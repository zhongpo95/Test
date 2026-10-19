// 모든 참가자의 영웅 선택 이후 같은 순서로 게임 UI 입력을 연결한다.
library UIInputGate initializer Init requires Native, DzAPIHardware
    globals
        private trigger array Bindings
        private integer BindingCount = 0
        private integer BoundCount = 0
        private boolean Ready = false
    endglobals

    function UIInputAfterPick takes code binding returns nothing
        set BindingCount = BindingCount + 1
        set Bindings[BindingCount] = CreateTrigger()
        call TriggerAddCondition(Bindings[BindingCount], Condition(binding))
    endfunction

    private function Tick takes nothing returns nothing
        local integer pid = 0
        local boolean playing = false
        if not Ready then
            loop
                exitwhen pid == 4
                if GetPlayerSlotState(Player(pid)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(pid)) == MAP_CONTROL_USER then
                    set playing = true
                    if not PickCheck[pid] then
                        return
                    endif
                endif
                set pid = pid + 1
            endloop
            if not playing then
                return
            endif
            set Ready = true
        endif
        // TriggerEvaluate와 ByCode 등록도 로컬 분기 없이 모든 클라이언트에서 실행한다.
        loop
            exitwhen BoundCount >= BindingCount
            if not TriggerEvaluate(Bindings[BoundCount + 1]) then
                return
            endif
            set BoundCount = BoundCount + 1
        endloop
    endfunction

    private function Init takes nothing returns nothing
        call TimerStart(CreateTimer(), 0.1, true, function Tick)
    endfunction
endlibrary
