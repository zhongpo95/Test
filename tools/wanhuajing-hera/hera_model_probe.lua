-- 건축사의 원본 메시를 기본 텍스처와 두 네이티브 경로로 비교하고 원래 모델로 복귀한다.
return function(port)
    local game, jass, japi = port.env.game, require('jass.common'), require('jass.japi')
    local active = {}
    local probe_path = 'HeraWanhua\\builder_probe.mdx'
    local function stop(player)
        local state = active[player.id]
        if not state then return end
        active[player.id] = nil
        for _, effect in ipairs(state.effects) do jass.DestroyEffect(effect) end
        local hero = state.hero
        if not hero.removed and player.hero == hero then
            local model = hero._model and hero._model[1] and hero._model[1][1]
            japi.SetUnitModel(hero.handle, model and model:get_path() or state.original)
        end
        port.note('MODEL PROBE restored p' .. player.id)
        player:sendMsg('모델 진단 종료. 원래 모델로 복귀했습니다.')
    end
    game.register_chat_command('hwmodel,모델진단', function(player)
        if active[player.id] then stop(player); return end
        local hero = player.hero
        local model = hero and hero._model and hero._model[1] and hero._model[1][1]
        if not hero or hero.removed or not model or model:get_path() ~= '-909478866.mdx' then
            player:sendMsg('모델 진단은 기본 건축사가 생성된 뒤에 사용할 수 있습니다.')
            return
        end
        local x, y = jass.GetUnitX(hero.handle), jass.GetUnitY(hero.handle)
        local state = {hero = hero, original = model:get_path(), effects = {}}
        active[player.id] = state
        port.note(string.format('MODEL PROBE p%d type=%s path=%s hidden=%s rgba=%s/%s/%s/%s size=%s',
            player.id, tostring(jass.GetUnitTypeId(hero.handle)), state.original,
            tostring(jass.IsUnitHidden(hero.handle)), tostring(hero.red), tostring(hero.green),
            tostring(hero.blue), tostring(hero.alpha), tostring(hero:get_size())))
        for _, path in ipairs({state.original, probe_path, 'MH-819509167.blp', 'MH933634193.blp'}) do
            local data = require('jass.storm').load(path)
            local header = data and data:sub(1, 4):gsub('.', function(c) return string.format('%02x', c:byte()) end)
            port.note('MODEL RESOURCE ' .. path .. ' bytes=' .. (data and #data or 0) .. ' header=' .. (header or 'missing'))
        end
        japi.SetUnitModel(hero.handle, probe_path)
        state.effects[1] = jass.AddSpecialEffect(probe_path, x + 350, y)
        state.effects[2] = jass.AddSpecialEffect('Units\\Human\\Footman\\Footman.mdx', x - 350, y)
        port.note('MODEL PROBE requested gray unit, gray effect and Footman effect; visibility needs visual confirmation')
        player:sendMsg('30초 모델 진단. 건축사는 회색 메시로 바뀌며 양옆에 회색 복사본과 풋맨이 나타나야 합니다. 다시 -hwmodel 입력 시 즉시 복귀합니다.')
        game.wait(30000, function() if active[player.id] == state then stop(player) end end)
    end)
end
