scope HeroMoR

globals
    private constant real MaxRange = 1000
    private constant real CoolTime = 14.0
    //쉐클시간
    private constant real Time = 0.30
    //스킬이펙트 시간
    private constant real Time2 = 0.50
    //스킬 지속시간
    private constant real Time3 = 0.06
    //스킬 틱
    private constant real TICK = 12
    
    private constant real DR = 5.56/6
    private constant real SD = 10

    private constant real scale = 500
    private constant real distance = 150
endglobals
       
private struct FxEffect
    unit caster
    unit dummy1
    unit dummy2
    unit dummy3
    real CasterX
    real CasterY
    real Angle
    integer pid
    real Velue
    real speed
    integer i
    private method OnStop takes nothing returns nothing
        set caster = null
        set dummy1 = null
        set dummy2 = null
        set dummy3 = null
        set pid = 0
        set Velue = 0
        set speed = 0
        set i = 0
        set Angle = 0
        set CasterX = 0
        set CasterY = 0
    endmethod
    //! runtextmacro 연출()
endstruct

private function splashD takes nothing returns nothing
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer level = HeroSkillLevel[pid][3]
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        if level >= 1 then
            call DeBuffCri.Apply( GetEnumUnit(), 12.0, 0 )
        endif
        
        if level >= 2 then
            if level >= 3 then
                call HeroDeal(splash.source,GetEnumUnit(),(DR*2.72),false,false,SD,false)
            else
                call HeroDeal(splash.source,GetEnumUnit(),(DR*1.60),false,false,SD,false)
            endif
        else
            call HeroDeal(splash.source,GetEnumUnit(),(DR),false,false,SD,false)
        endif
    endif
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data
    local tick t2
    local FxEffect fx2

    set fx.i = fx.i + 1
    
    if fx.i == 1 and ( GetUnitAbilityLevel(fx.caster, 'BPSE') > 0 or GetUnitAbilityLevel(fx.caster, 'A024') > 0 )  then
        call fx.Stop()
        call t.destroy()
    else
        if fx.i != (TICK+1) then
            set fx.dummy1 = UnitEffectTime2('e018', fx.CasterX+PolarX((fx.i*125),fx.Angle+335), fx.CasterY+PolarY((fx.i*125),fx.Angle+335),GetRandomReal(0,360),1.2,1)
            set fx.dummy2 = UnitEffectTime2('e018', fx.CasterX+PolarX((fx.i*125),fx.Angle), fx.CasterY+PolarY((fx.i*125),fx.Angle),GetRandomReal(0,360),1.2,1)
            set fx.dummy3 = UnitEffectTime2('e018', fx.CasterX+PolarX((fx.i*125),fx.Angle+25), fx.CasterY+PolarY((fx.i*125),fx.Angle+25),GetRandomReal(0,360),1.2,1)
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.dummy1), GetWidgetY(fx.dummy1), scale, function splashD )
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.dummy2), GetWidgetY(fx.dummy2), scale, function splashD )
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.dummy3), GetWidgetY(fx.dummy3), scale, function splashD )
            call t.start( Time3 * (1 - (fx.speed/(100+fx.speed)) ), false, function EffectFunction )
        else
            call fx.Stop()
            call t.destroy()
        endif
    endif
endfunction

    
private function Main takes nothing returns nothing
    local real speed
    local tick t
    local FxEffect fx
    if GetSpellAbilityId() == 'A011' then
        set t = tick.create(0) 
        set fx = FxEffect.Create()
        set fx.caster = GetTriggerUnit()
        set fx.CasterX = GetWidgetX(fx.caster)
        set fx.CasterY = GetWidgetY(fx.caster)
        set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set fx.speed = SkillSpeed(fx.pid)
        set fx.Angle = AngleWBP(fx.caster, GetSpellTargetX(), GetSpellTargetY())
        set fx.i = 0
        
        call CooldownFIX(fx.caster,'A011',CoolTime)
        call DummyMagicleash(fx.caster,Time * (1 - (fx.speed/(100+fx.speed)) ))
        call AnimationStart3(fx.caster,5, (100+fx.speed)/100)
        
        set t.data = fx
        call t.start( Time2 * (1 - (fx.speed/(100+fx.speed)) ), false, function EffectFunction ) 
    endif
endfunction

    private function RSyncData takes nothing returns nothing
        local player p=(DzGetTriggerSyncPlayer())
        local string data=(DzGetTriggerSyncData())
        local integer pid
        local integer dataLen=StringLength(data)
        local integer valueLen
        local real x
        local real y
        local real angle
        
        set pid=GetPlayerId(p)
        
        if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID3[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
            set x=S2R(data)
            set valueLen=StringLength(R2S(x))
            set data=SubString(data,valueLen+1,dataLen)
            set dataLen=dataLen-(valueLen+1)
            set y=S2R(data)
            set pid=GetPlayerId(p)
            set angle = AngleWBP(MainUnit[pid],x,y)
            call SetUnitFacing(MainUnit[pid],angle)
            call EXSetUnitFacing(MainUnit[pid],angle)
            call IssuePointOrder( MainUnit[pid], "ancestralspirit", x, y )
        endif
        
        set p=null
    endfunction

            
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("MoR"),(false))
    call TriggerAddAction(t,function RSyncData)

    set t = null
//! runtextmacro 이벤트_끝()
endscope

