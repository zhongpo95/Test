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





    method destroy takes nothing returns nothing


        set caster = null
        set e = null
        set e2 = null


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

                    call expiredTick.destroy()

                    call fx.destroy()
                endif

            else

                call expiredTick.destroy()

                call fx.destroy()
            endif

endfunction

    
private function F_A001 takes nothing returns nothing
    local FxEffect fx
    local tick fxTick
    set fx = FxEffect.create()
    set fx.caster = GetTriggerUnit()
    set fx.i = 0
    set fx.Lv = GetUnitAbilityLevel(fx.caster,'A001')
    set fxTick = tick.create(fx)
    call fxTick.start(0.02, true, function FxEffectOnTimer)
    call DummyMagicleash(fx.caster,Time)
    call AnimationStart(fx.caster,9)
endfunction

    //function UnitEffectTimeSpeed2 takes integer id, real x, real y, real r, real time, integer i, real r2 returns unit
        //local EffectDummy t = EffectDummy.create()
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
