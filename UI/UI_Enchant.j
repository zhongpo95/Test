library UIEnchant initializer Init requires DataItem, UIItem, ITEM, FrameCount
    globals
        integer F_EnchantBackDrop                   //인포 배경
        integer F_EnchantCancelButton               //X버튼
        integer array F_EEItemButtons               //장비아이템 버튼들
        integer array F_EEItemButtonsBackDrop       //장비 아이템 버튼 배경 아이콘들
        boolean array F_EnchantOnOff                //인포 온오프
        integer F_EnchantSelectNumber               //누른아이템번호저장
        //integer F_EnchantSelect                   //누른아이템
        integer F_EnchantUpText                     //강화단계
        integer F_EnchantRateText                   //확률
        integer F_EnchantFateText                   //장기
        integer array F_EnchantText                 //장기
        integer F_EnchantButton                     //강화버튼
        integer F_EnchantButtonBD                   //강화버튼
        integer F_EnchantButton2                    //계승버튼
        integer F_EnchantButtonBD2                  //계승버튼
        
    endglobals
    
    private function F_OFF_Actions takes nothing returns nothing
        call DzFrameShow(UI_Tip, false)
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
        local integer tier = 0
        local item tem
        local string sn = I2S(PlayerSlotNumber[pid])
        
        if f ==  F_EEItemButtons[0] then
            set items = Eitem[pid][0]
            set itemid = GetItemIDs(items)
        elseif f ==  F_EEItemButtons[1] then
            set items = Eitem[pid][1]
            set itemid = GetItemIDs(items)
        elseif f ==  F_EEItemButtons[2] then
            set items = Eitem[pid][2]
            set itemid = GetItemIDs(items)
        elseif f ==  F_EEItemButtons[3] then
            set items = Eitem[pid][3]
            set itemid = GetItemIDs(items)
        elseif f ==  F_EEItemButtons[4] then
            set items = Eitem[pid][4]
            set itemid = GetItemIDs(items)
        elseif f ==  F_EEItemButtons[5] then
            set items = Eitem[pid][5]
            set itemid = GetItemIDs(items)
        elseif f ==  F_EEItemButtons[6] then
            set items = Eitem[pid][F_EnchantSelectNumber]
            set itemid = GetItemIDs(items)
        elseif f ==  F_EEItemButtons[7] then
            set items = Eitem[pid][F_EnchantSelectNumber]
            set itemid = GetItemIDs(items)
        elseif f ==  F_EEItemButtons[8] then
            set items = Eitem[pid][F_EnchantSelectNumber]
            set itemid = GetItemIDs(items)
            if itemid == 2 then
                 set items = "ID17;"
                set itemid = 17
            elseif itemid == 3 then
                 set items = "ID18;"
                set itemid = 18
            elseif itemid == 4 then
                 set items = "ID19;"
                set itemid = 19
            elseif itemid == 6 then
                 set items = "ID20;"
                set itemid = 20
            elseif itemid == 5 then
                 set items = "ID21;"
                set itemid = 21
            elseif itemid == 1 then
                 set items = "ID22;"
                set itemid = 22
            elseif itemid == 17 then
                 set items = "ID23;"
                set itemid = 23
            elseif itemid == 18 then
                 set items = "ID24;"
                set itemid = 24
            elseif itemid == 19 then
                 set items = "ID25;"
                set itemid = 25
            elseif itemid == 20 then
                 set items = "ID26;"
                set itemid = 26
            elseif itemid == 21 then
                 set items = "ID27;"
                set itemid = 27
            elseif itemid == 22 then
                 set items = "ID28;"
                set itemid = 28
            elseif itemid == 23 then
                 set items = "ID29;"
                set itemid = 29
            elseif itemid == 24 then
                 set items = "ID30;"
                set itemid = 30
            elseif itemid == 25 then
                 set items = "ID31;"
                set itemid = 31
            elseif itemid == 26 then
                 set items = "ID32;"
                set itemid = 32
            elseif itemid == 27 then
                 set items = "ID33;"
                set itemid = 33
            elseif itemid == 28 then
                 set items = "ID34;"
                set itemid = 34
            elseif itemid == 29 then
                 set items = "ID35;"
                set itemid = 35
            elseif itemid == 30 then
                 set items = "ID36;"
                set itemid = 36
            endif
            if itemid == 31 then
                 set items = "ID37;"
                set itemid = 37
            elseif itemid == 32 then
                 set items = "ID38;"
                set itemid = 38
            elseif itemid == 33 then
                 set items = "ID39;"
                set itemid = 39
            elseif itemid == 34 then
                 set items = "ID40;"
                set itemid = 40
            elseif itemid == 35 then
                 set items = "ID41;"
                set itemid = 41
            elseif itemid == 36 then
                 set items = "ID42;"
                set itemid = 42
            elseif itemid == 37 then
                 set items = "ID43;"
                set itemid = 43
            elseif itemid == 38 then
                 set items = "ID44;"
                set itemid = 44
            elseif itemid == 39 then
                 set items = "ID45;"
                set itemid = 45
            elseif itemid == 40 then
                 set items = "ID46;"
                set itemid = 46
            elseif itemid == 41 then
                 set items = "ID47;"
                set itemid = 47
            elseif itemid == 42 then
                 set items = "ID48;"
                set itemid = 48
            elseif itemid == 43 then
                 set items = "ID49;"
                set itemid = 49
            elseif itemid == 44 then
                 set items = "ID50;"
                set itemid = 50
            elseif itemid == 45 then
                 set items = "ID51;"
                set itemid = 51
            elseif itemid == 46 then
                 set items = "ID52;"
                set itemid = 52
            elseif itemid == 47 then
                 set items = "ID53;"
                set itemid = 53
            elseif itemid == 48 then
                 set items = "ID54;"
                set itemid = 54
            elseif itemid == 49 then
                 set items = "ID55;"
                set itemid = 55
            elseif itemid == 50 then
                 set items = "ID56;"
                set itemid = 56
            elseif itemid == 51 then
                 set items = "ID57;"
                set itemid = 57
            elseif itemid == 52 then
                 set items = "ID58;"
                set itemid = 58
            endif
        
        elseif f ==  F_EEItemButtons[9] then
            
        endif
        
        // 0모자, 1상의, 2하의, 3장갑, 4견갑, 5무기, 6목걸이, 7귀걸이, 8반지, 9팔찌, 10카드
        //장비 0아이템아이디, 1강화수치, 2품질, 3트라이횟수, 4장인의기운
        //악세 0아이템아이디, 1강화수치, 2품질, 3특성, 4각인1, 5각인수치, 6각인2, 7각인수치, 8각인P, 9각인P수치, 10잠금
        //목걸이 0스탯, 1체력, 2품0, 3품질 5당 추가량
        //기타 0아이템아이디, 1중첩수
                
        if F_EnchantSelectNumber == 6 then
            set itemid = 0
        endif
    
        if itemid != 0 then
            call DzFrameShow(UI_Tip, true)
            set i = GetItemTypes(items)
            set up = GetItemUp(items)
            set quality = GetItemQuality(items)
            set tier = GetItemTier(items)
                
            if tier == 1 or i != 5 then
                call DzFrameSetText(UI_Tip_Text[1], GetItemNames(items) )
            else
                call DzFrameSetText(UI_Tip_Text[1], "+" + I2S(up) + " " + GetItemNames(items) )
            endif
            set str = "|cFFA5FA7D[ 종류 ]|r "
            // 0모자, 1상의, 2하의, 3장갑, 4견갑, 5무기, 6목걸이, 7귀걸이, 8반지, 9팔찌, 10카드
            if i == 0 then
                set str = str + "모자|n"
                set str = str + "|n|cff5AD2FF[ 효과 ]|r|n"
                set str = str + "  |cFFB9E2FA방어 등급|r +"
                set str = str + JNStringSplit(ItemStats[i][tier],";", up )
            elseif i == 1 then
                set str = str + "상의|n"
                set str = str + "|n|cff5AD2FF[ 효과 ]|r|n"
                set str = str + "  |cFFB9E2FA방어 등급|r +"
                set str = str + JNStringSplit(ItemStats[i][tier],";", up )
            elseif i == 2 then
                set str = str + "하의|n"
                set str = str + "|n|cff5AD2FF[ 효과 ]|r|n"
                set str = str + "  |cFFB9E2FA방어 등급|r +"
                set str = str + JNStringSplit(ItemStats[i][tier],";", up )
            elseif i == 3 then
                set str = str + "장갑|n"
                set str = str + "|n|cff5AD2FF[ 효과 ]|r|n"
                set str = str + "  |cFFB9E2FA방어 등급|r +"
                set str = str + JNStringSplit(ItemStats[i][tier],";", up )
            elseif i == 4 then
                set str = str + "견갑|n"
                set str = str + "|n|cff5AD2FF[ 효과 ]|r|n"
                set str = str + "  |cFFB9E2FA방어 등급|r +"
                set str = str + JNStringSplit(ItemStats[i][tier],";", up )
            elseif i == 5 then
                set str = str + "무기|n"
                set str = str + "|n|cff5AD2FF[ 효과 ]|r|n"
                set str = str + "  |cFFB9E2FA무기 공격력|r +"
                set str = str + JNStringSplit(ItemStats[i][tier],";", up )
                set str = str + "|n|n|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                set str = str + "  |cFFB9E2FA추가 피해|r +"
                set str = str + R2S(ItemWeaponQuality[quality]) + "%"
            endif
            
            call DzFrameSetText(UI_Tip_Text[2], str)
        endif
    endfunction
    
    private function EnchantOpen takes nothing returns nothing
        if F_EnchantOnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] == true then
            call DzFrameShow(F_EnchantBackDrop, false)
            set F_EnchantOnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = false
        else
            call DzFrameShow(F_EnchantBackDrop, true)
            set F_EnchantOnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = true
        endif
    endfunction
    
    private function ClickButton2 takes nothing returns nothing
        call DzSyncData(("Enchant"),I2S(F_EnchantSelectNumber))
    endfunction
    
    private function ClickButton3 takes nothing returns nothing
        call DzSyncData(("Success"),I2S(F_EnchantSelectNumber))
    endfunction
    
    private function ButtonSuccess takes nothing returns nothing
        local integer f = S2I(DzGetTriggerSyncData())
        local integer pid = GetPlayerId(DzGetTriggerSyncPlayer())
        local string items
        local integer i = 0
        local integer quality = 0
        local integer j = 0
        local integer k = 0
        local integer loopA = 0
        local integer tier = 0
        local integer length = 0
        local integer l = 1
        local integer tip = 0
        local string sn = I2S(PlayerSlotNumber[pid])
        
        if Player(pid) == GetLocalPlayer() then
            if true then
            //if JNObjectCharacterServerConnectCheck( ) then
                set items = Eitem[pid][f]
                set i = GetItemIDs(items)
                set quality = GetItemQuality(items)
                set tier = GetItemTier(items)
                set tip = GetItemTypes(items)
                if tip == 5 then
                    set l = 2
                endif
                if tier == 1 then
                    set k = 59
                elseif tier == 2 then
                    set k = 60
                elseif tier == 3 then
                    set k = 61
                elseif tier == 4 then
                    set k = 62
                elseif tier == 5 then
                    set k = 63
                elseif tier == 6 then
                    set k = 64
                elseif tier == 7 then
                    set k = 65
                endif
                
                set j = 0
                set loopA = 50
                loop
                    exitwhen loopA == 100
                    //보유중
                    if GetItemIDs(StashLoad(PLAYER_DATA[pid], "슬롯"+sn+".아이템"+I2S(loopA), "0")) == k then
                        set j = GetItemCharge(StashLoad(PLAYER_DATA[pid], "슬롯"+sn+".아이템"+I2S(loopA), "0"))
                        set items = StashLoad(PLAYER_DATA[pid], "슬롯"+sn+".아이템"+I2S(loopA), "0")
                        if l <= j then
                            if (j-l) == 0 then
                                //아이템지우기
                                call DzFrameSetTexture(F_ItemButtonsBackDrop[loopA], "UI_Inventory.blp", 0)
                                call DzFrameShow(UI_Tip, false)
                                call StashRemove(PLAYER_DATA[pid], "슬롯"+sn+".아이템"+I2S(loopA))
                            else
                                if j >= 1000 then
                                    set length = JNStringLength(StashLoad(PLAYER_DATA[pid], "슬롯"+sn+".아이템"+I2S(loopA), "0"))
                                    set items = JNStringSub(items,0,length-4) + I2S(j-l)
                                elseif j >= 100 then
                                    set length = JNStringLength(StashLoad(PLAYER_DATA[pid], "슬롯"+sn+".아이템"+I2S(loopA), "0"))
                                    set items = JNStringSub(items,0,length-3) + I2S(j-l)
                                elseif j >= 10 then
                                    set length = JNStringLength(StashLoad(PLAYER_DATA[pid], "슬롯"+sn+".아이템"+I2S(loopA), "0"))
                                    set items = JNStringSub(items,0,length-2) + I2S(j-l)
                                else
                                    set length = JNStringLength(StashLoad(PLAYER_DATA[pid], "슬롯"+sn+".아이템"+I2S(loopA), "0"))
                                    set items = JNStringSub(items,0,length-1) + I2S(j-l)
                                endif
                                set items = SetItemCharge(items, j-l)
                                call StashSave(PLAYER_DATA[pid], "슬롯"+sn+".아이템"+I2S(loopA), items)
                            endif
                            
                            if i == 2 then
                                 set items = "ID17;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 3 then
                                 set items = "ID18;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 4 then
                                 set items = "ID19;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 6 then
                                 set items = "ID20;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 5 then
                                 set items = "ID21;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 1 then
                                 set items = "ID22;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 17 then
                                 set items = "ID23;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 18 then
                                 set items = "ID24;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 19 then
                                 set items = "ID25;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 20 then
                                 set items = "ID26;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 21 then
                                 set items = "ID27;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 22 then
                                 set items = "ID28;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 23 then
                                 set items = "ID29;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 24 then
                                 set items = "ID30;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 25 then
                                 set items = "ID31;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 26 then
                                 set items = "ID32;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 27 then
                                 set items = "ID33;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 28 then
                                 set items = "ID34;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 29 then
                                 set items = "ID35;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 30 then
                                 set items = "ID36;"
                                set items = SetItemQuality(items, quality)
                            endif
                            
                            if i == 31 then
                                 set items = "ID37;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 32 then
                                 set items = "ID38;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 33 then
                                 set items = "ID39;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 34 then
                                 set items = "ID40;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 35 then
                                 set items = "ID41;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 36 then
                                 set items = "ID42;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 37 then
                                 set items = "ID43;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 38 then
                                 set items = "ID44;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 39 then
                                 set items = "ID45;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 40 then
                                 set items = "ID46;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 41 then
                                 set items = "ID47;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 42 then
                                 set items = "ID48;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 43 then
                                 set items = "ID49;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 44 then
                                 set items = "ID50;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 45 then
                                 set items = "ID51;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 46 then
                                 set items = "ID52;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 47 then
                                 set items = "ID53;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 48 then
                                 set items = "ID54;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 49 then
                                 set items = "ID55;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 50 then
                                 set items = "ID56;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 51 then
                                 set items = "ID57;"
                                set items = SetItemQuality(items, quality)
                            elseif i == 52 then
                                 set items = "ID58;"
                                set items = SetItemQuality(items, quality)
                            endif
                            
                            set Eitem[pid][f] = items
                            call DzSyncData("장착",I2S(pid)+"\t"+I2S(f)+"\t"+Eitem[pid][f])
                            
                            set F_EnchantSelectNumber = 6
                            call DzFrameSetTexture(F_EEItemButtonsBackDrop[6],"UI_Inventory.blp", 0)
                            call DzFrameShow(F_EnchantUpText, false)
                            call DzFrameShow(F_EnchantButton2, false)
                            call CharacterSave(true , SLNumber)
                        endif
                        set loopA = 99
                    endif
                    set loopA = loopA + 1
                endloop
            else
                call BJDebugMsg("서버에 연결되지 않았습니다.")
            endif
        endif
    endfunction
    
    private function ButtonEnchant takes nothing returns nothing
        local integer f = S2I(DzGetTriggerSyncData())
        local integer pid = GetPlayerId(DzGetTriggerSyncPlayer())
        local string items = ""
        local integer i = 0
        local integer quality = 0
        local integer up = 0
        local integer tier = 0
        local integer trycount = 0
        local integer trycount2 = 0
        local integer fate = 0
        local real rate =0
        local integer A = 0
        local integer j = 0
        local integer k = 0
        local integer loopA = 0
        local integer length = 0
        local integer l = 1
        local integer m = 0
        local integer tip = 0
        local string sn = I2S(PlayerSlotNumber[pid])
        
        set A = GetRandomInt(1,10000)
        
        if Player(pid) == GetLocalPlayer() then
            if JNObjectCharacterServerConnectCheck( ) then
                set items = Eitem[pid][f]
                set i = GetItemIDs(items)
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[6], GetItemArt(items), 0)
                set up = GetItemUp(items)
                set quality = GetItemQuality(items)
                set tier = GetItemTier(items)
                set trycount = GetItemTrycount(items)
                set fate = GetItemFate(items)
                //call DzFrameSetText(F_EnchantText[5], "x " + I2S(EnchantMaterial1[tier][up+1]) )
                //call DzFrameSetText(F_EnchantText[6], "x " + I2S(EnchantMaterial2[tier][up+1]) )
                
                set l = EnchantMaterial1[tier][up+1]
                set m = EnchantMaterial2[tier][up+1]
                    
                if tier == 2 then
                    set k = 66
                elseif tier == 3 then
                    set k = 67
                elseif tier == 4 then
                    set k = 68
                elseif tier == 5 then
                    set k = 69
                elseif tier == 6 then
                    set k = 70
                elseif tier == 7 then
                    set k = 71
                elseif tier == 8 then
                    set k = 72
                endif
                
                if tip == 5 then
                    set l = l * 2
                endif
                
                if m <= S2I(StashLoad(PLAYER_DATA[pid], "골드", "0")) then
                    set j = 0
                    if l == 0 then
                        call StashSave(PLAYER_DATA[pid], "골드", I2S(S2I(StashLoad(PLAYER_DATA[pid], "골드", "0")) - m) )
                        call DzFrameSetText(F_GoldText, StashLoad(PLAYER_DATA[pid], "골드", "0"))
                        if trycount > 10 then
                            set trycount2 = 10
                        else
                            set trycount2 = trycount
                        endif
                        if fate < 10000 then
                            set rate = I2R(EnchantRate[tier][up+1]) + ((I2R(EnchantRate[tier][up+1])*5/100) * trycount2)
                        else
                            set rate = 10000
                        endif
                        if A <= rate then
                            //성공
                            set fate = 0
                            set up = up + 1
                            set trycount = 0
                            set items = "ID"+I2S(i)+";"
                            set items = SetItemQuality(items, quality)
                            set items = SetItemUp(items, up)
                            set items = SetItemTrycount(items, trycount)
                            set items = SetItemFate(items, fate)
                            set Eitem[pid][f] = items
                            call DzSyncData("장착",I2S(pid)+"\t"+I2S(f)+"\t"+Eitem[pid][f])
                            set F_EnchantSelectNumber = 6
                            call DzFrameSetTexture(F_EEItemButtonsBackDrop[6],"UI_Inventory.blp", 0)
                            call DzFrameShow(F_EnchantUpText, false)
                            call DzFrameShow(F_EnchantButton, false)
                            call CharacterSave(true , SLNumber)
                        else
                            //실패
                            set trycount = trycount + 1
                            set fate = fate + R2I(rate * 0.465)
                            if fate >= 10000 then
                                set fate = 10000
                            endif
                            set items = "ID"+I2S(i)+";"
                            set items = SetItemQuality(items, quality)
                            set items = SetItemUp(items, up)
                            set items = SetItemTrycount(items, trycount)
                            set items = SetItemFate(items, fate)
                            set Eitem[pid][f] = items
                            if F_EnchantSelectNumber == 6 then
                            else
                                if trycount > 10 then
                                    set trycount2 = 10
                                else
                                    set trycount2 = trycount
                                endif
                                set rate = (I2R(EnchantRate[tier][up+1])/100) + ((I2R(EnchantRate[tier][up+1])*5/10000) * trycount2)
                                if rate >= 100 then
                                    set rate = 100
                                endif
                                call DzFrameSetText(F_EnchantRateText, "강화 확률 |cFFFFE400" + R2SW( rate ,1,2) + "%|r")
                                call DzFrameSetText(F_EnchantFateText, "운명 |cFFFFE400" + R2SW(I2R(fate)/100,1,2) + "%|r")
                            endif
                            call CharacterSave(true , SLNumber)
                        endif
                    else
                        set loopA = 50
                        loop
                            exitwhen loopA == 100
                            //보유중
                            if GetItemIDs(StashLoad(PLAYER_DATA[pid], "슬롯"+sn+".아이템"+I2S(loopA), "0")) == k then
                                set items = StashLoad(PLAYER_DATA[pid], "슬롯"+sn+".아이템"+I2S(loopA), "0")
                                set j = GetItemCharge(items)
                                if l <= j then
                                    if (j-l) == 0 then
                                        //아이템지우기
                                        call DzFrameSetTexture(F_ItemButtonsBackDrop[loopA], "UI_Inventory.blp", 0)
                                        call DzFrameShow(UI_Tip, false)
                                        call StashRemove(PLAYER_DATA[pid], "슬롯"+sn+".아이템"+I2S(loopA))
                                    else
                                        set items = SetItemCharge(items, j-l)
                                        call StashSave(PLAYER_DATA[pid], "슬롯"+sn+".아이템"+I2S(loopA), items)
                                    endif
                                    
                                    call StashSave(PLAYER_DATA[pid], "골드", I2S(S2I(StashLoad(PLAYER_DATA[pid], "골드", "0")) - m) )
                                    call DzFrameSetText(F_GoldText, StashLoad(PLAYER_DATA[pid], "골드", "0"))
                                    
                                    if trycount > 10 then
                                        set trycount2 = 10
                                    else
                                        set trycount2 = trycount
                                    endif
                                    if fate < 10000 then
                                        set rate = I2R(EnchantRate[tier][up+1]) + ((I2R(EnchantRate[tier][up+1])*5/100) * trycount2)
                                    else
                                        set rate = 10000
                                    endif
                                    if A <= rate then
                                        //성공
                                        set fate = 0
                                        set up = up + 1
                                        set trycount = 0
                                        set items = "ID"+I2S(i)+";"
                                        set items = SetItemQuality(items, quality)
                                        set items = SetItemUp(items, up)
                                        set items = SetItemTrycount(items, trycount)
                                        set items = SetItemFate(items, fate)
                                        set Eitem[pid][f] = items
                                        call DzSyncData("장착",I2S(pid)+"\t"+I2S(f)+"\t"+Eitem[pid][f])
                                        set F_EnchantSelectNumber = 6
                                        call DzFrameSetTexture(F_EEItemButtonsBackDrop[6],"UI_Inventory.blp", 0)
                                        call DzFrameShow(F_EnchantUpText, false)
                                        call DzFrameShow(F_EnchantButton, false)
                                        call CharacterSave(true , SLNumber)
                                    else
                                        //실패
                                        set trycount = trycount + 1
                                        set fate = fate + R2I(rate * 0.465)
                                        if fate >= 10000 then
                                            set fate = 10000
                                        endif
                                        set items = "ID"+I2S(i)+";"
                                        set items = SetItemQuality(items, quality)
                                        set items = SetItemUp(items, up)
                                        set items = SetItemTrycount(items, trycount)
                                        set items = SetItemFate(items, fate)
                                        set Eitem[pid][f] = items
                                        if F_EnchantSelectNumber == 6 then
                                        else
                                            if trycount > 10 then
                                                set trycount2 = 10
                                            else
                                                set trycount2 = trycount
                                            endif
                                            set rate = (I2R(EnchantRate[tier][up+1])/100) + ((I2R(EnchantRate[tier][up+1])*5/10000) * trycount2)
                                            if rate >= 100 then
                                                set rate = 100
                                            endif
                                            call DzFrameSetText(F_EnchantRateText, "강화 확률 |cFFFFE400" + R2SW( rate ,1,2) + "%|r")
                                            call DzFrameSetText(F_EnchantFateText, "운명 |cFFFFE400" + R2SW(I2R(fate)/100,1,2) + "%|r")
                                        endif
                                        call CharacterSave(true , SLNumber)
                                    endif
                                endif
                                set loopA = 99
                            endif
                            set loopA = loopA + 1
                        endloop
                    endif
                else
                    call BJDebugMsg("서버에 연결되지 않았습니다.")
                endif
            endif
        endif
    endfunction
        
    //장착중인 아이템 버튼 클릭
    private function ClickButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local string items
        local integer itemid = 0
        local integer i = 0
        local integer quality = 0
        local integer up = 0
        local integer tier = 0
        local integer trycount = 0
        local integer trycount2 = 0
        local integer fate = 0
        local real rate
        local string str = ""
        local string sn = I2S(PlayerSlotNumber[pid])
        
        //장비 0아이템아이디, 1강화수치, 2품질, 3트라이횟수, 4장인의기운
        
        if f == F_EEItemButtons[0] then
            set F_EnchantSelectNumber = 0
            set items = Eitem[pid][F_EnchantSelectNumber]
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[6], GetItemNumberArt(GetItemIDs(items)), 0)
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[7], GetItemNumberArt(GetItemIDs(items)), 0)
            set itemid = GetItemIDs(items)
            set tier = GetItemTier(items)
            call DzFrameSetText(F_EnchantText[7], "x " + "1" )
            if tier == 1 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(59), 0)
            elseif tier == 2 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(60), 0)
            elseif tier == 3 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(61), 0)
            elseif tier == 4 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(62), 0)
            elseif tier == 5 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(63), 0)
            elseif tier == 6 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(64), 0)
            elseif tier == 7 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(65), 0)
            endif
            call DzFrameSetText(F_EnchantUpText, "더이상 강화 할 수 없습니다. |n계승을 시도하세요")
            call DzFrameShow(F_EnchantButton, false)
            call DzFrameShow(F_EnchantButton2, true)
            call DzFrameShow(F_EnchantUpText, true)
        elseif f == F_EEItemButtons[1] then
            set F_EnchantSelectNumber = 1
            set items = Eitem[pid][F_EnchantSelectNumber]
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[6], GetItemNumberArt(GetItemIDs(items)), 0)
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[7], GetItemNumberArt(GetItemIDs(items)), 0)
            set itemid = GetItemIDs(items)
            set tier = GetItemTier(items)
            call DzFrameSetText(F_EnchantText[7], "x " + "1" )
            if tier == 1 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(59), 0)
            elseif tier == 2 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(60), 0)
            elseif tier == 3 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(61), 0)
            elseif tier == 4 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(62), 0)
            elseif tier == 5 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(63), 0)
            elseif tier == 6 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(64), 0)
            elseif tier == 7 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(65), 0)
            endif
            call DzFrameSetText(F_EnchantUpText, "더이상 강화 할 수 없습니다. |n계승을 시도하세요")
            call DzFrameShow(F_EnchantButton, false)
            call DzFrameShow(F_EnchantButton2, true)
            call DzFrameShow(F_EnchantUpText, true)
        elseif f == F_EEItemButtons[2] then
            set F_EnchantSelectNumber = 2
            set items = Eitem[pid][F_EnchantSelectNumber]
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[6], GetItemNumberArt(GetItemIDs(items)), 0)
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[7], GetItemNumberArt(GetItemIDs(items)), 0)
            set itemid = GetItemIDs(items)
            set tier = GetItemTier(items)
            call DzFrameSetText(F_EnchantText[7], "x " + "1" )
            if tier == 1 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(59), 0)
            elseif tier == 2 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(60), 0)
            elseif tier == 3 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(61), 0)
            elseif tier == 4 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(62), 0)
            elseif tier == 5 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(63), 0)
            elseif tier == 6 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(64), 0)
            elseif tier == 7 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(65), 0)
            endif
            call DzFrameSetText(F_EnchantUpText, "더이상 강화 할 수 없습니다. |n계승을 시도하세요")
            call DzFrameShow(F_EnchantButton, false)
            call DzFrameShow(F_EnchantButton2, true)
            call DzFrameShow(F_EnchantUpText, true)
        elseif f == F_EEItemButtons[3] then
            set F_EnchantSelectNumber = 3
            set items = Eitem[pid][F_EnchantSelectNumber]
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[6], GetItemNumberArt(GetItemIDs(items)), 0)
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[7], GetItemNumberArt(GetItemIDs(items)), 0)
            set itemid = GetItemIDs(items)
            set tier = GetItemTier(items)
            call DzFrameSetText(F_EnchantText[7], "x " + "1" )
            if tier == 1 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(59), 0)
            elseif tier == 2 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(60), 0)
            elseif tier == 3 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(61), 0)
            elseif tier == 4 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(62), 0)
            elseif tier == 5 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(63), 0)
            elseif tier == 6 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(64), 0)
            elseif tier == 7 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(65), 0)
            endif
            call DzFrameSetText(F_EnchantUpText, "더이상 강화 할 수 없습니다. |n계승을 시도하세요")
            call DzFrameShow(F_EnchantButton, false)
            call DzFrameShow(F_EnchantButton2, true)
            call DzFrameShow(F_EnchantUpText, true)
        elseif f == F_EEItemButtons[4] then
            set F_EnchantSelectNumber = 4
            set items = Eitem[pid][F_EnchantSelectNumber]
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[6], GetItemNumberArt(GetItemIDs(items)), 0)
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[7], GetItemNumberArt(GetItemIDs(items)), 0)
            set itemid = GetItemIDs(items)
            set tier = GetItemTier(items)
            call DzFrameSetText(F_EnchantText[7], "x " + "1" )
            if tier == 1 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(59), 0)
            elseif tier == 2 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(60), 0)
            elseif tier == 3 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(61), 0)
            elseif tier == 4 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(62), 0)
            elseif tier == 5 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(63), 0)
            elseif tier == 6 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(64), 0)
            elseif tier == 7 then
                call DzFrameSetTexture(F_EEItemButtonsBackDrop[11], GetItemNumberArt(65), 0)
            endif
            call DzFrameSetText(F_EnchantUpText, "더이상 강화 할 수 없습니다. |n계승을 시도하세요")
            call DzFrameShow(F_EnchantButton, false)
            call DzFrameShow(F_EnchantButton2, true)
            call DzFrameShow(F_EnchantUpText, true)
        elseif f == F_EEItemButtons[5] then
            set F_EnchantSelectNumber = 5
            set items = Eitem[pid][F_EnchantSelectNumber]
            set itemid = GetItemIDs(items)
            set i = GetItemTypes(items)
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[6], GetItemNumberArt(GetItemIDs(items)), 0)
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[7], GetItemNumberArt(GetItemIDs(items)), 0)
            set up = GetItemUp(items)
            set quality = GetItemQuality(items)
            set tier = GetItemTier(items)
            set trycount = GetItemTrycount(items)
            set fate = GetItemFate(items)
            if EnchantMax[tier] != up then
                call DzFrameSetText(F_EnchantUpText, I2S(up) + "  >>  " + I2S(up+1))
                if trycount > 10 then
                    set trycount2 = 10
                else
                    set trycount2 = trycount
                endif
                set rate = (I2R(EnchantRate[tier][up+1])/100) + ((I2R(EnchantRate[tier][up+1])*5/10000) * trycount2)
                if rate >= 100 then
                    set rate = 100
                endif
                call DzFrameSetText(F_EnchantRateText, "강화 확률 |cFFFFE400" + R2SW( rate ,1,2) + "%|r")
                call DzFrameSetText(F_EnchantFateText, "운명 |cFFFFE400" + R2SW(I2R(fate)/100,1,2) + "%|r")
                set str = str + "|cFFB9E2FA무기 공격력|r +"
                set str = str + JNStringSplit(ItemStats[i][tier],";", up )
                call DzFrameSetText(F_EnchantText[0], str)
                set str = ""
                set str = str + "|cFFB9E2FA무기 공격력|r +"
                set str = str + JNStringSplit(ItemStats[i][tier],";", (up+1) )
                
                call DzFrameSetText(F_EnchantText[5], "x " + I2S(EnchantMaterial1[tier][up+1]) )
                call DzFrameSetText(F_EnchantText[6], "x " + I2S(EnchantMaterial2[tier][up+1]) )
                
                if tier == 2 then
                    call DzFrameSetTexture(F_EEItemButtonsBackDrop[9], GetItemNumberArt(66), 0)
                elseif tier == 3 then
                    call DzFrameSetTexture(F_EEItemButtonsBackDrop[9], GetItemNumberArt(67), 0)
                elseif tier == 4 then
                    call DzFrameSetTexture(F_EEItemButtonsBackDrop[9], GetItemNumberArt(68), 0)
                elseif tier == 5 then
                    call DzFrameSetTexture(F_EEItemButtonsBackDrop[9], GetItemNumberArt(69), 0)
                elseif tier == 6 then
                    call DzFrameSetTexture(F_EEItemButtonsBackDrop[9], GetItemNumberArt(70), 0)
                elseif tier == 7 then
                    call DzFrameSetTexture(F_EEItemButtonsBackDrop[9], GetItemNumberArt(71), 0)
                elseif tier == 8 then
                    call DzFrameSetTexture(F_EEItemButtonsBackDrop[9], GetItemNumberArt(72), 0)
                endif
                call DzFrameSetText(F_EnchantText[2], str)
                call DzFrameShow(F_EnchantButton, true)
                call DzFrameShow(F_EnchantButton2, false)
            else
                //call BJDebugMsg("오류")
            endif
            call DzFrameShow(F_EnchantUpText, true)
        elseif f == F_EEItemButtons[6] then
            //set F_EnchantSelectNumber = 6
            //call DzFrameSetTexture(F_EEItemButtonsBackDrop[6],"UI_Inventory.blp", 0)
            //call DzFrameShow(F_EnchantUpText, false)
            //call DzFrameShow(F_EnchantButton, false)
            //call DzFrameShow(F_EnchantButton2, true)
        endif
        
        if itemid == 2 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(17), 0)
        elseif itemid == 3 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(18), 0)
        elseif itemid == 4 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(19), 0)
        elseif itemid == 6 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(20), 0)
        elseif itemid == 5 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(21), 0)
        elseif itemid == 1 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(22), 0)
        elseif itemid == 17 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(23), 0)
        elseif itemid == 18 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(24), 0)
        elseif itemid == 19 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(25), 0)
        elseif itemid == 20 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(26), 0)
        elseif itemid == 21 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(27), 0)
        elseif itemid == 22 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(28), 0)
        elseif itemid == 23 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(29), 0)
        elseif itemid == 24 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(30), 0)
        elseif itemid == 25 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(31), 0)
        elseif itemid == 26 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(32), 0)
        elseif itemid == 27 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(33), 0)
        elseif itemid == 28 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(34), 0)
        elseif itemid == 29 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(35), 0)
        elseif itemid == 30 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(36), 0)
        endif
        if itemid == 31 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(37), 0)
        elseif itemid == 32 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(38), 0)
        elseif itemid == 33 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(39), 0)
        elseif itemid == 34 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(40), 0)
        elseif itemid == 35 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(41), 0)
        elseif itemid == 36 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(42), 0)
        elseif itemid == 37 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(43), 0)
        elseif itemid == 38 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(44), 0)
        elseif itemid == 39 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(45), 0)
        elseif itemid == 40 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(46), 0)
        elseif itemid == 41 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(47), 0)
        elseif itemid == 42 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(48), 0)
        elseif itemid == 43 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(49), 0)
        elseif itemid == 44 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(50), 0)
        elseif itemid == 45 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(51), 0)
        elseif itemid == 46 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(52), 0)
        elseif itemid == 47 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(53), 0)
        elseif itemid == 48 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(54), 0)
        elseif itemid == 49 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(55), 0)
        elseif itemid == 50 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(56), 0)
        elseif itemid == 51 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(57), 0)
        elseif itemid == 52 then
            call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(58), 0)
        elseif itemid == 53 then
            call DzFrameShow(F_EnchantButton2, false)
        elseif itemid == 54 then
            call DzFrameShow(F_EnchantButton2, false)
        elseif itemid == 55 then
            call DzFrameShow(F_EnchantButton2, false)
        elseif itemid == 56 then
            call DzFrameShow(F_EnchantButton2, false)
        elseif itemid == 57 then
            call DzFrameShow(F_EnchantButton2, false)
        elseif itemid == 58 then
            call DzFrameShow(F_EnchantButton2, false)
        endif
        
        call StopSound(gg_snd_MouseClick1, false, false)
        call StartSound(gg_snd_MouseClick1)
    endfunction
    
    
    //장비 빈 버튼 아이콘 생성 함수
    private function CreateEItemButton takes integer types, real x, real y returns nothing
        set F_EEItemButtons[types]=DzCreateFrameByTagName("BUTTON", "", F_EnchantBackDrop, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetPoint(F_EEItemButtons[types], JN_FRAMEPOINT_CENTER, F_EnchantBackDrop , JN_FRAMEPOINT_TOPLEFT, x, y)
        call DzFrameSetSize(F_EEItemButtons[types], 0.025, 0.025)
        
        set F_EEItemButtonsBackDrop[types]=DzCreateFrameByTagName("BACKDROP", "", F_EEItemButtons[types], "", FrameCount())
        call DzFrameSetAllPoints(F_EEItemButtonsBackDrop[types], F_EEItemButtons[types])
        call DzFrameSetTexture(F_EEItemButtonsBackDrop[types],"UI_Inventory.blp", 0)
        
        call DzFrameSetScriptByCode(F_EEItemButtons[types], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions, false)
        call DzFrameSetScriptByCode(F_EEItemButtons[types], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        call DzFrameSetScriptByCode(F_EEItemButtons[types], JN_FRAMEEVENT_MOUSE_UP, function ClickButton, false)
    endfunction
    
    private function Main takes nothing returns nothing
        local string s
        local integer i
        call DzLoadToc("war3mapImported\\Templates.toc")
        
        //초기값
        set F_EnchantSelectNumber = 6
        
        //메뉴 배경
        set F_EnchantBackDrop=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "StandardEditBoxBackdropTemplate", 0)
        call DzFrameSetAbsolutePoint(F_EnchantBackDrop, JN_FRAMEPOINT_CENTER, 0.225, 0.320)
        call DzFrameSetSize(F_EnchantBackDrop, 0.40, 0.26)
        
        //메뉴 취소 버튼
        set F_EnchantCancelButton = DzCreateFrameByTagName("GLUETEXTBUTTON", "", F_EnchantBackDrop, "ScriptDialogButton", 0)
        call DzFrameSetPoint(F_EnchantCancelButton, JN_FRAMEPOINT_TOPRIGHT, F_EnchantBackDrop , JN_FRAMEPOINT_TOPRIGHT, -0.010, -0.010)
        call DzFrameSetText(F_EnchantCancelButton, "X")
        call DzFrameSetSize(F_EnchantCancelButton, 0.03, 0.03)
        call DzFrameSetScriptByCode(F_EnchantCancelButton, JN_FRAMEEVENT_MOUSE_UP, function EnchantOpen, false)
        
        call CreateEItemButton(0 , 0.040 , - 0.070)
        call CreateEItemButton(1 , 0.040 , - 0.100)
        call CreateEItemButton(2 , 0.040 , - 0.130)
        call CreateEItemButton(3 , 0.040 , - 0.160)
        call CreateEItemButton(4 , 0.040 , - 0.190)
        call CreateEItemButton(5 , 0.040 , - 0.220)
        
        call CreateEItemButton(6 , 0.220 , - 0.040)
        
        
        set F_EnchantButton2=DzCreateFrameByTagName("BUTTON", "", F_EnchantBackDrop, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetPoint(F_EnchantButton2, JN_FRAMEPOINT_CENTER, F_EEItemButtons[6] ,  JN_FRAMEPOINT_CENTER, 0, -0.175 )
        call DzFrameSetSize(F_EnchantButton2, 0.060 , 0.040)
        call DzFrameSetScriptByCode(F_EnchantButton2, JN_FRAMEEVENT_MOUSE_UP, function ClickButton3, false)
        set F_EnchantButtonBD2=DzCreateFrameByTagName("BACKDROP", "", F_EnchantButton2, "", FrameCount())
        call DzFrameSetAllPoints(F_EnchantButtonBD2, F_EnchantButton2)
        call DzFrameSetTexture(F_EnchantButtonBD2,"ReplaceableTextures\\CommandButtons\\BTNAnvil.blp", 0)
        set F_EEItemButtons[7]=DzCreateFrameByTagName("BUTTON", "", F_EnchantButton2, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetPoint(F_EEItemButtons[7], JN_FRAMEPOINT_CENTER, F_EEItemButtons[6] ,  JN_FRAMEPOINT_CENTER, -0.070 , - 0.080 )
        call DzFrameSetSize(F_EEItemButtons[7], 0.025, 0.025)
        set F_EEItemButtonsBackDrop[7]=DzCreateFrameByTagName("BACKDROP", "", F_EEItemButtons[7], "", FrameCount())
        call DzFrameSetAllPoints(F_EEItemButtonsBackDrop[7], F_EEItemButtons[7])
        call DzFrameSetTexture(F_EEItemButtonsBackDrop[7],"UI_Inventory.blp", 0)
        call DzFrameSetScriptByCode(F_EEItemButtons[7], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions, false)
        call DzFrameSetScriptByCode(F_EEItemButtons[7], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        set F_EEItemButtons[8]=DzCreateFrameByTagName("BUTTON", "", F_EnchantButton2, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetPoint(F_EEItemButtons[8], JN_FRAMEPOINT_CENTER, F_EEItemButtons[6] ,  JN_FRAMEPOINT_CENTER, 0.070 , - 0.080 )
        call DzFrameSetSize(F_EEItemButtons[8], 0.025, 0.025)
        set F_EEItemButtonsBackDrop[8]=DzCreateFrameByTagName("BACKDROP", "", F_EEItemButtons[8], "", FrameCount())
        call DzFrameSetAllPoints(F_EEItemButtonsBackDrop[8], F_EEItemButtons[8])
        call DzFrameSetTexture(F_EEItemButtonsBackDrop[8],"UI_Inventory.blp", 0)
        call DzFrameSetScriptByCode(F_EEItemButtons[8], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions, false)
        call DzFrameSetScriptByCode(F_EEItemButtons[8], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        set F_EEItemButtons[11]=DzCreateFrameByTagName("BUTTON", "", F_EnchantButton2, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetPoint(F_EEItemButtons[11], JN_FRAMEPOINT_CENTER, F_EEItemButtons[6] ,  JN_FRAMEPOINT_CENTER, -0.020 , - 0.125 )
        call DzFrameSetSize(F_EEItemButtons[11], 0.015, 0.015)
        set F_EEItemButtonsBackDrop[11]=DzCreateFrameByTagName("BACKDROP", "", F_EEItemButtons[11], "", FrameCount())
        call DzFrameSetAllPoints(F_EEItemButtonsBackDrop[11], F_EEItemButtons[11])
        call DzFrameSetTexture(F_EEItemButtonsBackDrop[11],"UI_Inventory.blp", 0)
        call DzFrameSetScriptByCode(F_EEItemButtons[11], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions, false)
        call DzFrameSetScriptByCode(F_EEItemButtons[11], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        set F_EnchantText[7]=DzCreateFrameByTagName("TEXT", "", F_EnchantButton2, "", FrameCount())
        call DzFrameSetPoint(F_EnchantText[7], JN_FRAMEPOINT_CENTER, F_EEItemButtons[6] ,  JN_FRAMEPOINT_CENTER, 0.010 , - 0.125 )
        call DzFrameSetText(F_EnchantText[7], "x "+"000")
        call DzFrameSetFont(F_EnchantText[7], "Fonts\\DFHeiMd.ttf", 0.010, 0)
        
        set F_EnchantText[4]=DzCreateFrameByTagName("TEXT", "", F_EnchantButton2, "", FrameCount())
        call DzFrameSetPoint(F_EnchantText[4], JN_FRAMEPOINT_CENTER, F_EEItemButtons[6] ,  JN_FRAMEPOINT_CENTER, 0 , - 0.080 )
        call DzFrameSetText(F_EnchantText[4], "  >>  ")
        call DzFrameSetFont(F_EnchantText[4], "Fonts\\DFHeiMd.ttf", 0.010, 0)
        
        
        
        set F_EnchantUpText=DzCreateFrameByTagName("TEXT", "", F_EnchantBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_EnchantUpText, JN_FRAMEPOINT_CENTER, F_EEItemButtons[6] ,  JN_FRAMEPOINT_CENTER, 0 , - 0.025 )
        call DzFrameSetText(F_EnchantUpText, "00" + "  >>  " + "00")
        call DzFrameSetFont(F_EnchantUpText, "Fonts\\DFHeiMd.ttf", 0.010, 0)
        
        set F_EnchantButton=DzCreateFrameByTagName("BUTTON", "", F_EnchantBackDrop, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetPoint(F_EnchantButton, JN_FRAMEPOINT_CENTER, F_EEItemButtons[6] ,  JN_FRAMEPOINT_CENTER, 0, -0.175 )
        call DzFrameSetSize(F_EnchantButton, 0.060 , 0.040)
        call DzFrameSetScriptByCode(F_EnchantButton, JN_FRAMEEVENT_MOUSE_UP, function ClickButton2, false)
        set F_EnchantButtonBD=DzCreateFrameByTagName("BACKDROP", "", F_EnchantButton, "", FrameCount())
        call DzFrameSetAllPoints(F_EnchantButtonBD, F_EnchantButton)
        call DzFrameSetTexture(F_EnchantButtonBD,"ReplaceableTextures\\CommandButtons\\BTNAnvil.blp", 0)
        
        set F_EnchantRateText=DzCreateFrameByTagName("TEXT", "", F_EnchantButton, "", FrameCount())
        call DzFrameSetPoint(F_EnchantRateText, JN_FRAMEPOINT_CENTER, F_EEItemButtons[6] ,  JN_FRAMEPOINT_CENTER, 0 , - 0.040 )
        call DzFrameSetText(F_EnchantRateText, "강화 확률 |cFFFFE400" + R2SW(I2R(10000)/100,1,2) + "%|r")
        call DzFrameSetFont(F_EnchantRateText, "Fonts\\DFHeiMd.ttf", 0.010, 0)
        set F_EnchantFateText=DzCreateFrameByTagName("TEXT", "", F_EnchantButton, "", FrameCount())
        call DzFrameSetPoint(F_EnchantFateText, JN_FRAMEPOINT_CENTER, F_EEItemButtons[6] ,  JN_FRAMEPOINT_CENTER, 0 , - 0.055 )
        call DzFrameSetText(F_EnchantFateText, "운명 |cFFFFE400" + R2SW(I2R(10000)/100,1,2) + "%|r")
        call DzFrameSetFont(F_EnchantFateText, "Fonts\\DFHeiMd.ttf", 0.008, 0)
        
        set F_EnchantText[0]=DzCreateFrameByTagName("TEXT", "", F_EnchantButton, "", FrameCount())
        call DzFrameSetPoint(F_EnchantText[0], JN_FRAMEPOINT_CENTER, F_EEItemButtons[6] ,  JN_FRAMEPOINT_CENTER, -0.070 , - 0.080 )
        call DzFrameSetText(F_EnchantText[0], "")
        call DzFrameSetFont(F_EnchantText[0], "Fonts\\DFHeiMd.ttf", 0.010, 0)
        set F_EnchantText[1]=DzCreateFrameByTagName("TEXT", "", F_EnchantButton, "", FrameCount())
        call DzFrameSetPoint(F_EnchantText[1], JN_FRAMEPOINT_CENTER, F_EEItemButtons[6] ,  JN_FRAMEPOINT_CENTER, 0 , - 0.080 )
        call DzFrameSetText(F_EnchantText[1], "  >>  ")
        call DzFrameSetFont(F_EnchantText[1], "Fonts\\DFHeiMd.ttf", 0.010, 0)
        set F_EnchantText[2]=DzCreateFrameByTagName("TEXT", "", F_EnchantButton, "", FrameCount())
        call DzFrameSetPoint(F_EnchantText[2], JN_FRAMEPOINT_CENTER, F_EEItemButtons[6] ,  JN_FRAMEPOINT_CENTER, 0.070 , - 0.080 )
        call DzFrameSetText(F_EnchantText[2], "")
        call DzFrameSetFont(F_EnchantText[2], "Fonts\\DFHeiMd.ttf", 0.010, 0)
        
        
        set F_EEItemButtons[9]=DzCreateFrameByTagName("BUTTON", "", F_EnchantButton, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetPoint(F_EEItemButtons[9], JN_FRAMEPOINT_CENTER, F_EEItemButtons[6] ,  JN_FRAMEPOINT_CENTER, -0.050 , - 0.125 )
        call DzFrameSetSize(F_EEItemButtons[9], 0.015, 0.015)
        set F_EEItemButtonsBackDrop[9]=DzCreateFrameByTagName("BACKDROP", "", F_EEItemButtons[9], "", FrameCount())
        call DzFrameSetAllPoints(F_EEItemButtonsBackDrop[9], F_EEItemButtons[9])
        call DzFrameSetTexture(F_EEItemButtonsBackDrop[9],"UI_Inventory.blp", 0)
        call DzFrameSetScriptByCode(F_EEItemButtons[9], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions, false)
        call DzFrameSetScriptByCode(F_EEItemButtons[9], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        set F_EEItemButtons[10]=DzCreateFrameByTagName("BUTTON", "", F_EnchantButton, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetPoint(F_EEItemButtons[10], JN_FRAMEPOINT_CENTER, F_EEItemButtons[6] ,  JN_FRAMEPOINT_CENTER, 0.010 , - 0.125 )
        call DzFrameSetSize(F_EEItemButtons[10], 0.015, 0.015)
        set F_EEItemButtonsBackDrop[10]=DzCreateFrameByTagName("BACKDROP", "", F_EEItemButtons[10], "", FrameCount())
        call DzFrameSetAllPoints(F_EEItemButtonsBackDrop[10], F_EEItemButtons[10])
        call DzFrameSetTexture(F_EEItemButtonsBackDrop[10], "UI\\Feedback\\Resources\\ResourceGold.blp", 0)
        call DzFrameSetScriptByCode(F_EEItemButtons[10], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions, false)
        call DzFrameSetScriptByCode(F_EEItemButtons[10], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        set F_EnchantText[5]=DzCreateFrameByTagName("TEXT", "", F_EnchantButton, "", FrameCount())
        call DzFrameSetPoint(F_EnchantText[5], JN_FRAMEPOINT_CENTER, F_EEItemButtons[6] ,  JN_FRAMEPOINT_CENTER, -0.020 , - 0.125 )
        call DzFrameSetText(F_EnchantText[5], "x "+"000")
        call DzFrameSetFont(F_EnchantText[5], "Fonts\\DFHeiMd.ttf", 0.010, 0)
        set F_EnchantText[6]=DzCreateFrameByTagName("TEXT", "", F_EnchantButton, "", FrameCount())
        call DzFrameSetPoint(F_EnchantText[6], JN_FRAMEPOINT_CENTER, F_EEItemButtons[6] ,  JN_FRAMEPOINT_CENTER, 0.040 , - 0.125 )
        call DzFrameSetText(F_EnchantText[6], "x "+"000")
        call DzFrameSetFont(F_EnchantText[6], "Fonts\\DFHeiMd.ttf", 0.010, 0)
        
        //call DzFrameSetTexture(F_EEItemButtonsBackDrop[9],"UI_Inventory.blp", 0)
        //call DzFrameSetText(F_EnchantText[5], "x "+"000")
        //call DzFrameSetText(F_EnchantText[6], "x "+"000")
        
        call DzFrameShow(F_EnchantUpText, false)
        call DzFrameShow(F_EnchantButton, false)
        call DzFrameShow(F_EnchantButton2, false)
        
        call DzFrameShow(F_EnchantBackDrop, false)
    endfunction
        
    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer index
        
        call TriggerRegisterTimerEventSingle( t, 0.10 )
        call TriggerAddAction( t, function Main )
        
        //강화
        set t=CreateTrigger()
        call DzTriggerRegisterSyncData(t,("Enchant"),(false))
        call TriggerAddAction(t,function ButtonEnchant)
        
        //계승
        set t=CreateTrigger()
        call DzTriggerRegisterSyncData(t,("Success"),(false))
        call TriggerAddAction(t,function ButtonSuccess)
        
        set index = 0
        loop
            set F_EnchantOnOff[index] = false
            set index = index + 1
            exitwhen index == bj_MAX_PLAYER_SLOTS
        endloop
    endfunction
endlibrary