# 외침 설정을 파일 대신 현재 게임의 메모리에만 유지한다.
import argparse
import hashlib
import json
from pathlib import Path
from archive import Archive
from patch import CHAT, once

BASE = '57900ead103d1e7ac4e80248e2e31cb213f797426ee4c1bb5f1c6ed2e55c8498'


def patch(read):
    raw = read(CHAT)
    s = raw.decode('utf8').replace('\r\n', '\n')
    s = once(s, 'local storm = require("jass.storm")\n', '')
    s = once(s, 'local save_path = "tloc_chat_tool.txt"\n', '')
    s = once(s, '변경 사항은 자동 저장됩니다. 창을 닫아도 단축키를 사용할 수 있습니다.',
             '설정은 현재 게임에서만 유지됩니다. 새 게임을 시작하면 초기화됩니다.')
    start = s.index('local function save_slots()')
    end = s.index('local function binding_text(keys)', start)
    s = s[:start] + '''local function settings_changed()
  status:set_text("외침 설정을 적용했습니다. 현재 게임에서만 유지됩니다.")
end

-- 문구와 단축키는 이 게임의 Lua 상태에만 보관한다.
for i = 1, 10 do
  slots[i] = ""
  bindings[i] = {
    KEY.ALT,
    48 + i % 10
  }
end

''' + s[end:]
    assert s.count('save_slots()') == 3
    s = s.replace('save_slots()', 'settings_changed()')
    s = once(s, '이번 기록은 저장하지 않았습니다.', '이번 기록은 적용하지 않았습니다.')
    return {CHAT: s.replace('\n', '\r\n' if b'\r\n' in raw else '\n').encode('utf8')}


def build(source, output):
    assert not output.exists(), 'output already exists'
    data = source.read_bytes()
    assert hashlib.sha256(data).hexdigest() == BASE, 'unexpected v208 baseline'
    original = Archive(data)
    changes = patch(original.read)
    for name in ('hera_build_info.lua', 'war3map.j', 'war3map.w3i'):
        raw = original.read(name)
        assert b'208 MP' in raw
        changes[name] = raw.replace(b'208 MP', b'209 MP')
    result = original.write(changes, 208, 209)
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
