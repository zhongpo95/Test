library UISkillLevel initializer init requires DataUnit
    globals
        integer FS_OpenButton                       //스킬창 여는 버튼
        integer FS_OpenButtonBD                     //스킬창 여는 버튼 백드롭
        integer FS_BackDrop                         //스킬창 배경
        integer FS_CombinationText                  //스킬창 텍스트
        integer FS_SPTEXT                           //스킬포인트 텍스트
        integer FS_SPTEXTV                          //스킬포인트 텍스트벨류
        integer FS_TemplateBackDrop                 //스킬창 스킬공간
        integer FS_TemplateText                     //스킬창 스킬설명
        integer FS_CancelButton                     //스킬창 취소버튼
        integer array FS_Button                     //스킬버튼
        integer array FS_ButtonBackDrop             //스킬버튼 백드롭
        integer array FS_ButtonTEXT                 //스킬버튼 텍스트
        integer array FS_ButtonTEXT2                //스킬버튼 텍스트
        integer array FS_UP                         //업버튼
        integer array FS_UPBD                       //업버튼 백드롭
        integer array FS_DOWN                       //다운버튼
        integer array FS_DOWNBD                     //다운버튼 백드롭
        integer array FP_SLBD1                       //스킬레벨 백드롭
        integer array FP_SLTEXT1                       //스킬레벨 텍스트
        integer array FP_SLBD2                       //스킬레벨 백드롭
        integer array FP_SLTEXT2                       //스킬레벨 텍스트
        integer array FP_SLBD3                       //스킬레벨 백드롭
        integer array FP_SLTEXT3                       //스킬레벨 텍스트
        
        boolean array FS_OnOff                      //플레이어 온오프
        
        //전역변수
        integer array HeroSkillLevel[13][8]
        integer array HeroSkillPoint[13]
    endglobals
    
    function SkillSetting takes unit u returns nothing
        local integer index = DataUnitIndex(u)
        local player p = GetOwningPlayer(u)
        
        if p == GetLocalPlayer() then
            
            call DzFrameSetText(FS_ButtonTEXT[0], EXGetAbilityString(HeroSkillID0[index],1,ABILITY_DATA_TIP) )
            call DzFrameSetText(FS_ButtonTEXT[1], EXGetAbilityString(HeroSkillID1[index],1,ABILITY_DATA_TIP) )
            call DzFrameSetText(FS_ButtonTEXT[2], EXGetAbilityString(HeroSkillID2[index],1,ABILITY_DATA_TIP) )
            call DzFrameSetText(FS_ButtonTEXT[3], EXGetAbilityString(HeroSkillID3[index],1,ABILITY_DATA_TIP) )
            call DzFrameSetText(FS_ButtonTEXT[4], EXGetAbilityString(HeroSkillID4[index],1,ABILITY_DATA_TIP) )
            call DzFrameSetText(FS_ButtonTEXT[5], EXGetAbilityString(HeroSkillID5[index],1,ABILITY_DATA_TIP) )
            call DzFrameSetText(FS_ButtonTEXT[6], EXGetAbilityString(HeroSkillID6[index],1,ABILITY_DATA_TIP) )
            call DzFrameSetText(FS_ButtonTEXT[7], EXGetAbilityString(HeroSkillID7[index],1,ABILITY_DATA_TIP) )
            
            call DzFrameSetTexture(FS_ButtonBackDrop[0], EXExecuteScript("(require'jass.slk').ability[" +I2S(HeroSkillID0[index])+"].Art"), 0)
            call DzFrameSetTexture(FS_ButtonBackDrop[1], EXExecuteScript("(require'jass.slk').ability[" +I2S(HeroSkillID1[index])+"].Art"), 0)
            call DzFrameSetTexture(FS_ButtonBackDrop[2], EXExecuteScript("(require'jass.slk').ability[" +I2S(HeroSkillID2[index])+"].Art"), 0)
            call DzFrameSetTexture(FS_ButtonBackDrop[3], EXExecuteScript("(require'jass.slk').ability[" +I2S(HeroSkillID3[index])+"].Art"), 0)
            call DzFrameSetTexture(FS_ButtonBackDrop[4], EXExecuteScript("(require'jass.slk').ability[" +I2S(HeroSkillID4[index])+"].Art"), 0)
            call DzFrameSetTexture(FS_ButtonBackDrop[5], EXExecuteScript("(require'jass.slk').ability[" +I2S(HeroSkillID5[index])+"].Art"), 0)
            call DzFrameSetTexture(FS_ButtonBackDrop[6], EXExecuteScript("(require'jass.slk').ability[" +I2S(HeroSkillID6[index])+"].Art"), 0)
            call DzFrameSetTexture(FS_ButtonBackDrop[7], EXExecuteScript("(require'jass.slk').ability[" +I2S(HeroSkillID7[index])+"].Art"), 0)
            
            call DzFrameSetText(FP_SLTEXT1[0], HeroSkill0Text1[index] )
            call DzFrameSetText(FP_SLTEXT2[0], HeroSkill0Text2[index] )
            call DzFrameSetText(FP_SLTEXT3[0], HeroSkill0Text3[index] )
            call DzFrameSetText(FP_SLTEXT1[1], HeroSkill1Text1[index] )
            call DzFrameSetText(FP_SLTEXT2[1], HeroSkill1Text2[index] )
            call DzFrameSetText(FP_SLTEXT3[1], HeroSkill1Text3[index] )
            call DzFrameSetText(FP_SLTEXT1[2], HeroSkill2Text1[index] )
            call DzFrameSetText(FP_SLTEXT2[2], HeroSkill2Text2[index] )
            call DzFrameSetText(FP_SLTEXT3[2], HeroSkill2Text3[index] )
            call DzFrameSetText(FP_SLTEXT1[3], HeroSkill3Text1[index] )
            call DzFrameSetText(FP_SLTEXT2[3], HeroSkill3Text2[index] )
            call DzFrameSetText(FP_SLTEXT3[3], HeroSkill3Text3[index] )
            call DzFrameSetText(FP_SLTEXT1[4], HeroSkill4Text1[index] )
            call DzFrameSetText(FP_SLTEXT2[4], HeroSkill4Text2[index] )
            call DzFrameSetText(FP_SLTEXT3[4], HeroSkill4Text3[index] )
            call DzFrameSetText(FP_SLTEXT1[5], HeroSkill5Text1[index] )
            call DzFrameSetText(FP_SLTEXT2[5], HeroSkill5Text2[index] )
            call DzFrameSetText(FP_SLTEXT3[5], HeroSkill5Text3[index] )
            call DzFrameSetText(FP_SLTEXT1[6], HeroSkill6Text1[index] )
            call DzFrameSetText(FP_SLTEXT2[6], HeroSkill6Text2[index] )
            call DzFrameSetText(FP_SLTEXT3[6], HeroSkill6Text3[index] )
            call DzFrameSetText(FP_SLTEXT1[7], HeroSkill7Text1[index] )
            call DzFrameSetText(FP_SLTEXT2[7], HeroSkill7Text2[index] )
            call DzFrameSetText(FP_SLTEXT3[7], HeroSkill7Text3[index] )

            if index == 0 then
            endif
        endif
        
        set p = null
    endfunction
    
    private function ShowMenu takes nothing returns nothing
        //메뉴 버튼을 누르면 메뉴 버튼 비활설화 + 메뉴 배경 표시
        //다시 메뉴 버튼을 누르면 메뉴버튼 활성화 + 메뉴 배경 숨김
        if FS_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] == true then
            call DzFrameShow(FS_BackDrop, false)
            set FS_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = false
        else
            call DzFrameShow(FS_BackDrop, true)
            set FS_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = true
        endif
    endfunction
    
    private function SelectSkill takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer i = 0
        
        set i = 0
        loop
            call DzFrameShow(FP_SLBD1[i], false)
            call DzFrameShow(FP_SLBD2[i], false)
            call DzFrameShow(FP_SLBD3[i], false)
            exitwhen i == 7
            set i = i + 1
        endloop
        
        if f == FS_Button[0] then
            call DzFrameShow(FP_SLBD1[0], true)
            call DzFrameShow(FP_SLBD2[0], true)
            call DzFrameShow(FP_SLBD3[0], true)
        elseif f == FS_Button[1] then
            call DzFrameShow(FP_SLBD1[1], true)
            call DzFrameShow(FP_SLBD2[1], true)
            call DzFrameShow(FP_SLBD3[1], true)
        elseif f == FS_Button[2] then
            call DzFrameShow(FP_SLBD1[2], true)
            call DzFrameShow(FP_SLBD2[2], true)
            call DzFrameShow(FP_SLBD3[2], true)
        elseif f == FS_Button[3] then
            call DzFrameShow(FP_SLBD1[3], true)
            call DzFrameShow(FP_SLBD2[3], true)
            call DzFrameShow(FP_SLBD3[3], true)
        elseif f == FS_Button[4] then
            call DzFrameShow(FP_SLBD1[4], true)
            call DzFrameShow(FP_SLBD2[4], true)
            call DzFrameShow(FP_SLBD3[4], true)
        elseif f == FS_Button[5] then
            call DzFrameShow(FP_SLBD1[5], true)
            call DzFrameShow(FP_SLBD2[5], true)
            call DzFrameShow(FP_SLBD3[5], true)
        elseif f == FS_Button[6] then
            call DzFrameShow(FP_SLBD1[6], true)
            call DzFrameShow(FP_SLBD2[6], true)
            call DzFrameShow(FP_SLBD3[6], true)
        elseif f == FS_Button[7] then
            call DzFrameShow(FP_SLBD1[7], true)
            call DzFrameShow(FP_SLBD2[7], true)
            call DzFrameShow(FP_SLBD3[7], true)
        endif
        
    endfunction
    
    private function PushUP takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        if FS_UP[0] == f then
            call DzSyncData(("BTUP"),"0")
        elseif FS_UP[1] == f then
            call DzSyncData(("BTUP"),"1")
        elseif FS_UP[2] == f then
            call DzSyncData(("BTUP"),"2")
        elseif FS_UP[3] == f then
            call DzSyncData(("BTUP"),"3")
        elseif FS_UP[4] == f then
            call DzSyncData(("BTUP"),"4")
        elseif FS_UP[5] == f then
            call DzSyncData(("BTUP"),"5")
        elseif FS_UP[6] == f then
            call DzSyncData(("BTUP"),"6")
        elseif FS_UP[7] == f then
            call DzSyncData(("BTUP"),"7")
        endif
    endfunction
    
    private function PushDOWN takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        if FS_DOWN[0] == f then
            call DzSyncData(("BTDOWN"),"0")
        elseif FS_DOWN[1] == f then
            call DzSyncData(("BTDOWN"),"1")
        elseif FS_DOWN[2] == f then
            call DzSyncData(("BTDOWN"),"2")
        elseif FS_DOWN[3] == f then
            call DzSyncData(("BTDOWN"),"3")
        elseif FS_DOWN[4] == f then
            call DzSyncData(("BTDOWN"),"4")
        elseif FS_DOWN[5] == f then
            call DzSyncData(("BTDOWN"),"5")
        elseif FS_DOWN[6] == f then
            call DzSyncData(("BTDOWN"),"6")
        elseif FS_DOWN[7] == f then
            call DzSyncData(("BTDOWN"),"7")
        endif
    endfunction
    
    //
    private function CreateSkillButton takes integer types returns nothing
        set FS_Button[types]=DzCreateFrameByTagName("BUTTON", "", FS_BackDrop, "ScoreScreenTabButtonTemplate", 0)
        call DzFrameSetPoint(FS_Button[types], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.040, -0.080 +(-0.038*types))
        call DzFrameSetSize(FS_Button[types], 0.030, 0.030)
        call DzFrameSetScriptByCode(FS_Button[types], JN_FRAMEEVENT_MOUSE_UP, function SelectSkill, false)
        
        set FS_ButtonBackDrop[types]=DzCreateFrameByTagName("BACKDROP", "", FS_Button[types], "", 0)
        call DzFrameSetAllPoints(FS_ButtonBackDrop[types], FS_Button[types])
        call DzFrameSetTexture(FS_ButtonBackDrop[types],"ReplaceableTextures\\CommandButtons\\BTNDeathPact.blp", 0)
        
        set FS_ButtonTEXT[types]=DzCreateFrameByTagName("TEXT", "", FS_Button[types], "", 0)
        call DzFrameSetPoint(FS_ButtonTEXT[types], JN_FRAMEPOINT_TOPLEFT, FS_Button[types] , JN_FRAMEPOINT_TOPLEFT, 0.035, -0.010)
        call DzFrameSetText(FS_ButtonTEXT[types], "스킬이름스킬이름스킬이")
        
        set FS_DOWN[types] = DzCreateFrameByTagName("BUTTON", "", FS_Button[types], "ScoreScreenTabButtonTemplate", 0)
        call DzFrameSetPoint(FS_DOWN[types], JN_FRAMEPOINT_CENTER, FS_Button[types] , JN_FRAMEPOINT_CENTER, 0.170, 0)
        call DzFrameSetSize(FS_DOWN[types], 0.020, 0.020)
        call DzFrameSetScriptByCode(FS_DOWN[types], JN_FRAMEEVENT_MOUSE_UP, function PushDOWN, false)
        set FS_DOWNBD[types]=DzCreateFrameByTagName("BACKDROP", "", FS_DOWN[types], "template", 0)
        call DzFrameSetTexture(FS_DOWNBD[types], "UI_M.blp", 0)
        call DzFrameSetSize(FS_DOWNBD[types], 0.020, 0.020)
        call DzFrameSetPoint(FS_DOWNBD[types], JN_FRAMEPOINT_CENTER, FS_Button[types] , JN_FRAMEPOINT_CENTER, 0.170, 0)
        
        set FS_ButtonTEXT2[types]=DzCreateFrameByTagName("TEXT", "", FS_Button[types], "", 0)
        call DzFrameSetPoint(FS_ButtonTEXT2[types], JN_FRAMEPOINT_TOPLEFT, FS_Button[types] , JN_FRAMEPOINT_TOPLEFT, 0.200, -0.010)
        call DzFrameSetText(FS_ButtonTEXT2[types], "0")
        
        set FS_UP[types] = DzCreateFrameByTagName("BUTTON", "", FS_Button[types], "ScoreScreenTabButtonTemplate", 0)
        call DzFrameSetPoint(FS_UP[types], JN_FRAMEPOINT_CENTER, FS_Button[types] , JN_FRAMEPOINT_CENTER, 0.210, 0)
        call DzFrameSetSize(FS_UP[types], 0.020, 0.020)
        call DzFrameSetScriptByCode(FS_UP[types], JN_FRAMEEVENT_MOUSE_UP, function PushUP, false)
        set FS_UPBD[types]=DzCreateFrameByTagName("BACKDROP", "", FS_UP[types], "template", 0)
        call DzFrameSetTexture(FS_UPBD[types], "UI_P.blp", 0)
        call DzFrameSetSize(FS_UPBD[types], 0.020, 0.020)
        call DzFrameSetPoint(FS_UPBD[types], JN_FRAMEPOINT_CENTER, FS_Button[types] , JN_FRAMEPOINT_CENTER, 0.210, 0)
        
        set FP_SLBD1[types]=DzCreateFrameByTagName("BACKDROP", "", FS_Button[types], "template", 0)
        call DzFrameSetTexture(FP_SLBD1[types], "UI_PickSelectButton2.tga", 0)
        call DzFrameSetSize(FP_SLBD1[types], 0.18, 0.08)
        call DzFrameSetAbsolutePoint(FP_SLBD1[types], JN_FRAMEPOINT_CENTER, 0.525, 0.38)
        set FP_SLTEXT1[types]=DzCreateFrameByTagName("TEXT", "", FP_SLBD1[types], "", 0)
        call DzFrameSetPoint(FP_SLTEXT1[types], JN_FRAMEPOINT_CENTER, FP_SLBD1[types] , JN_FRAMEPOINT_CENTER, 0.004,0)
        call DzFrameSetText(FP_SLTEXT1[types], "0")
        call DzFrameSetSize(FP_SLTEXT1[types], 0.165, 0.00)
        call DzFrameSetFont(FP_SLTEXT1[types], "Fonts\\DFHeiMd.ttf", 0.010, 0)
        call DzFrameShow(FP_SLBD1[types], false)
        
        set FP_SLBD2[types]=DzCreateFrameByTagName("BACKDROP", "", FS_Button[types], "template", 0)
        call DzFrameSetTexture(FP_SLBD2[types], "UI_PickSelectButton2.tga", 0)
        call DzFrameSetSize(FP_SLBD2[types], 0.18, 0.08)
        call DzFrameSetAbsolutePoint(FP_SLBD2[types], JN_FRAMEPOINT_CENTER, 0.525, 0.28)
        set FP_SLTEXT2[types]=DzCreateFrameByTagName("TEXT", "", FP_SLBD2[types], "", 0)
        call DzFrameSetPoint(FP_SLTEXT2[types], JN_FRAMEPOINT_CENTER, FP_SLBD2[types] , JN_FRAMEPOINT_CENTER, 0.004,0)
        call DzFrameSetText(FP_SLTEXT2[types], "0")
        call DzFrameSetSize(FP_SLTEXT2[types], 0.165, 0.00)
        call DzFrameSetFont(FP_SLTEXT2[types], "Fonts\\DFHeiMd.ttf", 0.010, 0)
        call DzFrameShow(FP_SLBD2[types], false)
        
        set FP_SLBD3[types]=DzCreateFrameByTagName("BACKDROP", "", FS_Button[types], "template", 0)
        call DzFrameSetTexture(FP_SLBD3[types], "UI_PickSelectButton2.tga", 0)
        call DzFrameSetSize(FP_SLBD3[types], 0.18, 0.08)
        call DzFrameSetAbsolutePoint(FP_SLBD3[types], JN_FRAMEPOINT_CENTER, 0.525, 0.18)
        set FP_SLTEXT3[types]=DzCreateFrameByTagName("TEXT", "", FP_SLBD3[types], "", 0)
        call DzFrameSetPoint(FP_SLTEXT3[types], JN_FRAMEPOINT_CENTER, FP_SLBD3[types] , JN_FRAMEPOINT_CENTER, 0.004,0)
        call DzFrameSetText(FP_SLTEXT3[types], "0")
        call DzFrameSetSize(FP_SLTEXT3[types], 0.165, 0.00)
        call DzFrameSetFont(FP_SLTEXT3[types], "Fonts\\DFHeiMd.ttf", 0.010, 0)
        call DzFrameShow(FP_SLBD3[types], false)
    endfunction
    
    private function Main takes nothing returns nothing
        local string s
        local integer i
        
        /********************************** 스킬 버튼 생성 **********************************************/
        set FS_OpenButton = DzCreateFrameByTagName("GLUETEXTBUTTON", "", DzGetGameUI(), "template", 0)
        call DzFrameSetAbsolutePoint(FS_OpenButton, JN_FRAMEPOINT_CENTER, 0.700, 0.020)
        call DzFrameSetSize(FS_OpenButton, 0.020, 0.020)
        call DzFrameSetScriptByCode(FS_OpenButton, JN_FRAMEEVENT_MOUSE_UP, function ShowMenu, false)
        set FS_OpenButtonBD=DzCreateFrameByTagName("BACKDROP", "", FS_OpenButton, "template", 0)
        call DzFrameSetTexture(FS_OpenButtonBD, "skill.blp", 0)
        call DzFrameSetSize(FS_OpenButtonBD, 0.020, 0.020)
        call DzFrameSetAbsolutePoint(FS_OpenButtonBD, JN_FRAMEPOINT_CENTER, 0.700, 0.020)
        call DzFrameShow(FS_OpenButton, false)
        
        /********************************** 메뉴 배경 생성 **********************************************/
        set FS_BackDrop=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "StandardEditBoxBackdropTemplate", 0)
        call DzFrameSetAbsolutePoint(FS_BackDrop, JN_FRAMEPOINT_CENTER, 0.40, 0.30)
        call DzFrameSetSize(FS_BackDrop, 0.50, 0.39)
        
        /********************************** 프레임 이름 설명 생성 **********************************************/
        set FS_CombinationText=DzCreateFrameByTagName("TEXT", "", FS_BackDrop, "", 0)
        call DzFrameSetPoint(FS_CombinationText, JN_FRAMEPOINT_TOPLEFT, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.025, -0.025)
        call DzFrameSetText(FS_CombinationText, "스킬")
        
        set FS_SPTEXT=DzCreateFrameByTagName("TEXT", "", FS_BackDrop, "", 0)
        call DzFrameSetPoint(FS_SPTEXT, JN_FRAMEPOINT_TOPLEFT, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.170, -0.050)
        call DzFrameSetText(FS_SPTEXT, "스킬포인트")
        
        set FS_SPTEXTV=DzCreateFrameByTagName("TEXT", "", FS_BackDrop, "", 0)
        call DzFrameSetPoint(FS_SPTEXTV, JN_FRAMEPOINT_TOPLEFT, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.245, -0.050)
        call DzFrameSetText(FS_SPTEXTV, "0")
        
        call CreateSkillButton(0)
        call CreateSkillButton(1)
        call CreateSkillButton(2)
        call CreateSkillButton(3)
        call CreateSkillButton(4)
        call CreateSkillButton(5)
        call CreateSkillButton(6)
        call CreateSkillButton(7)
        
        /********************************** 메뉴 취소 버튼 **********************************************/
        set FS_CancelButton = DzCreateFrameByTagName("GLUETEXTBUTTON", "", FS_BackDrop, "ScriptDialogButton", 0)
        call DzFrameSetPoint(FS_CancelButton, JN_FRAMEPOINT_TOPRIGHT, FS_BackDrop , JN_FRAMEPOINT_TOPRIGHT, -0.015, -0.015)
        call DzFrameSetText(FS_CancelButton, "X")
        call DzFrameSetSize(FS_CancelButton, 0.03, 0.03)
        call DzFrameSetScriptByCode(FS_CancelButton, JN_FRAMEEVENT_MOUSE_UP, function ShowMenu, false)
        
        
        call DzFrameShow(FS_BackDrop, false)
    endfunction
    
    private function ESCAction takes nothing returns nothing
        if FS_OnOff[GetPlayerId(GetTriggerPlayer())] == true then
            if ( GetTriggerPlayer() == GetLocalPlayer() ) then
                call DzFrameShow(FS_BackDrop, false)
            endif
            set FS_OnOff[GetPlayerId(GetTriggerPlayer())] = false
        endif
    endfunction
    
    
    private function KKey takes nothing returns nothing
        local integer key = DzGetTriggerKey()
        local integer i = 0
        local integer j = GetPlayerId(DzGetTriggerKeyPlayer())
        
        if DzGetTriggerKeyPlayer()==GetLocalPlayer() then
            set i = JNMemoryGetByte(JNGetModuleHandle("Game.dll")+0xD04FEC)
        endif
        
        if i==1 then
        else
            if PickCheck[j] == true then
                if key == 'K' then
                    if FS_OnOff[j] == true then
                        call DzFrameShow(FS_BackDrop, false)
                        set FS_OnOff[j] = false
                    else
                        call DzFrameShow(FS_BackDrop, true)
                        set FS_OnOff[j] = true
                    endif
                endif
            endif
        endif
    endfunction
    
    private function BTUPF takes nothing returns nothing
        local player p=(DzGetTriggerSyncPlayer())
        local integer f = S2I(DzGetTriggerSyncData())
        local integer pid = GetPlayerId(p)
        local integer i = 0

        
        if HeroSkillLevel[pid][f] != 3 then
            if HeroSkillPoint[pid] >= 1 then
                set HeroSkillPoint[pid] = HeroSkillPoint[pid] - 1
                set HeroSkillLevel[pid][f] = HeroSkillLevel[pid][f] + 1
                
                if p == GetLocalPlayer() then
                    if HeroSkillLevel[pid][f] == 1 then
                        call DzFrameSetTexture(FP_SLBD1[f], "UI_PickSelectButton.tga", 0)
                    elseif HeroSkillLevel[pid][f] == 2 then
                        call DzFrameSetTexture(FP_SLBD2[f], "UI_PickSelectButton.tga", 0)
                    elseif HeroSkillLevel[pid][f] == 3 then
                        call DzFrameSetTexture(FP_SLBD3[f], "UI_PickSelectButton.tga", 0)
                    endif
                    call DzFrameSetText(FS_SPTEXTV, I2S(HeroSkillPoint[pid]))
                    call DzFrameSetText(FS_ButtonTEXT2[f], I2S(HeroSkillLevel[pid][f]))
                    
                    set i = 0
                    loop
                        call DzFrameShow(FP_SLBD1[i], false)
                        call DzFrameShow(FP_SLBD2[i], false)
                        call DzFrameShow(FP_SLBD3[i], false)
                        exitwhen i == 7
                        set i = i + 1
                    endloop
                    set i = 0
                    
                    call DzFrameShow(FP_SLBD1[f], true)
                    call DzFrameShow(FP_SLBD2[f], true)
                    call DzFrameShow(FP_SLBD3[f], true)
                    
                endif
            endif
        endif
            
        set p = null
    endfunction
    
    private function BTDOWNF takes nothing returns nothing
        local player p=(DzGetTriggerSyncPlayer())
        local integer f = S2I(DzGetTriggerSyncData())
        local integer pid = GetPlayerId(p)
        local integer i = 0
        
        if HeroSkillLevel[pid][f] >= 1 then
            set HeroSkillPoint[pid] = HeroSkillPoint[pid] + 1
            set HeroSkillLevel[pid][f] = HeroSkillLevel[pid][f] - 1
            
            if p == GetLocalPlayer() then
                if HeroSkillLevel[pid][f] == 0 then
                    call DzFrameSetTexture(FP_SLBD1[f], "UI_PickSelectButton2.tga", 0)
                elseif HeroSkillLevel[pid][f] == 1 then
                    call DzFrameSetTexture(FP_SLBD2[f], "UI_PickSelectButton2.tga", 0)
                elseif HeroSkillLevel[pid][f] == 2 then
                    call DzFrameSetTexture(FP_SLBD3[f], "UI_PickSelectButton2.tga", 0)
                endif
                call DzFrameSetText(FS_SPTEXTV, I2S(HeroSkillPoint[pid]))
                call DzFrameSetText(FS_ButtonTEXT2[f], I2S(HeroSkillLevel[pid][f]))
                
                set i = 0
                loop
                    call DzFrameShow(FP_SLBD1[i], false)
                    call DzFrameShow(FP_SLBD2[i], false)
                    call DzFrameShow(FP_SLBD3[i], false)
                    exitwhen i == 7
                    set i = i + 1
                endloop
                set i = 0
                
                call DzFrameShow(FP_SLBD1[f], true)
                call DzFrameShow(FP_SLBD2[f], true)
                call DzFrameShow(FP_SLBD3[f], true)
                
            endif
        endif
        
        set p = null
    endfunction
    
    
    private function init takes nothing returns nothing
        local trigger t=CreateTrigger()
        local integer index
        
        set t = CreateTrigger()
        call TriggerAddAction( t, function Main )
        call TriggerRegisterTimerEventSingle( t, 0.1 )
        
        
        //esc버튼으로 인벤토리 닫기
        set t = CreateTrigger()
        
        set index = 0
        loop
            call TriggerRegisterPlayerEvent(t, Player(index), EVENT_PLAYER_END_CINEMATIC)
            set index = index + 1
            exitwhen index == bj_MAX_PLAYER_SLOTS
        endloop
        call TriggerAddAction( t, function ESCAction )
        
        set index = 0
        loop
            set HeroSkillLevel[index][0] = 0
            set HeroSkillLevel[index][1] = 0
            set HeroSkillLevel[index][2] = 0
            set HeroSkillLevel[index][3] = 0
            set HeroSkillLevel[index][4] = 0
            set HeroSkillLevel[index][5] = 0
            set HeroSkillLevel[index][6] = 0
            set HeroSkillLevel[index][7] = 0
            set HeroSkillPoint[index] = 0
            set index = index + 1
            exitwhen index == 13
        endloop
        
        //I버튼으로 인벤토리 열기 및 닫기
        set t = CreateTrigger()
        
        call DzTriggerRegisterKeyEventByCode(t, 'K', 0, false, function KKey)
        
        set t=CreateTrigger()
        call DzTriggerRegisterSyncData(t,("BTUP"),(false))
        call TriggerAddAction(t,function BTUPF)
        set t=CreateTrigger()
        call DzTriggerRegisterSyncData(t,("BTDOWN"),(false))
        call TriggerAddAction(t,function BTDOWNF)
        
        set t = null
        
    endfunction
endlibrary