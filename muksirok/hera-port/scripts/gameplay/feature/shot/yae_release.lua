-- 야에 사쿠라의 로컬 E 해제 요청을 모든 클라이언트에서 같은 영웅 명령으로 처리한다.
local japi = require("jass.japi")
local boot = require("hera_boot")
local M = {}
local prefix = "HeraYaeE"
-- 설치 JN의 Dz 동기화 접두사는 최대 9바이트다.
assert(#prefix <= 9, "YAE_RELEASE_PREFIX_TOO_LONG")
local token = "E_UP"
local release_order = 852138
local trace_count = 0

local function trace(text)
  if trace_count < 40 then
    trace_count = trace_count + 1
    boot.note("YAE RELEASE " .. text, true)
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
  -- H02F는 야에의 공중 형태이므로 입력·비행 처리와 같은 원래 영웅 종류를 확인한다.
  if not u:isvalid() or u.type ~= HeroType["八重樱"] or not u:isalive()
      or not u:hasdata("八重樱拔刀斩蓄力")
      or u:hasdata("八重樱拔刀斩蓄力取消")
      or GetUnitAbilityLevel(hero, S2ID("A1S0")) == 0 then
    trace("ignored p=" .. sy .. " inactive")
    return
  end
  trace("SYNC BEGIN p=" .. sy .. " order=" .. release_order)
  -- 기존 A1S0 시전 이벤트가 충전 해제 플래그를 설정하도록 유지한다.
  local accepted = IssueImmediateOrderById(hero, release_order)
  trace("SYNC END p=" .. sy .. " accepted=" .. tostring(accepted))
end)
trace("REGISTERED prefix=" .. prefix)

function M.request()
  trace("LOCAL SEND")
  japi.DzSyncData(prefix, token)
end

return M
