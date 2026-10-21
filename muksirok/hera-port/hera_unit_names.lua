-- 엔진 이름 변경이 없는 환경에서 개별 유닛의 Lua 이름과 수명을 관리한다.
local M = {}
local installed = false

function M.install()
  if installed then return end
  local japi = require("jass.japi")
  local names, proper = {}, {}
  local get_name, get_proper = GetUnitName, GetHeroProperName
  local remove = RemoveUnit
  local function clear(unit)
    names[unit], proper[unit] = nil, nil
  end
  local function setter(values)
    return function(unit, value)
      assert(unit and unit ~= 0 and GetUnitTypeId(unit) ~= 0, "HERA_UNIT_NAME_INVALID_UNIT")
      assert(type(value) == "string", "HERA_UNIT_NAME_INVALID_TEXT")
      values[unit] = value
    end
  end
  local changed = false
  if type(japi.SetUnitName) ~= "function" then
    rawset(japi, "SetUnitName", setter(names))
    GetUnitName = function(unit)
      return names[unit] or get_name(unit)
    end
    changed = true
  end
  if type(japi.SetUnitProperName) ~= "function" then
    rawset(japi, "SetUnitProperName", setter(proper))
    GetHeroProperName = function(unit)
      return proper[unit] or get_proper(unit)
    end
    changed = true
  end
  if changed then
    RemoveUnit = function(unit)
      clear(unit)
      return remove(unit)
    end
    for _, key in ipairs({"CreateUnit", "CreateUnitByName", "CreateUnitAtLoc", "CreateUnitAtLocByName"}) do
      local create = _G[key]
      if type(create) == "function" then
        _G[key] = function(...)
          local unit = create(...)
          if unit and unit ~= 0 then clear(unit) end
          return unit
        end
      end
    end
    local boot = package.loaded["hera_boot"]
    if boot then boot.note("COMPAT unit names: per-instance Lua getters; engine nameplates unchanged") end
  end
  installed = true
end

return M
