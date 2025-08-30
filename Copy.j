@ -13,8 +13,8 @@ library UIEnchant initializer Init requires DataItem, UIItem, ITEM, FrameCount
    integer array F_EnchantText                 //장기
    integer F_EnchantButton                     //강화버튼
    integer F_EnchantButtonBD                   //강화버튼
    integer F_EnchantButton2                    //계승버튼
    integer F_EnchantButtonBD2                  //계승버튼
    integer F_EnchantButton2                    //승급버튼
    integer F_EnchantButtonBD2                  //승급버튼
    
endglobals

@ -38,6 +38,7 @@ library UIEnchant initializer Init requires DataItem, UIItem, ITEM, FrameCount
    if f ==  F_EEItemButtons[0] then
        set items = Eitem[pid][0]
        set itemid = GetItemIDs(items)
    /*
    elseif f ==  F_EEItemButtons[1] then
        set items = Eitem[pid][1]
        set itemid = GetItemIDs(items)
@ -50,6 +51,7 @@ library UIEnchant initializer Init requires DataItem, UIItem, ITEM, FrameCount
    elseif f ==  F_EEItemButtons[4] then
        set items = Eitem[pid][4]
        set itemid = GetItemIDs(items)
    */
    elseif f ==  F_EEItemButtons[5] then
        set items = Eitem[pid][5]
        set itemid = GetItemIDs(items)
@ -63,7 +65,7 @@ library UIEnchant initializer Init requires DataItem, UIItem, ITEM, FrameCount
        set items = Eitem[pid][F_EnchantSelectNumber]
        set itemid = GetItemIDs(items)
        if itemid == 2 then
             set items = "ID17;"
            set items = "ID17;"
            set itemid = 17
        elseif itemid == 3 then
             set items = "ID18;"
@ -224,26 +226,6 @@ library UIEnchant initializer Init requires DataItem, UIItem, ITEM, FrameCount
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
@ -754,118 +736,11 @@ library UIEnchant initializer Init requires DataItem, UIItem, ITEM, FrameCount
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
        call DzFrameSetText(F_EnchantUpText, "더이상 강화 할 수 없습니다. |n승급을 시도하세요")
        call DzFrameShow(F_EnchantButton, false)
        call DzFrameShow(F_EnchantButton2, true)
        call DzFrameShow(F_EnchantUpText, true)
    
    elseif f == F_EEItemButtons[5] then
        set F_EnchantSelectNumber = 5
        set items = Eitem[pid][F_EnchantSelectNumber]
@ -931,102 +806,41 @@ library UIEnchant initializer Init requires DataItem, UIItem, ITEM, FrameCount
        //call DzFrameShow(F_EnchantButton2, true)
    endif
    
    if itemid == 2 then
        call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(17), 0)
    //모자
    if itemid == 9 then
        call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(2), 0)
    elseif itemid == 2 then
        call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(3), 0)
    elseif itemid == 3 then
        call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(18), 0)
        call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(4), 0)
    elseif itemid == 4 then
        call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(19), 0)
    elseif itemid == 6 then
        call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(20), 0)
        call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(5), 0)
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
        call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(6), 0)
    elseif itemid == 6 then
        call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(7), 0)
    elseif itemid == 7 then
        call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(8), 0)
    elseif itemid == 8 then
        call DzFrameShow(F_EnchantButton2, false)
    elseif itemid == 58 then
    endif

    //무기
    if itemid == 18 then
        call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(11), 0)
    elseif itemid == 11 then
        call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(12), 0)
    elseif itemid == 12 then
        call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(13), 0)
    elseif itemid == 13 then
        call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(14), 0)
    elseif itemid == 14 then
        call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(15), 0)
    elseif itemid == 15 then
        call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(16), 0)
    elseif itemid == 16 then
        call DzFrameSetTexture(F_EEItemButtonsBackDrop[8], GetItemNumberArt(17), 0)
    elseif itemid == 17 then
        call DzFrameShow(F_EnchantButton2, false)
    endif
    
@ -1211,7 +1025,7 @@ library UIEnchant initializer Init requires DataItem, UIItem, ITEM, FrameCount
    call DzTriggerRegisterSyncData(t,("Enchant"),(false))
    call TriggerAddAction(t,function ButtonEnchant)
    
    //계승
    //승급
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("Success"),(false))
    call TriggerAddAction(t,function ButtonSuccess)
