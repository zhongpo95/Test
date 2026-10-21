// FFmpeg의 영상 프레임과 오디오 재생 시계를 맞추고 함께 종료한다.
using System;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Text;
using System.Threading;

namespace Arcana.Video
{
    public sealed class VideoPlayer : IDisposable
    {
        public const int MaxWidth = 640, MaxHeight = 360, FramesPerSecond = 30;
        public const int FrameBytes = MaxWidth * MaxHeight * 4;
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
        private readonly AudioPlayback audio;
        private Process process;
        private bool cancelDisposed;
        private volatile bool cancelled, finished;
        private volatile string status = "영상 읽는 중";
        private int frameNumber, frameWidth, frameHeight;
        private long finishedAt, clockOffset;

        internal DecodeSession(string exe, string path, bool temporary, Action<string> logger)
        {
            decoder = exe;
            filename = path;
            deleteFile = temporary;
            log = logger;
            audio = new AudioPlayback(exe, path, logger);
        }

        public string Status { get { return status + " / " + audio.Status; } }
        public int FrameNumber { get { return Volatile.Read(ref frameNumber); } }
        public bool Finished { get { return finished && clock.ElapsedMilliseconds - Interlocked.Read(ref finishedAt) >= 100; } }
        internal AudioPlayback Audio { get { return audio; } }

        internal void Start()
        {
            audio.Start();
            Thread worker = new Thread(Decode);
            worker.Name = "Arcana video decoder";
            worker.IsBackground = true;
            worker.Start();
        }

        public bool CopyFrame(byte[] destination, int previous, out int number, out int width, out int height)
        {
            lock (frameLock)
            {
                number = frameNumber;
                width = frameWidth;
                height = frameHeight;
                if (number == 0 || number == previous) return false;
                Buffer.BlockCopy(published, 0, destination, 0, width * height * 4);
                return true;
            }
        }

        internal void Stop()
        {
            audio.Stop();
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
                        "-hide_banner -loglevel error -nostdin -threads 2 -copyts -start_at_zero -protocol_whitelist file,pipe -i \"" + filename +
                        "\" -map 0:v:0 -an -sn -dn -vf \"fps=30:start_time=0,scale=640:360:force_original_aspect_ratio=decrease:reset_sar=1\"" +
                        " -c:v pam -pix_fmt rgba -f image2pipe pipe:1");
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
                using (Stream output = new BufferedStream(child.StandardOutput.BaseStream, 65536))
                {
                    int index = 0;
                    while (!cancelled)
                    {
                        int width, height;
                        if (!ReadPamFrame(output, buffer, out width, out height) || cancelled) break;
                        if (index == 0) audio.WaitUntilReady(cancel);
                        if (cancelled) break;
                        if (!clock.IsRunning) clock.Start();
                        if (!WaitForPlaybackTime(index * 1000L / VideoPlayer.FramesPerSecond)) break;
                        lock (frameLock)
                        {
                            Buffer.BlockCopy(buffer, 0, published, 0, width * height * 4);
                            frameWidth = width;
                            frameHeight = height;
                            frameNumber++;
                        }
                        if (index == 0)
                        {
                            audio.BeginPlayback();
                            log("영상 출력 크기. " + width + "x" + height);
                        }
                        status = "재생 중 / 프레임 " + frameNumber;
                        index++;
                    }
                }
                if (!cancelled)
                {
                    if (!child.WaitForExit(3000)) throw new IOException("영상 디코더 종료 시간 초과");
                    child.WaitForExit();
                    if (child.ExitCode != 0 || frameNumber == 0)
                        throw new IOException("영상 디코딩 실패. " + error.Trim());
                    // 마지막 프레임의 표시 시간과 남은 오디오가 끝난 뒤 함께 닫는다.
                    WaitForPlaybackTime(frameNumber * 1000L / VideoPlayer.FramesPerSecond);
                    while (!cancelled && !audio.Completed) cancel.WaitOne(10);
                    if (!cancelled)
                    {
                        status = "재생 완료 / " + frameNumber + " 프레임";
                        log(Status);
                    }
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
                audio.Dispose();
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

        private bool WaitForPlaybackTime(long target)
        {
            while (!cancelled)
            {
                long audioTime;
                if (audio.TryGetMilliseconds(out audioTime)) clockOffset = audioTime - clock.ElapsedMilliseconds;
                long remaining = target - (clock.ElapsedMilliseconds + clockOffset);
                if (remaining <= 0) return true;
                if (cancel.WaitOne((int)Math.Min(remaining, 10))) break;
            }
            return false;
        }

        // FFmpeg가 보낸 RGBA PAM 헤더에서 크기를 읽고 고정 최대 버퍼 안에서만 수신한다.
        internal static bool ReadPamFrame(Stream input, byte[] pixels, out int width, out int height)
        {
            width = height = 0;
            string magic = ReadHeaderLine(input, true);
            if (magic == null) return false;
            if (magic != "P7") throw new InvalidDataException("영상 프레임 헤더가 잘못되었습니다.");
            int fields = 0;
            bool ended = false;
            for (int lineIndex = 0; lineIndex < 16; lineIndex++)
            {
                string line = ReadHeaderLine(input, false);
                if (line == "ENDHDR") { ended = true; break; }
                int field;
                if (line.StartsWith("WIDTH ", StringComparison.Ordinal) &&
                    Int32.TryParse(line.Substring(6), NumberStyles.None, CultureInfo.InvariantCulture, out width)) field = 1;
                else if (line.StartsWith("HEIGHT ", StringComparison.Ordinal) &&
                    Int32.TryParse(line.Substring(7), NumberStyles.None, CultureInfo.InvariantCulture, out height)) field = 2;
                else if (line == "DEPTH 4") field = 4;
                else if (line == "MAXVAL 255") field = 8;
                else if (line == "TUPLTYPE RGB_ALPHA") field = 16;
                else throw new InvalidDataException("지원하지 않는 영상 프레임 형식입니다.");
                if ((fields & field) != 0) throw new InvalidDataException("영상 프레임 헤더가 중복되었습니다.");
                fields |= field;
            }
            if (!ended || fields != 31 || width < 1 || width > VideoPlayer.MaxWidth ||
                height < 1 || height > VideoPlayer.MaxHeight)
                throw new InvalidDataException("영상 프레임 크기가 허용 범위를 벗어났습니다.");
            int bytes = width * height * 4, used = 0;
            if (pixels.Length < bytes) throw new InvalidDataException("영상 프레임 버퍼가 부족합니다.");
            while (used < bytes)
            {
                int count = input.Read(pixels, used, bytes - used);
                if (count == 0) throw new InvalidDataException("영상 프레임이 잘렸습니다.");
                used += count;
            }
            return true;
        }

        private static string ReadHeaderLine(Stream input, bool allowEnd)
        {
            StringBuilder line = new StringBuilder();
            for (int i = 0; i < 128; i++)
            {
                int value = input.ReadByte();
                if (value < 0)
                {
                    if (allowEnd && i == 0) return null;
                    throw new InvalidDataException("영상 프레임 헤더가 잘렸습니다.");
                }
                if (value == '\n') return line.ToString();
                if (value < 32 || value > 126) throw new InvalidDataException("영상 프레임 헤더가 잘못되었습니다.");
                line.Append((char)value);
            }
            throw new InvalidDataException("영상 프레임 헤더가 너무 깁니다.");
        }
    }
}
