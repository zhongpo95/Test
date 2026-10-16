// 마우스 좌표 멀티플레이 시험 맵의 기본 환경과 Lua 진입을 초기화한다.
native EXExecuteScript takes string script returns string
native DzTriggerRegisterSyncData takes trigger trig, string prefix, boolean server returns nothing
native DzSyncData takes string prefix, string data returns nothing
native DzGetTriggerSyncData takes nothing returns string
native DzGetTriggerSyncPlayer takes nothing returns player
native DzGetMouseTerrainX takes nothing returns real
native DzGetMouseTerrainY takes nothing returns real

function MouseTestBoot takes nothing returns nothing
    local string result
    call DestroyTimer(GetExpiredTimer())
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 30, "Mouse Multiplayer Test v004. Hera/JN Lua engine required.")
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 30, "Starting Lua diagnostic. LUA READY or a boot error should appear below.")
    // EXExecuteScript는 입력을 return (...)으로 감싸므로 하나의 식을 전달한다.
    set result = EXExecuteScript("(function() local ok, err = pcall(require, 'mouse_test'); if ok then return 'MT LUA READY' else return 'MT LUA ERROR ' .. tostring(err) end end)()")
    if result == null or result == "" then
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 30, "MT LUA BOOT FAILED: EXExecuteScript returned no result.")
    else
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 30, result)
    endif
endfunction

function main takes nothing returns nothing
    call SetCameraBounds(-1536, -1536, 1536, 1536, -1536, 1536, 1536, -1536)
    call SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl")
    call InitBlizzard()
    call SetTimeOfDay(12)
    call SuspendTimeOfDay(true)
    call TimerStart(CreateTimer(), 3.0, false, function MouseTestBoot)
endfunction

function config takes nothing returns nothing
    local integer i = 0
    call SetMapName("Hera Mouse Multiplayer Test v004")
    call SetMapDescription("2-6 human players. Mouse sampling, sync receipts and gravity-gun point-order test. Commands shown in game.")
    call SetPlayers(6)
    call SetTeams(6)
    call SetGamePlacement(MAP_PLACEMENT_USE_MAP_SETTINGS)
    loop
        exitwhen i == 6
        call DefineStartLocation(i, -750 + i * 300, -600)
        call SetPlayerStartLocation(Player(i), i)
        call ForcePlayerStartLocation(Player(i), i)
        call SetPlayerController(Player(i), MAP_CONTROL_USER)
        call SetPlayerRacePreference(Player(i), RACE_PREF_HUMAN)
        call SetPlayerRaceSelectable(Player(i), false)
        call SetPlayerColor(Player(i), ConvertPlayerColor(i))
        call SetPlayerTeam(Player(i), i)
        set i = i + 1
    endloop
endfunction
