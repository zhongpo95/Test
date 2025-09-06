library UIInfo2 initializer Init requires DataItem, StatsSet, UIItem, ITEM, FrameCount
    globals
        integer F_InfoBackDrop2                   //인포 배경
        //integer F_InfoCancelButton             //X버튼
        integer array F_ItemStatsText2           //스텟창 텍스트
        integer F_ItemStatsIcon2                  //스텟창 캐릭터 아이콘
        integer array F_EItemButtons2
        integer array F_EItemButtons2BackDrop
        boolean array F_Info2OnOff                //인포 온오프
        integer ClickPlayer = 0
    endglobals
    
    private function F_OFF_Actions takes nothing returns nothing
        call DzFrameShow(UI_Tip, false)
    endfunction
    
    private function F_ON_Actions1 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = ClickPlayer
        local string str = ""
        
        call DzFrameShow(UI_Tip, true)
        call DzFrameSetText(UI_Tip_Text[1], "공격력" )
        set str = "|cFFA5FA7D ◎ |r" + "공격력이 " + "|cFFA5FA7D" + I2S(R2I(Equip_Damage[pid])) + "|r 증가했습니다.|n"
        set str = str + "|cFFA5FA7D ◎ |r" + "증감효과로 공격력이 " + "|cFFA5FA7D" + I2S(R2I(Hero_Damage[pid])) + "|r 증가했습니다." 
        call DzFrameSetText(UI_Tip_Text[2], str )
    endfunction
    
    private function F_ON_Actions2 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = ClickPlayer
        local string str = ""
        
        call DzFrameShow(UI_Tip, true)
        call DzFrameSetText(UI_Tip_Text[1], "방어 등급" )
        //set str = "|cFFA5FA7D ◎ |r" + "방어 등급 " + "|cFFA5FA7D" + I2S(R2I( Equip_Defense[pid] + Arcana_Defense[pid] )) + "|r |n"
        set str = str + "|cFFA5FA7D ◎ |r" + "방어 등급 1 차이당 20%의 추가 데미지를 입습니다." 
        call DzFrameSetText(UI_Tip_Text[2], str )
    endfunction
    
    private function F_ON_Actions3 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = ClickPlayer
        local string str = ""
        
        call DzFrameShow(UI_Tip, true)
        call DzFrameSetText(UI_Tip_Text[1], "치명" )
        set str = "|cFFA5FA7D ◎ |r" + "치명타 적중률이 " + "|cFFA5FA7D" + R2S(  (Equip_Crit[pid]/28)  ) + "%|r 증가했습니다.|n"
        call DzFrameSetText(UI_Tip_Text[2], str )
    endfunction
    
    private function F_ON_Actions5 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = ClickPlayer
        local string str = ""
        
        call DzFrameShow(UI_Tip, true)
        call DzFrameSetText(UI_Tip_Text[1], "신속" )
        set str = "|cFFA5FA7D ◎ |r" + "이동속도와 공격속도가 " + "|cFFA5FA7D" + R2S(  SwiftnessSpeed(pid)  ) + "%|r 증가했습니다.|n"
        set str = str + "|cFFA5FA7D ◎ |r" + "스킬 재사용 시간이 " + "|cFFA5FA7D" + R2S(  (Equip_Swiftness[pid]/46)  ) + "%|r 감소합니다." 
        call DzFrameSetText(UI_Tip_Text[2], str )
    endfunction
    
    private function F_ON_Actions6 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = ClickPlayer
        local string str = ""
        
        call DzFrameShow(UI_Tip, true)
        call DzFrameSetText(UI_Tip_Text[1], "추가 피해" )
        set str = "|cFFA5FA7D ◎ |r" + "|cFFA5FA7D" + R2S(  Equip_WDP[pid] + Arcana_DP[pid] + Equip_ED[pid]  ) + "%|r"
        call DzFrameSetText(UI_Tip_Text[2], str )
    endfunction
    
    private function F_ON_Actions7 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = ClickPlayer
        local string str = ""
        
        call DzFrameShow(UI_Tip, true)
        call DzFrameSetText(UI_Tip_Text[1], "치명타 확률" )
        set str = "|cFFA5FA7D ◎ |r" + "|cFFA5FA7D" + R2S(  Stats_Crit[pid]  ) + "%|r|n"
        set str = str + "|cFFA5FA7D ◎ |r" + "치명타 적중시 피해량이 " + "|cFFA5FA7D" + R2S(  Hero_CriDeal[pid] + Equip_CriDeal[pid] + Arcana_CriDeal[pid]) + "%|r 증가합니다." 
        call DzFrameSetText(UI_Tip_Text[2], str )
    endfunction
    
    private function F_ON_Actions8 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = ClickPlayer
        local string str = ""
        
        call DzFrameShow(UI_Tip, true)
        call DzFrameSetText(UI_Tip_Text[1], "공격속도" )
        set str = "|cFFA5FA7D ◎ |r" + "|cFFA5FA7D" + R2S(  100 + SkillSpeed(pid)  ) + "%|r|n"
        set str = str + "|cFFA5FA7D ◎ |r" + "시전시간이 1초일 경우 " + "|cFFA5FA7D" + R2S(  (1 * (100.00-(Equip_Swiftness[pid]/46)) / 100 )  ) + "|r 초" 
        call DzFrameSetText(UI_Tip_Text[2], str )
    endfunction
    
    private function F_ON_Actions9 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = ClickPlayer
        local string str = ""
        
        call DzFrameShow(UI_Tip, true)
        call DzFrameSetText(UI_Tip_Text[1], "이동속도" )
        set str = "|cFFA5FA7D ◎ |r" + "|cFFA5FA7D" + R2S(  GetUnitMoveSpeed(MainUnit[pid])  ) + "|r"
        call DzFrameSetText(UI_Tip_Text[2], str )
    endfunction
    
    private function F_ON_Actions10 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = ClickPlayer
        local string str = ""
        
        call DzFrameShow(UI_Tip, true)
        call DzFrameSetText(UI_Tip_Text[1], "추가 드랍률" )
        set str = "|cFFA5FA7D ◎ |r" + "아이템 드랍 확률이 " + "|cFFA5FA7D" + I2S(  R2I(Equip_Drop[pid])  ) + "%|r 증가했습니다."
        call DzFrameSetText(UI_Tip_Text[2], str )
    endfunction
    
    private function F_ON_Actions11 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = ClickPlayer
        local string str = ""
        
        call DzFrameShow(UI_Tip, true)
        call DzFrameSetText(UI_Tip_Text[1], "공격력" )
        set str = "|cFFA5FA7D ◎ |r" + "공격력이 기본 공격력의 " + "|cFFA5FA7D" + I2S(  R2I(Equip_DamageP[pid])  ) + "%|r 증가했습니다."
        call DzFrameSetText(UI_Tip_Text[2], str )
    endfunction
    
    private function F_ON_Actions12 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = ClickPlayer
        local string str = ""
        
        call DzFrameShow(UI_Tip, true)
        call DzFrameSetText(UI_Tip_Text[1], "쿨타임 감소" )
        set str = "|cFFA5FA7D ◎ |r" + "신속 스텟에 의해 쿨타임이 " + "|cFFA5FA7D" + R2S(  (Equip_Swiftness[pid]/46)  ) + "%|r 감소합니다."
        call DzFrameSetText(UI_Tip_Text[2], str )
    endfunction
    
    private function F_ON_Actions13 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = ClickPlayer
        local string str = ""
        
        call DzFrameShow(UI_Tip, true)
        call DzFrameSetText(UI_Tip_Text[1], "방어력 관통" )
        set str = "|cFFA5FA7D ◎ |r" + "대상의 방어력을 " + "|cFFA5FA7D" + I2S(  R2I(Equip_Penetration[pid]) * 100  ) + "%|r 무시합니다."
        call DzFrameSetText(UI_Tip_Text[2], str )
    endfunction
    
    private function F_ON_Actions14 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = ClickPlayer
        local string str = ""
        
        call DzFrameShow(UI_Tip, true)
        call DzFrameSetText(UI_Tip_Text[1], "대미지 증가" )
        set str = "|cFFA5FA7D ◎ |r" + "가하는 피해가 " + "|cFFA5FA7D" + R2SW(  (Equip_DP[pid] - 1) * 100  ,1,2) + "%|r 증가합니다."
        call DzFrameSetText(UI_Tip_Text[2], str )
    endfunction
    
    private function F_ON_Actions15 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = ClickPlayer
        local string str = ""
        
        call DzFrameShow(UI_Tip, true)
        call DzFrameSetText(UI_Tip_Text[1], "최종 대미지 증가" )
        set str = "|cFFA5FA7D ◎ |r" + "최종적으로 가하는 피해가 " + "|cFFA5FA7D" + R2SW( (Equip_LastDamage[pid]) * 100 , 1,2) + "%|r 증가합니다."
        call DzFrameSetText(UI_Tip_Text[2], str )
    endfunction
    
    private function F_ON_Actions16 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = ClickPlayer
        local string str = ""
        
        call DzFrameShow(UI_Tip, true)
        call DzFrameSetText(UI_Tip_Text[1], "가상 전투력" )
        set str = "|cFFA5FA7D ◎ |r" + "스킬과 버프를 제외한 스텟을 가상의 전투력으로 표시합니다.|n"
        set str = str + "|cFFA5FA7D ◎ |r" + "아르카나에 의한 피해증가는 조건을 전부 만족한 최대치로 계산한다." 
        call DzFrameSetText(UI_Tip_Text[2], str )
    endfunction
    
    private function F_ON_Actions17 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = ClickPlayer
        local string str = ""
        
        call DzFrameShow(UI_Tip, true)
        call DzFrameSetText(UI_Tip_Text[1], "개척력" )
        set str = "|cFFA5FA7D ◎ |r" + "가상 전투력을 보정한 수치입니다.|n"
        set str = str + "|cFFA5FA7D ◎ |r" + "가상 전투력이 1000 이상일 경우 표시|n" 
        set str = str + "|cFFA5FA7D ◎ |r" + "가상 전투력이 약 10% 증가할 때마다 개척력이 약 1000 증가합니다.|n" 
        set str = str + "|cFFA5FA7D ◎ |r" + "아르카나에 의한 피해증가는 조건을 전부 만족한 최대치로 계산한다." 
        call DzFrameSetText(UI_Tip_Text[2], str )
    endfunction
        
    private function F_ON_Actions takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = ClickPlayer
        local string str = ""
        local string items = ""
        local integer itemid = 0
        local integer i = 0
        local integer quality = 0
        local integer up = 0
        local integer cts = 0
        local integer tier = 0
        local item tem
        
        // 0모자, 1상의, 2하의, 3장갑, 4견갑, 5무기, 6목걸이, 7귀걸이, 8귀걸이, 9반지, 10반지, 11팔찌, 12카드, 13보석, 14보석, 15??
        if f ==  F_EItemButtons2[0] then
            set items = Eitem[pid][0]
            set itemid = GetItemIDs(Eitem[pid][0])
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "모자" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
            /*
        elseif f ==  F_EItemButtons2[1] then
            set items = Eitem[pid][1]
            set itemid = GetItemIDs(Eitem[pid][1])
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "상의" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        elseif f ==  F_EItemButtons2[2] then
            set items = Eitem[pid][2]
            set itemid = GetItemIDs(Eitem[pid][2])
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "하의" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        elseif f ==  F_EItemButtons2[3] then
            set items = Eitem[pid][3]
            set itemid = GetItemIDs(Eitem[pid][3])
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "장갑" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        //elseif f ==  F_EItemButtons2[4] then
            //set items = Eitem[pid][4]
            //set itemid =GetItemIDs(Eitem[pid][4])
            //if itemid == 0 then
                //call DzFrameShow(UI_Tip, true)
                //call DzFrameSetText(UI_Tip_Text[1], "견갑" )
                //call DzFrameSetText(UI_Tip_Text[2], "")
            //endif
            */
        elseif f ==  F_EItemButtons2[5] then
            set items = Eitem[pid][5]
            set itemid = GetItemIDs(Eitem[pid][5])
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "무기" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        elseif f ==  F_EItemButtons2[6] then
            set items = Eitem[pid][6]
            set itemid = GetItemIDs(Eitem[pid][6])
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "목걸이" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        elseif f ==  F_EItemButtons2[7] then
            set items = Eitem[pid][7]
            set itemid = GetItemIDs(Eitem[pid][7])
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "귀걸이" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        elseif f ==  F_EItemButtons2[8] then
            set items = Eitem[pid][8]
            set itemid = GetItemIDs(Eitem[pid][8])
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "귀걸이" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        elseif f ==  F_EItemButtons2[9] then
            set items = Eitem[pid][9]
            set itemid = GetItemIDs(Eitem[pid][9])
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "반지" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        elseif f ==  F_EItemButtons2[10] then
            set items = Eitem[pid][10]
            set itemid = GetItemIDs(Eitem[pid][10])
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "반지" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        elseif f ==  F_EItemButtons2[11] then
            set items = Eitem[pid][11]
            set itemid = GetItemIDs(Eitem[pid][11])
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "팔찌" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        elseif f ==  F_EItemButtons2[12] then
            set items = Eitem[pid][12]
            set itemid = GetItemIDs(Eitem[pid][12])
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "카드" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        elseif f ==  F_EItemButtons2[13] then
            set items = Eitem[pid][13]
            set itemid = GetItemIDs(Eitem[pid][13])
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "보석" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        elseif f ==  F_EItemButtons2[14] then
            set items = Eitem[pid][14]
            set itemid = GetItemIDs(Eitem[pid][14])
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "보석2" )
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
                
            if i >= 6 and tier == 1 then
                call DzFrameSetText(UI_Tip_Text[1], GetItemNames(items) )
            else
                call DzFrameSetText(UI_Tip_Text[1], "+" + I2S(up) + " " + GetItemNames(items) )
            endif
            set str = "|cFFA5FA7D[ 종류 ]|r "
            // 0모자, 1상의, 2하의, 3장갑, 4견갑, 5무기, 6목걸이, 7귀걸이, 8반지, 9팔찌, 10카드, 11보석, 12보석2
            if i == 0 then
                set str = str + "모자|n|n"
                //set str = str + "  |cFFB9E2FA방어 등급|r +"
                set str = str + "  |cFFB9E2FA무기 공격력|r +"
                set str = str + JNStringSplit(ItemStats[i][tier],";", up )
                /*
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
                */
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
                    set str = str + "  [|cFFFFE400 " + ArcanaText[GetItemCombatBonus1(items)] + " |r] Lv "
                    set str = str + I2S(GetItemCombatBonus2(items))
                    set str = str + "|n  [|cFFFF0000 " + ArcanaText[GetItemCombatPenalty(items)] + " |r] Lv "
                    set str = str + I2S(GetItemCombatPenalty2(items))
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
                    set str = str + "  [|cFFFFE400 " + ArcanaText[GetItemCombatBonus1(items)] + " |r] Lv "
                    set str = str + I2S(GetItemCombatBonus2(items))
                    set str = str + "|n  [|cFFFF0000 " + ArcanaText[GetItemCombatPenalty(items)] + " |r] Lv "
                    set str = str + I2S(GetItemCombatPenalty2(items))
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
                    set str = str + "  [|cFFFFE400 " + ArcanaText[GetItemCombatBonus1(items)] + " |r] Lv "
                    set str = str + I2S(GetItemCombatBonus2(items))
                    set str = str + "|n  [|cFFFF0000 " + ArcanaText[GetItemCombatPenalty(items)] + " |r] Lv "
                    set str = str + I2S(GetItemCombatPenalty2(items))
                endif
            elseif i == 9 then
                set str = str + "팔찌|n|n"
            elseif i == 10 then
                set str = str + "카드|n|n"
                if GetItemCardBonus1(items) + GetItemCardBonus2(items) + GetItemCardBonus3(items) > 0 then
                    set str = str + "|n|n|cff5AD2FF[ 아르카나 ]|r|n"
                    set str = str + "  [|cFFFFE400 대미지 증가 |r] Lv "
                    set str = str + I2S(GetItemCardBonus1(items))
                    set str = str + "|n  [|cFFFFE400 대미지 증가 |r] Lv "
                    set str = str + I2S(GetItemCardBonus2(items))
                    set str = str + "|n  [|cFFFF0000 공격력 감소 |r] Lv "
                    set str = str + I2S(GetItemCardBonus3(items))
                endif
            elseif i == 11 then
                set str = str + "보석|n|n"
            elseif i == 12 then
                set str = str + "보석2|n|n"
            endif
            
            call DzFrameSetText(UI_Tip_Text[2], str)
        endif
    endfunction
    
    
    //장비 빈 버튼 아이콘 생성 함수
    private function CreateEItemButton takes integer types, real x, real y returns nothing
        set F_EItemButtons2[types]=DzCreateFrameByTagName("BUTTON", "", F_InfoBackDrop2, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetPoint(F_EItemButtons2[types], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2 , JN_FRAMEPOINT_BOTTOMLEFT, x, y)
        call DzFrameSetSize(F_EItemButtons2[types], 0.030, 0.030)
        
        set F_EItemButtons2BackDrop[types]=DzCreateFrameByTagName("BACKDROP", "", F_EItemButtons2[types], "", FrameCount())
        call DzFrameSetAllPoints(F_EItemButtons2BackDrop[types], F_EItemButtons2[types])
        call DzFrameSetTexture(F_EItemButtons2BackDrop[types],"UI_Inventory.blp", 0)
        
        call DzFrameSetScriptByCode(F_EItemButtons2[types], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions, false)
        call DzFrameSetScriptByCode(F_EItemButtons2[types], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        //call SaveInteger(Hash, F_EItemButtons2[types], StringHash("number"), types+201)
    endfunction
    
    
    private function InfoOpen takes nothing returns nothing
        local integer pid = ClickPlayer
        //메뉴 버튼을 누르면 메뉴 버튼 비활설화 + 메뉴 배경 표시
        //다시 메뉴 버튼을 누르면 메뉴버튼 활성화 + 메뉴 배경 숨김
        if F_Info2OnOff[pid] == true then
            call DzFrameShow(F_InfoBackDrop2, false)
            set F_Info2OnOff[pid] = false
        else
            if F_ArcanaOnOff[pid] == true then
                call DzFrameShow(F_ArcanaBackDrop, false)
                set F_ArcanaOnOff[pid] = false
            endif
            if F_InfoOnOff[pid] == true then
                call DzFrameShow(F_InfoBackDrop, false)
                set F_InfoOnOff[pid] = false
            endif
            call DzFrameShow(F_InfoBackDrop2, true)
            set F_Info2OnOff[pid] = true
        endif
    endfunction
    
    private function Main takes nothing returns nothing
        local string s
        local integer i
        call DzLoadToc("war3mapImported\\Templates.toc")
        
        //메뉴 배경
        set F_InfoBackDrop2=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "template", FrameCount())
        call DzFrameSetTexture(F_InfoBackDrop2, "File00005255.blp", 0)
        call DzFrameSetAbsolutePoint(F_InfoBackDrop2, JN_FRAMEPOINT_CENTER, 0.225, 0.315)
        call DzFrameSetSize(F_InfoBackDrop2, 0.40, 0.43)

        
        //메뉴 취소 버튼
        //set F_InfoCancelButton = DzCreateFrameByTagName("GLUETEXTBUTTON", "", F_InfoBackDrop2, "ScriptDialogButton", 0)
        //call DzFrameSetPoint(F_InfoCancelButton, JN_FRAMEPOINT_TOPRIGHT, F_InfoBackDrop2 , JN_FRAMEPOINT_TOPRIGHT, -0.010, -0.010)
        //call DzFrameSetText(F_InfoCancelButton, "X")
        //call DzFrameSetSize(F_InfoCancelButton, 0.03, 0.03)
        //call DzFrameSetScriptByCode(F_InfoCancelButton, JN_FRAMEEVENT_MOUSE_UP, function InfoOpen, false)
        
        
        // 0모자, 1상의, 2하의, 3장갑, 4견갑, 5무기, 6목걸이, 7귀걸이, 8귀걸이, 9반지, 10반지, 11팔찌, 12카드, 13보석, 14보석, 15??
        
        call CreateEItemButton(5 , 0.040 , 0.320)
        call CreateEItemButton(0 , 0.080 , 0.320)
        /*
        call CreateEItemButton(1 , 0.120 , 0.320)
        call CreateEItemButton(2 , 0.160 , 0.320)
        call CreateEItemButton(3 , 0.200 , 0.320)
        */

        //call CreateEItemButton(4 , 0.310 , 0.320)
        
        call CreateEItemButton(6 , 0.040 , 0.280)
        call CreateEItemButton(7 , 0.080 , 0.280)
        call CreateEItemButton(8 , 0.120 , 0.280)
        call CreateEItemButton(9 , 0.160 , 0.280)
        call CreateEItemButton(10 , 0.200 , 0.280)


        call CreateEItemButton(11 , 0.275 , 0.320)
        call CreateEItemButton(12 , 0.350 , 0.320)

        call CreateEItemButton(13 , 0.255 , 0.280)
        call CreateEItemButton(14 , 0.295 , 0.280)
        call CreateEItemButton(15 , 0.350 , 0.280)
        
        set i=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(i, JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.055, 0.235)
        call DzFrameSetText(i, "기본 정보")

        set F_ItemStatsText2[0]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[0], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.085, 0.215)
        call DzFrameSetText(F_ItemStatsText2[0], "|cFFFFE400공격력")
        
        set F_ItemStatsText2[0]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[0], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.165, 0.215)
        call DzFrameSetText(F_ItemStatsText2[0], "0")
        call DzFrameSetScriptByCode(F_ItemStatsText2[0], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions1, false)
        call DzFrameSetScriptByCode(F_ItemStatsText2[0], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        /*
        set F_ItemStatsText2[1]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[1], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.085, 0.195)
        call DzFrameSetText(F_ItemStatsText2[1], "|cFFFFE400방어 등급")
        
        set F_ItemStatsText2[1]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[1], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.165, 0.195)
        call DzFrameSetText(F_ItemStatsText2[1], "0")
        call DzFrameSetScriptByCode(F_ItemStatsText2[1], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions2, false)
        call DzFrameSetScriptByCode(F_ItemStatsText2[1], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        */
        
        set F_ItemStatsText2[2]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[2], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.085, 0.175)
        call DzFrameSetText(F_ItemStatsText2[2], "|cFFFFE400치명")
        
        set F_ItemStatsText2[2]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[2], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.165, 0.175)
        call DzFrameSetText(F_ItemStatsText2[2], "0")
        call DzFrameSetScriptByCode(F_ItemStatsText2[2], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions3, false)
        call DzFrameSetScriptByCode(F_ItemStatsText2[2], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        set F_ItemStatsText2[3]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[3], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.085, 0.155)
        call DzFrameSetText(F_ItemStatsText2[3], "|cFFFFE400신속")
        
        set F_ItemStatsText2[3]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[3], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.165, 0.155)
        call DzFrameSetText(F_ItemStatsText2[3], "0")
        call DzFrameSetScriptByCode(F_ItemStatsText2[3], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions5, false)
        call DzFrameSetScriptByCode(F_ItemStatsText2[3], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        set i=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(i, JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.055, 0.135)
        call DzFrameSetText(i, "추가 정보")

        set F_ItemStatsText2[4]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[4], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.085, 0.115)
        call DzFrameSetText(F_ItemStatsText2[4], "|cFFFFE400추가 피해")
        
        set F_ItemStatsText2[4]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[4], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.165, 0.115)
        call DzFrameSetText(F_ItemStatsText2[4], "0")
        call DzFrameSetScriptByCode(F_ItemStatsText2[4], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions6, false)
        call DzFrameSetScriptByCode(F_ItemStatsText2[4], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)

        set F_ItemStatsText2[5]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[5], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.085, 0.095)
        call DzFrameSetText(F_ItemStatsText2[5], "|cFFFFE400치명타 확률")
        
        set F_ItemStatsText2[5]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[5], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.165, 0.095)
        call DzFrameSetText(F_ItemStatsText2[5], "0")
        call DzFrameSetScriptByCode(F_ItemStatsText2[5], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions7, false)
        call DzFrameSetScriptByCode(F_ItemStatsText2[5], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        set F_ItemStatsText2[6]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[6], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.085, 0.075)
        call DzFrameSetText(F_ItemStatsText2[6], "|cFFFFE400공격속도")
        
        set F_ItemStatsText2[6]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[6], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.165, 0.075)
        call DzFrameSetText(F_ItemStatsText2[6], "0")
        call DzFrameSetScriptByCode(F_ItemStatsText2[6], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions8, false)
        call DzFrameSetScriptByCode(F_ItemStatsText2[6], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        set F_ItemStatsText2[7]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[7], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.085, 0.055)
        call DzFrameSetText(F_ItemStatsText2[7], "|cFFFFE400이동속도")
        
        set F_ItemStatsText2[7]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[7], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.165, 0.055)
        call DzFrameSetText(F_ItemStatsText2[7], "0")
        call DzFrameSetScriptByCode(F_ItemStatsText2[7], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions9, false)
        call DzFrameSetScriptByCode(F_ItemStatsText2[7], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        set F_ItemStatsText2[8]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[8], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.085, 0.035)
        call DzFrameSetText(F_ItemStatsText2[8], "|cFFFFE400추가 드랍률")
        
        set F_ItemStatsText2[8]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[8], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.165, 0.035)
        call DzFrameSetText(F_ItemStatsText2[8], "0")
        call DzFrameSetScriptByCode(F_ItemStatsText2[8], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions10, false)
        call DzFrameSetScriptByCode(F_ItemStatsText2[8], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        set F_ItemStatsText2[9]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[9], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.250, 0.115)
        call DzFrameSetText(F_ItemStatsText2[9], "|cFFFFE400공격력")
        
        set F_ItemStatsText2[9]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[9], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.325, 0.115)
        call DzFrameSetText(F_ItemStatsText2[9], "0")
        call DzFrameSetScriptByCode(F_ItemStatsText2[9], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions11, false)
        call DzFrameSetScriptByCode(F_ItemStatsText2[9], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        set F_ItemStatsText2[10]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[10], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.250, 0.095)
        call DzFrameSetText(F_ItemStatsText2[10], "|cFFFFE400쿨타임 감소")
        
        set F_ItemStatsText2[10]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[10], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.325, 0.095)
        call DzFrameSetText(F_ItemStatsText2[10], "0")
        call DzFrameSetScriptByCode(F_ItemStatsText2[10], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions12, false)
        call DzFrameSetScriptByCode(F_ItemStatsText2[10], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        set F_ItemStatsText2[11]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[11], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.250, 0.075)
        call DzFrameSetText(F_ItemStatsText2[11], "|cFFFFE400방어력 관통")
        
        set F_ItemStatsText2[11]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[11], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.325, 0.075)
        call DzFrameSetText(F_ItemStatsText2[11], "0")
        call DzFrameSetScriptByCode(F_ItemStatsText2[11], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions13, false)
        call DzFrameSetScriptByCode(F_ItemStatsText2[11], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        set F_ItemStatsText2[12]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[12], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.250, 0.055)
        call DzFrameSetText(F_ItemStatsText2[12], "|cFFFFE400대미지 증가")
        
        set F_ItemStatsText2[12]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[12], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.325, 0.055)
        call DzFrameSetText(F_ItemStatsText2[12], "0")
        call DzFrameSetScriptByCode(F_ItemStatsText2[12], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions14, false)
        call DzFrameSetScriptByCode(F_ItemStatsText2[12], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        set F_ItemStatsText2[13]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[13], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.250, 0.035)
        call DzFrameSetText(F_ItemStatsText2[13], "|cFFFFE400최종 대미지 증가")
        
        set F_ItemStatsText2[13]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[13], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.325, 0.035)
        call DzFrameSetText(F_ItemStatsText2[13], "0")
        call DzFrameSetScriptByCode(F_ItemStatsText2[13], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions15, false)
        call DzFrameSetScriptByCode(F_ItemStatsText2[13], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        set F_ItemStatsText2[14]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[14], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.295, 0.215)
        call DzFrameSetText(F_ItemStatsText2[14], "|cFFFFE400가상 전투력")
        
        set F_ItemStatsText2[14]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[14], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.295, 0.195)
        call DzFrameSetText(F_ItemStatsText2[14], "0")
        call DzFrameSetScriptByCode(F_ItemStatsText2[14], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions16, false)
        call DzFrameSetScriptByCode(F_ItemStatsText2[14], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        set F_ItemStatsText2[15]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[15], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.295, 0.175)
        call DzFrameSetText(F_ItemStatsText2[15], "|cFFFFE400개척력")
        
        set F_ItemStatsText2[15]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[15], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.295, 0.155)
        call DzFrameSetText(F_ItemStatsText2[15], "0")
        call DzFrameSetScriptByCode(F_ItemStatsText2[15], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions17, false)
        call DzFrameSetScriptByCode(F_ItemStatsText2[15], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        set F_ItemStatsText2[16]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[16], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.200, 0.400)
        call DzFrameSetText(F_ItemStatsText2[16], "아이디는가나다라마바사아")

        //vip이름
        set F_ItemStatsText2[17]=DzCreateFrameByTagName("TEXT", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsText2[17], JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.200, 0.380)
        call DzFrameSetText(F_ItemStatsText2[17], "")

        set F_ItemStatsIcon2=DzCreateFrameByTagName("BACKDROP", "", F_InfoBackDrop2, "", FrameCount())
        call DzFrameSetPoint(F_ItemStatsIcon2, JN_FRAMEPOINT_CENTER, F_InfoBackDrop2, JN_FRAMEPOINT_BOTTOMLEFT, 0.070, 0.380)
        call DzFrameSetTexture(F_ItemStatsIcon2, "File00005255.blp", 0)
        call DzFrameSetSize(F_ItemStatsIcon2, 0.06, 0.06)
        
        
        call DzFrameShow(F_InfoBackDrop2, false)
    endfunction
    
    private function TABKey takes nothing returns nothing
        local integer key = DzGetTriggerKey()
        local integer i = 0
        local integer j = GetPlayerId(DzGetTriggerKeyPlayer())
        
        if DzGetTriggerKeyPlayer()==GetLocalPlayer() then
            set i = JNMemoryGetByte(JNGetModuleHandle("Game.dll")+0xD04FEC)
        endif
        
        if i==1 then
        else
            if PickCheck[j] == true then
                if key == JN_OSKEY_TAB then
                    if F_Info2OnOff[j] == true then
                        call DzFrameShow(F_InfoBackDrop2, false)
                        set F_Info2OnOff[j] = false
                    else
                        if F_ArcanaOnOff[j] == true then
                            call DzFrameShow(F_ArcanaBackDrop, false)
                            set F_ArcanaOnOff[j] = false
                        endif
                        if F_InfoOnOff[j] == true then
                            call DzFrameShow(F_InfoBackDrop, false)
                            set F_InfoOnOff[j] = false
                        endif
                        call DzFrameShow(F_InfoBackDrop2, true)
                        set F_Info2OnOff[j] = true
                    endif
                endif
            endif
        endif
    endfunction
    

    private function SELECTEDAction takes nothing returns nothing
        local unit u = GetTriggerUnit()
        local real r =0
        local integer speed = 0
        local integer pid = GetPlayerId(GetOwningPlayer(u))
        //call DzFrameSetValue(bar, GetUnitLifePercent(u))

        //플레이어를 클릭함
        if GetPlayerId(GetOwningPlayer(u)) < 4 then
            set Stats_Crit[pid] = (Equip_Crit[pid]/28) + Hero_CriRate[pid] + Arcana_Cri[pid]
            set speed = R2I(  (Equip_Swiftness[pid]/45) + 100 + Hero_BuffMoveSpeed[pid] + Arcana_MoveSpeed[pid] )
            if speed > 140 then
                set speed = 140
            endif
            if ( GetTriggerPlayer() == GetLocalPlayer() ) then
                //클릭한 플레이어 저장
                set ClickPlayer = pid

                //플레이어아이디
                call DzFrameSetText(F_ItemStatsText2[16], GetPlayerName(Player(pid)) )

                //공격력
                call DzFrameSetText(F_ItemStatsText2[0], I2S(R2I( Equip_Damage[pid] + Hero_Damage[pid]  ) ) )
                //방어등급
                //call DzFrameSetText(F_ItemStatsText2[1], I2S(R2I( Equip_Defense[pid] + Arcana_Defense[pid] )) )
                //치명
                call DzFrameSetText(F_ItemStatsText2[2], I2S(R2I( Equip_Crit[pid] )) )
                //신속
                call DzFrameSetText(F_ItemStatsText2[3], I2S(R2I( Equip_Swiftness[pid] )) )
                //추가피해
                call DzFrameSetText(F_ItemStatsText2[4], I2S(R2I( Equip_WDP[pid] + Arcana_DP[pid] + Equip_ED[pid] )) + "%" )
                //치명타확률
                call DzFrameSetText(F_ItemStatsText2[5], I2S(R2I( Stats_Crit[pid] )) + "%")
                //공격속도
                call DzFrameSetText(F_ItemStatsText2[6], I2S(R2I( 100 + SkillSpeed(pid) )) + "%" )
                //이동속도
                call DzFrameSetText(F_ItemStatsText2[7], I2S(speed) + "%" )
                //드랍률
                call DzFrameSetText(F_ItemStatsText2[8], I2S(R2I(  Equip_Drop[pid] )) + "%" ) 
                //공퍼
                call DzFrameSetText(F_ItemStatsText2[9], I2S(R2I(  Equip_DamageP[pid] )) + "%" ) 
                //쿨감
                call DzFrameSetText(F_ItemStatsText2[10], R2S(  (Equip_Swiftness[pid]/46)  ) + "%" ) 
                //방관
                call DzFrameSetText(F_ItemStatsText2[11], I2S(R2I(  Equip_Penetration[pid] )) + "%" ) 
                //대미지증가
                call DzFrameSetText(F_ItemStatsText2[12], R2SW(( Equip_DP[pid] - 1) * 100  ,1,2) + "%" ) 
                //카드댐증
                call DzFrameSetText(F_ArcanaStatsText[9], R2SW( ((100 + Equip_CardDamage1[pid]) * (100 + Equip_CardDamage2[pid]) - 10000 ) / 100 ,1,2)  + "%" ) 
                //최종대미지증가
                call DzFrameSetText(F_ItemStatsText2[13], I2S(R2I(  Equip_LastDamage[pid] )) + "%" ) 
                //가상 전투력
                set r = Power(pid)
                call DzFrameSetText(F_ItemStatsText2[14], R2SW(r, 1, 2) ) 
                //개척력
                //call DzFrameSetText(F_ItemStatsText2[15], I2S(R2I(  TrailblazePower(r) )) ) 
                call DzFrameSetText(F_ItemStatsText2[15], R2SW(TrailblazePower(r), 1, 2)) 
                if Eitem[pid][0] != "0" and Eitem[pid][0] != "" and Eitem[pid][0] != null then
                    call DzFrameSetTexture(F_EItemButtons2BackDrop[0], GetItemArt(Eitem[pid][0]), 0)
                else
                    call DzFrameSetTexture(F_EItemButtons2BackDrop[0], "UI_Inventory.blp", 0)
                endif
                /*
                if Eitem[pid][1] != "0" and Eitem[pid][1] != "" and Eitem[pid][1] != null then
                    call DzFrameSetTexture(F_EItemButtons2BackDrop[1], GetItemArt(Eitem[pid][1]), 0)
                else
                    call DzFrameSetTexture(F_EItemButtons2BackDrop[1], "UI_Inventory.blp", 0)
                endif
                if Eitem[pid][2] != "0" and Eitem[pid][2] != "" and Eitem[pid][2] != null then
                    call DzFrameSetTexture(F_EItemButtons2BackDrop[2], GetItemArt(Eitem[pid][2]), 0)
                else
                    call DzFrameSetTexture(F_EItemButtons2BackDrop[2], "UI_Inventory.blp", 0)
                endif
                if Eitem[pid][3] != "0" and Eitem[pid][3] != "" and Eitem[pid][3] != null then
                    call DzFrameSetTexture(F_EItemButtons2BackDrop[3], GetItemArt(Eitem[pid][3]), 0)
                else
                    call DzFrameSetTexture(F_EItemButtons2BackDrop[3], "UI_Inventory.blp", 0)
                endif
                */
                //if Eitem[pid][4] != "0" then
                    //call DzFrameSetTexture(F_EItemButtons2BackDrop[4], GetItemArt(Eitem[pid][4]), 0)
                //endif
                if Eitem[pid][5] != "0" and Eitem[pid][5] != "" and Eitem[pid][5] != null then
                    call DzFrameSetTexture(F_EItemButtons2BackDrop[5], GetItemArt(Eitem[pid][5]), 0)
                else
                    call DzFrameSetTexture(F_EItemButtons2BackDrop[5], "UI_Inventory.blp", 0)
                endif
                if Eitem[pid][6] != "0" and Eitem[pid][6] != "" and Eitem[pid][6] != null then
                    call DzFrameSetTexture(F_EItemButtons2BackDrop[6], GetItemArt(Eitem[pid][6]), 0)
                else
                    call DzFrameSetTexture(F_EItemButtons2BackDrop[6], "UI_Inventory.blp", 0)
                endif
                if Eitem[pid][7] != "0" and Eitem[pid][7] != "" and Eitem[pid][7] != null then
                    call DzFrameSetTexture(F_EItemButtons2BackDrop[7], GetItemArt(Eitem[pid][7]), 0)
                else
                    call DzFrameSetTexture(F_EItemButtons2BackDrop[7], "UI_Inventory.blp", 0)
                endif
                if Eitem[pid][8] != "0" and Eitem[pid][8] != "" and Eitem[pid][8] != null then
                    call DzFrameSetTexture(F_EItemButtons2BackDrop[8], GetItemArt(Eitem[pid][8]), 0)
                else
                    call DzFrameSetTexture(F_EItemButtons2BackDrop[8], "UI_Inventory.blp", 0)
                endif
                if Eitem[pid][9] != "0" and Eitem[pid][9] != "" and Eitem[pid][9] != null then
                    call DzFrameSetTexture(F_EItemButtons2BackDrop[9], GetItemArt(Eitem[pid][9]), 0)
                else
                    call DzFrameSetTexture(F_EItemButtons2BackDrop[9], "UI_Inventory.blp", 0)
                endif
                if Eitem[pid][10] != "0" and Eitem[pid][10] != "" and Eitem[pid][10] != null then
                    call DzFrameSetTexture(F_EItemButtons2BackDrop[10], GetItemArt(Eitem[pid][10]), 0)
                else
                    call DzFrameSetTexture(F_EItemButtons2BackDrop[10], "UI_Inventory.blp", 0)
                endif
                if Eitem[pid][11] != "0" and Eitem[pid][11] != "" and Eitem[pid][11] != null then
                    call DzFrameSetTexture(F_EItemButtons2BackDrop[11], GetItemArt(Eitem[pid][11]), 0)
                else
                    call DzFrameSetTexture(F_EItemButtons2BackDrop[11], "UI_Inventory.blp", 0)
                endif
                if Eitem[pid][12] != "0" and Eitem[pid][12] != "" and Eitem[pid][12] != null then
                    call DzFrameSetTexture(F_EItemButtons2BackDrop[12], GetItemArt(Eitem[pid][12]), 0)
                else
                    call DzFrameSetTexture(F_EItemButtons2BackDrop[12], "UI_Inventory.blp", 0)
                endif
                if Eitem[pid][13] != "0" and Eitem[pid][13] != "" and Eitem[pid][13] != null then
                    call DzFrameSetTexture(F_EItemButtons2BackDrop[13], GetItemArt(Eitem[pid][13]), 0)
                else
                    call DzFrameSetTexture(F_EItemButtons2BackDrop[13], "UI_Inventory.blp", 0)
                endif
                if Eitem[pid][14] != "0" and Eitem[pid][14] != "" and Eitem[pid][14] != null then
                    call DzFrameSetTexture(F_EItemButtons2BackDrop[14], GetItemArt(Eitem[pid][14]), 0)
                else
                    call DzFrameSetTexture(F_EItemButtons2BackDrop[14], "UI_Inventory.blp", 0)
                endif
                if Eitem[pid][15] != "0" and Eitem[pid][15] != "" and Eitem[pid][15] != null then
                    call DzFrameSetTexture(F_EItemButtons2BackDrop[15], GetItemArt(Eitem[pid][15]), 0)
                else
                    call DzFrameSetTexture(F_EItemButtons2BackDrop[15], "UI_Inventory.blp", 0)
                endif
            endif
        endif
        set u = null
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer index
        
        call TriggerRegisterTimerEventSingle( t, 3.0 )
        call TriggerAddAction( t, function Main )
        call DzLoadToc("war3mapimported\\BoxedText.toc")
        
        set index = 0
        loop
            set F_Info2OnOff[index] = false
            set index = index + 1
            exitwhen index == 4
        endloop
        
        //P버튼으로 인포창 열기 및 닫기
        call DzTriggerRegisterKeyEventByCode(null, JN_OSKEY_TAB, 0, false, function TABKey)
        
        set t = CreateTrigger()
        set index = 0
        loop
            call TriggerRegisterPlayerUnitEvent(t, Player(index), EVENT_PLAYER_UNIT_SELECTED, null)
            set index = index + 1
            exitwhen index == bj_MAX_PLAYER_SLOTS
        endloop
        call TriggerAddAction( t, function SELECTEDAction )

        set t = null
    endfunction
endlibrary