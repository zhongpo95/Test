# 사용자가 지정한 외침 문구 10개를 새 게임의 기본값으로 설정한다.
import argparse
import hashlib
import json
from pathlib import Path
from archive import Archive
from patch import CHAT, once

BASE = 'c3a88a73991bc46980ccb056ac7662f37bcc892f6b5da529d6d90506ab0b3dc3'
DEFAULTS = ['+9999999999999999999999999', '-zx2', '-zc', '-ㅋㅌ', '-zx',
            '-tldi', '-ex1해봐', '-next', '-rm1', '-ㅋㅌ2']


def patch(read):
    raw = read(CHAT)
    s = raw.decode('utf8').replace('\r\n', '\n')
    values = ',\n'.join('  ' + json.dumps(value, ensure_ascii=False) for value in DEFAULTS)
    s = once(s, 'local slots = {}', 'local default_slots = {\n' + values + '\n}\nlocal slots = {}')
    s = once(s, '  slots[i] = ""', '  slots[i] = default_slots[i]')
    s = once(s, '새 게임을 시작하면 초기화됩니다.', '새 게임에서는 기본 문구로 돌아갑니다.')
    return {CHAT: s.replace('\n', '\r\n' if b'\r\n' in raw else '\n').encode('utf8')}


def build(source, output):
    assert not output.exists(), 'output already exists'
    data = source.read_bytes()
    assert hashlib.sha256(data).hexdigest() == BASE, 'unexpected v209 baseline'
    original = Archive(data)
    changes = patch(original.read)
    for name in ('hera_build_info.lua', 'war3map.j', 'war3map.w3i'):
        raw = original.read(name)
        assert b'209 MP' in raw
        changes[name] = raw.replace(b'209 MP', b'210 MP')
    result = original.write(changes, 209, 210)
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
