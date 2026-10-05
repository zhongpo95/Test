// 사건별 보상 이력을 유지하면서 같은 지역의 캐릭터 카드 효과와 희귀도를 누적한다.
library DataPrototypeGrowth initializer ProtoGrowthInit requires DataPrototypeCatalog, DataPrototypeCardImages
    globals
        private hashtable ProtoStoryChangeState = InitHashtable()
        integer array ProtoCardCharacter
        boolean array ProtoCharacterOwned
        boolean array ProtoCharacterEvolved
        integer array ProtoCharacterGrade
        integer array ProtoRewardCopies
        hashtable ProtoCharacterEffects = InitHashtable()
        private hashtable CharacterIndex = InitHashtable()
        private integer array CharacterNext
        private integer IndexCursor = PROTO_CARD_FIRST
    endglobals

    // 해시가 충돌해도 이름을 직접 비교한다. 지역이 다른 동명 캐릭터는 합치지 않는다.
    function ProtoGrowthIndexChunk takes nothing returns nothing
        local integer finish = IMinBJ(PROTO_CARD_LAST, IndexCursor + 63)
        local integer card
        local integer character
        local integer first
        local integer nameKey
        loop
            exitwhen IndexCursor > finish
            set card = IndexCursor
            set nameKey = StringHash(ProtoCardName[card])
            set first = LoadInteger(CharacterIndex, ProtoCardHead[card], nameKey)
            set character = first
            loop
                exitwhen character == 0 or ProtoCardName[character] == ProtoCardName[card]
                set character = CharacterNext[character]
            endloop
            if character == 0 then
                set character = card
                set CharacterNext[card] = first
                call SaveInteger(CharacterIndex, ProtoCardHead[card], nameKey, card)
            endif
            set ProtoCardCharacter[card] = character
            set IndexCursor = IndexCursor + 1
        endloop
    endfunction

    function ProtoOwnsCharacter takes integer pid, integer card returns boolean
        return ProtoCharacterOwned[ExpKey(pid, ProtoCardCharacter[card])]
    endfunction

    function ProtoIsInventoryCard takes integer pid, integer card returns boolean
        return ProtoCardCharacter[card] == card and ProtoCharacterOwned[ExpKey(pid, card)]
    endfunction

    function ProtoOwnedCardGrade takes integer pid, integer card returns integer
        local integer grade = ProtoCharacterGrade[ExpKey(pid, ProtoCardCharacter[card])]
        if grade == 0 then
            return ProtoCardGrade[card]
        endif
        return grade
    endfunction

    function ProtoRewardGrade takes integer pid, integer card, boolean mainStory returns integer
        if not ProtoOwnsCharacter(pid, card) then
            return ProtoCardGrade[card]
        endif
        if mainStory then
            return IMaxBJ(ProtoOwnedCardGrade(pid, card), ProtoCardGrade[card])
        endif
        return ProtoOwnedCardGrade(pid, card)
    endfunction

    function ProtoCardFrame takes integer grade returns string
        if grade == 4 then
            return "war3mapImported\\UI_Card_Frame_Prism.tga"
        elseif grade == 3 then
            return "war3mapImported\\UI_Card_Frame_Epic.tga"
        elseif grade == 2 then
            return "war3mapImported\\UI_Card_Frame_Rare.tga"
        endif
        return "war3mapImported\\UI_Card_Frame_Normal.tga"
    endfunction

    // 검토한 캐릭터 아이콘을 공유하고 미등록 캐릭터는 기존 지역 아이콘을 사용한다.
    function ProtoCardArt takes integer card returns string
        local string value = ProtoCharacterIconPath[ProtoCardCharacter[card]]
        if value != null and value != "" then
            return value
        elseif ProtoCardHead[card] > 0 then
            return ProtoHeadIcon[ProtoCardHead[card]]
        endif
        return "ReplaceableTextures\\CommandButtons\\BTNTome.blp"
    endfunction

    // 작은 아이콘과 큰 일러스트를 분리한다. 아직 준비하지 않은 캐릭터는 빈 경로를 반환한다.
    function ProtoCardIllustration takes integer card returns string
        local string value = ProtoCharacterArtPath[ProtoCardCharacter[card]]
        if value != null and value != "" then
            return value
        endif
        return ""
    endfunction

    // 선택한 보상의 증분만 25개 슬롯에 더한다. 보유 카드 전체를 재계산하지 않는다.
    function ProtoStatAddCard takes integer pid, integer card, boolean evolved returns nothing
        local integer kind = 1
        local integer character = ProtoCardCharacter[card]
        local real value
        loop
            exitwhen kind > PROTO_STAT_LAST
            if evolved then
                set value = LoadReal(ProtoEffectData, card, kind + 32) * ProtoRewardCopies[ExpKey(pid, card)]
            else
                set value = LoadReal(ProtoEffectData, card, kind)
                if ProtoEvolved[ExpKey(pid, card)] then
                    set value = value + LoadReal(ProtoEffectData, card, kind + 32)
                endif
            endif
            if value != 0.0 then
                set ProtoStatValues[pid * 32 + kind] = ProtoStatValues[pid * 32 + kind] + value
                call SaveReal(ProtoCharacterEffects, pid, character * 32 + kind, LoadReal(ProtoCharacterEffects, pid, character * 32 + kind) + value)
            endif
            set kind = kind + 1
        endloop
        if evolved then
            set ProtoCharacterEvolved[ExpKey(pid, character)] = true
        endif
    endfunction

    // 원본 인물/도감 ID는 유지하고 공개 여부만 플레이어별로 관리한다.
    function ProtoDisplayCardName takes integer pid, integer card returns string
        local integer rule = ProtoStoryChangeForCharacter[ProtoCardCharacter[card]]
        if rule > 0 and LoadInteger(ProtoStoryChangeState, pid, rule) > 0 then
            return ProtoStoryChangeName[rule]
        endif
        return ProtoCardName[card]
    endfunction

    function ProtoStoryChangeDescription takes integer pid, integer card returns string
        local integer rule = ProtoStoryChangeForCharacter[ProtoCardCharacter[card]]
        if rule > 0 and LoadInteger(ProtoStoryChangeState, pid, rule) > 0 then
            return ProtoStoryChangeDescriptionText[rule]
        endif
        return ""
    endfunction

    // 생성기가 계산한 설명 줄 수에 본문과의 구분 여백을 더한다.
    function ProtoStoryChangeLineCount takes integer pid, integer card returns integer
        local integer rule = ProtoStoryChangeForCharacter[ProtoCardCharacter[card]]
        if rule > 0 and LoadInteger(ProtoStoryChangeState, pid, rule) > 0 then
            return ProtoStoryChangeDescriptionLines[rule] + 2
        endif
        return 0
    endfunction

    function ProtoStoryChangeEffectsText takes integer rule returns string
        local integer kind = 1
        local real value
        local string result = ""
        loop
            exitwhen kind > PROTO_STAT_LAST
            set value = LoadReal(ProtoStoryChangeEffects, rule, kind)
            if value != 0.0 then
                if result != "" then
                    set result = result + "|n"
                endif
                set result = result + ProtoEffectText(kind, value)
            endif
            set kind = kind + 1
        endloop
        return result
    endfunction

    // 인물별 역색인으로 하나의 대기 규칙만 확인한다. 재획득은 보너스를 중복 적용하지 않는다.
    function ProtoApplyPendingStoryChange takes integer pid, integer card returns string
        local integer character = ProtoCardCharacter[card]
        local integer rule = ProtoStoryChangeForCharacter[character]
        local integer kind = 1
        local real value
        if rule == 0 or LoadInteger(ProtoStoryChangeState, pid, rule) != 1 or not ProtoOwnsCharacter(pid, card) then
            return ""
        endif
        call SaveInteger(ProtoStoryChangeState, pid, rule, 2)
        loop
            exitwhen kind > PROTO_STAT_LAST
            set value = LoadReal(ProtoStoryChangeEffects, rule, kind)
            if value != 0.0 then
                set ProtoStatValues[pid * 32 + kind] = ProtoStatValues[pid * 32 + kind] + value
                call SaveReal(ProtoCharacterEffects, pid, character * 32 + kind, LoadReal(ProtoCharacterEffects, pid, character * 32 + kind) + value)
            endif
            set kind = kind + 1
        endloop
        set ProtoCardRevision[pid] = ProtoCardRevision[pid] + 1
        return "|n[서사 변화] " + ProtoStoryChangeName[rule] + "|n" + ProtoStoryChangeDescriptionText[rule] + "|n" + ProtoStoryChangeEffectsText(rule)
    endfunction

    function ProtoStoryChangePreview takes integer pid, integer card returns string
        local integer rule = ProtoStoryChangeForCharacter[ProtoCardCharacter[card]]
        if rule > 0 and LoadInteger(ProtoStoryChangeState, pid, rule) == 1 then
            return "|n[서사 변화 추가 효과 · 최초 획득 시] |n" + ProtoStoryChangeEffectsText(rule)
        endif
        return ""
    endfunction

    // 성공한 사건에 연결된 규칙만 해금한다. 미보유 인물은 이후 획득 때 적용한다.
    function ProtoUnlockStoryChanges takes integer pid, integer eventId returns string
        local integer rule = ProtoStoryChangeFirst[eventId]
        local string result = ""
        loop
            exitwhen rule == 0
            if LoadInteger(ProtoStoryChangeState, pid, rule) == 0 then
                call SaveInteger(ProtoStoryChangeState, pid, rule, 1)
                set ProtoCardRevision[pid] = ProtoCardRevision[pid] + 1
                if not ProtoOwnsCharacter(pid, ProtoStoryChangeCharacter[rule]) then
                    set result = result + "|n[정체 공개] " + ProtoStoryChangeName[rule] + " · 카드 획득 시 추가 효과 적용"
                endif
            endif
            set result = result + ProtoApplyPendingStoryChange(pid, ProtoStoryChangeCharacter[rule])
            set rule = ProtoStoryChangeNext[rule]
        endloop
        return result
    endfunction

    function ProtoResetStoryChanges takes integer pid returns nothing
        call FlushChildHashtable(ProtoStoryChangeState, pid)
    endfunction

    function ProtoAddCharacterReward takes integer pid, integer card, boolean mainStory returns nothing
        local integer key = ExpKey(pid, ProtoCardCharacter[card])
        set ProtoCharacterGrade[key] = ProtoRewardGrade(pid, card, mainStory)
        if ProtoCharacterOwned[key] then
            set ProtoCardStacks[key] = ProtoCardStacks[key] + 1
        else
            set ProtoCharacterOwned[key] = true
            set ProtoCardStacks[key] = 0
        endif
        call ProtoStatAddCard(pid, card, false)
        set ProtoCardRevision[pid] = ProtoCardRevision[pid] + 1
    endfunction

    function ProtoCharacterEffectsText takes integer pid, integer card returns string
        local integer character = ProtoCardCharacter[card]
        local integer kind = 1
        local real value
        local string result = ""
        loop
            exitwhen kind > PROTO_STAT_LAST
            set value = LoadReal(ProtoCharacterEffects, pid, character * 32 + kind)
            if value != 0.0 then
                if result != "" then
                    set result = result + "|n"
                endif
                set result = result + ProtoEffectText(kind, value)
            endif
            set kind = kind + 1
        endloop
        return result
    endfunction

    function ProtoCharacterEffectCount takes integer pid, integer card returns integer
        local integer character = ProtoCardCharacter[card]
        local integer kind = 1
        local integer count = 0
        loop
            exitwhen kind > PROTO_STAT_LAST
            if LoadReal(ProtoCharacterEffects, pid, character * 32 + kind) != 0.0 then
                set count = count + 1
            endif
            set kind = kind + 1
        endloop
        return count
    endfunction

    private function ProtoGrowthInit takes nothing returns nothing
        loop
            exitwhen IndexCursor > PROTO_CARD_LAST
            call ExecuteFunc("ProtoGrowthIndexChunk")
        endloop
    endfunction
endlibrary
