// 참고 맵 방식의 좌표 기반 스킬 HUD 및 Alt 정보 관리
library UISkillHUD initializer init requires UISkill, DataUnit, JAPIAbilityState, JAPIItemState, HeroNarZ
    globals
        private constant integer SKILL_HUD_COUNT = 12
        private constant real SKILL_HUD_SIZE = 0.0275
        private integer array SkillHUDIcon
        private integer array SkillHUDCooldown
        private integer array SkillHUDCooldownText
        private integer array SkillHUDHotkeyText
        private integer array SkillHUDDisabledCover
        private integer array SkillHUDDisabledDark
        private integer array SkillHUDAbility
        private real array SkillHUDCooldownTotal
        private real array SkillHUDCooldownPrevious
        private integer array ItemHUDIcon
        private integer array ItemHUDCharges
        private integer SkillHUDTip
        private integer SkillHUDTipName
        private integer SkillHUDTipCost
        private integer SkillHUDTipDescription
        private integer SkillHUDHover = -1
    endglobals

    private function AbilityId takes integer index, integer slot returns integer
        if slot == 0 then
            return HeroSkillID0[index]
        elseif slot == 1 then
            return HeroSkillID1[index]
        elseif slot == 2 then
            return HeroSkillID2[index]
        elseif slot == 3 then
            return HeroSkillID3[index]
        elseif slot == 4 then
            return HeroSkillID4[index]
        elseif slot == 5 then
            return HeroSkillID5[index]
        elseif slot == 6 then
            return HeroSkillID6[index]
        elseif slot == 7 then
            return HeroSkillID7[index]
        elseif slot == 8 then
            return HeroSkillID10[index]
        elseif slot == 9 then
            return 'A002'
        elseif slot == 10 then
            return HeroSkillID9[index]
        elseif slot == 11 then
            return HeroSkillID8[index]
        endif
        return 0
    endfunction

    private function IsDashAbilityReady takes unit u, integer abilId returns boolean
        local ability ab
        local boolean ready
        if GetUnitAbilityLevel(u, abilId) < 1 then
            return false
        endif
        set ab = EXGetUnitAbility(u, abilId)
        if ab == null then
            return false
        endif
        set ready = EXGetAbilityState(ab, ABILITY_STATE_COOLDOWN) <= 0.0
        set ab = null
        return ready
    endfunction

    private function DashAbilityId takes unit u returns integer
        if GetUnitAbilityLevel(u, 'A006') > 0 then
            return 'A006'
        elseif GetUnitAbilityLevel(u, 'A005') > 0 then
            return 'A005'
        elseif GetUnitAbilityLevel(u, 'A004') > 0 then
            return 'A004'
        endif
        return 'A002'
    endfunction

    private function IsAbilityAvailable takes unit u, integer pid, integer index, integer slot, integer abilId returns boolean
        if slot == 9 then
            return IsDashAbilityReady(u, DashAbilityId(u))
        endif
        if index == 14 and slot == 2 then
            return GetUnitAbilityLevel(u, abilId) > 0 and NarForm[pid] == 1
        endif
        return GetUnitAbilityLevel(u, abilId) > 0
    endfunction

    private function Hotkey takes integer slot returns string
        if slot == 0 then
            return "Q"
        elseif slot == 1 then
            return "W"
        elseif slot == 2 then
            return "E"
        elseif slot == 3 then
            return "R"
        elseif slot == 4 then
            return "A"
        elseif slot == 5 then
            return "S"
        elseif slot == 6 then
            return "D"
        elseif slot == 7 then
            return "F"
        elseif slot == 8 then
            return "Z"
        elseif slot == 9 then
            return "X"
        elseif slot == 10 then
            return "C"
        endif
        return "V"
    endfunction

    private function SlotX takes integer slot returns real
        return 0.6075 + 0.0368 * I2R(ModuloInteger(slot, 4))
    endfunction

    private function SlotY takes integer slot returns real
        return 0.1205 - 0.0365 * I2R(slot / 4)
    endfunction

    private function HideTip takes nothing returns nothing
        set SkillHUDHover = -1
        call DzFrameShow(SkillHUDTip, false)
    endfunction

    private function ShowTip takes unit u, integer slot returns nothing
        local integer abilId = AbilityId(DataUnitIndex(u), slot)
        local integer level = GetUnitAbilityLevel(u, abilId)
        if level < 1 then
            set level = 1
        endif
        call DzFrameSetText(SkillHUDTipName, EXGetAbilityString(abilId, level, ABILITY_DATA_TIP))
        call DzFrameSetText(SkillHUDTipCost, "마나 " + I2S(JNGetUnitAbilityManaCost(u, abilId, level)))
        call DzFrameSetText(SkillHUDTipDescription, EXGetAbilityString(abilId, level, ABILITY_DATA_UBERTIP))
        call DzFrameShow(SkillHUDTip, true)
    endfunction

    private function UpdateHover takes unit u returns nothing
        local real mx = I2R(DzGetMouseXRelative()) / I2R(DzGetWindowWidth()) * 0.8
        local real my = I2R(DzGetWindowHeight() - 42 - DzGetMouseYRelative()) / I2R(DzGetWindowHeight() - 42) * 0.6
        local integer slot = 0
        local integer hover = -1
        local real x
        local real y
        loop
            exitwhen slot >= SKILL_HUD_COUNT
            set x = SlotX(slot)
            set y = SlotY(slot)
            if SkillHUDAbility[slot] != 0 and mx >= x and mx <= x + SKILL_HUD_SIZE and my <= y and my >= y - SKILL_HUD_SIZE then
                set hover = slot
            endif
            set slot = slot + 1
        endloop
        if hover < 0 then
            call HideTip()
        elseif hover != SkillHUDHover then
            set SkillHUDHover = hover
            call ShowTip(u, hover)
        endif
    endfunction

    private function Update takes nothing returns nothing
        local integer pid = GetPlayerId(GetLocalPlayer())
        local unit u = MainUnit[pid]
        local integer index
        local integer slot = 0
        local integer abilId
        local integer stateAbilId
        local integer level
        local real remain
        local real total
        local real ratio
        local item heldItem

        if u == null then
            loop
                exitwhen slot >= SKILL_HUD_COUNT
                call DzFrameShow(SkillHUDIcon[slot], false)
                set slot = slot + 1
            endloop
            set slot = 0
            loop
                exitwhen slot >= 3
                call DzFrameShow(ItemHUDIcon[slot], false)
                set slot = slot + 1
            endloop
            call HideTip()
            set u = null
            return
        endif

        set index = DataUnitIndex(u)
        loop
            exitwhen slot >= SKILL_HUD_COUNT
            set abilId = AbilityId(index, slot)
            set stateAbilId = abilId
            if slot == 9 then
                set stateAbilId = DashAbilityId(u)
            endif
            if abilId == 0 then
                call DzFrameShow(SkillHUDIcon[slot], false)
            else
                call DzFrameShow(SkillHUDIcon[slot], true)
                if SkillHUDAbility[slot] != abilId then
                    set SkillHUDAbility[slot] = abilId
                    set SkillHUDCooldownTotal[slot] = 0.0
                    set SkillHUDCooldownPrevious[slot] = 0.0
                    call DzFrameSetTexture(SkillHUDIcon[slot], EXExecuteScript("(require'jass.slk').ability[" + I2S(abilId) + "].Art"), 0)
                endif

                set level = GetUnitAbilityLevel(u, abilId)
                if IsAbilityAvailable(u, pid, index, slot, abilId) then
                    call DzFrameSetAlpha(SkillHUDIcon[slot], 255)
                    call DzFrameShow(SkillHUDDisabledCover[slot], false)
                    call DzFrameShow(SkillHUDDisabledDark[slot], false)
                    set remain = EXGetAbilityState(EXGetUnitAbility(u, stateAbilId), ABILITY_STATE_COOLDOWN)
                else
                    call DzFrameSetAlpha(SkillHUDIcon[slot], 255)
                    call DzFrameShow(SkillHUDDisabledCover[slot], true)
                    call DzFrameShow(SkillHUDDisabledDark[slot], true)
                    set remain = 0.0
                endif
                if remain > 0.0 then
                    if SkillHUDCooldownTotal[slot] <= 0.0 or remain > SkillHUDCooldownPrevious[slot] + 0.10 then
                        set SkillHUDCooldownTotal[slot] = remain
                    endif
                    set total = SkillHUDCooldownTotal[slot]
                    if total > 0.0 then
                        set ratio = remain / total
                    else
                        set ratio = 0.0
                    endif
                    call DzFrameSetSize(SkillHUDCooldown[slot], SKILL_HUD_SIZE, SKILL_HUD_SIZE * ratio)
                    call DzFrameSetAlpha(SkillHUDCooldown[slot], 150)
                    call DzFrameSetText(SkillHUDCooldownText[slot], I2S(R2I(remain + 0.99)))
                else
                    set SkillHUDCooldownTotal[slot] = 0.0
                    call DzFrameSetSize(SkillHUDCooldown[slot], SKILL_HUD_SIZE, 0.0)
                    call DzFrameSetAlpha(SkillHUDCooldown[slot], 0)
                    call DzFrameSetText(SkillHUDCooldownText[slot], "")
                endif
                set SkillHUDCooldownPrevious[slot] = remain
            endif
            set slot = slot + 1
        endloop
        call UpdateHover(u)
        set slot = 0
        loop
            exitwhen slot >= 3
            set heldItem = UnitItemInSlot(u, slot)
            if heldItem == null then
                call DzFrameShow(ItemHUDIcon[slot], false)
            else
                call DzFrameShow(ItemHUDIcon[slot], true)
                call DzFrameSetTexture(ItemHUDIcon[slot], JNGetItemIconPath(heldItem), 0)
                call DzFrameSetText(ItemHUDCharges[slot], I2S(GetItemCharges(heldItem)))
            endif
            set slot = slot + 1
        endloop
        set heldItem = null
        set u = null
    endfunction

    private function SyncPing takes nothing returns nothing
        local player sender = DzGetTriggerSyncPlayer()
        local integer pid = GetPlayerId(sender)
        local integer slot = S2I(DzGetTriggerSyncData())
        local unit u = MainUnit[pid]
        local integer abilId
        local integer level
        local real remain
        local integer i = 0
        local string state
        if u == null or slot < 0 or slot >= SKILL_HUD_COUNT then
            set sender = null
            set u = null
            return
        endif
        set abilId = AbilityId(DataUnitIndex(u), slot)
        if slot == 9 then
            set abilId = DashAbilityId(u)
        endif
        set level = GetUnitAbilityLevel(u, abilId)
        if level < 1 then
            set level = 1
        endif
        set remain = EXGetAbilityState(EXGetUnitAbility(u, abilId), ABILITY_STATE_COOLDOWN)
        if remain > 0.0 then
            set state = I2S(R2I(remain + 0.99)) + "초"
        else
            set state = "준비됨"
        endif
        loop
            exitwhen i >= 12
            if IsPlayerAlly(Player(i), sender) then
                call DisplayTextToPlayer(Player(i), 0.0, 0.0, GetUnitName(u) + " - " + EXGetAbilityString(abilId, level, ABILITY_DATA_TIP) + " " + state)
            endif
            set i = i + 1
        endloop
        set sender = null
        set u = null
    endfunction

    private function AltClick takes nothing returns nothing
        if DzGetTriggerKeyPlayer() == GetLocalPlayer() and DzIsKeyDown(JN_OSKEY_ALT) and SkillHUDHover >= 0 then
            call DzSyncData("SkillHUDPing", I2S(SkillHUDHover))
        endif
    endfunction

    private function Create takes nothing returns nothing
        local integer parent = DzGetGameUI()
        local integer slot = 0
        local integer row
        local integer column
        local real x
        local real y

        loop
            exitwhen slot >= SKILL_HUD_COUNT
            call DzFrameShow(DzFrameGetCommandBarButton(slot / 4, ModuloInteger(slot, 4)), false)
            set slot = slot + 1
        endloop

        set slot = 0
        loop
            exitwhen slot >= SKILL_HUD_COUNT
            set row = slot / 4
            set column = ModuloInteger(slot, 4)
            set x = 0.6075 + 0.0368 * I2R(column)
            set y = 0.1205 - 0.0365 * I2R(row)

            set SkillHUDIcon[slot] = DzCreateFrameByTagName("BACKDROP", "SkillHUDIcon" + I2S(slot), parent, "", slot)
            call DzFrameSetSize(SkillHUDIcon[slot], SKILL_HUD_SIZE, SKILL_HUD_SIZE)
            call DzFrameSetAbsolutePoint(SkillHUDIcon[slot], JN_FRAMEPOINT_TOPLEFT, x, y)
            call DzFrameSetPriority(SkillHUDIcon[slot], 21)
            call DzFrameShow(SkillHUDIcon[slot], false)

            set SkillHUDCooldown[slot] = DzCreateFrameByTagName("BACKDROP", "SkillHUDCooldown" + I2S(slot), SkillHUDIcon[slot], "SkillHUD_CooldownShade", slot)
            call DzFrameSetAbsolutePoint(SkillHUDCooldown[slot], JN_FRAMEPOINT_TOPLEFT, x, y)
            call DzFrameSetSize(SkillHUDCooldown[slot], SKILL_HUD_SIZE, 0.0)
            call DzFrameSetAlpha(SkillHUDCooldown[slot], 0)
            call DzFrameSetPriority(SkillHUDCooldown[slot], 22)

            set SkillHUDCooldownText[slot] = DzCreateFrameByTagName("TEXT", "SkillHUDCooldownText" + I2S(slot), SkillHUDIcon[slot], "SkillHUD_CooldownText", slot)
            call DzFrameSetAbsolutePoint(SkillHUDCooldownText[slot], JN_FRAMEPOINT_CENTER, x + SKILL_HUD_SIZE * 0.5, y - SKILL_HUD_SIZE * 0.5)
            call DzFrameSetEnable(SkillHUDCooldownText[slot], false)
            call DzFrameSetPriority(SkillHUDCooldownText[slot], 23)

            set SkillHUDHotkeyText[slot] = DzCreateFrameByTagName("TEXT", "SkillHUDHotkeyText" + I2S(slot), SkillHUDIcon[slot], "SkillHUD_HotkeyText", slot)
            call DzFrameSetAbsolutePoint(SkillHUDHotkeyText[slot], JN_FRAMEPOINT_BOTTOMLEFT, x + 0.0015, y - SKILL_HUD_SIZE + 0.0015)
            call DzFrameSetText(SkillHUDHotkeyText[slot], Hotkey(slot))
            call DzFrameSetEnable(SkillHUDHotkeyText[slot], false)
            call DzFrameSetPriority(SkillHUDHotkeyText[slot], 23)

            set SkillHUDDisabledCover[slot] = DzCreateFrameByTagName("BACKDROP", "SkillHUDDisabledCover" + I2S(slot), SkillHUDIcon[slot], "", slot)
            call DzFrameSetAbsolutePoint(SkillHUDDisabledCover[slot], JN_FRAMEPOINT_TOPLEFT, x, y)
            call DzFrameSetSize(SkillHUDDisabledCover[slot], SKILL_HUD_SIZE, SKILL_HUD_SIZE)
            call DzFrameSetTexture(SkillHUDDisabledCover[slot], "war3mapImported\\DISBTN.blp", 0)
            call DzFrameSetPriority(SkillHUDDisabledCover[slot], 24)
            call DzFrameShow(SkillHUDDisabledCover[slot], false)

            set SkillHUDDisabledDark[slot] = DzCreateFrameByTagName("BACKDROP", "SkillHUDDisabledDark" + I2S(slot), SkillHUDIcon[slot], "SkillHUD_CooldownShade", slot)
            call DzFrameSetAbsolutePoint(SkillHUDDisabledDark[slot], JN_FRAMEPOINT_TOPLEFT, x, y)
            call DzFrameSetSize(SkillHUDDisabledDark[slot], SKILL_HUD_SIZE, SKILL_HUD_SIZE)
            call DzFrameSetAlpha(SkillHUDDisabledDark[slot], 150)
            call DzFrameSetPriority(SkillHUDDisabledDark[slot], 25)
            call DzFrameShow(SkillHUDDisabledDark[slot], false)

            set slot = slot + 1
        endloop

        set slot = 0
        loop
            exitwhen slot >= 3
            set x = 0.5475
            set y = 0.1185 - 0.03675 * I2R(slot)
            set ItemHUDIcon[slot] = DzCreateFrameByTagName("BACKDROP", "ItemHUDIcon" + I2S(slot), parent, "", slot)
            call DzFrameSetSize(ItemHUDIcon[slot], 0.0225, 0.0225)
            call DzFrameSetAbsolutePoint(ItemHUDIcon[slot], JN_FRAMEPOINT_TOPLEFT, x, y)
            call DzFrameSetPriority(ItemHUDIcon[slot], 21)
            call DzFrameShow(ItemHUDIcon[slot], false)
            set ItemHUDCharges[slot] = DzCreateFrameByTagName("TEXT", "ItemHUDCharges" + I2S(slot), ItemHUDIcon[slot], "SkillHUD_HotkeyText", slot)
            call DzFrameSetAbsolutePoint(ItemHUDCharges[slot], JN_FRAMEPOINT_BOTTOMRIGHT, x + 0.021, y - 0.021)
            call DzFrameSetEnable(ItemHUDCharges[slot], false)
            call DzFrameSetPriority(ItemHUDCharges[slot], 22)
            set slot = slot + 1
        endloop

        set SkillHUDTip = DzCreateFrameByTagName("BACKDROP", "SkillHUDTip", parent, "SkillHUD_TipBackground", 0)
        call DzFrameSetSize(SkillHUDTip, 0.24, 0.12)
        call DzFrameSetAbsolutePoint(SkillHUDTip, JN_FRAMEPOINT_BOTTOMRIGHT, 0.59, 0.13)
        call DzFrameSetAlpha(SkillHUDTip, 230)
        call DzFrameSetPriority(SkillHUDTip, 30)
        set SkillHUDTipName = DzCreateFrameByTagName("TEXT", "SkillHUDTipName", SkillHUDTip, "SkillHUD_TipName", 0)
        call DzFrameSetPoint(SkillHUDTipName, JN_FRAMEPOINT_TOPLEFT, SkillHUDTip, JN_FRAMEPOINT_TOPLEFT, 0.01, -0.01)
        set SkillHUDTipCost = DzCreateFrameByTagName("TEXT", "SkillHUDTipCost", SkillHUDTip, "SkillHUD_TipCost", 0)
        call DzFrameSetPoint(SkillHUDTipCost, JN_FRAMEPOINT_TOPLEFT, SkillHUDTipName, JN_FRAMEPOINT_BOTTOMLEFT, 0.0, -0.008)
        set SkillHUDTipDescription = DzCreateFrameByTagName("TEXT", "SkillHUDTipDescription", SkillHUDTip, "SkillHUD_TipDescription", 0)
        call DzFrameSetPoint(SkillHUDTipDescription, JN_FRAMEPOINT_TOPLEFT, SkillHUDTipCost, JN_FRAMEPOINT_BOTTOMLEFT, 0.0, -0.008)
        call DzFrameSetEnable(SkillHUDTipName, false)
        call DzFrameSetEnable(SkillHUDTipCost, false)
        call DzFrameSetEnable(SkillHUDTipDescription, false)
        call DzFrameShow(SkillHUDTip, false)

        call TimerStart(CreateTimer(), 0.05, true, function Update)
        call DzTriggerRegisterMouseEventByCode(null, JN_MOUSE_BUTTON_TYPE_LEFT, 0, false, function AltClick)
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local trigger syncTrigger = CreateTrigger()
        call DzLoadToc("UnifiedUI.toc")
        call TriggerRegisterTimerEventSingle(t, 0.00)
        call TriggerAddAction(t, function Create)
        call DzTriggerRegisterSyncData(syncTrigger, "SkillHUDPing", false)
        call TriggerAddAction(syncTrigger, function SyncPing)
        set t = null
        set syncTrigger = null
    endfunction
endlibrary
