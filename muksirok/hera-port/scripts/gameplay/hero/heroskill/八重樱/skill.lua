-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local message = require("jass.message")
local slk = require("jass.slk")
local sound_bcy_yqc = {
  Sound_BCY_0__1_u,
  Sound_BCY_0__2_u,
  Sound_BCY_0__3_u,
  Sound_BCY_0__4_u,
  Sound_BCY_0__5_u,
  Sound_BCY_0__6_u,
  Sound_BCY_0__7_u,
  Sound_BCY_0__8_u,
  Sound_BCY_0__9_u,
  Sound_BCY_0__10_u,
  Sound_BCY_0__11_u,
  Sound_BCY_0__12_u,
  Sound_BCY_0__13_u,
  Sound_BCY_0__14_u
}
sound_bcy_yqc[20] = Sound_BCY_20
sound_bcy_yqc[21] = Sound_BCY_21
sound_bcy_yqc[22] = Sound_BCY_22
sound_bcy_yqc[23] = Sound_BCY_23
sound_bcy_yqc[24] = Sound_BCY_24
sound_bcy_yqc[25] = Sound_BCY_25
sound_bcy_yqc[26] = Sound_BCY_26

local function bcybdqdadd(u, bdqd, mz, skillstr)
  if not mz then
    if u:hasdata("八重樱-樱华幻刃") then
      if skillstr ~= "CQ" then
        bdqd = bdqd * 0.1
      end
    else
      bdqd = 0
    end
  end
  if 0 < bdqd then
    if u:hasdata("八重樱-居相道") then
      bdqd = bdqd * 1.25
    end
    if u:hasdata("八重樱-极刃空樱") and BossBattle then
      bdqd = bdqd * 1.5
    end
    if u:hasdata("八重樱-红莲业火斩杀累积") then
      bdqd = bdqd * (1 + u:getdata("八重樱-红莲业火斩杀累积"))
    end
    u:changedata("八重樱-拔刀强度", bdqd)
    u:setdata("八重樱-拔刀时间", u:getdata("八重樱-拔刀时间上限"))
  end
end

local function BcyDamage(args)
  local u = args.u
  local xq = args.tg
  local txsh = args.damage
  local isvest = args.isvest or false
  local string = args.string or ""
  local sx = args.sx or "无"
  local damagelevel = args.damagelevel or 1
  local fyxs = 1 + u:getdata("八重樱-绯樱系数") * xq:getdata("八重樱-绯樱层数")
  if string == "CVVAQR" then
    u:setdata("八重樱-寒天狂舞固伤")
  end
  if string == "R-Cyz" then
    u:setdata("八重樱-寒天狂舞次元斩固伤")
  end
  DamageUnit({
    bj = "八重樱(机体)",
    unit = xq.handle,
    source = u.handle,
    damage = txsh,
    level = damagelevel,
    type = "物理",
    isvest = isvest,
    isattack = true,
    isnoarmor = false,
    element = sx,
    extradata = {
      "八重樱-真红限伤"
    }
  })
  if string == "CVVAQR" then
    u:deldata("八重樱-寒天狂舞固伤")
  end
  if string == "R-Cyz" then
    u:deldata("八重樱-寒天狂舞次元斩固伤")
  end
  if not isvest then
    if u:hasdata("八重樱-兜穿") and xq:isboss() then
      LossHpUnit({
        u = u,
        tg = xq,
        perhp = 0.1,
        bj = "八重樱(兜穿损耗)"
      })
    end
    if xq:getdata("八重樱-绯樱层数") < u:getdata("八重樱-绯樱层数上限") then
      xq:changetimedata("八重樱-绯樱层数", 1, 8)
      xq:groupadd(u:getdata("八重樱-绯樱单位组"))
    end
  end
  if string == "CVCACW" and xq:isboss() then
    LossHpUnit({
      u = u,
      tg = xq,
      perhp = 1,
      bj = "八重樱(红莲业火损耗)"
    })
  end
  if string == "E" and u:hasdata("八重樱-拔刀斩火山强化") then
    local t = u:getdata("八重樱-拔刀斩蓄力时间")
    local txsh3 = t * 6000 * fyxs
    DamageUnit({
      bj = "八重樱(侵略如火)",
      unit = xq.handle,
      source = u.handle,
      damage = txsh3,
      level = 5,
      type = "物理",
      isvest = false,
      isattack = false,
      isnoarmor = false,
      element = "无",
      extradata = {
        "八重樱-真红限伤"
      }
    })
    if xq:isboss() then
      local bdqd = u:getdata("八重樱-蓄力拔刀强度")
      if 10 <= bdqd then
        local sunhao = 0.5 * bdqd
        if 25 <= sunhao then
          sunhao = 25
        end
        LossHpUnit({
          u = u,
          tg = xq,
          maxhp = sunhao,
          bj = "八重樱(拔刀斩损耗)"
        })
      end
    end
  end
  if string == "VR" and u:hasdata("八重樱-侵略如火不动如山") then
    local bdqd = u:getdata("八重樱-蓄力拔刀强度")
    local txsh3 = bdqd * 4500 * fyxs
    DamageUnit({
      bj = "八重樱(侵略如火)",
      unit = xq.handle,
      source = u.handle,
      damage = txsh3,
      level = 5,
      type = "物理",
      isvest = true,
      isattack = false,
      isnoarmor = false,
      element = "无",
      extradata = {
        "八重樱-真红限伤"
      }
    })
  end
  if string == "CR" and u:hasdata("八重樱-侵略如火不动如山") then
    local bdqd = u:getdata("八重樱-蓄力拔刀强度")
    local txsh3 = bdqd * 7500 * fyxs
    DamageUnit({
      bj = "八重樱(侵略如火)",
      unit = xq.handle,
      source = u.handle,
      damage = txsh3,
      level = 5,
      type = "物理",
      isvest = true,
      isattack = false,
      isnoarmor = false,
      element = "无",
      extradata = {
        "八重樱-真红限伤"
      }
    })
  end
  if (string == "CA" or string == "CAC") and u:hasdata("八重樱-侵略如火不动如山") then
    DamageUnit({
      bj = "八重樱(侵略如火)",
      unit = xq.handle,
      source = u.handle,
      damage = txsh,
      level = 1,
      type = "物理",
      isvest = true,
      isattack = false,
      isnoarmor = false,
      element = "无",
      extradata = {
        "八重樱-真红限伤"
      }
    })
  end
end

local function Srtr_Shanghaijisuan(u, skillstr)
  local txsh = u:getdata("角色基础伤害")
  local str = skillstr
  if str ~= "CVVAQR" and str ~= "CVCACW" and str ~= "E" and str ~= "VR" and str ~= "CR" then
    local bdqd = u:getdata("八重樱-拔刀强度")
    txsh = txsh * (1 + 0.1 * (bdqd - 1))
  end
  if str == "CA" or str == "CAC" then
    txsh = txsh * 0.25
  end
  if str == "VQV" or str == "CQ" or str == "VW" or str == "R" or str == "A" or str == "F" then
    txsh = txsh * 1.5
  end
  if str == "CW" then
    txsh = txsh * 1.75
  end
  if str == "VA" then
    txsh = txsh * 2
  end
  if str == "CF" then
    txsh = txsh * 0.2
  end
  if str == "VF" then
    txsh = txsh * 2.5
  end
  return txsh
end

local function bcyzanting(u, time)
  if not u:hasdata("八重樱-红莲业火强化") then
    u:buffset(u.handle, time, "暂停")
  end
end

local function bcyqkbd(u)
  if not u:hasdata("八重樱-红莲业火强化") then
    u:setdata("八重樱-拔刀强度", 1)
  end
end

local zgskill
zgskill = {
  Q = function(u)
    local skillstr = "Q"
    local txsh = Srtr_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    unitmove({
      unit = u.handle,
      time = 0.2,
      distance = 350,
      angle = jd + 180,
      startfunc = function()
        u:animespeed(2)
        ac.wait(1, function()
          u:animeact(10)
        end)
        if u:getdata("绝对闪避时间") == 0 then
          u:setdata("刷新Q时间", 0.2)
        end
        movexg(u.handle, 0.2, "A19F", "Q", "八重樱-Q")
        Effectcreate("ATX\\[ATxNew]Dust_20.mdx", x, y, 0.8, 1, 0, jd + 180)
        Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
        Effectcreate("ATx\\[ATxNew]Black_01.mdl", x, y)
      end,
      endfunc = function()
        u:animespeed(1)
        IssueImmediateOrder(u.handle, "stop")
        local x, y = u:getxy()
        Effectcreate("war3mapImported\\bbb.mdx", x, y)
        u:setdata("位移点X", x)
        u:setdata("位移点Y", y)
      end
    })
  end,
  VQ = function(u)
    local skillstr = "VQ"
    local txsh = Srtr_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    bcybdqdadd(u, 0.05, false, skillstr)
    u:deldata("八重樱-山林符")
    Effectcreate("ATX\\[ATxNew]Dust_20.mdx", x, y, 0.8, 1, 0, jd + 180)
    Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
    Effectcreate("ATx\\[ATxNew]Black_01.mdl", x, y)
    u:playsound(Sound_Katana_20)
    local t1, t2
    if u:hasdata("八重樱-疾如风徐如林") then
      t1 = 0.2
      t2 = 0.5
    else
      t1 = 0.25
      t2 = 0.4
    end
    bcyzanting(u, t1)
    u:settimedata("八重樱-虚影步", t1 + 0.5)
    movexg(u.handle, t2, "A19F", "Q", "八重樱-Q")
    u:setskillcd("A19F", t1 - 0.05)
    ac.wait(1, function()
      ResetUnitAnimation(u.handle)
      u:animeact(10)
      u:animespeed(2)
    end)
    unitmove({
      unit = u.handle,
      time = 0.2,
      distance = 500,
      angle = jd + 180,
      isfly = true,
      endfunc = function(dx, dy)
        u:animespeed(1)
      end
    })
    play_shadow_slow_series(u, {
      act = 10,
      count = 5,
      interval = 0.02,
      main_speed = 4,
      wait_time = 0.04,
      r = 0,
      g = 0,
      b = 255,
      show_alpha = 125,
      fade_sub = 5,
      noact = true
    })
  end,
  VQV = function(u)
    local skillstr = "VQV"
    local txsh = Srtr_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    u:deldata("八重樱-虚影步")
    Effectcreate("ATX\\[ATxNew]Dust_20.mdx", x, y, 0.8, 1, 0, jd + 180)
    Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
    Effectcreate("ATx\\[ATxNew]Black_01.mdl", x, y)
    u:playsound(Sound_Katana_20)
    bcyzanting(u, 0.25)
    movexg(u.handle, 0.25, "A19F", "Q", "八重樱-Q")
    ac.wait(1, function()
      u:reanimeact()
      u:animeact(10)
      u:animespeed(2)
    end)
    unitmove({
      unit = u.handle,
      time = 0.3,
      distance = 500,
      angle = jd + 180,
      isfly = true,
      endfunc = function(dx, dy)
        u:animespeed(1)
      end
    })
    play_shadow_slow_series(u, {
      act = 10,
      count = 5,
      interval = 0.02,
      main_speed = 4,
      wait_time = 0.04,
      r = 0,
      g = 0,
      b = 255,
      show_alpha = 125,
      fade_sub = 5,
      noact = true
    })
  end,
  CQ = function(u)
    local skillstr = "CQ"
    local txsh = Srtr_Shanghaijisuan(u, skillstr)
    u:deldata("八重樱-风火符")
    u:buffset(u.handle, 0.2, "绝对闪避")
    u:settimedata("八重樱-瞬身闪", 0.75)
  end,
  ["CQ-Act"] = function(u, dis)
    local skillstr = "CQ"
    local txsh = Srtr_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local angle = u:getface()
    local mz = false
    local bdqd = 0.2
    local mjl
    if u:hasdata("八重樱-疾如风徐如林") then
      mjl = 1500
    else
      mjl = 1000
    end
    if dis >= mjl then
      dis = mjl
    end
    u:playsound(sound_bcy_yqc[GetRandomInt(1, 14)])
    u:playsound(Sound_Katana_20)
    Effectcreate("war3mapImported\\bbb.mdl", x, y)
    Effectcreate("ATX\\[ATxNew]Black_01.mdx", x, y)
    Effectcreate("war3mapImported\\nitu.mdl", x, y, 0, 1, 0, angle)
    u:buffset(u.handle, 0.25, "绝对闪避")
    ac.wait(1, function()
      u:animeact(9)
      local g = CreateGroupLua()
      unitmove({
        unit = u.handle,
        time = 0.15,
        distance = dis,
        angle = angle,
        isfly = true,
        loops = {
          {
            looptime = 0.015,
            func = function(dx, dy)
              Effectcreate("war3mapImported\\[Murasame]01 (3).mdl", dx, dy, 0, GetRandomReal(0.8, 1.4), 0, GetRandomAngle())
              Effectcreate("war3mapImported\\blackblink.mdx", dx, dy, 0, GetRandomReal(0.8, 1.4), 0, GetRandomAngle())
              for _, xq in ac.selector():in_rangexy(dx, dy, 225):is_enemy(u.handle):isnotingroup(g):ipairs() do
                xq = getunit(xq)
                mz = true
                xq:groupadd(g)
                xq:buffset(u.handle, 0.5, "暂停")
                xq:animespeed(0)
              end
            end
          }
        },
        endfunc = function(dx, dy)
          if not u:hasdata("八重樱-CQ停止关闭") then
            u:setdata("位移点X", dx)
            u:setdata("位移点Y", dy)
            IssueImmediateOrder(u.handle, "stop")
            ac.wait(10, function()
              u:setface(angle)
            end)
          end
          u:animeact(6)
          u:playsound(Sound_Katana_17)
          ForGroupLuaNew(g, function(xq)
            xq:buffset(u.handle, 0.3, "暂停")
          end)
          ac.wait(250, function()
            u:playsound(Sound_Katana_02)
            u:playsound(Sound_Katana_18)
            local size = dis / 2200
            Effectcreate("war3mapImported\\[TxNew1]004.mdl", x, y, 0, size, 100, angle)
            ForGroupLuaNew(g, function(xq)
              xq:buffset(u.handle, 0.8, "眩晕")
              xq:animeact("death")
              xq:animespeed(1)
              BcyDamage({
                u = u,
                tg = xq,
                damage = txsh
              })
              xq:effectadd("AATX\\[AATxNew]Blood19.mdl", "chest")
              if not xq:hasdata("瞬身闪破坏抗性") then
                xq:effectadd("AATX\\[Sakura]08.mdl", "head", 5)
                xq:settimedata("瞬身闪破坏抗性", 5)
                xq:buffset(u.handle, 5, "破坏-伤害免疫")
              end
              if u:hasdata("八重樱-疾如风徐如林") and not xq:hasdata("瞬身闪降低护甲") then
                xq:settimedata("瞬身闪降低护甲", 10)
                xq:changetimearmor(-50, 10)
              end
            end)
          end)
          bcybdqdadd(u, bdqd, mz, skillstr)
          if u:hasdata("八重樱-云樱自在") and mz then
            u:curetili(1)
          end
        end
      })
    end)
  end,
  CVVAQ = function(u)
    local skillstr = "CVVAQ"
    local txsh = Srtr_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    bcybdqdadd(u, 0.1, false, skillstr)
    u:deldata("八重樱-寒天狂舞")
    u:settimedata("八重樱-寒天狂舞释放", 0.5)
    u:playsound(Sound_Katana_20)
    u:playsound(Sound_BCY_25)
    u:buffset(u.handle, 0.5, "绝对闪避")
    u:effectadd("AATX\\[AATxNew]Black32.mdl", "hand left")
    ac.wait(1, function()
      ResetUnitAnimation(u.handle)
      u:animeact(5)
      u:animespeed(3)
    end)
    unitmove({
      unit = u.handle,
      time = 0.2,
      distance = 250,
      angle = jd + 180,
      isfly = true,
      endfunc = function(dx, dy)
        u:animespeed(1)
      end
    })
    play_shadow_slow_series(u, {
      act = 5,
      count = 5,
      interval = 0.02,
      main_speed = 3,
      wait_time = 0.04,
      r = 0,
      g = 0,
      b = 255,
      show_alpha = 125,
      fade_sub = 5,
      noact = true
    })
  end,
  W = function(u)
    local skillstr = "W"
    local txsh = Srtr_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    unitmove({
      unit = u.handle,
      time = 0.2,
      distance = 450,
      angle = jd,
      startfunc = function()
        u:animespeed(1.8)
        ac.wait(1, function()
          u:animeact(9)
        end)
        if u:getdata("绝对闪避时间") == 0 then
          u:setdata("刷新W时间", 0.2)
        end
        movexg(u.handle, 0.2, "A19G", "W", "八重樱-W")
        Effectcreate("ATX\\[ATxNew]Dust_04.mdl", x, y, 0.5, 1, 0, jd)
        Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
        Effectcreate("ATx\\[ATxNew]Black_01.mdl", x, y)
        ac.wait(50, function()
          x, y = u:getxy()
          Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
          Effectcreate("ATx\\[ATxNew]Black_01.mdl", x, y)
        end)
      end,
      endfunc = function()
        u:animespeed(1)
        x, y = u:getxy()
        Effectcreate("war3mapImported\\bbb.mdx", x, y)
        u:setdata("位移点X", x)
        u:setdata("位移点Y", y)
      end
    })
  end,
  VW = function(u)
    local skillstr = "VW"
    local txsh = Srtr_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    u:deldata("八重樱-山林符")
    Effectcreate("ATX\\[ATxNew]Dust_04.mdl", x, y, 0, 0.5, 0, jd)
    u:playsound(sound_bcy_yqc[GetRandomInt(1, 14)])
    u:playsound(Sound_AA__61_u)
    u:effectadd("Abilities\\Weapons\\ZigguratMissile\\ZigguratMissile.mdl", "hand left", 0.15)
    u:effectadd("Abilities\\Weapons\\ZigguratMissile\\ZigguratMissile.mdl", "hand right", 0.15)
    ac.wait(1, function()
      u:animeact(9)
    end)
    local t1
    if u:hasdata("八重樱-疾如风徐如林") then
      t1 = 0.35
    else
      t1 = 0.25
    end
    u:buffset(u.handle, t1, "绝对闪避")
    local mz = false
    local g = CreateGroupLua()
    local cs = 0
    unitmove({
      unit = u.handle,
      time = 0.15,
      distance = 1000,
      angle = jd,
      isfly = true,
      loops = {
        {
          looptime = 0.015,
          func = function(dx, dy)
            cs = cs + 1
            if cs == 2 then
              cs = 0
              Effectcreate("war3mapImported\\specialanimedustwave.mdx", dx, dy, 0, 1, 0, GetRandomAngle())
              Effectcreate("war3mapImported\\blackblink.mdx", dx, dy, 0, 1, 0, GetRandomAngle())
            end
            for _, xq in ac.selector():in_rangexy(dx, dy, 200):is_enemy(u.handle):isnotingroup(g):ipairs() do
              xq = getunit(xq)
              mz = true
              xq:groupadd(g)
              xq:buffset(u.handle, 1, "眩晕")
              xq:animeact("death")
              BcyDamage({
                u = u,
                tg = xq,
                damage = txsh
              })
              xq:effectadd("ATX\\[ATxNew]Hit_02.mdl", "chest")
            end
          end
        }
      },
      endfunc = function(dx, dy)
        bcybdqdadd(u, 0.15, mz, skillstr)
        if u:hasdata("八重樱-云樱自在") and mz then
          u:curetili(1)
        end
        ResetUnitAnimation(u.handle)
        u:setdata("位移点X", dx)
        u:setdata("位移点Y", dy)
      end
    })
  end,
  CW = function(u)
    local skillstr = "CW"
    local txsh = Srtr_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    u:deldata("八重樱-风火符")
    ac.timer(100, 8, function()
      Effectcreate("war3mapImported\\[TX] (757).mdl", x, y, 0, 2, 0, GetRandomAngle())
    end)
    u:effectadd("war3mapImported\\[TX] (320).mdl")
    u:playsound(Sound_BCY_11)
    u:playsound(Sound_Katana_19)
    local t1
    if u:hasdata("八重樱-疾如风徐如林") then
      t1 = 0.4
      u:buffset(u.handle, 0.3, "绝对闪避")
    else
      t1 = 0.8
    end
    bcyzanting(u, t1)
    u:buffset(u.handle, t1, "无敌")
    ac.wait(1, function()
      u:animeact(4)
    end)
    ac.wait(200, function()
      u:animespeed(0)
    end)
    ac.wait(t1 * 1000, function()
      if not u:isalive() then
        return
      end
      u:buffset(u.handle, 0.3, "绝对闪避")
      Effectcreate("Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl", x, y, 0, 4)
      u:playsound(Sound_Katana_20)
      u:animeact(9)
      u:animespeed(1)
      local mz = false
      local g = CreateGroupLua()
      local cs = 0
      unitmove({
        unit = u.handle,
        time = 0.2,
        distance = 1500,
        angle = jd,
        isfly = true,
        loops = {
          {
            looptime = 0.02,
            func = function(dx, dy)
              cs = cs + 1
              if cs == 2 then
                cs = 0
                Effectcreate("war3mapImported\\[TX] (327).mdl", dx, dy, 0, 1, 0, GetRandomAngle())
                Effectcreate("ATX\\[ATxNew]ShockBoom_29.mdl", dx, dy, 0, 1, 0, GetRandomAngle())
              end
              for _, xq in ac.selector():in_rangexy(dx, dy, 275):is_enemy(u.handle):isnotingroup(g):ipairs() do
                mz = true
                xq = getunit(xq)
                xq:groupadd(g)
                xq:buffset(u.handle, 1, "眩晕")
                xq:animeact("death")
                BcyDamage({
                  u = u,
                  tg = xq,
                  damage = txsh
                })
                xq:groupadd(HpGroup)
                if not xq:hasdata("炎舞踏抑制恢复") then
                  xq:settimedata("炎舞踏抑制恢复", 5)
                  xq:effectadd("AATX\\[AATxNew]Fire08.mdl", "chest", 5)
                end
                if u:hasdata("八重樱-疾如风徐如林") and not xq:hasdata("炎舞踏额外受伤") then
                  xq:settimedata("炎舞踏额外受伤", 10)
                  xq:changetimedata("怪物-额外受伤", 0.25, 10)
                end
              end
            end
          }
        },
        endfunc = function(dx, dy)
          bcybdqdadd(u, 0.3, mz, skillstr)
          if u:hasdata("八重樱-云樱自在") and mz then
            u:curetili(1)
          end
          IssueImmediateOrder(u.handle, "stop")
          u:setdata("位移点X", dx)
          u:setdata("位移点Y", dy)
        end
      })
    end)
  end,
  E = function(u)
    local skillstr = "E"
    local txsh = Srtr_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    local mz = false
    if not u:hasdata("八重樱拔刀斩蓄力") then
      Effectcreate("war3mapImported\\[TX] (1357).mdl", x, y)
      u:playsound(Sound_Katana_19)
      u:setdata("八重樱拔刀斩蓄力")
      ac.wait(1, function()
        u:animeact(8)
      end)
      ac.wait(250, function()
        u:animespeed(0)
      end)
      ac.wait(1000, function()
        u:animespeed(1)
      end)
      local bdqd = u:getdata("八重樱-拔刀强度")
      bcyqkbd(u)
      u:buffset(u.handle, 0.25, "绝对闪避")
      local t = 0
      local cs = 0
      ac.loop(50, function(timer)
        if u:isalive() and not u:hasdata("八重樱拔刀斩蓄力取消") then
          if u:hasdata("八重樱-拔刀斩风林强化") then
            t = t + 0.9
          elseif u:hasdata("八重樱-拔刀斩火山强化") then
            t = t + 0.375
          else
            t = t + 0.15
          end
          if t >= bdqd then
            t = bdqd
          end
          x, y = u:getxy()
          Effectcreate("war3mapImported\\[TxNew1]008.mdl", x, y, 0, 1, 0, GetRandomAngle())
          cs = cs + 1
          if cs == 5 then
            cs = 0
            local dx = 1.5 + t
            if 5.5 <= dx then
              dx = 5.5
            end
            Effectcreate("war3mapImported\\specialanimedustwave.mdl", x, y, 0, dx, 0, GetRandomAngle())
          end
        else
          u:deldata("八重樱拔刀斩蓄力")
          x, y = u:getxy()
          local max = 1 + t
          if 4 <= max then
            max = 4
          end
          for i = 1, max do
            for j = 1, 3 do
              Effectcreate("war3mapImported\\[TxNew]MCut_Greey.mdl", x, y, 0, 4 * i, 90, 120 * j)
            end
          end
          Effectcreate("war3mapImported\\bbb.mdl", x, y, 0, max)
          Effectcreate("AATX\\[AATxNew]Katana64.mdl", x, y, 0, 1.5)
          Effectcreate("AATX\\[AATxNew]Katana62.mdl", x, y, 0, max)
          u:playsound(Sound_Katana_17)
          ac.wait(500, function()
            u:playsound(Katana_06)
          end)
          local xs, maxx
          if u:hasdata("八重樱-拔刀斩风林强化") then
            xs = 6
          else
            xs = 3.5
          end
          xs = 1 + (t - 1) * xs
          if 1 <= t then
            txsh = txsh * xs
          else
            txsh = txsh * t
          end
          u:animespeed(2)
          u:animeact("attack")
          ac.wait(500, function()
            u:animespeed(1)
          end)
          u:setdata("八重樱-拔刀斩蓄力时间", t)
          u:setdata("八重樱-蓄力拔刀强度", bdqd)
          for _, xq in ac.selector():in_rangexy(x, y, 250 * max):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            mz = true
            xq:effectadd("AATX\\[AATxNew]Blood19.mdl", "chest")
            BcyDamage({
              u = u,
              tg = xq,
              damage = txsh,
              string = "E"
            })
            xq:buffset(u.handle, 1 + t, "僵直")
          end
          if u:hasdata("八重樱-云樱自在") and mz then
            u:curetili(1)
          end
          u:deldata("八重樱-蓄力拔刀强度")
          u:deldata("八重樱-拔刀斩蓄力时间")
          timer:remove()
        end
      end)
    end
  end,
  R = function(u)
    local skillstr = "R"
    local txsh = Srtr_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    bcyqkbd(u)
    u:animespeed(3)
    ac.wait(1, function()
      u:animeact(11)
    end)
    ac.wait(500, function()
      u:animespeed(1)
    end)
    local g = CreateGroupLua()
    x, y = PolarXY(x, y, 40, jd)
    local fw = 150
    for i = 1, 8 do
      x, y = PolarXY(x, y, 10, jd)
      for _, xq in ac.selector():in_rangexy(x, y, fw):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        xq:groupadd(g)
      end
    end
    local mz = false
    ForGroupLuaNew(g, function(xq)
      mz = true
      xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
      BcyDamage({
        u = u,
        tg = xq,
        damage = txsh
      })
      xq:buffset(u.handle, 0.5, "僵直")
    end)
    if u:hasdata("八重樱-云樱自在") and mz then
      u:curetili(1)
    end
  end,
  ["R-Cyz"] = function(u, x2, y2)
    local skillstr = "R-Cyz"
    local txsh = u:getdata("八重樱-寒天狂舞伤害倍率") * 0.1
    local x, y = u:getxy()
    local jd = u:getface()
    u:animespeed(3)
    ac.wait(1, function()
      u:animeact(7)
    end)
    ac.wait(500, function()
      u:animespeed(1)
    end)
    u:setskillcd("A19I", 0.25)
    u:playseensound(Sound_Bcy_CyzXiao)
    EffectcreateArgs({
      effect = "DTX\\[DTx]003.mdl",
      x = x2,
      y = y2,
      time = 0.5,
      size = 0.4,
      height = 180,
      zxz = GetRandomAngle(),
      animespeed = 5
    })
    EffectcreateArgs({
      effect = "DTX\\[DTx]003.mdl",
      x = x2,
      y = y2,
      time = 0.5,
      size = 0.4,
      height = 60,
      zxz = GetRandomAngle(),
      xxz = -180,
      animespeed = 5
    })
    local cs = 0
    ac.loop(10, function(timer)
      cs = cs + 1
      local x3, y3 = PolarXY(x2, y2, GetRandomReal(0, 200), GetRandomAngle())
      local tx = EffectcreateArgs({
        effect = "AATX\\[AATxNew]Katana13_C.mdl",
        x = x3,
        y = y3,
        time = 1,
        size = GetRandomReal(0.1, 0.2),
        height = 100,
        zxz = GetRandomAngle(),
        xxz = GetRandomReal(15, 75)
      })
      if cs == 10 then
        for _, xq in ac.selector():in_rangexy(x3, y3, 275):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          BcyDamage({
            u = u,
            tg = xq,
            damage = txsh,
            string = "R-Cyz",
            damagelevel = 5
          })
          xq:buffset(u.handle, 1, "暂停")
        end
      end
      if cs == 20 then
        timer:remove()
      end
    end)
  end,
  VR = function(u)
    local skillstr = "VR"
    local txsh = Srtr_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    local mz = false
    local bdqd = u:getdata("八重樱-拔刀强度")
    bcyqkbd(u)
    local xs = 3.5
    xs = 1 + (bdqd - 1) * xs
    txsh = txsh * xs
    u:deldata("八重樱-山林符")
    u:playsound(Sound_Katana_19)
    u:animespeed(2)
    u:playsound(sound_bcy_yqc[GetRandomInt(20, 26)])
    Effectcreate("ATX\\[ATxNew]Ice_10.mdl", x, y, 0.5, 2)
    bcyzanting(u, 0.5)
    u:buffset(u.handle, 0.5, "无敌")
    ac.timer(50, 10, function()
      Effectcreate("Abilities\\Spells\\Other\\Charm\\CharmTarget.mdl", x, y, 0, 2, 0, GetRandomAngle())
    end)
    ac.wait(1, function()
      u:animeact(8)
    end)
    ac.wait(50, function()
      u:animespeed(0)
    end)
    ac.wait(400, function()
      u:playsound(Sound_Katana_18)
    end)
    ac.wait(500, function()
      u:animespeed(1)
      local jl = 2000
      x, y = u:getxy()
      local dx = jl / 300
      local tx = Effectcreate("ATX\\[ATxNew]Daoguang_27.mdl", x, y, -1, dx, 100, jd)
      ac.wait(800, function()
        SetEffectSize(tx, 0.01)
        DestroyEffectLua(tx)
      end)
      Effectcreate("war3mapImported\\bbb.mdl", x, y)
      local cs = 0
      ac.wait(200, function()
        loopmove({
          x = x,
          y = y,
          time = 0.2,
          distance = jl,
          angle = jd,
          loops = {
            {
              looptime = 0.01,
              func = function(dx, dy)
                cs = cs + 1
                if cs == 2 then
                  cs = 0
                  Effectcreate("ATX\\[ATxNew]Ice_14.mdl", dx, dy, 1.6, 4, 0, GetRandomAngle())
                  Effectcreate("Abilities\\Spells\\Undead\\FrostNova\\FrostNovaTarget.mdl", dx, dy)
                  Effectcreate("AATX\\[AATxNew]Blue04.mdl", dx, dy)
                end
                for _, xq in ac.selector():in_rangexy(dx, dy, 225):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  xq:buffset(u.handle, 2, "眩晕")
                  xq:animeact("death")
                  xq:animespeed(0)
                  ac.wait(1500, function()
                    xq:animespeed(1)
                  end)
                end
              end
            }
          }
        })
      end)
      ac.wait(1500, function()
        u:setdata("八重樱-蓄力拔刀强度", bdqd)
        u:playsound(ThunderClapCaster)
        local x1, y1 = x, y
        local v = jl / 10
        for i = 1, 10 do
          x1, y1 = PolarXY(x1, y1, v, jd)
          Effectcreate("ATX\\[ATxNew]Ice_06.mdl", x1, y1, 0, 0.5)
          for _, xq in ac.selector():in_rangexy(x1, y1, 225):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            mz = true
            xq:buffset(u.handle, 1, "眩晕")
            BcyDamage({
              u = u,
              tg = xq,
              damage = txsh,
              string = "VR",
              sx = "冰"
            })
          end
        end
        if u:hasdata("八重樱-云樱自在") and mz then
          u:curetili(1)
        end
        u:deldata("八重樱-蓄力拔刀强度")
      end)
    end)
  end,
  CR = function(u, dis, x2, y2)
    local skillstr = "CR"
    local txsh = Srtr_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    local bdqd = u:getdata("八重樱-拔刀强度")
    bcyqkbd(u)
    local xs = 1.25
    xs = 1 + (bdqd - 1) * xs
    txsh = txsh * xs
    u:deldata("八重樱-风火符")
    u:playsound(Sound_Katana_19)
    u:animespeed(3)
    Effectcreate("ATX\\[ATxNew]Pink_05.mdl", x, y, 0, 1, 90)
    Effectcreate("ATX\\[ATxNew]Dust_04.mdl", x, y, 0, 0.5, 0, jd)
    Effectcreate("ATX\\[ATxNew]Black_01.mdx", x, y)
    u:playsound(sound_bcy_yqc[GetRandomInt(20, 26)])
    u:buffset(u.handle, 0.5, "无敌")
    bcyzanting(u, 0.3)
    u:buffset(u.handle, 0.4, "绝对闪避")
    ac.wait(1, function()
      u:animeact(9)
    end)
    local mz = false
    unitmove({
      unit = u.handle,
      time = 0.15,
      distance = dis * 20 / 35,
      angle = jd,
      isfly = true,
      {
        looptime = 0.01,
        func = function(dx, dy)
          Effectcreate("war3mapImported\\senbonzakurapart.mdl", dx, dy)
        end
      },
      endfunc = function(dx, dy)
        u:setcolor(255, 255, 255, 0)
      end
    })
    ac.wait(200, function()
      u:reanimeact()
    end)
    ac.wait(240, function()
      u:animeact(11)
      u:animespeed(1)
      Effectcreate("ATX\\[ATxNew]Black_01.mdx", x2, y2, 0, 1, 500)
    end)
    ac.wait(250, function()
      u:setxy(x2, y2)
      u:setcolor(255, 255, 255, 255)
    end)
    ac.wait(300, function()
      u:playsound(Sound_Mugen_10000_45)
      u:playsound(ThunderClapCaster)
      Effectcreate("ATX\\[ATxNew]Dust_07.mdl", x2, y2, 0, math.min(5, bdqd / 2))
      Effectcreate("ATX\\[ATxNew]Sakura_01.mdl", x2, y2, 0, 2)
      Effectcreate("war3mapImported\\senbonzakurapart1.mdl", x2, y2)
      Effectcreate("war3mapImported\\shockwave_pink.mdl", x2, y2)
      Effectcreate("war3mapImported\\bbb.mdl", x2, y2, 0, 2)
      IssueImmediateOrder(u.handle, "stop")
      u:setdata("位移点X", x2)
      u:setdata("位移点Y", y2)
      u:setdata("八重樱-蓄力拔刀强度", bdqd)
      for _, xq in ac.selector():in_rangexy(x2, y2, 350):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        mz = true
        xq:animeact("death")
        BcyDamage({
          u = u,
          tg = xq,
          damage = txsh,
          string = "CR",
          sx = "无"
        })
        xq:buffset(u.handle, 1, "僵直")
      end
      if u:hasdata("八重樱-云樱自在") and mz then
        u:curetili(1)
      end
      u:deldata("八重樱-蓄力拔刀强度")
      if 2.25 <= bdqd then
        local dx = 1
        local cs = 0
        local fw = 350
        ac.loop(150, function(timer)
          bdqd = bdqd - 1.25
          cs = cs + 1
          dx = dx + 0.5
          fw = fw * 1.35
          u:playsound(ThunderClapCaster)
          Effectcreate("war3mapImported\\senbonzakurapart1.mdl", x2, y2, 0, dx)
          Effectcreate("war3mapImported\\shockwave_pink.mdl", x2, y2, 0, dx)
          Effectcreate("war3mapImported\\bbb.mdl", x2, y2, 0, 2 * dx)
          u:setdata("八重樱-蓄力拔刀强度", bdqd)
          for _, xq in ac.selector():in_rangexy(x2, y2, fw):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            BcyDamage({
              u = u,
              tg = xq,
              damage = txsh,
              string = "CR",
              sx = "无"
            })
            xq:buffset(u.handle, 1, "僵直")
          end
          u:deldata("八重樱-蓄力拔刀强度")
          if cs == 5 or bdqd <= 2.25 then
            timer:remove()
          end
        end)
      end
    end)
  end,
  A = function(u)
    local skillstr = "A"
    local txsh = Srtr_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    bcyqkbd(u)
    ac.wait(1, function()
      u:animeact(5)
    end)
    local g = CreateGroupLua()
    x, y = PolarXY(x, y, 40, jd)
    local fw = 150
    for i = 1, 8 do
      x, y = PolarXY(x, y, 10, jd)
      for _, xq in ac.selector():in_rangexy(x, y, fw):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        xq:groupadd(g)
      end
    end
    local mz = false
    ForGroupLuaNew(g, function(xq)
      mz = true
      xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
      BcyDamage({
        u = u,
        tg = xq,
        damage = txsh
      })
      xq:buffset(u.handle, 0.5, "僵直")
    end)
    if u:hasdata("八重樱-云樱自在") and mz then
      u:curetili(1)
    end
  end,
  VA = function(u)
    local skillstr = "VA"
    local txsh = Srtr_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    local sy = u.ownerid
    u:deldata("八重樱-山林符")
    u:playsound(Sound_Katana_04)
    u:playsound(sound_bcy_yqc[GetRandomInt(1, 14)])
    u:animespeed(3)
    if u:hasdata("八重樱-绯焰地狱") then
      local mz = false
      u:deldata("八重樱-绯焰地狱")
      bcybdqdadd(u, 0.25, false, skillstr)
      u:settimedata("八重樱-寒天狂舞", 0.5)
      u:buffset(u.handle, 0.5, "绝对闪避")
      u:effectadd("AATX\\[AATxNew]Black32.mdl", "hand left")
      play_shadow_slow_series(u, {
        act = 5,
        count = 5,
        interval = 0.02,
        main_speed = 1,
        wait_time = 0.04,
        r = 0,
        g = 0,
        b = 255,
        show_alpha = 125,
        fade_sub = 5,
        noact = true
      })
      ac.wait(1, function()
        u:animeact(5)
      end)
      ac.wait(100, function()
        x, y = u:getxy()
        if u:hasdata("八重樱-疾如风徐如林") then
          ChangeTimeValue(HeroMenu_ExtraMoveSpeed, sy, 200, 3)
          u:clearbuff("僵直")
          u:clearbuff("缠绕")
        end
        Effectcreate("ATX\\[ATxNew]Daoguang_08.mdl", x, y, 0, 1, 90, jd)
        Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
        Effectcreate("war3mapImported\\bbb.mdx", x, y)
        u:animespeed(1)
        for _, xq in ac.selector():in_rangexy(x, y, 900):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          mz = true
          xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
          BcyDamage({
            u = u,
            tg = xq,
            damage = txsh
          })
          xq:buffset(u.handle, 2.5, "僵直")
        end
        x, y = PolarXY(x, y, -100, jd)
        u:setxy(x, y)
        bcybdqdadd(u, 0.25, mz, skillstr)
        if u:hasdata("八重樱-云樱自在") and mz then
          u:curetili(1)
        end
      end)
    else
      local mz = false
      ac.wait(1, function()
        u:animeact(5)
      end)
      ac.wait(100, function()
        x, y = u:getxy()
        if u:hasdata("八重樱-疾如风徐如林") then
          ChangeTimeValue(HeroMenu_ExtraMoveSpeed, sy, 200, 3)
          u:clearbuff("僵直")
          u:clearbuff("缠绕")
        end
        Effectcreate("ATX\\[ATxNew]Daoguang_08.mdl", x, y, 0, 1, 90, jd)
        Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
        Effectcreate("war3mapImported\\bbb.mdx", x, y)
        u:animespeed(1)
        for _, xq in ac.selector():in_rangexy(x, y, 475):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          mz = true
          xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
          BcyDamage({
            u = u,
            tg = xq,
            damage = txsh
          })
          xq:buffset(u.handle, 2.5, "僵直")
        end
        x, y = PolarXY(x, y, -100, jd)
        u:setxy(x, y)
        bcybdqdadd(u, 0.25, mz, skillstr)
        if u:hasdata("八重樱-云樱自在") and mz then
          u:curetili(1)
        end
      end)
    end
  end,
  CA = function(u)
    local skillstr = "CA"
    local txsh = Srtr_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    u:deldata("八重樱-风火符")
    if u:hasdata("八重樱-绯焰地狱") and not u:hasdata("八重樱-红莲业火连携") then
      u:settimedata("八重樱-红莲业火连携", 0.5)
    end
    u:playsound(Sound_Katana_14)
    u:playsound(sound_bcy_yqc[GetRandomInt(1, 14)])
    u:animespeed(3)
    u:setskillcd("A19J", 0.1)
    local fw
    if u:hasdata("八重樱-侵略如火不动如山") then
      fw = 275
    else
      fw = 225
    end
    local mz = false
    ac.wait(50, function()
      x, y = u:getxy()
      x, y = PolarXY(x, y, 40, jd)
      u:setxy(x, y)
      local mj = u:createunit("u0AI", x, y, jd)
      mj:timetoremove(0.3)
      ac.wait(1, function()
        mj:animeact(2)
      end)
      for _, xq in ac.selector():in_rangexy(x, y, fw):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        local z = math.abs(AngleBetweenUnits(u.handle, xq.handle))
        if z <= 90 or 270 <= z then
          mz = true
          local x2, y2 = xq:getxy()
          x2, y2 = PolarXY(x2, y2, 40, jd)
          xq:setxy(x2, y2)
          xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
          BcyDamage({
            u = u,
            tg = xq,
            damage = txsh,
            string = "CA"
          })
          xq:buffset(u.handle, 1.5, "僵直")
        end
      end
    end)
    ac.wait(200, function()
      x, y = u:getxy()
      x, y = PolarXY(x, y, 40, jd)
      u:setxy(x, y)
      local mj = u:createunit("u0AI", x, y, jd)
      mj:timetoremove(0.3)
      ac.wait(1, function()
        mj:animeact(0)
      end)
      for _, xq in ac.selector():in_rangexy(x, y, fw):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        local z = math.abs(AngleBetweenUnits(u.handle, xq.handle))
        if z <= 90 or 270 <= z then
          mz = true
          local x2, y2 = xq:getxy()
          x2, y2 = PolarXY(x2, y2, 40, jd)
          xq:setxy(x2, y2)
          xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
          BcyDamage({
            u = u,
            tg = xq,
            damage = txsh,
            string = "CA"
          })
          xq:buffset(u.handle, 1.5, "僵直")
        end
      end
      bcybdqdadd(u, 0.12, mz, skillstr)
      if u:hasdata("八重樱-云樱自在") and mz then
        u:curetili(0.5)
      end
      u:settimedata("八重樱-缭乱刃", 0.5)
    end)
  end,
  F = function(u)
    local skillstr = "F"
    local txsh = Srtr_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    bcyqkbd(u)
    ac.wait(1, function()
      u:animeact(5)
    end)
    local g = CreateGroupLua()
    x, y = PolarXY(x, y, 40, jd)
    local fw = 150
    for i = 1, 8 do
      x, y = PolarXY(x, y, 10, jd)
      for _, xq in ac.selector():in_rangexy(x, y, fw):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        xq:groupadd(g)
      end
    end
    local mz = false
    ForGroupLuaNew(g, function(xq)
      xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
      BcyDamage({
        u = u,
        tg = xq,
        damage = txsh
      })
      mz = true
      xq:buffset(u.handle, 0.5, "僵直")
    end)
    if u:hasdata("八重樱-云樱自在") and mz then
      u:curetili(1)
    end
  end,
  VF = function(u)
    local skillstr = "VF"
    local txsh = Srtr_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    bcybdqdadd(u, 0.1, true, skillstr)
    u:deldata("八重樱-山林符")
    u:playsound(Sound_BCY_10)
    bcyzanting(u, 0.8)
    u:buffset(u.handle, 0.8, "无敌")
    ac.wait(400, function()
      u:playsound(Sound_Katana_19)
      u:animeact(4)
    end)
    ac.wait(600, function()
      Effectcreate("ATX\\[ATxNew]Sakura_01.mdl", x, y, 1)
      u:animespeed(0)
    end)
    ac.wait(800, function()
      if not u:isalive() then
        return
      end
      u:animespeed(1)
      u:playsound(Sound_Katana_01)
      ac.wait(450, function()
        u:playsound(Sound_Katana_11)
      end)
      local a = GetRandomAngle()
      local fw1, fw2
      if u:hasdata("八重樱-侵略如火不动如山") then
        fw1 = 135
        fw2 = 450
      else
        fw1 = 90
        fw2 = 375
      end
      for i = 1, 6 do
        a = a + 72
        local x2, y2 = PolarXY(x, y, 100, a)
        local dx = 1
        unifycreate({
          owner = u.handle,
          model = "war3mapImported\\senbonzakurapart1.mdl",
          modelname = "八重樱-樱花散剑团",
          modelsize = 1,
          height = 0,
          damage = 0,
          damagetype = 1,
          x = x2,
          y = y2,
          range = 1500,
          time = 0.5,
          volume = fw1,
          angle = a,
          angleoffset = 0,
          attenua = 1,
          attenuacount = 999,
          life = 10,
          isbullet = false,
          isvest = false,
          isignorearmor = false,
          startfunc = function(mj)
            mj:setdata("循环计数", 0)
            mj:setdata("循环计数2", 0)
          end,
          loopfunc = function(mj)
            mj:changedata("循环计数", UnifyDT)
            mj:changedata("循环计数2", UnifyDT)
            if mj:getdata("循环计数") >= 0.01 then
              mj:setdata("循环计数", 0)
              GroupClearLua(mj:getdata("弹幕-伤害组"))
              dx = dx + 0.04
              mj:setsize(dx)
              mj:setface(mj:getface() + 2)
            end
            if mj:getdata("循环计数2") >= 0.04 then
              mj:setdata("循环计数2", 0)
              mj:playsound(Youmu_ECA_Act)
            end
          end,
          hitfunc = function(mj, damage)
            return damage
          end,
          hitbeforefunc = function(mj, xq, damage2)
          end,
          hitafterfunc = function(mj, xq, damage2)
            local x3, y3 = mj:getxy()
            if not xq:hasdata("免疫击退效果") then
              xq:setxy(x3, y3)
            end
          end,
          endfunc = function(mj)
            local x3, y3 = mj:getxy()
            Effectcreate("ATX\\[ATxNew]Pink_01.mdl", x3, y3, 0, 2)
            Effectcreate("DTX\\[DTX]001.mdl", x3, y3, 0, 2)
            for _, xq in ac.selector():in_rangexy(x3, y3, fw2):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              BcyDamage({
                u = u,
                tg = xq,
                damage = txsh
              })
              xq:buffset(u.handle, 1.5, "眩晕")
            end
          end
        })
      end
    end)
  end,
  CF = function(u)
    local skillstr = "CF"
    local txsh = Srtr_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    bcybdqdadd(u, 0.1, true, skillstr)
    u:deldata("八重樱-风火符")
    u:playsound(Sound_BCY_10)
    bcyzanting(u, 0.8)
    u:buffset(u.handle, 0.8, "无敌")
    ac.wait(400, function()
      u:playsound(Sound_Katana_19)
      u:animeact(4)
    end)
    ac.wait(800, function()
      if not u:isalive() then
        return
      end
      u:animespeed(1)
      u:playsound(Sound_Katana_01)
      local a = jd - 63
      for i = 1, 6 do
        a = a + 18
        local x2, y2 = PolarXY(x, y, 100, a)
        local g = CreateGroupLua()
        local g2 = CreateGroupLua()
        local dx = 1
        unifycreate({
          owner = u.handle,
          model = "CTX\\[WTX] 001.mdl",
          modelname = "八重樱-樱花散剑气",
          modelsize = 1,
          height = 0,
          damage = 0,
          damagetype = 1,
          x = x2,
          y = y2,
          range = 1500,
          time = 0.5,
          volume = 64,
          angle = a,
          angleoffset = 0,
          attenua = 1,
          attenuacount = 999,
          life = 10,
          isbullet = false,
          isvest = false,
          isignorearmor = false,
          startfunc = function(mj)
            mj:setdata("循环计数", 0)
            mj:setdata("循环计数2", 0)
          end,
          loopfunc = function(mj)
            mj:changedata("循环计数", UnifyDT)
            mj:changedata("循环计数2", UnifyDT)
            if mj:getdata("循环计数") >= 0.01 then
              mj:setdata("循环计数", 0)
              GroupClearLua(mj:getdata("弹幕-伤害组"))
              dx = dx + 0.04
              mj:setsize(dx)
            end
            if mj:getdata("循环计数2") >= 0.04 then
              mj:setdata("循环计数2", 0)
              mj:playsound(Youmu_ECA_Act)
            end
          end,
          hitfunc = function(mj, damage)
            return damage
          end,
          hitbeforefunc = function(mj, xq, damage2)
          end,
          hitafterfunc = function(mj, xq, damage2)
            local x3, y3 = mj:getxy()
            x3, y3 = PolarXY(x3, y3, 100, a)
            if not xq:hasdata("免疫击退效果") then
              xq:setxy(x3, y3)
            end
            if not xq:isingroup(g) then
              xq:groupadd(g)
              u:setdata("八重樱-真红限伤")
              BcyDamage({
                u = u,
                tg = xq,
                damage = txsh
              })
              xq:buffset(u.handle, 0.8, "僵直")
            elseif u:hasdata("八重樱-侵略如火不动如山") then
              if not xq:isingroup(g2) then
                xq:groupadd(g2)
                BcyDamage({
                  u = u,
                  tg = xq,
                  damage = txsh
                })
                xq:buffset(u.handle, 0.8, "僵直")
              else
                BcyDamage({
                  u = u,
                  tg = xq,
                  damage = txsh,
                  isvest = true
                })
              end
            else
              BcyDamage({
                u = u,
                tg = xq,
                damage = txsh,
                isvest = true
              })
            end
          end,
          endfunc = function(mj)
            local x3, y3 = mj:getxy()
            Effectcreate("ATX\\[ATxNew]Pink_01.mdl", x3, y3)
            mj:setxy(PX_X, PX_Y)
          end
        })
      end
    end)
  end,
  CV = function(u)
    local skillstr = "CV"
    local sy = u.ownerid
    local txsh = Srtr_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    u:playsound(Sound_BCY_27)
    u:deldata("八重樱-山林符")
    u:deldata("八重樱-风火符")
    local t, t2
    if u:hasdata("八重樱-般若之心") then
      t = 45
      t2 = 2
      ChangeTimeValue(Correction_Jzsh, sy, 0.1 * (0.03 * u:getlevel()), 30)
    else
      t = 60
      t2 = 1
    end
    u:effectadd("AATX\\[AATxNew]Pink05.mdl", "origin")
    u:effectadd("AATX\\[AATxNew]Pink15.mdl", "origin")
    u:effectadd("AATX\\[AATxNew]Pink13.mdl", "chest", 1)
    if u:hasdata("八重樱-云樱自在") then
      u:curetili(25)
      t = t - 15
    else
      u:curetili(10)
    end
    u:buffset(u.handle, 1, "绝对闪避")
    u:settimedata("八重樱-绯焰地狱", t2)
    u:setdata("八重樱-绯焰地狱冷却", t)
    ac.wait(t * 1000, function()
      u:sendmessage("|cFF7DBEF1绯焰地狱冷却完毕|r")
    end)
  end,
  CAC = function(u)
    local skillstr = "CAC"
    local txsh = Srtr_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    u:deldata("八重樱-缭乱刃")
    u:playsound(Sound_Katana_14)
    u:playsound(sound_bcy_yqc[GetRandomInt(1, 14)])
    u:animespeed(3)
    local fw
    if u:hasdata("八重樱-侵略如火不动如山") then
      fw = 275
    else
      fw = 225
    end
    local mz = false
    ac.wait(50, function()
      x, y = u:getxy()
      x, y = PolarXY(x, y, 40, jd)
      u:setxy(x, y)
      u:animeact(5)
      local mj = u:createunit("u0AI", x, y, jd)
      mj:timetoremove(0.3)
      ac.wait(1, function()
        mj:animeact(0)
      end)
      for _, xq in ac.selector():in_rangexy(x, y, fw):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        local z = math.abs(AngleBetweenUnits(u.handle, xq.handle))
        if z <= 90 or 270 <= z then
          mz = true
          local x2, y2 = xq:getxy()
          x2, y2 = PolarXY(x2, y2, 40, jd)
          xq:setxy(x2, y2)
          xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
          BcyDamage({
            u = u,
            tg = xq,
            damage = txsh,
            string = "CA"
          })
          xq:buffset(u.handle, 1.5, "僵直")
        end
      end
    end)
    ac.wait(200, function()
      x, y = u:getxy()
      x, y = PolarXY(x, y, 40, jd)
      u:setxy(x, y)
      u:animeact(4)
      local mj = u:createunit("u0AI", x, y, jd)
      mj:timetoremove(0.3)
      ac.wait(1, function()
        mj:animeact(2)
      end)
      for _, xq in ac.selector():in_rangexy(x, y, fw):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        local z = math.abs(AngleBetweenUnits(u.handle, xq.handle))
        if z <= 90 or 270 <= z then
          mz = true
          local x2, y2 = xq:getxy()
          x2, y2 = PolarXY(x2, y2, 40, jd)
          xq:setxy(x2, y2)
          xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
          BcyDamage({
            u = u,
            tg = xq,
            damage = txsh,
            string = "CA"
          })
          xq:buffset(u.handle, 1.5, "僵直")
        end
      end
      bcybdqdadd(u, 0.12, mz, skillstr)
      if u:hasdata("八重樱-云樱自在") and mz then
        u:curetili(0.5)
      end
    end)
  end,
  CVVAQR = function(u, x2, y2)
    local skillstr = "CVVAQR"
    local txsh = Srtr_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    local bdqd = u:getdata("八重樱-拔刀强度")
    bcyqkbd(u)
    u:deldata("八重樱-寒天狂舞释放")
    PlayGlobalSound(Sound_BCY_Cyz_01)
    local xs = 10
    xs = 1 + (bdqd - 2) * xs
    if xs <= 4 then
      xs = 4
    end
    txsh = txsh * xs
    local bs = 1
    if u:hasdata("位移强化-维吉尔") then
      bs = bs + 2.5
    end
    if u:hasdata("变异判定-抛瓦椅") then
      bs = bs + 1
    end
    txsh = txsh * bs
    u:setdata("八重樱-寒天狂舞伤害倍率", txsh)
    u:buffset(u.handle, 5, "永恒")
    u:buffset(u.handle, 5, "绝对闪避")
    u:buffset(u.handle, 5, "无敌")
    u:buffset(u.handle, 5, "暂停")
    local mj = u:createunit("u0AQ", x, y, jd)
    mj:setcolor(255, 255, 255, 80)
    ac.wait(1350, function()
      mj:setcolor(255, 255, 255, 0)
    end)
    mj:timetoremove(4.5)
    local mj = u:createunit("u0AR", x, y, jd)
    mj:setcolor(255, 255, 255, 0)
    ac.wait(1350, function()
      mj:setcolor(255, 255, 255, 255)
    end)
    mj:timetoremove(4.5)
    u:effectadd("AATX\\[AATxNew]Black32.mdl", "hand left")
    u:playsound(DbKatana_01)
    ac.wait(1, function()
      ResetUnitAnimation(u.handle)
      u:animeact(8)
      u:animespeed(0.6)
    end)
    unitmove({
      unit = u.handle,
      time = 0.6,
      distance = 300,
      angle = jd + 180,
      isfly = true,
      endfunc = function(dx, dy)
        u:animespeed(1)
      end
    })
    play_shadow_slow_series(u, {
      act = 8,
      count = 30,
      interval = 0.02,
      main_speed = 0.6,
      wait_time = 0,
      r = 0,
      g = 0,
      b = 255,
      show_alpha = 125,
      fade_sub = 10
    })
    for _, xq in ac.selector():in_rangexy(x, y, 3000):is_enemy(u.handle):ipairs() do
      xq = getunit(xq)
      xq:buffset(u.handle, 8, "僵直")
    end
    ac.wait(1350, function()
      for _, xq in ac.selector():in_rangexy(x, y, 2800):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        xq:animespeed(0)
        xq:buffset(u.handle, 5, "暂停")
        xq:buffset(u.handle, 5, "锁定")
        xq:buffset(u.handle, 5, "沉默")
        ac.wait(3300, function()
          xq:animespeed(1)
        end)
      end
      u:effectadd("AATX\\[AATxNew]Hit52.mdl", "hand left")
      u:animespeed(10)
      ac.wait(250, function()
        u:animespeed(0)
      end)
      local aa
      if GetRandom100(50) then
        aa = 90
      else
        aa = -90
      end
      local tx = EffectcreateArgs({
        effect = "AATX\\[AATxNew]Katana13_C.mdl",
        x = x2,
        y = y2,
        time = 5,
        size = 1,
        height = 300,
        zxz = jd + aa,
        xxz = 15
      })
      ac.wait(200, function()
        SetEffectActSpeed(tx, 0)
      end)
      ac.wait(3300, function()
        SetEffectActSpeed(tx, 1)
        u:setdata("八重樱-蓄力拔刀强度", bdqd)
        for _, xq in ac.selector():in_rangexy(x2, y2, 1200):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          xq:animeact("death")
          if not xq:isboss() then
            xq:losshp(u, 0, 50)
            xq:effectadd("AATX\\[AATxNew]Blood19.mdl", "chest")
          else
            xq:effectadd("war3mapImported\\texiao_xuebao.mdx", "chest")
          end
          BcyDamage({
            u = u,
            tg = xq,
            damage = txsh,
            string = "CVVAQR",
            damagelevel = 4
          })
        end
        u:deldata("八重樱-蓄力拔刀强度")
      end)
      local cs = 0
      ac.loop(30, function(timer)
        cs = cs + 1
        local x3, y3 = PolarXY(x2, y2, GetRandomReal(200, 900), GetRandomAngle())
        local tx = EffectcreateArgs({
          effect = "AATX\\[AATxNew]Katana13_C.mdl",
          x = x3,
          y = y3,
          time = 5,
          size = GetRandomReal(0.8, 1.2),
          height = 300,
          zxz = GetRandomAngle(),
          xxz = GetRandomReal(15, 75)
        })
        ac.wait(200, function()
          SetEffectActSpeed(tx, 0)
        end)
        ac.wait(3300 - 20 * cs, function()
          SetEffectActSpeed(tx, 1)
        end)
        if cs == 20 then
          timer:remove()
        end
      end)
    end)
    ac.wait(5000, function()
      u:reanimeact()
      u:animespeed(1)
      if u:hasdata("八重樱-疾如风徐如林") then
        u:settimedata("八重樱-寒天狂舞次元斩", 8)
      end
    end)
    if u:hasdata("八重樱-杀意之痕") then
      u:settimedata("八重樱-杀意之痕附伤", 30)
    end
  end,
  CVCACW = function(u, x2, y2)
    local skillstr = "CVCACW"
    local txsh = Srtr_Shanghaijisuan(u, skillstr)
    local x, y = u:getxy()
    local jd = u:getface()
    local bdqd = u:getdata("八重樱-拔刀强度")
    u:deldata("八重樱-红莲业火连携")
    local damagelv = 1
    if u:hasdata("八重樱-侵略如火不动如山") then
      damagelv = 5
      Boolean_Bcy_Hylh = true
      FlashFog()
      ac.wait(10000, function()
        Boolean_Bcy_Hylh = false
        FlashFog()
      end)
      u:settimedata("八重樱-红莲业火强化", 10)
      ac.wait(10000, function()
        ac.timer(500, 20, function()
          u:changedata("八重樱-拔刀强度", 0.925, 1)
          if 1 > u:getdata("八重樱-拔刀强度") then
            u:setdata("八重樱-拔刀强度", 1)
          end
        end)
      end)
    else
      bcyqkbd(u)
    end
    local xs = 1.5
    xs = 1 + (bdqd - 2) * xs
    if xs <= 4 then
      xs = 6
    end
    txsh = txsh * xs
    local g = CreateGroupLua()
    local rs = 1200
    local cf = true
    u:shockcamera(600, 0.15)
    u:playsound(Sound_Katana_20)
    CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 0.1, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 50.0, 0.0, 0.0, 0.0)
    DisplayCineFilter(false)
    if u:isbeseenlocal() then
      DisplayCineFilter(true)
    end
    EffectcreateArgs({
      effect = "war3mapImported\\sete_huanghun1.mdl",
      x = x,
      y = y,
      time = 0.5,
      size = 10,
      height = -500,
      zxz = jd,
      animespeed = 2.0
    })
    EffectcreateArgs({
      effect = "war3mapImported\\sete_huanghun1.mdl",
      x = x,
      y = y,
      time = 0.5,
      size = 5,
      height = -500,
      zxz = jd,
      animespeed = 2.0
    })
    EffectcreateArgs({
      effect = "war3mapImported\\sete_huanghun1.mdl",
      x = x,
      y = y,
      time = 0.5,
      size = 3,
      height = -500,
      zxz = jd,
      animespeed = 2.0
    })
    EffectcreateArgs({
      effect = "war3mapImported\\sete_huanghun1.mdl",
      x = x,
      y = y,
      time = 0.5,
      size = 20,
      height = -500,
      zxz = jd
    })
    for _, xq in ac.selector():in_rangexy(x, y, 1200):is_enemy(u.handle):ipairs() do
      xq = getunit(xq)
      xq:groupadd(g)
    end
    if Group_Counts(g) == 0 then
      rs = 0
      cf = false
      u:buffset(u.handle, 1.1, "暂停")
      u:buffset(u.handle, 1.1, "永恒")
      u:buffset(u.handle, 1.4, "绝对闪避")
      u:buffset(u.handle, 1.4, "无敌")
    else
      u:buffset(u.handle, 2.3, "暂停")
      u:buffset(u.handle, 2.3, "永恒")
      u:buffset(u.handle, 2.6, "绝对闪避")
      u:buffset(u.handle, 2.6, "无敌")
    end
    SetCameraTargetControllerNoZForPlayer(u.owner, u.handle, 0, 0, false)
    ac.wait(200, function()
      if cf == true then
        local cs = 0
        u:animeact(4)
        ac.loop(100, function(t)
          cs = cs + 1
          local mb = Group_Randomunit(g)
          ForGroupLuaNew(g, function(xq)
            if xq:isboss() then
              mb = xq
            end
          end)
          local jd1 = AngleBetweenUnits(u.handle, mb.handle)
          local jl = DistanceBetweenUnits(u.handle, mb.handle) + 1000
          if cs == 8 then
            jl = jl - 1000
          end
          local dx, dy = mb:getxy()
          CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 0.1, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 50.0, 0.0, 0.0, 0.0)
          DisplayCineFilter(false)
          if u:isbeseenlocal() then
            DisplayCineFilter(true)
          end
          u:shockcamera(100, 0.1)
          PlayGlobalSound(Sound_Katana_23)
          u:playseensound(zhigui_zhanji1)
          local ng = CreateGroupLua()
          unitmove({
            unit = u.handle,
            time = 0.1,
            distance = jl,
            angle = jd1,
            isfly = true,
            loops = {
              {
                looptime = 0.01,
                func = function(dx, dy)
                  for _, xq in ac.selector():in_rangexy(dx, dy, 300):is_enemy(u.handle):isnotingroup(ng):ipairs() do
                    xq = getunit(xq)
                    xq:groupadd(ng)
                    BcyDamage({
                      u = u,
                      tg = xq,
                      damage = txsh,
                      string = "CVCACW",
                      damagelevel = damagelv
                    })
                    xq:buffset(u.handle, 2, "眩晕")
                    xq:buffset(u.handle, 2, "沉默")
                  end
                end
              }
            }
          })
          u:setface(jd1)
          EffectcreateArgs({
            effect = "war3mapImported\\qiye_zhanji8.mdx",
            x = dx,
            y = dy,
            size = 5,
            height = -50,
            zxz = jd1,
            animespeed = 2
          })
          EffectcreateArgs({
            effect = "war3mapImported\\qiye_zhanji8.mdx",
            x = dx,
            y = dy,
            size = 20,
            height = -700,
            zxz = jd1,
            animespeed = 2
          })
          if 8 <= cs then
            t:remove()
          end
        end)
      end
    end)
    ac.wait(rs, function()
      u:playsound(Sound_Katana_19)
      u:playsound(Sound_BCY_11)
      local cs = 0
      ac.loop(100, function(t)
        cs = cs + 1
        local dx, dy = u:getxy()
        EffectcreateArgs({
          effect = "war3mapImported\\sete_zhanji.mdx",
          x = dx,
          y = dy,
          size = GetRandomReal(10, 10),
          zxz = GetRandomAngle(),
          xxz = GetRandomAngle(),
          yxz = GetRandomAngle(),
          animespeed = 1
        })
        u:shockcamera(100, 0.05)
        for _, xq in ac.selector():in_rangexy(dx, dy, cs * 100 + 400):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          BcyDamage({
            u = u,
            tg = xq,
            damage = txsh,
            string = "CVCACW",
            damagelevel = damagelv
          })
          xq:buffset(u.handle, 2, "眩晕")
          xq:buffset(u.handle, 2, "沉默")
        end
        if 10 <= cs then
          t:remove()
        end
      end)
      ac.wait(100, function()
        local cs1 = 0
        local dx, dy = u:getxy()
        ac.loop(100, function(t1)
          cs1 = cs1 + 1
          u:animeact(5)
          u:playsound(Sound_Katana_14)
          Effectcreate("war3mapImported\\[TX] (327).mdl", dx, dy, 0, cs1 / 2, 0, GetRandomAngle(), 0, 0, 2)
          Effectcreate("ATX\\[ATxNew]ShockBoom_29.mdl", dx, dy, 0, cs1 / 2, 0, GetRandomAngle(), 0, 0, 2)
          EffectcreateArgs({
            effect = "war3mapImported\\sete_huanghun1.mdl",
            x = dx,
            y = dy,
            time = 0.2,
            size = cs1 / 3,
            height = -500,
            zxz = jd,
            animespeed = 10.0
          })
          if 10 <= cs1 then
            SetCameraTargetControllerNoZForPlayer(u.owner, u.handle, 0, 0, false)
            ResetToGameCameraForPlayer(u.owner, 0)
            local p = getplayer(u.owner)
            p:setcameraheight(Cam_height[u.ownerid], 0)
            u:shockcamera(600, 0.3)
            for i = 1, 10 do
              EffectcreateArgs({
                effect = "war3mapImported\\sete_huanghun1.mdl",
                x = dx,
                y = dy,
                time = 0.5,
                size = cs1 * 1.5,
                height = -500,
                zxz = jd,
                animespeed = 1.0
              })
            end
            t1:remove()
          end
        end)
      end)
    end)
    if u:hasdata("八重樱-杀意之痕") then
      u:settimedata("八重樱-杀意之痕附伤", 30)
    end
  end
}
return zgskill
