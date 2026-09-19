// 원정 스탯 배분과 획득한 성장 효과를 선택지와 분리하여 표시한다.
library UIExpeditionStats initializer Init requires UIExpeditionCommon
    globals
        private integer Root
        private integer Points
        private integer Crit
        private integer Swift
        private integer Effects
        private integer Hint
        private integer AddCrit
        private integer AddSwift
        private integer Reset
    endglobals

    private function Render takes nothing returns nothing
        local integer pid = GetPlayerId(GetLocalPlayer())
        local integer i = 1
        local integer remaining
        local integer level
        local boolean editable
        local string owned = ""
        if Root == 0 or pid > 3 or not PickCheck[pid] then
            return
        endif
        set remaining = ExpPoints[pid] - ExpCritPoints[pid] - ExpSwiftPoints[pid]
        set editable = ExpCanAllocate(pid)
        call ExpUIText(Points, "남은 포인트  |cff07516b" + I2S(remaining) + "|r    획득 " + I2S(ExpPoints[pid]) + "/40")
        call ExpUIText(Crit, "치명    " + I2S(ExpCritPoints[pid]) + "/30|n원정 추가 치명  +" + I2S(ExpCritPoints[pid] * 60 + ExpFixedCrit[pid]))
        call ExpUIText(Swift, "신속    " + I2S(ExpSwiftPoints[pid]) + "/30|n원정 추가 신속  +" + I2S(ExpSwiftPoints[pid] * 60 + ExpFixedSwift[pid]))
        call ExpUISetButton(AddCrit, "+1 포인트", editable and remaining > 0 and ExpCritPoints[pid] < 30)
        call ExpUISetButton(AddSwift, "+1 포인트", editable and remaining > 0 and ExpSwiftPoints[pid] < 30)
        call ExpUISetButton(Reset, "배분 초기화", editable and ExpCritPoints[pid] + ExpSwiftPoints[pid] > 0)
        if not editable then
            call ExpUISetButton(AddCrit, "배분 불가", false)
            call ExpUISetButton(AddSwift, "배분 불가", false)
        elseif remaining <= 0 then
            call ExpUISetButton(AddCrit, "포인트 없음", false)
            call ExpUISetButton(AddSwift, "포인트 없음", false)
        else
            if ExpCritPoints[pid] >= 30 then
                call ExpUISetButton(AddCrit, "최대 30포인트", false)
            endif
            if ExpSwiftPoints[pid] >= 30 then
                call ExpUISetButton(AddSwift, "최대 30포인트", false)
            endif
        endif
        if ExpState == EXP_BATTLE then
            call ExpUIText(Hint, "전투 중에는 배분할 수 없습니다.")
        elseif editable then
            call ExpUIText(Hint, "1포인트당 +60 · 비전투 중 배분 가능")
        else
            call ExpUIText(Hint, "원정을 시작하면 배분할 수 있습니다.")
        endif
        loop
            exitwhen i > 12
            if ExpCardOwned[ExpKey(pid, i)] then
                set owned = owned + ExpCardName(i) + "   "
            endif
            set i = i + 1
        endloop
        if owned == "" then
            set owned = "획득한 카드 없음"
        endif
        set owned = owned + "|n"
        set i = 0
        loop
            exitwhen i > 53
            set level = ExpArcana[ExpKey(pid, i)]
            if level > 0 then
                set owned = owned + ArcanaText[i] + " +" + I2S(level) + "   "
            endif
            set i = i + 1
        endloop
        call ExpUIText(Effects, owned)
    endfunction

    private function Build takes nothing returns nothing
        local integer f
        set Root = ExpUIRoot(EXP_UI_STATS, 0.52, 0.39, 0.518, true)
        set f = ExpUIHeader(Root, 0.52, "원정 스탯")
        set Points = ExpUILabel(Root, 0.024, 0.062, 0.47, 0.030, 0.013, "")
        set f = ExpUITexture(Root, 0.020, 0.103, 0.48, 0.062, "war3mapImported\\UI_Upgrade_Card.tga")
        set Crit = ExpUILabel(Root, 0.037, 0.114, 0.30, 0.046, 0.011, "")
        set AddCrit = ExpUIButton(Root, 0.358, 0.120, 0.125, 0.028, "+1 포인트", 101)
        set f = ExpUITexture(Root, 0.020, 0.174, 0.48, 0.062, "war3mapImported\\UI_Upgrade_Card.tga")
        set Swift = ExpUILabel(Root, 0.037, 0.185, 0.30, 0.046, 0.011, "")
        set AddSwift = ExpUIButton(Root, 0.358, 0.191, 0.125, 0.028, "+1 포인트", 102)
        set f = ExpUILabel(Root, 0.024, 0.251, 0.46, 0.020, 0.011, "이번 원정에서 획득한 효과")
        set Effects = ExpUILabel(Root, 0.024, 0.278, 0.47, 0.066, 0.0085, "")
        set Reset = ExpUIButton(Root, 0.024, 0.350, 0.133, 0.028, "배분 초기화", 103)
        set Hint = ExpUILabel(Root, 0.177, 0.355, 0.315, 0.030, 0.009, "")
        call TriggerAddAction(ExpRefresh, function Render)
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterTimerEventSingle(t, 0.03)
        call TriggerAddAction(t, function Build)
        set t = null
    endfunction
endlibrary
