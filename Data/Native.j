library Native initializer init

    function CharacterSave takes boolean auto, integer var returns nothing
    endfunction
    
    globals
        //플레이어 아이디
        string array PlayerName
    
        //영웅 공격력, 치확, 치피, 생명력, 자벞, 물약버프, 버프 이속, 버프 공속
        //real array Hero_Str
        //real array Hero_Defense
        real array Hero_Damage
        real array Hero_CriRate
        real array Hero_CriDeal
        //real array Hero_Hp
        real array Hero_Buff
        real array Hero_Buff2
        real array Hero_BuffMoveSpeed
        real array Hero_BuffAttackSpeed
        
        //장비 방어등급, 장비공격력, 무기추피, 치명, 치피, 신속, 드랍률
        real array Equip_Defense
        real array Equip_Damage
        real array Equip_WDP
        real array Equip_Crit
        real array Equip_CriDeal
        real array Equip_Swiftness
        real array Equip_Drop
        //장비 방관, 추피, 댐증, 공퍼, 최종댐
        real array Equip_Penetration
        real array Equip_ED
        real array Equip_DP
        real array Equip_DamageP
        real array Equip_LastDamage
        
        //각인 각인방어등급, 각인추뎀
        real array Arcana_Defense
        real array Arcana_DP
        
        //치명스텟크확, 전투력, 개척력(명성)
        real array Stats_Crit
        real array Stats_Power
        real array Stats_TrailblazePower
        
        //일시적인 방관버프
        real array Penetration
        //픽체크
        boolean array PickCheck
    endglobals

private function init takes nothing returns nothing
    local integer pid
    
    //딜 자동 0으로 설정
    call JNSetSyncDelay(0)
    
    set pid = 0
    loop
        set Hero_Damage[pid] = 0
        set Hero_CriRate[pid] = 0
        set Hero_CriDeal[pid] = 100
        //set Hero_Hp[pid] = 10000
        set Hero_Buff[pid] = 0
        set Hero_Buff2[pid] = 0
        set Hero_BuffMoveSpeed[pid] = 0
        set Hero_BuffAttackSpeed[pid] = 0
        set Penetration[pid] = 0
        
        set Equip_Defense[pid] = 0
        set Equip_Damage[pid] = 0
        set Equip_WDP[pid] = 0
        set Equip_Crit[pid] = 0
        set Equip_CriDeal[pid] = 0
        set Equip_Swiftness[pid] = 0
        set Equip_Drop[pid] = 0
        set Equip_Penetration [pid] = 0
        set Equip_ED[pid] = 0
        set Equip_DP[pid] = 0
        set Equip_DamageP[pid] = 0
        set Equip_LastDamage[pid] = 0

        set Arcana_Defense[pid] = 0
        set Arcana_DP[pid] = 0
        
        set pid = pid + 1
        exitwhen pid == bj_MAX_PLAYER_SLOTS
    endloop
endfunction
endlibrary