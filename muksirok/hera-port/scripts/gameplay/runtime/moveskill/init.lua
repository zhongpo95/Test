-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local Moveskill = require("gameplay.runtime.moveskill.set")
local slk = require("jass.slk")
local MoveskillInput = {}
local move_trace = require("hera_move_trace")
local input_hooks = {}

function MoveskillInput.set_input_hook(ownerid, callback)
  input_hooks[ownerid] = callback
end

function MoveskillInput.clear_input_hook(ownerid, callback)
  if callback == nil or input_hooks[ownerid] == callback then
    input_hooks[ownerid] = nil
  end
end

local function notify_input(args, keyboard)
  local u = getunit(args.unit)
  local callback = input_hooks[u.ownerid]
  return callback ~= nil and callback(u, keyboard, args) == true
end

require("gameplay.runtime.moveskill.ban")
require("gameplay.runtime.moveskill.replace")

function moveskilltrg(args)
  for _, value in ipairs(Moveskill) do
    if args.skill == value.handle then
      if not notify_input(args, value.keyboard) then
        moveskill(args)
      end
      break
    end
  end
end

function moveskill(args)
  local unit = args.unit
  local skill = args.skill
  local x2, y2
  if args.x and args.y then
    x2 = args.x
    y2 = args.y
  end
  local u = getunit(unit)
  move_trace.note("BEGIN", u, "skill=" .. tostring(skill))
  local sy = u.ownerid
  local tilixh, name, keyboard, distance, sbt
  for i, value in ipairs(Moveskill) do
    if skill == value.handle or skill == value.name then
      skill = value.handle
      tilixh = value.tilixh
      name = value.name
      keyboard = value.keyboard
      distance = value.distance
      sbt = value.duckingtime
      break
    end
  end
  if not name then
    print("不存在的位移技能" .. skill)
    return
  end
  if u:hasbuff("缠绕") and name ~= "利姆露-Q" and (name ~= "卫宫切嗣-Q" and name ~= "卫宫切嗣-W" or not u:hasdata("切嗣-子弹时间")) then
    u:setskillcd(skill, 0.01)
    u:sendmessage("|cFFFF3300缠绕中|r")
    return
  end
  if (name == "Bloo-W" or name == "Bloo-Q") and u:ishasskill("S00C") then
    tilixh = tilixh * 0.5
  end
  if u:hasdata("少年德古拉-恶魔城步伐开启") then
    tilixh = tilixh * 0.1
  end
  if not u:hasdata("位移体力消耗标记") then
    if u:lossstamina(tilixh) then
      u:settimedata("位移体力消耗标记", 0.001)
      if name == "Bloo-W" or name == "Bloo-Q" then
        if u:ishasskill("S00C") then
          u:setskilldatareal(skill, "施法间隔", 0.6)
          local yx = {}
          yx[1] = Sound_Bloo_10
          yx[2] = Sound_Bloo_11
          u:playsound(yx[GetRandomInt(1, 2)])
          u:setskillcd("A1MB", 0)
        else
          u:setskilldatareal(skill, "施法间隔", 1)
        end
      end
    else
      u:setskillcd(skill, 0.01)
      u:sendmessage("|cFFFF3300体力值不足|r")
      if not u:hasdata("技能释放失败") then
        u:settimedata("技能释放失败", 0.05)
      end
      return
    end
  end
  local cirno_qw = u.type == HeroType["琪露诺"] and (keyboard == "Q" or keyboard == "W")
  if cirno_qw and u._cirno_qw_cancel then
    move_trace.note("REPLACE", u, "previous Q/W movement cancelled")
    local cancel = u._cirno_qw_cancel
    u._cirno_qw_cancel = nil
    cancel()
  end
  local time = 0.2
  local isblink = false
  local islock = false
  local isfly = false
  if u:hasdata("系统-飞行状态") then
    isfly = true
  end
  if u:getdata("天使-精灵阶级") >= 3 then
    isblink = true
  end
  local angle = u:getface()
  if keyboard == "Q" then
    angle = u:getface() + 180
  end
  if u:hasdata("少年德古拉-恶魔城步伐开启") then
    angle = u:getface()
  end
  local x, y = u:getxy()
  local lfunc = {}
  
  local function efunc()
  end
  
  if name == "冲刺-W" or name == "后跳-Q" or name == "冲刺-简单模式-W" or name == "后跳-简单模式-Q" then
    if u:getdata("绝对闪避时间") == 0 then
      if keyboard == "Q" then
        u:setdata("刷新Q时间", 0.2)
      else
        u:setdata("刷新W时间", 0.2)
      end
    end
    if u.type == HeroType["十六夜"] or u.type == HeroType["狂三"] or u.type == HeroType["里三"] then
      isblink = true
      distance = distance + 100
    end
    if u.type == HeroType["莲华"] or u.type == HeroType["白洲梓"] or u.type == HeroType["贝洛妮卡"] or u.type == HeroType["缇娜"] or u.type == HeroType["铃仙"] or u.type == HeroType["灵梦"] or u.type == HeroType["魔理沙"] or u.type == HeroType["爱丽丝"] or u.type == HeroType["蕾米"] or u.type == HeroType["圣白莲"] then
      Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
      if keyboard == "Q" then
        Effectcreate("war3mapImported\\nitu.mdl", x, y, 0.8, 1, 0, u:getface() + 180)
      end
    end
    lfunc = {
      {
        looptime = 0.04,
        func = function()
          x, y = u:getxy()
          if keyboard == "W" and (u.type == HeroType["莲华"] or u.type == HeroType["白洲梓"] or u.type == HeroType["贝洛妮卡"] or u.type == HeroType["缇娜"] or u.type == HeroType["铃仙"] or u.type == HeroType["灵梦"] or u.type == HeroType["魔理沙"] or u.type == HeroType["爱丽丝"] or u.type == HeroType["蕾米"] or u.type == HeroType["圣白莲"]) then
            Effectcreate("war3mapImported\\nitu.mdl", x, y, 0.8, 1, 0, u:getface())
          end
          if keyboard == "Q" and (u.type == HeroType["魔理沙"] or u.type == HeroType["爱丽丝"] or u.type == HeroType["蕾米"] or u.type == HeroType["圣白莲"]) then
            Effectcreate("war3mapImported\\nitu.mdl", x, y, 0.8, 1, 0, u:getface() + 180)
          end
        end
      }
    }
    
    function efunc()
      if u.type == HeroType["灵梦"] and keyboard == "Q" then
        Effectcreate("war3mapImported\\bbb.mdx", x, y)
      end
    end
  end
  if name == "玉藻前-Q" or name == "玉藻前-W" then
    if u:getdata("绝对闪避时间") == 0 then
      if keyboard == "Q" then
        u:setdata("刷新Q时间", 0.2)
      else
        u:setdata("刷新W时间", 0.2)
      end
    end
    u:playsound(Yuzaoqian_QW3)
    Effectcreate("Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl", x, y)
    if u.type == HeroType["十六夜"] or u.type == HeroType["狂三"] or u.type == HeroType["里三"] then
      isblink = true
      distance = distance + 100
    end
    if u.type == HeroType["莲华"] or u.type == HeroType["白洲梓"] or u.type == HeroType["贝洛妮卡"] or u.type == HeroType["缇娜"] or u.type == HeroType["铃仙"] or u.type == HeroType["灵梦"] or u.type == HeroType["魔理沙"] or u.type == HeroType["爱丽丝"] or u.type == HeroType["蕾米"] then
      Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
      if keyboard == "Q" then
        Effectcreate("war3mapImported\\nitu.mdl", x, y, 0.8, 1, 0, u:getface() + 180)
      end
    end
    lfunc = {
      {
        looptime = 0.04,
        func = function()
          x, y = u:getxy()
          if keyboard == "W" and (u.type == HeroType["莲华"] or u.type == HeroType["白洲梓"] or u.type == HeroType["贝洛妮卡"] or u.type == HeroType["缇娜"] or u.type == HeroType["铃仙"] or u.type == HeroType["灵梦"] or u.type == HeroType["魔理沙"] or u.type == HeroType["爱丽丝"] or u.type == HeroType["蕾米"] or u.type == HeroType["圣白莲"]) then
            Effectcreate("war3mapImported\\nitu.mdl", x, y, 0.8, 1, 0, u:getface())
          end
          if keyboard == "Q" and (u.type == HeroType["魔理沙"] or u.type == HeroType["爱丽丝"] or u.type == HeroType["蕾米"] or u.type == HeroType["圣白莲"]) then
            Effectcreate("war3mapImported\\nitu.mdl", x, y, 0.8, 1, 0, u:getface() + 180)
          end
          local txsh = 25 * u:getdata("灵基突破次数") * u:getstr()
          local txsh2 = 2222 + 22 * u:getdata("魔力值")
          for _, xq in ac.selector():in_rangexy(x, y, 200):is_enemy(unit):ipairs() do
            xq = getunit(xq)
            xq:buffset(unit, 0.4, "眩晕")
            DamageUnit({
              bj = "玉藻前位移",
              unit = xq.handle,
              source = u.handle,
              damage = txsh
            })
            xq:effectadd("Abilities\\Weapons\\BallistaMissile\\BallistaImpact.mdl", "chest")
            unitmove({
              unit = xq.handle,
              time = 0.4,
              distance = 200,
              angle = AngleBetweenUnits(unit, xq.handle)
            })
            if GetRandom100(10) then
              u:curemp(-1)
              u:playsound(Yuzaoqian_QW)
              DamageUnit({
                bj = "玉藻前位移",
                unit = xq.handle,
                source = u.handle,
                damage = txsh2,
                type = "魔力",
                isvest = true,
                isnoarmor = false
              })
            end
          end
        end
      }
    }
    
    function efunc()
      if u.type == HeroType["灵梦"] then
        Effectcreate("war3mapImported\\bbb.mdx", x, y)
      end
    end
  end
  if name == "犬走椛-Q" or name == "犬走椛-W" then
    if u:getdata("绝对闪避时间") == 0 then
      if keyboard == "Q" then
        u:setdata("刷新Q时间", 0.2)
      else
        u:setdata("刷新W时间", 0.2)
      end
    end
    u:playsound(Yuzaoqian_QW3)
    Effectcreate("Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl", x, y)
    if u.type == HeroType["十六夜"] or u.type == HeroType["狂三"] or u.type == HeroType["里三"] then
      isblink = true
      distance = distance + 100
    end
    if u.type == HeroType["莲华"] or u.type == HeroType["白洲梓"] or u.type == HeroType["贝洛妮卡"] or u.type == HeroType["缇娜"] or u.type == HeroType["铃仙"] or u.type == HeroType["灵梦"] or u.type == HeroType["魔理沙"] or u.type == HeroType["爱丽丝"] or u.type == HeroType["蕾米"] or u.type == HeroType["圣白莲"] then
      Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
      if keyboard == "Q" then
        Effectcreate("war3mapImported\\nitu.mdl", x, y, 0.8, 1, 0, u:getface() + 180)
      end
    end
    lfunc = {
      {
        looptime = 0.04,
        func = function()
          x, y = u:getxy()
          if keyboard == "W" and (u.type == HeroType["莲华"] or u.type == HeroType["白洲梓"] or u.type == HeroType["贝洛妮卡"] or u.type == HeroType["缇娜"] or u.type == HeroType["铃仙"] or u.type == HeroType["灵梦"] or u.type == HeroType["魔理沙"] or u.type == HeroType["爱丽丝"] or u.type == HeroType["蕾米"] or u.type == HeroType["圣白莲"]) then
            Effectcreate("war3mapImported\\nitu.mdl", x, y, 0.8, 1, 0, u:getface())
          end
          if keyboard == "Q" and (u.type == HeroType["魔理沙"] or u.type == HeroType["爱丽丝"] or u.type == HeroType["蕾米"] or u.type == HeroType["圣白莲"]) then
            Effectcreate("war3mapImported\\nitu.mdl", x, y, 0.8, 1, 0, u:getface() + 180)
          end
          for _, xq in ac.selector():in_rangexy(x, y, 200):is_enemy(unit):ipairs() do
            xq = getunit(xq)
            xq:buffset(unit, 0.4, "眩晕")
            unitmove({
              unit = xq.handle,
              time = 0.4,
              distance = 200,
              angle = AngleBetweenUnits(unit, xq.handle)
            })
          end
        end
      }
    }
    
    function efunc()
      if u.type == HeroType["灵梦"] then
        Effectcreate("war3mapImported\\bbb.mdx", x, y)
      end
    end
  end
  if name == "秋静叶-Q" then
    if u:getdata("绝对闪避时间") == 0 then
      if keyboard == "Q" then
        u:setdata("刷新Q时间", 0.2)
      else
        u:setdata("刷新W时间", 0.2)
      end
    end
    if u.type == HeroType["十六夜"] or u.type == HeroType["狂三"] or u.type == HeroType["里三"] then
      isblink = true
      distance = distance + 100
    end
    if u.type == HeroType["莲华"] or u.type == HeroType["白洲梓"] or u.type == HeroType["贝洛妮卡"] or u.type == HeroType["缇娜"] or u.type == HeroType["铃仙"] or u.type == HeroType["灵梦"] or u.type == HeroType["魔理沙"] or u.type == HeroType["爱丽丝"] or u.type == HeroType["蕾米"] or u.type == HeroType["圣白莲"] then
      Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
      if keyboard == "Q" then
        Effectcreate("war3mapImported\\nitu.mdl", x, y, 0.8, 1, 0, u:getface() + 180)
      end
    end
    lfunc = {
      {
        looptime = 0.04,
        func = function()
          x, y = u:getxy()
          if keyboard == "W" and (u.type == HeroType["莲华"] or u.type == HeroType["白洲梓"] or u.type == HeroType["贝洛妮卡"] or u.type == HeroType["缇娜"] or u.type == HeroType["铃仙"] or u.type == HeroType["灵梦"] or u.type == HeroType["魔理沙"] or u.type == HeroType["爱丽丝"] or u.type == HeroType["蕾米"] or u.type == HeroType["圣白莲"]) then
            Effectcreate("war3mapImported\\nitu.mdl", x, y, 0.8, 1, 0, u:getface())
          end
          if keyboard == "Q" and (u.type == HeroType["魔理沙"] or u.type == HeroType["爱丽丝"] or u.type == HeroType["蕾米"] or u.type == HeroType["圣白莲"]) then
            Effectcreate("war3mapImported\\nitu.mdl", x, y, 0.8, 1, 0, u:getface() + 180)
          end
        end
      }
    }
    
    function efunc()
      if u.type == HeroType["灵梦"] then
        Effectcreate("war3mapImported\\bbb.mdx", x, y)
      end
    end
  end
  if name == "Bloo-W" or name == "Bloo-Q" then
    u:setcolor(0, 0, 0, 255)
    local zs
    if name == "Bloo-W" then
      if GetRandom100(50) then
        zs = 18
      else
        zs = 29
      end
    elseif GetRandom100(50) then
      zs = 55
    else
      zs = 29
    end
    u:setdata("Bloo动作", zs)
    play_shadow_slow_series(u, {
      model = "HERO\\Bloo4.mdl",
      scale = 1.2,
      act = zs,
      count = 6,
      interval = 0.03,
      main_speed = 1,
      wait_time = 0,
      r = 0,
      g = 0,
      b = 125,
      fade_sub = 10,
      noact = true
    })
    
    function efunc()
      u:setcolor(255, 255, 255, 255)
    end
  end
  if name == "卫宫切嗣-Q" or name == "卫宫切嗣-W" then
    if u:getdata("绝对闪避时间") == 0 then
      if keyboard == "Q" then
        u:setdata("刷新Q时间", 0.1)
      else
        u:setdata("刷新W时间", 0.1)
      end
    end
    if keyboard == "W" then
      u:playsound(QS_W)
      u:playsound(QS_WE)
      Effectcreate("war3mapImported\\nitu.mdl", x, y, 0.8, 1, 0, u:getface())
    else
      u:playsound(QS_E)
      u:playsound(QS_E2)
      Effectcreate("war3mapImported\\nitu.mdl", x, y, 0.8, 1, 0, u:getface() + 180)
      Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
    end
    local xh = 7
    if u:hasdata("魔术师杀手-切嗣强化") then
      xh = 4
    end
    if u:hasdata("切嗣-决意状态") and u:getperhp() <= 5 then
      xh = 0
    end
    if xh ~= 0 then
      u:losshp(u, 0, xh)
    end
    if keyboard == "Q" then
      unifycreate({
        owner = unit,
        model = "war3mapImported\\sakuya_knife.mdl",
        modelname = "卫宫切嗣-飞刀",
        modelsize = 1,
        height = 75,
        damage = 2500 + 250 * u:getlevel(),
        damagetype = 2,
        range = 2000,
        speed = 5000,
        isvest = true,
        hitfunc = function(mj, damage)
          if u:hasdata("切嗣-固有时制御") then
            damage = damage * 2
          end
          return damage
        end,
        hitbeforefunc = function(mj, xq)
          u:setdata("伤害阶级", 2)
        end
      })
    elseif not u:hasdata("切嗣-扔手雷关闭") then
      local x3, y3 = u:getxy()
      Effectcreate("war3mapImported\\Thing_Shoulei.mdl", x3, y3, 1.5)
      ac.wait(1500, function()
        for i = 1, 8 do
          local x2, y2 = PolarXY(x3, y3, 150, i * 45)
          Effectcreate("Objects\\Spawnmodels\\Other\\NeutralBuildingExplosion\\NeutralBuildingExplosion.mdl", x2, y2)
        end
        local txsh = 15000
        if u:hasdata("隐藏职业-无貌之人揭露") then
          txsh = txsh * 2
        end
        local fw = 375
        for _, xq in ac.selector():in_rangexy(x3, y3, fw):ipairs() do
          xq = getunit(xq)
          local dx, dy = xq:getxy()
          local xs = 1 + (fw - DistanceXY(dx, dy, x3, y3)) / fw
          if xq:is_enemy(u.handle) then
            local dtxsh
            if xq:isnormal() then
              dtxsh = 0.1 * xq:getmaxhp()
            else
              dtxsh = 0.01 * xq:gethp()
            end
            DamageUnit({
              bj = "切嗣手雷",
              unit = xq.handle,
              source = u.handle,
              damage = txsh * xs + dtxsh,
              type = "震荡"
            })
            xq:buffset(u.handle, 1, "眩晕")
            if u:hasdata("隐藏职业-无貌之人揭露") or u:hasdata("变异判定-奈亚子") then
              xq:buffset(u.handle, 1, "混乱")
            end
            if u:hasdata("切嗣-魔术师杀手") then
              xq:settimedata("魔术师杀手破坏减伤", 3)
            end
          elseif not xq:hasdata("英雄-卫宫切嗣") then
            local dtxsh = 10 * xs
            LossHpUnit({
              u = u,
              tg = xq,
              damage = dtxsh,
              perhp = 0,
              maxhp = 0,
              bj = "[生命损耗]切嗣手雷"
            })
            xq:buffset(u.handle, 0.5 * xs, "眩晕")
            flytext({
              unit = xq.handle,
              text = "-" .. math.floor(dtxsh) .. "%",
              size = 10,
              time = 0.5,
              r = 255,
              g = 0,
              b = 0
            })
          end
        end
      end)
      if u:hasdata("切嗣-固有时制御") then
        ac.wait(150, function()
          local x3, y3 = u:getxy()
          Effectcreate("war3mapImported\\Thing_Shoulei.mdl", x3, y3, 1.5)
          ac.wait(1500, function()
            for i = 1, 8 do
              local x2, y2 = PolarXY(x3, y3, 150, i * 45)
              Effectcreate("Objects\\Spawnmodels\\Other\\NeutralBuildingExplosion\\NeutralBuildingExplosion.mdl", x2, y2)
            end
            local txsh = 15000
            local dxs = Damage_Touzhiwu[sy]
            local fw = 375
            for _, xq in ac.selector():in_rangexy(x3, y3, fw):ipairs() do
              xq = getunit(xq)
              local dx, dy = xq:getxy()
              local xs = dxs + (fw - DistanceXY(dx, dy, x3, y3)) / fw
              if xq:is_enemy(u.handle) then
                local dtxsh
                if xq:isnormal() then
                  dtxsh = 0.1 * xq:getmaxhp()
                else
                  dtxsh = 0.01 * xq:gethp()
                end
                DamageUnit({
                  bj = "切嗣手雷",
                  unit = xq.handle,
                  source = u.handle,
                  damage = txsh * xs + dtxsh,
                  type = "震荡"
                })
                xq:buffset(u.handle, 1, "眩晕")
                if u:hasdata("隐藏职业-无貌之人揭露") or u:hasdata("变异判定-奈亚子") then
                  xq:buffset(u.handle, 1, "混乱")
                end
                if u:hasdata("切嗣-魔术师杀手") then
                  xq:settimedata("魔术师杀手破坏减伤", 3)
                end
              elseif not xq:hasdata("英雄-卫宫切嗣") then
                local dtxsh = 10 * xs
                LossHpUnit({
                  u = u,
                  tg = xq,
                  damage = dtxsh,
                  perhp = 0,
                  maxhp = 0,
                  bj = "[生命损耗]切嗣手雷"
                })
                xq:buffset(u.handle, 0.5 * xs, "眩晕")
                flytext({
                  unit = xq.handle,
                  text = "-" .. math.floor(dtxsh) .. "%",
                  size = 10,
                  time = 0.5,
                  r = 255,
                  g = 0,
                  b = 0
                })
              end
            end
          end)
        end)
      end
    end
    local act, actspeed
    if keyboard == "W" then
      act = 4
      actspeed = 7
    else
      act = 3
      actspeed = 7
    end
    play_shadow_slow_series(u, {
      act = act,
      count = 10,
      interval = 0.015,
      main_speed = actspeed,
      wait_time = 0.05,
      r = 255,
      g = 0,
      b = 0,
      fade_sub = 5,
      noact = true
    })
  end
  if name == "赫萝-Q" or name == "赫萝-W" then
    time = 0.3
    if u:getdata("绝对闪避时间") == 0 then
      if keyboard == "Q" then
        u:setdata("刷新Q时间", 0.2)
      else
        u:setdata("刷新W时间", 0.2)
      end
    end
    u:playsound(bac1)
    if keyboard == "Q" then
      local yx = {}
      yx[1] = Sound_Heluo_07
      yx[2] = Sound_Heluo_12
      yx[3] = Sound_Heluo_14
      u:playsound(yx[GetRandomInt(1, 3)])
      Effectcreate("AATX\\[AATxNew]Dust11.mdl", x, y)
      Effectcreate("war3mapImported\\bbb.mdx", x, y)
      Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
      modelchange({
        unit = unit,
        model = "HERO\\horo.mdl",
        modelsize = 1,
        modelact = 6,
        modelactspeed = 2,
        time = 0.3,
        sfunc = function()
        end,
        efunc = function()
          Effectcreate("Abilities\\Spells\\Orc\\FeralSpirit\\feralspirittarget.mdl", x, y)
          Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
        end
      })
      local txsh = 5000 + 50 * u:getagi()
      for _, xq in ac.selector():in_rangexy(x, y, 475):is_enemy(unit):ipairs() do
        xq = getunit(xq)
        DamageUnit({
          bj = "赫萝位移",
          unit = xq.handle,
          source = u.handle,
          damage = txsh,
          type = "物理",
          isnoarmor = false
        })
        xq:buffset(unit, 0.3, "僵直")
      end
    else
      local yx = {}
      yx[1] = Sound_Heluo_10
      yx[2] = Sound_Heluo_11
      yx[3] = Sound_Heluo_13
      yx[4] = Sound_Heluo_14
      yx[5] = Sound_Heluo_15
      yx[6] = Sound_Heluo_17
      yx[7] = Sound_Heluo_12
      yx[8] = Sound_Heluo_07
      u:playsound(yx[GetRandomInt(1, 8)])
      modelchange({
        unit = unit,
        model = "HERO\\horo.mdl",
        modelsize = 1,
        modelact = 4,
        modelactspeed = 2,
        time = 0.3,
        sfunc = function()
        end,
        efunc = function()
          Effectcreate("Abilities\\Spells\\Orc\\FeralSpirit\\feralspirittarget.mdl", x, y, 0, 1.5)
          local x2, y2 = PolarXY(x, y, 50, u:getface())
          Effectcreate("AATX\\[AATxNew]Dust15.mdl", x2, y2)
          u:playsound(Midouzi_2)
          local txsh = 7500 + 50 * u:getstr()
          for _, xq in ac.selector():in_rangexy(x2, y2, 300):is_enemy(unit):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              bj = "赫萝位移",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              type = "物理",
              isnoarmor = false
            })
            xq:buffset(unit, 0.5, "僵直")
          end
        end
      })
      Effectcreate("Abilities\\Spells\\Orc\\FeralSpirit\\feralspirittarget.mdl", x, y)
      Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
      Effectcreate("war3mapImported\\nitu.mdl", x, y, 0, 1, 0, u:getface() + 180)
    end
  end
  if name == "利姆露-Q" or name == "利姆露-W" then
    if u:getdata("绝对闪避时间") == 0 and keyboard == "W" then
      u:setdata("刷新W时间", 0.2)
    end
    if keyboard == "Q" then
      time = 0.5
      u:buffset(unit, 0.45, "暂停")
      u:playsound(bac1)
      u:playsound(Sound_Time_10)
      u:playsound(Sound_Lingshimizi)
      Effectcreate("AATX\\[AATxNew]Blue25.mdl", x, y, 1, 5)
      Effectcreate("AATX\\[AATxNew]Blue10.mdl", x, y, 1, 4)
      u:effectadd("ATX\\[ATxNew]Light_16.mdl")
      local tx = Effectcreate("AATX\\[AATxNew]Animate40.mdl", x, y, -1, 2)
      ac.wait(1000, function()
        japi.EXSetEffectSize(tx, 0.01)
        DestroyEffectLua(tx)
      end)
      for _, xq in ac.selector():in_rangexy(x, y, 800):is_enemy(unit):ipairs() do
        xq = getunit(xq)
        xq:buffset(unit, 1, "暂停")
        xq:animespeed(0)
        ac.wait(1000, function()
          xq:animespeed(1)
        end)
      end
    else
      u:playsound(QS_WE)
      Effectcreate("AATX\\[AATxNew]Dust11.mdl", x, y)
      Effectcreate("AATX\\[AATxNew]Black09.mdl", x, y)
      
      function efunc()
        x, y = u:getxy()
        Effectcreate("war3mapImported\\bbb.mdl", x, y)
        Effectcreate("AATX\\[AATxNew]Black09.mdl", x, y)
        Effectcreate("AATX\\[AATxNew]Blue22.mdl", x, y, 0, 0.5)
        for _, xq in ac.selector():in_rangexy(x, y, 325):is_enemy(unit):ipairs() do
          xq = getunit(xq)
          xq:buffset(unit, 0.6, "僵直")
        end
      end
    end
  end
  if name == "空之律者-Q" or name == "空之律者-W" then
    isblink = true
    x, y = u:getxy()
    distance = DistanceXY(x, y, x2, y2)
    angle = AngleXY(x, y, x2, y2)
    if distance >= 1800 then
      distance = 1800
    end
    Effectcreate("Abilities\\Spells\\Human\\MassTeleport\\MassTeleportCaster.mdl", x, y)
    Effectcreate("Abilities\\Spells\\Human\\MassTeleport\\MassTeleportCaster.mdl", x2, y2)
    Effectcreate("war3mapImported\\dead spirit by deckai2.mdx", x, y)
    Effectcreate("war3mapImported\\dead spirit by deckai2.mdx", x2, y2)
    Effectcreate("war3mapImported\\yellow field.mdx", x, y, 1)
    for _, xq in ac.selector():in_rangexy(x, y, 325):is_enemy(unit):ipairs() do
      xq = getunit(xq)
      if not xq:isboss() then
        xq:buffset(unit, 1, "暂停")
      end
    end
  end
  if name == "冲田总司-Q" or name == "冲田总司-W" then
    u:buffset(u.handle, 0.25, "绝对闪避")
    if 2 > u:getdata("冲田总司-缩地次数") then
      u:changedata("冲田总司-缩地次数", 1)
    end
    return
  end
  if name == "忍野忍-W" then
    u:setcolor(255, 255, 255, 0)
    local tx = Effectcreate("Abilities\\Spells\\Human\\CloudOfFog\\CloudOfFog.mdl", x, y, 0.25)
    ac.timer(30, 8, function()
      local x, y = u:getxy()
      SetEffectXY(tx, x, y)
    end)
    ac.wait(250, function()
      u:setcolor(255, 255, 255, 255)
      u:setdata("忍野忍-瞬移次数", 2)
    end)
  end
  if name == "忍野忍-Q" then
    if u:getdata("绝对闪避时间") == 0 then
      u:setdata("刷新Q时间", 0.35)
    end
    local dx, dy = x, y
    local mj = u:createunit("o00E", dx, dy, u:getface())
    local txsh = u:getdata("忍野忍-甜食值")
    mj:setmaxhp(1 + txsh)
    mj:sethp(100, true)
    local cs = 0
    ac.loop(250, function(timer)
      cs = cs + 1
      Effectcreate("ZK_TTQ2.mdx", dx, dy, 0, 2, 75, GetRandomAngle())
      for _, xq in ac.selector():in_rangexy(dx, dy, 400):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        DamageUnit({
          bj = "忍野忍位移",
          unit = xq.handle,
          source = u.handle,
          damage = txsh,
          level = 1,
          type = "魔力",
          isvest = true,
          isattack = false,
          isnoarmor = false,
          element = "无",
          extradata = {""}
        })
        u:getdata("忍野忍-甜腻施加")(xq, 1)
      end
      if cs == 4 then
        Effectcreate("ZK_TTQ2.mdx", dx, dy, 0, 2, 75, GetRandomAngle())
        for _, xq in ac.selector():in_rangexy(dx, dy, 400):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          xq:buffset(u.handle, 1, "眩晕")
          u:getdata("忍野忍-甜腻施加")(xq, 1)
        end
        mj:remove()
        timer:remove()
      end
    end)
  end
  if name == "七夜志贵-W" then
    u:buffset(u.handle, 0.1, "绝对闪避")
    u:setdata("闪走水月")
    if u:getdata("绝对闪避时间") == 0 then
      u:setdata("刷新W时间", 0.1)
    end
    return
  end
  if name == "七夜志贵-Q" then
    isblink = true
    if u:getdata("绝对闪避时间") == 0 then
      u:setdata("刷新Q时间", 0.2)
    end
    play_shadow_slow_series(u, {
      act = 6,
      count = 1,
      interval = 0.01,
      main_speed = 2,
      wait_time = 0,
      r = 255,
      g = 255,
      b = 255,
      fade_sub = 8,
      noact = true
    })
    Effectcreate("Abilities\\Spells\\Items\\AIil\\AIilTarget.mdl", x, y)
    if Boolean_Wj_Xiuluolingyu then
      unitmove({
        unit = unit,
        time = time,
        distance = distance,
        isfly = isfly,
        angle = angle,
        startfunc = function()
          movexg(unit, sbt, skill, keyboard, name)
        end,
        loops = lfunc,
        endfunc = function()
          efunc()
          x, y = u:getxy()
          u:setdata("位移点X", x)
          u:setdata("位移点Y", y)
        end,
        islock = islock,
        isblink = isblink
      })
    else
      u:settimedata("极死七夜", 0.13)
      ac.wait(130, function()
        unitmove({
          unit = unit,
          time = time,
          distance = distance,
          isfly = isfly,
          angle = angle,
          startfunc = function()
            movexg(unit, sbt, skill, keyboard, name)
          end,
          loops = lfunc,
          endfunc = function()
            efunc()
            x, y = u:getxy()
            u:setdata("位移点X", x)
            u:setdata("位移点Y", y)
          end,
          islock = islock,
          isblink = isblink
        })
      end)
    end
    return
  end
  ResetUnitAnimation(u.handle)
  if u.type == HeroType["十六夜"] then
    u:animeact(7)
    if isblink then
      Effectcreate("Abilities\\Spells\\NightElf\\Blink\\BlinkTarget.mdl", x, y)
      play_shadow_slow_series(u, {
        model = "war3mapImported\\SLY.mdl",
        act = 6,
        count = 1,
        interval = 0.01,
        main_speed = 2,
        wait_time = 0,
        r = 255,
        g = 255,
        b = 255,
        fade_sub = 5,
        noact = true
      })
    end
  end
  if u.type == HeroType["狂三"] then
    u:animeact(7)
    if isblink then
      Effectcreate("war3mapImported\\K3_Tx (2).mdx", x, y)
      local cs = 0
      ac.loop(10, function(t)
        cs = cs + 1
        u:setcolor(255, 255, 255, 5 + 5 * cs)
        if cs == 50 then
          t:remove()
        end
      end)
    end
  end
  if u.type == HeroType["里三"] then
    u:animeact(7)
    if isblink then
      Effectcreate("effect\\Hero\\K3_2 (3).mdl", x, y)
      local cs = 0
      ac.loop(10, function(t)
        cs = cs + 1
        u:setcolor(255, 255, 255, 5 + 5 * cs)
        if cs == 50 then
          t:remove()
        end
      end)
    end
  end
  ac.wait(1, function()
    if u.type == HeroType["圣白莲"] then
      u:animespeed(2)
      if keyboard == "Q" then
        u:animeact(6)
      else
        u:animeact(8)
      end
    end
    if u.type == HeroType["莲华"] then
      u:animespeed(2)
      if keyboard == "Q" then
        u:animeact("spell")
      else
        u:animeact("walk")
      end
    end
    if u.type == HeroType["缇娜"] then
      u:animespeed(2)
      u:animeact("spell six")
    end
    if u.type == HeroType["铃仙"] then
      u:animespeed(2)
      if keyboard == "Q" then
        u:animeact(8)
      else
        u:animeact(5)
      end
    end
    if u.type == HeroType["灵梦"] then
      if unit == Bolilingmeng then
        if keyboard == "W" then
          u:changedata("灵梦W音效冷却", 1)
          if u:getdata("灵梦W音效冷却") > 4 then
            u:setdata("灵梦W音效冷却", 0)
            u:playsound(Lingmeng_Q)
          end
        else
          u:changedata("灵梦Q音效冷却", 1)
          if 4 < u:getdata("灵梦Q音效冷却") then
            u:setdata("灵梦Q音效冷却", 0)
            u:playsound(Lingmeng_W)
          end
        end
      end
      u:animespeed(2)
      if keyboard == "W" then
        u:animeact(6)
      else
        u:animeact(7)
      end
    end
    if u.type == HeroType["魔理沙"] then
      if keyboard == "W" then
        u:animeact(5)
      else
        u:animeact(6)
      end
    end
    if u.type == HeroType["爱丽丝"] then
      if keyboard == "W" then
        u:animeact(6)
        u:animespeed(2)
      else
        u:animeact(7)
      end
    end
    if u.type == HeroType["蕾米"] then
      u:animespeed(2)
      if keyboard == "W" then
        u:animeact(6)
      else
        u:animeact(10)
      end
    end
    if u.type == HeroType["白洲梓"] then
      if keyboard == "Q" then
        u:animeact(12)
        u:animespeed(2)
      end
      if keyboard == "W" then
        u:animeact(14)
        u:animespeed(2)
      end
    end
    if u.type == HeroType["贝洛妮卡"] then
      if keyboard == "Q" then
        u:animeact(6)
        u:animespeed(2)
      end
      if keyboard == "W" then
        u:animeact(6)
        u:animespeed(2)
      end
    end
    if u.type == HeroType["切嗣"] then
      if keyboard == "W" then
        u:animeact(4)
        u:animespeed(7)
      else
        u:animeact(3)
        u:animespeed(7)
      end
    end
  end)
  move_trace.note("MOVE", u, "angle=" .. tostring(angle) .. " distance=" .. tostring(distance) .. " time=" .. tostring(time))
  if cirno_qw then
    require("hera_gameplay_diagnostic").monster("QW_ORIGINAL_MOVE", {unit=unit, key=keyboard, distance=distance, duration=time, angle=angle, blink=isblink, coordinate_apply=not islock})
  end
  local cancel_move = unitmove({
    unit = unit,
    time = time,
    distance = distance,
    isfly = isfly,
    angle = angle,
    startfunc = function()
      local diagnostic = cirno_qw and require("hera_gameplay_diagnostic")
      if diagnostic then diagnostic.monster("QW_COMMON_BEGIN", {unit=unit, key=keyboard}) end
      movexg(unit, sbt, skill, keyboard, name, cirno_qw)
      if diagnostic then diagnostic.monster("QW_COMMON_END", {unit=unit, key=keyboard}) end
    end,
    loops = lfunc,
    endfunc = function()
      if cirno_qw then u._cirno_qw_cancel = nil end
      move_trace.note("END", u, "")
      efunc()
      x, y = u:getxy()
      u:animespeed(1)
      u:setdata("位移点X", x)
      u:setdata("位移点Y", y)
      if cirno_qw then require("hera_gameplay_diagnostic").monster("QW_ORIGINAL_END", {unit=unit, key=keyboard, x=x, y=y}) end
      if isblink then
        if u.type == HeroType["十六夜"] then
          Effectcreate("Abilities\\Spells\\NightElf\\Blink\\BlinkTarget.mdl", x, y)
        end
        if u.type == HeroType["狂三"] then
          Effectcreate("war3mapImported\\K3_Tx (2).mdx", x, y)
        end
        if u.type == HeroType["里三"] then
          Effectcreate("effect\\Hero\\K3_2 (3).mdl", x, y)
        end
      end
    end,
    islock = islock,
    isblink = isblink
  })
  if cirno_qw then u._cirno_qw_cancel = cancel_move end
end

function movexg(unit, t, skill, keyboard, name, diagnostic_cirno_qw)
  local diagnostic = diagnostic_cirno_qw and require("hera_gameplay_diagnostic")
  local u = getunit(unit)
  local x, y = u:getxy()
  local sy = u.ownerid
  local jw = keyboard
  local wqlx = Hero_Equip_WeaponType[sy]
  local lx = GetData(GetData(wqlx, "绑定技能"), "近战技能类型")
  local t2 = 0
  if u:hasdata("缇娜天赋-极限反应神经") or u:hasdata("愚者-小丑") or u:hasdata("空-行为预测") or u:hasdata("变异判定-黄金体验镇魂曲") or u:getdata("天使-精灵阶级") >= 4 then
    t2 = 0.05
  end
  if u:hasdata("乾神招来突强化") or u:hasdata("变异判定-明智吾郎") then
    t2 = 0.075
  end
  if u:hasdata("物品-狂魔之理") or getunit(BOSS):hasdata("真红-金色翎羽") then
    t2 = 0
  end
  if u:hasdata("神器判定-异次元术士") then
    t = t + 0.2
  end
  t = t + t2
  if u:hasdata("神化判定-灾祸魔神") and u:getdata("灾祸等级") >= 3 then
    t = t + 0.1
  end
  HeroMenuShow_Jdsbzj[sy] = t
  if Boolean_Jinselingyu and 0.3 <= t then
    t = 0.3
  end
  if u:hasdata("少年德古拉-恶魔城步伐开启") then
    t = t * 0.2
  end
  if diagnostic then diagnostic.monster("QW_EVASION_BEGIN", {unit=unit, key=keyboard, duration=t, remaining=u:getdata("绝对闪避时间")}) end
  u:buffset(unit, t, "绝对闪避")
  if diagnostic then diagnostic.monster("QW_EVASION_END", {unit=unit, key=keyboard, remaining=u:getdata("绝对闪避时间")}) end
  if u:hasdata("BOSS空间-黑洞封锁") then
    return
  end
  if type(skill) == "string" then
    skill = S2ID(skill)
  end
  local cd = tonumber(slk.ability[ID2S(skill)].Cool1)
  if (name == "卫宫切嗣-Q" or name == "卫宫切嗣-W") and u:hasdata("切嗣-固有时制御") then
    cd = 0.5
  end
  if (name == "妖梦-前冲" or name == "妖梦-后撤") and u:hasdata("妖梦天赋-狱界剑") then
    cd = 1
  end
  local cddown = 0
  local cdchange = 1
  if u:hasdata("隐藏职业-江湖大侠") then
    cddown = cddown + 0.1
  end
  if u:hasdata("神器判定-假发") then
    cddown = cddown + 0.1
  end
  if u:hasdata("白洲梓-格罗兹尼的壁垒") and u:hasdata("白洲梓-适应性绿") then
    cddown = cddown + 0.2
  end
  if u:hasdata("缇娜天赋-极限反应神经") then
    cddown = cddown + 0.3
  end
  if u:hasdata("变异判定-塞缪尔") then
    cdchange = cdchange * 0.75
  end
  if u:hasdata("变异判定-月下初拥") then
    cdchange = cdchange * 0.75
  end
  if u:hasdata("变异判定-斯巴达之子") then
    if u:hasdata("位移强化-维吉尔") then
      cdchange = cdchange * 0.5
    end
    if u:hasdata("位移强化-但丁") then
      cdchange = cdchange * 0.75
    end
  end
  if u:hasdata("变异判定-噩梦志贵") then
    cdchange = cdchange * 0.5
  end
  if u:hasdata("变异判定-雷之律者") then
    cdchange = cdchange * 0.75
  end
  if u:hasdata("少年德古拉-恶魔城步伐开启") then
    cdchange = cdchange * 0.1
    if GetRandom100(80) then
      u:playsound(Sound_Cangzhen_02)
    else
      local yxz = {
        Sound_Cangzhen_01,
        Sound_Cangzhen_03
      }
      u:playsound(yxz[GetRandomInt(1, 2)])
    end
  end
  if name == "利姆露-Q" then
    cddown = 0
    cdchange = 1
  end
  cd = cd - cddown
  if cd <= 0 then
    cd = 0
  end
  if name ~= "冲田总司-缩地" and name ~= "七夜志贵-冲刺" then
    u:setskillcd(skill, cd * cdchange, diagnostic_cirno_qw and {key=keyboard} or nil)
  end
  if diagnostic then diagnostic.monster("QW_POST_EFFECTS_BEGIN", {unit=unit, key=keyboard, cd=cd}) end
  StexiaoFunc({
    text = "位移技能后效果",
    unit = unit,
    u = u,
    sy = sy,
    t = t,
    cd = cd,
    lx = lx,
    jw = jw,
    wqlx = wqlx,
    name = name,
    diagnostic_cirno_qw = diagnostic_cirno_qw
  })
  if diagnostic then diagnostic.monster("QW_POST_EFFECTS_END", {unit=unit, key=keyboard}) end
  if diagnostic then diagnostic.monster("QW_DIRECT_EFFECTS_BEGIN", {unit=unit, key=keyboard}) end
  if u:hasdata("变异判定-白鹭公主") then
    u:setdata("白鹭公主-冰华时间", 5)
    if not u:hasdata("白鹭公主-语音冷却") then
      u:setdata("白鹭公主-语音冷却", 10)
      local yxz = {
        Sound_Sllh_01,
        Sound_Sllh_02,
        Sound_Sllh_03
      }
      u:playseensound(yxz[GetRandomInt(1, 3)])
    end
    u:effectadd("Abilities\\Weapons\\ZigguratMissile\\ZigguratMissile.mdl", "hand left", 5)
    u:effectadd("linhua_chixu.mdl", "origin", 5)
    Effectcreate("linghua_binghua.mdl", x, y)
    for _, xq in ac.selector():in_rangexy(x, y, 250):is_enemy(unit):ipairs() do
      xq = getunit(xq)
      xq:buffset(unit, 1, "冰冻")
    end
  end
  if u:hasdata("变异判定-犬夜叉") then
    if u:hasdata("犬夜叉-连招FAA") and jw == "W" then
      u:deldata("犬夜叉-连招FAA")
      u:setdata("犬夜叉-连招时间", 2)
      u:banskill("A1HN")
      u:banskill("A1JV", false)
      ac.wait(500, function()
        u:banskill("A1HN", false)
        u:banskill("A1JV")
      end)
    end
    if u:hasdata("犬夜叉-连招FA") and jw == "W" then
      u:deldata("犬夜叉-连招FA")
      u:setdata("犬夜叉-连招FAW")
      u:setdata("犬夜叉-连招时间", 1)
    end
    if u:hasdata("犬夜叉-连招FAWA") and jw == "Q" then
      u:deldata("犬夜叉-连招FAWA")
      u:setdata("犬夜叉-连招时间", 0.1)
      u:banskill("A1HN")
      u:banskill("A1JW", false)
      ac.wait(500, function()
        u:banskill("A1HN", false)
        u:banskill("A1JW")
      end)
    end
    if u:hasdata("犬夜叉-连招AEAF") and jw == "Q" then
      u:deldata("犬夜叉-连招AEAF")
      u:setdata("犬夜叉-连招AEAFQ")
      u:setdata("犬夜叉-连招时间", 1)
    end
    if u:hasdata("犬夜叉-连招AEAFQ") and jw == "W" then
      u:deldata("犬夜叉-连招AEAFQ")
      u:setdata("犬夜叉-连招时间", 0.1)
      u:banskill("A1HN")
      u:banskill("A0CX", false)
      ac.wait(500, function()
        u:banskill("A1HN", false)
        u:banskill("A0CX")
      end)
    end
  end
  if u:hasdata("命运-骨折") then
    u:curemp(-2)
  end
  if u:hasdata("伊芙-公主抱加成") then
    if unit == Qiyue_Kldy_Zs then
      getunit(Qiyue_Kldy_Mb):buffset(unit, t, "绝对闪避")
    else
      getunit(Qiyue_Kldy_Zs):buffset(unit, t, "绝对闪避")
    end
  end
  if u:hasdata("朱雀院椿-禁忌化") then
    u:settimedata("椿-浴火鸟位移", 0.5)
  end
  if u:hasdata("变异判定-喵露露") and not u:hasdata("喵露露-猫翻滚冷却") then
    u:settimedata("喵露露-猫翻滚冷却", 1)
    ac.wait(100, function()
      u:settimedata("喵露露-猫翻滚", 0.5)
    end)
  end
  if u:hasdata("威蕾丝-怪力冷却") then
    u:deldata("威蕾丝-怪力冷却")
  end
  if u:hasdata("朱雀院椿-禁忌化") then
    if jw == "Q" then
      u:playsound(Sound_Chun_21)
      local txsh = 88 * u:getallattri()
      unifycreate({
        owner = u.handle,
        model = "0Tx\\0Tx_Chun (7).mdl",
        modelname = "浴火鸟",
        modelsize = 1.5,
        height = 25,
        damage = txsh,
        damagetype = 6,
        time = 1,
        speed = 2500,
        volume = 150,
        angle = u:getface(),
        angleoffset = 0,
        attenua = 1,
        attenuacount = 999,
        life = 10,
        isbullet = false,
        isvest = false,
        isignorearmor = false,
        hitbeforefunc = function(mj, xq, damage2)
          mj:setdata("属性伤害", "火")
        end
      })
    end
    if jw == "W" and not u:hasdata("椿-火之迦俱土命") then
      u:settimedata("椿-火之迦俱土命", 0.5)
    end
  end
  if u:hasdata("遗物-和平鸽数量") and jw == "W" then
    local ys = 50 * u:getdata("遗物-和平鸽数量")
    u:effectadd("Abilities\\Spells\\Items\\AIsp\\SpeedTarget.mdl", "origin", 2)
    ChangeTimeValue(HeroMenu_ExtraMoveSpeed, sy, ys, 2)
  end
  if u:hasdata("变异判定-白") then
    if Weiyi_Dz[27] then
      getunit(Danwei_Blank_Kong):buffset(unit, t, "绝对闪避")
    end
    u:changetimedata("闪避值", 10, 5)
  end
  if u:hasdata("变异判定-空") and Weiyi_Dz[28] then
    getunit(Danwei_Blank_Bai):buffset(unit, t, "绝对闪避")
  end
  if u:hasdata("窥星-夜晚判定") and not u:hasdata("星辰之舞冷却") then
    u:settimedata("星辰之舞冷却", 1.2)
    local add = 0.06 * u:getdata("星座数")
    ChangeTimeValue(DamageSystem_Shjc, sy, 0.1 * add, 12)
  end
  local b2 = false
  if u:hasdata("变异判定-炭治郎") and lx == 10 then
    for _, xq in ac.selector():in_rangexy(x, y, 500):is_enemy(unit):ipairs() do
      if u:lossstamina(1) then
        u:effectadd("war3mapImported\\[AKE]war3AKE.com - 7943684402387183062488748.mdl")
        b2 = true
      end
      break
    end
  end
  if skill == S2ID("A14I") and u:hasdata("礼奈-黑化状态") then
    b2 = true
  end
  if skill == S2ID("A14H") and u:hasdata("礼奈-黑化状态") then
    b2 = true
  end
  if b2 then
    u:useweapon()
  end
  if not b2 and u:hasdata("变异判定-莉可莉丝") then
    if jw == "Q" then
      u:setskillcd(u:getdata("位移技能-W"), 0)
      u:curetili(-u:getdata("千束-Q体力消耗"))
      u:changedata("千束-W体力消耗", 1)
      ac.wait(2000 + u:getdata("千束-W体力消耗") * 1000, function()
        u:changedata("千束-W体力消耗", -1)
        if u:getdata("千束-W体力消耗") < 0 then
          u:setdata("千束-W体力消耗", 0)
        end
      end)
    else
      u:setskillcd(u:getdata("位移技能-Q"), 0)
      u:curetili(-u:getdata("千束-W体力消耗"))
      u:changedata("千束-Q体力消耗", 1)
      ac.wait(2000 + u:getdata("千束-Q体力消耗") * 1000, function()
        u:changedata("千束-Q体力消耗", -1)
        if u:getdata("千束-Q体力消耗") < 0 then
          u:setdata("千束-Q体力消耗", 0)
        end
      end)
    end
  end
  if u:ishasskill(SKILL_TESHUYINGXIONG) and u:hasdata("变异判定-鬼灭之刃") then
    local txsh = 250 * u:getlevel()
    u:effectadd("war3mapImported\\[AKE]war3AKE.com - 7943684402387183062488748.mdl")
    for _, xq in ac.selector():in_rangexy(x, y, 275):is_enemy(unit):ipairs() do
      xq = getunit(xq)
      DamageUnit({
        bj = "鬼灭之刃位移",
        unit = xq.handle,
        source = u.handle,
        damage = 1.5 * txsh,
        type = "物理",
        isnoattack = true
      })
      xq:buffset(unit, 0.5, "眩晕")
    end
  end
  if u:hasdata("少年德古拉-恶魔城步伐开启") and not u:hasdata("恶魔城步伐冷却") then
    local cs = 0
    ac.loop(40, function(timer)
      cs = cs + 1
      x, y = u:getxy()
      for _, xq in ac.selector():in_rangexy(x, y, 150):is_enemy(unit):ipairs() do
        xq = getunit(xq)
        u:useweapon()
        u:settimedata("恶魔城步伐冷却", 1)
        break
      end
      if cs == 5 or u:hasdata("恶魔城步伐冷却") then
        timer:remove()
      end
    end)
  end
  if u:hasdata("变异判定-漆黑的子弹") then
    local txsh = 250 * u:getlevel()
    local cs = 0
    local g = CreateGroupLua()
    ac.loop(40, function(timer)
      cs = cs + 1
      x, y = u:getxy()
      for _, xq in ac.selector():in_rangexy(x, y, 200):is_enemy(unit):isnotingroup(g):ipairs() do
        xq = getunit(xq)
        xq:groupadd(g)
        DamageUnit({
          bj = "漆黑子弹位移",
          unit = xq.handle,
          source = u.handle,
          damage = txsh,
          type = "物理",
          isnoattack = true,
          extradata = {"近战"}
        })
        xq:buffset(unit, 1, "眩晕")
        unitmove({
          unit = xq.handle,
          time = 0.4,
          distance = GetRandomReal(100, 200),
          angle = AngleBetweenUnits(unit, xq.handle)
        })
      end
      if cs == 5 then
        timer:remove()
      end
    end)
  end
  if u:hasdata("缇娜天赋-枪斗术贝塔") then
    if not u:hasdata("枪斗术β沙鹰破抗") then
      ac.loop(10, function(timer)
        u:changedata("枪斗术β沙鹰破抗", -0.01)
        if u:getdata("枪斗术β沙鹰破抗") <= 0 then
          u:deldata("枪斗术β沙鹰破抗")
          timer:remove()
        end
      end)
    end
    u:setdata("枪斗术β沙鹰破抗", 1)
  end
  if u:hasdata("变异判定-秋静叶") then
    local yx = {}
    yx[1] = Sound_Qiu_Q
    yx[2] = Sound_Qiu_W
    yx[3] = Sound_Qiu_10
    yx[4] = Sound_Qiu_12
    yx[5] = Sound_Qiu_13
    yx[6] = Sound_Qiu_14
    yx[7] = Sound_Qiu_15
    yx[8] = Sound_Qiu_16
    yx[9] = Sound_Qiu_11
    u:playsound(yx[GetRandomInt(1, 9)])
    unifycreate({
      owner = unit,
      model = "war3mapImported\\[TxNew]qiujingye_ye.mdl",
      modelname = "落叶飞刀",
      modelsize = 0.6,
      height = 75,
      damage = 10 * u:getallattri(),
      damagetype = 6,
      range = 1400,
      speed = 1400,
      volume = 200,
      isvest = true,
      startfunc = function(mj)
        mj:setdata("循环计数", 0)
      end,
      loopfunc = function(mj)
        mj:changedata("循环计数", UnifyDT)
        if mj:getdata("循环计数") >= 0.03 then
          mj:setdata("循环计数", 0)
          GroupClearLua(mj:getdata("弹幕-伤害组"))
          local x, y = mj:getxy()
          Effectcreate("Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl", x, y)
        end
      end,
      hitafterfunc = function(mj, xq)
        local jt = 25
        if xq:isnormal() then
          jt = 100
        elseif xq:iselite() then
          jt = 50
        end
        unitmove({
          unit = xq.handle,
          time = 0.2,
          distance = jt,
          angle = AngleBetweenUnits(mj.handle, xq.handle)
        })
      end
    })
  end
  if u:ishasitem(Weapons["草薙剑"]) then
    ac.wait(2000, function()
      x, y = u:getxy()
      Effectcreate("war3mapImported\\sasigay_lei.mdx", x, y, 0, 2)
      Effectcreate("war3mapimported\\171.mdx", x, y, 0, 2)
      local txsh = 3500 + 150 * u:getlevel()
      for _, xq in ac.selector():in_rangexy(x, y, 600):is_enemy(unit):ipairs() do
        xq = getunit(xq)
        u:setdata("伤害阶级", 2)
        DamageUnit({
          bj = "草薙剑位移",
          unit = xq.handle,
          source = u.handle,
          damage = txsh,
          type = "灵力",
          isvest = true
        })
      end
    end)
  end
  if diagnostic then diagnostic.monster("QW_DIRECT_EFFECTS_END", {unit=unit, key=keyboard}) end
end

return MoveskillInput
