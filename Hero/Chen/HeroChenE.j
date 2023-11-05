//! runtextmacro 콘텐츠("HeroChenE")
globals
    private constant real DR = 5.13 //22.63
    private constant real SD = 109.00
    
    private constant real CoolTime = 16.0 //빠준5.6
    
    //쉐클시간
    private constant real Time = 0.60
    //스킬이펙트 시간
    private constant real Time2 = 0.20
    //스킬이펙트 시간2
    private constant real Time3 = 0.20
    //이동거리
    private constant real Dist = 450

    private constant real scale = 500
    private constant real distance = 200
endglobals

private struct FxEffect
    unit caster
    unit dummy
    real TargetX
    real TargetY
    real speed
    integer i
    private method OnStop takes nothing returns nothing
        set caster = null
        set dummy = null
        set i = 0
        set speed = 0
        set TargetX = 0
        set TargetY = 0
    endmethod
    //! runtextmacro 연출()
endstruct

private function splashD takes nothing returns nothing
    local real Velue = 1.0
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer level = HeroSkillLevel[pid][2]
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        if level >= 2 then
            set Velue = Velue * 1.70
        endif
        
        if level >= 3 then
            set Velue = Velue * 2.60
        endif
        
        call HeroDeal(splash.source,GetEnumUnit(),DR*Velue,true,false,SD,true)
    endif
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data
    
    set fx.i = fx.i + 1
    
    if fx.i == 1 and ( GetUnitAbilityLevel(fx.caster, 'BPSE') > 0 or GetUnitAbilityLevel(fx.caster, 'A024') > 0 ) then
        call fx.Stop()
        call t.destroy()
    else
        if fx.i == 1 then
            set fx.dummy = UnitEffectTime2('e00U',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetUnitFacing(fx.caster),1.0,1)
        endif
        
        if fx.i != 10 then
            call SetUnitSafePolarUTA(fx.caster,Dist/10,GetUnitFacing(fx.caster))
            call SetUnitX(fx.dummy,GetWidgetX(fx.caster))
            call SetUnitY(fx.dummy,GetWidgetY(fx.caster))
            call t.start( Time3 * (1 - (fx.speed/(100+fx.speed)) )/10, false, function EffectFunction )
        else
            call SetUnitSafePolarUTA(fx.caster,Dist/10,GetUnitFacing(fx.caster))
            call SetUnitX(fx.dummy,GetWidgetX(fx.caster))
            call SetUnitY(fx.dummy,GetWidgetY(fx.caster))
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+Polar.X( 100, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +Polar.Y( 100, GetUnitFacing(fx.caster) ), scale, function splashD )
            call fx.Stop()
            call t.destroy()
        endif
    endif
endfunction

private function Main takes nothing returns nothing
    local integer pid
    local tick t
    local FxEffect fx
    
    if GetSpellAbilityId() == 'A019' then
        set t = tick.create(0) 
        set fx = FxEffect.Create()
        set fx.caster = GetTriggerUnit()
        set fx.TargetX = GetSpellTargetX()
        set fx.TargetY = GetSpellTargetY()
        set fx.i = 0
        set pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set fx.speed = SkillSpeed(pid)
        
        call Sound3D(fx.caster,'A01P')
        if HeroSkillLevel[pid][2] >= 1 then
            call CooldownFIX(fx.caster,'A019',CoolTime-5.6)
        else
            call CooldownFIX(fx.caster,'A019',CoolTime)
        endif
        call DummyMagicleash(fx.caster, Time * (1 - (fx.speed/(100+fx.speed)) ))
        call AnimationStart3(fx.caster,17, (100+fx.speed)/100)
        
        set t.data = fx
        call t.start( Time2 * (1 - (fx.speed/(100+fx.speed)) ), false, function EffectFunction ) 
    endif
endfunction

private function ESyncData takes nothing returns nothing
    local player p=(DzGetTriggerSyncPlayer())
    local string data=(DzGetTriggerSyncData())
    local integer pid
    local integer dataLen=StringLength(data)
    local integer valueLen
    local real x
    local real y
    local real angle

    set pid=GetPlayerId(p)
        
    if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID2[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
        set x=S2R(data)
        set valueLen=StringLength(R2S(x))
        set data=SubString(data,valueLen+1,dataLen)
        set dataLen=dataLen-(valueLen+1)
        set y=S2R(data)
        set pid=GetPlayerId(p)
        set angle = Angle.WBP(MainUnit[pid],x,y)
        call SetUnitFacing(MainUnit[pid],angle)
        call EXSetUnitFacing(MainUnit[pid],angle)
        call IssuePointOrder( MainUnit[pid], "ambush", x, y )
    endif
    
    set p=null
endfunction

            
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("ChenE"),(false))
    call TriggerAddAction(t,function ESyncData)

    set t = null
//! runtextmacro 이벤트_끝()

//! runtextmacro 콘텐츠_끝()