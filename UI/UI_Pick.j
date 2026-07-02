//1
library UIPick initializer Init requires UIHP, UISkillLevel, UIItem, Daily, FrameCount, ItemPickUp
    globals
        integer FP_BD               //픽 백드롭
        integer array FP_SL         //세이브 리스트 프레임
        integer array FP_SLB        //세이브 리스트 버튼
        integer array FP_HeroBBD    //버튼백드롭
        integer array FP_HeroImgBD  //캐릭터 이미지
        integer array FP_HeroNameBD //캐릭터 이름 배경
        integer array FP_HeroLockBD //캐릭터 잠금 표시
        integer array FP_HeroB      //버튼
        integer FP_SelectBBD        //셀렉결정
        integer FP_SelectB          //셀렉결정버튼
        integer FP_SelectBT         //셀렉결정텍스트
        integer FP_PreviewPanel     //선택 캐릭터 미리보기 패널
        integer FP_SkinBBD          //스킨 선택 배경
        integer FP_SkinB            //스킨 선택 버튼
        integer FP_SkinBT           //스킨 선택 텍스트
        integer FP_ScrollTrack      //캐릭터 목록 스크롤 트랙
        integer FP_ScrollKnob       //캐릭터 목록 스크롤 노브
        integer FP_ScrollB          //캐릭터 목록 스크롤 버튼
        integer array FP_PotBD      //포트레잇 백드롭
        integer FP_HeroTBD          //캐릭터설명 텍스트 백드롭
        integer array FP_HeroT      //캐릭터설명 텍스트
        integer array PlayerSlotNumber     //플레이어 슬롯넘버
        integer SLNumber = 0        //활성화중인 슬롯넘버
        integer SHNumber = 0        //활성화중인 영웅넘버
        integer FP_LoadBBD          //로드결정
        integer FP_LoadB            //로드결정버튼
        integer FP_LoadBT           //로드결정텍스트
        integer PickScrollOffset = 0
        constant integer MaxHero = 3
        constant integer PickVisibleCardCount = 12
        constant integer PickCardColumnCount = 4
        constant integer PickCardCount = 16
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

    private function PickHeroName takes integer heroNumber returns string
        if heroNumber == 1 then
            return "루시아"
        elseif heroNumber == 2 then
            return "나루메아"
        elseif heroNumber == 3 then
            return "반디"
        endif
        return "잠금"
    endfunction

    private function PickSlotValue takes integer pid, integer slotNumber returns string
        return StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(slotNumber), null)
    endfunction

    private function PickSlotIsEmpty takes integer pid, integer slotNumber returns boolean
        local string value = PickSlotValue(pid, slotNumber)
        if value == null or value == "" or value == "없음" then
            return true
        endif
        return false
    endfunction

    private function PickSavedSlot takes integer pid, integer heroNumber returns integer
        local integer i = 1
        loop
            exitwhen i > 3
            if PickSlotValue(pid, i) == I2S(heroNumber) then
                return i
            endif
            set i = i + 1
        endloop
        return 0
    endfunction

    private function PickEmptySlot takes integer pid returns integer
        local integer i = 1
        loop
            exitwhen i > 3
            if PickSlotIsEmpty(pid, i) then
                return i
            endif
            set i = i + 1
        endloop
        return 0
    endfunction

    private function PickMaxScrollOffset takes nothing returns integer
        local integer maxOffset = PickCardCount - PickVisibleCardCount
        if maxOffset <= 0 then
            return 0
        endif
        return ((maxOffset + PickCardColumnCount - 1) / PickCardColumnCount) * PickCardColumnCount
    endfunction

    private function PickVisibleHeroNumber takes integer slot returns integer
        return PickScrollOffset + slot
    endfunction

    private function RefreshPickScroll takes nothing returns nothing
        local integer maxOffset = PickMaxScrollOffset()
        local real topY = 0.540
        local real bottomY = 0.190
        local real knobY = topY
        if maxOffset > 0 then
            set knobY = topY - ((topY - bottomY) * I2R(PickScrollOffset) / I2R(maxOffset))
        endif
        call DzFrameSetAbsolutePoint(FP_ScrollKnob, JN_FRAMEPOINT_CENTER, 0.4850, knobY)
    endfunction

    private function HidePickPortraits takes nothing returns nothing
        local integer i = 1
        loop
            exitwhen i > PickCardCount
            call DzFrameShow(FP_PotBD[i], false)
            set i = i + 1
        endloop
    endfunction

    private function RefreshPickConfirm takes integer pid returns nothing
        local integer slotNumber = 0
        if SHNumber < 1 or SHNumber > MaxHero then
            call DzFrameShow(FP_SelectBBD, false)
            return
        endif

        set slotNumber = PickSavedSlot(pid, SHNumber)
        if slotNumber != 0 then
            call DzFrameSetText(FP_SelectBT, "로드")
            call DzFrameShow(FP_SelectBBD, true)
            return
        endif

        set slotNumber = PickEmptySlot(pid)
        if slotNumber != 0 then
            call DzFrameSetText(FP_SelectBT, "생성")
            call DzFrameShow(FP_SelectBBD, true)
            return
        endif

        call DzFrameShow(FP_SelectBBD, false)
    endfunction

    private function RefreshPickCards takes integer pid returns nothing
        local integer i = 1
        local integer heroNumber = 0
        loop
            exitwhen i > PickVisibleCardCount
            set heroNumber = PickVisibleHeroNumber(i)
            if heroNumber <= PickCardCount then
                call DzFrameShow(FP_HeroBBD[i], true)
                call DzFrameShow(FP_HeroImgBD[i], true)
                call DzFrameShow(FP_HeroNameBD[i], true)
                call DzFrameShow(FP_HeroT[i], true)
                call DzFrameShow(FP_HeroB[i], true)
                if heroNumber == SHNumber then
                    call DzFrameSetTexture(FP_HeroBBD[i], "UI_PickSelectButton.tga", 0)
                else
                    call DzFrameSetTexture(FP_HeroBBD[i], "UI_PickSelect2.blp", 0)
                endif
                if heroNumber <= MaxHero then
                    call DzFrameSetTexture(FP_HeroImgBD[i], "UI_HeroPot"+I2S(heroNumber)+".blp", 0)
                else
                    call DzFrameSetTexture(FP_HeroImgBD[i], "ReplaceableTextures\\CommandButtons\\BTNHeroIcon0.blp", 0)
                endif
                call DzFrameSetText(FP_HeroT[i], PickHeroName(heroNumber))
                call DzFrameShow(FP_HeroLockBD[i], heroNumber > MaxHero)
            else
                call DzFrameShow(FP_HeroBBD[i], false)
                call DzFrameShow(FP_HeroImgBD[i], false)
                call DzFrameShow(FP_HeroNameBD[i], false)
                call DzFrameShow(FP_HeroLockBD[i], false)
                call DzFrameShow(FP_HeroT[i], false)
                call DzFrameShow(FP_HeroB[i], false)
            endif
            set i = i + 1
        endloop

        call HidePickPortraits()
        if SHNumber >= 1 and SHNumber <= MaxHero then
            call DzFrameShow(FP_PotBD[SHNumber], true)
        endif
        call RefreshPickScroll()
        call RefreshPickConfirm(pid)
    endfunction

    private function ClickBBDButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local integer i = 1
        local integer heroNumber = 0
        loop
            exitwhen i > PickVisibleCardCount
            if f == FP_HeroB[i] then
                set heroNumber = PickVisibleHeroNumber(i)
                if heroNumber <= PickCardCount then
                    set SHNumber = heroNumber
                    call RefreshPickCards(pid)
                endif
                return
            endif
            set i = i + 1
        endloop
    endfunction

    private function ClickPickHeroButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local integer slotNumber = 0

        if SHNumber >= 1 and SHNumber <= MaxHero then
            set slotNumber = PickSavedSlot(pid, SHNumber)
            if slotNumber != 0 then
                set SLNumber = slotNumber
                call DzFrameShow(FP_BD, false)
                call DzSyncData("LoadPick", I2S(SLNumber))
                return
            endif

            set slotNumber = PickEmptySlot(pid)
            if slotNumber != 0 then
                set SLNumber = slotNumber
                call DzFrameShow(FP_BD, false)
                call DzSyncData("NewPick", I2S(SHNumber) + ";" + I2S(SLNumber))
            endif
        endif
    endfunction

    private function ClickSkinButton takes nothing returns nothing
        if SHNumber >= 1 and SHNumber <= MaxHero then
            call HidePickPortraits()
            call DzFrameShow(FP_PotBD[SHNumber], true)
        endif
    endfunction

    private function ClickPickScrollButton takes nothing returns nothing
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local integer maxOffset = PickMaxScrollOffset()
        if maxOffset <= 0 then
            return
        endif
        set PickScrollOffset = PickScrollOffset + PickCardColumnCount
        if PickScrollOffset > maxOffset then
            set PickScrollOffset = 0
        endif
        call RefreshPickCards(pid)
    endfunction

    private function Main2 takes nothing returns nothing
        if true then
            call DzFrameShow(FP_BD, true)
        endif
    endfunction

    private function Main takes nothing returns nothing
        local integer i
        local integer row
        local integer col
        local real cardX
        local real cardY

        //카메라
        call SetCameraBoundsToRectForPlayerBJ( GetLocalPlayer(), gg_rct_Pick )
        call SetCameraPositionForPlayer(GetLocalPlayer(),GetRectCenterX(gg_rct_Pick),GetRectCenterY(gg_rct_Pick))

        call DzLoadToc("war3mapImported\\Templates.toc")

        set FP_BD=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "template", FrameCount())
        call DzFrameSetTexture(FP_BD, "war3mapImported\\UI_Pick_Backdrop2.tga", 0)
        call DzFrameSetVertexColor(FP_BD, DzGetColor(255, 255, 255, 255))
        call DzFrameSetAlpha(FP_BD, 255)
        call DzFrameSetSize(FP_BD, 0.80, 0.55)
        call DzFrameSetAbsolutePoint(FP_BD, JN_FRAMEPOINT_CENTER, 0.4000, 0.3300)
        call DzFrameShow(FP_BD, false)

        set i = 1
        loop
            exitwhen i > 3
            set FP_SL[i]=DzCreateFrameByTagName("BACKDROP", "", FP_BD, "template", FrameCount())
            call DzFrameSetTexture(FP_SL[i], "UI_PickSelect2.blp", 0)
            call DzFrameSetSize(FP_SL[i], 0.001, 0.001)
            call DzFrameSetAbsolutePoint(FP_SL[i], JN_FRAMEPOINT_CENTER, 0.0000, 0.0000)
            call DzFrameShow(FP_SL[i], false)
            set FP_SLB[i] = DzCreateFrameByTagName("BUTTON", "", FP_BD, "ScoreScreenTabButtonTemplate", FrameCount())
            call DzFrameSetSize(FP_SLB[i], 0.001, 0.001)
            call DzFrameSetAbsolutePoint(FP_SLB[i], JN_FRAMEPOINT_CENTER, 0.0000, 0.0000)
            call DzFrameShow(FP_SLB[i], false)
            set i = i + 1
        endloop

        set FP_HeroBBD[0]=DzCreateFrameByTagName("BACKDROP", "", FP_BD, "template", FrameCount())
        call DzFrameSetTexture(FP_HeroBBD[0], "war3mapImported\\UI_Pick_Frame.tga", 0)
        call DzFrameSetVertexColor(FP_HeroBBD[0], DzGetColor(255, 255, 255, 255))
        call DzFrameSetAlpha(FP_HeroBBD[0], 255)
        call DzFrameSetSize(FP_HeroBBD[0], 0.45, 0.37)
        call DzFrameSetAbsolutePoint(FP_HeroBBD[0], JN_FRAMEPOINT_CENTER, 0.2500, 0.3700)

        set i = 1
        loop
            exitwhen i > PickVisibleCardCount
            set row = (i - 1) / PickCardColumnCount
            set col = ModuloInteger(i - 1, PickCardColumnCount)
            set cardX = 0.088 + (0.105 * I2R(col))
            set cardY = 0.505 - (0.125 * I2R(row))

            set FP_HeroBBD[i]=DzCreateFrameByTagName("BACKDROP", "", FP_BD, "template", FrameCount())
            call DzFrameSetTexture(FP_HeroBBD[i], "UI_PickSelect2.blp", 0)
            call DzFrameSetSize(FP_HeroBBD[i], 0.085, 0.095)
            call DzFrameSetAbsolutePoint(FP_HeroBBD[i], JN_FRAMEPOINT_CENTER, cardX, cardY)

            set FP_HeroImgBD[i]=DzCreateFrameByTagName("BACKDROP", "", FP_HeroBBD[i], "template", FrameCount())
            if i <= MaxHero then
                call DzFrameSetTexture(FP_HeroImgBD[i], "UI_HeroPot"+I2S(i)+".blp", 0)
            else
                call DzFrameSetTexture(FP_HeroImgBD[i], "ReplaceableTextures\\CommandButtons\\BTNHeroIcon0.blp", 0)
            endif
            call DzFrameSetSize(FP_HeroImgBD[i], 0.075, 0.075)
            call DzFrameSetPoint(FP_HeroImgBD[i], JN_FRAMEPOINT_CENTER, FP_HeroBBD[i], JN_FRAMEPOINT_CENTER, 0.0, 0.006)

            set FP_HeroNameBD[i]=DzCreateFrameByTagName("BACKDROP", "", FP_HeroBBD[i], "template", FrameCount())
            call DzFrameSetTexture(FP_HeroNameBD[i], "war3mapImported\\UI_Pick_NameBar.tga", 0)
            call DzFrameSetSize(FP_HeroNameBD[i], 0.078, 0.016)
            call DzFrameSetPoint(FP_HeroNameBD[i], JN_FRAMEPOINT_CENTER, FP_HeroBBD[i], JN_FRAMEPOINT_BOTTOM, 0.0, -0.012)

            set FP_HeroT[i]=DzCreateFrameByTagName("TEXT", "", FP_HeroNameBD[i], "", 0)
            call DzFrameSetPoint(FP_HeroT[i], JN_FRAMEPOINT_CENTER, FP_HeroNameBD[i], JN_FRAMEPOINT_CENTER, 0.0, 0.0)
            call DzFrameSetText(FP_HeroT[i], PickHeroName(i))
            call DzFrameSetEnable(FP_HeroT[i], false)

            set FP_HeroLockBD[i]=DzCreateFrameByTagName("BACKDROP", "", FP_HeroBBD[i], "template", FrameCount())
            call DzFrameSetTexture(FP_HeroLockBD[i], "UI_Inventory_Lock2.blp", 0)
            call DzFrameSetSize(FP_HeroLockBD[i], 0.030, 0.030)
            call DzFrameSetPoint(FP_HeroLockBD[i], JN_FRAMEPOINT_CENTER, FP_HeroBBD[i], JN_FRAMEPOINT_CENTER, 0.0, 0.0)
            call DzFrameShow(FP_HeroLockBD[i], i > MaxHero)

            set FP_HeroB[i]=DzCreateFrameByTagName("BUTTON", "", FP_HeroBBD[i], "ScoreScreenTabButtonTemplate", FrameCount())
            call DzFrameSetAllPoints(FP_HeroB[i], FP_HeroBBD[i])
            call DzFrameSetSize(FP_HeroB[i], 0.085, 0.095)
            call DzFrameSetScriptByCode(FP_HeroB[i], JN_FRAMEEVENT_MOUSE_UP, function ClickBBDButton, false)
            set i = i + 1
        endloop

        set FP_ScrollTrack=DzCreateFrameByTagName("BACKDROP", "", FP_BD, "template", FrameCount())
        call DzFrameSetTexture(FP_ScrollTrack, "Textures\\black32.blp", 0)
        call DzFrameSetVertexColor(FP_ScrollTrack, DzGetColor(230, 214, 122, 54))
        call DzFrameSetSize(FP_ScrollTrack, 0.005, 0.35)
        call DzFrameSetAbsolutePoint(FP_ScrollTrack, JN_FRAMEPOINT_CENTER, 0.4850, 0.3650)

        set FP_ScrollKnob=DzCreateFrameByTagName("BACKDROP", "", FP_BD, "template", FrameCount())
        call DzFrameSetTexture(FP_ScrollKnob, "UI_PickSelectButton.tga", 0)
        call DzFrameSetVertexColor(FP_ScrollKnob, DzGetColor(245, 170, 42, 38))
        call DzFrameSetSize(FP_ScrollKnob, 0.020, 0.026)
        call DzFrameSetAbsolutePoint(FP_ScrollKnob, JN_FRAMEPOINT_CENTER, 0.4850, 0.5400)

        set FP_ScrollB=DzCreateFrameByTagName("BUTTON", "", FP_BD, "ScoreScreenTabButtonTemplate", FrameCount())
        call DzFrameSetSize(FP_ScrollB, 0.035, 0.35)
        call DzFrameSetAbsolutePoint(FP_ScrollB, JN_FRAMEPOINT_CENTER, 0.4850, 0.3650)
        call DzFrameSetScriptByCode(FP_ScrollB, JN_FRAMEEVENT_MOUSE_UP, function ClickPickScrollButton, false)

        set FP_PreviewPanel=DzCreateFrameByTagName("BACKDROP", "", FP_BD, "template", FrameCount())
        call DzFrameSetTexture(FP_PreviewPanel, "war3mapImported\\UI_Pick_Panel.tga", 0)
        call DzFrameSetVertexColor(FP_PreviewPanel, DzGetColor(255, 255, 255, 255))
        call DzFrameSetAlpha(FP_PreviewPanel, 255)
        call DzFrameSetSize(FP_PreviewPanel, 0.245, 0.230)
        call DzFrameSetAbsolutePoint(FP_PreviewPanel, JN_FRAMEPOINT_CENTER, 0.6300, 0.4100)

        set i = 1
        loop
            exitwhen i > PickCardCount
            set FP_PotBD[i]=DzCreateFrameByTagName("BACKDROP", "", FP_PreviewPanel, "template", FrameCount())
            if i <= MaxHero then
                call DzFrameSetTexture(FP_PotBD[i], "UI_HeroPot"+I2S(i)+".blp", 0)
            else
                call DzFrameSetTexture(FP_PotBD[i], "ReplaceableTextures\\CommandButtons\\BTNHeroIcon0.blp", 0)
            endif
            call DzFrameSetSize(FP_PotBD[i], 0.225, 0.205)
            call DzFrameSetPoint(FP_PotBD[i], JN_FRAMEPOINT_CENTER, FP_PreviewPanel, JN_FRAMEPOINT_CENTER, 0.0, 0.0)
            call DzFrameShow(FP_PotBD[i], false)
            set i = i + 1
        endloop

        set FP_SkinBBD=DzCreateFrameByTagName("BACKDROP", "", FP_BD, "template", FrameCount())
        call DzFrameSetTexture(FP_SkinBBD, "war3mapImported\\UI_Pick_Panel.tga", 0)
        call DzFrameSetVertexColor(FP_SkinBBD, DzGetColor(255, 255, 255, 255))
        call DzFrameSetAlpha(FP_SkinBBD, 255)
        call DzFrameSetSize(FP_SkinBBD, 0.245, 0.120)
        call DzFrameSetAbsolutePoint(FP_SkinBBD, JN_FRAMEPOINT_CENTER, 0.6300, 0.2200)

        set FP_SkinBT=DzCreateFrameByTagName("TEXT", "", FP_SkinBBD, "", 0)
        call DzFrameSetPoint(FP_SkinBT, JN_FRAMEPOINT_CENTER, FP_SkinBBD, JN_FRAMEPOINT_TOP, 0.0, -0.025)
        call DzFrameSetText(FP_SkinBT, "기본 스킨")
        call DzFrameSetEnable(FP_SkinBT, false)

        set FP_SkinB=DzCreateFrameByTagName("BUTTON", "", FP_SkinBBD, "ScoreScreenTabButtonTemplate", FrameCount())
        call DzFrameSetSize(FP_SkinB, 0.120, 0.030)
        call DzFrameSetPoint(FP_SkinB, JN_FRAMEPOINT_CENTER, FP_SkinBBD, JN_FRAMEPOINT_TOP, 0.0, -0.025)
        call DzFrameSetScriptByCode(FP_SkinB, JN_FRAMEEVENT_MOUSE_UP, function ClickSkinButton, false)

        set FP_SelectBBD=DzCreateFrameByTagName("BACKDROP", "", FP_BD, "template", FrameCount())
        call DzFrameSetTexture(FP_SelectBBD, "UI_PickSelectButton.tga", 0)
        call DzFrameSetSize(FP_SelectBBD, 0.080, 0.035)
        call DzFrameSetAbsolutePoint(FP_SelectBBD, JN_FRAMEPOINT_CENTER, 0.6300, 0.1050)
        call DzFrameShow(FP_SelectBBD, false)

        set FP_SelectBT=DzCreateFrameByTagName("TEXT","",FP_SelectBBD,"",0)
        call DzFrameSetPoint(FP_SelectBT, JN_FRAMEPOINT_CENTER, FP_SelectBBD, JN_FRAMEPOINT_CENTER, 0.0, 0.0)
        call DzFrameSetText(FP_SelectBT,"결정")
        call DzFrameSetEnable(FP_SelectBT, false)

        set FP_SelectB=DzCreateFrameByTagName("BUTTON", "", FP_SelectBBD, "ScoreScreenTabButtonTemplate", FrameCount())
        call DzFrameSetAllPoints(FP_SelectB, FP_SelectBBD)
        call DzFrameSetSize(FP_SelectB, 0.080, 0.035)
        call JNFrameSetLevel(FP_SelectBBD, 20)
        call JNFrameSetLevel(FP_SelectB, 21)
        call JNFrameSetLevel(FP_SelectBT, 22)
        call DzFrameSetScriptByCode(FP_SelectB, JN_FRAMEEVENT_MOUSE_UP, function ClickPickHeroButton, false)

        set FP_LoadBBD=DzCreateFrameByTagName("BACKDROP", "", FP_BD, "template", FrameCount())
        call DzFrameSetTexture(FP_LoadBBD, "UI_PickSelectButton.tga", 0)
        call DzFrameSetSize(FP_LoadBBD, 0.001, 0.001)
        call DzFrameSetAbsolutePoint(FP_LoadBBD, JN_FRAMEPOINT_CENTER, 0.0000, 0.0000)
        call DzFrameShow(FP_LoadBBD, false)
        set FP_LoadBT=DzCreateFrameByTagName("TEXT","",FP_LoadBBD,"",0)
        set FP_LoadB=DzCreateFrameByTagName("BUTTON", "", FP_LoadBBD, "ScoreScreenTabButtonTemplate", FrameCount())

        set SHNumber = 0
        set PickScrollOffset = 0
        call RefreshPickScroll()
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
