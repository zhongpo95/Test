-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local japi = require("jass.japi")

function GCreturn()
  collectgarbage("collect")
end

local function print_private_bytes()
  local private_bytes = japi.GetUsedMemory2()
  if 980 <= private_bytes then
    print(("War3内存占用: %.2f MB"):format(private_bytes))
  end
end

if type(japi.GetUsedMemory2) == "function" then
  ac.loop(10000, print_private_bytes)
else
  require("hera_boot").note("DEFERRED GetUsedMemory2: process-memory display unavailable; Lua GC remains active")
end
ac.loop(30000, function()
  GCreturn()
end)
local DESYNC_PROBE_PREFIX = "DesyncRngProbe"
local DESYNC_VALUE_PREFIX = "DesyncRngValue"
local DESYNC_REPORT_PREFIX = "DesyncRngReport"
local probe_sequence = 0
local local_probe_values = {}
local pending_host_values = {}
local report_sent = false
local desync_announced = false

local function selected_host_id()
  local host_id = tonumber(SeletPlayerID) or 0
  if host_id < 1 or 6 < host_id then
    return nil
  end
  return host_id
end

local function report_mismatch(sequence, local_value, host_value)
  if report_sent then
    return
  end
  report_sent = true
  ac.wait(0, function()
    japi.DzSyncData(DESYNC_REPORT_PREFIX, ("%d|%d|%d"):format(sequence, local_value, host_value))
  end)
end

local function compare_probe(sequence, host_value)
  local local_value = local_probe_values[sequence]
  if local_value == nil then
    pending_host_values[sequence] = host_value
    return
  end
  local_probe_values[sequence] = nil
  pending_host_values[sequence] = nil
  if local_value ~= host_value then
    report_mismatch(sequence, local_value, host_value)
  end
end

local function register_desync_probe()
  if not (japi.DzTriggerRegisterSyncData and japi.DzSyncData and japi.DzGetTriggerSyncData) or not japi.DzGetTriggerSyncPlayer then
    return
  end
  local probe_trigger = CreateTrigger()
  japi.DzTriggerRegisterSyncData(probe_trigger, DESYNC_PROBE_PREFIX, false)
  TriggerAddAction(probe_trigger, function()
    local host_id = selected_host_id()
    local sender_id = GetConvertedPlayerId(japi.DzGetTriggerSyncPlayer())
    local sequence = tonumber(japi.DzGetTriggerSyncData())
    if not host_id or sender_id ~= host_id or not sequence then
      return
    end
    local local_value = GetRandomInt(1, 100)
    local_probe_values[sequence] = local_value
    if pending_host_values[sequence] ~= nil then
      compare_probe(sequence, pending_host_values[sequence])
    end
    local stale_sequence = sequence - 12
    local_probe_values[stale_sequence] = nil
    pending_host_values[stale_sequence] = nil
    if LocalPlayerID == host_id then
      ac.wait(0, function()
        japi.DzSyncData(DESYNC_VALUE_PREFIX, ("%d|%d"):format(sequence, local_value))
      end)
    end
  end)
  local value_trigger = CreateTrigger()
  japi.DzTriggerRegisterSyncData(value_trigger, DESYNC_VALUE_PREFIX, false)
  TriggerAddAction(value_trigger, function()
    local host_id = selected_host_id()
    local sender_id = GetConvertedPlayerId(japi.DzGetTriggerSyncPlayer())
    local sequence_text, value_text = (japi.DzGetTriggerSyncData() or ""):match("^(%d+)|(%d+)$")
    local sequence = tonumber(sequence_text)
    local host_value = tonumber(value_text)
    if not (host_id and sender_id == host_id and sequence and host_value) or host_value < 1 or 100 < host_value then
      return
    end
    compare_probe(sequence, host_value)
  end)
  local report_trigger = CreateTrigger()
  japi.DzTriggerRegisterSyncData(report_trigger, DESYNC_REPORT_PREFIX, false)
  TriggerAddAction(report_trigger, function()
    if desync_announced then
      return
    end
    local sequence_text, local_text, host_text = (japi.DzGetTriggerSyncData() or ""):match("^(%d+)|(%d+)|(%d+)$")
    local sequence = tonumber(sequence_text)
    local local_value = tonumber(local_text)
    local host_value = tonumber(host_text)
    if not (sequence and local_value and host_value) or local_value < 1 or 100 < local_value or host_value < 1 or 100 < host_value then
      return
    end
    desync_announced = true
    local reporter_id = GetConvertedPlayerId(japi.DzGetTriggerSyncPlayer())
    print(("[DESYNC_CHECK] mismatch player=%d sequence=%d local=%d host=%d"):format(reporter_id, sequence, local_value, host_value))
    SendMsgAll(("|cFFFF0000[分车检测] 已分车：玩家%d随机校验不一致|r"):format(reporter_id), 60)
  end)
  ac.loop(10000, function()
    local host_id = selected_host_id()
    if not host_id or LocalPlayerID ~= host_id then
      return
    end
    probe_sequence = probe_sequence + 1
    japi.DzSyncData(DESYNC_PROBE_PREFIX, tostring(probe_sequence))
  end)
end

register_desync_probe()
