scope HeroMoS

globals
    private constant real DR = 9.92
    private constant real SD = 48
    
    private constant real CoolTime = 20.0//20.0
    //쉐클시간
    private constant real Time = 2.1
    //스킬이펙트 시간
    private constant real Time2 = 0.50
    //이동거리
    private constant real Dist = 300

    private constant real scale = 750
    private constant real distance = 500
endglobals
    
private struct FxEffect
    unit caster
    unit dummy
    unit dummy2
    real TargetX
    real TargetY
    integer pid
    real Velue
    real speed
    integer i
    private method OnStop takes nothing returns nothing
        set caster = null
        set dummy = null
        set dummy2 = null
        set pid = 0
        set Velue = 0
        set speed = 0
        set i = 0
        set TargetX = 0
        set TargetY = 0
    endmethod
    //! runtextmacro 연출()
endstruct

private function splashD takes nothing returns nothing
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer level = HeroSkillLevel[pid][5]
    local real velue = 1.0
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        //뒤는안떄림
        if AngleTrue( GetUnitFacing(splash.source), AngleWBW(splash.source,GetEnumUnit()), 135 ) then
            if level >= 3 then
                set velue = velue * 1.95
            endif
                    
            if level >= 2 then
                set Hero_CriDeal[pid] = Hero_CriDeal[pid] + 180
                call HeroDeal(splash.source,GetEnumUnit(),DR*velue,false,false,SD,false)
                set Hero_CriDeal[pid] = Hero_CriDeal[pid] - 180
            else
                call HeroDeal(splash.source,GetEnumUnit(),DR*velue,false,false,SD,false)
            endif
        endif
    endif
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data

    if GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
        set fx.dummy = UnitEffectTime2('e01A', GetWidgetX(fx.caster), GetWidgetY(fx.caster), GetUnitFacing(fx.caster),0.1,1)
        set fx.dummy = UnitEffectTime2('e01A', GetWidgetX(fx.caster), GetWidgetY(fx.caster), GetUnitFacing(fx.caster),0.1,1)
        set fx.dummy = UnitEffectTime2('e01A', GetWidgetX(fx.caster), GetWidgetY(fx.caster), GetUnitFacing(fx.caster),0.1,1)
        set fx.dummy = UnitEffectTime2('e01A', GetWidgetX(fx.caster), GetWidgetY(fx.caster), GetUnitFacing(fx.caster),0.1,1)
        
        call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale, function splashD )
        
        call fx.Stop()
        call t.destroy()
    else
        call fx.Stop()
        call t.destroy()
    endif
endfunction

private function Main takes nothing returns nothing
    local real speed
    local tick t
    local FxEffect fx
    if GetSpellAbilityId() == 'A013' then
        set t = tick.create(0) 
        set fx = FxEffect.Create()
        set fx.caster = GetTriggerUnit()
        set fx.TargetX = GetSpellTargetX()
        set fx.TargetY = GetSpellTargetY()
        set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        if HeroSkillLevel[fx.pid][5] >= 1 then
            set fx.speed = SkillSpeed2(fx.pid, 100.0)
            call CooldownFIX(fx.caster,'A013',CoolTime-5.0)
        else
            set fx.speed = SkillSpeed(fx.pid)
            call CooldownFIX(fx.caster,'A013',CoolTime)
        endif
        set fx.i = 0
        
        call Sound3D(fx.caster,'A01W')
        
        call DummyMagicleash(fx.caster,Time * (1 - (fx.speed/(100+fx.speed)) ))
        call AnimationStart3(fx.caster,13, (100+fx.speed)/100)
        
        set t.data = fx
        call t.start( Time2 * (1 - (fx.speed/(100+fx.speed)) ), false, function EffectFunction ) 
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
    call DzTriggerRegisterSyncData(t,("MoS"),(false))
    call TriggerAddAction(t,function SSyncData)

    set t = null
//! runtextmacro 이벤트_끝()
endscope

