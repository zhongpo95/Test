library UIItem initializer Init requires DataItem, StatsSet, UIShop, ITEM, FrameCount
    globals
        integer F_ItemOpenButtonBD                  //아이템창 여는 버튼 백드롭
        integer F_ItemOpenButton                    //아이템창 여는 버튼
        
        integer F_ItemBackDrop                      //메뉴 배경
        integer F_EQETCTemplateBackDrop             //장비,기타 표시 배경
        integer F_ETC2emplateBackDrop               //장비,기타 표시 배경
        integer F_ItemTemplateBackDrop              //아이템 조합법 표시하는 배경
        integer F_ItemDelBackDrop                   //아이템 파기 배경
        integer F_ItemALLDelBackDrop                //아이템 일괄 파기 배경
        
        integer F_ItemCancelButton                  //취소 버튼
        
        integer array F_EItemButtons                //장비아이템 버튼들
        integer array F_ItemButtons                 //아이템 버튼들
        integer F_EQButtons                         //장비탭 버튼
        integer F_ETCButtons                        //재료탭 버튼
        integer F_DLEButtons                        //파기 버튼
        integer F_ALLDLEButtons                     //일괄파기 버튼
        integer F_LOCKButtons                       //잠금 버튼
        integer F_RDButtons                         //진짜 파기 버튼
        integer F_CLButtons                         //파기 취소 버튼
        integer F_GoldBackDrop                      //골드 아이콘
        integer F_GoldText                          //골드 텍스트
        integer array F_ItemButtonsBackDrop         //아이템 버튼 배경 아이콘들
        integer array F_ItemButtonLock              //아이템 버튼 배경 아이콘들
        integer array F_EItemButtonsBackDrop        //장비 아이템 버튼 배경 아이콘들
        integer F_EQButtonsShow                     //장비아이콘 버튼들 숨김
        integer F_ETCButtonsShow                    //장비 아이콘 버튼들 숨김
        integer F_DELText                           //장비 분해 설명
        integer F_ALLDELText                        //장비 분해 설명
        
        boolean array F_ItemOnOff                   //플레이어 온오프
        integer array F_ItemClickNumber             //플레이어가 클릭한 아이템 번호
        integer array F_ItemClickDelNumber          //플레이어가 파괴할 클릭한 아이템 번호
        
        boolean array F_Storage_OnOff               //플레이어 창고 온오프
        
        //string array Ivitem [13][104]             //인벤토리 아이템번호
        string array Eitem [13][20]                 //장착한 인벤토리 아이템번호
        
        //창고
        integer array F_Storage_Buttons             //창고 아이템 버튼들
        integer array F_Storage_ButtonsBackDrop     //아이템 버튼 배경 아이콘들
        integer array F_Storage_ButtonLock          //아이템 버튼 배경 아이콘들
        integer F_Storage_EQButtonsShow             //장비아이콘 버튼들 숨김
        integer F_Storage_ETCButtonsShow            //장비 아이콘 버튼들 숨김
        integer array F_Storage_ClickNumber         //플레이어가 클릭한 창고 아이템 번호
        //string array Stitem [13][104]               //창고 아이템번호
        integer F_Storage_BackDrop                  //메뉴 배경
        integer F_Storage_EQBackDrop                //장비,기타 표시 배경
        integer F_Storage_ETCBackDrop               //장비,기타 표시 배경
        integer F_Storage_CancelButton              //취소 버튼
        integer F_Storage_EQButtons                 //장비탭 버튼
        integer F_Storage_ETCButtons                //재료탭 버튼
    endglobals
    
    private function F_ON_ActionsSt takes nothing returns nothing
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
        
        if f ==  F_Storage_Buttons[0] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(0), "0")
        elseif f ==  F_Storage_Buttons[1] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(1), "0")
        elseif f ==  F_Storage_Buttons[2] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(2), "0")
        elseif f ==  F_Storage_Buttons[3] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(3), "0")
        elseif f ==  F_Storage_Buttons[4] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(4), "0")
        elseif f ==  F_Storage_Buttons[5] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(5), "0")
        elseif f ==  F_Storage_Buttons[6] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(6), "0")
        elseif f ==  F_Storage_Buttons[7] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(7), "0")
        elseif f ==  F_Storage_Buttons[8] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(8), "0")
        elseif f ==  F_Storage_Buttons[9] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(9), "0")
        elseif f ==  F_Storage_Buttons[10] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(10), "0")
        elseif f ==  F_Storage_Buttons[11] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(11), "0")
        elseif f ==  F_Storage_Buttons[12] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(12), "0")
        elseif f ==  F_Storage_Buttons[13] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(13), "0")
        elseif f ==  F_Storage_Buttons[14] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(14), "0")
        elseif f ==  F_Storage_Buttons[15] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(15), "0")
        elseif f ==  F_Storage_Buttons[16] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(16), "0")
        elseif f ==  F_Storage_Buttons[17] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(17), "0")
        elseif f ==  F_Storage_Buttons[18] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(18), "0")
        elseif f ==  F_Storage_Buttons[19] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(19), "0")
        elseif f ==  F_Storage_Buttons[20] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(20), "0")
        elseif f ==  F_Storage_Buttons[21] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(21), "0")
        elseif f ==  F_Storage_Buttons[22] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(22), "0")
        elseif f ==  F_Storage_Buttons[23] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(23), "0")
        elseif f ==  F_Storage_Buttons[24] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(24), "0")
        elseif f ==  F_Storage_Buttons[25] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(25), "0")
        elseif f ==  F_Storage_Buttons[26] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(26), "0")
        elseif f ==  F_Storage_Buttons[27] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(27), "0")
        elseif f ==  F_Storage_Buttons[28] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(28), "0")
        elseif f ==  F_Storage_Buttons[29] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(29), "0")
        elseif f ==  F_Storage_Buttons[30] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(30), "0")
        endif
        if f ==  F_Storage_Buttons[31] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(31), "0")
        elseif f ==  F_Storage_Buttons[32] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(32), "0")
        elseif f ==  F_Storage_Buttons[33] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(33), "0")
        elseif f ==  F_Storage_Buttons[34] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(34), "0")
        elseif f ==  F_Storage_Buttons[35] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(35), "0")
        elseif f ==  F_Storage_Buttons[36] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(36), "0")
        elseif f ==  F_Storage_Buttons[37] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(37), "0")
        elseif f ==  F_Storage_Buttons[38] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(38), "0")
        elseif f ==  F_Storage_Buttons[39] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(39), "0")
        elseif f ==  F_Storage_Buttons[40] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(40), "0")
        elseif f ==  F_Storage_Buttons[41] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(41), "0")
        elseif f ==  F_Storage_Buttons[42] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(42), "0")
        elseif f ==  F_Storage_Buttons[43] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(43), "0")
        elseif f ==  F_Storage_Buttons[44] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(44), "0")
        elseif f ==  F_Storage_Buttons[45] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(45), "0")
        elseif f ==  F_Storage_Buttons[46] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(46), "0")
        elseif f ==  F_Storage_Buttons[47] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(47), "0")
        elseif f ==  F_Storage_Buttons[48] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(48), "0")
        elseif f ==  F_Storage_Buttons[49] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(49), "0")
        endif
        
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
                //치특
                elseif cts == 2 then
                    set str = str + "|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA치명|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                    set str = str + "|n  |cFFB9E2FA특화|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //특신
                elseif cts == 3 then
                    set str = str + "|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA특화|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                    set str = str + "|n  |cFFB9E2FA신속|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                endif
                //아르카나
                if GetItemCombatBonus2(items) + GetItemCombatPenalty2(items) > 0 then
                    set str = str + "|n|n|cff5AD2FF[ 아르카나 ]|r|n"
                    set str = str + "  [|cFFFFE400 " + ArcanaText[GetItemCombatBonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombatBonus2(items))
                    set str = str + "|n  [|cFFFFE400 " + ArcanaText[GetItemCombat2Bonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombat2Bonus2(items))
                    set str = str + "|n  [|cFFFF0000 " + ArcanaText[GetItemCombatPenalty(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombatPenalty2(items))
                endif
            elseif i == 7 then
                set str = str + "귀걸이|n|n"
                //치
                if cts == 1 then
                    set str = str + "|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA치명|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //특
                elseif cts == 2 then
                    set str = str + "|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA특화|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //신
                elseif cts == 3 then
                    set str = str + "|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA신속|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                endif
                //아르카나
                if GetItemCombatBonus2(items) + GetItemCombatPenalty2(items) > 0 then
                    set str = str + "|n|n|cff5AD2FF[ 아르카나 ]|r|n"
                    set str = str + "  [|cFFFFE400 " + ArcanaText[GetItemCombatBonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombatBonus2(items))
                    set str = str + "|n  [|cFFFFE400 " + ArcanaText[GetItemCombat2Bonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombat2Bonus2(items))
                    set str = str + "|n  [|cFFFF0000 " + ArcanaText[GetItemCombatPenalty(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombatPenalty2(items))
                endif
            elseif i == 8 then
                set str = str + "반지|n|n"
                //치
                if cts == 1 then
                    set str = str + "|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA치명|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //특
                elseif cts == 2 then
                    set str = str + "|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA특화|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //신
                elseif cts == 3 then
                    set str = str + "|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA신속|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                endif
                //아르카나
                if GetItemCombatBonus2(items) + GetItemCombatPenalty2(items) > 0 then
                    set str = str + "|n|n|cff5AD2FF[ 아르카나 ]|r|n"
                    set str = str + "  [|cFFFFE400 " + ArcanaText[GetItemCombatBonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombatBonus2(items))
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
                if GetItemCombatBonus2(items) + GetItemCombatPenalty2(items) > 0 then
                    set str = str + "|n|n|cff5AD2FF[ 아르카나 ]|r|n"
                    set str = str + "  [|cFFFFE400 " + ArcanaText[GetItemCombatBonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombatBonus2(items))
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
        
        if f ==  F_Storage_Buttons[50] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(50), "0")
        elseif f ==  F_Storage_Buttons[51] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(51), "0")
        elseif f ==  F_Storage_Buttons[52] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(52), "0")
        elseif f ==  F_Storage_Buttons[53] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(53), "0")
        elseif f ==  F_Storage_Buttons[54] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(54), "0")
        elseif f ==  F_Storage_Buttons[55] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(55), "0")
        elseif f ==  F_Storage_Buttons[56] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(56), "0")
        elseif f ==  F_Storage_Buttons[57] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(57), "0")
        elseif f ==  F_Storage_Buttons[58] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(58), "0")
        elseif f ==  F_Storage_Buttons[59] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(59), "0")
        elseif f ==  F_Storage_Buttons[60] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(60), "0")
        elseif f ==  F_Storage_Buttons[61] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(61), "0")
        elseif f ==  F_Storage_Buttons[62] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(62), "0")
        elseif f ==  F_Storage_Buttons[63] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(63), "0")
        elseif f ==  F_Storage_Buttons[64] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(64), "0")
        elseif f ==  F_Storage_Buttons[65] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(65), "0")
        elseif f ==  F_Storage_Buttons[66] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(66), "0")
        elseif f ==  F_Storage_Buttons[67] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(67), "0")
        elseif f ==  F_Storage_Buttons[68] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(68), "0")
        elseif f ==  F_Storage_Buttons[69] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(69), "0")
        elseif f ==  F_Storage_Buttons[70] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(70), "0")
        elseif f ==  F_Storage_Buttons[71] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(71), "0")
        elseif f ==  F_Storage_Buttons[72] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(72), "0")
        elseif f ==  F_Storage_Buttons[73] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(73), "0")
        elseif f ==  F_Storage_Buttons[74] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(74), "0")
        elseif f ==  F_Storage_Buttons[75] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(75), "0")
        elseif f ==  F_Storage_Buttons[76] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(76), "0")
        elseif f ==  F_Storage_Buttons[77] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(77), "0")
        elseif f ==  F_Storage_Buttons[78] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(78), "0")
        elseif f ==  F_Storage_Buttons[79] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(79), "0")
        elseif f ==  F_Storage_Buttons[80] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(80), "0")
        endif
        if f ==  F_Storage_Buttons[81] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(81), "0")
        elseif f ==  F_Storage_Buttons[82] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(82), "0")
        elseif f ==  F_Storage_Buttons[83] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(83), "0")
        elseif f ==  F_Storage_Buttons[84] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(84), "0")
        elseif f ==  F_Storage_Buttons[85] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(85), "0")
        elseif f ==  F_Storage_Buttons[86] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(86), "0")
        elseif f ==  F_Storage_Buttons[87] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(87), "0")
        elseif f ==  F_Storage_Buttons[88] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(88), "0")
        elseif f ==  F_Storage_Buttons[89] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(89), "0")
        elseif f ==  F_Storage_Buttons[90] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(90), "0")
        elseif f ==  F_Storage_Buttons[91] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(91), "0")
        elseif f ==  F_Storage_Buttons[92] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(92), "0")
        elseif f ==  F_Storage_Buttons[93] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(93), "0")
        elseif f ==  F_Storage_Buttons[94] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(94), "0")
        elseif f ==  F_Storage_Buttons[95] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(95), "0")
        elseif f ==  F_Storage_Buttons[96] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(96), "0")
        elseif f ==  F_Storage_Buttons[97] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(97), "0")
        elseif f ==  F_Storage_Buttons[98] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(98), "0")
        elseif f ==  F_Storage_Buttons[99] then
            set items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(99), "0")
        endif
        
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
        
        if f ==  F_ItemButtons[50] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(50), "0")
        elseif f ==  F_ItemButtons[51] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(51), "0")
        elseif f ==  F_ItemButtons[52] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(52), "0")
        elseif f ==  F_ItemButtons[53] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(53), "0")
        elseif f ==  F_ItemButtons[54] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(54), "0")
        elseif f ==  F_ItemButtons[55] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(55), "0")
        elseif f ==  F_ItemButtons[56] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(56), "0")
        elseif f ==  F_ItemButtons[57] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(57), "0")
        elseif f ==  F_ItemButtons[58] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(58), "0")
        elseif f ==  F_ItemButtons[59] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(59), "0")
        elseif f ==  F_ItemButtons[60] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(60), "0")
        elseif f ==  F_ItemButtons[61] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(61), "0")
        elseif f ==  F_ItemButtons[62] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(62), "0")
        elseif f ==  F_ItemButtons[63] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(63), "0")
        elseif f ==  F_ItemButtons[64] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(64), "0")
        elseif f ==  F_ItemButtons[65] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(65), "0")
        elseif f ==  F_ItemButtons[66] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(66), "0")
        elseif f ==  F_ItemButtons[67] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(67), "0")
        elseif f ==  F_ItemButtons[68] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(68), "0")
        elseif f ==  F_ItemButtons[69] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(69), "0")
        elseif f ==  F_ItemButtons[70] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(70), "0")
        elseif f ==  F_ItemButtons[71] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(71), "0")
        elseif f ==  F_ItemButtons[72] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(72), "0")
        elseif f ==  F_ItemButtons[73] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(73), "0")
        elseif f ==  F_ItemButtons[74] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(74), "0")
        elseif f ==  F_ItemButtons[75] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(75), "0")
        elseif f ==  F_ItemButtons[76] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(76), "0")
        elseif f ==  F_ItemButtons[77] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(77), "0")
        elseif f ==  F_ItemButtons[78] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(78), "0")
        elseif f ==  F_ItemButtons[79] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(79), "0")
        elseif f ==  F_ItemButtons[80] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(80), "0")
        endif
        if f ==  F_ItemButtons[81] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(81), "0")
        elseif f ==  F_ItemButtons[82] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(82), "0")
        elseif f ==  F_ItemButtons[83] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(83), "0")
        elseif f ==  F_ItemButtons[84] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(84), "0")
        elseif f ==  F_ItemButtons[85] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(85), "0")
        elseif f ==  F_ItemButtons[86] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(86), "0")
        elseif f ==  F_ItemButtons[87] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(87), "0")
        elseif f ==  F_ItemButtons[88] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(88), "0")
        elseif f ==  F_ItemButtons[89] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(89), "0")
        elseif f ==  F_ItemButtons[90] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(90), "0")
        elseif f ==  F_ItemButtons[91] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(91), "0")
        elseif f ==  F_ItemButtons[92] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(92), "0")
        elseif f ==  F_ItemButtons[93] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(93), "0")
        elseif f ==  F_ItemButtons[94] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(94), "0")
        elseif f ==  F_ItemButtons[95] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(95), "0")
        elseif f ==  F_ItemButtons[96] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(96), "0")
        elseif f ==  F_ItemButtons[97] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(97), "0")
        elseif f ==  F_ItemButtons[98] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(98), "0")
        elseif f ==  F_ItemButtons[99] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(99), "0")
        elseif f ==  F_ItemButtons[100] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".포션1", "0")
            set i = 1
        elseif f ==  F_ItemButtons[101] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".포션2", "0")
            set i = 1
        elseif f ==  F_ItemButtons[102] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".포션3", "0")
            set i = 1
        elseif f ==  F_ItemButtons[103] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".포션4", "0")
            set i = 1
        endif
        
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
        
        if f ==  F_ItemButtons[0] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(0), "0")
        elseif f ==  F_ItemButtons[1] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(1), "0")
        elseif f ==  F_ItemButtons[2] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(2), "0")
        elseif f ==  F_ItemButtons[3] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(3), "0")
        elseif f ==  F_ItemButtons[4] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(4), "0")
        elseif f ==  F_ItemButtons[5] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(5), "0")
        elseif f ==  F_ItemButtons[6] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(6), "0")
        elseif f ==  F_ItemButtons[7] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(7), "0")
        elseif f ==  F_ItemButtons[8] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(8), "0")
        elseif f ==  F_ItemButtons[9] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(9), "0")
        elseif f ==  F_ItemButtons[10] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(10), "0")
        elseif f ==  F_ItemButtons[11] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(11), "0")
        elseif f ==  F_ItemButtons[12] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(12), "0")
        elseif f ==  F_ItemButtons[13] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(13), "0")
        elseif f ==  F_ItemButtons[14] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(14), "0")
        elseif f ==  F_ItemButtons[15] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(15), "0")
        elseif f ==  F_ItemButtons[16] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(16), "0")
        elseif f ==  F_ItemButtons[17] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(17), "0")
        elseif f ==  F_ItemButtons[18] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(18), "0")
        elseif f ==  F_ItemButtons[19] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(19), "0")
        elseif f ==  F_ItemButtons[20] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(20), "0")
        elseif f ==  F_ItemButtons[21] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(21), "0")
        elseif f ==  F_ItemButtons[22] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(22), "0")
        elseif f ==  F_ItemButtons[23] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(23), "0")
        elseif f ==  F_ItemButtons[24] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(24), "0")
        elseif f ==  F_ItemButtons[25] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(25), "0")
        elseif f ==  F_ItemButtons[26] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(26), "0")
        elseif f ==  F_ItemButtons[27] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(27), "0")
        elseif f ==  F_ItemButtons[28] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(28), "0")
        elseif f ==  F_ItemButtons[29] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(29), "0")
        elseif f ==  F_ItemButtons[30] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(30), "0")
        endif
        if f ==  F_ItemButtons[31] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(31), "0")
        elseif f ==  F_ItemButtons[32] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(32), "0")
        elseif f ==  F_ItemButtons[33] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(33), "0")
        elseif f ==  F_ItemButtons[34] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(34), "0")
        elseif f ==  F_ItemButtons[35] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(35), "0")
        elseif f ==  F_ItemButtons[36] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(36), "0")
        elseif f ==  F_ItemButtons[37] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(37), "0")
        elseif f ==  F_ItemButtons[38] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(38), "0")
        elseif f ==  F_ItemButtons[39] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(39), "0")
        elseif f ==  F_ItemButtons[40] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(40), "0")
        elseif f ==  F_ItemButtons[41] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(41), "0")
        elseif f ==  F_ItemButtons[42] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(42), "0")
        elseif f ==  F_ItemButtons[43] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(43), "0")
        elseif f ==  F_ItemButtons[44] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(44), "0")
        elseif f ==  F_ItemButtons[45] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(45), "0")
        elseif f ==  F_ItemButtons[46] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(46), "0")
        elseif f ==  F_ItemButtons[47] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(47), "0")
        elseif f ==  F_ItemButtons[48] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(48), "0")
        elseif f ==  F_ItemButtons[49] then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(49), "0")
        endif
        
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
                //치특
                elseif cts == 2 then
                    set str = str + "|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA치명|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                    set str = str + "|n  |cFFB9E2FA특화|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //특신
                elseif cts == 3 then
                    set str = str + "|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA특화|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                    set str = str + "|n  |cFFB9E2FA신속|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                endif
                //아르카나
                if GetItemCombatBonus2(items) + GetItemCombatPenalty2(items) > 0 then
                    set str = str + "|n|n|cff5AD2FF[ 아르카나 ]|r|n"
                    set str = str + "  [|cFFFFE400 " + ArcanaText[GetItemCombatBonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombatBonus2(items))
                    set str = str + "|n  [|cFFFFE400 " + ArcanaText[GetItemCombat2Bonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombat2Bonus2(items))
                    set str = str + "|n  [|cFFFF0000 " + ArcanaText[GetItemCombatPenalty(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombatPenalty2(items))
                endif
            elseif i == 7 then
                set str = str + "귀걸이|n|n"
                //치
                if cts == 1 then
                    set str = str + "|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA치명|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //특
                elseif cts == 2 then
                    set str = str + "|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA특화|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //신
                elseif cts == 3 then
                    set str = str + "|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA신속|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                endif
                //아르카나
                if GetItemCombatBonus2(items) + GetItemCombatPenalty2(items) > 0 then
                    set str = str + "|n|n|cff5AD2FF[ 아르카나 ]|r|n"
                    set str = str + "  [|cFFFFE400 " + ArcanaText[GetItemCombatBonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombatBonus2(items))
                    set str = str + "|n  [|cFFFFE400 " + ArcanaText[GetItemCombat2Bonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombat2Bonus2(items))
                    set str = str + "|n  [|cFFFF0000 " + ArcanaText[GetItemCombatPenalty(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombatPenalty2(items))
                endif
            elseif i == 8 then
                set str = str + "반지|n|n"
                //치
                if cts == 1 then
                    set str = str + "|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA치명|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //특
                elseif cts == 2 then
                    set str = str + "|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA특화|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //신
                elseif cts == 3 then
                    set str = str + "|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA신속|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|cff5AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                endif
                //아르카나
                if GetItemCombatBonus2(items) + GetItemCombatPenalty2(items) > 0 then
                    set str = str + "|n|n|cff5AD2FF[ 아르카나 ]|r|n"
                    set str = str + "  [|cFFFFE400 " + ArcanaText[GetItemCombatBonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombatBonus2(items))
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
                if GetItemCombatBonus2(items) + GetItemCombatPenalty2(items) > 0 then
                    set str = str + "|n|n|cff5AD2FF[ 아르카나 ]|r|n"
                    set str = str + "  [|cFFFFE400 " + ArcanaText[GetItemCombatBonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombatBonus2(items))
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
            set F_Storage_ClickNumber[GetPlayerId(DzGetTriggerUIEventPlayer())] = 200
        else
            call DzFrameShow(F_Storage_BackDrop, true)
            set F_Storage_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = true
            set F_Storage_ClickNumber[GetPlayerId(DzGetTriggerUIEventPlayer())] = 200
        endif
    endfunction
    
    private function ShowMenu takes nothing returns nothing
        //메뉴 버튼을 누르면 메뉴 버튼 비활설화 + 메뉴 배경 표시
        //다시 메뉴 버튼을 누르면 메뉴버튼 활성화 + 메뉴 배경 숨김
        if F_ItemOnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] == true then
            call DzFrameShow(F_ItemBackDrop, false)
            call DzFrameShow(F_ItemDelBackDrop, false)
            call DzFrameShow(F_ItemALLDelBackDrop, false)
            set F_ItemOnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = false
            set F_ItemClickNumber[GetPlayerId(DzGetTriggerUIEventPlayer())] = 200
        else
            call DzFrameShow(F_ItemBackDrop, true)
            set F_ItemOnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = true
            set F_ItemClickNumber[GetPlayerId(DzGetTriggerUIEventPlayer())] = 200
        endif
    endfunction
    
    private function ClickALLDELButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())

        call DzFrameShow(F_ItemDelBackDrop, false)
        call DzFrameShow(F_ItemALLDelBackDrop, true)
        
        set F_ItemClickNumber[pid] = 200
        
        call StopSound(gg_snd_MouseClick1, false, false)
        call StartSound(gg_snd_MouseClick1)
    endfunction
    
    private function ClickDELButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local integer i = F_ItemClickNumber[pid]
        local string sn = I2S(PlayerSlotNumber[pid])
        //f: 트리거를 작동시킨 프레임(비동기화시에만 잡히니 주의.)

        call DzFrameShow(F_ItemALLDelBackDrop, false)
        
        if i != 200 then
            if i < 50 then
                if GetItemLock(StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(i), "0")) == 0 then
                    set F_ItemClickDelNumber[pid] = i
                    
                    call DzFrameSetText(F_DELText, GetItemNames(StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(i), "0"))+"을 분해하시겠습니까?")
                    call DzFrameShow(F_ItemDelBackDrop, true)
                else
                    set F_ItemClickNumber[pid] = 200
                endif
            endif
        endif
        
        call StopSound(gg_snd_MouseClick1, false, false)
        call StartSound(gg_snd_MouseClick1)
    endfunction
    
    private function ClickLockButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local integer i = F_ItemClickNumber[pid]
        local integer j = 0
        local string items
        local integer itemty = 0
        local string sn = I2S(PlayerSlotNumber[pid])
        //f: 트리거를 작동시킨 프레임(비동기화시에만 잡히니 주의.)

        if i != 200 then
            set F_ItemClickNumber[pid] = 200
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
    
    private function ClickDELButton2 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local integer i = F_ItemClickNumber[pid]
        local string sn = I2S(PlayerSlotNumber[pid])
        
        if i != 200 then
            if StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(F_ItemClickDelNumber[pid]), "0") != "0" and GetItemLock(StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(F_ItemClickDelNumber[pid]), "0")) == 0 then
                call DzFrameSetTexture(F_ItemButtonsBackDrop[F_ItemClickDelNumber[pid]], "UI_Inventory.blp", 0)
                call DzFrameShow(UI_Tip, false)
                call DzDestroyFrame(F_ItemButtons[F_ItemClickDelNumber[pid]])
                set F_ItemButtons[F_ItemClickDelNumber[pid]] = 0
                call StashRemove(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(F_ItemClickDelNumber[pid]))
            endif
        endif
        
        set F_ItemClickNumber[pid] = 200
        
        call DzFrameShow(F_ItemDelBackDrop, false)

        call StopSound(gg_snd_MouseClick1, false, false)
        call StartSound(gg_snd_MouseClick1)
    endfunction
    
    private function ClickDELButton5 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local integer i = 0
        local string sn = I2S(PlayerSlotNumber[pid])
        
        loop
            if StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(i), "0") != "" and GetItemLock(StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(i), "0")) == 0 then
                call DzFrameSetTexture(F_ItemButtonsBackDrop[i], "UI_Inventory.blp", 0)
                call DzFrameShow(UI_Tip, false)
                call DzDestroyFrame(F_ItemButtons[i])
                set F_ItemButtons[i] = 0
                call StashRemove(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(i))
            endif
            set i = i + 1
            exitwhen i == 50
        endloop
        
        set F_ItemClickNumber[pid] = 200
        
        call DzFrameShow(F_ItemALLDelBackDrop, false)

        call StopSound(gg_snd_MouseClick1, false, false)
        call StartSound(gg_snd_MouseClick1)
    endfunction
    
    private function ClickDELButton3 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        
        call DzFrameShow(F_ItemDelBackDrop, false)
    
        call StopSound(gg_snd_MouseClick1, false, false)
        call StartSound(gg_snd_MouseClick1)
    endfunction
    
    private function ClickDELButton4 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        
        call DzFrameShow(F_ItemALLDelBackDrop, false)
    
        call StopSound(gg_snd_MouseClick1, false, false)
        call StartSound(gg_snd_MouseClick1)
    endfunction
    
    private function ClickStItemButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local string items = StashLoad(pid:PLAYER_DATA, "창고"+I2S(F_Storage_ClickNumber[pid]), "0")
        local integer itemty = GetItemTypes(items)
        local integer i = 0
        local integer length
        local integer j = 0
        local integer k = 0
        local string sn = I2S(PlayerSlotNumber[pid])
        
        if f ==  F_Storage_Buttons[0] then
            if F_Storage_ClickNumber[pid] == 0 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 0
            endif
        elseif f ==  F_Storage_Buttons[1] then
            if F_Storage_ClickNumber[pid] == 1 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 1
            endif
        elseif f ==  F_Storage_Buttons[2] then
            if F_Storage_ClickNumber[pid] == 2 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 2
            endif
        elseif f ==  F_Storage_Buttons[3] then
            if F_Storage_ClickNumber[pid] == 3 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 3
            endif
        elseif f ==  F_Storage_Buttons[4] then
            if F_Storage_ClickNumber[pid] == 4 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 4
            endif
        elseif f ==  F_Storage_Buttons[5] then
            if F_Storage_ClickNumber[pid] == 5 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 5
            endif
        elseif f ==  F_Storage_Buttons[6] then
            if F_Storage_ClickNumber[pid] == 6 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 6
            endif
        elseif f ==  F_Storage_Buttons[7] then
            if F_Storage_ClickNumber[pid] == 7 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 7
            endif
        elseif f ==  F_Storage_Buttons[8] then
            if F_Storage_ClickNumber[pid] == 8 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 8
            endif
        elseif f ==  F_Storage_Buttons[9] then
            if F_Storage_ClickNumber[pid] == 9 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 9
            endif
        elseif f ==  F_Storage_Buttons[10] then
            if F_Storage_ClickNumber[pid] == 10 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 10
            endif
        elseif f ==  F_Storage_Buttons[11] then
            if F_Storage_ClickNumber[pid] == 11 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 11
            endif
        elseif f ==  F_Storage_Buttons[12] then
            if F_Storage_ClickNumber[pid] == 12 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 12
            endif
        elseif f ==  F_Storage_Buttons[13] then
            if F_Storage_ClickNumber[pid] == 13 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 13
            endif
        elseif f ==  F_Storage_Buttons[14] then
            if F_Storage_ClickNumber[pid] == 14 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 14
            endif
        elseif f ==  F_Storage_Buttons[15] then
            if F_Storage_ClickNumber[pid] == 15 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 15
            endif
        elseif f ==  F_Storage_Buttons[16] then
            if F_Storage_ClickNumber[pid] == 16 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 16
            endif
        elseif f ==  F_Storage_Buttons[17] then
            if F_Storage_ClickNumber[pid] == 17 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 17
            endif
        elseif f ==  F_Storage_Buttons[18] then
            if F_Storage_ClickNumber[pid] == 18 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 18
            endif
        elseif f ==  F_Storage_Buttons[19] then
            if F_Storage_ClickNumber[pid] == 19 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 19
            endif
        elseif f ==  F_Storage_Buttons[20] then
            if F_Storage_ClickNumber[pid] == 20 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 20
            endif
        elseif f ==  F_Storage_Buttons[21] then
            if F_Storage_ClickNumber[pid] == 21 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 21
            endif
        elseif f ==  F_Storage_Buttons[22] then
            if F_Storage_ClickNumber[pid] == 22 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 22
            endif
        elseif f ==  F_Storage_Buttons[23] then
            if F_Storage_ClickNumber[pid] == 23 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 23
            endif
        elseif f ==  F_Storage_Buttons[24] then
            if F_Storage_ClickNumber[pid] == 24 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 24
            endif
        elseif f ==  F_Storage_Buttons[25] then
            if F_Storage_ClickNumber[pid] == 25 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 25
            endif
        elseif f ==  F_Storage_Buttons[26] then
            if F_Storage_ClickNumber[pid] == 26 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 26
            endif
        elseif f ==  F_Storage_Buttons[27] then
            if F_Storage_ClickNumber[pid] == 27 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 27
            endif
        elseif f ==  F_Storage_Buttons[28] then
            if F_Storage_ClickNumber[pid] == 28 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 28
            endif
        elseif f ==  F_Storage_Buttons[29] then
            if F_Storage_ClickNumber[pid] == 29 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 29
            endif
        elseif f ==  F_Storage_Buttons[30] then
            if F_Storage_ClickNumber[pid] == 30 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 30
            endif
        elseif f ==  F_Storage_Buttons[31] then
            if F_Storage_ClickNumber[pid] == 31 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 31
            endif
        elseif f ==  F_Storage_Buttons[32] then
            if F_Storage_ClickNumber[pid] == 32 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 32
            endif
        elseif f ==  F_Storage_Buttons[33] then
            if F_Storage_ClickNumber[pid] == 33 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 33
            endif
        elseif f ==  F_Storage_Buttons[34] then
            if F_Storage_ClickNumber[pid] == 34 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 34
            endif
        elseif f ==  F_Storage_Buttons[35] then
            if F_Storage_ClickNumber[pid] == 35 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 35
            endif
        elseif f ==  F_Storage_Buttons[36] then
            if F_Storage_ClickNumber[pid] == 36 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 36
            endif
        elseif f ==  F_Storage_Buttons[37] then
            if F_Storage_ClickNumber[pid] == 37 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 37
            endif
        elseif f ==  F_Storage_Buttons[38] then
            if F_Storage_ClickNumber[pid] == 38 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 38
            endif
        elseif f ==  F_Storage_Buttons[39] then
            if F_Storage_ClickNumber[pid] == 39 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 39
            endif
        elseif f ==  F_Storage_Buttons[40] then
            if F_Storage_ClickNumber[pid] == 40 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 40
            endif
        elseif f ==  F_Storage_Buttons[41] then
            if F_Storage_ClickNumber[pid] == 41 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 41
            endif
        elseif f ==  F_Storage_Buttons[42] then
            if F_Storage_ClickNumber[pid] == 42 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 42
            endif
        elseif f ==  F_Storage_Buttons[43] then
            if F_Storage_ClickNumber[pid] == 43 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 43
            endif
        elseif f ==  F_Storage_Buttons[44] then
            if F_Storage_ClickNumber[pid] == 44 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 44
            endif
        elseif f ==  F_Storage_Buttons[45] then
            if F_Storage_ClickNumber[pid] == 45 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 45
            endif
        elseif f ==  F_Storage_Buttons[46] then
            if F_Storage_ClickNumber[pid] == 46 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 46
            endif
        elseif f ==  F_Storage_Buttons[47] then
            if F_Storage_ClickNumber[pid] == 47 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 47
            endif
        elseif f ==  F_Storage_Buttons[48] then
            if F_Storage_ClickNumber[pid] == 48 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 48
            endif
        elseif f ==  F_Storage_Buttons[49] then
            if F_Storage_ClickNumber[pid] == 49 then
                set i = 1
            else
                set F_Storage_ClickNumber[pid] = 49
            endif
        elseif f ==  F_Storage_Buttons[50] then
            if F_Storage_ClickNumber[pid] == 50 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 50
            endif
        elseif f ==  F_Storage_Buttons[51] then
            if F_Storage_ClickNumber[pid] == 51 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 51
            endif
        elseif f ==  F_Storage_Buttons[52] then
            if F_Storage_ClickNumber[pid] == 52 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 52
            endif
        elseif f ==  F_Storage_Buttons[53] then
            if F_Storage_ClickNumber[pid] == 53 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 53
            endif
        elseif f ==  F_Storage_Buttons[54] then
            if F_Storage_ClickNumber[pid] == 54 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 54
            endif
        elseif f ==  F_Storage_Buttons[55] then
            if F_Storage_ClickNumber[pid] == 55 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 55
            endif
        elseif f ==  F_Storage_Buttons[56] then
            if F_Storage_ClickNumber[pid] == 56 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 56
            endif
        elseif f ==  F_Storage_Buttons[57] then
            if F_Storage_ClickNumber[pid] == 57 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 57
            endif
        elseif f ==  F_Storage_Buttons[58] then
            if F_Storage_ClickNumber[pid] == 58 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 58
            endif
        elseif f ==  F_Storage_Buttons[59] then
            if F_Storage_ClickNumber[pid] == 59 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 59
            endif
        elseif f ==  F_Storage_Buttons[60] then
            if F_Storage_ClickNumber[pid] == 60 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 60
            endif
        elseif f ==  F_Storage_Buttons[61] then
            if F_Storage_ClickNumber[pid] == 61 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 61
            endif
        elseif f ==  F_Storage_Buttons[62] then
            if F_Storage_ClickNumber[pid] == 62 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 62
            endif
        elseif f ==  F_Storage_Buttons[63] then
            if F_Storage_ClickNumber[pid] == 63 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 63
            endif
        elseif f ==  F_Storage_Buttons[64] then
            if F_Storage_ClickNumber[pid] == 64 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 64
            endif
        elseif f ==  F_Storage_Buttons[65] then
            if F_Storage_ClickNumber[pid] == 65 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 65
            endif
        elseif f ==  F_Storage_Buttons[66] then
            if F_Storage_ClickNumber[pid] == 66 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 66
            endif
        elseif f ==  F_Storage_Buttons[67] then
            if F_Storage_ClickNumber[pid] == 67 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 67
            endif
        elseif f ==  F_Storage_Buttons[68] then
            if F_Storage_ClickNumber[pid] == 68 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 68
            endif
        elseif f ==  F_Storage_Buttons[69] then
            if F_Storage_ClickNumber[pid] == 69 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 69
            endif
        elseif f ==  F_Storage_Buttons[70] then
            if F_Storage_ClickNumber[pid] == 70 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 70
            endif
        elseif f ==  F_Storage_Buttons[71] then
            if F_Storage_ClickNumber[pid] == 71 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 71
            endif
        elseif f ==  F_Storage_Buttons[72] then
            if F_Storage_ClickNumber[pid] == 72 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 72
            endif
        elseif f ==  F_Storage_Buttons[73] then
            if F_Storage_ClickNumber[pid] == 73 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 73
            endif
        elseif f ==  F_Storage_Buttons[74] then
            if F_Storage_ClickNumber[pid] == 74 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 74
            endif
        elseif f ==  F_Storage_Buttons[75] then
            if F_Storage_ClickNumber[pid] == 75 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 75
            endif
        elseif f ==  F_Storage_Buttons[76] then
            if F_Storage_ClickNumber[pid] == 76 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 76
            endif
        elseif f ==  F_Storage_Buttons[77] then
            if F_Storage_ClickNumber[pid] == 77 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 77
            endif
        elseif f ==  F_Storage_Buttons[78] then
            if F_Storage_ClickNumber[pid] == 78 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 78
            endif
        elseif f ==  F_Storage_Buttons[79] then
            if F_Storage_ClickNumber[pid] == 79 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 79
            endif
        elseif f ==  F_Storage_Buttons[80] then
            if F_Storage_ClickNumber[pid] == 80 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 80
            endif
        elseif f ==  F_Storage_Buttons[81] then
            if F_Storage_ClickNumber[pid] == 81 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 81
            endif
        elseif f ==  F_Storage_Buttons[82] then
            if F_Storage_ClickNumber[pid] == 82 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 82
            endif
        elseif f ==  F_Storage_Buttons[83] then
            if F_Storage_ClickNumber[pid] == 83 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 83
            endif
        elseif f ==  F_Storage_Buttons[84] then
            if F_Storage_ClickNumber[pid] == 84 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 84
            endif
        elseif f ==  F_Storage_Buttons[85] then
            if F_Storage_ClickNumber[pid] == 85 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 85
            endif
        elseif f ==  F_Storage_Buttons[86] then
            if F_Storage_ClickNumber[pid] == 86 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 86
            endif
        elseif f ==  F_Storage_Buttons[87] then
            if F_Storage_ClickNumber[pid] == 87 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 87
            endif
        elseif f ==  F_Storage_Buttons[88] then
            if F_Storage_ClickNumber[pid] == 88 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 88
            endif
        elseif f ==  F_Storage_Buttons[89] then
            if F_Storage_ClickNumber[pid] == 89 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 89
            endif
        elseif f ==  F_Storage_Buttons[90] then
            if F_Storage_ClickNumber[pid] == 90 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 90
            endif
        elseif f ==  F_Storage_Buttons[91] then
            if F_Storage_ClickNumber[pid] == 91 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 91
            endif
        elseif f ==  F_Storage_Buttons[92] then
            if F_Storage_ClickNumber[pid] == 92 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 92
            endif
        elseif f ==  F_Storage_Buttons[93] then
            if F_Storage_ClickNumber[pid] == 93 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 93
            endif
        elseif f ==  F_Storage_Buttons[94] then
            if F_Storage_ClickNumber[pid] == 94 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 94
            endif
        elseif f ==  F_Storage_Buttons[95] then
            if F_Storage_ClickNumber[pid] == 95 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 95
            endif
        elseif f ==  F_Storage_Buttons[96] then
            if F_Storage_ClickNumber[pid] == 96 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 96
            endif
        elseif f ==  F_Storage_Buttons[97] then
            if F_Storage_ClickNumber[pid] == 97 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 97
            endif
        elseif f ==  F_Storage_Buttons[98] then
            if F_Storage_ClickNumber[pid] == 98 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 98
            endif
        elseif f ==  F_Storage_Buttons[99] then
            if F_Storage_ClickNumber[pid] == 99 then
                set i = 2
            else
                set F_Storage_ClickNumber[pid] = 99
            endif
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
                call DzFrameSetTexture(F_Storage_ButtonsBackDrop[F_Storage_ClickNumber[pid]], "UI_Inventory.blp", 0)
                call DzFrameShow(UI_Tip, false)
                call DzDestroyFrame(f)
                set F_Storage_Buttons[F_Storage_ClickNumber[pid]] = 0
                call StashRemove(pid:PLAYER_DATA, "창고"+I2S(F_Storage_ClickNumber[pid]))
                call DzFrameShow(F_Storage_ButtonLock[F_Storage_ClickNumber[pid]], false)
                //인벤에 추가
                call StashSave(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(j), items)
                call AddIvItem.evaluate(pid,j,items)
                set F_Storage_ClickNumber[pid] = 200
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
                    call DzFrameSetTexture(F_Storage_ButtonsBackDrop[F_Storage_ClickNumber[pid]], "UI_Inventory.blp", 0)
                    call DzFrameShow(UI_Tip, false)
                    call DzDestroyFrame(f)
                    set F_Storage_Buttons[F_Storage_ClickNumber[pid]] = 0
                    call StashRemove(pid:PLAYER_DATA, "창고"+I2S(F_Storage_ClickNumber[pid]))
                    call DzFrameShow(F_Storage_ButtonLock[F_Storage_ClickNumber[pid]], false)
                    
                    set F_Storage_ClickNumber[pid] = 200
                    
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
                    call DzFrameSetTexture(F_Storage_ButtonsBackDrop[F_Storage_ClickNumber[pid]], "UI_Inventory.blp", 0)
                    call DzFrameShow(UI_Tip, false)
                    call DzDestroyFrame(f)
                    set F_Storage_Buttons[F_Storage_ClickNumber[pid]] = 0
                    call StashRemove(pid:PLAYER_DATA, "창고"+I2S(F_Storage_ClickNumber[pid]))
                    call DzFrameShow(F_Storage_ButtonLock[F_Storage_ClickNumber[pid]], false)
                    //인벤에 추가
                    call StashSave(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(j), items)
                    call AddIvItem.evaluate(pid,j,items)
                    set F_Storage_ClickNumber[pid] = 200
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
        local string  items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(F_ItemClickNumber[pid]), "0")
        local string items2
        local integer length
        local integer itemty = GetItemTypes(items)
        local integer i = 0
        local integer j = 0
        local integer k = 0
        local integer etyid1
        local integer etyid2
        
        call DzFrameShow(F_ItemDelBackDrop, false)
        call DzFrameShow(F_ItemALLDelBackDrop, false)
                
        if f ==  F_ItemButtons[0] then
            if F_ItemClickNumber[pid] == 0 then
                set i = 1
                //call VJDebugMsg("장비탭 1번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 0
                //call VJDebugMsg("장비탭 1번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[1] then
            if F_ItemClickNumber[pid] == 1 then
                set i = 1
                //call VJDebugMsg("장비탭 2번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 1
                //call VJDebugMsg("장비탭 2번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[2] then
            if F_ItemClickNumber[pid] == 2 then
                set i = 1
                //call VJDebugMsg("장비탭 3번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 2
                //call VJDebugMsg("장비탭 3번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[3] then
            if F_ItemClickNumber[pid] == 3 then
                set i = 1
                //call VJDebugMsg("장비탭 4번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 3
                //call VJDebugMsg("장비탭 4번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[4] then
            if F_ItemClickNumber[pid] == 4 then
                set i = 1
                //call VJDebugMsg("장비탭 5번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 4
                //call VJDebugMsg("장비탭 5번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[5] then
            if F_ItemClickNumber[pid] == 5 then
                set i = 1
                //call VJDebugMsg("장비탭 6번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 5
                //call VJDebugMsg("장비탭 6번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[6] then
            if F_ItemClickNumber[pid] == 6 then
                set i = 1
                //call VJDebugMsg("장비탭 7번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 6
                //call VJDebugMsg("장비탭 7번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[7] then
            if F_ItemClickNumber[pid] == 7 then
                set i = 1
                //call VJDebugMsg("장비탭 8번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 7
                //call VJDebugMsg("장비탭 8번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[8] then
            if F_ItemClickNumber[pid] == 8 then
                set i = 1
                //call VJDebugMsg("장비탭 9번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 8
                //call VJDebugMsg("장비탭 9번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[9] then
            if F_ItemClickNumber[pid] == 9 then
                set i = 1
                //call VJDebugMsg("장비탭 10번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 9
                //call VJDebugMsg("장비탭 10번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[10] then
            if F_ItemClickNumber[pid] == 10 then
                set i = 1
                //call VJDebugMsg("장비탭 11번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 10
                //call VJDebugMsg("장비탭 11번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[11] then
            if F_ItemClickNumber[pid] == 11 then
                set i = 1
                //call VJDebugMsg("장비탭 12번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 11
                //call VJDebugMsg("장비탭 12번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[12] then
            if F_ItemClickNumber[pid] == 12 then
                set i = 1
                //call VJDebugMsg("장비탭 13번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 12
                //call VJDebugMsg("장비탭 13번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[13] then
            if F_ItemClickNumber[pid] == 13 then
                set i = 1
                //call VJDebugMsg("장비탭 14번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 13
                //call VJDebugMsg("장비탭 14번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[14] then
            if F_ItemClickNumber[pid] == 14 then
                set i = 1
                //call VJDebugMsg("장비탭 15번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 14
                //call VJDebugMsg("장비탭 15번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[15] then
            if F_ItemClickNumber[pid] == 15 then
                set i = 1
                //call VJDebugMsg("장비탭 16번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 15
                //call VJDebugMsg("장비탭 16번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[16] then
            if F_ItemClickNumber[pid] == 16 then
                set i = 1
                //call VJDebugMsg("장비탭 17번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 16
                //call VJDebugMsg("장비탭 17번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[17] then
            if F_ItemClickNumber[pid] == 17 then
                set i = 1
                //call VJDebugMsg("장비탭 18번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 17
                //call VJDebugMsg("장비탭 18번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[18] then
            if F_ItemClickNumber[pid] == 18 then
                set i = 1
                //call VJDebugMsg("장비탭 19번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 18
                //call VJDebugMsg("장비탭 19번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[19] then
            if F_ItemClickNumber[pid] == 19 then
                set i = 1
                //call VJDebugMsg("장비탭 20번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 19
                //call VJDebugMsg("장비탭 20번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[20] then
            if F_ItemClickNumber[pid] == 20 then
                set i = 1
                //call VJDebugMsg("장비탭 21번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 20
                //call VJDebugMsg("장비탭 21번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[21] then
            if F_ItemClickNumber[pid] == 21 then
                set i = 1
                //call VJDebugMsg("장비탭 22번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 21
                //call VJDebugMsg("장비탭 22번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[22] then
            if F_ItemClickNumber[pid] == 22 then
                set i = 1
                //call VJDebugMsg("장비탭 23번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 22
                //call VJDebugMsg("장비탭 23번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[23] then
            if F_ItemClickNumber[pid] == 23 then
                set i = 1
                //call VJDebugMsg("장비탭 24번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 23
                //call VJDebugMsg("장비탭 24번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[24] then
            if F_ItemClickNumber[pid] == 24 then
                set i = 1
                //call VJDebugMsg("장비탭 25번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 24
                //call VJDebugMsg("장비탭 25번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[25] then
            if F_ItemClickNumber[pid] == 25 then
                set i = 1
                //call VJDebugMsg("장비탭 26번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 25
                //call VJDebugMsg("장비탭 26번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[26] then
            if F_ItemClickNumber[pid] == 26 then
                set i = 1
                //call VJDebugMsg("장비탭 27번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 26
                //call VJDebugMsg("장비탭 27번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[27] then
            if F_ItemClickNumber[pid] == 27 then
                set i = 1
                //call VJDebugMsg("장비탭 28번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 27
                //call VJDebugMsg("장비탭 28번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[28] then
            if F_ItemClickNumber[pid] == 28 then
                set i = 1
                //call VJDebugMsg("장비탭 29번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 28
                //call VJDebugMsg("장비탭 29번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[29] then
            if F_ItemClickNumber[pid] == 29 then
                set i = 1
                //call VJDebugMsg("장비탭 30번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 29
                //call VJDebugMsg("장비탭 30번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[30] then
            if F_ItemClickNumber[pid] == 30 then
                set i = 1
                //call VJDebugMsg("장비탭 31번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 30
                //call VJDebugMsg("장비탭 31번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[31] then
            if F_ItemClickNumber[pid] == 31 then
                set i = 1
                //call VJDebugMsg("장비탭 32번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 31
                //call VJDebugMsg("장비탭 32번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[32] then
            if F_ItemClickNumber[pid] == 32 then
                set i = 1
                //call VJDebugMsg("장비탭 33번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 32
                //call VJDebugMsg("장비탭 33번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[33] then
            if F_ItemClickNumber[pid] == 33 then
                set i = 1
                //call VJDebugMsg("장비탭 34번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 33
                //call VJDebugMsg("장비탭 34번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[34] then
            if F_ItemClickNumber[pid] == 34 then
                set i = 1
                //call VJDebugMsg("장비탭 35번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 34
                //call VJDebugMsg("장비탭 35번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[35] then
            if F_ItemClickNumber[pid] == 35 then
                set i = 1
                //call VJDebugMsg("장비탭 36번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 35
                //call VJDebugMsg("장비탭 36번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[36] then
            if F_ItemClickNumber[pid] == 36 then
                set i = 1
                //call VJDebugMsg("장비탭 37번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 36
                //call VJDebugMsg("장비탭 37번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[37] then
            if F_ItemClickNumber[pid] == 37 then
                set i = 1
                //call VJDebugMsg("장비탭 38번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 37
                //call VJDebugMsg("장비탭 38번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[38] then
            if F_ItemClickNumber[pid] == 38 then
                set i = 1
                //call VJDebugMsg("장비탭 39번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 38
                //call VJDebugMsg("장비탭 39번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[39] then
            if F_ItemClickNumber[pid] == 39 then
                set i = 1
                //call VJDebugMsg("장비탭 40번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 39
                //call VJDebugMsg("장비탭 40번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[40] then
            if F_ItemClickNumber[pid] == 40 then
                set i = 1
                //call VJDebugMsg("장비탭 41번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 40
                //call VJDebugMsg("장비탭 41번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[41] then
            if F_ItemClickNumber[pid] == 41 then
                set i = 1
                //call VJDebugMsg("장비탭 42번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 41
                //call VJDebugMsg("장비탭 42번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[42] then
            if F_ItemClickNumber[pid] == 42 then
                set i = 1
                //call VJDebugMsg("장비탭 43번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 42
                //call VJDebugMsg("장비탭 43번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[43] then
            if F_ItemClickNumber[pid] == 43 then
                set i = 1
                //call VJDebugMsg("장비탭 44번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 43
                //call VJDebugMsg("장비탭 44번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[44] then
            if F_ItemClickNumber[pid] == 44 then
                set i = 1
                //call VJDebugMsg("장비탭 45번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 44
                //call VJDebugMsg("장비탭 45번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[45] then
            if F_ItemClickNumber[pid] == 45 then
                set i = 1
                //call VJDebugMsg("장비탭 46번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 45
                //call VJDebugMsg("장비탭 46번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[46] then
            if F_ItemClickNumber[pid] == 46 then
                set i = 1
                //call VJDebugMsg("장비탭 47번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 46
                //call VJDebugMsg("장비탭 47번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[47] then
            if F_ItemClickNumber[pid] == 47 then
                set i = 1
                //call VJDebugMsg("장비탭 48번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 47
                //call VJDebugMsg("장비탭 48번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[48] then
            if F_ItemClickNumber[pid] == 48 then
                set i = 1
                //call VJDebugMsg("장비탭 49번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 48
                //call VJDebugMsg("장비탭 49번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[49] then
            if F_ItemClickNumber[pid] == 49 then
                set i = 1
                //call VJDebugMsg("장비탭 50번째 아이템 장착")
            else
                set F_ItemClickNumber[pid] = 49
                //call VJDebugMsg("장비탭 50번째 아이템 선택")
            endif
        endif
        if f ==  F_ItemButtons[50] then
            if F_ItemClickNumber[pid] == 50 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 50
                //call VJDebugMsg("기타탭 1번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[51] then
            if F_ItemClickNumber[pid] == 51 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 51
                //call VJDebugMsg("기타탭 2번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[52] then
            if F_ItemClickNumber[pid] == 52 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 52
                //call VJDebugMsg("기타탭 3번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[53] then
            if F_ItemClickNumber[pid] == 53 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 53
                //call VJDebugMsg("기타탭 4번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[54] then
            if F_ItemClickNumber[pid] == 54 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 54
                //call VJDebugMsg("기타탭 5번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[55] then
            if F_ItemClickNumber[pid] == 55 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 55
                //call VJDebugMsg("기타탭 6번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[56] then
            if F_ItemClickNumber[pid] == 56 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 56
                //call VJDebugMsg("기타탭 7번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[57] then
            if F_ItemClickNumber[pid] == 57 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 57
                //call VJDebugMsg("기타탭 8번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[58] then
            if F_ItemClickNumber[pid] == 58 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 58
                //call VJDebugMsg("기타탭 9번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[59] then
            if F_ItemClickNumber[pid] == 59 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 59
                //call VJDebugMsg("기타탭 10번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[60] then
            if F_ItemClickNumber[pid] == 60 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 60
                //call VJDebugMsg("기타탭 11번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[61] then
            if F_ItemClickNumber[pid] == 61 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 61
                //call VJDebugMsg("기타탭 12번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[62] then
            if F_ItemClickNumber[pid] == 62 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 62
                //call VJDebugMsg("기타탭 13번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[63] then
            if F_ItemClickNumber[pid] == 63 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 63
                //call VJDebugMsg("기타탭 14번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[64] then
            if F_ItemClickNumber[pid] == 64 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 64
                //call VJDebugMsg("기타탭 15번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[65] then
            if F_ItemClickNumber[pid] == 65 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 65
                //call VJDebugMsg("기타탭 16번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[66] then
            if F_ItemClickNumber[pid] == 66 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 66
                //call VJDebugMsg("기타탭 17번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[67] then
            if F_ItemClickNumber[pid] == 67 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 67
                //call VJDebugMsg("기타탭 18번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[68] then
            if F_ItemClickNumber[pid] == 68 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 68
                //call VJDebugMsg("기타탭 19번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[69] then
            if F_ItemClickNumber[pid] == 69 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 69
                //call VJDebugMsg("기타탭 20번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[70] then
            if F_ItemClickNumber[pid] == 70 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 70
                //call VJDebugMsg("기타탭 21번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[71] then
            if F_ItemClickNumber[pid] == 71 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 71
                //call VJDebugMsg("기타탭 22번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[72] then
            if F_ItemClickNumber[pid] == 72 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 72
                //call VJDebugMsg("기타탭 23번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[73] then
            if F_ItemClickNumber[pid] == 73 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 73
                //call VJDebugMsg("기타탭 24번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[74] then
            if F_ItemClickNumber[pid] == 74 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 74
                //call VJDebugMsg("기타탭 25번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[75] then
            if F_ItemClickNumber[pid] == 75 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 75
                //call VJDebugMsg("기타탭 26번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[76] then
            if F_ItemClickNumber[pid] == 76 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 76
                //call VJDebugMsg("기타탭 27번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[77] then
            if F_ItemClickNumber[pid] == 77 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 77
                //call VJDebugMsg("기타탭 28번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[78] then
            if F_ItemClickNumber[pid] == 78 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 78
                //call VJDebugMsg("기타탭 29번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[79] then
            if F_ItemClickNumber[pid] == 79 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 79
                //call VJDebugMsg("기타탭 30번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[80] then
            if F_ItemClickNumber[pid] == 80 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 80
                //call VJDebugMsg("기타탭 31번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[81] then
            if F_ItemClickNumber[pid] == 81 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 81
                //call VJDebugMsg("기타탭 32번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[82] then
            if F_ItemClickNumber[pid] == 82 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 82
                //call VJDebugMsg("기타탭 33번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[83] then
            if F_ItemClickNumber[pid] == 83 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 83
                //call VJDebugMsg("기타탭 34번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[84] then
            if F_ItemClickNumber[pid] == 84 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 84
                //call VJDebugMsg("기타탭 35번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[85] then
            if F_ItemClickNumber[pid] == 85 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 85
                //call VJDebugMsg("기타탭 36번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[86] then
            if F_ItemClickNumber[pid] == 86 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 86
                //call VJDebugMsg("기타탭 37번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[87] then
            if F_ItemClickNumber[pid] == 87 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 87
                //call VJDebugMsg("기타탭 38번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[88] then
            if F_ItemClickNumber[pid] == 88 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 88
                //call VJDebugMsg("기타탭 39번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[89] then
            if F_ItemClickNumber[pid] == 89 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 89
                //call VJDebugMsg("기타탭 40번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[90] then
            if F_ItemClickNumber[pid] == 90 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 90
                //call VJDebugMsg("기타탭 41번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[91] then
            if F_ItemClickNumber[pid] == 91 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 91
                //call VJDebugMsg("기타탭 42번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[92] then
            if F_ItemClickNumber[pid] == 92 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 92
                //call VJDebugMsg("기타탭 43번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[93] then
            if F_ItemClickNumber[pid] == 93 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 93
                //call VJDebugMsg("기타탭 44번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[94] then
            if F_ItemClickNumber[pid] == 94 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 94
                //call VJDebugMsg("기타탭 45번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[95] then
            if F_ItemClickNumber[pid] == 95 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 95
                //call VJDebugMsg("기타탭 46번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[96] then
            if F_ItemClickNumber[pid] == 96 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 96
                //call VJDebugMsg("기타탭 47번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[97] then
            if F_ItemClickNumber[pid] == 97 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 97
                //call VJDebugMsg("기타탭 48번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[98] then
            if F_ItemClickNumber[pid] == 98 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 98
                //call VJDebugMsg("기타탭 49번째 아이템 선택")
            endif
        elseif f ==  F_ItemButtons[99] then
            if F_ItemClickNumber[pid] == 99 then
                set i = 2
            else
                set F_ItemClickNumber[pid] = 99
                //call VJDebugMsg("기타탭 50번째 아이템 선택")
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
            if itemty == 7 then
                set etyid1 = GetItemIDs(Eitem[pid][7])
                set etyid2 = GetItemIDs(Eitem[pid][8])
                set i = GetItemIDs(items)
                if etyid1 == 0 then
                    //장착
                    set Eitem[pid][7] = items
                    call DzFrameSetTexture(F_EItemButtonsBackDrop[7], GetItemArt(items), 0)
                    //인벤에서 제거
                    call DzFrameSetTexture(F_ItemButtonsBackDrop[F_ItemClickNumber[pid]], "UI_Inventory.blp", 0)
                    call DzFrameShow(UI_Tip, false)
                    call DzDestroyFrame(F_ItemButtons[F_ItemClickNumber[pid]])
                    set F_ItemButtons[F_ItemClickNumber[pid]] = 0
                    call StashRemove(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(F_ItemClickNumber[pid]))
                    call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber[pid]], false)
                    set F_ItemClickNumber[pid] = 200
                    call DzSyncData("장착",I2S(pid)+"\t"+"7"+"\t"+items)
                    call VJDebugMsg("1 : "+I2S(pid))
                    call VJDebugMsg("2 : "+"7")
                    call VJDebugMsg("3 : "+items)
                elseif etyid2 == 0 then
                    //장착
                    set Eitem[pid][8] = items
                    call DzFrameSetTexture(F_EItemButtonsBackDrop[8], GetItemArt(items), 0)
                    //인벤에서 제거
                    call DzFrameSetTexture(F_ItemButtonsBackDrop[F_ItemClickNumber[pid]], "UI_Inventory.blp", 0)
                    call DzFrameShow(UI_Tip, false)
                    call DzDestroyFrame(f)
                    set F_ItemButtons[F_ItemClickNumber[pid]] = 0
                    call StashRemove(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(F_ItemClickNumber[pid]))
                    call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber[pid]], false)
                    set F_ItemClickNumber[pid] = 200
                    call DzSyncData("장착",I2S(pid)+"\t"+"8"+"\t"+items)
                else
                    //장착
                    set items2 = Eitem[pid][7]
                    set Eitem[pid][7] = items
                    call DzFrameSetTexture(F_EItemButtonsBackDrop[7], GetItemArt(items), 0)
                    //교체
                    set j = GetItemIDs(items2)
                    call DzFrameSetTexture(F_ItemButtonsBackDrop[F_ItemClickNumber[pid]], GetItemArt(items2), 0)
                    call StashSave(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(F_ItemClickNumber[pid]), items2)
                    if GetItemLock(items2) == 0 then
                        call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber[pid]], false)
                    else
                        call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber[pid]], true)
                    endif
                    set F_ItemClickNumber[pid] = 200
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
                    call DzFrameSetTexture(F_ItemButtonsBackDrop[F_ItemClickNumber[pid]], "UI_Inventory.blp", 0)
                    call DzFrameShow(UI_Tip, false)
                    call DzDestroyFrame(f)
                    set F_ItemButtons[F_ItemClickNumber[pid]] = 0
                    call StashRemove(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(F_ItemClickNumber[pid]))
                    call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber[pid]], false)
                    set F_ItemClickNumber[pid] = 200
                    call DzSyncData("장착",I2S(pid)+"\t"+"9"+"\t"+items)
                elseif etyid2 == 0 then
                    //장착
                    set Eitem[pid][10] = items
                    call DzFrameSetTexture(F_EItemButtonsBackDrop[10], GetItemArt(items), 0)
                    //인벤에서 제거
                    call DzFrameSetTexture(F_ItemButtonsBackDrop[F_ItemClickNumber[pid]], "UI_Inventory.blp", 0)
                    call DzFrameShow(UI_Tip, false)
                    call DzDestroyFrame(f)
                    set F_ItemButtons[F_ItemClickNumber[pid]] = 0
                    call StashRemove(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(F_ItemClickNumber[pid]))
                    call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber[pid]], false)
                    set F_ItemClickNumber[pid] = 200
                    call DzSyncData("장착",I2S(pid)+"\t"+"10"+"\t"+items)
                else
                    //장착
                    set items2 = Eitem[pid][9]
                    set Eitem[pid][9] = items
                    call DzFrameSetTexture(F_EItemButtonsBackDrop[9], GetItemArt(items), 0)
                    //교체
                    set j = GetItemIDs(items2)
                    call DzFrameSetTexture(F_ItemButtonsBackDrop[F_ItemClickNumber[pid]], GetItemArt(items2), 0)
                    call StashSave(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(F_ItemClickNumber[pid]), items2)
                    if GetItemLock(items2) == 0 then
                        call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber[pid]], false)
                    else
                        call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber[pid]], true)
                    endif
                    set F_ItemClickNumber[pid] = 200
                    call DzSyncData("장착",I2S(pid)+"\t"+"9"+"\t"+items)
                endif
            elseif itemty == 10 then
                if GetItemIDs(Eitem[pid][12]) == 0 then
                    //장착
                    set Eitem[pid][12] = items
                    set i = GetItemIDs(items)
                    call DzFrameSetTexture(F_EItemButtonsBackDrop[12], GetItemArt(items), 0)
                    //인벤에서 제거
                    call DzFrameSetTexture(F_ItemButtonsBackDrop[F_ItemClickNumber[pid]], "UI_Inventory.blp", 0)
                    call DzFrameShow(UI_Tip, false)
                    call DzDestroyFrame(f)
                    set F_ItemButtons[F_ItemClickNumber[pid]] = 0
                    call StashRemove(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(F_ItemClickNumber[pid]))
                    call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber[pid]], false)
                    set F_ItemClickNumber[pid] = 200
                    call DzSyncData("장착",I2S(pid)+"\t"+I2S(12)+"\t"+items)
                else
                    //장착
                    set items2 = Eitem[pid][12]
                    set Eitem[pid][12] = items
                    set i = GetItemIDs(items)
                    call DzFrameSetTexture(F_EItemButtonsBackDrop[12], GetItemArt(items), 0)
                    //교체
                    set j = GetItemIDs(items2)
                    call DzFrameSetTexture(F_ItemButtonsBackDrop[F_ItemClickNumber[pid]], GetItemArt(items2), 0)
                    call StashSave(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(F_ItemClickNumber[pid]), items2)
                    if GetItemLock(items2) == 0 then
                        call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber[pid]], false)
                    else
                        call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber[pid]], true)
                    endif
                    set F_ItemClickNumber[pid] = 200
                    call DzSyncData("장착",I2S(pid)+"\t"+I2S(12)+"\t"+items)
                endif
            else
                if GetItemIDs(Eitem[pid][itemty]) == 0 then
                    //장착
                    set Eitem[pid][itemty] = items
                    set i = GetItemIDs(items)
                    call DzFrameSetTexture(F_EItemButtonsBackDrop[itemty], GetItemArt(items), 0)
                    //인벤에서 제거
                    call DzFrameSetTexture(F_ItemButtonsBackDrop[F_ItemClickNumber[pid]], "UI_Inventory.blp", 0)
                    call DzFrameShow(UI_Tip, false)
                    call DzDestroyFrame(f)
                    set F_ItemButtons[F_ItemClickNumber[pid]] = 0
                    call StashRemove(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(F_ItemClickNumber[pid]))
                    call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber[pid]], false)
                    set F_ItemClickNumber[pid] = 200
                    call DzSyncData("장착",I2S(pid)+"\t"+I2S(itemty)+"\t"+items)
                else
                    //장착
                    set items2 = Eitem[pid][itemty]
                    set Eitem[pid][itemty] = items
                    set i = GetItemIDs(items)
                    call DzFrameSetTexture(F_EItemButtonsBackDrop[itemty], GetItemArt(items), 0)
                    //교체
                    set j = GetItemIDs(items2)
                    call DzFrameSetTexture(F_ItemButtonsBackDrop[F_ItemClickNumber[pid]], GetItemArt(items2), 0)
                    call StashSave(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(F_ItemClickNumber[pid]), items2)
                    if GetItemLock(items2) == 0 then
                        call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber[pid]], false)
                    else
                        call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber[pid]], true)
                    endif
                    set F_ItemClickNumber[pid] = 200
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
                call DzFrameSetTexture(F_ItemButtonsBackDrop[F_ItemClickNumber[pid]], "UI_Inventory.blp", 0)
                call DzFrameShow(UI_Tip, false)
                call DzDestroyFrame(f)
                set F_ItemButtons[F_ItemClickNumber[pid]] = 0
                call StashRemove(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(F_ItemClickNumber[pid]))
                call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber[pid]], false)
                //창고에 추가
                call StashSave(pid:PLAYER_DATA, "창고"+I2S(j), items)
                call AddStItem.evaluate(pid,j,items)
                set F_ItemClickNumber[pid] = 200
            endif
        //기타템 창고로 이동
        elseif i == 4 then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(F_ItemClickNumber[pid]), "0")
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
                    call DzFrameSetTexture(F_ItemButtonsBackDrop[F_ItemClickNumber[pid]], "UI_Inventory.blp", 0)
                    call DzFrameShow(UI_Tip, false)
                    call DzDestroyFrame(f)
                    set F_ItemButtons[F_ItemClickNumber[pid]] = 0
                    call StashRemove(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(F_ItemClickNumber[pid]))
                    call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber[pid]], false)
                    
                    set F_ItemClickNumber[pid] = 200
                    
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
                    call DzFrameSetTexture(F_ItemButtonsBackDrop[F_ItemClickNumber[pid]], "UI_Inventory.blp", 0)
                    call DzFrameShow(UI_Tip, false)
                    call DzDestroyFrame(f)
                    set F_ItemButtons[F_ItemClickNumber[pid]] = 0
                    call StashRemove(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(F_ItemClickNumber[pid]))
                    call DzFrameShow(F_ItemButtonLock[F_ItemClickNumber[pid]], false)
                    //창고에 추가
                    call StashSave(pid:PLAYER_DATA, "창고"+ I2S(j), items)
                    call AddStItem.evaluate(pid,j,items)
                    set F_ItemClickNumber[pid] = 200
                endif
            endif
        endif
        
        if i == 5 then
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(F_ItemClickNumber[pid]), "0")
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
            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".기타"+I2S(F_ItemClickNumber[pid]), "0")
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
        set F_Storage_ButtonsBackDrop[types]=DzCreateFrameByTagName("BACKDROP", "", F_Storage_EQButtonsShow, "", FrameCount())
        call DzFrameSetPoint(F_Storage_ButtonsBackDrop[types], JN_FRAMEPOINT_CENTER, F_Storage_EQBackDrop , JN_FRAMEPOINT_TOPLEFT, x, y)
        call DzFrameSetSize(F_Storage_ButtonsBackDrop[types], 0.025, 0.025)
        call DzFrameSetTexture(F_Storage_ButtonsBackDrop[types], "UI_Inventory.blp", 0)
        
        set F_Storage_ButtonsBackDrop[types+50]=DzCreateFrameByTagName("BACKDROP", "", F_Storage_ETCButtonsShow, "", FrameCount())
        call DzFrameSetPoint(F_Storage_ButtonsBackDrop[types+50], JN_FRAMEPOINT_CENTER, F_Storage_EQBackDrop , JN_FRAMEPOINT_TOPLEFT, x, y)
        call DzFrameSetSize(F_Storage_ButtonsBackDrop[types+50], 0.025, 0.025)
        call DzFrameSetTexture(F_Storage_ButtonsBackDrop[types+50], "UI_Inventory.blp", 0)
        
        set F_Storage_ButtonLock[types]=DzCreateFrameByTagName("BACKDROP", "", F_Storage_ButtonsBackDrop[types], "template", FrameCount())
        call DzFrameSetSize(F_Storage_ButtonLock[types], 0.01, (19.0/ 16.0) * 0.01 )
        call DzFrameSetPoint(F_Storage_ButtonLock[types], 0, F_Storage_ButtonsBackDrop[types], 0, (( 28.0 / 16.0 ) * 0.01), (( 8.0 / 16.0 ) * 0.01)  )
        call DzFrameSetTexture(F_Storage_ButtonLock[types], "UI_Inventory_Lock2.blp", 0)
        call DzFrameShow(F_Storage_ButtonLock[types], false)
    endfunction
    
    //버튼 아이콘 생성 함수
    private function CreateItemBackDrop takes integer types, real x, real y returns nothing
        set F_ItemButtonsBackDrop[types]=DzCreateFrameByTagName("BACKDROP", "", F_EQButtonsShow, "", FrameCount())
        call DzFrameSetPoint(F_ItemButtonsBackDrop[types], JN_FRAMEPOINT_CENTER, F_EQETCTemplateBackDrop , JN_FRAMEPOINT_TOPLEFT, x, y)
        call DzFrameSetSize(F_ItemButtonsBackDrop[types], 0.025, 0.025)
        call DzFrameSetTexture(F_ItemButtonsBackDrop[types], "UI_Inventory.blp", 0)
        
        set F_ItemButtonsBackDrop[types+50]=DzCreateFrameByTagName("BACKDROP", "", F_ETCButtonsShow, "", FrameCount())
        call DzFrameSetPoint(F_ItemButtonsBackDrop[types+50], JN_FRAMEPOINT_CENTER, F_EQETCTemplateBackDrop , JN_FRAMEPOINT_TOPLEFT, x, y)
        call DzFrameSetSize(F_ItemButtonsBackDrop[types+50], 0.025, 0.025)
        call DzFrameSetTexture(F_ItemButtonsBackDrop[types+50], "UI_Inventory.blp", 0)
        
        set F_ItemButtonLock[types]=DzCreateFrameByTagName("BACKDROP", "", F_ItemButtonsBackDrop[types], "template", FrameCount())
        call DzFrameSetSize(F_ItemButtonLock[types], 0.01, (19.0/ 16.0) * 0.01 )
        call DzFrameSetPoint(F_ItemButtonLock[types], 0, F_ItemButtonsBackDrop[types], 0, (( 28.0 / 16.0 ) * 0.01), (( 8.0 / 16.0 ) * 0.01)  )
        call DzFrameSetTexture(F_ItemButtonLock[types], "UI_Inventory_Lock2.blp", 0)
        call DzFrameShow(F_ItemButtonLock[types], false)
    endfunction
    
    //버튼 아이콘 생성 함수
    private function CreateItemBackDrop2 takes integer types, real x, real y returns nothing
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
                set F_ItemButtons[number]=DzCreateFrameByTagName("BUTTON", "", F_ETCButtonsShow, "ScoreScreenTabButtonTemplate",  FrameCount())
                call DzFrameSetScriptByCode(F_ItemButtons[number], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions2, false)
                call DzFrameSetScriptByCode(F_ItemButtons[number], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
            else
                call StashSave(pid:PLAYER_DATA, "슬롯"+sn+".장비"+I2S(number), items)
                call DzFrameSetTexture(F_ItemButtonsBackDrop[number], s, 0)
                set F_ItemButtons[number]=DzCreateFrameByTagName("BUTTON", "", F_EQButtonsShow, "ScoreScreenTabButtonTemplate",  FrameCount())
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
                set F_Storage_Buttons[number]=DzCreateFrameByTagName("BUTTON", "", F_Storage_ETCButtonsShow, "ScoreScreenTabButtonTemplate",  FrameCount())
                call DzFrameSetScriptByCode(F_Storage_Buttons[number], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_ActionsSt2, false)
                call DzFrameSetScriptByCode(F_Storage_Buttons[number], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
            else
                set F_Storage_Buttons[number]=DzCreateFrameByTagName("BUTTON", "", F_Storage_EQButtonsShow, "ScoreScreenTabButtonTemplate",  FrameCount())
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
        endif
    endfunction
    
    private function Main takes nothing returns nothing
        local string s
        local integer i
        call DzLoadToc("war3mapImported\\Templates.toc")
        
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
        //call DzFrameShow(F_ItemOpenButton, true)
        
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
        
        // 일괄 분해 버튼 생성
        set F_ALLDLEButtons = DzCreateFrameByTagName("GLUETEXTBUTTON", "", F_ItemBackDrop, "ScriptDialogButton", 0)
        call DzFrameSetPoint(F_ALLDLEButtons, JN_FRAMEPOINT_CENTER, F_ItemBackDrop , JN_FRAMEPOINT_BOTTOMRIGHT, -0.050, 0.055)
        call DzFrameSetText(F_ALLDLEButtons, "|cffffffff일괄분해")
        call DzFrameSetSize(F_ALLDLEButtons,  0.070, 0.0275)
        call DzFrameSetScriptByCode(F_ALLDLEButtons, JN_FRAMEEVENT_MOUSE_UP, function ClickALLDELButton, false)
        
        // 분해 버튼 생성
        set F_DLEButtons = DzCreateFrameByTagName("GLUETEXTBUTTON", "", F_ItemBackDrop, "ScriptDialogButton", 0)
        call DzFrameSetPoint(F_DLEButtons, JN_FRAMEPOINT_CENTER, F_ItemBackDrop , JN_FRAMEPOINT_BOTTOMRIGHT, -0.1025, 0.055)
        call DzFrameSetText(F_DLEButtons, "|cffffffff분해")
        call DzFrameSetSize(F_DLEButtons,  0.035, 0.0275)
        call DzFrameSetScriptByCode(F_DLEButtons, JN_FRAMEEVENT_MOUSE_UP, function ClickDELButton, false)
        
        // 잠금 버튼 생성
        set F_LOCKButtons = DzCreateFrameByTagName("GLUETEXTBUTTON", "", F_ItemBackDrop, "ScriptDialogButton", 0)
        call DzFrameSetPoint(F_LOCKButtons, JN_FRAMEPOINT_CENTER, F_ItemBackDrop , JN_FRAMEPOINT_BOTTOMRIGHT, -0.1375, 0.055)
        call DzFrameSetText(F_LOCKButtons, "|cffffffff잠금")
        call DzFrameSetSize(F_LOCKButtons,  0.035, 0.0275)
        call DzFrameSetScriptByCode(F_LOCKButtons, JN_FRAMEEVENT_MOUSE_UP, function ClickLockButton, false)
        
        //일괄분해
        set F_ItemALLDelBackDrop=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "StandardEditBoxBackdropTemplate", 0)
        call DzFrameSetAbsolutePoint(F_ItemALLDelBackDrop, JN_FRAMEPOINT_CENTER, 0.4, 0.325)
        call DzFrameSetSize(F_ItemALLDelBackDrop, 0.25, 0.10)
        call DzFrameShow(F_ItemALLDelBackDrop, false)
        call DzFrameSetPriority(F_ItemALLDelBackDrop, 198)
        
        set F_ALLDELText=DzCreateFrameByTagName("TEXT", "", F_ItemALLDelBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_ALLDELText, JN_FRAMEPOINT_CENTER, F_ItemALLDelBackDrop , JN_FRAMEPOINT_CENTER, 0.0, 0.0125)
        call DzFrameSetText(F_ALLDELText, "장비를 전부 일괄 분해하시겠습니까?")
        
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
                        set F_ItemClickNumber[j] = 200
                        set F_ItemOnOff[j] = false
                    else
                        call DzFrameShow(F_ItemBackDrop, true)
                        set F_ItemClickNumber[j] = 200
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
            set F_ItemClickNumber[index] = 200
            set F_Storage_ClickNumber[index] = 200
            set F_Storage_OnOff[index] = false
            set index = index + 1
            exitwhen index == 6
        endloop

        
        //I버튼으로 인벤토리 열기 및 닫기
        call DzTriggerRegisterKeyEventByCode(null, 'I', 0, false, function IKey)
        set t = null
    endfunction
endlibrary