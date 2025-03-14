library ItemPickUp initializer init requires DataItem, UIItem, ITEM
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
                    if GetItemIDs(StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(i), "0")) == itemid then
                        call BJDebugMsg("보유중")
                        set j = GetItemCharge(StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(i), "0"))
                        set items = StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(i), "0")
                        set items = SetItemCharge(items,j+1)
                        call StashSave(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(i), items)
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
                        if GetItemIDs(StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(i), "0")) == 0 then
                            set items = "ID"+itemidstring + ";"
                            call BJDebugMsg("보유X 아이템전체코드1: "+ items)
                            set items = SetItemCharge(items,1)
                            call BJDebugMsg("보유X 아이템전체코드2: "+ items)
                            call AddIvItem(pid,i,items)
                            call BJDebugMsg("보유X 아이템전체코드3: "+ items)
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
                    call DzSyncData(("ICharge"),I2S(100)+"\t"+StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".포션1", "0") )
                elseif LoadInteger(ItemData, StringHash("ITEMID"), itemid ) == 'I00B' then
                    set i = 101
                    call DzSyncData(("ICharge"),I2S(101)+"\t"+StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".포션2", "0") )
                elseif LoadInteger(ItemData, StringHash("ITEMID"), itemid ) == 'I00A' then
                    set i = 102
                    call DzSyncData(("ICharge"),I2S(102)+"\t"+StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".포션3", "0") )
                elseif LoadInteger(ItemData, StringHash("ITEMID"), itemid ) == 'I00C' then
                    set i = 103
                    call DzSyncData(("ICharge"),I2S(103)+"\t"+StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".포션4", "0") )
                endif
            endif
            
            //장비
            if class == "Permanent" then
                set i = 0
                loop
                    exitwhen i == 50
                    //비어있는 공간이 있음
                    if GetItemIDs(StashLoad(pid:PLAYER_DATA, "슬롯"+sn+".아이템"+I2S(i), "0")) == 0 then
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
        local string items = JNStringSplit(DzGetTriggerSyncData(), "\t", 1)
        local string sn = I2S(PlayerSlotNumber[pid])
        
        if i == 100 then
            set j = GetItemCharge(items)
            if j == 0 then
                call RemoveItem(PlayerItem1[pid])
                set PlayerItem1[pid] = CreateItem('I009',0,0)
                call UnitAddItem(MainUnit[pid],PlayerItem1[pid])
            endif

            set items = SetItemCharge(items,j+1)

            call StashSave(pid:PLAYER_DATA, "슬롯"+sn+".포션1", items)
            call SetItemCharges(PlayerItem1[pid],j+1)
        elseif i == 101 then
            set j = GetItemCharge(items)
            if j == 0 then
                call RemoveItem(PlayerItem2[pid])
                set PlayerItem2[pid] = CreateItem('I00B',0,0)
                call UnitAddItem(MainUnit[pid],PlayerItem2[pid])
            endif
            set items = SetItemCharge(items,j+1)
            call StashSave(pid:PLAYER_DATA, "슬롯"+sn+".포션2", items)
            call SetItemCharges(PlayerItem2[pid],j+1)
        elseif i == 102 then
            set j = GetItemCharge(items)
            if j == 0 then
                call RemoveItem(PlayerItem3[pid])
                set PlayerItem3[pid] = CreateItem('I00A',0,0)
                call UnitAddItem(MainUnit[pid],PlayerItem3[pid])
            endif
            set items = SetItemCharge(items,j+1)
            call StashSave(pid:PLAYER_DATA, "슬롯"+sn+".포션3", items)
            call SetItemCharges(PlayerItem3[pid],j+1)
        elseif i == 103 then
            set j = GetItemCharge(items)
            if j == 0 then
                call RemoveItem(PlayerItem4[pid])
                set PlayerItem4[pid] = CreateItem('I00C',0,0)
                call UnitAddItem(MainUnit[pid],PlayerItem4[pid])
            endif
            set items = SetItemCharge(items,j+1)
            call StashSave(pid:PLAYER_DATA, "슬롯"+sn+".포션4", items)
            call SetItemCharges(PlayerItem4[pid],j+1)
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
    