// 테스트2 채팅 출력 스크립트
scope Test2_Rerun initializer init

    private function Test2RerunAction takes nothing returns nothing
        call VJDebugMsg("ARCANA-55 테스트2 출력 이슈명 변경")
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer index = 0

        loop
            call TriggerRegisterPlayerChatEvent(t, Player(index), "-테스트", true)
            set index = index + 1
            exitwhen index == bj_MAX_PLAYERS
        endloop
        call TriggerAddAction(t, function Test2RerunAction)
        set t = null
    endfunction

endscope
