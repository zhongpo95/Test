library UIBossStart initializer Init requires UIHP, Boss2, Boss1, Boss4
    globals
        integer FBS_BD                     //인포 배경
        integer FBS_CB                     //X버튼
        integer FBS_LB                     //X버튼
        integer FBS_L                      //X버튼
        integer FBS_L2                     //X버튼
        integer FBS_RB
        integer FBS_R
        integer FBS_R2
        integer FBS_SelectBBD
        integer FBS_SelectBT
        integer FBS_SelectB
        integer array FBS_BossTip
        integer array FBS_BT[12]           //보스티어
        integer array FBS_BLB[12][4]       //보스리스트 버튼
        integer array FBS_BL[12][4]        //보스리스트
        boolean array FBS_OnOff            //인포 온오프
        
        private integer Selectting = 0     //누른 보스넘버
        private integer NowList = 0        //현재리스트
        private constant integer MaxList = 4
    endglobals
    
    private function BSOpen takes nothing returns nothing
        //메뉴 버튼을 누르면 메뉴 버튼 비활설화 + 메뉴 배경 표시
        //다시 메뉴 버튼을 누르면 메뉴버튼 활성화 + 메뉴 배경 숨김
        if FBS_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] == true then
            call DzFrameShow(FBS_BossTip[0], false)
            call DzFrameShow(FBS_BossTip[1], false)
            call DzFrameShow(FBS_BossTip[2], false)
            call DzFrameShow(FBS_SelectBBD, false)
            call DzFrameShow(FBS_BD, false)
            set FBS_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = false
            call DzFrameShow(JNGetFrameByName("heroStatusUI",0), true)
            call PlayersHPBarShow(DzGetTriggerUIEventPlayer(),true)
            call SelectUnitForPlayerSingle( MainUnit[GetPlayerId(DzGetTriggerUIEventPlayer())], DzGetTriggerUIEventPlayer() )
        else
            call DzFrameShow(FBS_BD, true)
            set FBS_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = true
            call DzFrameShow(JNGetFrameByName("heroStatusUI",0), false)
            call PlayersHPBarShow(DzGetTriggerUIEventPlayer(),false)
        endif
    endfunction
    
    private function ClickRLButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        
        call DzFrameShow(FBS_L, true)
        call DzFrameShow(FBS_R, true)
        
        if f == FBS_RB then
            if NowList == MaxList then
                set NowList = MaxList
            else
                set NowList = NowList + 1
            endif
            
            if NowList == 0 then
                call DzFrameShow(FBS_L, false)
                call DzFrameShow(FBS_R, true)
                call DzFrameShow(FBS_L2, true)
                call DzFrameShow(FBS_R2, false)
            elseif MaxList == NowList then
                call DzFrameShow(FBS_L, true)
                call DzFrameShow(FBS_R, false)
                call DzFrameShow(FBS_L2, false)
                call DzFrameShow(FBS_R2, true)
            else
                call DzFrameShow(FBS_L, true)
                call DzFrameShow(FBS_R, true)
                call DzFrameShow(FBS_L2, false)
                call DzFrameShow(FBS_R2, false)
            endif
        elseif f == FBS_LB then
            if NowList == 0 then
                set NowList = 0
            else
                set NowList = NowList - 1
            endif
            
            if NowList == 0 then
                call DzFrameShow(FBS_L, false)
                call DzFrameShow(FBS_R, true)
                call DzFrameShow(FBS_L2, true)
                call DzFrameShow(FBS_R2, false)
            elseif MaxList == NowList then
                call DzFrameShow(FBS_L, true)
                call DzFrameShow(FBS_R, false)
                call DzFrameShow(FBS_L2, false)
                call DzFrameShow(FBS_R2, true)
            else
                call DzFrameShow(FBS_L, true)
                call DzFrameShow(FBS_R, true)
                call DzFrameShow(FBS_L2, false)
                call DzFrameShow(FBS_R2, false)
            endif
        endif
        
        set Selectting = 0
        call DzFrameShow(FBS_BossTip[0], false)
        call DzFrameShow(FBS_BossTip[1], false)
        call DzFrameShow(FBS_BossTip[2], false)
        call DzFrameShow(FBS_SelectBBD, false)
        call DzFrameShow(FBS_BT[0], false)
        call DzFrameShow(FBS_BT[1], false)
        call DzFrameShow(FBS_BT[2], false)
        call DzFrameShow(FBS_BT[3], false)
        call DzFrameShow(FBS_BT[4], false)
        
        if NowList == 0 then
            call DzFrameShow(FBS_BT[0], true)
        elseif NowList == 1 then
            call DzFrameShow(FBS_BT[1], true)
        elseif NowList == 2 then
            call DzFrameShow(FBS_BT[2], true)
        elseif NowList == 3 then
            call DzFrameShow(FBS_BT[3], true)
        elseif NowList == 4 then
            call DzFrameShow(FBS_BT[4], true)
        endif
        
    endfunction
    
    private function ClickPickBossButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        
        call DzFrameShow(FBS_BossTip[0], false)
        call DzFrameShow(FBS_BossTip[1], false)
        call DzFrameShow(FBS_BossTip[2], false)
        call DzFrameShow(FBS_SelectBBD, false)
        call DzFrameShow(FBS_BD, false)
        set FBS_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = false
        call DzFrameShow(JNGetFrameByName("heroStatusUI",0), true)
        call PlayersHPBarShow(DzGetTriggerUIEventPlayer(),true)
        call SelectUnitForPlayerSingle( MainUnit[GetPlayerId(DzGetTriggerUIEventPlayer())], DzGetTriggerUIEventPlayer() )
        call DzSyncData("PickBoss", I2S(Selectting))
    endfunction
    
    private function ClickBBDButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        
        call DzFrameShow(FBS_BossTip[0], false)
        call DzFrameShow(FBS_BossTip[1], false)
        call DzFrameShow(FBS_BossTip[2], false)
        call DzFrameShow(FBS_SelectBBD, false)
        
        //1페이지
        if f == FBS_BLB[0][1] then
            set Selectting = 1
            call DzFrameShow(FBS_BossTip[0], true)
            call DzFrameShow(FBS_SelectBBD, true)
        elseif f == FBS_BLB[0][2] then
            set Selectting = 2
            call DzFrameShow(FBS_BossTip[1], true)
            call DzFrameShow(FBS_SelectBBD, true)
        elseif f == FBS_BLB[0][3] then
            set Selectting = 3
            call DzFrameShow(FBS_BossTip[2], true)
            call DzFrameShow(FBS_SelectBBD, true)
        endif
        if f == FBS_BLB[1][1] then
            set Selectting = 4
            //유유코이미지
            call DzFrameShow(FBS_SelectBBD, true)
        endif
    endfunction
    
    private function ClickSLButton1 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
    endfunction

    
    private function Main takes nothing returns nothing
        local string s
        local integer i
        call DzLoadToc("war3mapImported\\Templates.toc")
        
        set FBS_BD=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "template", 0)
        call DzFrameSetTexture(FBS_BD, "UI_Pick.blp", 0)
        call DzFrameSetSize(FBS_BD, 0.80, 0.60)
        call DzFrameSetAbsolutePoint(FBS_BD, JN_FRAMEPOINT_CENTER, 0.4000, 0.2800)
        
        //메뉴 취소 버튼
        set FBS_CB = DzCreateFrameByTagName("GLUETEXTBUTTON", "", FBS_BD, "ScriptDialogButton", 0)
        call DzFrameSetPoint(FBS_CB, JN_FRAMEPOINT_TOPRIGHT, FBS_BD , JN_FRAMEPOINT_TOPRIGHT, -0.050, -0.050)
        call DzFrameSetText(FBS_CB, "X")
        call DzFrameSetSize(FBS_CB, 0.03, 0.03)
        call DzFrameSetScriptByCode(FBS_CB, JN_FRAMEEVENT_MOUSE_UP, function BSOpen, false)
        
        //왼쪽
        set FBS_L2=DzCreateFrameByTagName("BACKDROP", "", FBS_BD, "template", 0)
        call DzFrameSetTexture(FBS_L2, "UI_L2.blp", 0)
        call DzFrameSetSize(FBS_L2, 0.075, 0.075)
        call DzFrameSetAbsolutePoint(FBS_L2, JN_FRAMEPOINT_CENTER, 0.0500, 0.3000)
        call DzFrameShow(FBS_L2, true)
        set FBS_LB = DzCreateFrameByTagName("BUTTON", "", FBS_BD, "ScoreScreenTabButtonTemplate", 0)
        call DzFrameSetAbsolutePoint(FBS_LB, JN_FRAMEPOINT_CENTER, 0.0500, 0.3000)
        call DzFrameSetSize(FBS_LB, 0.075, 0.075)
        call DzFrameSetScriptByCode(FBS_LB, JN_FRAMEEVENT_MOUSE_UP, function ClickRLButton, false)
        set FBS_L=DzCreateFrameByTagName("BACKDROP", "", FBS_BD, "template", 0)
        call DzFrameSetTexture(FBS_L, "UI_L.blp", 0)
        call DzFrameSetSize(FBS_L, 0.075, 0.075)
        call DzFrameSetAbsolutePoint(FBS_L, JN_FRAMEPOINT_CENTER, 0.0500, 0.3000)
        call DzFrameShow(FBS_L, false)
        
        //오른쪽
        set FBS_R2=DzCreateFrameByTagName("BACKDROP", "", FBS_BD, "template", 0)
        call DzFrameSetTexture(FBS_R2, "UI_R2.blp", 0)
        call DzFrameSetSize(FBS_R2, 0.075, 0.075)
        call DzFrameSetAbsolutePoint(FBS_R2, JN_FRAMEPOINT_CENTER, 0.7500, 0.3000)
        call DzFrameShow(FBS_R2, false)
        set FBS_RB = DzCreateFrameByTagName("BUTTON", "", FBS_BD, "ScoreScreenTabButtonTemplate", 0)
        call DzFrameSetAbsolutePoint(FBS_RB, JN_FRAMEPOINT_CENTER, 0.7500, 0.3000)
        call DzFrameSetSize(FBS_RB, 0.075, 0.075)
        call DzFrameSetScriptByCode(FBS_RB, JN_FRAMEEVENT_MOUSE_UP, function ClickRLButton, false)
        set FBS_R=DzCreateFrameByTagName("BACKDROP", "", FBS_BD, "template", 0)
        call DzFrameSetTexture(FBS_R, "UI_R.blp", 0)
        call DzFrameSetSize(FBS_R, 0.075, 0.075)
        call DzFrameSetAbsolutePoint(FBS_R, JN_FRAMEPOINT_CENTER, 0.7500, 0.3000)
        
    //1페이지
    if true then
        set FBS_BT[0]=DzCreateFrameByTagName("BACKDROP", "", FBS_BD, "template", 0)
        call DzFrameSetTexture(FBS_BT[0], "UI_BossPage0.blp", 0)
        call DzFrameSetSize(FBS_BT[0], 0.20, 0.10)
        call DzFrameSetAbsolutePoint(FBS_BT[0], JN_FRAMEPOINT_CENTER, 0.2600, 0.4925)
        call DzFrameShow(FBS_BT[0], true)
        
        set FBS_BLB[0][1] = DzCreateFrameByTagName("BUTTON", "", FBS_BT[0], "ScoreScreenTabButtonTemplate", 0)
        call DzFrameSetAbsolutePoint(FBS_BLB[0][1], JN_FRAMEPOINT_CENTER, 0.2600, 0.3800)
        call DzFrameSetSize(FBS_BLB[0][1], 0.20, 0.10)
        call DzFrameSetScriptByCode(FBS_BLB[0][1], JN_FRAMEEVENT_MOUSE_UP, function ClickBBDButton, false)
        set FBS_BL[0][1]=DzCreateFrameByTagName("BACKDROP", "", FBS_BT[0], "template", 0)
        call DzFrameSetTexture(FBS_BL[0][1], "UI_Boss0_1_1.blp", 0)
        call DzFrameSetSize(FBS_BL[0][1], 0.20, 0.10)
        call DzFrameSetAbsolutePoint(FBS_BL[0][1], JN_FRAMEPOINT_CENTER, 0.2600, 0.3800)
        
        set FBS_BLB[0][2] = DzCreateFrameByTagName("BUTTON", "", FBS_BT[0], "ScoreScreenTabButtonTemplate", 0)
        call DzFrameSetAbsolutePoint(FBS_BLB[0][2], JN_FRAMEPOINT_CENTER, 0.2650, 0.2600)
        call DzFrameSetSize(FBS_BLB[0][2], 0.20, 0.10)
        call DzFrameSetScriptByCode(FBS_BLB[0][2], JN_FRAMEEVENT_MOUSE_UP, function ClickBBDButton, false)
        set FBS_BL[0][2]=DzCreateFrameByTagName("BACKDROP", "", FBS_BT[0], "template", 0)
        call DzFrameSetTexture(FBS_BL[0][2], "UI_Boss0_2_1.blp", 0)
        call DzFrameSetSize(FBS_BL[0][2], 0.20, 0.10)
        call DzFrameSetAbsolutePoint(FBS_BL[0][2], JN_FRAMEPOINT_CENTER, 0.2650, 0.2600)
        
        set FBS_BLB[0][3] = DzCreateFrameByTagName("BUTTON", "", FBS_BT[0], "ScoreScreenTabButtonTemplate", 0)
        call DzFrameSetAbsolutePoint(FBS_BLB[0][3], JN_FRAMEPOINT_CENTER, 0.2700, 0.1400)
        call DzFrameSetSize(FBS_BLB[0][3], 0.20, 0.10)
        call DzFrameSetScriptByCode(FBS_BLB[0][3], JN_FRAMEEVENT_MOUSE_UP, function ClickBBDButton, false)
        set FBS_BL[0][3]=DzCreateFrameByTagName("BACKDROP", "", FBS_BT[0], "template", 0)
        call DzFrameSetTexture(FBS_BL[0][3], "UI_Boss0_3_1.blp", 0)
        call DzFrameSetSize(FBS_BL[0][3], 0.20, 0.10)
        call DzFrameSetAbsolutePoint(FBS_BL[0][3], JN_FRAMEPOINT_CENTER, 0.2700, 0.1400)
        
        
        set FBS_BossTip[0]=DzCreateFrameByTagName("BACKDROP", "", FBS_BT[0], "template", 0)
        call DzFrameSetTexture(FBS_BossTip[0], "UI_BossTip0.blp", 0)
        call DzFrameSetSize(FBS_BossTip[0], 0.20, 0.30)
        call DzFrameSetAbsolutePoint(FBS_BossTip[0], JN_FRAMEPOINT_CENTER, 0.55, 0.35)
        call DzFrameShow(FBS_BossTip[0], false)
        set FBS_BossTip[1]=DzCreateFrameByTagName("BACKDROP", "", FBS_BT[0], "template", 0)
        call DzFrameSetTexture(FBS_BossTip[1], "UI_BossTip1.blp", 0)
        call DzFrameSetSize(FBS_BossTip[1], 0.20, 0.30)
        call DzFrameSetAbsolutePoint(FBS_BossTip[1], JN_FRAMEPOINT_CENTER, 0.55, 0.35)
        call DzFrameShow(FBS_BossTip[1], false)
        set FBS_BossTip[2]=DzCreateFrameByTagName("BACKDROP", "", FBS_BT[0], "template", 0)
        call DzFrameSetTexture(FBS_BossTip[2], "UI_BossTip2.blp", 0)
        call DzFrameSetSize(FBS_BossTip[2], 0.20, 0.30)
        call DzFrameSetAbsolutePoint(FBS_BossTip[2], JN_FRAMEPOINT_CENTER, 0.55, 0.35)
        call DzFrameShow(FBS_BossTip[2], false)
    endif
    //2페이지
    if true then
        set FBS_BT[1]=DzCreateFrameByTagName("BACKDROP", "", FBS_BD, "template", 0)
        call DzFrameSetTexture(FBS_BT[1], "UI_BossPage1.blp", 0)
        call DzFrameSetSize(FBS_BT[1], 0.20, 0.10)
        call DzFrameSetAbsolutePoint(FBS_BT[1], JN_FRAMEPOINT_CENTER, 0.2600, 0.4925)
        call DzFrameShow(FBS_BT[1], false)
        
        set FBS_BLB[1][1] = DzCreateFrameByTagName("BUTTON", "", FBS_BT[1], "ScoreScreenTabButtonTemplate", 0)
        call DzFrameSetAbsolutePoint(FBS_BLB[1][1], JN_FRAMEPOINT_CENTER, 0.2600, 0.3800)
        call DzFrameSetSize(FBS_BLB[1][1], 0.20, 0.10)
        call DzFrameSetScriptByCode(FBS_BLB[1][1], JN_FRAMEEVENT_MOUSE_UP, function ClickBBDButton, false)
        set FBS_BL[1][1]=DzCreateFrameByTagName("BACKDROP", "", FBS_BT[1], "template", 0)
        call DzFrameSetTexture(FBS_BL[1][1], "UI_Boss0_0_1.blp", 0)
        call DzFrameSetSize(FBS_BL[1][1], 0.20, 0.10)
        call DzFrameSetAbsolutePoint(FBS_BL[1][1], JN_FRAMEPOINT_CENTER, 0.2600, 0.3800)
        
        set FBS_BLB[1][2] = DzCreateFrameByTagName("BUTTON", "", FBS_BT[1], "ScoreScreenTabButtonTemplate", 0)
        call DzFrameSetAbsolutePoint(FBS_BLB[1][2], JN_FRAMEPOINT_CENTER, 0.2650, 0.2600)
        call DzFrameSetSize(FBS_BLB[1][2], 0.20, 0.10)
        call DzFrameSetScriptByCode(FBS_BLB[1][2], JN_FRAMEEVENT_MOUSE_UP, function ClickBBDButton, false)
        set FBS_BL[1][2]=DzCreateFrameByTagName("BACKDROP", "", FBS_BT[1], "template", 0)
        call DzFrameSetTexture(FBS_BL[1][2], "UI_Boss0_0_1.blp", 0)
        call DzFrameSetSize(FBS_BL[1][2], 0.20, 0.10)
        call DzFrameSetAbsolutePoint(FBS_BL[1][2], JN_FRAMEPOINT_CENTER, 0.2650, 0.2600)
        
        set FBS_BLB[1][3] = DzCreateFrameByTagName("BUTTON", "", FBS_BT[1], "ScoreScreenTabButtonTemplate", 0)
        call DzFrameSetAbsolutePoint(FBS_BLB[1][3], JN_FRAMEPOINT_CENTER, 0.2700, 0.1400)
        call DzFrameSetSize(FBS_BLB[1][3], 0.20, 0.10)
        call DzFrameSetScriptByCode(FBS_BLB[1][3], JN_FRAMEEVENT_MOUSE_UP, function ClickBBDButton, false)
        set FBS_BL[1][3]=DzCreateFrameByTagName("BACKDROP", "", FBS_BT[1], "template", 0)
        call DzFrameSetTexture(FBS_BL[1][3], "UI_Boss0_0_1.blp", 0)
        call DzFrameSetSize(FBS_BL[1][3], 0.20, 0.10)
        call DzFrameSetAbsolutePoint(FBS_BL[1][3], JN_FRAMEPOINT_CENTER, 0.2700, 0.1400)
    endif
    //3페이지
    if true then
        set FBS_BT[2]=DzCreateFrameByTagName("BACKDROP", "", FBS_BD, "template", 0)
        call DzFrameSetTexture(FBS_BT[2], "UI_BossPage2.blp", 0)
        call DzFrameSetSize(FBS_BT[2], 0.20, 0.10)
        call DzFrameSetAbsolutePoint(FBS_BT[2], JN_FRAMEPOINT_CENTER, 0.2600, 0.4925)
        call DzFrameShow(FBS_BT[2], false)
        
        set FBS_BLB[2][1] = DzCreateFrameByTagName("BUTTON", "", FBS_BT[2], "ScoreScreenTabButtonTemplate", 0)
        call DzFrameSetAbsolutePoint(FBS_BLB[2][1], JN_FRAMEPOINT_CENTER, 0.2600, 0.3800)
        call DzFrameSetSize(FBS_BLB[2][1], 0.20, 0.10)
        call DzFrameSetScriptByCode(FBS_BLB[2][1], JN_FRAMEEVENT_MOUSE_UP, function ClickBBDButton, false)
        set FBS_BL[2][1]=DzCreateFrameByTagName("BACKDROP", "", FBS_BT[2], "template", 0)
        call DzFrameSetTexture(FBS_BL[2][1], "UI_Boss0_0_1.blp", 0)
        call DzFrameSetSize(FBS_BL[2][1], 0.20, 0.10)
        call DzFrameSetAbsolutePoint(FBS_BL[2][1], JN_FRAMEPOINT_CENTER, 0.2600, 0.3800)
        
        set FBS_BLB[2][2] = DzCreateFrameByTagName("BUTTON", "", FBS_BT[2], "ScoreScreenTabButtonTemplate", 0)
        call DzFrameSetAbsolutePoint(FBS_BLB[2][2], JN_FRAMEPOINT_CENTER, 0.2650, 0.2600)
        call DzFrameSetSize(FBS_BLB[2][2], 0.20, 0.10)
        call DzFrameSetScriptByCode(FBS_BLB[2][2], JN_FRAMEEVENT_MOUSE_UP, function ClickBBDButton, false)
        set FBS_BL[2][2]=DzCreateFrameByTagName("BACKDROP", "", FBS_BT[2], "template", 0)
        call DzFrameSetTexture(FBS_BL[2][2], "UI_Boss0_0_1.blp", 0)
        call DzFrameSetSize(FBS_BL[2][2], 0.20, 0.10)
        call DzFrameSetAbsolutePoint(FBS_BL[2][2], JN_FRAMEPOINT_CENTER, 0.2650, 0.2600)
        
        set FBS_BLB[2][3] = DzCreateFrameByTagName("BUTTON", "", FBS_BT[2], "ScoreScreenTabButtonTemplate", 0)
        call DzFrameSetAbsolutePoint(FBS_BLB[2][3], JN_FRAMEPOINT_CENTER, 0.2700, 0.1400)
        call DzFrameSetSize(FBS_BLB[2][3], 0.20, 0.10)
        call DzFrameSetScriptByCode(FBS_BLB[2][3], JN_FRAMEEVENT_MOUSE_UP, function ClickBBDButton, false)
        set FBS_BL[2][3]=DzCreateFrameByTagName("BACKDROP", "", FBS_BT[2], "template", 0)
        call DzFrameSetTexture(FBS_BL[2][3], "UI_Boss0_0_1.blp", 0)
        call DzFrameSetSize(FBS_BL[2][3], 0.20, 0.10)
        call DzFrameSetAbsolutePoint(FBS_BL[2][3], JN_FRAMEPOINT_CENTER, 0.2700, 0.1400)
    endif
    //4페이지
    if true then
        set FBS_BT[3]=DzCreateFrameByTagName("BACKDROP", "", FBS_BD, "template", 0)
        call DzFrameSetTexture(FBS_BT[3], "UI_BossPage3.blp", 0)
        call DzFrameSetSize(FBS_BT[3], 0.20, 0.10)
        call DzFrameSetAbsolutePoint(FBS_BT[3], JN_FRAMEPOINT_CENTER, 0.2600, 0.4925)
        call DzFrameShow(FBS_BT[3], false)
        
        set FBS_BLB[3][1] = DzCreateFrameByTagName("BUTTON", "", FBS_BT[3], "ScoreScreenTabButtonTemplate", 0)
        call DzFrameSetAbsolutePoint(FBS_BLB[3][1], JN_FRAMEPOINT_CENTER, 0.2600, 0.3800)
        call DzFrameSetSize(FBS_BLB[3][1], 0.20, 0.10)
        call DzFrameSetScriptByCode(FBS_BLB[3][1], JN_FRAMEEVENT_MOUSE_UP, function ClickBBDButton, false)
        set FBS_BL[3][1]=DzCreateFrameByTagName("BACKDROP", "", FBS_BT[3], "template", 0)
        call DzFrameSetTexture(FBS_BL[3][1], "UI_Boss0_0_1.blp", 0)
        call DzFrameSetSize(FBS_BL[3][1], 0.20, 0.10)
        call DzFrameSetAbsolutePoint(FBS_BL[3][1], JN_FRAMEPOINT_CENTER, 0.2600, 0.3800)
        
        set FBS_BLB[3][2] = DzCreateFrameByTagName("BUTTON", "", FBS_BT[3], "ScoreScreenTabButtonTemplate", 0)
        call DzFrameSetAbsolutePoint(FBS_BLB[3][2], JN_FRAMEPOINT_CENTER, 0.2650, 0.2600)
        call DzFrameSetSize(FBS_BLB[3][2], 0.20, 0.10)
        call DzFrameSetScriptByCode(FBS_BLB[3][2], JN_FRAMEEVENT_MOUSE_UP, function ClickBBDButton, false)
        set FBS_BL[3][2]=DzCreateFrameByTagName("BACKDROP", "", FBS_BT[3], "template", 0)
        call DzFrameSetTexture(FBS_BL[3][2], "UI_Boss0_0_1.blp", 0)
        call DzFrameSetSize(FBS_BL[3][2], 0.20, 0.10)
        call DzFrameSetAbsolutePoint(FBS_BL[3][2], JN_FRAMEPOINT_CENTER, 0.2650, 0.2600)
        
        set FBS_BLB[3][3] = DzCreateFrameByTagName("BUTTON", "", FBS_BT[3], "ScoreScreenTabButtonTemplate", 0)
        call DzFrameSetAbsolutePoint(FBS_BLB[3][3], JN_FRAMEPOINT_CENTER, 0.2700, 0.1400)
        call DzFrameSetSize(FBS_BLB[3][3], 0.20, 0.10)
        call DzFrameSetScriptByCode(FBS_BLB[3][3], JN_FRAMEEVENT_MOUSE_UP, function ClickBBDButton, false)
        set FBS_BL[3][3]=DzCreateFrameByTagName("BACKDROP", "", FBS_BT[3], "template", 0)
        call DzFrameSetTexture(FBS_BL[3][3], "UI_Boss0_0_1.blp", 0)
        call DzFrameSetSize(FBS_BL[3][3], 0.20, 0.10)
        call DzFrameSetAbsolutePoint(FBS_BL[3][3], JN_FRAMEPOINT_CENTER, 0.2700, 0.1400)
    endif
        
    //5페이지
    if true then
        set FBS_BT[4]=DzCreateFrameByTagName("BACKDROP", "", FBS_BD, "template", 0)
        call DzFrameSetTexture(FBS_BT[4], "UI_BossPage4.blp", 0)
        call DzFrameSetSize(FBS_BT[4], 0.20, 0.10)
        call DzFrameSetAbsolutePoint(FBS_BT[4], JN_FRAMEPOINT_CENTER, 0.2600, 0.4925)
        call DzFrameShow(FBS_BT[4], false)
        
        set FBS_BLB[4][1] = DzCreateFrameByTagName("BUTTON", "", FBS_BT[4], "ScoreScreenTabButtonTemplate", 0)
        call DzFrameSetAbsolutePoint(FBS_BLB[4][1], JN_FRAMEPOINT_CENTER, 0.2600, 0.3800)
        call DzFrameSetSize(FBS_BLB[4][1], 0.20, 0.10)
        call DzFrameSetScriptByCode(FBS_BLB[4][1], JN_FRAMEEVENT_MOUSE_UP, function ClickBBDButton, false)
        set FBS_BL[4][1]=DzCreateFrameByTagName("BACKDROP", "", FBS_BT[4], "template", 0)
        call DzFrameSetTexture(FBS_BL[4][1], "UI_Boss0_0_1.blp", 0)
        call DzFrameSetSize(FBS_BL[4][1], 0.20, 0.10)
        call DzFrameSetAbsolutePoint(FBS_BL[4][1], JN_FRAMEPOINT_CENTER, 0.2600, 0.3800)
        
        set FBS_BLB[4][2] = DzCreateFrameByTagName("BUTTON", "", FBS_BT[4], "ScoreScreenTabButtonTemplate", 0)
        call DzFrameSetAbsolutePoint(FBS_BLB[4][2], JN_FRAMEPOINT_CENTER, 0.2650, 0.2600)
        call DzFrameSetSize(FBS_BLB[4][2], 0.20, 0.10)
        call DzFrameSetScriptByCode(FBS_BLB[4][2], JN_FRAMEEVENT_MOUSE_UP, function ClickBBDButton, false)
        set FBS_BL[4][2]=DzCreateFrameByTagName("BACKDROP", "", FBS_BT[4], "template", 0)
        call DzFrameSetTexture(FBS_BL[4][2], "UI_Boss0_0_1.blp", 0)
        call DzFrameSetSize(FBS_BL[4][2], 0.20, 0.10)
        call DzFrameSetAbsolutePoint(FBS_BL[4][2], JN_FRAMEPOINT_CENTER, 0.2650, 0.2600)
        
        set FBS_BLB[4][3] = DzCreateFrameByTagName("BUTTON", "", FBS_BT[4], "ScoreScreenTabButtonTemplate", 0)
        call DzFrameSetAbsolutePoint(FBS_BLB[4][3], JN_FRAMEPOINT_CENTER, 0.2700, 0.1400)
        call DzFrameSetSize(FBS_BLB[4][3], 0.20, 0.10)
        call DzFrameSetScriptByCode(FBS_BLB[4][3], JN_FRAMEEVENT_MOUSE_UP, function ClickBBDButton, false)
        set FBS_BL[4][3]=DzCreateFrameByTagName("BACKDROP", "", FBS_BT[4], "template", 0)
        call DzFrameSetTexture(FBS_BL[4][3], "UI_Boss0_0_1.blp", 0)
        call DzFrameSetSize(FBS_BL[4][3], 0.20, 0.10)
        call DzFrameSetAbsolutePoint(FBS_BL[4][3], JN_FRAMEPOINT_CENTER, 0.2700, 0.1400)
    endif
    
        set FBS_SelectBBD=DzCreateFrameByTagName("BACKDROP", "", FBS_BD, "template", 0)
        call DzFrameSetTexture(FBS_SelectBBD, "UI_PickSelectButton.tga", 0)
        call DzFrameSetSize(FBS_SelectBBD, 0.06, 0.03)
        call DzFrameSetAbsolutePoint(FBS_SelectBBD, JN_FRAMEPOINT_CENTER, 0.5800, 0.1200)
        call DzFrameShow(FBS_SelectBBD, false)

        set FBS_SelectBT=DzCreateFrameByTagName("TEXT","",FBS_SelectBBD,"",0)
        call DzFrameSetAbsolutePoint(FBS_SelectBT, JN_FRAMEPOINT_CENTER, 0.5800, 0.1200)
        call DzFrameSetText(FBS_SelectBT,"결정")
        
        set FBS_SelectB=DzCreateFrameByTagName("BUTTON", "", FBS_SelectBBD, "ScoreScreenTabButtonTemplate", 0)
        call DzFrameSetAllPoints(FBS_SelectB, FBS_SelectBBD)
        call DzFrameSetSize(FBS_SelectB, 0.06, 0.03)
        call DzFrameSetScriptByCode(FBS_SelectB, JN_FRAMEEVENT_MOUSE_UP, function ClickPickBossButton, false)
        
        call DzFrameShow(FBS_BD, false)
    endfunction
    
    
    private function PickBossF takes nothing returns nothing
        local player p=(DzGetTriggerSyncPlayer())
        local integer BossNumber = S2I(DzGetTriggerSyncData())
        local integer pid = GetPlayerId(p)
        local integer HeroTypeId
        
        //튜토 카운터
        if BossNumber == 1 then
            //set HeroTypeId = 'H004'
            call Boss1Start(MainUnit[pid])
            
        //튜토 무력화
        elseif BossNumber == 2 then
            //set HeroTypeId = 'H003'
            call Boss2Start(MainUnit[pid])

        //테스트
        elseif BossNumber == 3 then
            //set HeroTypeId = 'H003'
            call Boss3Start(MainUnit[pid])

        //유유코
        //elseif BossNumber == 4 then
            //set HeroTypeId = 'H00F'
            //call Boss4Start(MainUnit[pid])
        endif
        
        set p = null
    endfunction
        
    
    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer index
        
        call TriggerRegisterTimerEventSingle( t, 0.10 )
        call TriggerAddAction( t, function Main )
        
        set index = 0
        loop
            set FBS_OnOff[index] = false
            set index = index + 1
            exitwhen index == bj_MAX_PLAYER_SLOTS
        endloop
        
        set t=CreateTrigger()
        call DzTriggerRegisterSyncData(t,("PickBoss"),(false))
        call TriggerAddAction(t,function PickBossF)
        
        set t = null
    endfunction
endlibrary