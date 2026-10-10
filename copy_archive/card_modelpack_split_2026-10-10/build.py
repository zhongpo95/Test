# 검토된 카드 TGA만 담은 Arcana_A.asi와 별도 실행 로더를 만들고 검증한다.
import argparse
import ctypes
import hashlib
import json
import shutil
import struct
from ctypes import wintypes as w
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def sha(data):
    return hashlib.sha256(data).hexdigest()


def bind(dll):
    lib = ctypes.WinDLL(str(dll), use_last_error=True)
    signatures = {
        'SFileCreateArchive': [w.LPCWSTR, w.DWORD, w.DWORD, ctypes.POINTER(w.HANDLE)],
        'SFileAddFileEx': [w.HANDLE, w.LPCWSTR, ctypes.c_char_p, w.DWORD, w.DWORD, w.DWORD],
        'SFileOpenArchive': [w.LPCWSTR, w.DWORD, w.DWORD, ctypes.POINTER(w.HANDLE)],
        'SFileOpenFileEx': [w.HANDLE, ctypes.c_char_p, w.DWORD, ctypes.POINTER(w.HANDLE)],
        'SFileReadFile': [w.HANDLE, ctypes.c_void_p, w.DWORD, ctypes.POINTER(w.DWORD), ctypes.c_void_p],
        'SFileCloseFile': [w.HANDLE],
        'SFileCloseArchive': [w.HANDLE],
    }
    for name, args in signatures.items():
        func = getattr(lib, name)
        func.argtypes, func.restype = args, ctypes.c_bool
    return lib


def check(ok, operation):
    if not ok:
        raise OSError(ctypes.get_last_error(), operation)


def read(lib, archive, path, size):
    file = w.HANDLE()
    check(lib.SFileOpenFileEx(archive, path.encode('ascii'), 0, ctypes.byref(file)), path)
    try:
        buf = ctypes.create_string_buffer(size)
        count = w.DWORD()
        check(lib.SFileReadFile(file, buf, size, ctypes.byref(count), None), path)
        if count.value != size:
            raise ValueError('MPQ 파일 길이 불일치 ' + path)
        return buf.raw
    finally:
        check(lib.SFileCloseFile(file), '파일 닫기')


def build(args):
    source, out = args.source.resolve(), args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    manifest = json.loads((source / 'texture-manifest.json').read_text(encoding='utf8'))
    assets = manifest['assets']
    if len(assets) != 348 or len({a['file'].lower() for a in assets}) != 348:
        raise ValueError('현재 검토본은 카드 TGA 348개여야 합니다.')
    for row in assets:
        path = Path(row['file'].replace('\\', '/'))
        if path.parts != ('war3mapImported', path.name) or path.suffix != '.tga':
            raise ValueError('예상 밖의 임포트 경로 ' + row['file'])
        if sha((source / path).read_bytes()) != row['sha256']:
            raise ValueError('검토 원본 해시 불일치 ' + row['file'])
    loader = args.loader.read_bytes()
    pe = struct.unpack_from('<I', loader, 60)[0]
    if loader[:2] != b'MZ' or loader[pe:pe + 4] != b'PE\0\0':
        raise ValueError('로더는 컴파일된 PE DLL이어야 합니다.')
    if struct.unpack_from('<H', loader, pe + 4)[0] != 0x14c:
        raise ValueError('로더는 클래식 워크래프트용 x86 DLL이어야 합니다.')
    if not struct.unpack_from('<H', loader, pe + 22)[0] & 0x2000:
        raise ValueError('로더의 DLL 플래그가 없습니다.')
    asi, loader_file = out / 'Arcana_A.asi', out / 'Arcana_Loader.asi'
    if asi.exists() or loader_file.exists():
        raise ValueError('기존 모델팩을 보존하기 위해 새 출력 위치를 지정해야 합니다.')
    lib = bind(args.stormlib.resolve())
    archive = w.HANDLE()
    # MPQ v0, 목록 파일 포함. 4KB 섹터 zlib 압축은 원본 바이트를 보존한다.
    check(lib.SFileCreateArchive(str(asi), 0x00100000, 1024, ctypes.byref(archive)), 'MPQ 생성')
    try:
        for row in assets:
            path = row['file'].replace('/', '\\')
            check(lib.SFileAddFileEx(archive, str(source / row['file']), path.encode('ascii'),
                                    0x00000200, 0x02, 0x02), path)
    finally:
        check(lib.SFileCloseArchive(archive), 'MPQ 닫기')
    mpq_bytes = asi.read_bytes()
    if mpq_bytes[:4] != b'MPQ\x1a' or struct.unpack_from('<H', mpq_bytes, 12)[0] != 0:
        raise ValueError('클래식 MPQ v0 형식이 아닙니다.')
    # 이미지 팩은 MPQ 헤더부터 시작한다. 실행 코드는 별도 파일에만 둔다.
    block_count = struct.unpack_from('<I', mpq_bytes, 28)[0]
    if block_count != len(assets) + 1:
        raise ValueError('이미지와 MPQ 목록 이외의 항목이 있습니다.')
    loader_file.write_bytes(loader)
    for package in [asi]:
        archive = w.HANDLE()
        check(lib.SFileOpenArchive(str(package), 0, 0, ctypes.byref(archive)), str(package))
        try:
            for row in assets:
                data = read(lib, archive, row['file'].replace('/', '\\'), row['bytes'])
                if sha(data) != row['sha256']:
                    raise ValueError('모델팩에서 읽은 바이트 불일치 ' + row['file'])
        finally:
            check(lib.SFileCloseArchive(archive), '검증 아카이브 닫기')
    paths = '\n'.join(a['file'].replace('/', '\\') for a in assets) + '\n'
    (out / 'map-imports-to-remove.txt').write_text(paths, encoding='ascii')
    shutil.copy2(source / 'texture-manifest.json', out / 'texture-manifest.json')
    shutil.copy2(source / 'card-index.json', out / 'card-index.json')
    shutil.copy2(ROOT / 'Data/Data_PrototypeCardImages.j', out / 'Data_PrototypeCardImages.j')
    shutil.copy2(ROOT / 'System/CardModelPack.j', out / 'CardModelPack.j')
    shutil.copy2(Path(__file__).parent / 'loader.c', out / 'loader.c')
    report = {'asiFile': asi.name, 'textureFiles': len(assets), 'sourceBytes': sum(a['bytes'] for a in assets),
              'mpqBytes': asi.stat().st_size, 'asiBytes': asi.stat().st_size,
              'mpqSha256': sha(mpq_bytes), 'asiSha256': sha(asi.read_bytes()),
              'loaderFile': loader_file.name, 'loaderBytes': len(loader),
              'loaderSha256': sha(loader), 'loaderSourceSha256': sha((out / 'loader.c').read_bytes()),
              'stormlibSha256': sha(args.stormlib.read_bytes()), 'mpqOffset': 0,
              'imageOnly': True, 'embeddedExecutable': False,
              'archiveEntries': block_count, 'internalMetadataEntries': ['(listfile)'],
              'archiveVersion': 0, 'compression': 'zlib, 4KB sectors, lossless',
              'allMemberHashesVerified': True, 'pathsUnchanged': True,
              'mapCreated': False, 'installed': False, 'warcraftRuntimeTested': False}
    (out / 'modelpack-report.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n', encoding='utf8')
    print(json.dumps(report, ensure_ascii=False))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--loader', type=Path, required=True)
    parser.add_argument('--stormlib', type=Path, required=True)
    build(parser.parse_args())
