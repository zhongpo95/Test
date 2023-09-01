library StatsSet initializer init requires UIHP, ITEM
    function SkillSpeed takes integer pid returns real
        if (Equip_Swiftness[pid]/40) + Hero_BuffAttackSpeed[pid] >= 40 then
            return 40.00
        endif
        return (Equip_Swiftness[pid]/40) + Hero_BuffAttackSpeed[pid]
    endfunction
    
    function SkillSpeed2 takes integer pid, real PlusSpeed returns real
        if (Equip_Swiftness[pid]/40) + Hero_BuffAttackSpeed[pid] >= 40 then
            return 40.00 + PlusSpeed
        endif
        return (Equip_Swiftness[pid]/40) + Hero_BuffAttackSpeed[pid] + PlusSpeed
    endfunction

    function SwiftnessSpeed takes integer pid returns real
        if (Equip_Swiftness[pid]/40) >= 40 then
            return 40.00
        endif
        return (Equip_Swiftness[pid]/40)
    endfunction
    
    function ItemUIStatsSet takes integer pid returns nothing
        local real r =0
        local integer speed = 0
        set Stats_Crit[pid] = (Equip_Crit[pid]/28) + Hero_CriRate[pid]
        if GetLocalPlayer() == Player(pid) then
            //공격력
            call DzFrameSetText(F_ItemStatsText[0], I2S(R2I( Equip_Damage[pid] + Hero_Damage[pid]  ) ) )
            //방어등급
            call DzFrameSetText(F_ItemStatsText[1], I2S(R2I( Equip_Defense[pid] + Arcana_Defense[pid] )) )
            //치명
            call DzFrameSetText(F_ItemStatsText[2], I2S(R2I(  Equip_Crit[pid] )) )
            //특화
            call DzFrameSetText(F_ItemStatsText[3], I2S(R2I(  Equip_Specialization[pid] )) )
            //신속
            call DzFrameSetText(F_ItemStatsText[4], I2S(R2I(  Equip_Swiftness[pid] )) )
            //추가피해
            call DzFrameSetText(F_ItemStatsText[5], I2S(R2I(  Equip_DP[pid] + Arcana_DP[pid] )) + "%" )
            //치명타확률
            call DzFrameSetText(F_ItemStatsText[6], I2S(R2I(  Stats_Crit[pid] )) + "%")
            //공격속도
            call DzFrameSetText(F_ItemStatsText[7], I2S(R2I(  100 + SkillSpeed(pid) )) + "%" )
            //이동속도
            set speed = R2I(  ((Equip_Swiftness[pid]/40) + 100 + Hero_BuffMoveSpeed[pid] ) )
            if speed > 140 then
                set speed = 140
            endif
            call DzFrameSetText(F_ItemStatsText[8], I2S(speed) + "%" )
            //드랍률
            call DzFrameSetText(F_ItemStatsText[9], I2S(R2I(  Equip_Drop[pid] )) + "%" ) 
        endif
        call SetUnitMoveSpeed( MainUnit[pid], 4 * ((Equip_Swiftness[pid]/40) + 100 + Hero_BuffMoveSpeed[pid] ) )
    endfunction
    
    function PlayerStatsSet takes integer pid returns nothing
        local string items
        local integer tier
        local integer up
        local integer i = 0
        local integer j = 0
        local integer itemty = 0
        local integer qr = 0
        local integer quality = 0
        
        set Equip_Defense[pid] = 0
        set Equip_Damage[pid] = 0
        set Equip_Crit[pid] = 0
        set Equip_Specialization[pid] = 0
        set Equip_Swiftness[pid] = 0
        
        loop
            if GetItemIDs(Eitem[pid][i]) != 0 then
                set items = Eitem[pid][i]
                set itemty = GetItemTypes(items)
                set tier = GetItemTier(items)
                set up = GetItemUp(items)
                
                // 0모자, 1상의, 2하의, 3장갑, 4견갑, 5무기, 6목걸이, 7귀걸이, 8반지
                //장비 0아이템아이디, 1강화수치, 2품질, 3특성, 4각인1, 5각인2, 6패널티각인
                //목걸이 0품0, 1품질 5당 추가량
                //기타 0아이템아이디, 1중첩수
                
                //5무기
                if itemty == 5 then
                    set quality = GetItemQuality(items)
                    set Equip_Damage[pid] = Equip_Damage[pid] + S2I(JNStringSplit(ItemStats[itemty][tier],";", up ))
                    set Equip_DP[pid] = ItemWeaponQuality[quality]
                //0모자, 1상의, 2하의, 3장갑, 4견갑
                elseif itemty >= 0 and itemty <= 4 then
                    set Equip_Defense[pid] = Equip_Defense[pid] + S2I(JNStringSplit(ItemStats[itemty][tier],";", up ))
                elseif itemty == 6 then
        //목걸이 0품0, 1품질 5당 추가량
                    // j특성
                    set j = GetItemCombatStats(items)
                    //치신
                    if j == 1 then
                        // j품질
                        set j = GetItemQuality(items)
                        set Equip_Crit[pid] = Equip_Crit[pid] + S2I(JNStringSplit(ItemStats[itemty][tier],";", 0 )) + ( j * S2I(JNStringSplit(ItemStats[itemty][tier],";", 1 )))
                        set Equip_Swiftness[pid] = Equip_Swiftness[pid] + S2I(JNStringSplit(ItemStats[itemty][tier],";", 0 )) + ( j * S2I(JNStringSplit(ItemStats[itemty][tier],";", 1 )))
                    //치특
                    elseif j == 2 then
                        set j = GetItemQuality(items)
                        set Equip_Crit[pid] = Equip_Crit[pid] + S2I(JNStringSplit(ItemStats[itemty][tier],";", 0 )) + ( j * S2I(JNStringSplit(ItemStats[itemty][tier],";", 1 )))
                        set Equip_Specialization[pid] = Equip_Specialization[pid] + S2I(JNStringSplit(ItemStats[itemty][tier],";", 0 )) + ( j * S2I(JNStringSplit(ItemStats[itemty][tier],";", 1 )))
                    //특신
                    elseif j == 3 then
                        set j = GetItemQuality(items)
                        set Equip_Swiftness[pid] = Equip_Swiftness[pid] + S2I(JNStringSplit(ItemStats[itemty][tier],";", 0 )) + ( j * S2I(JNStringSplit(ItemStats[itemty][tier],";", 1 )))
                        set Equip_Specialization[pid] = Equip_Specialization[pid] + S2I(JNStringSplit(ItemStats[itemty][tier],";", 0 )) + ( j * S2I(JNStringSplit(ItemStats[itemty][tier],";", 1 )))
                    endif
                    set j = 0
                elseif itemty == 7 or itemty == 8 then
                    // j특성
                    set j = GetItemCombatStats(items)
                    //치
                    if j == 1 then
                        // j품질
                        set j = GetItemQuality(items)
                        set Equip_Crit[pid] = Equip_Crit[pid] + S2I(JNStringSplit(ItemStats[itemty][tier],";", 0 )) + ( j * S2I(JNStringSplit(ItemStats[itemty][tier],";", 1 )))
                    //특
                    elseif j == 2 then
                        set j = GetItemQuality(items)
                        set Equip_Specialization[pid] = Equip_Specialization[pid] + S2I(JNStringSplit(ItemStats[itemty][tier],";", 0 )) + ( j * S2I(JNStringSplit(ItemStats[itemty][tier],";", 1 )))
                    //신
                    elseif j == 3 then
                        set j = GetItemQuality(items)
                        set Equip_Swiftness[pid] = Equip_Swiftness[pid] + S2I(JNStringSplit(ItemStats[itemty][tier],";", 0 )) + ( j * S2I(JNStringSplit(ItemStats[itemty][tier],";", 1 )))
                    endif
                    set j = 0
                endif
                //각인추가
            endif
        exitwhen i == 12
            set i = i + 1
        endloop
        
    endfunction
                    
    private function EquipON takes nothing returns nothing
        local string s = JNStringSplit(DzGetTriggerSyncData(), "\t", 2)
        set Eitem[S2I(JNStringSplit(DzGetTriggerSyncData(), "\t", 0))][S2I(JNStringSplit(DzGetTriggerSyncData(), "\t", 1))] = s
        call PlayerStatsSet( S2I(JNStringSplit(DzGetTriggerSyncData(), "\t", 0)) )
        call ItemUIStatsSet(GetPlayerId(DzGetTriggerSyncPlayer()))
    endfunction
    
    private function EquipOFF takes nothing returns nothing
        set Eitem[S2I(JNStringSplit(DzGetTriggerSyncData(), "\t", 0))][S2I(JNStringSplit(DzGetTriggerSyncData(), "\t", 1))] = ""
        call PlayerStatsSet( S2I(JNStringSplit(DzGetTriggerSyncData(), "\t", 0)) )
        call ItemUIStatsSet(GetPlayerId(DzGetTriggerSyncPlayer()))
    endfunction
    
    private function EquipReset takes nothing returns nothing
        call PlayerStatsSet( S2I(DzGetTriggerSyncData()) )
        call ItemUIStatsSet(GetPlayerId(DzGetTriggerSyncPlayer()))
    endfunction
    
    
    private function init takes nothing returns nothing
        local trigger t
        //리셋 싱크
        set t = CreateTrigger()
        call DzTriggerRegisterSyncData(t, "리셋",false)
        call TriggerAddAction(t,function EquipReset)
        
        //장착 싱크
        set t = CreateTrigger()
        call DzTriggerRegisterSyncData(t, "장착",false)
        call TriggerAddAction(t,function EquipON)
        
        //해제 싱크
        set t = CreateTrigger()
        call DzTriggerRegisterSyncData(t, "해제",false)
        call TriggerAddAction(t,function EquipOFF)
    endfunction
endlibrary