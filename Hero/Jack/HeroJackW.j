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
    //! runtextmacro 연출()
endstruct

private struct FxEffect_Timer extends array
    private method OnAction takes FxEffect fx returns nothing
        local effect e
        local real r
        set fx.i = fx.i + 1
        if fx.caster != null and IsUnitDeadVJ(fx.caster) == false then
            if fx.i == 5 then
                call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+Polar.X( 75, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +Polar.Y( 75, GetUnitFacing(fx.caster) ), 300, function splashD )
                call UnitEffectTimeEX('e001',GetWidgetX(fx.caster)+Polar.X( 75, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster)+Polar.Y( 75, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.5)
                call UnitEffectTimeEX('e004',GetWidgetX(fx.caster)+Polar.X( 100, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster)+Polar.Y( 100, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.5)
                call Sound3D(fx.caster,'A009')
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster),10 )
            elseif fx.i == 17 then
                call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+Polar.X( 75, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +Polar.Y( 75, GetUnitFacing(fx.caster) ), 300, function splashD )
                call UnitEffectTimeEX('e002',GetWidgetX(fx.caster)+Polar.X( 75, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster)+Polar.Y( 75, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.5)
                call UnitEffectTimeEX('e003',GetWidgetX(fx.caster)+Polar.X( 100, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster)+Polar.Y( 100, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.5)
                call Sound3D(fx.caster,'A009')
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster),10 )
            elseif fx.i == 35 then
                call fx.Stop()
            endif
        else
            call fx.Stop()
        endif
    endmethod
    //! runtextmacro 연출효과_타이머("FxEffect", "0.02", "true")
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
    
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    call AbilityEffectEvent.Create( 'A001', function F_A001 )
//! runtextmacro 이벤트_끝()
endscope