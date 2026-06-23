scope HeroJackW

globals
    //데미지계수
    private constant real DR = 0.55
    //쉐클지속
    private constant real Time = 0.75
endglobals

private function splashD takes nothing returns nothing
    //call HeroDeal(splash.source,GetEnumUnit(),DR)
endfunction

private struct FxEffect
    unit caster
    real TargetX
    real TargetY
    effect e
    effect e2
    integer i
    integer Lv
    private method OnStop takes nothing returns nothing
        set caster = null
        set e = null
        set e2 = null
    endmethod

    private static method OnTimer takes nothing returns nothing
        local tick expiredTick = tick.getExpired()
        local thistype fx = expiredTick.data
                local effect e
        
                local real r
        
                set fx.i = fx.i + 1
        
                if fx.caster != null and IsUnitDeadVJ(fx.caster) == false then
        
                    if fx.i == 5 then
        
                        call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 75, GetUnitFacing(fx.caster) ), 300, function splashD )
        
                        call UnitEffectTimeEX2('e001',GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster)+PolarY( 75, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.5,GetPlayerId(GetOwningPlayer(fx.caster)))
        
                        call UnitEffectTimeEX2('e004',GetWidgetX(fx.caster)+PolarX( 100, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster)+PolarY( 100, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.5,GetPlayerId(GetOwningPlayer(fx.caster)))
        
                        call Sound3D(fx.caster,'A009')
        
                        call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster),10 )
        
                    elseif fx.i == 17 then
        
                        call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 75, GetUnitFacing(fx.caster) ), 300, function splashD )
        
                        call UnitEffectTimeEX2('e002',GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster)+PolarY( 75, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.5,GetPlayerId(GetOwningPlayer(fx.caster)))
        
                        call UnitEffectTimeEX2('e003',GetWidgetX(fx.caster)+PolarX( 100, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster)+PolarY( 100, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.5,GetPlayerId(GetOwningPlayer(fx.caster)))
        
                        call Sound3D(fx.caster,'A009')
        
                        call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster),10 )
        
                    elseif fx.i == 35 then
        
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

    
private function F_A001 takes nothing returns nothing
    local FxEffect fx
    set fx = FxEffect.Create()
    set fx.caster = GetTriggerUnit()
    set fx.i = 0
    set fx.Lv = GetUnitAbilityLevel(fx.caster,'A001')
    call fx.Start()
    call DummyMagicleash(fx.caster,Time)
    call AnimationStart(fx.caster,9)
endfunction

    //function UnitEffectTimeSpeed2 takes integer id, real x, real y, real r, real time, integer i, real r2 returns unit
        //local EffectDummy t = EffectDummy.Create()
        //set t.unit = CreateUnit(Player(NeutralCode),id,x,y,r)
        //call SetUnitAnimationByIndex(t.unit,i)
        //call SetUnitTimeScale(t.unit, r2)
        //call t.Start(time,false)
        //return t.unit
    //endfunction
    
private struct TEvAfterB extends array
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function thistype.Action)
        call TriggerRegisterTimerEvent(t,2.0,false)
        set t = null
    endmethod
    private static method Action takes nothing returns nothing
        call AbilityEffectEvent.Create( 'A001', function F_A001 )
    endmethod
endstruct
endscope
