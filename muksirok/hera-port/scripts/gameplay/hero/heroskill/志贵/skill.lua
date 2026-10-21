-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local message = require("jass.message")

local function set(u, skillstr)
  local sh = u:getdata("角色基础伤害")
  local bs = u:getdata("志贵-伤害范围加成")
  local txstr1, txstr2
  if u:getdata("志贵形态") == "七夜" then
    txstr1 = "war3mapImported\\Daji_Hong1.mdl"
    txstr2 = "chest"
  else
    txstr1 = "war3mapImportedhigui_daji5.mdl"
    txstr2 = "origin"
  end
  if u:getdata("志贵形态") == "七夜" or u:hasdata("变异判定-噩梦志贵") then
    sh = sh * (1 + u:getdata("志贵-七夜连击伤害") / 100)
  end
  local x, y = u:getxy()
  local sy = u.ownerid
  local kz = u:getdata("志贵-控制时间")
  u:setdata("七夜连携", "")
  if u:hasdata("志贵-手搓模式") and (skillstr == "EAAV" or skillstr == "AAEV" or skillstr == "EAAV") and u:hasdata("志贵天赋-我的刀法比传言中的要蹩脚") then
    sh = sh * 2
  end
  return sh, bs, txstr1, txstr2, x, y, sy, kz
end

local function extratilixh(u, skillstr)
  local xh = u:getdata("志贵-额外体力消耗-" .. skillstr)
  u:lossstamina(xh)
  local xhadd = 1
  if u:hasdata("志贵天赋-一体同心") then
    xhadd = 0.7
  end
  if u:hasdata("志贵天赋-梦境之外") then
    xhadd = 0.75
  end
  local len = string.len(skillstr)
  if len == 3 then
    xhadd = xhadd * 3
  end
  if len == 4 then
    xhadd = xhadd * 4
  end
  if skillstr == "AAA" then
    xhadd = 0
  end
  u:changedata("志贵-额外体力消耗-" .. skillstr, xhadd)
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

local function zhigui_hlget(u, skillstr)
  local add = 1
  local add2 = 1
  if not u:hasdata("志贵-回路获取-" .. skillstr) then
    u:setdata("志贵-回路获取-" .. skillstr)
    add = u:getdata("志贵-回路获取")
    add2 = u:getdata("志贵-连击伤害获取")
  end
  u:changedata("志贵-魔术回路值", add)
  u:changedata("志贵-七夜连击伤害", add2)
  if string.sub(skillstr, -1) == "V" then
    u:changedata("志贵-连携点数值", 10)
  end
  if string.len(skillstr) >= 4 and string.sub(skillstr, -1) == "E" then
    u:changedata("志贵-连携点数值", 1)
  end
end

local function lianxie(u, skillstr)
  u:setdata("七夜连携", skillstr)
  local t = 0.8
  local t2 = 0.5
  if skillstr == "EEE" then
    t2 = 0.3
  end
  if skillstr == "QW" then
    t = 0.75
    t2 = 0.3
  end
  if u:hasdata("志贵天赋-一体同心") then
    u:setdata("七夜连携时间", t2)
    if u:hasdata("志贵-手搓模式") and (skillstr == "EAA" or skillstr == "AAE" or skillstr == "EAA") then
      u:setdata("志贵-V变化时间", t2)
    end
  else
    u:setdata("七夜连携时间", t * u:getdata("志贵-连锁时间"))
    if u:hasdata("志贵-手搓模式") and (skillstr == "EAA" or skillstr == "AAE" or skillstr == "EAA") then
      u:setdata("志贵-V变化时间", t * u:getdata("志贵-连锁时间"))
    end
  end
end

local function shikianimeact(u, value, speed)
  ac.wait(1, function()
    ResetUnitAnimation(u.handle)
    u:animespeed(speed)
    u:animeact(value)
  end)
end

local function zhiguidamageunit(u, xq, sh, kz, kzlx, txstr1, txstr2, jt, angle, isvest)
  isvest = isvest or false
  xq:effectadd(txstr1, txstr2)
  if kz ~= 0 then
    xq:buffset(u.handle, kz, kzlx)
    if u:hasdata("志贵-七夜小刀") and u:hasdata("志贵-爆气状态") then
      xq:buffset(u.handle, u:getdata("志贵-控制时间"), "沉默")
    end
  end
  if sh ~= 0 then
    DamageUnit({
      bj = "志贵(机体)",
      unit = xq.handle,
      source = u.handle,
      damage = sh,
      level = 1,
      type = "物理",
      isvest = isvest,
      isattack = true,
      isnoarmor = false,
      element = "无"
    })
  end
  if jt then
    unitmove({
      unit = xq.handle,
      time = 0.02,
      distance = jt,
      angle = angle,
      isfly = Nandu_Choose <= 4
    })
  end
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

local function zhiguizantingtime(u, time)
  if u:hasdata("志贵-强断连招开启") then
    u:setdata("志贵连招暂停时间", math.max(u:getdata("志贵连招暂停时间"), time))
  else
    u:buffset(u.handle, time, "暂停")
  end
end

local function zhiguijiaodujiaozheng(u)
  if u:hasdata("志贵-角度校正") and u:islocal() then
    local sy = u.ownerid
    local bb = getunit(Beibao[sy])
    local ddx, ddy = message.mouse()
    bb:select()
    message.order_point(YDWEAbilityId2OrderId("A0BO"), ddx, ddy)
    u:select()
  end
end

local zgskill = {
  QW = function(u)
    local skillstr = "QW"
    local angle = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    u:setdata("志贵-QW阻止Q位移")
    extratilixh(u, skillstr)
    u:buffset(u.handle, 0.4, "绝对闪避")
    u:playsound(zhigui_chongci1)
    ac.wait(1, function()
      ResetUnitAnimation(u.handle)
      u:animespeed(2)
      u:animeact(8)
    end)
    local x2, y2 = PolarXY(x, y, 900, angle)
    local tx = Effectcreate("war3mapImported\\dash sfx.mdl", x2, y2, -1, 2, 0, angle)
    SetEffectActSpeed(tx, 3)
    DestroyEffectLua(tx)
    local tx = Effectcreate("war3mapImported\\bbb.mdl", x2, y2, -1, 2, 0, angle)
    SetEffectActSpeed(tx, 2)
    DestroyEffectLua(tx)
    local g2 = CreateGroupLua()
    unitmove({
      unit = u.handle,
      time = 0.1,
      distance = 1000,
      angle = angle,
      isfly = Nandu_Choose <= 4,
      loops = {
        {
          looptime = 0.02,
          func = function(dx, dy, args)
            for _, xq in ac.selector():in_rangexy(dx, dy, 200 + bs):is_enemy(u.handle):isnotingroup(g2):ipairs() do
              xq = getunit(xq)
              xq:groupadd(g2)
              xq:effectadd(txstr1, txstr2)
              xq:buffset(u.handle, 1 * kz, "僵直")
            end
            dx, dy = PolarXY(dx, dy, 50, angle)
            ForGroupLuaNew(g2, function(xq)
              if not xq:hasdata("免疫击退效果") then
                xq:setxy(dx, dy)
              end
            end)
          end
        }
      },
      endfunc = function(dx, dy)
        zhiguicamset(u, dx, dy)
        dx, dy = PolarXY(dx, dy, 50, angle)
        u:deldata("志贵-QW阻止Q位移")
        ForGroupLuaNew(g2, function(xq)
          if not xq:hasdata("免疫击退效果") then
            xq:setxy(dx, dy)
          end
        end)
        zhiguijiaodujiaozheng(u)
      end
    })
    lianxie(u, skillstr)
  end,
  EE = function(u)
    local skillstr = "EE"
    local angle = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    extratilixh(u, skillstr)
    lianxie(u, skillstr)
    u:playseensound(zhigui_feidao)
    x, y = PolarXY(x, y, -200, angle)
    shikianimeact(u, 2, 3)
    local mz = false
    unifycreate({
      owner = u.handle,
      model = "war3mapImported\\bishou.mdl",
      modelname = "志贵-飞刀",
      modelsize = 1,
      height = 150,
      damage = 1 * sh,
      damagetype = 2,
      x = x,
      y = y,
      time = 0.2,
      speed = 10000,
      volume = 200 + bs,
      angle = angle,
      angleoffset = 0,
      attenua = 1,
      attenuacount = 999,
      life = 10,
      isbullet = false,
      isvest = false,
      isignorearmor = false,
      startfunc = function(mj)
        mj:setdata("循环计数", 0)
      end,
      loopfunc = function(mj)
        mj:changedata("循环计数", UnifyDT)
        if mj:getdata("循环计数") >= 0.03 then
          mj:setdata("循环计数", 0)
        end
      end,
      hitfunc = function(mj, damage)
        return damage
      end,
      hitbeforefunc = function(mj, xq, damage2)
      end,
      hitafterfunc = function(mj, xq, damage2)
        mz = true
        u:shockcamera(10)
        zhiguidamageunit(u, xq, 0, kz, "僵直", txstr1, txstr2, 50, mj:getface())
      end,
      endfunc = function(mj)
        if mz then
          zhigui_combo(u)
          zhigui_hlget(u, skillstr)
        end
        u:shockcamerastop()
      end
    })
  end,
  AE = function(u)
    local skillstr = "AE"
    local angle = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    extratilixh(u, skillstr)
    lianxie(u, skillstr)
    local mz = false
    shikianimeact(u, 1, 2)
    u:playseensound(zhigui_zhanji1)
    if u:getdata("志贵形态") == "七夜" then
      u:playseensound(Nanaya_zhandou23)
    else
      u:playseensound(Shiki_zhandou18)
    end
    u:shockcamera(50, 0.15)
    ac.wait(100, function()
      local x2, y2 = PolarXY(x, y, 100, angle)
      Effectcreate("war3mapImported\\File00006330.mdl", x2, y2, 0, 3, 120, angle, -20)
      Effectcreate("war3mapImported\\File00006330.mdl", x2, y2, 0, 3, 120, angle, 10, 0, 2)
      for _, xq in ac.selector():in_rangexy(x2, y2, 300 + bs):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        mz = true
        zhiguidamageunit(u, xq, 1.25 * sh, kz, "僵直", txstr1, txstr2, 300, angle)
      end
      if mz then
        u:shockcamera(10, 0.15)
        zhigui_combo(u)
        zhigui_hlget(u, skillstr)
      end
    end)
  end,
  EA = function(u)
    local skillstr = "EA"
    local angle = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    extratilixh(u, skillstr)
    lianxie(u, skillstr)
    local mz = false
    u:playseensound(zhigui_chongci1)
    if u:getdata("志贵形态") == "七夜" then
      shikianimeact(u, 27, 2)
      u:playseensound(Nanaya_zhandou22)
    else
      shikianimeact(u, 14, 2)
      u:playseensound(Shiki_zhandou1)
    end
    local x2, y2 = PolarXY(x, y, 900, angle)
    Effectcreate("war3mapImported\\bbb.mdl", x, y, 0, 2, 0, angle, 0, 0, 2)
    local mb
    for _, xq in ac.selector():in_rangexy(x, y, 200 + bs):is_enemy(u.handle):ipairs() do
      mz = true
      mb = getunit(xq)
      break
    end
    unitmove({
      unit = u.handle,
      time = 0.02,
      distance = 1000,
      angle = angle,
      isfly = Nandu_Choose <= 4,
      loops = {
        {
          looptime = 0.005,
          func = function(dx, dy, args)
            for _, xq in ac.selector():in_rangexy(dx, dy, 200 + bs):is_enemy(u.handle):ipairs() do
              mz = true
              args.stop = true
              mb = getunit(xq)
              break
            end
          end
        }
      },
      endfunc = function(dx, dy, args)
        zhiguicamset(u, dx, dy)
        if mz then
          x, y = mb:getxy()
          u:playseensound(zhigui_daji4)
          u:playseensound(zhigui_zhanji1)
          Effectcreate("war3mapImported\\qiye_chongji1.mdl", x, y, 0, 2, 0, angle)
          Effectcreate("war3mapImported\\chongci_Bo.mdl", x, y, 0, 2, 0, angle)
          u:shockcamera(70, 0.15)
          zhigui_combo(u)
          zhigui_hlget(u, skillstr)
          lianxie(u, skillstr)
          for _, xq in ac.selector():in_rangexy(x, y, 300 + bs):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            zhiguidamageunit(u, xq, 1 * sh, kz, "僵直", txstr1, txstr2, 0)
            unitmove({
              unit = xq.handle,
              time = 0.1,
              distance = 1000,
              angle = angle,
              isfly = Nandu_Choose <= 4
            })
          end
        else
          u:setdata("七夜连携", "")
        end
        zhiguijiaodujiaozheng(u)
      end,
      dt = 0.001
    })
  end,
  AA = function(u)
    local skillstr = "AA"
    local angle = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    extratilixh(u, skillstr)
    lianxie(u, skillstr)
    shikianimeact(u, 2, 2)
    u:playseensound(zhigui_zhanji1)
    if u:getdata("志贵形态") == "七夜" then
      u:playseensound(Nanaya_zhandou24)
    else
      u:playseensound(Shiki_zhandou19)
    end
    ac.wait(100, function()
      x, y = u:getxy()
      x, y = PolarXY(x, y, 100, angle)
      if u:hasdata("志贵-镜头全锁定") then
        zhiguicamset(u, x, y)
      end
      u:setxy(x, y)
      local x2, y2 = PolarXY(x, y, 100, angle)
      local mz = false
      Effectcreate("war3mapImported\\File00006330.mdl", x2, y2, 0, 2, 120, angle, 200, 0, 2.5)
      for _, xq in ac.selector():in_rangexy(x2, y2, 300 + bs):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        zhiguidamageunit(u, xq, 1.25 * sh, kz, "僵直", txstr1, txstr2, 50, angle)
      end
      if mz then
        u:shockcamera(10, 0.15)
        zhigui_combo(u)
        zhigui_hlget(u, skillstr)
      end
    end)
  end,
  EAE = function(u)
    local skillstr = "EAE"
    local angle = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    extratilixh(u, skillstr)
    local mz = false
    shikianimeact(u, 14, 1)
    u:playseensound(zhigui_chongci1)
    u:playseensound(Nanaya_zhandou5)
    local x2, y2 = PolarXY(x, y, 900, angle)
    Effectcreate("war3mapImported\\bbb.mdl", x, y, 0, 2, 0, angle, 0, 0, 2)
    local mb
    unitmove({
      unit = u.handle,
      time = 0.05,
      distance = 1000,
      angle = angle,
      isfly = true,
      loops = {
        {
          looptime = 0.01,
          func = function(dx, dy, args)
            for _, xq in ac.selector():in_rangexy(dx, dy, 225 + bs):is_enemy(u.handle):ipairs() do
              mz = true
              args.stop = true
              mb = getunit(xq)
              break
            end
          end
        }
      },
      endfunc = function(dx, dy, args)
        zhiguicamset(u, dx, dy)
        if mz then
          x, y = mb:getxy()
          u:playseensound(zhigui_daji4)
          u:playseensound(zhigui_zhanji1)
          Effectcreate("war3mapImported\\qiye_zhanji7.mdl", x, y, 0, 5, 200, angle, 45)
          Effectcreate("war3mapImported\\qiye_zhanji7.mdl", x, y, 0, 5, 200, angle, 135)
          u:shockcamera(70, 0.15)
          zhigui_combo(u)
          zhigui_hlget(u, skillstr)
          lianxie(u, skillstr)
          for _, xq in ac.selector():in_rangexy(x, y, 300 + bs):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            zhiguidamageunit(u, xq, 1.5 * sh, kz, "僵直", txstr1, txstr2, 0)
            unitjump({
              unit = xq.handle,
              time = 0.1,
              distance = 200,
              height = 50,
              angle = angle,
              isfly = Nandu_Choose <= 4
            })
          end
        else
          lianxie(u, skillstr)
        end
        zhiguijiaodujiaozheng(u)
      end
    })
  end,
  EEE = function(u)
    local skillstr = "EEE"
    local angle = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    extratilixh(u, skillstr)
    zhiguicamlock(u)
    shikianimeact(u, 10, 3)
    u:shockcamera(50, 0.15)
    u:playseensound(zhigui_chongci1)
    u:playseensound(zhigui_zhanji1)
    u:playseensound(Nanaya_zhandou11)
    local x2, y2 = PolarXY(x, y, 900, angle)
    Effectcreate("war3mapImported\\dash sfx.mdl", x2, y2, 0, 2, 0, angle, 0, 0, 3)
    Effectcreate("war3mapImported\\chongci_Bo.mdl", x2, y2, 0, 2, 0, angle, 0, 0, 3)
    local x3, y3 = PolarXY(x, y, 400, angle)
    Effectcreate("war3mapImported\\File00000650.mdl", x3, y3, 0, 8, 200, angle, 0, 0, 2)
    Effectcreate("war3mapImported\\Daji_Hong1.mdl", x3, y3, 0, 40, 200, angle, 0, 0, 2)
    ac.wait(300, function()
      Effectcreate("war3mapImported\\Daoguang_1.mdl", x3, y3, 0, 1.7, 200, angle, 0, 0, 7)
    end)
    local mz = false
    local mz2 = false
    local g2 = CreateGroupLua()
    unitmove({
      unit = u.handle,
      time = 0.16,
      distance = 1600,
      angle = angle,
      isfly = true,
      loops = {
        {
          looptime = 0.02,
          func = function(dx, dy, args)
            if u:hasdata("志贵-强断连招") then
              args.stop = true
              return
            end
            mz2 = false
            for _, xq in ac.selector():in_rangexy(dx, dy, 200 + bs):is_enemy(u.handle):isnotingroup(g2):ipairs() do
              mz = true
              mz2 = true
              xq = getunit(xq)
              xq:groupadd(g2)
              zhiguidamageunit(u, xq, 1.25 * sh, kz, "僵直", txstr1, txstr2, 200, angle)
            end
            if mz2 then
              zhigui_combo(u)
            end
          end
        }
      },
      endfunc = function()
        zhiguicamunlock(u)
        lianxie(u, skillstr)
        if mz then
          zhigui_hlget(u, skillstr)
        end
        zhiguijiaodujiaozheng(u)
      end
    })
  end,
  EEA = function(u)
    local skillstr = "EEA"
    local angle = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    extratilixh(u, skillstr)
    zhiguicamlock(u)
    local mz = false
    shikianimeact(u, 2, 2)
    u:playseensound(Shiki_zhandou21)
    local x2, y2 = PolarXY(x, y, 900, angle)
    Effectcreate("war3mapImported\\bbb.mdl", x, y, 0, 2, 0, angle, 0, 0, 2)
    local mb
    unitmove({
      unit = u.handle,
      time = 0.2,
      distance = 2000,
      angle = angle,
      isfly = Nandu_Choose <= 4,
      loops = {
        {
          looptime = 0.01,
          func = function(dx, dy, args)
            if u:hasdata("志贵-强断连招") then
              args.stop = true
              return
            end
            for _, xq in ac.selector():in_rangexy(dx, dy, 200 + bs):is_enemy(u.handle):ipairs() do
              mz = true
              args.stop = true
              mb = getunit(xq)
              break
            end
          end
        }
      },
      endfunc = function(dx, dy, args)
        if mz then
          x, y = mb:getxy()
          u:playseensound(zhigui_zhanji1)
          local x1, y1 = PolarXY(x, y, 200, angle)
          Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x1, y1, 0, 4, 200, angle, 20, 0, GetRandomReal(1, 2))
          Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x1, y1, 0, 4, 200, angle, -20, 0, GetRandomReal(1, 2))
          u:shockcamera(70, 0.15)
          zhigui_combo(u)
          zhigui_hlget(u, skillstr)
          lianxie(u, skillstr)
          for _, xq in ac.selector():in_rangexy(x, y, 300 + bs):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            zhiguidamageunit(u, xq, 1.5 * sh, kz, "僵直", txstr1, txstr2, 200, angle)
          end
          x, y = mb:getxy()
          x1, y1 = PolarXY(x, y, 300, angle)
          u:setxy(x1, y1)
          zhiguicamunlock(u)
        else
          u:setdata("七夜连携", "")
        end
        zhiguijiaodujiaozheng(u)
      end
    })
  end,
  EAA = function(u)
    local skillstr = "EAA"
    local angle = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    extratilixh(u, skillstr)
    shikianimeact(u, 2, 2)
    u:playseensound(Shiki_zhandou12)
    ac.timer(100, 6, function()
      u:playseensound(zhigui_feidao)
      u:playseensound(zhigui_zhanji3)
      SetSoundPlayPosition(zhigui_zhanji3, 30)
    end)
    zhiguizantingtime(u, 0.5)
    local t2 = 0.1
    if u:hasdata("志贵天赋-闪走名月") then
      t2 = 0.15
    end
    u:buffset(u.handle, 0.5 + t2, "无敌")
    local cs1 = 0
    local cs2 = 0
    ac.loop(100, function(timer)
      if u:hasdata("志贵-强断连招") then
        timer:remove()
        return
      end
      cs1 = cs1 + 1
      cs2 = cs2 + 1
      ac.wait(1, function()
        ResetUnitAnimation(u.handle)
        if 1 < cs2 then
          cs2 = 0
          u:animespeed(3)
          u:animeact(2)
        else
          u:animespeed(2)
          u:animeact(1)
        end
      end)
      local x1, y1 = PolarXY(x, y, -200, angle)
      local mz = false
      unifycreate({
        owner = u.handle,
        model = "war3mapImported\\bishou.mdl",
        modelname = "志贵-飞刀",
        modelsize = 1,
        height = 150,
        damage = 0.5 * sh,
        damagetype = 2,
        x = x,
        y = y,
        time = 0.2,
        speed = 10000,
        volume = 200 + bs,
        angle = angle,
        angleoffset = 0,
        attenua = 1,
        attenuacount = 999,
        life = 10,
        isbullet = false,
        isvest = false,
        isignorearmor = false,
        startfunc = function(mj)
          mj:setdata("循环计数", 0)
        end,
        loopfunc = function(mj)
          mj:changedata("循环计数", UnifyDT)
          if mj:getdata("循环计数") >= 0.03 then
            mj:setdata("循环计数", 0)
          end
        end,
        hitfunc = function(mj, damage)
          return damage
        end,
        hitbeforefunc = function(mj, xq, damage2)
        end,
        hitafterfunc = function(mj, xq, damage2)
          mz = true
          u:shockcamera(10)
          zhiguidamageunit(u, xq, 0, kz, "僵直", txstr1, txstr2, 50, mj:getface())
        end,
        endfunc = function(mj)
          if mz then
            zhigui_combo(u)
            zhigui_hlget(u, skillstr)
          end
          u:shockcamerastop()
        end
      })
      if cs1 == 5 then
        lianxie(u, skillstr)
        timer:remove()
      end
    end)
  end,
  AEE = function(u)
    local skillstr = "AEE"
    local angle = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    extratilixh(u, skillstr)
    zhiguicamlock(u)
    u:playseensound(Nanaya_zhandou2)
    zhiguizantingtime(u, 0.1)
    local t2 = 0.1
    if u:hasdata("志贵天赋-闪走名月") then
      t2 = 0.15
    end
    u:buffset(u.handle, 0.55 + t2, "无敌")
    shikianimeact(u, 6, 1)
    local mz = false
    local mz2 = false
    local g2 = CreateGroupLua()
    unitmove({
      unit = u.handle,
      time = 0.6,
      distance = 1000,
      angle = angle,
      loops = {
        {
          looptime = 0.03,
          func = function(dx, dy, args)
            if u:hasdata("志贵-强断连招") then
              args.stop = true
              return
            end
            local x2, y2 = PolarXY(dx, dy, 50, angle)
            if GetRandom100(50) then
              Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x2, y2, 0, GetRandomReal(2, 3), GetRandomReal(100, 300), angle + GetRandomReal(-80, 80), GetRandomReal(-30, 30), 0, GetRandomReal(2, 3))
            else
              Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x2, y2, 0, GetRandomReal(2, 3), GetRandomReal(100, 300), angle + GetRandomReal(-80, 80), GetRandomReal(170, 200), 0, GetRandomReal(2, 3))
            end
          end
        },
        {
          looptime = 0.06,
          func = function(dx, dy, args)
            if u:hasdata("志贵-强断连招") then
              args.stop = true
              return
            end
            zhiguizantingtime(u, 0.07)
            local x2, y2 = PolarXY(dx, dy, 50, angle)
            mz2 = false
            for _, xq in ac.selector():in_rangexy(x2, y2, 300 + bs):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              mz2 = true
              mz = true
              if not xq:isingroup(g2) then
                xq:groupadd(g2)
                zhiguidamageunit(u, xq, 0.25 * sh, kz, "僵直", txstr1, txstr2, 150, angle, false)
              else
                zhiguidamageunit(u, xq, 0.25 * sh, kz, "僵直", txstr1, txstr2, 150, angle, true)
              end
            end
            if mz2 then
              zhigui_combo(u)
              u:shockcamera(10)
            end
            u:playseensound(zhigui_zhanji3)
            SetSoundPlayPosition(zhigui_zhanji3, 30)
          end
        }
      },
      endfunc = function()
        ForGroupLuaNew(g2, function(xq)
          zhiguidamageunit(u, xq, 0, kz, "僵直", txstr1, txstr2, 250, angle, true)
        end)
        zhiguicamunlock(u)
        u:shockcamerastop()
        ResetUnitAnimation(u.handle)
        lianxie(u, skillstr)
        if mz then
          zhigui_hlget(u, skillstr)
        end
        zhiguijiaodujiaozheng(u)
      end
    })
  end,
  AEA = function(u)
    local skillstr = "AEA"
    local angle = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    extratilixh(u, skillstr)
    zhiguicamlock(u)
    u:playseensound(zhigui_bisha)
    zhiguizantingtime(u, 0.6)
    local t2 = 0.1
    if u:hasdata("志贵天赋-闪走名月") then
      t2 = 0.15
    end
    u:buffset(u.handle, 0.6 + t2, "无敌")
    local x1, y1 = PolarXY(x, y, 500, angle)
    local x2, y2 = PolarXY(x, y, 250, angle)
    local mj = u:createunit("u0EA", x1, y1, angle + 180)
    shikianimeact(u, 10, 1)
    shikianimeact(mj, 10, 1)
    ac.wait(300, function()
      shikianimeact(u, 16, 1)
      shikianimeact(mj, 16, 1)
    end)
    ac.wait(600, function()
      shikianimeact(u, 17, 1)
      shikianimeact(mj, 17, 1)
    end)
    ac.wait(300, function()
      local mz = false
      local mz2 = false
      u:playseensound(Nanaya_zhandou27)
      local g2 = CreateGroupLua()
      local cs = 0
      ac.loop(20, function(timer)
        if u:hasdata("志贵-强断连招") then
          ForGroupLuaNew(g2, function(xq)
            xq:setflyheight(0)
          end)
          u:shockcamerastop()
          mj:remove()
          timer:remove()
          return
        end
        cs = cs + 1
        x, y = PolarXY(x, y, 50, angle)
        u:setxy(x, y)
        x1, y1 = PolarXY(x1, y1, -50, angle)
        mj:setxy(x1, y1)
        mj:setcolor(255, 255, 255, 25.5 * cs)
        if Group_Counts(g2) > 0 then
          u:shockcamera(10)
          Effectcreate("war3mapImported\\Daoguang_1.mdl", x2, y2, 0, GetRandomReal(0.5, 1.5), 50 * cs, GetRandomReal(0, 360), GetRandomReal(0, 360), 0, GetRandomReal(1, 2))
          local x3, y3 = PolarXY(x2, y2, GetRandomReal(-200, 200), GetRandomReal(0, 360))
          Effectcreate("war3mapImported\\qiye_zhanji4.mdl", x3, y3, 0, GetRandomReal(0.5, 1), 100 + 10 * cs, GetRandomReal(0, 360), GetRandomReal(0, 360), 0, 1.2)
        end
        if 10 <= cs then
          ac.wait(100, function()
            ForGroupLuaNew(g2, function(xq)
              local gd = GetUnitFlyHeight(xq.handle)
              ac.loop(20, function(timer2)
                xq:setflyheight(gd)
                gd = gd - 50
                if gd <= 0 then
                  xq:setflyheight(0)
                  timer2:remove()
                end
              end)
            end)
          end)
          u:shockcamerastop()
          mj:remove()
          if mz then
            zhigui_hlget(u, skillstr)
          end
          zhiguicamunlock(u)
          lianxie(u, skillstr)
          zhiguijiaodujiaozheng(u)
          timer:remove()
        end
      end)
      local cs2 = 0
      ac.loop(65, function(timer)
        if u:hasdata("志贵-强断连招") then
          timer:remove()
          return
        end
        cs2 = cs2 + 1
        mz2 = false
        for _, xq in ac.selector():in_rangexy(x2, y2, 300 + bs):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          mz2 = true
          mz = true
          xq:setflyheight(GetUnitFlyHeight(xq.handle) + 100)
          if not xq:isingroup(g2) then
            xq:groupadd(g2)
            zhiguidamageunit(u, xq, 0.4 * sh, kz, "僵直", txstr1, txstr2, 0, angle, false)
            xq:buffset(u.handle, kz, "沉默")
          else
            zhiguidamageunit(u, xq, 0.4 * sh, kz, "僵直", txstr1, txstr2, 0, angle, true)
          end
        end
        if mz2 then
          zhigui_combo(u)
        end
        u:playseensound(zhigui_zhanji3)
        SetSoundPlayPosition(zhigui_zhanji3, 30)
        if cs2 == 6 then
          timer:remove()
        end
      end)
    end)
  end,
  AAA = function(u)
    local skillstr = "AAA"
    local angle = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    extratilixh(u, skillstr)
    lianxie(u, skillstr)
    u:playseensound(zhigui_zhanji1)
    if u:getdata("志贵形态") == "七夜" then
      u:playseensound(Nanaya_zhandou15)
    else
      u:playseensound(Shiki_zhandou20)
    end
    u:shockcamera(50, 0.15)
    shikianimeact(u, 2, 2)
    ac.wait(100, function()
      x, y = u:getxy()
      x, y = PolarXY(x, y, 100, angle)
      if u:hasdata("志贵-镜头全锁定") then
        zhiguicamset(u, x, y)
      end
      u:setxy(x, y)
      local x2, y2 = PolarXY(x, y, 100, angle)
      Effectcreate("war3mapImported\\File00006330.mdl", x2, y2, 0, 3, 120, angle, 200, 0, 1)
      Effectcreate("war3mapImported\\File00006330.mdl", x2, y2, 0, 3, 120, angle, 230, 0, 2.5)
      local mz = false
      for _, xq in ac.selector():in_rangexy(x2, y2, 300 + bs):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        zhiguidamageunit(u, xq, 1.5 * sh, kz, "僵直", txstr1, txstr2, 200, angle)
      end
      if mz then
        u:shockcamera(10, 0.15)
        zhigui_combo(u)
        zhigui_hlget(u, skillstr)
      end
    end)
  end,
  AAE = function(u)
    local skillstr = "AAE"
    local angle = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    extratilixh(u, skillstr)
    zhiguicamlock(u)
    u:playseensound(Shiki_zhandou2)
    zhiguizantingtime(u, 0.7)
    local t2 = 0.1
    if u:hasdata("志贵天赋-闪走名月") then
      t2 = 0.15
    end
    u:buffset(u.handle, 0.7 + t2, "无敌")
    shikianimeact(u, 6, 1)
    local mz = false
    local mz2 = false
    local g2 = CreateGroupLua()
    unitmove({
      unit = u.handle,
      time = 0.75,
      distance = 250,
      angle = angle,
      isfly = true,
      loops = {
        {
          looptime = 0.03,
          func = function(dx, dy, args)
            if u:hasdata("志贵-强断连招") then
              args.stop = true
              return
            end
            local x2, y2 = PolarXY(dx, dy, 100, angle)
            if GetRandom100(50) then
              Effectcreate("war3mapImported\\qiye_zhanji1.mdl", x2, y2, 0, GetRandomReal(1, 2.5), 150, angle + GetRandomReal(-20, 20), GetRandomReal(0, 360), GetRandomReal(-20, 20), GetRandomReal(1, 2))
            else
              Effectcreate("war3mapImported\\qiye_zhanji2.mdl", x2, y2, 0, GetRandomReal(3, 6), 150, angle + GetRandomReal(-20, 20), GetRandomReal(0, 360), GetRandomReal(-20, 20), GetRandomReal(1, 2))
            end
          end
        },
        {
          looptime = 0.062,
          func = function(dx, dy, args)
            if u:hasdata("志贵-强断连招") then
              args.stop = true
              return
            end
            local x2, y2 = PolarXY(dx, dy, 100, angle)
            mz2 = false
            for _, xq in ac.selector():in_rangexy(x2, y2, 300 + bs):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              mz2 = true
              mz = true
              if not xq:isingroup(g2) then
                xq:groupadd(g2)
                zhiguidamageunit(u, xq, 0.2 * sh, kz, "僵直", txstr1, txstr2, 30, angle, false)
              else
                zhiguidamageunit(u, xq, 0.2 * sh, kz, "僵直", txstr1, txstr2, 30, angle, true)
              end
            end
            if mz2 then
              zhigui_combo(u)
              u:shockcamera(10)
            end
            u:playseensound(zhigui_zhanji3)
            SetSoundPlayPosition(zhigui_zhanji3, 30)
          end
        }
      },
      endfunc = function()
        ForGroupLuaNew(g2, function(xq)
          zhiguidamageunit(u, xq, 0, kz, "僵直", txstr1, txstr2, 250, angle, true)
        end)
        zhiguicamunlock(u)
        u:shockcamerastop()
        ResetUnitAnimation(u.handle)
        lianxie(u, skillstr)
        if mz then
          zhigui_hlget(u, skillstr)
        end
        zhiguijiaodujiaozheng(u)
      end
    })
  end,
  QWE = function(u)
    local skillstr = "QWE"
    local angle = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    extratilixh(u, skillstr)
    u:shockcamera(50, 0.15)
    shikianimeact(u, 1, 2)
    u:playseensound(zhigui_zhanji2)
    local x2, y2 = PolarXY(x, y, 100, angle)
    local tx1 = Effectcreate("war3mapImported\\Zhanji_Chongci.mdl", x2, y2, 0, 3, 0, angle + 180)
    local tx2 = Effectcreate("war3mapImported\\Zhanji_Chongci.mdl", x2, y2, 0, 3, 400, angle + 180, 180)
    local mz = false
    local mz2 = false
    local g2 = CreateGroupLua()
    for _, xq in ac.selector():in_rangexy(x2, y2, 250 + bs):is_enemy(u.handle):isnotingroup(g2):ipairs() do
      xq = getunit(xq)
      mz = true
      mz2 = true
      xq:groupadd(g2)
      zhiguidamageunit(u, xq, 1 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 0, angle, false)
    end
    ac.timer(25, 4, function()
      x, y = u:getxy()
      x2, y2 = PolarXY(x, y, 100, angle)
      SetEffectXY(tx1, x2, y2)
      SetEffectXY(tx2, x2, y2)
      for _, xq in ac.selector():in_rangexy(x2, y2, 250 + bs):is_enemy(u.handle):isnotingroup(g2):ipairs() do
        xq = getunit(xq)
        mz = true
        mz2 = true
        xq:groupadd(g2)
        zhiguidamageunit(u, xq, 1 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 0, angle, false)
      end
    end)
    ac.wait(100, function()
      if mz2 then
        zhigui_combo(u)
      end
      if Group_Counts(g2) > 0 then
        zhiguicamlock(u)
        u:playseensound(zhigui_zhanji1)
        if u:getdata("志贵形态") == "七夜" then
          u:playseensound(Nanaya_zhandou3)
        else
          u:playseensound(Shiki_zhandou22)
          shikianimeact(u, 11, 2)
        end
        zhiguizantingtime(u, 1.25)
        u:buffset(u.handle, 1.6, "无敌")
        u:setdata("七夜连携时间", 1.25)
        local dx, dy = PolarXY(x, y, 300, angle)
        ForGroupLuaNew(g2, function(xq)
          if not xq:hasdata("免疫击退效果") then
            xq:setxy(dx, dy)
          end
        end)
        local timer1, timer2, timer3
        local cs = 0
        ac.loop(50, function(timer)
          cs = cs + 1
          if u:hasdata("志贵-强断连招") then
            timer1:remove()
            timer2:remove()
            timer3:remove()
            ForGroupLuaNew(g2, function(xq)
              xq:setflyheight(0)
            end)
            timer:remove()
          end
          if cs == 25 then
            timer:remove()
          end
        end)
        timer1 = ac.wait(500, function()
          x, y = u:getxy()
          u:playseensound(zhigui_daji1)
          if u:getdata("志贵形态") == "七夜" then
            shikianimeact(u, 27, 1)
          end
          u:shockcamera(50, 0.2)
          for i = 1, 3 do
            dx, dy = PolarXY(x, y, 400, angle)
            Effectcreate("war3mapImported\\bbb.mdl", dx, dy, 0, 3, 300, angle, 0, 90, 2)
          end
          x, y = PolarXY(x, y, 400, angle)
          u:setxy(x, y)
          x, y = u:getxy()
          mz2 = false
          ForGroupLuaNew(g2, function(xq)
            mz2 = true
            x2, y2 = PolarXY(x, y, 200, angle)
            if not xq:hasdata("免疫击退效果") then
              xq:setxy(x2, y2)
            end
            zhiguidamageunit(u, xq, 1 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 0, angle, false)
          end)
          if mz2 then
            zhigui_combo(u)
          end
        end)
        timer2 = ac.wait(750, function()
          u:playseensound(zhigui_daji2)
          if u:getdata("志贵形态") == "七夜" then
            shikianimeact(u, 19, 1)
          end
          u:shockcamera(20, 0.2)
          x, y = u:getxy()
          x, y = PolarXY(x, y, 100, angle)
          u:setxy(x, y)
          x, y = u:getxy()
          u:setflyheight(400)
          mz2 = false
          ForGroupLuaNew(g2, function(xq)
            mz2 = true
            x2, y2 = PolarXY(x, y, 200, angle)
            if not xq:hasdata("免疫击退效果") then
              xq:setxy(x2, y2)
            end
            xq:setflyheight(500)
            zhiguidamageunit(u, xq, 1 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 0, angle, false)
          end)
          if mz2 then
            zhigui_combo(u)
          end
        end)
        timer3 = ac.wait(1250, function()
          u:playseensound(zhigui_daji3)
          if u:getdata("志贵形态") == "七夜" then
            u:playseensound(Nanaya_zhandou15)
            shikianimeact(u, 17, 1)
          else
            u:playseensound(Shiki_zhandou23)
          end
          ac.wait(50, function()
            local gd = 500
            ac.loop(20, function(timer)
              u:setflyheight(gd)
              gd = gd - 150
              if gd <= 0 then
                u:setflyheight(0)
                u:shockcamera(50, 0.3)
                timer:remove()
              end
            end)
          end)
          u:playseensound(zhigui_luodi2)
          x, y = u:getxy()
          x2, y2 = PolarXY(x, y, 200, angle)
          Effectcreate("war3mapImported\\xushizhendi.mdl", x2, y2, 0, 2, 500, angle + 180, 0, 45, 2)
          x2, y2 = PolarXY(x, y, 800, angle)
          ForGroupLuaNew(g2, function(xq)
            if not xq:hasdata("免疫击退效果") then
              xq:setxy(x2, y2)
            end
            xq:setflyheight(0)
          end)
          Effectcreate("war3mapImported\\bbb.mdl", x2, y2, 0, 2, 0, angle, 0, 0, 1.5)
          mz2 = false
          for _, xq in ac.selector():in_rangexy(x2, y2, 250 + bs):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            zhiguidamageunit(u, xq, 1 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 0, angle, false)
          end
          if mz2 then
            zhigui_combo(u)
          end
          lianxie(u, skillstr)
          if mz then
            zhigui_hlget(u, skillstr)
          end
          zhiguicamunlock(u)
          zhiguijiaodujiaozheng(u)
        end)
      end
    end)
  end,
  QWEA = function(u)
    local skillstr = "QWEA"
    local angle = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    extratilixh(u, skillstr)
    u:playseensound(zhigui_zhanji1)
    u:playseensound(Nanaya_zhandou1)
    zhiguizantingtime(u, 0.4)
    local t2 = 0.1
    if u:hasdata("志贵天赋-闪走名月") then
      t2 = 0.15
    end
    zhiguicamlock(u)
    u:buffset(u.handle, 0.4 + t2, "无敌")
    u:shockcamera(50, 0.15)
    shikianimeact(u, 18, 1.5)
    local x2, y2 = PolarXY(x, y, 400, angle)
    Effectcreate("war3mapImported\\Daoguang_1.mdl", x2, y2, 0, 2, 400, angle, 0, 45, 2)
    x2, y2 = PolarXY(x, y, 800, angle)
    Effectcreate("war3mapImported\\Daoguang_1.mdl", x2, y2, 0, 2, 400, angle + 30, 0, 45, 2)
    Effectcreate("war3mapImported\\Daoguang_1.mdl", x2, y2, 0, 2, 400, angle - 30, 0, 45, 2)
    local gd = 700
    local mz = false
    local mz2 = false
    ac.loop(20, function(timer)
      if u:hasdata("志贵-强断连招") then
        timer:remove()
        return
      end
      u:setflyheight(gd)
      gd = gd - 150
      if gd <= 150 then
        u:playseensound(zhigui_daji2)
        u:setflyheight(0)
        u:shockcamera(50, 0.15)
        x, y = u:getxy()
        x2, y2 = PolarXY(x, y, 800, angle)
        u:setxy(x2, y2)
        Effectcreate("war3mapImported\\bbb.mdl", x2, y2, 0, 2, 0, angle, 0, 0, 1.5)
        Effectcreate("war3mapImported\\qiye_xialuo1.mdl", x2, y2, 0, 3, 0, angle, 0, 0, 2)
        Effectcreate("war3mapImported\\Daji_Kuoshan2.mdl", x2, y2, 0, 2, 0, GetRandomReal(0, 360), 0, 0, 3)
        mz2 = false
        for _, xq in ac.selector():in_rangexy(x2, y2, 200 + bs):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          mz = true
          mz2 = true
          zhiguidamageunit(u, xq, 1 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 0, angle, false)
        end
        if mz2 then
          zhigui_combo(u)
        end
        ac.wait(200, function()
          if u:hasdata("志贵-强断连招") then
            return
          end
          u:playseensound(zhigui_zhanji1)
          u:playseensound(Nanaya_zhandou8)
          x, y = u:getxy()
          mz2 = false
          for _, xq in ac.selector():in_rangexy(x, y, 200 + bs):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            mz = true
            mz2 = true
            zhiguidamageunit(u, xq, 1 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 400, angle + 180, false)
          end
          if mz2 then
            zhigui_combo(u)
          end
          Effectcreate("war3mapImported\\File00000650.mdl", x2, y2, 0, 8, 200, angle + 180, 0, 0, 2)
          x2, y2 = PolarXY(x, y, -400, angle + 90)
          Effectcreate("war3mapImported\\File00000650.mdl", x2, y2, 0, 4, 200, angle + 160, 0, 0, 2)
          x2, y2 = PolarXY(x, y, -400, angle - 90)
          Effectcreate("war3mapImported\\File00000650.mdl", x2, y2, 0, 4, 200, angle + 200, 0, 0, 2)
          x2, y2 = PolarXY(x, y, -800, angle)
          u:setxy(x2, y2)
          u:setface(u:getface() + 180)
          u:shockcamera(50, 0.3)
          shikianimeact(u, 2, 1.5)
          local cs = 0
          ac.loop(20, function(timer2)
            if u:hasdata("志贵-强断连招") then
              timer2:remove()
              return
            end
            cs = cs + 1
            local jd
            if cs <= 2 then
              jd = angle - 90
            else
              jd = angle + 90
            end
            local dx, dy = u:getxy()
            Effectcreate("war3mapImported\\File00006330.mdl", dx, dy, 0, GetRandomReal(5, 6), 200, jd, GetRandomReal(-45, 45), 0, GetRandomReal(1, 2))
            if cs == 4 then
              timer2:remove()
            end
          end)
          lianxie(u, skillstr)
          if mz then
            zhigui_hlget(u, skillstr)
          end
          zhiguicamunlock(u)
          zhiguijiaodujiaozheng(u)
        end)
        timer:remove()
      end
    end)
  end,
  QWEE = function(u)
    local skillstr = "QWEE"
    local angle = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    extratilixh(u, skillstr)
    zhiguizantingtime(u, 0.4)
    local t2 = 0.1
    if u:hasdata("志贵天赋-闪走名月") then
      t2 = 0.15
    end
    u:buffset(u.handle, 0.4 + t2, "无敌")
    u:shockcamera(50, 0.15)
    u:playseensound(Shiki_zhandou18)
    shikianimeact(u, 18, 1.5)
    local gd = 700
    local mz = false
    local mz2 = false
    ac.loop(20, function(timer)
      if u:hasdata("志贵-强断连招") then
        timer:remove()
        return
      end
      u:setflyheight(gd)
      gd = gd - 150
      if gd <= 150 then
        u:playseensound(zhigui_daji2)
        u:setflyheight(0)
        u:shockcamera(50, 0.15)
        x, y = u:getxy()
        Effectcreate("war3mapImported\\bbb.mdl", x, y, 0, 2, 0, angle, 0, 0, 1.5)
        Effectcreate("war3mapImported\\qiye_xialuo1.mdl", x, y, 0, 3, 0, angle, 0, 0, 2)
        mz2 = false
        for _, xq in ac.selector():in_rangexy(x, y, 400 + bs):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          mz = true
          mz2 = true
          zhiguidamageunit(u, xq, 1.25 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 0, angle, false)
        end
        if mz2 then
          zhigui_combo(u)
        end
        ac.wait(200, function()
          if u:hasdata("志贵-强断连招") then
            return
          end
          u:playseensound(zhigui_zhanji1)
          u:playseensound(zhigui_bisha3)
          u:playseensound(Nanaya_zhandou8)
          u:shockcamera(50, 0.15)
          shikianimeact(u, 2, 1.5)
          local cs = 0
          ac.loop(20, function(timer2)
            if u:hasdata("志贵-强断连招") then
              timer2:remove()
              return
            end
            cs = cs + 1
            local jd
            if cs <= 2 then
              jd = angle - 90
            else
              jd = angle + 90
            end
            local dx, dy = u:getxy()
            Effectcreate("war3mapImported\\File00006330.mdl", dx, dy, 0, GetRandomReal(5, 6), 200, jd, GetRandomReal(-45, 45), 0, GetRandomReal(1, 2))
            if cs == 4 then
              timer2:remove()
            end
          end)
          x, y = u:getxy()
          Effectcreate("war3mapImported\\Daji_Kuoshan2.mdl", x, y, 0, 2, 0, GetRandomReal(0, 360), 0, 0, 3)
          mz2 = false
          for _, xq in ac.selector():in_rangexy(x, y, 400 + bs):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            mz = true
            mz2 = true
            zhiguidamageunit(u, xq, 1.25 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 0, angle, false)
          end
          if mz2 then
            zhigui_combo(u)
          end
          lianxie(u, skillstr)
          if mz then
            zhigui_hlget(u, skillstr)
          end
          zhiguijiaodujiaozheng(u)
        end)
        timer:remove()
      end
    end)
  end,
  QWEAV = function(u)
    local skillstr = "QWEAV"
    local angle = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    u:playseensound(zhigui_zhanji1)
    u:playseensound(zhigui_zhanji2)
    u:playseensound(Shiki_zhandou11)
    u:playseensound(zhigui_bisha2)
    u:playseensound(zhigui_bisha3)
    u:setdata("七夜连携", "")
    u:setdata("七夜连携时间", 1.5)
    zhiguizantingtime(u, 0.4)
    u:buffset(u.handle, 0.5, "无敌")
    if u:hasdata("志贵天赋-闪走名月") then
      u:buffset(u.handle, 0.4, "绝对闪避")
    end
    u:shockcamera(50, 0.15)
    local mz = false
    u:setflyheight(0)
    Effectcreate("war3mapImported\\bbb.mdl", x, y, 0, 2, 0, angle, 0, 0, 1.5)
    Effectcreate("war3mapImported\\qiye_xialuo1.mdl", x, y, 0, 3, 0, angle, 0, 0, 2)
    Effectcreate("war3mapImported\\Daji_Kuoshan2.mdl", x, y, 0, 2, 0, GetRandomReal(0, 360), 0, 0, 3)
    local mz2 = false
    for _, xq in ac.selector():in_rangexy(x, y, 400 + bs):is_enemy(u.handle):ipairs() do
      xq = getunit(xq)
      mz = true
      mz2 = true
      zhiguidamageunit(u, xq, 1.75 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 0, angle)
    end
    if mz2 then
      zhigui_combo(u)
    end
    ac.wait(200, function()
      if u:hasdata("志贵-强断连招") then
        return
      end
      x, y = u:getxy()
      local x2, y2 = PolarXY(x, y, -400, angle)
      u:setdata("志贵-无视伤害免疫时间", u:getdata("志贵-破抗时间"))
      mz2 = false
      for _, xq in ac.selector():in_rangexy(x2, y2, 400 + bs):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        mz = true
        mz2 = true
        zhiguidamageunit(u, xq, 1.75 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, -200, angle)
      end
      if mz2 then
        zhigui_combo(u)
      end
      Effectcreate("war3mapImported\\Daoguang_1.mdl", x, y, 0, 4, 200, angle + 180, 0, 0, 2)
      x2, y2 = PolarXY(x, y, -400, angle + 90)
      Effectcreate("war3mapImported\\Daoguang_1.mdl", x, y, 0, 2, 200, angle + 160, 0, 0, 2)
      x2, y2 = PolarXY(x, y, -400, angle - 90)
      Effectcreate("war3mapImported\\Daoguang_1.mdl", x, y, 0, 2, 200, angle + 200, 0, 0, 2)
      x2, y2 = PolarXY(x, y, -800, angle)
      u:setxy(x2, y2)
      zhiguicamset(u, x2, y2)
      u:setface(angle + 180)
      u:shockcamera(50, 0.3)
      shikianimeact(u, 2, 1.5)
      local cs = 0
      ac.loop(20, function(timer)
        if u:hasdata("志贵-强断连招") then
          timer:remove()
          return
        end
        cs = cs + 1
        local jd
        if cs <= 2 then
          jd = angle - 90
        else
          jd = angle + 90
        end
        local dx, dy = u:getxy()
        Effectcreate("war3mapImported\\File00006330.mdl", dx, dy, 0, GetRandomReal(5, 6), 200, jd, GetRandomReal(-45, 45), 0, GetRandomReal(1, 2))
        if cs == 4 then
          timer:remove()
        end
      end)
      if mz then
        zhigui_hlget(u, skillstr)
      end
      zhiguijiaodujiaozheng(u)
    end)
  end,
  EAAV = function(u)
    local skillstr = "EAAV"
    local angle = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    u:playseensound(zhigui_zhanji1)
    u:playseensound(Nanaya_zhandou13)
    u:playseensound(zhigui_daji3)
    u:setdata("七夜连携", "")
    zhiguizantingtime(u, 0.4)
    u:buffset(u.handle, 0.5, "无敌")
    if u:hasdata("志贵天赋-闪走名月") then
      u:buffset(u.handle, 0.4, "绝对闪避")
    end
    u:shockcamera(50, 0.15)
    shikianimeact(u, 14, 1.5)
    x, y = PolarXY(x, y, 1200, angle)
    u:setxy(x, y)
    local x2, y2 = PolarXY(x, y, 400, angle)
    Effectcreate("war3mapImported\\Daoguang_1.mdl", x2, y2, 0, 2, 400, angle, 45, 0, 2)
    x2, y2 = PolarXY(x, y, 800, angle)
    Effectcreate("war3mapImported\\Daoguang_1.mdl", x2, y2, 0, 2, 0, angle + 30, 45, 0, 2)
    Effectcreate("war3mapImported\\Daoguang_1.mdl", x2, y2, 0, 2, 0, angle - 30, 45, 0, 2)
    local gd = 700
    ac.loop(20, function(timer)
      if u:hasdata("志贵-强断连招") then
        timer:remove()
        return
      end
      u:setflyheight(gd)
      gd = gd - 150
      if gd <= 0 then
        u:setflyheight(0)
        u:shockcamera(100, 0.2)
        x, y = u:getxy()
        x2, y2 = PolarXY(x, y, 800, angle)
        u:setxy(x2, y2)
        Effectcreate("war3mapImported\\bbb.mdl", x2, y2, 0, 2, 0, angle, 0, 0, 1.5)
        Effectcreate("war3mapImported\\qiye_xialuo1.mdl", x2, y2, 0, 3, 0, angle, 0, 0, 2)
        Effectcreate("war3mapImported\\Daji_Kuoshan2.mdl", x2, y2, 0, 2, 0, GetRandomReal(0, 360), 0, 0, 3)
        u:setdata("志贵-无视伤害闪避时间", u:getdata("志贵-破抗时间"))
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x2, y2, 400 + bs):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          mz2 = true
          zhiguidamageunit(u, xq, 3 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 0, angle, false)
        end
        if mz2 then
          zhigui_combo(u)
          zhigui_hlget(u, skillstr)
        end
        zhiguicamset(u, x2, y2)
        zhiguijiaodujiaozheng(u)
        timer:remove()
      end
    end)
  end,
  ["EAAV-HandMode"] = function(u)
    local skillstr = "EAAV"
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    local x2 = u:getdata("志贵-X")
    local y2 = u:getdata("志贵-Y")
    local angle = AngleXY(x, y, x2, y2)
    local dis = DistanceXY(x, y, x2, y2)
    u:setface(angle)
    local max = 1600
    if u:hasdata("志贵天赋-闪鞘光影虚空") then
      max = 4500
    end
    if dis >= max then
      dis = max
    end
    x2, y2 = PolarXY(x, y, dis, angle)
    local x3, y3 = x2, y2
    u:playseensound(zhigui_zhanji1)
    u:playseensound(Nanaya_zhandou13)
    u:playseensound(zhigui_daji3)
    u:setdata("七夜连携", "")
    zhiguizantingtime(u, 0.4)
    u:buffset(u.handle, 0.5, "无敌")
    if u:hasdata("志贵天赋-闪走名月") then
      u:buffset(u.handle, 0.4, "绝对闪避")
    end
    u:shockcamera(50, 0.15)
    shikianimeact(u, 14, 1.5)
    x2, y2 = PolarXY(x, y, dis - 400, angle)
    Effectcreate("war3mapImported\\Daoguang_1.mdl", x2, y2, 0, 2, 400, angle, 45, 0, 2)
    x2, y2 = PolarXY(x, y, dis, angle)
    Effectcreate("war3mapImported\\Daoguang_1.mdl", x2, y2, 0, 2, 0, angle + 30, 45, 0, 2)
    Effectcreate("war3mapImported\\Daoguang_1.mdl", x2, y2, 0, 2, 0, angle - 30, 45, 0, 2)
    local gd = 700
    ac.loop(20, function(timer)
      if u:hasdata("志贵-强断连招") then
        timer:remove()
        return
      end
      u:setflyheight(gd)
      gd = gd - 150
      if gd <= 0 then
        u:setflyheight(0)
        u:shockcamera(100, 0.2)
        u:setxy(x3, y3)
        Effectcreate("war3mapImported\\bbb.mdl", x3, y3, 0, 2, 0, angle, 0, 0, 1.5)
        Effectcreate("war3mapImported\\qiye_xialuo1.mdl", x3, y3, 0, 3, 0, angle, 0, 0, 2)
        Effectcreate("war3mapImported\\Daji_Kuoshan2.mdl", x3, y3, 0, 2, 0, GetRandomReal(0, 360), 0, 0, 3)
        u:setdata("志贵-无视伤害闪避时间", u:getdata("志贵-破抗时间"))
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x3, y3, 400 + bs):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          mz2 = true
          zhiguidamageunit(u, xq, 3 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 0, angle, false)
        end
        if mz2 then
          zhigui_combo(u)
          zhigui_hlget(u, skillstr)
        end
        zhiguicamset(u, x3, y3)
        zhiguijiaodujiaozheng(u)
        timer:remove()
      end
    end)
  end,
  EEAV = function(u)
    local skillstr = "EEAV"
    local angle = u:getface() + 180
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    zhiguicamlock(u)
    u:playseensound(Nanaya_zhandou25)
    u:setdata("七夜连携", "")
    u:setdata("七夜连携时间", 0.85)
    u:setface(angle)
    zhiguizantingtime(u, 0.55)
    u:buffset(u.handle, 0.65, "无敌")
    if u:hasdata("志贵天赋-闪走名月") then
      u:buffset(u.handle, 0.55, "绝对闪避")
    end
    shikianimeact(u, 6, 1)
    local mz = false
    local mz2 = false
    local g2 = CreateGroupLua()
    unitmove({
      unit = u.handle,
      time = 0.45,
      distance = 300,
      angle = angle,
      loops = {
        {
          looptime = 0.03,
          func = function(dx, dy, args)
            if u:hasdata("志贵-强断连招") then
              args.stop = true
              return
            end
            local x2, y2 = PolarXY(dx, dy, 50, angle)
            if GetRandom100(50) then
              Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x2, y2, 0, GetRandomReal(2, 3), GetRandomReal(100, 300), angle + GetRandomReal(-80, 80), GetRandomReal(-30, 30), 0, GetRandomReal(2, 3))
            else
              Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x2, y2, 0, GetRandomReal(2, 3), GetRandomReal(100, 300), angle + GetRandomReal(-80, 80), GetRandomReal(170, 200), 0, GetRandomReal(2, 3))
            end
          end
        },
        {
          looptime = 0.06,
          func = function(dx, dy, args)
            if u:hasdata("志贵-强断连招") then
              args.stop = true
              return
            end
            local x2, y2 = PolarXY(dx, dy, 50, angle)
            mz2 = false
            for _, xq in ac.selector():in_rangexy(x2, y2, 300 + bs):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              mz2 = true
              mz = true
              if not xq:isingroup(g2) then
                xq:groupadd(g2)
                zhiguidamageunit(u, xq, 0.2 * sh, 1.5 * kz, "僵直", txstr1, txstr2, 80, angle, false)
              else
                zhiguidamageunit(u, xq, 0.2 * sh, 1.5 * kz, "僵直", txstr1, txstr2, 80, angle, true)
              end
            end
            if mz2 then
              zhigui_combo(u)
              u:shockcamera(10)
            end
            u:playseensound(zhigui_zhanji3)
            SetSoundPlayPosition(zhigui_zhanji3, 30)
          end
        }
      },
      endfunc = function()
        u:playseensound(zhigui_zhanji1)
        u:playseensound(Nanaya_zhandou8)
        shikianimeact(u, 2, 2)
        u:shockcamera(100, 0.2)
        local x2, y2 = PolarXY(x, y, 400, angle)
        Effectcreate("war3mapImported\\Daoguang_1.mdl", x2, y2, 0, 2, 200, angle - 30, 0, 0, 2)
        Effectcreate("war3mapImported\\Daoguang_1.mdl", x2, y2, 0, 2, 200, angle + 30, 0, 0, 2)
        Effectcreate("war3mapImported\\File00000650.mdl", x2, y2, 0, 15, 200, angle, 0, 0, 2)
        Effectcreate("war3mapImported\\Daji_Hong1.mdl", x2, y2, 0, 30, 200, GetRandomReal(0, 360), 0, 0, 2)
        GroupClearLua(g2)
        mz2 = false
        for _, xq in ac.selector():in_rangexy(x2, y2, 400 + bs):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          xq:groupadd(g2)
          mz2 = true
          zhiguidamageunit(u, xq, 1 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 0, angle, false)
        end
        if mz2 then
          zhigui_combo(u)
        end
        x2, y2 = PolarXY(x, y, 800, angle)
        u:setxy(x2, y2)
        ac.wait(500, function()
          if Group_Counts(g2) > 0 then
            u:playseensound(zhigui_zhanji1)
            u:playseensound(zhigui_bisha3)
            u:shockcamera(100, 0.2)
            x2, y2 = PolarXY(x, y, 400, angle)
            for i = 1, 5 do
              Effectcreate("war3mapImported\\qiye_baoxue2.mdl", x2, y2, 0, 3, 0, GetRandomReal(0, 360), 0, 0, 1)
              Effectcreate("war3mapImported\\qiye_nanaya_xue1.mdl", x2, y2, 0, 3, 0, GetRandomReal(0, 360), 0, 0, 1)
            end
            for i = 1, 2 do
              Effectcreate("war3mapImported\\Daoguang_1.mdl", x2, y2, 0, GetRandomReal(1, 2), 0, GetRandomReal(0, 360), 0, 0, 2)
            end
            Effectcreate("war3mapImported\\Daji_Hong1.mdl", x2, y2, 0, 30, 200, GetRandomReal(0, 360), 0, 0, 2)
            mz2 = false
            ForGroupLuaNew(g2, function(xq)
              mz2 = true
              zhiguidamageunit(u, xq, 1 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 200, angle, false)
            end)
            if mz2 then
              zhigui_combo(u)
            end
          end
          if mz then
            zhigui_hlget(u, skillstr)
          end
          zhiguicamunlock(u)
          zhiguijiaodujiaozheng(u)
        end)
      end
    })
  end,
  AEAV = function(u)
    local skillstr = "AEAV"
    local angle = u:getface() + 180
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    zhiguicamlock(u)
    u:setdata("七夜连携", "")
    u:setdata("七夜连携时间", 0.9)
    u:setface(angle)
    zhiguizantingtime(u, 0.6)
    u:buffset(u.handle, 0.7, "无敌")
    if u:hasdata("志贵天赋-闪走名月") then
      u:buffset(u.handle, 0.6, "绝对闪避")
    end
    local x1, y1 = PolarXY(x, y, 500, angle)
    local x2, y2 = PolarXY(x, y, 250, angle)
    local mj = u:createunit("u0EA", x1, y1, angle + 180)
    shikianimeact(u, 10, 1)
    shikianimeact(mj, 10, 1)
    ac.wait(300, function()
      shikianimeact(u, 16, 1)
      shikianimeact(mj, 16, 1)
    end)
    ac.wait(600, function()
      shikianimeact(u, 17, 1)
      shikianimeact(mj, 17, 1)
    end)
    ac.wait(300, function()
      local mz = false
      local mz2 = false
      u:playseensound(zhigui_daji2)
      u:shockcamera(100, 0.2)
      Effectcreate("war3mapImported\\File00000650.mdl", x, y, 0, 20, 400, angle, -70, 0, 2)
      Effectcreate("war3mapImported\\File00000650.mdl", x1, y1, 0, 20, 400, angle + 180, -70, 0, 2)
      local g2 = CreateGroupLua()
      local cs = 0
      ac.loop(10, function(timer)
        if u:hasdata("志贵-强断连招") then
          timer:remove()
          mj:remove()
          return
        end
        cs = cs + 1
        x, y = PolarXY(x, y, 50, angle)
        u:setxy(x, y)
        x1, y1 = PolarXY(x1, y1, -50, angle)
        mj:setxy(x1, y1)
        mj:setcolor(255, 255, 255, 25.5 * cs)
        mz2 = false
        for _, xq in ac.selector():in_rangexy(x2, y2, 350 + bs):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          mz2 = true
          mz = true
          xq:setflyheight(GetUnitFlyHeight(xq.handle) + 100)
          if not xq:isingroup(g2) then
            xq:groupadd(g2)
            zhiguidamageunit(u, xq, 1.5 * sh, kz, "僵直", txstr1, txstr2, 0, angle, false)
          else
            zhiguidamageunit(u, xq, 1.5 * sh, kz, "僵直", txstr1, txstr2, 0, angle, true)
          end
        end
        if mz2 then
          zhigui_combo(u)
        end
        if 10 <= cs then
          u:playseensound(zhigui_daji3)
          u:playseensound(Nanaya_zhandou5)
          u:shockcamerastop()
          x, y = mj:getxy()
          mj:remove()
          x1, y1 = PolarXY(x, y, 250, angle)
          u:setxy(x1, y1)
          local timer1
          if u:hasdata("志贵-强断连招开启") then
            u:setcolor(255, 255, 255, 0)
            local cs2 = 0
            ac.loop(50, function(timer2)
              cs2 = cs2 + 1
              if u:hasdata("志贵-强断连招") then
                ForGroupLuaNew(g2, function(xq)
                  xq:setflyheight(0)
                end)
                timer1:remove()
                u:setcolor(255, 255, 255, 255)
                timer2:remove()
              end
              if cs2 == 6 then
                timer2:remove()
              end
            end)
          else
            ShowUnit(u.handle, false)
          end
          timer1 = ac.wait(300, function()
            u:playseensound(zhigui_luodi2)
            u:playseensound(zhigui_daji2)
            shikianimeact(u, 4, 2)
            Effectcreate("war3mapImported\\bbb.mdl", x1, y1, 0, 2, 0, angle, 0, 0, 1.5)
            Effectcreate("war3mapImported\\qiye_xialuo1.mdl", x1, y1, 0, 3, 0, angle, 0, 0, 1)
            Effectcreate("war3mapImported\\Daji_Kuoshan2.mdl", x1, y1, 0, 2, 0, GetRandomReal(0, 360), 0, 0, 2)
            Effectcreate("war3mapImported\\Daoguang_1.mdl", x1, y1, 0, 3, 800, angle, 0, 90, 1)
            Effectcreate("war3mapImported\\Daoguang_1.mdl", x1, y1, 0, 3, 800, angle, 0, 70, 3)
            Effectcreate("war3mapImported\\Daoguang_1.mdl", x1, y1, 0, 3, 800, angle + 180, 0, 70, 3)
            Effectcreate("war3mapImported\\File00000650.mdl", x1, y1, 0, 10, 800, angle, 0, 90, 2)
            if u:hasdata("志贵-强断连招开启") then
              u:setcolor(255, 255, 255, 255)
              ShowUnit(u.handle, true)
            else
              ShowUnit(u.handle, true)
            end
            getplayer(u.owner):select(u.handle)
            u:setdata("志贵-无视伤害免疫时间", u:getdata("志贵-破抗时间"))
            ForGroupLuaNew(g2, function(xq)
              local gd = GetUnitFlyHeight(xq.handle)
              ac.loop(20, function(timer2)
                u:setflyheight(gd)
                xq:setflyheight(gd)
                gd = gd - 1000
                if gd <= 0 then
                  u:setflyheight(0)
                  xq:setflyheight(0)
                  timer2:remove()
                end
              end)
            end)
            mz2 = false
            for _, xq in ac.selector():in_rangexy(x2, y2, 350 + bs):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              mz2 = true
              mz = true
              xq:setxy(x2, y2)
              zhiguidamageunit(u, xq, 1.5 * sh, kz, "僵直", txstr1, txstr2, 0, angle, false)
            end
            if mz2 then
              zhigui_combo(u)
            end
            zhiguicamunlock(u)
            u:shockcamera(100, 0.2)
            zhiguijiaodujiaozheng(u)
          end)
          ac.wait(1000, function()
            if mz then
              zhigui_hlget(u, skillstr)
            end
          end)
          timer:remove()
        end
      end)
    end)
  end,
  AAAV = function(u)
    local skillstr = "AAAV"
    local angle = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    zhiguicamlock(u)
    u:playseensound(zhigui_zhanji1)
    if u:getdata("志贵形态") == "七夜" then
      u:playseensound(Nanaya_zhandou24)
    else
      u:playseensound(Shiki_zhandou19)
    end
    u:setdata("七夜连携", "")
    u:setdata("七夜连携时间", 0.8)
    zhiguizantingtime(u, 0.5)
    u:buffset(u.handle, 0.6, "无敌")
    if u:hasdata("志贵天赋-闪走名月") then
      u:buffset(u.handle, 0.5, "绝对闪避")
    end
    shikianimeact(u, 1, 2)
    u:shockcamera(50, 0.15)
    local mz = false
    local timer1, timer2, timer3
    local cs = 0
    ac.loop(50, function(timer)
      cs = cs + 1
      if u:hasdata("志贵-强断连招") then
        timer1:remove()
        timer2:remove()
        timer3:remove()
        timer:remove()
      end
      if cs == 8 then
        timer:remove()
      end
    end)
    timer1 = ac.wait(100, function()
      x, y = u:getxy()
      x, y = PolarXY(x, y, 100, angle)
      u:setxy(x, y)
      local x2, y2 = PolarXY(x, y, 100, angle)
      Effectcreate("war3mapImported\\File00006330.mdl", x2, y2, 0, 3, 120, angle, 0, 0, 1)
      Effectcreate("war3mapImported\\File00006330.mdl", x2, y2, 0, 3, 120, angle, 70, 0, 2.5)
      local mz2 = false
      for _, xq in ac.selector():in_rangexy(x2, y2, 300 + bs):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        mz2 = true
        mz = true
        zhiguidamageunit(u, xq, 1.5 * sh, 1.5 * kz, "僵直", txstr1, txstr2, 200, angle, false)
      end
      if mz2 then
        u:shockcamera(10, 0.15)
        zhigui_combo(u)
      end
    end)
    timer2 = ac.wait(200, function()
      u:playseensound(zhigui_zhanji1)
      if u:getdata("志贵形态") == "七夜" then
        u:playseensound(Nanaya_zhandou23)
      else
        u:playseensound(Shiki_zhandou18)
      end
      shikianimeact(u, 2, 2)
      u:shockcamera(50, 0.15)
      ac.wait(100, function()
        x, y = u:getxy()
        x, y = PolarXY(x, y, 100, angle)
        u:setxy(x, y)
        local x2, y2 = PolarXY(x, y, 100, angle)
        Effectcreate("war3mapImported\\File00006330.mdl", x2, y2, 0, 3, 120, angle, 200, 0, 1)
        Effectcreate("war3mapImported\\File00006330.mdl", x2, y2, 0, 3, 120, angle, 270, 0, 2.5)
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x2, y2, 300 + bs):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          mz2 = true
          mz = true
          zhiguidamageunit(u, xq, 1.5 * sh, 1.5 * kz, "僵直", txstr1, txstr2, 200, angle, false)
        end
        if mz2 then
          u:shockcamera(10, 0.15)
          zhigui_combo(u)
        end
      end)
    end)
    timer3 = ac.wait(400, function()
      u:playseensound(zhigui_zhanji1)
      if u:getdata("志贵形态") == "七夜" then
        u:playseensound(Nanaya_zhandou4)
      else
        u:playseensound(Shiki_zhandou11)
      end
      shikianimeact(u, 2, 2)
      u:shockcamera(50, 0.15)
      ac.wait(100, function()
        x, y = u:getxy()
        x, y = PolarXY(x, y, 100, angle)
        u:setxy(x, y)
        zhiguicamunlock(u)
        local x2, y2 = PolarXY(x, y, 100, angle)
        Effectcreate("war3mapImported\\qiye_zhanji7.mdl", x2, y2, 0, 3, 120, angle, 20, 0, 1)
        Effectcreate("war3mapImported\\qiye_zhanji7.mdl", x2, y2, 0, 3, 120, angle, 160, 0, 2.5)
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x2, y2, 300 + bs):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          mz2 = true
          mz = true
          zhiguidamageunit(u, xq, 1.5 * sh, 1.5 * kz, "僵直", txstr1, txstr2, 200, angle, false)
        end
        if mz2 then
          u:shockcamera(10, 0.15)
          zhigui_combo(u)
        end
        if mz then
          zhigui_hlget(u, skillstr)
        end
      end)
    end)
  end,
  EEEV = function(u)
    local skillstr = "EEEV"
    local angle = u:getface() + 180
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    zhiguicamlock(u)
    u:playseensound(zhigui_daji3)
    u:playseensound(zhigui_zhanji1)
    u:playseensound(Shiki_zhandou21)
    u:setface(angle)
    u:setdata("七夜连携", "")
    u:setdata("七夜连携时间", 0.3)
    local x2, y2 = PolarXY(x, y, 900, angle)
    Effectcreate("war3mapImported\\dash sfx.mdl", x2, y2, 0, 2, 0, angle, 0, 0, 3)
    Effectcreate("war3mapImported\\chongci_Bo.mdl", x, y, 0, 2, 0, angle, 0, 0, 1.5)
    shikianimeact(u, 10, 3)
    u:shockcamera(50, 0.15)
    local x1, y1 = PolarXY(x, y, 400, angle)
    Effectcreate("war3mapImported\\File00000650.mdl", x1, y1, 0, 8, 200, angle, 0, 0, 2)
    ac.wait(300, function()
      u:playseensound(zhigui_zhanji1)
      Effectcreate("war3mapImported\\Daoguang_1.mdl", x1, y1, 0, 1.7, 200, angle, 0, 0, 7)
    end)
    u:setdata("志贵-无视伤害免疫时间", u:getdata("志贵-破抗时间"))
    local mz = false
    local g2 = CreateGroupLua()
    unitmove({
      unit = u.handle,
      time = 0.16,
      distance = 1600,
      angle = angle,
      loops = {
        {
          looptime = 0.02,
          func = function(dx, dy, args)
            if u:hasdata("志贵-强断连招") then
              args.stop = true
              return
            end
            for i = 1, 6 do
              local x2, y2 = PolarXY(dx, dy, GetRandomReal(-500, 500), angle)
              if GetRandom100(50) then
                Effectcreate("war3mapImported\\File00006330.mdl", x2, y2, 0, GetRandomReal(1, 3), GetRandomReal(200, 400), angle, GetRandomReal(-110, -80), GetRandomReal(0, 180), GetRandomReal(1, 2))
              else
                Effectcreate("war3mapImported\\Zhanji_Hong.mdl", x2, y2, 0, GetRandomReal(0.25, 0.7), GetRandomReal(200, 400), angle, GetRandomReal(-110, -80), GetRandomReal(0, 180), GetRandomReal(1, 2))
              end
            end
            for _, xq in ac.selector():in_rangexy(dx, dy, 200 + bs):is_enemy(u.handle):isnotingroup(g2):ipairs() do
              xq = getunit(xq)
              xq:groupadd(g2)
              mz = true
              zhiguidamageunit(u, xq, 1.5 * sh, 1.5 * kz, "僵直", txstr1, txstr2, 0, angle, false)
              ac.wait(200, function()
                zhiguidamageunit(u, xq, 1 * sh, 0, "僵直", txstr1, txstr2, 200, angle, false)
              end)
            end
          end
        }
      },
      endfunc = function()
        zhiguicamunlock(u)
        if mz then
          zhigui_combo(u)
          zhigui_hlget(u, skillstr)
        end
        zhiguijiaodujiaozheng(u)
      end
    })
  end,
  EAEV = function(u)
    local skillstr = "EAEV"
    local angle = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    zhiguicamlock(u)
    u:setdata("七夜连携", "")
    u:setdata("七夜连携时间", 1.4)
    zhiguizantingtime(u, 1.1)
    u:buffset(u.handle, 1.2, "无敌")
    if u:hasdata("志贵天赋-闪走名月") then
      u:buffset(u.handle, 1.1, "绝对闪避")
    end
    u:playseensound(zhigui_zhanji1)
    u:playseensound(Shiki_zhandou18)
    u:shockcamera(50, 0.15)
    shikianimeact(u, 1, 2)
    local mz = false
    local timer1, timer2, timer3
    local cs = 0
    ac.loop(50, function(timer)
      cs = cs + 1
      if u:hasdata("志贵-强断连招") then
        timer1:remove()
        timer2:remove()
        timer3:remove()
        timer:remove()
      end
      if cs == 8 then
        timer:remove()
      end
    end)
    timer1 = ac.wait(100, function()
      x, y = u:getxy()
      x, y = PolarXY(x, y, 100, angle)
      u:setxy(x, y)
      local x2, y2 = PolarXY(x, y, 100, angle)
      Effectcreate("war3mapImported\\File00006330.mdl", x2, y2, 0, 3, 120, angle, 0, 0, 1)
      Effectcreate("war3mapImported\\File00006330.mdl", x2, y2, 0, 3, 120, angle, 70, 0, 2.5)
      local mz2 = false
      for _, xq in ac.selector():in_rangexy(x2, y2, 300 + bs):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        mz2 = true
        mz = true
        zhiguidamageunit(u, xq, 1 * sh, 1.5 * kz, "僵直", txstr1, txstr2, 200, angle, false)
      end
      if mz2 then
        u:shockcamera(10, 0.15)
        zhigui_combo(u)
      end
    end)
    timer2 = ac.wait(200, function()
      u:playseensound(zhigui_zhanji1)
      u:playseensound(Shiki_zhandou19)
      shikianimeact(u, 2, 2)
      u:shockcamera(50, 0.15)
      ac.wait(100, function()
        x, y = u:getxy()
        x, y = PolarXY(x, y, 200, angle)
        u:setxy(x, y)
        local x2, y2 = PolarXY(x, y, 100, angle)
        Effectcreate("war3mapImported\\File00006330.mdl", x2, y2, 0, 3, 120, angle, 200, 0, 1)
        Effectcreate("war3mapImported\\File00006330.mdl", x2, y2, 0, 3, 120, angle, 270, 0, 2.5)
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x2, y2, 300 + bs):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          mz2 = true
          mz = true
          zhiguidamageunit(u, xq, 1 * sh, 1.5 * kz, "僵直", txstr1, txstr2, 200, angle, false)
        end
        if mz2 then
          u:shockcamera(10, 0.15)
          zhigui_combo(u)
        end
        x, y = u:getxy()
        x, y = PolarXY(x, y, 600, angle)
        u:setxy(x, y)
      end)
    end)
    timer3 = ac.wait(400, function()
      u:playseensound(Shiki_zhandou2)
      angle = angle + 180
      u:setface(angle)
      shikianimeact(u, 6, 1)
      local mz2 = false
      local g2 = CreateGroupLua()
      unitmove({
        unit = u.handle,
        time = 0.8,
        distance = 400,
        angle = angle,
        loops = {
          {
            looptime = 0.03,
            func = function(dx, dy, args)
              if u:hasdata("志贵-强断连招") then
                args.stop = true
                return
              end
              local x2, y2 = PolarXY(dx, dy, 100, angle)
              if GetRandom100(50) then
                Effectcreate("war3mapImported\\qiye_zhanji1.mdl", x2, y2, 0, GetRandomReal(1, 2.5), 150, angle + GetRandomReal(-20, 20), GetRandomReal(0, 360), GetRandomReal(-20, 20), GetRandomReal(1, 2))
              else
                Effectcreate("war3mapImported\\qiye_zhanji2.mdl", x2, y2, 0, GetRandomReal(3, 6), 150, angle + GetRandomReal(-20, 20), GetRandomReal(0, 360), GetRandomReal(-20, 20), GetRandomReal(1, 2))
              end
            end
          },
          {
            looptime = 0.062,
            func = function(dx, dy, args)
              if u:hasdata("志贵-强断连招") then
                args.stop = true
                return
              end
              local x2, y2 = PolarXY(dx, dy, 100, angle)
              mz2 = false
              for _, xq in ac.selector():in_rangexy(x2, y2, 300 + bs):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                mz2 = true
                mz = true
                if not xq:isingroup(g2) then
                  xq:groupadd(g2)
                  zhiguidamageunit(u, xq, 0.25 * sh, 1.5 * kz, "僵直", txstr1, txstr2, 30, angle, false)
                else
                  zhiguidamageunit(u, xq, 0.25 * sh, 1.5 * kz, "僵直", txstr1, txstr2, 30, angle, true)
                end
              end
              if mz2 then
                zhigui_combo(u)
                u:shockcamera(10)
              end
              u:playseensound(zhigui_zhanji3)
              SetSoundPlayPosition(zhigui_zhanji3, 30)
            end
          }
        },
        endfunc = function()
          zhiguicamunlock(u)
          u:shockcamerastop()
          ResetUnitAnimation(u.handle)
          lianxie(u, skillstr)
          if mz then
            zhigui_hlget(u, skillstr)
          end
          zhiguijiaodujiaozheng(u)
        end
      })
    end)
  end,
  QWEEV = function(u)
    local skillstr = "QWEEV"
    local angle = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    zhiguicamlock(u)
    u:setdata("七夜连携", "")
    u:setdata("七夜连携时间", 2.2)
    zhiguizantingtime(u, 0.1)
    u:buffset(u.handle, 1.2, "无敌")
    if u:hasdata("志贵天赋-闪走名月") then
      u:buffset(u.handle, 1.1, "绝对闪避")
    end
    u:playseensound(zhigui_zhanji1)
    u:playseensound(Nanaya_zhandou17)
    u:shockcamera(50, 0.15)
    shikianimeact(u, 1, 2)
    local mz = false
    local timer1, timer2, timer3
    local cs = 0
    ac.loop(50, function(timer)
      cs = cs + 1
      if u:hasdata("志贵-强断连招") then
        timer1:remove()
        timer2:remove()
        timer3:remove()
        timer:remove()
      end
      if cs == 8 then
        timer:remove()
      end
    end)
    timer1 = ac.wait(100, function()
      x, y = u:getxy()
      x, y = PolarXY(x, y, 100, angle)
      u:setxy(x, y)
      local x2, y2 = PolarXY(x, y, 100, angle)
      Effectcreate("war3mapImported\\File00006330.mdl", x2, y2, 0, 3, 120, angle, 0, 0, 1)
      Effectcreate("war3mapImported\\File00006330.mdl", x2, y2, 0, 3, 120, angle, 70, 0, 2.5)
      local mz2 = false
      for _, xq in ac.selector():in_rangexy(x2, y2, 300 + bs):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        mz2 = true
        mz = true
        zhiguidamageunit(u, xq, 1 * sh, 1.5 * kz, "僵直", txstr1, txstr2, 200, angle, false)
      end
      if mz2 then
        u:shockcamera(10, 0.15)
        zhigui_combo(u)
      end
    end)
    timer2 = ac.wait(200, function()
      u:playseensound(zhigui_zhanji1)
      u:playseensound(Nanaya_zhandou18)
      shikianimeact(u, 2, 2)
      u:shockcamera(50, 0.15)
      ac.wait(100, function()
        x, y = u:getxy()
        x, y = PolarXY(x, y, 200, angle)
        u:setxy(x, y)
        local x2, y2 = PolarXY(x, y, 100, angle)
        Effectcreate("war3mapImported\\File00006330.mdl", x2, y2, 0, 3, 120, angle, 200, 0, 1)
        Effectcreate("war3mapImported\\File00006330.mdl", x2, y2, 0, 3, 120, angle, 270, 0, 2.5)
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x2, y2, 300 + bs):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          mz2 = true
          mz = true
          zhiguidamageunit(u, xq, 1 * sh, 1.5 * kz, "僵直", txstr1, txstr2, 200, angle, false)
        end
        if mz2 then
          u:shockcamera(10, 0.15)
          zhigui_combo(u)
        end
        x, y = u:getxy()
        x, y = PolarXY(x, y, 600, angle)
        u:setxy(x, y)
      end)
    end)
    timer3 = ac.wait(400, function()
      u:playseensound(Shiki_zhandou2)
      angle = angle + 180
      u:setface(angle)
      shikianimeact(u, 6, 1)
      local mz2 = false
      local g2 = CreateGroupLua()
      unitmove({
        unit = u.handle,
        time = 0.45,
        distance = 300,
        angle = angle,
        loops = {
          {
            looptime = 0.03,
            func = function(dx, dy, args)
              if u:hasdata("志贵-强断连招") then
                args.stop = true
                return
              end
              local x2, y2 = PolarXY(dx, dy, 50, angle)
              if GetRandom100(50) then
                Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x2, y2, 0, GetRandomReal(2, 3), GetRandomReal(100, 300), angle + GetRandomReal(-80, 80), GetRandomReal(-30, 30), 0, GetRandomReal(2, 3))
              else
                Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x2, y2, 0, GetRandomReal(2, 3), GetRandomReal(100, 300), angle + GetRandomReal(-80, 80), GetRandomReal(170, 200), 0, GetRandomReal(2, 3))
              end
            end
          },
          {
            looptime = 0.06,
            func = function(dx, dy, args)
              if u:hasdata("志贵-强断连招") then
                args.stop = true
                return
              end
              local x2, y2 = PolarXY(dx, dy, 50, angle)
              mz2 = false
              for _, xq in ac.selector():in_rangexy(x2, y2, 300 + bs):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                mz2 = true
                mz = true
                if not xq:isingroup(g2) then
                  xq:groupadd(g2)
                  zhiguidamageunit(u, xq, 0.25 * sh, 1.5 * kz, "僵直", txstr1, txstr2, 80, angle, false)
                else
                  zhiguidamageunit(u, xq, 0.25 * sh, 1.5 * kz, "僵直", txstr1, txstr2, 80, angle, true)
                end
              end
              if mz2 then
                zhigui_combo(u)
                u:shockcamera(10)
              end
              u:playseensound(zhigui_zhanji3)
              SetSoundPlayPosition(zhigui_zhanji3, 30)
            end
          }
        },
        endfunc = function()
          u:playseensound(zhigui_daji3)
          u:playseensound(zhigui_luodi1)
          u:playseensound(Nanaya_zhandou25)
          shikianimeact(u, 15, 1)
          u:shockcamera(100, 0.15)
          x, y = u:getxy()
          local x1, y1 = PolarXY(x, y, 300, angle)
          u:setxy(x1, y1)
          zhiguicamunlock(u)
          Effectcreate("war3mapImported\\qiye_chongji1.mdl", x1, y1, 0, 2, 0, angle, 0, 0, 1)
          Effectcreate("war3mapImported\\chongci_Bo.mdl", x1, y1, 0, 1.5, 0, angle, 0, 0, 2)
          u:shockcamera(70, 0.15)
          for _, xq in ac.selector():in_rangexy(x1, y1, 400 + bs):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            zhiguidamageunit(u, xq, 1 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 0)
            unitmove({
              unit = xq.handle,
              time = 0.1,
              distance = 1000,
              angle = angle,
              isfly = Nandu_Choose <= 4
            })
          end
          if mz2 then
            zhigui_combo(u)
          end
          if mz then
            zhigui_hlget(u, skillstr)
          end
          zhiguijiaodujiaozheng(u)
        end
      })
    end)
  end,
  AAEV = function(u)
    local skillstr = "AAEV"
    local angle = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    zhiguicamlock(u)
    u:setdata("七夜连携", "")
    u:setdata("七夜连携时间", 0.9)
    zhiguizantingtime(u, 0.9)
    u:buffset(u.handle, 1, "无敌")
    if u:hasdata("志贵天赋-闪走名月") then
      u:buffset(u.handle, 0.9, "绝对闪避")
    end
    u:playseensound(zhigui_zhanji1)
    u:playseensound(zhigui_bisha3)
    u:playseensound(Nanaya_zhandou28)
    local x2, y2 = PolarXY(x, y, 900, angle)
    Effectcreate("war3mapImported\\qiye_chongji1.mdl", x2, y2, 0, 2, 0, angle, 0, 0, 3)
    Effectcreate("war3mapImported\\chongci_Bo.mdl", x, y, 0, 2, 0, angle, 0, 0, 1.5)
    shikianimeact(u, 10, 3)
    u:shockcamera(50, 0.15)
    local x1, y1 = PolarXY(x, y, 400, angle)
    Effectcreate("war3mapImported\\qiye_zhanji8.mdl", x1, y1, 0, 4, 0, angle, 0, 0, 2)
    Effectcreate("war3mapImported\\Daji_Hong1.mdl", x1, y1, 0, 40, 200, angle, 0, 0, 2)
    ac.wait(300, function()
      Effectcreate("war3mapImported\\qiye_zhanji9.mdl", x1, y1, 0, 4, 200, angle, 0, 0, 7)
    end)
    local mz = false
    local mz2 = false
    local g2 = CreateGroupLua()
    unitmove({
      unit = u.handle,
      time = 0.16,
      distance = 800,
      angle = angle,
      loops = {
        {
          looptime = 0.02,
          func = function(dx, dy, args)
            if u:hasdata("志贵-强断连招") then
              args.stop = true
              return
            end
            for _, xq in ac.selector():in_rangexy(dx, dy, 200 + bs):is_enemy(u.handle):isnotingroup(g2):ipairs() do
              xq = getunit(xq)
              xq:groupadd(g2)
              mz2 = true
              zhiguidamageunit(u, xq, 1.5 * sh, 1.5 * kz, "僵直", txstr1, txstr2, 200, angle, false)
            end
          end
        }
      },
      endfunc = function()
        if mz2 then
          zhigui_combo(u)
        end
      end
    })
    local timer1
    local cs = 0
    ac.loop(50, function(timer)
      cs = cs + 1
      if u:hasdata("志贵-强断连招") then
        timer1:remove()
        timer:remove()
        return
      end
      if cs == 4 then
        timer:remove()
      end
    end)
    timer1 = ac.wait(200, function()
      u:setflyheight(700)
      angle = angle + 180
      u:setface(angle)
      local timer2, timer3
      local cs2 = 0
      ac.loop(50, function(timer)
        cs2 = cs2 + 1
        if u:hasdata("志贵-强断连招") then
          timer2:remove()
          timer3:remove()
          timer:remove()
          u:setflyheight(0)
          return
        end
        if cs2 == 12 then
          timer:remove()
        end
      end)
      timer2 = ac.wait(200, function()
        u:playseensound(zhigui_zhanji1)
        u:setflyheight(0)
        u:shockcamera(100, 0.2)
        x, y = u:getxy()
        x2, y2 = PolarXY(x, y, 600, angle)
        u:setxy(x2, y2)
        for i = 1, 5 do
          Effectcreate("war3mapImported\\qiye_baoxue2.mdl", x2, y2, 0, 3, 0, GetRandomReal(0, 360), 0, 0, 1)
          Effectcreate("war3mapImported\\qiye_nanaya_xue1.mdl", x2, y2, 0, 3, 0, GetRandomReal(0, 360), 0, 0, 1)
        end
        for i = 1, 2 do
          Effectcreate("war3mapImported\\Daoguang_1.mdl", x2, y2, 0, GetRandomReal(1, 2), 0, GetRandomReal(0, 360), 0, 0, 2)
        end
        Effectcreate("war3mapImported\\Daji_Hong1.mdl", x2, y2, 0, 30, 200, GetRandomReal(0, 360), 0, 0, 2)
        mz2 = false
        for _, xq in ac.selector():in_rangexy(x2, y2, 300 + bs):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          mz = true
          mz2 = true
          zhiguidamageunit(u, xq, 1.5 * sh, 1.5 * kz, "僵直", txstr1, txstr2, 200, angle, false)
        end
        if mz2 then
          zhigui_combo(u)
        end
      end)
      timer3 = ac.wait(600, function()
        u:playseensound(zhigui_zhanji1)
        u:playseensound(zhigui_luodi3)
        u:playseensound(zhigui_bisha2)
        u:playseensound(zhigui_suipin)
        u:shockcamera(100, 0.2)
        x2, y2 = u:getxy()
        for i = 1, 5 do
          Effectcreate("war3mapImported\\qiye_baoxue2.mdl", x2, y2, 0, 3, 0, GetRandomReal(0, 360), 0, 0, 1)
          Effectcreate("war3mapImported\\qiye_nanaya_xue1.mdl", x2, y2, 0, 3, 0, GetRandomReal(0, 360), 0, 0, 1)
        end
        for i = 1, 2 do
          Effectcreate("war3mapImported\\Daoguang_1.mdl", x2, y2, 0, GetRandomReal(5, 8), 0, GetRandomReal(0, 360), 0, 0, 2)
        end
        Effectcreate("war3mapImported\\Daji_Hong1.mdl", x2, y2, 0, 30, 200, GetRandomReal(0, 360), 0, 0, 2)
        mz2 = false
        for _, xq in ac.selector():in_rangexy(x2, y2, 300 + bs):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          mz = true
          mz2 = true
          zhiguidamageunit(u, xq, 1.5 * sh, 1.5 * kz, "僵直", txstr1, txstr2, 200, angle, false)
        end
        if mz2 then
          zhigui_combo(u)
        end
        x, y = u:getxy()
        x2, y2 = PolarXY(x, y, 600, angle)
        u:setxy(x2, y2)
        u:setface(angle)
        zhiguicamunlock(u)
        if mz then
          zhigui_hlget(u, skillstr)
        end
        zhiguijiaodujiaozheng(u)
      end)
    end)
  end,
  ["AAEV-HandMode"] = function(u)
    local skillstr = "AAEV"
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    local angle = u:getface()
    u:setdata("七夜连携", "")
    u:setdata("七夜连携时间", 0.4)
    zhiguizantingtime(u, 0.4)
    u:buffset(u.handle, 0.5, "无敌")
    if u:hasdata("志贵天赋-闪走名月") then
      u:buffset(u.handle, 0.4, "绝对闪避")
    end
    u:playseensound(zhigui_zhanji1)
    u:playseensound(zhigui_bisha3)
    u:playseensound(Nanaya_zhandou28)
    local x2, y2 = PolarXY(x, y, 900, angle)
    Effectcreate("war3mapImported\\qiye_chongji1.mdl", x2, y2, 0, 2, 0, angle, 0, 0, 3)
    Effectcreate("war3mapImported\\chongci_Bo.mdl", x2, y2, 0, 2, 0, angle, 0, 0, 1.5)
    shikianimeact(u, 10, 3)
    u:shockcamera(50, 0.15)
    local x1, y1 = PolarXY(x, y, 400, angle)
    Effectcreate("war3mapImported\\qiye_zhanji8.mdl", x1, y1, 0, 4, 0, angle, 0, 0, 2)
    Effectcreate("war3mapImported\\Daji_Hong1.mdl", x1, y1, 0, 40, 200, angle, 0, 0, 2)
    ac.wait(300, function()
      Effectcreate("war3mapImported\\qiye_zhanji9.mdl", x1, y1, 0, 4, 200, angle, 0, 0, 7)
    end)
    local mz = false
    local mz2 = false
    local g2 = CreateGroupLua()
    unitmove({
      unit = u.handle,
      time = 0.16,
      distance = 800,
      angle = angle,
      loops = {
        {
          looptime = 0.02,
          func = function(dx, dy, args)
            if u:hasdata("志贵-强断连招") then
              args.stop = true
              return
            end
            for _, xq in ac.selector():in_rangexy(dx, dy, 200 + bs):is_enemy(u.handle):isnotingroup(g2):ipairs() do
              xq = getunit(xq)
              xq:groupadd(g2)
              mz = true
              mz2 = true
              zhiguidamageunit(u, xq, 1.5 * sh, 1.5 * kz, "僵直", txstr1, txstr2, 200, angle, false)
            end
          end
        }
      },
      endfunc = function()
        if mz2 then
          zhigui_combo(u)
        end
      end
    })
    local timer2
    local cs2 = 0
    ac.loop(50, function(timer)
      cs2 = cs2 + 1
      if u:hasdata("志贵-强断连招") then
        timer2:remove()
        timer:remove()
        u:setflyheight(0)
        return
      end
      if cs2 == 4 then
        timer:remove()
      end
    end)
    timer2 = ac.wait(200, function()
      u:setflyheight(700)
      angle = angle + 180
      u:setface(angle)
      local timer3
      local cs2 = 0
      ac.loop(50, function(timer)
        cs2 = cs2 + 1
        if u:hasdata("志贵-强断连招") then
          timer3:remove()
          timer:remove()
          u:setflyheight(0)
          return
        end
        if cs2 == 4 then
          timer:remove()
        end
      end)
      timer3 = ac.wait(200, function()
        u:playseensound(zhigui_zhanji1)
        u:setflyheight(0)
        u:shockcamera(100, 0.2)
        x2, y2 = PolarXY(x, y, 600, angle)
        u:setxy(x2, y2)
        for i = 1, 5 do
          Effectcreate("war3mapImported\\qiye_baoxue2.mdl", x2, y2, 0, 3, 0, GetRandomReal(0, 360), 0, 0, 1)
          Effectcreate("war3mapImported\\qiye_nanaya_xue1.mdl", x2, y2, 0, 3, 0, GetRandomReal(0, 360), 0, 0, 1)
        end
        for i = 1, 2 do
          Effectcreate("war3mapImported\\Daoguang_1.mdl", x2, y2, 0, GetRandomReal(1, 2), 0, GetRandomReal(0, 360), 0, 0, 2)
        end
        Effectcreate("war3mapImported\\Daji_Hong1.mdl", x2, y2, 0, 30, 200, GetRandomReal(0, 360), 0, 0, 2)
        mz2 = false
        for _, xq in ac.selector():in_rangexy(x2, y2, 300 + bs):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          mz = true
          mz2 = true
          zhiguidamageunit(u, xq, 1.5 * sh, 1.5 * kz, "僵直", txstr1, txstr2, 200, angle, false)
        end
        if mz2 then
          zhigui_combo(u)
        end
        if mz then
          zhigui_hlget(u, skillstr)
        end
        u:setdata("七夜连携", "AAEV")
        u:setdata("七夜连携时间", 0.5)
        u:setdata("志贵-E变化时间", 0.5)
        zhiguijiaodujiaozheng(u)
      end)
    end)
  end,
  AAEVE = function(u)
    local skillstr = "AAEVE"
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    local x2 = u:getdata("志贵-X")
    local y2 = u:getdata("志贵-Y")
    local angle = AngleXY(x, y, x2, y2)
    local dis = DistanceXY(x, y, x2, y2)
    local max = 750
    if u:hasdata("志贵天赋-闪鞘光影虚空") then
      max = 4500
    end
    if dis >= max then
      dis = max
    end
    x2, y2 = PolarXY(x, y, dis, angle)
    u:setdata("七夜连携", "")
    u:setdata("七夜连携时间", 0.3)
    u:setdata("志贵-E变化时间", 0)
    zhiguizantingtime(u, 0.15)
    u:buffset(u.handle, 0.15, "绝对闪避")
    u:buffset(u.handle, 0.25, "无敌")
    local mz = false
    local mz2 = false
    u:playseensound(zhigui_zhanji1)
    u:playseensound(zhigui_luodi3)
    u:playseensound(zhigui_bisha2)
    u:playseensound(zhigui_suipin)
    u:shockcamera(100, 0.2)
    for i = 1, 5 do
      Effectcreate("war3mapImported\\qiye_baoxue2.mdl", x2, y2, 0, 3, 0, GetRandomReal(0, 360), 0, 0, 1)
      Effectcreate("war3mapImported\\qiye_nanaya_xue1.mdl", x2, y2, 0, 3, 0, GetRandomReal(0, 360), 0, 0, 1)
    end
    for i = 1, 2 do
      Effectcreate("war3mapImported\\Daoguang_1.mdl", x2, y2, 0, GetRandomReal(5, 8), 0, GetRandomReal(0, 360), 0, 0, 2)
    end
    Effectcreate("war3mapImported\\Daji_Hong1.mdl", x2, y2, 0, 30, 200, GetRandomReal(0, 360), 0, 0, 2)
    mz2 = false
    for _, xq in ac.selector():in_rangexy(x2, y2, 300 + bs):is_enemy(u.handle):ipairs() do
      xq = getunit(xq)
      mz = true
      mz2 = true
      zhiguidamageunit(u, xq, 1.5 * sh, 1.5 * kz, "僵直", txstr1, txstr2, 200, angle, false)
    end
    if mz2 then
      zhigui_combo(u)
    end
    x2, y2 = PolarXY(x2, y2, 300, angle)
    u:setxy(x2, y2)
    u:setface(angle)
    if mz then
      zhigui_hlget(u, skillstr)
    end
  end,
  AEEV = function(u)
    local skillstr = "AEEV"
    local angle = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    u:setdata("七夜连携", "")
    u:setdata("七夜连携时间", 2.3)
    zhiguizantingtime(u, 2.3)
    u:buffset(u.handle, 2.4, "无敌")
    if u:hasdata("志贵天赋-闪走名月") then
      u:buffset(u.handle, 2.3, "绝对闪避")
    end
    u:setdata("志贵-无视伤害免疫时间", u:getdata("志贵-破抗时间"))
    zhiguicamlock(u)
    local mz = false
    local timer1, timer2, timer3, timer4, timer5, timer6, timer7
    local cs2 = 0
    ac.loop(50, function(timer)
      cs2 = cs2 + 1
      if u:hasdata("志贵-强断连招") then
        timer1:remove()
        timer2:remove()
        timer3:remove()
        timer4:remove()
        timer5:remove()
        timer6:remove()
        timer7:remove()
        timer:remove()
        u:setflyheight(0)
        return
      end
      if cs2 == 40 then
        timer:remove()
      end
    end)
    timer1 = ac.wait(0, function()
      u:playseensound(zhigui_zhanji1)
      u:playseensound(Shiki_zhandou3)
      u:shockcamera(100, 0.15)
      local x1, y1 = PolarXY(x, y, 400, angle)
      local x2, y2 = PolarXY(x, y, 800, angle)
      local sj = GetRandomReal(200, 700)
      local x3, y3 = PolarXY(x, y, sj, angle)
      u:setface(angle)
      u:setxy(x2, y2)
      shikianimeact(u, 1, 2)
      Effectcreate("war3mapImported\\File00000650.mdl", x3, y3, 0, 15, 100, angle, 0, 0, 2)
      sj = GetRandomReal(200, 700)
      x3, y3 = PolarXY(x, y, sj, angle)
      Effectcreate("war3mapImported\\File00000650.mdl", x3, y3, 0, 15, 100, angle, 0, 0, 2)
      Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x2, y2, 0, 3, 100, angle, 0, 0, 1.5)
      Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x2, y2, 0, 3, 100, angle, GetRandomReal(0, 360), 0, 1.5)
      Effectcreate("war3mapImported\\Daji_Hong1.mdl", x1, y1, 0, 40, 200, angle, 0, 0, 2)
      local mz2 = false
      for _, xq in ac.selector():in_rangexy(x1, y1, 400 + bs):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        mz = true
        mz2 = true
        zhiguidamageunit(u, xq, 0.4 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 200, angle, false)
      end
      if mz2 then
        zhigui_combo(u)
      end
    end)
    timer2 = ac.wait(500, function()
      u:playseensound(zhigui_zhanji1)
      u:shockcamera(100, 0.15)
      local x1, y1 = PolarXY(x, y, 400, angle)
      local x2, y2 = x, y
      local sj = GetRandomReal(200, 700)
      local x3, y3 = PolarXY(x, y, sj, angle)
      u:setface(angle + 180)
      u:setxy(x2, y2)
      shikianimeact(u, 1, 2)
      Effectcreate("war3mapImported\\File00000650.mdl", x3, y3, 0, 15, 100, GetRandomReal(0, 360), 0, 0, 2)
      sj = GetRandomReal(200, 700)
      x3, y3 = PolarXY(x, y, sj, angle)
      Effectcreate("war3mapImported\\File00000650.mdl", x3, y3, 0, 15, 100, GetRandomReal(0, 360), 0, 0, 2)
      Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x2, y2, 0, 3, 100, angle + 180, GetRandomReal(10, 80), 0, 1.5)
      Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x2, y2, 0, 3, 100, angle + 180, GetRandomReal(10, 80), 0, 1.5)
      Effectcreate("war3mapImported\\Daji_Hong1.mdl", x1, y1, 0, 40, 200, angle, 0, 0, 2)
      local mz2 = false
      for _, xq in ac.selector():in_rangexy(x1, y1, 400 + bs):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        mz = true
        mz2 = true
        zhiguidamageunit(u, xq, 0.4 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 200, angle + 180, false)
      end
      if mz2 then
        zhigui_combo(u)
      end
    end)
    timer3 = ac.wait(700, function()
      u:playseensound(zhigui_zhanji1)
      u:shockcamera(100, 0.15)
      local x1, y1 = PolarXY(x, y, 400, angle)
      local x2, y2 = PolarXY(x, y, 800, angle)
      local sj = GetRandomReal(200, 700)
      local x3, y3 = PolarXY(x, y, sj, angle)
      u:setface(angle)
      u:setxy(x2, y2)
      shikianimeact(u, 1, 2)
      Effectcreate("war3mapImported\\qiye_zhanji8.mdl", x3, y3, 0, GetRandomReal(5, 8), 100, GetRandomReal(0, 360), 0, 0, 2)
      sj = GetRandomReal(200, 700)
      x3, y3 = PolarXY(x, y, sj, angle)
      Effectcreate("war3mapImported\\qiye_zhanji8.mdl", x3, y3, 0, GetRandomReal(5, 8), 100, GetRandomReal(0, 360), 0, 0, 2)
      Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x2, y2, 0, 3, 100, angle, 0, 0, 1.5)
      Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x2, y2, 0, 3, 100, angle, GetRandomReal(0, 360), 0, 1.5)
      Effectcreate("war3mapImported\\Daji_Hong1.mdl", x1, y1, 0, 40, 200, angle, 0, 0, 2)
      local mz2 = false
      for _, xq in ac.selector():in_rangexy(x1, y1, 400 + bs):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        mz = true
        mz2 = true
        zhiguidamageunit(u, xq, 0.4 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 100, angle, false)
      end
      if mz2 then
        zhigui_combo(u)
      end
    end)
    timer4 = ac.wait(900, function()
      u:playseensound(zhigui_zhanji1)
      u:shockcamera(100, 0.15)
      local x1, y1 = PolarXY(x, y, 400, angle)
      local x2, y2 = x, y
      local sj = GetRandomReal(200, 700)
      local x3, y3 = PolarXY(x, y, sj, angle)
      u:setface(angle + 180)
      u:setxy(x2, y2)
      shikianimeact(u, 1, 2)
      Effectcreate("war3mapImported\\File00000650.mdl", x3, y3, 0, 15, 100, GetRandomReal(0, 360), 0, 0, 2)
      sj = GetRandomReal(200, 700)
      x3, y3 = PolarXY(x, y, sj, angle)
      Effectcreate("war3mapImported\\File00000650.mdl", x3, y3, 0, 15, 100, GetRandomReal(0, 360), 0, 0, 2)
      Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x2, y2, 0, 3, 100, angle + 180, GetRandomReal(10, 80), 0, 1.5)
      Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x2, y2, 0, 3, 100, angle + 180, GetRandomReal(10, 80), 0, 1.5)
      Effectcreate("war3mapImported\\Daji_Hong1.mdl", x1, y1, 0, 40, 200, angle, 0, 0, 2)
      local mz2 = false
      for _, xq in ac.selector():in_rangexy(x1, y1, 400 + bs):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        mz = true
        mz2 = true
        zhiguidamageunit(u, xq, 0.4 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 100, angle + 180, false)
      end
      if mz2 then
        zhigui_combo(u)
      end
    end)
    timer5 = ac.wait(1100, function()
      u:playseensound(zhigui_zhanji1)
      u:shockcamera(100, 0.15)
      local x1, y1 = PolarXY(x, y, 400, angle)
      local x2, y2 = PolarXY(x, y, 800, angle)
      local sj = GetRandomReal(200, 700)
      local x3, y3 = PolarXY(x, y, sj, angle)
      u:setface(angle)
      u:setxy(x2, y2)
      shikianimeact(u, 1, 2)
      Effectcreate("war3mapImported\\qiye_zhanji8.mdl", x3, y3, 0, GetRandomReal(5, 8), 100, GetRandomReal(0, 360), 0, 0, 2)
      sj = GetRandomReal(200, 700)
      x3, y3 = PolarXY(x, y, sj, angle)
      Effectcreate("war3mapImported\\qiye_zhanji8.mdl", x3, y3, 0, GetRandomReal(5, 8), 100, GetRandomReal(0, 360), 0, 0, 2)
      Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x2, y2, 0, 3, 100, angle, 0, 0, 1.5)
      Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x2, y2, 0, 3, 100, angle, GetRandomReal(0, 360), 0, 1.5)
      Effectcreate("war3mapImported\\Daji_Hong1.mdl", x1, y1, 0, 40, 200, angle, 0, 0, 2)
      local mz2 = false
      for _, xq in ac.selector():in_rangexy(x1, y1, 400 + bs):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        mz = true
        mz2 = true
        zhiguidamageunit(u, xq, 0.4 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 100, angle, false)
      end
      if mz2 then
        zhigui_combo(u)
      end
    end)
    timer6 = ac.wait(1300, function()
      u:playseensound(zhigui_zhanji1)
      u:shockcamera(100, 0.15)
      local x1, y1 = PolarXY(x, y, 400, angle)
      local x2, y2 = x, y
      local sj = GetRandomReal(200, 700)
      local x3, y3 = PolarXY(x, y, sj, angle)
      u:setface(angle + 180)
      u:setxy(x2, y2)
      shikianimeact(u, 1, 2)
      Effectcreate("war3mapImported\\File00000650.mdl", x3, y3, 0, 15, 100, GetRandomReal(0, 360), 0, 0, 2)
      sj = GetRandomReal(200, 700)
      x3, y3 = PolarXY(x, y, sj, angle)
      Effectcreate("war3mapImported\\File00000650.mdl", x3, y3, 0, 15, 100, GetRandomReal(0, 360), 0, 0, 2)
      Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x2, y2, 0, 3, 100, angle + 180, GetRandomReal(10, 80), 0, 1.5)
      Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x2, y2, 0, 3, 100, angle + 180, GetRandomReal(10, 80), 0, 1.5)
      Effectcreate("war3mapImported\\Daji_Hong1.mdl", x1, y1, 0, 40, 200, angle, 0, 0, 2)
      local mz2 = false
      for _, xq in ac.selector():in_rangexy(x1, y1, 400 + bs):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        mz = true
        mz2 = true
        zhiguidamageunit(u, xq, 0.4 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 100, angle + 180, false)
      end
      if mz2 then
        zhigui_combo(u)
      end
    end)
    timer7 = ac.wait(2000, function()
      u:playseensound(zhigui_zhanji1)
      u:playseensound(zhigui_suipin)
      u:playseensound(zhigui_bisha3)
      u:shockcamera(100, 0.15)
      local x1, y1 = PolarXY(x, y, 400, angle)
      local x2, y2 = PolarXY(x, y, 800, angle)
      local sj = GetRandomReal(200, 700)
      local x3, y3 = PolarXY(x, y, sj, angle)
      Effectcreate("war3mapImported\\dash sfx.mdl", x2, y2, 0, 2, 100, angle, 0, 0, 3)
      Effectcreate("war3mapImported\\chongci_Bo.mdl", x, y, 0, 2, 100, angle, 0, 0, 1.5)
      Effectcreate("war3mapImported\\File00000650.mdl", x1, y1, 0, 15, 200, angle, 0, 0, 2)
      ac.wait(300, function()
        Effectcreate("war3mapImported\\qiye_zhanji8.mdl", x1, y1, 0, 17, -300, angle, 0, 0, 7)
      end)
      u:setface(angle)
      u:setxy(x2, y2)
      shikianimeact(u, 1, 2)
      Effectcreate("war3mapImported\\qiye_zhanji8.mdl", x3, y3, 0, GetRandomReal(5, 8), 100, GetRandomReal(0, 360), 0, 0, 2)
      sj = GetRandomReal(200, 700)
      x3, y3 = PolarXY(x, y, sj, angle)
      Effectcreate("war3mapImported\\qiye_zhanji8.mdl", x3, y3, 0, GetRandomReal(5, 8), 100, GetRandomReal(0, 360), 0, 0, 2)
      Effectcreate("war3mapImported\\Daji_Hong1.mdl", x1, y1, 0, 40, 200, angle, 0, 0, 2)
      local mz2 = false
      for _, xq in ac.selector():in_rangexy(x1, y1, 400 + bs):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        mz = true
        mz2 = true
        zhiguidamageunit(u, xq, 0.4 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 300, angle, false)
      end
      if mz2 then
        zhigui_combo(u)
      end
      ac.wait(300, function()
        u:shockcamera(100, 0.15)
        Effectcreate("war3mapImported\\qiye_zhanji8.mdl", x3, y3, 0, GetRandomReal(5, 8), 100, GetRandomReal(0, 360), 0, 0, 2)
        sj = GetRandomReal(200, 700)
        x3, y3 = PolarXY(x, y, sj, angle)
        Effectcreate("war3mapImported\\qiye_zhanji8.mdl", x3, y3, 0, GetRandomReal(5, 8), 100, GetRandomReal(0, 360), 0, 0, 2)
        Effectcreate("war3mapImported\\Daji_Hong1.mdl", x1, y1, 0, 40, 200, angle, 0, 0, 2)
        mz2 = false
        for _, xq in ac.selector():in_rangexy(x1, y1, 400 + bs):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          mz = true
          mz2 = true
          zhiguidamageunit(u, xq, 0.4 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 100, angle, false)
        end
        if mz2 then
          zhigui_combo(u)
        end
        if mz then
          zhigui_hlget(u, skillstr)
        end
        zhiguicamunlock(u)
        zhiguijiaodujiaozheng(u)
      end)
    end)
  end,
  ["AEEV-HandMode"] = function(u)
    local skillstr = "AEEV"
    local angle = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    u:setdata("七夜连携", skillstr)
    u:setdata("七夜连携时间", 0.9)
    u:setdata("志贵-E变化时间", 0.9)
    zhiguizantingtime(u, 0.2)
    u:buffset(u.handle, 0.4, "无敌")
    u:buffset(u.handle, 0.1, "绝对闪避")
    u:setdata("志贵-无视伤害免疫时间", u:getdata("志贵-破抗时间"))
    ac.wait(0, function()
      u:playseensound(zhigui_zhanji1)
      u:playseensound(Shiki_zhandou3)
      u:shockcamera(100, 0.15)
      local x1, y1 = PolarXY(x, y, 400, angle)
      local x2, y2 = PolarXY(x, y, 800, angle)
      local sj = GetRandomReal(200, 700)
      local x3, y3 = PolarXY(x, y, sj, angle)
      u:setface(angle)
      u:setxy(x2, y2)
      if u:hasdata("志贵-镜头全锁定") then
        zhiguicamset(u, x2, y2)
      end
      shikianimeact(u, 1, 2)
      Effectcreate("war3mapImported\\File00000650.mdl", x3, y3, 0, 15, 100, angle, 0, 0, 2)
      sj = GetRandomReal(200, 700)
      x3, y3 = PolarXY(x, y, sj, angle)
      Effectcreate("war3mapImported\\File00000650.mdl", x3, y3, 0, 15, 100, angle, 0, 0, 2)
      Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x2, y2, 0, 3, 100, angle, 0, 0, 1.5)
      Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x2, y2, 0, 3, 100, angle, GetRandomReal(0, 360), 0, 1.5)
      Effectcreate("war3mapImported\\Daji_Hong1.mdl", x1, y1, 0, 40, 200, angle, 0, 0, 2)
      local mz2 = false
      for _, xq in ac.selector():in_rangexy(x1, y1, 400 + bs):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        mz2 = true
        zhiguidamageunit(u, xq, 0.6 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 200, angle, false)
      end
      if mz2 then
        zhigui_combo(u)
        zhigui_hlget(u, skillstr)
      end
    end)
  end,
  AEEVE = function(u)
    local skillstr = "AEEVE"
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    local x2 = u:getdata("志贵-X")
    local y2 = u:getdata("志贵-Y")
    local angle = AngleXY(x, y, x2, y2)
    u:setface(angle)
    u:setdata("七夜连携", skillstr)
    u:setdata("七夜连携时间", 0.45)
    u:setdata("志贵-E变化时间", 0.45)
    zhiguizantingtime(u, 0.1)
    u:buffset(u.handle, 0.25, "无敌")
    u:buffset(u.handle, 0.1, "绝对闪避")
    ac.wait(0, function()
      u:playseensound(zhigui_zhanji1)
      u:shockcamera(100, 0.15)
      local x1, y1 = PolarXY(x, y, 400, angle)
      local x2, y2 = PolarXY(x, y, 800, angle)
      local sj = GetRandomReal(200, 700)
      local x3, y3 = PolarXY(x, y, sj, angle)
      u:setface(angle + 180)
      u:setxy(x2, y2)
      if u:hasdata("志贵-镜头全锁定") then
        zhiguicamset(u, x2, y2)
      end
      shikianimeact(u, 1, 2)
      Effectcreate("war3mapImported\\File00000650.mdl", x3, y3, 0, 15, 100, GetRandomReal(0, 360), 0, 0, 2)
      sj = GetRandomReal(200, 700)
      x3, y3 = PolarXY(x, y, sj, angle)
      Effectcreate("war3mapImported\\File00000650.mdl", x3, y3, 0, 15, 100, GetRandomReal(0, 360), 0, 0, 2)
      Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x2, y2, 0, 3, 100, angle, GetRandomReal(10, 80), 0, 1.5)
      Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x2, y2, 0, 3, 100, angle, GetRandomReal(10, 80), 0, 1.5)
      Effectcreate("war3mapImported\\Daji_Hong1.mdl", x1, y1, 0, 40, 200, angle, 0, 0, 2)
      local mz2 = false
      for _, xq in ac.selector():in_rangexy(x1, y1, 400 + bs):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        mz2 = true
        zhiguidamageunit(u, xq, 0.6 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 200, angle, false)
      end
      if mz2 then
        zhigui_hlget(u, skillstr)
        zhigui_combo(u)
      end
    end)
  end,
  AEEVEE = function(u)
    local skillstr = "AEEVEE"
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    local x2 = u:getdata("志贵-X")
    local y2 = u:getdata("志贵-Y")
    local angle = AngleXY(x, y, x2, y2)
    u:setface(angle)
    u:setdata("七夜连携", skillstr)
    u:setdata("七夜连携时间", 0.45)
    u:setdata("志贵-E变化时间", 0.45)
    zhiguizantingtime(u, 0.1)
    u:buffset(u.handle, 0.25, "无敌")
    u:buffset(u.handle, 0.1, "绝对闪避")
    ac.wait(0, function()
      u:playseensound(zhigui_zhanji1)
      u:shockcamera(100, 0.15)
      local x1, y1 = PolarXY(x, y, 400, angle)
      local x2, y2 = PolarXY(x, y, 800, angle)
      local sj = GetRandomReal(200, 700)
      local x3, y3 = PolarXY(x, y, sj, angle)
      u:setface(angle)
      u:setxy(x2, y2)
      if u:hasdata("志贵-镜头全锁定") then
        zhiguicamset(u, x2, y2)
      end
      shikianimeact(u, 1, 2)
      Effectcreate("war3mapImported\\qiye_zhanji8.mdl", x3, y3, 0, GetRandomReal(5, 8), 100, GetRandomReal(0, 360), 0, 0, 2)
      sj = GetRandomReal(200, 700)
      x3, y3 = PolarXY(x, y, sj, angle)
      Effectcreate("war3mapImported\\qiye_zhanji8.mdl", x3, y3, 0, GetRandomReal(5, 8), 100, GetRandomReal(0, 360), 0, 0, 2)
      Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x2, y2, 0, 3, 100, angle, 0, 0, 1.5)
      Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x2, y2, 0, 3, 100, angle, GetRandomReal(0, 360), 0, 1.5)
      Effectcreate("war3mapImported\\Daji_Hong1.mdl", x1, y1, 0, 40, 200, angle, 0, 0, 2)
      local mz2 = false
      for _, xq in ac.selector():in_rangexy(x1, y1, 400 + bs):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        mz2 = true
        zhiguidamageunit(u, xq, 0.6 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 100, angle, false)
      end
      if mz2 then
        zhigui_hlget(u, skillstr)
        zhigui_combo(u)
      end
    end)
  end,
  AEEVEEE = function(u)
    local skillstr = "AEEVEEE"
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    local x2 = u:getdata("志贵-X")
    local y2 = u:getdata("志贵-Y")
    local angle = AngleXY(x, y, x2, y2)
    u:setface(angle)
    u:setdata("七夜连携", skillstr)
    u:setdata("七夜连携时间", 0.45)
    u:setdata("志贵-E变化时间", 0.45)
    zhiguizantingtime(u, 0.1)
    u:buffset(u.handle, 0.25, "无敌")
    u:buffset(u.handle, 0.1, "绝对闪避")
    ac.wait(0, function()
      u:playseensound(zhigui_zhanji1)
      u:shockcamera(100, 0.15)
      local x1, y1 = PolarXY(x, y, 400, angle)
      local x2, y2 = PolarXY(x, y, 800, angle)
      local sj = GetRandomReal(200, 700)
      local x3, y3 = PolarXY(x, y, sj, angle)
      u:setface(angle + 180)
      u:setxy(x2, y2)
      if u:hasdata("志贵-镜头全锁定") then
        zhiguicamset(u, x2, y2)
      end
      shikianimeact(u, 1, 2)
      Effectcreate("war3mapImported\\File00000650.mdl", x3, y3, 0, 15, 100, GetRandomReal(0, 360), 0, 0, 2)
      sj = GetRandomReal(200, 700)
      x3, y3 = PolarXY(x, y, sj, angle)
      Effectcreate("war3mapImported\\File00000650.mdl", x3, y3, 0, 15, 100, GetRandomReal(0, 360), 0, 0, 2)
      Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x2, y2, 0, 3, 100, angle, GetRandomReal(10, 80), 0, 1.5)
      Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x2, y2, 0, 3, 100, angle, GetRandomReal(10, 80), 0, 1.5)
      Effectcreate("war3mapImported\\Daji_Hong1.mdl", x1, y1, 0, 40, 200, angle, 0, 0, 2)
      local mz2 = false
      for _, xq in ac.selector():in_rangexy(x1, y1, 400 + bs):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        mz2 = true
        zhiguidamageunit(u, xq, 0.6 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 100, angle, false)
      end
      if mz2 then
        zhigui_hlget(u, skillstr)
        zhigui_combo(u)
      end
    end)
  end,
  AEEVEEEE = function(u)
    local skillstr = "AEEVEEEE"
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    local x2 = u:getdata("志贵-X")
    local y2 = u:getdata("志贵-Y")
    local angle = AngleXY(x, y, x2, y2)
    u:setface(angle)
    u:setdata("七夜连携", skillstr)
    u:setdata("七夜连携时间", 0.45)
    u:setdata("志贵-E变化时间", 0.45)
    zhiguizantingtime(u, 0.1)
    u:buffset(u.handle, 0.25, "无敌")
    u:buffset(u.handle, 0.1, "绝对闪避")
    ac.wait(0, function()
      u:playseensound(zhigui_zhanji1)
      u:shockcamera(100, 0.15)
      local x1, y1 = PolarXY(x, y, 400, angle)
      local x2, y2 = PolarXY(x, y, 800, angle)
      local sj = GetRandomReal(200, 700)
      local x3, y3 = PolarXY(x, y, sj, angle)
      u:setface(angle)
      u:setxy(x2, y2)
      if u:hasdata("志贵-镜头全锁定") then
        zhiguicamset(u, x2, y2)
      end
      shikianimeact(u, 1, 2)
      Effectcreate("war3mapImported\\qiye_zhanji8.mdl", x3, y3, 0, GetRandomReal(5, 8), 100, GetRandomReal(0, 360), 0, 0, 2)
      sj = GetRandomReal(200, 700)
      x3, y3 = PolarXY(x, y, sj, angle)
      Effectcreate("war3mapImported\\qiye_zhanji8.mdl", x3, y3, 0, GetRandomReal(5, 8), 100, GetRandomReal(0, 360), 0, 0, 2)
      Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x2, y2, 0, 3, 100, angle, 0, 0, 1.5)
      Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x2, y2, 0, 3, 100, angle, GetRandomReal(0, 360), 0, 1.5)
      Effectcreate("war3mapImported\\Daji_Hong1.mdl", x1, y1, 0, 40, 200, angle, 0, 0, 2)
      local mz2 = false
      for _, xq in ac.selector():in_rangexy(x1, y1, 400 + bs):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        mz2 = true
        zhiguidamageunit(u, xq, 0.6 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 100, angle, false)
      end
      if mz2 then
        zhigui_hlget(u, skillstr)
        zhigui_combo(u)
      end
    end)
  end,
  AEEVEEEEE = function(u)
    local skillstr = "AEEVEEEEE"
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    local x2 = u:getdata("志贵-X")
    local y2 = u:getdata("志贵-Y")
    local angle = AngleXY(x, y, x2, y2)
    u:setface(angle)
    u:setdata("七夜连携", skillstr)
    u:setdata("七夜连携时间", 0.45)
    u:setdata("志贵-E变化时间", 0.45)
    zhiguizantingtime(u, 0.1)
    u:buffset(u.handle, 0.25, "无敌")
    u:buffset(u.handle, 0.1, "绝对闪避")
    ac.wait(0, function()
      u:playseensound(zhigui_zhanji1)
      u:shockcamera(100, 0.15)
      local x1, y1 = PolarXY(x, y, 400, angle)
      local x2, y2 = PolarXY(x, y, 800, angle)
      local sj = GetRandomReal(200, 700)
      local x3, y3 = PolarXY(x, y, sj, angle)
      u:setface(angle + 180)
      u:setxy(x2, y2)
      if u:hasdata("志贵-镜头全锁定") then
        zhiguicamset(u, x2, y2)
      end
      shikianimeact(u, 1, 2)
      Effectcreate("war3mapImported\\File00000650.mdl", x3, y3, 0, 15, 100, GetRandomReal(0, 360), 0, 0, 2)
      sj = GetRandomReal(200, 700)
      x3, y3 = PolarXY(x, y, sj, angle)
      Effectcreate("war3mapImported\\File00000650.mdl", x3, y3, 0, 15, 100, GetRandomReal(0, 360), 0, 0, 2)
      Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x2, y2, 0, 3, 100, angle, GetRandomReal(10, 80), 0, 1.5)
      Effectcreate("war3mapImported\\qiye_zhanji3.mdl", x2, y2, 0, 3, 100, angle, GetRandomReal(10, 80), 0, 1.5)
      Effectcreate("war3mapImported\\Daji_Hong1.mdl", x1, y1, 0, 40, 200, angle, 0, 0, 2)
      local mz2 = false
      for _, xq in ac.selector():in_rangexy(x1, y1, 400 + bs):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        mz2 = true
        zhiguidamageunit(u, xq, 0.6 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 100, angle, false)
      end
      if mz2 then
        zhigui_hlget(u, skillstr)
        zhigui_combo(u)
      end
    end)
  end,
  AEEVEEEEEE = function(u)
    local skillstr = "AEEVEEEEEE"
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    local x2 = u:getdata("志贵-X")
    local y2 = u:getdata("志贵-Y")
    local angle = AngleXY(x, y, x2, y2)
    u:setface(angle)
    u:setdata("七夜连携", "")
    u:setdata("七夜连携时间", 0.3)
    u:setdata("志贵-E变化时间", 0.0)
    zhiguizantingtime(u, 0.3)
    u:buffset(u.handle, 0.4, "无敌")
    u:buffset(u.handle, 0.1, "绝对闪避")
    local mz = false
    if u:hasdata("志贵-镜头全锁定") then
      zhiguicamlock(u)
    end
    ac.wait(0, function()
      u:playseensound(zhigui_zhanji1)
      u:playseensound(zhigui_suipin)
      u:playseensound(zhigui_bisha3)
      u:shockcamera(100, 0.15)
      local x1, y1 = PolarXY(x, y, 400, angle)
      local x2, y2 = PolarXY(x, y, 800, angle)
      local sj = GetRandomReal(200, 700)
      local x3, y3 = PolarXY(x, y, sj, angle)
      Effectcreate("war3mapImported\\dash sfx.mdl", x2, y2, 0, 2, 100, angle, 0, 0, 3)
      Effectcreate("war3mapImported\\chongci_Bo.mdl", x, y, 0, 2, 100, angle, 0, 0, 1.5)
      Effectcreate("war3mapImported\\File00000650.mdl", x1, y1, 0, 15, 200, angle, 0, 0, 2)
      ac.wait(300, function()
        Effectcreate("war3mapImported\\qiye_zhanji8.mdl", x1, y1, 0, 17, -300, angle, 0, 0, 7)
      end)
      u:setface(angle)
      u:setxy(x2, y2)
      shikianimeact(u, 1, 2)
      Effectcreate("war3mapImported\\qiye_zhanji8.mdl", x3, y3, 0, GetRandomReal(5, 8), 100, GetRandomReal(0, 360), 0, 0, 2)
      sj = GetRandomReal(200, 700)
      x3, y3 = PolarXY(x, y, sj, angle)
      Effectcreate("war3mapImported\\qiye_zhanji8.mdl", x3, y3, 0, GetRandomReal(5, 8), 100, GetRandomReal(0, 360), 0, 0, 2)
      Effectcreate("war3mapImported\\Daji_Hong1.mdl", x1, y1, 0, 40, 200, angle, 0, 0, 2)
      local mz2 = false
      for _, xq in ac.selector():in_rangexy(x1, y1, 400 + bs):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        mz = true
        mz2 = true
        zhiguidamageunit(u, xq, 0.6 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 300, angle, false)
      end
      if mz2 then
        zhigui_combo(u)
      end
      ac.wait(300, function()
        u:shockcamera(100, 0.15)
        Effectcreate("war3mapImported\\qiye_zhanji8.mdl", x3, y3, 0, GetRandomReal(5, 8), 100, GetRandomReal(0, 360), 0, 0, 2)
        sj = GetRandomReal(200, 700)
        x3, y3 = PolarXY(x, y, sj, angle)
        Effectcreate("war3mapImported\\qiye_zhanji8.mdl", x3, y3, 0, GetRandomReal(5, 8), 100, GetRandomReal(0, 360), 0, 0, 2)
        Effectcreate("war3mapImported\\Daji_Hong1.mdl", x1, y1, 0, 40, 200, angle, 0, 0, 2)
        mz2 = false
        for _, xq in ac.selector():in_rangexy(x1, y1, 400 + bs):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          mz = true
          mz2 = true
          zhiguidamageunit(u, xq, 0.75 * sh, 1.5 * kz, "眩晕", txstr1, txstr2, 100, angle, false)
        end
        if mz2 then
          zhigui_combo(u)
        end
        if mz then
          zhigui_hlget(u, skillstr)
        end
        if u:hasdata("志贵-镜头全锁定") then
          zhiguicamunlock(u)
        end
      end)
    end)
  end,
  R2 = function(u, tg)
    local skillstr = "R2"
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    local x1, y1 = tg:getxy()
    local angle = AngleXY(x, y, x1, y1)
    local dis = DistanceXY(x, y, x1, y1)
    u:setface(angle)
    local txsh
    local xh1 = 0.044
    local xh2 = 0.004
    xh2 = 0.007
    txsh = sh * 44.44
    if u:hasdata("志贵-BH状态") then
      u:setdata("志贵-十七分割已释放")
      local add = 0
      if u:hasdata("变异判定-噩梦志贵") or u:hasdata("变异判定-远野志贵") then
        add = add + 0.5
      end
      if u:hasdata("志贵天赋-这就是将事物杀死啊") then
        add = add + 0.5
      end
      xh1 = xh1 * (1 + add)
      xh2 = xh2 * (1 + add)
      txsh = txsh * (1 + add)
    else
      u:setdata("志贵-十七分割已释放")
    end
    u:setdata("七夜连携", "")
    u:setdata("七夜连携时间", 2.1)
    u:buffset(u.handle, 2.1, "暂停")
    u:buffset(u.handle, 2.5, "无敌")
    u:buffset(u.handle, 2.5, "绝对闪避")
    u:buffset(u.handle, 2.5, "永恒")
    zhiguicamlock(u)
    local g2 = CreateGroupLua()
    tg:groupadd(g2)
    for _, xq in ac.selector():in_rangexy(x1, y1, 350):is_enemy(u.handle):ipairs() do
      xq = getunit(xq)
      xq:groupadd(g2)
    end
    ForGroupLuaNew(g2, function(xq)
      xq:buffset(u.handle, 3, "暂停")
      xq:buffset(u.handle, 3, "沉默")
    end)
    local tx = Effectcreate("war3mapImported\\Heiquan.mdx", x1, y1, 4, 0.75, 0, 0, 0, 0, 2)
    ac.wait(100, function()
      SetEffectActSpeed(tx, 0.3)
    end)
    shikianimeact(u, 12, 3)
    unitmove({
      unit = u.handle,
      time = 0.1,
      distance = 400,
      angle = angle + 180,
      isfly = true
    })
    ac.wait(200, function()
      PlayGlobalSound(Sound_214_chongfeng_2)
      Effectcreate("war3mapImported\\chongci_Bo.mdx", x, y, 0, 1, 0, angle + 180, 0, 0, 1)
      ac.wait(200, function()
        play_shadow_slow_series(u, {
          model = "war3mapImported\\Toono shiki.mdl",
          scale = 0.73,
          act = 19,
          count = 28,
          interval = 0.05,
          main_speed = 1,
          wait_time = 0,
          r = 255,
          g = 255,
          b = 255,
          fade_sub = 12,
          noact = true
        })
      end)
      ac.wait(1430, function()
        u:animeact(18)
      end)
      ac.wait(150, function()
        u:setcolor(255, 255, 255, 0)
      end)
      unitmove({
        unit = u.handle,
        time = 0.1,
        distance = dis - 200,
        angle = angle,
        isfly = true,
        endfunc = function()
          PlayGlobalSound(Sound_214_R2)
          unitmove({
            unit = u.handle,
            time = 1.5,
            distance = 100,
            angle = angle,
            isfly = true,
            endfunc = function(dx, dy)
              u:setcolor(255, 255, 255, 255)
              ResetUnitAnimation(u.handle)
              u:animeact(20)
              u:animespeed(1)
              PlayGlobalSound(Sound_214_R3)
              PlayGlobalSound(Sound_214_R4)
              for i = 1, 3 do
                Effectcreate("war3mapImported\\Daji_fen.mdx", x1, y1, 0, 2, 0, GetRandomReal(0, 360))
              end
              Effectcreate("war3mapImported\\Daji_Kuoshan2.mdx", x1, y1, 0, 2, 0, 0, 0, 0, 1.25)
              for i = 1, 17 do
                local x3, y3 = PolarXY(x1, y1, GetRandomReal(-500, 500), GetRandomReal(0, 360))
                Effectcreate("war3mapImported\\File00000650.mdl", x3, y3, 0, GetRandomReal(1, 8), GetRandomReal(100, 400), GetRandomReal(0, 360), GetRandomReal(0, 180), GetRandomReal(-110, -80), GetRandomReal(0.5, 2))
                Effectcreate("war3mapImported\\File00006330.mdl", x3, y3, 0, GetRandomReal(1, 10), GetRandomReal(100, 400), GetRandomReal(0, 360), GetRandomReal(0, 180), GetRandomReal(-110, -80), GetRandomReal(0.5, 2))
              end
              u:shockcamera(20, 0.2)
              local x2, y2 = PolarXY(x1, y1, 200, angle)
              u:setxy(x2, y2)
              u:setdata("位移点X", x2)
              u:setdata("位移点Y", y2)
              zhiguicamunlock(u)
              for _, xq in ac.selector():in_rangexy(dx, dy, 350):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                xq:groupadd(g2)
              end
              if 0 < Group_Counts(g2) then
                PlayGlobalSound(Sound_214_Gongji)
              end
              PlayGlobalSound(Sound_Zhigui_SR)
              SetSoundVolumeBJ(Sound_Zhigui_SR, 75.0)
              u:setdata("志贵-无视伤害免疫时间", 5)
              u:setdata("志贵-无视伤害闪避时间", 5)
              ForGroupLuaNew(g2, function(xq)
                xq:buffset(u.handle, 3, "眩晕")
                xq:effectadd("war3mapImported\\Daji_Hong1.mdx", "head")
                DamageUnit({
                  bj = "志贵(机体)",
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
                if xq:isboss() then
                  LossHpUnit({
                    u = u,
                    tg = xq,
                    perhp = xh1 * 100,
                    bj = "志贵(机体损耗)"
                  })
                end
              end)
              local txsh2 = 0.1 * txsh
              local cs = 0
              ac.loop(10, function(timer)
                cs = cs + 1
                ForGroupLuaNew(g2, function(xq)
                  DamageUnit({
                    bj = "志贵(机体)",
                    unit = xq.handle,
                    source = u.handle,
                    damage = txsh2,
                    level = 1,
                    type = "物理",
                    isvest = true,
                    isattack = true,
                    isnoarmor = false,
                    element = "无"
                  })
                  if xq:isboss() then
                    LossHpUnit({
                      u = u,
                      tg = xq,
                      perhp = xh2 * 100,
                      bj = "志贵(机体损耗)"
                    })
                  end
                end)
                if cs == 16 then
                  timer:remove()
                end
              end)
            end
          })
        end
      })
    end)
  end,
  R3 = function(u, tg)
    local skillstr = "R3"
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    local x1, y1 = tg:getxy()
    local angle = AngleXY(x, y, x1, y1)
    local dis = DistanceXY(x, y, x1, y1)
    u:setface(angle)
    PlayGlobalSound(zhigui_tanfanAll)
    PlayGlobalSound(zhigui_bishaAll)
    PlayGlobalSound(Nanaya_zhandou7All)
    local txsh
    txsh = sh * 77.77
    local xh1 = 0.03 + 0.15 * u:getdata("志贵-连携点数值") / 100
    if u:hasdata("志贵-BH状态") then
      u:setdata("志贵-极死七夜已释放")
      local add = 0
      if u:hasdata("变异判定-噩梦志贵") or u:hasdata("变异判定-远野志贵") then
        add = add + 0.5
      end
      if u:hasdata("志贵天赋-知道要去哪里了吗") then
        add = add + 0.5
      end
      xh1 = xh1 * (1 + add)
      txsh = txsh * (1 + add)
    else
      u:setdata("志贵-极死七夜已释放")
    end
    local zscd = false
    if u:hasdata("变异判定-七夜志贵") or u:hasdata("变异判定-噩梦志贵") then
      local dsh = xh1 * tg:getmaxhp()
      if tg:isboss() and (dsh >= tg:gethp() or tg:getperhp() <= 7) or tg:isingroup(Group_PlayHero) then
        zscd = true
        PlayGlobalSound()
        PlayBGM({
          bgm = BGM_Nanaya_Zs,
          time = 55,
          ID = 143,
          unit = u.handle
        })
        musiccolortext({
          strz = {
            {
              str = "プリズムを通した",
              time = 0,
              showtexttime = 1.5
            },
            {
              str = "世界の色も褪せ",
              time = 3.7,
              showtexttime = 1.5
            },
            {
              str = "こんな灰色に",
              time = 7.2,
              showtexttime = 1.5
            },
            {
              str = "すべて埋ずもれても",
              time = 10.6,
              showtexttime = 1.5
            },
            {
              str = "僕ならばできる",
              time = 14.6,
              showtexttime = 1.5
            },
            {
              str = "たとえひとりだって",
              time = 18.2,
              showtexttime = 1.5
            },
            {
              str = "未來にまた塗りかえてみせるよ",
              time = 22,
              showtexttime = 4
            }
          },
          colorstart = "00FFFFFF",
          colorend = "FF5263FF"
        })
      end
    end
    u:setdata("志贵-超必杀附伤", xh1)
    u:setdata("七夜连携", "")
    u:setdata("七夜连携时间", 1.5)
    zhiguicamlock(u)
    x, y = PolarXY(x, y, -200, angle)
    shikianimeact(u, 9, 1)
    local dt1 = 0.5
    local dt2 = 0.7
    if zscd then
      u:buffset(u.handle, 7, "暂停")
      u:buffset(u.handle, 10, "无敌")
      u:buffset(u.handle, 10, "绝对闪避")
      u:buffset(u.handle, 10, "永恒")
      tg:buffset(u.handle, 15, "暂停")
      tg:buffset(u.handle, 15, "沉默")
      dt1 = 1
      dt2 = 1.4
    else
      u:buffset(u.handle, 1.3, "暂停")
      u:buffset(u.handle, 1.7, "无敌")
      u:buffset(u.handle, 1.7, "绝对闪避")
      u:buffset(u.handle, 1.7, "永恒")
      tg:buffset(u.handle, 1.7, "暂停")
      tg:buffset(u.handle, 1.7, "沉默")
    end
    ac.wait(200, function()
      if zscd then
        u:animespeed(0.25)
      else
        u:animespeed(0.5)
      end
      x, y = u:getxy()
      Effectcreate("war3mapImported\\Daji_Hong1.mdl", x, y, 0, 10, 200, angle, 0, 0, 1)
    end)
    ac.wait(dt1 * 1000, function()
      if zscd then
        PanCameraToTimed(x1, y1, 0)
      end
      PlayGlobalSound(zhigui_feidaoAll)
      u:animespeed(1)
      local tx = Effectcreate("war3mapImported\\bishou.mdl", x, y, 0.2, 1, 150, angle, 0, 0, 2)
      effectmove({
        effect = tx,
        time = 0.1,
        distance = dis + 350,
        angle = angle,
        endfunc = function()
          unitmove({
            unit = tg.handle,
            time = 0.02,
            distance = 200,
            angle = angle,
            isfly = Nandu_Choose <= 4,
            endfunc = function()
              x, y = tg:getxy()
              u:setxy(x, y)
              if zscd then
                tg:buffset(u.handle, 6, "锁定")
              else
                tg:buffset(u.handle, 1, "锁定")
              end
              PlayGlobalSound(zhigui_daji1All)
              Effectcreate("war3mapImported\\Daji_Hong1.mdl", x, y, 0, 4, 200, angle, 0, 0, 1)
              CameraSetEQNoiseForPlayer(LocalPlayer, 10)
              ac.wait(150.0, function()
                CameraClearNoiseForPlayer(LocalPlayer)
              end)
              ac.wait(dt2 * 1000, function()
                PlayGlobalSound(zhigui_bisha3All)
                PlayGlobalSound(zhigui_zhanji3)
                PlayGlobalSound(Nanaya_zhandou6All)
                CameraSetEQNoiseForPlayer(LocalPlayer, 200)
                ac.wait(200.0, function()
                  CameraClearNoiseForPlayer(LocalPlayer)
                end)
                if zscd then
                  flashphoto({
                    photo = "war3mapImported\\Ph_Nanaya_Zs.tga",
                    timeout = 1,
                    timehold = 3,
                    timein = 3
                  })
                  Effectcreate("war3mapImported\\qiye_xialuo1.mdl", x, y, 0, 2, -50, angle, 0, 0, 2)
                  Effectcreate("war3mapImported\\qiye_zhanji6.mdl", x, y, 0, 1, 0, angle, 0, 0, 1)
                  tg:animeact("death")
                  ac.wait(500, function()
                    tg:animespeed(0)
                  end)
                  ac.wait(1000, function()
                    local x2, y2 = tg:getxy()
                    x2, y2 = PolarXY(x2, y2, -100, angle)
                    u:setxy(x2, y2)
                  end)
                  ac.wait(4000, function()
                    PlayGlobalSound(Sound_Nanaya_Zs2)
                    local tgname
                    if tg:isingroup(Group_PlayHero) then
                      tgname = NameID[tg.ownerid]
                    else
                      tgname = tg:getname()
                    end
                    SendMsgAll(NameID[u.ownerid] .. "|cFFCC0000:『|r" .. tgname .. "|cFFCC0000，知道要去哪里了吗？如果是下地狱的话，代我向阎王问好。』|r")
                    if tg:isingroup(Group_PlayHero) then
                      tg:kill(u.handle, true)
                    else
                      u:setdata("志贵-超必杀斩杀")
                      tg:clearbuff("无敌")
                      DamageUnit({
                        bj = "志贵(机体)",
                        unit = tg.handle,
                        source = u.handle,
                        damage = 1,
                        level = 1,
                        type = "物理",
                        isvest = false,
                        isattack = true,
                        isnoarmor = false,
                        element = "无"
                      })
                      u:deldata("志贵-超必杀斩杀")
                    end
                    x, y = tg:getxy()
                    for i = 1, 5 do
                      Effectcreate("war3mapImported\\qiye_baoxue2.mdl", x, y, 0, 3, 0, angle, 0, 0, 1)
                      Effectcreate("war3mapImported\\qiye_nanaya_xue1.mdl", x, y, 0, 3, 0, angle, 0, 0, 1)
                    end
                    Effectcreate("war3mapImported\\qiye_baoxue2.mdl", x, y, 0, 2, 0, angle, 0, 0, 1)
                    Effectcreate("war3mapImported\\qiye_nanaya_xue1.mdl", x, y, 0, 3, 0, angle, 0, 0, 1)
                    Effectcreate("war3mapImported\\qiye_xialuo1.mdl", x, y, 0, 2, -50, angle, 0, 0, 2)
                    Effectcreate("war3mapImported\\qiye_zhanji6.mdl", x, y, 0, 1, 0, angle, 0, 0, 1)
                    zhiguicamunlock(u)
                  end)
                else
                  u:setdata("志贵-无视伤害免疫时间", 5)
                  u:setdata("志贵-无视伤害闪避时间", 5)
                  if tg:isboss() then
                    u:setdata("志贵-超必杀伤害")
                    DamageUnit({
                      bj = "志贵(机体)",
                      unit = tg.handle,
                      source = u.handle,
                      damage = txsh,
                      level = 1,
                      type = "物理",
                      isvest = false,
                      isattack = true,
                      isnoarmor = false,
                      element = "无"
                    })
                    tg:buffset(u.handle, 5, "眩晕")
                  else
                    tg:kill(u.handle, true)
                  end
                  x, y = tg:getxy()
                  for i = 1, 5 do
                    Effectcreate("war3mapImported\\qiye_baoxue2.mdl", x, y, 0, 3, 0, angle, 0, 0, 1)
                    Effectcreate("war3mapImported\\qiye_nanaya_xue1.mdl", x, y, 0, 3, 0, angle, 0, 0, 1)
                  end
                  Effectcreate("war3mapImported\\qiye_baoxue2.mdl", x, y, 0, 2, 0, angle, 0, 0, 1)
                  Effectcreate("war3mapImported\\qiye_nanaya_xue1.mdl", x, y, 0, 3, 0, angle, 0, 0, 1)
                  Effectcreate("war3mapImported\\qiye_xialuo1.mdl", x, y, 0, 2, -50, angle, 0, 0, 2)
                  Effectcreate("war3mapImported\\qiye_zhanji6.mdl", x, y, 0, 1, 0, angle, 0, 0, 1)
                  zhiguicamunlock(u)
                end
              end)
            end
          })
        end
      })
    end)
  end
}
return zgskill
