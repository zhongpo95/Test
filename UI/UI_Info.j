library UIInfo initializer Init requires DataItem, StatsSet, UIItem, ITEM
    globals
        integer F_InfoOpenButton                 //아이템창 여는 버튼
        integer F_InfoOpenButtonBD                 //아이템창 여는 버튼 백드롭
        integer F_InfoBackDrop                   //인포 배경
        integer F_InfoCancelButton               //X버튼
        integer array F_ItemStatsText            //스텟창 텍스트
        
        boolean array F_InfoOnOff                //인포 온오프
    endglobals
    
    private function F_OFF_Actions takes nothing returns nothing
        call DzFrameShow(UI_Tip, false)
    endfunction
    
    private function F_ON_Actions1 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local string str = ""
        
        call DzFrameShow(UI_Tip, true)
        call DzFrameSetText(UI_Tip_Text[1], "공격력" )
        set str = "|cFFA5FA7D ◎ |r" + "공격력이 " + "|cFFA5FA7D" + I2S(R2I(Equip_Damage[pid])) + "|r 증가했습니다.|n"
        set str = str + "|cFFA5FA7D ◎ |r" + "증감효과로 공격력이 " + "|cFFA5FA7D" + I2S(R2I(Hero_Damage[pid])) + "|r 증가했습니다." 
        call DzFrameSetText(UI_Tip_Text[2], str )
    endfunction
    
    private function F_ON_Actions2 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local string str = ""
        
        call DzFrameShow(UI_Tip, true)
        call DzFrameSetText(UI_Tip_Text[1], "방어 등급" )
        set str = "|cFFA5FA7D ◎ |r" + "방어력이 " + "|cFFA5FA7D" + I2S(R2I(Equip_Defense[pid])) + "|r 증가했습니다.|n"
        set str = str + "|cFFA5FA7D ◎ |r" + "방어 등급 1 차이당 20%의 추가 데미지를 입습니다." 
        call DzFrameSetText(UI_Tip_Text[2], str )
    endfunction
    
    private function F_ON_Actions3 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local string str = ""
        
        call DzFrameShow(UI_Tip, true)
        call DzFrameSetText(UI_Tip_Text[1], "치명" )
        set str = "|cFFA5FA7D ◎ |r" + "치명타 적중률이 " + "|cFFA5FA7D" + R2S(  Stats_Crit[pid]  ) + "%|r 증가했습니다.|n"
        set str = str + "|cFFA5FA7D ◎ |r" + "치명타 적중시 피해량이 " + "|cFFA5FA7D" + R2S(  Hero_CriDeal[pid]  ) + "%|r 증가합니다." 
        call DzFrameSetText(UI_Tip_Text[2], str )
    endfunction
    
    private function F_ON_Actions4 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local string str = ""
        
        call DzFrameShow(UI_Tip, true)
        call DzFrameSetText(UI_Tip_Text[1], "특화" )
        set str = "|cFFA5FA7D ◎ |r" + "각성 스킬 피해량이 " + "|cFFA5FA7D" + R2S(  (Equip_Specialization[pid]/18)  ) + "%|r 증가했습니다."
        call DzFrameSetText(UI_Tip_Text[2], str )
    endfunction
    
    private function F_ON_Actions5 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local string str = ""
        
        call DzFrameShow(UI_Tip, true)
        call DzFrameSetText(UI_Tip_Text[1], "신속" )
        set str = "|cFFA5FA7D ◎ |r" + "이동속도와 공격속도가 " + "|cFFA5FA7D" + R2S(  SwiftnessSpeed(pid)  ) + "%|r 증가했습니다.|n"
        set str = str + "|cFFA5FA7D ◎ |r" + "스킬 재사용 시간이 " + "|cFFA5FA7D" + R2S(  (Equip_Swiftness[pid]/46)  ) + "%|r 감소합니다." 
        call DzFrameSetText(UI_Tip_Text[2], str )
    endfunction
    
    private function F_ON_Actions6 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local string str = ""
        
        call DzFrameShow(UI_Tip, true)
        call DzFrameSetText(UI_Tip_Text[1], "추가 피해" )
        set str = "|cFFA5FA7D ◎ |r" + "|cFFA5FA7D" + R2S(  Equip_DP[pid]  ) + "%|r"
        call DzFrameSetText(UI_Tip_Text[2], str )
    endfunction
    
    private function F_ON_Actions7 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local string str = ""
        
        call DzFrameShow(UI_Tip, true)
        call DzFrameSetText(UI_Tip_Text[1], "치명타 확률" )
        set str = "|cFFA5FA7D ◎ |r" + "|cFFA5FA7D" + R2S(  Stats_Crit[pid]  ) + "%|r"
        call DzFrameSetText(UI_Tip_Text[2], str )
    endfunction
    
    private function F_ON_Actions8 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local string str = ""
        
        call DzFrameShow(UI_Tip, true)
        call DzFrameSetText(UI_Tip_Text[1], "공격속도" )
        set str = "|cFFA5FA7D ◎ |r" + "|cFFA5FA7D" + R2S(  100 + SkillSpeed(pid)  ) + "%|r|n"
        set str = str + "|cFFA5FA7D ◎ |r" + "시전시간이 1초일 경우 " + "|cFFA5FA7D" + R2S(  (1 * (100.00-(Equip_Swiftness[pid]/46)) / 100 )  ) + "|r 초" 
        call DzFrameSetText(UI_Tip_Text[2], str )
    endfunction
    
    private function F_ON_Actions9 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local string str = ""
        
        call DzFrameShow(UI_Tip, true)
        call DzFrameSetText(UI_Tip_Text[1], "이동속도" )
        set str = "|cFFA5FA7D ◎ |r" + "|cFFA5FA7D" + R2S(  GetUnitMoveSpeed(MainUnit[pid])  ) + "|r"
        call DzFrameSetText(UI_Tip_Text[2], str )
    endfunction
    
    private function F_ON_Actions10 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local string str = ""
        
        call DzFrameShow(UI_Tip, true)
        call DzFrameSetText(UI_Tip_Text[1], "추가 드랍률" )
        set str = "|cFFA5FA7D ◎ |r" + "아이템 드랍 확률이 " + "|cFFA5FA7D" + I2S(  R2I(Equip_Drop[pid])  ) + "%|r 증가했습니다."
        call DzFrameSetText(UI_Tip_Text[2], str )
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
        local item tem
        
        // 0모자, 1상의, 2하의, 3장갑, 4견갑, 5무기, 6목걸이, 7귀걸이, 8귀걸이, 9반지, 10반지, 11팔찌, 12어빌리티스톤
        if f ==  F_EItemButtons[0] then
            set items = Eitem[pid][0]
            set itemid = GetItemIDs(Eitem[pid][0])
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "모자" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        elseif f ==  F_EItemButtons[1] then
            set items = Eitem[pid][1]
            set itemid = GetItemIDs(Eitem[pid][1])
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "상의" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        elseif f ==  F_EItemButtons[2] then
            set items = Eitem[pid][2]
            set itemid = GetItemIDs(Eitem[pid][2])
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "하의" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        elseif f ==  F_EItemButtons[3] then
            set items = Eitem[pid][3]
            set itemid = GetItemIDs(Eitem[pid][3])
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "장갑" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        elseif f ==  F_EItemButtons[4] then
            set items = Eitem[pid][4]
            set itemid =GetItemIDs(Eitem[pid][4])
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "견갑" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        elseif f ==  F_EItemButtons[5] then
            set items = Eitem[pid][5]
            set itemid = GetItemIDs(Eitem[pid][5])
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "무기" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        elseif f ==  F_EItemButtons[6] then
            set items = Eitem[pid][6]
            set itemid = GetItemIDs(Eitem[pid][6])
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "목걸이" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        elseif f ==  F_EItemButtons[7] then
            set items = Eitem[pid][7]
            set itemid = GetItemIDs(Eitem[pid][7])
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "귀걸이" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        elseif f ==  F_EItemButtons[8] then
            set items = Eitem[pid][8]
            set itemid = GetItemIDs(Eitem[pid][8])
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "귀걸이" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        elseif f ==  F_EItemButtons[9] then
            set items = Eitem[pid][9]
            set itemid = GetItemIDs(Eitem[pid][9])
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "반지" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        elseif f ==  F_EItemButtons[10] then
            set items = Eitem[pid][10]
            set itemid = GetItemIDs(Eitem[pid][10])
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "반지" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        elseif f ==  F_EItemButtons[11] then
            set items = Eitem[pid][11]
            set itemid = GetItemIDs(Eitem[pid][11])
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "팔찌" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        elseif f ==  F_EItemButtons[12] then
            set items = Eitem[pid][12]
            set itemid = GetItemIDs(Eitem[pid][12])
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "어빌리티 스톤" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        endif
                
        if itemid != 0 then
            call DzFrameShow(UI_Tip, true)
            set i = GetItemTypes(items)
            set up = GetItemUp(items)
            set quality = GetItemQuality(items)
            set cts = GetItemCombatStats(items)
            set tier = GetItemTier(items)
                
            if i >= 6 or tier == 1 then
                call DzFrameSetText(UI_Tip_Text[1], GetItemNames(items) )
            else
                call DzFrameSetText(UI_Tip_Text[1], "+" + I2S(up) + " " + GetItemNames(items) )
            endif
            set str = "|cFFA5FA7D[ 종류 ]|r "
            // 0모자, 1상의, 2하의, 3장갑, 4견갑, 5무기, 6목걸이, 7귀걸이, 8반지, 9팔찌, 10카드
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
                set str = str + "팔찌|n|n"
            elseif i == 10 then
                set str = str + "카드|n|n"
                set str = str + "|n|cFFB9E2FA체력 + "
                set str = str + "0"
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
    
    //장착중인 아이템 버튼 클릭
    private function ClickEButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer i = 0
        local integer j = 40
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local string items
        local string sn = I2S(PlayerSlotNumber[pid])
        local integer selectnumber = LoadInteger(Hash, f, StringHash("number"))
        local integer selectnumber2 = selectnumber - 201

        //해제불가가 아닌템
        if selectnumber2 > 5 then
            //템이 비어있지않음
            if GetItemIDs(Eitem[pid][selectnumber2]) != 0 then
                if selectnumber == F_ItemClickNumber then
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
                        set items = Eitem[pid][selectnumber2]
                        //장착 해제
                        set Eitem[pid][selectnumber2] = ""
                        call DzFrameSetTexture(F_EItemButtonsBackDrop[selectnumber2], "UI_Inventory.blp", 0)
                        //인벤에서 추가
                        call AddIvItem(pid,j,items)
                        set F_ItemClickNumber = 200
                        call DzSyncData("해제",I2S(pid)+"\t"+I2S(selectnumber2)+"\t"+"0")
                    endif
                else
                    set F_ItemClickNumber = selectnumber
                endif
            else
                set F_ItemClickNumber = 200
            endif
        else
            set F_ItemClickNumber = selectnumber
        endif
        
        call StopSound(gg_snd_MouseClick1, false, false)
        call StartSound(gg_snd_MouseClick1)
    endfunction
    
    
    //장비 빈 버튼 아이콘 생성 함수
    private function CreateEItemButton takes integer types, real x, real y returns nothing
        set F_EItemButtons[types]=DzCreateFrameByTagName("BUTTON", "", F_InfoBackDrop, "ScoreScreenTabButtonTemplate", 0)
        call DzFrameSetPoint(F_EItemButtons[types], JN_FRAMEPOINT_CENTER, F_InfoBackDrop , JN_FRAMEPOINT_TOPLEFT, x, y)
        call DzFrameSetSize(F_EItemButtons[types], 0.030, 0.030)
        
        set F_EItemButtonsBackDrop[types]=DzCreateFrameByTagName("BACKDROP", "", F_EItemButtons[types], "", 0)
        call DzFrameSetAllPoints(F_EItemButtonsBackDrop[types], F_EItemButtons[types])
        call DzFrameSetTexture(F_EItemButtonsBackDrop[types],"UI_Inventory.blp", 0)
        
        call DzFrameSetScriptByCode(F_EItemButtons[types], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions, false)
        call DzFrameSetScriptByCode(F_EItemButtons[types], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        call DzFrameSetScriptByCode(F_EItemButtons[types], JN_FRAMEEVENT_MOUSE_UP, function ClickEButton, false)
        
        call SaveInteger(Hash, F_EItemButtons[types], StringHash("number"), types+201)
    endfunction
    
    
    private function InfoOpen takes nothing returns nothing
        //메뉴 버튼을 누르면 메뉴 버튼 비활설화 + 메뉴 배경 표시
        //다시 메뉴 버튼을 누르면 메뉴버튼 활성화 + 메뉴 배경 숨김
        if F_InfoOnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] == true then
            call DzFrameShow(F_InfoBackDrop, false)
            set F_InfoOnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = false
        else
            call DzFrameShow(F_InfoBackDrop, true)
            set F_InfoOnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = true
        endif
    endfunction
    
    private function Main takes nothing returns nothing
        local string s
        local integer i
        call DzLoadToc("war3mapImported\\Templates.toc")
        
        //가방 버튼 생성
        set F_InfoOpenButton = DzCreateFrameByTagName("GLUETEXTBUTTON", "", DzGetGameUI(), "template", 0)
        call DzFrameSetAbsolutePoint(F_InfoOpenButton, JN_FRAMEPOINT_CENTER, 0.750, 0.020)
        call DzFrameSetSize(F_InfoOpenButton, 0.020, 0.020)
        call DzFrameSetScriptByCode(F_InfoOpenButton, JN_FRAMEEVENT_MOUSE_UP, function InfoOpen, false)
        set F_InfoOpenButtonBD=DzCreateFrameByTagName("BACKDROP", "", F_InfoOpenButton, "template", 0)
        call DzFrameSetTexture(F_InfoOpenButtonBD, "inven.blp", 0)
        call DzFrameSetSize(F_InfoOpenButtonBD, 0.020, 0.020)
        call DzFrameSetAbsolutePoint(F_InfoOpenButtonBD, JN_FRAMEPOINT_CENTER, 0.750, 0.020)
        call DzFrameShow(F_InfoOpenButton, false)
        
        //메뉴 배경
        set F_InfoBackDrop=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "StandardEditBoxBackdropTemplate", 0)
        call DzFrameSetAbsolutePoint(F_InfoBackDrop, JN_FRAMEPOINT_CENTER, 0.225, 0.315)
        call DzFrameSetSize(F_InfoBackDrop, 0.40, 0.27)
        
        //메뉴 취소 버튼
        set F_InfoCancelButton = DzCreateFrameByTagName("GLUETEXTBUTTON", "", F_InfoBackDrop, "ScriptDialogButton", 0)
        call DzFrameSetPoint(F_InfoCancelButton, JN_FRAMEPOINT_TOPRIGHT, F_InfoBackDrop , JN_FRAMEPOINT_TOPRIGHT, -0.010, -0.010)
        call DzFrameSetText(F_InfoCancelButton, "X")
        call DzFrameSetSize(F_InfoCancelButton, 0.03, 0.03)
        call DzFrameSetScriptByCode(F_InfoCancelButton, JN_FRAMEEVENT_MOUSE_UP, function InfoOpen, false)
        
        
        // 0모자, 1상의, 2하의, 3장갑, 4견갑, 5무기, 6목걸이, 7귀걸이, 8귀걸이, 9반지, 10반지, 11팔찌, 12어빌리티스톤
        
        call CreateEItemButton(0 , 0.270 , - 0.080)
        call CreateEItemButton(1 , 0.270 , - 0.115)
        call CreateEItemButton(2 , 0.270 , - 0.150)
        call CreateEItemButton(3 , 0.310 , - 0.150)
        call CreateEItemButton(4 , 0.310 , - 0.115)
        call CreateEItemButton(5 , 0.230 , - 0.150)
        
        call CreateEItemButton(6 , 0.350 , - 0.080)
        call CreateEItemButton(7 , 0.350 , - 0.115)
        call CreateEItemButton(8 , 0.350 , - 0.150)
        call CreateEItemButton(9 , 0.350 , - 0.185)
        call CreateEItemButton(10 , 0.350 , - 0.220)


        call CreateEItemButton(11 , 0.310 , - 0.220)
        call CreateEItemButton(12 , 0.270 , - 0.220)
        //call CreateEItemButton(13 , 0.150 , - 0.235)
        //call CreateEItemButton(14 , 0.250 , - 0.235)
        
        set F_ItemStatsText[5]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop, "", 0)
        call DzFrameSetPoint(F_ItemStatsText[5], JN_FRAMEPOINT_CENTER, F_InfoBackDrop, JN_FRAMEPOINT_CENTER, -0.155, 0.110)
        call DzFrameSetText(F_ItemStatsText[5], "기본 정보")

        set F_ItemStatsText[0]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop, "", 0)
        call DzFrameSetPoint(F_ItemStatsText[0], JN_FRAMEPOINT_CENTER, F_InfoBackDrop, JN_FRAMEPOINT_CENTER, -0.135, 0.090)
        call DzFrameSetText(F_ItemStatsText[0], "|cFFFFE400공격력")
        
        set F_ItemStatsText[0]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop, "", 0)
        call DzFrameSetPoint(F_ItemStatsText[0], JN_FRAMEPOINT_CENTER, F_InfoBackDrop, JN_FRAMEPOINT_CENTER, -0.050, 0.090)
        call DzFrameSetText(F_ItemStatsText[0], "0")
        call DzFrameSetScriptByCode(F_ItemStatsText[0], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions1, false)
        call DzFrameSetScriptByCode(F_ItemStatsText[0], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        set F_ItemStatsText[1]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop, "", 0)
        call DzFrameSetPoint(F_ItemStatsText[1], JN_FRAMEPOINT_CENTER, F_InfoBackDrop, JN_FRAMEPOINT_CENTER, -0.135, 0.070)
        call DzFrameSetText(F_ItemStatsText[1], "|cFFFFE400방어등급")
        
        set F_ItemStatsText[1]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop, "", 0)
        call DzFrameSetPoint(F_ItemStatsText[1], JN_FRAMEPOINT_CENTER, F_InfoBackDrop, JN_FRAMEPOINT_CENTER, -0.050, 0.070)
        call DzFrameSetText(F_ItemStatsText[1], "0")
        call DzFrameSetScriptByCode(F_ItemStatsText[1], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions2, false)
        call DzFrameSetScriptByCode(F_ItemStatsText[1], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        
        set F_ItemStatsText[2]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop, "", 0)
        call DzFrameSetPoint(F_ItemStatsText[2], JN_FRAMEPOINT_CENTER, F_InfoBackDrop, JN_FRAMEPOINT_CENTER, -0.135, 0.050)
        call DzFrameSetText(F_ItemStatsText[2], "|cFFFFE400치명")
        
        set F_ItemStatsText[2]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop, "", 0)
        call DzFrameSetPoint(F_ItemStatsText[2], JN_FRAMEPOINT_CENTER, F_InfoBackDrop, JN_FRAMEPOINT_CENTER, -0.050, 0.050)
        call DzFrameSetText(F_ItemStatsText[2], "0")
        call DzFrameSetScriptByCode(F_ItemStatsText[2], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions3, false)
        call DzFrameSetScriptByCode(F_ItemStatsText[2], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        set F_ItemStatsText[3]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop, "", 0)
        call DzFrameSetPoint(F_ItemStatsText[3], JN_FRAMEPOINT_CENTER, F_InfoBackDrop, JN_FRAMEPOINT_CENTER, -0.135, 0.030)
        call DzFrameSetText(F_ItemStatsText[3], "|cFFFFE400특화")
        
        set F_ItemStatsText[3]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop, "", 0)
        call DzFrameSetPoint(F_ItemStatsText[3], JN_FRAMEPOINT_CENTER, F_InfoBackDrop, JN_FRAMEPOINT_CENTER, -0.050, 0.030)
        call DzFrameSetText(F_ItemStatsText[3], "0")
        call DzFrameSetScriptByCode(F_ItemStatsText[3], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions4, false)
        call DzFrameSetScriptByCode(F_ItemStatsText[3], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        set F_ItemStatsText[4]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop, "", 0)
        call DzFrameSetPoint(F_ItemStatsText[4], JN_FRAMEPOINT_CENTER, F_InfoBackDrop, JN_FRAMEPOINT_CENTER, -0.135, 0.010)
        call DzFrameSetText(F_ItemStatsText[4], "|cFFFFE400신속")
        
        set F_ItemStatsText[4]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop, "", 0)
        call DzFrameSetPoint(F_ItemStatsText[4], JN_FRAMEPOINT_CENTER, F_InfoBackDrop, JN_FRAMEPOINT_CENTER, -0.050, 0.010)
        call DzFrameSetText(F_ItemStatsText[4], "0")
        call DzFrameSetScriptByCode(F_ItemStatsText[4], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions5, false)
        call DzFrameSetScriptByCode(F_ItemStatsText[4], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        set F_ItemStatsText[5]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop, "", 0)
        call DzFrameSetPoint(F_ItemStatsText[5], JN_FRAMEPOINT_CENTER, F_InfoBackDrop, JN_FRAMEPOINT_CENTER, -0.155, -0.010)
        call DzFrameSetText(F_ItemStatsText[5], "추가 정보")

        set F_ItemStatsText[5]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop, "", 0)
        call DzFrameSetPoint(F_ItemStatsText[5], JN_FRAMEPOINT_CENTER, F_InfoBackDrop, JN_FRAMEPOINT_CENTER, -0.135, -0.030)
        call DzFrameSetText(F_ItemStatsText[5], "|cFFFFE400추가 피해")
        
        set F_ItemStatsText[5]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop, "", 0)
        call DzFrameSetPoint(F_ItemStatsText[5], JN_FRAMEPOINT_CENTER, F_InfoBackDrop, JN_FRAMEPOINT_CENTER, -0.050, -0.030)
        call DzFrameSetText(F_ItemStatsText[5], "0")
        call DzFrameSetScriptByCode(F_ItemStatsText[5], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions6, false)
        call DzFrameSetScriptByCode(F_ItemStatsText[5], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)

        set F_ItemStatsText[6]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop, "", 0)
        call DzFrameSetPoint(F_ItemStatsText[6], JN_FRAMEPOINT_CENTER, F_InfoBackDrop, JN_FRAMEPOINT_CENTER, -0.135, -0.050)
        call DzFrameSetText(F_ItemStatsText[6], "|cFFFFE400치명타 확률")
        
        set F_ItemStatsText[6]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop, "", 0)
        call DzFrameSetPoint(F_ItemStatsText[6], JN_FRAMEPOINT_CENTER, F_InfoBackDrop, JN_FRAMEPOINT_CENTER, -0.050, -0.050)
        call DzFrameSetText(F_ItemStatsText[6], "0")
        call DzFrameSetScriptByCode(F_ItemStatsText[6], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions7, false)
        call DzFrameSetScriptByCode(F_ItemStatsText[6], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        set F_ItemStatsText[7]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop, "", 0)
        call DzFrameSetPoint(F_ItemStatsText[7], JN_FRAMEPOINT_CENTER, F_InfoBackDrop, JN_FRAMEPOINT_CENTER, -0.135, -0.070)
        call DzFrameSetText(F_ItemStatsText[7], "|cFFFFE400공격속도")
        
        set F_ItemStatsText[7]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop, "", 0)
        call DzFrameSetPoint(F_ItemStatsText[7], JN_FRAMEPOINT_CENTER, F_InfoBackDrop, JN_FRAMEPOINT_CENTER, -0.050, -0.070)
        call DzFrameSetText(F_ItemStatsText[7], "0")
        call DzFrameSetScriptByCode(F_ItemStatsText[7], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions8, false)
        call DzFrameSetScriptByCode(F_ItemStatsText[7], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        set F_ItemStatsText[8]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop, "", 0)
        call DzFrameSetPoint(F_ItemStatsText[8], JN_FRAMEPOINT_CENTER, F_InfoBackDrop, JN_FRAMEPOINT_CENTER, -0.135, -0.090)
        call DzFrameSetText(F_ItemStatsText[8], "|cFFFFE400이동속도")
        
        set F_ItemStatsText[8]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop, "", 0)
        call DzFrameSetPoint(F_ItemStatsText[8], JN_FRAMEPOINT_CENTER, F_InfoBackDrop, JN_FRAMEPOINT_CENTER, -0.050, -0.090)
        call DzFrameSetText(F_ItemStatsText[8], "0")
        call DzFrameSetScriptByCode(F_ItemStatsText[8], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions9, false)
        call DzFrameSetScriptByCode(F_ItemStatsText[8], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        set F_ItemStatsText[9]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop, "", 0)
        call DzFrameSetPoint(F_ItemStatsText[9], JN_FRAMEPOINT_CENTER, F_InfoBackDrop, JN_FRAMEPOINT_CENTER, -0.135, -0.110)
        call DzFrameSetText(F_ItemStatsText[9], "|cFFFFE400추가 드랍률")
        
        set F_ItemStatsText[9]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop, "", 0)
        call DzFrameSetPoint(F_ItemStatsText[9], JN_FRAMEPOINT_CENTER, F_InfoBackDrop, JN_FRAMEPOINT_CENTER, -0.050, -0.110)
        call DzFrameSetText(F_ItemStatsText[9], "0")
        call DzFrameSetScriptByCode(F_ItemStatsText[9], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions10, false)
        call DzFrameSetScriptByCode(F_ItemStatsText[9], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        
        call DzFrameShow(F_InfoBackDrop, false)
    endfunction
    
    private function ESCAction takes nothing returns nothing
        if F_InfoOnOff[GetPlayerId(GetTriggerPlayer())] == true then
            if ( GetTriggerPlayer() == GetLocalPlayer() ) then
                call DzFrameShow(F_InfoBackDrop, false)
            endif
            set F_InfoOnOff[GetPlayerId(GetTriggerPlayer())] = false
        endif
    endfunction
    
    private function PKey takes nothing returns nothing
        local integer key = DzGetTriggerKey()
        local integer i = 0
        local integer j = GetPlayerId(DzGetTriggerKeyPlayer())
        
        if DzGetTriggerKeyPlayer()==GetLocalPlayer() then
            set i = JNMemoryGetByte(JNGetModuleHandle("Game.dll")+0xD04FEC)
        endif
        
        if i==1 then
        else
            if PickCheck[j] == true then
                if key == 'P' then
                    if F_InfoOnOff[j] == true then
                        call DzFrameShow(F_InfoBackDrop, false)
                        set F_InfoOnOff[j] = false
                    else
                        call DzFrameShow(F_InfoBackDrop, true)
                        set F_InfoOnOff[j] = true
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
        call DzLoadToc("war3mapimported\\BoxedText.toc")
        
        set index = 0
        loop
            set F_InfoOnOff[index] = false
            set index = index + 1
            exitwhen index == 6
        endloop
        
        //esc버튼으로 인포창 닫기
        set t = CreateTrigger()
        
        set index = 0
        loop
            call TriggerRegisterPlayerEvent(t, Player(index), EVENT_PLAYER_END_CINEMATIC)
            set index = index + 1
            exitwhen index == 6
        endloop
        call TriggerAddAction( t, function ESCAction )
        
        //P버튼으로 인포창 열기 및 닫기
        set t = CreateTrigger()
        
        call DzTriggerRegisterKeyEventByCode(t, 'P', 0, false, function PKey)
        
        set t = null
    endfunction
endlibrary