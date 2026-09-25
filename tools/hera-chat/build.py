# v203 원본을 보존하고 채팅 수정 및 진단 중지 v204 맵을 생성한다.
import argparse
import difflib
import hashlib
import json
from pathlib import Path
from archive import Archive
from patch import patch

BASE = '8024b53535c773d13da51c3874c51a02cf2c932b7b79bcfebb7680bae04f8a14'


def build(source, output):
    assert not output.exists(), 'output already exists'
    data = source.read_bytes()
    assert hashlib.sha256(data).hexdigest() == BASE, 'unexpected baseline'
    original = Archive(data)
    changes = patch(original.read)
    for name in ('hera_build_info.lua', 'war3map.j', 'war3map.w3i'):
        raw = changes.get(name, original.read(name))
        assert b'203 MP' in raw
        changes[name] = raw.replace(b'203 MP', b'204 MP')
    result = original.write(changes, 203, 204)
    checked = Archive(result)
    for name, raw in changes.items():
        assert checked.read(name) == raw, name
    ids = {original.index(name) for name in changes}
    for index, row in enumerate(original.blocks):
        if index not in ids:
            assert checked.blocks[index] == row
            off, size, _, _ = row
            assert data[original.base+off:original.base+off+size] == result[checked.base+off:checked.base+off+size]
    assert checked.hashes == original.hashes
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(result)
    diff = []
    for name, raw in changes.items():
        target = output.parent / 'source' / name
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
        if name.endswith(('.lua', '.j')):
            diff.extend(difflib.unified_diff(original.read(name).decode('utf8').replace('\r\n', '\n').splitlines(True),
                raw.decode('utf8').replace('\r\n', '\n').splitlines(True), fromfile='v203/' + name, tofile='v204/' + name))
    (output.parent / 'changes.diff').write_text(''.join(diff), encoding='utf8')
    report = dict(source_sha256=BASE, output_sha256=hashlib.sha256(result).hexdigest(),
                  changed=list(changes), unchanged_blocks=len(original.blocks)-len(ids),
                  runtime_tested=False, multiplayer_tested=False, visual_tested=False)
    output.with_suffix('.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf8')
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('source', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    print(json.dumps(build(args.source, args.output), ensure_ascii=False, indent=2))
