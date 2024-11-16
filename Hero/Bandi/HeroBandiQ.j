scope HeroBandiQ
globals
    private constant real SD = 0.00
endglobals


private function Main takes nothing returns nothing
    local tick t
    local SkillFx fx
    local real random
    local real r
    local effect e
         
    if GetSpellAbilityId() == 'A06H' then
        call BanBisulPlus(GetPlayerId(GetOwningPlayer(GetTriggerUnit())),1)
        //call CooldownFIX(GetTriggerUnit(),'A06H',HeroSkillCD0[15])
        call CooldownFIX(GetTriggerUnit(),'A06H',0.5)




        set t = tick.create(0)
        set fx = SkillFx.Create()
        set fx.caster = GetTriggerUnit()
        set fx.TargetX = GetSpellTargetX()
        set fx.TargetY = GetSpellTargetY()
        set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set fx.speed = ((100+SkillSpeed(fx.pid))/100)
        set fx.index = IndexUnit(MainUnit[fx.pid])
        set fx.i = 0
        set r = DistanceWBP(fx.caster, fx.TargetX, fx.TargetY )
        if r >= MoveD then
            set fx.r = MoveD
        else
            set fx.r = r
        endif

        if EffectOff[GetPlayerId(GetLocalPlayer())] == false and fx.pid != GetPlayerId(GetLocalPlayer()) then
            set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        else
            set e = AddSpecialEffect("nitu.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        endif

        call EXEffectMatRotateZ(e,AngleWBP(fx.caster,fx.TargetX,fx.TargetY))
        call DestroyEffect(e)
        set e = null

        call Sound3D(fx.caster,'A03V')

        call CooldownFIX(fx.caster, 'A02I', HeroSkillCD0[14])

        call DummyMagicleash(fx.caster, Time3/fx.speed)
        call AnimationStart3(fx.caster, 11, (100+fx.speed)/100)
        set t.data = fx
        call t.start( 0.02, false, function EffectFunction )







    endif
endfunction

private function QSyncData takes nothing returns nothing
    local player p=(DzGetTriggerSyncPlayer())
    local string data=(DzGetTriggerSyncData())
    local integer pid=GetPlayerId(p)
    local integer dataLen=StringLength(data)
    local integer valueLen
    local real x
    local real y
    local real angle

    if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID0[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
        if GetUnitAbilityLevel(MainUnit[pid],'A06N') < 1 then
            set x=S2R(data)
            set valueLen=StringLength(R2S(x))
            set data=SubString(data,valueLen+1,dataLen)
            set dataLen=dataLen-(valueLen+1)
            set y=S2R(data)
            set pid=GetPlayerId(p)
            set angle = AngleWBP(MainUnit[pid],x,y)
            call SetUnitFacing(MainUnit[pid],angle)
            call EXSetUnitFacing(MainUnit[pid],angle)
            call IssuePointOrder( MainUnit[pid], "acidbomb", x, y )
        endif
    endif

    set p=null
endfunction

private function QSyncData2 takes nothing returns nothing
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
    call DzTriggerRegisterSyncData(t,("BandiQ"),(false))
    call TriggerAddAction(t,function QSyncData)
    
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("BandiQ2"),(false))
    call TriggerAddAction(t,function QSyncData2)

    set t = null
//! runtextmacro 이벤트_끝()
endscope

