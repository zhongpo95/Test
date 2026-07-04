library ItemPickUp initializer init requires DataItem, UIItem, ITEM
    globals
        constant integer POTION_HEAL_DUNGEON_CHARGES = 1
        constant integer POTION_BUFF_DUNGEON_CHARGES = 1
        constant integer POTION_INVULNERABLE_DUNGEON_CHARGES = 1
    endglobals

    function ShowPlayerPotionDisplay takes integer pid returns nothing
        if PlayerItem1[pid] != null then
            call RemoveItem(PlayerItem1[pid])
        endif
        set PlayerItem1[pid] = CreateItem('I00J',0,0)
        call UnitAddItem(MainUnit[pid],PlayerItem1[pid])

        if PlayerItem2[pid] != null then
            call RemoveItem(PlayerItem2[pid])
        endif
        set PlayerItem2[pid] = CreateItem('I00G',0,0)
        call UnitAddItem(MainUnit[pid],PlayerItem2[pid])

        if PlayerItem3[pid] != null then
            call RemoveItem(PlayerItem3[pid])
        endif
        set PlayerItem3[pid] = CreateItem('I00I',0,0)
        call UnitAddItem(MainUnit[pid],PlayerItem3[pid])
    endfunction

    function ResetPlayerPotionCharges takes integer pid returns nothing
        if PlayerItem1[pid] != null then
            call RemoveItem(PlayerItem1[pid])
        endif
        set PlayerItem1[pid] = CreateItem('I009',0,0)
        call UnitAddItem(MainUnit[pid],PlayerItem1[pid])
        call SetItemCharges(PlayerItem1[pid], POTION_HEAL_DUNGEON_CHARGES)

        if PlayerItem2[pid] != null then
            call RemoveItem(PlayerItem2[pid])
        endif
        set PlayerItem2[pid] = CreateItem('I00C',0,0)
        call UnitAddItem(MainUnit[pid],PlayerItem2[pid])
        call SetItemCharges(PlayerItem2[pid], POTION_BUFF_DUNGEON_CHARGES)

        if PlayerItem3[pid] != null then
            call RemoveItem(PlayerItem3[pid])
        endif
        set PlayerItem3[pid] = CreateItem('I00A',0,0)
        call UnitAddItem(MainUnit[pid],PlayerItem3[pid])
        call SetItemCharges(PlayerItem3[pid], POTION_INVULNERABLE_DUNGEON_CHARGES)
    endfunction

    function additem takes player p, string items returns nothing
        local integer i = 0
        local integer j = 0
        local integer k = 0
        local integer pid = GetPlayerId(p)
        local integer length = 0
        local integer itemid = GetItemIDs(items)
        local string itemidstring = GetItemIDs2(items)
        local string class = GetItemClass(items)
        local string sn = I2S(PlayerSlotNumber[pid])
        
        if GetLocalPlayer() == p then
            //재료
            if class == "Miscellaneous" then
                set i = 50
                loop
                    exitwhen i == 100
                    //보유중
                    if GetItemIDs(StashLoad(PLAYER_DATA[pid], "영웅"+sn+".아이템"+I2S(i), "0")) == itemid then
                        set j = GetItemCharge(StashLoad(PLAYER_DATA[pid], "영웅"+sn+".아이템"+I2S(i), "0"))
                        set items = StashLoad(PLAYER_DATA[pid], "영웅"+sn+".아이템"+I2S(i), "0")
                        set items = SetItemCharge(items,j+1)
                        call StashSave(PLAYER_DATA[pid], "영웅"+sn+".아이템"+I2S(i), items)
                        set k = 1
                        set i = 99
                    endif
                    set i = i + 1
                endloop
                if k == 1 then
                else
                    set i = 50
                    loop
                        exitwhen i == 100
                        //비어있는 공간이 있음
                        if GetItemIDs(StashLoad(PLAYER_DATA[pid], "영웅"+sn+".아이템"+I2S(i), "0")) == 0 then
                            set items = "ID"+itemidstring + ";"
                            set items = SetItemCharge(items,1)
                            call AddIvItem(pid,i,items)
                            set i = 99
                        endif
                        set i = i + 1
                    endloop
                endif
            endif
            //소모품
            if class == "Charged" then
                if LoadInteger(ItemData, StringHash("ITEMID"), itemid ) == 'I009' then
                    set i = 100
                    call DzSyncData(("ICharge"),I2S(100)+"\t"+I2S(GetItemCharges(PlayerItem1[pid])) )
                elseif LoadInteger(ItemData, StringHash("ITEMID"), itemid ) == 'I00C' then
                    set i = 101
                    call DzSyncData(("ICharge"),I2S(101)+"\t"+I2S(GetItemCharges(PlayerItem2[pid])) )
                elseif LoadInteger(ItemData, StringHash("ITEMID"), itemid ) == 'I00A' then
                    set i = 102
                    call DzSyncData(("ICharge"),I2S(102)+"\t"+I2S(GetItemCharges(PlayerItem3[pid])) )
                endif
            endif
            
            //장비
            if class == "Permanent" then
                set i = 0
                loop
                    exitwhen i == 50
                    //비어있는 공간이 있음
                    if GetItemIDs(StashLoad(PLAYER_DATA[pid], "영웅"+sn+".아이템"+I2S(i), "0")) == 0 then
                        call AddIvItem(pid,i,items)
                        set i = 49
                    endif
                    set i = i + 1
                endloop
            endif
            
        endif
    endfunction
    
    private function ICharge takes nothing returns nothing
        local player p=(DzGetTriggerSyncPlayer())
        local integer i = S2I(JNStringSplit(DzGetTriggerSyncData(), "\t", 0))
        local integer j
        local integer pid = GetPlayerId(p)
        local integer charges = S2I(JNStringSplit(DzGetTriggerSyncData(), "\t", 1))
        
        if i == 100 then
            set j = charges
            if j == 0 then
                call RemoveItem(PlayerItem1[pid])
                set PlayerItem1[pid] = CreateItem('I009',0,0)
                call UnitAddItem(MainUnit[pid],PlayerItem1[pid])
            endif

            call SetItemCharges(PlayerItem1[pid],j+1)
        elseif i == 101 then
            set j = charges
            if j == 0 then
                call RemoveItem(PlayerItem2[pid])
                set PlayerItem2[pid] = CreateItem('I00C',0,0)
                call UnitAddItem(MainUnit[pid],PlayerItem2[pid])
            endif
            call SetItemCharges(PlayerItem2[pid],j+1)
            call SetItemCharges(PlayerItem2[pid],j+1)
        elseif i == 102 then
            set j = charges
            if j == 0 then
                call RemoveItem(PlayerItem3[pid])
                set PlayerItem3[pid] = CreateItem('I00A',0,0)
                call UnitAddItem(MainUnit[pid],PlayerItem3[pid])
            endif
            call SetItemCharges(PlayerItem3[pid],j+1)
        endif
        
        set p=null
    endfunction
        
    private function Action takes nothing returns nothing
        if GetOrderTarget() == GetOrderTargetItem() then
            if GetIssuedOrderId() == String2OrderIdBJ("smart") then
                call IssueTargetOrder(GetTriggerUnit(),"root",GetOrderTargetItem())
            endif
        endif
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER )
        call TriggerAddAction( t, function Action )
        
        set t=CreateTrigger()
        call DzTriggerRegisterSyncData(t,("ICharge"),(false))
        call TriggerAddAction(t,function ICharge)
        
        set t = null
    endfunction
    endlibrary
    