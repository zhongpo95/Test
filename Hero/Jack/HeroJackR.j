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
    private method OnStop takes nothing returns nothing
        set caster = null
        set target = null
    endmethod

    private static method OnTimer takes nothing returns nothing
        local tick expiredTick = tick.getExpired()
        local thistype fx = expiredTick.data
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
    
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    call AbilityEffectEvent.Create( 'A00C', function F_A00C )
//! runtextmacro 이벤트_끝()
endscope