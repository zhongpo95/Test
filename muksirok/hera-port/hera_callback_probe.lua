-- 실제 Lua-JASS 콜백 등록 테이블을 변경하지 않고 검사 전후를 기록한다.
local M = {}
local registry = debug and debug.getregistry and debug.getregistry()
local seq = 0
local writer
local failed = false
local function callback_table()
  local t = registry and rawget(registry, "_JASS_CALLBACK_TABLE")
  return type(t) == "table" and t or nil
end
function M.before(callback)
  local t = callback_table()
  if not t then return -1, -1 end
  return rawget(t, callback) or 0, rawlen(t)
end
function M.after(ctx, callback, before_id, before_count)
  if failed or not ctx then return end
  local t = callback_table()
  local after_id = t and rawget(t, callback) or -1
  local after_count = t and rawlen(t) or -1
  seq = seq + 1
  local f
  local ok = pcall(function()
    local runtime = require("jass.runtime")
    local line = "seq=" .. seq .. " clock=" .. tostring(ac.clock()) .. " move=" .. ctx.id .. " step=" .. ctx.step ..
      " unit=" .. tostring(ctx.unit) .. " owner=" .. tostring(GetPlayerId(GetOwningPlayer(ctx.unit)) + 1) ..
      " before_id=" .. tostring(before_id) .. " after_id=" .. tostring(after_id) ..
      " before_count=" .. tostring(before_count) .. " after_count=" .. tostring(after_count) ..
      " delta=" .. tostring(after_count - before_count) .. " sleep=" .. tostring(runtime.sleep) ..
      " runtime=" .. tostring(runtime.version) .. "\n"
    if not writer then writer = require("hera_trace_ring").new("Logs/Hera_RPG_Callback_v160_p" .. tostring(GetPlayerId(GetLocalPlayer()) + 1) .. ".txt") end
    writer.write(line)
  end)
  if not ok then
    failed = true
    if f then pcall(function() f:close() end) end
    local boot = package.loaded.hera_boot
    if boot and boot.note then boot.note("CALLBACK PROBE LOG FAILED", true) end
  end
end
return M
