-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local BossAggro = require("gameplay.monster.boss.aggro")

local function MonsterFlashHatred()
  local z = 0
  local g = {}
  ForGroupLuaNew(Group_PlayHero, function(xq)
    if xq:isalive() and xq:isinrect(RECT_PlayArea) then
      local qz = xq:getdata("仇恨权重")
      if xq:hasbuff("隐身") then
        qz = qz * 0.05
      end
      z = z + qz
      table.insert(g, xq)
    end
  end)
  if #g == 0 then
    return getunit(BOSS_DEATH)
  end
  local totalWeight = z
  local randomWeight = GetRandomReal(0, 1) * totalWeight
  local weightSum = 0
  for i, xq in ipairs(g) do
    local qz = xq:getdata("仇恨权重")
    if xq:hasbuff("隐身") then
      qz = qz * 0.05
    end
    weightSum = weightSum + qz
    if randomWeight <= weightSum then
      return xq
    end
  end
  return getunit(BOSS_DEATH)
end

local function MonsterDefaultAttackTarget()
  if Danwei_Aidenizhiguan ~= 0 then
    local aidenizhiguan = getunit(Danwei_Aidenizhiguan)
    if aidenizhiguan and aidenizhiguan:isalive() then
      return aidenizhiguan
    end
  end
  return MonsterFlashHatred()
end

local function MonsterSetDefaultAttackTarget(u, face_target, target)
  if type(u) ~= "table" or not u.handle then
    u = getunit(u)
  end
  target = target or MonsterDefaultAttackTarget()
  if target then
    u:setdata("进攻目标", target.handle)
    if face_target and target.handle ~= BOSS_DEATH then
      SetUnitFacing(u.handle, AngleBetweenUnits(u.handle, target.handle))
    end
  end
  return target
end

function MonsterSetXingcunzuAttackTarget(u, face_target)
  if type(u) ~= "table" or not u.handle then
    u = getunit(u)
  end
  if Group_Counts(Group_Xingcunzu) <= 0 then
    return nil
  end
  local target = Group_Randomunit(Group_Xingcunzu)
  if target then
    u:setdata("进攻目标", target.handle)
    if face_target and target.handle ~= BOSS_DEATH then
      SetUnitFacing(u.handle, AngleBetweenUnits(u.handle, target.handle))
    end
  end
  return target
end

local function init()
  local dt = 0
  local counttime = 200
  
  local function _pick_name_from_current()
    if type(MonsterNames) == "table" and 0 < (MonsterType or 0) then
      return MonsterNames[GetRandomInt(1, MonsterType)]
    end
    return nil
  end
  
  local function _pick_name_from_all()
    if type(MonsterAllNames) == "table" and 0 < (MonsterTypeCount or 0) then
      return MonsterAllNames[GetRandomInt(1, MonsterTypeCount)]
    end
    return nil
  end
  
  local count2 = 0
  attack_start = ac.loop(counttime, function()
    require("hera_gameplay_diagnostic").monster("SPAWN_TICK", {boss=BossBattle, extra=ExtraBattle, exboss=ExBossBattle})
    local b = true
    local max = 100
    if BossBattle or ModeSelect_Muss then
      max = 40 + 10 * (PlayerCount + ComCount)
    end
    if max <= AllNumofMonster then
      b = false
    end
    if ExBossBattle then
      b = false
    end
    if not b then
      return
    end
    local x, y
    local hero = getunit(BOSS_DEATH)
    if LeftNumofMonster > 0 or ExtraBattle or BossBattle then
      local gdsg = true
      gdsg = false
      if Boolean_Ningjingwangguan then
        gdsg = true
      end
      if BossBattle then
        gdsg = true
      end
      if gdsg then
        x, y = GetRandomXYInRect(RECT_PlayArea)
      else
        hero = MonsterFlashHatred()
        x, y = hero:getxy()
        if hero.handle == BOSS_DEATH then
          x, y = GetRandomXYInRect(RECT_PlayArea)
        else
          for i = 1, 10 do
            x, y = PolarXY(x, y, GetRandomReal(3000, 5000), GetRandomReal(0, 360))
            if not (not IsXYinRect(x, y, RECT_PlayArea) or IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY)) then
              break
            end
            if i == 10 then
              x, y = GetRandomXYInRect(RECT_PlayArea)
              hero = getunit(BOSS_DEATH)
            end
          end
        end
      end
      local pick_name = Boolean_CallofCthulhu and _pick_name_from_all() or _pick_name_from_current()
      if not pick_name then
        return
      end
      require("hera_gameplay_diagnostic").monster("SPAWN_REQUEST", {name=pick_name, x=x, y=y, target=hero.handle})
      local u = CreateNameMonster(pick_name, x, y)
      require("hera_gameplay_diagnostic").monster("SPAWN_RETURN", {name=pick_name, handle=u and u.handle or 0})
      if not u then
        print("CreateNameMonster 失败：" .. tostring(pick_name))
        return
      end
      local mon = u.handle
      if not IsXYinRect(x, y, RECT_PlayArea) then
        local npc = getunit(NPC_BAYUNZI)
        local ax, ay = npc:getxy()
        u:setxy(ax + 500, ay + 500)
      end
      if hero.handle ~= BOSS_DEATH then
        MonsterSetDefaultAttackTarget(u, true, hero)
      end
    end
  end)
  attack_start:pause()
  require("hera_gameplay_diagnostic").monster("SPAWN_PAUSED_INIT", {})
  local g = CreateGroupLua()
  local dtime = 5
  attack_attackplace = ac.loop(dtime * 1000, function()
    GroupClearLua(g)
    ForGroupLuaNew(Group_PlayHero, function(xq)
      if xq:isalive() then
        xq:groupadd(g)
      end
      if xq:ishasskill("A0S9") or xq:ishasskill("Apiv") then
        xq:groupremove(g)
      end
    end)
    ForGroupLuaNew(Group_Monster, function(xq)
      local mb
      local is_aggro_boss = BossAggro.is_registered(xq)
      if is_aggro_boss then
        mb = BossAggro.get_target(xq)
      elseif Group_Counts(g) == 0 then
        return
      else
        local re = false
        if xq:getdata("进攻目标") == 0 then
          re = true
        else
          mb = getunit(xq:getdata("进攻目标"))
          if not (mb:isinrect(RECT_PlayArea) and mb:isalive()) or mb:hasbuff("隐身") then
            re = true
          end
        end
        if re then
          mb = MonsterSetDefaultAttackTarget(xq)
        end
      end
      if mb then
        local x, y = mb:getxy()
        if GetUnitCurrentOrder(xq.handle) ~= String2OrderIdBJ("tranquility") then
          IssueImmediateOrder(xq.handle, "holdposition")
          IssuePointOrder(xq.handle, "attack", x, y)
        end
      elseif is_aggro_boss then
        IssueImmediateOrder(xq.handle, "holdposition")
        IssueImmediateOrder(xq.handle, "stop")
      end
    end)
  end)
  attack_attackplace:pause()
  ac.loop(3000, function()
    ForGroupLuaNew(Group_PlayHero, function(hero)
      if not hero:isalive() or hero:hasbuff("隐身") then
      else
        local x, y = hero:getxy()
        for _, xq in ac.selector():in_rangexy(x, y, 1000):is_enemy(hero.handle):ipairs() do
          xq = getunit(xq)
          if xq:isingroup(Group_Monster) and not BossAggro.is_registered(xq) and GetUnitCurrentOrder(xq.handle) ~= String2OrderIdBJ("tranquility") then
            IssueImmediateOrder(xq.handle, "holdposition")
            IssuePointOrder(xq.handle, "attack", x, y)
          end
        end
      end
    end)
  end)
  attack_monster_ai = ac.loop(250, function()
    ForGroupLuaNew(Group_PlayHero, function(u)
      if u:isalive() then
        local x, y = u:getxy()
        for _, xq in ac.selector():in_rangexy(x, y, 2000):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          if not BossAggro.is_registered(xq) and xq:hasdata("施法范围") and xq:getdata("沉默时间") == 0 then
            local dis = DistanceBetweenUnits(xq.handle, u.handle)
            if dis <= xq:getdata("施法范围") then
              local b = true
              if xq:ishasbuff("B0A5") and not xq:hasdata("空-行为预测冷却") then
                xq:buffset(u.handle, 2, "眩晕")
                xq:settimedata("空-行为预测冷却", 15)
              end
              if xq:ishasbuff("B0E3") and GetRandom100(30) then
                xq:buffset(u.handle, 1, "眩晕")
                xq:buffset(u.handle, 1, "沉默")
              end
              if b then
                monstermagic(u.handle, xq.handle)
              end
            end
          end
        end
      end
    end)
  end)
end

init()

function monstermagic(unit, monster)
  local u = getunit(unit)
  local mon = getunit(monster)
  local x, y = u:getxy()
  local x2, y2 = mon:getxy()
  local c = mon:getdata("施法频率")
  if GetRandomReal(0, c) <= 1 then
    if mon:ishasskill("A0AT") or mon:ishasskill("A02R") or mon:ishasskill("A02U") or mon:ishasskill("A08K") or mon:ishasskill("A07X") or mon:ishasskill("A08O") or mon:ishasskill("A0F1") or mon:ishasskill("A0KV") or mon:ishasskill("A0L4") or mon:ishasskill("A0L7") or mon:ishasskill("A05M") or mon:ishasskill("A00I") or mon:ishasskill("A0LA") or mon:ishasskill("A183") then
      IssueTargetOrder(mon.handle, "slow", u.handle)
    end
    if mon:ishasskill("A0AU") or mon:ishasskill("A0A6") or mon:ishasskill("A0BI") or mon:ishasskill("A08P") or mon:ishasskill("A0EY") or mon:ishasskill("A0EZ") or mon:ishasskill("A0IO") or mon:ishasskill("A0KS") or mon:ishasskill("A0K2") then
      IssueImmediateOrder(mon.handle, "berserk")
    end
    if mon:ishasskill("A0LB") then
      IssueImmediateOrder(mon.handle, "fanofknives")
    end
    if mon:ishasskill("A0RC") then
      IssueImmediateOrder(mon.handle, "windwalk")
    end
    if mon:ishasskill("A0KW") then
      IssueTargetOrder(mon.handle, "cripple", u.handle)
    end
    if mon:ishasskill("A0L0") then
      IssueTargetOrder(mon.handle, "shadowstrike", u.handle)
    end
    if mon:ishasskill("A0EX") or mon:ishasskill("A0RF") then
      IssuePointOrder(mon.handle, "blink", x, y)
    end
    if mon:ishasskill("A0KY") then
      IssuePointOrder(mon.handle, "flamestrike", x, y)
    end
    if mon:ishasskill("A0KZ") then
      IssuePointOrder(mon.handle, "ward", x2, y2)
    end
  end
end

local g = CreateGroupLua()

function gethpatkchange(u)
  local hp, atk
  local unit = u.handle
  if not u:hasdata("系统-怪物模板") then
    atk = 100
    hp = GetUnitState(u.handle, UNIT_STATE_MAX_LIFE)
    SetUnitState(u.handle, UNIT_STATE_MAX_LIFE, 10000)
    TriggerRegisterUnitEvent(DamageSystemTrg, unit, EVENT_UNIT_DAMAGED)
    TriggerRegisterUnitEvent(MonsterDead, unit, EVENT_UNIT_DEATH)
  else
    hp = u:getdata("系统-怪物模板生命值")
    atk = u:getdata("系统-怪物模板攻击力")
  end
  if u:isingroup(HellGroup) then
    hp = hp * BOSSEWHp
  end
  local addhp = 1 + 0.05 * Nandu_Level
  local addatk = 1 + 0.015 * Nandu_Level
  addhp = addhp * 8
  addhp = addhp * MWTQ_HpMon
  addatk = addatk * MWTQ_AtkMon
  addhp = addhp * NanduJc_Hp
  addatk = addatk * NanduJc_Atk
  u:setdata("怪物强度", addatk)
  u:setdata("怪物-伤害修正", 1)
  u:setmaxhp(hp * addhp)
  u:setdata("怪物基础生命上限", u:getmaxhp())
  local shjc = atk * Stage
  SetUnitState(unit, ConvertUnitState(18), shjc * u:getdata("怪物强度"))
  u:sethp(100, true)
  if Keyan_Zhongzhuanghujia and not u:hasdata("科研模式-重装护甲提升") then
    local add = 0.5 * Nandu_Level
    u:changearmor(add)
    u:setdata("科研模式-重装护甲提升")
  end
end

local gl = 0

function attackshuaguai(unit)
  local u = getunit(unit)
  local x, y = u:getxy()
  local jg = false
  jg = true
  AllNumofMonster = AllNumofMonster + 1
  if ExtraBattle or BossBattle or ExBossBattle then
  else
    LeftNumofMonster = LeftNumofMonster - 1
  end
  gethpatkchange(u)
  elitemonster(unit)
  if Boolean_Fuxiuchen then
    u:groupadd(HpGroup)
  end
  if Boolean_Tianqi and GetRandom100(1) then
    if GetRandomInt(1, 2) == 1 then
      u:addskill("S05X")
    else
      u:addskill("S05Y")
    end
  end
  u:groupadd(Group_Monster)
  u:setdata("闪避值", 0)
  if not u:hasdata("进攻目标") then
    MonsterSetDefaultAttackTarget(u)
    u:effectadd("Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl")
    u:animeact("birth")
    ac.wait(10, function()
      u:buffset(unit, 1.5, "暂停")
      u:buffset(unit, 1, "无敌")
    end)
  end
  local mb = getunit(u:getdata("进攻目标"))
  IssueImmediateOrder(u.handle, "holdposition")
  IssueImmediateOrder(u.handle, "stop")
  ac.wait(1000, function()
    if jg and mb.handle ~= BOSS_DEATH then
      IssuePointOrder(unit, "attack", GetUnitX(mb.handle), GetUnitY(mb.handle))
    end
  end)
  if not u:hasdata("系统-怪物模板") then
    local monsterskill = require("gameplay.monster.skill")
    if monsterskill[MonsterName[GetUnitTypeId(unit)]] and MonsterName[GetUnitTypeId(unit)] then
      monsterskill[MonsterName[GetUnitTypeId(unit)]](unit)
      if u:hasdata("施法范围") then
        u:triggeraddevent(Trg_UnitSkill, EVENT_UNIT_SPELL_EFFECT)
      end
    end
  end
  if 0 < Count_Huanxiangxiangshuliang and 0 < Count_HuanxiangguaiMax then
    if GetRandom100(5 * Count_Huanxiangxiangshuliang + gl) then
      gl = 0
      Count_HuanxiangguaiMax = Count_HuanxiangguaiMax - 1
      u:setdata("怪物-携带P点")
      u:setcolor(255, 0, 0)
    else
      gl = gl + 2.5
    end
  end
end
