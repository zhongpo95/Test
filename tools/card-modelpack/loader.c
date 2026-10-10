// 단일 ASI 안에 통합한 리소스 MPQ를 클래식 워크래프트 Storm에 연결한다.
#include <windows.h>

typedef BOOL (WINAPI *OpenArchive)(const char *, DWORD, DWORD, HANDLE *);
typedef BOOL (WINAPI *CloseArchive)(HANDLE);
typedef BOOL (WINAPI *StormOpenFile)(HANDLE, const char *, DWORD, HANDLE *);
typedef BOOL (WINAPI *StormReadFile)(HANDLE, void *, DWORD, DWORD *, OVERLAPPED *);
typedef BOOL (WINAPI *StormCloseFile)(HANDLE);

static HANDLE card_archive;
static CloseArchive close_archive;
static DWORD pack_status;

__declspec(dllexport) DWORD ArcanaCardPackStatus(void)
{
    return pack_status;
}

BOOL WINAPI DllMain(HINSTANCE module, DWORD reason, LPVOID reserved)
{
    if (reason == DLL_PROCESS_ATTACH) {
        char filename[MAX_PATH];
        DWORD length;
        HMODULE storm = GetModuleHandleA("Storm.dll");
        OpenArchive open_archive;
        StormOpenFile open_file;
        StormReadFile read_file;
        StormCloseFile close_file;
        if (!storm) {
            pack_status = 1;
            return FALSE;
        }
        open_archive = (OpenArchive)GetProcAddress(storm, (LPCSTR)266);
        close_archive = (CloseArchive)GetProcAddress(storm, (LPCSTR)252);
        open_file = (StormOpenFile)GetProcAddress(storm, (LPCSTR)268);
        read_file = (StormReadFile)GetProcAddress(storm, (LPCSTR)269);
        close_file = (StormCloseFile)GetProcAddress(storm, (LPCSTR)253);
        if (!open_archive || !close_archive || !open_file || !read_file || !close_file) {
            pack_status = 2;
            return FALSE;
        }
        length = GetModuleFileNameA(module, filename, sizeof(filename));
        if (!length || length >= sizeof(filename)) {
            pack_status = 3;
            return FALSE;
        }
        // 현재 실행 중인 ASI 파일 뒤의 MPQ를 열어 별도 로더 파일 없이 사용한다.
        if (!open_archive(filename, 16, 0, &card_archive)) {
            pack_status = 4;
            return FALSE;
        }
        // 특정 이미지에 의존하지 않고 실제 MPQ 목록을 읽을 수 있는지 확인한다.
        {
            HANDLE file;
            unsigned char header[1];
            DWORD count = 0;
            BOOL valid = FALSE;
            if (open_file(card_archive, "(listfile)", 0, &file)) {
                valid = read_file(file, header, sizeof(header), &count, NULL)
                    && count == sizeof(header);
                close_file(file);
            }
            if (!valid) {
                close_archive(card_archive);
                card_archive = NULL;
                pack_status = 5;
                return FALSE;
            }
        }
        pack_status = 0;
    } else if (reason == DLL_PROCESS_DETACH && !reserved && card_archive) {
        // 명시적 해제 때만 닫는다. 프로세스 종료 때는 Storm의 해제 순서에 의존하지 않는다.
        close_archive(card_archive);
        card_archive = NULL;
    }
    return TRUE;
}
