// 개인 사냥 카드의 표시, 실제 피해 기록과 사건 선택 키를 관리한다.
library DataPrototype requires DataPrototypeGrowth
    globals
        // 플레이어별 처치(1), 피해(2), 무피격(3) 조건의 보유 미각성 카드만 연결한다.
        integer array ProtoEvolutionFirst
        integer array ProtoEvolutionNext
    endglobals

    function ProtoGradeColor takes integer grade returns string
        if grade == 4 then
            return "|cffb84ca5"
        elseif grade == 3 then
            return "|cff8042ad"
        elseif grade == 2 then
            return "|cff0877ae"
        endif
        return "|cff315a70"
    endfunction

    function ProtoEvolutionReset takes integer pid returns nothing
        local integer kind = 1
        loop
            exitwhen kind > 3
            set ProtoEvolutionFirst[pid * 4 + kind] = 0
            set kind = kind + 1
        endloop
    endfunction

    // 최초 획득 경로에서 한 번만 등록한다. 새 원정은 시작점만 비우고 다음 획득 때 링크를 덮어쓴다.
    function ProtoEvolutionRegister takes integer pid, integer card returns nothing
        local integer kind = ProtoEvolutionKind[card]
        if kind >= 1 and kind <= 3 then
            set ProtoEvolutionNext[ExpKey(pid, card)] = ProtoEvolutionFirst[pid * 4 + kind]
            set ProtoEvolutionFirst[pid * 4 + kind] = card
        endif
    endfunction

    function ProtoCardText takes integer pid, integer id returns string
        local integer character = ProtoCardCharacter[id]
        local integer key = ExpKey(pid, character)
        local string value = "강화 +" + I2S(ProtoCardStacks[key]) + " · 누적 보상 " + I2S(ProtoCardStacks[key] + 1) + "회|n"
        if ProtoCardEnding[id] == 1 then
            return ProtoCardDescription[id] + "|n|n엔딩 기념 카드 · 전투 효과 미설정"
        endif
        set value = value + "선택한 보상의 합산 효과|n" + ProtoCharacterEffectsText(pid, character)
        if ProtoStoryChangeDescription(pid, id) != "" then
            set value = value + "|n|n" + ProtoStoryChangeDescription(pid, id)
        endif
        if ProtoCharacterEvolved[key] then
            set value = value + "|n|cffc781ff각성 효과 적용|r"
        endif
        return value
    endfunction

    function ProtoCanHit takes integer pid, integer targetIndex returns boolean
        local integer owner = ProtoHuntOwner[targetIndex] - 1
        if ExpPrototypeActive and ExpMember[pid] and (ProtoPaused[pid] or ProtoReady[pid]) then
            return false
        endif
        if owner >= 0 then
            return ExpPrototypeActive and ExpState == EXP_HUNT and owner == pid and ExpMember[pid] and not ProtoPaused[pid] and not ProtoReady[pid]
        endif
        return true
    endfunction

    function ProtoRecordDamage takes integer pid, integer targetIndex, real amount returns nothing
        local integer id = ProtoEvolutionFirst[pid * 4 + 2]
        if ProtoHuntOwner[targetIndex] != pid + 1 or amount <= 0 then
            return
        endif
        set ProtoDamage[pid] = ProtoDamage[pid] + amount
        loop
            exitwhen id == 0
            set ProtoCardProgress[ExpKey(pid, id)] = ProtoCardProgress[ExpKey(pid, id)] + amount
            set id = ProtoEvolutionNext[ExpKey(pid, id)]
        endloop
    endfunction

    function ProtoResetSafeProgress takes integer pid returns nothing
        local integer id = ProtoEvolutionFirst[pid * 4 + 3]
        loop
            exitwhen id == 0
            set ProtoCardProgress[ExpKey(pid, id)] = 0.0
            set id = ProtoEvolutionNext[ExpKey(pid, id)]
        endloop
    endfunction

    // 카드와 사건은 공통 간격을 사용하여 플레이어별 0~2047번이 겹치지 않는다.
    function ProtoStoryKey takes integer pid, integer id returns integer
        return ExpKey(pid, id)
    endfunction

    function ProtoChoiceKey takes integer id, integer choice returns integer
        return id * 4 + choice - 1
    endfunction
endlibrary
