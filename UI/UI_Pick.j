library UIPick initializer Init requires UIHP, UISkillLevel, UIItem, Daily, FrameCount, ItemPickUp
    globals
        integer FP_BD               //픽 백드롭
        integer array FP_SL         //세이브 리스트 프레임
        integer array FP_SLB        //세이브 리스트 버튼
        integer array FP_HeroBBD    //버튼백드롭
        integer array FP_HeroIconBD //영웅 아이콘 백드롭
        integer array FP_HeroB      //버튼
        integer FP_SelectBBD        //셀렉결정
        integer FP_SelectB          //셀렉결정버튼
        integer FP_SelectBT         //셀렉결정텍스트
        integer FP_HeroPrevBBD      //영웅 이전 페이지 백드롭
        integer FP_HeroPrevB        //영웅 이전 페이지 버튼
        integer FP_HeroPrevBT       //영웅 이전 페이지 텍스트
        integer FP_HeroNextBBD      //영웅 다음 페이지 백드롭
        integer FP_HeroNextB        //영웅 다음 페이지 버튼
        integer FP_HeroNextBT       //영웅 다음 페이지 텍스트
        integer FP_PreviewPanel     //미리보기 패널
        integer FP_PreviewBG        //미리보기 배경
        integer array FP_PotBD      //포트레잇 백드롭
        integer array FP_LeftPotBD  //왼쪽 캐릭터 이미지
        integer FP_HeroTBD          //캐릭터설명 텍스트 백드롭
        integer array FP_HeroT      //캐릭터설명 텍스트
        integer array PlayerSlotNumber     //플레이어 슬롯넘버
        integer SLNumber = 0        //활성화중인 슬롯넘버
        integer SHNumber = 0        //활성화중인 영웅넘버
        integer FP_LoadBBD          //로드결정
        integer FP_LoadB            //로드결정버튼
        integer FP_LoadBT           //로드결정텍스트
        integer HeroPage = 0
        constant integer HeroPageSize = 6
        integer PickConfirmStep = 0
        integer ConfirmHeroNumber = 0
        constant integer MaxHero = 3
    endglobals

    function StringNullCheck2 takes string s returns boolean
        if s == "" or s == null then
            return true
        endif
        return false
    endfunction

    private function PickWidth takes real px returns real
        return px / 2000.0
    endfunction

    private function PickHeight takes real px returns real
        return px / 1500.0
    endfunction

    private function PickCenterX takes real x, real w returns real
        return (x + (w * 0.5)) / 2000.0
    endfunction

    private function PickCenterY takes real y, real h returns real
        return (900.0 - y - (h * 0.5)) / 1500.0
    endfunction
    private function upload2 takes integer pid returns nothing
        local string str = I2S(PlayerSlotNumber[pid])
        local integer i = 0
        set i = 0
        loop
            if Eitem[pid][i] != null then
                call StashSave(PLAYER_DATA[pid], "슬롯"+ str + ".E"+I2S(i), Eitem[pid][i])
            endif
            exitwhen i == EQUIP_SLOT_MAX
            set i = i + 1
        endloop
        call JNStashNetUploadUser( Player(pid), MapName, GetPlayerName(Player(pid)), MapApi, PLAYER_DATA[pid], UPLOAD_CALLBACK )
    endfunction

    private function ClickLoadButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())

        call DzFrameShow(FP_BD, false)
        call DzSyncData("LoadPick", I2S(SLNumber))
    endfunction


    private function PickCardFrameTexture takes integer heroNumber returns string
        if heroNumber > MaxHero then
            return "war3mapImported\\UI_Pick_Card_Locked.tga"
        elseif heroNumber == SHNumber then
            return "war3mapImported\\UI_Pick_Card_Selected.tga"
        elseif PickConfirmStep == 1 and heroNumber == ConfirmHeroNumber then
            return "war3mapImported\\UI_Pick_Card_Selected.tga"
        endif
        return "war3mapImported\\UI_Pick_Card_Normal.tga"
    endfunction

    private function PickPageFrameTexture takes boolean enabled returns string
        if enabled then
            return "war3mapImported\\UI_Pick_Page_Normal.tga"
        endif
        return "war3mapImported\\UI_Pick_Page_Disabled.tga"
    endfunction

    private function PickButtonFrameTexture takes boolean enabled returns string
        if enabled then
            return "war3mapImported\\UI_Pick_Button_Normal.tga"
        endif
        return "war3mapImported\\UI_Pick_Button_Disabled.tga"
    endfunction

    private function RefreshPickButtons takes nothing returns nothing
        call DzFrameSetTexture(FP_SelectBBD, PickButtonFrameTexture(SHNumber != 0), 0)
        call DzFrameSetTexture(FP_HeroPrevBBD, PickPageFrameTexture(HeroPage > 0), 0)
        call DzFrameSetTexture(FP_HeroNextBBD, PickPageFrameTexture(((HeroPage + 1) * HeroPageSize) < MaxHero), 0)
    endfunction

        private function HideHeroPortraits takes nothing returns nothing
        local integer i = 1
        loop
            exitwhen i > 12
            call DzFrameShow(FP_PotBD[i], false)
            call DzFrameShow(FP_LeftPotBD[i], false)
            set i = i + 1
        endloop
    endfunction

    private function ShowSlotFrames takes boolean flag returns nothing
        call DzFrameShow(FP_SL[1], flag)
        call DzFrameShow(FP_SLB[1], flag)
        call DzFrameShow(FP_SL[2], flag)
        call DzFrameShow(FP_SLB[2], flag)
        call DzFrameShow(FP_SL[3], flag)
        call DzFrameShow(FP_SLB[3], flag)
    endfunction

    private function ResetPickConfirm takes nothing returns nothing
        set ConfirmHeroNumber = 0
        set PickConfirmStep = 0
        call DzFrameSetText(FP_SelectBT, "선택")
    endfunction

        private function RenderHeroCards takes nothing returns nothing
        local integer i = 1
        local integer heroNumber

        loop
            exitwhen i > 12
            if i <= HeroPageSize then
                set heroNumber = HeroPage * HeroPageSize + i
                if heroNumber <= MaxHero then
                    call DzFrameShow(FP_HeroBBD[i], true)
                    call DzFrameShow(FP_HeroB[i], true)
                    call DzFrameSetTexture(FP_HeroBBD[i], PickCardFrameTexture(heroNumber), 0)
                    call DzFrameShow(FP_HeroIconBD[i], true)
                    call DzFrameSetTexture(FP_HeroIconBD[i], "UI_HeroPot"+I2S(heroNumber)+".blp", 0)
                else
                    call DzFrameShow(FP_HeroBBD[i], true)
                    call DzFrameShow(FP_HeroB[i], false)
                    call DzFrameSetTexture(FP_HeroBBD[i], "war3mapImported\\UI_Pick_Card_Locked.tga", 0)
                    call DzFrameShow(FP_HeroIconBD[i], false)
                endif
            else
                call DzFrameShow(FP_HeroBBD[i], false)
                call DzFrameShow(FP_HeroB[i], false)
                call DzFrameShow(FP_HeroIconBD[i], false)
            endif
            set i = i + 1
        endloop

        call DzFrameShow(FP_HeroPrevBBD, MaxHero > HeroPageSize)
        call DzFrameShow(FP_HeroPrevBT, MaxHero > HeroPageSize)
        call DzFrameShow(FP_HeroNextBBD, MaxHero > HeroPageSize)
        call DzFrameShow(FP_HeroNextBT, MaxHero > HeroPageSize)
        call RefreshPickButtons()
    endfunction

    private function ResetHeroListSelection takes nothing returns nothing
        set SHNumber = 0
        call HideHeroPortraits()
        call ResetPickConfirm()
    endfunction

    private function ClickBBDButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local integer i = 1
        local integer heroNumber

        call ResetHeroListSelection()

        loop
            exitwhen i > HeroPageSize
            if f == FP_HeroB[i] then
                set heroNumber = HeroPage * HeroPageSize + i
                if heroNumber <= MaxHero then
                    set SHNumber = heroNumber
                    call DzFrameShow(FP_PotBD[heroNumber], true)
                    call DzFrameShow(FP_LeftPotBD[heroNumber], false)
                    call RenderHeroCards()
                endif
            endif
            set i = i + 1
        endloop
    endfunction

    private function EnterHeroCardButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer i = 1
        local integer heroNumber
        loop
            exitwhen i > HeroPageSize
            if f == FP_HeroB[i] then
                set heroNumber = HeroPage * HeroPageSize + i
                if heroNumber <= MaxHero and heroNumber != SHNumber and heroNumber != ConfirmHeroNumber then
                    call DzFrameSetTexture(FP_HeroBBD[i], "war3mapImported\\UI_Pick_Card_Hover.tga", 0)
                endif
            endif
            set i = i + 1
        endloop
    endfunction

    private function LeaveHeroCardButton takes nothing returns nothing
        call RenderHeroCards()
    endfunction

    private function EnterSelectButton takes nothing returns nothing
        if SHNumber != 0 then
            call DzFrameSetTexture(FP_SelectBBD, "war3mapImported\\UI_Pick_Button_Hover.tga", 0)
        endif
    endfunction

    private function LeaveSelectButton takes nothing returns nothing
        call RefreshPickButtons()
    endfunction

    private function EnterLoadButton takes nothing returns nothing
        call DzFrameSetTexture(FP_LoadBBD, "war3mapImported\\UI_Pick_Button_Hover.tga", 0)
    endfunction

    private function LeaveLoadButton takes nothing returns nothing
        call DzFrameSetTexture(FP_LoadBBD, "war3mapImported\\UI_Pick_Button_Normal.tga", 0)
    endfunction

    private function EnterHeroPrevButton takes nothing returns nothing
        if HeroPage > 0 then
            call DzFrameSetTexture(FP_HeroPrevBBD, "war3mapImported\\UI_Pick_Page_Normal.tga", 0)
        endif
    endfunction

    private function LeaveHeroPrevButton takes nothing returns nothing
        call RefreshPickButtons()
    endfunction

    private function EnterHeroNextButton takes nothing returns nothing
        if ((HeroPage + 1) * HeroPageSize) < MaxHero then
            call DzFrameSetTexture(FP_HeroNextBBD, "war3mapImported\\UI_Pick_Page_Normal.tga", 0)
        endif
    endfunction

    private function LeaveHeroNextButton takes nothing returns nothing
        call RefreshPickButtons()
    endfunction

    private function ClickPickHeroButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())

        if SHNumber != 0 then
            if PickConfirmStep == 0 then
                set ConfirmHeroNumber = SHNumber
                set PickConfirmStep = 1
                call DzFrameSetText(FP_SelectBT, "확인")
                call RenderHeroCards()
            elseif ConfirmHeroNumber == SHNumber then
                call DzFrameShow(FP_BD, false)
                call DzSyncData("NewPick", I2S(ConfirmHeroNumber) + ";" + I2S(SLNumber))
            else
                call ResetPickConfirm()
            endif
        endif
    endfunction

    private function ClickHeroPrevButton takes nothing returns nothing
        if HeroPage > 0 then
            set HeroPage = HeroPage - 1
            call ResetHeroListSelection()
            call RenderHeroCards()
        endif
    endfunction

    private function ClickHeroNextButton takes nothing returns nothing
        if ((HeroPage + 1) * HeroPageSize) < MaxHero then
            set HeroPage = HeroPage + 1
            call ResetHeroListSelection()
            call RenderHeroCards()
        endif
    endfunction

    private function ClickSLButton1 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        if f == FP_SLB[1] then
            if StashLoad(PLAYER_DATA[pid], "슬롯1", null) == null then
                call DzFrameSetTexture(FP_SL[1], "war3mapImported\\UI_Pick_Button_Hover.tga", 0)
            else
                call DzFrameSetTexture(FP_SL[1], "UI_PickSelect1Hero"+ StashLoad(PLAYER_DATA[pid], "슬롯1", null) +".blp", 0)
            endif
        endif
        if f == FP_SLB[2] then
            if StashLoad(PLAYER_DATA[pid], "슬롯2", null) == null then
                call DzFrameSetTexture(FP_SL[2], "war3mapImported\\UI_Pick_Button_Hover.tga", 0)
            else
                call DzFrameSetTexture(FP_SL[2], "UI_PickSelect1Hero"+ StashLoad(PLAYER_DATA[pid], "슬롯2", null) +".blp", 0)
            endif
        endif
        if f == FP_SLB[3] then
            if StashLoad(PLAYER_DATA[pid], "슬롯3", null) == null then
                call DzFrameSetTexture(FP_SL[3], "war3mapImported\\UI_Pick_Button_Hover.tga", 0)
            else
                call DzFrameSetTexture(FP_SL[3], "UI_PickSelect1Hero"+ StashLoad(PLAYER_DATA[pid], "슬롯3", null) +".blp", 0)
            endif
        endif
        /*
        if f == FP_SLB[4] then
            if StashLoad(PLAYER_DATA[pid], "슬롯4", null) == null then
                call DzFrameSetTexture(FP_SL[4], "war3mapImported\\UI_Pick_Button_Hover.tga", 0)
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
                call DzFrameSetTexture(FP_SL[1], "war3mapImported\\UI_Pick_Button_Normal.tga", 0)
            else
                call DzFrameSetTexture(FP_SL[1], "UI_PickSelect1Hero"+ StashLoad(PLAYER_DATA[pid], "슬롯1", null) +".blp", 0)
            endif
        endif
        if f == FP_SLB[2] then
            if StashLoad(PLAYER_DATA[pid], "슬롯2", null) == null then
                call DzFrameSetTexture(FP_SL[2], "war3mapImported\\UI_Pick_Button_Normal.tga", 0)
            else
                call DzFrameSetTexture(FP_SL[2], "UI_PickSelect1Hero"+ StashLoad(PLAYER_DATA[pid], "슬롯2", null) +".blp", 0)
            endif

        endif
        if f == FP_SLB[3] then
            if StashLoad(PLAYER_DATA[pid], "슬롯3", null) == null then
                call DzFrameSetTexture(FP_SL[3], "war3mapImported\\UI_Pick_Button_Normal.tga", 0)
            else
                call DzFrameSetTexture(FP_SL[3], "UI_PickSelect1Hero"+ StashLoad(PLAYER_DATA[pid], "슬롯3", null) +".blp", 0)
            endif
        endif
        /*
        if f == FP_SLB[4] then
            if StashLoad(PLAYER_DATA[pid], "슬롯4", null) == null then
                call DzFrameSetTexture(FP_SL[4], "war3mapImported\\UI_Pick_Button_Normal.tga", 0)
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
                call DzFrameShow(FP_PreviewPanel, true)
                call ShowSlotFrames(false)
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
                set HeroPage = 0
                call ResetPickConfirm()
                call RenderHeroCards()
            else
                set SLNumber = 1
                call DzFrameShow(FP_HeroBBD[0], false)
                call DzFrameShow(FP_PreviewPanel, false)
                call DzFrameShow(FP_LoadBBD, true)
            endif
        endif
        if f == FP_SLB[2] then
            if StashLoad(PLAYER_DATA[pid], "슬롯2", null) == null then
                call DzFrameShow(FP_HeroBBD[0], true)
                call DzFrameShow(FP_PreviewPanel, true)
                call ShowSlotFrames(false)
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
                set HeroPage = 0
                call ResetPickConfirm()
                call RenderHeroCards()
            else
                set SLNumber = 2
                call DzFrameShow(FP_HeroBBD[0], false)
                call DzFrameShow(FP_PreviewPanel, false)
                call DzFrameShow(FP_LoadBBD, true)
            endif
        endif
        if f == FP_SLB[3] then
            if StashLoad(PLAYER_DATA[pid], "슬롯3", null) == null then
                call DzFrameShow(FP_HeroBBD[0], true)
                call DzFrameShow(FP_PreviewPanel, true)
                call ShowSlotFrames(false)
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
                set HeroPage = 0
                call ResetPickConfirm()
                call RenderHeroCards()
            else
                set SLNumber = 3
                call DzFrameShow(FP_HeroBBD[0], false)
                call DzFrameShow(FP_PreviewPanel, false)
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
                set HeroPage = 0
                call ResetPickConfirm()
                call RenderHeroCards()
            else
                set SLNumber = 4
                call DzFrameShow(FP_SelectBBD, false)
                call DzFrameShow(FP_LoadBBD, true)
            endif
        endif
        */
    endfunction

    private function OpenHeroSelection takes integer slotNumber returns nothing
        set SLNumber = slotNumber
        set SHNumber = 0
        set HeroPage = 0
        call ResetPickConfirm()
        call HideHeroPortraits()
        call ShowSlotFrames(false)
        call DzFrameShow(FP_LoadBBD, false)
        call DzFrameShow(FP_HeroBBD[0], true)
        call DzFrameShow(FP_PreviewPanel, true)
        call RenderHeroCards()
    endfunction

    private function Main2 takes nothing returns nothing
        if true then
            call OpenHeroSelection(1)
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
        local real cardX
        local real cardY

        //카메라
        call SetCameraBoundsToRectForPlayerBJ( GetLocalPlayer(), gg_rct_Pick )
        call SetCameraPositionForPlayer(GetLocalPlayer(),GetRectCenterX(gg_rct_Pick),GetRectCenterY(gg_rct_Pick))

        call DzLoadToc("war3mapImported\\Templates.toc")

        set FP_BD=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "template", FrameCount())
        call DzFrameSetTexture(FP_BD, "war3mapImported\\UI_Pick_Main_Ref.tga", 0)
        call DzFrameSetSize(FP_BD, PickWidth(1460.0), PickHeight(760.0))
        call DzFrameSetAbsolutePoint(FP_BD, JN_FRAMEPOINT_CENTER, PickCenterX(70.0, 1460.0), PickCenterY(60.0, 760.0))
        call DzFrameShow(FP_BD, false)

        set FP_SL[1]=DzCreateFrameByTagName("BACKDROP", "", FP_BD, "template", FrameCount())
        call DzFrameSetTexture(FP_SL[1], "war3mapImported\\UI_Pick_Button_Normal.tga", 0)
        call DzFrameSetSize(FP_SL[1], 0.160, 0.040)
        call DzFrameSetAbsolutePoint(FP_SL[1], JN_FRAMEPOINT_CENTER, 0.2750, 0.4050)
        set FP_SLB[1] = DzCreateFrameByTagName("BUTTON", "", FP_BD, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetAbsolutePoint(FP_SLB[1], JN_FRAMEPOINT_CENTER, 0.2750, 0.4050)
        call DzFrameSetSize(FP_SLB[1], 0.160, 0.040)
        call DzFrameSetScriptByCode(FP_SLB[1], JN_FRAMEEVENT_MOUSE_ENTER, function ClickSLButton1, false)
        call DzFrameSetScriptByCode(FP_SLB[1], JN_FRAMEEVENT_MOUSE_LEAVE, function ClickSLButton2, false)
        call DzFrameSetScriptByCode(FP_SLB[1], JN_FRAMEEVENT_MOUSE_UP, function ClickSLButton3, false)

        set FP_SL[2]=DzCreateFrameByTagName("BACKDROP", "", FP_BD, "template", FrameCount())
        call DzFrameSetTexture(FP_SL[2], "war3mapImported\\UI_Pick_Button_Normal.tga", 0)
        call DzFrameSetSize(FP_SL[2], 0.160, 0.040)
        call DzFrameSetAbsolutePoint(FP_SL[2], JN_FRAMEPOINT_CENTER, 0.2750, 0.3450)
        set FP_SLB[2] = DzCreateFrameByTagName("BUTTON", "", FP_BD, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetAbsolutePoint(FP_SLB[2], JN_FRAMEPOINT_CENTER, 0.2750, 0.3450)
        call DzFrameSetSize(FP_SLB[2], 0.160, 0.040)
        call DzFrameSetScriptByCode(FP_SLB[2], JN_FRAMEEVENT_MOUSE_ENTER, function ClickSLButton1, false)
        call DzFrameSetScriptByCode(FP_SLB[2], JN_FRAMEEVENT_MOUSE_LEAVE, function ClickSLButton2, false)
        call DzFrameSetScriptByCode(FP_SLB[2], JN_FRAMEEVENT_MOUSE_UP, function ClickSLButton3, false)

        set FP_SL[3]=DzCreateFrameByTagName("BACKDROP", "", FP_BD, "template", FrameCount())
        call DzFrameSetTexture(FP_SL[3], "war3mapImported\\UI_Pick_Button_Normal.tga", 0)
        call DzFrameSetSize(FP_SL[3], 0.160, 0.040)
        call DzFrameSetAbsolutePoint(FP_SL[3], JN_FRAMEPOINT_CENTER, 0.2750, 0.2850)
        set FP_SLB[3] = DzCreateFrameByTagName("BUTTON", "", FP_BD, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetAbsolutePoint(FP_SLB[3], JN_FRAMEPOINT_CENTER, 0.2750, 0.2850)
        call DzFrameSetSize(FP_SLB[3], 0.160, 0.040)
        call DzFrameSetScriptByCode(FP_SLB[3], JN_FRAMEEVENT_MOUSE_ENTER, function ClickSLButton1, false)
        call DzFrameSetScriptByCode(FP_SLB[3], JN_FRAMEEVENT_MOUSE_LEAVE, function ClickSLButton2, false)
        call DzFrameSetScriptByCode(FP_SLB[3], JN_FRAMEEVENT_MOUSE_UP, function ClickSLButton3, false)

        /*
        set FP_SLB[4] = DzCreateFrameByTagName("BUTTON", "", FP_BD, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetAbsolutePoint(FP_SLB[4], JN_FRAMEPOINT_CENTER, 0.1750, 0.2150)
        call DzFrameSetSize(FP_SLB[4], 0.16, 0.055)
        call DzFrameSetScriptByCode(FP_SLB[4], JN_FRAMEEVENT_MOUSE_ENTER, function ClickSLButton1, false)
        call DzFrameSetScriptByCode(FP_SLB[4], JN_FRAMEEVENT_MOUSE_LEAVE, function ClickSLButton2, false)
        call DzFrameSetScriptByCode(FP_SLB[4], JN_FRAMEEVENT_MOUSE_UP, function ClickSLButton3, false)
        set FP_SL[4]=DzCreateFrameByTagName("BACKDROP", "", FP_BD, "template", FrameCount())
        call DzFrameSetTexture(FP_SL[4], "war3mapImported\\UI_Pick_Button_Normal.tga", 0)
        call DzFrameSetSize(FP_SL[4], 0.16, 0.055)
        call DzFrameSetAbsolutePoint(FP_SL[4], JN_FRAMEPOINT_CENTER, 0.1750, 0.2150)
        */

        set FP_PreviewPanel=DzCreateFrameByTagName("BACKDROP", "", FP_BD, "template", FrameCount())
        call DzFrameSetTexture(FP_PreviewPanel, "war3mapImported\\UI_Pick_Preview_Panel.tga", 0)
        call DzFrameSetSize(FP_PreviewPanel, PickWidth(390.0), PickHeight(675.0))
        call DzFrameSetAbsolutePoint(FP_PreviewPanel, JN_FRAMEPOINT_CENTER, PickCenterX(1100.0, 390.0), PickCenterY(105.0, 675.0))

        set FP_PreviewBG=DzCreateFrameByTagName("BACKDROP", "", FP_PreviewPanel, "template", FrameCount())
        call DzFrameSetTexture(FP_PreviewBG, "war3mapImported\\UI_Pick_Preview_BG.tga", 0)
        call DzFrameSetSize(FP_PreviewBG, PickWidth(330.0), PickHeight(520.0))
        call DzFrameSetAbsolutePoint(FP_PreviewBG, JN_FRAMEPOINT_CENTER, PickCenterX(1130.0, 330.0), PickCenterY(155.0, 520.0))
        call DzFrameShow(FP_PreviewPanel, false)
        set FP_HeroBBD[0]=DzCreateFrameByTagName("BACKDROP", "", FP_BD, "", FrameCount())

        set j = 0
        loop
            set i = 1
            loop
                set k = i+(j*6)
                set cardX = PickCenterX(160.0 + (285.0 * I2R(ModuloInteger(k - 1, 3))), 240.0)
                set cardY = PickCenterY(170.0 + (305.0 * I2R((k - 1) / 3)), 240.0)
                set FP_HeroBBD[k]=DzCreateFrameByTagName("BACKDROP", "", FP_HeroBBD[0], "", FrameCount())
                call DzFrameSetAbsolutePoint(FP_HeroBBD[k], JN_FRAMEPOINT_CENTER, cardX, cardY)
                call DzFrameSetSize(FP_HeroBBD[k], PickWidth(240.0), PickHeight(240.0))
                call DzFrameSetTexture(FP_HeroBBD[k], "war3mapImported\\UI_Pick_Card_Normal.tga", 0)
                set FP_HeroIconBD[k]=DzCreateFrameByTagName("BACKDROP", "", FP_HeroBBD[k], "template", FrameCount())
                call DzFrameSetTexture(FP_HeroIconBD[k], "ReplaceableTextures\\CommandButtons\\BTNHeroIcon0.blp", 0)
                call DzFrameSetSize(FP_HeroIconBD[k], PickWidth(190.0), PickHeight(190.0))
                call DzFrameSetAbsolutePoint(FP_HeroIconBD[k], JN_FRAMEPOINT_CENTER, cardX, cardY)
                set FP_HeroB[k]=DzCreateFrameByTagName("BUTTON", "", FP_HeroBBD[k], "ScoreScreenTabButtonTemplate",  FrameCount())
                call DzFrameSetAllPoints(FP_HeroB[k], FP_HeroBBD[k])
                call DzFrameSetSize(FP_HeroB[k], PickWidth(240.0), PickHeight(240.0))
                call DzFrameSetScriptByCode(FP_HeroB[k], JN_FRAMEEVENT_MOUSE_ENTER, function EnterHeroCardButton, false)
                call DzFrameSetScriptByCode(FP_HeroB[k], JN_FRAMEEVENT_MOUSE_LEAVE, function LeaveHeroCardButton, false)
                call DzFrameSetScriptByCode(FP_HeroB[k], JN_FRAMEEVENT_MOUSE_UP, function ClickBBDButton, false)
                if k <= MaxHero then
                    set FP_PotBD[k]=DzCreateFrameByTagName("BACKDROP", "", FP_PreviewBG, "template", FrameCount())
                    call DzFrameSetTexture(FP_PotBD[k], "UI_HeroPot"+I2S(k)+".blp", 0)
                    call DzFrameSetSize(FP_PotBD[k], PickWidth(300.0), PickHeight(480.0))
                    call DzFrameSetAbsolutePoint(FP_PotBD[k], JN_FRAMEPOINT_CENTER, PickCenterX(1130.0, 300.0), PickCenterY(155.0, 480.0))
                    call DzFrameShow(FP_PotBD[k], false)
                    set FP_LeftPotBD[k]=DzCreateFrameByTagName("BACKDROP", "", FP_BD, "template", FrameCount())
                    call DzFrameSetTexture(FP_LeftPotBD[k], "UI_HeroPot"+I2S(k)+".blp", 0)
                    call DzFrameSetSize(FP_LeftPotBD[k], 0.110, 0.225)
                    call DzFrameSetAbsolutePoint(FP_LeftPotBD[k], JN_FRAMEPOINT_CENTER, 0.1260, 0.3800)
                    call DzFrameShow(FP_LeftPotBD[k], false)
                endif
                set i = i + 1
                exitwhen i == 7
            endloop
            set j = j + 1
            exitwhen j == 2
        endloop

        set FP_HeroPrevBBD=DzCreateFrameByTagName("BACKDROP", "", FP_HeroBBD[0], "template", FrameCount())
        call DzFrameSetTexture(FP_HeroPrevBBD, "war3mapImported\\UI_Pick_Page_Disabled.tga", 0)
        call DzFrameSetSize(FP_HeroPrevBBD, PickWidth(30.0), PickHeight(72.0))
        call DzFrameSetAbsolutePoint(FP_HeroPrevBBD, JN_FRAMEPOINT_CENTER, PickCenterX(1035.0, 30.0), PickCenterY(255.0, 72.0))
        set FP_HeroPrevBT=DzCreateFrameByTagName("TEXT", "", FP_HeroPrevBBD, "", 0)
        call DzFrameSetAbsolutePoint(FP_HeroPrevBT, JN_FRAMEPOINT_CENTER, PickCenterX(1035.0, 30.0), PickCenterY(255.0, 72.0))
        call DzFrameSetText(FP_HeroPrevBT, "<")
        set FP_HeroPrevB=DzCreateFrameByTagName("BUTTON", "", FP_HeroPrevBBD, "ScoreScreenTabButtonTemplate", FrameCount())
        call DzFrameSetAllPoints(FP_HeroPrevB, FP_HeroPrevBBD)
        call DzFrameSetScriptByCode(FP_HeroPrevB, JN_FRAMEEVENT_MOUSE_ENTER, function EnterHeroPrevButton, false)
        call DzFrameSetScriptByCode(FP_HeroPrevB, JN_FRAMEEVENT_MOUSE_LEAVE, function LeaveHeroPrevButton, false)
        call DzFrameSetScriptByCode(FP_HeroPrevB, JN_FRAMEEVENT_MOUSE_UP, function ClickHeroPrevButton, false)

        set FP_HeroNextBBD=DzCreateFrameByTagName("BACKDROP", "", FP_HeroBBD[0], "template", FrameCount())
        call DzFrameSetTexture(FP_HeroNextBBD, "war3mapImported\\UI_Pick_Page_Disabled.tga", 0)
        call DzFrameSetSize(FP_HeroNextBBD, PickWidth(30.0), PickHeight(72.0))
        call DzFrameSetAbsolutePoint(FP_HeroNextBBD, JN_FRAMEPOINT_CENTER, PickCenterX(1035.0, 30.0), PickCenterY(490.0, 72.0))
        set FP_HeroNextBT=DzCreateFrameByTagName("TEXT", "", FP_HeroNextBBD, "", 0)
        call DzFrameSetAbsolutePoint(FP_HeroNextBT, JN_FRAMEPOINT_CENTER, PickCenterX(1035.0, 30.0), PickCenterY(490.0, 72.0))
        call DzFrameSetText(FP_HeroNextBT, ">")
        set FP_HeroNextB=DzCreateFrameByTagName("BUTTON", "", FP_HeroNextBBD, "ScoreScreenTabButtonTemplate", FrameCount())
        call DzFrameSetAllPoints(FP_HeroNextB, FP_HeroNextBBD)
        call DzFrameSetScriptByCode(FP_HeroNextB, JN_FRAMEEVENT_MOUSE_ENTER, function EnterHeroNextButton, false)
        call DzFrameSetScriptByCode(FP_HeroNextB, JN_FRAMEEVENT_MOUSE_LEAVE, function LeaveHeroNextButton, false)
        call DzFrameSetScriptByCode(FP_HeroNextB, JN_FRAMEEVENT_MOUSE_UP, function ClickHeroNextButton, false)


        /*
        set FP_HeroTBD=DzCreateFrameByTagName("BACKDROP", "", FP_SelectBBD, "template", FrameCount())
        call DzFrameSetTexture(FP_HeroTBD, "UI_PickText.tga", 0)
        call DzFrameSetSize(FP_HeroTBD, 0.22, 0.12)
        call DzFrameSetAbsolutePoint(FP_HeroTBD, JN_FRAMEPOINT_CENTER, 0.5700, 0.2100)
        call DzFrameShow(FP_HeroTBD, true)
        */

        set FP_SelectBBD=DzCreateFrameByTagName("BACKDROP", "", FP_HeroBBD[0], "template", FrameCount())
        call DzFrameSetTexture(FP_SelectBBD, "war3mapImported\\UI_Pick_Button_Disabled.tga", 0)
        call DzFrameSetSize(FP_SelectBBD, PickWidth(170.0), PickHeight(46.0))
        call DzFrameSetAbsolutePoint(FP_SelectBBD, JN_FRAMEPOINT_CENTER, PickCenterX(1210.0, 170.0), PickCenterY(635.0, 46.0))

        set FP_SelectBT=DzCreateFrameByTagName("TEXT","",FP_SelectBBD,"",0)
        call DzFrameSetAbsolutePoint(FP_SelectBT, JN_FRAMEPOINT_CENTER, PickCenterX(1210.0, 170.0), PickCenterY(635.0, 46.0))
        call DzFrameSetText(FP_SelectBT,"선택")
        call DzFrameSetEnable(FP_SelectBT, false)

        set FP_SelectB=DzCreateFrameByTagName("BUTTON", "", FP_SelectBBD, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetAbsolutePoint(FP_SelectB, JN_FRAMEPOINT_CENTER, PickCenterX(1210.0, 170.0), PickCenterY(635.0, 46.0))
        call DzFrameSetSize(FP_SelectB, PickWidth(170.0), PickHeight(46.0))
        call DzFrameSetScriptByCode(FP_SelectB, JN_FRAMEEVENT_MOUSE_ENTER, function EnterSelectButton, false)
        call DzFrameSetScriptByCode(FP_SelectB, JN_FRAMEEVENT_MOUSE_LEAVE, function LeaveSelectButton, false)
        call DzFrameSetScriptByCode(FP_SelectB, JN_FRAMEEVENT_MOUSE_UP, function ClickPickHeroButton, false)

        call DzFrameShow(FP_HeroBBD[0], false)

        //로드
        set FP_LoadBBD=DzCreateFrameByTagName("BACKDROP", "", FP_BD, "template", FrameCount())
        call DzFrameSetTexture(FP_LoadBBD, "war3mapImported\\UI_Pick_Button_Normal.tga", 0)
        call DzFrameSetSize(FP_LoadBBD, PickWidth(170.0), PickHeight(46.0))
        call DzFrameSetAbsolutePoint(FP_LoadBBD, JN_FRAMEPOINT_CENTER, PickCenterX(1210.0, 170.0), PickCenterY(635.0, 46.0))
        call DzFrameShow(FP_LoadBBD, false)

        set FP_LoadBT=DzCreateFrameByTagName("TEXT","",FP_LoadBBD,"",0)
        call DzFrameSetAbsolutePoint(FP_LoadBT, JN_FRAMEPOINT_CENTER, PickCenterX(1210.0, 170.0), PickCenterY(635.0, 46.0))
        call DzFrameSetText(FP_LoadBT,"결정")
        call DzFrameSetEnable(FP_LoadBT, false)

        set FP_LoadB=DzCreateFrameByTagName("BUTTON", "", FP_LoadBBD, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetAbsolutePoint(FP_LoadB, JN_FRAMEPOINT_CENTER, PickCenterX(1210.0, 170.0), PickCenterY(635.0, 46.0))
        call DzFrameSetSize(FP_LoadB, PickWidth(170.0), PickHeight(46.0))
        call DzFrameSetScriptByCode(FP_LoadB, JN_FRAMEEVENT_MOUSE_ENTER, function EnterLoadButton, false)
        call DzFrameSetScriptByCode(FP_LoadB, JN_FRAMEEVENT_MOUSE_LEAVE, function LeaveLoadButton, false)
        call DzFrameSetScriptByCode(FP_LoadB, JN_FRAMEEVENT_MOUSE_UP, function ClickLoadButton, false)
        call RenderHeroCards()

    endfunction

    private function LoadPickF takes nothing returns nothing
        local player p=(DzGetTriggerSyncPlayer())
        local integer SlotNumber = S2I(DzGetTriggerSyncData())
        local integer pid=GetPlayerId(p)
        local integer HeroTypeId
        local integer i = 0
        local integer j = 0
        local string str = null

        set PlayerSlotNumber[pid] = SlotNumber

        if StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber), null) == "1" then
            set HeroTypeId = 'H004'
        elseif StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber), null) == "2" then
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
        elseif StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber), null) == "3" then
            set HeroTypeId = 'H00K'
            if p == GetLocalPlayer() then
                call DzFrameShow(BanAdens[0], true)
                call DzFrameShow(BanAdens2[0], true)
                call DzFrameShow(BanAdens2[1], true)
                call DzFrameShow(BanAdens2[2], true)
                call DzFrameShow(BanAdens2[3], true)
                call DzFrameShow(BanAdens2[4], true)
            endif
            set BanBisul[pid] = 0
            set BanBisul2[pid] = 0
            set BandiForm[pid] = CreateUnit(Player(pid),'e03A',0,0,0)
            set BandiState[pid] = 1
        endif

        set MainUnit[pid] = CreateUnit(Player(pid), HeroTypeId, GetRectCenterX(gg_rct_Home),GetRectCenterY(gg_rct_Home), 0)
        call ShowPlayerPotionDisplay(pid)


        if StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber), null) == "1" then

        elseif StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber), null) == "2" then
            set NarFormG[pid] = CreateUnit(Player(pid),'e027',0,0,0)
        endif

        call SelectUnitForPlayerSingle( MainUnit[pid], Player(pid) )
        //카메라
        call SetCameraBoundsToRectForPlayerBJ( p, gg_rct_Home )
        call SetCameraPositionForPlayer(p,GetWidgetX(MainUnit[pid]),GetWidgetY(MainUnit[pid]))


        set i = 0
        loop
            set Eitem[pid][i] = StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".E"+I2S(i), "0")
            exitwhen i == EQUIP_SLOT_MAX
            set i = i + 1
        endloop
        set j = 0
        loop
            set str = StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".아이템"+I2S(j), "없음")
            if str != "없음" and str != null then
                call AddIvItem(pid, j, str)
                set str = null
            endif
            set j = j + 1
        exitwhen j == 50
        endloop

        loop
            set str = StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber)+".아이템"+I2S(j), "없음")
            if str != "없음" and str != null then
                call AddIvItem(pid, j, str)
                set str = null
            endif
            set j = j + 1
        exitwhen j == 100
        endloop
        if GetLocalPlayer() == Player(pid) then
            call DzFrameSetText(F_GoldText, StashLoad(PLAYER_DATA[pid], "골드", "0"))
            set i = 0
            loop
                if Eitem[pid][i] != "" and Eitem[pid][i] != "0" then
                    call DzFrameSetTexture(F_EItemButtonsBackDrop[i], GetItemArt(Eitem[pid][i]), 0)
                    if i <= EQUIP_SLOT_WEAPON then
                        call DzFrameSetTexture(F_EEItemButtonsBackDrop[i], GetItemArt(Eitem[pid][i]), 0)
                    endif
                endif
                exitwhen i == EQUIP_SLOT_MAX
                set i = i + 1
            endloop
            if GetItemIDs(Eitem[pid][EQUIP_SLOT_NECKLACE]) != 0 then
                call DzFrameSetTexture(F_ArcanaButtonsBackDrop[0], GetItemArt(Eitem[pid][EQUIP_SLOT_NECKLACE]), 0)
            endif
            if GetItemIDs(Eitem[pid][EQUIP_SLOT_EARRING_1]) != 0 then
                call DzFrameSetTexture(F_ArcanaButtonsBackDrop[1], GetItemArt(Eitem[pid][EQUIP_SLOT_EARRING_1]), 0)
            endif
            if GetItemIDs(Eitem[pid][EQUIP_SLOT_EARRING_2]) != 0 then
                call DzFrameSetTexture(F_ArcanaButtonsBackDrop[2], GetItemArt(Eitem[pid][EQUIP_SLOT_EARRING_2]), 0)
            endif
            if GetItemIDs(Eitem[pid][EQUIP_SLOT_RING_1]) != 0 then
                call DzFrameSetTexture(F_ArcanaButtonsBackDrop[3], GetItemArt(Eitem[pid][EQUIP_SLOT_RING_1]), 0)
            endif
            if GetItemIDs(Eitem[pid][EQUIP_SLOT_RING_2]) != 0 then
                call DzFrameSetTexture(F_ArcanaButtonsBackDrop[4], GetItemArt(Eitem[pid][EQUIP_SLOT_RING_2]), 0)
            endif
            if GetItemIDs(Eitem[pid][EQUIP_SLOT_CARD]) != 0 then
                call DzFrameSetTexture(F_ArcanaButtonsBackDrop[5], GetItemArt(Eitem[pid][EQUIP_SLOT_CARD]), 0)
            endif
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
        local integer i = 0

        call StashSave(PLAYER_DATA[pid], "슬롯"+I2S(SlotNumber), I2S(SlotHero))
        set PlayerSlotNumber[pid] = SlotNumber

        if SlotHero == 1 then
            set HeroTypeId = 'H004'
        elseif SlotHero == 2 then
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
        elseif SlotHero == 3 then
            set HeroTypeId = 'H00K'
            if p == GetLocalPlayer() then
                call DzFrameShow(BanAdens[0], true)
                call DzFrameShow(BanAdens2[0], true)
                call DzFrameShow(BanAdens2[1], true)
                call DzFrameShow(BanAdens2[2], true)
                call DzFrameShow(BanAdens2[3], true)
                call DzFrameShow(BanAdens2[4], true)
            endif
            set BanBisul[pid] = 0
            set BanBisul2[pid] = 0
            set BandiForm[pid] = CreateUnit(Player(pid),'e03A',0,0,0)
            set BandiState[pid] = 1
        endif

        set MainUnit[pid] = CreateUnit(Player(pid), HeroTypeId, GetRectCenterX(gg_rct_Home),GetRectCenterY(gg_rct_Home), 0)
        call ShowPlayerPotionDisplay(pid)
        call SelectUnitForPlayerSingle( MainUnit[pid], Player(pid) )
        //카메라
        call SetCameraBoundsToRectForPlayerBJ( p, gg_rct_Home )
        call SetCameraPositionForPlayer(p,GetWidgetX(MainUnit[pid]),GetWidgetY(MainUnit[pid]))

        if SlotHero == 1 then
        elseif SlotHero == 2 then
            set NarFormC[pid] = CreateUnit(Player(pid),'e028',0,0,0)
        endif


        set i = 0
        loop
            set Eitem[pid][i] = "0"
            exitwhen i == EQUIP_SLOT_MAX
            set i = i + 1
        endloop
        set Eitem[pid][EQUIP_SLOT_WEAPON] = "ID18;"

        // 장착 슬롯: 0엘릭서, 1무기, 2목걸이, 3귀걸이1, 4귀걸이2, 5반지1, 6반지2, 7팔찌, 8카드
        if GetLocalPlayer() == Player(pid) then
            call DzFrameSetText(F_GoldText, StashLoad(PLAYER_DATA[pid], "골드", "0"))
            call DzFrameSetTexture(F_EItemButtonsBackDrop[EQUIP_SLOT_WEAPON], GetItemArt(Eitem[pid][EQUIP_SLOT_WEAPON]), 0)
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[EQUIP_SLOT_WEAPON], GetItemArt(Eitem[pid][EQUIP_SLOT_WEAPON]), 0)
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
        ///*
        set t = CreateTrigger()
        call TriggerRegisterTimerEventSingle( t, 5.0 )
        call TriggerAddAction( t, function Main2 )
        //*/
        set t=CreateTrigger()
        call DzTriggerRegisterSyncData(t,("NewPick"),(false))
        call TriggerAddAction(t,function NewPickF)

        set t=CreateTrigger()
        call DzTriggerRegisterSyncData(t,("LoadPick"),(false))
        call TriggerAddAction(t,function LoadPickF)

        set t = null
    endfunction
endlibrary
