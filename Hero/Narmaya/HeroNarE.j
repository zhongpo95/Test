scope HeroNarE
globals

    private constant real SD = 70
    
    //모션시간
    private constant real Time1 = 0.50
    private constant real Time2 = 0.60

    //차지시간
    private constant real EffectTime = 2.0 / 3

    private constant real scale = 1500
    private constant real distance = 900

    private constant real scale2 = 900
    private constant real distance2 = 750

    private integer array Stack
    private integer array Size
    private unit array StackDummy
    private unit array SDummy
    private boolean StackChecker
endglobals

private struct FxEffect
    unit caster
    real TargetX
    real TargetY
    integer pid
    integer i
    integer j
    real r
    real Aspeed
    real A2speed
    private method OnStop takes nothing returns nothing
        set caster = null
        set TargetX = 0
        set TargetY = 0
        set pid = 0
        set i = 0
        set j = 0
        set r = 0
        set Aspeed = 0
        set A2speed = 0
    endmethod
    //! runtextmacro 연출()
endstruct

private function AngleCheck takes real A,real A2,real R returns boolean
    local boolean n

    if A2 < 0 then
        set A2 = A2 +360
    endif
   
    if A - R >= A2 or A - (R*-1) <= A2 then
        set n  = true
    else
        set n = false
    endif 
    return n
endfunction

private function splashD1 takes nothing returns nothing
    local real Velue = 1.0
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer level = HeroSkillLevel[pid][2]
    local integer random
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        if AngleTrue(AngleWBW(splash.source,GetEnumUnit()), GetUnitFacing(splash.source),  1.8 * I2R(Size[pid]) ) then
            call HeroDeal('A02K',splash.source,GetEnumUnit(),HeroSkillVelue2[14]*Velue,false,false,false,true)
            call UnitEffectTimeEX2('e02B',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),AngleWBW(splash.source,GetEnumUnit())-90,1.2,pid)
            set random = GetRandomInt(0,2)
            if random == 0 then
                call Sound3D(GetEnumUnit(),'A03X')
            elseif random == 1 then
                call Sound3D(GetEnumUnit(),'A03Y')
            elseif random == 2 then
                call Sound3D(GetEnumUnit(),'A05N')
            endif
        endif
    endif
endfunction
private function splashD2 takes nothing returns nothing
    local real Velue = 1.0
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer level = HeroSkillLevel[pid][2]
    local integer random
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        if AngleTrue(AngleWBW(splash.source,GetEnumUnit()), GetUnitFacing(splash.source),  1.8 * I2R(Size[pid]) ) then
            if level >= 2 then
                set Velue = Velue * 1.30
            endif
            
            call HeroDeal('A02K',splash.source,GetEnumUnit(),HeroSkillVelue2[14]*Velue,false,false,false,true)
            call UnitEffectTimeEX2('e02B',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),AngleWBW(splash.source,GetEnumUnit())-90,1.2,pid)
            set random = GetRandomInt(0,2)
            if random == 0 then
                call Sound3D(GetEnumUnit(),'A03X')
            elseif random == 1 then
                call Sound3D(GetEnumUnit(),'A03Y')
            elseif random == 2 then
                call Sound3D(GetEnumUnit(),'A05N')
            endif
        endif
    endif
endfunction
private function splashD3 takes nothing returns nothing
    local real Velue = 1.0
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer level = HeroSkillLevel[pid][2]
    local integer random
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        if AngleTrue(AngleWBW(splash.source,GetEnumUnit()), GetUnitFacing(splash.source),  1.8 * I2R(Size[pid]) ) then
            if level >= 2 then
                set Velue = Velue * 1.60
            endif
            
            call HeroDeal('A02K',splash.source,GetEnumUnit(),HeroSkillVelue2[14]*Velue,false,false,false,true)
            call UnitEffectTimeEX2('e02B',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),AngleWBW(splash.source,GetEnumUnit())-90,1.2,pid)
            set random = GetRandomInt(0,2)
            if random == 0 then
                call Sound3D(GetEnumUnit(),'A03X')
            elseif random == 1 then
                call Sound3D(GetEnumUnit(),'A03Y')
            elseif random == 2 then
                call Sound3D(GetEnumUnit(),'A05N')
            endif
        endif
    endif
endfunction
private function splashD4 takes nothing returns nothing
    local real Velue = 1.0
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer level = HeroSkillLevel[pid][2]
    local integer random
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        if AngleTrue(AngleWBW(splash.source,GetEnumUnit()), GetUnitFacing(splash.source),  1.8 * I2R(Size[pid]) ) then
            if level >= 2 then
                set Velue = Velue * 1.90
            endif
            
            call HeroDeal('A02K',splash.source,GetEnumUnit(),HeroSkillVelue2[14]*Velue,false,false,false,true)
            call UnitEffectTimeEX2('e02B',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),AngleWBW(splash.source,GetEnumUnit())-90,1.2,pid)
            set random = GetRandomInt(0,2)
            if random == 0 then
                call Sound3D(GetEnumUnit(),'A03X')
            elseif random == 1 then
                call Sound3D(GetEnumUnit(),'A03Y')
            elseif random == 2 then
                call Sound3D(GetEnumUnit(),'A05N')
            endif
        endif
    endif
endfunction
private function splashD5 takes nothing returns nothing
    local real Velue = 1.0
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer level = HeroSkillLevel[pid][2]
    local integer random
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance2) then
        if AngleTrue(AngleWBW(splash.source,GetEnumUnit()), GetUnitFacing(splash.source),  1.8 * I2R(Size[pid]) ) then
            call HeroDeal('A02K',splash.source,GetEnumUnit(),HeroSkillVelue2[14]*Velue,false,false,false,true)
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
    endif
endfunction
private function splashD6 takes nothing returns nothing
    local real Velue = 1.0
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer level = HeroSkillLevel[pid][2]
    local integer random
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance2) then
        if AngleTrue(AngleWBW(splash.source,GetEnumUnit()), GetUnitFacing(splash.source),  1.8 * I2R(Size[pid]) ) then
            call HeroDeal('A02K',splash.source,GetEnumUnit(),HeroSkillVelue2[14]*Velue,false,false,false,true)
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
    endif
endfunction
private function splashD7 takes nothing returns nothing
    local real Velue = 1.0
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer level = HeroSkillLevel[pid][2]
    local integer random
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance2) then
        if AngleTrue(AngleWBW(splash.source,GetEnumUnit()), GetUnitFacing(splash.source),  1.8 * I2R(Size[pid]) ) then
            if level >= 3 then
                set Velue = Velue * 2.00
            endif
            call HeroDeal('A02K',splash.source,GetEnumUnit(),HeroSkillVelue2[14]*Velue,false,false,false,true)
            call UnitEffectTimeEX2('e02B',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),GetRandomReal(0,360),1.2,pid)
            set random = GetRandomInt(0,2)
            if random == 0 then
                call Sound3D(GetEnumUnit(),'A03X')
            elseif random == 1 then
                call Sound3D(GetEnumUnit(),'A03Y')
            elseif random == 2 then
                call Sound3D(GetEnumUnit(),'A05N')
            endif
            if level >= 2 then
                if StackChecker == false then
                    call NarNabiPlus(pid,1)
                    set StackChecker = true
                endif
            endif
        endif
    endif
endfunction
private function splashD8 takes nothing returns nothing
    local real Velue = 1.0
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer level = HeroSkillLevel[pid][2]
    local integer random
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance2) then
        if AngleTrue(AngleWBW(splash.source,GetEnumUnit()), GetUnitFacing(splash.source),  1.8 * I2R(Size[pid]) ) then
            call HeroDeal('A02K',splash.source,GetEnumUnit(),HeroSkillVelue2[14]*Velue,false,false,false,true)
            call UnitEffectTimeEX2('e02B',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),AngleWBW(splash.source,GetEnumUnit())-90,1.2,pid)
            set random = GetRandomInt(0,2)
            if random == 0 then
                call Sound3D(GetEnumUnit(),'A03X')
            elseif random == 1 then
                call Sound3D(GetEnumUnit(),'A03Y')
            elseif random == 2 then
                call Sound3D(GetEnumUnit(),'A05N')
            endif
        endif
    endif
endfunction

private function EffectFunction4 takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data

    set fx.i = fx.i + 1
        
    if fx.caster != null and IsUnitDeadVJ(fx.caster) == false then
        if Stack[fx.pid] == 11 then
        elseif Stack[fx.pid] == 12 then
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX(150, GetUnitFacing(fx.caster)),GetWidgetY(fx.caster)+PolarY(150, GetUnitFacing(fx.caster)), scale2, function splashD5 )
            if fx.i == 1 then
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
                //call KillUnit(CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e02C',GetWidgetX(fx.caster)+PolarX(150, GetUnitFacing(fx.caster)),GetWidgetY(fx.caster)+PolarY(150, GetUnitFacing(fx.caster)),GetUnitFacing(fx.caster)))
                call KillUnit(CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e03T',GetWidgetX(fx.caster)+PolarX(150, GetUnitFacing(fx.caster)),GetWidgetY(fx.caster)+PolarY(150, GetUnitFacing(fx.caster)),GetUnitFacing(fx.caster)))
                call KillUnit(CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e03T',GetWidgetX(fx.caster)+PolarX(150, GetUnitFacing(fx.caster)),GetWidgetY(fx.caster)+PolarY(150, GetUnitFacing(fx.caster)),GetUnitFacing(fx.caster)))
            endif
        elseif Stack[fx.pid] == 13 then
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX(150, GetUnitFacing(fx.caster)),GetWidgetY(fx.caster)+PolarY(150, GetUnitFacing(fx.caster)), scale2, function splashD6 )
            if fx.i == 1 then
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
                //call KillUnit(CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e02C',GetWidgetX(fx.caster)+PolarX(150, GetUnitFacing(fx.caster)),GetWidgetY(fx.caster)+PolarY(150, GetUnitFacing(fx.caster)),GetUnitFacing(fx.caster)))
                call KillUnit(CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e03T',GetWidgetX(fx.caster)+PolarX(150, GetUnitFacing(fx.caster)),GetWidgetY(fx.caster)+PolarY(150, GetUnitFacing(fx.caster)),GetUnitFacing(fx.caster)))
                call KillUnit(CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e03T',GetWidgetX(fx.caster)+PolarX(150, GetUnitFacing(fx.caster)),GetWidgetY(fx.caster)+PolarY(150, GetUnitFacing(fx.caster)),GetUnitFacing(fx.caster)))
            endif
        elseif Stack[fx.pid] == 14 then
            if fx.j == 0 then
                set StackChecker = false
            else
                set StackChecker = true
            endif
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX(150, GetUnitFacing(fx.caster)),GetWidgetY(fx.caster)+PolarY(150, GetUnitFacing(fx.caster)), scale2, function splashD7 )
            if StackChecker == true then
                set fx.j = 1
            endif
            set StackChecker = false
            if fx.i == 1 then
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
                //call KillUnit(CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e02C',GetWidgetX(fx.caster)+PolarX(150, GetUnitFacing(fx.caster)),GetWidgetY(fx.caster)+PolarY(150, GetUnitFacing(fx.caster)),GetUnitFacing(fx.caster)))
                call KillUnit(CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e03T',GetWidgetX(fx.caster)+PolarX(150, GetUnitFacing(fx.caster)),GetWidgetY(fx.caster)+PolarY(150, GetUnitFacing(fx.caster)),GetUnitFacing(fx.caster)))
                call KillUnit(CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e03T',GetWidgetX(fx.caster)+PolarX(150, GetUnitFacing(fx.caster)),GetWidgetY(fx.caster)+PolarY(150, GetUnitFacing(fx.caster)),GetUnitFacing(fx.caster)))
            endif
            if HeroSkillLevel[fx.pid][1] >= 1 then
                call BuffNar00.Apply( fx.caster, NarChangeTime, 0 )
            endif
        endif
        if Stack[fx.pid] > 11 and fx.i == 1 then
            call Sound3D(fx.caster,'A03O')
        endif

        if fx.i == 3 then
            set NarStack[fx.pid] = 0
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
        set NarStack[fx.pid] = 0
        set Stack[fx.pid] = 0
        call fx.Stop()
        call t.destroy()
    endif
endfunction

private function EffectFunction3 takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data

        
    if fx.caster != null and IsUnitDeadVJ(fx.caster) == false then
        call AnimationStart3(fx.caster,16, fx.A2speed)
        set fx.i = 0
        set fx.j = 0
        call t.start( Time2 / fx.A2speed, false, function EffectFunction4 )
    else
        set NarStack[fx.pid] = 0
        set Stack[fx.pid] = 0
        call fx.Stop()
        call t.destroy()
    endif

endfunction

private function EffectFunction2 takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data
    local string data
    local integer random
    local integer i
        
    if fx.caster != null and IsUnitDeadVJ(fx.caster) == false then
        call AnimationStart3(fx.caster,15, fx.A2speed)
        call KillUnit(StackDummy[fx.pid])
        call ShowUnit(StackDummy[fx.pid], false)
        set StackDummy[fx.pid] = null
        set i = GetRandomInt(1,3)
        call Sound3D(fx.caster,'A03O')
        if i == 1 then
            call Sound3D(fx.caster,'A02Y')
        elseif i == 2 then
            call Sound3D(fx.caster,'A02Z')
        elseif i == 3 then
            call Sound3D(fx.caster,'A030')
        endif
        call UnitEffectTime2('e02A',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetUnitFacing(fx.caster),1.2,0,fx.pid)
        call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
        if Stack[fx.pid] == 11 then
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale, function splashD1 )
        elseif Stack[fx.pid] == 12 then
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale, function splashD2 )
        elseif Stack[fx.pid] == 13 then
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale, function splashD3 )
        elseif Stack[fx.pid] == 14 then
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale, function splashD4 )
        endif
        call CastingBarShow(Player(fx.pid),false)
        call t.start( Time1 / fx.A2speed, false, function EffectFunction3 )

        //set NarStack[fx.pid] = 0
        //set Stack[fx.pid] = 0
        //call fx.Stop()
        //call t.destroy()
    endif
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data
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
                if fx.i == 1 then
                    call Sound3D(fx.caster,'A03L')
                endif
                set Stack[fx.pid] = 1
                if Player(fx.pid) == GetLocalPlayer() then
                    call DzFrameSetValue(CastingBar, fx.i)
                endif
                call t.start( (EffectTime / fx.Aspeed) /25, false, function EffectFunction )
            elseif fx.i == 25 then
                set Stack[fx.pid] = 2
                set i = GetRandomInt(1,2)
                if i == 1 then
                    call Sound3D(fx.caster,'A02S')
                elseif i == 2 then
                    call Sound3D(fx.caster,'A02X')
                endif
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

private function EffectFunction9 takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data

        
    if fx.caster != null and IsUnitDeadVJ(fx.caster) == false then
        call UnitRemoveAbility( fx.caster, 'B000' )
        call UnitApplyTimedLife( SDummy[fx.pid], 'BHwe', 0.1 )
        set SDummy[fx.pid] = null
        set NarStack[fx.pid] = 0
        set Stack[fx.pid] = 0
        call fx.Stop()
        call t.destroy()
    endif
endfunction

private function EffectFunction8 takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data
    local string data
    local integer random
    local integer i
        
    if fx.caster != null and IsUnitDeadVJ(fx.caster) == false then
        call AnimationStart3(fx.caster,15, fx.A2speed)
        call KillUnit(StackDummy[fx.pid])
        call ShowUnit(StackDummy[fx.pid], false)
        set StackDummy[fx.pid] = null
        set i = GetRandomInt(1,3)
        call Sound3D(fx.caster,'A03O')
        if i == 1 then
            call Sound3D(fx.caster,'A02Y')
        elseif i == 2 then
            call Sound3D(fx.caster,'A02Z')
        elseif i == 3 then
            call Sound3D(fx.caster,'A030')
        endif
        call UnitEffectTime2('e02A',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetUnitFacing(fx.caster),1.2,0,fx.pid)
        call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
        if Stack[fx.pid] == 11 then
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale, function splashD8 )
        endif
        if Size[fx.pid] == 75 then
            if HeroSkillLevel[fx.pid][1] >= 1 then
                call BuffNar00.Apply( fx.caster, NarChangeTime, 0 )
            endif
        endif

        call CastingBarShow(Player(fx.pid),false)
        call t.start( Time1 / fx.A2speed, false, function EffectFunction9 )

        //set NarStack[fx.pid] = 0
        //set Stack[fx.pid] = 0
        //call fx.Stop()
        //call t.destroy()
    endif
endfunction

private function EffectFunction7 takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data
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
            if fx.i < 75 then
                if fx.i == 1 then
                    call Sound3D(fx.caster,'A03L')
                endif
                set Stack[fx.pid] = 1
                if Player(fx.pid) == GetLocalPlayer() then
                    call DzFrameSetValue(CastingBar, fx.i/3)
                endif
                call t.start( (EffectTime / fx.Aspeed) /25, false, function EffectFunction7 )
            elseif fx.i == 75 then
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
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
                call t.start( 1.0, false, function EffectFunction7 )
            elseif fx.i == 76 then
                if Stack[fx.pid] == 1 then
                    set fx.i = 0
                    set Stack[fx.pid] = 11
                    call t.start( 0.02, false, function EffectFunction8 )
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
    local real r
    local integer i 
    if GetSpellAbilityId() == 'A02K' then
        set t = tick.create(0)
        set fx = FxEffect.Create()
        set fx.caster = GetTriggerUnit()
        set fx.TargetX = GetSpellTargetX()
        set fx.TargetY = GetSpellTargetY()
        set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set fx.i = 0
        set fx.r = 1 + ( 0.5 * NarStack[fx.pid] )

        call Overlay2Count(fx.pid,'A02K')

        if HeroSkillLevel[fx.pid][2] >= 1 then
            set fx.Aspeed = ((100+SkillSpeed(fx.pid))/100) * fx.r
        else
            set fx.Aspeed = ((100+SkillSpeed(fx.pid))/100)
        endif
        //슈차
        set fx.Aspeed = fx.Aspeed * Arcana_ChargeSpeed[fx.pid]

        set fx.A2speed = ((100+SkillSpeed(fx.pid))/100)
        
        if StackDummy[fx.pid] == null then
            if HeroSkillLevel[fx.pid][2] >= 2 then
                set StackDummy[fx.pid] = CreateUnit(Player(fx.pid),'e026',GetUnitX(fx.caster),GetUnitY(fx.caster), AngleWBP(fx.caster,fx.TargetX ,fx.TargetY))
            else
                set StackDummy[fx.pid] = CreateUnit(Player(fx.pid),'e029',GetUnitX(fx.caster),GetUnitY(fx.caster), AngleWBP(fx.caster,fx.TargetX ,fx.TargetY))
            endif
        else
            call KillUnit(StackDummy[fx.pid])
            call ShowUnit(StackDummy[fx.pid], false)
            if HeroSkillLevel[fx.pid][2] >= 2 then
                set StackDummy[fx.pid] = CreateUnit(Player(fx.pid),'e026',GetUnitX(fx.caster),GetUnitY(fx.caster), AngleWBP(fx.caster,fx.TargetX ,fx.TargetY))
            else
                set StackDummy[fx.pid] = CreateUnit(Player(fx.pid),'e029',GetUnitX(fx.caster),GetUnitY(fx.caster), AngleWBP(fx.caster,fx.TargetX ,fx.TargetY))
            endif
        endif

        //더미애니메이션속도
        call AnimationStart3(StackDummy[fx.pid], 0, fx.Aspeed)
        
        //유닛애니메이션속도
        call AnimationStart3(fx.caster,14, fx.Aspeed ) 
        
        set t.data = fx
        set Stack[fx.pid] = 1
        set i = GetRandomInt(1,3)
        if i == 1 then
            call Sound3D(fx.caster,'A031')
        elseif i == 2 then
            call Sound3D(fx.caster,'A031')
        elseif i == 3 then
            call Sound3D(fx.caster,'A031')
        endif

        if Player(fx.pid) == GetLocalPlayer() then
            call DzFrameSetText(CastingTextFrame,"명경지수")
            call DzFrameSetValue(CastingBar,0)
            call CastingBarShow(Player(fx.pid),true)
        endif
        set SDummy[fx.pid] =  DummyMagicleash2( fx.caster )
        if HeroSkillLevel[fx.pid][2] >= 2 then
            call t.start( (EffectTime / fx.Aspeed ) / 25, false, function EffectFunction )
        else
            call t.start( (EffectTime / fx.Aspeed ) / 25, false, function EffectFunction7 )
        endif
        //쿨변경
        call CooldownFIX(fx.caster,'A02K',HeroSkillCD2[14])
    endif
endfunction
    
private function ESyncData takes nothing returns nothing
    local player p=(DzGetTriggerSyncPlayer())
    local string data=(DzGetTriggerSyncData())
    local integer pid=GetPlayerId(p)
    local integer dataLen=StringLength(data)
    local integer valueLen
    local real x
    local real y
    local real angle
    
    if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID2[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
        if NarForm[pid] == 1 then
            set x=S2R(data)
            set valueLen=StringLength(R2S(x))
            set data=SubString(data,valueLen+1,dataLen)
            set dataLen=dataLen-(valueLen+1)
            set y=S2R(data)
            set pid=GetPlayerId(p)
            set angle = AngleWBP(MainUnit[pid],x,y)
            call SetUnitFacing(MainUnit[pid],angle)
            call EXSetUnitFacing(MainUnit[pid],angle)
            call IssuePointOrder( MainUnit[pid], "ambush", x, y )
        endif
    endif

    set p=null
endfunction

private function ESyncData2 takes nothing returns nothing
    local player p = DzGetTriggerSyncPlayer()
    local integer pid = GetPlayerId(p)
    local real x
    local real y
    local real angle
    local real speed
    local tick t
    local FxEffect fx

    if HeroSkillLevel[pid][2] >= 2 then
        if Stack[pid] == 0 then
            
        elseif Stack[pid] == 1 then
            set t = tick.create(0) 
            set fx = FxEffect.Create()
            set fx.pid = pid
            set fx.caster = MainUnit[fx.pid]
            set fx.i = 0
            set fx.r = 1 + ( 0.5 * NarStack[fx.pid] )
            if HeroSkillLevel[fx.pid][2] >= 1 then
                set fx.Aspeed = ((100+SkillSpeed(fx.pid))/100) * fx.r
            else
                set fx.Aspeed = ((100+SkillSpeed(fx.pid))/100)
            endif
            set fx.Aspeed = fx.Aspeed * Arcana_ChargeSpeed[fx.pid]
            set fx.A2speed = ((100+SkillSpeed(pid))/100)
            set t.data = fx
            set Stack[fx.pid] = 11
            call t.start( 0.02, false, function EffectFunction2 )
        elseif Stack[pid] == 2 then
            set t = tick.create(0) 
            set fx = FxEffect.Create()
            set fx.pid = pid
            set fx.caster = MainUnit[fx.pid]
            set fx.i = 0
            set fx.r = 1 + ( 0.5 * NarStack[fx.pid] )
            if HeroSkillLevel[fx.pid][2] >= 1 then
                set fx.Aspeed = ((100+SkillSpeed(fx.pid))/100) * fx.r
            else
                set fx.Aspeed = ((100+SkillSpeed(fx.pid))/100)
            endif
            set fx.Aspeed = fx.Aspeed * Arcana_ChargeSpeed[fx.pid]
            set fx.A2speed = ((100+SkillSpeed(pid))/100)
            set t.data = fx
            set Stack[fx.pid] = 12
            call t.start( 0.02, false, function EffectFunction2 )
        elseif Stack[pid] == 3 then
            set t = tick.create(0) 
            set fx = FxEffect.Create()
            set fx.pid = pid
            set fx.caster = MainUnit[fx.pid]
            set fx.i = 0
            set fx.r = 1 + ( 0.5 * NarStack[fx.pid] )
            if HeroSkillLevel[fx.pid][2] >= 1 then
                set fx.Aspeed = ((100+SkillSpeed(fx.pid))/100) * fx.r
            else
                set fx.Aspeed = ((100+SkillSpeed(fx.pid))/100)
            endif
            set fx.Aspeed = fx.Aspeed * Arcana_ChargeSpeed[fx.pid]
            set fx.A2speed = ((100+SkillSpeed(pid))/100)
            set t.data = fx
            set Stack[fx.pid] = 13
            call t.start( 0.02, false, function EffectFunction2 )
        elseif Stack[pid] == 4 then
            set t = tick.create(0) 
            set fx = FxEffect.Create()
            set fx.pid = pid
            set fx.caster = MainUnit[fx.pid]
            set fx.i = 0
            set fx.r = 1 + ( 0.5 * NarStack[fx.pid] )
            if HeroSkillLevel[fx.pid][2] >= 1 then
                set fx.Aspeed = ((100+SkillSpeed(fx.pid))/100) * fx.r
            else
                set fx.Aspeed = ((100+SkillSpeed(fx.pid))/100)
            endif
            set fx.Aspeed = fx.Aspeed * Arcana_ChargeSpeed[fx.pid]
            set fx.A2speed = ((100+SkillSpeed(pid))/100)
            set t.data = fx
            set Stack[fx.pid] = 14
            call t.start( 0.02, false, function EffectFunction2 )
        endif
    else
        if Stack[pid] == 1 then
            set t = tick.create(0) 
            set fx = FxEffect.Create()
            set fx.pid = pid
            set fx.caster = MainUnit[fx.pid]
            set fx.i = 0
            set fx.r = 1 + ( 0.5 * NarStack[fx.pid] )
            if HeroSkillLevel[fx.pid][2] >= 1 then
                set fx.Aspeed = ((100+SkillSpeed(fx.pid))/100) * fx.r
            else
                set fx.Aspeed = ((100+SkillSpeed(fx.pid))/100)
            endif
            set fx.Aspeed = fx.Aspeed * Arcana_ChargeSpeed[fx.pid]
            set fx.A2speed = ((100+SkillSpeed(pid))/100)
            set t.data = fx
            set Stack[fx.pid] = 11
            call t.start( 0.02, false, function EffectFunction8 )
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
    call DzTriggerRegisterSyncData(t,("NarE"),(false))
    call TriggerAddAction(t,function ESyncData)
    
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("NarE2"),(false))
    call TriggerAddAction(t,function ESyncData2)

    set t = null
//! runtextmacro 이벤트_끝()
endscope