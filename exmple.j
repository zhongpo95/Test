function Trig_Damage_AuraACB_Actions takes nothing returns nothing
    local integer pid = GetConvertedPlayerId(GetTriggerPlayer())
    local unit u = udg_DummyPoint[pid]
    local integer i = GetUnitPointValue(u)
    local integer a
    
    if i < 400 then
        set a = i / 100 + 1
        if a > udg_AuraC[pid] then
            set udg_AuraC[pid] = a
        endif
        return
    endif

    set a = (i / 100 - 1) / 3 + 3

    if ModuloInteger(i, 300) == 110 and a > udg_AuraA[pid] then
        set udg_AuraA[pid] = a
    endif

    if ModuloInteger(i, 300) == 210 and a > udg_AuraB[pid] then
        set udg_AuraB[pid] = a
    endif

    if ModuloInteger(i, 300) == 10 and a > udg_AuraC[pid] then
        set udg_AuraC[pid] = a
    endif  
    
    set udg_AuraDamage[pid] = (0.05 * udg_AuraZ[pid] + 0.03 * (udg_AuraA[pid] + udg_AuraB[pid] + udg_AuraC[pid]))

endfunction

//===========================================================================
function InitTrig_Damage_AuraACB takes nothing returns nothing
    set gg_trg_Damage_AuraACB = CreateTrigger()
    call TriggerAddAction(gg_trg_Damage_AuraACB, function Trig_Damage_AuraACB_Actions)
endfunction