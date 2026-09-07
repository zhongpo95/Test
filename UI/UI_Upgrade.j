// 영구 강화 기능 통합 탭 UI 관리
library UIUpgrade initializer Init requires UIEnchant, UIStone, UIElixir, UITIP, UIHP, UISkillHUD, FrameCount
    globals
        integer F_UpgradeRoot
        integer F_UpgradeScreenBlock
        integer F_UpgradeNav
        integer F_UpgradeTitleBD
        integer F_UpgradeTitle
        integer F_UpgradeNpcPanel
        integer F_UpgradeClose
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
                call DzFrameSetVertexColor(F_UpgradeTabBD[i], DzGetColor(245, 255, 255, 255))
            else
                call DzFrameSetVertexColor(F_UpgradeTabBD[i], DzGetColor(225, 122, 174, 197))
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
        call UpgradeHideContents(pid)
        set F_UpgradeCurrentTab[pid] = tab
        call DzFrameSetText(F_UpgradeTitle, UpgradeTabName(tab))
        call UpgradeRefreshTabs(tab)

        if tab == 1 then
            call EnchantSetOpen(pid, true)
            call DzFrameShow(F_EnchantCancelButton, false)
        elseif tab == 2 then
            if F_UpgradeStonePrepared[pid] then
                call StoneSetOpen(pid, true)
            elseif StoneStart(pid) then
                set F_UpgradeStonePrepared[pid] = true
            endif
            call DzFrameShow(F_StoneCancelButton, false)
        else
            call ElixirSetOpen(pid, true)
        endif
    endfunction

    function UpgradeHubClose takes integer pid returns nothing
        call UpgradeHideContents(pid)
        call DzFrameShow(F_UpgradeRoot, false)
        call DzFrameShow(UI_Tip, false)
        set F_UpgradeOnOff[pid] = false
        set F_UpgradeStonePrepared[pid] = false
        set F_UpgradeCurrentTab[pid] = 0
        if Player(pid) == GetLocalPlayer() then
            call BlzHideOriginFrames(false)
            call DzFrameShow(heroStatusUI, true)
            call SkillHUDSetVisible(true)
        endif
        call PlayersHPBarShow(Player(pid), F_UpgradeHPWasShown[pid])
    endfunction

    function UpgradeHubOpen takes integer pid, integer tab returns nothing
        if tab < 1 or tab > 3 then
            set tab = 1
        endif
        set F_UpgradeHPWasShown[pid] = HPBshow[pid]
        if Player(pid) == GetLocalPlayer() then
            call BlzHideOriginFrames(true)
            call DzFrameShow(heroStatusUI, false)
            call SkillHUDSetVisible(false)
        endif
        call PlayersHPBarShow(Player(pid), false)
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

    private function Main takes nothing returns nothing
        local integer i = 1
        local integer index = 0

        set F_UpgradeRoot=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "template", FrameCount())
        call DzFrameSetTexture(F_UpgradeRoot, "war3mapImported\\UI_Pick_Backdrop.tga", 0)
        call DzFrameSetSize(F_UpgradeRoot, 0.800, 0.600)
        call DzFrameSetAbsolutePoint(F_UpgradeRoot, JN_FRAMEPOINT_CENTER, 0.4000, 0.3000)
        call DzFrameSetPriority(F_UpgradeRoot, 100)

        call DzFrameSetParent(F_EnchantBackDrop, F_UpgradeRoot)
        call DzFrameSetParent(F_StoneBackDrop, F_UpgradeRoot)
        call DzFrameSetParent(El_BackDrop, F_UpgradeRoot)
        call DzFrameSetParent(El_BackDrop2, F_UpgradeRoot)

        set F_UpgradeScreenBlock=DzCreateFrameByTagName("BUTTON", "", F_UpgradeRoot, "ScoreScreenTabButtonTemplate", FrameCount())
        call DzFrameSetAllPoints(F_UpgradeScreenBlock, F_UpgradeRoot)
        call DzFrameSetSize(F_UpgradeScreenBlock, 0.800, 0.600)

        set F_UpgradeNav=DzCreateFrameByTagName("BACKDROP", "", F_UpgradeRoot, "template", FrameCount())
        call DzFrameSetTexture(F_UpgradeNav, "war3mapImported\\UI_Pick_Backdrop.tga", 0)
        call DzFrameSetSize(F_UpgradeNav, 0.105, 0.400)
        call DzFrameSetAbsolutePoint(F_UpgradeNav, JN_FRAMEPOINT_CENTER, 0.0600, 0.3000)
        call DzFrameSetPriority(F_UpgradeNav, 120)

        set F_UpgradeTitleBD=DzCreateFrameByTagName("BACKDROP", "", F_UpgradeRoot, "template", FrameCount())
        call DzFrameSetTexture(F_UpgradeTitleBD, "war3mapImported\\UI_Pick_Backdrop.tga", 0)
        call DzFrameSetSize(F_UpgradeTitleBD, 0.405, 0.052)
        call DzFrameSetAbsolutePoint(F_UpgradeTitleBD, JN_FRAMEPOINT_CENTER, 0.3225, 0.5650)
        call DzFrameSetPriority(F_UpgradeTitleBD, 120)

        set F_UpgradeTitle=DzCreateFrameByTagName("TEXT", "", F_UpgradeTitleBD, "", FrameCount())
        call DzFrameSetPoint(F_UpgradeTitle, JN_FRAMEPOINT_CENTER, F_UpgradeTitleBD, JN_FRAMEPOINT_CENTER, 0.0, 0.0)
        call DzFrameSetFont(F_UpgradeTitle, "Fonts\\DFHeiMd.ttf", 0.014, 0)
        call DzFrameSetText(F_UpgradeTitle, "장비강화")
        call DzFrameSetTextColor(F_UpgradeTitle, JNConvertColor(255, 28, 55, 72))
        call DzFrameSetEnable(F_UpgradeTitle, false)

        set F_UpgradeNpcPanel=DzCreateFrameByTagName("BACKDROP", "", F_UpgradeRoot, "template", FrameCount())
        call DzFrameSetTexture(F_UpgradeNpcPanel, "BANDI.blp", 0)
        call DzFrameSetSize(F_UpgradeNpcPanel, 0.265, 0.590)
        call DzFrameSetAbsolutePoint(F_UpgradeNpcPanel, JN_FRAMEPOINT_CENTER, 0.6625, 0.3000)
        call DzFrameSetPriority(F_UpgradeNpcPanel, 120)

        loop
            exitwhen i > 3
            set F_UpgradeTabBD[i]=DzCreateFrameByTagName("BACKDROP", "", F_UpgradeNav, "template", FrameCount())
            call DzFrameSetTexture(F_UpgradeTabBD[i], "textures\\white.blp", 0)
            call DzFrameSetSize(F_UpgradeTabBD[i], 0.085, 0.045)
            call DzFrameSetAbsolutePoint(F_UpgradeTabBD[i], JN_FRAMEPOINT_CENTER, 0.0600, 0.4100 - (0.070 * I2R(i - 1)))
            call DzFrameSetPriority(F_UpgradeTabBD[i], 121)

            set F_UpgradeTabText[i]=DzCreateFrameByTagName("TEXT", "", F_UpgradeTabBD[i], "", FrameCount())
            call DzFrameSetPoint(F_UpgradeTabText[i], JN_FRAMEPOINT_CENTER, F_UpgradeTabBD[i], JN_FRAMEPOINT_CENTER, 0.0, 0.0)
            call DzFrameSetFont(F_UpgradeTabText[i], "Fonts\\DFHeiMd.ttf", 0.011, 0)
            call DzFrameSetText(F_UpgradeTabText[i], UpgradeTabName(i))
            call DzFrameSetTextColor(F_UpgradeTabText[i], JNConvertColor(255, 28, 55, 72))
            call DzFrameSetEnable(F_UpgradeTabText[i], false)

            set F_UpgradeTab[i]=DzCreateFrameByTagName("BUTTON", "", F_UpgradeTabBD[i], "ScoreScreenTabButtonTemplate", FrameCount())
            call DzFrameSetAllPoints(F_UpgradeTab[i], F_UpgradeTabBD[i])
            call DzFrameSetSize(F_UpgradeTab[i], 0.085, 0.045)
            call DzFrameSetScriptByCode(F_UpgradeTab[i], JN_FRAMEEVENT_MOUSE_UP, function ClickUpgradeTab, false)
            set i = i + 1
        endloop

        set F_UpgradeClose=DzCreateFrameByTagName("GLUETEXTBUTTON", "", F_UpgradeTitleBD, "ScriptDialogButton", FrameCount())
        call DzFrameSetPoint(F_UpgradeClose, JN_FRAMEPOINT_RIGHT, F_UpgradeTitleBD, JN_FRAMEPOINT_RIGHT, -0.008, 0.0)
        call DzFrameSetSize(F_UpgradeClose, 0.030, 0.030)
        call DzFrameSetText(F_UpgradeClose, "X")
        call DzFrameSetScriptByCode(F_UpgradeClose, JN_FRAMEEVENT_MOUSE_UP, function ClickUpgradeClose, false)

        call UpgradeRefreshTabs(1)
        call DzFrameShow(F_UpgradeRoot, false)
        loop
            exitwhen index == bj_MAX_PLAYER_SLOTS
            set F_UpgradeOnOff[index] = false
            set F_UpgradeStonePrepared[index] = false
            set F_UpgradeCurrentTab[index] = 0
            set F_UpgradeHPWasShown[index] = false
            set index = index + 1
        endloop
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterTimerEventSingle(t, 0.20)
        call TriggerAddAction(t, function Main)
        set t = null
    endfunction
endlibrary
