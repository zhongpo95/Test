scope HeroChenS
globals
    private constant real DR = 1.84
    private constant real SD = 81.00
    
    private constant real CoolTime = 10.0
    
    //쉐클시간
    private constant real Time = 0.60
    //스킬이펙트 시간
    private constant real Time2 = 0.40
    //버프지속시간,공증량
    private constant real Time3 = 5
    private constant integer Velue = 335

    private constant real scale = 500
    private constant real distance = 150
endglobals

private struct FxEffect
    unit caster
    real TargetX
    real TargetY
    integer pid
    private method OnStop takes nothing returns nothing
        set caster = null
        set pid = 0
        set TargetX = 0
        set TargetY = 0
    endmethod
    //! runtextmacro 연출()
endstruct

private function splashD takes nothing returns nothing
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer level = HeroSkillLevel[pid][5]
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then

        call HeroDeal(splash.source,GetEnumUnit(),DR,true,false,SD,true)
        
        if level >= 1 then
            //call DeBuffMArm.Apply( GetEnumUnit(), 10.0, 0 )
        endif

    endif
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data
     
    if GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
        call UnitEffectTime2('e00B',GetWidgetX(fx.caster)+PolarX( 150, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster) + PolarY( 150, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster)+90,0.5,1)
        call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 15 )
        
        if HeroSkillLevel[fx.pid][5] >= 3 then
            //set DM = 200 * 1.7
        endif
        
        if splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 150, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 150, GetUnitFacing(fx.caster) ), scale, function splashD ) != 0 then
        endif
    endif
    
    call fx.Stop()
    call t.destroy()
endfunction

private function Main takes nothing returns nothing
    local real speed
    local tick t
    local FxEffect fx
    
    if GetSpellAbilityId() == 'A018' then
        set t = tick.create(0) 
        set fx = FxEffect.Create()
        set fx.caster = GetTriggerUnit()
        set fx.TargetX = GetSpellTargetX()
        set fx.TargetY = GetSpellTargetY()
        set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set speed = SkillSpeed(fx.pid)
        
        call Sound3D(fx.caster,'A01K')
        call CooldownFIX(fx.caster,'A018',CoolTime)
        call DummyMagicleash(fx.caster,Time * (1 - (speed/(100+speed)) ))
        call AnimationStart3(fx.caster,2, (100+speed)/100)
        
        set t.data = fx
        call t.start( Time2 * (1 - (speed/(100+speed)) ), false, function EffectFunction ) 
    endif
endfunction
    
private function SSyncData takes nothing returns nothing
    local player p=(DzGetTriggerSyncPlayer())
    local string data=(DzGetTriggerSyncData())
    local integer pid
    local integer dataLen=StringLength(data)
    local integer valueLen
    local real x
    local real y
    local real angle
    
    set pid=GetPlayerId(p)
    
    if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID5[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
        set x=S2R(data)
        set valueLen=StringLength(R2S(x))
        set data=SubString(data,valueLen+1,dataLen)
        set dataLen=dataLen-(valueLen+1)
        set y=S2R(data)
        set pid=GetPlayerId(p)
        set angle = AngleWBP(MainUnit[pid],x,y)
        call SetUnitFacing(MainUnit[pid],angle)
        call EXSetUnitFacing(MainUnit[pid],angle)
        call IssuePointOrder( MainUnit[pid], "animatedead", x, y )
    endif
    
    set p=null
endfunction

            
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("ChenS"),(false))
    call TriggerAddAction(t,function SSyncData)

    set t = null
//! runtextmacro 이벤트_끝()
endscope