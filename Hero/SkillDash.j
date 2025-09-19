scope SkillDash
globals
    //대쉬 최대이동거리
    private constant real MaxRange = 500
    private constant real CoolTime = 7.0
    private constant real Time = 0.3125
    private integer array UT
    private trigger array TrgRemove
    private triggeraction array ActRemove
endglobals

//! runtextmacro 틱("DashTimer")
    ability ab
    unit caster
    integer stack
//! runtextmacro 틱_끝()

//! runtextmacro 틱("DashCool")
    ability ab
    unit caster
    integer stack
//! runtextmacro 틱_끝()
    
//! runtextmacro 이벤트_틱이_종료되면_발동("DashTimer")
    local ability ab
    local real r
    set expired.stack = expired.stack + 1
    if expired.stack == 1 then
        set ab = EXGetUnitAbility(expired.caster,'A002')
        set r = EXGetAbilityState(ab,1)
        call UnitRemoveAbility(expired.caster,'A002')
        call UnitAddAbility(expired.caster,'A004')
        set ab = EXGetUnitAbility(expired.caster,'A004')
        call EXSetAbilityState(ab,1,r)
        set ab = null
        set r = 0
        call expired.Start(CoolTime,false)
    elseif expired.stack == 2 then
        set ab = EXGetUnitAbility(expired.caster,'A004')
        set r = EXGetAbilityState(ab,1)
        call UnitRemoveAbility(expired.caster,'A004')
        call UnitAddAbility(expired.caster,'A005')
        set ab = EXGetUnitAbility(expired.caster,'A005')
        call EXSetAbilityState(ab,1,r)
        set ab = null
        set r = 0
        call expired.Start(CoolTime,false)
    elseif expired.stack == 3 then
        call UnitRemoveAbility(expired.caster,'A005')
        call UnitAddAbility(expired.caster,'A006')
        set expired.caster = null
        set expired.ab = null
        call expired.Destroy()
    endif
//! runtextmacro 이벤트_끝()

//! runtextmacro 이벤트_틱이_종료되면_발동("DashCool")
    local DashTimer t2 = UT[GetUnitIndex(expired.caster)]
    if expired.stack == 0 then
        call EXSetAbilityState(expired.ab,1,t2.Remaining)
    else
        call EXSetAbilityState(expired.ab,1,1)
    endif
    set expired.ab = null
    set expired.caster = null
    call expired.Destroy()
//! runtextmacro 이벤트_끝()

private function OnRemove takes nothing returns nothing
    local integer i = GetTriggerIndex()
    call TriggerRemoveAction(TrgRemove[i], ActRemove[i])
    set ActRemove[i] = null
    set TrgRemove[i] = null
    set UT[i] = 0
endfunction

//3개일때
private function F_A006 takes nothing returns nothing
    local DashCool t
    local DashTimer t2
    local SkillDash st
    local effect e
    local integer i
    local unit caster
    if GetSpellAbilityId() == 'A006' then
        set caster = GetTriggerUnit()
        set st = SkillDash.Create()
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
        call st.Start()
        call SetUnitFacing(caster,AngleWBP(caster,GetSpellTargetX(),GetSpellTargetY()))
        call EXSetUnitFacing(caster,AngleWBP(caster,GetSpellTargetX(),GetSpellTargetY()))
        
        if GetUnitAbilityLevel(caster, 'B009') < 1 then
            if DataUnitIndex(caster) == 17 then
                if LuciaForm[GetPlayerId(GetOwningPlayer(caster))] == 0 then
                    call AnimationStart3(caster,UnitDashCode[DataUnitIndex(caster)],2.0)
                elseif LuciaForm[GetPlayerId(GetOwningPlayer(caster))] == 1 then
                    call AnimationStart3(caster,UnitDashCode[DataUnitIndex(caster)]+1,2.0)
                endif
            else
                call AnimationStart3(caster,UnitDashCode[DataUnitIndex(caster)],2.0)
            endif
        endif
        call UnitRemoveAbility(caster,'A006')
        call UnitAddAbility(caster,'A005')
        set t = DashCool.Create()
        set t.caster = caster
        set t.ab = EXGetUnitAbility(caster,'A005')
        set t.stack = 2
        set t2 = DashTimer.Create()
        set t2.caster = caster
        set t2.ab = EXGetUnitAbility(caster,'A005')
        set t2.stack = 2
        set UT[i] = t2
        call t.Start(0.02,false)
        call t2.Start(CoolTime,false)
        call DummyMagicleash(t.caster,Time)
        call BuffNoNB.Apply( t.caster, Time, 0 )
        call BuffNoST.Apply( t.caster, Time, 0 )
        call TriggerSleepActionByTimer(0)
        call JNStartUnitAbilityCooldown(caster, 'A006', 1)
        set caster = null
    endif
endfunction

private function F_A005 takes nothing returns nothing
    local DashCool t
    local DashTimer t2
    local SkillDash st
    local effect e
    local unit caster
    if GetSpellAbilityId() == 'A005' then
        set caster = GetTriggerUnit()
        set st = SkillDash.Create()
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
        call st.Start()
        call SetUnitFacing(caster,AngleWBP(caster,GetSpellTargetX(),GetSpellTargetY()))
        call EXSetUnitFacing(caster,AngleWBP(caster,GetSpellTargetX(),GetSpellTargetY()))
        
        if GetUnitAbilityLevel(caster, 'B009') < 1 then
            if DataUnitIndex(caster) == 17 then
                if LuciaForm[GetPlayerId(GetOwningPlayer(caster))] == 0 then
                    call AnimationStart3(caster,UnitDashCode[DataUnitIndex(caster)],2.0)
                elseif LuciaForm[GetPlayerId(GetOwningPlayer(caster))] == 1 then
                    call AnimationStart3(caster,UnitDashCode[DataUnitIndex(caster)]+1,2.0)
                endif
            else
                call AnimationStart3(caster,UnitDashCode[DataUnitIndex(caster)],2.0)
            endif
        endif
        call UnitRemoveAbility(caster,'A005')
        call UnitAddAbility(caster,'A004')
        set t = DashCool.Create()
        set t.caster = caster
        set t.stack = 1
        set t.ab = EXGetUnitAbility(caster,'A004')
        set t2 = UT[GetUnitIndex(caster)]
        set t2.ab = EXGetUnitAbility(caster,'A004')
        set t2.stack = 1
        call t.Start(0.02,false)
        call DummyMagicleash(t.caster,Time)
        call BuffNoNB.Apply( t.caster, Time, 0 )
        call BuffNoST.Apply( t.caster, Time, 0 )
        call SetUnitVertexColorBJ( caster, 80, 80, 100, 0 )
        call TriggerSleepActionByTimer(0)
        call JNStartUnitAbilityCooldown(caster, 'A005', 1)
        set caster = null
    endif
endfunction

private function F_A004 takes nothing returns nothing
    local DashCool t
    local DashTimer t2
    local SkillDash st
    local effect e
    local unit caster
    
    if GetSpellAbilityId() == 'A004' then
        set caster = GetTriggerUnit()
        set st = SkillDash.Create()
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
        call st.Start()
        call SetUnitFacing(caster,AngleWBP(caster,GetSpellTargetX(),GetSpellTargetY()))
        call EXSetUnitFacing(caster,AngleWBP(caster,GetSpellTargetX(),GetSpellTargetY()))
        
        if GetUnitAbilityLevel(caster, 'B009') < 1 then
            if DataUnitIndex(caster) == 17 then
                if LuciaForm[GetPlayerId(GetOwningPlayer(caster))] == 0 then
                    call AnimationStart3(caster,UnitDashCode[DataUnitIndex(caster)],2.0)
                elseif LuciaForm[GetPlayerId(GetOwningPlayer(caster))] == 1 then
                    call AnimationStart3(caster,UnitDashCode[DataUnitIndex(caster)]+1,2.0)
                endif
            else
                call AnimationStart3(caster,UnitDashCode[DataUnitIndex(caster)],2.0)
            endif
        endif
        call UnitRemoveAbility(caster,'A004')
        call UnitAddAbility(caster,'A002')
        set t = DashCool.Create()
        set t.caster = caster
        set t.stack = 0
        set t.ab = EXGetUnitAbility(caster,'A002')
        set t2 = UT[GetUnitIndex(caster)]
        set t2.ab = EXGetUnitAbility(caster,'A002')
        set t2.stack = 0
        call t.Start(0.02,false)
        call DummyMagicleash(t.caster, Time)
        call BuffNoNB.Apply( t.caster, Time, 0 )
        call BuffNoST.Apply( t.caster, Time, 0 )
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

//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
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
//! runtextmacro 이벤트_끝()

    //! runtextmacro 이벤트_맵이_로딩되면_발동()
    call DzTriggerRegisterKeyEventByCode(null, JN_OSKEY_X, 1, false, function XKey)
    //! runtextmacro 이벤트_끝()
endscope
