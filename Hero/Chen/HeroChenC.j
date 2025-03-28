scope HeroChenC
globals
    private constant real DR = 1.00
    private constant real SD = 0.00
    
    private constant real CoolTime = 1.0
    
    //쉐클시간
    private constant real Time = 0.60
    //스킬이펙트 시간
    private constant real Time2 = 0.40

    private constant real scale = 500
    private constant real distance = 150
endglobals

private struct FxEffect
    unit caster
    real TargetX
    real TargetY
    private method OnStop takes nothing returns nothing
        set caster = null
        set TargetX = 0
        set TargetY = 0
    endmethod
    //! runtextmacro 연출()
endstruct

private function splashD takes nothing returns nothing
    local real Velue = 1.0
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        call HeroDeal(splash.source,GetEnumUnit(),DR*Velue,false,false,false,false)
    endif
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data
     
    if GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
        call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 75, GetUnitFacing(fx.caster) ), scale, function splashD )
    endif
    
    call fx.Stop()
    call t.destroy()
endfunction

private function Main takes nothing returns nothing
    local real speed
    local integer pid
    local tick t
    local FxEffect fx
    local real random
         
    if GetSpellAbilityId() == 'A028' then
        set t = tick.create(0) 
        set fx = FxEffect.Create()
        set fx.caster = GetTriggerUnit()
        set fx.TargetX = GetSpellTargetX()
        set fx.TargetY = GetSpellTargetY()
        set pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set speed = ((100+SkillSpeed(pid))/100)
        
        call CooldownFIX(fx.caster,'A028', CoolTime)

        call DummyMagicleash(fx.caster,Time /speed)
        call AnimationStart3(fx.caster,2, (100+speed)/100)
        
        set t.data = fx
        call t.start( Time2 /speed, false, function EffectFunction ) 
    endif
endfunction
    
private function CSyncData takes nothing returns nothing
    local player p=(DzGetTriggerSyncPlayer())
    local string data=(DzGetTriggerSyncData())
    local integer pid
    local integer dataLen=StringLength(data)
    local integer valueLen
    local real x
    local real y
    local real angle
    
    set pid=GetPlayerId(p)
    
    if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID9[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
        set x=S2R(data)
        set valueLen=StringLength(R2S(x))
        set data=SubString(data,valueLen+1,dataLen)
        set dataLen=dataLen-(valueLen+1)
        set y=S2R(data)
        set pid=GetPlayerId(p)
        set angle = AngleWBP(MainUnit[pid],x,y)
        call SetUnitFacing(MainUnit[pid],angle)
        call EXSetUnitFacing(MainUnit[pid],angle)
        call IssuePointOrder( MainUnit[pid], "auravampiric", x, y )
    endif
    
    set p=null
endfunction


//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("ChenC"),(false))
    call TriggerAddAction(t,function CSyncData)

    set t = null
//! runtextmacro 이벤트_끝()
endscope