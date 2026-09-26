# 맵 선택 헤더와 내부 제목을 GHJ로 통일하고 기존 게임 데이터를 보존한다.
import argparse
import hashlib
import json
import struct
from pathlib import Path
from archive import Archive

BASE = '7b2153f40dda10015e69e6225f8f5779781b4aea34625adac83166bc8c069ffe'
OLD = b'Hera RPG initialization v211 MP'
TITLE = b'GHJ'


def build(source, output):
    assert not output.exists(), 'output already exists'
    data = source.read_bytes()
    assert hashlib.sha256(data).hexdigest() == BASE, 'unexpected v211 baseline'
    original = Archive(data)
    info = original.read('war3map.w3i')
    assert struct.unpack_from('<I', info)[0] == 25
    info_end = info.index(b'\0', 12)
    assert info[12:info_end] == OLD
    changes = {'war3map.w3i': info[:12] + TITLE + info[info_end:]}
    for name in ('war3map.j', 'hera_build_info.lua'):
        raw = original.read(name)
        assert raw.count(OLD) == 1
        changes[name] = raw.replace(OLD, TITLE)
    result = bytearray(original.write(changes, 211, 211))
    prefix = bytes(result[:original.base])
    assert prefix[:4] == b'HM3W'
    end = prefix.index(b'\0', 8)
    assert prefix[8:end] == OLD
    # 제목 길이만 줄이고 MPQ 시작 위치, 헤더의 플래그/플레이어 수를 보존한다.
    compact = prefix[:8] + TITLE + prefix[end:]
    result[:original.base] = compact.ljust(original.base, b'\0')
    checked = Archive(bytes(result))
    assert checked.base == original.base
    assert result[8:12] == b'GHJ\0'
    assert result[12:20] == prefix[end+1:end+9]
    assert changes['war3map.w3i'][16:] == info[info_end+1:]
    assert b'call SetMapName("GHJ")' in checked.read('war3map.j')
    for name, raw in changes.items():
        assert checked.read(name) == raw
    ids = {original.index(name) for name in changes}
    for index, row in enumerate(original.blocks):
        if index not in ids:
            assert checked.blocks[index] == row
            off, size, _, _ = row
            assert data[original.base+off:original.base+off+size] == result[checked.base+off:checked.base+off+size]
    assert checked.hashes == original.hashes
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(result)
    for name, raw in changes.items():
        target = output.parent / 'source' / name
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
    report = dict(title='GHJ', source_sha256=BASE, output_sha256=hashlib.sha256(result).hexdigest(),
                  changed=list(changes), header_title_changed=True,
                  unchanged_blocks=len(original.blocks)-len(ids), runtime_tested=False)
    output.with_suffix('.json').write_text(json.dumps(report, indent=2), encoding='utf8')
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('source', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    print(json.dumps(build(args.source, args.output), indent=2))
