// 시험 원정 카드의 피해와 방어력 관통을 기존 전투에 적용한다.
library ExpeditionEffects requires DataExpedition, DataUnit, AttackAngle
    function ExpHasCard takes integer pid, integer id returns boolean
        return ExpMember[pid] and ExpCardOwned[ExpKey(pid, id)]
    endfunction

    function ExpCardPenetration takes integer pid returns real
        local real value = 0.0
        if ExpHasCard(pid, 7) then
            set value = value + 0.20
        endif
        if ExpHasCard(pid, 8) then
            set value = value + ExpGold[pid] * 0.0003
        endif
        return value
    endfunction

    function ExpCardDamage takes integer pid, unit source, unit target returns real
        local integer index = IndexUnit(target)
        local real value = 0.0
        local real health = 1.0
        local real dx = GetUnitX(source) - GetUnitX(target)
        local real dy = GetUnitY(source) - GetUnitY(target)
        local real distance = SquareRoot(dx * dx + dy * dy)
        local integer i = 0
        if UnitHPMAX[index] > 0 then
            set health = UnitHP[index] / UnitHPMAX[index]
        endif
        if ExpHasCard(pid, 2) and health >= 0.80 then
            set value = value + 40.0
        endif
        if ExpHasCard(pid, 3) and distance <= 400.0 then
            set value = value + 30.0
        endif
        if ExpHasCard(pid, 4) and health <= 0.30 then
            set value = value + 40.0
        endif
        if ExpHasCard(pid, 5) and distance >= 600.0 then
            set value = value + 30.0
        endif
        if ExpHasCard(pid, 6) and ExpGold[pid] <= 50 then
            set value = value + 30.0
        endif
        if ExpHasCard(pid, 7) and ExpSeconds <= ExpBattleLimit / 5 then
            set value = value + 40.0
        endif
        if ExpHasCard(pid, 9) then
            loop
                exitwhen i > 10
                if LoadInteger(ArcanaData, i, pid) >= 3 then
                    set value = value + 10.0
                endif
                set i = i + 1
            endloop
        endif
        if ExpHasCard(pid, 10) and GetUnitState(source, UNIT_STATE_LIFE) <= GetUnitState(source, UNIT_STATE_MAX_LIFE) * 0.35 then
            set value = value + 60.0
        endif
        return value
    endfunction

    // 원정에서는 일반 각인 피해를 카드와 같은 합연산 묶음에 넣는다.
    function ExpArcanaDamage takes integer pid, unit source, unit target, boolean head, boolean back, boolean charge returns real
        local real value = 0.0
        local real level
        local integer i = 0
        local integer lv
        local boolean directional = (head and HeadTrue(AngleWBW(source, target), GetUnitFacing(target))) or (back and BackTrue(AngleWBW(source, target), GetUnitFacing(target)))
        loop
            exitwhen i > 10
            set lv = IMinBJ(3, LoadInteger(ArcanaData, i, pid))
            set level = I2R(lv)
            if lv > 0 then
                if i == 0 or i == 3 or i == 4 or i == 8 then
                    if i == 0 or (i == 3 and not head and not back) or (i == 4 and UnitSD[IndexUnit(source)] > 0) or (i == 8 and GetUnitState(source, UNIT_STATE_LIFE) >= GetUnitState(source, UNIT_STATE_MAX_LIFE) * 0.65) then
                        set value = value + 8.0 + 3.0 * level
                    endif
                elseif i == 1 then
                    set value = value + RMaxBJ(0.0, GetUnitMoveSpeed(source) / 4.0 - 100.0) * (0.24 + 0.08 * level)
                elseif i == 2 then
                    if lv == 1 then
                        set value = value + 4.0
                    elseif lv == 2 then
                        set value = value + 4.8
                    else
                        set value = value + 7.6
                    endif
                    if directional then
                        if lv == 1 then
                            set value = value + 12.0
                        else
                            set value = value + 15.0
                        endif
                    endif
                elseif i == 5 and charge then
                    if lv == 3 then
                        set value = value + 21.0
                    else
                        set value = value + 14.0 + 2.0 * level
                    endif
                elseif i == 6 then
                    if lv == 3 then
                        set value = value + 19.0
                    else
                        set value = value + 10.0 + 3.0 * level
                    endif
                elseif i == 9 then
                    // 현재 각인 설명의 8/11/14%와 맞춘다.
                    set value = value + 5.0 + 3.0 * level
                endif
            endif
            set i = i + 1
        endloop
        return value
    endfunction
endlibrary
