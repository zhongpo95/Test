//! runtextmacro 콘텐츠("HeroJackR")

globals
    //데미지계수
    private constant real DR = 2.1
    //쉐클지속
    private constant real Time = 0.8
endglobals

private struct FxEffect
    unit caster
    unit target
    real angle
    integer i
    private method OnStop takes nothing returns nothing
        set caster = null
        set target = null
    endmethod
    //! runtextmacro 연출()
endstruct

private struct FxEffect_Timer extends array
    private method OnAction takes FxEffect fx returns nothing
        local effect e
        local real r
        set fx.i = fx.i + 1
        if fx.caster != null and IsUnitDeadVJ(fx.caster) == false then
            if fx.i == 1 then
                call Sound3D(fx.caster,'A00E')
                set fx.angle = Angle.WBW(fx.caster,fx.target)
                call SetUnitFacing(fx.caster,fx.angle)
                call SetUnitX(fx.caster,GetUnitX(fx.target)+Polar.X( -75, fx.angle ))
                call SetUnitY(fx.caster,GetUnitY(fx.target)+Polar.Y( -75, fx.angle ))
            elseif fx.i == 34 then
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster),50 )
                call SetUnitX(fx.caster,GetUnitX(fx.caster)+Polar.X( -75, fx.angle ))
                call SetUnitY(fx.caster,GetUnitY(fx.caster)+Polar.Y( -75, fx.angle ))
                //call DestroyEffect(AddSpecialEffectTarget("1213.mdl",fx.target,"over head"))
                call DestroyEffect(AddSpecialEffectTarget("1!bloodex-special!.mdl",fx.target,"chest"))
                call HeroDeal(fx.caster,fx.target,DR)
            elseif fx.i > 34 and fx.i <= 40 then
                call SetUnitX(fx.caster,GetUnitX(fx.caster)+Polar.X( -75, fx.angle ))
                call SetUnitY(fx.caster,GetUnitY(fx.caster)+Polar.Y( -75, fx.angle ))
            elseif fx.i == 50 then
                call fx.Stop()
            endif
        else
            call fx.Stop()
        endif
    endmethod
    //! runtextmacro 연출효과_타이머("FxEffect", "0.02", "true")
endstruct
    
private function F_A00C takes nothing returns nothing
    local FxEffect fx
    set fx = FxEffect.Create()
    set fx.caster = GetTriggerUnit()
    set fx.target = GetSpellTargetUnit()
    set fx.i = 0
    call fx.Start()
    call DummyMagicleash(fx.caster,Time)
    call AnimationStart(fx.caster,21)
endfunction
    
//! runtextmacro 이벤트_맵이_로딩되면_발동()
    call AbilityEffectEvent.Create( 'A00C', function F_A00C )
//! runtextmacro 이벤트_끝()
//! runtextmacro 콘텐츠_끝()