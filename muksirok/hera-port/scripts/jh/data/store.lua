-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local Store = {}

local function ensure(unit)
  if not unit.user_data then
    unit.user_data = {}
  end
  return unit.user_data
end

function Store.set(unit, key, value)
  local data = ensure(unit)
  if value == nil then
    value = true
  end
  data[key] = value
end

function Store.clear(unit)
  unit.user_data = {}
end

function Store.set_timed(unit, key, time, value)
  if not time then
    time = 0
    print("settimedata暂时性数据未设置时间")
    printCallStack()
  end
  Store.set(unit, key, value)
  local trace_mark = key == "位移体力消耗标记" and unit.type == 1211117621
  if trace_mark then
    require("hera_gameplay_diagnostic").monster("QW_MARK_SET", {unit=unit.handle, due=ac.clock() + 1000 * time})
  end
  ac.wait(1000 * time, function()
    if trace_mark then
      require("hera_gameplay_diagnostic").monster("QW_MARK_EXPIRE_BEGIN", {unit=unit.handle, present=Store.has(unit, key)})
    end
    Store.delete(unit, key)
    if trace_mark then
      require("hera_gameplay_diagnostic").monster("QW_MARK_EXPIRE_END", {unit=unit.handle, present=Store.has(unit, key)})
    end
  end)
end

function Store.get(unit, key)
  local data = ensure(unit)
  if data[key] ~= nil then
    return data[key]
  end
  return 0
end

function Store.delete(unit, key)
  local data = ensure(unit)
  data[key] = nil
end

function Store.has(unit, key)
  local data = unit.user_data
  if data and data[key] then
    return true
  end
  return false
end

return Store
