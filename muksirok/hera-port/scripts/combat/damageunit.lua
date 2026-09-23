-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
function DamageUnit(args)
  local unit = args.unit
  
  if not unit or unit == 0 then
    print("受伤单位不存在")
    printCallStack()
    return
  end
  local source = args.source or BOSS_DEATH
  if not source or source == 0 then
    source = BOSS_DEATH
  end
  if GetUnitTypeId(unit) == 0 or GetUnitTypeId(source) == 0 then return end
  local u = getunit(unit)
  if not u then
    print(("DamageUnit: getunit(%s) 失败（受伤单位不存在或已移除）"):format(tostring(unit)))
    printCallStack()
    return
  end
  local soc = getunit(source)
  if not soc then
    print(("DamageUnit: getunit(%s) 失败（伤害来源不存在或已移除）"):format(tostring(source)))
    soc = getunit(BOSS_DEATH) or u
  end
  if not u:isvalid() or not soc:isvalid() then return end
  local damage = args.damage or 0
  local isattack = args.isattack or false
  local isnoarmor = args.isnoarmor or false
  local damagetype = args.type or "物理"
  local isvest = args.isvest or false
  local element = args.element or "无"
  local level = args.level or 1
  local extradata = args.extradata
  local attack = args.attack
  local bj = args.bj
  local sy = u.ownerid
  local sy2 = soc.ownerid
  if isvest then
    source = System_SkillVestPlayer[sy2]
  end
  local x, y = u:getxy()
  local x2, y2 = soc:getxy()
  local damageinfo = {
    bj = bj,
    u = u,
    soc = soc,
    x = x,
    y = y,
    x2 = x2,
    y2 = y2,
    sy = u.ownerid,
    sy2 = sy2,
    damage = damage,
    yssh = damage,
    isvestdamage = isvest,
    isignorearmor = isnoarmor,
    ismeleedamage = isattack,
    damagetype = damagetype,
    distance = DistanceXY(x, y, x2, y2),
    attack = attack
  }
  if sy2 <= 6 then
    damageinfo.hero = getunit(Hero[sy2])
    damageinfo.wqlx = Hero_Equip_WeaponType[sy2]
  else
    damageinfo.hero = soc
  end
  local hero = damageinfo.hero
  if element == "无" and hero:hasdata("属性伤害") then
    element = hero:getdata("属性伤害")
    hero:deldata("属性伤害")
  end
  damageinfo.element = element
  if hero:hasdata("伤害阶级") then
    level = hero:getdata("伤害阶级")
    hero:deldata("伤害阶级")
  end
  if level == 2 or level == 3 then
    level = 1
  end
  damageinfo.level = level
  if extradata then
    for index, value in ipairs(extradata) do
      soc:setdata(value)
    end
  end
  if u:isingroup(Group_AllHero) then
    damagefunc2(damageinfo)
  else
    damagefunc(damageinfo)
  end
  if extradata then
    for index, value in ipairs(extradata) do
      soc:deldata(value)
    end
  end
end
