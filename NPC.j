library NPC initializer init requires DataUnit, UIStone, UIEnchant, UIOFF, ITEM
                
    private function Action takes nothing returns nothing
        local unit u = GetTriggerUnit()
        local integer pid = GetPlayerId(GetTriggerPlayer())
        local integer loopA = 0
        local integer j
        local string items
        local integer length
        local integer Random1
        local integer Random2
        local integer Random3
        local string sn = I2S(PlayerSlotNumber[pid])
        
        set Random1 = GetRandomInt(0,13)
        loop
            set loopA = GetRandomInt(0,13)
            set Random2 = loopA
            exitwhen loopA != Random1
        endloop
        //패널티각인
         set Random3 = GetRandomInt(50,53)
                                            
        if ( GetTriggerPlayer() == GetLocalPlayer() ) then
            if IsUnitOwnedByPlayer(GetTriggerUnit(), Player(PLAYER_NEUTRAL_PASSIVE)) then
                if DistanceWBW(u,MainUnit[GetPlayerId(GetLocalPlayer())]) < 350 then
                    //사신짱 클릭
                    if DataUnitIndex(u) == 5 then
                        //이미 열려있음
                        if F_StoneOnOff[pid] == false then
                            if JNUse( ) then
                                set loopA = 0
                                set j = 50
                                loop        
                                    exitwhen loopA == 50
                                    //비어있는 공간이 있음
                                    if GetItemIDs(StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(loopA), "0")) == 0 then
                                        set j = loopA
                                        set loopA = 49
                                    endif
                                    set loopA = loopA + 1
                                endloop
                                if j < 50 then
                                    //빈공간이 있음
                                    set j = 0
                                    set loopA = 50
                                    loop
                                        exitwhen loopA == 100
                                        //보유중
                                        if GetItemIDs(StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(loopA), "0")) == 12 then
                                            set j = GetItemCharge(StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(loopA), "0"))
                                            set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(loopA), "0")
                                            if (j-1) == 0 then
                                                //아이템지우기
                                                call DzFrameSetTexture(F_ItemButtonsBackDrop[loopA], "UI_Inventory.blp", 0)
                                                call DzFrameShow(UI_Tip, false)
                                                call StashRemove(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(loopA))
                                            else
                                                set items = SetItemCharge(items, j-1)
                                                call StashSave(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(loopA), items)
                                            endif
                                            //열기
                                            if F_StoneOnOff[pid] == false then
                                                set ArcanaOption[1] = Random1
                                                call DzFrameSetTexture(F_ArcanaButton2BackDrop[1], Arcana[ArcanaOption[1]], 0)
                                                call DzFrameSetText(F_ArcanaText[3], "|c005AD2FF" + ArcanaText[ArcanaOption[1]] + "|r")
                                                set ArcanaOption[2] = Random2
                                                call DzFrameSetTexture(F_ArcanaButton2BackDrop[2], Arcana[ArcanaOption[2]], 0)
                                                call DzFrameSetText(F_ArcanaText[4], "|c005AD2FF" + ArcanaText[ArcanaOption[2]] + "|r")
                                                set ArcanaOption[3] = Random3
                                                call DzFrameSetTexture(F_ArcanaButton2BackDrop[3], Arcana[ArcanaOption[3]], 0)
                                                call DzFrameSetText(F_ArcanaText[5], "|c00FF0000" + ArcanaText[ArcanaOption[3]] + "|r")
                                                set loopA = 0
                                                loop
                                                    set Arcana1[loopA] = 0
                                                    call DzFrameSetTexture(F_Arcana1[loopA], "UI_Arcana_Work1.blp", 0)
                                                    set Arcana2[loopA] = 0
                                                    call DzFrameSetTexture(F_Arcana2[loopA], "UI_Arcana_Work1.blp", 0)
                                                    set Arcana3[loopA] = 0
                                                    call DzFrameSetTexture(F_Arcana3[loopA], "UI_Arcana_Work3.blp", 0)
                                                exitwhen loopA == 9
                                                    set loopA = loopA + 1
                                                endloop
                                                set ArcanaA = 0
                                                call DzFrameSetText(F_ArcanaText[6], "|c005AD2FFX " + I2S(ArcanaA) + "|r")
                                                set ArcanaB = 0
                                                call DzFrameSetText(F_ArcanaText[7], "|c005AD2FFX " + I2S(ArcanaB) + "|r")
                                                set ArcanaC = 0
                                                call DzFrameSetText(F_ArcanaText[8], "|c00FF0000X " + I2S(ArcanaC)+ "|r")
                                                set ArcanaProbability = 0
                                                call DzFrameSetText(F_ArcanaText[0], "부여 확률 |cFFFFE400" + I2S(75 - (ArcanaProbability * 10 )) + "%|r")
                                                call DzFrameSetText(F_ArcanaText[1], "균열 확률 |cFFFFE400" + I2S(75 - (ArcanaProbability * 10 )) + "%|r")
                                                call DzFrameShow(F_StoneBackDrop, true)
                                                set F_StoneOnOff[pid] = true
                                            endif
                                            set loopA = 99
                                        endif
                                        set loopA = loopA + 1
                                    endloop
                                else
                                    call BJDebugMsg("서버에 연결되지 않았습니다.")
                                endif
                            else
                                //템창에 빈공간이 없음
                            endif
                        endif
                    //세레스티아 루덴베르크
                    elseif DataUnitIndex(u) == 6 then
                        //이미 열려있음
                        if F_EnchantOnOff[pid] == false then
                            call DzFrameShow(F_EnchantBackDrop, true)
                            set F_EnchantOnOff[pid] = true
                        endif
                    //라이자
                    elseif DataUnitIndex(u) == 7 then
                        //이미 열려있음
                        if FBS_OnOff[pid] == false then
                            call DzFrameShow(FBS_BD, true)
                            set FBS_OnOff[pid] = true
                            call SelectUnitForPlayerSingle( GetTriggerUnit(), GetTriggerPlayer() )
                            call DzFrameShow(JNGetFrameByName("heroStatusUI",0), false)
                            call PlayersHPBarShow(GetTriggerPlayer(),false)
                        endif
                    //창고
                    elseif DataUnitIndex(u) == 9 then
                        call StorageShow(pid)
                    //가공품 상점
                    elseif DataUnitIndex(u) == 10 then
                         if SHOP_OnOff[pid] == false then
                            call ShopShow(pid)
                        endif
                    //재료 상점
                    elseif DataUnitIndex(u) == 11 then
                        if SHOP2_OnOff[pid] == false then
                            call Shop2Show(pid)
                        endif
                    endif
                endif
            endif
        endif
        set u = null
    endfunction

    function Main takes nothing returns nothing
        local integer id
        //set NPCUnit[0] = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h005',0,0,270)
        //set id = DataUnitIndex(NPCUnit[0])
        
    endfunction
    
    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer i
        
        call TriggerRegisterTimerEventSingle( t, 0.01 )
        call TriggerAddAction( t, function Main )
        
        set t = CreateTrigger()
        set i = 0
        loop
            call TriggerRegisterPlayerUnitEvent(t, Player(i), EVENT_PLAYER_UNIT_SELECTED, null)
            set i = i + 1
            exitwhen i == bj_MAX_PLAYER_SLOTS
        endloop
        call TriggerAddAction( t, function Action )
    
        set t = null
    endfunction
endlibrary