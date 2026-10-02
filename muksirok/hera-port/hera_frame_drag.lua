-- 로컬 버튼의 이동 잠금과 기존 드래그 콜백을 네이티브 마우스 입력에 연결한다.
local M = {}
local japi = require("jass.japi")
local capture
local suppressed
local installed = false

local function report(err)
  local boot = package.loaded["hera_boot"]
  if boot and type(boot.record_runtime_error) == "function" then
    pcall(boot.record_runtime_error, "UI drag: " .. tostring(err))
  end
end

local function attempt(callback)
  local ok, result = xpcall(callback, debug.traceback)
  if not ok then report(result) end
  return ok, result
end

local function current(button, frame)
  return button and frame and frame ~= 0 and button._id == frame and
    class and class.button and class.button.button_map[frame] == button
end

local function visible(button, frame)
  return current(button, frame) and button.is_enable ~= false and button:get_is_show()
end

local function active()
  if type(IsWindowActive) == "function" then return IsWindowActive() ~= false end
  if japi and type(japi.IsWindowActive) == "function" then return japi.IsWindowActive() ~= false end
  return true
end

local function valid(state)
  return visible(state.button, state.frame) and state.button.is_drag == true and active()
end

local function finish(state, notify_up)
  if state.finished then return end
  state.finished = true
  if capture == state then capture = nil end
  if state.timer then
    local timer = state.timer
    state.timer = nil
    if type(timer.remove) == "function" then attempt(function() timer:remove() end) end
  end
  if state.ghost then
    local ghost = state.ghost
    state.ghost = nil
    attempt(function() ghost:destroy() end)
  end
  -- 드래그 전의 누름 상태와 이미지는 원래 프레임 입력 콜백이 정리한다.
  if not state.started then return end
  local button = state.button
  if current(button, state.frame) then
    button.is_down = false
    attempt(function() button:set_alpha(state.alpha) end)
    attempt(function()
      if button.is_enter and button.hover_image and button.hover_image ~= "" then
        button:set_hover_image(button.hover_image)
      else
        button:set_normal_image(button.normal_image)
      end
    end)
    if notify_up and current(button, state.frame) then
      attempt(function() button:event_notify("on_button_mouseup") end)
    end
  end
end

function M.cancel(button)
  local state = capture
  if not state or button and state.button ~= button then return false end
  finish(state, state.started)
  return true
end

function M.suppresses(button)
  return button ~= nil and suppressed == button
end

function M.update()
  local state = capture
  if not state then return end
  local ok = attempt(function()
    if not valid(state) then
      finish(state, state.started)
      return
    end
    if not state.started then return end
    local button = state.button
    local ghost = state.ghost
    if not ghost or not ghost._id or ghost._id == 0 then
      finish(state, true)
      return
    end
    local x, y = game.get_mouse_pos()
    ghost:set_position(x - ghost.w / 2, y - ghost.h / 2)
    button:event_notify("on_button_update_drag", ghost, x - button.w / 2, y - button.h / 2)
    if capture == state and not valid(state) then finish(state, true) end
  end)
  if not ok then finish(state, state.started) end
end

function M.down(button)
  M.cancel()
  suppressed = nil
  if not button then return false end
  local state = {button=button, frame=button._id, alpha=button.alpha or 1}
  local ok, accepted = attempt(function()
    if not valid(state) then return false end
    capture = state
    state.timer = game.wait(300, function()
      state.timer = nil
      if capture ~= state then return end
      local started = attempt(function()
        if not valid(state) then
          finish(state, false)
          return
        end
        state.started = true
        suppressed = button
        local x, y = game.get_mouse_pos()
        state.ghost = class.texture:builder({
          x = x - button.w / 2,
          y = y - button.h / 2,
          w = button.w,
          h = button.h,
          normal_image = button.normal_image,
          alpha = 0.8
        })
        assert(state.ghost, "drag texture was not created")
        state.ghost.button = button
        button:event_notify("on_button_begin_drag")
        if capture == state then M.update() end
      end)
      if not started then finish(state, state.started) end
    end)
    return true
  end)
  if not ok then finish(state, state.started) end
  return ok and accepted or false
end

function M.up(target)
  local state = capture
  if not state then return false end
  if not state.started then
    finish(state, false)
    return false
  end
  M.update()
  if capture ~= state then return true end
  attempt(function()
    local button = state.button
    if target == button or not target or not visible(target, target._id) then target = nil end
    local x, y = game.get_mouse_pos()
    button:event_notify("on_button_drag_and_drop", target, x, y)
  end)
  finish(state, true)
  return true
end

function M.install()
  if installed then return end
  game.loop(30, M.update)
  installed = true
end

return M
