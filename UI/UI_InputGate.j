// 참가자 중 누군가 영웅을 고르면 같은 순서로 게임 UI 입력을 연결한다.
// 각 키 처리 함수가 누른 사람의 PickCheck를 따로 확인하므로, 다른 사람이 아직 안 골라도 고른 사람은 바로 쓸 수 있다.
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
        if not Ready then
            loop
                exitwhen pid == 4
                if PickCheck[pid] and GetPlayerSlotState(Player(pid)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(pid)) == MAP_CONTROL_USER then
                    set Ready = true
                endif
                set pid = pid + 1
            endloop
            if not Ready then
                return
            endif
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
