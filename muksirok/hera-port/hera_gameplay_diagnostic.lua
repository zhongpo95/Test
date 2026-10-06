-- 몬스터 생성과 휴식 종료 경로를 변경하지 않고 중단 상태를 기록한다.
local M = {}
local writers = {}
local function record(channel, text)
  local ok = pcall(function()
    if not writers[channel] then
      local slot = GetPlayerId(GetLocalPlayer()) + 1
      writers[channel] = require("hera_trace_ring").new("Logs/Hera_RPG_" .. channel .. "_v160_p" .. slot .. ".txt")
    end
    writers[channel].write(text)
  end)
  return ok
end
local function fields_text(values)
  local keys, parts = {}, {}
  for key in pairs(values or {}) do keys[#keys + 1] = key end
  table.sort(keys)
  for _,key in ipairs(keys) do parts[#parts + 1] = key .. "=" .. tostring(values[key]) end
  return table.concat(parts, " ")
end
function M.monster(stage, values)
  pcall(function()
    record("Monster", "clock=" .. tostring(ac.clock()) .. " stage=" .. stage .. " wave=" .. tostring(Stage) ..
      " monsters=" .. tostring(AllNumofMonster) .. " left=" .. tostring(LeftNumofMonster) ..
      " rest=" .. tostring(WaveStateText_Time) .. " " .. fields_text(values))
  end)
end
function M.phase(stage, values)
  pcall(function()
    record("Phase", "clock=" .. tostring(ac.clock()) .. " wave=" .. tostring(Stage) .. " stage=" .. stage .. " " .. fields_text(values))
  end)
end
local input_path
local input_count = 0
local command_count = 0
local function snapshot(handle)
  if not handle or handle == 0 then return "unit=0" end
  return "unit=" .. tostring(handle) .. " owner=" .. tostring(GetPlayerId(GetOwningPlayer(handle)) + 1) ..
    " type=" .. tostring(GetUnitTypeId(handle)) .. " x=" .. tostring(GetUnitX(handle)) ..
    " y=" .. tostring(GetUnitY(handle)) .. " facing=" .. tostring(GetUnitFacing(handle)) ..
    " current_order=" .. tostring(GetUnitCurrentOrder(handle))
end
local function input_note(kind, handle, detail)
  if not input_path then return end
  input_count = input_count + 1
  pcall(function()
    record("Input", "clock=" .. tostring(ac.clock()) .. " kind=" .. kind .. " " .. snapshot(handle) .. " " .. (detail or ""))
  end)
end
function M.local_input(kind, handle, detail)
  input_note("LOCAL " .. kind, handle, detail)
end
function M.command(kind, handle, detail)
  command_count = command_count + 1
  local sequence = command_count
  input_note("SYNC " .. kind, handle, "seq=" .. sequence .. " " .. (detail or ""))
  -- 진단 때문에 명령마다 지연 타이머 3개를 추가하지 않고 동기화 시점만 기록한다.
end
local combat = {hero_hits=0, monster_hits=0, spells=0, deaths=0, reduced=0}
function M.track_damage(apply_damage)
  return function(args)
    local target = args.unit and getunit(args.unit)
    local before = target and target:gethp()
    local result = apply_damage(args)
    local after = target and target:gethp()
    if before and after and after < before then combat.reduced = combat.reduced + 1 end
    local source_owner = args.source and GetPlayerId(GetOwningPlayer(args.source)) or -1
    local target_owner = args.unit and GetPlayerId(GetOwningPlayer(args.unit)) or -1
    if source_owner >= 0 and source_owner <= 5 then
      combat.hero_hits = combat.hero_hits + 1
      if combat.hero_hits <= 12 then
        require('hera_boot').note('COMBAT player damage source=' .. source_owner .. '; target=' .. target_owner ..
          '; requested=' .. tostring(args.damage) .. '; hp=' .. tostring(before) .. ' -> ' .. tostring(after))
      end
    elseif source_owner >= 8 and source_owner <= 11 then
      combat.monster_hits = combat.monster_hits + 1
    end
    return result
  end
end
local function state(timer)
  if type(timer) ~= 'table' then return 'missing' end
  if timer.removed then return 'removed' end
  return timer.pause_remaining ~= nil and 'paused' or 'running'
end
function M.summary()
  return 'Wave = ' .. tostring(Stage) .. '; rest=' .. tostring(WaveStateText_Time) ..
    '; monsters=' .. tostring(AllNumofMonster) .. '; left=' .. tostring(LeftNumofMonster) ..
    '; spawn=' .. state(attack_start) .. '\nCombat = player requests ' .. combat.hero_hits ..
    '; monster requests ' .. combat.monster_hits .. '; reduced ' .. combat.reduced ..
    '; spells ' .. combat.spells .. '; deaths ' .. combat.deaths ..
    '; kills=' .. tostring(KillCumCount and KillCumCount[1])
end
function M.install()
  M.monster("INSTALL", {})
  local boot = require('hera_boot')
  local japi = require('jass.japi')
  input_path = "Logs/Hera_RPG_Input_v160_p" .. tostring(GetPlayerId(GetLocalPlayer()) + 1) .. ".txt"
  M.phase("INSTALL", {local_time=os.date("%Y-%m-%d %H:%M:%S"), version="v160"})
  local order_trigger = war3.CreateTrigger(function()
    local handle = GetTriggerUnit()
    local event = GetTriggerEventId()
    local kind = "IMMEDIATE"
    local detail = "order=" .. tostring(GetIssuedOrderId())
    if event == EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER then
      kind = "POINT"
      detail = detail .. " target_x=" .. tostring(GetOrderPointX()) .. " target_y=" .. tostring(GetOrderPointY())
    elseif event == EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER then
      kind = "TARGET"
      detail = detail .. " target=" .. tostring(GetOrderTargetUnit())
    end
    M.command(kind, handle, detail)
  end)
  for i = 0, 5 do
    TriggerRegisterPlayerUnitEvent(order_trigger, Player(i), EVENT_PLAYER_UNIT_ISSUED_ORDER, nil)
    TriggerRegisterPlayerUnitEvent(order_trigger, Player(i), EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, nil)
    TriggerRegisterPlayerUnitEvent(order_trigger, Player(i), EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, nil)
  end
  boot.note("RUN INFO version=v160 local_time=" .. os.date("%Y-%m-%d %H:%M:%S") .. " utc=" .. os.date("!%Y-%m-%d %H:%M:%S"), true)
  for slot = 0, 5 do
    boot.note("ROSTER slot=" .. slot .. " name=" .. GetPlayerName(Player(slot)) .. " controller=" .. tostring(GetPlayerController(Player(slot))) .. " state=" .. tostring(GetPlayerSlotState(Player(slot))), true)
  end
  local spell_trigger = war3.CreateTrigger(function()
    M.command("SPELL", GetTriggerUnit(), "ability=" .. tostring(GetSpellAbilityId()))
    combat.spells = combat.spells + 1
    if combat.spells <= 1000 then
      boot.note('COMBAT spell=' .. tostring(GetSpellAbilityId()) .. '; unit=' .. tostring(GetTriggerUnit()) .. '; clock=' .. tostring(ac.clock()) .. '; sequence=' .. combat.spells, true)
    end
  end)
  local death_trigger = war3.CreateTrigger(function()
    combat.deaths = combat.deaths + 1
    if combat.deaths <= 20 then
      boot.note('COMBAT death owner=' .. GetPlayerId(GetOwningPlayer(GetTriggerUnit())) ..
        '; unit=' .. tostring(GetTriggerUnit()) .. '; killer=' .. tostring(GetKillingUnit()))
    end
  end)
  for i = 0, 15 do
    TriggerRegisterPlayerUnitEvent(death_trigger, Player(i), EVENT_PLAYER_UNIT_DEATH, nil)
    if i <= 5 then TriggerRegisterPlayerUnitEvent(spell_trigger, Player(i), EVENT_PLAYER_UNIT_SPELL_EFFECT, nil) end
  end
  for _, name in ipairs({'SetUnitName','SetUnitMissileArc','SetUnitMissileModel','SetUnitMissileSpeed'}) do
    boot.note('MONSTER API ' .. name .. ' = ' .. type(japi[name]))
  end
  local samples = 0
  ac.loop(5000, function(timer)
    samples = samples + 1
    M.monster("STATE", {spawn=state(attack_start), next=state(attack_next), movie=Movie_Boolean, extra=ExtraBattle, boss=BossBattle, pool=MonsterType, sample=samples})
    local heroes = Group_PlayHero and type(Group_Counts)=='function' and Group_Counts(Group_PlayHero) or -1
    if samples <= 180 then boot.note('GAMEPLAY SAMPLE ' .. samples .. ': ' .. M.summary() ..
      '; heroes=' .. heroes .. '; next=' .. state(attack_next) ..
      '; movie=' .. tostring(Movie_Boolean) .. '; extra=' .. tostring(ExBossBattle) ..
      '; practice=' .. tostring(Mode_Dabamoshi) .. '; pool=' .. tostring(MonsterType)) end
    pcall(function()
    for slot = 1, 6 do
      local h = Hero and Hero[slot]
      if Xuanze and Xuanze[slot] and h and h ~= 0 and GetUnitTypeId(h) ~= 0 then
        M.phase("HERO_STATE", {slot=slot, type=GetUnitTypeId(h), x=GetUnitX(h), y=GetUnitY(h),
          hp=GetWidgetLife(h), stamina=Hero_Tili and Hero_Tili[slot], ready=PlayerReady and PlayerReady[slot]})
      end
    end
    end)
  end)
end
return M
