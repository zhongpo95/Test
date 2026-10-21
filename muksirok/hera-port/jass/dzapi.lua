-- 복원 RPG의 Dz 이벤트 등록을 검증한 Lua와 JASS 연결 경로에 전달한다.
local M = {}
local ui

function M.DzFrameSetScriptByCode(frame, event, callback, sync)
  if not sync and require("hera_native_tooltip").register(frame, event, callback) then return end
  ui = ui or require("hera_ui_bridge").bind()
  return ui.FrameSetScriptByCode(frame, event, callback, sync)
end

return M
