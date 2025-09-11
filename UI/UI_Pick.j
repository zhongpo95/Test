library UIPick initializer Init requires UIHP, UISkillLevel, UIItem, Daily, FrameCount
    globals
        integer FP_BD               //픽 백드롭
        integer array FP_SL         //세이브 리스트 프레임
        integer array FP_SLB        //세이브 리스트 버튼
        integer array FP_HeroBBD    //버튼백드롭
        integer array FP_HeroB      //버튼
        integer FP_SelectBBD        //셀렉결정
        integer FP_SelectB          //셀렉결정버튼
        integer FP_SelectBT         //셀렉결정텍스트
        integer array FP_PotBD      //포트레잇 백드롭
        integer FP_HeroTBD          //캐릭터설명 텍스트 백드롭
        integer array FP_HeroT      //캐릭터설명 텍스트
        integer array PlayerSlotNumber     //플레이어 슬롯넘버
        integer SLNumber = 0        //활성화중인 슬롯넘버
        integer SHNumber = 0        //활성화중인 영웅넘버
        integer FP_LoadBBD          //로드결정
        integer FP_LoadB            //로드결정버튼
        integer FP_LoadBT           //로드결정텍스트
        constant integer MaxHero = 4
    endglobals
    
    function StringNullCheck2 takes string s returns boolean
        if s == "" or s == null then
            return true
        endif
        return false
    endfunction
    
    private function upload2 takes integer pid returns nothing
        local string str = I2S(PlayerSlotNumber[pid])
        local integer i = 0
        call StashSave(PLAYER_DATA[pid], "슬롯"+ str + ".E0", Eitem[pid][0])
        if Eitem[pid][1] != null then
            call StashSave(PLAYER_DATA[pid], "슬롯"+ str + ".E1", Eitem[pid][1])
        endif
        /*
        call StashSave(PLAYER_DATA[pid], "슬롯"+ str + ".E2", Eitem[pid][2])
        call StashSave(PLAYER_DATA[pid], "슬롯"+ str + ".E3", Eitem[pid][3])
        */
        //call StashSave(PLAYER_DATA[pid], "슬롯"+ str + ".E4", Eitem[pid][4])
        call StashSave(PLAYER_DATA[pid], "슬롯"+ str + ".E5", Eitem[pid][5])
        if Eitem[pid][6] != null then
            call StashSave(PLAYER_DATA[pid], "슬롯"+ str + ".E6", Eitem[pid][6])
        endif
        if Eitem[pid][7] != null then
            call StashSave(PLAYER_DATA[pid], "슬롯"+ str + ".E7", Eitem[pid][7])
        endif
        if Eitem[pid][8] != null then
            call StashSave(PLAYER_DATA[pid], "슬롯"+ str + ".E8", Eitem[pid][8])
        endif
        if Eitem[pid][9] != null then
            call StashSave(PLAYER_DATA[pid], "슬롯"+ str + ".E9", Eitem[pid][9])
        endif
        if Eitem[pid][10] != null then
            call StashSave(PLAYER_DATA[pid], "슬롯"+ str + ".E10", Eitem[pid][10])
        endif
        if Eitem[pid][11] != null then
            call StashSave(PLAYER_DATA[pid], "슬롯"+ str + ".E11", Eitem[pid][11])
        endif
        if Eitem[pid][12] != null then
            call StashSave(PLAYER_DATA[pid], "슬롯"+ str + ".E12", Eitem[pid][12])
        endif
        if Eitem[pid][13] != null then
            call StashSave(PLAYER_DATA[pid], "슬롯"+ str + ".E13", Eitem[pid][13])
        endif
        if Eitem[pid][14] != null then
            call StashSave(PLAYER_DATA[pid], "슬롯"+ str + ".E14", Eitem[pid][14])
        endif
        if Eitem[pid][15] != null then
            call StashSave(PLAYER_DATA[pid], "슬롯"+ str + ".E15", Eitem[pid][15])
        endif
        
        call JNStashNetUploadUser( Player(pid), MapName, GetPlayerName(Player(pid)), MapApi, PLAYER_DATA[pid], UPLOAD_CALLBACK )
    endfunction

    private function ClickLoadButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        
        call DzFrameShow(FP_BD, false)
        call DzSyncData("LoadPick", I2S(SLNumber))
    endfunction
    
    private function ClickBBDButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        
        call DzFrameShow(FP_PotBD[1], false)
        call DzFrameShow(FP_PotBD[2], false)
        call DzFrameShow(FP_PotBD[3], false)
        call DzFrameShow(FP_PotBD[4], false)
        call DzFrameShow(FP_PotBD[5], false)
        call DzFrameShow(FP_PotBD[6], false)
        call DzFrameShow(FP_PotBD[7], false)
        call DzFrameShow(FP_PotBD[8], false)
        call DzFrameShow(FP_PotBD[9], false)
        call DzFrameShow(FP_PotBD[10], false)
        call DzFrameShow(FP_PotBD[11], false)
        call DzFrameShow(FP_PotBD[12], false)
            
        if f == FP_HeroB[1] then
            set SHNumber = 1
            call DzFrameShow(FP_PotBD[1], true)
        elseif f == FP_HeroB[2] then
            set SHNumber = 2
            call DzFrameShow(FP_PotBD[2], true)
        elseif f == FP_HeroB[3] then
            set SHNumber = 3
            call DzFrameShow(FP_PotBD[3], true)
        elseif f == FP_HeroB[4] then
            set SHNumber = 4
            call DzFrameShow(FP_PotBD[4], true)
        elseif f == FP_HeroB[5] then
            set SHNumber = 5
            call DzFrameShow(FP_PotBD[5], true)
        elseif f == FP_HeroB[6] then
            set SHNumber = 6
            call DzFrameShow(FP_PotBD[6], true)
        elseif f == FP_HeroB[7] then
            set SHNumber = 7
            call DzFrameShow(FP_PotBD[7], true)
        elseif f == FP_HeroB[8] then
            set SHNumber = 8
            call DzFrameShow(FP_PotBD[8], true)
        elseif f == FP_HeroB[9] then
            set SHNumber = 9
            call DzFrameShow(FP_PotBD[9], true)
        elseif f == FP_HeroB[10] then
            set SHNumber = 10
            call DzFrameShow(FP_PotBD[10], true)
        elseif f == FP_HeroB[11] then
            set SHNumber = 11
            call DzFrameShow(FP_PotBD[11], true)
        elseif f == FP_HeroB[12] then
            set SHNumber = 12
            call DzFrameShow(FP_PotBD[12], true)
        endif
    endfunction
    
    private function ClickPickHeroButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        
        if SHNumber != 0 then
            call DzFrameShow(FP_BD, false)
            call DzSyncData("NewPick", I2S(SHNumber) + ";" + I2S(SLNumber))
        endif
    endfunction
    
    private function ClickSLButton1 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        if f == FP_SLB[1] then
            if StashLoad(PLAYER_DATA[pid], "슬롯1", null) == null then
                call DzFrameSetTexture(FP_SL[1], "UI_PickSelect2.blp", 0)
            else
                call DzFrameSetTexture(FP_SL[1], "UI_PickSelect1Hero"+ StashLoad(PLAYER_DATA[pid], "슬롯1", null) +".blp", 0)
            endif
        endif
        if f == FP_SLB[2] then
            if StashLoad(PLAYER_DATA[pid], "슬롯2", null) == null then
                call DzFrameSetTexture(FP_SL[2], "UI_PickSelect2.blp", 0)
            else
                call DzFrameSetTexture(FP_SL[2], "UI_PickSelect1Hero"+ StashLoad(PLAYER_DATA[pid], "슬롯2", null) +".blp", 0)
            endif
        endif
        if f == FP_SLB[3] then
            if StashLoad(PLAYER_DATA[pid], "슬롯3", null) == null then
                call DzFrameSetTexture(FP_SL[3], "UI_PickSelect2.blp", 0)
            else
                call DzFrameSetTexture(FP_SL[3], "UI_PickSelect1Hero"+ StashLoad(PLAYER_DATA[pid], "슬롯3", null) +".blp", 0)
            endif
        endif
        /*
        if f == FP_SLB[4] then
            if StashLoad(PLAYER_DATA[pid], "슬롯4", null) == null then
                call DzFrameSetTexture(FP_SL[4], "UI_PickSelect2.blp", 0)
            else
                call DzFrameSetTexture(FP_SL[4], "UI_PickSelect1Hero"+ StashLoad(PLAYER_DATA[pid], "슬롯4", null) +".blp", 0)
            endif
        endif
        */
    endfunction
    private function ClickSLButton2 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        if f == FP_SLB[1] then
            if StashLoad(PLAYER_DATA[pid], "슬롯1", null) == null then
                call DzFrameSetTexture(FP_SL[1], "UI_PickSelect2.blp", 0)
            else
                call DzFrameSetTexture(FP_SL[1], "UI_PickSelect1Hero"+ StashLoad(PLAYER_DATA[pid], "슬롯1", null) +".blp", 0)
            endif
        endif
        if f == FP_SLB[2] then
            if StashLoad(PLAYER_DATA[pid], "슬롯2", null) == null then
                call DzFrameSetTexture(FP_SL[2], "UI_PickSelect2.blp", 0)
            else
                call DzFrameSetTexture(FP_SL[2], "UI_PickSelect1Hero"+ StashLoad(PLAYER_DATA[pid], "슬롯2", null) +".blp", 0)
            endif
            
        endif
        if f == FP_SLB[3] then
            if StashLoad(PLAYER_DATA[pid], "슬롯3", null) == null then
                call DzFrameSetTexture(FP_SL[3], "UI_PickSelect2.blp", 0)
            else
                call DzFrameSetTexture(FP_SL[3], "UI_PickSelect1Hero"+ StashLoad(PLAYER_DATA[pid], "슬롯3", null) +".blp", 0)
            endif
        endif
        /*
        if f == FP_SLB[4] then
            if StashLoad(PLAYER_DATA[pid], "슬롯4", null) == null then
                call DzFrameSetTexture(FP_SL[4], "UI_PickSelect2.blp", 0)
            else
                call DzFrameSetTexture(FP_SL[4], "UI_PickSelect1Hero"+ StashLoad(PLAYER_DATA[pid], "슬롯4", null) +".blp", 0)
            endif
        endif
        */
    endfunction
    
    private function ClickSLButton3 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        
        if f == FP_SLB[1] then
            if StashLoad(PLAYER_DATA[pid], "슬롯1", null) == null then
                call DzFrameShow(FP_HeroBBD[0], true)
                call DzFrameShow(FP_LoadBBD, false)
                set SLNumber = 1
                set SHNumber = 0
                call DzFrameShow(FP_PotBD[1], false)
                call DzFrameShow(FP_PotBD[2], false)
                call DzFrameShow(FP_PotBD[3], false)
                call DzFrameShow(FP_PotBD[4], false)
                call DzFrameShow(FP_PotBD[5], false)
                call DzFrameShow(FP_PotBD[6], false)
                call DzFrameShow(FP_PotBD[7], false)
                call DzFrameShow(FP_PotBD[8], false)
                call DzFrameShow(FP_PotBD[9], false)
                call DzFrameShow(FP_PotBD[10], false)
                call DzFrameShow(FP_PotBD[11], false)
                call DzFrameShow(FP_PotBD[12], false)
            else
                set SLNumber = 1
                call DzFrameShow(FP_HeroBBD[0], false)
                call DzFrameShow(FP_LoadBBD, true)
            endif
        endif
        if f == FP_SLB[2] then
            if StashLoad(PLAYER_DATA[pid], "슬롯2", null) == null then
                call DzFrameShow(FP_HeroBBD[0], true)
                call DzFrameShow(FP_LoadBBD, false)
                set SLNumber = 2
                set SHNumber = 0
                call DzFrameShow(FP_PotBD[1], false)
                call DzFrameShow(FP_PotBD[2], false)
                call DzFrameShow(FP_PotBD[3], false)
                call DzFrameShow(FP_PotBD[4], false)
                call DzFrameShow(FP_PotBD[5], false)
                call DzFrameShow(FP_PotBD[6], false)
                call DzFrameShow(FP_PotBD[7], false)
                call DzFrameShow(FP_PotBD[8], false)
                call DzFrameShow(FP_PotBD[9], false)
                call DzFrameShow(FP_PotBD[10], false)
                call DzFrameShow(FP_PotBD[11], false)
                call DzFrameShow(FP_PotBD[12], false)
            else
                set SLNumber = 2
                call DzFrameShow(FP_HeroBBD[0], false)
                call DzFrameShow(FP_LoadBBD, true)
            endif
        endif
        if f == FP_SLB[3] then
            if StashLoad(PLAYER_DATA[pid], "슬롯3", null) == null then
                call DzFrameShow(FP_HeroBBD[0], true)
                call DzFrameShow(FP_LoadBBD, false)
                set SLNumber = 3
                set SHNumber = 0
                call DzFrameShow(FP_PotBD[1], false)
                call DzFrameShow(FP_PotBD[2], false)
                call DzFrameShow(FP_PotBD[3], false)
                call DzFrameShow(FP_PotBD[4], false)
                call DzFrameShow(FP_PotBD[5], false)
                call DzFrameShow(FP_PotBD[6], false)
                call DzFrameShow(FP_PotBD[7], false)
                call DzFrameShow(FP_PotBD[8], false)
                call DzFrameShow(FP_PotBD[9], false)
                call DzFrameShow(FP_PotBD[10], false)
                call DzFrameShow(FP_PotBD[11], false)
                call DzFrameShow(FP_PotBD[12], false)
            else
                set SLNumber = 3
                call DzFrameShow(FP_HeroBBD[0], false)
                call DzFrameShow(FP_LoadBBD, true)
            endif
        endif
        /*
        if f == FP_SLB[4] then
            if StashLoad(PLAYER_DATA[pid], "슬롯4", null) == null then
                call DzFrameShow(FP_SelectBBD, true)
                call DzFrameShow(FP_LoadBBD, false)
                set SLNumber = 4
                set SHNumber = 0
                call DzFrameShow(FP_PotBD[1], false)
                call DzFrameShow(FP_PotBD[2], false)
                call DzFrameShow(FP_PotBD[3], false)
                call DzFrameShow(FP_PotBD[4], false)
                call DzFrameShow(FP_PotBD[5], false)
                call DzFrameShow(FP_PotBD[6], false)
                call DzFrameShow(FP_PotBD[7], false)
                call DzFrameShow(FP_PotBD[8], false)
                call DzFrameShow(FP_PotBD[9], false)
                call DzFrameShow(FP_PotBD[10], false)
                call DzFrameShow(FP_PotBD[11], false)
                call DzFrameShow(FP_PotBD[12], false)
            else
                set SLNumber = 4
                call DzFrameShow(FP_SelectBBD, false)
                call DzFrameShow(FP_LoadBBD, true)
            endif
        endif
        */
    endfunction
    
    private function Main2 takes nothing returns nothing
        if true then
            call DzFrameShow(FP_BD, true)
        endif
        /*
        if JNGetConnectionState() == 1280266064 then
            call BJDebugMsg("현재 싱글 플레이중입니다.")
        elseif JNGetConnectionState() == 1413697614 then
            call BJDebugMsg("현재 LAN에서 중입니다.")
        elseif JNGetConnectionState() == 1112425812 then
            call BJDebugMsg("현재 배틀넷에서 플레이중입니다.")
            call DzFrameShow(FP_BD, true)
        endif
        */
    endfunction
    
    private function Main takes nothing returns nothing
        local string s
        local integer i
        local integer j
        local integer k

        //카메라
        call SetCameraBoundsToRectForPlayerBJ( GetLocalPlayer(), gg_rct_Pick )
        call SetCameraPositionForPlayer(GetLocalPlayer(),GetRectCenterX(gg_rct_Pick),GetRectCenterY(gg_rct_Pick))
        
        call DzLoadToc("war3mapImported\\Templates.toc")
        
        set FP_BD=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "template", FrameCount())
        call DzFrameSetTexture(FP_BD, "ys_shuye.tga", 0)
        call DzFrameSetSize(FP_BD, 0.72, 0.42)
        call DzFrameSetAbsolutePoint(FP_BD, JN_FRAMEPOINT_CENTER, 0.4000, 0.3600)
        call DzFrameShow(FP_BD, false)
        
        set FP_SL[1]=DzCreateFrameByTagName("BACKDROP", "", FP_BD, "template", FrameCount())
        call DzFrameSetTexture(FP_SL[1], "UI_PickSelect2.blp", 0)
        call DzFrameSetSize(FP_SL[1], 0.20, 0.10)
        call DzFrameSetAbsolutePoint(FP_SL[1], JN_FRAMEPOINT_CENTER, 0.2300, 0.4800)
        set FP_SLB[1] = DzCreateFrameByTagName("BUTTON", "", FP_BD, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetAbsolutePoint(FP_SLB[1], JN_FRAMEPOINT_CENTER, 0.2300, 0.4800)
        call DzFrameSetSize(FP_SLB[1], 0.20, 0.10)
        call DzFrameSetScriptByCode(FP_SLB[1], JN_FRAMEEVENT_MOUSE_ENTER, function ClickSLButton1, false)
        call DzFrameSetScriptByCode(FP_SLB[1], JN_FRAMEEVENT_MOUSE_LEAVE, function ClickSLButton2, false)
        call DzFrameSetScriptByCode(FP_SLB[1], JN_FRAMEEVENT_MOUSE_UP, function ClickSLButton3, false)
        
        set FP_SL[2]=DzCreateFrameByTagName("BACKDROP", "", FP_BD, "template", FrameCount())
        call DzFrameSetTexture(FP_SL[2], "UI_PickSelect2.blp", 0)
        call DzFrameSetSize(FP_SL[2], 0.20, 0.10)
        call DzFrameSetAbsolutePoint(FP_SL[2], JN_FRAMEPOINT_CENTER, 0.2300, 0.3700)
        set FP_SLB[2] = DzCreateFrameByTagName("BUTTON", "", FP_BD, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetAbsolutePoint(FP_SLB[2], JN_FRAMEPOINT_CENTER, 0.2300, 0.3700)
        call DzFrameSetSize(FP_SLB[2], 0.20, 0.10)
        call DzFrameSetScriptByCode(FP_SLB[2], JN_FRAMEEVENT_MOUSE_ENTER, function ClickSLButton1, false)
        call DzFrameSetScriptByCode(FP_SLB[2], JN_FRAMEEVENT_MOUSE_LEAVE, function ClickSLButton2, false)
        call DzFrameSetScriptByCode(FP_SLB[2], JN_FRAMEEVENT_MOUSE_UP, function ClickSLButton3, false)
        
        set FP_SL[3]=DzCreateFrameByTagName("BACKDROP", "", FP_BD, "template", FrameCount())
        call DzFrameSetTexture(FP_SL[3], "UI_PickSelect2.blp", 0)
        call DzFrameSetSize(FP_SL[3], 0.20, 0.10)
        call DzFrameSetAbsolutePoint(FP_SL[3], JN_FRAMEPOINT_CENTER, 0.2300, 0.2600)
        set FP_SLB[3] = DzCreateFrameByTagName("BUTTON", "", FP_BD, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetAbsolutePoint(FP_SLB[3], JN_FRAMEPOINT_CENTER, 0.2300, 0.2600)
        call DzFrameSetSize(FP_SLB[3], 0.20, 0.10)
        call DzFrameSetScriptByCode(FP_SLB[3], JN_FRAMEEVENT_MOUSE_ENTER, function ClickSLButton1, false)
        call DzFrameSetScriptByCode(FP_SLB[3], JN_FRAMEEVENT_MOUSE_LEAVE, function ClickSLButton2, false)
        call DzFrameSetScriptByCode(FP_SLB[3], JN_FRAMEEVENT_MOUSE_UP, function ClickSLButton3, false)
        
        /*
        set FP_SLB[4] = DzCreateFrameByTagName("BUTTON", "", FP_BD, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetAbsolutePoint(FP_SLB[4], JN_FRAMEPOINT_CENTER, 0.2750, 0.1300)
        call DzFrameSetSize(FP_SLB[4], 0.20, 0.10)
        call DzFrameSetScriptByCode(FP_SLB[4], JN_FRAMEEVENT_MOUSE_ENTER, function ClickSLButton1, false)
        call DzFrameSetScriptByCode(FP_SLB[4], JN_FRAMEEVENT_MOUSE_LEAVE, function ClickSLButton2, false)
        call DzFrameSetScriptByCode(FP_SLB[4], JN_FRAMEEVENT_MOUSE_UP, function ClickSLButton3, false)
        set FP_SL[4]=DzCreateFrameByTagName("BACKDROP", "", FP_BD, "template", FrameCount())
        call DzFrameSetTexture(FP_SL[4], "UI_PickSelect2.blp", 0)
        call DzFrameSetSize(FP_SL[4], 0.20, 0.10)
        call DzFrameSetAbsolutePoint(FP_SL[4], JN_FRAMEPOINT_CENTER, 0.2750, 0.1300)
        */

        set FP_HeroBBD[0]=DzCreateFrameByTagName("BACKDROP", "", FP_BD, "", FrameCount())

        set j = 0
        loop
            set i = 1
            loop
                set FP_HeroBBD[i+(j*6)]=DzCreateFrameByTagName("BACKDROP", "", FP_HeroBBD[0], "", FrameCount())
                call DzFrameSetAbsolutePoint(FP_HeroBBD[i+(j*6)], JN_FRAMEPOINT_CENTER, 0.4800+(0.035*(i-1))+(0.0100*j), 0.5200-(0.035*j))
                call DzFrameSetSize(FP_HeroBBD[i+(j*6)], 0.035, 0.035)
                if i+(j*6) <= MaxHero then
                    call DzFrameSetTexture(FP_HeroBBD[i+(j*6)], "ReplaceableTextures\\CommandButtons\\BTNHeroIcon"+I2S(i+(j*6))+".blp", 0)
                    set FP_HeroB[i+(j*6)]=DzCreateFrameByTagName("BUTTON", "", FP_HeroBBD[i+(j*6)], "ScoreScreenTabButtonTemplate",  FrameCount())
                    call DzFrameSetAllPoints(FP_HeroB[i+(j*6)], FP_HeroBBD[i+(j*6)])
                    call DzFrameSetSize(FP_HeroB[i+(j*6)], 0.035, 0.035)
                    call DzFrameSetScriptByCode(FP_HeroB[i+(j*6)], JN_FRAMEEVENT_MOUSE_UP, function ClickBBDButton, false)
                    
                    set FP_PotBD[i+(j*6)]=DzCreateFrameByTagName("BACKDROP", "", FP_HeroBBD[i+(j*6)], "template", FrameCount())
                    call DzFrameSetTexture(FP_PotBD[i+(j*6)], "UI_HeroPot"+I2S(i+(j*6))+".blp", 0)
                    call DzFrameSetSize(FP_PotBD[i+(j*6)], 0.22, 0.22)
                    call DzFrameSetAbsolutePoint(FP_PotBD[i+(j*6)], JN_FRAMEPOINT_CENTER, 0.5800, 0.3400)
                    call DzFrameShow(FP_PotBD[i+(j*6)], false)
                else
                    call DzFrameSetTexture(FP_HeroBBD[i+(j*6)], "ReplaceableTextures\\CommandButtons\\BTNHeroIcon0.blp", 0)
                endif
                set i = i + 1
                exitwhen i == 7
            endloop
            set j = j + 1
            exitwhen j == 2
        endloop
                
        /*
        set FP_HeroTBD=DzCreateFrameByTagName("BACKDROP", "", FP_SelectBBD, "template", FrameCount())
        call DzFrameSetTexture(FP_HeroTBD, "UI_PickText.tga", 0)
        call DzFrameSetSize(FP_HeroTBD, 0.22, 0.12)
        call DzFrameSetAbsolutePoint(FP_HeroTBD, JN_FRAMEPOINT_CENTER, 0.5700, 0.2100)
        call DzFrameShow(FP_HeroTBD, true)
        */
        
        set FP_SelectBBD=DzCreateFrameByTagName("BACKDROP", "", FP_HeroBBD[0], "template", FrameCount())
        call DzFrameSetTexture(FP_SelectBBD, "UI_PickSelectButton.tga", 0)
        call DzFrameSetSize(FP_SelectBBD, 0.06, 0.03)
        call DzFrameSetAbsolutePoint(FP_SelectBBD, JN_FRAMEPOINT_CENTER, 0.7000, 0.2200)
        
        set FP_SelectBT=DzCreateFrameByTagName("TEXT","",FP_SelectBBD,"",0)
        call DzFrameSetAbsolutePoint(FP_SelectBT, JN_FRAMEPOINT_CENTER, 0.7000, 0.2200)
        call DzFrameSetText(FP_SelectBT,"결정")
        
        set FP_SelectB=DzCreateFrameByTagName("BUTTON", "", FP_SelectBBD, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetAllPoints(FP_SelectB, FP_SelectBBD)
        call DzFrameSetSize(FP_SelectB, 0.06, 0.03)
        call DzFrameSetScriptByCode(FP_SelectB, JN_FRAMEEVENT_MOUSE_UP, function ClickPickHeroButton, false)

        call DzFrameShow(FP_HeroBBD[0], false)
        
        //로드
        set FP_LoadBBD=DzCreateFrameByTagName("BACKDROP", "", FP_BD, "template", FrameCount())
        call DzFrameSetTexture(FP_LoadBBD, "UI_PickSelectButton.tga", 0)
        call DzFrameSetSize(FP_LoadBBD, 0.06, 0.03)
        call DzFrameSetAbsolutePoint(FP_LoadBBD, JN_FRAMEPOINT_CENTER, 0.7000, 0.2200)
        call DzFrameShow(FP_LoadBBD, false)
        
        set FP_LoadBT=DzCreateFrameByTagName("TEXT","",FP_LoadBBD,"",0)
        call DzFrameSetAbsolutePoint(FP_LoadBT, JN_FRAMEPOINT_CENTER, 0.7000, 0.2200)
        call DzFrameSetText(FP_LoadBT,"결정")
        
        set FP_LoadB=DzCreateFrameByTagName("BUTTON", "", FP_LoadBBD, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetAllPoints(FP_LoadB, FP_LoadBBD)
        call DzFrameSetSize(FP_LoadB, 0.06, 0.03)
        call DzFrameSetScriptByCode(FP_LoadB, JN_FRAMEEVENT_MOUSE_UP, function ClickLoadButton, false)
        
    endfunction
      
    private function LoadPickF takes nothing returns nothing
        local player p=(DzGetTriggerSyncPlayer())
        local integer SlotNumber = S2I(DzGetTriggerSyncData())
        local integer pid=GetPlayerId(p)
        local integer HeroTypeId
        local integer j = 0
        local string str = null
        
        set PlayerSlotNumber[pid] = SlotNumber
        
        if StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber), null) == "1" then
            set HeroTypeId = 'H004'
        elseif StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber), null) == "2" then
            set HeroTypeId = 'H003'
        elseif StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber), null) == "3" then
            set HeroTypeId = 'H00I'
            if p == GetLocalPlayer() then
                call DzFrameShow(NarAden, true)
                call DzFrameShow(NarAdens[0], false)
                call DzFrameShow(NarAdens[1], false)
                call DzFrameShow(NarAdens[2], false)
                call DzFrameShow(NarAdens[3], false)
                call DzFrameShow(NarAdens[4], false)
                call DzFrameShow(NarAdens[5], false)
                call DzFrameShow(NarAdens2[0], true)
                call DzFrameShow(NarAdens2[1], true)
                call DzFrameShow(NarAdens2[2], true)
                call DzFrameShow(NarAdens2[3], true)
                call DzFrameShow(NarAdens2[4], true)
                call DzFrameShow(NarAdens2[5], true)
            endif
            set NarNabi[pid] = 0
            //call DzFrameShow(skillbuttonframe[8],true)
            //call DzFrameShow(NarAden2, true)
        elseif StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber), null) == "4" then
            set HeroTypeId = 'H00K'
            //call DzFrameShow(BanAden, true)
            call DzFrameShow(BanAdens[0], true)
            call DzFrameShow(BanAdens2[0], true)
            call DzFrameShow(BanAdens2[1], true)
            call DzFrameShow(BanAdens2[2], true)
            call DzFrameShow(BanAdens2[3], true)
            call DzFrameShow(BanAdens2[4], true)
            set BanBisul[pid] = 0
            set BanBisul2[pid] = 0
            set BandiForm[pid] = CreateUnit(Player(pid),'e03A',0,0,0)
            //form 반디
            set BandiState[pid] = 1
        endif
        
        set MainUnit[pid] = CreateUnit(Player(pid), HeroTypeId, GetRectCenterX(gg_rct_Home),GetRectCenterY(gg_rct_Home), 0)

        
        if StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber), null) == "1" then

        elseif StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber), null) == "2" then

        elseif StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber), null) == "3" then
            set NarFormG[pid] = CreateUnit(Player(pid),'e027',0,0,0)
        endif

        call SelectUnitForPlayerSingle( MainUnit[pid], Player(pid) )
        //카메라
        call SetCameraBoundsToRectForPlayerBJ( p, gg_rct_Home )
        call SetCameraPositionForPlayer(p,GetWidgetX(MainUnit[pid]),GetWidgetY(MainUnit[pid]))

        if GetItemCharge(StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".포션1", "0")) > 0 then
            set PlayerItem1[pid] = CreateItem('I009',0,0)
            call UnitAddItem(MainUnit[pid],PlayerItem1[pid])
            call SetItemCharges(PlayerItem1[pid], GetItemCharge(StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".포션1", "0")))
        else
            set PlayerItem1[pid] = CreateItem('I00J',0,0)
            call UnitAddItem(MainUnit[pid],PlayerItem1[pid])
            call StashSave(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".포션1", "ID26;중첩수0")
        endif
        if GetItemCharge(StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".포션2", "0")) > 0 then
            set PlayerItem2[pid] = CreateItem('I00C',0,0)
            call UnitAddItem(MainUnit[pid],PlayerItem2[pid])
            call SetItemCharges(PlayerItem2[pid], GetItemCharge(StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".포션2", "0")))
        else
            set PlayerItem2[pid] = CreateItem('I00G',0,0)
            call UnitAddItem(MainUnit[pid],PlayerItem2[pid])
            call StashSave(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".포션2", "ID22;중첩수0")
        endif
        if GetItemCharge(StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".포션3", "0")) > 0 then
            set PlayerItem3[pid] = CreateItem('I00A',0,0)
            call UnitAddItem(MainUnit[pid],PlayerItem3[pid])
            call SetItemCharges(PlayerItem3[pid], GetItemCharge(StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".포션3", "0")))
        else
            set PlayerItem3[pid] = CreateItem('I00I',0,0)
            call UnitAddItem(MainUnit[pid],PlayerItem3[pid])
            call StashSave(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".포션3", "ID25;중첩수0")
        endif
        
        set Eitem[pid][0] = StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".E0", "0")
        set Eitem[pid][1] = StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".E1", "0")
        /*
        set Eitem[pid][2] = StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".E2", "0")
        set Eitem[pid][3] = StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".E3", "0")
        */
        //set Eitem[pid][4] = StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".E4", "0")
        set Eitem[pid][5] = StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".E5", "0")
        
        set j = 0
        loop
            set str = StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".아이템"+I2S(j), "없음")
            if str != "없음" and str != null then
                call AddIvItem(pid, j, str)
                set str = null
            else
            endif
            set j = j + 1
        exitwhen j == 50
        endloop
            
        loop
            set str = StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".아이템"+I2S(j), "없음")
            if str != "없음" and str != null then
                call AddIvItem(pid, j, str)
                set str = null
            else
            endif
            set j = j + 1
        exitwhen j == 100
        endloop
        
        if GetLocalPlayer() == Player(pid) then
            call DzFrameSetText(F_GoldText, StashLoad(PLAYER_DATA[pid], "골드", "0"))
            if Eitem[pid][0] != "" then
                call DzFrameSetTexture(F_EItemButtonsBackDrop[0], GetItemArt(Eitem[pid][0]), 0)
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[0], GetItemArt(Eitem[pid][0]), 0)
            endif
            if Eitem[pid][1] != "" then
                call DzFrameSetTexture(F_EItemButtonsBackDrop[1], GetItemArt(Eitem[pid][1]), 0)
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[1], GetItemArt(Eitem[pid][1]), 0)
            endif
            /*
            if Eitem[pid][2] != "" then
                call DzFrameSetTexture(F_EItemButtonsBackDrop[2], GetItemArt(Eitem[pid][2]), 0)
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[2], GetItemArt(Eitem[pid][2]), 0)
            endif
            if Eitem[pid][3] != "" then
                call DzFrameSetTexture(F_EItemButtonsBackDrop[3], GetItemArt(Eitem[pid][3]), 0)
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[3], GetItemArt(Eitem[pid][3]), 0)
            endif
            */
            if Eitem[pid][5] != "" then
                call DzFrameSetTexture(F_EItemButtonsBackDrop[5], GetItemArt(Eitem[pid][5]), 0)
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[5], GetItemArt(Eitem[pid][5]), 0)
            endif
        endif
        
        if StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".E6", "0") != "0" then
            set Eitem[pid][6] =  StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".E6", "0")
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(F_EItemButtonsBackDrop[6], GetItemArt(Eitem[pid][6]), 0)
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[6], GetItemArt(Eitem[pid][6]), 0)
                call DzFrameSetTexture(F_ArcanaButtonsBackDrop[0], GetItemArt(Eitem[pid][6]), 0)
            endif
        endif
        if StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".E7", "0") != "0" then
            set Eitem[pid][7] =  StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".E7", "0")
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(F_EItemButtonsBackDrop[7], GetItemArt(Eitem[pid][7]), 0)
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[7], GetItemArt(Eitem[pid][7]), 0)
                call DzFrameSetTexture(F_ArcanaButtonsBackDrop[1], GetItemArt(Eitem[pid][7]), 0)
            endif
        endif
        if StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".E8", "0") != "0" then
            set Eitem[pid][8] =  StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".E8", "0")
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(F_EItemButtonsBackDrop[8], GetItemArt(Eitem[pid][8]), 0)
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemArt(Eitem[pid][8]), 0)
                call DzFrameSetTexture(F_ArcanaButtonsBackDrop[2], GetItemArt(Eitem[pid][8]), 0)
            endif
        endif
        if StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".E9", "0") != "0" then
            set Eitem[pid][9] =  StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".E9", "0")
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(F_EItemButtonsBackDrop[9], GetItemArt(Eitem[pid][9]), 0)
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[9], GetItemArt(Eitem[pid][9]), 0)
                call DzFrameSetTexture(F_ArcanaButtonsBackDrop[3], GetItemArt(Eitem[pid][9]), 0)
            endif
        endif
        if StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".E10", "0") != "0" then
            set Eitem[pid][10] =  StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".E10", "0")
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(F_EItemButtonsBackDrop[10], GetItemArt(Eitem[pid][10]), 0)
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[10], GetItemArt(Eitem[pid][10]), 0)
                call DzFrameSetTexture(F_ArcanaButtonsBackDrop[4], GetItemArt(Eitem[pid][10]), 0)
            endif
        endif
        if StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".E11", "0") != "0" then
            set Eitem[pid][11] =  StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".E11", "0")
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(F_EItemButtonsBackDrop[11], GetItemArt(Eitem[pid][11]), 0)
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemArt(Eitem[pid][11]), 0)
            endif
        endif
        if StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".E12", "0") != "0" then
            set Eitem[pid][12] =  StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".E12", "0")
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(F_EItemButtonsBackDrop[12], GetItemArt(Eitem[pid][12]), 0)
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[12], GetItemArt(Eitem[pid][12]), 0)
                call DzFrameSetTexture(F_ArcanaButtonsBackDrop[5], GetItemArt(Eitem[pid][12]), 0)
            endif
        endif
        if StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".E13", "0") != "0" then
            set Eitem[pid][13] =  StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".E13", "0")
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(F_EItemButtonsBackDrop[13], GetItemArt(Eitem[pid][13]), 0)
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[13], GetItemArt(Eitem[pid][13]), 0)
            endif
        endif
        if StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".E14", "0") != "0" then
            set Eitem[pid][14] =  StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".E14", "0")
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(F_EItemButtonsBackDrop[14], GetItemArt(Eitem[pid][14]), 0)
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[14], GetItemArt(Eitem[pid][14]), 0)
            endif
        endif
        if StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".E15", "0") != "0" then
            set Eitem[pid][15] =  StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".E15", "0")
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(F_EItemButtonsBackDrop[15], GetItemArt(Eitem[pid][15]), 0)
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[15], GetItemArt(Eitem[pid][15]), 0)
            endif
        endif
        
        if GetLocalPlayer() == Player(pid) then
            call DzSyncData("리셋",I2S(pid))
            call DzFrameShow(HPBarBorder,false)
            //call DzFrameShow(MPBarBorder,false)
            call DzFrameShow(HPTextFrame,false)
            //call DzFrameShow(F_InfoOpenButton, true)
            call DzFrameShow(JNGetFrameByName("heroStatusUI",0), true)
            //call DzFrameShow(F_ItemOpenButton, true)
            //call DzFrameShow(FS_OpenButton, true)
        endif
        
        call SkillSetting(MainUnit[pid])

        set HeroSkillPoint[pid] = 999
        call DzFrameSetText(FS_SPTEXTV, I2S(HeroSkillPoint[pid]))
        
        set PickCheck[pid] = true
        call PlayersHPBarShow(Player(pid),true)
        
        //call TodaySet(pid)
        
        call SetMapLine(pid)

        call Deilycheck(pid)
        
        call StashSave(PLAYER_DATA[pid], "슬롯"+ I2S(PlayerSlotNumber[pid]) + ".logins", I2S( S2I(StashLoad(PLAYER_DATA[pid], "슬롯"+ I2S(PlayerSlotNumber[pid]) + ".logins", "0")) + 1 ) )
        
        call upload2(pid)

        set p = null
    endfunction
        
    private function NewPickF takes nothing returns nothing
        local player p=(DzGetTriggerSyncPlayer())
        local string f = DzGetTriggerSyncData()
        local integer pid=GetPlayerId(p)
        local integer SlotHero = S2I(JNStringSplit(f, ";", 0))
        local integer HeroTypeId
        local integer SlotNumber = S2I(JNStringSplit(f, ";", 1))
        
        call StashSave(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber), I2S(SlotHero))
        set PlayerSlotNumber[pid] = SlotNumber
        
        if SlotHero == 1 then
            set HeroTypeId = 'H004'
        elseif SlotHero == 2 then
            set HeroTypeId = 'H003'
        elseif SlotHero == 3 then
            set HeroTypeId = 'H00I'
            if p == GetLocalPlayer() then
                call DzFrameShow(NarAden, true)
                call DzFrameShow(NarAdens[0], false)
                call DzFrameShow(NarAdens[1], false)
                call DzFrameShow(NarAdens[2], false)
                call DzFrameShow(NarAdens[3], false)
                call DzFrameShow(NarAdens[4], false)
                call DzFrameShow(NarAdens[5], false)
                call DzFrameShow(NarAdens2[0], true)
                call DzFrameShow(NarAdens2[1], true)
                call DzFrameShow(NarAdens2[2], true)
                call DzFrameShow(NarAdens2[3], true)
                call DzFrameShow(NarAdens2[4], true)
                call DzFrameShow(NarAdens2[5], true)
            endif
            set NarNabi[pid] = 0
            //call DzFrameShow(skillbuttonframe[8],true)
            //call DzFrameShow(NarAden2, true)
        elseif SlotHero == 4 then
            set HeroTypeId = 'H00K'
            //call DzFrameShow(BanAden, true)
            call DzFrameShow(BanAdens[0], true)
            call DzFrameShow(BanAdens2[0], true)
            call DzFrameShow(BanAdens2[1], true)
            call DzFrameShow(BanAdens2[2], true)
            call DzFrameShow(BanAdens2[3], true)
            call DzFrameShow(BanAdens2[4], true)
            set BanBisul[pid] = 0
            set BanBisul2[pid] = 0
            set BandiForm[pid] = CreateUnit(Player(pid),'e03A',0,0,0)
            //form 반디
            set BandiState[pid] = 1
        endif
        
        set MainUnit[pid] = CreateUnit(Player(pid), HeroTypeId, GetRectCenterX(gg_rct_Home),GetRectCenterY(gg_rct_Home), 0)
        call SelectUnitForPlayerSingle( MainUnit[pid], Player(pid) )
        //카메라
        call SetCameraBoundsToRectForPlayerBJ( p, gg_rct_Home )
        call SetCameraPositionForPlayer(p,GetWidgetX(MainUnit[pid]),GetWidgetY(MainUnit[pid]))
        
        if SlotHero == 1 then
        elseif SlotHero == 2 then
        elseif SlotHero == 3 then
            set NarFormC[pid] = CreateUnit(Player(pid),'e028',0,0,0)
        endif

        if GetItemCharge(StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".포션1", "0")) > 0 then
            set PlayerItem1[pid] = CreateItem('I009',0,0)
            call UnitAddItem(MainUnit[pid],PlayerItem1[pid])
            call SetItemCharges(PlayerItem1[pid], GetItemCharge(StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".포션1", "0")))
        else
            set PlayerItem1[pid] = CreateItem('I00J',0,0)
            call UnitAddItem(MainUnit[pid],PlayerItem1[pid])
            call StashSave(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".포션1", "ID26;중첩수0")
        endif
        if GetItemCharge(StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".포션2", "0")) > 0 then
            set PlayerItem2[pid] = CreateItem('I00C',0,0)
            call UnitAddItem(MainUnit[pid],PlayerItem2[pid])
            call SetItemCharges(PlayerItem1[pid], GetItemCharge(StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".포션2", "0")))
        else
            set PlayerItem2[pid] = CreateItem('I00G',0,0)
            call UnitAddItem(MainUnit[pid],PlayerItem2[pid])
            call StashSave(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".포션2", "ID22;중첩수0")
        endif
        if GetItemCharge(StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".포션3", "0")) > 0 then
            set PlayerItem3[pid] = CreateItem('I00A',0,0)
            call UnitAddItem(MainUnit[pid],PlayerItem3[pid])
            call SetItemCharges(PlayerItem1[pid], GetItemCharge(StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".포션3", "0")))
        else
            set PlayerItem3[pid] = CreateItem('I00I',0,0)
            call UnitAddItem(MainUnit[pid],PlayerItem3[pid])
            call StashSave(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".포션3", "ID25;중첩수0")
        endif
        
        set Eitem[pid][0] = "ID9;"
        /*
        set Eitem[pid][1] = "ID3;"
        set Eitem[pid][2] = "ID4;"
        set Eitem[pid][3] = "ID6;"
        */
        set Eitem[pid][5] = "ID18;"

        set Eitem[pid][6] = "0"
        set Eitem[pid][7] = "0"
        set Eitem[pid][8] = "0"
        set Eitem[pid][9] = "0"
        set Eitem[pid][10] = "0"
        set Eitem[pid][11] = "0"
        set Eitem[pid][12] = "0"
        set Eitem[pid][13] = "0"
        set Eitem[pid][14] = "0"
        set Eitem[pid][15] = "0"

        // 0보조무기, 1상의, 2하의, 3장갑, 4견갑, 5무기, 6목걸이, 7귀걸이, 8반지, 9팔찌, 10카드
        if GetLocalPlayer() == Player(pid) then
            call DzFrameSetText(F_GoldText, StashLoad(PLAYER_DATA[pid], "골드", "0"))
            call DzFrameSetTexture(F_EItemButtonsBackDrop[0], GetItemArt(Eitem[pid][0]), 0)
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[0], GetItemArt(Eitem[pid][0]), 0)
            /*
            call DzFrameSetTexture(F_EItemButtonsBackDrop[1], GetItemArt(Eitem[pid][1]), 0)
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[1], GetItemArt(Eitem[pid][1]), 0)
            call DzFrameSetTexture(F_EItemButtonsBackDrop[2], GetItemArt(Eitem[pid][2]), 0)
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[2], GetItemArt(Eitem[pid][2]), 0)
            call DzFrameSetTexture(F_EItemButtonsBackDrop[3], GetItemArt(Eitem[pid][3]), 0)
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[3], GetItemArt(Eitem[pid][3]), 0)
            */
            //call DzFrameSetTexture(F_EItemButtonsBackDrop[4], GetItemArt(Eitem[pid][4]), 0)
            //call DzFrameSetTexture(F_EEItemButtonsBackDrop[4], GetItemArt(Eitem[pid][4]), 0)
            call DzFrameSetTexture(F_EItemButtonsBackDrop[5], GetItemArt(Eitem[pid][5]), 0)
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[5], GetItemArt(Eitem[pid][5]), 0)
            call DzSyncData("리셋",I2S(pid))
            call DzFrameShow(HPBarBorder,false)
            //call DzFrameShow(MPBarBorder,false)
            call DzFrameShow(HPTextFrame,false)
            //call DzFrameShow(F_InfoOpenButton, true)
            call DzFrameShow(JNGetFrameByName("heroStatusUI",0), true)
            //call DzFrameShow(F_ItemOpenButton, true)
            //call DzFrameShow(FS_OpenButton, true)
        endif
        
        call SkillSetting(MainUnit[pid])

        set HeroSkillPoint[pid] = 999
        call DzFrameSetText(FS_SPTEXTV, I2S(HeroSkillPoint[pid]))
        
        set PickCheck[pid] = true
        call PlayersHPBarShow(Player(pid),true)
        
        //call TodaySet(pid)

        call SetMapLine(pid)

        call Deilycheck(pid)

        call StashSave(PLAYER_DATA[pid], "슬롯"+ I2S(PlayerSlotNumber[pid]) + ".logins", "0")

        call upload2(pid)

        set p = null
    endfunction
    
    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        
        call TriggerRegisterTimerEventSingle( t, 1.0 )
        call TriggerAddAction( t, function Main )
        call DzLoadToc("war3mapimported\\BoxedText.toc")
        
        set t = CreateTrigger()
        call TriggerRegisterTimerEventSingle( t, 5.0 )
        call TriggerAddAction( t, function Main2 )
        
        set t=CreateTrigger()
        call DzTriggerRegisterSyncData(t,("NewPick"),(false))
        call TriggerAddAction(t,function NewPickF)
        
        set t=CreateTrigger()
        call DzTriggerRegisterSyncData(t,("LoadPick"),(false))
        call TriggerAddAction(t,function LoadPickF)
        
        set t = null
    endfunction
endlibrary