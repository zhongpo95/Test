//! runtextmacro 콘텐츠("HeroJackG")

globals
    //데미지계수
    private constant real DR = 0.1
    private constant real DR2 = 3.0
    //쉐클지속
    private constant real Time = 2.0
endglobals

private struct FxEffect
    unit caster
    unit target
    real angle
    effect e
    effect e2
    effect e3
    integer i
    private method OnStop takes nothing returns nothing
        call DestroyEffect(e)
        call DestroyEffect(e2)
        call DestroyEffect(e3)
        set e = null
        set e3 = null
        set e2 = null
        set caster = null
        set target = null
    endmethod
    //! runtextmacro 연출()
endstruct

private struct FxEffect_Timer extends array
    private method OnAction takes FxEffect fx returns nothing
        local real x
        local real r
        set fx.i = fx.i + 1
        if fx.caster != null and IsUnitDeadVJ(fx.caster) == false then
            if fx.i < 12 then
                //call Sound3D(fx.caster,'A00E')
                set fx.angle = Angle.WBW(fx.caster,fx.target)
                call SetUnitFacing(fx.caster,fx.angle)
                call SetUnitX(fx.caster,GetUnitX(fx.target)-Polar.X( 650 - (fx.i * 50), fx.angle ))
                call SetUnitY(fx.caster,GetUnitY(fx.target)-Polar.Y( 650 - (fx.i * 50), fx.angle ))
                if fx.i == 6 then
                    call UnitEffectTimeEX('e00B',GetUnitX(fx.caster),GetUnitY(fx.caster),fx.angle,1.0)
                    call Sound3D(fx.caster,'A009')
                endif
            elseif fx.i == 12 then
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster),15 )
            elseif fx.i == 45 then
                call Sound3D(fx.caster,'A00M')
            elseif fx.i == 50 then
                set fx.angle = Angle.WBW(fx.caster,fx.target)
                call SetUnitX(fx.caster,GetUnitX(fx.target)+Polar.X( 250, fx.angle ))
                call SetUnitY(fx.caster,GetUnitY(fx.target)+Polar.Y( 250, fx.angle ))
            elseif fx.i == 60 then
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster),50 )
                call Sound3D(fx.caster,'A00I')
                call UnitEffectTimeEX('e00B',GetUnitX(fx.target),GetUnitY(fx.target),fx.angle+30,1.0)
                call UnitEffectTimeEX('e00C',GetUnitX(fx.target),GetUnitY(fx.target),fx.angle-30,1.0)
                call UnitEffectTimeEX('e00D',GetUnitX(fx.target),GetUnitY(fx.target),fx.angle-30,1.0)
                call HeroDeal(fx.caster,fx.target,DR)
            elseif fx.i == 70 then
                call Sound3D(fx.caster,'A00H')
                call UnitEffectTimeEX('e00B',GetUnitX(fx.target),GetUnitY(fx.target),fx.angle-30,1.0)
                call UnitEffectTimeEX('e00E',GetUnitX(fx.target),GetUnitY(fx.target),fx.angle-30,1.0)
                call HeroDeal(fx.caster,fx.target,DR)
                
                call Sound3D(fx.caster,'A00L')
            elseif fx.i == 115 then
                call HeroDeal(fx.caster,fx.target,DR2)
                call DestroyEffect(AddSpecialEffectTarget("1!bloodex-special!.mdl",fx.target,"chest"))
                call fx.Stop()
            endif
        else
            call fx.Stop()
        endif
    endmethod
    //! runtextmacro 연출효과_타이머("FxEffect", "0.02", "true")
endstruct
    
private function F_A00J takes nothing returns nothing
    local FxEffect fx
    set fx = FxEffect.Create()
    set fx.caster = GetTriggerUnit()
    set fx.target = GetSpellTargetUnit()
    set fx.e = AddSpecialEffectTarget("Effect_Ribbon_Black.mdl",fx.caster,"chest")
    set fx.e2 = AddSpecialEffectTarget("Effect_Ribbon_Black.mdl",fx.caster,"right hand")
    set fx.e3 = AddSpecialEffectTarget("Effect_Ribbon_Black.mdl",fx.caster,"left hand")
    set fx.i = 0
    call fx.Start()
    //call Sound3D(fx.caster,'A00K')
    call DummyMagicleash(fx.caster,Time)
    call AnimationStart(fx.caster,14)
endfunction
    
//! runtextmacro 이벤트_맵이_로딩되면_발동()
    call AbilityEffectEvent.Create( 'A00J', function F_A00J )
//! runtextmacro 이벤트_끝()
//! runtextmacro 콘텐츠_끝()