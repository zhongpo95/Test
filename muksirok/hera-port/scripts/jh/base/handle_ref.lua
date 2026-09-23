-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local dbg = require("jass.debug")
local handle_ref = {}
local tracked = {}
local next_generation = 0

local function is_valid(handle)
  return handle ~= nil and handle ~= 0
end

function handle_ref.ref(handle)
  if not is_valid(handle) or tracked[handle] then
    return handle, false
  end
  dbg.handle_ref(handle)
  next_generation = next_generation + 1
  tracked[handle] = {
    generation = next_generation,
    holds = 0,
    unref_pending = false
  }
  return handle, true, next_generation
end

function handle_ref.unref(handle, generation)
  local state = tracked[handle]
  if not (is_valid(handle) and state) or generation and state.generation ~= generation or state.unref_pending then
    return false
  end
  if state.holds > 0 then
    state.unref_pending = true
    return false
  end
  dbg.handle_unref(handle)
  tracked[handle] = nil
  return true
end

function handle_ref.generation(handle)
  local state = tracked[handle]
  return state and state.generation or nil
end

function handle_ref.is_current(handle, generation)
  local state = tracked[handle]
  return state ~= nil and state.generation == generation
end

function handle_ref.hold(handle)
  local state = tracked[handle]
  if not is_valid(handle) then
    return false
  end
  if not state then
    handle_ref.ref(handle)
    state = tracked[handle]
  end
  state.holds = state.holds + 1
  return true
end

function handle_ref.release(handle)
  local state = tracked[handle]
  if not (is_valid(handle) and state) or state.holds <= 0 then
    return false
  end
  state.holds = state.holds - 1
  if state.holds == 0 and state.unref_pending then
    dbg.handle_unref(handle)
    tracked[handle] = nil
    return true
  end
  return false
end

-- 참조 보유와 별개로 같은 세대의 네이티브 제거를 한 번만 허용한다.
function handle_ref.begin_remove(handle, generation)
  local state = tracked[handle]
  if not state or state.removing or (generation and state.generation ~= generation) then
    return false
  end
  state.removing = true
  return true
end

function handle_ref.is_alive(handle, generation)
  local state = tracked[handle]
  return state ~= nil and not state.removing and (generation == nil or state.generation == generation)
end

return handle_ref
