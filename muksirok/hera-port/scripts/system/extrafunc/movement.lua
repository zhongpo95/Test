-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
-- 공통 초기화에서 한 번 만든 영역을 이동 충돌 검사에 재사용한다.
local movement_destructable_rect = Rect(0, 0, 0, 0)
local function enum_movement_destructables(x, y, radius, callback, use_filter, trace_context)
  if use_filter then
    local center = Location(x, y)
    -- v160 비교 전용이며 원래 BJ처럼 공유 값을 덮어쓰고 종료 후 복원하지 않는다.
    local probe = require("hera_callback_probe")
    -- 엔진에 전달할 중간 함수 자체의 등록을 관찰한다.
    local action = function()
      callback()
    end
    local before_id, before_count = probe.before(action)
    EnumDestructablesInCircleBJ(radius, center, action)
    RemoveLocation(center)
    probe.after(trace_context, action, before_id, before_count)
    return
  end
  SetRect(movement_destructable_rect, x - radius, y - radius, x + radius, y + radius)
  EnumDestructablesInRect(movement_destructable_rect, nil, function()
    local dc = GetEnumDestructable()
    local dx = GetDestructableX(dc) - x
    local dy = GetDestructableY(dc) - y
    if dx * dx + dy * dy <= radius * radius then
      callback()
    end
  end)
end

function unitmove(args)
  local unit = args.unit
  
  local u = getunit(unit)
  local trace = require("hera_move_trace")
  local ctx = trace.begin_steps(u)
  trace.step(ctx, "CREATE", "distance=" .. tostring(args.distance) .. " time=" .. tostring(args.time) .. " angle=" .. tostring(args.angle))
  local dis, t, speed
  if args.speed then
    speed = args.speed
    if args.distance then
      dis = args.distance
      t = dis / speed
    elseif args.time then
      t = args.time
      dis = t * speed
    end
  else
    t = args.time
    dis = args.distance
    speed = dis / t
  end
  local dt = args.dt or 0.01
  local cs = t / dt
  local isfly = args.isfly or false
  local isblink = args.isblink or false
  local islock = args.islock or false
  local angle = args.angle or u:getface()
  if dis < 0 then
    dis = dis * -1
    angle = angle + 180
  end
  if u:hasdata("免疫击退效果") then
    dis = 0
  end
  local x, y = u:getxy()
  local v = dis / cs
  local b = true
  local startfunc = args.startfunc
  local loops = args.loops
  local loop_timers = {}
  if loops then
    for i, loop in ipairs(loops) do
      loop_timers[i] = 0
    end
  end
  local endfunc = args.endfunc
  if startfunc then
    trace.step(ctx, "STARTFUNC_BEGIN", "")
    startfunc()
    trace.step(ctx, "STARTFUNC_END", "")
  end
  if u:hasdata("系统-飞行状态") then
    isfly = true
  end
  local lt = dt * 1000
  if isblink then
    lt = 0
  end
  args.v = v
  args.angle = angle
  args.stop = args.stop or false
  local ox, oy = x, y
  local finished = false
  local move_timer = ac.loop(lt, function(timer)
    if finished then return end
    if ctx then ctx.step = ctx.step + 1 end
    trace.step(ctx, "TICK_BEGIN", "remaining=" .. tostring(cs))
    cs = cs - 1
    if not isblink then
      x, y = u:getxy()
    end
    ox, oy = x, y
    x, y = PolarXY(x, y, args.v, args.angle)
    trace.step(ctx, "CANDIDATE", "x=" .. tostring(x) .. " y=" .. tostring(y) .. " fly=" .. tostring(isfly) .. " blink=" .. tostring(isblink))
    if not isfly and not isblink then
      local terrain_blocked = IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY)
      trace.step(ctx, "TERRAIN", "blocked=" .. tostring(terrain_blocked))
      if terrain_blocked then
        b = false
      end
      do
        trace.step(ctx, "DESTRUCTABLE_FILTER_BEGIN", "mode=bj_wrapped_registry_probe")
        enum_movement_destructables(x, y, 50, function()
          local dc = GetEnumDestructable()
          local dctype = GetDestructableTypeId(dc)
          local life = GetDestructableLife(dc)
          trace.step(ctx, "DESTRUCTABLE", "handle=" .. tostring(dc) .. " type=" .. tostring(dctype) .. " life=" .. tostring(life))
          if life > 0 and dctype ~= S2ID("JTtw") and dctype ~= S2ID("OTip") and dctype ~= S2ID("OTis") then
            b = false
          end
        end, true, ctx)
        trace.step(ctx, "DESTRUCTABLE_FILTER_END", "mode=bj_wrapped_registry_probe")
      end
    end
    local in_bounds = IsXYinAnyPlayRect(x, y)
    trace.step(ctx, "BOUNDS", "inside=" .. tostring(in_bounds) .. " path_ok=" .. tostring(b))
    if not in_bounds then
      b = false
      x, y = ox, oy
    end
    local finish_reason
    if cs <= 0 then
      finish_reason = "duration"
    elseif not b then
      finish_reason = "path_or_bounds"
    elseif not u:isalive() and u:getdata("生命上限") ~= 0 then
      finish_reason = "dead"
    elseif args.stop then
      finish_reason = "requested_stop"
    end
    if finish_reason then
      trace.step(ctx, "FINISH", "reason=" .. finish_reason .. " remaining=" .. tostring(cs) .. " path_ok=" .. tostring(b) .. " stop=" .. tostring(args.stop))
      finished = true
      if endfunc then
        trace.step(ctx, "ENDFUNC_BEGIN", "")
        endfunc(x, y)
        trace.step(ctx, "ENDFUNC_END", "")
      end
      if not islock and isblink then
        u:setxy(x, y, ctx)
      end
      timer:remove()
    else
      if not islock and not isblink then
        u:setxy(x, y, ctx)
      end
      if loops then
        for i, loop in ipairs(loops) do
          loop_timers[i] = loop_timers[i] + dt
          if loop_timers[i] >= (loop.looptime or dt) then
            loop_timers[i] = 0
            if loop.func then
              trace.step(ctx, "LOOPFUNC_BEGIN", "index=" .. tostring(i))
              loop.func(x, y, args)
              trace.step(ctx, "LOOPFUNC_END", "index=" .. tostring(i))
            end
          end
        end
      end
    end
    trace.step(ctx, "TICK_END", "finished=" .. tostring(finished))
  end)
  return function()
    if finished then return false end
    trace.step(ctx, "CANCEL", "remaining=" .. tostring(cs))
    finished = true
    move_timer:remove()
    local end_x, end_y = u:getxy()
    if endfunc then endfunc(end_x, end_y) end
    trace.step(ctx, "CANCEL_END", "")
    return true
  end
end

function effectmove(args)
  local effect = args.effect
  local handle_ref = require("jh.base.handle_ref")
  local generation = handle_ref.generation(effect)
  if not generation or not handle_ref.is_alive(effect, generation) then
    return
  end
  local dis, t, speed
  if args.speed then
    speed = args.speed
    if args.distance then
      dis = args.distance
      t = dis / speed
    elseif args.time then
      t = args.time
      dis = t * speed
    end
  else
    t = args.time
    dis = args.distance
    speed = dis / t
  end
  local dt = args.dt or 0.01
  local cs = t / dt
  local angle = args.angle or 0
  local x = japi.EXGetEffectX(effect)
  local y = japi.EXGetEffectY(effect)
  local v = dis / cs
  local b = true
  local startfunc = args.startfunc
  local loops = args.loops
  local loop_timers = {}
  if loops then
    for i, loop in ipairs(loops) do
      loop_timers[i] = 0
    end
  end
  local endfunc = args.endfunc
  if startfunc then
    startfunc(args)
  end
  local lt = dt * 1000
  args.stop = args.stop or false
  ac.loop(lt, function(timer)
    if not handle_ref.is_alive(effect, generation) then
      timer:remove()
      return
    end
    cs = cs - 1
    x = japi.EXGetEffectX(effect)
    y = japi.EXGetEffectY(effect)
    x, y = PolarXY(x, y, v, angle)
    if not IsXYinAnyPlayRect(x, y) then
      b = false
    end
    if not (not (cs <= 0) and b) or args.stop then
      if endfunc then
        endfunc(x, y, args)
      end
      timer:remove()
    else
      japi.EXSetEffectXY(effect, x, y)
      if loops then
        for i, loop in ipairs(loops) do
          loop_timers[i] = loop_timers[i] + dt
          if loop_timers[i] >= (loop.looptime or dt) then
            loop_timers[i] = 0
            if loop.func then
              loop.func(x, y, args)
            end
          end
        end
      end
    end
  end)
end

function loopmove(args)
  local dis, t, speed
  if args.speed then
    speed = args.speed
    if args.distance then
      dis = args.distance
      t = dis / speed
    elseif args.time then
      t = args.time
      dis = t * speed
    end
  else
    t = args.time
    dis = args.distance
    speed = dis / t
  end
  local dt = args.dt or 0.01
  local cs = t / dt
  local angle = args.angle or 0
  local x = args.x
  local y = args.y
  local v = dis / cs
  local b = true
  local startfunc = args.startfunc
  local loops = args.loops
  local loop_timers = {}
  if loops then
    for i, loop in ipairs(loops) do
      loop_timers[i] = 0
    end
  end
  local endfunc = args.endfunc
  if startfunc then
    startfunc(x, y)
  end
  local lt = dt * 1000
  ac.loop(lt, function(timer)
    cs = cs - 1
    x, y = PolarXY(x, y, v, angle)
    if not IsXYinAnyPlayRect(x, y) then
      b = false
    end
    if cs <= 0 or not b then
      if endfunc then
        endfunc(x, y)
      end
      timer:remove()
    elseif loops then
      for i, loop in ipairs(loops) do
        loop_timers[i] = loop_timers[i] + dt
        if loop_timers[i] >= (loop.looptime or dt) then
          loop_timers[i] = 0
          if loop.func then
            loop.func(x, y)
          end
        end
      end
    end
  end)
end

function unitjump(args)
  local unit = args.unit
  local u = getunit(unit)
  local dis, t, speed
  if args.speed then
    speed = args.speed
    if args.distance then
      dis = args.distance
      t = dis / speed
    elseif args.time then
      t = args.time
      dis = t * speed
    end
  else
    t = args.time
    dis = args.distance
    speed = dis / t
  end
  local dt = args.dt or 0.01
  local cs = t / dt
  local isfly = args.isfly or true
  local isblink = args.isblink or false
  local islock = args.islock or false
  local angle = args.angle or 0
  local x, y = u:getxy()
  local v = dis / cs
  local b = true
  local startfunc = args.startfunc
  local loops = args.loops
  local loop_timers = {}
  if loops then
    for i, loop in ipairs(loops) do
      loop_timers[i] = 0
    end
  end
  if u:hasdata("免疫击退效果") then
    dis = 0
  end
  local endfunc = args.endfunc
  if startfunc then
    startfunc()
  end
  local lt = dt * 1000
  if isblink then
    lt = 0
  end
  u:allowfly()
  local originheight = 0
  if not u:hasdata("跳跃高度-初始") then
    u:setdata("跳跃高度-初始", GetUnitDefaultFlyHeight(unit))
    originheight = GetUnitDefaultFlyHeight(unit)
  else
    originheight = u:getdata("跳跃高度-初始")
  end
  local height = args.height or 0
  local midcs = cs / 2
  args.stop = args.stop or false
  ac.loop(lt, function(timer)
    cs = cs - 1
    if not isblink then
      x, y = u:getxy()
    end
    x, y = PolarXY(x, y, v, angle)
    if not isfly and not isblink then
      if IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY) then
        b = false
      end
      enum_movement_destructables(x, y, 50, function()
        local dc = GetEnumDestructable()
        local dctype = GetDestructableTypeId(dc)
        if GetDestructableLife(dc) > 0 and dctype ~= S2ID("JTtw") and dctype ~= S2ID("OTip") and dctype ~= S2ID("OTis") then
          b = false
        end
      end)
    end
    if not IsXYinAnyPlayRect(x, y) then
      b = false
    end
    if not (not (cs <= 0) and b) or not u:isalive() and u:getdata("生命上限") ~= 0 or args.stop then
      if endfunc then
        endfunc(x, y)
      end
      if not islock and isblink then
        u:setxy(x, y)
      end
      if u:hasdata("跳跃高度-初始") then
        SetUnitFlyHeight(unit, u:getdata("跳跃高度-初始"), 99999)
        u:deldata("跳跃高度-初始")
      else
        SetUnitFlyHeight(unit, originheight, 99999)
      end
      timer:remove()
    else
      local h = (-(1 - cs / midcs) ^ 2 + 1) * height + originheight
      SetUnitFlyHeight(unit, h, 99999)
      u:setdata("当前跳跃高度", h)
      if not islock and not isblink then
        u:setxy(x, y)
      end
      if loops then
        for i, loop in ipairs(loops) do
          loop_timers[i] = loop_timers[i] + dt
          if loop_timers[i] >= (loop.looptime or dt) then
            loop_timers[i] = 0
            if loop.func then
              loop.func(x, y, args)
            end
          end
        end
      end
    end
  end)
end

function effectjump(args)
  local effect = args.effect
  local dis, t, speed
  if args.speed then
    speed = args.speed
    if args.distance then
      dis = args.distance
      t = dis / speed
    elseif args.time then
      t = args.time
      dis = t * speed
    end
  else
    t = args.time
    dis = args.distance
    speed = dis / t
  end
  local dt = args.dt or 0.01
  local cs = t / dt
  local angle = args.angle or 0
  local x = japi.EXGetEffectX(effect)
  local y = japi.EXGetEffectY(effect)
  local v = dis / cs
  local b = true
  local startfunc = args.startfunc
  local loops = args.loops
  local loop_timers = {}
  if loops then
    for i, loop in ipairs(loops) do
      loop_timers[i] = 0
    end
  end
  local endfunc = args.endfunc
  if startfunc then
    startfunc()
  end
  local lt = dt * 1000
  local height = args.height or 0
  local originheight = japi.EXGetEffectZ(effect)
  local midcs = cs / 2
  local dargs = {}
  ac.loop(lt, function(timer)
    cs = cs - 1
    x = japi.EXGetEffectX(effect)
    y = japi.EXGetEffectY(effect)
    x, y = PolarXY(x, y, v, angle)
    if not IsXYinAnyPlayRect(x, y) then
      b = false
    end
    if cs <= 0 or not b then
      if endfunc then
        endfunc(dargs)
      end
      timer:remove()
    else
      japi.EXSetEffectXY(effect, x, y)
      local h = (-(1 - cs / midcs) ^ 2 + 1) * height + originheight
      japi.EXSetEffectZ(effect, h)
      dargs.h = h
      dargs.x = x
      dargs.y = y
      if loops then
        for i, loop in ipairs(loops) do
          loop_timers[i] = loop_timers[i] + dt
          if loop_timers[i] >= (loop.looptime or dt) then
            loop_timers[i] = 0
            if loop.func then
              loop.func(dargs)
            end
          end
        end
      end
    end
  end)
end
