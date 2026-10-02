-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local ui = require("jh.ui.client.util")
local queue = game.sync_queue
local sync_key_map = {}
ac.sync_key_map = sync_key_map
local RETIRED_CONTROL_GRACE_TICKS = 20
local retired_control_ticks = {}

local function find(t, list)
  for name, value in pairs(t) do
    table.insert(list, {name, value})
  end
  local mt = getmetatable(t)
  if mt then
    local it = mt.__index
    if it and type(it) == "table" then
      find(it, list)
    end
  end
end

function apairs(tbl)
  local list = {}
  find(tbl, list)
  local i = 0
  return function()
    i = i + 1
    local info = list[i]
    if info then
      return table.unpack(info)
    end
  end
end

local function control_has_func(control, func_name)
  local object = control
  while object ~= nil do
    if object[func_name] then
      return true
    end
    object = object.parent
  end
  return false
end

local function seach_sync_func(control)
  for name, func in apairs(control) do
    if type(func) == "function" and name:find("on_sync_") then
      ui.add_str(name)
    end
  end
  if control.parent then
    seach_sync_func(control.parent)
  end
end

local function update_hashtable()
  for key, button in pairs(sync_key_map) do
    if button._id == nil or button._id == 0 then
      local ticks = (retired_control_ticks[key] or 0) + 1
      retired_control_ticks[key] = ticks
      if ticks > RETIRED_CONTROL_GRACE_TICKS then
        sync_key_map[key] = nil
        retired_control_ticks[key] = nil
      end
    else
      retired_control_ticks[key] = nil
    end
  end
  for _, button in pairs(class.button.button_map) do
    local key = button.sync_key
    local registered = key and sync_key_map[key]
    if key and (registered == nil or registered._id == nil or registered._id == 0) then
      sync_key_map[key] = button
      retired_control_ticks[key] = nil
      ui.add_str(key)
      seach_sync_func(button)
    end
  end
end

setmetatable(queue, {
  __newindex = function(self, index, first)
    local control = first.control
    local func_name = "on_sync_" .. first.event_name:sub(4, -1)
    for i = 1, first.count do
      local value = first.args[i]
      if type(value) == "table" then
        if value.sync_key then
          first.args[i] = {
            ui.get_hash(value.sync_key)
          }
        else
          first.args[i] = nil
        end
      elseif type(value) == "function" then
        first.args[i] = nil
      end
    end
    local has = control_has_func(control, func_name)
    if has then
      rawset(self, index, first)
    end
  end
})

local function update_queue()
  update_hashtable()
  if #queue == 0 then
    return
  end
  local first = queue[1]
  table.remove(queue, 1)
  local control = first.control
  local func_name = "on_sync_" .. first.event_name:sub(4, -1)
  local info = {
    type = "sync",
    func_name = "on_sync",
    params = {
      [1] = ui.get_hash(control.sync_key),
      [2] = ui.get_hash(func_name),
      [3] = first.args,
      [4] = first.sync_data
    }
  }
  if func_name == "on_sync_button_right_clicked" then
    require("hera_button_input").trace_right("send", control.sync_key)
  end
  ui.send_message(info)
end

game.loop(150, update_queue)
