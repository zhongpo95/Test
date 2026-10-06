-- 변신별 지속 시간과 재사용 대기시간 및 효과를 정의한다.
-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
return function(HeshinFunc)
  local heshingroup = {
    {
      name = "白狼王",
      skill = "A0UC",
      time = 45,
      cd = 600,
      unittype = "E007",
      startfunc = function(u)
        local sy = u.ownerid
        ChangeValue(HeroMenu_HpChange_Inr, sy, 2000)
        u:changeoriginmaxhp(10000)
        gunban(u.handle)
        u:addstexiao("狼化", "近战伤害特效", function(args)
          local u = args.u
          local tg = args.tg
          local info = args.damageinfo
          if u:hasdata("变身-狼化中") and not u:hasdata("狼化" .. "-特效冷却") then
            u:settimedata("狼化" .. "-特效冷却", 0.1)
            local x2, y2 = tg:getxy()
            for _, xq in ac.selector():in_rangexy(x2, y2, 500):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              if xq ~= tg then
                xq:effectadd("Abilities\\Spells\\Human\\MarkOfChaos\\MarkOfChaosDone.mdl", "chest")
                DamageUnit({
                  bj = "白狼王分裂",
                  unit = xq.handle,
                  source = u.handle,
                  damage = info.yssh,
                  level = 1,
                  type = "物理",
                  isvest = false,
                  isattack = true,
                  isnoarmor = false,
                  element = "无"
                })
              end
            end
          end
        end)
        ForGroupLuaNew(Group_Wolf, function(xq)
          xq:deldata("狼神庇护冷却")
          if xq:hasdata("变身冷却-狼人") then
            xq:setdata("变身冷却-狼人", 0)
          end
        end)
        SetTimeOfDay(24)
        u:setdata("变身-狼化中")
      end,
      loopfunc = function(u)
        gunban(u.handle)
      end,
      endfunc = function(u)
        local sy = u.ownerid
        ChangeValue(HeroMenu_HpChange_Inr, sy, -2000)
        u:changeoriginmaxhp(-10000)
        gunban(u.handle, false)
        u:deldata("变身-狼化中")
      end
    },
    {
      name = "狼人",
      skill = "A0QD",
      time = 40,
      cd = 120,
      unittype = "E006",
      startfunc = function(u)
        local sy = u.ownerid
        ChangeValue(HeroMenu_HpChange_Inr, sy, 1000)
        u:changeoriginmaxhp(5000)
        gunban(u.handle)
        u:setdata("变身-狼化中")
        u:addstexiao("狼化", "近战伤害特效", function(args)
          local u = args.u
          local tg = args.tg
          local info = args.damageinfo
          if u:hasdata("变身-狼化中") and not u:hasdata("狼化" .. "-特效冷却") then
            u:settimedata("狼化" .. "-特效冷却", 0.1)
            local x2, y2 = tg:getxy()
            for _, xq in ac.selector():in_rangexy(x2, y2, 500):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              if xq ~= tg then
                xq:effectadd("Abilities\\Spells\\Human\\MarkOfChaos\\MarkOfChaosDone.mdl", "chest")
                DamageUnit({
                  bj = "狼人分裂",
                  unit = xq.handle,
                  source = u.handle,
                  damage = info.yssh,
                  level = 1,
                  type = "物理",
                  isvest = false,
                  isattack = true,
                  isnoarmor = false,
                  element = "无"
                })
              end
            end
          end
        end)
      end,
      loopfunc = function(u)
        gunban(u.handle)
      end,
      endfunc = function(u)
        local sy = u.ownerid
        ChangeValue(HeroMenu_HpChange_Inr, sy, -1000)
        u:deldata("变身-狼化中")
        u:changeoriginmaxhp(-5000)
        gunban(u.handle, false)
      end
    },
    {
      name = "盖亚-狼",
      skill = "A17G",
      time = 20,
      cd = 600,
      unittype = "E006",
      startfunc = function(u)
        local sy = u.ownerid
        ChangeValue(HeroMenu_HpChange_Inr, sy, 1000)
        u:changeoriginmaxhp(5000)
        gunban(u.handle)
        u:setdata("变身-狼化中")
        u:addstexiao("狼化", "近战伤害特效", function(args)
          local u = args.u
          local tg = args.tg
          local info = args.damageinfo
          if u:hasdata("变身-狼化中") and not u:hasdata("狼化" .. "-特效冷却") then
            u:settimedata("狼化" .. "-特效冷却", 0.1)
            local x2, y2 = tg:getxy()
            for _, xq in ac.selector():in_rangexy(x2, y2, 500):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              if xq ~= tg then
                xq:effectadd("Abilities\\Spells\\Human\\MarkOfChaos\\MarkOfChaosDone.mdl", "chest")
                DamageUnit({
                  bj = "狼人分裂",
                  unit = xq.handle,
                  source = u.handle,
                  damage = info.yssh,
                  level = 1,
                  type = "物理",
                  isvest = false,
                  isattack = true,
                  isnoarmor = false,
                  element = "无"
                })
              end
            end
          end
        end)
      end,
      loopfunc = function(u)
        gunban(u.handle)
      end,
      endfunc = function(u)
        local sy = u.ownerid
        ChangeValue(HeroMenu_HpChange_Inr, sy, -1000)
        u:deldata("变身-狼化中")
        u:changeoriginmaxhp(-5000)
        gunban(u.handle, false)
      end
    },
    {
      name = "盖亚-恶魔",
      skill = "A17F",
      time = 22.5,
      cd = 600,
      unittype = "E002",
      startfunc = function(u)
        local sy = u.ownerid
        u:changeoriginmaxhp(2500)
        u:playsound(SargerasRoar)
        local add1 = u:getdata("魔力值")
        local add2 = Correction_Magic[sy] - 1
        u:setdata("变身-提升魔力值", add1)
        u:setdata("变身-提升法术修正", add2)
        u:changedata("魔力值", add1)
        ChangeValue(Correction_Magic, sy, add2)
        ChangeValue(Damage_ElementRes_Fire, sy, 1000)
      end,
      loopfunc = function(u)
      end,
      endfunc = function(u)
        u:changeoriginmaxhp(-2500)
        local sy = u.ownerid
        local add1 = u:getdata("变身-提升魔力值")
        local add2 = u:getdata("变身-提升法术修正")
        u:deldata("恶魔变身-传送移动")
        u:changedata("魔力值", -1 * add1)
        ChangeValue(Correction_Magic, sy, -1 * add2)
        ChangeValue(Damage_ElementRes_Fire, sy, -1000)
      end
    },
    {
      name = "恶魔",
      skill = "A07K",
      time = 45,
      cd = 360,
      unittype = "E002",
      startfunc = function(u)
        local sy = u.ownerid
        u:changeoriginmaxhp(2500)
        u:playsound(SargerasRoar)
        local add1 = u:getdata("魔力值")
        local add2 = Correction_Magic[sy] - 1
        u:setdata("变身-提升魔力值", add1)
        u:setdata("变身-提升法术修正", add2)
        u:changedata("魔力值", add1)
        ChangeValue(Correction_Magic, sy, add2)
        ChangeValue(Damage_ElementRes_Fire, sy, 1000)
      end,
      loopfunc = function(u)
      end,
      endfunc = function(u)
        u:changeoriginmaxhp(-2500)
        local sy = u.ownerid
        local add1 = u:getdata("变身-提升魔力值")
        local add2 = u:getdata("变身-提升法术修正")
        u:changedata("魔力值", -1 * add1)
        u:deldata("恶魔变身-传送移动")
        ChangeValue(Correction_Magic, sy, -1 * add2)
        ChangeValue(Damage_ElementRes_Fire, sy, -1000)
      end
    },
    {
      name = "盖亚-龙",
      skill = "A17H",
      time = 15,
      cd = 600,
      unittype = "E003",
      startfunc = function(u)
        local sy = u.ownerid
        ChangeValue(HeroMenu_HpChange_Inr, sy, 2500)
        local z = 10000 * u:getdragonbloodpower()
        u:setdata("龙-变身提升生命值", z)
        u:changeoriginmaxhp(z)
        gunban(u.handle)
        ac.wait(1000, function()
          SetUnitState(u.handle, ConvertUnitState(18), 10000 + 10000.0 * u:getdata("龙变异数量") * u:getdragonbloodpower())
        end)
        u:effectadd("Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl", "origin")
        u:playsound(DragonYesAttack2)
        local x, y = u:getxy()
        for _, xq in ac.selector():in_rangexy(x, y, 900):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          xq:buffset(u.handle, 3, "眩晕")
        end
      end,
      loopfunc = function(u)
        gunban(u.handle)
      end,
      endfunc = function(u)
        local sy = u.ownerid
        ChangeValue(HeroMenu_HpChange_Inr, sy, -2500)
        u:changeoriginmaxhp(-1 * u:getdata("龙-变身提升生命值"))
        u:deldata("龙-变身提升生命值")
        gunban(u.handle, false)
      end
    },
    {
      name = "龙化",
      skill = "A05Q",
      time = 30,
      cd = 480,
      unittype = "E003",
      startfunc = function(u)
        local sy = u.ownerid
        ChangeValue(HeroMenu_HpChange_Inr, sy, 2500)
        local z = 10000 * u:getdragonbloodpower()
        u:setdata("龙-变身提升生命值", z)
        u:changeoriginmaxhp(z)
        gunban(u.handle)
        ac.wait(1000, function()
          SetUnitState(u.handle, ConvertUnitState(18), 10000 + 10000.0 * u:getdata("龙变异数量") * u:getdragonbloodpower())
        end)
        u:effectadd("Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl", "origin")
        u:playsound(DragonYesAttack2)
        local x, y = u:getxy()
        for _, xq in ac.selector():in_rangexy(x, y, 900):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          xq:buffset(u.handle, 3, "眩晕")
        end
      end,
      loopfunc = function(u)
        gunban(u.handle)
      end,
      endfunc = function(u)
        local sy = u.ownerid
        ChangeValue(HeroMenu_HpChange_Inr, sy, -2500)
        u:changeoriginmaxhp(-1 * u:getdata("龙-变身提升生命值"))
        u:deldata("龙-变身提升生命值")
        gunban(u.handle, false)
      end
    },
    {
      name = "恶魔显现",
      skill = "A1HA",
      time = 30,
      cd = 480,
      unittype = "E00D",
      startfunc = function(u)
        u:changeoriginmaxhp(50000)
        ac.wait(1000, function()
          SetUnitState(u.handle, ConvertUnitState(18), 30000 + 30000 * u:getstate("黑暗变异"))
        end)
        gunban(u.handle)
        u:setdata("缇欧-恶魔显现")
        HeshinFunc.add_buff_block(u, "恶魔显现", "缇欧-恶魔显现")
      end,
      loopfunc = function(u)
        gunban(u.handle)
      end,
      endfunc = function(u)
        u:deldata("缇欧-恶魔显现")
        u:changeoriginmaxhp(-50000)
        gunban(u.handle, false)
      end
    },
    {
      name = "兽化暗",
      skill = "A1H9",
      time = 30,
      cd = 300,
      unittype = "E00C",
      startfunc = function(u)
        u:changeoriginmaxhp(10000)
        gunban(u.handle)
        u:effectadd("Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl", "origin")
      end,
      loopfunc = function(u)
        gunban(u.handle)
      end,
      endfunc = function(u)
        u:changeoriginmaxhp(-10000)
        gunban(u.handle, false)
      end
    },
    {
      name = "龙化暗",
      skill = "A1H8",
      time = 30,
      cd = 300,
      unittype = "E00B",
      startfunc = function(u)
        local z = 20000
        u:setdata("龙-变身提升生命值", z)
        u:changeoriginmaxhp(z)
        HeshinFunc.add_buff_block(u, "龙化暗", "缇欧-龙化暗")
        u:setdata("缇欧-龙化暗")
        gunban(u.handle)
        ac.wait(1000, function()
          SetUnitState(u.handle, ConvertUnitState(18), 10000 + 10000.0 * u:getstate("龙变异") + 10000 * u:getstate("黑暗变异"))
        end)
        u:effectadd("Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl", "origin")
        u:playsound(DragonYesAttack2)
        local x, y = u:getxy()
        for _, xq in ac.selector():in_rangexy(x, y, 900):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          xq:buffset(u.handle, 3, "眩晕")
        end
      end,
      loopfunc = function(u)
        gunban(u.handle)
      end,
      endfunc = function(u)
        u:deldata("缇欧-龙化暗")
        u:changeoriginmaxhp(-1 * u:getdata("龙-变身提升生命值"))
        u:deldata("龙-变身提升生命值")
        gunban(u.handle, false)
      end
    },
    {
      name = "狮子王",
      skill = "A17D",
      time = 60,
      cd = 600,
      unittype = "E008",
      startfunc = function(u)
        local sy = u.ownerid
        HeshinFunc.add_buff_block(u, "狮子王", "变身-狮子王")
        u:setdata("变身-狮子王")
        u:changeoriginmaxhp(50000)
        ChangeValue(HeroMenu_HpChange_Inr, sy, 2000)
        gunban(u.handle)
        u:addstexiao("狮子王", "近战伤害特效", function(args)
          local tg = args.tg
          local u = args.u
          if u.type == S2ID("E008") and not u:hasdata("狮子王" .. "-特效冷却") then
            u:settimedata("狮子王" .. "-特效冷却", 1)
            local x2, y2 = tg:getxy()
            Effectcreate("BTX\\[BTxNew]LionKing_01.mdx", x2, y2, 0, 2, 0, u:getface())
            Effectcreate("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", x2, y2, 0, 3)
            for i = 1, 3 do
              Effectcreate("Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl", x2, y2, 0, i)
            end
            for _, xq in ac.selector():in_rangexy(x2, y2, 500):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              xq:effectadd("Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl")
              DamageUnit({
                bj = "狮子王",
                unit = xq.handle,
                source = u.handle,
                damage = 300000,
                level = 1,
                type = "震荡",
                isvest = false,
                isattack = false,
                isnoarmor = false,
                element = "无"
              })
            end
          end
        end)
      end,
      loopfunc = function(u)
        gunban(u.handle)
        local x2, y2 = u:getxy()
        Effectcreate("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", x2, y2, 0, 3)
        for _, xq in ac.selector():in_rangexy(x2, y2, 500):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          DamageUnit({
            bj = "狮子王",
            unit = xq.handle,
            source = u.handle,
            damage = 150000,
            level = 1,
            type = "震荡",
            isvest = false,
            isattack = false,
            isnoarmor = false,
            element = "无"
          })
        end
      end,
      endfunc = function(u)
        local sy = u.ownerid
        ChangeValue(HeroMenu_HpChange_Inr, sy, -2000)
        u:deldata("变身-狮子王")
        u:changeoriginmaxhp(-50000)
        gunban(u.handle, false)
      end
    },
    {
      name = "盖亚-狮子王",
      skill = "A17I",
      time = 30,
      cd = 600,
      unittype = "E008",
      startfunc = function(u)
        local sy = u.ownerid
        ChangeValue(HeroMenu_HpChange_Inr, sy, 2000)
        u:setdata("变身-狮子王")
        u:changeoriginmaxhp(50000)
        gunban(u.handle)
        HeshinFunc.add_buff_block(u, "狮子王", "变身-狮子王")
        u:addstexiao("狮子王", "近战伤害特效", function(args)
          local tg = args.tg
          local u = args.u
          if u.type == S2ID("E008") and not u:hasdata("狮子王" .. "-特效冷却") then
            u:settimedata("狮子王" .. "-特效冷却", 1)
            local x2, y2 = tg:getxy()
            Effectcreate("BTX\\[BTxNew]LionKing_01.mdx", x2, y2, 0, 2, 0, u:getface())
            Effectcreate("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", x2, y2, 0, 3)
            for i = 1, 3 do
              Effectcreate("Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl", x2, y2, 0, i)
            end
            for _, xq in ac.selector():in_rangexy(x2, y2, 500):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              xq:effectadd("Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl")
              DamageUnit({
                bj = "狮子王",
                unit = xq.handle,
                source = u.handle,
                damage = 300000,
                level = 1,
                type = "震荡",
                isvest = false,
                isattack = false,
                isnoarmor = false,
                element = "无"
              })
            end
          end
        end)
      end,
      loopfunc = function(u)
        gunban(u.handle)
        local x2, y2 = u:getxy()
        Effectcreate("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", x2, y2, 0, 3)
        for _, xq in ac.selector():in_rangexy(x2, y2, 500):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          DamageUnit({
            bj = "狮子王",
            unit = xq.handle,
            source = u.handle,
            damage = 150000,
            level = 1,
            type = "震荡",
            isvest = false,
            isattack = false,
            isnoarmor = false,
            element = "无"
          })
        end
      end,
      endfunc = function(u)
        local sy = u.ownerid
        ChangeValue(HeroMenu_HpChange_Inr, sy, -2000)
        u:deldata("变身-狮子王")
        u:changeoriginmaxhp(-50000)
        gunban(u.handle, false)
      end
    }
  }
  return heshingroup
end
