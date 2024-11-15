scope HeroBandiE
globals
endglobals

private function Main takes nothing returns nothing
    local unit caster
    local integer pid

    if GetSpellAbilityId() == 'A06F' then
        set caster = GetTriggerUnit()
        set pid = GetPlayerId(GetOwningPlayer(caster))

        call BanBisul2Plus(pid,1)

        call CooldownFIX(caster,'A06F',0.5)
        set caster = null
    endif
endfunction
    
private function ESyncData takes nothing returns nothing
    local player p=(DzGetTriggerSyncPlayer())
    local string data=(DzGetTriggerSyncData())
    local integer pid=GetPlayerId(p)
    local integer dataLen=StringLength(data)
    local integer valueLen
    local real x
    local real y
    local real angle
    
    if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID2[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
        set x=S2R(data)
        set valueLen=StringLength(R2S(x))
        set data=SubString(data,valueLen+1,dataLen)
        set dataLen=dataLen-(valueLen+1)
        set y=S2R(data)
        set pid=GetPlayerId(p)
        set angle = AngleWBP(MainUnit[pid],x,y)
        call SetUnitFacing(MainUnit[pid],angle)
        call EXSetUnitFacing(MainUnit[pid],angle)
        call IssuePointOrder( MainUnit[pid], "ambush", x, y )
    endif

    set p=null
endfunction
            
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("BandiE"),(false))
    call TriggerAddAction(t,function ESyncData)

    set t = null
//! runtextmacro 이벤트_끝()
endscope