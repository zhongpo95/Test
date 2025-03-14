library StatsSet initializer init requires UIHP, ITEM
    function SkillSpeed takes integer pid returns real
        if (Equip_Swiftness[pid]/45) + Hero_BuffAttackSpeed[pid] >= 40 then
            return 40.00
        endif
        return (Equip_Swiftness[pid]/45) + Hero_BuffAttackSpeed[pid]
    endfunction
    
    function SkillSpeed2 takes integer pid, real PlusSpeed returns real
        if (Equip_Swiftness[pid]/45) + Hero_BuffAttackSpeed[pid] >= 40 then
            return 40.00 + PlusSpeed
        endif
        return (Equip_Swiftness[pid]/45) + Hero_BuffAttackSpeed[pid] + PlusSpeed
    endfunction

    function SwiftnessSpeed takes integer pid returns real
        if (Equip_Swiftness[pid]/45) >= 40 then
            return 40.00
        endif
        return (Equip_Swiftness[pid]/45)
    endfunction

    //전투력
    function Power takes integer pid returns real
        local real cooldownReduction = Equip_Swiftness[pid] / 46.0 / 100.0
        local real critical = Equip_Crit[pid] / 28.0 / 100.0
        local real defenseRatio = Equip_Penetration[pid] * 10000.0
        local real defenseReductionAmount = defenseRatio / (defenseRatio + 10000.0)
        local real damageReductionRate = 1.0 - defenseReductionAmount

        return Equip_Damage[pid] * (1.0 + Equip_DamageP[pid] / 100.0) * (1.0 + ((Equip_ED[pid] + Arcana_DP[pid] + Equip_WDP[pid]) / 100.0)) * (1.0 + critical * (Equip_CriDeal[pid] + 100) / 100.0) * (1.0 / (1.0 - cooldownReduction)) * damageReductionRate * (1.0 + Equip_DP[pid] / 100.0) * (1.0 + Equip_LastDamage[pid] / 100.0) 
    endfunction


    globals
        // 전투력 1,173,908에 대한 명성 값 상수
        private integer FAME_1 = 60000
        // 전투력 1,173,908에 대한 명성 값 상수
        private integer FAME_2 = 120000
        // 전투력 1,173,908에 대한 명성 값 상수
        private integer FAME_3 = 30000
    endglobals


    private function ln takes real x returns real
        local real result = 0.0
        local real term = 0.0
        local integer n = 1
    
        if x <= 0.0 then
            return 0.0
        endif
    
        if x == 1.0 then
            return 0.0
        endif
    
        if x > 2.0 then
            return -ln(1.0 / x)
        endif
    
        set x = x - 1.0
        set term = x
    
        loop
            set result = result + term / n
            set term = -term * x
            set n = n + 1
            exitwhen SquareRoot(term * term) < 0.000001
        endloop
    
        return result
    endfunction
    
    private function log1_1 takes real x returns real
        local real LN_1_1 = 0.09531
        return ln(x) / LN_1_1
    endfunction

    //개척력
    function TrailblazePower takes real x returns integer
        local real log_val
        local real scaled_val
    
        if x < 1000 then
            return 0
        elseif x >= 13780612.0 then
            // 전투력 13,780,612 이상일 경우 상수 사용
            set log_val = log1_1(x / 13780612.0)
            return FAME_2 + R2I(1000.0 * log_val + 0.5)
        elseif x >= 117391.0 then
            // 전투력 117,391 이상일 경우 상수 사용
            set log_val = log1_1(x / 117391.0)
            return FAME_1 + R2I(1000.0 * log_val + 0.5)
        elseif x >= 6727.0 then
            // 전투력 6,727 이상일 경우 상수 사용
            set log_val = log1_1(x / 6727.0)
            return FAME_3 + R2I(1000.0 * log_val + 0.5)
        else
            // 기존 계산 방식 사용
            set log_val = log1_1(x / 1000.0)
            set scaled_val = 10000.0 + 1000.0 * log_val
            return R2I(scaled_val + 0.5)
        endif
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
            call DzFrameSetText(F_ItemStatsText[2], I2S(R2I( Equip_Crit[pid] )) )
            //신속
            call DzFrameSetText(F_ItemStatsText[3], I2S(R2I( Equip_Swiftness[pid] )) )
            //추가피해
            call DzFrameSetText(F_ItemStatsText[4], I2S(R2I( Equip_WDP[pid] + Arcana_DP[pid] + Equip_ED[pid] )) + "%" )
            //치명타확률
            call DzFrameSetText(F_ItemStatsText[5], I2S(R2I( Stats_Crit[pid] )) + "%")
            //공격속도
            call DzFrameSetText(F_ItemStatsText[6], I2S(R2I( 100 + SkillSpeed(pid) )) + "%" )
            //이동속도
            set speed = R2I(  ((Equip_Swiftness[pid]/45) + 100 + Hero_BuffMoveSpeed[pid] ) )
            if speed > 140 then
                set speed = 140
            endif
            call DzFrameSetText(F_ItemStatsText[7], I2S(speed) + "%" )
            //드랍률
            call DzFrameSetText(F_ItemStatsText[8], I2S(R2I(  Equip_Drop[pid] )) + "%" ) 
            //공퍼
            call DzFrameSetText(F_ItemStatsText[9], I2S(R2I(  Equip_DamageP[pid] )) + "%" ) 
            //쿨감
            call DzFrameSetText(F_ItemStatsText[10], R2S(  (Equip_Swiftness[pid]/46)  ) + "%" ) 
            //방관
            call DzFrameSetText(F_ItemStatsText[11], I2S(R2I(  Equip_Penetration[pid] )) + "%" ) 
            //대미지증가
            call DzFrameSetText(F_ItemStatsText[12], I2S(R2I(  Equip_DP[pid] )) + "%" ) 
            //최종대미지증가
            call DzFrameSetText(F_ItemStatsText[13], I2S(R2I(  Equip_LastDamage[pid] )) + "%" ) 
            //가상 전투력
            set r = Power(pid)
            call DzFrameSetText(F_ItemStatsText[14], R2SW(r, 1, 0) ) 
            //개척력
            //call DzFrameSetText(F_ItemStatsText[15], I2S(R2I(  TrailblazePower(r) )) ) 
            call DzFrameSetText(F_ItemStatsText[15], R2SW(TrailblazePower(r), 1, 0)) 
        endif
        call SetUnitMoveSpeed( MainUnit[pid], 4 * ((Equip_Swiftness[pid]/45) + 100 + Hero_BuffMoveSpeed[pid] ) )
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
        set Equip_Swiftness[pid] = 0
        call SaveInteger(ArcanaData, 0, pid, 0)
        call SaveInteger(ArcanaData, 1, pid, 0)
        call SaveInteger(ArcanaData, 2, pid, 0)
        call SaveInteger(ArcanaData, 3, pid, 0)
        call SaveInteger(ArcanaData, 4, pid, 0)
        call SaveInteger(ArcanaData, 5, pid, 0)
        call SaveInteger(ArcanaData, 6, pid, 0)
        call SaveInteger(ArcanaData, 7, pid, 0)
        call SaveInteger(ArcanaData, 8, pid, 0)
        call SaveInteger(ArcanaData, 9, pid, 0)
        call SaveInteger(ArcanaData, 10, pid, 0)
        //패널티
        call SaveInteger(ArcanaData, 50, pid, 0)
        call SaveInteger(ArcanaData, 51, pid, 0)
        call SaveInteger(ArcanaData, 52, pid, 0)
        call SaveInteger(ArcanaData, 53, pid, 0)
        
        loop
            if GetItemIDs(Eitem[pid][i]) != 0 then
                set items = Eitem[pid][i]
                set itemty = GetItemTypes(items)
                set tier = GetItemTier(items)
                set up = GetItemUp(items)
                
                // 0모자, 1상의, 2하의, 3장갑, 4견갑, 5무기, 6목걸이, 7귀걸이, 8반지
                //장비 0아이템아이디, 1강화수치, 2품질, 3특성, 4각인1, 5각인2, 6각인P
                //목걸이 0품0, 1품질 5당 추가량
                //기타 0아이템아이디, 1중첩수
                
                //5무기
                if itemty == 5 then
                    set quality = GetItemQuality(items)
                    set Equip_Damage[pid] = Equip_Damage[pid] + S2I(JNStringSplit(ItemStats[itemty][tier],";", up ))
                    set Equip_WDP[pid] = ItemWeaponQuality[quality]
                //0모자, 1상의, 2하의, 3장갑, 4견갑
                elseif itemty >= 0 and itemty <= 4 then
                    set Equip_Defense[pid] = Equip_Defense[pid] + S2I(JNStringSplit(ItemStats[itemty][tier],";", up ))
                //목걸이
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
                    //치치
                    elseif j == 2 then
                        set j = GetItemQuality(items)
                        set Equip_Crit[pid] = Equip_Crit[pid] + S2I(JNStringSplit(ItemStats[itemty][tier],";", 0 )) + ( j * S2I(JNStringSplit(ItemStats[itemty][tier],";", 1 )))
                        set Equip_Crit[pid] = Equip_Crit[pid] + S2I(JNStringSplit(ItemStats[itemty][tier],";", 0 )) + ( j * S2I(JNStringSplit(ItemStats[itemty][tier],";", 1 )))
                    //신신
                    elseif j == 3 then
                        set j = GetItemQuality(items)
                        set Equip_Swiftness[pid] = Equip_Swiftness[pid] + S2I(JNStringSplit(ItemStats[itemty][tier],";", 0 )) + ( j * S2I(JNStringSplit(ItemStats[itemty][tier],";", 1 )))
                        set Equip_Swiftness[pid] = Equip_Swiftness[pid] + S2I(JNStringSplit(ItemStats[itemty][tier],";", 0 )) + ( j * S2I(JNStringSplit(ItemStats[itemty][tier],";", 1 )))
                    endif
                    if GetItemCombatBonus2(items) > 0 then
                        call SaveInteger(ArcanaData, GetItemCombatBonus1(items), pid, LoadInteger(ArcanaData, GetItemCombatBonus1(items), pid) + GetItemCombatBonus2(items) )
                    endif
                    if GetItemCombatPenalty2(items) > 0 then
                        call SaveInteger(ArcanaData, GetItemCombatBonus1(items), pid, LoadInteger(ArcanaData, GetItemCombatPenalty(items), pid) + GetItemCombatPenalty2(items) )
                    endif
                    set j = 0
                //귀걸이,반지
                elseif itemty == 7 or itemty == 8 then
                    // j특성
                    set j = GetItemCombatStats(items)
                    //치
                    if j == 1 then
                        // j품질
                        set j = GetItemQuality(items)
                        set Equip_Crit[pid] = Equip_Crit[pid] + S2I(JNStringSplit(ItemStats[itemty][tier],";", 0 )) + ( j * S2I(JNStringSplit(ItemStats[itemty][tier],";", 1 )))
                    //신
                    elseif j == 2 then
                        set j = GetItemQuality(items)
                        set Equip_Swiftness[pid] = Equip_Swiftness[pid] + S2I(JNStringSplit(ItemStats[itemty][tier],";", 0 )) + ( j * S2I(JNStringSplit(ItemStats[itemty][tier],";", 1 )))
                    endif
                    if GetItemCombatBonus2(items) > 0 then
                        call SaveInteger(ArcanaData, GetItemCombatBonus1(items), pid, LoadInteger(ArcanaData, GetItemCombatBonus1(items), pid) + GetItemCombatBonus2(items) )
                    endif
                    if GetItemCombatPenalty2(items) > 0 then
                        call SaveInteger(ArcanaData, GetItemCombatBonus1(items), pid, LoadInteger(ArcanaData, GetItemCombatPenalty(items), pid) + GetItemCombatPenalty2(items) )
                    endif
                    set j = 0
                endif
                //각인추가
            endif
        exitwhen i == 15
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