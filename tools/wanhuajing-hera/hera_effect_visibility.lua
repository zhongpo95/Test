-- 숨겨진 효과의 논리 크기를 유지하고 다시 표시할 때 최신 크기를 복원한다.
return function(common, japi)
    if type(japi.EXSetEffectVisible) == 'function' then return end
    local get_size, set_size = japi.EXGetEffectSize, japi.EXSetEffectSize
    local hidden = {}
    rawset(japi, 'EXSetEffectVisible', function(handle, visible)
        if visible then
            if hidden[handle] ~= nil then
                local size = hidden[handle]
                hidden[handle] = nil
                set_size(handle, size)
            end
        elseif hidden[handle] == nil then
            hidden[handle] = get_size(handle)
            set_size(handle, 0)
        end
    end)
    rawset(japi, 'EXSetEffectSize', function(handle, size)
        if hidden[handle] ~= nil then hidden[handle] = size
        else return set_size(handle, size) end
    end)
    rawset(japi, 'EXGetEffectSize', function(handle)
        if hidden[handle] ~= nil then return hidden[handle] end
        return get_size(handle)
    end)
    local destroy = common.DestroyEffect
    rawset(common, 'DestroyEffect', function(handle)
        hidden[handle] = nil
        return destroy(handle)
    end)
end
