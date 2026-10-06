-- 회피 상태와 추가 효과 이름을 제한된 횟수만 슬롯별 부트 로그에 기록한다.
local M = {}
local step_failed = false
local step_count = 0
local step_writer
local move_count = 0
M.context = nil
function M.begin_steps(u)
  if not Hero or Hero[u.ownerid] ~= u.handle then return nil end
  move_count = move_count + 1
  return {id=move_count, step=0, unit=u.handle, unit_type=u.type}
end
function M.step(ctx, stage, detail)
  -- v160는 이동 시작과 종료만 남겨 상세 파일 기록의 영향을 비교한다.
  if stage ~= "CREATE" and stage ~= "FINISH" then return end
  if not ctx or step_failed then return end
  local f
  local ok, err = pcall(function()
    local h = ctx.unit
    local line = "clock=" .. tostring(ac.clock()) .. " move=" .. ctx.id .. " step=" .. ctx.step ..
      " stage=" .. stage .. " type=" .. tostring(ctx.unit_type) .. " unit=" .. tostring(h) .. " owner=" .. tostring(GetPlayerId(GetOwningPlayer(h)) + 1) ..
      " x=" .. tostring(GetUnitX(h)) .. " y=" .. tostring(GetUnitY(h)) .. " facing=" .. tostring(GetUnitFacing(h)) ..
      " order=" .. tostring(GetUnitCurrentOrder(h)) .. " " .. (detail or "") .. "\n"
    if not step_writer then step_writer = require("hera_trace_ring").new("Logs/Hera_RPG_MoveSteps_v160_p" .. tostring(GetPlayerId(GetLocalPlayer()) + 1) .. ".txt") end
    step_writer.write(line)
    step_count = step_count + 1
  end)
  if not ok then
    step_failed = true
    if f then pcall(function() f:close() end) end
    pcall(function()
      local boot = package.loaded["hera_boot"]
      if boot and boot.note then boot.note("MOVE STEP LOG FAILED stage=" .. tostring(stage) .. " error=" .. tostring(err), true) end
    end)
  end
end
local function note(text)
  require("hera_gameplay_diagnostic").phase("MOVE_EFFECT", {detail=text})
end
function M.note(stage, u, detail)
  local x, y = u:getxy()
  note(stage .. " unit=" .. tostring(u.handle) .. " owner=" .. tostring(u.ownerid) .. " type=" .. tostring(u.type) .. " x=" .. tostring(x) .. " y=" .. tostring(y) .. " face=" .. tostring(u:getface()) .. " stamina=" .. tostring(Hero_Tili[u.ownerid]) .. " " .. detail)
end
function M.effect(stage, kind, name)
  M.step(M.context, "EFFECT_" .. stage, "kind=" .. tostring(kind) .. " name=" .. tostring(name))
  note("EFFECT " .. stage .. " kind=" .. tostring(kind) .. " name=" .. tostring(name))
end
return M
