// OpenGL 영상 시제품의 로컬 재생과 종료 및 상태 확인 명령을 등록한다.
function ArcanaVideoTest_Report takes nothing returns nothing
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.00, 0.00, 20.00, "|cff80d8ff[VIDEO TEST]|r " + JNArcVideoStatus())
endfunction

function ArcanaVideoTest_Chat takes nothing returns nothing
    local string command = GetEventPlayerChatString()
    local integer result = 0
    if GetTriggerPlayer() == GetLocalPlayer() then
        if command == "-video" then
            set result = JNArcVideoOpen("arcana_video_test.mp4")
            if result == 0 then
                call ArcanaVideoTest_Report()
            endif
        elseif command == "-videoclose" then
            call JNArcVideoClose()
            call ArcanaVideoTest_Report()
        elseif command == "-videostatus" then
            call ArcanaVideoTest_Report()
        endif
    endif
endfunction

function ArcanaVideoTest_Ready takes nothing returns nothing
    call DestroyTimer(GetExpiredTimer())
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.00, 0.00, 45.00, "|cff80d8ff[VIDEO TEST]|r -video 재생 / -videoclose 닫기 / -videostatus 상태. 영상에 소리가 있으면 함께 재생합니다.")
    call ArcanaVideoTest_Report()
endfunction

function ArcanaVideoTest_Init takes nothing returns nothing
    local trigger chat = CreateTrigger()
    local timer ready = CreateTimer()
    local integer index = 0
    loop
        exitwhen index >= 12
        call TriggerRegisterPlayerChatEvent(chat, Player(index), "-video", false)
        set index = index + 1
    endloop
    call TriggerAddAction(chat, function ArcanaVideoTest_Chat)
    call TimerStart(ready, 12.00, false, function ArcanaVideoTest_Ready)
    set chat = null
    set ready = null
endfunction
