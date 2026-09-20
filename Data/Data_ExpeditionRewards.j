// 기본 성장의 즉시 랜덤 보상을 사건과 분리하여 종류와 수량만 안내한다.
library DataExpeditionRewards requires DataExpedition
    function ExpRewardTitle takes integer kind returns string
        if kind == 1 then
            return "150골드"
        elseif kind == 2 then
            return "노말 카드 1장"
        elseif kind == 3 then
            return "고정 치명 +75"
        elseif kind == 4 then
            return "고정 신속 +75"
        elseif kind == 5 then
            return "회복 물약 +2회"
        elseif kind == 6 then
            return "무작위 물약 +3회"
        elseif kind == 7 then
            return "250골드"
        elseif kind == 8 then
            return "레어 카드 1장"
        elseif kind == 9 then
            return "노말 카드 2장"
        elseif kind == 10 then
            return "고정 치명 +150"
        elseif kind == 11 then
            return "고정 신속 +150"
        elseif kind == 12 then
            return "모든 물약 +2회"
        elseif kind == 13 then
            return "500골드"
        elseif kind == 14 then
            return "희귀 카드 1장"
        elseif kind == 15 then
            return "레어 카드 2장"
        elseif kind == 16 then
            return "스탯 15포인트"
        elseif kind == 17 then
            return "고정 치명 +250"
        elseif kind == 18 then
            return "고정 신속 +250"
        elseif kind == 19 then
            return "행운 +1"
        elseif kind == 20 then
            return "전설 1장 + 레어 1장"
        elseif kind == 21 then
            return "희귀 카드 3장"
        elseif kind == 22 then
            return "고정 치명·신속 +300"
        endif
        return "1,200골드"
    endfunction

    function ExpRewardText takes integer pid returns string
        local integer kind = ExpRewardKind[pid]
        if kind == 2 or kind == 8 or kind == 9 or kind == 14 or kind == 15 or kind == 20 or kind == 21 then
            return "개인 미등장 카드에서 무작위 지급|n카드 이름은 획득 후 공개합니다.|n|n기본 보상 뒤 추가 사건 진행"
        elseif kind == 6 then
            return "기존 물약 중 한 종류를 3회 충전합니다.|n물약 종류는 획득할 때 공개됩니다.|n|n기본 보상 뒤 추가 사건 진행"
        elseif kind == 5 or kind == 12 then
            return "표시된 물약 충전을 즉시 얻습니다.|n바이바인의 추가 충전 효과 적용|n|n기본 보상 뒤 추가 사건 진행"
        elseif kind == 16 then
            return "스탯 배분 포인트를 즉시 얻습니다.|n총 40포인트 한도 이내 지급|n|n기본 보상 뒤 추가 사건 진행"
        endif
        return "표시된 수치만큼 즉시 얻습니다.|n|n기본 보상 뒤 추가 사건 진행"
    endfunction
endlibrary
