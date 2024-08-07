scope HeroChenQ
globals
    private constant real DR = 7.12
    private constant real SD = 60.00
    
    //private constant real CoolTime = 18.00
    private constant real CoolTime = 10.0
    
    //쉐클시간
    private constant real Time = 0.30
    //스킬이펙트 시간
    private constant real EffectTime = 0.70
    private constant real EffectTime2 = 0.50
    
    private constant real scale = 525
    private constant real distance = 350

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
    local integer level = HeroSkillLevel[pid][0]
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        if level >= 2 then
            set Velue = Velue * 1.70
        endif
        
        if level >= 3 then
            set Velue = Velue * 0.976
        endif
        
        call HeroDeal(splash.source,GetEnumUnit(),DR*Velue,true,false,SD,false)
    endif
endfunction

private function splashD2 takes nothing returns nothing
    local real Velue = 1.0
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer level = HeroSkillLevel[pid][0]
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        if level >= 2 then
            set Velue = Velue * 1.70
        endif
        
        if level >= 3 then
            set Velue = Velue * 1.525
        endif
        
        call HeroDeal(splash.source,GetEnumUnit(),DR*Velue,true,false,SD,false)
    endif
endfunction
private function splashD3 takes nothing returns nothing
    local real Velue = 1.0
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer level = HeroSkillLevel[pid][0]
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        if level >= 2 then
            set Velue = Velue * 1.70
        endif
        
        if level >= 3 then
            set Velue = Velue * 2.50
        endif
        
        call HeroDeal(splash.source,GetEnumUnit(),DR*Velue,true,false,SD,false)
    endif
endfunction

private function EffectFunction2 takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data
    local string data
    local integer random
    
    if fx.caster != null and IsUnitDeadVJ(fx.caster) == false then
        if Stack[fx.pid] == 11 then
            call Sound3D(fx.caster,'A01Q')
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+Polar.X( 100, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +Polar.Y( 100, GetUnitFacing(fx.caster) ), scale, function splashD1 )
            call AnimationStart3(fx.caster,16, (100+fx.speed)/100)
            set random = GetRandomInt(1,3)
            if random == 1 then
                call UnitEffectTime2('e00L',GetWidgetX(fx.caster)+Polar.X( 100, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster) +Polar.Y( 100, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.5,1)
            elseif random == 2 then
                call UnitEffectTime2('e00M',GetWidgetX(fx.caster)+Polar.X( 100, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster) +Polar.Y( 100, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.5,1)
            elseif random == 3 then
                call UnitEffectTime2('e00N',GetWidgetX(fx.caster)+Polar.X( 100, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster) +Polar.Y( 100, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.5,1)
            endif
            call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
            call DummyMagicleash(fx.caster, Time * (1 - (fx.speed/(100+fx.speed)) ))
            call BuffNoST.Apply( fx.caster, Time * (1 - (fx.speed/(100+fx.speed)) ), 0 )
            call CastingBarShow(Player(fx.pid),false)
            set Stack[fx.pid] = 0
            call fx.Stop()
            call t.destroy()
        elseif Stack[fx.pid] == 12 then
            call Sound3D(fx.caster,'A01Q')
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+Polar.X( 100, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +Polar.Y( 100, GetUnitFacing(fx.caster) ), scale, function splashD2 )
            call AnimationStart3(fx.caster,16, (100+fx.speed)/100)
            set random = GetRandomInt(1,3)
            if random == 1 then
                call UnitEffectTime2('e00L',GetWidgetX(fx.caster)+Polar.X( 100, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster) +Polar.Y( 100, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.5,1)
            elseif random == 2 then
                call UnitEffectTime2('e00M',GetWidgetX(fx.caster)+Polar.X( 100, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster) +Polar.Y( 100, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.5,1)
            elseif random == 3 then
                call UnitEffectTime2('e00N',GetWidgetX(fx.caster)+Polar.X( 100, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster) +Polar.Y( 100, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.5,1)
            endif
            call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
            call DummyMagicleash(fx.caster, Time * (1 - (fx.speed/(100+fx.speed)) ))
            call BuffNoST.Apply( fx.caster, Time * (1 - (fx.speed/(100+fx.speed)) ), 0 )
            call CastingBarShow(Player(fx.pid),false)
            set Stack[fx.pid] = 0
            call fx.Stop()
            call t.destroy()
        elseif Stack[fx.pid] == 13 then
            call Sound3D(fx.caster,'A01Q')
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+Polar.X( 100, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +Polar.Y( 100, GetUnitFacing(fx.caster) ), scale, function splashD3 )
            call AnimationStart3(fx.caster,16, (100+fx.speed)/100)
            set random = GetRandomInt(1,3)
            if random == 1 then
                call UnitEffectTime2('e00L',GetWidgetX(fx.caster)+Polar.X( 100, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster) +Polar.Y( 100, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.5,1)
            elseif random == 2 then
                call UnitEffectTime2('e00M',GetWidgetX(fx.caster)+Polar.X( 100, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster) +Polar.Y( 100, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.5,1)
            elseif random == 3 then
                call UnitEffectTime2('e00N',GetWidgetX(fx.caster)+Polar.X( 100, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster) +Polar.Y( 100, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.5,1)
            endif
            call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
            call DummyMagicleash(fx.caster, Time * (1 - (fx.speed/(100+fx.speed)) ))
            call BuffNoST.Apply( fx.caster, Time * (1 - (fx.speed/(100+fx.speed)) ), 0 )
            call CastingBarShow(Player(fx.pid),false)
            set Stack[fx.pid] = 0
            call fx.Stop()
            call t.destroy()
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
        if Stack[fx.pid] == 1 or Stack[fx.pid] == 2 or Stack[fx.pid] == 3 then
            if fx.i < 25 then
                if Player(fx.pid) == GetLocalPlayer() then
                    call DzFrameSetValue(CastingBar, fx.i)
                endif
                call DummyMagicleash(fx.caster,(EffectTime * (1 - (fx.speed/(100+fx.speed)) ))/25)
                call BuffNoST.Apply( fx.caster,(EffectTime * (1 - (fx.speed/(100+fx.speed)) ))/25, 0 )
                call t.start( (EffectTime * (1 - (fx.speed/(100+fx.speed)) ))/25, false, function EffectFunction )
            elseif fx.i == 25 then
                set Stack[fx.pid] = 2
                set e = AddSpecialEffectTarget("Effect_Invisibility_Target_Wave_puple2.mdl",fx.caster,"hand left")
                call DestroyEffect(e)
                set e = AddSpecialEffectTarget("Effect_Invisibility_Target_Wave_puple2.mdl",fx.caster,"hand left")
                call DestroyEffect(e)
                set e = null
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
                if Player(fx.pid) == GetLocalPlayer() then
                    call DzFrameSetValue(CastingBar, fx.i)
                endif
                call DummyMagicleash(fx.caster,(EffectTime2 * (1 - (fx.speed/(100+fx.speed)) ))/25 * 2)
                call BuffNoST.Apply( fx.caster,(EffectTime2 * (1 - (fx.speed/(100+fx.speed)) ))/25 * 2, 0 )
                call t.start( (EffectTime2 * (1 - (fx.speed/(100+fx.speed)) ))/25 * 2, false, function EffectFunction )
                set fx.i = fx.i + 1
            elseif fx.i < 50 then
                if Player(fx.pid) == GetLocalPlayer() then
                    call DzFrameSetValue(CastingBar, fx.i - 25)
                endif
                call DummyMagicleash(fx.caster,(EffectTime2 * (1 - (fx.speed/(100+fx.speed)) ))/25)
                call BuffNoST.Apply( fx.caster,(EffectTime2 * (1 - (fx.speed/(100+fx.speed)) ))/25, 0 )
                call t.start( (EffectTime2 * (1 - (fx.speed/(100+fx.speed)) ))/25, false, function EffectFunction )
            elseif fx.i == 50 then
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
                set Stack[fx.pid] = 3
                set e = AddSpecialEffectTarget("Effect_Invisibility_Target_Wave_puple2.mdl",fx.caster,"hand left")
                call DestroyEffect(e)
                set e = AddSpecialEffectTarget("Effect_Invisibility_Target_Wave_puple2.mdl",fx.caster,"hand left")
                call DestroyEffect(e)
                set e = null
                if Player(fx.pid) == GetLocalPlayer() then
                    call DzFrameSetValue(CastingBar, fx.i - 25)
                endif
                call DummyMagicleash(fx.caster,0.3)
                call BuffNoST.Apply( fx.caster,0.3, 0 )
                call t.start( 0.3, false, function EffectFunction )
            elseif fx.i == 51 then
                if Stack[fx.pid] == 3 then
                    set fx.i = 0
                    set Stack[fx.pid] = 13
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


private function EffectFunction3 takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data
    local integer random
    
    if fx.caster != null and IsUnitDeadVJ(fx.caster) == false then
        call Sound3D(fx.caster,'A01Q')
        call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+Polar.X( 100, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +Polar.Y( 100, GetUnitFacing(fx.caster) ), scale, function splashD1 )
        call AnimationStart3(fx.caster,16, (100+fx.speed)/100)
        set random = GetRandomInt(1,3)
        if random == 1 then
            call UnitEffectTime2('e00L',GetWidgetX(fx.caster)+Polar.X( 100, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster) +Polar.Y( 100, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.5,1)
        elseif random == 2 then
            call UnitEffectTime2('e00M',GetWidgetX(fx.caster)+Polar.X( 100, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster) +Polar.Y( 100, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.5,1)
        elseif random == 3 then
            call UnitEffectTime2('e00N',GetWidgetX(fx.caster)+Polar.X( 100, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster) +Polar.Y( 100, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.5,1)
        endif
        call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
        call DummyMagicleash(fx.caster,Time * (1 - (fx.speed/(100+fx.speed)) ))
        call CastingBarShow(Player(fx.pid),false)
        set Stack[fx.pid] = 0
    endif
    
    call fx.Stop()
    call t.destroy()
    
endfunction

private function Main takes nothing returns nothing
    local real speed
    local tick t
    local FxEffect fx
    if GetSpellAbilityId() == 'A01A' then
        set t = tick.create(0) 
        set fx = FxEffect.Create()
        set fx.caster = GetTriggerUnit()
        set fx.TargetX = GetSpellTargetX()
        set fx.TargetY = GetSpellTargetY()
        set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set fx.i = 0
        if HeroSkillLevel[fx.pid][0] >= 1 then
            set fx.speed = SkillSpeed2(fx.pid, 27.0)
        else
            set fx.speed = SkillSpeed(fx.pid)
        endif
        call CooldownFIX(fx.caster,'A01A',CoolTime)
        call AnimationStart3(fx.caster,15, (100+fx.speed)/100)
        
        if HeroSkillLevel[fx.pid][0] >= 3 then
            set t.data = fx
            set Stack[fx.pid] = 1
            if Player(fx.pid) == GetLocalPlayer() then
                call DzFrameSetText(CastingTextFrame,"발도")
                call DzFrameSetValue(CastingBar,0)
                call CastingBarShow(Player(fx.pid),true)
            endif
            call DummyMagicleash(fx.caster,(EffectTime * (1 - (fx.speed/(100+fx.speed)) ))/25)
            call t.start( (EffectTime * (1 - (fx.speed/(100+fx.speed)) ))/25, false, function EffectFunction )
        else
            set t.data = fx
            set Stack[fx.pid] = 1
            call DummyMagicleash(fx.caster,(EffectTime * (1 - (fx.speed/(100+fx.speed)) ))/25)
            call t.start( (EffectTime * (1 - (fx.speed/(100+fx.speed)) ))/25, false, function EffectFunction3 )
        endif
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
        set angle = Angle.WBP(MainUnit[pid],x,y)
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
    local FxEffect fx
    
    if Stack[pid] == 0 then
    elseif Stack[pid] == 1 then
        set t = tick.create(0) 
        set fx = FxEffect.Create()
        set fx.pid = pid
        set fx.caster = MainUnit[fx.pid]
        set fx.i = 0
        set fx.speed = (Equip_Swiftness[fx.pid]/40)
        set t.data = fx
        set Stack[fx.pid] = 11
        call t.start( 0.02, false, function EffectFunction2 )
    elseif Stack[pid] == 2 then
        set t = tick.create(0) 
        set fx = FxEffect.Create()
        set fx.pid = pid
        set fx.caster = MainUnit[fx.pid]
        set fx.i = 0
        set fx.speed = (Equip_Swiftness[fx.pid]/40)
        set t.data = fx
        set Stack[fx.pid] = 12
        call t.start( 0.02, false, function EffectFunction2 )
    elseif Stack[pid] == 3 then
        set t = tick.create(0) 
        set fx = FxEffect.Create()
        set fx.pid = pid
        set fx.caster = MainUnit[fx.pid]
        set fx.i = 0
        set fx.speed = (Equip_Swiftness[fx.pid]/40)
        set t.data = fx
        set Stack[fx.pid] = 13
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
    call DzTriggerRegisterSyncData(t,("ChenQ"),(false))
    call TriggerAddAction(t,function QSyncData)
    
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("ChenQ2"),(false))
    call TriggerAddAction(t,function QSyncData2)

    set t = null
//! runtextmacro 이벤트_끝()
endscope

