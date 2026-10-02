-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local skillg = require("gameplay.hero.heroskill.琪露诺.skill")

-- 치르노 전용 동작을 복원한 상태에서 지면 회전 진단을 기록한다.
local ground_spin_enabled = true
local diagnostic_skip_cirno_events = false

local function init(u)
  local trace_count = 0
  local spin_sequence = 0
  local function trace_spin(stage, details)
    if trace_count >= 6000 then return end
    trace_count = trace_count + 1
    require("hera_gameplay_diagnostic").monster("CIRNO_SPIN_" .. stage, {unit=u.handle, owner=u.ownerid, sequence=spin_sequence, details=details or ""})
    local x, y = u:getxy()
    require("hera_boot").note("CIRNO SPIN clock=" .. tostring(ac.clock()) ..
      " unit=" .. tostring(u.handle) .. " owner=" .. tostring(u.ownerid) ..
      " seq=" .. tostring(spin_sequence) .. " stage=" .. stage ..
      " x=" .. tostring(x) .. " y=" .. tostring(y) ..
      " hp=" .. tostring(u:gethp()) .. " " .. (details or ""), true)
    if trace_count == 6000 then
      require("hera_boot").note("CIRNO SPIN trace limit reached unit=" .. tostring(u.handle), true)
    end
  end
  local sy = u.ownerid
  ChatIcon[sy] = "ChatIcon (4).tga"
  u:setdata("单位-左上头像", "TopLeft_ICON_12.blp")
  Damage_ElementRes_Dark[sy] = -25
  Damage_ElementRes_Fire[sy] = -25
  Damage_ElementRes_Water[sy] = 50
  Damage_ElementRes_Ice[sy] = 50
  Damage_Element_Ice[sy] = 0.25
  Damage_Element_Water[sy] = 0.1
  Damage_Element_Fire[sy] = -0.5
  u:setdata("琪露诺-冰袭方阵附加")
  u:changearmor(5)
  u:setdata("英雄-琪露诺")
  u:setdata("东方变异数量", 1)
  u:setdata("冰变异数量", 1)
  u:setdata("东方角色")
  -- 외형과 초기 능력치는 유지하고 전용 스킬, 재능, 타이머 등록을 건너뛴다.
  if diagnostic_skip_cirno_events then
    u:addint(9)
    u:setdata("英雄-天赋树表", {})
    require("hera_boot").note("CIRNO ISOLATION v80 owner=" .. tostring(sy) ..
      " unit=" .. tostring(u.handle) .. " dedicated_events=disabled timers=disabled talents=disabled", true)
    u:sendmessage("|cFFFFCC00[v80 진단] 치르노 전용 스킬·재능 효과를 임시로 껐습니다. 기본 Q/W 이동은 유지됩니다.|r")
    return
  end
  require("hera_gameplay_diagnostic").monster("CIRNO_EVENTS_INIT_BEGIN", {unit=u.handle, owner=sy})
  u:addstexiao("琪露诺天赋", "直接伤害特效", function(args)
    local u = args.u
    local tg = args.tg
    local info = args.damageinfo
    if not tg:hasdata("琪露诺天赋冷却") and u:getluckrandom(10 * info.txgl) then
      tg:settimedata("琪露诺天赋冷却", 0.1)
      tg:buffset(u.handle, 1, "冰冻")
    end
    if not u:hasdata("琪露诺-碎冰龙卷冷却") and u:getluckrandom(5 * info.txgl) then
      u:setskillcd("A1OO", 15)
      u:settimedata("琪露诺-碎冰龙卷冷却", 15)
      local dx, dy = u:getxy()
      local x2, y2 = tg:getxy()
      local cs = 0
      local angle = AngleXY(dx, dy, x2, y2)
      local g = CreateGroupLua()
      local txsh = 5000 + 500 * u:getlevel()
      Effectcreate("4.26.Ice (28).mdl", dx, dy, 0, 1.75)
      for _, xq in ac.selector():in_rangexy(dx, dy, 450):is_enemy(u.handle):isnotingroup(g):ipairs() do
        xq = getunit(xq)
        xq:groupadd(g)
        xq:effectadd("Abilities\\Spells\\Undead\\FrostNova\\FrostNovaTarget.mdl")
        xq:buffset(u.handle, 1, "冻结")
        xq:buffset(u.handle, 3, "冰冻")
        DamageUnit({
          bj = "琪露诺(破冰龙卷)",
          unit = xq.handle,
          source = u.handle,
          damage = txsh,
          level = 1,
          type = "灵力",
          isvest = false,
          isattack = false,
          isnoarmor = false,
          element = "冰"
        })
      end
      ac.loop(250, function(timer)
        cs = cs + 1
        dx, dy = PolarXY(dx, dy, 325, angle)
        Effectcreate("4.26.Ice (28).mdl", dx, dy, 0, 1.75)
        for _, xq in ac.selector():in_rangexy(dx, dy, 450):is_enemy(u.handle):isnotingroup(g):ipairs() do
          xq = getunit(xq)
          xq:groupadd(g)
          xq:effectadd("Abilities\\Spells\\Undead\\FrostNova\\FrostNovaTarget.mdl")
          xq:buffset(u.handle, 1, "冻结")
          xq:buffset(u.handle, 3, "冰冻")
          DamageUnit({
            bj = "琪露诺(破冰龙卷)",
            unit = xq.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "灵力",
            isvest = false,
            isattack = false,
            isnoarmor = false,
            element = "冰"
          })
        end
        if cs == 3 then
          timer:remove()
        end
      end)
      if u:hasdata("琪露诺-我的滑板鞋") then
        ac.timer(2000, 5, function()
          local dx, dy = u:getxy()
          Effectcreate("4.26.Ice (28).mdl", dx, dy, 0, 1.25)
          for _, xq in ac.selector():in_rangexy(dx, dy, 325):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            xq:effectadd("Abilities\\Spells\\Undead\\FrostNova\\FrostNovaTarget.mdl")
            xq:buffset(u.handle, 1, "冻结")
            xq:buffset(u.handle, 3, "冰冻")
            DamageUnit({
              bj = "琪露诺(破冰龙卷)",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "灵力",
              isvest = false,
              isattack = false,
              isnoarmor = false,
              element = "冰"
            })
          end
        end)
      end
    end
  end)
  ac.loop(15000, function()
    if u:isalive() then
      u:effectadd("Abilities\\Weapons\\ZigguratFrostMissile\\ZigguratFrostMissile.mdl", "hand", 15)
    end
  end)
  u:addint(9)
  local dadd = 0
  ac.loop(1000, function()
    if u:getoriginint() ~= 9 then
      local add = (u:getoriginint() - 9) / 2
      u:setdata("智力", 9)
      if 1 <= add then
        u:setdata("混沌之种-属性添加中")
        u:addstr(add)
        u:addagi(add)
        u:deldata("混沌之种-属性添加中")
      else
        dadd = dadd + add
      end
      if 1 <= dadd then
        local add2 = math.floor(dadd)
        dadd = dadd - add2
        u:setdata("混沌之种-属性添加中")
        u:addstr(add2)
        u:addagi(add2)
        u:deldata("混沌之种-属性添加中")
      end
    end
  end)
  u:addstexiao("琪露诺", "决死效果", function(args)
    if args.dt and not u:hasdata("琪露诺-决死冷却") then
      args.dt = false
      u:setskillcd("A1OQ", 90)
      u:settimedata("琪露诺-决死冷却", 90)
      local dx, dy = u:getxy()
      u:sendmessage("|cFF6699FF琪露诺-冷符「瞬间冷冻Beam」|r")
      Effectcreate("4.26.Ice (28).mdl", dx, dy, 0, 2)
      Effectcreate("4.26.Ice (2).mdl", dx, dy, 0, 2)
      u:effectadd("4.26.Ice (2).mdl", "origin", 3)
      u:buffset(u.handle, 3, "冻结")
      u:buffset(u.handle, 3.3, "无敌")
      ChangeTimeValue(HeroMenu_HpForever_MaxHp, sy, 11, 3)
      ChangeTimeValue(Hero_Tili_Huifu, sy, 5, 3)
      for _, xq in ac.selector():in_rangexy(dx, dy, 444):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        xq:effectadd("Abilities\\Spells\\Undead\\FrostNova\\FrostNovaTarget.mdl")
        xq:buffset(u.handle, 6, "冻结")
        xq:buffset(u.handle, 6, "破坏-伤害抗性")
      end
    end
  end)
  u:addstexiao("琪露诺", "终结伤害计算效果", function(args)
    local tg = args.tg
    local u = args.u
    local info = args.damageinfo
    if tg:hasbuff("冰冻") then
      info.end2 = info.end2 + 0.25
    end
  end)
  u:addstexiao("琪露诺", "位移技能后效果", function(args)
    if not u:hasdata("琪露诺-妖精旋转关闭") and not u:hasdata("琪露诺-妖精旋转") then
      u:settimedata("琪露诺-妖精旋转", 0.5)
      trace_spin("ARM", "window=0.5")
    end
  end)
  u:addtrgevent("单位-指定点目标指令", function(args)
    trace_spin("ORDER", "order=" .. tostring(args.orderid) .. " target_x=" .. tostring(args.x) ..
      " target_y=" .. tostring(args.y) .. " armed=" .. tostring(u:hasdata("琪露诺-妖精旋转")))
    if args.orderid == String2OrderIdBJ("smart") and u:hasdata("琪露诺-妖精旋转") then
      if not ground_spin_enabled then
        trace_spin("BLOCKED", "diagnostic=v99 ground_spin_disabled")
        return
      end
      spin_sequence = spin_sequence + 1
      trace_spin("BEGIN")
      u:deldata("琪露诺-妖精旋转")
      local x, y = u:getxy()
      local dx = args.x
      local dy = args.y
      local angle = AngleXY(x, y, dx, dy)
      local dis = DistanceXY(x, y, dx, dy)
      local max = 250 + u:getdata("当前额外移速") * 0.5
      if u:hasdata("琪露诺-我的滑板鞋") then
        max = max * 2
      end
      if dis >= max then
        dis = max
      end
      dx, dy = PolarXY(x, y, dis, angle)
      trace_spin("STAMINA BEGIN", "distance=" .. tostring(dis) .. " angle=" .. tostring(angle))
      if not u:lossstamina(1) then
        trace_spin("STAMINA REJECT")
        u:sendmessage("|cFFFF3300体力值不足|r")
        return
      end
      trace_spin("STAMINA END")
      if u:hasdata("琪露诺-大寒波") and not u:hasdata("琪露诺-大寒波碰撞判定时间") then
        u:setdata("琪露诺-大寒波碰撞判定时间", 0.5)
      end
      if u:hasdata("琪露诺-我的滑板鞋") then
        u:buffset(u.handle, 0.25, "绝对闪避")
      end
      trace_spin("GROUP BEGIN")
      local g = CreateGroupLua()
      trace_spin("GROUP END")
      local ticks = 0
      trace_spin("MOVE BEGIN")
      unitmove({
        unit = u.handle,
        time = 0.25,
        distance = dis,
        angle = angle,
        isfly = true,
        startfunc = function()
          trace_spin("MOVE START")
        end,
        endfunc = function()
          trace_spin("MOVE END", "ticks=" .. tostring(ticks))
        end,
        loops = {
          {
            looptime = 0.05,
            func = function()
              x, y = u:getxy()
              ticks = ticks + 1
              trace_spin("EFFECT BEGIN", "tick=" .. tostring(ticks))
              local trail = Effectcreate("Abilities\\Weapons\\FrostWyrmMissile\\FrostWyrmMissile.mdl", x, y, 0.25)
              trace_spin("EFFECT END", "handle=" .. tostring(trail) .. " lifetime=0.25")
            end
          },
          {
            looptime = 0.05,
            func = function()
              x, y = u:getxy()
              trace_spin("TARGETS BEGIN")
              for _, xq in ac.selector():in_rangexy(x, y, 225):is_enemy(u.handle):isnotingroup(g):ipairs() do
                xq = getunit(xq)
                trace_spin("FREEZE BEGIN", "target=" .. tostring(xq.handle))
                xq:groupadd(g)
                xq:buffset(u.handle, 1, "冰冻")
                xq:effectadd("Abilities\\Spells\\Undead\\FrostNova\\FrostNovaTarget.mdl")
                trace_spin("FREEZE END", "target=" .. tostring(xq.handle))
              end
              trace_spin("TARGETS END")
            end
          }
        }
      })
      trace_spin("MOVE SCHEDULED")
    end
  end)
  u:addstexiao("琪露诺天赋", "伤害判定后效果", function(args)
    local tg = args.tg
    if args.damage >= 100 then
      tg:clearbuff("Bbsk")
      tg:clearbuff("B045")
      tg:clearbuff("BOwk")
    end
  end)
  u:addtrgevent("单位-发动技能", function(args)
    for index, value in ipairs(skillg) do
      if S2ID(value.skill) == args.skill then
        value:func(args)
      end
    end
  end)
  require("hera_gameplay_diagnostic").monster("CIRNO_TALENT_INIT_BEGIN", {unit=u.handle, owner=sy})
  local talent = require("gameplay.hero.heroskill.琪露诺.talent")
  u:setdata("英雄-天赋树表", talent)
  WaitTalentUnitReady(sy, function(tfs)
    require("hera_gameplay_diagnostic").monster("CIRNO_TALENT_READY", {unit=u.handle, owner=sy})
    tfs:triggeraddevent(Trg_UNIT_RESEARCH_START, EVENT_UNIT_RESEARCH_START)
    tfs:triggeraddevent(Trg_UNIT_RESEARCH_FINISH, EVENT_UNIT_RESEARCH_FINISH)
    tfs:addtrgevent("单位-开始研究科技", function(args)
      talent.start(args)
    end)
    tfs:addtrgevent("单位-完成研究科技", function(args)
      talent.finish(args)
    end)
  end)
  require("hera_gameplay_diagnostic").monster("CIRNO_EVENTS_INIT_END", {unit=u.handle, owner=sy, ground_spin=true})
  u:sendmessage("|cFFFFCC00[v101 진단] 지면 회전과 얼음 궤적 연출을 복원했습니다.|r")
end

return init
