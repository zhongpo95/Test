-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local ku = require("gameplay.monster.mubanku")
local UNIT_ID_DEFAULT = "u05N"
local STORAGE_OWNER = Player(PLAYER_NEUTRAL_AGGRESSIVE)
local STORAGE_X, STORAGE_Y = -7500, -7500
local TEMPLATE_BY_ATTACKTYPE = {
  ["近战"] = "u05N",
  ["模拟远程"] = "u06I",
  ["跟踪远程"] = "u065",
  ["炮火远程"] = "u060"
}

local function clear_custom_state(u)
  local h = u.handle
  local key = u:getdata("系统-怪物模板")
  local removefunc = u:getdata("系统-怪物模板移除函数")
  local hp = u:getdata("系统-怪物模板生命值")
  local atk = u:getdata("系统-怪物模板攻击力")
  Group_RemoveFromAll(u)
  u:clearbuff("暂停")
  removefunc(u)
  if not u.trigger then
    u.trigger = {}
  end
  u.trigger["单位-发动技能"] = {}
  u:clearstexiao()
  u:removeelitestics()
  u:cleardata()
  UnitRemoveBuffs(h, true, true)
  u = getunit(h)
  SetUnitOwner(u.handle, Player(PLAYER_NEUTRAL_AGGRESSIVE), false)
  u:setdata("系统-怪物模板", key)
  u:setdata("系统-怪物模板生命值", hp)
  u:setdata("系统-怪物模板攻击力", atk)
  u:setdata("系统-未使用怪物")
  ShowUnit(u.handle, false)
  PauseUnit(u.handle, true)
  SetUnitX(u.handle, STORAGE_X)
  SetUnitY(u.handle, STORAGE_Y)
end

local function apply_data(u, data, x, y, owner)
  local name = data.name or "怪物"
  local model = data.model or "units\\orc\\WyvernRider\\WyvernRider.mdl"
  local modelsize = data.modelsize or 1.0
  local color = data.color or {
    255,
    255,
    255,
    255
  }
  local movetype = data.movetype
  local movespeed = data.movespeed or 400
  local flyheight = data.flyheight or 0
  local attack = data.attack or 100
  local attackrange = data.attackrange == 0 and 90 or data.attackrange or 100
  local attackspeed = data.attackspeed or 1.0
  local attacktype = data.attacktype or "近战"
  local armor = data.armor or 0
  local missilearc = data.missilearc or 0
  local missilespeed = data.missilespeed or 600
  local basichp = data.basichp or 10000
  local missile = data.missile or "Abilities\\Weapons\\HarpyMissile\\HarpyMissile.mdl"
  local removefunc = data.removefunc or function(_)
  end
  local setfunc = data.setfunc or function(_)
  end
  local mt
  if movetype == "步行" then
    mt = 2
  elseif movetype == "飞行" then
    mt = 4
  else
    mt = 0
  end
  if attacktype == "跟踪远程" or attacktype == "炮火远程" then
    -- JN 미지원 발사체 편집 때문에 생성 전체를 중단하지 않는다.
    -- 해당 환경에서는 원거리/포격 템플릿의 기본 발사체 설정을 유지한다.
    if type(japi.SetUnitMissileArc) == "function" then
      japi.SetUnitMissileArc(u.handle, missilearc)
    end
    if type(japi.SetUnitMissileModel) == "function" then
      japi.SetUnitMissileModel(u.handle, missile)
    end
    if type(japi.SetUnitMissileSpeed) == "function" then
      japi.SetUnitMissileSpeed(u.handle, missilespeed)
    end
  end
  japi.SetUnitName(u.handle, name)
  u:setdata("模型-名字", name)
  japi.SetUnitModel(u.handle, model)
  u:setsize(modelsize)
  u:setdata("模型-模型", model)
  u:setdata("模型-模型大小", modelsize)
  u:setflyheight(flyheight)
  u:setcolor(color[1], color[2], color[3], color[4] or 255)
  u:setdata("模型-色表", color)
  japi.EXSetUnitMoveType(u.handle, mt)
  SetUnitMoveSpeed(u.handle, movespeed)
  SetUnitState(u.handle, ConvertUnitState(18), attack)
  SetUnitState(u.handle, ConvertUnitState(22), attackrange)
  SetUnitState(u.handle, ConvertUnitState(37), attackspeed)
  SetUnitState(u.handle, ConvertUnitState(32), armor)
  u:clearbuff("暂停")
  u:changeowner(owner)
  SetUnitX(u.handle, x)
  SetUnitY(u.handle, y)
  PauseUnit(u.handle, false)
  SetUnitInvulnerable(u.handle, false)
  ShowUnit(u.handle, true)
  setfunc(u)
  u:deldata("系统-未使用怪物")
  u:setdata("系统-怪物模板移除函数", removefunc)
  u:setdata("系统-怪物模板生命值", basichp)
  u:setdata("系统-怪物模板攻击力", attack)
end

MonsterPool = {
  idle = {},
  inuse = {}
}

local function _ensure_bucket(self, unitId)
  if not self.idle[unitId] then
    self.idle[unitId] = {}
  end
  return self.idle[unitId]
end

local function _unitId_from_attacktype(attacktype)
  local id = TEMPLATE_BY_ATTACKTYPE[attacktype or "近战"]
  return id or UNIT_ID_DEFAULT
end

function MonsterPool:_spawn_empty(unitId)
  unitId = unitId or UNIT_ID_DEFAULT
  require("hera_gameplay_diagnostic").monster("POOL_CREATE_BEGIN", {type=unitId, x=STORAGE_X, y=STORAGE_Y})
  local h = CreateUnitLua(STORAGE_OWNER, S2ID(unitId), STORAGE_X, STORAGE_Y, 0)
  require("hera_gameplay_diagnostic").monster("POOL_CREATE_END", {type=unitId, handle=h})
  local u = getunit(h)
  u:setdata("系统-怪物模板", unitId)
  TriggerRegisterUnitEvent(DamageSystemTrg, h, EVENT_UNIT_DAMAGED)
  TriggerRegisterUnitEvent(MonsterDead, h, EVENT_UNIT_DEATH)
  u:triggeraddevent(Trg_UnitSkill, EVENT_UNIT_SPELL_EFFECT)
  return u
end

function MonsterPool:acquire(x, y, owner, unitId)
  unitId = unitId or UNIT_ID_DEFAULT
  local bucket = _ensure_bucket(self, unitId)
  require("hera_gameplay_diagnostic").monster("POOL_ACQUIRE", {type=unitId, idle=#bucket})
  local u = table.remove(bucket)
  require("hera_gameplay_diagnostic").monster("POOL_PICK", {type=unitId, reused=u ~= nil, handle=u and u.handle or 0})
  u = u or self:_spawn_empty(unitId)
  u.pool_idle = false
  self.inuse[u.handle] = true
  return u
end

function MonsterPool:release(u)
  require("hera_gameplay_diagnostic").monster("POOL_RELEASE", {handle=u and u.handle or 0, inuse=u and self.inuse[u.handle] or false})
  if not u or not self.inuse[u.handle] then
    return
  end
  u.pool_idle = true
  self.inuse[u.handle] = nil
  u.armor_pool_epoch = (u.armor_pool_epoch or 0) + 1
  local unitId = u:getdata("系统-怪物模板") or UNIT_ID_DEFAULT
  local bucket = _ensure_bucket(self, unitId)
  table.insert(bucket, u)
  clear_custom_state(u)
end

local function CreateDataMonsterFromPool(data, x, y, owner)
  owner = owner or Player(GetRandomInt(8, 11))
  local unitId = _unitId_from_attacktype(data.attacktype)
  local u = MonsterPool:acquire(x, y, owner, unitId)
  require("hera_gameplay_diagnostic").monster("APPLY_BEGIN", {handle=u.handle, name=data.name, x=x, y=y, owner=owner})
  apply_data(u, data, x, y, owner)
  require("hera_gameplay_diagnostic").monster("APPLY_END", {handle=u.handle})
  attackshuaguai(u.handle)
  require("hera_gameplay_diagnostic").monster("REGISTER_END", {handle=u.handle})
  return u
end

function CreateNameMonster(name, x, y, owner)
  if ku[name] then
    return CreateDataMonsterFromPool(ku[name], x, y, owner)
  else
    print("不存在的怪物类型" .. name)
    return CreateDataMonsterFromPool(ku["丧尸"], x, y, owner)
  end
end
