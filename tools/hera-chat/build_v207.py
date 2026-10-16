# 기존 UI_Msg.j의 두 모서리 이동 방식으로 기본 채팅을 화면 밖에 배치한다.
import argparse
import hashlib
import json
from pathlib import Path
from archive import Archive
from patch import NATIVE, once

BASE = 'fdf3d8feea3ea382b0a7ec0aef85af66032cf3121714e7e654079fe1875cbb9c'
PLAYER = 'scripts/jh/ac/player.lua'


def patch(read):
    changes = {}
    s = read(NATIVE).decode('utf8').replace('\r\n', '\n')
    start = s.index('function M.clear_chat_frame()')
    end = s.index('\nend', start) + 4
    s = s[:start] + '''function M.clear_chat_frame()
  local frame = japi.FrameGetChatMessage()
  if not frame or frame == 0 then return end
  -- UI/UI_Msg.j와 같이 두 모서리를 지정하되 사각형 전체를 화면 밖으로 옮긴다.
  japi.FrameClearAllPoints(frame)
  japi.FrameSetAbsolutePoint(frame, 6, 2.00, 2.00)
  japi.FrameSetAbsolutePoint(frame, 2, 2.29, 2.14)
end''' + s[end:]
    s = once(s, '  M.clear_chat_frame()\n', '  ac.wait(1000, M.clear_chat_frame)\n')
    changes[NATIVE] = s
    s = read(PLAYER).decode('utf8').replace('\r\n', '\n')
    s = once(s, '''    -- 엔진이 새 채팅을 추가한 뒤 복구하는 기본 프레임 배치를 다시 숨긴다.
    ac.wait(1, function() require("system.bootstrap.native_ui").clear_chat_frame() end)
''', '')
    changes[PLAYER] = s
    return {name: text.replace('\n', '\r\n' if b'\r\n' in read(name) else '\n').encode('utf8')
            for name, text in changes.items()}


def build(source, output):
    assert not output.exists(), 'output already exists'
    data = source.read_bytes()
    assert hashlib.sha256(data).hexdigest() == BASE, 'unexpected v206 baseline'
    original = Archive(data)
    changes = patch(original.read)
    for name in ('hera_build_info.lua', 'war3map.j', 'war3map.w3i'):
        raw = original.read(name)
        assert b'206 MP' in raw
        changes[name] = raw.replace(b'206 MP', b'207 MP')
    result = original.write(changes, 206, 207)
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
