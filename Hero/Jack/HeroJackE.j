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
                    if fx.i == 15 then        
                        call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 75, GetUnitFacing(fx.caster) ), 300, function splashD )        
                        call UnitEffectTimeEX2('e005',GetWidgetX(fx.caster)+PolarX( 100, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster)+PolarY( 100, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.5,GetPlayerId(GetOwningPlayer(fx.caster)))        
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

    private tick __lifeTick
    private boolean __lifeStarted
    private boolean __lifeStopping

    static method Create takes nothing returns thistype
        local thistype this = allocate()

        set __lifeStarted = false
        set __lifeStopping = false
        set __lifeTick = 0

        static if thistype.OnCreate.exists then
            call this.OnCreate()
        endif

        return this
    endmethod

    method Start takes nothing returns nothing
        if __lifeStarted then
            return
        endif

        set __lifeStarted = true

        static if thistype.OnStart.exists then
            call this.OnStart()
        endif

        if __lifeTick != 0 then
            return
        endif

        set __lifeTick = tick.create(0)
        set __lifeTick.data = this
        call __lifeTick.start(0.02, true, function thistype.OnTimer)
    endmethod

    method Stop takes nothing returns nothing
        if __lifeStopping then
            return
        endif

        set __lifeStopping = true

        static if thistype.OnStop.exists then
            call this.OnStop()
        endif

        if __lifeTick != 0 then
            call __lifeTick.destroy()
            set __lifeTick = 0
        endif

        call deallocate()
    endmethod
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
    
//! runtextmacro 이벤트_N초가_지나면_발동("2.0")
    call AbilityEffectEvent.Create( 'A008', function F_A008 )
//! runtextmacro 이벤트_끝()
endscope