-- 초기 난수와 객체 생성의 기존 반환값을 슬롯별 파일에 기록하며 추가 호출은 하지 않는다.
local M = {}
local rows, installed, timer_started, path = {}, false, false
local limit, dirty, active = 4096, false, false
function M.flush()
  if not dirty or not path then return end
  local ok = pcall(function()
    local file = io.open(path, "wb")
    if not file then return end
    file:write(table.concat(rows, "\n") .. "\n")
    file:close()
  end)
  if ok then dirty = false end
end
function M.install()
  if installed then return end
  installed = true
  local common = require("jass.common")
  local japi = require("jass.japi")
  path = "Logs/Hera_RPG_Trace_v160_p" .. tostring(common.GetPlayerId(common.GetLocalPlayer()) + 1) .. ".txt"
  local get_id = common.GetHandleId
  local function value(v)
    if type(v) == "userdata" then return tostring(get_id(v)) end
    return tostring(v)
  end
  for _, name in ipairs({"GetRandomInt", "GetRandomReal", "SetRandomSeed", "CreateUnit", "CreateItem", "CreateTimer", "CreateTrigger", "CreateGroup", "CreateSound"}) do
    local preferred = _G[name] or japi[name] or common[name]
    local function wrap(original)
      return function(...)
        if active or #rows >= limit then return original(...) end
        active = true
        local result = table.pack(pcall(original, ...))
        active = false
        if not result[1] then error(result[2], 0) end
        local args = {}
        for i = 1, select("#", ...) do args[i] = value(select(i, ...)) end
        local info = debug.getinfo(2, "Sl") or {}
        rows[#rows + 1] = tostring(#rows + 1) .. " " .. name .. "(" .. table.concat(args, ",") .. ")=" .. value(result[2]) .. " @" .. tostring(info.short_src) .. ":" .. tostring(info.currentline)
        dirty = true
        return table.unpack(result, 2, result.n)
      end
    end
    if type(common[name]) == "function" then rawset(common, name, wrap(common[name])) end
    if type(preferred) == "function" then _G[name] = wrap(preferred) end
  end
end
function M.start_flush()
  if timer_started then return end
  timer_started = true
  M.flush()
  ac.loop(100, function(t)
    M.flush()
    if ac.clock() >= 5000 then
      limit = #rows
      t:remove()
    end
  end)
end
return M
