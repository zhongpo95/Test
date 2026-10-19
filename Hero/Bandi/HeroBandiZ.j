// Arcana.Video.dll(JN 플러그인) 영상 native. ARCANA_VIDEO_ON 을 false 로 바꾸면 선언과 호출이 모두 빠져 DLL 없이도 맵이 열린다.
// true 인 동안은 Arcana.Video.dll 이 없는 PC에서 맵을 열 수 없다.
library ArcanaVideoNatives
    globals
        constant boolean ARCANA_VIDEO_ON = true
    endglobals

    static if ARCANA_VIDEO_ON then
        native JNArcVideoOpen takes string asset returns integer
        native JNArcVideoClose takes nothing returns nothing
        native JNArcVideoStatus takes nothing returns string
        // Arcana.Video.dll 영역 지정판에서 추가. 창 크기 비율(0~1, 왼쪽 위 기준). 너비·높이 0이면 중앙 기본 배치
        native JNArcVideoSetRect takes real x, real y, real w, real h returns nothing
    endif

    // target 의 화면에서만 맵 내부 영상을 연다. 결과는 로컬 표시용이라 동기화된 게임 상태의 조건으로 쓰면 안 된다.
    function ArcanaVideoOpenLocal takes player target, string asset returns boolean
        static if ARCANA_VIDEO_ON then
            if GetLocalPlayer() == target then
                return JNArcVideoOpen(asset) == 1
            endif
        endif
        return false
    endfunction

    // target 의 화면에서 영역(창 크기 비율)을 정한 뒤 영상을 연다. 영상은 비율을 유지한 채 영역 안에 맞춰진다.
    function ArcanaVideoOpenRectLocal takes player target, string asset, real x, real y, real w, real h returns boolean
        static if ARCANA_VIDEO_ON then
            if GetLocalPlayer() == target then
                call JNArcVideoSetRect(x, y, w, h)
                return JNArcVideoOpen(asset) == 1
            endif
        endif
        return false
    endfunction
endlibrary

scope HeroBandiZ
     globals
        private constant real SD = 109.00
        
        //쉐클시간
        private constant real Time = 0.60
        //스킬이펙트 시간
        private constant real Time2 = 0.20
        //스킬이펙트 시간2
        private constant real Time3 = 0.20
        //이동거리
        private constant real Dist = 450
    
        private constant real scale = 500
        private constant real distance = 200

        unit array BandiForm
        //Z 연출 영상. 로컬 화면 값이라 클라이언트마다 다를 수 있으니 로컬 표시 판단에만 쓴다
        private constant string ZVideo = "war3mapImported\\bandi-video.mp4"
        private boolean array ZVideoOn
        //unit array BandiForm2
        //unit array BandiForm3
    endglobals
        
    //Z 체공: 시전 순간부터 떠오르기 시작해(영상이 도는 동안 기를 모으며 상승) 마지막 베기 직전에 내려온다.
    //fx.r = 시전 후 지난 시간(초). 전체 길이는 시전 동작(약 3.34초)에 맞춘다
    private function EffectFunctionZ takes nothing returns nothing
        local tick t = tick.getExpired()
        local SkillFx fx = t.data
        local real h
        local real p

        call UnitAddAbility(fx.caster,'Arav')
        call UnitRemoveAbility(fx.caster,'Arav')

        set fx.r = fx.r + 0.04

        if fx.r <= 1.20 then
            //천천히 떠오름 (0 -> 120)
            set p = fx.r / 1.20
            set h = 120.00 * Sin(p * bj_PI / 2)
        elseif fx.r <= 1.34 then
            set h = 120.00
        elseif fx.r <= 2.60 then
            //영상이 끝나면 크게 상승 (120 -> 220)
            set p = (fx.r - 1.34) / 1.26
            set h = 120.00 + 100.00 * Sin(p * bj_PI / 2)
        elseif fx.r <= 3.10 then
            set h = 220.00
        elseif fx.r <= 3.34 then
            //마지막 베기와 함께 내려옴
            set p = (fx.r - 3.10) / 0.24
            set h = 220.00 * (1.0 - p)
        else
            call SetUnitFlyHeight(fx.caster, 0, 0.00)
            call fx.stop()
            call t.destroy()
            return
        endif

        if fx.caster == null or IsUnitDeadVJ(fx.caster) then
            call SetUnitFlyHeight(fx.caster, 0, 0.00)
            call fx.stop()
            call t.destroy()
            return
        endif
        call SetUnitFlyHeight(fx.caster, h, 0.00)
    endfunction

    private function EffectFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        local SkillFx fx = t.data
        local effect e
        local tick t2
        local SkillFx fx2
       
        //반디필터
        set fx.i = fx.i + 1
        //첫 장에서 영상을 연다. 플러그인이 없거나 OpenGL 이 아니면 기존 그림 연출로 재생한다
        if fx.i == 1 then
            //오른쪽 위(창 너비 68%~97.5%, 높이 4.5%~33%)에 띄운다
            set ZVideoOn[fx.pid] = ArcanaVideoOpenRectLocal(Player(fx.pid), ZVideo, 0.680, 0.045, 0.295, 0.287)
        endif
        if fx.i+29 < 10 then
            //call CinematicFilter2(GetTriggerPlayer(), BLEND_MODE_BLEND , "war3mapImported\\BandiZ (0"+I2S(fx.i)+").blp" , 100, 100, 100, 100, 100, 100, 100, 25)
            if GetLocalPlayer() == GetOwningPlayer(fx.caster) and not ZVideoOn[fx.pid] then
                call DzFrameSetTexture(BanAden,"war3mapImported\\BandiZ (0"+I2S(fx.i+29)+").blp",0)
                call DzFrameShow(BanAden, true)
            endif
        elseif fx.i+29 < 86 then
            //call CinematicFilter2(GetTriggerPlayer(), BLEND_MODE_BLEND , "war3mapImported\\BandiZ ("+I2S(fx.i)+").blp" , 100, 100, 100, 100, 100, 100, 100, 25)
            if GetLocalPlayer() == GetOwningPlayer(fx.caster) and not ZVideoOn[fx.pid] then
                call DzFrameSetTexture(BanAden,"war3mapImported\\BandiZ ("+I2S(fx.i+29)+").blp",0)
                call DzFrameShow(BanAden, true)
            endif
        endif
        
        if fx.i+29 == 31 then
            //call Sound3D(MainUnit[0],'A066')
            call Sound3D(fx.caster,'A067')
            call Sound3D(fx.caster,'A065')
        elseif fx.i+29 == 85 then
            call AnimationStart3(fx.caster,3, 1.00)
            call Sound3D(fx.caster,'A068')
        endif


        if fx.i+29 < 86 then
            call t.start( 0.02, false, function EffectFunction ) 
        else
            if fx.i+29 == 86 then 
                //시전 때 붙인 양손 기 모으기 이펙트 정리 (fx.e는 다음 장에서 가슴 이펙트로 다시 쓴다)
                if fx.e != null then
                    call DestroyEffect(fx.e)
                    set fx.e = null
                endif
                if fx.e2 != null then
                    call DestroyEffect(fx.e2)
                    set fx.e2 = null
                endif
                if GetLocalPlayer() == GetOwningPlayer(fx.caster) then
                    call DzFrameShow(BanAden, false)
                endif
                set ZVideoOn[fx.pid] = false
                call t.start( 1.35, false, function EffectFunction ) 
            elseif fx.i+29 == 87 then
                call AnimationStart3(fx.caster,4, 1.00)
                if fx.pid != GetPlayerId(GetLocalPlayer()) then
                    set fx.e = AddSpecialEffectTarget(".mdl", fx.caster,"chest")
                else
                    set fx.e = AddSpecialEffectTarget("tx-LiuYing17.mdl",fx.caster,"chest")
                endif
                call t.start( 0.05, false, function EffectFunction ) 
            elseif fx.i+29 == 88 then
                if fx.pid != GetPlayerId(GetLocalPlayer()) then
                    set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                else
                    set e = AddSpecialEffect("tx-LiuYing15.mdl", GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                endif
                call UnitAddAbility(fx.caster,'Arav')
                call UnitRemoveAbility(fx.caster,'Arav')
                call EXSetEffectZ(e, GetUnitFlyHeight(fx.caster)+100)
                call EXEffectMatRotateZ(e, GetUnitFacing(fx.caster)+90)
                call EXSetEffectSize(e,2.0)
                call DestroyEffect(e)
                set e = null
                if fx.pid != GetPlayerId(GetLocalPlayer()) then
                    set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                else
                    set e = AddSpecialEffect("Suzakuin-17-Y.mdl", GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                endif
                call UnitAddAbility(fx.caster,'Arav')
                call UnitRemoveAbility(fx.caster,'Arav')
                call EXSetEffectZ(e, GetUnitFlyHeight(fx.caster)+100)
                call EXEffectMatRotateZ(e, GetUnitFacing(fx.caster)+90)
                call DestroyEffect(e)
                set e = null
                call t.start( 0.60, false, function EffectFunction ) 
            else
                call DestroyEffect(fx.e)
                call PauseUnitEx(fx.caster,false)
                set fx.e = null
                call fx.stop()
                call t.destroy()
            endif
        endif


    endfunction
        

    private function Main takes nothing returns nothing
        local integer pid
        local tick t
        local SkillFx fx
        local tick t2
        local SkillFx fx2
        
        if GetSpellAbilityId() == 'A06M' and not BandiCastBlocked(GetTriggerUnit(), 'A06M') then
            call SetUnitFacing(GetTriggerUnit(), AngleWBP(GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() ))
            call EXSetUnitFacing(GetTriggerUnit(), AngleWBP(GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() ))
            set pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
            set t = tick.create(0) 
            set fx = SkillFx.create()
            set fx.caster = GetTriggerUnit()
            set fx.i = 0
            set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
                
            //call DummyMagicleash(fx.caster, Time)
            //call AnimationStart3(fx.caster,17, 1.00)
            
            call BanBisul2Use(fx.pid)

            call DzSetUnitModel(fx.caster, "[AWF]FireFlySam2.mdx")

            //form 완전연소
            set BandiState[fx.pid] = 2

            call PauseUnitEx(fx.caster,true)

            //시작 연출: 가만히 서 있지 않도록 시전 순간 변신 폭발 + 기 모으는 자세 + 상승을 바로 시작한다
            call AnimationStart3(fx.caster,3, 1.00)
            call UnitEffectTime2('e035',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetUnitFacing(fx.caster),1.2,0,fx.pid)
            call UnitEffectTime2('e036',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetUnitFacing(fx.caster),1.2,0,fx.pid)
            call UnitEffectTime2('e037',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetUnitFacing(fx.caster),1.2,0,fx.pid)
            call UnitEffectTime2('e038',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetUnitFacing(fx.caster),1.2,0,fx.pid)
            call UnitEffectTime2('e039',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetUnitFacing(fx.caster),1.2,0,fx.pid)
            call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 20 )
            set fx.e = AddSpecialEffectTarget("t7_wood_bashenan_juqi_1_2.mdl", fx.caster, "left hand")
            set fx.e2 = AddSpecialEffectTarget("t7_wood_bashenan_juqi_1_2.mdl", fx.caster, "right hand")
            set fx2 = SkillFx.create()
            set t2 = tick.create(fx2)
            set fx2.pid = fx.pid
            set fx2.caster = fx.caster
            set fx2.r = 0
            call t2.start( 0.04, true, function EffectFunctionZ )

            call BuffNoDM.Apply( fx.caster, 3.34, 0 )
            call BuffNoNB.Apply( fx.caster, 3.34, 0 )
            call BuffNoST.Apply( fx.caster, 3.34, 0 )

            set t.data = fx
            call t.start( Time2, false, function EffectFunction ) 
            call BandiStopOrder(fx.caster, "autodispel", 3.34)
            call CooldownFIX(fx.caster,'A06M', 4.0)
         endif
    endfunction

    private function ZSyncData takes nothing returns nothing
        local player p=(DzGetTriggerSyncPlayer())
        local string data=(DzGetTriggerSyncData())
        local integer pid
        local integer dataLen=StringLength(data)
        local integer valueLen
        local real x
        local real y
        local real angle
    
        set pid=GetPlayerId(p)
            
        if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and IsUnitPausedEx(MainUnit[pid]) == false and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID10[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
            if GetUnitAbilityLevel(MainUnit[pid],'A06N') < 1 then
                set x=S2R(data)
                set valueLen=StringLength(R2S(x))
                set data=SubString(data,valueLen+1,dataLen)
                set dataLen=dataLen-(valueLen+1)
                set y=S2R(data)
                set pid=GetPlayerId(p)
                set angle = AngleWBP( MainUnit[pid],x,y)
                call SetUnitFacing (MainUnit[pid],angle)
                call EXSetUnitFacing(MainUnit[pid],angle)
                call BandiRequest(pid, 'A06M')
                call IssuePointOrder( MainUnit[pid], "autodispel", x, y )
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
        call TriggerAddAction(t, function Main)
            
        set t=CreateTrigger()
        call DzTriggerRegisterSyncData(t,("BandiZ"),(false))
        call TriggerAddAction(t,function ZSyncData)
    
        set t = null
        endmethod
    endstruct
    endscope

    library HeroBandiZ2 initializer BandiCastGuardInit requires PSound, Cooldown

    globals
        integer array BanBisul
        integer array BanBisul2
        unit array BanBisulU
        unit array BanBisul2U
        boolean array BanBisul2Boolaen
        //1번 반디, 2번 샘, 3번 완전연소
        integer array BandiState
        //완전연소 남은 초. 1초 동기 틱(EffectFunction)에서만 쓴다
        integer array BandiZLeft
        //완전연소를 시작한 영웅. 영웅이 바뀌면 남은 시간 표시를 숨긴다
        unit array BandiZUnit
        //아래는 화면 그리기 전용(클라이언트마다 다를 수 있음). 동기 값을 읽기만 하고 게임 상태는 바꾸지 않는다
        timer BandiZDrawTimer = null
        integer BandiZSeen = -1
        real BandiZFrac = 0.0
        integer BandiZBlink = 0
        boolean BandiZShown = false
    endglobals

    //반디 스킬 자동 시전 차단.
    //키 입력(동기화)으로 내린 명령으로만 스킬이 나가게 한다. 묶임이 풀린 뒤 남은 명령으로 저절로 다시 시전되면
    //시전 시작(SPELL_CAST)에서 정지시키고, 효과(SPELL_EFFECT) 쪽 스킬 코드도 실행하지 않는다
    globals
        integer array BandiReqAbil
        integer array BandiCastBlock
        integer array BandiBlockOrder
        unit array BandiFixUnit
        integer array BandiFixAbil
    endglobals

    //동기화 핸들러에서 스킬 명령을 내리기 직전에 부른다
    function BandiRequest takes integer pid, integer abil returns nothing
        set BandiReqAbil[pid] = abil
    endfunction

    //차단된 시전의 효과가 그래도 나가 버리면 오브젝트 기본 쿨(300초)이 걸린다. 스킬은 실제로 나가지 않았으니 쿨을 0으로 되돌린다
    private function BandiFixCooldown takes nothing returns nothing
        local tick t = tick.getExpired()
        local integer pid = t.data
        if BandiFixUnit[pid] != null and BandiFixAbil[pid] != 0 then
            call CooldownSet(BandiFixUnit[pid], BandiFixAbil[pid], 0)
        endif
        set BandiFixUnit[pid] = null
        set BandiFixAbil[pid] = 0
        call t.destroy()
    endfunction

    //각 스킬 Main 에서 부른다. 이번 시전이 차단된 시전이면 true
    function BandiCastBlocked takes unit u, integer abil returns boolean
        local integer pid = GetPlayerId(GetOwningPlayer(u))
        local tick t
        if BandiCastBlock[pid] == abil then
            set BandiCastBlock[pid] = 0
            set BandiFixUnit[pid] = u
            set BandiFixAbil[pid] = abil
            set t = tick.create(pid)
            call t.start(0.0, false, function BandiFixCooldown)
            return true
        endif
        return false
    endfunction

    //남은 스킬 명령을 확실히 지운다. 시전 이벤트 안이나 묶인 상태에서는 정지 명령만 내리면 무시되는 경우가 있어
    //잠깐 일시정지한 상태에서 정지 명령을 내리고 바로 푼다 (원래 일시정지돼 있던 유닛은 그대로 둔다)
    function BandiHardStop takes unit u returns nothing
        local boolean paused = IsUnitPaused(u)
        if not paused then
            call PauseUnit(u, true)
        endif
        call IssueImmediateOrder(u, "stop")
        if not paused then
            call PauseUnit(u, false)
        endif
    endfunction

    private function BandiGuardRetry takes nothing returns nothing
        local tick t = tick.getExpired()
        local integer pid = t.data
        if BandiBlockOrder[pid] != 0 and GetUnitCurrentOrder(MainUnit[pid]) == BandiBlockOrder[pid] then
            call BandiHardStop(MainUnit[pid])
        endif
        call t.destroy()
    endfunction

    private function IsBandiSkill takes integer a returns boolean
        return a == 'A06H' or a == 'A06L' or a == 'A06C' or a == 'A06J' or a == 'A06I' or a == 'A06E' or a == 'A06G' or a == 'A06M'
    endfunction

    private function BandiCastGuard takes nothing returns nothing
        local integer abil = GetSpellAbilityId()
        local integer pid
        local tick t
        if IsBandiSkill(abil) then
            set pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
            if BandiReqAbil[pid] == abil then
                set BandiReqAbil[pid] = 0
                set BandiCastBlock[pid] = 0
            else
                set BandiCastBlock[pid] = abil
                set BandiBlockOrder[pid] = GetUnitCurrentOrder(GetTriggerUnit())
                call BandiHardStop(GetTriggerUnit())
                //이벤트 안에서 안 먹혔을 때를 대비해 바로 다음 틱에 한 번 더
                set t = tick.create(pid)
                call t.start(0.0, false, function BandiGuardRetry)
            endif
        endif
    endfunction

    private function BandiCastGuardInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_CAST)
        call TriggerAddAction(t, function BandiCastGuard)
        set t = null
    endfunction

    //반디 스킬 자동 재시전 방지.
    //쉐클(행동 불가)이 풀리면 유닛이 남아 있던 스킬 명령을 다시 실행해, 그 사이 쿨이 끝났으면 같은 스킬이 저절로 또 나갔다.
    //동작이 끝나기 직전(아직 묶여 있을 때) 조건 없이 정지시키고, 풀린 직후에는 현재 명령이 아직 그 스킬이면 한 번 더 정지시킨다
    private struct BandiStopSt
        unit u
        integer order
        boolean always
        integer pid
        integer seq
    endstruct

    globals
        //X(대시) 캔슬 횟수. 캔슬 뒤에는 그 스킬의 정지 예약을 취소해 대시나 이동 명령을 끊지 않는다
        integer array BandiCancelSeq
    endglobals

    //SkillDash 에서 반디가 X로 캔슬했을 때 부른다
    function BandiDashCancel takes integer pid returns nothing
        set BandiCancelSeq[pid] = BandiCancelSeq[pid] + 1
    endfunction

    private function BandiStopTick takes nothing returns nothing
        local tick t = tick.getExpired()
        local BandiStopSt st = t.data
        if st.u != null and st.seq == BandiCancelSeq[st.pid] and (st.always or GetUnitCurrentOrder(st.u) == st.order) then
            call BandiHardStop(st.u)
        endif
        set st.u = null
        call st.destroy()
        call t.destroy()
    endfunction

    private function BandiStopAt takes unit u, integer order, real delay, boolean always returns nothing
        local tick t = tick.create(0)
        local BandiStopSt st = BandiStopSt.create()
        set st.u = u
        set st.order = order
        set st.always = always
        set st.pid = GetPlayerId(GetOwningPlayer(u))
        set st.seq = BandiCancelSeq[st.pid]
        set t.data = st
        call t.start(delay, false, function BandiStopTick)
    endfunction

    //busy = 스킬 동작(행동 불가) 시간, 스킬 속도 반영된 초 단위
    function BandiStopOrder takes unit u, string order, real busy returns nothing
        //풀리기 직전: 남은 명령(대기 중인 재시전 포함)을 조건 없이 지운다. 묶여 있는 동안 내린 이동 명령도 함께 지워진다
        call BandiStopAt(u, OrderId(order), RMaxBJ(busy - 0.02, 0.01), true)
        call BandiStopAt(u, OrderId(order), busy + 0.03, false)
    endfunction

    function BanBisulPlus takes integer pid, integer i returns nothing
        local integer ch = 0

        if BanBisul[pid] == 4 then
            set ch = 1
        endif

        loop
            if BanBisul[pid] == 5 then
                if not IsUnitDeadVJ(BanBisulU[pid]) then
                    call KillUnit(BanBisulU[pid])
                endif
                set BanBisulU[pid] = CreateUnit(Player(pid),'e033',0,0,0)
            endif
        exitwhen i <= 0
            if GetLocalPlayer() == Player(pid) then
                if BanBisul[pid] == 0 then
                    call DzFrameSetTexture(BanAdens[0],"Bandi_Aden1.blp",0)
                    call DzFrameSetModel(BanAdens2[0], "Bandi_Aden.mdx", 0, 0)
                elseif BanBisul[pid] == 1 then
                    call DzFrameSetTexture(BanAdens[0],"Bandi_Aden2.blp",0)
                    call DzFrameSetModel(BanAdens2[1], "Bandi_Aden.mdx", 0, 0)
                elseif BanBisul[pid] == 2 then
                    call DzFrameSetTexture(BanAdens[0],"Bandi_Aden3.blp",0)
                    call DzFrameSetModel(BanAdens2[2], "Bandi_Aden.mdx", 0, 0)
                elseif BanBisul[pid] == 3 then
                    call DzFrameSetTexture(BanAdens[0],"Bandi_Aden4.blp",0)
                    call DzFrameSetModel(BanAdens2[3], "Bandi_Aden.mdx", 0, 0)
                elseif BanBisul[pid] == 4 then
                    call DzFrameSetTexture(BanAdens[0],"Bandi_Aden5.blp",0)
                    call DzFrameSetModel(BanAdens2[4], "Bandi_Aden.mdx", 0, 0)
                endif
            endif
            
            if BanBisul[pid] == 4 then
                if ch == 1 then
                    call Sound3D(MainUnit[pid],'A06U')
                endif
            endif

            set i = i - 1

            if BanBisul[pid] == 5 then
            else
                set BanBisul[pid] = BanBisul[pid] + 1
            endif
            
            set i = i - 1
        endloop
    endfunction
    
    function BanBisulUse takes integer pid returns nothing
        if GetLocalPlayer() == Player(pid) then
            call DzFrameSetTexture(BanAdens[0],"Bandi_Aden0.blp",0)
            call DzFrameSetModel(BanAdens2[0], "Bandi_Aden.mdx", 0, 0)
            call DzFrameSetModel(BanAdens2[1], "Bandi_Aden.mdx", 0, 0)
            call DzFrameSetModel(BanAdens2[2], "Bandi_Aden.mdx", 0, 0)
            call DzFrameSetModel(BanAdens2[3], "Bandi_Aden.mdx", 0, 0)
            call DzFrameSetModel(BanAdens2[4], "Bandi_Aden.mdx", 0, 0)
            call DzFrameShow(BanAdens[0],false)
            call DzFrameShow(BanAdens[1],true)
            call DzFrameShow(BanAdens[2],true)
        endif
        
        if not IsUnitDeadVJ(BanBisulU[pid]) then
            call KillUnit(BanBisulU[pid])
        endif
        
        set BanBisul[pid] = 0
    endfunction

    function BanBisul2Plus takes integer pid, integer i returns nothing
        if BandiState[pid] == 2 then
            loop
                if BanBisul2[pid] == 4 then
                    //set BanBisulU[pid] = CreateUnit(Player(pid),'e033',0,0,0)
                    if not IsUnitDeadVJ(BanBisul2U[pid]) then
                        call KillUnit(BanBisul2U[pid])
                    endif
                    set BanBisul2U[pid] = CreateUnit(Player(pid),'e034',0,0,0)
                endif
            exitwhen i <= 0
                if GetLocalPlayer() == Player(pid) then
                    if BanBisul2[pid] == 0 then
                        call DzFrameSetTexture(BanAdens[1],"Bandi_Aden2_25.blp",0)
                    elseif BanBisul2[pid] == 1 then
                        call DzFrameSetTexture(BanAdens[1],"Bandi_Aden2_50.blp",0)
                    elseif BanBisul2[pid] == 2 then
                        call DzFrameSetTexture(BanAdens[1],"Bandi_Aden2_75.blp",0)
                    elseif BanBisul2[pid] == 3 then
                        call DzFrameSetTexture(BanAdens[1],"Bandi_Aden2_100.blp",0)
                        call DzFrameSetModel(BanAdens[2], "Bandi_Aden2.mdx", 0, 0)
                    endif
                endif
                
                if BanBisul2[pid] == 4 then
                    set BanBisul2[pid] = 3
                    call DzFrameSetModel(BanAdens[2], "Bandi_Aden2.mdx", 0, 0)
                endif
                
                set i = i - 1
                set BanBisul2[pid] = BanBisul2[pid] + 1
            endloop
        endif
    endfunction
    

    globals
        //완전연소 지속 초. EffectFunction 이 1초마다 st.i 를 올려 이 값에 닿으면 끝난다
        private constant integer BANDI_Z_SEC = 22
        private constant real BANDI_Z_DRAW = 0.05
    endglobals

    //완전연소 남은 시간 그리기. 모든 클라이언트에서 돌지만 자기 pid 의 동기 값(BandiZLeft 등)을 읽어 프레임만 바꾼다
    private function BandiZDraw takes nothing returns nothing
        local integer pid = GetPlayerId(GetLocalPlayer())
        local integer left = BandiZLeft[pid]
        local real w

        if left > 0 and BandiState[pid] == 2 and BandiZUnit[pid] == MainUnit[pid] and not IsUnitDeadVJ(MainUnit[pid]) then
            //동기 1초 틱 사이를 로컬에서 메워 선이 매끄럽게 줄어들게 한다
            if left != BandiZSeen then
                set BandiZSeen = left
                set BandiZFrac = 0.0
            else
                set BandiZFrac = RMinBJ(BandiZFrac + BANDI_Z_DRAW, 1.0)
            endif
            if not BandiZShown then
                set BandiZShown = true
                set BandiZBlink = 0
            endif

            if left <= 3 then
                call DzFrameSetVertexColor(BanZLine, DzGetColor(255, 255, 70, 60))
                call DzFrameSetTextColor(BanZText, JNConvertColor(255, 255, 70, 60))
                set BandiZBlink = BandiZBlink + 1
                if ModuloInteger(BandiZBlink, 10) < 5 then
                    call DzFrameSetAlpha(BanZLine, 255)
                    call DzFrameSetAlpha(BanZText, 255)
                else
                    call DzFrameSetAlpha(BanZLine, 60)
                    call DzFrameSetAlpha(BanZText, 60)
                endif
            else
                call DzFrameSetVertexColor(BanZLine, DzGetColor(255, 255, 200, 80))
                call DzFrameSetTextColor(BanZText, JNConvertColor(255, 255, 200, 80))
                call DzFrameSetAlpha(BanZLine, 255)
                call DzFrameSetAlpha(BanZText, 255)
            endif

            set w = BANZ_LINE_W * (I2R(left) - BandiZFrac) / I2R(BANDI_Z_SEC)
            if w < 0.0005 then
                call DzFrameShow(BanZLine, false)
            else
                call DzFrameSetSize(BanZLine, w, BANZ_LINE_H)
                call DzFrameShow(BanZLine, true)
            endif
            call DzFrameSetText(BanZText, I2S(left))
            call DzFrameShow(BanZText, true)
        elseif BandiZShown then
            set BandiZShown = false
            set BandiZSeen = -1
            call DzFrameShow(BanZLine, false)
            call DzFrameShow(BanZText, false)
        endif
    endfunction

    private struct Adenst
        integer i
        integer pid
    endstruct

    private function EffectFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        local Adenst st = t.data

        set st.i = st.i + 1
        set BandiZLeft[st.pid] = BANDI_Z_SEC - st.i
        if st.i == 1 then
            if not IsUnitDeadVJ(BandiForm[st.pid]) then
                call KillUnit(BandiForm[st.pid])
            endif
            set BandiForm[st.pid] = CreateUnit(Player(st.pid),'e03C',0,0,0)
        endif

        if GetLocalPlayer() == Player(st.pid) then
            call DzFrameSetModel(BanAdens[2], "Bandi_Aden3.mdx", 0, 0)
        endif
        
        if st.i == BANDI_Z_SEC then
            if not IsUnitDeadVJ(BandiForm[st.pid]) then
                call KillUnit(BandiForm[st.pid])
            endif
    
            set BandiForm[st.pid] = CreateUnit(Player(st.pid),'e03A',0,0,0)
            //form 반디
            set BandiState[st.pid] = 1
    
            call DzSetUnitModel(MainUnit[st.pid], "FireFly_V1.mdx")
    
            if GetUnitAbilityLevel(MainUnit[st.pid],'A06Q') >= 1 then
                call UnitRemoveAbility(MainUnit[st.pid],'A06Q')
                call UnitAddAbility(MainUnit[st.pid],'A06F')
            endif
    
            if GetLocalPlayer() == Player(st.pid) then
                call DzFrameShow(BanAdens[0],true)
                call DzFrameSetTexture(BanAdens[1],"Bandi_Aden2_0.blp",0)
                call DzFrameShow(BanAdens[1],false)
                call DzFrameShow(BanAdens[2],false)
            endif
            call t.destroy()
            call st.destroy()
        endif
    endfunction
    
    function BanBisul2Use takes integer pid returns nothing
        local tick t = tick.create(pid)
        local Adenst st = Adenst.create()
        set st.i = 0
        set st.pid = pid
        set t.data = st

        if GetLocalPlayer() == Player(pid) then
            call DzFrameSetTexture(BanAdens[1],"Bandi_Aden3_0.blp",0)
        endif
        
        if not IsUnitDeadVJ(BanBisul2U[pid]) then
            call KillUnit(BanBisul2U[pid])
        endif
        
        set BanBisul2[pid] = 0
        set BandiState[pid] = 3
        set BandiZLeft[pid] = BANDI_Z_SEC
        set BandiZUnit[pid] = MainUnit[pid]
        if BandiZDrawTimer == null then
            set BandiZDrawTimer = CreateTimer()
            call TimerStart(BandiZDrawTimer, BANDI_Z_DRAW, true, function BandiZDraw)
        endif

        call t.start( 1.0, true, function EffectFunction )
    endfunction
endlibrary
