-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local message = require("jass.message")
local ljshjz

local function set(u, skillstr)
  local sh = u:getdata("角色基础伤害")
  local bs = u:getdata("两仪式-伤害范围加成")
  local txstr1, txstr2
  txstr1 = "war3mapImported\\zhigui_daji5.mdl"
  txstr2 = "origin"
  if u:hasdata("两仪式-爆气状态") then
    txstr1 = "daji_hong1.mdl"
    txstr2 = "chest"
  end
  sh = ljshjz(u, sh, skillstr)
  local x, y = u:getxy()
  local sy = u.ownerid
  local kz = u:getdata("两仪式-控制时间")
  u:setdata("两仪式连携", "")
  return sh, bs, txstr1, txstr2, x, y, sy, kz
end

local function extratilixh(u, skillstr)
  local xh = u:getdata("两仪式-额外体力消耗-" .. skillstr)
  u:lossstamina(xh)
  local xhadd = 0.8
  local len = string.len(skillstr)
  if u:hasdata("两仪式天赋-忘却录音") then
    xhadd = xhadd * 0.7
  end
  if len == 3 then
    xhadd = xhadd * 3
  end
  if len == 4 then
    xhadd = xhadd * 4
  end
  u:changedata("两仪式-额外体力消耗-" .. skillstr, xhadd)
end

local function zhigui_combo(u)
  u:changedata("两仪式-连击数", 1)
  local lj = u:getdata("两仪式-连击数")
  local str
  str = "|cFFFFFF00" .. math.floor(lj) .. "|r |cFFFF9900hit"
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
  if not u:hasdata("两仪式-回路获取-" .. skillstr) then
    u:setdata("两仪式-回路获取-" .. skillstr)
    add = u:getdata("两仪式-回路获取")
    add2 = u:getdata("两仪式-连击伤害获取")
  end
  u:changedata("两仪式-魔术回路值", add)
  if u:hasdata("EEEV回路已获取") and skillstr == "EEEV" then
  elseif string.sub(skillstr, -1) == "V" then
    u:changedata("两仪式-连携点数值", 10)
  end
  if string.len(skillstr) >= 4 and string.sub(skillstr, -1) == "E" then
    u:changedata("两仪式-连携点数值", 1)
  end
end

local function lianxie(u, skillstr, extime)
  ac.wait(1, function()
    u:setdata("两仪式连携", skillstr)
  end)
  extime = extime or 0
  local t = 0.8
  local t2 = 0.5
  if u:hasdata("两仪式天赋-忘却录音") then
    u:setdata("两仪式连携时间", extime + t2)
  else
    u:setdata("两仪式连携时间", extime + t * u:getdata("两仪式-连锁时间"))
  end
  if u:hasdata("两仪式-手搓模式") and (skillstr == "AAE" or skillstr == "EEE" or skillstr == "EEA" or skillstr == "AEA" or skillstr == "EAE") then
    u:setdata("两仪式-V变化时间", extime + t * u:getdata("两仪式-连锁时间"))
  end
end

local function shikianimeact(u, value, speed)
  ac.wait(1, function()
    ResetUnitAnimation(u.handle)
    u:animespeed(speed)
    u:animeact(value)
  end)
end

local function zhiguidamageunit(args)
  local u = args.u
  local xq = args.xq
  local sh = args.sh or 0
  local kz = args.kz or 0
  local kzlx = args.kzlx or "僵直"
  local txstr1 = args.txstr1
  local txstr2 = args.txstr2
  local isvest = args.isvest or false
  local jtjl = args.jtjl or 0
  local jtjd = args.jtjd or 0
  local jtsj = args.jtsj or 0
  local skillstr = args.skillstr or ""
  xq:effectadd(txstr1, txstr2)
  if kz ~= 0 then
    xq:buffset(u.handle, kz, kzlx)
  end
  if sh ~= 0 then
    DamageUnit({
      bj = "两仪式(机体)",
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
    if u:hasdata("两仪式天赋-伽蓝之洞") then
      local combo = u:getdata("两仪式-连击数")
      local sunhao = 0
      if 75 <= combo then
        if xq:isnormal() then
          sunhao = 0.01 * xq:getmaxhp()
        else
          sunhao = 5.0E-4 * xq:getmaxhp()
        end
      elseif 50 <= combo then
        if xq:isnormal() then
          sunhao = 0.01 * xq:gethp()
        else
          sunhao = 5.0E-4 * xq:gethp()
        end
      elseif 25 <= combo then
        if xq:isnormal() then
          sunhao = 0.005 * xq:gethp()
        else
          sunhao = 2.5E-4 * xq:gethp()
        end
      end
      if 0 < u:getdata("两仪式-爆气时间") then
        sunhao = sunhao * 2
      end
      if u:hasdata("变异判定-根源式") then
        sunhao = sunhao * 1.5
      end
      if 0 < sunhao then
        LossHpUnit({
          u = u,
          tg = xq,
          damage = sunhao,
          bj = "两仪式(伽蓝之洞损耗)"
        })
      end
    end
  end
  if 0 < jtjl then
    unitmove({
      unit = xq.handle,
      time = jtsj,
      distance = jtjl,
      angle = jtjd,
      isfly = true
    })
  end
end

local function zhiguicamlock(u)
  if not u:hasdata("两仪式-禁止镜头锁定") then
    SetCameraTargetControllerNoZForPlayer(u.owner, u.handle, 0, 0, false)
  end
end

local function zhiguicamunlock(u)
  if not u:hasdata("两仪式-禁止镜头锁定") then
    ac.wait(10, function()
      ResetToGameCameraForPlayer(u.owner, 0)
      local p = getplayer(u.owner)
      p:setcameraheight(Cam_height[u.ownerid], 0)
    end)
  end
end

local function zhiguizantingtime(u, time)
  if u:hasdata("两仪式-强断连招开启") then
    u:setdata("两仪式连招暂停时间", math.max(u:getdata("两仪式连招暂停时间"), time))
  else
    u:buffset(u.handle, time, "暂停")
  end
end

local function zhiguicamset(u, x, y)
  if not u:hasdata("两仪式-禁止镜头锁定") then
    getplayer(u.owner):setcamera(x, y, 0)
  end
end

local function zhiguishockcamera(u, qd, time)
  if not u:hasdata("两仪式-关闭镜头摇晃") then
    u:shockcamera(qd, time)
  end
end

function ljshjz(u, sh, skillstr)
  local add = 0.01 * u:getdata("两仪式-连击数")
  local bl = 1
  if skillstr == "EEAV" or skillstr == "AAAV" then
    bl = 1.5
  end
  if skillstr == "AAEV" then
    bl = 1.75
  end
  if skillstr == "AEAV" or skillstr == "AEEV" or skillstr == "EEEV" or skillstr == "EAAV" then
    bl = 2
  end
  if skillstr == "EAEV" then
    bl = 8
    if u:hasdata("两仪式天赋-唯识.直死魔眼") then
      bl = bl * 2
    end
  end
  if skillstr == "R2" then
    bl = 6
  end
  if skillstr == "R3" then
    bl = 12
  end
  if skillstr == "VD" then
    bl = 15
  end
  local add2 = 1
  if u:hasdata("变异判定-两仪式") then
    add2 = add2 + 0.25
  end
  if u:hasdata("两仪式天赋-伽蓝之洞") then
    if string.sub(skillstr, -1) == "V" then
      add2 = add2 + 1
    else
      add2 = add2 + 0.5
    end
  end
  sh = sh * (1 + add * add2 * bl)
  return sh
end

local zgskill = {
  QW = function(u)
    local skillstr = "QW"
    local angle = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    u:setdata("两仪式-QW阻止Q位移")
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
      endfunc = function(dx, dy)
        zhiguicamset(u, dx, dy)
        dx, dy = PolarXY(dx, dy, 50, angle)
        u:setdata("两仪式连携", "")
        u:deldata("两仪式-QW阻止Q位移")
        ForGroupLuaNew(g2, function(xq)
          if not xq:hasdata("免疫击退效果") then
            xq:setxy(dx, dy)
          end
        end)
      end
    })
  end,
  EE = function(u)
    local skillstr = "EE"
    local x, y = u:getxy()
    local x2 = u:getdata("两仪式-X")
    local y2 = u:getdata("两仪式-Y")
    local jd = AngleXY(x, y, x2, y2)
    u:setface(jd)
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    extratilixh(u, skillstr)
    ac.wait(205, function()
      local dx, dy = u:getxy()
      zhiguicamset(u, dx, dy)
    end)
    local zttime = 0.2
    lianxie(u, skillstr, zttime + 0.2)
    zhiguizantingtime(u, zttime)
    u:buffset(u.handle, zttime, "无敌")
    local kzlx = "僵直"
    local txsh = sh * 1
    local txsh2 = sh * 0.1
    local mz = false
    ac.wait(1, function()
      u:animeact(5)
      u:animespeed(2.0)
      u:playsound(Sound_214_qianghua_E)
      u:playsound(Sound_214_chongfeng_2)
    end)
    ac.wait(100, function()
      zhiguishockcamera(u, 100, 0.2)
      local x1, y1 = PolarXY(x, y, 900, jd)
      EffectcreateArgs({
        effect = "war3mapImported\\214_bishou1.mdx",
        x = x1,
        y = y1,
        size = 5,
        height = 100,
        zxz = jd,
        animespeed = 2.0
      })
      EffectcreateArgs({
        effect = "war3mapImported\\dash sfx.mdx",
        x = x1,
        y = y1,
        size = 2,
        zxz = jd,
        animespeed = 3.0
      })
      EffectcreateArgs({
        effect = "war3mapImported\\bbb.mdx",
        x = x,
        y = y,
        size = 2,
        zxz = jd,
        animespeed = 1.0
      })
      local g = CreateGroupLua()
      local mz2 = false
      unitmove({
        unit = u.handle,
        time = 0.1,
        distance = 2000,
        angle = jd,
        isfly = true,
        loops = {
          {
            looptime = 0.01,
            func = function(dx, dy)
              for _, xq in ac.selector():in_rangexy(dx, dy, 225):isnotingroup(g):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                mz = true
                if not mz2 then
                  mz2 = true
                  zhigui_combo(u)
                  zhiguishockcamera(u, 100, 0.15)
                end
                xq:groupadd(g)
                zhiguidamageunit({
                  skillstr = skillstr,
                  u = u,
                  xq = xq,
                  sh = txsh,
                  kz = kz,
                  kzlx = "僵直",
                  txstr1 = txstr1,
                  txstr2 = txstr2,
                  isvest = false,
                  jtjl = 25,
                  jtjd = jd,
                  jtsj = 0.1
                })
              end
            end
          }
        }
      })
    end)
  end,
  AE = function(u)
    local skillstr = "AE"
    local jd = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    extratilixh(u, skillstr)
    zhiguicamlock(u)
    ac.wait(401, function()
      zhiguicamunlock(u)
    end)
    local zttime = 0.4
    lianxie(u, skillstr, zttime + 0.2)
    zhiguizantingtime(u, zttime)
    u:buffset(u.handle, zttime + u:getdata("两仪式-额外无敌时间"), "无敌")
    local txsh = sh * 0.5
    local mz = false
    ac.wait(1, function()
      u:animeact(15)
      u:animespeed(2.0)
      u:playsound(Sound_214_chongfeng_2)
      u:playsound(Sound_214_T6)
    end)
    unitmove({
      unit = u.handle,
      time = 0.5,
      distance = 500,
      angle = jd,
      isfly = true,
      loops = {
        {
          looptime = 0.02,
          func = function(dx, dy, args)
            if u:hasdata("两仪式-强断连招") then
              args.stop = true
              return
            end
          end
        }
      }
    })
    local mz2 = false
    local cs = 0
    ac.loop(100, function(timer)
      if u:hasdata("两仪式-强断连招") then
        timer:remove()
        return
      end
      cs = cs + 1
      if cs == 1 then
        x, y = u:getxy()
        for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          if not mz2 then
            mz = true
            mz2 = true
            zhigui_combo(u)
            zhiguishockcamera(u, 100, 0.15)
          end
          zhiguidamageunit({
            skillstr = skillstr,
            u = u,
            xq = xq,
            sh = txsh,
            kz = kz,
            kzlx = "僵直",
            txstr1 = txstr1,
            txstr2 = txstr2,
            isvest = false,
            jtjl = 100,
            jtjd = jd,
            jtsj = 0.1
          })
        end
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 1,
          zxz = jd,
          xxz = 10,
          animespeed = 1.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 1,
          zxz = jd,
          xxz = 10,
          animespeed = 1.0
        })
      end
      if cs == 2 then
        x, y = u:getxy()
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 2,
          height = 150,
          zxz = jd + 180,
          xxz = 10,
          animespeed = 1.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 2,
          height = 150,
          zxz = jd + 180,
          xxz = 10,
          animespeed = 1.0
        })
      end
      if cs == 3 then
        x, y = u:getxy()
        u:playsound(Sound_214_T6)
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          if not mz2 then
            mz = true
            mz2 = true
            zhigui_combo(u)
            zhiguishockcamera(u, 100, 0.15)
          end
          zhiguidamageunit({
            skillstr = skillstr,
            u = u,
            xq = xq,
            sh = txsh,
            kz = kz,
            kzlx = "僵直",
            txstr1 = txstr1,
            txstr2 = txstr2,
            isvest = false,
            jtjl = 100,
            jtjd = jd,
            jtsj = 0.1
          })
        end
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 3,
          height = 300,
          zxz = jd,
          xxz = 10,
          animespeed = 1.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 3,
          height = 300,
          zxz = jd,
          xxz = 10,
          animespeed = 1.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\214_chongjibo.mdx",
          x = x,
          y = y,
          size = 2,
          height = -10,
          zxz = jd,
          animespeed = 1.0
        })
      end
      if cs == 4 then
        x, y = u:getxy()
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          if not mz2 then
            mz = true
            mz2 = true
            zhigui_combo(u)
            zhiguishockcamera(u, 100, 0.15)
          end
          zhiguidamageunit({
            skillstr = skillstr,
            u = u,
            xq = xq,
            sh = txsh,
            kz = kz,
            kzlx = "僵直",
            txstr1 = txstr1,
            txstr2 = txstr2,
            isvest = false,
            jtjl = 100,
            jtjd = jd,
            jtsj = 0.1
          })
        end
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 4,
          height = 450,
          zxz = jd + 180,
          xxz = 10,
          animespeed = 1.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 4,
          height = 450,
          zxz = jd + 180,
          xxz = 10,
          animespeed = 1.0
        })
      end
      if cs == 4 then
        if mz then
          zhigui_hlget(u, skillstr)
        end
        timer:remove()
      end
    end)
  end,
  EA = function(u)
    local skillstr = "EA"
    local jd = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    extratilixh(u, skillstr)
    local zttime = 0.4
    lianxie(u, skillstr, zttime)
    zhiguizantingtime(u, zttime)
    u:buffset(u.handle, zttime + u:getdata("两仪式-额外无敌时间"), "无敌")
    local txsh = sh * 0.2
    local mz = false
    local cs1 = 0
    ac.loop(80, function(t1)
      if u:hasdata("两仪式-强断连招") then
        t1:remove()
        return
      end
      cs1 = cs1 + 1
      ac.wait(1, function()
        u:animeact(11)
        u:animespeed(2.5)
      end)
      local tx = EffectcreateArgs({
        effect = "war3mapImported\\214_bishou2.mdx",
        x = x,
        y = y,
        time = -1,
        size = 1,
        height = GetRandomReal(0, 200),
        zxz = jd,
        animespeed = 1.0
      })
      EffectShowAll(tx)
      local cs = 0
      local x1, y1 = x, y
      local g = CreateGroupLua()
      local mz2 = false
      ac.loop(10, function(t)
        cs = cs + 1
        x1, y1 = PolarXY(x1, y1, 100, jd)
        if cs < 20 then
          japi.EXSetEffectXY(tx, x1, y1)
          for _, xq in ac.selector():in_rangexy(x1, y1, 150):is_enemy(u.handle):isnotingroup(g):ipairs() do
            xq = getunit(xq)
            xq:groupadd(g)
            if not mz then
              mz = true
              zhigui_hlget(u, skillstr)
            end
            if not mz2 then
              mz2 = true
              zhigui_combo(u)
              zhiguishockcamera(u, 100, 0.15)
            end
            zhiguidamageunit({
              skillstr = skillstr,
              u = u,
              xq = xq,
              sh = txsh,
              kz = kz,
              kzlx = "僵直",
              txstr1 = txstr1,
              txstr2 = txstr2,
              isvest = false,
              jtjl = 25,
              jtjd = jd,
              jtsj = 0.1
            })
          end
        end
        if 25 <= cs then
          DestroyEffectLua(tx)
          t:remove()
        end
      end)
      if 5 <= cs1 then
        t1:remove()
      end
    end)
  end,
  AA = function(u)
    local skillstr = "AA"
    local jd = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    extratilixh(u, skillstr)
    lianxie(u, skillstr)
    local txsh = sh * 1
    local mz = false
    ac.wait(1, function()
      u:animeact(2)
      u:animespeed(2.0)
      u:playsound(Sound_214_Q2)
      u:playsound(Sound_214_Gongji)
    end)
    unitmove({
      unit = u.handle,
      time = 0.1,
      distance = 100,
      angle = jd,
      isfly = true
    })
    ac.wait(110, function()
      x, y = u:getxy()
      EffectcreateArgs({
        effect = "war3mapImported\\214_zhanji_bai.mdx",
        x = x,
        y = y,
        size = 6,
        height = 150,
        zxz = jd + 45,
        xxz = -20,
        animespeed = 0.7
      })
      local mz2 = false
      for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        if not mz2 then
          mz = true
          mz2 = true
          zhigui_combo(u)
          zhiguishockcamera(u, 100, 0.15)
        end
        zhiguidamageunit({
          skillstr = skillstr,
          u = u,
          xq = xq,
          sh = txsh,
          kz = kz,
          kzlx = "僵直",
          txstr1 = txstr1,
          txstr2 = txstr2,
          isvest = false,
          jtjl = 50,
          jtjd = jd,
          jtsj = 0.1
        })
      end
      if mz then
        zhigui_hlget(u, skillstr)
      end
    end)
  end,
  EAE = function(u)
    local skillstr = "EAE"
    local jd = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    extratilixh(u, skillstr)
    local zttime = 0.1
    lianxie(u, skillstr, zttime)
    zhiguizantingtime(u, zttime)
    local txsh = sh * 0.25
    local txsh2 = sh * 0.5
    local txsh3 = sh * 1
    local mz = false
    ac.wait(1, function()
      u:animeact(3)
      u:animespeed(2.5)
      u:playsound(Sound_214_Gongji)
    end)
    local tx = EffectcreateArgs({
      effect = "war3mapImported\\214_bishou2.mdx",
      x = x,
      y = y,
      time = -1,
      size = 1,
      height = 100,
      zxz = jd,
      animespeed = 1.0
    })
    EffectShowAll(tx)
    local cs = 0
    ac.loop(10, function(t)
      cs = cs + 1
      x, y = PolarXY(x, y, 100, jd)
      if cs < 20 then
        japi.EXSetEffectXY(tx, x, y)
        local mb
        for _, xq in ac.selector():in_rangexy(x, y, 200):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          mb = xq
        end
        if mb ~= nil then
          do
            local x2, y2 = mb:getxy()
            EffectcreateArgs({
              effect = "5dab9b48c482691b.mdl",
              x = x2,
              y = y2,
              size = 4,
              zxz = GetRandomAngle()
            })
            mz = true
            zhigui_combo(u)
            zhiguishockcamera(u, 100, 0.15)
            for _, xq in ac.selector():in_rangexy(x2, y2, 200):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              zhiguidamageunit({
                skillstr = skillstr,
                u = u,
                xq = xq,
                sh = txsh,
                kz = kz,
                kzlx = "僵直",
                txstr1 = txstr1,
                txstr2 = txstr2,
                isvest = false,
                jtjl = 50,
                jtjd = jd,
                jtsj = 0.1
              })
            end
            DestroyEffectLua(tx)
            local zttime = 0.3
            lianxie(u, skillstr, zttime)
            zhiguizantingtime(u, zttime)
            u:buffset(u.handle, zttime + u:getdata("两仪式-额外无敌时间"), "无敌")
            local dcs = 0
            ac.loop(100, function(timer)
              if u:hasdata("两仪式-强断连招") then
                timer:remove()
                return
              end
              dcs = dcs + 1
              if dcs == 1 then
                u:playsound(Sound_214_qianghua_W1)
                u:playsound(Sound_214_Gongji)
                local x1, y1 = mb:getxy()
                u:animeact(5)
                u:animespeed(2.5)
                EffectcreateArgs({
                  effect = "war3mapImported\\daji_hong1.mdx",
                  x = x1,
                  y = y1,
                  size = 40,
                  height = 150,
                  zxz = jd,
                  animespeed = 6.0
                })
                EffectcreateArgs({
                  effect = "war3mapImported\\bbb.mdx",
                  x = x1,
                  y = y1,
                  size = 2,
                  zxz = jd,
                  animespeed = 1.2
                })
                EffectcreateArgs({
                  effect = "war3mapImported\\dash sfx.mdx",
                  x = x1,
                  y = y1,
                  size = 2,
                  zxz = jd,
                  animespeed = 3.0
                })
                local tx = EffectcreateArgs({
                  effect = "war3mapImported\\214_bishou1.mdx",
                  x = x1,
                  y = y1,
                  size = 10.0,
                  zxz = jd,
                  animespeed = 2.0
                })
                if type(japi.EXSetEffectColor) == "function" then
                  japi.EXSetEffectColor(tx, 4294901760)
                end
                tx = EffectcreateArgs({
                  effect = "war3mapImported\\qiye_zhanji8.mdx",
                  x = x1,
                  y = y1,
                  size = 10.0,
                  zxz = jd,
                  animespeed = 2.0
                })
                if type(japi.EXSetEffectColor) == "function" then
                  japi.EXSetEffectColor(tx, 4294901760)
                end
                zhiguishockcamera(u, 600, 0.15)
                u:setxy(x1, y1)
                local dx, dy = PolarXY(x1, y1, 200, jd)
                zhigui_combo(u)
                for _, xq in ac.selector():in_rangexy(dx, dy, 200):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  mb:setxy(dx, dy)
                  zhiguidamageunit({
                    skillstr = skillstr,
                    u = u,
                    xq = xq,
                    sh = txsh2,
                    kz = kz,
                    kzlx = "僵直",
                    txstr1 = txstr1,
                    txstr2 = txstr2,
                    isvest = false
                  })
                end
              end
              if dcs == 3 then
                u:animeact(18)
                u:animespeed(1.2)
                u:playsound(Sound_214_R3)
                local x1, y1 = u:getxy()
                for i = 1, 3 do
                  EffectcreateArgs({
                    effect = "war3mapImported\\214_zhanji_bai.mdx",
                    x = x1,
                    y = y1,
                    size = 8.0,
                    zxz = jd - 30,
                    animespeed = 1.0
                  })
                end
                local dx, dy = PolarXY(x1, y1, 500, jd)
                EffectcreateArgs({
                  effect = "5dab9b48c482691b.mdl",
                  x = x1,
                  y = y1,
                  size = 10,
                  height = -200,
                  zxz = GetRandomAngle()
                })
                zhiguishockcamera(u, 600, 0.15)
                zhigui_combo(u)
                for _, xq in ac.selector():in_rangexy(x1, y1, 200):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  xq:setxy(dx, dy)
                  zhiguidamageunit({
                    skillstr = skillstr,
                    u = u,
                    xq = xq,
                    sh = txsh2,
                    kz = kz,
                    kzlx = "僵直",
                    txstr1 = txstr1,
                    txstr2 = txstr2,
                    isvest = false
                  })
                end
                zhiguicamset(u, x1, y1)
                zhigui_hlget(u, skillstr)
              end
              if dcs == 3 then
                timer:remove()
              end
            end)
            t:remove()
          end
        end
      end
      if 25 <= cs then
        DestroyEffectLua(tx)
        t:remove()
      end
    end)
  end,
  EEE = function(u)
    local skillstr = "EEE"
    local x, y = u:getxy()
    local x2 = u:getdata("两仪式-X")
    local y2 = u:getdata("两仪式-Y")
    local jd = AngleXY(x, y, x2, y2)
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    extratilixh(u, skillstr)
    ac.wait(205, function()
      local dx, dy = u:getxy()
      zhiguicamset(u, dx, dy)
    end)
    local zttime = 0.2
    lianxie(u, skillstr, zttime)
    zhiguizantingtime(u, zttime)
    u:buffset(u.handle, zttime, "无敌")
    local mz = false
    local txsh = sh * 1
    local txsh2 = sh * 0.5
    x, y = u:getxy()
    u:setface(jd)
    ac.wait(1, function()
      u:animeact(5)
      u:animespeed(2.0)
      u:playsound(Sound_214_W)
      u:playsound(Sound_214_chongfeng_2)
    end)
    ac.wait(100, function()
      zhiguishockcamera(u, 100, 0.2)
      local x1, y1 = PolarXY(x, y, 900, jd)
      EffectcreateArgs({
        effect = "war3mapImported\\214_bishou1.mdx",
        x = x1,
        y = y1,
        size = 5,
        height = 100,
        zxz = jd,
        animespeed = 2.0
      })
      EffectcreateArgs({
        effect = "war3mapImported\\dash sfx.mdx",
        x = x1,
        y = y1,
        size = 2,
        zxz = jd,
        animespeed = 3.0
      })
      EffectcreateArgs({
        effect = "war3mapImported\\bbb.mdx",
        x = x,
        y = y,
        size = 2,
        zxz = jd,
        animespeed = 1.0
      })
      x1, y1 = PolarXY(x, y, 900, jd + 45)
      EffectcreateArgs({
        effect = "war3mapImported\\214_bishou1.mdx",
        x = x1,
        y = y1,
        size = 5,
        height = 500,
        zxz = jd - 45,
        yxz = 30,
        animespeed = 3.0
      })
      x1, y1 = PolarXY(x, y, 900, jd - 45)
      EffectcreateArgs({
        effect = "war3mapImported\\214_bishou1.mdx",
        x = x1,
        y = y1,
        size = 5,
        height = 500,
        zxz = jd + 45,
        yxz = 30,
        animespeed = 3.0
      })
      local g = CreateGroupLua()
      local mz2 = false
      unitmove({
        unit = u.handle,
        time = 0.1,
        distance = 2000,
        angle = jd,
        isfly = true,
        loops = {
          {
            looptime = 0.01,
            func = function(dx, dy)
              for _, xq in ac.selector():in_rangexy(dx, dy, 225):isnotingroup(g):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                mz = true
                if not mz2 then
                  mz2 = true
                  zhigui_combo(u)
                  zhiguishockcamera(u, 100, 0.15)
                end
                xq:groupadd(g)
                zhiguidamageunit({
                  skillstr = skillstr,
                  u = u,
                  xq = xq,
                  sh = txsh,
                  kz = kz,
                  kzlx = "僵直",
                  txstr1 = txstr1,
                  txstr2 = txstr2,
                  isvest = false,
                  jtjl = 25,
                  jtjd = jd,
                  jtsj = 0.1
                })
              end
            end
          }
        }
      })
    end)
    ac.wait(100, function()
      local cs1 = 0
      local x1, y1 = x, y
      for i = 1, 10 do
        local mz2 = false
        local sj = jd + GetRandomReal(-90, 90)
        x1, y1 = PolarXY(x, y, 150, sj)
        local tx = EffectcreateArgs({
          effect = "war3mapImported\\214_bishou2.mdx",
          x = x1,
          y = y1,
          time = -1,
          size = 1,
          height = 100,
          zxz = jd,
          animespeed = 1.0
        })
        EffectShowAll(tx)
        local cs = 0
        local x3, y3 = x1, y1
        local sj1 = GetRandomInt(200, 600)
        local g = CreateGroupLua()
        ac.wait(sj1, function()
          ac.loop(10, function(t)
            cs = cs + 1
            x3, y3 = PolarXY(x3, y3, 100, jd)
            if cs < 30 then
              japi.EXSetEffectXY(tx, x3, y3)
              for _, xq in ac.selector():in_rangexy(x3, y3, 100):isnotingroup(g):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                mz = true
                if not mz2 then
                  mz2 = true
                  zhigui_combo(u)
                  zhiguishockcamera(u, 100, 0.15)
                end
                xq:groupadd(g)
                zhiguidamageunit({
                  skillstr = skillstr,
                  u = u,
                  xq = xq,
                  sh = txsh2,
                  kz = kz * 0.25,
                  kzlx = "僵直",
                  txstr1 = txstr1,
                  txstr2 = txstr2,
                  isvest = true,
                  jtjl = 10,
                  jtjd = jd,
                  jtsj = 0.1
                })
              end
            end
            if 35 <= cs then
              DestroyEffectLua(tx)
              t:remove()
            end
          end)
        end)
      end
      ac.wait(400, function()
        if mz then
          zhigui_hlget(u, skillstr)
        end
      end)
    end)
  end,
  EEA = function(u)
    local skillstr = "EEA"
    local jd = u:getface() + 180
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    extratilixh(u, skillstr)
    local zttime = 0.1
    lianxie(u, skillstr, zttime)
    zhiguizantingtime(u, zttime)
    local txsh = sh * 1
    local mz = false
    u:setface(jd)
    ac.wait(1, function()
      u:animeact(3)
      u:animespeed(2.5)
      u:playsound(Sound_214_Gongji)
    end)
    local tx = EffectcreateArgs({
      effect = "war3mapImported\\214_bishou2.mdx",
      x = x,
      y = y,
      time = -1,
      size = 1,
      height = 100,
      zxz = jd,
      animespeed = 1.0
    })
    EffectShowAll(tx)
    local cs = 0
    local mz2 = false
    ac.loop(10, function(t)
      cs = cs + 1
      x, y = PolarXY(x, y, 100, jd)
      if cs < 20 then
        japi.EXSetEffectXY(tx, x, y)
        local mb
        for _, xq in ac.selector():in_rangexy(x, y, 200):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          mb = xq
        end
        if mb ~= nil then
          do
            local x2, y2 = mb:getxy()
            EffectcreateArgs({
              effect = "5dab9b48c482691b.mdl",
              x = x2,
              y = y2,
              size = 4,
              zxz = GetRandomAngle()
            })
            mz = true
            zhigui_combo(u)
            zhiguishockcamera(u, 100, 0.15)
            for _, xq in ac.selector():in_rangexy(x2, y2, 200):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              zhiguidamageunit({
                skillstr = skillstr,
                u = u,
                xq = xq,
                sh = txsh,
                kz = kz,
                kzlx = "僵直",
                txstr1 = txstr1,
                txstr2 = txstr2,
                isvest = false
              })
            end
            DestroyEffectLua(tx)
            lianxie(u, skillstr, zttime)
            zhiguizantingtime(u, zttime)
            ac.wait(200, function()
              u:playsound(Sound_214_qianghua_W1)
              u:playsound(Sound_214_Gongji)
              local x1, y1 = mb:getxy()
              u:animeact(5)
              u:animespeed(2.5)
              EffectcreateArgs({
                effect = "war3mapImported\\daji_hong1.mdx",
                x = x1,
                y = y1,
                size = 40,
                height = 150,
                zxz = jd,
                animespeed = 6.0
              })
              EffectcreateArgs({
                effect = "war3mapImported\\bbb.mdx",
                x = x1,
                y = y1,
                size = 2,
                zxz = jd,
                animespeed = 1.2
              })
              EffectcreateArgs({
                effect = "war3mapImported\\dash sfx.mdx",
                x = x1,
                y = y1,
                size = 2,
                zxz = jd,
                animespeed = 3.0
              })
              local tx = EffectcreateArgs({
                effect = "war3mapImported\\214_bishou1.mdx",
                x = x1,
                y = y1,
                size = 10.0,
                zxz = jd,
                animespeed = 2.0
              })
              if type(japi.EXSetEffectColor) == "function" then
                japi.EXSetEffectColor(tx, 4294901760)
              end
              tx = EffectcreateArgs({
                effect = "war3mapImported\\qiye_zhanji8.mdx",
                x = x1,
                y = y1,
                size = 10.0,
                zxz = jd,
                animespeed = 2.0
              })
              if type(japi.EXSetEffectColor) == "function" then
                japi.EXSetEffectColor(tx, 4294901760)
              end
              zhiguishockcamera(u, 600, 0.15)
              x1, y1 = PolarXY(x1, y1, 200, jd)
              u:setxy(x1, y1)
              u:setface(jd + 180)
              local dx, dy = PolarXY(x1, y1, 400, jd + 180)
              zhigui_combo(u)
              for _, xq in ac.selector():in_rangexy(x1, y1, 200):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                xq:setxy(dx, dy)
                zhiguidamageunit({
                  skillstr = skillstr,
                  u = u,
                  xq = xq,
                  sh = txsh,
                  kz = kz,
                  kzlx = "僵直",
                  txstr1 = txstr1,
                  txstr2 = txstr2,
                  isvest = false
                })
              end
              zhiguicamset(u, x1, y1)
              zhigui_hlget(u, skillstr)
            end)
            t:remove()
          end
        end
      end
      if 25 <= cs then
        DestroyEffectLua(tx)
        t:remove()
      end
    end)
  end,
  EAA = function(u)
    local skillstr = "EAA"
    local jd = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    extratilixh(u, skillstr)
    zhiguicamlock(u)
    local zttime = 0.4
    lianxie(u, skillstr, zttime)
    zhiguizantingtime(u, zttime)
    u:buffset(u.handle, zttime + u:getdata("两仪式-额外无敌时间"), "无敌")
    local txsh = sh * 0.75
    local mz = false
    ac.wait(1, function()
      u:animeact(8)
      u:animespeed(1.0)
      u:playsound(Sound_214_qianghua_E)
      u:playsound(Sound_214_Gongji)
    end)
    unitjump({
      unit = u.handle,
      time = 0.4,
      distance = 500,
      height = 100,
      angle = u:getface(),
      loops = {
        {
          looptime = 0.02,
          func = function(x, y, args)
            if u:hasdata("两仪式-强断连招") then
              args.stop = true
              return
            end
          end
        }
      }
    })
    local dtime = 0
    ac.loop(100, function(dtimer)
      dtime = dtime + 1
      if u:hasdata("两仪式-强断连招") then
        dtimer:remove()
        return
      end
      if dtime == 2 then
        u:playsound(Sound_214_Gongji)
        u:animeact(18)
        u:animespeed(1.2)
        x, y = u:getxy()
        local tx = EffectcreateArgs({
          effect = "war3mapImported\\File00006330.mdx",
          x = x,
          y = y,
          size = 4,
          height = 300,
          zxz = jd - 45,
          xxz = 200,
          animespeed = 1.5
        })
        if type(japi.EXSetEffectColor) == "function" then
          japi.EXSetEffectColor(tx, 4285098345)
        end
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          if not mz then
            mz = true
            zhigui_hlget(u, skillstr)
          end
          if not mz2 then
            mz2 = true
            zhigui_combo(u)
            zhiguishockcamera(u, 100, 0.15)
          end
          zhiguidamageunit({
            skillstr = skillstr,
            u = u,
            xq = xq,
            sh = txsh,
            kz = kz,
            kzlx = "僵直",
            txstr1 = txstr1,
            txstr2 = txstr2,
            isvest = false,
            jtjl = 150,
            jtjd = jd,
            jtsj = 0.1
          })
        end
      end
      if dtime == 4 then
        x, y = u:getxy()
        EffectcreateArgs({
          effect = "war3mapImported\\bbb.mdx",
          x = x,
          y = y,
          size = 1,
          animespeed = 1.5
        })
        local tx = EffectcreateArgs({
          effect = "war3mapImported\\File00006330.mdx",
          x = x,
          y = y,
          size = 6,
          height = 150,
          zxz = jd + 200,
          xxz = -190,
          animespeed = 2.5
        })
        if type(japi.EXSetEffectColor) == "function" then
          japi.EXSetEffectColor(tx, 4285098345)
        end
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          if not mz then
            mz = true
            zhigui_hlget(u, skillstr)
          end
          if not mz2 then
            mz2 = true
            zhigui_combo(u)
            zhiguishockcamera(u, 100, 0.15)
          end
          zhiguidamageunit({
            skillstr = skillstr,
            u = u,
            xq = xq,
            sh = txsh,
            kz = kz,
            kzlx = "僵直",
            txstr1 = txstr1,
            txstr2 = txstr2,
            isvest = false,
            jtjl = 150,
            jtjd = jd,
            jtsj = 0.1
          })
        end
        zhiguicamunlock(u)
      end
      if dtime == 4 then
        dtimer:remove()
      end
    end)
  end,
  AEE = function(u)
    local skillstr = "AEE"
    local jd = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    extratilixh(u, skillstr)
    zhiguicamlock(u)
    ac.wait(900, function()
      zhiguicamunlock(u)
    end)
    local zttime = 0.8
    lianxie(u, skillstr, zttime)
    zhiguizantingtime(u, zttime)
    u:buffset(u.handle, zttime + u:getdata("两仪式-额外无敌时间"), "无敌")
    local txsh = sh * 0.25
    local mz = false
    u:setface(jd)
    ac.wait(1, function()
      u:animeact(20)
      u:animespeed(1.5)
      u:playsound(Sound_214_chongfeng_2)
      u:playsound(Sound_214_T6)
      EffectcreateArgs({
        effect = "war3mapImported\\bbb.mdx",
        x = x,
        y = y,
        size = 1,
        zxz = jd,
        animespeed = 1.2
      })
    end)
    ac.wait(100, function()
      unitjump({
        unit = u.handle,
        time = 0.6,
        distance = 700,
        height = 100,
        angle = u:getface(),
        isfly = true,
        loops = {
          {
            looptime = 0.02,
            func = function(x, y, args)
              if u:hasdata("两仪式-强断连招") then
                args.stop = true
                return
              end
            end
          }
        }
      })
      local cs = 0
      ac.loop(120, function(t)
        if u:hasdata("两仪式-强断连招") then
          t:remove()
          return
        end
        cs = cs + 1
        local x1, y1 = u:getxy()
        local gd = 100
        jd = u:getface()
        u:setface(jd)
        if cs <= 3 then
          gd = 100 + 100 * cs
        else
          gd = 400 - 45 * cs
        end
        EffectcreateArgs({
          effect = "war3mapImported\\sete_zhanji.mdx",
          x = x1,
          y = y1,
          size = 4,
          height = gd,
          zxz = jd,
          xxz = 270,
          animespeed = 2.0
        })
        if cs == 4 then
          EffectcreateArgs({
            effect = "war3mapImported\\bbb.mdx",
            x = x1,
            y = y1,
            size = 1,
            zxz = jd,
            animespeed = 2.0
          })
        end
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x1, y1, 225):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          local x2, y2 = xq:getxy()
          EffectcreateArgs({
            effect = "5dab9b48c482691b.mdl",
            x = x2,
            y = y2,
            size = 2,
            zxz = GetRandomAngle()
          })
          if not mz then
            mz = true
            zhigui_hlget(u, skillstr)
          end
          if not mz2 then
            mz2 = true
            zhigui_combo(u)
            zhiguishockcamera(u, 100, 0.15)
          end
          zhiguidamageunit({
            skillstr = skillstr,
            u = u,
            xq = xq,
            sh = txsh,
            kz = kz,
            kzlx = "僵直",
            txstr1 = txstr1,
            txstr2 = txstr2,
            isvest = false,
            jtjl = 100,
            jtjd = jd,
            jtsj = 0.1
          })
        end
        if 5 <= cs then
          t:remove()
        end
      end)
    end)
  end,
  AEA = function(u)
    local skillstr = "AEA"
    local jd = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    extratilixh(u, skillstr)
    zhiguicamlock(u)
    ac.wait(200, function()
      zhiguicamunlock(u)
    end)
    local zttime = 0.2
    lianxie(u, skillstr, zttime)
    zhiguizantingtime(u, zttime)
    local txsh = sh * 1.5
    local mz = false
    ac.wait(1, function()
      u:animeact(5)
      u:animespeed(2.0)
      u:playsound(Sound_214_qianghua_Q1)
    end)
    ac.wait(100, function()
      ac.wait(1, function()
        u:animeact(11)
        u:animespeed(2.5)
      end)
      unitmove({
        unit = u.handle,
        time = 0.1,
        distance = 100,
        angle = jd,
        isfly = true
      })
    end)
    ac.wait(200, function()
      x, y = u:getxy()
      u:playsound(Sound_214_Gongji)
      EffectcreateArgs({
        effect = "war3mapImported\\214_zhanji_bai.mdx",
        x = x,
        y = y,
        size = 6,
        height = 250,
        zxz = jd,
        xxz = -70,
        animespeed = 0.7
      })
      local mz2 = false
      for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        local x2, y2 = xq:getxy()
        unitjump({
          unit = xq.handle,
          time = 0.5,
          distance = 300,
          height = 600,
          angle = u:getface()
        })
        if not mz then
          mz = true
          zhigui_hlget(u, skillstr)
        end
        if not mz2 then
          mz2 = true
          zhigui_combo(u)
          zhiguishockcamera(u, 100, 0.15)
        end
        zhiguidamageunit({
          skillstr = skillstr,
          u = u,
          xq = xq,
          sh = txsh,
          kz = kz,
          kzlx = "僵直",
          txstr1 = txstr1,
          txstr2 = txstr2,
          isvest = false,
          jtjl = 0,
          jtjd = jd,
          jtsj = 0.1
        })
      end
    end)
  end,
  AAA = function(u)
    local skillstr = "AAA"
    local jd = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    extratilixh(u, skillstr)
    lianxie(u, skillstr)
    zhiguicamlock(u)
    ac.wait(100, function()
      zhiguicamunlock(u)
    end)
    local txsh = sh * 0.75
    local mz = false
    ac.wait(1, function()
      ac.wait(1, function()
        u:animeact(17)
        u:animespeed(2.0)
        u:playsound(Sound_214_Q3)
      end)
      ac.wait(100, function()
        u:playsound(Sound_214_Gongji)
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_bai.mdx",
          x = x,
          y = y,
          size = 6,
          height = 150,
          zxz = jd - 45,
          xxz = 160,
          animespeed = 0.7
        })
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          if not mz then
            mz = true
            zhigui_hlget(u, skillstr)
          end
          if not mz2 then
            mz2 = true
            zhigui_combo(u)
            zhiguishockcamera(u, 100, 0.15)
          end
          zhiguidamageunit({
            skillstr = skillstr,
            u = u,
            xq = xq,
            sh = txsh,
            kz = kz,
            kzlx = "僵直",
            txstr1 = txstr1,
            txstr2 = txstr2,
            isvest = false,
            jtjl = 50,
            jtjd = jd,
            jtsj = 0.1
          })
        end
      end)
    end)
    ac.wait(250, function()
      ac.wait(1, function()
        u:animeact(2)
        u:animespeed(2.0)
        u:playsound(Sound_214_Gongji)
      end)
      unitmove({
        unit = u.handle,
        time = 0.1,
        distance = 100,
        angle = jd,
        isfly = true
      })
      ac.wait(110, function()
        x, y = u:getxy()
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_bai.mdx",
          x = x,
          y = y,
          size = 6,
          height = 150,
          zxz = jd + 45,
          xxz = -20,
          animespeed = 0.7
        })
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          if not mz then
            mz = true
            zhigui_hlget(u, skillstr)
          end
          if not mz2 then
            mz2 = true
            zhigui_combo(u)
            zhiguishockcamera(u, 100, 0.15)
          end
          zhiguidamageunit({
            skillstr = skillstr,
            u = u,
            xq = xq,
            sh = txsh,
            kz = kz,
            kzlx = "僵直",
            txstr1 = txstr1,
            txstr2 = txstr2,
            isvest = false,
            jtjl = 50,
            jtjd = jd,
            jtsj = 0.1
          })
        end
      end)
    end)
    ac.wait(400, function()
      ac.wait(1, function()
        u:animeact(17)
        u:animespeed(2.0)
      end)
      ac.wait(100, function()
        u:playsound(Sound_214_Gongji)
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_bai.mdx",
          x = x,
          y = y,
          size = 6,
          height = 150,
          zxz = jd - 45,
          xxz = 160,
          animespeed = 0.7
        })
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          if not mz then
            mz = true
            zhigui_hlget(u, skillstr)
          end
          if not mz2 then
            mz2 = true
            zhigui_combo(u)
            zhiguishockcamera(u, 100, 0.15)
          end
          zhiguidamageunit({
            skillstr = skillstr,
            u = u,
            xq = xq,
            sh = txsh,
            kz = kz,
            kzlx = "僵直",
            txstr1 = txstr1,
            txstr2 = txstr2,
            isvest = false,
            jtjl = 50,
            jtjd = jd,
            jtsj = 0.1
          })
        end
      end)
    end)
  end,
  AAE = function(u)
    local skillstr = "AAE"
    local jd = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    extratilixh(u, skillstr)
    zhiguicamlock(u)
    ac.wait(410, function()
      zhiguicamunlock(u)
    end)
    local zttime = 0.4
    lianxie(u, skillstr, zttime)
    zhiguizantingtime(u, zttime)
    u:buffset(u.handle, zttime + u:getdata("两仪式-额外无敌时间"), "无敌")
    local mz = false
    local txsh = sh * 1
    local txsh2 = sh * 1
    ac.wait(1, function()
      local x1, y1 = PolarXY(x, y, 1000, jd)
      u:setxy(x1, y1)
      u:setface(jd + 180)
      u:animeact(4)
      u:animespeed(2.0)
      u:setflyheight(800)
      u:playsound(Sound_214_chongfeng_2)
      EffectcreateArgs({
        effect = "war3mapImported\\bbb.mdx",
        x = x1,
        y = y1,
        size = 2,
        zxz = jd,
        animespeed = 1.0
      })
    end)
    local dtime = 0
    ac.loop(100, function(dtimer)
      dtime = dtime + 1
      if u:hasdata("两仪式-强断连招") then
        dtimer:remove()
        return
      end
      if dtime == 1 then
        u:setxy(x, y)
        u:playsound(Sound_214_Gongji)
        u:setflyheight(0)
        u:animeact(3)
        u:animespeed(4.0)
        ac.wait(100, function()
          u:animespeed(1.0)
        end)
        zhiguishockcamera(u, 100, 0.2)
        local x1, y1 = PolarXY(x, y, 900, jd)
        EffectcreateArgs({
          effect = "war3mapImported\\214_bishou1.mdx",
          x = x1,
          y = y1,
          size = 5,
          height = 900,
          zxz = jd + 180,
          yxz = 45,
          animespeed = 2.0
        })
        x1, y1 = PolarXY(x, y, 0, jd)
        EffectcreateArgs({
          effect = "war3mapImported\\dash sfx.mdx",
          x = x1,
          y = y1,
          size = 2,
          height = 0,
          zxz = jd + 180,
          yxz = 45,
          animespeed = 3.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\214_chongjibo.mdx",
          x = x1,
          y = y1,
          size = 2.0,
          height = 0,
          zxz = jd + 180,
          animespeed = 1.0
        })
        x1, y1 = PolarXY(x, y, 700, jd)
        EffectcreateArgs({
          effect = "war3mapImported\\Daoguang_1.mdx",
          x = x1,
          y = y1,
          size = 1.0,
          height = 700,
          zxz = jd + 180,
          yxz = 45,
          animespeed = 2.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\bbb.mdx",
          x = x,
          y = y,
          size = 2,
          zxz = jd + 180,
          animespeed = 1.0
        })
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          if not mz then
            mz = true
            zhigui_hlget(u, skillstr)
          end
          if not mz2 then
            mz2 = true
            zhigui_combo(u)
            zhiguishockcamera(u, 100, 0.15)
          end
          zhiguidamageunit({
            skillstr = skillstr,
            u = u,
            xq = xq,
            sh = txsh,
            kz = kz,
            kzlx = "僵直",
            txstr1 = txstr1,
            txstr2 = txstr2,
            isvest = false,
            jtjl = 50,
            jtjd = jd + 180,
            jtsj = 0.1
          })
        end
      end
      if dtime == 2 then
        x, y = u:getxy()
        u:setface(jd)
        ac.wait(1, function()
          u:animeact(3)
          u:animespeed(1.5)
          u:playsound(Sound_214_W)
          u:playsound(Sound_214_chongfeng_2)
        end)
      end
      if dtime == 3 then
        zhiguishockcamera(u, 100, 0.2)
        local x1, y1 = PolarXY(x, y, 900, jd)
        local tx = EffectcreateArgs({
          effect = "war3mapImported\\214_bishou1.mdx",
          x = x1,
          y = y1,
          size = 5,
          height = 100,
          zxz = jd,
          animespeed = 2.0
        })
        if type(japi.EXSetEffectColor) == "function" then
          japi.EXSetEffectColor(tx, 4294901760)
        end
        tx = EffectcreateArgs({
          effect = "war3mapImported\\dash sfx.mdx",
          x = x1,
          y = y1,
          size = 2,
          zxz = jd,
          animespeed = 3.0
        })
        if type(japi.EXSetEffectColor) == "function" then
          japi.EXSetEffectColor(tx, 4294901760)
        end
        EffectcreateArgs({
          effect = "war3mapImported\\bbb.mdx",
          x = x,
          y = y,
          size = 2,
          zxz = jd,
          animespeed = 1.0
        })
        x1, y1 = PolarXY(x, y, 900, jd + 45)
        tx = EffectcreateArgs({
          effect = "war3mapImported\\214_bishou1.mdx",
          x = x1,
          y = y1,
          size = 5,
          height = 500,
          zxz = jd - 45,
          yxz = 30,
          animespeed = 3.0
        })
        if type(japi.EXSetEffectColor) == "function" then
          japi.EXSetEffectColor(tx, 4294901760)
        end
        x1, y1 = PolarXY(x, y, 900, jd - 45)
        tx = EffectcreateArgs({
          effect = "war3mapImported\\214_bishou1.mdx",
          x = x1,
          y = y1,
          size = 5,
          height = 500,
          zxz = jd + 45,
          yxz = 30,
          animespeed = 3.0
        })
        if type(japi.EXSetEffectColor) == "function" then
          japi.EXSetEffectColor(tx, 4294901760)
        end
        x1, y1 = PolarXY(x, y, 500, jd)
        EffectcreateArgs({
          effect = "war3mapImported\\Daji_Hong1.mdx",
          x = x1,
          y = y1,
          size = 40.0,
          zxz = jd + 180,
          animespeed = 2.0
        })
        local g = CreateGroupLua()
        local mz2 = false
        unitmove({
          unit = u.handle,
          time = 0.1,
          distance = 1500,
          angle = jd,
          isfly = true,
          loops = {
            {
              looptime = 0.01,
              func = function(dx, dy)
                for _, xq in ac.selector():in_rangexy(dx, dy, 200):is_enemy(u.handle):isnotingroup(g):ipairs() do
                  xq = getunit(xq)
                  xq:groupadd(g)
                  if not mz then
                    mz = true
                    zhigui_hlget(u, skillstr)
                  end
                  if not mz2 then
                    mz2 = true
                    zhigui_combo(u)
                    zhiguishockcamera(u, 100, 0.15)
                  end
                  zhiguidamageunit({
                    skillstr = skillstr,
                    u = u,
                    xq = xq,
                    sh = txsh2,
                    kz = kz,
                    kzlx = "僵直",
                    txstr1 = txstr1,
                    txstr2 = txstr2,
                    isvest = false,
                    jtjl = 200,
                    jtjd = jd,
                    jtsj = 0.1
                  })
                end
              end
            }
          }
        })
      end
      if dtime == 3 then
        dtimer:remove()
      end
    end)
  end,
  EAAV = function(u)
    local skillstr = "EAAV"
    local jd = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    zhiguicamlock(u)
    local mz = false
    local txsh = sh * 2
    local zttime = 0.7
    u:setdata("两仪式连携", "")
    u:setdata("两仪式连携时间", zttime + 0.8 * u:getdata("两仪式-连锁时间"))
    zhiguizantingtime(u, zttime)
    u:buffset(u.handle, zttime + u:getdata("两仪式-额外无敌时间"), "无敌")
    if u:hasdata("两仪式天赋-痛觉残留") then
      u:buffset(u.handle, zttime, "绝对闪避")
    end
    ac.wait(1, function()
      u:animeact(5)
      u:animespeed(1.0)
      u:playsound(Sound_214_chongfeng_2)
      u:playsound(Sound_214_T6)
    end)
    local dtime = 0
    ac.loop(100, function(dtimer)
      dtime = dtime + 1
      if u:hasdata("两仪式-强断连招") then
        dtimer:remove()
        return
      end
      if dtime == 1 then
        u:playsound(Sound_214_chongfeng_1)
        u:animeact(15)
        u:animespeed(3.0)
        unitmove({
          unit = u.handle,
          time = 0.3,
          distance = 500,
          angle = jd,
          isfly = true
        })
        EffectcreateArgs({
          effect = "war3mapImported\\qiye_chongci2.mdx",
          x = x,
          y = y,
          size = 5.0,
          height = -100,
          zxz = jd,
          animespeed = 3.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\bbb.mdx",
          x = x,
          y = y,
          size = 2,
          zxz = jd,
          animespeed = 2.2
        })
      end
      if dtime == 3 then
        u:animespeed(0.1)
        u:playsound(Sound_214_qianghua_E2)
        u:playsound(Sound_214_T6)
      end
      if dtime == 4 then
        x, y = u:getxy()
        EffectcreateArgs({
          effect = "war3mapImported\\Daji_Hong1.mdx",
          x = x,
          y = y,
          size = 40.0,
          zxz = jd + 180,
          animespeed = 4.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\214_chongjibo.mdx",
          x = x,
          y = y,
          size = 2.0,
          height = -10,
          zxz = jd,
          animespeed = 1.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\qiye_zhanji8.mdx",
          x = x,
          y = y,
          size = 50.0,
          height = -1400,
          zxz = jd,
          animespeed = 10.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\qiye_zhanji8.mdx",
          x = x,
          y = y,
          size = 50.0,
          height = -1400,
          zxz = jd + 65,
          animespeed = 10.0
        })
        local tx = EffectcreateArgs({
          effect = "war3mapImported\\sete_zhanji.mdx",
          x = x,
          y = y,
          size = 6,
          height = 100,
          zxz = jd,
          xxz = 5,
          animespeed = 1.0
        })
        local tx1 = EffectcreateArgs({
          effect = "war3mapImported\\sete_zhanji.mdx",
          x = x,
          y = y,
          size = 6,
          height = 300,
          zxz = jd + 90,
          animespeed = 1.0
        })
        if type(japi.EXSetEffectColor) == "function" then
          japi.EXSetEffectColor(tx, 4288230399)
        end
        if type(japi.EXSetEffectColor) == "function" then
          japi.EXSetEffectColor(tx1, 4288230399)
        end
        zhiguishockcamera(u, 300, 0.2)
        ac.wait(100, function()
          japi.EXSetEffectSpeed(tx, 0.2)
          japi.EXSetEffectSpeed(tx1, 0.1)
          x, y = u:getxy()
          local mz2 = false
          for _, xq in ac.selector():in_rangexy(x, y, 600):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            local x2, y2 = xq:getxy()
            EffectcreateArgs({
              effect = "5dab9b48c482691b.mdl",
              x = x2,
              y = y2,
              size = 4,
              zxz = GetRandomAngle()
            })
            if not mz then
              mz = true
              zhigui_hlget(u, skillstr)
            end
            if not mz2 then
              mz2 = true
              zhigui_combo(u)
              zhiguishockcamera(u, 100, 0.15)
              u:playsound(Sound_214_Gongji)
            end
            zhiguidamageunit({
              skillstr = skillstr,
              u = u,
              xq = xq,
              sh = txsh,
              kz = kz,
              kzlx = "僵直",
              txstr1 = txstr1,
              txstr2 = txstr2,
              isvest = false
            })
          end
        end)
        ac.wait(500, function()
          japi.EXSetEffectSpeed(tx, 2.0)
          japi.EXSetEffectSpeed(tx1, 2.0)
        end)
      end
      if dtime == 7 then
        zhiguicamunlock(u)
        u:animespeed(2.0)
        unitmove({
          unit = u.handle,
          time = 0.3,
          distance = 200,
          angle = jd,
          isfly = true
        })
      end
      if dtime == 7 then
        dtimer:remove()
      end
    end)
  end,
  EEAV = function(u)
    local skillstr = "EEAV"
    local jd = u:getface()
    if u:hasdata("两仪式-手搓模式") and u:hasdata("两仪式-开启EEAV跟随") then
      local x, y = u:getxy()
      local x2 = u:getdata("两仪式-X")
      local y2 = u:getdata("两仪式-Y")
      jd = AngleXY(x, y, x2, y2)
    end
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    zhiguicamlock(u)
    ac.wait(1005, function()
      zhiguicamunlock(u)
    end)
    local mz = false
    local txsh = sh * 1
    local txsh2 = sh * 0.5
    local txsh3 = sh * 1
    local zttime = 1
    u:setdata("两仪式连携", "")
    u:setdata("两仪式连携时间", zttime + 0.8 * u:getdata("两仪式-连锁时间"))
    zhiguizantingtime(u, zttime)
    u:buffset(u.handle, zttime + u:getdata("两仪式-额外无敌时间"), "无敌")
    if u:hasdata("两仪式天赋-痛觉残留") then
      u:buffset(u.handle, zttime, "绝对闪避")
    end
    u:setface(jd)
    ac.wait(1, function()
      u:animeact(3)
      u:animespeed(2.5)
      u:playsound(Sound_214_qianghua_W1)
      u:playsound(Sound_214_Gongji)
    end)
    ac.wait(100, function()
      local x2, y2 = PolarXY(x, y, 300, jd)
      local tx1 = EffectcreateArgs({
        effect = "war3mapImported\\heiquan.mdx",
        x = x2,
        y = y2,
        time = 2.4,
        size = 7,
        height = -10,
        zxz = jd,
        animespeed = 3.0
      })
      ac.wait(100, function()
        japi.EXSetEffectSpeed(tx1, 0.0)
      end)
      ac.wait(700, function()
        japi.EXSetEffectSpeed(tx1, 2.0)
      end)
      EffectcreateArgs({
        effect = "5dab9b48c482691b.mdl",
        x = x2,
        y = y2,
        size = 4,
        zxz = GetRandomAngle()
      })
      local mz2 = false
      for _, xq in ac.selector():in_rangexy(x2, y2, 400):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        if not mz then
          mz = true
          zhigui_hlget(u, skillstr)
        end
        if not mz2 then
          mz2 = true
          zhigui_combo(u)
          zhiguishockcamera(u, 100, 0.15)
        end
        zhiguidamageunit({
          skillstr = skillstr,
          u = u,
          xq = xq,
          sh = txsh,
          kz = kz,
          kzlx = "僵直",
          txstr1 = txstr1,
          txstr2 = txstr2,
          isvest = false,
          jtjl = 100,
          jtjd = jd,
          jtsj = 0.1
        })
      end
      local cs1 = 0
      ac.loop(150, function(t1)
        cs1 = cs1 + 1
        if u:hasdata("两仪式-强断连招") then
          t1:remove()
          return
        end
        ac.wait(150, function()
          u:playsound(Sound_214_Gongji)
          local x1, y1 = x2, y2
          u:animeact(5)
          u:animespeed(2.5)
          local jd1 = jd
          if cs1 == 1 or cs1 == 3 then
            jd1 = jd + 180
          end
          EffectcreateArgs({
            effect = "war3mapImported\\daji_hong1.mdx",
            x = x1,
            y = y1,
            size = 40,
            height = 150,
            zxz = jd1,
            animespeed = 6.0
          })
          EffectcreateArgs({
            effect = "war3mapImported\\bbb.mdx",
            x = x1,
            y = y1,
            size = 2,
            zxz = jd1,
            animespeed = 1.2
          })
          EffectcreateArgs({
            effect = "war3mapImported\\dash sfx.mdx",
            x = x1,
            y = y1,
            size = 2,
            zxz = jd1,
            animespeed = 3.0
          })
          local tx = EffectcreateArgs({
            effect = "war3mapImported\\214_bishou1.mdx",
            x = x1,
            y = y1,
            size = 10.0,
            zxz = jd1,
            animespeed = 2.0
          })
          if type(japi.EXSetEffectColor) == "function" then
            japi.EXSetEffectColor(tx, 4294901760)
          end
          tx = EffectcreateArgs({
            effect = "war3mapImported\\qiye_zhanji8.mdx",
            x = x1,
            y = y1,
            size = 10.0,
            zxz = jd1,
            animespeed = 2.0
          })
          if type(japi.EXSetEffectColor) == "function" then
            japi.EXSetEffectColor(tx, 4294901760)
          end
          x1, y1 = PolarXY(x2, y2, 400, jd1)
          zhiguishockcamera(u, 300, 0.15)
          u:setxy(x1, y1)
          u:setface(jd1)
          local mz2 = false
          for _, xq in ac.selector():in_rangexy(x2, y2, 400):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            if not mz then
              mz = true
              zhigui_hlget(u, skillstr)
            end
            if not mz2 then
              mz2 = true
              zhigui_combo(u)
            end
            zhiguidamageunit({
              skillstr = skillstr,
              u = u,
              xq = xq,
              sh = txsh2,
              kz = kz,
              kzlx = "僵直",
              txstr1 = txstr1,
              txstr2 = txstr2,
              isvest = false,
              jtjl = 100,
              jtjd = jd1,
              jtsj = 0.1
            })
          end
        end)
        if 4 <= cs1 then
          u:setface(jd)
          u:playsound(Sound_214_qianghua_W2)
          local x1, y1 = x2, y2
          ac.wait(300, function()
            EffectcreateArgs({
              effect = "war3mapImported\\qiye_zhanji8.mdx",
              x = x1,
              y = y1,
              size = 50.0,
              height = -1400,
              zxz = jd,
              animespeed = 1.0
            })
            EffectcreateArgs({
              effect = "war3mapImported\\qiye_zhanji8.mdx",
              x = x1,
              y = y1,
              size = 50.0,
              height = -1400,
              zxz = jd + 65,
              animespeed = 1.0
            })
            EffectcreateArgs({
              effect = "war3mapImported\\daji_hong1.mdx",
              x = x1,
              y = y1,
              size = 40,
              height = 150,
              zxz = jd,
              animespeed = 2.0
            })
          end)
          ac.wait(400, function()
            ac.wait(200, function()
              zhiguishockcamera(u, 600, 0.15)
              u:playsound(Sound_214_R3)
              u:playsound(Sound_214_R4)
            end)
            ac.wait(300, function()
              EffectcreateArgs({
                effect = "5dab9b48c482691b.mdl",
                x = x1,
                y = y1,
                size = 40,
                height = -1700,
                zxz = GetRandomAngle(),
                animespeed = 1.5
              })
              EffectcreateArgs({
                effect = "war3mapImported\\qiye_zhanji8.mdx",
                x = x1,
                y = y1,
                size = 10.0,
                height = -140,
                zxz = jd,
                animespeed = 2.0
              })
              EffectcreateArgs({
                effect = "war3mapImported\\qiye_zhanji8.mdx",
                x = x1,
                y = y1,
                size = 10.0,
                height = -140,
                zxz = jd + 65,
                animespeed = 2.0
              })
              local mz2 = false
              for _, xq in ac.selector():in_rangexy(x1, y1, 400):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                if not mz then
                  mz = true
                  zhigui_hlget(u, skillstr)
                end
                if not mz2 then
                  mz2 = true
                  zhigui_combo(u)
                end
                zhiguidamageunit({
                  skillstr = skillstr,
                  u = u,
                  xq = xq,
                  sh = txsh3,
                  kz = kz,
                  kzlx = "僵直",
                  txstr1 = txstr1,
                  txstr2 = txstr2,
                  isvest = false
                })
              end
            end)
          end)
          t1:remove()
        end
      end)
    end)
  end,
  AEAV = function(u)
    local skillstr = "AEAV"
    local jd = u:getface()
    if u:hasdata("两仪式-手搓模式") and u:hasdata("两仪式-开启AEAV跟随") then
      local x, y = u:getxy()
      local x2 = u:getdata("两仪式-X")
      local y2 = u:getdata("两仪式-Y")
      jd = AngleXY(x, y, x2, y2)
    end
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    zhiguicamlock(u)
    local mz = false
    local txsh = sh * 2
    local zttime = 0.6
    u:setdata("两仪式连携", "")
    u:setdata("两仪式连携时间", zttime + 0.8 * u:getdata("两仪式-连锁时间"))
    u:setface(jd)
    zhiguizantingtime(u, zttime)
    if u:hasdata("两仪式天赋-痛觉残留") then
      u:buffset(u.handle, zttime, "绝对闪避")
    end
    u:buffset(u.handle, zttime + u:getdata("两仪式-额外无敌时间"), "无敌")
    ac.wait(1, function()
      u:animeact(5)
      u:animespeed(2.0)
      u:playsound(Sound_214_chongfeng_1)
    end)
    local dtime = 0
    ac.loop(100, function(dtimer)
      dtime = dtime + 1
      if u:hasdata("两仪式-强断连招") then
        dtimer:remove()
        return
      end
      if dtime == 2 then
        u:playsound(Sound_214_chongfeng_2)
        u:animeact(8)
      end
      if dtime == 3 then
        u:animeact(18)
        u:animespeed(1.0)
        unitmove({
          unit = u.handle,
          time = 0.3,
          distance = 500,
          angle = jd,
          isfly = true
        })
        local cs = 0
        local mz2 = false
        ac.loop(10, function(t)
          cs = cs + 1
          x, y = u:getxy()
          for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            local x2, y2 = xq:getxy()
            local jd2 = jd + cs * 9
            if 25 <= cs then
              x2, y2 = PolarXY(x, y, 800, jd)
              if not mz then
                mz = true
                zhigui_hlget(u, skillstr)
              end
              if not mz2 then
                mz2 = true
                zhigui_combo(u)
              end
              zhiguidamageunit({
                skillstr = skillstr,
                u = u,
                xq = xq,
                sh = txsh,
                kz = kz,
                kzlx = "僵直",
                txstr1 = txstr1,
                txstr2 = txstr2,
                isvest = false
              })
            else
              x2, y2 = PolarXY(x, y, 200, jd2)
            end
            xq:setxy(x2, y2)
          end
          if cs == 20 then
            u:playsound(Sound_214_T6)
          end
          if 25 <= cs then
            u:playsound(Sound_214_F)
            u:playsound(Sound_214_R3)
            u:playsound(Sound_214_R4)
            zhiguishockcamera(u, 600, 0.15)
            CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 0.1, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 50.0, 0.0, 0.0, 0.0)
            DisplayCineFilter(false)
            if u:isbeseenlocal() then
              DisplayCineFilter(true)
            end
            x, y = u:getxy()
            local x2, y2 = PolarXY(x, y, 800, jd)
            EffectcreateArgs({
              effect = "5dab9b48c482691b.mdl",
              x = x2,
              y = y2,
              size = 30,
              height = -1200,
              zxz = GetRandomAngle()
            })
            EffectcreateArgs({
              effect = "war3mapImported\\sete_zhanji.mdx",
              x = x,
              y = y,
              size = 10,
              height = 150,
              zxz = jd,
              xxz = 190,
              animespeed = 2.0
            })
            EffectcreateArgs({
              effect = "war3mapImported\\sete_zhanji.mdx",
              x = x,
              y = y,
              size = 8,
              height = 400,
              zxz = jd,
              xxz = 200,
              animespeed = 1.5
            })
            EffectcreateArgs({
              effect = "war3mapImported\\214_chongjibo.mdx",
              x = x,
              y = y,
              size = 5,
              height = -10,
              zxz = jd,
              animespeed = 1.5
            })
            zhiguicamunlock(u)
            t:remove()
          end
        end)
      end
      if dtime == 3 then
        dtimer:remove()
      end
    end)
  end,
  AAAV = function(u)
    local skillstr = "AAAV"
    local jd = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    zhiguicamlock(u)
    local mz = false
    local txsh = sh * 0.5
    local zttime = 1.3
    u:setdata("两仪式连携", "")
    u:setdata("两仪式连携时间", zttime + 0.8 * u:getdata("两仪式-连锁时间"))
    zhiguizantingtime(u, zttime)
    if u:hasdata("两仪式天赋-痛觉残留") then
      u:buffset(u.handle, zttime, "绝对闪避")
    end
    u:buffset(u.handle, zttime + u:getdata("两仪式-额外无敌时间"), "无敌")
    ac.wait(1, function()
      u:animeact(5)
      u:animespeed(2.0)
      u:playsound(Sound_214_qianghua_Q1)
      u:playsound(Sound_214_chongfeng_1)
    end)
    local dtime = 0
    ac.loop(50, function(dtimer)
      dtime = dtime + 1
      if u:hasdata("两仪式-强断连招") then
        dtimer:remove()
        return
      end
      if dtime == 1 then
        zhiguishockcamera(u, 100, 0.15)
        u:playsound(Sound_214_chongfeng_2)
        unitmove({
          unit = u.handle,
          time = 0.1,
          distance = 500,
          angle = jd,
          isfly = true,
          loops = {
            {
              looptime = 0.02,
              func = function(dx, dy)
                for _, xq in ac.selector():in_rangexy(dx, dy, 200):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  xq:setxy(dx, dy)
                end
              end
            }
          }
        })
        local x1, y1 = PolarXY(x, y, 600, jd)
        EffectcreateArgs({
          effect = "war3mapImported\\dash sfx.mdx",
          x = x1,
          y = y1,
          size = 2,
          zxz = jd,
          animespeed = 3.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\bbb.mdx",
          x = x,
          y = y,
          size = 2,
          zxz = jd,
          animespeed = 1.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\Daji_Hong1.mdx",
          x = x,
          y = y,
          size = 30,
          zxz = jd,
          animespeed = 6.0
        })
      end
      if dtime == 3 then
        ac.wait(1, function()
          u:animeact(17)
          u:animespeed(2.0)
          u:playsound(Sound_214_Gongji)
        end)
        ac.wait(100, function()
          x, y = u:getxy()
          u:playsound(Sound_214_Gongji)
          EffectcreateArgs({
            effect = "war3mapImported\\214_zhanji_bai.mdx",
            x = x,
            y = y,
            size = 6,
            height = 150,
            zxz = jd - 45,
            xxz = 160,
            animespeed = 0.7
          })
          local mz2 = false
          local x2, y2 = u:getxy()
          local dx, dy = PolarXY(x2, y2, 300, jd)
          for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            if not mz then
              mz = true
              zhigui_hlget(u, skillstr)
            end
            if not mz2 then
              mz2 = true
              zhigui_combo(u)
              zhiguishockcamera(u, 100, 0.15)
            end
            xq:setxy(dx, dy)
            zhiguidamageunit({
              skillstr = skillstr,
              u = u,
              xq = xq,
              sh = txsh,
              kz = kz,
              kzlx = "僵直",
              txstr1 = txstr1,
              txstr2 = txstr2,
              isvest = false
            })
          end
        end)
      end
      if dtime == 8 then
        ac.wait(1, function()
          u:animeact(2)
          u:animespeed(2.0)
          u:playsound(Sound_214_Gongji)
        end)
        unitmove({
          unit = u.handle,
          time = 0.1,
          distance = 100,
          angle = jd,
          isfly = true
        })
        ac.wait(110, function()
          x, y = u:getxy()
          EffectcreateArgs({
            effect = "war3mapImported\\214_zhanji_bai.mdx",
            x = x,
            y = y,
            size = 6,
            height = 150,
            zxz = jd + 45,
            xxz = -20,
            animespeed = 0.7
          })
          local mz2 = false
          local x2, y2 = u:getxy()
          local dx, dy = PolarXY(x2, y2, 300, jd)
          for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            if not mz then
              mz = true
              zhigui_hlget(u, skillstr)
            end
            if not mz2 then
              mz2 = true
              zhigui_combo(u)
              zhiguishockcamera(u, 100, 0.15)
            end
            xq:setxy(dx, dy)
            zhiguidamageunit({
              skillstr = skillstr,
              u = u,
              xq = xq,
              sh = txsh,
              kz = kz,
              kzlx = "僵直",
              txstr1 = txstr1,
              txstr2 = txstr2,
              isvest = false
            })
          end
        end)
      end
      if dtime == 11 then
        ac.wait(1, function()
          u:animeact(17)
          u:animespeed(2.0)
        end)
        ac.wait(100, function()
          x, y = u:getxy()
          u:playsound(Sound_214_Gongji)
          EffectcreateArgs({
            effect = "war3mapImported\\214_zhanji_bai.mdx",
            x = x,
            y = y,
            size = 6,
            height = 150,
            zxz = jd - 45,
            xxz = 160,
            animespeed = 0.7
          })
          local mz2 = false
          local x2, y2 = u:getxy()
          local dx, dy = PolarXY(x2, y2, 250, jd)
          for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            if not mz then
              mz = true
              zhigui_hlget(u, skillstr)
            end
            if not mz2 then
              mz2 = true
              zhigui_combo(u)
              zhiguishockcamera(u, 100, 0.15)
            end
            xq:setxy(dx, dy)
            zhiguidamageunit({
              skillstr = skillstr,
              u = u,
              xq = xq,
              sh = txsh,
              kz = kz,
              kzlx = "僵直",
              txstr1 = txstr1,
              txstr2 = txstr2,
              isvest = false
            })
          end
        end)
      end
      if dtime == 14 then
        ac.wait(1, function()
          u:animeact(6)
          u:animespeed(2.0)
        end)
        unitmove({
          unit = u.handle,
          time = 0.1,
          distance = 100,
          angle = jd,
          isfly = true
        })
        ac.wait(100, function()
          x, y = u:getxy()
          u:playsound(Sound_214_Gongji)
          EffectcreateArgs({
            effect = "war3mapImported\\214_zhanji_bai.mdx",
            x = x,
            y = y,
            size = 6,
            height = 150,
            zxz = jd,
            xxz = -45,
            animespeed = 0.7
          })
          local mz2 = false
          local x2, y2 = u:getxy()
          local dx, dy = PolarXY(x2, y2, 300, jd)
          for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            if not mz then
              mz = true
              zhigui_hlget(u, skillstr)
            end
            if not mz2 then
              mz2 = true
              zhigui_combo(u)
              zhiguishockcamera(u, 100, 0.15)
            end
            xq:setxy(dx, dy)
            zhiguidamageunit({
              skillstr = skillstr,
              u = u,
              xq = xq,
              sh = txsh,
              kz = kz,
              kzlx = "僵直",
              txstr1 = txstr1,
              txstr2 = txstr2,
              isvest = false
            })
          end
        end)
      end
      if dtime == 18 then
        ac.wait(1, function()
          u:animeact(2)
          u:animespeed(2.0)
          u:playsound(Sound_214_Gongji)
        end)
        unitmove({
          unit = u.handle,
          time = 0.1,
          distance = 100,
          angle = jd,
          isfly = true
        })
        ac.wait(110, function()
          x, y = u:getxy()
          EffectcreateArgs({
            effect = "war3mapImported\\214_zhanji_bai.mdx",
            x = x,
            y = y,
            size = 6,
            height = 150,
            zxz = jd + 45,
            xxz = -20,
            animespeed = 0.7
          })
          local mz2 = false
          local x2, y2 = u:getxy()
          local dx, dy = PolarXY(x2, y2, 250, jd)
          for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            if not mz then
              mz = true
              zhigui_hlget(u, skillstr)
            end
            if not mz2 then
              mz2 = true
              zhigui_combo(u)
              zhiguishockcamera(u, 100, 0.15)
            end
            xq:setxy(dx, dy)
            zhiguidamageunit({
              skillstr = skillstr,
              u = u,
              xq = xq,
              sh = txsh,
              kz = kz,
              kzlx = "僵直",
              txstr1 = txstr1,
              txstr2 = txstr2,
              isvest = false
            })
          end
        end)
      end
      if dtime == 21 then
        ac.wait(1, function()
          u:animeact(17)
          u:animespeed(2.0)
        end)
        ac.wait(100, function()
          x, y = u:getxy()
          u:playsound(Sound_214_Gongji)
          EffectcreateArgs({
            effect = "war3mapImported\\214_zhanji_bai.mdx",
            x = x,
            y = y,
            size = 6,
            height = 150,
            zxz = jd - 45,
            xxz = 160,
            animespeed = 0.7
          })
          local mz2 = false
          local x2, y2 = u:getxy()
          local dx, dy = PolarXY(x2, y2, 250, jd)
          for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            if not mz then
              mz = true
              zhigui_hlget(u, skillstr)
            end
            if not mz2 then
              mz2 = true
              zhigui_combo(u)
              zhiguishockcamera(u, 100, 0.15)
            end
            xq:setxy(dx, dy)
            zhiguidamageunit({
              skillstr = skillstr,
              u = u,
              xq = xq,
              sh = txsh,
              kz = kz,
              kzlx = "僵直",
              txstr1 = txstr1,
              txstr2 = txstr2,
              isvest = false
            })
          end
        end)
      end
      if dtime == 24 then
        ac.wait(1, function()
          u:animeact(11)
          u:animespeed(2.5)
        end)
        unitmove({
          unit = u.handle,
          time = 0.1,
          distance = 100,
          angle = jd,
          isfly = true
        })
        ac.wait(100, function()
          x, y = u:getxy()
          zhiguicamunlock(u)
          u:playsound(Sound_214_Gongji)
          EffectcreateArgs({
            effect = "war3mapImported\\214_zhanji_bai.mdx",
            x = x,
            y = y,
            size = 6,
            height = 250,
            zxz = jd,
            xxz = -70,
            animespeed = 0.7
          })
          local mz2 = false
          for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            unitjump({
              unit = xq.handle,
              time = 0.5,
              distance = 300,
              height = 600,
              angle = u:getface(),
              isfly = true
            })
            if not mz then
              mz = true
              zhigui_hlget(u, skillstr)
            end
            if not mz2 then
              mz2 = true
              zhigui_combo(u)
              zhiguishockcamera(u, 100, 0.15)
            end
            zhiguidamageunit({
              skillstr = skillstr,
              u = u,
              xq = xq,
              sh = txsh,
              kz = kz,
              kzlx = "僵直",
              txstr1 = txstr1,
              txstr2 = txstr2,
              isvest = false
            })
          end
        end)
      end
      if dtime == 26 then
        dtimer:remove()
      end
    end)
  end,
  EEEV = function(u)
    local skillstr = "EEEV"
    local jd = u:getface() + 180
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    zhiguicamlock(u)
    local mz = false
    local txsh = sh * 1.5
    local zttime = 1
    u:setdata("两仪式连携", "")
    u:setdata("两仪式连携时间", zttime + 0.8 * u:getdata("两仪式-连锁时间"))
    zhiguizantingtime(u, zttime)
    if u:hasdata("两仪式天赋-痛觉残留") then
      u:buffset(u.handle, zttime, "绝对闪避")
    end
    u:buffset(u.handle, zttime + u:getdata("两仪式-额外无敌时间"), "无敌")
    local txsh2 = sh * 0.5
    ac.wait(1, function()
      u:animeact(15)
      u:animespeed(2.0)
      u:playsound(Sound_214_chongfeng_2)
      u:playsound(Sound_214_T6)
    end)
    unitmove({
      unit = u.handle,
      time = 0.5,
      distance = 1500,
      angle = jd,
      isfly = true,
      loops = {
        {
          looptime = 0.02,
          func = function(x, y, args)
            if u:hasdata("两仪式-强断连招") then
              args.stop = true
              return
            end
          end
        }
      }
    })
    local mz2 = false
    local dtime = 0
    ac.loop(50, function(dtimer)
      dtime = dtime + 1
      if u:hasdata("两仪式-强断连招") then
        dtimer:remove()
        return
      end
      if dtime == 2 then
        x, y = u:getxy()
        for _, xq in ac.selector():in_rangexy(x, y, 300):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          if not mz2 then
            mz2 = true
            zhigui_combo(u)
            zhiguishockcamera(u, 100, 0.15)
          end
          if not mz then
            mz = true
            zhigui_hlget(u, skillstr)
          end
          zhiguidamageunit({
            skillstr = skillstr,
            u = u,
            xq = xq,
            sh = txsh2,
            kz = kz,
            kzlx = "僵直",
            txstr1 = txstr1,
            txstr2 = txstr2,
            isvest = false,
            jtjl = 50,
            jtjd = jd,
            jtsj = 0.1
          })
        end
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 1,
          zxz = jd,
          xxz = 10,
          animespeed = 1.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 1,
          zxz = jd,
          xxz = 10,
          animespeed = 1.0
        })
      end
      if dtime == 4 then
        x, y = u:getxy()
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 2,
          height = 150,
          zxz = jd + 180,
          xxz = 10,
          animespeed = 1.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 2,
          height = 150,
          zxz = jd + 180,
          xxz = 10,
          animespeed = 1.0
        })
      end
      if dtime == 6 then
        x, y = u:getxy()
        u:playsound(Sound_214_T6)
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          if not mz2 then
            mz2 = true
            zhigui_combo(u)
            zhiguishockcamera(u, 100, 0.15)
          end
          if not mz then
            mz = true
            zhigui_hlget(u, skillstr)
          end
          zhiguidamageunit({
            skillstr = skillstr,
            u = u,
            xq = xq,
            sh = txsh2,
            kz = kz,
            kzlx = "僵直",
            txstr1 = txstr1,
            txstr2 = txstr2,
            isvest = false,
            jtjl = 50,
            jtjd = jd,
            jtsj = 0.1
          })
        end
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 3,
          height = 300,
          zxz = jd,
          xxz = 10,
          animespeed = 1.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 3,
          height = 300,
          zxz = jd,
          xxz = 10,
          animespeed = 1.0
        })
      end
      if dtime == 8 then
        x, y = u:getxy()
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x, y, 500):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          if not mz2 then
            mz2 = true
            zhigui_combo(u)
            zhiguishockcamera(u, 100, 0.15)
          end
          if not mz then
            mz = true
            zhigui_hlget(u, skillstr)
          end
          zhiguidamageunit({
            skillstr = skillstr,
            u = u,
            xq = xq,
            sh = txsh2,
            kz = kz,
            kzlx = "僵直",
            txstr1 = txstr1,
            txstr2 = txstr2,
            isvest = false,
            jtjl = 50,
            jtjd = jd,
            jtsj = 0.1
          })
        end
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 4,
          height = 450,
          zxz = jd + 180,
          xxz = 10,
          animespeed = 1.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 4,
          height = 450,
          zxz = jd + 180,
          xxz = 10,
          animespeed = 1.0
        })
      end
      if dtime == 10 then
        x, y = u:getxy()
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x, y, 600):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          if not mz2 then
            mz2 = true
            zhigui_combo(u)
            zhiguishockcamera(u, 100, 0.15)
          end
          if not mz then
            mz = true
            zhigui_hlget(u, skillstr)
          end
          zhiguidamageunit({
            skillstr = skillstr,
            u = u,
            xq = xq,
            sh = txsh2,
            kz = kz,
            kzlx = "僵直",
            txstr1 = txstr1,
            txstr2 = txstr2,
            isvest = false,
            jtjl = 50,
            jtjd = jd,
            jtsj = 0.1
          })
        end
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 4.5,
          height = 600,
          zxz = jd,
          xxz = 10,
          animespeed = 1.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 4.5,
          height = 600,
          zxz = jd,
          xxz = 10,
          animespeed = 1.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\214_chongjibo.mdx",
          x = x,
          y = y,
          size = 3,
          height = -10,
          zxz = jd,
          animespeed = 1.0
        })
      end
      if dtime == 11 then
        x, y = u:getxy()
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x, y, 700):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          if not mz2 then
            mz2 = true
            zhigui_combo(u)
            zhiguishockcamera(u, 100, 0.15)
          end
          if not mz then
            mz = true
            zhigui_hlget(u, skillstr)
          end
          zhiguidamageunit({
            skillstr = skillstr,
            u = u,
            xq = xq,
            sh = txsh2,
            kz = kz,
            kzlx = "僵直",
            txstr1 = txstr1,
            txstr2 = txstr2,
            isvest = false,
            jtjl = 50,
            jtjd = jd,
            jtsj = 0.1
          })
        end
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 5,
          height = 750,
          zxz = jd + 180,
          xxz = 10,
          animespeed = 1.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 5,
          height = 750,
          zxz = jd + 180,
          xxz = 10,
          animespeed = 1.0
        })
      end
      if dtime == 12 then
        x, y = u:getxy()
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x, y, 800):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          if not mz2 then
            mz2 = true
            zhigui_combo(u)
            zhiguishockcamera(u, 100, 0.15)
          end
          if not mz then
            mz = true
            zhigui_hlget(u, skillstr)
          end
          zhiguidamageunit({
            skillstr = skillstr,
            u = u,
            xq = xq,
            sh = txsh2,
            kz = kz,
            kzlx = "僵直",
            txstr1 = txstr1,
            txstr2 = txstr2,
            isvest = false,
            jtjl = 50,
            jtjd = jd,
            jtsj = 0.1
          })
        end
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 5.5,
          height = 900,
          zxz = jd,
          xxz = 10,
          animespeed = 1.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 5.5,
          height = 900,
          zxz = jd,
          xxz = 10,
          animespeed = 1.0
        })
      end
      if dtime == 10 then
        jd = jd + 180
        ac.wait(1, function()
          u:animeact(5)
          u:animespeed(1.5)
          u:playsound(Sound_214_R1)
          u:playsound(Sound_214_chongfeng_1)
          local tx = EffectcreateArgs({
            effect = "war3mapImported\\heiquan.mdx",
            x = x,
            y = y,
            time = 2.4,
            size = 7,
            height = -10,
            zxz = jd,
            animespeed = 3.0
          })
          ac.wait(100, function()
            japi.EXSetEffectSpeed(tx, 2.0)
          end)
        end)
      end
      if dtime == 16 then
        EffectcreateArgs({
          effect = "war3mapImported\\bbb.mdx",
          x = x,
          y = y,
          size = 2,
          zxz = jd,
          animespeed = 1.0
        })
        unitjump({
          unit = u.handle,
          time = 0.2,
          distance = 1000,
          height = 500,
          angle = jd
        })
      end
      if dtime == 20 then
        u:animeact(17)
        u:animespeed(2.0)
        u:playsound(Sound_214_R3)
        CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 0.2, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 50.0, 0.0, 0.0, 0.0)
        DisplayCineFilter(false)
        if u:isbeseenlocal() then
          DisplayCineFilter(true)
        end
        local x1, y1 = u:getxy()
        zhiguishockcamera(u, 600, 0.2)
        for i = 1, 10 do
          EffectcreateArgs({
            effect = "war3mapImported\\sete_zhanji.mdx",
            x = x1,
            y = y1,
            size = 10,
            zxz = GetRandomAngle()
          })
        end
        for i1 = 1, 50 do
          EffectcreateArgs({
            effect = "war3mapImported\\214_zhanji_guang.mdx",
            x = x1,
            y = y1,
            size = GetRandomReal(7, 14),
            height = GetRandomReal(-350, 700),
            zxz = GetRandomAngle(),
            xxz = GetRandomAngle(),
            yxz = GetRandomAngle(),
            animespeed = GetRandomReal(1, 4)
          })
        end
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x1, y1, 1100):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          if not mz then
            mz = true
            zhigui_hlget(u, skillstr)
          end
          if not mz2 then
            mz2 = true
            zhigui_combo(u)
            zhiguishockcamera(u, 100, 0.15)
          end
          zhiguidamageunit({
            skillstr = skillstr,
            u = u,
            xq = xq,
            sh = txsh,
            kz = kz,
            kzlx = "僵直",
            txstr1 = txstr1,
            txstr2 = txstr2,
            isvest = false
          })
        end
        zhiguicamunlock(u)
      end
      if dtime == 20 then
        dtimer:remove()
      end
    end)
  end,
  ["EEEV-HandMode"] = function(u)
    local skillstr = "EEEV"
    local x, y = u:getxy()
    local x2 = u:getdata("两仪式-X")
    local y2 = u:getdata("两仪式-Y")
    local jd = AngleXY(x, y, x2, y2)
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    zhiguicamlock(u)
    ac.wait(500, function()
      zhiguicamunlock(u)
    end)
    local mz = false
    local txsh = sh * 1.5
    local zttime = 0.5
    u:deldata("EEEV回路已获取")
    u:setdata("两仪式连携", "EEEV")
    u:setdata("两仪式连携时间", zttime + 0.8 * u:getdata("两仪式-连锁时间"))
    zhiguizantingtime(u, zttime)
    if u:hasdata("两仪式天赋-痛觉残留") then
      u:buffset(u.handle, zttime, "绝对闪避")
    end
    u:buffset(u.handle, zttime + u:getdata("两仪式-额外无敌时间"), "无敌")
    u:setdata("两仪式-V变化时间", zttime + 0.8 * u:getdata("两仪式-连锁时间"))
    local txsh2 = sh * 0.5
    ac.wait(1, function()
      u:animeact(15)
      u:animespeed(2.0)
      u:playsound(Sound_214_chongfeng_2)
      u:playsound(Sound_214_T6)
    end)
    unitmove({
      unit = u.handle,
      time = 0.5,
      distance = 1500,
      angle = jd,
      isfly = true,
      loops = {
        {
          looptime = 0.02,
          func = function(x, y, args)
            if u:hasdata("两仪式-强断连招") then
              args.stop = true
              return
            end
          end
        }
      }
    })
    local mz2 = false
    local dtime = 0
    ac.loop(50, function(dtimer)
      dtime = dtime + 1
      if u:hasdata("两仪式-强断连招") then
        dtimer:remove()
        return
      end
      if dtime == 2 then
        x, y = u:getxy()
        for _, xq in ac.selector():in_rangexy(x, y, 300):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          if not mz2 then
            mz2 = true
            zhigui_combo(u)
            zhiguishockcamera(u, 100, 0.15)
          end
          if not mz then
            mz = true
            zhigui_hlget(u, skillstr)
          end
          zhiguidamageunit({
            skillstr = skillstr,
            u = u,
            xq = xq,
            sh = txsh2,
            kz = kz,
            kzlx = "僵直",
            txstr1 = txstr1,
            txstr2 = txstr2,
            isvest = false,
            jtjl = 50,
            jtjd = jd,
            jtsj = 0.1
          })
        end
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 1,
          zxz = jd,
          xxz = 10,
          animespeed = 1.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 1,
          zxz = jd,
          xxz = 10,
          animespeed = 1.0
        })
      end
      if dtime == 4 then
        x, y = u:getxy()
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 2,
          height = 150,
          zxz = jd + 180,
          xxz = 10,
          animespeed = 1.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 2,
          height = 150,
          zxz = jd + 180,
          xxz = 10,
          animespeed = 1.0
        })
      end
      if dtime == 6 then
        x, y = u:getxy()
        u:playsound(Sound_214_T6)
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          if not mz then
            mz = true
            zhigui_hlget(u, skillstr)
          end
          if not mz2 then
            mz2 = true
            zhigui_combo(u)
            zhiguishockcamera(u, 100, 0.15)
          end
          zhiguidamageunit({
            skillstr = skillstr,
            u = u,
            xq = xq,
            sh = txsh2,
            kz = kz,
            kzlx = "僵直",
            txstr1 = txstr1,
            txstr2 = txstr2,
            isvest = false,
            jtjl = 50,
            jtjd = jd,
            jtsj = 0.1
          })
        end
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 3,
          height = 300,
          zxz = jd,
          xxz = 10,
          animespeed = 1.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 3,
          height = 300,
          zxz = jd,
          xxz = 10,
          animespeed = 1.0
        })
      end
      if dtime == 8 then
        x, y = u:getxy()
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x, y, 500):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          if not mz2 then
            mz2 = true
            zhigui_combo(u)
            zhiguishockcamera(u, 100, 0.15)
          end
          if not mz then
            mz = true
            zhigui_hlget(u, skillstr)
          end
          zhiguidamageunit({
            skillstr = skillstr,
            u = u,
            xq = xq,
            sh = txsh2,
            kz = kz,
            kzlx = "僵直",
            txstr1 = txstr1,
            txstr2 = txstr2,
            isvest = false,
            jtjl = 50,
            jtjd = jd,
            jtsj = 0.1
          })
        end
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 4,
          height = 450,
          zxz = jd + 180,
          xxz = 10,
          animespeed = 1.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 4,
          height = 450,
          zxz = jd + 180,
          xxz = 10,
          animespeed = 1.0
        })
      end
      if dtime == 10 then
        x, y = u:getxy()
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x, y, 600):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          if not mz2 then
            mz2 = true
            zhigui_combo(u)
            zhiguishockcamera(u, 100, 0.15)
          end
          if not mz then
            mz = true
            zhigui_hlget(u, skillstr)
          end
          zhiguidamageunit({
            skillstr = skillstr,
            u = u,
            xq = xq,
            sh = txsh2,
            kz = kz,
            kzlx = "僵直",
            txstr1 = txstr1,
            txstr2 = txstr2,
            isvest = false,
            jtjl = 50,
            jtjd = jd,
            jtsj = 0.1
          })
        end
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 4.5,
          height = 600,
          zxz = jd,
          xxz = 10,
          animespeed = 1.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 4.5,
          height = 600,
          zxz = jd,
          xxz = 10,
          animespeed = 1.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\214_chongjibo.mdx",
          x = x,
          y = y,
          size = 3,
          height = -10,
          zxz = jd,
          animespeed = 1.0
        })
      end
      if dtime == 11 then
        x, y = u:getxy()
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x, y, 700):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          if not mz2 then
            mz2 = true
            zhigui_combo(u)
            zhiguishockcamera(u, 100, 0.15)
          end
          if not mz then
            mz = true
            zhigui_hlget(u, skillstr)
          end
          zhiguidamageunit({
            skillstr = skillstr,
            u = u,
            xq = xq,
            sh = txsh2,
            kz = kz,
            kzlx = "僵直",
            txstr1 = txstr1,
            txstr2 = txstr2,
            isvest = false,
            jtjl = 50,
            jtjd = jd,
            jtsj = 0.1
          })
        end
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 5,
          height = 750,
          zxz = jd + 180,
          xxz = 10,
          animespeed = 1.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 5,
          height = 750,
          zxz = jd + 180,
          xxz = 10,
          animespeed = 1.0
        })
      end
      if dtime == 12 then
        x, y = u:getxy()
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x, y, 800):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          if not mz2 then
            mz2 = true
            zhigui_combo(u)
            zhiguishockcamera(u, 100, 0.15)
          end
          if not mz then
            mz = true
            zhigui_hlget(u, skillstr)
          end
          zhiguidamageunit({
            skillstr = skillstr,
            u = u,
            xq = xq,
            sh = txsh2,
            kz = kz,
            kzlx = "僵直",
            txstr1 = txstr1,
            txstr2 = txstr2,
            isvest = false,
            jtjl = 50,
            jtjd = jd,
            jtsj = 0.1
          })
        end
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 5.5,
          height = 900,
          zxz = jd,
          xxz = 10,
          animespeed = 1.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\214_zhanji_lan.mdx",
          x = x,
          y = y,
          size = 5.5,
          height = 900,
          zxz = jd,
          xxz = 10,
          animespeed = 1.0
        })
      end
      if dtime == 13 then
        if mz then
          u:setdata("EEEV回路已获取")
        end
        dtimer:remove()
      end
    end)
  end,
  EEEVV = function(u)
    local skillstr = "EEEV"
    local x, y = u:getxy()
    local x2 = u:getdata("两仪式-X")
    local y2 = u:getdata("两仪式-Y")
    local jd = AngleXY(x, y, x2, y2)
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    zhiguicamlock(u)
    ac.wait(500, function()
      zhiguicamunlock(u)
    end)
    local mz = false
    local txsh = sh * 1.5
    local zttime = 0.5
    u:setdata("两仪式连携", "")
    u:setdata("两仪式连携时间", zttime + 0.8 * u:getdata("两仪式-连锁时间"))
    zhiguizantingtime(u, zttime)
    if u:hasdata("两仪式天赋-痛觉残留") then
      u:buffset(u.handle, zttime, "绝对闪避")
    end
    u:buffset(u.handle, zttime + u:getdata("两仪式-额外无敌时间"), "无敌")
    ac.wait(1, function()
      u:animeact(5)
      u:animespeed(1.5)
      u:playsound(Sound_214_R1)
      u:playsound(Sound_214_chongfeng_1)
      local tx = EffectcreateArgs({
        effect = "war3mapImported\\heiquan.mdx",
        x = x,
        y = y,
        time = 2.4,
        size = 7,
        height = -10,
        zxz = jd,
        animespeed = 3.0
      })
      ac.wait(100, function()
        japi.EXSetEffectSpeed(tx, 2.0)
      end)
    end)
    local dtime = 0
    ac.loop(50, function(dtimer)
      dtime = dtime + 1
      if u:hasdata("两仪式-强断连招") then
        dtimer:remove()
        return
      end
      if dtime == 6 then
        EffectcreateArgs({
          effect = "war3mapImported\\bbb.mdx",
          x = x,
          y = y,
          size = 2,
          zxz = jd,
          animespeed = 1.0
        })
        unitjump({
          unit = u.handle,
          time = 0.2,
          distance = 1000,
          height = 500,
          angle = jd
        })
      end
      if dtime == 10 then
        u:animeact(17)
        u:animespeed(2.0)
        u:playsound(Sound_214_R3)
        CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 0.2, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 50.0, 0.0, 0.0, 0.0)
        DisplayCineFilter(false)
        if u:isbeseenlocal() then
          DisplayCineFilter(true)
        end
        local x1, y1 = u:getxy()
        zhiguishockcamera(u, 600, 0.2)
        for i = 1, 10 do
          EffectcreateArgs({
            effect = "war3mapImported\\sete_zhanji.mdx",
            x = x1,
            y = y1,
            size = 10,
            zxz = GetRandomAngle()
          })
        end
        for i1 = 1, 50 do
          EffectcreateArgs({
            effect = "war3mapImported\\214_zhanji_guang.mdx",
            x = x1,
            y = y1,
            size = GetRandomReal(7, 14),
            height = GetRandomReal(-350, 700),
            zxz = GetRandomAngle(),
            xxz = GetRandomAngle(),
            yxz = GetRandomAngle(),
            animespeed = GetRandomReal(1, 4)
          })
        end
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x1, y1, 1100):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          if not mz then
            mz = true
          end
          if not mz2 then
            mz2 = true
            zhigui_combo(u)
            zhiguishockcamera(u, 100, 0.15)
          end
          zhiguidamageunit({
            skillstr = skillstr,
            u = u,
            xq = xq,
            sh = txsh,
            kz = kz,
            kzlx = "僵直",
            txstr1 = txstr1,
            txstr2 = txstr2,
            isvest = false
          })
        end
        zhiguicamunlock(u)
        if not u:hasdata("EEEV回路已获取") and mz then
          zhigui_hlget(u, skillstr)
        end
        u:deldata("EEEV回路已获取")
        dtimer:remove()
      end
    end)
  end,
  EAEV = function(u)
    local skillstr = "EAEV"
    local jd = u:getface()
    if u:hasdata("两仪式-手搓模式") then
      local x, y = u:getxy()
      local x2 = u:getdata("两仪式-X")
      local y2 = u:getdata("两仪式-Y")
      jd = AngleXY(x, y, x2, y2)
    end
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    local mz = false
    local txsh = sh * 4
    local zttime = 2.4
    zhiguicamlock(u)
    u:setdata("两仪式连携", "")
    u:setdata("两仪式连携时间", zttime + 0.8 * u:getdata("两仪式-连锁时间"))
    u:setface(jd)
    zhiguizantingtime(u, zttime)
    ac.wait(1, function()
      u:animeact(16)
      u:animespeed(1.9)
      u:playsound(Sound_214_chongfeng_1)
      u:playsound(Sound_214_T6)
    end)
    local dtime = 0
    local g = CreateGroupLua()
    ac.loop(100, function(dtimer)
      dtime = dtime + 1
      if u:hasdata("两仪式-强断连招") then
        dtimer:remove()
        return
      end
      if u:hasdata("两仪式天赋-痛觉残留") then
        u:buffset(u.handle, 0.1, "绝对闪避")
      end
      u:buffset(u.handle, 0.1 + u:getdata("两仪式-额外无敌时间"), "无敌")
      if dtime == 3 then
        zhiguishockcamera(u, 300, 0.2)
        u:animespeed(0.15)
        u:playsound(Sound_214_R2)
        u:playsound(Sound_214_R1)
        EffectcreateArgs({
          effect = "war3mapImported\\daji_hong1.mdx",
          x = x,
          y = y,
          size = 40,
          height = 150,
          zxz = jd,
          animespeed = 6.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\bbb.mdx",
          x = x,
          y = y,
          size = 2,
          zxz = jd,
          animespeed = 1.2
        })
        EffectcreateArgs({
          effect = "war3mapImported\\dash sfx.mdx",
          x = x,
          y = y,
          size = 2,
          zxz = jd,
          animespeed = 3.0
        })
        local tx = EffectcreateArgs({
          effect = "war3mapImported\\214_bishou1.mdx",
          x = x,
          y = y,
          size = 20.0,
          zxz = jd,
          animespeed = 2.0
        })
        if type(japi.EXSetEffectColor) == "function" then
          japi.EXSetEffectColor(tx, 4288230399)
        end
        local x1, y1 = PolarXY(x, y, 400, jd + 90)
        tx = EffectcreateArgs({
          effect = "war3mapImported\\214_bishou1.mdx",
          x = x1,
          y = y1,
          size = 7.0,
          zxz = jd - 20,
          animespeed = 2.0
        })
        if type(japi.EXSetEffectColor) == "function" then
          japi.EXSetEffectColor(tx, 4294901760)
        end
        x1, y1 = PolarXY(x, y, 400, jd - 90)
        tx = EffectcreateArgs({
          effect = "war3mapImported\\214_bishou1.mdx",
          x = x1,
          y = y1,
          size = 7.0,
          zxz = jd + 20,
          animespeed = 2.0
        })
        if type(japi.EXSetEffectColor) == "function" then
          japi.EXSetEffectColor(tx, 4294901760)
        end
        unitmove({
          unit = u.handle,
          time = 0.1,
          distance = 1000,
          angle = jd,
          isfly = true
        })
        x1, y1 = PolarXY(x, y, 300, jd)
        for _, xq in ac.selector():in_rangexy(x1, y1, 600):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          xq:groupadd(g)
          local x2, y2 = xq:getxy()
          EffectcreateArgs({
            effect = "war3mapImported\\214_sixian.mdx",
            x = x2,
            y = y2,
            time = 2.0,
            size = 1.5,
            height = 50,
            zxz = jd,
            animespeed = 1.0
          })
          xq:buffset(u.handle, 2.4, "暂停")
        end
      end
      if dtime == 4 then
        unitmove({
          unit = u.handle,
          time = 2,
          distance = 250,
          angle = jd,
          isfly = true,
          loops = {
            {
              looptime = 0.02,
              func = function(x, y, args)
                if u:hasdata("两仪式-强断连招") then
                  args.stop = true
                  return
                end
              end
            }
          }
        })
        local tx = EffectcreateArgs({
          effect = "war3mapImported\\heiquan.mdx",
          x = x,
          y = y,
          time = 2.4,
          size = 7,
          height = -10,
          zxz = jd,
          animespeed = 3.0
        })
        ac.wait(100, function()
          japi.EXSetEffectSpeed(tx, 0.0)
        end)
        ac.wait(1600, function()
          japi.EXSetEffectSpeed(tx, 2.0)
        end)
      end
      if dtime == 24 then
        if Group_Counts(g) > 0 then
          zhigui_combo(u)
          zhiguishockcamera(u, 100, 0.15)
          if not mz then
            mz = true
            zhigui_hlget(u, skillstr)
          end
        end
        ForGroupLuaNew(g, function(xq)
          local x2, y2 = xq:getxy()
          EffectcreateArgs({
            effect = "5dab9b48c482691b.mdl",
            x = x2,
            y = y2,
            size = 4,
            zxz = GetRandomAngle()
          })
          zhiguidamageunit({
            skillstr = skillstr,
            u = u,
            xq = xq,
            sh = txsh,
            kz = kz,
            kzlx = "僵直",
            txstr1 = txstr1,
            txstr2 = txstr2,
            isvest = false
          })
          unitmove({
            unit = xq.handle,
            time = 0.1,
            distance = 150,
            angle = jd,
            isfly = true
          })
        end)
        unitmove({
          unit = u.handle,
          time = 0.1,
          distance = 250,
          angle = jd,
          isfly = true
        })
        CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 0.1, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 0.0, 0.0, 0.0)
        DisplayCineFilter(false)
        if u:isbeseenlocal() then
          DisplayCineFilter(true)
        end
        u:animespeed(1.0)
        zhiguishockcamera(u, 300, 0.2)
        u:playsound(Sound_214_R3)
        u:playsound(Sound_214_R4)
        EffectcreateArgs({
          effect = "war3mapImported\\qiye_zhanji8.mdx",
          x = x,
          y = y,
          size = 50.0,
          height = -1400,
          zxz = jd,
          animespeed = 1.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\qiye_zhanji8.mdx",
          x = x,
          y = y,
          size = 50.0,
          height = -1400,
          zxz = jd + 65,
          animespeed = 1.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\daji_hong1.mdx",
          x = x,
          y = y,
          size = 40,
          height = 150,
          zxz = jd,
          animespeed = 2.0
        })
        ac.wait(300, function()
          EffectcreateArgs({
            effect = "war3mapImported\\qiye_zhanji8.mdx",
            x = x,
            y = y,
            size = 10.0,
            height = -140,
            zxz = jd,
            animespeed = 2.0
          })
          EffectcreateArgs({
            effect = "war3mapImported\\qiye_zhanji8.mdx",
            x = x,
            y = y,
            size = 10.0,
            height = -140,
            zxz = jd + 65,
            animespeed = 2.0
          })
        end)
        zhiguicamunlock(u)
      end
      if dtime == 24 then
        dtimer:remove()
      end
    end)
  end,
  AAEV = function(u)
    local skillstr = "AAEV"
    local jd = u:getface() + 180
    if u:hasdata("两仪式-手搓模式") then
      local x, y = u:getxy()
      local x2 = u:getdata("两仪式-X")
      local y2 = u:getdata("两仪式-Y")
      jd = AngleXY(x, y, x2, y2)
    end
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    local mz = false
    local txsh = sh * 1
    local txsh2 = sh * 1
    local zttime = 0.4
    u:setface(jd)
    u:setdata("两仪式连携", "")
    u:setdata("两仪式连携时间", zttime + 0.8 * u:getdata("两仪式-连锁时间"))
    zhiguizantingtime(u, zttime)
    if u:hasdata("两仪式天赋-痛觉残留") then
      u:buffset(u.handle, zttime, "绝对闪避")
    end
    u:buffset(u.handle, zttime + u:getdata("两仪式-额外无敌时间"), "无敌")
    ac.wait(1, function()
      u:animeact(3)
      u:animespeed(2.5)
      u:playsound(Sound_214_Gongji)
    end)
    local tx = EffectcreateArgs({
      effect = "war3mapImported\\214_bishou2.mdx",
      x = x,
      y = y,
      time = -1,
      size = 1,
      height = 100,
      zxz = jd,
      animespeed = 1.0
    })
    EffectShowAll(tx)
    local cs = 0
    local g = CreateGroupLua()
    ac.loop(10, function(t)
      cs = cs + 1
      if cs < 20 then
        x, y = PolarXY(x, y, 100, jd)
        japi.EXSetEffectXY(tx, x, y)
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x, y, 200):is_enemy(u.handle):isnotingroup(g):ipairs() do
          xq = getunit(xq)
          local x2, y2 = xq:getxy()
          xq:groupadd(g)
          EffectcreateArgs({
            effect = "5dab9b48c482691b.mdl",
            x = x2,
            y = y2,
            size = 4,
            zxz = GetRandomAngle()
          })
          if not mz then
            mz = true
            zhigui_hlget(u, skillstr)
          end
          if not mz2 then
            mz2 = true
            zhigui_combo(u)
            zhiguishockcamera(u, 100, 0.15)
          end
          zhiguidamageunit({
            skillstr = skillstr,
            u = u,
            xq = xq,
            sh = txsh,
            kz = kz,
            kzlx = "僵直",
            txstr1 = txstr1,
            txstr2 = txstr2,
            isvest = false
          })
        end
        ForGroupLuaNew(g, function(xq)
          xq:setxy(x, y)
        end)
      end
      if 40 <= cs then
        DestroyEffectLua(tx)
        unitjump({
          unit = u.handle,
          time = 0.3,
          distance = 0,
          height = 3000,
          angle = u:getface()
        })
        u:setxy(x, y)
        zhiguicamset(u, x, y)
        u:playsound(Sound_214_R3)
        u:playsound(Sound_214_R4)
        for i = 1, 10 do
          local tx = EffectcreateArgs({
            effect = "war3mapImported\\214_bishou1.mdx",
            x = x,
            y = y,
            size = 10,
            height = 1000,
            zxz = jd,
            yxz = 90,
            animespeed = GetRandomReal(0.5, 2.0)
          })
          if type(japi.EXSetEffectColor) == "function" then
            japi.EXSetEffectColor(tx, 4294901760)
          end
        end
        EffectcreateArgs({
          effect = "war3mapImported\\dash sfx.mdx",
          x = x,
          y = y,
          size = 2,
          zxz = jd,
          yxz = 90,
          animespeed = 3.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\Daji_Hong1.mdx",
          x = x,
          y = y,
          size = 40.0,
          zxz = jd + 180,
          animespeed = 2.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\bbb.mdx",
          x = x,
          y = y,
          size = 3.0,
          zxz = jd + 180,
          animespeed = 2.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\214_chongjibo.mdx",
          x = x,
          y = y,
          size = 3.0,
          height = 10,
          zxz = jd + 180,
          animespeed = 1.0
        })
        for i1 = 1, 10 do
          EffectcreateArgs({
            effect = "war3mapImported\\sete_zhanji.mdx",
            x = x,
            y = y,
            size = GetRandomReal(10, 20),
            height = GetRandomReal(-500, 1000),
            zxz = GetRandomAngle(),
            xxz = GetRandomAngle(),
            yxz = GetRandomAngle(),
            animespeed = GetRandomReal(1, 4)
          })
        end
        CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 0.2, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 50.0, 0.0, 0.0, 0.0)
        DisplayCineFilter(false)
        if u:isbeseenlocal() then
          DisplayCineFilter(true)
        end
        zhiguishockcamera(u, 600, 0.15)
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x, y, 800):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          if not mz then
            mz = true
            zhigui_hlget(u, skillstr)
          end
          if not mz2 then
            mz2 = true
            zhigui_combo(u)
            zhiguishockcamera(u, 100, 0.15)
          end
          zhiguidamageunit({
            skillstr = skillstr,
            u = u,
            xq = xq,
            sh = txsh2,
            kz = kz,
            kzlx = "僵直",
            txstr1 = txstr1,
            txstr2 = txstr2,
            isvest = false
          })
        end
        t:remove()
      end
    end)
  end,
  AEEV = function(u)
    local skillstr = "AEEV"
    local jd = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    local mz = false
    local txsh = sh * 2
    local zttime = 0.4
    u:setdata("两仪式连携", "")
    u:setdata("两仪式连携时间", zttime + 0.8 * u:getdata("两仪式-连锁时间"))
    zhiguizantingtime(u, zttime)
    if u:hasdata("两仪式天赋-痛觉残留") then
      u:buffset(u.handle, zttime, "绝对闪避")
    end
    u:buffset(u.handle, zttime + u:getdata("两仪式-额外无敌时间"), "无敌")
    ac.wait(1, function()
      u:animeact(5)
      u:animespeed(2.5)
      u:playsound(Sound_214_chongfeng_1)
    end)
    ac.wait(400, function()
      u:animeact(18)
      u:animespeed(1.2)
      for i = 1, 10 do
        local tx = EffectcreateArgs({
          effect = "war3mapImported\\File00006330.mdx",
          x = x,
          y = y,
          size = GetRandomReal(10, 30),
          height = GetRandomReal(-500, 1000),
          zxz = GetRandomAngle(),
          xxz = GetRandomAngle(),
          yxz = GetRandomAngle(),
          animespeed = GetRandomReal(1, 4)
        })
        if type(japi.EXSetEffectColor) == "function" then
          japi.EXSetEffectColor(tx, 4288230399)
        end
      end
      EffectcreateArgs({
        effect = "war3mapImported\\dash sfx.mdx",
        x = x,
        y = y,
        size = 2,
        zxz = jd,
        yxz = 90,
        animespeed = 3.0
      })
      EffectcreateArgs({
        effect = "war3mapImported\\Daji_Hong1.mdx",
        x = x,
        y = y,
        size = 40.0,
        zxz = jd + 180,
        animespeed = 2.0
      })
      EffectcreateArgs({
        effect = "war3mapImported\\bbb.mdx",
        x = x,
        y = y,
        size = 3.0,
        zxz = jd + 180,
        animespeed = 2.0
      })
      EffectcreateArgs({
        effect = "war3mapImported\\214_chongjibo.mdx",
        x = x,
        y = y,
        size = 3.0,
        height = 10,
        zxz = jd + 180,
        animespeed = 1.0
      })
      for i1 = 1, 10 do
        EffectcreateArgs({
          effect = "war3mapImported\\qiye_zhanji8.mdx",
          x = x,
          y = y,
          size = GetRandomReal(10, 20),
          height = GetRandomReal(-500, 1000),
          zxz = GetRandomAngle(),
          xxz = GetRandomAngle(),
          yxz = GetRandomAngle(),
          animespeed = GetRandomReal(1, 4)
        })
      end
      CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 0.2, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 50.0, 0.0, 0.0, 0.0)
      DisplayCineFilter(false)
      if u:isbeseenlocal() then
        DisplayCineFilter(true)
      end
      zhiguishockcamera(u, 600, 0.15)
      u:playsound(Sound_214_R3)
      u:playsound(Sound_214_R4)
      local mz2 = false
      for _, xq in ac.selector():in_rangexy(x, y, 800):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        if not mz then
          mz = true
          zhigui_hlget(u, skillstr)
        end
        if not mz2 then
          mz2 = true
          zhigui_combo(u)
        end
        zhiguidamageunit({
          skillstr = skillstr,
          u = u,
          xq = xq,
          sh = txsh,
          kz = kz,
          kzlx = "僵直",
          txstr1 = txstr1,
          txstr2 = txstr2,
          isvest = false
        })
      end
    end)
  end,
  R1 = function(u)
    local skillstr = "R1"
    local jd = u:getface()
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, skillstr)
    local txsh = sh * 0.5
    local txsh2 = sh * 2
    local zttime = 0.3
    zhiguizantingtime(u, zttime)
    u:setdata("两仪式连携时间", zttime + 0.8 * u:getdata("两仪式-连锁时间"))
    u:buffset(u.handle, zttime + u:getdata("两仪式-额外无敌时间"), "无敌")
    ac.wait(1, function()
      u:animeact(5)
      u:animespeed(2.0)
      u:playsound(Sound_214_qianghua_E)
      u:playsound(Sound_214_chongfeng_2)
    end)
    ac.wait(100, function()
      x, y = u:getxy()
      u:setface(jd)
      ac.wait(100, function()
        CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 0.1, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 30.0, 0.0, 0.0, 0.0)
        DisplayCineFilter(false)
        if u:isbeseenlocal() then
          DisplayCineFilter(true)
        end
        zhiguishockcamera(u, 100, 0.2)
        local x1, y1 = PolarXY(x, y, 900, jd)
        local tx = EffectcreateArgs({
          effect = "war3mapImported\\214_bishou1.mdx",
          x = x1,
          y = y1,
          size = 5,
          height = 100,
          zxz = jd,
          animespeed = 2.0
        })
        if type(japi.EXSetEffectColor) == "function" then
          japi.EXSetEffectColor(tx, 4294901760)
        end
        tx = EffectcreateArgs({
          effect = "war3mapImported\\dash sfx.mdx",
          x = x1,
          y = y1,
          size = 2,
          zxz = jd,
          animespeed = 3.0
        })
        if type(japi.EXSetEffectColor) == "function" then
          japi.EXSetEffectColor(tx, 4294901760)
        end
        EffectcreateArgs({
          effect = "war3mapImported\\bbb.mdx",
          x = x,
          y = y,
          size = 2,
          zxz = jd,
          animespeed = 1.0
        })
        x1, y1 = PolarXY(x, y, 900, jd + 45)
        tx = EffectcreateArgs({
          effect = "war3mapImported\\214_bishou1.mdx",
          x = x1,
          y = y1,
          size = 5,
          height = 500,
          zxz = jd - 45,
          yxz = 30,
          animespeed = 3.0
        })
        if type(japi.EXSetEffectColor) == "function" then
          japi.EXSetEffectColor(tx, 4294901760)
        end
        x1, y1 = PolarXY(x, y, 900, jd - 45)
        tx = EffectcreateArgs({
          effect = "war3mapImported\\214_bishou1.mdx",
          x = x1,
          y = y1,
          size = 5,
          height = 500,
          zxz = jd + 45,
          yxz = 30,
          animespeed = 3.0
        })
        if type(japi.EXSetEffectColor) == "function" then
          japi.EXSetEffectColor(tx, 4294901760)
        end
        local x2, y2 = u:getxy()
        x2, y2 = PolarXY(x2, y2, 600, jd)
        EffectcreateArgs({
          effect = "war3mapImported\\qiye_zhanji8.mdx",
          x = x2,
          y = y2,
          size = 50.0,
          height = -1400,
          zxz = jd,
          animespeed = 1.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\qiye_zhanji8.mdx",
          x = x2,
          y = y2,
          size = 50.0,
          height = -1400,
          zxz = jd + 65,
          animespeed = 1.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\daji_hong1.mdx",
          x = x2,
          y = y2,
          size = 40,
          height = 150,
          zxz = jd,
          animespeed = 2.0
        })
        ac.wait(500, function()
          CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 0.1, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 0.0, 0.0, 0.0)
          DisplayCineFilter(false)
          if u:isbeseenlocal() then
            DisplayCineFilter(true)
          end
          zhiguishockcamera(u, 600, 0.15)
          u:playsound(Sound_214_R3)
          u:playsound(Sound_214_R4)
          EffectcreateArgs({
            effect = "war3mapImported\\qiye_zhanji8.mdx",
            x = x2,
            y = y2,
            size = 10.0,
            height = -140,
            zxz = jd,
            animespeed = 2.0
          })
          EffectcreateArgs({
            effect = "war3mapImported\\qiye_zhanji8.mdx",
            x = x2,
            y = y2,
            size = 10.0,
            height = -140,
            zxz = jd + 65,
            animespeed = 2.0
          })
        end)
        unitmove({
          unit = u.handle,
          time = 0.1,
          distance = 2000,
          angle = jd,
          isfly = true
        })
        local dx, dy = PolarXY(x, y, 900, jd)
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(dx, dy, 100):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          if not mz2 then
            mz2 = true
            zhigui_combo(u)
          end
          zhiguidamageunit({
            skillstr = skillstr,
            u = u,
            xq = xq,
            sh = txsh2,
            kz = kz,
            kzlx = "僵直",
            txstr1 = txstr1,
            txstr2 = txstr2,
            isvest = false,
            jtjl = 100,
            jtjd = jd,
            jtsj = 0.1
          })
        end
      end)
      ac.wait(300, function()
        local cs1 = 0
        local x1, y1 = x, y
        for i = 1, 10 do
          local sj = jd + GetRandomReal(-90, 90)
          x1, y1 = PolarXY(x, y, 150, sj)
          local tx = EffectcreateArgs({
            effect = "war3mapImported\\214_bishou2.mdx",
            x = x1,
            y = y1,
            time = -1,
            size = 1,
            height = 100,
            zxz = jd,
            animespeed = 1.0
          })
          EffectShowAll(tx)
          local cs = 0
          local x3, y3 = x1, y1
          local sj1 = GetRandomInt(200, 600)
          local g = CreateGroupLua()
          ac.wait(sj1, function()
            local mz2 = false
            ac.loop(10, function(t)
              cs = cs + 1
              x3, y3 = PolarXY(x3, y3, 100, jd)
              if cs < 30 then
                japi.EXSetEffectXY(tx, x3, y3)
                for _, xq in ac.selector():in_rangexy(x3, y3, 100):is_enemy(u.handle):isnotingroup(g):ipairs() do
                  xq = getunit(xq)
                  xq:groupadd(g)
                  if not mz2 then
                    mz2 = true
                    zhigui_combo(u)
                    zhiguishockcamera(u, 100, 0.15)
                  end
                  zhiguidamageunit({
                    skillstr = skillstr,
                    u = u,
                    xq = xq,
                    sh = txsh,
                    kz = kz,
                    kzlx = "僵直",
                    txstr1 = txstr1,
                    txstr2 = txstr2,
                    isvest = false,
                    jtjl = 25,
                    jtjd = jd,
                    jtsj = 0.1
                  })
                end
              end
              if 35 <= cs then
                DestroyEffectLua(tx)
                t:remove()
              end
            end)
          end)
        end
      end)
    end)
  end,
  R2 = function(u)
    local skillstr = "R2"
    local jd = u:getface()
    u:setface(jd)
    u:buffset(u.handle, 0.7, "暂停")
    u:buffset(u.handle, 0.7 + u:getdata("两仪式-额外无敌时间"), "无敌")
    u:setdata("两仪式连携时间", 0.7 + 0.8 * u:getdata("两仪式-连锁时间"))
    u:buffset(u.handle, 0.8999999999999999, "绝对闪避")
    u:setdata("两仪式不计入爆气时间", 0.7)
    u:setdata("两仪式-R2技能已释放")
    u:playsound(Sound_214_chongfeng_1)
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, "R2")
    local txsh = sh * 4
    local g = CreateGroupLua()
    local qd = false
    local mb
    local mz2 = false
    local dx, dy = PolarXY(x, y, 200, jd)
    for _, xq in ac.selector():in_rangexy(dx, dy, 400):is_enemy(u.handle):ipairs() do
      xq = getunit(xq)
      xq:groupadd(g)
      if xq:isboss() then
        xq:buffset(xq.handle, 8.0, "沉默")
      end
    end
    ac.wait(300, function()
      u:animeact(17)
      u:animespeed(2.0)
      u:playsound(Sound_214_R3)
    end)
    ac.wait(400, function()
      EffectcreateArgs({
        effect = "war3mapImported\\214_zhanji_bai.mdx",
        x = x,
        y = y,
        size = 6,
        height = 150,
        zxz = jd - 45,
        xxz = 160,
        animespeed = 0.7
      })
      EffectcreateArgs({
        effect = "war3mapImported\\Daji_Hong1.mdx",
        x = x,
        y = y,
        size = 40,
        zxz = jd,
        animespeed = 3.0
      })
      local x2, y2 = u:getxy()
      ForGroupLuaNew(g, function(xq)
        xq:setxy(x2, y2)
        mb = xq
        unitmove({
          unit = xq.handle,
          time = 0.1,
          distance = 1500,
          angle = jd,
          isfly = true
        })
        zhiguishockcamera(u, 600, 0.15)
        if not mz2 then
          mz2 = true
          zhigui_combo(u)
        end
        if xq:isboss() then
          xq:buffset(xq.handle, 8.0, "沉默")
        end
        xq:buffset(xq.handle, 8.0, "暂停")
        zhiguidamageunit({
          skillstr = skillstr,
          u = u,
          xq = xq,
          sh = txsh,
          kz = kz,
          kzlx = "僵直",
          txstr1 = txstr1,
          txstr2 = txstr2,
          isvest = false
        })
      end)
      local dx, dy = PolarXY(x, y, 200, jd)
      for _, xq in ac.selector():in_rangexy(dx, dy, 400):is_enemy(u.handle):isnotingroup(g):ipairs() do
        xq = getunit(xq)
        xq:groupadd(g)
        xq:setxy(x2, y2)
        mb = xq
        unitmove({
          unit = xq.handle,
          time = 0.1,
          distance = 1500,
          angle = jd,
          isfly = true
        })
        zhiguishockcamera(u, 600, 0.15)
        if not mz2 then
          mz2 = true
          zhigui_combo(u)
        end
        if xq:isboss() then
          xq:buffset(xq.handle, 8.0, "沉默")
        end
        xq:buffset(xq.handle, 8.0, "暂停")
        zhiguidamageunit({
          skillstr = skillstr,
          u = u,
          xq = xq,
          sh = txsh,
          kz = kz,
          kzlx = "僵直",
          txstr1 = txstr1,
          txstr2 = txstr2,
          isvest = false
        })
      end
      ac.wait(100, function()
        if mb ~= nil and qd == false then
          SetCameraTargetControllerNoZForPlayer(u.owner, u.handle, 0, 0, false)
          qd = true
          local x1, y1 = mb:getxy()
          local tx = EffectcreateArgs({
            effect = "war3mapImported\\heiquan.mdx",
            x = x1,
            y = y1,
            time = 2.4,
            size = 7,
            height = -10,
            zxz = jd,
            animespeed = 3.0
          })
          if type(japi.EXSetEffectFogVisible) == "function" then
            japi.EXSetEffectFogVisible(tx, true)
          end
          if type(japi.EXSetEffectMaskVisible) == "function" then
            japi.EXSetEffectMaskVisible(tx, true)
          end
          ac.wait(100, function()
            japi.EXSetEffectSpeed(tx, 0.0)
          end)
          ac.wait(8000, function()
            japi.EXSetEffectSpeed(tx, 3.0)
            ResetToGameCameraForPlayer(u.owner, 0)
            local p = getplayer(u.owner)
            p:setcameraheight(Cam_height[u.ownerid], 0)
          end)
        end
      end)
      ac.wait(300, function()
        if Group_Counts(g) > 0 then
          u:playsound(Sound_214_R1)
          u:buffset(u.handle, 8.0, "暂停")
          u:buffset(u.handle, 8 + u:getdata("两仪式-额外无敌时间"), "无敌")
          u:buffset(u.handle, 8.2, "绝对闪避")
          u:setdata("两仪式不计入爆气时间", 8)
          u:setdata("两仪式连携时间", 8 + 0.8 * u:getdata("两仪式-连锁时间"))
          ac.wait(1, function()
            u:animeact(5)
            u:animespeed(2.0)
          end)
          ac.wait(1000, function()
            ac.wait(1, function()
              zhiguishockcamera(u, 600, 0.15)
              CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 0.2, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 30.0, 0.0, 0.0, 0.0)
              DisplayCineFilter(false)
              if u:isbeseenlocal() then
                DisplayCineFilter(true)
              end
              u:playsound(Sound_214_Baoqi_2)
              EffectcreateArgs({
                effect = "war3mapImported\\214_baoqi.mdx",
                x = x,
                y = y,
                size = 10,
                zxz = jd,
                animespeed = 2.0
              })
              EffectcreateArgs({
                effect = "war3mapImported\\214_chongjibo.mdx",
                x = x,
                y = y,
                size = 5,
                height = 10,
                zxz = jd,
                animespeed = 1.0
              })
              local x2, y2 = u:getxy()
              local dx, dy = PolarXY(x2, y2, 1500, jd)
              ForGroupLuaNew(g, function(xq)
                xq:setxy(dx, dy)
              end)
              unitmove({
                unit = u.handle,
                time = 0.1,
                distance = 1300,
                angle = jd,
                isfly = true
              })
              ac.wait(1, function()
                ac.wait(1, function()
                  ac.wait(1, function()
                    u:animeact(17)
                    u:animespeed(2.0)
                    u:playsound(Sound_214_qianghua_Q2)
                    u:playsound(Sound_214_Gongji)
                  end)
                  ac.wait(100, function()
                    x, y = u:getxy()
                    u:playsound(Sound_214_Gongji)
                    EffectcreateArgs({
                      effect = "war3mapImported\\214_zhanji_bai.mdx",
                      x = x,
                      y = y,
                      size = 6,
                      height = 150,
                      zxz = jd - 45,
                      xxz = 160,
                      animespeed = 0.7
                    })
                    local mz2 = false
                    for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
                      xq = getunit(xq)
                      local x2, y2 = u:getxy()
                      x2, y2 = PolarXY(x2, y2, 300, jd)
                      xq:setxy(x2, y2)
                      if not mz2 then
                        mz2 = true
                        zhigui_combo(u)
                        zhiguishockcamera(u, 100, 0.15)
                      end
                      zhiguidamageunit({
                        skillstr = skillstr,
                        u = u,
                        xq = xq,
                        sh = txsh,
                        kz = kz,
                        kzlx = "僵直",
                        txstr1 = txstr1,
                        txstr2 = txstr2,
                        isvest = false
                      })
                    end
                  end)
                end)
                ac.wait(500, function()
                  ac.wait(1, function()
                    u:animeact(2)
                    u:animespeed(2.0)
                    u:playsound(Sound_214_Gongji)
                  end)
                  unitmove({
                    unit = u.handle,
                    time = 0.1,
                    distance = 100,
                    angle = jd,
                    isfly = true
                  })
                  ac.wait(110, function()
                    x, y = u:getxy()
                    EffectcreateArgs({
                      effect = "war3mapImported\\214_zhanji_bai.mdx",
                      x = x,
                      y = y,
                      size = 6,
                      height = 150,
                      zxz = jd + 45,
                      xxz = -20,
                      animespeed = 0.7
                    })
                    local mz2 = false
                    for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
                      xq = getunit(xq)
                      local x2, y2 = u:getxy()
                      x2, y2 = PolarXY(x2, y2, 300, jd)
                      xq:setxy(x2, y2)
                      if not mz2 then
                        mz2 = true
                        zhigui_combo(u)
                        zhiguishockcamera(u, 100, 0.15)
                      end
                      zhiguidamageunit({
                        skillstr = skillstr,
                        u = u,
                        xq = xq,
                        sh = txsh,
                        kz = kz,
                        kzlx = "僵直",
                        txstr1 = txstr1,
                        txstr2 = txstr2,
                        isvest = false
                      })
                    end
                  end)
                end)
                ac.wait(750, function()
                  ac.wait(1, function()
                    u:animeact(17)
                    u:animespeed(2.0)
                  end)
                  ac.wait(100, function()
                    x, y = u:getxy()
                    u:playsound(Sound_214_Gongji)
                    EffectcreateArgs({
                      effect = "war3mapImported\\214_zhanji_bai.mdx",
                      x = x,
                      y = y,
                      size = 6,
                      height = 150,
                      zxz = jd - 45,
                      xxz = 160,
                      animespeed = 0.7
                    })
                    local mz2 = false
                    for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
                      xq = getunit(xq)
                      local x2, y2 = u:getxy()
                      x2, y2 = PolarXY(x2, y2, 300, jd)
                      xq:setxy(x2, y2)
                      if not mz2 then
                        mz2 = true
                        zhigui_combo(u)
                        zhiguishockcamera(u, 100, 0.15)
                      end
                      zhiguidamageunit({
                        skillstr = skillstr,
                        u = u,
                        xq = xq,
                        sh = txsh,
                        kz = kz,
                        kzlx = "僵直",
                        txstr1 = txstr1,
                        txstr2 = txstr2,
                        isvest = false
                      })
                    end
                  end)
                end)
                ac.wait(900, function()
                  ac.wait(1, function()
                    u:animeact(6)
                    u:animespeed(2.0)
                  end)
                  unitmove({
                    unit = u.handle,
                    time = 0.1,
                    distance = 100,
                    angle = jd,
                    isfly = true
                  })
                  ac.wait(100, function()
                    x, y = u:getxy()
                    u:playsound(Sound_214_Gongji)
                    EffectcreateArgs({
                      effect = "war3mapImported\\214_zhanji_bai.mdx",
                      x = x,
                      y = y,
                      size = 6,
                      height = 150,
                      zxz = jd,
                      xxz = -45,
                      animespeed = 0.7
                    })
                    local mz2 = false
                    for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
                      xq = getunit(xq)
                      local x2, y2 = u:getxy()
                      x2, y2 = PolarXY(x2, y2, 300, jd)
                      xq:setxy(x2, y2)
                      if not mz2 then
                        mz2 = true
                        zhigui_combo(u)
                        zhiguishockcamera(u, 100, 0.15)
                      end
                      zhiguidamageunit({
                        skillstr = skillstr,
                        u = u,
                        xq = xq,
                        sh = txsh,
                        kz = kz,
                        kzlx = "僵直",
                        txstr1 = txstr1,
                        txstr2 = txstr2,
                        isvest = false
                      })
                    end
                  end)
                end)
                ac.wait(1050, function()
                  ac.wait(1, function()
                    u:animeact(2)
                    u:animespeed(2.0)
                    u:playsound(Sound_214_Gongji)
                  end)
                  unitmove({
                    unit = u.handle,
                    time = 0.1,
                    distance = 100,
                    angle = jd,
                    isfly = true
                  })
                  ac.wait(110, function()
                    x, y = u:getxy()
                    EffectcreateArgs({
                      effect = "war3mapImported\\214_zhanji_bai.mdx",
                      x = x,
                      y = y,
                      size = 6,
                      height = 150,
                      zxz = jd + 45,
                      xxz = -20,
                      animespeed = 0.7
                    })
                    local mz2 = false
                    for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
                      xq = getunit(xq)
                      local x2, y2 = u:getxy()
                      x2, y2 = PolarXY(x2, y2, 300, jd)
                      xq:setxy(x2, y2)
                      if not mz2 then
                        mz2 = true
                        zhigui_combo(u)
                        zhiguishockcamera(u, 100, 0.15)
                      end
                      zhiguidamageunit({
                        skillstr = skillstr,
                        u = u,
                        xq = xq,
                        sh = txsh,
                        kz = kz,
                        kzlx = "僵直",
                        txstr1 = txstr1,
                        txstr2 = txstr2,
                        isvest = false
                      })
                    end
                  end)
                end)
                ac.wait(1250, function()
                  ac.wait(1, function()
                    u:animeact(17)
                    u:animespeed(2.0)
                  end)
                  ac.wait(100, function()
                    x, y = u:getxy()
                    u:playsound(Sound_214_Gongji)
                    EffectcreateArgs({
                      effect = "war3mapImported\\214_zhanji_bai.mdx",
                      x = x,
                      y = y,
                      size = 6,
                      height = 150,
                      zxz = jd - 45,
                      xxz = 160,
                      animespeed = 0.7
                    })
                    local mz2 = false
                    for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
                      xq = getunit(xq)
                      local x2, y2 = u:getxy()
                      x2, y2 = PolarXY(x2, y2, 250, jd)
                      xq:setxy(x2, y2)
                      if not mz2 then
                        mz2 = true
                        zhigui_combo(u)
                        zhiguishockcamera(u, 100, 0.15)
                      end
                      zhiguidamageunit({
                        skillstr = skillstr,
                        u = u,
                        xq = xq,
                        sh = txsh,
                        kz = kz,
                        kzlx = "僵直",
                        txstr1 = txstr1,
                        txstr2 = txstr2,
                        isvest = false
                      })
                    end
                  end)
                end)
                ac.wait(1400, function()
                  ac.wait(1, function()
                    u:animeact(20)
                    u:animespeed(1.5)
                    u:playsound(Sound_214_chongfeng_2)
                    u:playsound(Sound_214_T6)
                    EffectcreateArgs({
                      effect = "war3mapImported\\bbb.mdx",
                      x = x,
                      y = y,
                      size = 1,
                      zxz = jd,
                      animespeed = 1.2
                    })
                  end)
                  ac.wait(100, function()
                    unitjump({
                      unit = u.handle,
                      time = 0.6,
                      distance = 700,
                      height = 100,
                      angle = u:getface(),
                      isfly = true
                    })
                    local cs = 0
                    ac.loop(120, function(t)
                      cs = cs + 1
                      local x1, y1 = u:getxy()
                      local gd = 100
                      jd = u:getface()
                      u:setface(jd)
                      if cs <= 3 then
                        gd = 100 + 100 * cs
                      else
                        gd = 400 - 45 * cs
                      end
                      EffectcreateArgs({
                        effect = "war3mapImported\\sete_zhanji.mdx",
                        x = x1,
                        y = y1,
                        size = 4,
                        height = gd,
                        zxz = jd,
                        xxz = 270,
                        animespeed = 2.0
                      })
                      if cs == 4 then
                        EffectcreateArgs({
                          effect = "war3mapImported\\bbb.mdx",
                          x = x1,
                          y = y1,
                          size = 1,
                          zxz = jd,
                          animespeed = 2.0
                        })
                      end
                      u:playsound(Sound_214_Gongji)
                      local mz2 = false
                      for _, xq in ac.selector():in_rangexy(x1, y1, 200):is_enemy(u.handle):ipairs() do
                        xq = getunit(xq)
                        local x2, y2 = xq:getxy()
                        unitmove({
                          unit = xq.handle,
                          time = 0.1,
                          distance = 300,
                          angle = jd,
                          isfly = true
                        })
                        if not mz2 then
                          mz2 = true
                          zhigui_combo(u)
                          zhiguishockcamera(u, 100, 0.15)
                          EffectcreateArgs({
                            effect = "5dab9b48c482691b.mdl",
                            x = x2,
                            y = y2,
                            size = 2,
                            zxz = GetRandomAngle()
                          })
                        end
                        zhiguidamageunit({
                          skillstr = skillstr,
                          u = u,
                          xq = xq,
                          sh = txsh,
                          kz = kz,
                          kzlx = "僵直",
                          txstr1 = txstr1,
                          txstr2 = txstr2,
                          isvest = false
                        })
                      end
                      if 5 <= cs then
                        t:remove()
                      end
                    end)
                  end)
                end)
                ac.wait(1900, function()
                  local x2, y2 = u:getxy()
                  ac.wait(200, function()
                    u:playsound(Sound_214_qianghua_W1)
                    u:playsound(Sound_214_Gongji)
                    local x1, y1 = PolarXY(x2, y2, 0, jd)
                    u:animeact(5)
                    u:animespeed(2.5)
                    EffectcreateArgs({
                      effect = "war3mapImported\\daji_hong1.mdx",
                      x = x1,
                      y = y1,
                      size = 40,
                      height = 150,
                      zxz = jd,
                      animespeed = 6.0
                    })
                    EffectcreateArgs({
                      effect = "war3mapImported\\bbb.mdx",
                      x = x1,
                      y = y1,
                      size = 2,
                      zxz = jd,
                      animespeed = 1.2
                    })
                    EffectcreateArgs({
                      effect = "war3mapImported\\dash sfx.mdx",
                      x = x1,
                      y = y1,
                      size = 2,
                      zxz = jd,
                      animespeed = 3.0
                    })
                    local tx = EffectcreateArgs({
                      effect = "war3mapImported\\214_bishou1.mdx",
                      x = x1,
                      y = y1,
                      size = 10.0,
                      zxz = jd,
                      animespeed = 2.0
                    })
                    if type(japi.EXSetEffectColor) == "function" then
                      japi.EXSetEffectColor(tx, 4294901760)
                    end
                    tx = EffectcreateArgs({
                      effect = "war3mapImported\\qiye_zhanji8.mdx",
                      x = x1,
                      y = y1,
                      size = 10.0,
                      zxz = jd,
                      animespeed = 2.0
                    })
                    if type(japi.EXSetEffectColor) == "function" then
                      japi.EXSetEffectColor(tx, 4294901760)
                    end
                    zhiguishockcamera(u, 600, 0.15)
                    u:setxy(x1, y1)
                    x1, y1 = PolarXY(x1, y1, 200, jd)
                    local mz2 = false
                    for _, xq in ac.selector():in_rangexy(x1, y1, 400):is_enemy(u.handle):ipairs() do
                      xq = getunit(xq)
                      if not mz2 then
                        mz2 = true
                        zhigui_combo(u)
                        zhiguishockcamera(u, 100, 0.15)
                      end
                      zhiguidamageunit({
                        skillstr = skillstr,
                        u = u,
                        xq = xq,
                        sh = txsh,
                        kz = kz,
                        kzlx = "僵直",
                        txstr1 = txstr1,
                        txstr2 = txstr2,
                        isvest = false
                      })
                    end
                  end)
                  ac.wait(500, function()
                    local x1, y1 = PolarXY(x2, y2, 0, jd)
                    u:animeact(18)
                    u:animespeed(1.2)
                    u:playsound(Sound_214_R3)
                    for i = 1, 3 do
                      EffectcreateArgs({
                        effect = "war3mapImported\\214_zhanji_bai.mdx",
                        x = x1,
                        y = y1,
                        size = 8.0,
                        zxz = jd - 30,
                        animespeed = 1.0
                      })
                    end
                    local mz2 = false
                    for _, xq in ac.selector():in_rangexy(x2, y2, 400):is_enemy(u.handle):ipairs() do
                      xq = getunit(xq)
                      x1, y1 = PolarXY(x2, y2, 500, jd)
                      xq:setxy(x1, y1)
                      if not mz2 then
                        mz2 = true
                        zhigui_combo(u)
                      end
                      zhiguidamageunit({
                        skillstr = skillstr,
                        u = u,
                        xq = xq,
                        sh = txsh,
                        kz = kz,
                        kzlx = "僵直",
                        txstr1 = txstr1,
                        txstr2 = txstr2,
                        isvest = false
                      })
                    end
                    EffectcreateArgs({
                      effect = "5dab9b48c482691b.mdl",
                      x = x1,
                      y = y1,
                      size = 10,
                      height = -200,
                      zxz = GetRandomAngle()
                    })
                    zhiguishockcamera(u, 600, 0.15)
                  end)
                end)
                ac.wait(2700, function()
                  ac.wait(200, function()
                    u:playsound(Sound_214_Gongji)
                    local x1, y1 = PolarXY(x, y, 1400, jd)
                    u:animeact(5)
                    u:animespeed(2.5)
                    EffectcreateArgs({
                      effect = "war3mapImported\\daji_hong1.mdx",
                      x = x1,
                      y = y1,
                      size = 40,
                      height = 150,
                      zxz = jd,
                      animespeed = 6.0
                    })
                    EffectcreateArgs({
                      effect = "war3mapImported\\bbb.mdx",
                      x = x1,
                      y = y1,
                      size = 2,
                      zxz = jd,
                      animespeed = 1.2
                    })
                    EffectcreateArgs({
                      effect = "war3mapImported\\dash sfx.mdx",
                      x = x1,
                      y = y1,
                      size = 2,
                      zxz = jd,
                      animespeed = 3.0
                    })
                    local tx = EffectcreateArgs({
                      effect = "war3mapImported\\214_bishou1.mdx",
                      x = x1,
                      y = y1,
                      size = 10.0,
                      zxz = jd,
                      animespeed = 2.0
                    })
                    if type(japi.EXSetEffectColor) == "function" then
                      japi.EXSetEffectColor(tx, 4294901760)
                    end
                    tx = EffectcreateArgs({
                      effect = "war3mapImported\\qiye_zhanji8.mdx",
                      x = x1,
                      y = y1,
                      size = 10.0,
                      zxz = jd,
                      animespeed = 2.0
                    })
                    if type(japi.EXSetEffectColor) == "function" then
                      japi.EXSetEffectColor(tx, 4294901760)
                    end
                    zhiguishockcamera(u, 300, 0.15)
                    unitmove({
                      unit = u.handle,
                      time = 0.1,
                      distance = 1000,
                      angle = jd,
                      isfly = true
                    })
                    local cs = 0
                    local g1 = CreateGroupLua()
                    ac.wait(10, function()
                      local mz2 = false
                      ac.loop(10, function(t)
                        cs = cs + 1
                        local x3, y3 = u:getxy()
                        x3, y3 = PolarXY(x3, y3, 100, jd)
                        if cs < 30 then
                          for _, xq in ac.selector():in_rangexy(x3, y3, 100):is_enemy(u.handle):ipairs() do
                            xq = getunit(xq)
                            if not xq:isingroup(g1) then
                              xq:groupadd(g1)
                              local x2, y2 = xq:getxy()
                              unitmove({
                                unit = xq.handle,
                                time = 0.1,
                                distance = 10,
                                angle = jd,
                                isfly = true
                              })
                              if not mz2 then
                                mz2 = true
                                zhigui_combo(u)
                              end
                              zhiguidamageunit({
                                skillstr = skillstr,
                                u = u,
                                xq = xq,
                                sh = txsh,
                                kz = kz,
                                kzlx = "僵直",
                                txstr1 = txstr1,
                                txstr2 = txstr2,
                                isvest = false
                              })
                            end
                          end
                        end
                        if 35 <= cs then
                          DestroyEffectLua(tx)
                          t:remove()
                        end
                      end)
                    end)
                  end)
                  ac.wait(400, function()
                    u:setface(jd + 180)
                    u:playsound(Sound_214_Gongji)
                    local x1, y1 = PolarXY(x, y, 1400, jd)
                    u:animeact(5)
                    u:animespeed(2.5)
                    EffectcreateArgs({
                      effect = "war3mapImported\\daji_hong1.mdx",
                      x = x1,
                      y = y1,
                      size = 40,
                      height = 150,
                      zxz = jd + 180,
                      animespeed = 6.0
                    })
                    EffectcreateArgs({
                      effect = "war3mapImported\\bbb.mdx",
                      x = x1,
                      y = y1,
                      size = 2,
                      zxz = jd + 180,
                      animespeed = 1.2
                    })
                    EffectcreateArgs({
                      effect = "war3mapImported\\dash sfx.mdx",
                      x = x1,
                      y = y1,
                      size = 2,
                      zxz = jd + 180,
                      animespeed = 3.0
                    })
                    local tx = EffectcreateArgs({
                      effect = "war3mapImported\\214_bishou1.mdx",
                      x = x1,
                      y = y1,
                      size = 10.0,
                      zxz = jd + 180,
                      animespeed = 2.0
                    })
                    if type(japi.EXSetEffectColor) == "function" then
                      japi.EXSetEffectColor(tx, 4294901760)
                    end
                    tx = EffectcreateArgs({
                      effect = "war3mapImported\\qiye_zhanji8.mdx",
                      x = x1,
                      y = y1,
                      size = 10.0,
                      zxz = jd + 180,
                      animespeed = 2.0
                    })
                    if type(japi.EXSetEffectColor) == "function" then
                      japi.EXSetEffectColor(tx, 4294901760)
                    end
                    zhiguishockcamera(u, 300, 0.15)
                    unitmove({
                      unit = u.handle,
                      time = 0.1,
                      distance = 1500,
                      angle = jd + 180,
                      isfly = true
                    })
                    local cs = 0
                    local g1 = CreateGroupLua()
                    ac.wait(10, function()
                      ac.loop(10, function(t)
                        cs = cs + 1
                        local x3, y3 = u:getxy()
                        x3, y3 = PolarXY(x3, y3, 100, jd)
                        local mz2 = false
                        if cs < 30 then
                          for _, xq in ac.selector():in_rangexy(x3, y3, 100):is_enemy(u.handle):ipairs() do
                            xq = getunit(xq)
                            if not xq:isingroup(g1) then
                              xq:groupadd(g1)
                              local x2, y2 = xq:getxy()
                              unitmove({
                                unit = xq.handle,
                                time = 0.1,
                                distance = 10,
                                angle = jd,
                                isfly = true
                              })
                              if not mz2 then
                                mz2 = true
                                zhigui_combo(u)
                              end
                              zhiguidamageunit({
                                skillstr = skillstr,
                                u = u,
                                xq = xq,
                                sh = txsh,
                                kz = kz,
                                kzlx = "僵直",
                                txstr1 = txstr1,
                                txstr2 = txstr2,
                                isvest = false
                              })
                            end
                          end
                        end
                        if 35 <= cs then
                          DestroyEffectLua(tx)
                          t:remove()
                        end
                      end)
                    end)
                  end)
                end)
                ac.wait(3300, function()
                  u:animeact(16)
                  u:animespeed(1.9)
                  ac.wait(300, function()
                    u:setface(jd)
                    zhiguishockcamera(u, 300, 0.2)
                    u:animespeed(0.15)
                    u:playsound(Sound_214_R2)
                    u:playsound(Sound_214_R1)
                    EffectcreateArgs({
                      effect = "war3mapImported\\daji_hong1.mdx",
                      x = x,
                      y = y,
                      size = 40,
                      height = 150,
                      zxz = jd,
                      animespeed = 6.0
                    })
                    EffectcreateArgs({
                      effect = "war3mapImported\\bbb.mdx",
                      x = x,
                      y = y,
                      size = 2,
                      zxz = jd,
                      animespeed = 1.2
                    })
                    EffectcreateArgs({
                      effect = "war3mapImported\\dash sfx.mdx",
                      x = x,
                      y = y,
                      size = 2,
                      zxz = jd,
                      animespeed = 3.0
                    })
                    local tx = EffectcreateArgs({
                      effect = "war3mapImported\\214_bishou1.mdx",
                      x = x,
                      y = y,
                      size = 20.0,
                      zxz = jd,
                      animespeed = 2.0
                    })
                    if type(japi.EXSetEffectColor) == "function" then
                      japi.EXSetEffectColor(tx, 4288230399)
                    end
                    local x1, y1 = PolarXY(x, y, 400, jd + 90)
                    tx = EffectcreateArgs({
                      effect = "war3mapImported\\214_bishou1.mdx",
                      x = x1,
                      y = y1,
                      size = 7.0,
                      zxz = jd - 20,
                      animespeed = 2.0
                    })
                    if type(japi.EXSetEffectColor) == "function" then
                      japi.EXSetEffectColor(tx, 4294901760)
                    end
                    x1, y1 = PolarXY(x, y, 400, jd - 90)
                    tx = EffectcreateArgs({
                      effect = "war3mapImported\\214_bishou1.mdx",
                      x = x1,
                      y = y1,
                      size = 7.0,
                      zxz = jd + 20,
                      animespeed = 2.0
                    })
                    if type(japi.EXSetEffectColor) == "function" then
                      japi.EXSetEffectColor(tx, 4294901760)
                    end
                    unitmove({
                      unit = u.handle,
                      time = 0.1,
                      distance = 1000,
                      angle = jd,
                      isfly = true
                    })
                    x1, y1 = PolarXY(x, y, 1300, jd)
                    local mz2 = false
                    for _, xq in ac.selector():in_rangexy(x1, y1, 600):is_enemy(u.handle):ipairs() do
                      xq = getunit(xq)
                      local x2, y2 = xq:getxy()
                      EffectcreateArgs({
                        effect = "war3mapImported\\214_sixian.mdx",
                        x = x2,
                        y = y2,
                        time = 2.0,
                        size = 1.5,
                        height = 50,
                        zxz = jd,
                        animespeed = 1.0
                      })
                      ac.wait(2100, function()
                        x2, y2 = xq:getxy()
                        EffectcreateArgs({
                          effect = "5dab9b48c482691b.mdl",
                          x = x2,
                          y = y2,
                          size = 4,
                          zxz = GetRandomAngle()
                        })
                        if not mz2 then
                          mz2 = true
                          zhigui_combo(u)
                        end
                        zhiguidamageunit({
                          skillstr = skillstr,
                          u = u,
                          xq = xq,
                          sh = txsh,
                          kz = kz,
                          kzlx = "僵直",
                          txstr1 = txstr1,
                          txstr2 = txstr2,
                          isvest = false
                        })
                        unitmove({
                          unit = xq.handle,
                          time = 0.1,
                          distance = 50,
                          angle = jd,
                          isfly = true
                        })
                      end)
                    end
                    ac.wait(100, function()
                      unitmove({
                        unit = u.handle,
                        time = 2,
                        distance = 250,
                        angle = jd,
                        isfly = true
                      })
                      tx = EffectcreateArgs({
                        effect = "war3mapImported\\heiquan.mdx",
                        x = x,
                        y = y,
                        time = 2.4,
                        size = 7,
                        height = -10,
                        zxz = jd,
                        animespeed = 3.0
                      })
                      ac.wait(100, function()
                        japi.EXSetEffectSpeed(tx, 0.0)
                      end)
                      ac.wait(2500, function()
                        japi.EXSetEffectSpeed(tx, 2.0)
                      end)
                    end)
                    ac.wait(2100, function()
                      unitmove({
                        unit = u.handle,
                        time = 0.1,
                        distance = 250,
                        angle = jd,
                        isfly = true
                      })
                      CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 0.1, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 0.0, 0.0, 0.0)
                      DisplayCineFilter(false)
                      if u:isbeseenlocal() then
                        DisplayCineFilter(true)
                      end
                      u:animespeed(1.0)
                      zhiguishockcamera(u, 300, 0.2)
                      u:playsound(Sound_214_R3)
                      u:playsound(Sound_214_R4)
                      EffectcreateArgs({
                        effect = "war3mapImported\\qiye_zhanji8.mdx",
                        x = x,
                        y = y,
                        size = 50.0,
                        height = -1400,
                        zxz = jd,
                        animespeed = 1.0
                      })
                      EffectcreateArgs({
                        effect = "war3mapImported\\qiye_zhanji8.mdx",
                        x = x,
                        y = y,
                        size = 50.0,
                        height = -1400,
                        zxz = jd + 65,
                        animespeed = 1.0
                      })
                      EffectcreateArgs({
                        effect = "war3mapImported\\daji_hong1.mdx",
                        x = x,
                        y = y,
                        size = 40,
                        height = 150,
                        zxz = jd,
                        animespeed = 2.0
                      })
                      ac.wait(300, function()
                        EffectcreateArgs({
                          effect = "war3mapImported\\qiye_zhanji8.mdx",
                          x = x,
                          y = y,
                          size = 10.0,
                          height = -140,
                          zxz = jd,
                          animespeed = 2.0
                        })
                        EffectcreateArgs({
                          effect = "war3mapImported\\qiye_zhanji8.mdx",
                          x = x,
                          y = y,
                          size = 10.0,
                          height = -140,
                          zxz = jd + 65,
                          animespeed = 2.0
                        })
                      end)
                    end)
                  end)
                end)
                ac.wait(6000, function()
                  jd = jd + 180
                  ac.wait(300, function()
                    u:animeact(20)
                    u:animespeed(3.0)
                    EffectcreateArgs({
                      effect = "war3mapImported\\bbb.mdx",
                      x = x,
                      y = y,
                      size = 2,
                      zxz = jd,
                      animespeed = 1.0
                    })
                    unitjump({
                      unit = u.handle,
                      time = 0.2,
                      distance = 1000,
                      height = 500,
                      angle = jd
                    })
                  end)
                  ac.wait(500, function()
                    u:playsound(Sound_214_R3)
                    CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 0.2, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 50.0, 0.0, 0.0, 0.0)
                    DisplayCineFilter(false)
                    if u:isbeseenlocal() then
                      DisplayCineFilter(true)
                    end
                    local x1, y1 = u:getxy()
                    zhiguishockcamera(u, 600, 0.2)
                    for i = 1, 10 do
                      EffectcreateArgs({
                        effect = "war3mapImported\\sete_zhanji.mdx",
                        x = x1,
                        y = y1,
                        size = 15,
                        zxz = GetRandomAngle()
                      })
                    end
                    for i1 = 1, 50 do
                      EffectcreateArgs({
                        effect = "war3mapImported\\214_zhanji_guang.mdx",
                        x = x1,
                        y = y1,
                        size = GetRandomReal(10, 20),
                        height = GetRandomReal(-500, 1000),
                        zxz = GetRandomAngle(),
                        xxz = GetRandomAngle(),
                        yxz = GetRandomAngle(),
                        animespeed = GetRandomReal(0.5, 1)
                      })
                    end
                    local mz2 = false
                    for _, xq in ac.selector():in_rangexy(x1, y1, 1600):is_enemy(u.handle):ipairs() do
                      xq = getunit(xq)
                      local x2, y2 = xq:getxy()
                      x2, y2 = PolarXY(x2, y2, 50, jd)
                      xq:setxy(x2, y2)
                      if not mz2 then
                        mz2 = true
                        zhigui_combo(u)
                      end
                      zhiguidamageunit({
                        skillstr = skillstr,
                        u = u,
                        xq = xq,
                        sh = txsh * 5,
                        kz = kz,
                        kzlx = "僵直",
                        txstr1 = txstr1,
                        txstr2 = txstr2,
                        isvest = false
                      })
                    end
                  end)
                end)
              end)
            end)
          end)
        end
      end)
    end)
  end,
  R3 = function(u)
    local skillstr = "R3"
    local jd = u:getface()
    u:setface(jd)
    u:buffset(u.handle, 0.7, "暂停")
    u:buffset(u.handle, 0.7 + u:getdata("两仪式-额外无敌时间"), "无敌")
    u:setdata("两仪式连携时间", 0.7 + 0.8 * u:getdata("两仪式-连锁时间"))
    u:setdata("两仪式不计入爆气时间", 0.7)
    u:buffset(u.handle, 0.8999999999999999, "绝对闪避")
    u:setdata("两仪式-R3技能已释放")
    u:playsound(Sound_214_chongfeng_1)
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, "R3")
    local txsh = sh * 66
    local g = CreateGroupLua()
    local qd = false
    local mb
    local dx, dy = PolarXY(x, y, 200, jd)
    for _, xq in ac.selector():in_rangexy(dx, dy, 400):is_enemy(u.handle):ipairs() do
      xq = getunit(xq)
      xq:groupadd(g)
      if xq:isboss() then
        xq:buffset(xq.handle, 8.0, "沉默")
      end
    end
    ac.wait(300, function()
      u:animeact(17)
      u:animespeed(2.0)
      u:playsound(Sound_214_R3)
    end)
    ac.wait(400, function()
      EffectcreateArgs({
        effect = "war3mapImported\\214_zhanji_bai.mdx",
        x = x,
        y = y,
        size = 6,
        height = 150,
        zxz = jd - 45,
        xxz = 160,
        animespeed = 0.7
      })
      EffectcreateArgs({
        effect = "war3mapImported\\Daji_Hong1.mdx",
        x = x,
        y = y,
        size = 40,
        zxz = jd,
        animespeed = 3.0
      })
      local x2, y2 = u:getxy()
      ForGroupLuaNew(g, function(xq)
        xq:groupadd(g)
        mb = xq
        unitmove({
          unit = xq.handle,
          time = 0.09,
          distance = 3500,
          angle = jd,
          isblink = true
        })
        if xq:isboss() then
          xq:buffset(xq.handle, 4.5, "沉默")
        end
        xq:buffset(xq.handle, 4.5, "暂停")
        ac.wait(90, function()
          xq:buffset(u.handle, 4.5, "锁定")
        end)
      end)
      local dx, dy = PolarXY(x2, y2, 3500, jd)
      local dx2, dy2 = PolarXY(x, y, 200, jd)
      for _, xq in ac.selector():in_rangexy(dx2, dy2, 400):is_enemy(u.handle):isnotingroup(g):ipairs() do
        xq = getunit(xq)
        xq:groupadd(g)
        mb = xq
        unitmove({
          unit = xq.handle,
          time = 0.09,
          distance = 3500,
          angle = jd,
          isblink = true
        })
        if xq:isboss() then
          xq:buffset(xq.handle, 4.5, "沉默")
        end
        xq:buffset(xq.handle, 4.5, "暂停")
        ac.wait(90, function()
          xq:buffset(u.handle, 4.5, "锁定")
        end)
      end
      ac.wait(100, function()
        if mb ~= nil and qd == false then
          qd = true
          local x1, y1 = mb:getxy()
          local tx = EffectcreateArgs({
            effect = "war3mapImported\\heiquan.mdx",
            x = x1,
            y = y1,
            time = 2.4,
            size = 7,
            height = -10,
            zxz = jd,
            animespeed = 3.0
          })
          if type(japi.EXSetEffectFogVisible) == "function" then
            japi.EXSetEffectFogVisible(tx, true)
          end
          if type(japi.EXSetEffectMaskVisible) == "function" then
            japi.EXSetEffectMaskVisible(tx, true)
          end
          ac.wait(100, function()
            japi.EXSetEffectSpeed(tx, 0.0)
          end)
          ac.wait(3800, function()
            japi.EXSetEffectSpeed(tx, 3.0)
          end)
          SetCameraTargetControllerNoZForPlayer(u.owner, u.handle, 0, 0, false)
          ac.wait(4500, function()
            ResetToGameCameraForPlayer(u.owner, 0)
            local p = getplayer(u.owner)
            p:setcameraheight(Cam_height[u.ownerid], 0)
          end)
        end
      end)
      ac.wait(1, function()
        if Group_Counts(g) > 0 then
          zhiguishockcamera(u, 600, 0.15)
          u:playsound(Sound_214_F_2)
          u:buffset(u.handle, 4.5, "暂停")
          u:buffset(u.handle, 4.5 + u:getdata("两仪式-额外无敌时间"), "无敌")
          u:buffset(u.handle, 4.7, "绝对闪避")
          u:setdata("两仪式不计入爆气时间", 4.5)
          u:setdata("两仪式连携时间", 4.5 + 0.8 * u:getdata("两仪式-连锁时间"))
          ac.wait(1, function()
            u:animeact(5)
            u:animespeed(2.0)
          end)
          ac.wait(1, function()
            local cs = 0
            ac.loop(500, function(t)
              cs = cs + 1
              x, y = u:getxy()
              ShowUnitShow(u.handle)
              CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 0.15, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 10.0, 0.0, 0.0, 0.0)
              DisplayCineFilter(false)
              if u:isbeseenlocal() then
                DisplayCineFilter(true)
              end
              local x1, y1 = PolarXY(x, y, -200, jd)
              EffectcreateArgs({
                effect = "war3mapImported\\dash sfx.mdx",
                x = x1,
                y = y1,
                size = 2,
                zxz = jd,
                animespeed = 3.0
              })
              EffectcreateArgs({
                effect = "war3mapImported\\bbb.mdx",
                x = x,
                y = y,
                size = 2,
                zxz = jd,
                animespeed = 1.0
              })
              EffectcreateArgs({
                effect = "war3mapImported\\Daji_Hong1.mdx",
                x = x,
                y = y,
                size = 30,
                zxz = jd,
                animespeed = 6.0
              })
              zhiguishockcamera(u, 100, 0.15)
              u:playsound(Sound_214_chongfeng_2)
              unitmove({
                unit = u.handle,
                time = 0.2,
                distance = 600,
                angle = jd,
                isfly = true
              })
              ac.wait(200, function()
                ShowUnitHide(u.handle)
                local x1, y1 = u:getxy()
                if cs == 1 then
                  x1, y1 = PolarXY(x, y, 1000, jd + 30)
                  u:setxy(x1, y1)
                end
                if cs == 2 then
                  x1, y1 = PolarXY(x, y, 1000, jd - 30)
                  u:setxy(x1, y1)
                end
                if cs == 3 then
                  local u1 = Group_Randomunit(g)
                  x1, y1 = u1:getxy()
                  x1, y1 = PolarXY(x1, y1, -300, jd)
                  u:setxy(x1, y1)
                  ac.wait(500, function()
                    ShowUnitShow(u.handle)
                    SelectUnitForPlayerSingle(u.handle, GetOwningPlayer(u.handle))
                    u:animeact(20)
                    u:animespeed(2.0)
                    ac.wait(300, function()
                      u:playsound(Sound_214_R2)
                      u:animespeed(0.1)
                    end)
                    ac.wait(2000, function()
                      u:animespeed(1.0)
                      u:playsound(Sound_214_R3)
                      u:playsound(Sound_214_R4)
                    end)
                    EffectcreateArgs({
                      effect = "war3mapImported\\bbb.mdx",
                      x = x1,
                      y = y1,
                      size = 2,
                      zxz = jd,
                      animespeed = 1.0
                    })
                    unitmove({
                      unit = u.handle,
                      time = 2.0,
                      distance = 100,
                      angle = jd,
                      isfly = true
                    })
                    ac.wait(2000, function()
                      unitmove({
                        unit = u.handle,
                        time = 0.1,
                        distance = 500,
                        angle = jd,
                        isfly = true
                      })
                      CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 1.0, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 50.0, 0.0, 0.0, 0.0)
                      DisplayCineFilter(false)
                      if u:isbeseenlocal() then
                        DisplayCineFilter(true)
                      end
                      zhiguishockcamera(u, 600, 0.2)
                      x1, y1 = u1:getxy()
                      for i = 1, 10 do
                        EffectcreateArgs({
                          effect = "5dab9b48c482691b.mdl",
                          x = x1,
                          y = y1,
                          size = 20,
                          height = -1000,
                          zxz = GetRandomAngle()
                        })
                        EffectcreateArgs({
                          effect = "war3mapImported\\qiye_zhanji8.mdx",
                          x = x1,
                          y = y1,
                          size = 50.0,
                          height = -1400,
                          zxz = jd,
                          animespeed = 1.0
                        })
                        for i1 = 1, 10 do
                          EffectcreateArgs({
                            effect = "war3mapImported\\sete_zhanji.mdx",
                            x = x1,
                            y = y1,
                            size = GetRandomReal(10, 20),
                            height = GetRandomReal(-500, 1000),
                            zxz = GetRandomAngle(),
                            xxz = GetRandomAngle(),
                            yxz = GetRandomAngle(),
                            animespeed = GetRandomReal(1, 4)
                          })
                        end
                      end
                      local mz2 = false
                      ForGroupLuaNew(g, function(xq)
                        if not mz2 then
                          mz2 = true
                          zhigui_combo(u)
                        end
                        if xq:isboss() then
                          u:setdata("两仪式-七景终落附伤")
                        end
                        zhiguidamageunit({
                          skillstr = skillstr,
                          u = u,
                          xq = xq,
                          sh = txsh,
                          kz = kz,
                          kzlx = "僵直",
                          txstr1 = txstr1,
                          txstr2 = txstr2,
                          isvest = false
                        })
                        if xq:isboss() then
                          u:deldata("两仪式-七景终落附伤")
                        end
                      end)
                    end)
                  end)
                end
              end)
              if 3 <= cs then
                t:remove()
              end
            end)
          end)
        end
      end)
    end)
  end,
  VD = function(u, tg)
    local skillstr = "VD"
    local x2, y2 = tg:getxy()
    local jd = u:getface()
    u:setface(jd)
    u:buffset(u.handle, 11.0, "暂停")
    u:buffset(u.handle, 13 + u:getdata("两仪式-额外无敌时间"), "无敌")
    u:buffset(u.handle, 13, "永恒")
    u:setdata("两仪式连携时间", 11 + 0.8 * u:getdata("两仪式-连锁时间"))
    u:setdata("两仪式不计入爆气时间", 11)
    u:buffset(u.handle, 13, "绝对闪避")
    u:setdata("两仪式-成功发动无垢识")
    local sh, bs, txstr1, txstr2, x, y, sy, kz = set(u, "VD")
    local txsh = sh * 99
    local dtx = u:getdata("单位-大头像")
    local fw = 1200
    if u:hasdata("变异判定-根源式") then
      fw = 2400
    end
    ac.wait(1, function()
      CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 5, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 100.0, 100.0, 0.0)
      flashphoto({
        photo = "war3mapImported\\Pho_214.blp",
        timeout = 0.5,
        timehold = 1,
        timein = 1,
        notchangetime = true
      })
      u:playsound(Sound_214_T1)
      u:playsound(Sound_214_Baoqi_2)
      PlayBGM({
        bgm = BGM_214_3,
        time = 120,
        ID = 33,
        unit = u.handle
      })
      local d = u:getdata("单位-大头像")
      japi.DzSetUnitModel(u.handle, "HERO\\214_new.mdl")
      u:setdata("单位-大头像", "214_new_portrait.tga")
      SetUnitScale(u.handle, 1.25, 1.25, 1.25)
      ac.wait(100, function()
        u:animeact(13)
        u:animespeed(0.4)
      end)
      ac.wait(2000, function()
        u:playsound(Sound_214_T4_1)
      end)
      ac.wait(3000, function()
        SetUnitAnimation(u.handle, "stand")
        CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 20, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 100.0, 100.0, 99.0)
      end)
      local g = CreateGroupLua()
      for _, xq in ac.selector():in_rangexy(x2, y2, fw):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        local dx, dy = PolarXY(x, y, 100, jd)
        xq:setxy(dx, dy)
        xq:groupadd(g)
        xq:buffset(xq.handle, 13, "暂停")
        xq:buffset(xq.handle, 13, "沉默")
        xq:buffset(xq.handle, 13, "锁定")
      end
      local dtime = 13
      ac.loop(250, function(timer)
        dtime = dtime - 0.25
        for _, xq in ac.selector():in_rangexy(x2, y2, fw):is_enemy(u.handle):isnotingroup(g):ipairs() do
          xq = getunit(xq)
          local dx, dy = PolarXY(x, y, 100, jd)
          xq:setxy(dx, dy)
          xq:groupadd(g)
          xq:buffset(xq.handle, dtime, "暂停")
          xq:buffset(xq.handle, dtime, "沉默")
          xq:buffset(xq.handle, dtime, "锁定")
        end
        if dtime <= 10 then
          timer:remove()
        end
      end)
      ac.wait(12100, function()
        u:setdata("两仪式-爆气时间", 0.1)
        u:playsound(Sound_214_R3)
        u:playsound(Sound_214_R4)
        local dx, dy = tg:getxy()
        for i = 1, 10 do
          EffectcreateArgs({
            effect = "5dab9b48c482691b.mdl",
            x = x2,
            y = y2,
            size = 20,
            height = -1000,
            zxz = GetRandomAngle()
          })
          EffectcreateArgs({
            effect = "war3mapImported\\qiye_zhanji8.mdx",
            x = x2,
            y = y2,
            size = 50.0,
            height = -1400,
            zxz = jd,
            animespeed = 1.0
          })
          EffectcreateArgs({
            effect = "war3mapImported\\qiye_zhanji8.mdx",
            x = x2,
            y = y2,
            size = 50.0,
            height = -1400,
            zxz = jd + 65,
            animespeed = 1.0
          })
        end
        zhiguishockcamera(u, 600, 0.15)
        local mz2 = false
        ForGroupLuaNew(g, function(xq)
          if not mz2 then
            mz2 = true
            zhigui_combo(u)
          end
          if xq:isboss() then
            u:setdata("两仪式-无垢识附伤")
          end
          zhiguidamageunit({
            skillstr = skillstr,
            u = u,
            xq = xq,
            sh = txsh,
            kz = kz,
            kzlx = "暂停",
            txstr1 = txstr1,
            txstr2 = txstr2,
            isvest = false
          })
          if u:hasdata("变异判定-根源式") and not xq:isboss() then
            xq:kill(u.handle, true)
          end
          if xq:isboss() then
            u:deldata("两仪式-无垢识附伤")
          end
        end)
      end)
      EffectcreateArgs({
        effect = "war3mapImported\\214_yinghua.mdx",
        x = x,
        y = y,
        time = 10,
        size = 4,
        zxz = jd,
        animespeed = 1.0
      })
      local x1, y1 = PolarXY(x, y, 600, jd + 180)
      u:setxy(x1, y1)
      EffectcreateArgs({
        effect = "war3mapImported\\214_baoqi.mdx",
        x = x1,
        y = y1,
        size = 6,
        zxz = jd,
        animespeed = 2.0
      })
      EffectcreateArgs({
        effect = "war3mapImported\\214_chongjibo.mdx",
        x = x1,
        y = y1,
        size = 3,
        height = 10,
        zxz = jd,
        animespeed = 1.0
      })
    end)
    ac.wait(3500, function()
      u:animeact(15)
      u:animespeed(10.0)
      ac.wait(100, function()
        u:animespeed(0.6)
      end)
      ac.wait(2000, function()
        u:animeact(16)
        u:animespeed(0.4)
        u:playsound(Sound_214_T3)
        u:playsound(Sound_214_T2)
        local cs = 0
        ac.loop(200, function(t)
          cs = cs + 1
          local x1, y1 = u:getxy()
          EffectcreateArgs({
            effect = "war3mapImported\\Fenquan.mdx",
            x = x1,
            y = y1,
            size = 3,
            zxz = jd,
            animespeed = 2.0
          })
          if 5 <= cs then
            t:remove()
          end
        end)
      end)
      ac.wait(3800, function()
        u:animeact(12)
        u:animespeed(2.3)
        ac.wait(300, function()
          u:animespeed(0.4)
        end)
      end)
      ac.wait(3500, function()
        local x1, y1 = PolarXY(x, y, 600, jd + 180)
        u:setxy(x1, y1)
        unitmove({
          unit = u.handle,
          time = 0.3,
          distance = 500,
          angle = jd,
          isfly = true
        })
      end)
      ac.wait(3800, function()
        CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 0.8, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 50.0, 0.0, 0.0, 0.0)
        zhiguishockcamera(u, 600, 0.2)
        u:playsound(Sound_214_T6)
        local x1, y1 = PolarXY(x, y, 600, jd)
        EffectcreateArgs({
          effect = "war3mapImported\\sete_zhanji.mdx",
          x = x1,
          y = y1,
          size = 15,
          height = 1000,
          zxz = 150,
          yxz = 10
        })
        EffectcreateArgs({
          effect = "war3mapImported\\sete_zhanji.mdx",
          x = x1,
          y = y1,
          size = 10,
          height = 800,
          zxz = 60,
          yxz = 10
        })
        EffectcreateArgs({
          effect = "war3mapImported\\sete_zhanji.mdx",
          x = x1,
          y = y1,
          size = 8,
          height = 1000,
          zxz = 180,
          xxz = 70,
          yxz = -10
        })
        EffectcreateArgs({
          effect = "war3mapImported\\qiye_zhanji8.mdx",
          x = x,
          y = y,
          size = 50.0,
          height = -1400,
          zxz = jd,
          animespeed = 2.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\qiye_zhanji8.mdx",
          x = x,
          y = y,
          size = 50.0,
          height = -1400,
          zxz = jd + 65,
          animespeed = 2.0
        })
        EffectcreateArgs({
          effect = "war3mapImported\\daji_hong1.mdx",
          x = x,
          y = y,
          size = 40,
          height = 150,
          zxz = jd,
          animespeed = 2.0
        })
        unitmove({
          unit = u.handle,
          time = 0.1,
          distance = 500,
          angle = jd,
          isfly = true
        })
      end)
      ac.wait(5000, function()
        u:playsound(Sound_214_T3_1)
        zhiguishockcamera(u, 10, 2.0)
        u:playsound(Sound_214_T1)
        CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 2, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 100.0, 100.0, 0.0)
        ac.wait(3000, function()
          local icon
          if dtx ~= 0 then
            icon = dtx
            u:setdata("单位-大头像", dtx)
          end
          if u:hasdata("变异判定-根源式") then
            ModelReSet({
              u = u,
              model = "HERO\\214_new.mdl",
              modelsize = 1.25,
              modelicon = icon
            })
          else
            ModelReSet({
              u = u,
              model = "war3mapImported\\214.mdx",
              modelsize = 0.8,
              modelicon = icon
            })
          end
          u:animespeed(1)
          CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 1, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 100.0, 100.0, 0.0)
          u:setdata("单位-大头像", dtx)
        end)
        ac.wait(3700, function()
          u:playsound(Sound_214_T5)
        end)
        for i = 1, 30 do
          EffectcreateArgs({
            effect = "war3mapImported\\214_yinghua.mdx",
            x = x,
            y = y,
            time = 2,
            size = GetRandomReal(4, 10),
            height = -100,
            zxz = GetRandomAngle(),
            animespeed = GetRandomReal(0.1, 3)
          })
        end
      end)
    end)
  end
}
return zgskill
