scope HeroMoW

globals
    private constant real SD = 30
    //쉐클시간
    private constant real Time = 0.80
    //스킬이펙트 시간
    private constant real Time2 = 0.25
    //발도버프 지속 시간
    private constant real Time3 = 3.0
    //이동타이머
    private constant real Time5 = 0.12
    //이동거리
    private constant real Dist = 250

    private constant real scale = 500
    private constant real distance = 250
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
    local integer level = HeroSkillLevel[pid][1]
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        if level >= 2 then
            if level >= 3 then
                set Penetration[pid] = 0.8
                call HeroDeal(splash.source,GetEnumUnit(),HeroSkillVelue1[3]*1.45,false,false,false,false)
                set Penetration[pid] = 0
            else
                call HeroDeal(splash.source,GetEnumUnit(),HeroSkillVelue1[3]*1.45,false,false,false,false)
            endif
        else
            call HeroDeal(splash.source,GetEnumUnit(),HeroSkillVelue1[3],false,false,false,false)
        endif
    endif
    
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data
    local tick t2
    local FxEffect fx2

    set fx.i = fx.i + 1
    
    if GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
        if fx.i == 1 then
            set fx.dummy = UnitEffectTime2('e012',GetWidgetX(fx.caster)+PolarX( -100, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster)+PolarY( -100, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),3.0,1,GetPlayerId(GetOwningPlayer(fx.caster)))
        endif
        
        if fx.i != 5 then
            if HeroSkillLevel[fx.pid][1] >= 2 then
                call SetUnitSafePolarUTA(fx.caster,Dist/5,GetUnitFacing(fx.caster))
                call SetUnitX(fx.dummy,GetWidgetX(fx.caster))
                call SetUnitY(fx.dummy,GetWidgetY(fx.caster))
            endif
            call t.start( Time5 * (1 - (fx.speed/(100+fx.speed)) )/5, false, function EffectFunction )
        else
            if HeroSkillLevel[fx.pid][1] >= 2 then
                call SetUnitSafePolarUTA(fx.caster,Dist/5,GetUnitFacing(fx.caster))
                call SetUnitX(fx.dummy,GetWidgetX(fx.caster))
                call SetUnitY(fx.dummy,GetWidgetY(fx.caster))
            endif
            
            call UnitEffectTime2('e011',GetWidgetX(fx.caster)+PolarX( 100, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 100, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),1.5,1,fx.pid)
            
            if splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 100, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 100, GetUnitFacing(fx.caster) ), scale, function splashD ) != 0 then
                //발도버프
                if HeroSkillLevel[fx.pid][1] >= 1 then
                    call BuffMomiz01.Apply( fx.caster, Time3, 0 )
                endif
            endif
            
            call fx.Stop()
            call t.destroy()
        endif
    else
        call fx.Stop()
        call t.destroy()
    endif
endfunction

private function Main takes nothing returns nothing
    local real speed
    local tick t
    local FxEffect fx
    if GetSpellAbilityId() == 'A00Z' then
        set t = tick.create(0) 
        set fx = FxEffect.Create()
        set fx.caster = GetTriggerUnit()
        set fx.TargetX = GetSpellTargetX()
        set fx.TargetY = GetSpellTargetY()
        set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set fx.speed = SkillSpeed(fx.pid)
        set fx.i = 0
        
        call Sound3D(fx.caster,'A022')
        call CooldownFIX(fx.caster,'A00Z',HeroSkillCD1[3])
        call DummyMagicleash(fx.caster,Time * (1 - (fx.speed/(100+fx.speed)) ))
        call BuffNoST.Apply( fx.caster, Time * (1 - (fx.speed/(100+fx.speed)) ), 0 )
        call AnimationStart3(fx.caster,18, fx.speed)
        
        set t.data = fx
        call t.start( Time2 * (1 - (fx.speed/(100+fx.speed)) ), false, function EffectFunction ) 
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
        set angle = AngleWBP(MainUnit[pid],x,y)
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
    call DzTriggerRegisterSyncData(t,("MoW"),(false))
    call TriggerAddAction(t,function WSyncData)

    set t = null
//! runtextmacro 이벤트_끝()

endscope