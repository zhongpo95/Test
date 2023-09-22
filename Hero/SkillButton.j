library SkillButton requires DataUnit
    globals
    endglobals
    
    private function SkillButtonKey takes nothing returns nothing
        local integer key = DzGetTriggerKey()
        local integer i = GetPlayerId(DzGetTriggerKeyPlayer())
        local string data
        
        if JNMemoryGetByte(JNGetModuleHandle("Game.dll") + 0xD04FEC) == 0 then
            if key == JN_OSKEY_1 then
                if EXGetAbilityState(EXGetUnitAbility(MainUnit[i], potion[1]), ABILITY_STATE_COOLDOWN) == 0 then
                    set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                    call DzSyncData(("PS1"),data)
                endif
            endif
            if key == JN_OSKEY_2 then
                if EXGetAbilityState(EXGetUnitAbility(MainUnit[i], potion[2]), ABILITY_STATE_COOLDOWN) == 0 then
                    set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                    call DzSyncData(("PS2"),data)
                endif
            endif
            if key == JN_OSKEY_3 then
                if EXGetAbilityState(EXGetUnitAbility(MainUnit[i], potion[3]), ABILITY_STATE_COOLDOWN) == 0 then
                    set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                    call DzSyncData(("PS3"),data)
                endif
            endif
            if key == JN_OSKEY_4 then
                if EXGetAbilityState(EXGetUnitAbility(MainUnit[i], potion[4]), ABILITY_STATE_COOLDOWN) == 0 then
                    set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                    call DzSyncData(("PS4"),data)
                endif
            endif
        endif
                
        if DataUnitIndex(MainUnit[i]) == 3 then
            if JNMemoryGetByte(JNGetModuleHandle("Game.dll") + 0xD04FEC) == 0 then
                if key == JN_OSKEY_Q then
                    if EXGetAbilityState(EXGetUnitAbility(MainUnit[i], HeroSkillID0[DataUnitIndex(MainUnit[i])]), ABILITY_STATE_COOLDOWN) == 0 then
                        set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                        call DzSyncData(("MoQ"),data)
                    endif
                endif
                if key == JN_OSKEY_W then
                    if EXGetAbilityState(EXGetUnitAbility(MainUnit[i], HeroSkillID1[DataUnitIndex(MainUnit[i])]), ABILITY_STATE_COOLDOWN) == 0 then
                        set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                        call DzSyncData(("MoW"),data)
                    endif
                endif
                if key == JN_OSKEY_E then
                    if EXGetAbilityState(EXGetUnitAbility(MainUnit[i], HeroSkillID2[DataUnitIndex(MainUnit[i])]), ABILITY_STATE_COOLDOWN) == 0 then
                        set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                        call DzSyncData(("MoE"),data)
                    endif
                endif
                if key == JN_OSKEY_R then
                    if EXGetAbilityState(EXGetUnitAbility(MainUnit[i], HeroSkillID3[DataUnitIndex(MainUnit[i])]), ABILITY_STATE_COOLDOWN) == 0 then
                        set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                        call DzSyncData(("MoR"),data)
                    endif
                endif
                if key == JN_OSKEY_A then
                    if EXGetAbilityState(EXGetUnitAbility(MainUnit[i], HeroSkillID4[DataUnitIndex(MainUnit[i])]), ABILITY_STATE_COOLDOWN) == 0 then
                        set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                        call DzSyncData(("MoA"),data)
                    endif
                endif
                if key == JN_OSKEY_S then
                    if EXGetAbilityState(EXGetUnitAbility(MainUnit[i], HeroSkillID5[DataUnitIndex(MainUnit[i])]), ABILITY_STATE_COOLDOWN) == 0 then
                        set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                        call DzSyncData(("MoS"),data)
                    endif
                endif
                if key == JN_OSKEY_D then
                    if EXGetAbilityState(EXGetUnitAbility(MainUnit[i], HeroSkillID6[DataUnitIndex(MainUnit[i])]), ABILITY_STATE_COOLDOWN) == 0 then
                        set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                        call DzSyncData(("MoD"),data)
                    endif
                endif
                if key == JN_OSKEY_F then
                    if EXGetAbilityState(EXGetUnitAbility(MainUnit[i], HeroSkillID7[DataUnitIndex(MainUnit[i])]), ABILITY_STATE_COOLDOWN) == 0 then
                        set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                        call DzSyncData(("MoF"),data)
                    endif
                endif
                if key == JN_OSKEY_V then
                    if EXGetAbilityState(EXGetUnitAbility(MainUnit[i], HeroSkillID8[DataUnitIndex(MainUnit[i])]), ABILITY_STATE_COOLDOWN) == 0 then
                        set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                        call DzSyncData(("MoV"),data)
                    endif
                endif
                if key == JN_OSKEY_C then
                    if EXGetAbilityState(EXGetUnitAbility(MainUnit[i], HeroSkillID9[DataUnitIndex(MainUnit[i])]), ABILITY_STATE_COOLDOWN) == 0 then
                        set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                        call DzSyncData(("MoV"),data)
                    endif
                endif
            endif
        endif
        
        if DataUnitIndex(MainUnit[i]) == 4 then
            if JNMemoryGetByte(JNGetModuleHandle("Game.dll") + 0xD04FEC) == 0 then
                if key == JN_OSKEY_Q then
                    if EXGetAbilityState(EXGetUnitAbility(MainUnit[i], HeroSkillID0[DataUnitIndex(MainUnit[i])]), ABILITY_STATE_COOLDOWN) == 0 then
                        set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                        call DzSyncData(("ChenQ"),data)
                    endif
                endif
                if key == JN_OSKEY_W then
                    if EXGetAbilityState(EXGetUnitAbility(MainUnit[i], HeroSkillID1[DataUnitIndex(MainUnit[i])]), ABILITY_STATE_COOLDOWN) == 0 then
                        set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                        call DzSyncData(("ChenW"),data)
                    endif
                endif
                if key == JN_OSKEY_E then
                    if EXGetAbilityState(EXGetUnitAbility(MainUnit[i], HeroSkillID2[DataUnitIndex(MainUnit[i])]), ABILITY_STATE_COOLDOWN) == 0 then
                        set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                        call DzSyncData(("ChenE"),data)
                    endif
                endif
                if key == JN_OSKEY_R then
                    if EXGetAbilityState(EXGetUnitAbility(MainUnit[i], HeroSkillID3[DataUnitIndex(MainUnit[i])]), ABILITY_STATE_COOLDOWN) == 0 then
                        set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                        call DzSyncData(("ChenR"),data)
                    endif
                endif
                if key == JN_OSKEY_A then
                    if EXGetAbilityState(EXGetUnitAbility(MainUnit[i], HeroSkillID4[DataUnitIndex(MainUnit[i])]), ABILITY_STATE_COOLDOWN) == 0 then
                        set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                        call DzSyncData(("ChenA"),data)
                    endif
                endif
                if key == JN_OSKEY_S then
                    if EXGetAbilityState(EXGetUnitAbility(MainUnit[i], HeroSkillID5[DataUnitIndex(MainUnit[i])]), ABILITY_STATE_COOLDOWN) == 0 then
                        set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                        call DzSyncData(("ChenS"),data)
                    endif
                endif
                if key == JN_OSKEY_D then
                    if EXGetAbilityState(EXGetUnitAbility(MainUnit[i], HeroSkillID6[DataUnitIndex(MainUnit[i])]), ABILITY_STATE_COOLDOWN) == 0 then
                        set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                        call DzSyncData(("ChenD"),data)
                    endif
                endif
                if key == JN_OSKEY_F then
                    if EXGetAbilityState(EXGetUnitAbility(MainUnit[i], HeroSkillID7[DataUnitIndex(MainUnit[i])]), ABILITY_STATE_COOLDOWN) == 0 then
                        set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                        call DzSyncData(("ChenF"),data)
                    endif
                endif
                if key == JN_OSKEY_V then
                    if EXGetAbilityState(EXGetUnitAbility(MainUnit[i], HeroSkillID8[DataUnitIndex(MainUnit[i])]), ABILITY_STATE_COOLDOWN) == 0 then
                        set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                        call DzSyncData(("ChenV"),data)
                    endif
                endif
                if key == JN_OSKEY_C then
                    if EXGetAbilityState(EXGetUnitAbility(MainUnit[i], HeroSkillID9[DataUnitIndex(MainUnit[i])]), ABILITY_STATE_COOLDOWN) == 0 then
                        set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                        call DzSyncData(("ChenC"),data)
                    endif
                endif
            endif
        endif
    endfunction
    
    private function SkillButtonKey2 takes nothing returns nothing
        local integer key = DzGetTriggerKey()
        local integer i = GetPlayerId(DzGetTriggerKeyPlayer())
        local string data
        
        if DataUnitIndex(MainUnit[i]) == 3 then
            if JNMemoryGetByte(JNGetModuleHandle("Game.dll") + 0xD04FEC) == 0 then
                if key == JN_OSKEY_Q then
                    set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                    call DzSyncData(("MoQ2"),data)
                endif
                if key == JN_OSKEY_W then
                    set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                    call DzSyncData(("MoW2"),data)
                endif
                if key == JN_OSKEY_E then
                    set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                    call DzSyncData(("MoE2"),data)
                endif
                if key == JN_OSKEY_R then
                    set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                    call DzSyncData(("MoR2"),data)
                endif
                if key == JN_OSKEY_A then
                    set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                    call DzSyncData(("MoA2"),data)
                endif
                if key == JN_OSKEY_S then
                    set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                    call DzSyncData(("MoS2"),data)
                endif
                if key == JN_OSKEY_D then
                    set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                    call DzSyncData(("MoD2"),data)
                endif
                if key == JN_OSKEY_F then
                    set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                    call DzSyncData(("MoF2"),data)
                endif
                if key == JN_OSKEY_V then
                    set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                    call DzSyncData(("MoV2"),data)
                endif
            endif
        elseif DataUnitIndex(MainUnit[i]) == 4 then
            if JNMemoryGetByte(JNGetModuleHandle("Game.dll") + 0xD04FEC) == 0 then
                if key == JN_OSKEY_Q then
                    set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                    call DzSyncData(("ChenQ2"),data)
                endif
                if key == JN_OSKEY_W then
                    set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                    call DzSyncData(("ChenW2"),data)
                endif
                if key == JN_OSKEY_E then
                    set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                    call DzSyncData(("ChenE2"),data)
                endif
                if key == JN_OSKEY_R then
                    set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                    call DzSyncData(("ChenR2"),data)
                endif
                if key == JN_OSKEY_A then
                    set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                    call DzSyncData(("ChenA2"),data)
                endif
                if key == JN_OSKEY_S then
                    set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                    call DzSyncData(("ChenS2"),data)
                endif
                if key == JN_OSKEY_D then
                    set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                    call DzSyncData(("ChenD2"),data)
                endif
                if key == JN_OSKEY_F then
                    set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                    call DzSyncData(("ChenF2"),data)
                endif
                if key == JN_OSKEY_V then
                    set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                    call DzSyncData(("ChenV2"),data)
                endif
            endif
        endif
    endfunction
    
//! runtextmacro 이벤트_맵이_로딩되면_발동()
    local trigger t
    
    set t = CreateTrigger()
    call DzTriggerRegisterKeyEventByCode(t, JN_OSKEY_Q, 1, false, function SkillButtonKey)
    set t = CreateTrigger()
    call DzTriggerRegisterKeyEventByCode(t, JN_OSKEY_W, 1, false, function SkillButtonKey)
    set t = CreateTrigger()
    call DzTriggerRegisterKeyEventByCode(t, JN_OSKEY_E, 1, false, function SkillButtonKey)
    set t = CreateTrigger()
    call DzTriggerRegisterKeyEventByCode(t, JN_OSKEY_R, 1, false, function SkillButtonKey)
    set t = CreateTrigger()
    call DzTriggerRegisterKeyEventByCode(t, JN_OSKEY_A, 1, false, function SkillButtonKey)
    set t = CreateTrigger()
    call DzTriggerRegisterKeyEventByCode(t, JN_OSKEY_S, 1, false, function SkillButtonKey)
    set t = CreateTrigger()
    call DzTriggerRegisterKeyEventByCode(t, JN_OSKEY_D, 1, false, function SkillButtonKey)
    set t = CreateTrigger()
    call DzTriggerRegisterKeyEventByCode(t, JN_OSKEY_F, 1, false, function SkillButtonKey)
    set t = CreateTrigger()
    call DzTriggerRegisterKeyEventByCode(t, JN_OSKEY_V, 1, false, function SkillButtonKey)
    set t = CreateTrigger()
    call DzTriggerRegisterKeyEventByCode(t, JN_OSKEY_C, 1, false, function SkillButtonKey)
    
    //소모품
    set t = CreateTrigger()
    call DzTriggerRegisterKeyEventByCode(t, JN_OSKEY_1, 1, false, function SkillButtonKey)
    set t = CreateTrigger()
    call DzTriggerRegisterKeyEventByCode(t, JN_OSKEY_2, 1, false, function SkillButtonKey)
    set t = CreateTrigger()
    call DzTriggerRegisterKeyEventByCode(t, JN_OSKEY_3, 1, false, function SkillButtonKey)
    set t = CreateTrigger()
    call DzTriggerRegisterKeyEventByCode(t, JN_OSKEY_4, 1, false, function SkillButtonKey)
    
    
    set t = CreateTrigger()
    call DzTriggerRegisterKeyEventByCode(t, JN_OSKEY_Q, 0, false, function SkillButtonKey2)
    set t = CreateTrigger()
    call DzTriggerRegisterKeyEventByCode(t, JN_OSKEY_W, 0, false, function SkillButtonKey2)
    set t = CreateTrigger()
    call DzTriggerRegisterKeyEventByCode(t, JN_OSKEY_E, 0, false, function SkillButtonKey2)
    set t = CreateTrigger()
    call DzTriggerRegisterKeyEventByCode(t, JN_OSKEY_R, 0, false, function SkillButtonKey2)
    set t = CreateTrigger()
    call DzTriggerRegisterKeyEventByCode(t, JN_OSKEY_A, 0, false, function SkillButtonKey2)
    set t = CreateTrigger()
    call DzTriggerRegisterKeyEventByCode(t, JN_OSKEY_S, 0, false, function SkillButtonKey2)
    set t = CreateTrigger()
    call DzTriggerRegisterKeyEventByCode(t, JN_OSKEY_D, 0, false, function SkillButtonKey2)
    set t = CreateTrigger()
    call DzTriggerRegisterKeyEventByCode(t, JN_OSKEY_F, 0, false, function SkillButtonKey2)
    set t = CreateTrigger()
    call DzTriggerRegisterKeyEventByCode(t, JN_OSKEY_V, 0, false, function SkillButtonKey2)

    set t = null
//! runtextmacro 이벤트_끝()
endlibrary