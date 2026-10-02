-- 미나토의 로컬 V 입력을 동기화한 뒤 소유자의 가방에서 기존 소환술을 실행한다.
local japi = require("jass.japi")
local boot = require("hera_boot")
local M = {}
local prefix = "HeraMinV"
-- 설치 JN의 Dz 동기화 접두사는 최대 9바이트다.
assert(#prefix <= 9, "MINATO_SUMMON_PREFIX_TOO_LONG")
local token = "V_DOWN"
local summon_order = 852050
local trace_count = 0

local function trace(text)
  if trace_count < 40 then
    trace_count = trace_count + 1
    boot.note("MINATO SUMMON " .. text, true)
  end
end

local trigger = CreateTrigger()
japi.DzTriggerRegisterSyncData(trigger, prefix, false)
TriggerAddAction(trigger, function()
  local data = japi.DzGetTriggerSyncData()
  local sender = japi.DzGetTriggerSyncPlayer()
  local sy = GetConvertedPlayerId(sender)
  trace("SYNC RECEIVE p=" .. sy .. " data=" .. tostring(data))
  if data ~= token then return end
  if sy < 1 or sy > 6 or not Xuanze or not Xuanze[sy] then return end
  local hero = Hero and Hero[sy]
  if not hero or hero == 0 or GetOwningPlayer(hero) ~= sender then return end
  local u = getunit(hero)
  if not u or not u:isvalid() or u.type ~= HeroType["波风水门"] or not u:isalive()
      or u:hasdata("波风水门-通灵之术冷却")
      or u:hasdata("茉子-兽化状态") then
    trace("ignored p=" .. sy .. " inactive")
    return
  end
  local bag = Beibao and Beibao[sy]
  if not bag or bag == 0 or GetUnitTypeId(bag) == 0 or GetOwningPlayer(bag) ~= sender
      or GetUnitAbilityLevel(bag, S2ID("A0KQ")) <= 0 then
    trace("ignored p=" .. sy .. " bag")
    return
  end
  trace("SYNC BEGIN p=" .. sy .. " order=" .. summon_order)
  -- 기존 A0KQ 시전 이벤트가 소환 효과와 쿨다운을 그대로 처리한다.
  local accepted = IssueImmediateOrderById(bag, summon_order)
  trace("SYNC END p=" .. sy .. " accepted=" .. tostring(accepted))
end)
trace("REGISTERED prefix=" .. prefix)

function M.request()
  trace("LOCAL SEND")
  japi.DzSyncData(prefix, token)
end

return M
