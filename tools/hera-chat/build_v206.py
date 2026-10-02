# 외침 실행의 미지원 API를 우회하고 영웅 선택 전 채팅 표시를 연결한다.
import argparse
import hashlib
import json
from pathlib import Path
from archive import Archive
from patch import CHAT, NATIVE, once

BASE = 'a21d35caf394bf39eabe09e4ff7e69945e069a094fea2af70147c77b7fe59cb5'
PLAYER = 'scripts/jh/ac/player.lua'


def patch(read):
    changes = {}
    s = read(CHAT).decode('utf8').replace('\r\n', '\n')
    s = once(s, 'local slots = {}', '''-- 설치 YDWE에는 GetChatState가 없으므로 Enter/Esc와 채팅 수신으로 보완한다.
local chat_open = false
local function is_chat_open()
  if type(japi.GetChatState) == "function" then
    local state = japi.GetChatState()
    return state == true or state == 1
  end
  return chat_open
end
local slots = {}''')
    assert s.count('not japi.GetChatState()') == 2
    s = s.replace('not japi.GetChatState()', 'not is_chat_open()')
    s = once(s, '''    for key in pairs(down) do
      if not ui.IsKeyDown(key) then''', '''    if not recording and not focused_edit then
      if code == 13 or code == KEY.ESC then
        if code == 13 then chat_open = not chat_open else chat_open = false end
        down[code], used[code] = false, true
        return
      end
    end
    for key in pairs(down) do
      if not ui.IsKeyDown(key) then''')
    s = once(s, '  japi.EXDisplayChat(sender, 0, text)\n',
             '  -- 기본 채팅에 중복 출력하지 않고 기존 명령·커스텀 채팅 처리로 전달한다.\n')
    s = once(s, '''  local text = GetEventPlayerChatString()
  if GetTriggerPlayer() ~= LocalPlayer or text:sub(1, 1) ~= "-" then''', '''  local text = GetEventPlayerChatString()
  if GetTriggerPlayer() == LocalPlayer then chat_open = false end
  if GetTriggerPlayer() ~= LocalPlayer or text:sub(1, 1) ~= "-" then''')
    changes[CHAT] = s

    s = read(PLAYER).decode('utf8').replace('\r\n', '\n')
    s = once(s, '''  if not listeners then
    return
  end
  local hero = Hero[self.id]''', '''  if not listeners or #listeners == 0 then
    -- 영웅 선택 전에도 일반 대화와 외침 문구는 커스텀 채팅에 표시한다.
    if type(UI_NewChat) == "function" then UI_NewChat(self, str, str) end
    return
  end
  local hero = Hero[self.id]''')
    s = once(s, '''  Trg_PlayerChat = war3.CreateTrigger(function()
    getplayer(GetTriggerPlayer()):dispatch_chat(GetEventPlayerChatString())
  end)''', '''  Trg_PlayerChat = war3.CreateTrigger(function()
    -- 엔진이 새 채팅을 추가한 뒤 복구하는 기본 프레임 배치를 다시 숨긴다.
    ac.wait(1, function() require("system.bootstrap.native_ui").clear_chat_frame() end)
    getplayer(GetTriggerPlayer()):dispatch_chat(GetEventPlayerChatString())
  end)''')
    changes[PLAYER] = s
    return {name: text.replace('\n', '\r\n' if b'\r\n' in read(name) else '\n').encode('utf8')
            for name, text in changes.items()}


def build(source, output):
    assert not output.exists(), 'output already exists'
    data = source.read_bytes()
    assert hashlib.sha256(data).hexdigest() == BASE, 'unexpected v205 baseline'
    original = Archive(data)
    changes = patch(original.read)
    for name in ('hera_build_info.lua', 'war3map.j', 'war3map.w3i'):
        raw = original.read(name)
        assert b'205 MP' in raw
        changes[name] = raw.replace(b'205 MP', b'206 MP')
    result = original.write(changes, 205, 206)
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
