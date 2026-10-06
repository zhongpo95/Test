-- 기본 버튼의 배치 좌표와 마우스 초점을 함께 읽어 설명창 진입과 이탈을 연결한다.
local M = {enters=0, leaves=0, commands=0, focus=0, geometry=0}
local items, commands = {}, {}
local rectangles = {}
local previous, selected, selected_item, timer
local ui
local command_tooltip = require('hera_command_tooltip')

function M.layout(frame, x, y, width, height)
  if frame == 0 then return end
  rectangles[frame] = {left=x-width/2, right=x+width/2, top=y-height/2, bottom=y+height/2}
end

local function rectangle_focus(focus)
  if items[focus] or commands[focus] then return focus end
  -- 커스텀 버튼이 위에 올라와 있을 때 그 아래 기본 버튼 설명을 열지 않는다.
  local buttons = class and class.button and class.button.button_map
  if buttons and buttons[focus] then return 0 end
  if not game or not game.get_mouse_pos then return 0 end
  local x, y = game.get_mouse_pos()
  for frame, rect in pairs(rectangles) do
    if (items[frame] or commands[frame]) and x >= rect.left and x <= rect.right and y >= rect.top and y <= rect.bottom then
      return frame
    end
  end
  return 0
end

local function record(text)
  local boot = package.loaded['hera_boot']
  if boot and boot.note and M.enters + M.commands <= 40 then boot.note(text) end
end

local function notify(frame, event)
  local callback = items[frame] and items[frame][event]
  if not callback then return end
  local ok, err = xpcall(callback, debug.traceback)
  if not ok then
    local boot = package.loaded['hera_boot']
    if boot and boot.record_runtime_error then boot.record_runtime_error(err) end
  end
end

function M.tick()
  local japi = require('jass.japi')
  local active = not IsWindowActive or IsWindowActive()
  local focus = active and ui.GetMouseFocus() or 0
  local unit = active and japi.GetRealSelectUnit() or 0
  M.focus = focus
  local raw_focus = focus
  focus = active and rectangle_focus(focus) or 0
  local item
  if items[focus] and unit ~= 0 and UnitItemInSlot then item = UnitItemInSlot(unit, items[focus].slot) end
  if focus ~= previous or unit ~= selected or item ~= selected_item then
    if items[previous] then
      M.leaves = M.leaves + 1
      notify(previous, 3)
    end
    if commands[previous] then
      command_tooltip.hide()
      ui.FrameShow(ui.FrameGetTooltip(), false)
    end
    previous, selected, selected_item = focus, unit, item
    if focus ~= 0 and raw_focus ~= focus then
      M.geometry = M.geometry + 1
      record('NATIVE RECT ENTER frame=' .. focus .. ' raw_focus=' .. tostring(raw_focus))
    end
    if items[focus] and unit ~= 0 then
      M.enters = M.enters + 1
      record('NATIVE ITEM ENTER frame=' .. focus .. ' unit=' .. unit)
      notify(focus, 2)
    elseif commands[focus] and unit ~= 0 then
      M.commands = M.commands + 1
      record('NATIVE COMMAND ENTER frame=' .. focus .. ' unit=' .. unit)
    end
  end
  -- 엔진이 채운 기본 설명은 실제 명령 버튼을 가리키는 동안에만 표시한다.
  if commands[focus] and unit ~= 0 then
    local tooltip = rawget(_G, 'YuanshengTooltip')
    if not tooltip or tooltip.enabled then
      local slot = commands[focus]
      local custom = command_tooltip.update(unit, slot.column, slot.row)
      ui.FrameShow(ui.FrameGetTooltip(), not custom)
    else
      command_tooltip.hide()
    end
  end
end

function M.register(frame, event, callback)
  if event ~= 2 and event ~= 3 then return false end
  ui = ui or require('hera_ui_bridge').bind()
  local japi = require('jass.japi')
  local inventory
  for slot = 0, 5 do
    if frame ~= 0 and frame == japi.DzFrameGetItemBarButton(slot) then inventory = slot; break end
  end
  if inventory == nil then return false end
  items[frame] = items[frame] or {slot=inventory}
  items[frame][event] = callback
  if not timer then
    for row = 0, 2 do
      for column = 0, 3 do
        local button = ui.FrameGetCommandBarButton(row, column)
        if button ~= 0 then commands[button] = {row=row, column=column} end
      end
    end
    timer = ac.loop(30, M.tick)
  end
  return true
end

function M.summary()
  return 'Native hover = item ' .. M.enters .. '; leave ' .. M.leaves .. '; command ' .. M.commands .. '; rect ' .. M.geometry .. '; raw ' .. tostring(M.focus)
end
return M
