scope HeroChenE
globals
    private constant real SD = 109.00

    //쉐클시간
    private constant real Time = 0.60
    //스킬이펙트 시간
    private constant real Time2 = 0.20
    //스킬이펙트 시간2
    private constant real Time3 = 0.20
    //이동거리
    private constant real Dist = 450

    private constant real scale = 500
    private constant real distance = 200
    boolean array IsCastingChenE
endglobals

private struct FxEffect
    unit caster
    unit dummy
    real TargetX
    real TargetY
    real speed
    integer i
    private method OnStop takes nothing returns nothing
        set caster = null
        set dummy = null
        set i = 0
        set speed = 0
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
    local real Velue = 1.0
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))

    if IsCastingChenE[pid] == true then
        if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
            set Velue = Velue * 1.70

            set Velue = Velue * 2.60

            call HeroDeal('A019',splash.source,GetEnumUnit(),HeroSkillVelue2[4]*Velue,true,false,true,false)
        endif
    endif
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data

    set fx.i = fx.i + 1

    if fx.i == 1 and ( GetUnitAbilityLevel(fx.caster, 'BPSE') > 0 or GetUnitAbilityLevel(fx.caster, 'A024') > 0 ) or IsCastingChenE[GetPlayerId(GetOwningPlayer(fx.caster))] == false then
        set IsCastingChenE[GetPlayerId(GetOwningPlayer(fx.caster))] = false
        call fx.Stop()
        call t.destroy()
    else
        if fx.i == 1 then
            set fx.dummy = UnitEffectTime2('e00U',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetUnitFacing(fx.caster),1.0,1,GetPlayerId(GetOwningPlayer(fx.caster)))
        endif
        if fx.i != 10 then
            call SetUnitSafePolarUTA(fx.caster,Dist/10,GetUnitFacing(fx.caster))
            call SetUnitX(fx.dummy,GetWidgetX(fx.caster))
            call SetUnitY(fx.dummy,GetWidgetY(fx.caster))
            call t.start( Time3 /fx.speed/10, false, function EffectFunction )
        else
            call SetUnitSafePolarUTA(fx.caster,Dist/10,GetUnitFacing(fx.caster))
            call SetUnitX(fx.dummy,GetWidgetX(fx.caster))
            call SetUnitY(fx.dummy,GetWidgetY(fx.caster))
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 100, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 100, GetUnitFacing(fx.caster) ), scale, function splashD )

            set IsCastingChenE[GetPlayerId(GetOwningPlayer(fx.caster))] = false
            call fx.Stop()
            call t.destroy()
        endif
    endif


endfunction

private function Main takes nothing returns nothing
    local integer pid
    local tick t
    local FxEffect fx

    if GetSpellAbilityId() == 'A019' then
        call SetUnitFacing(GetTriggerUnit(), AngleWBP(GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() ))
        call EXSetUnitFacing(GetTriggerUnit(), AngleWBP(GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() ))
        set t = tick.create(0)
        set fx = FxEffect.Create()
        set fx.caster = GetTriggerUnit()
        set fx.TargetX = GetSpellTargetX()
        set fx.TargetY = GetSpellTargetY()
        set fx.i = 0
        set pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set fx.speed = ((100+SkillSpeed(pid))/100)
        set IsCastingChenE[pid] = true

        call Sound3D(fx.caster,'A01P')
        call CooldownFIX(fx.caster,'A019',HeroSkillCD2[4]-5.6)
        call DummyMagicleash(fx.caster, Time /fx.speed)
        call AnimationStart3(fx.caster,17, fx.speed)

        set t.data = fx
        call t.start( Time2 /fx.speed, false, function EffectFunction )
    endif
endfunction

private function ESyncData takes nothing returns nothing
    local player p=(DzGetTriggerSyncPlayer())
    local string data=(DzGetTriggerSyncData())
    local integer pid
    local integer dataLen=StringLength(data)
    local integer valueLen
    local real x
    local real y
    local real angle

    set pid=GetPlayerId(p)

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
        call DzTriggerRegisterSyncData(t,("ChenE"),(false))
        call TriggerAddAction(t,function ESyncData)

        set t = null
    endmethod
endstruct
endscope
