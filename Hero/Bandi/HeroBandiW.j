scope HeroBandiW
globals
    private constant real SD = 0.00

    //전진시간
    private constant real Time3 = 0.40
    //최대 전진거리
    private constant real MoveD = 1000
    
    private constant real scale = 500
    private constant real distance = 150
endglobals

//call BanBisulPlus(GetPlayerId(GetOwningPlayer(GetTriggerUnit())),1)

private function splashD takes nothing returns nothing
    local real Velue = 1.0
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer random
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        call HeroDeal(1,splash.source,GetEnumUnit(),HeroSkillVelue1[15]*Velue,false,false,false,false)
        call BanBisulPlus(pid,1)
    endif
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillFx fx = t.data
    local real random
    local integer i
    local real r = GetUnitFacing(fx.caster)
    set fx.i = fx.i + 1

    if fx.i >= 10/fx.speed then
        if GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
            call UnitEffectTime2('e03E', fx.TargetX2 + PolarX( (fx.r+25)/5 * 1 , r) , fx.TargetY2 + PolarY((fx.r+25)/5 * 1, r), GetUnitFacing(fx.caster),0.7,0,fx.pid)
            call splash.range( splash.ENEMY, fx.caster, fx.TargetX2 + PolarX( (fx.r+25)/5 * 1 , r) , fx.TargetY2 + PolarY((fx.r+25)/5 * 1, r), scale, function splashD )
            call UnitEffectTime2('e03E', fx.TargetX2 + PolarX( (fx.r+25)/5 * 2 , r) , fx.TargetY2 + PolarY((fx.r+25)/5 * 2, r), GetUnitFacing(fx.caster),0.7,0,fx.pid)
            call splash.range( splash.ENEMY, fx.caster, fx.TargetX2 + PolarX( (fx.r+25)/5 * 2 , r) , fx.TargetY2 + PolarY((fx.r+25)/5 * 2, r), scale, function splashD )
            call UnitEffectTime2('e03E', fx.TargetX2 + PolarX( (fx.r+25)/5 * 3 , r) , fx.TargetY2 + PolarY((fx.r+25)/5 * 3, r), GetUnitFacing(fx.caster),0.7,0,fx.pid)
            call splash.range( splash.ENEMY, fx.caster, fx.TargetX2 + PolarX( (fx.r+25)/5 * 3 , r) , fx.TargetY2 + PolarY((fx.r+25)/5 * 3, r), scale, function splashD )
            call UnitEffectTime2('e03E', fx.TargetX2 + PolarX( (fx.r+25)/5 * 4 , r) , fx.TargetY2 + PolarY((fx.r+25)/5 * 4, r), GetUnitFacing(fx.caster),0.7,0,fx.pid)
            call splash.range( splash.ENEMY, fx.caster, fx.TargetX2 + PolarX( (fx.r+25)/5 * 4 , r) , fx.TargetY2 + PolarY((fx.r+25)/5 * 4, r), scale, function splashD )
            call UnitEffectTime2('e03E', fx.TargetX2 + PolarX( (fx.r+25)/5 * 5 , r) , fx.TargetY2 + PolarY((fx.r+25)/5 * 5, r), GetUnitFacing(fx.caster),0.7,0,fx.pid)
            call splash.range( splash.ENEMY, fx.caster, fx.TargetX2 + PolarX( (fx.r+25)/5 * 5 , r) , fx.TargetY2 + PolarY((fx.r+25)/5 * 5, r), scale, function splashD )
        endif
        call Sound3D(fx.caster,'A03W')
        call fx.Stop()
        call t.destroy()
    else
        call SetUnitSafePolarUTA(fx.caster,fx.r/(10/fx.speed),GetUnitFacing(fx.caster))
        call t.start( 0.02, false, function EffectFunction ) 
    endif
endfunction

private function Main takes nothing returns nothing
    local tick t
    local SkillFx fx
    local real random
    local real r
    local effect e
    
    if GetSpellAbilityId() == 'A06L' then
        set t = tick.create(0)
        set fx = SkillFx.Create()
        set fx.caster = GetTriggerUnit()
        set fx.TargetX = GetSpellTargetX()
        set fx.TargetY = GetSpellTargetY()
        set fx.TargetX2 = GetUnitX(fx.caster)
        set fx.TargetY2 = GetUnitY(fx.caster)
        set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set fx.speed = ((100+SkillSpeed(fx.pid))/100)
        set fx.index = IndexUnit(MainUnit[fx.pid])
        set fx.i = 0
        set r = DistanceWBP(fx.caster, fx.TargetX, fx.TargetY )
        
        if r >= MoveD then
            set fx.r = MoveD
        else
            set fx.r = r
        endif

        if EffectOff[GetPlayerId(GetLocalPlayer())] == false and fx.pid != GetPlayerId(GetLocalPlayer()) then
            set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        else
            set e = AddSpecialEffect("nitu.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        endif
        call EXEffectMatRotateZ(e,AngleWBP(fx.caster,fx.TargetX,fx.TargetY))
        call DestroyEffect(e)
        set e = null
 
        call Sound3D(fx.caster,'A06T')
        
        call Overlay2Count(fx.pid,'A06L')


        call DummyMagicleash(fx.caster, Time3/fx.speed)
        call AnimationStart3(fx.caster, 2, fx.speed)
        set t.data = fx
        call t.start( 0.02, false, function EffectFunction )

        call CooldownFIX(fx.caster, 'A06L', HeroSkillCD1[15])
    endif
endfunction
    
private function WSyncData takes nothing returns nothing
    local player p=(DzGetTriggerSyncPlayer())
    local string data=(DzGetTriggerSyncData())
    local integer pid=GetPlayerId(p)
    local integer dataLen=StringLength(data)
    local integer valueLen
    local real x
    local real y
    local real angle

    if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and IsUnitPausedEx(MainUnit[pid]) == false and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID1[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
        if GetUnitAbilityLevel(MainUnit[pid],'A06N') < 1 then
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
    endif

    set p=null
endfunction

            
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("BandiW"),(false))
    call TriggerAddAction(t,function WSyncData)

    set t = null
//! runtextmacro 이벤트_끝()
endscope

