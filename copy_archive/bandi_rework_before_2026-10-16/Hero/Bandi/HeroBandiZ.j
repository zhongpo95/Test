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
        
    private function EffectFunctionZ takes nothing returns nothing
        local tick t = tick.getExpired()
        local SkillFx fx = t.data
        local real r
        
        call UnitAddAbility(fx.caster,'Arav')
        call UnitRemoveAbility(fx.caster,'Arav')

        set fx.r = fx.r + 0.04

        if fx.r <= 1.300 then
            set r = RMaxBJ(( 5.00 - ( fx.r - 1.700 ) * 5.00 ), 2.00)
        elseif fx.r <= 1.800 then
            set r = 0
        else
            set r = GetUnitFlyHeight(fx.caster) / 7.5
        endif

        if GetUnitFlyHeight(fx.caster) >= 0 and fx.r <= 2.00 then
            if fx.r <= 1.700 then
                call SetUnitFlyHeight(fx.caster, GetUnitFlyHeight(fx.caster) + r, r / 0.04)
            else
                call SetUnitFlyHeight(fx.caster, GetUnitFlyHeight(fx.caster) - r, r / 0.04)
            endif
        else
            call SetUnitFlyHeight(fx.caster, 0, 0.00)
            call fx.stop()
            call t.destroy()
        endif
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
            set fx2 = SkillFx.create()
            set t2 = tick.create(fx2)
            set fx2.pid = fx.pid
            set fx2.caster = fx.caster
            set fx2.r = 0

            call t2.start( 0.04, true, function EffectFunctionZ )
        endif


        if fx.i+29 < 86 then
            call t.start( 0.02, false, function EffectFunction ) 
        else
            if fx.i+29 == 86 then 
                call DzFrameShow(BanAden, false)
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
        
        if GetSpellAbilityId() == 'A06M' then
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

            call BuffNoDM.Apply( fx.caster, 3.34, 0 )
            call BuffNoNB.Apply( fx.caster, 3.34, 0 )
            call BuffNoST.Apply( fx.caster, 3.34, 0 )

            set t.data = fx
            call t.start( Time2, false, function EffectFunction ) 
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
            
        if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and IsUnitPausedEx(MainUnit[pid]) == false and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID2[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
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

    library HeroBandiZ2 requires PSound

    globals
        integer array BanBisul
        integer array BanBisul2
        unit array BanBisulU
        unit array BanBisul2U
        boolean array BanBisul2Boolaen
        //1번 반디, 2번 샘, 3번 완전연소
        integer array BandiState
    endglobals

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
    

    private struct Adenst
        integer i
        integer pid
    endstruct

    private function EffectFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        local Adenst st = t.data

        set st.i = st.i + 1
        if st.i == 1 then
            if not IsUnitDeadVJ(BandiForm[st.pid]) then
                call KillUnit(BandiForm[st.pid])
            endif
            set BandiForm[st.pid] = CreateUnit(Player(st.pid),'e03C',0,0,0)
        endif

        if GetLocalPlayer() == Player(st.pid) then
            call DzFrameSetModel(BanAdens[2], "Bandi_Aden3.mdx", 0, 0)
        endif
        
        if st.i == 22 then
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

        call t.start( 1.0, true, function EffectFunction )
    endfunction
endlibrary
