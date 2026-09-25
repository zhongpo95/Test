# 일반 채팅이 외침 도구의 사용자 문구를 밀어내지 않도록 자동 등록을 제거한다.
import argparse
import hashlib
import json
from pathlib import Path
from archive import Archive
from patch import CHAT

BASE = '360a7afedc45689e90a83783f7a303198155a2e57872f853f661501b4a3b5976'


def patch(read):
    raw = read(CHAT)
    s = raw.decode('utf8').replace('\r\n', '\n')
    start = s.index('TriggerAddAction(history, function()')
    end = s.index('\nend)', start) + len('\nend)')
    block = s[start:end]
    assert 'table.remove(slots, 1)' in block and 'slots[10] = text' in block
    s = s[:start] + '''TriggerAddAction(history, function()
  -- 일반 채팅은 외침 문구에 자동 등록하지 않고 입력창 상태만 갱신한다.
  if GetTriggerPlayer() == LocalPlayer then chat_open = false end
end)''' + s[end:]
    return {CHAT: s.replace('\n', '\r\n' if b'\r\n' in raw else '\n').encode('utf8')}


def build(source, output):
    assert not output.exists(), 'output already exists'
    data = source.read_bytes()
    assert hashlib.sha256(data).hexdigest() == BASE, 'unexpected v207 baseline'
    original = Archive(data)
    changes = patch(original.read)
    for name in ('hera_build_info.lua', 'war3map.j', 'war3map.w3i'):
        raw = original.read(name)
        assert b'207 MP' in raw
        changes[name] = raw.replace(b'207 MP', b'208 MP')
    result = original.write(changes, 207, 208)
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
