-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local slk = require("jass.slk")
local skill = {
  {
    name = "C呆-Z",
    skill = "A0J2",
    func = function(self, args)
      local u = getunit(args.unit)
      local sy = u.ownerid
      local x, y = u:getxy()
      x = x - 16
      y = y - 16
      local zt = 0.8
      if u:hasdata("卡斯特-调停者的指引") then
        zt = zt * 0.5
      end
      SendMsgAll("|cFFFF99FF[|r|cFFF59BFE阿|r|cFFEB9CFC尔|r|cFFE19EFB托|r|cFFD89FF9莉|r|cFFCEA1F8雅|r|cFFC4A3F7]|r|cFFBAA4F5希|r|cFFB0A6F4望|r|cFFA6A8F3的|r|cFF9DA9F1魅|r|cFF93ABF0力|r")
      if u:hasdata("卡斯特-调停者的指引") then
        u:setskillcd(self.skill, 90)
      end
      u:buffset(u.handle, zt, "暂停")
      ac.wait(1, function()
        local yx = {}
        local count
        if u:hasdata("Caber-杖形态") then
          count = 6
          yx[1] = Hero_Caber_20
          yx[2] = Hero_Caber_21
          yx[3] = Hero_Caber_22
          yx[4] = Hero_Caber_23
          yx[5] = Hero_Caber_24
          yx[6] = Hero_Caber_25
        else
          count = 3
          yx[1] = Hero_Caber_30
          yx[2] = Hero_Caber_31
          yx[3] = Hero_Caber_32
        end
        u:animeact(6)
        u:animespeed(2)
        u:playsound(yx[GetRandomInt(1, count)])
        u:playsound(bas1)
        u:playsound(bac231)
        EffectcreateArgs({
          effect = "AATX\\[AATxNew]Blue18.mdl",
          x = x,
          y = y,
          size = 1.5
        })
        EffectcreateArgs({
          effect = "AATX\\[AATxNew]Blue06.mdl",
          x = x,
          y = y,
          size = 1.5
        })
      end)
      ac.wait(500, function()
        EffectcreateArgs({
          effect = "AATX\\[AATxNew]Blue38.mdl",
          x = x,
          y = y,
          size = 1.5,
          height = 90
        })
        u:addskill("S06Y")
        local add = 0.5
        ForGroupLuaNew(Group_PlayHero, function(xq)
          local sy2 = xq.ownerid
          ChangeValue(DamageSystem_EndSh, sy2, 0.1 * add)
          ChangeValue(Hero_Tili_Huifu, sy2, 2)
        end)
        ac.wait(15000, function()
          u:delskill("S06Y")
          ForGroupLuaNew(Group_PlayHero, function(xq)
            local sy2 = xq.ownerid
            ChangeValue(DamageSystem_EndSh, sy2, 0.1 * -add)
            ChangeValue(Hero_Tili_Huifu, sy2, -2)
          end)
        end)
      end)
      ac.wait(800, function()
        u:animespeed(1)
      end)
    end
  },
  {
    name = "C呆-X",
    skill = "A0JL",
    func = function(self, args)
      local u = getunit(args.unit)
      local tg = getunit(args.target)
      local sy = u.ownerid
      local sy2 = tg.ownerid
      local x, y = u:getxy()
      x = x - 16
      y = y - 16
      local zt = 0.8
      if u:hasdata("卡斯特-调停者的指引") then
        zt = zt * 0.5
      end
      if u:hasdata("卡斯特-调停者的指引") then
        u:setskillcd(self.skill, 90)
      end
      tg:sendmessage("|cFFFF99FF[|r|cFFF49BFE阿|r|cFFEA9CFC尔|r|cFFDF9EFA托|r|cFFD4A0F9莉|r|cFFCAA2F8雅|r|cFFBFA4F6]|r|cFFB4A5F4湖|r|cFFAAA7F3之|r|cFF9FA9F2加|r|cFF94AAF0护|r")
      u:buffset(u.handle, zt, "暂停")
      ac.wait(1, function()
        local yx = {}
        local count
        if u:hasdata("Caber-杖形态") then
          count = 6
          yx[1] = Hero_Caber_20
          yx[2] = Hero_Caber_21
          yx[3] = Hero_Caber_22
          yx[4] = Hero_Caber_23
          yx[5] = Hero_Caber_24
          yx[6] = Hero_Caber_25
        else
          count = 3
          yx[1] = Hero_Caber_30
          yx[2] = Hero_Caber_31
          yx[3] = Hero_Caber_32
        end
        u:animeact(6)
        u:animespeed(2)
        u:playsound(yx[GetRandomInt(1, count)])
        u:playsound(bas1)
        u:playsound(bac231)
        EffectcreateArgs({
          effect = "AATX\\[AATxNew]Blue18.mdl",
          x = x,
          y = y,
          size = 1.5
        })
        EffectcreateArgs({
          effect = "AATX\\[AATxNew]Blue06.mdl",
          x = x,
          y = y,
          size = 1.5
        })
      end)
      ac.wait(500, function()
        EffectcreateArgs({
          effect = "AATX\\[AATxNew]Blue38.mdl",
          x = x,
          y = y,
          size = 1.5,
          height = 90
        })
        local dhp = 2500 + u:getdata("魔力值") * 1
        local zs = 1 + 0.05 * u:getlevel()
        if u.handle ~= tg.handle then
          ChangeTimeValue(DamageSystem_Shjc, sy2, 0.1 * zs, 30)
        end
        if not tg:hasdata("Caber-湖之护盾") then
          tg:setdata("Caber-湖之护盾", dhp)
          Hdzflash(tg)
          ac.wait(15000, function()
            if tg:hasdata("Caber-湖之护盾") then
              tg:deldata("Caber-湖之护盾")
              Hdzflash(tg)
            end
          end)
        end
      end)
      ac.wait(800, function()
        u:animespeed(1)
      end)
    end
  },
  {
    name = "C呆-C-仗",
    skill = "A0JQ",
    func = function(self, args)
      local u = getunit(args.unit)
      local tg = getunit(args.target)
      local sy = u.ownerid
      local sy2 = tg.ownerid
      local x, y = u:getxy()
      x = x - 16
      y = y - 16
      local zt = 0.8
      if u:hasdata("卡斯特-调停者的指引") then
        zt = zt * 0.5
      end
      if u:hasdata("卡斯特-调停者的指引") then
        u:setskillcd(self.skill, 90)
      end
      tg:sendmessage("|cFFFF99FF[|r|cFFF49BFE阿|r|cFFEA9CFC尔|r|cFFDF9EFA托|r|cFFD4A0F9莉|r|cFFCAA2F8雅|r|cFFBFA4F6]|r|cFFB4A5F4仗|r|cFFAAA7F3之|r|cFF9FA9F2授|r|cFF94AAF0予|r")
      u:buffset(u.handle, zt, "暂停")
      ac.wait(1, function()
        local yx = {}
        local count
        u:animeact(6)
        u:animespeed(2)
        u:playsound(Hero_Caber_26)
        u:playsound(bas1)
        u:playsound(bac231)
        EffectcreateArgs({
          effect = "AATX\\[AATxNew]Blue18.mdl",
          x = x,
          y = y,
          size = 1.5
        })
        EffectcreateArgs({
          effect = "AATX\\[AATxNew]Blue06.mdl",
          x = x,
          y = y,
          size = 1.5
        })
      end)
      ac.wait(500, function()
        EffectcreateArgs({
          effect = "AATX\\[AATxNew]Blue38.mdl",
          x = x,
          y = y,
          size = 1.5,
          height = 90
        })
        local all = u:getdata("显示-伤害加成")
        local add = 0.5 + 0.5 * all
        ChangeTimeValue(DamageSystem_Shjc, sy2, 0.1 * add, 15)
        local addfs = 0.05 * Correction_Magic[sy2]
        ChangeTimeValue(Correction_Magic, sy2, addfs, 15)
      end)
      ac.wait(800, function()
        u:animespeed(1)
      end)
    end
  },
  {
    name = "C呆-C-剑",
    skill = "A0JU",
    func = function(self, args)
      local u = getunit(args.unit)
      local tg = getunit(args.target)
      local sy = u.ownerid
      local sy2 = tg.ownerid
      local x, y = u:getxy()
      x = x - 16
      y = y - 16
      local zt = 0.8
      if u:hasdata("卡斯特-调停者的指引") then
        zt = zt * 0.5
      end
      if u:hasdata("卡斯特-调停者的指引") then
        u:setskillcd(self.skill, 90)
      end
      tg:sendmessage("|cFFFF99FF[|r|cFFFF9DEE阿|r|cFFFFA2DD尔|r|cFFFFA6CC托|r|cFFFFAABB莉|r|cFFFFAEAA雅|r|cFFFFB299]|r|cFFFFB788剑|r|cFFFFBB77之|r|cFFFFBF66授|r|cFFFFC455予|r")
      u:buffset(u.handle, zt, "暂停")
      ac.wait(1, function()
        local yx = {}
        u:animeact(6)
        u:animespeed(2)
        local count = 3
        yx[1] = Hero_Caber_30
        yx[2] = Hero_Caber_31
        yx[3] = Hero_Caber_32
        u:playsound(yx[GetRandomInt(1, count)])
        u:playsound(bas1)
        u:playsound(bac231)
        EffectcreateArgs({
          effect = "AATX\\[AATxNew]Blue18.mdl",
          x = x,
          y = y,
          size = 1.5
        })
        EffectcreateArgs({
          effect = "AATX\\[AATxNew]Blue06.mdl",
          x = x,
          y = y,
          size = 1.5
        })
      end)
      ac.wait(500, function()
        EffectcreateArgs({
          effect = "AATX\\[AATxNew]Blue38.mdl",
          x = x,
          y = y,
          size = 1.5,
          height = 90
        })
        local all = u:getdata("显示-伤害加成")
        local add = 0.5 + 0.5 * all
        ChangeTimeValue(DamageSystem_Shjc, sy2, 0.1 * add, 15)
        local addfs = 0.5 * Correction_Jzsh[sy2]
        ChangeTimeValue(Correction_Jzsh, sy2, 0.1 * addfs, 15)
      end)
      ac.wait(800, function()
        u:animespeed(1)
      end)
    end
  },
  {
    name = "C呆-V",
    skill = "A0JV",
    func = function(self, args)
      local u = getunit(args.unit)
      local tg = getunit(args.target)
      local sy = u.ownerid
      local sy2 = tg.ownerid
      local x, y = u:getxy()
      x = x - 16
      y = y - 16
      if not u:hasdata("Caber-妖精眼开启") then
        if u:getdata("Caber-精神值") < 10 then
          u:sendmessage("|cFFCC66FF精神值不足|r")
          return
        end
        u:playsound(Hero_Caber_33)
        u:setdata("Caber-妖精眼开启")
        u:sendmessage("|cFFCC66FF开启妖精眼|r")
      else
        u:deldata("Caber-妖精眼开启")
        u:sendmessage("|cFFCC66FF关闭妖精眼|r")
      end
    end
  },
  {
    name = "C呆-仗-A",
    skill = "A0CF",
    func = function(self, args)
      local u = getunit(args.unit)
      local sy = u.ownerid
      local x, y = u:getxy()
      local x2 = args.x
      local y2 = args.y
      local angle = AngleXY(x, y, x2, y2)
      local dis = DistanceXY(x, y, x2, y2)
      local b = false
      if u:hasdata("Caber-仗加持") then
        u:deldata("Caber-仗加持")
        local tl = 5
        if u:hasdata("卡斯特-调停者的指引") then
          tl = 4
        end
        if u:lossstamina(tl) then
          if not u:hasdata("C呆-语音SA冷却") then
            local yx = {}
            yx[1] = Hero_Caber_24
            yx[2] = Hero_Caber_25
            yx[3] = Hero_Caber_26
            yx[4] = Hero_Caber_33
            u:playsound(yx[GetRandomInt(1, 4)])
            u:settimedata("C呆-语音SA冷却", 10)
          end
          EffectcreateArgs({
            effect = "AATX\\[AATxNew]Blue12.mdl",
            x = x,
            y = y,
            size = 2
          })
          EffectcreateArgs({
            effect = "AATX\\[AATxNew]Colour07.mdl",
            x = x,
            y = y,
            size = 5
          })
          EffectcreateArgs({
            effect = "AATX\\[AATxNew]Blue43.mdl",
            x = x,
            y = y
          })
          EffectcreateArgs({
            effect = "AATX\\[AATxNew]Hit25.mdl",
            x = x,
            y = y,
            size = 3
          })
          u:playsound(bac368)
          ac.wait(1, function()
            u:animeact(10)
          end)
          for _, xq in ac.selector():in_rangexy(x, y, 800):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            xq:effectadd("AATX\\[AATxNew]Blue30.mdl", "chest")
            xq:buffset(u.handle, 1, "僵直")
            unitmove({
              unit = xq.handle,
              time = 1,
              distance = GetRandomReal(1000, 1400),
              angle = AngleBetweenUnits(u.handle, xq.handle)
            })
          end
        else
          u:sendmessage("|cFFFF3300体力值不足|r")
        end
        return
      end
      if u:hasdata("Caber-枪支类型") then
        local itemtype = GetItemTypeId(u:getdata("装备枪支"))
        local bb = getunit(Beibao[sy])
        local dy
        local b2 = false
        for i = 1, 6 do
          local wp = u:getcountitem(i)
          b2 = bulletjudge(u.handle, GetItemTypeId(wp), u:getdata("装备枪支"))
          if b2 then
            dy = wp
            break
          end
        end
        if not b2 then
          for i = 1, 6 do
            local wp = bb:getcountitem(i)
            b2 = bulletjudge(u.handle, GetItemTypeId(wp), u:getdata("装备枪支"))
            if b2 then
              dy = wp
              break
            end
          end
        end
        local lx = u:getdata("Caber-枪支类型")
        local dylx
        if b2 then
          dylx = GetItemTypeId(dy)
        else
          if lx == 1 then
            dylx = S2ID("I000")
          end
          if lx == 2 then
            dylx = S2ID("I00E")
          end
          if lx == 3 then
            dylx = S2ID("I003")
          end
        end
        local zdl
        if lx == 1 then
          zdl = 5
        end
        if lx == 2 then
          if GetData(dylx, "子弹类型") == 5 then
            zdl = 1
          else
            zdl = 10
          end
        end
        if lx == 3 then
          zdl = 1
        end
        if b2 then
          if zdl <= GetItemCharges(dy) then
            ChangeItemCount(dy, -1 * zdl)
          else
            u:sendmessage("|cFFFF3300弹药不足|r")
            return
          end
        end
        if not u:hasdata("C呆-普攻语音冷却") then
          local yx = {}
          yx[1] = Hero_Caster_01
          yx[2] = Hero_Caster_02
          yx[3] = Hero_Caster_03
          yx[4] = Hero_Caster_04
          yx[5] = Hero_Caster_05
          yx[6] = Hero_Caster_06
          yx[7] = Hero_Caster_07
          u:playsound(yx[GetRandomInt(1, 7)])
          u:settimedata("C呆-普攻语音冷却", 4)
        end
        if lx == 1 then
          local txsh = 1.5 * GetData(itemtype, "伤害修正") * GetData(dylx, "伤害")
          Effectcreate("AATX\\[AATxNew]Blue06.mdl", x, y)
          Effectcreate("AATX\\[AATxNew]White04.mdl", x, y)
          u:playsound(bac313)
          ac.wait(1, function()
            u:animeact(2)
            u:animespeed(2)
            ac.wait(700, function()
              u:animespeed(1)
            end)
          end)
          local count = 5
          for i = 1, count do
            local csa
            if u:hasdata("卡斯特-调停者的指引") then
              csa = math.floor(32 * (dis / 2700))
            else
              csa = math.floor(32 * (dis / 1800))
            end
            if csa < 2 then
              csa = 2
            end
            local beita, beita2
            if GetRandom100(50) then
              beita = GetRandomReal(0, 75)
              beita2 = 180 - beita * 2
              beita2 = beita2 / csa
            else
              beita = GetRandomReal(-75, 0)
              beita2 = 180 + beita * 2
              beita2 = beita2 / (-1 * csa)
            end
            local r = dis / 2 / math.cos(beita)
            beita = beita + angle
            local x3, y3 = PolarXY(x, y, r, beita)
            local gama = beita + 180
            local cs = 0
            local h = 75
            local h1 = 225 / (csa / 2)
            local h2 = 300 / (csa / 2)
            local b3 = false
            local tx = Effectcreate("AATX\\[AATxNew]Tile15.mdl", x, y, -1, 1)
            ac.loop(32, function(timer)
              cs = cs + 1
              gama = gama + beita2
              local x4, y4 = PolarXY(x3, y3, r, gama)
              SetEffectXY(tx, x4, y4)
              if cs <= csa / 2 then
                h = h + h1
              else
                h = h - h2
              end
              SetEffectHeight(tx, h)
              for _, xq in ac.selector():in_rangexy(x4, y4, 90):is_enemy(u.handle):ipairs() do
                b3 = true
                break
              end
              if b3 or cs == csa then
                DestroyEffectLua(tx)
                Effectcreate("ATX\\[ATxNew]ShockBoom_12.mdl", x4, y4)
                for _, xq in ac.selector():in_rangexy(x4, y4, 150):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  xq:effectadd("AATX\\[AATxNew]Blue30.mdl", "chest")
                  DamageUnit({
                    bj = "C呆(机体)",
                    unit = xq.handle,
                    source = u.handle,
                    damage = txsh,
                    level = 1,
                    type = "魔力",
                    isvest = false,
                    isattack = false,
                    isnoarmor = false,
                    element = "无",
                    extradata = {
                      "法术",
                      "魔导",
                      "枪械"
                    }
                  })
                  if u:hasdata("卡斯特-调停者的指引") and not xq:hasdata("调停者的指引冷却") then
                    xq:settimedata("调停者的指引冷却", 0.1)
                    xq:changetimedata("调停者的指引-额外受伤", 0.02, 30)
                  end
                end
                if cs == csa then
                else
                  StopSoundBJ(bac368, false)
                end
                PlaySoundOnUnitBJ(bac368, 100, u.handle)
                timer:remove()
              end
            end)
          end
        end
        if lx == 2 then
          local txsh = 1.25 * GetData(itemtype, "伤害修正") * GetData(dylx, "伤害")
          local shsj = GetData(itemtype, "穿透衰减")
          Effectcreate("AATX\\[AATxNew]Blue06.mdl", x, y)
          Effectcreate("AATX\\[AATxNew]White04.mdl", x, y)
          u:playsound(bac156)
          ac.wait(1, function()
            u:animeact(4)
            u:animespeed(2)
            ac.wait(700, function()
              u:animespeed(1)
            end)
          end)
          ac.wait(200, function()
            local txmj = u:createunit("u01X", x, y, angle)
            ac.wait(1, function()
              txmj:animeact("birth")
              txmj:animespeed(2.5)
              local tt
              if u:hasdata("卡斯特-调停者的指引") then
                tt = 0.05
              else
                tt = 0.2
              end
              ac.wait(tt * 1000, function()
                local g = CreateGroupLua()
                local gama = angle
                for i = 1, 20 do
                  local r = 100 * i
                  local x4, y4 = PolarXY(x, y, r, gama)
                  for _, xq in ac.selector():in_rangexy(x4, y4, 170):is_enemy(u.handle):isnotingroup(g):ipairs() do
                    xq = getunit(xq)
                    xq:groupadd(g)
                    xq:effectadd("AATX\\[AATxNew]Blue30.mdl", "chest")
                    DamageUnit({
                      bj = "C呆(机体)",
                      unit = xq.handle,
                      source = u.handle,
                      damage = txsh,
                      level = 1,
                      type = "魔力",
                      isvest = false,
                      isattack = false,
                      isnoarmor = false,
                      element = "无",
                      extradata = {
                        "法术",
                        "魔导",
                        "枪械"
                      }
                    })
                    txsh = txsh * shsj
                    if u:hasdata("卡斯特-调停者的指引") and not xq:hasdata("调停者的指引冷却") then
                      xq:settimedata("调停者的指引冷却", 0.1)
                      xq:changetimedata("调停者的指引-额外受伤", 0.02, 30)
                    end
                  end
                end
              end)
              ac.wait(250, function()
                txmj:animeact("stand")
                txmj:animespeed(1)
                ac.wait(500, function()
                  txmj:animeact("death")
                  txmj:timetoremove(0.35)
                end)
              end)
            end)
          end)
        end
        if lx == 3 then
          local txsh = 0.75 * GetData(dylx, "弹片数") * GetData(itemtype, "伤害修正") * GetData(dylx, "伤害")
          Effectcreate("AATX\\[AATxNew]Blue06.mdl", x, y)
          Effectcreate("AATX\\[AATxNew]White04.mdl", x, y)
          u:playsound(bac340)
          ac.wait(1, function()
            u:animeact(3)
            u:animespeed(2)
            ac.wait(700, function()
              u:animespeed(1)
            end)
          end)
          local tt
          if u:hasdata("卡斯特-调停者的指引") then
            tt = 0.05
          else
            tt = 0.2
          end
          ac.wait(tt * 1000, function()
            u:playsound(bac347)
            local aerfa = angle - 100
            local r = 220
            local r2 = 50
            local g = CreateGroupLua()
            for i = 1, 4 do
              aerfa = aerfa + 40
              local x3, y3 = PolarXY(x, y, r, aerfa)
              EffectcreateArgs({
                effect = "AATX\\[AATxNew]Blue44.mdl",
                x = x3,
                y = y3,
                size = 2,
                zxz = aerfa,
                xxz = 90
              })
              x3, y3 = PolarXY(x, y, r2, aerfa)
              Effectcreate("ATX\\[ATxNew]ShockBoom_12.mdl", x3, y3)
              for _, xq in ac.selector():in_rangexy(x3, y3, 300):is_enemy(u.handle):isnotingroup(g):ipairs() do
                xq = getunit(xq)
                xq:groupadd(g)
                xq:effectadd("AATX\\[AATxNew]Blue30.mdl", "chest")
                DamageUnit({
                  bj = "C呆(机体)",
                  unit = xq.handle,
                  source = u.handle,
                  damage = txsh,
                  level = 1,
                  type = "魔力",
                  isvest = false,
                  isattack = false,
                  isnoarmor = false,
                  element = "无",
                  extradata = {
                    "法术",
                    "魔导",
                    "枪械"
                  }
                })
                xq:buffset(u.handle, 0.5, "眩晕")
                if u:hasdata("卡斯特-调停者的指引") and not xq:hasdata("调停者的指引冷却") then
                  xq:settimedata("调停者的指引冷却", 0.1)
                  xq:changetimedata("调停者的指引-额外受伤", 0.02, 30)
                end
              end
            end
          end)
        end
      else
        u:sendmessage("|cFF3399FF需要装备枪支|r")
      end
    end
  },
  {
    name = "C呆-仗-R",
    skill = "A0CY",
    func = function(self, args)
      local u = getunit(args.unit)
      local sy = u.ownerid
      local x, y = u:getxy()
      local x2 = args.x
      local y2 = args.y
      local angle = AngleXY(x, y, x2, y2)
      local dis = DistanceXY(x, y, x2, y2)
      local b = false
      if u:hasdata("Caber-仗加持") then
        u:deldata("Caber-仗加持")
        local tl = 3.5
        if u:hasdata("卡斯特-调停者的指引") then
          tl = 2.5
        end
        if u:lossstamina(tl) then
          local txsh = 2000 + u:getint() * 75 * (1 + 0.015 * u:getlevel())
          if not u:hasdata("C呆-普攻语音冷却") then
            local yx = {}
            yx[1] = Hero_Caber_23
            yx[2] = Hero_Caber_24
            yx[3] = Hero_Caber_25
            yx[4] = Hero_Caber_26
            u:playsound(yx[GetRandomInt(1, 4)])
            u:settimedata("C呆-普攻语音冷却", 4)
          end
          u:playsound(bac222)
          EffectcreateArgs({
            effect = "ATX\\[ATxNew]Magic_42.mdl",
            x = x2,
            y = y2,
            size = 3
          })
          ac.wait(1, function()
            u:animeact(7)
            u:animespeed(2)
            ac.wait(300, function()
              u:animeact(9)
            end)
            ac.wait(600, function()
              u:animespeed(1)
              u:playsound(bac237)
              Effectcreate("AATX\\[AATxNew]Blue08.mdl", x2, y2, 1.8, 5)
            end)
          end)
          ac.wait(1800, function()
            Effectcreate("AATX\\[AATxNew]Fire19_C.mdl", x2, y2, 2, 2)
            u:playsound(bac301)
            ac.timer(125, 16, function()
              for _, xq in ac.selector():in_rangexy(x2, y2, 530):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                DamageUnit({
                  bj = "C呆(机体)",
                  unit = xq.handle,
                  source = u.handle,
                  damage = txsh,
                  level = 1,
                  type = "魔力",
                  isvest = false,
                  isattack = false,
                  isnoarmor = false,
                  element = "无",
                  extradata = {"法术", "魔导"}
                })
                if u:hasdata("卡斯特-调停者的指引") and not xq:hasdata("调停者的指引冷却") then
                  xq:settimedata("调停者的指引冷却", 0.1)
                  xq:changetimedata("调停者的指引-额外受伤", 0.02, 30)
                end
              end
            end)
          end)
        else
          u:sendmessage("|cFFFF3300体力值不足|r")
        end
        return
      end
      if u:hasdata("Caber-枪支类型") then
        local itemtype = GetItemTypeId(u:getdata("装备枪支"))
        local bb = getunit(Beibao[sy])
        local dy
        local b2 = false
        for i = 1, 6 do
          local wp = u:getcountitem(i)
          b2 = bulletjudge(u.handle, GetItemTypeId(wp), u:getdata("装备枪支"))
          if b2 then
            dy = wp
            break
          end
        end
        if not b2 then
          for i = 1, 6 do
            local wp = bb:getcountitem(i)
            b2 = bulletjudge(u.handle, GetItemTypeId(wp), u:getdata("装备枪支"))
            if b2 then
              dy = wp
              break
            end
          end
        end
        local lx = u:getdata("Caber-枪支类型")
        local dylx
        if b2 then
          dylx = GetItemTypeId(dy)
        else
          if lx == 1 then
            dylx = S2ID("I000")
          end
          if lx == 2 then
            dylx = S2ID("I00E")
          end
          if lx == 3 then
            dylx = S2ID("I003")
          end
        end
        local zdl
        if lx == 1 then
          zdl = 25
        end
        if lx == 2 then
          if GetData(dylx, "子弹类型") == 5 then
            zdl = 3
          else
            zdl = 25
          end
        end
        if lx == 3 then
          zdl = 5
        end
        if b2 then
          if zdl <= GetItemCharges(dy) then
            ChangeItemCount(dy, -1 * zdl)
          else
            u:sendmessage("|cFFFF3300弹药不足|r")
            return
          end
        end
        if not u:hasdata("C呆-普攻语音冷却") then
          local yx = {}
          yx[1] = Hero_Caster_01
          yx[2] = Hero_Caster_02
          yx[3] = Hero_Caster_03
          yx[4] = Hero_Caster_04
          yx[5] = Hero_Caster_05
          yx[6] = Hero_Caster_06
          yx[7] = Hero_Caster_07
          u:playsound(yx[GetRandomInt(1, 7)])
          u:settimedata("C呆-普攻语音冷却", 4)
        end
        if lx == 1 then
          local txsh = 1.25 * GetData(itemtype, "伤害修正") * GetData(dylx, "伤害")
          local zt = 0.4
          if u:hasdata("卡斯特-调停者的指引") then
            zt = zt * 0.7
          end
          u:buffset(u.handle, zt, "暂停")
          Effectcreate("AATX\\[AATxNew]Blue06.mdl", x, y)
          Effectcreate("AATX\\[AATxNew]White04.mdl", x, y)
          u:playsound(bac75)
          ac.wait(1000, function()
            u:playsound(bac288)
          end)
          ac.wait(1, function()
            u:animeact(16)
            u:animespeed(2)
            ac.wait(700, function()
              u:animespeed(1)
            end)
          end)
          for i = 1, 10 do
            local tx = Effectcreate("AATX\\[AATxNew]Blue42.mdl", x, y, 1, 1, 75)
            local r = GetRandomReal(0, 500)
            local a2 = GetRandomReal(0, 360)
            local x4, y4 = PolarXY(x2, y2, r, a2)
            local da = AngleXY(x, y, x4, y4)
            local dl = DistanceXY(x, y, x4, y4)
            effectjump({
              effect = tx,
              time = 0.75,
              distance = dl,
              height = 500,
              angle = da
            })
            ac.wait(1000, function()
              Effectcreate("AATX\\[AATxNew]Fire19_C.mdl", x4, y4, 2, 0.5)
              ac.timer(250, 8, function()
                for _, xq in ac.selector():in_rangexy(x2, y2, 175):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  DamageUnit({
                    bj = "C呆(机体)",
                    unit = xq.handle,
                    source = u.handle,
                    damage = txsh,
                    level = 1,
                    type = "魔力",
                    isvest = false,
                    isattack = false,
                    isnoarmor = false,
                    element = "无",
                    extradata = {"法术", "魔导"}
                  })
                  if u:hasdata("卡斯特-调停者的指引") and not xq:hasdata("调停者的指引冷却") then
                    xq:settimedata("调停者的指引冷却", 0.1)
                    xq:changetimedata("调停者的指引-额外受伤", 0.02, 30)
                  end
                end
              end)
            end)
          end
        end
        if lx == 2 then
          local txsh = 1.125 * GetData(itemtype, "伤害修正") * GetData(dylx, "伤害")
          local zt = 0.45
          if u:hasdata("卡斯特-调停者的指引") then
            zt = zt * 0.7
          end
          u:buffset(u.handle, zt, "暂停")
          local shsj = 1 - (1 - GetData(itemtype, "穿透衰减")) * 0.5
          Effectcreate("AATX\\[AATxNew]Blue06.mdl", x, y)
          Effectcreate("AATX\\[AATxNew]White04.mdl", x, y)
          u:playsound(bac77)
          ac.timer(50, 8, function()
            Effectcreate("AATX\\[AATxNew]Yellow01.mdl", x, y, 0, 1, 90, GetRandomReal(0, 360))
          end)
          ac.wait(1, function()
            u:animeact(17)
            u:animespeed(2)
            ac.wait(500, function()
              u:animeact(19)
              u:animespeed(1)
              u:playsound(bac158)
            end)
          end)
          ac.wait(450, function()
            local txmj = u:createunit("u01X", x, y, angle)
            ac.wait(1, function()
              txmj:animeact("birth")
              txmj:animespeed(2.5)
              ac.wait(250, function()
                local txmj2 = u:createunit("u0A6", x, y, angle)
                txmj:animeact("stand")
                txmj:animespeed(1)
                local g = CreateGroupLua()
                local gama = angle
                for i = 1, 20 do
                  local r = 100 * i
                  local x4, y4 = PolarXY(x, y, r, gama)
                  for _, xq in ac.selector():in_rangexy(x4, y4, 190):is_enemy(u.handle):isnotingroup(g):ipairs() do
                    xq = getunit(xq)
                    xq:groupadd(g)
                    xq:effectadd("AATX\\[AATxNew]Blue30.mdl", "chest")
                    DamageUnit({
                      bj = "C呆(机体)",
                      unit = xq.handle,
                      source = u.handle,
                      damage = txsh,
                      level = 1,
                      type = "魔力",
                      isvest = false,
                      isattack = false,
                      isnoarmor = false,
                      element = "无",
                      extradata = {"法术", "魔导"}
                    })
                    txsh = txsh * shsj
                    if u:hasdata("卡斯特-调停者的指引") and not xq:hasdata("调停者的指引冷却") then
                      xq:settimedata("调停者的指引冷却", 0.1)
                      xq:changetimedata("调停者的指引-额外受伤", 0.02, 30)
                    end
                  end
                end
                ac.wait(500, function()
                  txmj:animeact("death")
                  txmj:timetoremove(0.35)
                  txmj2:animeact("death")
                  txmj2:timetoremove(0.35)
                end)
              end)
            end)
          end)
        end
        if lx == 3 then
          local txsh = 0.75 * GetData(itemtype, "伤害修正") * GetData(dylx, "伤害")
          local zs = GetData(dylx, "弹片数") * 1
          local zt = 0.4
          if u:hasdata("卡斯特-调停者的指引") then
            zt = zt * 0.7
          end
          u:buffset(u.handle, zt, "暂停")
          Effectcreate("AATX\\[AATxNew]Blue06.mdl", x, y)
          Effectcreate("AATX\\[AATxNew]White04.mdl", x, y)
          u:playsound(bac121)
          ac.wait(1, function()
            u:animeact(13)
            u:animespeed(1.5)
            ac.wait(1000, function()
              u:animespeed(1)
            end)
          end)
          ac.wait(500, function()
            u:playsound(bac162)
          end)
          local a2 = angle + 240
          local a3 = 120 / (zs - 1)
          a2 = a2 + a3
          local dl = dis + 300
          local csa = 16
          for i = 1, math.floor(zs) do
            a2 = a2 - a3
            local x3, y3 = PolarXY(x2, y2, dl, a2)
            local da = AngleXY(x3, y3, x2, y2)
            local dl2 = DistanceXY(x2, y2, x3, y3)
            dl2 = dl2 * 2
            local tx = Effectcreate("war3mapImported\\80.mdl", x3, y3, -1, -1, 70, da)
            SetEffectColor(tx, 255, 255, 0)
            Effectcreate("AATX\\[AATxNew]Yellow08.mdl", x3, y3, 0, 1, 125)
            dl2 = dl2 / csa
            ac.wait(500, function()
              local cs = 0
              local g = CreateGroupLua()
              local x4, y4 = x3, y3
              ac.loop(32, function(timer)
                cs = cs + 1
                x4, y4 = PolarXY(x4, y4, dl2, da)
                SetEffectXY(tx, x4, y4)
                Effectcreate("AATX\\[AATxNew]Yellow04.mdl", x4, y4)
                Effectcreate("Abilities\\Weapons\\BallistaMissile\\BallistaImpact.mdl", x4, y4)
                for _, xq in ac.selector():in_rangexy(x4, y4, 200):is_enemy(u.handle):isnotingroup(g):ipairs() do
                  xq = getunit(xq)
                  xq:groupadd(g)
                  xq:effectadd("ATX\\[ATxNew]Thunder_12.mdl", "origin")
                  DamageUnit({
                    bj = "C呆(机体)",
                    unit = xq.handle,
                    source = u.handle,
                    damage = txsh,
                    level = 1,
                    type = "魔力",
                    isvest = false,
                    isattack = false,
                    isnoarmor = false,
                    element = "无",
                    extradata = {"法术", "魔导"}
                  })
                  if u:hasdata("卡斯特-调停者的指引") and not xq:hasdata("调停者的指引冷却") then
                    xq:settimedata("调停者的指引冷却", 0.1)
                    xq:changetimedata("调停者的指引-额外受伤", 0.02, 30)
                  end
                end
                if cs == csa then
                  DestroyEffectLua(tx)
                  Effectcreate("AATX\\[AATxNew]Yellow08.mdl", x4, y4, 0, 1, 125)
                  timer:remove()
                end
              end)
            end)
          end
        end
      else
        u:sendmessage("|cFF3399FF需要装备枪支|r")
      end
    end
  },
  {
    name = "C呆-仗-S",
    skill = "A0D6",
    func = function(self, args)
      local u = getunit(args.unit)
      local sy = u.ownerid
      local x, y = u:getxy()
      if u:hasdata("Caber-仗加持") then
        u:deldata("Caber-仗加持")
        if u:getpermp() <= 20 then
          u:sendmessage("|cFF0041FF魔力不足|r")
          return
        end
        if u:hasdata("卡斯特-踏影的卡文南") and not u:hasdata("卡文南加强") then
          u:setdata("卡文南加强")
          u:changedata("闪避值", 25)
          ChangeValue(HeroMenu_Sbxs, sy, 0.1)
        end
        local skill
        if u:hasdata("系统-飞行状态") then
          skill = "A0S7"
        else
          skill = "A0K7"
        end
        u:addskill(skill)
        u:delskill(skill)
        u:banskill("A0JU", false)
        u:banskill("A0FX", false)
        u:banskill("A0FY", false)
        u:banskill("A0JQ", true)
        u:banskill("A0CY", true)
        u:banskill("A0ED", true)
        u:banskill("A0FS", true)
        u:delskill("A00B")
        u:addskill("A00B")
        u:setskillforever("A0GT")
        u:setskillforever("A0GR")
        u:banskill("A0GT", false)
        u:banskill("A0GR", false)
        u:banweaponskill()
        Effectcreate("ATX\\[ATxNew]White_15.mdl", x, y, 0, 2)
        u:playsound(bac28)
        u:deldata("Caber-杖形态")
        u:setdata("Caber-剑形态")
        u:setdata("C呆-抑制魔力恢复", 0.01)
        ModelReSet({
          u = u,
          modelicon = "Hero_Caber_T2_TX.tga"
        })
        u:setdata("位移技能-Q", S2ID("A0FY"))
        u:setdata("位移技能-W", S2ID("A0FX"))
        if not u:hasdata("Caber-剑状态消耗标记") then
          u:setdata("Caber-剑状态消耗标记")
          ac.loop(250, function(timer)
            local unittype = GetUnitTypeId(u.handle)
            if unittype == S2ID("H02J") or unittype == S2ID("H02K") then
              if not u:hasdata("死亡状态") and u:isalive() then
                local dmp = 0.5 + 0.005 * u:getmaxmp()
                dmp = dmp * 0.25
                if dmp > u:getmp() then
                  x, y = u:getxy()
                  if u:hasdata("卡文南加强") then
                    u:deldata("卡文南加强")
                    u:changedata("闪避值", -25)
                    ChangeValue(HeroMenu_Sbxs, sy, -0.1)
                  end
                  u:setmp(0)
                  if u:hasdata("系统-飞行状态") then
                    skill = "A0S2"
                  else
                    skill = "A0M6"
                  end
                  u:addskill(skill)
                  u:delskill(skill)
                  Effectcreate("ATX\\[ATxNew]White_15.mdl", x, y, 0, 2)
                  u:sendmessage("|cFFFFCC33魔力不足,强制切换状态|r")
                  u:playsound(bac28)
                  u:setdata("Caber-杖形态")
                  u:deldata("Caber-剑形态")
                  ModelReSet({
                    u = u,
                    modelicon = "Hero_Caber_T1_TX.tga"
                  })
                  u:banskill("A0JU", true)
                  u:banskill("A0FX", true)
                  u:banskill("A0FY", true)
                  u:banskill("A0GT", true)
                  u:banskill("A0GR", true)
                  u:banskill("A0JQ", false)
                  u:banskill("A0CY", false)
                  u:banskill("A0ED", false)
                  u:banskill("A0FS", false)
                  u:setdata("位移技能-Q", S2ID("A0FS"))
                  u:setdata("位移技能-W", S2ID("A0ED"))
                  u:banweaponskill(true)
                  u:delskill("A00B")
                  u:addskill("A00B")
                else
                  u:curemp(-1 * dmp)
                end
              end
            else
              u:deldata("Caber-剑状态消耗标记")
              timer:remove()
            end
          end)
        end
        if not u:hasdata("C呆-切换语音冷却") then
          do
            local yx = {}
            yx[1] = Hero_Caster_11
            yx[2] = Hero_Caster_12
            u:playsound(yx[GetRandomInt(1, 2)])
            u:settimedata("C呆-切换语音冷却", 60)
          end
        end
      else
        u:effectadd("AATX\\[AATxNew]White41.mdl", "weapon")
        u:settimedata("Caber-仗加持", 1)
      end
    end
  },
  {
    name = "C呆-仗-Q",
    skill = "A0FS",
    func = function(self, args)
      local u = getunit(args.unit)
      local sy = u.ownerid
      local x, y = u:getxy()
      local angle = u:getface()
      local b = false
      if u:hasbuff("缠绕") then
        u:setskillcd(self.skill, 0.01)
        u:sendmessage("|cFFFF3300缠绕中|r")
        return
      end
      local tl = 1
      if u:lossstamina(tl) then
      else
        u:setskillcd(self.skill, 0.01)
        u:sendmessage("|cFFFF3300体力值不足|r")
        return
      end
      if u:hasdata("Caber-仗加持") then
        u:deldata("Caber-仗加持")
        tl = 1
        if u:hasdata("卡斯特-调停者的指引") then
          tl = 0
        end
        if u:lossstamina(tl) then
          local txsh1 = 2500 + u:getint() * 50 * (1 + 0.015 * u:getlevel())
          local txsh2 = 5000 + u:getint() * 75 * (1 + 0.015 * u:getlevel())
          if not u:hasdata("C呆-位移语音冷却") then
            local yx = {}
            yx[1] = Hero_Caber_20
            yx[2] = Hero_Caber_21
            yx[3] = Hero_Caber_22
            yx[4] = Hero_Caber_23
            yx[5] = Hero_Caber_24
            yx[6] = Hero_Caber_25
            yx[7] = Hero_Caber_26
            u:playsound(yx[GetRandomInt(1, 7)])
            u:settimedata("C呆-位移语音冷却", 4)
          end
          local zt = 0.6
          if u:hasdata("卡斯特-调停者的指引") then
            zt = zt * 0.7
          end
          u:buffset(u.handle, zt, "暂停")
          unitmove({
            unit = u.handle,
            time = 0.2,
            distance = 600,
            angle = angle + 180,
            endfunc = function()
              x, y = u:getxy()
              u:setdata("位移点X", x)
              u:setdata("位移点Y", y)
            end
          })
          if u:getdata("绝对闪避时间") == 0 then
            u:setdata("刷新Q时间", 0.2)
          end
          movexg(u.handle, 0.3, self.skill, "Q", "C呆-仗-Q")
          ac.wait(1, function()
            u:animeact(15)
            u:animespeed(4)
            u:playsound(bac1)
            ac.wait(200, function()
              Effectcreate("AATX\\[AATxNew]Blue06.mdl", x, y)
              Effectcreate("AATX\\[AATxNew]White04.mdl", x, y)
              u:playsound(bac75)
              ac.wait(1050, function()
                u:playsound(bac368)
              end)
              local x2, y2 = x, y
              x, y = u:getxy()
              angle = u:getface()
              for i = 1, 5 do
                local tx = Effectcreate("AATX\\[AATxNew]Blue42.mdl", x, y, -1, 1, 75)
                local r = GetRandomReal(0, 200)
                local a2 = GetRandomReal(0, 360)
                local x4, y4 = PolarXY(x2, y2, r, a2)
                local da = AngleXY(x, y, x4, y4)
                local dl = DistanceXY(x, y, x4, y4)
                effectjump({
                  effect = tx,
                  time = 0.5,
                  distance = dl,
                  height = 500,
                  angle = da
                })
                ac.wait(1050, function()
                  DestroyEffectLua(tx)
                  Effectcreate("ATX\\[ATxNew]ShockBoom_12.mdl", x4, y4, 0, 1)
                  for _, xq in ac.selector():in_rangexy(x4, y4, 150):is_enemy(u.handle):ipairs() do
                    xq = getunit(xq)
                    DamageUnit({
                      bj = "C呆(机体)",
                      unit = xq.handle,
                      source = u.handle,
                      damage = txsh1,
                      level = 1,
                      type = "魔力",
                      isvest = false,
                      isattack = false,
                      isnoarmor = false,
                      element = "无",
                      extradata = {"法术", "魔导"}
                    })
                    if u:hasdata("卡斯特-调停者的指引") and not xq:hasdata("调停者的指引冷却") then
                      xq:settimedata("调停者的指引冷却", 0.1)
                      xq:changetimedata("调停者的指引-额外受伤", 0.02, 30)
                    end
                  end
                end)
              end
            end)
            ac.wait(600, function()
              u:animespeed(1)
              x, y = u:getxy()
              angle = u:getface()
              Effectcreate("AATX\\[0TxNew]Caber (5).mdl", x, y, 0, 1.5)
              local x2, y2 = x, y
              local r = 225
              ac.timer(250, 5, function()
                x2, y2 = PolarXY(x2, y2, r, angle)
                u:playsound(bac48)
                Effectcreate("AATX\\[0TxNew]Caber (2).mdl", x2, y2, 0, 1)
                for _, xq in ac.selector():in_rangexy(x2, y2, 275):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  DamageUnit({
                    bj = "C呆(机体)",
                    unit = xq.handle,
                    source = u.handle,
                    damage = txsh2,
                    level = 1,
                    type = "魔力",
                    isvest = false,
                    isattack = false,
                    isnoarmor = false,
                    element = "无",
                    extradata = {"法术", "魔导"}
                  })
                  if u:hasdata("卡斯特-调停者的指引") and not xq:hasdata("调停者的指引冷却") then
                    xq:settimedata("调停者的指引冷却", 0.1)
                    xq:changetimedata("调停者的指引-额外受伤", 0.02, 30)
                  end
                end
              end)
            end)
          end)
          ac.wait(1, function()
            IssueImmediateOrder(u.handle, "stop")
            Effectcreate("ATX\\[ATxNew]Dust_20.mdx", x, y, 0.8, 1, 0, angle + 180)
            Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
            ac.wait(200, function()
              x, y = u:getxy()
              Effectcreate("war3mapImported\\bbb.mdx", x, y)
            end)
          end)
          return
        else
          u:sendmessage("|cFFFF3300体力值不足|r")
        end
        return
      end
      if not u:hasdata("C呆-位移语音冷却") then
        local yx = {}
        yx[1] = Hero_Caber_20
        yx[2] = Hero_Caber_21
        yx[3] = Hero_Caber_22
        u:playsound(yx[GetRandomInt(1, 3)])
        u:settimedata("C呆-位移语音冷却", 4)
      end
      local txsh = 2000 + u:getint() * 25 * (1 + 0.015 * u:getlevel())
      unitmove({
        unit = u.handle,
        time = 0.3,
        distance = 350,
        angle = angle + 180,
        endfunc = function()
          x, y = u:getxy()
          u:setdata("位移点X", x)
          u:setdata("位移点Y", y)
        end
      })
      if u:getdata("绝对闪避时间") == 0 then
        u:setdata("刷新Q时间", 0.2)
      end
      movexg(u.handle, 0.25, self.skill, "Q", "C呆-仗-Q")
      ac.wait(1, function()
        IssueImmediateOrder(u.handle, "stop")
        Effectcreate("ATX\\[ATxNew]Dust_20.mdx", x, y, 0.8, 1, 0, angle + 180)
        Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
        ac.wait(200, function()
          x, y = u:getxy()
          Effectcreate("war3mapImported\\bbb.mdx", x, y)
        end)
      end)
      ac.wait(1, function()
        u:animeact(12)
        u:animespeed(4)
        u:playsound(bac1)
        ac.wait(200, function()
          u:playsound(bac203)
          x, y = u:getxy()
          angle = u:getface()
          local txmj = u:createunit("u0A7", x, y, angle)
          ac.wait(1, function()
            txmj:animeact("birth")
            ac.wait(170, function()
              txmj:animeact("stand")
              txmj:animespeed(1)
              local x4, y4 = PolarXY(x, y, 300, angle)
              for _, xq in ac.selector():in_rangexy(x4, y4, 175):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                DamageUnit({
                  bj = "C呆(机体)",
                  unit = xq.handle,
                  source = u.handle,
                  damage = txsh,
                  level = 1,
                  type = "魔力",
                  isvest = false,
                  isattack = false,
                  isnoarmor = false,
                  element = "无",
                  extradata = {"法术", "魔导"}
                })
                xq:effectadd("war3mapImported\\bbb.mdx")
                xq:buffset(u.handle, 0.25, "僵直")
                if u:hasdata("卡斯特-调停者的指引") and not xq:hasdata("调停者的指引冷却") then
                  xq:settimedata("调停者的指引冷却", 0.1)
                  xq:changetimedata("调停者的指引-额外受伤", 0.02, 30)
                end
              end
              ac.wait(230, function()
                txmj:animeact("death")
                txmj:timetoremove(0.35)
              end)
            end)
          end)
        end)
        ac.wait(600, function()
          u:animespeed(1)
        end)
      end)
    end
  },
  {
    name = "C呆-仗-W",
    skill = "A0ED",
    func = function(self, args)
      local u = getunit(args.unit)
      local sy = u.ownerid
      local x, y = u:getxy()
      local angle = u:getface()
      local b = false
      if u:hasbuff("缠绕") then
        u:setskillcd(self.skill, 0.01)
        u:sendmessage("|cFFFF3300缠绕中|r")
        return
      end
      local tl = 1
      if u:lossstamina(tl) then
      else
        u:setskillcd(self.skill, 0.01)
        u:sendmessage("|cFFFF3300体力值不足|r")
        return
      end
      if u:hasdata("Caber-仗加持") then
        u:deldata("Caber-仗加持")
        tl = 1
        if u:hasdata("卡斯特-调停者的指引") then
          tl = 0
        end
        if u:lossstamina(tl) then
          local txsh = 3333 + u:getint() * 33 * (1 + 0.015 * u:getlevel())
          if not u:hasdata("C呆-位移语音冷却") then
            local yx = {}
            yx[1] = Hero_Caber_20
            yx[2] = Hero_Caber_21
            yx[3] = Hero_Caber_22
            yx[4] = Hero_Caber_23
            yx[5] = Hero_Caber_24
            yx[6] = Hero_Caber_25
            yx[7] = Hero_Caber_26
            u:playsound(yx[GetRandomInt(1, 7)])
            u:settimedata("C呆-位移语音冷却", 4)
          end
          local zt = 0.35
          if u:hasdata("卡斯特-调停者的指引") then
            zt = zt * 0.7
          end
          u:buffset(u.handle, zt, "暂停")
          unitmove({
            unit = u.handle,
            time = 0.3,
            distance = 450,
            angle = angle,
            endfunc = function()
              x, y = u:getxy()
              u:setdata("位移点X", x)
              u:setdata("位移点Y", y)
            end
          })
          if u:getdata("绝对闪避时间") == 0 then
            u:setdata("刷新W时间", 0.2)
          end
          movexg(u.handle, 0.3, self.skill, "W", "C呆-仗-W")
          ac.wait(1, function()
            u:animeact(14)
            u:animespeed(4)
            Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
            Effectcreate("ATX\\[ATxNew]Dust_04.mdl", x, y, 0, 0.5, 0, angle)
            Effectcreate("AATX\\[0TxNew]Caber (4).mdl", x, y)
            u:playsound(bac2)
            ac.wait(5, function()
              x, y = u:getxy()
              Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
            end)
            ac.timer(30, 10, function()
              u:effectadd("Abilities\\Spells\\Other\\Charm\\CharmTarget.mdl", "weapon")
            end)
            ac.wait(350, function()
              x, y = u:getxy()
              angle = u:getface()
              local x2, y2 = PolarXY(x, y, 175, angle)
              Effectcreate("AATX\\AATxNew]Dust02.mdl", x2, y2, 0, 0.5, 0)
              Effectcreate("AATX\\[AATxNew]Dust19.mdl", x2, y2, 0, 1.5, 0)
              Effectcreate("AATX\\[AATxNew]Fire19_C.mdl", x2, y2, 2, 1.25, 0)
              u:playsound(bac301)
              local cs = 0
              local g = CreateGroupLua()
              ac.loop(250, function(timer)
                cs = cs + 1
                for _, xq in ac.selector():in_rangexy(x2, y2, 300):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  if not xq:isingroup(g) then
                    xq:groupadd(g)
                    xq:buffset(u.handle, 0.5, "眩晕")
                  end
                  DamageUnit({
                    bj = "C呆(机体)",
                    unit = xq.handle,
                    source = u.handle,
                    damage = txsh,
                    level = 1,
                    type = "魔力",
                    isvest = false,
                    isattack = false,
                    isnoarmor = false,
                    element = "无",
                    extradata = {"法术", "魔导"}
                  })
                  if u:hasdata("卡斯特-调停者的指引") and not xq:hasdata("调停者的指引冷却") then
                    xq:settimedata("调停者的指引冷却", 0.1)
                    xq:changetimedata("调停者的指引-额外受伤", 0.02, 30)
                  end
                end
                if cs == 8 then
                  timer:remove()
                end
              end)
            end)
          end)
          return
        else
          u:sendmessage("|cFFFF3300体力值不足|r")
        end
        return
      end
      if not u:hasdata("C呆-位移语音冷却") then
        local yx = {}
        yx[1] = Hero_Caber_20
        yx[2] = Hero_Caber_21
        yx[3] = Hero_Caber_22
        u:playsound(yx[GetRandomInt(1, 3)])
        u:settimedata("C呆-位移语音冷却", 4)
      end
      local txsh = 4000 + u:getstr() * 100 * (1 + 0.015 * u:getlevel())
      unitmove({
        unit = u.handle,
        time = 0.3,
        distance = 450,
        angle = angle,
        endfunc = function()
          x, y = u:getxy()
          u:setdata("位移点X", x)
          u:setdata("位移点Y", y)
        end
      })
      if u:getdata("绝对闪避时间") == 0 then
        u:setdata("刷新W时间", 0.2)
      end
      movexg(u.handle, 0.25, self.skill, "W", "C呆-仗-W")
      ac.wait(1, function()
        u:animeact(14)
        u:animespeed(4)
        Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
        Effectcreate("ATX\\[ATxNew]Dust_04.mdl", x, y, 0, 0.5, 0, angle)
        u:playsound(bac2)
      end)
      ac.wait(5, function()
        x, y = u:getxy()
        Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
      end)
      ac.wait(350, function()
        x, y = u:getxy()
        angle = u:getface()
        local x2, y2 = PolarXY(x, y, 175, angle)
        Effectcreate("AATX\\AATxNew]Dust02.mdl", x2, y2, 0, 0.5, 0)
        Effectcreate("AATX\\[AATxNew]Dust19.mdl", x2, y2, 0, 1.5, 0)
        Effectcreate("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", x2, y2, 0, 1.5)
        for _, xq in ac.selector():in_rangexy(x2, y2, 275):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          DamageUnit({
            bj = "C呆(机体)",
            unit = xq.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "物理",
            isvest = false,
            isattack = false,
            isnoarmor = false,
            element = "无",
            extradata = {"法术", "魔导"}
          })
          xq:buffset(u.handle, 0.5, "眩晕")
          if u:hasdata("卡斯特-调停者的指引") and not xq:hasdata("调停者的指引冷却") then
            xq:settimedata("调停者的指引冷却", 0.1)
            xq:changetimedata("调停者的指引-额外受伤", 0.02, 30)
          end
        end
      end)
    end
  },
  {
    name = "C呆-剑-S",
    skill = "A0HI",
    func = function(self, args)
      local u = getunit(args.unit)
      local sy = u.ownerid
      local x, y = u:getxy()
      if u:hasdata("Caber-剑加持") then
        u:deldata("Caber-剑加持")
        if u:hasdata("卡文南加强") then
          u:deldata("卡文南加强")
          u:changedata("闪避值", -25)
          ChangeValue(HeroMenu_Sbxs, sy, -0.1)
        end
        local skill
        if u:hasdata("系统-飞行状态") then
          skill = "A0S2"
        else
          skill = "A0M6"
        end
        u:addskill(skill)
        u:delskill(skill)
        Effectcreate("ATX\\[ATxNew]White_15.mdl", x, y, 0, 2)
        u:playsound(bac28)
        u:setdata("Caber-杖形态")
        u:deldata("Caber-剑形态")
        ModelReSet({
          u = u,
          modelicon = "Hero_Caber_T1_TX.tga"
        })
        u:banskill("A0JU", true)
        u:banskill("A0FX", true)
        u:banskill("A0FY", true)
        u:banskill("A0GT", true)
        u:banskill("A0GR", true)
        u:banskill("A0JQ", false)
        u:banskill("A0CY", false)
        u:banskill("A0ED", false)
        u:banskill("A0FS", false)
        u:setdata("位移技能-Q", S2ID("A0FS"))
        u:setdata("位移技能-W", S2ID("A0ED"))
        u:banweaponskill(true)
        u:delskill("A00B")
        u:addskill("A00B")
        if not u:hasdata("C呆-切换语音冷却") then
          local yx = {}
          yx[1] = Hero_Caster_12
          u:playsound(yx[GetRandomInt(1, 1)])
          u:settimedata("C呆-切换语音冷却", 60)
        end
      else
        u:effectadd("AATX\\[AATxNew]Yellow11.mdl", "weapon")
        u:settimedata("Caber-剑加持", 1)
      end
    end
  },
  {
    name = "C呆-剑-Q",
    skill = "A0FY",
    func = function(self, args)
      local u = getunit(args.unit)
      local sy = u.ownerid
      local x, y = u:getxy()
      local angle = u:getface()
      local b = false
      if u:hasbuff("缠绕") then
        u:setskillcd(self.skill, 0.01)
        u:sendmessage("|cFFFF3300缠绕中|r")
        return
      end
      local tl = 1
      if u:lossstamina(tl) then
      else
        u:setskillcd(self.skill, 0.01)
        u:sendmessage("|cFFFF3300体力值不足|r")
        return
      end
      if u:hasdata("卡斯特-踏影的卡文南") then
        u:setskillcd(self.skill, 0.9)
      end
      if not u:hasdata("C呆-位移语音冷却") then
        local yx = {}
        yx[1] = Hero_Caber_20
        yx[2] = Hero_Caber_21
        yx[3] = Hero_Caber_22
        u:playsound(yx[GetRandomInt(1, 3)])
        u:settimedata("C呆-位移语音冷却", 4)
      end
      if u:hasdata("Caber-剑加持") then
        u:deldata("Caber-剑加持")
        if 1 <= u:getpermp() then
          u:curemp(0, -1)
          local txsh = 3000 + u:getallattri() * 30 * (1 + 0.015 * u:getlevel())
          local zt = 0.15
          if u:hasdata("卡斯特-调停者的指引") then
            zt = zt * 0.7
          end
          u:buffset(u.handle, zt, "暂停")
          ac.wait(1, function()
            u:animeact(20)
            u:animespeed(5)
            ac.wait(100, function()
              u:playsound(bac237)
              u:animespeed(1)
              x, y = u:getxy()
              local x2, y2 = PolarXY(x, y, -500, angle)
              Effectcreate("AATX\\AATxNew]Dust11.mdl", x, y)
              Effectcreate("ATX\\[ATxNew]Cthulhu_07.mdl", x, y)
              Effectcreate("ATX\\[ATxNew]Cthulhu_07.mdl", x2, y2)
              Effectcreate("war3mapImported\\bbb.mdx", x2, y2)
              unitmove({
                unit = u.handle,
                time = 0.3,
                distance = 500,
                angle = angle + 180,
                isblink = true,
                endfunc = function()
                  x, y = u:getxy()
                  u:setdata("位移点X", x)
                  u:setdata("位移点Y", y)
                end
              })
            end)
            ac.wait(200, function()
              ac.timer(150, 4, function()
                local r = GetRandomReal(0, 100)
                local a2 = GetRandomAngle()
                local x3, y3 = PolarXY(x, y, r, a2)
                local txmj = u:createunit("u023", x3, y3, GetRandomAngle())
                txmj:timetoremove(0.7)
                ac.wait(1, function()
                  txmj:animeact(0)
                  txmj:animespeed(0.5)
                end)
                u:playsound(bac221)
                Effectcreate("ATX\\[ATxNew]Cthulhu_11.mdl", x3, y3)
                Effectcreate("war3mapImported\\bbb.mdx", x3, y3, 0, 1.5)
                for _, xq in ac.selector():in_rangexy(x3, y3, 210):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  DamageUnit({
                    bj = "C呆(机体)",
                    unit = xq.handle,
                    source = u.handle,
                    damage = txsh,
                    level = 1,
                    type = "物理",
                    isvest = false,
                    isattack = true,
                    isnoarmor = false,
                    element = "无",
                    extradata = {
                      "近战",
                      "法术",
                      "魔导"
                    }
                  })
                  xq:buffset(u.handle, 1, "眩晕")
                  if u:hasdata("卡斯特-调停者的指引") and not xq:hasdata("调停者的指引冷却") then
                    xq:settimedata("调停者的指引冷却", 0.1)
                    xq:changetimedata("调停者的指引-额外受伤", 0.02, 30)
                  end
                end
              end)
            end)
          end)
          if u:getdata("绝对闪避时间") == 0 then
            u:setdata("刷新Q时间", 0.2)
          end
          movexg(u.handle, 0.3, self.skill, "Q", "C呆-剑-Q")
          return
        else
          u:sendmessage("|cFFFFCC33魔力值不足|r")
        end
      end
      play_shadow_slow_series(u, {
        model = "HERO\\Shio_Altria_C2.mdl",
        act = 24,
        x = x,
        y = y,
        count = 1,
        interval = 0.03,
        main_speed = 1,
        wait_time = 0,
        r = 255,
        g = 255,
        b = 255,
        fade_sub = 5
      })
      ac.wait(100, function()
        u:playsound(bac496)
        u:animespeed(1)
        x, y = u:getxy()
        local x2, y2 = PolarXY(x, y, -400, angle)
        Effectcreate("AATX\\AATxNew]Dust11.mdl", x, y)
        Effectcreate("AATX\\[AATxNew]Yellow08.mdl", x, y, 0, 1, 100)
        Effectcreate("AATX\\[AATxNew]Yellow08.mdl", x2, y2, 0, 1, 100)
        Effectcreate("war3mapImported\\bbb.mdx", x2, y2)
        unitmove({
          unit = u.handle,
          time = 0.3,
          distance = 400,
          angle = angle + 180,
          isblink = true,
          endfunc = function()
            x, y = u:getxy()
            u:setdata("位移点X", x)
            u:setdata("位移点Y", y)
          end
        })
        if u:hasdata("卡斯特-闪电的斯普梅达") then
          local txsh = 3000 + 15 * u:getallattri() * (1 + 0.015 * u:getlevel())
          local vest = getunit(System_SkillVest)
          vest:addskill("A1FT")
          for _, xq in ac.selector():in_rangexy(x2, y2, 700):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            local dis = DistanceBetweenUnits(u.handle, xq.handle)
            IssueTargetOrder(vest.handle, "curse", xq.handle)
            if dis <= 350 then
              DamageUnit({
                bj = "C呆(机体)",
                unit = xq.handle,
                source = u.handle,
                damage = txsh,
                level = 1,
                type = "魔力",
                isvest = false,
                isattack = false,
                isnoarmor = false,
                element = "光",
                extradata = {"法术", "魔导"}
              })
              if u:hasdata("卡斯特-调停者的指引") and not xq:hasdata("调停者的指引冷却") then
                xq:settimedata("调停者的指引冷却", 0.1)
                xq:changetimedata("调停者的指引-额外受伤", 0.02, 30)
              end
            end
          end
          vest:delskill("A1FT")
        end
      end)
      if u:getdata("绝对闪避时间") == 0 then
        u:setdata("刷新Q时间", 0.2)
      end
      movexg(u.handle, 0.25, self.skill, "Q", "C呆-剑-Q")
      u:effectadd("Abilities\\Weapons\\FaerieDragonMissile\\FaerieDragonMissile.mdl", "hand left", 0.25)
      u:effectadd("Abilities\\Weapons\\FaerieDragonMissile\\FaerieDragonMissile.mdl", "hand right", 0.25)
    end
  },
  {
    name = "C呆-剑-W",
    skill = "A0FX",
    func = function(self, args)
      local u = getunit(args.unit)
      local sy = u.ownerid
      local x, y = u:getxy()
      local angle = u:getface()
      local b = false
      if u:hasbuff("缠绕") then
        u:setskillcd(self.skill, 0.01)
        u:sendmessage("|cFFFF3300缠绕中|r")
        return
      end
      local tl = 1
      if u:lossstamina(tl) then
      else
        u:setskillcd(self.skill, 0.01)
        u:sendmessage("|cFFFF3300体力值不足|r")
        return
      end
      if u:hasdata("卡斯特-踏影的卡文南") then
        u:setskillcd(self.skill, 0.9)
      end
      if not u:hasdata("C呆-位移语音冷却") then
        local yx = {}
        yx[1] = Hero_Caber_20
        yx[2] = Hero_Caber_21
        yx[3] = Hero_Caber_22
        u:playsound(yx[GetRandomInt(1, 3)])
        u:settimedata("C呆-位移语音冷却", 4)
      end
      if u:hasdata("Caber-剑加持") then
        u:deldata("Caber-剑加持")
        if 1 <= u:getpermp() then
          u:curemp(0, -1)
          local txsh = 10000 + u:getallattri() * 30 * (1 + 0.015 * u:getlevel())
          local zt = 0.2
          if u:hasdata("卡斯特-调停者的指引") then
            zt = zt * 0.7
          end
          u:buffset(u.handle, zt, "暂停")
          u:playsound(bac1)
          Effectcreate("ATX\\[ATxNew]Dust_04.mdl", x, y, 0, 0.4, 90, angle)
          Effectcreate("ATX\\[ATxNew]Dust_20.mdl", x, y, 0, 1, 0, angle)
          unitmove({
            unit = u.handle,
            time = 0.15,
            distance = 450,
            angle = angle,
            endfunc = function()
              x, y = u:getxy()
              u:setdata("位移点X", x)
              u:setdata("位移点Y", y)
            end
          })
          ac.wait(1, function()
            u:animeact(21)
            u:animespeed(4)
          end)
          ac.wait(100, function()
            u:effectadd("AATX\\[AATxNew]Colour06.mdl", "weapon")
            u:effectadd("AATX\\[AATxNew]Yellow01.mdl", "weapon")
            u:effectadd("war3mapImported\\xiaoguangdao3_S.mdx", "weapon", 0.4)
          end)
          ac.wait(150, function()
            u:animeact(23)
            local yx = {}
            yx[1] = bac416
            yx[2] = bac417
            u:playsound(yx[GetRandomInt(1, 2)])
            x, y = u:getxy()
            angle = u:getface()
            Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
            EffectcreateArgs({
              effect = "ATX\\[ATxNew]Daoguang_26_C2.mdl",
              x = x,
              y = y,
              time = 0,
              size = 2.5,
              height = 100,
              zxz = angle + 180,
              yxz = 180,
              animespeed = 2
            })
            local x3, y3 = PolarXY(x, y, 150, angle)
            Effectcreate("5Tx\\[555]1765.mdl", x3, y3, 0, 1, 0, angle)
            ac.wait(80, function()
              x, y = u:getxy()
              angle = u:getface()
              local g = CreateGroupLua()
              local r = 300
              local a2 = angle - 90
              for i = 1, 3 do
                a2 = a2 + 45
                x3, y3 = PolarXY(x, y, r, a2)
                for _, xq in ac.selector():in_rangexy(x3, y3, r):is_enemy(u.handle):isnotingroup(g):ipairs() do
                  xq = getunit(xq)
                  xq:groupadd(g)
                  xq:effectadd("Abilities\\Spells\\Items\\StaffOfPurification\\PurificationTarget.mdl", "chest", 0.5)
                  DamageUnit({
                    bj = "C呆(机体)",
                    unit = xq.handle,
                    source = u.handle,
                    damage = txsh,
                    level = 1,
                    type = "物理",
                    isvest = false,
                    isattack = true,
                    isnoarmor = false,
                    element = "无",
                    extradata = {
                      "近战",
                      "法术",
                      "魔导"
                    }
                  })
                  xq:buffset(u.handle, 1.2, "僵直")
                  if u:hasdata("卡斯特-调停者的指引") and not xq:hasdata("调停者的指引冷却") then
                    xq:settimedata("调停者的指引冷却", 0.1)
                    xq:changetimedata("调停者的指引-额外受伤", 0.02, 30)
                  end
                end
              end
            end)
          end)
          ac.wait(250, function()
            u:animespeed(1)
          end)
          if u:getdata("绝对闪避时间") == 0 then
            u:setdata("刷新W时间", 0.2)
          end
          movexg(u.handle, 0.3, self.skill, "W", "C呆-剑-W")
          return
        else
          u:sendmessage("|cFFFFCC33魔力值不足|r")
        end
      end
      play_shadow_slow_series(u, {
        model = "HERO\\Shio_Altria_C2.mdl",
        act = 24,
        x = x,
        y = y,
        count = 1,
        interval = 0.03,
        main_speed = 1,
        wait_time = 0,
        r = 255,
        g = 255,
        b = 255,
        fade_sub = 5
      })
      ac.wait(100, function()
        u:playsound(bac496)
        u:animespeed(1)
        x, y = u:getxy()
        local x2, y2 = PolarXY(x, y, 400, angle)
        Effectcreate("AATX\\AATxNew]Dust11.mdl", x, y)
        Effectcreate("AATX\\[AATxNew]Yellow08.mdl", x, y, 0, 1, 100)
        Effectcreate("AATX\\[AATxNew]Yellow08.mdl", x2, y2, 0, 1, 100)
        Effectcreate("war3mapImported\\bbb.mdx", x2, y2)
        unitmove({
          unit = u.handle,
          time = 0.3,
          distance = 400,
          angle = angle,
          isblink = true,
          endfunc = function()
            x, y = u:getxy()
            u:setdata("位移点X", x)
            u:setdata("位移点Y", y)
          end
        })
        if u:hasdata("卡斯特-闪电的斯普梅达") then
          local txsh = 3000 + 15 * u:getallattri() * (1 + 0.015 * u:getlevel())
          local vest = getunit(System_SkillVest)
          vest:addskill("A1FT")
          for _, xq in ac.selector():in_rangexy(x2, y2, 700):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            local dis = DistanceBetweenUnits(u.handle, xq.handle)
            IssueTargetOrder(vest.handle, "curse", xq.handle)
            if dis <= 350 then
              DamageUnit({
                bj = "C呆(机体)",
                unit = xq.handle,
                source = u.handle,
                damage = txsh,
                level = 1,
                type = "魔力",
                isvest = false,
                isattack = false,
                isnoarmor = false,
                element = "光",
                extradata = {"法术", "魔导"}
              })
              if u:hasdata("卡斯特-调停者的指引") and not xq:hasdata("调停者的指引冷却") then
                xq:settimedata("调停者的指引冷却", 0.1)
                xq:changetimedata("调停者的指引-额外受伤", 0.02, 30)
              end
            end
          end
          vest:delskill("A1FT")
        end
      end)
      if u:getdata("绝对闪避时间") == 0 then
        u:setdata("刷新W时间", 0.2)
      end
      movexg(u.handle, 0.25, self.skill, "W", "C呆-剑-W")
      u:effectadd("Abilities\\Weapons\\FaerieDragonMissile\\FaerieDragonMissile.mdl", "hand left", 0.25)
      u:effectadd("Abilities\\Weapons\\FaerieDragonMissile\\FaerieDragonMissile.mdl", "hand right", 0.25)
    end
  },
  {
    name = "C呆-剑-A",
    skill = "A0G0",
    func = function(self, args)
      local u = getunit(args.unit)
      local sy = u.ownerid
      local x, y = u:getxy()
      local angle = u:getface()
      if u:getpermp() >= 0.5 then
        u:curemp(0, -0.5)
      else
        u:sendmessage("|cFFFFCC33魔力值不足|r")
        return
      end
      u:mousexyflash()
      if not u:hasdata("C呆-普攻语音冷却") then
        local yx = {}
        yx[1] = Hero_Caster_01
        yx[2] = Hero_Caster_02
        yx[3] = Hero_Caster_03
        yx[4] = Hero_Caster_04
        yx[5] = Hero_Caster_05
        yx[6] = Hero_Caster_06
        yx[7] = Hero_Caster_07
        u:playsound(yx[GetRandomInt(1, 7)])
        u:settimedata("C呆-普攻语音冷却", 4)
      end
      if u:hasdata("Caber-剑加持") then
        u:deldata("Caber-剑加持")
        if u:getpermp() >= 1.5 then
          u:curemp(0, -1.5)
          local txsh = 5000 + u:getlevel() * 600 * (1 + 0.015 * u:getlevel())
          local zt = 0.35
          if u:hasdata("卡斯特-调停者的指引") then
            zt = zt * 0.7
          end
          u:buffset(u.handle, zt, "暂停")
          ac.wait(1, function()
            u:animeact(19)
            u:animespeed(2)
          end)
          ac.wait(150, function()
            u:playsound(bac250)
            Effectcreate("ATX\\[ATxNew]White_25.mdl", x, y, 0, 2, 250)
          end)
          ac.wait(300, function()
            local x2, y2 = u:getmousexy()
            if IsXYinAnyPlayRect(x2, y2) then
            else
              u:sendmessage("|cFFFFCC33超出地图区域|r")
              return
            end
            local dis = DistanceXY(x, y, x2, y2)
            local btx = false
            if 4000 <= dis then
              btx = true
            end
            ac.wait(50, function()
              ac.timer(150, 4, function()
                local r = GetRandomReal(0, 100)
                local a2 = GetRandomAngle()
                local x3, y3 = PolarXY(x2, y2, r, a2)
                local txmj = u:createunit("u023", x3, y3, GetRandomAngle())
                txmj:timetoremove(0.7)
                ac.wait(1, function()
                  txmj:animeact(GetRandomInt(0, 3))
                end)
                ac.wait(200, function()
                  PlaySoundXY(x2, y2, bac221)
                  Effectcreate("ATX\\[ATxNew]Cthulhu_11.mdl", x3, y3)
                  Effectcreate("war3mapImported\\bbb.mdx", x3, y3, 0, 1.5)
                  for _, xq in ac.selector():in_rangexy(x3, y3, 250):is_enemy(u.handle):ipairs() do
                    xq = getunit(xq)
                    DamageUnit({
                      bj = "C呆(机体)",
                      unit = xq.handle,
                      source = u.handle,
                      damage = txsh,
                      level = 1,
                      type = "物理",
                      isvest = btx,
                      isattack = true,
                      isnoarmor = false,
                      element = "无",
                      extradata = {
                        "近战",
                        "法术",
                        "魔导"
                      }
                    })
                    if xq:isnormal() then
                      xq:buffset(u.handle, 1, "眩晕")
                    else
                      xq:buffset(u.handle, 0.2, "眩晕")
                    end
                    xq:effectadd("AATX\\[AATxNew]Blood22.mdl", "chest")
                    if u:hasdata("卡斯特-调停者的指引") and not xq:hasdata("调停者的指引冷却") then
                      xq:settimedata("调停者的指引冷却", 0.1)
                      xq:changetimedata("调停者的指引-额外受伤", 0.02, 30)
                    end
                  end
                end)
              end)
            end)
          end)
          ac.wait(450, function()
            u:animespeed(1)
          end)
          return
        else
          u:sendmessage("|cFFFFCC33魔力值不足|r")
        end
      end
      local txsh = 10000 + u:getallattri() * 35 * (1 + 0.015 * u:getlevel())
      u:effectadd("AATX\\[AATxNew]Yellow01.mdl", "weapon")
      u:effectadd("war3mapImported\\xiaoguangdao3_S.mdx", "weapon", 0.4)
      ac.wait(200, function()
        u:effectadd("AATX\\[AATxNew]Colour06.mdl", "weapon")
      end)
      ac.wait(1, function()
        if GetRandom100(50) then
          u:animeact(2)
          ac.wait(100, function()
            EffectcreateArgs({
              effect = "ATX\\[ATxNew]Daoguang_26_C2.mdl",
              x = x,
              y = y,
              size = 2,
              height = 100,
              zxz = angle,
              yxz = 345,
              animespeed = 2
            })
          end)
        else
          u:animeact(3)
          ac.wait(100, function()
            EffectcreateArgs({
              effect = "ATX\\[ATxNew]Daoguang_26_C2.mdl",
              x = x,
              y = y,
              size = 2,
              height = 100,
              zxz = angle,
              yxz = 15,
              animespeed = 2
            })
          end)
        end
        u:animespeed(2)
      end)
      ac.wait(100, function()
        local yx = {}
        yx[1] = bac416
        yx[2] = bac417
        u:playsound(yx[GetRandomInt(1, 2)])
        Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
        ac.wait(80, function()
          x, y = u:getxy()
          angle = u:getface()
          local r = 200
          local a2 = angle - 90
          local g = CreateGroupLua()
          for i = 1, 3 do
            a2 = a2 + 45
            local x3, y3 = PolarXY(x, y, r, a2)
            for _, xq in ac.selector():in_rangexy(x3, y3, r):is_enemy(u.handle):isnotingroup(g):ipairs() do
              xq = getunit(xq)
              xq:groupadd(g)
              xq:effectadd("Abilities\\Spells\\Items\\StaffOfPurification\\PurificationTarget.mdl", "chest", 0.5)
              DamageUnit({
                bj = "C呆(机体)",
                unit = xq.handle,
                source = u.handle,
                damage = txsh,
                level = 1,
                type = "物理",
                isvest = false,
                isattack = true,
                isnoarmor = false,
                element = "光",
                extradata = {
                  "近战",
                  "法术",
                  "魔导"
                }
              })
              xq:buffset(u.handle, 1.2, "僵直")
              if u:hasdata("卡斯特-调停者的指引") and not xq:hasdata("调停者的指引冷却") then
                xq:settimedata("调停者的指引冷却", 0.1)
                xq:changetimedata("调停者的指引-额外受伤", 0.02, 30)
              end
            end
          end
        end)
      end)
    end
  },
  {
    name = "C呆-剑-E",
    skill = "A0GT",
    func = function(self, args)
      local u = getunit(args.unit)
      local sy = u.ownerid
      local x, y = u:getxy()
      local x2 = args.x
      local y2 = args.y
      local dis = DistanceXY(x, y, x2, y2)
      local angle = AngleXY(x, y, x2, y2)
      u:setface(angle)
      if u:getpermp() >= 1.4 then
        u:curemp(0, -1.4)
      else
        u:sendmessage("|cFFFFCC33魔力值不足|r")
        return
      end
      u:mousexyflash()
      if not u:hasdata("C呆-普攻语音冷却") then
        local yx = {}
        yx[1] = Hero_Caster_04
        yx[2] = Hero_Caster_05
        yx[3] = Hero_Caster_06
        yx[4] = Hero_Caster_07
        u:playsound(yx[GetRandomInt(1, 4)])
        u:settimedata("C呆-普攻语音冷却", 4)
      end
      if u:hasdata("Caber-剑加持") then
        u:deldata("Caber-剑加持")
        if u:getpermp() >= 4.2 then
          u:curemp(0, -4.2)
          local txsh = 15000 + u:getlevel() * 3000 + u:getallattri() * 180 * (1 + 0.015 * u:getlevel())
          local zt = 0.6
          if u:hasdata("卡斯特-调停者的指引") then
            zt = zt * 0.7
          end
          u:buffset(u.handle, zt, "暂停")
          ac.timer(50, 7, function()
            local r = GetRandomReal(0, 200)
            local a = GetRandomAngle()
            local x3, y3 = PolarXY(x, y, r, a)
            Effectcreate("AATX\\[AATxNew]Yellow04.mdl", x3, y3, 0, 3)
            Effectcreate("war3mapImported\\specialanimedustwave.mdx", x2, y2, 0, 2, 0, GetRandomAngle())
          end)
          ac.wait(1, function()
            u:animeact(17)
            u:animespeed(2)
            u:effectadd("AATX\\[AATxNew]Yellow01.mdl", "weapon")
            u:effectadd("AATX\\[AATxNew]Colour06.mdl", "weapon")
            u:playsound(bac296)
            u:effectadd("war3mapImported\\xiaoguangdao3.mdx", "weapon", 1.4)
          end)
          ac.wait(400, function()
            u:animespeed(0.5)
            u:playsound(bac301)
            u:playsound(bac309)
          end)
          ac.wait(500, function()
            local r = 350
            local x3, y3 = PolarXY(x, y, r, angle)
            Effectcreate("ATX\\[ATxNew]ShockBoom_06.mdl", x3, y3, 0, 1.5)
            Effectcreate("AATX\\[AATxNew]ShockBoom23.mdl", x3, y3)
            Effectcreate("5Tx\\[555]1765.mdl", x3, y3, 0, 1, 0, angle)
            for _, xq in ac.selector():in_rangexy(x3, y3, 450):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              if xq:isnormal() then
                xq:losshp(u, 0, 10)
              else
                LossHpUnit({
                  u = u,
                  tg = xq,
                  perhp = 1,
                  bj = "C呆(机体损耗)"
                })
              end
              if u:hasdata("卡斯特-玛米亚德兹") then
                u:setdata("C呆-神话礼装伤害变更")
                u:setdata("C呆-审判固伤")
              end
              DamageUnit({
                bj = "C呆(机体)",
                unit = xq.handle,
                source = u.handle,
                damage = txsh,
                level = 1,
                type = "物理",
                isvest = false,
                isattack = true,
                isnoarmor = false,
                element = "光",
                extradata = {
                  "近战",
                  "法术",
                  "魔导"
                }
              })
              local kz = 2
              if u:hasdata("卡斯特-玛米亚德兹") then
                kz = 2.5
                u:deldata("C呆-神话礼装伤害变更")
                u:deldata("C呆-审判固伤")
              end
              xq:buffset(u.handle, kz, "眩晕")
              xq:settimedata("Caber-审判抑制", 10)
              xq:groupadd(HpGroup)
              xq:effectadd("ATX\\[ATxNew]Thunder_12.mdl")
              xq:effectadd("Abilities\\Spells\\NightElf\\FaerieFire\\FaerieFireTarget.mdl", "head", 10)
              xq:effectadd("Abilities\\Spells\\Items\\StaffOfPurification\\PurificationCaster.mdl", "origin", 0.5)
              if u:hasdata("卡斯特-调停者的指引") and not xq:hasdata("调停者的指引冷却") then
                xq:settimedata("调停者的指引冷却", 0.1)
                xq:changetimedata("调停者的指引-额外受伤", 0.02, 30)
              end
            end
          end)
          ac.wait(600, function()
            u:animespeed(1)
          end)
          return
        else
          u:sendmessage("|cFFFFCC33魔力值不足|r")
        end
      end
      if 2000 <= dis then
        dis = 2000
      end
      local zt = 0.25
      if u:hasdata("卡斯特-调停者的指引") then
        zt = zt * 0.7
      end
      u:buffset(u.handle, zt, "暂停")
      local txsh = 8000 + u:getlevel() * 1000 * (1 + 0.015 * u:getlevel())
      ac.wait(1, function()
        u:animeact(14)
        u:animespeed(2)
        u:playsound(bac392)
        EffectcreateArgs({
          effect = "AATX\\[AATxNew]Fire48.mdl",
          x = x,
          y = y,
          animespeed = 2
        })
      end)
      ac.wait(150, function()
        u:playsound(bac396)
        u:animeact(16)
        EffectcreateArgs({
          effect = "AATX\\[AATxNew]Dust07.mdl",
          x = x,
          y = y,
          size = 0.4,
          height = 70,
          zxz = angle
        })
        unifycreate({
          owner = u.handle,
          model = "",
          modelname = "卡斯特-圣剑",
          modelsize = 0.4,
          height = 100,
          damage = 0.5 * txsh,
          damagetype = 4,
          x = x,
          y = y,
          range = dis,
          speed = 3500,
          volume = 125,
          angle = angle,
          angleoffset = 0,
          attenua = 1,
          attenuacount = 999,
          life = 10,
          isbullet = false,
          isvest = false,
          isignorearmor = false,
          startfunc = function(mj)
            japi.SetUnitModel(mj.handle, "HERO\\Shio_Altria_C2_W1.mdl")
            local tx = mj:effectadd("war3mapImported\\xiaoguangdao4.mdx", "weapon", -1)
            mj:setdata("圣剑-特效", tx)
            mj:setdata("循环计数", 0)
          end,
          loopfunc = function(mj)
            mj:changedata("循环计数", UnifyDT)
            if mj:getdata("循环计数") >= 0.04 then
              mj:setdata("循环计数", 0)
              local dx, dy = mj:getxy()
              Effectcreate("AATX\\[AATxNew]Yellow11.mdl", dx, dy, 0, 1, 70, GetRandomAngle())
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
            japi.SetUnitModel(mj.handle, "Bullet.mdl")
            local dx, dy = mj:getxy()
            Effectcreate("AATX\\[AATxNew]Hit22.mdl", dx, dy, 0, 2, 70)
            Effectcreate("5Tx\\[555]Katana16_C.mdx", dx, dy, 0, 2.5, 90)
            Effectcreate("AATX\\[AATxNew]Fire16.mdl", dx, dy, 0, 2)
            Effectcreate("war3mapImported\\bbb.mdx", dx, dy, 0, 3)
            local tx = mj:getdata("圣剑-特效")
            ac.wait(1000, function()
              DestroyEffectLua(tx)
            end)
            mj:playsound(bac221)
            for _, xq in ac.selector():in_rangexy(dx, dy, 400):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              DamageUnit({
                bj = "C呆(机体)",
                unit = xq.handle,
                source = u.handle,
                damage = txsh,
                level = 1,
                type = "物理",
                isvest = false,
                isattack = true,
                isnoarmor = false,
                element = "光",
                extradata = {"法术", "魔导"}
              })
              xq:buffset(u.handle, 1, "眩晕")
              xq:effectadd("Abilities\\Spells\\Items\\StaffOfPurification\\PurificationCaster.mdl", "origin", 0.5)
              if u:hasdata("卡斯特-调停者的指引") and not xq:hasdata("调停者的指引冷却") then
                xq:settimedata("调停者的指引冷却", 0.1)
                xq:changetimedata("调停者的指引-额外受伤", 0.02, 30)
              end
            end
          end
        })
      end)
      ac.wait(200, function()
        u:animespeed(0.5)
      end)
      ac.wait(650, function()
        x, y = u:getxy()
        u:animespeed(1)
        EffectcreateArgs({
          effect = "AATX\\[AATxNew]Fire48.mdl",
          x = x,
          y = y,
          animespeed = 2
        })
      end)
    end
  },
  {
    name = "C呆-剑-R",
    skill = "A0GR",
    func = function(self, args)
      local u = getunit(args.unit)
      local sy = u.ownerid
      local x, y = u:getxy()
      local x2 = args.x
      local y2 = args.y
      local dis = DistanceXY(x, y, x2, y2)
      local angle = AngleXY(x, y, x2, y2)
      u:setface(angle)
      if u:getpermp() >= 1.8 then
        u:curemp(0, -1.8)
      else
        u:sendmessage("|cFFFFCC33魔力值不足|r")
        return
      end
      u:mousexyflash()
      if not u:hasdata("C呆-普攻语音冷却") then
        local yx = {}
        yx[1] = Hero_Caster_04
        yx[2] = Hero_Caster_05
        yx[3] = Hero_Caster_06
        yx[4] = Hero_Caster_07
        u:playsound(yx[GetRandomInt(1, 4)])
        u:settimedata("C呆-普攻语音冷却", 4)
      end
      if u:hasdata("Caber-剑加持") then
        u:deldata("Caber-剑加持")
        u:setface(angle)
        if u:getpermp() >= 5.4 then
          u:curemp(0, -5.4)
          local txsh1 = 10000 + u:getallattri() * 50 * (1 + 0.015 * u:getlevel())
          local txsh2 = 3000 + u:getallattri() * 15 * (1 + 0.015 * u:getlevel())
          u:effectadd("AATX\\[AATxNew]Yellow08.mdl", "overhead")
          u:playsound(bac75)
          local zt = 0.7
          if u:hasdata("卡斯特-调停者的指引") then
            zt = zt * 0.7
          end
          u:buffset(u.handle, zt, "暂停")
          ac.wait(1, function()
            u:animeact(11)
            u:animespeed(2)
            ac.wait(250, function()
              u:playsound(bac250)
              Effectcreate("war3mapImported\\bbb.mdx", x, y, 0, 2)
              local a2 = angle
              local r = 200
              for i = 1, 4 do
                a2 = a2 + 90
                local x3, y3 = PolarXY(x, y, r, a2)
                x3 = x3 - 16
                y3 = y3 - 16
                local txmj = u:createunit("u08Q", x3, y3, a2 + 180)
                txmj:timetoremove(0.45)
              end
              a2 = GetRandomAngle()
              for i = 1, 6 do
                a2 = a2 + GetRandomReal(50, 70)
                local x3, y3
                x3 = x - 16
                y3 = y - 16
                local txmj = u:createunit("u002", x3, y3, a2)
                txmj:timetoremove(0.451)
                local a3 = a2
                ac.timer(15, 30, function()
                  a3 = a3 + 10
                  txmj:setface(a3)
                end)
              end
              u:animeact(12)
              u:animespeed(1)
            end)
            ac.wait(400, function()
              u:playsound(bac285)
              ac.wait(1, function()
                local a2 = GetRandomAngle()
                local x3, y3 = PolarXY(x2, y2, 600, a2)
                local txmj = u:createunit("u08N", x3, y3, a2)
                a2 = a2 + 180
                local g = CreateGroupLua()
                unitmove({
                  unit = txmj.handle,
                  time = 1,
                  distance = 1200,
                  isfly = true,
                  angle = a2,
                  loops = {
                    {
                      looptime = 0.065,
                      func = function(dx, dy)
                        Effectcreate("AATX\\[AATxNew]ShockBoom19.mdl", dx, dy, 0, 3)
                        Effectcreate("AATX\\[AATxNew]Hit16.mdl", dx, dy, 0, 3)
                      end
                    },
                    {
                      looptime = 0.1,
                      func = function(dx, dy)
                        for _, xq in ac.selector():in_rangexy(dx, dy, 200):is_enemy(u.handle):ipairs() do
                          xq = getunit(xq)
                          DamageUnit({
                            bj = "C呆(机体)",
                            unit = xq.handle,
                            source = u.handle,
                            damage = txsh1,
                            level = 1,
                            type = "魔力",
                            isvest = false,
                            isattack = false,
                            isnoarmor = false,
                            element = "光",
                            extradata = {"法术", "魔导"}
                          })
                          xq:buffset(u.handle, 1, "僵直")
                          if u:hasdata("卡斯特-调停者的指引") and not xq:hasdata("调停者的指引冷却") then
                            xq:settimedata("调停者的指引冷却", 0.1)
                            xq:changetimedata("调停者的指引-额外受伤", 0.02, 30)
                          end
                        end
                      end
                    }
                  },
                  endfunc = function()
                    txmj:remove()
                  end
                })
              end)
              ac.wait(100, function()
                local a2 = GetRandomAngle()
                for i = 1, 3 do
                  a2 = a2 + GetRandomReal(100, 150)
                  local x3, y3 = PolarXY(x2, y2, 600, a2)
                  local txmj = u:createunit("u03L", x3, y3, a2)
                  a2 = a2 + 180
                  local g = CreateGroupLua()
                  unitmove({
                    unit = txmj.handle,
                    time = 1,
                    distance = 1200,
                    angle = a2,
                    loops = {
                      {
                        looptime = 0.065,
                        func = function(dx, dy)
                          Effectcreate("AATX\\[AATxNew]ShockBoom19.mdl", dx, dy, 0, 2)
                          Effectcreate("AATX\\[AATxNew]Hit16.mdl", dx, dy, 0, 2)
                        end
                      },
                      {
                        looptime = 0.1,
                        func = function(dx, dy)
                          for _, xq in ac.selector():in_rangexy(dx, dy, 200):is_enemy(u.handle):ipairs() do
                            xq = getunit(xq)
                            local vest = true
                            if not xq:isingroup(g) then
                              vest = false
                              xq:groupadd(g)
                            end
                            DamageUnit({
                              bj = "C呆(机体)",
                              unit = xq.handle,
                              source = u.handle,
                              damage = txsh2,
                              level = 1,
                              type = "魔力",
                              isvest = vest,
                              isattack = false,
                              isnoarmor = false,
                              element = "光",
                              extradata = {"法术", "魔导"}
                            })
                            xq:buffset(u.handle, 1, "僵直")
                            if u:hasdata("卡斯特-调停者的指引") and not xq:hasdata("调停者的指引冷却") then
                              xq:settimedata("调停者的指引冷却", 0.1)
                              xq:changetimedata("调停者的指引-额外受伤", 0.02, 30)
                            end
                          end
                        end
                      }
                    },
                    endfunc = function()
                      txmj:remove()
                    end
                  })
                end
              end)
              ac.wait(200, function()
                local a2 = GetRandomAngle()
                for i = 1, 3 do
                  a2 = a2 + GetRandomReal(100, 150)
                  local x3, y3 = PolarXY(x2, y2, 600, a2)
                  local txmj = u:createunit("u03L", x3, y3, a2)
                  a2 = a2 + 180
                  local g = CreateGroupLua()
                  unitmove({
                    unit = txmj.handle,
                    time = 1,
                    distance = 1200,
                    angle = a2,
                    loops = {
                      {
                        looptime = 0.065,
                        func = function(dx, dy)
                          Effectcreate("AATX\\[AATxNew]ShockBoom19.mdl", dx, dy, 0, 2)
                          Effectcreate("AATX\\[AATxNew]Hit16.mdl", dx, dy, 0, 2)
                        end
                      },
                      {
                        looptime = 0.1,
                        func = function(dx, dy)
                          for _, xq in ac.selector():in_rangexy(dx, dy, 200):is_enemy(u.handle):ipairs() do
                            xq = getunit(xq)
                            local vest = true
                            if not xq:isingroup(g) then
                              vest = false
                              xq:groupadd(g)
                            end
                            DamageUnit({
                              bj = "C呆(机体)",
                              unit = xq.handle,
                              source = u.handle,
                              damage = txsh2,
                              level = 1,
                              type = "魔力",
                              isvest = vest,
                              isattack = false,
                              isnoarmor = false,
                              element = "光",
                              extradata = {"法术", "魔导"}
                            })
                            xq:buffset(u.handle, 1, "僵直")
                            if u:hasdata("卡斯特-调停者的指引") and not xq:hasdata("调停者的指引冷却") then
                              xq:settimedata("调停者的指引冷却", 0.1)
                              xq:changetimedata("调停者的指引-额外受伤", 0.02, 30)
                            end
                          end
                        end
                      }
                    },
                    endfunc = function()
                      txmj:remove()
                    end
                  })
                end
              end)
            end)
          end)
          ac.wait(700, function()
            u:animeact(13)
          end)
          return
        else
          u:sendmessage("|cFFFFCC33魔力值不足|r")
        end
      end
      ac.wait(1, function()
        u:animeact(8)
        u:animespeed(3)
        local txsh = 5000 + 25 * u:getallattri() * (1 + 0.015 * u:getlevel())
        local x2, y2 = x, y
        ac.timer(200, 5, function()
          x2, y2 = PolarXY(x2, y2, 400, angle)
          u:playsound(bac391)
          Effectcreate("AATX\\[AATxNew]Colour07.mdl", x2, y2, 0, 1)
        end)
        ac.wait(100, function()
          local x2, y2 = x, y
          ac.timer(500, 5, function()
            x2, y2 = PolarXY(x2, y2, 400, angle)
            u:playsound(bac288)
            Effectcreate("AATX\\[AATxNew]Fire19_C.mdl", x2, y2, 1, 0.75)
            ac.timer(250, 4, function()
              for _, xq in ac.selector():in_rangexy(x2, y2, 350):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                xq:buffset(u.handle, 0.5, "僵直")
                DamageUnit({
                  bj = "C呆(机体)",
                  unit = xq.handle,
                  source = u.handle,
                  damage = txsh,
                  level = 1,
                  type = "魔力",
                  isvest = false,
                  isattack = false,
                  isnoarmor = false,
                  element = "光",
                  extradata = {"法术", "魔导"}
                })
                if u:hasdata("卡斯特-调停者的指引") and not xq:hasdata("调停者的指引冷却") then
                  xq:settimedata("调停者的指引冷却", 0.1)
                  xq:changetimedata("调停者的指引-额外受伤", 0.02, 30)
                end
              end
            end)
          end)
        end)
        ac.wait(300, function()
          u:animespeed(1)
        end)
      end)
    end
  }
}
return skill
