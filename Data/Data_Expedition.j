// 원정 진행 상태와 임시 성장 및 공통 판정 데이터를 관리한다.
library DataExpedition
    globals
        constant integer EXP_LOBBY = 0
        constant integer EXP_START = 1
        constant integer EXP_VOTE = 2
        constant integer EXP_BATTLE = 3
        constant integer EXP_REWARD = 4
        constant integer EXP_SHOP = 5
        constant integer EXP_MOVE = 6
        constant integer EXP_RESULT = 7
        constant integer EXP_EVENT = 8
        integer ExpState = EXP_LOBBY
        integer ExpRun = 0
        integer ExpRevision = 0
        integer ExpStep = 0
        integer ExpNode = 0
        integer ExpSeconds = 0
        integer ExpLife = 100
        integer ExpPlayers = 0
        integer ExpArena = 0
        integer ExpBattleLimit = 120
        real ExpProgress = 0.0
        boolean ExpWon = false
        boolean ExpBossBattle = false
        boolean ExpLifeBought = false
        boolean ExpLifeUseful = false
        boolean array ExpMember
        boolean array ExpLeft
        boolean array ExpReady
        boolean array ExpDone
        integer array ExpVote
        integer array ExpGold
        integer array ExpPoints
        integer array ExpCritPoints
        integer array ExpSwiftPoints
        integer array ExpFixedCrit
        integer array ExpFixedSwift
        integer array ExpLuck
        integer array ExpRolls
        integer array ExpOfferVersion
        boolean array ExpRewardTaken
        integer array ExpRewardGrade
        integer array ExpRewardKind
        integer array ExpRewardPotion
        integer array ExpRewardCardA
        integer array ExpRewardCardB
        boolean array ExpCardReserved
        integer array ExpArcana
        boolean array ExpCardOwned
        boolean array ExpCardSeen
        integer array ExpShopCard
        boolean array ExpShopSold
        integer array ExpPotionBought
        boolean array ExpStatBought
        integer array ExpArcanaA
        integer array ExpArcanaB
        integer array ExpArcanaLevel
        integer array ExpPenalty
        integer array ExpEventCandidate
        integer array ExpEventGrade
        integer array ExpEventDeadline
        integer array ExpEventTargetCard
        integer array ExpEventTargetArcana
        integer array ExpEventTargetPenalty
        boolean array ExpEventResolved
        string array ExpEventOutcome
        integer ExpEncounter = 1
        integer array ExpEventReservation
        boolean array ExpEventUsed
        integer array ExpStartCard
        integer array ExpStartCardKind
        boolean array ExpEnemy
        integer array ExpConfirmedBattles
        string array ExpResultText
        trigger ExpRefresh = CreateTrigger()
        trigger ExpBattleFinished = CreateTrigger()
    endglobals

    function ExpKey takes integer pid, integer id returns integer
        return pid * 64 + id
    endfunction

    function ExpLoss takes integer node, real progress returns integer
        local integer base = 5
        local real loss
        local integer rounded
        if progress >= 1.0 then
            return 0
        endif
        if progress < 0.0 then
            set progress = 0.0
        endif
        if node >= 16 then
            set base = 15
        elseif node >= 9 then
            set base = 10
        endif
        set loss = base * (2.0 - progress)
        set rounded = R2I(loss)
        if I2R(rounded) < loss then
            set rounded = rounded + 1
        endif
        return rounded
    endfunction

    function ExpPointRoom takes integer pid, integer offered returns integer
        if ExpPoints[pid] >= 40 then
            return 0
        endif
        if ExpPoints[pid] + offered > 40 then
            return 40 - ExpPoints[pid]
        endif
        return offered
    endfunction

    function ExpGradeFromRoll takes integer roll returns integer
        if roll <= 5500 then
            return 1
        elseif roll <= 9000 then
            return 2
        elseif roll <= 9950 then
            return 3
        endif
        return 4
    endfunction

    function ExpGradeGold takes integer grade returns integer
        if grade == 1 then
            return 150
        elseif grade == 2 then
            return 250
        elseif grade == 3 then
            return 500
        endif
        return 1200
    endfunction

    function ExpEventGradeName takes integer grade returns string
        if grade == 1 then
            return "노말"
        elseif grade == 2 then
            return "레어"
        elseif grade == 3 then
            return "에픽"
        endif
        return "프리즘"
    endfunction

    function ExpCardName takes integer id returns string
        if id == 1 then
            return "조로 · 삼도류"
        elseif id == 2 then
            return "미나토 · 황색 섬광"
        elseif id == 3 then
            return "이타도리 · 주먹에 실은 주력"
        elseif id == 4 then
            return "리바이 · 급소 절단"
        elseif id == 5 then
            return "우솝 · 저격왕"
        elseif id == 6 then
            return "레이무 · 가난한 낙원"
        elseif id == 7 then
            return "나나미 · 십획주법"
        elseif id == 8 then
            return "린 · 보석마술"
        elseif id == 9 then
            return "에드워드 · 구축의 연금술"
        elseif id == 10 then
            return "호두 · 피안접무"
        elseif id == 11 then
            return "호로 · 현랑의 흥정"
        elseif id == 12 then
            return "도라에몽 · 바이바인"
        endif
        return "품절"
    endfunction

    function ExpCardText takes integer id returns string
        if id == 1 then
            return "공격력 +20%|n무기와 엘릭서의 고정 공격력 기준"
        elseif id == 2 then
            return "체력 80% 이상인 적에게 피해량 +40%"
        elseif id == 3 then
            return "거리 400 이하인 적에게 피해량 +30%"
        elseif id == 4 then
            return "체력 30% 이하인 적에게 피해량 +40%"
        elseif id == 5 then
            return "거리 600 이상인 적에게 피해량 +30%"
        elseif id == 6 then
            return "보유 골드 50 이하일 때 피해량 +30%"
        elseif id == 7 then
            return "방관 +20%, 남은 시간 20% 이하일 때 피해량 +40%"
        elseif id == 8 then
            return "보유 골드 10당 방관 +0.3%p"
        elseif id == 9 then
            return "3레벨 이상 일반 각인 종류당 피해량 +10%"
        elseif id == 10 then
            return "자신의 체력 35% 이하일 때 피해량 +60%"
        elseif id == 11 then
            return "이후 상점 결제액 15% 할인"
        elseif id == 12 then
            return "물약 충전 획득량 +1"
        endif
        return "남은 미등장 카드가 없습니다."
    endfunction

    function ExpCardGrade takes integer id returns integer
        if id <= 6 then
            return 1
        endif
        return 2
    endfunction

    function ExpNodeKind takes integer node returns integer
        if node == 1 then
            return EXP_START
        elseif node == 4 or node == 11 or node == 18 or node == 22 then
            return EXP_SHOP
        elseif node == 6 or node == 8 or node == 13 or node == 15 or node == 20 or node == 23 then
            return EXP_BATTLE
        elseif node == 7 or node == 14 or node == 21 then
            return EXP_EVENT
        endif
        return EXP_VOTE
    endfunction

    function ExpHasTeamRewardEvent takes integer node returns boolean
        return node == 6 or node == 8 or node == 13 or node == 15 or node == 20
    endfunction
endlibrary
