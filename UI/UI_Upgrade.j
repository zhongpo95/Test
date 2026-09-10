// 영구 강화 기능 통합 탭 UI 관리
library UIUpgrade initializer Init requires UIEnchant, UIStone, UIElixir, UITIP, UIHP, UISkillHUD, FrameCount
    globals
        integer F_UpgradeRoot
        integer F_UpgradeNav
        integer F_UpgradeTitleBD
        integer F_UpgradeTitle
        integer F_UpgradeNpcPanel
        integer F_UpgradeClose
        integer F_UpgradeCloseBD
        integer F_UpgradeHint
        integer F_UpgradeBackground
        integer array F_UpgradeTabBD
        integer array F_UpgradeTab
        integer array F_UpgradeTabText
        boolean array F_UpgradeOnOff
        boolean array F_UpgradeStonePrepared
        integer array F_UpgradeCurrentTab
        boolean array F_UpgradeHPWasShown
    endglobals

    private function UpgradeTabName takes integer tab returns string
        if tab == 1 then
            return "장비강화"
        elseif tab == 2 then
            return "카드부여"
        endif
        return "엘릭서"
    endfunction

    private function UpgradeRefreshTabs takes integer selectedTab returns nothing
        local integer i = 1
        loop
            exitwhen i > 3
            if i == selectedTab then
                call DzFrameSetTexture(F_UpgradeTabBD[i], "war3mapImported\\UI_Upgrade_TabActive.tga", 0)
                call DzFrameSetText(F_UpgradeTabText[i], "|cff2699be" + UpgradeTabName(i) + "|r")
            else
                call DzFrameSetTexture(F_UpgradeTabBD[i], "war3mapImported\\UI_Upgrade_TabIdle.tga", 0)
                call DzFrameSetText(F_UpgradeTabText[i], UpgradeTabName(i))
            endif
            set i = i + 1
        endloop
    endfunction

    private function UpgradeHideContents takes integer pid returns nothing
        call EnchantSetOpen(pid, false)
        call StoneSetOpen(pid, false)
        call ElixirSetOpen(pid, false)
    endfunction

    function UpgradeHubSetTab takes integer pid, integer tab returns nothing
        if Player(pid) != GetLocalPlayer() or not F_UpgradeOnOff[pid] then
            return
        endif
        if tab < 1 or tab > 3 then
            set tab = 1
        endif
        if F_UpgradeCurrentTab[pid] == tab then
            return
        endif
        call UpgradeHideContents(pid)
        call DzFrameShow(F_UpgradeHint, false)
        set F_UpgradeCurrentTab[pid] = tab
        call DzFrameSetText(F_UpgradeTitle, "|cff244f65" + UpgradeTabName(tab) + "|r")
        call UpgradeRefreshTabs(tab)

        if tab == 1 then
            call EnchantSetOpen(pid, true)
            call DzFrameShow(F_EnchantCancelButton, false)
        elseif tab == 2 then
            if F_UpgradeStonePrepared[pid] then
                call StoneSetOpen(pid, true)
            elseif StoneStart(pid) then
                set F_UpgradeStonePrepared[pid] = true
            else
                call DzFrameSetText(F_UpgradeHint, "|cff426f83카드 부여 재료와 장비 창의 빈 공간이 필요합니다.|r")
                call DzFrameShow(F_UpgradeHint, true)
            endif
            call DzFrameShow(F_StoneCancelButton, false)
        else
            call ElixirSetOpen(pid, true)
        endif
    endfunction

    function UpgradeHubClose takes integer pid returns nothing
        if Player(pid) != GetLocalPlayer() or not F_UpgradeOnOff[pid] then
            return
        endif
        call UpgradeHideContents(pid)
        call DzFrameShow(F_UpgradeRoot, false)
        call DzFrameShow(UI_Tip, false)
        set F_UpgradeOnOff[pid] = false
        set F_UpgradeStonePrepared[pid] = false
        set F_UpgradeCurrentTab[pid] = 0
        call DzFrameShow(GetGameplayUI(), true)
        call DzFrameShow(DzFrameGetMinimap(), true)
        call DzFrameShow(DzFrameGetPortrait(), true)
        call DzFrameShow(DzFrameFindByName("InfoPanelIconBackdrop", 0), true)
        call PlayersHPBarShow(Player(pid), F_UpgradeHPWasShown[pid])
    endfunction

    function UpgradeHubOpen takes integer pid, integer tab returns nothing
        if Player(pid) != GetLocalPlayer() then
            return
        endif
        if MainUnit[pid] == null then
            call DisplayTimedTextToPlayer(Player(pid), 0, 0, 3, "캐릭터를 선택한 후 강화 화면을 열 수 있습니다.")
            return
        endif
        if F_UpgradeOnOff[pid] then
            call UpgradeHubSetTab(pid, tab)
            return
        endif
        set F_UpgradeHPWasShown[pid] = HPBshow[pid]
        call DzFrameShow(GetGameplayUI(), false)
        call DzFrameShow(DzFrameGetMinimap(), false)
        call DzFrameShow(DzFrameGetPortrait(), false)
        call DzFrameShow(DzFrameFindByName("InfoPanelIconBackdrop", 0), false)
        call PlayersHPBarShow(Player(pid), false)
        call DzFrameShow(UI_Tip, false)
        call DzFrameShow(F_UpgradeRoot, true)
        set F_UpgradeOnOff[pid] = true
        call UpgradeHubSetTab(pid, tab)
    endfunction

    function UpgradeHubOpenPreparedStone takes integer pid returns nothing
        set F_UpgradeStonePrepared[pid] = true
        call UpgradeHubOpen(pid, 2)
    endfunction

    private function ClickUpgradeTab takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local integer i = 1
        loop
            exitwhen i > 3
            if f == F_UpgradeTab[i] then
                call UpgradeHubSetTab(pid, i)
                return
            endif
            set i = i + 1
        endloop
    endfunction

    private function ClickUpgradeClose takes nothing returns nothing
        call UpgradeHubClose(GetPlayerId(DzGetTriggerUIEventPlayer()))
    endfunction

    private function CommandUpgrade takes nothing returns nothing
        local integer pid = GetPlayerId(GetTriggerPlayer())
        if GetTriggerPlayer() == GetLocalPlayer() then
            if not F_UpgradeOnOff[pid] then
                call UpgradeHubOpen(pid, 1)
            endif
        endif
    endfunction

    private function HoverUpgradeTab takes nothing returns nothing
        local integer i = 1
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        loop
            exitwhen i > 3
            if DzGetTriggerUIEventFrame() == F_UpgradeTab[i] and F_UpgradeCurrentTab[pid] != i then
                call DzFrameSetTexture(F_UpgradeTabBD[i], "war3mapImported\\UI_Upgrade_TabHover.tga", 0)
            endif
            set i = i + 1
        endloop
    endfunction

    private function LeaveUpgradeTab takes nothing returns nothing
        call UpgradeRefreshTabs(F_UpgradeCurrentTab[GetPlayerId(DzGetTriggerUIEventPlayer())])
    endfunction

    private function UpgradeLabel takes integer parent, string value, real x, real y, real size returns integer
        local integer f = DzCreateFrameByTagName("TEXT", "", parent, "", FrameCount())
        call DzFrameSetPoint(f, JN_FRAMEPOINT_LEFT, parent, JN_FRAMEPOINT_TOPLEFT, x, y)
        call DzFrameSetFont(f, "Fonts\\DFHeiMd.ttf", size, 0)
        call DzFrameSetText(f, value)
        call DzFrameSetEnable(f, false)
        return f
    endfunction

    private function Main takes nothing returns nothing
        local integer i = 1
        local integer index = 0
        local integer label
        local trigger t = CreateTrigger()

        // 상단 기본 메뉴 아래의 클릭을 받는 독립 허브입니다.
        set F_UpgradeRoot = DzCreateFrameByTagName("BUTTON", "", DzGetGameUI(), "", FrameCount())
        call DzFrameSetSize(F_UpgradeRoot, 0.800, 0.568)
        call DzFrameSetAbsolutePoint(F_UpgradeRoot, JN_FRAMEPOINT_BOTTOMLEFT, 0.0, 0.0)
        call DzFrameSetPriority(F_UpgradeRoot, 100)
        set F_UpgradeBackground = DzCreateFrameByTagName("BACKDROP", "", F_UpgradeRoot, "", FrameCount())
        call DzFrameSetAllPoints(F_UpgradeBackground, F_UpgradeRoot)
        call DzFrameSetTexture(F_UpgradeBackground, "war3mapImported\\UI_Upgrade_Background.tga", 0)

        call DzFrameSetParent(F_EnchantBackDrop, F_UpgradeRoot)
        call DzFrameSetParent(F_StoneBackDrop, F_UpgradeRoot)
        call DzFrameSetParent(El_BackDrop, F_UpgradeRoot)
        call DzFrameSetParent(El_BackDrop2, F_UpgradeRoot)

        set F_UpgradeNav = DzCreateFrameByTagName("FRAME", "", F_UpgradeRoot, "", FrameCount())
        call DzFrameSetSize(F_UpgradeNav, 0.105, 0.568)
        call DzFrameSetPoint(F_UpgradeNav, JN_FRAMEPOINT_TOPLEFT, F_UpgradeRoot, JN_FRAMEPOINT_TOPLEFT, 0.008, 0.0)
        set label = UpgradeLabel(F_UpgradeNav, "|cff2eb9dfARCANA|r", 0.005, -0.034, 0.016)
        set label = UpgradeLabel(F_UpgradeNav, "|cff709db1UPGRADE|r", 0.006, -0.057, 0.008)
        set label = UpgradeLabel(F_UpgradeNav, "|cff709db1ESC  닫기|r", 0.006, -0.538, 0.008)

        set F_UpgradeTitleBD = DzCreateFrameByTagName("BACKDROP", "", F_UpgradeRoot, "", FrameCount())
        call DzFrameSetTexture(F_UpgradeTitleBD, "war3mapImported\\UI_Upgrade_Header.tga", 0)
        call DzFrameSetSize(F_UpgradeTitleBD, 0.405, 0.060)
        call DzFrameSetPoint(F_UpgradeTitleBD, JN_FRAMEPOINT_TOPLEFT, F_UpgradeRoot, JN_FRAMEPOINT_TOPLEFT, 0.120, -0.010)
        set F_UpgradeTitle = UpgradeLabel(F_UpgradeTitleBD, "|cff244f65장비강화|r", 0.016, -0.025, 0.016)
        set label = UpgradeLabel(F_UpgradeTitleBD, "|cff6792a6EQUIPMENT  /  CARD  /  ELIXIR|r", 0.017, -0.047, 0.007)

        set F_UpgradeNpcPanel = DzCreateFrameByTagName("BACKDROP", "", F_UpgradeRoot, "", FrameCount())
        call DzFrameSetTexture(F_UpgradeNpcPanel, "war3mapImported\\UI_Upgrade_Portrait.tga", 0)
        call DzFrameSetSize(F_UpgradeNpcPanel, 0.265, 0.568)
        call DzFrameSetPoint(F_UpgradeNpcPanel, JN_FRAMEPOINT_TOPRIGHT, F_UpgradeRoot, JN_FRAMEPOINT_TOPRIGHT, 0.0, 0.0)

        loop
            exitwhen i > 3
            set F_UpgradeTab[i] = DzCreateFrameByTagName("BUTTON", "", F_UpgradeNav, "", FrameCount())
            call DzFrameSetSize(F_UpgradeTab[i], 0.090, 0.032)
            call DzFrameSetPoint(F_UpgradeTab[i], JN_FRAMEPOINT_TOPLEFT, F_UpgradeNav, JN_FRAMEPOINT_TOPLEFT, 0.002, -0.137 - 0.048 * I2R(i - 1))
            set F_UpgradeTabBD[i] = DzCreateFrameByTagName("BACKDROP", "", F_UpgradeTab[i], "", FrameCount())
            call DzFrameSetAllPoints(F_UpgradeTabBD[i], F_UpgradeTab[i])
            set F_UpgradeTabText[i] = UpgradeLabel(F_UpgradeTab[i], UpgradeTabName(i), 0.012, -0.014, 0.011)
            call DzFrameSetScriptByCode(F_UpgradeTab[i], JN_FRAMEEVENT_MOUSE_UP, function ClickUpgradeTab, false)
            call DzFrameSetScriptByCode(F_UpgradeTab[i], JN_FRAMEEVENT_MOUSE_ENTER, function HoverUpgradeTab, false)
            call DzFrameSetScriptByCode(F_UpgradeTab[i], JN_FRAMEEVENT_MOUSE_LEAVE, function LeaveUpgradeTab, false)
            set i = i + 1
        endloop

        set F_UpgradeClose = DzCreateFrameByTagName("BUTTON", "", F_UpgradeTitleBD, "", FrameCount())
        call DzFrameSetPoint(F_UpgradeClose, JN_FRAMEPOINT_RIGHT, F_UpgradeTitleBD, JN_FRAMEPOINT_RIGHT, -0.010, 0.0)
        call DzFrameSetSize(F_UpgradeClose, 0.026, 0.026)
        set F_UpgradeCloseBD = DzCreateFrameByTagName("BACKDROP", "", F_UpgradeClose, "", FrameCount())
        call DzFrameSetAllPoints(F_UpgradeCloseBD, F_UpgradeClose)
        call DzFrameSetTexture(F_UpgradeCloseBD, "war3mapImported\\UI_Upgrade_Close.tga", 0)
        call DzFrameSetScriptByCode(F_UpgradeClose, JN_FRAMEEVENT_MOUSE_UP, function ClickUpgradeClose, false)
        set F_UpgradeHint = UpgradeLabel(F_UpgradeRoot, "", 0.140, -0.120, 0.010)
        call DzFrameShow(F_UpgradeHint, false)

        call UpgradeRefreshTabs(1)
        call DzFrameShow(F_UpgradeRoot, false)
        loop
            exitwhen index == bj_MAX_PLAYER_SLOTS
            call TriggerRegisterPlayerChatEvent(t, Player(index), "-강화", true)
            call TriggerRegisterPlayerChatEvent(t, Player(index), "-upgrade", true)
            set index = index + 1
        endloop
        call TriggerAddAction(t, function CommandUpgrade)
        set t = null
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterTimerEventSingle(t, 0.40)
        call TriggerAddAction(t, function Main)
        set t = null
    endfunction
endlibrary
