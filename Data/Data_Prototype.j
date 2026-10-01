// 개인 사냥 카드의 표시, 실제 피해 기록과 사건 선택 키를 관리한다.
library DataPrototype requires DataPrototypeCatalog, DataPrototypeStats
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
        local integer id = PROTO_CARD_FIRST
        if ProtoHuntOwner[targetIndex] != pid + 1 or amount <= 0 then
            return
        endif
        set ProtoDamage[pid] = ProtoDamage[pid] + amount
        loop
            exitwhen id > PROTO_CARD_LAST
            if ExpCardOwned[ExpKey(pid, id)] and ProtoEvolutionKind[id] == 2 and not ProtoEvolved[ExpKey(pid, id)] then
                set ProtoCardProgress[ExpKey(pid, id)] = ProtoCardProgress[ExpKey(pid, id)] + amount
            endif
            set id = id + 1
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
