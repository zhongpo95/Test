-- 전용 모델 교체 풀 대신 워크래프트 기본 효과 생성·부착·해제를 사용한다.
return function(env, note)
    local common, dbg = require('jass.common'), require('jass.debug')
    local add, target, destroy = common.AddSpecialEffect, common.AddSpecialEffectTarget, common.DestroyEffect
    local models, created, destroyed, live = {}, 0, 0, 0
    local game = env.game
    game.nAddSpecialEffect, game.nAddSpecialEffectTarget, game.nDestroyEffect = add, target, destroy
    local function retain(handle, path)
        dbg.handle_ref(handle)
        models[handle] = path
        created, live = created + 1, live + 1
        return handle
    end
    rawset(common, 'AddSpecialEffect', function(path, x, y) return retain(add(path, x, y), path) end)
    rawset(common, 'AddSpecialEffectTarget', function(path, widget, attachment, immediate, alternate)
        return retain(target(alternate or path, widget, attachment), alternate or path)
    end)
    rawset(common, 'DestroyEffect', function(handle)
        if models[handle] then
            models[handle] = nil
            destroyed, live = destroyed + 1, live - 1
            destroy(handle)
            dbg.handle_unref(handle)
        else destroy(handle) end
    end)
    function game.get_effect_pool_data() return created, destroyed, live, 0, 0 end
    function game.get_showing_effect_models()
        local result = {}
        for _, path in pairs(models) do result[path] = (result[path] or 0) + 1 end
        return result
    end
    function game.set_target_effect_display(handle, path)
        if models[handle] ~= path then note('LIMITATION attached effect model swap unavailable: ' .. tostring(path)) end
    end
end
