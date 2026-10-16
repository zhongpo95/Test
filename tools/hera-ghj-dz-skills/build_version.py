# 현재 Dz 수정본의 맵 이름과 인게임 버전 표시를 GHJ 1.6으로 변경한다.
import argparse
import hashlib
import json
import struct
from pathlib import Path

from archive import Archive


BASE_SHA256 = '02b4c303aa6cf438e2b0bfdfc0cb1180a10e7a60309e460fd8a255deba436c3e'


def replace_once(raw, old, new):
    old, new = old.encode('utf8'), new.encode('utf8')
    assert raw.count(old) == 1, 'unexpected version metadata'
    return raw.replace(old, new, 1)


def build(source, output):
    assert not output.exists(), 'output already exists'
    data = source.read_bytes()
    assert hashlib.sha256(data).hexdigest() == BASE_SHA256, 'unexpected patched GHJ 1.5 baseline'
    archive = Archive(data)
    prefix = data[:archive.base]
    title_end = prefix.index(b'\0', 8)
    assert prefix[:4] == b'HM3W' and prefix[8:title_end] == b'GHJ 1.5'
    info = archive.read('war3map.w3i')
    info_end = info.index(b'\0', 12)
    assert struct.unpack_from('<I', info)[0] == 25 and info[12:info_end] == b'GHJ 1.5'
    changes = {
        'war3map.w3i': info[:12] + b'GHJ 1.6' + info[info_end:],
        'war3map.j': replace_once(archive.read('war3map.j'),
            'call SetMapName("GHJ 1.5")', 'call SetMapName("GHJ 1.6")'),
        'hera_build_info.lua': replace_once(archive.read('hera_build_info.lua'),
            'title="GHJ 1.5"', 'title="GHJ 1.6"'),
        'scripts/main.lua': replace_once(archive.read('scripts/main.lua'),
            'GameVersion = "1.5"', 'GameVersion = "1.6"'),
    }
    result = bytearray(archive.write(changes))
    result[8:title_end] = b'GHJ 1.6'
    checked = Archive(bytes(result))
    assert checked.base == archive.base and checked.hashes == archive.hashes
    assert bytes(result[:archive.base]) == prefix[:8] + b'GHJ 1.6' + prefix[title_end:]
    changed_ids = {archive.index(name) for name in changes}
    for name, content in changes.items():
        assert checked.read(name) == content, name
    for index, row in enumerate(archive.blocks):
        if index in changed_ids:
            continue
        assert checked.blocks[index] == row
        offset, size, _, _ = row
        assert data[archive.base + offset:archive.base + offset + size] == result[checked.base + offset:checked.base + offset + size]
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open('xb') as stream:
        stream.write(result)
    return {
        'title': 'GHJ 1.6',
        'game_version': '1.6',
        'source_sha256': BASE_SHA256,
        'output_sha256': hashlib.sha256(result).hexdigest(),
        'changed': list(changes),
        'unchanged_blocks': len(archive.blocks) - len(changed_ids),
        'unrelated_blocks_byte_identical': True,
        'runtime_tested': False,
    }


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('source', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    print(json.dumps(build(args.source, args.output), ensure_ascii=False, indent=2))
