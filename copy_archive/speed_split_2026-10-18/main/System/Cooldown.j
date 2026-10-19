library Cooldown requires TriggerSleepActionByTimer
    function CooldownReduction takes integer pid returns real
        if Equip_Swiftness[pid] / 46.00 > 75.00 then
            return 75.00
        endif
        return Equip_Swiftness[pid] / 46.00
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

