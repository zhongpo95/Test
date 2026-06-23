scope HeroJackZ

globals
    //애니
    private constant integer AniIndex1 = 9
    private constant real Range = 300
    //데미지계수 6회
    private constant real DR = 1.68
    private constant real DR2 = 1.91
    //쉐클지속
    private constant real Time = 0.75
    private constant real MP = 2
endglobals

private function splashD takes nothing returns nothing
    local real r = DistanceWBW(splash.source,GetEnumUnit())
    //call Deal(splash.source,GetEnumUnit(),DR*SkillDamageRate[splash.int])
endfunction

private struct FxEffect
    unit caster
    real TargetX
    real TargetY
    effect e
    effect e2
    effect e3
    integer i
    integer Lv
    private method OnStop takes nothing returns nothing
        set caster = null
        call DestroyEffect(e)
        set e = null
        set e2 = null
        set e3 = null
    endmethod

    private static method OnTimer takes nothing returns nothing
        local tick expiredTick = tick.getExpired()
        local thistype fx = expiredTick.data
                local effect e

                local real r

                set fx.i = fx.i + 1

                if fx.caster != null and IsUnitDeadVJ(fx.caster) == false then

                    if fx.i == 5 then

                        call SetUnitX(fx.caster,fx.TargetX)

                        call SetUnitY(fx.caster,fx.TargetY)

                        call AnimationStart(fx.caster,10)

                        call UnitEffectTimeEX2('e00A',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetUnitFacing(fx.caster),2,GetPlayerId(GetOwningPlayer(fx.caster)))

                        call Sound3D(fx.caster,'A00F')

                    elseif fx.i == 50 then

                        call fx.Stop()

                    endif

                else

                    call fx.Stop()

                endif
    endmethod

    private tick lifeTick
    private boolean lifeStarted
    private boolean lifeStopping

    static method Create takes nothing returns thistype
        local thistype this = allocate()

        set lifeStarted = false
        set lifeStopping = false
        set lifeTick = 0

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

        if lifeTick != 0 then
            return
        endif

        set lifeTick = tick.create(0)
        set lifeTick.data = this
        call lifeTick.start(0.02, true, function thistype.OnTimer)
    endmethod

    method Stop takes nothing returns nothing
        if lifeStopping then
            return
        endif

        set lifeStopping = true

        static if thistype.OnStop.exists then
            call this.OnStop()
        endif

        if lifeTick != 0 then
            call lifeTick.destroy()
            set lifeTick = 0
        endif

        call deallocate()
    endmethod
endstruct


private function F_A00D takes nothing returns nothing
    local FxEffect fx
    local real angle

    set fx = FxEffect.Create()
    set fx.caster = GetTriggerUnit()
    set fx.TargetX = GetSpellTargetX()
    set fx.TargetY = GetSpellTargetY()
    if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
        set fx.e = AddSpecialEffectTarget(".mdl",fx.caster,"chest")
    else
        set fx.e = AddSpecialEffectTarget("Effect_Ribbon_Black.mdl",fx.caster,"chest")
    endif
    //set fx.e2 = AddSpecialEffectTarget("Effect_Ribbon_Black.mdl",fx.caster,"left hand")
    //set fx.e3 = AddSpecialEffectTarget("Effect_Ribbon_Black.mdl",fx.caster,"right hand")
    set fx.i = 0
    call fx.Start()
    call DummyMagicleash(fx.caster,1)
    call AnimationStart(fx.caster,10)
endfunction

private struct TEvAfterB extends array
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function thistype.Action)
        call TriggerRegisterTimerEvent(t,2.0,false)
        set t = null
    endmethod
    private static method Action takes nothing returns nothing
        call AbilityEffectEvent.Create( 'A00D', function F_A00D )
    endmethod
endstruct
endscope
