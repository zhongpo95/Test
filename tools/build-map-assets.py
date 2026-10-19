# 공통 이미지 목록으로 원본 맵을 보존하며 내장판과 외장판을 만들고 파일 해시를 검증한다.
import argparse
import importlib.util
import ctypes
from ctypes import wintypes as w
import hashlib
import json
from pathlib import Path
import shutil
import struct
import tempfile


def sha(data):
    return hashlib.sha256(data).hexdigest()


class Archive:
    def __init__(self, dll, path):
        self.lib = ctypes.WinDLL(str(dll.resolve()), use_last_error=True)
        signatures = {
            'SFileOpenArchive': [w.LPCWSTR, w.DWORD, w.DWORD, ctypes.POINTER(w.HANDLE)],
            'SFileOpenFileEx': [w.HANDLE, ctypes.c_char_p, w.DWORD, ctypes.POINTER(w.HANDLE)],
            'SFileGetFileSize': [w.HANDLE, ctypes.POINTER(w.DWORD)],
            'SFileReadFile': [w.HANDLE, ctypes.c_void_p, w.DWORD, ctypes.POINTER(w.DWORD), ctypes.c_void_p],
            'SFileCloseFile': [w.HANDLE], 'SFileCloseArchive': [w.HANDLE],
        }
        for name, args in signatures.items():
            fn = getattr(self.lib, name)
            fn.argtypes = args
            fn.restype = w.DWORD if name == 'SFileGetFileSize' else ctypes.c_bool
        self.handle = w.HANDLE()
        self.check(self.lib.SFileOpenArchive(str(path), 0, 0x100, ctypes.byref(self.handle)))

    def check(self, result):
        if not result:
            raise ctypes.WinError(ctypes.get_last_error())

    def read(self, name):
        handle = w.HANDLE()
        self.check(self.lib.SFileOpenFileEx(self.handle, name.encode('utf8'), 0, ctypes.byref(handle)))
        try:
            size = self.lib.SFileGetFileSize(handle, None)
            if size == 0xFFFFFFFF:
                raise ValueError('Invalid member size: ' + name)
            buffer, count = ctypes.create_string_buffer(size), w.DWORD()
            if size:
                self.check(self.lib.SFileReadFile(handle, buffer, size, ctypes.byref(count), None))
            assert count.value == size
            return buffer.raw
        finally:
            self.check(self.lib.SFileCloseFile(handle))

    def names(self):
        return {n.lower(): n for n in self.read('(listfile)').decode('utf8').splitlines() if n}

    def close(self):
        self.check(self.lib.SFileCloseArchive(self.handle))


def import_entries(data):
    version, count = struct.unpack_from('<II', data)
    pos, entries = 8, []
    for _ in range(count):
        flag = data[pos]
        end = data.index(b'\0', pos+1)
        name = data[pos+1:end].decode('utf8')
        # 기본 경로 플래그는 이름 앞에 war3mapImported를 붙인다.
        full = ('war3mapImported\\' + name) if flag in (5, 8) else name
        entries.append((flag, name, full.replace('/', '\\').lower()))
        pos = end+1
    if pos != len(data):
        raise ValueError('Unknown import table trailing data')
    return version, entries


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--map', type=Path, required=True)
    p.add_argument('--assets', type=Path, required=True)
    p.add_argument('--manifest', type=Path, required=True)
    p.add_argument('--stormlib', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--mode', choices=['embedded', 'external'], default='embedded')
    args = p.parse_args()
    args.map, args.output = args.map.resolve(), args.output.resolve()
    if args.output.exists() or args.map == args.output or args.output.suffix.lower() != '.w3x':
        raise ValueError('Use a new .w3x output path')
    manifest = json.loads(args.manifest.read_text(encoding='utf8'))
    rows, keys = [], set()
    for row in manifest['files']:
        name = row['path'].replace('/', '\\')
        parts = name.split('\\')
        if len(parts) != 2 or parts[0] != 'war3mapImported' or not parts[1].lower().endswith('.blp') or ':' in name or '..' in parts:
            raise ValueError('Unsupported managed path: ' + name)
        key = name.lower()
        if key in keys:
            raise ValueError('Duplicate path: ' + name)
        keys.add(key)
        source = args.assets.joinpath(*parts)
        if sha(source.read_bytes()) != row['sha256']:
            raise ValueError('Asset hash mismatch: ' + name)
        rows.append((name, source, row['sha256']))
    spec = importlib.util.spec_from_file_location('writer', Path(__file__).with_name('mpq-v0-writer.py'))
    writer = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(writer)
    original_hash = sha(args.map.read_bytes())
    archive = Archive(args.stormlib, args.map)
    try:
        names = archive.names()
        writer.validate_source(args.map, names.values())
        if '(signature)' in names:
            raise ValueError('Signed map requires a separate signing workflow')
        version, entries = import_entries(archive.read('war3map.imp'))
        preserved = {k: sha(archive.read(n)) for k, n in names.items()
                     if k not in keys and k not in ('(listfile)', '(attributes)', 'war3map.imp')}
        if args.mode == 'external':
            for name, _, digest in rows:
                if name.lower() in names and sha(archive.read(name)) != digest:
                    raise ValueError('Refusing to remove a different asset: ' + name)
    finally:
        archive.close()
    kept = [(flag, name) for flag, name, key in entries if key not in keys]
    if args.mode == 'embedded':
        kept += [(13, name) for name, _, _ in rows]
    imp = struct.pack('<II', version, len(kept)) + b''.join(bytes([flag])+name.encode('utf8')+b'\0' for flag, name in kept)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='.map-assets-', dir=args.output.parent) as scratch:
        candidate = Path(scratch)/'candidate.w3x'
        mpq = Path(scratch)/'resources.mpq'
        original = Archive(args.stormlib, args.map)
        def members():
            output_list = []
            for key in preserved:
                output_list.append(names[key])
                yield names[key], original.read(names[key])
            if args.mode == 'embedded':
                for name, source, _ in rows:
                    output_list.append(name)
                    yield name, source.read_bytes()
            output_list.extend(['war3map.imp', '(listfile)'])
            yield 'war3map.imp', imp
            yield '(listfile)', ('\r\n'.join(output_list)+'\r\n').encode('utf8')
        try:
            writer.write_mpq(mpq, members())
        finally:
            original.close()
        with args.map.open('rb') as source:
            prefix = source.read(512)
            magic = source.read(4)
        if magic != b'MPQ\x1a' or prefix[:4] != b'HM3W':
            raise ValueError('Expected classic Warcraft map with a 512-byte header')
        with candidate.open('wb') as out, mpq.open('rb') as packed:
            out.write(prefix)
            shutil.copyfileobj(packed, out)
        archive = Archive(args.stormlib, candidate)
        try:
            output_names = archive.names()
            expected = set(preserved) | {'war3map.imp', '(listfile)'}
            if args.mode == 'embedded':
                expected |= keys
            assert set(output_names) == expected, 'Unexpected archive members'
            writer.validate_source(candidate, output_names.values())
            for key, digest in preserved.items():
                assert sha(archive.read(names[key])) == digest, names[key]
            for name, _, digest in rows:
                if args.mode == 'embedded':
                    assert sha(archive.read(name)) == digest, name
                else:
                    assert name.lower() not in output_names, name
            assert archive.read('war3map.imp') == imp
        finally:
            archive.close()
        assert sha(args.map.read_bytes()) == original_hash
        candidate.rename(args.output)
    report = dict(mode=args.mode, map=str(args.output), mapBytes=args.output.stat().st_size,
                  mapSha256=sha(args.output.read_bytes()), sourceMapSha256=original_hash,
                  manifestSha256=sha(args.manifest.read_bytes()), managedFiles=len(rows),
                  preservedMembers=len(preserved), sourceUnchanged=True,
                  memberHashesVerified=True, warcraftRuntimeTested=False)
    args.output.with_suffix('.report.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf8')
    print(json.dumps(report, ensure_ascii=False))


if __name__ == '__main__':
    main()

