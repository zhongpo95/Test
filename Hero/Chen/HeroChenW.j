//! runtextmacro 콘텐츠("HeroChenW")
globals
    private constant real DR = 2.35
    private constant real SD = 20.00
    
    private constant real CoolTime = 7.0
    
    //쉐클시간
    private constant real Time = 0.50
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
    local integer level = HeroSkillLevel[pid][1]
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        if level >= 2 then
            set Velue = Velue * 1.5
        endif
        
        if level >= 3 then
            set Velue = Velue * 2.0
        endif
        
        call HeroDeal(splash.source,GetEnumUnit(),(DR/2)*Velue,true,false,SD,false)
        call HeroDeal(splash.source,GetEnumUnit(),(DR/2)*Velue,true,false,SD,false)
    endif
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data
     
    if GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
        call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+Polar.X( 75, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +Polar.Y( 75, GetUnitFacing(fx.caster) ), scale, function splashD )
        call UnitEffectTimeEX('e00I',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetUnitFacing(fx.caster)+180,0.01)
        call UnitEffectTimeEX('e00H',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetUnitFacing(fx.caster),0.01)
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
    local real random
         
    if GetSpellAbilityId() == 'A017' then
        set t = tick.create(0)
        set fx = FxEffect.Create()
        set fx.caster = GetTriggerUnit()
        set fx.TargetX = GetSpellTargetX()
        set fx.TargetY = GetSpellTargetY()
        set pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set speed = SkillSpeed(pid)
        
        call Sound3D(fx.caster,'A01J')
        if HeroSkillLevel[pid][1] >= 1 then
            if GetRandomInt(0,1) == 1 then
                call CooldownFIX(fx.caster,'A017', CoolTime - 5.00)
            else
                call CooldownFIX(fx.caster,'A017', CoolTime)
            endif
        else
            call CooldownFIX(fx.caster,'A017', CoolTime)
        endif
        call DummyMagicleash(fx.caster,Time * (1 - (speed/(100+speed)) ))
        call AnimationStart3(fx.caster,9, (100+speed)/100)
        
        set t.data = fx
        call t.start( Time2 * (1 - (speed/(100+speed)) ), false, function EffectFunction ) 
    endif
endfunction
    
private function WSyncData takes nothing returns nothing
    local player p=(DzGetTriggerSyncPlayer())
    local string data=(DzGetTriggerSyncData())
    local integer pid
    local integer dataLen=StringLength(data)
    local integer valueLen
    local real x
    local real y
    local real angle
    
    set pid=GetPlayerId(p)
    
    if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID1[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
        set x=S2R(data)
        set valueLen=StringLength(R2S(x))
        set data=SubString(data,valueLen+1,dataLen)
        set dataLen=dataLen-(valueLen+1)
        set y=S2R(data)
        set pid=GetPlayerId(p)
        set angle = Angle.WBP(MainUnit[pid],x,y)
        call SetUnitFacing(MainUnit[pid],angle)
        call EXSetUnitFacing(MainUnit[pid],angle)
        call IssuePointOrder( MainUnit[pid], "acolyteharvest", x, y )
    endif
    
    set p=null
endfunction


//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("ChenW"),(false))
    call TriggerAddAction(t,function WSyncData)

    set t = null
//! runtextmacro 이벤트_끝()
//! runtextmacro 콘텐츠_끝()