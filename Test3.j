// 테스트3 채팅 출력 스크립트
scope Test3 initializer init

    private function Test3Action takes nothing returns nothing
        call VJDebugMsg("ARCANA-55 테스트3 출력 이슈명 변경")
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer index = 0

        loop
            call TriggerRegisterPlayerChatEvent(t, Player(index), "-테스트", true)
            set index = index + 1
            exitwhen index == bj_MAX_PLAYERS
        endloop
        call TriggerAddAction(t, function Test3Action)
        set t = null
    endfunction

endscope
