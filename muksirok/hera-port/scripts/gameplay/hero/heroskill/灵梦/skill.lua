-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local skill = {
  {
    name = "祈愿「祛除厄运之祈愿」",
    skill = "A05P",
    func = function(self, args)
      local u = getunit(args.unit)
      local sy = u.ownerid
      local tg = getunit(args.target)
      local x, y = tg:getxy()
      local hp = 300 + u:getlevel() * 20
      if u.handle ~= tg.handle then
        hp = hp + 0.1 * u:gethp() + 0.1 * u:getmisshp()
        local yx = {}
        yx[1] = Sound_Reimu_01
        yx[2] = Sound_Reimu_02
        yx[3] = Sound_Reimu_03
        u:playsound(yx[GetRandomInt(1, 3)])
      end
      tg:curehp(u.handle, hp, 0, 1)
      tg:clearbuff("僵直")
      tg:clearbuff("眩晕")
      tg:clearbuff("缠绕")
      tg:clearbuff()
      ac.timer(100, 10, function()
        tg:clearbuff("僵直")
        tg:clearbuff("眩晕")
        tg:clearbuff("缠绕")
        tg:clearbuff()
      end)
      Effectcreate("AATX\\[AATxNew]White42.mdl", x, y, 0, 2)
      tg:effectadd("Abilities\\Spells\\Human\\ReviveHuman\\ReviveHuman.mdl")
      for _, xq in ac.selector():in_rangexy(x, y, 450):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        xq:buffset(u.handle, 2, "眩晕")
        unitmove({
          unit = xq.handle,
          time = 0.8,
          distance = 450 - DistanceBetweenUnits(xq.handle, tg.handle),
          angle = AngleBetweenUnits(tg.handle, u.handle)
        })
      end
    end
  },
  {
    name = "亚空穴",
    skill = "A03T",
    func = function(self, args)
      local u = getunit(args.unit)
      local sy = u.ownerid
      local x, y = u:getxy()
      local x2 = args.x
      local y2 = args.y
      local tilixh = 1
      local skill = S2ID(self.skill)
      if u:hasbuff("缠绕") then
        u:setskillcd(skill, 0.01)
        u:sendmessage("|cFFFF3300缠绕中|r")
        return
      end
      if not u:hasdata("位移体力消耗标记") then
        if u:lossstamina(tilixh) then
          u:settimedata("位移体力消耗标记", 0.001)
        else
          u:setskillcd(skill, 0.01)
          u:sendmessage("|cFFFF3300体力值不足|r")
          if not u:hasdata("技能释放失败") then
            u:settimedata("技能释放失败", 0.05)
          end
          return
        end
      end
      u:setdata("霰弹换弹", false)
      u:setdata("射击状态", false)
      Effectcreate("Abilities\\Spells\\NightElf\\Blink\\BlinkCaster.mdl", x, y)
      u:buffset(u.handle, 2, "飞行")
      u:buffset(u.handle, 0.5, "无敌")
      local angle = AngleXY(x, y, x2, y2)
      local x3, y3 = PolarXY(x2, y2, -300, angle)
      Effectcreate("Abilities\\Spells\\NightElf\\Blink\\BlinkCaster.mdl", x3, y3, 0, 1, 300)
      u:setxy(x3 + 16, y3 + 16)
      u:setface(angle)
      local cs = 0
      local gd = 250
      u:setflyheight(gd)
      local txsh = 1000 * u:getlevel() + 100 * u:getstr()
      unitmove({
        unit = u.handle,
        time = 0.1,
        distance = 300,
        angle = angle,
        isfly = true,
        loops = {
          {
            looptime = 0.01,
            func = function()
              gd = gd - 25
              u:setflyheight(gd)
            end
          }
        },
        endfunc = function()
          u:setflyheight(0)
          x, y = u:getxy()
          Effectcreate("Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl", x, y)
          Effectcreate("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", x, y)
          for _, xq in ac.selector():in_rangexy(x, y, 325):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            xq:buffset(u.handle, 2, "眩晕")
            DamageUnit({
              bj = "灵梦(亚空穴)",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "物理",
              isvest = false,
              isattack = true,
              isnoarmor = false,
              element = "无"
            })
          end
        end
      })
      u:setcolor(255, 255, 255, 155)
      ac.wait(2000, function()
        u:setcolor(255, 255, 255, 255)
      end)
      u:changedata("亚空穴充能次数", -1)
      if u:getdata("亚空穴充能次数") > 0 then
        ac.wait(2, function()
          u:setskillcd(self.skill, 0)
        end)
      end
    end
  },
  {
    name = "神佑第六感",
    skill = "A01I",
    func = function(self, args)
      local u = getunit(args.unit)
      u:effectadd("Abilities\\Spells\\Human\\ControlMagic\\ControlMagicTarget.mdl", "overhead", 0.5)
      local str = "灵梦格挡判定时间"
      if Boolean_Jinselingyu then
        u:setdata(str, 0.3)
      else
        u:setdata(str, 0.5)
      end
    end
  },
  {
    name = "梦符「封魔阵」",
    skill = "A1AX",
    func = function(self, args)
      local u = getunit(args.unit)
      local sy = u.ownerid
      local x, y = u:getxy()
      local x2 = args.x
      local y2 = args.y
      local angle = AngleXY(x, y, x2, y2)
      local txsh = 10000 + 500 * u:getint()
      u:playsound(Sound_Reimu_04)
      unifycreate({
        owner = u.handle,
        model = "AATX\\[AATxNew]Animate27.mdl",
        modelname = "封魔符",
        modelsize = 1,
        height = 90,
        damage = 0,
        damagetype = 6,
        x = x,
        y = y,
        time = 0.9,
        speed = 2000,
        volume = 110,
        angle = angle,
        angleoffset = 0,
        attenua = 1,
        attenuacount = 1,
        life = 10,
        isbullet = false,
        isvest = false,
        isignorearmor = false,
        startfunc = function(mj)
          mj:animespeed(3)
          mj:setdata("封魔符未触发")
        end,
        hitbeforefunc = function(mj, xq, damage2)
          mj:deldata("封魔符未触发")
          mj:playsound(Sound_Reimu_05)
          x, y = mj:getxy()
          local tx = Effectcreate("AATX\\[AATxNew]Animate28.mdl", x, y, -1, 3.5)
          ac.wait(500, function()
            SetEffectSize(tx, 0.01)
            DestroyEffectLua(tx)
          end)
          Effectcreate("AATX\\[AATxNew]Yellow05.mdl", x, y, 0, 3.5)
          for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            xq:removecharacteristics(10)
            xq:buffset(u.handle, 10, "眩晕")
            xq:effectadd("Abilities\\Spells\\Human\\AerialShackles\\AerialShacklesTarget.mdl", "chest", 10)
            DamageUnit({
              bj = "灵梦(封魔阵)",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "灵力",
              isvest = false,
              isattack = false,
              isnoarmor = false,
              element = "光"
            })
          end
        end,
        endfunc = function(mj)
          if mj:hasdata("封魔符未触发") then
            mj:playsound(Sound_Reimu_05)
            x, y = mj:getxy()
            local tx = Effectcreate("AATX\\[AATxNew]Animate28.mdl", x, y, -1, 3.5)
            ac.wait(500, function()
              SetEffectSize(tx, 0.01)
              DestroyEffectLua(tx)
            end)
            Effectcreate("AATX\\[AATxNew]Yellow05.mdl", x, y, 0, 3.5)
            for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              xq:removecharacteristics(10)
              xq:buffset(u.handle, 10, "眩晕")
              xq:effectadd("Abilities\\Spells\\Human\\AerialShackles\\AerialShacklesTarget.mdl", "chest", 10)
              DamageUnit({
                bj = "灵梦(封魔阵)",
                unit = xq.handle,
                source = u.handle,
                damage = txsh,
                level = 1,
                type = "灵力",
                isvest = false,
                isattack = false,
                isnoarmor = false,
                element = "光"
              })
            end
          end
          mj:deldata("封魔符未触发")
        end
      })
      if u:hasdata("灵梦-梦想封印") then
        u:changedata("封魔符充能次数", -1)
        if u:getdata("封魔符充能次数") > 0 then
          ac.wait(2, function()
            u:setskillcd(self.skill, 0)
          end)
        end
      end
    end
  }
}
return skill
