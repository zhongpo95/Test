-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local BossAggro = require("gameplay.monster.boss.aggro")
local g = CreateGroupLua()
local bossskill = {
  {
    name = "雷罚",
    skilltime = 5,
    skillcd = 7,
    cd = 30,
    condition = function(u)
      local b = true
      return b
    end,
    selectcondition = function(u)
      local b = false
      return b
    end,
    effect = function(self, args)
      local u = args.u
      local txsh = 1000 * u:getdata("怪物强度")
      SendMsgAll("|cFFFFCC33" .. self.name .. "|r")
      ac.wait(1, function()
        u:animeact(11)
      end)
      local x, y = u:getxy()
      PlayGlobalSound(BOSS_Wst_11)
      Effectcreate("Abilities\\Spells\\Human\\slow\\slowtarget.mdl", x, y, 1.5, 5)
      Effectcreate("effect\\BOSS\\BOSS_Wst (1).mdl", x, y, 5, 5)
      ac.wait(1000, function()
        Effectcreate("effect\\BOSS\\BOSS_Wst (19).mdl", x, y, 0, 4)
      end)
      ac.wait(1500, function()
        PlayGlobalSound(BOSS_Wst_12)
        Effectcreate("effect\\BOSS\\BOSS_Wst (7).mdl", x, y, 0, 5)
        for _, xq in ac.selector():in_rangexy(x, y, 600):isingroup(Group_PlayHero):ipairs() do
          xq = getunit(xq)
          local txsh2 = txsh
          if xq:hasbuff("麻痹") then
            txsh2 = txsh + 0.25 * xq:getmaxhp()
            xq:losshp(u, 0, 25)
          end
          DamageUnit({
            unit = xq.handle,
            source = u.handle,
            damage = txsh2,
            level = 1,
            type = "魔力",
            isvest = false,
            isattack = false,
            isnoarmor = false,
            element = "雷"
          })
          if xq:getdata("绝对闪避时间") == 0 then
            xq:buffset(u.handle, 0.1, "眩晕")
          end
        end
        ac.timer(750, 4, function()
          for i = 1, 18 do
            local x1, y1 = PolarXY(x, y, GetRandomReal(0, 3000), GetRandomReal(0, 360))
            Effectcreate("Abilities\\Spells\\Human\\slow\\slowtarget.mdl", x1, y1, 1.25, 5)
            ac.wait(1250, function()
              Effectcreate("effect\\BOSS\\BOSS_Wst (7).mdl", x1, y1, 0, 3)
              for _, xq in ac.selector():in_rangexy(x1, y1, 400):isingroup(Group_PlayHero):ipairs() do
                xq = getunit(xq)
                local txsh2 = txsh
                if xq:hasbuff("麻痹") then
                  txsh2 = txsh + 0.25 * xq:getmaxhp()
                  xq:losshp(u, 0, 25)
                end
                DamageUnit({
                  unit = xq.handle,
                  source = u.handle,
                  damage = txsh2,
                  level = 1,
                  type = "魔力",
                  isvest = false,
                  isattack = false,
                  isnoarmor = false,
                  element = "雷"
                })
                if xq:getdata("绝对闪避时间") == 0 then
                  xq:buffset(u.handle, 0.1, "眩晕")
                end
              end
            end)
          end
          ForGroupLuaNew(Group_PlayHero, function(xq)
            local x1, y1 = xq:getxy()
            Effectcreate("Abilities\\Spells\\Human\\slow\\slowtarget.mdl", x1, y1, 1.25, 5)
            ac.wait(1250, function()
              Effectcreate("effect\\BOSS\\BOSS_Wst (7).mdl", x1, y1, 0, 3)
              for _, xq in ac.selector():in_rangexy(x1, y1, 400):isingroup(Group_PlayHero):ipairs() do
                xq = getunit(xq)
                local txsh2 = txsh
                if xq:hasbuff("麻痹") then
                  txsh2 = txsh + 0.25 * xq:getmaxhp()
                  xq:losshp(u, 0, 25)
                end
                DamageUnit({
                  unit = xq.handle,
                  source = u.handle,
                  damage = txsh2,
                  level = 1,
                  type = "魔力",
                  isvest = false,
                  isattack = false,
                  isnoarmor = false,
                  element = "雷"
                })
                if xq:getdata("绝对闪避时间") == 0 then
                  xq:buffset(u.handle, 0.1, "眩晕")
                end
              end
            end)
          end)
          ac.wait(1250, function()
            PlayGlobalSound(BOSS_Wst_12)
          end)
        end)
      end)
    end
  },
  {
    name = "惊雷",
    skilltime = 6.25,
    skillcd = 8.25,
    cd = 45,
    condition = function(u)
      local b = true
      return b
    end,
    selectcondition = function(u)
      local b = true
      local jl = 20000
      ForGroupLuaNew(Group_PlayHero, function(xq)
        if xq:isalive() and not xq:hasdata("系统-已删模") and xq.owner ~= Player(PLAYER_NEUTRAL_PASSIVE) then
          local jl2 = DistanceBetweenUnits(xq.handle, u.handle)
          if jl2 <= jl then
            jl = jl2
            xq:groupadd(g)
          end
        end
      end)
      return b
    end,
    effect = function(self, args)
      local u = args.u
      local tg = args.tg
      local txsh = 1000 * u:getdata("怪物强度")
      SendMsgAll("|cFFFFCC33" .. self.name .. "|r")
      ac.wait(1, function()
        u:animeact(9)
      end)
      local x, y = u:getxy()
      Effectcreate("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", x, y, 0, 2)
      Effectcreate("effect\\BOSS\\BOSS_Wst (6).mdl", x, y)
      u:buffset(u.handle, 6, "无敌")
      ac.wait(1200, function()
        ShowUnit(u.handle, false)
        local x2, y2 = tg:getxy()
        local x1, y1 = tg:getxy()
        local tx = Effectcreate("effect\\BOSS\\BOSS_Wst (2).mdl", x2, y2, -1, 3)
        local cs = 0
        ac.loop(30, function(timer)
          cs = cs + 1
          x2, y2 = tg:getxy()
          local angle = AngleXY(x1, y1, x2, y2)
          local dis = DistanceXY(x1, y1, x2, y2)
          if dis >= cs then
            dis = cs
          end
          x1, y1 = PolarXY(x1, y1, dis, angle)
          SetEffectXY(tx, x1, y1)
          if cs == 100 then
            DestroyEffectLua(tx)
            for _, xq in ac.selector():in_rangexy(x1, y1, 600):isingroup(Group_PlayHero):ipairs() do
              xq = getunit(xq)
              xq:effectadd("effect\\BOSS\\BOSS_Wst (8).mdl", "chest", 1)
              xq:clearbuff("无敌")
              if xq:hasbuff("绝对闪避") and xq:getdata("绝对闪避时间") <= 3 then
                xq:clearbuff("绝对闪避")
              end
            end
            ac.wait(300, function()
              u:setxy(x1, y1)
              u:animeact(10)
              ac.wait(1, function()
                ShowUnit(u.handle, true)
              end)
              for _, xq in ac.selector():in_rangexy(x1, y1, 600):isingroup(Group_PlayHero):ipairs() do
                xq = getunit(xq)
                xq:buffset(u.handle, 0.5, "锁定")
              end
              ac.wait(200, function()
                x, y = u:getxy()
                Effectcreate("effect\\BOSS\\BOSS_Wst (7).mdl", x, y, 0, 5)
                Effectcreate("effect\\BOSS\\BOSS_Wst (3).mdl", x, y, 0, 3)
                Effectcreate("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", x, y, 0, 2)
                Effectcreate("effect\\BOSS\\BOSS_Wst (6).mdl", x, y, 0, 1)
                PlayGlobalSound(BOSS_Wst_12)
                u:playsound(bac238)
                for _, xq in ac.selector():in_rangexy(x, y, 600):isingroup(Group_PlayHero):ipairs() do
                  xq = getunit(xq)
                  local txsh2 = txsh
                  DamageUnit({
                    unit = xq.handle,
                    source = u.handle,
                    damage = txsh2,
                    level = 1,
                    type = "魔力",
                    isvest = false,
                    isattack = false,
                    isnoarmor = false,
                    element = "雷"
                  })
                  if 0 >= xq:getdata("绝对闪避时间") then
                    xq:buffset(u.handle, 2, "眩晕")
                    xq:buffset(u.handle, 1, "锁定")
                  end
                end
              end)
              ac.wait(500, function()
                x, y = u:getxy()
                Effectcreate("effect\\BOSS\\BOSS_Wst (16).mdl", x, y, 0, 3, 0, GetRandomReal(0, 360))
                PlayGlobalSound(BOSS_Wst_05)
                ac.wait(500, function()
                  Effectcreate("effect\\BOSS\\BOSS_Wst (16).mdl", x, y, 0, 3, 0, GetRandomReal(0, 360))
                end)
                ac.timer(100, 10, function()
                  for _, xq in ac.selector():in_rangexy(x, y, 600):isingroup(Group_PlayHero):ipairs() do
                    xq = getunit(xq)
                    if xq:hasbuff("麻痹") then
                      xq:losshp(u, 0, 10)
                    end
                    local txsh2 = txsh + 0.1 * xq:getmaxhp()
                    DamageUnit({
                      unit = xq.handle,
                      source = u.handle,
                      damage = txsh2,
                      level = 1,
                      type = "魔力",
                      isvest = false,
                      isattack = false,
                      isnoarmor = false,
                      element = "雷"
                    })
                    if 0 >= xq:getdata("绝对闪避时间") then
                      u:sethp(u:getperhp() + 1, true)
                    end
                  end
                end)
              end)
            end)
            timer:remove()
          end
        end)
      end)
    end
  },
  {
    name = "震颤",
    skilltime = 2.2,
    skillcd = 4.2,
    cd = 4,
    condition = function(u)
      local b = true
      return b
    end,
    selectcondition = function(u)
      local b = true
      local jl = 3000
      ForGroupLuaNew(Group_PlayHero, function(xq)
        if xq:isalive() and not xq:hasdata("系统-已删模") and xq.owner ~= Player(PLAYER_NEUTRAL_PASSIVE) then
          local jl2 = DistanceBetweenUnits(xq.handle, u.handle)
          if jl2 <= jl then
            jl = jl2
            xq:groupadd(g)
          end
        end
      end)
      return b
    end,
    effect = function(self, args)
      local u = args.u
      local tg = args.tg
      local x, y = u:getxy()
      local x2, y2 = tg:getxy()
      local txsh = 1000 * u:getdata("怪物强度")
      local angle = AngleXY(x, y, x2, y2)
      local dis = DistanceXY(x, y, x2, y2)
      local zs = 2
      ac.wait(1, function()
        u:animeact(4)
      end)
      ac.timer(30, 16, function()
        angle = AngleBetweenUnits(u.handle, tg.handle)
        u:setface(angle)
      end)
      ac.wait(500, function()
        x2, y2 = tg:getxy()
        Effectcreate("effect\\BOSS\\BOSS_Wst2 (23).mdl", x2, y2, 0, 1.5, GetRandomReal(0, 360))
        angle = tg:getface()
        x2, y2 = PolarXY(x2, y2, 300, angle)
        x, y = u:getxy()
        angle = AngleXY(x, y, x2, y2)
        dis = DistanceXY(x, y, x2, y2)
        u:buffset(u.handle, 0.6, "无敌")
        unitjump({
          unit = u.handle,
          time = 0.6,
          distance = dis - 150,
          height = 300,
          angle = angle,
          isfly = true
        })
        ac.wait(600, function()
          PlayGlobalSound(BOSS_Wst_05)
          Effectcreate("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", x2, y2, 0, 2)
          Effectcreate("effect\\BOSS\\BOSS_Wst (16).mdl", x2, y2, 0, 4, GetRandomReal(0, 360))
          Effectcreate("effect\\BOSS\\BOSS_Wst2 (6).mdl", x2, y2, 0, 2, GetRandomReal(0, 360))
          ac.timer(50, 10, function()
            for _, xq in ac.selector():in_rangexy(x2, y2, 600):isingroup(Group_PlayHero):ipairs() do
              xq = getunit(xq)
              local txsh2 = txsh + 0.1 * xq:getmaxhp()
              DamageUnit({
                unit = xq.handle,
                source = u.handle,
                damage = txsh2,
                level = 1,
                type = "魔力",
                isvest = false,
                isattack = false,
                isnoarmor = false,
                element = "雷"
              })
            end
          end)
        end)
      end)
    end
  },
  {
    name = "刺击",
    skilltime = 1.8,
    skillcd = 3.8,
    cd = 8,
    condition = function(u)
      local b = true
      return b
    end,
    selectcondition = function(u)
      local b = true
      local jl = 1800
      ForGroupLuaNew(Group_PlayHero, function(xq)
        if xq:isalive() and not xq:hasdata("系统-已删模") and xq.owner ~= Player(PLAYER_NEUTRAL_PASSIVE) then
          local jl2 = DistanceBetweenUnits(xq.handle, u.handle)
          if jl2 <= jl then
            jl = jl2
            xq:groupadd(g)
          end
        end
      end)
      return b
    end,
    effect = function(self, args)
      local u = args.u
      local tg = args.tg
      local txsh = 1000 * u:getdata("怪物强度")
      local angle
      ac.wait(2, function()
        u:animeact(3)
      end)
      ac.timer(10, 60, function()
        u:animespeed(0.75)
      end)
      ac.timer(20, 20, function()
        angle = AngleBetweenUnits(u.handle, tg.handle)
        u:setface(angle)
      end)
      tg:effectadd("war3mapImported\\wei_buff.mdx", "overhead", 0)
      tg:playsound(Wei3)
      ac.wait(533, function()
        local dis = DistanceBetweenUnits(u.handle, tg.handle)
        if 500 <= dis then
          local x, y = u:getxy()
          x, y = PolarXY(x, y, -300, angle)
          unitmove({
            unit = u.handle,
            time = 0.2,
            distance = 200,
            angle = angle,
            isfly = true
          })
          Effectcreate("effect\\BOSS\\BOSS_Wst2 (21).mdl", x, y, 0, 1.5, 0, angle)
        end
      end)
      ac.wait(800, function()
        u:animespeed(1)
        u:playsound(bac261)
        local x, y = u:getxy()
        angle = u:getface()
        local tx = EffectcreateArgs({
          effect = "effect\\BOSS\\BOSS_Wst (5).mdl",
          x = x,
          y = y,
          time = 0.5,
          height = 75,
          zxz = angle
        })
        SetEffectColor(tx, 255, 100, 0)
        local x1, y1 = PolarXY(x, y, 1100, angle)
        Effectcreate("effect\\BOSS\\BOSS_Wst2 (18).mdl", x1, y1, 0, 1.5, 150, angle)
        x1, y1 = u:getxy()
        local dg = CreateGroupLua()
        for i = 1, 11 do
          x1, y1 = PolarXY(x1, y1, 100, angle)
          for _, xq in ac.selector():in_rangexy(x1, y1, 180):isingroup(Group_PlayHero):ipairs() do
            xq = getunit(xq)
            xq:groupadd(dg)
          end
        end
        if 0 < Group_Counts(dg) then
          u:playsound(bac48)
          PlayGlobalSound(BOSS_Wst_05)
          ForGroupLuaNew(dg, function(xq)
            local x2, y2 = xq:getxy()
            Effectcreate("effect\\BOSS\\BOSS_Wst (16).mdl", x2, y2, 0, 3, 0, GetRandomReal(0, 360))
            Effectcreate("effect\\BOSS\\BOSS_Wst (26).mdl", x2, y2, 0, 1, 0, GetRandomReal(0, 360))
            ac.wait(500, function()
              Effectcreate("effect\\BOSS\\BOSS_Wst (16).mdl", x2, y2, 0, 3, 0, GetRandomReal(0, 360))
            end)
            xq:effectadd("effect\\BOSS\\BOSS_Wst (8).mdl", "chest", 1)
            if xq:hasbuff("麻痹") and not Movie_Boolean then
              xq:kill(u.handle)
            end
            if xq:getdata("绝对闪避时间") <= 0 then
              xq:buffset(u.handle, 1, "锁定")
            end
            ac.timer(100, 10, function()
              for _, xq in ac.selector():in_rangexy(x2, y2, 400):isingroup(Group_PlayHero):ipairs() do
                xq = getunit(xq)
                local txsh2 = txsh + 0.1 * xq:getmaxhp()
                DamageUnit({
                  unit = xq.handle,
                  source = u.handle,
                  damage = txsh2,
                  level = 1,
                  type = "物理",
                  isvest = false,
                  isattack = true,
                  isnoarmor = false,
                  element = "雷"
                })
              end
            end)
          end)
        end
      end)
    end
  },
  {
    name = "突击",
    skilltime = 1.9,
    skillcd = 3.9,
    cd = 2,
    condition = function(u)
      local b = true
      return b
    end,
    selectcondition = function(u)
      local b = true
      local jl = 3000
      ForGroupLuaNew(Group_PlayHero, function(xq)
        if xq:isalive() and not xq:hasdata("系统-已删模") and xq.owner ~= Player(PLAYER_NEUTRAL_PASSIVE) then
          local jl2 = DistanceBetweenUnits(xq.handle, u.handle)
          if jl2 <= jl then
            jl = jl2
            xq:groupadd(g)
          end
        end
      end)
      return b
    end,
    effect = function(self, args)
      local u = args.u
      local tg = args.tg
      local x, y = u:getxy()
      local txsh = 1000 * u:getdata("怪物强度")
      local angle
      ac.wait(1, function()
        u:animeact(5)
        u:animespeed(2)
      end)
      Effectcreate("effect\\BOSS\\BOSS_Wst (21).mdl", x, y, 0, 1, 250)
      ac.timer(20, 20, function()
        angle = AngleBetweenUnits(u.handle, tg.handle)
        u:setface(angle)
      end)
      ac.wait(600, function()
        u:animeact(6)
        u:animespeed(1)
        ac.wait(200, function()
          PlayGlobalSound(BOSS_Wst_13)
          local x1, y1 = PolarXY(x, y, 350, angle)
          local tx = Effectcreate("effect\\BOSS\\BOSS_Wst (14).mdl", x1, y1, -1, 3, 200, angle)
          SetEffectXY(tx, x1, y1)
          DestroyEffectLua(tx)
          local dg = CreateGroupLua()
          for i = 1, 35 do
            x1, y1 = PolarXY(x1, y1, 100, angle)
            for _, xq in ac.selector():in_rangexy(x1, y1, 220):isingroup(Group_PlayHero):ipairs() do
              xq = getunit(xq)
              xq:groupadd(dg)
            end
          end
          if 0 < Group_Counts(dg) then
            ForGroupLuaNew(dg, function(xq)
              if xq:hasbuff("麻痹") then
                xq:effectadd("effect\\BOSS\\BOSS_Wst (8).mdl", "chest", 1)
                xq:clearbuff("无敌")
              end
              local txsh2 = txsh + 0.5 * xq:getmaxhp()
              DamageUnit({
                unit = xq.handle,
                source = u.handle,
                damage = txsh2,
                level = 1,
                type = "魔力",
                isvest = false,
                isattack = false,
                isnoarmor = false,
                element = "雷"
              })
              if xq:getdata("绝对闪避时间") <= 0 then
                xq:buffset(u.handle, 2, "眩晕")
                xq:losshp(u, 0, 50)
              end
            end)
          end
        end)
      end)
    end
  },
  {
    name = "突刺",
    skilltime = 2.4,
    skillcd = 4.4,
    cd = 8,
    condition = function(u)
      local b = true
      return b
    end,
    selectcondition = function(u)
      local b = true
      local jl = 3000
      ForGroupLuaNew(Group_PlayHero, function(xq)
        if xq:isalive() and not xq:hasdata("系统-已删模") and xq.owner ~= Player(PLAYER_NEUTRAL_PASSIVE) then
          local jl2 = DistanceBetweenUnits(xq.handle, u.handle)
          if jl2 <= jl then
            jl = jl2
            xq:groupadd(g)
          end
        end
      end)
      return b
    end,
    effect = function(self, args)
      local u = args.u
      local tg = args.tg
      local x, y = u:getxy()
      local angle
      local txsh = 2000 * u:getdata("怪物强度")
      ac.wait(1, function()
        u:animeact(5)
      end)
      Effectcreate("effect\\BOSS\\BOSS_Wst (18).mdl", x, y, 0, 1, 250)
      ac.timer(20, 40, function()
        angle = AngleBetweenUnits(u.handle, tg.handle)
        u:setface(angle)
      end)
      ac.wait(1000, function()
        u:animeact(6)
        ac.wait(200, function()
          PlayGlobalSound(BOSS_Wst_15)
          PlayGlobalSound(Shockwave)
          x, y = u:getxy()
          local x1, y1 = PolarXY(x, y, 300, angle)
          angle = angle - 90
          for i = 1, 5 do
            angle = angle + 30
            local tx = Effectcreate("effect\\BOSS\\BOSS_Wst (10).mdl", x1, y1, -1, 1, 200, angle)
            local dt = 0
            effectmove({
              effect = tx,
              time = 2,
              distance = 2000,
              angle = angle,
              loops = {
                {
                  looptime = 0.25,
                  func = function(dx, dy)
                    Effectcreate("Abilities\\Spells\\Human\\slow\\slowtarget.mdl", dx, dy, 1.25, 5)
                    ac.wait(1250, function()
                      Effectcreate("effect\\BOSS\\BOSS_Wst (7).mdl", dx, dy, 0, 3)
                      for _, xq in ac.selector():in_rangexy(dx, dy, 400):isingroup(Group_PlayHero):ipairs() do
                        xq = getunit(xq)
                        local txsh2 = txsh
                        if xq:hasbuff("麻痹") then
                          txsh2 = txsh + 0.25 * xq:getmaxhp()
                          xq:losshp(u, 0, 25)
                        end
                        DamageUnit({
                          unit = xq.handle,
                          source = u.handle,
                          damage = txsh2,
                          level = 1,
                          type = "魔力",
                          isvest = false,
                          isattack = false,
                          isnoarmor = false,
                          element = "雷"
                        })
                        if xq:getdata("绝对闪避时间") == 0 then
                          xq:buffset(u.handle, 0.1, "眩晕")
                        end
                      end
                    end)
                  end
                },
                {
                  looptime = 0.025,
                  func = function(dx, dy)
                    dt = dt + 0.025
                    if dt <= 0.75 then
                      for _, xq in ac.selector():in_rangexy(dx, dy, 200):isingroup(Group_PlayHero):ipairs() do
                        xq = getunit(xq)
                        local txsh2 = txsh * 0.25
                        DamageUnit({
                          unit = xq.handle,
                          source = u.handle,
                          damage = txsh2,
                          level = 1,
                          type = "魔力",
                          isvest = false,
                          isattack = false,
                          isnoarmor = false,
                          element = "雷"
                        })
                        if xq:getdata("绝对闪避时间") <= 0 then
                          xq:buffset(u.handle, 5, "僵直")
                          xq:buffset(u.handle, 5, "麻痹")
                        end
                      end
                    end
                  end
                }
              },
              endfunc = function()
                DestroyEffectLua(tx)
              end
            })
          end
          ac.timer(250, 8, function()
            ac.wait(1250, function()
              PlayGlobalSound(BOSS_Wst_12)
            end)
          end)
        end)
      end)
    end
  },
  {
    name = "光耀之雷",
    skilltime = 5.5,
    skillcd = 9,
    cd = 180,
    condition = function(u)
      local b = false
      if u:getperhp() <= 50 and Nandu_Choose >= 3 then
        b = true
      end
      return b
    end,
    selectcondition = function(_)
      return true
    end,
    effect = function(self, args)
      local u = args.u
      if not u:isalive() then
        return
      end
      local x, y = u:getxy()
      local angle
      local txsh = 1000 * u:getdata("怪物强度")
      local tg = args.tg
      if not tg then
        return
      end
      SendMsgAll("|cFFFFCC33" .. self.name .. "|r")
      local hp = u:getperhp()
      u:settimedata("翁斯坦-光耀之雷冷却", 15)
      if not u:hasdata("光耀之雷冷却中") then
        local t = 180
        if Nandu_Choose >= 4 then
          t = 75
        end
        if Nandu_Shenzhao then
          t = 60
        end
        u:settimedata("光耀之雷冷却中", t)
      elseif hp <= 33 and not u:hasdata("翁斯坦-光耀之雷33%") then
        u:setdata("翁斯坦-光耀之雷33%")
      elseif hp <= 66 and not u:hasdata("翁斯坦-光耀之雷66%") then
        u:setdata("翁斯坦-光耀之雷66%")
      end
      u:effectadd("effect\\BOSS\\BOSS_Wst (21).mdl", "hand left")
      tg:effectadd("effect\\BOSS\\BOSS_Wst2 (20).mdl", "overhead")
      u:playsound(bac406)
      FogEnable(false)
      FogMaskEnable(false)
      u:buffset(u.handle, 5.5, "暂停")
      u:buffset(u.handle, 5.5, "无敌")
      ac.wait(1, function()
        u:animeact(7)
        u:animespeed(0.5)
      end)
      ac.timer(20, 250, function()
        angle = AngleBetweenUnits(u.handle, tg.handle)
        u:setface(angle)
      end)
      ac.timer(500, 5, function()
        x, y = u:getxy()
        ac.wait(1250, function()
          for i = 1, 10 do
            local x1, y1 = PolarXY(x, y, GetRandomReal(0, 1800), GetRandomReal(0, 360))
            Effectcreate("Abilities\\Spells\\Human\\slow\\slowtarget.mdl", x1, y1, 1.25, 5)
            ac.wait(1250, function()
              Effectcreate("effect\\BOSS\\BOSS_Wst (7).mdl", x1, y1, 0, 3)
              for _, xq in ac.selector():in_rangexy(x1, y1, 400):isingroup(Group_PlayHero):ipairs() do
                xq = getunit(xq)
                local txsh2 = txsh
                if xq:hasbuff("麻痹") then
                  txsh2 = txsh + 0.25 * xq:getmaxhp()
                  xq:losshp(u, 0, 25)
                end
                DamageUnit({
                  unit = xq.handle,
                  source = u.handle,
                  damage = txsh2,
                  level = 1,
                  type = "魔力",
                  isvest = false,
                  isattack = false,
                  isnoarmor = false,
                  element = "雷"
                })
                if xq:getdata("绝对闪避时间") == 0 then
                  xq:buffset(u.handle, 0.1, "眩晕")
                end
              end
            end)
          end
          PlayGlobalSound(BOSS_Wst_12)
        end)
      end)
      ac.wait(4000, function()
        PlayGlobalSound(BOSS_Wst_12)
        u:effectadd("effect\\BOSS\\BOSS_Wst (18).mdl", "weapon")
        local cs = 0
        local jl = 2000
        local a = GetRandomReal(0, 360)
        x, y = u:getxy()
        ac.timer(100, 8, function()
          cs = cs + 1
          jl = jl - 200
          a = a + 30
          for i = 1, 6 do
            a = a + 60
            local x1, y1 = PolarXY(x, y, jl, a)
            Effectcreate("effect\\BOSS\\BOSS_Wst2 (8).mdl", x1, y1, 0, 4)
            for _, xq in ac.selector():in_rangexy(x1, y1, 500):isingroup(Group_PlayHero):ipairs() do
              xq = getunit(xq)
              local txsh2 = txsh
              if xq:hasbuff("麻痹") then
                txsh2 = txsh + 0.25 * xq:getmaxhp()
                xq:losshp(u, 0, 25)
              end
              DamageUnit({
                unit = xq.handle,
                source = u.handle,
                damage = txsh2,
                level = 1,
                type = "魔力",
                isvest = false,
                isattack = false,
                isnoarmor = false,
                element = "雷"
              })
              if xq:getdata("绝对闪避时间") == 0 then
                xq:buffset(u.handle, 0.1, "眩晕")
              end
            end
          end
        end)
      end)
      ac.wait(5000, function()
        PlayGlobalSound(bac51)
        u:animeact(8)
        u:animespeed(1)
        local a = u:getface()
        ac.wait(100, function()
          x, y = u:getxy()
          local x1, y1 = PolarXY(x, y, 100, a)
          local g2 = CreateGroupLua()
          ForGroupLuaNew(Group_PlayHero, function(xq)
            xq:buffset(u.handle, 10, "锁定")
          end)
          unifycreate({
            owner = u.handle,
            model = "effect\\BOSS\\BOSS_Wst (13).mdl",
            modelname = "光耀之雷",
            modelsize = 5,
            height = 90,
            damage = 0,
            damagetype = 1,
            x = x1,
            y = y1,
            range = 100000,
            speed = 15000,
            volume = 90,
            angle = u:getface(),
            angleoffset = 0,
            attenua = 1,
            attenuacount = 999,
            life = 10,
            isbullet = false,
            isvest = false,
            isignorearmor = false,
            startfunc = function(mj)
              mj:setdata("循环计数", 0)
              mj:setcolor(255, 100, 0)
            end,
            loopfunc = function(mj)
              local dx, dy = mj:getxy()
              mj:changedata("循环计数", UnifyDT)
              if mj:getdata("循环计数") >= 0.05 then
                mj:setdata("循环计数", 0)
                Effectcreate("effect\\BOSS\\BOSS_Wst2 (8).mdl", dx, dy, 0, 4)
                u:buffset(u.handle, 0.55, "暂停")
                u:buffset(u.handle, 0.55, "无敌")
              end
              for _, xq in ac.selector():in_rangexy(dx, dy, 300):isingroup(Group_PlayHero):isnotingroup(g2):ipairs() do
                xq = getunit(xq)
                xq:groupadd(g2)
                xq:setdata("翁斯坦-光耀之雷封锁")
                SetCameraTargetControllerNoZForPlayer(xq.owner, mj.handle, 0, 0, false)
              end
              local x2, y2 = PolarXY(dx, dy, -200, a)
              ForGroupLuaNew(g2, function(xq)
                xq:setxy(x2, y2)
              end)
              if not IsXYinAnyPlayRect(dx, dy) then
                args.stop = true
              end
            end,
            hitfunc = function(mj, damage)
              return damage
            end,
            hitbeforefunc = function(mj, xq, damage2)
            end,
            hitafterfunc = function(mj, xq, damage2)
            end,
            endfunc = function(mj)
              FogEnable(true)
              FogMaskEnable(true)
              local dx, dy = mj:getxy()
              Effectcreate("effect\\BOSS\\BOSS_Wst2 (19).mdl", dx, dy)
              Effectcreate("effect\\BOSS\\BOSS_Wst2 (6).mdl", dx, dy, 0, 3)
              for i = 1, 10 do
                Effectcreate("effect\\BOSS\\BOSS_Wst2 (32).mdl", dx, dy, 0, 5, 0, GetRandomReal(0, 360))
              end
              PlayGlobalSound(boom1)
              if 0 < Group_Counts(g2) then
                local c = Group_Counts(g2)
                local sh = 0.6 * Nandu_Choose
                if c <= 1 and 1.8 <= sh then
                  sh = 1.8
                end
                sh = sh / c
                sh = sh * tg:getmaxhp()
                ForGroupLuaNew(g2, function(__enum_u)
                  local sh2 = sh
                  local xq = __enum_u
                  local sy = xq.ownerid
                  if xq:hasbuff("麻痹") then
                    sh2 = sh2 * 2
                  end
                  if xq:hasbuff("绝对闪避") then
                    sh2 = sh2 * 0.5
                  end
                  if sh2 < xq:gethp() then
                    xq:losshp(u, sh2)
                  elseif xq:getdata("空观剑判定时间") > 0 then
                    xq:setdata("空观剑判定时间", 0)
                    local umc = require("gameplay.hero.heroskill.妖梦.skill")
                    umc["六根清净斩"](xq, u)
                  elseif 0 < xq:getdata("两仪式-无垢识判定时间") then
                    u:setdata("两仪式-无垢识判定时间", 0)
                    local umc = require("gameplay.hero.heroskill.两仪式.skill")
                    umc.VD(xq, u)
                  elseif Nandu_Shenzhao then
                    xq:kill(u.handle)
                  elseif xq:hasbuff("绝对闪避") then
                    xq:losshp(u, sh2)
                    xq:buffset(u.handle, 60, "麻痹")
                  else
                    xq:kill(u.handle)
                  end
                end)
              end
              ForGroupLuaNew(Group_PlayHero, function(xq)
                local sy = xq.ownerid
                xq:deldata("翁斯坦-光耀之雷封锁")
                xq:setdata("锁定时间", 0)
                ResetToGameCameraForPlayer(xq.owner, 0)
                local p = getplayer(xq.owner)
                p:setcameraheight(Cam_height[xq.ownerid], 0)
              end)
              mj:setcolor(255, 255, 255)
            end
          })
        end)
      end)
    end
  }
}

function boss_wst(unit)
  local u = getunit(unit)
  u:setdata("单位-大头像", "ORNSTEIN1_portrait.tga")
  ForGroupLuaNew(Group_PlayHero, function(xq)
    if xq:hasdata("背包-艾露猫") then
      AilumaoSnd(xq, "挑战BOSS")
    end
  end)
  BOSS = u.handle
  u.owner = Player(9)
  u:changeowner(Player(9))
  RewardStop = true
  ForGroupLuaNew(Group_Monster, function(xq)
    if not xq:isboss() then
      xq:kill(BOSS_DEATH, true)
      if xq:isnotingroup(HellGroup) then
        LeftNumofMonster = LeftNumofMonster + 1
      end
    end
  end)
  RewardStop = false
  BossBattle = true
  ExBossBattle = true
  ExtraBattle = true
  ClearBGM()
  PlayGlobalSound(BOSS_Wst_03)
  local npc = getunit(NPC_TIANZI)
  if Morihuanjing_String ~= "雷鸣" then
    npc:setdata("环境变更")
    npc:setdata("翁斯坦天气切换")
  end
  SetTimeOfDay(12)
  u:buffset(u.handle, 16, "无敌")
  u:buffset(u.handle, 16, "暂停")
  u:addstexiao("翁斯坦", "被施加Buff时效果-暂停", function(args)
    local u = args.u
    local soc = args.soc
    if soc.handle ~= u.handle then
      args.time = args.time * 0.05
    end
  end)
  u:addstexiao("翁斯坦", "被施加Buff时效果-石化", function(args)
    local u = args.u
    local soc = args.soc
    if soc.handle ~= u.handle then
      args.time = args.time * 0.05
    end
  end)
  u:addstexiao("翁斯坦", "被施加Buff时效果-僵直", function(args)
    local u = args.u
    local soc = args.soc
    if soc.handle ~= u.handle then
      args.time = args.time * 0.05
    end
  end)
  u:addstexiao("翁斯坦", "施加Buff时效果-麻痹", function(args)
    local u = args.u
    local tg = args.tg
    if (tg:hasdata("英雄-妖梦") or tg.type == HeroType["志贵"] or tg.type == HeroType["两仪式"] or tg.type == HeroType["波风水门"] or tg.type == HeroType["史尔特尔"]) and tg:hasdata("BOSS-翁斯坦") and tg:hasbuff("无敌") then
      args.time = 0
    end
  end)
  CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 3, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 100.0, 100.0, 100.0, 0.0)
  ac.wait(4000, function()
    PlayGlobalSound(BOSS_Wst_04)
    RemoveWeatherEffect(Tqxg)
    Tqxg = AddWeatherEffect(RECT_PlayArea, S2ID("RAhr"))
    EnableWeatherEffect(Tqxg, true)
    ShowUnit(u.handle, true)
    ac.wait(4000, function()
      local tm = 0
      ac.loop(20, function(timer)
        tm = tm + 0.5
        CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 0.0, "war3mapImported\\Ph_BOSS_Wst.tga", tm, tm, tm, 0)
        if 100 <= tm then
          CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 4.0, "war3mapImported\\Ph_BOSS_Wst.tga", 100, 100, 100, 0)
          timer:remove()
        end
      end)
    end)
    ac.wait(12810, function()
      ChangeBGM(BOSS_Wst_01)
    end)
  end)
  ac.wait(12000, function()
    SendMsgAll("|cffff0000猎龙者-翁斯坦|r")
    print("BOSS注册成功:" .. u:getname())
    TriggerRegisterUnitEvent(DamageSystemTrg, u.handle, EVENT_UNIT_DAMAGED)
    TriggerRegisterUnitEvent(MonsterDead, u.handle, EVENT_UNIT_DEATH)
    bosshpattackset(u, true)
    u:setdata("神性", 5)
    u:additem("I0CK")
    u:additem("I0CL")
    BossAggro.register(u)
    u:groupadd(Group_Monster)
    u:groupadd(HellGroup)
    u:addskill("A020")
    u:setdata("系统-BOSS")
    u:addskill("A11G")
    SetUnitPathing(u.handle, false)
    for i = 1, 8 do
      UnitShareVision(u.handle, Player(i - 1), true)
    end
    u:setdata("BOSS-翁斯坦")
    u:setdata("BOSS限伤-单次直伤限伤", 0.01)
    u:setdata("BOSS限伤-单次附伤限伤", 0.005)
    u:setdata("BOSS-强制发动技能", "雷罚")
    japi.SetUnitName(u.handle, "|cFFFF9900翁斯坦|r")
    u:setdata("模型-名字", "|cFFFF9900翁斯坦|r")
    u:setdata("雷属性抗性", 90)
    u:setdata("心灵属性抗性", 25)
    u:setdata("光属性抗性", 75)
    u:setdata("暗属性抗性", 75)
    u:setdata("风属性抗性", 75)
    u:setdata("冰属性抗性", 75)
    u:setdata("水属性抗性", 75)
    u:setdata("火属性抗性", -25)
    BOSS_Kbd = 0
    BOSS_KbdJs = 1
    BOSS_KbdT = 0
    ac.wait(10, function()
      if Nandu_Choose >= 5 or MWTQ_Mw > 0 then
        u:elitesextrachange()
      end
    end)
    u:addstexiao("翁斯坦", "BOSS减伤计算", function(args)
      local u = args.tg
      local soc = args.u
      local info = args.damageinfo
      local sh = info.damage
      local yssh = info.yssh
      sh = sh * 0.5
      if soc:getdata("光明变异数量") > soc:getdata("黑暗变异数量") and (soc:getstate("战士变异") >= 15 or u:hasdata("职业判定-骑士") or u:hasdata("职业判定-战士") or u:hasdata("职业判定-救世主") or u:hasdata("血统判定-英雄")) then
      else
        sh = sh * 0.4
      end
      if u:hasdata("BOSS-施法时间") then
      else
        if Nandu_Shenzhao then
          sh = sh * 0.05
        else
          sh = sh * 0.25
        end
        if not info.ismeleedamage then
          sh = sh * 0.5
        end
      end
      if u:hasdata("翁斯坦-金石之誓") then
        sh = sh * 0.5
      end
      info.damage = sh
    end)
    AddAllSTexiao("BOSS-翁斯坦", "受伤后效果", function(args)
      local u = args.tg
      local hero = args.u
      local info = args.damageinfo
      if info.damage > 0 and u:hasdata("BOSS-翁斯坦") and not hero:hasdata("翁斯坦-免疫雷霆之力时间") then
        local t = 10
        if Nandu_Shenzhao then
          t = 30
        end
        hero:changetimedata("翁斯坦-雷霆之力层数", 1, t)
        if hero:islocal() then
          BuffUI.apply({
            id = "翁斯坦-雷霆之力",
            duration = t + 0.1
          })
        end
      end
    end)
    ac.wait(4000, function()
      ac.loop(1000, function(t)
        local b = true
        if not u:hasdata("翁斯坦-金石之誓") and u:getperhp() <= 50 and Nandu_Choose >= 3 then
          u:setdata("翁斯坦-金石之誓")
          u:addskill("S07V")
        end
        if Nandu_Choose >= 4 and not u:hasdata("翁斯坦-光耀之雷冷却") and (not u:hasdata("光耀之雷冷却中") or Nandu_Shenzhao) and (not (not (u:getperhp() <= 33) or u:hasdata("翁斯坦-光耀之雷33%")) or u:getperhp() <= 66 and not u:hasdata("翁斯坦-光耀之雷66%")) then
          u:setdata("BOSS-强制发动技能", "光耀之雷")
        end
        if Movie_Boolean or u:hasdata("BOSS-施法时间") or u:hasbuff("沉默") then
          b = false
        end
        if b then
          local allowskill = {}
          for index, skill in ipairs(bossskill) do
            if (not (not skill.condition(u) and skill.condition) or u:getdata("BOSS-强制发动技能") == skill.name) and (not u:hasdata(skill.name .. "冷却中") or u:getdata("BOSS-强制发动技能") == skill.name) then
              table.insert(allowskill, skill)
            end
          end
          if 0 < #allowskill then
            local args = {}
            args.u = u
            GroupClearLua(g)
            local b = true
            local skill
            if u:hasdata("BOSS-强制发动技能") then
              for index, dskill in ipairs(allowskill) do
                if u:getdata("BOSS-强制发动技能") == dskill.name then
                  skill = dskill
                  u:deldata("BOSS-强制发动技能")
                  break
                end
              end
            else
              skill = allowskill[GetRandomInt(1, #allowskill)]
            end
            if skill.selectcondition(u) then
              local target = BossAggro.get_target(u)
              if target then
                args.tg = target
              else
                b = false
              end
            end
            if b then
              skill:effect(args)
              if skill.name ~= "光耀之雷" then
                u:settimedata(skill.name .. "冷却中", skill.cd)
              end
              u:buffset(u.handle, skill.skilltime, "暂停")
              u:settimedata("BOSS-施法时间", skill.skillcd)
            end
          end
        end
        if not u:isalive() then
          t:remove()
        end
      end)
    end)
  end)
end
