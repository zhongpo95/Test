scope SkillDash
globals
    //대쉬 최대이동거리
    private constant real MaxRange = 500
    private constant real CoolTime = 7.0
    private constant real Time = 0.3125
    private integer array UT
    private trigger array TrgRemove
    private triggeraction array ActRemove
    unit array LuciaCheckUnit
endglobals

private function DashAbilityByStack takes unit caster, integer stack returns ability
    if stack == 0 then
        return EXGetUnitAbility(caster,'A002')
    elseif stack == 1 then
        return EXGetUnitAbility(caster,'A004')
    endif
    return EXGetUnitAbility(caster,'A005')
endfunction

private function OnDashTimerExpired takes nothing returns nothing
    local tick expiredTick = tick.getExpired()
    local SkillFx expired = expiredTick.data
    local ability ab
    local real r
    local integer unitIndex = IndexUnit(expired.caster)

    set expired.i = expired.i + 1
    if expired.i == 1 then
        set ab = EXGetUnitAbility(expired.caster,'A002')
        set r = EXGetAbilityState(ab,1)
        call UnitRemoveAbility(expired.caster,'A002')
        call UnitAddAbility(expired.caster,'A004')
        set ab = EXGetUnitAbility(expired.caster,'A004')
        call EXSetAbilityState(ab,1,r)
        set ab = null
        set r = 0
        call expiredTick.start(CoolTime,false,function OnDashTimerExpired)
    elseif expired.i == 2 then
        set ab = EXGetUnitAbility(expired.caster,'A004')
        set r = EXGetAbilityState(ab,1)
        call UnitRemoveAbility(expired.caster,'A004')
        call UnitAddAbility(expired.caster,'A005')
        set ab = EXGetUnitAbility(expired.caster,'A005')
        call EXSetAbilityState(ab,1,r)
        set ab = null
        set r = 0
        call expiredTick.start(CoolTime,false,function OnDashTimerExpired)
    elseif expired.i == 3 then
        call UnitRemoveAbility(expired.caster,'A005')
        call UnitAddAbility(expired.caster,'A006')
        set UT[unitIndex] = 0
        call expired.Stop()
        set expiredTick.data = 0
        call expiredTick.destroy()
    endif

    set ab = null
endfunction

private function OnDashCoolExpired takes nothing returns nothing
    local tick expiredTick = tick.getExpired()
    local SkillFx expired = expiredTick.data
    local tick dashTimer = UT[GetUnitIndex(expired.caster)]
    local ability ab = DashAbilityByStack(expired.caster, expired.i)

    if expired.i == 0 and dashTimer != 0 then
        call EXSetAbilityState(ab,1,dashTimer.remaining)
    else
        call EXSetAbilityState(ab,1,1)
    endif

    set ab = null
    call expired.Stop()
    set expiredTick.data = 0
    call expiredTick.destroy()
endfunction
private function OnRemove takes nothing returns nothing
    local integer i = GetTriggerIndex()
    local tick t = UT[i]
    local SkillFx fx
    if t != 0 then
        set fx = t.data
        if fx != 0 then
            call fx.Stop()
        endif
        set t.data = 0
        call t.destroy()
    endif
    call TriggerRemoveAction(TrgRemove[i], ActRemove[i])
    set ActRemove[i] = null
    set TrgRemove[i] = null
    set UT[i] = 0
endfunction

//3개일때
private function F_A006 takes nothing returns nothing
    local tick t
    local tick t2
    local SkillFx fx
    local SkillFx fx2
    local SkillDash st
    local effect e
    local integer i
    local unit caster
    if GetSpellAbilityId() == 'A006' then
        set caster = GetTriggerUnit()
        set st = SkillDash.create()
        if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(caster)) != GetPlayerId(GetLocalPlayer()) then
            set e = AddSpecialEffect(".mdl",GetWidgetX(caster),GetWidgetY(caster))
        else
            set e = AddSpecialEffect("nitu.mdl",GetWidgetX(caster),GetWidgetY(caster))
        endif
        set i = IndexUnit(caster)
        if ActRemove[i] == null then
            set TrgRemove[i] = GetUnitRemoveTrigger(caster)
            set ActRemove[i] = TriggerAddAction(TrgRemove[i],function OnRemove)
        endif
        call EXEffectMatRotateZ(e,AngleWBP(caster,GetSpellTargetX(),GetSpellTargetY()))
        call DestroyEffect(e)
        set e = null
        set st.Owner = caster
        set st.TargetX = GetSpellTargetX()
        set st.TargetY = GetSpellTargetY()
        set st.Max = MaxRange
        set st.Speed = 32
        call st.start()
        call SetUnitFacing(caster,AngleWBP(caster,GetSpellTargetX(),GetSpellTargetY()))
        call EXSetUnitFacing(caster,AngleWBP(caster,GetSpellTargetX(),GetSpellTargetY()))

        if GetUnitAbilityLevel(caster, 'B009') < 1 then
            if DataUnitIndex(caster) == 17 then
                if LuciaForm[GetPlayerId(GetOwningPlayer(caster))] == 0 then
                    call AnimationStart3(caster,UnitDashCode[DataUnitIndex(caster)],2.0)
                elseif LuciaForm[GetPlayerId(GetOwningPlayer(caster))] == 1 then
                    call AnimationStart3(caster,UnitDashCode[DataUnitIndex(caster)]+1,2.0)
                endif
                set LuciaCheckUnit[GetPlayerId(GetOwningPlayer(caster))] = CreateUnit(GetOwningPlayer(caster),'e04Y',0,0,0)
                call DelayKill(LuciaCheckUnit[GetPlayerId(GetOwningPlayer(caster))], 1.0)
            else
                call AnimationStart3(caster,UnitDashCode[DataUnitIndex(caster)],2.0)
            endif
        endif
        call UnitRemoveAbility(caster,'A006')
        call UnitAddAbility(caster,'A005')
        set fx = SkillFx.Create()
        set fx.caster = caster
        set fx.i = 2
        set t = tick.create(0)
        set t.data = fx
        set fx2 = SkillFx.Create()
        set fx2.caster = caster
        set fx2.i = 2
        set t2 = tick.create(0)
        set t2.data = fx2
        set UT[i] = t2
        call t.start(0.02,false,function OnDashCoolExpired)
        call t2.start(CoolTime,false,function OnDashTimerExpired)
        //call DummyMagicleash(fx.caster,Time)
        call PauseUnitEx(caster,true)
        call BuffNoNB.Apply( caster, Time, 0 )
        call BuffNoST.Apply( caster, Time, 0 )
        call TriggerSleepActionByTimer(0)
        call JNStartUnitAbilityCooldown(caster, 'A006', 1)
        set caster = null
    endif
endfunction

private function F_A005 takes nothing returns nothing
    local tick t
    local tick t2
    local SkillFx fx
    local SkillFx fx2
    local SkillDash st
    local effect e
    local unit caster
    if GetSpellAbilityId() == 'A005' then
        set caster = GetTriggerUnit()
        set st = SkillDash.create()
        if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(caster)) != GetPlayerId(GetLocalPlayer()) then
            set e = AddSpecialEffect(".mdl",GetWidgetX(caster),GetWidgetY(caster))
        else
            set e = AddSpecialEffect("nitu.mdl",GetWidgetX(caster),GetWidgetY(caster))
        endif
        call EXEffectMatRotateZ(e,AngleWBP(caster,GetSpellTargetX(),GetSpellTargetY()))
        call DestroyEffect(e)
        set e = null
        set st.Owner = caster
        set st.TargetX = GetSpellTargetX()
        set st.TargetY = GetSpellTargetY()
        set st.Max = MaxRange
        set st.Speed = 32
        call st.start()
        call SetUnitFacing(caster,AngleWBP(caster,GetSpellTargetX(),GetSpellTargetY()))
        call EXSetUnitFacing(caster,AngleWBP(caster,GetSpellTargetX(),GetSpellTargetY()))

        if GetUnitAbilityLevel(caster, 'B009') < 1 then
            if DataUnitIndex(caster) == 17 then
                if LuciaForm[GetPlayerId(GetOwningPlayer(caster))] == 0 then
                    call AnimationStart3(caster,UnitDashCode[DataUnitIndex(caster)],2.0)
                elseif LuciaForm[GetPlayerId(GetOwningPlayer(caster))] == 1 then
                    call AnimationStart3(caster,UnitDashCode[DataUnitIndex(caster)]+1,2.0)
                endif
                set LuciaCheckUnit[GetPlayerId(GetOwningPlayer(caster))] = CreateUnit(GetOwningPlayer(caster),'e04Y',0,0,0)
                call DelayKill(LuciaCheckUnit[GetPlayerId(GetOwningPlayer(caster))], 1.0)
            else
                call AnimationStart3(caster,UnitDashCode[DataUnitIndex(caster)],2.0)
            endif
        endif
        call UnitRemoveAbility(caster,'A005')
        call UnitAddAbility(caster,'A004')
        set fx = SkillFx.Create()
        set fx.caster = caster
        set fx.i = 1
        set t = tick.create(0)
        set t.data = fx
        set t2 = UT[GetUnitIndex(caster)]
        set fx2 = t2.data
        set fx2.i = 1
        call t.start(0.02,false,function OnDashCoolExpired)
        //call DummyMagicleash(fx.caster,Time)
        call PauseUnitEx(caster,true)
        call BuffNoNB.Apply( caster, Time, 0 )
        call BuffNoST.Apply( caster, Time, 0 )
        call SetUnitVertexColorBJ( caster, 80, 80, 100, 0 )
        call TriggerSleepActionByTimer(0)
        call JNStartUnitAbilityCooldown(caster, 'A005', 1)
        set caster = null
    endif
endfunction

private function F_A004 takes nothing returns nothing
    local tick t
    local tick t2
    local SkillFx fx
    local SkillFx fx2
    local SkillDash st
    local effect e
    local unit caster

    if GetSpellAbilityId() == 'A004' then
        set caster = GetTriggerUnit()
        set st = SkillDash.create()
        if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(caster)) != GetPlayerId(GetLocalPlayer()) then
            set e = AddSpecialEffect(".mdl",GetWidgetX(caster),GetWidgetY(caster))
        else
            set e = AddSpecialEffect("nitu.mdl",GetWidgetX(caster),GetWidgetY(caster))
        endif
        call EXEffectMatRotateZ(e,AngleWBP(caster,GetSpellTargetX(),GetSpellTargetY()))
        call DestroyEffect(e)
        set e = null
        set st.Owner = caster
        set st.TargetX = GetSpellTargetX()
        set st.TargetY = GetSpellTargetY()
        set st.Max = MaxRange
        set st.Speed = 32
        call st.start()
        call SetUnitFacing(caster,AngleWBP(caster,GetSpellTargetX(),GetSpellTargetY()))
        call EXSetUnitFacing(caster,AngleWBP(caster,GetSpellTargetX(),GetSpellTargetY()))

        if GetUnitAbilityLevel(caster, 'B009') < 1 then
            if DataUnitIndex(caster) == 17 then
                if LuciaForm[GetPlayerId(GetOwningPlayer(caster))] == 0 then
                    call AnimationStart3(caster,UnitDashCode[DataUnitIndex(caster)],2.0)
                elseif LuciaForm[GetPlayerId(GetOwningPlayer(caster))] == 1 then
                    call AnimationStart3(caster,UnitDashCode[DataUnitIndex(caster)]+1,2.0)
                endif
                set LuciaCheckUnit[GetPlayerId(GetOwningPlayer(caster))] = CreateUnit(GetOwningPlayer(caster),'e04Y',0,0,0)
                call DelayKill(LuciaCheckUnit[GetPlayerId(GetOwningPlayer(caster))], 1.0)
            else
                call AnimationStart3(caster,UnitDashCode[DataUnitIndex(caster)],2.0)
            endif
        endif
        call UnitRemoveAbility(caster,'A004')
        call UnitAddAbility(caster,'A002')
        set fx = SkillFx.Create()
        set fx.caster = caster
        set fx.i = 0
        set t = tick.create(0)
        set t.data = fx
        set t2 = UT[GetUnitIndex(caster)]
        set fx2 = t2.data
        set fx2.i = 0
        call t.start(0.02,false,function OnDashCoolExpired)
        //call DummyMagicleash(fx.caster, Time)
        call PauseUnitEx(caster,true)
        call BuffNoNB.Apply( caster, Time, 0 )
        call BuffNoST.Apply( caster, Time, 0 )
        call SetUnitVertexColorBJ( caster, 80, 80, 100, 0 )
        call TriggerSleepActionByTimer(0)
        call JNStartUnitAbilityCooldown(caster, 'A004', 1)
        set caster = null
    endif
endfunction

    private function XKey takes nothing returns nothing
        local integer key = DzGetTriggerKey()
        local integer i = GetPlayerId(DzGetTriggerKeyPlayer())
        local string data

        if JNMemoryGetByte(JNGetModuleHandle("Game.dll") + 0xD04FEC) == 0 then /*채팅창 활성화 여부*/
            if key == JN_OSKEY_X then
                set data=R2S(DzGetMouseTerrainX())+" "+R2S(DzGetMouseTerrainY())
                call DzSyncData(("DashSync"),data)
            endif
        endif
    endfunction

    function DashSyncData takes nothing returns nothing
        local player p=(DzGetTriggerSyncPlayer())
        local string data=(DzGetTriggerSyncData())
        local integer pid
        local integer dataLen=StringLength(data)
        local integer valueLen
        local real x
        local real y
        local real angle

        set pid=GetPlayerId(p)

        set x=S2R(data)
        set valueLen=StringLength(R2S(x))
        set data=SubString(data,valueLen+1,dataLen)
        set dataLen=dataLen-(valueLen+1)
        set y=S2R(data)
        set pid=GetPlayerId(p)
        set angle = AngleWBP(MainUnit[pid],x,y)


        //0스텍이 사용가능
        if EXGetAbilityState(EXGetUnitAbility(MainUnit[pid],'A002'), ABILITY_STATE_COOLDOWN) == 0 then

            //스턴중이고 에어본상태가 아님
            if GetUnitAbilityLevel(MainUnit[pid], 'BPSE') == 1 and GetUnitAbilityLevel(MainUnit[pid], 'A024') < 1 then
                call CustomStun.Clear( MainUnit[pid] )
            endif

            //캐스팅중일시 캔슬
            //챈(차지중엔 캔슬불가)
            if DataUnitIndex(MainUnit[pid]) == 4 then
                if IsCastingChenQ[pid] == true then
                    set IsCastingChenQ[pid] = false
                    call UnitRemoveAbility( MainUnit[pid], 'B000' )
                endif
                if IsCastingChenC[pid] == true then
                    set IsCastingChenC[pid] = false
                    call UnitRemoveAbility( MainUnit[pid], 'B000' )
                endif
                if IsCastingChenA[pid] == true then
                    set IsCastingChenA[pid] = false
                    call UnitRemoveAbility( MainUnit[pid], 'B000' )
                endif
                if IsCastingChenW[pid] == true then
                    set IsCastingChenW[pid] = false
                    call UnitRemoveAbility( MainUnit[pid], 'B000' )
                endif
                if IsCastingChenE[pid] == true then
                    set IsCastingChenE[pid] = false
                    call UnitRemoveAbility( MainUnit[pid], 'B000' )
                endif
                if IsCastingChenD[pid] == true then
                    set IsCastingChenD[pid] = false
                    call UnitRemoveAbility( MainUnit[pid], 'B000' )
                endif
                if IsCastingChenS[pid] == true then
                    set IsCastingChenS[pid] = false
                    call UnitRemoveAbility( MainUnit[pid], 'B000' )
                endif
            endif

            //캐스팅중일시 캔슬
            //나루메아(차지중엔 캔슬불가)
            if DataUnitIndex(MainUnit[pid]) == 14 then
                if IsCastingNarC[pid] == true then
                    set IsCastingNarC[pid] = false
                    call UnitRemoveAbility( MainUnit[pid], 'B000' )
                endif
                if IsCastingNarD[pid] == true then
                    set IsCastingNarD[pid] = false
                    call UnitRemoveAbility( MainUnit[pid], 'B000' )
                endif
                if IsCastingNarA[pid] == true then
                    set IsCastingNarA[pid] = false
                    call UnitRemoveAbility( MainUnit[pid], 'B000' )
                endif
            endif

            //캐스팅중일시 캔슬
            //반디(차지중엔 캔슬불가)
            if DataUnitIndex(MainUnit[pid]) == 15 then
                if IsCastingBandiS[pid] == true then
                    set IsCastingBandiS[pid] = false
                    call UnitRemoveAbility( MainUnit[pid], 'B000' )
                endif
            endif

            //캐스팅중일시 캔슬
            //반디(차지중엔 캔슬불가)
            if DataUnitIndex(MainUnit[pid]) == 17 then
                if IsCastingLuciaA[pid] == true then
                    set IsCastingLuciaA[pid] = false
                    call UnitRemoveAbility( MainUnit[pid], 'B000' )
                endif
                if IsCastingLuciaS[pid] == true then
                    set IsCastingLuciaS[pid] = false
                    call UnitRemoveAbility( MainUnit[pid], 'B000' )
                endif
            endif
        endif

        //반디비술중
        if GetUnitAbilityLevel(MainUnit[pid],'A06N') < 1 then
            if DistanceWBP(MainUnit[pid],x,y) <= MaxRange then
                call IssuePointOrder( MainUnit[pid], "absorb", x, y )
            else
                call IssuePointOrder( MainUnit[pid], "absorb", GetWidgetX(MainUnit[pid]) + PolarX(MaxRange,angle), GetWidgetY(MainUnit[pid]) + PolarY(MaxRange,angle) )
            endif
        endif

        set p=null
    endfunction

private struct TEvAfterB extends array
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function thistype.Action)
        call TriggerRegisterTimerEvent(t,2.0,false)
        set t = null
    endmethod
    private static method Action takes nothing returns nothing
        local trigger t

        set t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddAction(t, function F_A004)
        set t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddAction(t, function F_A005)
        set t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddAction(t, function F_A006)

        set t=CreateTrigger()
        call DzTriggerRegisterSyncData(t,("DashSync"),(false))
        call TriggerAddAction(t,function DashSyncData)

        set t = null
    endmethod
endstruct
    private struct TEvMapLoadSkillDash extends array
        private static method onInit takes nothing returns nothing
            local trigger t = CreateTrigger()
            call TriggerAddAction(t, function thistype.Action)
            call TriggerRegisterTimerEvent(t, 0.04, false)
            set t = null
        endmethod
        private static method Action takes nothing returns nothing
    call DzTriggerRegisterKeyEventByCode(null, JN_OSKEY_X, 1, false, function XKey)
        endmethod
    endstruct
endscope
