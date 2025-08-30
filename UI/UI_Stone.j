library UIStone initializer Init requires DataItem, StatsSet, UIItem, FrameCount
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
        integer ArcanaProbability               //확률
        boolean array F_StoneOnOff              //인포 온오프
        
        integer array Arcana1
        integer array Arcana2
        integer array Arcana3
        integer loopASC
        integer loopBSC
        integer loopCSC
        integer ArcanaA
        integer ArcanaB
        integer ArcanaC
        
        private integer si = 0
        private integer si2 = 0
    endglobals
    
    private function F_OFF_Actions takes nothing returns nothing
        call DzFrameShow(UI_Tip, false)
    endfunction
        
    private function F_ON_Actions takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        
        call DzFrameShow(UI_Tip, true)
        if f == F_ArcanaButton2[1] then
            //call DzFrameSetText(UI_Tip_Text[1], "|cFFFFE400"+ArcanaText[ArcanaOption[1]]+"|r")
            //call DzFrameSetText(UI_Tip_Text[2], " " + ArcanaText2[ArcanaOption[1]])
        elseif f == F_ArcanaButton2[2] then
            //call DzFrameSetText(UI_Tip_Text[1], "|cFFFFE400"+ArcanaText[ArcanaOption[2]]+"|r")
            //call DzFrameSetText(UI_Tip_Text[2], " " + ArcanaText2[ArcanaOption[2]])
        elseif f == F_ArcanaButton2[3] then
            //call DzFrameSetText(UI_Tip_Text[1], "|cFFFF0000"+ArcanaText[ArcanaOption[3]]+"|r")
            //call DzFrameSetText(UI_Tip_Text[2], " " + ArcanaText2[ArcanaOption[3]])
        endif
    endfunction
    
        // 0모자, 1상의, 2하의, 3장갑, 4견갑, 5무기, 6목걸이, 7귀걸이, 8반지, 9팔찌, 10카드
        //장비 0아이템아이디, 1강화수치, 2품질, 3특성, 4각인1, 5각인수치, 6각인2, 7각인수치, 8각인P, 9각인P수치, 10잠금
        //목걸이 0스탯, 1체력, 2품0, 3품질 5당 추가량
        //기타 0아이템아이디, 1중첩수
            
    private function ClickButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        call DzSyncData(("Work"),I2S(f))
    endfunction
    
    private function StoneOpen takes nothing returns nothing
        //메뉴 버튼을 누르면 메뉴 버튼 비활설화 + 메뉴 배경 표시
        //다시 메뉴 버튼을 누르면 메뉴버튼 활성화 + 메뉴 배경 숨김
        if F_StoneOnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] == true then
            call DzFrameShow(F_StoneBackDrop, false)
            set F_StoneOnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = false
        else
            call DzFrameShow(F_StoneBackDrop, true)
            set F_StoneOnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = true
        endif
    endfunction
    
    private function Main takes nothing returns nothing
        local string s
        local integer i
        call DzLoadToc("war3mapImported\\Templates.toc")
        
        //메뉴 배경
        set F_StoneBackDrop=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "template", FrameCount())
        call DzFrameSetAbsolutePoint(F_StoneBackDrop, JN_FRAMEPOINT_CENTER, 0.225, 0.320)
        call DzFrameSetTexture(F_StoneBackDrop, "Stonebackdrop.blp", 0)
        call DzFrameSetSize(F_StoneBackDrop, 0.40, 0.30)

        //메뉴 취소 버튼
        set F_StoneCancelButton = DzCreateFrameByTagName("GLUETEXTBUTTON", "", F_StoneBackDrop, "ScriptDialogButton", FrameCount())
        call DzFrameSetPoint(F_StoneCancelButton, JN_FRAMEPOINT_TOPRIGHT, F_StoneBackDrop , JN_FRAMEPOINT_TOPRIGHT, -0.010, -0.010)
        call DzFrameSetText(F_StoneCancelButton, "X")
        call DzFrameSetSize(F_StoneCancelButton, 0.03, 0.03)
        call DzFrameSetScriptByCode(F_StoneCancelButton, JN_FRAMEEVENT_MOUSE_UP, function StoneOpen, false)
        
        set F_StoneBackDrop2[1]=DzCreateFrameByTagName("BACKDROP", "", F_StoneBackDrop, "StandardEditBoxBackdropTemplate", FrameCount())
        call DzFrameSetPoint(F_StoneBackDrop2[1], JN_FRAMEPOINT_CENTER, F_StoneBackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.165, 0.225 )
        call DzFrameSetSize(F_StoneBackDrop2[1], 0.270, 0.046)
        set F_StoneBackDrop2[2]=DzCreateFrameByTagName("BACKDROP", "", F_StoneBackDrop, "StandardEditBoxBackdropTemplate", FrameCount())
        call DzFrameSetPoint(F_StoneBackDrop2[2], JN_FRAMEPOINT_CENTER, F_StoneBackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.165, 0.165)
        call DzFrameSetSize(F_StoneBackDrop2[2], 0.270, 0.046)
        set F_StoneBackDrop2[3]=DzCreateFrameByTagName("BACKDROP", "", F_StoneBackDrop, "StandardEditBoxBackdropTemplate", FrameCount())
        call DzFrameSetPoint(F_StoneBackDrop2[3], JN_FRAMEPOINT_CENTER, F_StoneBackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.165, 0.050)
        call DzFrameSetSize(F_StoneBackDrop2[3], 0.270, 0.046)
        
        set i = 0
        loop
            set F_Arcana1[i]=DzCreateFrameByTagName("BACKDROP", "", F_StoneBackDrop, "StandardEditBoxBackdropTemplate", FrameCount())
            call DzFrameSetPoint(F_Arcana1[i], JN_FRAMEPOINT_CENTER, F_StoneBackDrop , JN_FRAMEPOINT_BOTTOMLEFT, (0.025 * i) + 0.053 , 0.230 )
            call DzFrameSetSize(F_Arcana1[i], 0.02125 , 0.02125)
            call DzFrameSetTexture(F_Arcana1[i], "UI_Arcana_Work1.blp", 0)
            set F_Arcana2[i]=DzCreateFrameByTagName("BACKDROP", "", F_StoneBackDrop, "StandardEditBoxBackdropTemplate", FrameCount())
            call DzFrameSetPoint(F_Arcana2[i], JN_FRAMEPOINT_CENTER, F_StoneBackDrop , JN_FRAMEPOINT_BOTTOMLEFT, (0.025 * i) + 0.053 , 0.170 )
            call DzFrameSetSize(F_Arcana2[i], 0.02125 , 0.02125)
            call DzFrameSetTexture(F_Arcana2[i], "UI_Arcana_Work1.blp", 0)
            set F_Arcana3[i]=DzCreateFrameByTagName("BACKDROP", "", F_StoneBackDrop, "StandardEditBoxBackdropTemplate", FrameCount())
            call DzFrameSetPoint(F_Arcana3[i], JN_FRAMEPOINT_CENTER, F_StoneBackDrop , JN_FRAMEPOINT_BOTTOMLEFT, (0.025 * i) + 0.053 , 0.055 )
            call DzFrameSetSize(F_Arcana3[i], 0.02125 , 0.02125)
            call DzFrameSetTexture(F_Arcana3[i], "UI_Arcana_Work3.blp", 0)
        exitwhen i == 9
            set i = i + 1
        endloop
        
        set F_ArcanaButton[1]=DzCreateFrameByTagName("BUTTON", "", F_StoneBackDrop, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetPoint(F_ArcanaButton[1], JN_FRAMEPOINT_CENTER, F_StoneBackDrop ,  JN_FRAMEPOINT_BOTTOMLEFT, 0.330, 0.225 )
        call DzFrameSetSize(F_ArcanaButton[1], 0.060 , 0.040)
        call DzFrameSetScriptByCode(F_ArcanaButton[1], JN_FRAMEEVENT_MOUSE_UP, function ClickButton, false)
        set F_ArcanaButton2BackDrop[4]=DzCreateFrameByTagName("BACKDROP", "", F_ArcanaButton[1], "", FrameCount())
        call DzFrameSetAllPoints(F_ArcanaButton2BackDrop[4], F_ArcanaButton[1])
        call DzFrameSetTexture(F_ArcanaButton2BackDrop[4],"ReplaceableTextures\\CommandButtons\\BTNAnvil.blp", 0)
        set F_ArcanaButton[2]=DzCreateFrameByTagName("BUTTON", "", F_StoneBackDrop, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetPoint(F_ArcanaButton[2], JN_FRAMEPOINT_CENTER, F_StoneBackDrop ,  JN_FRAMEPOINT_BOTTOMLEFT, 0.330, 0.165 )
        call DzFrameSetSize(F_ArcanaButton[2], 0.060 , 0.040)
        call DzFrameSetScriptByCode(F_ArcanaButton[2], JN_FRAMEEVENT_MOUSE_UP, function ClickButton, false)
        set F_ArcanaButton2BackDrop[5]=DzCreateFrameByTagName("BACKDROP", "", F_ArcanaButton[2], "", FrameCount())
        call DzFrameSetAllPoints(F_ArcanaButton2BackDrop[5], F_ArcanaButton[2])
        call DzFrameSetTexture(F_ArcanaButton2BackDrop[5],"ReplaceableTextures\\CommandButtons\\BTNAnvil.blp", 0)
        set F_ArcanaButton[3]=DzCreateFrameByTagName("BUTTON", "", F_StoneBackDrop, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetPoint(F_ArcanaButton[3], JN_FRAMEPOINT_CENTER, F_StoneBackDrop ,  JN_FRAMEPOINT_BOTTOMLEFT, 0.330, 0.05)
        call DzFrameSetSize(F_ArcanaButton[3], 0.060 , 0.040)
        call DzFrameSetScriptByCode(F_ArcanaButton[3], JN_FRAMEEVENT_MOUSE_UP, function ClickButton, false)
        set F_ArcanaButton2BackDrop[6]=DzCreateFrameByTagName("BACKDROP", "", F_ArcanaButton[3], "", FrameCount())
        call DzFrameSetAllPoints(F_ArcanaButton2BackDrop[6], F_ArcanaButton[3])
        call DzFrameSetTexture(F_ArcanaButton2BackDrop[6],"ReplaceableTextures\\CommandButtons\\BTNAnvil.blp", 0)
        
        set F_ArcanaText[0]=DzCreateFrameByTagName("TEXT", "", F_StoneBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_ArcanaText[0], JN_FRAMEPOINT_CENTER, F_StoneBackDrop ,  JN_FRAMEPOINT_BOTTOMLEFT, 0.330, 0.255 )
        call DzFrameSetText(F_ArcanaText[0], "부여 확률 |cFFFFE400" + I2S(75) + "%|r")
        call DzFrameSetFont(F_ArcanaText[0], "Fonts\\DFHeiMd.ttf", 0.010, 0)
        set F_ArcanaText[1]=DzCreateFrameByTagName("TEXT", "", F_StoneBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_ArcanaText[1], JN_FRAMEPOINT_CENTER, F_StoneBackDrop ,  JN_FRAMEPOINT_BOTTOMLEFT, 0.330, 0.080 )
        call DzFrameSetText(F_ArcanaText[1], "균열 확률 |cFFFFE400" + I2S(75) + "%|r")
        call DzFrameSetFont(F_ArcanaText[1], "Fonts\\DFHeiMd.ttf", 0.010, 0)
        
        set F_ArcanaText[3]=DzCreateFrameByTagName("TEXT", "", F_StoneBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_ArcanaText[3], JN_FRAMEPOINT_CENTER, F_StoneBackDrop ,  JN_FRAMEPOINT_BOTTOMLEFT, 0.135, 0.255 )
        call DzFrameSetText(F_ArcanaText[3], "|cff5AD2FF" + "Lv 마다 3/3.75/5.25/6% 대미지 증가|r")
        call DzFrameSetFont(F_ArcanaText[3], "Fonts\\DFHeiMd.ttf", 0.010, 0)
        call DzFrameSetTextAlignment(F_ArcanaText[3], JN_TEXT_JUSTIFY_MIDDLE)
        set F_ArcanaText[4]=DzCreateFrameByTagName("TEXT", "", F_StoneBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_ArcanaText[4], JN_FRAMEPOINT_CENTER, F_StoneBackDrop ,  JN_FRAMEPOINT_BOTTOMLEFT, 0.135, 0.195 )
        call DzFrameSetText(F_ArcanaText[4], "|cff5AD2FF" + "Lv 마다 3/3.75/5.25/6% 대미지 증가|r")
        call DzFrameSetFont(F_ArcanaText[4], "Fonts\\DFHeiMd.ttf", 0.010, 0)
        call DzFrameSetTextAlignment(F_ArcanaText[4], JN_TEXT_JUSTIFY_MIDDLE)
        set F_ArcanaText[5]=DzCreateFrameByTagName("TEXT", "", F_StoneBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_ArcanaText[5], JN_FRAMEPOINT_CENTER, F_StoneBackDrop ,  JN_FRAMEPOINT_BOTTOMLEFT, 0.065, 0.080 )
        call DzFrameSetText(F_ArcanaText[5], "|cffFF0000" + "공격력 감소|r")
        call DzFrameSetFont(F_ArcanaText[5], "Fonts\\DFHeiMd.ttf", 0.010, 0)
        call DzFrameSetTextAlignment(F_ArcanaText[5], JN_TEXT_JUSTIFY_MIDDLE)
        
        set F_ArcanaText[6]=DzCreateFrameByTagName("TEXT", "", F_StoneBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_ArcanaText[6], JN_FRAMEPOINT_CENTER, F_StoneBackDrop ,  JN_FRAMEPOINT_BOTTOMLEFT, 0.275, 0.255 )
        call DzFrameSetText(F_ArcanaText[6], "|cff5AD2FFX " + "0" + "|r")
        call DzFrameSetFont(F_ArcanaText[6], "Fonts\\DFHeiMd.ttf", 0.010, 0)
        call DzFrameSetTextAlignment(F_ArcanaText[6], JN_TEXT_JUSTIFY_MIDDLE)
        set F_ArcanaText[7]=DzCreateFrameByTagName("TEXT", "", F_StoneBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_ArcanaText[7], JN_FRAMEPOINT_CENTER, F_StoneBackDrop ,  JN_FRAMEPOINT_BOTTOMLEFT, 0.275, 0.195)
        call DzFrameSetText(F_ArcanaText[7], "|cff5AD2FFX " + "0" + "|r")
        call DzFrameSetFont(F_ArcanaText[7], "Fonts\\DFHeiMd.ttf", 0.010, 0)
        call DzFrameSetTextAlignment(F_ArcanaText[7], JN_TEXT_JUSTIFY_MIDDLE)
        set F_ArcanaText[8]=DzCreateFrameByTagName("TEXT", "", F_StoneBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_ArcanaText[8], JN_FRAMEPOINT_CENTER, F_StoneBackDrop ,  JN_FRAMEPOINT_BOTTOMLEFT, 0.275, 0.080 )
        call DzFrameSetText(F_ArcanaText[8], "|cffFF0000X " + "0" + "|r")
        call DzFrameSetFont(F_ArcanaText[8], "Fonts\\DFHeiMd.ttf", 0.010, 0)
        call DzFrameSetTextAlignment(F_ArcanaText[8], JN_TEXT_JUSTIFY_MIDDLE)
        
        set F_Arcana1[10]=DzCreateFrameByTagName("BACKDROP", "", F_StoneBackDrop, "StandardEditBoxBackdropTemplate", FrameCount())
        call DzFrameSetPoint(F_Arcana1[10], JN_FRAMEPOINT_CENTER, F_StoneBackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.255, 0.255)
        call DzFrameSetSize(F_Arcana1[10], 0.02125 , 0.02125)
        call DzFrameSetTexture(F_Arcana1[10], "UI_Arcana_Work2.blp", 0)
        set F_Arcana2[11]=DzCreateFrameByTagName("BACKDROP", "", F_StoneBackDrop, "StandardEditBoxBackdropTemplate", FrameCount())
        call DzFrameSetPoint(F_Arcana2[11], JN_FRAMEPOINT_CENTER, F_StoneBackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.255 , 0.195)
        call DzFrameSetSize(F_Arcana2[11], 0.02125 , 0.02125)
        call DzFrameSetTexture(F_Arcana2[11], "UI_Arcana_Work2.blp", 0)
        set F_Arcana3[12]=DzCreateFrameByTagName("BACKDROP", "", F_StoneBackDrop, "StandardEditBoxBackdropTemplate", FrameCount())
        call DzFrameSetPoint(F_Arcana3[12], JN_FRAMEPOINT_CENTER, F_StoneBackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.255 , 0.080)
        call DzFrameSetSize(F_Arcana3[12], 0.02125 , 0.02125)
        call DzFrameSetTexture(F_Arcana3[12], "UI_Arcana_Work4.blp", 0)
        
        set F_ArcanaTextA[0]=DzCreateFrameByTagName("TEXT", "", F_StoneBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_ArcanaTextA[0], JN_FRAMEPOINT_CENTER, F_StoneBackDrop ,  JN_FRAMEPOINT_BOTTOMLEFT, 0.180 + ( 0 * 0.025), 0.2175 )
        call DzFrameSetText(F_ArcanaTextA[0], "Lv 1")
        call DzFrameSetFont(F_ArcanaTextA[0], "Fonts\\DFHeiMd.ttf", 0.010, 0)
        set F_ArcanaTextA[1]=DzCreateFrameByTagName("TEXT", "", F_StoneBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_ArcanaTextA[1], JN_FRAMEPOINT_CENTER, F_StoneBackDrop ,  JN_FRAMEPOINT_BOTTOMLEFT, 0.205 + ( 0 * 0.025), 0.2175 )
        call DzFrameSetText(F_ArcanaTextA[1], "Lv 2")
        call DzFrameSetFont(F_ArcanaTextA[1], "Fonts\\DFHeiMd.ttf", 0.010, 0)
        set F_ArcanaTextA[2]=DzCreateFrameByTagName("TEXT", "", F_StoneBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_ArcanaTextA[2], JN_FRAMEPOINT_CENTER, F_StoneBackDrop ,  JN_FRAMEPOINT_BOTTOMLEFT, 0.255 + ( 0 * 0.025), 0.2175 )
        call DzFrameSetText(F_ArcanaTextA[2], "Lv 3")
        call DzFrameSetFont(F_ArcanaTextA[2], "Fonts\\DFHeiMd.ttf", 0.010, 0)
        set F_ArcanaTextA[3]=DzCreateFrameByTagName("TEXT", "", F_StoneBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_ArcanaTextA[3], JN_FRAMEPOINT_CENTER, F_StoneBackDrop ,  JN_FRAMEPOINT_BOTTOMLEFT, 0.280 + ( 0 * 0.025), 0.2175 )
        call DzFrameSetText(F_ArcanaTextA[3], "Lv 4")
        call DzFrameSetFont(F_ArcanaTextA[3], "Fonts\\DFHeiMd.ttf", 0.010, 0)

        set F_ArcanaTextB[0]=DzCreateFrameByTagName("TEXT", "", F_StoneBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_ArcanaTextB[0], JN_FRAMEPOINT_CENTER, F_StoneBackDrop ,  JN_FRAMEPOINT_BOTTOMLEFT, 0.180 + ( 0 * 0.025), 0.1575 )
        call DzFrameSetText(F_ArcanaTextB[0], "Lv 1")
        call DzFrameSetFont(F_ArcanaTextB[0], "Fonts\\DFHeiMd.ttf", 0.010, 0)
        set F_ArcanaTextB[1]=DzCreateFrameByTagName("TEXT", "", F_StoneBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_ArcanaTextB[1], JN_FRAMEPOINT_CENTER, F_StoneBackDrop ,  JN_FRAMEPOINT_BOTTOMLEFT, 0.205 + ( 0 * 0.025), 0.1575 )
        call DzFrameSetText(F_ArcanaTextB[1], "Lv 2")
        call DzFrameSetFont(F_ArcanaTextB[1], "Fonts\\DFHeiMd.ttf", 0.010, 0)
        set F_ArcanaTextB[2]=DzCreateFrameByTagName("TEXT", "", F_StoneBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_ArcanaTextB[2], JN_FRAMEPOINT_CENTER, F_StoneBackDrop ,  JN_FRAMEPOINT_BOTTOMLEFT, 0.255 + ( 0 * 0.025), 0.1575 )
        call DzFrameSetText(F_ArcanaTextB[2], "Lv 3")
        call DzFrameSetFont(F_ArcanaTextB[2], "Fonts\\DFHeiMd.ttf", 0.010, 0)
        set F_ArcanaTextB[3]=DzCreateFrameByTagName("TEXT", "", F_StoneBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_ArcanaTextB[3], JN_FRAMEPOINT_CENTER, F_StoneBackDrop ,  JN_FRAMEPOINT_BOTTOMLEFT, 0.280 + ( 0 * 0.025), 0.1575 )
        call DzFrameSetText(F_ArcanaTextB[3], "Lv 4")
        call DzFrameSetFont(F_ArcanaTextB[3], "Fonts\\DFHeiMd.ttf", 0.010, 0)

        set F_ArcanaTextC[0]=DzCreateFrameByTagName("TEXT", "", F_StoneBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_ArcanaTextC[0], JN_FRAMEPOINT_CENTER, F_StoneBackDrop ,  JN_FRAMEPOINT_BOTTOMLEFT, 0.155 + ( 0 * 0.025), 0.0400 )
        call DzFrameSetText(F_ArcanaTextC[0], "Lv 1")
        call DzFrameSetFont(F_ArcanaTextC[0], "Fonts\\DFHeiMd.ttf", 0.010, 0)
        call DzFrameSetTextAlignment(F_ArcanaTextC[0], JN_TEXT_JUSTIFY_MIDDLE)
        set F_ArcanaTextC[1]=DzCreateFrameByTagName("TEXT", "", F_StoneBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_ArcanaTextC[1], JN_FRAMEPOINT_CENTER, F_StoneBackDrop ,  JN_FRAMEPOINT_BOTTOMLEFT, 0.205 + ( 0 * 0.025), 0.0400 )
        call DzFrameSetText(F_ArcanaTextC[1], "Lv 2")
        call DzFrameSetFont(F_ArcanaTextC[1], "Fonts\\DFHeiMd.ttf", 0.010, 0)
        set F_ArcanaTextC[2]=DzCreateFrameByTagName("TEXT", "", F_StoneBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_ArcanaTextC[2], JN_FRAMEPOINT_CENTER, F_StoneBackDrop ,  JN_FRAMEPOINT_BOTTOMLEFT, 0.280 + ( 0 * 0.025), 0.0400 )
        call DzFrameSetText(F_ArcanaTextC[2], "Lv 3")
        call DzFrameSetFont(F_ArcanaTextC[2], "Fonts\\DFHeiMd.ttf", 0.010, 0)
        
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
            
            //if JNObjectCharacterServerConnectCheck( ) then
            if true then
                if f == F_ArcanaButton[1] then
                    if loopA != 10 then
                        if (75 - (ArcanaProbability * 10 )) >= i then
                            //성공
                            call DzFrameSetTexture(F_Arcana1[loopA], "UI_Arcana_Work2.blp", 0)
                            set Arcana1[loopA] = 1
                            set ArcanaProbability = ArcanaProbability + 1
                            if ArcanaProbability > 5 then
                                set ArcanaProbability = 5
                            endif
                            call DzFrameSetText(F_ArcanaText[0], "부여 확률 |cFFFFE400" + I2S(75 - (ArcanaProbability * 10 )) + "%|r")
                            call DzFrameSetText(F_ArcanaText[1], "균열 확률 |cFFFFE400" + I2S(75 - (ArcanaProbability * 10 )) + "%|r")
                            set ArcanaA = ArcanaA + 1
                            if ArcanaA == 6 then
                                call DzFrameSetText(F_ArcanaTextA[0], "|cff5AD2FF"+ "Lv 1|r")
                            endif
                            if ArcanaA == 7 then
                                call DzFrameSetText(F_ArcanaTextA[1], "|cff5AD2FF"+ "Lv 2|r")
                            endif
                            if ArcanaA == 9 then
                                call DzFrameSetText(F_ArcanaTextA[2], "|cff5AD2FF"+ "Lv 3|r")
                            endif
                            if ArcanaA == 10 then
                                call DzFrameSetText(F_ArcanaTextA[3], "|cff5AD2FF"+ "Lv 4|r")
                            endif
                            call DzFrameSetText(F_ArcanaText[6], "|cff5AD2FFX " + I2S(ArcanaA) + "|r")
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
                            call DzFrameSetTexture(F_Arcana1[loopA], "UI_Arcana_Work0.blp", 0)
                            set Arcana1[loopA] = 2
                            set ArcanaProbability = ArcanaProbability - 1
                            if ArcanaProbability < 0 then
                                set ArcanaProbability = 0
                            endif
                            call DzFrameSetText(F_ArcanaText[0], "부여 확률 |cFFFFE400" + I2S(75 - (ArcanaProbability * 10 )) + "%|r")
                            call DzFrameSetText(F_ArcanaText[1], "균열 확률 |cFFFFE400" + I2S(75 - (ArcanaProbability * 10 )) + "%|r")
                            set loopASC = loopASC + 1
                            if loopASC < 5 then
                                call DzFrameSetPoint(F_ArcanaTextA[0], JN_FRAMEPOINT_CENTER, F_StoneBackDrop ,  JN_FRAMEPOINT_BOTTOMLEFT, 0.180 + ( loopASC * 0.025), 0.2175 )
                            elseif loopASC == 5 then
                                call DzFrameShow(F_ArcanaTextA[0],false)
                            endif
                            if loopASC < 4 then
                                call DzFrameSetPoint(F_ArcanaTextA[1], JN_FRAMEPOINT_CENTER, F_StoneBackDrop ,  JN_FRAMEPOINT_BOTTOMLEFT, 0.205 + ( loopASC * 0.025), 0.2175 )
                            elseif loopASC == 4 then
                                call DzFrameShow(F_ArcanaTextA[1],false)
                            endif
                            if loopASC < 2 then
                                call DzFrameSetPoint(F_ArcanaTextA[2], JN_FRAMEPOINT_CENTER, F_StoneBackDrop ,  JN_FRAMEPOINT_BOTTOMLEFT, 0.255 + ( loopASC * 0.025), 0.2175 )
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
                elseif f == F_ArcanaButton[2] then
                    if loopB != 10 then
                        if (75 - (ArcanaProbability * 10 )) >= i then
                            //성공
                            call DzFrameSetTexture(F_Arcana2[loopB], "UI_Arcana_Work2.blp", 0)
                            set Arcana2[loopB] = 1
                            set ArcanaProbability = ArcanaProbability + 1
                            if ArcanaProbability > 5 then
                                set ArcanaProbability = 5
                            endif
                            call DzFrameSetText(F_ArcanaText[0], "부여 확률 |cFFFFE400" + I2S(75 - (ArcanaProbability * 10 )) + "%|r")
                            call DzFrameSetText(F_ArcanaText[1], "균열 확률 |cFFFFE400" + I2S(75 - (ArcanaProbability * 10 )) + "%|r")
                            set ArcanaB = ArcanaB + 1
                            if ArcanaB == 6 then
                                call DzFrameSetText(F_ArcanaTextB[0], "|cff5AD2FF"+ "Lv 1|r")
                            endif
                            if ArcanaB == 7 then
                                call DzFrameSetText(F_ArcanaTextB[1], "|cff5AD2FF"+ "Lv 2|r")
                            endif
                            if ArcanaB == 9 then
                                call DzFrameSetText(F_ArcanaTextB[2], "|cff5AD2FF"+ "Lv 3|r")
                            endif
                            if ArcanaB == 10 then
                                call DzFrameSetText(F_ArcanaTextB[3], "|cff5AD2FF"+ "Lv 4|r")
                            endif
                            call DzFrameSetText(F_ArcanaText[7], "|cff5AD2FFX " + I2S(ArcanaB) + "|r")
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
                            call DzFrameSetTexture(F_Arcana2[loopB], "UI_Arcana_Work0.blp", 0)
                            set Arcana2[loopB] = 2
                            set ArcanaProbability = ArcanaProbability - 1
                            if ArcanaProbability < 0 then
                                set ArcanaProbability = 0
                            endif
                            call DzFrameSetText(F_ArcanaText[0], "부여 확률 |cFFFFE400" + I2S(75 - (ArcanaProbability * 10 )) + "%|r")
                            call DzFrameSetText(F_ArcanaText[1], "균열 확률 |cFFFFE400" + I2S(75 - (ArcanaProbability * 10 )) + "%|r")
                            set loopBSC = loopBSC + 1
                            if loopBSC < 5 then
                                call DzFrameSetPoint(F_ArcanaTextB[0], JN_FRAMEPOINT_CENTER, F_StoneBackDrop ,  JN_FRAMEPOINT_BOTTOMLEFT, 0.180 + ( loopBSC * 0.025), 0.1575 )
                            elseif loopBSC == 5 then
                                call DzFrameShow(F_ArcanaTextB[0],false)
                            endif
                            if loopBSC < 4 then
                                call DzFrameSetPoint(F_ArcanaTextB[1], JN_FRAMEPOINT_CENTER, F_StoneBackDrop ,  JN_FRAMEPOINT_BOTTOMLEFT, 0.205 + ( loopBSC * 0.025), 0.1575 )
                            elseif loopBSC == 4 then
                                call DzFrameShow(F_ArcanaTextB[1],false)
                            endif
                            if loopBSC < 2 then
                                call DzFrameSetPoint(F_ArcanaTextB[2], JN_FRAMEPOINT_CENTER, F_StoneBackDrop ,  JN_FRAMEPOINT_BOTTOMLEFT, 0.255 + ( loopBSC * 0.025), 0.1575 )
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
                elseif f == F_ArcanaButton[3] then
                    if loopC != 10 then
                        if (75 - (ArcanaProbability * 10 )) >= i then
                            //성공
                            call DzFrameSetTexture(F_Arcana3[loopC], "UI_Arcana_Work4.blp", 0)
                            set Arcana3[loopC] = 1
                            set ArcanaProbability = ArcanaProbability + 1
                            if ArcanaProbability > 5 then
                                set ArcanaProbability = 5
                            endif
                            call DzFrameSetText(F_ArcanaText[0], "부여 확률 |cFFFFE400" + I2S(75 - (ArcanaProbability * 10 )) + "%|r")
                            call DzFrameSetText(F_ArcanaText[1], "균열 확률 |cFFFFE400" + I2S(75 - (ArcanaProbability * 10 )) + "%|r")
                            set ArcanaC = ArcanaC + 1
                            if ArcanaC == 5 then
                                call DzFrameSetText(F_ArcanaTextC[0], "|cffFF0000"+ "Lv 1|r")
                            endif
                            if ArcanaC == 7 then
                                call DzFrameSetText(F_ArcanaTextC[1], "|cffFF0000"+ "Lv 2|r")
                            endif
                            if ArcanaC == 10 then
                                call DzFrameSetText(F_ArcanaTextC[2], "|cffFF0000"+ "Lv 3|r")
                            endif
                            call DzFrameSetText(F_ArcanaText[8], "|cffFF0000X " + I2S(ArcanaC)+ "|r")
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
                            call DzFrameSetTexture(F_Arcana3[loopC], "UI_Arcana_Work0.blp", 0)
                            set Arcana3[loopC] = 2
                            set ArcanaProbability = ArcanaProbability - 1
                            if ArcanaProbability < 0 then
                                set ArcanaProbability = 0
                            endif
                            call DzFrameSetText(F_ArcanaText[0], "부여 확률 |cFFFFE400" + I2S(75 - (ArcanaProbability * 10 )) + "%|r")
                            call DzFrameSetText(F_ArcanaText[1], "균열 확률 |cFFFFE400" + I2S(75 - (ArcanaProbability * 10 )) + "%|r")
                            set loopCSC = loopCSC + 1
                            if loopCSC < 6 then
                                call DzFrameSetPoint(F_ArcanaTextC[0], JN_FRAMEPOINT_CENTER, F_StoneBackDrop ,  JN_FRAMEPOINT_BOTTOMLEFT, 0.155 + ( loopCSC * 0.025), 0.0400 )
                            elseif loopCSC == 6 then
                                call DzFrameShow(F_ArcanaTextC[0],false)
                            endif
                            if loopCSC < 4 then
                                call DzFrameSetPoint(F_ArcanaTextC[1], JN_FRAMEPOINT_CENTER, F_StoneBackDrop ,  JN_FRAMEPOINT_BOTTOMLEFT, 0.205 + ( loopCSC * 0.025), 0.0400 )
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
                    set i = 0
                    set A = 0
                    set B = 0
                    set C = 0
                    loop
                        if Arcana1[i] == 1 then
                            set A = A + 1
                        endif
                        if Arcana2[i] == 1 then
                            set B = B + 1
                        endif
                        if Arcana3[i] == 1 then
                            set C = C + 1
                        endif
                    exitwhen i == 9
                        set i = i + 1
                    endloop
                    
                    set i = 0
                    loop
                        exitwhen i == 50
                        //비어있는 공간이 있음
                        if GetItemIDs(StashLoad(PLAYER_DATA[pid], "슬롯"+sn+".아이템"+I2S(i), "0")) == 0 then
                            set items = "ID"+I2S(11)+";"
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
                            call AddIvItem(pid,i,items)
                            set items = ""
                            set i = 49
                            //저장
                            //call CharacterSave(true , SLNumber)
                        endif
                        set i = i + 1
                    endloop
                    //call DzFrameShow(F_StoneBackDrop, false)
                    //set F_StoneOnOff[pid] = false
                endif
            else
                call BJDebugMsg("서버에 연결되지 않았습니다.")
            endif
        endif
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