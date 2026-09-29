// 개인 사냥, 행동력 사건, 카드 각성과 준비 완료 후 보스 합류를 진행한다.
library ExpeditionPrototype initializer Init requires Expedition, DataPrototype, DataMap, StatsSet, PlayerSave
    globals
        private timer HuntClock = CreateTimer()
        private real HuntFraction = 0.0
        private integer array HuntSeconds
        private real array DeathSeconds
        private unit array HuntUnits
        private real array AttackClock
        private boolean array AttackWarning
        private boolean array ReservedRegion
    endglobals

    function ProtoRefreshStats takes integer pid returns nothing
        local real ratio = GetUnitState(MainUnit[pid], UNIT_STATE_LIFE) / GetUnitState(MainUnit[pid], UNIT_STATE_MAX_LIFE)
        call PlayerStatsSet(pid)
        call ItemUIStatsSet(pid)
        call SetUnitState(MainUnit[pid], UNIT_STATE_LIFE, GetUnitState(MainUnit[pid], UNIT_STATE_MAX_LIFE) * ratio)
        call RefreshHP(MainUnit[pid])
    endfunction

    function ProtoCanDepart takes integer pid returns boolean
        // 기존 첫 계승(ID10 → ID3)이 공격력 1인 T1을 공격력 100인 T2로 바꾼다.
        return PickCheck[pid] and ProtoCodexSlot[pid] == PlayerSlotNumber[pid] and PlayerSlotNumber[pid] > 0 and GetItemTier(Eitem[pid][EQUIP_SLOT_WEAPON]) >= 2 and AttackPower(pid) >= 100.0 and UnitAlive(MainUnit[pid]) and RectContainsUnit(gg_rct_Home, MainUnit[pid])
    endfunction

    private function ProtoRememberHead takes integer pid, integer head returns nothing
        if not ProtoHeadKnown[ExpKey(pid, head)] then
            set ProtoHeadKnown[ExpKey(pid, head)] = true
            if GetLocalPlayer() == Player(pid) then
                call StashSave(PLAYER_DATA[pid], "원정.머리도감." + I2S(head), "1")
            endif
            call RequestPlayerSave(pid)
        endif
    endfunction

    private function ProtoRememberCard takes integer pid, integer card returns nothing
        if GetLocalPlayer() == Player(pid) then
            call StashSave(PLAYER_DATA[pid], "원정.카드도감." + I2S(card), "1")
        endif
        call RequestPlayerSave(pid)
    endfunction

    function ProtoGrantHead takes integer pid, integer head returns nothing
        if head < 1 or head > 3 or ProtoHeadCount[pid] >= 3 or ProtoHeadOwned[ExpKey(pid, head)] then
            return
        endif
        set ProtoHeadOwned[ExpKey(pid, head)] = true
        set ProtoHeadCount[pid] = ProtoHeadCount[pid] + 1
        // 머리 효과는 작게 두고 관련 풀을 여는 역할에 집중한다.
        set ProtoDamageBonus[pid] = ProtoDamageBonus[pid] + 5.0
        call ProtoRememberHead(pid, head)
    endfunction

    function ProtoDrawCard takes integer pid, integer head returns integer
        local integer id = PROTO_CARD_FIRST
        local integer weight
        local integer total = 0
        local integer selected = 0
        loop
            exitwhen id > PROTO_CARD_LAST
            if not ExpCardOwned[ExpKey(pid, id)] and (ProtoCardHead[id] == 0 or (ProtoHeadOwned[ExpKey(pid, ProtoCardHead[id])] and (head == 0 or head == ProtoCardHead[id]))) then
                set weight = 60
                if ProtoCardGrade[id] == 2 then
                    set weight = 30
                elseif ProtoCardGrade[id] == 3 then
                    set weight = 9
                elseif ProtoCardGrade[id] == 4 then
                    set weight = 1
                endif
                set total = total + weight
                if GetRandomInt(1, total) <= weight then
                    set selected = id
                endif
            endif
            set id = id + 1
        endloop
        return selected
    endfunction

    function ProtoGrantCard takes integer pid, integer card returns nothing
        if card == 0 then
            set ExpGold[pid] = ExpGold[pid] + 100
            set ProtoOutcome[pid] = ProtoOutcome[pid] + "|n획득 가능한 카드가 없어 골드 +100."
            return
        endif
        if ExpCardOwned[ExpKey(pid, card)] then
            return
        endif
        set ExpCardOwned[ExpKey(pid, card)] = true
        set ProtoCardProgress[ExpKey(pid, card)] = 0.0
        set ProtoEvolved[ExpKey(pid, card)] = false
        if ProtoCardKind[card] == 3 then
            set ProtoGoldBonus[pid] = ProtoGoldBonus[pid] + R2I(ProtoCardValue[card])
        elseif ProtoCardKind[card] == 5 then
            set ExpFixedSwift[pid] = ExpFixedSwift[pid] + R2I(ProtoCardValue[card])
        elseif ProtoCardKind[card] == 6 then
            set ProtoChoices[pid] = IMinBJ(4, ProtoChoices[pid] + 1)
        endif
        set ProtoOutcome[pid] = ProtoOutcome[pid] + "|n[" + ExpEventGradeName(ProtoCardGrade[card]) + "] " + ProtoCardName[card] + "|n" + ProtoCardText(pid, card)
        call ProtoRememberCard(pid, card)
        call ProtoRefreshStats(pid)
    endfunction

    function ProtoEventEligible takes integer pid, integer id returns boolean
        local integer head = ProtoEventHead[id]
        if id <= 0 or id > PROTO_EVENT_COUNT or ProtoEventUsed[id] then
            return false
        endif
        if ProtoEventKind[id] == 0 then
            return ProtoHeadCount[pid] < 3 and not ProtoHeadOwned[ExpKey(pid, head)]
        endif
        return head == 0 or ProtoHeadOwned[ExpKey(pid, head)]
    endfunction

    function ProtoSetPause takes integer pid, boolean paused returns nothing
        local integer slot = 1
        local integer key
        set ProtoPaused[pid] = paused
        call PauseUnit(MainUnit[pid], paused or ProtoReady[pid])
        call SetUnitInvulnerable(MainUnit[pid], paused or ProtoReady[pid])
        loop
            exitwhen slot > 10
            set key = pid * 16 + slot
            if HuntUnits[key] != null then
                call PauseUnit(HuntUnits[key], paused or ProtoReady[pid])
            endif
            set slot = slot + 1
        endloop
    endfunction

    function ProtoOffer takes integer pid returns nothing
        local integer slot = 1
        local integer id
        local integer j
        local integer total
        local integer selected
        local integer weight
        local boolean duplicate
        if ProtoAP[pid] <= 0 or ProtoReady[pid] then
            return
        endif
        loop
            exitwhen slot > 4
            set ProtoCandidates[ExpKey(pid, slot)] = 0
            if slot <= ProtoChoices[pid] then
                set id = 1
                set total = 0
                set selected = 0
                loop
                    exitwhen id > PROTO_EVENT_COUNT
                    set duplicate = false
                    set j = 1
                    loop
                        exitwhen j >= slot
                        if ProtoCandidates[ExpKey(pid, j)] == id then
                            set duplicate = true
                        endif
                        set j = j + 1
                    endloop
                    if not duplicate and ProtoEventEligible(pid, id) then
                        set weight = 1
                        if ProtoEventKind[id] == 0 then
                            set weight = 20
                        elseif ProtoEventHead[id] > 0 then
                            set weight = 3
                        endif
                        set total = total + weight
                        if GetRandomInt(1, total) <= weight then
                            set selected = id
                        endif
                    endif
                    set id = id + 1
                endloop
                set ProtoCandidates[ExpKey(pid, slot)] = selected
            endif
            set slot = slot + 1
        endloop
        if ProtoCandidates[ExpKey(pid, 1)] == 0 then
            // 당장 유효한 사건이 없어도 행동력을 강제로 소비하지 않는다.
            set ProtoStage[pid] = 0
            set ProtoSelected[pid] = 0
            set ProtoDeadline[pid] = 0
            set ProtoOutcome[pid] = ""
            set ProtoLastEvent[pid] = HuntSeconds[pid]
            call ProtoSetPause(pid, false)
            return
        endif
        set ProtoStage[pid] = 1
        set ProtoDeadline[pid] = 45
        set ProtoSelected[pid] = 0
        set ExpOfferVersion[pid] = ExpOfferVersion[pid] + 1
        call ProtoSetPause(pid, true)
    endfunction

    function ProtoBranchText takes integer pid, integer choice returns string
        local integer kind = ProtoEventKind[ProtoSelected[pid]]
        if kind == 0 then
            if choice == 1 then
                return "지역 조사 · 머리 카드 획득, 관련 풀 개방"
            endif
            return "출발을 미룬다 · 골드 +100"
        elseif kind == 1 or kind == 5 then
            if choice == 1 then
                return "힘의 단서를 택한다 · 무작위 카드 1장"
            endif
            return "자원을 챙긴다 · 골드 +150"
        elseif kind == 2 then
            if choice == 1 then
                return "무리를 유인한다 · 적 수 +2, 카드 1장"
            endif
            return "길을 정리한다 · 적 수 -1, 골드 +100"
        elseif kind == 3 then
            if choice == 1 then
                return "강적을 부른다 · 적 단계 +1, 골드 +250"
            endif
            return "안전하게 사냥한다 · 적 단계 -1"
        elseif kind == 4 then
            if choice == 1 then
                return "판돈 200골드 · 주사위 4~6이면 카드 2장, 1~3이면 손실"
            endif
            return "작은 보상을 받는다 · 골드 +80"
        elseif kind == 6 then
            if choice == 1 then
                return "위험한 힘을 받는다 · 피해 +15%, 적 단계 +1"
            endif
            return "상처를 돌본다 · 생명력 100% 회복"
        elseif kind == 7 then
            if choice == 1 then
                return "300골드로 거래한다 · 무작위 카드 2장"
            endif
            return "거래 대신 수고비 · 골드 +100"
        endif
        if choice == 1 then
            return "보급품을 챙긴다 · 생명력 물약 +2"
        endif
        return "물자를 넘긴다 · 골드 +150"
    endfunction

    function ProtoBranchAllowed takes integer pid, integer choice returns boolean
        local integer kind = ProtoEventKind[ProtoSelected[pid]]
        if choice == 1 and kind == 2 then
            return ProtoDensity[pid] <= 8
        elseif choice == 1 and (kind == 3 or kind == 6) then
            return ProtoLevel[pid] < 5
        elseif choice == 1 and kind == 4 then
            return ExpGold[pid] >= 200
        elseif choice == 1 and kind == 7 then
            return ExpGold[pid] >= 300
        endif
        return choice == 1 or choice == 2
    endfunction

    function ProtoRemoveEnemy takes integer key returns nothing
        local integer index
        if HuntUnits[key] != null then
            set index = IndexUnit(HuntUnits[key])
            set ProtoHuntOwner[index] = 0
            set ExpEnemy[index] = false
            call KillUnit(HuntUnits[key])
            call RemoveUnit(HuntUnits[key])
            set HuntUnits[key] = null
        endif
        set AttackClock[key] = 0.0
        set AttackWarning[key] = false
    endfunction

    function ProtoApplyField takes integer pid returns nothing
        local integer slot = 1
        local integer key
        local integer index
        local real ratio
        loop
            exitwhen slot > 10
            set key = pid * 16 + slot
            if HuntUnits[key] != null then
                if slot > ProtoDensity[pid] then
                    call ProtoRemoveEnemy(key)
                else
                    set index = IndexUnit(HuntUnits[key])
                    set ratio = UnitHP[index] / UnitHPMAX[index]
                    set UnitHPMAX[index] = 300.0 * (1.0 + 0.30 * (ProtoLevel[pid] - 1))
                    set UnitHP[index] = UnitHPMAX[index] * ratio
                endif
            endif
            set slot = slot + 1
        endloop
    endfunction

    function ProtoResolve takes integer pid, integer choice returns nothing
        local integer id = ProtoSelected[pid]
        local integer kind = ProtoEventKind[id]
        local integer roll
        if ProtoStage[pid] != 2 or not ProtoBranchAllowed(pid, choice) then
            return
        endif
        set ProtoOutcome[pid] = ProtoEventName[id] + "|n" + ProtoBranchText(pid, choice)
        if kind == 0 then
            if choice == 1 then
                call ProtoGrantHead(pid, ProtoEventHead[id])
            else
                set ExpGold[pid] = ExpGold[pid] + 100
            endif
        elseif kind == 1 or kind == 5 then
            if choice == 1 then
                call ProtoGrantCard(pid, ProtoDrawCard(pid, ProtoEventHead[id]))
            else
                set ExpGold[pid] = ExpGold[pid] + 150
            endif
        elseif kind == 2 then
            if choice == 1 then
                set ProtoDensity[pid] = IMinBJ(10, ProtoDensity[pid] + 2)
                call ProtoGrantCard(pid, ProtoDrawCard(pid, ProtoEventHead[id]))
            else
                set ProtoDensity[pid] = IMaxBJ(1, ProtoDensity[pid] - 1)
                set ExpGold[pid] = ExpGold[pid] + 100
            endif
        elseif kind == 3 then
            if choice == 1 then
                set ProtoLevel[pid] = IMinBJ(5, ProtoLevel[pid] + 1)
                set ExpGold[pid] = ExpGold[pid] + 250
            else
                set ProtoLevel[pid] = IMaxBJ(1, ProtoLevel[pid] - 1)
            endif
        elseif kind == 4 then
            if choice == 1 then
                set ExpGold[pid] = ExpGold[pid] - 200
                set roll = GetRandomInt(1, 6)
                set ProtoOutcome[pid] = ProtoOutcome[pid] + "|n주사위 " + I2S(roll)
                if roll >= 4 then
                    call ProtoGrantCard(pid, ProtoDrawCard(pid, ProtoEventHead[id]))
                    call ProtoGrantCard(pid, ProtoDrawCard(pid, ProtoEventHead[id]))
                endif
            else
                set ExpGold[pid] = ExpGold[pid] + 80
            endif
        elseif kind == 6 then
            if choice == 1 then
                set ProtoLevel[pid] = IMinBJ(5, ProtoLevel[pid] + 1)
                set ProtoDamageBonus[pid] = ProtoDamageBonus[pid] + 15.0
            else
                call SetUnitState(MainUnit[pid], UNIT_STATE_LIFE, GetUnitState(MainUnit[pid], UNIT_STATE_MAX_LIFE))
                call RefreshHP(MainUnit[pid])
            endif
        elseif kind == 7 then
            if choice == 1 then
                set ExpGold[pid] = ExpGold[pid] - 300
                call ProtoGrantCard(pid, ProtoDrawCard(pid, ProtoEventHead[id]))
                call ProtoGrantCard(pid, ProtoDrawCard(pid, ProtoEventHead[id]))
            else
                set ExpGold[pid] = ExpGold[pid] + 100
            endif
        elseif choice == 1 then
            call SetItemCharges(PlayerItem1[pid], GetItemCharges(PlayerItem1[pid]) + 2)
            call ShowPlayerPotionDisplay(pid)
        else
            set ExpGold[pid] = ExpGold[pid] + 150
        endif
        call ProtoApplyField(pid)
        set ProtoStage[pid] = 3
        set ProtoDeadline[pid] = 8
        set ExpOfferVersion[pid] = ExpOfferVersion[pid] + 1
    endfunction


    function ProtoResume takes integer pid returns nothing
        set ProtoStage[pid] = 0
        set ProtoLastEvent[pid] = HuntSeconds[pid]
        set ProtoOfferKills[pid] = ProtoKills[pid]
        set ProtoRerolls[pid] = 0
        set ExpOfferVersion[pid] = ExpOfferVersion[pid] + 1
        call ProtoSetPause(pid, false)
    endfunction


    function ProtoCleanup takes nothing returns nothing
        local integer key = 1
        local integer area = 1
        loop
            exitwhen key > 64
            call ProtoRemoveEnemy(key)
            set key = key + 1
        endloop
        loop
            exitwhen area > 6
            if ReservedRegion[area] then
                call MapReset(area, Mapthema[area])
                set ReservedRegion[area] = false
            endif
            set area = area + 1
        endloop
        set area = 0
        loop
            exitwhen area == 4
            set ProtoPaused[area] = false
            set ProtoReady[area] = false
            set ProtoStage[area] = 0
            set area = area + 1
        endloop
        set ExpPrototypeActive = false
    endfunction

    function ProtoJoinBoss takes nothing returns nothing
        local integer key = 1
        local integer pid = 0
        loop
            exitwhen key > 64
            call ProtoRemoveEnemy(key)
            set key = key + 1
        endloop
        loop
            exitwhen pid == 4
            if ExpMember[pid] then
                // 제한 시간이 끝나도 행동력을 지불한 사건은 안전한 선택으로 마무리한다.
                if ProtoStage[pid] == 2 then
                    call ProtoResolve(pid, 2)
                endif
                set ProtoStage[pid] = 0
                set ProtoReady[pid] = false
                call ProtoSetPause(pid, false)
            endif
            set pid = pid + 1
        endloop
        set ExpState = EXP_BATTLE
        set HuntFraction = 0.0
        set ExpStep = 4
        set ExpNode = 2
        set ExpRevision = ExpRevision + 1
        call ExpCombatStart(true)
    endfunction

    function ProtoTryStart takes nothing returns nothing
        local integer pid = 0
        local integer area
        local integer count = 0
        local integer id
        local MapStruct arena
        loop
            exitwhen pid == 4
            if not ExpLeft[pid] and GetPlayerSlotState(Player(pid)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(pid)) == MAP_CONTROL_USER then
                if not ExpReady[pid] or not ProtoCanDepart(pid) then
                    return
                endif
                set arena = MapSt[pid + 1]
                if MapRectReturn(pid + 1) == null or not MapRectCheck[pid + 1] or arena.caster != null then
                    call DisplayTimedTextToPlayer(Player(pid), 0, 0, 5, "개인 사냥 구역이 사용 중입니다. 훈련을 종료해 주세요.")
                    return
                endif
                set count = count + 1
            endif
            set pid = pid + 1
        endloop
        if count == 0 then
            return
        endif
        set area = 5
        loop
            exitwhen area > 6
            set arena = MapSt[area]
            exitwhen MapRectReturn(area) != null and MapRectCheck[area] and arena.caster == null
            set area = area + 1
        endloop
        if area > 6 then
            call DisplayTimedTextToForce(bj_FORCE_ALL_PLAYERS, 5, "사용 가능한 보스 구역이 없습니다.")
            return
        endif
        set ExpArena = area
        call MapSet(area, 1)
        set MapRectCheck[area] = false
        set ReservedRegion[area] = true
        set ExpPrototypeActive = true
        set ExpRun = ExpRun + 1
        set ExpRevision = ExpRevision + 1
        set ExpState = EXP_HUNT
        set ExpSeconds = 600
        set ExpPlayers = count
        set ExpLife = 100
        set ExpStep = 1
        set ExpNode = 1
        set HuntFraction = 0.0
        set id = 1
        loop
            exitwhen id > PROTO_EVENT_COUNT
            set ProtoEventUsed[id] = false
            set id = id + 1
        endloop
        set pid = 0
        loop
            exitwhen pid == 4
            set ExpMember[pid] = not ExpLeft[pid] and GetPlayerSlotState(Player(pid)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(pid)) == MAP_CONTROL_USER
            set ExpReady[pid] = false
            set ExpDone[pid] = false
            set ExpPoints[pid] = 0
            set ExpCritPoints[pid] = 0
            set ExpSwiftPoints[pid] = 0
            set ExpFixedCrit[pid] = 0
            set ExpFixedSwift[pid] = 0
            set ExpLuck[pid] = 0
            set ExpGold[pid] = 0
            set ExpConfirmedBattles[pid] = 0
            set ExpResultText[pid] = ""
            set ExpEventDeadline[pid] = 0
            set ProtoAP[pid] = 10
            set ProtoStage[pid] = 0
            set ProtoSelected[pid] = 0
            set ProtoDeadline[pid] = 0
            set ProtoOutcome[pid] = ""
            set ProtoHeadCount[pid] = 0
            set ProtoChoices[pid] = 2
            set ProtoLevel[pid] = 1
            set ProtoDensity[pid] = 4
            set ProtoKills[pid] = 0
            set ProtoDamage[pid] = 0.0
            set ProtoDamageBonus[pid] = 0.0
            set ProtoGoldBonus[pid] = 0
            set ProtoSafeTime[pid] = 0.0
            set ProtoLastEvent[pid] = 0
            set ProtoLastKill[pid] = 0
            set ProtoOfferKills[pid] = 0
            set ProtoRerolls[pid] = 0
            set ProtoPaused[pid] = false
            set ProtoReady[pid] = false
            set HuntSeconds[pid] = 0
            set DeathSeconds[pid] = 0.0
            set id = 0
            loop
                exitwhen id == 64
                set ExpArcana[ExpKey(pid, id)] = 0
                set ExpCardOwned[ExpKey(pid, id)] = false
                set ExpCardSeen[ExpKey(pid, id)] = false
                set ExpCardReserved[ExpKey(pid, id)] = false
                set ProtoCardProgress[ExpKey(pid, id)] = 0.0
                set ProtoEvolved[ExpKey(pid, id)] = false
                set ProtoHeadOwned[ExpKey(pid, id)] = false
                set ProtoCandidates[ExpKey(pid, id)] = 0
                set id = id + 1
            endloop
            if ExpMember[pid] then
                call MapSet(pid + 1, 1)
                set MapRectCheck[pid + 1] = false
                set ReservedRegion[pid + 1] = true
                if ProtoStartHead[pid] > 0 and ProtoHeadKnown[ExpKey(pid, ProtoStartHead[pid])] then
                    call ProtoGrantHead(pid, ProtoStartHead[pid])
                endif
                call ResetPlayerPotionCharges(pid)
                call SetItemCharges(PlayerItem1[pid], 2)
                call SetItemCharges(PlayerItem2[pid], 2)
                call SetItemCharges(PlayerItem3[pid], 2)
                call ProtoRefreshStats(pid)
                call SetUnitState(MainUnit[pid], UNIT_STATE_LIFE, GetUnitState(MainUnit[pid], UNIT_STATE_MAX_LIFE))
                call RefreshHP(MainUnit[pid])
                call SetUnitPosition(MainUnit[pid], GetRectCenterX(MapRectReturn(pid + 1)), GetRectCenterY(MapRectReturn(pid + 1)))
                if GetLocalPlayer() == Player(pid) then
                    call SetCameraBoundsToRectForPlayerBJ(Player(pid), MapRectReturn(pid + 1))
                    call SetCameraPosition(GetRectCenterX(MapRectReturn(pid + 1)), GetRectCenterY(MapRectReturn(pid + 1)))
                endif
            endif
            set pid = pid + 1
        endloop
        call TriggerExecute(ExpRefresh)
    endfunction

    function ProtoAction takes integer pid, integer action returns nothing
        local integer slot
        local integer id
        local integer price
        local integer other
        if ExpState == EXP_LOBBY or ExpState == EXP_RESULT then
            if action == 2002 then
                call ProtoTryStart()
            elseif action >= 2010 and action <= 2013 and not ExpReady[pid] then
                set id = action - 2010
                if id == 0 or ProtoHeadKnown[ExpKey(pid, id)] then
                    set ProtoStartHead[pid] = id
                endif
            elseif action == 2001 then
                if not ExpReady[pid] and not ProtoCanDepart(pid) then
                    call DisplayTimedTextToPlayer(Player(pid), 0, 0, 6, "공격력 1인 T1 무기는 출발할 수 없습니다. 마을에서 첫 계승을 시도하여 T2 무기를 갖춘 뒤 준비해 주세요.")
                    return
                endif
                set ExpReady[pid] = not ExpReady[pid]
                call ProtoTryStart()
            endif
            return
        endif
        if not ExpPrototypeActive or ExpState != EXP_HUNT or not ExpMember[pid] or ProtoReady[pid] then
            return
        endif
        if action >= 2101 and action <= 2104 and ProtoStage[pid] == 1 then
            set slot = action - 2100
            if slot > ProtoChoices[pid] then
                return
            endif
            set id = ProtoCandidates[ExpKey(pid, slot)]
            if not ProtoEventEligible(pid, id) then
                call ProtoOffer(pid)
                return
            endif
            set ProtoEventUsed[id] = true
            set ProtoSelected[pid] = id
            set ProtoAP[pid] = ProtoAP[pid] - 1
            set ProtoStage[pid] = 2
            set ProtoDeadline[pid] = 45
            set ExpOfferVersion[pid] = ExpOfferVersion[pid] + 1
            // 표시만 된 사건은 재등장 가능하지만 선택된 사건은 파티 전체에서 제외한다.
            set other = 0
            loop
                exitwhen other == 4
                if other != pid and ExpMember[other] and ProtoStage[other] == 1 then
                    set slot = 1
                    loop
                        exitwhen slot > ProtoChoices[other]
                        if ProtoCandidates[ExpKey(other, slot)] == id then
                            call ProtoOffer(other)
                            exitwhen true
                        endif
                        set slot = slot + 1
                    endloop
                endif
                set other = other + 1
            endloop
        elseif action == 2300 and ProtoStage[pid] == 1 then
            set price = 500 + ProtoRerolls[pid] * 100
            if ExpGold[pid] < price then
                return
            endif
            set ExpGold[pid] = ExpGold[pid] - price
            set ProtoRerolls[pid] = ProtoRerolls[pid] + 1
            call ProtoOffer(pid)
        elseif action >= 2201 and action <= 2202 then
            call ProtoResolve(pid, action - 2200)
        elseif action == 2400 and ProtoStage[pid] == 3 then
            call ProtoResume(pid)
        elseif action == 2500 and ProtoAP[pid] == 0 and ProtoStage[pid] == 0 and UnitAlive(MainUnit[pid]) then
            set ProtoReady[pid] = true
            set ExpGold[pid] = ExpGold[pid] + ExpSeconds
            call ProtoSetPause(pid, true)
        endif
    endfunction

    private function ProtoDispatch takes nothing returns nothing
        call ProtoAction(ExpPrototypePid, ExpPrototypeAction)
        call TriggerExecute(ExpRefresh)
    endfunction

    private function ProtoCodexSync takes nothing returns nothing
        local integer pid = GetPlayerId(DzGetTriggerSyncPlayer())
        local string data = DzGetTriggerSyncData()
        local integer head = 1
        if pid < 0 or pid > 3 or ExpMember[pid] or (ExpState != EXP_LOBBY and ExpState != EXP_RESULT) or S2I(JNStringSplit(data, "|", 0)) != PlayerSlotNumber[pid] then
            return
        endif
        // 같은 캐릭터의 뒤늦은 로드 패킷이 이번 원정의 발견 기록을 덮어쓰지 않는다.
        if ProtoCodexSlot[pid] == PlayerSlotNumber[pid] then
            return
        endif
        set ProtoCodexSlot[pid] = PlayerSlotNumber[pid]
        set ProtoStartHead[pid] = 0
        set ExpReady[pid] = false
        loop
            exitwhen head > 3
            set ProtoHeadKnown[ExpKey(pid, head)] = S2I(JNStringSplit(data, "|", head)) == 1
            set head = head + 1
        endloop
    endfunction

    function ProtoKill takes integer pid returns nothing
        local integer id = PROTO_CARD_FIRST
        set ProtoKills[pid] = ProtoKills[pid] + 1
        set ProtoLastKill[pid] = HuntSeconds[pid]
        set ExpGold[pid] = ExpGold[pid] + 10 + ProtoGoldBonus[pid]
        loop
            exitwhen id > PROTO_CARD_LAST
            if ExpCardOwned[ExpKey(pid, id)] and ProtoEvolutionKind[id] == 1 and not ProtoEvolved[ExpKey(pid, id)] then
                set ProtoCardProgress[ExpKey(pid, id)] = ProtoCardProgress[ExpKey(pid, id)] + 1.0
            endif
            set id = id + 1
        endloop
    endfunction

    private function ProtoSpawn takes integer pid, integer slot returns nothing
        local rect bounds = MapRectReturn(pid + 1)
        local real x
        local real y
        local integer attempts = 0
        local integer key = pid * 16 + slot
        local integer index
        loop
            set x = GetRandomReal(GetRectMinX(bounds) + 160.0, GetRectMaxX(bounds) - 160.0)
            set y = GetRandomReal(GetRectMinY(bounds) + 160.0, GetRectMaxY(bounds) - 160.0)
            exitwhen not IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY) and (x - GetUnitX(MainUnit[pid])) * (x - GetUnitX(MainUnit[pid])) + (y - GetUnitY(MainUnit[pid])) * (y - GetUnitY(MainUnit[pid])) > 90000.0
            set attempts = attempts + 1
            if attempts >= 20 then
                set bounds = null
                return
            endif
        endloop
        set HuntUnits[key] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), 'hfoo', x, y, 270.0)
        set index = IndexUnit(HuntUnits[key])
        set ProtoHuntOwner[index] = pid + 1
        set ExpEnemy[index] = true
        set UnitHP[index] = 300.0 * (1.0 + 0.30 * (ProtoLevel[pid] - 1))
        set UnitHPMAX[index] = UnitHP[index]
        set UnitArm[index] = 0.0
        set UnitSD[index] = 0.0
        set UnitSDMAX[index] = 0.0
        set UnitCasting[index] = false
        call SetUnitState(HuntUnits[key], UNIT_STATE_MAX_LIFE, 1000000.0)
        call SetUnitState(HuntUnits[key], UNIT_STATE_LIFE, 1000000.0)
        call UnitRemoveAbility(HuntUnits[key], 'Aatk')
        call SetUnitAcquireRange(HuntUnits[key], 0.0)
        call SetUnitMoveSpeed(HuntUnits[key], 380.0)
        set AttackClock[key] = 0.75
        set AttackWarning[key] = false
        set bounds = null
    endfunction

    function ProtoHuntUpdate takes integer pid returns nothing
        local integer slot = 1
        local integer key
        local integer index
        local rect bounds = MapRectReturn(pid + 1)
        if not UnitAlive(MainUnit[pid]) then
            set DeathSeconds[pid] = DeathSeconds[pid] + 0.25
            if DeathSeconds[pid] >= 15.0 then
                call ReviveHero(MainUnit[pid], GetRectCenterX(bounds), GetRectCenterY(bounds), false)
                call SetUnitState(MainUnit[pid], UNIT_STATE_LIFE, GetUnitState(MainUnit[pid], UNIT_STATE_MAX_LIFE))
                call RefreshHP(MainUnit[pid])
                set DeathSeconds[pid] = 0.0
            endif
            set bounds = null
            return
        endif
        set DeathSeconds[pid] = 0.0
        if not RectContainsUnit(bounds, MainUnit[pid]) then
            call SetUnitPosition(MainUnit[pid], GetRectCenterX(bounds), GetRectCenterY(bounds))
        endif
        loop
            exitwhen slot > 10
            set key = pid * 16 + slot
            if HuntUnits[key] != null then
                set index = IndexUnit(HuntUnits[key])
                if UnitHP[index] <= 0.0 or not UnitAlive(HuntUnits[key]) then
                    call ProtoKill(pid)
                    call ProtoRemoveEnemy(key)
                elseif slot > ProtoDensity[pid] then
                    // 밀도 감소는 처치 보상으로 정산하지 않는다.
                    call ProtoRemoveEnemy(key)
                else
                    call SetUnitState(HuntUnits[key], UNIT_STATE_LIFE, RMaxBJ(1.0, 1000000.0 * UnitHP[index] / UnitHPMAX[index]))
                    set AttackClock[key] = AttackClock[key] - 0.25
                    if AttackWarning[key] then
                        if AttackClock[key] <= 0.0 then
                            if IsUnitInRange(HuntUnits[key], MainUnit[pid], 190.0) then
                                call BossDeal(HuntUnits[key], MainUnit[pid], GetUnitState(MainUnit[pid], UNIT_STATE_MAX_LIFE) * 0.04 * (1.0 + 0.25 * (ProtoLevel[pid] - 1)), false)
                            endif
                            set AttackWarning[key] = false
                            set AttackClock[key] = 1.0
                            call SetUnitVertexColor(HuntUnits[key], 255, 255, 255, 255)
                        endif
                    elseif IsUnitInRange(HuntUnits[key], MainUnit[pid], 140.0) then
                        call IssueImmediateOrder(HuntUnits[key], "stop")
                        if AttackClock[key] <= 0.0 then
                            call SetUnitAnimation(HuntUnits[key], "attack")
                            call SetUnitVertexColor(HuntUnits[key], 255, 80, 80, 255)
                            set AttackWarning[key] = true
                            set AttackClock[key] = 0.5
                        endif
                    else
                        call IssuePointOrder(HuntUnits[key], "move", GetUnitX(MainUnit[pid]), GetUnitY(MainUnit[pid]))
                    endif
                endif
            endif
            if HuntUnits[key] == null and slot <= ProtoDensity[pid] then
                call ProtoSpawn(pid, slot)
            endif
            set slot = slot + 1
        endloop
        set bounds = null
    endfunction

    function ProtoEvolutionTick takes integer pid returns nothing
        local integer id = PROTO_CARD_FIRST
        set ProtoSafeTime[pid] = ProtoSafeTime[pid] + 0.25
        loop
            exitwhen id > PROTO_CARD_LAST
            if ExpCardOwned[ExpKey(pid, id)] and ProtoEvolutionKind[id] > 0 and not ProtoEvolved[ExpKey(pid, id)] then
                if ProtoEvolutionKind[id] == 3 then
                    set ProtoCardProgress[ExpKey(pid, id)] = ProtoCardProgress[ExpKey(pid, id)] + 0.25
                endif
                if ProtoCardProgress[ExpKey(pid, id)] >= ProtoEvolutionGoal[id] then
                    set ProtoEvolved[ExpKey(pid, id)] = true
                    call DisplayTimedTextToPlayer(Player(pid), 0, 0, 5, "|cffc781ff카드 각성! " + ProtoCardName[id] + " · 피해 +25%|r")
                    if GetLocalPlayer() == Player(pid) then
                        call StashSave(PLAYER_DATA[pid], "원정.카드각성도감." + I2S(id), "1")
                    endif
                    call RequestPlayerSave(pid)
                    call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl", MainUnit[pid], "origin"))
                endif
            endif
            set id = id + 1
        endloop
    endfunction

    function ProtoTick takes nothing returns nothing
        local integer pid = 0
        local integer slot
        local boolean second = false
        local boolean allReady = true
        if not ExpPrototypeActive then
            return
        endif
        set HuntFraction = HuntFraction + 0.25
        if HuntFraction >= 1.0 then
            set HuntFraction = 0.0
            set ExpSeconds = IMaxBJ(0, ExpSeconds - 1)
            set second = true
        endif
        if ExpState != EXP_HUNT then
            return
        endif
        loop
            exitwhen pid == 4
            if ExpMember[pid] then
                if not ProtoReady[pid] then
                    set allReady = false
                    if ProtoStage[pid] > 0 then
                        if second then
                            set ProtoDeadline[pid] = IMaxBJ(0, ProtoDeadline[pid] - 1)
                            if ProtoDeadline[pid] == 0 then
                                if ProtoStage[pid] == 2 then
                                    call ProtoResolve(pid, 2)
                                else
                                    call ProtoResume(pid)
                                endif
                            endif
                        endif
                    else
                        call ProtoHuntUpdate(pid)
                        if UnitAlive(MainUnit[pid]) then
                            call ProtoEvolutionTick(pid)
                            if second then
                                set HuntSeconds[pid] = HuntSeconds[pid] + 1
                                if ProtoAP[pid] > 0 and HuntSeconds[pid] - ProtoLastEvent[pid] >= 20 and (ProtoKills[pid] - ProtoOfferKills[pid] >= 12 or HuntSeconds[pid] - ProtoLastEvent[pid] >= 45 or HuntSeconds[pid] - ProtoLastKill[pid] >= 25) then
                                    set ProtoRerolls[pid] = 0
                                    call ProtoOffer(pid)
                                endif
                            endif
                        endif
                    endif
                endif
            else
                set slot = 1
                loop
                    exitwhen slot > 10
                    call ProtoRemoveEnemy(pid * 16 + slot)
                    set slot = slot + 1
                endloop
            endif
            set pid = pid + 1
        endloop
        if ExpSeconds == 0 or allReady then
            call ProtoJoinBoss()
        endif
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        set ExpPrototypeEnabled = true
        call DzTriggerRegisterSyncData(t, "ProtoCodex", false)
        call TriggerAddAction(t, function ProtoCodexSync)
        call TriggerAddAction(ExpPrototypeRequest, function ProtoDispatch)
        call TriggerAddAction(ExpPrototypeCleanup, function ProtoCleanup)
        call TimerStart(HuntClock, 0.25, true, function ProtoTick)
        set t = null
    endfunction
endlibrary
