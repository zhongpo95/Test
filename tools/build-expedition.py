# 원본 맵의 배치와 트리거 진입부를 보존하여 별도 원정 시험 맵을 만든다.
import argparse
import ctypes as c
import hashlib
import json
import re
import shutil
import struct
import subprocess
from pathlib import Path


class Archive:
    def __init__(self, dll, path, write=False):
        self.dll = dll
        self.handle = c.c_void_p()
        if not dll.SFileOpenArchive(str(path), 0, 0 if write else 0x100, c.byref(self.handle)):
            raise OSError('Cannot open MPQ: ' + str(path))

    def read(self, name):
        handle = c.c_void_p()
        if not self.dll.SFileOpenFileEx(self.handle, name.encode('utf8'), 0, c.byref(handle)):
            raise OSError('Missing MPQ member: ' + name)
        try:
            size = self.dll.SFileGetFileSize(handle, None)
            buffer = c.create_string_buffer(size)
            read = c.c_uint32()
            if not self.dll.SFileReadFile(handle, buffer, size, c.byref(read), None) or read.value != size:
                raise OSError('Cannot read MPQ member: ' + name)
            return buffer.raw
        finally:
            self.dll.SFileCloseFile(handle)

    def close(self):
        self.dll.SFileCloseArchive(self.handle)


def load_dll(path):
    dll = c.WinDLL(str(path))
    signatures = {
        'SFileOpenArchive': [c.c_wchar_p, c.c_uint32, c.c_uint32, c.POINTER(c.c_void_p)],
        'SFileOpenFileEx': [c.c_void_p, c.c_char_p, c.c_uint32, c.POINTER(c.c_void_p)],
        'SFileGetFileSize': [c.c_void_p, c.POINTER(c.c_uint32)],
        'SFileReadFile': [c.c_void_p, c.c_void_p, c.c_uint32, c.POINTER(c.c_uint32), c.c_void_p],
        'SFileCloseFile': [c.c_void_p],
        'SFileCloseArchive': [c.c_void_p],
        'SFileAddFileEx': [c.c_void_p, c.c_wchar_p, c.c_char_p, c.c_uint32, c.c_uint32, c.c_uint32],
    }
    for name, args in signatures.items():
        getattr(dll, name).argtypes = args
        getattr(dll, name).restype = c.c_uint32
    return dll


def function(source, name):
    matches = re.findall(r'^function ' + re.escape(name) + r' takes[^\n]*\n.*?^endfunction\b', source, re.M | re.S)
    if len(matches) != 1:
        raise ValueError('Expected one generated function: ' + name)
    return matches[0]


def wct_scripts(data):
    if struct.unpack_from('<I', data)[0] != 1:
        raise ValueError('Only WCT v1 is supported')
    pos = data.index(b'\0', 4) + 1
    size = struct.unpack_from('<I', data, pos)[0]
    pos += 4 + size
    count = struct.unpack_from('<I', data, pos)[0]
    pos += 4
    result = []
    for _ in range(count):
        size = struct.unpack_from('<I', data, pos)[0]
        pos += 4
        result.append(data[pos:pos + size].rstrip(b'\0').decode('utf8'))
        pos += size
    if pos != len(data):
        raise ValueError('Unexpected WCT tail')
    return result


def scaffold(archive, root):
    source = archive.read('war3map.j').decode('utf-8-sig').replace('\r\n', '\n')
    globals_block = re.search(r'^globals\b(.*?)^endglobals\b', source, re.M | re.S)[1]
    declarations = [line for line in globals_block.splitlines() if re.match(r'^\s*\w+\s+(?:array\s+)?(?:gg_|udg_)\w+', line)]
    if not any('gg_rct_Home' in line for line in declarations):
        raise ValueError('Source map has no home region')
    scripts = wct_scripts(archive.read('war3map.wct'))
    if len(scripts) < 2 or 'Import.j' not in scripts[0] or 'library JNServerCode' not in scripts[1]:
        raise ValueError('Source map does not have the expected ARCANA entry triggers')
    # 활성 편집기 진입 트리거가 두 개라는 점은 원본 컴파일 결과에서도 확인한다.
    init = function(source, 'InitCustomTriggers')
    entries = re.findall(r'call (InitTrig_\w+)\(', init)
    if entries != ['InitTrig_Import', 'InitTrig_JNServer']:
        raise ValueError('Additional editor triggers require an updated scaffold')
    imports = re.sub(r'//! import "[^"\n]*[\\/]Import\.j"', lambda _: '//! import "' + str(root / 'Import.j') + '"', scripts[0])
    names = ['InitGlobals', 'InitSounds', 'CreateUnitsForPlayer0', 'CreateUnitsForPlayer1',
             'CreateUnitsForPlayer2', 'CreateUnitsForPlayer3', 'CreateNeutralPassive',
             'CreatePlayerBuildings', 'CreatePlayerUnits', 'CreateAllUnits', 'CreateRegions',
             'CreateCameras', 'InitCustomTriggers', 'InitCustomPlayerSlots', 'InitCustomTeams',
             'InitAllyPriorities', 'config']
    main = function(source, 'main')
    before = main[:main.index('    call InitBlizzard()') + len('    call InitBlizzard()')]
    after = main[main.index('    call InitGlobals()'):]
    result = '\n'.join(['// 원본 맵에서 추출한 배치와 현재 저장소의 스크립트를 결합한다.',
                        'globals', 'constant boolean REFORGED_MODE = false', *declarations,
                        'endglobals', imports, scripts[1],
                        *(function(source, name) for name in names), before + '\n' + after])
    # 다른 클라이언트의 배치나 오래된 로그 템플릿을 사용하지 않는다.
    for name in names:
        if function(result, name) != function(source, name):
            raise AssertionError(name)
    return result, names


def sha(data):
    return hashlib.sha256(data).hexdigest()


def import_table(data, names):
    version, count = struct.unpack_from('<II', data)
    if version != 1:
        raise ValueError('Only import table version 1 is supported')
    pos, existing = 8, set()
    for _ in range(count):
        flag = data[pos]
        end = data.index(b'\0', pos + 1)
        name = data[pos + 1:end].decode('utf8').replace('/', '\\')
        if flag in (5, 8):
            name = 'war3mapImported\\' + name
        existing.add(name.lower())
        pos = end + 1
    if pos != len(data):
        raise ValueError('Unexpected import table tail')
    added = [name for name in names if name.lower() not in existing]
    return struct.pack('<II', version, count + len(added)) + data[8:] + b''.join(b'\x0d' + name.encode('utf8') + b'\0' for name in added)


def run(args):
    root = Path(__file__).resolve().parents[1]
    source, output, build = args.source.resolve(), args.output.resolve(), args.build_dir.resolve()
    if source == output or output.exists():
        raise ValueError('Output must be a new path, distinct from the source map')
    build.mkdir(parents=True, exist_ok=True)
    (build / 'bin').mkdir(exist_ok=True)
    (build / 'pjass').mkdir(exist_ok=True)
    (build / 'logs').mkdir(exist_ok=True)
    original_hash = sha(source.read_bytes())
    manifest = root / 'assets/expedition/import-manifest.json'
    assets = []
    if manifest.exists():
        for asset in json.loads(manifest.read_text(encoding='utf8')):
            path = (root / asset['source']).resolve()
            path.relative_to(root)
            if sha(path.read_bytes()) != asset['sha256']:
                raise ValueError('UI asset hash mismatch: ' + asset['source'])
            assets.append((asset['target'], path, asset['sha256']))
    dll = load_dll(args.stormlib)
    archive = Archive(dll, source)
    try:
        text, names = scaffold(archive, root)
        members = sorted(set(archive.read('(listfile)').decode('utf-8-sig').splitlines()))
        hashes = {name: sha(archive.read(name)) for name in members if name and name not in ('(listfile)', '(attributes)', 'war3map.j')}
        imports = import_table(archive.read('war3map.imp'), [name for name, _, _ in assets])
    finally:
        archive.close()
    (build / 'input.j').write_text(text, encoding='utf8')
    shutil.copy2(args.jn_root / 'jasshelper/vexorianjasshelper.exe', build / 'vexorianjasshelper.exe')
    for name in ('common.j', 'Blizzard.j'):
        shutil.copy2(args.compiler_data / name, build / name)
    shutil.copy2(args.jn_root / 'bin/SFmpq.dll', build / 'bin/SFmpq.dll')
    shutil.copy2(args.jn_root / 'bin/SFmpq.dll', build / 'SFmpq.dll')
    shutil.copy2(args.compiler_data / 'pjass/f2d22c84.exe', build / 'pjass/f2d22c84.exe')
    (build / 'jasshelper.conf').write_text('[lookupfolders]\n"' + str(args.jn_root / 'import') + '\\"\n[jasscompiler]\n"pjass\\f2d22c84.exe"\n"$COMMONJ $BLIZZARDJ $WAR3MAPJ"\n[noreturnfixer]\n[doshadowfixer]\n', encoding='utf8')
    compiled = build / 'war3map.j'
    proc = subprocess.run([str(build / 'vexorianjasshelper.exe'), '--scriptonly', 'common.j', 'Blizzard.j', 'input.j', 'war3map.j'], cwd=build, timeout=60, creationflags=subprocess.CREATE_NO_WINDOW)
    if proc.returncode or not compiled.exists():
        raise RuntimeError('Compile failed; inspect ' + str(build / 'logs/compileerrors.txt'))
    check = subprocess.run([str(build / 'pjass/f2d22c84.exe'), 'common.j', 'Blizzard.j', 'war3map.j'], cwd=build, capture_output=True, text=True, timeout=30, creationflags=subprocess.CREATE_NO_WINDOW)
    if check.returncode:
        raise RuntimeError(check.stdout + check.stderr)
    output.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, output)
    (build / 'war3map.imp').write_bytes(imports)
    archive = Archive(dll, output, write=True)
    try:
        if not dll.SFileAddFileEx(archive.handle, str(compiled), b'war3map.j', 0x80000200, 2, 2):
            raise OSError('Cannot replace war3map.j')
        for name, path, _ in assets:
            if not dll.SFileAddFileEx(archive.handle, str(path), name.encode('utf8'), 0x80000200, 2, 2):
                raise OSError('Cannot import UI asset: ' + name)
        if not dll.SFileAddFileEx(archive.handle, str(build / 'war3map.imp'), b'war3map.imp', 0x80000200, 2, 2):
            raise OSError('Cannot update UI import table')
    finally:
        archive.close()
    archive = Archive(dll, output)
    try:
        if archive.read('war3map.j') != compiled.read_bytes():
            raise AssertionError('Packaged script mismatch')
        replacements = {'war3map.imp': sha(imports), **{name: digest for name, _, digest in assets}}
        changed = [name for name, digest in hashes.items() if name in replacements and replacements[name] != digest]
        for name, digest in {**hashes, **replacements}.items():
            if sha(archive.read(name)) != digest:
                raise AssertionError('Unexpected member change: ' + name)
    finally:
        archive.close()
    if sha(source.read_bytes()) != original_hash:
        raise AssertionError('Original map changed')
    report = {'source': str(source), 'source_sha256': original_hash, 'output': str(output),
              'output_sha256': sha(output.read_bytes()), 'script_sha256': sha(compiled.read_bytes()),
              'preserved_members': len(hashes) - len(changed), 'updated_members': changed,
              'ui_assets': [{'name': name, 'sha256': digest} for name, _, digest in assets],
              'preserved_generated_functions': names,
              'compiler_exit': proc.returncode, 'pjass_exit': check.returncode,
              'pjass_output': check.stdout + check.stderr, 'runtime_tested': False}
    (build / 'report.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf8')
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    for name in ('source', 'output', 'build-dir', 'jn-root', 'compiler-data', 'stormlib'):
        parser.add_argument('--' + name, required=True, type=Path)
    run(parser.parse_args())
