-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local Site = {}
local CIRCLE_MODEL = "WhiteCircle.mdx"
local CIRCLE_SCALE = 0.4
local SEARCH_RADIUS = 215
local CHECK_INTERVAL = 250
local PING_INTERVAL = 15000
local MIN_START_DISTANCE = 1200
local RANDOM_ATTEMPTS = 16
local MOVEABLE_SEARCH_RADIUS = 512
local FALLBACK_STEP = 400
local FALLBACK_STEPS = 6
local FALLBACK_ANGLES = 8
local circle_effects = {}

local function unit_exists(u)
  return u.handle ~= nil and GetUnitTypeId(u.handle) ~= 0
end

local function is_valid_target(origin_x, origin_y, x, y)
  if x < GetRectMinX(RECT_PlayArea) + SEARCH_RADIUS or x > GetRectMaxX(RECT_PlayArea) - SEARCH_RADIUS or y < GetRectMinY(RECT_PlayArea) + SEARCH_RADIUS or y > GetRectMaxY(RECT_PlayArea) - SEARCH_RADIUS then
    return false
  end
  if IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY) then
    return false
  end
  if not IsTerrainPathable(x, y, PATHING_TYPE_FLOATABILITY) then
    return false
  end
  return DistanceXY(origin_x, origin_y, x, y) >= MIN_START_DISTANCE
end

local function moveable_target(origin_x, origin_y, x, y)
  local point = ac.point(x, y):findMoveablePoint(MOVEABLE_SEARCH_RADIUS)
  if not point then
    return nil, nil
  end
  local target_x, target_y = point:get()
  if not is_valid_target(origin_x, origin_y, target_x, target_y) then
    return nil, nil
  end
  return target_x, target_y
end

local function select_target(u)
  local origin_x, origin_y = u:getxy()
  for _ = 1, RANDOM_ATTEMPTS do
    local x, y = GetRandomXYInRect(RECT_PlayArea)
    local target_x, target_y = moveable_target(origin_x, origin_y, x, y)
    if target_x and target_y then
      return target_x, target_y
    end
  end
  for step = 1, FALLBACK_STEPS do
    local distance = MIN_START_DISTANCE + step * FALLBACK_STEP
    for index = 0, FALLBACK_ANGLES - 1 do
      local angle = index * 360 / FALLBACK_ANGLES
      local x, y = PolarXY(origin_x, origin_y, distance, angle)
      local target_x, target_y = moveable_target(origin_x, origin_y, x, y)
      if target_x and target_y then
        return target_x, target_y
      end
    end
  end
  error("弹丸论破搜查任务未找到可抵达的陆地点", 2)
end

local function ping(site)
  local u = site.unit
  if not u or not u:islocal() then
    return
  end
  local ok, err = xpcall(PingMinimapEx, debug.traceback, site.x, site.y, 5, 255, 153, 204, false)
  if not ok then
    print("弹丸论破搜查点小地图信号显示失败", err)
  end
end

local function create_circle(site)
  local u = site.unit
  if not u then
    return
  end
  -- 모든 클라이언트에서 핸들을 만들고 소유자에게만 모델을 표시한다.
  local model = ""
  if u:islocal() then
    model = CIRCLE_MODEL
  end
  local ok, effect = xpcall(Effectcreate, debug.traceback, model, site.x, site.y, -1, CIRCLE_SCALE, 0, 0, 0, 0, 0.25)
  if ok then
    circle_effects[site] = effect
  else
    print("弹丸论破搜查圈显示失败", effect)
  end
end

function Site.close(site)
  if not site or site.closed then
    return
  end
  site.closed = true
  site.on_arrive = nil
  site.unit = nil
  local timer = site.timer
  site.timer = nil
  if timer then
    timer:remove()
  end
  local effect = circle_effects[site]
  circle_effects[site] = nil
  if effect then
    local ok, err = xpcall(DestroyEffectLua, debug.traceback, effect)
    if not ok then
      print("弹丸论破搜查圈销毁失败", err)
    end
  end
end

function Site.open(u, on_arrive)
  if not unit_exists(u) then
    error("弹丸论破搜查任务需要存在的英雄", 2)
  end
  local x, y = select_target(u)
  local site = {
    x = x,
    y = y,
    radius = SEARCH_RADIUS,
    unit = u,
    on_arrive = on_arrive,
    ping_elapsed = 0,
    closed = false
  }
  site.timer = ac.loop(CHECK_INTERVAL, function()
    if site.closed then
      return
    end
    local hero = site.unit
    if not hero or not unit_exists(hero) then
      Site.close(site)
      return
    end
    local hero_x, hero_y = hero:getxy()
    if hero:isalive() and hero:gethp() > 0 and DistanceXY(site.x, site.y, hero_x, hero_y) <= site.radius then
      local callback = site.on_arrive
      Site.close(site)
      if callback then
        callback(site)
      end
      return
    end
    site.ping_elapsed = site.ping_elapsed + CHECK_INTERVAL
    if site.ping_elapsed >= PING_INTERVAL then
      site.ping_elapsed = site.ping_elapsed - PING_INTERVAL
      ping(site)
    end
  end)
  u:sendmessage(("|cFFFF99CC搜查目标已标记：|r坐标 |cFF99FFFF%.0f，%.0f|r，进入 |cFF99FFFF%d|r 码范围。"):format(site.x, site.y, site.radius), 15)
  create_circle(site)
  ping(site)
  return site
end

return Site
