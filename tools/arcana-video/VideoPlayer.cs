// FFmpeg가 읽은 영상 프레임을 제한된 버퍼로 전달하고 재생 종료를 관리한다.
using System;
using System.Diagnostics;
using System.IO;
using System.Threading;

namespace Arcana.Video
{
    public sealed class VideoPlayer : IDisposable
    {
        public const int Width = 640, Height = 360, FramesPerSecond = 30;
        public const int FrameBytes = Width * Height * 4;
        private readonly string decoder;
        private readonly Action<string> log;
        private DecodeSession session;
        private string status = "준비";

        public VideoPlayer(string decoderPath, Action<string> logger)
        {
            decoder = decoderPath;
            log = logger;
        }

        public DecodeSession Session { get { return Volatile.Read(ref session); } }
        public string Status
        {
            get
            {
                DecodeSession current = Session;
                return current == null ? status : current.Status;
            }
        }

        public void Open(string path, bool deleteAfterPlayback)
        {
            Close();
            if (!File.Exists(decoder)) throw new FileNotFoundException("FFmpeg 파일이 없습니다.", decoder);
            if (!File.Exists(path)) throw new FileNotFoundException("영상 파일이 없습니다.", path);
            DecodeSession next = new DecodeSession(decoder, Path.GetFullPath(path), deleteAfterPlayback, log);
            Interlocked.Exchange(ref session, next);
            status = "재생 시작";
            next.Start();
        }

        public void Close()
        {
            DecodeSession previous = Interlocked.Exchange(ref session, null);
            if (previous != null) previous.Stop();
            status = "닫힘";
        }

        public void Finish(DecodeSession finished)
        {
            if (Interlocked.CompareExchange(ref session, null, finished) == finished)
            {
                status = finished.Status;
                finished.Stop();
            }
        }

        public void Dispose() { Close(); }
    }

    public sealed class DecodeSession
    {
        private readonly string decoder, filename;
        private readonly bool deleteFile;
        private readonly Action<string> log;
        private readonly object frameLock = new object(), processLock = new object();
        private readonly byte[] published = new byte[VideoPlayer.FrameBytes];
        private readonly ManualResetEvent cancel = new ManualResetEvent(false);
        private readonly Stopwatch clock = new Stopwatch();
        private Process process;
        private bool cancelDisposed;
        private volatile bool cancelled, finished;
        private volatile string status = "영상 읽는 중";
        private int frameNumber;
        private long finishedAt;

        internal DecodeSession(string exe, string path, bool temporary, Action<string> logger)
        {
            decoder = exe;
            filename = path;
            deleteFile = temporary;
            log = logger;
        }

        public string Status { get { return status; } }
        public int FrameNumber { get { return Volatile.Read(ref frameNumber); } }
        public bool Finished { get { return finished && clock.ElapsedMilliseconds - Interlocked.Read(ref finishedAt) >= 100; } }

        internal void Start()
        {
            Thread worker = new Thread(Decode);
            worker.Name = "Arcana video decoder";
            worker.IsBackground = true;
            worker.Start();
        }

        public bool CopyFrame(byte[] destination, int previous, out int number)
        {
            lock (frameLock)
            {
                number = frameNumber;
                if (number == 0 || number == previous) return false;
                Buffer.BlockCopy(published, 0, destination, 0, published.Length);
                return true;
            }
        }

        internal void Stop()
        {
            lock (processLock)
            {
                cancelled = true;
                if (!cancelDisposed) cancel.Set();
                if (process != null)
                {
                    try { if (!process.HasExited) process.Kill(); }
                    catch (InvalidOperationException) { }
                    catch (System.ComponentModel.Win32Exception e) { log("디코더 종료 요청 실패. " + e.Message); }
                }
            }
        }

        private void Decode()
        {
            Process child = null;
            string error = "";
            try
            {
                lock (processLock)
                {
                    if (cancelled) return;
                    child = new Process();
                    child.StartInfo = new ProcessStartInfo(decoder,
                        "-hide_banner -loglevel error -nostdin -threads 2 -protocol_whitelist file,pipe -i \"" + filename +
                        "\" -map 0:v:0 -an -sn -dn -vf \"fps=30,scale=640:360:force_original_aspect_ratio=decrease," +
                        "pad=640:360:(ow-iw)/2:(oh-ih)/2\" -pix_fmt bgra -f rawvideo pipe:1");
                    child.StartInfo.UseShellExecute = false;
                    child.StartInfo.CreateNoWindow = true;
                    child.StartInfo.RedirectStandardOutput = true;
                    child.StartInfo.RedirectStandardError = true;
                    child.ErrorDataReceived += delegate(object sender, DataReceivedEventArgs e)
                    {
                        if (e.Data != null && error.Length < 4096) error += e.Data + "\n";
                    };
                    child.Start();
                    process = child;
                    child.BeginErrorReadLine();
                }
                byte[] buffer = new byte[VideoPlayer.FrameBytes];
                Stream output = child.StandardOutput.BaseStream;
                int index = 0;
                while (!cancelled)
                {
                    int used = 0;
                    while (used < buffer.Length && !cancelled)
                    {
                        int count = output.Read(buffer, used, buffer.Length - used);
                        if (count == 0) break;
                        used += count;
                    }
                    if (cancelled || used == 0) break;
                    if (used != buffer.Length) throw new InvalidDataException("영상 프레임이 잘렸습니다.");
                    if (!clock.IsRunning) clock.Start();
                    int delay = (int)Math.Max(0, index * 1000L / VideoPlayer.FramesPerSecond - clock.ElapsedMilliseconds);
                    if (cancel.WaitOne(delay)) break;
                    lock (frameLock)
                    {
                        Buffer.BlockCopy(buffer, 0, published, 0, buffer.Length);
                        frameNumber++;
                    }
                    status = "재생 중 / 프레임 " + frameNumber;
                    index++;
                }
                if (!cancelled)
                {
                    if (!child.WaitForExit(3000)) throw new IOException("영상 디코더 종료 시간 초과");
                    child.WaitForExit();
                    if (child.ExitCode != 0 || frameNumber == 0)
                        throw new IOException("영상 디코딩 실패. " + error.Trim());
                    status = "재생 완료 / " + frameNumber + " 프레임";
                    log(status);
                }
            }
            catch (Exception e)
            {
                if (!cancelled)
                {
                    status = "오류. " + e.Message;
                    log(status);
                }
            }
            finally
            {
                lock (processLock)
                {
                    if (child != null)
                    {
                        try { if (!child.HasExited) { child.Kill(); child.WaitForExit(2000); } }
                        catch (InvalidOperationException) { }
                        catch (System.ComponentModel.Win32Exception e) { log("디코더 정리 실패. " + e.Message); }
                        child.Dispose();
                    }
                    process = null;
                    cancel.Dispose();
                    cancelDisposed = true;
                }
                if (deleteFile)
                {
                    try { File.Delete(filename); }
                    catch (IOException e) { log("임시 영상 정리 실패. " + e.Message); }
                    catch (UnauthorizedAccessException e) { log("임시 영상 정리 권한 오류. " + e.Message); }
                }
                if (!clock.IsRunning) clock.Start();
                Interlocked.Exchange(ref finishedAt, clock.ElapsedMilliseconds);
                finished = true;
            }
        }
    }
}
