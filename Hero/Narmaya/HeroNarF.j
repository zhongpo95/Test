scope HeroNarF
globals
    private constant real CoolTime = 5.00
    //쉐클시간
    private constant real Time = 2.3
endglobals


private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillFx fx = t.data

endfunction

private function Main takes nothing returns nothing
    local real speed
    local tick t
    local SkillFx fx
    local real r
    local integer i
    
    //38 39 54 55

    if GetSpellAbilityId() == 'A02P' then
        set t = tick.create(0)
        set fx = SkillFx.Create()
        set fx.caster = GetTriggerUnit()
        set fx.TargetX = GetSpellTargetX()
        set fx.TargetY = GetSpellTargetY()
        set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set fx.i = 0
        set fx.Aspeed = ((100+SkillSpeed(fx.pid))/100)

        //유닛애니메이션속도
        call DummyMagicleash(fx.caster, Time /fx.Aspeed)
        call AnimationStart3(fx.caster, 14, fx.Aspeed)
        
        call Sound3D(fx.caster,'A03J')

        set r = GetRandomInt(0,1)
        if r == 0 then
            call Sound3D(fx.caster,'A04F')
        elseif r == 1 then
            call Sound3D(fx.caster,'A04D')
        endif
        set t.data = fx

        call t.start( 0.02, false, function EffectFunction )

        call CooldownFIX(GetTriggerUnit(),'A02P',CoolTime)
    endif
endfunction

    
private function FSyncData takes nothing returns nothing
    local player p=(DzGetTriggerSyncPlayer())
    local string data=(DzGetTriggerSyncData())
    local integer pid=GetPlayerId(p)
    local integer dataLen=StringLength(data)
    local integer valueLen
    local real x
    local real y
    local real angle
    
    if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID7[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
        set x=S2R(data)
        set valueLen=StringLength(R2S(x))
        set data=SubString(data,valueLen+1,dataLen)
        set dataLen=dataLen-(valueLen+1)
        set y=S2R(data)
        set pid=GetPlayerId(p)
        set angle = AngleWBP(MainUnit[pid],x,y)
        call SetUnitFacing(MainUnit[pid],angle)
        call EXSetUnitFacing(MainUnit[pid],angle)
        call IssuePointOrder( MainUnit[pid], "attributemodskill", x, y )
    endif

    set p=null
endfunction

private function FSyncData2 takes nothing returns nothing
    local player p = DzGetTriggerSyncPlayer()
    local integer pid = GetPlayerId(p)
    local real x
    local real y
    local real angle
    local real speed
    local tick t
    
    set p=null
endfunction

            
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("NarF"),(false))
    call TriggerAddAction(t,function FSyncData)
    
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("NarF2"),(false))
    call TriggerAddAction(t,function FSyncData2)

    set t = null
//! runtextmacro 이벤트_끝()
endscope

