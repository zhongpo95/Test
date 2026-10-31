// FFmpeg의 PCM 소리를 제한된 waveOut 버퍼로 재생하고 영상에 재생 시계를 제공한다.
using System;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using System.Threading;

namespace Arcana.Video
{
    internal sealed class AudioPlayback : IDisposable
    {
        private readonly string decoder, filename;
        private readonly Action<string> log;
        private readonly object sync = new object();
        private readonly ManualResetEvent ready = new ManualResetEvent(false), play = new ManualResetEvent(false), cancel = new ManualResetEvent(false);
        private readonly Stopwatch tailClock = new Stopwatch();
        private readonly Thread worker;
        private Process process;
        private WaveOutput output;
        private bool started, disposed;
        private volatile bool cancelled, completed;
        private long lastPosition, submittedBytes;
        private volatile string status = "오디오 준비 중";

        internal AudioPlayback(string exe, string path, Action<string> logger)
        {
            decoder = exe; filename = path; log = logger;
            worker = new Thread(Decode);
            worker.Name = "Arcana audio decoder";
            worker.IsBackground = true;
        }

        internal string Status { get { return status; } }
        internal bool Completed { get { return completed; } }
        internal long SubmittedBytes { get { return Interlocked.Read(ref submittedBytes); } }
        internal void Start() { worker.Start(); }

        internal void WaitUntilReady(WaitHandle videoCancel)
        {
            if (WaitHandle.WaitAny(new WaitHandle[] { ready, videoCancel }, 5000) == WaitHandle.WaitTimeout)
            {
                log("오디오 준비 시간 초과. 영상만 재생합니다.");
                Stop();
            }
        }

        internal void BeginPlayback()
        {
            lock (sync)
            {
                if (cancelled || output == null || started) return;
                try
                {
                    output.Restart();
                    started = true;
                    status = "오디오 재생 중";
                    play.Set();
                    log("오디오 출력 시작. PCM 48000Hz / 2채널 / 16비트");
                }
                catch (Exception e) { log("오디오 시작 실패. " + e.Message); Stop(); }
            }
        }

        internal bool TryGetMilliseconds(out long value)
        {
            lock (sync)
            {
                value = lastPosition;
                if (!started || cancelled) return false;
                if (output != null)
                {
                    try { lastPosition = Math.Max(lastPosition, output.PositionMilliseconds); }
                    catch (IOException e)
                    {
                        log("오디오 재생 위치 확인 실패. " + e.Message);
                        Stop();
                        return false;
                    }
                    value = lastPosition;
                }
                else value = lastPosition + tailClock.ElapsedMilliseconds;
                return true;
            }
        }

        internal void Stop()
        {
            lock (sync)
            {
                if (disposed) return;
                cancelled = true;
                if (!completed) status = "오디오 닫힘";
                cancel.Set();
                if (output != null) output.Reset();
                if (process != null)
                {
                    try { if (!process.HasExited) process.Kill(); }
                    catch (InvalidOperationException) { }
                    catch (System.ComponentModel.Win32Exception e) { log("오디오 디코더 종료 실패. " + e.Message); }
                }
            }
        }

        public void Dispose()
        {
            Stop();
            if (!worker.Join(5000)) { log("오디오 작업 정리 시간 초과"); return; }
            lock (sync)
            {
                if (disposed) return;
                disposed = true;
                ready.Dispose(); play.Dispose(); cancel.Dispose();
            }
        }

        private void Decode()
        {
            Process child = null;
            string error = "";
            try
            {
                lock (sync)
                {
                    if (cancelled) return;
                    child = new Process();
                    child.StartInfo = new ProcessStartInfo(decoder,
                        "-hide_banner -loglevel error -nostdin -threads 2 -copyts -start_at_zero -protocol_whitelist file,pipe -i \"" + filename +
                        "\" -map 0:a:0? -vn -sn -dn -af \"aresample=48000:async=1:first_pts=0\" -ac 2 -ar 48000 -c:a pcm_s16le -f s16le pipe:1");
                    child.StartInfo.UseShellExecute = false;
                    child.StartInfo.CreateNoWindow = true;
                    child.StartInfo.RedirectStandardOutput = true;
                    child.StartInfo.RedirectStandardError = true;
                    child.ErrorDataReceived += delegate(object sender, DataReceivedEventArgs e)
                    { if (e.Data != null && error.Length < 4096) error += e.Data + "\n"; };
                    child.Start();
                    process = child;
                    child.BeginErrorReadLine();
                }
                byte[] buffer = new byte[WaveOutput.BufferBytes];
                int index = 0;
                bool atEnd = false;
                using (Stream input = new BufferedStream(child.StandardOutput.BaseStream, 16384))
                {
                    while (!cancelled)
                    {
                        int count = 0;
                        while (count < buffer.Length)
                        {
                            int read = input.Read(buffer, count, buffer.Length - count);
                            if (read == 0) { atEnd = true; break; }
                            count += read;
                        }
                        if (cancelled) break;
                        if (count % 4 != 0) throw new InvalidDataException("PCM 오디오 프레임이 잘렸습니다.");
                        if (count > 0)
                        {
                            int slot = index % WaveOutput.BufferCount;
                            while (!cancelled)
                            {
                                bool available;
                                lock (sync) { available = output == null || output.Available(slot); }
                                if (available || cancel.WaitOne(5)) break;
                            }
                            lock (sync)
                            {
                                if (cancelled) break;
                                if (output == null) output = new WaveOutput();
                                output.Write(slot, buffer, count);
                                Interlocked.Add(ref submittedBytes, count);
                            }
                            index++;
                        }
                        if (index == WaveOutput.BufferCount || atEnd)
                        {
                            ready.Set();
                            if (index > 0 && WaitHandle.WaitAny(new WaitHandle[] { play, cancel }) == 1) break;
                        }
                        if (atEnd) break;
                    }
                }
                if (!cancelled)
                {
                    if (!child.WaitForExit(3000)) throw new IOException("오디오 디코더 종료 시간 초과");
                    child.WaitForExit();
                    if (SubmittedBytes == 0)
                    {
                        status = "오디오 출력 없음";
                        log(status + (error.Length == 0 ? "" : ". " + error.Trim()));
                    }
                    else
                    {
                        if (child.ExitCode != 0) throw new IOException("오디오 디코딩 실패. " + error.Trim());
                        Stopwatch drain = Stopwatch.StartNew();
                        while (!cancelled)
                        {
                            bool pending;
                            lock (sync) { pending = output != null && output.HasPendingBuffers; }
                            if (!pending || cancel.WaitOne(5)) break;
                            if (drain.ElapsedMilliseconds > 5000) throw new IOException("오디오 출력 종료 시간 초과");
                        }
                        if (!cancelled) { status = "오디오 완료"; log(status + " / " + SubmittedBytes + " PCM 바이트"); }
                    }
                }
            }
            catch (Exception e)
            {
                if (!cancelled) { status = "오디오 오류"; log(status + ". " + e.Message + " / 영상 재생은 계속합니다."); }
            }
            finally
            {
                lock (sync)
                {
                    if (output != null)
                    {
                        if (started && !cancelled)
                        {
                            try { lastPosition = Math.Max(lastPosition, output.PositionMilliseconds); }
                            catch (IOException) { }
                            tailClock.Start();
                        }
                        output.Dispose();
                        output = null;
                    }
                    if (child != null)
                    {
                        try { if (!child.HasExited) { child.Kill(); child.WaitForExit(2000); } }
                        catch (InvalidOperationException) { }
                        catch (System.ComponentModel.Win32Exception e) { log("오디오 디코더 정리 실패. " + e.Message); }
                        child.Dispose();
                    }
                    process = null;
                    completed = true;
                    ready.Set();
                }
            }
        }
    }

    internal sealed class WaveOutput : IDisposable
    {
        internal const int BufferCount = 4, BufferBytes = 9600, BytesPerSecond = 48000 * 4;
        [StructLayout(LayoutKind.Sequential, Pack = 2)]
        private struct WaveFormat
        {
            internal ushort Format, Channels;
            internal uint SamplesPerSecond, AverageBytesPerSecond;
            internal ushort BlockAlign, BitsPerSample, ExtraBytes;
        }
        [StructLayout(LayoutKind.Sequential)]
        private struct WaveHeader
        {
            internal IntPtr Data;
            internal uint Length, Recorded;
            internal UIntPtr User;
            internal uint Flags, Loops;
            internal IntPtr Next;
            internal UIntPtr Reserved;
        }
        [StructLayout(LayoutKind.Explicit, Size = 12)]
        private struct MultimediaTime
        {
            [FieldOffset(0)] internal uint Type;
            [FieldOffset(4)] internal uint Value;
        }
        [DllImport("winmm.dll")] private static extern uint waveOutOpen(out IntPtr device, uint id, ref WaveFormat format, IntPtr callback, IntPtr instance, uint flags);
        [DllImport("winmm.dll")] private static extern uint waveOutPrepareHeader(IntPtr device, IntPtr header, uint size);
        [DllImport("winmm.dll")] private static extern uint waveOutUnprepareHeader(IntPtr device, IntPtr header, uint size);
        [DllImport("winmm.dll")] private static extern uint waveOutWrite(IntPtr device, IntPtr header, uint size);
        [DllImport("winmm.dll")] private static extern uint waveOutPause(IntPtr device);
        [DllImport("winmm.dll")] private static extern uint waveOutRestart(IntPtr device);
        [DllImport("winmm.dll")] private static extern uint waveOutReset(IntPtr device);
        [DllImport("winmm.dll")] private static extern uint waveOutClose(IntPtr device);
        [DllImport("winmm.dll")] private static extern uint waveOutGetPosition(IntPtr device, ref MultimediaTime time, uint size);
        private IntPtr device;
        private readonly IntPtr[] headers = new IntPtr[BufferCount], data = new IntPtr[BufferCount];
        private readonly bool[] prepared = new bool[BufferCount], queued = new bool[BufferCount];
        private static readonly uint headerSize = (uint)Marshal.SizeOf(typeof(WaveHeader));
        private static readonly int flagsOffset = (int)Marshal.OffsetOf(typeof(WaveHeader), "Flags");
        private uint lastRawPosition;
        private long positionWrap;
#if VIDEO_SELF_TEST
        internal static bool FailOpenForTest;
        internal static int OpenDevicesForTest;
#endif

        internal WaveOutput()
        {
            try
            {
#if VIDEO_SELF_TEST
                if (FailOpenForTest) throw new IOException("시험용 오디오 장치 열기 실패");
#endif
                WaveFormat format = new WaveFormat();
                format.Format = 1; format.Channels = 2; format.SamplesPerSecond = 48000;
                format.AverageBytesPerSecond = BytesPerSecond; format.BlockAlign = 4; format.BitsPerSample = 16;
                Check(waveOutOpen(out device, UInt32.MaxValue, ref format, IntPtr.Zero, IntPtr.Zero, 0), "장치 열기");
#if VIDEO_SELF_TEST
                Interlocked.Increment(ref OpenDevicesForTest);
#endif
                Check(waveOutPause(device), "출력 준비");
                for (int i = 0; i < BufferCount; i++)
                {
                    data[i] = Marshal.AllocHGlobal(BufferBytes);
                    headers[i] = Marshal.AllocHGlobal((int)headerSize);
                    WaveHeader header = new WaveHeader();
                    header.Data = data[i]; header.Length = BufferBytes;
                    Marshal.StructureToPtr(header, headers[i], false);
                    Check(waveOutPrepareHeader(device, headers[i], headerSize), "버퍼 준비");
                    prepared[i] = true;
                }
            }
            catch { Dispose(); throw; }
        }

        internal bool Available(int slot) { return !queued[slot] || (Marshal.ReadInt32(headers[slot], flagsOffset) & 1) != 0; }
        internal bool HasPendingBuffers
        {
            get { for (int i = 0; i < BufferCount; i++) if (!Available(i)) return true; return false; }
        }
        internal void Write(int slot, byte[] buffer, int count)
        {
            Marshal.Copy(buffer, 0, data[slot], count);
            Marshal.WriteInt32(headers[slot], IntPtr.Size, count);
            Check(waveOutWrite(device, headers[slot], headerSize), "버퍼 출력");
            queued[slot] = true;
        }
        internal void Restart() { Check(waveOutRestart(device), "재생 시작"); }
        internal void Reset() { if (device != IntPtr.Zero) waveOutReset(device); }
        internal long PositionMilliseconds
        {
            get
            {
                MultimediaTime time = new MultimediaTime(); time.Type = 4;
                Check(waveOutGetPosition(device, ref time, 12), "재생 위치");
                if (time.Value < lastRawPosition) positionWrap += 1L << 32;
                lastRawPosition = time.Value;
                long value = positionWrap + time.Value;
                if (time.Type == 4) return value * 1000 / BytesPerSecond;
                if (time.Type == 2) return value * 1000 / 48000;
                if (time.Type == 1) return value;
                throw new IOException("지원하지 않는 오디오 재생 위치 형식입니다.");
            }
        }
        public void Dispose()
        {
            Reset();
            for (int i = 0; i < BufferCount; i++)
            {
                // 드라이버가 아직 소유한 버퍼는 해제하지 않아 네이티브 메모리 접근 오류를 막는다.
                if (prepared[i] && waveOutUnprepareHeader(device, headers[i], headerSize) != 0) continue;
                prepared[i] = false;
                if (headers[i] != IntPtr.Zero) { Marshal.FreeHGlobal(headers[i]); headers[i] = IntPtr.Zero; }
                if (data[i] != IntPtr.Zero) { Marshal.FreeHGlobal(data[i]); data[i] = IntPtr.Zero; }
            }
            if (device != IntPtr.Zero)
            {
                uint closed = waveOutClose(device);
#if VIDEO_SELF_TEST
                if (closed == 0) Interlocked.Decrement(ref OpenDevicesForTest);
#else
                if (closed != 0) Trace.WriteLine("[ArcanaVideo] 오디오 장치 정리 실패. MMRESULT=" + closed);
#endif
                device = IntPtr.Zero;
            }
        }
        private static void Check(uint result, string operation)
        {
            if (result != 0) throw new IOException("Windows 오디오 " + operation + " 실패. MMRESULT=" + result);
        }
    }
}
