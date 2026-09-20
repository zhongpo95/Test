// M 키로 원정의 경로와 현재 위치만 확인하는 지도를 표시한다.
library UIMap initializer Init requires UIExpeditionCommon, UIInputGate
    globals
        private integer Root
        private integer Status
        private integer array Nodes
        private integer array NodeLabels
        boolean array FMap_OnOff
    endglobals

    private function Render takes nothing returns nothing
        local integer pid = GetPlayerId(GetLocalPlayer())
        local integer current = 1
        local integer i = 1
        local string name
        local string status
        if Root == 0 or pid > 3 or not PickCheck[pid] then
            return
        endif
        set FMap_OnOff[pid] = ExpUIPanel == EXP_UI_MAP
        if ExpNode >= 6 then
            set current = 4
        elseif ExpNode >= 4 then
            set current = 3
        elseif ExpNode >= 2 then
            set current = 2
        endif
        loop
            exitwhen i > 4
            set name = JNStringSplit("출발|정찰 · 전투|상점|보스", "|", i - 1)
            if ExpMember[pid] and i == current then
                call DzFrameSetTexture(Nodes[i], "war3mapImported\\UI_Upgrade_Selected.tga", 0)
                set name = "|cff07516b현재 위치|r|n" + name
            else
                call DzFrameSetTexture(Nodes[i], "war3mapImported\\UI_Upgrade_Card.tga", 0)
            endif
            call ExpUIText(NodeLabels[i], name)
            set i = i + 1
        endloop
        set status = "출발 전"
        if ExpMember[pid] then
            set status = "팀 라이프 " + I2S(ExpLife) + "    원정 골드 " + I2S(ExpGold[pid]) + " G"
            if ExpState == EXP_BATTLE then
                set status = status + "|n전투 진행 " + I2S(R2I(ExpProgress * 100)) + "%    남은 시간 " + I2S(ExpSeconds) + "초"
            endif
        elseif ExpState == EXP_RESULT then
            set status = "원정 종료"
        endif
        call ExpUIText(Status, status)
    endfunction

    private function Toggle takes nothing returns nothing
        local integer pid = GetPlayerId(GetLocalPlayer())
        if pid < 4 and PickCheck[pid] then
            if ExpUIPanel == EXP_UI_MAP then
                call ExpUIOpen(0)
            else
                call ExpUIOpen(EXP_UI_MAP)
            endif
        endif
    endfunction

    function SetMapLine takes integer pid returns nothing
        // 영웅 선택의 기존 진입점은 출발 준비 창에 연결한다.
        if GetLocalPlayer() == Player(pid) then
            call ExpUIOpen(EXP_UI_LOBBY)
        endif
    endfunction

    private function Build takes nothing returns nothing
        local integer i = 1
        local integer f
        set Root = ExpUIRoot(EXP_UI_MAP, 0.64, 0.265, 0.465, true)
        set f = ExpUIHeader(Root, 0.64, "원정 지도")
        set Status = ExpUILabel(Root, 0.025, 0.066, 0.58, 0.043, 0.011, "")
        loop
            exitwhen i > 4
            set Nodes[i] = ExpUITexture(Root, 0.024 + (i - 1) * 0.152, 0.128, 0.137, 0.085, "war3mapImported\\UI_Upgrade_Card.tga")
            set NodeLabels[i] = ExpUILabel(Root, 0.035 + (i - 1) * 0.152, 0.150, 0.115, 0.048, 0.011, "")
            if i < 4 then
                set f = ExpUILabel(Root, 0.162 + (i - 1) * 0.152, 0.156, 0.015, 0.023, 0.013, ">")
            endif
            set i = i + 1
        endloop
        call TriggerAddAction(ExpRefresh, function Render)
    endfunction

    private function BindInput takes nothing returns boolean
        if Root == 0 then
            return false
        endif
        call DzTriggerRegisterKeyEventByCode(null, JN_OSKEY_M, 1, false, function Toggle)
        return true
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterTimerEventSingle(t, 0.03)
        call TriggerAddAction(t, function Build)
        set t = null
        call UIInputAfterPick(function BindInput)
    endfunction
endlibrary
