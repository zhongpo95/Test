scope HeroJackG

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
        local effect e
        set fx.i = fx.i + 1
        if fx.caster != null and IsUnitDeadVJ(fx.caster) == false then
            if fx.i < 12 then
                //call Sound3D(fx.caster,'A00E')
                set fx.angle = AngleWBW(fx.caster,fx.target)
                call SetUnitFacing(fx.caster,fx.angle)
                call SetUnitX(fx.caster,GetWidgetX(fx.target)-PolarX( 650 - (fx.i * 50), fx.angle ))
                call SetUnitY(fx.caster,GetWidgetY(fx.target)-PolarY( 650 - (fx.i * 50), fx.angle ))
                if fx.i == 6 then
                    call UnitEffectTimeEX2('e00B',GetWidgetX(fx.caster),GetWidgetY(fx.caster),fx.angle,1.0,GetPlayerId(GetOwningPlayer(fx.caster)))
                    call Sound3D(fx.caster,'A009')
                endif
            elseif fx.i == 12 then
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster),15 )
            elseif fx.i == 45 then
                call Sound3D(fx.caster,'A00M')
            elseif fx.i == 50 then
                set fx.angle = AngleWBW(fx.caster,fx.target)
                call SetUnitX(fx.caster,GetWidgetX(fx.target)+PolarX( 250, fx.angle ))
                call SetUnitY(fx.caster,GetWidgetY(fx.target)+PolarY( 250, fx.angle ))
            elseif fx.i == 60 then
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster),50 )
                call Sound3D(fx.caster,'A00I')
                call UnitEffectTimeEX2('e00B',GetWidgetX(fx.target),GetWidgetY(fx.target),fx.angle+30,1.0,GetPlayerId(GetOwningPlayer(fx.caster)))
                call UnitEffectTimeEX2('e00C',GetWidgetX(fx.target),GetWidgetY(fx.target),fx.angle-30,1.0,GetPlayerId(GetOwningPlayer(fx.caster)))
                call UnitEffectTimeEX2('e00D',GetWidgetX(fx.target),GetWidgetY(fx.target),fx.angle-30,1.0,GetPlayerId(GetOwningPlayer(fx.caster)))
                call HeroDeal(fx.caster,fx.target,DR)
            elseif fx.i == 70 then
                call Sound3D(fx.caster,'A00H')
                call UnitEffectTimeEX2('e00B',GetWidgetX(fx.target),GetWidgetY(fx.target),fx.angle-30,1.0,GetPlayerId(GetOwningPlayer(fx.caster)))
                call UnitEffectTimeEX2('e00E',GetWidgetX(fx.target),GetWidgetY(fx.target),fx.angle-30,1.0,GetPlayerId(GetOwningPlayer(fx.caster)))
                call HeroDeal(fx.caster,fx.target,DR)
                
                call Sound3D(fx.caster,'A00L')
            elseif fx.i == 115 then
                call HeroDeal(fx.caster,fx.target,DR2)
                if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                    set e = AddSpecialEffectTarget(".mdl",fx.target,"chest")
                else
                    set e = AddSpecialEffectTarget("1!bloodex-special!.mdl",fx.target,"chest")
                endif
                call DestroyEffect(e)
                set e = null
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

    if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
        set fx.e = AddSpecialEffectTarget(".mdl",fx.caster,"chest")
        set fx.e2 = AddSpecialEffectTarget(".mdl",fx.caster,"right hand")
        set fx.e3 = AddSpecialEffectTarget(".mdl",fx.caster,"left hand")
    else
        set fx.e = AddSpecialEffectTarget("Effect_Ribbon_Black.mdl",fx.caster,"chest")
        set fx.e2 = AddSpecialEffectTarget("Effect_Ribbon_Black.mdl",fx.caster,"right hand")
        set fx.e3 = AddSpecialEffectTarget("Effect_Ribbon_Black.mdl",fx.caster,"left hand")
    endif

    set fx.i = 0
    call fx.Start()
    //call Sound3D(fx.caster,'A00K')
    call DummyMagicleash(fx.caster,Time)
    call AnimationStart(fx.caster,14)
endfunction
    
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    call AbilityEffectEvent.Create( 'A00J', function F_A00J )
//! runtextmacro 이벤트_끝()
endscope