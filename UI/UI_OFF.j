library UIOFF initializer init requires UIInfo, UIItem, UIShop, UISkillLevel, UITIP, UIArcana, FrameCount


    private function ESCAction takes nothing returns nothing
        local integer pid = GetPlayerId(GetTriggerPlayer())
        if GetTriggerPlayer() == GetLocalPlayer() then
            call DzFrameShow(FS_BackDrop, false)
            set FS_OnOff[pid] = false
            call DzFrameShow(F_InfoBackDrop, false)
            set F_InfoOnOff[pid] = false
            call DzFrameShow(F_ItemBackDrop, false)
            set F_ItemOnOff[pid] = false
            set F_ItemClickNumber = 200
            call DzFrameShow(SHOP_BackDrop, false)
            set SHOP_OnOff[pid] = false
            call DzFrameShow(F_Storage_BackDrop, false)
            set F_Storage_OnOff[pid] = false
            call DzFrameShow(SHOP2_BackDrop, false)
            set SHOP2_OnOff[pid] = false
            call DzFrameShow(F_ArcanaBackDrop, false)
            set F_ArcanaOnOff[pid] = false
            call DzFrameShow(F_InfoBackDrop2, false)
            set F_Info2OnOff[pid] = false
            call DzFrameShow(Overlay2_BackDrop, false)
            set Overlay2_InfoOnOff[pid] = false
            call DzFrameShow(FBS_BD, false)
            set FBS_OnOff[pid] = false
            call DzFrameShow(F_EnchantBackDrop, false)
            set F_EnchantOnOff[pid] = false
            
        endif


    endfunction



    function ShopShow takes integer pid returns nothing
        call DzFrameShow(F_Storage_BackDrop, false)
        set F_Storage_OnOff[pid] = false

        call DzFrameShow(SHOP2_BackDrop, false)
        set SHOP2_OnOff[pid] = false

        call DzFrameShow(F_ItemBackDrop, true)
        set F_ItemClickNumber = 200
        set F_ItemOnOff[pid] = true

        call DzFrameShow(SHOP_BackDrop, true)
        set SHOP_OnOff[pid] = true

        call MarketDataDownload(pid)
        call DzFrameSetText(SHOP_HowMuch[0], I2S(Price[0]))
        call DzFrameSetText(SHOP_HowMuch[1], I2S(Price[1]))
        call DzFrameSetText(SHOP_HowMuch[2], I2S(Price[2]))
        call DzFrameSetText(SHOP_HowMuch[3], I2S(Price[3]))
        call DzFrameSetText(SHOP_HowMuch[4], I2S(Price[4]))
    endfunction

    function Shop2Show takes integer pid returns nothing
        call DzFrameShow(F_Storage_BackDrop, false)
        set F_Storage_OnOff[pid] = false

        call DzFrameShow(SHOP_BackDrop, false)
        set SHOP_OnOff[pid] = false

        call DzFrameShow(F_ItemBackDrop, true)
        set F_ItemClickNumber = 200
        set F_ItemOnOff[pid] = true

        call DzFrameShow(SHOP2_BackDrop, true)
        set SHOP2_OnOff[pid] = true
    endfunction

    function StorageShow takes integer pid returns nothing
        call DzFrameShow(SHOP_BackDrop, false)
        set SHOP_OnOff[pid] = false
        call DzFrameShow(SHOP2_BackDrop, false)
        set SHOP2_OnOff[pid] = false

        call DzFrameShow(F_ItemBackDrop, true)
        set F_ItemClickNumber = 200
        set F_ItemOnOff[pid] = true

        if SHOP_OnOff[pid] == false then
            call DzFrameShow(F_Storage_BackDrop, true)
            set F_Storage_OnOff[pid] = true
        endif
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer index
        
        set t = CreateTrigger()
        set index = 0
        loop
            call TriggerRegisterPlayerEvent(t, Player(index), EVENT_PLAYER_END_CINEMATIC)
            set index = index + 1
            exitwhen index == 6
        endloop
        call TriggerAddAction( t, function ESCAction )
    endfunction
endlibrary