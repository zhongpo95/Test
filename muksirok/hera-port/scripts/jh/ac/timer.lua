-- 원래 타이머 스케줄을 유지하면서 콜백 오류를 헤라 진단에도 전달한다.
local setmetatable = _ENV.setmetatable
local ipairs = _ENV.ipairs
local pairs = _ENV.pairs
local math_max = math.max
local math_floor = math.floor
local table_insert = table.insert
local cur_frame = 0
local max_frame = 0
local cur_index = 0
local free_queue = {}
local timer = {}
ac.all_timers = setmetatable({}, {__mode = "kv"})

local function alloc_queue()
  local n = #free_queue
  if 0 < n then
    local r = free_queue[n]
    free_queue[n] = nil
    return r
  else
    return {}
  end
end

local function m_timeout(self, timeout)
  local ti = cur_frame + timeout
  local q = timer[ti]
  if q == nil then
    q = alloc_queue()
    timer[ti] = q
  end
  self.timeout_frame = ti
  q[#q + 1] = self
end

local function m_wakeup(self)
  if self.removed then
    return
  end
  xpcall(self.on_timer, function(msg)
    local boot = package.loaded["hera_boot"]
    if type(boot) == "table" and boot.record_runtime_error then
      boot.record_runtime_error(tostring(msg) .. "\nTIMER " .. tostring(self._src) .. ":" ..
        tostring(self._line) .. "\n" .. debug.traceback())
    end
    print("计时器运行错误", self._src, self._line)
    print(msg, debug.traceback())
  end, self)
  if self.removed or self.pause_remaining then
    return
  end
  if self.timeout then
    m_timeout(self, self.timeout)
  else
    self.removed = true
    ac.all_timers[self] = nil
  end
end

local function on_tick()
  local q = timer[cur_frame]
  if q == nil then
    cur_index = 0
    return
  end
  for i = cur_index + 1, #q do
    local callback = q[i]
    cur_index = i
    q[i] = nil
    if callback then
      m_wakeup(callback)
    end
  end
  cur_index = 0
  timer[cur_frame] = nil
  free_queue[#free_queue + 1] = q
end

function ac.clock()
  return cur_frame
end

function ac.timer_size()
  local n = 0
  for _, ts in pairs(timer) do
    n = n + #ts
  end
  return n
end

function ac.debug_print_timer()
  if ac.enable_debug_timer ~= true then
    return
  end
  local map = {}
  for _, ts in pairs(timer) do
    for index, t in ipairs(ts) do
      if t.traceback then
        map[t.traceback] = (map[t.traceback] or 0) + 1
      end
    end
  end
  for info, count in pairs(map) do
    print("计时器数量", count, info)
  end
end

function ac.init_timer(timer)
  local info = debug.getinfo(3, "Sl")
  if info then
    timer._src = info.short_src
    timer._line = info.currentline
  end
  ac.all_timers[timer] = true
  if ac.enable_debug_timer then
    timer.traceback = debug.traceback(1)
  end
end

local jass = require("jass.common")
local handle_ref = require("jh.base.handle_ref")
local jtimer = jass.CreateTimer()
handle_ref.ref(jtimer)
jass.TimerStart(jtimer, 0.01, true, function()
  local delta = 10
  if cur_index ~= 0 then
    cur_frame = cur_frame - 1
  end
  max_frame = max_frame + delta
  while cur_frame < max_frame do
    cur_frame = cur_frame + 1
    on_tick()
  end
end)
local mt = {}
local api = {}
mt.__index = api
mt.type = "timer"

function api:remove()
  if self.removed then
    return
  end
  if self.on_remove then
    self:on_remove()
  end
  self.removed = true
  ac.all_timers[self] = nil
end

function api:get_remaining()
  if self.removed then
    return 0
  end
  if self.pause_remaining then
    return self.pause_remaining
  end
  if self.timeout_frame == cur_frame then
    return self.timeout or 0
  end
  return self.timeout_frame - cur_frame
end

function api:pause()
  self.pause_remaining = self:get_remaining()
  local ti = self.timeout_frame
  local q = timer[ti]
  if q then
    for i = #q, 1, -1 do
      if q[i] == self then
        q[i] = false
        return
      end
    end
  end
end

function api:resume()
  if self.pause_remaining then
    m_timeout(self, self.pause_remaining)
    self.pause_remaining = nil
  end
end

function ac.wait(timeout, on_timer)
  if timeout == nil or on_timer == nil then
    print("计时器参数不对", timeout, on_timer, debug.traceback())
    error("计时器参数不对", 2)
  end
  local timeout = math_max(math_floor(timeout) or 1, 1)
  local t = setmetatable({on_timer = on_timer}, mt)
  ac.init_timer(t)
  m_timeout(t, timeout)
  return t
end

function ac.loop(timeout, on_timer)
  if timeout == nil or on_timer == nil then
    print("计时器参数不对", timeout, on_timer, debug.traceback())
    error("计时器参数不对", 2)
  end
  local t = setmetatable({
    timeout = math_max(math_floor(timeout) or 1, 1),
    on_timer = on_timer
  }, mt)
  ac.init_timer(t)
  m_timeout(t, t.timeout)
  return t
end

function ac.timer(timeout, count, on_timer)
  if timeout == nil or count == nil or on_timer == nil then
    print("计时器参数不对", timeout, count, on_timer, debug.traceback())
    error("计时器参数不对", 2)
  end
  if count == 0 then
    return ac.loop(timeout, on_timer)
  end
  local t = ac.loop(timeout, function(t)
    on_timer(t)
    count = count - 1
    if count <= 0 then
      t:remove()
    end
  end)
  return t
end

local function utimer_initialize(u)
  if not u._timers then
    u._timers = {}
  end
  if #u._timers > 0 then
    return
  end
  u._timers[1] = ac.loop(10000, function()
    local timers = assert(u._timers)
    for i = #timers, 2, -1 do
      if timers[i].removed then
        local len = #timers
        timers[i] = timers[len]
        timers[len] = nil
      end
    end
    if #timers == 1 then
      timers[1]:remove()
      timers[1] = nil
    end
  end)
end

function ac.uwait(u, timeout, on_timer)
  utimer_initialize(u)
  local t = ac.wait(timeout, on_timer)
  table_insert(u._timers, t)
  return t
end

function ac.uloop(u, timeout, on_timer)
  utimer_initialize(u)
  local t = ac.loop(timeout, on_timer)
  table_insert(u._timers, t)
  return t
end

function ac.utimer(u, timeout, count, on_timer)
  utimer_initialize(u)
  local t = ac.timer(timeout, count, on_timer)
  table_insert(u._timers, t)
  return t
end

function ac.list_running_timers()
  local c = 0
  for frame, q in pairs(timer) do
    print("帧:", frame, " 计时器数量:", #q)
    for _, t in ipairs(q) do
      if t and not t.removed then
        c = c + 1
        print("  - 计时器:", t, " 剩余时间:", t:get_remaining(), " 来源:", t._src, " 行号:", t._line)
      end
    end
  end
  print("总计时器数量:" .. c)
end
