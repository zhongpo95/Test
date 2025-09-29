scope HeroLuciaW
globals
    
    private constant real SD = 15.00
    private constant real SD2 = 35.00
    
    //private constant real HeroSkillCD7[4] = 30.00 // 30.0
    
    //쉐클시간
    private constant real Time = 0.30
    //스킬이펙트 시간
    private constant real EffectTime = 0.333
    
    private integer array Stack

    private constant real scale = 500
    private constant real distance = 250
    private constant real scale2 = 525
    private constant real distance2 = 300
    
    private constant real TICK = 16
    //범위체크
    private group CheckG
    //더미 유닛
    private unit CheckU
endglobals

private function splashD takes nothing returns nothing
    local real Velue = 1.0
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer level = HeroSkillLevel[pid][4]
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        if level >= 1 then
            set Velue = Velue * 2.00
        endif
        
        call HeroDeal('A01B',splash.source,GetEnumUnit(),HeroSkillVelue7[4]*Velue,true,false,false,true)
    endif
endfunction

private function EffectFunction2 takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillFx fx = t.data
    local real X
    local real Y
    
    set fx.i = fx.i + 1
    
    if fx.i == 1 then
        if fx.j == 0 then
            set fx.dummy = UnitEffectTimeEX2('e04V', GetWidgetX(fx.caster), GetWidgetY(fx.caster), GetUnitFacing(fx.caster),0.5,fx.pid)
            set fx.r =  GetUnitFacing(fx.caster)
        elseif fx.j == 1 then
            set fx.dummy = UnitEffectTimeEX2('e04W', GetWidgetX(fx.caster), GetWidgetY(fx.caster), GetUnitFacing(fx.caster),0.5,fx.pid)
            set fx.r =  GetUnitFacing(fx.caster)
        elseif fx.j == 2 then
            set fx.dummy = UnitEffectTimeEX2('e04X', GetWidgetX(fx.caster), GetWidgetY(fx.caster), GetUnitFacing(fx.caster),0.5,fx.pid)
            set fx.r =  GetUnitFacing(fx.caster)
        endif
        call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 2 )
    endif
    
    if fx.i != (TICK+1) then
        set X = GetWidgetX(fx.dummy)
        set Y = GetWidgetY(fx.dummy)
        call SetUnitX(fx.dummy, X + PolarX( 93.75, fx.r ))
        call SetUnitY(fx.dummy, Y + PolarY( 93.75, fx.r ))
        set CheckG = fx.ul.super
        set CheckU = fx.dummy
        call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.dummy), GetWidgetY(fx.dummy), scale, function splashD )
        set CheckU = null
        set CheckG = null
        call t.start( 0.03125, false, function EffectFunction2 )
    else
        call KillUnit(fx.dummy)
        call fx.ul.destroy()
        call fx.Stop()
        call t.destroy()
    endif

endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillFx fx = t.data
    local string data
    local effect e
    local tick t2
    local SkillFx fx2
    
    set fx.i = fx.i + 1
    
    if fx.caster != null and IsUnitDeadVJ(fx.caster) == false and GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
        if Stack[fx.pid] == 0 then
            if fx.i == 1 then
                call LuciaMuPlus(fx.pid, 20)
                if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                    set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                else
                    set e = AddSpecialEffect("0835.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                endif
                call EXEffectMatRotateZ(e,AngleWBP(fx.caster,GetSpellTargetX(),GetSpellTargetY()))
                call EXSetEffectSize(e,1.4)
                call EXSetEffectZ(e,70)
                call EXSetEffectSpeed(e,2)
                call EXEffectMatRotateX(e,60)
                call DestroyEffect(e)
        
                if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                    set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                else
                    set e = AddSpecialEffect("0413.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                endif
                call DestroyEffect(e)
        
                if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                    set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                else
                    set e = AddSpecialEffect("0561.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                endif
                call EXSetEffectSize(e,0.4)
                call DestroyEffect(e)
                if LuciaForm[fx.pid] == 0 then
                    //set LuciaForm[fx.pid] = 1
                    call AnimationStart3(fx.caster,27, fx.speed)
                else
                    //set LuciaForm[fx.pid] = 0
                    call AnimationStart3(fx.caster,4, fx.speed)
                endif
                set t2 = tick.create(0)
                set fx2 = SkillFx.Create()
                set fx2.ul = party.create()
                set fx2.caster = fx.caster
                set fx2.r =  GetUnitFacing(fx.caster)
                set fx2.pid = GetPlayerId(GetOwningPlayer(fx2.caster))
                set fx2.i = 0
                set fx2.j = 1
                set fx2.speed = ((100+SkillSpeed(fx2.pid))/100)
                set t2.data = fx2
                call t2.start( 0.03125, false, function EffectFunction2 ) 
                call DummyMagicleash(fx.caster, (EffectTime /fx.speed))
                call BuffNoST.Apply( fx.caster, (EffectTime /fx.speed), 0 )
                call t.start( (EffectTime /fx.speed), false, function EffectFunction )
            elseif fx.i == 2 then
                call LuciaMuPlus(fx.pid, 20)
                if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                    set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                else
                    set e = AddSpecialEffect("0835.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                endif
                call EXEffectMatRotateZ(e,AngleWBP(fx.caster,GetSpellTargetX(),GetSpellTargetY()))
                call EXSetEffectSize(e,1.4)
                call EXSetEffectZ(e,70)
                call EXSetEffectSpeed(e,2)
                call EXEffectMatRotateX(e,-60)
                call DestroyEffect(e)
        
                if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                    set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                else
                    set e = AddSpecialEffect("0413.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                endif
                call DestroyEffect(e)
        
                if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                    set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                else
                    set e = AddSpecialEffect("0561.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                endif
                call EXSetEffectSize(e,0.4)
                call DestroyEffect(e)
                set t2 = tick.create(0)
                set fx2 = SkillFx.Create()
                set fx2.ul = party.create()
                set fx2.caster = fx.caster
                set fx2.r =  GetUnitFacing(fx.caster)
                set fx2.pid = GetPlayerId(GetOwningPlayer(fx2.caster))
                set fx2.i = 0
                set fx2.j = 2
                set fx2.speed = ((100+SkillSpeed(fx2.pid))/100)
                set t2.data = fx2
                call t2.start( 0.03125, false, function EffectFunction2 ) 
                if LuciaForm[fx.pid] == 0 then
                    //set LuciaForm[fx.pid] = 1
                    call AnimationStart3(fx.caster,27, fx.speed)
                else
                    //set LuciaForm[fx.pid] = 0
                    call AnimationStart3(fx.caster,3, fx.speed)
                endif
                call DummyMagicleash(fx.caster, (EffectTime /fx.speed))
                call BuffNoST.Apply( fx.caster, (EffectTime /fx.speed), 0 )
                call t.start( (EffectTime /fx.speed), false, function EffectFunction )
            elseif fx.i == 3 then
                call LuciaMuPlus(fx.pid, 20)
                if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                    set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                else
                    set e = AddSpecialEffect("0835.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                endif
                call EXEffectMatRotateZ(e,AngleWBP(fx.caster,GetSpellTargetX(),GetSpellTargetY()))
                call EXSetEffectSize(e,1.4)
                call EXSetEffectZ(e,70)
                call EXSetEffectSpeed(e,2)
                call EXEffectMatRotateX(e,160)
                call DestroyEffect(e)
        
                if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                    set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                else
                    set e = AddSpecialEffect("0413.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                endif
                call DestroyEffect(e)
        
                if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                    set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                else
                    set e = AddSpecialEffect("0561.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                endif
                call EXSetEffectSize(e,0.4)
                call DestroyEffect(e)
                set t2 = tick.create(0)
                set fx2 = SkillFx.Create()
                set fx2.ul = party.create()
                set fx2.caster = fx.caster
                set fx2.r =  GetUnitFacing(fx.caster)
                set fx2.pid = GetPlayerId(GetOwningPlayer(fx2.caster))
                set fx2.i = 0
                set fx2.j = 0
                set fx2.speed = ((100+SkillSpeed(fx2.pid))/100)
                set t2.data = fx2
                call t2.start( 0.03125, false, function EffectFunction2 ) 
                if LuciaForm[fx.pid] == 0 then
                    //set LuciaForm[fx.pid] = 1
                    call AnimationStart3(fx.caster,27, fx.speed)
                else
                    //set LuciaForm[fx.pid] = 0
                    call AnimationStart3(fx.caster,4, fx.speed)
                endif
                call DummyMagicleash(fx.caster, (EffectTime /fx.speed))
                call BuffNoST.Apply( fx.caster, (EffectTime /fx.speed), 0 )
                call t.start( (EffectTime /fx.speed), false, function EffectFunction )
            elseif fx.i == 4 then
                call LuciaMuPlus(fx.pid, 20)
                if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                    set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                else
                    set e = AddSpecialEffect("0835.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                endif
                call EXEffectMatRotateZ(e,AngleWBP(fx.caster,GetSpellTargetX(),GetSpellTargetY()))
                call EXSetEffectSize(e,1.4)
                call EXSetEffectZ(e,70)
                call EXSetEffectSpeed(e,2)
                call EXEffectMatRotateX(e,60)
                call DestroyEffect(e)
        
                if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                    set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                else
                    set e = AddSpecialEffect("0413.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                endif
                call DestroyEffect(e)
        
                if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                    set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                else
                    set e = AddSpecialEffect("0561.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                endif
                call EXSetEffectSize(e,0.4)
                call DestroyEffect(e)
                set t2 = tick.create(0)
                set fx2 = SkillFx.Create()
                set fx2.ul = party.create()
                set fx2.caster = fx.caster
                set fx2.r =  GetUnitFacing(fx.caster)
                set fx2.pid = GetPlayerId(GetOwningPlayer(fx2.caster))
                set fx2.i = 0
                set fx2.j = 1
                set fx2.speed = ((100+SkillSpeed(fx2.pid))/100)
                set t2.data = fx2
                call t2.start( 0.03125, false, function EffectFunction2 ) 
                if LuciaForm[fx.pid] == 0 then
                    //set LuciaForm[fx.pid] = 1
                    call AnimationStart3(fx.caster,27, fx.speed)
                else
                    //set LuciaForm[fx.pid] = 0
                    call AnimationStart3(fx.caster,3, fx.speed)
                endif
                call DummyMagicleash(fx.caster, (EffectTime /fx.speed))
                call BuffNoST.Apply( fx.caster, (EffectTime /fx.speed), 0 )
                call t.start( (EffectTime /fx.speed), false, function EffectFunction )
            elseif fx.i == 5 then
                call LuciaMuPlus(fx.pid, 20)
                if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                    set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                else
                    set e = AddSpecialEffect("0835.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                endif
                call EXEffectMatRotateZ(e,AngleWBP(fx.caster,GetSpellTargetX(),GetSpellTargetY()))
                call EXSetEffectSize(e,1.4)
                call EXSetEffectZ(e,70)
                call EXSetEffectSpeed(e,2)
                call EXEffectMatRotateX(e,60)
                call DestroyEffect(e)
        
                if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                    set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                else
                    set e = AddSpecialEffect("0413.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                endif
                call DestroyEffect(e)
        
                if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                    set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                else
                    set e = AddSpecialEffect("0561.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                endif
                call EXSetEffectSize(e,0.4)
                call DestroyEffect(e)
                set t2 = tick.create(0)
                set fx2 = SkillFx.Create()
                set fx2.ul = party.create()
                set fx2.caster = fx.caster
                set fx2.r =  GetUnitFacing(fx.caster)
                set fx2.pid = GetPlayerId(GetOwningPlayer(fx2.caster))
                set fx2.i = 0
                set fx2.j = 2
                set fx2.speed = ((100+SkillSpeed(fx2.pid))/100)
                set t2.data = fx2
                call t2.start( 0.03125, false, function EffectFunction2 ) 
                if LuciaForm[fx.pid] == 0 then
                    //set LuciaForm[fx.pid] = 1
                    call AnimationStart3(fx.caster,27, fx.speed)
                else
                    //set LuciaForm[fx.pid] = 0
                    call AnimationStart3(fx.caster,4, fx.speed)
                endif
                call DummyMagicleash(fx.caster, (EffectTime /fx.speed))
                call BuffNoST.Apply( fx.caster, (EffectTime /fx.speed), 0 )
                call t.start( (EffectTime /fx.speed), false, function EffectFunction )
            elseif fx.i == 6 then
                call DummyMagicleash(fx.caster, (EffectTime /fx.speed))
                call BuffNoST.Apply( fx.caster, (EffectTime /fx.speed), 0 )
                call fx.Stop()
                call t.destroy()
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
    local SkillFx fx
    local effect e
    local tick t2
    local SkillFx fx2

    if GetSpellAbilityId() == 'A07A' then
        call SetUnitFacing(GetTriggerUnit(), AngleWBP(GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() ))
        call EXSetUnitFacing(GetTriggerUnit(), AngleWBP(GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() ))
        set t = tick.create(0) 
        set fx = SkillFx.Create()
        set fx.caster = GetTriggerUnit()
        set fx.TargetX = GetSpellTargetX()
        set fx.TargetY = GetSpellTargetY()
        set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set fx.i = 0
        set fx.speed = ((100+SkillSpeed(fx.pid))/100)
        
        call Overlay2Count(fx.pid,'A07B')
        //set fx.speed = fx.speed * Arcana_ChargeSpeed[fx.pid]
        
        if LuciaForm[fx.pid] == 0 then
            //set LuciaForm[fx.pid] = 1
            call AnimationStart3(fx.caster,27, fx.speed)
        else
            //set LuciaForm[fx.pid] = 0
            call AnimationStart3(fx.caster,3, fx.speed)
        endif
        call LuciaMuPlus(fx.pid, 20)
        set t.data = fx
        set Stack[fx.pid] = 0
        /*
        call Sound3D(fx.caster,'A01N')
        if Player(fx.pid) == GetLocalPlayer() then
            if LuciaForm[fx.pid] == 0 then
                call DzFrameSetValue(LuciaAden,0)
            elseif LuciaForm[fx.pid] == 1 then
                call DzFrameSetValue(LuciaAden2,0)
            endif
        endif
        */
        set t2 = tick.create(0)
        set fx2 = SkillFx.Create()
        set fx2.ul = party.create()
        set fx2.caster = fx.caster
        set fx2.r =  GetUnitFacing(fx.caster)
        set fx2.pid = GetPlayerId(GetOwningPlayer(fx2.caster))
        set fx2.i = 0
        set fx2.j = 0
        set fx2.speed = ((100+SkillSpeed(fx2.pid))/100)
        set t2.data = fx2
        call t2.start( 0.03125, false, function EffectFunction2 ) 

        if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
            set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        else
            set e = AddSpecialEffect("0835.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        endif
        call EXEffectMatRotateZ(e,AngleWBP(fx.caster,GetSpellTargetX(),GetSpellTargetY()))
        call EXSetEffectSize(e,1.4)
        call EXSetEffectZ(e,70)
        call EXSetEffectSpeed(e,2)
        call EXEffectMatRotateX(e,160)
        call DestroyEffect(e)

        if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
            set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        else
            set e = AddSpecialEffect("0413.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        endif
        call DestroyEffect(e)

        if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
            set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        else
            set e = AddSpecialEffect("0561.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        endif
        call EXSetEffectSize(e,0.4)
        call DestroyEffect(e)

        call DummyMagicleash(fx.caster, (EffectTime /fx.speed))
        call BuffNoST.Apply( fx.caster, (EffectTime /fx.speed), 0 )
        call t.start( (EffectTime /fx.speed), false, function EffectFunction )
        call CooldownFIX(fx.caster,'A07A',1.50)
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
    
    if IsUnitAliveVJ(LuciaCheckUnit[pid]) == true and GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID1[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
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

private function WSyncData2 takes nothing returns nothing
    local player p = DzGetTriggerSyncPlayer()
    local integer pid = GetPlayerId(p)
    local real x
    local real y
    local real angle
    local real speed
    
    if Stack[pid] == 0 then
        set Stack[pid] = 1
    endif
    
    set p=null
endfunction
            
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        

    //스킬사용
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("LuciaW"),(false))
    call TriggerAddAction(t,function WSyncData)

    //떼면종료
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("LuciaW2"),(false))
    call TriggerAddAction(t,function WSyncData2)

    set t = null
//! runtextmacro 이벤트_끝()
endscope

