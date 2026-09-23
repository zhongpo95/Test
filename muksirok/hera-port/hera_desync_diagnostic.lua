-- 이탈과 게임 종료 전후의 상태를 게임 동작 변경 없이 별도 순환 로그에 보존한다.
local M = {}
local writer
local ui_writer
local function write(kind, detail)
  if not writer then
    local build = require('hera_build_info')
    local version = tostring(build.revision):gsub('[^%w]', '_')
    writer = require('hera_trace_ring').new('Logs/Hera_RPG_Desync_v' .. version .. '_p' ..
      tostring(GetPlayerId(GetLocalPlayer()) + 1) .. '.txt')
  end
  return writer.write('clock=' .. tostring(ac.clock()) .. ' wall=' .. os.date('%Y-%m-%dT%H:%M:%S') ..
    ' kind=' .. kind .. ' ' .. (detail or ''))
end

function M.ui_receive(stage, player, message)
  return pcall(function()
    if not ui_writer then
      local version = tostring(require('hera_build_info').revision):gsub('[^%w]', '_')
      ui_writer = require('hera_trace_ring').new('Logs/Hera_RPG_UISync_v' .. version .. '_p' ..
        tostring(GetPlayerId(GetLocalPlayer()) + 1) .. '.txt')
    end
    ui_writer.write('clock=' .. tostring(ac.clock()) .. ' stage=' .. stage ..
      ' sender=' .. tostring(GetPlayerId(player) + 1) .. ' payload=' ..
      tostring(message):gsub('\r', '\\r'):gsub('\n', '\\n'))
  end)
end

function M.snapshot(reason)
  return pcall(function()
    local parts = {'reason=' .. reason, 'wave=' .. tostring(Stage), 'players=' .. tostring(PlayerCount),
      'monsters=' .. tostring(AllNumofMonster), 'left=' .. tostring(LeftNumofMonster)}
    for slot = 1, 6 do
      local h = Hero and Hero[slot]
      local kind = h and h ~= 0 and GetUnitTypeId(h) or 0
      local values = {'slot=' .. slot, 'selected=' .. tostring(Xuanze and Xuanze[slot]),
        'native_state=' .. tostring(GetPlayerSlotState(Player(slot - 1))), 'type=' .. kind}
      if kind ~= 0 then
        values[#values + 1] = 'hp=' .. GetWidgetLife(h)
        values[#values + 1] = 'mp=' .. GetUnitState(h, UNIT_STATE_MANA)
        values[#values + 1] = 'x=' .. GetUnitX(h)
        values[#values + 1] = 'y=' .. GetUnitY(h)
        values[#values + 1] = 'order=' .. GetUnitCurrentOrder(h)
        values[#values + 1] = 'stamina=' .. tostring(Hero_Tili and Hero_Tili[slot])
        for index = 0, 5 do
          local item = UnitItemInSlot(h, index)
          values[#values + 1] = 'item' .. index .. '=' ..
            tostring(item and item ~= 0 and GetItemTypeId(item) or 0) .. '/' ..
            tostring(item and item ~= 0 and GetItemCharges(item) or 0)
        end
      end
      parts[#parts + 1] = '[' .. table.concat(values, ' ') .. ']'
    end
    write('STATE', table.concat(parts, ' '))
  end)
end

function M.event(kind, detail)
  -- 진단 실패가 퇴장/패배 처리의 실행을 막지 않도록 전체를 보호한다.
  local ok = pcall(function()
    write(kind, detail)
    require('hera_boot').note('LIFECYCLE ' .. kind .. ' clock=' .. tostring(ac.clock()) ..
      ' ' .. (detail or ''), true)
  end)
  M.snapshot(kind)
  return ok
end

function M.install()
  local build = require('hera_build_info')
  M.event('INSTALL', 'revision=' .. tostring(build.revision) .. ' title=' .. tostring(build.title))
end

return M
