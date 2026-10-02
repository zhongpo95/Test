# 기본 채팅 FrameShow 호출로 중단된 초기화를 복구하는 v205 맵을 만든다.
import argparse
import hashlib
import json
from pathlib import Path
from archive import Archive

BASE = '849ea00f7c1d625c4b6e677168306b74e932fe3d3727059a4b64eb0927bfbbfc'
NATIVE = 'scripts/system/bootstrap/native_ui.lua'


def patch(raw):
    line = b'  japi.FrameShow(frame, false)'
    start = raw.index(b'function M.clear_chat_frame()')
    end = raw.index(b'\nend', start)
    block = raw[start:end]
    assert block.count(line) == 1
    eol = b'\r\n' if b'\r\n' in raw else b'\n'
    return raw[:start] + block.replace(line + eol, b'', 1) + raw[end:]


def build(source, output):
    assert not output.exists(), 'output already exists'
    data = source.read_bytes()
    assert hashlib.sha256(data).hexdigest() == BASE, 'unexpected v204 baseline'
    original = Archive(data)
    changes = {NATIVE: patch(original.read(NATIVE))}
    for name in ('hera_build_info.lua', 'war3map.j', 'war3map.w3i'):
        raw = original.read(name)
        assert b'204 MP' in raw
        changes[name] = raw.replace(b'204 MP', b'205 MP')
    result = original.write(changes, 204, 205)
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
