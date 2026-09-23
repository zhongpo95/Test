-- UI 동기화 메시지를 헤라 Dz 경로로 연결하고 진단용 왕복 수신을 기록한다.
local ui = require("jh.ui.server.util")
local japi = require("jass.japi")
local boot = require("hera_boot")
local state = {registered=false, sent=false, received=0, sender=-1}
local probe = '{{t="hera_transport_probe_v4",f="empty",p={}}}'
local trg = CreateTrigger()
local ok, err = pcall(function()
  japi.DzTriggerRegisterSyncData(trg, "ui", false)
  TriggerAddAction(trg, function()
    local message = japi.DzGetTriggerSyncData()
    local player = japi.DzGetTriggerSyncPlayer()
    if message == probe then
      state.received = state.received + 1
      state.sender = GetPlayerId(player)
      boot.note("UI SYNC diagnostic received; player=" .. state.sender .. " count=" .. state.received)
    else
      require('hera_desync_diagnostic').ui_receive('BEGIN', player, message)
      ui.on_custom_ui_event(player, message)
      require('hera_desync_diagnostic').ui_receive('END', player, message)
    end
  end)
end)
if not ok then
  DestroyTrigger(trg)
  error(err, 0)
end
state.registered = true
-- 설치 JN 선언의 최대 데이터 길이는 998바이트이며 초과한 메시지는 잘라 보내지 않는다.
rawset(japi, "SendCustomMessage", function(message)
  assert(type(message) == "string" and #message <= 998, "HERA_UI_SYNC_SIZE: expected string up to 998 bytes")
  japi.DzSyncData("ui", message)
end)
boot.note("UI SYNC registered; original UI codec and callback retained")
-- 초기 UI 등록 중에는 자동 진단 패킷을 보내지 않는다.
boot.note("UI SYNC automatic startup probe disabled")

return state
