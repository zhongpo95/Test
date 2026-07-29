scope HeroJackR

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





    method destroy takes nothing returns nothing


        set caster = null
        set target = null


        call deallocate()
    endmethod
endstruct

private function FxEffectOnTimer takes nothing returns nothing
    local tick expiredTick = tick.getExpired()
    local FxEffect fx = expiredTick.data
            local effect e

            local real r

            set fx.i = fx.i + 1

            if fx.caster != null and IsUnitDeadVJ(fx.caster) == false then

                if fx.i == 1 then

                    call Sound3D(fx.caster,'A00E')

                    set fx.angle = AngleWBW(fx.caster,fx.target)

                    call SetUnitFacing(fx.caster,fx.angle)

                    call SetUnitX(fx.caster,GetWidgetX(fx.target)+PolarX( -75, fx.angle ))

                    call SetUnitY(fx.caster,GetWidgetY(fx.target)+PolarY( -75, fx.angle ))

                elseif fx.i == 34 then

                    call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster),50 )

                    call SetUnitX(fx.caster,GetWidgetX(fx.caster)+PolarX( -75, fx.angle ))

                    call SetUnitY(fx.caster,GetWidgetY(fx.caster)+PolarY( -75, fx.angle ))

                    //call DestroyEffect(AddSpecialEffectTarget("1213.mdl",fx.target,"over head"))

                    if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then

                        set e = AddSpecialEffectTarget(".mdl",fx.target,"chest")

                    else

                        set e = AddSpecialEffectTarget("1!bloodex-special!.mdl",fx.target,"chest")

                    endif

                    call DestroyEffect(e)

                    set e = null

                    call HeroDeal(fx.caster,fx.target,DR)

                elseif fx.i > 34 and fx.i <= 40 then

                    call SetUnitX(fx.caster,GetWidgetX(fx.caster)+PolarX( -75, fx.angle ))

                    call SetUnitY(fx.caster,GetWidgetY(fx.caster)+PolarY( -75, fx.angle ))

                elseif fx.i == 50 then

                    call expiredTick.destroy()

                    call fx.destroy()
                endif

            else

                call expiredTick.destroy()

                call fx.destroy()
            endif

endfunction

    
private function F_A00C takes nothing returns nothing
    local FxEffect fx
    local tick fxTick
    set fx = FxEffect.create()
    set fx.caster = GetTriggerUnit()
    set fx.target = GetSpellTargetUnit()
    set fx.i = 0
    set fxTick = tick.create(fx)
    call fxTick.start(0.02, true, function FxEffectOnTimer)
    call DummyMagicleash(fx.caster,Time)
    call AnimationStart(fx.caster,21)
endfunction
    
private struct TEvAfterB extends array
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function thistype.Action)
        call TriggerRegisterTimerEvent(t,2.0,false)
        set t = null
    endmethod
    private static method Action takes nothing returns nothing
        call AbilityEffectEvent.Create( 'A00C', function F_A00C )
    endmethod
endstruct
endscope
