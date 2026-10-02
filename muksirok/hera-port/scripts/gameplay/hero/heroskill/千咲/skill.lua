-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local message = require("jass.message")

local function Qianxiao_Shanghaijisuan(u, skillstr)
  local txsh = u:getdata("角色基础伤害")
  local str = skillstr
  if u:hasdata("变异判定-千咲神化") then
    txsh = txsh * 1.25
  end
  if u:getdata("千咲-万缕汇终时间") > 0 then
    txsh = txsh * 1.5
    if u:hasdata("千咲天赋-万理归尘") then
      txsh = txsh * 1.5
    end
  end
  if 0 < u:getdata("千咲-电锯热力时间") and (skillstr == "E" or skillstr == "EE" or skillstr == "EER" or skillstr == "EERR") then
    txsh = txsh * 2.5
    if u:hasdata("千咲天赋-奇点裂相") then
      txsh = txsh * 2
    end
    if u:hasdata("千咲天赋-虚夜环锯") then
      txsh = txsh * 2
    end
  end
  if u:hasdata("千咲天赋-伊始之剪") and (skillstr == "SE" or skillstr == "SEE" or skillstr == "AAA" or skillstr == "SAAA" or skillstr == "AAR") then
    txsh = txsh * 1.5
  end
  if u:hasdata("千咲天赋-虚数断章") and skillstr == "AAR" then
    txsh = txsh * 2
  end
  if u:hasdata("千咲天赋-相位弦网") and 0 < u:getdata("千咲-浮空高度") then
    txsh = txsh * (1 + 0.03 * u:getdata("千咲-连击数"))
  end
  if str == "AAA" then
    txsh = txsh * 2
  end
  if str == "SAAA" then
    txsh = txsh * 2
  end
  if str == "R" then
    txsh = txsh * 2
  end
  if str == "AR" then
    txsh = txsh * 0.25
  end
  if str == "AAR" then
    txsh = txsh * 1
  end
  if str == "AAAR" then
    txsh = txsh * 0.3
  end
  if str == "E" then
    txsh = txsh * 0.1
  end
  if str == "EE" then
    txsh = txsh * 0.25
  end
  if str == "EER" then
    txsh = txsh * 1
  end
  if str == "EERR" then
    txsh = txsh * 10
    if u:hasdata("千咲天赋-奇点裂相") then
      txsh = txsh * 2
    end
  end
  if str == "S" then
    txsh = txsh * 0.6
  end
  if str == "SS" then
    txsh = txsh * 1
  end
  if str == "SE" then
    txsh = txsh * 1.5
  end
  if str == "SEE" then
    txsh = txsh * 0.25
  end
  if str == "SW" or str == "SQ" then
    txsh = txsh * 1
  end
  if str == "SR" then
    txsh = txsh * 0.75
  end
  if str == "X" then
    txsh = txsh * 0.01
  end
  if str == "F" then
    txsh = txsh * 0.01
  end
  if str == "V" then
    txsh = txsh * 77
  end
  return txsh
end

local function zhiguizantingtime(u, time, skillstr)
  if 0 < time then
    u:setdata("千咲-连招暂停时间", math.max(u:getdata("千咲-连招暂停时间"), time))
    if not u:hasdata("千咲-强断连招开启") then
      u:buffset(u.handle, time, "暂停")
    end
  end
end

local function wudisrtrtime(u, time, skillstr)
  if u:hasdata("千咲-伪无敌模式") then
    u:buffset(u.handle, time, "伪无敌")
  else
    u:buffset(u.handle, time, "无敌")
  end
  if u:hasdata("千咲天赋-虚夜环锯") and u:getdata("千咲-电锯热力时间") > 0 and (skillstr == "E" or skillstr == "EE" or skillstr == "EER" or skillstr == "EERR") then
    u:buffset(u.handle, time, "绝对闪避")
  end
  if u:hasdata("千咲天赋-光锥天域") and (skillstr == "S" and u:getdata("千咲-浮空高度") == 0 or skillstr == "SS" or skillstr == "SRR" or skillstr == "SEE") then
    u:buffset(u.handle, time, "绝对闪避")
  end
  if u:hasdata("千咲天赋-断续疾走") and (skillstr == "SE" or skillstr == "AAA" or skillstr == "SAAA" or skillstr == "SEE" or skillstr == "AAR") then
    u:buffset(u.handle, time, "绝对闪避")
  end
  if u:hasdata("千咲天赋-拖拽终焉之弦") and 0 < u:getdata("千咲-万缕汇终时间") then
    u:buffset(u.handle, time, "绝对闪避")
  end
end

local function Qianxiao_Move(u, time, jl, jd)
  unitmove({
    unit = u.handle,
    time = time,
    distance = jl,
    angle = jd,
    isfly = true,
    endfunc = function(dx, dy)
      u:setdata("位移点X", dx)
      u:setdata("位移点Y", dy)
    end
  })
end

function Qianxiao_sound(u, snd)
  local isrun = true
  local sndsize = 100
  local localid = LocalPlayerID
  if not u:isbeseenlocal() then
    isrun = false
  elseif Hero[localid] ~= 0 then
    local hero = getunit(Hero[localid])
    local dis = DistanceBetweenUnits(u.handle, hero.handle)
    if 3500 <= dis then
      isrun = false
    elseif 2000 <= dis then
      sndsize = 25 + 75 * (3500 - dis) / 1500
    end
    if not hero:isalive() then
      isrun = true
      sndsize = 100
    end
  end
  if isrun then
    PlayGlobalSound(snd)
    SetSoundVolume(snd, sndsize * 1.27)
  end
end

local txcount = 0

local function qianxiao_combo(u, skillstr)
  u:setdata("千咲-连击时间", 1)
  if u:hasdata("千咲-连击判定" .. skillstr) then
    return
  end
  u:settimedata("千咲-连击判定" .. skillstr, 0.01)
  u:changedata("千咲-连击数", 1)
  local lj = u:getdata("千咲-连击数")
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

local function qianxiao_hlget(u, skillstr)
  if u:hasdata("千咲-共鸣解放获取-" .. skillstr) then
    return
  end
  local time = 1
  if skillstr == "AAA" or skillstr == "SW" or skillstr == "SQ" then
    time = 0.1
  end
  if skillstr == "S" then
    time = 0.3
  end
  u:settimedata("千咲-共鸣解放获取-" .. skillstr, time)
  if u:getdata("千咲-万缕汇终时间") == 0 then
    u:changedata("千咲-共鸣解放值", 1)
  end
  if u:hasdata("千咲天赋-第五象限") and 0 < u:getdata("千咲-浮空高度") then
    if u:getdata("千咲-万缕汇终时间") > 0 then
      u:changedata("千咲-共鸣解放值", 1)
    end
    u:changedata("千咲-共鸣解放值", 0.5)
  end
  if u:hasdata("千咲天赋-终点在此处") and u:getdata("千咲-解弦标记" .. skillstr) < u:getdata("千咲-解弦标记上限") then
    u:changedata("千咲-解弦标记" .. skillstr, 1)
    if u:getdata("千咲-万缕汇终时间") == 0 then
      u:changedata("千咲-共鸣解放值", 1)
    end
  end
  if (u:hasdata("千咲天赋-奇点裂相") or skillstr ~= "E" and skillstr ~= "EE" and skillstr ~= "EER" and skillstr ~= "EERR") and u:getdata("千咲-电锯热力时间") == 0 then
    u:changedata("千咲-锯环残响值", 2)
    if u:hasdata("千咲天赋-虚夜环锯") then
      u:changedata("千咲-锯环残响值", 1)
    end
  end
  local max1 = u:getdata("千咲-共鸣解放值上限")
  if max1 <= u:getdata("千咲-共鸣解放值") then
    u:setdata("千咲-共鸣解放值", max1)
  end
  local max2 = u:getdata("千咲-锯环残响值上限")
  if max2 <= u:getdata("千咲-锯环残响值") then
    u:setdata("千咲-锯环残响值", max2)
  end
end

function Qianxiao_Damage(args)
  local u = args.u
  local jd = args.jd or 0
  local tg = args.tg
  local x2 = args.mx or 0
  local y2 = args.my or 0
  local fw = args.fw or 0
  local yx = args.yx
  local txsh = args.damage
  local jt = args.jt or 0
  local mz = args.mz or false
  local isfk = args.isfk or false
  local isqf = args.isqf or false
  local iseverytx = args.iseverytx or false
  local istandao = args.istandao or false
  local isvest = args.isvest or false
  local isnotxh = args.isnotxh or false
  local skillstr = args.skillstr or ""
  local startfunc = args.startfunc or function(xq, sh)
    return sh
  end
  local extrafunc = args.extrafunc or function(xq, sh)
  end
  local sx = "无"
  local g = CreateGroupLua()
  if 1 < fw then
    for _, xq in ac.selector():in_rangexy(x2, y2, fw):is_enemy(u.handle):ipairs() do
      xq = getunit(xq)
      if isqf then
        xq:groupadd(g)
      elseif isfk then
        if 0 < xq:getdata("千咲-浮空高度") then
          xq:groupadd(g)
        end
      elseif xq:getdata("千咲-浮空高度") <= 100 then
        xq:groupadd(g)
      end
    end
  elseif tg then
    tg:groupadd(g)
  end
  local jxz = u:getdata("千咲-解弦单位组")
  local xg = 1
  if u:hasdata("千咲天赋-伊始之剪") then
    xg = xg + 0.5
  end
  ForGroupLuaNew(g, function(xq)
    local dtxsh = startfunc(xq, txsh)
    local exdata = {}
    if 0 < jt and not xq:hasdata("免疫击退效果") then
      local dx, dy = xq:getxy()
      dx, dy = PolarXY(dx, dy, jt, jd)
      xq:setxy(dx, dy)
    end
    if not mz then
      mz = true
      if txcount < 10 or xq:isboss() then
        local x1, y1 = xq:getxy()
        EffectcreateArgs({
          effect = "5dab9b48c482691b.mdl",
          x = x1,
          y = y1,
          size = 2,
          height = xq:getdata("千咲-浮空高度"),
          zxz = GetRandomAngle()
        })
        txcount = txcount + 1
        ac.wait(100, function()
          txcount = txcount - 1
        end)
      end
    end
    local cs = 1
    if u:hasdata("千咲天赋-终点在此处") and 0 < xq:getdata("千咲-解弦标记时间") and xq:getdata("千咲-解弦标记" .. skillstr) < u:getdata("千咲-解弦标记上限") then
      xq:changedata("千咲-解弦标记" .. skillstr, 1)
      cs = cs + 1
    end
    for i = 1, cs do
      if xq:isboss() then
        if skillstr == "AAA" or skillstr == "SAAA" then
          u:setdata("千咲-固定伤害百分比", 0.001 * xg)
        end
        if skillstr == "SE" then
          u:setdata("千咲-固定伤害百分比", 0.002 * xg)
        end
        if (skillstr == "AAR" or skillstr == "SEE") and not isvest then
          u:setdata("千咲-固定伤害百分比", 0.002 * xg)
        end
        if u:hasdata("千咲天赋-虚数断章") then
          if skillstr == "AAR" then
            local bfb = 0.002 * xg
            local count = xq:getdata("千咲-湮灭之痕层数")
            if 0 < count then
              bfb = bfb + count * 5.0E-4
              dtxsh = dtxsh * (1 + 0.1 * count)
              xq:deldata("千咲-湮灭之痕层数")
              local str
              str = "|cffc21616x" .. math.floor(100 + count * 10) .. "%|r"
              flytext({
                unit = xq.handle,
                text = str,
                size = 15,
                time = 2,
                xspeed = GetRandomReal(-0.03, 0.03),
                yspeed = 0.05
              })
            end
            u:setdata("千咲-固定伤害百分比", bfb)
          end
          if (skillstr == "AAA" or skillstr == "SAAA" or skillstr == "AAR" or skillstr == "SE" or skillstr == "SEE") and not isvest then
            xq:changedata("千咲-湮灭之痕层数", 1)
            local str
            str = "|cffc21616" .. math.floor(xq:getdata("千咲-湮灭之痕层数")) .. "!|r"
            flytext({
              unit = xq.handle,
              text = str,
              size = 10,
              time = 1,
              xspeed = GetRandomReal(-0.03, 0.03),
              yspeed = 0.05
            })
          end
        end
        if u:hasdata("千咲天赋-奇点裂相") and (skillstr == "E" or skillstr == "EE" or skillstr == "EER" or skillstr == "EERR") and not isvest then
          u:changedata("千咲-电锯热力电锯命中次数", 1)
        end
        if 0 < u:getdata("千咲-电锯热力时间") then
          local bfb = 0
          if skillstr == "E" or skillstr == "EE" or skillstr == "EER" then
            bfb = 2.0E-4
          end
          if skillstr == "EERR" then
            bfb = 0.003
          end
          if u:hasdata("千咲天赋-负界弦锯") then
            bfb = bfb * 2
          end
          if skillstr == "EERR" and u:hasdata("千咲天赋-奇点裂相") then
            bfb = bfb + u:getdata("千咲-电锯热力电锯命中次数") * 3.0E-4
            u:setdata("千咲-电锯热力电锯命中次数", 0)
          end
          if 0 < bfb then
            u:setdata("千咲-固定伤害百分比", bfb)
          end
        end
        if u:hasdata("变异判定-千咲神化") then
          xq:changetimearmor(-1, 7)
          xq:changetimedata("怪物-额外受伤", 0.005, 7)
        end
      end
      DamageUnit({
        bj = "千咲(机体)",
        unit = xq.handle,
        source = u.handle,
        damage = dtxsh,
        level = 1,
        type = "物理",
        isvest = isvest,
        isattack = true,
        isnoarmor = false,
        element = sx,
        extradata = exdata
      })
      u:deldata("千咲-固定伤害百分比")
    end
    xq:buffset(u.handle, 0.02, "眩晕")
    xq:buffset(u.handle, 0.7, "僵直")
    if u:hasdata("千咲天赋-虚夜环锯") and 0 < u:getdata("千咲-电锯热力时间") and (skillstr == "E" or skillstr == "EE" or skillstr == "EER" or skillstr == "EERR") then
      xq:buffset(xq.handle, 0.7, "沉默")
    end
    extrafunc(xq, dtxsh)
  end)
  if mz then
    qianxiao_combo(u, skillstr)
    qianxiao_hlget(u, skillstr)
    if skillstr == "AAR" then
      u:curehp(u.handle, 0, 0.05 * u:getmissperhp(), 2)
    end
    if u:hasdata("千咲天赋-伊始之剪") and (skillstr == "SE" or skillstr == "AAA" or skillstr == "SAAA" or skillstr == "SEE" or skillstr == "AAR") and not isvest then
      local add = 2000 + 100 * u:getlevel()
      u:changetimedata("近战机体-基础伤害提升", add, 10)
    end
  end
  return mz
end

local function qianxiao_fukong(u, height, time)
  local cs = time / 0.03
  local h = u:getdata("千咲-浮空高度")
  local add = height / cs
  if u:getdata("千咲-浮空高度") <= 0 then
    u:setdata("千咲-浮空高度", 1)
    IssueImmediateOrder(u.handle, "stop")
    if (u:hasdata("千咲天赋-相位弦网") or u:hasdata("千咲天赋-第五象限")) and not u:hasdata("千咲-落地不断连时间") then
      u:setdata("千咲-连击数", 0)
    end
    if u:hasdata("千咲-空中锁定镜头") then
      u:setdata("千咲-锁定镜头中")
      SetCameraTargetControllerNoZForPlayer(u.owner, u.handle, 0, 0, false)
    end
  end
  if u:getdata("千咲-浮空时间") <= 0.3 then
    u:changedata("千咲-浮空时间", 0.3)
  end
  ac.loop(30, function(t)
    cs = cs - 1
    h = u:getdata("千咲-浮空高度") + add
    u:setflyheight(h)
    u:changedata("千咲-浮空时间", 0.03)
    u:setdata("千咲-浮空高度", h)
    if cs <= 0 then
      if u:hasdata("千咲天赋-零坠空间") and u:getdata("千咲-浮空时间") <= 0.2 then
        u:setdata("千咲-浮空时间", 0.2)
      end
      t:remove()
    end
  end)
end

local function qianxiao_fukong_tg(u, tg, height, time)
  local cs = time / 0.03
  local h = tg:getdata("千咲-浮空高度")
  local add = height / cs
  tg:groupadd(u:getdata("千咲-浮空单位组"))
  if tg:getdata("千咲-浮空高度") <= 0 then
    tg:setdata("千咲-浮空高度", 1)
  end
  if tg:getdata("千咲-浮空时间") <= 0.3 then
    tg:changedata("千咲-浮空时间", 0.3)
  end
  ac.loop(30, function(t)
    cs = cs - 1
    h = tg:getdata("千咲-浮空高度") + add
    tg:setflyheight(h)
    tg:changedata("千咲-浮空时间", 0.03)
    tg:setdata("千咲-浮空高度", h)
    if cs <= 0 then
      if u:hasdata("千咲天赋-零坠空间") and tg:getdata("千咲-浮空时间") <= 0.2 then
        tg:setdata("千咲-浮空时间", 0.2)
      end
      t:remove()
    end
  end)
end

local function qianxiao_fukongdaoguang(args)
  local u = args.u
  local dx = args.dx
  local dy = args.dy
  local jd = args.jd
  local xz = args.xz
  local iszheng = args.iszheng
  jd = jd + xz
  local h = u:getdata("千咲-浮空高度") or 0
  local tx = EffectcreateArgs({
    effect = "Qx\\qianxiao_tuowei1.mdx",
    x = dx,
    y = dy,
    time = 0.5,
    size = 1,
    height = 1 + h,
    zxz = jd,
    animespeed = 2
  })
  ac.wait(50, function()
    h = u:getdata("千咲-浮空高度")
    dx, dy = u:getxy()
    local x1, y1 = PolarXY(dx, dy, 300, jd + 45)
    japi.EXSetEffectXY(tx, x1, y1)
    japi.EXSetEffectZ(tx, h + 100)
    x1, y1 = PolarXY(dx, dy, iszheng * 100, jd + iszheng * 90)
    local tx1 = EffectcreateArgs({
      effect = "Qx\\qianxiao_daoguang1.mdx",
      x = x1,
      y = y1,
      size = 0.5,
      height = h,
      zxz = jd + 30,
      animespeed = 2
    })
    ac.wait(100, function()
      japi.EXSetEffectSpeed(tx1, 10)
    end)
  end)
  ac.wait(100, function()
    h = u:getdata("千咲-浮空高度")
    dx, dy = u:getxy()
    local x1, y1 = PolarXY(dx, dy, 400, jd - 20)
    japi.EXSetEffectXY(tx, x1, y1)
    japi.EXSetEffectZ(tx, h + 100)
    x1, y1 = PolarXY(dx, dy, iszheng * 300, 90 * (1 - iszheng) + jd)
    local tx1 = EffectcreateArgs({
      effect = "Qx\\qianxiao_daoguang1.mdx",
      x = x1,
      y = y1,
      size = 0.5,
      height = h,
      zxz = jd + 120,
      animespeed = 2
    })
    ac.wait(100, function()
      japi.EXSetEffectSpeed(tx1, 10)
    end)
  end)
  ac.wait(150, function()
    h = u:getdata("千咲-浮空高度")
    dx, dy = u:getxy()
    local x1, y1 = PolarXY(dx, dy, 150, jd - 90)
    japi.EXSetEffectXY(tx, x1, y1)
    japi.EXSetEffectZ(tx, h + 100)
    x1, y1 = PolarXY(dx, dy, iszheng * 200, jd - iszheng * 45)
    local tx1 = EffectcreateArgs({
      effect = "Qx\\qianxiao_daoguang1.mdx",
      x = x1,
      y = y1,
      size = 0.5,
      height = h,
      zxz = jd,
      animespeed = 2
    })
    ac.wait(100, function()
      japi.EXSetEffectSpeed(tx1, 10)
    end)
    u:shockcamera(100, 0.1)
  end)
end

local zsz = {
  "A",
  "AA",
  "AAA",
  "R",
  "AR",
  "AAR",
  "AAAR",
  "E",
  "EE",
  "EER",
  "EERR",
  "S",
  "SS",
  "SE",
  "SEE",
  "SR",
  "SRR",
  "SA",
  "SAA",
  "SAAA",
  "SW",
  "SQ"
}
local zgskill
zgskill = {
  W = function(u)
    local skillstr = "A"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    local zttime = 0.0
    local lianxietime = 0.8
    ac.wait(1, function()
      u:animeact(19)
      u:animespeed(2)
      ac.wait(100, function()
        u:animespeed(1)
      end)
      local g = CreateGroupLua()
      unitmove({
        unit = u.handle,
        time = 0.1,
        distance = 400,
        angle = jd,
        isfly = true,
        loops = {
          {
            looptime = 0.02,
            func = function(dx, dy)
              local x1, y1 = PolarXY(dx, dy, 50, jd)
              for _, xq in ac.selector():in_rangexy(x1, y1, 300):is_enemy(u.handle):isnotingroup(g):ipairs() do
                xq = getunit(xq)
                xq:groupadd(g)
                Qianxiao_Damage({
                  u = u,
                  tg = xq,
                  damage = txsh,
                  jt = 100,
                  jd = jd,
                  skillstr = skillstr
                })
              end
            end
          }
        },
        endfunc = function(dx, dy)
          u:setdata("位移点X", dx)
          u:setdata("位移点Y", dy)
        end
      })
      Qianxiao_sound(u, Sound_Qianxiao_A)
      if u:hasdata("千咲-日配") then
        PlayGlobalSound(Sound_Qianxiao_yuyin_A_Jp)
      else
        PlayGlobalSound(Sound_Qianxiao_yuyin_A)
      end
    end)
    do
      local dx, dy = u:getxy()
      dx, dy = PolarXY(x, y, 100, jd + 90)
      local tx = EffectcreateArgs({
        effect = "Qx\\qianxiao_tuowei1.mdx",
        x = dx,
        y = dy,
        time = 0.5,
        size = 1,
        height = 1,
        zxz = jd,
        animespeed = 2
      })
      ac.wait(50, function()
        dx, dy = u:getxy()
        local x1, y1 = PolarXY(dx, dy, 200, jd + 45)
        japi.EXSetEffectXY(tx, x1, y1)
        x1, y1 = PolarXY(dx, dy, 0, jd + 90)
        local tx1 = EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang1.mdx",
          x = x1,
          y = y1,
          size = 0.5,
          height = 1,
          zxz = jd + 30,
          animespeed = 2
        })
        ac.wait(100, function()
          japi.EXSetEffectSpeed(tx1, 10)
        end)
      end)
      ac.wait(100, function()
        dx, dy = u:getxy()
        local x1, y1 = PolarXY(x, y, 300, jd - 20)
        japi.EXSetEffectXY(tx, x1, y1)
        x1, y1 = PolarXY(dx, dy, 200, jd)
        local tx1 = EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang1.mdx",
          x = x1,
          y = y1,
          size = 0.5,
          height = 1,
          zxz = jd + 120,
          animespeed = 2
        })
        ac.wait(100, function()
          japi.EXSetEffectSpeed(tx1, 10)
        end)
      end)
      ac.wait(150, function()
        dx, dy = u:getxy()
        local x1, y1 = PolarXY(x, y, 50, jd - 90)
        japi.EXSetEffectXY(tx, x1, y1)
        x1, y1 = PolarXY(dx, dy, 100, jd - 45)
        local tx1 = EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang1.mdx",
          x = x1,
          y = y1,
          size = 0.5,
          height = 1,
          zxz = jd,
          animespeed = 2
        })
        ac.wait(100, function()
          japi.EXSetEffectSpeed(tx1, 10)
        end)
        u:shockcamera(25, 0.1)
      end)
    end
    if u:getdata("千咲连携") == "" then
      u:setdata("千咲连携", "A")
      u:setdata("千咲连携时间", zttime + lianxietime)
    end
    if u:hasdata("千咲天赋-断续疾走") then
      u:setdata("千咲连携", "W")
      u:setdata("千咲连携时间", zttime + lianxietime)
    end
  end,
  Q = function(u)
    local skillstr = "Q"
    local x, y = u:getxy()
    local jd = u:getface()
    ac.wait(1, function()
      u:animeact(12)
      u:animespeed(1)
    end)
    unitmove({
      unit = u.handle,
      time = 0.1,
      distance = 400,
      angle = jd + 180,
      endfunc = function()
        local x, y = u:getxy()
        u:setdata("位移点X", x)
        u:setdata("位移点Y", y)
      end
    })
    local dx, dy = PolarXY(x, y, -50, jd)
    Effectcreate("war3mapImported\\specialanimedustwave.mdx", dx, dy, 0, 1, 0, 0, 0, 0, 2)
    Effectcreate("war3mapImported\\nitu.mdl", x, y, 0.8, 1, 0, u:getface() + 180)
  end,
  A = function(u)
    local skillstr = "A"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    local zttime = 0.0
    local lianxietime = 0.8
    u:setdata("千咲连携", "")
    zhiguizantingtime(u, zttime, skillstr)
    ac.wait(1, function()
      u:animeact(19)
      u:animespeed(1)
      Qianxiao_Move(u, 0.1, 100, jd)
      Qianxiao_sound(u, Sound_Qianxiao_A)
      if u:hasdata("千咲-日配") then
        PlayGlobalSound(Sound_Qianxiao_yuyin_A_Jp)
      else
        PlayGlobalSound(Sound_Qianxiao_yuyin_A)
      end
    end)
    do
      local dx, dy = u:getxy()
      dx, dy = PolarXY(x, y, 100, jd + 90)
      local tx = EffectcreateArgs({
        effect = "Qx\\qianxiao_tuowei1.mdx",
        x = dx,
        y = dy,
        time = 0.5,
        size = 1,
        height = 1,
        zxz = jd,
        animespeed = 2
      })
      ac.wait(50, function()
        local x1, y1 = PolarXY(x, y, 300, jd + 45)
        japi.EXSetEffectXY(tx, x1, y1)
        x1, y1 = PolarXY(x, y, 100, jd + 90)
        local tx1 = EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang1.mdx",
          x = x1,
          y = y1,
          size = 0.5,
          height = 1,
          zxz = jd + 30,
          animespeed = 2
        })
        ac.wait(100, function()
          japi.EXSetEffectSpeed(tx1, 10)
        end)
      end)
      ac.wait(100, function()
        local x1, y1 = PolarXY(x, y, 400, jd - 20)
        japi.EXSetEffectXY(tx, x1, y1)
        x1, y1 = PolarXY(x, y, 300, jd)
        local tx1 = EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang1.mdx",
          x = x1,
          y = y1,
          size = 0.5,
          height = 1,
          zxz = jd + 120,
          animespeed = 2
        })
        ac.wait(100, function()
          japi.EXSetEffectSpeed(tx1, 10)
        end)
      end)
      ac.wait(150, function()
        local x1, y1 = PolarXY(x, y, 150, jd - 90)
        japi.EXSetEffectXY(tx, x1, y1)
        x1, y1 = PolarXY(x, y, 200, jd - 45)
        local tx1 = EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang1.mdx",
          x = x1,
          y = y1,
          size = 0.5,
          height = 1,
          zxz = jd,
          animespeed = 2
        })
        ac.wait(100, function()
          japi.EXSetEffectSpeed(tx1, 10)
        end)
        u:shockcamera(25, 0.1)
      end)
    end
    ac.wait(100, function()
      local x1, y1 = PolarXY(x, y, 150, jd)
      Qianxiao_Damage({
        u = u,
        mx = x1,
        my = y1,
        fw = 300,
        damage = txsh,
        jt = 50,
        jd = jd,
        skillstr = skillstr
      })
    end)
    u:setdata("千咲连携", "A")
    u:setdata("千咲连携时间", zttime + lianxietime)
  end,
  AA = function(u)
    local skillstr = "AA"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    local ojd = u:getface()
    local zttime = 0.5
    local lianxietime = 0.8
    u:setdata("千咲连携", "")
    zhiguizantingtime(u, zttime, skillstr)
    wudisrtrtime(u, zttime + 0.1, skillstr)
    ac.wait(1, function()
      u:animeact(0)
      u:animespeed(1.5)
    end)
    ac.wait(0, function()
      local dx, dy = u:getxy()
      dx, dy = PolarXY(dx, dy, 0, jd)
      Qianxiao_Move(u, 0.25, 400, jd)
      Qianxiao_sound(u, Sound_Qianxiao_AA)
      dx, dy = PolarXY(x, y, 100, jd + 90)
      local tx = EffectcreateArgs({
        effect = "Qx\\qianxiao_tuowei1.mdx",
        x = dx,
        y = dy,
        time = 0.5,
        size = 1,
        height = 1,
        zxz = jd,
        animespeed = 2
      })
      ac.wait(50, function()
        local x1, y1 = PolarXY(x, y, 300, jd + 45)
        japi.EXSetEffectXY(tx, x1, y1)
        x1, y1 = PolarXY(x, y, 100, jd + 90)
        local tx1 = EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang1.mdx",
          x = x1,
          y = y1,
          size = 0.5,
          height = 1,
          zxz = jd + 30,
          animespeed = 2
        })
        ac.wait(100, function()
          japi.EXSetEffectSpeed(tx1, 10)
        end)
      end)
      ac.wait(100, function()
        local x1, y1 = PolarXY(x, y, 400, jd - 20)
        japi.EXSetEffectXY(tx, x1, y1)
        x1, y1 = PolarXY(x, y, 300, jd)
        local tx1 = EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang1.mdx",
          x = x1,
          y = y1,
          size = 0.5,
          height = 1,
          zxz = jd + 120,
          animespeed = 2
        })
        ac.wait(100, function()
          japi.EXSetEffectSpeed(tx1, 10)
        end)
      end)
      ac.wait(150, function()
        local x1, y1 = PolarXY(x, y, 150, jd - 90)
        japi.EXSetEffectXY(tx, x1, y1)
        x1, y1 = PolarXY(x, y, 200, jd - 45)
        local tx1 = EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang1.mdx",
          x = x1,
          y = y1,
          size = 0.5,
          height = 1,
          zxz = jd,
          animespeed = 2
        })
        ac.wait(100, function()
          japi.EXSetEffectSpeed(tx1, 10)
        end)
        u:shockcamera(50, 0.1)
        ac.wait(0, function()
          local djx, djy = u:getxy()
          Qianxiao_Damage({
            u = u,
            mx = djx,
            my = djy,
            fw = 300,
            damage = txsh,
            jt = 175,
            jd = jd,
            skillstr = skillstr
          })
        end)
      end)
    end)
    ac.wait(150, function()
      local x, y = u:getxy()
      x, y = PolarXY(x, y, 300, jd)
      local jd = u:getface() - 180
      ac.wait(0, function()
        local dx, dy = u:getxy()
        dx, dy = PolarXY(dx, dy, 0, jd)
        dx, dy = PolarXY(x, y, 100, jd + 90)
        local tx = EffectcreateArgs({
          effect = "Qx\\qianxiao_tuowei1.mdx",
          x = dx,
          y = dy,
          time = 0.5,
          size = 1,
          height = 1,
          zxz = jd,
          animespeed = 2
        })
        ac.wait(50, function()
          local x1, y1 = PolarXY(x, y, 300, jd + 45)
          japi.EXSetEffectXY(tx, x1, y1)
          x1, y1 = PolarXY(x, y, 100, jd + 90)
          local tx1 = EffectcreateArgs({
            effect = "Qx\\qianxiao_daoguang1.mdx",
            x = x1,
            y = y1,
            size = 0.5,
            height = 100,
            zxz = jd + 30,
            animespeed = 2
          })
          ac.wait(100, function()
            japi.EXSetEffectSpeed(tx1, 10)
          end)
        end)
        ac.wait(100, function()
          local x1, y1 = PolarXY(x, y, 400, jd - 20)
          japi.EXSetEffectXY(tx, x1, y1)
          x1, y1 = PolarXY(x, y, 300, jd)
          local tx1 = EffectcreateArgs({
            effect = "Qx\\qianxiao_daoguang1.mdx",
            x = x1,
            y = y1,
            size = 0.5,
            height = 100,
            zxz = jd + 120,
            animespeed = 2
          })
          ac.wait(100, function()
            japi.EXSetEffectSpeed(tx1, 10)
          end)
        end)
        ac.wait(150, function()
          local x1, y1 = PolarXY(x, y, 150, jd - 90)
          japi.EXSetEffectXY(tx, x1, y1)
          x1, y1 = PolarXY(x, y, 200, jd - 45)
          local tx1 = EffectcreateArgs({
            effect = "Qx\\qianxiao_daoguang1.mdx",
            x = x1,
            y = y1,
            size = 0.5,
            height = 100,
            zxz = jd,
            animespeed = 2
          })
          ac.wait(100, function()
            japi.EXSetEffectSpeed(tx1, 10)
          end)
          local djx, djy = u:getxy()
          Qianxiao_Damage({
            u = u,
            mx = djx,
            my = djy,
            fw = 300,
            damage = txsh,
            jt = 175,
            jd = ojd,
            skillstr = skillstr
          })
        end)
      end)
    end)
    ac.wait(300, function()
      Qianxiao_Move(u, 0.1, 200, jd)
    end)
    ac.wait(500, function()
      if u:hasdata("千咲-日配") then
        PlayGlobalSound(Sound_Qianxiao_yuyin_AA_Jp)
      else
        PlayGlobalSound(Sound_Qianxiao_yuyin_AA)
      end
      local dx, dy = u:getxy()
      dx, dy = PolarXY(dx, dy, 200, jd)
      local tx1 = EffectcreateArgs({
        effect = "Qx\\qianxiao_daoguang1.mdx",
        x = dx,
        y = dy,
        size = 1,
        height = 100,
        zxz = jd + 270,
        yxz = 10,
        animespeed = 3
      })
      ac.wait(100, function()
        japi.EXSetEffectSpeed(tx1, 20)
      end)
      EffectcreateArgs({
        effect = "Qx\\qianxiao_daoguang1.mdx",
        x = dx,
        y = dy,
        size = 1,
        height = -100,
        zxz = jd + 270,
        animespeed = 2
      })
      EffectcreateArgs({
        effect = "Qx\\qianxiao_daoguang1.mdx",
        x = dx,
        y = dy,
        size = 1,
        height = -50,
        zxz = jd + 270,
        yxz = 20,
        animespeed = 2
      })
      u:shockcamera(100, 0.1)
      local djx, djy = u:getxy()
      Qianxiao_Damage({
        u = u,
        mx = djx,
        my = djy,
        fw = 300,
        damage = 2 * txsh,
        jt = 200,
        jd = jd,
        skillstr = skillstr
      })
    end)
    u:setdata("千咲连携", "AA")
    u:setdata("千咲连携时间", zttime + lianxietime)
  end,
  AAA = function(u)
    local skillstr = "AAA"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    local ojd = u:getface()
    local zttime = 0.05
    local lianxietime = 0.8
    u:setdata("千咲连携", "")
    zhiguizantingtime(u, zttime, skillstr)
    wudisrtrtime(u, zttime + 0.1, skillstr)
    Qianxiao_sound(u, Sound_Qianxiao_NewWW)
    ac.wait(1, function()
      u:animeact(5)
      u:animespeed(1)
    end)
    ac.wait(50, function()
      Qianxiao_Move(u, 0.1, 150, jd)
      local dx, dy = u:getxy()
      dx, dy = PolarXY(dx, dy, 300, jd)
      EffectcreateArgs({
        effect = "Qx\\qianxiao_baozha1.mdx",
        x = dx,
        y = dy,
        size = 1,
        height = -390,
        zxz = jd,
        animespeed = 10
      })
      EffectcreateArgs({
        effect = "Qx\\qianxiao_daoguang4.mdx",
        x = dx,
        y = dy,
        size = 1,
        height = 150,
        zxz = jd + 90,
        animespeed = 1
      })
      EffectcreateArgs({
        effect = "Qx\\qianxiao_daoguang3.mdx",
        x = dx,
        y = dy,
        size = 0.75,
        height = 190,
        zxz = jd + 90,
        animespeed = 2
      })
      EffectcreateArgs({
        effect = "war3mapImported\\Daji_Hong1.mdx",
        x = dx,
        y = dy,
        size = 10,
        zxz = jd,
        animespeed = 2.0
      })
      EffectcreateArgs({
        effect = "Qx\\qianxiao_daoguang10.mdx",
        x = x,
        y = y,
        size = 1.5,
        height = 0,
        zxz = jd,
        animespeed = 1
      })
      EffectcreateArgs({
        effect = "Qx\\qianxiao_daoguang10.mdx",
        x = dx,
        y = dy,
        size = 1.5,
        height = 10,
        zxz = jd,
        animespeed = 1
      })
      for i = 1, 5 do
        EffectcreateArgs({
          effect = "5dab9b48c482691b.mdl",
          x = dx,
          y = dy,
          size = 2,
          height = 0,
          zxz = GetRandomAngle()
        })
      end
      u:shockcamera(75, 0.1)
      local x1, y1 = PolarXY(x, y, 125, jd)
      local fw = 375
      if u:hasdata("千咲天赋-昙切") then
        fw = fw + 30
      end
      Qianxiao_Damage({
        u = u,
        mx = x1,
        my = y1,
        fw = fw,
        damage = txsh,
        jt = 150,
        jd = jd,
        skillstr = skillstr
      })
    end)
    u:setdata("千咲连携", "AAA")
    u:setdata("千咲连携时间", zttime + lianxietime)
  end,
  R = function(u)
    local skillstr = "R"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    IssueImmediateOrder(u.handle, "stop")
    local x, y = u:getxy()
    local jd
    if u:hasdata("千咲-R手动调整角度") then
      local x2 = u:getdata("千咲-重击X")
      local y2 = u:getdata("千咲-重击Y")
      jd = AngleXY(x, y, x2, y2)
      u:setface(jd)
    else
      jd = u:getface()
    end
    local zttime = 0.2
    local lianxietime = 0.8
    u:setdata("千咲连携", "")
    zhiguizantingtime(u, zttime, skillstr)
    wudisrtrtime(u, zttime + 0.2, skillstr)
    ac.wait(1, function()
      u:animeact(3)
      u:animespeed(3)
    end)
    Qianxiao_sound(u, Sound_Qianxiao_NewAAAA1)
    ac.wait(100, function()
      Qianxiao_Move(u, 0.1, 200, jd)
      ac.wait(100, function()
        u:shockcamera(50, 0.1)
        local x2, y2 = u:getxy()
        x2, y2 = PolarXY(x2, y2, 200, jd)
        x2, y2 = PolarXY(x2, y2, GetRandomReal(-100, 100), GetRandomAngle())
        EffectcreateArgs({
          effect = "Qx\\qianxiao_daji1.mdx",
          x = x2,
          y = y2,
          size = 3,
          height = 0,
          zxz = GetRandomAngle(),
          animespeed = 1
        })
        EffectcreateArgs({
          effect = "Qx\\qianxiao_daji1.mdx",
          x = x2,
          y = y2,
          size = 3,
          height = 0,
          zxz = GetRandomAngle(),
          animespeed = 1
        })
        EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang4.mdx",
          x = x2,
          y = y2,
          size = 1.5,
          height = 0,
          zxz = GetRandomAngle(),
          xxz = GetRandomAngle(),
          yxz = GetRandomAngle(),
          animespeed = 1
        })
      end)
      ac.wait(100, function()
        if u:hasdata("千咲-日配") then
          PlayGlobalSound(Sound_Qianxiao_yuyin_AA_Jp)
        else
          PlayGlobalSound(Sound_Qianxiao_yuyin_AA)
        end
        local dx, dy = u:getxy()
        dx, dy = PolarXY(dx, dy, 200, jd)
        local tx1 = EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang1.mdx",
          x = dx,
          y = dy,
          size = 2,
          height = 100,
          zxz = jd + 270,
          yxz = 10,
          animespeed = 3
        })
        ac.wait(100, function()
          japi.EXSetEffectSpeed(tx1, 20)
        end)
        EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang1.mdx",
          x = dx,
          y = dy,
          size = 2,
          height = -100,
          zxz = jd + 270,
          animespeed = 2
        })
        u:shockcamera(100, 0.1)
        local x, y = u:getxy()
        local x1, y1 = PolarXY(x, y, 125, jd)
        Qianxiao_Damage({
          u = u,
          mx = x1,
          my = y1,
          fw = 300,
          damage = txsh,
          jt = 100,
          jd = jd,
          skillstr = skillstr
        })
      end)
    end)
    u:setdata("千咲连携", "R")
    u:setdata("千咲连携时间", zttime + lianxietime)
  end,
  AR = function(u)
    local skillstr = "AR"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    IssueImmediateOrder(u.handle, "stop")
    local x, y = u:getxy()
    local jd
    if u:hasdata("千咲-R手动调整角度") then
      local x2 = u:getdata("千咲-重击X")
      local y2 = u:getdata("千咲-重击Y")
      jd = AngleXY(x, y, x2, y2)
      u:setface(jd)
    else
      jd = u:getface()
    end
    local zttime = 1.1
    local lianxietime = 0.8
    u:setdata("千咲连携", "")
    zhiguizantingtime(u, zttime, skillstr)
    wudisrtrtime(u, zttime + 0.2, skillstr)
    local g = CreateGroupLua()
    ac.wait(1, function()
      u:animeact(6)
      u:animespeed(1)
    end)
    ac.wait(0, function()
      local dx, dy = u:getxy()
      Qianxiao_Move(u, 0.1, 500, jd)
      Qianxiao_Move(u, 0.5, 300, jd)
      Qianxiao_Move(u, 1.5, 200, jd)
      ac.wait(1200, function()
        Qianxiao_Move(u, 0.1, 200, jd)
      end)
      Qianxiao_sound(u, Sound_Qianxiao_AAA)
      if u:hasdata("千咲-日配") then
        PlayGlobalSound(Sound_Qianxiao_yuyin_AAA_Jp)
      else
        PlayGlobalSound(Sound_Qianxiao_yuyin_AAA)
      end
      dx, dy = PolarXY(x, y, 100, jd + 90)
      local tx = EffectcreateArgs({
        effect = "Qx\\qianxiao_tuowei1.mdx",
        x = dx,
        y = dy,
        time = 0.5,
        size = 1,
        height = 1,
        zxz = jd,
        animespeed = 2
      })
      ac.wait(50, function()
        local x1, y1 = PolarXY(x, y, 300, jd + 45)
        japi.EXSetEffectXY(tx, x1, y1)
        x1, y1 = PolarXY(x, y, 100, jd + 90)
        local tx1 = EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang7.mdx",
          x = x1,
          y = y1,
          time = 1,
          size = 4,
          height = 200,
          zxz = jd,
          animespeed = 10
        })
        local tx2 = EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang7.mdx",
          x = x1,
          y = y1,
          time = 1,
          size = 4,
          height = 200,
          zxz = jd,
          xxz = 30,
          animespeed = 10
        })
        local cs = 0
        local cs1 = 0
        for _, xq in ac.selector():in_rangexy(x, y, 225):is_enemy(u.handle):isnotingroup(g):ipairs() do
          xq = getunit(xq)
          xq:groupadd(g)
        end
        local jt = 570
        ac.loop(10, function(t)
          cs = cs + 1
          cs1 = cs1 + 1
          local sj = GetRandomReal(4, 6)
          japi.EXSetEffectSize(tx1, sj)
          japi.EXSetEffectSize(tx2, sj)
          x1, y1 = u:getxy()
          x1, y1 = PolarXY(x1, y1, 100, jd)
          japi.EXSetEffectXY(tx1, x1, y1)
          japi.EXSetEffectXY(tx2, x1, y1)
          if cs <= 10 then
            jt = 570
          elseif cs <= 60 then
            jt = 70
          else
            jt = 10
          end
          if 10 <= cs1 and cs <= 80 then
            cs1 = 0
            u:shockcamera(25, 0.1)
            local x2, y2 = u:getxy()
            x2, y2 = PolarXY(x2, y2, 550, jd)
            x2, y2 = PolarXY(x2, y2, GetRandomReal(-100, 100), GetRandomAngle())
            EffectcreateArgs({
              effect = "Qx\\qianxiao_daji1.mdx",
              x = x2,
              y = y2,
              size = 3,
              height = 100,
              zxz = GetRandomAngle(),
              animespeed = 1
            })
            EffectcreateArgs({
              effect = "Qx\\qianxiao_daoguang4.mdx",
              x = x2,
              y = y2,
              size = 1.5,
              height = 190,
              zxz = GetRandomAngle(),
              xxz = GetRandomAngle(),
              yxz = GetRandomAngle(),
              animespeed = 1
            })
            x2, y2 = u:getxy()
            for _, xq in ac.selector():in_rangexy(x2, y2, 400):is_enemy(u.handle):isnotingroup(g):ipairs() do
              xq = getunit(xq)
              xq:groupadd(g)
            end
            ForGroupLuaNew(g, function(xq)
              Qianxiao_Damage({
                u = u,
                tg = xq,
                damage = txsh,
                jt = jt,
                jd = jd,
                isvest = true,
                skillstr = skillstr
              })
            end)
          end
          if 100 <= cs then
            ac.wait(100, function()
              local x2, y2 = u:getxy()
              x2, y2 = PolarXY(x2, y2, 550, jd)
              EffectcreateArgs({
                effect = "Qx\\qianxiao_daoguang4.mdx",
                x = x2,
                y = y2,
                size = 8,
                height = 50,
                zxz = jd + 90,
                yxz = -20,
                animespeed = 1
              })
              EffectcreateArgs({
                effect = "Qx\\qianxiao_daoguang3.mdx",
                x = x2,
                y = y2,
                size = 4,
                height = 190,
                zxz = jd + 90,
                yxz = -20,
                animespeed = 2
              })
              u:shockcamera(300, 0.1)
              local djx, djy = u:getxy()
              djx, djy = PolarXY(djx, djy, 250, jd)
              Qianxiao_Damage({
                u = u,
                mx = x1,
                my = y1,
                fw = 500,
                damage = 8 * txsh,
                jt = 200,
                jd = jd,
                skillstr = skillstr
              })
            end)
            t:remove()
          end
        end)
      end)
    end)
    u:setdata("千咲连携", "AR")
    u:setdata("千咲连携时间", zttime + lianxietime)
  end,
  AAR = function(u)
    local skillstr = "AAR"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    IssueImmediateOrder(u.handle, "stop")
    local x, y = u:getxy()
    local jd
    if u:hasdata("千咲-R手动调整角度") then
      local x2 = u:getdata("千咲-重击X")
      local y2 = u:getdata("千咲-重击Y")
      jd = AngleXY(x, y, x2, y2)
      u:setface(jd)
    else
      jd = u:getface()
    end
    local zttime = 0.7
    local lianxietime = 0.8
    u:setdata("千咲连携", "")
    zhiguizantingtime(u, zttime, skillstr)
    wudisrtrtime(u, zttime + 0.2, skillstr)
    u:playsound(Sound_Qianxiao_AAAA1)
    ac.wait(1, function()
      u:animeact(5)
      u:animespeed(1)
      ac.wait(100, function()
        u:animespeed(0.1)
      end)
      ac.wait(600, function()
        u:animespeed(1)
      end)
    end)
    ac.wait(0, function()
      local yxz = {}
      if u:hasdata("千咲-日配") then
        yxz = {
          Sound_Qianxiao_yuyin_AAAA_Jp,
          Sound_Qianxiao_yuyin_AAAA1_Jp,
          Sound_Qianxiao_yuyin_AAAA2_Jp,
          Sound_Qianxiao_WWW_Jp
        }
      else
        yxz = {
          Sound_Qianxiao_yuyin_AAAA,
          Sound_Qianxiao_yuyin_AAAA1,
          Sound_Qianxiao_yuyin_AAAA2,
          Sound_Qianxiao_yuyin_WWW
        }
      end
      u:playsound(yxz[GetRandomInt(1, #yxz)])
    end)
    ac.wait(0, function()
      local x3, y3 = PolarXY(x, y, 1100, jd - 20)
      local x4, y4 = PolarXY(x, y, 1100, jd + 20)
      local tx3 = EffectcreateArgs({
        effect = "Qx\\qianxiao_daoguang1.mdx",
        x = x3,
        y = y3,
        size = 0.1,
        height = 0,
        zxz = jd - 20,
        animespeed = 1
      })
      ac.wait(100, function()
        japi.EXSetEffectSpeed(tx3, 0.05)
      end)
      local tx4 = EffectcreateArgs({
        effect = "Qx\\qianxiao_daoguang1.mdx",
        x = x4,
        y = y4,
        size = 0.1,
        height = 0,
        zxz = jd + 20,
        animespeed = 1
      })
      ac.wait(100, function()
        japi.EXSetEffectSpeed(tx4, 0.05)
      end)
      local cs = 0
      local jd1 = jd - 20
      local jd2 = jd + 20
      local jd3 = jd1 - 1.5
      local jd4 = jd2 + 1.5
      ac.loop(10, function(t)
        cs = cs + 1
        local dx, dy = u:getxy()
        if cs <= 20 then
          jd3 = jd3 - 1
          jd4 = jd4 + 1
          japi.EXSetEffectSize(tx3, 0.5)
          japi.EXSetEffectSize(tx4, 0.5)
          japi.EXSetEffectZ(tx3, 0)
          japi.EXSetEffectZ(tx4, 0)
          x3, y3 = PolarXY(dx, dy, 200, jd3)
          x4, y4 = PolarXY(dx, dy, 200, jd4)
        end
        if 36 < cs and cs <= 40 then
          jd3 = jd3 - 5
          jd4 = jd4 + 5
          japi.EXSetEffectSize(tx3, 0.7)
          japi.EXSetEffectSize(tx4, 0.7)
          japi.EXSetEffectZ(tx3, 0)
          japi.EXSetEffectZ(tx4, 0)
          x3, y3 = PolarXY(dx, dy, 300, jd3)
          x4, y4 = PolarXY(dx, dy, 300, jd4)
        end
        japi.EXSetEffectXY(tx3, x3, y3)
        japi.EXSetEffectXY(tx4, x4, y4)
        if cs <= 20 then
          japi.EXEffectMatRotateZ(tx3, -1)
          japi.EXEffectMatRotateZ(tx4, 1)
        end
        if cs == 40 then
          Qianxiao_Move(u, 0.1, 100, jd + 180)
        end
        if 36 < cs and cs <= 40 then
          japi.EXEffectMatRotateZ(tx3, -5)
          japi.EXEffectMatRotateZ(tx4, 5)
        end
        if 65 <= cs and cs < 70 then
          japi.EXEffectMatRotateZ(tx3, 1.5)
          japi.EXEffectMatRotateZ(tx4, -1.5)
        end
        if 70 <= cs then
          x3, y3 = PolarXY(dx, dy, 300, jd)
          x4, y4 = PolarXY(dx, dy, 300, jd)
          japi.EXSetEffectXY(tx3, x3, y3)
          japi.EXSetEffectXY(tx4, x4, y4)
          japi.EXEffectMatRotateZ(tx3, 50)
          japi.EXEffectMatRotateZ(tx4, -50)
          japi.EXSetEffectSpeed(tx3, 1)
          japi.EXSetEffectSpeed(tx4, 1)
          japi.EXSetEffectSize(tx3, 1.3)
          japi.EXSetEffectSize(tx4, 1.3)
          ac.wait(100, function()
            japi.EXSetEffectSpeed(tx3, 10)
            japi.EXSetEffectSpeed(tx4, 10)
          end)
          EffectcreateArgs({
            effect = "Qx\\qianxiao_baozha1.mdx",
            x = x3,
            y = y3,
            size = 2,
            height = 10,
            zxz = jd,
            animespeed = 10
          })
          EffectcreateArgs({
            effect = "Qx\\qianxiao_daoguang4.mdx",
            x = x3,
            y = y3,
            size = 2,
            height = 120,
            zxz = jd + 90,
            animespeed = 1
          })
          EffectcreateArgs({
            effect = "Qx\\qianxiao_daoguang3.mdx",
            x = x3,
            y = y3,
            size = 1,
            height = 190,
            zxz = jd + 90,
            animespeed = 2
          })
          EffectcreateArgs({
            effect = "war3mapImported\\Daji_Hong1.mdx",
            x = x3,
            y = y3,
            size = 10,
            zxz = jd,
            animespeed = 2.0
          })
          EffectcreateArgs({
            effect = "Qx\\qianxiao_daoguang10.mdx",
            x = x,
            y = y,
            size = 2,
            height = 10,
            zxz = jd,
            animespeed = 1
          })
          EffectcreateArgs({
            effect = "Qx\\qianxiao_daoguang10.mdx",
            x = x,
            y = y,
            size = 2,
            height = 10,
            zxz = jd,
            animespeed = 1
          })
          for i = 1, 5 do
            EffectcreateArgs({
              effect = "5dab9b48c482691b.mdl",
              x = x3,
              y = y3,
              size = 5,
              height = -200,
              zxz = GetRandomAngle()
            })
          end
          u:shockcamera(100, 0.1)
          ac.wait(0, function()
            local g = CreateGroupLua()
            local djd = jd - 60
            local ax, ay = PolarXY(x, y, -150, jd)
            for k = 1, 11 do
              djd = djd + 10
              for j = 1, 9 do
                local dx1, dy1 = PolarXY(ax, ay, j * 100, djd)
                for _, xq in ac.selector():in_rangexy(dx1, dy1, 125):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  xq:groupadd(g)
                end
              end
            end
            ForGroupLuaNew(g, function(xq)
              Qianxiao_Damage({
                u = u,
                tg = xq,
                damage = txsh,
                jt = 100,
                jd = jd,
                skillstr = skillstr
              })
            end)
          end)
          t:remove()
        end
      end)
      ac.wait(340, function()
        u:playsound(Sound_Qianxiao_AAAA2)
      end)
    end)
    ac.wait(0, function()
      unitmove({
        unit = u.handle,
        time = 0.2,
        distance = 400,
        angle = u:getface() + 180,
        isfly = false
      })
      unitmove({
        unit = u.handle,
        time = 0.6,
        distance = 50,
        angle = u:getface() + 180,
        isfly = false
      })
      ac.wait(600, function()
        unitmove({
          unit = u.handle,
          time = 0.1,
          distance = 600,
          angle = u:getface(),
          isfly = false
        })
      end)
      EffectcreateArgs({
        effect = "war3mapImported\\bbb.mdx",
        x = x,
        y = y,
        size = 2.0,
        zxz = jd + 180,
        animespeed = 2.0
      })
      local dx, dy = u:getxy()
      dx, dy = PolarXY(x, y, 200, jd)
      dx, dy = PolarXY(dx, dy, 300, jd - 90)
      local tx1 = EffectcreateArgs({
        effect = "Qx\\qianxiao_daoguang1.mdx",
        x = dx,
        y = dy,
        size = 0.5,
        height = 100,
        zxz = jd - 90,
        animespeed = 1
      })
      ac.wait(300, function()
        japi.EXSetEffectSpeed(tx1, 100)
      end)
      dx, dy = PolarXY(x, y, 200, jd)
      dx, dy = PolarXY(dx, dy, 300, jd + 90)
      local tx2 = EffectcreateArgs({
        effect = "Qx\\qianxiao_daoguang1.mdx",
        x = dx,
        y = dy,
        size = 0.5,
        height = 100,
        zxz = jd + 90,
        animespeed = 1
      })
      ac.wait(300, function()
        japi.EXSetEffectSpeed(tx2, 100)
      end)
    end)
    u:setdata("千咲连携", "AAR")
    u:setdata("千咲连携时间", zttime + lianxietime)
  end,
  ["AAR强化"] = function(u)
    local skillstr = "AAR"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    IssueImmediateOrder(u.handle, "stop")
    local x, y = u:getxy()
    local jd
    if u:hasdata("千咲-R手动调整角度") then
      local x2 = u:getdata("千咲-重击X")
      local y2 = u:getdata("千咲-重击Y")
      jd = AngleXY(x, y, x2, y2)
      u:setface(jd)
    else
      jd = u:getface()
    end
    local zttime = 1.05
    local lianxietime = 0.8
    u:setdata("千咲连携", "")
    zhiguizantingtime(u, zttime, skillstr)
    wudisrtrtime(u, zttime + 0.2, skillstr)
    ac.wait(1, function()
      u:animeact(5)
      u:animespeed(1)
      ac.wait(100, function()
        u:animespeed(0.1)
      end)
      ac.wait(900, function()
        u:animespeed(1)
      end)
    end)
    Qianxiao_sound(u, Sound_Qianxiao_New01)
    ac.wait(0, function()
      local yxz = {}
      if u:hasdata("千咲-日配") then
        yxz = {
          Sound_Qianxiao_yuyin_AAAA_Jp,
          Sound_Qianxiao_yuyin_AAAA1_Jp,
          Sound_Qianxiao_yuyin_AAAA2_Jp,
          Sound_Qianxiao_WWW_Jp
        }
      else
        yxz = {
          Sound_Qianxiao_yuyin_AAAA,
          Sound_Qianxiao_yuyin_AAAA1,
          Sound_Qianxiao_yuyin_AAAA2,
          Sound_Qianxiao_yuyin_WWW
        }
      end
      u:playsound(yxz[GetRandomInt(1, #yxz)])
    end)
    ac.wait(0, function()
      local tx = EffectcreateArgs({
        effect = "war3mapImported\\heiquan.mdx",
        x = x,
        y = y,
        time = 2.4,
        size = 6,
        height = -10,
        zxz = jd,
        animespeed = 3.0
      })
      ac.wait(100, function()
        japi.EXSetEffectSpeed(tx, 0.0)
      end)
      ac.wait(700, function()
        japi.EXSetEffectSpeed(tx, 2.0)
      end)
    end)
    ac.wait(0, function()
      local x3, y3 = PolarXY(x, y, 1100, jd - 20)
      local x4, y4 = PolarXY(x, y, 1100, jd + 20)
      local tx3 = EffectcreateArgs({
        effect = "Qx\\qianxiao_daoguang1.mdx",
        x = x3,
        y = y3,
        size = 1,
        height = 0,
        zxz = jd - 20,
        animespeed = 1
      })
      if type(japi.EXSetEffectFogVisible) == "function" then
        japi.EXSetEffectFogVisible(tx3, true)
      end
      if type(japi.EXSetEffectMaskVisible) == "function" then
        japi.EXSetEffectMaskVisible(tx3, true)
      end
      ac.wait(100, function()
        japi.EXSetEffectSpeed(tx3, 0.05)
      end)
      local tx4 = EffectcreateArgs({
        effect = "Qx\\qianxiao_daoguang1.mdx",
        x = x4,
        y = y4,
        size = 1,
        height = 0,
        zxz = jd + 20,
        animespeed = 1
      })
      if type(japi.EXSetEffectFogVisible) == "function" then
        japi.EXSetEffectFogVisible(tx4, true)
      end
      if type(japi.EXSetEffectMaskVisible) == "function" then
        japi.EXSetEffectMaskVisible(tx4, true)
      end
      ac.wait(100, function()
        japi.EXSetEffectSpeed(tx4, 0.05)
      end)
      local cs = 0
      local jd1 = jd - 20
      local jd2 = jd + 20
      local jd3 = jd1 - 1.5
      local jd4 = jd2 + 1.5
      ac.loop(15, function(t)
        cs = cs + 1
        local dx, dy = u:getxy()
        if cs <= 20 then
          jd3 = jd3 - 1
          jd4 = jd4 + 1
          japi.EXSetEffectSize(tx3, 1)
          japi.EXSetEffectSize(tx4, 1)
          japi.EXSetEffectZ(tx3, 0)
          japi.EXSetEffectZ(tx4, 0)
          x3, y3 = PolarXY(dx, dy, 700, jd3)
          x4, y4 = PolarXY(dx, dy, 700, jd4)
        end
        if 36 < cs and cs <= 40 then
          jd3 = jd3 - 5
          jd4 = jd4 + 5
          japi.EXSetEffectSize(tx3, 2)
          japi.EXSetEffectSize(tx4, 2)
          japi.EXSetEffectZ(tx3, -200)
          japi.EXSetEffectZ(tx4, -200)
          x3, y3 = PolarXY(dx, dy, 1100, jd3)
          x4, y4 = PolarXY(dx, dy, 1100, jd4)
        end
        japi.EXSetEffectXY(tx3, x3, y3)
        japi.EXSetEffectXY(tx4, x4, y4)
        if cs <= 20 then
          japi.EXEffectMatRotateZ(tx3, -1)
          japi.EXEffectMatRotateZ(tx4, 1)
        end
        if cs == 40 then
          Qianxiao_Move(u, 0.1, 100, jd + 180)
        end
        if 36 < cs and cs <= 40 then
          japi.EXEffectMatRotateZ(tx3, -5)
          japi.EXEffectMatRotateZ(tx4, 5)
        end
        if 65 <= cs and cs < 70 then
          japi.EXEffectMatRotateZ(tx3, 1.5)
          japi.EXEffectMatRotateZ(tx4, -1.5)
        end
        if 70 <= cs then
          x3, y3 = PolarXY(dx, dy, 1100, jd)
          x4, y4 = PolarXY(dx, dy, 1100, jd)
          japi.EXSetEffectXY(tx3, x3, y3)
          japi.EXSetEffectXY(tx4, x4, y4)
          japi.EXEffectMatRotateZ(tx3, 50)
          japi.EXEffectMatRotateZ(tx4, -50)
          japi.EXSetEffectSpeed(tx3, 1)
          japi.EXSetEffectSpeed(tx4, 1)
          ac.wait(100, function()
            japi.EXSetEffectSpeed(tx3, 10)
            japi.EXSetEffectSpeed(tx4, 10)
          end)
          EffectcreateArgs({
            effect = "Qx\\qianxiao_baozha1.mdx",
            x = x3,
            y = y3,
            size = 5,
            height = 10,
            zxz = jd,
            animespeed = 10
          })
          EffectcreateArgs({
            effect = "Qx\\qianxiao_daoguang4.mdx",
            x = x3,
            y = y3,
            size = 8,
            height = 50,
            zxz = jd + 90,
            animespeed = 1
          })
          EffectcreateArgs({
            effect = "Qx\\qianxiao_daoguang3.mdx",
            x = x3,
            y = y3,
            size = 4,
            height = 190,
            zxz = jd + 90,
            animespeed = 2
          })
          EffectcreateArgs({
            effect = "war3mapImported\\Daji_Hong1.mdx",
            x = x3,
            y = y3,
            size = 40,
            zxz = jd,
            animespeed = 2.0
          })
          EffectcreateArgs({
            effect = "Qx\\qianxiao_daoguang10.mdx",
            x = x,
            y = y,
            size = 7,
            height = 10,
            zxz = jd,
            animespeed = 1
          })
          EffectcreateArgs({
            effect = "Qx\\qianxiao_daoguang10.mdx",
            x = x,
            y = y,
            size = 3,
            height = 10,
            zxz = jd,
            animespeed = 1
          })
          for i = 1, 5 do
            EffectcreateArgs({
              effect = "5dab9b48c482691b.mdl",
              x = x3,
              y = y3,
              size = 10,
              height = -200,
              zxz = GetRandomAngle()
            })
          end
          u:shockcamera(300, 0.1)
          ac.wait(0, function()
            local g = CreateGroupLua()
            local djd = jd - 70
            local ax, ay = PolarXY(x, y, -150, jd)
            for k = 1, 13 do
              djd = djd + 10
              for j = 1, 17 do
                local dx1, dy1 = PolarXY(ax, ay, j * 100, djd)
                for _, xq in ac.selector():in_rangexy(dx1, dy1, 225):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  xq:groupadd(g)
                end
              end
            end
            ForGroupLuaNew(g, function(xq)
              Qianxiao_Damage({
                u = u,
                tg = xq,
                damage = txsh,
                jt = 150,
                jd = jd,
                skillstr = skillstr
              })
            end)
          end)
          t:remove()
        end
      end)
    end)
    ac.wait(0, function()
      Qianxiao_Move(u, 0.2, 400, jd + 180)
      Qianxiao_Move(u, 0.6, 50, jd + 180)
      ac.wait(1000, function()
        Qianxiao_Move(u, 0.1, 600, jd)
      end)
      EffectcreateArgs({
        effect = "war3mapImported\\bbb.mdx",
        x = x,
        y = y,
        size = 2.0,
        zxz = jd + 180,
        animespeed = 2.0
      })
      local dx, dy = u:getxy()
      dx, dy = PolarXY(x, y, 600, jd)
      dx, dy = PolarXY(dx, dy, 300, jd - 90)
      local tx1 = EffectcreateArgs({
        effect = "Qx\\qianxiao_daoguang1.mdx",
        x = dx,
        y = dy,
        size = 0.5,
        height = 100,
        zxz = jd - 90,
        animespeed = 1
      })
      ac.wait(300, function()
        japi.EXSetEffectSpeed(tx1, 100)
      end)
      dx, dy = PolarXY(x, y, 600, jd)
      dx, dy = PolarXY(dx, dy, 300, jd + 90)
      local tx2 = EffectcreateArgs({
        effect = "Qx\\qianxiao_daoguang1.mdx",
        x = dx,
        y = dy,
        size = 0.5,
        height = 100,
        zxz = jd + 90,
        animespeed = 1
      })
      ac.wait(300, function()
        japi.EXSetEffectSpeed(tx2, 100)
      end)
    end)
    u:setdata("千咲连携", "AAR")
    u:setdata("千咲连携时间", zttime + lianxietime)
  end,
  AAAR = function(u)
    local skillstr = "AAAR"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    IssueImmediateOrder(u.handle, "stop")
    local x, y = u:getxy()
    local jd
    if u:hasdata("千咲-R手动调整角度") then
      local x2 = u:getdata("千咲-重击X")
      local y2 = u:getdata("千咲-重击Y")
      jd = AngleXY(x, y, x2, y2)
      u:setface(jd)
    else
      jd = u:getface()
    end
    local zttime = 0.7
    local lianxietime = 0.8
    u:setdata("千咲连携", "")
    zhiguizantingtime(u, zttime, skillstr)
    wudisrtrtime(u, zttime + 0.2, skillstr)
    ac.wait(1, function()
      u:animeact(3)
      u:animespeed(1)
    end)
    ac.wait(0, function()
      local dx, dy = u:getxy()
      dx, dy = PolarXY(dx, dy, 0, jd)
      Qianxiao_Move(u, 0.7, 500, jd + 180)
      Qianxiao_sound(u, Sound_Qianxiao_AAAAA)
      ac.wait(0, function()
        local yxz = {}
        if u:hasdata("千咲-日配") then
          yxz = {
            Sound_Qianxiao_yuyin_AAAAA1_Jp,
            Sound_Qianxiao_yuyin_AAAAA2_Jp,
            Sound_Qianxiao_yuyin_AAAAA3_Jp
          }
        else
          yxz = {
            Sound_Qianxiao_yuyin_AAAAA1,
            Sound_Qianxiao_yuyin_AAAAA2,
            Sound_Qianxiao_yuyin_AAAAA3
          }
        end
        u:playsound(yxz[GetRandomInt(1, #yxz)])
      end)
      dx, dy = PolarXY(x, y, 100, jd + 90)
      local cs1 = 0
      ac.loop(50, function(t1)
        cs1 = cs1 + 1
        EffectcreateArgs({
          effect = "war3mapImported\\Texiao_zhenhongxuli.mdx",
          x = dx,
          y = dy,
          size = 10 - 2 * cs1,
          height = 50 * cs1,
          zxz = GetRandomAngle(),
          animespeed = 3
        })
        EffectcreateArgs({
          effect = "Qx\\qianxiao_baozha9.mdx",
          x = dx,
          y = dy,
          time = 0.2,
          size = 10 - 2 * cs1,
          height = 300,
          zxz = jd,
          animespeed = 1
        })
        u:shockcamera(50, 0.05)
        ac.wait(0, function()
          Qianxiao_Damage({
            u = u,
            mx = dx,
            my = dy,
            fw = 800,
            damage = txsh,
            isnotxh = true,
            isvest = true,
            skillstr = skillstr,
            extrafunc = function(xq, sh)
              if not xq:hasdata("免疫击退效果") then
                local x2, y2 = xq:getxy()
                local jd1 = AngleXY(x2, y2, dx, dy)
                x2, y2 = PolarXY(x2, y2, 50, jd1)
                xq:setxy(x2, y2)
              end
            end
          })
        end)
        if 8 <= cs1 then
          t1:remove()
        end
      end)
      ac.wait(800, function()
        for i = 1, 3 do
          EffectcreateArgs({
            effect = "Qx\\qianxiao_shandian1.mdx",
            x = dx,
            y = dy,
            size = 20,
            height = -600,
            zxz = GetRandomAngle(),
            animespeed = 1
          })
        end
        local cs = 0
        ac.loop(100, function(t)
          cs = cs + 1
          EffectcreateArgs({
            effect = "Qx\\qianxiao_kuosan1.mdx",
            x = dx,
            y = dy,
            size = cs / 2,
            height = 1,
            zxz = jd,
            animespeed = 1
          })
          if 3 <= cs then
            t:remove()
          end
        end)
        EffectcreateArgs({
          effect = "Qx\\qianxiao_hongguang1.mdx",
          x = dx,
          y = dy,
          time = 1,
          size = 1,
          height = 1,
          zxz = jd,
          animespeed = 1
        })
        u:shockcamera(50, 0.1)
        ac.wait(0, function()
          Qianxiao_Damage({
            u = u,
            mx = dx,
            my = dy,
            fw = 800,
            damage = 4 * txsh,
            skillstr = skillstr,
            extrafunc = function(xq, sh)
              local dh = 700 - xq:getdata("千咲-浮空高度")
              qianxiao_fukong_tg(u, xq, dh, 0.3)
            end
          })
        end)
      end)
    end)
    u:setdata("千咲连携", "AAAR")
    u:setdata("千咲连携时间", zttime + lianxietime)
  end,
  E = function(u)
    local skillstr = "E"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    local zttime = 0.4
    local lianxietime = 1.2
    u:setdata("千咲连携", "")
    zhiguizantingtime(u, zttime, skillstr)
    wudisrtrtime(u, zttime + 0.4, skillstr)
    u:buffset(u.handle, 0.18, "暂停")
    IssueImmediateOrder(u.handle, "stop")
    u:setskillcd("A0OD", 0.3)
    u:setskillcd("A0NW", 0.3)
    ac.wait(1, function()
      u:animeact(20)
      u:animespeed(1)
    end)
    local dsize = 0.5
    Qianxiao_sound(u, Sound_Qianxiao_E)
    if u:islocal() then
      u:setskilldatastring("A0N3", "图标", "Qx_QW_Fense.tga")
      u:setskilldatastring("A0NW", "图标", "Qx_E_Fense.tga")
      u:setskilldatastring("A0OD", "图标", "Qx_E_Fense.tga")
      u:setskilldatastring("A0NX", "图标", "Qx_R_Fense.tga")
      u:setskilldatastring("A0O5", "图标", "Qx_R_Fense.tga")
      ClearSelection()
      u:select()
    end
    local isvest = true
    if u:hasdata("千咲天赋-负界弦锯") and u:getdata("千咲-电锯热力时间") > 0 then
      isvest = false
    end
    ac.wait(400, function()
      if u:hasdata("千咲-日配") then
        Qianxiao_sound(u, Sound_Qianxiao_yuyin_E_Jp)
      else
        Qianxiao_sound(u, Sound_Qianxiao_yuyin_E)
      end
      local dx, dy = u:getxy()
      Qianxiao_sound(u, Roland_Duralandal_Up)
      dx, dy = PolarXY(x, y, 200, jd + 90)
      for i = 1, 3 do
        EffectcreateArgs({
          effect = "Qx\\qianxiao_shandian1.mdx",
          x = dx,
          y = dy,
          size = 10 * dsize,
          height = -450 * dsize,
          zxz = jd + 90,
          animespeed = 0.5
        })
        EffectcreateArgs({
          effect = "Qx\\qianxiao_baozha5.mdx",
          x = dx,
          y = dy,
          size = 4 * dsize,
          height = -100,
          zxz = jd + 90,
          animespeed = 2
        })
      end
      u:shockcamera(100, 0.2)
      u:setdata("千咲-电锯模式时间", 1.2)
      u:setdata("千咲-电锯模式音效", Sound_Qianxiao_Shoudao1)
      local x2, y2 = PolarXY(x, y, 100, jd)
      for _, xq in ac.selector():in_rangexy(x, y, 900 * dsize):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        local x1, y1 = xq:getxy()
        local jl = DistanceXY(x1, y1, x2, y2)
        local jd1 = AngleXY(x1, y1, x2, y2)
        unitmove({
          unit = xq.handle,
          time = 0.3,
          distance = jl,
          angle = jd1,
          isfly = true
        })
        unitjump({
          unit = xq.handle,
          time = 0.3,
          distance = 0,
          height = 150
        })
      end
      local cs = 0
      ac.loop(150, function(t)
        cs = cs + 1
        local x1, y1 = PolarXY(x, y, 100, jd)
        Qianxiao_Damage({
          u = u,
          mx = x1,
          my = y1,
          fw = 300,
          damage = txsh,
          isvest = isvest,
          skillstr = skillstr,
          extrafunc = function(xq, sh)
            if not xq:hasdata("免疫击退效果") then
              local x2, y2 = xq:getxy()
              x2 = x2 + GetRandomReal(-10, 10)
              y2 = y2 + GetRandomReal(-10, 10)
              xq:setxy(x2, y2)
            end
          end
        })
        if 8 <= cs then
          u:animespeed(1)
          t:remove()
        end
      end)
    end)
    u:setdata("千咲连携", "E")
    u:setdata("千咲连携时间", zttime + lianxietime)
  end,
  ["强化E"] = function(u)
    local skillstr = "E"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    local h = u:getdata("千咲-浮空高度")
    if 0 < h then
      qianxiao_fukong(u, -u:getdata("千咲-浮空高度"), 0.4)
    end
    local x, y = u:getxy()
    local jd = u:getface()
    local zttime = 0.4
    local lianxietime = 2
    u:setdata("千咲连携", "")
    zhiguizantingtime(u, zttime, skillstr)
    wudisrtrtime(u, zttime + 2.2, skillstr)
    u:buffset(u.handle, 0.18, "暂停")
    u:setskillcd("A0OD", 0.3)
    u:setskillcd("A0NW", 0.3)
    IssueImmediateOrder(u.handle, "stop")
    local isvest = true
    if u:hasdata("千咲天赋-负界弦锯") and 0 < u:getdata("千咲-电锯热力时间") then
      isvest = false
    end
    ac.wait(1, function()
      u:animeact(20)
      u:animespeed(1)
    end)
    Qianxiao_sound(u, Sound_Qianxiao_E)
    if u:islocal() then
      u:setskilldatastring("A0N3", "图标", "Qx_QW_Fense.tga")
      u:setskilldatastring("A0NW", "图标", "Qx_E_Fense.tga")
      u:setskilldatastring("A0OD", "图标", "Qx_E_Fense.tga")
      u:setskilldatastring("A0NX", "图标", "Qx_R_Fense.tga")
      u:setskilldatastring("A0O5", "图标", "Qx_R_Fense.tga")
      ClearSelection()
      u:select()
    end
    ac.wait(400, function()
      if u:hasdata("千咲-日配") then
        Qianxiao_sound(u, Sound_Qianxiao_yuyin_E_Jp)
      else
        Qianxiao_sound(u, Sound_Qianxiao_yuyin_E)
      end
      local dx, dy = u:getxy()
      Qianxiao_sound(u, Roland_Duralandal_Up)
      dx, dy = PolarXY(x, y, 200, jd + 90)
      ac.wait(0, function()
        local tx = EffectcreateArgs({
          effect = "war3mapImported\\heiquan.mdx",
          x = dx,
          y = dy,
          time = 1.4,
          size = 2,
          height = 0,
          zxz = jd,
          animespeed = 3.0
        })
        ac.wait(100, function()
          japi.EXSetEffectSpeed(tx, 0.0)
        end)
        ac.wait(100, function()
          japi.EXSetEffectSpeed(tx, 2.0)
        end)
      end)
      for i = 1, 3 do
        EffectcreateArgs({
          effect = "Qx\\qianxiao_shandian1.mdx",
          x = dx,
          y = dy,
          size = 10,
          height = -450,
          zxz = jd + 90,
          animespeed = 0.5
        })
        EffectcreateArgs({
          effect = "Qx\\qianxiao_baozha5.mdx",
          x = dx,
          y = dy,
          size = 4,
          height = -100,
          zxz = jd + 90,
          animespeed = 2
        })
      end
      u:shockcamera(200, 0.2)
      u:setdata("千咲-电锯模式时间", 2.0)
      u:setdata("千咲-电锯模式", 1)
      for _, xq in ac.selector():in_rangexy(x, y, 900):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        local x1, y1 = xq:getxy()
        local x2, y2 = PolarXY(x, y, 100, jd)
        local jl = DistanceXY(x1, y1, x2, y2)
        local jd1 = AngleXY(x1, y1, x2, y2)
        unitmove({
          unit = xq.handle,
          time = 0.4,
          distance = jl,
          angle = jd1,
          isfly = true
        })
        unitjump({
          unit = xq.handle,
          time = 0.4,
          distance = 0,
          height = 300
        })
      end
      local cs = 0
      ac.loop(60, function(t)
        cs = cs + 1
        local x1, y1 = PolarXY(x, y, 100, jd)
        Qianxiao_Damage({
          u = u,
          mx = x1,
          my = y1,
          fw = 300,
          damage = txsh,
          isvest = isvest,
          skillstr = skillstr,
          extrafunc = function(xq, sh)
            if not xq:hasdata("免疫击退效果") then
              local x2, y2 = xq:getxy()
              x2 = x2 + GetRandomReal(-10, 10)
              y2 = y2 + GetRandomReal(-10, 10)
              xq:setxy(x2, y2)
            end
          end
        })
        if 20 <= cs then
          t:remove()
        end
      end)
    end)
    u:setdata("千咲连携", "E")
    u:setdata("千咲连携时间", zttime + lianxietime)
  end,
  EE = function(u)
    local skillstr = "EE"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    local zttime = 0.8
    local lianxietime = 0.8
    u:setdata("千咲连携", "")
    zhiguizantingtime(u, zttime, skillstr)
    wudisrtrtime(u, zttime + 0.6, skillstr)
    if not u:hasdata("千咲天赋-坍缩视界") then
      u:setskillcd("A0NW", 2)
      u:setskillcd("A0OD", 2)
    else
      u:changedata("千咲-锯环额外体力消耗", 1)
    end
    u:setdata("千咲-电锯模式时间", 1.0)
    local g = CreateGroupLua()
    ac.wait(1, function()
      u:animeact(10)
      u:animespeed(3)
      ac.wait(400, function()
        u:animespeed(1)
      end)
    end)
    Qianxiao_sound(u, Sound_Qianxiao_EE)
    if u:hasdata("千咲-日配") then
      Qianxiao_sound(u, Sound_Qianxiao_yuyin_EE_Jp)
    else
      Qianxiao_sound(u, Sound_Qianxiao_yuyin_EE)
    end
    ac.wait(0, function()
      local dx, dy = u:getxy()
      Qianxiao_Move(u, 0.3, 500, jd)
      Qianxiao_Move(u, 0.5, 200, jd)
      for _, xq in ac.selector():in_rangexy(dx, dy, 300):is_enemy(u.handle):isnotingroup(g):ipairs() do
        xq = getunit(xq)
        xq:groupadd(g)
      end
      dx, dy = PolarXY(x, y, 100, jd + 90)
      ac.wait(50, function()
        local x1, y1 = PolarXY(x, y, 600, jd + 45)
        local tx1 = EffectcreateArgs({
          effect = "Qx\\qianxiao_zhuanquan1.mdx",
          x = x1,
          y = y1,
          time = 0.3,
          size = 0.5,
          height = 0,
          zxz = jd,
          animespeed = 1
        })
        local tx2 = EffectcreateArgs({
          effect = "Qx\\qianxiao_zhuanquan1.mdx",
          x = x1,
          y = y1,
          time = 0.3,
          size = 0.5,
          height = 0,
          zxz = jd,
          animespeed = 1
        })
        local cs = 0
        local cs1 = 0
        ac.loop(10, function(t)
          cs = cs + 1
          cs1 = cs1 + 1
          local sj = GetRandomReal(0.45, 1)
          japi.EXSetEffectSize(tx1, sj)
          japi.EXSetEffectSize(tx2, sj)
          local ax, ay = u:getxy()
          ax, ay = PolarXY(ax, ay, 100, jd)
          x1, y1 = PolarXY(ax, ay, 200, jd)
          japi.EXSetEffectXY(tx1, x1, y1)
          japi.EXSetEffectXY(tx2, x1, y1)
          for _, xq in ac.selector():in_rangexy(ax, ay, 300):is_enemy(u.handle):isnotingroup(g):ipairs() do
            xq = getunit(xq)
            xq:groupadd(g)
          end
          if Group_Counts(g) > 0 then
            DestroyEffectLua(tx1)
            DestroyEffectLua(tx2)
            x1, y1 = u:getxy()
            zgskill["EE命中"](u, x1, y1, g, jd)
            t:remove()
          end
          if 5 <= cs1 and cs <= 30 then
            Qianxiao_Move(u, 0.05, 100, jd)
            cs1 = 0
            u:shockcamera(100, 0.03)
            local x2, y2 = u:getxy()
            x2, y2 = PolarXY(x2, y2, 350, jd)
            x2, y2 = PolarXY(x2, y2, GetRandomReal(-100, 100), GetRandomAngle())
            EffectcreateArgs({
              effect = "Qx\\qianxiao_daji1.mdx",
              x = x2,
              y = y2,
              size = 3,
              height = 100,
              zxz = GetRandomAngle(),
              animespeed = 1
            })
            EffectcreateArgs({
              effect = "Qx\\qianxiao_daoguang4.mdx",
              x = x2,
              y = y2,
              size = 1.5,
              height = 190,
              zxz = GetRandomAngle(),
              xxz = GetRandomAngle(),
              yxz = GetRandomAngle(),
              animespeed = 1
            })
          end
          if 45 <= cs then
            if u:hasdata("千咲-日配") then
              Qianxiao_sound(u, Sound_Qianxiao_WWW_Jp)
            else
              Qianxiao_sound(u, Sound_Qianxiao_yuyin_WWW)
            end
            local dx1, dy1 = u:getxy()
            local ax, ay = PolarXY(dx1, dy1, 100, jd)
            dx1, dy1 = PolarXY(dx1, dy1, 100, jd + 180)
            ac.wait(100, function()
              EffectcreateArgs({
                effect = "war3mapImported\\sete_zhanji.mdx",
                x = dx1,
                y = dy1,
                size = 4,
                height = 100,
                zxz = jd - 45,
                xxz = 170,
                animespeed = 1.2
              })
              Qianxiao_Damage({
                u = u,
                mx = ax,
                my = ay,
                fw = 300,
                damage = 4 * txsh,
                skillstr = skillstr
              })
            end)
            Qianxiao_Move(u, 0.3, 100, jd + 180)
            u:animeact(7)
            u:animespeed(2)
            u:setdata("千咲-电锯模式时间", 1.1)
            u:setdata("千咲-电锯模式", 2)
            if u:islocal() then
              u:setskilldatastring("A0N3", "图标", "Qx_QW_Fense.tga")
              if u:hasdata("千咲天赋-坍缩视界") then
                u:setskilldatastring("A0NW", "图标", "Qx_E_Fense.tga")
                u:setskilldatastring("A0OD", "图标", "Qx_E_Fense.tga")
              else
                u:setskilldatastring("A0NW", "图标", "Qx_E" .. u:getdata("系统-图标后缀"))
                u:setskilldatastring("A0OD", "图标", "Qx_E" .. u:getdata("系统-图标后缀"))
              end
              u:setskilldatastring("A0NX", "图标", "Qx_R_Fense.tga")
              u:setskilldatastring("A0O5", "图标", "Qx_R_Fense.tga")
              ClearSelection()
              u:select()
            end
            ac.wait(300, function()
              u:animespeed(1)
              Qianxiao_sound(u, Sound_Qianxiao_Shoudao1)
            end)
            t:remove()
          end
        end)
      end)
    end)
    u:setdata("千咲连携", "EE")
    u:setdata("千咲连携时间", zttime + lianxietime)
  end,
  EQ = function(u)
    local skillstr = "EQ"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    local zttime = 0.1
    local lianxietime = 0.8
    local str = u:getdata("千咲连携")
    u:setdata("千咲连携", "")
    zhiguizantingtime(u, zttime, skillstr)
    wudisrtrtime(u, zttime + 0.6, skillstr)
    u:buffset(u.handle, 0.15, "绝对闪避")
    ac.wait(1, function()
      u:animeact(7)
      u:animespeed(2)
    end)
    if str == "E" then
      if u:hasdata("千咲-日配") then
        Qianxiao_sound(u, Sound_Qianxiao_WWW_Jp)
      else
        Qianxiao_sound(u, Sound_Qianxiao_yuyin_WWW)
      end
    end
    local dx1, dy1 = u:getxy()
    local ax, ay = PolarXY(dx1, dy1, 100, jd)
    dx1, dy1 = PolarXY(dx1, dy1, 100, jd + 180)
    ac.wait(100, function()
      EffectcreateArgs({
        effect = "war3mapImported\\sete_zhanji.mdx",
        x = dx1,
        y = dy1,
        size = 4,
        height = 100,
        zxz = jd - 45,
        xxz = 170,
        animespeed = 1.2
      })
      Qianxiao_Damage({
        u = u,
        mx = ax,
        my = ay,
        fw = 300,
        damage = 4 * txsh,
        skillstr = skillstr
      })
    end)
    Qianxiao_Move(u, 0.1, 300, jd + 180)
    u:setdata("千咲-电锯模式时间", 0.1)
    u:setdata("千咲-电锯模式", 1)
    if u:islocal() then
      u:setskilldatastring("A0N3", "图标", "Qx_QW" .. u:getdata("系统-图标后缀"))
      u:setskilldatastring("A0NW", "图标", "Qx_E" .. u:getdata("系统-图标后缀"))
      u:setskilldatastring("A0OD", "图标", "Qx_E" .. u:getdata("系统-图标后缀"))
      u:setskilldatastring("A0NX", "图标", "Qx_R" .. u:getdata("系统-图标后缀"))
      u:setskilldatastring("A0O5", "图标", "Qx_R" .. u:getdata("系统-图标后缀"))
      ClearSelection()
      u:select()
    end
    ac.wait(300, function()
      u:animespeed(1)
    end)
    u:setdata("千咲连携", "EQ")
    u:setdata("千咲连携时间", zttime + lianxietime)
  end,
  ["EE命中"] = function(u, x1, y1, g, jd)
    local skillstr = "EE"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    local x, y = x1, y1
    local zttime = 1
    local lianxietime = 0.8
    u:setdata("千咲连携", "")
    zhiguizantingtime(u, zttime, skillstr)
    wudisrtrtime(u, zttime + 0.4, skillstr)
    u:setdata("千咲-电锯模式时间", 1.4)
    local isvest = true
    if u:hasdata("千咲天赋-负界弦锯") and u:getdata("千咲-电锯热力时间") > 0 then
      isvest = false
    end
    Qianxiao_sound(u, Sound_Qianxiao_EE)
    local dx, dy = x, y
    Qianxiao_Move(u, 1, 200, jd)
    Qianxiao_Move(u, 1.5, 100, jd)
    dx, dy = PolarXY(x, y, 100, jd + 90)
    ac.wait(50, function()
      local x1, y1 = PolarXY(x, y, 600, jd + 45)
      local tx1 = EffectcreateArgs({
        effect = "Qx\\qianxiao_zhuanquan1.mdx",
        x = x1,
        y = y1,
        time = 1,
        size = 0.5,
        height = 0,
        zxz = jd,
        animespeed = 1
      })
      local tx2 = EffectcreateArgs({
        effect = "Qx\\qianxiao_zhuanquan1.mdx",
        x = x1,
        y = y1,
        time = 1,
        size = 0.5,
        height = 0,
        zxz = jd,
        animespeed = 1
      })
      local cs = 0
      local cs1 = 0
      ac.loop(10, function(t)
        cs = cs + 1
        cs1 = cs1 + 1
        local sj = GetRandomReal(0.45, 1)
        japi.EXSetEffectSize(tx1, sj)
        japi.EXSetEffectSize(tx2, sj)
        local ax, ay = u:getxy()
        ax, ay = PolarXY(ax, ay, 100, jd)
        x1, y1 = PolarXY(ax, ay, 200, jd)
        japi.EXSetEffectXY(tx1, x1, y1)
        japi.EXSetEffectXY(tx2, x1, y1)
        if 10 <= cs1 and cs <= 80 then
          cs1 = 0
          for _, xq in ac.selector():in_rangexy(ax, ay, 300):is_enemy(u.handle):isnotingroup(g):ipairs() do
            xq = getunit(xq)
            xq:groupadd(g)
          end
          u:shockcamera(50, 0.1)
          local x2, y2 = u:getxy()
          x2, y2 = PolarXY(x2, y2, 350, jd)
          x2, y2 = PolarXY(x2, y2, GetRandomReal(-100, 100), GetRandomAngle())
          EffectcreateArgs({
            effect = "Qx\\qianxiao_daji1.mdx",
            x = x2,
            y = y2,
            size = 3,
            height = 100,
            zxz = GetRandomAngle(),
            animespeed = 1
          })
          EffectcreateArgs({
            effect = "Qx\\qianxiao_daoguang4.mdx",
            x = x2,
            y = y2,
            size = 1.5,
            height = 190,
            zxz = GetRandomAngle(),
            xxz = GetRandomAngle(),
            yxz = GetRandomAngle(),
            animespeed = 1
          })
          ForGroupLuaNew(g, function(xq)
            if not xq:hasdata("免疫击退效果") then
              local djx, djy = x2, y2
              xq:setxy(djx, djy)
            end
            Qianxiao_Damage({
              u = u,
              tg = xq,
              damage = txsh,
              isnotxh = true,
              isvest = isvest,
              skillstr = skillstr
            })
          end)
        end
        if 90 <= cs then
          if u:hasdata("千咲-日配") then
            Qianxiao_sound(u, Sound_Qianxiao_WWW_Jp)
          else
            Qianxiao_sound(u, Sound_Qianxiao_yuyin_WWW)
          end
          local dx1, dy1 = u:getxy()
          local ax, ay = PolarXY(dx1, dy1, 100, jd)
          dx1, dy1 = PolarXY(dx1, dy1, 100, jd + 180)
          ac.wait(100, function()
            EffectcreateArgs({
              effect = "war3mapImported\\sete_zhanji.mdx",
              x = dx1,
              y = dy1,
              size = 4,
              height = 100,
              zxz = jd - 45,
              xxz = 170,
              animespeed = 1.2
            })
            Qianxiao_Damage({
              u = u,
              mx = ax,
              my = ay,
              fw = 300,
              damage = txsh,
              skillstr = skillstr
            })
          end)
          Qianxiao_Move(u, 0.1, 150, jd + 180)
          u:animeact(7)
          u:animespeed(2)
          if u:islocal() then
            u:setskilldatastring("A0N3", "图标", "Qx_QW_Fense.tga")
            if u:hasdata("千咲天赋-坍缩视界") then
              u:setskilldatastring("A0NW", "图标", "Qx_E_Fense.tga")
              u:setskilldatastring("A0OD", "图标", "Qx_E_Fense.tga")
            else
              u:setskilldatastring("A0NW", "图标", "Qx_E" .. u:getdata("系统-图标后缀"))
              u:setskilldatastring("A0OD", "图标", "Qx_E" .. u:getdata("系统-图标后缀"))
            end
            u:setskilldatastring("A0NX", "图标", "Qx_R_Fense.tga")
            u:setskilldatastring("A0O5", "图标", "Qx_R_Fense.tga")
            ClearSelection()
            u:select()
          end
          ac.wait(100, function()
            u:animespeed(1)
            Qianxiao_sound(u, Sound_Qianxiao_Shoudao1)
            u:setdata("千咲-电锯模式时间", 0.8)
            u:setdata("千咲-电锯模式", 2)
          end)
          t:remove()
        end
      end)
    end)
    u:setdata("千咲连携", "EE")
    u:setdata("千咲连携时间", zttime + lianxietime)
  end,
  EER = function(u)
    local skillstr = "EER"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    local zttime = 0.85
    if u:getdata("千咲-电锯热力时间") > 0 then
      zttime = 0.45
    end
    local lianxietime = 0.8
    u:setdata("千咲连携", "")
    zhiguizantingtime(u, zttime, skillstr)
    wudisrtrtime(u, zttime + 0.3, skillstr)
    Qianxiao_sound(u, Sound_Qianxiao_EEE)
    ac.wait(1, function()
      u:animeact(8)
      u:animespeed(1)
    end)
    ac.wait(0, function()
      local dx, dy = u:getxy()
      dx, dy = PolarXY(dx, dy, 300, jd)
      Qianxiao_Move(u, 0.1, 100, jd)
      unitjump({
        unit = u.handle,
        time = 0.45,
        distance = 200,
        height = 300,
        angle = jd
      })
      ac.wait(450, function()
        if u:islocal() then
          u:setskilldatastring("A0N3", "图标", "Qx_QW" .. u:getdata("系统-图标后缀"))
          u:setskilldatastring("A0NW", "图标", "Qx_E" .. u:getdata("系统-图标后缀"))
          u:setskilldatastring("A0OD", "图标", "Qx_E" .. u:getdata("系统-图标后缀"))
          if u:getdata("千咲-电锯热力时间") > 0 then
            u:setskilldatastring("A0NX", "图标", "Qx_R_Fense.tga")
            u:setskilldatastring("A0O5", "图标", "Qx_R_Fense.tga")
          else
            u:setskilldatastring("A0NX", "图标", "Qx_R" .. u:getdata("系统-图标后缀"))
            u:setskilldatastring("A0O5", "图标", "Qx_R" .. u:getdata("系统-图标后缀"))
          end
          ClearSelection()
          u:select()
        end
        if u:getdata("千咲-电锯热力时间") > 0 then
          u:setdata("千咲-电锯模式时间", 0.8)
        else
          u:setdata("千咲-电锯模式时间", 0.4)
        end
        u:setdata("千咲-电锯模式", 3)
        if u:hasdata("千咲-日配") then
          Qianxiao_sound(u, Sound_Qianxiao_yuyin_EEE_Jp)
        else
          Qianxiao_sound(u, Sound_Qianxiao_yuyin_EEE)
        end
        local x1, y1 = u:getxy()
        x1, y1 = PolarXY(x1, y1, 300, jd)
        EffectcreateArgs({
          effect = "Qx\\qianxiao_baozha2.mdx",
          x = x1,
          y = y1,
          size = 1,
          height = 1,
          zxz = jd,
          animespeed = 2
        })
        u:shockcamera(125, 0.1)
        Qianxiao_Damage({
          u = u,
          mx = x1,
          my = y1,
          fw = 600,
          damage = txsh,
          skillstr = skillstr,
          extrafunc = function(xq, sh)
            local dh = 300 - xq:getdata("千咲-浮空高度")
            qianxiao_fukong_tg(u, xq, dh, 0.2)
          end
        })
      end)
      ac.wait(850, function()
        local x1, y1 = u:getxy()
        x1, y1 = PolarXY(x1, y1, 300, jd)
        EffectcreateArgs({
          effect = "Qx\\qianxiao_baozha5.mdx",
          x = x1,
          y = y1,
          size = 3,
          height = 0,
          zxz = jd,
          animespeed = 2
        })
        u:shockcamera(125, 0.1)
        EffectcreateArgs({
          effect = "Qx\\qianxiao_baozha5.mdx",
          x = x1,
          y = y1,
          size = 3,
          height = 0,
          zxz = jd,
          animespeed = 5
        })
        local cs = 0
        ac.loop(100, function(t)
          cs = cs + 1
          EffectcreateArgs({
            effect = "Qx\\qianxiao_kuosan1.mdx",
            x = x1,
            y = y1,
            size = 0.2 + cs / 5,
            height = 1,
            zxz = jd,
            animespeed = 0.5
          })
          if 3 <= cs then
            t:remove()
          end
        end)
        Qianxiao_Damage({
          u = u,
          mx = x1,
          my = y1,
          fw = 800,
          damage = txsh,
          skillstr = skillstr
        })
      end)
    end)
    u:setdata("千咲连携", "EER")
    u:setdata("千咲连携时间", zttime + lianxietime)
  end,
  EERR = function(u)
    local sy = u.ownerid
    local skillstr = "EERR"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    local zttime = 1.1
    local lianxietime = 0.8
    u:setdata("千咲连携", "")
    zhiguizantingtime(u, zttime, skillstr)
    wudisrtrtime(u, zttime + 0.6, skillstr)
    u:setdata("千咲-电锯模式时间", 1.1)
    u:setdata("千咲-电锯模式", 4)
    Qianxiao_sound(u, Sound_Qianxiao_EEEE)
    if u:hasdata("千咲-日配") then
      Qianxiao_sound(u, Sound_Qianxiao_yuyin_EEEE_Jp)
    else
      Qianxiao_sound(u, Sound_Qianxiao_yuyin_EEEE)
    end
    ac.wait(1, function()
      u:animeact(8)
      u:animespeed(0.5)
      ac.wait(500, function()
        u:animespeed(1)
      end)
    end)
    ac.wait(0, function()
      local dx, dy = PolarXY(x, y, 500, jd)
      local tx = EffectcreateArgs({
        effect = "war3mapImported\\heiquan.mdx",
        x = dx,
        y = dy,
        time = 2.4,
        size = 6,
        height = -10,
        zxz = jd,
        animespeed = 3.0
      })
      ac.wait(100, function()
        japi.EXSetEffectSpeed(tx, 0.0)
      end)
      ac.wait(450, function()
        japi.EXSetEffectSpeed(tx, 2.0)
      end)
    end)
    ac.wait(0, function()
      local dx, dy = u:getxy()
      dx, dy = PolarXY(dx, dy, -150, jd)
      dx, dy = PolarXY(dx, dy, 75, jd + 90)
      local height = 650
      local midcs = 50
      local cs = 0
      local h = 0
      ac.loop(10, function(t)
        cs = cs + 1
        if cs <= 50 then
          h = (-(1 - cs / midcs) ^ 2 + 1) * height
        elseif cs <= 70 then
          h = h + 3
        else
          h = h - 70
        end
        SetUnitFlyHeight(u.handle, h, 99999)
        if 80 <= cs then
          SetUnitFlyHeight(u.handle, 0, 99999)
          t:remove()
        end
      end)
      ac.wait(300, function()
        local txz = {}
        for i = 1, 4 do
          txz[i] = EffectcreateArgs({
            effect = "war3mapImported\\Texiao_zhenhongxuli.mdx",
            x = dx,
            y = dy,
            size = 10,
            height = 0,
            zxz = GetRandomAngle(),
            animespeed = 2
          })
        end
        local dcs = 0
        ac.loop(50, function(timer)
          dcs = dcs + 1
          for index, value in ipairs(txz) do
            SetEffectHeight(value, 0 + dcs * 25)
          end
          if 4 <= dcs then
            txz = nil
            timer:remove()
          end
        end)
      end)
      ac.wait(900, function()
        local x1, y1 = u:getxy()
        x1, y1 = PolarXY(x1, y1, 300, jd)
        EffectcreateArgs({
          effect = "Qx\\qianxiao_baozha2.mdx",
          x = x1,
          y = y1,
          size = 3,
          height = 1,
          zxz = jd,
          animespeed = 2
        })
        u:shockcamera(300, 0.1)
        local add = 50 * u:getlevel()
        hdzlinshiadd(u, add)
        Qianxiao_Damage({
          u = u,
          mx = x1,
          my = y1,
          fw = 1000,
          isqf = true,
          damage = txsh,
          skillstr = skillstr,
          extrafunc = function(xq, sh)
            ac.wait(100, function()
              local dh = 750 - xq:getdata("千咲-浮空高度")
              qianxiao_fukong_tg(u, xq, dh, 0.3)
            end)
          end
        })
      end)
      ac.wait(800, function()
        local x1, y1 = u:getxy()
        x1, y1 = PolarXY(x1, y1, 300, jd)
        EffectcreateArgs({
          effect = "Qx\\qianxiao_baozha5.mdx",
          x = x1,
          y = y1,
          size = 3,
          height = 0,
          zxz = jd,
          animespeed = 2
        })
        local cs1 = 0
        ac.loop(100, function(t)
          cs1 = cs1 + 1
          EffectcreateArgs({
            effect = "Qx\\qianxiao_kuosan1.mdx",
            x = x1,
            y = y1,
            size = 0.1 + cs1,
            height = 1,
            zxz = jd,
            animespeed = 0.5
          })
          EffectcreateArgs({
            effect = "Qx\\qianxiao_baozha5.mdx",
            x = x1,
            y = y1,
            size = cs1 * 10,
            height = -300,
            zxz = jd,
            animespeed = 1
          })
          u:shockcamera(200, 0.1)
          if 3 <= cs1 then
            Qianxiao_Move(u, 0.4, 400, jd + 180)
            u:animeact(9)
            u:animespeed(1)
            ac.wait(500, function()
              u:animespeed(0.5)
            end)
            t:remove()
          end
        end)
      end)
    end)
    u:setdata("千咲连携", "EERR")
    u:setdata("千咲连携时间", zttime + lianxietime)
  end,
  S = function(u)
    local skillstr = "S"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    local zttime = 0.3
    local lianxietime = 1.8
    u:setdata("千咲连携", "")
    zhiguizantingtime(u, zttime, skillstr)
    wudisrtrtime(u, zttime + 0.2, skillstr)
    Qianxiao_sound(u, Sound_Qianxiao_W)
    local voice_list = {}
    if u:hasdata("千咲-日配") then
      voice_list = {
        Sound_Qianxiao_W_Jp,
        Sound_Qianxiao_yuyin_gongji1_Jp,
        Sound_Qianxiao_yuyin_gongji2_Jp
      }
    else
      voice_list = {
        Sound_Qianxiao_yuyin_W,
        Sound_Qianxiao_yuyin_gongji1,
        Sound_Qianxiao_yuyin_gongji2
      }
    end
    Qianxiao_sound(u, voice_list[GetRandomInt(1, #voice_list)])
    ac.wait(1, function()
      u:animeact(1)
      u:animespeed(1)
    end)
    local h = 400 - u:getdata("千咲-浮空高度")
    if h <= 50 then
      h = 50
    end
    h = h / 4
    local isfk = false
    local isqf = false
    if u:getdata("千咲-浮空高度") > 100 then
      isfk = true
    else
      isqf = true
    end
    ac.wait(0, function()
      local dx, dy = u:getxy()
      Qianxiao_Move(u, 0.7, 100, jd)
      qianxiao_fukong(u, h, 0.1)
      qianxiao_fukongdaoguang({
        u = u,
        dx = dx,
        dy = dy,
        jd = jd,
        xz = 0,
        iszheng = 1
      })
      Qianxiao_Damage({
        u = u,
        mx = dx,
        my = dy,
        fw = 400,
        damage = txsh,
        isqf = isqf,
        isfk = isfk,
        skillstr = skillstr,
        extrafunc = function(xq, sh)
          local dh = u:getdata("千咲-浮空高度") - xq:getdata("千咲-浮空高度")
          if dh <= 0 then
            dh = 0
          end
          qianxiao_fukong_tg(u, xq, dh, 0.1)
          unitmove({
            unit = xq.handle,
            time = 0.1,
            distance = 25,
            angle = jd,
            isblink = true
          })
        end
      })
    end)
    ac.wait(100, function()
      local dx, dy = u:getxy()
      qianxiao_fukong(u, h, 0.1)
      qianxiao_fukongdaoguang({
        u = u,
        dx = dx,
        dy = dy,
        jd = jd,
        xz = 90,
        iszheng = -1
      })
      Qianxiao_Damage({
        u = u,
        mx = dx,
        my = dy,
        fw = 400,
        damage = txsh,
        isqf = isqf,
        isfk = isfk,
        skillstr = skillstr,
        extrafunc = function(xq, sh)
          local dh = u:getdata("千咲-浮空高度") - xq:getdata("千咲-浮空高度")
          if dh <= 0 then
            dh = 0
          end
          qianxiao_fukong_tg(u, xq, dh, 0.1)
          unitmove({
            unit = xq.handle,
            time = 0.1,
            distance = 25,
            angle = jd,
            isblink = true
          })
        end
      })
    end)
    ac.wait(200, function()
      local dx, dy = u:getxy()
      qianxiao_fukong(u, h, 0.1)
      qianxiao_fukongdaoguang({
        u = u,
        dx = dx,
        dy = dy,
        jd = jd,
        xz = 0,
        iszheng = -1
      })
      Qianxiao_Damage({
        u = u,
        mx = dx,
        my = dy,
        fw = 400,
        damage = txsh,
        isqf = isqf,
        isfk = isfk,
        skillstr = skillstr,
        extrafunc = function(xq, sh)
          local dh = u:getdata("千咲-浮空高度") - xq:getdata("千咲-浮空高度")
          if dh <= 0 then
            dh = 0
          end
          qianxiao_fukong_tg(u, xq, dh, 0.1)
          unitmove({
            unit = xq.handle,
            time = 0.1,
            distance = 25,
            angle = jd,
            isblink = true
          })
        end
      })
    end)
    ac.wait(300, function()
      local dx, dy = u:getxy()
      qianxiao_fukong(u, h, 0.1)
      qianxiao_fukongdaoguang({
        u = u,
        dx = dx,
        dy = dy,
        jd = jd,
        xz = 180,
        iszheng = -1
      })
      Qianxiao_Damage({
        u = u,
        mx = dx,
        my = dy,
        fw = 400,
        damage = txsh,
        isqf = isqf,
        isfk = isfk,
        skillstr = skillstr,
        extrafunc = function(xq, sh)
          local dh = u:getdata("千咲-浮空高度") - xq:getdata("千咲-浮空高度")
          qianxiao_fukong_tg(u, xq, dh, 0.1)
          unitmove({
            unit = xq.handle,
            time = 0.1,
            distance = 25,
            angle = jd,
            isblink = true
          })
        end
      })
    end)
    u:setdata("千咲连携", "S")
    u:setdata("千咲连携时间", zttime + lianxietime)
  end,
  X = function(u, x2, y2)
    local skillstr = "X"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local sy = u.ownerid
    local jd = AngleXY(x, y, x2, y2)
    local jl = DistanceXY(x, y, x2, y2)
    local max = 1400
    if jl >= max then
      jl = max
    end
    local tx = Effectcreate("Abilities\\Weapons\\WingedSerpentMissile\\WingedSerpentMissile.mdl", x, y, -1, 1, 75, jd)
    ac.wait(1, function()
      u:animeact(14)
    end)
    u:setface(jd)
    local h = u:getdata("千咲-浮空高度")
    if 0 < h then
      SetEffectHeight(tx, h)
    end
    effectmove({
      effect = tx,
      distance = jl,
      angle = jd,
      endfunc = function(dx, dy)
        DestroyEffectLua(tx)
        local x, y = u:getxy()
        local jd = AngleXY(x, y, dx, dy)
        local jl = DistanceXY(x, y, dx, dy)
        u:setface(jd)
        ac.wait(1, function()
          u:animeact(6)
          u:animespeed(1)
        end)
        local time = 0.1 + 0.15 * (jl / 1500)
        if 0 < h then
          local dh = h - u:getdata("千咲-浮空高度")
          if dh <= 0 then
            dh = 0
          end
          qianxiao_fukong(u, dh, time)
          unitmove({
            unit = u.handle,
            time = time,
            distance = jl * 1,
            angle = jd,
            isfly = true
          })
          if u:hasdata("千咲天赋-相位弦网") then
            for _, xq in ac.selector():in_rangexy(dx, dy, 200):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              qianxiao_fukong_tg(u, xq, h, time)
              Qianxiao_Damage({
                u = u,
                tg = xq,
                damage = txsh,
                skillstr = skillstr
              })
            end
          end
        else
          unitjump({
            unit = u.handle,
            time = time,
            distance = jl * 1,
            angle = jd,
            height = 25 + 75 * (jl / 1500),
            isfly = true,
            endfunc = function(dx, dy)
              u:animeact(4)
              u:animespeed(1)
            end
          })
        end
      end,
      speed = 4500
    })
  end,
  XCar = function(u)
    local sy = u.ownerid
    local x, y = u:getxy()
    local jd = u:getface()
    CheSuduSx[sy] = 25
    CheXuanze[sy] = true
    CheJiasudu[sy] = 0.1
    local atx = Effectcreate("Abilities\\Spells\\Orc\\FeralSpirit\\feralspirittarget.mdl", x, y, 0, 3, 0, jd)
    local mtc = Effectcreate("lxy_mtc.mdx", x, y, -1, 1.25, 0, jd)
    SetEffectAnimation(mtc, "walk")
    local mtcjd = jd
    SetCameraTargetControllerNoZForPlayer(u.owner, u.handle, 0, 0, false)
    local pzq = 100
    -- 공유 차량 타이머를 관찰하며 진단용 타이머나 게임 핸들은 생성하지 않는다.
    local vehicle_tick = 0
    local previous_blocked = nil
    local diagnostic = package.loaded["hera_gameplay_diagnostic"]
    local function vehicle_note(stage, blocked, collision)
      if not diagnostic then return end
      local vx, vy = u:getxy()
      diagnostic.monster(stage, {unit=u.handle, owner=sy, tick=vehicle_tick,
        x=vx, y=vy, speed=CheSudu[sy], accelerate=CheYdW[sy], brake=CheYdS[sy],
        blocked=blocked, collision=collision, mounted=CheXuanze[sy]})
    end
    vehicle_note("VEHICLE_START", false, false)
    ac.loop(10, function(timer)
      vehicle_tick = vehicle_tick + 1
      local b = true
      local pz = false
      if CheYdW[sy] and CheSudu[sy] < CheSuduSx[sy] then
        CheSudu[sy] = CheSudu[sy] + CheJiasudu[sy]
      end
      if CheSudu[sy] > 0 then
        SetEffectAnimation(mtc, "walk")
        if (CheSudu[sy] > CheSuduSx[sy] or not CheYdW[sy]) and CheYdS[sy] then
          CheSudu[sy] = CheSudu[sy] - CheJiasudu[sy] * 2
        end
      else
        CheSudu[sy] = 0
        SetEffectAnimation(mtc, "stand")
      end
      local x, y = u:getxy()
      local jd = u:getface()
      local x3, y3 = PolarXY(x, y, 100, jd)
      if IsTerrainPathable(x3, y3, PATHING_TYPE_WALKABILITY) then
        b = false
      end
      if b then
        EnumDestrucSelect(x3, y3, 50, function()
          local dc = GetEnumDestructable()
          local dctype = GetDestructableTypeId(dc)
          if GetDestructableLife(dc) > 0 and dctype ~= S2ID("OTip") and dctype ~= S2ID("OTis") then
            b = false
          end
        end)
      end
      if b then
        local x2, y2 = PolarXY(x, y, CheSudu[sy], jd)
        SetUnitPosition(u.handle, x2, y2)
        if u["脚本位移后效果"] and #u["脚本位移后效果"] > 0 then
          StexiaoFunc({
            text = "脚本位移后效果",
            u = u
          })
        end
        local ax, ay = PolarXY(x, y, -10, jd)
        local loc = Location(ax, ay)
        local heiadd = GetLocationZ(loc)
        RemoveLocation(loc)
        SetEffectXY(mtc, ax, ay)
        SetEffectHeight(mtc, heiadd)
        SetEffectAngle(mtc, u:getface() - mtcjd)
        mtcjd = u:getface()
      else
        if CheSudu[sy] >= 12 then
          pz = true
          local t = 0.5 + CheSudu[sy] / 10
          u:buffset(u.handle, t, "眩晕")
          u:buffset(u.handle, t, "暂停")
          u:losshp(u, 0, 0, t * 25)
          Effectcreate("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", x, y, 0, t)
        end
        CheSudu[sy] = 0
        CheYdW[sy] = false
        CheYdS[sy] = false
        SetUnitPosition(u.handle, x, y)
        if u["脚本位移后效果"] and #u["脚本位移后效果"] > 0 then
          StexiaoFunc({
            text = "脚本位移后效果",
            u = u
          })
        end
      end
      if vehicle_tick == 1 or vehicle_tick % 50 == 0 or previous_blocked ~= not b then
        vehicle_note("VEHICLE_STEP", not b, pz)
      end
      previous_blocked = not b
      u:animeact(1)
      if not (u:isalive() and CheXuanze[sy]) or pz or 0 < u:getdata("战斗时间") then
        u:animeact(4)
        DestroyEffectLua(mtc)
        Effectcreate("Abilities\\Spells\\Orc\\FeralSpirit\\feralspirittarget.mdl", x, y, 0, 3, 0, jd)
        CheXuanze[sy] = false
        CheSudu[sy] = 0
        CheYdW[sy] = false
        CheYdS[sy] = false
        ResetToGameCameraForPlayer(u.owner, 0)
        local p = getplayer(u.owner)
        p:setcameraheight(Cam_height[u.ownerid], 0)
        vehicle_note("VEHICLE_END", not b, pz)
        timer:remove()
      end
    end)
  end,
  SE = function(u)
    local skillstr = "SE"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    local gd = u:getdata("千咲-浮空高度")
    local zttime = 0.4
    local lianxietime = 0.8
    u:setdata("千咲连携", "")
    zhiguizantingtime(u, zttime, skillstr)
    wudisrtrtime(u, zttime + 0.2, skillstr)
    local g = CreateGroupLua()
    Qianxiao_sound(u, Sound_Qianxiao_WW)
    if u:hasdata("千咲-日配") then
      Qianxiao_sound(u, Sound_Qianxiao_WW_Jp)
    else
      Qianxiao_sound(u, Sound_Qianxiao_yuyin_WW)
    end
    ac.wait(1, function()
      u:animeact(5)
      u:animespeed(1)
    end)
    qianxiao_fukong(u, 0, 0.4)
    local ax, ay = PolarXY(x, y, 100, jd)
    for i = 1, 2 do
      EffectcreateArgs({
        effect = "war3mapImported\\Texiao_zhenhongxuli.mdx",
        x = ax,
        y = ay,
        size = 5,
        height = -300 + gd,
        zxz = GetRandomAngle(),
        animespeed = 3
      })
    end
    ac.wait(300, function()
      local dx, dy = u:getxy()
      Qianxiao_Move(u, 0.1, 800, jd)
      local ax, ay = u:getxy()
      for _, xq in ac.selector():in_rangexy(ax, ay, 350):is_enemy(u.handle):isnotingroup(g):ipairs() do
        xq = getunit(xq)
        xq:groupadd(g)
        if xq:getdata("千咲-浮空高度") > 0 then
          Qianxiao_Damage({
            u = u,
            tg = xq,
            damage = txsh,
            skillstr = skillstr,
            extrafunc = function(xq, sh)
              local dh = u:getdata("千咲-浮空高度") - xq:getdata("千咲-浮空高度")
              qianxiao_fukong_tg(u, xq, dh, 0.1)
              unitmove({
                unit = xq.handle,
                time = 0.1,
                distance = 700,
                angle = jd,
                isblink = true
              })
            end
          })
        end
      end
      local cs = 0
      ac.loop(25, function(timer)
        cs = cs + 1
        local ax, ay = u:getxy()
        for _, xq in ac.selector():in_rangexy(ax, ay, 400):is_enemy(u.handle):isnotingroup(g):ipairs() do
          xq = getunit(xq)
          xq:groupadd(g)
          if xq:getdata("千咲-浮空高度") > 0 then
            Qianxiao_Damage({
              u = u,
              tg = xq,
              damage = txsh,
              skillstr = skillstr,
              extrafunc = function(xq, sh)
                local dh = u:getdata("千咲-浮空高度") - xq:getdata("千咲-浮空高度")
                qianxiao_fukong_tg(u, xq, dh, 0.1)
                unitmove({
                  unit = xq.handle,
                  time = 0.1,
                  distance = 700,
                  angle = jd,
                  isblink = true
                })
              end
            })
          end
        end
        if 4 <= cs then
          timer:remove()
        end
      end)
      ac.wait(100, function()
        local dx, dy = u:getxy()
        dx, dy = PolarXY(dx, dy, 300, jd)
        EffectcreateArgs({
          effect = "Qx\\qianxiao_baozha1.mdx",
          x = dx,
          y = dy,
          size = 3,
          height = -390 + gd,
          zxz = jd,
          animespeed = 10
        })
        EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang4.mdx",
          x = dx,
          y = dy,
          size = 5,
          height = 50 + gd,
          zxz = jd + 90,
          animespeed = 1
        })
        EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang3.mdx",
          x = dx,
          y = dy,
          size = 2,
          height = 190 + gd,
          zxz = jd + 90,
          animespeed = 2
        })
        EffectcreateArgs({
          effect = "war3mapImported\\Daji_Hong1.mdx",
          x = dx,
          y = dy,
          size = 40,
          zxz = jd,
          animespeed = 2.0
        })
        EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang10.mdx",
          x = x,
          y = y,
          size = 7,
          height = 0,
          zxz = jd,
          animespeed = 1
        })
        EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang10.mdx",
          x = dx,
          y = dy,
          size = 3,
          height = 10 + gd,
          zxz = jd,
          animespeed = 1
        })
        for i = 1, 5 do
          EffectcreateArgs({
            effect = "5dab9b48c482691b.mdl",
            x = dx,
            y = dy,
            size = 10,
            height = -150 + gd,
            zxz = GetRandomAngle()
          })
        end
        u:shockcamera(250, 0.1)
        ForGroupLuaNew(g, function(xq)
          if xq:getdata("千咲-浮空高度") > 0 then
            Qianxiao_Damage({
              u = u,
              tg = xq,
              damage = 2 * txsh,
              skillstr = skillstr,
              extrafunc = function(xq, sh)
                local dh = u:getdata("千咲-浮空高度") - xq:getdata("千咲-浮空高度")
                qianxiao_fukong_tg(u, xq, dh, 0.1)
              end
            })
          end
        end)
      end)
    end)
    u:setdata("千咲连携", "SE")
    u:setdata("千咲连携时间", zttime + lianxietime)
  end,
  SEE = function(u)
    local skillstr = "SEE"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    local gd = u:getdata("千咲-浮空高度")
    local zttime = 0.5
    local lianxietime = 0.8
    u:setdata("千咲连携", "")
    zhiguizantingtime(u, zttime, skillstr)
    wudisrtrtime(u, zttime + 0.2, skillstr)
    u:setskillcd("A0NW", 0.85)
    u:setskillcd("A0OD", 0.85)
    qianxiao_fukong(u, gd, 0.5)
    ac.wait(1, function()
      u:animeact(3)
      u:animespeed(1.4)
    end)
    Qianxiao_sound(u, Sound_Qianxiao_WW)
    Qianxiao_sound(u, Sound_Qianxiao_AAAAA)
    ac.wait(0, function()
      local voice_list = {}
      if u:hasdata("千咲-日配") then
        voice_list = {
          Sound_Qianxiao_yuyin_AAAAA1_Jp,
          Sound_Qianxiao_yuyin_AAAAA2_Jp,
          Sound_Qianxiao_yuyin_AAAAA3_Jp
        }
      else
        voice_list = {
          Sound_Qianxiao_yuyin_AAAAA1,
          Sound_Qianxiao_yuyin_AAAAA2,
          Sound_Qianxiao_yuyin_AAAAA3
        }
      end
      Qianxiao_sound(u, voice_list[GetRandomInt(1, #voice_list)])
    end)
    local cs1 = 0
    ac.loop(50, function(t1)
      cs1 = cs1 + 1
      EffectcreateArgs({
        effect = "war3mapImported\\Texiao_zhenhongxuli.mdx",
        x = x,
        y = y,
        size = 10 - 1 * cs1,
        height = -600 + gd,
        zxz = GetRandomAngle(),
        animespeed = 2
      })
      EffectcreateArgs({
        effect = "Qx\\qianxiao_baozha9.mdx",
        x = x,
        y = y,
        time = 0.2,
        size = 10 - 2 * cs1,
        height = 300 + gd,
        zxz = jd,
        animespeed = 1
      })
      u:shockcamera(50, 0.05)
      ac.wait(0, function()
        Qianxiao_Damage({
          u = u,
          mx = x,
          my = y,
          fw = 700,
          damage = txsh,
          isnotxh = true,
          isfk = true,
          isvest = true,
          skillstr = skillstr,
          extrafunc = function(xq, sh)
            if not xq:hasdata("免疫击退效果") then
              local x2, y2 = xq:getxy()
              local jd1 = AngleXY(x2, y2, x, y)
              x2, y2 = PolarXY(x2, y2, 50, jd1)
              xq:setxy(x2, y2)
            end
          end
        })
      end)
      if 8 <= cs1 then
        t1:remove()
      end
    end)
    local tx = EffectcreateArgs({
      effect = "war3mapImported\\heiquan.mdx",
      x = x,
      y = y,
      time = 2.4,
      size = 6,
      height = -10,
      zxz = jd,
      animespeed = 3.0
    })
    ac.wait(100, function()
      japi.EXSetEffectSpeed(tx, 0.0)
    end)
    ac.wait(450, function()
      japi.EXSetEffectSpeed(tx, 10.0)
    end)
    ac.wait(400, function()
      Qianxiao_sound(u, Sound_Qianxiao_AAAA2)
      qianxiao_fukong(u, -u:getdata("千咲-浮空高度"), 0.1)
      ac.wait(100, function()
        local x1, y1 = PolarXY(x, y, 0, jd)
        EffectcreateArgs({
          effect = "Qx\\qianxiao_baozha1.mdx",
          x = x1,
          y = y1,
          size = 3,
          height = -390 + gd,
          zxz = jd,
          animespeed = 10
        })
        EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang1.mdx",
          x = x1,
          y = y1,
          size = 2,
          height = 0,
          zxz = jd + 65,
          animespeed = 1
        })
        EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang1.mdx",
          x = x1,
          y = y1,
          size = 2,
          height = 0,
          zxz = jd - 65,
          animespeed = 1
        })
        EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang1.mdx",
          x = x1,
          y = y1,
          size = 2,
          height = 0,
          zxz = jd + 115,
          animespeed = 1
        })
        EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang1.mdx",
          x = x1,
          y = y1,
          size = 2,
          height = 0,
          zxz = jd - 115,
          animespeed = 1
        })
        EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang4.mdx",
          x = x1,
          y = y1,
          size = 3,
          height = 50,
          zxz = jd + 65,
          animespeed = 1.5
        })
        EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang3.mdx",
          x = x1,
          y = y1,
          size = 1.5,
          height = 190,
          zxz = jd + 65,
          animespeed = 2
        })
        EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang4.mdx",
          x = x1,
          y = y1,
          size = 3,
          height = 50,
          zxz = jd - 65,
          animespeed = 1.5
        })
        EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang3.mdx",
          x = x1,
          y = y1,
          size = 1.5,
          height = 190,
          zxz = jd - 65,
          animespeed = 2
        })
        local x2, y2 = PolarXY(x, y, -200, jd)
        local tx1 = EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang10.mdx",
          x = x2,
          y = y2,
          size = 6,
          height = 800,
          zxz = jd,
          yxz = 90,
          animespeed = 1
        })
        local x3, y3 = PolarXY(x, y, 200, jd)
        local tx2 = EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang10.mdx",
          x = x3,
          y = y3,
          size = 6,
          height = 800,
          zxz = jd + 180,
          yxz = 90,
          animespeed = 1
        })
        u:shockcamera(100, 0.1)
        Qianxiao_Damage({
          u = u,
          mx = x1,
          my = y1,
          fw = 700,
          damage = txsh * 6,
          isqf = true,
          skillstr = skillstr,
          extrafunc = function(xq, sh)
            if xq:getdata("千咲-浮空高度") > 0 then
              qianxiao_fukong_tg(u, xq, -xq:getdata("千咲-浮空高度"), 0.1)
            end
          end
        })
      end)
    end)
    u:setdata("千咲连携", "SEE")
    u:setdata("千咲连携时间", zttime + lianxietime)
  end,
  SR = function(u)
    local skillstr = "SR"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    local gd = u:getdata("千咲-浮空高度")
    local zttime = 0.2
    local lianxietime = 0.8
    u:setdata("千咲连携", "")
    zhiguizantingtime(u, zttime, skillstr)
    wudisrtrtime(u, zttime + 0.2, skillstr)
    ac.wait(1, function()
      u:animeact(6)
      u:animespeed(3)
    end)
    Qianxiao_sound(u, Sound_Qianxiao_A)
    Qianxiao_sound(u, Sound_Qianxiao_AA)
    local voice_list = {}
    if u:hasdata("千咲-日配") then
      Qianxiao_sound(u, Sound_Qianxiao_yuyin_A_Jp)
    else
      Qianxiao_sound(u, Sound_Qianxiao_yuyin_A)
    end
    qianxiao_fukong(u, 0, 0.3)
    u:effectadd("Qx\\qianxiao_tuowei1.mdx", "origin", 0.4)
    local g = CreateGroupLua()
    ac.wait(100, function()
      Qianxiao_Move(u, 0.1, 1000, jd)
      local cs = 0
      ac.loop(10, function(timer)
        cs = cs + 1
        local ax, ay = u:getxy()
        for _, xq in ac.selector():in_rangexy(ax, ay, 350):is_enemy(u.handle):isnotingroup(g):ipairs() do
          xq = getunit(xq)
          xq:groupadd(g)
          if xq:getdata("千咲-浮空高度") > 0 then
            Qianxiao_Damage({
              u = u,
              tg = xq,
              damage = txsh,
              isfk = true,
              skillstr = skillstr,
              extrafunc = function(xq, sh)
                local dh = u:getdata("千咲-浮空高度") - xq:getdata("千咲-浮空高度")
                if dh <= 0 then
                  dh = 0
                end
                qianxiao_fukong_tg(u, xq, dh, 0.1)
                unitmove({
                  unit = xq.handle,
                  time = 0.2,
                  distance = 100,
                  angle = jd,
                  isfly = true
                })
              end
            })
          end
        end
        if cs == 10 then
          timer:remove()
        end
      end)
      ac.wait(100, function()
        local x1, y1 = PolarXY(x, y, 400, jd)
        EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang4.mdx",
          x = x1,
          y = y1,
          size = 2.5,
          height = -30 + gd,
          zxz = jd,
          animespeed = 1
        })
        EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang3.mdx",
          x = x1,
          y = y1,
          size = 1,
          height = 50 + gd,
          zxz = jd,
          animespeed = 2
        })
        u:shockcamera(25, 0.1)
      end)
    end)
    ac.wait(300, function()
      u:animeact(2)
      u:animespeed(1)
      local x1, y1 = PolarXY(x, y, -400, jd)
      EffectcreateArgs({
        effect = "Qx\\qianxiao_daoguang4.mdx",
        x = x1,
        y = y1,
        size = 0.5,
        height = 115 + gd,
        zxz = jd + 45,
        animespeed = 1
      })
      EffectcreateArgs({
        effect = "Qx\\qianxiao_daoguang3.mdx",
        x = x1,
        y = y1,
        size = 0.2,
        height = 130 + gd,
        zxz = jd + 45,
        animespeed = 2
      })
      ForGroupLuaNew(g, function(xq)
        if xq:getdata("千咲-浮空高度") > 0 then
          Qianxiao_Damage({
            u = u,
            tg = xq,
            damage = txsh,
            isfk = true,
            skillstr = skillstr,
            extrafunc = function(xq, sh)
              local dh = u:getdata("千咲-浮空高度") - xq:getdata("千咲-浮空高度")
              if dh <= 0 then
                dh = 0
              end
              qianxiao_fukong_tg(u, xq, dh, 0.1)
              unitmove({
                unit = xq.handle,
                time = 0.2,
                distance = 100,
                angle = jd,
                isfly = true
              })
            end
          })
        end
      end)
    end)
    ac.wait(375, function()
      local x1, y1 = PolarXY(x, y, 0, jd)
      EffectcreateArgs({
        effect = "Qx\\qianxiao_daoguang4.mdx",
        x = x1,
        y = y1,
        size = 0.75,
        height = 110 + gd,
        zxz = jd - 45,
        animespeed = 1
      })
      EffectcreateArgs({
        effect = "Qx\\qianxiao_daoguang3.mdx",
        x = x1,
        y = y1,
        size = 0.3,
        height = 130 + gd,
        zxz = jd - 45,
        animespeed = 2
      })
      ForGroupLuaNew(g, function(xq)
        if xq:getdata("千咲-浮空高度") > 0 then
          Qianxiao_Damage({
            u = u,
            tg = xq,
            damage = txsh,
            isfk = true,
            skillstr = skillstr,
            extrafunc = function(xq, sh)
              local dh = u:getdata("千咲-浮空高度") - xq:getdata("千咲-浮空高度")
              if dh <= 0 then
                dh = 0
              end
              qianxiao_fukong_tg(u, xq, dh, 0.1)
              unitmove({
                unit = xq.handle,
                time = 0.2,
                distance = 100,
                angle = jd,
                isfly = true
              })
            end
          })
        end
      end)
    end)
    ac.wait(450, function()
      Qianxiao_sound(u, Sound_Qianxiao_Q)
      local x1, y1 = PolarXY(x, y, 600, jd)
      local x2, y2 = PolarXY(x, y, 200, jd)
      EffectcreateArgs({
        effect = "Qx\\qianxiao_daoguang4.mdx",
        x = x1,
        y = y1,
        size = 1,
        height = 105 + gd,
        zxz = jd + 20,
        animespeed = 1.5
      })
      EffectcreateArgs({
        effect = "Qx\\qianxiao_daoguang3.mdx",
        x = x1,
        y = y1,
        size = 0.4,
        height = 130 + gd,
        zxz = jd + 20,
        animespeed = 2
      })
      EffectcreateArgs({
        effect = "war3mapImported\\Daji_Hong1.mdx",
        x = x2,
        y = y2,
        size = 5,
        height = gd,
        zxz = jd,
        animespeed = 2.0
      })
      for i = 1, 5 do
        EffectcreateArgs({
          effect = "5dab9b48c482691b.mdl",
          x = x2,
          y = y2,
          size = 5,
          height = gd,
          zxz = GetRandomAngle(),
          animespeed = 3
        })
      end
      ForGroupLuaNew(g, function(xq)
        if xq:getdata("千咲-浮空高度") > 0 then
          Qianxiao_Damage({
            u = u,
            tg = xq,
            damage = txsh,
            isfk = true,
            skillstr = skillstr,
            extrafunc = function(xq, sh)
              local dh = u:getdata("千咲-浮空高度") - xq:getdata("千咲-浮空高度")
              if dh <= 0 then
                dh = 0
              end
              qianxiao_fukong_tg(u, xq, dh, 0.1)
              unitmove({
                unit = xq.handle,
                time = 0.2,
                distance = 100,
                angle = jd,
                isfly = true
              })
            end
          })
        end
      end)
      u:shockcamera(25, 0.1)
    end)
    u:setdata("千咲连携", "SR")
    u:setdata("千咲连携时间", zttime + lianxietime)
  end,
  SRR = function(u)
    local skillstr = "SRR"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    local gd = u:getdata("千咲-浮空高度")
    local zttime = 0.9
    local lianxietime = 0.8
    u:setdata("千咲连携", "")
    zhiguizantingtime(u, zttime, skillstr)
    wudisrtrtime(u, zttime + 0.2, skillstr)
    Qianxiao_sound(u, Sound_Qianxiao_WWW1)
    ac.wait(1, function()
      u:animeact(1)
      u:animespeed(1)
    end)
    local g = CreateGroupLua()
    local h = 400 - u:getdata("千咲-浮空高度")
    if h <= 50 then
      h = 50
    end
    h = h / 4
    ac.wait(0, function()
      local dx, dy = u:getxy()
      Qianxiao_Move(u, 0.7, 100, jd)
      qianxiao_fukong(u, h, 0.1)
      qianxiao_fukongdaoguang({
        u = u,
        dx = dx,
        dy = dy,
        jd = jd,
        xz = 0,
        iszheng = 1
      })
      Qianxiao_Damage({
        u = u,
        mx = dx,
        my = dy,
        fw = 400,
        damage = txsh,
        isfk = true,
        skillstr = skillstr,
        extrafunc = function(xq, sh)
          local dh = u:getdata("千咲-浮空高度") - xq:getdata("千咲-浮空高度")
          qianxiao_fukong_tg(u, xq, dh, 0.1)
          unitmove({
            unit = xq.handle,
            time = 0.1,
            distance = 25,
            angle = jd,
            isblink = true
          })
          xq:groupadd(g)
        end
      })
    end)
    ac.wait(100, function()
      local dx, dy = u:getxy()
      qianxiao_fukong(u, h, 0.1)
      qianxiao_fukongdaoguang({
        u = u,
        dx = dx,
        dy = dy,
        jd = jd,
        xz = 90,
        iszheng = -1
      })
      Qianxiao_Damage({
        u = u,
        mx = dx,
        my = dy,
        fw = 400,
        damage = txsh,
        isfk = true,
        skillstr = skillstr,
        extrafunc = function(xq, sh)
          local dh = u:getdata("千咲-浮空高度") - xq:getdata("千咲-浮空高度")
          qianxiao_fukong_tg(u, xq, dh, 0.1)
          unitmove({
            unit = xq.handle,
            time = 0.1,
            distance = 25,
            angle = jd,
            isblink = true
          })
          xq:groupadd(g)
        end
      })
    end)
    ac.wait(200, function()
      local dx, dy = u:getxy()
      qianxiao_fukong(u, h, 0.1)
      qianxiao_fukongdaoguang({
        u = u,
        dx = dx,
        dy = dy,
        jd = jd,
        xz = 0,
        iszheng = -1
      })
      Qianxiao_Damage({
        u = u,
        mx = dx,
        my = dy,
        fw = 400,
        damage = txsh,
        isfk = true,
        skillstr = skillstr,
        extrafunc = function(xq, sh)
          local dh = u:getdata("千咲-浮空高度") - xq:getdata("千咲-浮空高度")
          qianxiao_fukong_tg(u, xq, dh, 0.1)
          unitmove({
            unit = xq.handle,
            time = 0.1,
            distance = 25,
            angle = jd,
            isblink = true
          })
          xq:groupadd(g)
        end
      })
    end)
    ac.wait(300, function()
      local dx, dy = u:getxy()
      qianxiao_fukong(u, h, 0.1)
      qianxiao_fukongdaoguang({
        u = u,
        dx = dx,
        dy = dy,
        jd = jd,
        xz = 180,
        iszheng = -1
      })
      Qianxiao_Damage({
        u = u,
        mx = dx,
        my = dy,
        fw = 400,
        damage = txsh,
        isfk = true,
        skillstr = skillstr,
        extrafunc = function(xq, sh)
          local dh = u:getdata("千咲-浮空高度") - xq:getdata("千咲-浮空高度")
          qianxiao_fukong_tg(u, xq, dh, 0.1)
          unitmove({
            unit = xq.handle,
            time = 0.1,
            distance = 25,
            angle = jd,
            isblink = true
          })
          xq:groupadd(g)
        end
      })
    end)
    local jl = 250
    ac.wait(800, function()
      local dx, dy = u:getxy()
      qianxiao_fukong(u, -u:getdata("千咲-浮空高度"), 0.1)
      Qianxiao_Move(u, 0.1, jl, jd)
      Qianxiao_Damage({
        u = u,
        mx = dx,
        my = dy,
        fw = 400,
        damage = 1.5 * txsh,
        isfk = true,
        isnotxh = true,
        skillstr = skillstr,
        extrafunc = function(xq, sh)
          xq:groupadd(g)
          qianxiao_fukong_tg(u, xq, -xq:getdata("千咲-浮空高度"), 0.1)
          unitmove({
            unit = xq.handle,
            time = 0.1,
            distance = 100,
            angle = jd,
            isblink = true
          })
        end
      })
    end)
    ac.wait(900, function()
      u:shockcamera(150, 0.1)
      u:animeact(4)
      u:animespeed(1)
      local ax, ay = u:getxy()
      local dx, dy = PolarXY(ax, ay, -400, jd)
      EffectcreateArgs({
        effect = "Qx\\qianxiao_daoguang4.mdx",
        x = dx,
        y = dy,
        size = 10,
        height = 450,
        zxz = jd + 180,
        yxz = -70,
        animespeed = 1
      })
      dx, dy = PolarXY(ax, ay, 100, jd)
      EffectcreateArgs({
        effect = "Qx\\qianxiao_daoguang3.mdx",
        x = dx,
        y = dy,
        size = 3,
        height = 0,
        zxz = jd,
        yxz = 70,
        animespeed = 2
      })
      dx, dy = PolarXY(ax, ay, 20, jd)
      EffectcreateArgs({
        effect = "Qx\\qianxiao_baozha5.mdx",
        x = dx,
        y = dy,
        size = 3,
        height = 0,
        zxz = jd + 180,
        animespeed = 2
      })
      for i = 1, 2 do
        EffectcreateArgs({
          effect = "Qx\\qianxiao_shandian1.mdx",
          x = dx,
          y = dy,
          size = 10,
          height = -450,
          zxz = jd + 270,
          animespeed = 0.5
        })
        EffectcreateArgs({
          effect = "Qx\\qianxiao_baozha5.mdx",
          x = dx,
          y = dy,
          size = 4,
          height = -100,
          zxz = jd + 270,
          animespeed = 2
        })
      end
      EffectcreateArgs({
        effect = "war3mapImported\\Daji_Hong1.mdx",
        x = x,
        y = y,
        size = 40,
        zxz = jd + 180,
        animespeed = 2.0
      })
      dx, dy = PolarXY(ax, ay, 100, jd)
      Qianxiao_Damage({
        u = u,
        mx = dx,
        my = dy,
        fw = 600,
        damage = 2 * txsh,
        skillstr = skillstr
      })
    end)
    u:setdata("千咲连携", "SRR")
    u:setdata("千咲连携时间", zttime + lianxietime)
  end,
  SA = function(u)
    local skillstr = "SA"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    local gd = u:getdata("千咲-浮空高度")
    local zttime = 0.0
    local lianxietime = 0.8
    u:setdata("千咲连携", "")
    zhiguizantingtime(u, zttime, skillstr)
    wudisrtrtime(u, zttime + 0.2, skillstr)
    qianxiao_fukong(u, 0, 0.05)
    local h = u:getdata("千咲-浮空高度")
    ac.wait(1, function()
      u:animeact(1)
      u:animespeed(1)
      qianxiao_fukong(u, 0, 0.01)
      Qianxiao_Move(u, 0.1, 100, jd)
      Qianxiao_sound(u, Sound_Qianxiao_A)
      local voice_list = {}
      if u:hasdata("千咲-日配") then
        Qianxiao_sound(u, Sound_Qianxiao_yuyin_A_Jp)
      else
        Qianxiao_sound(u, Sound_Qianxiao_yuyin_A)
      end
    end)
    ac.wait(300, function()
      if u:getdata("千咲连携") == "SA" then
        u:animeact(2)
      end
    end)
    do
      local dx, dy = u:getxy()
      dx, dy = PolarXY(x, y, 100, jd + 90)
      local tx = EffectcreateArgs({
        effect = "Qx\\qianxiao_tuowei1.mdx",
        x = dx,
        y = dy,
        time = 0.5,
        size = 1,
        height = h,
        zxz = jd,
        animespeed = 2
      })
      ac.wait(50, function()
        local x1, y1 = PolarXY(x, y, 300, jd + 45)
        japi.EXSetEffectXY(tx, x1, y1)
        x1, y1 = PolarXY(x, y, 100, jd + 90)
        local tx1 = EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang1.mdx",
          x = x1,
          y = y1,
          size = 0.5,
          height = h,
          zxz = jd + 30,
          animespeed = 2
        })
        ac.wait(100, function()
          japi.EXSetEffectSpeed(tx1, 10)
        end)
      end)
      ac.wait(100, function()
        local x1, y1 = PolarXY(x, y, 400, jd - 20)
        japi.EXSetEffectXY(tx, x1, y1)
        x1, y1 = PolarXY(x, y, 300, jd)
        local tx1 = EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang1.mdx",
          x = x1,
          y = y1,
          size = 0.5,
          height = h,
          zxz = jd + 120,
          animespeed = 2
        })
        ac.wait(100, function()
          japi.EXSetEffectSpeed(tx1, 10)
        end)
      end)
      ac.wait(150, function()
        local x1, y1 = PolarXY(x, y, 150, jd - 90)
        japi.EXSetEffectXY(tx, x1, y1)
        x1, y1 = PolarXY(x, y, 200, jd - 45)
        local tx1 = EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang1.mdx",
          x = x1,
          y = y1,
          size = 0.5,
          height = h,
          zxz = jd,
          animespeed = 2
        })
        ac.wait(100, function()
          japi.EXSetEffectSpeed(tx1, 10)
        end)
        u:shockcamera(25, 0.1)
      end)
    end
    ac.wait(100, function()
      local x1, y1 = PolarXY(x, y, 150, jd)
      Qianxiao_Damage({
        u = u,
        mx = x1,
        my = y1,
        fw = 300,
        damage = txsh,
        jt = 50,
        jd = jd,
        isfk = true,
        skillstr = skillstr,
        extrafunc = function(xq, sh)
          local dh = u:getdata("千咲-浮空高度") - xq:getdata("千咲-浮空高度")
          qianxiao_fukong_tg(u, xq, dh, 0.1)
          unitmove({
            unit = xq.handle,
            time = 0.1,
            distance = 25,
            angle = jd,
            isblink = true
          })
        end
      })
    end)
    u:setdata("千咲连携", "SA")
    u:setdata("千咲连携时间", zttime + lianxietime)
  end,
  SAA = function(u)
    local skillstr = "SAA"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    local ojd = u:getface()
    local zttime = 0.35
    local lianxietime = 0.8
    u:setdata("千咲连携", "")
    zhiguizantingtime(u, zttime, skillstr)
    wudisrtrtime(u, zttime + 0.1, skillstr)
    local h = u:getdata("千咲-浮空高度")
    ac.wait(1, function()
      u:animeact(1)
      u:animespeed(1.5)
      qianxiao_fukong(u, 0, 0.35)
    end)
    ac.wait(0, function()
      local dx, dy = u:getxy()
      dx, dy = PolarXY(dx, dy, 0, jd)
      Qianxiao_Move(u, 0.1, 200, jd)
      Qianxiao_sound(u, Sound_Qianxiao_AA)
      dx, dy = PolarXY(x, y, 100, jd + 90)
      local tx = EffectcreateArgs({
        effect = "Qx\\qianxiao_tuowei1.mdx",
        x = dx,
        y = dy,
        time = 0.5,
        size = 1,
        height = h,
        zxz = jd,
        animespeed = 2
      })
      ac.wait(50, function()
        local x1, y1 = PolarXY(x, y, 300, jd + 45)
        japi.EXSetEffectXY(tx, x1, y1)
        x1, y1 = PolarXY(x, y, 100, jd + 90)
        local tx1 = EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang1.mdx",
          x = x1,
          y = y1,
          size = 0.5,
          height = h,
          zxz = jd + 30,
          animespeed = 2
        })
        ac.wait(100, function()
          japi.EXSetEffectSpeed(tx1, 10)
        end)
      end)
      ac.wait(100, function()
        local x1, y1 = PolarXY(x, y, 400, jd - 20)
        japi.EXSetEffectXY(tx, x1, y1)
        x1, y1 = PolarXY(x, y, 300, jd)
        local tx1 = EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang1.mdx",
          x = x1,
          y = y1,
          size = 0.5,
          height = h,
          zxz = jd + 120,
          animespeed = 2
        })
        ac.wait(100, function()
          japi.EXSetEffectSpeed(tx1, 10)
        end)
      end)
      ac.wait(150, function()
        local x1, y1 = PolarXY(x, y, 150, jd - 90)
        japi.EXSetEffectXY(tx, x1, y1)
        x1, y1 = PolarXY(x, y, 200, jd - 45)
        local tx1 = EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang1.mdx",
          x = x1,
          y = y1,
          size = 0.5,
          height = h,
          zxz = jd,
          animespeed = 2
        })
        ac.wait(100, function()
          japi.EXSetEffectSpeed(tx1, 10)
        end)
        u:shockcamera(50, 0.1)
        ac.wait(0, function()
          local djx, djy = u:getxy()
          Qianxiao_Damage({
            u = u,
            mx = djx,
            my = djy,
            fw = 300,
            damage = txsh,
            jt = 75,
            jd = jd,
            isfk = true,
            skillstr = skillstr,
            extrafunc = function(xq, sh)
              local dh = u:getdata("千咲-浮空高度") - xq:getdata("千咲-浮空高度")
              qianxiao_fukong_tg(u, xq, dh, 0.1)
            end
          })
        end)
      end)
    end)
    ac.wait(100, function()
      local x, y = u:getxy()
      x, y = PolarXY(x, y, 300, jd)
      local jd = u:getface() - 180
      ac.wait(0, function()
        local dx, dy = u:getxy()
        dx, dy = PolarXY(dx, dy, 0, jd)
        dx, dy = PolarXY(x, y, 100, jd + 90)
        local tx = EffectcreateArgs({
          effect = "Qx\\qianxiao_tuowei1.mdx",
          x = dx,
          y = dy,
          time = 0.5,
          size = 1,
          height = h,
          zxz = jd,
          animespeed = 2
        })
        ac.wait(50, function()
          local x1, y1 = PolarXY(x, y, 300, jd + 45)
          japi.EXSetEffectXY(tx, x1, y1)
          x1, y1 = PolarXY(x, y, 100, jd + 90)
          local tx1 = EffectcreateArgs({
            effect = "Qx\\qianxiao_daoguang1.mdx",
            x = x1,
            y = y1,
            size = 0.5,
            height = 100 + h,
            zxz = jd + 30,
            animespeed = 2
          })
          ac.wait(100, function()
            japi.EXSetEffectSpeed(tx1, 10)
          end)
        end)
        ac.wait(100, function()
          local x1, y1 = PolarXY(x, y, 400, jd - 20)
          japi.EXSetEffectXY(tx, x1, y1)
          x1, y1 = PolarXY(x, y, 300, jd)
          local tx1 = EffectcreateArgs({
            effect = "Qx\\qianxiao_daoguang1.mdx",
            x = x1,
            y = y1,
            size = 0.5,
            height = 100 + h,
            zxz = jd + 120,
            animespeed = 2
          })
          ac.wait(100, function()
            japi.EXSetEffectSpeed(tx1, 10)
          end)
        end)
        ac.wait(150, function()
          local x1, y1 = PolarXY(x, y, 150, jd - 90)
          japi.EXSetEffectXY(tx, x1, y1)
          x1, y1 = PolarXY(x, y, 200, jd - 45)
          local tx1 = EffectcreateArgs({
            effect = "Qx\\qianxiao_daoguang1.mdx",
            x = x1,
            y = y1,
            size = 0.5,
            height = 100 + h,
            zxz = jd,
            animespeed = 2
          })
          ac.wait(100, function()
            japi.EXSetEffectSpeed(tx1, 10)
          end)
          local djx, djy = u:getxy()
          Qianxiao_Damage({
            u = u,
            mx = djx,
            my = djy,
            fw = 300,
            damage = txsh,
            jt = 75,
            jd = ojd,
            isfk = true,
            skillstr = skillstr,
            extrafunc = function(xq, sh)
              local dh = u:getdata("千咲-浮空高度") - xq:getdata("千咲-浮空高度")
              qianxiao_fukong_tg(u, xq, dh, 0.1)
            end
          })
        end)
      end)
    end)
    ac.wait(250, function()
      Qianxiao_Move(u, 0.1, 200, jd)
    end)
    ac.wait(350, function()
      local voice_list = {}
      if u:hasdata("千咲-日配") then
        Qianxiao_sound(u, Sound_Qianxiao_yuyin_AA_Jp)
      else
        Qianxiao_sound(u, Sound_Qianxiao_yuyin_AA)
      end
      local dx, dy = u:getxy()
      dx, dy = PolarXY(dx, dy, 200, jd)
      EffectcreateArgs({
        effect = "Qx\\qianxiao_daoguang1.mdx",
        x = dx,
        y = dy,
        size = 1,
        height = -100 + h,
        zxz = jd + 270,
        animespeed = 2
      })
      EffectcreateArgs({
        effect = "Qx\\qianxiao_daoguang1.mdx",
        x = dx,
        y = dy,
        size = 1,
        height = -50 + h,
        zxz = jd + 270,
        yxz = 20,
        animespeed = 2
      })
      u:shockcamera(100, 0.1)
      local djx, djy = u:getxy()
      Qianxiao_Damage({
        u = u,
        mx = djx,
        my = djy,
        fw = 300,
        damage = 2 * txsh,
        jt = 125,
        jd = jd,
        isfk = true,
        skillstr = skillstr,
        extrafunc = function(xq, sh)
          local dh = u:getdata("千咲-浮空高度") - xq:getdata("千咲-浮空高度")
          qianxiao_fukong_tg(u, xq, dh, 0.1)
        end
      })
    end)
    u:setdata("千咲连携", "SAA")
    u:setdata("千咲连携时间", zttime + lianxietime)
  end,
  SAAA = function(u)
    local skillstr = "SAAA"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    local ojd = u:getface()
    local zttime = 0.05
    local lianxietime = 2.5
    u:setdata("千咲连携", "")
    zhiguizantingtime(u, zttime, skillstr)
    wudisrtrtime(u, zttime + 0.1, skillstr)
    local h = u:getdata("千咲-浮空高度")
    Qianxiao_sound(u, Sound_Qianxiao_NewWW)
    ac.wait(1, function()
      u:animeact(5)
      u:animespeed(1)
    end)
    qianxiao_fukong(u, 0, 0.05)
    ac.wait(50, function()
      Qianxiao_Move(u, 0.1, 150, jd)
      local dx, dy = u:getxy()
      dx, dy = PolarXY(dx, dy, 300, jd)
      EffectcreateArgs({
        effect = "Qx\\qianxiao_baozha1.mdx",
        x = dx,
        y = dy,
        size = 1,
        height = -390 + h,
        zxz = jd,
        animespeed = 10
      })
      EffectcreateArgs({
        effect = "Qx\\qianxiao_daoguang4.mdx",
        x = dx,
        y = dy,
        size = 1,
        height = 150 + h,
        zxz = jd + 90,
        animespeed = 1
      })
      EffectcreateArgs({
        effect = "Qx\\qianxiao_daoguang3.mdx",
        x = dx,
        y = dy,
        size = 0.75,
        height = 190 + h,
        zxz = jd + 90,
        animespeed = 2
      })
      EffectcreateArgs({
        effect = "war3mapImported\\Daji_Hong1.mdx",
        x = dx,
        y = dy,
        size = 10,
        height = h,
        zxz = jd,
        animespeed = 2.0
      })
      EffectcreateArgs({
        effect = "Qx\\qianxiao_daoguang10.mdx",
        x = x,
        y = y,
        size = 1.5,
        height = 0 + h,
        zxz = jd,
        animespeed = 1
      })
      EffectcreateArgs({
        effect = "Qx\\qianxiao_daoguang10.mdx",
        x = dx,
        y = dy,
        size = 1.5,
        height = 10 + h,
        zxz = jd,
        animespeed = 1
      })
      for i = 1, 5 do
        EffectcreateArgs({
          effect = "5dab9b48c482691b.mdl",
          x = dx,
          y = dy,
          size = 2,
          height = 0 + h,
          zxz = GetRandomAngle()
        })
      end
      u:shockcamera(75, 0.1)
      local x1, y1 = PolarXY(x, y, 125, jd)
      local fw = 375
      if u:hasdata("千咲天赋-昙切") then
        fw = fw + 30
      end
      Qianxiao_Damage({
        u = u,
        mx = x1,
        my = y1,
        fw = fw,
        damage = txsh,
        jt = 150,
        jd = jd,
        isfk = true,
        skillstr = skillstr,
        extrafunc = function(xq, sh)
          local dh = u:getdata("千咲-浮空高度") - xq:getdata("千咲-浮空高度")
          qianxiao_fukong_tg(u, xq, dh, 0.1)
        end
      })
    end)
    u:setdata("千咲连携", "SAAA")
    u:setdata("千咲连携时间", zttime + lianxietime)
  end,
  SS = function(u)
    local skillstr = "SS"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    local gd = u:getdata("千咲-浮空高度")
    local zttime = 0.55
    local lianxietime = 0.8
    u:setdata("千咲连携", "")
    zhiguizantingtime(u, zttime, skillstr)
    wudisrtrtime(u, zttime + 0.2, skillstr)
    u:setdata("千咲-落地不断连时间", zttime + lianxietime + 0.3)
    qianxiao_fukong(u, 0, 0.3)
    Qianxiao_sound(u, Sound_Qianxiao_WWW1)
    ac.wait(1, function()
      u:animeact(15)
      u:animespeed(2)
    end)
    ac.wait(0, function()
      Qianxiao_Move(u, 0.7, 75, jd)
    end)
    ac.wait(350, function()
      qianxiao_fukong(u, -gd, 0.1)
    end)
    ac.wait(450, function()
      u:shockcamera(100, 0.1)
      Qianxiao_Move(u, 0.1, 150, jd)
      local dx, dy = u:getxy()
      Qianxiao_Damage({
        u = u,
        mx = dx,
        my = dy,
        fw = 400,
        isfk = true,
        damage = txsh,
        skillstr = skillstr,
        extrafunc = function(xq, sh)
          unitmove({
            unit = xq.handle,
            time = 0.1,
            distance = 125,
            angle = jd,
            isblink = true
          })
          qianxiao_fukong_tg(u, xq, 0, 0.1)
        end
      })
      ac.wait(100, function()
        local dx, dy = u:getxy()
        dx, dy = PolarXY(dx, dy, 150, jd)
        Qianxiao_Damage({
          u = u,
          mx = dx,
          my = dy,
          fw = 400,
          damage = txsh,
          skillstr = skillstr,
          extrafunc = function(xq, sh)
            unitmove({
              unit = xq.handle,
              time = 0.1,
              distance = 75,
              angle = jd,
              isblink = true
            })
            if xq:getdata("千咲-浮空高度") > 0 then
              qianxiao_fukong_tg(u, xq, 0, 0.1)
            end
          end
        })
        EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang4.mdx",
          x = dx,
          y = dy,
          size = 3,
          height = 50,
          zxz = jd + 90,
          xxz = 180,
          yxz = 170,
          animespeed = 1.5
        })
        EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang3.mdx",
          x = dx,
          y = dy,
          size = 1,
          height = 125,
          zxz = jd + 90,
          xxz = 180,
          yxz = 170,
          animespeed = 2
        })
        for i = 1, 2 do
          EffectcreateArgs({
            effect = "Qx\\qianxiao_shandian1.mdx",
            x = dx,
            y = dy,
            size = 10,
            height = -450,
            zxz = jd,
            animespeed = 0.5
          })
        end
        EffectcreateArgs({
          effect = "war3mapImported\\Daji_Hong1.mdx",
          x = dx,
          y = dy,
          size = 40,
          zxz = jd,
          animespeed = 2.0
        })
      end)
    end)
    u:setdata("千咲连携", "SS")
    u:setdata("千咲连携时间", zttime + lianxietime)
  end,
  SW = function(u)
    local skillstr = "SW"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    local gd = u:getdata("千咲-浮空高度")
    local zttime = 0
    local lianxietime = 0.8
    u:setdata("千咲连携", "")
    zhiguizantingtime(u, zttime, skillstr)
    wudisrtrtime(u, zttime + 0.2, skillstr)
    u:buffset(u.handle, 0.15, "绝对闪避")
    local g = CreateGroupLua()
    ac.wait(1, function()
      u:animeact(1)
      u:animespeed(1.5)
    end)
    ac.wait(0, function()
      local dx, dy = u:getxy()
      qianxiao_fukong(u, 0, 0.1)
      Qianxiao_Move(u, 0.7, 100, jd)
      Qianxiao_Move(u, 0.2, 600, jd)
      Qianxiao_sound(u, Sound_Qianxiao_Q)
      dx, dy = PolarXY(x, y, 100, jd + 90)
      local tx = EffectcreateArgs({
        effect = "Qx\\qianxiao_tuowei1.mdx",
        x = dx,
        y = dy,
        time = 0.5,
        size = 1,
        height = gd + 50,
        zxz = jd,
        animespeed = 2
      })
      EffectcreateArgs({
        effect = "Qx\\qianxiao_shandian1.mdx",
        x = dx,
        y = dy,
        size = 10,
        height = gd - 400,
        zxz = jd,
        animespeed = 1.5
      })
      ac.wait(100, function()
        local x1, y1 = PolarXY(x, y, 600, jd)
        japi.EXSetEffectXY(tx, x1, y1)
      end)
      local ax, ay = u:getxy()
      for _, xq in ac.selector():in_rangexy(ax, ay, 350):is_enemy(u.handle):isnotingroup(g):ipairs() do
        xq = getunit(xq)
        xq:groupadd(g)
        if 0 < xq:getdata("千咲-浮空高度") then
          Qianxiao_Damage({
            u = u,
            tg = xq,
            damage = txsh,
            skillstr = skillstr,
            extrafunc = function(xq, sh)
              local dh = u:getdata("千咲-浮空高度") - xq:getdata("千咲-浮空高度")
              qianxiao_fukong_tg(u, xq, dh, 0.3)
              unitmove({
                unit = xq.handle,
                time = 0.1,
                distance = 25,
                angle = jd,
                isblink = true
              })
            end
          })
        end
      end
      local cs = 0
      ac.loop(50, function(timer)
        cs = cs + 1
        local ax, ay = u:getxy()
        for _, xq in ac.selector():in_rangexy(ax, ay, 350):is_enemy(u.handle):isnotingroup(g):ipairs() do
          xq = getunit(xq)
          xq:groupadd(g)
          if xq:getdata("千咲-浮空高度") > 0 then
            Qianxiao_Damage({
              u = u,
              tg = xq,
              damage = txsh,
              skillstr = skillstr,
              extrafunc = function(xq, sh)
                local dh = u:getdata("千咲-浮空高度") - xq:getdata("千咲-浮空高度")
                qianxiao_fukong_tg(u, xq, dh, 0.3)
                unitmove({
                  unit = xq.handle,
                  time = 0.1,
                  distance = 25,
                  angle = jd,
                  isblink = true
                })
              end
            })
          end
        end
        if 4 <= cs then
          timer:remove()
        end
      end)
    end)
    u:setdata("千咲连携", "SW")
    u:setdata("千咲连携时间", zttime + lianxietime)
  end,
  SQ = function(u)
    local skillstr = "SQ"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface() + 180
    local gd = u:getdata("千咲-浮空高度")
    local zttime = 0
    local lianxietime = 0.8
    u:setdata("千咲连携", "")
    zhiguizantingtime(u, zttime, skillstr)
    wudisrtrtime(u, zttime + 0.2, skillstr)
    u:buffset(u.handle, 0.15, "绝对闪避")
    local g = CreateGroupLua()
    ac.wait(1, function()
      u:animeact(1)
      u:animespeed(1.5)
    end)
    ac.wait(0, function()
      local dx, dy = u:getxy()
      qianxiao_fukong(u, 0, 0.1)
      Qianxiao_Move(u, 0.7, 100, jd)
      Qianxiao_Move(u, 0.2, 600, jd)
      Qianxiao_sound(u, Sound_Qianxiao_Q)
      dx, dy = PolarXY(x, y, 100, jd + 90)
      local tx = EffectcreateArgs({
        effect = "Qx\\qianxiao_tuowei1.mdx",
        x = dx,
        y = dy,
        time = 0.5,
        size = 1,
        height = gd + 50,
        zxz = jd,
        animespeed = 2
      })
      EffectcreateArgs({
        effect = "Qx\\qianxiao_shandian1.mdx",
        x = dx,
        y = dy,
        size = 10,
        height = gd - 400,
        zxz = jd,
        animespeed = 1.5
      })
      ac.wait(100, function()
        local x1, y1 = PolarXY(x, y, 600, jd)
        japi.EXSetEffectXY(tx, x1, y1)
      end)
      local ax, ay = u:getxy()
      for _, xq in ac.selector():in_rangexy(ax, ay, 350):is_enemy(u.handle):isnotingroup(g):ipairs() do
        xq = getunit(xq)
        xq:groupadd(g)
        if 0 < xq:getdata("千咲-浮空高度") then
          Qianxiao_Damage({
            u = u,
            tg = xq,
            damage = txsh,
            skillstr = skillstr,
            extrafunc = function(xq, sh)
              local dh = u:getdata("千咲-浮空高度") - xq:getdata("千咲-浮空高度")
              qianxiao_fukong_tg(u, xq, dh, 0.3)
              unitmove({
                unit = xq.handle,
                time = 0.1,
                distance = 25,
                angle = jd,
                isblink = true
              })
            end
          })
        end
      end
      local cs = 0
      ac.loop(50, function(timer)
        cs = cs + 1
        local ax, ay = u:getxy()
        for _, xq in ac.selector():in_rangexy(ax, ay, 350):is_enemy(u.handle):isnotingroup(g):ipairs() do
          xq = getunit(xq)
          xq:groupadd(g)
          if xq:getdata("千咲-浮空高度") > 0 then
            Qianxiao_Damage({
              u = u,
              tg = xq,
              damage = txsh,
              skillstr = skillstr,
              extrafunc = function(xq, sh)
                local dh = u:getdata("千咲-浮空高度") - xq:getdata("千咲-浮空高度")
                qianxiao_fukong_tg(u, xq, dh, 0.3)
                unitmove({
                  unit = xq.handle,
                  time = 0.1,
                  distance = 25,
                  angle = jd,
                  isblink = true
                })
              end
            })
          end
        end
        if 4 <= cs then
          timer:remove()
        end
      end)
    end)
    u:setdata("千咲连携", "SQ")
    u:setdata("千咲连携时间", zttime + lianxietime)
  end,
  ["SW-斜"] = function(u)
    local skillstr = "SW"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    if u:getdata("千咲连携") == "EER" then
      u:setdata("千咲-电锯模式时间", 0)
      if u:islocal() then
        ClearSelection()
        u:select()
        u:setskilldatastring("A0NW", "图标", "Qx_E" .. u:getdata("系统-图标后缀"))
        u:setskilldatastring("A0OD", "图标", "Qx_E" .. u:getdata("系统-图标后缀"))
        u:setskilldatastring("A0O5", "图标", "Qx_R" .. u:getdata("系统-图标后缀"))
        u:setskilldatastring("A0NX", "图标", "Qx_R" .. u:getdata("系统-图标后缀"))
      end
    end
    local x, y = u:getxy()
    local jd = u:getface()
    local gd = u:getdata("千咲-浮空高度")
    local zttime = 0
    local lianxietime = 0.8
    u:setdata("千咲连携", "")
    zhiguizantingtime(u, zttime, skillstr)
    wudisrtrtime(u, zttime + 0.2, skillstr)
    u:buffset(u.handle, 0.15, "绝对闪避")
    local h = 400 - u:getdata("千咲-浮空高度")
    local g = CreateGroupLua()
    ac.wait(1, function()
      u:animeact(1)
      u:animespeed(1.5)
    end)
    ac.wait(0, function()
      local dx, dy = u:getxy()
      qianxiao_fukong(u, h, 0.1)
      Qianxiao_Move(u, 0.7, 100, jd)
      Qianxiao_Move(u, 0.2, 600, jd)
      Qianxiao_sound(u, Sound_Qianxiao_Q)
      dx, dy = PolarXY(x, y, 100, jd + 90)
      local tx = EffectcreateArgs({
        effect = "Qx\\qianxiao_tuowei1.mdx",
        x = dx,
        y = dy,
        time = 0.5,
        size = 1,
        height = gd + 50,
        zxz = jd,
        animespeed = 2
      })
      EffectcreateArgs({
        effect = "Qx\\qianxiao_shandian1.mdx",
        x = dx,
        y = dy,
        size = 10,
        height = gd - 400,
        zxz = jd,
        animespeed = 1.5
      })
      ac.wait(100, function()
        local x1, y1 = PolarXY(x, y, 600, jd)
        japi.EXSetEffectXY(tx, x1, y1)
        SetEffectHeight(tx, 400)
      end)
      local ax, ay = u:getxy()
      for _, xq in ac.selector():in_rangexy(ax, ay, 350):is_enemy(u.handle):isnotingroup(g):ipairs() do
        xq = getunit(xq)
        xq:groupadd(g)
        Qianxiao_Damage({
          u = u,
          tg = xq,
          damage = txsh,
          isqf = true,
          skillstr = skillstr,
          extrafunc = function(xq, sh)
            local dh = 400 - xq:getdata("千咲-浮空高度")
            if dh <= 50 then
              dh = 50
            end
            qianxiao_fukong_tg(u, xq, dh, 0.3)
            unitmove({
              unit = xq.handle,
              time = 0.1,
              distance = 25,
              angle = jd,
              isblink = true
            })
          end
        })
      end
      local cs = 0
      ac.loop(50, function(timer)
        cs = cs + 1
        local ax, ay = u:getxy()
        for _, xq in ac.selector():in_rangexy(ax, ay, 350):is_enemy(u.handle):isnotingroup(g):ipairs() do
          xq = getunit(xq)
          xq:groupadd(g)
          Qianxiao_Damage({
            u = u,
            tg = xq,
            damage = txsh,
            isqf = true,
            skillstr = skillstr,
            extrafunc = function(xq, sh)
              local dh = 400 - xq:getdata("千咲-浮空高度")
              if dh <= 50 then
                dh = 50
              end
              qianxiao_fukong_tg(u, xq, dh, 0.3)
              unitmove({
                unit = xq.handle,
                time = 0.1,
                distance = 25,
                angle = jd,
                isblink = true
              })
            end
          })
        end
        if 4 <= cs then
          timer:remove()
        end
      end)
    end)
    u:setdata("千咲连携", "SW")
    u:setdata("千咲连携时间", zttime + lianxietime)
  end,
  ["SQ-斜"] = function(u)
    local skillstr = "SQ"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    if u:getdata("千咲连携") == "EER" then
      u:setdata("千咲-电锯模式时间", 0)
      if u:islocal() then
        ClearSelection()
        u:select()
        u:setskilldatastring("A0NW", "图标", "Qx_E" .. u:getdata("系统-图标后缀"))
        u:setskilldatastring("A0OD", "图标", "Qx_E" .. u:getdata("系统-图标后缀"))
        u:setskilldatastring("A0O5", "图标", "Qx_R" .. u:getdata("系统-图标后缀"))
        u:setskilldatastring("A0NX", "图标", "Qx_R" .. u:getdata("系统-图标后缀"))
      end
    end
    local x, y = u:getxy()
    local jd = u:getface() + 180
    local gd = u:getdata("千咲-浮空高度")
    local zttime = 0
    local lianxietime = 0.8
    u:setdata("千咲连携", "")
    zhiguizantingtime(u, zttime, skillstr)
    wudisrtrtime(u, zttime + 0.2, skillstr)
    u:buffset(u.handle, 0.15, "绝对闪避")
    local h = 400 - u:getdata("千咲-浮空高度")
    local g = CreateGroupLua()
    ac.wait(1, function()
      u:animeact(1)
      u:animespeed(1.5)
    end)
    ac.wait(0, function()
      local dx, dy = u:getxy()
      qianxiao_fukong(u, h, 0.1)
      Qianxiao_Move(u, 0.7, 100, jd)
      Qianxiao_Move(u, 0.2, 600, jd)
      Qianxiao_sound(u, Sound_Qianxiao_Q)
      dx, dy = PolarXY(x, y, 100, jd + 90)
      local tx = EffectcreateArgs({
        effect = "Qx\\qianxiao_tuowei1.mdx",
        x = dx,
        y = dy,
        time = 0.5,
        size = 1,
        height = gd + 50,
        zxz = jd,
        animespeed = 2
      })
      EffectcreateArgs({
        effect = "Qx\\qianxiao_shandian1.mdx",
        x = dx,
        y = dy,
        size = 10,
        height = gd - 400,
        zxz = jd,
        animespeed = 1.5
      })
      ac.wait(100, function()
        local x1, y1 = PolarXY(x, y, 600, jd)
        japi.EXSetEffectXY(tx, x1, y1)
        SetEffectHeight(tx, 400)
      end)
      local ax, ay = u:getxy()
      for _, xq in ac.selector():in_rangexy(ax, ay, 350):is_enemy(u.handle):isnotingroup(g):ipairs() do
        xq = getunit(xq)
        xq:groupadd(g)
        Qianxiao_Damage({
          u = u,
          tg = xq,
          damage = txsh,
          isqf = true,
          skillstr = skillstr,
          extrafunc = function(xq, sh)
            local dh = 400 - xq:getdata("千咲-浮空高度")
            if dh <= 50 then
              dh = 50
            end
            qianxiao_fukong_tg(u, xq, dh, 0.3)
            unitmove({
              unit = xq.handle,
              time = 0.1,
              distance = 25,
              angle = jd,
              isblink = true
            })
          end
        })
      end
      local cs = 0
      ac.loop(50, function(timer)
        cs = cs + 1
        local ax, ay = u:getxy()
        for _, xq in ac.selector():in_rangexy(ax, ay, 350):is_enemy(u.handle):isnotingroup(g):ipairs() do
          xq = getunit(xq)
          xq:groupadd(g)
          Qianxiao_Damage({
            u = u,
            tg = xq,
            damage = txsh,
            isqf = true,
            skillstr = skillstr,
            extrafunc = function(xq, sh)
              local dh = 400 - xq:getdata("千咲-浮空高度")
              if dh <= 50 then
                dh = 50
              end
              qianxiao_fukong_tg(u, xq, dh, 0.3)
              unitmove({
                unit = xq.handle,
                time = 0.1,
                distance = 25,
                angle = jd,
                isblink = true
              })
            end
          })
        end
        if 4 <= cs then
          timer:remove()
        end
      end)
    end)
    u:setdata("千咲连携", "SW")
    u:setdata("千咲连携时间", zttime + lianxietime)
  end,
  F = function(u)
    local skillstr = "F"
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    local h = u:getdata("千咲-浮空高度")
    local zttime = 0.1
    local lianxietime = 0.8
    u:setdata("千咲连携", "")
    zhiguizantingtime(u, zttime, skillstr)
    wudisrtrtime(u, zttime + 0.2, skillstr)
    if u:hasdata("千咲天赋-无解的命途") then
      u:setdata("千咲-空中闪避次数", 0)
      u:setdata("千咲-空中重击次数", 0)
      u:setdata("千咲-空中剪刀次数", 0)
      u:setdata("千咲-空中普攻次数", 0)
    end
    local jxz = u:getdata("千咲-解弦单位组")
    for index, value in ipairs(zsz) do
      u:deldata("千咲-解弦标记" .. value)
    end
    ForGroupLuaNew(jxz, function(xq)
      for index, value in ipairs(zsz) do
        xq:deldata("千咲-解弦标记" .. value)
      end
    end)
    ac.wait(1, function()
      u:animeact(12)
      u:animespeed(1)
    end)
    ac.wait(0, function()
      Qianxiao_sound(u, Sound_Qianxiao_Saomiao)
      ac.wait(0, function()
        local yxz = {}
        if u:hasdata("千咲-日配") then
          yxz = {
            Sound_Qianxiao_yuyin_D1_Jp,
            Sound_Qianxiao_yuyin_D2_Jp,
            Sound_Qianxiao_yuyin_D3_Jp,
            Sound_Qianxiao_yuyin_D4_Jp,
            Sound_Qianxiao_yuyin_D5_Jp
          }
        else
          yxz = {
            Sound_Qianxiao_yuyin_D1,
            Sound_Qianxiao_yuyin_D2,
            Sound_Qianxiao_yuyin_D3,
            Sound_Qianxiao_yuyin_D4,
            Sound_Qianxiao_yuyin_D5
          }
        end
        Qianxiao_sound(u, yxz[GetRandomInt(1, #yxz)])
      end)
      Qianxiao_Move(u, 0.1, 100, jd + 180)
      Qianxiao_Move(u, 1, 100, jd + 180)
      if 0 < h then
        qianxiao_fukong(u, 25, 0.4)
      end
      EffectcreateArgs({
        effect = "Qx\\qianxiao_kuosan1.mdx",
        x = x,
        y = y,
        time = 0.2,
        size = 5,
        height = 1,
        zxz = jd,
        animespeed = 2
      })
      for i = 1, 2 do
        EffectcreateArgs({
          effect = "Qx\\qianxiao_shandian1.mdx",
          x = x,
          y = y,
          size = 20,
          height = -850 + h,
          zxz = jd + 90,
          animespeed = 1.5
        })
        EffectcreateArgs({
          effect = "Qx\\qianxiao_baozha5.mdx",
          x = x,
          y = y,
          size = 20,
          height = -200,
          zxz = jd + 90,
          animespeed = 2
        })
      end
      ac.wait(0, function()
        local tx = EffectcreateArgs({
          effect = "war3mapImported\\heiquan.mdx",
          x = x,
          y = y,
          time = 2.4,
          size = 6,
          height = -14,
          zxz = jd,
          animespeed = 3.0
        })
        ac.wait(100, function()
          japi.EXSetEffectSpeed(tx, 0.0)
        end)
        ac.wait(300, function()
          japi.EXSetEffectSpeed(tx, 1.5)
        end)
      end)
      Qianxiao_Damage({
        u = u,
        mx = x,
        my = y,
        fw = 1800,
        damage = txsh,
        isnotxh = true,
        isqf = true,
        skillstr = skillstr,
        extrafunc = function(xq, sh)
          xq:groupadd(jxz)
          if not xq:hasdata("千咲-解弦标记特效") then
            xq:setdata("千咲-解弦标记特效", xq:effectadd("Qx\\Qianxiao_Biaoji.mdx", "overhead", -1))
            if u:hasdata("千咲天赋-无解的命途") then
              xq:changearmor(-36)
              xq:changedata("怪物-额外受伤", 0.36)
            else
              xq:changearmor(-18)
              xq:changedata("怪物-额外受伤", 0.18)
            end
          end
          xq:setdata("千咲-解弦标记时间", 30)
          xq:buffset(u.handle, 2, "暂停")
          if xq:getdata("千咲-浮空高度") > 0 then
            qianxiao_fukong(xq, 0, 0.3)
          end
        end
      })
    end)
    u:setdata("千咲连携", "F")
    u:setdata("千咲连携时间", zttime + lianxietime)
  end,
  V = function(u)
    local skillstr = "V"
    local sy = u.ownerid
    local txsh = Qianxiao_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local x2 = u:getdata("千咲-超杀X")
    local y2 = u:getdata("千咲-超杀Y")
    local jd = AngleXY(x, y, x2, y2)
    local dis = DistanceXY(x, y, x2, y2)
    if 1500 <= dis then
      x2, y2 = PolarXY(x, y, 1500, jd)
    end
    u:setcamera(x2, y2, 0.1)
    local h = u:getdata("千咲-浮空高度")
    local zttime = 3.4
    local lianxietime = 0.8
    u:setdata("千咲连携", "")
    zhiguizantingtime(u, zttime, skillstr)
    wudisrtrtime(u, zttime + 0.5, skillstr)
    u:buffset(u.handle, zttime, "永恒")
    u:buffset(u.handle, zttime + 0.5, "绝对闪避")
    local fkbl = 1
    if u:hasdata("千咲天赋-第五象限") then
      fkbl = 1 + 0.0075 * u:getdata("千咲-连击数")
      u:setdata("千咲-连击数", 0)
    end
    if 0 < h then
      qianxiao_fukong(u, -u:getdata("千咲-浮空高度"), 0.8)
    end
    if u:hasdata("千咲天赋-第五象限") or u:hasdata("千咲天赋-拖拽终焉之弦") or u:hasdata("千咲天赋-万理归尘") then
      local qxphoto = class.panel:builder({
        parent = OriginPanel,
        x = 0,
        y = 0,
        w = 1920,
        h = 850,
        normal_image = "Touming.tga"
      })
      local c = 0
      ac.loop(37, function(timer)
        if c < 27 then
          c = c + 1
          qxphoto:set_normal_image("QX\\Ph_Qx_Bisha (" .. c .. ").tga")
        else
          qxphoto:destroy()
          timer:remove()
        end
      end)
    end
    ac.wait(1, function()
      u:animeact(14)
      u:animespeed(5)
    end)
    ac.wait(100, function()
      u:animespeed(2)
    end)
    local g = CreateGroupLua()
    ac.wait(0, function()
      Qianxiao_sound(u, Sound_Qianxiao_Dazhao)
      ac.wait(0, function()
        local yxz = {}
        if u:hasdata("千咲-日配") then
          yxz = {
            Sound_Qianxiao_yuyin_R1_Jp,
            Sound_Qianxiao_yuyin_R2_Jp,
            Sound_Qianxiao_yuyin_R3_Jp
          }
        else
          yxz = {
            Sound_Qianxiao_yuyin_R1,
            Sound_Qianxiao_yuyin_R2,
            Sound_Qianxiao_yuyin_R3
          }
        end
        Qianxiao_sound(u, yxz[GetRandomInt(1, #yxz)])
      end)
      EffectcreateArgs({
        effect = "Qx\\qianxiao_kuosan1.mdx",
        x = x,
        y = y,
        time = 0.2,
        size = 5,
        height = 1,
        zxz = jd,
        animespeed = 2
      })
      for i = 1, 2 do
        EffectcreateArgs({
          effect = "Qx\\qianxiao_shandian1.mdx",
          x = x,
          y = y,
          size = 20,
          height = -850,
          zxz = jd + 90,
          animespeed = 1.5
        })
        EffectcreateArgs({
          effect = "Qx\\qianxiao_baozha5.mdx",
          x = x,
          y = y,
          size = 20,
          height = -200,
          zxz = jd + 90,
          animespeed = 2
        })
      end
      ac.wait(0, function()
        local dx, dy = x2, y2
        local tx1 = EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang1.mdx",
          x = dx,
          y = dy,
          time = 1.5,
          size = 400,
          height = 0,
          zxz = 180,
          animespeed = 1
        })
        if type(japi.EXSetEffectFogVisible) == "function" then
          japi.EXSetEffectFogVisible(tx1, true)
        end
        if type(japi.EXSetEffectMaskVisible) == "function" then
          japi.EXSetEffectMaskVisible(tx1, true)
        end
        ac.wait(100, function()
          japi.EXSetEffectSpeed(tx1, 0.05)
        end)
        ac.wait(1400, function()
          japi.EXSetEffectSpeed(tx1, 20)
        end)
        for _, xq in ac.selector():in_rangexy(x2, y2, 1800):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          xq:groupadd(g)
          xq:buffset(xq.handle, 5, "暂停")
          if xq:isboss() then
            xq:buffset(xq.handle, 5, "沉默")
          end
        end
      end)
      ac.wait(1000, function()
        u:setflyheight(400)
        u:setface(jd)
        local x1, y1 = PolarXY(x2, y2, -700, jd)
        u:setxy(x1, y1)
        Qianxiao_Move(u, 1, 300, jd)
        local ajd = GetRandomAngle()
        local ajd1 = GetRandomAngle()
        local dis = 1000
        local dis1 = 2000
        local ddis = dis / 40
        local ddis1 = dis1 / 40
        local bx, by = x2, y2
        ac.loop(30, function(timer)
          bx, by = u:getxy()
          ajd = ajd + 9
          ajd1 = ajd1 - 9
          dis = dis - ddis
          dis1 = dis1 - ddis1
          for i = 1, 5 do
            ajd = ajd + 72.0
            local ax, ay = PolarXY(bx, by, dis, ajd)
            EffectcreateArgs({
              effect = "Qx\\qianxiao_hjjxzx.mdx",
              x = ax,
              y = ay,
              time = 0,
              size = 0.1 + dis / 200,
              height = dis,
              zxz = ajd,
              animespeed = 2
            })
            if u:hasdata("千咲天赋-第五象限") then
              local tx = EffectcreateArgs({
                effect = "Qx\\qianxiao_aoyihuanrao.mdx",
                x = ax,
                y = ay,
                time = 0.3,
                size = 0.1 + dis / 200,
                height = dis,
                zxz = ajd,
                animespeed = 2
              })
              ac.wait(300, function()
                japi.EXSetEffectSpeed(tx, 100)
              end)
            end
          end
          if u:hasdata("千咲天赋-拖拽终焉之弦") then
            for i = 1, 5 do
              ajd1 = ajd1 + 72.0
              local ax1, ay1 = PolarXY(bx, by, dis1, ajd1)
              EffectcreateArgs({
                effect = "Qx\\qianxiao_daoguang1.mdx",
                x = ax1,
                y = ay1,
                time = 0.3,
                size = 0.1 + dis / 200,
                height = dis * 2,
                zxz = ajd1 + 45,
                animespeed = 10
              })
            end
          end
          if dis <= ddis then
            timer:remove()
          end
        end)
      end)
      ac.wait(2000, function()
        u:setface(jd)
        u:shockcamera(300, 0.1)
        u:setflyheight(0)
        u:animespeed(10)
        ac.wait(100, function()
          u:animespeed(1)
        end)
        ac.wait(0, function()
          unitmove({
            unit = u.handle,
            time = 0.1,
            distance = 1000,
            angle = jd,
            isblink = true,
            endfunc = function(dx, dy)
              u:setdata("位移点X", dx)
              u:setdata("位移点Y", dy)
            end
          })
        end)
        ac.wait(10, function()
          local ax, ay = PolarXY(x2, y2, 175, jd + 90)
          ax, ay = PolarXY(ax, ay, 0, jd)
          for i = 1, 2 do
            local tx = EffectcreateArgs({
              effect = "Qx\\qianxiao_daoguang11.mdx",
              x = ax,
              y = ay,
              size = 16,
              height = 300,
              zxz = jd + 270,
              xxz = -200,
              yxz = 310,
              animespeed = 0.9
            })
          end
        end)
        EffectcreateArgs({
          effect = "Qx\\qianxiao_kuosan1.mdx",
          x = x2,
          y = y2,
          time = 0.2,
          size = 5,
          height = 1,
          zxz = jd,
          animespeed = 2
        })
        for i = 1, 2 do
          EffectcreateArgs({
            effect = "Qx\\qianxiao_shandian1.mdx",
            x = x2,
            y = y2,
            size = 20,
            height = -850,
            zxz = jd + 90,
            animespeed = 1.5
          })
          EffectcreateArgs({
            effect = "Qx\\qianxiao_baozha5.mdx",
            x = x2,
            y = y2,
            size = 20,
            height = -200,
            zxz = jd + 90,
            animespeed = 2
          })
        end
        local ax, ay = x2, y2
        local dx, dy = PolarXY(ax, ay, -200, jd)
        EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang4.mdx",
          x = dx,
          y = dy,
          size = 10,
          height = 450,
          zxz = jd + 180,
          yxz = -50,
          animespeed = 1
        })
        dx, dy = PolarXY(ax, ay, 525, jd)
        EffectcreateArgs({
          effect = "Qx\\qianxiao_daoguang3.mdx",
          x = dx,
          y = dy,
          size = 4,
          height = 0,
          zxz = jd,
          yxz = 50,
          animespeed = 2
        })
        dx, dy = PolarXY(ax, ay, 400, jd)
        EffectcreateArgs({
          effect = "Qx\\qianxiao_baozha5.mdx",
          x = dx,
          y = dy,
          size = 10,
          height = 0,
          zxz = jd + 180,
          animespeed = 2
        })
        for i = 1, 2 do
          EffectcreateArgs({
            effect = "Qx\\qianxiao_shandian1.mdx",
            x = dx,
            y = dy,
            size = 10,
            height = -450,
            zxz = jd + 90,
            animespeed = 0.5
          })
          EffectcreateArgs({
            effect = "Qx\\qianxiao_baozha5.mdx",
            x = dx,
            y = dy,
            size = 4,
            height = -100,
            zxz = jd + 90,
            animespeed = 2
          })
        end
        EffectcreateArgs({
          effect = "war3mapImported\\Daji_Hong1.mdx",
          x = x2,
          y = y2,
          size = 40,
          zxz = jd,
          animespeed = 2.0
        })
        local tx = EffectcreateArgs({
          effect = "Qx\\qianxiao_sjd.mdx",
          x = x2,
          y = y2,
          time = 1,
          size = 5,
          height = 200,
          zxz = 0,
          animespeed = 1
        })
        ac.wait(200, function()
          japi.EXSetEffectSpeed(tx, 3)
        end)
        ac.wait(700, function()
          japi.EXSetEffectSpeed(tx, 4)
        end)
        local cs1 = 0
        ac.loop(100, function(t)
          cs1 = cs1 + 1
          EffectcreateArgs({
            effect = "Qx\\qianxiao_baozha10.mdx",
            x = x2,
            y = y2,
            time = 0.2,
            size = 0.1,
            height = 550,
            zxz = jd,
            animespeed = 2
          })
          if 6 <= cs1 then
            t:remove()
          end
        end)
      end)
      ac.wait(3000, function()
        CinematicFadeBJ(bj_CINEFADETYPE_FADEOUTIN, 1, "ReplaceableTextures\\CameraMasks\\DreamFilter_Mask.blp", 100.0, 0.0, 0.0, 0.0)
        for i = 1, 2 do
          EffectcreateArgs({
            effect = "Qx\\qianxiao_baozha10.mdx",
            x = x2,
            y = y2,
            time = 0.2,
            size = 10,
            height = 600,
            zxz = jd,
            animespeed = 2
          })
        end
        local cs1 = 0
        ac.loop(100, function(t)
          cs1 = cs1 + 1
          EffectcreateArgs({
            effect = "Qx\\qianxiao_kuosan1.mdx",
            x = x2,
            y = y2,
            size = 0.1 + cs1,
            height = 1,
            zxz = jd,
            animespeed = 0.5
          })
          if cs1 == 1 then
            local time = 15
            local bfb = 0.12
            local xs = 1
            if u:hasdata("千咲天赋-万理归尘") then
              bfb = bfb * 1.5
              xs = xs * 2
            end
            if 2.5 <= fkbl then
              bfb = bfb * 2.5
            else
              bfb = bfb * fkbl
            end
            if u:hasdata("千咲天赋-拖拽终焉之弦") then
              time = time * 2
              u:sethp(100, true)
              Hero_Tili[sy] = Hero_Tili_Max[sy]
            else
              u:curehp(u.handle, 0, 50, 4)
              u:curetili(0.5 * Hero_Tili_Max[sy])
            end
            local add = 0.25 * u:getmaxhp()
            hdzlinshiadd(u, add)
            u:setdata("千咲-万缕汇终时间", time)
            local add = 0.2 * xs * DamageSystem_EndSh[sy]
            ChangeTimeValue(DamageSystem_EndSh, sy, 0.1 * add, time)
            local z = 100
            local dz = 10 / time
            ac.loop(100, function(timer)
              z = z - dz
              u:changedata("千咲-共鸣解放值", -dz)
              if u:getdata("千咲-共鸣解放值") < 0 then
                u:setdata("千咲-共鸣解放值", 0)
              end
              if z <= 0 then
                timer:remove()
              end
            end)
            if u:islocal() then
              BuffUI.apply({
                id = "千咲-万缕汇终"
              })
            end
            for _, xq in ac.selector():in_rangexy(x2, y2, 1800):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              xq:groupadd(g)
            end
            local bosskill = false
            ForGroupLuaNew(g, function(xq)
              if xq:isboss() then
                u:setdata("千咲-归无百分比伤害", bfb)
                ac.wait(300, function()
                  if not xq:isalive() or u:hasdata("千咲-归无斩杀判定") then
                    bosskill = true
                  end
                  u:deldata("千咲-归无斩杀判定")
                end)
              end
              DamageUnit({
                bj = "千咲(机体)",
                unit = xq.handle,
                source = u.handle,
                damage = txsh * xs * fkbl,
                level = 1,
                type = "物理",
                isvest = false,
                isattack = true,
                isnoarmor = false
              })
              local x1, y1 = xq:getxy()
              EffectcreateArgs({
                effect = "5dab9b48c482691b.mdl",
                x = x1,
                y = y1,
                size = 3,
                zxz = GetRandomAngle()
              })
            end)
            if u:hasdata("千咲天赋-第五象限") or u:hasdata("千咲天赋-拖拽终焉之弦") or u:hasdata("千咲天赋-万理归尘") then
              if GetRandom100(50) then
                PlayBGM({
                  bgm = BGM_Qianxiao_V1,
                  time = 75,
                  ID = 241,
                  unit = u.handle
                })
              else
                PlayBGM({
                  bgm = BGM_Qianxiao_V2,
                  time = 62,
                  ID = 242,
                  unit = u.handle
                })
              end
              ac.wait(500, function()
                if bosskill then
                  flashphoto({
                    photo = "Ph_Qianxiao_Zhansha.tga",
                    timeout = 3,
                    timehold = 1,
                    timein = 3
                  })
                  u:chat("|cFFEC2935我会,切开这个死局！")
                  if u:hasdata("千咲-日配") then
                    PlayGlobalSound(Sound_Qianxiao_Zhansha)
                  else
                    PlayGlobalSound(Sound_Qianxiao_Zhansha)
                  end
                  ForGroupLuaNew(Group_PlayHero, function(xq)
                    xq:buffset(u.handle, 7, "绝对闪避")
                  end)
                end
              end)
            end
          end
          if cs1 <= 3 then
            EffectcreateArgs({
              effect = "Qx\\qianxiao_baozha5.mdx",
              x = x2,
              y = y2,
              size = cs1 * 10,
              height = -300,
              zxz = GetRandomAngle(),
              animespeed = 4
            })
          end
          if 6 <= cs1 then
            t:remove()
          end
        end)
        u:shockcamera(300, 0.1)
      end)
    end)
    u:setdata("千咲连携", "V")
    u:setdata("千咲连携时间", zttime + lianxietime)
  end
}
return zgskill
