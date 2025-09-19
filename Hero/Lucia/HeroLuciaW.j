scope HeroLucaiW
globals
endglobals


private struct SkillRarW
    unit caster
    integer pid
endstruct

private function EffectF takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillRarW fx = t.data

    call SelectUnitForPlayerSingle(fx.caster,Player(fx.pid))

    set fx.caster = null

    call fx.destroy()
    call t.destroy()
endfunction

private function Main takes nothing returns nothing
    local integer pid
    local tick t
    local SkillRarW fx

    if GetSpellAbilityId() == 'A07A' then
        call SetUnitFacing(GetTriggerUnit(), AngleWBP(GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() ))
        call EXSetUnitFacing(GetTriggerUnit(), AngleWBP(GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() ))
        set pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        
        call Overlay2Count(pid,'A07A')
        set t = tick.create(pid) 
        set fx = SkillRarW.create()
        set fx.caster = GetTriggerUnit()
        set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set t.data = fx
        call t.start( 0.05, false, function EffectF ) 

        if LuciaForm[fx.pid] == 0 then
            set LuciaForm[fx.pid] = 1
            call AddUnitAnimationProperties(fx.caster, "Alternate", true)
        else
            set LuciaForm[fx.pid] = 0
            call AddUnitAnimationProperties(fx.caster, "Alternate", false)
        endif
        

        call ClearSelectionForPlayer(Player(pid))
        call CooldownFIX(fx.caster,'A07A',HeroSkillCD1[17])
    endif
endfunction
    
private function WSyncData takes nothing returns nothing
    local player p=(DzGetTriggerSyncPlayer())
    local string data=(DzGetTriggerSyncData())
    local integer pid=GetPlayerId(p)
    local integer dataLen=StringLength(data)
    local integer valueLen
    local real x
    local real y
    local real angle

    if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID1[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
        set x=S2R(data)
        set valueLen=StringLength(R2S(x))
        set data=SubString(data,valueLen+1,dataLen)
        set dataLen=dataLen-(valueLen+1)
        set y=S2R(data)
        set pid=GetPlayerId(p)
        set angle = AngleWBP(MainUnit[pid],x,y)
        call SetUnitFacing(MainUnit[pid],angle)
        call EXSetUnitFacing(MainUnit[pid],angle)
        call IssuePointOrder( MainUnit[pid], "acolyteharvest", x, y )
    endif

    set p=null
endfunction

            
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("LuciaW"),(false))
    call TriggerAddAction(t,function WSyncData)

    set t = null
//! runtextmacro 이벤트_끝()
endscope

