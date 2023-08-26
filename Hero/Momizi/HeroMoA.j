//! runtextmacro 콘텐츠("HeroMoA")

globals
    private constant real DR = 10.0 * 0.10
    private constant real SD = 40 * 0.10
    
    private constant real CoolTime = 20.0
    //쉐클시간
    private constant real Time = 0.90
    //스킬이펙트 시간
    private constant real Time2 = 0.30
    //이동타이머
    private constant real Time5 = 0.06
    //이동거리
    private constant real Dist = 300

    private constant real scale = 500
    private constant real distance = 250
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
    local integer level = HeroSkillLevel[pid][4]
    local real velue = 1.0
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        if level >= 2 then
            if BuffMomiz01.Exists( splash.source ) then
                set velue = velue * 1.95
            endif
            if level >= 3 then
                set velue = velue * 2.05
                call HeroDeal(splash.source,GetEnumUnit(),DR*velue,false,false,SD,false)
            else
                call HeroDeal(splash.source,GetEnumUnit(),DR*velue,false,false,SD,false)
            endif
        else
            call HeroDeal(splash.source,GetEnumUnit(),DR*velue,false,false,SD,false)
        endif
    endif
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data
    local tick t2
    local FxEffect fx2

    set fx.i = fx.i + 1
    

    if fx.i == 1 then
        set fx.dummy = UnitEffectTime2('e019', GetUnitX(fx.caster), GetUnitY(fx.caster), GetUnitFacing(fx.caster),0.9,1)
        set fx.dummy2 = UnitEffectTime2('e019', GetUnitX(fx.caster), GetUnitY(fx.caster), GetUnitFacing(fx.caster),0.9,1)
    endif
    
    call UnitAddAbility(fx.caster,'Arav')
    call UnitRemoveAbility(fx.caster,'Arav')
    call UnitAddAbility(fx.dummy,'Arav')
    call UnitRemoveAbility(fx.dummy,'Arav')
    call UnitAddAbility(fx.dummy2,'Arav')
    call UnitRemoveAbility(fx.dummy2,'Arav')
    
    if fx.i != 10 then
        if fx.i < 5 then
            //call SetUnitFlyHeight(fx.caster, fx.i * 40  ,0)
            call SetUnitHeight(fx.caster, fx.i * 40 )
            call SetUnitFlyHeight(fx.dummy, 200+(fx.i * 40)  ,0)
            call SetUnitFlyHeight(fx.dummy2, 200+(fx.i * 40)  ,0)
        elseif fx.i == 5 then
            //call SetUnitFlyHeight(fx.caster, 5 * 40  ,0)
            call SetUnitHeight(fx.caster, 5 * 40 )
            call SetUnitFlyHeight(fx.dummy, 200+(5 * 40)  ,0)
            call SetUnitFlyHeight(fx.dummy2, 200+(5 * 40)  ,0)
        else
            //call SetUnitFlyHeight(fx.caster, (10 - fx.i) * 40  ,0)
            call SetUnitHeight(fx.caster, (10 - fx.i) * 40 )
            call SetUnitFlyHeight(fx.dummy, 200+((10 - fx.i) * 40)  ,0)
            call SetUnitFlyHeight(fx.dummy2, 200+((10 - fx.i) * 40)  ,0)
        endif
        call SetUnitSafePolarUTA(fx.caster,Dist/10,GetUnitFacing(fx.caster))
        call SetUnitX(fx.dummy,GetUnitX(fx.caster))
        call SetUnitY(fx.dummy,GetUnitY(fx.caster))
        call SetUnitX(fx.dummy2,GetUnitX(fx.caster))
        call SetUnitY(fx.dummy2,GetUnitY(fx.caster))
        call splash.range( splash.ENEMY, fx.caster, GetUnitX(fx.caster), GetUnitY(fx.caster), scale, function splashD )
        call t.start( Time5 * (1 - (fx.speed/(100+fx.speed)) ), false, function EffectFunction )
    else
        //call SetUnitFlyHeight(fx.caster, 0  ,0)
        call SetUnitSafePolarUTA(fx.caster,Dist/10,GetUnitFacing(fx.caster))
        call SetUnitX(fx.dummy,GetUnitX(fx.caster))
        call SetUnitY(fx.dummy,GetUnitY(fx.caster))
        call SetUnitX(fx.dummy2,GetUnitX(fx.caster))
        call SetUnitY(fx.dummy2,GetUnitY(fx.caster))
        
        call splash.range( splash.ENEMY, fx.caster, GetUnitX(fx.caster), GetUnitY(fx.caster), scale, function splashD )
        
        if BuffMomiz01.Exists( fx.caster ) then
            call BuffMomiz01.Stop( fx.caster )
        endif
        
        call fx.Stop()
        call t.destroy()
    endif
endfunction

private function Main takes nothing returns nothing
    local real speed
    local tick t
    local FxEffect fx
    if GetSpellAbilityId() == 'A012' then
        set t = tick.create(0) 
        set fx = FxEffect.Create()
        set fx.caster = GetTriggerUnit()
        set fx.TargetX = GetSpellTargetX()
        set fx.TargetY = GetSpellTargetY()
        set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        if HeroSkillLevel[fx.pid][4] >= 1 then
            set fx.speed = SkillSpeed2(fx.pid, 18.0)
        else
            set fx.speed = SkillSpeed(fx.pid)
        endif
        set fx.speed = SkillSpeed(fx.pid)
        set fx.i = 0
        
        call Sound3D(fx.caster,'A01Z')
        call CooldownFIX(fx.caster,'A012',CoolTime)
        call DummyMagicleash(fx.caster, Time * (1 - (fx.speed/(100+fx.speed)) ))
        call BuffNoST.Apply( fx.caster, Time * (1 - (fx.speed/(100+fx.speed)) ), 0 )
        call BuffNoNB.Apply( fx.caster, Time * (1 - (fx.speed/(100+fx.speed)) ), 0 )
        call AnimationStart3(fx.caster,14, (100+fx.speed)/100)
        
        set t.data = fx
        call t.start( Time2 * (1 - (fx.speed/(100+fx.speed)) ), false, function EffectFunction ) 
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
            set angle = Angle.WBP(MainUnit[pid],x,y)
            call SetUnitFacing(MainUnit[pid],angle)
            call EXSetUnitFacing(MainUnit[pid],angle)
            call IssuePointOrder( MainUnit[pid], "ancestralspirittarget", x, y )
        endif
        
        set p=null
    endfunction

            
//! runtextmacro 이벤트_맵이_로딩되면_발동()
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("MoA"),(false))
    call TriggerAddAction(t,function ASyncData)

    set t = null
//! runtextmacro 이벤트_끝()
//! runtextmacro 콘텐츠_끝()

