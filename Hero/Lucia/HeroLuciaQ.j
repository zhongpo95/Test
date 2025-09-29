scope HeroLuciaQ
globals
    private constant real SD = 0.00

    private constant real StopTime = 1.000
    private constant real Time1 = 0.200
    private constant real Time2 = 0.600

    private constant real MoveD = 300

    
    private constant real scale = 400
    private constant real distance = 300
endglobals


private function splashD takes nothing returns nothing
    local real Velue = 1.0
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer random
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        call HeroDeal('A07B',splash.source,GetEnumUnit(),HeroSkillVelue0[17]*Velue,false,false,true,false)
        //call UnitEffectTimeEX2('e02I',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),GetRandomReal(0,360),1.2,pid)
    endif
endfunction

private function splashD2 takes nothing returns nothing
    local real Velue = 1.0
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer random
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        call HeroDeal('A07B',splash.source,GetEnumUnit(),HeroSkillVelue0[17]*Velue,false,false,false,false)
        //call UnitEffectTimeEX2('e02I',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),GetRandomReal(0,360),1.2,pid)
    endif
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillFx fx = t.data
    local real random
    local integer i

    set fx.r = fx.r + 0.03125

    if GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
        if fx.r >= Time1/fx.speed and fx.i == 0 then
            call Sound3D(fx.caster,'A07M')
            set fx.i = 1
            call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 5 )
            call UnitEffectTimeEX2('e04S',GetWidgetX(fx.caster)+PolarX( 25, GetUnitFacing(fx.caster))+PolarX( 50, GetUnitFacing(fx.caster) - 90 ),GetWidgetY(fx.caster)+PolarY( 50, GetUnitFacing(fx.caster) - 90 )+PolarY( 25, GetUnitFacing(fx.caster)),GetUnitFacing(fx.caster),1.2,fx.pid)
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 25, GetUnitFacing(fx.caster))+PolarX( 50, GetUnitFacing(fx.caster) - 90 ), GetWidgetY(fx.caster)+PolarY( 50, GetUnitFacing(fx.caster) - 90 )+PolarY( 25, GetUnitFacing(fx.caster)), scale, function splashD )
            call t.start( 0.03125, false, function EffectFunction ) 
        elseif fx.r >= Time2/fx.speed and fx.i == 1 then
            set fx.i = 2
            call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 5 )
            call UnitEffectTimeEX2('e04T',GetWidgetX(fx.caster)+PolarX( 25, GetUnitFacing(fx.caster)),GetWidgetY(fx.caster)+PolarY( 25, GetUnitFacing(fx.caster)),GetUnitFacing(fx.caster),1.2,fx.pid)
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 25, GetUnitFacing(fx.caster)), GetWidgetY(fx.caster)+PolarY( 25, GetUnitFacing(fx.caster)), scale, function splashD2 )
            call fx.Stop()
            call t.destroy()
        elseif fx.r <= Time1/fx.speed then
            call SetUnitSafePolarUTA(fx.caster,MoveD/(6/fx.speed),GetUnitFacing(fx.caster))
            call t.start( 0.03125, false, function EffectFunction )
        else
            call t.start( 0.03125, false, function EffectFunction )
        endif
    endif

endfunction

private function Main takes nothing returns nothing
    local tick t
    local SkillFx fx
    local real random
    local real r
    local effect e
         
    if GetSpellAbilityId() == 'A07B' then
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
        set fx.r = 0
        set fx.i = 0

        call Overlay2Count(fx.pid,'A07B')
        call LuciaMuPlus(fx.pid, 40)
        
        set LuciaVelue[fx.pid] = LuciaVelue[fx.pid] + 8
        if LuciaVelue[fx.pid] >= 25 then
            set LuciaVelue[fx.pid] = 25
        endif
        if Player(fx.pid) == GetLocalPlayer() then
            if LuciaForm[fx.pid] == 0 then
                call DzFrameSetValue(LuciaAden, LuciaVelue[fx.pid])
            endif
        endif

        if EffectOff[GetPlayerId(GetLocalPlayer())] == false and fx.pid != GetPlayerId(GetLocalPlayer()) then
            set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        else
            set e = AddSpecialEffect("nitu.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        endif
        
        call EXEffectMatRotateZ(e,AngleWBP(fx.caster,fx.TargetX,fx.TargetY))
        call DestroyEffect(e)
        set e = null

        call DummyMagicleash(fx.caster, StopTime/fx.speed)
        call AnimationStart3(fx.caster, 5, fx.speed)
        set t.data = fx
        call t.start( 0.03125, false, function EffectFunction )

        //call CooldownFIX(fx.caster, 'A07B', HeroSkillCD0[17])
        call CooldownFIX(fx.caster, 'A07B', 1.5)
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
    
    if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID0[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
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

    set p=null
endfunction

private function QSyncData2 takes nothing returns nothing
    local player p = DzGetTriggerSyncPlayer()
    local integer pid = GetPlayerId(p)
    local real x
    local real y
    local real angle
    local real speed
    local tick t
    
    set p=null
endfunction

            
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("LuciaQ"),(false))
    call TriggerAddAction(t,function QSyncData)
    
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("LuciaQ2"),(false))
    call TriggerAddAction(t,function QSyncData2)

    set t = null
//! runtextmacro 이벤트_끝()
endscope

