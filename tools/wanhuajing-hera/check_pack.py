# 원본 MPQ 해시 슬롯 보존과 결과 맵의 모든 블록 내용을 독립적으로 다시 읽어 검사한다.
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
from build import Archive, SOURCE_SHA256, crypt, file_hash, name_hash, restore_asset


def table(path):
    with path.open('rb') as file:
        prefix = file.read(8192)
        base = prefix.index(b'MPQ\x1a')
        _, size, total, version, shift, hp, bp, count, blocks = struct.unpack_from('<4sIIHHIIII', prefix, base)
        assert size == 32 and version == 0 and total + base == path.stat().st_size
        file.seek(base + hp)
        entries = list(struct.iter_unpack('<IIHHI', crypt(file.read(count * 16), name_hash('(hash table)', 3))))
        return prefix[:base], entries, blocks


def main():
    parser = argparse.ArgumentParser()
    for name in ('source', 'output', 'stormlib', 'report'):
        parser.add_argument('--' + name, required=True, type=Path)
    args = parser.parse_args()
    report = json.loads(args.report.read_text(encoding='utf8'))
    assert file_hash(args.source) == SOURCE_SHA256 == report['source_sha256']
    assert file_hash(args.output) == report['output_sha256']
    before, original, old_count = table(args.source)
    after, modified, new_count = table(args.output)
    assert len(original) == len(modified)
    title = report.get('map_name')
    if title:
        old_end, new_end = before.index(b'\0', 8), after.index(b'\0', 8)
        assert len(before) == len(after) == 512 and before[:8] == after[:8]
        assert after[8:new_end].decode('utf8') == title
        assert before[old_end:old_end + 9] == after[new_end:new_end + 9]
        assert not any(before[old_end + 9:]) and not any(after[new_end + 9:])
    else:
        assert before == after
    preserved_slots = 0
    for index, entry in enumerate(original):
        if entry[-1] not in (0xffffffff, 0xfffffffe):
            assert entry == modified[index], ('Changed original hash slot', index)
            preserved_slots += 1
    assert len(report['files']) == new_count and old_count == 10611
    archive = Archive(args.output, args.stormlib)
    try:
        if title:
            source = Archive(args.source, args.stormlib)
            try: old_info = source.read('war3map.w3i')
            finally: source.close()
            info = archive.read('war3map.w3i')
            old_end, new_end = old_info.index(b'\0', 12), info.index(b'\0', 12)
            assert old_info[:12] == info[:12] and old_info[old_end:] == info[new_end:]
            assert info[12:new_end].decode('utf8') == title
            config_names = re.findall(r'call SetMapName\("([^"\r\n]*)"\)', archive.read('war3map.j').decode('utf8'))
            assert config_names == [title]
        texture_report = args.report.with_name('model-textures.json')
        if texture_report.exists():
            textures = json.loads(texture_report.read_text(encoding='utf8'))
            source = Archive(args.source, args.stormlib)
            changed = 0
            try:
                for row in report['files'][:old_count]:
                    if row['name']:
                        continue
                    original_data, _ = restore_asset(source.read(f"File{row['index']:08d}.xxx"))
                    if not original_data.startswith(b'MDLX'):
                        continue
                    data = archive.read(f"File{row['index']:08d}.xxx")
                    assert len(data) == len(original_data)
                    masked = bytearray(data)
                    offset = 4
                    while offset < len(data):
                        tag, size = struct.unpack_from('<4sI', original_data, offset)
                        if tag == b'TEXS':
                            for start in range(offset + 8, offset + 8 + size, 268):
                                old = original_data[start + 4:start + 264].split(b'\0')[0]
                                new = data[start + 4:start + 264].split(b'\0')[0]
                                if old != new:
                                    entry = textures['textures'][old.decode('ascii')]
                                    assert new.decode('ascii') == entry['path']
                                    texture = archive.read(entry['path'])
                                    assert texture.startswith(b'BLP1')
                                    assert hashlib.sha256(texture).hexdigest() == entry['sha256']
                                    masked[start + 4:start + 264] = original_data[start + 4:start + 264]
                        offset += 8 + size
                    assert bytes(masked) == original_data, ('Non-texture model data changed', row['index'])
                    changed += data != original_data
                assert changed == textures['changed_models']
            finally:
                source.close()
        named = 0
        for row in report['files']:
            data = archive.read(f"File{row['index']:08d}.xxx")
            assert len(data) == row['size']
            assert hashlib.sha256(data).hexdigest() == row['sha256'], row['index']
            if row['name']:
                assert archive.read(row['name']) == data, row['name']
                named += 1
            if row['index'] % 2000 == 0: print('Verified', row['index'], flush=True)
    finally:
        archive.close()
    result = {'source_sha256': SOURCE_SHA256, 'output_sha256': report['output_sha256'],
              'output_bytes': args.output.stat().st_size, 'verified_blocks': new_count,
              'verified_named_patches': named, 'preserved_original_hash_slots': preserved_slots,
              'source_unchanged': True, 'runtime_tested': False}
    if title: result['map_name'] = title
    args.report.with_name('verification.json').write_text(json.dumps(result, indent=2), encoding='utf8')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
