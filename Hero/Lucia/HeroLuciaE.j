scope HeroLuciaE
globals
    
    private constant real SD = 15.00
    private constant real SD2 = 35.00
    
    //private constant real HeroSkillCD7[4] = 30.00 // 30.0
    
    private constant real Time = 0.30
    private constant real MoveTime = 0.20
    private constant real MoveD = 1000
    private constant real MoveD2 = 600
    private constant real MoveD3 = 800

    private constant real EffectTime = 0.5
    private constant real EffectTime2 = 2.0
    private constant real EffectTime3 = 1.0
    //잔상이펙트시간
    private constant real EffectTime4 = 0.16
    private constant real EffectTime5 = 0.16
    //풀차지
    private constant real EffectTime6 = 1.1
    
    private integer array Stack

    private constant real scale = 550
    private constant real distance = 450
    private constant real scale2 = 700
    private constant real distance2 = 550
endglobals

private function splashD takes nothing returns nothing
    local real Velue = 1.0
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer level = HeroSkillLevel[pid][17]
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        if level >= 1 then
            set Velue = Velue * 2.00
        endif
        
        call HeroDeal('A07C',splash.source,GetEnumUnit(),HeroSkillVelue3[17]*Velue,true,false,false,true)
    endif
endfunction

private function splashD2 takes nothing returns nothing
    local real Velue = 1.0
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer level = HeroSkillLevel[pid][17]
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance2) then
        if level >= 1 then
            set Velue = Velue * 2.00
        endif
        
        call HeroDeal('A07C',splash.source,GetEnumUnit(),HeroSkillVelue3[17]*Velue,true,false,false,true)
    endif
endfunction


//대태도 잔상
private function EffectFunction7 takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillFx fx = t.data
    local integer i
    local effect e
    local real x
    local real y

    set fx.i = fx.i + 1

    set x = fx.TargetX+PolarX( (MoveD3/5) * fx.i, fx.r)
    set y = fx.TargetY+PolarY( (MoveD3/5) * fx.i, fx.r)

    if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
        set e = AddSpecialEffect(".mdl", x, y)
    else
        if GetRandomInt(0,1) == 1 then
            set e = AddSpecialEffect("ZK_BM_Red knife shine4-Blue-1.mdl", x, y)
        else
            set e = AddSpecialEffect("ZK_BM_Red knife shine4-1.mdl", x, y)
        endif
    endif
    if fx.i == 1 or fx.i == 3 and fx.i != 5 then
        call EXEffectMatRotateZ(e, fx.r - 45)
        call EXEffectMatRotateX(e, GetRandomReal(-15,15))
        call EXSetEffectZ(e, EXGetEffectZ(e) + 100)
        call SetUnitVertexColorBJ( UnitEffectTime2('e05D',x+PolarX( 150, fx.r -45), y+PolarY( 150, fx.r - 45), (fx.r - 45), 0.7, 23, fx.pid) , 100, 100, 100, 50 )
    elseif fx.i != 5 then
        call EXEffectMatRotateZ(e, fx.r + 45)
        call EXEffectMatRotateX(e, GetRandomReal(-15,15))
        call EXSetEffectZ(e, EXGetEffectZ(e) + 100)
        call SetUnitVertexColorBJ( UnitEffectTime2('e05D',x+PolarX( 150, fx.r +45), y+PolarY( 150, fx.r + 45), (fx.r + 45), 0.7, 23, fx.pid) , 100, 100, 100, 50 )
    endif
    //call EXSetEffectSize(e, 1.25)
    call DestroyEffect(e)

    if fx.i != 5 then
        call t.start( EffectTime5/fx.speed, false, function EffectFunction7 )
    else
        //막타
        if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
            set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        else
            set e = AddSpecialEffect("ZK_BM_Red knife shine4-1.mdl",GetWidgetX(fx.caster)+PolarX( 0, GetUnitFacing(fx.caster)-180),GetWidgetY(fx.caster)+PolarY( 0, GetUnitFacing(fx.caster)-180))
        endif
        call EXEffectMatRotateZ(e, GetUnitFacing(fx.caster))
        call EXSetEffectSize(e, 1.75)
        call DestroyEffect(e)

        //D사용가능
        if not IsUnitDeadVJ(LuciaD[fx.pid]) then
            call KillUnit(LuciaD[fx.pid])
        endif
        set LuciaD[fx.pid] = CreateUnit(GetOwningPlayer(fx.caster),'e05L',0,0,0)

        set Stack[fx.pid] = 0
        call fx.Stop()
        call t.destroy()
    endif
endfunction

//대태도 돌진2
private function EffectFunction8 takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillFx fx = t.data
    local integer i
    local effect e
    local real distancePerTick = 0
    local real remainingDistance = 0
    local real x = 0
    local real y = 0

    set fx.r = fx.r + 0.03125

    if fx.r >= MoveTime/fx.speed then
        set fx.i = 0
        set fx.r = GetUnitFacing(fx.caster)
            
        set fx.i = fx.i + 1

        set x = fx.TargetX+PolarX( (MoveD3/5) * fx.i, fx.r)
        set y = fx.TargetY+PolarY( (MoveD3/5) * fx.i, fx.r)

        if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
            set e = AddSpecialEffect(".mdl", x, y)
        else
            if GetRandomInt(0,1) == 1 then
                set e = AddSpecialEffect("ZK_BM_Red knife shine4-Blue-1.mdl", x, y)
            else
                set e = AddSpecialEffect("ZK_BM_Red knife shine4-1.mdl", x, y)
            endif
        endif
        if fx.i == 1 or fx.i == 3 then
            call EXEffectMatRotateZ(e, fx.r - 45)
            call EXEffectMatRotateX(e, GetRandomReal(-20,15))
            call EXSetEffectZ(e, EXGetEffectZ(e) + 100)
            call SetUnitVertexColorBJ( UnitEffectTime2('e05D',x+PolarX( 150, fx.r -45), y+PolarY( 150, fx.r - 45), (fx.r - 45), 0.7, 23, fx.pid) , 100, 100, 100, 50 )
        else
            call EXEffectMatRotateZ(e, fx.r + 45)
            call EXEffectMatRotateX(e, GetRandomReal(-15,15))
            call EXSetEffectZ(e, EXGetEffectZ(e) + 100)
            call SetUnitVertexColorBJ( UnitEffectTime2('e05D',x+PolarX( 150, fx.r +45), y+PolarY( 150, fx.r + 45), (fx.r + 45), 0.7, 23, fx.pid) , 100, 100, 100, 50 )
        endif
        //call EXSetEffectSize(e, 1.25)
        call DestroyEffect(e)
        
        call t.start( EffectTime5/fx.speed , false, function EffectFunction7 ) 
    else
        set distancePerTick = ((MoveD2 * fx.speed) / MoveTime) * 0.03125
        call SetUnitSafePolarUTA(fx.caster, distancePerTick , GetUnitFacing(fx.caster))
        set fx.r2 = fx.r2 + distancePerTick
        call t.start( 0.03125, false, function EffectFunction8 ) 
    endif
endfunction

//대태도 돌진
private function EffectFunction4 takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillFx fx = t.data
    local integer i
    local effect e
    local real distancePerTick = 0
    local real remainingDistance = 0
    set fx.r = fx.r + 0.03125

    if fx.r >= MoveTime/fx.speed then
        if GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
            set remainingDistance = MoveD2 - fx.r2
            if remainingDistance > 0 then
                call SetUnitSafePolarUTA(fx.caster, remainingDistance, GetUnitFacing(fx.caster))
            endif
            set fx.r2 = fx.r2 + remainingDistance
            if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
            else
                set e = AddSpecialEffect("ZK_BM_Red knife shine4-1.mdl",GetWidgetX(fx.caster)+PolarX( 0, GetUnitFacing(fx.caster)-180),GetWidgetY(fx.caster)+PolarY( 0, GetUnitFacing(fx.caster)-180))
            endif
            call EXEffectMatRotateZ(e, GetUnitFacing(fx.caster))
            call EXSetEffectSize(e, 1.75)
            call DestroyEffect(e)
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale2, function splashD2 )
        endif
        set Stack[fx.pid] = 0
        call fx.Stop()
        call t.destroy()
    else
        set distancePerTick = ((MoveD2 * fx.speed) / MoveTime) * 0.03125
        call SetUnitSafePolarUTA(fx.caster, distancePerTick , GetUnitFacing(fx.caster))
        set fx.r2 = fx.r2 + distancePerTick
        call t.start( 0.03125, false, function EffectFunction4 ) 
    endif
endfunction

//소태도 돌진
private function EffectFunction3 takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillFx fx = t.data
    local integer i
    local effect e
    local real distancePerTick = 0
    local real remainingDistance = 0
    set fx.r = fx.r + 0.03125

    if fx.r >= MoveTime/fx.speed then
        if GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
            set remainingDistance = MoveD - fx.r2
            if remainingDistance > 0 then
                call SetUnitSafePolarUTA(fx.caster, remainingDistance, GetUnitFacing(fx.caster))
            endif
            set fx.r2 = fx.r2 + remainingDistance
            if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
            else
                set e = AddSpecialEffect("ZK_BM_Red knife shine4-1.mdl",GetWidgetX(fx.caster)+PolarX( 0, GetUnitFacing(fx.caster)-180),GetWidgetY(fx.caster)+PolarY( 0, GetUnitFacing(fx.caster)-180))
            endif
            call EXEffectMatRotateZ(e, GetUnitFacing(fx.caster))
            call EXSetEffectSize(e, 1.25)
            call DestroyEffect(e)
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale, function splashD )
        endif
        set Stack[fx.pid] = 0
        call fx.Stop()
        call t.destroy()
    else
        set distancePerTick = ((MoveD * fx.speed) / MoveTime) * 0.03125
        call SetUnitSafePolarUTA(fx.caster, distancePerTick , GetUnitFacing(fx.caster))
        set fx.r2 = fx.r2 + distancePerTick
        call t.start( 0.03125, false, function EffectFunction3 ) 
    endif
endfunction

//소태도 잔상
private function EffectFunction6 takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillFx fx = t.data
    local integer i
    local effect e
    local real x
    local real y

    set fx.i = fx.i + 1

    set x = fx.TargetX+PolarX( (MoveD/5) * (fx.i-1), fx.r)
    set y = fx.TargetY+PolarY( (MoveD/5) * (fx.i-1), fx.r)

    if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
        set e = AddSpecialEffect(".mdl", x, y)
    else
        set e = AddSpecialEffect("tx-shqy10-E.mdl", x, y)
    endif
    if fx.i == 1 or fx.i == 3 or fx.i == 5 then
        call EXEffectMatRotateZ(e, fx.r - 60)
        call SetUnitVertexColorBJ( UnitEffectTime2('e05D',x+PolarX( 285, fx.r -60), y+PolarY( 285, fx.r - 60), (fx.r - 60), 0.7, 4, fx.pid) , 100, 100, 100, 50 )
    else
        call EXEffectMatRotateZ(e, fx.r + 60)
        call SetUnitVertexColorBJ( UnitEffectTime2('e05D',x+PolarX( 285, fx.r +60), y+PolarY( 285, fx.r + 60), (fx.r + 60), 0.7, 4, fx.pid) , 100, 100, 100, 50 )
    endif
    //call EXSetEffectSize(e, 1.25)
    call DestroyEffect(e)

    if fx.i != 5 then
        call t.start( EffectTime4/fx.speed, false, function EffectFunction6 )
    else
        //R사용가능
        if not IsUnitDeadVJ(LuciaR[fx.pid]) then
            call KillUnit(LuciaR[fx.pid])
        endif
        set LuciaR[fx.pid] = CreateUnit(GetOwningPlayer(fx.caster),'e05J',0,0,0)

        set Stack[fx.pid] = 0
        call fx.Stop()
        call t.destroy()
    endif
endfunction

//소태도 돌진2
private function EffectFunction5 takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillFx fx = t.data
    local integer i
    local effect e
    local real distancePerTick = 0
    local real remainingDistance = 0
    local real x 
    local real y 

    set fx.r = fx.r + 0.03125

    if fx.r >= MoveTime/fx.speed then
        /*
        if GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
            set remainingDistance = MoveD - fx.r2
            if remainingDistance > 0 then
                call SetUnitSafePolarUTA(fx.caster, remainingDistance, GetUnitFacing(fx.caster))
            endif
            set fx.r2 = fx.r2 + remainingDistance
            if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
            else
                set e = AddSpecialEffect("ZK_BM_Red knife shine4-1.mdl",GetWidgetX(fx.caster)+PolarX( 0, GetUnitFacing(fx.caster)-180),GetWidgetY(fx.caster)+PolarY( 0, GetUnitFacing(fx.caster)-180))
            endif
            call EXEffectMatRotateZ(e, GetUnitFacing(fx.caster))
            call EXSetEffectSize(e, 1.25)
            call DestroyEffect(e)
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale, function splashD )
        endif
        */
        set fx.i = 0
        set fx.r = GetUnitFacing(fx.caster)
            
        /*
        set fx.i = fx.i + 1

        set x = fx.TargetX+PolarX( (MoveD/5) * fx.i, fx.r)
        set y = fx.TargetY+PolarY( (MoveD/5) * fx.i, fx.r)

        if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
            set e = AddSpecialEffect(".mdl", x, y)
        else
            set e = AddSpecialEffect("tx-shqy10-E.mdl", x, y)
        endif
        if fx.i == 1 or fx.i == 3 then
            call EXEffectMatRotateZ(e, fx.r - 60)
            call SetUnitVertexColorBJ( UnitEffectTime2('e05D',x+PolarX( 285, fx.r -60), y+PolarY( 285, fx.r - 60), (fx.r - 60), 0.7, 4, fx.pid) , 100, 100, 100, 50 )
        else
            call EXEffectMatRotateZ(e, fx.r + 60)
            call SetUnitVertexColorBJ( UnitEffectTime2('e05D',x+PolarX( 285, fx.r +60), y+PolarY( 285, fx.r + 60), (fx.r + 60), 0.7, 4, fx.pid) , 100, 100, 100, 50 )
        endif
        //call EXSetEffectSize(e, 1.25)
        call DestroyEffect(e)
        */
        call t.start( EffectTime4/fx.speed , false, function EffectFunction6 ) 
    else
        set distancePerTick = ((MoveD * fx.speed) / MoveTime) * 0.03125
        call SetUnitSafePolarUTA(fx.caster, distancePerTick , GetUnitFacing(fx.caster))
        set fx.r2 = fx.r2 + distancePerTick
        call t.start( 0.03125, false, function EffectFunction5 ) 
    endif
endfunction

private function EffectFunction2 takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillFx fx = t.data
    local string data
    local integer random
    local effect e
        
    if fx.caster != null and IsUnitDeadVJ(fx.caster) == false then
        if Stack[fx.pid] == 10 then
            if fx.i < 25 then
                if LuciaForm[fx.pid] == 0 then
                    call PauseUnitEx(fx.caster, false)
                    call Sound3D(fx.caster,'A07O')
                    //call AnimationStart3(fx.caster,3, fx.speed)
                    call AnimationStart3(fx.caster,15, fx.speed)

                    if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                        set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                    else
                        set e = AddSpecialEffect("ad1565f30e619287.mdl",GetWidgetX(fx.caster)+PolarX( 0, GetUnitFacing(fx.caster)-180),GetWidgetY(fx.caster)+PolarY( 0, GetUnitFacing(fx.caster)-180))
                    endif
                    call EXEffectMatRotateZ(e, GetUnitFacing(fx.caster))
                    call EXSetEffectSize(e, 2.0)
                    call DestroyEffect(e)

                    if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                        set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                    else
                        set e = AddSpecialEffect("Light_Hit-2-Red.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                    endif
                    call EXEffectMatRotateZ(e, GetUnitFacing(fx.caster))
                    call EXSetEffectZ(e,EXGetEffectZ(e)+100)
                    call DestroyEffect(e)

                    if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                        set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                    else
                        set e = AddSpecialEffect("tx-shqy21.mdl",GetWidgetX(fx.caster)+PolarX( 512, GetUnitFacing(fx.caster)),GetWidgetY(fx.caster)+PolarY( 512, GetUnitFacing(fx.caster)))
                    endif
                    call EXSetEffectSize(e, 5.0)
                    call EXEffectMatRotateZ(e, GetUnitFacing(fx.caster))
                    call EXSetEffectZ(e,EXGetEffectZ(e)+25)
                    call DestroyEffect(e)

                    call DummyMagicleash(fx.caster, (EffectTime3 /fx.speed))
                    call BuffNoST.Apply( fx.caster, (EffectTime3 /fx.speed), 0 )

                    set fx.r = 0
                    call t.start( 0.03125, false, function EffectFunction3 )
                else
                    call PauseUnitEx(fx.caster, false)
                    call Sound3D(fx.caster,'A07Q')
                    call AnimationStart3(fx.caster,21, fx.speed)

                    if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                        set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                    else
                        set e = AddSpecialEffect("ad1565f30e619287.mdl",GetWidgetX(fx.caster)+PolarX( 0, GetUnitFacing(fx.caster)-180),GetWidgetY(fx.caster)+PolarY( 0, GetUnitFacing(fx.caster)-180))
                    endif
                    call EXEffectMatRotateZ(e, GetUnitFacing(fx.caster))
                    call EXSetEffectSize(e, 2.0)
                    call DestroyEffect(e)

                    call DummyMagicleash(fx.caster, (EffectTime3 /fx.speed))
                    call BuffNoST.Apply( fx.caster, (EffectTime3 /fx.speed), 0 )

                    set fx.r = 0
                    call t.start( 0.03125, false, function EffectFunction4 )
                endif
            elseif fx.i == 25 then

                set LuciaVelue[fx.pid] = 0
                if Player(fx.pid) == GetLocalPlayer() then
                    if LuciaForm[fx.pid] == 1 then
                        call DzFrameSetValue(LuciaAden2, 0)
                    else
                        call DzFrameSetValue(LuciaAden, 0)
                    endif
                endif

                if LuciaForm[fx.pid] == 0 then
                    call PauseUnitEx(fx.caster, false)
                    call Sound3D(fx.caster,'A07P')
                    //call AnimationStart3(fx.caster,3, fx.speed)
                    call AnimationStart3(fx.caster,15, fx.speed)

                    if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                        set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                    else
                        set e = AddSpecialEffect("ad1565f30e619287.mdl",GetWidgetX(fx.caster)+PolarX( 0, GetUnitFacing(fx.caster)-180),GetWidgetY(fx.caster)+PolarY( 0, GetUnitFacing(fx.caster)-180))
                    endif
                    call EXEffectMatRotateZ(e, GetUnitFacing(fx.caster))
                    call EXSetEffectSize(e, 2.0)
                    call DestroyEffect(e)

                    if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                        set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                    else
                        set e = AddSpecialEffect("Light_Hit-2-Red.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                    endif
                    call EXEffectMatRotateZ(e, GetUnitFacing(fx.caster))
                    call EXSetEffectZ(e,EXGetEffectZ(e)+100)
                    call DestroyEffect(e)

                    if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                        set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                    else
                        set e = AddSpecialEffect("tx-shqy21.mdl",GetWidgetX(fx.caster)+PolarX( 512, GetUnitFacing(fx.caster)),GetWidgetY(fx.caster)+PolarY( 512, GetUnitFacing(fx.caster)))
                    endif
                    call EXSetEffectSize(e, 5.0)
                    call EXEffectMatRotateZ(e, GetUnitFacing(fx.caster))
                    call EXSetEffectZ(e,EXGetEffectZ(e)+25)
                    call DestroyEffect(e)

                    call DummyMagicleash(fx.caster, (EffectTime6 /fx.speed))
                    call BuffNoST.Apply( fx.caster, (EffectTime6 /fx.speed), 0 )

                    set fx.TargetX = GetWidgetX(fx.caster)
                    set fx.TargetY = GetWidgetY(fx.caster)

                    set fx.r = 0
                    call t.start( 0.03125, false, function EffectFunction5 )
                else
                    call PauseUnitEx(fx.caster, false)
                    call Sound3D(fx.caster,'A07R')
                    call AnimationStart3(fx.caster,21, fx.speed)
                    /*
                    if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                        set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                    else
                        set e = AddSpecialEffect("ad1565f30e619287.mdl",GetWidgetX(fx.caster)+PolarX( 0, GetUnitFacing(fx.caster)-180),GetWidgetY(fx.caster)+PolarY( 0, GetUnitFacing(fx.caster)-180))
                    endif
                    call EXEffectMatRotateZ(e, GetUnitFacing(fx.caster))
                    call EXSetEffectSize(e, 2.0)
                    call DestroyEffect(e)
                    */
                    call DummyMagicleash(fx.caster, (EffectTime6 /fx.speed))
                    call BuffNoST.Apply( fx.caster, (EffectTime6 /fx.speed), 0 )

                    set fx.TargetX = GetWidgetX(fx.caster)
                    set fx.TargetY = GetWidgetY(fx.caster)

                    set fx.r = 0
                    call t.start( 0.03125, false, function EffectFunction8 )
                endif




                //set Stack[fx.pid] = 0
                //call fx.Stop()
                //call t.destroy()
            endif
        endif
    else
        set Stack[fx.pid] = 0
        call fx.Stop()
        call t.destroy()
    endif
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillFx fx = t.data
    local string data
    local effect e
    
    if fx.i == fx.j then
        call AnimationStart3(fx.caster, 14, fx.speed)
        set Stack[fx.pid] = 1
        if fx.i == 25 then
            call Sound3D(fx.caster,'A07N')

            call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
            set Stack[fx.pid] = 2
            if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
            else
                set e = AddSpecialEffectTarget("Effect_Invisibility_Target_Wave_Blue2.mdl",fx.caster,"hand left")
            endif
            call DestroyEffect(e)
            if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
            else
                set e = AddSpecialEffectTarget("Effect_Invisibility_Target_Wave_Blue2.mdl",fx.caster,"hand left")
            endif
            call DestroyEffect(e)
            set e = null
            set LuciaVelue[fx.pid] = fx.i
            if Player(fx.pid) == GetLocalPlayer() then
                if LuciaForm[fx.pid] == 1 then
                    call DzFrameSetValue(LuciaAden2, fx.i)
                else
                    call DzFrameSetValue(LuciaAden, fx.i)
                endif
            endif
            //call DummyMagicleash(fx.caster, 0.3)
            call BuffNoST.Apply( fx.caster, 0.3, 0 )
            call t.start( 0.3, false, function EffectFunction )
        endif
    endif

    set fx.i = fx.i + 1
    
    if fx.caster != null and IsUnitDeadVJ(fx.caster) == false and GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
        if Stack[fx.pid] == 1 or Stack[fx.pid] == 2 or Stack[fx.pid] == 3 then
            set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
            call DzSyncData(("LuciaEM"),data)
            if fx.i < 25 then
                set LuciaVelue[fx.pid] = fx.i
                if Player(fx.pid) == GetLocalPlayer() then
                    if LuciaForm[fx.pid] == 1 then
                        call DzFrameSetValue(LuciaAden2, fx.i)
                    else
                        call DzFrameSetValue(LuciaAden, fx.i)
                    endif
                endif
                //call DummyMagicleash(fx.caster, (EffectTime2 /fx.speed)/25)
                call BuffNoST.Apply( fx.caster, (EffectTime2 /fx.speed)/25, 0 )
                call t.start( (EffectTime2 /fx.speed)/25, false, function EffectFunction )
            elseif fx.i == 25 then
                call Sound3D(fx.caster,'A07N')

                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
                set Stack[fx.pid] = 2
                if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                    set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                else
                    set e = AddSpecialEffectTarget("Effect_Invisibility_Target_Wave_Blue2.mdl",fx.caster,"hand left")
                endif
                call DestroyEffect(e)
                if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                    set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                else
                    set e = AddSpecialEffectTarget("Effect_Invisibility_Target_Wave_Blue2.mdl",fx.caster,"hand left")
                endif
                call DestroyEffect(e)
                set e = null
                set LuciaVelue[fx.pid] = fx.i
                if Player(fx.pid) == GetLocalPlayer() then
                    if LuciaForm[fx.pid] == 1 then
                        call DzFrameSetValue(LuciaAden2, fx.i)
                    else
                        call DzFrameSetValue(LuciaAden, fx.i)
                    endif
                endif
                //call DummyMagicleash(fx.caster, 0.3)
                call BuffNoST.Apply( fx.caster, 0.3, 0 )
                call t.start( 0.3, false, function EffectFunction )
            elseif fx.i == 26 then
                if Stack[fx.pid] == 2 then
                    set fx.i = 25
                    set Stack[fx.pid] = 10
                    //call DummyMagicleash(fx.caster, 0.02)
                    call BuffNoST.Apply( fx.caster, 0.02, 0 )
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
    if GetSpellAbilityId() == 'A07C' then
        call SetUnitFacing(GetTriggerUnit(), AngleWBP(GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() ))
        call EXSetUnitFacing(GetTriggerUnit(), AngleWBP(GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() ))
        set t = tick.create(0) 
        set fx = SkillFx.Create()
        set fx.caster = GetTriggerUnit()
        set fx.TargetX = GetSpellTargetX()
        set fx.TargetY = GetSpellTargetY()
        set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set fx.i = LuciaVelue[fx.pid]
        set fx.j = LuciaVelue[fx.pid]
        set fx.speed = ((100+SkillSpeed(fx.pid))/100)
        
        set fx.speed = fx.speed * Arcana_ChargeSpeed[fx.pid]
        
        call AnimationStart3(fx.caster,13, fx.speed)
        
        set t.data = fx
        set Stack[fx.pid] = 0
        /*
        if Player(fx.pid) == GetLocalPlayer() then
            call DzFrameSetText(CastingTextFrame,"적소·절영")
            call DzFrameSetValue(CastingBar,0)
            call CastingBarShow(Player(fx.pid),true)
        endif
        */
        //call DummyMagicleash(fx.caster, (EffectTime /fx.speed))
        call PauseUnitEx(fx.caster, true)
        call BuffNoST.Apply( fx.caster, (EffectTime /fx.speed), 0 )
        call t.start( (EffectTime /fx.speed), false, function EffectFunction )

        //call CooldownFIX(fx.caster,'A07C',HeroSkillCD3[4])
        call CooldownFIX(fx.caster,'A07C', 5)
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
        call IssuePointOrder( MainUnit[pid], "ambush", x, y )
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
    local SkillFx fx
    
    if Stack[pid] == 0 then
    elseif Stack[pid] == 1 then
        set t = tick.create(0) 
        set fx = SkillFx.Create()
        set fx.pid = pid
        set fx.caster = MainUnit[fx.pid]
        set fx.i = LuciaVelue[fx.pid]
        set fx.speed = ((100+SkillSpeed(fx.pid))/100)
        set t.data = fx
        set Stack[fx.pid] = 10
        call t.start( 0.02, false, function EffectFunction2 )
    endif
    
    set p=null
endfunction

private function ESyncData3 takes nothing returns nothing
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
        
    if Stack[pid] == 1 or Stack[pid] == 2 then
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
    call DzTriggerRegisterSyncData(t,("LuciaE"),(false))
    call TriggerAddAction(t,function ESyncData)
    
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("LuciaE2"),(false))
    call TriggerAddAction(t,function ESyncData2)
    
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("LuciaEM"),(false))
    call TriggerAddAction(t,function ESyncData3)
    
    set t = null
//! runtextmacro 이벤트_끝()
endscope

