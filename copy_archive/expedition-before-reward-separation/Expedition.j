// 짧은 시험 원정의 동기화된 진행과 개인 보상 및 확정 결과 저장을 담당한다.
library Expedition initializer Init requires DataExpedition, DataExpeditionEvents, ExpeditionCombat, ExpeditionEffects, StatsSet, ItemPickUp, PlayerSave
    globals
        private timer Clock = CreateTimer()
        private integer NextState = 0
        private integer Elapsed = 0
        private integer array Order
    endglobals

    private function RefreshStats takes integer pid returns nothing
        local real ratio = GetUnitState(MainUnit[pid], UNIT_STATE_LIFE) / GetUnitState(MainUnit[pid], UNIT_STATE_MAX_LIFE)
        call PlayerStatsSet(pid)
        call ItemUIStatsSet(pid)
        call SetUnitState(MainUnit[pid], UNIT_STATE_LIFE, GetUnitState(MainUnit[pid], UNIT_STATE_MAX_LIFE) * ratio)
        call RefreshHP(MainUnit[pid])
    endfunction

    function ExpChoiceSeconds takes integer pid returns integer
        if ExpEventDeadline[pid] > 0 then
            return IMaxBJ(0, ExpEventDeadline[pid] - Elapsed)
        endif
        return ExpSeconds
    endfunction

    private function GrantPoints takes integer pid, integer amount returns nothing
        local integer accepted = ExpPointRoom(pid, amount)
        set ExpPoints[pid] = ExpPoints[pid] + accepted
        set ExpGold[pid] = ExpGold[pid] + (amount - accepted) * 20
    endfunction

    private function DrawCard takes integer pid, integer grade returns integer
        local integer first = 1
        local integer last = 6
        local integer count = 0
        local integer selected = 0
        if grade == 2 then
            set first = 7
            set last = 10
        elseif grade == 5 then
            set first = 11
            set last = 12
        elseif grade != 1 then
            return 0
        endif
        loop
            exitwhen first > last
            if not ExpCardSeen[ExpKey(pid, first)] then
                set count = count + 1
                if GetRandomInt(1, count) == 1 then
                    set selected = first
                endif
            endif
            set first = first + 1
        endloop
        if selected != 0 then
            set ExpCardSeen[ExpKey(pid, selected)] = true
        endif
        return selected
    endfunction

    private function GrantCard takes integer pid, integer card, integer grade returns nothing
        if card == 0 then
            set ExpGold[pid] = ExpGold[pid] + ExpGradeGold(grade)
        else
            set ExpCardOwned[ExpKey(pid, card)] = true
            call DisplayTimedTextToPlayer(Player(pid), 0, 0, 10, "카드 획득 · " + ExpCardName(card) + " · " + ExpCardText(card))
        endif
    endfunction

    private function CardsLeft takes integer pid, integer first, integer last returns integer
        local integer count = 0
        loop
            exitwhen first > last
            if not ExpCardSeen[ExpKey(pid, first)] then
                set count = count + 1
            endif
            set first = first + 1
        endloop
        return count
    endfunction

    private function OwnedEventCard takes integer pid returns integer
        local integer i = 1
        loop
            exitwhen i > 6
            if ExpCardOwned[ExpKey(pid, i)] then
                return i
            endif
            set i = i + 1
        endloop
        return 0
    endfunction

    private function OwnedEventPenalty takes integer pid returns integer
        local integer i = 50
        local integer selected = 0
        local integer largest = 0
        loop
            exitwhen i > 53
            if ExpArcana[ExpKey(pid, i)] > largest then
                set selected = i
                set largest = ExpArcana[ExpKey(pid, i)]
            endif
            set i = i + 1
        endloop
        return selected
    endfunction

    private function EventValid takes integer pid, integer id returns boolean
        if id == 5 then
            return OwnedEventCard(pid) != 0
        elseif id == 7 then
            return OwnedEventPenalty(pid) != 0
        endif
        return true
    endfunction

    private function PrepareEvent takes integer pid returns nothing
        local integer i = 0
        local integer count = 0
        set ExpEventTargetCard[pid] = OwnedEventCard(pid)
        set ExpEventTargetPenalty[pid] = OwnedEventPenalty(pid)
        set ExpEventTargetArcana[pid] = -1
        set ExpEventResolved[pid] = false
        set ExpEventOutcome[pid] = ""
        if ExpEventCandidate[pid] == 4 or ExpEventCandidate[pid] == 8 then
            loop
                exitwhen i > 10
                if LoadInteger(ArcanaData, i, pid) < 3 then
                    set count = count + 1
                    if GetRandomInt(1, count) == 1 then
                        set ExpEventTargetArcana[pid] = i
                    endif
                endif
                set i = i + 1
            endloop
            if ExpEventCandidate[pid] == 8 then
                return
            endif
            set i = 50
            set count = 0
            set ExpEventTargetPenalty[pid] = 0
            loop
                exitwhen i > 53
                if LoadInteger(ArcanaData, i, pid) < 5 then
                    set count = count + 1
                    if GetRandomInt(1, count) == 1 then
                        set ExpEventTargetPenalty[pid] = i
                    endif
                endif
                set i = i + 1
            endloop
        endif
    endfunction

    function ExpEventUnavailable takes integer pid, integer choice returns string
        local integer id = ExpEventCandidate[pid]
        local integer price = 0
        if id < 1 or id > 9 or choice < 1 or choice > 3 then
            return "사건이 없습니다."
        endif
        if ExpEventResolved[pid] then
            if choice == 3 then
                return ""
            endif
            return "이미 선택했습니다."
        endif
        if choice == 3 then
            return ""
        endif
        if id == 2 then
            set price = 100
            if choice == 2 then
                set price = 50
            elseif CardsLeft(pid, 1, 6) == 0 then
                return "미등장 일반 카드가 없습니다."
            endif
        elseif id == 3 and choice == 1 then
            if PlayerItem1[pid] == null then
                return "회복 물약이 없습니다."
            elseif GetItemCharges(PlayerItem1[pid]) < 1 then
                return "회복 물약 1회가 필요합니다."
            endif
        elseif id == 4 and choice == 1 then
            if ExpEventArcanaGain(pid) <= 0 or ExpEventTargetPenalty[pid] == 0 then
                return "받아들일 수 있는 각인 조합이 없습니다."
            elseif LoadInteger(ArcanaData, ExpEventTargetPenalty[pid], pid) >= 5 then
                return "감소 각인이 이미 최대입니다."
            endif
        elseif id == 5 then
            if ExpEventTargetCard[pid] == 0 or not ExpCardOwned[ExpKey(pid, ExpEventTargetCard[pid])] then
                return "반납할 일반 카드가 없습니다."
            elseif choice == 1 and CardsLeft(pid, 7, 10) == 0 then
                return "미등장 희귀 카드가 없습니다."
            endif
        elseif id == 6 and choice == 2 then
            set price = 100
        elseif id == 7 and choice == 1 then
            set price = 150
            if ExpEventTargetPenalty[pid] == 0 or ExpArcana[ExpKey(pid, ExpEventTargetPenalty[pid])] <= 0 then
                return "원정에서 얻은 감소 각인이 없습니다."
            endif
        elseif id == 8 and choice == 1 then
            set price = 150
            if ExpEventArcanaGain(pid) <= 0 then
                return "새길 수 있는 각인이 없습니다."
            endif
        elseif id == 9 and choice == 1 and CardsLeft(pid, 7, 10) < 2 then
            return "미등장 희귀 카드 2장이 필요합니다."
        endif
        if ExpGold[pid] < price then
            return I2S(price) + "골드가 필요합니다."
        endif
        return ""
    endfunction

    private function GrantEventPotion takes integer pid, integer kind, integer amount returns nothing
        local item target = PlayerItem1[pid]
        if kind == 2 then
            set target = PlayerItem2[pid]
        elseif kind == 3 then
            set target = PlayerItem3[pid]
        endif
        if target != null then
            if ExpHasCard(pid, 12) then
                set amount = amount + 1
            endif
            call SetItemCharges(target, GetItemCharges(target) + amount)
        endif
        set target = null
    endfunction

    private function ReleaseEvent takes integer pid returns nothing
        local integer eventId = ExpEventCandidate[pid]
        if eventId != 0 and ExpEventReservation[eventId] == pid + 1 then
            set ExpEventReservation[eventId] = 0
        endif
        set ExpEventCandidate[pid] = 0
    endfunction

    private function RollOffers takes integer pid returns nothing
        local integer grade = 1
        local integer roll
        local integer i = 0
        local integer first
        local integer last
        local integer count = 0
        call ReleaseEvent(pid)
        loop
            exitwhen i > ExpLuck[pid]
            set roll = ExpGradeFromRoll(GetRandomInt(1, 10000))
            set grade = IMaxBJ(grade, roll)
            set i = i + 1
        endloop
        set ExpEventGrade[pid] = grade
        set first = 1
        set last = 4
        if grade == 2 then
            set first = 5
            set last = 8
        elseif grade == 3 then
            set first = 9
            set last = 9
        elseif grade == 4 then
            set first = 10
            set last = 9
        endif
        loop
            exitwhen first > last
            if EventValid(pid, first) and not ExpEventUsed[first] and ExpEventReservation[first] == 0 then
                set count = count + 1
                if GetRandomInt(1, count) == 1 then
                    set ExpEventCandidate[pid] = first
                endif
            endif
            set first = first + 1
        endloop
        if ExpEventCandidate[pid] != 0 then
            set ExpEventReservation[ExpEventCandidate[pid]] = pid + 1
        endif
        set ExpArcanaA[pid] = GetRandomInt(0, 10)
        set ExpArcanaB[pid] = ModuloInteger(ExpArcanaA[pid] + GetRandomInt(1, 10), 11)
        set ExpArcanaLevel[pid] = 1
        if GetRandomInt(1, 100) > 75 then
            set ExpArcanaLevel[pid] = 2
        endif
        set ExpPenalty[pid] = GetRandomInt(50, 53)
        set ExpOfferVersion[pid] = ExpOfferVersion[pid] + 1
    endfunction

    private function CompleteEvent takes integer pid returns nothing
        call ReleaseEvent(pid)
        set ExpEventDeadline[pid] = 0
        set ExpDone[pid] = true
    endfunction

    private function ApplyEvent takes integer pid, integer choice returns nothing
        local integer id = ExpEventCandidate[pid]
        local integer card
        local integer second
        local integer amount
        local string result = ""
        if ExpEventUnavailable(pid, choice) != "" then
            return
        endif
        if choice == 3 then
            set ExpEventUsed[id] = true
            call CompleteEvent(pid)
            return
        endif
        if id == 1 then
            if choice == 1 then
                call GrantEventPotion(pid, 1, 1)
                set result = "약상자에서 쓸 만한 약을 찾았습니다.|n회복 물약 +1회 충전"
            else
                set ExpGold[pid] = ExpGold[pid] + 80
                set result = "흩어진 귀중품을 모아 짐에 넣었습니다.|n80골드 획득"
            endif
        elseif id == 2 then
            if choice == 1 then
                set card = DrawCard(pid, 1)
                set ExpGold[pid] = ExpGold[pid] - 100
                call GrantCard(pid, card, 1)
                set result = "밀봉 상자에서 전투 기록을 꺼냈습니다.|n100골드 지불|n획득  " + ExpCardName(card)
            else
                set ExpGold[pid] = ExpGold[pid] - 50
                call GrantEventPotion(pid, 2, 1)
                set result = "상인이 전투 물약 한 병을 건넸습니다.|n50골드 지불|n최종 대미지 물약 +1회 충전"
            endif
        elseif id == 3 then
            if choice == 1 then
                call SetItemCharges(PlayerItem1[pid], GetItemCharges(PlayerItem1[pid]) - 1)
                set ExpGold[pid] = ExpGold[pid] + 200
                set result = "약을 받은 상인이 보답으로 주머니를 내밀었습니다.|n회복 물약 1회 반납 · 200골드 획득"
            else
                set ExpGold[pid] = ExpGold[pid] + 60
                set result = "수레를 안전한 곳으로 옮겼습니다.|n60골드 획득"
            endif
        elseif id == 4 then
            if choice == 1 then
                set amount = ExpEventArcanaGain(pid)
                set ExpArcana[ExpKey(pid, ExpEventTargetArcana[pid])] = ExpArcana[ExpKey(pid, ExpEventTargetArcana[pid])] + amount
                set ExpArcana[ExpKey(pid, ExpEventTargetPenalty[pid])] = ExpArcana[ExpKey(pid, ExpEventTargetPenalty[pid])] + 1
                set result = "돌은 부서지고 힘과 저주가 몸에 남았습니다.|n" + ArcanaText[ExpEventTargetArcana[pid]] + " +" + I2S(amount) + "|n" + ArcanaText[ExpEventTargetPenalty[pid]] + " +1"
            else
                set ExpGold[pid] = ExpGold[pid] + 80
                set result = "힘을 건드리지 않고 파편만 팔았습니다.|n80골드 획득"
            endif
        elseif id == 5 then
            set card = ExpEventTargetCard[pid]
            set ExpCardOwned[ExpKey(pid, card)] = false
            if choice == 1 then
                set second = DrawCard(pid, 2)
                call GrantCard(pid, second, 2)
                set result = "수집가와 기록을 교환했습니다.|n반납  " + ExpCardName(card) + "|n획득  " + ExpCardName(second)
            else
                set ExpGold[pid] = ExpGold[pid] + 250
                set result = "기록을 판 대금을 받았습니다.|n반납  " + ExpCardName(card) + "|n250골드 획득"
            endif
        elseif id == 6 then
            if choice == 1 then
                set ExpGold[pid] = ExpGold[pid] + 100
                set result = "금고는 그대로 두고 주머니를 챙겼습니다.|n100골드 획득"
            else
                set ExpGold[pid] = ExpGold[pid] - 100
                if GetRandomInt(1, 100) <= 50 then
                    set ExpGold[pid] = ExpGold[pid] + 400
                    set result = "금고 안에는 금화가 가득했습니다.|n100골드 지불 · 400골드 획득"
                else
                    set result = "문은 열렸지만 금고는 비어 있었습니다.|n100골드 지불 · 획득 없음"
                endif
            endif
        elseif id == 7 then
            if choice == 1 then
                set ExpGold[pid] = ExpGold[pid] - 150
                set ExpArcana[ExpKey(pid, ExpEventTargetPenalty[pid])] = 0
                set result = "샘물이 원정에서 얻은 저주를 씻어 냈습니다.|n150골드 지불|n" + ArcanaText[ExpEventTargetPenalty[pid]] + "의 원정 획득분 제거"
            else
                call GrantEventPotion(pid, 1, 2)
                set result = "빈 병에 약수를 나누어 담았습니다.|n회복 물약 +2회 충전"
            endif
        elseif id == 8 then
            if choice == 1 then
                set ExpGold[pid] = ExpGold[pid] - 150
                set ExpArcana[ExpKey(pid, ExpEventTargetArcana[pid])] = ExpArcana[ExpKey(pid, ExpEventTargetArcana[pid])] + 1
                set result = "각인사가 흠집 없는 문양을 새겼습니다.|n150골드 지불|n" + ArcanaText[ExpEventTargetArcana[pid]] + " +1 · 감소 각인 없음"
            else
                set ExpGold[pid] = ExpGold[pid] + 100
                set result = "작업대를 정리하고 품삯을 받았습니다.|n100골드 획득"
            endif
        elseif id == 9 then
            if choice == 1 then
                set card = DrawCard(pid, 2)
                set second = DrawCard(pid, 2)
                call GrantCard(pid, card, 2)
                call GrantCard(pid, second, 2)
                set result = "온전한 기록 두 개를 챙겼습니다.|n" + ExpCardName(card) + "|n" + ExpCardName(second)
            else
                set ExpGold[pid] = ExpGold[pid] + 500
                call GrantEventPotion(pid, 1, 1)
                call GrantEventPotion(pid, 2, 1)
                call GrantEventPotion(pid, 3, 1)
                set result = "보급품을 나누어 짐에 실었습니다.|n500골드 획득 · 모든 물약 +1회 충전"
            endif
        endif
        if ExpHasCard(pid, 12) and ((id == 1 and choice == 1) or (id == 2 and choice == 2) or (id == 7 and choice == 2) or (id == 9 and choice == 2)) then
            set result = result + "|n바이바인으로 각 충전 종류 +1회 추가"
        endif
        set ExpEventUsed[id] = true
        set ExpEventResolved[pid] = true
        set ExpEventOutcome[pid] = result
        set ExpEventDeadline[pid] = Elapsed + 12
        set ExpOfferVersion[pid] = ExpOfferVersion[pid] + 1
        call RefreshStats(pid)
    endfunction

    private function ClaimMaterials takes integer pid returns nothing
        local integer count
        local integer slot
        local string itemData
        local string key = "영웅" + I2S(PlayerSlotNumber[pid]) + ".시험원정.보관재료"
        // 기존 인벤토리도 소유 클라이언트에서만 변경된다. 이 분기는 원정 상태를 바꾸지 않는다.
        if GetLocalPlayer() == Player(pid) and PLAYER_DATA_SERVER_READY[pid] then
            set count = S2I(StashLoad(PLAYER_DATA[pid], key, "0"))
            loop
                exitwhen count <= 0
                set slot = 50
                loop
                    exitwhen slot == 100
                    set itemData = StashLoad(PLAYER_DATA[pid], "영웅" + I2S(PlayerSlotNumber[pid]) + ".아이템" + I2S(slot), "0")
                    exitwhen itemData == null or itemData == "" or itemData == "0"
                    exitwhen GetItemIDs(itemData) == 0 or GetItemIDs(itemData) == 27
                    set slot = slot + 1
                endloop
                exitwhen slot == 100
                call additem(Player(pid), "ID27;")
                set count = count - 1
            endloop
            call StashSave(PLAYER_DATA[pid], key, I2S(count))
        endif
    endfunction

    private function ConfirmVictory takes integer pid, boolean clear returns nothing
        local string key = "영웅" + I2S(PlayerSlotNumber[pid]) + ".시험원정."
        set ExpConfirmedBattles[pid] = ExpConfirmedBattles[pid] + 1
        if PLAYER_DATA_SERVER_READY[pid] then
            if GetLocalPlayer() == Player(pid) then
                call StashSave(PLAYER_DATA[pid], key + "보관재료", I2S(S2I(StashLoad(PLAYER_DATA[pid], key + "보관재료", "0")) + 1))
                call StashSave(PLAYER_DATA[pid], key + "전투승리", I2S(S2I(StashLoad(PLAYER_DATA[pid], key + "전투승리", "0")) + 1))
                if clear then
                    call StashSave(PLAYER_DATA[pid], key + "완주", I2S(S2I(StashLoad(PLAYER_DATA[pid], key + "완주", "0")) + 1))
                endif
            endif
            call ClaimMaterials(pid)
            call RequestPlayerSave(pid)
        endif
    endfunction

    private function Finish takes boolean clear returns nothing
        local integer pid = 0
        call ExpCombatStop()
        set ExpState = EXP_RESULT
        set ExpRevision = ExpRevision + 1
        set ExpSeconds = 0
        loop
            exitwhen pid == 4
            if ExpMember[pid] then
                set ExpResultText[pid] = "원정 종료 · 전투 승리 " + I2S(ExpConfirmedBattles[pid]) + "회"
                if clear then
                    set ExpResultText[pid] = "원정 완주 · 전투 승리 " + I2S(ExpConfirmedBattles[pid]) + "회"
                endif
                call ReleaseEvent(pid)
                set ExpMember[pid] = false
                call PlayerStatsSet(pid)
                call ItemUIStatsSet(pid)
                if not UnitAlive(MainUnit[pid]) then
                    call ReviveHero(MainUnit[pid], GetRectCenterX(gg_rct_Home), GetRectCenterY(gg_rct_Home), false)
                endif
                call SetUnitPosition(MainUnit[pid], GetRectCenterX(gg_rct_Home), GetRectCenterY(gg_rct_Home))
                call SetUnitInvulnerable(MainUnit[pid], false)
                call PauseUnit(MainUnit[pid], false)
                call ShowPlayerPotionDisplay(pid)
                call RefreshHP(MainUnit[pid])
                if GetLocalPlayer() == Player(pid) then
                    call SetCameraBoundsToRectForPlayerBJ(Player(pid), gg_rct_Home)
                    call SetCameraPosition(GetRectCenterX(gg_rct_Home), GetRectCenterY(gg_rct_Home))
                endif
            endif
            set ExpReady[pid] = false
            set pid = pid + 1
        endloop
        if ExpArena != 0 then
            call MapReset(ExpArena, Mapthema[ExpArena])
            set ExpArena = 0
        endif
        call TriggerExecute(ExpRefresh)
    endfunction

    private function Enter takes integer state returns nothing
        local integer pid = 0
        local integer i = 0
        local integer j
        local integer swap
        local integer grade
        set ExpState = state
        set ExpRevision = ExpRevision + 1
        set Elapsed = 0
        set ExpSeconds = 60
        if state == EXP_VOTE then
            set ExpNode = 2
            set ExpEncounter = GetRandomInt(1, 3)
            set ExpSeconds = 40
        elseif state == EXP_SHOP then
            set ExpNode = 4
            set ExpSeconds = 120
            // RL-01은 이 상점 뒤의 대표 보스로 끝나므로 라이프 회복을 판매하지 않는다.
            set ExpLifeUseful = false
        elseif state == EXP_BATTLE then
            set ExpNode = 2
            if ExpStep == 4 then
                set ExpNode = 6
            endif
        endif
        loop
            exitwhen pid == 4
            set ExpDone[pid] = false
            set ExpEventDeadline[pid] = 0
            set ExpEventResolved[pid] = false
            set ExpEventOutcome[pid] = ""
            set ExpRolls[pid] = 0
            set ExpVote[pid] = 0
            set ExpOfferVersion[pid] = ExpOfferVersion[pid] + 1
            set Order[pid] = pid
            if ExpMember[pid] then
                call PauseUnit(MainUnit[pid], state != EXP_BATTLE)
            endif
            set pid = pid + 1
        endloop
        // 후보 예약 순서는 매 보상 화면마다 섞는다.
        set i = 3
        loop
            exitwhen i <= 0
            set j = GetRandomInt(0, i)
            set swap = Order[i]
            set Order[i] = Order[j]
            set Order[j] = swap
            set i = i - 1
        endloop
        set i = 0
        loop
            exitwhen i == 4
            set pid = Order[i]
            if ExpMember[pid] then
                if state == EXP_START then
                    set ExpStartTwoCards[pid] = GetRandomInt(1, 2) == 1
                    if not ExpStartTwoCards[pid] then
                        set ExpStartCard[pid] = DrawCard(pid, 1)
                    endif
                elseif state == EXP_REWARD then
                    call RollOffers(pid)
                elseif state == EXP_SHOP then
                    set j = 1
                    loop
                        exitwhen j > 3
                        set grade = 5
                        if j != 1 then
                            set swap = GetRandomInt(1, 100)
                            set grade = 1
                            if swap > 90 then
                                set grade = 3
                            elseif swap > 60 then
                                set grade = 2
                            endif
                        endif
                        set ExpShopCard[ExpKey(pid, j)] = DrawCard(pid, grade)
                        set ExpShopSold[ExpKey(pid, j)] = false
                        set ExpPotionBought[ExpKey(pid, j)] = 0
                        set j = j + 1
                    endloop
                    set ExpStatBought[pid] = false
                endif
            endif
            set i = i + 1
        endloop
        if state == EXP_BATTLE then
            call ExpCombatStart(ExpStep == 4)
        endif
        call TriggerExecute(ExpRefresh)
    endfunction

    private function QueueNext takes integer state returns nothing
        set NextState = state
        set ExpState = EXP_MOVE
        set ExpRevision = ExpRevision + 1
        set ExpSeconds = 6
        call TriggerExecute(ExpRefresh)
    endfunction

    private function BattleFinished takes nothing returns nothing
        local integer pid = 0
        if ExpState != EXP_BATTLE then
            return
        endif
        if not ExpWon then
            set ExpLife = IMaxBJ(0, ExpLife - ExpLoss(ExpNode, ExpProgress))
        endif
        loop
            exitwhen pid == 4
            if ExpMember[pid] then
                if ExpWon then
                    set ExpGold[pid] = ExpGold[pid] + 100
                    if ExpStep != 4 and ExpEncounter == 2 then
                        set ExpGold[pid] = ExpGold[pid] + 100
                    elseif ExpStep != 4 and ExpEncounter == 3 then
                        call GrantCard(pid, DrawCard(pid, 1), 1)
                        call RefreshStats(pid)
                    endif
                    call ConfirmVictory(pid, ExpStep == 4)
                endif
                if not UnitAlive(MainUnit[pid]) then
                    call ReviveHero(MainUnit[pid], GetRectCenterX(MapRectReturn(ExpArena)), GetRectCenterY(MapRectReturn(ExpArena)), false)
                endif
                call PauseUnit(MainUnit[pid], true)
            endif
            set pid = pid + 1
        endloop
        if ExpLife <= 0 or ExpStep == 4 then
            call Finish(ExpWon and ExpLife > 0)
        else
            call Enter(EXP_REWARD)
        endif
    endfunction

    private function TryStart takes nothing returns nothing
        local integer pid = 0
        local integer count = 0
        local integer i = 1
        local MapStruct arena
        loop
            exitwhen pid == 4
            if not ExpLeft[pid] and GetPlayerSlotState(Player(pid)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(pid)) == MAP_CONTROL_USER then
                if not ExpReady[pid] or not PickCheck[pid] or not UnitAlive(MainUnit[pid]) or not RectContainsUnit(gg_rct_Home, MainUnit[pid]) then
                    return
                endif
                set count = count + 1
            endif
            set pid = pid + 1
        endloop
        if count == 0 then
            return
        endif
        set ExpArena = 0
        loop
            exitwhen i > 4
            set arena = MapSt[i]
            if MapRectCheck[i] and arena.caster == null then
                set ExpArena = i
                exitwhen true
            endif
            set i = i + 1
        endloop
        if ExpArena == 0 then
            call DisplayTimedTextToForce(bj_FORCE_ALL_PLAYERS, 5, "빈 전투 구역이 없습니다. 훈련 전투 종료 후 다시 준비해 주세요.")
            return
        endif
        call MapResetAll(ExpArena)
        // 초기화로 숨겨진 전장 장식을 기존 기본 테마로 복구한다.
        call MapSet(ExpArena, 1)
        set MapRectCheck[ExpArena] = false
        set ExpRun = ExpRun + 1
        set ExpStep = 1
        set ExpNode = 1
        set ExpLife = 100
        set ExpPlayers = count
        set ExpLifeBought = false
        set pid = 0
        loop
            exitwhen pid == 4
            set ExpMember[pid] = not ExpLeft[pid] and GetPlayerSlotState(Player(pid)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(pid)) == MAP_CONTROL_USER
            set ExpGold[pid] = 0
            set ExpPoints[pid] = 5
            set ExpCritPoints[pid] = 0
            set ExpSwiftPoints[pid] = 0
            set ExpFixedCrit[pid] = 0
            set ExpFixedSwift[pid] = 0
            set ExpLuck[pid] = 0
            set ExpConfirmedBattles[pid] = 0
            set ExpStartCard[pid] = 0
            set ExpResultText[pid] = ""
            set i = 0
            loop
                exitwhen i == 64
                set ExpArcana[ExpKey(pid, i)] = 0
                set ExpCardSeen[ExpKey(pid, i)] = false
                set ExpCardOwned[ExpKey(pid, i)] = false
                set i = i + 1
            endloop
            if ExpMember[pid] then
                call ResetPlayerPotionCharges(pid)
                call SetItemCharges(PlayerItem1[pid], 2)
                call SetItemCharges(PlayerItem2[pid], 2)
                call SetItemCharges(PlayerItem3[pid], 2)
                call RefreshStats(pid)
                // 준비 이후에는 훈련 입구와 접촉하지 않도록 예약 구역으로 옮긴다.
                call SetUnitPosition(MainUnit[pid], GetRectCenterX(MapRectReturn(ExpArena)) - 450 + pid * 300, GetRectCenterY(MapRectReturn(ExpArena)) - 700)
                if GetLocalPlayer() == Player(pid) then
                    call SetCameraBoundsToRectForPlayerBJ(Player(pid), MapRectReturn(ExpArena))
                    call SetCameraPosition(GetRectCenterX(MapRectReturn(ExpArena)), GetRectCenterY(MapRectReturn(ExpArena)))
                endif
            endif
            set pid = pid + 1
        endloop
        set i = 1
        loop
            exitwhen i > 9
            set ExpEventUsed[i] = false
            set ExpEventReservation[i] = 0
            set i = i + 1
        endloop
        call Enter(EXP_START)
    endfunction

    function ExpShopPrice takes integer pid, integer base returns integer
        if ExpHasCard(pid, 11) then
            return (base * 85 + 99) / 100
        endif
        return base
    endfunction

    private function Buy takes integer pid, integer action returns nothing
        local integer key = ExpKey(pid, action)
        local integer card
        local integer price = 300
        local integer charges = 1
        local item potion = null
        if action <= 3 then
            set card = ExpShopCard[key]
            if card == 0 or ExpShopSold[key] then
                return
            endif
            set price = 250
            if ExpCardGrade(card) == 1 then
                set price = 150
            endif
        elseif action <= 5 then
            if ExpStatBought[pid] then
                return
            endif
        elseif action <= 8 then
            set key = ExpKey(pid, action - 5)
            if ExpPotionBought[key] >= 2 then
                return
            endif
            set price = 100
            if action == 6 then
                set price = 75
                set potion = PlayerItem1[pid]
            elseif action == 7 then
                set potion = PlayerItem2[pid]
            else
                set potion = PlayerItem3[pid]
            endif
        elseif action == 9 then
            if not ExpLifeUseful or ExpLifeBought or ExpLife > 90 then
                return
            endif
        elseif action == 10 then
            set ExpDone[pid] = true
            return
        else
            return
        endif
        set price = ExpShopPrice(pid, price)
        if ExpGold[pid] < price then
            set potion = null
            return
        endif
        set ExpGold[pid] = ExpGold[pid] - price
        if action <= 3 then
            set ExpShopSold[key] = true
            call GrantCard(pid, card, ExpCardGrade(card))
        elseif action <= 5 then
            set ExpStatBought[pid] = true
            if action == 4 then
                set ExpFixedCrit[pid] = ExpFixedCrit[pid] + 100
            else
                set ExpFixedSwift[pid] = ExpFixedSwift[pid] + 100
            endif
        elseif action <= 8 then
            set ExpPotionBought[key] = ExpPotionBought[key] + 1
            if ExpHasCard(pid, 12) then
                set charges = charges + 1
            endif
            call SetItemCharges(potion, GetItemCharges(potion) + charges)
        else
            set ExpLifeBought = true
            set ExpLife = ExpLife + 10
        endif
        call RefreshStats(pid)
        set potion = null
    endfunction

    function ExpCanAllocate takes integer pid returns boolean
        return ExpMember[pid] and not ExpLeft[pid] and (ExpState == EXP_START or ExpState == EXP_VOTE or ExpState == EXP_REWARD or ExpState == EXP_SHOP or ExpState == EXP_MOVE)
    endfunction

    function ExpAction takes integer pid, integer action returns nothing
        local integer kind
        if pid < 0 or pid > 3 or ExpLeft[pid] or not PickCheck[pid] then
            return
        endif
        if ExpState == EXP_LOBBY or ExpState == EXP_RESULT then
            if action == 1 then
                if not ExpReady[pid] and (not UnitAlive(MainUnit[pid]) or not RectContainsUnit(gg_rct_Home, MainUnit[pid])) then
                    call DisplayTimedTextToPlayer(Player(pid), 0, 0, 5, "마을에서 준비할 수 있습니다. 현재 전투를 마친 뒤 다시 눌러 주세요.")
                    return
                endif
                set ExpReady[pid] = not ExpReady[pid]
                call TryStart()
            elseif action == 2 then
                call ClaimMaterials(pid)
                call RequestPlayerSave(pid)
            endif
        elseif not ExpMember[pid] then
            return
        elseif action >= 101 and action <= 103 and ExpCanAllocate(pid) then
            if action == 103 then
                set ExpCritPoints[pid] = 0
                set ExpSwiftPoints[pid] = 0
            elseif ExpCritPoints[pid] + ExpSwiftPoints[pid] < ExpPoints[pid] then
                if action == 101 and ExpCritPoints[pid] < 30 then
                    set ExpCritPoints[pid] = ExpCritPoints[pid] + 1
                elseif action == 102 and ExpSwiftPoints[pid] < 30 then
                    set ExpSwiftPoints[pid] = ExpSwiftPoints[pid] + 1
                endif
            endif
            call RefreshStats(pid)
        elseif ExpDone[pid] then
            return
        elseif ExpState == EXP_START and action >= 1 and action <= 6 then
            if action == 1 then
                call GrantPoints(pid, 10)
            elseif action == 2 then
                if GetRandomInt(1, 2) == 1 then
                    set ExpFixedCrit[pid] = ExpFixedCrit[pid] + 200
                else
                    set ExpFixedSwift[pid] = ExpFixedSwift[pid] + 200
                endif
            elseif action == 3 then
                set kind = ExpKey(pid, GetRandomInt(0, 10))
                set ExpArcana[kind] = ExpArcana[kind] + 2
            elseif action == 4 then
                if ExpStartTwoCards[pid] then
                    call GrantCard(pid, DrawCard(pid, 1), 1)
                    call GrantCard(pid, DrawCard(pid, 1), 1)
                else
                    call GrantCard(pid, ExpStartCard[pid], 1)
                endif
            elseif action == 5 then
                call GrantCard(pid, DrawCard(pid, 2), 2)
            else
                set ExpGold[pid] = ExpGold[pid] + 200
            endif
            set ExpDone[pid] = true
            call RefreshStats(pid)
        elseif ExpState == EXP_VOTE and (action == 1 or action == 2) then
            set ExpVote[pid] = action
            set ExpDone[pid] = true
        elseif ExpState == EXP_REWARD then
            if ExpEventDeadline[pid] > 0 then
                if action >= 1 and action <= 3 then
                    call ApplyEvent(pid, action)
                endif
            elseif action == 100 then
                set kind = 100 * (ExpRolls[pid] + 1)
                if ExpGold[pid] >= kind then
                    set ExpGold[pid] = ExpGold[pid] - kind
                    set ExpRolls[pid] = ExpRolls[pid] + 1
                    call RollOffers(pid)
                endif
            elseif action >= 1 and action <= 3 then
                if action == 1 then
                    call GrantPoints(pid, 5)
                elseif action == 2 then
                    set kind = ExpKey(pid, ExpArcanaA[pid])
                    set ExpArcana[kind] = ExpArcana[kind] + ExpArcanaLevel[pid]
                    set kind = ExpKey(pid, ExpArcanaB[pid])
                    set ExpArcana[kind] = ExpArcana[kind] + 1
                    set kind = ExpKey(pid, ExpPenalty[pid])
                    set ExpArcana[kind] = ExpArcana[kind] + ExpArcanaLevel[pid]
                elseif ExpEventCandidate[pid] == 0 then
                    set ExpGold[pid] = ExpGold[pid] + ExpGradeGold(ExpEventGrade[pid])
                else
                    set ExpEventUsed[ExpEventCandidate[pid]] = true
                    call PrepareEvent(pid)
                    set ExpEventDeadline[pid] = Elapsed + 40
                    set ExpOfferVersion[pid] = ExpOfferVersion[pid] + 1
                    call TriggerExecute(ExpRefresh)
                    return
                endif
                call ReleaseEvent(pid)
                set ExpDone[pid] = true
                call RefreshStats(pid)
            endif
        elseif ExpState == EXP_SHOP and action >= 1 and action <= 10 then
            call Buy(pid, action)
        endif
        call TriggerExecute(ExpRefresh)
    endfunction

    private function OnSync takes nothing returns nothing
        local integer pid = GetPlayerId(DzGetTriggerSyncPlayer())
        local string data = DzGetTriggerSyncData()
        if pid >= 0 and pid < 4 and S2I(JNStringSplit(data, "|", 0)) == ExpRun and S2I(JNStringSplit(data, "|", 1)) == ExpRevision and S2I(JNStringSplit(data, "|", 2)) == ExpOfferVersion[pid] then
            call ExpAction(pid, S2I(JNStringSplit(data, "|", 3)))
        endif
    endfunction

    private function Tick takes nothing returns nothing
        local integer pid = 0
        local boolean allDone = true
        local integer fight = 0
        local integer avoid = 0
        if ExpState == EXP_LOBBY or ExpState == EXP_RESULT then
            call TriggerExecute(ExpRefresh)
            return
        endif
        set ExpSeconds = IMaxBJ(0, ExpSeconds - 1)
        set Elapsed = Elapsed + 1
        if ExpState == EXP_MOVE then
            if ExpSeconds == 0 then
                call Enter(NextState)
            endif
        elseif ExpState != EXP_BATTLE then
            loop
                exitwhen pid == 4
                if ExpMember[pid] then
                    if not ExpDone[pid] then
                        if ExpState == EXP_REWARD and ExpEventDeadline[pid] > 0 then
                            if Elapsed >= ExpEventDeadline[pid] then
                                call ApplyEvent(pid, 3)
                            endif
                        elseif ExpSeconds == 0 then
                            if ExpState == EXP_SHOP then
                                call ExpAction(pid, 10)
                            elseif ExpState == EXP_VOTE then
                                call ExpAction(pid, 2)
                            else
                                // 시간 초과는 스탯 기본 선택. 비용과 패널티를 강제하지 않는다.
                                call ExpAction(pid, 1)
                            endif
                        endif
                    endif
                    if not ExpDone[pid] then
                        set allDone = false
                    endif
                    if ExpVote[pid] == 1 then
                        set fight = fight + 1
                    elseif ExpVote[pid] == 2 then
                        set avoid = avoid + 1
                    endif
                endif
                set pid = pid + 1
            endloop
            if allDone then
                if ExpState == EXP_START then
                    set ExpStep = 2
                    call QueueNext(EXP_VOTE)
                elseif ExpState == EXP_VOTE then
                    if fight > avoid then
                        call QueueNext(EXP_BATTLE)
                    else
                        set pid = 0
                        loop
                            exitwhen pid == 4
                            if ExpMember[pid] then
                                if ExpEncounter == 1 then
                                    call GrantEventPotion(pid, GetRandomInt(1, 3), 1)
                                elseif ExpEncounter == 2 then
                                    set ExpGold[pid] = ExpGold[pid] + 50
                                else
                                    set ExpGold[pid] = ExpGold[pid] + 60
                                endif
                            endif
                            set pid = pid + 1
                        endloop
                        call QueueNext(EXP_REWARD)
                    endif
                elseif ExpState == EXP_REWARD then
                    set ExpStep = 3
                    call QueueNext(EXP_SHOP)
                elseif ExpState == EXP_SHOP then
                    set ExpStep = 4
                    call QueueNext(EXP_BATTLE)
                endif
            endif
        endif
        call TriggerExecute(ExpRefresh)
    endfunction

    private function Leave takes nothing returns nothing
        local integer pid = GetPlayerId(GetTriggerPlayer())
        set ExpLeft[pid] = true
        set ExpReady[pid] = false
        if ExpMember[pid] then
            call ReleaseEvent(pid)
            set ExpMember[pid] = false
            set ExpPlayers = ExpPlayers - 1
            call PauseUnit(MainUnit[pid], true)
            call ShowUnit(MainUnit[pid], false)
            if ExpPlayers == 0 then
                call Finish(false)
            endif
        elseif ExpState == EXP_LOBBY or ExpState == EXP_RESULT then
            call TryStart()
        endif
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer pid = 0
        call DzTriggerRegisterSyncData(t, "ExpCmd", false)
        call TriggerAddAction(t, function OnSync)
        set t = CreateTrigger()
        loop
            exitwhen pid == 4
            call TriggerRegisterPlayerEvent(t, Player(pid), EVENT_PLAYER_LEAVE)
            set pid = pid + 1
        endloop
        call TriggerAddAction(t, function Leave)
        call TriggerAddAction(ExpBattleFinished, function BattleFinished)
        call TimerStart(Clock, 1.0, true, function Tick)
        set t = null
    endfunction
endlibrary
