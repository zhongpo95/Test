# 평탄한 6인 시험 맵을 새 MPQ로 만들고 패키지와 컴파일 결과를 검증한다.
import argparse
import ctypes as c
import hashlib
import importlib.util
import json
import struct
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.dont_write_bytecode = True
TITLE = 'Hera Mouse Multiplayer Test v002'


def u(*values):
    return struct.pack('<' + 'I' * len(values), *values)


def f(*values):
    return struct.pack('<' + 'f' * len(values), *values)


def z(value):
    return value.encode('utf8') + b'\0'


def info():
    data = u(25, 1, 6052) + z(TITLE) + z('Mouse multiplayer diagnostic')
    data += z('2-6 human players. -help shows commands. Requires Hera/JN Lua engine.') + z('Shared receipts and point-order probe')
    data += f(-1536, -1536, 1536, 1536, -1536, 1536, 1536, -1536)
    data += u(4, 4, 4, 4, 32, 32, 0x60) + b'L'
    data += u(0xffffffff) + z('') + z('Compare -local, -mouse, -dz, -track and -order.')
    data += z(TITLE) + z('ACK N/N verifies peer receipts, not accuracy of the local reader.')
    data += u(0) + z('') + z('') + z('') + z('')
    data += u(0) + f(3000, 5000, 0.5) + bytes([0, 0, 0, 255])
    data += u(0) + z('') + b'L' + bytes([255] * 4)
    data += u(6)
    for player in range(6):
        data += u(player, 1, 1, 1) + z('Tester ' + str(player + 1))
        data += f(-750 + player * 300, -600) + u(0, 0)
    data += u(6)
    for player in range(6):
        data += u(0, 1 << player) + z('Tester team ' + str(player + 1))
    return data + u(0, 0, 0, 0)


def ability():
    mods = []

    def mod(field, kind, value, level=0, pointer=0):
        encoded = z(value) if kind == 3 else (f(value) if kind in (1, 2) else u(value))
        mods.append(field.encode('ascii') + u(kind, level, pointer) + encoded + b'A0CJ')

    mod('anam', 3, 'Point-order probe')
    mod('alev', 0, 1)
    mod('areq', 3, '')
    mod('aher', 0, 0)
    mod('aite', 0, 0)
    for field, value in [('Ncl1', 0), ('acdn', 0.01), ('arng', 200000), ('Ncl5', 0)]:
        mod(field, 1, value, 1, {'Ncl1': 1, 'Ncl5': 5}.get(field, 0))
    mod('Ncl2', 0, 2, 1, 2)
    mod('Ncl3', 0, 1, 1, 3)
    mod('Ncl4', 0, 0, 1, 4)
    mod('Ncl6', 3, 'innerfire', 1, 6)
    mod('amcs', 0, 0, 1)
    mod('atp1', 3, 'Point-order probe', 1)
    mod('aub1', 3, 'Ground-target spell event used by the mouse diagnostic.', 1)
    mod('aart', 3, '')
    return u(1, 0, 1) + b'ANclA0CJ' + u(len(mods)) + b''.join(mods)


def members():
    # Warcraft III 1.28에서 쓰는 W3E v11, W3I v25 형식을 사용한다.
    terrain = b'W3E!' + u(11) + b'L' + u(0, 2) + b'LdrtLgrs'
    terrain += u(2) + b'CLdiCLgr' + u(33, 33) + f(-2048, -2048)
    terrain += struct.pack('<HHBBB', 8192, 8192, 1, 0, 2) * (33 * 33)
    result = {
        'war3map.j': (ROOT / 'war3map.j').read_bytes(),
        'mouse_test.lua': (ROOT / 'mouse_test.lua').read_bytes(),
        'war3map.w3i': info(), 'war3map.w3e': terrain, 'war3map.w3a': ability(),
        'war3map.wpm': b'MP3W' + u(0, 128, 128) + bytes(128 * 128),
        'war3map.shd': bytes(128 * 128),
        'war3map.doo': b'W3do' + u(8, 11, 0, 0, 0),
        'war3mapUnits.doo': b'W3do' + u(8, 11, 0),
        'war3map.w3r': u(5, 0), 'war3map.w3c': u(0, 0), 'war3map.mmp': u(0, 0),
        'war3map.imp': u(1, 1) + b'\x0d' + z('mouse_test.lua'),
    }
    return result


def main():
    parser = argparse.ArgumentParser()
    for name in ('output', 'build-dir', 'stormlib', 'pjass', 'common', 'blizzard'):
        parser.add_argument('--' + name, type=Path, required=True)
    args = parser.parse_args()
    output, build = args.output.resolve(), args.build_dir.resolve()
    if output.exists():
        raise ValueError('Refusing to overwrite an existing map: ' + str(output))
    build.mkdir(parents=True, exist_ok=True)
    assets = members()
    for name, data in assets.items():
        (build / name).write_bytes(data)
    result = subprocess.run([str(args.pjass), str(args.common), str(args.blizzard), str(build / 'war3map.j')],
                            capture_output=True, text=True)
    (build / 'pjass.txt').write_text(result.stdout + result.stderr, encoding='utf8')
    if result.returncode:
        raise RuntimeError('PJass failed; see ' + str(build / 'pjass.txt'))
    spec = importlib.util.spec_from_file_location('expedition_builder', ROOT.parent / 'build-expedition.py')
    mpq = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mpq)
    dll = mpq.load_dll(args.stormlib)
    dll.SFileCreateArchive.argtypes = [c.c_wchar_p, c.c_uint32, c.c_uint32, c.POINTER(c.c_void_p)]
    dll.SFileCreateArchive.restype = c.c_uint32
    archive_path = build / 'mouse-test.mpq'
    if archive_path.exists():
        raise ValueError('Use a fresh build directory')
    handle = c.c_void_p()
    if not dll.SFileCreateArchive(str(archive_path), 0, 64, c.byref(handle)):
        raise OSError('SFileCreateArchive failed')
    try:
        for name in assets:
            if not dll.SFileAddFileEx(handle, str(build / name), name.encode('ascii'), 0x80000200, 2, 2):
                raise OSError('Cannot pack ' + name)
    finally:
        if not dll.SFileCloseArchive(handle):
            raise OSError('Cannot close archive')
    header = b'HM3W' + u(0) + z(TITLE) + u(0x60, 6)
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open('xb') as target:
        target.write(header.ljust(512, b'\0') + archive_path.read_bytes())
    packed = mpq.Archive(dll, output)
    try:
        for name, expected in assets.items():
            if packed.read(name) != expected:
                raise AssertionError('MPQ member mismatch: ' + name)
    finally:
        packed.close()
    report = {
        'output': str(output), 'bytes': output.stat().st_size,
        'sha256': hashlib.sha256(output.read_bytes()).hexdigest(),
        'members': {name: hashlib.sha256(data).hexdigest() for name, data in assets.items()},
        'players': 6, 'lobbyTeams': 6, 'terrainCells': [32, 32], 'jassCompile': 'passed',
        'packageReadback': 'passed', 'realGameTested': False, 'multiplayerTested': False,
        'existingMapUsedOrChanged': False,
    }
    (build / 'build-report.json').write_text(json.dumps(report, indent=2), encoding='utf8')
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
