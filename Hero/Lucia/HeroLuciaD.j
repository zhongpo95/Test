scope HeroLuciaD
globals
    private constant real SD = 0.00

    private constant real Time1 = 0.8
    private constant real Time2 = 0.6
    private constant real Time3 = 1.0
    private constant real Time4 = 3.0

    private constant real Time5 = 0.6
    //최대 전진거리
    private constant real MoveD = 1000
    
    private constant real scale = 500
    private constant real distance = 400
endglobals


private function splashD takes nothing returns nothing
    local real Velue = 1.0
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer random
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        if HeroDeal('A02I',splash.source,GetEnumUnit(),HeroSkillVelue0[14]*Velue,false,false,true,false) then
            if HeroSkillLevel[pid][0] >= 2 then
                call NarNabiPlus(pid,6)
            endif
        endif
        //call UnitEffectTimeEX2('e02I',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),GetRandomReal(0,360),1.2,pid)
        set random = GetRandomInt(0,2)
        if random == 0 then
            call Sound3D(GetEnumUnit(),'A03X')
        elseif random == 1 then
            call Sound3D(GetEnumUnit(),'A03Y')
        elseif random == 2 then
            call Sound3D(GetEnumUnit(),'A05N')
        endif
    endif
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillFx fx = t.data
    local real random
    local integer i
    local effect e
    
    set fx.i = fx.i + 1

    if GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
        if fx.i == 1 then
            call UnitAddAbility(fx.caster,'Arav')
            call UnitRemoveAbility(fx.caster,'Arav')
            call SetUnitFlyHeight(fx.caster, GetUnitFlyHeight(fx.caster) + 500, 0)

            call SetUnitSafeXY(fx.caster, GetWidgetX(fx.caster) + PolarX( 450, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) + PolarY( 450, GetUnitFacing(fx.caster) ) )

            call SetUnitFacing(fx.caster, fx.r - 180)
            call EXSetUnitFacing(fx.caster, fx.r - 180)

            call AnimationStart2(fx.caster, 22, Time1 / fx.speed, 0.1)
            call Sound3D(fx.caster,'A07L')
            call t.start( Time1 / fx.speed, false, function EffectFunction )
        elseif fx.i == 2 then
            call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 5 )
            call UnitEffectTime2('e057',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetUnitFacing(fx.caster),0.5,0,fx.pid)
            //call SetUnitSafeXY(fx.caster, GetWidgetX(fx.caster) + PolarX( 300, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) + PolarY( 300, GetUnitFacing(fx.caster) ) )

            call UnitAddAbility(fx.caster,'Arav')
            call UnitRemoveAbility(fx.caster,'Arav')
            call SetUnitFlyHeight(fx.caster, GetUnitFlyHeight(fx.caster) - 500, 0)

            if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                set e = AddSpecialEffect(".mdl", GetWidgetX(fx.caster), GetWidgetY(fx.caster) )
            else
                set e = AddSpecialEffect("ZK_BM_Mine blasting.mdl", GetWidgetX(fx.caster)+ PolarX( -50, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster)+ PolarY( -50, GetUnitFacing(fx.caster) ))
            endif
            call EXSetEffectSize(e,0.5)
            call DestroyEffect(e)

            call AnimationStart3(fx.caster, 22, fx.speed)
            call t.start( Time2 / fx.speed, false, function EffectFunction )
        elseif fx.i == 3 then
            call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 20 )
            if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                set e = AddSpecialEffect(".mdl", GetWidgetX(fx.caster), GetWidgetY(fx.caster) )
            else
                set e = AddSpecialEffect("ZK_BM_Mine blasting.mdl", GetWidgetX(fx.caster), GetWidgetY(fx.caster))
            endif
            call EXEffectMatRotateZ(e,GetRandomReal(0,360))
            call DestroyEffect(e)

            call fx.Stop()
            call t.destroy()
        endif
    else
        call fx.Stop()
        call t.destroy()
    endif
endfunction

private function Main takes nothing returns nothing
    local tick t
    local SkillFx fx
    local real random
    local real r
    local effect e
         
    if GetSpellAbilityId() == 'A07G' then
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
        set fx.r = GetUnitFacing(fx.caster)

        call Overlay2Count(fx.pid,'A07G')

        /*
        if EffectOff[GetPlayerId(GetLocalPlayer())] == false and fx.pid != GetPlayerId(GetLocalPlayer()) then
            set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        else
            set e = AddSpecialEffect("nitu.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        endif

        call EXEffectMatRotateZ(e,AngleWBP(fx.caster,fx.TargetX,fx.TargetY))
        call DestroyEffect(e)
        set e = null
        call Sound3D(fx.caster,'A03V')
        */

        if not IsUnitDeadVJ(LuciaD[fx.pid]) then
            call KillUnit(LuciaD[fx.pid])
        endif

        //F사용가능
        if not IsUnitDeadVJ(LuciaF[fx.pid]) then
            call KillUnit(LuciaF[fx.pid])
        endif
        set LuciaF[fx.pid] = CreateUnit(GetOwningPlayer(fx.caster),'e05K',0,0,0)

        call Sound3D(fx.caster,'A07K')

        call DummyMagicleash(fx.caster, Time4 / fx.speed)
        call AnimationStart3(fx.caster, 6, fx.speed)
        set t.data = fx
        call t.start( Time3 / fx.speed, false, function EffectFunction )

        call CooldownFIX(fx.caster, 'A07G', 4)
    endif
endfunction

private function DSyncData takes nothing returns nothing
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
        call IssuePointOrder( MainUnit[pid], "antimagicshell", x, y )
    endif

    set p=null
endfunction

private function DSyncData2 takes nothing returns nothing
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
    call DzTriggerRegisterSyncData(t,("LuciaD"),(false))
    call TriggerAddAction(t,function DSyncData)
    
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("LuciaD2"),(false))
    call TriggerAddAction(t,function DSyncData2)

    set t = null
//! runtextmacro 이벤트_끝()
endscope

