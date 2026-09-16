// OpenGL 화면 교체 직전에 영상을 그리고 게임의 그래픽 상태를 복원한다.
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Threading;
using EasyHook;

namespace Arcana.Video
{
    public sealed class OpenGlOverlay : IDisposable
    {
        [UnmanagedFunctionPointer(CallingConvention.StdCall)]
        private delegate bool SwapDelegate(IntPtr dc);
        [UnmanagedFunctionPointer(CallingConvention.StdCall)]
        private delegate bool SwapLayersDelegate(IntPtr dc, uint planes);
        [UnmanagedFunctionPointer(CallingConvention.StdCall)]
        private delegate void SelectTexture(uint texture);
        [UnmanagedFunctionPointer(CallingConvention.StdCall)]
        private delegate void UseProgram(uint program);
        [UnmanagedFunctionPointer(CallingConvention.StdCall)]
        private delegate void BindObject(uint target, uint name);

        private readonly VideoPlayer player;
        private readonly Action<string> log;
        private readonly List<LocalHook> hooks = new List<LocalHook>();
        private readonly List<Delegate> callbacks = new List<Delegate>();
        private readonly byte[] pixels = new byte[VideoPlayer.FrameBytes];
        private readonly int processId = Process.GetCurrentProcess().Id;
        private IntPtr textureContext;
        private uint texture;
        private DecodeSession renderedSession;
        private int renderedFrame;
        private long lastContext;
        private SelectTexture activeTexture;
        private UseProgram useProgram;
        private BindObject bindBuffer, bindFramebuffer;
        private int textureUnits = 1;
        private bool unpackBufferSupported, separateFramebufferTargets;
#if VIDEO_SELF_TEST
        internal Action BeforeSwap;
#endif
        [ThreadStatic] private static bool insideSwap;

        public OpenGlOverlay(VideoPlayer source, Action<string> logger)
        {
            player = source;
            log = logger;
        }

        public bool HasRecentContext
        {
            get
            {
                long last = Interlocked.Read(ref lastContext);
                return last != 0 && Stopwatch.GetTimestamp() - last < Stopwatch.Frequency * 3;
            }
        }

        public void Install()
        {
            if (hooks.Count != 0) return;
            InstallLayers();
            InstallSwap("gdi32.dll", "SwapBuffers");
            // 일부 드라이버/호스트는 OpenGL 내보내기를 직접 호출한다.
            try { InstallSwap("opengl32.dll", "wglSwapBuffers"); }
            catch (MissingMethodException) { }
            catch (EntryPointNotFoundException) { }
            log("OpenGL wglSwapLayerBuffers / SwapBuffers 연결 완료");
        }

        private void InstallLayers()
        {
            IntPtr address = LocalHook.GetProcAddress("opengl32.dll", "wglSwapLayerBuffers");
            SwapLayersDelegate original = null;
            SwapLayersDelegate callback = delegate(IntPtr dc, uint planes)
            {
                if (insideSwap || (planes & 1) == 0) return original(dc, planes);
                insideSwap = true;
                try
                {
                    RenderBeforeSwap(dc);
                    return original(dc, planes);
                }
                finally { insideSwap = false; }
            };
            LocalHook hook = LocalHook.Create(address, callback, null);
            original = (SwapLayersDelegate)Marshal.GetDelegateForFunctionPointer(hook.HookBypassAddress, typeof(SwapLayersDelegate));
            callbacks.Add(callback);
            hooks.Add(hook);
            hook.ThreadACL.SetExclusiveACL(new int[0]);
        }

        private void RenderBeforeSwap(IntPtr dc)
        {
            try
            {
                Draw(dc);
#if VIDEO_SELF_TEST
                if (BeforeSwap != null) BeforeSwap();
#endif
            }
            catch (Exception e)
            {
                player.Close();
                log("영상 그리기 중단. " + e.Message);
            }
        }

        private void InstallSwap(string library, string name)
        {
            IntPtr address = LocalHook.GetProcAddress(library, name);
            if (address == IntPtr.Zero) throw new EntryPointNotFoundException(name);
            LocalHook hook = null;
            SwapDelegate original = null;
            SwapDelegate callback = delegate(IntPtr dc)
            {
                if (insideSwap) return original(dc);
                insideSwap = true;
                try
                {
                    RenderBeforeSwap(dc);
                    return original(dc);
                }
                finally { insideSwap = false; }
            };
            hook = LocalHook.Create(address, callback, null);
            original = (SwapDelegate)Marshal.GetDelegateForFunctionPointer(hook.HookBypassAddress, typeof(SwapDelegate));
            callbacks.Add(callback);
            hooks.Add(hook);
            hook.ThreadACL.SetExclusiveACL(new int[0]);
        }

        private static T Extension<T>(string name) where T : class
        {
            IntPtr pointer = GL.wglGetProcAddress(name);
            long value = pointer.ToInt64();
            if (value == 0 || value == 1 || value == 2 || value == 3 || value == -1) return null;
            return (T)(object)Marshal.GetDelegateForFunctionPointer(pointer, typeof(T));
        }

        private void SetContext(IntPtr context)
        {
            if (textureContext == context) return;
            // 다른 컨텍스트의 텍스처 번호를 현재 컨텍스트에서 삭제하지 않는다.
            textureContext = context;
            texture = 0;
            renderedFrame = 0;
            renderedSession = null;
            activeTexture = Extension<SelectTexture>("glActiveTexture");
            useProgram = Extension<UseProgram>("glUseProgram");
            bindBuffer = Extension<BindObject>("glBindBuffer");
            bindFramebuffer = Extension<BindObject>("glBindFramebuffer");
            string version = Marshal.PtrToStringAnsi(GL.glGetString(0x1F02));
            Version parsed;
            string number = (version ?? "1.1").Split(' ')[0];
            unpackBufferSupported = Version.TryParse(number, out parsed) && parsed >= new Version(2, 1);
            separateFramebufferTargets = parsed != null && parsed.Major >= 3;
            textureUnits = activeTexture == null ? 1 : Math.Min(32, Math.Max(1, GL.Integer(0x84E2)));
            log("OpenGL 컨텍스트. " + version);
        }

        private void Draw(IntPtr dc)
        {
            IntPtr context = GL.wglGetCurrentContext();
            if (context == IntPtr.Zero) return;
            IntPtr window = GL.WindowFromDC(dc);
            uint owner;
            GL.GetWindowThreadProcessId(window, out owner);
            GL.Rect client;
            if (window == IntPtr.Zero || owner != processId || !GL.GetClientRect(window, out client)) return;
            int width = client.Right - client.Left, height = client.Bottom - client.Top;
            if (width < 320 || height < 240) return;
            Interlocked.Exchange(ref lastContext, Stopwatch.GetTimestamp());
            SetContext(context);
            DecodeSession current = player.Session;
            if (current != null && current.Finished)
            {
                player.Finish(current);
                current = null;
            }
            if (current == null)
            {
                if (texture != 0) { GL.glDeleteTextures(1, ref texture); texture = 0; }
                renderedSession = null;
                renderedFrame = 0;
                return;
            }
            if (renderedSession != current) { renderedSession = current; renderedFrame = 0; }
            int number;
            bool upload = current.CopyFrame(pixels, renderedFrame, out number);
            if (number == 0) return;

            // 스택이 가득 찬 호스트에서는 기존 상태를 손상시키지 않고 이번 프레임을 건너뛴다.
            if (GL.Integer(0x0BB0) >= GL.Integer(0x0D35) || GL.Integer(0x0BB1) >= GL.Integer(0x0D3B) ||
                GL.Integer(0x0BA3) >= GL.Integer(0x0D36) || GL.Integer(0x0BA4) >= GL.Integer(0x0D38) ||
                GL.Integer(0x0BA5) >= GL.Integer(0x0D39)) return;
            int mode = GL.Integer(0x0BA0);
            int savedActive = activeTexture == null ? 0 : GL.Integer(0x84E0);
            int savedProgram = useProgram == null ? 0 : GL.Integer(0x8B8D);
            int savedUnpack = bindBuffer == null || !unpackBufferSupported ? 0 : GL.Integer(0x88EF);
            int savedFramebuffer = bindFramebuffer == null ? 0 : GL.Integer(0x8CA6);
            int savedReadFramebuffer = bindFramebuffer == null || !separateFramebufferTargets ? savedFramebuffer : GL.Integer(0x8CAA);
            GL.glPushAttrib(0x000FFFFF);
            GL.glPushClientAttrib(0x00000001);
            bool matrices = false;
            try
            {
                if (useProgram != null) useProgram(0);
                if (bindBuffer != null && unpackBufferSupported) bindBuffer(0x88EC, 0);
                if (bindFramebuffer != null) bindFramebuffer(0x8D40, 0);
                for (int unit = textureUnits - 1; unit >= 0; unit--)
                {
                    if (activeTexture != null) activeTexture((uint)(0x84C0 + unit));
                    GL.glDisable(0x0DE0);
                    GL.glDisable(0x0DE1);
                    if (activeTexture != null) { GL.glDisable(0x806F); GL.glDisable(0x8513); }
                    for (uint coordinate = 0x0C60; coordinate <= 0x0C63; coordinate++) GL.glDisable(coordinate);
                }
                GL.glMatrixMode(0x1702); GL.glPushMatrix(); GL.glLoadIdentity();
                GL.glMatrixMode(0x1701); GL.glPushMatrix(); GL.glLoadIdentity();
                GL.glOrtho(0, width, height, 0, -1, 1);
                GL.glMatrixMode(0x1700); GL.glPushMatrix(); GL.glLoadIdentity();
                matrices = true;
                GL.glViewport(0, 0, width, height);
                GL.glDrawBuffer(0x0405);
                foreach (uint state in new uint[] { 0x0B71, 0x0C11, 0x0B50, 0x0BC0, 0x0B44, 0x0B60, 0x0B90, 0x0BE2, 0x0BF2 })
                    GL.glDisable(state);
                for (uint plane = 0x3000; plane <= 0x3005; plane++) GL.glDisable(plane);
                GL.glColorMask(true, true, true, true);
                GL.glDepthMask(false);
                GL.glPolygonMode(0x0408, 0x1B02);
                GL.glPixelStorei(0x0CF5, 1);
                GL.glPixelStorei(0x0CF2, 0);
                GL.glPixelStorei(0x0CF3, 0);
                GL.glPixelStorei(0x0CF4, 0);
                if (texture == 0)
                {
                    GL.glGenTextures(1, out texture);
                    GL.glBindTexture(0x0DE1, texture);
                    GL.glTexParameteri(0x0DE1, 0x2801, 0x2601);
                    GL.glTexParameteri(0x0DE1, 0x2800, 0x2601);
                    GL.glTexParameteri(0x0DE1, 0x2802, 0x812F);
                    GL.glTexParameteri(0x0DE1, 0x2803, 0x812F);
                    GL.glTexImage2D(0x0DE1, 0, 0x1908, 1024, 512, 0, 0x80E1, 0x1401, IntPtr.Zero);
                    upload = true;
                }
                GL.glBindTexture(0x0DE1, texture);
                if (upload)
                {
                    GCHandle pinned = GCHandle.Alloc(pixels, GCHandleType.Pinned);
                    try { GL.glTexSubImage2D(0x0DE1, 0, 0, 0, VideoPlayer.Width, VideoPlayer.Height, 0x80E1, 0x1401, pinned.AddrOfPinnedObject()); }
                    finally { pinned.Free(); }
                    renderedFrame = number;
                }
                float w = Math.Min(width * 0.70f, height * 0.60f * 16 / 9);
                float h = w * 9 / 16, left = (width - w) / 2, top = (height - h) / 2;
                GL.glColor4f(0, 0, 0, 1);
                Quad(left - 3, top - 3, w + 6, h + 6, false);
                GL.glEnable(0x0DE1);
                GL.glTexEnvi(0x2300, 0x2200, 0x1E01);
                GL.glColor4f(1, 1, 1, 1);
                Quad(left, top, w, h, true);
            }
            finally
            {
                if (matrices)
                {
                    GL.glMatrixMode(0x1700); GL.glPopMatrix();
                    GL.glMatrixMode(0x1701); GL.glPopMatrix();
                    GL.glMatrixMode(0x1702); GL.glPopMatrix();
                }
                if (bindFramebuffer != null)
                {
                    if (separateFramebufferTargets)
                    {
                        bindFramebuffer(0x8CA9, (uint)savedFramebuffer);
                        bindFramebuffer(0x8CA8, (uint)savedReadFramebuffer);
                    }
                    else bindFramebuffer(0x8D40, (uint)savedFramebuffer);
                }
                GL.glPopClientAttrib();
                GL.glPopAttrib();
                if (bindBuffer != null && unpackBufferSupported) bindBuffer(0x88EC, (uint)savedUnpack);
                if (useProgram != null) useProgram((uint)savedProgram);
                if (activeTexture != null) activeTexture((uint)savedActive);
                GL.glMatrixMode((uint)mode);
            }
        }

        private static void Quad(float x, float y, float width, float height, bool textured)
        {
            float u0 = .5f / 1024, v0 = .5f / 512;
            float u1 = (VideoPlayer.Width - .5f) / 1024, v1 = (VideoPlayer.Height - .5f) / 512;
            GL.glBegin(0x0007);
            if (textured) GL.glTexCoord2f(u0, v0); GL.glVertex2f(x, y);
            if (textured) GL.glTexCoord2f(u1, v0); GL.glVertex2f(x + width, y);
            if (textured) GL.glTexCoord2f(u1, v1); GL.glVertex2f(x + width, y + height);
            if (textured) GL.glTexCoord2f(u0, v1); GL.glVertex2f(x, y + height);
            GL.glEnd();
        }

        public void Dispose()
        {
            player.Close();
            foreach (LocalHook hook in hooks) hook.Dispose();
            hooks.Clear();
            // 콜백 델리게이트는 네이티브 후크 제거가 완료될 때까지 이 객체가 보관한다.
        }
    }

    internal static class GL
    {
        [StructLayout(LayoutKind.Sequential)] internal struct Rect { public int Left, Top, Right, Bottom; }
        [DllImport("user32.dll")] internal static extern IntPtr WindowFromDC(IntPtr dc);
        [DllImport("user32.dll")] internal static extern uint GetWindowThreadProcessId(IntPtr window, out uint id);
        [DllImport("user32.dll")] internal static extern bool GetClientRect(IntPtr window, out Rect rect);
        [DllImport("opengl32.dll")] internal static extern IntPtr wglGetCurrentContext();
        [DllImport("opengl32.dll", CharSet = CharSet.Ansi)] internal static extern IntPtr wglGetProcAddress(string name);
        [DllImport("opengl32.dll")] internal static extern IntPtr glGetString(uint name);
        [DllImport("opengl32.dll")] internal static extern void glGetIntegerv(uint name, int[] value);
        internal static int Integer(uint name) { int[] value = new int[4]; glGetIntegerv(name, value); return value[0]; }
        [DllImport("opengl32.dll")] internal static extern void glPushAttrib(uint mask);
        [DllImport("opengl32.dll")] internal static extern void glPopAttrib();
        [DllImport("opengl32.dll")] internal static extern void glPushClientAttrib(uint mask);
        [DllImport("opengl32.dll")] internal static extern void glPopClientAttrib();
        [DllImport("opengl32.dll")] internal static extern void glMatrixMode(uint mode);
        [DllImport("opengl32.dll")] internal static extern void glPushMatrix();
        [DllImport("opengl32.dll")] internal static extern void glPopMatrix();
        [DllImport("opengl32.dll")] internal static extern void glLoadIdentity();
        [DllImport("opengl32.dll")] internal static extern void glOrtho(double left, double right, double bottom, double top, double near, double far);
        [DllImport("opengl32.dll")] internal static extern void glViewport(int x, int y, int width, int height);
        [DllImport("opengl32.dll")] internal static extern void glDrawBuffer(uint buffer);
        [DllImport("opengl32.dll")] internal static extern void glDisable(uint state);
        [DllImport("opengl32.dll")] internal static extern void glEnable(uint state);
        [DllImport("opengl32.dll")] internal static extern void glColorMask([MarshalAs(UnmanagedType.I1)] bool r, [MarshalAs(UnmanagedType.I1)] bool g, [MarshalAs(UnmanagedType.I1)] bool b, [MarshalAs(UnmanagedType.I1)] bool a);
        [DllImport("opengl32.dll")] internal static extern void glDepthMask([MarshalAs(UnmanagedType.I1)] bool enabled);
        [DllImport("opengl32.dll")] internal static extern void glPolygonMode(uint face, uint mode);
        [DllImport("opengl32.dll")] internal static extern void glPixelStorei(uint key, int value);
        [DllImport("opengl32.dll")] internal static extern void glGenTextures(int count, out uint texture);
        [DllImport("opengl32.dll")] internal static extern void glDeleteTextures(int count, ref uint texture);
        [DllImport("opengl32.dll")] internal static extern void glBindTexture(uint target, uint texture);
        [DllImport("opengl32.dll")] internal static extern void glTexParameteri(uint target, uint name, int value);
        [DllImport("opengl32.dll")] internal static extern void glTexImage2D(uint target, int level, int internalFormat, int width, int height, int border, uint format, uint type, IntPtr pixels);
        [DllImport("opengl32.dll")] internal static extern void glTexSubImage2D(uint target, int level, int x, int y, int width, int height, uint format, uint type, IntPtr pixels);
        [DllImport("opengl32.dll")] internal static extern void glTexEnvi(uint target, uint name, int value);
        [DllImport("opengl32.dll")] internal static extern void glColor4f(float r, float g, float b, float a);
        [DllImport("opengl32.dll")] internal static extern void glBegin(uint mode);
        [DllImport("opengl32.dll")] internal static extern void glEnd();
        [DllImport("opengl32.dll")] internal static extern void glTexCoord2f(float u, float v);
        [DllImport("opengl32.dll")] internal static extern void glVertex2f(float x, float y);
    }
}
