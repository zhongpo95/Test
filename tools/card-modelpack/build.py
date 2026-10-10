# 선택한 폴더의 모든 파일을 실행 로더와 통합한 ASI로 만들고 원본 바이트를 검증한다.
import argparse
import ctypes
import hashlib
import json
import os
import struct
import tempfile
from ctypes import wintypes as w
from pathlib import Path


def sha(data):
    return hashlib.sha256(data).hexdigest()


def file_sha(path):
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
    return digest.hexdigest()


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


def collect_files(source, prefix=''):
    source = Path(source).resolve()
    if not source.is_dir():
        raise ValueError('입력 폴더를 선택해 주세요.')
    prefix = prefix.replace('/', '\\').strip('\\')
    if prefix and any(part in ('', '.', '..') or ':' in part for part in prefix.split('\\')):
        raise ValueError('임포트 경로 앞부분에는 상대 폴더 이름만 사용할 수 있습니다.')
    rows, names = [], set()

    def scan_error(error):
        raise error

    # 순환 junction과 폴더 밖을 연결하는 링크는 조용히 누락하지 않고 알린다.
    for folder, directories, files in os.walk(source, onerror=scan_error, followlinks=False):
        for name in directories + files:
            path = Path(folder) / name
            if path.lstat().st_file_attributes & 0x400:
                raise ValueError('링크 폴더·파일 대신 실제 파일을 사용해 주세요. ' + str(path))
        for name in files:
            path = Path(folder) / name
            relative = str(path.relative_to(source)).replace('/', '\\')
            archive_name = prefix + '\\' + relative if prefix else relative
            key = archive_name.lower()
            if key in names or key in ('(listfile)', '(attributes)', '(signature)'):
                raise ValueError('MPQ에서 중복되거나 예약된 경로입니다. ' + archive_name)
            names.add(key)
            info = path.stat()
            rows.append({'source': path, 'name': archive_name, 'bytes': info.st_size,
                         'mtime': info.st_mtime_ns})
    if not rows:
        raise ValueError('선택한 폴더에 파일이 없습니다.')
    return sorted(rows, key=lambda row: row['name'].lower())


def verify_members(lib, package, rows, progress):
    archive = w.HANDLE()
    check(lib.SFileOpenArchive(str(package), 0, 0, ctypes.byref(archive)), '완성 ASI 열기')
    try:
        buffer = ctypes.create_string_buffer(1024 * 1024)
        for index, row in enumerate(rows, 1):
            progress('검증', index, len(rows), row['name'])
            file = w.HANDLE()
            check(lib.SFileOpenFileEx(archive, row['name'].encode('utf8'), 0, ctypes.byref(file)), row['name'])
            try:
                digest, remaining = hashlib.sha256(), row['bytes']
                while remaining:
                    size, count = min(remaining, len(buffer)), w.DWORD()
                    check(lib.SFileReadFile(file, buffer, size, ctypes.byref(count), None), row['name'])
                    if count.value != size:
                        raise ValueError('ASI 안의 파일 길이가 다릅니다. ' + row['name'])
                    digest.update(buffer.raw[:size])
                    remaining -= size
                if digest.hexdigest() != row['sha256']:
                    raise ValueError('ASI 안의 파일이 원본과 다릅니다. ' + row['name'])
            finally:
                check(lib.SFileCloseFile(file), '파일 닫기')
    finally:
        check(lib.SFileCloseArchive(archive), '검증 아카이브 닫기')


def build_pack(source, output, loader_path, stormlib_path, prefix='', progress=None):
    source, output = Path(source).resolve(), Path(output).resolve()
    progress = progress or (lambda *args: None)
    if output.suffix.lower() != '.asi':
        raise ValueError('출력 파일 확장자는 .asi여야 합니다.')
    if output == source or source in output.parents:
        raise ValueError('출력 파일은 입력 폴더 밖에 저장해 주세요.')
    if output.exists():
        raise ValueError('기존 파일을 보존합니다. 새 출력 파일 이름을 지정해 주세요.')
    rows = collect_files(source, prefix)
    loader = Path(loader_path).read_bytes()
    if len(loader) < 64 or loader[:2] != b'MZ':
        raise ValueError('실행 로더가 올바른 PE DLL이 아닙니다.')
    pe = struct.unpack_from('<I', loader, 60)[0]
    if pe + 24 > len(loader) or loader[pe:pe + 4] != b'PE\0\0':
        raise ValueError('실행 로더의 PE 헤더가 올바르지 않습니다.')
    if struct.unpack_from('<H', loader, pe + 4)[0] != 0x14c or not struct.unpack_from('<H', loader, pe + 22)[0] & 0x2000:
        raise ValueError('실행 로더는 클래식 워크래프트용 x86 DLL이어야 합니다.')
    lib = bind(Path(stormlib_path).resolve())
    output.parent.mkdir(parents=True, exist_ok=True)
    # 임시 파일은 출력 폴더 아래 새 전용 디렉터리에만 만들고 정리한다.
    with tempfile.TemporaryDirectory(prefix='.arcana-pack-', dir=output.parent) as scratch:
        mpq, combined = Path(scratch) / 'resources.mpq', Path(scratch) / 'combined.asi'
        archive = w.HANDLE()
        check(lib.SFileCreateArchive(str(mpq), 0x00100000, max(1024, len(rows) * 2), ctypes.byref(archive)), 'MPQ 생성')
        try:
            for index, row in enumerate(rows, 1):
                progress('압축', index, len(rows), row['name'])
                row['sha256'] = file_sha(row['source'])
                check(lib.SFileAddFileEx(archive, str(row['source']), row['name'].encode('utf8'),
                                        0x00000200, 0x02, 0x02), row['name'])
                info = row['source'].stat()
                if (info.st_size, info.st_mtime_ns) != (row['bytes'], row['mtime']):
                    raise ValueError('작업 중 원본이 변경됐습니다. ' + row['name'])
        finally:
            check(lib.SFileCloseArchive(archive), 'MPQ 닫기')
        with mpq.open('rb') as stream:
            header = stream.read(32)
        if header[:4] != b'MPQ\x1a' or struct.unpack_from('<H', header, 12)[0] != 0:
            raise ValueError('클래식 MPQ v0 형식이 아닙니다.')
        if struct.unpack_from('<I', header, 28)[0] != len(rows) + 1:
            raise ValueError('원본 파일과 MPQ 목록 이외의 항목이 있습니다.')
        offset = (len(loader) + 511) // 512 * 512
        with combined.open('wb') as target, mpq.open('rb') as stream:
            target.write(loader)
            target.write(b'\0' * (offset - len(loader)))
            for block in iter(lambda: stream.read(1024 * 1024), b''):
                target.write(block)
        verify_members(lib, combined, rows, progress)
        report = {'asiFile': output.name, 'files': len(rows), 'sourceBytes': sum(row['bytes'] for row in rows),
                  'asiBytes': combined.stat().st_size, 'asiSha256': file_sha(combined),
                  'loaderBytes': len(loader), 'loaderSha256': sha(loader), 'mpqOffset': offset,
                  'mpqSha256': file_sha(mpq), 'archiveVersion': 0, 'compression': 'lossless zlib',
                  'allMemberHashesVerified': True, 'standaloneLoaderRequired': False,
                  'mapCreated': False, 'installed': False, 'warcraftRuntimeTested': False}
        # Windows의 rename은 이미 존재하는 목적지를 덮어쓰지 않는다.
        os.rename(combined, output)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='폴더 전체를 로더 통합 ASI로 묶습니다.')
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--loader', type=Path, required=True)
    parser.add_argument('--stormlib', type=Path, required=True)
    parser.add_argument('--prefix', default='')
    args = parser.parse_args()
    print(json.dumps(build_pack(args.source, args.output, args.loader, args.stormlib, args.prefix), ensure_ascii=False))
