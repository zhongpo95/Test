library NPC initializer init requires DataUnit, UIStone, UIEnchant, UIUpgrade, UIOFF, ITEM, UIBossStart
                
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
        //각인P
         set Random3 = GetRandomInt(50,53)
                                            
        if ( GetTriggerPlayer() == GetLocalPlayer() ) then
            if IsUnitOwnedByPlayer(GetTriggerUnit(), Player(PLAYER_NEUTRAL_PASSIVE)) then
                if DistanceWBW(u,MainUnit[GetPlayerId(GetLocalPlayer())]) < 350 then
                    //사신짱 클릭
                    if DataUnitIndex(u) == 5 then
                        call UpgradeHubOpen(pid, 2)
                    //세레스티아 루덴베르크
                    elseif DataUnitIndex(u) == 6 then
                        //이미 열려있음
                        if F_UpgradeOnOff[pid] == false then
                            call UpgradeHubOpen(pid, 1)
                        endif
                    //라이자
                    elseif DataUnitIndex(u) == 7 then
                        //이미 열려있음
                        if FBS_OnOff[pid] == false then
                            call DzFrameShow(FBS_BD, true)
                            set FBS_OnOff[pid] = true
                            call BossStartRefreshTextures(pid)
                            call SelectUnitForPlayerSingle( GetTriggerUnit(), GetTriggerPlayer() )
                            call DzFrameShow(JNGetFrameByName("heroStatusUI",0), false)
                            call PlayersHPBarShow(GetTriggerPlayer(),false)
                        endif
                    //창고
                    elseif DataUnitIndex(u) == 9 then
                        call StorageShow(pid)
                    //가공품 상점
                    /*
                    elseif DataUnitIndex(u) == 10 then
                         if SHOP_OnOff[pid] == false then
                            call ShopShow(pid)
                        endif
                    //재료 상점
                    elseif DataUnitIndex(u) == 11 then
                        if SHOP2_OnOff[pid] == false then
                            call Shop2Show(pid)
                        endif
                    */
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
