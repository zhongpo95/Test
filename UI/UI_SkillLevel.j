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
        integer array FS_Button[16][4]              //길버튼
        integer array FS_ButtonBackDrop[16][4]      //길버튼 백드롭
        integer array FS_LineBackDrop        //라인 백드롭
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
        
        integer FS_LB                     //X버튼
        integer FS_L                      //X버튼
        integer FS_L2                     //X버튼
        integer FS_RB
        integer FS_R
        integer FS_R2
        
        boolean array FS_OnOff                      //플레이어 온오프

        private integer NowList = 0        //현재리스트
        private constant integer MaxList = 2
        //전역변수
        integer array HeroSkillLevel[13][8]
        integer array HeroSkillPoint[13]
    endglobals
    
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
    
    //

    private function ClickRLButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        
        call DzFrameShow(FS_L, true)
        call DzFrameShow(FS_R, true)
        
        if f == FS_RB then
            if NowList == MaxList then
                set NowList = MaxList
            else
                set NowList = NowList + 1
            endif
            
            if NowList == 0 then
                call DzFrameShow(FS_L, false)
                call DzFrameShow(FS_R, true)
                call DzFrameShow(FS_L2, true)
                call DzFrameShow(FS_R2, false)
            elseif MaxList == NowList then
                call DzFrameShow(FS_L, true)
                call DzFrameShow(FS_R, false)
                call DzFrameShow(FS_L2, false)
                call DzFrameShow(FS_R2, true)
            else
                call DzFrameShow(FS_L, true)
                call DzFrameShow(FS_R, true)
                call DzFrameShow(FS_L2, false)
                call DzFrameShow(FS_R2, false)
            endif
        elseif f == FS_LB then
            if NowList == 0 then
                set NowList = 0
            else
                set NowList = NowList - 1
            endif
            
            if NowList == 0 then
                call DzFrameShow(FS_L, false)
                call DzFrameShow(FS_R, true)
                call DzFrameShow(FS_L2, true)
                call DzFrameShow(FS_R2, false)
            elseif MaxList == NowList then
                call DzFrameShow(FS_L, true)
                call DzFrameShow(FS_R, false)
                call DzFrameShow(FS_L2, false)
                call DzFrameShow(FS_R2, true)
            else
                call DzFrameShow(FS_L, true)
                call DzFrameShow(FS_R, true)
                call DzFrameShow(FS_L2, false)
                call DzFrameShow(FS_R2, false)
            endif
        endif
        
        if NowList == 0 then
            call DzFrameSetPoint(FS_Button[0][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*5), -0.080 - 0.120)

            call DzFrameSetPoint(FS_Button[1][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FS_Button[1][1], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FS_Button[1][2], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FS_Button[1][3], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FS_Button[2][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FS_Button[2][1], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FS_Button[2][2], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FS_Button[2][3], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FS_Button[3][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FS_Button[3][1], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FS_Button[3][2], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FS_Button[3][3], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FS_Button[4][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*1), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FS_Button[4][1], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*1), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FS_Button[4][2], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*1), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FS_Button[4][3], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*1), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FS_Button[5][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350, -0.080 - 0.120)

            call DzFrameSetPoint(FS_Button[6][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FS_Button[6][1], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FS_Button[6][2], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FS_Button[6][3], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FS_Button[7][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FS_Button[7][1], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FS_Button[7][2], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FS_Button[7][3], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FS_Button[8][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FS_Button[8][1], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FS_Button[8][2], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FS_Button[8][3], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FS_Button[9][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*4), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FS_Button[9][1], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*4), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FS_Button[9][2], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*4), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FS_Button[9][3], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*4), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FS_Button[10][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*5), -0.080 - 0.120)

            call DzFrameShow(FS_Button[0][0], true)
            call DzFrameShow(FS_Button[5][0], true)
            call DzFrameShow(FS_Button[10][0], false)
            call DzFrameShow(FS_Button[15][0], false)
        elseif NowList == 1 then
            call DzFrameSetPoint(FS_Button[5][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*5), -0.080 - 0.120)

            call DzFrameSetPoint(FS_Button[6][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FS_Button[6][1], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FS_Button[6][2], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FS_Button[6][3], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FS_Button[7][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FS_Button[7][1], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FS_Button[7][2], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FS_Button[7][3], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FS_Button[8][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FS_Button[8][1], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FS_Button[8][2], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FS_Button[8][3], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FS_Button[9][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*1), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FS_Button[9][1], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*1), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FS_Button[9][2], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*1), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FS_Button[9][3], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*1), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FS_Button[10][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350, -0.080 - 0.120)

            call DzFrameSetPoint(FS_Button[11][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FS_Button[11][1], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FS_Button[11][2], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FS_Button[11][3], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FS_Button[12][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FS_Button[12][1], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FS_Button[12][2], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FS_Button[12][3], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FS_Button[13][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FS_Button[13][1], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FS_Button[13][2], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FS_Button[13][3], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FS_Button[14][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*4), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FS_Button[14][1], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*4), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FS_Button[14][2], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*4), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FS_Button[14][3], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*4), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FS_Button[15][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*5), -0.080 - 0.120)
            
            call DzFrameShow(FS_Button[0][0], false)
            call DzFrameShow(FS_Button[5][0], true)
            call DzFrameShow(FS_Button[10][0], true)
            call DzFrameShow(FS_Button[15][0], false)
        elseif NowList == 2 then
            call DzFrameSetPoint(FS_Button[10][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*5), -0.080 - 0.120)

            call DzFrameSetPoint(FS_Button[11][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FS_Button[11][1], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FS_Button[11][2], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FS_Button[11][3], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FS_Button[12][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FS_Button[12][1], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FS_Button[12][2], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FS_Button[12][3], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FS_Button[13][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FS_Button[13][1], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FS_Button[13][2], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FS_Button[13][3], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FS_Button[14][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*1), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FS_Button[14][1], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*1), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FS_Button[14][2], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*1), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FS_Button[14][3], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*1), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FS_Button[15][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350, -0.080 - 0.120)

            call DzFrameSetPoint(FS_Button[16][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2.5), -0.080 - 0.120)

            call DzFrameShow(FS_Button[0][0], false)
            call DzFrameShow(FS_Button[5][0], false)
            call DzFrameShow(FS_Button[10][0], true)
            call DzFrameShow(FS_Button[15][0], true)
        endif
        
    endfunction
    

    private function CreateSkillButton takes integer types, integer x returns nothing
        local integer i

        if types == 0 then
            set FS_Button[types][0]=DzCreateFrameByTagName("BUTTON", "", FS_BackDrop, "ScoreScreenTabButtonTemplate", 0)
            call DzFrameSetPoint(FS_Button[types][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.060 + (0.060*types), -0.080 - 0.120)
            call DzFrameSetSize(FS_Button[types][0], 0.030, 0.030)
            //call DzFrameSetScriptByCode(FS_Button[types][0], JN_FRAMEEVENT_MOUSE_UP, function SelectSkill, false)
            
            set FS_ButtonBackDrop[types][0]=DzCreateFrameByTagName("BACKDROP", "", FS_Button[types][0], "", 0)
            call DzFrameSetAllPoints(FS_ButtonBackDrop[types][0], FS_Button[types][0])
            call DzFrameSetTexture(FS_ButtonBackDrop[types][0],"ReplaceableTextures\\CommandButtons\\BTNGarithos.blp", 0)

        elseif types == 5 or types == 10 or types == 15 then
            set FS_Button[types][0]=DzCreateFrameByTagName("BUTTON", "", FS_BackDrop, "ScoreScreenTabButtonTemplate", 0)
            call DzFrameSetPoint(FS_Button[types][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.060 + (0.060*types), -0.080 - 0.120)
            call DzFrameSetSize(FS_Button[types][0], 0.030, 0.030)
            //call DzFrameSetScriptByCode(FS_Button[types][0], JN_FRAMEEVENT_MOUSE_UP, function SelectSkill, false)
            
            set FS_ButtonBackDrop[types][0]=DzCreateFrameByTagName("BACKDROP", "", FS_Button[types][0], "", 0)
            call DzFrameSetAllPoints(FS_ButtonBackDrop[types][0], FS_Button[types][0])
            call DzFrameSetTexture(FS_ButtonBackDrop[types][0],"ReplaceableTextures\\CommandButtons\\BTNDeathPact.blp", 0)

        elseif types == 16 then
            set FS_Button[types][0]=DzCreateFrameByTagName("BUTTON", "", FS_Button[x*5][0], "ScoreScreenTabButtonTemplate", 0)
            call DzFrameSetPoint(FS_Button[types][0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.050 + (0.060*types), -0.080 - 0.120)
            call DzFrameSetSize(FS_Button[types][0], 0.050, 0.050)
            //call DzFrameSetScriptByCode(FS_Button[types][0], JN_FRAMEEVENT_MOUSE_UP, function SelectSkill, false)
            
            set FS_ButtonBackDrop[types][0]=DzCreateFrameByTagName("BACKDROP", "", FS_Button[types][0], "", 0)
            call DzFrameSetAllPoints(FS_ButtonBackDrop[types][0], FS_Button[types][0])
            call DzFrameSetTexture(FS_ButtonBackDrop[types][0],"ReplaceableTextures\\CommandButtons\\BTNGarithos.blp", 0)
        else
            set i = 0
            set FS_Button[types][i]=DzCreateFrameByTagName("BUTTON", "", FS_Button[x*5][0], "ScoreScreenTabButtonTemplate", 0)
            call DzFrameSetPoint(FS_Button[types][i], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.060 + (0.060*types), -0.080 )
            call DzFrameSetSize(FS_Button[types][i], 0.030, 0.030)
            //call DzFrameSetScriptByCode(FS_Button[types][i], JN_FRAMEEVENT_MOUSE_UP, function SelectSkill, false)
            
            set FS_ButtonBackDrop[types][i]=DzCreateFrameByTagName("BACKDROP", "", FS_Button[types][i], "", 0)
            call DzFrameSetAllPoints(FS_ButtonBackDrop[types][i], FS_Button[types][i])
            call DzFrameSetTexture(FS_ButtonBackDrop[types][i],"ReplaceableTextures\\CommandButtons\\BTNDeathPact.blp", 0)
            
            set i = 1
            set FS_Button[types][i]=DzCreateFrameByTagName("BUTTON", "", FS_Button[x*5][0], "ScoreScreenTabButtonTemplate", 0)
            call DzFrameSetPoint(FS_Button[types][i], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.060 + (0.060*types), -0.080 + (-0.080*i))
            call DzFrameSetSize(FS_Button[types][i], 0.030, 0.030)
            //call DzFrameSetScriptByCode(FS_Button[types][i], JN_FRAMEEVENT_MOUSE_UP, function SelectSkill, false)
            
            set FS_ButtonBackDrop[types][i]=DzCreateFrameByTagName("BACKDROP", "", FS_Button[types][i], "", 0)
            call DzFrameSetAllPoints(FS_ButtonBackDrop[types][i], FS_Button[types][i])
            call DzFrameSetTexture(FS_ButtonBackDrop[types][i],"ReplaceableTextures\\CommandButtons\\BTNDeathPact.blp", 0)
            
            set i = 2
            set FS_Button[types][i]=DzCreateFrameByTagName("BUTTON", "", FS_Button[x*5][0], "ScoreScreenTabButtonTemplate", 0)
            call DzFrameSetPoint(FS_Button[types][i], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.060 + (0.060*types), -0.080 + (-0.080*i))
            call DzFrameSetSize(FS_Button[types][i], 0.030, 0.030)
            //call DzFrameSetScriptByCode(FS_Button[types][i], JN_FRAMEEVENT_MOUSE_UP, function SelectSkill, false)
            
            set FS_ButtonBackDrop[types][i]=DzCreateFrameByTagName("BACKDROP", "", FS_Button[types][i], "", 0)
            call DzFrameSetAllPoints(FS_ButtonBackDrop[types][i], FS_Button[types][i])
            call DzFrameSetTexture(FS_ButtonBackDrop[types][i],"ReplaceableTextures\\CommandButtons\\BTNDeathPact.blp", 0)
            
            set i = 3
            set FS_Button[types][i]=DzCreateFrameByTagName("BUTTON", "", FS_Button[x*5][0], "ScoreScreenTabButtonTemplate", 0)
            call DzFrameSetPoint(FS_Button[types][i], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.060 + (0.060*types), -0.080 + (-0.080*i))
            call DzFrameSetSize(FS_Button[types][i], 0.030, 0.030)
            //call DzFrameSetScriptByCode(FS_Button[types][i], JN_FRAMEEVENT_MOUSE_UP, function SelectSkill, false)
            
            set FS_ButtonBackDrop[types][i]=DzCreateFrameByTagName("BACKDROP", "", FS_Button[types][i], "", 0)
            call DzFrameSetAllPoints(FS_ButtonBackDrop[types][i], FS_Button[types][i])
            call DzFrameSetTexture(FS_ButtonBackDrop[types][i],"ReplaceableTextures\\CommandButtons\\BTNDeathPact.blp", 0)
        endif
        //call DzFrameShow(FS_Button[types][0], false)
    endfunction

    private function CreateLine takes nothing returns nothing
        //1번줄 앞칸
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4) + 0.025, -0.080 )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4) + 0.035, -0.080 )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3) + 0.025, -0.080 )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3) + 0.035, -0.080 )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2) + 0.025, -0.080 )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2) + 0.035, -0.080 )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        //set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        //call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        //call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*1) + 0.025, -0.080 )
        //call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        //set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        //call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        //call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*1) + 0.035, -0.080 )
        //call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        
        //1번줄 뒷칸
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1) + 0.025, -0.080 )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1) + 0.035, -0.080 )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2) + 0.025, -0.080 )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2) + 0.035, -0.080 )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3) + 0.025, -0.080 )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3) + 0.035, -0.080 )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        //set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        //call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        //call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*4) + 0.025, -0.080 )
        //call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        //set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        //call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        //call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*4) + 0.035, -0.080 )
        //call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        
        //2번줄 앞칸
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4) + 0.025, -0.080 + (-0.080*1) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4) + 0.035, -0.080 + (-0.080*1) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3) + 0.025, -0.080 + (-0.080*1) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3) + 0.035, -0.080 + (-0.080*1) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2) + 0.025, -0.080 + (-0.080*1) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2) + 0.035, -0.080 + (-0.080*1) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        //2번줄 뒷칸
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1) + 0.025, -0.080 + (-0.080*1) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1) + 0.035, -0.080 + (-0.080*1) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2) + 0.025, -0.080 + (-0.080*1) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2) + 0.035, -0.080 + (-0.080*1) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3) + 0.025, -0.080 + (-0.080*1) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3) + 0.035, -0.080 + (-0.080*1) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        //3번줄 앞칸
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4) + 0.025, -0.080 + (-0.080*2) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4) + 0.035, -0.080 + (-0.080*2) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3) + 0.025, -0.080 + (-0.080*2) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3) + 0.035, -0.080 + (-0.080*2) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2) + 0.025, -0.080 + (-0.080*2) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2) + 0.035, -0.080 + (-0.080*2) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        //3번줄 뒷칸
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1) + 0.025, -0.080 + (-0.080*2) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1) + 0.035, -0.080 + (-0.080*2) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2) + 0.025, -0.080 + (-0.080*2) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2) + 0.035, -0.080 + (-0.080*2) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3) + 0.025, -0.080 + (-0.080*2) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3) + 0.035, -0.080 + (-0.080*2) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        //4번줄 앞칸
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4) + 0.025, -0.080 + (-0.080*3) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4) + 0.035, -0.080 + (-0.080*3) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3) + 0.025, -0.080 + (-0.080*3) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3) + 0.035, -0.080 + (-0.080*3) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2) + 0.025, -0.080 + (-0.080*3) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2) + 0.035, -0.080 + (-0.080*3) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        //4번줄 뒷칸
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1) + 0.025, -0.080 + (-0.080*3) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1) + 0.035, -0.080 + (-0.080*3) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2) + 0.025, -0.080 + (-0.080*3) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2) + 0.035, -0.080 + (-0.080*3) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3) + 0.025, -0.080 + (-0.080*3) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FS_LineBackDrop[0]=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "", 0)
        call DzFrameSetSize(FS_LineBackDrop[0], 0.002, 0.002)
        call DzFrameSetPoint(FS_LineBackDrop[0], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3) + 0.035, -0.080 + (-0.080*3) )
        call DzFrameSetTexture(FS_LineBackDrop[0],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
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
        call DzFrameSetSize(FS_BackDrop, 0.75, 0.39)
        
        //왼쪽
        set FS_L2=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "template", 0)
        call DzFrameSetTexture(FS_L2, "UI_L2.blp", 0)
        call DzFrameSetSize(FS_L2, 0.030, 0.030)
        call DzFrameSetAbsolutePoint(FS_L2, JN_FRAMEPOINT_CENTER, 0.6850, 0.1500)
        call DzFrameShow(FS_L2, true)
        set FS_LB = DzCreateFrameByTagName("BUTTON", "", FS_BackDrop, "ScoreScreenTabButtonTemplate", 0)
        call DzFrameSetAbsolutePoint(FS_LB, JN_FRAMEPOINT_CENTER, 0.6850, 0.1500)
        call DzFrameSetSize(FS_LB, 0.030, 0.030)
        call DzFrameSetScriptByCode(FS_LB, JN_FRAMEEVENT_MOUSE_UP, function ClickRLButton, false)
        set FS_L=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "template", 0)
        call DzFrameSetTexture(FS_L, "UI_L.blp", 0)
        call DzFrameSetSize(FS_L, 0.030, 0.030)
        call DzFrameSetAbsolutePoint(FS_L, JN_FRAMEPOINT_CENTER, 0.6850, 0.1500)
        call DzFrameShow(FS_L, false)
        
        //오른쪽
        set FS_R2=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "template", 0)
        call DzFrameSetTexture(FS_R2, "UI_R2.blp", 0)
        call DzFrameSetSize(FS_R2, 0.030, 0.030)
        call DzFrameSetAbsolutePoint(FS_R2, JN_FRAMEPOINT_CENTER, 0.7300, 0.1500)
        call DzFrameShow(FS_R2, false)
        set FS_RB = DzCreateFrameByTagName("BUTTON", "", FS_BackDrop, "ScoreScreenTabButtonTemplate", 0)
        call DzFrameSetAbsolutePoint(FS_RB, JN_FRAMEPOINT_CENTER, 0.7300, 0.1500)
        call DzFrameSetSize(FS_RB, 0.030, 0.030)
        call DzFrameSetScriptByCode(FS_RB, JN_FRAMEEVENT_MOUSE_UP, function ClickRLButton, false)
        set FS_R=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "template", 0)
        call DzFrameSetTexture(FS_R, "UI_R.blp", 0)
        call DzFrameSetSize(FS_R, 0.030, 0.030)
        call DzFrameSetAbsolutePoint(FS_R, JN_FRAMEPOINT_CENTER, 0.7300, 0.1500)
        
        //시작
        call CreateSkillButton(0,0)

        call CreateSkillButton(1,0)
        call CreateSkillButton(2,0)
        call CreateSkillButton(3,0)
        call CreateSkillButton(4,0)
        //보스선택or보너스
        call CreateSkillButton(5,1)

        call CreateSkillButton(6,1)
        call CreateSkillButton(7,1)
        call CreateSkillButton(8,1)
        call CreateSkillButton(9,1)
        //유물상자
        call CreateSkillButton(10,2)

        call CreateSkillButton(11,2)
        call CreateSkillButton(12,2)
        call CreateSkillButton(13,2)
        call CreateSkillButton(14,2)

        call CreateSkillButton(15,3)
        //보스
        call CreateSkillButton(16,3)
        //선
        call CreateLine()

        call DzFrameShow(FS_Button[0][0], true)
        call DzFrameShow(FS_Button[5][0], true)
        call DzFrameShow(FS_Button[10][0], false)
        call DzFrameShow(FS_Button[15][0], false)
        
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
    
    private function init takes nothing returns nothing
        local trigger t=CreateTrigger()
        local integer index
        
        set t = CreateTrigger()
        call TriggerAddAction( t, function Main )
        call TriggerRegisterTimerEventSingle( t, 0.1 )
        
        
        //esc버튼으로 인벤토리 닫기
        set t = CreateTrigger()
        
        call TriggerRegisterPlayerEvent(t, Player(0), EVENT_PLAYER_END_CINEMATIC)
        call TriggerRegisterPlayerEvent(t, Player(1), EVENT_PLAYER_END_CINEMATIC)
        call TriggerRegisterPlayerEvent(t, Player(2), EVENT_PLAYER_END_CINEMATIC)
        call TriggerRegisterPlayerEvent(t, Player(3), EVENT_PLAYER_END_CINEMATIC)

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
        
        set t = null
        
    endfunction
endlibrary