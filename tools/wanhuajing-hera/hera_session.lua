-- 중국 계정이나 서버 응답을 생성하지 않고 이번 게임의 임시 기록만 관리한다.
return function(env, note)
    local game = env.game
    local server = {cfg = {}, uids = {}, players_uid = {}, celeblist = {}, record_data = {player = {}, globals = {}}, temporary = true}
    game.myserver = server
    for id = 1, 16 do server.record_data.player[id] = {}; server.uids[id] = 0 end
    local player = game.player.__index
    function player:GetGameRecordData(key) return server.record_data.player[self.id][key] or '' end
    function player:SaveGameRecordData(key, value)
        server.record_data.player[self.id][key] = tostring(value)
        return false -- 외부 저장 성공을 의미하지 않는다.
    end
    function player:ClearGameRecordData(key) return self:SaveGameRecordData(key, '') end
    function player:GetPlayerUid() return 0 end
    function player:GetCelebData() return nil end
    function player:UpDatePlayerCeleb() return false end
    function server:GetCelebData(name) return self.celeblist[name] end
    function server:GetGlobalData(key) return self.record_data.globals[key] end
    function server:get_local_uid() return 0 end
    function server.UserIdToPlayer() return game.player[16] end
    server.post = {Init = function() end, send = function() note('Cloud request unavailable in temporary session'); return false end}
    function server.init()
        game.wait(0, function()
            game.instance:event_notify('新存档-读取玩家存档完毕')
            game.instance:event_notify('新存档-读取全局存档完毕')
            game.instance:event_notify('新存档-读取排行榜完毕')
            note('SESSION temporary defaults ready; cloud persistence unavailable')
        end)
    end
    return function(config)
        server.cfg = config or {}
        game.host_player = env.get_player_list()[1]
        for _, entry in ipairs(server.cfg.CelebList or {}) do server.celeblist[entry.name] = {} end
        server.init()
    end
end
