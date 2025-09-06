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
        //real array Equip_Defense
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

        //카드 댐증
        real array Equip_CardDamage1
        real array Equip_CardDamage2
        
        //각인 각인방어등급, 각인추뎀, 각인공속, 치확, 치피, 체력, 이속, 공속
        //real array Arcana_Defense
        real array Arcana_DP
        real array Arcana_SkillSpeed
        real array Arcana_ChargeSpeed
        real array Arcana_Cri
        real array Arcana_CriDeal
        real array Arcana_HP
        real array Arcana_MoveSpeed
        real array Arcana_SkillSpeed2

        //각인
        hashtable ArcanaData = InitHashtable()
        real array Arcana_Count0
        real array Arcana_Count1
        real array Arcana_Count2
        real array Arcana_Count3
        real array Arcana_Count4
        real array Arcana_Count5
        real array Arcana_Count6
        real array Arcana_Count7
        real array Arcana_Count8
        real array Arcana_Count9
        real array Arcana_Count10

        //패널티 각인
        real array Arcana_Count50
        real array Arcana_Count51
        real array Arcana_Count52
        real array Arcana_Count53
        
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
        
        //set Equip_Defense[pid] = 0
        set Equip_Damage[pid] = 0
        set Equip_WDP[pid] = 0
        set Equip_Crit[pid] = 0
        set Equip_CriDeal[pid] = 0
        set Equip_Swiftness[pid] = 0
        set Equip_Drop[pid] = 0
        set Equip_Penetration [pid] = 0
        set Equip_ED[pid] = 0
        set Equip_DP[pid] = 1
        set Equip_DamageP[pid] = 0
        set Equip_LastDamage[pid] = 0
        set Equip_CardDamage1[pid] = 0
        set Equip_CardDamage2[pid] = 0

        //set Arcana_Defense[pid] = 0
        set Arcana_DP[pid] = 0
        set Arcana_SkillSpeed[pid] = 0
        set Arcana_ChargeSpeed[pid] = 1
        set Arcana_Cri[pid] = 0
        set Arcana_CriDeal[pid] = 0
        set Arcana_HP[pid] = 1
        set Arcana_MoveSpeed[pid] = 0
        set Arcana_SkillSpeed2[pid] = 0
        
        //플레이어 각인 테이블 초기화
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
        
        set pid = pid + 1
        exitwhen pid == bj_MAX_PLAYER_SLOTS
    endloop
endfunction
endlibrary