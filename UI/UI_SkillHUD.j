// 클릭을 막지 않는 스킬 아이콘 및 쿨타임 HUD 관리
library UISkillHUD initializer init requires UISkill, DataUnit, JAPIAbilityState
    globals
        private constant integer SKILL_HUD_COUNT = 12
        private constant real SKILL_HUD_SIZE = 0.0275
        private integer array SkillHUDIcon
        private integer array SkillHUDCooldown
        private integer array SkillHUDCooldownText
        private integer array SkillHUDHotkeyText
        private integer array SkillHUDAbility
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

    private function Update takes nothing returns nothing
        local integer pid = GetPlayerId(GetLocalPlayer())
        local unit u = MainUnit[pid]
        local integer index
        local integer slot = 0
        local integer abilId
        local integer level
        local real remain
        local real total
        local real ratio

        if u == null then
            loop
                exitwhen slot >= SKILL_HUD_COUNT
                call DzFrameShow(SkillHUDIcon[slot], false)
                set slot = slot + 1
            endloop
            set u = null
            return
        endif

        set index = DataUnitIndex(u)
        loop
            exitwhen slot >= SKILL_HUD_COUNT
            set abilId = AbilityId(index, slot)
            if abilId == 0 then
                call DzFrameShow(SkillHUDIcon[slot], false)
            else
                call DzFrameShow(SkillHUDIcon[slot], true)
                if SkillHUDAbility[slot] != abilId then
                    set SkillHUDAbility[slot] = abilId
                    call DzFrameSetTexture(SkillHUDIcon[slot], EXExecuteScript("(require'jass.slk').ability[" + I2S(abilId) + "].Art"), 0)
                endif

                set level = GetUnitAbilityLevel(u, abilId)
                if level > 0 then
                    set remain = JNGetUnitAbilityCooldownRemaining(u, abilId)
                else
                    set remain = 0.0
                endif
                if remain > 0.0 then
                    set total = JNGetUnitAbilityCooldown(u, abilId, level)
                    if total < remain then
                        set total = remain
                    endif
                    if total > 0.0 then
                        set ratio = remain / total
                    else
                        set ratio = 0.0
                    endif
                    call DzFrameSetSize(SkillHUDCooldown[slot], SKILL_HUD_SIZE, SKILL_HUD_SIZE * ratio)
                    call DzFrameSetAlpha(SkillHUDCooldown[slot], 150)
                    call DzFrameSetText(SkillHUDCooldownText[slot], I2S(R2I(remain + 0.99)))
                else
                    call DzFrameSetSize(SkillHUDCooldown[slot], SKILL_HUD_SIZE, 0.0)
                    call DzFrameSetAlpha(SkillHUDCooldown[slot], 0)
                    call DzFrameSetText(SkillHUDCooldownText[slot], "")
                endif
            endif
            set slot = slot + 1
        endloop
        set u = null
    endfunction

    private function Create takes nothing returns nothing
        local integer parent = JNGetFrameByName("heroStatusUI", 0)
        local integer slot = 0
        local integer row
        local integer column
        local integer nativeButton
        local real x
        local real y

        loop
            exitwhen slot >= SKILL_HUD_COUNT
            set row = slot / 4
            set column = ModuloInteger(slot, 4)
            set x = 0.6075 + 0.0368 * I2R(column)
            set y = 0.1205 - 0.0365 * I2R(row)

            set nativeButton = DzFrameGetCommandBarButton(row, column)
            call DzFrameShow(nativeButton, false)

            set SkillHUDIcon[slot] = DzCreateFrameByTagName("BACKDROP", "SkillHUDIcon" + I2S(slot), parent, "", slot)
            call DzFrameSetSize(SkillHUDIcon[slot], SKILL_HUD_SIZE, SKILL_HUD_SIZE)
            call DzFrameSetAbsolutePoint(SkillHUDIcon[slot], JN_FRAMEPOINT_TOPLEFT, x, y)
            call DzFrameShow(SkillHUDIcon[slot], false)

            set SkillHUDCooldown[slot] = DzCreateFrameByTagName("BACKDROP", "SkillHUDCooldown" + I2S(slot), SkillHUDIcon[slot], "SkillHUD_CooldownShade", slot)
            call DzFrameSetAbsolutePoint(SkillHUDCooldown[slot], JN_FRAMEPOINT_TOPLEFT, x, y)
            call DzFrameSetSize(SkillHUDCooldown[slot], SKILL_HUD_SIZE, 0.0)
            call DzFrameSetAlpha(SkillHUDCooldown[slot], 0)

            set SkillHUDCooldownText[slot] = DzCreateFrameByTagName("TEXT", "SkillHUDCooldownText" + I2S(slot), SkillHUDIcon[slot], "SkillHUD_CooldownText", slot)
            call DzFrameSetAbsolutePoint(SkillHUDCooldownText[slot], JN_FRAMEPOINT_CENTER, x + SKILL_HUD_SIZE * 0.5, y - SKILL_HUD_SIZE * 0.5)
            call DzFrameSetEnable(SkillHUDCooldownText[slot], false)

            set SkillHUDHotkeyText[slot] = DzCreateFrameByTagName("TEXT", "SkillHUDHotkeyText" + I2S(slot), SkillHUDIcon[slot], "SkillHUD_HotkeyText", slot)
            call DzFrameSetAbsolutePoint(SkillHUDHotkeyText[slot], JN_FRAMEPOINT_BOTTOMLEFT, x + 0.0015, y - SKILL_HUD_SIZE + 0.0015)
            call DzFrameSetText(SkillHUDHotkeyText[slot], Hotkey(slot))
            call DzFrameSetEnable(SkillHUDHotkeyText[slot], false)

            set slot = slot + 1
        endloop

        call TimerStart(CreateTimer(), 0.05, true, function Update)
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterTimerEventSingle(t, 0.31)
        call TriggerAddAction(t, function Create)
        set t = null
    endfunction
endlibrary
