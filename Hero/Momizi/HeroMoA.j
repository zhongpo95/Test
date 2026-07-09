scope HeroMoA

globals
    private constant real SD = 40 * 0.10

    //쉐클시간
    private constant real Time = 0.90
    //스킬이펙트 시간
    private constant real Time2 = 0.30
    //이동타이머
    private constant real Time5 = 0.06
    //이동거리
    private constant real Dist = 300

    private constant real scale = 500
    private constant real distance = 250
endglobals

private struct FxEffect
    unit caster
    unit dummy
    unit dummy2
    real TargetX
    real TargetY
    integer pid
    real Velue
    real speed
    integer i
    private method OnStop takes nothing returns nothing
        set caster = null
        set dummy = null
        set dummy2 = null
        set pid = 0
        set Velue = 0
        set speed = 0
        set i = 0
        set TargetX = 0
        set TargetY = 0
    endmethod
    private boolean lifeStarted
    private boolean lifeStopping

    static method Create takes nothing returns thistype
        local thistype this = allocate()

        set lifeStarted = false
        set lifeStopping = false

        static if thistype.OnCreate.exists then
            call this.OnCreate()
        endif

        return this
    endmethod

    method Start takes nothing returns nothing
        if lifeStarted then
            return
        endif

        set lifeStarted = true

        static if thistype.OnStart.exists then
            call this.OnStart()
        endif
    endmethod

    method Stop takes nothing returns nothing
        if lifeStopping then
            return
        endif

        set lifeStopping = true

        static if thistype.OnStop.exists then
            call this.OnStop()
        endif

        call deallocate()
    endmethod
endstruct

private function splashD takes nothing returns nothing
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local real velue = 1.0

    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        if BuffMomiz01.Exists( splash.source ) then
            set velue = velue * 1.95
        endif
        set velue = velue * 2.05
        call HeroDeal(1,splash.source,GetEnumUnit(),HeroSkillVelue4[3]*velue,false,false,false,false)
    endif
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data
    local tick t2
    local FxEffect fx2

    set fx.i = fx.i + 1


    if fx.i == 1 then
        set fx.dummy = UnitEffectTime2('e019', GetWidgetX(fx.caster), GetWidgetY(fx.caster), GetUnitFacing(fx.caster),0.9,1,GetPlayerId(GetOwningPlayer(fx.caster)))
        set fx.dummy2 = UnitEffectTime2('e019', GetWidgetX(fx.caster), GetWidgetY(fx.caster), GetUnitFacing(fx.caster),0.9,1,GetPlayerId(GetOwningPlayer(fx.caster)))
    endif

    call UnitAddAbility(fx.caster,'Arav')
    call UnitRemoveAbility(fx.caster,'Arav')
    call UnitAddAbility(fx.dummy,'Arav')
    call UnitRemoveAbility(fx.dummy,'Arav')
    call UnitAddAbility(fx.dummy2,'Arav')
    call UnitRemoveAbility(fx.dummy2,'Arav')

    if fx.i != 10 then
        if fx.i < 5 then
            //call SetUnitFlyHeight(fx.caster, fx.i * 40  ,0)
            call SetUnitHeight(fx.caster, fx.i * 40 )
            call SetUnitFlyHeight(fx.dummy, 200+(fx.i * 40)  ,0)
            call SetUnitFlyHeight(fx.dummy2, 200+(fx.i * 40)  ,0)
        elseif fx.i == 5 then
            //call SetUnitFlyHeight(fx.caster, 5 * 40  ,0)
            call SetUnitHeight(fx.caster, 5 * 40 )
            call SetUnitFlyHeight(fx.dummy, 200+(5 * 40)  ,0)
            call SetUnitFlyHeight(fx.dummy2, 200+(5 * 40)  ,0)
        else
            //call SetUnitFlyHeight(fx.caster, (10 - fx.i) * 40  ,0)
            call SetUnitHeight(fx.caster, (10 - fx.i) * 40 )
            call SetUnitFlyHeight(fx.dummy, 200+((10 - fx.i) * 40)  ,0)
            call SetUnitFlyHeight(fx.dummy2, 200+((10 - fx.i) * 40)  ,0)
        endif
        call SetUnitSafePolarUTA(fx.caster,Dist/10,GetUnitFacing(fx.caster))
        call SetUnitX(fx.dummy,GetWidgetX(fx.caster))
        call SetUnitY(fx.dummy,GetWidgetY(fx.caster))
        call SetUnitX(fx.dummy2,GetWidgetX(fx.caster))
        call SetUnitY(fx.dummy2,GetWidgetY(fx.caster))
        call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale, function splashD )
        call t.start( Time5 * (1 - (fx.speed/(100+fx.speed)) ), false, function EffectFunction )
    else
        //call SetUnitFlyHeight(fx.caster, 0  ,0)
        call SetUnitSafePolarUTA(fx.caster,Dist/10,GetUnitFacing(fx.caster))
        call SetUnitX(fx.dummy,GetWidgetX(fx.caster))
        call SetUnitY(fx.dummy,GetWidgetY(fx.caster))
        call SetUnitX(fx.dummy2,GetWidgetX(fx.caster))
        call SetUnitY(fx.dummy2,GetWidgetY(fx.caster))

        call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale, function splashD )

        if BuffMomiz01.Exists( fx.caster ) then
            call BuffMomiz01.Stop( fx.caster )
        endif

        call fx.Stop()
        call t.destroy()
    endif
endfunction

private function Main takes nothing returns nothing
    local real speed
    local tick t
    local FxEffect fx
    if GetSpellAbilityId() == 'A012' then
        set t = tick.create(0)
        set fx = FxEffect.Create()
        set fx.caster = GetTriggerUnit()
        set fx.TargetX = GetSpellTargetX()
        set fx.TargetY = GetSpellTargetY()
        set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set fx.speed = SkillSpeed2(fx.pid, 18.0)
        set fx.i = 0

        call Sound3D(fx.caster,'A01Z')
        call CooldownFIX(fx.caster,'A012',HeroSkillCD4[3])
        call DummyMagicleash(fx.caster, Time * (1 - (fx.speed/(100+fx.speed)) ))
        call BuffNoST.Apply( fx.caster, Time * (1 - (fx.speed/(100+fx.speed)) ), 0 )
        call BuffNoNB.Apply( fx.caster, Time * (1 - (fx.speed/(100+fx.speed)) ), 0 )
        call AnimationStart3(fx.caster,14, fx.speed)

        set t.data = fx
        call t.start( Time2 * (1 - (fx.speed/(100+fx.speed)) ), false, function EffectFunction )
    endif
endfunction


    private function ASyncData takes nothing returns nothing
        local player p=(DzGetTriggerSyncPlayer())
        local string data=(DzGetTriggerSyncData())
        local integer pid
        local integer dataLen=StringLength(data)
        local integer valueLen
        local real x
        local real y
        local real angle

        set pid=GetPlayerId(p)

        if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID4[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
            set x=S2R(data)
            set valueLen=StringLength(R2S(x))
            set data=SubString(data,valueLen+1,dataLen)
            set dataLen=dataLen-(valueLen+1)
            set y=S2R(data)
            set pid=GetPlayerId(p)
            set angle = AngleWBP(MainUnit[pid],x,y)
            call SetUnitFacing(MainUnit[pid],angle)
            call EXSetUnitFacing(MainUnit[pid],angle)
            call IssuePointOrder( MainUnit[pid], "ancestralspirittarget", x, y )
        endif

        set p=null
    endfunction


private struct TEvAfterB extends array
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function thistype.Action)
        call TriggerRegisterTimerEvent(t,2.0,false)
        set t = null
    endmethod
    private static method Action takes nothing returns nothing
        local trigger t

        set t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddAction(t, function Main)

        set t=CreateTrigger()
        call DzTriggerRegisterSyncData(t,("MoA"),(false))
        call TriggerAddAction(t,function ASyncData)

        set t = null
    endmethod
endstruct
endscope
