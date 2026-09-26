# 기본 채팅 숨김, 외침 키 입력 연결, 복구 가능한 진단 주석 처리를 적용한다.
import re

CHAT = 'scripts/gameplay/interface/ui/chat_tool.lua'
NATIVE = 'scripts/system/bootstrap/native_ui.lua'


def once(text, old, new):
    assert text.count(old) == 1, old[:120]
    return text.replace(old, new, 1)


def comment(text):
    assert ']==]' not in text
    return '--[==[ v204 진단 임시 중지. 아래 원문은 복구용으로 보존한다.\n' + text + '\n]==]'


def mute_body(text, signature, result=''):
    start = text.index(signature + '\n') + len(signature) + 1
    end = text.index('\nend', start)
    assert text[end + 4:end + 5] in ('', '\n')
    return text[:start] + comment(text[start:end]) + ('\n  ' + result if result else '') + text[end:]


def patch(read):
    changes = {}

    def get(name):
        return changes.get(name, read(name).decode('utf8').replace('\r\n', '\n'))

    s = get(NATIVE)
    changes[NATIVE] = once(s, '''  japi.FrameClearAllPoints(japi.FrameGetChatMessage())
  japi.FrameSetAbsolutePoint(japi.FrameGetChatMessage(), 8, 1, 1)''', '''  local frame = japi.FrameGetChatMessage()
  if not frame or frame == 0 then return end
  -- 새 메시지가 표시 상태를 복구해도 기본 채팅 글자는 보이지 않게 한다.
  japi.FrameSetAlpha(frame, 0)
  japi.FrameShow(frame, false)
  japi.FrameClearAllPoints(frame)
  japi.FrameSetAbsolutePoint(frame, 8, 2, 2)''')

    s = get(CHAT)
    s = once(s, 'local slots = {}', '''local ui = require("hera_compat").installed.ui
local slots = {}''')
    s = once(s, 'game.register_event({\n  on_mouse_down', 'local input = {\n  on_mouse_down')
    s = once(s, '  on_key_down = function(code)\n', '''  on_key_down = function(code)
    if not IsWindowActive() then
      down, used = {}, {}
      cancel_recording()
      return
    end
''')
    s = once(s, 'if not japi.GetKeyState(key) then', 'if not ui.IsKeyDown(key) then')
    s = once(s, '  on_key_up = function(code)\n', '''  on_key_up = function(code)
    if not IsWindowActive() then
      down, used = {}, {}
      cancel_recording()
      return
    end
''')
    s = once(s, '''  end
})
local trigger = CreateTrigger()''', '''  end
}
-- 창 이벤트와 JASS 입력이 함께 와도 같은 down/used 상태로 중복 전송을 막는다.
game.register_event(input)
local trigger = CreateTrigger()''')
    s = once(s, 'status:set_text("전송에 실패했습니다. 로그를 확인하세요.")',
             'status:set_text("전송에 실패했습니다. 잠시 후 다시 시도하세요.")')
    s += '\nreturn input\n'
    changes[CHAT] = s

    s = get('hera_button_input.lua')
    changes['hera_button_input.lua'] = once(s, '''      left_player = player_id
      drag.down(mouse_focus())''', '''      left_player = player_id
      local chat = package.loaded["gameplay.interface.ui.chat_tool"]
      if type(chat) == "table" then chat.on_mouse_down() end
      drag.down(mouse_focus())''')

    s = get('hera_ui_bridge.lua')
    changes['hera_ui_bridge.lua'] = once(s, '  function ui.FrameGetChatMessage()', '''  function ui.IsKeyDown(code)
    return invoke(53, {IntA=code}) ~= 0
  end
  function ui.FrameGetChatMessage()''')

    s = get('war3map.j')
    s = once(s, 'function HeraUIBridgeEmojiDown takes nothing returns nothing\n', '''// 외침 도구에 필요한 키를 기존 로컬 Dz 입력 경로로 전달한다.
function HeraChatToolKeyDown takes nothing returns nothing
    local string result = EXExecuteScript("(function() local m=package.loaded['gameplay.interface.ui.chat_tool']; if type(m)=='table' then m.on_key_down(" + I2S(DzGetTriggerKey()) + ") end; return '' end)()")
endfunction

function HeraChatToolKeyUp takes nothing returns nothing
    local string result = EXExecuteScript("(function() local m=package.loaded['gameplay.interface.ui.chat_tool']; if type(m)=='table' then m.on_key_up(" + I2S(DzGetTriggerKey()) + ") end; return '' end)()")
endfunction

function HeraUIBridgeEmojiDown takes nothing returns nothing
''')
    s = once(s, '''    local string result = EXExecuteScript("require('hera_emoji_input').key_down()")
''', '''    local string result = EXExecuteScript("require('hera_emoji_input').key_down()")
    call HeraChatToolKeyDown()
''')
    s = once(s, '''    local string result = EXExecuteScript("require('hera_emoji_input').key_up()")
''', '''    local string result = EXExecuteScript("require('hera_emoji_input').key_up()")
    call HeraChatToolKeyUp()
''')
    s = once(s, 'function HeraUIBridgeInitialize takes nothing returns nothing\n',
             'function HeraUIBridgeInitialize takes nothing returns nothing\n    local integer key = 8\n')
    s = once(s, '''        call DzTriggerRegisterKeyEventByCode(null, 84, 0, false, function HeraUIBridgeEmojiUp)
''', '''        call DzTriggerRegisterKeyEventByCode(null, 84, 0, false, function HeraUIBridgeEmojiUp)
        loop
            exitwhen key > 254
            if key != 84 then
                call DzTriggerRegisterKeyEventByCode(null, key, 1, false, function HeraChatToolKeyDown)
                call DzTriggerRegisterKeyEventByCode(null, key, 0, false, function HeraChatToolKeyUp)
            endif
            set key = key + 1
        endloop
''')
    s = once(s, '''    elseif HeraUIBridgeOperation == 52 then
        call DzFrameSetFocus(HeraUIBridgeIntA, HeraUIBridgeBoolA)''', '''    elseif HeraUIBridgeOperation == 52 then
        call DzFrameSetFocus(HeraUIBridgeIntA, HeraUIBridgeBoolA)
    elseif HeraUIBridgeOperation == 53 then
        if DzIsKeyDown(HeraUIBridgeIntA) then
            set HeraUIBridgeResult = 1
        endif''')
    s = once(s, '// 진단 로그는 유지하며 패널은 -hera 명령으로만 연다.',
             '// 진단 출력은 주석 처리하고 수동 -hera 상태 조회는 보존한다.')
    changes['war3map.j'] = s

    # 기능이 섞인 모듈에서는 기록 함수의 본문만 비활성화한다.
    muted = {
        'hera_boot.lua': [('local function save()', ''), ('local function note(text, important)', ''),
                          ('local function runtime_error(err)', '')],
        'hera_trace_ring.lua': [('function M.new(path, limit)', 'return {write=function() return true end}')],
        'hera_startup_trace.lua': [('function M.flush()', ''), ('function M.install()', ''),
                                  ('function M.start_flush()', '')],
        'hera_gameplay_diagnostic.lua': [('function M.monster(stage, values)', ''),
            ('function M.phase(stage, values)', ''), ('function M.local_input(kind, handle, detail)', ''),
            ('function M.command(kind, handle, detail)', ''),
            ('function M.track_damage(apply_damage)', 'return apply_damage'), ('function M.install()', '')],
        'hera_desync_diagnostic.lua': [('function M.ui_receive(stage, player, message)', 'return true'),
            ('function M.snapshot(reason)', 'return true'), ('function M.event(kind, detail)', 'return true'),
            ('function M.install()', ''), ('function M.runtime(stage, detail)', 'return true'),
            ('function M.item(stage, item, detail)', 'return true'),
            ('function guard.trace(stage, npc, detail)', 'return true'), ('function guard.snapshot(group)', '')],
        'hera_ui_trace.lua': [(x, '') for x in [
            'function M.install(common)', 'function M.label_frame(frame, label)',
            'function M.forget_frame(frame)', 'function M.item_hover(place, slot, item)',
            'function M.target_change(kind, handle)', 'function M.begin_event(frame, event, player)',
            'function M.end_event(previous, ok, result)', 'function M.before(operation, arguments)',
            'function M.after(ticket, ok, result)']],
        'hera_move_trace.lua': [(x, '') for x in ['function M.begin_steps(u)',
            'function M.step(ctx, stage, detail)', 'function M.note(stage, u, detail)',
            'function M.effect(stage, kind, name)']],
        'hera_callback_probe.lua': [('function M.before(callback)', 'return -1, -1'),
                                  ('function M.after(ctx, callback, before_id, before_count)', '')],
        'scripts/jh/base/handle_ref.lua': [
            ('function handle_ref.unit_event(stage, h, g, detail, history)', 'return history')],
        'scripts/system/util/basicfunc.lua': [
            ('local function stack_boundary(stage, item, target, value)', '')],
        'scripts/system/bootstrap/debug_console.lua': [('function M.enable()', '')],
        'scripts/jh/base/runtime.lua': [('function runtime.error_handle(msg)', ''),
                                     ('function printf(format, ...)', '')],
        'scripts/jh/base/utility.lua': [('local function warning(msg)', '')],
        'scripts/test.lua': [('function print(...)', '')],
    }
    for name, bodies in muted.items():
        s = get(name)
        for signature, result in bodies:
            s = mute_body(s, signature, result)
        changes[name] = s

    s = get('hera_boot.lua')
    s = once(s, '''    print = function(...)
      local values = {}
      for i = 1, select("#", ...) do values[i] = tostring(select(i, ...)) end
      note("PRINT " .. table.concat(values, " "))
    end''', '''    print = function(...)
      -- v204 진단 임시 중지. 출력 인자의 변환도 수행하지 않는다.
      -- local values = {}
      -- for i = 1, select("#", ...) do values[i] = tostring(select(i, ...)) end
      -- note("PRINT " .. table.concat(values, " "))
    end''')
    changes['hera_boot.lua'] = s
    s = get('scripts/jh/base/runtime.lua')
    start, end = s.index('if console.enable then'), s.index('runtime.handle_level = 0')
    changes['scripts/jh/base/runtime.lua'] = s[:start] + comment(s[start:end]) + '\n' + s[end:]
    s = get('scripts/jh/base/utility.lua')
    changes['scripts/jh/base/utility.lua'] = once(s, 'print = console.write', '-- print = console.write -- v204 진단 임시 중지.')
    s = get('scripts/jh/base/log.lua')
    first, rest = s.split('\n', 1)
    changes['scripts/jh/base/log.lua'] = first + '\n' + comment(rest) + '''
-- 기존 호출부는 유지하고 파일·콘솔 기록만 중지한다.
local function silent(...) end
log = {debug=silent, info=silent, warn=silent, error=silent, fatal=silent}
print = silent
'''
    return {name: (value.replace('\n', '\r\n') if b'\r\n' in read(name) else value).encode('utf8')
            for name, value in changes.items()}
