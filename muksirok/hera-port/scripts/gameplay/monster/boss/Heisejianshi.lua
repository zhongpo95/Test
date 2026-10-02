-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local BossAggro = require("gameplay.monster.boss.aggro")
local g = CreateGroupLua()
local attacksound = {
  geal_attack1,
  geal_attack2,
  geal_attack3,
  geal_attack4
}
local bigboom = {
  geal_bigboom1,
  geal_bigboom2
}
local smallboom = {
  geal_smallboom1,
  geal_smallboom2,
  geal_smallboom3
}
local gesikuangbao
local bossskill = {
  {
    name = "终结",
    skilltime = 0,
    skillcd = 2,
    cd = 10,
    condition = function(u)
      local b = true
      return b
    end,
    selectcondition = function(u)
      local b = true
      local jl = 4000
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
      local boss = args.u
      local mb = args.tg
      local x, y = boss:getxy()
      local txsh = 1000 * boss:getdata("怪物强度")
      boss:buffset(boss.handle, 2, "暂停")
      ac.wait(1, function()
        boss:playsound(geal_jump)
        boss:animeact(2)
        local x2, y2 = mb:getxy()
        local dx, dy = PolarXY(x2, y2, 100, mb:getface())
        local angle = AngleXY(x, y, dx, dy)
        dx, dy = PolarXY(dx, dy, 100, angle + 180)
        local dis = DistanceXY(x, y, dx, dy)
        boss:setface(angle)
        unitmove({
          unit = boss.handle,
          time = 0.5,
          distance = dis,
          angle = angle,
          isfly = true
        })
        Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y, 0, 2)
      end)
      ac.wait(700, function()
        boss:playseensound(bigboom[GetRandomInt(1, #bigboom)])
        x, y = boss:getxy()
        local mx, my = PolarXY(x, y, 100, boss:getface())
        Effectcreate("Gael_05.mdx", mx, my, 0, 5)
        Effectcreate("war3mapImported\\fuzzystomp.mdx", mx, my, 0, 3)
        Effectcreate("war3mapImported\\bbb.mdx", mx, my, 0, 2)
        for _, xq in ac.selector():in_rangexy(mx, my, 525):isingroup(Group_PlayHero):ipairs() do
          xq = getunit(xq)
          DamageUnit({
            unit = xq.handle,
            source = boss.handle,
            damage = txsh,
            level = 1,
            type = "物理",
            isvest = false,
            isattack = true,
            isnoarmor = false,
            element = "无"
          })
          xq:buffset(boss.handle, 0.1, "眩晕")
          xq:buffset(boss.handle, 1, "僵直")
        end
      end)
      ac.wait(2000, function()
        boss:animeact(0)
      end)
    end
  },
  {
    name = "残虐强袭",
    skilltime = 0,
    skillcd = 1,
    cd = 18,
    condition = function(u)
      local b = false
      local jl = 4000
      ForGroupLuaNew(Group_PlayHero, function(xq)
        if xq:isalive() and not xq:hasdata("系统-已删模") and xq.owner ~= Player(PLAYER_NEUTRAL_PASSIVE) and not xq:hasbuff("绝对闪避") and not xq:hasbuff("永恒") then
          local jl2 = DistanceBetweenUnits(xq.handle, u.handle)
          if jl2 <= jl then
            b = true
          end
        end
      end)
      return b
    end,
    selectcondition = function(u)
      local b = true
      local jl = 4000
      ForGroupLuaNew(Group_PlayHero, function(xq)
        if xq:isalive() and not xq:hasdata("系统-已删模") and xq.owner ~= Player(PLAYER_NEUTRAL_PASSIVE) and not xq:hasbuff("绝对闪避") and not xq:hasbuff("永恒") then
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
      local boss = args.u
      local u = args.u
      local mb = args.tg
      local x, y = boss:getxy()
      local txsh = 1000 * boss:getdata("怪物强度")
      local dis = DistanceBetweenUnits(boss.handle, mb.handle)
      local angle = AngleBetweenUnits(boss.handle, mb.handle)
      local maxt = 60
      local maxangle = 15
      if boss:getperhp() <= 66 then
        maxangle = 20
        maxt = 70
      end
      if boss:getperhp() <= 33 or boss:hasdata("格斯-狂暴") then
        maxangle = 25
        maxt = 80
      end
      boss:setface(angle)
      boss:buffset(boss.handle, 1, "暂停")
      boss:buffset(boss.handle, 1, "沉默")
      ac.wait(1, function()
        boss:animeact(4)
      end)
      local b = false
      local tg
      local dt = 0.3
      if dis <= 500 then
        dt = 0.4
      end
      ac.wait(dt * 1000, function()
        boss:playsound(geal_attacklong2)
        boss:effectadd("Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl", "hand left", 3.5)
        boss:effectadd("Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl", "hand right", 3.5)
        local tx = Effectcreate("Gael_07.mdx", x, y, -1, 2, 0, angle, 0, 90)
        local cs2 = 0
        local v = 30
        local cs = 0
        ac.loop(50, function(timer)
          cs = cs + 1
          cs2 = cs2 + 1
          local x, y = boss:getxy()
          local x2, y2 = mb:getxy()
          local angle2 = AngleXY(x, y, x2, y2)
          if v <= 100 then
            v = v + 10
          end
          local deangle = (angle2 - angle) % 360
          if 180 < deangle then
            deangle = deangle - 360
          end
          if deangle >= maxangle then
            deangle = maxangle
          end
          if deangle <= -maxangle then
            deangle = -maxangle
          end
          angle = angle + deangle
          boss:setface(angle)
          local dx, dy = PolarXY(x, y, 50, angle + 90)
          dx, dy = PolarXY(dx, dy, -50, angle)
          SetEffectXY(tx, dx, dy)
          SetEffectAngle(tx, deangle)
          if cs2 == 3 then
            boss:buffset(boss.handle, 1, "暂停")
            boss:buffset(boss.handle, 1, "沉默")
            Effectcreate("war3mapImported\\fuzzystomp.mdx", dx, dy, 0, 1)
            cs2 = 0
          end
          unitmove({
            unit = boss.handle,
            time = 0.5,
            distance = v,
            angle = angle,
            isfly = true
          })
          ForGroupLuaNew(Group_PlayHero, function(xq)
            local dis = DistanceBetweenUnits(xq.handle, boss.handle)
            if dis <= 100 then
              b = true
              tg = xq
            end
          end)
          if cs >= maxt or b then
            boss:playsound(geal_jump)
            boss:buffset(boss.handle, 1.6, "暂停")
            boss:buffset(boss.handle, 1.6, "沉默")
            DestroyEffectLua(tx)
            boss:animeact(5)
            local x, y = boss:getxy()
            local djd = boss:getface()
            local dis
            if cs >= maxt then
              local x2, y2 = mb:getxy()
              dis = DistanceXY(x, y, x2, y2)
              if 500 <= dis then
                dis = 500
              end
            else
              dis = 500
              tg:buffset(tg.handle, 0.8, "暂停")
              unitjump({
                unit = tg.handle,
                time = 0.7,
                distance = 0,
                height = 250,
                angle = djd,
                isfly = true
              })
              ac.timer(35, 20, function()
                local dx, dy = boss:getxy()
                dx, dy = PolarXY(dx, dy, 75, boss:getface())
                tg:setxy(dx, dy)
              end)
              ac.wait(700, function()
                if Nandu_Choose >= 5 then
                  if tg:hasdata("格斯-碎裂印记") then
                    tg:kill(u.handle)
                    tg:deldata("格斯-碎裂印记")
                    if not u:hasdata("格斯-狂战士形态") then
                      u:setdata("格斯-狂战士形态")
                      gesikuangbao()
                      if tg:islocal() then
                        BuffUI.remove("格斯-碎裂印记")
                      end
                    elseif tg:islocal() then
                      PlayGlobalSound(Sound_Boss_Gesi_02)
                      flashphoto({
                        photo = "Ph_Gesi_01.tga",
                        timeout = 0,
                        timehold = 1,
                        timein = 1
                      })
                      BuffUI.remove("格斯-碎裂印记")
                    end
                  else
                    tg:setdata("格斯-碎裂印记", 30)
                    tg:sendmessage("|cFF990000你已经被施加碎裂印记|r")
                    tg:setdata("格斯-碎裂印记免疫时间", 3)
                    if tg:islocal() then
                      BuffUI.apply({
                        id = "格斯-碎裂印记",
                        duration = 30.1
                      })
                    end
                  end
                end
              end)
            end
            unitmove({
              unit = boss.handle,
              time = 0.7,
              distance = dis,
              angle = djd,
              isfly = true
            })
            Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y, 0, 2)
            ac.wait(700, function()
              boss:playseensound(bigboom[GetRandomInt(1, #bigboom)])
              local dx, dy = boss:getxy()
              dx, dy = PolarXY(dx, dy, 75, boss:getface())
              Effectcreate("Gael_05.mdx", dx, dy, 0, 5)
              Effectcreate("war3mapImported\\fuzzystomp.mdx", dx, dy, 0, 3)
              Effectcreate("war3mapImported\\bbb.mdx", dx, dy, 0, 2)
              for _, xq in ac.selector():in_rangexy(dx, dy, 525):isingroup(Group_PlayHero):ipairs() do
                xq = getunit(xq)
                DamageUnit({
                  unit = xq.handle,
                  source = boss.handle,
                  damage = txsh,
                  level = 1,
                  type = "物理",
                  isvest = false,
                  isattack = true,
                  isnoarmor = false,
                  element = "无"
                })
                xq:buffset(boss.handle, 0.1, "眩晕")
                xq:buffset(boss.handle, 1, "僵直")
              end
            end)
            ac.wait(1600, function()
              boss:animeact(0)
            end)
            timer:remove()
          end
        end)
      end)
    end
  },
  {
    name = "迅斩",
    skilltime = 0,
    skillcd = 2,
    cd = 10,
    condition = function(u)
      local b = true
      return b
    end,
    selectcondition = function(u)
      local b = true
      local jl = 1500
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
      local boss = args.u
      local mb = args.tg
      local x, y = boss:getxy()
      local txsh = 1000 * boss:getdata("怪物强度")
      local angle = AngleBetweenUnits(boss.handle, mb.handle)
      boss:setface(angle)
      boss:buffset(boss.handle, 1.8, "暂停")
      ac.wait(1, function()
        boss:playsound(attacksound[GetRandomInt(1, #attacksound)])
        boss:animeact(12)
        local angle = AngleBetweenUnits(boss.handle, mb.handle)
        boss:setface(angle)
        local dis = DistanceBetweenUnits(mb.handle, boss.handle)
        if 300 <= dis then
          dis = 300
        end
        local dg = CreateGroupLua()
        ac.wait(300, function()
          x, y = boss:getxy()
          local tx = Effectcreate("dg_2.mdx", x, y, -1, 1, 200, angle)
          SetEffectColor(tx, 55, 0, 0)
          DestroyEffectLua(tx)
          for _, xq in ac.selector():in_rangexy(x, y, 525):isnotingroup(dg):isingroup(Group_PlayHero):ipairs() do
            xq = getunit(xq)
            xq:groupadd(dg)
            DamageUnit({
              unit = xq.handle,
              source = boss.handle,
              damage = txsh,
              level = 1,
              type = "物理",
              isvest = false,
              isattack = true,
              isnoarmor = false,
              element = "无"
            })
            xq:buffset(boss.handle, 1, "僵直")
          end
          unitmove({
            unit = boss.handle,
            time = 0.2,
            distance = dis,
            angle = boss:getface(),
            isfly = true,
            loops = {
              {
                looptime = 0.02,
                func = function(dx, dy)
                  SetEffectXY(tx, dx, dy)
                  for _, xq in ac.selector():in_rangexy(dx, dy, 525):isnotingroup(dg):isingroup(Group_PlayHero):ipairs() do
                    xq = getunit(xq)
                    xq:groupadd(dg)
                    DamageUnit({
                      unit = xq.handle,
                      source = boss.handle,
                      damage = txsh,
                      level = 1,
                      type = "物理",
                      isvest = false,
                      isattack = true,
                      isnoarmor = false,
                      element = "无"
                    })
                    xq:buffset(boss.handle, 1, "僵直")
                  end
                end
              }
            }
          })
        end)
      end)
      ac.wait(700, function()
        boss:playsound(attacksound[GetRandomInt(1, #attacksound)])
        boss:animeact(7)
        local angle = AngleBetweenUnits(boss.handle, mb.handle)
        boss:setface(angle)
        local dis = DistanceBetweenUnits(mb.handle, boss.handle)
        if 300 <= dis then
          dis = 300
        end
        x, y = boss:getxy()
        Effectcreate("war3mapImported\\bbb.mdl", x, y, 0, 2, 0, GetRandomAngle())
        local tx = Effectcreate("dg_2.mdx", x, y, -1, 1, 200, angle, 180)
        SetEffectColor(tx, 55, 0, 0)
        DestroyEffectLua(tx)
        ac.wait(200, function()
          x, y = boss:getxy()
          local tx2 = Effectcreate("Gael_06.mdx", x, y, 0, 2, 0, GetRandomAngle())
        end)
        local dg = CreateGroupLua()
        for _, xq in ac.selector():in_rangexy(x, y, 525):isnotingroup(dg):isingroup(Group_PlayHero):ipairs() do
          xq = getunit(xq)
          xq:groupadd(dg)
          DamageUnit({
            unit = xq.handle,
            source = boss.handle,
            damage = txsh,
            level = 1,
            type = "物理",
            isvest = false,
            isattack = true,
            isnoarmor = false,
            element = "无"
          })
          xq:buffset(boss.handle, 1, "僵直")
        end
        unitmove({
          unit = boss.handle,
          time = 0.2,
          distance = dis,
          angle = boss:getface(),
          isfly = true,
          loops = {
            {
              looptime = 0.02,
              func = function(dx, dy)
                SetEffectXY(tx, dx, dy)
                for _, xq in ac.selector():in_rangexy(dx, dy, 525):isnotingroup(dg):isingroup(Group_PlayHero):ipairs() do
                  xq = getunit(xq)
                  xq:groupadd(dg)
                  DamageUnit({
                    unit = xq.handle,
                    source = boss.handle,
                    damage = txsh,
                    level = 1,
                    type = "物理",
                    isvest = false,
                    isattack = true,
                    isnoarmor = false,
                    element = "无"
                  })
                  xq:buffset(boss.handle, 1, "僵直")
                end
              end
            }
          }
        })
      end)
      ac.wait(1700, function()
        boss:animeact(0)
      end)
    end
  },
  {
    name = "狼袭",
    skilltime = 0,
    skillcd = 3,
    cd = 10,
    condition = function(u)
      local b = true
      return b
    end,
    selectcondition = function(u)
      local b = true
      local jl = 1500
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
      local boss = args.u
      local mb = args.tg
      local x, y = boss:getxy()
      local txsh = 1000 * boss:getdata("怪物强度")
      local angle = AngleBetweenUnits(boss.handle, mb.handle)
      boss:setface(angle)
      boss:buffset(boss.handle, 2.8, "暂停")
      boss:effectadd("Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl", "hand left", 2.8)
      boss:effectadd("Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl", "hand right", 2.8)
      local dis = DistanceBetweenUnits(mb.handle, boss.handle)
      if 500 <= dis then
        dis = 500
      end
      ac.wait(1, function()
        boss:playsound(attacksound[GetRandomInt(1, #attacksound)])
        boss:animeact(4)
        boss:setface(angle)
        local tx = Effectcreate("Gael_07.mdx", x, y, -1, 2, 0, angle, 0, 90)
        unitmove({
          unit = boss.handle,
          time = 0.3,
          distance = dis,
          angle = boss:getface(),
          isfly = true,
          loops = {
            {
              looptime = 0.03,
              func = function(dx, dy)
                dx, dy = PolarXY(dx, dy, 50, angle + 90)
                dx, dy = PolarXY(dx, dy, -50, angle)
                SetEffectXY(tx, dx, dy)
              end
            }
          },
          endfunc = function(dx, dy)
            DestroyEffectLua(tx)
          end
        })
      end)
      ac.wait(300, function()
        boss:playsound(geal_jump)
        local x, y = boss:getxy()
        Effectcreate("war3mapImported\\fuzzystomp.mdx", x, y, 0, 3)
        Effectcreate("war3mapImported\\bbb.mdl", x, y, 0, 2, 0, GetRandomAngle())
        boss:animeact(5)
        for _, xq in ac.selector():in_rangexy(x, y, 300):isingroup(Group_PlayHero):ipairs() do
          xq = getunit(xq)
          DamageUnit({
            unit = xq.handle,
            source = boss.handle,
            damage = txsh,
            level = 1,
            type = "物理",
            isvest = false,
            isattack = true,
            isnoarmor = false,
            element = "无"
          })
          xq:buffset(boss.handle, 0.1, "眩晕")
          xq:buffset(boss.handle, 1, "僵直")
        end
      end)
      ac.wait(1100, function()
        boss:animeact(6)
        local angle = AngleBetweenUnits(boss.handle, mb.handle)
        boss:setface(angle)
        local dis = DistanceBetweenUnits(mb.handle, boss.handle)
        if 500 <= dis then
          dis = 500
        end
        unitmove({
          unit = boss.handle,
          time = 0.2,
          distance = dis,
          angle = boss:getface(),
          isfly = true
        })
        ac.wait(300, function()
          boss:playsound(attacksound[GetRandomInt(1, #attacksound)])
          local x, y = boss:getxy()
          local tx = Effectcreate("dg_2.mdx", x, y, -1, 1, 350, angle, 90)
          SetEffectColor(tx, 55, 0, 0)
          DestroyEffectLua(tx)
          local dx, dy = PolarXY(x, y, 250, angle)
          Effectcreate("Gael_08.mdx", dx, dy, 0, 1.5, 0, angle)
          local dg = CreateGroupLua()
          for i = -5, 12 do
            local dx, dy = PolarXY(x, y, i * 100, angle)
            for _, xq in ac.selector():in_rangexy(dx, dy, 150):isingroup(Group_PlayHero):isnotingroup(dg):ipairs() do
              xq = getunit(xq)
              xq:groupadd(dg)
              DamageUnit({
                unit = xq.handle,
                source = boss.handle,
                damage = txsh,
                level = 1,
                type = "物理",
                isvest = false,
                isattack = true,
                isnoarmor = false,
                element = "无"
              })
              xq:buffset(boss.handle, 1, "僵直")
            end
          end
        end)
      end)
      ac.wait(2000, function()
        boss:animeact(7)
        local angle = AngleBetweenUnits(boss.handle, mb.handle)
        boss:setface(angle)
        local dis = DistanceBetweenUnits(mb.handle, boss.handle)
        if 500 <= dis then
          dis = 500
        end
        unitmove({
          unit = boss.handle,
          time = 0.2,
          distance = dis,
          angle = boss:getface(),
          isfly = true
        })
        ac.wait(200, function()
          boss:playsound(attacksound[GetRandomInt(1, #attacksound)])
          x, y = boss:getxy()
          Effectcreate("war3mapImported\\bbb.mdl", x, y, 0, 2, 0, GetRandomAngle())
          local tx = Effectcreate("dg_2.mdx", x, y, -1, 1, 200, angle, 180)
          SetEffectColor(tx, 55, 0, 0)
          DestroyEffectLua(tx)
          ac.wait(200, function()
            x, y = boss:getxy()
            local tx2 = Effectcreate("Gael_06.mdx", x, y, 0, 2, 0, GetRandomAngle())
          end)
          for _, xq in ac.selector():in_rangexy(x, y, 525):isingroup(Group_PlayHero):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              unit = xq.handle,
              source = boss.handle,
              damage = txsh,
              level = 1,
              type = "物理",
              isvest = false,
              isattack = true,
              isnoarmor = false,
              element = "无"
            })
            xq:buffset(boss.handle, 1, "僵直")
          end
        end)
      end)
      ac.wait(2800, function()
        boss:animeact(0)
      end)
    end
  },
  {
    name = "血斩",
    skilltime = 0,
    skillcd = 1.5,
    cd = 10,
    condition = function(u)
      local b = true
      return b
    end,
    selectcondition = function(u)
      local b = true
      local jl = 2200
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
      local boss = args.u
      local mb = args.tg
      local x, y = boss:getxy()
      local txsh = 400 * boss:getdata("怪物强度")
      boss:buffset(boss.handle, 0.8, "暂停")
      ac.wait(1, function()
        boss:animeact(6)
      end)
      local angle = AngleBetweenUnits(boss.handle, mb.handle)
      boss:setface(angle)
      unitmove({
        unit = boss.handle,
        time = 0.2,
        distance = -500,
        angle = boss:getface(),
        isfly = true
      })
      local x, y = boss:getxy()
      Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y, 0, 2)
      ac.wait(300, function()
        boss:playsound(attacksound[GetRandomInt(1, #attacksound)])
        local x, y = boss:getxy()
        local tx = Effectcreate("dg_2.mdx", x, y, -1, 1, 350, angle, 90)
        SetEffectColor(tx, 55, 0, 0)
        DestroyEffectLua(tx)
        ac.wait(100, function()
          local dx, dy = boss:getxy()
          local dg = CreateGroupLua()
          local tx = Effectcreate("Gael_11.mdx", dx, dy, -1, 1, 0, angle, 0, 90)
          effectmove({
            effect = tx,
            time = 0.5,
            distance = 2000,
            angle = angle,
            loops = {
              {
                looptime = 0.03,
                func = function(dx, dy)
                  for _, xq in ac.selector():in_rangexy(dx, dy, 300):isingroup(Group_PlayHero):ipairs() do
                    xq = getunit(xq)
                    DamageUnit({
                      unit = xq.handle,
                      source = boss.handle,
                      damage = txsh,
                      level = 1,
                      type = "物理",
                      isvest = false,
                      isattack = false,
                      isnoarmor = false,
                      element = "无"
                    })
                    xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
                  end
                end
              }
            },
            endfunc = function(dx, dy)
              ac.timer(30, 100, function()
                for _, xq in ac.selector():in_rangexy(dx, dy, 300):isingroup(Group_PlayHero):ipairs() do
                  xq = getunit(xq)
                  DamageUnit({
                    unit = xq.handle,
                    source = boss.handle,
                    damage = txsh,
                    level = 1,
                    type = "物理",
                    isvest = false,
                    isattack = false,
                    isnoarmor = false,
                    element = "无"
                  })
                  xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
                end
              end)
              ac.wait(3000, function()
                DestroyEffectLua(tx)
              end)
            end
          })
        end)
      end)
      ac.wait(1500, function()
        boss:animeact(0)
      end)
    end
  },
  {
    name = "狼噬",
    skilltime = 0,
    skillcd = 2,
    cd = 10,
    condition = function(u)
      local b = true
      return b
    end,
    selectcondition = function(u)
      local b = true
      local jl = 2200
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
      local boss = args.u
      local mb = args.tg
      local x, y = boss:getxy()
      local txsh = 1000 * boss:getdata("怪物强度")
      boss:buffset(boss.handle, 2, "暂停")
      ac.wait(1, function()
        boss:playsound(attacksound[GetRandomInt(1, #attacksound)])
        boss:animeact(7)
        local angle = AngleBetweenUnits(boss.handle, mb.handle)
        boss:setface(angle)
        local dis = DistanceBetweenUnits(mb.handle, boss.handle)
        if 400 <= dis then
          dis = 400
        end
        x, y = boss:getxy()
        Effectcreate("war3mapImported\\bbb.mdl", x, y, 0, 2, 0, GetRandomAngle())
        local tx = Effectcreate("dg_2.mdx", x, y, -1, 1, 200, angle, 180)
        SetEffectColor(tx, 55, 0, 0)
        DestroyEffectLua(tx)
        ac.wait(200, function()
          x, y = boss:getxy()
          local tx2 = Effectcreate("Gael_06.mdx", x, y, 0, 2, 0, GetRandomAngle())
        end)
        local dg = CreateGroupLua()
        for _, xq in ac.selector():in_rangexy(x, y, 525):isnotingroup(dg):isingroup(Group_PlayHero):ipairs() do
          xq = getunit(xq)
          xq:groupadd(dg)
          DamageUnit({
            unit = xq.handle,
            source = boss.handle,
            damage = txsh,
            level = 1,
            type = "物理",
            isvest = false,
            isattack = true,
            isnoarmor = false,
            element = "无"
          })
          xq:buffset(boss.handle, 1, "僵直")
        end
        unitmove({
          unit = boss.handle,
          time = 0.2,
          distance = dis,
          angle = boss:getface(),
          isfly = true,
          loops = {
            {
              looptime = 0.02,
              func = function(dx, dy)
                SetEffectXY(tx, dx, dy)
                for _, xq in ac.selector():in_rangexy(dx, dy, 525):isnotingroup(dg):isingroup(Group_PlayHero):ipairs() do
                  xq = getunit(xq)
                  xq:groupadd(dg)
                  DamageUnit({
                    unit = xq.handle,
                    source = boss.handle,
                    damage = txsh,
                    level = 1,
                    type = "物理",
                    isvest = false,
                    isattack = true,
                    isnoarmor = false,
                    element = "无"
                  })
                  xq:buffset(boss.handle, 1, "僵直")
                end
              end
            }
          }
        })
      end)
      ac.wait(800, function()
        boss:playsound(geal_jump)
        x, y = boss:getxy()
        Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y, 0, 2)
        boss:effectadd("Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl", "hand left", 1)
        boss:effectadd("Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl", "hand right", 1)
        boss:animeact(8)
        local angle = AngleBetweenUnits(boss.handle, mb.handle)
        boss:setface(angle)
        local dis = DistanceBetweenUnits(mb.handle, boss.handle)
        if 800 <= dis then
          dis = 800
        end
        unitmove({
          unit = boss.handle,
          time = 0.5,
          distance = dis,
          angle = boss:getface(),
          isfly = true
        })
        ac.wait(800, function()
          boss:playseensound(bigboom[GetRandomInt(1, #bigboom)])
          x, y = boss:getxy()
          local mx, my = PolarXY(x, y, 200, boss:getface())
          Effectcreate("Gael_05.mdx", mx, my, 0, 5)
          Effectcreate("war3mapImported\\fuzzystomp.mdx", mx, my, 0, 3)
          Effectcreate("war3mapImported\\bbb.mdx", mx, my, 0, 2)
          for _, xq in ac.selector():in_rangexy(mx, my, 525):isingroup(Group_PlayHero):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              unit = xq.handle,
              source = boss.handle,
              damage = txsh,
              level = 1,
              type = "物理",
              isvest = false,
              isattack = true,
              isnoarmor = false,
              element = "无"
            })
            xq:buffset(boss.handle, 0.1, "眩晕")
            xq:buffset(boss.handle, 1, "僵直")
          end
        end)
        ac.wait(1000, function()
          boss:animeact(0)
        end)
      end)
    end
  },
  {
    name = "狼灭",
    skilltime = 0,
    skillcd = 3,
    cd = 10,
    condition = function(u)
      local b = true
      return b
    end,
    selectcondition = function(u)
      local b = true
      local jl = 2200
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
      local boss = args.u
      local mb = args.tg
      local x, y = boss:getxy()
      local txsh = 1000 * boss:getdata("怪物强度")
      boss:buffset(boss.handle, 2.5, "暂停")
      ac.wait(1, function()
        boss:animeact(6)
        boss:animespeed(0.25)
        boss:effectadd("Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl", "hand left", 2)
        boss:effectadd("Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl", "hand right", 2)
        local angle = AngleBetweenUnits(boss.handle, mb.handle)
        boss:setface(angle)
        local dis = DistanceBetweenUnits(mb.handle, boss.handle)
        if 400 <= dis then
          dis = 400
        end
        ac.wait(300, function()
          boss:animespeed(1)
          unitmove({
            unit = boss.handle,
            time = 0.2,
            distance = dis,
            angle = boss:getface(),
            isfly = true
          })
          ac.wait(300, function()
            boss:playsound(attacksound[GetRandomInt(1, #attacksound)])
            local x, y = boss:getxy()
            local tx = Effectcreate("dg_2.mdx", x, y, -1, 1, 350, angle, 90)
            SetEffectColor(tx, 55, 0, 0)
            DestroyEffectLua(tx)
            local dx, dy = PolarXY(x, y, 250, angle)
            Effectcreate("Gael_08.mdx", dx, dy, 0, 1.5, 0, angle)
            local dg = CreateGroupLua()
            for i = -5, 12 do
              local dx, dy = PolarXY(x, y, i * 100, angle)
              for _, xq in ac.selector():in_rangexy(dx, dy, 150):isingroup(Group_PlayHero):isnotingroup(dg):ipairs() do
                xq = getunit(xq)
                xq:groupadd(dg)
                DamageUnit({
                  unit = xq.handle,
                  source = boss.handle,
                  damage = txsh,
                  level = 1,
                  type = "物理",
                  isvest = false,
                  isattack = true,
                  isnoarmor = false,
                  element = "无"
                })
                xq:buffset(boss.handle, 1, "僵直")
              end
            end
          end)
        end)
      end)
      ac.wait(1100, function()
        boss:playsound(geal_jump)
        boss:animeact(8)
        local angle = AngleBetweenUnits(boss.handle, mb.handle)
        boss:setface(angle)
        local dis = DistanceBetweenUnits(mb.handle, boss.handle)
        if 800 <= dis then
          dis = 800
        end
        unitmove({
          unit = boss.handle,
          time = 0.5,
          distance = dis,
          angle = boss:getface(),
          isfly = true
        })
        ac.wait(800, function()
          boss:playseensound(bigboom[GetRandomInt(1, #bigboom)])
          x, y = boss:getxy()
          local mx, my = PolarXY(x, y, 200, boss:getface())
          Effectcreate("Gael_05.mdx", mx, my, 0, 5)
          Effectcreate("war3mapImported\\fuzzystomp.mdx", mx, my, 0, 3)
          Effectcreate("war3mapImported\\bbb.mdx", mx, my, 0, 2)
          for _, xq in ac.selector():in_rangexy(mx, my, 525):isingroup(Group_PlayHero):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              unit = xq.handle,
              source = boss.handle,
              damage = txsh,
              level = 1,
              type = "物理",
              isvest = false,
              isattack = true,
              isnoarmor = false,
              element = "无"
            })
            xq:buffset(boss.handle, 0.1, "眩晕")
            xq:buffset(boss.handle, 1, "僵直")
          end
        end)
        ac.wait(1000, function()
          boss:animeact(0)
        end)
      end)
    end
  },
  {
    name = "屠戮",
    skilltime = 0,
    skillcd = 7,
    cd = 10,
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
      local boss = args.u
      local mb = args.tg
      local x, y = boss:getxy()
      local txsh = 1000 * boss:getdata("怪物强度")
      local angle = AngleBetweenUnits(boss.handle, mb.handle)
      boss:setface(angle)
      boss:buffset(boss.handle, 6, "暂停")
      ac.wait(1, function()
        boss:playsound(attacksound[GetRandomInt(1, #attacksound)])
        boss:animeact(12)
        local angle = AngleBetweenUnits(boss.handle, mb.handle)
        boss:setface(angle)
        local dis = DistanceBetweenUnits(mb.handle, boss.handle)
        if 400 <= dis then
          dis = 400
        end
        ac.wait(300, function()
          x, y = boss:getxy()
          local tx = Effectcreate("dg_2.mdx", x, y, -1, 1, 200, angle)
          SetEffectColor(tx, 55, 0, 0)
          DestroyEffectLua(tx)
          local dg = CreateGroupLua()
          for _, xq in ac.selector():in_rangexy(x, y, 525):isnotingroup(dg):isingroup(Group_PlayHero):ipairs() do
            xq = getunit(xq)
            xq:groupadd(dg)
            DamageUnit({
              unit = xq.handle,
              source = boss.handle,
              damage = txsh,
              level = 1,
              type = "物理",
              isvest = false,
              isattack = true,
              isnoarmor = false,
              element = "无"
            })
            xq:buffset(boss.handle, 1, "僵直")
          end
          unitmove({
            unit = boss.handle,
            time = 0.2,
            distance = dis,
            angle = boss:getface(),
            isfly = true,
            loops = {
              {
                looptime = 0.02,
                func = function(dx, dy)
                  SetEffectXY(tx, dx, dy)
                  for _, xq in ac.selector():in_rangexy(dx, dy, 525):isnotingroup(dg):isingroup(Group_PlayHero):ipairs() do
                    xq = getunit(xq)
                    xq:groupadd(dg)
                    DamageUnit({
                      unit = xq.handle,
                      source = boss.handle,
                      damage = txsh,
                      level = 1,
                      type = "物理",
                      isvest = false,
                      isattack = true,
                      isnoarmor = false,
                      element = "无"
                    })
                    xq:buffset(boss.handle, 1, "僵直")
                  end
                end
              }
            }
          })
        end)
      end)
      ac.wait(700, function()
        boss:playsound(attacksound[GetRandomInt(1, #attacksound)])
        boss:animeact(7)
        local angle = AngleBetweenUnits(boss.handle, mb.handle)
        boss:setface(angle)
        local dis = DistanceBetweenUnits(mb.handle, boss.handle)
        if 400 <= dis then
          dis = 400
        end
        x, y = boss:getxy()
        Effectcreate("war3mapImported\\bbb.mdl", x, y, 0, 2, 0, GetRandomAngle())
        local tx = Effectcreate("dg_2.mdx", x, y, -1, 1, 200, angle, 180)
        SetEffectColor(tx, 55, 0, 0)
        DestroyEffectLua(tx)
        local dg = CreateGroupLua()
        for _, xq in ac.selector():in_rangexy(x, y, 525):isnotingroup(dg):isingroup(Group_PlayHero):ipairs() do
          xq = getunit(xq)
          xq:groupadd(dg)
          DamageUnit({
            unit = xq.handle,
            source = boss.handle,
            damage = txsh,
            level = 1,
            type = "物理",
            isvest = false,
            isattack = true,
            isnoarmor = false,
            element = "无"
          })
          xq:buffset(boss.handle, 1, "僵直")
        end
        unitmove({
          unit = boss.handle,
          time = 0.2,
          distance = dis,
          angle = boss:getface(),
          isfly = true,
          loops = {
            {
              looptime = 0.02,
              func = function(dx, dy)
                SetEffectXY(tx, dx, dy)
                for _, xq in ac.selector():in_rangexy(dx, dy, 525):isnotingroup(dg):isingroup(Group_PlayHero):ipairs() do
                  xq = getunit(xq)
                  xq:groupadd(dg)
                  DamageUnit({
                    unit = xq.handle,
                    source = boss.handle,
                    damage = txsh,
                    level = 1,
                    type = "物理",
                    isvest = false,
                    isattack = true,
                    isnoarmor = false,
                    element = "无"
                  })
                  xq:buffset(boss.handle, 1, "僵直")
                end
              end
            }
          }
        })
        ac.wait(200, function()
          boss:playsound(attacksound[GetRandomInt(1, #attacksound)])
          x, y = boss:getxy()
          local tx2 = Effectcreate("Gael_06.mdx", x, y, 0, 2, 0, GetRandomAngle())
        end)
      end)
      ac.wait(1600, function()
        boss:animeact(9)
      end)
      ac.wait(1900, function()
        x, y = boss:getxy()
        local mx, my = PolarXY(x, y, 200, boss:getface())
        Effectcreate("Gael_02.mdx", mx, my, 0, 2)
        Effectcreate("Gael_04.mdx", mx, my, 0, 2)
        boss:effectadd("Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl", "hand left", 3)
        boss:effectadd("Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl", "hand right", 3)
        for _, xq in ac.selector():in_rangexy(mx, my, 350):isingroup(Group_PlayHero):ipairs() do
          xq = getunit(xq)
          DamageUnit({
            unit = xq.handle,
            source = boss.handle,
            damage = txsh,
            level = 1,
            type = "魔力",
            isvest = false,
            isattack = false,
            isnoarmor = false,
            element = "无"
          })
          xq:buffset(boss.handle, 0.1, "眩晕")
          xq:buffset(boss.handle, 1, "僵直")
        end
      end)
      ac.wait(2800, function()
        x, y = boss:getxy()
        Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y, 0, 2)
        local angle = AngleBetweenUnits(boss.handle, mb.handle)
        boss:setface(angle)
        local dis = DistanceBetweenUnits(mb.handle, boss.handle)
        if 1000 <= dis then
          dis = 1000
        end
        local tx = EffectcreateArgs({
          effect = "Gael_01.mdx",
          x = x,
          y = y,
          time = 0.5,
          height = 100
        })
        unitmove({
          unit = boss.handle,
          time = 0.5,
          distance = dis,
          angle = boss:getface(),
          isfly = true,
          loops = {
            {
              looptime = 0.03,
              func = function(dx, dy)
                SetEffectXY(tx, dx, dy)
                for _, xq in ac.selector():in_rangexy(dx, dy, 525):isingroup(Group_PlayHero):ipairs() do
                  xq = getunit(xq)
                  DamageUnit({
                    unit = xq.handle,
                    source = boss.handle,
                    damage = 0.25 * txsh,
                    level = 1,
                    type = "物理",
                    isvest = false,
                    isattack = true,
                    isnoarmor = false,
                    element = "无"
                  })
                  xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
                end
              end
            }
          }
        })
      end)
      ac.wait(3500, function()
        x, y = boss:getxy()
        boss:playseensound(smallboom[GetRandomInt(1, #smallboom)])
        local mx, my = PolarXY(x, y, 200, boss:getface())
        Effectcreate("Gael_03.mdx", mx, my, 0, 2)
        Effectcreate("war3mapImported\\fuzzystomp.mdx", mx, my, 0, 3)
        Effectcreate("war3mapImported\\bbb.mdx", mx, my, 0, 2)
        for _, xq in ac.selector():in_rangexy(mx, my, 375):isingroup(Group_PlayHero):ipairs() do
          xq = getunit(xq)
          DamageUnit({
            unit = xq.handle,
            source = boss.handle,
            damage = txsh,
            level = 1,
            type = "物理",
            isvest = false,
            isattack = true,
            isnoarmor = false,
            element = "无"
          })
          xq:buffset(boss.handle, 0.1, "眩晕")
          xq:buffset(boss.handle, 1, "僵直")
        end
      end)
      ac.wait(3900, function()
        x, y = boss:getxy()
        Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y, 0, 2)
        boss:animeact(2)
        local x2, y2 = mb:getxy()
        local dx, dy = PolarXY(x2, y2, 250, mb:getface())
        local angle = AngleXY(x, y, dx, dy)
        dx, dy = PolarXY(dx, dy, 100, angle + 180)
        local dis = DistanceXY(x, y, dx, dy)
        boss:setface(angle)
        unitmove({
          unit = boss.handle,
          time = 0.5,
          distance = dis,
          angle = angle,
          isfly = true
        })
        ac.wait(700, function()
          boss:playseensound(bigboom[GetRandomInt(1, #bigboom)])
          x, y = boss:getxy()
          local mx, my = PolarXY(x, y, 100, boss:getface())
          Effectcreate("Gael_05.mdx", mx, my, 0, 5)
          Effectcreate("war3mapImported\\fuzzystomp.mdx", mx, my, 0, 3)
          Effectcreate("war3mapImported\\bbb.mdx", mx, my, 0, 2)
          for _, xq in ac.selector():in_rangexy(mx, my, 525):isingroup(Group_PlayHero):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              unit = xq.handle,
              source = boss.handle,
              damage = txsh,
              level = 1,
              type = "物理",
              isvest = false,
              isattack = true,
              isnoarmor = false,
              element = "无"
            })
            xq:buffset(boss.handle, 0.1, "眩晕")
            xq:buffset(boss.handle, 1, "僵直")
          end
        end)
        ac.wait(2000, function()
          boss:animeact(0)
        end)
      end)
    end
  }
}

function boss_heisejianshi(unit)
  local u = getunit(unit)
  u:setdata("BOSS-格斯")
  SendMsgAll("|cFFCC0000黑暗野兽|r")
  u:setdata("单位-大头像", "gazi_portrait.tga")
  ForGroupLuaNew(Group_PlayHero, function(xq)
    if xq:hasdata("背包-艾露猫") then
      AilumaoSnd(xq, "挑战BOSS")
    end
  end)
  ChangeBGM(BGM_Heisejianshi)
  RewardStop = true
  ForGroupLuaNew(Group_Monster, function(xq)
    if not xq:isboss() then
      xq:kill(BOSS_DEATH, true)
      if xq:isnotingroup(HellGroup) then
        LeftNumofMonster = LeftNumofMonster + 1
      end
    end
  end)
  u.owner = Player(9)
  u:changeowner(Player(9))
  RewardStop = false
  BossBattle = true
  ExBossBattle = true
  BOSS = u.handle
  TriggerRegisterUnitEvent(DamageSystemTrg, u.handle, EVENT_UNIT_DAMAGED)
  TriggerRegisterUnitEvent(MonsterDead, u.handle, EVENT_UNIT_DEATH)
  bosshpattackset(u, true)
  ac.wait(10, function()
    if Nandu_Choose >= 5 or MWTQ_Mw > 0 then
      u:elitesextrachange()
    end
  end)
  u:setdata("神性", 5)
  BossAggro.register(u)
  u:setskilldatareal("A07T", 109, 500 * u:getdata("怪物强度"))
  u:groupadd(Group_Monster)
  u:groupadd(HellGroup)
  u:addskill("A020")
  u:setdata("系统-BOSS")
  u:addskill("A11G")
  SetUnitPathing(u.handle, false)
  for i = 1, 8 do
    UnitShareVision(u.handle, Player(i - 1), true)
  end
  u:setdata("光属性抗性", 0)
  u:setdata("暗属性抗性", 90)
  u:setdata("风属性抗性", 50)
  u:setdata("雷属性抗性", 50)
  u:setdata("冰属性抗性", 50)
  u:setdata("水属性抗性", 50)
  u:setdata("火属性抗性", 50)
  u:setdata("心灵属性抗性", 0)
  u:setdata("BOSS限伤-单次直伤限伤", 0.01)
  u:setdata("BOSS限伤-单次附伤限伤", 0.005)
  if Nandu_Shenzhao then
    u:setdata("风属性抗性", 75)
    u:setdata("雷属性抗性", 75)
    u:setdata("冰属性抗性", 75)
    u:setdata("水属性抗性", 75)
    u:setdata("火属性抗性", 75)
  end
  
  function gesikuangbao()
    u:groupremove(HpGroup)
    u:setdata("生命值百分比", 100)
    u:sethp(100, true)
    u:buffset(u.handle, 3, "无敌")
    u:buffset(u.handle, 3, "沉默")
    u:buffset(u.handle, 3, "暂停")
    u:setdata("格斯-狂战士形态")
    u:setdata("格斯-狂暴")
    u:setdata("BOSS限伤-单次直伤限伤", 0.005)
    u:setdata("BOSS限伤-单次附伤限伤", 0.0025)
    PlayGlobalSound(Sound_Boss_Gesi_01)
    flashphoto({
      photo = "Ph_Gesi_02.tga",
      timeout = 1,
      timehold = 1.5,
      timein = 1
    })
    PlayBGM({
      bgm = BGM_Gesi_01,
      time = 120,
      ID = 231
    })
    ac.wait(117000, function()
      StopSoundBJ(BGM_Gesi_01, false)
      ac.wait(1000, function()
        ChangeBGM(BGM_Gesi_01)
      end)
    end)
    ForGroupLuaNew(Group_PlayHero, function(xq)
      xq:buffset(xq.handle, 3, "永恒")
    end)
    if Nandu_Shenzhao then
      local x, y = getunit(NPC_Molijiedian):getxy()
      local dis = 2200
      local v = 0.01
      local ax, ay = x, y
      local txz = {}
      for i = 1, 24 do
        local a = i * 15
        local dx, dy = PolarXY(ax, ay, dis, a)
        local tx = Effectcreate("texiao_gazi_bj.mdx", dx, dy, -1, 1, 90)
        table.insert(txz, tx)
      end
      ac.loop(30, function(timer)
        ForGroupLuaNew(Group_PlayHero, function(xq)
          if xq:isalive() then
            local x, y = xq:getxy()
            local jl = DistanceXY(x, y, ax, ay)
            if jl > dis then
              local angle = AngleXY(ax, ay, x, y)
              local cx, cy = PolarXY(ax, ay, dis - 20, angle)
              xq:setxy(cx, cy)
            end
          end
        end)
        if not u:isalive() then
          for index, value in ipairs(txz) do
            DestroyEffectLua(value)
          end
          txz = nil
          timer:remove()
        end
      end)
    end
  end
  
  u:addstexiao("黑色剑士", "BOSS减伤计算", function(args)
    local u = args.tg
    local soc = args.u
    local info = args.damageinfo
    local sh = info.damage
    local yssh = info.yssh
    sh = sh * 0.5
    if info.damagetype == "物理" then
      sh = sh * 0.5
    end
    if u:hasdata("格斯-狂暴") then
      sh = sh * 0.5
    end
    if u:hasdata("格斯-狂战士形态") then
      sh = sh * 0.5
    end
    info.damage = sh
  end)
  u:addstexiao("BOSS-格斯", "伤害显示后效果", function(args)
    local u = args.tg
    local soc = args.u
    local info = args.damageinfo
    if Nandu_Choose >= 5 and not u:hasdata("格斯-狂战士形态") then
      u:changetimedata("格斯-累积受伤", info.damage, 5)
    end
  end)
  ac.loop(1000, function(timer)
    if u:isalive() then
      if not u:hasdata("格斯-狂战士形态") and Nandu_Choose >= 5 and u:getdata("格斯-累积受伤") >= 0.15 * u:getmaxhp() then
        gesikuangbao()
      end
      ForGroupLuaNew(Group_PlayHero, function(xq)
        if xq:hasdata("格斯-碎裂印记") then
          xq:changedata("格斯-碎裂印记", -1)
          if xq:getdata("格斯-碎裂印记") <= 0 then
            xq:deldata("格斯-碎裂印记")
          end
        end
        if xq:hasdata("格斯-碎裂印记免疫时间") then
          xq:changedata("格斯-碎裂印记免疫时间", -1)
          if 0 >= xq:getdata("格斯-碎裂印记免疫时间") then
            xq:deldata("格斯-碎裂印记免疫时间")
          end
        end
        if 0 < xq:getdata("格斯-撕裂流血层数") then
          xq:losshp(u, 0, 0, 1 * xq:getdata("格斯-撕裂流血层数"))
        end
      end)
    else
      ForGroupLuaNew(Group_PlayHero, function(xq)
        if xq:hasdata("格斯-碎裂印记") then
          xq:deldata("格斯-碎裂印记")
          if xq:islocal() then
            BuffUI.remove("格斯-碎裂印记")
          end
        end
      end)
      timer:remove()
    end
  end)
  AddAllSTexiao("BOSS-格斯", "受伤后效果", function(args)
    local u = args.tg
    local hero = args.u
    local info = args.damageinfo
    if info.damage > 0 and u:hasdata("BOSS-格斯") then
      if hero:hasdata("格斯-碎裂印记") then
        if not hero:hasdata("格斯-碎裂印记免疫时间") then
          hero:kill(u.handle)
          hero:deldata("格斯-碎裂印记")
          hero:setdata("格斯-碎裂印记免疫时间", 5)
          if not u:hasdata("格斯-狂战士形态") then
            u:setdata("格斯-狂战士形态")
            gesikuangbao()
            if hero:islocal() then
              BuffUI.remove("格斯-碎裂印记")
            end
          elseif hero:islocal() then
            PlayGlobalSound(Sound_Boss_Gesi_02)
            flashphoto({
              photo = "Ph_Gesi_01.tga",
              timeout = 0,
              timehold = 1,
              timein = 1
            })
            BuffUI.remove("格斯-碎裂印记")
          end
        end
      else
        local t = 30
        if Nandu_Shenzhao then
          t = 60
        end
        hero:changetimedata("格斯-撕裂流血层数", 1, t)
        if hero:islocal() then
          BuffUI.apply({
            id = "格斯-撕裂流血",
            duration = t + 0.1
          })
        end
        if 5 <= Nandu_Choose and hero:getdata("格斯-撕裂流血层数") >= 10 then
          hero:setdata("格斯-碎裂印记", 30)
          hero:sendmessage("|cFF990000你已经被施加碎裂印记|r")
          hero:setdata("格斯-碎裂印记免疫时间", 3)
          if hero:islocal() then
            BuffUI.apply({
              id = "格斯-碎裂印记",
              duration = 30.1
            })
          end
        end
      end
    end
  end)
  u:buffset(u.handle, 5, "无敌")
  u:buffset(u.handle, 5, "暂停")
  ac.wait(5000, function()
    ac.loop(1000, function(t)
      local b = true
      if not u:hasdata("格斯-狂暴") and u:getperhp() <= 50 and Nandu_Choose >= 3 then
        u:setdata("格斯-狂暴")
      end
      if Movie_Boolean or u:hasdata("BOSS-施法时间") or u:hasbuff("沉默") then
        b = false
      end
      if b then
        local allowskill = {}
        for index, skill in ipairs(bossskill) do
          if (skill.condition(u) or not skill.condition) and not u:hasdata(skill.name .. "冷却中") then
            table.insert(allowskill, skill)
          end
        end
        if 0 < #allowskill then
          local args = {}
          args.u = u
          GroupClearLua(g)
          local b = true
          local skill = allowskill[GetRandomInt(1, #allowskill)]
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
            u:settimedata(skill.name .. "冷却中", skill.cd)
            u:buffset(u.handle, skill.skilltime, "暂停")
            local add = 1
            if u:getperhp() <= 66 then
              add = 0.5
            end
            if u:getperhp() <= 33 or u:hasdata("格斯-狂暴") then
              add = 0
            end
            u:settimedata("BOSS-施法时间", skill.skillcd + add)
            SendMsgAll("|cFFFF0000" .. skill.name .. "|r")
          end
        end
      end
      if not u:isalive() then
        ac.wait(2000, function()
          StopSoundBJ(BGM_Gesi_01, false)
          ForGroupLuaNew(Group_PlayHero, function(xq)
            if xq:hasdata("格斯-碎裂印记") then
              xq:deldata("格斯-碎裂印记")
              if xq:islocal() then
                BuffUI.remove("格斯-碎裂印记")
              end
            end
          end)
        end)
        t:remove()
      end
    end)
  end)
end
