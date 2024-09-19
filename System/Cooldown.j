library Cooldown requires TriggerSleepActionByTimer
    function CooldownFIX takes unit caster, integer abilId, real cooldown returns nothing
        call TriggerSleepActionByTimer(0)
        call JNStartUnitAbilityCooldown(caster, abilId, cooldown * (100.00-(Equip_Swiftness[GetPlayerId(GetOwningPlayer(caster))]/46)) / 100 )
    endfunction
    function CooldownFIX2 takes unit caster, integer abilId, real cooldown returns nothing
        call JNStartUnitAbilityCooldown(caster, abilId, cooldown * (100.00-(Equip_Swiftness[GetPlayerId(GetOwningPlayer(caster))]/46)) / 100 )
    endfunction
endlibrary