# MPQ 경계 크기와 예약형 실제 이름, 목록 누락 감지를 독립 디코더로 검사한다.
import argparse
import importlib.util
from pathlib import Path
import random
import tempfile


def load(name, filename):
    spec = importlib.util.spec_from_file_location(name, Path(__file__).with_name(filename))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


p = argparse.ArgumentParser()
p.add_argument('--stormlib', type=Path, required=True)
args = p.parse_args()
builder = load('builder', 'build-map-assets.py')
writer = load('writer', 'mpq-v0-writer.py')
rng = random.Random(19)
data = {'File00005255.tga': b'texture', 'empty.bin': b'',
        'solid.bin': bytes(10000)}
for size in (1, 4095, 4096, 4097, 8192):
    data[str(size)+'.bin'] = rng.randbytes(size)
data['(listfile)'] = ('\r\n'.join(data)+'\r\n(listfile)\r\n').encode('ascii')
with tempfile.TemporaryDirectory(prefix='.mpq-test-', dir=Path(__file__).parent) as temporary:
    packed, map_path = Path(temporary)/'test.mpq', Path(temporary)/'test.w3x'
    writer.write_mpq(packed, data.items())
    map_path.write_bytes(b'HM3W'+bytes(508)+packed.read_bytes())
    writer.validate_source(map_path, data)
    archive = builder.Archive(args.stormlib, map_path)
    try:
        for name, expected in data.items():
            assert archive.read(name) == expected, name
    finally:
        archive.close()
    try:
        writer.validate_source(map_path, ['(listfile)'])
    except ValueError:
        pass
    else:
        raise AssertionError('Incomplete source list accepted')
    entries = builder.import_entries(b'\x01\0\0\0\x01\0\0\0\x05image.blp\0')[1]
    assert entries[0][2] == 'war3mapimported\\image.blp'
print('PASS: StormLib readback, sector boundaries, compression, empty file, pseudo-style name, incomplete-list rejection, import paths')

