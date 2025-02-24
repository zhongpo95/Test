scope HeroBandiA
    globals
        private constant real SD = 0.00
    
        //쉐클시간
        private constant real Time3 = 0.60
        //최대 전진거리
        private constant real MoveD = 600
        
        private constant real scale = 700
        private constant real distance = 500
    endglobals

    

    private function splashD takes nothing returns nothing
        local real Velue = 1.0
        local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
        local integer random
        
        if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
            if AngleTrue(AngleWBW(splash.source,GetEnumUnit()), GetUnitFacing(splash.source),  90 ) then
                if HeroDeal(splash.source,GetEnumUnit(),HeroSkillVelue4[15]*Velue,false,false,SD,true) then
                endif
            endif
        endif
    endfunction

    private function EffectFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        local SkillFx fx = t.data
        local integer i
        
        set fx.i = fx.i + 1
    
        if fx.i >= 20/fx.speed then
            if GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
                call UnitEffectTime2('e03G',GetWidgetX(fx.caster)+PolarX(50,GetUnitFacing(fx.caster)),GetWidgetY(fx.caster)+PolarY(50,GetUnitFacing(fx.caster)),GetUnitFacing(fx.caster),1.5,0,fx.pid)
                call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale, function splashD )
                call BanBisul2Plus( GetPlayerId(GetOwningPlayer(fx.caster)),1)
            endif
            call fx.Stop()
            call t.destroy()
        else
            call SetUnitSafePolarUTA(fx.caster,fx.r/(20/fx.speed),GetUnitFacing(fx.caster))
            call t.start( 0.02, false, function EffectFunction ) 
        endif
    endfunction

private function Main takes nothing returns nothing
    local tick t
    local SkillFx fx
    local real random
    local real r
    local effect e

    if GetSpellAbilityId() == 'A06C' then
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

        call Sound3D(fx.caster,'A05U')
        call Sound3D(fx.caster,'A05V')
        call Sound3D(fx.caster,'A06V')

        call DummyMagicleash(fx.caster, Time3/fx.speed)
        call AnimationStart3(fx.caster, 0, (100+fx.speed)/100)
        set t.data = fx
        call t.start( 0.02, false, function EffectFunction )
        call CooldownFIX(fx.caster, 'A06C', HeroSkillCD4[15])
    endif
endfunction
    
private function ASyncData takes nothing returns nothing
    local player p=(DzGetTriggerSyncPlayer())
    local string data=(DzGetTriggerSyncData())
    local integer pid=GetPlayerId(p)
    local integer dataLen=StringLength(data)
    local integer valueLen
    local real x
    local real y
    local real angle
    
    if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID4[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
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
            call IssuePointOrder( MainUnit[pid], "ancestralspirittarget", x, y )
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
    call DzTriggerRegisterSyncData(t,("BandiA"),(false))
    call TriggerAddAction(t,function ASyncData)

    set t = null
//! runtextmacro 이벤트_끝()
endscope

