library UIItem initializer Init requires DataItem, StatsSet, UIShop, ITEM
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

        //집은 아이템
        integer F_PickUp

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
        //플레이어가 클릭한 창고 아이템 번호
        integer F_Storage_ClickNumber = 200
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

    private function PickUpItem takes nothing returns nothing
        local real r1
        local real r2
        
        if F_ItemClickNumber != 200 then
            set r1 = I2R(DzGetMouseXRelative()) / I2R(DzGetWindowWidth()) * 0.8 + 0.0025
            set r2 = I2R(DzGetWindowHeight() - 42 - DzGetMouseYRelative()) / I2R(DzGetWindowHeight() - 42) * 0.6
            call BJDebugMsg("X: "+ R2S(r1) + "|nY: "+ R2S(r2))
            call DzFrameSetAbsolutePoint(F_PickUp, JN_FRAMEPOINT_CENTER, r1, r2)
        else
            call DzFrameSetUpdateCallback("")
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
            //장비 0아이템아이디, 1강화수치, 2품질, 3특성, 4각인1, 5각인수치, 6각인2, 7각인수치, 8패널티각인, 9패널티각인수치, 10잠금
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
                set str = str + "|n|n|c005AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                set str = str + "  |cFFB9E2FA추가 피해|r +"
                set str = str + R2S(ItemWeaponQuality[quality]) + "%"
            elseif i == 6 then
                set str = str + "목걸이|n|n"
                //치신
                if cts == 1 then
                    set str = str + "|c005AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA치명|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                    set str = str + "|n  |cFFB9E2FA신속|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //치특
                elseif cts == 2 then
                    set str = str + "|c005AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA치명|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                    set str = str + "|n  |cFFB9E2FA특화|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //특신
                elseif cts == 3 then
                    set str = str + "|c005AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA특화|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                    set str = str + "|n  |cFFB9E2FA신속|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                endif
                //아르카나
                if GetItemCombat1Bonus2(items) + GetItemCombat2Bonus2(items) + GetItemCombatPenalty2(items) > 0 then
                    set str = str + "|n|n|c005AD2FF[ 아르카나 ]|r|n"
                    set str = str + "  [|cFFFFE400 " + ArcanaText[GetItemCombat1Bonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombat1Bonus2(items))
                    set str = str + "|n  [|cFFFFE400 " + ArcanaText[GetItemCombat2Bonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombat2Bonus2(items))
                    set str = str + "|n  [|cFFFF0000 " + ArcanaText[GetItemCombatPenalty(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombatPenalty2(items))
                endif
            elseif i == 7 then
                set str = str + "귀걸이|n|n"
                //치
                if cts == 1 then
                    set str = str + "|c005AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA치명|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //특
                elseif cts == 2 then
                    set str = str + "|c005AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA특화|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //신
                elseif cts == 3 then
                    set str = str + "|c005AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA신속|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                endif
                //아르카나
                if GetItemCombat1Bonus2(items) + GetItemCombat2Bonus2(items) + GetItemCombatPenalty2(items) > 0 then
                    set str = str + "|n|n|c005AD2FF[ 아르카나 ]|r|n"
                    set str = str + "  [|cFFFFE400 " + ArcanaText[GetItemCombat1Bonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombat1Bonus2(items))
                    set str = str + "|n  [|cFFFFE400 " + ArcanaText[GetItemCombat2Bonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombat2Bonus2(items))
                    set str = str + "|n  [|cFFFF0000 " + ArcanaText[GetItemCombatPenalty(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombatPenalty2(items))
                endif
            elseif i == 8 then
                set str = str + "반지|n|n"
                //치
                if cts == 1 then
                    set str = str + "|c005AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA치명|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //특
                elseif cts == 2 then
                    set str = str + "|c005AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA특화|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //신
                elseif cts == 3 then
                    set str = str + "|c005AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA신속|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                endif
                //아르카나
                if GetItemCombat1Bonus2(items) + GetItemCombat2Bonus2(items) + GetItemCombatPenalty2(items) > 0 then
                    set str = str + "|n|n|c005AD2FF[ 아르카나 ]|r|n"
                    set str = str + "  [|cFFFFE400 " + ArcanaText[GetItemCombat1Bonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombat1Bonus2(items))
                    set str = str + "|n  [|cFFFFE400 " + ArcanaText[GetItemCombat2Bonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombat2Bonus2(items))
                    set str = str + "|n  [|cFFFF0000 " + ArcanaText[GetItemCombatPenalty(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombatPenalty2(items))
                endif
            elseif i == 9 then
                set str = str + "팔찌|n"
            elseif i == 10 then
                set str = str + "카드|n|n"
                set str = str + "|n|cFFB9E2FA체력 + "
                set str = str + "0"
                //아르카나
                if GetItemCombat1Bonus2(items) + GetItemCombat2Bonus2(items) + GetItemCombatPenalty2(items) > 0 then
                    set str = str + "|n|n|c005AD2FF[ 아르카나 ]|r|n"
                    set str = str + "  [|cFFFFE400 " + ArcanaText[GetItemCombat1Bonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombat1Bonus2(items))
                    set str = str + "|n  [|cFFFFE400 " + ArcanaText[GetItemCombat2Bonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombat2Bonus2(items))
                    set str = str + "|n  [|cFFFF0000 " + ArcanaText[GetItemCombatPenalty(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombatPenalty2(items))
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
            set str = str + "|n|c005AD2FF[ 설명 ]|r|n"
            set str = str + "|cFFB9E2FA"+GetItemTip(items)+"|r|n"
            call DzFrameSetText(UI_Tip_Text[2], str)
        endif
    endfunction
    
    private function F_OFF_Actions takes nothing returns nothing
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
        
        set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(selectnumber), "0")
        
        set itemid = GetItemIDs(items)
        
        if itemid != 0 then
            call DzFrameShow(UI_Tip, true)
            call DzFrameSetText(UI_Tip_Text[1], GetItemNames(items) + "  "+ I2S(GetItemCharge(items))+"개" )
            if i == 1 then
                set str = "|cFFA5FA7D[ 종류 ]|r 소모품|n"
            else
                set str = "|cFFA5FA7D[ 종류 ]|r 재료|n"
            endif
            set str = str + "|n|c005AD2FF[ 설명 ]|r|n"
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

        set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(selectnumber), "0")
        
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
            //장비 0아이템아이디, 1강화수치, 2품질, 3특성, 4각인1, 5각인수치, 6각인2, 7각인수치, 8패널티각인, 9패널티각인수치, 10잠금
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
                set str = str + "|n|n|c005AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                set str = str + "  |cFFB9E2FA추가 피해|r +"
                set str = str + R2S(ItemWeaponQuality[quality]) + "%"
            elseif i == 6 then
                set str = str + "목걸이|n|n"
                //치신
                if cts == 1 then
                    set str = str + "|c005AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA치명|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                    set str = str + "|n  |cFFB9E2FA신속|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //치특
                elseif cts == 2 then
                    set str = str + "|c005AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA치명|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                    set str = str + "|n  |cFFB9E2FA특화|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //특신
                elseif cts == 3 then
                    set str = str + "|c005AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA특화|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                    set str = str + "|n  |cFFB9E2FA신속|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                endif
                //아르카나
                if GetItemCombat1Bonus2(items) + GetItemCombat2Bonus2(items) + GetItemCombatPenalty2(items) > 0 then
                    set str = str + "|n|n|c005AD2FF[ 아르카나 ]|r|n"
                    set str = str + "  [|cFFFFE400 " + ArcanaText[GetItemCombat1Bonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombat1Bonus2(items))
                    set str = str + "|n  [|cFFFFE400 " + ArcanaText[GetItemCombat2Bonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombat2Bonus2(items))
                    set str = str + "|n  [|cFFFF0000 " + ArcanaText[GetItemCombatPenalty(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombatPenalty2(items))
                endif
            elseif i == 7 then
                set str = str + "귀걸이|n|n"
                //치
                if cts == 1 then
                    set str = str + "|c005AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA치명|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //특
                elseif cts == 2 then
                    set str = str + "|c005AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA특화|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //신
                elseif cts == 3 then
                    set str = str + "|c005AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA신속|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                endif
                //아르카나
                if GetItemCombat1Bonus2(items) + GetItemCombat2Bonus2(items) + GetItemCombatPenalty2(items) > 0 then
                    set str = str + "|n|n|c005AD2FF[ 아르카나 ]|r|n"
                    set str = str + "  [|cFFFFE400 " + ArcanaText[GetItemCombat1Bonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombat1Bonus2(items))
                    set str = str + "|n  [|cFFFFE400 " + ArcanaText[GetItemCombat2Bonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombat2Bonus2(items))
                    set str = str + "|n  [|cFFFF0000 " + ArcanaText[GetItemCombatPenalty(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombatPenalty2(items))
                endif
            elseif i == 8 then
                set str = str + "반지|n|n"
                //치
                if cts == 1 then
                    set str = str + "|c005AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA치명|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //특
                elseif cts == 2 then
                    set str = str + "|c005AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA특화|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //신
                elseif cts == 3 then
                    set str = str + "|c005AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA신속|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                endif
                //아르카나
                if GetItemCombat1Bonus2(items) + GetItemCombat2Bonus2(items) + GetItemCombatPenalty2(items) > 0 then
                    set str = str + "|n|n|c005AD2FF[ 아르카나 ]|r|n"
                    set str = str + "  [|cFFFFE400 " + ArcanaText[GetItemCombat1Bonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombat1Bonus2(items))
                    set str = str + "|n  [|cFFFFE400 " + ArcanaText[GetItemCombat2Bonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombat2Bonus2(items))
                    set str = str + "|n  [|cFFFF0000 " + ArcanaText[GetItemCombatPenalty(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombatPenalty2(items))
                endif
            elseif i == 9 then
                set str = str + "팔찌|n"
            elseif i == 10 then
                set str = str + "카드|n|n"
                set str = str + "|n|cFFB9E2FA체력 + "
                set str = str + "0"
                //아르카나
                if GetItemCombat1Bonus2(items) + GetItemCombat2Bonus2(items) + GetItemCombatPenalty2(items) > 0 then
                    set str = str + "|n|n|c005AD2FF[ 아르카나 ]|r|n"
                    set str = str + "  [|cFFFFE400 " + ArcanaText[GetItemCombat1Bonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombat1Bonus2(items))
                    set str = str + "|n  [|cFFFFE400 " + ArcanaText[GetItemCombat2Bonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombat2Bonus2(items))
                    set str = str + "|n  [|cFFFF0000 " + ArcanaText[GetItemCombatPenalty(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombatPenalty2(items))
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
            set F_Storage_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = false
            set F_Storage_ClickNumber = 200
        else
            call DzFrameShow(F_Storage_BackDrop, true)
            set F_Storage_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = true
            set F_Storage_ClickNumber = 200
        endif
    endfunction
    
    private function ShowMenu takes nothing returns nothing
        //메뉴 버튼을 누르면 메뉴 버튼 비활설화 + 메뉴 배경 표시
        //다시 메뉴 버튼을 누르면 메뉴버튼 활성화 + 메뉴 배경 숨김
        if F_ItemOnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] == true then
            call DzFrameShow(F_ItemBackDrop, false)
            set F_ItemOnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = false
            set F_ItemClickNumber = 200
        else
            call DzFrameShow(F_ItemBackDrop, true)
            set F_ItemOnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = true
            set F_ItemClickNumber = 200
        endif
    endfunction

    private function ClickLockButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local integer i = F_ItemClickNumber
        local integer j = 0
        local string items
        local integer itemty = 0
        local string sn = I2S(PlayerSlotNumber[pid])
        //f: 트리거를 작동시킨 프레임(비동기화시에만 잡히니 주의.)

        if i != 200 then
            set F_ItemClickNumber = 200
            set j = GetItemLock(StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(i), "0"))
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(i), "0")
            if j == 0 then
                set items = SetItemLock(items, 1)
                call StashSave(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(i), items)
                call DzFrameShow(F_ItemButtonLock[i], true)
            elseif j == 1 then
                set itemty = GetItemTypes(items)
                if itemty == 6 or itemty == 7 or itemty == 8 then
                    set items = SetItemLock(items, 0)
                    call StashSave(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(i), items)
                    call DzFrameShow(F_ItemButtonLock[i], false)
                endif
            endif
        endif
    
        call StopSound(gg_snd_MouseClick1, false, false)
        call StartSound(gg_snd_MouseClick1)
    endfunction
    
    private function ClickStItemButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local string items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(F_Storage_ClickNumber), "0")
        local integer itemty = GetItemTypes(items)
        local integer i = 0
        local integer length
        local integer j = 0
        local integer k = 0
        local string sn = I2S(PlayerSlotNumber[pid])
        local integer selectnumber = LoadInteger(Hash, f, StringHash("number")) - 10000
        local real r1 = 0
        local real r2 = 0

        if F_Storage_ClickNumber == selectnumber then
            if selectnumber < 50 then
                set i = 1
            else
                set i = 2
            endif
            call DzFrameShow(F_PickUp, false)
        else
            set F_Storage_ClickNumber = selectnumber
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(F_Storage_ClickNumber), "0")
            // 좌표 바로 한 번 갱신하기
            call DzFrameShow(F_PickUp, true)
            call DzFrameSetTexture(F_PickUp, GetItemArt(items), 0)
            set r1 = I2R(DzGetMouseXRelative()) / I2R(DzGetWindowWidth()) * 0.8 + 0.0025
            set r2 = I2R(DzGetWindowHeight() - 42 - DzGetMouseYRelative()) / I2R(DzGetWindowHeight() - 42) * 0.6
            call DzFrameSetAbsolutePoint(F_PickUp, JN_FRAMEPOINT_CENTER, r1, r2)
            call DzFrameSetUpdateCallbackByCode(function PickUpItem)
        endif

        //장비템 창고에서 인벤으로 이동
        if i == 1 then
            set i = 0
            set j = 50
            loop        
                exitwhen i == 50
                //비어있는 공간이 있음
                if GetItemIDs(StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(i), "0")) == 0 then
                    set j = i
                    set i = 49
                endif
                set i = i + 1
            endloop
            if j < 50 then
                //창고에서 제거
                call DzFrameSetTexture(F_Storage_ButtonsBackDrop[F_Storage_ClickNumber], "UI_Inventory.blp", 0)
                call DzFrameShow(UI_Tip, false)
                call DzDestroyFrame(f)
                set F_Storage_Buttons[F_Storage_ClickNumber] = 0
                call StashRemove(pid:PLAYER_DATA, "창고"+I2S(F_Storage_ClickNumber))
                call DzFrameShow(F_Storage_ButtonLock[F_Storage_ClickNumber], false)
                //인벤에 추가
                call StashSave(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(j), items)
                call AddIvItem.evaluate(pid,j,items)
                set F_Storage_ClickNumber = 200
            endif
        //기타템 창고에서 인벤으로 이동
        elseif i == 2 then
            set i = 50
            set j = 0
            
            loop
                exitwhen i == 100
                //보유중
                if GetItemIDs2(StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(i), "0")) == GetItemIDs2(items) then
                    set k = GetItemCharge(items)
                    set j = GetItemCharge(StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(i), "0"))
                    set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(i), "0")
                    set items = SetItemCharge(items, j+k)
                    //중첩변경
                    call StashSave(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(i), items)
                    //제거
                    call DzFrameSetTexture(F_Storage_ButtonsBackDrop[F_Storage_ClickNumber], "UI_Inventory.blp", 0)
                    call DzFrameShow(UI_Tip, false)
                    call DzDestroyFrame(f)
                    set F_Storage_Buttons[F_Storage_ClickNumber] = 0
                    call StashRemove(pid:PLAYER_DATA, "창고"+I2S(F_Storage_ClickNumber))
                    call DzFrameShow(F_Storage_ButtonLock[F_Storage_ClickNumber], false)
                    
                    set F_Storage_ClickNumber = 200
                    
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
                    if GetItemIDs(StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(i), "0")) == 0 then
                        set j = i
                        set i = 99
                    endif
                    set i = i + 1
                endloop
                if j < 100 then
                    //창고에서 제거
                    call DzFrameSetTexture(F_Storage_ButtonsBackDrop[F_Storage_ClickNumber], "UI_Inventory.blp", 0)
                    call DzFrameShow(UI_Tip, false)
                    call DzDestroyFrame(f)
                    set F_Storage_Buttons[F_Storage_ClickNumber] = 0
                    call StashRemove(pid:PLAYER_DATA, "창고"+I2S(F_Storage_ClickNumber))
                    call DzFrameShow(F_Storage_ButtonLock[F_Storage_ClickNumber], false)
                    //인벤에 추가
                    call StashSave(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(j), items)
                    call AddIvItem.evaluate(pid,j,items)
                    set F_Storage_ClickNumber = 200
                endif
            endif
        endif
        
        call StopSound(gg_snd_MouseClick1, false, false)
        call StartSound(gg_snd_MouseClick1)
    endfunction
    
    private function ClickItemButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local string sn = I2S(PlayerSlotNumber[pid])
        local string items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(F_ItemClickNumber), "0")
        local string items2
        local integer length
        local integer itemty = GetItemTypes(items)
        local integer i = 0
        local integer j = 0
        local integer k = 0
        local integer etyid1
        local integer etyid2
        local integer selectnumber = LoadInteger(Hash, f, StringHash("number"))
        local real r1
        local real r2

        if F_ItemClickNumber == selectnumber then
            if selectnumber < 50 then
                set i = 1
            else
                set i = 2
            endif
            call DzFrameShow(F_PickUp, false)
        else
            set F_ItemClickNumber = selectnumber
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(F_ItemClickNumber), "0")
            call DzFrameShow(F_PickUp, true)
            call DzFrameSetTexture(F_PickUp, GetItemArt(items), 0)
            set r1 = I2R(DzGetMouseXRelative()) / I2R(DzGetWindowWidth()) * 0.8 + 0.0025
            set r2 = I2R(DzGetWindowHeight() - 42 - DzGetMouseYRelative()) / I2R(DzGetWindowHeight() - 42) * 0.6
            call DzFrameSetAbsolutePoint(F_PickUp, JN_FRAMEPOINT_CENTER, r1, r2)
            call DzFrameSetUpdateCallbackByCode(function PickUpItem)
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
        
        // 0모자, 1상의, 2하의, 3장갑, 4견갑, 5무기, 6목걸이, 7귀걸이, 8귀걸이, 9반지, 10반지, 11팔찌, 12어빌리티스톤
        
        //장착
        if i == 1 then
            if itemty == 7 then
                set etyid1 = GetItemIDs(Eitem[pid][7])
                set etyid2 = GetItemIDs(Eitem[pid][8])
                set i = GetItemIDs(items)
                if etyid1 == 0 then
                    //장착
                    set Eitem[pid][7] = items
                    call DzFrameSetTexture(F_EItemButtonsBackDrop[7], GetItemArt(items), 0)
                    //인벤에서 제거
                    call DzFrameSetTexture(F_ItemButtonsBackDrop[F_ItemClickNumber], "UI_Inventory.blp", 0)
                    call DzFrameShow(UI_Tip, false)
                    call DzDestroyFrame(F_ItemButtons[F_ItemClickNumber])
                    set F_ItemButtons[F_ItemClickNumber] = 0
                    call StashRemove(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(F_ItemClickNumber))
                    call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber], false)
                    set F_ItemClickNumber = 200
                    call DzSyncData("장착",I2S(pid)+"\t"+"7"+"\t"+items)
                    call VJDebugMsg("1 : "+I2S(pid))
                    call VJDebugMsg("2 : "+"7")
                    call VJDebugMsg("3 : "+items)
                elseif etyid2 == 0 then
                    //장착
                    set Eitem[pid][8] = items
                    call DzFrameSetTexture(F_EItemButtonsBackDrop[8], GetItemArt(items), 0)
                    //인벤에서 제거
                    call DzFrameSetTexture(F_ItemButtonsBackDrop[F_ItemClickNumber], "UI_Inventory.blp", 0)
                    call DzFrameShow(UI_Tip, false)
                    call DzDestroyFrame(f)
                    set F_ItemButtons[F_ItemClickNumber] = 0
                    call StashRemove(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(F_ItemClickNumber))
                    call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber], false)
                    set F_ItemClickNumber = 200
                    call DzSyncData("장착",I2S(pid)+"\t"+"8"+"\t"+items)
                else
                    //장착
                    set items2 = Eitem[pid][7]
                    set Eitem[pid][7] = items
                    call DzFrameSetTexture(F_EItemButtonsBackDrop[7], GetItemArt(items), 0)
                    //교체
                    set j = GetItemIDs(items2)
                    call DzFrameSetTexture(F_ItemButtonsBackDrop[F_ItemClickNumber], GetItemArt(items2), 0)
                    call StashSave(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(F_ItemClickNumber), items2)
                    if GetItemLock(items2) == 0 then
                        call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber], false)
                    else
                        call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber], true)
                    endif
                    set F_ItemClickNumber = 200
                    call DzSyncData("장착",I2S(pid)+"\t"+"7"+"\t"+items)
                endif
            elseif itemty == 8 then
                set etyid1 = GetItemIDs(Eitem[pid][9])
                set etyid2 = GetItemIDs(Eitem[pid][10])
                set i = GetItemIDs(items)
                if etyid1 == 0 then
                    //장착
                    set Eitem[pid][9] = items
                    call DzFrameSetTexture(F_EItemButtonsBackDrop[9], GetItemArt(items), 0)
                    //인벤에서 제거
                    call DzFrameSetTexture(F_ItemButtonsBackDrop[F_ItemClickNumber], "UI_Inventory.blp", 0)
                    call DzFrameShow(UI_Tip, false)
                    call DzDestroyFrame(f)
                    set F_ItemButtons[F_ItemClickNumber] = 0
                    call StashRemove(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(F_ItemClickNumber))
                    call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber], false)
                    set F_ItemClickNumber = 200
                    call DzSyncData("장착",I2S(pid)+"\t"+"9"+"\t"+items)
                elseif etyid2 == 0 then
                    //장착
                    set Eitem[pid][10] = items
                    call DzFrameSetTexture(F_EItemButtonsBackDrop[10], GetItemArt(items), 0)
                    //인벤에서 제거
                    call DzFrameSetTexture(F_ItemButtonsBackDrop[F_ItemClickNumber], "UI_Inventory.blp", 0)
                    call DzFrameShow(UI_Tip, false)
                    call DzDestroyFrame(f)
                    set F_ItemButtons[F_ItemClickNumber] = 0
                    call StashRemove(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(F_ItemClickNumber))
                    call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber], false)
                    set F_ItemClickNumber = 200
                    call DzSyncData("장착",I2S(pid)+"\t"+"10"+"\t"+items)
                else
                    //장착
                    set items2 = Eitem[pid][9]
                    set Eitem[pid][9] = items
                    call DzFrameSetTexture(F_EItemButtonsBackDrop[9], GetItemArt(items), 0)
                    //교체
                    set j = GetItemIDs(items2)
                    call DzFrameSetTexture(F_ItemButtonsBackDrop[F_ItemClickNumber], GetItemArt(items2), 0)
                    call StashSave(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(F_ItemClickNumber), items2)
                    if GetItemLock(items2) == 0 then
                        call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber], false)
                    else
                        call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber], true)
                    endif
                    set F_ItemClickNumber = 200
                    call DzSyncData("장착",I2S(pid)+"\t"+"9"+"\t"+items)
                endif
            elseif itemty == 10 then
                if GetItemIDs(Eitem[pid][12]) == 0 then
                    //장착
                    set Eitem[pid][12] = items
                    set i = GetItemIDs(items)
                    call DzFrameSetTexture(F_EItemButtonsBackDrop[12], GetItemArt(items), 0)
                    //인벤에서 제거
                    call DzFrameSetTexture(F_ItemButtonsBackDrop[F_ItemClickNumber], "UI_Inventory.blp", 0)
                    call DzFrameShow(UI_Tip, false)
                    call DzDestroyFrame(f)
                    set F_ItemButtons[F_ItemClickNumber] = 0
                    call StashRemove(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(F_ItemClickNumber))
                    call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber], false)
                    set F_ItemClickNumber = 200
                    call DzSyncData("장착",I2S(pid)+"\t"+I2S(12)+"\t"+items)
                else
                    //장착
                    set items2 = Eitem[pid][12]
                    set Eitem[pid][12] = items
                    set i = GetItemIDs(items)
                    call DzFrameSetTexture(F_EItemButtonsBackDrop[12], GetItemArt(items), 0)
                    //교체
                    set j = GetItemIDs(items2)
                    call DzFrameSetTexture(F_ItemButtonsBackDrop[F_ItemClickNumber], GetItemArt(items2), 0)
                    call StashSave(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(F_ItemClickNumber), items2)
                    if GetItemLock(items2) == 0 then
                        call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber], false)
                    else
                        call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber], true)
                    endif
                    set F_ItemClickNumber = 200
                    call DzSyncData("장착",I2S(pid)+"\t"+I2S(12)+"\t"+items)
                endif
            else
                if GetItemIDs(Eitem[pid][itemty]) == 0 then
                    //장착
                    set Eitem[pid][itemty] = items
                    set i = GetItemIDs(items)
                    call DzFrameSetTexture(F_EItemButtonsBackDrop[itemty], GetItemArt(items), 0)
                    //인벤에서 제거
                    call DzFrameSetTexture(F_ItemButtonsBackDrop[F_ItemClickNumber], "UI_Inventory.blp", 0)
                    call DzFrameShow(UI_Tip, false)
                    call DzDestroyFrame(f)
                    set F_ItemButtons[F_ItemClickNumber] = 0
                    call StashRemove(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(F_ItemClickNumber))
                    call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber], false)
                    set F_ItemClickNumber = 200
                    call DzSyncData("장착",I2S(pid)+"\t"+I2S(itemty)+"\t"+items)
                else
                    //장착
                    set items2 = Eitem[pid][itemty]
                    set Eitem[pid][itemty] = items
                    set i = GetItemIDs(items)
                    call DzFrameSetTexture(F_EItemButtonsBackDrop[itemty], GetItemArt(items), 0)
                    //교체
                    set j = GetItemIDs(items2)
                    call DzFrameSetTexture(F_ItemButtonsBackDrop[F_ItemClickNumber], GetItemArt(items2), 0)
                    call StashSave(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(F_ItemClickNumber), items2)
                    if GetItemLock(items2) == 0 then
                        call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber], false)
                    else
                        call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber], true)
                    endif
                    set F_ItemClickNumber = 200
                    call DzSyncData("장착",I2S(pid)+"\t"+I2S(itemty)+"\t"+items)
                endif
            endif
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
                call DzFrameSetTexture(F_ItemButtonsBackDrop[F_ItemClickNumber], "UI_Inventory.blp", 0)
                call DzFrameShow(UI_Tip, false)
                call DzDestroyFrame(f)
                set F_ItemButtons[F_ItemClickNumber] = 0
                call StashRemove(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(F_ItemClickNumber))
                call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber], false)
                //창고에 추가
                call StashSave(pid:PLAYER_DATA, "창고"+I2S(j), items)
                call AddStItem.evaluate(pid,j,items)
                set F_ItemClickNumber = 200
            endif
        //기타템 창고로 이동
        elseif i == 4 then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(F_ItemClickNumber), "0")
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
                    call StashSave(pid:PLAYER_DATA, "창고"+I2S(i), items)
                    //제거
                    call DzFrameSetTexture(F_ItemButtonsBackDrop[F_ItemClickNumber], "UI_Inventory.blp", 0)
                    call DzFrameShow(UI_Tip, false)
                    call DzDestroyFrame(f)
                    set F_ItemButtons[F_ItemClickNumber] = 0
                    call StashRemove(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(F_ItemClickNumber))
                    call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber], false)
                    
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
                    call DzFrameSetTexture(F_ItemButtonsBackDrop[F_ItemClickNumber], "UI_Inventory.blp", 0)
                    call DzFrameShow(UI_Tip, false)
                    call DzDestroyFrame(f)
                    set F_ItemButtons[F_ItemClickNumber] = 0
                    call StashRemove(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(F_ItemClickNumber))
                    call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber], false)
                    //창고에 추가
                    call StashSave(pid:PLAYER_DATA, "창고"+ I2S(j), items)
                    call AddStItem.evaluate(pid,j,items)
                    set F_ItemClickNumber = 200
                endif
            endif
        endif
        
        if i == 5 then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(F_ItemClickNumber), "0")
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
        endif
        
        if i == 6 then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(F_ItemClickNumber), "0")
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
        set F_Storage_ButtonsBackDrop[types]=DzCreateFrameByTagName("BACKDROP", "", F_Storage_EQButtonsShow, "", 0)
        call DzFrameSetPoint(F_Storage_ButtonsBackDrop[types], JN_FRAMEPOINT_CENTER, F_Storage_EQBackDrop , JN_FRAMEPOINT_TOPLEFT, x, y)
        call DzFrameSetSize(F_Storage_ButtonsBackDrop[types], 0.025, 0.025)
        call DzFrameSetTexture(F_Storage_ButtonsBackDrop[types], "UI_Inventory.blp", 0)
        
        set F_Storage_ButtonsBackDrop[types+50]=DzCreateFrameByTagName("BACKDROP", "", F_Storage_ETCButtonsShow, "", 0)
        call DzFrameSetPoint(F_Storage_ButtonsBackDrop[types+50], JN_FRAMEPOINT_CENTER, F_Storage_EQBackDrop , JN_FRAMEPOINT_TOPLEFT, x, y)
        call DzFrameSetSize(F_Storage_ButtonsBackDrop[types+50], 0.025, 0.025)
        call DzFrameSetTexture(F_Storage_ButtonsBackDrop[types+50], "UI_Inventory.blp", 0)
        
        set F_Storage_ButtonLock[types]=DzCreateFrameByTagName("BACKDROP", "", F_Storage_ButtonsBackDrop[types], "Template", 0)
        call DzFrameSetSize(F_Storage_ButtonLock[types], 0.01, (19.0/ 16.0) * 0.01 )
        call DzFrameSetPoint(F_Storage_ButtonLock[types], 0, F_Storage_ButtonsBackDrop[types], 0, (( 28.0 / 16.0 ) * 0.01), (( 8.0 / 16.0 ) * 0.01)  )
        call DzFrameSetTexture(F_Storage_ButtonLock[types], "UI_Inventory_Lock2.blp", 0)
        call DzFrameShow(F_Storage_ButtonLock[types], false)
    endfunction
    
    //버튼 아이콘 생성 함수
    private function CreateItemBackDrop takes integer types, real x, real y returns nothing
        set F_ItemButtonsBackDrop[types]=DzCreateFrameByTagName("BACKDROP", "", F_EQButtonsShow, "", 0)
        call DzFrameSetPoint(F_ItemButtonsBackDrop[types], JN_FRAMEPOINT_CENTER, F_EQETCTemplateBackDrop , JN_FRAMEPOINT_TOPLEFT, x, y)
        call DzFrameSetSize(F_ItemButtonsBackDrop[types], 0.025, 0.025)
        call DzFrameSetTexture(F_ItemButtonsBackDrop[types], "UI_Inventory.blp", 0)
        
        set F_ItemButtonsBackDrop[types+50]=DzCreateFrameByTagName("BACKDROP", "", F_ETCButtonsShow, "", 0)
        call DzFrameSetPoint(F_ItemButtonsBackDrop[types+50], JN_FRAMEPOINT_CENTER, F_EQETCTemplateBackDrop , JN_FRAMEPOINT_TOPLEFT, x, y)
        call DzFrameSetSize(F_ItemButtonsBackDrop[types+50], 0.025, 0.025)
        call DzFrameSetTexture(F_ItemButtonsBackDrop[types+50], "UI_Inventory.blp", 0)
        
        set F_ItemButtonLock[types]=DzCreateFrameByTagName("BACKDROP", "", F_ItemButtonsBackDrop[types], "template", 0)
        call DzFrameSetSize(F_ItemButtonLock[types], 0.01, (19.0/ 16.0) * 0.01 )
        call DzFrameSetPoint(F_ItemButtonLock[types], 0, F_ItemButtonsBackDrop[types], 0, (( 28.0 / 16.0 ) * 0.01), (( 8.0 / 16.0 ) * 0.01)  )
        call DzFrameSetTexture(F_ItemButtonLock[types], "UI_Inventory_Lock2.blp", 0)
        call DzFrameShow(F_ItemButtonLock[types], false)
    endfunction
    
    //버튼 아이콘 생성 함수
    private function CreateItemBackDrop2 takes integer types, real x, real y returns nothing
        set F_ItemButtonsBackDrop[types+100]=DzCreateFrameByTagName("BACKDROP", "", F_ETC2emplateBackDrop, "", 0)
        call DzFrameSetPoint(F_ItemButtonsBackDrop[types+100], JN_FRAMEPOINT_CENTER, F_ETC2emplateBackDrop , JN_FRAMEPOINT_TOPLEFT, x, y)
        call DzFrameSetSize(F_ItemButtonsBackDrop[types+100], 0.025, 0.025)
        call DzFrameSetTexture(F_ItemButtonsBackDrop[types+100], "UI_Inventory.blp", 0)
        set F_ItemButtons[types+100]=DzCreateFrameByTagName("BUTTON", "", F_ETC2emplateBackDrop, "ScoreScreenTabButtonTemplate", 0)
        call DzFrameSetScriptByCode(F_ItemButtons[types+100], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions2, false)
        call DzFrameSetScriptByCode(F_ItemButtons[types+100], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        call DzFrameSetAllPoints(F_ItemButtons[types+100], F_ItemButtonsBackDrop[types+100])
        call DzFrameSetSize(F_ItemButtons[types+100], 0.025, 0.025)
        call DzFrameSetScriptByCode(F_ItemButtons[types+100], JN_FRAMEEVENT_MOUSE_UP, function ClickItemButton, false)
    endfunction
        
    //가지고 있는 장비 버튼 아이콘 생성 함수
    function AddIvItem takes integer pid, integer number, string items returns nothing
        local string s
        local string sn = I2S(PlayerSlotNumber[pid])
        if GetLocalPlayer() == Player(pid) then
            set s = GetItemArt(items)
            if number > 49 then
                call StashSave(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(number), items)
                call DzFrameSetTexture(F_ItemButtonsBackDrop[number], s, 0)
                set F_ItemButtons[number]=DzCreateFrameByTagName("BUTTON", "", F_ETCButtonsShow, "ScoreScreenTabButtonTemplate", 0)
                call DzFrameSetScriptByCode(F_ItemButtons[number], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions2, false)
                call DzFrameSetScriptByCode(F_ItemButtons[number], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
            else
                call StashSave(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(number), items)
                call DzFrameSetTexture(F_ItemButtonsBackDrop[number], s, 0)
                set F_ItemButtons[number]=DzCreateFrameByTagName("BUTTON", "", F_EQButtonsShow, "ScoreScreenTabButtonTemplate", 0)
                call DzFrameSetScriptByCode(F_ItemButtons[number], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions, false)
                call DzFrameSetScriptByCode(F_ItemButtons[number], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
                
                if GetItemLock(items) == 0 then
                    call DzFrameShow(F_ItemButtonLock[number], false)
                else
                    call DzFrameShow(F_ItemButtonLock[number], true)
                endif
            endif
            call DzFrameSetAllPoints(F_ItemButtons[number], F_ItemButtonsBackDrop[number])
            call DzFrameSetSize(F_ItemButtons[number], 0.025, 0.025)
            call DzFrameSetScriptByCode(F_ItemButtons[number], JN_FRAMEEVENT_MOUSE_UP, function ClickItemButton, false)
            call SaveInteger(Hash, F_ItemButtons[number], StringHash("number"), number)
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
                set F_Storage_Buttons[number]=DzCreateFrameByTagName("BUTTON", "", F_Storage_ETCButtonsShow, "ScoreScreenTabButtonTemplate", 0)
                call DzFrameSetScriptByCode(F_Storage_Buttons[number], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_ActionsSt2, false)
                call DzFrameSetScriptByCode(F_Storage_Buttons[number], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
            else
                set F_Storage_Buttons[number]=DzCreateFrameByTagName("BUTTON", "", F_Storage_EQButtonsShow, "ScoreScreenTabButtonTemplate", 0)
                call DzFrameSetScriptByCode(F_Storage_Buttons[number], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_ActionsSt, false)
                call DzFrameSetScriptByCode(F_Storage_Buttons[number], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
                
                if GetItemLock(items) == 0 then
                    call DzFrameShow(F_Storage_ButtonLock[number], false)
                else
                    call DzFrameShow(F_Storage_ButtonLock[number], true)
                endif
            endif
            call DzFrameSetAllPoints(F_Storage_Buttons[number], F_Storage_ButtonsBackDrop[number])
            call DzFrameSetSize(F_Storage_Buttons[number], 0.025, 0.025)
            call DzFrameSetScriptByCode(F_Storage_Buttons[number], JN_FRAMEEVENT_MOUSE_UP, function ClickStItemButton, false)
            call SaveInteger(Hash, F_Storage_Buttons[number], StringHash("number"), number+10000)
        endif
    endfunction
    
    private function Main takes nothing returns nothing
        local string s
        local integer i
        call DzLoadToc("war3mapImported\\Templates.toc")
        
        //가방 버튼 생성
        set F_ItemOpenButton = DzCreateFrameByTagName("GLUETEXTBUTTON", "", DzGetGameUI(), "template", 0)
        call DzFrameSetAbsolutePoint(F_ItemOpenButton, JN_FRAMEPOINT_CENTER, 0.775, 0.020)
        call DzFrameSetSize(F_ItemOpenButton, 0.020, 0.020)
        call DzFrameSetScriptByCode(F_ItemOpenButton, JN_FRAMEEVENT_MOUSE_UP, function ShowMenu, false)
        set F_ItemOpenButtonBD=DzCreateFrameByTagName("BACKDROP", "", F_ItemOpenButton, "template", 0)
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
        set F_GoldBackDrop = DzCreateFrameByTagName("BACKDROP", "", F_ItemBackDrop, "template", 0)
        call DzFrameSetTexture(F_GoldBackDrop, "UI\\Feedback\\Resources\\ResourceGold.blp", 0)
        call DzFrameSetPoint(F_GoldBackDrop, JN_FRAMEPOINT_CENTER, F_ItemBackDrop , JN_FRAMEPOINT_BOTTOMRIGHT, -0.100, 0.0175)
        call DzFrameSetSize(F_GoldBackDrop, 0.010, 0.010)
        set F_GoldText=DzCreateFrameByTagName("TEXT", "", F_GoldBackDrop, "", 0)
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
        
        
        set F_EQButtonsShow=DzCreateFrameByTagName("BACKDROP", "", F_EQETCTemplateBackDrop, "", 0)
        set F_ETCButtonsShow=DzCreateFrameByTagName("BACKDROP", "", F_EQETCTemplateBackDrop, "", 0)
        call DzFrameShow(F_ETCButtonsShow,false)
        
        //장비,기타 아이템 버튼 생성
        call CreateItemBackDrop(0, 0.025, -0.0275)
        call CreateItemBackDrop(1, 0.055, -0.0275)
        call CreateItemBackDrop(2, 0.085, -0.0275)
        call CreateItemBackDrop(3, 0.115, -0.0275)
        call CreateItemBackDrop(4, 0.145, -0.0275)
        call CreateItemBackDrop(5, 0.175, -0.0275)
        call CreateItemBackDrop(6, 0.205, -0.0275)
        call CreateItemBackDrop(7, 0.235, -0.0275)
        call CreateItemBackDrop(8, 0.265, -0.0275)
        call CreateItemBackDrop(9, 0.295, -0.0275)
        
        call CreateItemBackDrop(10, 0.025, -0.0575)
        call CreateItemBackDrop(11, 0.055, -0.0575)
        call CreateItemBackDrop(12, 0.085, -0.0575)
        call CreateItemBackDrop(13, 0.115, -0.0575)
        call CreateItemBackDrop(14, 0.145, -0.0575)
        call CreateItemBackDrop(15, 0.175, -0.0575)
        call CreateItemBackDrop(16, 0.205, -0.0575)
        call CreateItemBackDrop(17, 0.235, -0.0575)
        call CreateItemBackDrop(18, 0.265, -0.0575)
        call CreateItemBackDrop(19, 0.295, -0.0575)
        
        call CreateItemBackDrop(20, 0.025, -0.0875)
        call CreateItemBackDrop(21, 0.055, -0.0875)
        call CreateItemBackDrop(22, 0.085, -0.0875)
        call CreateItemBackDrop(23, 0.115, -0.0875)
        call CreateItemBackDrop(24, 0.145, -0.0875)
        call CreateItemBackDrop(25, 0.175, -0.0875)
        call CreateItemBackDrop(26, 0.205, -0.0875)
        call CreateItemBackDrop(27, 0.235, -0.0875)
        call CreateItemBackDrop(28, 0.265, -0.0875)
        call CreateItemBackDrop(29, 0.295, -0.0875)
    
        call CreateItemBackDrop(30, 0.025, -0.1175)
        call CreateItemBackDrop(31, 0.055, -0.1175)
        call CreateItemBackDrop(32, 0.085, -0.1175)
        call CreateItemBackDrop(33, 0.115, -0.1175)
        call CreateItemBackDrop(34, 0.145, -0.1175)
        call CreateItemBackDrop(35, 0.175, -0.1175)
        call CreateItemBackDrop(36, 0.205, -0.1175)
        call CreateItemBackDrop(37, 0.235, -0.1175)
        call CreateItemBackDrop(38, 0.265, -0.1175)
        call CreateItemBackDrop(39, 0.295, -0.1175)
    
        call CreateItemBackDrop(40, 0.025, -0.1475)
        call CreateItemBackDrop(41, 0.055, -0.1475)
        call CreateItemBackDrop(42, 0.085, -0.1475)
        call CreateItemBackDrop(43, 0.115, -0.1475)
        call CreateItemBackDrop(44, 0.145, -0.1475)
        call CreateItemBackDrop(45, 0.175, -0.1475)
        call CreateItemBackDrop(46, 0.205, -0.1475)
        call CreateItemBackDrop(47, 0.235, -0.1475)
        call CreateItemBackDrop(48, 0.265, -0.1475)
        call CreateItemBackDrop(49, 0.295, -0.1475)
        
        //소모품
        set F_ETC2emplateBackDrop=DzCreateFrameByTagName("BACKDROP", "", F_ItemBackDrop, "StandardEditBoxBackdropTemplate", 0)
        call DzFrameSetPoint(F_ETC2emplateBackDrop, JN_FRAMEPOINT_TOPLEFT, F_ItemBackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.015, 0.070)
        call DzFrameSetPoint(F_ETC2emplateBackDrop, JN_FRAMEPOINT_TOPRIGHT, F_ItemBackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.155, 0.070)
        call DzFrameSetPoint(F_ETC2emplateBackDrop, JN_FRAMEPOINT_BOTTOMLEFT, F_ItemBackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.015, 0.015)
        call DzFrameSetPoint(F_ETC2emplateBackDrop, JN_FRAMEPOINT_BOTTOMRIGHT, F_ItemBackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.155, 0.015)

        call CreateItemBackDrop2(0, 0.025, -0.0275)
        call DzFrameSetTexture(F_ItemButtonsBackDrop[100], GetItemNumberArt(13), 0)
        call CreateItemBackDrop2(1, 0.055, -0.0275)
        call DzFrameSetTexture(F_ItemButtonsBackDrop[101], GetItemNumberArt(14), 0)
        call CreateItemBackDrop2(2, 0.085, -0.0275)
        call DzFrameSetTexture(F_ItemButtonsBackDrop[102], GetItemNumberArt(15), 0)
        call CreateItemBackDrop2(3, 0.115, -0.0275)
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
        
        
        set F_Storage_EQButtonsShow=DzCreateFrameByTagName("BACKDROP", "", F_Storage_EQBackDrop, "", 0)
        set F_Storage_ETCButtonsShow=DzCreateFrameByTagName("BACKDROP", "", F_Storage_EQBackDrop, "", 0)
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
        set F_PickUp = DzCreateFrameByTagName("BACKDROP", "", F_ItemBackDrop, "template", 0)
        call DzFrameSetSize(F_PickUp, 0.025, 0.025)
        call DzFrameShow(F_PickUp, false)
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
        
        call TriggerRegisterTimerEventSingle( t, 0.1 )
        call TriggerAddAction( t, function Main )
        call DzLoadToc("war3mapimported\\BoxedText.toc")
        
        set index = 0
        loop
            set F_ItemOnOff[index] = false
            set F_Storage_OnOff[index] = false
            set index = index + 1
            exitwhen index == 6
        endloop

        
        //I버튼으로 인벤토리 열기 및 닫기
        set t = CreateTrigger()
        call DzTriggerRegisterKeyEventByCode(t, 'I', 0, false, function IKey)
        set t = null
    endfunction
endlibrary