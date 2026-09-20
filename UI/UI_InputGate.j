// 로딩 화면의 전역 입력을 막고 영웅 선택 이후에만 게임 UI 입력을 연결한다.
library UIInputGate initializer Init requires Native, DzAPIHardware
    globals
        private trigger array Bindings
        private integer BindingCount = 0
        private integer BoundCount = 0
    endglobals

    function UIInputAfterPick takes code binding returns nothing
        set BindingCount = BindingCount + 1
        set Bindings[BindingCount] = CreateTrigger()
        call TriggerAddCondition(Bindings[BindingCount], Condition(binding))
    endfunction

    private function Tick takes nothing returns nothing
        local integer pid = GetPlayerId(GetLocalPlayer())
        if pid >= 4 or not PickCheck[pid] then
            return
        endif
        // 핸들 생성은 모든 클라이언트에서 수행하고, 로컬 입력 등록만 선택 이후에 실행한다.
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
