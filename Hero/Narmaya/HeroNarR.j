scope HeroNarR
globals
endglobals

private function Main takes nothing returns nothing
    local real speed
    local tick t
    local SkillFx fx
    local real r
    local integer i 
    if GetSpellAbilityId() == 'A02L' then
        set NarStack[GetPlayerId(GetOwningPlayer(GetTriggerUnit()))] = 1
        call CooldownFIX(GetTriggerUnit(),'A02L',HeroSkillCD3[14])
        
        call Overlay2Count(GetPlayerId(GetOwningPlayer(GetTriggerUnit())),'A02L')

    endif
endfunction
    
private function RSyncData takes nothing returns nothing
    local player p=(DzGetTriggerSyncPlayer())
    local string data=(DzGetTriggerSyncData())
    local integer pid=GetPlayerId(p)
    local integer dataLen=StringLength(data)
    local integer valueLen
    local real x
    local real y
    local real angle
    
    if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID3[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
        if NarForm[pid] == 0 then
            set x=S2R(data)
            set valueLen=StringLength(R2S(x))
            set data=SubString(data,valueLen+1,dataLen)
            set dataLen=dataLen-(valueLen+1)
            set y=S2R(data)
            set pid=GetPlayerId(p)
            set angle = AngleWBP(MainUnit[pid],x,y)
            call SetUnitFacing(MainUnit[pid],angle)
            call EXSetUnitFacing(MainUnit[pid],angle)
            call IssuePointOrder( MainUnit[pid], "ancestralspirit", x, y )
        endif
    endif

    set p=null
endfunction

private function RSyncData2 takes nothing returns nothing
    local player p = DzGetTriggerSyncPlayer()
    local integer pid = GetPlayerId(p)
    local real x
    local real y
    local real angle
    local real speed
    local tick t
    local SkillFx fx
    
    set p=null
endfunction

            
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("NarR"),(false))
    call TriggerAddAction(t,function RSyncData)
    
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("NarR2"),(false))
    call TriggerAddAction(t,function RSyncData2)

    set t = null
//! runtextmacro 이벤트_끝()
endscope

