//! runtextmacro 콘텐츠("HeroJackZ")

globals
    //애니
    private constant integer AniIndex1 = 9
    private constant real Range = 300
    //데미지계수 6회
    private constant real DR = 1.68
    private constant real DR2 = 1.91
    //쉐클지속
    private constant real Time = 0.75
    private constant real MP = 2
endglobals

private function splashD takes nothing returns nothing
    local real r = Distance.WBW(splash.source,GetEnumUnit())
    //call Deal(splash.source,GetEnumUnit(),DR*SkillDamageRate[splash.int])
endfunction

private struct FxEffect
    unit caster
    real TargetX
    real TargetY
    effect e
    effect e2
    effect e3
    integer i
    integer Lv
    private method OnStop takes nothing returns nothing
        set caster = null
        call DestroyEffect(e)
        set e = null
        set e2 = null
        set e3 = null
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
                call SetUnitX(fx.caster,fx.TargetX)
                call SetUnitY(fx.caster,fx.TargetY)
                call AnimationStart(fx.caster,10)
                call UnitEffectTimeEX('e00A',GetUnitX(fx.caster),GetUnitY(fx.caster),GetUnitFacing(fx.caster),2)
                call Sound3D(fx.caster,'A00F')
            elseif fx.i == 50 then
                call fx.Stop()
            endif
        else
            call fx.Stop()
        endif
    endmethod
    //! runtextmacro 연출효과_타이머("FxEffect", "0.02", "true")
endstruct
    
private function F_A00D takes nothing returns nothing
    local FxEffect fx
    local SkillDash st = SkillDash.Create()
    local real angle
    
    set fx = FxEffect.Create()
    set fx.caster = GetTriggerUnit()
    set fx.TargetX = GetSpellTargetX()
    set fx.TargetY = GetSpellTargetY()
    set fx.e = AddSpecialEffectTarget("Effect_Ribbon_Black.mdl",fx.caster,"chest")
    //set fx.e2 = AddSpecialEffectTarget("Effect_Ribbon_Black.mdl",fx.caster,"left hand")
    //set fx.e3 = AddSpecialEffectTarget("Effect_Ribbon_Black.mdl",fx.caster,"right hand")
    set fx.i = 0
    call fx.Start()
    call DummyMagicleash(fx.caster,1)
    call AnimationStart(fx.caster,10)
endfunction
    
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    call AbilityEffectEvent.Create( 'A00D', function F_A00D )
//! runtextmacro 이벤트_끝()
//! runtextmacro 콘텐츠_끝()