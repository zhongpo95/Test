// 테스트3 재실행 채팅 출력 스크립트
scope Test3_Rerun initializer init

    private function Test3RerunAction takes nothing returns nothing
        call VJDebugMsg("테스트3")
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer index = 0

        loop
            call TriggerRegisterPlayerChatEvent(t, Player(index), "-테스트", true)
            set index = index + 1
            exitwhen index == bj_MAX_PLAYERS
        endloop
        call TriggerAddAction(t, function Test3RerunAction)
        set t = null
    endfunction

endscope
