scope HeroChenR

globals
    
    private constant real SD = 70
    
    //private constant real HeroSkillCD3[4] = 30.00
    
    //쉐클시간
    private constant real Time = 0.20
    private constant real Time2 = 0.20
    //스킬이펙트 시간
    private constant real EffectTime = 0.50
    
    private constant real scale = 500
    private constant real distance = 150

    private integer array Stack
endglobals

private struct FxEffect
    unit caster
    real TargetX
    real TargetY
    integer pid
    integer i
    real speed
    private method OnStop takes nothing returns nothing
        set caster = null
        set TargetX = 0
        set TargetY = 0
        set pid = 0
        set i = 0
        set speed = 0
    endmethod
    //! runtextmacro 연출()
endstruct

private function splashD1 takes nothing returns nothing
    local real Velue = 1.0
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer level = HeroSkillLevel[pid][3]
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        if level >= 1 then
            set Velue = Velue * 1.50
        endif
        
        call HeroDeal(splash.source,GetEnumUnit(),HeroSkillVelue3[4]*Velue,true,false,false,true)
    endif
endfunction
private function splashD2 takes nothing returns nothing
    local real Velue = 1.0
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer level = HeroSkillLevel[pid][3]
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        if level >= 1 then
            set Velue = Velue * 1.50
        endif
        
        if level >= 2 then
            set Velue = Velue * 1.30
        endif
        
        call HeroDeal(splash.source,GetEnumUnit(),HeroSkillVelue3[4]*Velue,true,false,false,true)
    endif
endfunction
private function splashD3 takes nothing returns nothing
    local real Velue = 1.0
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer level = HeroSkillLevel[pid][3]
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        if level >= 1 then
            set Velue = Velue * 1.50
        endif
        
        if level >= 2 then
            set Velue = Velue * 1.60
        endif
        
        call HeroDeal(splash.source,GetEnumUnit(),HeroSkillVelue3[4]*Velue,true,false,false,true)
    endif
endfunction
private function splashD4 takes nothing returns nothing
    local real Velue = 1.0
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer level = HeroSkillLevel[pid][3]
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        if level >= 1 then
            set Velue = Velue * 1.50
        endif
        
        if level >= 2 then
            set Velue = Velue * 1.90
        endif
        
        if level >= 3 then
            set Velue = Velue * 2.22
        endif
        
        call HeroDeal(splash.source,GetEnumUnit(),HeroSkillVelue3[4]*Velue,true,false,false,true)
    endif
endfunction

private function EffectFunction2 takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data
    local string data
    local integer random
    
    set fx.i = fx.i + 1
        
    if fx.caster != null and IsUnitDeadVJ(fx.caster) == false then
        if fx.i == 1 then
            call AnimationStart3(fx.caster,17, fx.speed)
            call UnitEffectTime2('e00R',GetWidgetX(fx.caster)+PolarX( 50, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster) +PolarY( 50, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.4,1,fx.pid)
            call Sound3D(fx.caster,'A01H')
        endif
        if Stack[fx.pid] == 11 then
            if fx.i < 10 then
                call SetUnitSafePolarUTA(fx.caster,35,GetUnitFacing(fx.caster))
                call DummyMagicleash(fx.caster, (Time / 10) /fx.speed)
                call BuffNoST.Apply( fx.caster, (Time / 10) /fx.speed, 0 )
                call t.start( (Time / 10) /fx.speed , false, function EffectFunction2 )
            elseif fx.i == 10 then
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
                call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 100, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 100, GetUnitFacing(fx.caster) ), scale, function splashD1 )
                call UnitEffectTime2('e00S',GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster) +PolarY( 75, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.4,1,fx.pid)
                call DummyMagicleash(fx.caster, Time2 /fx.speed)
                call BuffNoST.Apply( fx.caster, Time2 /fx.speed, 0 )
                call CastingBarShow(Player(fx.pid),false)
                set Stack[fx.pid] = 0
                call fx.Stop()
                call t.destroy()
            endif
        elseif Stack[fx.pid] == 12 then
            if fx.i < 10 then
                call SetUnitSafePolarUTA(fx.caster,35,GetUnitFacing(fx.caster))
                call DummyMagicleash(fx.caster, (Time / 10) /fx.speed)
                call BuffNoST.Apply( fx.caster, (Time / 10) /fx.speed, 0 )
                call t.start( (Time / 10) /fx.speed , false, function EffectFunction2 )
            elseif fx.i == 10 then
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
                call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 100, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 100, GetUnitFacing(fx.caster) ), scale, function splashD2 )
                call UnitEffectTime2('e00S',GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster) +PolarY( 75, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.4,1,fx.pid)
                call DummyMagicleash(fx.caster, Time2 /fx.speed)
                call BuffNoST.Apply( fx.caster, Time2 /fx.speed, 0 )
                call CastingBarShow(Player(fx.pid),false)
                set Stack[fx.pid] = 0
                call fx.Stop()
                call t.destroy()
            endif
        elseif Stack[fx.pid] == 13 then
            if fx.i < 10 then
                call SetUnitSafePolarUTA(fx.caster,35,GetUnitFacing(fx.caster))
                call DummyMagicleash(fx.caster, (Time / 10) /fx.speed)
                call BuffNoST.Apply( fx.caster, (Time / 10) /fx.speed, 0 )
                call t.start( (Time / 10) /fx.speed , false, function EffectFunction2 )
            elseif fx.i == 10 then
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
                call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 100, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 100, GetUnitFacing(fx.caster) ), scale, function splashD3 )
                call UnitEffectTime2('e00S',GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster) +PolarY( 75, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.4,1,fx.pid)
                call DummyMagicleash(fx.caster, Time2 /fx.speed)
                call BuffNoST.Apply( fx.caster, Time2 /fx.speed, 0 )
                call CastingBarShow(Player(fx.pid),false)
                set Stack[fx.pid] = 0
                call fx.Stop()
                call t.destroy()
            endif
        elseif Stack[fx.pid] == 14 then
            if fx.i < 10 then
                call SetUnitSafePolarUTA(fx.caster,35,GetUnitFacing(fx.caster))
                call DummyMagicleash(fx.caster, (Time / 10) /fx.speed)
                call BuffNoST.Apply( fx.caster, (Time / 10) /fx.speed, 0 )
                call t.start( (Time / 10) /fx.speed , false, function EffectFunction2 )
            elseif fx.i == 10 then
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 20 )
                call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 100, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 100, GetUnitFacing(fx.caster) ), scale, function splashD4 )
                call UnitEffectTime2('e00T',GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster) +PolarY( 75, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.4,1,fx.pid)
                call DummyMagicleash(fx.caster, Time2 /fx.speed)
                call BuffNoST.Apply( fx.caster, Time2 /fx.speed, 0 )
                call CastingBarShow(Player(fx.pid),false)
                set Stack[fx.pid] = 0
                call fx.Stop()
                call t.destroy()
            endif
        endif
    else
        call CastingBarShow(Player(fx.pid),false)
        set Stack[fx.pid] = 0
        call fx.Stop()
        call t.destroy()
    endif
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data
    local string data
    local effect e
    
    set fx.i = fx.i + 1
    
    if fx.caster != null and IsUnitDeadVJ(fx.caster) == false and GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
        if Stack[fx.pid] == 1 or Stack[fx.pid] == 2 or Stack[fx.pid] == 3 or Stack[fx.pid] == 4 then
            set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
            call DzSyncData(("ChenRM"),data)
            if fx.i < 25 then
                if Player(fx.pid) == GetLocalPlayer() then
                    call DzFrameSetValue(CastingBar, fx.i)
                endif
                call DummyMagicleash(fx.caster, (EffectTime /fx.speed )/25)
                call BuffNoST.Apply( fx.caster, (EffectTime /fx.speed )/25, 0 )
                call t.start( (EffectTime /fx.speed )/25, false, function EffectFunction )
            elseif fx.i == 25 then
                set Stack[fx.pid] = 2
                if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                    set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                else
                    set e = AddSpecialEffectTarget("Effect_Invisibility_Target_Wave_Red2.mdl",fx.caster,"hand left")
                endif
                call DestroyEffect(e)
                if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                    set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                else
                    set e = AddSpecialEffectTarget("Effect_Invisibility_Target_Wave_Red2.mdl",fx.caster,"hand left")
                endif
                call DestroyEffect(e)
                set e = null
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
                if Player(fx.pid) == GetLocalPlayer() then
                    call DzFrameSetValue(CastingBar, fx.i)
                endif
                call DummyMagicleash(fx.caster, (EffectTime /fx.speed )/25 * 2)
                call BuffNoST.Apply( fx.caster, (EffectTime /fx.speed )/25 * 2, 0 )
                call t.start( (EffectTime /fx.speed )/25 * 2, false, function EffectFunction )
                set fx.i = fx.i + 1
            elseif fx.i < 50 then
                if Player(fx.pid) == GetLocalPlayer() then
                    call DzFrameSetValue(CastingBar, fx.i - 25)
                endif
                call DummyMagicleash(fx.caster, (EffectTime /fx.speed )/25)
                call BuffNoST.Apply( fx.caster, (EffectTime /fx.speed )/25, 0 )
                call t.start( (EffectTime /fx.speed )/25, false, function EffectFunction )
            elseif fx.i == 50 then
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
                set Stack[fx.pid] = 3
                if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                    set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                else
                    set e = AddSpecialEffectTarget("Effect_Invisibility_Target_Wave_Red2.mdl",fx.caster,"hand left")
                endif
                call DestroyEffect(e)
                if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                    set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                else
                    set e = AddSpecialEffectTarget("Effect_Invisibility_Target_Wave_Red2.mdl",fx.caster,"hand left")
                endif
                call DestroyEffect(e)
                set e = null
                if Player(fx.pid) == GetLocalPlayer() then
                    call DzFrameSetValue(CastingBar, fx.i - 25)
                endif
                call DummyMagicleash(fx.caster, (EffectTime /fx.speed )/25 * 2)
                call BuffNoST.Apply( fx.caster, (EffectTime /fx.speed )/25 * 2, 0 )
                call t.start( (EffectTime /fx.speed )/25 * 2, false, function EffectFunction )
                set fx.i = fx.i + 1
            elseif fx.i < 75 then
                if Player(fx.pid) == GetLocalPlayer() then
                    call DzFrameSetValue(CastingBar, fx.i - 50)
                endif
                call DummyMagicleash(fx.caster, (EffectTime /fx.speed )/25)
                call BuffNoST.Apply( fx.caster, (EffectTime /fx.speed )/25, 0 )
                call t.start( (EffectTime /fx.speed )/25, false, function EffectFunction )
            elseif fx.i == 75 then
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
                set Stack[fx.pid] = 4
                if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                    set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                else
                    set e = AddSpecialEffectTarget("Effect_Invisibility_Target_Wave_Red2.mdl",fx.caster,"hand left")
                endif
                call DestroyEffect(e)
                if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                    set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                else
                    set e = AddSpecialEffectTarget("Effect_Invisibility_Target_Wave_Red2.mdl",fx.caster,"hand left")
                endif
                call DestroyEffect(e)
                set e = null
                if Player(fx.pid) == GetLocalPlayer() then
                    call DzFrameSetValue(CastingBar, fx.i - 50)
                endif
                call DummyMagicleash(fx.caster, 0.3)
                call BuffNoST.Apply( fx.caster, 0.3, 0 )
                call t.start( 0.3, false, function EffectFunction )
            elseif fx.i == 76 then
                if Stack[fx.pid] == 4 then
                    set fx.i = 0
                    set Stack[fx.pid] = 14
                    call DummyMagicleash(fx.caster,0.02)
                    call BuffNoST.Apply( fx.caster,0.02, 0 )
                    call t.start( 0.02, false, function EffectFunction2 )
                else
                    call fx.Stop()
                    call t.destroy()
                endif
            endif
        else
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
    if GetSpellAbilityId() == 'A01C' then
        set t = tick.create(0) 
        set fx = FxEffect.Create()
        set fx.caster = GetTriggerUnit()
        set fx.TargetX = GetSpellTargetX()
        set fx.TargetY = GetSpellTargetY()
        set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set fx.i = 0
        set fx.speed = ((100+SkillSpeed(fx.pid))/100)
        
        set fx.speed = fx.speed * Arcana_ChargeSpeed[fx.pid]
        
        call CooldownFIX(fx.caster,'A01C',HeroSkillCD3[4])
        call AnimationStart3(fx.caster,3, fx.speed)
        
        set t.data = fx
        set Stack[fx.pid] = 1
        call Sound3D(fx.caster,'A01O')
        if Player(fx.pid) == GetLocalPlayer() then
            call DzFrameSetText(CastingTextFrame,"적소·발도")
            call DzFrameSetValue(CastingBar,0)
            call CastingBarShow(Player(fx.pid),true)
        endif
        call DummyMagicleash(fx.caster, (EffectTime /fx.speed )/25)
        call BuffNoST.Apply( fx.caster, (EffectTime /fx.speed )/25, 0 )
        call t.start( (EffectTime /fx.speed )/25, false, function EffectFunction )
    endif
endfunction
    
private function RSyncData takes nothing returns nothing
    local player p=(DzGetTriggerSyncPlayer())
    local string data=(DzGetTriggerSyncData())
    local integer pid=GetPlayerId(p)
    local integer dataLen=StringLength(data)
    local integer valueLen
    local real x
    local real y
    local real angle
    
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

private function RSyncData2 takes nothing returns nothing
    local player p = DzGetTriggerSyncPlayer()
    local integer pid = GetPlayerId(p)
    local real x
    local real y
    local real angle
    local real speed
    local tick t
    local FxEffect fx
    
    if Stack[pid] == 0 then
    elseif Stack[pid] == 1 then
        set t = tick.create(0) 
        set fx = FxEffect.Create()
        set fx.pid = pid
        set fx.caster = MainUnit[fx.pid]
        set fx.i = 0
        set fx.speed = ((100+SkillSpeed(fx.pid))/100)
        set t.data = fx
        set Stack[fx.pid] = 11
        call t.start( 0.02, false, function EffectFunction2 )
    elseif Stack[pid] == 2 then
        set t = tick.create(0) 
        set fx = FxEffect.Create()
        set fx.pid = pid
        set fx.caster = MainUnit[fx.pid]
        set fx.i = 0
        set fx.speed = ((100+SkillSpeed(fx.pid))/100)
        set t.data = fx
        set Stack[fx.pid] = 12
        call t.start( 0.02, false, function EffectFunction2 )
    elseif Stack[pid] == 3 then
        set t = tick.create(0) 
        set fx = FxEffect.Create()
        set fx.pid = pid
        set fx.caster = MainUnit[fx.pid]
        set fx.i = 0
        set fx.speed = ((100+SkillSpeed(fx.pid))/100)
        set t.data = fx
        set Stack[fx.pid] = 13
        call t.start( 0.02, false, function EffectFunction2 )
    elseif Stack[pid] == 4 then
        set t = tick.create(0) 
        set fx = FxEffect.Create()
        set fx.pid = pid
        set fx.caster = MainUnit[fx.pid]
        set fx.i = 0
        set fx.speed = ((100+SkillSpeed(fx.pid))/100)
        set t.data = fx
        set Stack[fx.pid] = 14
        call t.start( 0.02, false, function EffectFunction2 )
    endif
    
    set p=null
endfunction

private function RSyncData3 takes nothing returns nothing
    local player p=(DzGetTriggerSyncPlayer())
    local string data=(DzGetTriggerSyncData())
    local integer pid=GetPlayerId(p)
    local integer dataLen=StringLength(data)
    local integer valueLen
    local real x
    local real y
    local real angle
    
    set x=S2R(data)
    set valueLen=StringLength(R2S(x))
    set data=SubString(data,valueLen+1,dataLen)
    set dataLen=dataLen-(valueLen+1)
    set y=S2R(data)
    set pid=GetPlayerId(p)
    set angle = AngleWBP(MainUnit[pid],x,y)
        
    if Stack[pid] == 1 or Stack[pid] == 2 or Stack[pid] == 3 then
        call SetUnitFacing(MainUnit[pid],angle)
        call EXSetUnitFacing(MainUnit[pid],angle)
    endif
    
    set p=null
endfunction
            
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("ChenR"),(false))
    call TriggerAddAction(t,function RSyncData)
    
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("ChenR2"),(false))
    call TriggerAddAction(t,function RSyncData2)
    
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("ChenRM"),(false))
    call TriggerAddAction(t,function RSyncData3)

    set t = null
//! runtextmacro 이벤트_끝()
endscope

