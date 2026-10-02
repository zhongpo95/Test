// 개인 사냥, 행동력 사건, 카드 각성과 준비 완료 후 보스 합류를 진행한다.
library ExpeditionPrototype initializer Init requires Expedition, DataPrototype, DataMap, StatsSet, PlayerSave, CardRecovery
    globals
        private timer HuntClock = CreateTimer()
        private real HuntFraction = 0.0
        private integer array HuntSeconds
        private real array DeathSeconds
        private unit array HuntUnits
        private real array AttackClock
        private boolean array AttackWarning
        private boolean array HuntMoving
        private real array MoveX
        private real array MoveY
        private boolean array ReservedRegion
        // 한 번의 추첨에서만 사용하는 유효 사건 목록. 동기화 경로에서 순차적으로 채운다.
        private integer array OfferEvents
        private integer array OfferWeights
    endglobals

    function ProtoRefreshStats takes integer pid returns nothing
        local real ratio = GetUnitState(MainUnit[pid], UNIT_STATE_LIFE) / GetUnitState(MainUnit[pid], UNIT_STATE_MAX_LIFE)
        call ProtoStatRefreshDerived(pid)
        call PlayerStatsSet(pid)
        call ItemUIStatsSet(pid)
        call SetUnitState(MainUnit[pid], UNIT_STATE_LIFE, GetUnitState(MainUnit[pid], UNIT_STATE_MAX_LIFE) * ratio)
        call RefreshHP(MainUnit[pid])
    endfunction

    function ProtoStartHeadReady takes integer pid returns boolean
        local integer head = ProtoStartHead[pid]
        // 머리 카드 없이 출발할 때는 도감 로드를 기다리지 않는다.
        return head == 0 or (head >= 1 and head <= PROTO_HEAD_COUNT and ProtoCodexSlot[pid] == PlayerSlotNumber[pid] and ProtoHeadKnown[ExpKey(pid, head)])
    endfunction

    function ProtoCanDepart takes integer pid returns boolean
        // 기존 첫 계승(ID10 → ID3)이 공격력 1인 T1을 공격력 100인 T2로 바꾼다.
        return PickCheck[pid] and ProtoStartHeadReady(pid) and PlayerSlotNumber[pid] > 0 and GetItemTier(Eitem[pid][EQUIP_SLOT_WEAPON]) >= 2 and AttackPower(pid) >= 100.0 and UnitAlive(MainUnit[pid]) and RectContainsUnit(gg_rct_Home, MainUnit[pid])
    endfunction

    private function ProtoRememberHead takes integer pid, integer head returns nothing
        if not ProtoHeadKnown[ExpKey(pid, head)] then
            set ProtoHeadKnown[ExpKey(pid, head)] = true
            if GetLocalPlayer() == Player(pid) then
                call StashSave(PLAYER_DATA[pid], PROTO_SAVE_PREFIX + "머리도감." + ProtoHeadKey[head], "1")
            endif
            call RequestPlayerSave(pid)
        endif
    endfunction

    private function ProtoRememberCard takes integer pid, integer card returns nothing
        if GetLocalPlayer() == Player(pid) then
            call StashSave(PLAYER_DATA[pid], PROTO_SAVE_PREFIX + "카드도감." + ProtoCardKey[card], "1")
        endif
        call RequestPlayerSave(pid)
    endfunction

    function ProtoGrantHead takes integer pid, integer head returns nothing
        if head < 1 or head > PROTO_HEAD_COUNT or ProtoHeadCount[pid] >= 2 or ProtoHeadOwned[ExpKey(pid, head)] then
            return
        endif
        set ProtoHeadOwned[ExpKey(pid, head)] = true
        set ProtoHeadCount[pid] = ProtoHeadCount[pid] + 1
        // 머리 효과는 작게 두고 관련 풀을 여는 역할에 집중한다.
        call ProtoStatAddHead(pid, head)
        call ProtoStatRefreshDerived(pid)
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
        set ProtoCardStacks[ExpKey(pid, card)] = 0
        set ProtoCardRevision[pid] = ProtoCardRevision[pid] + 1
        set ExpCardOwned[ExpKey(pid, card)] = true
        set ProtoCardProgress[ExpKey(pid, card)] = 0.0
        set ProtoEvolved[ExpKey(pid, card)] = false
        call ProtoStatAddCard(pid, card, false)
        call ProtoEvolutionRegister(pid, card)
        set ProtoOutcome[pid] = ProtoOutcome[pid] + "|n[" + ExpEventGradeName(ProtoCardGrade[card]) + "] " + ProtoCardName[card] + "|n" + ProtoCardText(pid, card)
        // 사건 결과 창에 이미 표시할 때는 채팅 알림이 본문을 덮지 않도록 한다.
        if ProtoStage[pid] != 2 then
            call DisplayTimedTextToPlayer(Player(pid), 0, 0, 6, "카드 획득 · [" + ExpEventGradeName(ProtoCardGrade[card]) + "] " + ProtoCardName[card] + "|n성장·카드 창에서 효과와 각성 조건을 확인할 수 있습니다.")
        endif
        call ProtoRememberCard(pid, card)
        call ProtoRefreshStats(pid)
    endfunction

    function ProtoBranchAvailable takes integer pid, integer id, integer choice returns boolean
        local integer key = ProtoChoiceKey(id, choice)
        if choice < 1 or choice > ProtoEventChoices[id] then
            return false
        endif
        if ProtoEventKind[id] == 0 then
            return choice == 1 and ProtoHeadCount[pid] < 2 and not ProtoHeadOwned[ExpKey(pid, ProtoEventHead[id])]
        endif
        return ExpGold[pid] >= ProtoBranchCost[key] and ProtoLevel[pid] + ProtoBranchLevel[key] <= 5 and ProtoDensity[pid] + ProtoBranchDensity[key] <= 10
    endfunction

    function ProtoEventEligible takes integer pid, integer id returns boolean
        local integer head
        local integer previous
        local integer choice = 1
        if id <= 0 or id > PROTO_EVENT_COUNT or ProtoEventUsed[id] or ProtoEventKind[id] < 0 or ProtoAP[pid] <= 0 or ProtoAP[pid] < ProtoEventAPCost[id] then
            return false
        endif
        set head = ProtoEventHead[id]
        if ProtoEventKind[id] == 0 then
            // 입구 ID는 플레이어별로 하나씩 배정한다. 다른 사람의 머리 획득이 내 입구를 소진하지 않는다.
            return id == (head - 1) * 4 + pid + 1 and ProtoHeadCount[pid] < 2 and not ProtoHeadOwned[ExpKey(pid, head)]
        endif
        // 잠긴 지역의 사건은 분기 조건까지 검사하지 않는다.
        if head > 0 and not ProtoHeadOwned[ExpKey(pid, head)] then
            return false
        endif
        set previous = ProtoEventRequired[id]
        if previous > 0 and ProtoEventHistory[ProtoStoryKey(pid, previous)] != ProtoEventRequiredChoice[id] then
            return false
        endif
        if ProtoEventRequiredCard[id] > 0 and not ExpCardOwned[ExpKey(pid, ProtoEventRequiredCard[id])] then
            return false
        endif
        loop
            exitwhen choice > ProtoEventChoices[id]
            if ProtoBranchAvailable(pid, id, choice) then
                return true
            endif
            set choice = choice + 1
        endloop
        return false
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
        local integer id = 1
        local integer j
        local integer count = 0
        local integer total = 0
        local integer selected
        local integer weight
        local integer roll
        if ProtoAP[pid] <= 0 or ProtoReady[pid] then
            return
        endif
        // 조건 검사는 사건마다 한 번만 한다. 후보 수가 늘어도 전체 분기를 다시 훑지 않는다.
        loop
            exitwhen id > PROTO_EVENT_COUNT
            if ProtoEventEligible(pid, id) then
                set weight = 1
                if ProtoEventKind[id] == 0 then
                    set weight = 80
                elseif ProtoEventRequired[id] > 0 then
                    // 이미 시작한 이야기는 이어질 가능성을 높이되 강제로 등장시키지 않는다.
                    set weight = 12
                elseif ProtoEventHead[id] > 0 then
                    set weight = 3
                endif
                set count = count + 1
                set OfferEvents[count] = id
                set OfferWeights[count] = weight
                set total = total + weight
            endif
            set id = id + 1
        endloop
        loop
            exitwhen slot > 4
            set ProtoCandidates[ExpKey(pid, slot)] = 0
            if slot <= ProtoChoices[pid] and total > 0 then
                set roll = GetRandomInt(1, total)
                set j = 1
                set selected = 0
                loop
                    exitwhen j > count
                    if roll <= OfferWeights[j] then
                        set selected = OfferEvents[j]
                        // 같은 가중치로 중복 없이 뽑는다. 선택한 사건은 이번 목록에서만 제거한다.
                        set total = total - OfferWeights[j]
                        set OfferEvents[j] = OfferEvents[count]
                        set OfferWeights[j] = OfferWeights[count]
                        set count = count - 1
                        exitwhen true
                    endif
                    set roll = roll - OfferWeights[j]
                    set j = j + 1
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

    function ProtoEventCardPreview takes integer pid, integer card returns string
        if ExpCardOwned[ExpKey(pid, card)] then
            return ProtoCardName[card] + " 강화 +" + I2S(ProtoCardStacks[ExpKey(pid, card)] + 1) + " · 원래 효과 +50%|n" + ProtoCardEffectsScaled(card, ProtoEvolved[ExpKey(pid, card)], 1.5 + 0.5 * ProtoCardStacks[ExpKey(pid, card)])
        endif
        return "[" + ExpEventGradeName(ProtoCardGrade[card]) + "] " + ProtoCardName[card] + " · " + ProtoCardEffectName[card] + "|n" + JNStringReplace(ProtoCardEffectsText(card, false), "|n", " · ")
    endfunction

    function ProtoBranchAllowed takes integer pid, integer choice returns boolean
        return ProtoBranchAvailable(pid, ProtoSelected[pid], choice)
    endfunction

    function ProtoBranchText takes integer pid, integer choice returns string
        local integer id = ProtoSelected[pid]
        local integer key = ProtoChoiceKey(id, choice)
        local string value = ProtoBranchLabel[key]
        local string reward = ""
        local string cost = ""
        local string field = ""
        if ProtoEventKind[id] == 0 then
            return "즉시 지역 개방 · " + ProtoHeadEffectText(ProtoEventHead[id]) + "|n" + ProtoEventCardPreview(pid, ProtoHeadEntryCard[ProtoEventHead[id]])
        endif
        if ProtoBranchCost[key] > 0 then
            set cost = I2S(ProtoBranchCost[key]) + "골드  "
        endif
        if ProtoBranchLevel[key] > 0 then
            set field = "|cff9c4a22적 단계 +" + I2S(ProtoBranchLevel[key]) + "|cff163848  "
        elseif ProtoBranchLevel[key] < 0 then
            set field = "|cff216548적 단계 " + I2S(ProtoBranchLevel[key]) + " (최저 1)|cff163848  "
        endif
        if ProtoBranchDensity[key] > 0 then
            set field = field + "|cff9c4a22적 수 +" + I2S(ProtoBranchDensity[key]) + "|cff163848"
        elseif ProtoBranchDensity[key] < 0 then
            set field = field + "|cff216548적 수 " + I2S(ProtoBranchDensity[key]) + " (최저 1)|cff163848"
        endif
        if ProtoBranchCard[key] > 0 then
            set reward = ProtoEventCardPreview(pid, ProtoBranchCard[key]) + "  "
        endif
        if ProtoBranchCard2[key] > 0 then
            set reward = reward + ProtoEventCardPreview(pid, ProtoBranchCard2[key]) + "  "
        endif
        if ProtoBranchGold[key] > 0 then
            set reward = reward + "골드 +" + I2S(ProtoBranchGold[key]) + "  "
        endif
        if ProtoBranchPotions[key] > 0 then
            set reward = reward + "생명력 물약 +" + I2S(ProtoBranchPotions[key])
        endif
        if ProtoBranchChance[key] > 0 and ProtoBranchChance[key] < 100 then
            set value = value + "|n|cff216548[성공 보상] " + reward + "|cff163848"
        elseif reward != "" then
            set value = value + "|n|cff216548[보상] " + reward + "|cff163848"
        endif
        if cost != "" then
            set value = value + "|n|cff9c4a22[비용] " + cost + "|cff163848"
        endif
        if field != "" then
            set value = value + "|n[사냥터] " + field
        endif
        if ProtoBranchChance[key] > 0 and ProtoBranchChance[key] < 100 then
            set value = value + "|n[판정] 성공 " + I2S(ProtoBranchChance[key]) + "% · 실패 시 보상 없음"
            if cost != "" and field != "" then
                set value = value + "|n실패해도 비용과 사냥터 변화는 적용됩니다."
            elseif cost != "" then
                set value = value + "|n실패해도 비용은 소모됩니다."
            elseif field != "" then
                set value = value + "|n실패해도 사냥터 변화는 적용됩니다."
            endif
        endif
        if not ProtoBranchAllowed(pid, choice) then
            set value = value + "|n현재 골드 또는 적 단계·수 상한 때문에 선택할 수 없습니다."
        endif
        return value
    endfunction

    // 작은 행동 칸에는 손익만 요약한다. 카드 수치와 판정 상세는 사건 설명 칸에서 확인한다.
    function ProtoBranchSummary takes integer pid, integer choice returns string
        local integer key = ProtoChoiceKey(ProtoSelected[pid], choice)
        local string value = ProtoBranchLabel[key]
        local string reward = ""
        local string cost = ""
        if ProtoBranchCard[key] > 0 then
            set reward = ProtoCardName[ProtoBranchCard[key]]
            if ExpCardOwned[ExpKey(pid, ProtoBranchCard[key])] then
                set reward = reward + " (강화 · 원래 효과 +50%)"
            endif
        endif
        if ProtoBranchCard2[key] > 0 then
            set reward = reward + " · " + ProtoCardName[ProtoBranchCard2[key]]
            if ExpCardOwned[ExpKey(pid, ProtoBranchCard2[key])] then
                set reward = reward + " (강화 · 원래 효과 +50%)"
            endif
        endif
        if ProtoBranchGold[key] > 0 then
            set reward = reward + " 골드 +" + I2S(ProtoBranchGold[key])
        endif
        if ProtoBranchPotions[key] > 0 then
            set reward = reward + " 물약 +" + I2S(ProtoBranchPotions[key])
        endif
        if ProtoBranchCost[key] > 0 then
            set cost = I2S(ProtoBranchCost[key]) + "골드 · "
        endif
        if ProtoBranchLevel[key] != 0 then
            set cost = cost + "적 단계 " + I2S(ProtoBranchLevel[key]) + " · "
        endif
        if ProtoBranchDensity[key] != 0 then
            set cost = cost + "적 수 " + I2S(ProtoBranchDensity[key]) + " · "
        endif
        if ProtoBranchChance[key] < 100 then
            set cost = cost + "성공 " + I2S(ProtoBranchChance[key]) + "%"
        endif
        return value + "|n" + reward + "|n" + cost
    endfunction

    function ProtoUpgradeCard takes integer pid, integer card returns nothing
        local integer kind = 1
        local real value
        loop
            exitwhen kind > PROTO_STAT_LAST
            set value = LoadReal(ProtoEffectData, card, kind)
            if ProtoEvolved[ExpKey(pid, card)] then
                set value = value + LoadReal(ProtoEffectData, card, kind + 32)
            endif
            set ProtoStatValues[pid * 32 + kind] = ProtoStatValues[pid * 32 + kind] + value * 0.5
            set kind = kind + 1
        endloop
        set ProtoCardStacks[ExpKey(pid, card)] = ProtoCardStacks[ExpKey(pid, card)] + 1
        set ProtoCardRevision[pid] = ProtoCardRevision[pid] + 1
        set ProtoOutcome[pid] = ProtoOutcome[pid] + "|n" + ProtoCardName[card] + " 강화 완료|n" + ProtoCardText(pid, card)
    endfunction

    function ProtoGrantEventCard takes integer pid, integer card returns nothing
        if card <= 0 then
            return
        endif
        // 사건의 정체성을 유지한다. 중복 카드를 다른 작품의 카드로 다시 뽑지 않는다.
        if ExpCardOwned[ExpKey(pid, card)] then
            call ProtoUpgradeCard(pid, card)
        else
            call ProtoGrantCard(pid, card)
        endif
    endfunction

    function ProtoRemoveEnemy takes integer key returns nothing
        local integer index
        if HuntUnits[key] != null then
            set index = IndexUnit(HuntUnits[key])
            set ProtoHuntOwner[index] = 0
            set ExpEnemy[index] = false
            set ExpEnemyBoss[index] = false
            call KillUnit(HuntUnits[key])
            call RemoveUnit(HuntUnits[key])
            set HuntUnits[key] = null
        endif
        set AttackClock[key] = 0.0
        set AttackWarning[key] = false
        set HuntMoving[key] = false
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
                    call ExpSyncEnemyLife(HuntUnits[key])
                endif
            endif
            set slot = slot + 1
        endloop
    endfunction

    function ProtoResolve takes integer pid, integer choice returns nothing
        local integer id = ProtoSelected[pid]
        local integer key = ProtoChoiceKey(id, choice)
        local integer roll = 0
        local boolean success = true
        local integer levelBefore = ProtoLevel[pid]
        local integer densityBefore = ProtoDensity[pid]
        if ProtoStage[pid] != 2 or not ProtoBranchAllowed(pid, choice) then
            return
        endif
        set ProtoOutcome[pid] = ProtoEventName[id]
        if ProtoEventKind[id] == 0 then
            call ProtoGrantHead(pid, ProtoEventHead[id])
            set ProtoOutcome[pid] = ProtoOutcome[pid] + "|n" + ProtoEventStory[id] + "|n|n|cff216548[지역 개방]|cff315a70|n머리 카드 획득 · " + ProtoHeadName[ProtoEventHead[id]] + "|n관련 사건 풀 개방 · " + ProtoHeadEffectText(ProtoEventHead[id]) + "|n|n|cff216548[입문 카드]|cff315a70"
            call ProtoGrantEventCard(pid, ProtoHeadEntryCard[ProtoEventHead[id]])
        else
            // 표시한 비용과 필드 위험은 먼저 적용한다. 실패했다고 판돈이 환급되지는 않는다.
            set ExpGold[pid] = ExpGold[pid] - ProtoBranchCost[key]
            set ProtoLevel[pid] = IMaxBJ(1, ProtoLevel[pid] + ProtoBranchLevel[key])
            set ProtoDensity[pid] = IMaxBJ(1, ProtoDensity[pid] + ProtoBranchDensity[key])
            if ProtoBranchChance[key] > 0 and ProtoBranchChance[key] < 100 then
                set roll = GetRandomInt(1, 100)
                set success = roll <= ProtoBranchChance[key]
                set ProtoOutcome[pid] = ProtoOutcome[pid] + "|n성공 판정 " + I2S(roll) + "/100 · " + I2S(ProtoBranchChance[key]) + " 이하이면 성공"
            endif
            if success then
                set ProtoOutcome[pid] = ProtoOutcome[pid] + "|n" + ProtoBranchLabel[key] + "|n" + ProtoBranchResult[key]
                if ProtoBranchCard[key] > 0 or ProtoBranchCard2[key] > 0 or ProtoBranchGold[key] > 0 or ProtoBranchPotions[key] > 0 then
                    set ProtoOutcome[pid] = ProtoOutcome[pid] + "|n|n|cff216548[획득 보상]|cff315a70"
                endif
                call ProtoGrantEventCard(pid, ProtoBranchCard[key])
                call ProtoGrantEventCard(pid, ProtoBranchCard2[key])
                set ExpGold[pid] = ExpGold[pid] + ProtoBranchGold[key]
                if ProtoBranchGold[key] > 0 then
                    set ProtoOutcome[pid] = ProtoOutcome[pid] + "|n골드 +" + I2S(ProtoBranchGold[key])
                endif
                if ProtoBranchPotions[key] > 0 then
                    call SetItemCharges(PlayerItem1[pid], GetItemCharges(PlayerItem1[pid]) + ProtoBranchPotions[key])
                    call ShowPlayerPotionDisplay(pid)
                    set ProtoOutcome[pid] = ProtoOutcome[pid] + "|n생명력 물약 +" + I2S(ProtoBranchPotions[key])
                endif
            else
                set ProtoOutcome[pid] = ProtoOutcome[pid] + "|n|cff9c4a22[실패 · 보상 없음]|cff315a70|n" + ProtoEventFailure[id]
            endif
            if ProtoBranchCost[key] > 0 then
                set ProtoOutcome[pid] = ProtoOutcome[pid] + "|n|n|cff9c4a22[지불 비용]|cff315a70"
            endif
            if ProtoBranchCost[key] > 0 then
                set ProtoOutcome[pid] = ProtoOutcome[pid] + "|n지불한 골드 " + I2S(ProtoBranchCost[key])
            endif
        endif
        if success then
            set ProtoEventHistory[ProtoStoryKey(pid, id)] = choice
        else
            set ProtoEventHistory[ProtoStoryKey(pid, id)] = -choice
        endif
        call ProtoRefreshStats(pid)
        call ProtoApplyField(pid)
        if levelBefore != ProtoLevel[pid] or densityBefore != ProtoDensity[pid] then
            if ProtoLevel[pid] > levelBefore or ProtoDensity[pid] > densityBefore then
                set ProtoOutcome[pid] = ProtoOutcome[pid] + "|n|n|cff9c4a22[사냥터 변화]|cff315a70"
            else
                set ProtoOutcome[pid] = ProtoOutcome[pid] + "|n|n|cff216548[사냥터 변화]|cff315a70"
            endif
        endif
        if levelBefore != ProtoLevel[pid] then
            set ProtoOutcome[pid] = ProtoOutcome[pid] + "|n적 단계 " + I2S(levelBefore) + " → " + I2S(ProtoLevel[pid]) + "|n몬스터 체력 " + I2S(R2I(300.0 * (1.0 + 0.30 * (levelBefore - 1)))) + " → " + I2S(R2I(300.0 * (1.0 + 0.30 * (ProtoLevel[pid] - 1)))) + "|n한 번의 공격 피해 · 내 최대 체력의 " + R2SW(4.0 * (1.0 + 0.25 * (levelBefore - 1)), 0, 1) + "% → " + R2SW(4.0 * (1.0 + 0.25 * (ProtoLevel[pid] - 1)), 0, 1) + "%"
        endif
        if densityBefore != ProtoDensity[pid] then
            set ProtoOutcome[pid] = ProtoOutcome[pid] + "|n동시 몬스터 수 " + I2S(densityBefore) + " → " + I2S(ProtoDensity[pid])
        endif
        set ProtoStage[pid] = 3
        set ProtoDeadline[pid] = 30
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

    // 시간 만료는 추가 비용·위험이 없는 행동부터 고른다. 무효인 고정 2번으로 멈추지 않는다.
    function ProtoResolveTimeout takes integer pid returns nothing
        local integer choice = 1
        local integer selected = 0
        local integer key
        loop
            exitwhen choice > ProtoEventChoices[ProtoSelected[pid]]
            set key = ProtoChoiceKey(ProtoSelected[pid], choice)
            if ProtoBranchAllowed(pid, choice) then
                if ProtoBranchCost[key] == 0 and ProtoBranchLevel[key] <= 0 and ProtoBranchDensity[key] <= 0 then
                    call ProtoResolve(pid, choice)
                    return
                endif
                if selected == 0 or ProtoBranchCost[key] < ProtoBranchCost[ProtoChoiceKey(ProtoSelected[pid], selected)] then
                    set selected = choice
                endif
            endif
            set choice = choice + 1
        endloop
        if selected > 0 then
            call ProtoResolve(pid, selected)
        else
            // 외부 정산으로 조건이 바뀌었을 때에도 개인 구역의 정지를 해제한다.
            call ProtoResume(pid)
        endif
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
            call ProtoClearRecovery(area)
            call ProtoEvolutionReset(area)
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
                    call ProtoResolveTimeout(pid)
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
            set ProtoAPMax[pid] = 10
            set ProtoStage[pid] = 0
            set ProtoSelected[pid] = 0
            set ProtoDeadline[pid] = 0
            set ProtoOutcome[pid] = ""
            set ProtoHeadCount[pid] = 0
            set ProtoChoices[pid] = 3
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
            call ProtoClearRecovery(pid)
            call ProtoStatReset(pid)
            call ProtoEvolutionReset(pid)
            set id = 0
            loop
                exitwhen id > IMaxBJ(63, PROTO_CARD_LAST)
                set ExpArcana[ExpKey(pid, id)] = 0
                set ExpCardOwned[ExpKey(pid, id)] = false
                set ExpCardSeen[ExpKey(pid, id)] = false
                set ExpCardReserved[ExpKey(pid, id)] = false
                set ProtoCardProgress[ExpKey(pid, id)] = 0.0
                set ProtoEvolved[ExpKey(pid, id)] = false
                set ProtoCardStacks[ExpKey(pid, id)] = 0
                set ProtoHeadOwned[ExpKey(pid, id)] = false
                set ProtoCandidates[ExpKey(pid, id)] = 0
                set id = id + 1
            endloop
            set id = 1
            loop
                exitwhen id > PROTO_EVENT_COUNT
                set ProtoEventHistory[ProtoStoryKey(pid, id)] = 0
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
            elseif action >= 2010 and action <= 2010 + PROTO_HEAD_COUNT and not ExpReady[pid] then
                set id = action - 2010
                if id == 0 or (ProtoCodexSlot[pid] == PlayerSlotNumber[pid] and ProtoHeadKnown[ExpKey(pid, id)]) then
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
            set ProtoAP[pid] = ProtoAP[pid] - ProtoEventAPCost[id]
            set ProtoStage[pid] = 2
            set ProtoDeadline[pid] = 45
            set ExpOfferVersion[pid] = ExpOfferVersion[pid] + 1
            // 머리 후보를 선택한 시점에 이미 획득 의사가 확정되었다. 다시 묻거나 행동력을 더 쓰지 않는다.
            if ProtoEventKind[id] == 0 then
                call ProtoResolve(pid, 1)
            endif
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
        elseif action >= 2201 and action <= 2204 then
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
        if pid < 0 or pid > 3 or (ExpState != EXP_LOBBY and ExpState != EXP_RESULT and not ExpPrototypeActive) or S2I(JNStringSplit(data, "|", 0)) != PlayerSlotNumber[pid] then
            return
        endif
        // 같은 캐릭터의 뒤늦은 로드 패킷이 이번 원정의 발견 기록을 덮어쓰지 않는다.
        if ProtoCodexSlot[pid] == PlayerSlotNumber[pid] then
            return
        endif
        if not ExpMember[pid] and ProtoStartHead[pid] != 0 then
            set ProtoStartHead[pid] = 0
            set ExpReady[pid] = false
        endif
        loop
            exitwhen head > PROTO_HEAD_COUNT
            // 첫 도감 로드 전에 사냥에서 발견한 머리도 함께 보존한다.
            set ProtoHeadKnown[ExpKey(pid, head)] = S2I(JNStringSplit(data, "|", head)) == 1 or (ProtoCodexSlot[pid] == 0 and ProtoHeadKnown[ExpKey(pid, head)])
            set head = head + 1
        endloop
        set ProtoCodexSlot[pid] = PlayerSlotNumber[pid]
    endfunction

    function ProtoKill takes integer pid returns nothing
        local integer id = ProtoEvolutionFirst[pid * 4 + 1]
        set ProtoKills[pid] = ProtoKills[pid] + 1
        set ProtoLastKill[pid] = HuntSeconds[pid]
        set ExpGold[pid] = ExpGold[pid] + 10 + ProtoGoldBonus[pid]
        loop
            exitwhen id == 0
            set ProtoCardProgress[ExpKey(pid, id)] = ProtoCardProgress[ExpKey(pid, id)] + 1.0
            set id = ProtoEvolutionNext[ExpKey(pid, id)]
        endloop
    endfunction

    private function ProtoSpawn takes integer pid, integer slot returns nothing
        local rect bounds = MapCenter[pid + 1]
        local real x
        local real y
        local integer attempts = 0
        local integer key = pid * 16 + slot
        local integer index
        // 이동 구역 전체가 아니라 사용자가 지정한 몬스터 생성 구역만 사용한다.
        if bounds == null or GetRectMaxX(bounds) - GetRectMinX(bounds) <= 320.0 or GetRectMaxY(bounds) - GetRectMinY(bounds) <= 320.0 then
            set bounds = null
            return
        endif
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
        set ExpEnemyBoss[index] = false
        set UnitHP[index] = 300.0 * (1.0 + 0.30 * (ProtoLevel[pid] - 1))
        set UnitHPMAX[index] = UnitHP[index]
        set UnitArm[index] = 0.0
        call JNSetUnitArmor(HuntUnits[key], 0.0)
        set UnitSD[index] = 0.0
        set UnitSDMAX[index] = 0.0
        set UnitCasting[index] = false
        call SetUnitState(HuntUnits[key], UNIT_STATE_MAX_LIFE, 1000000.0)
        call SetUnitState(HuntUnits[key], UNIT_STATE_LIFE, 1000000.0)
        call UnitRemoveAbility(HuntUnits[key], 'Aatk')
        call SetUnitAcquireRange(HuntUnits[key], 0.0)
        // 중립 적의 귀환 명령이 개인 사냥 추적을 덮어쓰지 않는다.
        call SetUnitCreepGuard(HuntUnits[key], false)
        call RemoveGuardPosition(HuntUnits[key])
        call SetUnitMoveSpeed(HuntUnits[key], 380.0)
        set AttackClock[key] = 0.75
        set AttackWarning[key] = false
        set HuntMoving[key] = false
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
                            call SetUnitAnimation(HuntUnits[key], "stand")
                        endif
                    elseif IsUnitInRange(HuntUnits[key], MainUnit[pid], 140.0) then
                        if HuntMoving[key] then
                            call IssueImmediateOrder(HuntUnits[key], "stop")
                            set HuntMoving[key] = false
                        endif
                        if AttackClock[key] <= 0.0 then
                            call SetUnitAnimation(HuntUnits[key], "attack")
                            call SetUnitVertexColor(HuntUnits[key], 255, 80, 80, 255)
                            set AttackWarning[key] = true
                            set AttackClock[key] = 0.5
                        endif
                    else
                        // 같은 목적지 명령을 반복하여 회전과 이동 시작을 끊지 않는다.
                        if not HuntMoving[key] or GetUnitCurrentOrder(HuntUnits[key]) != OrderId("move") or (MoveX[key] - GetUnitX(MainUnit[pid])) * (MoveX[key] - GetUnitX(MainUnit[pid])) + (MoveY[key] - GetUnitY(MainUnit[pid])) * (MoveY[key] - GetUnitY(MainUnit[pid])) >= 10000.0 then
                            set MoveX[key] = GetUnitX(MainUnit[pid])
                            set MoveY[key] = GetUnitY(MainUnit[pid])
                            call IssuePointOrder(HuntUnits[key], "move", MoveX[key], MoveY[key])
                            set HuntMoving[key] = true
                        endif
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
        local integer kind = 1
        local integer id
        local integer previous
        local integer next
        local boolean changed = false
        set ProtoSafeTime[pid] = ProtoSafeTime[pid] + 0.25
        loop
            exitwhen kind > 3
            set id = ProtoEvolutionFirst[pid * 4 + kind]
            set previous = 0
            loop
                exitwhen id == 0
                set next = ProtoEvolutionNext[ExpKey(pid, id)]
                if kind == 3 then
                    set ProtoCardProgress[ExpKey(pid, id)] = ProtoCardProgress[ExpKey(pid, id)] + 0.25
                endif
                if ProtoCardProgress[ExpKey(pid, id)] >= ProtoEvolutionGoal[id] then
                    // 각성한 카드는 현재 목록에서 제거하여 이후 전투에서 검사하지 않는다.
                    if previous == 0 then
                        set ProtoEvolutionFirst[pid * 4 + kind] = next
                    else
                        set ProtoEvolutionNext[ExpKey(pid, previous)] = next
                    endif
                    set ProtoEvolutionNext[ExpKey(pid, id)] = 0
                    set ProtoEvolved[ExpKey(pid, id)] = true
                    set ProtoCardRevision[pid] = ProtoCardRevision[pid] + 1
                    call ProtoStatAddCard(pid, id, true)
                    set changed = true
                    call DisplayTimedTextToPlayer(Player(pid), 0, 0, 5, "|cffc781ff카드 각성! " + ProtoCardName[id] + " · " + ProtoCardEffectName[id] + "|r|n" + ProtoCardEffectsScaled(id, true, 1.0 + 0.5 * ProtoCardStacks[ExpKey(pid, id)]))
                    if GetLocalPlayer() == Player(pid) then
                        call StashSave(PLAYER_DATA[pid], PROTO_SAVE_PREFIX + "카드각성도감." + ProtoCardKey[id], "1")
                    endif
                    call RequestPlayerSave(pid)
                    call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl", MainUnit[pid], "origin"))
                else
                    set previous = id
                endif
                set id = next
            endloop
            set kind = kind + 1
        endloop
        if changed then
            call ProtoRefreshStats(pid)
        endif
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
                                    call ProtoResolveTimeout(pid)
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
