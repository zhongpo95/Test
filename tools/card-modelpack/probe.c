// 게임을 실행하지 않고 클래식 Storm과 카드 로더의 실제 파일 읽기를 검사한다.
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef BOOL (WINAPI *StormOpenFile)(const char *, HANDLE *);
typedef BOOL (WINAPI *StormReadFile)(HANDLE, void *, DWORD, DWORD *, OVERLAPPED *);
typedef BOOL (WINAPI *StormCloseFile)(HANDLE);
typedef DWORD (*PackStatus)(void);

int main(int argc, char **argv)
{
    HMODULE storm, pack;
    StormOpenFile open_file;
    StormReadFile read_file;
    StormCloseFile close_file;
    PackStatus status;
    HANDLE file;
    unsigned char actual[65536], expected[65536];
    DWORD read_bytes = 0;
    FILE *list;
    char path[512], source_path[1024];
    int checked = 0;
    if (argc != 5) return 10;
    storm = LoadLibraryExA(argv[1], NULL, LOAD_WITH_ALTERED_SEARCH_PATH);
    if (!storm) return 11;
    open_file = (StormOpenFile)GetProcAddress(storm, (LPCSTR)267);
    read_file = (StormReadFile)GetProcAddress(storm, (LPCSTR)269);
    close_file = (StormCloseFile)GetProcAddress(storm, (LPCSTR)253);
    if (!open_file || !read_file || !close_file) return 12;
    pack = LoadLibraryA(argv[2]);
    if (!pack) return 13;
    status = (PackStatus)GetProcAddress(pack, "ArcanaCardPackStatus");
    if (!status || status()) {
        printf("mount status %lu\n", status ? status() : 99);
        return 14;
    }
    list = fopen(argv[3], "r");
    if (!list) return 15;
    while (fgets(path, sizeof(path), list)) {
        char *end = path;
        while (*end && *end != '\r' && *end != '\n') end++;
        *end = 0;
        if (!*path) continue;
        if (!open_file(path, &file)) {
            printf("missing %s (error %lu)\n", path, GetLastError());
            return 16;
        }
        {
            FILE *source;
            size_t size;
            unsigned long total = 0;
            if (strlen(argv[4]) + strlen(path) + 2 > sizeof(source_path)) return 20;
            sprintf(source_path, "%s\\%s", argv[4], path);
            source = fopen(source_path, "rb");
            if (!source) return 21;
            while ((size = fread(expected, 1, sizeof(expected), source)) > 0) {
                if (!read_file(file, actual, size, &read_bytes, NULL)
                    || read_bytes != size || memcmp(actual, expected, size)) {
                    printf("different bytes %s at %lu\n", path, total);
                    return 17;
                }
                if (!total && (actual[2] != 2 || actual[16] != 32)) return 22;
                total += size;
            }
            if (ferror(source)) return 23;
            fclose(source);
            read_file(file, actual, 1, &read_bytes, NULL);
            if (read_bytes) return 24;
        }
        close_file(file);
        checked++;
    }
    fclose(list);
    FreeLibrary(pack);
    // 명시적 해제 후 전역 검색에서 리소스가 사라져야 한다.
    if (open_file("war3mapImported\\UI_Card_FateCalm_caster_Art.tga", &file)) {
        close_file(file);
        return 18;
    }
    FreeLibrary(storm);
    printf("PASS classic Storm mount/read/unmount: %d textures\n", checked);
    return checked == 348 ? 0 : 19;
}
