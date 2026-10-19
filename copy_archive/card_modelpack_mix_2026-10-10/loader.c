// 클래식 워크래프트의 Storm에 이 파일 뒤의 카드 MPQ를 읽기 전용으로 연결한다.
#include <windows.h>

typedef BOOL (WINAPI *OpenArchive)(const char *, DWORD, DWORD, HANDLE *);
typedef BOOL (WINAPI *CloseArchive)(HANDLE);

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
        if (!storm) {
            pack_status = 1;
            return TRUE;
        }
        open_archive = (OpenArchive)GetProcAddress(storm, (LPCSTR)266);
        close_archive = (CloseArchive)GetProcAddress(storm, (LPCSTR)252);
        if (!open_archive || !close_archive) {
            pack_status = 2;
            return TRUE;
        }
        length = GetModuleFileNameA(module, filename, sizeof(filename));
        if (!length || length >= sizeof(filename)) {
            pack_status = 3;
            return TRUE;
        }
        if (!open_archive(filename, 16, 0, &card_archive)) {
            pack_status = 4;
            return TRUE;
        }
        pack_status = 0;
    } else if (reason == DLL_PROCESS_DETACH && !reserved && card_archive) {
        // 명시적 해제 때만 닫는다. 프로세스 종료 때는 Storm의 해제 순서에 의존하지 않는다.
        close_archive(card_archive);
        card_archive = NULL;
    }
    return TRUE;
}
