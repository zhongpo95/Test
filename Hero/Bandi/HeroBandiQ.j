scope HeroBandiQ
    globals
        private constant real SD = 0.00
    
        //쉐클시간
        private constant real Time3 = 0.60
        //최대 전진거리
        private constant real MoveD = 300
        
        private constant real scale = 500
        private constant real distance = 400
    endglobals

    private function splashD takes nothing returns nothing
        local real Velue = 1.0
        local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
        local integer random
        
        if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
            call HeroDeal(1,splash.source,GetEnumUnit(),HeroSkillVelue0[15]*Velue,false,false,true,false)
            call BanBisulPlus(pid,1)
            //call UnitEffectTimeEX2('e02I',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),GetRandomReal(0,360),1.2,pid)
        endif
    endfunction

    private function EffectFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        local SkillFx fx = t.data
        local integer i
        
        set fx.i = fx.i + 1
    
        if fx.i >= 20/fx.speed then
            if GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
                call UnitEffectTime2('e03D',GetWidgetX(fx.caster)+PolarX( 50, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster)+PolarY( 50, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.7,0,fx.pid)
                call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 75, GetUnitFacing(fx.caster) ), scale, function splashD )
            endif
            call fx.Stop()
            call t.destroy()
        else
            call SetUnitSafePolarUTA(fx.caster,fx.r/(20/fx.speed),GetUnitFacing(fx.caster))
            call t.start( 0.02, false, function EffectFunction ) 
        endif
    endfunction

//트포 비적중시에도 비술게이지 1 얻음
private function Main takes nothing returns nothing
    local tick t
    local SkillFx fx
    local real random
    local real r
    local effect e
         
    if GetSpellAbilityId() == 'A06H' then
        call SetUnitFacing(GetTriggerUnit(), AngleWBP(GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() ))
        call EXSetUnitFacing(GetTriggerUnit(), AngleWBP(GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() ))
        set t = tick.create(0)
        set fx = SkillFx.Create()
        set fx.caster = GetTriggerUnit()
        set fx.TargetX = GetSpellTargetX()
        set fx.TargetY = GetSpellTargetY()
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

        if GetRandomInt(0,1) == 1 then
            call Sound3D(fx.caster,'A06R')
        else
            call Sound3D(fx.caster,'A06S')
        endif

        call Overlay2Count(fx.pid,'A06H')


        call DummyMagicleash(fx.caster, Time3/fx.speed)
        call AnimationStart3(fx.caster, 2, fx.speed)
        set t.data = fx
        call t.start( 0.02, false, function EffectFunction )
        call CooldownFIX(fx.caster, 'A06H', HeroSkillCD0[15])
    endif
endfunction

private function QSyncData takes nothing returns nothing
    local player p=(DzGetTriggerSyncPlayer())
    local string data=(DzGetTriggerSyncData())
    local integer pid=GetPlayerId(p)
    local integer dataLen=StringLength(data)
    local integer valueLen
    local real x
    local real y
    local real angle

    if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and IsUnitPausedEx(MainUnit[pid]) == false and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID0[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
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
            call IssuePointOrder( MainUnit[pid], "acidbomb", x, y )
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
    call DzTriggerRegisterSyncData(t,("BandiQ"),(false))
    call TriggerAddAction(t,function QSyncData)

    set t = null
//! runtextmacro 이벤트_끝()
endscope

