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
        private integer PreviousCard
        private integer NextCard
        private integer CardPage = 0
    endglobals

    private function CardPageClick takes nothing returns nothing
        if DzGetTriggerUIEventPlayer() != GetLocalPlayer() then
            return
        endif
        if DzGetTriggerUIEventFrame() == ExpUIButtons[PreviousCard] then
            set CardPage = IMaxBJ(0, CardPage - 1)
        elseif DzGetTriggerUIEventFrame() == ExpUIButtons[NextCard] then
            set CardPage = CardPage + 1
        endif
    endfunction

    private function Render takes nothing returns nothing
        local integer pid = GetPlayerId(GetLocalPlayer())
        local integer i = 1
        local integer remaining
        local integer level
        local integer count = 0
        local integer card = 0
        local string heads = ""
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
        elseif ExpState == EXP_HUNT then
            call ExpUIText(Hint, "사건으로 공간이 정지했을 때 배분 가능합니다.")
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
        if ExpPrototypeActive then
            set i = 1
            loop
                exitwhen i > 3
                if ProtoHeadOwned[ExpKey(pid, i)] then
                    set heads = heads + ProtoHeadName[i] + "   "
                endif
                set i = i + 1
            endloop
            if heads == "" then
                set heads = "없음"
            endif
            set i = PROTO_CARD_FIRST
            loop
                exitwhen i > PROTO_CARD_LAST
                if ExpCardOwned[ExpKey(pid, i)] then
                    set count = count + 1
                endif
                set i = i + 1
            endloop
            set CardPage = IMaxBJ(0, IMinBJ(CardPage, count - 1))
            set count = 0
            set i = PROTO_CARD_FIRST
            loop
                exitwhen i > PROTO_CARD_LAST
                if ExpCardOwned[ExpKey(pid, i)] then
                    if count == CardPage then
                        set card = i
                    endif
                    set count = count + 1
                endif
                set i = i + 1
            endloop
            set owned = "머리 카드 · " + heads + "|n"
            if card > 0 then
                set owned = owned + "보유 카드 " + I2S(count) + "장 · " + I2S(CardPage + 1) + "/" + I2S(count) + "|n[" + ExpEventGradeName(ProtoCardGrade[card]) + "] " + ProtoCardName[card] + "|n" + ProtoCardText(pid, card)
            else
                set owned = owned + "획득한 성장 카드 없음"
            endif
        endif
        call DzFrameShow(ExpUIButtons[PreviousCard], ExpPrototypeActive)
        call DzFrameShow(ExpUIButtons[NextCard], ExpPrototypeActive)
        call ExpUISetButton(PreviousCard, "이전", count > 0 and CardPage > 0)
        call ExpUISetButton(NextCard, "다음", CardPage + 1 < count)
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
        set Root = ExpUIRoot(EXP_UI_STATS, 0.52, 0.435, 0.540, true)
        set f = ExpUIHeader(Root, 0.52, "원정 성장·카드")
        set Points = ExpUILabel(Root, 0.024, 0.062, 0.47, 0.030, 0.013, "")
        set f = ExpUITexture(Root, 0.020, 0.103, 0.48, 0.062, "war3mapImported\\UI_Upgrade_Card.tga")
        set Crit = ExpUILabel(Root, 0.037, 0.114, 0.30, 0.046, 0.011, "")
        set AddCrit = ExpUIButton(Root, 0.358, 0.120, 0.125, 0.028, "+1 포인트", 101)
        set f = ExpUITexture(Root, 0.020, 0.174, 0.48, 0.062, "war3mapImported\\UI_Upgrade_Card.tga")
        set Swift = ExpUILabel(Root, 0.037, 0.185, 0.30, 0.046, 0.011, "")
        set AddSwift = ExpUIButton(Root, 0.358, 0.191, 0.125, 0.028, "+1 포인트", 102)
        set f = ExpUILabel(Root, 0.024, 0.251, 0.46, 0.020, 0.011, "이번 원정에서 획득한 효과")
        set Effects = ExpUILabel(Root, 0.024, 0.278, 0.47, 0.105, 0.009, "")
        set PreviousCard = ExpUIButton(Root, 0.024, 0.390, 0.060, 0.028, "이전", 0)
        set NextCard = ExpUIButton(Root, 0.090, 0.390, 0.060, 0.028, "다음", 0)
        call DzFrameSetScriptByCode(ExpUIButtons[PreviousCard], JN_FRAMEEVENT_MOUSE_UP, function CardPageClick, false)
        call DzFrameSetScriptByCode(ExpUIButtons[NextCard], JN_FRAMEEVENT_MOUSE_UP, function CardPageClick, false)
        set Reset = ExpUIButton(Root, 0.164, 0.390, 0.115, 0.028, "배분 초기화", 103)
        set Hint = ExpUILabel(Root, 0.294, 0.395, 0.202, 0.030, 0.0085, "")
        call TriggerAddAction(ExpRefresh, function Render)
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterTimerEventSingle(t, 0.03)
        call TriggerAddAction(t, function Build)
        set t = null
    endfunction
endlibrary
