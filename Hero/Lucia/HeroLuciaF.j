scope HeroLuciaF
globals
endglobals

private struct SkillRarR
    unit caster
    integer pid
endstruct

private function EffectF takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillFx fx = t.data

    call SelectUnitForPlayerSingle(fx.caster,Player(fx.pid))

    set fx.caster = null

    call fx.Stop()
    call t.destroy()
endfunction

private function EffectFunction2 takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillFx fx = t.data
    local real r

    set fx.i = fx.i + 1

    if fx.i == 8 then
        call SetUnitSafeXY(fx.caster, fx.TargetX + PolarX( 600, fx.r - 180 ), fx.TargetY + PolarY( 600, fx.r - 180 ) )
        call UnitEffectTime2('e055',fx.TargetX2,fx.TargetY2,GetUnitFacing(fx.caster),2.4,0,fx.pid)
        call fx.Stop()
        call t.destroy()
    else
        call t.start( 0.03125, false, function EffectFunction2 ) 
        call SetUnitSafeXY(fx.caster, fx.TargetX + PolarX( 600, fx.r-(22.5*fx.i) ), fx.TargetY + PolarY( 600, fx.r-(22.5*fx.i) ) )
    endif
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillFx fx = t.data
    local effect e
    local real r
    local real r2
    local tick t2
    local SkillFx fx2
    
    set fx.i = fx.i + 1

    if fx.i < 44 then
        if GetRandomInt(0,1) == 0 then
            set r = GetRandomReal(0,360)
            set r2 = GetRandomReal(0,SquareRoot(500*500))
            //call UnitEffectTime2('e04A',fx.TargetX+PolarX( r2, r ),fx.TargetY+PolarY( r2, r ),GetRandomReal(0,360),1.5,0,fx.pid)

            if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster)+PolarX( r2, r ),GetWidgetY(fx.caster)+PolarY( r2, r ))
            else
                set e = AddSpecialEffect("sl_e6bb08d.mdl",GetWidgetX(fx.caster)+PolarX( r2, r ),GetWidgetY(fx.caster)+PolarY( r2, r ))
            endif
            call DestroyEffect(e)
        else
            set r = GetRandomReal(0,360)
            set r2 = GetRandomReal(0,SquareRoot(500*500))
            //call UnitEffectTime2('e04A',fx.TargetX+PolarX( r2, r ),fx.TargetY+PolarY( r2, r ),GetRandomReal(0,360),1.5,0,fx.pid)

            if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster)+PolarX( r2, r ),GetWidgetY(fx.caster)+PolarY( r2, r ))
            else
                set e = AddSpecialEffect("fuwen_xinghongshandian.mdl",GetWidgetX(fx.caster)+PolarX( r2, r ),GetWidgetY(fx.caster)+PolarY( r2, r ))
            endif
            call DestroyEffect(e)
        endif
        call t.start( 0.05, false, function EffectFunction ) 
    else
        call t.start( 0.05, false, function EffectFunction ) 
    endif

    if fx.i == 9 then
        call UnitEffectTime2('e051',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetUnitFacing(fx.caster),2.0,0,fx.pid)
    elseif fx.i == 48 then
        //카메라 변경
        call SetCameraFieldForPlayer(Player(fx.pid),CAMERA_FIELD_ZOFFSET,0,0)
        call SetCameraFieldForPlayer(Player(fx.pid),CAMERA_FIELD_ROTATION,90,0)
        call SetCameraFieldForPlayer(Player(fx.pid),CAMERA_FIELD_TARGET_DISTANCE,3500,0)
        call SetCameraFieldForPlayer(Player(fx.pid),CAMERA_FIELD_ANGLE_OF_ATTACK,304,0)

        set arrayPlayerCameraBoolean[fx.pid] = false
        set r = GetUnitFacing(fx.caster)
        call UnitEffectTime2('e056',GetWidgetX(fx.caster)+PolarX( 512, GetUnitFacing(fx.caster)),GetWidgetY(fx.caster)+PolarY( 512, GetUnitFacing(fx.caster)),GetUnitFacing(fx.caster),2.4,0,fx.pid)

        call t.start( 1.6, false, function EffectFunction ) 
        set fx.TargetX = GetWidgetX(fx.caster) + PolarX( 600, GetUnitFacing(fx.caster) )
        set fx.TargetY = GetWidgetY(fx.caster) + PolarY( 600, GetUnitFacing(fx.caster) )

        set t2 = tick.create(fx.pid) 
        set fx2 = SkillFx.Create()
        set fx2.caster = fx.caster
        set fx2.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set t2.data = fx2
        set fx2.i = 0
        set fx2.r = GetUnitFacing(fx.caster) - 180
        set fx2.r2 = 0
        set fx2.TargetX = GetWidgetX(fx.caster) + PolarX( 600, GetUnitFacing(fx.caster))
        set fx2.TargetY = GetWidgetY(fx.caster) + PolarY( 600, GetUnitFacing(fx.caster))
        set fx2.TargetX2 = GetWidgetX(fx.caster) + PolarX( 200, GetUnitFacing(fx.caster)+50)
        set fx2.TargetY2 = GetWidgetY(fx.caster) + PolarY( 200, GetUnitFacing(fx.caster)+50)
        call t2.start( 0.03125, false, function EffectFunction2 ) 

    elseif fx.i == 49 then
        if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
            set e = AddSpecialEffect(".mdl", fx.TargetX, fx.TargetY )
        else
            set e = AddSpecialEffect("ZK_BM_Mine blasting.mdl", fx.TargetX, fx.TargetY)
        endif
        call EXSetEffectSize(e, 1.5)
        call DestroyEffect(e)
        call fx.Stop()
        call t.destroy()
    endif

endfunction

private function Main takes nothing returns nothing
    local integer pid
    local tick t
    local SkillFx fx
    local effect e
    local real r
    local real r2

    if GetSpellAbilityId() == 'A07H' then
        call SetUnitFacing(GetTriggerUnit(), AngleWBP(GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() ))
        call EXSetUnitFacing(GetTriggerUnit(), AngleWBP(GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() ))
        set pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        
        call Overlay2Count(pid,'A07H')

        //포트레잇변경
        set t = tick.create(pid) 
        set fx = SkillFx.Create()
        set fx.caster = GetTriggerUnit()
        set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set fx.speed = ((100+SkillSpeed(fx.pid))/100)
        set t.data = fx
        call t.start( 0.05, false, function EffectF ) 
        call ClearSelectionForPlayer(Player(pid))

        set t = tick.create(pid) 
        set fx = SkillFx.Create()
        set fx.caster = GetTriggerUnit()
        set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set t.data = fx
        call t.start( 0.05, false, function EffectF ) 

        set LuciaForm[fx.pid] = 0
        set LuciaVelue[fx.pid] = 0
        if Player(fx.pid) == GetLocalPlayer() then
            if LuciaForm[fx.pid] == 1 then
                call DzFrameSetValue(LuciaAden2, 0)
            else
                call DzFrameSetValue(LuciaAden, 0)
            endif
        endif
        call AddUnitAnimationProperties(fx.caster, "Alternate", false)

        call LuciaAdenShow(Player(fx.pid),1,true)
        
        //카메라 변경
        set arrayPlayerCameraBoolean[fx.pid] = true
        if GetLocalPlayer() == Player(pid) then
            //call SetCameraField( CAMERA_FIELD_TARGET_DISTANCE, 500, 0.00 )
            //call SetCameraPosition(GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        endif
        call SetCameraEyePositionForPlayer(Player(pid),GetWidgetX(fx.caster)+PolarX( 250, GetUnitFacing(fx.caster)),GetWidgetY(fx.caster)+PolarY( 250, GetUnitFacing(fx.caster)),500)
        call SetCameraTargetPositionForPlayer(Player(pid),GetWidgetX(fx.caster),GetWidgetY(fx.caster),0)
        call AdjustCameraSettingsForPlayer(Player(pid),0)
        call SetCameraEyePositionForPlayer(Player(pid),GetWidgetX(fx.caster)+PolarX( 250, GetUnitFacing(fx.caster)-90),GetWidgetY(fx.caster)+PolarY( 250, GetUnitFacing(fx.caster)-90),500)
        call SetCameraTargetPositionForPlayer(Player(pid),GetWidgetX(fx.caster),GetWidgetY(fx.caster),0)
        call AdjustCameraSettingsForPlayer(Player(pid),2.4)
        call SetCameraField( CAMERA_FIELD_TARGET_DISTANCE, 1000, 1.3 )

        //특수효과
        call UnitEffectTime2('e052',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetUnitFacing(fx.caster),2.4,0,fx.pid)
        
        set r = GetRandomReal(0,360)
        set r2 = GetRandomReal(0,SquareRoot(500*500))
        //call UnitEffectTime2('e04A',fx.TargetX+PolarX( r2, r ),fx.TargetY+PolarY( r2, r ),GetRandomReal(0,360),1.5,0,fx.pid)

        if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
            set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster)+PolarX( r2, r ),GetWidgetY(fx.caster)+PolarY( r2, r ))
        else
            set e = AddSpecialEffect("sl_e6bb08d.mdl",GetWidgetX(fx.caster)+PolarX( r2, r ),GetWidgetY(fx.caster)+PolarY( r2, r ))
        endif
        call DestroyEffect(e)
        
        set r = GetRandomReal(0,360)
        set r2 = GetRandomReal(0,SquareRoot(500*500))
        //call UnitEffectTime2('e04A',fx.TargetX+PolarX( r2, r ),fx.TargetY+PolarY( r2, r ),GetRandomReal(0,360),1.5,0,fx.pid)

        if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
            set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster)+PolarX( r2, r ),GetWidgetY(fx.caster)+PolarY( r2, r ))
        else
            set e = AddSpecialEffect("fuwen_xinghongshandian.mdl",GetWidgetX(fx.caster)+PolarX( r2, r ),GetWidgetY(fx.caster)+PolarY( r2, r ))
        endif
        call DestroyEffect(e)
    

        //애니
        call AnimationStart3(fx.caster, 18, 1.0)
        
        //사운드
        call Sound3D(fx.caster,'A07J')

        call DummyMagicleash(fx.caster, 4.9)


        set t = tick.create(pid) 
        set fx = SkillFx.Create()
        set fx.caster = GetTriggerUnit()
        set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set t.data = fx
        set fx.i = 0
        call t.start( 0.05, false, function EffectFunction ) 

        call CooldownFIX(fx.caster,'A07H',5)
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

    set p=null
endfunction

            
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("LuciaF"),(false))
    call TriggerAddAction(t,function FSyncData)

    set t = null
//! runtextmacro 이벤트_끝()
endscope

