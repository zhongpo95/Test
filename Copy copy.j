function RaceLib__WeatherSet takes nothing returns nothing
    local integer r=GetRandomInt(1,10)
    call EnableWeatherEffect(udg_RACE_RAIN,false)
    call EnableWeatherEffect(udg_RACE_SNOW,false)
    set RACE_WEATHER_BOOL[1]=false
    set RACE_WEATHER_BOOL[2]=false

    if(r<=2)then
        call EnableWeatherEffect(udg_RACE_RAIN,true)
        set RACE_WEATHER_BOOL[1]=true
        call DisplayTimedTextToPlayer(GetLocalPlayer(),0.0,0.0,10.0,"|CFFFFEA88비가 내리기 시작합니다.|r")
        if(TEAM_MODE)then
            call s__boardItem__set_value(s__boardY__getindex(s__board__getindex(T_MB,1),13),"|cffffd700날씨 : 비|r")
        endif
    endif

    if(r>2)and(r<=4)then
        call EnableWeatherEffect(udg_RACE_SNOW,true)
        set RACE_WEATHER_BOOL[2]=true
        call DisplayTimedTextToPlayer(GetLocalPlayer(),0.0,0.0,10.0,"|CFFFFEA88눈이 내리기 시작합니다.|r")
        if(TEAM_MODE)then
            call s__boardItem__set_value(s__boardY__getindex(s__board__getindex(T_MB,1),13),"|cffffd700날씨 : 눈|r")
        endif
    endif

    if(RACE_WEATHER_BOOL[1]==false)and(RACE_WEATHER_BOOL[2]==false)then
        if(TEAM_MODE)then
            call s__boardItem__set_value(s__boardY__getindex(s__board__getindex(T_MB,1),13),"|cffffd700날씨 : 맑음|r")
        endif
    endif
    
    endfunction