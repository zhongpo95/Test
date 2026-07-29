scope HeroJackE

globals
    //데미지계수
    private constant real DR = 1.2
    //쉐클지속
    private constant real Time = 0.4
endglobals

private function splashD takes nothing returns nothing
    local texttag ttag
    //call HeroDeal(splash.source,GetEnumUnit(),DR)
    
    if HeadTrue(AngleWBW(splash.source,GetEnumUnit()), GetUnitFacing(GetEnumUnit())) == true then
        set ttag=CreateTextTag()
        call SetTextTagText(ttag, "헤드 어택", 0.020)
        call SetTextTagPos(ttag, GetWidgetX(GetEnumUnit()), GetWidgetY(GetEnumUnit()), 100)
        call SetTextTagColor(ttag, 255, 185, 0, 229)
        call SetTextTagVelocityBJ(ttag, 60.00, GetRandomReal(60.00, 120.00))
        call SetTextTagFadepoint(ttag, 0.6)
        call SetTextTagLifespan(ttag, 0.8)
        call SetTextTagPermanent(ttag, false)
        call SetTextTagVisibility(ttag, true)
    endif
    if BackTrue(AngleWBW(splash.source,GetEnumUnit()), GetUnitFacing(GetEnumUnit())) == true then
        set ttag=CreateTextTag()
        call SetTextTagText(ttag, "백 어택", 0.020)
        call SetTextTagPos(ttag, GetWidgetX(GetEnumUnit()), GetWidgetY(GetEnumUnit()), 100)
        call SetTextTagColor(ttag, 255, 185, 0, 229)
        call SetTextTagVelocityBJ(ttag, 60.00, GetRandomReal(60.00, 120.00))
        call SetTextTagFadepoint(ttag, 0.6)
        call SetTextTagLifespan(ttag, 0.8)
        call SetTextTagPermanent(ttag, false)
        call SetTextTagVisibility(ttag, true)
    endif
        
    if GetUnitAbilityLevel(GetEnumUnit(), 'A00V') == 1 then
        if HeadTrue(AngleWBW(splash.source,GetEnumUnit()), GetUnitFacing(GetEnumUnit())) == true then
            set ttag=CreateTextTag()
            call SetTextTagText(ttag, "카운터 어택", 0.020)
            call SetTextTagPos(ttag, GetWidgetX(GetEnumUnit()), GetWidgetY(GetEnumUnit()), 100)
            call SetTextTagColor(ttag, 255, 185, 0, 229)
            call SetTextTagVelocityBJ(ttag, 60.00, GetRandomReal(60.00, 120.00))
            call SetTextTagFadepoint(ttag, 0.6)
            call SetTextTagLifespan(ttag, 0.8)
            call SetTextTagPermanent(ttag, false)
            call SetTextTagVisibility(ttag, true)
            call UnitRemoveAbility(GetEnumUnit(), 'A00V')
        endif
    endif
endfunction
            
private struct FxEffect
    unit caster
    real TargetX
    real TargetY
    effect e
    effect e2
    integer i
    integer Lv
    private method cleanup takes nothing returns nothing
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
        
                    if fx.i == 15 then
        
                        call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 75, GetUnitFacing(fx.caster) ), 300, function splashD )
        
                        call UnitEffectTimeEX2('e005',GetWidgetX(fx.caster)+PolarX( 100, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster)+PolarY( 100, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.5,GetPlayerId(GetOwningPlayer(fx.caster)))
        
                        call Sound3D(fx.caster,'A00A')
        
                        call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster),10 )
        
                    elseif fx.i == 35 then
        
                        //call AnimationStart(fx.caster,4)
        
                        call expiredTick.destroy()

                        call fx.destroy()
                    endif
        
                else
        
                    call expiredTick.destroy()

                    call fx.destroy()
                endif
        
    endmethod


    static method createData takes nothing returns thistype
        local thistype this = allocate()



        return this
    endmethod

    method launch takes nothing returns nothing




        local tick t = tick.create(this)
        call t.start(0.02, true, function thistype.OnTimer)
    endmethod

    method destroy takes nothing returns nothing


        call this.cleanup()


        call deallocate()
    endmethod
endstruct

    
private function F_A008 takes nothing returns nothing
    local FxEffect fx
    set fx = FxEffect.createData()
    set fx.caster = GetTriggerUnit()
    set fx.i = 0
    call fx.launch()
    call DummyMagicleash(fx.caster,Time)
    call AnimationStart2(fx.caster,4,0.4,1.5)
endfunction
    
private struct TEvAfterA008 extends array
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function thistype.Action)
        call TriggerRegisterTimerEvent(t,2.0,false)
        set t = null
    endmethod
    private static method Action takes nothing returns nothing
        call AbilityEffectEvent.Create( 'A008', function F_A008 )
    endmethod
endstruct
endscope
