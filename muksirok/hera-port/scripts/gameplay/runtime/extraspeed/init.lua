-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local Court = require("gameplay.var.pools.mwx.danwanlunpo_runtime")
local Fengyun = require("gameplay.var.pools.mwx.fengyun_runtime")
Ewys_02 = war3.CreateTrigger(function()
  local id = GetIssuedOrderIdBJ()
  if id ~= String2OrderIdBJ("coldarrows") and id ~= String2OrderIdBJ("carrionswarm") and id ~= String2OrderIdBJ("controlmagic") and id ~= String2OrderIdBJ("coupletarget") and id ~= 852002 and id ~= 852003 and id ~= 852004 and id ~= 852005 and id ~= 852006 and id ~= 852007 then
    local unit = GetTriggerUnit()
    local u = getunit(unit)
    local x, y = u:getxy()
    if GetOrderTargetUnit() == 0 and GetOrderTargetItem() == 0 then
      x = GetOrderPointX()
      y = GetOrderPointY()
    elseif GetOrderTargetItem() ~= 0 then
      x = GetItemX(GetOrderTargetItem())
      y = GetItemY(GetOrderTargetItem())
    else
      x = GetUnitX(GetOrderTargetUnit())
      y = GetUnitY(GetOrderTargetUnit())
    end
    ac.wait(1, function()
      u:setdata("位移点X", x)
      u:setdata("位移点Y", y)
    end)
  end
end)
Ewys_03 = war3.CreateTrigger(function()
  local id = GetIssuedOrderIdBJ()
  if id ~= String2OrderIdBJ("roar") then
    local unit = GetTriggerUnit()
    ac.wait(1, function()
      local u = getunit(unit)
      local x, y = u:getxy()
      u:setdata("位移点X", x)
      u:setdata("位移点Y", y)
    end)
  end
end)

local function angle_diff(a, b)
  local d = (a - b) % 360
  if 180 < d then
    d = d - 360
  end
  return d
end

local CountXs = 0.02
local CountTime = CountXs * 1000

local function init()
  ac.loop(CountTime, function()
    ForGroupLuaNew(Group_PlayHero, function(u)
      local sy = u.ownerid
      local player = u.owner
      Court.sample_move(u)
      Fengyun.sample_move(u)
      if u:isalive() and not u:hasdata("电影模式") and not u:hasdata("系统-已删模") and player ~= Player(PLAYER_NEUTRAL_PASSIVE) then
        local x, y = u:getxy()
        local ewys = HeroMenu_ExtraMoveSpeed[sy]
        ewys = ewys + 0.075 * u:getagi()
        if u:getdata("黄金体验") == 3 then
          ewys = ewys + 25
        end
        if u:hasdata("羁绊-浪客派对") and BGMIsChange then
          ewys = ewys + 25
        end
        if u:hasdata("变异判定-付丧神") then
          ewys = ewys + 25 + 0.1 * u:getdata("白面具数量")
        end
        if u:hasdata("物品-狂魔之理") then
          ewys = ewys + 100 * (100 - u:getperhp()) / 100
        end
        if u:ishasitem(Weapons["柴刀"]) and u:hasdata("变异判定-龙宫礼奈") then
          ewys = ewys + 25 + 0.025 * KillCount[sy]
        end
        if u:hasdata("利姆露-时间支配") then
          ewys = ewys + 500
        end
        if u:ishasbuff("B0AY") then
          ewys = ewys + 50
        end
        if u:hasdata("十六夜-月时记") then
          local add = 50 + 2 * u:getlevel()
          if u:hasdata("十六夜-StopWatch") then
            add = add * 2
          end
          ewys = ewys + add
        end
        if u:ishasitem("I06G") then
          ewys = ewys + 0.25 * GetItemCharges(u:getitem("I06G"))
        end
        if u:ishasitem("I058") then
          local add = 0.05 * u:getdata("魔力值")
          if 100 <= add then
            add = 100
          end
          ewys = ewys + add
        end
        if u:ishasitem("I08B") then
          ewys = ewys + 25
        end
        if u:ishasitem("I08S") then
          ewys = ewys + 25
        end
        if u.type == HeroType["秦心"] then
          if u:hasdata("秦心-哀伤逝去之面") then
            ewys = ewys + 66 * (1 + 0.05 * u:getlevel())
          else
            ewys = ewys + u:getdata("面具数量") * (1 + 0.05 * u:getlevel())
          end
        end
        if u.type == HeroType["狂三"] then
          ewys = ewys + 50 + 2 * u:getlevel() + 0.01 * u:getdata("时间点")
        end
        if u:getdata("刻1") == 1 then
          ewys = ewys + 25
        end
        if u:ishasitem("I04L") then
          ewys = ewys + 10 + u:getlevel() * 1
        end
        if u:ishasitem("I04D") then
          ewys = ewys + 25
        end
        if u:ishasitem("I06D") then
          ewys = ewys + 30 + u:getlevel() * 1
        end
        if u:hasdata("变异判定-幽灵鲨") then
          ewys = ewys + 25 + u:getlevel() * 0.25
        end
        if u:hasdata("玉藻前-永恒的约定") then
          ewys = ewys + 1 * u:getlevel()
        end
        if u:hasdata("夜夜-吹鸣") then
          ewys = ewys + 25 + 1 * u:getlevel()
        end
        if u:hasdata("圣白莲-游行圣") then
          ewys = ewys + 0.25 * GetUnitMoveSpeed(u.handle)
        end
        if u:hasdata("空白神化-收束法加速") then
          ewys = ewys + 75
        end
        if u:ishasskill("A0ZA") then
          ewys = ewys + 125
        end
        if u:ishasbuff("B0DU") then
          ewys = ewys + 50
        end
        if u:hasdata("洋流加速") then
          ewys = ewys + 50
          u:changedata("洋流加速特效", 1)
          if u:getdata("洋流加速特效") >= 15 then
            u:setdata("洋流加速特效", 0)
            Effectcreate("war3mapimported\\[ake]war3ake.com - 5467718799163621931506138.mdl", x, y)
          end
        end
        if u:hasdata("圣白莲-高速婆婆") and (GetTimeOfDay() >= 23 or 1 >= GetTimeOfDay()) then
          ewys = ewys + 500
        end
        if u:hasdata("摩托车马力") then
          ewys = ewys + u:getdata("摩托车马力")
        end
        do
          local bfb = HeroMenu_ExtraMoveSpeed_Bfb[sy]
          if u:hasdata("物品-狂魔之理") then
            bfb = bfb + 0.1 * (100 - u:getperhp()) / 100
          end
          if u:ishasbuff("B09F") then
            bfb = bfb + 0.04
          end
          if u:ishasbuff("B0DD") then
            bfb = bfb + 0.1
          end
          if 0 < u:getdata("风天层数") then
            bfb = bfb + 0.01 * u:getdata("风天层数")
          end
          if u:hasdata("深海猎人") and u:isingroup(Group_Hunter) then
            bfb = bfb + 0.03 * Group_Counts(Group_Hunter)
          end
          if u:hasdata("变异判定-秋穰子") then
            bfb = bfb + 0.005 * u:getdata("谷物神祝福次数")
          end
          if u:hasdata("东云心菜-量子态") then
            bfb = bfb + 0.5
          end
          ewys = ewys * bfb
          if u:hasdata("环境-交错次元") then
            ewys = ewys * 1.5
          end
          if not u:hasdata("变异判定-星莲华") and not u:hasdata("变异判定-人理之光") then
            if u:hasdata("变异判定-土蛛毒") and not u:hasdata("变异判定-雪女") and not u:hasdata("血统判定-妖魔之子") then
              ewys = ewys * 0.8
            end
            if u:ishasbuff("B01I") then
              ewys = ewys * 0.5
            end
            if 3 <= u:getdata("黑龙血统阶级") then
              ewys = ewys * 0.5
            end
            if u:hasbuff("睡眠") then
              ewys = ewys * 0.5
            end
            if u:hasbuff("冰冻") then
              ewys = ewys * 0.1
            end
            if u:hasbuff("麻痹") then
              ewys = ewys * 0.5
            end
            if u:ishasbuff("B091") then
              ewys = 0
            end
          end
          if u:hasdata("空白神化-外行人") and ewys >= GetUnitMoveSpeed(u.handle) then
            ewys = GetUnitMoveSpeed(u.handle)
          end
          if Boolean_ZhenhongBattle and Boss_Zhenhong ~= 0 then
            local boss = getunit(Boss_Zhenhong)
            if boss:hasdata("第三阶段开始") then
              if boss:hasdata("忍者帮助") then
                ewys = ewys / 2
              else
                ewys = 0
              end
            end
          end
          if u:hasdata("变异判定-健次郎") then
            ewys = 125
          end
        end
        if ewys < 0 then
          ewys = 0
        end
        if not (u:hasbuff("僵直") or u:hasbuff("缠绕") or u:ishasbuff("B08O") or u:ishasbuff("B096") or u:ishasbuff("B0AC") or u:hasdata("摩托车熄火") or u:hasdata("环境-死网")) and (not u:hasdata("变异判定-迷失之蝶") or u:hasdata("间桐樱-此世之恶")) or 0 < u:getdata("魔理沙-天翔层数") or u:hasdata("变异判定-星莲华") or u:hasdata("利姆露-禁忌化") or u:hasdata("神化判定-古明地恋") or u:hasdata("奥尔加-卡其脱离太") or u:hasdata("变异判定-神代の御神子") or u:hasdata("固有时御制加速") or u:hasdata("变异判定-人理之光") then
        else
          ewys = 0
        end
        if u:hasdata("系统-固有额外移速") then
          ewys = ewys + u:getdata("系统-固有额外移速")
        end
        if u:hasdata("遗物判定-AE86") then
          ewys = ewys + 800
        end
        if u:hasdata("神器判定-雨夜的迈巴赫") then
          ewys = ewys + 25
        end
        if u:hasdata("圣白莲-老妇人冲刺") then
          ewys = ewys + 1000
        end
        if u:hasdata("变异判定-LED初始") then
          ewys = ewys + 10
        end
        if u:hasdata("变异判定-破晓") then
          ewys = ewys + 40
        end
        if u:hasdata("变异判定-歼灭天使") then
          ewys = ewys + 244
        end
        if u:hasdata("花瓣-莉莉丝") then
          ewys = ewys + 15 + 0.5 * u:getlevel()
        end
        if Boolean_ZhenhongBattle and Boss_Zhenhong ~= 0 then
          local boss = getunit(Boss_Zhenhong)
          if boss:hasdata("次元闭锁启动") then
            ewys = 0
          end
        end
        if Nandu_Choose >= 5 and u:hasdata("系统-飞行状态") then
          ewys = ewys * 0.25
        end
        u:setdata("当前额外移速", ewys)
        if u:hasdata("固有时制御加速") and u:hasdata("切嗣-子弹时间") then
          ewys = ewys + 0.01
        end
        if ModeSelect_Muss then
          ewys = ewys * 0.1
        end
        if u:hasdata("世界之眼锁定") then
          ewys = ewys * 0.25
        end
        if u:hasdata("暗神-旧日凝视") then
          ewys = ewys * 0.1
        end
        if Keyan_Chuanshishizhen then
          ewys = ewys * 0.1
        end
        if u:hasbuff("暂停") then
          ewys = 0
        end
        u:setdata("当前显示额外移速", ewys)
        if 0 < ewys then
          local b = true
          if not (not u:hasdata("系统-关闭额外移速") and not u:hasdata("无极-破武") and not u:hasdata("茸茸-箭生效") and not u:hasdata("沉渊锁魂-封印移速") and not u:hasdata("暗神-无光之视") and not (0 < u:getdata("志贵连招暂停时间")) and not u:hasdata("变异判定-雷之律者") and not u:hasdata("爱丽丝-任务-红心女王") and (not u:hasdata("世界之眼锁定") or not (Nandu_Choose >= 5)) and not u:hasdata("次元闭锁锁定") and not u:hasdata("噩梦-降临") and not u:hasdata("狙击模式-开启") and not u:ishasskill("S013") and not u:istype("E00D") and (not u:hasdata("是否射击") or u:hasdata("固有时制御加速"))) or u:hasdata("弓箭系统-蓄力中") or 0 < u:getdata("妖梦连锁时间-ACWQ") or 0 < u:getdata("妖梦连锁时间-ACWQC") then
            b = false
          end
          if b then
            local dx = u:getdata("位移点X")
            local dy = u:getdata("位移点Y")
            if dx == 0 then
              dx = x
            end
            if dy == 0 then
              dy = y
            end
            local x2 = dx
            local y2 = dy
            local a = Atan2BJ(y2 - y, x2 - x)
            local dis = DistanceXY(x, y, x2, y2)
            local max = ewys
            local xs = 1
            if u:isingroup(SystemGroup_Battle) then
              xs = 0.25
              if u:hasdata("羁绊判定-RWBY") then
                xs = xs + 0.25
              end
              if u:hasdata("十六夜-月时记") then
                xs = xs + (1 - xs) * u:getdata("月时记-额外移速衰减减少")
              end
            end
            if u:hasdata("芙蕾雅-纯真之爱") or u:hasdata("琉紫-虚数时间") or u:hasdata("圣白莲-老妇人冲刺") or u:hasdata("神器判定-异次元术士") or u:hasdata("神器判定-卡其脱离太") and u:hasdata("奥尔加-卡其脱离太") then
              xs = 1
            end
            if u:hasdata("固有时制御加速") and u:hasdata("切嗣-子弹时间") then
              max = max + 500
            end
            max = max * xs
            u:setdata("当前显示额外移速", max)
            max = max * CountXs
            if dis >= max then
              dis = max
            end
            local ax, ay = x, y
            x, y = PolarXY(x, y, dis, a)
            if not IsXYInLimRECT(x, y) then
              x, y = ax, ay
            end
            if u:hasdata("圣白莲-老妇人冲刺") then
              u:changedata("老妇人冲刺-特效", 1)
              if 15 <= u:getdata("老妇人冲刺-特效") then
                Effectcreate("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", x, y)
                u:setdata("老妇人冲刺-特效", 0)
              end
              for _, xq in ac.selector():in_rangexy(x, y, 90):is_not(u.handle):ipairs() do
                xq = getunit(xq)
                if not xq:hasdata("高速婆婆碾压冷却") then
                  xq:settimedata("高速婆婆碾压冷却", 3)
                  local txsh = ewys * 500
                  if txsh < 0 then
                    txsh = 0
                  end
                  unitmove({
                    unit = xq.handle,
                    time = 1,
                    distance = GetRandomReal(ewys * 0.5, ewys * 1.5),
                    angle = AngleBetweenUnits(u.handle, xq.handle)
                  })
                  if xq:is_enemy(u.handle) then
                    DamageUnit({
                      bj = "高速婆婆碾压",
                      unit = xq.handle,
                      source = u.handle,
                      damage = txsh,
                      type = "震荡",
                      isattack = true
                    })
                  else
                    xq:losshp(u, 0, 0, GetRandomReal(1, 100))
                  end
                  xq:buffset(u.handle, 2, "眩晕")
                  xq:effectadd("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl")
                end
              end
            end
            if u:hasdata("利姆露-暴风之王") then
              for _, xq in ac.selector():in_rangexy(x, y, 90):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                local txsh = (GetUnitMoveSpeed(u.handle) + ewys - GetUnitMoveSpeed(xq.handle)) * 50
                if txsh < 0 then
                  txsh = 0
                end
                unitmove({
                  unit = u.handle,
                  time = 0.5,
                  distance = GetRandomReal(100, 500),
                  angle = AngleBetweenUnits(u.handle, xq.handle)
                })
                DamageUnit({
                  bj = "利姆露暴风之王",
                  unit = xq.handle,
                  source = u.handle,
                  damage = txsh,
                  type = "震荡"
                })
                xq:buffset(u.handle, 1, "眩晕")
                xq:effectadd("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl")
                if not xq:hasdata("暴风之王碾压冷却") then
                  xq:settimedata("暴风之王碾压冷却", 10)
                end
              end
            end
            if u:hasdata("遗物判定-AE86") or not u:hasdata("摩托车熄火") and u:hasdata("摩托车马力") then
              Effectcreate("Abilities\\Spells\\Items\\AIfb\\AIfbSpecialArt.mdl", x, y)
            end
            if u:hasdata("炭治郎-通透世界") then
              u:changedata("炭治郎-通透世界特效", 1)
              if 15 <= u:getdata("炭治郎-通透世界特效") then
                Effectcreate("Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl", x, y)
                u:setdata("炭治郎-通透世界特效", 0)
              end
            end
            if u:hasdata("闪刀姬-风") then
              u:changedata("闪刀姬-风特效", 1)
              if 15 <= u:getdata("闪刀姬-风特效") then
                Effectcreate("war3mapImported\\[ake]war3ake.com - 1819045376306725276640889.mdl", x, y)
                u:setdata("闪刀姬-风特效", 0)
              end
            end
            if 0.9 <= dis then
              u:setxy(x, y)
              if u["脚本位移后效果"] and 0 < #u["脚本位移后效果"] then
                local actual_x, actual_y = u:getxy()
                local actual_distance = DistanceXY(ax, ay, actual_x, actual_y)
                Court.sample_move(u, actual_distance)
                Fengyun.sample_move(u, actual_distance)
              end
            elseif dis ~= 0 then
              x, y = u:getxy()
              u:setdata("位移点X", x)
              u:setdata("位移点Y", y)
            end
          else
            u:setdata("当前显示额外移速", 0)
          end
        end
      end
    end)
  end)
end

init()
