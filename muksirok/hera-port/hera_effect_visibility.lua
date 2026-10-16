-- 표시 네이티브가 없는 이펙트의 숨김과 크기 갱신을 같은 수명 안에서 보존한다.
local M = {}
local japi = require("jass.japi")
local handle_ref = require("jh.base.handle_ref")
local reported = false

function M.new(effect, scale)
  local generation = handle_ref.generation(effect)
  local native_visible = type(japi.EXSetEffectVisible) == "function"
  local hidden = false
  local height
  local controller = {}

  local function alive()
    return generation ~= nil and handle_ref.is_alive(effect, generation)
  end

  function controller:set_visible(visible)
    if not alive() then return false end
    if native_visible then
      japi.EXSetEffectVisible(effect, visible)
    elseif visible then
      if hidden then
        japi.EXSetEffectZ(effect, height)
        japi.EXSetEffectSize(effect, scale)
      end
    elseif not hidden then
      height = japi.EXGetEffectZ(effect)
      japi.EXSetEffectSize(effect, 0)
      japi.EXSetEffectZ(effect, -100000)
      if not reported then
        reported = true
        local boot = package.loaded["hera_boot"]
        if boot and boot.note then
          pcall(boot.note, "VISUAL visibility fallback: preserve scale/height and restore on show", true)
        end
      end
    end
    hidden = not visible
    return true
  end

  function controller:set_size(value)
    if not alive() then return false end
    scale = value
    -- 숨긴 동안의 배율 변경은 재표시할 때 적용한다.
    if native_visible or not hidden then
      japi.EXSetEffectSize(effect, value)
    end
    return true
  end

  return controller
end

return M
