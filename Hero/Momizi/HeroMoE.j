scope HeroMoE

globals
    private constant real MaxRange = 1000
    //쉐클시간
    private constant real Time = 0.30
    //스킬이펙트 시간
    private constant real Time2 = 0.60
    //스킬 지속시간
    private constant real Time3 = 2.5
    //스킬 틱
    private constant real TICK = 6
    
    private constant real SD = 113/6

    private constant real scale = 650
    private constant real distance = 425
endglobals
       
private struct FxEffect
    unit caster
    unit dummy
    real TargetX
    real TargetY
    integer pid
    real Velue
    real speed
    integer i
    private method OnStop takes nothing returns nothing
        set caster = null
        set dummy = null
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
    local integer level = HeroSkillLevel[pid][2]
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        if level >= 2 then
            if level >= 3 then
                call HeroDeal(splash.source,GetEnumUnit(),(HeroSkillVelue2[3]*3.06)/TICK,false,false,SD,false)
            else
                call HeroDeal(splash.source,GetEnumUnit(),(HeroSkillVelue2[3]*1.70)/TICK,false,false,SD,false)
            endif
        else
            call HeroDeal(splash.source,GetEnumUnit(),(HeroSkillVelue2[3])/TICK,false,false,SD,false)
        endif
    endif
    
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data
    local tick t2
    local FxEffect fx2

    set fx.i = fx.i + 1
    if fx.i == 1 and ( GetUnitAbilityLevel(fx.caster, 'BPSE') > 0 or GetUnitAbilityLevel(fx.caster, 'A024') > 0 ) then
        call fx.Stop()
        call t.destroy()
    else
        if fx.i != (TICK+1) then
            set fx.dummy = UnitEffectTime2('e013',fx.TargetX,fx.TargetY,GetRandomReal(0,360),3.0,1,GetPlayerId(GetOwningPlayer(fx.caster)))
            set fx.dummy = UnitEffectTime2('e014',fx.TargetX,fx.TargetY,GetRandomReal(0,360),3.0,1,GetPlayerId(GetOwningPlayer(fx.caster)))
            set fx.dummy = UnitEffectTime2('e015',fx.TargetX,fx.TargetY,GetRandomReal(0,360),3.0,1,GetPlayerId(GetOwningPlayer(fx.caster)))
            set fx.dummy = UnitEffectTime2('e016',fx.TargetX,fx.TargetY,GetRandomReal(0,360),3.0,1,GetPlayerId(GetOwningPlayer(fx.caster)))
            set fx.dummy = UnitEffectTime2('e017',fx.TargetX,fx.TargetY,GetRandomReal(0,360),3.0,1,GetPlayerId(GetOwningPlayer(fx.caster)))
            call splash.range( splash.ENEMY, fx.caster, fx.TargetX, fx.TargetY, scale, function splashD )
            call t.start( Time3 * (1 - (fx.speed/(100+fx.speed)) )/TICK, false, function EffectFunction )
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
    if GetSpellAbilityId() == 'A010' then
        set t = tick.create(0) 
        set fx = FxEffect.Create()
        set fx.caster = GetTriggerUnit()
        set fx.TargetX = GetSpellTargetX()
        set fx.TargetY = GetSpellTargetY()
        set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set fx.speed = SkillSpeed(fx.pid)
        set fx.i = 0
        
        //call Sound3D(fx.caster,'A01W')
        if HeroSkillLevel[fx.pid][2] >= 1 then
            call CooldownFIX(fx.caster,'A010',HeroSkillCD2[3]-11.0)
        else
            call CooldownFIX(fx.caster,'A010',HeroSkillCD2[3])
        endif
        call DummyMagicleash(fx.caster,Time * (1 - (fx.speed/(100+fx.speed)) ))
        call BuffNoST.Apply( fx.caster, Time * (1 - (fx.speed/(100+fx.speed)) ), 0 )
        call AnimationStart3(fx.caster,18, (100+fx.speed)/100)
        
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
            set angle = AngleWBP(MainUnit[pid],x,y)
            call SetUnitFacing(MainUnit[pid],angle)
            call EXSetUnitFacing(MainUnit[pid],angle)
            
            if DistanceWBP(MainUnit[pid],x,y) <= MaxRange then
                call IssuePointOrder( MainUnit[pid], "ambush", x, y )
            else
                call IssuePointOrder( MainUnit[pid], "ambush", GetWidgetX(MainUnit[pid]) + PolarX(MaxRange,angle), GetWidgetY(MainUnit[pid]) + PolarY(MaxRange,angle) )
            endif
            
        endif
        
        set p=null
    endfunction

            
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("MoE"),(false))
    call TriggerAddAction(t,function ESyncData)

    set t = null
//! runtextmacro 이벤트_끝()
endscope