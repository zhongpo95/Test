-- 고정 JASS 트리거로 엔진 진단을 호출하고 연결 실패는 한 번만 보고한다.
local M = {}
local common = require("jass.common")
local globals = require("jass.globals")
local failed, announced = false, false
local function block(reason)
  if failed then return false end
  failed = true
  local boot = package.loaded.hera_boot
  if boot and boot.note then boot.note("ENGINE PROBE BLOCKED " .. tostring(reason), true) end
  if common.DisplayTimedTextToPlayer then
    common.DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 15, "[v136] 엔진 진단 연결 실패. 테스트를 중단하고 로그를 확인해주세요.")
  end
  return false
end
local function invoke(phase, ctx)
  if failed then return false end
  local ok, result = pcall(function()
    assert(globals.HeraEngineProbeEvaluator and globals.HeraEngineProbeEvaluator ~= 0, "JASS evaluator missing")
    globals.HeraEngineProbePhase = phase
    globals.HeraEngineProbeResult = 0
    if phase == 1 then
      globals.HeraEngineProbeClock = ac.clock()
      globals.HeraEngineProbeMove = ctx and ctx.id or 0
      globals.HeraEngineProbeStep = ctx and ctx.step or 0
    end
    common.TriggerEvaluate(globals.HeraEngineProbeEvaluator)
    return globals.HeraEngineProbeResult
  end)
  if not ok or result ~= 1 then return block(result) end
  return true
end
function M.begin(ctx)
  if failed then return false end
  if not announced then
    announced = true
    local boot = package.loaded.hera_boot
    if boot and boot.note then boot.note("ENGINE PROBE v136 JASS bridge attempt", true) end
  end
  return invoke(1, ctx)
end
function M.finish() return invoke(2) end
return M
