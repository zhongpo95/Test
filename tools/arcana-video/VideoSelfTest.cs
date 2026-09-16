// 워크래프트를 실행하지 않고 별도 OpenGL 컨텍스트에서 영상과 상태 복원을 검증한다.
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Runtime.InteropServices;
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
        private static string output;
        private static readonly List<string> results = new List<string>();

        [STAThread]
        private static int Main(string[] args)
        {
            try
            {
                if (args.Length != 3) throw new ArgumentException("decoder.exe clip.mp4 output-folder");
                output = args[2];
                Directory.CreateDirectory(output);
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
                    if (changedFrames == 5) SaveFrame(pixels);
                }
                previousHash = hash;
            }
            catch (Exception e) { callbackError = e; }
        }

        private static void SaveFrame(byte[] pixels)
        {
            using (Bitmap bitmap = new Bitmap(800, 600, PixelFormat32))
            {
                BitmapData data = bitmap.LockBits(new Rectangle(0, 0, 800, 600), ImageLockMode.WriteOnly, PixelFormat32);
                try { Marshal.Copy(pixels, 0, data.Scan0, pixels.Length); }
                finally { bitmap.UnlockBits(data); }
                bitmap.RotateFlip(RotateFlipType.RotateNoneFlipY);
                bitmap.Save(Path.Combine(output, "opengl-video.png"), ImageFormat.Png);
            }
        }
        private const System.Drawing.Imaging.PixelFormat PixelFormat32 = System.Drawing.Imaging.PixelFormat.Format32bppRgb;
    }
}
