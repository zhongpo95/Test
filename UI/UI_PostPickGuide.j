// 캐릭터 선택 직후 다음 목표 안내 패널
library UIPostPickGuide initializer Init requires UIMap, FrameCount
    globals
        integer FPostPickGuide_BackDrop
        integer FPostPickGuide_Title
        integer FPostPickGuide_Text
        integer FPostPickGuide_MapButton
        integer FPostPickGuide_CloseButton

        boolean array FPostPickGuide_OnOff
        boolean array FPostPickGuide_Shown
    endglobals

    function HidePostPickGuide takes integer pid returns nothing
        if Player(pid) == GetLocalPlayer() then
            call DzFrameShow(FPostPickGuide_BackDrop, false)
        endif
        set FPostPickGuide_OnOff[pid] = false
    endfunction

    function ShowPostPickGuide takes integer pid returns nothing
        if FPostPickGuide_Shown[pid] == true then
            return
        endif

        set FPostPickGuide_Shown[pid] = true
        set FPostPickGuide_OnOff[pid] = true

        if Player(pid) == GetLocalPlayer() then
            call DzFrameShow(FPostPickGuide_BackDrop, true)
        endif
    endfunction

    private function ClickMapButton takes nothing returns nothing
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())

        call HidePostPickGuide(pid)
        call ShowMapForGuide(pid)
    endfunction

    private function ClickCloseButton takes nothing returns nothing
        call HidePostPickGuide(GetPlayerId(DzGetTriggerUIEventPlayer()))
    endfunction

    private function ESCAction takes nothing returns nothing
        local integer pid = GetPlayerId(GetTriggerPlayer())

        if FPostPickGuide_OnOff[pid] == true then
            call HidePostPickGuide(pid)
        endif
    endfunction

    private function Main takes nothing returns nothing
        set FPostPickGuide_BackDrop = DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "StandardEditBoxBackdropTemplate", FrameCount())
        call DzFrameSetAbsolutePoint(FPostPickGuide_BackDrop, JN_FRAMEPOINT_CENTER, 0.40, 0.13)
        call DzFrameSetSize(FPostPickGuide_BackDrop, 0.32, 0.13)

        set FPostPickGuide_Title = DzCreateFrameByTagName("TEXT", "", FPostPickGuide_BackDrop, "", FrameCount())
        call DzFrameSetPoint(FPostPickGuide_Title, JN_FRAMEPOINT_TOPLEFT, FPostPickGuide_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.018, -0.018)
        call DzFrameSetText(FPostPickGuide_Title, "모험 준비 완료")

        set FPostPickGuide_Text = DzCreateFrameByTagName("TEXT", "", FPostPickGuide_BackDrop, "", FrameCount())
        call DzFrameSetPoint(FPostPickGuide_Text, JN_FRAMEPOINT_TOPLEFT, FPostPickGuide_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.018, -0.045)
        call DzFrameSetText(FPostPickGuide_Text, "M 키로 지도를 열고 첫 경로를 선택하세요.|n전투, 사건, 상점 중 하나를 고르면 진행이 시작됩니다.")

        set FPostPickGuide_MapButton = DzCreateFrameByTagName("GLUETEXTBUTTON", "", FPostPickGuide_BackDrop, "ScriptDialogButton", FrameCount())
        call DzFrameSetPoint(FPostPickGuide_MapButton, JN_FRAMEPOINT_BOTTOMLEFT, FPostPickGuide_BackDrop, JN_FRAMEPOINT_BOTTOMLEFT, 0.018, 0.018)
        call DzFrameSetSize(FPostPickGuide_MapButton, 0.10, 0.03)
        call DzFrameSetText(FPostPickGuide_MapButton, "지도 열기")
        call DzFrameSetScriptByCode(FPostPickGuide_MapButton, JN_FRAMEEVENT_MOUSE_UP, function ClickMapButton, false)

        set FPostPickGuide_CloseButton = DzCreateFrameByTagName("GLUETEXTBUTTON", "", FPostPickGuide_BackDrop, "ScriptDialogButton", FrameCount())
        call DzFrameSetPoint(FPostPickGuide_CloseButton, JN_FRAMEPOINT_BOTTOMLEFT, FPostPickGuide_BackDrop, JN_FRAMEPOINT_BOTTOMLEFT, 0.132, 0.018)
        call DzFrameSetSize(FPostPickGuide_CloseButton, 0.08, 0.03)
        call DzFrameSetText(FPostPickGuide_CloseButton, "닫기")
        call DzFrameSetScriptByCode(FPostPickGuide_CloseButton, JN_FRAMEEVENT_MOUSE_UP, function ClickCloseButton, false)

        call DzFrameShow(FPostPickGuide_BackDrop, false)
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()

        call TriggerRegisterTimerEventSingle(t, 0.1)
        call TriggerAddAction(t, function Main)

        set t = CreateTrigger()
        call TriggerRegisterPlayerEvent(t, Player(0), EVENT_PLAYER_END_CINEMATIC)
        call TriggerRegisterPlayerEvent(t, Player(1), EVENT_PLAYER_END_CINEMATIC)
        call TriggerRegisterPlayerEvent(t, Player(2), EVENT_PLAYER_END_CINEMATIC)
        call TriggerRegisterPlayerEvent(t, Player(3), EVENT_PLAYER_END_CINEMATIC)
        call TriggerAddAction(t, function ESCAction)

        set t = null
    endfunction
endlibrary
