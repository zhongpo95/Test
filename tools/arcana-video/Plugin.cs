// JN 네이티브 명령과 맵에 포함된 영상 자원을 OpenGL 재생기에 연결한다.
using System;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using Cirnix.JassNative.JassAPI;
using Cirnix.JassNative.Runtime.Plugin;
using Cirnix.JassNative.Runtime.Blizzard.Storm;

namespace Arcana.Video
{
    [Requires(typeof(JassAPIPlugin))]
    public sealed class Plugin : IPlugin
    {
        private VideoPlayer player;
        private OpenGlOverlay overlay;
        private string lastError = "";
        private delegate JassInteger OpenNative(JassStringArg asset);
        private delegate void CloseNative();
        private delegate JassStringRet StatusNative();

        public void Initialize()
        {
            string folder = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
            player = new VideoPlayer(Path.Combine(folder, "ArcanaVideo", "ffmpeg.exe"), Log);
            overlay = new OpenGlOverlay(player, Log);
            Natives.Add(new OpenNative(Open), "JNArcVideoOpen");
            Natives.Add(new CloseNative(Close), "JNArcVideoClose");
            Natives.Add(new StatusNative(Status), "JNArcVideoStatus");
        }

        public void OnGameLoad()
        {
            try { overlay.Install(); }
            catch (Exception e) { lastError = "OpenGL 연결 실패. " + e.Message; Log(lastError); }
        }

        public void OnMapLoad() { Close(); }
        public void OnMapEnd() { Close(); }
        public void OnProgramExit()
        {
            Close();
            if (overlay != null) overlay.Dispose();
        }

        private JassInteger Open(JassStringArg asset)
        {
            string temporary = null;
            try
            {
                if (!overlay.HasRecentContext) throw new InvalidOperationException("OpenGL 모드 화면이 감지되지 않았습니다.");
                string name = asset;
                if (String.IsNullOrEmpty(name) || name.IndexOf("..", StringComparison.Ordinal) >= 0 ||
                    name.IndexOf(':') >= 0 || name.StartsWith("\\", StringComparison.Ordinal) ||
                    name.StartsWith("/", StringComparison.Ordinal) || name.IndexOf('"') >= 0 ||
                    !(name.EndsWith(".mp4", StringComparison.OrdinalIgnoreCase) || name.EndsWith(".webm", StringComparison.OrdinalIgnoreCase)))
                    throw new ArgumentException("맵 내부의 MP4 또는 WebM 경로가 필요합니다.");
                Close();
                temporary = ExtractVideo(name);
                player.Open(temporary, true);
                lastError = "";
                Log("영상 열기. " + name);
                return 1;
            }
            catch (Exception e)
            {
                if (temporary != null)
                {
                    try { File.Delete(temporary); }
                    catch (IOException) { }
                    catch (UnauthorizedAccessException) { }
                }
                lastError = e.Message;
                Log(lastError);
                return 0;
            }
        }

        private void Close() { if (player != null) player.Close(); }
        private JassStringRet Status()
        {
            return "OpenGL=" + (overlay.HasRecentContext ? "감지" : "미감지") +
                " / " + player.Status + (lastError.Length == 0 ? "" : " / " + lastError);
        }

        private static string ExtractVideo(string name)
        {
            IntPtr file;
            if (!SFile.OpenFileEx(IntPtr.Zero, name, 0, out file)) throw new FileNotFoundException("맵 안에서 영상을 찾을 수 없습니다.", name);
            string path = null;
            try
            {
                long size = SFile.GetFileSizeLong(file);
                if (size <= 0 || size > 256L * 1024 * 1024) throw new InvalidDataException("테스트 영상은 256MB 이하여야 합니다.");
                string folder = Path.Combine(Path.GetTempPath(), "ArcanaVideo");
                Directory.CreateDirectory(folder);
                path = Path.Combine(folder, Guid.NewGuid().ToString("N") + Path.GetExtension(name));
                byte[] buffer = new byte[65536];
                using (FileStream output = new FileStream(path, FileMode.CreateNew, FileAccess.Write, FileShare.None))
                {
                    long remaining = size;
                    while (remaining > 0)
                    {
                        int read;
                        int requested = (int)Math.Min(buffer.Length, remaining);
                        if (SFile.ReadFile(file, buffer, requested, out read) == 0 || read != requested)
                            throw new IOException("맵 영상 읽기에 실패했습니다.");
                        output.Write(buffer, 0, read);
                        remaining -= read;
                    }
                }
                return path;
            }
            catch
            {
                if (path != null && File.Exists(path)) File.Delete(path);
                throw;
            }
            finally { SFile.CloseFile(file); }
        }

        private static void Log(string text)
        {
            try
            {
                Trace.WriteLine("[ArcanaVideo] " + text);
                string folder = Path.Combine(Path.GetTempPath(), "ArcanaVideo");
                Directory.CreateDirectory(folder);
                File.AppendAllText(Path.Combine(folder, "player-" + Process.GetCurrentProcess().Id + ".log"),
                    DateTime.Now.ToString("s") + " " + text + Environment.NewLine);
            }
            catch (Exception) { }
        }
    }
}
