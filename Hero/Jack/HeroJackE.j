//! runtextmacro 콘텐츠("HeroJackE")

globals
    //데미지계수
    private constant real DR = 1.2
    //쉐클지속
    private constant real Time = 0.4
endglobals

private function splashD takes nothing returns nothing
    local texttag ttag
    call HeroDeal(splash.source,GetEnumUnit(),DR)
    
    if HeadTrue(Angle.WBW(splash.source,GetEnumUnit()), GetUnitFacing(GetEnumUnit())) == true then
        set ttag=CreateTextTag()
        call SetTextTagText(ttag, "헤드 어택", 0.020)
        call SetTextTagPos(ttag, GetUnitX(GetEnumUnit()), GetUnitY(GetEnumUnit()), 100)
        call SetTextTagColor(ttag, 255, 185, 0, 229)
        call SetTextTagVelocityBJ(ttag, 60.00, GetRandomReal(60.00, 120.00))
        call SetTextTagFadepoint(ttag, 0.6)
        call SetTextTagLifespan(ttag, 0.8)
        call SetTextTagPermanent(ttag, false)
        call SetTextTagVisibility(ttag, true)
    endif
    if BackTrue(Angle.WBW(splash.source,GetEnumUnit()), GetUnitFacing(GetEnumUnit())) == true then
        set ttag=CreateTextTag()
        call SetTextTagText(ttag, "백 어택", 0.020)
        call SetTextTagPos(ttag, GetUnitX(GetEnumUnit()), GetUnitY(GetEnumUnit()), 100)
        call SetTextTagColor(ttag, 255, 185, 0, 229)
        call SetTextTagVelocityBJ(ttag, 60.00, GetRandomReal(60.00, 120.00))
        call SetTextTagFadepoint(ttag, 0.6)
        call SetTextTagLifespan(ttag, 0.8)
        call SetTextTagPermanent(ttag, false)
        call SetTextTagVisibility(ttag, true)
    endif
        
    if GetUnitAbilityLevel(GetEnumUnit(), 'A00V') == 1 then
        if HeadTrue(Angle.WBW(splash.source,GetEnumUnit()), GetUnitFacing(GetEnumUnit())) == true then
            set ttag=CreateTextTag()
            call SetTextTagText(ttag, "카운터 어택", 0.020)
            call SetTextTagPos(ttag, GetUnitX(GetEnumUnit()), GetUnitY(GetEnumUnit()), 100)
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
            if fx.i == 15 then
                call splash.range( splash.ENEMY, fx.caster, GetUnitX(fx.caster)+Polar.X( 75, GetUnitFacing(fx.caster) ), GetUnitY(fx.caster) +Polar.Y( 75, GetUnitFacing(fx.caster) ), 300, function splashD )
                call UnitEffectTimeEX('e005',GetUnitX(fx.caster)+Polar.X( 100, GetUnitFacing(fx.caster) ),GetUnitY(fx.caster)+Polar.Y( 100, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.5)
                call Sound3D(fx.caster,'A00A')
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster),10 )
            elseif fx.i == 35 then
                //call AnimationStart(fx.caster,4)
                call fx.Stop()
            endif
        else
            call fx.Stop()
        endif
    endmethod
    //! runtextmacro 연출효과_타이머("FxEffect", "0.02", "true")
endstruct
    
private function F_A008 takes nothing returns nothing
    local FxEffect fx
    set fx = FxEffect.Create()
    set fx.caster = GetTriggerUnit()
    set fx.i = 0
    call fx.Start()
    call DummyMagicleash(fx.caster,Time)
    call AnimationStart2(fx.caster,4,0.4,1.5)
endfunction
    
//! runtextmacro 이벤트_맵이_로딩되면_발동()
    call AbilityEffectEvent.Create( 'A008', function F_A008 )
//! runtextmacro 이벤트_끝()
//! runtextmacro 콘텐츠_끝()