scope HeroChenA
globals
    //private constant real CoolTime = 40.0 //빠준 8.0
    private constant real CoolTime = 10.0 //빠준 8.0
    //범위
    private constant real Dist = 1500
    //쉴드량
    private constant real Value = 0.15
    private constant real Value2 = 0.40
    //쉐클시간
    private constant real Time = 0.8
endglobals

private struct FxEffect
    unit caster
    unit target
    unit dummy
    real casterX
    real casterY
    real targetX
    real targetY
    real stopoverX
    real stopoverY
    real angle
    real r
    integer pid
    private method OnStop takes nothing returns nothing
        set casterX = 0
        set casterY = 0
        set targetX = 0
        set targetY = 0
        set stopoverX = 0
        set stopoverY = 0
        set angle = 0
        set r = 0
        set pid = 0
        set target = null
        set caster = null
        call KillUnit(dummy)
        set dummy = null
    endmethod
    //! runtextmacro 연출()
endstruct

private function EffectFunction2 takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data
    local real x
    local real y
    
    if fx.r <= 1 then
        set x = ((fx.casterX)*(1.00-fx.r)*(1.00-fx.r))
        set x = x + ((GetWidgetX(fx.target))*(fx.r * fx.r))
        set x = x + (2 * (fx.stopoverX) * (fx.r * (1.00 - fx.r)))
        call SetUnitX(fx.dummy, x )
        set y = ((fx.casterY)*(1.00-fx.r)*(1.00-fx.r))
        set y = y + ((GetWidgetY(fx.target))*(fx.r * fx.r))
        set y = y + (2 * (fx.stopoverY) * (fx.r * (1.00 - fx.r)))
        call SetUnitY(fx.dummy, y)
        set fx.r = fx.r + 0.03
        call t.start( 0.02, false, function EffectFunction2 ) 
    else
        if HeroSkillLevel[fx.pid][4] >= 2 then
            if HeroSkillLevel[fx.pid][4] >= 3 then
                call ShieldAdd(fx.target,12.0,GetUnitMaxLifeVJ(fx.caster)*Value2)
            else
                call ShieldAdd(fx.target,12.0,GetUnitMaxLifeVJ(fx.caster)*Value)
            endif
        else
            if HeroSkillLevel[fx.pid][4] >= 3 then
                call ShieldAdd(fx.target,6.0,GetUnitMaxLifeVJ(fx.caster)*Value2)
            else
                call ShieldAdd(fx.target,6.0,GetUnitMaxLifeVJ(fx.caster)*Value)
            endif
        endif
        call fx.Stop()
        call t.destroy()
    endif
endfunction

private function splashD takes nothing returns nothing
    local tick t
    local FxEffect fx
    local real random = GetRandomReal(300,700)
    local real random2 = GetRandomReal(120,240)
    
    set t = tick.create(0)
    set fx = FxEffect.Create()
    set fx.caster = splash.source
    set fx.target = GetEnumUnit()
    set fx.casterX = GetWidgetX(fx.caster)
    set fx.casterY = GetWidgetY(fx.caster)
    set fx.targetX = GetWidgetX(fx.target)
    set fx.targetY = GetWidgetY(fx.target)
    set fx.dummy = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e00W', fx.casterX , fx.casterY, GetUnitFacing(fx.caster))
    call SetUnitFlyHeight( fx.dummy, 100.00, 0.00 )
    set fx.angle = AngleWBW(fx.caster,fx.target)
    set fx.stopoverX = fx.casterX + PolarX(random, fx.angle + random2 )
    set fx.stopoverY = fx.casterY + PolarY(random, fx.angle + random2 )
    set fx.r = 0
    set fx.pid = GetPlayerId(GetOwningPlayer(fx.caster))
    
    set t.data = fx
    call t.start( 0.02, false, function EffectFunction2 ) 
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data
     
    if GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
        call UnitEffectTimeEX('e00X',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetUnitFacing(fx.caster),0.01)
        call splash.range( splash.ALLY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), Dist, function splashD )
        call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
    endif
    
    call fx.Stop()
    call t.destroy()
endfunction

private function Main takes nothing returns nothing
    local real speed
    local integer pid
    local tick t
    local FxEffect fx
    
    if GetSpellAbilityId() == 'A01E' then
        set t = tick.create(0)
        set fx = FxEffect.Create()
        set fx.caster = GetTriggerUnit()
        set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set speed = SkillSpeed(fx.pid)
        
        call Sound3D(fx.caster,'A01M')
        call DummyMagicleash(fx.caster,Time * (1 - (speed/(100+speed)) ))
        call AnimationStart3(fx.caster,10, (100+speed)/100)
        if HeroSkillLevel[fx.pid][4] >= 1 then
            call CooldownFIX(fx.caster,'A01E',CoolTime-8.0)
        else
            call CooldownFIX(fx.caster,'A01E',CoolTime)
        endif
        
        set t.data = fx
        call t.start( Time * (1 - (speed/(100+speed)) ), false, function EffectFunction ) 
    endif
endfunction

private function ASyncData takes nothing returns nothing
    local player p=(DzGetTriggerSyncPlayer())
    local string data=(DzGetTriggerSyncData())
    local integer pid
    local integer dataLen=StringLength(data)
    local integer valueLen
    local real x
    local real y
    local real angle
    
    set pid=GetPlayerId(p)
    
    if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID4[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
        set x=S2R(data)
        set valueLen=StringLength(R2S(x))
        set data=SubString(data,valueLen+1,dataLen)
        set dataLen=dataLen-(valueLen+1)
        set y=S2R(data)
        set pid=GetPlayerId(p)
        set angle = AngleWBP(MainUnit[pid],x,y)
        call SetUnitFacing(MainUnit[pid],angle)
        call EXSetUnitFacing(MainUnit[pid],angle)
        call IssuePointOrder( MainUnit[pid], "ancestralspirittarget", x, y )
    endif
    
    set p=null
endfunction

            
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("ChenA"),(false))
    call TriggerAddAction(t,function ASyncData)

    set t = null
//! runtextmacro 이벤트_끝()
endscope
