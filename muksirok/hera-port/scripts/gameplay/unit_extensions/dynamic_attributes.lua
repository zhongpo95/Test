-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local DirtyRefresh = require("gameplay.runtime.dirty_refresh")
local Modifier = require("gameplay.state.modifier")
local DynamicAttributes = {}
local dynamic_attributes_mt = {}
dynamic_attributes_mt.__index = dynamic_attributes_mt
local TENGU = "天狗"
local MECHANICAL_LIFE = "机械生命"
local MAID = "女仆"
local MOBILE_SUIT = "机动战士"

local function assert_targets(targets)
  assert(targets.damage_bonus, "damage bonus target is required")
  assert(targets.critical_damage, "critical damage target is required")
  assert(targets.max_health, "max health target is required")
  assert(targets.extra_move_speed_ratio, "extra move speed ratio target is required")
  assert(targets.extra_move_speed, "extra move speed target is required")
  assert(targets.damage_taken, "damage taken target is required")
  assert(targets.energy_damage, "energy damage target is required")
  assert(targets.physical_damage, "physical damage target is required")
  assert(targets.melee_damage, "melee damage target is required")
  assert(targets.end_damage, "end damage target is required")
end

local function mark_if_enabled(runtime, enabled, unit, key)
  if enabled[unit] then
    runtime.dirty_refresh:mark(unit, key)
  end
end

local function refresh_tengu(runtime, unit)
  local owner_id = unit.ownerid
  local targets = runtime.targets
  local critical_damage = runtime.tengu_values.critical_damage_ratio_per_mutation * unit:getdata("天狗变异数量")
  runtime.modifier:set(targets.damage_bonus, owner_id, unit, 0.1 * unit:getbloodcd("妖"))
  runtime.modifier:set(targets.critical_damage, owner_id, unit, critical_damage)
end

local function refresh_mechanical_life(runtime, unit)
  local mutation = unit:getstate("机械变异") or 0
  local effect_ratio = runtime.mechanical_life_values.effect_ratio_per_mutation
  local max_health = effect_ratio * mutation
  local damage_taken_ratio = 1 - max_health
  local floor = runtime.mechanical_life_values.damage_taken_ratio_floor
  if damage_taken_ratio <= floor then
    damage_taken_ratio = floor
  end
  unit:setdata("机械生命-减伤", damage_taken_ratio)
  runtime.modifier:set(runtime.targets.max_health, unit.ownerid, unit, 0.1 * max_health)
end

local function refresh_maid(runtime, unit)
  local move_speed = runtime.maid_values.extra_move_speed_ratio_per_mutation * unit:getdata("女仆变异数量")
  runtime.modifier:set(runtime.targets.extra_move_speed_ratio, unit.ownerid, unit, move_speed)
end

local function refresh_mobile_suit(runtime, unit)
  local owner_id = unit.ownerid
  local targets = runtime.targets
  local in_combat = unit:getdata("战斗时间") > 0
  local move_speed = in_combat and 0 or 75
  local damage_taken = in_combat and 0 or 0.5
  local damage_bonus = in_combat and 0.25 or 0
  local melee_damage = in_combat and 0.025 or 0
  local end_damage = 0.005 * runtime.get_mobile_count()
  runtime.modifier:set(targets.extra_move_speed, owner_id, unit, move_speed)
  runtime.modifier:set(targets.damage_taken, owner_id, unit, damage_taken)
  runtime.modifier:set(targets.energy_damage, owner_id, unit, damage_bonus)
  runtime.modifier:set(targets.physical_damage, owner_id, unit, damage_bonus)
  runtime.modifier:set(targets.melee_damage, owner_id, unit, melee_damage)
  runtime.modifier:set(targets.end_damage, owner_id, unit, end_damage)
end

local function build_data_change_handlers(runtime)
  local handlers = {}
  
  local function mark_tengu(unit)
    mark_if_enabled(runtime, runtime.tengu_units, unit, TENGU)
  end
  
  local function mark_mechanical_life(unit)
    mark_if_enabled(runtime, runtime.mechanical_life_units, unit, MECHANICAL_LIFE)
  end
  
  local function mark_maid(unit)
    mark_if_enabled(runtime, runtime.maid_units, unit, MAID)
  end
  
  -- 신력 부하와 수용 한도는 공용 상태이며 변경 즉시 기존 질병 페널티를 갱신한다.
  local function refresh_divinity_load(unit)
    local excess = unit:getdata("系统-神力承载") - unit:getdata("系统-神力承载上限")
    if excess > 0 or unit:hasdata("变异判定-无序之力") then
      AdvanceGet["无序之力"](unit)
    end
  end
  handlers["系统-神力承载"] = refresh_divinity_load
  handlers["系统-神力承载上限"] = refresh_divinity_load

  handlers["总血统补正浓度"] = mark_tengu
  handlers["妖血统补正浓度"] = mark_tengu
  handlers["天狗变异数量"] = mark_tengu
  handlers["机械变异数量"] = mark_mechanical_life
  handlers["效果增强-机械"] = mark_mechanical_life
  handlers["效果增强-全词条"] = mark_mechanical_life
  handlers["神器判定-索林原虫虫后"] = mark_mechanical_life
  handlers["心脏变异数量"] = mark_mechanical_life
  handlers["女仆变异数量"] = mark_maid
  handlers["战斗时间"] = function(unit, old_value, new_value)
    local was_in_combat = type(old_value) == "number" and 0 < old_value
    local is_in_combat = type(new_value) == "number" and 0 < new_value
    if was_in_combat ~= is_in_combat then
      mark_if_enabled(runtime, runtime.mobile_suit_units, unit, MOBILE_SUIT)
    end
  end
  return handlers
end

function DynamicAttributes.new(config)
  local targets = assert(config.targets, "dynamic attribute targets are required")
  assert_targets(targets)
  local runtime = setmetatable({
    targets = targets,
    tengu_values = assert(config.tengu_values, "tengu values are required"),
    mechanical_life_values = assert(config.mechanical_life_values, "mechanical life values are required"),
    maid_values = assert(config.maid_values, "maid values are required"),
    get_mobile_count = assert(config.get_mobile_count, "mobile suit count callback is required"),
    modifier = Modifier.new(config.change_value),
    tengu_units = {},
    mechanical_life_units = {},
    maid_units = {},
    mobile_suit_units = {},
    mobile_suit_order = {}
  }, dynamic_attributes_mt)
  runtime.dirty_refresh = DirtyRefresh.new({
    interval = config.interval or 250,
    loop = config.loop
  })
  runtime.dirty_refresh:register(TENGU, function(unit)
    refresh_tengu(runtime, unit)
  end)
  runtime.dirty_refresh:register(MECHANICAL_LIFE, function(unit)
    refresh_mechanical_life(runtime, unit)
  end)
  runtime.dirty_refresh:register(MAID, function(unit)
    refresh_maid(runtime, unit)
  end)
  runtime.dirty_refresh:register(MOBILE_SUIT, function(unit)
    refresh_mobile_suit(runtime, unit)
  end)
  runtime.data_change_handlers = build_data_change_handlers(runtime)
  
  function runtime.on_data_cleared(unit)
    mark_if_enabled(runtime, runtime.tengu_units, unit, TENGU)
    mark_if_enabled(runtime, runtime.mechanical_life_units, unit, MECHANICAL_LIFE)
    mark_if_enabled(runtime, runtime.maid_units, unit, MAID)
    mark_if_enabled(runtime, runtime.mobile_suit_units, unit, MOBILE_SUIT)
  end
  
  return runtime
end

function dynamic_attributes_mt:enable_tengu(unit)
  if self.tengu_units[unit] then
    return
  end
  self.tengu_units[unit] = true
  self.dirty_refresh:mark(unit, TENGU)
end

function dynamic_attributes_mt:enable_mechanical_life(unit)
  if self.mechanical_life_units[unit] then
    return
  end
  self.mechanical_life_units[unit] = true
  self.dirty_refresh:mark(unit, MECHANICAL_LIFE)
end

function dynamic_attributes_mt:enable_maid(unit)
  if self.maid_units[unit] then
    return
  end
  self.maid_units[unit] = true
  self.dirty_refresh:mark(unit, MAID)
end

function dynamic_attributes_mt:enable_mobile_suit(unit)
  if self.mobile_suit_units[unit] then
    return
  end
  self.mobile_suit_units[unit] = true
  local order = self.mobile_suit_order
  order[#order + 1] = unit
  for index = 1, #order do
    self.dirty_refresh:mark(order[index], MOBILE_SUIT)
  end
end

return DynamicAttributes
