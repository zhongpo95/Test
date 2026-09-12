// 카드부여 화면과 재료 확인 및 부여 진행을 관리합니다.
library UIStone initializer Init requires DataItem, StatsSet, UIItem, UIPick, FrameCount
    globals
        integer F_StoneBackDrop                 //인포 배경
        integer array F_StoneBackDrop2          //인포 배경
        integer F_StoneCancelButton             //X버튼
        integer array F_Arcana1                 //스킬버튼
        integer array F_Arcana2                 //스킬버튼
        integer array F_Arcana3                 //스킬버튼
        integer array F_ArcanaButton            //스킬버튼 백드롭
        integer array F_ArcanaButton2           //스킬버튼 백드롭
        integer array F_ArcanaButton2BackDrop   //스킬버튼 백드롭
        integer array F_ArcanaText              //스킬버튼 백드롭
        integer array F_ArcanaTextA              //스킬버튼 백드롭
        integer array F_ArcanaTextB              //스킬버튼 백드롭
        integer array F_ArcanaTextC              //스킬버튼 백드롭
        integer ArcanaProbability = 0           //시작 전 화면에서도 사용하는 확률 보정값
        boolean array F_StoneOnOff              //인포 온오프
        
        integer array Arcana1
        integer array Arcana2
        integer array Arcana3
        integer loopASC
        integer loopBSC
        integer loopCSC
        integer ArcanaA = 0
        integer ArcanaB = 0
        integer ArcanaC = 0
        
        private boolean array StoneActive
        private boolean array StonePending
        private string array StoneResult
        private integer StoneStatus
        private integer StoneMaterial
        private integer StoneStartButton
        private integer StoneStartBD
        private integer StoneStartText
        private integer array StoneButtonText
        private integer si = 0
        private integer si2 = 0
    endglobals


    private function StoneSlot takes integer pid, boolean material returns integer
        local integer i = 0
        local integer limit = 50
        local string value
        local string sn = I2S(PlayerSlotNumber[pid])
        if material then
            set i = 50
            set limit = 100
        endif
        loop
            exitwhen i >= limit
            set value = StashLoad(PLAYER_DATA[pid], "영웅"+sn+".아이템"+I2S(i), "0")
            if material then
                if not IsEmptyItem(value) then
                    if GetItemIDs(value) == 39 and GetItemCharge(value) > 0 then
                        return i
                    endif
                endif
            elseif IsEmptyItem(value) then
                return i
            endif
            set i = i + 1
        endloop
        return -1
    endfunction

    private function StoneServerReady takes integer pid returns boolean
        // 서버 초기화에 실패한 테스트 세션에서는 연결 검사 네이티브를 호출하지 않습니다.
        if not PLAYER_DATA_SERVER_READY[pid] then
            return false
        endif
        return JNObjectCharacterServerConnectCheck()
    endfunction

    private function StoneRefresh takes integer pid returns nothing
        local integer i = 1
        local integer threshold
        local integer slot
        local integer count = 0
        local string value
        local string reason = "시작할 때 카드 부여 재료 1개를 사용합니다."
        local boolean ready = true
        if GetLocalPlayer() != Player(pid) then
            return
        endif
        set slot = 50
        loop
            exitwhen slot >= 100
            set value = StashLoad(PLAYER_DATA[pid], "영웅"+I2S(PlayerSlotNumber[pid])+".아이템"+I2S(slot), "0")
            // 빈 슬롯은 JN 정규식 기반 아이템 파서에 넘기지 않습니다.
            if not IsEmptyItem(value) then
                if GetItemIDs(value) == 39 then
                    set count = count + GetItemCharge(value)
                endif
            endif
            set slot = slot + 1
        endloop
        call DzFrameSetText(StoneMaterial, "카드 부여 재료   "+I2S(count)+"개 보유  /  시작 시 1개 필요")
        // 화면 갱신에서는 서버를 조회하지 않고 완료된 데이터 수신 상태만 표시합니다.
        if not PLAYER_DATA_SERVER_READY[pid] then
            set reason = "서버 데이터를 불러온 후 카드 부여를 시작할 수 있습니다."
            set ready = false
        elseif StoneSlot(pid, false) == -1 then
            set reason = "장비 창에 빈 공간이 필요합니다."
            set ready = false
        elseif count < 1 and not StoneActive[pid] and (StoneResult[pid] == null or StoneResult[pid] == "") then
            set reason = "카드 부여 재료가 부족합니다."
            set ready = false
        endif
        if StoneResult[pid] != null and StoneResult[pid] != "" then
            call DzFrameSetText(StoneStartText, "결과 받기")
            if ready then
                set reason = "부여 완료. 결과 카드를 받아 주세요."
            endif
        elseif StoneActive[pid] then
            call DzFrameSetText(StoneStartText, "부여 진행 중")
            if PLAYER_DATA_SERVER_READY[pid] then
                set reason = "탭을 이동하거나 닫아도 현재 부여는 유지됩니다."
            endif
            set ready = false
        else
            call DzFrameSetText(StoneStartText, "부여 시작")
        endif
        call DzFrameSetText(StoneStatus, reason)
        if ready then
            call DzFrameSetTexture(StoneStartBD, "war3mapImported\\UI_Upgrade_Action.tga", 0)
        else
            call DzFrameSetTexture(StoneStartBD, "war3mapImported\\UI_Upgrade_Disabled.tga", 0)
        endif
        // 조건이 바뀐 뒤에도 클릭으로 재검사할 수 있으며 차감은 StoneStart에서만 수행합니다.
        loop
            exitwhen i > 3
            call DzFrameSetEnable(F_ArcanaButton[i], StoneActive[pid] and not StonePending[pid] and PLAYER_DATA_SERVER_READY[pid])
            if not StoneActive[pid] or StonePending[pid] or (i == 1 and Arcana1[9] != 0) or (i == 2 and Arcana2[9] != 0) or (i == 3 and Arcana3[9] != 0) then
                call DzFrameSetEnable(F_ArcanaButton[i], false)
                call DzFrameSetTexture(F_ArcanaButton2BackDrop[i+3], "war3mapImported\\UI_Upgrade_Disabled.tga", 0)
            else
                call DzFrameSetTexture(F_ArcanaButton2BackDrop[i+3], "war3mapImported\\UI_Upgrade_Action.tga", 0)
            endif
            set i = i + 1
        endloop
        call DzFrameSetText(F_ArcanaText[6], I2S(ArcanaA)+"회 성공")
        call DzFrameSetText(F_ArcanaText[7], I2S(ArcanaB)+"회 성공")
        call DzFrameSetText(F_ArcanaText[8], I2S(ArcanaC)+"회 균열")
        set i = 0
        loop
            exitwhen i > 3
            set threshold = 6 + i
            if i > 1 then
                set threshold = threshold + 1
            endif
            call DzFrameShow(F_ArcanaTextA[i], true)
            call DzFrameShow(F_ArcanaTextB[i], true)
            call DzFrameSetText(F_ArcanaTextA[i], I2S(threshold)+"회 · Lv "+I2S(i+1))
            call DzFrameSetText(F_ArcanaTextB[i], I2S(threshold)+"회 · Lv "+I2S(i+1))
            call DzFrameSetTextColor(F_ArcanaTextA[i], JNConvertColor(255, 120, 150, 166))
            call DzFrameSetTextColor(F_ArcanaTextB[i], JNConvertColor(255, 120, 150, 166))
            if ArcanaA >= threshold then
                call DzFrameSetTextColor(F_ArcanaTextA[i], JNConvertColor(255, 22, 142, 174))
            endif
            if ArcanaB >= threshold then
                call DzFrameSetTextColor(F_ArcanaTextB[i], JNConvertColor(255, 22, 142, 174))
            endif
            if i < 3 then
                set threshold = 5 + i * 2
                if i == 2 then
                    set threshold = 10
                endif
                call DzFrameShow(F_ArcanaTextC[i], true)
                call DzFrameSetText(F_ArcanaTextC[i], I2S(threshold)+"회 · Lv "+I2S(i+1))
                call DzFrameSetTextColor(F_ArcanaTextC[i], JNConvertColor(255, 120, 150, 166))
                if ArcanaC >= threshold then
                    call DzFrameSetTextColor(F_ArcanaTextC[i], JNConvertColor(255, 200, 94, 123))
                endif
            endif
            set i = i + 1
        endloop
        call DzFrameSetText(F_ArcanaText[0], "부여 확률 "+I2S(75 - ArcanaProbability * 10)+"%")
        call DzFrameSetText(F_ArcanaText[1], "균열 확률 "+I2S(75 - ArcanaProbability * 10)+"%")
    endfunction

    function StoneSetOpen takes integer pid, boolean show returns nothing
        if GetLocalPlayer() != Player(pid) then
            return
        endif
        if show then
            call StoneRefresh(pid)
        endif
        call DzFrameShow(F_StoneBackDrop, show)
        if not show then
            call DzFrameShow(UI_Tip, false)
        endif
        set F_StoneOnOff[pid] = show
    endfunction

    function StoneStart takes integer pid returns boolean
        local integer i = 0
        local integer cardSlot
        local integer charge
        local string items
        local string sn = I2S(PlayerSlotNumber[pid])
        if GetLocalPlayer() != Player(pid) or StoneActive[pid] then
            return false
        endif
        if StoneResult[pid] != null and StoneResult[pid] != "" then
            return false
        endif
        if not StoneServerReady(pid) then
            call StoneRefresh(pid)
            call DzFrameSetText(StoneStatus, "서버 연결을 확인할 수 없어 시작하지 않았습니다.")
            return false
        endif
        if StoneSlot(pid, false) == -1 or StoneSlot(pid, true) == -1 then
            call StoneRefresh(pid)
            return false
        endif
        set cardSlot = StoneSlot(pid, true)
        set items = StashLoad(PLAYER_DATA[pid], "영웅"+sn+".아이템"+I2S(cardSlot), "0")
        set charge = GetItemCharge(items)
        if charge <= 1 then
            call DzFrameSetTexture(F_ItemButtonsBackDrop[cardSlot], "UI_Inventory.blp", 0)
            call StashRemove(PLAYER_DATA[pid], "영웅"+sn+".아이템"+I2S(cardSlot))
        else
            call StashSave(PLAYER_DATA[pid], "영웅"+sn+".아이템"+I2S(cardSlot), SetItemCharge(items, charge-1))
        endif
        set StoneActive[pid] = true
        set StonePending[pid] = false
        set StoneResult[pid] = ""
        set i = 0
        loop
            set Arcana1[i] = 0
            set Arcana2[i] = 0
            set Arcana3[i] = 0
            call DzFrameSetTexture(F_Arcana1[i], "war3mapImported\\UI_Upgrade_StepEmpty.tga", 0)
            call DzFrameSetTexture(F_Arcana2[i], "war3mapImported\\UI_Upgrade_StepEmpty.tga", 0)
            call DzFrameSetTexture(F_Arcana3[i], "war3mapImported\\UI_Upgrade_StepRisk.tga", 0)
            exitwhen i == 9
            set i = i + 1
        endloop

        set ArcanaA = 0
        set ArcanaB = 0
        set ArcanaC = 0
        set ArcanaProbability = 0
        set loopASC = 0
        set loopBSC = 0
        set loopCSC = 0
        call DzFrameSetText(F_ArcanaText[6], "|cff168eaeX 0|r")
        call DzFrameSetText(F_ArcanaText[7], "|cff168eaeX 0|r")
        call DzFrameSetText(F_ArcanaText[8], "|cffc85e7bX 0|r")
        call DzFrameSetText(F_ArcanaText[0], "부여 확률 |cff168eae75%|r")
        call DzFrameSetText(F_ArcanaText[1], "균열 확률 |cff168eae75%|r")

        call DzFrameShow(F_ArcanaTextA[0], true)
        call DzFrameShow(F_ArcanaTextA[1], true)
        call DzFrameShow(F_ArcanaTextA[2], true)
        call DzFrameShow(F_ArcanaTextA[3], true)
        call DzFrameShow(F_ArcanaTextB[0], true)
        call DzFrameShow(F_ArcanaTextB[1], true)
        call DzFrameShow(F_ArcanaTextB[2], true)
        call DzFrameShow(F_ArcanaTextB[3], true)
        call DzFrameShow(F_ArcanaTextC[0], true)
        call DzFrameShow(F_ArcanaTextC[1], true)
        call DzFrameShow(F_ArcanaTextC[2], true)
        call DzFrameSetText(F_ArcanaTextA[0], "Lv 1")
        call DzFrameSetText(F_ArcanaTextA[1], "Lv 2")
        call DzFrameSetText(F_ArcanaTextA[2], "Lv 3")
        call DzFrameSetText(F_ArcanaTextA[3], "Lv 4")
        call DzFrameSetText(F_ArcanaTextB[0], "Lv 1")
        call DzFrameSetText(F_ArcanaTextB[1], "Lv 2")
        call DzFrameSetText(F_ArcanaTextB[2], "Lv 3")
        call DzFrameSetText(F_ArcanaTextB[3], "Lv 4")
        call DzFrameSetText(F_ArcanaTextC[0], "Lv 1")
        call DzFrameSetText(F_ArcanaTextC[1], "Lv 2")
        call DzFrameSetText(F_ArcanaTextC[2], "Lv 3")
        call StoneSetOpen(pid, true)
        return true
    endfunction
    
    private function F_OFF_Actions takes nothing returns nothing
        call DzFrameShow(UI_Tip, false)
    endfunction
        
    private function F_ON_Actions takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        
        call DzFrameShow(UI_Tip, true)
        if f == F_ArcanaButton2[1] then
            //call DzFrameSetText(UI_Tip_Text[1], "|cff168eae"+ArcanaText[ArcanaOption[1]]+"|r")
            //call DzFrameSetText(UI_Tip_Text[2], " " + ArcanaText2[ArcanaOption[1]])
        elseif f == F_ArcanaButton2[2] then
            //call DzFrameSetText(UI_Tip_Text[1], "|cff168eae"+ArcanaText[ArcanaOption[2]]+"|r")
            //call DzFrameSetText(UI_Tip_Text[2], " " + ArcanaText2[ArcanaOption[2]])
        elseif f == F_ArcanaButton2[3] then
            //call DzFrameSetText(UI_Tip_Text[1], "|cFFFF0000"+ArcanaText[ArcanaOption[3]]+"|r")
            //call DzFrameSetText(UI_Tip_Text[2], " " + ArcanaText2[ArcanaOption[3]])
        endif
    endfunction
    
        // 아이템 타입: 0엘릭서, 1무기, 2목걸이, 3귀걸이, 4반지, 5팔찌, 6카드
        //장비 0아이템아이디, 1강화수치, 2품질, 3특성, 4각인1, 5각인수치, 6각인2, 7각인수치, 8각인P, 9각인P수치, 10잠금
        //목걸이 0스탯, 1체력, 2품0, 3품질 5당 추가량
        //기타 0아이템아이디, 1중첩수
            
    private function StoneBegin takes nothing returns nothing
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local integer slot
        if GetLocalPlayer() != Player(pid) then
            return
        endif
        if StoneResult[pid] != null and StoneResult[pid] != "" then
            set slot = StoneSlot(pid, false)
            if StoneServerReady(pid) and slot != -1 then
                call AddIvItem(pid, slot, StoneResult[pid])
                set StoneResult[pid] = ""
                set StoneActive[pid] = false
            endif
            call StoneRefresh(pid)
        elseif not StoneActive[pid] then
            call StoneStart(pid)
        endif
        call StoneRefresh(pid)
    endfunction

    private function ClickButton takes nothing returns nothing
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local integer i = 1
        if not StoneActive[pid] or StonePending[pid] then
            return
        endif
        loop
            exitwhen i > 3
            if DzGetTriggerUIEventFrame() == F_ArcanaButton[i] then
                set StonePending[pid] = true
                call StoneRefresh(pid)
                call DzSyncData("Work", I2S(i))
                return
            endif
            set i = i + 1
        endloop
    endfunction
    
    private function StoneOpen takes nothing returns nothing
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        call StoneSetOpen(pid, not F_StoneOnOff[pid])
    endfunction
    

    private function StonePanel takes integer parent, string texture, real x, real y, real w, real h returns integer
        local integer f = DzCreateFrameByTagName("BACKDROP", "", parent, "", FrameCount())
        call DzFrameSetPoint(f, JN_FRAMEPOINT_CENTER, parent, JN_FRAMEPOINT_BOTTOMLEFT, x, y)
        call DzFrameSetSize(f, w, h)
        call DzFrameSetTexture(f, texture, 0)
        return f
    endfunction

    private function StoneText takes integer parent, string value, real x, real y, real size returns integer
        local integer f = DzCreateFrameByTagName("TEXT", "", parent, "", FrameCount())
        call DzFrameSetPoint(f, JN_FRAMEPOINT_CENTER, parent, JN_FRAMEPOINT_BOTTOMLEFT, x, y)
        call DzFrameSetText(f, value)
        call DzFrameSetFont(f, "Fonts\\DFHeiMd.ttf", size, 0)
        call DzFrameSetTextColor(f, JNConvertColor(255, 49, 90, 112))
        return f
    endfunction

    private function Main takes nothing returns nothing
        local integer i = 0
        local integer row = 1
        local integer label
        local real y
        call DzLoadToc("Templates.toc")
        set F_StoneBackDrop = DzCreateFrameByTagName("BACKDROP", "", GetGameplayUI(), "", FrameCount())
        call DzFrameSetAbsolutePoint(F_StoneBackDrop, JN_FRAMEPOINT_CENTER, 0.3225, 0.2550)
        call DzFrameSetSize(F_StoneBackDrop, 0.405, 0.475)
        call DzFrameSetTexture(F_StoneBackDrop, "war3mapImported\\UI_Upgrade_Panel.tga", 0)
        call DzFrameSetPriority(F_StoneBackDrop, 110)
        set label = StonePanel(F_StoneBackDrop, "war3mapImported\\UI_Upgrade_Card.tga", 0.2025, 0.421, 0.365, 0.073)
        set StoneMaterial = StoneText(F_StoneBackDrop, "카드 부여 재료  /  시작 시 1개 필요", 0.2025, 0.429, 0.010)
        set F_ArcanaText[0] = StoneText(F_StoneBackDrop, "부여 확률 75%", 0.110, 0.402, 0.010)
        set F_ArcanaText[1] = StoneText(F_StoneBackDrop, "균열 확률 75%", 0.295, 0.402, 0.010)
        set F_StoneCancelButton = DzCreateFrameByTagName("BUTTON", "", F_StoneBackDrop, "", FrameCount())
        call DzFrameSetSize(F_StoneCancelButton, 0.020, 0.020)
        call DzFrameShow(F_StoneCancelButton, false)
        loop
            exitwhen row > 3
            set y = 0.325 - (row - 1) * 0.092
            set F_StoneBackDrop2[row] = StonePanel(F_StoneBackDrop, "war3mapImported\\UI_Upgrade_Row.tga", 0.2025, y, 0.365, 0.080)
            if row < 3 then
                set F_ArcanaText[row+2] = StoneText(F_StoneBackDrop, "대미지 증가 "+I2S(row)+"  ·  단계별 3 / 3.75 / 5.25 / 6%", 0.180, y+0.025, 0.008)
            else
                set F_ArcanaText[5] = StoneText(F_StoneBackDrop, "균열  ·  공격력 감소", 0.180, y+0.025, 0.009)
            endif
            set F_ArcanaText[row+5] = StoneText(F_StoneBackDrop, "0회 성공", 0.338, y+0.025, 0.008)
            set F_ArcanaButton[row] = DzCreateFrameByTagName("BUTTON", "", F_StoneBackDrop, "", FrameCount())
            call DzFrameSetPoint(F_ArcanaButton[row], JN_FRAMEPOINT_CENTER, F_StoneBackDrop, JN_FRAMEPOINT_BOTTOMLEFT, 0.340, y-0.008)
            call DzFrameSetSize(F_ArcanaButton[row], 0.065, 0.029)
            set F_ArcanaButton2BackDrop[row+3] = StonePanel(F_ArcanaButton[row], "war3mapImported\\UI_Upgrade_Action.tga", 0.0325, 0.0145, 0.065, 0.029)
            set StoneButtonText[row] = StoneText(F_ArcanaButton[row], "부여", 0.0325, 0.0145, 0.009)
            call DzFrameSetTextColor(StoneButtonText[row], JNConvertColor(255,255,255,255))
            call DzFrameSetScriptByCode(F_ArcanaButton[row], JN_FRAMEEVENT_MOUSE_UP, function ClickButton, false)
            call DzFrameSetEnable(F_ArcanaButton[row], false)
            set row = row + 1
        endloop
        call DzFrameSetText(StoneButtonText[3], "균열")
        loop
            exitwhen i > 9
            set F_Arcana1[i] = StonePanel(F_StoneBackDrop, "war3mapImported\\UI_Upgrade_StepEmpty.tga", 0.045+i*0.025, 0.320, 0.019, 0.020)
            set F_Arcana2[i] = StonePanel(F_StoneBackDrop, "war3mapImported\\UI_Upgrade_StepEmpty.tga", 0.045+i*0.025, 0.228, 0.019, 0.020)
            set F_Arcana3[i] = StonePanel(F_StoneBackDrop, "war3mapImported\\UI_Upgrade_StepRisk.tga", 0.045+i*0.025, 0.136, 0.019, 0.020)
            set i = i + 1
        endloop
        set i = 0
        loop
            exitwhen i > 3
            set F_ArcanaTextA[i] = StoneText(F_StoneBackDrop, "Lv "+I2S(i+1), 0.070+i*0.064, 0.296, 0.008)
            set F_ArcanaTextB[i] = StoneText(F_StoneBackDrop, "Lv "+I2S(i+1), 0.070+i*0.064, 0.204, 0.008)
            if i < 3 then
                set F_ArcanaTextC[i] = StoneText(F_StoneBackDrop, "Lv "+I2S(i+1), 0.080+i*0.080, 0.112, 0.008)
            endif
            set i = i + 1
        endloop
        set StoneStatus = StoneText(F_StoneBackDrop, "시작할 때 재료 1개를 사용합니다.", 0.2025, 0.072, 0.009)
        call DzFrameSetSize(StoneStatus, 0.355, 0.028)
        call DzFrameSetTextAlignment(StoneStatus, JN_TEXT_JUSTIFY_CENTER)
        set StoneStartButton = DzCreateFrameByTagName("BUTTON", "", F_StoneBackDrop, "", FrameCount())
        call DzFrameSetPoint(StoneStartButton, JN_FRAMEPOINT_CENTER, F_StoneBackDrop, JN_FRAMEPOINT_BOTTOMLEFT, 0.2025, 0.035)
        call DzFrameSetSize(StoneStartButton, 0.170, 0.036)
        set StoneStartBD = StonePanel(StoneStartButton, "war3mapImported\\UI_Upgrade_Action.tga", 0.085, 0.018, 0.170, 0.036)
        set StoneStartText = StoneText(StoneStartButton, "부여 시작", 0.085, 0.018, 0.011)
        call DzFrameSetTextColor(StoneStartText, JNConvertColor(255,255,255,255))
        call DzFrameSetScriptByCode(StoneStartButton, JN_FRAMEEVENT_MOUSE_UP, function StoneBegin, false)
        call DzFrameShow(F_StoneBackDrop, false)
    endfunction
    
    private function ESCAction takes nothing returns nothing
        if F_StoneOnOff[GetPlayerId(GetTriggerPlayer())] == true then
            if ( GetTriggerPlayer() == GetLocalPlayer() ) then
                call DzFrameShow(F_StoneBackDrop, false)
            endif
            set F_StoneOnOff[GetPlayerId(GetTriggerPlayer())] = false
        endif
    endfunction
    
    private function ButtonWork takes nothing returns nothing
        local player p=(DzGetTriggerSyncPlayer())
        local integer f = S2I(DzGetTriggerSyncData())
        local integer pid = GetPlayerId(p)
        local integer i = GetRandomInt(1,100)
        local integer loopA
        local integer loopB
        local integer loopC
        local integer A
        local integer B
        local integer C
        local string items
        local string sn = I2S(PlayerSlotNumber[pid])
        
        if p == GetLocalPlayer() then
            set StonePending[pid] = false
            if not StoneActive[pid] or f < 1 or f > 3 or (StoneResult[pid] != null and StoneResult[pid] != "") then
                set p = null
                return
            endif
            set loopA = 0
            loop
                exitwhen Arcana1[loopA] == 0 or loopA == 10
                set loopA = loopA + 1
            endloop
            set loopB = 0
            loop
                exitwhen Arcana2[loopB] == 0 or loopB == 10
                set loopB = loopB + 1
            endloop
            set loopC = 0
            loop
                exitwhen Arcana3[loopC] == 0 or loopC == 10
                set loopC = loopC + 1
            endloop
                
            if loopA == 10 and loopB == 10 and loopC == 10 then
                return
            endif
            
            if StoneServerReady(pid) then
                if f == 1 then
                    if loopA != 10 then
                        if (75 - (ArcanaProbability * 10 )) >= i then
                            //성공
                            call DzFrameSetTexture(F_Arcana1[loopA], "war3mapImported\\UI_Upgrade_StepSuccess.tga", 0)
                            set Arcana1[loopA] = 1
                            set ArcanaProbability = ArcanaProbability + 1
                            if ArcanaProbability > 5 then
                                set ArcanaProbability = 5
                            endif
                            call DzFrameSetText(F_ArcanaText[0], "부여 확률 |cff168eae" + I2S(75 - (ArcanaProbability * 10 )) + "%|r")
                            call DzFrameSetText(F_ArcanaText[1], "균열 확률 |cff168eae" + I2S(75 - (ArcanaProbability * 10 )) + "%|r")
                            set ArcanaA = ArcanaA + 1
                            if ArcanaA == 6 then
                                call DzFrameSetText(F_ArcanaTextA[0], "|cff168eae"+ "Lv 1|r")
                            endif
                            if ArcanaA == 7 then
                                call DzFrameSetText(F_ArcanaTextA[1], "|cff168eae"+ "Lv 2|r")
                            endif
                            if ArcanaA == 9 then
                                call DzFrameSetText(F_ArcanaTextA[2], "|cff168eae"+ "Lv 3|r")
                            endif
                            if ArcanaA == 10 then
                                call DzFrameSetText(F_ArcanaTextA[3], "|cff168eae"+ "Lv 4|r")
                            endif
                            call DzFrameSetText(F_ArcanaText[6], "|cff168eaeX " + I2S(ArcanaA) + "|r")
                            set si = si + 1
                            if si == 1 then
                                call StartSound(gg_snd_StoneEffectSound7)
                            elseif si == 2 then
                                call StartSound(gg_snd_StoneEffectSound8)
                            elseif si == 3 then
                                call StartSound(gg_snd_StoneEffectSound9)
                                set si = 0
                            endif
                        else
                            //실패
                            call DzFrameSetTexture(F_Arcana1[loopA], "war3mapImported\\UI_Upgrade_StepFail.tga", 0)
                            set Arcana1[loopA] = 2
                            set ArcanaProbability = ArcanaProbability - 1
                            if ArcanaProbability < 0 then
                                set ArcanaProbability = 0
                            endif
                            call DzFrameSetText(F_ArcanaText[0], "부여 확률 |cff168eae" + I2S(75 - (ArcanaProbability * 10 )) + "%|r")
                            call DzFrameSetText(F_ArcanaText[1], "균열 확률 |cff168eae" + I2S(75 - (ArcanaProbability * 10 )) + "%|r")
                            set loopASC = loopASC + 1
                            if loopASC < 5 then
                            elseif loopASC == 5 then
                                call DzFrameShow(F_ArcanaTextA[0],false)
                            endif
                            if loopASC < 4 then
                            elseif loopASC == 4 then
                                call DzFrameShow(F_ArcanaTextA[1],false)
                            endif
                            if loopASC < 2 then
                            elseif loopASC == 2 then
                                call DzFrameShow(F_ArcanaTextA[2],false)
                            endif
                            if loopASC == 1 then
                                call DzFrameShow(F_ArcanaTextA[3],false)
                            endif
                            set si2 = si2 + 1
                            if si2 == 1 then
                                call StartSound(gg_snd_StoneEffectSound4)
                            elseif si2 == 2 then
                                call StartSound(gg_snd_StoneEffectSound5)
                            elseif si2 == 3 then
                                call StartSound(gg_snd_StoneEffectSound6)
                                set si2 = 0
                            endif
                        endif
                        set loopA = loopA + 1
                    endif
                elseif f == 2 then
                    if loopB != 10 then
                        if (75 - (ArcanaProbability * 10 )) >= i then
                            //성공
                            call DzFrameSetTexture(F_Arcana2[loopB], "war3mapImported\\UI_Upgrade_StepSuccess.tga", 0)
                            set Arcana2[loopB] = 1
                            set ArcanaProbability = ArcanaProbability + 1
                            if ArcanaProbability > 5 then
                                set ArcanaProbability = 5
                            endif
                            call DzFrameSetText(F_ArcanaText[0], "부여 확률 |cff168eae" + I2S(75 - (ArcanaProbability * 10 )) + "%|r")
                            call DzFrameSetText(F_ArcanaText[1], "균열 확률 |cff168eae" + I2S(75 - (ArcanaProbability * 10 )) + "%|r")
                            set ArcanaB = ArcanaB + 1
                            if ArcanaB == 6 then
                                call DzFrameSetText(F_ArcanaTextB[0], "|cff168eae"+ "Lv 1|r")
                            endif
                            if ArcanaB == 7 then
                                call DzFrameSetText(F_ArcanaTextB[1], "|cff168eae"+ "Lv 2|r")
                            endif
                            if ArcanaB == 9 then
                                call DzFrameSetText(F_ArcanaTextB[2], "|cff168eae"+ "Lv 3|r")
                            endif
                            if ArcanaB == 10 then
                                call DzFrameSetText(F_ArcanaTextB[3], "|cff168eae"+ "Lv 4|r")
                            endif
                            call DzFrameSetText(F_ArcanaText[7], "|cff168eaeX " + I2S(ArcanaB) + "|r")
                            set si = si + 1
                            if si == 1 then
                                call StartSound(gg_snd_StoneEffectSound7)
                            elseif si == 2 then
                                call StartSound(gg_snd_StoneEffectSound8)
                            elseif si == 3 then
                                call StartSound(gg_snd_StoneEffectSound9)
                                set si = 0
                            endif
                        else
                            //실패
                            call DzFrameSetTexture(F_Arcana2[loopB], "war3mapImported\\UI_Upgrade_StepFail.tga", 0)
                            set Arcana2[loopB] = 2
                            set ArcanaProbability = ArcanaProbability - 1
                            if ArcanaProbability < 0 then
                                set ArcanaProbability = 0
                            endif
                            call DzFrameSetText(F_ArcanaText[0], "부여 확률 |cff168eae" + I2S(75 - (ArcanaProbability * 10 )) + "%|r")
                            call DzFrameSetText(F_ArcanaText[1], "균열 확률 |cff168eae" + I2S(75 - (ArcanaProbability * 10 )) + "%|r")
                            set loopBSC = loopBSC + 1
                            if loopBSC < 5 then
                            elseif loopBSC == 5 then
                                call DzFrameShow(F_ArcanaTextB[0],false)
                            endif
                            if loopBSC < 4 then
                            elseif loopBSC == 4 then
                                call DzFrameShow(F_ArcanaTextB[1],false)
                            endif
                            if loopBSC < 2 then
                            elseif loopBSC == 2 then
                                call DzFrameShow(F_ArcanaTextB[2],false)
                            endif
                            if loopBSC == 1 then
                                call DzFrameShow(F_ArcanaTextB[3],false)
                            endif
                            set si2 = si2 + 1
                            if si2 == 1 then
                                call StartSound(gg_snd_StoneEffectSound4)
                            elseif si2 == 2 then
                                call StartSound(gg_snd_StoneEffectSound5)
                            elseif si2 == 3 then
                                call StartSound(gg_snd_StoneEffectSound6)
                                set si2 = 0
                            endif
                            set si2 = si2 + 1
                            if si2 == 1 then
                                call StartSound(gg_snd_StoneEffectSound4)
                            elseif si2 == 2 then
                                call StartSound(gg_snd_StoneEffectSound5)
                            elseif si2 == 3 then
                                call StartSound(gg_snd_StoneEffectSound6)
                                set si2 = 0
                            endif
                        endif
                        set loopB = loopB + 1
                    endif
                elseif f == 3 then
                    if loopC != 10 then
                        if (75 - (ArcanaProbability * 10 )) >= i then
                            //성공
                            call DzFrameSetTexture(F_Arcana3[loopC], "war3mapImported\\UI_Upgrade_StepPenalty.tga", 0)
                            set Arcana3[loopC] = 1
                            set ArcanaProbability = ArcanaProbability + 1
                            if ArcanaProbability > 5 then
                                set ArcanaProbability = 5
                            endif
                            call DzFrameSetText(F_ArcanaText[0], "부여 확률 |cff168eae" + I2S(75 - (ArcanaProbability * 10 )) + "%|r")
                            call DzFrameSetText(F_ArcanaText[1], "균열 확률 |cff168eae" + I2S(75 - (ArcanaProbability * 10 )) + "%|r")
                            set ArcanaC = ArcanaC + 1
                            if ArcanaC == 5 then
                                call DzFrameSetText(F_ArcanaTextC[0], "|cffc85e7b"+ "Lv 1|r")
                            endif
                            if ArcanaC == 7 then
                                call DzFrameSetText(F_ArcanaTextC[1], "|cffc85e7b"+ "Lv 2|r")
                            endif
                            if ArcanaC == 10 then
                                call DzFrameSetText(F_ArcanaTextC[2], "|cffc85e7b"+ "Lv 3|r")
                            endif
                            call DzFrameSetText(F_ArcanaText[8], "|cffc85e7bX " + I2S(ArcanaC)+ "|r")
                            set si = si + 1
                            if si == 1 then
                                call StartSound(gg_snd_StoneEffectSound7)
                            elseif si == 2 then
                                call StartSound(gg_snd_StoneEffectSound8)
                            elseif si == 3 then
                                call StartSound(gg_snd_StoneEffectSound9)
                                set si = 0
                            endif
                        else
                            //실패
                            call DzFrameSetTexture(F_Arcana3[loopC], "war3mapImported\\UI_Upgrade_StepFail.tga", 0)
                            set Arcana3[loopC] = 2
                            set ArcanaProbability = ArcanaProbability - 1
                            if ArcanaProbability < 0 then
                                set ArcanaProbability = 0
                            endif
                            call DzFrameSetText(F_ArcanaText[0], "부여 확률 |cff168eae" + I2S(75 - (ArcanaProbability * 10 )) + "%|r")
                            call DzFrameSetText(F_ArcanaText[1], "균열 확률 |cff168eae" + I2S(75 - (ArcanaProbability * 10 )) + "%|r")
                            set loopCSC = loopCSC + 1
                            if loopCSC < 6 then
                            elseif loopCSC == 6 then
                                call DzFrameShow(F_ArcanaTextC[0],false)
                            endif
                            if loopCSC < 4 then
                            elseif loopCSC == 4 then
                                call DzFrameShow(F_ArcanaTextC[1],false)
                            endif
                            if loopCSC == 1 then
                                call DzFrameShow(F_ArcanaTextC[2],false)
                            endif
                            set si2 = si2 + 1
                            if si2 == 1 then
                                call StartSound(gg_snd_StoneEffectSound4)
                            elseif si2 == 2 then
                                call StartSound(gg_snd_StoneEffectSound5)
                            elseif si2 == 3 then
                                call StartSound(gg_snd_StoneEffectSound6)
                                set si2 = 0
                            endif
                        endif
                        set loopC = loopC + 1
                    endif
                endif
                
                if loopA == 10 and loopB == 10 and loopC == 10 then
                    set A = ArcanaA
                    set B = ArcanaB
                    set C = ArcanaC
                    set items = "ID13;"
                    if A >= 10 then
                        set A = 4
                    elseif A >= 9 then
                        set A = 3
                    elseif A >= 7 then
                        set A = 2
                    elseif A >= 6 then
                        set A = 1
                    else
                        set A = 0
                    endif
                    set items = SetItemCardBonus1(items,A)
                    if B >= 10 then
                        set B = 4
                    elseif B >= 9 then
                        set B = 3
                    elseif B >= 7 then
                        set B = 2
                    elseif B >= 6 then
                        set B = 1
                    else
                        set B = 0
                    endif
                    set items = SetItemCardBonus2(items,B)
                    if C >= 10 then
                        set C = 3
                    elseif C >= 7 then
                        set C = 2
                    elseif C >= 5 then
                        set C = 1
                    else
                        set C = 0
                    endif
                    set items = SetItemCardBonus3(items,C)
                    set StoneResult[pid] = items
                    set StoneActive[pid] = false
                endif
            else
                call VJDebugMsg("서버에 연결되지 않았습니다.")
            endif
        endif
        call StoneRefresh(pid)
        set p=null
    endfunction
        
    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer index
        
        call TriggerRegisterTimerEventSingle( t, 0.10 )
        call TriggerAddAction( t, function Main )
        
        set index = 0
        loop
            set F_StoneOnOff[index] = false
            set index = index + 1
            exitwhen index == bj_MAX_PLAYER_SLOTS
        endloop
        
        set t=CreateTrigger()
        call DzTriggerRegisterSyncData(t,("Work"),(false))
        call TriggerAddAction(t,function ButtonWork)
        
        set t = null
    endfunction
endlibrary
