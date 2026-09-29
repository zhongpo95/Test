-- 마우스 좌표의 로컬 읽기, 동기화 수신, 중력건 점 명령을 분리해서 검사한다.
local j = require('jass.common')
local api = require('jass.japi')
local message = require('jass.message')
local ME = j.GetPlayerId(j.GetLocalPlayer())
local SYNC, ACK = 'MT002XY', 'MT002ACK'
local CHANNEL = 1093681994 -- A0CJ
local ORDER = 852066 -- innerfire
local heroes, helpers, markers, orderMarkers = {}, {}, {}, {}
local latest, orderSeq, sampleSeq, runs = {}, {}, {}, {}
local syncReady, file = false, nil
local logPath = 'Logs/Hera_Mouse_Test_v002_p' .. (ME + 1) .. '.txt'
pcall(function() file = io.open(logPath, 'w') end)

local function log(text)
    if file then
        pcall(function() file:write(text .. '\n'); file:flush() end)
    end
end

local function say(text)
    j.DisplayTimedTextToPlayer(j.GetLocalPlayer(), 0, 0, 12, '[MT] ' .. text)
    log(text)
end

local function active(id)
    return id >= 0 and id < 6
        and j.GetPlayerSlotState(j.Player(id)) == j.ConvertPlayerSlotState(1)
        and j.GetPlayerController(j.Player(id)) == j.ConvertMapControl(0)
end

local function valid(x, y)
    return type(x) == 'number' and type(y) == 'number' and x == x and y == y
        and math.abs(x) <= 1900 and math.abs(y) <= 1900
end

local function once(delay, callback)
    local timer = j.CreateTimer()
    j.TimerStart(timer, delay, false, function()
        j.DestroyTimer(timer)
        callback()
    end)
end

local function totals(record)
    local count, expected = 0, 0
    for id = 0, 5 do
        if active(id) then
            expected = expected + 1
            if record.acks[id] then count = count + 1 end
        end
    end
    return count, expected
end

local function accept(source, kind, seq, x, y, payload)
    local key = source .. kind
    if latest[key] and seq <= latest[key].seq then return end
    local record = {seq = seq, x = x, y = y, payload = payload, acks = {}}
    latest[key] = record
    local marker = kind == 'O' and orderMarkers[source] or markers[source]
    j.SetUnitX(marker, x)
    j.SetUnitY(marker, y)
    log('RECEIVE ' .. payload)
    if syncReady and active(ME) then
        api.DzSyncData(ACK, source .. '|' .. kind .. '|' .. seq .. '|' .. ME .. '|' .. payload)
    end
    if seq == 1 then say('P' .. (source + 1) .. ' ' .. kind .. ' received ' .. x .. ', ' .. y) end
end

local function installSync()
    for _, name in ipairs({'DzTriggerRegisterSyncData', 'DzGetTriggerSyncData',
        'DzGetTriggerSyncPlayer', 'DzSyncData'}) do
        if type(api[name]) ~= 'function' then
            say('Missing API ' .. name .. '. Shared coordinate/receipt test disabled.')
            return
        end
    end
    local xy = j.CreateTrigger()
    log('BEFORE DzTriggerRegisterSyncData XY')
    api.DzTriggerRegisterSyncData(xy, SYNC, false)
    log('AFTER DzTriggerRegisterSyncData XY')
    j.TriggerAddAction(xy, function()
        local data = api.DzGetTriggerSyncData()
        if type(data) ~= 'string' then return end
        local s, kind, seq, x, y = data:match('^(%d)|([MD])|(%d+)|([%-%.%d]+)|([%-%.%d]+)$')
        s, seq, x, y = tonumber(s), tonumber(seq), tonumber(x), tonumber(y)
        local sender = j.GetPlayerId(api.DzGetTriggerSyncPlayer())
        if s ~= sender or not active(sender) or not seq or seq < 1 or not valid(x, y) then return end
        accept(s, kind, seq, x, y, data)
    end)
    local ack = j.CreateTrigger()
    log('BEFORE DzTriggerRegisterSyncData ACK')
    api.DzTriggerRegisterSyncData(ack, ACK, false)
    log('AFTER DzTriggerRegisterSyncData ACK')
    j.TriggerAddAction(ack, function()
        local data = api.DzGetTriggerSyncData()
        if type(data) ~= 'string' then return end
        local s, kind, seq, receiver, payload = data:match('^(%d)|([MDO])|(%d+)|(%d)|(.+)$')
        s, seq, receiver = tonumber(s), tonumber(seq), tonumber(receiver)
        if not s or not active(s) or not active(receiver or -1) then return end
        if receiver ~= j.GetPlayerId(api.DzGetTriggerSyncPlayer()) then return end
        local record = latest[s .. kind]
        if not record or record.seq ~= seq or record.payload ~= payload then return end
        record.acks[receiver] = true
        local count, expected = totals(record)
        log('ACK P' .. (s + 1) .. ' ' .. kind .. '#' .. seq .. ' peer=' .. (receiver + 1))
        if count == expected and seq == 1 then
            say('P' .. (s + 1) .. ' ' .. kind .. ' ACK ' .. count .. '/' .. expected .. ' PASS')
        end
    end)
    syncReady = true
end

local function sample(id, kind, send, quiet)
    local name = kind == 'D' and 'DzGetMouseTerrain' or 'message.mouse'
    log('BEFORE ' .. name)
    local ok, x, y = pcall(function()
        if kind == 'D' then return api.DzGetMouseTerrainX(), api.DzGetMouseTerrainY() end
        return message.mouse()
    end)
    log('AFTER ' .. name .. ' ok=' .. tostring(ok) .. ' x=' .. tostring(x) .. ' y=' .. tostring(y))
    if not ok then say(name .. ' Lua error: ' .. tostring(x)); return nil end
    if not valid(x, y) then say('Rejected invalid/off-map coordinates. Place cursor on terrain.'); return nil end
    if send then
        local key = id .. kind
        sampleSeq[key] = (sampleSeq[key] or 0) + 1
        local data = string.format('%d|%s|%d|%.2f|%.2f', id, kind, sampleSeq[key], x, y)
        api.DzSyncData(SYNC, data)
    elseif not quiet then
        say(name .. ' LOCAL ' .. string.format('%.2f, %.2f', x, y))
    end
    return x, y
end

local function status()
    for id = 0, 5 do
        if active(id) then
            for _, kind in ipairs({'M', 'D', 'O'}) do
                local record = latest[id .. kind]
                if record then
                    local count, expected = totals(record)
                    say(string.format('P%d %s #%d (%.2f, %.2f) ACK %d/%d %s',
                        id + 1, kind, record.seq, record.x, record.y, count, expected,
                        count == expected and 'PASS' or 'WAIT/FAIL'))
                end
            end
        end
    end
end

local function help()
    say('LUA READY. 2-6 players. Put cursor on terrain after sending command.')
    say('-local local read; -mouse one shared sample; -dz alternate API sample')
    say('-track 10s shared samples; -order 10s gravity-gun input; -stop; -status')
    say('M=message.mouse D=Dz mouse O=spell event. ACK N/N = peer receipts.')
    say('Logs: ' .. logPath .. (file and '' or ' (file unavailable; use screenshots)'))
end

local function start(id, mode)
    if runs[id] then
        if ME == id then say('A run is active. Use -stop first.') end
        return
    end
    local run = {stop = false, localFailed = false}
    runs[id] = run
    if ME == id then say(mode .. ' starts in 1 second. Move cursor onto terrain.') end
    once(1, function()
        local tick, limit = 0, (mode == 'order' and 100 or (mode == 'track' and 50 or 1))
        local timer = j.CreateTimer()
        j.TimerStart(timer, mode == 'track' and 0.2 or 0.1, true, function()
            tick = tick + 1
            -- 타이머 수명과 종료는 모든 클라이언트에서 같은 조건으로 처리한다.
            if ME == id and not run.stop and not run.localFailed then
                local ok, err = pcall(function()
                    if mode == 'order' then
                        log('BEFORE ClearSelection/SelectUnit helper tick=' .. tick)
                        j.ClearSelection()
                        j.SelectUnit(helpers[id], true)
                        local x, y = sample(id, 'M', false, true)
                        if x then
                            log('BEFORE message.order_point tick=' .. tick)
                            message.order_point(ORDER, x, y)
                            log('AFTER message.order_point tick=' .. tick)
                        end
                        j.ClearSelection()
                        j.SelectUnit(heroes[id], true)
                        log('AFTER restore selection tick=' .. tick)
                    else
                        sample(id, mode == 'dz' and 'D' or 'M', mode ~= 'local')
                    end
                end)
                if not ok then
                    run.localFailed = true
                    say('Stopped local input after Lua error: ' .. tostring(err))
                    j.ClearSelection()
                    j.SelectUnit(heroes[id], true)
                end
            end
            if tick >= limit or run.stop then
                j.DestroyTimer(timer)
                runs[id] = nil
                if ME == id then say(mode .. ' finished. Use -status for shared receipts.') end
            end
        end)
    end)
end

for id = 0, 5 do
    local x = -750 + id * 300
    for other = 0, 5 do
        j.SetPlayerAlliance(j.Player(id), j.Player(other), j.ConvertAllianceType(0), true)
    end
    heroes[id] = j.CreateUnit(j.Player(id), 1751543663, x, -600, 90) -- hfoo
    helpers[id] = j.CreateUnit(j.Player(id), 1751543663, x, -850, 90)
    j.UnitAddAbility(helpers[id], CHANNEL)
    j.SetUnitInvulnerable(heroes[id], true)
    j.SetUnitInvulnerable(helpers[id], true)
    j.SetUnitMoveSpeed(helpers[id], 0)
    markers[id] = j.CreateUnit(j.Player(id), 1751543663, x, 200, 90)
    orderMarkers[id] = j.CreateUnit(j.Player(id), 1751543663, x, 500, 90)
    for _, marker in ipairs({markers[id], orderMarkers[id]}) do
        j.SetUnitInvulnerable(marker, true)
        j.SetUnitScale(marker, 0.55, 0.55, 0.55)
        j.SetUnitPathing(marker, false)
        j.UnitAddAbility(marker, 1097625443) -- Aloc
    end
    orderSeq[id] = 0
    local fog = j.CreateFogModifierRect(j.Player(id), j.ConvertFogState(4), j.GetWorldBounds(), true, false)
    j.FogModifierStart(fog)
end

installSync()
local spell = j.CreateTrigger()
for id = 0, 5 do j.TriggerRegisterPlayerUnitEvent(spell, j.Player(id), j.ConvertPlayerUnitEvent(274), nil) end
j.TriggerAddAction(spell, function()
    if j.GetSpellAbilityId() ~= CHANNEL then return end
    local id = j.GetPlayerId(j.GetOwningPlayer(j.GetTriggerUnit()))
    if j.GetTriggerUnit() ~= helpers[id] then return end
    local x, y = j.GetSpellTargetX(), j.GetSpellTargetY()
    if not valid(x, y) then return end
    orderSeq[id] = orderSeq[id] + 1
    local data = string.format('%d|O|%d|%.2f|%.2f', id, orderSeq[id], x, y)
    accept(id, 'O', orderSeq[id], x, y, data)
end)

local chat = j.CreateTrigger()
for id = 0, 5 do j.TriggerRegisterPlayerChatEvent(chat, j.Player(id), '-', false) end
j.TriggerAddAction(chat, function()
    local id = j.GetPlayerId(j.GetTriggerPlayer())
    local cmd = j.GetEventPlayerChatString():lower()
    local mode = ({['-local'] = 'local', ['-mouse'] = 'mouse', ['-dz'] = 'dz',
        ['-track'] = 'track', ['-order'] = 'order'})[cmd]
    if cmd == '-status' then status()
    elseif cmd == '-help' then if ME == id then help() end
    elseif cmd == '-stop' then
        if runs[id] then runs[id].stop = true end
    elseif mode then
        if (mode == 'mouse' or mode == 'dz' or mode == 'track') and not syncReady then
            if ME == id then say('Sync API unavailable. Use -local to test only the local reader.') end
        elseif mode == 'order' and type(message.order_point) ~= 'function' then
            if ME == id then say('Missing message.order_point') end
        elseif mode == 'dz' and (type(api.DzGetMouseTerrainX) ~= 'function' or type(api.DzGetMouseTerrainY) ~= 'function') then
            if ME == id then say('Missing DzGetMouseTerrainX/Y') end
        else start(id, mode) end
    end
end)
j.PanCameraToTimed(0, 0, 0)
j.SetCameraField(j.ConvertCameraField(0), 2200, 0)
j.ClearSelection()
j.SelectUnit(heroes[ME] or heroes[0], true)
help()
