# 한글 자음과 모음도 한국어 폰트로 표시하도록 문자 판별을 보완한다.
import argparse
import hashlib
import json
from pathlib import Path
from archive import Archive
from patch import once

BASE = '54489cbe61c386f32307e42e61fdd67aff75a113900278e225b61f2d8e3e42bb'
KOREAN = 'hera_korean.lua'


def patch(read):
    raw = read(KOREAN)
    s = raw.decode('utf8').replace('\r\n', '\n')
    s = once(s, '    if code >= 0xAC00 and code <= 0xD7A3 then return true end',
             '''    -- ㅋㅋ, ㅎㅎ, ㅁㄴㅇ처럼 음절로 조합되지 않은 자모도 한글 폰트를 사용한다.
    if code >= 0xAC00 and code <= 0xD7A3 or code >= 0x3131 and code <= 0x318E then return true end''')
    return {KOREAN: s.replace('\n', '\r\n' if b'\r\n' in raw else '\n').encode('utf8')}


def build(source, output):
    assert not output.exists(), 'output already exists'
    data = source.read_bytes()
    assert hashlib.sha256(data).hexdigest() == BASE, 'unexpected v210 baseline'
    original = Archive(data)
    changes = patch(original.read)
    for name in ('hera_build_info.lua', 'war3map.j', 'war3map.w3i'):
        raw = original.read(name)
        assert b'210 MP' in raw
        changes[name] = raw.replace(b'210 MP', b'211 MP')
    result = original.write(changes, 210, 211)
    checked = Archive(result)
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
    report = dict(source_sha256=BASE, output_sha256=hashlib.sha256(result).hexdigest(),
                  changed=list(changes), unchanged_blocks=len(original.blocks)-len(ids),
                  runtime_tested=False, multiplayer_tested=False, visual_tested=False)
    output.with_suffix('.json').write_text(json.dumps(report, indent=2), encoding='utf8')
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('source', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    print(json.dumps(build(args.source, args.output), indent=2))
