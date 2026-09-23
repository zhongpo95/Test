-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local nd = Nandu_Choose

local function blz_skill1(args)
  local u = getunit(args.unit)
  local tg = getunit(args.target)
  local x, y = u:getxy()
  local x2, y2 = tg:getxy()
  local angle = AngleXY(x, y, x2, y2)
  u:buffset(u.handle, 0.75, "暂停")
  ac.wait(1, function()
    u:animeact("spell")
    u:animespeed(2)
  end)
  local txsh = 500 * u:getdata("怪物强度")
  ac.wait(300, function()
    if u:isalive() then
      for i = 1, 20 do
        local jd2 = angle + GetRandomReal(-60, 60)
        unifycreate({
          owner = u.handle,
          model = "Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl",
          modelname = "深渊火球",
          modelsize = 1.5,
          height = 100,
          damage = txsh,
          damagetype = 4,
          x = x,
          y = y,
          time = 6,
          speed = 500,
          volume = 90,
          angle = jd2,
          angleoffset = 0,
          attenua = 1,
          attenuacount = 1,
          life = 10,
          isbullet = false,
          isvest = false,
          isignorearmor = false
        })
      end
    end
  end)
  ac.wait(750, function()
    u:animespeed(1)
  end)
end

local function blz_skill2(args)
  local u = getunit(args.unit)
  local tg = getunit(args.target)
  local x, y = u:getxy()
  local x2, y2 = tg:getxy()
  local angle = AngleXY(x, y, x2, y2)
  u:buffset(u.handle, 0.5, "暂停")
  ac.wait(1, function()
    u:animeact("spell")
    u:animespeed(2)
  end)
  local txsh = 500 * u:getdata("怪物强度")
  ac.wait(250, function()
    if u:isalive() then
      unifycreate({
        owner = u.handle,
        model = "Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl",
        modelname = "深渊火球",
        modelsize = 1.5,
        height = 100,
        damage = txsh,
        damagetype = 4,
        x = x,
        y = y,
        time = 1.5,
        speed = 2000,
        volume = 90,
        angle = angle,
        angleoffset = 0,
        attenua = 1,
        attenuacount = 1,
        life = 10,
        isbullet = false,
        isvest = false,
        isignorearmor = false,
        hitafterfunc = function(mj, xq, damage2)
          local vest = getunit(System_SkillVest)
          vest:addskill("A0KU")
          vest:setskilldatareal("A0KU", 108, 0.2 * txsh)
          IssueTargetOrder(vest.handle, "soulburn", xq.handle)
          vest:delskill("A0KU")
        end
      })
    end
  end)
  ac.wait(500, function()
    u:animespeed(1)
  end)
end

local function weiboskill1(args)
  local u = getunit(args.unit)
  local tg = getunit(args.target)
  local x, y = u:getxy()
  local x2, y2 = tg:getxy()
  local angle = AngleXY(x, y, x2, y2)
  local txsh = 500 * u:getdata("怪物强度")
  u:buffset(u.handle, 0.5, "暂停")
  ac.wait(10, function()
    u:animeact("spell")
  end)
  ac.wait(500, function()
    if u:isalive() then
      unifycreate({
        owner = u.handle,
        model = "Abilities\\Spells\\Other\\FrostBolt\\FrostBoltMissile.mdl",
        modelname = "冰球术",
        modelsize = 2,
        height = 75,
        damage = txsh,
        damagetype = 4,
        x = x,
        y = y,
        time = 2,
        speed = 2200,
        volume = 90,
        angle = angle,
        angleoffset = 0,
        attenua = 1,
        attenuacount = 1,
        life = 10,
        isbullet = false,
        isvest = false,
        isignorearmor = false,
        hitafterfunc = function(mj, xq, damage2)
          xq:buffset(u.handle, 2, "冻结")
        end
      })
    end
  end)
end

local function oglsskill1(args)
  local u = getunit(args.unit)
  local tg = getunit(args.target)
  if not u:isvalid() or not tg:isvalid() then return end
  local source_epoch = u.armor_pool_epoch or 0
  local target_epoch = tg.armor_pool_epoch or 0
  local function valid()
    return u:isvalid(source_epoch) and tg:isvalid(target_epoch)
  end
  ac.loop(1000, function(timer)
    if not valid() or not tg:ishasbuff("BNpa") then
      timer:remove()
      return
    end
    local x, y = tg:getxy()
    local hp = 0.05 * tg:gethp()
    local txsh = hp * Nandu_Choose
    tg:losshp(u, hp)
    if not valid() then timer:remove(); return end
    for i = 1, 12 do
      for j = 1, 3 do
        local dx, dy = PolarXY(x, y, 150 * j, 30 * i)
        Effectcreate("Objects\\Spawnmodels\\NightElf\\EntBirthTarget\\EntBirthTarget.mdl", dx, dy)
      end
    end
    for _, xq in ac.selector():in_rangexy(x, y, 500):is_enemy(u.handle):ipairs() do
      if not valid() then timer:remove(); return end
      xq = getunit(xq)
      if xq.handle ~= tg.handle then
        DamageUnit({
          unit = xq.handle,
          source = u.handle,
          damage = 250 * u:getdata("怪物强度"),
          level = 1,
          type = "魔力",
          isvest = false,
          isattack = false,
          isnoarmor = false,
          element = "风"
        })
      else
        DamageUnit({
          unit = xq.handle,
          source = u.handle,
          damage = txsh,
          level = 1,
          type = "魔力",
          isvest = false,
          isattack = false,
          isnoarmor = false,
          element = "风"
        })
      end
    end
    if not valid() or not tg:ishasbuff("BNpa") then
      timer:remove()
    end
  end)
end

local function sidierskill1(args)
  local u = getunit(args.unit)
  local x, y = u:getxy()
  u:buffset(u.handle, 10.6, "暂停")
  ac.wait(1, function()
    u:animeact("attack slam")
    u:animespeed(2)
  end)
  local txsh = 800 * u:getdata("怪物强度")
  ac.wait(500, function()
    Effectcreate("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", x, y)
    u:setflyheight(9000, 5000)
  end)
  local cs = 0
  ac.loop(1000, function(timer)
    cs = cs + 1
    if cs == 1 then
      ShowUnit(u.handle, false)
      u:animespeed(1)
      u:setflyheight(0, 5000)
    end
    if cs < 10 then
      ForGroupLuaNew(Group_Xingcunzu, function(xq)
        local x2, y2 = xq:getxy()
        local mj = u:createunit("o001", x2, y2)
        mj:groupadd(HellGroup)
        japi.EXSetUnitCollisionType(false, mj.handle, 1)
        mj:setdata("系统-单次受伤1")
        mj:setflyheight(6000)
        mj:timetoremove(24)
        Effectcreate("Abilities\\Spells\\Other\\Silence\\SilenceAreaBirth.mdl", x2, y2)
        local cs2 = 0
        ac.loop(30, function(timer2)
          cs2 = cs2 + 1
          mj:setflyheight(6000 - 300 * cs2)
          if cs2 == 20 then
            Effectcreate("Objects\\Spawnmodels\\Other\\NeutralBuildingExplosion\\NeutralBuildingExplosion.mdl", x2, y2)
            japi.EXSetUnitCollisionType(true, mj.handle, 1)
            for _, xq2 in ac.selector():in_rangexy(x2, y2, 200):is_enemy(u.handle):ipairs() do
              xq2 = getunit(xq2)
              DamageUnit({
                unit = xq2.handle,
                source = u.handle,
                damage = txsh,
                level = 1,
                type = "震荡",
                isvest = false,
                isattack = false,
                isnoarmor = false,
                element = "无"
              })
              xq2:buffset(u.handle, 0.5, "眩晕")
            end
            timer2:remove()
          end
        end)
      end)
    end
    if cs == 10 then
      ShowUnit(u.handle, true)
      if Group_Counts(Group_Xingcunzu) > 0 then
        local tg = Group_Randomunit(Group_Xingcunzu)
        if type(tg) ~= "table" then
          error("生存组计数与内容不一致")
        end
        x, y = tg:getxy()
      end
      u:setxy(x, y)
      u:setflyheight(6000)
      Effectcreate("Abilities\\Spells\\Other\\Silence\\SilenceAreaBirth.mdl", x, y)
      local cs2 = 0
      ac.loop(30, function(timer2)
        cs2 = cs2 + 1
        u:setflyheight(6000 - 300 * cs2)
        if cs2 == 20 then
          Effectcreate("Objects\\Spawnmodels\\Other\\NeutralBuildingExplosion\\NeutralBuildingExplosion.mdl", x, y)
          for _, xq2 in ac.selector():in_rangexy(x, y, 250):is_enemy(u.handle):ipairs() do
            xq2 = getunit(xq2)
            DamageUnit({
              unit = xq2.handle,
              source = u.handle,
              damage = 2 * txsh,
              level = 1,
              type = "震荡",
              isvest = false,
              isattack = false,
              isnoarmor = false,
              element = "无"
            })
            xq2:buffset(u.handle, 0.5, "眩晕")
          end
          timer2:remove()
        end
      end)
      timer:remove()
    end
  end)
end

local function sidierskill2(args)
  local u = getunit(args.unit)
  local x, y = u:getxy()
  u:playsound(TaurenWarcry1)
  Effectcreate("Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl", x, y, 0, 3)
  for _, xq2 in ac.selector():in_rangexy(x, y, 1000):is_enemy(u.handle):ipairs() do
    xq2 = getunit(xq2)
    xq2:buffset(u.handle, 0.1, "眩晕")
    xq2:buffset(u.handle, 3, "僵直")
  end
end

local function gdjxjr1(args)
  local u = getunit(args.unit)
  local x, y = u:getxy()
  for i = 1, 4 do
    if ExtraBattle or BossBattle or ExBossBattle then
    else
      LeftNumofMonster = LeftNumofMonster + 1
    end
    local mon = CreateMonster("u05C", x + GetRandomReal(100, 300), y + GetRandomReal(100, 300))
    attackshuaguai(mon)
    mon = getunit(mon)
    mon:buffset(mon.handle, 3, "暂停")
    mon:setdata("系统-机械单位")
  end
end

local function gdjxjr2(args)
  local u = getunit(args.unit)
  local tg = getunit(args.target)
  local x, y = u:getxy()
  local x2, y2 = tg:getxy()
  local angle = AngleXY(x, y, x2, y2)
  local txsh = 1000 * u:getdata("怪物强度")
  if u:isalive() then
    unifycreate({
      owner = u.handle,
      model = "Abilities\\Weapons\\RockBoltMissile\\RockBoltMissile.mdl",
      modelname = "巨石",
      modelsize = 2,
      height = 50,
      damage = txsh,
      damagetype = 4,
      x = x,
      y = y,
      time = 1.5,
      speed = 2000,
      volume = 125,
      angle = angle,
      angleoffset = 0,
      attenua = 1,
      attenuacount = 1,
      life = 10,
      isbullet = false,
      isvest = false,
      isignorearmor = false,
      hitafterfunc = function(mj, xq, damage2)
        if not xq:hasbuff("绝对闪避") then
          xq:buffset(u.handle, 2, "眩晕")
        end
      end
    })
  end
end

local function gdjxjr3(args)
  local u = getunit(args.unit)
  local txsh = 1000 * u:getdata("怪物强度")
  ac.wait(1, function()
    u:animeact("spell")
  end)
  u:buffset(u.handle, 1.3, "暂停")
  local x, y = u:getxy()
  local jd = u:getface()
  local dx, dy = PolarXY(x, y, 300, jd)
  local dt = 0.6
  u:setface(jd)
  Effectcreate("Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl", x, y, 0, 3)
  ac.wait(700, function()
    u:animeact("walk")
    u:animespeed(2)
    unitmove({
      unit = u.handle,
      time = 0.6,
      distance = 1800,
      angle = jd,
      isfly = true,
      loops = {
        {
          looptime = 0.05,
          func = function(dx, dy)
            local ddx, ddy = PolarXY(dx, dy, GetRandomReal(0, 200), GetRandomAngle())
            Effectcreate("war3mapImported\\fuzzystomp.mdx", ddx, ddy, 0, 3)
            for _, xq in ac.selector():in_rangexy(dx, dy, 400):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              DamageUnit({
                unit = xq.handle,
                source = u.handle,
                damage = txsh,
                level = 1,
                type = "震荡",
                isvest = false,
                isattack = true,
                isnoarmor = false,
                element = "无"
              })
              xq:buffset(u.handle, 1.5, "眩晕")
            end
          end
        },
        {
          looptime = 0.1,
          func = function(dx, dy)
            local ddx, ddy = PolarXY(dx, dy, GetRandomReal(0, 200), GetRandomAngle())
            Effectcreate("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", ddx, ddy, 0, 3)
          end
        }
      },
      endfunc = function(dx, dy)
        u:animespeed(1)
      end
    })
  end)
end

local monsterskill = {
  ["布兰兹"] = function(unit)
    local u = getunit(unit)
    u:setdata("系统-精英")
    u:setdata("深渊怪物-布兰兹")
    u:setdata("施法范围", 1500)
    u:setdata("施法频率", 4)
    u:setskilldatareal("A0KY", 110, 400 * u:getdata("怪物强度"))
    u:addstexiao("布兰兹", "伤害判定后效果", function(args)
      local tg = args.tg
      local u = args.u
      local info = args.damageinfo
      if tg:hasdata("布兰兹-炼狱之速") then
        if Nandu_Shenzhao then
          u:sethp(u:gethp() + info.damage)
        end
        info.damage = 1
      end
    end)
    u:addstexiao("布兰兹", "被施加Buff时效果-僵直", function(args)
      local u = args.u
      local soc = args.soc
      if u:hasdata("布兰兹-炼狱之速") then
        args.time = args.time * 0.05
      end
    end)
    u:addstexiao("布兰兹", "被施加Buff时效果-眩晕", function(args)
      local u = args.u
      local soc = args.soc
      if u:hasdata("布兰兹-炼狱之速") then
        args.time = args.time * 0.05
      end
    end)
    u:addtrgevent("单位-发动技能", function(args)
      if args.skill == S2ID("A0KV") then
        blz_skill1(args)
      end
      if args.skill == S2ID("A0KW") then
        blz_skill2(args)
      end
      if args.skill == S2ID("A0K2") then
        u:setdata("布兰兹-炼狱之速")
        SetUnitState(u.handle, ConvertUnitState(37), 0.5)
        ac.wait(10000, function()
          u:deldata("布兰兹-炼狱之速")
          SetUnitState(u.handle, ConvertUnitState(37), 10.0)
        end)
      end
    end)
  end,
  ["维波"] = function(unit)
    local u = getunit(unit)
    u:setdata("系统-精英")
    u:setdata("深渊怪物-维波")
    u:setdata("施法范围", 2000)
    u:setdata("施法频率", 5)
    u:addtrgevent("单位-发动技能", function(args)
      if args.skill == S2ID("A0L4") then
        weiboskill1(args)
      end
    end)
  end,
  ["欧格罗斯"] = function(unit)
    local u = getunit(unit)
    u:setdata("深渊怪物-欧格罗斯")
    u:setdata("系统-精英")
    u:changedata("怪物-百分比恢复", 0.25)
    local cs = 0
    ac.loop(1000, function(timer)
      if u:isalive() then
        cs = cs + 1
        if cs == 15 then
          cs = 0
          local x, y = u:getxy()
          local mj = u:createunit("u04H", x, y)
          mj:setdata("免疫生命损耗")
          mj:setdata("免疫击退效果")
          mj:setdata("免疫生命修改")
          mj:setdata("系统-单次受伤1")
          mj:setdata("免疫即死效果")
          mj:setdata("免疫混乱改变所属")
          SetUnitState(mj.handle, UNIT_STATE_MAX_LIFE, 10000)
          mj:setmaxhp(50)
          UnitApplyTimedLife(mj.handle, S2ID("BHwe"), 60)
          mj:groupadd(HellGroup)
          TriggerRegisterUnitEvent(DamageSystemTrg, mj.handle, EVENT_UNIT_DAMAGED)
          SetUnitMoveSpeed(mj.handle, 0)
        end
      else
        timer:remove()
      end
    end)
    u:setdata("施法范围", 1000)
    u:setdata("施法频率", 4)
    u:addtrgevent("单位-发动技能", function(args)
      if args.skill == S2ID("A0L0") then
        oglsskill1(args)
      end
    end)
  end,
  ["斯狄尔"] = function(unit)
    local u = getunit(unit)
    u:setdata("深渊怪物-斯狄尔")
    u:setdata("系统-精英")
    u:setdata("施法范围", 1500)
    u:setdata("施法频率", 4)
    if Nandu_Choose >= 3 then
      u:addskill("A0IO")
    end
    u:setskilldatareal("A0L3", 109, 400 * u:getdata("怪物强度"))
    u:addtrgevent("单位-发动技能", function(args)
      if args.skill == S2ID("A0L7") then
        sidierskill1(args)
      end
      if args.skill == S2ID("A0IO") then
        sidierskill2(args)
      end
    end)
  end,
  ["古代机械战士"] = function(unit)
    local u = getunit(unit)
    u:setdata("普攻-古代机械战士")
  end,
  ["古代机械巨人"] = function(unit)
    local u = getunit(unit)
    u:setdata("施法范围", 1500)
    u:setdata("施法频率", 4)
    u:addskill("A0LB")
    u:addskill("A0LA")
    u:addskill("A0KS")
    u:addtrgevent("单位-发动技能", function(args)
      if args.skill == S2ID("A0LB") then
        gdjxjr1(args)
      end
      if args.skill == S2ID("A0LA") then
        gdjxjr2(args)
      end
      if args.skill == S2ID("A0KS") then
        gdjxjr3(args)
      end
    end)
    local cs = 0
    ac.loop(1000, function(timer)
      if u:isalive() then
        cs = cs + 1
        if cs == 15 then
          cs = 0
          local x, y = u:getxy()
          Effectcreate("Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl", x, y, 0, 2.5)
          u:clearbuff("眩晕")
          u:clearbuff("僵直")
          for _, xq2 in ac.selector():in_rangexy(x, y, 900):is_enemy(u.handle):ipairs() do
            xq2 = getunit(xq2)
            xq2:buffset(u.handle, 0.25, "眩晕")
            xq2:buffset(u.handle, 3, "僵直")
          end
        end
      else
        timer:remove()
      end
    end)
  end
}
return monsterskill
