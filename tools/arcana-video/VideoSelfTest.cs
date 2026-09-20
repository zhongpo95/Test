// 워크래프트를 실행하지 않고 별도 OpenGL 컨텍스트에서 영상과 상태 복원을 검증한다.
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;
using System.Windows.Forms;

namespace Arcana.Video
{
    internal static class VideoSelfTest
    {
        [StructLayout(LayoutKind.Sequential)]
        private struct PixelFormat
        {
            public ushort Size, Version;
            public uint Flags;
            public byte PixelType, ColorBits, RedBits, RedShift, GreenBits, GreenShift, BlueBits, BlueShift,
                AlphaBits, AlphaShift, AccumBits, AccumRedBits, AccumGreenBits, AccumBlueBits, AccumAlphaBits,
                DepthBits, StencilBits, AuxBuffers, LayerType, Reserved;
            public uint LayerMask, VisibleMask, DamageMask;
        }
        [DllImport("user32.dll")] private static extern IntPtr GetDC(IntPtr window);
        [DllImport("user32.dll")] private static extern int ReleaseDC(IntPtr window, IntPtr dc);
        [DllImport("gdi32.dll")] private static extern int ChoosePixelFormat(IntPtr dc, ref PixelFormat format);
        [DllImport("gdi32.dll")] private static extern bool SetPixelFormat(IntPtr dc, int number, ref PixelFormat format);
        [DllImport("gdi32.dll")] private static extern bool SwapBuffers(IntPtr dc);
        [DllImport("opengl32.dll")] private static extern bool wglSwapLayerBuffers(IntPtr dc, uint planes);
        [DllImport("opengl32.dll")] private static extern IntPtr wglCreateContext(IntPtr dc);
        [DllImport("opengl32.dll")] private static extern bool wglMakeCurrent(IntPtr dc, IntPtr context);
        [DllImport("opengl32.dll")] private static extern bool wglDeleteContext(IntPtr context);
        [DllImport("opengl32.dll")] private static extern uint glGetError();
        [DllImport("opengl32.dll")] private static extern void glClearColor(float r, float g, float b, float a);
        [DllImport("opengl32.dll")] private static extern void glClear(uint mask);
        [DllImport("opengl32.dll")] private static extern byte glIsEnabled(uint state);
        [DllImport("opengl32.dll")] private static extern void glReadBuffer(uint buffer);
        [DllImport("opengl32.dll")] private static extern void glReadPixels(int x, int y, int w, int h, uint format, uint type, byte[] pixels);

        private static int checkedFrames, changedFrames;
        private static long previousHash;
        private static Exception callbackError;
        private static bool useLayers;
        private static bool captureNext;
        private static byte[] capturedScreen;
        private static string output;
        private static readonly List<string> results = new List<string>();

        [STAThread]
        private static int Main(string[] args)
        {
            try
            {
                if (args.Length < 3 || args.Length > 5) throw new ArgumentException("decoder.exe clip.mp4 output-folder [aspect-fixtures-folder] [audio-fixtures-folder]");
                output = args[2];
                Directory.CreateDirectory(output);
                TestFrameReader();
                using (Form form = new Form())
                {
                    form.ClientSize = new Size(800, 600);
                    form.ShowInTaskbar = false;
                    // 핸들만 만들며 창은 표시하지 않는다.
                    IntPtr window = form.Handle, dc = GetDC(window);
                    PixelFormat format = new PixelFormat();
                    format.Size = (ushort)Marshal.SizeOf(typeof(PixelFormat));
                    format.Version = 1; format.Flags = 0x25; format.ColorBits = 32;
                    format.DepthBits = 24; format.StencilBits = 8;
                    int choice = ChoosePixelFormat(dc, ref format);
                    Require(choice != 0 && SetPixelFormat(dc, choice, ref format), "OpenGL pixel format");
                    IntPtr context = wglCreateContext(dc);
                    Require(context != IntPtr.Zero && wglMakeCurrent(dc, context), "OpenGL context");
                    try
                    {
                        using (VideoPlayer player = new VideoPlayer(args[0], Console.WriteLine))
                        using (OpenGlOverlay overlay = new OpenGlOverlay(player, Console.WriteLine))
                        {
                            overlay.Install();
                            overlay.BeforeSwap = Inspect;
                            Pump(dc);
                            Require(overlay.HasRecentContext, "SwapBuffers hook detects OpenGL");
                            useLayers = true;
                            int beforeLayers = checkedFrames;
                            Pump(dc);
                            Require(checkedFrames == beforeLayers + 1, "wglSwapLayerBuffers draws exactly once");
                            player.Open(args[1], false);
                            RunFor(dc, 1600);
                            Require(changedFrames >= 10, "Decoded frames change on the OpenGL surface");
                            player.Close();
                            Pump(dc);
                            Require(player.Session == null, "Manual close");
                            player.Open(args[1], false);
                            DecodeSession replay = player.Session;
                            Stopwatch deadline = Stopwatch.StartNew();
                            while (player.Session != null && deadline.ElapsedMilliseconds < 12000) { Pump(dc); Thread.Sleep(12); }
                            Require(player.Session == null && replay.FrameNumber == 240, "Replay and automatic close after 240 frames");
                            Require(replay.Audio.SubmittedBytes == 0 && replay.Audio.Completed, "Silent video needs no audio output");
                            if (args.Length >= 4)
                            {
                                TestAspect(dc, player, args[3], "square", 360, 360, 30, true);
                                TestAspect(dc, player, args[3], "portrait", 203, 360, 30, true);
                                TestAspect(dc, player, args[3], "wide", 640, 213, 30, true);
                                TestAspect(dc, player, args[3], "anamorphic", 640, 240, 30, true);
                                TestAspect(dc, player, args[3], "user", 203, 360, 356, false);
                            }
                            if (args.Length == 5) TestAudio(dc, player, args[4]);
                            for (int i = 0; i < 8; i++) { player.Open(args[1], false); Thread.Sleep(15); player.Close(); Pump(dc); }
                            Require(player.Session == null, "Repeated open and close");
                            string corrupt = Path.Combine(output, "invalid.mp4");
                            File.WriteAllText(corrupt, "invalid video");
                            player.Open(corrupt, true);
                            RunFor(dc, 2000);
                            Require(player.Session == null && player.Status.StartsWith("오류", StringComparison.Ordinal), "Invalid video fails without breaking rendering");
                            Require(!File.Exists(corrupt), "Temporary video cleanup");
                            bool missingRejected = false;
                            try { player.Open(Path.Combine(output, "does-not-exist.mp4"), false); }
                            catch (FileNotFoundException) { missingRejected = true; }
                            Require(missingRejected, "Missing video rejected");
                            overlay.BeforeSwap = null;
                        }
                        RunFor(dc, 1000);
                        Require(callbackError == null, "Graphics state restored on every observed swap");
                        Require(WaveOutput.OpenDevicesForTest == 0, "All waveOut devices closed after playback and errors");
                    }
                    finally
                    {
                        wglMakeCurrent(IntPtr.Zero, IntPtr.Zero);
                        wglDeleteContext(context);
                        ReleaseDC(window, dc);
                    }
                }
                File.WriteAllLines(Path.Combine(output, "self-test.txt"), results.ToArray());
                Console.WriteLine("PASS " + results.Count + " checks; " + checkedFrames + " swaps; " + changedFrames + " changed frame samples");
                return 0;
            }
            catch (Exception e)
            {
                Console.Error.WriteLine(e);
                if (output != null) File.WriteAllText(Path.Combine(output, "self-test-failure.txt"), e.ToString());
                return 1;
            }
        }

        private static void Require(bool condition, string message)
        {
            if (!condition) throw new InvalidOperationException("FAIL. " + message);
            results.Add("PASS. " + message);
        }

        private static void TestFrameReader()
        {
            byte[] pixels = new byte[VideoPlayer.FrameBytes];
            string header = "P7\nWIDTH 1\nHEIGHT 1\nDEPTH 4\nMAXVAL 255\nTUPLTYPE RGB_ALPHA\nENDHDR\n";
            using (MemoryStream data = new MemoryStream())
            {
                for (int i = 0; i < 2; i++)
                {
                    byte[] bytes = Encoding.ASCII.GetBytes(header);
                    data.Write(bytes, 0, bytes.Length);
                    // 헤더 구분 문자와 같은 값도 픽셀로 보존해야 한다.
                    data.Write(new byte[] { 10, 13, 32, 255 }, 0, 4);
                }
                data.Position = 0;
                int width, height;
                for (int i = 0; i < 2; i++)
                    Require(DecodeSession.ReadPamFrame(data, pixels, out width, out height) && width == 1 && height == 1 &&
                        pixels[0] == 10 && pixels[1] == 13 && pixels[2] == 32 && pixels[3] == 255, "PAM frame boundary " + i);
                Require(!DecodeSession.ReadPamFrame(data, pixels, out width, out height), "PAM clean end of stream");
            }
            foreach (string invalid in new string[] { header, header.Replace("WIDTH 1", "WIDTH 999999999"),
                header.Replace("DEPTH 4", "DEPTH 3"), "P7\n" + new string('X', 129), "P7\nWIDTH 1" })
            {
                bool rejected = false;
                using (MemoryStream data = new MemoryStream(Encoding.ASCII.GetBytes(invalid)))
                {
                    int width, height;
                    try { DecodeSession.ReadPamFrame(data, pixels, out width, out height); }
                    catch (InvalidDataException) { rejected = true; }
                }
                Require(rejected, "Invalid or truncated PAM frame rejected");
            }
        }

        private static void TestAspect(IntPtr dc, VideoPlayer player, string folder, string name,
            int expectedWidth, int expectedHeight, int expectedFrames, bool colorFixture)
        {
            player.Open(Path.Combine(folder, name + ".mp4"), false);
            DecodeSession current = player.Session;
            Stopwatch deadline = Stopwatch.StartNew();
            bool sampled = false;
            while (player.Session != null && deadline.ElapsedMilliseconds < 16000)
            {
                Pump(dc);
                if (!sampled && current.FrameNumber >= 5 && player.Session != null)
                {
                    byte[] frame = new byte[VideoPlayer.FrameBytes];
                    int number, width, height;
                    current.CopyFrame(frame, 0, out number, out width, out height);
                    Require(width == expectedWidth && height == expectedHeight, name + " decoded dimensions");
                    captureNext = true;
                    Pump(dc);
                    byte[] screen = capturedScreen;
                    double ratio = (double)expectedWidth / expectedHeight;
                    double w = Math.Min(560, 360 * ratio), h = w / ratio;
                    int left = (int)Math.Round((800 - w) / 2), top = (int)Math.Round((600 - h) / 2);
                    Require(IsBackground(screen, left - 10, 300) && IsBackground(screen, 800 - left + 10, 300),
                        name + " game background remains beside video");
                    if (colorFixture)
                    {
                        int minX = 800, minY = 600, maxX = -1, maxY = -1;
                        for (int y = 0; y < 600; y++)
                            for (int x = 0; x < 800; x++)
                                if (!IsBackground(screen, x, y))
                                {
                                    minX = Math.Min(minX, x); maxX = Math.Max(maxX, x);
                                    minY = Math.Min(minY, y); maxY = Math.Max(maxY, y);
                                }
                        Require(Math.Abs(minX - left) <= 1 && Math.Abs(minY - top) <= 1 &&
                            Math.Abs((maxX - minX + 1) - w) <= 1 && Math.Abs((maxY - minY + 1) - h) <= 1,
                            name + " rendered bounds preserve aspect without padding");
                        int upper = ((599 - (top + (int)(h / 4))) * 800 + 400) * 4;
                        int lower = ((599 - (top + (int)(h * 3 / 4))) * 800 + 400) * 4;
                        Require(screen[upper + 2] > 220 && screen[upper] < 25 && screen[lower] > 220 && screen[lower + 2] < 25,
                            name + " color channels and vertical orientation");
                    }
                    SaveFrame(screen, name + ".png");
                    sampled = true;
                }
                Thread.Sleep(12);
            }
            Require(sampled && player.Session == null && current.FrameNumber == expectedFrames,
                name + " complete playback and automatic close");
            captureNext = true;
            Pump(dc);
            Require(IsBackground(capturedScreen, 400, 300), name + " game background restored after playback");
            if (name == "user")
                Require(current.Audio.SubmittedBytes > 2200000 && current.Audio.Completed && current.Audio.Status == "오디오 완료",
                    "User AAC audio completely submitted and drained through Windows waveOut");
        }

        private static void TestAudio(IntPtr dc, VideoPlayer player, string folder)
        {
            TestAudioClip(dc, player, Path.Combine(folder, "together.mp4"), 60, 2000, 2000);
            TestAudioClip(dc, player, Path.Combine(folder, "short-audio.mp4"), 90, 1000, 3000);
            TestAudioClip(dc, player, Path.Combine(folder, "long-audio.mp4"), 30, 3000, 3000);
            TestAudioClip(dc, player, Path.Combine(folder, "delayed-audio.mp4"), 120, 3000, 4000);
            TestAudioClip(dc, player, Path.Combine(folder, "opus.webm"), 60, 2000, 2000);
            List<DecodeSession> stopped = new List<DecodeSession>();
            for (int i = 0; i < 3; i++)
            {
                player.Open(Path.Combine(folder, "together.mp4"), false);
                DecodeSession current = player.Session;
                stopped.Add(current);
                RunFor(dc, 700);
                Require(current.Audio.SubmittedBytes > 0, "Audio starts on replay " + i);
                player.Close();
                long position;
                Require(!current.Audio.TryGetMilliseconds(out position) && player.Session == null, "Close stops audio clock and video immediately " + i);
                RunFor(dc, 250);
                Require(current.Audio.Completed && WaveOutput.OpenDevicesForTest == 0, "Close drains owned worker and releases device " + i);
            }
            for (int i = 0; i < 8; i++)
            {
                player.Open(Path.Combine(folder, "together.mp4"), false);
                stopped.Add(player.Session);
                Thread.Sleep(15);
                player.Close();
            }
            RunFor(dc, 1000);
            Require(stopped.TrueForAll(delegate(DecodeSession value) { return value.Audio.Completed; }) && WaveOutput.OpenDevicesForTest == 0,
                "Rapid audio open and close leaves no active devices or workers");
            WaveOutput.FailOpenForTest = true;
            try
            {
                player.Open(Path.Combine(folder, "together.mp4"), false);
                DecodeSession current = player.Session;
                RunFor(dc, 3000);
                Require(player.Session == null && current.FrameNumber == 60 && current.Audio.Status == "오디오 오류",
                    "Unavailable audio device falls back to complete silent video");
            }
            finally { WaveOutput.FailOpenForTest = false; player.Close(); }
        }

        private static void TestAudioClip(IntPtr dc, VideoPlayer player, string clip, int frames, int audioMilliseconds, int durationMilliseconds)
        {
            player.Open(clip, false);
            DecodeSession current = player.Session;
            Stopwatch deadline = Stopwatch.StartNew(), playback = new Stopwatch();
            int samples = 0;
            long maximumDifference = 0;
            while (player.Session != null && deadline.ElapsedMilliseconds < durationMilliseconds + 6000)
            {
                Pump(dc);
                if (current.FrameNumber > 0 && !playback.IsRunning) playback.Start();
                long audioTime;
                if (current.FrameNumber > 1 && current.FrameNumber < frames && current.Audio.TryGetMilliseconds(out audioTime))
                {
                    maximumDifference = Math.Max(maximumDifference, Math.Abs((current.FrameNumber - 1) * 1000L / 30 - audioTime));
                    samples++;
                }
                Thread.Sleep(12);
            }
            string name = Path.GetFileName(clip);
            Require(player.Session == null && current.FrameNumber == frames && current.Audio.Status == "오디오 완료", name + " complete A/V playback");
            Require(Math.Abs(current.Audio.SubmittedBytes * 1000 / WaveOutput.BytesPerSecond - audioMilliseconds) < 70,
                name + " decoded audio duration including timestamp offset");
            Require(samples >= 10 && maximumDifference < 150, name + " video follows audio device clock within 150 ms (observed " + maximumDifference + " ms)");
            Require(playback.ElapsedMilliseconds >= durationMilliseconds - 100 && playback.ElapsedMilliseconds < durationMilliseconds + 1000,
                name + " automatic close waits for both streams");
            Require(WaveOutput.OpenDevicesForTest == 0, name + " output device released");
        }

        private static bool IsBackground(byte[] pixels, int x, int y)
        {
            int index = ((599 - y) * 800 + x) * 4;
            return Math.Abs(pixels[index] - 33) <= 2 && Math.Abs(pixels[index + 1] - 18) <= 2 && Math.Abs(pixels[index + 2] - 8) <= 2;
        }

        private static byte[] ReadScreen()
        {
            byte[] pixels = new byte[800 * 600 * 4];
            int oldReadBuffer = GL.Integer(0x0C02);
            glReadBuffer(0x0405);
            glReadPixels(0, 0, 800, 600, 0x80E1, 0x1401, pixels);
            glReadBuffer((uint)oldReadBuffer);
            return pixels;
        }

        private static void RunFor(IntPtr dc, int milliseconds)
        {
            Stopwatch timer = Stopwatch.StartNew();
            while (timer.ElapsedMilliseconds < milliseconds) { Pump(dc); Thread.Sleep(12); }
        }

        private static void Pump(IntPtr dc)
        {
            if (callbackError != null) throw new InvalidOperationException("Graphics callback verification failed", callbackError);
            GL.glDisable(0x0C11);
            GL.glColorMask(true, true, true, true);
            glClearColor(.03f, .07f, .13f, 1);
            glClear(0x00004000);
            GL.glViewport(17, 23, 700, 500);
            GL.glMatrixMode(0x1701);
            GL.glEnable(0x0B71);
            GL.glEnable(0x0BE2);
            GL.glEnable(0x0C11);
            GL.glPixelStorei(0x0CF5, 8);
            bool swapped = useLayers ? wglSwapLayerBuffers(dc, 1) : SwapBuffers(dc);
            if (!swapped) throw new InvalidOperationException("Buffer swap failed");
            Application.DoEvents();
        }

        private static void Inspect()
        {
            try
            {
                int[] viewport = new int[4];
                GL.glGetIntegerv(0x0BA2, viewport);
                if (viewport[0] != 17 || viewport[1] != 23 || viewport[2] != 700 || viewport[3] != 500 ||
                    GL.Integer(0x0BA0) != 0x1701 || GL.Integer(0x0CF5) != 8 ||
                    glIsEnabled(0x0B71) == 0 || glIsEnabled(0x0BE2) == 0 || glIsEnabled(0x0C11) == 0)
                    throw new InvalidOperationException("Viewport, matrix, unpack alignment or enable state changed");
                uint error = glGetError();
                if (error != 0) throw new InvalidOperationException("OpenGL error 0x" + error.ToString("X"));
                checkedFrames++;
                if (captureNext) { capturedScreen = ReadScreen(); captureNext = false; }
                if (checkedFrames % 4 != 0) return;
                byte[] pixels = new byte[800 * 600 * 4];
                int oldReadBuffer = GL.Integer(0x0C02);
                glReadBuffer(0x0405);
                glReadPixels(0, 0, 800, 600, 0x80E1, 0x1401, pixels);
                glReadBuffer((uint)oldReadBuffer);
                long hash = 17;
                for (int i = 0; i < pixels.Length; i += 79) hash = unchecked(hash * 31 + pixels[i]);
                if (previousHash != 0 && hash != previousHash)
                {
                    changedFrames++;
                    if (changedFrames == 5) SaveFrame(pixels, "opengl-video.png");
                }
                previousHash = hash;
            }
            catch (Exception e) { callbackError = e; }
        }

        private static void SaveFrame(byte[] pixels, string name)
        {
            using (Bitmap bitmap = new Bitmap(800, 600, PixelFormat32))
            {
                BitmapData data = bitmap.LockBits(new Rectangle(0, 0, 800, 600), ImageLockMode.WriteOnly, PixelFormat32);
                try { Marshal.Copy(pixels, 0, data.Scan0, pixels.Length); }
                finally { bitmap.UnlockBits(data); }
                bitmap.RotateFlip(RotateFlipType.RotateNoneFlipY);
                bitmap.Save(Path.Combine(output, name), ImageFormat.Png);
            }
        }
        private const System.Drawing.Imaging.PixelFormat PixelFormat32 = System.Drawing.Imaging.PixelFormat.Format32bppRgb;
    }
}
