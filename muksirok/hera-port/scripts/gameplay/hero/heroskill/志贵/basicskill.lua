-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local ewtl = {
  {name = "EE"},
  {name = "AE"},
  {name = "EAE"},
  {name = "AEE"},
  {name = "AAE"},
  {name = "QWEE"},
  {name = "QWE"},
  {name = "QWEA"},
  {name = "AEA"},
  {name = "AAA"},
  {name = "EEA"},
  {name = "EEE"},
  {name = "EAA"},
  {name = "EA"},
  {name = "AA"}
}
local zgc = require("gameplay.hero.heroskill.志贵.skill")

local function set(u, skillstr)
  local sh = u:getdata("角色基础伤害")
  local bs = u:getdata("志贵-伤害范围加成")
  local txstr1, txstr2
  if u:getdata("志贵形态") == "七夜" then
    txstr1 = "war3mapImported\\Daji_Hong1.mdl"
    txstr2 = "chest"
  else
    txstr1 = "war3mapImported\\zhigui_daji5.mdl"
    txstr2 = "origin"
  end
  return sh, bs, txstr1, txstr2
end

local function vact(u)
  local sy = u.ownerid
  if u:getdata("志贵形态") == "七夜" then
    u:setdata("志贵形态", "远野")
    if u:hasdata("隐藏职业-虚拟主播") then
      ModelReSet({
        u = u,
        modelsize = u:getdata("志贵-七夜模型大小"),
        model = u:getdata("志贵-七夜模型")
      })
      if u:islocal() then
        u:setskilldatastring("A1MN", "图标", "war3mapImported\\BTNShiki_V1" .. u:getdata("志贵-图标后缀"))
        u:setskilldatastring("A1MY", "图标", "war3mapImported\\BTNShiki_V1" .. u:getdata("志贵-图标后缀"))
      end
    else
      ModelReSet({
        u = u,
        modelsize = u:getdata("志贵-远野模型大小"),
        model = u:getdata("志贵-远野模型")
      })
      if u:islocal() then
        u:setskilldatastring("A1MN", "图标", "war3mapImported\\BTNShiki_V2" .. u:getdata("志贵-图标后缀"))
        u:setskilldatastring("A1MY", "图标", "war3mapImported\\BTNShiki_V2" .. u:getdata("志贵-图标后缀"))
      end
    end
  else
    u:setdata("志贵形态", "七夜")
    if u:hasdata("隐藏职业-虚拟主播") then
      ModelReSet({
        u = u,
        modelsize = u:getdata("志贵-远野模型大小"),
        model = u:getdata("志贵-远野模型")
      })
      if u:islocal() then
        u:setskilldatastring("A1MN", "图标", "war3mapImported\\BTNShiki_V2" .. u:getdata("志贵-图标后缀"))
        u:setskilldatastring("A1MY", "图标", "war3mapImported\\BTNShiki_V2" .. u:getdata("志贵-图标后缀"))
      end
    else
      ModelReSet({
        u = u,
        modelsize = u:getdata("志贵-七夜模型大小"),
        model = u:getdata("志贵-七夜模型")
      })
      if u:islocal() then
        u:setskilldatastring("A1MN", "图标", "war3mapImported\\BTNShiki_V1" .. u:getdata("志贵-图标后缀"))
        u:setskilldatastring("A1MY", "图标", "war3mapImported\\BTNShiki_V1" .. u:getdata("志贵-图标后缀"))
      end
    end
  end
  local xh = 1.5
  for index, value in ipairs(ewtl) do
    if u:getdata("七夜连携") == value.name then
      xh = xh + u:getdata("志贵-额外体力消耗-" .. value.name .. "V")
    end
  end
  if u:lossstamina(xh) then
  else
    u:setskillcd("A1MN", 0.1)
    u:setskillcd("A1MY", 0.1)
    u:sendmessage("|cFFFF3300体力值不足|r")
    return
  end
  local skillstr
  local b = false
  for index, value in ipairs(ewtl) do
    if u:getdata("七夜连携") == value.name then
      b = true
      skillstr = value.name .. "V"
      break
    end
  end
  if b then
    if u:hasdata("志贵-手搓模式") and (skillstr == "EAAV" or skillstr == "AAEV" or skillstr == "AEEV") then
      skillstr = skillstr .. "-HandMode"
    end
    if zgc[skillstr] then
      zgc[skillstr](u)
    else
      print("不存在的志贵连携:" .. skillstr)
    end
    local ewxh = 0.6
    if u:hasdata("志贵天赋-梦境之外") then
      ewxh = ewxh * 0.75
    end
    u:changetimedata("志贵-额外体力消耗-" .. skillstr, ewxh, 8)
    if u:hasdata("志贵-爆气状态") then
      if u:getdata("志贵形态") == "七夜" then
        u:setdata("志贵-无视伤害闪避时间", u:getdata("志贵-破抗时间"))
      else
        u:setdata("志贵-无视伤害免疫时间", u:getdata("志贵-破抗时间"))
      end
    end
    ac.wait(1, function()
      u:setskillcd("A1MN", 0.5)
      u:setskillcd("A1MY", 0.5)
    end)
  elseif u:hasdata("志贵天赋-梦境之外") then
    u:setskillcd("A1MN", 3)
    u:setskillcd("A1MY", 3)
  end
end

local function zhigui_combo(u)
  u:changedata("志贵-连击数", 1)
  local lj = u:getdata("志贵-连击数")
  local str
  if u:getdata("志贵形态") == "七夜" or u:hasdata("变异判定-噩梦志贵") then
    str = "|cFFFFFF00" .. math.floor(lj) .. "|r |cFFFF9900hit(" .. math.floor(u:getdata("志贵-七夜连击伤害") + 100) .. "%)|r"
  else
    str = "|cFFFFFF00" .. math.floor(lj) .. "|r |cFFFF9900hit"
  end
  flytext({
    unit = u.handle,
    text = str,
    size = 10,
    time = 1,
    xspeed = GetRandomReal(-0.03, 0.03),
    yspeed = 0.05
  })
end

local function zhiguicamlock(u)
  if not u:hasdata("志贵-镜头长锁") and not u:hasdata("志贵-禁止镜头锁定") then
    SetCameraTargetControllerNoZForPlayer(u.owner, u.handle, 0, 0, false)
  end
end

local function zhiguicamunlock(u)
  if not u:hasdata("志贵-镜头长锁") and not u:hasdata("志贵-禁止镜头锁定") then
    ac.wait(100, function()
      ResetToGameCameraForPlayer(u.owner, 0)
      local p = getplayer(u.owner)
      p:setcameraheight(Cam_height[u.ownerid], 0)
    end)
  end
end

local function zhiguicamset(u, x, y)
  if not u:hasdata("志贵-镜头长锁") and not u:hasdata("志贵-禁止镜头锁定") then
    getplayer(u.owner):setcamera(x, y, 0)
  end
end

local function lianxie(u, skillstr)
  u:setdata("七夜连携", skillstr)
  local t = 1
  local t2 = 0.5
  if skillstr == "Q" or skillstr == "W" then
    t = 0.75
    t2 = 0.3
  end
  if u:hasdata("志贵天赋-一体同心") then
    u:setdata("七夜连携时间", t2)
  else
    u:setdata("七夜连携时间", t * u:getdata("志贵-连锁时间"))
  end
end

local zhiguiskill = {
  {
    name = "Q",
    skill = "A1ML",
    func = function(self, args)
      local u = getunit(args.unit)
      local sy = u.ownerid
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
          return
        end
      end
      ac.wait(1, function()
        ResetUnitAnimation(u.handle)
        u:animespeed(2)
        u:animeact(12)
        ac.wait(200, function()
          if u:getdata("七夜连携") == "Q" then
            ResetUnitAnimation(u.handle)
          end
        end)
      end)
      if u:hasdata("志贵-镜头全锁定") then
        zhiguicamlock(u)
      end
      lianxie(u, "Q")
      unitmove({
        unit = u.handle,
        time = 0.1,
        distance = 500,
        angle = u:getface() + 180,
        startfunc = function()
          if u:getdata("绝对闪避时间") == 0 then
            u:setdata("刷新Q时间", 0.15)
          end
          movexg(u.handle, 0.15, skill, "Q", "志贵-Q")
        end,
        loops = {
          {
            looptime = 0.01,
            func = function(dx, dy, args)
              if u:hasdata("志贵-QW阻止Q位移") then
                args.stop = true
              end
            end
          }
        },
        endfunc = function()
          local x, y = u:getxy()
          u:setdata("位移点X", x)
          u:setdata("位移点Y", y)
          if u:hasdata("志贵-镜头全锁定") then
            zhiguicamunlock(u)
          end
        end
      })
    end
  },
  {
    name = "W",
    skill = "A1MO",
    func = function(self, args)
      local u = getunit(args.unit)
      local sy = u.ownerid
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
          return
        end
      end
      local x, y = u:getxy()
      local angle = u:getface()
      if u:getdata("七夜连携") == "Q" then
        zgc.QW(u)
        return
      end
      if u:hasdata("志贵-镜头全锁定") then
        zhiguicamlock(u)
      end
      lianxie(u, "W")
      ac.wait(1, function()
        ResetUnitAnimation(u.handle)
        u:animespeed(2)
        u:animeact(12)
        ac.wait(200, function()
          ResetUnitAnimation(u.handle)
        end)
      end)
      unitmove({
        unit = u.handle,
        time = 0.1,
        distance = 500,
        angle = u:getface(),
        startfunc = function()
          if u:getdata("绝对闪避时间") == 0 then
            u:setdata("刷新W时间", 0.15)
          end
          movexg(u.handle, 0.15, skill, "W", "志贵-W")
        end,
        endfunc = function()
          local x, y = u:getxy()
          u:setdata("位移点X", x)
          u:setdata("位移点Y", y)
          if u:hasdata("志贵-镜头全锁定") then
            zhiguicamunlock(u)
          end
        end
      })
    end
  },
  {
    name = "R",
    skill = "A1MM",
    func = function(self, args)
      local u = getunit(args.unit)
      local tg = getunit(args.target)
      local sy = u.ownerid
      local tilixh = 1
      local skill = S2ID(self.skill)
      if u:hasbuff("缠绕") and (not (u:getdata("志贵-R2时间") > 0) or u:getdata("志贵形态") ~= "远野" or not not u:hasdata("志贵-十七分割已释放")) and (not (0 < u:getdata("志贵-R3时间")) or u:getdata("志贵形态") ~= "七夜" or not not u:hasdata("志贵-极死七夜已释放")) then
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
          return
        end
      end
      if u:getdata("志贵-R2时间") > 0 and u:getdata("志贵形态") == "远野" and not u:hasdata("志贵-十七分割已释放") then
        zgc.R2(u, tg)
        return
      end
      if 0 < u:getdata("志贵-R3时间") and u:getdata("志贵形态") == "七夜" and not u:hasdata("志贵-极死七夜已释放") then
        zgc.R3(u, tg)
        return
      end
      local x, y = u:getxy()
      local x2, y2 = tg:getxy()
      local angle = AngleBetweenUnits(u.handle, tg.handle)
      if u:getdata("志贵形态") == "七夜" then
        Effectcreate("Abilities\\Spells\\Items\\AIil\\AIilTarget.mdl", x, y)
        local yx = {}
        yx[1] = Nanaya_B0AA060
        yx[2] = Nanaya_B0AA061
        yx[3] = Nanaya_B0AA063
        yx[4] = Nanaya_B0AA117
        yx[5] = Nanaya_B0AA119a
        u:playsound(yx[GetRandomInt(1, 5)])
      else
        Effectcreate("ATX\\[ATxNew]Black_01.mdl", x, y)
        local yx = {}
        yx[1] = Shiki_B0AA075
        yx[2] = Shiki_B0AA077
        yx[3] = Shiki_B0AA080
        yx[4] = Shiki_B0AA100
        yx[5] = Shiki_B0AA101
        u:playsound(yx[GetRandomInt(1, 5)])
      end
      local kz = u:getdata("志贵-控制时间")
      local bs = u:getdata("志贵-伤害范围加成")
      for _, xq in ac.selector():in_rangexy(x2, y2, 350 + bs):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        xq:buffset(u.handle, 1 * kz, "眩晕")
      end
      local dis = 125 + DistanceBetweenUnits(u.handle, tg.handle)
      x2, y2 = PolarXY(x, y, dis, angle)
      u:setxy(x2, y2)
      if u:hasdata("志贵-镜头全锁定") then
        zhiguicamset(u, x2, y2)
      end
      u:setface(angle + 180)
      u:buffset(u.handle, 0.1, "绝对闪避")
      if u:getdata("志贵形态") == "七夜" then
        Effectcreate("Abilities\\Spells\\Items\\AIil\\AIilTarget.mdl", x2, y2)
      else
        Effectcreate("ATX\\[ATxNew]Black_01.mdl", x2, y2)
      end
    end
  },
  {
    name = "S",
    skill = "A1MQ",
    func = function(self, args)
      local u = getunit(args.unit)
      local sy = u.ownerid
      local tilixh = 1
      local skill = S2ID(self.skill)
      if u:hasbuff("缠绕") and not u:hasdata("志贵天赋-吾乃以面影之丝织巢的蜘蛛") then
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
          return
        end
      end
      if u:getdata("志贵-R2时间") > 0 and u:getdata("志贵形态") == "远野" then
        return
      end
      if 0 < u:getdata("志贵-R3时间") and u:getdata("志贵形态") == "七夜" and not u:hasdata("志贵-极死七夜已释放") then
        return
      end
      local x, y = u:getxy()
      local x2 = args.x
      local y2 = args.y
      if u:getdata("志贵形态") == "七夜" then
        Effectcreate("Abilities\\Spells\\Items\\AIil\\AIilTarget.mdl", x, y)
        local yx = {}
        yx[1] = Nanaya_B0AA060
        yx[2] = Nanaya_B0AA061
        yx[3] = Nanaya_B0AA063
        yx[4] = Nanaya_B0AA117
        yx[5] = Nanaya_B0AA119a
        u:playsound(yx[GetRandomInt(1, 5)])
      else
        Effectcreate("ATX\\[ATxNew]Black_01.mdl", x, y)
        local yx = {}
        yx[1] = Shiki_B0AA075
        yx[2] = Shiki_B0AA077
        yx[3] = Shiki_B0AA080
        yx[4] = Shiki_B0AA100
        yx[5] = Shiki_B0AA101
        u:playsound(yx[GetRandomInt(1, 5)])
      end
      local mjl = 600
      local dis = DistanceXY(x, y, x2, y2)
      local angle = AngleXY(x, y, x2, y2)
      if u:hasdata("志贵天赋-闪鞘光影虚空") then
        mjl = 1200
      end
      if dis >= mjl then
        x2, y2 = PolarXY(x, y, mjl, angle)
      end
      if u:getdata("志贵形态") == "七夜" then
        Effectcreate("Abilities\\Spells\\Items\\AIil\\AIilTarget.mdl", x2, y2)
      else
        Effectcreate("ATX\\[ATxNew]Black_01.mdl", x2, y2)
      end
      u:setxy(x2, y2)
      if u:hasdata("志贵-镜头全锁定") then
        zhiguicamset(u, x2, y2)
      end
      if u:hasdata("志贵-强断连招开启") and 0 < u:getdata("志贵连招暂停时间") then
        u:setdata("志贵连招暂停时间", 0)
        u:settimedata("志贵-强断连招", 0.1)
        u:setflyheight(0)
      end
      IssueImmediateOrder(u.handle, "stop")
      u:setdata("位移点X", x2)
      u:setdata("位移点Y", y2)
      u:changedata("七夜连携时间", 0.5, 1)
      u:buffset(u.handle, 0.1, "绝对闪避")
      local cd = 3
      if u:hasdata("变异判定-七夜志贵") or u:hasdata("变异判定-噩梦志贵") then
        cd = cd - 0.6
      end
      if u:hasdata("志贵天赋-吾乃以面影之丝织巢的蜘蛛") then
        cd = cd - 1
      end
      ac.wait(1, function()
        u:setskillcd(skill, cd)
      end)
      if not u:hasdata("志贵-十七分割已释放") and u:getdata("志贵形态") == "远野" then
        if u:hasdata("志贵-BH状态") then
          if u:getdata("志贵-连携点数值") + u:getdata("志贵-连击数") * 0.5 >= 44 then
            u:setdata("志贵-R2时间", 0.3)
          end
        elseif u:hasdata("志贵天赋-这就是将事物杀死啊") and not u:hasdata("志贵-十七分割冷却") then
          if u:hasdata("志贵-爆气状态") then
            if u:getdata("志贵-连携点数值") >= 44 then
              u:setdata("志贵-R2时间", 0.3)
            end
          elseif u:getdata("志贵-连携点数值") >= 44 and u:getdata("志贵-连击数") >= 44 then
            u:setdata("志贵-R2时间", 0.3)
          end
        end
      end
    end
  },
  {
    name = "E",
    skill = "A1MK",
    func = function(self, args)
      local u = getunit(args.unit)
      local sy = u.ownerid
      local tilixh = 1
      local skill = S2ID(self.skill)
      if not u:hasdata("位移体力消耗标记") then
        if u:lossstamina(tilixh) then
          u:settimedata("位移体力消耗标记", 0.001)
        else
          u:setskillcd(skill, 0.01)
          u:sendmessage("|cFFFF3300体力值不足|r")
          return
        end
      end
      local str = u:getdata("七夜连携")
      local str2 = "E"
      if str == "QW" or str == "E" or str == "A" then
        zgc[str .. str2](u)
        return
      end
      if u:getdata("志贵形态") == "七夜" and (str == "EA" or str == "EE" or str == "AE") then
        zgc[str .. str2](u)
        return
      end
      if u:getdata("志贵形态") == "远野" and (str == "AA" or str == "QWE") then
        zgc[str .. str2](u)
        return
      end
      local sh, bs, txstr1, txstr2 = set(u, "E")
      local kz = u:getdata("志贵-控制时间")
      local x, y = u:getxy()
      local angle = u:getface()
      u:playseensound(zhigui_zhanji1)
      if u:getdata("志贵形态") == "七夜" then
        u:playseensound(Nanaya_zhandou23)
      else
        u:playseensound(Shiki_zhandou18)
      end
      lianxie(u, "E")
      ac.wait(1, function()
        ResetUnitAnimation(u.handle)
        u:animespeed(2)
        u:animeact(1)
      end)
      ac.wait(100, function()
        x, y = u:getxy()
        x, y = PolarXY(x, y, 50, angle)
        if u:hasdata("志贵-镜头全锁定") then
          zhiguicamset(u, x, y)
        end
        u:setxy(x, y)
        local x2, y2 = PolarXY(x, y, 150, angle)
        local tx = Effectcreate("war3mapImported\\qiye_zhanji4.mdl", x2, y2, -1, 0.8, 170, angle + GetRandomReal(150, 210), 200)
        SetEffectActSpeed(tx, 1.2)
        DestroyEffectLua(tx)
        local tx = Effectcreate("war3mapImported\\qiye_zhanji4.mdl", x2, y2, -1, 0.8, 170, angle + GetRandomReal(150, 210), 200)
        SetEffectActSpeed(tx, 1.5)
        DestroyEffectLua(tx)
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x2, y2, 300 + bs):is_enemy(u.handle):ipairs() do
          mz2 = true
          xq = getunit(xq)
          DamageUnit({
            bj = "志贵(机体)",
            unit = xq.handle,
            source = u.handle,
            damage = 1 * sh,
            level = 1,
            type = "物理",
            isvest = false,
            isattack = true,
            isnoarmor = false,
            element = "无"
          })
          unitmove({
            unit = xq.handle,
            time = 0.02,
            distance = 50,
            angle = angle
          })
          xq:effectadd(txstr1, txstr2)
          xq:buffset(u.handle, 1 * kz, "僵直")
        end
        if mz2 then
          zhigui_combo(u)
          CameraSetEQNoiseForPlayer(u.owner, 10.0)
        end
        ac.wait(150, function()
          CameraClearNoiseForPlayer(u.owner)
        end)
      end)
    end
  },
  {
    name = "E2",
    skill = "A1MZ",
    func = function(self, args)
      local u = getunit(args.unit)
      local sy = u.ownerid
      local tilixh = 0.1
      local skill = S2ID(self.skill)
      if not u:hasdata("位移体力消耗标记") then
        if u:lossstamina(tilixh) then
          u:settimedata("位移体力消耗标记", 0.001)
        else
          u:setskillcd(skill, 0.01)
          u:sendmessage("|cFFFF3300体力值不足|r")
          return
        end
      end
      local x2 = args.x
      local y2 = args.y
      u:setdata("志贵-X", x2)
      u:setdata("志贵-Y", y2)
      local str = u:getdata("七夜连携")
      local str2 = "E"
      if str == "AEEV" or str == "AEEVE" or str == "AEEVEE" or str == "AEEVEEE" or str == "AEEVEEEE" or str == "AEEVEEEEE" or str == "AAEV" then
        zgc[str .. str2](u)
        return
      end
    end
  },
  {
    name = "A",
    skill = "A1MH",
    func = function(self, args)
      local u = getunit(args.unit)
      local sy = u.ownerid
      local tilixh = 1
      local skill = S2ID(self.skill)
      if not u:hasdata("位移体力消耗标记") then
        if u:lossstamina(tilixh) then
          u:settimedata("位移体力消耗标记", 0.001)
        else
          u:setskillcd(skill, 0.01)
          u:sendmessage("|cFFFF3300体力值不足|r")
          return
        end
      end
      local str = u:getdata("七夜连携")
      local str2 = "A"
      if str == "AA" or str == "E" or str == "A" then
        zgc[str .. str2](u)
        return
      end
      if u:getdata("志贵形态") == "七夜" and (str == "QWE" or str == "AE") then
        zgc[str .. str2](u)
        return
      end
      if u:getdata("志贵形态") == "远野" and (str == "EE" or str == "EA") then
        zgc[str .. str2](u)
        return
      end
      local sh, bs, txstr1, txstr2 = set(u, "A")
      local kz = u:getdata("志贵-控制时间")
      local x, y = u:getxy()
      local angle = u:getface()
      u:playseensound(zhigui_zhanji1)
      if u:getdata("志贵形态") == "七夜" then
        u:playseensound(Nanaya_zhandou24)
      else
        u:playseensound(Shiki_zhandou19)
      end
      lianxie(u, "A")
      ac.wait(1, function()
        ResetUnitAnimation(u.handle)
        u:animespeed(2)
        u:animeact(1)
      end)
      ac.wait(100, function()
        x, y = u:getxy()
        x, y = PolarXY(x, y, 50, angle)
        if u:hasdata("志贵-镜头全锁定") then
          zhiguicamset(u, x, y)
        end
        u:setxy(x, y)
        local x2, y2 = PolarXY(x, y, 150, angle)
        local tx = Effectcreate("war3mapImported\\File00006330.mdl", x2, y2, -1, 2, 100, angle, -30)
        SetEffectActSpeed(tx, 2)
        DestroyEffectLua(tx)
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x2, y2, 300 + bs):is_enemy(u.handle):ipairs() do
          mz2 = true
          xq = getunit(xq)
          DamageUnit({
            bj = "志贵(机体)",
            unit = xq.handle,
            source = u.handle,
            damage = 1 * sh,
            level = 1,
            type = "物理",
            isvest = false,
            isattack = true,
            isnoarmor = false,
            element = "无"
          })
          unitmove({
            unit = xq.handle,
            time = 0.02,
            distance = 50,
            angle = angle
          })
          xq:effectadd(txstr1, txstr2)
          xq:buffset(u.handle, 1 * kz, "僵直")
        end
        if mz2 then
          zhigui_combo(u)
          CameraSetEQNoiseForPlayer(u.owner, 10.0)
        end
        ac.wait(150, function()
          CameraClearNoiseForPlayer(u.owner)
        end)
      end)
    end
  },
  {
    name = "D",
    skill = "A1MJ",
    func = function(self, args)
      local u = getunit(args.unit)
      local sy = u.ownerid
      u:effectadd("Abilities\\Spells\\Human\\ControlMagic\\ControlMagicTarget.mdl", "overhead", 1)
      u:setdata("志贵-格挡判定时间", 0.3)
    end
  },
  {
    name = "C",
    skill = "A1MI",
    func = function(self, args)
      local u = getunit(args.unit)
      local sy = u.ownerid
      local x, y = u:getxy()
      local angle = u:getface()
      local hlz = u:getdata("志贵-魔术回路值")
      if 300 <= hlz then
        u:setdata("UI-爆气上限", 20)
        u:setdata("志贵-爆气时间", 20)
        u:setdata("志贵-爆气特效", u:effectadd("zhigui_baoqi1.mdl", "chest", -1))
        u:setdata("志贵-魔术回路值", 0)
        u:setdata("志贵-爆气状态")
        u:setdata("志贵-BH状态")
        u:deldata("志贵-极死七夜已释放")
        u:deldata("志贵-十七分割已释放")
        if u:hasdata("志贵天赋-推土机") then
          u:clearbuff("僵直")
          u:clearbuff("眩晕")
          u:clearbuff("缠绕")
          u:clearbuff("混乱")
          u:clearbuff("麻痹")
          u:clearbuff()
        end
        u:shockcamera(200, 0.15)
        u:playseensound(zhigui_baoqi)
        if u:getdata("志贵形态") == "七夜" then
          u:playseensound(Nanaya_zhandou12)
        else
          u:playseensound(Shiki_zhandou15)
        end
        Effectcreate("war3mapImported\\zhigui_baoqi3.mdl", x, y, 0, 2, 10, angle)
        if u:islocal() then
          u:setskilldatastring("A1MJ", "图标", "war3mapImported\\BTNShiki_D2")
        end
        for index, value in ipairs(ewtl) do
          u:setdata("志贵-额外体力消耗-" .. value.name, 0)
        end
      elseif 100 <= hlz then
        local t = 5 + 0.05 * hlz
        local add = 0.12 * hlz
        ChangeValue(Hero_Tili, sy, add)
        ChangeTimeValue(Hero_Tili_Max, sy, add, t)
        u:setdata("UI-爆气上限", t)
        u:setdata("志贵-爆气时间", t)
        u:setdata("志贵-爆气特效", u:effectadd("zhigui_baoqi1.mdl", "chest", -1))
        u:setdata("志贵-魔术回路值", 0)
        u:setdata("志贵-爆气状态")
        u:shockcamera(200, 0.15)
        u:deldata("志贵-极死七夜已释放")
        u:deldata("志贵-十七分割已释放")
        u:playseensound(zhigui_baoqi)
        if u:getdata("志贵形态") == "七夜" then
          u:playseensound(Nanaya_zhandou12)
        else
          u:playseensound(Shiki_zhandou15)
        end
        for index, value in ipairs(ewtl) do
          u:setdata("志贵-额外体力消耗-" .. value.name, 0)
        end
        Effectcreate("war3mapImported\\zhigui_baoqi3.mdl", x, y, 0, 2, 10, angle)
      else
        u:sendmessage("|cFF0066CC魔术回路不足|r")
      end
    end
  },
  {
    name = "V",
    skill = "A1MN",
    func = function(self, args)
      local u = getunit(args.unit)
      vact(u)
    end
  },
  {
    name = "V2",
    skill = "A1MY",
    func = function(self, args)
      local u = getunit(args.unit)
      u:setdata("志贵-X", args.x)
      u:setdata("志贵-Y", args.y)
      vact(u)
    end
  }
}
return zhiguiskill
