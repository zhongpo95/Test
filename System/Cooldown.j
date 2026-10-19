library Cooldown requires TriggerSleepActionByTimer
    // 쿨타임 가속. 원정 카드 가속은 카드 획득 즉시 반영되도록 매번 더한다. 300(재사용 75% 감소)에서 멈춘다.
    function CooldownHaste takes integer pid returns real
        local real haste = Stat_CooldownHaste[pid]
        if ExpPrototypeActive and ExpMember[pid] then
            set haste = haste + ProtoStatValues[pid * PROTO_STAT_STRIDE + PROTO_STAT_COOLDOWN]
        endif
        return RMinBJ(300.00, RMaxBJ(0.00, haste))
    endfunction

    // 쿨타임 가속이 줄여 주는 재사용 시간 비율(%)
    function CooldownReduction takes integer pid returns real
        return 100.00 - 10000.00 / (100.00 + CooldownHaste(pid))
    endfunction

    // 대시 충전 시간 감소(%). 원정 카드 수치는 카드 획득 즉시 반영되도록 매번 더한다. 50%에서 멈춘다.
    function DashCooldownReduction takes integer pid returns real
        local real reduction = Stat_DashCooldown[pid]
        if ExpPrototypeActive and ExpMember[pid] then
            set reduction = reduction + ProtoStatValues[pid * PROTO_STAT_STRIDE + PROTO_STAT_DASH_COOLDOWN]
        endif
        return RMinBJ(50.00, RMaxBJ(0.00, reduction))
    endfunction

    function DashCoolTime takes unit caster, real baseTime returns real
        return baseTime * (100.00 - DashCooldownReduction(GetPlayerId(GetOwningPlayer(caster)))) / 100.00
    endfunction

    function GemCooldownReduction takes integer pid returns real
        return Equip_GemCooldown[pid]
    endfunction

    function CooldownRate takes integer pid returns real
        local real swiftnessCooldownRate = (100.00 - CooldownReduction(pid)) / 100.00
        local real gemCooldownRate = (100.00 - GemCooldownReduction(pid)) / 100.00
        return swiftnessCooldownRate * gemCooldownRate
    endfunction

    function CooldownFIX takes unit caster, integer abilId, real cooldown returns nothing
        call TriggerSleepActionByTimer(0)
        call JNStartUnitAbilityCooldown(caster, abilId, cooldown * CooldownRate(GetPlayerId(GetOwningPlayer(caster))) )
    endfunction
    function CooldownFIX2 takes unit caster, integer abilId, real cooldown returns nothing
        call JNStartUnitAbilityCooldown(caster, abilId, cooldown * CooldownRate(GetPlayerId(GetOwningPlayer(caster))) )
    endfunction
    function CooldownSet takes unit caster, integer abilId, real cooldown returns nothing
        call JNStartUnitAbilityCooldown(caster, abilId, cooldown )
    endfunction
endlibrary

