-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local jass = require("jass.common")
local storm = require("jass.storm")
local japi = require("jass.japi")
local slots = {}
local edits = {}
local bindings = {}
local binding_buttons = {}
local entry_button
local entry_x, entry_y = 1515, 18
local recording
local down, used = {}, {}
local focused_edit
local loading = true
local save_path = "tloc_chat_tool.txt"
local panel = class.panel:builder({
  x = 1380,
  y = 110,
  w = 520,
  h = 560,
  _type = "tooltip_backdrop"
})
panel:set_level(5)
panel:hide()
local status = class.text:builder({
  parent = panel,
  x = 18,
  y = 525,
  w = 484,
  h = 24,
  text = "변경 사항은 자동 저장됩니다. 창을 닫아도 단축키를 사용할 수 있습니다.",
  font_size = 11
})

local function save_slots()
  local lines = {}
  for i = 1, 10 do
    lines[i] = slots[i]
    lines[i + 11] = table.concat(bindings[i], ",")
  end
  lines[11] = entry_button.x .. "," .. entry_button.y
  local ok, result = pcall(storm.save, save_path, table.concat(lines, "\n"))
  if not ok or result == false then
    status:set_text("저장에 실패했습니다. 로컬 파일 쓰기 권한을 확인하세요.")
    print("[喊话工具] 保存失败", result)
  else
    status:set_text("외침 문구, 단축키, 버튼 위치를 저장했습니다.")
  end
end

local ok, content = pcall(storm.load, save_path)
if not ok then
  print("[喊话工具] 读取失败", content)
  content = nil
end
local lines = {}
if type(content) == "string" then
  for line in (content .. "\n"):gmatch("(.-)\n") do
    lines[#lines + 1] = line:gsub("\r$", "")
    if #lines == 21 then
      break
    end
  end
end
local saved_x, saved_y = (lines[11] or ""):match("^(%d+%.?%d*),(%d+%.?%d*)$")
if saved_x and saved_y then
  entry_x = math.min(1872, tonumber(saved_x))
  entry_y = math.min(1042, tonumber(saved_y))
end
for i = 1, 10 do
  slots[i] = lines[i] or ""
  bindings[i] = {
    KEY.ALT,
    48 + i % 10
  }
  local first, second = (lines[i + 11] or ""):match("^(%d+),?(%d*)$")
  first, second = tonumber(first), tonumber(second)
  if first and 8 <= first and first <= 254 and first ~= KEY.ESC and (not second or 8 <= second and second <= 254 and second ~= KEY.ESC and second ~= first) then
    bindings[i] = {first, second}
    table.sort(bindings[i])
  end
end

local function binding_text(keys)
  local names = {}
  for i, code in ipairs(keys) do
    if 48 <= code and code <= 57 or 65 <= code and code <= 90 then
      names[i] = string.char(code)
    elseif code == KEY.ALT then
      names[i] = "Alt"
    elseif code == KEY.CTRL then
      names[i] = "Ctrl"
    elseif code == 16 then
      names[i] = "Shift"
    else
      names[i] = tostring(KEY_STR[code] or "키 " .. code)
    end
  end
  return table.concat(names, "+")
end

local function cancel_recording()
  if recording then
    binding_buttons[recording.slot].text:set_text(binding_text(bindings[recording.slot]))
    recording = nil
  end
end

local function send_slot(i)
  local text = slots[i]
  if text:match("^%s*$") then
    status:set_text("먼저 이 줄에 외칠 문구를 입력하세요.")
    return
  end
  if 255 < #text or text:find("[%z\r\n]") then
    status:set_text("한 줄은 255바이트 이하여야 하며 줄바꿈은 사용할 수 없습니다.")
    return
  end
  local sent, err = pcall(japi.DzSyncData, "ChatTool", text)
  if not sent then
    status:set_text("전송에 실패했습니다. 로그를 확인하세요.")
    print("[喊话工具] 发送失败", err)
  end
end

class.text:builder({
  parent = panel,
  x = 18,
  y = 12,
  w = 450,
  h = 24,
  text = "왼쪽에서 단축키를 기록하고(최대 2키), 오른쪽에서 문구를 편집합니다.",
  font_size = 13
})
class.button:builder({
  parent = panel,
  x = 480,
  y = 8,
  w = 28,
  h = 28,
  normal_image = "UI_Chat_Black.tga",
  text = {
    type = "text",
    text = "×",
    align = "center",
    font_size = 14
  },
  on_button_clicked = function()
    cancel_recording()
    focused_edit = nil
    for i = 1, 10 do
      edits[i]:set_focus(false)
    end
    panel:hide()
  end
})
for i = 1, 10 do
  local slot = i
  local y = 48 + (i - 1) * 47
  binding_buttons[i] = class.button:builder({
    parent = panel,
    x = 16,
    y = y,
    w = 106,
    h = 38,
    normal_image = "UI_Chat_Black.tga",
    text = {
      type = "text",
      text = binding_text(bindings[i]),
      align = "center",
      font_size = 12
    },
    on_button_clicked = function(self)
      cancel_recording()
      for n = 1, 10 do
        edits[n]:set_focus(false)
      end
      focused_edit = nil
      recording = {
        slot = slot,
        keys = {}
      }
      self.text:set_text("키 입력 대기…")
      status:set_text("한 키 또는 두 키를 누른 뒤 모두 놓으면 확정됩니다. Esc로 취소합니다.")
    end
  })
  local background = class.panel:builder({
    parent = panel,
    x = 132,
    y = y,
    w = 370,
    h = 38,
    _type = "tooltip_backdrop"
  })
  edits[i] = class.edit:builder({
    parent = background,
    x = 8,
    y = 3,
    w = 354,
    h = 32,
    text = slots[i],
    font_size = 12,
    on_edit_text_changed = function(self, text)
      if loading then
        return
      end
      if text:find("[%z\r\n]") then
        self:set_text(slots[i])
        status:set_text("외침 문구는 한 줄만 입력할 수 있습니다.")
        return
      end
      slots[i] = text
      save_slots()
    end
  })
end
loading = false
local dragged = false
entry_button = class.button:builder({
  x = entry_x,
  y = entry_y,
  w = 48,
  h = 38,
  normal_image = "ReplaceableTextures\\CommandButtons\\BTNReplay-Loop.blp",
  on_button_clicked = function()
    if dragged then
      return
    end
    cancel_recording()
    focused_edit = nil
    if panel:get_is_show() then
      for i = 1, 10 do
        edits[i]:set_focus(false)
      end
      panel:hide()
    else
      panel:show()
    end
  end,
  on_button_mousedown = function()
    dragged = false
  end,
  on_button_mouseup = function()
    dragged = false
  end,
  on_button_right_clicked = function(self)
    self:set_enable_drag(not self.is_drag)
    uiy_show_text(self.is_drag and "외침 도구. 드래그하여 이동할 수 있습니다.|n우클릭으로 위치를 잠급니다." or "외침 도구. 위치가 잠겼습니다.|n우클릭으로 이동을 허용합니다.")
  end,
  on_button_begin_drag = function()
    dragged = true
  end,
  on_button_update_drag = function(self, _, x, y)
    if self.is_drag then
      self:set_position(math.max(0, math.min(1872, x)), math.max(0, math.min(1042, y)))
    end
  end,
  on_button_drag_and_drop = function(self, _, x, y)
    if self.is_drag then
      self:set_position(math.max(0, math.min(1872, x - self.w / 2)), math.max(0, math.min(1042, y - self.h / 2)))
      save_slots()
    end
  end,
  on_button_mouse_enter = function(self)
    uiy_show_text(self.is_drag and "외침 도구. 드래그하여 이동할 수 있습니다.|n우클릭으로 위치를 잠급니다." or "외침 도구. 위치가 잠겼습니다.|n우클릭으로 이동을 허용합니다.")
  end,
  on_button_mouse_leave = function()
    uiy_hide()
  end
})
entry_button:set_enable_drag(false)
game.register_event({
  on_mouse_down = function()
    local focus = japi.GetMouseFocus()
    local edit
    for i = 1, 10 do
      if focus == edits[i]._id then
        edit = edits[i]
        break
      end
    end
    if focused_edit and focused_edit ~= edit then
      focused_edit:set_focus(false)
    end
    focused_edit = edit
    if edit then
      cancel_recording()
    end
  end,
  on_key_down = function(code)
    if code < 8 or 254 < code then
      return
    end
    if down[code] ~= nil then
      return
    end
    for key in pairs(down) do
      if not japi.GetKeyState(key) then
        down[key], used[key] = nil, nil
      end
    end
    down[code] = recording == nil and focused_edit == nil and not japi.GetChatState()
    used[code] = not down[code]
    if recording then
      if code == KEY.ESC then
        cancel_recording()
        status:set_text("기록을 취소하고 기존 단축키를 유지했습니다.")
        return
      end
      local keys = recording.keys
      if #keys < 2 then
        keys[#keys + 1] = code
        binding_buttons[recording.slot].text:set_text(binding_text(keys))
      else
        recording.invalid = true
        status:set_text("최대 두 키까지 지정할 수 있습니다. 이번 기록은 저장하지 않았습니다.")
      end
      return
    end
    if used[code] then
      return
    end
    local count = 0
    for key in pairs(down) do
      count = count + 1
      if key ~= code then
        used[key], used[code] = true, true
      end
    end
    if count ~= 2 then
      return
    end
    for i = 1, 10 do
      local keys = bindings[i]
      if #keys == 2 and down[keys[1]] and down[keys[2]] then
        send_slot(i)
        break
      end
    end
  end,
  on_key_up = function(code)
    local was_down, was_used = down[code], used[code]
    down[code], used[code] = nil, nil
    if recording then
      local keys = recording.keys
      if #keys == 0 or next(down) then
        return
      end
      if recording.invalid then
        cancel_recording()
        return
      end
      table.sort(keys)
      local slot = recording.slot
      for i = 1, 10 do
        if i ~= slot and bindings[i][1] == keys[1] and bindings[i][2] == keys[2] then
          cancel_recording()
          status:set_text("이 단축키는 " .. i .. "번 줄에서 사용 중입니다. 기존 설정을 유지했습니다.")
          return
        end
      end
      bindings[slot] = keys
      cancel_recording()
      save_slots()
      return
    end
    if was_down and not was_used and not focused_edit and not japi.GetChatState() then
      for i = 1, 10 do
        if #bindings[i] == 1 and bindings[i][1] == code then
          send_slot(i)
          break
        end
      end
    end
  end
})
local trigger = CreateTrigger()
japi.DzTriggerRegisterSyncData(trigger, "ChatTool", false)
TriggerAddAction(trigger, function()
  local text = japi.DzGetTriggerSyncData()
  if type(text) ~= "string" or 255 < #text or text:match("^%s*$") or text:find("[%z\r\n]") then
    return
  end
  local sender = japi.DzGetTriggerSyncPlayer()
  local p = getplayer(sender)
  japi.EXDisplayChat(sender, 0, text)
  p:dispatch_chat(text)
end)
local history = CreateTrigger()
for i = 0, 15 do
  jass.TriggerRegisterPlayerChatEvent(history, jass.Player(i), "", false)
end
TriggerAddAction(history, function()
  local text = GetEventPlayerChatString()
  if GetTriggerPlayer() ~= LocalPlayer or text:sub(1, 1) ~= "-" then
    return
  end
  for i = 1, 10 do
    if slots[i] == text then
      return
    end
  end
  loading = true
  table.remove(slots, 1)
  slots[10] = text
  for i = 1, 10 do
    edits[i]:set_text(slots[i])
  end
  loading = false
  save_slots()
end)
game.register_event(require("gameplay.interface.ui.icon_chat"))
