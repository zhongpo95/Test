-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local hook = require("jass.hook")
local japi = require("jass.japi")
local message = require("jass.message")
local error_handle = require("jass.runtime").error_handle
local dbg = require("jass.debug")
local base

local function log(tag, ...)
  print(("[ClientEvent][%s] "):format(tag), ...)
end

local function is_window_active()
  if type(IsWindowActive) == "function" then
    return IsWindowActive() ~= false
  end
  if japi and type(japi.IsWindowActive) == "function" then
    return japi.IsWindowActive() ~= false
  end
  return true
end

local boardKeyList = {}
local boardKeyHash = {}
local boardKeyMapping = {}
local Class = {}
setmetatable(Class, Class)
Class.isActive = true
local width, height = 0, 0
local pointer
local left_is_down = false
local left_alt_down = false
local left_button_list = {}
local right_button_list = {}
local right_is_down = false
local button_enter_event_list = {}
local button_leave_event_list = {}
local is_active = true
local clock = os.clock()
local texture
local world_controls = {}
local ht = InitHashtable()

local function get_handle_type(handle)
  if handle == nil or handle == 0 then
    return nil
  end
  if GetHandleId(handle) == 1048576 then
    return nil
  end
  local retval
  RemoveSavedHandle(ht, 1, 1)
  SaveFogStateHandle(ht, 1, 1, handle)
  if LoadItemHandle(ht, 1, 1) ~= nil and LoadItemHandle(ht, 1, 1) ~= 0 then
    retval = 1
  elseif LoadUnitHandle(ht, 1, 1) ~= nil and LoadUnitHandle(ht, 1, 1) ~= 0 then
    retval = 2
  end
  RemoveSavedHandle(ht, 1, 1)
  return retval
end

local function game_event_callback(name, ...)
  local hash_table = {}
  local ret = false
  for index, event_table in ipairs(game.game_event) do
    local func = event_table[name]
    if func ~= nil and not ret then
      ret = func(...)
    end
  end
  return ret
end

game.sync_queue = {}
game.alt_click_enabled = false
game.game_event = {}

function game.register_event(module)
  table.insert(game.game_event, module)
end

function game.get_mouse_pos()
  local x = japi.GetMouseVectorX() / 1024
  local y = -(japi.GetMouseVectorY() - 768) / 768
  x = x * 1920
  y = y * 1080
  return x, y
end

function game.set_mouse_pos(x, y)
  x = x / 1920 * 1024
  y = 768 - y / 1080 * 768
  japi.SetMousePos(x, y)
end

function game.world_to_screen(x, y, z)
  local screen_x, screen_y, scale = message.world_to_screen(x, y, z)
  if screen_x and screen_y then
    return screen_x * 1920 / 0.8, screen_y * 1080 / 0.6, scale
  end
end

function game.screen_to_world(x, y)
  local screen_x, screen_y = x / 1920 * 0.8, y / 1080 * 0.6
  return message.screen_to_world(x, y)
end

function game.bind_world(control, enable)
  if enable then
    world_controls[control] = true
  else
    world_controls[control] = nil
  end
end

function game.add_event_sync(control, event_name, ...)
  table.insert(game.sync_queue, {
    control = control,
    event_name = event_name,
    args = {
      ...
    },
    count = select("#", ...),
    sync_data = control.sync_data
  })
end

game.wait(0, function()
  base.on_init()
end)
game.loop(0.03, function()
  local object = japi.GetTargetObject()
  if object ~= nil and object ~= pointer then
    local type = get_handle_type(pointer)
    if type == 1 then
      base.on_item_mouse_leave(pointer)
    elseif type == 2 then
      base.on_unit_mouse_leave(pointer)
    end
    type = get_handle_type(object)
    if type == 1 then
      base.on_item_mouse_enter(object)
    elseif type == 2 then
      base.on_unit_mouse_enter(object)
    end
    pointer = object
  end
  if is_window_active() == false and is_active == true then
    is_active = false
    if left_is_down or right_is_down then
      base.on_mouse_up()
      base.on_mouse_right_up()
    end
  else
    is_active = true
  end
end)
base = {
  on_mouse_down = function()
    if not is_window_active() then
      return
    end
    local id = japi.GetMouseFocus()
    local button = class.button.button_map[id]
    if button == nil then
      for id, btn in pairs(class.button.button_map) do
        if btn.is_enter and btn:get_is_show() then
          button = btn
          break
        end
      end
    end
    left_alt_down = game.alt_click_enabled and japi.GetKeyState(KEY.ALT) and not japi.GetChatState()
    if left_alt_down then
      left_is_down = false
      local native_consumed = game_event_callback("on_mouse_alt_click")
      if not native_consumed and button and button.is_enable then
        xpcall(button.event_callback, error_handle, button, "on_button_alt_click")
      end
      return true
    end
    left_is_down = true
    if button ~= nil then
      button.is_down = true
      if button.active_image and button.active_image ~= "" then
        button:set_active_image(button.active_image)
      end
      button:event_notify("on_button_mousedown")
      table.insert(left_button_list, button)
      if button.is_drag == true and button.is_enable then
        width, height = button.w, button.h
        game.wait(0.3, function()
          if left_is_down == true then
            if texture ~= nil then
              base.on_mouse_up()
            end
            local x, y = game.get_mouse_pos()
            texture = class.texture:builder({
              x = x - button.w / 2,
              y = y - button.h / 2,
              w = width,
              h = height,
              normal_image = button.normal_image,
              alpha = 0.8
            })
            texture.button = button
            button:event_notify("on_button_begin_drag")
          end
        end)
      end
    end
    local ret = game_event_callback("on_mouse_down")
    local handle = japi.GetTargetObject()
    local type = get_handle_type(handle)
    if type == 1 then
      ret = game_event_callback("on_item_mouse_down", handle) or ret
    else
      ret = type == 2 and game_event_callback("on_unit_mouse_down", handle) or ret
    end
    return ret
  end,
  on_mouse_up = function()
    if not is_window_active() then
      return
    end
    if left_alt_down then
      left_alt_down = false
      left_is_down = false
      return true
    end
    local id = japi.GetMouseFocus()
    local button = class.button.button_map[id]
    left_is_down = false
    local x, y = game.get_mouse_pos()
    if button == nil then
      for id, btn in pairs(class.button.button_map) do
        if btn.is_enter and btn:get_is_show() then
          button = btn
          break
        end
      end
    end
    if texture ~= nil then
      if button == texture.button then
        for id, btn in pairs(class.button.button_map) do
          if btn.is_enter and btn:get_is_show() and btn ~= texture.button then
            button = btn
            break
          end
        end
      end
      if button == texture.button then
        texture.button:event_notify("on_button_drag_and_drop", nil, x, y)
      else
        texture.button:event_notify("on_button_drag_and_drop", button, x, y)
      end
      texture:destroy()
      texture = nil
    end
    for index, object in ipairs(left_button_list) do
      object.is_down = nil
      if object.is_enter and object.hover_image and object.hover_image ~= "" then
        object:set_hover_image(object.hover_image)
      else
        object:set_normal_image(object.normal_image)
      end
      if object ~= button then
        object:event_notify("on_button_mouseup")
      else
        if object.is_enable and object:point_in_rect(x, y) then
          object:event_notify("on_button_clicked")
          local time = os.clock()
          if object._click_time and time - object._click_time <= 0.3 then
            object:event_notify("on_button_double_clicked")
          end
          object._click_time = time
        end
        object:event_notify("on_button_mouseup")
      end
    end
    left_button_list = {}
    local ret = game_event_callback("on_mouse_up")
    local handle = japi.GetTargetObject()
    local type = get_handle_type(handle)
    if type == 1 then
      ret = game_event_callback("on_item_mouse_up", handle) or ret
      ret = game_event_callback("on_item_clicked", handle) or ret
    elseif type == 2 then
      ret = game_event_callback("on_unit_mouse_up", handle) or ret
      ret = game_event_callback("on_unit_clicked", handle) or ret
    end
    return ret
  end,
  on_mouse_right_down = function()
    if _G.HERA_NATIVE_RIGHT_INPUT then return end
    if not is_window_active() then
      return
    end
    local id = japi.GetMouseFocus()
    local button = class.button.button_map[id]
    right_is_down = true
    if button ~= nil and not button.is_enable then
      button = nil
    end
    if button == nil then
      for id, btn in pairs(class.button.button_map) do
        if btn.is_enter and btn:get_is_show() and btn.is_enable then
          button = btn
          break
        end
      end
    end
    if button ~= nil then
      button:event_notify("on_button_right_mousedown")
      table.insert(right_button_list, button)
    end
    return game_event_callback("on_mouse_right_down")
  end,
  on_mouse_right_up = function()
    if _G.HERA_NATIVE_RIGHT_INPUT then return end
    if not is_window_active() then
      return
    end
    local id = japi.GetMouseFocus()
    local button = class.button.button_map[id]
    right_is_down = false
    if button == nil then
      for id, btn in pairs(class.button.button_map) do
        if btn.is_enter and btn:get_is_show() then
          button = btn
          break
        end
      end
    end
    for index, object in ipairs(right_button_list) do
      if object ~= button then
        object:event_notify("on_button_right_mouseup")
      else
        object:event_notify("on_button_right_mouseup")
        object:event_notify("on_button_right_clicked")
      end
    end
    right_button_list = {}
    local ret
    local handle = japi.GetTargetObject()
    local type = get_handle_type(handle)
    if type == 1 then
      ret = game_event_callback("on_item_right_clicked", handle) or ret
    else
      ret = type == 2 and game_event_callback("on_unit_right_clicked", handle) or ret
    end
    ret = game_event_callback("on_mouse_right_up") or ret
    return ret
  end,
  on_mouse_move = function()
    if not is_window_active() then
      return
    end
    local x, y = game.get_mouse_pos()
    if texture ~= nil then
      local button = texture.button
      texture:set_position(x - texture.w / 2, y - texture.h / 2)
      button:event_notify("on_button_update_drag", texture, x - button.w / 2, y - button.h / 2)
    end
    for id, button in pairs(class.button.button_map) do
      local ox, oy = button:get_real_position()
      if x >= ox and y >= oy and x <= ox + button.w and y <= oy + button.h then
        local is_show = button:get_is_show() ~= false
        if button.is_enter == nil and is_show then
          button.is_enter = true
          table.insert(button_enter_event_list, button)
        end
        if button.is_enter and is_show and button.is_move_event then
          button:event_notify("on_button_mouse_move", x, y)
        end
      elseif button.is_enter == true then
        table.insert(button_leave_event_list, button)
        button.is_enter = nil
      end
    end
    if 0 < #button_leave_event_list then
      class.ui_base.remove_tooltip()
    end
    for i = #button_leave_event_list, 1, -1 do
      local button = button_leave_event_list[i]
      button:event_notify("on_button_mouse_leave")
      table.remove(button_leave_event_list, i)
      if button.is_down and button.active_image and button.active_image ~= "" then
        button:set_active_image(button.active_image)
      else
        button:set_normal_image(button.normal_image)
      end
    end
    for i = #button_enter_event_list, 1, -1 do
      local button = button_enter_event_list[i]
      button:event_notify("on_button_mouse_enter")
      table.remove(button_enter_event_list, i)
      if button.hover_image and button.hover_image ~= "" then
        button:set_hover_image(button.hover_image)
      else
        button:set_normal_image(button.normal_image)
      end
    end
    game_event_callback("on_mouse_move")
  end,
  on_mouse_wheeldelta = function()
    if not is_window_active() then
      return
    end
    local x = japi.GetMouseVectorX() / 1024
    local y = -(japi.GetMouseVectorY() - 768) / 768
    x = x * 1920
    y = y * 1080
    for id, panel in pairs(class.panel.panel_map) do
      local ox, oy = panel:get_real_position()
      if panel.is_scroll and x >= ox and y >= oy and x <= ox + panel.w and y <= oy + panel.h then
        local bool = japi.GetWheelDelta() > 0
        local y = panel.scroll_y or 0
        if bool then
          if 0 < y then
            y = y - (panel.scroll_interval_y or 10)
          end
        elseif y + panel.h < panel:get_child_max_y() then
          y = y + (panel.scroll_interval_y or 10)
        end
        panel.scroll_y = y
        panel:event_notify("on_panel_scroll", bool)
        panel:event_notify("on_panel_scroll_fix", bool)
      end
    end
    return game_event_callback("on_mouse_wheeldelta", japi.GetWheelDelta() > 0)
  end,
  on_key_down = function()
    if not is_window_active() then
      return
    end
    local code = japi.GetTriggerKey()
    local str = KEY_STR[code]
    if str then
      if not japi.GetChatState() and not boardKeyHash[str] then
        boardKeyHash[str] = true
        boardKeyList[#boardKeyList + 1] = str
      end
      for id, button in pairs(class.button.button_map) do
        if button.is_enable and button.keys and (button:get_is_show() or button.hide_has_event) then
          for index, key in ipairs(button.keys) do
            if key == str then
              button:event_notify("on_button_key_down", str)
              break
            end
          end
        end
      end
    end
    return game_event_callback("on_key_down", code)
  end,
  on_key_up = function(keyStr)
    if not is_window_active() then
      return
    end
    local code = japi.GetTriggerKey()
    local str = keyStr or KEY_STR[code]
    if str then
      for id, button in pairs(class.button.button_map) do
        if button.is_enable and button.keys and (button:get_is_show() or button.hide_has_event) then
          for index, key in ipairs(button.keys) do
            if key == str then
              button:event_notify("on_button_key_up", str)
              break
            end
          end
        end
      end
      local i = 1
      local max = #boardKeyList
      while i <= max do
        if boardKeyList[i] == str then
          table.remove(boardKeyList, i)
          i = i - 1
          max = max - 1
        end
        i = i + 1
      end
      boardKeyHash[str] = nil
    end
    return game_event_callback("on_key_up", code)
  end,
  on_item_mouse_enter = function(item_handle)
    if not is_window_active() then
      return
    end
    game_event_callback("on_item_mouse_enter", item_handle)
  end,
  on_item_mouse_leave = function(item_handle)
    if not is_window_active() then
      return
    end
    game_event_callback("on_item_mouse_leave", item_handle)
  end,
  on_unit_mouse_enter = function(unit_handle)
    if not is_window_active() then
      return
    end
    game_event_callback("on_unit_mouse_enter", unit_handle)
  end,
  on_unit_mouse_leave = function(unit_handle)
    if not is_window_active() then
      return
    end
    game_event_callback("on_unit_mouse_leave", unit_handle)
  end,
  on_update_window_size = function()
    game_event_callback("on_update_window_size")
  end,
  on_update = function()
    if not is_window_active() then
      return
    end
    local c = os.clock()
    local delta = c - clock
    clock = c
    base.on_mouse_move()
    game_event_callback("on_update", delta)
    for control in pairs(world_controls) do
      local unit = control.world_unit
      local x, y, z
      if unit then
        if unit.removed then
          if control.world_auto_remove then
            control:destroy()
          else
            control:hide()
          end
          goto lbl_124
        elseif not (not unit.hide_life_bar and unit:is_alive()) or unit:has_restriction("隐藏") or not unit:is_visible(ac.player.self) then
          control:hide()
          goto lbl_124
        else
          local p = unit:get_point()
          x, y = p:get()
          z = p:getZ()
          z = z + unit:get_height()
          z = z + message.unit_overhead(unit.handle)
        end
      else
        x, y, z = control.world_x, control.world_y, control.world_z
      end
      local screen_x, screen_y, scale = game.world_to_screen(x, y, z)
      if screen_x == nil or screen_x < 0 or screen_y < 32 or 1920 < screen_x or 1080 < screen_y then
        control:hide()
      else
        control:show()
        local x = screen_x - control.w + (control.offect_x or 0)
        local y = screen_y - control.h + (control.offect_y or 0)
        control:set_real_position(x, y, control.world_anchor)
      end
      ::lbl_124::
    end
  end,
  on_init = function()
    game_event_callback("on_init")
  end
}
local event = {
  base.on_mouse_down,
  base.on_mouse_up,
  base.on_mouse_right_down,
  base.on_mouse_right_up,
  base.on_mouse_move,
  base.on_mouse_wheeldelta,
  base.on_key_down,
  base.on_key_up,
  base.on_update_window_size,
  base.on_update
}

local function flush_mouse_leave()
  for _, button in pairs(class.button.button_map) do
    if button.is_enter then
      button.is_enter = nil
      table.insert(button_leave_event_list, button)
    end
  end
  if 0 < #button_leave_event_list then
    class.ui_base.remove_tooltip()
  end
  for i = #button_leave_event_list, 1, -1 do
    local button = button_leave_event_list[i]
    button:event_notify("on_button_mouse_leave")
    table.remove(button_leave_event_list, i)
    if button.is_down and button.active_image and button.active_image ~= "" then
      button:set_active_image(button.active_image)
    else
      button:set_normal_image(button.normal_image)
    end
  end
end

local eventIds = event

function _G.WindowEventCallBack(eventId)
  local x = japi.GetMouseVectorX() / 1024
  local y = -(japi.GetMouseVectorY() - 768) / 768
  if not japi.IsWindowMode() then
    local func = eventIds[eventId]
    if func ~= nil then
      local _, ret = xpcall(func, error_handle)
      return ret
    end
    return false
  else
    if not is_window_active() or x < 0 or 1 < x or y < 0 or 1 < y then
      if not Class.isActive then
        goto lbl_90
      end
      flush_mouse_leave()
      Class.isActive = false
      if not japi.GetChatState() then
        for index = 1, #boardKeyList do
          local key = boardKeyList[index]
          if key == nil then
            break
          end
          boardKeyMapping[index] = key
        end
        for index = 1, #boardKeyMapping do
          local key = boardKeyMapping[index]
          boardKeyMapping[index] = nil
          if key == nil then
            break
          end
          base.on_key_up(key)
        end
      end
      if left_is_down then
        base.on_mouse_up()
      end
      if right_is_down then
        base.on_mouse_right_up()
      end
      if eventId ~= 8 and eventId ~= 9 then
        return false
      end
    elseif not Class.isActive then
      Class.isActive = true
    end
    ::lbl_90::
    local func = eventIds[eventId]
    if func ~= nil then
      local _, ret = xpcall(func, error_handle)
      return ret
    end
  end
end

local frame_event = {
  [9] = function(frame, id)
    local edit = class.edit.edit_map[frame]
    if edit == nil then
      return
    end
    local text = edit:get_text()
    if edit.text ~= text then
      local old_text = edit.text
      edit.text = text
      edit:event_notify("on_edit_text_changed", text, old_text)
    end
  end
}

function FrameEventCallBack(frame, id)
  if frame_event[id] then
    xpcall(frame_event[id], error_handle, frame, id)
  end
end

return game
