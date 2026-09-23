-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local g = CreateGroupLua()
local du, hero, dsh, dbs, kz, sy, ddx, ddy, dangle, dhj, dlx, dhxb

local function set()
  sy = du.ownerid
  hero = getunit(Hero[sy])
  dsh = hero:getdata("角色基础伤害")
  dbs = hero:getdata("角色伤害范围")
  ddx, ddy = du:getxy()
  dhxb = false
  if du:hasdata("魂符幻象") then
    dhxb = true
    dangle = hero:getdata("魂符角度")
    du:setface(dangle)
    if du:hasdata("大魂符") then
      dsh = dsh * hero:getdata("妖梦-大魂符伤害")
    else
      dsh = dsh * hero:getdata("妖梦-小魂符伤害")
    end
  else
    dangle = du:getface()
  end
  dhj = false
  dlx = "物理"
  if dhxb then
    dhj = true
    dlx = "灵力"
  end
  return dsh, dbs, ddx, ddy, dhj, dlx, dangle
end

local function jqzhf(u, skillstr)
  if u:hasdata("英雄-妖梦") then
    local add = 2.5
    local now = u:getdata("妖梦-剑气值")
    local max = u:getdata("妖梦-剑气值上限")
    if u:hasdata("妖梦天赋-天界剑") then
      add = add + 0.5
    end
    if skillstr == "ECA-Extra" then
      add = 0.25
    elseif skillstr == "DCAV-Extra" then
      add = 0.25
    elseif skillstr == "QCRV" then
      add = 2
    elseif skillstr == "ACRV" then
      add = 1
    elseif skillstr == "ACWQCV-Extra" then
      add = 0.5
    elseif skillstr == "ACWQCV" then
      add = 50
    elseif skillstr == "QCDWCDCV" then
      add = 100
      if u:hasdata("妖梦天赋-一念无量劫") then
        add = max
      end
    else
      if #skillstr == 1 then
        add = 1.5
      elseif skillstr:sub(-1) == "V" then
        add = 3
      end
      if u:hasdata("妖梦天赋-天界剑") then
        add = add + 0.5
      end
    end
    now = now + add
    if max <= now then
      now = max
    end
    u:setdata("妖梦-剑气值", now)
  end
end

local umskill = {
  A = function(u)
    du = u
    local sh, bs, x, y, hj, lx, angle = set()
    kz = 0.6
    if hero:hasdata("妖梦天赋-人神剑") then
      sh = sh * 2
      bs = bs * 2
      kz = kz * 2
    end
    u:animespeed(3)
    ac.wait(1, function()
      u:animeact(9)
    end)
    ac.wait(1000, function()
      u:animespeed(1)
    end)
    local mz = false
    local fw = 200 * bs
    for _, xq in ac.selector():in_rangexy(x, y, fw):is_enemy(u.handle):ipairs() do
      xq = getunit(xq)
      xq:groupadd(g)
      mz = true
    end
    if mz then
      jqzhf(u, "A")
    end
    ForGroupLuaNew(g, function(xq)
      xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
      DamageUnit({
        bj = "妖梦(机体)",
        unit = xq.handle,
        source = hero.handle,
        damage = sh,
        level = 1,
        type = lx,
        isvest = false,
        isattack = true,
        isnoarmor = hj,
        element = "无"
      })
      xq:buffset(hero.handle, kz, "僵直")
    end)
    GroupClearLua(g)
  end,
  F = function(u)
    du = u
    local sh, bs, x, y, hj, lx, angle = set()
    kz = 0.6
    if hero:hasdata("妖梦天赋-人神剑") then
      sh = sh * 2
      bs = bs * 2
      kz = kz * 2
    end
    u:animespeed(3)
    ac.wait(1, function()
      u:animeact(26)
    end)
    ac.wait(1000, function()
      u:animespeed(1)
    end)
    local mz = false
    local fw = 90 * bs
    x, y = PolarXY(x, y, 40, angle)
    for i = 1, 14 do
      x, y = PolarXY(x, y, 10, angle)
      for _, xq in ac.selector():in_rangexy(x, y, fw):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        xq:groupadd(g)
        mz = true
      end
    end
    if mz then
      jqzhf(u, "F")
    end
    ForGroupLuaNew(g, function(xq)
      xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
      DamageUnit({
        bj = "妖梦(机体)",
        unit = xq.handle,
        source = hero.handle,
        damage = sh,
        level = 1,
        type = lx,
        isvest = false,
        isattack = true,
        isnoarmor = hj,
        element = "无"
      })
      xq:buffset(hero.handle, kz, "僵直")
    end)
    GroupClearLua(g)
  end,
  E = function(u)
    du = u
    local sh, bs, x, y, hj, lx, angle = set()
    kz = 0.8
    if hero:hasdata("妖梦天赋-人神剑") then
      sh = sh * 2
      bs = bs * 2
      kz = kz * 2
    end
    u:animespeed(3)
    ac.wait(1, function()
      u:animeact(4)
    end)
    ac.wait(1000, function()
      u:animespeed(1)
    end)
    local mz = false
    local fw = 110 * bs
    x, y = PolarXY(x, y, 40, angle)
    for i = 1, 8 do
      x, y = PolarXY(x, y, 10, angle)
      for _, xq in ac.selector():in_rangexy(x, y, fw):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        xq:groupadd(g)
        mz = true
      end
    end
    if mz then
      jqzhf(u, "E")
    end
    ForGroupLuaNew(g, function(xq)
      xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
      DamageUnit({
        bj = "妖梦(机体)",
        unit = xq.handle,
        source = hero.handle,
        damage = 1.5 * sh,
        level = 1,
        type = lx,
        isvest = false,
        isattack = true,
        isnoarmor = hj,
        element = "无"
      })
      xq:buffset(hero.handle, kz, "僵直")
    end)
    GroupClearLua(g)
  end,
  R = function(u)
    du = u
    local sh, bs, x, y, hj, lx, angle = set()
    kz = 0.4
    if hero:hasdata("妖梦天赋-人神剑") then
      sh = sh * 2
      bs = bs * 2
      kz = kz * 2
    end
    u:animespeed(3)
    ac.wait(1, function()
      u:animeact(5)
    end)
    ac.wait(1000, function()
      u:animespeed(1)
    end)
    local mz = false
    local fw = 90 * bs
    x, y = PolarXY(x, y, 40, angle)
    for i = 1, 14 do
      x, y = PolarXY(x, y, 10, angle)
      for _, xq in ac.selector():in_rangexy(x, y, fw):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        xq:groupadd(g)
        mz = true
      end
    end
    if mz then
      jqzhf(u, "R")
    end
    ForGroupLuaNew(g, function(xq)
      xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
      DamageUnit({
        bj = "妖梦(机体)",
        unit = xq.handle,
        source = hero.handle,
        damage = 1.25 * sh,
        level = 1,
        type = lx,
        isvest = false,
        isattack = true,
        isnoarmor = hj,
        element = "无"
      })
      xq:buffset(hero.handle, kz, "僵直")
    end)
    GroupClearLua(g)
  end,
  QCDWCD = function(u)
    du = u
    local sh, bs, x, y, hj, lx, angle = set()
    if u:hasdata("妖梦天赋-天界剑") then
      ChangeValue(Hero_Tili, sy, 2)
    end
    u:playsound(Youmu_WCDQCD_Start)
    u:effectadd("Abilities\\Spells\\Human\\ControlMagic\\ControlMagicTarget.mdl", "overhead", 1)
    u:animespeed(3)
    ac.wait(1, function()
      u:animeact(21)
    end)
    ac.wait(1000, function()
      u:animespeed(1)
    end)
    if Boolean_Jinselingyu then
      u:setdata("炯眼剑判定时间", 0.3)
    else
      u:setdata("炯眼剑判定时间", 0.4)
    end
  end,
  WCF = function(u)
    du = u
    local sh, bs, x, y, hj, lx, angle = set()
    local txsh = 1.75 * sh
    if u:hasdata("妖梦天赋-天界剑") then
      ChangeValue(Hero_Tili, sy, 2)
    end
    u:animespeed(5)
    ac.wait(1, function()
      u:animeact(6)
    end)
    ac.wait(201, function()
      u:animespeed(5)
    end)
    ac.wait(400, function()
      u:animespeed(1)
    end)
    Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
    local xq = getunit(BOSS_DEATH)
    local x2, y2 = PolarXY(x, y, 350, angle)
    local x4, y4 = PolarXY(x, y, 450, angle)
    local jumptime = 0.3
    unitjump({
      unit = u.handle,
      time = jumptime,
      distance = 250,
      height = 100,
      angle = angle,
      isfly = true
    })
    local mz = false
    local fw = 350 * bs
    for _, xq in ac.selector():in_rangexy(x, y, fw):is_enemy(u.handle):ipairs() do
      xq = getunit(xq)
      DamageUnit({
        bj = "妖梦(机体)",
        unit = xq.handle,
        source = hero.handle,
        damage = txsh,
        level = 1,
        type = lx,
        isvest = false,
        isattack = true,
        isnoarmor = hj,
        element = "无"
      })
      mz = true
      xq:buffset(hero.handle, 2, "眩晕")
      local x3, y3 = xq:getxy()
      local angle2 = AngleXY(x3, y3, x4, y4)
      local dis = DistanceXY(x3, y3, x4, y4)
      unitjump({
        unit = xq.handle,
        time = jumptime,
        distance = dis,
        height = 300,
        angle = angle2,
        isfly = true
      })
    end
    do
      local a = angle + 30
      local txxs
      if u:getdata("umpf_paopao") == true then
        txxs = "war3mapImported\\umpf_paopao_baozha_yumao.mdx"
      else
        txxs = "war3mapImported\\senbonzakurapart.mdx"
      end
      local cang = angle - 110
      local r = 100
      local ctime = 0
      local height = 0
      ac.loop(20, function(timer)
        ctime = ctime + 0.02
        if ctime <= 0.3 then
          r = r + 10
          cang = cang - 18
          x, y = u:getxy()
          local dx, dy = PolarXY(x, y, r, cang)
          height = height + 12
          EffectcreateArgs({
            effect = txxs,
            x = dx,
            y = dy,
            size = 1,
            height = height,
            zxz = GetRandomAngle(),
            animespeed = 1
          })
        else
          timer:remove()
        end
      end)
      local cang = angle - 90
      local r = 70
      local ctime = 0
      ac.loop(20, function(timer)
        ctime = ctime + 0.02
        if ctime <= 0.3 then
          r = r + 12
          cang = cang + 21
          x, y = u:getxy()
          local dx, dy = PolarXY(x, y, r, cang)
          height = height + 18
          EffectcreateArgs({
            effect = txxs,
            x = dx,
            y = dy,
            size = 1,
            height = height,
            zxz = GetRandomAngle(),
            animespeed = 1
          })
        else
          timer:remove()
        end
      end)
    end
    if mz then
      jqzhf(u, "WCF")
      u:playsound(Youmu_WCFCA_Ok)
      u:changedata("连携剑技使用次数", 1)
    else
      u:playsound(Youmu_WCFCA_Miss)
    end
  end,
  DCA = function(u)
    du = u
    local sh, bs, x, y, hj, lx, angle = set()
    if u:hasdata("妖梦天赋-天界剑") then
      ChangeValue(Hero_Tili, sy, 2)
    end
    u:playsound(Youmu_DCA_Start)
    u:animespeed(1)
    ac.wait(1, function()
      u:animeact(18)
    end)
    if u:getdata("umpf_paopao") == true then
      EffectcreateArgs({
        effect = "war3mapImported\\umpf_paopao_baozha2.mdx",
        x = x,
        y = y,
        size = 2,
        animespeed = 1
      })
    else
      u:effectadd("war3mapImported\\ThunderclapCaster.mdx", "origin")
    end
    local xq = getunit(BOSS_DEATH)
    local x4, y4 = PolarXY(x, y, 250, angle)
    local mz = false
    local fw = 512 * bs
    for _, xq in ac.selector():in_rangexy(x, y, 900):is_enemy(hero.handle):allow_unify():ipairs() do
      xq = getunit(xq)
      mz = true
      if xq:hasdata("系统-弹幕") then
        ChangeValue(Hero_Tili, sy, 2)
        xq:setdata("弹幕-生命值", 0)
        local dx, dy = xq:getxy()
        Effectcreate("Abilities\\Spells\\Human\\Polymorph\\PolyMorphTarget.mdl", dx, dy)
      else
        xq:buffset(hero.handle, 0.6, "眩晕")
        xq:buffset(hero.handle, 1.8, "僵直")
        DamageUnit({
          bj = "妖梦(机体)",
          unit = xq.handle,
          source = hero.handle,
          damage = 1 * sh,
          level = 1,
          type = lx,
          isvest = false,
          isattack = true,
          isnoarmor = hj,
          element = "无"
        })
        if hero:hasdata("妖梦天赋-畜趣剑") and not xq:hasdata("免疫击退效果") then
          xq:setxy(x4, y4)
        end
      end
    end
    if mz then
      jqzhf(u, "DCA")
      StopSoundBJ(Youmu_DCA_Start, false)
      u:playsound(Youmu_DCA_Act)
      u:changedata("连携剑技使用次数", 1)
    end
  end,
  QCR = function(u)
    du = u
    local sh, bs, x, y, hj, lx, angle = set()
    if u:hasdata("妖梦天赋-天界剑") then
      ChangeValue(Hero_Tili, sy, 2)
    end
    u:animespeed(1)
    ac.wait(1, function()
      u:animeact(5)
    end)
    local ng = CreateGroupLua()
    u:buffset(u.handle, 0.4, "暂停")
    u:buffset(u.handle, 0.4, "伤害免疫")
    Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
    unitmove({
      unit = u.handle,
      time = 0.1,
      distance = 200,
      angle = angle
    })
    local jumptime = 0.3
    ac.wait(100, function()
      x, y = u:getxy()
      unitjump({
        unit = u.handle,
        time = jumptime,
        distance = 200,
        height = 300,
        angle = angle,
        isfly = true
      })
      local xq = getunit(BOSS_DEATH)
      local x2, y2 = PolarXY(x, y, 275, angle)
      local x4, y4 = PolarXY(x, y, 375, angle)
      local mz = false
      local fw = 350 * bs
      for _, xq in ac.selector():in_rangexy(x, y, fw):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        local x3, y3 = xq:getxy()
        unitjump({
          unit = xq.handle,
          time = jumptime,
          distance = DistanceXY(x3, y3, x4, y4),
          height = 300,
          angle = AngleXY(x3, y3, x4, y4),
          isfly = true
        })
      end
      ac.wait(jumptime * 1000, function()
        local x, y = u:getxy()
        local mz2 = false
        for _, xq in ac.selector():in_rangexy(x2, y2, fw):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          xq:groupadd(ng)
          mz2 = true
        end
        Effectcreate("Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl", x2, y2)
        if u:getdata("umpf_paopao") == true then
          EffectcreateArgs({
            effect = "war3mapImported\\umpf_paopao_daoguang1.mdx",
            x = x,
            y = y,
            size = 4,
            height = 0,
            zxz = angle,
            yxz = 15,
            animespeed = 2
          })
          EffectcreateArgs({
            effect = "war3mapImported\\umpf_paopao_daoguang5.mdx",
            x = x,
            y = y,
            size = 15,
            height = 100,
            zxz = angle,
            yxz = 15,
            animespeed = 6
          })
        else
          local a = angle + 180
          local mj = u:createunit("e004", x2, y2, a)
          mj:animeact(math.floor(17.939999999999998))
          mj:timetoremove(0.5)
          mj:setflyheight(150)
          mj:effectadd("war3mapImported\\zhanji-blueX-shu.mdx")
          mj:effectadd("war3mapImported\\zhanji-blue-shu.mdx")
        end
        ForGroupLuaNew(ng, function(xq)
          DamageUnit({
            bj = "妖梦(机体)",
            unit = xq.handle,
            source = hero.handle,
            damage = 2 * sh,
            level = 1,
            type = lx,
            isvest = false,
            isattack = true,
            isnoarmor = hj,
            element = "无"
          })
          xq:buffset(hero.handle, 1.2, "眩晕")
        end)
        if mz then
          jqzhf(u, "QCR")
        end
      end)
      if mz then
        jqzhf(u, "QCR")
        u:playsound(Youmu_QCR_Ok)
        u:changedata("连携剑技使用次数", 1)
      else
        u:playsound(Youmu_QCR_Miss)
      end
    end)
  end,
  ECA = function(u)
    du = u
    local sh, bs, x, y, hj, lx, angle = set()
    if u:hasdata("妖梦天赋-天界剑") then
      ChangeValue(Hero_Tili, sy, 2)
    end
    u:animespeed(3)
    ac.wait(1, function()
      u:animeact(18)
    end)
    ac.wait(100, function()
      u:animespeed(1)
    end)
    u:playsound(Youmu_ECA_Start)
    u:effectadd("war3mapImported\\evilwave_blue.mdx", "origin")
    local x2, y2 = PolarXY(x, y, 80, angle)
    local range = 1200
    local g2 = CreateGroupLua()
    local cs = 4
    local b = false
    local b2 = false
    local txth = ""
    if u:getdata("umpf_paopao") == true then
      txth = "PPJianqi.mdx"
    else
      txth = "war3mapImported\\Texiao_Lvsechognjibo.mdl"
    end
    local mz = false
    unifycreate({
      owner = hero.handle,
      model = txth,
      modelname = "结痂跌斩",
      modelsize = 1.5,
      height = 0,
      damage = 0,
      damagetype = 2,
      x = x2,
      y = y2,
      range = range,
      speed = 1800,
      volume = 128,
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
        if mj:getdata("循环计数") >= 0.05 then
          if b then
            cs = cs + 1
            if cs == 5 then
              cs = 0
              u:playsound(Youmu_ECA_Act)
            end
          end
          b = false
          GroupClearLua(mj:getdata("弹幕-伤害组"))
          mj:setdata("循环计数", 0)
          local dx, dy = mj:getxy()
          Effectcreate("Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl", dx, dy)
        end
      end,
      hitfunc = function(mj, damage)
        return damage
      end,
      hitbeforefunc = function(mj, xq, damage2)
      end,
      hitafterfunc = function(mj, xq, damage2)
        b2 = true
        if not mz then
          mz = true
          jqzhf(u, "ECA")
        end
        if not b then
          b = true
          jqzhf(u, "ECA-Extra")
        end
        if not xq:isingroup(g2) then
          xq:groupadd(g2)
          DamageUnit({
            bj = "妖梦(机体)",
            unit = xq.handle,
            source = hero.handle,
            damage = 0.5 * sh,
            level = 1,
            type = lx,
            isvest = false,
            isattack = true,
            isnoarmor = hj,
            element = "无"
          })
          xq:buffset(hero.handle, 0.3, "僵直")
        else
          DamageUnit({
            bj = "妖梦(机体)",
            unit = xq.handle,
            source = hero.handle,
            damage = 0.5 * sh,
            level = 1,
            type = lx,
            isvest = true,
            isattack = true,
            isnoarmor = hj,
            element = "无"
          })
        end
        unitmove({
          unit = xq.handle,
          time = 0.2,
          distance = 100,
          angle = mj:getface()
        })
      end,
      endfunc = function(mj)
        mj:settimedata("禁止使用", 5)
        if b2 then
          u:changedata("连携剑技使用次数", 1)
        end
      end
    })
  end,
  ACR = function(u)
    du = u
    local sh, bs, x, y, hj, lx, angle = set()
    if u:hasdata("妖梦天赋-天界剑") then
      ChangeValue(Hero_Tili, sy, 2)
    end
    u:animespeed(3)
    ac.wait(1, function()
      u:animeact(18)
    end)
    ac.wait(100, function()
      u:animespeed(1)
    end)
    u:playsound(Youmu_ACR_Start)
    u:effectadd("war3mapImported\\bigexplosionblue (by defong).mdx", "origin")
    local fw = 128 * bs
    local rg = 400
    if hero:hasdata("妖梦天赋-樱花剑") then
      rg = 600
    end
    local g2 = CreateGroupLua()
    local b2 = false
    for i = 1, 20 do
      local a = angle - 66 + 6 * i
      local tx = ""
      if u:getdata("umpf_paopao") == true then
        tx = Effectcreate("war3mapImported\\umpf_paopao_baozha_yumao.mdl", x, y, -1, 1, 100, a)
      else
        tx = Effectcreate("war3mapImported\\Toushewu_Ziguang.mdl", x, y, -1, 1, 100, a)
      end
      effectmove({
        effect = tx,
        time = 0.3,
        distance = rg,
        angle = a,
        loops = {
          {
            looptime = 0.03,
            func = function(dx, dy)
              for _, xq in ac.selector():in_rangexy(dx, dy, fw):is_enemy(u.handle):isnotingroup(g2):ipairs() do
                xq = getunit(xq)
                xq:groupadd(g2)
                DamageUnit({
                  bj = "妖梦(机体)",
                  unit = xq.handle,
                  source = hero.handle,
                  damage = 1.5 * sh,
                  level = 1,
                  type = lx,
                  isvest = false,
                  isattack = true,
                  isnoarmor = hj,
                  element = "无"
                })
                xq:buffset(hero.handle, 1, "眩晕")
                if not b2 then
                  b2 = true
                  jqzhf(u, "ACR")
                  StopSoundBJ(Youmu_ACR_Start, false)
                  u:playsound(Youmu_ACR_Act)
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
    ac.wait(301, function()
      if Group_Counts(g2) > 0 then
        u:changedata("连携剑技使用次数", 1)
      end
      b2 = false
      GroupClearLua(g2)
      for i = 1, 20 do
        local a = angle - 66 + 6 * i
        local x2, y2 = PolarXY(x, y, rg, a)
        local tx = ""
        if u:getdata("umpf_paopao") == true then
          tx = Effectcreate("war3mapImported\\umpf_paopao_baozha_yumao.mdl", x2, y2, -1, 1, 100, a)
        else
          tx = Effectcreate("war3mapImported\\Toushewu_Ziguang.mdl", x2, y2, -1, 1, 100, a)
        end
        effectmove({
          effect = tx,
          time = 0.3,
          distance = rg,
          angle = a + 180,
          loops = {
            {
              looptime = 0.03,
              func = function(dx, dy)
                for _, xq in ac.selector():in_rangexy(dx, dy, fw):is_enemy(u.handle):isnotingroup(g2):ipairs() do
                  xq = getunit(xq)
                  xq:groupadd(g2)
                  DamageUnit({
                    bj = "妖梦(机体)",
                    unit = xq.handle,
                    source = hero.handle,
                    damage = 1.5 * sh,
                    level = 1,
                    type = lx,
                    isvest = false,
                    isattack = true,
                    isnoarmor = hj,
                    element = "无"
                  })
                  xq:buffset(hero.handle, 1, "眩晕")
                  if not b2 then
                    b2 = true
                    jqzhf(u, "ACR")
                    StopSoundBJ(Youmu_ACR_Start, false)
                    u:playsound(Youmu_ACR_Act)
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
    end)
    ac.wait(602, function()
    end)
  end,
  QCWWCQ = function(u)
    du = u
    local sh, bs, x, y, hj, lx, angle = set()
    if u:hasdata("妖梦天赋-天界剑") then
      ChangeValue(Hero_Tili, sy, 2)
    end
    u:animespeed(1)
    ac.wait(1, function()
      u:animeact(21)
    end)
    local xq = getunit(BOSS_DEATH)
    if u:getdata("umpf_paopao") == true then
      u:effectadd("war3mapImported\\umpf_paopao_quan1.mdx", "origin", 1)
      EffectcreateArgs({
        effect = "war3mapImported\\umpf_paopao_quan2.mdx",
        x = x,
        y = y,
        size = 3,
        height = 100,
        zxz = angle,
        animespeed = 2
      })
      EffectcreateArgs({
        effect = "war3mapImported\\umpf_paopao_guangzhu1.mdx",
        x = x,
        y = y,
        size = 2,
        height = -500,
        zxz = angle,
        animespeed = 1
      })
    else
      u:effectadd("Abilities\\Spells\\Items\\TomeOfRetraining\\TomeOfRetrainingCaster.mdl", "origin", 1)
      u:effectadd("war3mapImported\\dead spirit by deckai2.mdx", "origin")
    end
    local fw = 300 * bs
    local mz = false
    for _, xq in ac.selector():in_rangexy(x, y, fw):is_enemy(u.handle):ipairs() do
      xq = getunit(xq)
      if not mz then
        mz = true
        jqzhf(u, "QCWWCQ")
      end
      unitmove({
        unit = xq.handle,
        time = 0.2,
        distance = 200,
        angle = AngleBetweenUnits(u.handle, xq.handle),
        isfly = Nandu_Choose <= 4
      })
      xq:buffset(hero.handle, 2, "眩晕")
      xq:buffset(hero.handle, 8, "破坏-伤害免疫")
      xq:buffset(hero.handle, 8, "破坏-伤害闪避")
      DamageUnit({
        bj = "妖梦(机体)",
        unit = xq.handle,
        source = hero.handle,
        damage = 1 * sh,
        level = 1,
        type = lx,
        isvest = false,
        isattack = true,
        isnoarmor = hj,
        element = "无"
      })
    end
    u:playsound(Youmu_QCWWCQ_Act)
    u:buffset(u.handle, 1.2, "绝对闪避")
  end,
  ACW = function(u)
    du = u
    local sh, bs, x, y, hj, lx, angle = set()
    if u:hasdata("妖梦天赋-天界剑") then
      ChangeValue(Hero_Tili, sy, 2)
    end
    u:animespeed(1)
    ac.wait(1, function()
      u:animeact(14)
    end)
    local t = 0.4
    local t3 = 0.3
    if hero:hasdata("妖梦天赋-狱神剑") then
      t = 0.2
      t3 = 0.15
    end
    u:buffset(u.handle, t3, "绝对闪避")
    u:buffset(u.handle, t3, "暂停")
    local xq = getunit(BOSS_DEATH)
    local fw = 256 * bs
    local x2, y2 = u:getxy()
    for i = 1, 10 do
      x2, y2 = PolarXY(x2, y2, 60, angle)
      for _, xq in ac.selector():in_rangexy(x, y, fw):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
      end
    end
    if xq.handle ~= BOSS_DEATH then
      u:playsound(Youmu_WCA_Ok)
      u:changedata("连携剑技使用次数", 1)
    else
      u:playsound(Youmu_WCA_Miss)
    end
    local mz = false
    local g2 = CreateGroupLua()
    local fh = 1
    unitmove({
      unit = u.handle,
      time = t,
      distance = 600,
      angle = angle,
      isfly = Nandu_Choose <= 4,
      loops = {
        {
          looptime = 0.03,
          func = function(dx, dy)
            if u:getdata("umpf_paopao") == true then
              Effectcreate("war3mapImported\\umpf_paopao_baozha_yumao.mdx", dx, dy, 0, 5)
            else
              Effectcreate("war3mapImported\\senbonzakurapart1.mdx", dx, dy)
            end
            do
              local ran = GetRandomReal(60, 75) * fh
              local ani = (ran + 460) % 360 * 0.69
              ran = GetRandomReal(15, 35) * fh
              local angt = angle + ran
              local mj = u:createunit("e005", dx, dy, angt)
              mj:animeact(math.floor(ani))
              SetUnitScale(mj.handle, GetRandomReal(0.7, 1), 1, 1)
              mj:timetoremove(0.5)
              mj:setflyheight(120 + fh * 60)
              if u:getdata("umpf_paopao") == true then
                mj:effectadd("war3mapImported\\umpf_paopao_daoguang1.mdx")
              else
                mj:effectadd("war3mapImported\\zhanji-blueX-shu.mdx")
              end
              fh = fh * -1
            end
            for _, xq in ac.selector():in_rangexy(dx, dy, fw):is_enemy(u.handle):isnotingroup(g2):ipairs() do
              xq = getunit(xq)
              if not mz then
                mz = true
                jqzhf(u, "ACW")
              end
              xq:groupadd(g2)
              unitmove({
                unit = xq.handle,
                time = 0.2,
                distance = 350 - DistanceBetweenUnits(xq.handle, u.handle),
                angle = AngleBetweenUnits(u.handle, xq.handle),
                isfly = Nandu_Choose <= 4
              })
              DamageUnit({
                bj = "妖梦(机体)",
                unit = xq.handle,
                source = hero.handle,
                damage = 1.25 * sh,
                level = 1,
                type = lx,
                isvest = false,
                isattack = true,
                isnoarmor = hj,
                element = "无"
              })
              xq:buffset(hero.handle, 0.8, "眩晕")
            end
          end
        }
      },
      endfunc = function(dx, dy)
        u:setdata("位移点X", dx)
        u:setdata("位移点Y", dy)
      end
    })
  end,
  ACE = function(u)
    du = u
    local sh, bs, x, y, hj, lx, angle = set()
    if u:hasdata("妖梦天赋-天界剑") then
      ChangeValue(Hero_Tili, sy, 2)
    end
    u:animespeed(2)
    ac.wait(1, function()
      u:animeact(8)
    end)
    u:buffset(u.handle, 0.2, "伤害免疫")
    u:buffset(u.handle, 0.15, "暂停")
    local xq = getunit(BOSS_DEATH)
    local fw = 256 * bs
    local x2, y2 = u:getxy()
    for i = 1, 10 do
      x2, y2 = PolarXY(x2, y2, 60, angle)
      for _, xq in ac.selector():in_rangexy(x, y, fw):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
      end
    end
    local mz = false
    local x4, y4 = PolarXY(x, y, 200, angle)
    local g2 = CreateGroupLua()
    local jtjl = 300
    local jttime = 0.2
    unitmove({
      unit = u.handle,
      time = 0.2,
      distance = 300,
      angle = angle,
      isfly = Nandu_Choose <= 4,
      loops = {
        {
          looptime = 0.03,
          func = function(dx, dy)
            jtjl = jtjl - 40
            jttime = jttime - 0.03
            Effectcreate("Abilities\\Weapons\\BallistaMissile\\BallistaImpact.mdl", dx, dy)
            for _, xq in ac.selector():in_rangexy(dx, dy, fw):is_enemy(u.handle):isnotingroup(g2):ipairs() do
              xq = getunit(xq)
              xq:groupadd(g2)
              if not mz then
                mz = true
                jqzhf(u, "ACE")
              end
              if not hero:hasdata("妖梦-ACE无击退") then
                unitmove({
                  unit = xq.handle,
                  time = jttime,
                  distance = jtjl,
                  angle = angle
                })
              end
              DamageUnit({
                bj = "妖梦(机体)",
                unit = xq.handle,
                source = hero.handle,
                damage = 1 * sh,
                level = 1,
                type = lx,
                isvest = false,
                isattack = true,
                isnoarmor = hj,
                element = "无"
              })
              xq:buffset(hero.handle, 0.75, "眩晕")
            end
          end
        }
      },
      endfunc = function()
      end
    })
    if xq.handle ~= BOSS_DEATH then
      u:playsound(Youmu_ACECFCR_1Ok)
      u:changedata("连携剑技使用次数", 1)
    else
      u:playsound(Youmu_ACECFCR_1Miss)
    end
  end,
  ACEF = function(u)
    du = u
    local sh, bs, x, y, hj, lx, angle = set()
    if u:hasdata("妖梦天赋-天界剑") then
      ChangeValue(Hero_Tili, sy, 2)
    end
    u:animespeed(5)
    ac.wait(1, function()
      u:animeact(6)
    end)
    ac.wait(201, function()
      u:animespeed(1)
    end)
    u:buffset(u.handle, 0.4, "伤害免疫")
    u:buffset(u.handle, 0.4, "暂停")
    Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
    local xq = getunit(BOSS_DEATH)
    local fw = 300 * bs
    local mz = false
    local x2, y2 = PolarXY(x, y, 100, angle)
    unitjump({
      unit = u.handle,
      time = 0.5,
      distance = 250,
      height = 300,
      angle = angle,
      isfly = true
    })
    for _, xq in ac.selector():in_rangexy(x, y, fw):is_enemy(u.handle):ipairs() do
      xq = getunit(xq)
      unitjump({
        unit = xq.handle,
        time = 0.5,
        distance = 250,
        height = 300,
        angle = angle,
        isfly = Nandu_Choose <= 4
      })
      DamageUnit({
        bj = "妖梦(机体)",
        unit = xq.handle,
        source = hero.handle,
        damage = 1.5 * sh,
        level = 1,
        type = lx,
        isvest = false,
        isattack = true,
        isnoarmor = hj,
        element = "无"
      })
      if not mz then
        mz = true
        jqzhf(u, "ACEF")
      end
      xq:buffset(hero.handle, 0.8, "眩晕")
    end
    do
      local a = angle + 30
      local mj = u:createunit("e004", x, y, a)
      mj:animeact(math.floor(0 * 0.69))
      SetUnitScale(mj.handle, 0.3, 1, 1)
      mj:timetoremove(1)
      if u:getdata("umpf_paopao") == true then
        mj:effectadd("war3mapImported\\umpf_paopao_baozha_yumao.mdx")
        mj:effectadd("war3mapImported\\umpf_paopao_baozha_yumao.mdx")
        mj:effectadd("war3mapImported\\umpf_paopao_baozha_yumao.mdx")
      else
        mj:effectadd("war3mapImported\\senbonzakurapart1.mdx")
        mj:effectadd("war3mapImported\\senbonzakurapart.mdx")
        mj:effectadd("war3mapImported\\senbonzakurapart.mdx")
      end
      local cang = angle - 110
      local r = 100
      local ctime = 0
      ac.loop(20, function(timer)
        ctime = ctime + 0.02
        if ctime <= 0.3 then
          r = r + 15
          cang = cang + 18
          x, y = u:getxy()
          local dx, dy = PolarXY(x, y, r, cang)
          mj:setxy(dx, dy)
          mj:setflyheight(GetUnitFlyHeight(mj.handle) + 21)
        else
          timer:remove()
        end
      end)
      local mj = u:createunit("e004", x, y, a)
      mj:animeact(math.floor(0 * 0.69))
      SetUnitScale(mj.handle, 0.3, 1, 1)
      mj:timetoremove(1)
      if u:getdata("umpf_paopao") == true then
        mj:effectadd("war3mapImported\\umpf_paopao_baozha_yumao.mdx")
        mj:effectadd("war3mapImported\\umpf_paopao_baozha_yumao.mdx")
        mj:effectadd("war3mapImported\\umpf_paopao_baozha_yumao.mdx")
      else
        mj:effectadd("war3mapImported\\senbonzakurapart1.mdx")
        mj:effectadd("war3mapImported\\senbonzakurapart.mdx")
        mj:effectadd("war3mapImported\\senbonzakurapart.mdx")
      end
      local cang = angle - 90
      local r = 70
      local ctime = 0
      ac.loop(20, function(timer)
        ctime = ctime + 0.02
        if ctime <= 0.3 then
          r = r + 18
          cang = cang + 21
          x, y = u:getxy()
          local dx, dy = PolarXY(x, y, r, cang)
          mj:setxy(dx, dy)
          mj:setflyheight(GetUnitFlyHeight(mj.handle) + 24)
        else
          timer:remove()
        end
      end)
    end
    if xq.handle ~= BOSS_DEATH then
      u:playsound(Youmu_ACECFCR_2Ok)
      u:changedata("连携剑技使用次数", 1)
    else
      u:playsound(Youmu_ACECFCR_2Miss)
    end
  end,
  ACEFR = function(u)
    du = u
    local sh, bs, x, y, hj, lx, angle = set()
    if u:hasdata("妖梦天赋-天界剑") then
      ChangeValue(Hero_Tili, sy, 2)
    end
    u:animespeed(1)
    ac.wait(1, function()
      u:animeact(5)
    end)
    u:buffset(u.handle, 0.4, "伤害免疫")
    u:buffset(u.handle, 0.4, "暂停")
    Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
    local xq = getunit(BOSS_DEATH)
    local mz = false
    local fw = 375 * bs
    local x2, y2 = PolarXY(x, y, 100, angle)
    unitjump({
      unit = u.handle,
      time = 0.2,
      distance = 100,
      height = 500,
      angle = angle,
      isfly = true
    })
    for _, xq in ac.selector():in_rangexy(x2, y2, fw):is_enemy(u.handle):ipairs() do
      xq = getunit(xq)
    end
    if xq.handle ~= BOSS_DEATH then
      u:playsound(Youmu_ACECFCR_3Ok)
      u:changedata("连携剑技使用次数", 1)
    else
      u:playsound(Youmu_ACECFCR_3Miss)
    end
    ac.wait(200, function()
      x, y = u:getxy()
      Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
      Effectcreate("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", x, y)
      Effectcreate("war3mapImported\\fuzzystomp.mdx", x, y)
      if u:getdata("umpf_paopao") == true then
        Effectcreate("war3mapImported\\umpf_paopao_guangzhu1.mdx", x, y, 0, 5, -500)
        Effectcreate("war3mapImported\\umpf_paopao_baozha7.mdx", x, y, 0, 10)
      end
      for _, xq in ac.selector():in_rangexy(x, y, fw):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl")
        if not mz then
          mz = true
          jqzhf(u, "ACEFR")
        end
        DamageUnit({
          bj = "妖梦(机体)",
          unit = xq.handle,
          source = hero.handle,
          damage = 2.5 * sh,
          level = 1,
          type = lx,
          isvest = false,
          isattack = true,
          isnoarmor = hj,
          element = "无"
        })
        xq:buffset(hero.handle, 1.5, "眩晕")
      end
    end)
  end,
  SCS = function(u)
    du = u
    sy = u.ownerid
    local x, y = u:getxy()
    local angle = u:getface()
    if u:hasdata("妖梦天赋-天界剑") then
      ChangeValue(Hero_Tili, sy, 2)
    end
    u:effectadd("war3mapImported\\spellcardcall.mdx", "origin", 0.8)
    u:playsound(Sound_Youmu_SCS)
    if u:hasdata("妖梦天赋-天神剑") then
      u:setdata("妖梦-小魂符时间", 14)
    else
      u:setdata("妖梦-小魂符时间", 10)
    end
    if u:islocal() then
      BuffUI.apply({
        id = "妖梦-魂符幻象"
      })
    end
    local mj = u:createunit("u0E6", x, y, angle)
    if u:getdata("umpf_paopao") == true then
      japi.SetUnitModel(mj.handle, "paopao_umpf1.mdx")
      mj:setsize(1.4)
      mj:setdata("umpf_paopao")
    end
    u:setdata("妖梦-魂符幻象", mj.handle)
    mj:setdata("魂符幻象")
    mj:setdata("小魂符")
    u:setdata("妖梦-魂符延迟", 0.25)
    mj:setcolor(255, 255, 255, 125)
    if u:hasdata("系统-飞行状态") then
      mj:setdata("系统-飞行状态")
    end
    ac.loop(100, function(t)
      local x2, y2 = u:getxy()
      x2 = x2 - 16
      y2 = y2 - 16
      IssuePointOrder(mj.handle, "move", x2, y2)
      if mj.handle ~= u:getdata("妖梦-魂符幻象") then
        t:remove()
      end
    end)
  end,
  SCV = function(u)
    du = u
    sy = u.ownerid
    local x, y = u:getxy()
    local angle = u:getface()
    if u:hasdata("妖梦天赋-天界剑") then
      ChangeValue(Hero_Tili, sy, 7)
    end
    u:effectadd("war3mapImported\\spellcardcall.mdx", "origin", 0.8)
    u:playsound(Sound_Youmu_SCS)
    if u:hasdata("妖梦天赋-天神剑") then
      u:setdata("妖梦-大魂符时间", 18)
    else
      u:setdata("妖梦-大魂符时间", 14)
    end
    if u:islocal() then
      BuffUI.apply({
        id = "妖梦-魂符幻象"
      })
    end
    local mj = u:createunit("u0E6", x, y, angle)
    if u:getdata("umpf_paopao") == true then
      japi.SetUnitModel(mj.handle, "paopao_umpf1.mdx")
      mj:setsize(1.4)
      mj:setdata("umpf_paopao")
    end
    u:setdata("妖梦-魂符幻象", mj.handle)
    mj:setdata("魂符幻象")
    mj:setdata("大魂符")
    u:setdata("妖梦-魂符延迟", 0.15)
    mj:setcolor(255, 255, 255, 125)
    if u:hasdata("系统-飞行状态") then
      mj:setdata("系统-飞行状态")
    end
    ac.loop(100, function(t)
      local x2, y2 = u:getxy()
      x2 = x2 - 16
      y2 = y2 - 16
      IssuePointOrder(mj.handle, "move", x2, y2)
      if mj.handle ~= u:getdata("妖梦-魂符幻象") then
        t:remove()
      end
    end)
  end,
  WV = function(u)
    du = u
    local sh, bs, x, y, hj, lx, angle = set()
    local txsh = 5 * sh
    if u:hasdata("妖梦天赋-天界剑") then
      ChangeValue(Hero_Tili, sy, 7)
    end
    u:animespeed(1)
    ac.wait(1, function()
      u:animeact(21)
    end)
    local qianyaotime = 0.8
    if hero:hasdata("妖梦天赋-狱神剑") then
      qianyaotime = 0.5
    end
    u:effectadd("war3mapImported\\spellcardcall.mdx", "origin", qianyaotime)
    u:buffset(u.handle, qianyaotime, "暂停")
    u:buffset(u.handle, qianyaotime, "无敌")
    local xq = getunit(BOSS_DEATH)
    local fw = 256 * bs
    local x2, y2 = u:getxy()
    for i = 1, 10 do
      x2, y2 = PolarXY(x2, y2, 60, angle)
      for _, xq in ac.selector():in_rangexy(x, y, fw):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
      end
    end
    if xq.handle ~= BOSS_DEATH then
      u:playsound(Youmu_WV_Ok)
      u:changedata("终结剑技使用次数", 1)
    else
      u:playsound(Youmu_WV_Miss)
    end
    ac.wait(qianyaotime * 1000, function()
      u:animeact(14)
      local range = 1000
      local t = 0.25
      if hero:hasdata("妖梦天赋-狱神剑") then
        t = 0.125
        range = 1250
        fw = fw * 1.25
        sh = sh * 2
      end
      u:buffset(u.handle, 0.3, "无敌")
      local fh = 1
      local mz = false
      local g2 = CreateGroupLua()
      unitmove({
        unit = u.handle,
        time = t,
        distance = range,
        angle = angle,
        isfly = Nandu_Choose <= 4,
        loops = {
          {
            looptime = 0.03,
            func = function(dx, dy)
              if u:getdata("umpf_paopao") == true then
                Effectcreate("war3mapImported\\umpf_paopao_baozha_yumao.mdx", dx, dy)
              else
                Effectcreate("Abilities\\Spells\\Human\\MarkOfChaos\\MarkOfChaosDone.mdl", dx, dy)
              end
              for _, xq in ac.selector():in_rangexy(dx, dy, fw):is_enemy(u.handle):isnotingroup(g2):ipairs() do
                xq = getunit(xq)
                xq:groupadd(g2)
                if not mz then
                  mz = true
                  jqzhf(u, "WV")
                end
                xq:buffset(u.handle, 8, "破坏-伤害免疫")
                DamageUnit({
                  bj = "妖梦(机体)",
                  unit = xq.handle,
                  source = hero.handle,
                  damage = txsh,
                  level = 1,
                  type = lx,
                  isvest = false,
                  isattack = true,
                  isnoarmor = hj,
                  element = "无"
                })
                xq:buffset(hero.handle, 2.5, "眩晕")
              end
              if u:getdata("umpf_paopao") == true then
                EffectcreateArgs({
                  effect = "war3mapImported\\umpf_paopao_daoguang1.mdx",
                  x = dx,
                  y = dy,
                  size = 4,
                  height = 0,
                  zxz = angle,
                  yxz = 15,
                  animespeed = 2
                })
                EffectcreateArgs({
                  effect = "war3mapImported\\umpf_paopao_daoguang5.mdx",
                  x = x,
                  y = y,
                  size = 15,
                  height = 100,
                  zxz = angle,
                  yxz = 15,
                  animespeed = 6
                })
              else
                local ran = GetRandomReal(60, 75) * fh
                local ani = (ran + 460) % 360 * 0.69
                ran = GetRandomReal(15, 35) * fh
                local angt = angle + ran
                local mj = u:createunit("e005", dx, dy, angt)
                mj:animeact(math.floor(ani))
                SetUnitScale(mj.handle, GetRandomReal(0.7, 1), 1, 1)
                mj:timetoremove(0.5)
                mj:setflyheight(120 + fh * 60)
                mj:effectadd("war3mapImported\\zhanji-blueX-shu.mdx")
              end
              fh = fh * -1
              if u:getdata("umpf_paopao") == true then
                EffectcreateArgs({
                  effect = "war3mapImported\\umpf_paopao_daoguang1.mdx",
                  x = dx,
                  y = dy,
                  size = 4,
                  height = 0,
                  zxz = angle,
                  yxz = 15,
                  animespeed = 2
                })
                EffectcreateArgs({
                  effect = "war3mapImported\\umpf_paopao_daoguang5.mdx",
                  x = dx,
                  y = dy,
                  size = 15,
                  height = 100,
                  zxz = angle,
                  yxz = 15,
                  animespeed = 6
                })
              else
                local a = angle + 180
                local mj = u:createunit("e004", dx, dy, a)
                mj:animeact(math.floor(17.939999999999998))
                mj:timetoremove(0.5)
                mj:setflyheight(150)
                mj:effectadd("war3mapImported\\zhanji-blueX-shu.mdx")
                mj:effectadd("war3mapImported\\zhanji-blue-shu.mdx")
                fh = fh * -1
              end
            end
          }
        },
        endfunc = function()
        end
      })
    end)
  end,
  AV = function(u)
    du = u
    local sh, bs, x, y, hj, lx, angle = set()
    local txsh = 5 * sh
    if u:hasdata("妖梦天赋-天界剑") then
      ChangeValue(Hero_Tili, sy, 7)
    end
    u:animespeed(1)
    ac.wait(1, function()
      u:animeact(21)
    end)
    u:effectadd("war3mapImported\\spellcardcall.mdx", "origin", 0.8)
    u:buffset(u.handle, 0.8, "暂停")
    u:buffset(u.handle, 0.8, "无敌")
    local xq = getunit(BOSS_DEATH)
    local fw = 256 * bs
    local sx = 10
    local t = 1
    local range = 1200
    if hero:hasdata("妖梦天赋-樱花剑") then
      fw = fw * 1.25
      sx = 15
      range = 1800
      t = 1.5
    end
    local x2, y2 = u:getxy()
    for i = 1, sx do
      x2, y2 = PolarXY(x2, y2, 60, angle)
      for _, xq in ac.selector():in_rangexy(x, y, fw):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
      end
    end
    if xq.handle ~= BOSS_DEATH then
      u:playsound(Youmu_AV_Ok)
      u:changedata("终结剑技使用次数", 1)
    else
      u:playsound(Youmu_AV_Miss)
    end
    ac.wait(800, function()
      u:animeact(8)
      local mz = false
      local g2 = CreateGroupLua()
      x, y = u:getxy()
      loopmove({
        x = x,
        y = y,
        time = t,
        distance = range,
        angle = angle,
        loops = {
          {
            looptime = 0.05,
            func = function(dx, dy)
              for i = 1, 12 do
                local dx2, dy2 = PolarXY(dx, dy, GetRandomReal(0, 256), GetRandomReal(0, 360))
                if u:getdata("umpf_paopao") == true then
                  Effectcreate("war3mapImported\\umpf_paopao_daoguang5.mdl", dx, dy, 0.3, 1, 0, GetRandomReal(0, 360))
                else
                  Effectcreate("war3mapImported\\zhanji-blueX-shu.mdl", dx, dy, 0.3, 1, 0, GetRandomReal(0, 360))
                end
              end
              if u:getdata("umpf_paopao") == true then
                Effectcreate("war3mapImported\\umpf_paopao_guangzhu1.mdl", dx, dy, 0, 2)
                Effectcreate("war3mapImported\\umpf_paopao_bodong1.mdl", dx, dy, 0, 2)
              else
                Effectcreate("war3mapImported\\ThunderclapCaster.mdl", dx, dy)
              end
              for _, xq in ac.selector():in_rangexy(dx, dy, fw):is_enemy(u.handle):isnotingroup(g2):ipairs() do
                xq = getunit(xq)
                xq:groupadd(g2)
                if not mz then
                  mz = true
                  jqzhf(u, "AV")
                end
                if not xq:hasdata("妖梦-AV抑制恢复") then
                  xq:groupadd(HpGroup)
                  xq:settimedata("妖梦-AV抑制恢复", 8)
                  xq:effectadd("Abilities\\Spells\\Human\\AerialShackles\\AerialShacklesTarget.mdl", "overhead", 8)
                end
                DamageUnit({
                  bj = "妖梦(机体)",
                  unit = xq.handle,
                  source = hero.handle,
                  damage = txsh,
                  level = 1,
                  type = lx,
                  isvest = false,
                  isattack = true,
                  isnoarmor = hj,
                  element = "无"
                })
                xq:buffset(hero.handle, 1.25, "眩晕")
              end
            end
          }
        },
        endfunc = function(dx, dy)
        end
      })
    end)
  end,
  ECAV = function(u)
    du = u
    local sh, bs, x, y, hj, lx, angle = set()
    local txsh = 2 * sh
    if u:hasdata("妖梦天赋-天界剑") then
      ChangeValue(Hero_Tili, sy, 7)
    end
    u:animespeed(1)
    ac.wait(1, function()
      u:animeact(21)
    end)
    u:effectadd("war3mapImported\\spellcardcall.mdx", "origin", 0.8)
    u:buffset(u.handle, 1.8, "暂停")
    u:buffset(u.handle, 1.9, "无敌")
    local xq = getunit(BOSS_DEATH)
    local fw = 256 * bs
    local sx = 16
    local txdx = 1
    if hero:hasdata("妖梦天赋-樱花剑") then
      fw = fw * 1.25
      sx = 24
      txdx = 1.25
    end
    local x2, y2 = u:getxy()
    for i = 1, sx do
      x2, y2 = PolarXY(x2, y2, 60, angle)
      for _, xq in ac.selector():in_rangexy(x, y, fw):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
      end
    end
    if xq.handle ~= BOSS_DEATH then
      u:playsound(Youmu_ECAV_Ok)
      u:changedata("终结剑技使用次数", 1)
    else
      u:playsound(Youmu_ECAV_Miss)
    end
    local dtime = 0.6
    ac.wait(dtime * 1000, function()
      u:animeact(8)
      local g2 = CreateGroupLua()
      x, y = u:getxy()
      local cs = 0
      ac.loop(200, function(timer)
        cs = cs + 1
        x, y = u:getxy()
        GroupClearLua(g2)
        local cs2 = 0
        local x3, y3 = x, y
        local mz = false
        ac.loop(10, function(timer2)
          cs2 = cs2 + 1
          x3, y3 = PolarXY(x3, y3, 100, angle)
          if u:getdata("umpf_paopao") == true then
            Effectcreate("war3mapImported\\umpf_paopao_bodong1.mdl", x3, y3, 0, 2 * txdx)
          else
            Effectcreate("war3mapImported\\ThunderclapCaster.mdl", x3, y3, 0, txdx)
          end
          for _, xq in ac.selector():in_rangexy(x3, y3, fw):is_enemy(u.handle):isnotingroup(g2):ipairs() do
            xq = getunit(xq)
            xq:groupadd(g2)
            if not mz then
              mz = true
              jqzhf(u, "ECAV")
            end
            DamageUnit({
              bj = "妖梦(机体)",
              unit = xq.handle,
              source = hero.handle,
              damage = txsh,
              level = 1,
              type = lx,
              isvest = false,
              isattack = true,
              isnoarmor = hj,
              element = "无"
            })
            xq:buffset(hero.handle, 0.5, "眩晕")
          end
          if cs2 == sx then
            timer2:remove()
          end
        end)
        if cs == 6 then
          timer:remove()
        end
      end)
    end)
  end,
  WCFV = function(u)
    du = u
    local sh, bs, x, y, hj, lx, angle = set()
    local jd = angle
    local txsh = 7.5 * sh
    if u:hasdata("妖梦天赋-天界剑") then
      ChangeValue(Hero_Tili, sy, 7)
    end
    u:animespeed(1)
    ac.wait(1, function()
      u:animeact(21)
    end)
    u:playsound(se_cat00)
    local qianyaotime = 0.5
    u:buffset(u.handle, qianyaotime + 1.1, "暂停")
    u:buffset(u.handle, qianyaotime + 1.3, "无敌")
    u:effectadd("war3mapImported\\spellcardcall.mdx", "origin", qianyaotime)
    SetCameraTargetControllerNoZForPlayer(u.owner, u.handle, 0, 0, false)
    ac.wait(qianyaotime * 1000, function()
      u:animeact(8)
      PlayGlobalSound(Sound_Ym_F02_3)
      local cs = 0
      unitjump({
        unit = u.handle,
        time = 1.4,
        height = GetRandomInt(250, 500),
        distance = 0,
        angle = 0
      })
      local ng = CreateGroupLua()
      for _, xq in ac.selector():in_rangexy(x, y, 425):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        xq:groupadd(ng)
        xq:buffset(u.handle, 1.2, "暂停")
        xq:buffset(u.handle, 1.2, "沉默")
      end
      local dcs = 0
      local count = GetRandomInt(1, 5)
      ac.loop(30, function(t)
        local dx, dy = u:getxy()
        local height = u:getdata("当前跳跃高度")
        dcs = dcs + 1
        if cs <= 11 then
          if cs <= 6 then
            local time = 1.2 - cs * 0.09
            for _, xq in ac.selector():in_rangexy(dx, dy, 425):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              xq:groupadd(ng)
              xq:buffset(u.handle, time, "暂停")
              xq:buffset(u.handle, time, "沉默")
            end
          end
          ForGroupLuaNew(ng, function(xq)
            local x2, y2 = xq:getxy()
            local da = AngleXY(dx, dy, x2, y2)
            local dis = 125
            da = da + count
            x2, y2 = PolarXY(dx, dy, dis, da)
            if not xq:hasdata("免疫击退效果") then
              xq:setxy(x2, y2)
              xq:setflyheight(height)
            end
          end)
        end
        if dcs == 3 then
          dcs = 0
          cs = cs + 1
          count = GetRandomInt(1, 5)
          jd = jd + count * cs
          u:setface(jd)
          if cs <= 11 then
            unitmove({
              unit = u.handle,
              time = 0.1,
              distance = 15 * cs * 2,
              angle = u:getface()
            })
          end
          if u:getdata("umpf_paopao") == true then
            EffectcreateArgs({
              effect = "war3mapImported\\umpf_paopao_baozha6.mdl",
              x = dx,
              y = dy,
              time = 0.5,
              size = 1,
              height = height,
              zxz = GetRandomAngle(),
              animespeed = 1
            })
          else
            EffectcreateArgs({
              effect = "war3mapImported\\senbonzakurapart1.mdl",
              x = dx,
              y = dy,
              time = 0,
              size = 3,
              height = height,
              zxz = GetRandomAngle(),
              animespeed = 1
            })
          end
          if 12 <= cs then
            PlayGlobalSound(Sound_Ym_F12)
            u:shockcamera(300, 0.2)
            local dx1, dy1 = u:getxy()
            local jd1 = AngleXY(dx1, dy1, x, y)
            u:setxy(x, y)
            ResetToGameCameraForPlayer(u.owner, 0)
            local p = getplayer(u.owner)
            p:setcamera(x, y)
            p:setcameraheight(Cam_height[u.ownerid], 0)
            u:setface(jd1)
            if u:getdata("umpf_paopao") == true then
              EffectcreateArgs({
                effect = "war3mapImported\\umpf_paopao_daoguang1.mdx",
                x = x,
                y = y,
                size = 8,
                height = 0,
                zxz = jd1 - 15,
                yxz = 20,
                animespeed = 2
              })
              EffectcreateArgs({
                effect = "war3mapImported\\umpf_paopao_daoguang5.mdx",
                x = x,
                y = y,
                size = 30,
                height = 100,
                zxz = jd1 - 15,
                yxz = 20,
                animespeed = 6
              })
              EffectcreateArgs({
                effect = "war3mapImported\\umpf_paopao_daoguang1.mdx",
                x = x,
                y = y,
                size = 8,
                height = 0,
                zxz = jd1 + 15,
                yxz = 20,
                animespeed = 2
              })
              EffectcreateArgs({
                effect = "war3mapImported\\umpf_paopao_daoguang5.mdx",
                x = x,
                y = y,
                size = 30,
                height = 100,
                zxz = jd1 + 15,
                yxz = 20,
                animespeed = 6
              })
              EffectcreateArgs({
                effect = "war3mapImported\\umpf_paopao_daoguang1.mdx",
                x = x,
                y = y,
                size = 16,
                height = -250,
                zxz = jd1,
                yxz = 20,
                animespeed = 2
              })
              EffectcreateArgs({
                effect = "war3mapImported\\umpf_paopao_daoguang5.mdx",
                x = x,
                y = y,
                size = 60,
                height = 100,
                zxz = jd1,
                yxz = 20,
                animespeed = 6
              })
            else
              EffectcreateArgs({
                effect = "war3mapImported\\zhanji-sakura2.mdx",
                x = x,
                y = y,
                size = 8,
                height = 0,
                zxz = jd1 - 15,
                yxz = 20,
                animespeed = 2
              })
              EffectcreateArgs({
                effect = "war3mapImported\\zhanji-blueX-shu.mdx",
                x = x,
                y = y,
                size = 30,
                height = 100,
                zxz = jd1 - 15,
                yxz = 20,
                animespeed = 6
              })
              EffectcreateArgs({
                effect = "war3mapImported\\zhanji-sakura2.mdx",
                x = x,
                y = y,
                size = 8,
                height = 0,
                zxz = jd1 + 15,
                yxz = 20,
                animespeed = 2
              })
              EffectcreateArgs({
                effect = "war3mapImported\\zhanji-blueX-shu.mdx",
                x = x,
                y = y,
                size = 30,
                height = 100,
                zxz = jd1 + 15,
                yxz = 20,
                animespeed = 6
              })
              EffectcreateArgs({
                effect = "war3mapImported\\zhanji-sakura2.mdx",
                x = x,
                y = y,
                size = 16,
                height = -250,
                zxz = jd1,
                yxz = 20,
                animespeed = 2
              })
              EffectcreateArgs({
                effect = "war3mapImported\\zhanji-blueX-shu.mdx",
                x = x,
                y = y,
                size = 60,
                height = 100,
                zxz = jd1,
                yxz = 20,
                animespeed = 6
              })
            end
            for _, xq in ac.selector():in_rangexy(x, y, 475):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              xq:groupadd(ng)
            end
            local ax, ay = PolarXY(x, y, 150, jd1)
            ForGroupLuaNew(ng, function(xq)
              if not xq:hasdata("免疫击退效果") then
                xq:setxy(ax, ay)
                xq:setflyheight(0)
              end
              DamageUnit({
                bj = "妖梦(机体)",
                unit = xq.handle,
                source = hero.handle,
                damage = txsh,
                level = 1,
                type = lx,
                isvest = false,
                isattack = true,
                isnoarmor = hj,
                element = "无"
              })
              xq:buffset(hero.handle, 1, "眩晕")
            end)
            if Group_Counts(ng) > 0 then
              u:changedata("终结剑技使用次数", 1)
              jqzhf(u, "WCFV")
            end
            t:remove()
          end
        end
      end)
    end)
  end,
  QCRV = function(u)
    du = u
    local sh, bs, x, y, hj, lx, angle = set()
    local jd = angle
    local txsh = 2.5 * sh
    if u:hasdata("妖梦天赋-天界剑") then
      ChangeValue(Hero_Tili, sy, 7)
    end
    u:animespeed(1)
    ac.wait(1, function()
      u:animeact(21)
    end)
    u:playsound(se_cat00)
    local qianyaotime = 0.8
    u:buffset(u.handle, qianyaotime + 1.1, "暂停")
    u:buffset(u.handle, qianyaotime + 1.1, "绝对闪避")
    u:buffset(u.handle, qianyaotime + 1.3, "无敌")
    u:effectadd("war3mapImported\\spellcardcall.mdx", "origin", qianyaotime)
    local ng = CreateGroupLua()
    local mza = false
    ac.wait(qianyaotime * 1000, function()
      u:animeact(8)
      u:animespeed(2)
      local cs = 0
      local cs1 = 0
      ac.loop(100, function(t)
        local dx, dy = PolarXY(x, y, 200 * cs, jd)
        local sj = (10 - cs) * 100
        local jd1 = jd - GetRandomReal(50, 75)
        jd1 = jd1 + 180
        local mz = false
        for _, xq in ac.selector():in_rangexy(dx, dy, 350):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          xq:groupadd(ng)
          if not xq:hasdata("免疫击退效果") then
            local ax, ay = xq:getxy()
            ax, ay = PolarXY(ax, ay, 190, jd)
            xq:setxy(ax, ay)
          end
          DamageUnit({
            bj = "妖梦(机体)",
            unit = xq.handle,
            source = hero.handle,
            damage = txsh,
            level = 1,
            type = lx,
            isvest = false,
            isattack = true,
            isnoarmor = hj,
            element = "无"
          })
          xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
          if not mz then
            mz = true
            mza = true
            jqzhf(u, "QCRV")
          end
        end
        u:setxy(dx, dy)
        u:animeact(GetRandomInt(7, 9))
        if u:getdata("umpf_paopao") == true then
          local rjd = GetRandomReal(0, 10)
          local rjd2 = GetRandomReal(0, 10)
          local tx = EffectcreateArgs({
            effect = "war3mapImported\\umpf_paopao_daoguang1.mdx",
            x = dx,
            y = dy,
            size = 4,
            height = 0,
            zxz = jd1,
            xxz = rjd,
            yxz = rjd2,
            animespeed = 2
          })
          ac.wait(100, function()
            japi.EXSetEffectSpeed(tx, 0)
          end)
          ac.wait(sj, function()
            japi.EXSetEffectSpeed(tx, 1)
            EffectcreateArgs({
              effect = "war3mapImported\\umpf_paopao_daoguang5.mdx",
              x = dx,
              y = dy,
              size = 15,
              height = 100,
              zxz = jd1,
              xxz = rjd,
              yxz = rjd2,
              animespeed = 6
            })
          end)
        else
          local tx = EffectcreateArgs({
            effect = "war3mapImported\\zhanji-blueX-shu.mdx",
            x = dx,
            y = dy,
            size = 4,
            height = 100,
            zxz = jd1,
            animespeed = 2
          })
          ac.wait(100, function()
            japi.EXSetEffectSpeed(tx, 0)
          end)
          ac.wait(sj, function()
            japi.EXSetEffectSpeed(tx, 1)
            EffectcreateArgs({
              effect = "war3mapImported\\zhanji-sakura2.mdx",
              x = dx,
              y = dy,
              size = 5,
              height = 100,
              zxz = jd1,
              animespeed = 2
            })
          end)
        end
        cs = cs + 1
        PlayGlobalSound(Sound_Ym_F12)
        if cs == 1 then
          PlayGlobalSound(ym_dxfswxz)
        end
        if cs <= 8 then
          u:shockcamera(100, 0.1)
        end
        if 10 <= cs then
          u:animeact(8)
          u:shockcamera(300, 0.2)
          jd = jd + 180
          x, y = u:getxy()
          local dx1, dy1 = PolarXY(x, y, 1000, jd)
          if u:getdata("umpf_paopao") == true then
            EffectcreateArgs({
              effect = "war3mapImported\\umpf_paopao_daoguang1.mdx",
              x = dx1,
              y = dy1,
              size = 8,
              height = 0,
              zxz = jd - 15,
              animespeed = 2
            })
            EffectcreateArgs({
              effect = "war3mapImported\\umpf_paopao_daoguang5.mdx",
              x = dx1,
              y = dy1,
              size = 30,
              height = 100,
              zxz = jd - 15,
              animespeed = 6
            })
            EffectcreateArgs({
              effect = "war3mapImported\\umpf_paopao_daoguang1.mdx",
              x = dx1,
              y = dy1,
              size = 8,
              height = 0,
              zxz = jd + 15,
              animespeed = 2
            })
            EffectcreateArgs({
              effect = "war3mapImported\\umpf_paopao_daoguang5.mdx",
              x = dx1,
              y = dy1,
              size = 30,
              height = 100,
              zxz = jd + 15,
              animespeed = 6
            })
          else
            EffectcreateArgs({
              effect = "war3mapImported\\zhanji-sakura2.mdx",
              x = dx1,
              y = dy1,
              size = 8,
              height = 0,
              zxz = jd - 15,
              animespeed = 2
            })
            EffectcreateArgs({
              effect = "war3mapImported\\zhanji-blueX-shu.mdx",
              x = dx1,
              y = dy1,
              size = 30,
              height = 100,
              zxz = jd - 15,
              animespeed = 6
            })
            EffectcreateArgs({
              effect = "war3mapImported\\zhanji-sakura2.mdx",
              x = dx1,
              y = dy1,
              size = 8,
              height = 0,
              zxz = jd + 15,
              animespeed = 2
            })
            EffectcreateArgs({
              effect = "war3mapImported\\zhanji-blueX-shu.mdx",
              x = dx1,
              y = dy1,
              size = 30,
              height = 100,
              zxz = jd + 15,
              animespeed = 6
            })
          end
          local nx, ny = PolarXY(x, y, 2000, jd)
          local nx2, ny2 = PolarXY(nx, ny, 150, jd)
          u:setxy(nx, ny)
          ForGroupLuaNew(ng, function(xq)
            if not xq:hasdata("免疫击退效果") then
              xq:setxy(nx2, ny2)
            end
            DamageUnit({
              bj = "妖梦(机体)",
              unit = xq.handle,
              source = hero.handle,
              damage = 4 * txsh,
              level = 1,
              type = lx,
              isvest = false,
              isattack = true,
              isnoarmor = hj,
              element = "无"
            })
            xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
            if not mz then
              mz = true
              mza = true
              jqzhf(u, "QCRV")
            end
          end)
          if mza then
            u:changedata("终结剑技使用次数", 1)
          end
          u:setface(jd)
          t:remove()
        end
      end)
    end)
  end,
  QCWWCQV = function(u)
    du = u
    local sh, bs, x, y, hj, lx, angle = set()
    local jd = angle
    local txsh = 2 * sh
    if u:hasdata("妖梦天赋-天界剑") then
      ChangeValue(Hero_Tili, sy, 7)
    end
    u:animespeed(1)
    ac.wait(1, function()
      u:animeact(21)
    end)
    u:playsound(se_cat00)
    local qianyaotime = 0.8
    u:buffset(u.handle, qianyaotime + 1.1, "暂停")
    u:buffset(u.handle, qianyaotime + 1.3, "无敌")
    u:effectadd("war3mapImported\\spellcardcall.mdx", "origin", qianyaotime)
    local ng = CreateGroupLua()
    ac.wait(qianyaotime * 1000, function()
      u:animeact(8)
      u:animespeed(1.5)
      local mza = false
      ac.wait(100, function()
        local mz = false
        for _, xq in ac.selector():in_rangexy(x, y, 900):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
          DamageUnit({
            bj = "妖梦(机体)",
            unit = xq.handle,
            source = hero.handle,
            damage = txsh,
            level = 1,
            type = lx,
            isvest = false,
            isattack = true,
            isnoarmor = hj,
            element = "无"
          })
          xq:buffset(hero.handle, 1, "眩晕")
          if not mz then
            mz = true
            mza = true
            jqzhf(u, "QCWWCQV")
          end
        end
      end)
      ac.wait(600, function()
        local mz = false
        for _, xq in ac.selector():in_rangexy(x, y, 900):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
          DamageUnit({
            bj = "妖梦(机体)",
            unit = xq.handle,
            source = hero.handle,
            damage = txsh,
            level = 1,
            type = lx,
            isvest = false,
            isattack = true,
            isnoarmor = hj,
            element = "无"
          })
          xq:buffset(hero.handle, 1, "眩晕")
          if not mz then
            mz = true
            mza = true
            jqzhf(u, "QCWWCQV")
          end
        end
      end)
      ac.wait(1100, function()
        local mz = false
        for _, xq in ac.selector():in_rangexy(x, y, 900):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
          DamageUnit({
            bj = "妖梦(机体)",
            unit = xq.handle,
            source = hero.handle,
            damage = 3 * txsh,
            level = 1,
            type = lx,
            isvest = false,
            isattack = true,
            isnoarmor = hj,
            element = "无"
          })
          xq:buffset(hero.handle, 2, "眩晕")
          if not mz then
            mz = true
            mza = true
            jqzhf(u, "QCWWCQV")
          end
        end
        if mza then
          u:changedata("终结剑技使用次数", 1)
        end
      end)
      ac.wait(100, function()
        u:shockcamera(100, 0.2)
        PlayGlobalSound(Sound_Ym_F12)
        local dx, dy = PolarXY(x, y, 600, jd)
        local dx1, dy1 = PolarXY(x, y, 600, jd + 180)
        if u:getdata("umpf_paopao") == true then
          local tx = EffectcreateArgs({
            effect = "war3mapImported\\umpf_paopao_daoguang1.mdx",
            x = dx,
            y = dy,
            size = 4,
            height = 0,
            zxz = jd - 90,
            animespeed = 2
          })
          local tx1 = EffectcreateArgs({
            effect = "war3mapImported\\umpf_paopao_daoguang1.mdx",
            x = dx1,
            y = dy1,
            size = 4,
            height = 0,
            zxz = jd + 90,
            animespeed = 2
          })
          ac.wait(100, function()
            japi.EXSetEffectSpeed(tx, 0)
            japi.EXSetEffectSpeed(tx1, 0)
          end)
          ac.wait(1000, function()
            japi.EXSetEffectSpeed(tx, 1)
            japi.EXSetEffectSpeed(tx1, 1)
            EffectcreateArgs({
              effect = "war3mapImported\\umpf_paopao_daoguang5.mdx",
              x = dx,
              y = dy,
              size = 15,
              height = 100,
              zxz = jd - 90,
              animespeed = 6
            })
            EffectcreateArgs({
              effect = "war3mapImported\\umpf_paopao_daoguang5.mdx",
              x = dx1,
              y = dy1,
              size = 15,
              height = 100,
              zxz = jd + 90,
              animespeed = 6
            })
          end)
        else
          local tx = EffectcreateArgs({
            effect = "war3mapImported\\zhanji-blueX-shu.mdx",
            x = dx,
            y = dy,
            size = 4,
            height = 50,
            zxz = jd - 90,
            animespeed = 2
          })
          local tx1 = EffectcreateArgs({
            effect = "war3mapImported\\zhanji-blueX-shu.mdx",
            x = dx1,
            y = dy1,
            size = 4,
            height = 50,
            zxz = jd + 90,
            animespeed = 2
          })
          ac.wait(100, function()
            japi.EXSetEffectSpeed(tx, 0)
            japi.EXSetEffectSpeed(tx1, 0)
          end)
          ac.wait(1000, function()
            japi.EXSetEffectSpeed(tx, 1)
            japi.EXSetEffectSpeed(tx1, 1)
            EffectcreateArgs({
              effect = "war3mapImported\\zhanji-sakura2.mdx",
              x = dx,
              y = dy,
              size = 5,
              height = 100,
              zxz = jd - 90,
              animespeed = 1
            })
            EffectcreateArgs({
              effect = "war3mapImported\\zhanji-sakura2.mdx",
              x = dx1,
              y = dy1,
              size = 5,
              height = 100,
              zxz = jd + 90,
              animespeed = 1
            })
          end)
        end
      end)
      ac.wait(600, function()
        u:shockcamera(100, 0.2)
        PlayGlobalSound(Sound_Ym_F12)
        local dx, dy = PolarXY(x, y, 600, jd + 45)
        local dx1, dy1 = PolarXY(x, y, 600, jd - 45)
        if u:getdata("umpf_paopao") == true then
          local tx = EffectcreateArgs({
            effect = "war3mapImported\\umpf_paopao_daoguang1.mdx",
            x = dx,
            y = dy,
            size = 4,
            height = 0,
            zxz = jd - 45,
            animespeed = 2
          })
          local tx1 = EffectcreateArgs({
            effect = "war3mapImported\\umpf_paopao_daoguang1.mdx",
            x = dx1,
            y = dy1,
            size = 4,
            height = 0,
            zxz = jd + 45,
            animespeed = 2
          })
          ac.wait(100, function()
            japi.EXSetEffectSpeed(tx, 0)
            japi.EXSetEffectSpeed(tx1, 0)
          end)
          ac.wait(500, function()
            japi.EXSetEffectSpeed(tx, 1)
            japi.EXSetEffectSpeed(tx1, 1)
            EffectcreateArgs({
              effect = "war3mapImported\\umpf_paopao_daoguang5.mdx",
              x = dx,
              y = dy,
              size = 15,
              height = 100,
              zxz = jd - 45,
              animespeed = 6
            })
            EffectcreateArgs({
              effect = "war3mapImported\\umpf_paopao_daoguang5.mdx",
              x = dx1,
              y = dy1,
              size = 15,
              height = 100,
              zxz = jd + 45,
              animespeed = 6
            })
          end)
        else
          local tx = EffectcreateArgs({
            effect = "war3mapImported\\zhanji-blueX-shu.mdx",
            x = dx,
            y = dy,
            size = 4,
            height = 50,
            zxz = jd - 45,
            animespeed = 2
          })
          local tx1 = EffectcreateArgs({
            effect = "war3mapImported\\zhanji-blueX-shu.mdx",
            x = dx1,
            y = dy1,
            size = 4,
            height = 50,
            zxz = jd + 45,
            animespeed = 2
          })
          ac.wait(200, function()
            japi.EXSetEffectSpeed(tx, 0)
            japi.EXSetEffectSpeed(tx1, 0)
          end)
          ac.wait(500, function()
            japi.EXSetEffectSpeed(tx, 1)
            japi.EXSetEffectSpeed(tx1, 1)
            EffectcreateArgs({
              effect = "war3mapImported\\zhanji-sakura2.mdx",
              x = dx,
              y = dy,
              size = 5,
              height = 100,
              zxz = jd - 45,
              animespeed = 1
            })
            EffectcreateArgs({
              effect = "war3mapImported\\zhanji-sakura2.mdx",
              x = dx1,
              y = dy1,
              size = 5,
              height = 100,
              zxz = jd + 45,
              animespeed = 1
            })
          end)
        end
      end)
      ac.wait(600, function()
        local dx, dy = PolarXY(x, y, 600, jd + 45 + 180)
        local dx1, dy1 = PolarXY(x, y, 600, jd - 45 - 180)
        if u:getdata("umpf_paopao") == true then
          local tx = EffectcreateArgs({
            effect = "war3mapImported\\umpf_paopao_daoguang1.mdx",
            x = dx,
            y = dy,
            size = 4,
            height = 0,
            zxz = jd - 45,
            animespeed = 2
          })
          local tx1 = EffectcreateArgs({
            effect = "war3mapImported\\umpf_paopao_daoguang1.mdx",
            x = dx1,
            y = dy1,
            size = 4,
            height = 0,
            zxz = jd + 45,
            animespeed = 2
          })
          ac.wait(100, function()
            japi.EXSetEffectSpeed(tx, 0)
            japi.EXSetEffectSpeed(tx1, 0)
          end)
          ac.wait(500, function()
            japi.EXSetEffectSpeed(tx, 1)
            japi.EXSetEffectSpeed(tx1, 1)
            EffectcreateArgs({
              effect = "war3mapImported\\umpf_paopao_daoguang5.mdx",
              x = dx,
              y = dy,
              size = 15,
              height = 100,
              zxz = jd - 45,
              animespeed = 6
            })
            EffectcreateArgs({
              effect = "war3mapImported\\umpf_paopao_daoguang5.mdx",
              x = dx1,
              y = dy1,
              size = 15,
              height = 100,
              zxz = jd + 45,
              animespeed = 6
            })
          end)
        else
          local tx = EffectcreateArgs({
            effect = "war3mapImported\\zhanji-blueX-shu.mdx",
            x = dx,
            y = dy,
            size = 4,
            height = 50,
            zxz = jd - 45,
            animespeed = 2
          })
          local tx1 = EffectcreateArgs({
            effect = "war3mapImported\\zhanji-blueX-shu.mdx",
            x = dx1,
            y = dy1,
            size = 4,
            height = 50,
            zxz = jd + 45,
            animespeed = 2
          })
          ac.wait(200, function()
            japi.EXSetEffectSpeed(tx, 0)
            japi.EXSetEffectSpeed(tx1, 0)
          end)
          ac.wait(500, function()
            japi.EXSetEffectSpeed(tx, 1)
            japi.EXSetEffectSpeed(tx1, 1)
            EffectcreateArgs({
              effect = "war3mapImported\\zhanji-sakura2.mdx",
              x = dx,
              y = dy,
              size = 5,
              height = 100,
              zxz = jd - 45,
              animespeed = 1
            })
            EffectcreateArgs({
              effect = "war3mapImported\\zhanji-sakura2.mdx",
              x = dx1,
              y = dy1,
              size = 5,
              height = 100,
              zxz = jd + 45,
              animespeed = 1
            })
          end)
        end
      end)
      ac.wait(1100, function()
        u:shockcamera(300, 0.2)
        PlayGlobalSound(Sound_Ym_F12)
        PlayGlobalSound(Sound_Ym_F02_2)
        SetSoundPlayPosition(Sound_Ym_F02_2, 600)
        for i = 1, 6 do
          if u:getdata("umpf_paopao") == true then
            EffectcreateArgs({
              effect = "war3mapImported\\umpf_paopao_baozha6.mdl",
              x = x,
              y = y,
              time = 1,
              size = 2,
              height = 0,
              zxz = i * 60,
              animespeed = 2
            })
          else
            EffectcreateArgs({
              effect = "war3mapImported\\4496844d540a9969.mdl",
              x = x,
              y = y,
              size = 8,
              height = -400,
              zxz = i * 60,
              animespeed = 2
            })
            EffectcreateArgs({
              effect = "war3mapImported\\Daji_fen.mdl",
              x = x,
              y = y,
              time = 1,
              size = 4,
              height = 0,
              zxz = i * 60,
              animespeed = 1
            })
          end
        end
      end)
    end)
  end,
  ACRV = function(u)
    du = u
    local sh, bs, x, y, hj, lx, angle = set()
    local txsh = 1.5 * sh
    if u:hasdata("妖梦天赋-天界剑") then
      ChangeValue(Hero_Tili, sy, 7)
    end
    u:animespeed(1)
    ac.wait(1, function()
      u:animeact(21)
    end)
    u:effectadd("war3mapImported\\spellcardcall.mdx", "origin", 0.8)
    u:buffset(u.handle, 2, "暂停")
    u:buffset(u.handle, 2.1, "无敌")
    local xq = getunit(BOSS_DEATH)
    local fw = 380 * bs
    local sx = 16
    local x2, y2 = u:getxy()
    x2, y2 = PolarXY(x2, y2, 100, angle)
    if hero:hasdata("妖梦天赋-樱花剑") then
      local x3, y3 = PolarXY(x2, y2, 250, angle)
      for _, xq in ac.selector():in_rangexy(x3, y3, fw):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        xq:buffset(hero.handle, 1.5, "僵直")
      end
    end
    for _, xq in ac.selector():in_rangexy(x2, y2, fw):is_enemy(u.handle):ipairs() do
      xq = getunit(xq)
      xq:buffset(hero.handle, 1.5, "僵直")
    end
    if xq.handle ~= BOSS_DEATH then
      u:playsound(Youmu_ACRV_Ok)
      u:changedata("终结剑技使用次数", 1)
    else
      u:playsound(Youmu_ACRV_Miss)
    end
    ac.wait(800, function()
      u:animeact(8)
      local g2 = CreateGroupLua()
      local cs = 0
      ac.loop(120, function(timer)
        cs = cs + 1
        x, y = u:getxy()
        x, y = PolarXY(x, y, 100, angle)
        local mz = false
        if u:getdata("umpf_paopao") == true then
          Effectcreate("war3mapImported\\umpf_paopao_guangzhu1.mdl", x, y, 0, 3, -700)
          Effectcreate("war3mapImported\\umpf_paopao_baozha6.mdl", x, y, 1, 1, 0, GetRandomAngle())
        else
          Effectcreate("war3mapImported\\senbonzakurapart1.mdl", x, y)
          Effectcreate("war3mapImported\\uuz_sakuraexplosion.mdl", x, y)
        end
        GroupClearLua(g2)
        if hero:hasdata("妖梦天赋-樱花剑") then
          local x3, y3 = PolarXY(x, y, 300, angle)
          if u:getdata("umpf_paopao") == true then
            Effectcreate("war3mapImported\\umpf_paopao_guangzhu1.mdl", x, y, 0, 3, -700)
            Effectcreate("war3mapImported\\umpf_paopao_baozha6.mdl", x, y, 1, 1)
          else
            Effectcreate("war3mapImported\\senbonzakurapart1.mdl", x, y)
            Effectcreate("war3mapImported\\uuz_sakuraexplosion.mdl", x, y)
          end
          for _, xq in ac.selector():in_rangexy(x3, y3, fw):is_enemy(u.handle):isnotingroup(g2):ipairs() do
            xq = getunit(xq)
            xq:groupadd(g2)
            if not mz then
              mz = true
              jqzhf(u, "ACRV")
            end
            DamageUnit({
              bj = "妖梦(机体)",
              unit = xq.handle,
              source = hero.handle,
              damage = txsh,
              level = 1,
              type = lx,
              isvest = false,
              isattack = true,
              isnoarmor = hj,
              element = "无"
            })
            xq:buffset(hero.handle, 0.25, "眩晕")
          end
        end
        for _, xq in ac.selector():in_rangexy(x, y, fw):is_enemy(u.handle):isnotingroup(g2):ipairs() do
          xq = getunit(xq)
          xq:groupadd(g2)
          if not mz then
            mz = true
            jqzhf(u, "ACRV")
          end
          DamageUnit({
            bj = "妖梦(机体)",
            unit = xq.handle,
            source = hero.handle,
            damage = txsh,
            level = 1,
            type = lx,
            isvest = false,
            isattack = true,
            isnoarmor = hj,
            element = "无"
          })
          xq:buffset(hero.handle, 0.25, "眩晕")
        end
        if cs == 10 then
          timer:remove()
        end
      end)
    end)
  end,
  ACWV = function(u)
    du = u
    local sh, bs, x, y, hj, lx, angle = set()
    local txsh = 6 * sh
    if u:hasdata("妖梦天赋-天界剑") then
      ChangeValue(Hero_Tili, sy, 7)
    end
    u:animespeed(1)
    ac.wait(1, function()
      u:animeact(21)
    end)
    u:effectadd("war3mapImported\\spellcardcall.mdx", "origin", 0.8)
    u:buffset(u.handle, 1, "暂停")
    u:buffset(u.handle, 1, "无敌")
    local mza = false
    local xq = getunit(BOSS_DEATH)
    local x2, y2 = u:getxy()
    local fw = 256 * bs
    for i = 1, 10 do
      x2, y2 = PolarXY(x2, y2, 150, angle)
      for _, xq in ac.selector():in_rangexy(x2, y2, fw):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        mza = true
      end
    end
    if mza then
      u:playsound(Youmu_ACWV_Ok)
      u:changedata("终结剑技使用次数", 1)
    else
      u:playsound(Youmu_ACWV_Miss)
    end
    ac.wait(800, function()
      u:animeact(14)
      local g2 = CreateGroupLua()
      x, y = u:getxy()
      local t = 0.6
      local t2 = 0.3
      if hero:hasdata("妖梦天赋-狱神剑") then
        t = 0.4
        t2 = 0.3
      end
      u:buffset(u.handle, t, "暂停")
      u:buffset(u.handle, t + 0.1, "无敌")
      unitmove({
        unit = u.handle,
        time = t,
        distance = 1200,
        angle = angle,
        isfly = true,
        loops = {
          {
            looptime = 0.03,
            func = function(dx, dy)
              if u:getdata("umpf_paopao") == true then
                Effectcreate("war3mapImported\\umpf_paopao_guangzhu1.mdl", dx, dy, 0, 3, -700)
                Effectcreate("war3mapImported\\umpf_paopao_baozha6.mdl", dx, dy, 1, 1, 0, GetRandomAngle())
              else
                Effectcreate("war3mapImported\\senbonzakurapart.mdx", dx, dy)
              end
            end
          }
        },
        endfunc = function(dx, dy)
          u:setdata("位移点X", dx)
          u:setdata("位移点Y", dy)
        end
      })
      local mz = false
      ac.wait(t2 * 1000, function()
        loopmove({
          x = x,
          y = y,
          time = t,
          distance = 1200,
          angle = angle,
          loops = {
            {
              looptime = 0.03,
              func = function(dx, dy)
                Effectcreate("war3mapImported\\senbonzakurapart1.mdl", dx, dy)
                Effectcreate("war3mapImported\\uuz_sakuraexplosion.mdl", dx, dy)
                for _, xq in ac.selector():in_rangexy(dx, dy, fw):is_enemy(u.handle):isnotingroup(g2):ipairs() do
                  xq = getunit(xq)
                  xq:groupadd(g2)
                  if not mz then
                    mz = true
                    jqzhf(u, "ACWV")
                    ac.wait(50, function()
                      jqzhf(u, "ACWV")
                    end)
                    ac.wait(100, function()
                      jqzhf(u, "ACWV")
                    end)
                  end
                  DamageUnit({
                    bj = "妖梦(机体)",
                    unit = xq.handle,
                    source = hero.handle,
                    damage = txsh,
                    level = 1,
                    type = lx,
                    isvest = false,
                    isattack = true,
                    isnoarmor = hj,
                    element = "无"
                  })
                  ac.wait(50, function()
                    DamageUnit({
                      bj = "妖梦(机体)",
                      unit = xq.handle,
                      source = hero.handle,
                      damage = txsh,
                      level = 1,
                      type = lx,
                      isvest = false,
                      isattack = true,
                      isnoarmor = hj,
                      element = "无"
                    })
                  end)
                  ac.wait(100, function()
                    DamageUnit({
                      bj = "妖梦(机体)",
                      unit = xq.handle,
                      source = hero.handle,
                      damage = txsh,
                      level = 1,
                      type = lx,
                      isvest = false,
                      isattack = true,
                      isnoarmor = hj,
                      element = "无"
                    })
                  end)
                  xq:buffset(hero.handle, 1.25, "眩晕")
                end
              end
            }
          },
          endfunc = function(dx, dy)
          end
        })
      end)
    end)
  end,
  ACEFRV = function(u)
    du = u
    local sh, bs, x, y, hj, lx, angle = set()
    local txsh = 5 * sh
    if u:hasdata("妖梦天赋-天界剑") then
      ChangeValue(Hero_Tili, sy, 7)
    end
    u:animespeed(1)
    ac.wait(1, function()
      u:animeact(15)
    end)
    u:effectadd("war3mapImported\\spellcardcall.mdx", "origin", 0.8)
    u:buffset(u.handle, 2.6, "暂停")
    u:buffset(u.handle, 2.6, "绝对闪避")
    u:buffset(u.handle, 2.9, "无敌")
    u:playsound(Sound_Ym_F03)
    u:playsound(Sound_Ym_F03_2)
    SetSoundVolume(Sound_Ym_F03, 0)
    ac.wait(500, function()
      local cs1 = 0
      local xz = false
      local mz = false
      ac.loop(300, function(timer)
        cs1 = cs1 + 1
        x, y = PolarXY(x, y, 100, angle)
        u:setxy(x, y)
        local dx = GetRandomReal(0.5, 1)
        local ry = GetRandomReal(-20, 20)
        if 5 < cs1 then
          dx = 1.5
          ry = GetRandomReal(-10, 10)
        end
        if u:getdata("umpf_paopao") == true then
          local tx = Effectcreate("war3mapImported\\umpf_paopao_daoguang4.mdl", x, y, -1, dx, 150, 0, 0, ry)
          SetEffectActSpeed(tx, GetRandomReal(0.75, 2))
          DestroyEffectLua(tx)
        else
          local tx = Effectcreate("war3mapImported\\Zhanji_Hong.mdl", x, y, -1, dx, 150, 0, 0, ry)
          SetEffectActSpeed(tx, GetRandomReal(0.75, 2))
          DestroyEffectLua(tx)
        end
        u:animeact(9)
        u:animespeed(2)
        local mzhf = false
        for _, xq in ac.selector():in_rangexy(x, y, 375):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          mz = true
          if not mzhf then
            mzhf = true
            jqzhf(u, "ACEFRV")
          end
          local x2, y2 = xq:getxy()
          x2, y2 = PolarXY(x2, y2, 100, angle)
          xq:setxy(x2, y2)
          u:setdata("妖梦-剑技固伤", 0.005)
          DamageUnit({
            bj = "妖梦(机体)",
            unit = xq.handle,
            source = hero.handle,
            damage = txsh,
            level = 1,
            type = lx,
            isvest = false,
            isattack = true,
            isnoarmor = hj,
            element = "无"
          })
          u:deldata("妖梦-剑技固伤")
          xq:buffset(hero.handle, 1, "眩晕")
          for i = 1, 3 do
            if u:getdata("umpf_paopao") == true then
              local tx = Effectcreate("war3mapImported\\umpf_paopao_daoguang5.mdx", x2, y2, -1, GetRandomReal(4, 6), 100, GetRandomReal(0, 360), 0, GetRandomReal(-20, 20), 2.0)
              SetEffectActSpeed(tx, GetRandomReal(3, 5))
              DestroyEffectLua(tx)
            else
              local tx = Effectcreate("war3mapImported\\zhanji-sakura2.mdx", x2, y2, -1, GetRandomReal(0.5, 1), 100, GetRandomReal(0, 360), 0, GetRandomReal(-20, 20))
              SetEffectActSpeed(tx, GetRandomReal(1, 2))
              DestroyEffectLua(tx)
            end
          end
        end
        if 5 < cs1 then
          u:animespeed(1)
          CameraSetEQNoiseForPlayer(u.owner, 100.0)
          ac.wait(250, function()
            CameraClearNoiseForPlayer(u.owner)
          end)
          ac.wait(200, function()
            Effectcreate("war3mapImported\\xushizhendi.mdl", x, y, 0, 3, 0, GetRandomReal(0, 360))
            if u:getdata("umpf_paopao") == true then
              local tx = Effectcreate("war3mapImported\\umpf_paopao_daoguang4.mdl", x, y, -1, 1.5, 150, GetRandomReal(0, 360), 0, 0, 2)
              SetEffectActSpeed(tx, GetRandomReal(0.75, 2))
              DestroyEffectLua(tx)
            else
              local tx = Effectcreate("war3mapImported\\Zhanji_Hong.mdl", x, y, -1, 1.5, 150, GetRandomReal(0, 360))
              SetEffectActSpeed(tx, GetRandomReal(0.75, 2))
              DestroyEffectLua(tx)
            end
            local mzhf = false
            for _, xq in ac.selector():in_rangexy(x, y, 650):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              mz = true
              if not mzhf then
                mzhf = true
                jqzhf(u, "ACEFRV")
              end
              local x2, y2 = xq:getxy()
              x2, y2 = PolarXY(x2, y2, 100, angle)
              xq:setxy(x2, y2)
              u:setdata("妖梦-剑技固伤", 0.02)
              DamageUnit({
                bj = "妖梦(机体)",
                unit = xq.handle,
                source = hero.handle,
                damage = 3 * txsh,
                level = 1,
                type = lx,
                isvest = false,
                isattack = true,
                isnoarmor = hj,
                element = "无"
              })
              u:deldata("妖梦-剑技固伤")
              xq:buffset(hero.handle, 2, "眩晕")
              for i = 1, 3 do
                if u:getdata("umpf_paopao") == true then
                  local tx = Effectcreate("war3mapImported\\umpf_paopao_daoguang1.mdx", x2, y2, -1, GetRandomReal(3, 5), 100, GetRandomReal(0, 360), 0, GetRandomReal(-20, 20), 2.0)
                  SetEffectActSpeed(tx, GetRandomReal(1, 2))
                  DestroyEffectLua(tx)
                else
                  local tx = Effectcreate("war3mapImported\\zhanji-sakura2.mdx", x2, y2, -1, GetRandomReal(3, 5), 100, GetRandomReal(0, 360), 0, GetRandomReal(-20, 20))
                  SetEffectActSpeed(tx, GetRandomReal(1, 2))
                  DestroyEffectLua(tx)
                end
              end
            end
          end)
        end
        if mz then
          SetSoundVolume(Sound_Ym_F03, 127)
          SetSoundVolume(Sound_Ym_F03_2, 0)
        end
        if 5 < cs1 then
          if mz then
            u:changedata("终结剑技使用次数", 1)
          end
          timer:remove()
        end
      end)
    end)
  end,
  DCAV = function(u)
    du = u
    local sh, bs, x, y, hj, lx, angle = set()
    local txsh = 3.5 * sh
    if u:hasdata("妖梦天赋-天界剑") then
      ChangeValue(Hero_Tili, sy, 7)
    end
    if u:hasdata("魂符幻象") then
      local x2, y2 = hero:getxy()
      x, y = PolarXY(x, y, 1600, angle)
      u:setxy(x, y)
      angle = hero:getface() + 180
      u:setface(angle)
    end
    u:animespeed(1)
    ac.wait(1, function()
      u:animeact(7)
    end)
    u:effectadd("war3mapImported\\spellcardcall.mdx", "origin", 0.8)
    u:buffset(u.handle, 1.5, "暂停")
    u:buffset(u.handle, 1.5, "绝对闪避")
    u:buffset(u.handle, 1.8, "无敌")
    u:playsound(se_cat00)
    ac.timer(250, 4, function()
      if u:getdata("umpf_paopao") == true then
        local tx = Effectcreate("war3mapImported\\umpf_paopao_quan1.mdx", x, y, 0.2, 1, 20, 0, 0, 0, 1)
        SetEffectActSpeed(tx, 2)
        local tx = Effectcreate("war3mapImported\\umpf_paopao_baozha3.mdx", x, y, -1, 1.5, 0, 0, 0, 0, 1)
        SetEffectActSpeed(tx, 2)
        DestroyEffectLua(tx)
      else
        local tx = Effectcreate("war3mapImported\\ympf_baoqi1.mdx", x, y, -1, 1)
        SetEffectActSpeed(tx, 2)
        DestroyEffectLua(tx)
      end
    end)
    ac.wait(500, function()
      PlayGlobalSound(ym_dxfswxz)
    end)
    ac.wait(1050, function()
      u:playsound(se_slash)
    end)
    ac.wait(1250, function()
      CameraSetEQNoiseForPlayer(u.owner, 200.0)
      ac.wait(150, function()
        CameraClearNoiseForPlayer(u.owner)
      end)
      for i = 1, 3 do
        local x2, y2 = PolarXY(x, y, 900, angle + 90 * (i - 2))
        if u:getdata("umpf_paopao") == true then
          local tx = Effectcreate("war3mapImported\\umpf_paopao_daoguang1.mdl", x2, y2, -1, 4, -100, angle, 0, 0, 2)
          SetEffectActSpeed(tx, 2)
          DestroyEffectLua(tx)
          local tx1 = Effectcreate("war3mapImported\\umpf_paopao_daoguang5.mdl", x2, y2, -1, 15, -100, angle, 0, 0, 6)
          SetEffectActSpeed(tx1, 2)
          DestroyEffectLua(tx1)
        else
          local tx = Effectcreate("war3mapImported\\ympf_daoguang5.mdl", x2, y2, -1, 6, -100, angle)
          SetEffectActSpeed(tx, 2)
          DestroyEffectLua(tx)
        end
      end
      local txstr
      if u:getdata("umpf_paopao") == true then
        txstr = "war3mapImported\\BOSS_4D_danmu1.mdl"
      else
        txstr = "war3mapImported\\ym_dm.mdx"
      end
      local mzhf = false
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
            func = function(dx, dy)
              for _, xq in ac.selector():in_rangexy(dx, dy, 400):is_enemy(u.handle):isnotingroup(g2):ipairs() do
                xq = getunit(xq)
                xq:groupadd(g2)
                if not mzhf then
                  mzhf = true
                  jqzhf(u, "DCAV")
                end
                local x2, y2 = xq:getxy()
                x2, y2 = PolarXY(x2, y2, 50, angle)
                xq:setxy(x2, y2)
                DamageUnit({
                  bj = "妖梦(机体)",
                  unit = xq.handle,
                  source = hero.handle,
                  damage = txsh,
                  level = 1,
                  type = lx,
                  isvest = false,
                  isattack = true,
                  isnoarmor = hj,
                  element = "无"
                })
                ac.wait(50, function()
                  DamageUnit({
                    bj = "妖梦(机体)",
                    unit = xq.handle,
                    source = hero.handle,
                    damage = txsh,
                    level = 1,
                    type = lx,
                    isvest = false,
                    isattack = true,
                    isnoarmor = hj,
                    element = "无"
                  })
                end)
                ac.wait(100, function()
                  DamageUnit({
                    bj = "妖梦(机体)",
                    unit = xq.handle,
                    source = hero.handle,
                    damage = txsh,
                    level = 1,
                    type = lx,
                    isvest = false,
                    isattack = true,
                    isnoarmor = hj,
                    element = "无"
                  })
                end)
                xq:buffset(hero.handle, 2, "眩晕")
              end
            end
          }
        },
        endfunc = function()
          u:playsound(se_tan00)
          ac.wait(10, function()
            u:playsound(se_tan01)
          end)
          ac.wait(20, function()
            u:playsound(se_tan02)
          end)
          ac.timer(20, 25, function()
            local x3, y3 = PolarXY(x, y, GetRandomReal(-400, 400), angle + 90)
            local dtype
            if lx == "物理" then
              dtype = 2
            else
              dtype = 6
            end
            local mzhf = false
            unifycreate({
              owner = u.handle,
              model = txstr,
              modelname = "待宵卫星反射斩弹幕",
              modelsize = 1,
              height = GetRandomReal(50, 300),
              damage = txsh * 0.5,
              damagetype = dtype,
              x = x3,
              y = y3,
              range = GetRandomReal(2800, 3400),
              speed = 10000,
              volume = 200,
              angle = angle,
              angleoffset = 0,
              attenua = 1,
              attenuacount = 1,
              life = 10,
              isbullet = false,
              isvest = false,
              isignorearmor = hj,
              hitafterfunc = function(mj, xq, damage2)
                mj:effectadd("war3mapImported\\4cc960d99d71d473.mdx")
                if not mzhf then
                  mzhf = true
                  jqzhf(u, "DCAV-Extra")
                end
              end
            })
          end)
        end
      })
    end)
  end,
  ACWQCV = function(u)
    sy = du.ownerid
    local sh = u:getdata("角色基础伤害") + 1000 * u:getlevel()
    local bs = u:getdata("角色伤害范围")
    local angle = u:getface()
    local x, y = u:getxy()
    ResetUnitAnimation(u.handle)
    u:animespeed(1)
    ac.wait(1, function()
      u:animeact(15)
    end)
    PlayGlobalSound(Sound_Ym_F10)
    u:effectadd("war3mapImported\\spellcardcall.mdx", "origin", 0.8)
    local pdfw = 100
    local pdcs = 10
    local fw = 400
    if u:hasdata("妖梦天赋-狱神剑") then
      sh = sh * 2
      pdfw = 200
      pdcs = 15
      fw = 550
    end
    local sh1, sh2
    sh1 = (0.5 + 0.02 * u:getlevel()) * sh
    sh2 = (55 + 4 * u:getlevel()) * sh
    u:buffset(u.handle, 0.9, "暂停")
    u:buffset(u.handle, 0.9, "绝对闪避")
    u:buffset(u.handle, 0.9, "永恒")
    ac.wait(700, function()
      ResetUnitAnimation(u.handle)
      u:animespeed(1)
      u:animeact(30)
      Effectcreate("war3mapImported\\chongci_Bo.mdx", x, y, 0, 2, 0, angle + 180)
      local x2, y2 = PolarXY(x, y, 400, angle)
      if u:getdata("umpf_paopao") == true then
        EffectcreateArgs({
          effect = "war3mapImported\\umpf_paopao_daoguang1.mdx",
          x = x2,
          y = y2,
          size = 5,
          height = 0,
          zxz = angle,
          animespeed = 2
        })
        EffectcreateArgs({
          effect = "war3mapImported\\umpf_paopao_daoguang5.mdx",
          x = x2,
          y = y2,
          size = 20,
          height = 100,
          zxz = angle,
          animespeed = 6
        })
      else
        local tx = Effectcreate("war3mapImported\\File00000650.mdl", x2, y2, -1, 30, 0, angle)
        SetEffectActSpeed(tx, 2)
        DestroyEffectLua(tx)
      end
      local b = false
      local ishasboss = false
      for _, xq in ac.selector():in_rangexy(x, y, pdcs * 100 + 250):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        if xq:isboss() then
          ishasboss = true
        end
      end
      local mb
      unitmove({
        unit = u.handle,
        time = pdcs * 0.02,
        distance = pdcs * 100,
        angle = angle,
        isfly = true,
        loops = {
          {
            looptime = 0.02,
            func = function(dx, dy)
              if not b then
                for _, xq in ac.selector():in_rangexy(dx, dy, pdfw):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  if ishasboss then
                    if xq:isboss() then
                      b = true
                      mb = xq
                    end
                    break
                  end
                  b = true
                  mb = xq
                  break
                end
                if b then
                  if u:hasdata("妖梦天赋-天界剑") then
                    ChangeValue(Hero_Tili, sy, 50)
                  end
                  ShowUnit(u.handle, false)
                  u:setdata("未来永劫斩-破抗")
                  if mb:getdata("破防时间") > 0 then
                    u:setdata("未来永劫斩-破招")
                  end
                  u:buffset(u.handle, 3.4, "暂停")
                  u:buffset(u.handle, 5, "无敌")
                  local t = 3.65
                  if u:hasdata("妖梦天赋-人界剑") then
                    t = t + 1
                  end
                  u:buffset(u.handle, t, "永恒")
                  u:buffset(u.handle, 5, "绝对闪避")
                  CameraSetEQNoiseForPlayer(u.owner, 200.0)
                  ac.wait(150, function()
                    CameraClearNoiseForPlayer(u.owner)
                  end)
                  if u:getdata("umpf_paopao") == true then
                    for i = 1, 2 do
                      EffectcreateArgs({
                        effect = "war3mapImported\\umpf_paopao_yuzhou.mdx",
                        x = dx,
                        y = dy,
                        time = 3,
                        size = 15,
                        height = -1500,
                        zxz = GetRandomAngle(),
                        animespeed = 3
                      })
                    end
                  end
                  local g2 = CreateGroupLua()
                  for _, xq in ac.selector():in_rangexy(dx, dy, fw):is_enemy(u.handle):ipairs() do
                    xq = getunit(xq)
                    xq:groupadd(g2)
                    xq:buffset(u.handle, 4, "暂停")
                    xq:buffset(u.handle, 3.2, "锁定")
                    xq:buffset(u.handle, 4, "沉默")
                  end
                  local gd = 0
                  local qr = false
                  ac.loop(20, function(timer)
                    ForGroupLuaNew(g2, function(xq)
                      xq:setflyheight(gd)
                    end)
                    if 3000 < gd then
                      qr = true
                    end
                    if not qr then
                      gd = gd + 150
                    else
                      gd = gd - 150
                    end
                    if qr and gd == 600 then
                      PlayGlobalSound(Sound_Ym_F11)
                      local x3, y3 = mb:getxy()
                      CameraSetEQNoiseForPlayer(u.owner, 10.0)
                      ac.timer(100, 20, function()
                        local gd2 = GetUnitFlyHeight(mb.handle)
                        if u:getdata("umpf_paopao") == true then
                          for i = 1, 2 do
                            local tx = Effectcreate("war3mapImported\\umpf_paopao_daoguang3.mdl", x3, y3, 1, GetRandomReal(2, 5), gd2, GetRandomReal(0, 360), GetRandomReal(0, 180), GetRandomReal(-110, -80), 1)
                            SetEffectActSpeed(tx, 1.5)
                            local x4, y4 = PolarXY(x3, y3, GetRandomReal(-300, 300), GetRandomReal(0, 360))
                            local tx = Effectcreate("war3mapImported\\umpf_paopao_daoguang5.mdl", x4, y4, -1, GetRandomReal(8, 10), gd2, GetRandomReal(0, 360), GetRandomReal(0, 180), GetRandomReal(-110, -80))
                            SetEffectActSpeed(tx, GetRandomReal(4, 6))
                            DestroyEffectLua(tx)
                          end
                          for i = 1, 8 do
                            local x4, y4 = PolarXY(x3, y3, GetRandomReal(-500, 500), GetRandomReal(0, 360))
                            local tx = Effectcreate("war3mapImported\\ympf_shandian.mdx", x4, y4, -1, 30, -400, angle + GetRandomReal(0, 180))
                            SetEffectActSpeed(tx, 4)
                            DestroyEffectLua(tx)
                          end
                        else
                          for i = 1, 2 do
                            local tx = Effectcreate("war3mapImported\\Daoguang_1.mdl", x3, y3, -1, GetRandomReal(0.5, 2), gd2, GetRandomReal(0, 360), GetRandomReal(0, 180), GetRandomReal(-110, -80))
                            SetEffectActSpeed(tx, 1.5)
                            DestroyEffectLua(tx)
                            local x4, y4 = PolarXY(x3, y3, GetRandomReal(-300, 300), GetRandomReal(0, 360))
                            local tx = Effectcreate("war3mapImported\\Zhanji_Hong.mdl", x4, y4, -1, GetRandomReal(0.2, 2), gd2, GetRandomReal(0, 360), GetRandomReal(0, 180), GetRandomReal(-110, -80))
                            SetEffectActSpeed(tx, GetRandomReal(0.5, 2))
                            DestroyEffectLua(tx)
                          end
                          for i = 1, 8 do
                            local x4, y4 = PolarXY(x3, y3, GetRandomReal(-500, 500), GetRandomReal(0, 360))
                            local tx = Effectcreate("war3mapImported\\ympf_shandian.mdx", x4, y4, -1, 30, -400, angle + GetRandomReal(0, 180))
                            SetEffectActSpeed(tx, 4)
                            DestroyEffectLua(tx)
                          end
                        end
                      end)
                      ac.timer(78.26086956521739, 23, function()
                        jqzhf(u, "ACWQCV-Extra")
                        ForGroupLuaNew(g2, function(xq)
                          DamageUnit({
                            bj = "妖梦(机体)",
                            unit = xq.handle,
                            source = u.handle,
                            damage = sh1,
                            level = 1,
                            type = "物理",
                            isvest = false,
                            isattack = true,
                            isnoarmor = false,
                            element = "无"
                          })
                          xq:buffset(u.handle, 0.5, "暂停")
                        end)
                      end)
                      local cs = 0
                      local gd2 = GetUnitFlyHeight(mb.handle)
                      local sj = 1
                      ac.loop(20, function(timer2)
                        cs = cs + 1
                        sj = sj + 1
                        if 8 < sj then
                          sj = 1
                        end
                        local a1 = angle + 45 * sj
                        local x4, y4 = PolarXY(x3, y3, 500, a1)
                        if u:getdata("umpf_paopao") == true then
                          local tx = Effectcreate("war3mapImported\\umpf_paopao_daoguang1.mdx", x4, y4, 0, 3, gd2 - 70, a1 + 90, 0, 0, 2)
                          local tx = Effectcreate("war3mapImported\\umpf_paopao_daoguang5.mdx", x4, y4, 0, 10, gd2, a1 + 90, 0, 0, 4)
                        else
                          local tx = Effectcreate("war3mapImported\\File00000650.mdl", x4, y4, -1, 5, gd2, a1 + 90)
                          SetEffectActSpeed(tx, GetRandomReal(0.75, 2))
                          DestroyEffectLua(tx)
                        end
                        ForGroupLuaNew(g2, function(xq)
                          xq:setflyheight(GetUnitFlyHeight(xq.handle) + GetRandomReal(-10, 10))
                        end)
                        if cs == 100 then
                          PlayGlobalSound(Sound_Ym_F12)
                          CameraSetEQNoiseForPlayer(u.owner, 200.0)
                          ac.wait(250, function()
                            CameraClearNoiseForPlayer(u.owner)
                          end)
                          mb:setflyheight(0)
                          for i = 1, 2 do
                            Effectcreate("war3mapImported\\File00000650.mdl", x3, y3, 0, 30, gd2, GetRandomReal(0, 360))
                          end
                          Effectcreate("war3mapImported\\Daoguang_1.mdl", x3, y3, 0, 5, gd2, 0, 0, 90)
                          for i = 1, 20 do
                            local x4, y4 = PolarXY(x3, y3, GetRandomReal(-1000, 1000), GetRandomReal(0, 360))
                            local tx = Effectcreate("war3mapImported\\File00000650.mdl", x4, y4, -1, GetRandomReal(1, 8), GetRandomReal(0, 2000), GetRandomReal(0, 360), GetRandomReal(0, 180), GetRandomReal(-110, -80))
                            SetEffectActSpeed(tx, GetRandomReal(1, 2))
                            DestroyEffectLua(tx)
                            local tx = Effectcreate("war3mapImported\\File00006330.mdl", x4, y4, -1, GetRandomReal(1, 10), GetRandomReal(0, 2000), GetRandomReal(0, 360), GetRandomReal(0, 180), GetRandomReal(-110, -80))
                            SetEffectActSpeed(tx, GetRandomReal(0.75, 2))
                            DestroyEffectLua(tx)
                          end
                          if u:getdata("umpf_paopao") == true then
                            EffectcreateArgs({
                              effect = "war3mapImported\\umpf_paopao_guangzhu1.mdx",
                              x = x2,
                              y = y2,
                              size = 20,
                              height = -1000,
                              zxz = angle,
                              animespeed = 0.5
                            })
                          end
                          ShowUnit(u.handle, true)
                          u:setxy(x3, y3)
                          u:animespeed(1)
                          ResetUnitAnimation(u.handle)
                          u:animeact(6)
                          SelectUnitForPlayerSingle(u.handle, u.owner)
                          u:buffset(u.handle, 0.6, "无敌")
                          jqzhf(u, "ACWQCV")
                          if u:hasdata("妖梦天赋-狱神剑") then
                            for _, xq in ac.selector():in_rangexy(x3, y3, fw + 100):is_enemy(u.handle):ipairs() do
                              xq = getunit(xq)
                              xq:animeact("death")
                              if xq:isboss() then
                                u:setdata("未来永劫斩-破灭")
                              end
                              DamageUnit({
                                bj = "妖梦(机体)",
                                unit = xq.handle,
                                source = u.handle,
                                damage = sh2,
                                level = 1,
                                type = "物理",
                                isvest = false,
                                isattack = false,
                                isnoarmor = false,
                                element = "无"
                              })
                              xq:buffset(u.handle, 3, "暂停")
                            end
                          else
                            ForGroupLuaNew(g2, function(xq)
                              xq:animeact("death")
                              if xq:isboss() then
                                u:setdata("未来永劫斩-破灭")
                              end
                              DamageUnit({
                                bj = "妖梦(机体)",
                                unit = xq.handle,
                                source = u.handle,
                                damage = sh2,
                                level = 1,
                                type = "物理",
                                isvest = false,
                                isattack = false,
                                isnoarmor = false,
                                element = "无"
                              })
                              xq:buffset(u.handle, 3, "暂停")
                            end)
                          end
                          u:deldata("未来永劫斩-破抗")
                          u:deldata("未来永劫斩-破招")
                          local gd3 = 500
                          local qr2 = false
                          ac.loop(20, function(timer3)
                            ForGroupLuaNew(g2, function(xq)
                              xq:setflyheight(gd3)
                            end)
                            u:setflyheight(gd3)
                            if 5000 < gd3 then
                              qr2 = true
                            end
                            if not qr2 then
                              gd3 = gd3 + 150
                            else
                              gd3 = gd3 - 150
                            end
                            if qr2 and gd3 <= 0 then
                              ForGroupLuaNew(g2, function(xq)
                                xq:setflyheight(0)
                              end)
                              u:setflyheight(0)
                              timer3:remove()
                            end
                          end)
                          timer2:remove()
                        end
                      end)
                    end
                    if qr and gd < 500 then
                      timer:remove()
                    end
                  end)
                end
              end
            end
          }
        }
      })
    end)
  end,
  QCDWCDCV = function(u)
    sy = du.ownerid
    local angle = u:getface()
    local x, y = u:getxy()
    ResetUnitAnimation(u.handle)
    u:animespeed(1)
    ac.wait(1, function()
      u:animeact(21)
    end)
    u:setdata("格挡判定时间", 0)
    if Boolean_Jinselingyu then
      if u:getdata("炯眼剑判定时间") >= 0.23 then
        u:setdata("空观剑判定时间", 0.25)
      elseif u:hasdata("妖梦天赋-一念无量劫") then
        u:setdata("空观剑判定时间", 0.3)
      else
        u:setdata("空观剑判定时间", 0.5)
      end
    elseif u:getdata("炯眼剑判定时间") >= 0.43 then
      u:setdata("空观剑判定时间", 0.25)
    elseif u:hasdata("妖梦天赋-一念无量劫") then
      u:setdata("空观剑判定时间", 0.3)
    else
      u:setdata("空观剑判定时间", 0.5)
    end
    u:setdata("炯眼剑判定时间", 0)
    u:effectadd("war3mapImported\\spellcardcall.mdx", "origin", 0.8)
    PlayGlobalSound(Sound_Ym_F01)
    u:buffset(u.handle, 2.5, "暂停")
  end,
  ["六根清净斩"] = function(u, mb)
    sy = u.ownerid
    local sh = u:getdata("角色基础伤害") + 2500 * u:getlevel()
    local bs = u:getdata("角色伤害范围")
    local angle = u:getface()
    local x, y = u:getxy()
    local x2, y2 = mb:getxy()
    local p = getplayer(u.owner)
    local p2
    if mb:isingroup(Group_PlayHero) then
      p2 = getplayer(mb.owner)
    end
    PlayGlobalSound(Sound_Ym_F02)
    Effectcreate("war3mapImported\\[TxNew]331 (8).mdl", x, y)
    if u:hasdata("妖梦天赋-天界剑") then
      ChangeValue(Hero_Tili, sy, 50)
    end
    local txsh
    txsh = 150 * sh + 10 * u:getlevel()
    if u:hasdata("妖梦天赋-一念无量劫") then
      u:changedata("妖梦冷却-空观剑-六根清净斩", 0.5, 1)
      txsh = (399.99 + 19.99 * u:getlevel()) * sh
    end
    print("六根基础伤害" .. txsh)
    u:buffset(u.handle, 5, "无敌")
    u:buffset(u.handle, 4.1, "暂停")
    local t = 4.5
    if u:hasdata("妖梦天赋-人界剑") then
      t = t + 1
    end
    u:buffset(u.handle, t, "永恒")
    u:buffset(u.handle, 5, "绝对闪避")
    mb:buffset(u.handle, 4.5, "暂停")
    mb:buffset(u.handle, 4.5, "锁定")
    mb:buffset(u.handle, 4.7, "沉默")
    ac.wait(500, function()
      Effectcreate("war3mapImported\\blackblink.mdx", x, y)
      ShowUnit(u.handle, false)
    end)
    ac.wait(1000, function()
      u:setxy(x2, y2)
      if p then
        p:setcamera(x2, y2)
      end
      if p2 then
        p2:setcamera(x2, y2)
      end
      local g2 = CreateGroupLua()
      for i = 1, 5 do
        local a = angle + 72 * i
        local x3, y3 = PolarXY(x2, y2, 50, a)
        local mj = u:createunit("u0E6", x3, y3, a - 90)
        if u:getdata("umpf_paopao") == true then
          japi.SetUnitModel(mj.handle, "paopao_umpf1.mdx")
          mj:setsize(1.4)
          mj:effectadd("paopaoguanghuan.mdx", "origin", -1)
          mj:setdata("umpf_paopao")
        end
        mj:groupadd(g2)
      end
      ForGroupLuaNew(g2, function(xq)
        xq:animeact(13)
        local cs2 = 200
        local fx = 80
        local jl = 0
        ac.loop(10, function(timer)
          cs2 = cs2 - 1
          if jl < 600 then
            jl = jl + 3
          end
          fx = fx / 1.02
          local x4, y4 = xq:getxy()
          local a = AngleXY(x2, y2, x4, y4)
          local x3, y3 = PolarXY(x2, y2, jl, a + fx)
          xq:setxy(x3, y3)
          SetUnitFacing(xq.handle, a + 180)
          if cs2 == 0 then
            ResetUnitAnimation(xq.handle)
            xq:animeact(30)
            ac.wait(250, function()
              CameraSetEQNoiseForPlayer(u.owner, 100.0)
              ac.wait(250, function()
                CameraClearNoiseForPlayer(u.owner)
              end)
              x2, y2 = mb:getxy()
              local a2 = AngleBetweenUnits(xq.handle, mb.handle)
              if u:getdata("umpf_paopao") == true then
                EffectcreateArgs({
                  effect = "war3mapImported\\umpf_paopao_yuzhou.mdx",
                  x = x2,
                  y = y2,
                  time = 1,
                  size = 15,
                  height = -1500,
                  zxz = GetRandomAngle(),
                  animespeed = 10
                })
                EffectcreateArgs({
                  effect = "war3mapImported\\umpf_paopao_guangzhu1.mdx",
                  x = x2,
                  y = y2,
                  time = 0.2,
                  size = 10,
                  height = -500,
                  zxz = GetRandomAngle(),
                  animespeed = 10
                })
                EffectcreateArgs({
                  effect = "war3mapImported\\umpf_paopao_baozha6.mdx",
                  x = x2,
                  y = y2,
                  time = 1,
                  size = 1,
                  zxz = a2,
                  animespeed = 2
                })
                EffectcreateArgs({
                  effect = "war3mapImported\\umpf_paopao_baozha6.mdx",
                  x = x2,
                  y = y2,
                  time = 1,
                  size = 2,
                  height = -700,
                  zxz = a2,
                  animespeed = 2
                })
                Effectcreate("war3mapImported\\umpf_paopao_daoguang1.mdl", x2, y2, 0, 10, 0, a2, 0, 0, 2)
                Effectcreate("war3mapImported\\umpf_paopao_daoguang5.mdl", x2, y2, 0, 30, 0, a2, 0, 0, 6)
              else
                Effectcreate("war3mapImported\\zhanji-sakura2.mdl", x2, y2, 0, 4, 0, a2)
                Effectcreate("war3mapImported\\bf69087b487bd5d6.mdl", x2, y2, 0, 2, 0, a2)
                local tx = Effectcreate("war3mapImported\\4496844d540a9969.mdl", x2, y2, -1, 3, -400, GetRandomReal(0, 360))
                SetEffectActSpeed(tx, 0.5)
                DestroyEffectLua(tx)
                local tx = Effectcreate("war3mapImported\\0c1eaa180f01d931.mdl", x2, y2, -1, 2, 0, GetRandomReal(0, 360))
                SetEffectActSpeed(tx, 3)
                DestroyEffectLua(tx)
                Effectcreate("war3mapImported\\um_h2.mdl", x2, y2, 0.75, 3, 0, a2)
                for i = 1, 4 do
                  Effectcreate("war3mapImported\\Daji_fen.mdl", x2, y2, 0, 3, 0, GetRandomReal(0, 360))
                end
              end
              local x5, y5 = xq:getxy()
              local cs1 = 0
              ac.loop(20, function(timer2)
                cs1 = cs1 + 1
                x5, y5 = PolarXY(x5, y5, 100, a2)
                xq:setxy(x5, y5)
                if cs1 == 10 then
                  xq:remove()
                  timer2:remove()
                end
              end)
            end)
          end
        end)
      end)
      ac.wait(500, function()
        PlayGlobalSound(Sound_Ym_F02_3)
      end)
      ac.wait(2250, function()
        PlayGlobalSound(Sound_Ym_F02_2)
      end)
      ac.wait(3000, function()
        x2, y2 = mb:getxy()
        u:setxy(x2, y2)
        ShowUnit(u.handle, true)
        IssueImmediateOrder(u.handle, "stop")
        u:animeact(5)
        local gd = 1000
        ac.loop(20, function(timer2)
          u:setflyheight(gd)
          gd = gd - 150
          if gd <= 0 then
            u:setflyheight(0)
            CameraSetEQNoiseForPlayer(u.owner, 200.0)
            ac.wait(500, function()
              CameraClearNoiseForPlayer(u.owner)
            end)
            SelectUnitForPlayerSingle(u.handle, u.owner)
            timer2:remove()
          end
        end)
        if u:getdata("umpf_paopao") == true then
          for i = 1, 2 do
            EffectcreateArgs({
              effect = "war3mapImported\\umpf_paopao_bodongpaopao.mdx",
              x = x2,
              y = y2,
              size = 3,
              height = -1000,
              zxz = angle,
              animespeed = 1
            })
          end
          for i = 1, 40 do
            local x4, y4 = PolarXY(x2 + GetRandomReal(-2000, 2000), y2 + GetRandomReal(-2000, 2000), GetRandomReal(-1000, 1000), GetRandomReal(0, 360))
            local tx = Effectcreate("war3mapImported\\umpf_paopao_daoguang1.mdx", x4, y4, -1, GetRandomReal(5, 10), GetRandomReal(0, 2000), GetRandomReal(0, 360), GetRandomReal(0, 180), GetRandomReal(-110, -80))
            SetEffectActSpeed(tx, GetRandomReal(1, 2))
            DestroyEffectLua(tx)
            local tx = Effectcreate("war3mapImported\\umpf_paopao_daoguang5.mdl", x4, y4, -1, GetRandomReal(10, 20), GetRandomReal(0, 2000), GetRandomReal(0, 360), GetRandomReal(0, 180), GetRandomReal(-110, -80))
            SetEffectActSpeed(tx, GetRandomReal(0.75, 2))
            DestroyEffectLua(tx)
          end
        else
          local tx = Effectcreate("war3mapImported\\ym_baoqi1.mdl", x2, y2, -1, 3, 0, GetRandomReal(0, 360))
          SetEffectActSpeed(tx, 4)
          DestroyEffectLua(tx)
          local tx = Effectcreate("war3mapImported\\a03bb1d21a15af4f.mdl", x2, y2, -1, 0.5, 0, GetRandomReal(0, 360))
          SetEffectActSpeed(tx, 3)
          DestroyEffectLua(tx)
          for i = 1, 20 do
            local x4, y4 = PolarXY(x2, y2, GetRandomReal(-1000, 1000), GetRandomReal(0, 360))
            local tx = Effectcreate("war3mapImported\\zhanji-sakura2.mdx", x4, y4, -1, GetRandomReal(1, 5), GetRandomReal(0, 2000), GetRandomReal(0, 360), GetRandomReal(0, 180), GetRandomReal(-110, -80))
            SetEffectActSpeed(tx, GetRandomReal(1, 2))
            DestroyEffectLua(tx)
            local tx = Effectcreate("war3mapImported\\Zhanji_Hong.mdl", x4, y4, -1, GetRandomReal(0.5, 3), GetRandomReal(0, 2000), GetRandomReal(0, 360), GetRandomReal(0, 180), GetRandomReal(-110, -80))
            SetEffectActSpeed(tx, GetRandomReal(0.75, 2))
            DestroyEffectLua(tx)
          end
        end
        mb:animeact("death")
        if mb:isboss() then
          u:setdata("六根清净斩-破灭")
        end
        mb:clearbuff("无敌")
        jqzhf(u, "QCDWCDCV")
        DamageUnit({
          bj = "妖梦(机体)",
          unit = mb.handle,
          source = u.handle,
          damage = txsh,
          level = 1,
          type = "物理",
          isvest = false,
          isattack = false,
          isnoarmor = false,
          element = "无"
        })
        u:deldata("六根清净斩-破灭")
        mb:buffset(u.handle, 3, "暂停")
        for _, xq in ac.selector():in_rangexy(x2, y2, 500):is_enemy(u.handle):is_not(mb.handle):ipairs() do
          xq = getunit(xq)
          xq:animeact("death")
          if xq:isboss() then
            u:setdata("六根清净斩-破灭")
          end
          xq:clearbuff("无敌")
          DamageUnit({
            bj = "妖梦(机体)",
            unit = xq.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "物理",
            isvest = false,
            isattack = false,
            isnoarmor = false,
            element = "无"
          })
          u:deldata("六根清净斩-破灭")
          xq:buffset(u.handle, 3, "暂停")
        end
      end)
    end)
  end
}
return umskill
