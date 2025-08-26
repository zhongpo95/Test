scope HeroBandiF
globals
    private constant real SD = 70
    
    //모션시간
    private constant real Time1 = 1.0
    private constant real Time2 = 0.60

    //차지시간
    private constant real EffectTime = 3.0 / 3

    private constant real scale = 1300
    private constant real distance = 1000

    private integer array Stack
    private integer array Size
    private unit array SDummy
    private integer array Nabi
    private integer Nabi2
endglobals

private function splashD2 takes nothing returns nothing
    local real Velue = 1.0
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    //local integer level = HeroSkillLevel[pid][2]
    local integer random
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        call HeroDeal(1,splash.source,GetEnumUnit(),HeroSkillVelue7[14]*Velue,false,false,false,false)
        call UnitEffectTimeEX2('e02B',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),GetRandomReal(0,360),1.2,pid)

        loop
        exitwhen Nabi2 == 0
            set Nabi2 = Nabi2 - 1
            call HeroDeal(1,splash.source,GetEnumUnit(),HeroSkillVelue7[14]*Velue,false,false,false,false)
            call UnitEffectTimeEX2('e02B',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),GetRandomReal(0,360),1.2,pid)
        endloop

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

private function splashD takes nothing returns nothing
    local real Velue = 1.0
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    //local integer level = HeroSkillLevel[pid][2]
    local integer random
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        call HeroDeal(1,splash.source,GetEnumUnit(),HeroSkillVelue7[14]*Velue,false,false,false,false)
        call UnitEffectTimeEX2('e02B',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),GetRandomReal(0,360),1.2,pid)
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


private function EffectFunction4 takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillFx fx = t.data
    local integer i = 0

    set fx.i = fx.i + 1
        
    if fx.caster != null and IsUnitDeadVJ(fx.caster) == false then
        if Stack[fx.pid] == 11 then
            set Nabi2 = fx.st
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster),GetWidgetY(fx.caster), scale, function splashD2 )
            set Nabi2 = 0
            if fx.i == 1 then
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
            endif
        elseif Stack[fx.pid] == 12 then
            set Nabi2 = fx.st
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster),GetWidgetY(fx.caster), scale, function splashD2 )
            set Nabi2 = 0
            if fx.i == 1 then
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
            endif
        elseif Stack[fx.pid] == 13 then
            set Nabi2 = fx.st
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster),GetWidgetY(fx.caster), scale, function splashD2 )
            set Nabi2 = 0
            if fx.i == 1 then
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
            endif
        elseif Stack[fx.pid] == 14 then
            set Nabi2 = fx.st
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster),GetWidgetY(fx.caster), scale, function splashD2 )
            set Nabi2 = 0
            if fx.i == 1 then
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
            endif
        endif
        if fx.i == 1 then
            call Sound3D(fx.caster,'A03U')
            if GetRandomInt(0,1) == 0 then
                call Sound3D(fx.caster,'A05S')
            else
                call Sound3D(fx.caster,'A05T')
            endif
        endif

        if fx.i == 3 then
            set Stack[fx.pid] = 0
            call fx.Stop()
            call t.destroy()
        elseif fx.i == 2 then
            call UnitRemoveAbility( fx.caster, 'B000' )
            call UnitApplyTimedLife( SDummy[fx.pid], 'BHwe', 0.1 )
            set SDummy[fx.pid] = null
            call t.start( 0.2, false, function EffectFunction4 )
        else
            call t.start( 0.2, false, function EffectFunction4 )
        endif
    else
        set Stack[fx.pid] = 0
        call fx.Stop()
        call t.destroy()
    endif
endfunction

private function EffectFunction3 takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillFx fx = t.data

        
    if fx.caster != null and IsUnitDeadVJ(fx.caster) == false then
        call AnimationStart3(fx.caster,16, fx.A2speed)
        if HeroSkillLevel[fx.pid][7] >= 3 and fx.st == 6 then
            call BuffNoDM.Apply( fx.caster, (Time2 / fx.A2speed) + 0.4, 0 )
            call BuffNoNB.Apply( fx.caster, (Time2 / fx.A2speed) + 0.4, 0 )
            call BuffNoST.Apply( fx.caster, (Time2 / fx.A2speed) + 0.4, 0 )
        endif
        set fx.i = 0
        call t.start( Time2 / fx.A2speed, false, function EffectFunction4 )
    else
        set Stack[fx.pid] = 0
        call fx.Stop()
        call t.destroy()
    endif

endfunction

private function EffectFunction2 takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillFx fx = t.data
    local string data
    local integer random
    local integer i
        
    //38 39 54 55
    if fx.caster != null and IsUnitDeadVJ(fx.caster) == false then
        call AnimationStart3(fx.caster,15, fx.A2speed)
        set i = GetRandomInt(1,3)
        call Sound3D(fx.caster,'A03T')
        call Sound3D(fx.caster,'A049')
        call UnitEffectTime2('e032',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetUnitFacing(fx.caster),0.4,0,fx.pid)
        call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
        if Stack[fx.pid] == 11 then
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale, function splashD )
        elseif Stack[fx.pid] == 12 then
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale, function splashD )
        elseif Stack[fx.pid] == 13 then
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale, function splashD )
        elseif Stack[fx.pid] == 14 then
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale, function splashD )
        endif
        call CastingBarShow(Player(fx.pid),false)
        call t.start( Time1 / fx.A2speed, false, function EffectFunction3 )
    endif
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillFx fx = t.data
    local string data
    local effect e
    local integer i
    
    set fx.i = fx.i + 1
    set Size[fx.pid] = fx.i
    if Size[fx.pid] == 76 then
        set Size[fx.pid] = 75
    endif
    if fx.caster != null and IsUnitDeadVJ(fx.caster) == false and GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
        if Stack[fx.pid] == 1 or Stack[fx.pid] == 2 or Stack[fx.pid] == 3 or Stack[fx.pid] == 4 then
            if fx.i < 25 then
                set Stack[fx.pid] = 1
                if Player(fx.pid) == GetLocalPlayer() then
                    call DzFrameSetValue(CastingBar, fx.i)
                endif
                call t.start( (EffectTime / fx.Aspeed) /25, false, function EffectFunction )
            elseif fx.i == 25 then
                call Sound3D(fx.caster,'A03L')
                set Stack[fx.pid] = 2
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
                if Player(fx.pid) == GetLocalPlayer() then
                    call DzFrameSetValue(CastingBar, fx.i)
                endif
                call t.start( (EffectTime / fx.Aspeed) /25 * 2, false, function EffectFunction )
                set fx.i = fx.i + 1
            elseif fx.i < 50 then
                if Player(fx.pid) == GetLocalPlayer() then
                    call DzFrameSetValue(CastingBar, fx.i - 25)
                endif
                call t.start( (EffectTime / fx.Aspeed) /25, false, function EffectFunction )
            elseif fx.i == 50 then
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
                call Sound3D(fx.caster,'A03M')
                set Stack[fx.pid] = 3
                if Player(fx.pid) == GetLocalPlayer() then
                    call DzFrameSetValue(CastingBar, fx.i - 25)
                endif
                call t.start( (EffectTime / fx.Aspeed) /25 * 2, false, function EffectFunction )
                set fx.i = fx.i + 1
            elseif fx.i < 75 then
                if Player(fx.pid) == GetLocalPlayer() then
                    call DzFrameSetValue(CastingBar, fx.i - 50)
                endif
                call t.start( (EffectTime / fx.Aspeed) /25, false, function EffectFunction )
            elseif fx.i == 75 then
                call Sound3D(fx.caster,'A03N')
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
                set Stack[fx.pid] = 4
                if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                    set e = AddSpecialEffectTarget(".mdl",fx.caster,"hand left")
                else
                    set e = AddSpecialEffectTarget("Effect_Invisibility_Target_Wave_Red2.mdl",fx.caster,"hand left")
                endif
                call DestroyEffect(e)
                set e = null
                if Player(fx.pid) == GetLocalPlayer() then
                    call DzFrameSetValue(CastingBar, fx.i - 50)
                endif
                call t.start( 1.0, false, function EffectFunction )
            elseif fx.i == 76 then
                if Stack[fx.pid] == 4 then
                    set fx.i = 0
                    set Stack[fx.pid] = 14
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
    local SkillFx fx
    local real r
    local integer i
    
    //38 39 54 55

    if GetSpellAbilityId() == 'A06G' then
        set t = tick.create(0)
        set fx = SkillFx.Create()
        set fx.caster = GetTriggerUnit()
        set fx.TargetX = GetSpellTargetX()
        set fx.TargetY = GetSpellTargetY()
        set fx.pid = GetPlayerId(GetOwningPlayer(fx.caster))
        set fx.i = 0
        if HeroSkillLevel[fx.pid][7] >= 1 then
            if HeroSkillLevel[fx.pid][7] >= 3 then
                set fx.st = NarNabiUse(fx.pid,true)
            else
                set fx.st = NarNabiUse(fx.pid,false)
            endif
            if HeroSkillLevel[fx.pid][7] >= 2 then
                set fx.r = 1 + ( 0.5 * fx.st )
            else
                set fx.r = 1
            endif
            set fx.Aspeed = ((100+SkillSpeed(fx.pid))/100) * fx.r
        else
            set fx.st = 0
            set fx.r = 1
            set fx.Aspeed = ((100+SkillSpeed(fx.pid))/100)
        endif

        set fx.A2speed = ((100+SkillSpeed(fx.pid))/100)

        set Stack[fx.pid] = 1

        //유닛애니메이션속도
        call AnimationStart3(fx.caster, 14, fx.Aspeed)
        
        if Player(fx.pid) == GetLocalPlayer() then
            call DzFrameSetText(CastingTextFrame,"찰 나")
            call DzFrameSetValue(CastingBar,0)
            call CastingBarShow(Player(fx.pid),true)
        endif

        set t.data = fx
        set SDummy[fx.pid] =  DummyMagicleash2( fx.caster )
        call t.start( (EffectTime / fx.Aspeed ) / 25, false, function EffectFunction )

        call CooldownFIX(fx.caster,'A06G',HeroSkillCD7[14])
    endif
endfunction

    
private function FSyncData takes nothing returns nothing
    local player p=(DzGetTriggerSyncPlayer())
    local string data=(DzGetTriggerSyncData())
    local integer pid=GetPlayerId(p)
    local integer dataLen=StringLength(data)
    local integer valueLen
    local real x
    local real y
    local real angle
    
    if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID7[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
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
            call IssuePointOrder( MainUnit[pid], "attributemodskill", x, y )
        endif
    endif

    set p=null
endfunction

private function FSyncData2 takes nothing returns nothing
    local player p = DzGetTriggerSyncPlayer()
    local integer pid = GetPlayerId(p)
    local real x
    local real y
    local real angle
    local real speed
    local tick t
    local SkillFx fx

    if Stack[pid] == 0 then
        
    elseif Stack[pid] == 1 then
        set t = tick.create(0) 
        set fx = SkillFx.Create()
        set fx.pid = pid
        set fx.caster = MainUnit[fx.pid]
        set fx.i = 0
        if HeroSkillLevel[pid][7] >= 1 then
            set fx.st = Nabi[fx.pid]
            if HeroSkillLevel[pid][7] >= 2 then
                set fx.r = 1 + ( 0.5 * fx.st )
            else
                set fx.r = 1
            endif
            set fx.Aspeed = ((100+SkillSpeed(fx.pid))/100) * fx.r
        else
            set fx.st = 0
            set fx.r = 1
            set fx.Aspeed = ((100+SkillSpeed(fx.pid))/100)
        endif
        set fx.A2speed = ((100+SkillSpeed(pid))/100)
        set t.data = fx
        set Stack[fx.pid] = 11
        call t.start( 0.02, false, function EffectFunction2 )
    elseif Stack[pid] == 2 then
        set t = tick.create(0) 
        set fx = SkillFx.Create()
        set fx.pid = pid
        set fx.caster = MainUnit[fx.pid]
        set fx.i = 0
        if HeroSkillLevel[pid][7] >= 1 then
            set fx.st = Nabi[fx.pid]
            if HeroSkillLevel[pid][7] >= 2 then
                set fx.r = 1 + ( 0.5 * fx.st )
            else
                set fx.r = 1
            endif
            set fx.Aspeed = ((100+SkillSpeed(fx.pid))/100) * fx.r
        else
            set fx.st = 0
            set fx.r = 1
            set fx.Aspeed = ((100+SkillSpeed(fx.pid))/100)
        endif
        set fx.A2speed = ((100+SkillSpeed(pid))/100)
        set t.data = fx
        set Stack[fx.pid] = 12
        call t.start( 0.02, false, function EffectFunction2 )
    elseif Stack[pid] == 3 then
        set t = tick.create(0) 
        set fx = SkillFx.Create()
        set fx.pid = pid
        set fx.caster = MainUnit[fx.pid]
        set fx.i = 0
        if HeroSkillLevel[pid][7] >= 1 then
            set fx.st = Nabi[fx.pid]
            if HeroSkillLevel[pid][7] >= 2 then
                set fx.r = 1 + ( 0.5 * fx.st )
            else
                set fx.r = 1
            endif
            set fx.Aspeed = ((100+SkillSpeed(fx.pid))/100) * fx.r
        else
            set fx.st = 0
            set fx.r = 1
            set fx.Aspeed = ((100+SkillSpeed(fx.pid))/100)
        endif
        set fx.A2speed = ((100+SkillSpeed(pid))/100)
        set t.data = fx
        set Stack[fx.pid] = 13
        call t.start( 0.02, false, function EffectFunction2 )
    elseif Stack[pid] == 4 then
        set t = tick.create(0) 
        set fx = SkillFx.Create()
        set fx.pid = pid
        set fx.caster = MainUnit[fx.pid]
        set fx.i = 0
        if HeroSkillLevel[pid][7] >= 1 then
            set fx.st = Nabi[fx.pid]
            if HeroSkillLevel[pid][7] >= 2 then
                set fx.r = 1 + ( 0.5 * fx.st )
            else
                set fx.r = 1
            endif
            set fx.Aspeed = ((100+SkillSpeed(fx.pid))/100) * fx.r
        else
            set fx.st = 0
            set fx.r = 1
            set fx.Aspeed = ((100+SkillSpeed(fx.pid))/100)
        endif
        set fx.A2speed = ((100+SkillSpeed(pid))/100)
        set t.data = fx
        set Stack[fx.pid] = 14
        call t.start( 0.02, false, function EffectFunction2 )
    endif

    set p=null
endfunction

            
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("BandiF"),(false))
    call TriggerAddAction(t,function FSyncData)
    
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("BandiF2"),(false))
    call TriggerAddAction(t,function FSyncData2)

    set t = null
//! runtextmacro 이벤트_끝()
endscope

