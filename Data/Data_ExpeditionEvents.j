// 개인 사건과 파티 조우의 상황·행동·결과 안내를 정의한다.
library DataExpeditionEvents requires DataExpedition, DataArcana, Native
    function ExpEventTitle takes integer id returns string
        return JNStringSplit("잊힌 야영지|노점의 밀봉 상자|바퀴가 부서진 수레|금이 간 각인석|기억을 사는 수집가|봉인된 금고|침묵의 정화샘|각인사의 작업대|멈춰 선 보급 열차", "|", id - 1)
    endfunction

    function ExpEventScene takes integer id returns string
        if id == 1 then
            return "모닥불은 식었지만 약상자에는 온기가 남아 있습니다. 철수한 이들이 두고 간 짐을 살펴봅니다."
        elseif id == 2 then
            return "상인은 상자를 열어 보이지 않습니다. 전투 기록과 물약 중 필요한 것을 사라며 가격표를 내밉니다."
        elseif id == 3 then
            return "바퀴가 부서진 수레 곁에 다친 상인이 앉아 있습니다. 약이 없어도 수레를 미는 일은 도울 수 있습니다."
        elseif id == 4 then
            return "각인석의 균열에서 힘이 흘러나옵니다. 손을 대면 저주까지 옮겨올 듯합니다. 파편만 팔 수도 있습니다."
        elseif id == 5 then
            return "수집가는 당신의 전투 기록 하나를 가리킵니다. 돈으로 살 수도, 더 희귀한 기록과 교환할 수도 있다고 합니다."
        elseif id == 6 then
            return "금고 앞에 작은 동전 주머니가 놓여 있습니다. 안쪽 금고를 열려면 해제 장치에 돈을 넣어야 합니다."
        elseif id == 7 then
            return "샘에 던진 동전이 흔적 없이 녹습니다. 물에 손을 담그자 몸에 붙은 저주도 희미해집니다."
        elseif id == 8 then
            return "각인사가 작업대를 펼쳐 놓고 손님을 기다립니다. 문양을 새기거나, 바쁜 그를 도와 품삯을 받을 수 있습니다."
        endif
        return "선로 끝에 멈춘 보급 열차를 발견했습니다. 온전한 전투 기록과 보급품 중 옮길 짐을 고릅니다."
    endfunction

    function ExpEventOptionTitle takes integer id, integer choice returns string
        local string names
        if choice == 3 then
            return "떠나기"
        endif
        if id == 1 then
            set names = "약상자를 챙긴다|귀중품을 모은다"
        elseif id == 2 then
            set names = "기록 상자를 산다|물약을 산다"
        elseif id == 3 then
            set names = "약을 건넨다|수레를 밀어준다"
        elseif id == 4 then
            set names = "힘을 받아들인다|파편을 판다"
        elseif id == 5 then
            set names = "기록을 교환한다|기록을 판다"
        elseif id == 6 then
            set names = "주머니만 챙긴다|금고를 연다"
        elseif id == 7 then
            set names = "저주를 씻어 낸다|약수를 담는다"
        elseif id == 8 then
            set names = "각인을 새긴다|작업대를 정리한다"
        else
            set names = "기록을 챙긴다|보급품을 챙긴다"
        endif
        return JNStringSplit(names, "|", choice - 1)
    endfunction

    function ExpEventArcanaGain takes integer pid returns integer
        if ExpEventTargetArcana[pid] < 0 then
            return 0
        endif
        return IMaxBJ(0, IMinBJ(2, 3 - LoadInteger(ArcanaData, ExpEventTargetArcana[pid], pid)))
    endfunction

    function ExpEventOptionText takes integer pid, integer choice returns string
        local integer id = ExpEventCandidate[pid]
        if choice == 3 then
            return "비용 없이 떠납니다.|n이 사건은 이번 원정에서 다시 등장하지 않습니다."
        endif
        if id == 1 then
            if choice == 1 then
                return "회복 물약 +1회 충전"
            endif
            return "80골드를 얻습니다."
        elseif id == 2 then
            if choice == 1 then
                return "100골드 지불|n미등장 일반 카드 1장 획득"
            endif
            return "50골드 지불|n최종 대미지 물약 +1회 충전"
        elseif id == 3 then
            if choice == 1 then
                return "회복 물약 1회 반납|n200골드를 얻습니다."
            endif
            return "60골드를 얻습니다."
        elseif id == 4 then
            if choice == 1 then
                if ExpEventTargetArcana[pid] < 0 or ExpEventTargetPenalty[pid] == 0 then
                    return "받아들일 수 있는 각인 조합이 없습니다."
                endif
                return ArcanaText[ExpEventTargetArcana[pid]] + " +" + I2S(ExpEventArcanaGain(pid)) + "|n|cff98284d" + ArcanaText[ExpEventTargetPenalty[pid]] + " +1|r"
            endif
            return "80골드를 얻습니다."
        elseif id == 5 then
            if choice == 1 then
                return "반납  " + ExpCardName(ExpEventTargetCard[pid]) + "|n미등장 레어 카드 1장 획득"
            endif
            return "반납  " + ExpCardName(ExpEventTargetCard[pid]) + "|n250골드를 얻습니다."
        elseif id == 6 then
            if choice == 1 then
                return "100골드를 얻습니다."
            endif
            return "100골드 지불|n50%  400골드 획득|n50%  빈 금고 (획득 없음)"
        elseif id == 7 then
            if choice == 1 then
                return "150골드 지불|n" + ArcanaText[ExpEventTargetPenalty[pid]] + "의 원정 획득분 전부 제거|n장비의 감소 각인은 유지됩니다."
            endif
            return "회복 물약 +2회 충전"
        elseif id == 8 then
            if choice == 1 then
                if ExpEventTargetArcana[pid] < 0 then
                    return "새길 수 있는 각인이 없습니다."
                endif
                return "150골드 지불|n" + ArcanaText[ExpEventTargetArcana[pid]] + " +1|n감소 각인 없음"
            endif
            return "100골드를 얻습니다."
        endif
        if choice == 1 then
            return "미등장 레어 카드 2장 획득"
        endif
        return "500골드를 얻습니다.|n모든 물약 +1회 충전"
    endfunction

    function ExpEncounterTitle takes integer id returns string
        return JNStringSplit("무너진 봉쇄선|마물의 식량 창고|길목의 결투자", "|", id - 1)
    endfunction

    function ExpEncounterScene takes integer id returns string
        if id == 1 then
            return "적의 봉쇄선에 빈틈이 보입니다. 그대로 돌파하거나 보급로를 따라 돌아갈 수 있습니다."
        elseif id == 2 then
            return "마물들이 보급품을 창고로 나르고 있습니다. 창고를 노리면 더 거센 저항을 받게 됩니다."
        endif
        return "무장한 무리가 길을 막습니다. 짧은 시간 안에 자신들을 이기면 전투 기록을 넘겨주겠다고 합니다."
    endfunction

    function ExpEncounterOptionTitle takes integer id, integer choice returns string
        if id == 1 then
            return JNStringSplit("빈틈으로 돌파|보급로로 우회", "|", choice - 1)
        elseif id == 2 then
            return JNStringSplit("창고를 습격|외곽만 수색", "|", choice - 1)
        endif
        return JNStringSplit("도전을 수락|길을 비켜 간다", "|", choice - 1)
    endfunction

    function ExpEncounterOptionText takes integer id, integer choice returns string
        if id == 1 then
            if choice == 1 then
                return "일반 적 체력 45만 × 인원|n제한시간 120초|n기본 전투 승리 보상"
            endif
            return "전투 생략|n각자 무작위 물약 +1회|n개인 성장 선택으로 이동"
        elseif id == 2 then
            if choice == 1 then
                return "일반 적 체력 55만 × 인원|n제한시간 120초|n승리 시 기본 보상 + 각자 100골드"
            endif
            return "전투 생략 · 각자 50골드|n개인 성장 선택으로 이동"
        endif
        if choice == 1 then
            return "일반 적 체력 45만 × 인원|n제한시간 90초|n승리 시 기본 보상 + 일반 카드 1장|n카드 소진 시 150골드"
        endif
        return "전투 생략 · 각자 60골드|n개인 성장 선택으로 이동"
    endfunction
endlibrary
