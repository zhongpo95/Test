-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local zhenhong_1_start, zhenhong_1_end, zhenhong_2_end, zhenhong_3_end, zhenhong_2_start, ZhenhongSkill, zhenhong_3_start
Group_Zhenhongshanmo = CreateGroupLua()

local function shanbipanding(u)
  local b = false
  if u:hasbuff("绝对闪避") or u:hasbuff("永恒") or u:hasbuff("停滞") then
    b = true
  end
  return b
end

local function shanmopanding(u)
  local x, y = u:getxy()
  Effectcreate("war3mapImported\\Texiao_chengxizhiguang1.mdx", x, y, 0, 5)
  PlayGlobalSound(BOSS_Zhenhong_Baozha1)
  SetUnitOwner(u.handle, Player(PLAYER_NEUTRAL_PASSIVE), true)
  u:setdata("系统-已删模")
  u:groupremove(Group_Xingcunzu)
  u:groupremove(Group_DeathHero)
  u:groupremove(Group_PlayHero)
  if not Boolean_Jinselingyu then
    ShowUnit(u.handle, false)
  end
  u:addskill("Aloc")
  u:addskill("A00N")
  u:addskill("A0P2")
  u:groupadd(Group_Zhenhongshanmo)
  GameOver()
end

local function anshishandian(u, x, y)
  Effectcreate("war3mapImported\\Texiao_jinggao2.mdx", x, y, 0.5, 0.5, 10)
  ac.wait(800, function()
    Effectcreate("war3mapImported\\Texiao_shenfa2.mdx", x, y, 0, 0.7)
    local fw = 75
    ForGroupLuaNew(Group_PlayHero, function(xq)
      if xq:isalive() then
        local ax, ay = xq:getxy()
        local dis = DistanceXY(x, y, ax, ay)
        if dis <= fw then
          local txsh = 450 * u:getdata("怪物强度") + 0.2 * xq:getmaxhp()
          DamageUnit({
            unit = xq.handle,
            source = u.handle,
            damage = txsh,
            level = 5,
            type = "魔力",
            isvest = false,
            isattack = false,
            isnoarmor = false,
            element = "无",
            extradata = {""}
          })
          if not shanbipanding(xq) then
            xq:losshp(u, 0, 15, 15)
            xq:buffset(u.handle, 5, "缠绕")
            xq:buffset(u.handle, 5, "麻痹")
            if not xq:hasdata("真红-神罚破坏") then
              xq:settimedata("真红-神罚破坏", 10)
            end
          end
        end
      end
    end)
  end)
end

local function zhenhongskill_3_anshi(u)
  local g = CreateGroupLua()
  ForGroupLuaNew(Group_PlayHero, function(xq)
    if xq:isalive() then
      xq:groupadd(g)
    end
  end)
  ForGroupLuaNew(g, function(xq)
    ac.timer(200, 25, function()
      local x, y = xq:getxy()
      anshishandian(u, x, y)
      local ax, ay = PolarXY(x, y, GetRandomReal(0, 500), GetRandomAngle())
      anshishandian(u, ax, ay)
    end)
  end)
  ac.wait(5000, function()
    local dx, dy = u:getxy()
    ac.timer(20, 150, function()
      local ax, ay = PolarXY(dx, dy, GetRandomReal(0, 800), GetRandomAngle())
      anshishandian(u, ax, ay)
    end)
  end)
end

local timershijiezhiyan = ac.loop(2500, function()
  local u = getunit(Boss_Zhenhong)
  if u:hasdata("第一阶段结束") then
    return
  end
  if u:getpermp() >= 80 and not u:hasdata("纯白之羽警告") and Nandu_Choose <= 4 then
    u:setdata("纯白之羽警告")
    SendMsgAll("|cFFCC99FF八云紫：|r小心，我感受到她身上的能量越来越强了，请尽快抵达我们身边，我们会守护你")
  end
  if Nandu_Choose >= 5 then
    u:curemp(GetRandomReal(5, 25))
  end
  ForGroupLuaNew(u:getdata("世界之门组"), function(xq)
    local dx, dy = xq:getxy()
    if not xq:hasdata("世界之门-重构中") then
      PingMinimapEx(dx, dy, 1, 0, 255, 0, false)
    end
  end)
  PlayGlobalSound(BOSS_Zhenhong_Xintiao)
  ac.wait(1000, function()
    local b = false
    ForGroupLuaNew(Group_PlayHero, function(xq)
      if xq:hasdata("世界之眼锁定") then
        b = true
        local t = 0
        local speed = 7500
        ForGroupLuaNew(u:getdata("世界之门组"), function(xq2)
          local dx, dy = xq:getxy()
          local dx2, dy2 = xq2:getxy()
          local jd = AngleXY(dx2, dy2, dx, dy)
          local dis = DistanceXY(dx, dy, dx2, dy2)
          if Nandu_Choose >= 5 then
            t = 9
            speed = 7500
          else
            if t == 0 then
              t = dis / 7500
            end
            speed = dis / t
          end
          unifycreate({
            owner = u.handle,
            model = "war3mapImported\\Texiao_guangjian.mdl",
            modelname = "真红-世界之眼",
            modelsize = 5,
            height = 100,
            damage = 100,
            damagetype = 1,
            x = dx2,
            y = dy2,
            time = t + 3,
            speed = speed,
            volume = 110,
            angle = jd,
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
              if xq:isingroup(Group_PlayHero) then
                local txsh = 400 * u:getdata("怪物强度") + 0.2 * xq:getmaxhp()
                DamageUnit({
                  unit = xq.handle,
                  source = u.handle,
                  damage = txsh,
                  level = 5,
                  type = "魔力",
                  isvest = false,
                  isattack = false,
                  isnoarmor = false,
                  element = "无",
                  extradata = {""}
                })
                local sb = shanbipanding(xq)
                if not sb then
                  xq:losshp(u, 0, 10, 10)
                end
              end
            end,
            endfunc = function(mj)
            end
          })
        end)
      end
    end)
    if b then
      PlayGlobalSound(BOSS_Zhenhong_Shijiezhiyan)
      SetSoundVolume(BOSS_Zhenhong_Shijiezhiyan, 70)
    end
  end)
end)
timershijiezhiyan:pause()
ZhenhongSkill = {
  ["天国之门"] = function(u)
    local sj = 180
    local count = Group_Counts(Group_Xingcunzu)
    if Nandu_Choose >= 5 then
      count = Group_Counts(Group_PlayHero)
    end
    if count == 1 then
      sj = 240
    end
    if count == 2 or count == 3 then
      if Nandu_Choose <= 4 then
        sj = 120
      else
        sj = 80
      end
    end
    if 4 <= count then
      sj = 20
    end
    SendMsgAll("|cFFCC99FF八云紫：|r第一座世界之门已被破坏，请在|cFFCC0033" .. sj .. "秒|r内破坏剩余的世界之门，否则所有世界之门都会重新构筑，请抓紧时间", 5)
    local cs = 0
    ac.loop(1000, function(timer)
      cs = cs + 1
      u:curemp(GetRandomReal(5, 25))
      local c = 0
      ForGroupLuaNew(u:getdata("世界之门组"), function(xq)
        if xq:hasdata("世界之门-重构中") then
          c = c + 1
        end
      end)
      if 4 <= c then
        SendMsgAll("|cFFCC99FF八云紫：|r所有世界之门已经被损毁，真红身上的辉光黯淡了，趁现在快去把她压制住")
        ForGroupLuaNew(u:getdata("世界之门组"), function(xq)
          xq:addskill("A00N")
          SetUnitOwner(xq.handle, Player(PLAYER_NEUTRAL_PASSIVE), false)
        end)
        u:deldata("真红永恒")
        u:clearbuff("无敌")
        -- 타이머 값과 엔진 상태가 달라도 구슬 완료 시 무적을 즉시 해제한다.
        u:deldata("无敌时间")
        u:deldata("伪无敌时间")
        SetUnitInvulnerable(u.handle, false)
        timer:remove()
        -- 제한시간과 동시에 성공해도 구슬 복구 분기로 넘어가지 않는다.
        return
      end
      if cs >= sj then
        SendMsgAll("|cFFCC99FF八云紫：|r太迟了，世界之门通过真红的力量已经被重新构筑，下次请一定要准备万全再动手")
        u:deldata("天国之门计时")
        ForGroupLuaNew(u:getdata("世界之门组"), function(xq)
          xq:sethp(100, true)
          xq:deldata("真红永恒")
          xq:deldata("世界之门-重构中")
        end)
        timer:remove()
      end
    end)
  end,
  ["纯白之羽"] = function(u)
    SendMsgAll("|cFFCC0000神迹.纯白之羽|r")
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFFCC0000[靠近任意NPC来躲避纯白之羽的伤害]|r")
    end
    u:animeact(8)
    local x, y = u:getxy()
    ac.wait(1000, function()
      u:getxy()
      PlayGlobalSound(BOSS_Zhenhong_Xuli1)
      local cs2 = 0
      ac.loop(200, function(timer)
        cs2 = cs2 + 1
        Effectcreate("war3mapImported\\Texiao_zhenhongxuli.mdx", x, y, 0, 3, -100, GetRandomAngle())
        if 5 < cs2 then
          u:animeact(9)
          CinematicFadeBJ(bj_CINEFADETYPE_FADEOUTIN, 0.5, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 100.0, 0, 0, 50.0)
          ac.wait(1000, function()
            ResetUnitAnimation(u.handle)
          end)
          timer:remove()
        end
      end)
    end)
    ac.wait(2500, function()
      PlayGlobalSound(BOSS_Zhenhong_Heiyuzhijian2)
      EffectcreateArgs({
        effect = "war3mapImported\\Texiao_chengxizhiguang1.mdx",
        x = x,
        y = y,
        size = 20
      })
      local cs = 0
      ac.loop(250, function(timer)
        cs = cs + 1
        u:setmp(0)
        for i = 1, 2 do
          local g = CreateGroupLua()
          ForGroupLuaNew(Group_PlayHero, function(xq)
            if xq:isalive() then
              xq:groupadd(g)
            end
          end)
          if 0 < Group_Counts(g) then
            do
              local mb = Group_Randomunit(g)
              local x1, y1 = u:getxy()
              local x2, y2 = mb:getxy()
              local jd = AngleXY(x2, y2, x1, y1)
              jd = jd + GetRandomReal(-5, 5)
              local x3, y3 = PolarXY(x1, y1, 50, jd)
              local tx = EffectcreateArgs({
                effect = "war3mapImported\\Texiao_baiyu.mdl",
                x = x3,
                y = y3,
                time = -1,
                size = 0.5,
                height = 100,
                zxz = jd
              })
              EffectShowAll(tx)
              local dcs = 0
              local h = 100
              local v = GetRandomReal(30, 60)
              local dx = x3
              local dy = y3
              local change = jd
              ac.loop(20, function(timer2)
                dcs = dcs + 1
                if mb:isalive() then
                  local dx2, dy2 = mb:getxy()
                  if 25 <= dcs and dcs <= 50 then
                    v = v + 2
                  end
                  if 50 < dcs then
                    local dis = DistanceXY(dx, dy, dx2, dy2)
                    if dis <= 100 then
                      local b = false
                      ForGroupLuaNew(GroupNpc, function(xq)
                        if not b then
                          local dx3, dy3 = xq:getxy()
                          local dis2 = DistanceXY(dx3, dy3, dx2, dy2)
                          if dis2 <= 500 then
                            b = true
                          end
                        end
                      end)
                      if not b then
                        mb:changedata("纯白之羽命中次数", 1)
                        mb:losshp(u, 0, 0, mb:getdata("纯白之羽命中次数"))
                        local txsh = 10 * u:getdata("怪物强度") * mb:getdata("纯白之羽命中次数")
                        DamageUnit({
                          unit = mb.handle,
                          source = u.handle,
                          damage = txsh,
                          level = 5,
                          type = "魔力",
                          isvest = false,
                          isattack = false,
                          isnoarmor = false,
                          element = "无",
                          extradata = {""}
                        })
                        Effectcreate("war3mapImported\\Texiao_chengxizhiguang1.mdx", dx2, dy2)
                      end
                      DestroyEffectLua(tx)
                      timer2:remove()
                    end
                  end
                  jd = AngleXY(dx, dy, dx2, dy2)
                  change = change - jd
                  SetEffectAngle(tx, change)
                  dx, dy = PolarXY(dx, dy, v, jd)
                  SetEffectXY(tx, dx, dy)
                  change = jd
                else
                  DestroyEffectLua(tx)
                  timer2:remove()
                end
              end)
            end
          end
        end
        if cs == 120 then
          u:deldata("纯白之羽警告")
          ForGroupLuaNew(Group_PlayHero, function(xq)
            xq:deldata("纯白之羽命中次数")
          end)
          ac.wait(5000, function()
            zhenhong_1_start(u)
          end)
          timer:remove()
        end
      end)
    end)
  end,
  ["神罚"] = function(u)
    SendMsgAll("|cFFCC0000神罚|r")
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFFCC0000[在玩家周围召唤神罚之雷伤害;小神罚只会出现在一定距离外]|r")
    end
    u:animeact(6)
    local x, y = u:getxy()
    Effectcreate("war3mapImported\\Texiao_zhenhongxuli.mdx", x, y, 0, 2)
    PlayGlobalSound(BOSS_Zhenhong_Xuli1)
    ac.wait(1000, function()
      PlayGlobalSound(BOSS_Zhenhong_Xintiao)
      CinematicFadeBJ(bj_CINEFADETYPE_FADEOUTIN, 0.2, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 100.0, 0, 0, 50.0)
      ac.wait(1000, function()
        PlayGlobalSound(BOSS_Zhenhong_Shandian3)
        ResetUnitAnimation(u.handle)
      end)
      ForGroupLuaNew(Group_PlayHero, function(xq)
        if xq:isalive() then
          local cs = 0
          local cs2 = 0
          local count = 150
          if Nandu_Choose >= 5 then
            count = 225
          end
          ac.loop(50, function(timer)
            cs = cs + 1
            cs2 = cs2 + 1
            local dx, dy = xq:getxy()
            local waittime, x2, y2, fw
            if 50 <= cs2 then
              cs2 = 0
              waittime = 0.5
              x2, y2 = xq:getxy()
              if Nandu_Choose >= 5 then
                Effectcreate("war3mapImported\\Texiao_jinggao2.mdx", x2, y2, 0.2, 6)
                fw = 600
              else
                Effectcreate("war3mapImported\\Texiao_jinggao2.mdx", x2, y2, 0.2, 4)
                fw = 400
              end
              ac.wait(500, function()
                EffectcreateArgs({
                  effect = "war3mapImported\\Texiao_shenfa2.mdx",
                  x = x2,
                  y = y2,
                  size = 10,
                  animespeed = 2
                })
                local a = GetRandomAngle()
                for i = 1, 6 do
                  a = a + 60
                  local x3, y3 = PolarXY(x2, y2, 250, a)
                  EffectcreateArgs({
                    effect = "war3mapImported\\Texiao_shenfa2.mdx",
                    x = x2,
                    y = y2,
                    size = 10,
                    animespeed = 2
                  })
                end
              end)
            else
              waittime = 0.8
              fw = 125
              x2, y2 = PolarXY(dx, dy, GetRandomReal(500, 1800), GetRandomAngle())
              Effectcreate("war3mapImported\\Texiao_jinggao2.mdx", x2, y2, 0.83, 0.6)
              ac.wait(800, function()
                EffectcreateArgs({
                  effect = "war3mapImported\\Texiao_shenfa2.mdx",
                  x = x2,
                  y = y2,
                  size = 0.83,
                  animespeed = 2
                })
              end)
            end
            ac.wait(waittime * 1000, function()
              if xq:isalive() then
                local ax, ay = xq:getxy()
                local dis = DistanceXY(x2, y2, ax, ay)
                if dis <= fw then
                  local txsh = 250 * u:getdata("怪物强度") + 0.15 * xq:getmaxhp()
                  DamageUnit({
                    unit = xq.handle,
                    source = u.handle,
                    damage = txsh,
                    level = 1,
                    type = "魔力",
                    isvest = false,
                    isattack = false,
                    isnoarmor = false,
                    element = "无",
                    extradata = {""}
                  })
                  local sb = shanbipanding(xq)
                  if not sb then
                    xq:losshp(u, 0, 10, 10)
                    if not xq:hasdata("世界之眼锁定") then
                      local t = 25
                      if Nandu_Choose >= 5 then
                        t = 30
                      end
                      if xq:islocal() then
                        BuffUI.apply({
                          id = "世界之眼",
                          duration = t
                        })
                      end
                      xq:sendmessage("|cFF3366FF「世界之眼已锁定你」|r")
                      xq:settimedata("世界之眼锁定", t)
                      xq:effectadd("war3mapImported\\Texiao_suodingzhiyan.mdx", "overhead", t)
                    end
                  end
                end
              end
            end)
            if cs == count then
              timer:remove()
            end
          end)
        end
      end)
      ac.wait(17500.0, function()
        zhenhong_1_start(u)
      end)
    end)
  end,
  ["界跃"] = function(u)
    local g = CreateGroupLua()
    ForGroupLuaNew(Group_PlayHero, function(xq)
      if xq:isalive() then
        xq:groupadd(g)
      end
    end)
    local mb = Group_Randomunit(g)
    if mb == 0 then
      mb = u
    end
    u:setdata("锁定单位", mb)
    local cs = 0
    local zs = 3
    local dtime = 1500
    if Nandu_Choose >= 5 then
      zs = GetRandomInt(1, 4)
      dtime = GetRandomReal(300, 900)
    end
    ac.loop(dtime, function(timer)
      cs = cs + 1
      if Nandu_Choose >= 5 then
        mb = Group_Randomunit(g)
        if mb == 0 then
          mb = u
        end
        u:setdata("锁定单位", mb)
      end
      PlayGlobalSound(BOSS_Zhenhong_Chuansong)
      local x, y = u:getxy()
      local x2, y2 = mb:getxy()
      x2, y2 = PolarXY(x2, y2, GetRandomReal(0, 2000), GetRandomAngle())
      Effectcreate("war3mapImported\\Texiao_zhenhongchuansong1.mdx", x, y)
      ResetUnitAnimation(u.handle)
      ac.wait(dtime / 3, function()
        u:setxy(x2, y2)
        local a = AngleBetweenUnits(u.handle, mb.handle)
        u:setface(a)
        Effectcreate("war3mapImported\\Texiao_zhenhongchuansong1.mdx", x2, y2)
      end)
      if zs == cs then
        ac.wait(dtime, function()
          zhenhong_2_start(u)
        end)
        timer:remove()
      end
    end)
  end,
  ["世界之风"] = function(u)
    SendMsgAll("|cFFCC0000神迹.来自世界尽头的风|r")
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFFCC0000[在所有玩家周围召唤世界之风攻击]|r")
    end
    u:animeact(6)
    local dx, dy = u:getxy()
    Effectcreate("war3mapImported\\Texiao_zhenhongxuli.mdx", dx, dy, 0, 2)
    PlayGlobalSound(BOSS_Zhenhong_Xuli1)
    ac.wait(1000 * u:getdata("真红-二阶段蓄力时间"), function()
      PlayGlobalSound(BOSS_Zhenhong_Feng2)
      ac.timer(1000, 10, function()
        local zs = GetRandomInt(2, 4)
        if Nandu_Choose >= 5 then
          zs = zs + 2
        end
        ForGroupLuaNew(Group_PlayHero, function(xq)
          if xq:isalive() then
            local x, y = xq:getxy()
            for i = 1, zs do
              local ax, ay = PolarXY(x, y, 1500, GetRandomAngle())
              local tx = Effectcreate("war3mapImported\\[AKE]war3AKE.com - 1308011877258862159355271.mdl", ax, ay, -1, 1, 100, 0, 0, 0, 2)
              local jd = AngleXY(ax, ay, x, y)
              local g = CreateGroupLua()
              effectmove({
                effect = tx,
                time = 3,
                distance = GetRandomReal(3000, 5000),
                angle = jd,
                loops = {
                  {
                    looptime = 0.03,
                    func = function(ddx, ddy)
                      for _, xq2 in ac.selector():in_rangexy(ddx, ddy, 150):is_enemy(u.handle):isnotingroup(g):isingroup(Group_PlayHero):ipairs() do
                        xq2 = getunit(xq2)
                        xq2:groupadd(g)
                        local txsh = 250 * u:getdata("怪物强度") + 0.2 * xq2:getmaxhp()
                        DamageUnit({
                          unit = xq2.handle,
                          source = u.handle,
                          damage = txsh,
                          level = 5,
                          type = "魔力",
                          isvest = false,
                          isattack = false,
                          isnoarmor = false,
                          element = "无",
                          extradata = {""}
                        })
                        if not shanbipanding(xq2) then
                          xq2:losshp(u, 0, 15, 15)
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
          end
        end)
      end)
    end)
    ac.wait(10000, function()
      ZhenhongSkill["界跃"](u)
    end)
  end,
  ["晨曦之光"] = function(u)
    SendMsgAll("|cFFCC0000神迹.晨曦之光|r")
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFFCC0000[短暂蓄力后进行锁定玩家的连续打击]|r")
    end
    u:animeact(6)
    local dx, dy = u:getxy()
    Effectcreate("war3mapImported\\Texiao_zhenhongxuli.mdx", dx, dy, 0, 2)
    PlayGlobalSound(BOSS_Zhenhong_Xuli1)
    local waittime = 1
    if Nandu_Choose >= 0 then
      waittime = 0.1
    end
    ac.wait(1000 * waittime, function()
      local g = u:getdata("晨曦之光锁定组")
      GroupClearLua(g)
      ForGroupLuaNew(Group_PlayHero, function(xq)
        if xq:isalive() then
          xq:groupadd(g)
        end
      end)
      if Group_Counts(g) > 0 then
        local mb = FirstOfGroupLua(g)
        mb:groupremove(g)
        PlayGlobalSound(BOSS_Zhenhong_Chuansong)
        local x, y = u:getxy()
        local x2, y2 = mb:getxy()
        x2, y2 = PolarXY(x2, y2, GetRandomReal(0, 1000), GetRandomAngle())
        Effectcreate("war3mapImported\\Texiao_zhenhongchuansong1.mdx", x, y)
        ResetUnitAnimation(u.handle)
        ac.wait(500, function()
          u:setxy(x2, y2)
          u:setface(AngleBetweenUnits(u.handle, mb.handle))
          PlayGlobalSound(BOSS_Zhenhong_Xuli1)
          Effectcreate("war3mapImported\\Texiao_zhenhongxuli.mdx", x2, y2, 0, 2)
          Effectcreate("war3mapImported\\Texiao_zhenhongchuansong1.mdx", x2, y2)
        end)
        local cs = 0
        local dtime = 1.3
        local origintime = 1.3
        if Nandu_Choose >= 5 then
          dtime = 1.2
          origintime = 1.2
        end
        ac.loop(10, function(timer)
          cs = cs + 1
          dtime = dtime + origintime - 0.1 * cs
          ac.wait(dtime * 1000, function()
            PlayGlobalSound(BOSS_Zhenhong_Shandian2)
            local jd = AngleBetweenUnits(u.handle, mb.handle)
            u:animeact(4)
            u:setface(jd)
            x, y = u:getxy()
            local x1, y1 = PolarXY(x, y, -150, jd)
            local txx, txy = PolarXY(x1, y1, 1200, jd)
            Effectcreate("war3mapImported\\Texiao_chengxizhiguang2.mdx", txx, txy, 0, 2, 0, jd)
            local g2 = CreateGroupLua()
            loopmove({
              x = x1,
              y = y1,
              time = 0.1,
              distance = 4000,
              angle = jd,
              loops = {
                {
                  looptime = 0.01,
                  func = function(ddx, ddy)
                    for _, xq2 in ac.selector():in_rangexy(ddx, ddy, 200):is_enemy(u.handle):isnotingroup(g2):isingroup(Group_PlayHero):ipairs() do
                      xq2 = getunit(xq2)
                      xq2:groupadd(g2)
                      local txsh = 500 * u:getdata("怪物强度") + 0.2 * xq2:getmaxhp()
                      DamageUnit({
                        unit = xq2.handle,
                        source = u.handle,
                        damage = txsh,
                        level = 5,
                        type = "魔力",
                        isvest = false,
                        isattack = false,
                        isnoarmor = false,
                        element = "无",
                        extradata = {""}
                      })
                      if not shanbipanding(xq2) then
                        xq2:losshp(u, 0, 15, 15)
                      end
                    end
                  end
                }
              }
            })
          end)
          if 9 <= cs then
            timer:remove()
          end
        end)
      end
    end)
    ac.wait(7200 + 2000 * waittime, function()
      ZhenhongSkill["界跃"](u)
    end)
  end,
  ["祟神之影"] = function(u)
    SendMsgAll("|cFFCC0000祟神之影|r")
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFFCC0000[进入限时的红色警告圈中规避伤害]|r")
    end
    u:animeact(6)
    local dx, dy = u:getxy()
    Effectcreate("war3mapImported\\Texiao_zhenhongxuli.mdx", dx, dy, 0, 2)
    PlayGlobalSound(BOSS_Zhenhong_Xuli1)
    ac.wait(1000 * u:getdata("真红-二阶段蓄力时间"), function()
      local timemax = 150
      if Nandu_Choose >= 5 then
        timemax = 100
      end
      ForGroupLuaNew(Group_PlayHero, function(xq)
        if xq:isalive() then
          local x, y = xq:getxy()
          x, y = PolarXY(x, y, GetRandomReal(300, 700), GetRandomAngle())
          local tx = Effectcreate("war3mapImported\\Texiao_jinggao1.mdl", x, y, -1)
          local cs = 0
          ac.loop(10, function(timer)
            local ax, ay = xq:getxy()
            local dis = DistanceXY(ax, ay, x, y)
            cs = cs + 1
            if dis <= timemax then
              SetEffectSize(tx, 0.001)
              xq:setdata("祟神之影拾取")
            end
            if cs == timemax then
              DestroyEffectLua(tx)
              if not xq:hasdata("祟神之影拾取") then
                CinematicFadeBJ(bj_CINEFADETYPE_FADEOUTIN, 0.5, "ReplaceableTextures\\CameraMasks\\DreamFilter_Mask.blp", 100.0, 0, 0, 50.0)
                ac.wait(1000, function()
                  local dcs = 0
                  ac.loop(50, function(timer2)
                    dcs = dcs + 1
                    ax, ay = xq:getxy()
                    local xx, yy = PolarXY(ax, ay, GetRandomReal(0, 200), GetRandomAngle())
                    Effectcreate("war3mapImported\\176.mdx", xx, yy, 1, 0.5, 0, GetRandomAngle())
                    if Nandu_Choose >= 5 then
                      xq:changemaxhp(-0.02 * xq:getmaxhp())
                    else
                      xq:changemaxhp(-0.01 * xq:getmaxhp())
                    end
                    xq:losshp(u, 0, 0, 9)
                    if dcs == 10 then
                      xq:effectadd("war3mapImported\\texiao_xuebao.mdx")
                      timer2:remove()
                    end
                  end)
                end)
              end
              xq:deldata("祟神之影拾取")
              timer:remove()
            end
          end)
        end
      end)
      ac.wait(1000, function()
        PlayGlobalSound(BOSS_Zhenhong_Xintiao)
        ac.wait(10 * timemax, function()
          ac.timer(50, 10, function()
            PlayGlobalSound(BOSS_Zhenhong_Suishen1)
          end)
        end)
      end)
    end)
    ac.wait(500 + 2000 * u:getdata("真红-二阶段蓄力时间"), function()
      ZhenhongSkill["界跃"](u)
    end)
  end,
  ["次元闭锁"] = function(u)
    SendMsgAll("|cFFCC0000神迹.次元闭锁|r")
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFFCC0000[小地图信号为黯羽之箭发射点 破界者抵挡射向队友的黯羽之箭(不能过于贴近队友)\n仅破界者存活时 规避所有黯羽之箭]|r")
    end
    local npc = getunit(NPC_Molijiedian)
    ShowUnit(npc.handle, false)
    u:setdata("真红永恒")
    u:setdata("次元闭锁启动")
    u:animeact(8)
    u:animespeed(0.1)
    PlayGlobalSound(BOSS_Zhenhong_Xuli2)
    local cs2 = 0
    local x, y = u:getxy()
    u:buffset(u.handle, 999, "锁定")
    ac.loop(200, function(timer)
      cs2 = cs2 + 1
      EffectcreateArgs({
        effect = "war3mapImported\\Texiao_zhenhongxuli.mdx",
        x = x,
        y = y,
        size = 1 + 0.1 * cs2,
        height = -1 * cs2,
        zxz = GetRandomAngle()
      })
      if 150 <= cs2 then
        u:animespeed(1)
        u:animeact(9)
        ac.wait(1000, function()
          ResetUnitAnimation(u.handle)
        end)
        CinematicFadeBJ(bj_CINEFADETYPE_FADEOUTIN, 1.0, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 100.0, 0, 0, 50.0)
        PlayGlobalSound(BOSS_Zhenhong_Suolian1)
        ac.wait(250, function()
          Boolean_Zhenhong_Ciyuanbisuo = true
          FlashFog()
          local g = CreateGroupLua()
          local g2 = CreateGroupLua()
          local g3 = CreateGroupLua()
          u:setdata("真红-次元闭锁组", g)
          u:setdata("真红-黑羽之箭组", g2)
          ForGroupLuaNew(Group_PlayHero, function(xq)
            if not xq:isalive() then
              xq:groupadd(g3)
            end
            HeroRelive(xq.handle, x, y)
            xq:groupadd(g)
            xq:setdata("次元闭锁锁定")
            local dx, dy = xq:getxy()
            local tx = Effectcreate("war3mapImported\\Texiao_ciyuanbisuo.mdx", dx, dy, -1, 3)
            xq:setdata("次元闭锁锁定特效", tx)
          end)
          local pj
          if Nandu_Choose <= 4 then
            if Group_Counts(g3) > 0 then
              pj = Group_Randomunit(g3)
            else
              pj = Group_Randomunit(g)
            end
          else
            pj = Group_Randomunit(g)
          end
          if pj == 0 then
            pj = Group_Randomunit(Group_PlayHero)
          end
          pj:setdata("次元闭锁-破界者")
          DestroyEffectLua(pj:getdata("次元闭锁锁定特效"))
          pj:deldata("次元闭锁锁定特效")
          SendMsgAll(pj:getplayername() .. "|cFF9999FF被选定为破界者|r")
          ac.loop(100, function(timer2)
            ForGroupLuaNew(Group_PlayHero, function(xq)
              if not xq:hasdata("次元闭锁-破界者") then
                xq:buffset(u.handle, 0.2, "暂停")
                xq:buffset(u.handle, 0.2, "锁定")
              end
              if not xq:isingroup(g) and xq:isalive() then
                if xq:getdata("残机剩余数量") > 0 then
                  xq:changedata("残机剩余数量", -1)
                  xq:setusedfodd(u:getdata("残机剩余数量"))
                  xq:groupadd(g)
                else
                  xq:setdata("真红次元闭锁超即死")
                  xq:kill(u.handle, false)
                  xq:deldata("真红次元闭锁超即死")
                end
              end
            end)
            if u:hasdata("第二阶段结束") then
              timer2:remove()
            end
          end)
          local cs = 0
          local sycs = 10
          ac.loop(1000, function(timer3)
            cs = cs + 1
            if not pj:isalive() or not pj:isingroup(Group_PlayHero) then
              pj:deldata("次元闭锁-破界者")
              pj:groupremove(g)
              if Group_Counts(g) > 0 then
                pj = Group_Randomunit(g)
                pj:setdata("次元闭锁-破界者")
                DestroyEffectLua(pj:getdata("次元闭锁锁定特效"))
                pj:deldata("次元闭锁锁定特效")
                SendMsgAll(pj:getplayername() .. "|cFF9999FF被选定为破界者|r")
                if Nandu_Choose <= 4 then
                  SendMsgAll("|cFF9999FF替队友抵挡黑羽之箭(小地图提示 抵挡时远离队友200码外)|r")
                  SendMsgAll("|cFF9999FF不存在队友时,躲避黑羽之箭|r")
                end
              end
            end
            if 9 <= cs then
              cs = 0
              sycs = sycs - 1
              ac.wait(5000, function()
                PlayGlobalSound(BOSS_Zhenhong_Heiyuzhijian2)
              end)
              if Group_Counts(g) > 0 then
                local mb
                if 1 < Group_Counts(g) then
                  local ng = CreateGroupLua()
                  ForGroupLuaNew(g, function(xq)
                    if not xq:hasdata("次元闭锁-破界者") then
                      xq:groupadd(ng)
                    end
                  end)
                  mb = Group_Randomunit(ng)
                  mb:effectadd("war3mapImported\\Texiao_suodingzhiyan.mdx", "overhead", 5)
                  local ax, ay = mb:getxy()
                  local ra = GetRandomAngle()
                  local dax, day = PolarXY(ax, ay, 3000, ra)
                  local mj = u:createunit("u0DE", dax, day, ra + 180)
                  mj:setcolor(255, 255, 255, 0)
                  mj:groupadd(g2)
                  local tx = Effectcreate("war3mapImported\\zhishixian2.mdl", ax, ay, -1, 0.001, 0, ra)
                  ac.wait(4800, function()
                    SetEffectSize(tx, 1)
                  end)
                  ac.wait(5000, function()
                    japi.SetUnitModel(mj.handle, "war3mapImported\\Texiao_heiyuzhijian2.mdl")
                    mj:setcolor(255, 255, 255, 255)
                    ac.wait(300, function()
                      SetEffectSize(tx, 0.001)
                      DestroyEffectLua(tx)
                    end)
                    local cs3 = 0
                    local dx2, dy2 = mj:getxy()
                    ac.loop(5, function(timer2)
                      cs3 = cs3 + 1
                      dx2, dy2 = PolarXY(dx2, dy2, 100, ra + 180)
                      mj:setxy(dx2, dy2)
                      local dis = DistanceXY(dx2, dy2, ax, ay)
                      local x3, y3 = pj:getxy()
                      local dis2 = DistanceXY(dx2, dy2, x3, y3)
                      Effectcreate("war3mapImported\\Texiao_heiyuzhijian.mdx", dx2, dy2, 0.2, 2, 0, ra + 180)
                      if dis2 <= 100 then
                        local dis3 = DistanceXY(x3, y3, ax, ay)
                        if dis3 <= 200 then
                          pj:setdata("真红次元闭锁超即死")
                          pj:kill(u.handle, false)
                          pj:deldata("真红次元闭锁超即死")
                        end
                        mj:groupremove(g2)
                        mj:remove()
                        timer2:remove()
                      end
                      if dis <= 101 then
                        pj:setdata("真红次元闭锁超即死")
                        pj:kill(u.handle, false)
                        pj:deldata("真红次元闭锁超即死")
                        mj:groupremove(g2)
                        mj:remove()
                        timer2:remove()
                      end
                      if 200 <= cs3 or not IsXYinAnyPlayRect(dx2, dy2) and 50 <= cs3 then
                        mj:groupremove(g2)
                        mj:remove()
                        timer2:remove()
                      end
                    end)
                  end)
                else
                  mb = pj
                  mb:effectadd("war3mapImported\\Texiao_suodingzhiyan.mdx", "overhead", 5)
                  local count = 3
                  if Nandu_Choose >= 5 then
                    count = 5
                  end
                  for i = 1, count do
                    local ax, ay = mb:getxy()
                    local ra = GetRandomAngle()
                    ax, ay = PolarXY(ax, ay, 3000, ra)
                    local mj = u:createunit("u0DE", ax, ay, ra + 180)
                    mj:setcolor(255, 255, 255, 0)
                    mj:groupadd(g2)
                    local tx, dtime
                    if Nandu_Choose <= 4 then
                      ac.wait(4600, function()
                        local aax, aay = mb:getxy()
                        ra = AngleXY(aax, aay, ax, ay)
                        tx = Effectcreate("war3mapImported\\zhishixian2.mdl", aax, aay, -1, 1, 0, ra, 0, 0, 10)
                        ac.timer(30, 5, function()
                          aax, aay = mb:getxy()
                          local ra2 = AngleXY(aax, aay, ax, ay)
                          local djd = ra2 - ra
                          SetEffectAngle(tx, djd)
                          SetEffectXY(tx, aax, aay)
                          ra = ra2
                        end)
                      end)
                    else
                      ac.wait(4750, function()
                        local aax, aay = mb:getxy()
                        ra = AngleXY(aax, aay, ax, ay)
                        tx = Effectcreate("war3mapImported\\zhishixian2.mdl", aax, aay, -1, 1, 0, ra, 0, 0, 10)
                      end)
                    end
                    ac.wait(5000, function()
                      japi.SetUnitModel(mj.handle, "war3mapImported\\Texiao_heiyuzhijian2.mdl")
                      mj:setcolor(255, 255, 255, 255)
                      ac.wait(300, function()
                        SetEffectSize(tx, 0.001)
                        DestroyEffectLua(tx)
                      end)
                      local cs3 = 0
                      local dx2, dy2 = mj:getxy()
                      ac.loop(5, function(timer2)
                        cs3 = cs3 + 1
                        dx2, dy2 = PolarXY(dx2, dy2, 100, ra + 180)
                        mj:setxy(dx2, dy2)
                        local x3, y3 = pj:getxy()
                        local dis = DistanceXY(dx2, dy2, x3, y3)
                        Effectcreate("war3mapImported\\Texiao_heiyuzhijian.mdx", dx2, dy2, 0.2, 2, 0, ra + 180)
                        if dis <= 101 then
                          if Nandu_Shenzhao then
                            pj:setdata("真红次元闭锁超即死")
                            pj:kill(u.handle, false)
                            pj:deldata("真红次元闭锁超即死")
                          elseif not pj:hasdata("真红次元闭锁即死冷却") then
                            pj:settimedata("真红次元闭锁即死冷却", 3)
                            pj:setdata("真红次元闭锁超即死")
                            pj:kill(u.handle, false)
                            pj:deldata("真红次元闭锁超即死")
                          end
                          mj:groupremove(g2)
                          mj:remove()
                          timer2:remove()
                        end
                        if 200 <= cs3 or not IsXYinAnyPlayRect(dx2, dy2) and 50 <= cs3 then
                          mj:groupremove(g2)
                          mj:remove()
                          timer2:remove()
                        end
                      end)
                    end)
                  end
                end
                local count = 2
                if Nandu_Choose >= 5 then
                  count = 1
                end
                ac.timer(1000, count, function()
                  ForGroupLuaNew(g2, function(xq)
                    local aax, aay = xq:getxy()
                    PingMinimapEx(aax, aay, 0.5, 0, 255, 0, false)
                  end)
                  local aax, aay = mb:getxy()
                  PingMinimapEx(aax, aay, 0.5, 102, 51, 255, false)
                end)
              end
            end
            if sycs == 0 or Group_Counts(g) == 0 then
              ac.wait(8000, function()
                Boolean_Zhenhong_Ciyuanbisuo = false
              end)
              ac.wait(10000, function()
                if Group_Counts(g) == 0 then
                  GameOverRun()
                else
                  ForGroupLuaNew(Group_PlayHero, function(xq)
                    if not xq:isalive() then
                      HeroRelive(xq.handle, x, y)
                    end
                    if xq:hasdata("次元闭锁锁定特效") then
                      DestroyEffectLua(xq:getdata("次元闭锁锁定特效"))
                      xq:deldata("次元闭锁锁定特效")
                    end
                    xq:deldata("次元闭锁锁定")
                    xq:deldata("次元闭锁-破界者")
                  end)
                  zhenhong_2_end(u)
                end
              end)
              timer3:remove()
            end
          end)
        end)
        timer:remove()
      end
    end)
  end,
  ["法则轮转"] = function(u)
    PlayGlobalSound(BOSS_Zhenhong_Xuli1)
    u:setdata("法则", CreateGroupLua())
    local g = u:getdata("法则")
    SendMsgAll("|cFFCC0000神迹.法则轮转|r")
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFFCC0000[显现两条缓慢转动的时空之线]|r")
    end
    local x, y = u:getxy()
    local dx, dy = PolarXY(x, y, 1500, 0)
    Effectcreate("war3mapImported\\Texiao_chengxizhiguang1.mdx", dx, dy, 0, 5)
    local mj = u:createunit("u0DC", dx, dy)
    mj:groupadd(g)
    dx, dy = PolarXY(x, y, 1500, 180)
    Effectcreate("war3mapImported\\Texiao_chengxizhiguang1.mdx", dx, dy, 0, 5)
    mj = u:createunit("u0DC", dx, dy)
    mj:groupadd(g)
    local fzg = {}
    local cs = 0
    ac.loop(5000, function(timer)
      cs = cs + 1
      PlayGlobalSound(BOSS_Zhenhong_Zhongsheng1)
      ForGroupLuaNew(g, function(xq)
        local fx = 0
        if GetRandomInt(1, 2) == 1 then
          fx = -0.1
        else
          fx = 0.1
        end
        ac.timer(10, GetRandomInt(1, 450), function()
          local ax, ay = xq:getxy()
          local jd = AngleXY(x, y, ax, ay)
          jd = jd + fx
          local bx, by = PolarXY(x, y, 1500, jd)
          xq:setxy(bx, by)
        end)
      end)
      if u:getdata("时间与空间的刻印个数") <= 0 then
        PlayGlobalSound(BOSS_Zhenhong_Keyin2)
        ForGroupLuaNew(g, function(xq)
          local ax, ay = xq:getxy()
          Effectcreate("war3mapImported\\Texiao_chengxizhiguang1.mdx", ax, ay, 0, 3)
          xq:groupremove(g)
          xq:remove()
        end)
        timer:remove()
      end
    end)
    ac.wait(5000, function()
      SendMsgAll("|cFFCC0000多维覆写|r")
      if Nandu_Choose <= 4 then
        SendMsgAll("|cFFCC0000[触碰到时空之线会受到生命损耗与伤害]|r")
      end
      ac.loop(100, function(timer)
        ForGroupLuaNew(u:getdata("法则"), function(xq)
          local ax, ay = xq:getxy()
          local jd = AngleXY(ax, ay, x, y)
          local tx = Effectcreate("war3mapImported\\Texiao_baiyu.mdl", ax, ay, -1, 0.2, 100, jd)
          local visibility = require("hera_effect_visibility").new(tx, 0.2)
          local cs1 = 0
          table.insert(fzg, tx)
          SetData(tx, "坐标X", ax)
          SetData(tx, "坐标Y", ay)
          visibility:set_visible(false)
          ac.loop(30, function(timer2)
            cs1 = cs1 + 1
            if cs1 == 1 then
              visibility:set_visible(true)
            end
            ax, ay = PolarXY(ax, ay, 100, jd)
            SetEffectXY(tx, ax, ay)
            SetData(tx, "坐标X", ax)
            SetData(tx, "坐标Y", ay)
            if cs1 == 15 then
              visibility:set_visible(false)
            end
            if cs1 == 16 then
              for i, v in ipairs(fzg) do
                if v == tx then
                  table.remove(fzg, i)
                  break
                end
              end
              DelData(tx, "坐标X")
              DelData(tx, "坐标Y")
              DestroyEffectLua(tx)
              timer2:remove()
            end
          end)
        end)
        if u:getdata("时间与空间的刻印个数") <= 0 then
          timer:remove()
        end
      end)
      ac.loop(100, function(timer2)
        ForGroupLuaNew(Group_PlayHero, function(xq)
          if xq:isalive() then
            local bx, by = xq:getxy()
            local b = false
            for i, tx in ipairs(fzg) do
              local cx = GetData(tx, "坐标X")
              local cy = GetData(tx, "坐标Y")
              local dis = DistanceXY(bx, by, cx, cy)
              if dis <= 100 then
                b = true
                break
              end
            end
            if b then
              if not xq:hasdata("永恒之锁") then
                xq:losshp(u, 0, 15, 15)
              end
              if u:hasdata("真红-三阶段强化") then
                if u:hasdata("法则循环开启") then
                  local txsh = 100 * u:getdata("怪物强度") + 0.1 * xq:getmaxhp()
                  DamageUnit({
                    unit = xq.handle,
                    source = u.handle,
                    damage = txsh,
                    level = 5,
                    type = "魔力",
                    isvest = false,
                    isattack = false,
                    isnoarmor = false,
                    element = "无",
                    extradata = {""}
                  })
                end
                if not shanbipanding(xq) and not xq:hasdata("永恒之锁") and 100 <= xq:getmaxhp() then
                  local sy = xq.ownerid
                  local down = 0.06 * xq:getmaxhp() + 90
                  xq:changemaxhp(-down)
                end
              end
            end
          end
        end)
        if u:getdata("时间与空间的刻印个数") <= 0 then
          timer2:remove()
        end
      end)
      ac.loop(500, function(timer3)
        ForGroupLuaNew(Group_PlayHero, function(xq)
          if xq:isalive() then
            local dis = DistanceBetweenUnits(xq.handle, u.handle)
            if 1140 <= dis then
              if 6000 <= dis then
                local jd = AngleBetweenUnits(u.handle, xq.handle)
                local ex, ey = PolarXY(x, y, 1000, jd)
                xq:setxy(ex, ey)
              elseif not xq:hasdata("永恒之锁") and xq:getmaxhp() >= 100 then
                local sy = xq.ownerid
                local down = 0.1 * xq:getmaxhp() + 500
                if u:hasdata("八云紫帮助") then
                  down = down * 0.5
                end
                if xq:hasdata("神器判定-永恒王座") then
                  xq:changedata("永恒王座-锁定生命上限", -down)
                else
                  xq:changemaxhp(-down)
                end
              end
            end
          end
        end)
        if u:hasdata("第三阶段结束") then
          timer3:remove()
        end
      end)
      BuffUI.apply({
        id = "青空之翼",
        duration = 30.1
      })
      ac.loop(30000, function(timer4)
        ForGroupLuaNew(Group_PlayHero, function(xq)
          xq:setdata("青空之翼增伤", 0)
          xq:setdata("青空之翼叠加层数", 0)
        end)
        BuffUI.apply({
          id = "青空之翼",
          duration = 30.1
        })
        if u:hasdata("真红-金色翎羽") then
          timer4:remove()
        else
          SendMsgAll("|cFF1BE6B8青空的力量被削弱了|r")
        end
      end)
    end)
  end,
  ["时空刻印"] = function(u)
    SendMsgAll("|cFFCC0000祈愿.时空刻印|r")
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFFCC0000[无敌一段时间并恢复状态;时空刻印达到6时进入狂暴状态]|r")
    end
    ForGroupLuaNew(Group_PlayHero, function(xq)
      xq:setdata("青空之翼增伤", 0)
    end)
    local x, y = u:getxy()
    u:setdata("真红永恒")
    local count = u:getdata("时间与空间的刻印个数")
    if not u:hasdata("永恒之轮") then
      ac.wait(60000, function()
        if count == u:getdata("时间与空间的刻印个数") and u:getdata("时间与空间的刻印个数") > 0 then
          u:changedata("时间与空间的刻印个数", -1)
          u:sethp(100, true)
          u:deldata("真红永恒")
          u:clearbuff("无敌")
        end
      end)
    end
    u:buffset(u.handle, 60, "无敌")
    if u:getmaxhp() < 21000000000 then
      u:setmaxhp(21000000000)
    end
    u:sethp(10, true)
    if u:hasdata("永恒之轮") then
      SendMsgAll("|cFFFFFF66『|r|cFFFFE65C曙|r|cFFFFCC52光|r|cFFFFB247.|r|cFFFF993D永|r|cFFFF8033恒|r|cFFFF6629之|r|cFFFF4C1F轮|r|cFFFF3314』|r")
    else
      PlayGlobalSound(BOSS_Zhenhong_Suolian1)
      if Group_Counts(u:getdata("刻印组2")) > 0 then
        local mj = FirstOfGroupLua(u:getdata("刻印组2"))
        if mj and mj ~= 0 then
          local dx, dy = mj:getxy()
          local jd = AngleBetweenUnits(u.handle, mj.handle)
          local ax, ay = PolarXY(x, y, 1350, jd)
          local tx = Effectcreate("war3mapImported\\Texiao_ciyuanbisuo.mdx", ax, ay, -1, 4, 150)
          mj:setdata("刻印之锁", tx)
          mj:groupremove(u:getdata("刻印组2"))
        end
      end
      u:changedata("时间与空间的刻印个数", -1)
    end
    ac.wait(1000, function()
      Effectcreate("war3mapImported\\Texiao_keyingfuhuo.mdx", x, y, 0, 3)
      local sj = 30
      if Nandu_Choose >= 5 then
        sj = sj + 15
      end
      if u:hasdata("两仪式帮助") then
        sj = sj * 0.5
      end
      local add = 90 / sj
      ac.loop(1000, function(timer)
        sj = sj - 1
        u:sethp(u:getperhp() + add, true)
        if sj <= 0 then
          if 0 < u:getdata("时间与空间的刻印个数") then
            u:deldata("真红永恒")
            u:clearbuff("无敌")
          end
          timer:remove()
        end
      end)
      BuffUI.apply({
        id = "永恒之轮",
        duration = sj
      })
    end)
    if u:getdata("时间与空间的刻印个数") == 6 then
      u:setdata("真红-三阶段强化")
      SendMsgAll("|cFF990000二阶堂真红：哼……碍事……|r")
      u:effectadd("war3mapImported\\44Q.mdx", "origin", -1)
    end
  end,
  ["寂灭之光"] = function(u)
    SendMsgAll("|cFFCC0000神迹.寂灭之光|r")
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFFCC0000[被锁定玩家远离其他玩家;锁定圈消失发动攻击(仅被锁定玩家可以绝对闪避);规避后续警告圈]|r")
    end
    u:animeact(6)
    local dx, dy = u:getxy()
    PlayGlobalSound(BOSS_Zhenhong_Xuli1)
    Effectcreate("war3mapImported\\Texiao_zhenhongxuli.mdx", dx, dy, 0, 1)
    ac.wait(1000, function()
      local g = CreateGroupLua()
      ForGroupLuaNew(Group_PlayHero, function(xq)
        if xq:isalive() then
          xq:groupadd(g)
        end
      end)
      local mb = Group_Randomunit(g)
      if mb == 0 then
        mb = u
      end
      mb:effectadd("war3mapImported\\Texiao_suodingzhiyan.mdx", "overhead", 3)
      local x, y = mb:getxy()
      local tx = Effectcreate("war3mapImported\\Texiao_jinggao2.mdx", x, y, -1, 5)
      local cs = 0
      PlayGlobalSound(BOSS_Zhenhong_Jiguang6)
      ac.loop(30, function(timer)
        cs = cs + 1
        x, y = mb:getxy()
        if cs <= 67 then
          SetEffectXY(tx, x, y)
        end
        if cs == 67 then
          SetEffectActSpeed(tx, 0.2)
          DestroyEffectLua(tx)
        end
        if cs == 100 then
          PlayGlobalSound(BOSS_Zhenhong_Baozha1)
          CinematicFadeBJ(bj_CINEFADETYPE_FADEOUTIN, 0.2, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 100.0, 0, 0, 0.0)
          ForGroupLuaNew(Group_PlayHero, function(xq)
            xq:shockcamera(100, 0.5)
          end)
          x, y = mb:getxy()
          Effectcreate("war3mapImported\\Texiao_chengxizhiguang1.mdx", x, y, 0, 30)
          ForGroupLuaNew(Group_PlayHero, function(xq)
            if xq:isalive() then
              local dis = DistanceBetweenUnits(xq.handle, mb.handle)
              if dis <= 500 then
                if xq.handle == mb.handle then
                  local txsh = 100 * u:getdata("怪物强度") + 0.15 * xq:getmaxhp()
                  DamageUnit({
                    unit = xq.handle,
                    source = u.handle,
                    damage = txsh,
                    level = 1,
                    type = "魔力",
                    isvest = false,
                    isattack = false,
                    isnoarmor = false,
                    element = "无",
                    extradata = {""}
                  })
                  if not shanbipanding(xq) and not xq:hasdata("永恒之锁") then
                    xq:losshp(u, 0, 25, 25)
                    if 100 <= xq:getmaxhp() then
                      local sy = xq.ownerid
                      local down = 0.08 * xq:getmaxhp() + 100
                      if Nandu_Choose <= 4 then
                        down = down * 0.5
                      end
                      xq:changemaxhp(-down)
                    end
                  end
                else
                  local txsh = 100 * u:getdata("怪物强度") + 0.15 * xq:getmaxhp()
                  DamageUnit({
                    unit = xq.handle,
                    source = u.handle,
                    damage = txsh,
                    level = 1,
                    type = "魔力",
                    isvest = false,
                    isattack = false,
                    isnoarmor = false,
                    element = "无",
                    extradata = {""}
                  })
                  if not xq:hasdata("永恒之锁") then
                    xq:losshp(u, 0, 25, 25)
                    if 100 <= xq:getmaxhp() then
                      local sy = xq.ownerid
                      local down = 0.08 * xq:getmaxhp() + 2500
                      if Nandu_Choose <= 4 then
                        down = down * 0.5
                      end
                      xq:changemaxhp(-down)
                    end
                  end
                end
              end
            end
          end)
          local cs3 = 3
          if u:hasdata("真红-三阶段强化") then
            cs3 = 10
          end
          ac.loop(1200, function(timer2)
            cs3 = cs3 - 1
            local dcs = 0
            ac.loop(30, function(timer3)
              dcs = dcs + 1
              if dcs == 1 then
                local size = 2
                local fw = 200
                if u:hasdata("真红-三阶段强化") then
                  size = 3
                  fw = 300
                end
                for i = 1, 15 do
                  local x2, y2 = PolarXY(dx, dy, GetRandomReal(0, 1200), GetRandomAngle())
                  Effectcreate("war3mapImported\\Texiao_jinggao2.mdx", x2, y2, 0.5, size)
                  ac.wait(490, function()
                    Effectcreate("war3mapImported\\Texiao_chengxizhiguang1.mdx", x2, y2, 0, 3, 0, 0, 0, 0, 2.5)
                    ForGroupLuaNew(Group_PlayHero, function(xq)
                      if xq:isalive() then
                        local ax, ay = xq:getxy()
                        local dis = DistanceXY(x2, y2, ax, ay)
                        if dis <= fw then
                          local txsh = 100 * u:getdata("怪物强度") + 0.15 * xq:getmaxhp()
                          DamageUnit({
                            unit = xq.handle,
                            source = u.handle,
                            damage = txsh,
                            level = 1,
                            type = "魔力",
                            isvest = false,
                            isattack = false,
                            isnoarmor = false,
                            element = "无",
                            extradata = {""}
                          })
                          if not shanbipanding(xq) and not xq:hasdata("永恒之锁") then
                            xq:losshp(u, 0, 25, 25)
                            if 100 <= xq:getmaxhp() then
                              local sy = xq.ownerid
                              local down = 0.06 * xq:getmaxhp() + 2500
                              if Nandu_Choose <= 4 then
                                down = down * 0.5
                              end
                              xq:changemaxhp(-down)
                            end
                          end
                        end
                      end
                    end)
                  end)
                end
              end
              if dcs == 1 then
                PlayGlobalSound(BOSS_Zhenhong_Jiguang6)
              end
              if 18 <= dcs then
                CinematicFadeBJ(bj_CINEFADETYPE_FADEOUTIN, 0.2, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 100.0, 0, 0, 0.0)
                PlayGlobalSound(BOSS_Zhenhong_Baozha1)
                ForGroupLuaNew(Group_PlayHero, function(xq)
                  xq:shockcamera(100, 0.5)
                end)
                timer3:remove()
              end
            end)
            if cs3 <= 0 then
              timer2:remove()
            end
          end)
          local dtime = 7
          if u:hasdata("真红-三阶段强化") then
            dtime = 14
          end
          ac.wait(dtime * 1000, function()
            zhenhong_3_start(u)
          end)
          timer:remove()
        end
      end)
    end)
  end,
  ["光暗共生"] = function(u)
    SendMsgAll("|cFFCC0000光暗共生|r")
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFFCC0000[规避黑羽之箭与真红脚下的至暗之域;触碰到救赎之光时一定时间内提升大量固伤]|r")
    end
    u:animeact(6)
    local dx, dy = u:getxy()
    PlayGlobalSound(BOSS_Zhenhong_Xuli1)
    Effectcreate("war3mapImported\\Texiao_zhenhongxuli.mdx", dx, dy, 0, 1)
    ac.wait(1000, function()
      ForGroupLuaNew(u:getdata("刻印组"), function(xq)
        local fx = 0.12
        ac.timer(10, 3000, function()
          local ax, ay = xq:getxy()
          local jd = AngleXY(dx, dy, ax, ay)
          jd = jd + fx
          local bx, by = PolarXY(dx, dy, 1100, jd)
          xq:setxy(bx, by)
        end)
      end)
      Effectcreate("war3mapImported\\Texiao_heihongwuqi.mdx", dx, dy, 30, 0.7)
      local tx = Effectcreate("war3mapImported\\Texiao_jinggao1.mdx", dx, dy, 30, 3)
      local fw = 300
      ac.timer(200, 150, function()
        if fw < 800 then
          fw = fw + 5
          SetEffectSize(tx, 3 * (fw / 300))
        end
        ForGroupLuaNew(Group_PlayHero, function(xq)
          if xq:isalive() then
            local dis = DistanceBetweenUnits(xq.handle, u.handle)
            if dis <= fw and not xq:hasdata("永恒之锁") then
              local txsh = 100 * u:getdata("怪物强度") + 0.05 * xq:getmaxhp()
              DamageUnit({
                unit = xq.handle,
                source = u.handle,
                damage = txsh,
                level = 5,
                type = "魔力",
                isvest = false,
                isattack = false,
                isnoarmor = false,
                element = "无",
                extradata = {""}
              })
              xq:losshp(u, 0, 1, 1)
              if 100 <= xq:getmaxhp() then
                local sy = xq.ownerid
                local down = 0.1 * xq:getmaxhp() + 15
                xq:changemaxhp(-down)
              end
            end
          end
        end)
      end)
      local cs = 0
      ac.loop(2000, function(timer)
        cs = cs + 1
        local g = CreateGroupLua()
        PlayGlobalSound(BOSS_Zhenhong_Xintiao)
        ForGroupLuaNew(Group_PlayHero, function(xq)
          xq:shockcamera(20, 0.2)
          if xq:isalive() then
            xq:groupadd(g)
          end
        end)
        ac.wait(1000, function()
          PlayGlobalSound(BOSS_Zhenhong_Heiyuzhijian1)
        end)
        local mb
        if u:hasdata("真红-三阶段强化") then
          mb = Group_Randomunit(g)
          if mb == 0 then
            mb = u
          end
          mb:effectadd("war3mapImported\\Texiao_suodingzhiyan.mdx", "overhead", 1)
        end
        ForGroupLuaNew(u:getdata("刻印组"), function(xq)
          local sj = GetRandomInt(1, 2)
          if sj == 1 then
            local dis, jd, dt, speed
            xq:setcolor(255, 0, 255)
            ac.wait(1000, function()
              local ax, ay = xq:getxy()
              if u:hasdata("真红-三阶段强化") then
                dt = 0.5
                jd = AngleBetweenUnits(xq.handle, mb.handle)
                dis = DistanceBetweenUnits(xq.handle, mb.handle)
                speed = dis / dt
                dis = dis + 400
                if dis <= 1100 then
                  dis = 1100
                end
              else
                dis = 1100
                jd = AngleBetweenUnits(xq.handle, u.handle)
                speed = 3300
              end
              unifycreate({
                owner = u.handle,
                model = "war3mapImported\\Texiao_heiyuzhijian2.mdl",
                modelname = "黑羽之箭",
                modelsize = 2,
                height = 100,
                damage = 100,
                damagetype = 1,
                x = ax,
                y = ay,
                range = dis,
                speed = speed,
                volume = 75,
                angle = jd,
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
                  local txsh = 100 * u:getdata("怪物强度") + 0.15 * xq:getmaxhp()
                  DamageUnit({
                    unit = xq.handle,
                    source = u.handle,
                    damage = txsh,
                    level = 5,
                    type = "魔力",
                    isvest = false,
                    isattack = false,
                    isnoarmor = false,
                    element = "无",
                    extradata = {""}
                  })
                  if not shanbipanding(xq) then
                    xq:losshp(u, 0, 10, 10)
                  end
                end,
                endfunc = function(mj)
                  xq:setcolor(255, 255, 255)
                end
              })
            end)
          end
          if sj == 2 then
            local jd = AngleBetweenUnits(u.handle, xq.handle)
            local dis = 1100
            local ax, ay = xq:getxy()
            unifycreate({
              owner = u.handle,
              model = "war3mapImported\\Texiao_baiyu.mdl",
              modelname = "救赎之光",
              modelsize = 0.5,
              height = 100,
              damage = 0,
              damagetype = 1,
              x = dx,
              y = dy,
              range = dis,
              speed = 500,
              volume = 75,
              angle = jd,
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
                if xq:isingroup(Group_PlayHero) then
                  mj:setdata("弹幕-生命值", 0)
                  xq:changetimedata("青空之翼基础增伤", 10000000, 30)
                end
              end,
              endfunc = function(mj)
              end
            })
          end
        end)
        if 15 <= cs then
          ac.wait(3000, function()
            zhenhong_3_start(u)
          end)
          timer:remove()
        end
      end)
    end)
  end,
  ["观测塌陷"] = function(u)
    SendMsgAll("|cFFCC0000观测塌陷|r")
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFFCC0000[在所有玩家脚下留下观测圈并随机传送;限时内回到观测圈内规避伤害]|r")
    end
    u:animeact(6)
    local dx, dy = u:getxy()
    PlayGlobalSound(BOSS_Zhenhong_Xuli1)
    Effectcreate("war3mapImported\\Texiao_zhenhongxuli.mdx", dx, dy, 0, 1)
    ac.wait(1000, function()
      CinematicFadeBJ(bj_CINEFADETYPE_FADEOUTIN, 0.3, "ReplaceableTextures\\CameraMasks\\DreamFilter_Mask.blp", 100.0, 0, 0, 50.0)
      local g = CreateGroupLua()
      ForGroupLuaNew(Group_PlayHero, function(xq)
        if xq:isalive() and not xq:hasdata("永恒之锁") then
          xq:groupadd(g)
        end
      end)
      local txg = {}
      ForGroupLuaNew(g, function(xq)
        local x, y = xq:getxy()
        local ntx = Effectcreate("war3mapImported\\Texiao_jinggao2.mdl", x, y, -1)
        SetData(ntx, "坐标X", x)
        SetData(ntx, "坐标Y", y)
        table.insert(txg, ntx)
        Effectcreate("war3mapImported\\Texiao_jinggao3.mdx", x, y, 1, 2.5)
        x, y = PolarXY(dx, dy, GetRandomReal(0, 750), GetRandomAngle())
        xq:deldata("是否射击")
        xq:setxy(x, y)
        IssueImmediateOrder(xq.handle, "stop")
        xq:setdata("位移点X", x)
        xq:setdata("位移点Y", y)
        local time = 0.5
        if Nandu_Choose <= 4 then
          time = 1
        end
        xq:buffset(u.handle, time, "绝对闪避")
      end)
      local tmax = 1.5
      ac.loop(30, function(timer)
        tmax = tmax - 0.03
        for index, tx in ipairs(txg) do
          if not HasData(tx, "已使用") then
            local ax = GetData(tx, "坐标X")
            local ay = GetData(tx, "坐标Y")
            ForGroupLuaNew(g, function(xq)
              local x, y = xq:getxy()
              local dis = DistanceXY(ax, ay, x, y)
              if dis <= 100 then
                SetEffectSize(tx, 0.001)
                SetData(tx, "已使用")
                xq:setdata("世界线波动")
              end
            end)
          end
        end
        if tmax <= 0 then
          for index, tx in ipairs(txg) do
            DestroyEffectLua(tx)
          end
          CinematicFadeBJ(bj_CINEFADETYPE_FADEOUTIN, 0.3, "ReplaceableTextures\\CameraMasks\\DreamFilter_Mask.blp", 100.0, 0, 0, 50.0)
          local down = 0.01
          if u:hasdata("真红-三阶段强化") then
            down = 0.03
          end
          ForGroupLuaNew(g, function(xq)
            if not xq:hasdata("世界线波动") then
              ac.wait(1000, function()
                local dcs = 0
                ac.loop(100, function(timer2)
                  dcs = dcs + 1
                  local ax, ay = xq:getxy()
                  Effectcreate("war3mapImported\\texiao_xuebao.mdx", ax, ay, 0, 3)
                  xq:changemaxhp(-down * xq:getmaxhp())
                  local txsh = 500 * u:getdata("怪物强度") + 0.2 * xq:getmaxhp()
                  DamageUnit({
                    unit = xq.handle,
                    source = u.handle,
                    damage = txsh,
                    level = 5,
                    type = "魔力",
                    isvest = false,
                    isattack = false,
                    isnoarmor = false,
                    element = "无",
                    extradata = {""}
                  })
                  if dcs == 5 then
                    timer2:remove()
                  end
                end)
              end)
            end
            xq:deldata("世界线波动")
          end)
          timer:remove()
        end
      end)
      local dtime = 6
      if u:hasdata("真红-三阶段强化") then
        dtime = 3
      end
      ac.wait(dtime * 1000, function()
        zhenhong_3_start(u)
      end)
    end)
  end,
  ["湮灭"] = function(u)
    SendMsgAll("|cFFCC0000神迹.湮灭|r")
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFFCC0000[短暂延迟后对所有玩家进行连续的锁定打击]|r")
    end
    u:animeact(6)
    local dx, dy = u:getxy()
    PlayGlobalSound(BOSS_Zhenhong_Xuli1)
    Effectcreate("war3mapImported\\Texiao_zhenhongxuli.mdx", dx, dy, 0, 1)
    ac.wait(1100, function()
      PlayGlobalSound(BOSS_Zhenhong_Xuli1)
      Effectcreate("war3mapImported\\Texiao_zhenhongxuli.mdx", dx, dy, 0, 1)
    end)
    ac.wait(1000, function()
      ResetUnitAnimation(u.handle)
      local dtime = 1.3
      local origintime = 1.3
      if Nandu_Choose >= 5 then
        dtime = 1.2
        origintime = 1.2
      end
      ac.wait(2000, function()
        PlayGlobalSound(BOSS_Zhenhong_Xintiao)
      end)
      do
        local cs = 0
        local t = dtime
        ac.loop(10, function(timer)
          cs = cs + 1
          t = t + origintime - 0.1 * cs
          ac.wait(t * 1000, function()
            PlayGlobalSound(BOSS_Zhenhong_Yanmie)
          end)
          if 8 <= cs then
            timer:remove()
          end
        end)
      end
      local g = CreateGroupLua()
      ForGroupLuaNew(Group_PlayHero, function(xq)
        if xq:isalive() then
          xq:groupadd(g)
        end
      end)
      ForGroupLuaNew(Group_PlayHero, function(xq)
        local x, y = xq:getxy()
        local cs = 0
        local t = dtime
        ac.loop(10, function(timer)
          cs = cs + 1
          t = t + origintime - 0.1 * cs
          ac.wait(t * 1000, function()
            local jd = AngleBetweenUnits(u.handle, xq.handle)
            EffectcreateArgs({
              effect = "war3mapImported\\Texiao_shenfa2.mdx",
              x = dx,
              y = dy,
              time = 0,
              size = 5,
              height = 100,
              zxz = jd,
              yxz = 90
            })
            local x1, y1 = PolarXY(dx, dy, -150, jd)
            local bx, by = PolarXY(dx, dy, 1200, jd)
            EffectcreateArgs({
              effect = "war3mapImported\\Texiao_chengxizhiguang2.mdx",
              x = bx,
              y = by,
              size = 2,
              zxz = jd
            })
            local g2 = CreateGroupLua()
            loopmove({
              x = x1,
              y = y1,
              time = 0.1,
              distance = 3000,
              angle = jd,
              loops = {
                {
                  looptime = 0.01,
                  func = function(ddx, ddy)
                    for _, xq2 in ac.selector():in_rangexy(ddx, ddy, 200):is_enemy(u.handle):isnotingroup(g2):isingroup(Group_PlayHero):ipairs() do
                      xq2 = getunit(xq2)
                      xq2:groupadd(g2)
                      local txsh = 200 * u:getdata("怪物强度") + 0.1 * xq2:getmaxhp()
                      DamageUnit({
                        unit = xq2.handle,
                        source = u.handle,
                        damage = txsh,
                        level = 5,
                        type = "魔力",
                        isvest = false,
                        isattack = false,
                        isnoarmor = false,
                        element = "无",
                        extradata = {""}
                      })
                      if not shanbipanding(xq2) then
                        xq2:losshp(u, 0, 15, 15)
                      end
                    end
                  end
                }
              }
            })
          end)
          if 8 <= cs then
            timer:remove()
          end
        end)
      end)
      local waittime = 10
      if u:hasdata("真红-三阶段强化") then
        waittime = 6
      end
      ac.wait(waittime * 1000, function()
        zhenhong_3_start(u)
      end)
    end)
  end,
  ["黯世"] = function(u)
    SendMsgAll("|cFFCC0000神迹.黯世|r")
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFFCC0000[跟随玩家释放神罚,3秒后在真红周围释放神罚]|r")
    end
    u:animeact(6)
    local dx, dy = u:getxy()
    PlayGlobalSound(BOSS_Zhenhong_Xuli1)
    Effectcreate("war3mapImported\\Texiao_zhenhongxuli.mdx", dx, dy, 0, 2)
    ac.wait(1000, function()
      ResetUnitAnimation(u.handle)
      PlayGlobalSound(BOSS_Zhenhong_Shandian3)
      zhenhongskill_3_anshi(u)
      local cs4 = 0
      ac.loop(10000, function(timer)
        cs4 = cs4 + 1
        PlayGlobalSound(BOSS_Zhenhong_Shandian3)
        zhenhongskill_3_anshi(u)
        if cs4 == 2 then
          if u:hasdata("真红-三阶段强化") then
            ac.wait(8500, function()
              Effectcreate("war3mapImported\\Texiao_jinggao2.mdx", dx, dy, 0.5, 10, 10)
              ac.wait(800, function()
                PlayGlobalSound(BOSS_Zhenhong_Baozha1)
                local a = GetRandomAngle()
                for i = 1, 6 do
                  a = a + 60
                  local x3, y3 = PolarXY(dx, dy, 550, a)
                  EffectcreateArgs({
                    effect = "war3mapImported\\Texiao_shenfa2.mdx",
                    x = x3,
                    y = y3,
                    size = 20,
                    animespeed = 2
                  })
                end
                ForGroupLuaNew(Group_PlayHero, function(xq)
                  if xq:isalive() then
                    local ax, ay = xq:getxy()
                    local dis = DistanceXY(dx, dy, ax, ay)
                    if dis <= 1100 then
                      local txsh = 250 * u:getdata("怪物强度") + 0.1 * xq:getmaxhp()
                      DamageUnit({
                        unit = xq.handle,
                        source = u.handle,
                        damage = txsh,
                        level = 5,
                        type = "魔力",
                        isvest = false,
                        isattack = false,
                        isnoarmor = false,
                        element = "无",
                        extradata = {""}
                      })
                      if not shanbipanding(xq) then
                        xq:losshp(u, 0, 15, 15)
                        xq:buffset(u.handle, 5, "缠绕")
                        xq:buffset(u.handle, 5, "麻痹")
                        if not xq:hasdata("真红-神罚破坏") then
                          xq:settimedata("真红-神罚破坏", 10)
                        end
                      end
                    end
                  end
                end)
              end)
            end)
          end
          local waittime = 10
          ac.wait(waittime * 1000, function()
            ResetUnitAnimation(u.handle)
            u:setface(270)
            zhenhong_3_start(u)
          end)
          timer:remove()
        end
      end)
    end)
  end,
  ["黯羽裁决"] = function(u)
    SendMsgAll("|cFFCC0000神迹.黯羽裁决|r")
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFFCC0000[随机对所有变色的时空刻印释放黯羽之箭并扩散]|r")
    end
    u:animeact(6)
    local dx, dy = u:getxy()
    PlayGlobalSound(BOSS_Zhenhong_Xuli1)
    Effectcreate("war3mapImported\\Texiao_zhenhongxuli.mdx", dx, dy, 0, 2)
    ac.wait(1000, function()
      ResetUnitAnimation(u.handle)
      local ng = Group_Randomunits(u:getdata("刻印组"), 7)
      ForGroupLuaNew(ng, function(xq)
        xq:setcolor(255, 0, 255)
      end)
      local dtime = 1.1
      local origintime = 1.1
      local cs = 0
      ac.loop(10, function(timer)
        cs = cs + 1
        dtime = dtime + origintime - 0.1 * cs
        ac.wait(dtime * 1000, function()
          if Group_Counts(ng) > 0 then
            local mb = Group_Randomunit(ng)
            mb:groupremove(ng)
            local jd = AngleBetweenUnits(u.handle, mb.handle)
            u:animeact(4)
            u:setface(jd)
            ac.wait(500, function()
              PlayGlobalSound(BOSS_Zhenhong_Heiyuzhijian1)
              unifycreate({
                owner = u.handle,
                model = "war3mapImported\\Texiao_heiyuzhijian2.mdl",
                modelname = "黯羽之箭",
                modelsize = 3,
                height = 100,
                damage = 100,
                damagetype = 1,
                x = dx,
                y = dy,
                range = 1100,
                speed = 3300,
                volume = 125,
                angle = jd,
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
                  local txsh = 100 * u:getdata("怪物强度") + 0.15 * xq:getmaxhp()
                  DamageUnit({
                    unit = xq.handle,
                    source = u.handle,
                    damage = txsh,
                    level = 5,
                    type = "魔力",
                    isvest = false,
                    isattack = false,
                    isnoarmor = false,
                    element = "无",
                    extradata = {""}
                  })
                  if not shanbipanding(xq) then
                    xq:losshp(u, 0, 10, 10)
                  end
                end,
                endfunc = function(mj)
                  mb:setcolor(255, 255, 255)
                  local ax, ay = mj:getxy()
                  jd = jd + 180
                  jd = jd - 45 - 22.5
                  for i = 1, 5 do
                    jd = jd + 22.5
                    unifycreate({
                      owner = u.handle,
                      model = "war3mapImported\\Texiao_heiyuzhijian2.mdl",
                      modelname = "黯羽之箭",
                      modelsize = 2,
                      height = 100,
                      damage = 100,
                      damagetype = 1,
                      x = ax,
                      y = ay,
                      range = 2200,
                      speed = 3300,
                      volume = 100,
                      angle = jd,
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
                        local txsh = 100 * u:getdata("怪物强度") + 0.15 * xq:getmaxhp()
                        DamageUnit({
                          unit = xq.handle,
                          source = u.handle,
                          damage = txsh,
                          level = 5,
                          type = "魔力",
                          isvest = false,
                          isattack = false,
                          isnoarmor = false,
                          element = "无",
                          extradata = {""}
                        })
                        if not shanbipanding(xq) then
                          xq:losshp(u, 0, 10, 10)
                        end
                      end,
                      endfunc = function(mj)
                        mb:setcolor(255, 255, 255)
                      end
                    })
                  end
                end
              })
            end)
          end
        end)
        if 7 <= cs then
          timer:remove()
        end
      end)
      if u:hasdata("真红-三阶段强化") then
        ac.wait(3000, function()
          ac.timer(2000, 4, function()
            ac.wait(2000, function()
              PlayGlobalSound(BOSS_Zhenhong_Heiyuzhijian2)
            end)
            for i = 1, 3 do
              local ax, ay = u:getxy()
              if GetRandom100(50) then
                local g = CreateGroupLua()
                ForGroupLuaNew(Group_PlayHero, function(xq)
                  if xq:isalive() then
                    xq:groupadd(g)
                  end
                end)
                local hero = Group_Randomunit(g)
                if hero == 0 then
                  hero = u
                end
                ax, ay = hero:getxy()
              end
              local ox = ax
              local oy = ay
              local ra = GetRandomAngle()
              ax, ay = PolarXY(ax, ay, 3000, ra)
              local mj = u:createunit("u0DE", ax, ay, ra + 180)
              mj:setcolor(255, 255, 255, 0)
              local tx = Effectcreate("war3mapImported\\zhishixian2.mdl", ox, oy, -1, 1, 50, ra)
              ac.wait(2000, function()
                mj:setcolor(255, 255, 255, 255)
                ac.wait(100, function()
                  SetEffectSize(tx, 0.001)
                  DestroyEffectLua(tx)
                end)
                local cs3 = 0
                local dx2, dy2 = mj:getxy()
                ac.loop(10, function(timer2)
                  cs3 = cs3 + 1
                  dx2, dy2 = PolarXY(dx2, dy2, 100, ra + 180)
                  mj:setxy(dx2, dy2)
                  Effectcreate("war3mapImported\\Texiao_heiyuzhijian.mdx", dx2, dy2, 0.2, 2, 0, ra + 180)
                  ForGroupLuaNew(Group_PlayHero, function(xq)
                    if xq:isalive() then
                      local x3, y3 = xq:getxy()
                      local dis = DistanceXY(dx2, dy2, x3, y3)
                      if dis <= 101 then
                        local txsh = 100 * u:getdata("怪物强度") + 0.15 * xq:getmaxhp()
                        DamageUnit({
                          unit = xq.handle,
                          source = u.handle,
                          damage = txsh,
                          level = 1,
                          type = "魔力",
                          isvest = false,
                          isattack = false,
                          isnoarmor = false,
                          element = "无",
                          extradata = {""}
                        })
                        if not xq:hasdata("永恒之锁") then
                          xq:losshp(u, 0, 25, 25)
                          if 100 <= xq:getmaxhp() then
                            local sy = xq.ownerid
                            local down = 0.15 * xq:getmaxhp() + 100
                            xq:changemaxhp(-down)
                          end
                        end
                        mj:remove()
                        timer2:remove()
                      end
                    end
                  end)
                  if 50 <= cs3 or not IsXYinAnyPlayRect(dx2, dy2) then
                    mj:remove()
                    timer2:remove()
                  end
                end)
              end)
            end
          end)
        end)
      end
      local waittime = 9
      if u:hasdata("真红-三阶段强化") then
        waittime = 13
      end
      ac.wait(waittime * 1000, function()
        u:setface(270)
        zhenhong_3_start(u)
      end)
    end)
  end,
  ["法则循环"] = function(u)
    SendMsgAll("|cFFCC0000神迹.法则循环|r")
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFFCC0000[时空之线数量增加,触碰伤害提升]|r")
    end
    u:animeact(6)
    u:setdata("法则循环开启")
    local dx, dy = u:getxy()
    PlayGlobalSound(BOSS_Zhenhong_Xuli1)
    Effectcreate("war3mapImported\\Texiao_zhenhongxuli.mdx", dx, dy, 0, 2)
    ac.wait(1000, function()
      ResetUnitAnimation(u.handle)
    end)
    ac.timer(1000, 6, function()
      PlayGlobalSound(BOSS_Zhenhong_Keyin2)
      local ax, ay = PolarXY(dx, dy, 1500, GetRandomAngle())
      Effectcreate("war3mapImported\\Texiao_jinggao1.mdx", ax, ay, 1, 2)
      ac.wait(1000, function()
        Effectcreate("war3mapImported\\Texiao_chengxizhiguang1.mdx", ax, ay, 0, 5)
        local mj = u:createunit("u0DC", ax, ay)
        mj:groupadd(u:getdata("法则"))
        ac.wait(30000, function()
          PlayGlobalSound(BOSS_Zhenhong_Keyin2)
          ax, ay = mj:getxy()
          Effectcreate("war3mapImported\\Texiao_chengxizhiguang1.mdx", ax, ay, 0, 3)
          mj:groupremove(u:getdata("法则"))
          mj:remove()
        end)
      end)
    end)
    local waittime = 40
    if u:hasdata("真红-三阶段强化") then
      waittime = 33
    end
    ac.wait(waittime * 1000, function()
      u:deldata("法则循环开启")
      zhenhong_3_start(u)
    end)
  end,
  ["金色翎羽"] = function(u)
    SendMsgAll("|cFFCC0000真理·金色翎羽|r")
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFFCC0000[对NPC和玩家进行点名,点名结束后根据点名顺序进行打击,仅绝对闪避可以规避;未闪避时消耗残机,残机不足时抹除]|r")
    end
    u:buffset(u.handle, 3600, "无敌")
    u:setdata("真红永恒")
    u:setdata("真红-金色翎羽")
    Boolean_Jinselingyu = true
    u:animeact(6)
    local x, y = u:getxy()
    Effectcreate("war3mapImported\\Texiao_zhenhongxuli.mdx", x, y)
    PlayGlobalSound(BOSS_Zhenhong_Xuli1)
    
    local function generateChineseNumbers(n)
      local chineseNumbers = {
        "一",
        "二",
        "三",
        "四",
        "五",
        "六",
        "七",
        "八",
        "九",
        "十",
        "十一",
        "十二",
        "十三",
        "十四",
        "十五",
        "十六",
        "十七",
        "十八",
        "十九",
        "二十",
        "二十一",
        "二十二",
        "二十三",
        "二十四",
        "二十五",
        "二十六",
        "二十七",
        "二十八",
        "二十九",
        "三十"
      }
      return chineseNumbers[n]
    end
    
    ac.wait(1000, function()
      local hero = CreateGroupLua()
      local dwz = CreateGroupLua()
      ForGroupLuaNew(GroupNpc, function(xq)
        local handle = xq.handle
        if handle ~= NPC_Nilu and handle ~= NPC_Wst_Diaoxiang and handle ~= NPC_ZHENHONG and handle ~= NPC_Molijiedian and handle ~= NPC_WUJI and handle ~= NPC_Yuanshichulisheshi and handle ~= NPC_WeiqidongXianqujiagongchang and handle ~= NPC_Xianqujiagongchang and handle ~= NPC_Xingshang then
          local dx, dy = xq:getxy()
          xq:setdata("保存X", dx)
          xq:setdata("保存Y", dy)
          xq:groupadd(dwz)
          xq:setdata("真红-NPC判定")
          xq:setdata("NPC名字", GetUnitName(xq.handle))
          if handle == NPC_YIDIAN then
            xq:setcolor(255, 255, 255, 155)
          end
        end
      end)
      ForGroupLuaNew(Group_Zhenhongshanmo, function(xq)
        xq:groupadd(dwz)
        xq:setdata("真红-NPC判定")
        xq:setdata("NPC名字", GetUnitName(xq.handle))
        ShowUnit(xq.handle, true)
      end)
      local pfz = {}
      local djd = 360 / Group_Counts(dwz)
      local jda = GetRandomAngle()
      ForGroupLuaNew(dwz, function(xq)
        jda = jda + djd
        local jl = 800
        local x2, y2 = PolarXY(x, y, jl, jda)
        xq:setxy(x2, y2)
        Effectcreate("war3mapImported\\Texiao_chengxizhiguang1.mdx", x2, y2, 0, 3)
        if Nandu_Choose <= 4 then
          local wz = flytext({
            unit = xq.handle,
            text = xq:getdata("NPC名字"),
            size = 10,
            time = -1,
            height = -50,
            yspeed = 0
          })
          table.insert(pfz, wz)
        end
      end)
      ForGroupLuaNew(Group_PlayHero, function(xq)
        local sy = xq.ownerid
        xq:groupadd(hero)
        xq:groupadd(dwz)
        HeroRelive(xq.handle, x, y)
      end)
      local sl = Group_Counts(dwz)
      local cs = 20 - u:getdata("真红-任务完成数")
      if Nandu_Choose == 4 then
        cs = cs - 6
      end
      local b = true
      ac.loop(1000 * sl, function(timer)
        cs = cs - 1
        if b then
          local js = GetRandomReal(1, 2.5)
          local dwz1 = CreateGroupLua()
          ForGroupLuaNew(dwz, function(xq)
            xq:groupadd(dwz1)
          end)
          local count = Group_Counts(dwz1)
          local cs1 = Group_Counts(dwz1)
          local xuhao = 0
          ac.loop(200, function(timer2)
            cs1 = cs1 - 1
            local mb = Group_Randomunit(dwz1)
            mb:groupremove(dwz1)
            PlayGlobalSound(BOSS_Zhenhong_Tishi2)
            local zfc
            if mb:hasdata("真红-NPC判定") then
              zfc = GetUnitName(mb.handle)
            else
              zfc = mb:getplayername()
            end
            if Nandu_Choose <= 4 then
              xuhao = xuhao + 1
              SendMsgAll("|cFFCC0033二阶堂真红：|r" .. xuhao .. "." .. zfc, 30)
            else
              SendMsgAll("|cFFCC0033二阶堂真红： |r" .. zfc, 0.01)
            end
            if mb:isingroup(hero) then
              mb:effectadd("war3mapImported\\Texiao_jinggao1.mdx", "origin", js + 0.2 * count)
            else
              local bx, by = mb:getxy()
              Effectcreate("war3mapImported\\Texiao_jinggao1.mdx", bx, by, js + 0.2 * count)
            end
            ac.wait((js + 0.2 * count) * 1000, function()
              PlayGlobalSound(BOSS_Zhenhong_Tishi2)
              local bx, by = mb:getxy()
              Effectcreate("war3mapImported\\Texiao_chengxizhiguang1.mdx", bx, by, 0, 3)
              if mb:isingroup(Group_PlayHero) then
                DamageUnit({
                  unit = mb.handle,
                  source = u.handle,
                  damage = 1000,
                  level = 5,
                  type = "物理",
                  isvest = false,
                  isattack = false,
                  isnoarmor = false,
                  element = "无",
                  extradata = {""}
                })
                if not shanbipanding(mb) then
                  if 0 < mb:getdata("残机剩余数量") then
                    mb:changedata("残机剩余数量", -1)
                    mb:setusedfodd(u:getdata("残机剩余数量"))
                  else
                    mb:groupremove(hero)
                    mb:setdata("真红-NPC判定")
                    mb:setdata("NPC名字", GetUnitName(mb.handle))
                    shanmopanding(mb)
                  end
                end
              end
            end)
            if cs1 <= 0 then
              ac.wait((js - 0.4) * 1000, function()
                if cs == 0 then
                  SendMsgAll("|cFFFF0000真|r|cFFFF1700理|r|cFFFF2E00裁|r|cFFFF4600决|r|cFFFF5D00 |r|cFFFF7400-|r|cFFFF8B00 |r|cFFFFA200第|r|cFFFFB900" .. "零" .. "|r|cFFFFD100界|r")
                else
                  SendMsgAll("|cFFFF0000真|r|cFFFF1700理|r|cFFFF2E00裁|r|cFFFF4600决|r|cFFFF5D00 |r|cFFFF7400-|r|cFFFF8B00 |r|cFFFFA200第|r|cFFFFB900" .. generateChineseNumbers(cs) .. "|r|cFFFFD100界|r")
                end
                PlayGlobalSound(BOSS_Zhenhong_Xintiao)
                u:animeact(6)
                ForGroupLuaNew(Group_PlayHero, function(xq)
                  xq:shockcamera(20, js - 0.2)
                end)
                ac.wait((js + 0.2) * 1000, function()
                  ClearTextMessages()
                end)
              end)
              ac.wait((js + 0.4 + 0.2 * count) * 1000, function()
                ClearTextMessages()
                ResetUnitAnimation(u.handle)
                ForGroupLuaNew(hero, function(xq)
                  xq:clearbuff("绝对闪避")
                end)
                if Group_Counts(hero) <= 0 then
                  b = false
                  GameOverRun()
                  for index, value in ipairs(pfz) do
                    TimerDestroyTextTag(0, value)
                  end
                end
              end)
              timer2:remove()
            end
          end)
          if cs <= 0 then
            ac.wait(10000, function()
              Boolean_Jinselingyu = false
              ForGroupLuaNew(Group_Zhenhongshanmo, function(xq)
                xq:groupremove(dwz)
                ShowUnit(xq.handle, false)
              end)
              for index, value in ipairs(pfz) do
                TimerDestroyTextTag(0, value)
              end
              ForGroupLuaNew(dwz, function(xq)
                if xq:hasdata("真红-NPC判定") then
                  local ax, ay = xq:getxy()
                  Effectcreate("war3mapImported\\Texiao_chengxizhiguang1.mdx", ax, ay, 0, 3)
                  xq:setxy(xq:getdata("保存X"), xq:getdata("保存Y"))
                  xq:deldata("真红-NPC判定")
                  if xq.handle == NPC_YIDIAN then
                    xq:setcolor(255, 255, 255, 255)
                  end
                end
              end)
              if Group_Counts(hero) == 0 then
                GameOverRun()
              else
                zhenhong_3_end(u)
              end
            end)
            timer:remove()
          end
        else
          timer:remove()
        end
      end)
    end)
  end
}

function zhenhong_3_start(u)
  if u:hasdata("第三阶段结束") then
    return
  end
  if u:getdata("时间与空间的刻印个数") <= 0 then
    ZhenhongSkill["金色翎羽"](u)
    return
  end
  if u:getdata("技能循环") >= 7 then
    u:setdata("技能循环", 1)
  else
    u:changedata("技能循环", 1)
  end
  local xh = u:getdata("技能循环")
  if u:getdata("时间与空间的刻印个数") >= 6 then
    xh = 13 - u:getdata("时间与空间的刻印个数")
  end
  if xh == 1 then
    ZhenhongSkill["寂灭之光"](u)
  end
  if xh == 2 then
    ZhenhongSkill["光暗共生"](u)
  end
  if xh == 3 then
    if u:getdata("时间与空间的刻印个数") <= 6 then
      ac.wait(20000, function()
        ZhenhongSkill["观测塌陷"](u)
      end)
    else
      ZhenhongSkill["观测塌陷"](u)
    end
  end
  if xh == 4 then
    ZhenhongSkill["湮灭"](u)
  end
  if xh == 5 then
    ZhenhongSkill["黯世"](u)
  end
  if xh == 6 then
    ZhenhongSkill["黯羽裁决"](u)
  end
  if xh == 7 then
    ZhenhongSkill["法则循环"](u)
  end
end

function zhenhong_3_end(u)
  u:deldata("真红-金色翎羽")
  BuffUI.remove("世界的尽头")
  Nofail_Biaoji = true
  local x, y = u:getxy()
  SetUnitOwner(u.handle, Player(PLAYER_NEUTRAL_PASSIVE), false)
  ForGroupLuaNew(u:getdata("刻印组"), function(xq)
    DestroyEffectLua(xq:getdata("刻印之锁"))
    xq:deldata("刻印之锁")
  end)
  SetTimeOfDay(12)
  u:setdata("第三阶段结束")
  u:setdata("时间与空间的刻印个数", 0)
  u:setface(270)
  u:addskill("A00N")
  ResetUnitAnimation(u.handle)
  local cs = 0
  ac.loop(1000, function(timer)
    cs = cs + 1
    Movie_Boolean = true
    if cs == 250 then
      Movie_Boolean = false
      FogEnable(true)
      FogMaskEnable(true)
      timer:remove()
    end
  end)
  local qk
  ChangeBGM(BOSS_Zhenhong_Start6)
  SendDtimeMsgAll(0, "|cFFFF9933二阶堂真红：|r|cFFFF9933呃......|r", 10)
  ac.wait(1, function()
    PlayGlobalSound(BOSS_Zhenhong_Yuyin2)
  end)
  SendDtimeMsgAll(3, "|cFFFF9933我从漫长的梦中苏醒|r", 10)
  SendDtimeMsgAll(6, "|cFFFF9933二阶堂真红：|r|cFFFF9933......某个人的记忆|r", 10)
  ac.wait(6000, function()
    PlayGlobalSound(BOSS_Zhenhong_Yuyin3)
  end)
  SendDtimeMsgAll(10, "|cFFFF9933某个人的愿望|r", 10)
  SendDtimeMsgAll(12, "|cFFFF9933二阶堂真红：|r|cFFFF9933但是，刚才的梦是真的吗？|r", 10)
  ac.wait(12000, function()
    PlayGlobalSound(BOSS_Zhenhong_Yuyin4)
  end)
  SendDtimeMsgAll(18, "|cFFFF9933那个好像随时都会到来的未来.......|r", 10)
  SendDtimeMsgAll(21, "|cFFFF9933那个我无法达到的未来......|r", 10)
  SendDtimeMsgAll(24, "|cFFFF9933一个小小的女孩来到了我的身边.....并为我带来了Happy End...|r", 10)
  ac.wait(27000, function()
    SendDtimeMsgAll(0, "|cFFFF9933二阶堂真红：|r|cFFFF9933啊....... |r", 10)
    if Nandu_Choose >= 5 then
      flashphoto({
        photo = "Ph_Zhenhong_03E1.tga",
        timeout = 3,
        timehold = 2,
        timein = 3
      })
    else
      CinematicFadeBJ(bj_CINEFADETYPE_FADEOUTIN, 8.0, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 100.0, 100.0, 0.0)
    end
    PlayGlobalSound(BOSS_Zhenhong_Yuyin5)
    ac.wait(4000, function()
      qk = u:createunit("u03J", x, y - 100, 90)
    end)
    SendDtimeMsgAll(7, "|cFFFF9933耀眼的光彩在我面前铺陈开来——|r", 10)
    SendDtimeMsgAll(10, "|cFFFF9933青空……|r", 10)
    SendDtimeMsgAll(13, "|cFFFF9933.......青空降临到了我的身旁|r", 10)
    SendDtimeMsgAll(17, "|cFFFF9933二阶堂青空：|r|cFF66FFCC还没有|r", 10)
    ac.wait(17000, function()
      PlayGlobalSound(BOSS_Zhenhong_Yuyin6)
    end)
    SendDtimeMsgAll(20, "|cFFFF9933二阶堂真红：|r|cFFFF9933诶？ |r", 10)
    ac.wait(20000, function()
      PlayGlobalSound(BOSS_Zhenhong_Yuyin7)
    end)
    SendDtimeMsgAll(23, "|cFFFF9933——不经意间，我的左手被某种柔和的温暖所包裹|r", 10)
    SendDtimeMsgAll(26, "|cFFFF9933二阶堂青空：|r|cFF66FFCC还没有放弃！|r", 10)
    ac.wait(26000, function()
      PlayGlobalSound(BOSS_Zhenhong_Yuyin8)
    end)
    SendDtimeMsgAll(30, "|cFFFF9933二阶堂真红：|r|cFFFF9933........还没有？ |r", 10)
    ac.wait(30000, function()
      PlayGlobalSound(BOSS_Zhenhong_Yuyin9)
    end)
    SendDtimeMsgAll(35, "|cFFFF9933二阶堂青空：|r|cFF66FFCC是的........大家无数次地跌倒又站起，一直在努力着|r", 10)
    ac.wait(35000, function()
      PlayGlobalSound(BOSS_Zhenhong_Yuyin10)
    end)
    SendDtimeMsgAll(40, "|cFFFF9933这个女孩告诉了我一直以来大家都在与什么战斗。|r", 10)
    SendDtimeMsgAll(43, "|cFFFF9933二阶堂青空：|r|cFF66FFCC.........|r", 10)
    ac.wait(43000, function()
      PlayGlobalSound(BOSS_Zhenhong_Yuyin11)
    end)
    SendDtimeMsgAll(45, "|cFFFF9933二阶堂真红：|r|cFFFF9933........ |r", 10)
    ac.wait(45000, function()
      PlayGlobalSound(BOSS_Zhenhong_Yuyin12)
    end)
  end)
  ac.wait(75000, function()
    SendDtimeMsgAll(1, "|cFFFF9933........不会错，她就是我梦到的那个女孩。|r", 10)
    SendDtimeMsgAll(4, "|cFFFF9933并且我现在也明白了。|r", 10)
    SendDtimeMsgAll(7, "|cFFFF9933我怎么会不明白呢。|r", 10)
    SendDtimeMsgAll(10, "|cFFFF9933我比任何人都要了解这个孩子。|r", 10)
    SendDtimeMsgAll(13, "|cFFFF9933二阶堂真红：|r|cFFFF9933你是....... |r", 10)
    ac.wait(13000, function()
      PlayGlobalSound(BOSS_Zhenhong_Yuyin13)
    end)
    SendDtimeMsgAll(17, "|cFFFF9933二阶堂青空：|r|cFF66FFCC魔法已经结束了。所以被知道身份也没事了哦~|r", 10)
    ac.wait(17000, function()
      PlayGlobalSound(BOSS_Zhenhong_Yuyin14)
    end)
    SendDtimeMsgAll(27, "|cFFFF9933二阶堂真红：|r|cFFFF9933嗯...... |r", 10)
    ac.wait(27000, function()
      PlayGlobalSound(BOSS_Zhenhong_Yuyin15)
    end)
    SendDtimeMsgAll(30, "|cFFFF9933我露出了微笑|r", 10)
    SendDtimeMsgAll(33, "|cFFFF9933但是。|r", 10)
    SendDtimeMsgAll(36, "|cFFFF9933我却不知道如何开口。|r", 10)
    SendDtimeMsgAll(39, "|cFFFF9933望着这个如此可爱的孩子.........|r", 10)
    SendDtimeMsgAll(42, "|cFFFF9933对不起。|r", 10)
    SendDtimeMsgAll(45, "|cFFFF9933对不起，让你独自一人那么寂寞|r", 10)
  end)
  ac.wait(120000, function()
    ChangeBGM(BOSS_Zhenhong_Start8)
    SendDtimeMsgAll(3, "|cFFFF9933二阶堂青空：|r|cFF66FFCC我会等着的|r", 10)
    SendDtimeMsgAll(6, "|cFFFF9933这个瞳孔像青空一般蔚蓝的女孩抱住了我|r", 10)
    SendDtimeMsgAll(9, "|cFFFF9933二阶堂青空：|r|cFF66FFCC妈妈，拜托了..........请一定要回来哦~|r", 10)
    ac.wait(9000, function()
      PlayGlobalSound(BOSS_Zhenhong_Yuyin16)
    end)
    SendDtimeMsgAll(16, "|cFFFF9933二阶堂青空：|r|cFF66FFCC我们能做的就是这些了.....已经不能在陪着你在这条路上前进了~|r", 10)
    ac.wait(16000, function()
      PlayGlobalSound(BOSS_Zhenhong_Yuyin17)
    end)
    SendDtimeMsgAll(26, "|cFFFF9933二阶堂青空：|r|cFF66FFCC但是我相信，自己能向妈妈尽情撒娇的日子一定会到来，我会一直等着的|r", 10)
    ac.wait(26000, function()
      PlayGlobalSound(BOSS_Zhenhong_Yuyin18)
    end)
    SendDtimeMsgAll(36, "|cFFFF9933二阶堂真红：|r|cFFFF9933......... |r", 10)
    ac.wait(36000, function()
      PlayGlobalSound(BOSS_Zhenhong_Yuyin19)
    end)
    SendDtimeMsgAll(39, "|cFFFF9933二阶堂青空：|r|cFF66FFCC.......妈妈|r", 10)
    ac.wait(39000, function()
      PlayGlobalSound(BOSS_Zhenhong_Yuyin20)
    end)
    SendDtimeMsgAll(42, "|cFFFF9933二阶堂青空：|r|cFF66FFCC我得走了|r", 10)
    ac.wait(42000, function()
      PlayGlobalSound(BOSS_Zhenhong_Yuyin21)
    end)
    SendDtimeMsgAll(47, "|cFFFF9933二阶堂真红：|r|cFFFF9933到时间了吗？|r", 10)
    ac.wait(47000, function()
      PlayGlobalSound(BOSS_Zhenhong_Yuyin22)
    end)
    SendDtimeMsgAll(50, "|cFFFF9933二阶堂青空：|r|cFF66FFCC........嗯|r", 10)
    ac.wait(50000, function()
      PlayGlobalSound(BOSS_Zhenhong_Yuyin23)
    end)
    SendDtimeMsgAll(54, "|cFFFF9933二阶堂真红：|r|cFFFF9933你没法再和我一起前行了吧|r", 10)
    ac.wait(54000, function()
      PlayGlobalSound(BOSS_Zhenhong_Yuyin24)
    end)
    SendDtimeMsgAll(59, "|cFFFF9933二阶堂青空：|r|cFF66FFCC抱歉呢......妈妈|r", 10)
    ac.wait(59000, function()
      PlayGlobalSound(BOSS_Zhenhong_Yuyin25)
    end)
  end)
  ac.wait(182000, function()
    SendDtimeMsgAll(1, "|cFFFF9933我紧紧抱起了这个小小生命。|r", 10)
    SendDtimeMsgAll(4, "|cFFFF9933二阶堂青空：|r|cFF66FFCC啊........ |r", 10)
    ac.wait(4000, function()
      PlayGlobalSound(BOSS_Zhenhong_Yuyin29)
    end)
    SendDtimeMsgAll(7, "|cFFFF9933二阶堂真红：|r|cFFFF9933谢谢，谢谢你为了我变得这么坚强|r", 10)
    ac.wait(7000, function()
      PlayGlobalSound(BOSS_Zhenhong_Yuyin30)
    end)
    SendDtimeMsgAll(16, "|cFFFF9933二阶堂青空：|r|cFF66FFCC呜、呜呜......... |r", 10)
    ac.wait(16000, function()
      PlayGlobalSound(BOSS_Zhenhong_Yuyin31)
    end)
    SendDtimeMsgAll(20, "|cFFFF9933我更加用力地搂紧了她。|r", 10)
    SendDtimeMsgAll(23, "|cFFFF9933我闻到了太阳的味道。|r", 10)
    SendDtimeMsgAll(26, "|cFFFF9933.......一阵非常非常温柔的味道。|r", 10)
    SendDtimeMsgAll(29, "|cFFFF9933.........伴随着小小的微笑，怀中的生命便化为光消散在天际", 10)
    ac.wait(29000, function()
      Effectcreate("war3mapImported\\[ake]war3ake.com - 7346841038772226188179609.mdx", x, y - 100, 5)
      PlayBGM({
        bgm = BOSS_Zhenhong_Start7,
        time = 300,
        ID = 0
      })
      songtext({
        text = {
          {
            starttime = 33.45,
            str = "被封闭的这份记忆"
          },
          {
            starttime = 41.32,
            str = "为了确认它而与你紧紧相连"
          },
          {
            starttime = 49.18,
            str = "新刻下的"
          },
          {
            starttime = 53.67,
            str = "未来和过去的瞬间"
          },
          {
            starttime = 57.82,
            str = "此时与你一起见证"
          },
          {
            starttime = 63.38,
            str = "永远无法忘记，和你定下的约定"
          },
          {
            starttime = 71.99,
            str = "如今在这个世界也依然五彩斑斓"
          },
          {
            starttime = 86.34,
            str = "奇迹已出现在眼前"
          },
          {
            starttime = 94.47,
            str = "因为再次和你想见"
          },
          {
            starttime = 102.66,
            str = "我把梦想寄托在空中飞舞的羽毛上"
          },
          {
            starttime = 110.52,
            str = "让只属于我们的真理"
          },
          {
            starttime = 114.74,
            str = "能飞往世界的每一个角落"
          },
          {
            starttime = 123.43,
            str = "拥抱着依然闪耀的羁绊",
            time = 10
          },
          {
            starttime = 166.47,
            str = "如果能成为你继续前进的理由"
          },
          {
            starttime = 174.56,
            str = "那我就会一直坚持"
          },
          {
            starttime = 188.9,
            str = "奇迹永远在你身旁"
          },
          {
            starttime = 197.02,
            str = "我们开始握起彼此的手"
          },
          {
            starttime = 205.18,
            str = "抬头仰望天上飞舞的羽毛时"
          },
          {
            starttime = 213.31,
            str = "追寻这让内心鼓动的真理"
          },
          {
            starttime = 217.4,
            str = "无论在哪，只要是和你一起"
          },
          {
            starttime = 225.47,
            str = "我就不会迷失在黑暗中能够继续前进",
            time = 10
          },
          {
            starttime = 267.1,
            str = "还在继续前进的真理"
          },
          {
            starttime = 271.03,
            str = "无论什么时候，想再见你一次"
          },
          {
            starttime = 279.25,
            str = "我的一切所求，只是向着这个愿望"
          },
          {
            starttime = 286.8,
            str = "前进",
            time = 8.2
          }
        },
        color = {"FFFF0000", "FFFFFF33"},
        isjbcolor = true
      })
      local tm = 255
      ac.timer(50, 90, function()
        tm = tm - 2.5
        qk:setcolor(255, 255, 255, tm)
      end)
      ac.wait(5000, function()
        qk:remove()
      end)
    end)
    SendDtimeMsgAll(34, "|cFFFF9933二阶堂真红缓缓地看向了你们", 10)
    if Nandu_Choose >= 5 then
      SendDtimeMsgAll(37, "|cFFFF9933二阶堂真红：|r|cFFFF9933谢谢你们....现在我得回去了，回去那个一切的起源之地，亲手结束这段痛苦的故事|r", 10)
      SendDtimeMsgAll(40, "|cFFFF9933二阶堂真红：|r|cFFFF9933真的……谢谢你们……|r", 10)
      SendDtimeMsgAll(43, "|cFFFF9933二阶堂真红：|r|cFFFF9933再会了……不知名的勇者们|r", 10)
      ac.wait(43000, function()
        flashphoto({
          photo = "Ph_Zhenhong_03E2.tga",
          timeout = 3,
          timehold = 3,
          timein = 3
        })
      end)
    else
      SendDtimeMsgAll(37, "|cFFFF9933二阶堂真红：|r|cFFFF9933谢谢你们……是你们唤醒了我|r", 10)
      SendDtimeMsgAll(40, "|cFFFF9933二阶堂真红：|r|cFFFF9933真的……谢谢你们……|r", 10)
      SendDtimeMsgAll(43, "|cFFFF9933二阶堂真红：|r|cFFFF9933再会了……不知名的勇者们|r", 10)
    end
  end)
  ac.wait(228000, function()
    ForGroupLuaNew(u:getdata("刻印组"), function(xq)
      local fx = 3
      local cs2 = 100
      local jl = 1100
      ac.loop(30, function(timer)
        cs2 = cs2 - 1
        jl = jl - 11
        local jd = AngleBetweenUnits(xq.handle, u.handle)
        local dx, dy = PolarXY(x, y, jl, jd + fx)
        xq:setxy(dx, dy)
        if cs2 <= 0 then
          xq:remove()
          timer:remove()
        end
      end)
    end)
    ac.wait(3000, function()
      Effectcreate("war3mapImported\\Texiao_chengxizhiguang1.mdx", x, y, 0, 30)
      PlayGlobalSound(BOSS_Zhenhong_Jiguang3)
    end)
    PlayGlobalSound(BOSS_Zhenhong_Shijiezhihuan)
    local tx = u:getdata("世界之环")
    local tx2 = u:getdata("世界的尽头特效")
    tx:animespeed(6)
    local acs = 0
    local bs = 6.25
    local bs2 = 7.3
    local dcs = 0
    ac.loop(10, function(timer)
      dcs = dcs + 1
      acs = acs + 1
      bs = bs - 0.02
      bs2 = bs2 - 0.024
      if dcs == 10 then
        dcs = 0
        ForGroupLuaNew(Group_PlayHero, function(xq)
          xq:shockcamera(acs / 5, 0.1)
        end)
      end
      tx:setsize(bs)
      SetEffectSize(tx2, bs2)
      if 300 <= acs then
        tx:animespeed(1)
        CinematicFadeBJ(bj_CINEFADETYPE_FADEOUTIN, 0.2, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 100.0, 0, 0, 0.0)
        PlayGlobalSound(BOSS_Zhenhong_Baozha1)
        Effectcreate("war3mapImported\\Texiao_chengxizhiguang1.mdx", x, y, 0, 60)
        tx:remove()
        DestroyEffectLua(tx2)
        ExtraBattle = false
        BossBattle = false
        ExBossBattle = false
        FogEnable(true)
        FogMaskEnable(true)
        u:setdata("第三阶段完结")
        ForGroupLuaNew(Group_PlayHero, function(xq)
          xq:adddivinity(xq:getdata("神性保存值"))
          DestroyEffectLua(xq:getdata("青空之翼特效"))
          xq:deldata("青空之翼特效")
          xq:deldata("青空之翼")
          xq:deldata("青空之翼增伤")
          xq:deldata("青空之翼基础增伤")
          xq:deldata("青空之翼叠加增伤")
          HeroRelive(xq.handle, x, y, 3)
        end)
        Nofail_Biaoji = false
        if not u:hasdata("真红-三阶段击败者") then
          u:setdata("真红-三阶段击败者", Group_Randomunit(Group_PlayHero))
        end
        bossdeath(u.handle, u:getdata("真红-三阶段击败者"))
        ac.wait(10, function()
          ShowUnit(u.handle, false)
        end)
        ac.wait(3000, function()
          local npc = getunit(NPC_ZHENHONG)
          ShowUnit(npc.handle, true)
          npc:setface(350)
          npc:setxy(-11175, 17000)
          PlayGlobalSound(BOSS_Zhenhong_Chuansong)
          japi.SetUnitName(npc.handle, "|cFFFF0000二|r|cFFFF2A00阶|r|cFFFF5500堂|r|cFFFF8000真|r|cFFFFAA00红|r")
          npc:setdata("模型-名字", "|cFFFF0000二|r|cFFFF2A00阶|r|cFFFF5500堂|r|cFFFF8000真|r|cFFFFAA00红|r")
          local ax, ay = npc:getxy()
          Effectcreate("war3mapImported\\Texiao_zhenhongchuansong1.mdx", x, y)
        end)
        ac.wait(10000, function()
          Boolean_ZhenhongBattle = false
          u:remove()
        end)
        timer:remove()
      end
    end)
  end)
end

function zhenhong_2_start(u)
  if u:hasdata("第二阶段结束") then
    return
  end
  if (u:getperhp() <= 10 or u:hasdata("次元闭锁已开启")) and not u:hasdata("次元闭锁触发") then
    u:setdata("次元闭锁触发")
    ZhenhongSkill["次元闭锁"](u)
    return
  end
  if u:hasdata("次元闭锁触发") then
    return
  end
  if u:getdata("技能循环") >= 3 then
    u:setdata("技能循环", 1)
  else
    u:changedata("技能循环", 1)
  end
  local xh = u:getdata("技能循环")
  if xh == 1 then
    ZhenhongSkill["世界之风"](u)
  end
  if xh == 2 then
    ZhenhongSkill["晨曦之光"](u)
  end
  if xh == 3 then
    ZhenhongSkill["祟神之影"](u)
  end
end

function zhenhong_2_end(u)
  local dx = -5000
  local dy = 12089
  SetUnitOwner(u.handle, Player(PLAYER_NEUTRAL_PASSIVE), false)
  local npc = getunit(NPC_Molijiedian)
  ShowUnit(npc.handle, true)
  local a = GetRandomAngle()
  ac.loop(30, function(timer)
    a = a + 0.1
    local ax, ay = PolarXY(dx, dy, 1300, a)
    npc:setxy(ax, ay)
    if u:hasdata("第三阶段结束") then
      npc:setxy(dx, dy)
      npc:setflyheight(600)
      timer:remove()
    end
  end)
  SendMsgAll("|cFF9999FF神化位获取|r")
  ForGroupLuaNew(Group_PlayHero, function(xq)
    local sy = xq.ownerid
    ChangeValue(Hero_Shenhua_Left, sy, 1)
  end)
  ChangeBGM(BOSS_Zhenhong_Start5)
  ExtraBattle = false
  BossBattle = false
  ExBossBattle = false
  FogEnable(true)
  FogMaskEnable(true)
  u:sethp(10, true)
  u:deldata("次元闭锁启动")
  u:setdata("第二阶段结束")
  u:setdata("真红永恒")
  u:deldata("真红-世界之羽")
  u:deldata("世界之羽累积伤害")
  if not u:hasdata("真红-二阶段击败者") then
    u:setdata("真红-二阶段击败者", Group_Randomunit(Group_PlayHero))
  end
  u:setdata("真红阶段结束标记")
  bossdeath(u.handle, u:getdata("真红-二阶段击败者"))
  u:setdata("伤害统计-来自玩家累积伤害", 0)
  for i = 1, 6 do
    u:setdata("伤害统计-来自玩家累积伤害" .. i, 0)
  end
  u:setdata("锁定时间", 0)
  PlayGlobalSound(BOSS_Zhenhong_Chuansong)
  local x, y = u:getxy()
  Effectcreate("war3mapImported\\Texiao_zhenhongchuansong1.mdx", x, y)
  ResetUnitAnimation(u.handle)
  ac.wait(500, function()
    u:setxy(dx, dy)
    u:buffset(u.handle, 3600, "锁定")
    u:setface(270)
    Effectcreate("war3mapImported\\Texiao_zhenhongchuansong1.mdx", dx, dy)
    ac.wait(2000, function()
      u:addskill("A00N")
    end)
  end)
  SendMsgAll("|cFF1BE6B8现在可以去各个NPC处寻求帮助|r", 10)
  ac.wait(3000, function()
    SendDtimeMsgAll(10, "|cFFFFFF33幸福|r", 60)
    SendDtimeMsgAll(20, "|cFFFFFF33梦想|r", 60)
    SendDtimeMsgAll(30, "|cFFFFFF33纯白|r", 60)
    SendDtimeMsgAll(40, "|cFFFFFF33希望|r", 60)
    SendDtimeMsgAll(50, "|cFFFFFF33幻想|r", 60)
    SendDtimeMsgAll(60, "|cFFFFFF33无垠|r", 60)
    SendDtimeMsgAll(70, "|cFF990000痛苦|r", 60)
    SendDtimeMsgAll(80, "|cFF990000噩梦|r", 60)
    SendDtimeMsgAll(90, "|cFF990000虚无|r", 60)
    SendDtimeMsgAll(100, "|cFF990000苦难|r", 60)
    SendDtimeMsgAll(110, "|cFF990000绝望|r", 60)
    SendDtimeMsgAll(120, "|cFF990000灾厄|r", 60)
    SendDtimeMsgAll(125, "|cFF990000尘世中一切美好与厄运皆汇聚于此|r", 60)
    ac.wait(130000, function()
      if Nandu_Choose >= 5 then
        flashphoto({
          photo = "Ph_Zhenhong_02E.tga",
          timeout = 5,
          timehold = 3,
          timein = 3
        })
        ForGroupLuaNew(Group_PlayHero, function(xq)
          xq:buffset(u.handle, 12, "绝对闪避")
        end)
        SendDtimeMsgAll(0, "|cFFFF9933二阶堂真红：|r|cFF990000我为什么要这么做呢....|r", 60)
        SendDtimeMsgAll(5, "|cFFFF9933二阶堂真红：|r|cFF990000我不知道|r", 60)
        SendDtimeMsgAll(10, "|cFFFF9933二阶堂真红：|r|cFF990000夺取了世界的权能...现在我得到了一切，但我所有的一切却早已离我而去|r", 60)
        SendDtimeMsgAll(15, "|cFFFF9933二阶堂真红：|r|cFF990000我已经身不由己了..|r", 60)
        SendDtimeMsgAll(20, "|cFFFF9933二阶堂真红：|r|cFF990000好孤单..好痛苦..救救我...|r", 60)
      end
    end)
  end)
  ac.wait(3000, function()
    local g = CreateGroupLua()
    u:setdata("时间与空间的刻印", g)
    local tx = Effectcreate("war3mapImported\\Texiao_heihongwuqi.mdx", dx, dy, -1, 0.01, 1)
    u:setdata("时间与空间的刻印特效", tx)
    local cs1 = 0
    local size = 0.01
    ac.loop(100, function(timer)
      cs1 = cs1 + 1
      if cs1 <= 100 then
        size = size + 0.007
      else
        size = size + 0.002
      end
      SetEffectSize(tx, size)
      if 1000 <= cs1 then
        timer:remove()
      end
    end)
    local cs = 0
    local jd = 90
    local jl = 500
    ac.loop(10000, function(timer)
      cs = cs + 1
      local ax, ay = PolarXY(dx, dy, jl, jd)
      jd = jd + 30
      jl = jl + 50
      local mj = u:createunit("u0DF", ax, ay)
      mj:setdata("刻印计数", cs)
      mj:groupadd(g)
      PlayGlobalSound(BOSS_Zhenhong_Zhongsheng2)
      if 12 <= cs then
        timer:remove()
      end
    end)
    ac.wait(10000, function()
      local jl2 = 500
      ac.loop(100, function(timer)
        jl2 = jl2 + 0.5
        ForGroupLuaNew(g, function(xq)
          local ajd = AngleBetweenUnits(u.handle, xq.handle)
          local ax, ay = PolarXY(dx, dy, jl2, ajd)
          xq:setxy(ax, ay)
        end)
        if 1100 <= jl2 then
          timer:remove()
        end
      end)
    end)
  end)
  u:setdata("真红-任务完成数", 0)
  ac.loop(250, function(timer)
    ForGroupLuaNew(Group_PlayHero, function(xq)
      if not u:hasdata("天子任务开启") and IsUnitInRange(xq.handle, NPC_TIANZI, 500.0) then
        u:setdata("天子任务开启")
        local npc2 = getunit(NPC_TIANZI)
        npc2:setdata("真红-任务中", u)
        SendMsgAll("|cFF6699FF天人|r哟~需不需要我的帮助啊，只要达成了我的条件，我就会帮你压制住这破地方的天气哦", 30)
        SendMsgAll("【在十一波至少触发不同6个环境则达成条件】", 30)
        ac.loop(100, function(timer2)
          if u:getdata("天子环境切换个数") >= 6 then
            SendMsgAll("|cFF6699FF天人|r好嘞~按照约定，我会帮你们压制住这里的鬼天气，放心吧~", 30)
            SendMsgAll("|cff00ff00【环境影响消失】|r", 30)
            ForGroupLuaNew(Group_PlayHero, function(xq2)
              xq2:setdata("天子帮助")
            end)
            u:changedata("真红-任务完成数", 1)
            npc2:deldata("真红-任务中")
            timer2:remove()
          end
          if u:hasdata("第三阶段开始") then
            npc2:deldata("真红-任务中")
            timer2:remove()
          end
        end)
      end
      if not u:hasdata("两仪式任务开启") and IsUnitInRange(xq.handle, NPC_LIANGYISHI, 500.0) then
        u:setdata("两仪式任务开启")
        SendMsgAll("|cffe6a5f5两仪式：|r我也想帮助你们...不过，我的九字兼定丢失了，如果你们能帮我找回，我就有办法帮你们削弱她的力量", 30)
        SendMsgAll("【将九字兼定交予根源式】", 30)
        ac.loop(100, function(timer2)
          ForGroupLuaNew(Group_PlayHero, function(xq2)
            if (xq2:ishasitem("I03O") or xq2:ishasitem("I03N")) and IsUnitInRange(xq2.handle, NPC_LIANGYISHI, 500.0) then
              xq2:removeitem("I03O")
              xq2:removeitem("I03N")
              SendMsgAll("|cffe6a5f5两仪式：|r啊...你们找到了，我会按照约定，尽力帮助你们对抗她", 30)
              SendMsgAll("|cff00ff00【真红失去时间与空间的刻印时，无敌时间减少一半】|r", 30)
              u:setdata("两仪式帮助")
              u:changedata("真红-任务完成数", 1)
              timer2:remove()
            end
          end)
          if u:hasdata("第三阶段开始") then
            timer2:remove()
          end
        end)
      end
      if not u:hasdata("八云紫任务开启") and IsUnitInRange(xq.handle, NPC_BAYUNZI, 500.0) then
        u:setdata("八云紫任务开启")
        SendMsgAll("|cFFCC99FF八云紫：|r二阶堂真红的力量过于强大，我研究了很久，通过我的结界，可以削弱一点她的力量，但是以我的能力释放这个结界需要耗费巨大魔力，让我积攒一下魔力来释放结界", 30)
        SendMsgAll("【带给八云紫15个魔力石构筑结界】", 30)
        ac.loop(100, function(timer2)
          ForGroupLuaNew(Group_PlayHero, function(xq2)
            if xq2:ishasitem("I09D") and IsUnitInRange(xq2.handle, NPC_BAYUNZI, 500.0) then
              local item = xq2:getitem("I09D")
              if GetItemCharges(item) >= 15 then
                ChangeItemCount(item, -15)
                SendMsgAll("|cFFCC99FF八云紫：|r呼....结界已经构建完成，这样就能压制住她少许力量了，接下来就靠你们了", 30)
                SendMsgAll("|cff00ff00【离开[世界的尽头]生命上限降低效果减少50%】|r", 30)
                u:setdata("八云紫帮助")
                u:changedata("真红-任务完成数", 1)
                timer2:remove()
              end
            end
          end)
          if u:hasdata("第三阶段开始") then
            timer2:remove()
          end
        end)
      end
      if not u:hasdata("伊甸任务开启") and IsUnitInRange(xq.handle, NPC_YIDIAN, 500.0) then
        u:setdata("伊甸任务开启")
        SendMsgAll("|cFFFF6633伊|r|cFFFF9922甸：|r~~~~沙沙声（充足的资源也是战斗胜利的关键，你们尽量寻找一些消耗品，或许对你们战斗有所帮助）", 30)
        SendMsgAll("【开启[50*存活人数]个补给箱】", 30)
        u:setdata("补给箱开启个数", 0)
        local npc2 = getunit(NPC_YIDIAN)
        npc2:setdata("真红-任务中", u)
        ac.loop(100, function(timer2)
          if u:getdata("补给箱开启个数") >= 50 * Group_Counts(Group_Xingcunzu) then
            SendMsgAll("|cFFFF6633伊|r|cFFFF9922甸：|r~~~~沙沙声（这种力量能够在绝地之中有一线生机，带着吧）", 30)
            SendMsgAll("|cff00ff00【玩家被世界的尽头影响程度减少，恢复50%回血效果】|r", 30)
            u:setdata("伊甸帮助")
            u:changedata("真红-任务完成数", 1)
            npc2:deldata("真红-任务中")
            timer2:remove()
          end
          if u:hasdata("第三阶段开始") then
            npc2:deldata("真红-任务中")
            timer2:remove()
          end
        end)
      end
      if not u:hasdata("阿比盖尔任务开启") and IsUnitInRange(xq.handle, NPC_Abi, 500.0) then
        u:setdata("阿比盖尔任务开启")
        SendMsgAll("|cff008080卖火柴的小女孩：|r阿比...也想帮助大家..那个，如果能找回一些我的力量，我就能和它们沟通..", 30)
        SendMsgAll("【玩家外域变异总和达到[3*玩家人数]个】", 30)
        ac.loop(100, function(timer2)
          local sl = 0
          ForGroupLuaNew(Group_PlayHero, function(xq2)
            sl = sl + xq2:getdata("外域变异数量")
          end)
          if sl >= 3 * Group_Counts(Group_PlayHero) then
            SendMsgAll("|cff008080卖火柴的小女孩：|r啊...！我感受到它们了..这样我就能帮助大家了", 30)
            SendMsgAll("|cff00ff00【玩家被世界的尽头影响程度减少，恢复50%神性】|r", 30)
            u:setdata("阿比盖尔帮助")
            u:changedata("真红-任务完成数", 1)
            timer2:remove()
          end
          if u:hasdata("第三阶段开始") then
            timer2:remove()
          end
        end)
      end
      if not u:hasdata("阎魔爱任务开启") and IsUnitInRange(xq.handle, NPC_XIAOAI, 500.0) then
        u:setdata("阎魔爱任务开启")
        SendMsgAll("|cff993300小爱：|r唔...如果你们能给我找来一些深渊怪物的灵魂，我倒是可以用来帮助你们", 30)
        SendMsgAll("【击杀[4*游戏人数]个深渊怪】", 30)
        local npc2 = getunit(NPC_XIAOAI)
        npc2:setdata("真红-任务中", u)
        ac.loop(100, function(timer2)
          if u:getdata("击杀深渊怪数") >= 4 * Group_Counts(Group_PlayHero) then
            SendMsgAll("|cff993300小爱：|r好的...这些深渊能量能对她起到一些克制作用，拿好", 30)
            SendMsgAll("|cff00ff00【玩家被世界的尽头影响程度减少，恢复玩家50%生命损耗伤害】|r", 30)
            u:setdata("小爱帮助")
            u:changedata("真红-任务完成数", 1)
            npc2:deldata("真红-任务中")
            timer2:remove()
          end
          if u:hasdata("第三阶段开始") then
            npc2:deldata("真红-任务中")
            timer2:remove()
          end
        end)
      end
      if not u:hasdata("千子村正任务开启") and IsUnitInRange(xq.handle, NPC_CUNZHENG, 500.0) then
        u:setdata("千子村正任务开启")
        SendMsgAll("|cffff9900桑名的刀匠：|r哦！要决战了吗？大家都很有干劲呢，那我也来帮你们一把吧，战场上武器是最重要的，我来为你们打造武器", 30)
        SendMsgAll("【在千子村正处打造成功五件装备】", 30)
        local npc2 = getunit(NPC_CUNZHENG)
        npc2:setdata("真红-任务中", u)
        ac.loop(100, function(timer2)
          if u:getdata("千子村正打造武器次数") >= 5 then
            SendMsgAll("|cffff9900桑名的刀匠：|r嗯..！你们的武器我都给你们打磨好了，要平安回来哦！", 30)
            SendMsgAll("|cff00ff00【玩家被世界的尽头影响程度减少，伤害等级不再下降】|r", 30)
            u:setdata("千子村正帮助")
            u:changedata("真红-任务完成数", 1)
            npc2:deldata("真红-任务中")
            timer2:remove()
          end
          if u:hasdata("第三阶段开始") then
            npc2:deldata("真红-任务中")
            timer2:remove()
          end
        end)
      end
      if not u:hasdata("忍者任务开启") and IsUnitInRange(xq.handle, NPC_MOZI, 500.0) then
        u:setdata("忍者任务开启")
        SendMsgAll("|cffc0c0c0忍者：|r听说要进行决战了，战斗过程中速度可是取胜的关键哦，抓紧提升自己的身体灵巧度吧", 30)
        SendMsgAll("【玩家额外移速总和大于[250*游戏人数]】", 30)
        ac.loop(100, function(timer2)
          local ewys = 0
          ForGroupLuaNew(Group_PlayHero, function(xq2)
            ewys = ewys + xq2:getdata("当前额外移速")
          end)
          if ewys >= 250 * Group_Counts(Group_PlayHero) then
            SendMsgAll("|cffc0c0c0忍者：|r听说要进行决战了，战斗过程中速度可是取胜的关键哦，抓紧提升自己的身体灵巧度吧", 30)
            SendMsgAll("|cff00ff00【玩家被世界的尽头影响程度减少，恢复50%额外移速】|r", 30)
            u:setdata("忍者帮助")
            u:changedata("真红-任务完成数", 1)
            timer2:remove()
          end
          if u:hasdata("第三阶段开始") then
            timer2:remove()
          end
        end)
      end
    end)
    if u:hasdata("第三阶段开始") then
      timer:remove()
    end
  end)
  ac.loop(1000, function(timer)
    if u:hasdata("真红-三阶段开始判定") and not u:hasdata("真红-三阶段已经开始") then
      u:setdata("真红-三阶段已经开始")
      u:setmaxhp(21000000000)
      u:sethp(100, true)
      u:setface(270)
      u:setdata("神性", 51)
      u:deldata("真红阶段结束标记")
      FogEnable(false)
      FogMaskEnable(false)
      BOSS = u.handle
      Movie_Boolean = true
      local cs = 0
      ac.loop(1000, function(timer2)
        cs = cs + 1
        Movie_Boolean = true
        if cs == 40 then
          Movie_Boolean = false
          timer2:remove()
        end
      end)
      local waittime = 0
      if Nandu_Choose >= 5 then
        waittime = 8
        flashphoto({
          photo = "Ph_Zhenhong_03S.tga",
          timeout = 2,
          timehold = 2,
          timein = 2
        })
        SendDtimeMsgAll(0, "|cFFFF9933二阶堂真红|r静静地漂在空中", 10)
        SendDtimeMsgAll(5, "|cFFFF9933二阶堂真红：|r|cFF990000.........|r", 10)
      end
      ac.wait(waittime * 1000, function()
        SendDtimeMsgAll(0, "|cFFFF9933二阶堂青空：|r|cFF66FFCC妈妈！！！|r", 10)
        SendDtimeMsgAll(3, "|cFFFF9933二阶堂真红：|r|cFF990000这道声音是....呃....快走吧，我控制不住了...|r", 10)
        SendDtimeMsgAll(6, "|cFFFF9933二阶堂青空：|r|cFF66FFCC妈妈...不要放弃希望...！|r", 10)
        SendDtimeMsgAll(9, "|cFFFF9933二阶堂真红：|r|cFF990000.........|r", 10)
        SendDtimeMsgAll(12, "|cFFFF9933二阶堂青空：|r|cFF990000|cFF66FFCC呜呜...大家，请帮帮我吧..帮我救救妈妈...|r", 10)
        SendDtimeMsgAll(15, "|cFF990000二阶堂真红：哼……你们都将会消逝在此|r", 10)
        SendDtimeMsgAll(20, "|cFF990000二阶堂真红：想夺回二阶堂真红？真是愚蠢……|r", 10)
        SendDtimeMsgAll(23, "|cFFFFFF33一缕温暖的光芒，钻进了你们的心中|r", 10)
        SendDtimeMsgAll(26, "|cFFFF9933二阶堂青空：|r|cFF66FFCC这是，我和魔法师留下最后一丝的力量..拜托了，请救救妈妈...！|r", 10)
        SendDtimeMsgAll(32, "|cFF00CCFF众人：|r|cFFFFFF00放心吧，相信我们，我们一定会救回真红！|r", 10)
        SendDtimeMsgAll(35, "|cFFFF9933你获得了二阶堂青空与二阶堂蓝赋予的守护之力|r", 10)
        SendDtimeMsgAll(35, "|cFF66FFCC每次直接伤害时削弱真红的意志，对真红的固定伤害提升(无衰减 触发冷却0.5秒)，每隔30秒，这份力量会被真红重新压制归零|r", 10)
        ac.wait(23000, function()
          CinematicFadeBJ(bj_CINEFADETYPE_FADEOUTIN, 5.0, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 100.0, 100.0, 0.0)
        end)
        ac.wait(26000, function()
          ForGroupLuaNew(Group_PlayHero, function(xq)
            xq:setdata("青空之翼特效", xq:effectadd("war3mapImported\\Texiao_chibang1.mdx", "chest", -1))
            xq:setdata("青空之翼")
            xq:setdata("青空之翼增伤", 0)
            xq:setdata("青空之翼叠加层数", 0)
          end)
          AddAllSTexiao("BOSS-真红", "直接伤害特效", function(args)
            local tg = args.tg
            local u = args.u
            local info = args.damageinfo
            if u:hasdata("青空之翼") and tg:hasdata("BOSS-真红") and not u:hasdata("青空之翼叠加冷却") then
              u:settimedata("青空之翼叠加冷却", 0.5)
              u:changedata("青空之翼增伤", u:getdata("青空之翼叠加增伤"))
              u:changedata("青空之翼叠加层数", 1)
            end
          end)
        end)
        ac.wait(30000, function()
          ChangeBGM(BOSS_Zhenhong_Start4)
          local zs = 0
          ac.loop(3000, function(timer3)
            zs = zs + 1
            PlayGlobalSound(BOSS_Zhenhong_Zhongsheng2)
            if 12 <= zs then
              timer3:remove()
            end
          end)
        end)
        ac.wait(35000, function()
          u:setdata("伤害统计-分钟数", Time_M)
          u:setdata("伤害统计-秒钟数", Time_S)
          u:setdata("真红-BOSS阶段", 3)
          u:setdata("第三阶段开始")
          CameraSetupApplyForceDuration(Glo.gg_cam_Camera_008, true, 0)
          SetCameraTargetController(u.handle, 0, 0, false)
          PlayGlobalSound(BOSS_Zhenhong_Zhongsheng1)
          ac.loop(1000, function(timer2)
            u:animespeed(1)
            u:setdata("锁定时间", 0)
            u:setxy(dx, dy)
            u:buffset(u.handle, 3600, "锁定")
            if u:hasdata("第三阶段完结") then
              timer2:remove()
            end
          end)
          ForGroupLuaNew(Group_PlayHero, function(xq)
            local sy = xq.ownerid
            local down = u:getshenxing()
            if u:hasdata("阿比盖尔帮助") then
              down = down * 0.5
            end
            down = math.floor(down)
            xq:setdata("真红-神性下降值", down)
            xq:adddivinity(-down)
            xq:setdata("青空之翼基础增伤", 5000000 * (1 + u:getdata("真红-任务完成数")))
            xq:setdata("青空之翼叠加增伤", 500000 * (1 + u:getdata("真红-任务完成数")))
          end)
          ac.wait(2000, function()
            ac.loop(1000, function(timer2)
              ForGroupLuaNew(Group_PlayHero, function(xq)
                if xq:getmaxhp() < 100 then
                  shanmopanding(xq)
                end
              end)
              if u:hasdata("真红-金色翎羽") then
                timer2:remove()
              end
            end)
            ac.wait(1000, function()
              local a1 = 100
              if u:hasdata("阿比盖尔帮助") then
                a1 = 50
              end
              local a2 = 100
              if u:hasdata("伊甸帮助") then
                a2 = 50
              end
              local a3 = 100
              if u:hasdata("忍者帮助") then
                a3 = 50
              end
              local a4 = 0.1
              local a5 = 500
              if Nandu_Choose >= 5 then
                a4 = 0.25
                a5 = 1500
              end
              local atext = "|cFFFF0000世|r|cFFFF2A1A界|r|cFFFF5533的|r|cFFFF804C尽|r|cFFFFAA66头|r\n|cFFFF2A1A离开世界的尽头时,每秒极速降低生命上限\n受到来自世界的意志伤害时,降低[" .. string.format("%.1f", a4) .. "%+" .. a5 .. "]基础生命上限|r\n|cFFFF5533降低" .. a1 .. "%神性|r\n|cFFFF804C降低" .. a2 .. "%生命恢复效果|r\n|cFFFFAA66降低" .. a3 .. "%额外移速|r"
              BuffUI.register("世界的尽头", {
                image = "Buff_Zhenhong_Shijiedejintou.blp",
                on_enter = function(self)
                  local text = atext
                  uiy_show_text_and_image(text, self.normal_image, "Buff")
                end,
                on_leave = function(self)
                  uiy_hide()
                end,
                show_time = false
              })
              BuffUI.apply({
                id = "世界的尽头",
                duration = 99999
              })
              SendMsgAll("|cFFCC0000神迹.世界的尽头|r")
              PlayGlobalSound(BOSS_Zhenhong_Shijiezhihuan)
              u:effectadd("war3mapImported\\44.mdx", "origin", -1)
              local tx = Effectcreate("war3mapImported\\Texiao_zhianzhiyu.mdx", dx, dy, -1, 0.1, -10, 0, 0, 0, 6)
              local cs2 = 0
              local bs = 0.1
              local bs2 = 0.25
              local tx2 = u:getdata("世界之环")
              tx2:animespeed(6)
              u:setdata("世界的尽头特效", tx)
              ac.loop(30, function(timer2)
                cs2 = cs2 + 1
                bs = bs + 0.072
                bs2 = bs2 + 0.06
                SetEffectSize(tx, bs)
                tx2:setsize(bs2)
                if 100 < cs2 then
                  tx2:animespeed(0.25)
                  SetEffectActSpeed(tx, 1)
                  DestroyEffectLua(u:getdata("时间与空间的刻印特效"))
                  u:deldata("时间与空间的刻印特效")
                  u:setdata("刻印组", CreateGroupLua())
                  u:setdata("刻印组2", CreateGroupLua())
                  local dcs = 0
                  ac.loop(200, function(timer4)
                    dcs = dcs + 1
                    PlayGlobalSound(BOSS_Zhenhong_Keyin1)
                    ForGroupLuaNew(u:getdata("时间与空间的刻印"), function(xq)
                      if xq:getdata("刻印计数") == dcs then
                        xq:groupremove(u:getdata("时间与空间的刻印"))
                        ShowUnit(xq.handle, false)
                        xq:timetoremove()
                        local cx, cy = xq:getxy()
                        Effectcreate("war3mapImported\\Texiao_chengxizhiguang1.mdx", cx, cy, 0, 5)
                        local mj = u:createunit("u0DG", cx, cy)
                        mj:setdata("刻印位置X", cx)
                        mj:setdata("刻印位置Y", cy)
                        mj:groupadd(u:getdata("刻印组"))
                        mj:groupadd(u:getdata("刻印组2"))
                      end
                    end)
                    if 12 <= dcs then
                      u:setdata("时间与空间的刻印个数", 12)
                      u:setdata("技能循环", 0)
                      u:setdata("永恒之轮")
                      local dt = 180
                      if u:hasdata("两仪式帮助") then
                        dt = 90
                      end
                      BuffUI.apply({
                        id = "永恒之轮",
                        duration = dt
                      })
                      ZhenhongSkill["法则轮转"](u)
                      ForGroupLuaNew(Group_PlayHero, function(xq)
                        local sy = xq.ownerid
                        ResetToGameCameraForPlayer(xq.owner, 0)
                        local p = getplayer(xq.owner)
                        p:setcameraheight(Cam_height[xq.ownerid], 0)
                      end)
                      local cs3 = 0
                      ac.loop(1000, function(timer5)
                        cs3 = cs3 + 1
                        if 90 <= cs3 and u:hasdata("两仪式帮助") then
                          u:deldata("永恒之轮")
                          SendMsgAll("|cFFFFFF66『|r|cFFFFE35B永|r|cFFFFC64F恒|r|cFFFFAA44之|r|cFFFF8E39轮|r|cFFFF712D消|r|cFFFF5522散|r|cFFFF3917』|r")
                          timer5:remove()
                        end
                        if 180 <= cs3 then
                          u:deldata("永恒之轮")
                          SendMsgAll("|cFFFFFF66『|r|cFFFFE35B永|r|cFFFFC64F恒|r|cFFFFAA44之|r|cFFFF8E39轮|r|cFFFF712D消|r|cFFFF5522散|r|cFFFF3917』|r")
                          timer5:remove()
                        end
                      end)
                      ac.wait(6000, function()
                        u:delskill("A00N")
                        u:deldata("真红永恒")
                        SetUnitOwner(u.handle, Player(9), false)
                        zhenhong_3_start(u)
                      end)
                      timer4:remove()
                    end
                  end)
                  timer2:remove()
                end
              end)
            end)
          end)
        end)
      end)
      timer:remove()
    end
  end)
end

function zhenhong_1_start(u)
  if u:hasdata("第一阶段结束") then
    return
  end
  if u:getpermp() >= 100 then
    u:setmp(0)
    ZhenhongSkill["纯白之羽"](u)
    return
  end
  if u:getdata("技能循环") >= 1 then
    u:setdata("技能循环", 1)
  else
    u:changedata("技能循环", 1)
  end
  ac.wait(100, function()
    if u:getdata("技能循环") == 1 then
      ZhenhongSkill["神罚"](u)
    end
  end)
end

function zhenhong_1_end(u)
  if u:hasdata("真红-一阶段击败判定") then
    return
  else
    u:setdata("真红-一阶段击败判定")
  end
  SetUnitOwner(u.handle, Player(PLAYER_NEUTRAL_PASSIVE), false)
  ExtraBattle = false
  BossBattle = false
  ExBossBattle = false
  FogEnable(true)
  FogMaskEnable(true)
  u:setdata("真红阶段结束标记")
  bossdeath(u.handle, u:getdata("真红-一阶段击败者"))
  u:setdata("伤害统计-来自玩家累积伤害", 0)
  for i = 1, 6 do
    u:setdata("伤害统计-来自玩家累积伤害" .. i, 0)
  end
  u:setface(270)
  if ModeSelect_Infinite and Boolean_ZhenhongBiding then
  else
    SendMsgAll("|cFF9999FF神化位获取|r")
    ForGroupLuaNew(Group_PlayHero, function(xq)
      local sy = xq.ownerid
      ChangeValue(Hero_Shenhua_Left, sy, 1)
    end)
  end
  local g = CreateGroupLua()
  ForGroupLuaNew(u:getdata("世界之门组"), function(xq)
    xq:groupadd(g)
    xq:clearbuff("锁定")
    xq:groupremove(Group_Monster)
  end)
  local x, y = u:getxy()
  local a = 135
  ac.timer(1000, 4, function()
    a = a + 90
    local mj = FirstOfGroupLua(g)
    mj:clearbuff("锁定")
    mj:groupremove(g)
    PlayGlobalSound(BOSS_Zhenhong_Keyin2)
    local x2, y2 = PolarXY(x, y, 1000, a)
    EffectcreateArgs({
      effect = "war3mapImported\\Texiao_chengxizhiguang1.mdx",
      x = x2,
      y = y2,
      size = 10
    })
    mj:setxy(x2, y2)
    local djd = a + 180
    ac.loop(1000, function(timer)
      local tx = EffectcreateArgs({
        effect = "war3mapImported\\Texiao_baiyu.mdl",
        x = x2,
        y = y2,
        time = 2,
        size = 0.5,
        height = 100,
        zxz = djd
      })
      EffectShowAll(tx)
      effectmove({
        effect = tx,
        time = 2,
        distance = 1000,
        angle = djd,
        endfunc = function()
          u:sethp(u:getperhp() + 1, true)
          Effectcreate("war3mapImported\\Texiao_chengxizhiguang1.mdx", x, y)
        end
      })
      if u:hasdata("第二阶段开始") then
        timer:remove()
      end
    end)
  end)
  ac.wait(6000, function()
    SendMsgAll("|cFFCC0033二阶堂真红：......|r")
    SendDtimeMsgAll(5, "|cFFCC99FF八云紫：|r呼....似乎暂时将她击退了，不过情况还是不容乐观")
    SendDtimeMsgAll(10, "|cFFCC99FF八云紫：|r天国之门似乎在修复着她的身体，各位请抓紧现在的时间提升自己的力量")
    SendDtimeMsgAll(15, "|cFFCC99FF八云紫：|r我们会在这期间寻找出压制她的办法")
    SendDtimeMsgAll(20, "|cFFCC99FF八云紫：|r大家加油吧")
    ac.loop(1000, function(timer)
      if u:hasdata("真红-二阶段开始判定") and not u:hasdata("真红-二阶段已经开始") then
        u:setdata("真红-二阶段已经开始")
        local dx = -5000
        local dy = 12089
        u:deldata("真红阶段结束标记")
        u:setmaxhp(400000000)
        u:sethp(100, true)
        u:setface(270)
        u:setdata("神性", 27)
        FogEnable(false)
        FogMaskEnable(false)
        u:setdata("锁定时间", 0)
        BOSS = u.handle
        u:setxy(dx, dy)
        u:setmp(0)
        u:setdata("晨曦之光锁定组", CreateGroupLua())
        u:setdata("第二阶段开始")
        u:setdata("真红-二阶段蓄力时间", 1)
        if Nandu_Choose >= 5 then
          u:setdata("真红-二阶段蓄力时间", 0.6)
        end
        u:setdata("伤害统计-分钟数", Time_M)
        u:setdata("伤害统计-秒钟数", Time_S)
        u:setdata("世界之羽累积伤害", 0)
        u:setdata("真红-BOSS阶段", 2)
        u:setdata("真红-世界之羽")
        CameraSetupApplyForceDuration(Glo.gg_cam_Camera_008, true, 0)
        SetCameraTargetController(u.handle, 0, 0, false)
        Movie_Boolean = true
        local cs = 0
        ac.loop(1000, function(timer2)
          cs = cs + 1
          Movie_Boolean = true
          if cs == 6 then
            Movie_Boolean = false
            timer2:remove()
          end
        end)
        ac.wait(3000, function()
          PlayGlobalSound(BOSS_Zhenhong_Chuansong)
        end)
        ForGroupLuaNew(u:getdata("世界之门组"), function(xq)
          local size = 0.61
          local cs2 = 0
          xq:animespeed(6)
          ac.loop(20, function(timer3)
            cs2 = cs2 + 1
            size = size - 0.004
            xq:setsize(size)
            if cs2 == 150 then
              local ax, ay = xq:getxy()
              EffectcreateArgs({
                effect = "war3mapImported\\Texiao_zhenhongchuansong1.mdx",
                x = ax,
                y = ay
              })
              xq:remove()
              timer3:remove()
            end
          end)
        end)
        ChangeBGM(BOSS_Zhenhong_Start1)
        ForGroupLuaNew(Group_PlayHero, function(xq)
          xq:shockcamera(10, 0.99)
        end)
        local cs2 = 0
        ac.loop(100, function(timer4)
          cs2 = cs2 + 1
          ForGroupLuaNew(Group_PlayHero, function(xq)
            xq:shockcamera(cs2 * 1, 0.99)
          end)
          EffectcreateArgs({
            effect = "war3mapImported\\Texiao_zhenhongxuli.mdx",
            x = dx,
            y = dy,
            size = 1 + 0.2 * cs2,
            height = -15 * cs2,
            zxz = GetRandomAngle()
          })
          if 60 <= cs2 then
            ac.wait(1000, function()
              ForGroupLuaNew(Group_PlayHero, function(xq)
                xq:shockcamera(10, 0.5)
              end)
              if Nandu_Choose >= 5 then
                PlayGlobalSound(BOSS_Zhenhong_Baozha1)
                local dcs = 0
                ac.loop(50, function(t)
                  dcs = dcs + 1
                  EffectcreateArgs({
                    effect = "BOSS_zhenhong_hongqi1.mdx",
                    x = dx,
                    y = dy,
                    time = 1,
                    size = dcs / 1.5,
                    zxz = u:getface(),
                    animespeed = 1
                  })
                  if 10 <= dcs then
                    t:remove()
                  end
                end)
              end
              ac.wait(500, function()
                ForGroupLuaNew(Group_PlayHero, function(xq)
                  local sy = xq.ownerid
                  ResetToGameCameraForPlayer(xq.owner, 0)
                  local p = getplayer(xq.owner)
                  p:setcameraheight(Cam_height[xq.ownerid], 0)
                end)
                CinematicFadeBJ(bj_CINEFADETYPE_FADEOUTIN, 0.5, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 100.0, 0, 0, 0.0)
                u:effectadd("war3mapImported\\wangguan.mdx", "head", -1)
                local mj = u:createunit("u0DI", dx, dy)
                mj:setsize(1.1)
                ac.loop(30, function(timer5)
                  local ddx, ddy = u:getxy()
                  mj:setxy(ddx, ddy)
                  if u:hasdata("第三阶段开始") then
                    mj:setxy(ddx, ddy)
                    timer5:remove()
                  end
                end)
                u:setdata("世界之环", mj)
                local tm = 0
                local tmd = 0
                ac.loop(100, function(timer6)
                  if u:hasdata("第三阶段开始") then
                    if 50 <= tmd then
                      tmd = 50
                    end
                    if tmd < 50 and tm == 0 then
                      tmd = tmd + 1
                    else
                      tm = 1
                      tmd = tmd - 1
                      if tmd <= 10 then
                        tm = 0
                      end
                    end
                  elseif tmd < 255 and tm == 0 then
                    tmd = tmd + 1
                  else
                    tm = 1
                    tmd = tmd - 1
                    if tmd <= 100 then
                      tm = 0
                    end
                  end
                  mj:setcolor(255, 255, 255, tmd)
                  if u:hasdata("第三阶段完结") then
                    timer6:remove()
                  end
                end)
                ac.wait(5000, function()
                  u:deldata("真红永恒")
                  u:delskill("A00N")
                  SetUnitOwner(u.handle, Player(9), false)
                  if not u:hasdata("真红二阶段技能循环开始") then
                    u:setdata("真红二阶段技能循环开始")
                    zhenhong_2_start(u)
                  end
                end)
              end)
            end)
            timer4:remove()
          end
        end)
        timer:remove()
      end
    end)
  end)
end

function boss_zhenhong(unit)
  local npc = getunit(NPC_Molijiedian)
  ShowUnit(npc.handle, true)
  japi.SetUnitModel(NPC_Molijiedian, "Star_Blue.mdx")
  npc:setsize(0.5)
  npc:setflyheight(600)
  RewardStop = true
  ForGroupLuaNew(Group_PlayHero, function(xq)
    if xq:hasdata("背包-艾露猫") then
      AilumaoSnd(xq, "挑战BOSS")
    end
  end)
  ForGroupLuaNew(Group_Monster, function(xq)
    if not xq:isboss() then
      xq:kill(BOSS_DEATH, true)
      if xq:isnotingroup(HellGroup) then
        LeftNumofMonster = LeftNumofMonster + 1
      end
    end
  end)
  RewardStop = false
  local u = getunit(unit)
  local zhenhong = u
  u.owner = Player(9)
  u:changeowner(Player(9))
  u:setplayername("|cffff0000『世界的意志』|r")
  Boss_Zhenhong = u.handle
  BOSS = u.handle
  local dx = -5000
  local dy = 12089
  local npc = getunit(NPC_Molijiedian)
  npc:setxy(dx, dy)
  npc:setcolor(255, 255, 255, 50)
  u:buffset(u.handle, 3600, "暂停")
  u:buffset(u.handle, 3600, "无敌")
  u:setxy(dx, dy)
  u:buffset(u.handle, 3600, "锁定")
  MonsterSetXingcunzuAttackTarget(u)
  u:groupadd(Group_Monster)
  u:groupadd(HellGroup)
  u:setface(270)
  u:addskill("A020")
  u:setdata("系统-BOSS")
  u:addskill("A11G")
  SetUnitPathing(u.handle, false)
  for i = 1, 8 do
    UnitShareVision(u.handle, Player(i - 1), true)
  end
  TriggerRegisterUnitEvent(DamageSystemTrg, u.handle, EVENT_UNIT_DAMAGED)
  TriggerRegisterUnitEvent(MonsterDead, u.handle, EVENT_UNIT_DEATH)
  if Nandu_Choose >= 5 then
    u:setdata("爆伤抗性", 0.4)
  else
    u:setdata("爆伤抗性", 0.6)
  end
  AddAllSTexiao("BOSS-真红", "受伤后效果", function(args)
    local u = args.tg
    local hero = args.u
    local info = args.damageinfo
    if info.damage > 0 and u:hasdata("BOSS-真红") then
      local t = 10
      if u:hasdata("第三阶段开始") then
        t = t * 2
      end
      if u:hasdata("两仪式帮助") then
        t = t * 0.5
      end
      if Nandu_Choose >= 5 then
        t = t * 1.5
      end
      hero:changetimedata("法则侵蚀叠加层数", 1, t)
      if hero:islocal() then
        BuffUI.apply({
          id = "法则侵蚀",
          duration = t + 0.1
        })
      end
    end
  end)
  local addatk = 0.85 + 0.15 * Nandu_Level
  addatk = addatk * MWTQ_AtkBOSS
  addatk = addatk * NanduJc_Atk
  u:setdata("怪物强度", addatk)
  u:setdata("怪物-伤害修正", 1)
  if Nandu_Choose == 5 then
    u:setdata("单位-大头像", "Portrait_Shijiedeyizhi.tga")
  end
  u:setdata("光属性抗性", 50)
  u:setdata("暗属性抗性", 50)
  u:setdata("风属性抗性", 50)
  u:setdata("雷属性抗性", 50)
  u:setdata("冰属性抗性", 50)
  u:setdata("水属性抗性", 50)
  u:setdata("火属性抗性", 50)
  u:setdata("心灵属性抗性", 50)
  u:setdata("神性", 5)
  u:setdata("真红永恒")
  u:setdata("免疫击退效果")
  u:setdata("世界之门组", CreateGroupLua())
  Movie_Boolean = true
  local cs = 0
  FogEnable(false)
  FogMaskEnable(false)
  ac.loop(1000, function(timer)
    cs = cs + 1
    Movie_Boolean = true
    if cs == 34 then
      Movie_Boolean = false
      timer:remove()
    end
  end)
  ShowUnit(u.handle, false)
  SetUnitMoveSpeed(u.handle, 0)
  SetUnitState(u.handle, UNIT_STATE_MAX_LIFE, 10000)
  u:setmaxhp(100000000)
  u:setdata("怪物基础生命上限", u:getmaxhp())
  if Keyan_Zhongzhuanghujia and not u:hasdata("科研模式-重装护甲提升") then
    local add = 0.5 * Nandu_Level
    u:changearmor(add)
    u:setdata("科研模式-重装护甲提升")
  end
  u:setmaxmp(1000)
  u:sethp(100, true)
  CameraSetupApplyForceDuration(Glo.gg_cam_Camera_008, true, 0)
  SetCameraTargetController(u.handle, 0, 500, false)
  Effectcreate("war3mapImported\\Texiao_zhenhongxuli.mdx", dx, dy, 0, 15)
  PlayGlobalSound(BOSS_Zhenhong_Feng1)
  ac.wait(500, function()
    ChangeBGM(BOSS_Zhenhong_Start3)
  end)
  u:setdata("BOSS-真红")
  u:setdata("真红-BOSS阶段", 1)
  u:setdata("免疫混乱改变所属")
  u:addstexiao("BOSS-真红", "BOSS减伤计算", function(args)
    local u = args.tg
    local soc = args.u
    local info = args.damageinfo
    local sh = info.damage
    local yssh = info.yssh
    local xs = 1
    local cxsx = 0.03
    if Nandu_Choose >= 5 then
      xs = 0.5
      cxsx = 0.01
    end
    if soc:hasdata("八重樱-真红限伤") then
      xs = xs * 2
    end
    if 1 >= PlayerCount then
      xs = xs * 2
    end
    local jm = false
    if info.isvestdamage or soc:hasdata("不拆分伤害") then
      jm = true
    end
    if u:getdata("真红-BOSS阶段") == 1 then
      local max = 1000000 * xs
      if jm then
        max = max * 0.2
      end
      if sh >= max then
        sh = max + (sh - max) * cxsx
      end
    end
    if u:getdata("真红-BOSS阶段") == 2 then
      local max = 4000000 * xs
      if jm then
        max = max * 0.2
      end
      if sh >= max then
        sh = max + (sh - max) * cxsx
      end
    end
    if u:getdata("真红-BOSS阶段") == 3 then
      local max = 20000000 * xs
      if jm then
        max = max * 0.2
      end
      if sh >= max then
        sh = max + (sh - max) * cxsx
      end
    end
    if soc:hasdata("真红-世界锁") then
      sh = sh * soc:getdata("真红-世界锁")
    end
    if soc:hasdata("青空之翼") then
      local add = soc:getdata("青空之翼增伤") + soc:getdata("青空之翼基础增伤")
      if jm then
        add = add * 0.1
      end
      sh = sh + add
    end
    info.damage = sh
  end)
  u:addstexiao("BOSS-真红", "伤害显示后效果", function(args)
    local u = args.tg
    local soc = args.u
    local info = args.damageinfo
    if u:getdata("真红-BOSS阶段") == 1 and (info.damage >= u:gethp() - 1000 or u:getperhp() <= 10) then
      info.damage = 0
      u:setdata("真红-一阶段击败者", soc)
      u:setdata("第一阶段结束")
      u:setdata("真红永恒")
      u:sethp(10, true)
      timershijiezhiyan:remove()
      local ax, ay = u:getxy()
      PlayGlobalSound(BOSS_Zhenhong_Chuansong)
      EffectcreateArgs({
        effect = "war3mapImported\\Texiao_zhenhongchuansong1.mdx",
        x = ax,
        y = ay
      })
      ac.wait(1000, function()
        zhenhong_1_end(u)
        u:addskill("A00N")
        u:setxy(dx, dy)
        PlayGlobalSound(BOSS_Zhenhong_Chuansong)
        EffectcreateArgs({
          effect = "war3mapImported\\Texiao_zhenhongchuansong1.mdx",
          x = dx,
          y = dy
        })
      end)
    end
    if u:getdata("真红-BOSS阶段") == 2 then
      if info.damage >= u:gethp() - 1000 or u:getperhp() <= 7 then
        info.damage = 0
        u:setdata("真红永恒")
        u:sethp(9, true)
        u:setdata("次元闭锁已开启")
        u:setdata("真红-二阶段击败者", soc)
      end
      if u:hasdata("真红-世界之羽") and not u:hasdata("真红-世界之羽永恒") then
        local max = 60000000
        if Nandu_Choose >= 5 then
          max = 40000000
        end
        local cur = u:getdata("世界之羽累积伤害") or 0
        if Nandu_Shenzhao then
          local remain = max - cur
          if remain <= 0 then
            info.damage = 0
          else
            local add = info.damage
            if remain < add then
              add = remain
              info.damage = add
            end
            u:changedata("世界之羽累积伤害", add)
            cur = cur + add
          end
        else
          local add = info.damage
          u:changedata("世界之羽累积伤害", add)
          cur = cur + add
        end
        if max <= cur then
          u:setdata("世界之羽累积伤害", 0)
          SendMsgAll("|cFFCC0000曙光.世界之羽|r")
          u:effectadd("war3mapImported\\Zhenhong_NTx (2).mdl")
          u:effectadd("war3mapImported\\Zhenhong_NTx (1).mdl", "origin", 10)
          u:settimedata("真红-世界之羽永恒", 10)
        end
      end
    end
    if u:getdata("真红-BOSS阶段") == 3 and 0 < u:getdata("时间与空间的刻印个数") and (info.damage >= u:gethp() - 1000 or u:getperhp() <= 5) then
      info.damage = 0
      u:setdata("真红永恒")
      u:sethp(10, true)
      ZhenhongSkill["时空刻印"](u)
    end
  end)
  ac.wait(1000, function()
    ForGroupLuaNew(Group_PlayHero, function(xq)
      xq:shockcamera(20, 0.2)
    end)
    Effectcreate("war3mapImported\\Texiao_baiwu1.mdx", dx, dy, 13)
    CinematicFadeBJ(bj_CINEFADETYPE_FADEOUTIN, 0.2, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 100.0, 0, 0, 0.0)
    local atx1 = EffectcreateArgs({
      effect = "war3mapImported\\Texiao_zhianzhiyu.mdx",
      x = dx,
      y = dy,
      time = 18,
      height = 1200,
      zxz = 270,
      yxz = 90
    })
    local atx2 = EffectcreateArgs({
      effect = "war3mapImported\\Texiao_heihongwuqi.mdx",
      x = dx,
      y = dy,
      time = 18,
      size = 0.5,
      height = 1200,
      zxz = 270,
      yxz = 90
    })
    ac.timer(20, 10, function()
      EffectcreateArgs({
        effect = "war3mapImported\\Texiao_heiyuzhijian.mdx",
        x = dx,
        y = dy,
        time = 0,
        size = 10,
        height = 1200,
        zxz = GetRandomAngle(),
        xxz = GetRandomAngle(),
        yxz = GetRandomAngle()
      })
    end)
    ac.wait(4500.0, function()
      CinematicFadeBJ(bj_CINEFADETYPE_FADEOUTIN, 0.2, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 100.0, 0, 0, 0.0)
      SetEffectSize(atx1, 2)
      SetEffectSize(atx2, 1)
      ForGroupLuaNew(Group_PlayHero, function(xq)
        xq:shockcamera(20, 0.2)
      end)
    end)
    ac.wait(9000, function()
      CinematicFadeBJ(bj_CINEFADETYPE_FADEOUTIN, 0.2, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 100.0, 0, 0, 0.0)
      SetEffectSize(atx1, 3)
      SetEffectSize(atx2, 1.5)
      ForGroupLuaNew(Group_PlayHero, function(xq)
        xq:shockcamera(20, 0.2)
      end)
    end)
    ac.wait(13500.0, function()
      CinematicFadeBJ(bj_CINEFADETYPE_FADEOUTIN, 0.2, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 100.0, 0, 0, 0.0)
      SetEffectSize(atx1, 4)
      SetEffectSize(atx2, 2)
      ForGroupLuaNew(Group_PlayHero, function(xq)
        xq:shockcamera(20, 0.2)
      end)
    end)
    ac.wait(17500.0, function()
      DestroyEffectLua(atx1)
      DestroyEffectLua(atx2)
    end)
    local tx4, tx3
    ac.wait(18000, function()
      tx3 = EffectcreateArgs({
        effect = "war3mapImported\\Texiao_heiyu.mdx",
        x = dx,
        y = dy,
        time = -1,
        size = 2,
        height = 1250
      })
      tx4 = EffectcreateArgs({
        effect = "war3mapImported\\Texiao_heiyu.mdx",
        x = dx,
        y = dy,
        time = -1,
        size = 2,
        height = 1250
      })
      PlayGlobalSound(BOSS_Zhenhong_Tishi1)
      Effectcreate("war3mapImported\\Texiao_chengxizhiguang1.mdx", dx, dy, 0, 60)
      CinematicFadeBJ(bj_CINEFADETYPE_FADEOUTIN, 0.2, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 100.0, 0, 0, 0.0)
      u:setflyheight(1200)
      ShowUnit(u.handle, true)
      ForGroupLuaNew(Group_PlayHero, function(xq)
        xq:shockcamera(20, 0.2)
      end)
    end)
    ac.wait(23000, function()
      local dcs = 0
      local size = 2
      ac.loop(20, function(timer)
        dcs = dcs + 1
        size = size - 0.008
        SetEffectSize(tx4, size)
        if dcs == 250 then
          DestroyEffectLua(tx4)
          timer:remove()
        end
      end)
    end)
    ac.wait(26000, function()
      PlayGlobalSound(BOSS_Zhenhong_Feng1)
      local dcs = 0
      local size = 2
      ac.loop(20, function(timer)
        dcs = dcs + 1
        size = size - 0.008
        SetEffectSize(tx3, size)
        if dcs == 250 then
          DestroyEffectLua(tx3)
          ForGroupLuaNew(Group_PlayHero, function(xq)
            xq:shockcamera(20, 1)
          end)
          PlayGlobalSound(BOSS_Zhenhong_Shandian1)
          ac.timer(20, 50, function()
            EffectcreateArgs({
              effect = "war3mapImported\\Texiao_heiyuzhijian.mdx",
              x = dx,
              y = dy,
              time = 0,
              size = 10,
              height = 1300,
              zxz = GetRandomAngle(),
              xxz = GetRandomAngle(),
              yxz = GetRandomAngle()
            })
          end)
          timer:remove()
        end
      end)
    end)
    ac.wait(31700.0, function()
      PlayGlobalSound(BOSS_Zhenhong_Chuansong)
      ShowUnit(u.handle, false)
      u:setflyheight(0)
      EffectcreateArgs({
        effect = "war3mapImported\\Texiao_zhenhongchuansong1.mdx",
        x = dx,
        y = dy,
        time = 0,
        height = 1200
      })
    end)
    ac.wait(32500.0, function()
      PlayGlobalSound(BOSS_Zhenhong_Chuansong)
      ShowUnit(u.handle, true)
      u:effectadd("Guanghuan_Zhenhong.mdx", "origin", -1)
      u:setflyheight(0)
      EffectcreateArgs({
        effect = "war3mapImported\\Texiao_zhenhongchuansong1.mdx",
        x = dx,
        y = dy,
        time = 0
      })
      ForGroupLuaNew(Group_PlayHero, function(xq)
        local sy = xq.ownerid
        ResetToGameCameraForPlayer(xq.owner, 0)
        local p = getplayer(xq.owner)
        p:setcameraheight(Cam_height[xq.ownerid], 0)
      end)
    end)
    ac.wait(33500.0, function()
      SendMsgAll("|cFFCC0000神迹.世界之门|r", 10)
      if Nandu_Choose <= 4 then
        SendMsgAll("|cFFCC0000[地图四个角落出现世界之门,摧毁任一世界之门时,在一定时间后复原所有世界之门;同时摧毁所有世界之门时解除真红的无敌]|r")
      end
      local rect = RECT_Guangchang
      local x1 = GetRectMinX(rect)
      local x2 = GetRectMaxX(rect)
      local y1 = GetRectMinY(rect)
      local y2 = GetRectMaxY(rect)
      local cs3 = 0
      
      local function mjdd(mj)
        mj:setdata("免疫生命损耗")
        mj:setdata("免疫击退效果")
        mj:setdata("免疫生命修改")
        mj:setdata("免疫抑制恢复")
        mj:setdata("免疫负面效果")
        mj:setdata("系统-单次受伤1")
        mj:setdata("免疫即死效果")
        mj:setdata("免疫混乱改变所属")
        SetUnitState(mj.handle, UNIT_STATE_MAX_LIFE, 10000)
        mj:setmaxhp(600)
        mj:setdata("真红-世界之门")
        mj:groupadd(u:getdata("世界之门组"))
        mj:groupadd(HellGroup)
        TriggerRegisterUnitEvent(DamageSystemTrg, mj.handle, EVENT_UNIT_DAMAGED)
        SetUnitMoveSpeed(mj.handle, 0)
        local ddx, ddy = mj:getxy()
        Effectcreate("war3mapImported\\Texiao_chengxizhiguang1.mdx", ddx, ddy, 0, 2)
        mj:animespeed(6)
        mj:setsize(0.01)
        local size = 0.01
        local cs2 = 0
        ac.loop(20, function(timer)
          cs2 = cs2 + 1
          size = size + 0.004
          mj:setsize(size)
          if cs2 == 150 then
            cs3 = cs3 + 1
            if cs3 == 1 then
              mj:setxy(x1, y1)
            end
            if cs3 == 2 then
              mj:setxy(x1, y2)
            end
            if cs3 == 3 then
              mj:setxy(x2, y1)
            end
            if cs3 == 4 then
              mj:setxy(x2, y2)
            end
            EffectcreateArgs({
              effect = "war3mapImported\\Texiao_zhenhongchuansong1.mdx",
              x = ddx,
              y = ddy
            })
            timer:remove()
          end
        end)
        mj:addstexiao("真红-世界之门", "伤害显示后效果", function(args)
          local tg = args.tg
          local u = args.u
          local info = args.damageinfo
          if u:ishasskill(SKILL_TESHUYINGXIONG) then
            info.damage = 2
            if u.type == HeroType["八重樱"] then
              info.damage = 5
            end
            if Nandu_Choose <= 4 then
              info.damage = info.damage + 1
            end
          end
          if u:hasdata("世界之门-伤害加成") then
            info.damage = info.damage + u:getdata("世界之门-伤害加成")
          end
          if info.damage >= tg:gethp() - 10 or tg:hasdata("真红永恒") then
            info.damage = 0
            tg:setdata("真红永恒")
            tg:setdata("世界之门-重构中")
            local xx, yy = tg:getxy()
            Effectcreate("war3mapImported\\Texiao_chengxizhiguang1.mdx", xx, yy, 0, 4)
            if not zhenhong:hasdata("天国之门计时") then
              zhenhong:setdata("天国之门计时")
              ZhenhongSkill["天国之门"](zhenhong)
            end
          end
        end)
      end
      
      local a = 315
      for i = 1, 4 do
        a = a + 90
        local dddx, dddy = PolarXY(dx, dy, 350, a)
        local mj = u:getdata("世界之门G")[i]
        mj.owner = Player(9)
        mj:changeowner(Player(9))
        mj:setxy(dddx, dddy)
        mjdd(mj)
      end
      ac.loop(1000, function(timer)
        ForGroupLuaNew(u:getdata("世界之门组"), function(xq)
          xq:buffset(u.handle, 0.98, "锁定")
        end)
        if u:hasdata("第一阶段结束") then
          timer:remove()
        end
      end)
      PlayGlobalSound(BOSS_Zhenhong_Keyin1)
      ac.wait(3000, function()
        PlayGlobalSound(BOSS_Zhenhong_Zhongsheng2)
        PlayGlobalSound(BOSS_Zhenhong_Chuansong)
      end)
      ac.wait(4000, function()
        zhenhong_1_start(u)
        u:setdata("伤害统计-分钟数", Time_M)
        u:setdata("伤害统计-秒钟数", Time_S)
        timershijiezhiyan:resume()
      end)
    end)
  end)
end
