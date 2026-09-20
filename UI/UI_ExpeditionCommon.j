// 원정 화면의 공통 스타일과 창 전환 및 선택 요청을 관리한다.
library UIExpeditionCommon initializer Init requires Expedition, UIMainQuest, FrameCount
    globals
        constant integer EXP_UI_LOBBY = 1
        constant integer EXP_UI_CHOICE = 2
        constant integer EXP_UI_EVENT = 3
        constant integer EXP_UI_SHOP = 4
        constant integer EXP_UI_STATS = 5
        constant integer EXP_UI_MAP = 6
        constant integer EXP_UI_RESULT = 7
        integer ExpUIPanel = 0
        integer array ExpUIRoots
        integer array ExpUIButtons
        integer array ExpUIButtonLabels
        private integer array ButtonBackdrops
        private integer array ButtonActions
        private boolean array ButtonEnabled
        private integer ButtonCount = 0
        private integer Hovered = 0
        private integer Navigation
        private integer ActivityButton
        private integer StatsButton
        private integer array PanelToggles
        private integer FoldedPanel = 0
        private integer SeenRevision = -1
        private integer SeenOffer = -1
        private boolean SeenDone = false
        private integer ShownRun = 0
        private integer ShownRevision = 0
        private integer ShownOffer = 0
    endglobals

    function ExpUILabel takes integer parent, real x, real y, real width, real height, real size, string value returns integer
        local integer f = DzCreateFrameByTagName("TEXT", "", parent, "", FrameCount())
        call DzFrameSetPoint(f, JN_FRAMEPOINT_TOPLEFT, parent, JN_FRAMEPOINT_TOPLEFT, x, -y)
        call DzFrameSetSize(f, width, height)
        call DzFrameSetFont(f, "Fonts\\DFHeiMd.ttf", size, 0)
        call DzFrameSetText(f, "|cff315a70" + value + "|r")
        call DzFrameSetEnable(f, false)
        return f
    endfunction

    function ExpUIText takes integer frame, string value returns nothing
        call DzFrameSetText(frame, "|cff315a70" + value + "|r")
    endfunction

    function ExpUITexture takes integer parent, real x, real y, real width, real height, string texture returns integer
        local integer f = DzCreateFrameByTagName("BACKDROP", "", parent, "", FrameCount())
        call DzFrameSetPoint(f, JN_FRAMEPOINT_TOPLEFT, parent, JN_FRAMEPOINT_TOPLEFT, x, -y)
        call DzFrameSetSize(f, width, height)
        call DzFrameSetTexture(f, texture, 0)
        // BACKDROP은 CControl이 아니므로 DzFrameSetEnable을 호출하지 않는다.
        return f
    endfunction

    function ExpUIRoot takes integer id, real width, real height, real top, boolean background returns integer
        local integer f = DzCreateFrameByTagName("FRAME", "", DzGetGameUI(), "", FrameCount())
        local integer decoration
        call DzFrameSetSize(f, width, height)
        call DzFrameSetAbsolutePoint(f, JN_FRAMEPOINT_TOPLEFT, (0.8 - width) * 0.5, top)
        call DzFrameSetPriority(f, 90)
        if background then
            set decoration = ExpUITexture(f, 0, 0, width, height, "war3mapImported\\UI_Upgrade_Panel.tga")
        endif
        set ExpUIRoots[id] = f
        call DzFrameShow(f, false)
        return f
    endfunction

    function ExpUISend takes integer action returns nothing
        // UI에 표시한 회차와 후보 버전을 전송한다. 판정은 기존 동기화 수신부가 담당한다.
        call DzSyncData("ExpCmd", I2S(ShownRun) + "|" + I2S(ShownRevision) + "|" + I2S(ShownOffer) + "|" + I2S(action))
    endfunction

    function ExpUIActivity takes integer pid returns integer
        if ExpState == EXP_LOBBY then
            return EXP_UI_LOBBY
        elseif ExpState == EXP_RESULT then
            return EXP_UI_RESULT
        elseif not ExpMember[pid] or ExpDone[pid] then
            return 0
        elseif ExpState == EXP_START then
            return EXP_UI_CHOICE
        elseif ExpState == EXP_VOTE or (ExpState == EXP_REWARD and ExpEventDeadline[pid] > 0) then
            return EXP_UI_EVENT
        elseif ExpState == EXP_REWARD then
            return EXP_UI_CHOICE
        elseif ExpState == EXP_SHOP then
            return EXP_UI_SHOP
        endif
        return 0
    endfunction

    function ExpUIOpen takes integer panel returns nothing
        if not F_UpgradeOnOff[GetPlayerId(GetLocalPlayer())] then
            if panel == 0 and ExpUIPanel != 0 then
                set FoldedPanel = ExpUIPanel
            elseif panel != 0 then
                set FoldedPanel = 0
            endif
            set ExpUIPanel = panel
            // 로컬 입력에서는 표시 상태만 바꾼다. TriggerExecute는 여기서 호출하지 않는다.
        endif
    endfunction

    private function ButtonStyle takes integer i returns nothing
        if not ButtonEnabled[i] then
            call DzFrameSetTexture(ButtonBackdrops[i], "war3mapImported\\UI_Upgrade_Disabled.tga", 0)
        elseif Hovered == i then
            call DzFrameSetTexture(ButtonBackdrops[i], "war3mapImported\\UI_Upgrade_ActionHover.tga", 0)
        else
            call DzFrameSetTexture(ButtonBackdrops[i], "war3mapImported\\UI_Upgrade_Action.tga", 0)
        endif
    endfunction

    function ExpUISetButton takes integer i, string value, boolean enabled returns nothing
        set ButtonEnabled[i] = enabled
        call DzFrameSetEnable(ExpUIButtons[i], enabled)
        call DzFrameSetText(ExpUIButtonLabels[i], "|cffffffff" + value + "|r")
        call ButtonStyle(i)
    endfunction

    private function HoverButton takes nothing returns nothing
        local integer i = 1
        loop
            exitwhen i > ButtonCount
            if DzGetTriggerUIEventFrame() == ExpUIButtons[i] then
                set Hovered = i
                call ButtonStyle(i)
                return
            endif
            set i = i + 1
        endloop
    endfunction

    private function LeaveButton takes nothing returns nothing
        local integer old = Hovered
        set Hovered = 0
        if old > 0 then
            call ButtonStyle(old)
        endif
    endfunction

    private function ClickButton takes nothing returns nothing
        local integer i = 1
        local integer pid = GetPlayerId(GetLocalPlayer())
        local integer action
        if DzGetTriggerUIEventPlayer() != GetLocalPlayer() then
            return
        endif
        loop
            exitwhen i > ButtonCount
            if DzGetTriggerUIEventFrame() == ExpUIButtons[i] and ButtonEnabled[i] then
                set action = ButtonActions[i]
                if action == -99 then
                    call ExpUIOpen(0)
                elseif action == -98 then
                    call ExpUIOpen(ExpUIActivity(pid))
                elseif action < 0 then
                    if ExpUIPanel == -action then
                        call ExpUIOpen(0)
                    else
                        call ExpUIOpen(-action)
                    endif
                else
                    call ExpUISend(action)
                endif
                return
            endif
            set i = i + 1
        endloop
    endfunction

    function ExpUIButton takes integer parent, real x, real y, real width, real height, string value, integer action returns integer
        local integer i = ButtonCount + 1
        set ButtonCount = i
        set ExpUIButtons[i] = DzCreateFrameByTagName("BUTTON", "", parent, "", FrameCount())
        call DzFrameSetPoint(ExpUIButtons[i], JN_FRAMEPOINT_TOPLEFT, parent, JN_FRAMEPOINT_TOPLEFT, x, -y)
        call DzFrameSetSize(ExpUIButtons[i], width, height)
        set ButtonBackdrops[i] = ExpUITexture(ExpUIButtons[i], 0, 0, width, height, "war3mapImported\\UI_Upgrade_Action.tga")
        set ExpUIButtonLabels[i] = ExpUILabel(ExpUIButtons[i], 0.007, (height - 0.012) * 0.5, width - 0.014, 0.027, 0.009, value)
        set ButtonActions[i] = action
        call ExpUISetButton(i, value, true)
        call DzFrameSetScriptByCode(ExpUIButtons[i], JN_FRAMEEVENT_MOUSE_ENTER, function HoverButton, false)
        call DzFrameSetScriptByCode(ExpUIButtons[i], JN_FRAMEEVENT_MOUSE_LEAVE, function LeaveButton, false)
        call DzFrameSetScriptByCode(ExpUIButtons[i], JN_FRAMEEVENT_MOUSE_UP, function ClickButton, false)
        return i
    endfunction

    function ExpUIPanelToggle takes integer parent, real x, real y, real width, real height returns integer
        local integer panel = 1
        local integer i
        loop
            exitwhen panel > 7 or ExpUIRoots[panel] == parent
            set panel = panel + 1
        endloop
        if panel > 7 then
            return 0
        endif
        // 창을 숨겨도 버튼은 같은 위치에서 입력을 받도록 별도 부모에 둔다.
        set i = ExpUIButton(DzGetGameUI(), x, y, width, height, "접기", -panel)
        call DzFrameClearAllPoints(ExpUIButtons[i])
        call DzFrameSetPoint(ExpUIButtons[i], JN_FRAMEPOINT_TOPLEFT, parent, JN_FRAMEPOINT_TOPLEFT, x, -y)
        call DzFrameSetPriority(ExpUIButtons[i], 95)
        call DzFrameShow(ExpUIButtons[i], false)
        set PanelToggles[panel] = i
        return i
    endfunction

    function ExpUIHeader takes integer parent, real width, string title returns integer
        local integer f = ExpUITexture(parent, 0, 0, width, 0.044, "war3mapImported\\UI_Upgrade_Header.tga")
        local integer close = ExpUIPanelToggle(parent, width - 0.048, 0.008, 0.033, 0.026)
        return ExpUILabel(parent, 0.018, 0.013, width - 0.082, 0.026, 0.014, title)
    endfunction

    private function Render takes nothing returns nothing
        local integer pid = GetPlayerId(GetLocalPlayer())
        local integer activity
        local integer i = 1
        local boolean visible
        if Navigation == 0 or pid > 3 then
            return
        endif
        set visible = PickCheck[pid] and not F_UpgradeOnOff[pid]
        set activity = ExpUIActivity(pid)
        if SeenRevision != ExpRevision then
            set ExpUIPanel = activity
            set FoldedPanel = 0
            set SeenRevision = ExpRevision
        elseif SeenOffer != ExpOfferVersion[pid] and ExpState == EXP_REWARD and ExpEventDeadline[pid] > 0 then
            set ExpUIPanel = activity
            set FoldedPanel = 0
        elseif not SeenDone and ExpDone[pid] and (ExpUIPanel == EXP_UI_CHOICE or ExpUIPanel == EXP_UI_EVENT or ExpUIPanel == EXP_UI_SHOP) then
            set ExpUIPanel = 0
        endif
        if ExpDone[pid] and (FoldedPanel == EXP_UI_CHOICE or FoldedPanel == EXP_UI_EVENT or FoldedPanel == EXP_UI_SHOP) then
            set FoldedPanel = 0
        endif
        set SeenDone = ExpDone[pid]
        set SeenOffer = ExpOfferVersion[pid]
        set ShownRun = ExpRun
        set ShownRevision = ExpRevision
        set ShownOffer = ExpOfferVersion[pid]
        call DzFrameShow(Navigation, visible)
        call DzFrameShow(ExpUIButtons[ActivityButton], activity != 0)
        call DzFrameShow(ExpUIButtons[StatsButton], ExpMember[pid])
        // 선택 버튼이 없는 전투 중에는 스탯 버튼을 당겨 보스 체력바 자리를 비운다.
        call DzFrameClearAllPoints(ExpUIButtons[StatsButton])
        if activity == 0 then
            call DzFrameSetPoint(ExpUIButtons[StatsButton], JN_FRAMEPOINT_TOPLEFT, Navigation, JN_FRAMEPOINT_TOPLEFT, 0.090, 0)
        else
            call DzFrameSetPoint(ExpUIButtons[StatsButton], JN_FRAMEPOINT_TOPLEFT, Navigation, JN_FRAMEPOINT_TOPLEFT, 0.180, 0)
        endif
        if activity == EXP_UI_LOBBY then
            call ExpUISetButton(ActivityButton, "출발 준비", true)
        elseif activity == EXP_UI_RESULT then
            call ExpUISetButton(ActivityButton, "원정 결과", true)
        elseif activity == EXP_UI_SHOP then
            call ExpUISetButton(ActivityButton, "상점", true)
        else
            call ExpUISetButton(ActivityButton, "선택지", true)
        endif
        call ExpUISetButton(StatsButton, "스탯  " + I2S(ExpPoints[pid] - ExpCritPoints[pid] - ExpSwiftPoints[pid]), true)
        loop
            exitwhen i > 7
            if ExpUIRoots[i] != 0 then
                call DzFrameShow(ExpUIRoots[i], visible and ExpUIPanel == i)
            endif
            if PanelToggles[i] != 0 then
                call DzFrameShow(ExpUIButtons[PanelToggles[i]], visible and (ExpUIPanel == i or (ExpUIPanel == 0 and FoldedPanel == i)))
                if ExpUIPanel == i then
                    call ExpUISetButton(PanelToggles[i], "접기", true)
                else
                    call ExpUISetButton(PanelToggles[i], "열기", true)
                endif
            endif
            set i = i + 1
        endloop
        call MainQuestSetOverlayHidden(pid, ExpMember[pid] or (visible and ExpUIPanel != 0))
    endfunction

    private function Escape takes nothing returns nothing
        if GetTriggerPlayer() == GetLocalPlayer() then
            call ExpUIOpen(0)
        endif
    endfunction

    private function Build takes nothing returns nothing
        local integer mapButton
        local integer i = 0
        local trigger t = CreateTrigger()
        set Navigation = DzCreateFrameByTagName("FRAME", "", DzGetGameUI(), "", FrameCount())
        call DzFrameSetSize(Navigation, 0.285, 0.026)
        call DzFrameSetAbsolutePoint(Navigation, JN_FRAMEPOINT_TOPLEFT, 0.018, 0.552)
        call DzFrameSetPriority(Navigation, 95)
        set mapButton = ExpUIButton(Navigation, 0, 0, 0.082, 0.026, "지도 [M]", -EXP_UI_MAP)
        set ActivityButton = ExpUIButton(Navigation, 0.090, 0, 0.082, 0.026, "출발 준비", -98)
        set StatsButton = ExpUIButton(Navigation, 0.180, 0, 0.092, 0.026, "스탯", -EXP_UI_STATS)
        loop
            exitwhen i == 4
            call TriggerRegisterPlayerEvent(t, Player(i), EVENT_PLAYER_END_CINEMATIC)
            set i = i + 1
        endloop
        call TriggerAddAction(t, function Escape)
        call TriggerAddAction(ExpRefresh, function Render)
        // 미선택자와 관전자도 같은 타이머 이벤트로 갱신한다. 로컬 창 상태로 실행을 분기하지 않는다.
        call TriggerRegisterTimerEvent(ExpRefresh, 0.10, true)
        call DzFrameShow(Navigation, false)
        set t = null
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterTimerEventSingle(t, 0.02)
        call TriggerAddAction(t, function Build)
        set t = null
    endfunction
endlibrary
