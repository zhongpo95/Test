-- 생성되는 모든 커스텀 버튼의 네이티브 입력을 원래 이벤트와 동기화 큐로 보낸다.
local M = {bound=0, clicks=0, enters=0, leaves=0, downs=0, ups=0, fallback_downs=0}
local bound = {}
local drag = require("hera_frame_drag")
local hovered
local left_player
_G.HERA_NATIVE_RIGHT_INPUT = true
local right_pressed
local right_held = false
local right_log_counts = {}
function M.trace_right(stage, detail)
  local count = (right_log_counts[stage] or 0) + 1
  right_log_counts[stage] = count
  local boot = package.loaded["hera_boot"]
  if count <= 40 and boot and boot.note then
    pcall(boot.note, "UI RIGHT " .. stage .. " " .. tostring(detail), true)
  end
end
local function current(button, frame)
  return button._id == frame and class.button.button_map[frame] == button
end
local function valid(button, frame)
  return current(button, frame) and button.is_enable ~= false and button:get_is_show()
end
local function note(button, event)
  local boot = package.loaded["hera_boot"]
  if boot and boot.note and M.clicks + M.downs <= 120 then
    boot.note("UI INPUT " .. event .. " frame=" .. tostring(button._id) ..
      " key=" .. tostring(button.sync_key) .. " image=" .. tostring(button.normal_image))
  end
end
local function mouse_down(button, fallback)
  button.is_down = true
  M.downs = M.downs + 1
  if fallback then M.fallback_downs = M.fallback_downs + 1 end
  note(button, fallback and "down-from-up" or "down")
  if button.active_image and button.active_image ~= "" then button:set_active_image(button.active_image) end
  button:event_notify("on_button_mousedown")
end
local function mouse_focus()
  if not class or not class.button then return nil end
  local japi = require("jass.japi")
  local frame = japi.GetMouseFocus()
  local button = class.button.button_map[frame]
  if button and valid(button, frame) then return button end
  -- 자식 텍스트나 장식 프레임에 초점이 있을 때 마지막 진입 버튼을 사용한다.
  if hovered and hovered.is_enter and valid(hovered, hovered._id) then return hovered end
  return nil
end
function M.dispatch_right(is_down, player_id)
  local ok, err = xpcall(function()
    if not class or not class.button then return end
    local button = mouse_focus()
    if is_down then
      if right_held then return end
      right_held = true
      right_pressed = button and {button=button, frame=button._id, player=player_id} or nil
      M.trace_right("down", button and button.sync_key or "no-button")
      if button then button:event_notify("on_button_right_mousedown") end
    else
      local pressed = right_pressed
      right_pressed, right_held = nil, false
      if not pressed then return end
      local original = pressed.button
      if pressed.player ~= player_id or not valid(original, pressed.frame) then
        M.trace_right("cancel", "stale/hidden/disabled/player")
        return
      end
      original:event_notify("on_button_right_mouseup")
      if button ~= original or not valid(original, pressed.frame) then
        M.trace_right("cancel", "released-outside")
        return
      end
      M.trace_right("click", original.sync_key)
      original:event_notify("on_button_right_clicked")
    end
  end, debug.traceback)
  if not ok then M.trace_right("error", err) end
  return ""
end
-- 실제 왼쪽 누름과 뗌만 드래그에 전달하고 보통 클릭은 프레임 이벤트에 맡긴다.
function M.dispatch_left(is_down, player_id)
  local ok, err = xpcall(function()
    if not class or not class.button then return end
    if is_down then
      left_player = player_id
      drag.down(mouse_focus())
    else
      local original_player = left_player
      left_player = nil
      if original_player == nil then return end
      if original_player ~= player_id then drag.cancel(); return end
      drag.up(mouse_focus())
    end
  end, debug.traceback)
  if not ok then
    drag.cancel()
    local boot = package.loaded["hera_boot"]
    if boot and boot.record_runtime_error then pcall(boot.record_runtime_error, err) end
  end
  return ""
end
function M.bind_button(button)
  local frame = button._id
  if not frame or frame == 0 or bound[frame] == button then return end
  local japi = require("jass.japi")
  japi.FrameSetScriptByCode(frame, 1, function(id)
    if right_held or drag.suppresses(button) or not valid(button, id) then return end
    M.clicks = M.clicks + 1
    note(button, "click")
    button:event_notify("on_button_clicked")
    if not current(button, id) then return end
    local time = os.clock()
    if button._click_time and time - button._click_time <= 0.3 then
      button:event_notify("on_button_double_clicked")
    end
    button._click_time = time
  end, false)
  japi.FrameSetScriptByCode(frame, 2, function(id)
    if not valid(button, id) then return end
    hovered = button
    if button.is_enter then return end
    button.is_enter = true
    M.enters = M.enters + 1
    if button.hover_image and button.hover_image ~= "" then button:set_hover_image(button.hover_image) end
    button:event_notify("on_button_mouse_enter")
  end, false)
  japi.FrameSetScriptByCode(frame, 3, function(id)
    if not current(button, id) or not button.is_enter then return end
    if hovered == button then hovered = nil end
    button.is_enter, button.is_down = false, false
    if right_pressed and right_pressed.button == button then right_pressed = nil end
    M.leaves = M.leaves + 1
    button:set_normal_image(button.normal_image)
    button:event_notify("on_button_mouse_leave")
  end, false)
  japi.FrameSetScriptByCode(frame, 4, function(id)
    if not current(button, id) or drag.suppresses(button) then return end
    if not valid(button, id) then button.is_down = false; return end
    -- 이 환경의 GLUETEXTBUTTON은 이벤트 5 없이 4만 보내므로 누름 콜백을 한 번 보충한다.
    if not button.is_down then mouse_down(button, true) end
    if not current(button, id) then return end
    button.is_down = false
    if not valid(button, id) then return end
    M.ups = M.ups + 1
    if button.is_enter and button.hover_image and button.hover_image ~= "" then
      button:set_hover_image(button.hover_image)
    else
      button:set_normal_image(button.normal_image)
    end
    button:event_notify("on_button_mouseup")
  end, false)
  japi.FrameSetScriptByCode(frame, 5, function(id)
    if not valid(button, id) then return end
    mouse_down(button, false)
  end, false)
  japi.FrameSetEnable(frame, button.is_enable ~= false)
  bound[frame] = button
  M.bound = M.bound + 1
end
function M.unbind_button(button)
  drag.cancel(button)
  if hovered == button then hovered = nil end
  if right_pressed and right_pressed.button == button then right_pressed = nil end
  if bound[button._id] == button then
    bound[button._id] = nil
    M.bound = M.bound - 1
  end
  button.is_enter, button.is_down = false, false
end
function M.bind()
  for _, button in pairs(class.button.button_map) do M.bind_button(button) end
  assert(M.bound > 0, "HERA_UI_BUTTONS_NOT_FOUND")
  drag.install()
  return M.bound
end
function M.summary()
  return "UI input = buttons " .. M.bound .. "; click " .. M.clicks .. "; down " .. M.downs ..
    "; up " .. M.ups .. "; enter " .. M.enters .. "; leave " .. M.leaves .. "; fallback " .. M.fallback_downs
end
return M
