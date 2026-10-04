// 사건별 보상 이력을 유지하면서 같은 지역의 캐릭터 카드 효과와 희귀도를 누적한다.
library DataPrototypeGrowth initializer ProtoGrowthInit requires DataPrototypeCatalog
    globals
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

    // 먼저 검토한 두 캐릭터 이미지를 공유한다. 나머지는 기존 지역 아이콘을 사용한다.
    function ProtoCardArt takes integer card returns string
        if ProtoCardName[card] == "미샤" then
            return "war3mapImported\\UI_Card_Misha.tga"
        elseif ProtoCardName[card] == "이자요이 노노미" then
            return "war3mapImported\\UI_Card_Nonomi.tga"
        elseif ProtoCardHead[card] > 0 then
            return ProtoHeadIcon[ProtoCardHead[card]]
        endif
        return "ReplaceableTextures\\CommandButtons\\BTNTome.blp"
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
