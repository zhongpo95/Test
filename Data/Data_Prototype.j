// 개인 사냥 카드의 표시, 실제 피해 기록과 사건 선택 키를 관리한다.
library DataPrototype requires DataPrototypeCatalog, DataPrototypeStats
    globals
        // 플레이어별 처치(1), 피해(2), 무피격(3) 조건의 보유 미각성 카드만 연결한다.
        integer array ProtoEvolutionFirst
        integer array ProtoEvolutionNext
    endglobals

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
        local string value = "[" + ProtoCardKeyword[id] + "] " + ProtoCardEffectName[id] + "|n"
        set value = value + ProtoCardEffectsText(id, ProtoEvolved[ExpKey(pid, id)])
        if ProtoEvolutionKind[id] > 0 then
            if ProtoEvolved[ExpKey(pid, id)] then
                set value = value + "|n|cffc781ff각성 완료|r"
            elseif ProtoEvolutionKind[id] == 1 then
                set value = value + "|n각성 목표 · 획득 후 처치 " + I2S(R2I(ProtoCardProgress[ExpKey(pid, id)])) + "/" + I2S(R2I(ProtoEvolutionGoal[id]))
            elseif ProtoEvolutionKind[id] == 2 then
                set value = value + "|n각성 목표 · 실제 누적 피해 " + I2S(R2I(ProtoCardProgress[ExpKey(pid, id)])) + "/" + I2S(R2I(ProtoEvolutionGoal[id]))
            else
                set value = value + "|n각성 목표 · 연속 무피격 " + I2S(R2I(ProtoCardProgress[ExpKey(pid, id)])) + "/" + I2S(R2I(ProtoEvolutionGoal[id])) + "초"
            endif
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

    // 카드와 사건은 각각 최대 1023개까지 플레이어 키가 충돌하지 않는다.
    function ProtoStoryKey takes integer pid, integer id returns integer
        return pid * 1024 + id
    endfunction

    function ProtoChoiceKey takes integer id, integer choice returns integer
        return id * 4 + choice - 1
    endfunction
endlibrary
