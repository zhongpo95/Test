scope HeroLuciaR
globals
endglobals

private function EffectF takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillFx fx = t.data

    call SelectUnitForPlayerSingle(fx.caster,Player(fx.pid))

    set fx.caster = null

    call fx.Stop()
    call t.destroy()
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillFx fx = t.data
    local effect e
    
    set fx.i = fx.i + 1

    if fx.i == 1 then
        //특수효과
        if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
            set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        else
            set e = AddSpecialEffect("ZK_BM_Lightningexplosion_tiao3.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        endif
        //call EXSetEffectSize(e,1.0)
        call EXSetEffectZ(e, EXGetEffectZ(e) + 175)
        call DestroyEffect(e)

        //특수효과
        if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
            set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        else
            set e = AddSpecialEffect("ZK_BM_Lightningexplosion_tiao3-2.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        endif
        call DestroyEffect(e)
        call t.start( 0.25, false, function EffectFunction ) 
    else
        //카메라 변경
        call SetCameraFieldForPlayer(Player(fx.pid),CAMERA_FIELD_ZOFFSET,0,0.5)
        call SetCameraFieldForPlayer(Player(fx.pid),CAMERA_FIELD_ROTATION,90,0.5)
        call SetCameraFieldForPlayer(Player(fx.pid),CAMERA_FIELD_TARGET_DISTANCE,3500,0.5)
        call SetCameraFieldForPlayer(Player(fx.pid),CAMERA_FIELD_ANGLE_OF_ATTACK,304,0.5)

        call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 5 )
        set arrayPlayerCameraBoolean[fx.pid] = false

        call fx.Stop()
        call t.destroy()
    endif

endfunction

private function Main takes nothing returns nothing
    local integer pid
    local tick t
    local SkillFx fx
    local effect e

    if GetSpellAbilityId() == 'A07D' then
        call SetUnitFacing(GetTriggerUnit(), AngleWBP(GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() ))
        call EXSetUnitFacing(GetTriggerUnit(), AngleWBP(GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() ))
        set pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        
        call Overlay2Count(pid,'A07D')
        
        //포트레잇변경
        set t = tick.create(pid) 
        set fx = SkillFx.Create()
        set fx.caster = GetTriggerUnit()
        set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set fx.speed = ((100+SkillSpeed(fx.pid))/100)
        set t.data = fx
        call t.start( 0.05, false, function EffectF ) 
        call ClearSelectionForPlayer(Player(pid))

        set LuciaForm[fx.pid] = 1
        set LuciaVelue[fx.pid] = 0
        if Player(fx.pid) == GetLocalPlayer() then
            if LuciaForm[fx.pid] == 1 then
                call DzFrameSetValue(LuciaAden2, 0)
            else
                call DzFrameSetValue(LuciaAden, 0)
            endif
        endif
        call AddUnitAnimationProperties(fx.caster, "Alternate", true)

        call LuciaAdenShow(Player(fx.pid),2,true)

        //대태도스킬 사용가능
        if not IsUnitDeadVJ(LuciaFormUnit[fx.pid]) then
            call KillUnit(LuciaFormUnit[fx.pid])
        endif
        set LuciaFormUnit[fx.pid] = CreateUnit(GetOwningPlayer(fx.caster),'e05I',0,0,0)
        
        //R사용불가
        if not IsUnitDeadVJ(LuciaR[fx.pid]) then
            call KillUnit(LuciaR[fx.pid])
        endif

        //카메라 변경
        set arrayPlayerCameraBoolean[fx.pid] = true
        if GetLocalPlayer() == Player(pid) then
            //call SetCameraField( CAMERA_FIELD_TARGET_DISTANCE, 500, 0.00 )
            //call SetCameraPosition(GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        endif
        call SetCameraEyePositionForPlayer(Player(pid),GetWidgetX(fx.caster)+PolarX( 250, GetUnitFacing(fx.caster)),GetWidgetY(fx.caster)+PolarY( 250, GetUnitFacing(fx.caster)),500)
        call SetCameraTargetPositionForPlayer(Player(pid),GetWidgetX(fx.caster),GetWidgetY(fx.caster),0)
        call AdjustCameraSettingsForPlayer(Player(pid),0)
        call SetCameraField( CAMERA_FIELD_TARGET_DISTANCE, 1000, 1.3 )

        //애니
        call AnimationStart3(fx.caster, 17, 1.0)

        //특수효과
        if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
            set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        else
            set e = AddSpecialEffect("ZK_BM_Mine blasting2.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        endif
        call DestroyEffect(e)
        
        call UnitEffectTime2('e050',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetUnitFacing(fx.caster),2.0,0,fx.pid)
        //call OnlyDelayKill(CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e04Z',GetWidgetX(fx.caster),GetWidgetY(fx.caster),0), 1.5, fx.pid)
        
        
        //사운드
        call Sound3D(fx.caster,'A07I')

        set t = tick.create(pid) 
        set fx = SkillFx.Create()
        set fx.caster = GetTriggerUnit()
        set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set fx.speed = ((100+SkillSpeed(fx.pid))/100)
        set t.data = fx
        set fx.i = 0
        call t.start( 1.20, false, function EffectFunction ) 
        
        call DummyMagicleash(fx.caster, 2.4)

        call CooldownFIX(fx.caster,'A07D',3)
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

            
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("LuciaR"),(false))
    call TriggerAddAction(t,function RSyncData)

    set t = null
//! runtextmacro 이벤트_끝()
endscope

