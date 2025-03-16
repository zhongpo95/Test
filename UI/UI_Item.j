library UIItem initializer Init requires DataItem, StatsSet, UIShop, ITEM, FrameCount
    globals
        hashtable Hash = InitHashtable()
        //아이템창 여는 버튼 백드롭
        integer F_ItemOpenButtonBD
        //아이템창 여는 버튼
        integer F_ItemOpenButton
        //메뉴 배경
        integer F_ItemBackDrop
        //장비,기타 표시 배경
        integer F_EQETCTemplateBackDrop
        integer F_ETC2emplateBackDrop
        //아이템 배경
        integer F_ItemTemplateBackDrop
        //취소 버튼
        integer F_ItemCancelButton

        //우클릭메뉴
        integer F_RightMenu
        //집은 아이템
        integer F_PickUp
        //픽업중 체크
        boolean PickUpOn = false
        //프레임 마우스들어감
        boolean array FrameIn
        //마지막으로 우클릭한 인벤토리 칸 번호
        private integer LastRightClicked = -1
        //아이템 파기 배경
        integer F_ItemDelBackDrop
        //진짜 파기 버튼
        integer F_RDButtons
        //파기 취소 버튼
        integer F_CLButtons
        //장비 분해 설명
        integer F_DELText
        //일괄파기 버튼
        integer F_ALLDLEButtons
        integer F_ItemALLDelBackDrop

        //장비아이템 버튼들
        integer array F_EItemButtons
        //아이템 버튼들
        integer array F_ItemButtons
        //장비탭 버튼
        integer F_EQButtons
        //재료탭 버튼
        integer F_ETCButtons
        //잠금 버튼
        integer F_LOCKButtons
        //골드 아이콘
        integer F_GoldBackDrop
        //골드 텍스트
        integer F_GoldText
        //아이템 버튼 배경 아이콘들
        integer array F_ItemButtonsBackDrop
        //아이템 버튼 배경 아이콘들
        integer array F_ItemButtonLock
        //장비 아이템 버튼 배경 아이콘들
        integer array F_EItemButtonsBackDrop
        //장비아이콘 버튼들 숨김
        integer F_EQButtonsShow
        //장비 아이콘 버튼들 숨김
        integer F_ETCButtonsShow
        
        //플레이어 온오프
        boolean array F_ItemOnOff
        //플레이어가 클릭한 아이템 번호
        integer F_ItemClickNumber = 200
        //플레이어 창고 온오프
        boolean array F_Storage_OnOff
        
        //string array Ivitem [13][104]             //인벤토리 아이템번호

        //장착한 인벤토리 아이템번호
        string array Eitem [13][20]
        
        
        //창고
        //창고 아이템 버튼들
        integer array F_Storage_Buttons
        //아이템 버튼 배경 아이콘들
        integer array F_Storage_ButtonsBackDrop
        //아이템 버튼 배경 아이콘들
        integer array F_Storage_ButtonLock
        //장비아이콘 버튼들 숨김
        integer F_Storage_EQButtonsShow
        //장비 아이콘 버튼들 숨김
        integer F_Storage_ETCButtonsShow
        //string array Stitem [13][104]               //창고 아이템번호
        //메뉴 배경
        integer F_Storage_BackDrop
        //장비,기타 표시 배경
        integer F_Storage_EQBackDrop
        integer F_Storage_ETCBackDrop
        //취소 버튼
        integer F_Storage_CancelButton
        //장비탭 버튼
        integer F_Storage_EQButtons
        //재료탭 버튼
        integer F_Storage_ETCButtons
    endglobals

    //템제거 RemoveItem2(플레이어아이디,지울번호,창고?)
    function RemoveItem2 takes integer pid, integer number, boolean st returns nothing
        local string sn
        if GetLocalPlayer() == Player(pid) then
            if st == false then
            //인벤에서 제거
                set sn = I2S(PlayerSlotNumber[pid])
                call DzFrameSetTexture(F_ItemButtonsBackDrop[number], "UI_Inventory.blp", 0)
                call DzFrameShow(UI_Tip, false)
                call StashRemove(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(number))
                call DzFrameShow(F_ItemButtonLock[number], false)
            elseif st == true then
                call DzFrameSetTexture(F_Storage_ButtonsBackDrop[number], "UI_Inventory.blp", 0)
                call DzFrameShow(UI_Tip, false)
                call StashRemove(pid:PLAYER_DATA, "창고"+I2S(number))
                call DzFrameShow(F_Storage_ButtonLock[number], false)
            endif
        endif
    endfunction

    // 마우스 우클릭 ====================================================================================================
    private function MouseRightClick takes nothing returns nothing
        local integer pid = GetPlayerId(DzGetTriggerKeyPlayer())
        local string sn = I2S(PlayerSlotNumber[pid])
        local integer i
        
        call DzFrameShow(F_ItemDelBackDrop, false)

        // 템을 찝은 상태일 경우 찝기 해제
        if F_ItemClickNumber != 200 and PickUpOn == true then
            // 값 초기화, 프레임 숨기기
            set F_ItemClickNumber = 200
            set PickUpOn = false
            call DzFrameShow(F_PickUp, false)
        // 템을 안찝은 상태일 경우 우클릭 메뉴 보이기
        else
            set i = 0
            loop
            exitwhen i > 50
                if FrameIn[i] and (GetItemIDs(StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(i), "0")) != 0 ) then
                    exitwhen true
                endif
                set i = i + 1
            endloop
            if i < 50 then
                set LastRightClicked = i
                call DzFrameShow(DzFrameFindByName("RightMenuBack", 0), true)
                call DzFrameSetPoint(DzFrameFindByName("RightMenuBack", 0), JN_FRAMEPOINT_TOPLEFT, F_ItemButtons[i], JN_FRAMEPOINT_TOPRIGHT, 0, 0)
            endif
        endif
    endfunction

    private function F_ON_ActionsSt takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local string str = ""
        local integer selectnumber = LoadInteger(Hash, f, StringHash("number")) - 10000
        local string items = ""
        local integer itemid = 0
        local integer i = 0
        local integer quality = 0
        local integer up = 0
        local integer cts = 0
        local integer tier = 0

        set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(selectnumber), "0")
        
        set itemid = GetItemIDs(items)
        
        if itemid != 0 then
            call DzFrameShow(UI_Tip, true)
            set i = GetItemTypes(items)
            set up = GetItemUp(items)
            set quality = GetItemQuality(items)
            set cts = GetItemCombatStats(items)
            set tier = GetItemTier(items)
            if i >= 6 then
                call DzFrameSetText(UI_Tip_Text[1], GetItemNames(items) )
            else
                call DzFrameSetText(UI_Tip_Text[1], "+" + I2S(up) + " " + GetItemNames(items) )
            endif
            set str = "|cFFA5FA7D[ 종류 ]|r "
            // 0모자, 1상의, 2하의, 3장갑, 4견갑, 5무기, 6목걸이, 7귀걸이, 8반지, 9팔찌, 10카드
            //장비 0아이템아이디, 1강화수치, 2품질, 3특성, 4각인1, 5각인수치, 6각인2, 7각인수치, 8각인P, 9각인P수치, 10잠금
            //목걸이 0스탯, 1체력, 2품0, 3품질 5당 추가량
            //기타 0아이템아이디, 1중첩수
            if i == 0 then
                set str = str + "모자|n|n"
                set str = str + "  |cFFB9E2FA방어 등급|r +"
                set str = str + JNStringSplit(ItemStats[i][tier],";", up )
            elseif i == 1 then
                set str = str + "상의|n|n"
                set str = str + "  |cFFB9E2FA방어 등급|r +"
                set str = str + JNStringSplit(ItemStats[i][tier],";", up )
            elseif i == 2 then
                set str = str + "하의|n|n"
                set str = str + "  |cFFB9E2FA방어 등급|r +"
                set str = str + JNStringSplit(ItemStats[i][tier],";", up )
            elseif i == 3 then
                set str = str + "장갑|n|n"
                set str = str + "  |cFFB9E2FA방어 등급|r +"
                set str = str + JNStringSplit(ItemStats[i][tier],";", up )
            elseif i == 4 then
                set str = str + "견갑|n|n"
                set str = str + "  |cFFB9E2FA방어 등급|r +"
                set str = str + JNStringSplit(ItemStats[i][tier],";", up )
            elseif i == 5 then
                set str = str + "무기|n|n"
                set str = str + "  |cFFB9E2FA무기 공격력|r +"
                set str = str + JNStringSplit(ItemStats[i][tier],";", up )
                set str = str + "|n|n|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                set str = str + "  |cFFB9E2FA추가 피해|r +"
                set str = str + R2S(ItemWeaponQuality[quality]) + "%"
            elseif i == 6 then
                set str = str + "목걸이|n|n"
                //치신
                if cts == 1 then
                    set str = str + "|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA치명|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                    set str = str + "|n  |cFFB9E2FA신속|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //치치
                elseif cts == 2 then
                    set str = str + "|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA치명|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                    set str = str + "|n  |cFFB9E2FA치명|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //신신
                elseif cts == 3 then
                    set str = str + "|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA신속|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                    set str = str + "|n  |cFFB9E2FA신속|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                endif
                //아르카나
                if GetItemCombatBonus2(items) + GetItemCombatPenalty2(items) > 0 then
                    set str = str + "|n|n|cff5AD2FF[ 아르카나 ]|r|n"
                    set str = str + "  [|cFFFFE400 " + ArcanaText[GetItemCombatBonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombatBonus2(items))
                    set str = str + "|n  [|cFFFF0000 " + ArcanaText[GetItemCombatPenalty(items)] + " |r]"
                endif
            elseif i == 7 then
                set str = str + "귀걸이|n|n"
                //치
                if cts == 1 then
                    set str = str + "|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA치명|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //신
                elseif cts == 2 then
                    set str = str + "|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA신속|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                endif
                //아르카나
                if GetItemCombatBonus2(items) + GetItemCombatPenalty2(items) > 0 then
                    set str = str + "|n|n|cff5AD2FF[ 아르카나 ]|r|n"
                    set str = str + "  [|cFFFFE400 " + ArcanaText[GetItemCombatBonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombatBonus2(items))
                    set str = str + "|n  [|cFFFF0000 " + ArcanaText[GetItemCombatPenalty(items)] + " |r]"
                endif
            elseif i == 8 then
                set str = str + "반지|n|n"
                //치
                if cts == 1 then
                    set str = str + "|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA치명|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //신
                elseif cts == 2 then
                    set str = str + "|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA신속|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                endif
                //아르카나
                if GetItemCombatBonus2(items) + GetItemCombatPenalty2(items) > 0 then
                    set str = str + "|n|n|cff5AD2FF[ 아르카나 ]|r|n"
                    set str = str + "  [|cFFFFE400 " + ArcanaText[GetItemCombatBonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombatBonus2(items))
                    set str = str + "|n  [|cFFFF0000 " + ArcanaText[GetItemCombatPenalty(items)] + " |r]"
                endif
            elseif i == 9 then
                set str = str + "팔찌|n"
            elseif i == 10 then
                set str = str + "카드|n|n"
                //아르카나
                if GetItemCardBonus1(items) + GetItemCardBonus2(items) + GetItemCardBonus3(items) > 0 then
                    set str = str + "|n|n|cff5AD2FF[ 아르카나 ]|r|n"
                    set str = str + "  [|cFFFFE400 대미지 증가 |r] Lv "
                    set str = str + I2S(GetItemCardBonus1(items))
                    set str = str + "|n  [|cFFFFE400 대미지 증가 |r] Lv "
                    set str = str + I2S(GetItemCardBonus2(items))
                    set str = str + "|n  [|cFFFF0000 공격력 감소 |r] Lv "
                    set str = str + I2S(GetItemCardBonus3(items))
                endif
            endif
            
            call DzFrameSetText(UI_Tip_Text[2], str)
        endif
    endfunction
    
    private function F_ON_ActionsSt2 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local string str = ""
        local string items = ""
        local integer itemid = 0
        local integer i = 0
        local integer selectnumber = LoadInteger(Hash, f, StringHash("number")) - 10000
        
        set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(selectnumber), "0")
        
        set itemid = GetItemIDs(items)
        
        if itemid != 0 then
            call DzFrameShow(UI_Tip, true)
            call DzFrameSetText(UI_Tip_Text[1], GetItemNames(items) + "  "+ I2S(GetItemCharge(items))+"개" )
            set str = "|cFFA5FA7D[ 종류 ]|r 재료|n"
            set str = str + "|n|cff5AD2FF[ 설명 ]|r|n"
            set str = str + "|cFFB9E2FA"+GetItemTip(items)+"|r|n"
            call DzFrameSetText(UI_Tip_Text[2], str)
        endif
    endfunction
    
    private function F_OFF_Actions takes nothing returns nothing
        set FrameIn[LoadInteger(Hash, DzGetTriggerUIEventFrame(), StringHash("number"))] = false
        call DzFrameShow(UI_Tip, false)
    endfunction

    private function F_OFF_ActionsSt takes nothing returns nothing
        call DzFrameShow(UI_Tip, false)
    endfunction
    
    private function F_ON_Actions2 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local string str = ""
        local string items = ""
        local integer itemid = 0
        local integer i = 0
        local string sn = I2S(PlayerSlotNumber[pid])
        local integer selectnumber = LoadInteger(Hash, f, StringHash("number"))
        
        set FrameIn[selectnumber] = false

        set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(selectnumber), "0")
        
        set itemid = GetItemIDs(items)
        
        if itemid != 0 then
            call DzFrameShow(UI_Tip, true)
            call DzFrameSetText(UI_Tip_Text[1], GetItemNames(items) + "  "+ I2S(GetItemCharge(items))+"개" )
            if i == 1 then
                set str = "|cFFA5FA7D[ 종류 ]|r 소모품|n"
            else
                set str = "|cFFA5FA7D[ 종류 ]|r 재료|n"
            endif
            set str = str + "|n|cff5AD2FF[ 설명 ]|r|n"
            set str = str + "|cFFB9E2FA"+GetItemTip(items)+"|r|n"
            call DzFrameSetText(UI_Tip_Text[2], str)
        endif
        
    endfunction
    
    private function F_ON_Actions takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local string str = ""
        local string items = ""
        local integer itemid = 0
        local integer i = 0
        local integer quality = 0
        local integer up = 0
        local integer cts = 0
        local integer tier = 0
        local string sn = I2S(PlayerSlotNumber[pid])
        local integer selectnumber = LoadInteger(Hash, f, StringHash("number"))

        set FrameIn[selectnumber] = true

        set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(selectnumber), "0")
        
        set itemid = GetItemIDs(items)
        
        if itemid != 0 then
            call DzFrameShow(UI_Tip, true)
            set i = GetItemTypes(items)
            set up = GetItemUp(items)
            set quality = GetItemQuality(items)
            set cts = GetItemCombatStats(items)
            set tier = GetItemTier(items)
            if i >= 6 then
                call DzFrameSetText(UI_Tip_Text[1], GetItemNames(items) )
            else
                call DzFrameSetText(UI_Tip_Text[1], "+" + I2S(up) + " " + GetItemNames(items) )
            endif
            set str = "|cFFA5FA7D[ 종류 ]|r "
            // 0모자, 1상의, 2하의, 3장갑, 4견갑, 5무기, 6목걸이, 7귀걸이, 8반지, 9팔찌, 10카드
            //장비 0아이템아이디, 1강화수치, 2품질, 3특성, 4각인1, 5각인수치, 6각인2, 7각인수치, 8각인P, 9각인P수치, 10잠금
            //목걸이 0스탯, 1체력, 2품0, 3품질 5당 추가량
            //기타 0아이템아이디, 1중첩수
            if i == 0 then
                set str = str + "모자|n|n"
                set str = str + "  |cFFB9E2FA방어 등급|r +"
                set str = str + JNStringSplit(ItemStats[i][tier],";", up )
            elseif i == 1 then
                set str = str + "상의|n|n"
                set str = str + "  |cFFB9E2FA방어 등급|r +"
                set str = str + JNStringSplit(ItemStats[i][tier],";", up )
            elseif i == 2 then
                set str = str + "하의|n|n"
                set str = str + "  |cFFB9E2FA방어 등급|r +"
                set str = str + JNStringSplit(ItemStats[i][tier],";", up )
            elseif i == 3 then
                set str = str + "장갑|n|n"
                set str = str + "  |cFFB9E2FA방어 등급|r +"
                set str = str + JNStringSplit(ItemStats[i][tier],";", up )
            elseif i == 4 then
                set str = str + "견갑|n|n"
                set str = str + "  |cFFB9E2FA방어 등급|r +"
                set str = str + JNStringSplit(ItemStats[i][tier],";", up )
            elseif i == 5 then
                set str = str + "무기|n|n"
                set str = str + "  |cFFB9E2FA무기 공격력|r +"
                set str = str + JNStringSplit(ItemStats[i][tier],";", up )
                set str = str + "|n|n|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                set str = str + "  |cFFB9E2FA추가 피해|r +"
                set str = str + R2S(ItemWeaponQuality[quality]) + "%"
            elseif i == 6 then
                set str = str + "목걸이|n|n"
                //치신
                if cts == 1 then
                    set str = str + "|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA치명|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                    set str = str + "|n  |cFFB9E2FA신속|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //치치
                elseif cts == 2 then
                    set str = str + "|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA치명|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                    set str = str + "|n  |cFFB9E2FA치명|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //신신
                elseif cts == 3 then
                    set str = str + "|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA신속|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                    set str = str + "|n  |cFFB9E2FA신속|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                endif
                //아르카나
                if GetItemCombatBonus2(items) + GetItemCombatPenalty2(items) > 0 then
                    set str = str + "|n|n|cff5AD2FF[ 아르카나 ]|r|n"
                    set str = str + "  [|cFFFFE400 " + ArcanaText[GetItemCombatBonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombatBonus2(items))
                    set str = str + "|n  [|cFFFF0000 " + ArcanaText[GetItemCombatPenalty(items)] + " |r]"
                endif
            elseif i == 7 then
                set str = str + "귀걸이|n|n"
                //치
                if cts == 1 then
                    set str = str + "|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA치명|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //신
                elseif cts == 2 then
                    set str = str + "|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA신속|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                endif
                //아르카나
                if GetItemCombatBonus2(items) + GetItemCombatPenalty2(items) > 0 then
                    set str = str + "|n|n|cff5AD2FF[ 아르카나 ]|r|n"
                    set str = str + "  [|cFFFFE400 " + ArcanaText[GetItemCombatBonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombatBonus2(items))
                    set str = str + "|n  [|cFFFF0000 " + ArcanaText[GetItemCombatPenalty(items)] + " |r]"
                endif
            elseif i == 8 then
                set str = str + "반지|n|n"
                //치
                if cts == 1 then
                    set str = str + "|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA치명|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //신
                elseif cts == 2 then
                    set str = str + "|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA신속|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                endif
                //아르카나
                if GetItemCombatBonus2(items) + GetItemCombatPenalty2(items) > 0 then
                    set str = str + "|n|n|cff5AD2FF[ 아르카나 ]|r|n"
                    set str = str + "  [|cFFFFE400 " + ArcanaText[GetItemCombatBonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombatBonus2(items))
                    set str = str + "|n  [|cFFFF0000 " + ArcanaText[GetItemCombatPenalty(items)] + " |r]"
                endif
            elseif i == 9 then
                set str = str + "팔찌|n"
            elseif i == 10 then
                set str = str + "카드|n|n"
                //아르카나
                if GetItemCardBonus1(items) + GetItemCardBonus2(items) + GetItemCardBonus3(items) > 0 then
                    set str = str + "|n|n|cff5AD2FF[ 아르카나 ]|r|n"
                    set str = str + "  [|cFFFFE400 대미지 증가 |r] Lv "
                    set str = str + I2S(GetItemCardBonus1(items))
                    set str = str + "|n  [|cFFFFE400 대미지 증가 |r] Lv "
                    set str = str + I2S(GetItemCardBonus2(items))
                    set str = str + "|n  [|cFFFF0000 공격력 감소 |r] Lv "
                    set str = str + I2S(GetItemCardBonus3(items))
                endif
            endif
            
            call DzFrameSetText(UI_Tip_Text[2], str)
        endif
    endfunction
    
    private function StorageClickETCButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
    
        call DzFrameSetEnable(F_Storage_EQButtons,true)
        call DzFrameSetEnable(F_Storage_ETCButtons,false)
        
        call DzFrameShow(F_Storage_ETCButtonsShow,true)
        call DzFrameShow(F_Storage_EQButtonsShow,false)
        
        call StopSound(gg_snd_MouseClick1, false, false)
        call StartSound(gg_snd_MouseClick1)
    endfunction
    
    private function StorageClickEQButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        
        call DzFrameSetEnable(F_Storage_EQButtons,false)
        call DzFrameSetEnable(F_Storage_ETCButtons,true)
        
        call DzFrameShow(F_Storage_ETCButtonsShow,false)
        call DzFrameShow(F_Storage_EQButtonsShow,true)
        
        call StopSound(gg_snd_MouseClick1, false, false)
        call StartSound(gg_snd_MouseClick1)
    endfunction
    
    private function StShowMenu takes nothing returns nothing
        //메뉴 버튼을 누르면 메뉴 버튼 비활설화 + 메뉴 배경 표시
        //다시 메뉴 버튼을 누르면 메뉴버튼 활성화 + 메뉴 배경 숨김
        if F_Storage_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] == true then
            call DzFrameShow(F_Storage_BackDrop, false)
            call DzFrameShow(F_ItemDelBackDrop, false)
            set F_Storage_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = false
            set F_ItemClickNumber = 200
        else
            call DzFrameShow(F_Storage_BackDrop, true)
            set F_Storage_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = true
            set F_ItemClickNumber = 200
        endif
    endfunction
    
    private function ShowMenu takes nothing returns nothing
        //메뉴 버튼을 누르면 메뉴 버튼 비활설화 + 메뉴 배경 표시
        //다시 메뉴 버튼을 누르면 메뉴버튼 활성화 + 메뉴 배경 숨김
        if F_ItemOnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] == true then
            call DzFrameShow(F_ItemBackDrop, false)
            call DzFrameShow(F_ItemDelBackDrop, false)
            set F_ItemOnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = false
            set F_ItemClickNumber = 200
        else
            call DzFrameShow(F_ItemBackDrop, true)
            set F_ItemOnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = true
            set F_ItemClickNumber = 200
        endif
    endfunction

    private function ClickLockButton takes nothing returns nothing
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local integer i = LastRightClicked
        local integer j = 0
        local string items
        local integer itemty = 0
        local string sn = I2S(PlayerSlotNumber[pid])

        call DzFrameShow(F_RightMenu, false )

        if i != 200 then
            set F_ItemClickNumber = 200
            set j = GetItemLock(StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(i), "0"))
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(i), "0")
            if j == 0 then
                set items = SetItemLock(items, 1)
                call StashSave(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(i), items)
                call DzFrameShow(F_ItemButtonLock[i], true)
            elseif j == 1 then
                set itemty = GetItemTypes(items)
                if itemty == 6 or itemty == 7 or itemty == 8 then
                    set items = SetItemLock(items, 0)
                    call StashSave(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(i), items)
                    call DzFrameShow(F_ItemButtonLock[i], false)
                endif
            endif
        endif
        
        set LastRightClicked = -1

        call StopSound(gg_snd_MouseClick1, false, false)
        call StartSound(gg_snd_MouseClick1)
    endfunction

    private function ClickALLDELButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())

        call DzFrameShow(F_RightMenu, false )
        call DzFrameShow(F_ItemDelBackDrop, false)
        call DzFrameShow(F_ItemALLDelBackDrop, true)
        
        set LastRightClicked = -1
        set F_ItemClickNumber = 200
        
        call StopSound(gg_snd_MouseClick1, false, false)
        call StartSound(gg_snd_MouseClick1)
    endfunction

    private function ClickDELButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local integer i = LastRightClicked
        local string sn = I2S(PlayerSlotNumber[pid])
        //f: 트리거를 작동시킨 프레임(비동기화시에만 잡히니 주의.)

        call DzFrameShow(F_RightMenu, false )
        call DzFrameShow(F_ItemALLDelBackDrop, false)
        
        set F_ItemClickNumber = 200
        
        if i != 200 then
            if i < 50 then
                if GetItemLock(StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(i), "0")) == 0 then
                    call DzFrameSetText(F_DELText, GetItemNames(StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(i), "0"))+"을 분해하시겠습니까?")
                    call DzFrameShow(F_ItemDelBackDrop, true)
                else
                    set LastRightClicked = -1
                endif
            endif
        endif
        
        call StopSound(gg_snd_MouseClick1, false, false)
        call StartSound(gg_snd_MouseClick1)
    endfunction

    private function ClickDELButton2 takes nothing returns nothing
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local integer i = LastRightClicked
        local string sn = I2S(PlayerSlotNumber[pid])
        
        call DzFrameShow(F_RightMenu, false )
        
        if i != 200 then
            if StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(i), "0") != "0" and GetItemLock(StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(i), "0")) == 0 then
                call DzFrameShow(UI_Tip, false)
                call RemoveItem2(pid,i,false)
                //돈추가 동기화 해야됨
            endif
        endif
        
        set LastRightClicked = -1
        
        call DzFrameShow(F_ItemDelBackDrop, false)

        call StopSound(gg_snd_MouseClick1, false, false)
        call StartSound(gg_snd_MouseClick1)
    endfunction

    private function ClickDELButton3 takes nothing returns nothing
        set LastRightClicked = -1
        call DzFrameShow(F_RightMenu, false )
        call DzFrameShow(F_ItemDelBackDrop, false)
    
        call StopSound(gg_snd_MouseClick1, false, false)
        call StartSound(gg_snd_MouseClick1)
    endfunction

    private function ClickDELButton4 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        
        call DzFrameShow(F_RightMenu, false )
        call DzFrameShow(F_ItemDelBackDrop, false)
        call DzFrameShow(F_ItemALLDelBackDrop, false)
    
        call StopSound(gg_snd_MouseClick1, false, false)
        call StartSound(gg_snd_MouseClick1)
    endfunction

    private function ClickDELButton5 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local integer i = 0
        local string sn = I2S(PlayerSlotNumber[pid])
        
        loop
            if StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(i), "0") != "" and GetItemLock(StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(i), "0")) == 0 then
                call DzFrameShow(UI_Tip, false)
                call RemoveItem2(pid,i,false)
                //돈추가 동기화 해야됨
            endif
            set i = i + 1
            exitwhen i == 50
        endloop

        set LastRightClicked = -1
        set F_ItemClickNumber = 200
        
        call DzFrameShow(F_RightMenu, false )
        call DzFrameShow(F_ItemDelBackDrop, false)
        call DzFrameShow(F_ItemALLDelBackDrop, false)

        call StopSound(gg_snd_MouseClick1, false, false)
        call StartSound(gg_snd_MouseClick1)
    endfunction

    private function ClickStItemButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local integer selectnumber = LoadInteger(Hash, f, StringHash("number"))
        local string items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(selectnumber - 10000), "0")
        local string items2
        local integer itemty = GetItemTypes(items)
        local integer i = 0
        local integer length
        local integer j = 0
        local integer k = 0
        local string sn = I2S(PlayerSlotNumber[pid])
        local real r1 = 0
        local real r2 = 0
    
        call DzFrameShow(F_RightMenu, false )
        call DzFrameShow(F_ItemDelBackDrop, false)

        if items != "0" then
            if F_ItemClickNumber == selectnumber then
                if (selectnumber - 10000) < 50 then
                    set i = 1
                else
                    set i = 2
                endif
            else
                //아이템을 들고있지않으면 템을 듦
                if PickUpOn == false then
                    set F_ItemClickNumber = selectnumber
                    set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(F_ItemClickNumber - 10000), "0")
                    // 좌표 바로 한 번 갱신하기
                    set PickUpOn = true
                    call DzFrameShow(F_PickUp, true)
                    call DzFrameSetTexture(F_PickUp, GetItemArt(items), 0)
                    set r1 = I2R(DzGetMouseXRelative()) / I2R(DzGetWindowWidth()) * 0.8 + 0.0025
                    set r2 = I2R(DzGetWindowHeight() - 42 - DzGetMouseYRelative()) / I2R(DzGetWindowHeight() - 42) * 0.6
                    call DzFrameSetAbsolutePoint(F_PickUp, JN_FRAMEPOINT_CENTER, r1, r2)
                    //call DzFrameSetUpdateCallbackByCode(function FPS)
                //아이템을 들고있으면 자리바꿈
                else
                    //장비
                    if F_ItemClickNumber < 50 then
                        if (selectnumber-10000) < 50 and (selectnumber-10000) >= 0 then
                            set items2 = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(F_ItemClickNumber), "0")
                            call AddIvItem.evaluate(pid, F_ItemClickNumber, items)
                            call AddStItem.evaluate(pid, (selectnumber-10000), items2)
                        endif
                        call DzFrameShow(F_PickUp, false)
                        set F_ItemClickNumber = 200
                    //기타
                    elseif F_ItemClickNumber < 100 then
                        if (selectnumber-10000) < 100 and (selectnumber-10000) >= 50 then
                            set items2 = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(F_ItemClickNumber), "0")
                            call AddIvItem.evaluate(pid, F_ItemClickNumber, items)
                            call AddStItem.evaluate(pid, (selectnumber-10000), items2)
                        endif
                        call DzFrameShow(F_PickUp, false)
                        set F_ItemClickNumber = 200
                    //창고장비
                    elseif (F_ItemClickNumber - 10000) < 50 and F_ItemClickNumber >= 10000 then
                        if (selectnumber-10000) < 50 and (selectnumber-10000) >= 0 then
                            set items2 = StashLoad(pid:PLAYER_DATA, "창고"+I2S(F_ItemClickNumber-10000), "0")
                            call AddStItem.evaluate(pid, F_ItemClickNumber-10000, items)
                            call AddStItem.evaluate(pid, selectnumber-10000, items2)
                        endif
                        call DzFrameShow(F_PickUp, false)
                        set F_ItemClickNumber = 200
                    //기타
                    elseif ((F_ItemClickNumber - 10000) >= 50 and (F_ItemClickNumber - 10000) < 100) and F_ItemClickNumber >= 10000 then
                        if (selectnumber-10000) < 100 and (selectnumber-10000) >= 50 then
                            set items2 = StashLoad(pid:PLAYER_DATA, "창고"+I2S(F_ItemClickNumber-10000), "0")
                            call AddStItem.evaluate(pid, F_ItemClickNumber-10000, items)
                            call AddStItem.evaluate(pid, selectnumber-10000, items2)
                        endif
                        call DzFrameShow(F_PickUp, false)
                        set F_ItemClickNumber = 200
                    endif
                endif
            endif

            //장비템 창고에서 인벤으로 이동
            if i == 1 then
                set i = 0
                set j = 50
                loop        
                    exitwhen i == 50
                    //비어있는 공간이 있음
                    if GetItemIDs(StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(i), "0")) == 0 then
                        set j = i
                        set i = 49
                    endif
                    set i = i + 1
                endloop
                if j < 50 then
                    //창고에서 제거
                    call RemoveItem2(pid, F_ItemClickNumber - 10000, true)
                    //인벤에 추가
                    call AddIvItem.evaluate(pid,j,items)
                    set F_ItemClickNumber = 200
                endif
            //기타템 창고에서 인벤으로 이동
            elseif i == 2 then
                set i = 50
                set j = 0
                
                loop
                    exitwhen i == 100
                    //보유중
                    if GetItemIDs2(StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(i), "0")) == GetItemIDs2(items) then
                        set k = GetItemCharge(items)
                        set j = GetItemCharge(StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(i), "0"))
                        set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(i), "0")
                        set items = SetItemCharge(items, j+k)
                        //중첩변경
                        call StashSave(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(i), items)
                        //제거
                        call RemoveItem2(pid, F_ItemClickNumber - 10000, true)
                        
                        set F_ItemClickNumber = 200
                        
                        set k = 1
                        set i = 99
                    endif
                    set i = i + 1
                endloop
                
                //보유중이지 않음
                if k == 1 then
                else
                    set i = 50
                    set j = 100
                    loop        
                        exitwhen i == 100
                        //비어있는 공간이 있음
                        if GetItemIDs(StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(i), "0")) == 0 then
                            set j = i
                            set i = 99
                        endif
                        set i = i + 1
                    endloop
                    if j < 100 then
                        //창고에서 제거
                        call RemoveItem2(pid, F_ItemClickNumber - 10000, true)
                        //인벤에 추가
                        call AddIvItem.evaluate(pid,j,items)
                        set F_ItemClickNumber = 200
                    endif
                endif
            endif
            call StopSound(gg_snd_MouseClick1, false, false)
            call StartSound(gg_snd_MouseClick1)
        else
            //템을 들고있음
            if PickUpOn == true then
                //창고장비
                if (F_ItemClickNumber - 10000) < 50 and F_ItemClickNumber >= 10000 then
                    if (selectnumber-10000) < 50 and (selectnumber-10000) >= 0 then
                        set items2 = StashLoad(pid:PLAYER_DATA, "창고"+I2S(F_ItemClickNumber-10000), "0")
                        call RemoveItem2(pid, F_ItemClickNumber - 10000, true)
                        call AddStItem.evaluate(pid, selectnumber-10000, items2)
                        call DzFrameShow(F_PickUp, false)
                        set F_ItemClickNumber = 200
                    endif
                //창고기타
                elseif ((F_ItemClickNumber - 10000) >= 50 and (F_ItemClickNumber - 10000) < 100) and F_ItemClickNumber >= 10000 then
                    if (selectnumber-10000) < 100 and (selectnumber-10000) >= 50 then
                        set items2 = StashLoad(pid:PLAYER_DATA, "창고"+I2S(F_ItemClickNumber-10000), "0")
                        call RemoveItem2(pid, F_ItemClickNumber - 10000, true)
                        call AddStItem.evaluate(pid, selectnumber-10000, items2)
                        call DzFrameShow(F_PickUp, false)
                        set F_ItemClickNumber = 200
                    endif
                //인벤장비
                elseif F_ItemClickNumber < 50 then
                    if (selectnumber-10000) < 50 and (selectnumber-10000) >= 0 then
                        set items2 = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(F_ItemClickNumber), "0")
                        call RemoveItem2(pid, F_ItemClickNumber, false)
                        call AddStItem.evaluate(pid, selectnumber-10000, items2)
                        call DzFrameShow(F_PickUp, false)
                        set F_ItemClickNumber = 200
                    endif
                //기타장비
                elseif F_ItemClickNumber < 100 and F_ItemClickNumber >= 50 then
                    if (selectnumber-10000) < 100 and (selectnumber-10000) >= 50 then
                        set items2 = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(F_ItemClickNumber), "0")
                        call RemoveItem2(pid, F_ItemClickNumber, false)
                        call AddStItem.evaluate(pid, selectnumber-10000, items2)
                        call DzFrameShow(F_PickUp, false)
                        set F_ItemClickNumber = 200
                    endif
                endif
            endif
        endif
    endfunction

    private function ClickItemButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local string sn = I2S(PlayerSlotNumber[pid])
        local integer selectnumber = LoadInteger(Hash, f, StringHash("number"))
        local string items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(selectnumber), "0")
        local string items2
        local integer length
        local integer itemty = GetItemTypes(items)
        local integer i = 0
        local integer j = 0
        local integer k = 0
        local integer etyid1
        local integer etyid2
        local real r1
        local real r2

        call DzFrameShow(F_ItemDelBackDrop, false)
        call DzFrameShow(F_RightMenu, false)

        //템있는곳클릭
        if items != "0" and selectnumber < 100 then
            //같은아이템을 두번클릭 장비면 i=1 기타템이면 i=2
            if F_ItemClickNumber == selectnumber then
                if selectnumber < 50 then
                    set i = 1
                else
                    set i = 2
                endif
            else
                //아이템을 들고있지않으면 템을 듦
                if PickUpOn == false then
                    set F_ItemClickNumber = selectnumber
                    set PickUpOn = true
                    set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(F_ItemClickNumber), "0")
                    call DzFrameShow(F_PickUp, true)
                    call DzFrameSetTexture(F_PickUp, GetItemArt(items), 0)
                    set r1 = I2R(DzGetMouseXRelative()) / I2R(DzGetWindowWidth()) * 0.8 + 0.0025
                    set r2 = I2R(DzGetWindowHeight() - 42 - DzGetMouseYRelative()) / I2R(DzGetWindowHeight() - 42) * 0.6
                    call DzFrameSetAbsolutePoint(F_PickUp, JN_FRAMEPOINT_CENTER, r1, r2)
                    //call DzFrameSetUpdateCallbackByCode(function FPS)
                //템을 들고있으면 자리바꿈
                else
                    //장비
                    if F_ItemClickNumber < 50 then
                        if selectnumber < 50 then
                            set items2 = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(F_ItemClickNumber), "0")
                            call AddIvItem.evaluate(pid,F_ItemClickNumber,items)
                            call AddIvItem.evaluate(pid,selectnumber,items2)
                        endif
                        call DzFrameShow(F_PickUp, false)
                        set F_ItemClickNumber = 200
                    //기타
                    elseif F_ItemClickNumber < 100 then
                        //기타
                        if selectnumber < 100 and selectnumber >= 50 then
                            set items2 = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(F_ItemClickNumber), "0")
                            call AddIvItem.evaluate(pid,F_ItemClickNumber,items)
                            call AddIvItem.evaluate(pid,selectnumber,items2)
                        endif
                        call DzFrameShow(F_PickUp, false)
                        set F_ItemClickNumber = 200
                    //창고장비
                    elseif (F_ItemClickNumber - 10000) < 50 and F_ItemClickNumber >= 10000 then
                        if selectnumber < 50 then
                            //창고에 추가
                            set items2 = StashLoad(pid:PLAYER_DATA, "창고"+I2S(F_ItemClickNumber-10000), "0")
                            call AddStItem.evaluate(pid, F_ItemClickNumber-10000, items)
                            call AddIvItem.evaluate(pid,selectnumber,items2)
                        endif
                        call DzFrameShow(F_PickUp, false)
                        set F_ItemClickNumber = 200
                    //기타
                    elseif ((F_ItemClickNumber - 10000) >= 50 and (F_ItemClickNumber - 10000) < 100) and F_ItemClickNumber >= 10000 then
                        if selectnumber < 100 then
                            //창고에 추가
                            set items2 = StashLoad(pid:PLAYER_DATA, "창고"+I2S(F_ItemClickNumber-10000), "0")
                            call AddStItem.evaluate(pid, F_ItemClickNumber-10000, items)
                            call AddIvItem.evaluate(pid,selectnumber,items2)
                        endif
                        call DzFrameShow(F_PickUp, false)
                        set F_ItemClickNumber = 200
                    endif
                endif
            endif


            //창고가 열려있고 두번클릭했을시
            if F_Storage_OnOff[pid] == true then
                if i == 1 then
                    set i = 3
                endif
                if i == 2 then
                    set i = 4
                endif
            endif
            
            //가공품 상점이 열려있고 두번클릭했을시
            if SHOP_OnOff[pid] == true then
                if i == 2 then
                    set i = 5
                endif
            endif

            //재료 상점이 열려있고 두번클릭했을시
            if SHOP2_OnOff[pid] == true then
                if i == 2 then
                    set i = 6
                endif
            endif

            // 0무기, 1모자, 2상의, 3하의, 4장갑, 5견갑, 6목걸이, 7귀걸이, 8반지
            
            // 0모자, 1상의, 2하의, 3장갑, 4견갑, 5무기, 6목걸이, 7귀걸이, 8귀걸이, 9반지, 10반지, 11팔찌, 12카드
            
            //장착
            if i == 1 then
                //귀걸이
                if itemty == 7 then
                    set etyid1 = GetItemIDs(Eitem[pid][7])
                    set etyid2 = GetItemIDs(Eitem[pid][8])
                    //set i = GetItemIDs(items)
                    if etyid1 == 0 then
                        //장착
                        set Eitem[pid][7] = items
                        call DzFrameSetTexture(F_EItemButtonsBackDrop[7], GetItemArt(items), 0)
                        call DzFrameSetTexture(F_ArcanaButtonsBackDrop[1], GetItemArt(items), 0)
                        //인벤에서 제거
                        call DzFrameShow(UI_Tip, false)
                        call RemoveItem2(pid, F_ItemClickNumber, false)
                        set F_ItemClickNumber = 200
                        call DzSyncData("장착",I2S(pid)+"\t"+"7"+"\t"+items)
                    elseif etyid2 == 0 then
                        //장착
                        set Eitem[pid][8] = items
                        call DzFrameSetTexture(F_EItemButtonsBackDrop[8], GetItemArt(items), 0)
                        call DzFrameSetTexture(F_ArcanaButtonsBackDrop[2], GetItemArt(items), 0)
                        //인벤에서 제거
                        call DzFrameShow(UI_Tip, false)
                        call RemoveItem2(pid, F_ItemClickNumber, false)
                        set F_ItemClickNumber = 200
                        call DzSyncData("장착",I2S(pid)+"\t"+"8"+"\t"+items)
                    else
                        //장착
                        set items2 = Eitem[pid][7]
                        set Eitem[pid][7] = items
                        call DzFrameSetTexture(F_EItemButtonsBackDrop[7], GetItemArt(items), 0)
                        call DzFrameSetTexture(F_ArcanaButtonsBackDrop[1], GetItemArt(items), 0)
                        //교체
                        //set j = GetItemIDs(items2)
                        call AddIvItem.evaluate(pid, F_ItemClickNumber, items2)
                        set F_ItemClickNumber = 200
                        call DzSyncData("장착",I2S(pid)+"\t"+"7"+"\t"+items)
                    endif
                //반지
                elseif itemty == 8 then
                    set etyid1 = GetItemIDs(Eitem[pid][9])
                    set etyid2 = GetItemIDs(Eitem[pid][10])
                    //set i = GetItemIDs(items)
                    if etyid1 == 0 then
                        //장착
                        set Eitem[pid][9] = items
                        call DzFrameSetTexture(F_EItemButtonsBackDrop[9], GetItemArt(items), 0)
                        call DzFrameSetTexture(F_ArcanaButtonsBackDrop[3], GetItemArt(items), 0)
                        //인벤에서 제거
                        call RemoveItem2(pid, F_ItemClickNumber, false)
                        call DzFrameShow(UI_Tip, false)
                        set F_ItemClickNumber = 200
                        call DzSyncData("장착",I2S(pid)+"\t"+"9"+"\t"+items)
                    elseif etyid2 == 0 then
                        //장착
                        set Eitem[pid][10] = items
                        call DzFrameSetTexture(F_EItemButtonsBackDrop[10], GetItemArt(items), 0)
                        call DzFrameSetTexture(F_ArcanaButtonsBackDrop[4], GetItemArt(items), 0)
                        //인벤에서 제거
                        call RemoveItem2(pid, F_ItemClickNumber, false)
                        call DzFrameShow(UI_Tip, false)
                        set F_ItemClickNumber = 200
                        call DzSyncData("장착",I2S(pid)+"\t"+"10"+"\t"+items)
                    else
                        //장착
                        set items2 = Eitem[pid][9]
                        set Eitem[pid][9] = items
                        call DzFrameSetTexture(F_EItemButtonsBackDrop[9], GetItemArt(items), 0)
                        call DzFrameSetTexture(F_ArcanaButtonsBackDrop[3], GetItemArt(items), 0)
                        //교체
                        //set j = GetItemIDs(items2)
                        call AddIvItem.evaluate(pid, F_ItemClickNumber, items2)
                        set F_ItemClickNumber = 200
                        call DzSyncData("장착",I2S(pid)+"\t"+"9"+"\t"+items)
                    endif
                //카드
                elseif itemty == 10 then
                    if GetItemIDs(Eitem[pid][12]) == 0 then
                        //장착
                        set Eitem[pid][12] = items
                        //set i = GetItemIDs(items)
                        call DzFrameSetTexture(F_EItemButtonsBackDrop[12], GetItemArt(items), 0)
                        call DzFrameSetTexture(F_ArcanaButtonsBackDrop[5], GetItemArt(items), 0)
                        //인벤에서 제거
                        call RemoveItem2(pid, F_ItemClickNumber, false)
                        call DzFrameShow(UI_Tip, false)
                        set F_ItemClickNumber = 200
                        call DzSyncData("장착",I2S(pid)+"\t"+I2S(12)+"\t"+items)
                    else
                        //장착
                        set items2 = Eitem[pid][12]
                        set Eitem[pid][12] = items
                        //set i = GetItemIDs(items)
                        call DzFrameSetTexture(F_EItemButtonsBackDrop[12], GetItemArt(items), 0)
                        call DzFrameSetTexture(F_ArcanaButtonsBackDrop[5], GetItemArt(items), 0)
                        //교체
                        //set j = GetItemIDs(items2)
                        call AddIvItem.evaluate(pid, F_ItemClickNumber, items2)
                        set F_ItemClickNumber = 200
                        call DzSyncData("장착",I2S(pid)+"\t"+I2S(12)+"\t"+items)
                    endif
                else
                    if GetItemIDs(Eitem[pid][itemty]) == 0 then
                        //장착
                        set Eitem[pid][itemty] = items
                        //set i = GetItemIDs(items)
                        call DzFrameSetTexture(F_EItemButtonsBackDrop[itemty], GetItemArt(items), 0)
                        if itemty == 6 then
                            call DzFrameSetTexture(F_ArcanaButtonsBackDrop[0], GetItemArt(items), 0)
                        endif
                        //인벤에서 제거
                        call RemoveItem2(pid, F_ItemClickNumber, false)
                        call DzFrameShow(UI_Tip, false)
                        set F_ItemClickNumber = 200
                        call DzSyncData("장착",I2S(pid)+"\t"+I2S(itemty)+"\t"+items)
                    else
                        //장착
                        set items2 = Eitem[pid][itemty]
                        set Eitem[pid][itemty] = items
                        //set i = GetItemIDs(items)
                        call DzFrameSetTexture(F_EItemButtonsBackDrop[itemty], GetItemArt(items), 0)
                        if itemty == 6 then
                            call DzFrameSetTexture(F_ArcanaButtonsBackDrop[0], GetItemArt(items), 0)
                        endif
                        //교체
                        //set j = GetItemIDs(items2)
                        call AddIvItem.evaluate(pid, F_ItemClickNumber, items2)
                        set F_ItemClickNumber = 200
                        call DzSyncData("장착",I2S(pid)+"\t"+I2S(itemty)+"\t"+items)
                    endif
                endif
                call DzFrameShow(F_PickUp, false)
                set F_ItemClickNumber = 200
            endif
            
            if i == 2 then
                call DzFrameShow(F_PickUp, false)
                set F_ItemClickNumber = 200
            endif
            
            //장비템 창고로 이동
            if i == 3 then
                set i = 0
                set j = 50
                loop        
                    exitwhen i == 50
                    //비어있는 공간이 있음
                    if GetItemIDs(StashLoad(pid:PLAYER_DATA, "창고"+I2S(i), "0")) == 0 then
                        set j = i
                        set i = 49
                    endif
                    set i = i + 1
                endloop
                if j < 50 then
                    //인벤에서 제거
                    call RemoveItem2(pid, F_ItemClickNumber, false)
                    //창고에 추가
                    call AddStItem.evaluate(pid,j,items)
                    call DzFrameShow(UI_Tip, false)
                    set F_ItemClickNumber = 200
                endif
                call DzFrameShow(F_PickUp, false)
                set F_ItemClickNumber = 200
            //기타템 창고로 이동
            elseif i == 4 then
                set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(F_ItemClickNumber), "0")
                set i = 50
                set j = 0
                loop
                    exitwhen i == 100
                    //보유중
                    if GetItemIDs2(StashLoad(pid:PLAYER_DATA, "창고"+I2S(i), "0")) == GetItemIDs2(items) then
                        set k = GetItemCharge(items)
                        set j = GetItemCharge(StashLoad(pid:PLAYER_DATA, "창고"+I2S(i), "0"))
                        set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(i), "0")
                        //중첩변경
                        set items = SetItemCharge(items, j+k)
                        call AddStItem.evaluate(pid,i,items)
                        //제거
                        call RemoveItem2(pid, F_ItemClickNumber, false)
                        
                        call DzFrameShow(UI_Tip, false)
                        set F_ItemClickNumber = 200
                        
                        set k = 1
                        set i = 99
                    endif
                    set i = i + 1
                endloop
                //보유중이지않음
                if k == 1 then
                else
                    set i = 50
                    set j = 100
                    loop        
                        exitwhen i == 100
                        //비어있는 공간이 있음
                        if GetItemIDs(StashLoad(pid:PLAYER_DATA, "창고"+I2S(i), "0")) == 0 then
                            set j = i
                            set i = 99
                        endif
                        set i = i + 1
                    endloop
                    if j < 100 then
                        //인벤에서 제거
                        call RemoveItem2(pid, F_ItemClickNumber, false)
                        //창고에 추가
                        call AddStItem.evaluate(pid,j,items)
                        call DzFrameShow(UI_Tip, false)
                        set F_ItemClickNumber = 200
                    endif
                endif
                call DzFrameShow(F_PickUp, false)
                set F_ItemClickNumber = 200
            endif
            
            if i == 5 then
                set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(F_ItemClickNumber), "0")
                if GetItemIDs2(items) == "73" then
                    set SHOP_Select = items
                    call DzFrameSetTexture(SHOP_ButtonBackDrop[5],"ReplaceableTextures\\CommandButtons\\BTNArcana19.blp", 0)
                    call DzFrameSetText(SHOP_Much[0], " 1개 가격 : " + I2S(Price[0]))
                    call DzFrameSetText(SHOP_Much[1], "10개 가격 : " + I2S(Price[0]*10))
                endif
                if GetItemIDs2(items) == "74" then
                    set SHOP_Select = items
                    call DzFrameSetTexture(SHOP_ButtonBackDrop[5],"ReplaceableTextures\\CommandButtons\\BTNArcana20.blp", 0)
                    call DzFrameSetText(SHOP_Much[0], " 1개 가격 : " + I2S(Price[1]))
                    call DzFrameSetText(SHOP_Much[1], "10개 가격 : " + I2S(Price[1]*10))
                endif
                if GetItemIDs2(items) == "75" then
                    set SHOP_Select = items
                    call DzFrameSetTexture(SHOP_ButtonBackDrop[5],"ReplaceableTextures\\CommandButtons\\BTNArcana21.blp", 0)
                    call DzFrameSetText(SHOP_Much[0], " 1개 가격 : " + I2S(Price[2]))
                    call DzFrameSetText(SHOP_Much[1], "10개 가격 : " + I2S(Price[2]*10))
                endif
                if GetItemIDs2(items) == "76" then
                    set SHOP_Select = items
                    call DzFrameSetTexture(SHOP_ButtonBackDrop[5],"ReplaceableTextures\\CommandButtons\\BTNArcana12.blp", 0)
                    call DzFrameSetText(SHOP_Much[0], " 1개 가격 : " + I2S(Price[3]))
                    call DzFrameSetText(SHOP_Much[1], "10개 가격 : " + I2S(Price[3]*10))
                endif
                if GetItemIDs2(items) == "77" then
                    set SHOP_Select = items
                    call DzFrameSetTexture(SHOP_ButtonBackDrop[5],"ReplaceableTextures\\CommandButtons\\BTNArcana09.blp", 0)
                    call DzFrameSetText(SHOP_Much[0], " 1개 가격 : " + I2S(Price[4]))
                    call DzFrameSetText(SHOP_Much[1], "10개 가격 : " + I2S(Price[4]*10))
                endif
                call DzFrameShow(F_PickUp, false)
                set F_ItemClickNumber = 200
            endif
            
            if i == 6 then
                set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(F_ItemClickNumber), "0")
                if GetItemIDs2(items) == "73" then
                    set SHOP2_Select = items
                    call DzFrameSetTexture(SHOP_ButtonBackDrop[5],"ReplaceableTextures\\CommandButtons\\BTNArcana19.blp", 0)
                    call DzFrameSetText(SHOP2_Much[0], " 1개 가격 : " + I2S(SHOP2_MuchP[1]))
                    call DzFrameSetText(SHOP2_Much[1], "10개 가격 : " + I2S(SHOP2_MuchP[1]*10))
                endif
                if GetItemIDs2(items) == "74" then
                    set SHOP2_Select = items
                    call DzFrameSetTexture(SHOP_ButtonBackDrop[5],"ReplaceableTextures\\CommandButtons\\BTNArcana20.blp", 0)
                    call DzFrameSetText(SHOP2_Much[0], " 1개 가격 : " + I2S(SHOP2_MuchP[2]))
                    call DzFrameSetText(SHOP2_Much[1], "10개 가격 : " + I2S(SHOP2_MuchP[2]*10))
                endif
                if GetItemIDs2(items) == "75" then
                    set SHOP2_Select = items
                    call DzFrameSetTexture(SHOP_ButtonBackDrop[5],"ReplaceableTextures\\CommandButtons\\BTNArcana21.blp", 0)
                    call DzFrameSetText(SHOP2_Much[0], " 1개 가격 : " + I2S(SHOP2_MuchP[3]))
                    call DzFrameSetText(SHOP2_Much[1], "10개 가격 : " + I2S(SHOP2_MuchP[3]*10))
                endif
                if GetItemIDs2(items) == "76" then
                    set SHOP2_Select = items
                    call DzFrameSetTexture(SHOP_ButtonBackDrop[5],"ReplaceableTextures\\CommandButtons\\BTNArcana12.blp", 0)
                    call DzFrameSetText(SHOP2_Much[0], " 1개 가격 : " + I2S(SHOP2_MuchP[4]))
                    call DzFrameSetText(SHOP2_Much[1], "10개 가격 : " + I2S(SHOP2_MuchP[4]*10))
                endif
                if GetItemIDs2(items) == "77" then
                    set SHOP2_Select = items
                    call DzFrameSetTexture(SHOP_ButtonBackDrop[5],"ReplaceableTextures\\CommandButtons\\BTNArcana09.blp", 0)
                    call DzFrameSetText(SHOP2_Much[0], " 1개 가격 : " + I2S(SHOP2_MuchP[5]))
                    call DzFrameSetText(SHOP2_Much[1], "10개 가격 : " + I2S(SHOP2_MuchP[5]*10))
                endif
                call DzFrameShow(F_PickUp, false)
                set F_ItemClickNumber = 200
            endif
        else
            //템을 들고있음
            if PickUpOn == true then
                //장비
                if F_ItemClickNumber < 50 then
                    if selectnumber < 50 then
                        set items2 = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(F_ItemClickNumber), "0")
                        call RemoveItem2(pid, F_ItemClickNumber, false)
                        set F_ItemClickNumber = 200
                        call AddIvItem.evaluate(pid, selectnumber, items2)
                        call DzFrameShow(F_PickUp, false)
                    endif
                //기타
                elseif F_ItemClickNumber < 100 then
                    if selectnumber < 100 and selectnumber >= 50 then
                        set items2 = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(F_ItemClickNumber), "0")
                        call RemoveItem2(pid, F_ItemClickNumber, false)
                        call AddIvItem.evaluate(pid, selectnumber, items2)
                        call DzFrameShow(F_PickUp, false)
                        set F_ItemClickNumber = 200
                    endif
                //창고장비
                elseif (F_ItemClickNumber - 10000) < 50 and F_ItemClickNumber >= 10000 then
                    if selectnumber < 50 then
                        set items2 = StashLoad(pid:PLAYER_DATA, "창고"+I2S(F_ItemClickNumber-10000), "0")
                        call RemoveItem2(pid, F_ItemClickNumber - 10000, true)
                        call AddIvItem.evaluate(pid, selectnumber, items2)
                        call DzFrameShow(F_PickUp, false)
                        set F_ItemClickNumber = 200
                    endif
                //창고기타
                elseif ((F_ItemClickNumber - 10000) >= 50 and (F_ItemClickNumber - 10000) < 100) and F_ItemClickNumber >= 10000 then
                    if selectnumber < 100 and selectnumber >= 50 then
                        set items2 = StashLoad(pid:PLAYER_DATA, "창고"+I2S(F_ItemClickNumber-10000), "0")
                        call RemoveItem2(pid, F_ItemClickNumber - 10000, true)
                        call AddIvItem.evaluate(pid, selectnumber, items2)
                        call DzFrameShow(F_PickUp, false)
                        set F_ItemClickNumber = 200
                    endif
                endif
            endif
        endif

        call StopSound(gg_snd_MouseClick1, false, false)
        call StartSound(gg_snd_MouseClick1)
    endfunction
    
    private function ClickETCButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
    
        call DzFrameSetEnable(F_EQButtons,true)
        call DzFrameSetEnable(F_ETCButtons,false)
        
        call DzFrameShow(F_ETCButtonsShow,true)
        call DzFrameShow(F_EQButtonsShow,false)
        
        call StopSound(gg_snd_MouseClick1, false, false)
        call StartSound(gg_snd_MouseClick1)
    endfunction
    
    private function ClickEQButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        
        call DzFrameSetEnable(F_EQButtons,false)
        call DzFrameSetEnable(F_ETCButtons,true)
        
        call DzFrameShow(F_ETCButtonsShow,false)
        call DzFrameShow(F_EQButtonsShow,true)
        
        call StopSound(gg_snd_MouseClick1, false, false)
        call StartSound(gg_snd_MouseClick1)
    endfunction
    
    //창고 버튼 아이콘 생성 함수
    private function CreateStItemBackDrop takes integer types, real x, real y returns nothing
        set F_Storage_Buttons[types]=DzCreateFrameByTagName("BUTTON", "", F_Storage_EQButtonsShow, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetPoint(F_Storage_Buttons[types], JN_FRAMEPOINT_CENTER, F_Storage_EQBackDrop , JN_FRAMEPOINT_TOPLEFT, x, y)
        call DzFrameSetSize(F_Storage_Buttons[types], 0.025, 0.025)
        
        set F_Storage_ButtonsBackDrop[types]=DzCreateFrameByTagName("BACKDROP", "", F_Storage_Buttons[types], "", FrameCount())
        call DzFrameSetAllPoints(F_Storage_ButtonsBackDrop[types], F_Storage_Buttons[types])
        call DzFrameSetTexture(F_Storage_ButtonsBackDrop[types],"UI_Inventory.blp", 0)
        
        set F_Storage_ButtonLock[types]=DzCreateFrameByTagName("BACKDROP", "", F_Storage_ButtonsBackDrop[types], "template", FrameCount())
        call DzFrameSetSize(F_Storage_ButtonLock[types], 0.01, (19.0/ 16.0) * 0.01 )
        call DzFrameSetPoint(F_Storage_ButtonLock[types], 0, F_Storage_ButtonsBackDrop[types], 0, (( 28.0 / 16.0 ) * 0.01), (( 8.0 / 16.0 ) * 0.01)  )
        call DzFrameSetTexture(F_Storage_ButtonLock[types], "UI_Inventory_Lock2.blp", 0)
        call DzFrameShow(F_Storage_ButtonLock[types], false)

        call SaveInteger(Hash, F_Storage_Buttons[types], StringHash("number"), types+10000)

        call DzFrameSetScriptByCode(F_Storage_Buttons[types], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_ActionsSt, false)
        call DzFrameSetScriptByCode(F_Storage_Buttons[types], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_ActionsSt, false)
        call DzFrameSetScriptByCode(F_Storage_Buttons[types], JN_FRAMEEVENT_MOUSE_UP, function ClickStItemButton, false)

        set F_Storage_Buttons[types+50]=DzCreateFrameByTagName("BUTTON", "", F_Storage_ETCButtonsShow, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetPoint(F_Storage_Buttons[types+50], JN_FRAMEPOINT_CENTER, F_Storage_EQBackDrop , JN_FRAMEPOINT_TOPLEFT, x, y)
        call DzFrameSetSize(F_Storage_Buttons[types+50], 0.025, 0.025)
        
        set F_Storage_ButtonsBackDrop[types+50]=DzCreateFrameByTagName("BACKDROP", "", F_Storage_Buttons[types+50], "", FrameCount())
        call DzFrameSetAllPoints(F_Storage_ButtonsBackDrop[types+50], F_Storage_Buttons[types+50])
        call DzFrameSetTexture(F_Storage_ButtonsBackDrop[types+50],"UI_Inventory.blp", 0)

        call SaveInteger(Hash, F_Storage_Buttons[types+50], StringHash("number"), types+50)

        call DzFrameSetScriptByCode(F_Storage_Buttons[types+50], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_ActionsSt2, false)
        call DzFrameSetScriptByCode(F_Storage_Buttons[types+50], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_ActionsSt, false)
        call DzFrameSetScriptByCode(F_Storage_Buttons[types+50], JN_FRAMEEVENT_MOUSE_UP, function ClickStItemButton, false)

    endfunction
    
    //버튼 아이콘 생성 함수
    private function CreateItemButton takes integer types, real x, real y returns nothing
        set F_ItemButtons[types]=DzCreateFrameByTagName("BUTTON", "", F_EQButtonsShow, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetPoint(F_ItemButtons[types], JN_FRAMEPOINT_CENTER, F_EQETCTemplateBackDrop , JN_FRAMEPOINT_TOPLEFT, x, y)
        call DzFrameSetSize(F_ItemButtons[types], 0.025, 0.025)
        
        set F_ItemButtonsBackDrop[types]=DzCreateFrameByTagName("BACKDROP", "", F_ItemButtons[types], "", FrameCount())
        call DzFrameSetAllPoints(F_ItemButtonsBackDrop[types], F_ItemButtons[types])
        call DzFrameSetTexture(F_ItemButtonsBackDrop[types],"UI_Inventory.blp", 0)
        
        set F_ItemButtonLock[types]=DzCreateFrameByTagName("BACKDROP", "", F_ItemButtonsBackDrop[types], "template", FrameCount())
        call DzFrameSetSize(F_ItemButtonLock[types], 0.01, (19.0/ 16.0) * 0.01 )
        call DzFrameSetPoint(F_ItemButtonLock[types], 0, F_ItemButtonsBackDrop[types], 0, (( 28.0 / 16.0 ) * 0.01), (( 8.0 / 16.0 ) * 0.01)  )
        call DzFrameSetTexture(F_ItemButtonLock[types], "UI_Inventory_Lock2.blp", 0)
        call DzFrameShow(F_ItemButtonLock[types], false)

        call SaveInteger(Hash, F_ItemButtons[types], StringHash("number"), types)

        call DzFrameSetScriptByCode(F_ItemButtons[types], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions, false)
        call DzFrameSetScriptByCode(F_ItemButtons[types], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        call DzFrameSetScriptByCode(F_ItemButtons[types], JN_FRAMEEVENT_MOUSE_UP, function ClickItemButton, false)
        

        set F_ItemButtons[types+50]= DzCreateFrameByTagName("BUTTON", "", F_ETCButtonsShow, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetPoint(F_ItemButtons[types+50], JN_FRAMEPOINT_CENTER, F_EQETCTemplateBackDrop , JN_FRAMEPOINT_TOPLEFT, x, y)
        call DzFrameSetSize(F_ItemButtons[types+50], 0.025, 0.025)
        
        set F_ItemButtonsBackDrop[types+50]=DzCreateFrameByTagName("BACKDROP", "", F_ItemButtons[types+50], "", FrameCount())
        call DzFrameSetAllPoints(F_ItemButtonsBackDrop[types+50], F_ItemButtons[types+50])
        call DzFrameSetTexture(F_ItemButtonsBackDrop[types+50],"UI_Inventory.blp", 0)

        call SaveInteger(Hash, F_ItemButtons[types+50], StringHash("number"), types+50)

        call DzFrameSetScriptByCode(F_ItemButtons[types+50], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions2, false)
        call DzFrameSetScriptByCode(F_ItemButtons[types+50], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        call DzFrameSetScriptByCode(F_ItemButtons[types+50], JN_FRAMEEVENT_MOUSE_UP, function ClickItemButton, false)
    endfunction
    
    //버튼 아이콘 생성 함수
    private function CreateItemButton2 takes integer types, real x, real y returns nothing
        set F_ItemButtonsBackDrop[types+100]=DzCreateFrameByTagName("BACKDROP", "", F_ETC2emplateBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_ItemButtonsBackDrop[types+100], JN_FRAMEPOINT_CENTER, F_ETC2emplateBackDrop , JN_FRAMEPOINT_TOPLEFT, x, y)
        call DzFrameSetSize(F_ItemButtonsBackDrop[types+100], 0.025, 0.025)
        call DzFrameSetTexture(F_ItemButtonsBackDrop[types+100], "UI_Inventory.blp", 0)
        set F_ItemButtons[types+100]=DzCreateFrameByTagName("BUTTON", "", F_ETC2emplateBackDrop, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetScriptByCode(F_ItemButtons[types+100], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions2, false)
        call DzFrameSetScriptByCode(F_ItemButtons[types+100], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        call DzFrameSetAllPoints(F_ItemButtons[types+100], F_ItemButtonsBackDrop[types+100])
        call DzFrameSetSize(F_ItemButtons[types+100], 0.025, 0.025)
        call DzFrameSetScriptByCode(F_ItemButtons[types+100], JN_FRAMEEVENT_MOUSE_UP, function ClickItemButton, false)
        call SaveInteger(Hash, F_ItemButtons[types+100], StringHash("number"), types+100)
    endfunction
        
    //가지고 있는 장비 버튼 아이콘 생성 함수
    function AddIvItem takes integer pid, integer number, string items returns nothing
        local string s
        local string sn = I2S(PlayerSlotNumber[pid])
        if GetLocalPlayer() == Player(pid) then
            set s = GetItemArt(items)
            call StashSave(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(number), items)
            call DzFrameSetTexture(F_ItemButtonsBackDrop[number], s, 0)
            if number > 49 then
            else
                if GetItemLock(items) == 0 then
                    call DzFrameShow(F_ItemButtonLock[number], false)
                else
                    call DzFrameShow(F_ItemButtonLock[number], true)
                endif
            endif
        endif
    endfunction
    
    //가지고 있는 장비 버튼 아이콘 생성 함수
    function AddStItem takes integer pid, integer number, string items returns nothing
        local string s
        if GetLocalPlayer() == Player(pid) then
            set s = GetItemArt(items)
            call StashSave(pid:PLAYER_DATA, "창고"+I2S(number), items)
            call DzFrameSetTexture(F_Storage_ButtonsBackDrop[number], s, 0)
            if number > 49 then
            else
                if GetItemLock(items) == 0 then
                    call DzFrameShow(F_Storage_ButtonLock[number], false)
                else
                    call DzFrameShow(F_Storage_ButtonLock[number], true)
                endif
            endif
        endif
    endfunction
    
    private function Main takes nothing returns nothing
        local string s
        local integer i
        local trigger t
        local integer index

        call DzLoadToc("war3mapImported\\Templates.toc")
        call DzLoadToc("FDE Import.toc")
        call DzLoadToc("war3mapimported\\BoxedText.toc")
        
        set index = 0
        loop
            set F_ItemOnOff[index] = false
            set F_Storage_OnOff[index] = false
            set index = index + 1
            exitwhen index == 6
        endloop
        
        // 우클릭
        set t = CreateTrigger()
        call DzTriggerRegisterMouseEventByCode(t, JN_MOUSE_BUTTON_TYPE_MIDDLE, 0, false, function MouseRightClick)
        set t = null

        //가방 버튼 생성
        set F_ItemOpenButton = DzCreateFrameByTagName("GLUETEXTBUTTON", "", DzGetGameUI(), "template", FrameCount())
        call DzFrameSetAbsolutePoint(F_ItemOpenButton, JN_FRAMEPOINT_CENTER, 0.775, 0.020)
        call DzFrameSetSize(F_ItemOpenButton, 0.020, 0.020)
        call DzFrameSetScriptByCode(F_ItemOpenButton, JN_FRAMEEVENT_MOUSE_UP, function ShowMenu, false)
        set F_ItemOpenButtonBD=DzCreateFrameByTagName("BACKDROP", "", F_ItemOpenButton, "template", FrameCount())
        call DzFrameSetTexture(F_ItemOpenButtonBD, "inven.blp", 0)
        call DzFrameSetSize(F_ItemOpenButtonBD, 0.020, 0.020)
        call DzFrameSetAbsolutePoint(F_ItemOpenButtonBD, JN_FRAMEPOINT_CENTER, 0.775, 0.020)
        call DzFrameShow(F_ItemOpenButton, false)
        
        //메뉴 배경
        set F_ItemBackDrop=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "StandardEditBoxBackdropTemplate", 0)
        call DzFrameSetAbsolutePoint(F_ItemBackDrop, JN_FRAMEPOINT_CENTER, 0.60, 0.30)
        call DzFrameSetSize(F_ItemBackDrop, 0.35, 0.30)
        
        //장비탭 버튼 생성
        set F_EQButtons = DzCreateFrameByTagName("GLUETEXTBUTTON", "", F_ItemBackDrop, "ScriptDialogButton", 0)
        call DzFrameSetPoint(F_EQButtons, JN_FRAMEPOINT_CENTER, F_ItemBackDrop , JN_FRAMEPOINT_TOPLEFT, 0.035, -0.035)
        call DzFrameSetText(F_EQButtons, "|cffffffff장비")
        call DzFrameSetSize(F_EQButtons, 0.035, 0.0275)
        call DzFrameSetScriptByCode(F_EQButtons, JN_FRAMEEVENT_MOUSE_UP, function ClickEQButton, false)
        call DzFrameSetEnable(F_EQButtons,false)
        
        //기타탭 버튼 생성
        set F_ETCButtons = DzCreateFrameByTagName("GLUETEXTBUTTON", "", F_ItemBackDrop, "ScriptDialogButton", 0)
        call DzFrameSetPoint(F_ETCButtons, JN_FRAMEPOINT_CENTER, F_ItemBackDrop , JN_FRAMEPOINT_TOPLEFT, 0.070, -0.035)
        call DzFrameSetText(F_ETCButtons, "|cffffffff기타")
        call DzFrameSetSize(F_ETCButtons, 0.035, 0.0275)
        call DzFrameSetScriptByCode(F_ETCButtons, JN_FRAMEEVENT_MOUSE_UP, function ClickETCButton, false)
        
        //골드 아이콘
        set F_GoldBackDrop = DzCreateFrameByTagName("BACKDROP", "", F_ItemBackDrop, "template", FrameCount())
        call DzFrameSetTexture(F_GoldBackDrop, "UI\\Feedback\\Resources\\ResourceGold.blp", 0)
        call DzFrameSetPoint(F_GoldBackDrop, JN_FRAMEPOINT_CENTER, F_ItemBackDrop , JN_FRAMEPOINT_BOTTOMRIGHT, -0.100, 0.0175)
        call DzFrameSetSize(F_GoldBackDrop, 0.010, 0.010)
        set F_GoldText=DzCreateFrameByTagName("TEXT", "", F_GoldBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_GoldText, JN_FRAMEPOINT_TOPRIGHT, F_ItemBackDrop , JN_FRAMEPOINT_BOTTOMRIGHT, -0.015, 0.025)
        call DzFrameSetPoint(F_GoldText, JN_FRAMEPOINT_BOTTOMLEFT, F_ItemBackDrop , JN_FRAMEPOINT_BOTTOMRIGHT, -0.090, 0.010)
        call JNFrameSetTextAlignment(F_GoldText, JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_LEFT)
        call DzFrameSetText(F_GoldText, "0")
        
        //장비,기타 배경 버튼 생성
        set F_EQETCTemplateBackDrop=DzCreateFrameByTagName("BACKDROP", "", F_ItemBackDrop, "StandardEditBoxBackdropTemplate", 0)
        call DzFrameSetPoint(F_EQETCTemplateBackDrop, JN_FRAMEPOINT_TOPLEFT, F_ItemBackDrop , JN_FRAMEPOINT_TOPLEFT, 0.015, -0.050)
        call DzFrameSetPoint(F_EQETCTemplateBackDrop, JN_FRAMEPOINT_TOPRIGHT, F_ItemBackDrop , JN_FRAMEPOINT_TOPRIGHT, -0.015, -0.050)
        call DzFrameSetPoint(F_EQETCTemplateBackDrop, JN_FRAMEPOINT_BOTTOMLEFT, F_ItemBackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.015, 0.075)
        call DzFrameSetPoint(F_EQETCTemplateBackDrop, JN_FRAMEPOINT_BOTTOMRIGHT, F_ItemBackDrop , JN_FRAMEPOINT_BOTTOMRIGHT, -0.015, 0.075)
        
        
        set F_EQButtonsShow=DzCreateFrameByTagName("BACKDROP", "", F_EQETCTemplateBackDrop, "", FrameCount())
        set F_ETCButtonsShow=DzCreateFrameByTagName("BACKDROP", "", F_EQETCTemplateBackDrop, "", FrameCount())
        call DzFrameShow(F_ETCButtonsShow,false)
        
        //장비,기타 아이템 버튼 생성
        call CreateItemButton(0, 0.025, -0.0275)
        call CreateItemButton(1, 0.055, -0.0275)
        call CreateItemButton(2, 0.085, -0.0275)
        call CreateItemButton(3, 0.115, -0.0275)
        call CreateItemButton(4, 0.145, -0.0275)
        call CreateItemButton(5, 0.175, -0.0275)
        call CreateItemButton(6, 0.205, -0.0275)
        call CreateItemButton(7, 0.235, -0.0275)
        call CreateItemButton(8, 0.265, -0.0275)
        call CreateItemButton(9, 0.295, -0.0275)
        
        call CreateItemButton(10, 0.025, -0.0575)
        call CreateItemButton(11, 0.055, -0.0575)
        call CreateItemButton(12, 0.085, -0.0575)
        call CreateItemButton(13, 0.115, -0.0575)
        call CreateItemButton(14, 0.145, -0.0575)
        call CreateItemButton(15, 0.175, -0.0575)
        call CreateItemButton(16, 0.205, -0.0575)
        call CreateItemButton(17, 0.235, -0.0575)
        call CreateItemButton(18, 0.265, -0.0575)
        call CreateItemButton(19, 0.295, -0.0575)
        
        call CreateItemButton(20, 0.025, -0.0875)
        call CreateItemButton(21, 0.055, -0.0875)
        call CreateItemButton(22, 0.085, -0.0875)
        call CreateItemButton(23, 0.115, -0.0875)
        call CreateItemButton(24, 0.145, -0.0875)
        call CreateItemButton(25, 0.175, -0.0875)
        call CreateItemButton(26, 0.205, -0.0875)
        call CreateItemButton(27, 0.235, -0.0875)
        call CreateItemButton(28, 0.265, -0.0875)
        call CreateItemButton(29, 0.295, -0.0875)
    
        call CreateItemButton(30, 0.025, -0.1175)
        call CreateItemButton(31, 0.055, -0.1175)
        call CreateItemButton(32, 0.085, -0.1175)
        call CreateItemButton(33, 0.115, -0.1175)
        call CreateItemButton(34, 0.145, -0.1175)
        call CreateItemButton(35, 0.175, -0.1175)
        call CreateItemButton(36, 0.205, -0.1175)
        call CreateItemButton(37, 0.235, -0.1175)
        call CreateItemButton(38, 0.265, -0.1175)
        call CreateItemButton(39, 0.295, -0.1175)
    
        call CreateItemButton(40, 0.025, -0.1475)
        call CreateItemButton(41, 0.055, -0.1475)
        call CreateItemButton(42, 0.085, -0.1475)
        call CreateItemButton(43, 0.115, -0.1475)
        call CreateItemButton(44, 0.145, -0.1475)
        call CreateItemButton(45, 0.175, -0.1475)
        call CreateItemButton(46, 0.205, -0.1475)
        call CreateItemButton(47, 0.235, -0.1475)
        call CreateItemButton(48, 0.265, -0.1475)
        call CreateItemButton(49, 0.295, -0.1475)
        
        //소모품
        set F_ETC2emplateBackDrop=DzCreateFrameByTagName("BACKDROP", "", F_ItemBackDrop, "StandardEditBoxBackdropTemplate", 0)
        call DzFrameSetPoint(F_ETC2emplateBackDrop, JN_FRAMEPOINT_TOPLEFT, F_ItemBackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.015, 0.070)
        call DzFrameSetPoint(F_ETC2emplateBackDrop, JN_FRAMEPOINT_TOPRIGHT, F_ItemBackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.155, 0.070)
        call DzFrameSetPoint(F_ETC2emplateBackDrop, JN_FRAMEPOINT_BOTTOMLEFT, F_ItemBackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.015, 0.015)
        call DzFrameSetPoint(F_ETC2emplateBackDrop, JN_FRAMEPOINT_BOTTOMRIGHT, F_ItemBackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.155, 0.015)

        call CreateItemButton2(0, 0.025, -0.0275)
        call DzFrameSetTexture(F_ItemButtonsBackDrop[100], GetItemNumberArt(13), 0)
        call CreateItemButton2(1, 0.055, -0.0275)
        call DzFrameSetTexture(F_ItemButtonsBackDrop[101], GetItemNumberArt(14), 0)
        call CreateItemButton2(2, 0.085, -0.0275)
        call DzFrameSetTexture(F_ItemButtonsBackDrop[102], GetItemNumberArt(15), 0)
        call CreateItemButton2(3, 0.115, -0.0275)
        call DzFrameSetTexture(F_ItemButtonsBackDrop[103], GetItemNumberArt(16), 0)
        
        
        //메뉴 취소 버튼
        set F_ItemCancelButton = DzCreateFrameByTagName("GLUETEXTBUTTON", "", F_ItemBackDrop, "ScriptDialogButton", 0)
        call DzFrameSetPoint(F_ItemCancelButton, JN_FRAMEPOINT_TOPRIGHT, F_ItemBackDrop , JN_FRAMEPOINT_TOPRIGHT, -0.010, -0.010)
        call DzFrameSetText(F_ItemCancelButton, "X")
        call DzFrameSetSize(F_ItemCancelButton, 0.03, 0.03)
        call DzFrameSetScriptByCode(F_ItemCancelButton, JN_FRAMEEVENT_MOUSE_UP, function ShowMenu, false)
        
        call DzFrameShow(F_ItemBackDrop, false)
        
        //창고
        //메뉴 배경
        set F_Storage_BackDrop=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "StandardEditBoxBackdropTemplate", 0)
        call DzFrameSetAbsolutePoint(F_Storage_BackDrop, JN_FRAMEPOINT_CENTER, 0.225, 0.325)
        call DzFrameSetSize(F_Storage_BackDrop, 0.35, 0.25)
        
        //장비탭 버튼 생성
        set F_Storage_EQButtons = DzCreateFrameByTagName("GLUETEXTBUTTON", "", F_Storage_BackDrop, "ScriptDialogButton", 0)
        call DzFrameSetPoint(F_Storage_EQButtons, JN_FRAMEPOINT_CENTER, F_Storage_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.035, -0.035)
        call DzFrameSetText(F_Storage_EQButtons, "|cffffffff장비")
        call DzFrameSetSize(F_Storage_EQButtons, 0.035, 0.0275)
        call DzFrameSetScriptByCode(F_Storage_EQButtons, JN_FRAMEEVENT_MOUSE_UP, function StorageClickEQButton, false)
        call DzFrameSetEnable(F_Storage_EQButtons,false)
        
        //기타탭 버튼 생성
        set F_Storage_ETCButtons = DzCreateFrameByTagName("GLUETEXTBUTTON", "", F_Storage_BackDrop, "ScriptDialogButton", 0)
        call DzFrameSetPoint(F_Storage_ETCButtons, JN_FRAMEPOINT_CENTER, F_Storage_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.070, -0.035)
        call DzFrameSetText(F_Storage_ETCButtons, "|cffffffff기타")
        call DzFrameSetSize(F_Storage_ETCButtons, 0.035, 0.0275)
        call DzFrameSetScriptByCode(F_Storage_ETCButtons, JN_FRAMEEVENT_MOUSE_UP, function StorageClickETCButton, false)
        
        //장비,기타 배경 버튼 생성
        set F_Storage_EQBackDrop=DzCreateFrameByTagName("BACKDROP", "", F_Storage_BackDrop, "StandardEditBoxBackdropTemplate", 0)
        call DzFrameSetPoint(F_Storage_EQBackDrop, JN_FRAMEPOINT_TOPLEFT, F_Storage_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.015, -0.050)
        call DzFrameSetPoint(F_Storage_EQBackDrop, JN_FRAMEPOINT_TOPRIGHT, F_Storage_BackDrop , JN_FRAMEPOINT_TOPRIGHT, -0.015, -0.050)
        call DzFrameSetPoint(F_Storage_EQBackDrop, JN_FRAMEPOINT_BOTTOMLEFT, F_Storage_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.015, 0.025)
        call DzFrameSetPoint(F_Storage_EQBackDrop, JN_FRAMEPOINT_BOTTOMRIGHT, F_Storage_BackDrop , JN_FRAMEPOINT_BOTTOMRIGHT, -0.015, 0.025)
        
        
        set F_Storage_EQButtonsShow=DzCreateFrameByTagName("BACKDROP", "", F_Storage_EQBackDrop, "", FrameCount())
        set F_Storage_ETCButtonsShow=DzCreateFrameByTagName("BACKDROP", "", F_Storage_EQBackDrop, "", FrameCount())
        call DzFrameShow(F_Storage_ETCButtonsShow,false)
        
        //장비,기타 아이템 버튼 생성
        call CreateStItemBackDrop(0, 0.025, -0.0275)
        call CreateStItemBackDrop(1, 0.055, -0.0275)
        call CreateStItemBackDrop(2, 0.085, -0.0275)
        call CreateStItemBackDrop(3, 0.115, -0.0275)
        call CreateStItemBackDrop(4, 0.145, -0.0275)
        call CreateStItemBackDrop(5, 0.175, -0.0275)
        call CreateStItemBackDrop(6, 0.205, -0.0275)
        call CreateStItemBackDrop(7, 0.235, -0.0275)
        call CreateStItemBackDrop(8, 0.265, -0.0275)
        call CreateStItemBackDrop(9, 0.295, -0.0275)
        
        call CreateStItemBackDrop(10, 0.025, -0.0575)
        call CreateStItemBackDrop(11, 0.055, -0.0575)
        call CreateStItemBackDrop(12, 0.085, -0.0575)
        call CreateStItemBackDrop(13, 0.115, -0.0575)
        call CreateStItemBackDrop(14, 0.145, -0.0575)
        call CreateStItemBackDrop(15, 0.175, -0.0575)
        call CreateStItemBackDrop(16, 0.205, -0.0575)
        call CreateStItemBackDrop(17, 0.235, -0.0575)
        call CreateStItemBackDrop(18, 0.265, -0.0575)
        call CreateStItemBackDrop(19, 0.295, -0.0575)
        
        call CreateStItemBackDrop(20, 0.025, -0.0875)
        call CreateStItemBackDrop(21, 0.055, -0.0875)
        call CreateStItemBackDrop(22, 0.085, -0.0875)
        call CreateStItemBackDrop(23, 0.115, -0.0875)
        call CreateStItemBackDrop(24, 0.145, -0.0875)
        call CreateStItemBackDrop(25, 0.175, -0.0875)
        call CreateStItemBackDrop(26, 0.205, -0.0875)
        call CreateStItemBackDrop(27, 0.235, -0.0875)
        call CreateStItemBackDrop(28, 0.265, -0.0875)
        call CreateStItemBackDrop(29, 0.295, -0.0875)
    
        call CreateStItemBackDrop(30, 0.025, -0.1175)
        call CreateStItemBackDrop(31, 0.055, -0.1175)
        call CreateStItemBackDrop(32, 0.085, -0.1175)
        call CreateStItemBackDrop(33, 0.115, -0.1175)
        call CreateStItemBackDrop(34, 0.145, -0.1175)
        call CreateStItemBackDrop(35, 0.175, -0.1175)
        call CreateStItemBackDrop(36, 0.205, -0.1175)
        call CreateStItemBackDrop(37, 0.235, -0.1175)
        call CreateStItemBackDrop(38, 0.265, -0.1175)
        call CreateStItemBackDrop(39, 0.295, -0.1175)
    
        call CreateStItemBackDrop(40, 0.025, -0.1475)
        call CreateStItemBackDrop(41, 0.055, -0.1475)
        call CreateStItemBackDrop(42, 0.085, -0.1475)
        call CreateStItemBackDrop(43, 0.115, -0.1475)
        call CreateStItemBackDrop(44, 0.145, -0.1475)
        call CreateStItemBackDrop(45, 0.175, -0.1475)
        call CreateStItemBackDrop(46, 0.205, -0.1475)
        call CreateStItemBackDrop(47, 0.235, -0.1475)
        call CreateStItemBackDrop(48, 0.265, -0.1475)
        call CreateStItemBackDrop(49, 0.295, -0.1475)
        
        //메뉴 취소 버튼
        set F_Storage_CancelButton = DzCreateFrameByTagName("GLUETEXTBUTTON", "", F_Storage_BackDrop, "ScriptDialogButton", 0)
        call DzFrameSetPoint(F_Storage_CancelButton, JN_FRAMEPOINT_TOPRIGHT, F_Storage_BackDrop , JN_FRAMEPOINT_TOPRIGHT, -0.010, -0.010)
        call DzFrameSetText(F_Storage_CancelButton, "X")
        call DzFrameSetSize(F_Storage_CancelButton, 0.03, 0.03)
        call DzFrameSetScriptByCode(F_Storage_CancelButton, JN_FRAMEEVENT_MOUSE_UP, function StShowMenu, false)
        

        call DzFrameShow(F_Storage_BackDrop, false)

        //집은 아이템
        set F_PickUp = DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "template", FrameCount())
        call DzFrameSetSize(F_PickUp, 0.025, 0.025)
        call DzFrameShow(F_PickUp, false)

        // 우클릭 메뉴
        set F_RightMenu = DzCreateFrameByTagName("BACKDROP", "RightMenuBack", F_ItemBackDrop, "", FrameCount())
        call DzFrameSetSize(F_RightMenu, 0.02, 0.02)
        call DzFrameSetTexture(F_RightMenu, "Textures\\black32.blp", 0)
        call DzFrameSetPoint(DzCreateFrame("RightMenu1", F_RightMenu, 0), JN_FRAMEPOINT_TOPLEFT, F_RightMenu, JN_FRAMEPOINT_TOPLEFT, 0, 0)
        call DzFrameSetEnable(DzFrameFindByName("RightMenuText1", 0), false)
        call DzFrameSetEnable(DzFrameFindByName("RightMenuText2", 0), false)
        call DzFrameSetText(DzFrameFindByName("RightMenuText1", 0), "잠금")
        call DzFrameSetText(DzFrameFindByName("RightMenuText2", 0), "분해")
        call DzFrameSetAlpha(DzFrameFindByName("RightMenu1High", 0), 32)
        call DzFrameSetAlpha(DzFrameFindByName("RightMenu2High", 0), 32)
        call DzFrameSetScriptByCode(DzFrameFindByName("RightMenu1", 0), JN_FRAMEEVENT_CONTROL_CLICK, function ClickLockButton, false)
        call DzFrameSetScriptByCode(DzFrameFindByName("RightMenu2", 0), JN_FRAMEEVENT_CONTROL_CLICK, function ClickDELButton, false)

        
        // 일괄 분해 버튼 생성
        set F_ALLDLEButtons = DzCreateFrameByTagName("GLUETEXTBUTTON", "", F_ItemBackDrop, "ScriptDialogButton", 0)
        call DzFrameSetPoint(F_ALLDLEButtons, JN_FRAMEPOINT_CENTER, F_ItemBackDrop , JN_FRAMEPOINT_BOTTOMRIGHT, -0.050, 0.055)
        call DzFrameSetText(F_ALLDLEButtons, "|cffffffff일괄분해")
        call DzFrameSetSize(F_ALLDLEButtons,  0.070, 0.0275)
        call DzFrameSetScriptByCode(F_ALLDLEButtons, JN_FRAMEEVENT_MOUSE_UP, function ClickALLDELButton, false)
        
        //일괄분해
        set F_ItemALLDelBackDrop=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "StandardEditBoxBackdropTemplate", 0)
        call DzFrameSetAbsolutePoint(F_ItemALLDelBackDrop, JN_FRAMEPOINT_CENTER, 0.4, 0.325)
        call DzFrameSetSize(F_ItemALLDelBackDrop, 0.25, 0.10)
        call DzFrameShow(F_ItemALLDelBackDrop, false)
        call DzFrameSetPriority(F_ItemALLDelBackDrop, 198)
        
        set F_DELText=DzCreateFrameByTagName("TEXT", "", F_ItemALLDelBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_DELText, JN_FRAMEPOINT_CENTER, F_ItemALLDelBackDrop , JN_FRAMEPOINT_CENTER, 0.0, 0.0125)
        call DzFrameSetText(F_DELText, "장비를 전부 일괄 분해하시겠습니까?")
        
        set F_RDButtons = DzCreateFrameByTagName("GLUETEXTBUTTON", "", F_ItemALLDelBackDrop, "ScriptDialogButton", 0)
        call DzFrameSetPoint(F_RDButtons, JN_FRAMEPOINT_CENTER, F_ItemALLDelBackDrop , JN_FRAMEPOINT_CENTER, -0.035, -0.025)
        call DzFrameSetText(F_RDButtons, "분해")
        call DzFrameSetSize(F_RDButtons, 0.035, 0.0275)
        call DzFrameSetScriptByCode(F_RDButtons, JN_FRAMEEVENT_MOUSE_UP, function ClickDELButton5, false)
        
        set F_CLButtons = DzCreateFrameByTagName("GLUETEXTBUTTON", "", F_ItemALLDelBackDrop, "ScriptDialogButton", 0)
        call DzFrameSetPoint(F_CLButtons, JN_FRAMEPOINT_CENTER, F_ItemALLDelBackDrop , JN_FRAMEPOINT_CENTER, 0.035, -0.025)
        call DzFrameSetText(F_CLButtons, "취소")
        call DzFrameSetSize(F_CLButtons, 0.035, 0.0275)
        call DzFrameSetScriptByCode(F_CLButtons, JN_FRAMEEVENT_MOUSE_UP, function ClickDELButton4, false)

        //분해
        set F_ItemDelBackDrop=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "StandardEditBoxBackdropTemplate", 0)
        call DzFrameSetAbsolutePoint(F_ItemDelBackDrop, JN_FRAMEPOINT_CENTER, 0.4, 0.325)
        call DzFrameSetSize(F_ItemDelBackDrop, 0.25, 0.10)
        call DzFrameShow(F_ItemDelBackDrop, false)
        call DzFrameSetPriority(F_ItemDelBackDrop, 199)
        
        set F_DELText=DzCreateFrameByTagName("TEXT", "", F_ItemDelBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_DELText, JN_FRAMEPOINT_CENTER, F_ItemDelBackDrop , JN_FRAMEPOINT_CENTER, 0.0, 0.0125)
        call DzFrameSetText(F_DELText, "장비 분해")
        
        set F_RDButtons = DzCreateFrameByTagName("GLUETEXTBUTTON", "", F_ItemDelBackDrop, "ScriptDialogButton", 0)
        call DzFrameSetPoint(F_RDButtons, JN_FRAMEPOINT_CENTER, F_ItemDelBackDrop , JN_FRAMEPOINT_CENTER, -0.035, -0.025)
        call DzFrameSetText(F_RDButtons, "분해")
        call DzFrameSetSize(F_RDButtons, 0.035, 0.0275)
        call DzFrameSetScriptByCode(F_RDButtons, JN_FRAMEEVENT_MOUSE_UP, function ClickDELButton2, false)
        
        set F_CLButtons = DzCreateFrameByTagName("GLUETEXTBUTTON", "", F_ItemDelBackDrop, "ScriptDialogButton", 0)
        call DzFrameSetPoint(F_CLButtons, JN_FRAMEPOINT_CENTER, F_ItemDelBackDrop , JN_FRAMEPOINT_CENTER, 0.035, -0.025)
        call DzFrameSetText(F_CLButtons, "취소")
        call DzFrameSetSize(F_CLButtons, 0.035, 0.0275)
        call DzFrameSetScriptByCode(F_CLButtons, JN_FRAMEEVENT_MOUSE_UP, function ClickDELButton3, false)

        call DzFrameShow(F_ItemBackDrop, false)

    endfunction
    
    private function IKey takes nothing returns nothing
        local integer key = DzGetTriggerKey()
        local integer i = 0
        local integer j = GetPlayerId(DzGetTriggerKeyPlayer())
        
        if DzGetTriggerKeyPlayer()==GetLocalPlayer() then
            set i = JNMemoryGetByte(JNGetModuleHandle("Game.dll")+0xD04FEC)
        endif
        
        if i==1 then
        else
            if PickCheck[j] == true then
                if key == 'I' then
                    if F_ItemOnOff[j] == true then
                        call DzFrameShow(F_ItemBackDrop, false)
                        set F_ItemClickNumber = 200
                        set F_ItemOnOff[j] = false
                    else
                        call DzFrameShow(F_ItemBackDrop, true)
                        set F_ItemClickNumber = 200
                        set F_ItemOnOff[j] = true
                    endif
                endif
            endif
        endif
    endfunction
    
    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer index
        
        call TriggerRegisterTimerEventSingle( t, 3.0 )
        call TriggerAddAction( t, function Main )
        
        //I버튼으로 인벤토리 열기 및 닫기
        call DzTriggerRegisterKeyEventByCode(null, 'I', 0, false, function IKey)
        set t = null
    endfunction
endlibrary