-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
function damagesystemre0035(unit, source, damage, damagelevel, dis, damageinfo)
  local sh = damage
  
  local u = getunit(unit)
  local soc = getunit(source)
  local x, y = u:getxy()
  local x2, y2 = soc:getxy()
  local sy = u.ownerid
  local sy2 = soc.ownerid
  local shlx = damagelevel
  local b = false
  if u:hasdata("变异判定-写轮眼") and soc:istype(u:getdata("复写对象")) then
    b = true
    if soc:isnormal() then
      u:changedata("复写时间", -0.5)
    elseif soc:iselite() then
      u:changedata("复写时间", -5)
    else
      u:setdata("复写时间", 0)
    end
  end
  if u:hasdata("变异判定-卡卡西") then
    local lx = GetUnitTypeId(source)
    for index, value in ipairs(Group_KakaxiFuxie) do
      if lx == value then
        b = true
        u:effectadd("Abilities\\Weapons\\AncestralGuardianMissile\\AncestralGuardianMissile.mdl", "chest")
        break
      end
    end
  end
  if u:hasdata("变异判定-利姆露") then
    for i = 1, 10 do
      if Group_LimuruBianhua[i] == GetUnitTypeId(source) then
        b = true
        u:effectadd("Abilities\\Weapons\\AncestralGuardianMissile\\AncestralGuardianMissile.mdl", "chest")
        break
      end
    end
  end
  if u:ishasbuff("B063") then
    local qzh = 0
    ForGroupLuaNew(Group_Xingcunzu, function(xq)
      if u:ishasskill("A0WM") then
        qzh = xq.handle
      end
    end)
    if qzh ~= 0 then
      if DistanceBetweenUnits(qzh, soc) >= 1000 then
        b = true
      else
        sh = sh * GetRandomReal(0.2, 0.5)
      end
    end
  end
  if u:hasdata("变异判定-六眼") and dis <= 350 and not soc:hasdata("六眼无量冷却") and soc:getdata("六眼-无量计数") < 6 then
    b = true
    u:effectadd("AATX\\[AATxNew]Blue03.mdl")
    if soc:isboss() then
      soc:settimedata("六眼无量冷却", 3)
    end
  end
  if u:hasdata("卡斯特-冬秋夏春") and not u:hasdata("卡斯特-冬秋夏春冷却") then
    b = true
    u:settimedata("卡斯特-冬秋夏春冷却", 8)
    u:sendmessage("|cFF990000C呆-冬秋夏春|r")
  end
  if source ~= BOSS_DEATH and 50 <= sh then
    local tt = StexiaoFunc({
      text = "伤害格挡效果",
      target = source,
      tg = soc,
      unit = unit,
      u = u,
      sy = sy,
      sy2 = sy2,
      damage = sh,
      dis = dis,
      b = b,
      damageinfo = damageinfo
    })
    b = tt.b
    if not b and u:hasdata("变异判定-拉比琳丝") and not u:hasdata("拉比琳丝魔像冷却") then
      b = true
      u:settimedata("拉比琳丝魔像冷却", 5)
    end
    if not b and u:hasdata("星之奇迹-持有") and not u:hasdata("神之形冷却") then
      b = true
      u:sendmessage("|cFFFFCC00神之形|r")
      local t = 60
      if u:hasdata("变异判定-人理之光") then
        t = 30
      end
      u:settimedata("神之形冷却", t)
    end
    if not b and u:ishasbuff("B0BH") and not u:hasdata("心空妙有冷却") then
      b = true
      u:sendmessage("|cFFFF99FF根源式-心空妙有|r")
      u:settimedata("心空妙有冷却", 15)
    end
    if not b and u:hasdata("变异判定-破晓") and not u:hasdata("破晓格挡冷却") then
      b = true
      u:effectadd("Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldCaster.mdl", "chest")
      u:sendmessage("|cFFFF9933破晓|r")
      local t = 30
      if u:hasdata("变异判定-终末鸟") then
        t = 18
      end
      u:settimedata("破晓格挡冷却", t)
    end
    if not b and u:hasdata("夜夜-森闲") and not u:hasdata("森闲格挡冷却") then
      b = true
      u:effectadd("Abilities\\Spells\\Undead\\ReplenishHealth\\ReplenishHealthCasterOverhead.mdl", "chest")
      u:settimedata("森闲格挡冷却", 30)
    end
    if not b and u:hasdata("变异判定-米霍克") and 750 <= dis and 0 >= u:getdata("武装色霸气格挡冷却时间") then
      b = true
      u:setdata("武装色霸气格挡冷却时间", 15)
      u:effectadd("Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldCaster.mdl", "chest")
      if GetRandom100(50) then
        u:playsound(Datie_1)
      else
        u:playsound(Datie_2)
      end
      local txsh = 5000 + 500 * u:getlevel()
      local a = AngleBetweenUnits(unit, source)
      local tx = Effectcreate("war3mapImported\\[TX] (1348).mdl", x, y, -1, 1.5, 50, a)
      local x1, y1 = x, y
      local g = CreateGroupLua()
      effectmove({
        effect = tx,
        time = 0.6,
        distance = 1800,
        angle = a,
        loops = {
          {
            looptime = 0.02,
            func = function()
              x1, y1 = GetEffectXY(tx)
              for _, xq in ac.selector():in_rangexy(x1, y1, 225):is_enemy(unit):isnotingroup(g):ipairs() do
                xq = getunit(xq)
                xq:groupadd(g)
                DamageUnit({
                  bj = "米霍克武装色霸气",
                  unit = xq.handle,
                  source = u.handle,
                  damage = txsh,
                  level = 5,
                  type = "魔力",
                  isvest = true,
                  isattack = false,
                  isnoarmor = false,
                  element = "无",
                  extradata = {"近战"}
                })
                xq:effectadd("Objects\\Spawnmodels\\Human\\HumanLargeDeathExplode\\HumanLargeDeathExplode.mdl")
                xq:buffset(unit, 0.5, "僵直")
              end
            end
          }
        },
        endfunc = function()
          DestroyEffectLua(tx)
        end
      })
    end
    if not b and u:hasdata("变异判定-利姆露") and 750 <= dis and 0 >= u:getdata("魔王霸气格挡冷却时间") then
      b = true
      u:setdata("魔王霸气格挡冷却时间", 30)
      u:effectadd("Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldCaster.mdl", "chest")
      if GetRandom100(50) then
        u:playsound(Datie_1)
      else
        u:playsound(Datie_2)
      end
      local txsh = 5000 + 500 * u:getlevel()
      local a = AngleBetweenUnits(unit, source)
      local tx = Effectcreate("war3mapImported\\[TX] (1348).mdl", x, y, -1, 1.5, 50, a)
      local x1, y1 = x, y
      local g = CreateGroupLua()
      effectmove({
        effect = tx,
        time = 0.6,
        distance = 1800,
        angle = a,
        loops = {
          {
            looptime = 0.02,
            func = function()
              x1, y1 = GetEffectXY(tx)
              for _, xq in ac.selector():in_rangexy(x1, y1, 225):is_enemy(unit):isnotingroup(g):ipairs() do
                xq = getunit(xq)
                xq:groupadd(g)
                DamageUnit({
                  bj = "利姆露魔王霸气",
                  unit = xq.handle,
                  source = u.handle,
                  damage = txsh,
                  level = 5,
                  type = "魔力",
                  isvest = true,
                  isattack = false,
                  isnoarmor = false,
                  element = "无",
                  extradata = {"近战"}
                })
                xq:effectadd("war3mapImported\\[TX] (1337).mdx")
                xq:buffset(unit, 0.5, "僵直")
              end
            end
          }
        },
        endfunc = function()
          DestroyEffectLua(tx)
        end
      })
    end
    if not b and u:hasdata("变异判定-根源式") and not u:hasdata("俯瞰风景格挡冷却时间") then
      b = true
      u:effectadd("Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldCaster.mdl")
      u:setdata("俯瞰风景格挡冷却时间", 15)
      ac.loop(250, function(timer)
        u:changedata("俯瞰风景格挡冷却时间", -0.25)
        if u:getdata("俯瞰风景格挡冷却时间") <= 0 then
          u:deldata("俯瞰风景格挡冷却时间")
          u:sendmessage("俯瞰风景冷却完毕")
          timer:remove()
        end
      end)
    end
    if not b and u:hasdata("变异判定-两仪式") and not u:hasdata("心眼格挡冷却时间") then
      b = true
      u:effectadd("Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldCaster.mdl")
      u:setdata("心眼格挡冷却时间", 25)
      ac.loop(250, function(timer)
        u:changedata("心眼格挡冷却时间", -0.25)
        if u:getdata("心眼格挡冷却时间") <= 0 then
          u:deldata("心眼格挡冷却时间")
          u:sendmessage("心眼(伪)冷却完毕")
          timer:remove()
        end
      end)
      unifycreate({
        owner = unit,
        model = "war3mapImported\\sakuya_knife.mdl",
        modelname = "飞刀",
        modelsize = 1,
        height = 75,
        damage = 1000 + 100 * u:getlevel(),
        damagetype = 2,
        range = dis + 500,
        speed = 2500,
        volume = 90,
        angle = AngleBetweenUnits(unit, source),
        hitbeforefunc = function(mj, xq, damage2)
          u:setdata("伤害阶级", 5)
        end
      })
    end
    if not b and u:hasdata("秦心-禁忌化") and not u:hasdata("秦心禁忌化格挡冷却") then
      b = true
      u:settimedata("秦心禁忌化格挡冷却", 12)
      soc:effectadd("war3mapImported\\[TX] (967).mdl")
      DamageUnit({
        bj = "禁忌秦心格挡",
        unit = soc.handle,
        source = u.handle,
        damage = 50 * sh,
        level = 4,
        type = "灵力",
        isvest = true,
        isnoarmor = false
      })
    end
    if not b and u:hasdata("赫萝-戒指Lv2") and not u:hasdata("赫萝-戒指Lv2冷却") then
      b = true
      u:settimedata("赫萝-戒指Lv2", 20)
    end
    if not b and u:hasdata("量子机甲-格挡") then
      b = true
      u:deldata("量子机甲-格挡")
      u:sendmessage("|cFFCCCCCC量子机甲-格挡|r")
    end
    if not b and u:hasdata("变异判定-黑兔") and u:getdata("黑兔-黑色障壁次数") > 0 then
      b = true
      u:changedata("黑兔-黑色障壁次数", -1)
      u:sendmessage("|cFF330099黑色障壁剩余次数：" .. math.floor(u:getdata("黑兔-黑色障壁次数")) .. "|r")
    end
    if not b and u:hasdata("变异判定-年") and 0 < u:getdata("年-千明可鉴次数") then
      b = true
      u:changedata("年-千明可鉴触发次数", 1)
      if 3 <= u:getdata("年-千明可鉴触发次数") then
        u:changedata("年-千明可鉴触发次数", -3)
        ChangeValue(DamageSystem_Shjc, sy, 0.005)
      end
      u:changedata("年-千明可鉴次数", -1)
      u:sendmessage("|cFFED5E37千明可鉴剩余次数：" .. math.floor(u:getdata("年-千明可鉴次数")) .. "|r")
    end
    if not b and u:hasdata("红魔城碎片闪避") then
      b = true
      u:deldata("红魔城碎片闪避")
    end
    if not b and u:hasdata("万宝槌-梦幻格挡") then
      b = true
      u:deldata("万宝槌-梦幻格挡")
    end
  end
  if not b then
    if u:hasdata("变异判定-大祸津日神") and soc:getdata("伤害系统-伤害类型") == "灵力" and u:getgedangrandom(33) then
      b = true
    end
    if u:ishasitem("I03K") and u:getluckrandom(30) then
      b = true
    end
    if u:hasdata("变异判定-宇智波佐助") and u:getgedangrandom(5) then
      b = true
    end
    if u:hasdata("变异判定-滑头鬼之孙") and not u:hasdata("滑头鬼之孙-镜花水月冷却") and u:getgedangrandom(20) then
      b = true
      local txsh = 20 * u:getallattri()
      DamageUnit({
        bj = "滑头鬼之孙镜花水月",
        unit = soc.handle,
        source = u.handle,
        damage = txsh,
        level = 1,
        type = "灵力",
        isvest = true,
        isnoarmor = false
      })
      Hero_Tili[sy] = Hero_Tili[sy] + 0.3
      u:curehp(unit, 0, 1, 2)
      u:settimedata("滑头鬼之孙-镜花水月冷却", 0.5)
    end
    if u:hasdata("白洲梓-格罗兹尼的壁垒") and u:hasdata("白洲梓-适应性绿") and u:getgedangrandom(25) then
      b = true
    end
    if u:hasdata("变异判定-见习剑巫") then
      local gl = 10
      if u:hasdata("变异判定-姬柊雪菜") then
        gl = 18
      end
      if u:getgedangrandom(18) then
        b = true
        u:sendmessage("|cFF6699FF雪菜-未来视|r")
      end
    end
    if u:hasdata("禁忌判定-宇智波佐助") and u:getgedangrandom(5) then
      b = true
    end
    if u:hasdata("变异判定-刀仕禰宜") and not u:hasdata("刀仕禰宜触发冷却") then
      local jl = 25
      if u:hasdata("朱雀院椿-禁忌化") then
        jl = 100
      elseif u:hasdata("变异判定-朱雀院椿") then
        jl = 50
      end
      if u:getgedangrandom(jl) then
        b = true
        local txsh = 100 * u:getstr() + 500 * u:getlevel()
        if u:hasdata("朱雀院椿-禁忌化") then
          txsh = 45 * u:getallattri() + 1000 * u:getlevel()
          u:settimedata("刀仕禰宜触发冷却", 5)
        elseif u:hasdata("变异判定-朱雀院椿") then
          txsh = txsh * 2
        end
        u:sendmessage("|cFF990000刀仕禰宜-心眼|r")
        u:effectadd("Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldCaster.mdl", "chest")
        Effectcreate("0Tx\\0Tx_Chun (13).mdl", x2, y2, 0, 2)
        DamageUnit({
          bj = "椿-心眼",
          unit = soc.handle,
          source = u.handle,
          damage = txsh,
          level = 1,
          type = "物理",
          isvest = true,
          isattack = true
        })
        soc:buffset(unit, 1, "眩晕")
        soc:playsound(bac73)
      end
    end
    if u:hasdata("变异判定-终末鸟") and not u:hasdata("终末鸟-小鸟格挡触发冷却") then
      local jl = 20
      if sh >= u:gethp() then
        jl = 40
      end
      if u:getgedangrandom(jl) then
        b = true
        if sh >= u:gethp() then
          u:settimedata("终末鸟-小鸟格挡触发冷却", 10)
          u:sendmessage("|cFF990000小喙进入冷却|r")
          ac.wait(10000, function()
            u:sendmessage("|cFF990000小喙冷却完毕|r")
          end)
        end
        u:sendmessage("|cFF990000终末鸟-小喙格挡|r")
        u:effectadd("0Tx\\0Tx_Baoming (5).mdl", "chest")
      end
    end
    if not b and u:hasdata("Het") and u:getgedangrandom(24) then
      b = true
      local de = sh / 6
      local cs = 0
      ac.loop(2000, function(timer)
        cs = cs + 1
        u:effectadd("Abilities\\Spells\\Demon\\DarkPortal\\DarkPortalTarget.mdl")
        u:losshp(u, de)
        if cs == 6 then
          timer:remove()
        end
      end)
    end
    if u:hasdata("丛雨-神化") and 100 <= sh and u:getgedangrandom(u:getdata("守护灵概率")) then
      b = true
      if u:getdata("守护灵概率") >= 35 then
        u:changetimedata("守护灵概率", -10, 60)
      end
    end
    if u:hasdata("物品-要石") and not u:hasdata("要石-无法格挡") then
      local djl = u:getdata("要石格挡")
      if u:getgedangrandom(djl) then
        b = true
        u:effectadd("AATX\\[AATxNew]Hit36.mdl", "chest")
        u:sendmessage("|cFF6699FF要石格挡|r")
      end
    end
    if u:hasdata("变异判定-卧龙") and not u:hasdata("变异判定-诸葛亮") and not u:hasdata("八阵图触发冷却") then
      b = true
      u:settimedata("八阵图触发冷却", 8)
      u:effectadd("AATX\\[AATxNew]Hit53.mdl", "chest", 1)
      u:effectadd("AATX\\[AATxNew]Yellow01.mdl", "chest")
      Effectcreate("AATX\\AATxNew]Animate24.mdl", x, y, 0, 0.5)
      u:playsound(bac35)
    end
    if u:hasdata("变异判定-诸葛亮") and not u:hasdata("八阵图触发冷却") and u:getgedangrandom(50) then
      b = true
      u:settimedata("八阵图触发冷却", 3)
      u:effectadd("AATX\\[AATxNew]Hit53.mdl", "chest", 1)
      u:effectadd("AATX\\[AATxNew]Yellow01.mdl", "chest")
      Effectcreate("AATX\\AATxNew]Animate24.mdl", x, y, 0, 0.5)
      u:playsound(bac35)
    end
    if u:hasdata("遗物-更艰难的时光数量") then
      local zs = u:getdata("遗物-更艰难的时光数量")
      local jl = 1 - 1 / (0.15 * zs + 1)
      if jl >= GetRandomReal(0, 1) then
        b = true
        u:playsound(Sound_Xiaoxiong)
        u:effectadd("Abilities\\Spells\\Human\\Polymorph\\PolyMorphTarget.mdl", "chest")
      end
    end
    if soc:hasdata("神化判定-千子村正") and u:getgedangrandom(12) then
      b = true
      u:effectadd("AATX\\[AATxNew]Fire13.mdl", "chest")
    end
    if u:hasdata("变异判定-特里诺") and not u:hasdata("三原则触发冷却") and u:getgedangrandom(30) then
      b = true
      u:settimedata("三原则触发冷却", 1)
      u:effectadd("Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldCaster.mdl", "chest")
    end
    if u:hasdata("变异判定-纳兹") and 50 >= u:getperhp() then
      local jl = 50 - u:getperhp()
      if u:getgedangrandom(jl) then
        b = true
        u:effectadd("Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl")
        u:effectadd("Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl")
      end
    end
    if u:hasdata("星座-天蝎座激活") then
      if u:getgedangrandom(12) then
        b = true
        u:effectadd("Abilities\\Spells\\Other\\CrushingWave\\CrushingWaveDamage.mdl", "chest")
      end
      if u:getgedangrandom(12) then
        u:effectadd("Abilities\\Spells\\Items\\AIlm\\AIlmTarget.mdl", "chest")
        DamageUnit({
          bj = "天蝎座格挡",
          unit = soc.handle,
          source = u.handle,
          damage = 12 * sh,
          level = 1,
          type = "魔力",
          isvest = true,
          isnoarmor = false
        })
      end
    end
    if u:hasdata("变异判定-窥星者") and u:hasdata("窥星-夜晚判定") and u:getgedangrandom(12) then
      b = true
      u:effectadd("Abilities\\Spells\\Human\\MassTeleport\\MassTeleportTarget.mdl")
      Hero_Tili[sy] = Hero_Tili[sy] + 5
      u:curehp(unit, 0, 5, 4)
    end
    if u:hasdata("闪刀姬-水") and u:getgedangrandom(25) then
      b = true
      u:effectadd("Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl")
      soc:effectadd("Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl")
      DamageUnit({
        bj = "闪刀姬水",
        unit = soc.handle,
        source = u.handle,
        damage = 1000 * u:getdata("刀计数"),
        level = 1,
        type = "魔力",
        isvest = false,
        isattack = true,
        isnoarmor = false,
        element = "水"
      })
    end
    if u:hasdata("秦心-青青芦苇 秋露成霜") then
      local jl = 0.35 * (66 - u:getdata("面具数量"))
      if u:getgedangrandom(jl) then
        b = true
        u:effectadd("Abilities\\Weapons\\AncestralGuardianMissile\\AncestralGuardianMissile.mdl", "chest")
      end
    end
    if u:hasdata("玉藻前-神性") then
      local jl = 10 + 2 * u:getdata("灵基突破次数")
      if u:getgedangrandom(jl) then
        b = true
        u:effectadd("Abilities\\Weapons\\AncestralGuardianMissile\\AncestralGuardianMissile.mdl", "chest")
      end
    end
    if u:hasdata("物品-四叶草的初心") then
      local jl = 14
      if u:getgedangrandom(jl) then
        b = true
        u:effectadd("Abilities\\Weapons\\AncestralGuardianMissile\\AncestralGuardianMissile.mdl", "chest")
      end
    end
    if u:hasdata("变异判定-八云紫") then
      local jl = 12
      if u:ishasitem("I06F") then
        jl = 24
      end
      if u:getgedangrandom(jl) then
        b = true
        u:effectadd("Abilities\\Weapons\\AncestralGuardianMissile\\AncestralGuardianMissile.mdl", "chest")
        if soc:isnormal() then
          soc:buffset(unit, 3, "暂停")
          local x3, y3 = GetRandomXYInRect(RECT_PlayArea)
          soc:setxy(x3, y3)
        end
      end
    end
    if u:hasdata("禁忌判定-樱总司") and u:getgedangrandom(20) then
      b = true
      u:effectadd("Abilities\\Spells\\Orc\\MirrorImage\\MirrorImageCaster.mdl", "chest")
    end
    if u:hasdata("夜夜-吹鸣") and u:getgedangrandom(20) then
      b = true
      u:effectadd("Abilities\\Spells\\Orc\\MirrorImage\\MirrorImageCaster.mdl", "chest")
    end
    if u:hasdata("变异判定-卡卡西") and IsUnitVisible(source, u.owner) then
      local jl = 11
      if soc:isnormal() then
        jl = 33
      end
      if u:getgedangrandom(jl) then
        b = true
        u:effectadd("Abilities\\Weapons\\AncestralGuardianMissile\\AncestralGuardianMissile.mdl", "chest")
      end
    end
    if u:hasdata("天赋判定-杀戮空间") and u:isingroup(Group_Shalukongjian) and soc:isingroup(Group_Shalukongjian) and u:getgedangrandom(33) then
      b = true
      u:effectadd("Abilities\\Weapons\\AncestralGuardianMissile\\AncestralGuardianMissile.mdl", "chest")
    end
    if u:hasdata("变异判定-植物学硕士") and (not u:hasdata("奥尔加-杀意感知冷却") or u:hasdata("奥尔加-杀意感知持续时间")) then
      local gl = 50 + u:getdata("奥尔加-杀意感知加成概率")
      if 90 <= gl then
        gl = 90
      end
      if u:getgedangrandom(gl) and source ~= BOSS_DEATH then
        b = true
        u:playsound(Sound_Aoerjia_03)
        if not u:hasdata("奥尔加-杀意感知冷却") then
          u:settimedata("奥尔加-杀意感知失败", 4)
          u:settimedata("奥尔加-杀意感知持续时间", 3)
          u:settimedata("奥尔加-杀意感知冷却", 13)
        end
        u:changetimedata("奥尔加-杀意感知加成概率", 10, 3)
        local jd2 = GetRandomReal(0, 360)
        local jl = 450
        local x3, y3 = PolarXY(x, y, jl, jd2)
        Effectcreate("war3mapImported\\blackblink.mdx", x, y)
        if not Boolean_AnshenBattle and not Boolean_ZhenhongBattle then
          Effectcreate("war3mapImported\\blackblink.mdx", x3, y3)
          u:setxy(x3, y3)
        end
        u:clearbuff()
        if u:hasbuff("缠绕") then
          u:setdata("缠绕时间", 0)
        end
        if u:hasbuff("眩晕") then
          u:setdata("眩晕时间", 0)
        end
        if u:hasbuff("僵直") then
          u:setdata("僵直时间", 0)
        end
      end
    end
  end
  if b then
    sh = sh * 0.001
    if u:hasdata("薄暝甲-和平") and not u:hasdata("薄暝甲-格挡护盾冷却") then
      u:settimedata("薄暝甲-格挡护盾冷却", 5)
      local xxz = 0.003 * u:getdata("显示-固定伤害")
      u:changedata("薄暝甲-护盾值", xxz)
      hdzlinshiadd(u, xxz)
    end
    if u:hasdata("变异判定-残影的菲奥雷托") and not u:hasdata("菲奥雷托-歇逼") and not u:hasdata("菲奥雷托-虐杀") then
      u:changedata("菲奥雷托-格挡次数", 1)
      if 5 <= u:getdata("菲奥雷托-格挡次数") then
        u:setdata("菲奥雷托-格挡次数", 0)
        local yx = {
          Sound_Falt_Sb_01,
          Sound_Falt_Sb_02,
          Sound_Falt_Sb_03
        }
        u:sendmessage("|cFFFFCC66[残影的菲奥雷托]虐杀|r")
        u:playsound(yx[GetRandomInt(1, 3)])
        u:settimedata("菲奥雷托-虐杀", 30)
        ChangeTimeValue(DamageSystem_Shjc, sy, 1.3, 30)
      end
    end
    if u:hasdata("变异判定-终末鸟") and u:hasdata("物品-薄暝甲") and not u:hasdata("小喙恢复冷却") then
      u:curehp(u.handle, 0, 10, 2)
      u:settimedata("小喙恢复冷却", 5)
    end
    if u:hasdata("变异判定-枪之恶魔") then
      u:sendmessage("|cFF990000枪之恶魔-格挡规制|r")
      u:settimedata("枪之恶魔-格挡限制", 120)
      ac.wait(120000, function()
        u:sendmessage("|cFF990000枪之恶魔-格挡规制冷却完毕|r")
      end)
    end
    if u:hasdata("物品判定-双刃下弦月") and not u:hasdata("双刃下弦月-冷却") then
      u:settimedata("双刃下弦月-冷却", 1)
      local txsh = 500 * u:getlevel()
      DamageUnit({
        bj = "双刃下弦月",
        unit = soc.handle,
        source = u.handle,
        damage = txsh,
        level = 1,
        type = "物理",
        isvest = false,
        isattack = true,
        isnoarmor = false,
        element = "无",
        extradata = {""}
      })
    end
    if Keyan_Zhongshangdaodi then
      u:settimedata("科研模式-重伤倒地时间", 15)
    end
  end
  return sh
end
