-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local slk = require("jass.slk")

local function shootact(args)
  local u = args.u
  local unit = u.handle
  local skill = args.skill
  local gun = args.gun
  local sc = args.sc
  local rpm = args.rpm
  local xhzd = args.xhzd
  local sjsm = args.sjsm
  local snd = args.snd
  local sh = args.sh
  local shlx = args.shlx
  local issingle = args.issingle
  local x = args.x
  local y = args.y
  local jd = args.jd
  local jdxz = args.jdxz
  local ctsj = args.ctsj
  local ctcs = args.ctcs
  local txsh = args.txsh or 0
  local islxhd = args.islxhd or false
  local sy = u.ownerid
  local gun2
  if gun == u:getdata("装备枪支") then
    gun2 = u:getdata("辅助枪支")
  else
    gun2 = u:getdata("装备枪支")
  end
  local guntype = GetItemTypeId(gun)
  local lx = GetData(guntype, "枪械类型")
  if u:hasdata("缇娜-沙漠之鹰") then
    lx = 8
    u:playsound(bac418)
    if u:hasdata("缇娜天赋-枪斗术贝塔") then
      u:setskillcd(u:getdata("位移技能-W"), 0)
      u:setskillcd(u:getdata("位移技能-Q"), 0)
    end
  end
  local juji, kj
  if lx == 3 then
    juji = true
    if u:hasdata("狙击模式-开启") then
      kj = true
    else
      kj = false
    end
  end
  if u:hasdata("变异判定-战术少女") and not u:hasdata("Niko-进阶") then
    u:changedata("战术少女-背身三发计数", 1)
    if 3 <= u:getdata("战术少女-背身三发计数") then
      u:setdata("战术少女-背身三发计数", 0)
      if GetRandom100(25) then
        if GetRandom100(50) then
          jd = jd + 45
        else
          jd = jd - 45
        end
      end
    end
  end
  if xhzd <= GetItemCharges(gun) then
    local mdj = false
    if GetItemCharges(gun) == u:getdata("UI-弹药数量上限") then
      mdj = true
    end
    if xhzd ~= 0 then
      gunammude(unit, gun, xhzd)
      gunshowrefreesh(unit)
      u:setskillcd(skill, rpm)
      if snd ~= 0 then
        if juji then
          u:playseensound(snd)
          if guntype == Guns["AX338狙击枪"] then
            ac.wait(1000, function()
              u:playseensound(AX338_ShotRe)
            end)
          end
          if guntype == Guns.AWP then
            u:playseensound(awp2_split_out1)
            ac.wait(200, function()
              u:playseensound(awp2_clipout)
            end)
          end
        else
          u:playsound(snd)
        end
      end
    end
    if not islxhd then
      ac.wait(1, function()
        if not u:ishasskill("A00Z") then
          if issingle then
            if u:istype("E002") then
              u:animeact("attack alternate")
            elseif u.type == HeroType["灵梦"] then
              u:animeact("spell")
            elseif u.type == HeroType["缇娜"] and u:ishasskill("A0DS") then
              u:animeact("spell one")
            elseif u.type == HeroType["贝洛妮卡"] then
              u:animeact(3)
            else
              u:animeact("attack")
            end
          else
            local ti = 0.5
            if u:istype("E002") then
              u:animeact("attack alternate")
              ti = 0.6
            elseif u.type == HeroType["魔理沙"] or u.type == HeroType["十六夜"] then
              u:animeact("attack slam")
            elseif u.type == HeroType["蕾米"] then
              u:animeact(9)
            elseif u.type == HeroType["爱丽丝"] then
              u:animeact(3)
            elseif u.type == HeroType["切嗣"] then
              u:animeact(5)
            elseif u.type == HeroType["贝洛妮卡"] then
              u:animeact(3)
            elseif u.type == HeroType["白洲梓"] then
              u:animeact(1)
            else
              u:animeact("attack")
            end
            u:addtimeskill("A00Z", ti)
          end
        end
      end)
    end
    if guntype == Guns["光之剑超新星"] then
      local shsj = 0.99
      local sh2 = sh * 0.2
      ac.wait(200, function()
        local txmj = u:createunit("u01X", x, y, jd)
        ac.wait(1, function()
          txmj:animeact("birth")
          txmj:animespeed(2.5)
          local tt = 0.1
          ac.timer(100, 5, function()
            local g = CreateGroupLua()
            local gama = jd
            for i = 1, 20 do
              local r = 100 * i
              local x4, y4 = PolarXY(x, y, r, gama)
              for _, xq in ac.selector():in_rangexy(x4, y4, 170):is_enemy(u.handle):isnotingroup(g):ipairs() do
                xq = getunit(xq)
                xq:groupadd(g)
                DamageUnit({
                  bj = "枪械伤害(光之剑超新星)",
                  unit = xq.handle,
                  source = u.handle,
                  damage = sh2,
                  level = 1,
                  type = "能量",
                  isvest = false,
                  isattack = false,
                  isnoarmor = false,
                  element = "无",
                  extradata = {"枪械"}
                })
                sh2 = sh2 * shsj
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
      return true
    end
    if guntype == Guns["魔弹"] then
      u:addgold(-0.1 * u:getgold())
      Effectcreate("Modan (2).mdx", x, y, 0, 1, 90, jd, 0, 90)
      Effectcreate("Modan (4).mdx", x, y)
      if GetItemCharges(gun) == 0 and u:getluckrandom(5, false) then
        if u:getperhp() <= 99 then
          u:losshp(u, 0, 0, 99)
          u:kill()
        else
          u:losshp(u, 0, 0, 99)
        end
      end
    end
    if guntype == Guns["丧钟"] then
      u:setdata("丧钟-剩余子弹数", GetItemCharges(gun))
      u:sendmessage("|cFF666666「|r|cFF70525C丧|r|cFF7A3D52钟|r|cFF852947」剩余" .. GetItemCharges(gun) .. "发|r")
      if GetItemCharges(gun) == 0 and u:hasdata("变异判定-愚者初始") then
        shlx = 5
        sh = sh * (1 + 0.2 * math.max(u:getdata("愚者-宿命计数"), 1))
      end
    end
    if guntype == Guns["演算宝珠"] then
      if u:getmp() >= 3 then
        u:curemp(-3)
        local intadd = 100 * u:getint()
        if 100000 <= intadd then
          intadd = 100000
        end
        sh = sh + intadd + 10 * u:getdata("魔力值")
      end
      u:playseensound(Sound_Yansuanbaozhu)
      SetSoundVolumeBJ(Sound_Yansuanbaozhu, 70)
    end
    local mk_xg, lv_xg = ReturnGunMokuaiData(gun, "下挂")
    if mk_xg == "近战模块" then
      local cd = 5
      if lv_xg == 2 then
        cd = 3
      end
      if lv_xg == 3 then
        if mdj and lx ~= 4 and not u:hasdata("近战模块-触发近战武器冷却") then
          u:useweapon()
          u:settimedata("近战模块-触发近战武器冷却", 0.1)
        end
      elseif not u:hasdata("近战模块-触发近战武器冷却") then
        u:useweapon()
        u:settimedata("近战模块-触发近战武器冷却", cd)
      end
    end
    local ishasend = false
    if u:hasdata("an94-入战") then
      sjsm = sjsm + 1
    end
    for i = 1, sjsm do
      local model, modelsize, modelname
      local speed = 7500
      if lx == 3 then
        if kj then
          speed = 13000
          if u:hasdata("缇娜天赋-狙击精通") then
            speed = 16000
          end
        else
          speed = 10000
        end
      end
      if islxhd then
        if lx == 4 then
          model = "Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl"
          modelsize = 0.6
          modelname = "幻影霰弹"
        else
          model = "Abilities\\Weapons\\SerpentWardMissile\\SerpentWardMissile.mdl"
          modelsize = 0.6
          modelname = "幻影子弹"
        end
      else
        model, modelsize, modelname = ammureplace(unit, gun)
      end
      if guntype == Guns["魔弹"] then
        model = "zidan1.mdl"
        modelsize = 1
        modelname = "魔弹"
      end
      if guntype == Guns["丧钟"] then
        model = "0Tx\\0Tx_Modao (3).mdl"
        modelsize = 1
        modelname = "丧钟弹"
        ishasend = true
        speed = 6000
      end
      if guntype == Guns["演算宝珠"] then
        model = "0Tx\\0Tx_Modao (3).mdl"
        modelsize = 1
        modelname = "演算弹"
        ishasend = true
        speed = 2500
      end
      local height = 90
      if u.type == HeroType["灵梦"] or u.type == HeroType["魔理沙"] or u.type == HeroType["爱丽丝"] or u.type == HeroType["切嗣"] then
        height = 100
      end
      if u.type == HeroType["贝洛妮卡"] or u.type == HeroType["白洲梓"] then
        height = 120
      end
      if u.type == HeroType["狂三"] then
        height = 140
      end
      unifycreate({
        owner = unit,
        model = model,
        modelname = modelname,
        modelsize = modelsize,
        height = height,
        damage = sh,
        damagetype = shlx,
        speed = speed,
        range = sc,
        x = x,
        y = y,
        angle = jd,
        angleoffset = jdxz,
        attenua = ctsj,
        attenuacount = ctcs,
        isbullet = true,
        startfunc = function(mj)
          ammuadd(unit, gun, mj.handle)
          mj:setdata("循环计数", 0)
        end,
        loopfunc = function(mj)
          mj:changedata("循环计数", UnifyDT)
          if mj:getdata("循环计数") >= 0.03 then
            mj:setdata("循环计数", 0)
            Bulletloopfunc(mj)
          end
        end,
        endfunc = function(mj)
          if ishasend then
            if guntype == Guns["演算宝珠"] then
              local ax, ay = mj:getxy()
              Effectcreate("Abilities\\Weapons\\Bolt\\BoltImpact.mdl", ax, ay)
              ac.wait(250, function()
                SetUnitX(mj.handle, PX_X)
                SetUnitY(mj.handle, PX_Y)
              end)
            end
            if guntype == Guns["丧钟"] then
              ac.wait(250, function()
                SetUnitX(mj.handle, PX_X)
                SetUnitY(mj.handle, PX_Y)
              end)
            end
          end
        end
      })
    end
    return true
  else
    if gun2 == ITEM_KONG then
      u:sendmessage("枪支弹药不足")
      u:deldata("是否射击")
    elseif GetItemCharges(gun2) == 0 then
      u:sendmessage("枪支弹药不足")
      u:deldata("是否射击")
    end
    return false
  end
end

local function shootcount(gun, u, sy, skill, x, y, jd, issingle)
  local guntype = GetItemTypeId(gun)
  local snd = GetData(guntype, "射击音效")
  local rpm = GetData(guntype, "RPM")
  local sc = GetData(guntype, "有效射程")
  local shxz = GetData(guntype, "伤害修正")
  local jdxz = GetData(guntype, "角度修正")
  local dxrl = GetData(guntype, "弹匣容量")
  local xhzd = GetData(guntype, "消耗子弹")
  local sfxh = GetData(guntype, "是否循环")
  local ctcs = GetData(guntype, "穿透次数")
  local ctsj = GetData(guntype, "穿透衰减")
  local lx = GetData(guntype, "枪械类型")
  local dylx = GetData(gun, "装备弹药") or S2ID("I0J4")
  local sjsm = GetData(dylx, "弹片数")
  local sh = GetData(dylx, "伤害")
  local shlx = GetData(dylx, "伤害阶级")
  if guntype == Guns["光之剑超新星"] then
    sjsm = 1
    sh = 1500
    shlx = 1
  end
  if guntype == Guns["演算宝珠"] then
    sjsm = 1
    sh = 5000
    shlx = 5
    ctcs = 999
    ctsj = 0.75
  end
  if guntype == Guns["魔弹"] then
    sjsm = 1
    local mp = u:getmp()
    u:curemp(-0.25 * mp)
    sh = 0.1 * u:getgold() * 34 + mp * 0.25 * 5000
    sh = sh * 1.5
    shlx = 4
  end
  if guntype == Guns["丧钟"] then
    sjsm = 1
    sh = u:getallattri() * 333 + u:getstate("外域变异") * 6280 + u:getdata("愚者-诡秘计数") * 11111
    shlx = 1
  end
  if u:hasdata("抵近射击-射击中") then
    xhzd = 0
    if lx == 0 then
      snd = deagle_1
      rpm = 60
      sc = 2250
      sjsm = 1
      shxz = 1
      jdxz = 0.5
      sfxh = false
      ctcs = 3
      ctsj = 0.5
      sh = 5000
      shlx = 2
      lx = 8
    end
  end
  if u:hasdata("缇娜-沙漠之鹰") then
    snd = deagle_1
    rpm = 60
    sc = 2250
    sjsm = 1
    xhzd = 0
    shxz = 1
    jdxz = 0.5
    sfxh = false
    ctcs = 999
    ctsj = 0.5
    sh = 20000 + 800 * u:getlevel()
    if u:hasdata("缇娜-沙漠之鹰解构者") then
      ctsj = 0.95
      shxz = 1.25
      sc = 2750
      sh = sh * (1 + u:getdata("沙漠之鹰-伤害提升"))
    end
    if u:hasdata("缇娜-沙漠之鹰枪斗术") then
      sh = 2500 + 100 * u:getlevel() + 100 * u:getagi()
    end
    shlx = 5
    lx = 8
  end
  local juji = false
  if lx == 3 then
    local kj
    if u:hasdata("狙击模式-开启") then
      kj = true
    else
      kj = false
    end
    juji = true
    if kj then
      sc = GetData(guntype, "开镜射程")
      shxz = GetData(guntype, "开镜修正")
      jdxz = 0
    end
  end
  if u:hasdata("贝洛妮卡-不碎的花") then
    local add = 0.25 + 0.01 * u:getlevel()
    if lx ~= 4 then
      add = add * 0.5
    end
    sh = sh * (1 + add)
  end
  if 0 < GetData(gun, "枪械-枪械等级") then
    sh = sh * GetData(gun, "枪械-枪械等级倍率")
  end
  local mk_xg, lv_xg = ReturnGunMokuaiData(gun, "下挂")
  local mk_dx, lv_dx = ReturnGunMokuaiData(gun, "弹匣")
  local mk_qk, lv_qk = ReturnGunMokuaiData(gun, "枪口")
  local zu = {
    "雷",
    "火",
    "冰",
    "暗",
    "光",
    "水"
  }
  for index, sx in ipairs(zu) do
    if mk_dx == "元素弹匣-" .. sx and mk_qk == "元素调制枪口-" .. sx then
      sh = sh * (1 + 0.15 * lv_dx)
    end
  end
  sh = sh * shxz
  if u:hasdata("夜子夜晚判定") then
    sc = sc + 1000
    if lx == 3 then
      jdxz = 0
    end
  end
  if u:hasdata("变异判定-漆黑的子弹") then
    jdxz = 0
    sc = sc + 20000
  end
  if u:hasdata("变异判定-法琦尔") then
    sh = sh * 1.25
  end
  if u:hasdata("职业判定-老兵") and u:getdata("擅长枪械") == lx then
    sh = sh * 1.25
  end
  if u:hasdata("语音-白洲梓") and u:hasdata("白洲梓-交火语音允许") then
    u:deldata("白洲梓-交火语音允许")
    local yx = {}
    yx[1] = Sound_Bzz_Shot_1
    yx[2] = Sound_Bzz_Shot_2
    yx[3] = Sound_Bzz_Shot_3
    local snd = yx[GetRandomInt(1, 3)]
    u:playsndmsg({
      str = GetData(snd, "绑定台词"),
      snd = snd,
      time = GetData(snd, "语音长度"),
      colors = {
        "F3D9F0",
        "FFFEFF",
        "8A6CAE"
      },
      isneedseen = true
    })
  end
  if u:hasdata("白洲梓-一切皆为虚无") and lx == 2 then
    sh = sh * 1.25
  end
  sh = sh + 100 * u:getdata("系统-累积等级")
  if u:hasdata("里三-狮子之弹") then
    local add = 0
    if u:hasdata("十二星弹-狮子之弹") then
      add = 350 * u:getdata("系统-累积等级")
    else
      add = 175 * u:getdata("系统-累积等级")
    end
    sh = sh + add
  end
  if u:hasdata("白洲梓-瞄准弱点伤害提升") then
    local add = 0
    if u:hasdata("白洲梓-战略整装") then
      add = 400 * u:getdata("系统-累积等级")
    else
      add = 200 * u:getdata("系统-累积等级")
    end
    if u:hasdata("枪械-白洲梓-虚无步枪") then
      add = add * 1.25
    end
    sh = sh + add
  end
  if u:hasdata("贝洛妮卡-毒刺炸裂强化") then
    sh = sh + 200 * u:getdata("系统-累积等级")
  end
  if u:hasdata("蕾米莉亚-红魔法") then
    sh = sh + 100 * u:getdata("系统-累积等级")
  end
  if u:hasdata("英雄-琪露诺") then
    local add = 125 * u:getdata("系统-累积等级")
    sh = sh + add
  end
  if u:hasdata("变异判定-猫头鹰因子") then
    sh = sh + 50 * u:getdata("系统-累积等级")
  end
  if u:hasdata("视界调律-子弹基础伤害提升") then
    sh = sh + u:getdata("视界调律-子弹基础伤害提升")
  end
  if u:hasdata("缇娜天赋-狙击精通") then
    if u:hasdata("狙击模式-开启") then
      sc = sc * 1.5
      sh = sh + 75 * u:getdata("系统-累积等级")
      if u:hasdata("缇娜天赋-黑风") then
        sh = sh + 75 * u:getdata("系统-累积等级")
      end
    end
    if u:hasdata("缇娜天赋-狙击特化复核弹头") then
      sh = sh + 50 * u:getdata("系统-累积等级")
    end
  end
  local rpmxz = Correction_RPM[sy]
  rpmxz = rpmxz + u:getdata("伊塔-枪械RPM加成")
  if rpmxz <= 0.01 then
    rpmxz = 0.01
  end
  if mk_qk == "高速枪口" then
    rpmxz = rpmxz + 0.15 * lv_qk
  end
  if mk_dx == "轻弹匣" then
    rpmxz = rpmxz + 0.1 * lv_dx
  end
  if mk_xg == "射速模块" then
    rpmxz = rpmxz + 0.1 * lv_xg
  end
  if guntype == Guns["演算宝珠"] then
    u:setskillcd("A1EY", 0.75 / rpmxz)
  end
  local scxz = Correction_Range[sy]
  if u:hasdata("变异判定-漆黑的子弹") and lx == 3 then
    scxz = scxz + 5
  end
  local qxshxz = 1
  if u:hasdata("变异判定-尤格索托斯") and not u:hasdata("妖梦皮肤-渎白之渊") and 0 < u:getdata("尤格索托斯-聚合时空伤害") then
    qxshxz = qxshxz + u:getdata("尤格索托斯-聚合时空伤害") * 0.1
    u:setdata("尤格索托斯-聚合时空伤害", 0)
  end
  if mk_xg == "射程模块" then
    scxz = scxz + 0.15 * lv_xg
  end
  rpm = 1 / (rpm * rpmxz / 60)
  if rpm <= 0 then
    rpm = 0.01
  end
  sc = sc * scxz
  sh = sh * qxshxz
  if sh <= 0 then
    sh = 0
  end
  jdxz = jdxz * Correction_Angle[sy]
  if mk_xg == "瞄准模块" then
    jdxz = jdxz * (1 - 0.33 * lv_xg)
  end
  if u:hasdata("缇娜天赋-狙击特化复核弹头") then
    ctsj = ctsj + (1 - ctsj / 2)
  end
  local args = {
    u = u,
    skill = skill,
    gun = gun,
    sc = sc,
    rpm = rpm,
    xhzd = xhzd,
    sjsm = sjsm,
    sfxh = sfxh,
    snd = snd,
    sh = sh,
    shlx = shlx,
    issingle = false,
    x = x,
    y = y,
    jd = jd,
    jdxz = jdxz,
    ctsj = ctsj,
    ctcs = ctcs
  }
  return args
end

local function shallowCopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == "table" then
    copy = {}
    for orig_key, orig_value in pairs(orig) do
      copy[orig_key] = orig_value
    end
  else
    copy = orig
  end
  return copy
end

local function lxhd(u, args)
  local gl = 10
  if u:hasdata("铃仙-幻弹强化") then
    gl = 100
  end
  if GetRandom100(gl) then
    local txsh = args.sh
    if u:hasdata("铃仙-超短脑波") then
      txsh = txsh * 1.5
    end
    ac.wait(150, function()
      local args2 = shallowCopy(args)
      args2.txsh = txsh
      args2.islxhd = true
      args2.xhzd = 0
      args2.shlx = 6
      u:setdata("铃仙-幻弹射击")
      shootact(args2)
      u:deldata("铃仙-幻弹射击")
    end)
    play_shadow_slow_series(u, {
      act = "attack",
      x = args.x,
      y = args.y,
      count = 1,
      interval = 0.03,
      main_speed = 1,
      wait_time = 0,
      r = 255,
      g = 255,
      b = 255,
      fade_sub = 5,
      noact = true,
      no_freeze = true
    })
    if u:hasdata("铃仙-疯狂回声") then
      do
        local x2 = u:getdata("开火点X")
        local y2 = u:getdata("开火点Y")
        local x = args.x
        local y = args.y
        if not (x2 and y2 and x) or not y then
          return
        end
        local jd = AngleXY(x2, y2, x, y)
        local dis = DistanceXY(x2, y2, x, y)
        x2, y2 = PolarXY(x2, y2, dis, jd + 180)
        ac.wait(150, function()
          local args2 = shallowCopy(args)
          args2.x = x2
          args2.y = y2
          args2.jd = jd
          args2.txsh = txsh
          args2.islxhd = true
          args2.xhzd = 0
          args2.shlx = 6
          u:setdata("铃仙-幻弹射击")
          shootact(args2)
          u:deldata("铃仙-幻弹射击")
        end)
        play_shadow_slow_series(u, {
          act = "attack",
          x = x2,
          y = y2,
          count = 1,
          interval = 0.03,
          main_speed = 1,
          wait_time = 0,
          r = 255,
          g = 255,
          b = 255,
          fade_sub = 5,
          noact = true,
          extra_angle = 180,
          no_freeze = true
        })
      end
    end
  end
end

function gunshoot(unit, skill, x2, y2, issingle)
  local u = getunit(unit)
  local sy = u.ownerid
  local x1, y1 = u:getxy()
  local jd
  if not u:hasdata("抵近射击-射击中") then
    x2 = x2 + GetRandomReal(-1, 1)
    y2 = y2 + GetRandomReal(-1, 1)
    u:setdata("开火点X", x2)
    u:setdata("开火点Y", y2)
    jd = AngleXY(x1, y1, x2, y2)
    SetUnitFacing(u.handle, jd)
  else
    jd = AngleXY(x1, y1, x2, y2)
  end
  x2, y2 = PolarXY(x1, y1, 50, jd)
  local zbqz
  if u.type == HeroType["铃仙"] then
    zbqz = u:getdata("专属枪支")
  else
    zbqz = u:getdata("装备枪支")
  end
  if u:hasdata("缇娜-沙漠之鹰") then
    if u:ishasitem("I01G") then
      zbqz = u:getitem("I01G")
    end
    if u:ishasitem("I0DH") then
      zbqz = u:getitem("I0DH")
    end
  end
  local fzqz = u:getdata("辅助枪支")
  local x3, y3
  if fzqz ~= ITEM_KONG then
    x2, y2 = PolarXY(x2, y2, 20, jd + 90)
    x3, y3 = PolarXY(x2, y2, -40, jd + 90)
  end
  u:setdata("霰弹装弹", false)
  u:setdata("是否射击")
  if not u:hasdata("免疫射击取消") then
    u:settimedata("免疫射击取消", 0.2)
  end
  if u:hasdata("无影剑-释放中") then
    u:setdata("无影剑-结束标记")
  end
  if u:hasdata("神器判定-开枪还击") and not u:hasdata("开枪还击音效冷却") then
    u:playseensound(Sound_Tuanzhang_02)
    u:settimedata("开枪还击音效冷却", 10)
  end
  local args = shootcount(zbqz, u, sy, skill, x2, y2, jd, false)
  if issingle then
    if u:hasdata("白洲梓-瞄准弱点伤害提升") and GetItemCharges(zbqz) > 0 then
      Effectcreate("war3mapImported\\298caea93f1af5d3.mdl", x1, y1, 0, 0.5, 40, jd, nil, nil, 2)
    end
    if u:hasdata("枪械-加斯尔豺狼") or u:hasdata("枪械-加斯尔豺狼-蕾米强化") then
      local xx1, yy1 = PolarXY(x2, y2, 20, jd + 90)
      local xx2, yy2 = PolarXY(x2, y2, -40, jd + 90)
      if u:getdata("加斯尔豺狼-顺序") == 1 then
        x2, y2 = xx1, yy1
      else
        x2, y2 = xx2, yy2
      end
    end
    args.x = x2
    args.y = y2
    local b = shootact(args)
    if b then
      if u:hasdata("加斯尔豺狼-蕾米强化-装备") then
        u:changemaxhp(-1)
        if not u:hasdata("加斯尔豺狼-位移") then
          ac.wait(1, function()
            u:settimedata("加斯尔豺狼-位移", 0.5)
          end)
        end
      end
      if u.type == HeroType["铃仙"] then
        lxhd(u, args)
      end
    end
  else
    local xx = u:getdata("开火点X")
    local yy = u:getdata("开火点Y")
    local lt = 0
    ac.loop(args.rpm * 1000, function(t)
      local b = true
      if not (xx == u:getdata("开火点X") and yy == u:getdata("开火点Y") and u:hasdata("是否射击")) or u:getdata("枪支换弹") == true or u:hasbuff("暂停") or u:hasbuff("眩晕") or not u:isalive() then
        b = false
      end
      if not args.sfxh or not b then
        t:remove()
        return
      end
      x1, y1 = u:getxy()
      x2 = u:getdata("开火点X")
      y2 = u:getdata("开火点Y")
      if not x2 or not y2 then
        t:remove()
        return
      end
      jd = AngleXY(x1, y1, x2, y2)
      lt = lt + args.rpm
      if 0.1 <= lt then
        lt = 0
        SetUnitFacing(unit, jd)
      end
      x2, y2 = PolarXY(x1, y1, 50, jd)
      if fzqz ~= ITEM_KONG then
        x2, y2 = PolarXY(x2, y2, 20, jd + 90)
        x3, y3 = PolarXY(x2, y2, -40, jd + 90)
      end
      args.x = x2
      args.y = y2
      local b2 = shootact(args)
      if b2 and u.type == HeroType["铃仙"] then
        lxhd(u, args)
      end
    end)
    if fzqz ~= ITEM_KONG then
      u:setdata("是否射击")
      if not u:hasdata("免疫射击取消") then
        u:settimedata("免疫射击取消", 0.2)
      end
      do
        local args = shootcount(fzqz, u, sy, skill, x2, y2, jd, false)
        local xx = u:getdata("开火点X")
        local yy = u:getdata("开火点Y")
        local lt = 0
        ac.loop(args.rpm * 1000, function(t)
          local b = true
          if not (xx == u:getdata("开火点X") and yy == u:getdata("开火点Y") and u:hasdata("是否射击")) or u:getdata("辅助换弹") == true or u:hasbuff("暂停") or u:hasbuff("眩晕") or not u:isalive() then
            b = false
          end
          if not args.sfxh or not b then
            t:remove()
            return
          end
          x1, y1 = u:getxy()
          x2 = u:getdata("开火点X")
          y2 = u:getdata("开火点Y")
          if not x2 or not y2 then
            t:remove()
            return
          end
          jd = AngleXY(x1, y1, x2, y2)
          lt = lt + args.rpm
          if 0.1 <= lt then
            lt = 0
            SetUnitFacing(unit, jd)
          end
          x2, y2 = PolarXY(x1, y1, 50, jd)
          x2, y2 = PolarXY(x2, y2, -20, jd + 90)
          args.x = x2
          args.y = y2
          local b2 = shootact(args)
          if b2 and u.type == HeroType["铃仙"] then
            lxhd(u, args)
          end
        end)
      end
    end
  end
end

function gunammude(unit, gun, count)
  local u = getunit(unit)
  local gl = 0
  if u:hasdata("变异判定-秋穰子") then
    gl = math.max(gl, 7)
  end
  if u:hasdata("十二星弹-双子座激活") then
    gl = math.max(gl, 25)
  end
  if u:hasdata("贝洛妮卡-家政专家") then
    gl = math.max(gl, 25)
  end
  if u:hasdata("变异判定-伊塔") then
    gl = math.max(gl, u:getdata("伊塔-不消耗子弹概率"))
  end
  if u:hasdata("变异判定-枪之恶魔") then
    gl = math.max(gl, 50)
  end
  if u:hasdata("铃仙-暗形态") then
    gl = math.max(gl, 50)
  end
  if Keyan_Dunzhongqiangxie then
    count = count * 2
  end
  if GetRandom100(gl) then
  else
    ChangeItemCount(gun, -1 * count)
  end
  SetItemCharges(gun, GetItemCharges(gun))
end

function ammureplace(unit, gun)
  local u = getunit(unit)
  local guntype = GetItemTypeId(gun)
  local lx = GetData(guntype, "枪械类型")
  local model = "Abilities\\Weapons\\RocketMissile\\RocketMissile.mdl"
  local modelname = "普通子弹"
  local modelsize = 0.35
  if lx == 4 then
    model = "Abilities\\Weapons\\Rifle\\RifleImpact.mdl"
    modelsize = 0.5
  end
  local dylx = GetData(gun, "装备弹药")
  if dylx == S2ID("I0FW") then
    model = "Abilities\\Weapons\\ShadowHunterMissile\\ShadowHunterMissile.mdl"
    modelname = "机巧弹"
    modelsize = 0.75
  end
  if dylx == S2ID("I0FU") then
    model = "Abilities\\Weapons\\LichMissile\\LichMissile.mdl"
    modelname = "水晶弹"
    modelsize = 1.0
  end
  if dylx == S2ID("I0FV") then
    model = "Abilities\\Weapons\\Mortar\\MortarMissile.mdl"
    modelname = "爆裂弹"
    modelsize = 1.0
  end
  if dylx == S2ID("I0DW") then
    model = "war3mapImported\\Tile_1218 (2).mdx"
    modelname = "星光弹"
    modelsize = 1.0
  end
  if dylx == S2ID("I0FT") then
    model = "Abilities\\Weapons\\snapMissile\\snapMissile.mdl"
    modelname = "叶绿弹"
    modelsize = 1.0
  end
  if dylx == S2ID("I0DX") then
    model = "war3mapImported\\Tile_1218 (1).mdx"
    modelname = "幻想虚弹"
    modelsize = 1.0
  end
  if dylx == S2ID("I05L") then
    model = "Abilities\\Spells\\Items\\OrbCorruption\\OrbCorruptionMissile.mdl"
    modelname = "达姆弹-黑牙"
    modelsize = 2.0
  end
  if dylx == S2ID("I06C") then
    model = "Abilities\\Weapons\\IllidanMissile\\IllidanMissile.mdl"
    modelname = "劳伯奈斯化武弹"
    modelsize = 0.75
  end
  if dylx == S2ID("I066") then
    model = "Abilities\\Spells\\Undead\\OrbOfDeath\\OrbOfDeathMissile.mdl"
    modelname = "螺旋塔弹"
    modelsize = 0.75
  end
  if dylx == S2ID("I06B") then
    model = "Abilities\\Weapons\\SpiritOfVengeanceMissile\\SpiritOfVengeanceMissile.mdl"
    modelname = "塔纳活性能量弹"
    modelsize = 0.75
  end
  if dylx == S2ID("I0BP") then
    model = "Abilities\\Weapons\\ChimaeraAcidMissile\\ChimaeraAcidMissile.mdl"
    modelname = "腐朽弹"
    modelsize = 0.75
  end
  if u:hasdata("白洲梓-瞄准弱点伤害提升") or u:hasdata("贝洛妮卡-毒刺炸裂强化") then
    model = "war3mapImported\\Sinon01_32.mdl"
    modelsize = 1.0
  end
  if u:hasdata("变异判定-阿露希") then
    model = "Tx_Aluxi_01.mdl"
    modelname = "元弹"
  end
  if HasData(gun, "法琦尔-恶魔制造") then
    model = "war3mapImported\\Tx_Niuqu_Fqe_03.mdl"
    modelsize = 2.0
  end
  if u:ishasskill("S021") or u:ishasskill("A0T0") then
    model = "war3mapImported\\Big_ICM_Blue.mdl"
    modelname = "青空弹"
    modelsize = 0.5
  end
  if u:hasdata("变异判定-Bloo") then
    model = "war3mapImported\\blue_fire_explosion.mdl"
    modelname = "蓝炎弹"
    modelsize = 0.5
  end
  if u:hasdata("变异判定-宵暗") and (GetTimeOfDay() >= 22.0 or 2.0 >= GetTimeOfDay()) then
    model = "Abilities\\Weapons\\AvengerMissile\\AvengerMissile.mdl"
    modelname = "宵暗弹"
    modelsize = 0.5
  end
  if u:hasdata("赫萝-伟力苹果强化") or u:hasdata("赫萝-伟力银苹果强化") or u:hasdata("赫萝-伟力金苹果强化") then
    model = "war3mapImported\\ukyojuzi.mdl"
    modelname = "苹果弹"
    modelsize = 2.0
  end
  if u:hasdata("Yang-抵近射击弹幕") then
    model = "Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl"
    modelsize = 1.0
  end
  if u:hasdata("Blake-抵近射击弹幕") then
    model = "Abilities\\Weapons\\BlackKeeperMissile\\BlackKeeperMissile.mdl"
    modelsize = 1.0
  end
  if u:hasdata("Ruby-抵近射击弹幕") then
    model = "Abilities\\Weapons\\SerpentWardMissile\\SerpentWardMissile.mdl"
    modelsize = 1.0
  end
  if u:hasdata("Weiss-抵近射击弹幕") then
    model = "Abilities\\Weapons\\DragonHawkMissile\\DragonHawkMissile.mdl"
    modelsize = 1.0
  end
  if u:ishasskill("A0VE") or u:hasdata("蕾米莉亚-完全觉醒") then
    model = "war3mapImported\\batsonly.mdl"
    modelname = "芙兰觉醒弹"
    modelsize = 1.75
  end
  if u:hasdata("恶灵附身-附身状态") then
    model = "war3mapImported\\[TX] (869).mdl"
    modelname = "恶灵弹"
    modelsize = 1.0
  end
  if u:hasdata("潘迪-天使化") then
    model = "war3mapImported\\[TX] (869).mdl"
    modelname = "强化恶灵弹"
    modelsize = 1.0
  end
  if u:hasdata("变异判定-迷失之蝶") then
    model = "ATX\\[ATxNew]Tile_25.mdl"
    modelname = "虚数弹"
    modelsize = 0.5
  end
  if u:hasdata("里三-狮子之弹") then
    model = "tx_gmdl1.mdx"
    modelname = "狮子之弹"
    modelsize = 1
  end
  if u:hasdata("变异判定-古明地恋") then
    model = "Lianlian_Tx_Toushewu.mdx"
    modelname = "蔷薇弹"
    modelsize = 1.5
  end
  if u:hasdata("愚者-占卜师") then
    model = "Tx_Yuzhe_03.mdx"
    modelname = "占卜师弹"
    modelsize = 0.5
  end
  if u:hasdata("变异判定-老男人") then
    model = "Lnr_01_Zidan.mdx"
    modelname = "炼金弹"
    modelsize = 1
  end
  if u:hasdata("变异判定-克萝蒂亚") then
    model = "Kldy_100.mdl"
    modelsize = 1
  end
  if u:hasdata("神化判定-千子村正") then
    model = "effect\\[Tx]Qzcz_01.mdl"
    modelname = "焰弹"
    modelsize = 1.5
  end
  if u:hasdata("白-精细操作") then
    model = "AATX\\[AATxNew]Tile42.mdl"
    modelname = "空间弹"
    modelsize = 1.0
  end
  if u:hasdata("琪露诺-冰袭方阵附加") then
    model = "4.26.Ice (9).mdl"
    modelname = "冰袭方阵弹"
    modelsize = 1.0
  end
  if u:hasdata("变异判定-队长禁忌") then
    model = "0466.mdl"
    modelsize = 1.0
  end
  if u:hasdata("魔力构成模式-星光锁定") or u:ishasskill("A0TZ") or u:getdata("星神认证") == true or u:getdata("魔力构成模式-星尘") == true and u:getdata("星神") == true then
    model = "war3mapImported\\[AKE]war3AKE.com - 7346841038772226188179609.mdl"
    modelname = "星尘弹"
    modelsize = 0.75
  end
  if dylx == S2ID("I069") then
    model = "war3mapimported\\blackhole.mdl"
    modelname = "湮灭弹"
    modelsize = 1.0
  end
  if u:hasdata("W-改装榴弹") then
    model = "Abilities\\Weapons\\Mortar\\MortarMissile.mdl"
    modelname = "改装榴弹"
    modelsize = 1.0
    u:deldata("W-改装榴弹")
  end
  return model, modelsize, modelname
end

function ammuadd(unit, gun, unify)
  local u = getunit(unit)
  local mj = getunit(unify)
  local name = mj:getdata("弹幕-子弹名字")
  local dylx = GetData(gun, "装备弹药")
  local guntype = GetItemTypeId(gun)
  local lx = GetData(guntype, "枪械类型")
  local sy = u.ownerid
  mj:setdata("元素触发概率", GetData(guntype, "元素触发概率"))
  if name == "恶灵弹" then
    mj:setdata("弹幕类型-恶灵弹")
    mj:setdata("弹幕-伤害", 250 * (u:getlevel() + 20 * u:getdata("恶灵强度")))
  end
  local add = Correction_Gun_Bullet[sy]
  local st = StexiaoFunc({
    text = "子弹创建时效果",
    unit = unit,
    u = u,
    mj = mj,
    sy = sy,
    name = name,
    dylx = dylx,
    guntype = guntype,
    lx = lx,
    add = add
  })
  add = st.add
  local mk_xg, lv_xg = ReturnGunMokuaiData(gun, "下挂")
  if mk_xg == "暴击模块" then
    mj:setdata("模块-暴击模块提升", lv_xg)
  end
  if mk_xg == "连击模块" then
    mj:setdata("模块-连击模块", lv_xg)
  end
  if lx == 3 then
    mj:setdata("狙击枪子弹")
    add = add + Correction_Gun_Juji[sy]
  end
  if lx == 4 then
    mj:setdata("霰弹枪子弹")
    add = add + Correction_Gun_Xiandan[sy]
  end
  if lx == 8 then
    add = add + Correction_Gun_Pistol[sy]
  end
  if guntype == Guns["丧钟"] then
    mj:setdata("丧钟-丧钟弹")
  end
  if u:hasdata("英雄-白洲梓") then
    mj:setdata("白洲梓-瞄准弱点")
  end
  if u:hasdata("铃仙-幻弹射击") then
    mj:setdata("铃仙-幻弹射击")
  end
  if u:hasdata("缇娜-沙漠之鹰") then
    mj:setdata("缇娜-沙漠之鹰")
    if u:hasdata("缇娜-沙漠之鹰枪斗术") then
      mj:setdata("缇娜-沙漠之鹰枪斗术")
    end
    if u:hasdata("缇娜-沙漠之鹰解构者") then
      mj:setdata("缇娜-沙漠之鹰解构者")
      mj:setdata("缇娜-沙漠之鹰解构者提升属性")
    end
  end
  if u:hasdata("变异判定-魔术师杀手") then
    mj:setdata("魔术师杀手-起源弹")
    if u:hasdata("魔术师杀手-切嗣强化") then
      mj:setdata("魔术师杀手-强化起源弹")
    end
  end
  if u:hasdata("琪露诺-绚烂冰花") then
    mj:setdata("琪露诺-绚烂冰花附伤")
  end
  if u:hasdata("变异判定-冰之狙击手") then
    mj:setdata("诗乃-幽灵子弹")
    if lx == 8 then
      mj:setdata("诗乃-幽灵手枪")
    end
    if lx == 8 or lx == 3 then
      mj:setdata("诗乃-幽灵杀敌")
    end
    if u:hasdata("诗乃-第一发") then
      add = add + 1
      mj:setdata("诗乃-第一发暴击率")
      if Correction_Gun[sy] >= 2.5 then
        mj:setdata("诗乃-第一发爆伤")
      end
      u:deldata("诗乃-第一发")
    end
  end
  if u:hasdata("枪械-竞争者") then
    mj:setdata("竞争者-断罪者魔弹")
    add = add + 0.25
  end
  if u:hasdata("伊丽莎白-黄金舰队") then
    add = add + 0.15
  end
  if u:hasdata("枪械-加斯尔豺狼") then
    if u:getdata("加斯尔豺狼-顺序") == 1 then
      u:setdata("加斯尔豺狼-顺序", 2)
      mj:setdata("加斯尔豺狼-洗礼银弹")
    else
      u:setdata("加斯尔豺狼-顺序", 1)
      mj:setdata("加斯尔豺狼-水银合弹")
      add = add + 3
    end
  end
  if u:hasdata("枪械-加斯尔豺狼-蕾米强化") then
    mj:setdata("加斯尔豺狼-附骨燃殇")
    if u:getdata("加斯尔豺狼-顺序") == 1 then
      u:setdata("加斯尔豺狼-顺序", 2)
      mj:setdata("加斯尔豺狼-血咒银弹")
    else
      u:setdata("加斯尔豺狼-顺序", 1)
      mj:setdata("加斯尔豺狼-水银合弹")
      add = add + 0.14
    end
  end
  if u:hasdata("视界调律-子弹伤害提升") then
    add = add + u:getdata("视界调律-子弹伤害提升")
  end
  if u:hasdata("六面-狮子面") and u:hasdata("付丧缘") then
    mj:changedata("弹幕-穿透次数", 1)
    add = add + 0.1 * (Correction_Gun[sy] - 1)
  end
  mj:changedata("弹幕-伤害", 1 + add, 1)
  if u:hasdata("赫萝-伟力苹果强化") then
    mj:changedata("弹幕-伤害", 3000)
  end
  if u:hasdata("变异判定-星虹之眸") then
    mj:setdata("星虹之眸-子弹附伤")
  end
  if u:hasdata("变异判定-伊芙") then
    mj:setdata("伊芙-星辰弹")
  end
  if u:hasdata("变异判定-枪之恶魔") then
    mj:setdata("枪之恶魔-子弹附伤")
  end
  if name == "白洲梓-死亡弹" then
    mj:setdata("白洲梓-死亡弹")
  end
  if name == "白洲梓-射手弹" then
    mj:setdata("白洲梓-射手弹")
  end
  if name == "幻影霰弹" or name == "幻影子弹" then
    if u:hasdata("铃仙-超短脑波") then
      mj:setdata("超短脑波无视抗性")
    end
    if u:hasdata("铃仙-双重疯狂") then
      mj:setdata("双重疯狂混乱")
    end
  end
  if HasData(gun, "法琦尔-恶魔制造") then
    mj:setdata("法琦尔-恶魔制造")
  end
  if u:hasdata("变异判定-法琦尔") then
    mj:setdata("法琦尔-黑暗之力")
  end
  if dylx == Bullets["伯奈利军弹"] then
    mj:setdata("霰弹")
  end
  if dylx == Bullets["爆裂弹"] then
    mj:setdata("爆裂弹")
  end
  if dylx == Bullets["水晶弹"] then
    mj:setdata("水晶弹")
  end
  if dylx == Bullets["幻想虚弹"] then
    mj:setdata("幻想虚弹")
  end
  if dylx == Bullets["叶绿弹"] then
    mj:setdata("叶绿弹")
  end
  if dylx == Bullets["星光弹"] then
    mj:setdata("星光弹")
  end
  if dylx == Bullets["达姆弹-黑牙"] then
    mj:setdata("达姆弹-黑牙")
  end
  if dylx == Bullets["贯彻弹"] then
    mj:setdata("贯彻弹")
  end
  if dylx == Bullets["塔纳活性能量弹"] then
    mj:setdata("活性弹伤害")
  end
  if dylx == Bullets["劳伯奈利斯化武弹"] then
    mj:setdata("化武弹")
  end
  if dylx == Bullets["S02-SU弹"] then
    mj:setdata("眩晕弹")
  end
  if dylx == Bullets["螺旋塔弹"] then
    mj:changedata("弹幕-穿透次数", 2)
  end
  if dylx == Bullets["腐朽弹"] then
    mj:setdata("腐朽弹")
  end
  if name == "空间弹" then
    mj:changedata("弹幕-穿透次数", 2)
  end
  if name == "焰弹" then
    mj:setdata("弹幕类型-焰弹")
    mj:changedata("弹幕-穿透次数", 1)
    mj:setdata("弹幕-穿透衰减", 1 - (1 - mj:getdata("弹幕-穿透衰减") / 2))
  end
  if name == "宵暗弹" then
    mj:changedata("弹幕-射速", 1000)
    if mj:getdata("弹幕-穿透次数") == 1 then
      mj:changedata("弹幕-穿透次数", 1)
    end
  end
  if name == "虚数弹" then
    mj:setdata("弹幕类型-虚数弹")
    mj:changedata("弹幕-穿透次数", 2)
  end
  if name == "强化恶灵弹" then
    mj:setdata("弹幕类型-强化恶灵弹")
  end
  if name == "改装榴弹" then
    mj:setdata("弹幕类型-改装榴弹")
    mj:setdata("弹幕-穿透次数", 1)
  end
  if name == "演算弹" then
    mj:setdata("弹幕-魔力子弹")
    table.insert(Group_Molizidan, mj)
  end
  if name == "魔弹" then
    mj:setdata("弹幕特效-魔弹")
  end
  if u:hasdata("变异判定-漆黑的子弹") then
    mj:setdata("音爆狂袭")
  elseif u:hasdata("变异判定-猫头鹰因子") and lx == 3 then
    mj:setdata("音爆云")
  end
  if u:hasdata("变异判定-尤格索托斯") then
    mj:changedata("弹幕-穿透次数", 2)
  end
  if u:hasdata("赫萝-伟力银苹果强化") then
    mj:setdata("赫萝-银苹果子弹")
  end
  if u:hasdata("赫萝-伟力金苹果强化") then
    mj:setdata("赫萝-金苹果子弹")
  end
  if u:hasdata("变异判定-小天鹅") then
    u:curemp(0.02 * u:getmp())
  end
  if u:getdata("Gold Experience") == true then
    mj:setdata("弹幕特效-黄金体验")
  end
  if u:hasdata("变异判定-古明地恋") then
    mj:setdata("弹幕特效-蔷薇弹")
  end
  if u:hasdata("蕾米莉亚-红魔法") then
    mj:setdata("弹幕特效-红魔法")
  end
  if u:hasdata("蕾米莉亚-碎心") then
    mj:setdata("弹幕特效-碎心")
  end
  if u:ishasskill("A012") then
    mj:setdata("弹幕特效-十六夜飞刀")
  end
  if u:ishasskill("A0T0") then
    mj:setdata("弹幕特效-神奇料理青空")
  end
  if u:ishasskill("S021") then
    mj:setdata("弹幕特效-半透明魔法使")
  end
  if u:ishasskill("A0GL") or u:ishasskill("A0HX") or u:ishasskill("S021") then
    mj:setdata("弹幕特效-白羽风")
  end
  if u:ishasitem("I03I") then
    mj:setdata("弹幕特效-神奇料理")
  end
  mj:changedata("弹幕-伤害", add, 1)
  local sx
  if mj:hasdata("星光弹") and IsTimeNight() and u:hasdata("枪械-星光魔术师") then
    sx = "光"
  end
  if mj:hasdata("琪露诺-绚烂冰花附伤") then
    sx = "冰"
  end
  if u:hasdata("变异判定-尤格索托斯") or mj:hasdata("铃仙-幻弹射击") or u:hasdata("铃仙-幻胧月睨强化") then
    sx = "心灵"
  end
  if mj:hasdata("法琦尔-恶魔制造") then
    sx = "暗"
  end
  local mk_dx, lv_dx = ReturnGunMokuaiData(gun, "弹匣")
  local mk_qk, lv_qk = ReturnGunMokuaiData(gun, "枪口")
  local zu = {
    "雷",
    "火",
    "冰",
    "暗",
    "光",
    "水"
  }
  for index, v in ipairs(zu) do
    if mk_dx == "元素弹匣-" .. v then
      sx = v
    end
  end
  for index, v in ipairs(zu) do
    if mk_qk == "元素调制枪口-" .. v then
      sx = v
    end
  end
  if sx then
    mj:setdata("属性伤害", sx)
  end
end
