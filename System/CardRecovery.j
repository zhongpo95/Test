// 실제 피해 흡수와 재생을 공유 주기로 처리하고 합산 초당 최대 체력 10%로 제한한다.
library CardRecovery initializer ProtoRecoveryInit requires DataPrototypeStats, UIHP
    globals
        private timer RecoveryClock = CreateTimer()
        private integer array RecoveryStep
        private real array RecoveryRate
        private real array RecoveryExpiryRate
        private real array RecoveryExpiryTail
    endglobals

    function ProtoClearRecovery takes integer pid returns nothing
        local integer i = 0
        loop
            exitwhen i == 51
            set RecoveryExpiryRate[pid * 64 + i] = 0.0
            set RecoveryExpiryTail[pid * 64 + i] = 0.0
            set i = i + 1
        endloop
        set RecoveryRate[pid] = 0.0
        set RecoveryStep[pid] = 0
    endfunction

    // 한 타격은 최대 체력 10%를 저장하고 초당 2% 속도로 최대 5초 동안 흡수한다.
    // 같은 만료 주기의 타격은 합산한다. 타격마다 타이머나 인스턴스 핸들을 만들지 않는다.
    function ProtoLeechHit takes integer pid, unit source, real actualDamage returns nothing
        local real maximum
        local real amount
        local real rate
        local integer ticks
        local integer key
        if pid < 0 or pid >= 4 or not ExpPrototypeActive or not ExpMember[pid] or source != MainUnit[pid] or ProtoPaused[pid] or ProtoReady[pid] or not UnitAlive(source) or actualDamage <= 0.0 then
            return
        endif
        set maximum = GetUnitState(source, UNIT_STATE_MAX_LIFE)
        if maximum <= 0.0 then
            return
        endif
        if GetUnitState(source, UNIT_STATE_LIFE) >= maximum then
            call ProtoClearRecovery(pid)
            return
        endif
        set amount = RMinBJ(maximum * 0.10, actualDamage * RMaxBJ(0.0, ProtoStat(pid, PROTO_STAT_LEECH)) / 100.0)
        if amount <= 0.0 then
            return
        endif
        set rate = maximum * 0.002
        set ticks = R2I(amount / rate)
        if I2R(ticks) * rate < amount then
            set ticks = ticks + 1
        endif
        set ticks = IMinBJ(50, IMaxBJ(1, ticks))
        set key = pid * 64 + ModuloInteger(RecoveryStep[pid] + ticks, 51)
        set RecoveryExpiryRate[key] = RecoveryExpiryRate[key] + rate
        set RecoveryExpiryTail[key] = RecoveryExpiryTail[key] + RMaxBJ(0.0, amount - rate * (ticks - 1))
        set RecoveryRate[pid] = RecoveryRate[pid] + rate
    endfunction

    function ProtoRecoveryTick takes nothing returns nothing
        local integer pid = 0
        local integer key
        local real maximum
        local real life
        local real amount
        loop
            exitwhen pid == 4
            if not ExpPrototypeActive or not ExpMember[pid] or (ExpState != EXP_HUNT and ExpState != EXP_BATTLE) or not UnitAlive(MainUnit[pid]) then
                call ProtoClearRecovery(pid)
            elseif not ProtoPaused[pid] and not ProtoReady[pid] then
                set maximum = GetUnitState(MainUnit[pid], UNIT_STATE_MAX_LIFE)
                set life = GetUnitState(MainUnit[pid], UNIT_STATE_LIFE)
                if life >= maximum or maximum <= 0.0 then
                    call ProtoClearRecovery(pid)
                else
                    set RecoveryStep[pid] = ModuloInteger(RecoveryStep[pid] + 1, 51)
                    set key = pid * 64 + RecoveryStep[pid]
                    set amount = RMaxBJ(0.0, RecoveryRate[pid] - RecoveryExpiryRate[key] + RecoveryExpiryTail[key])
                    set RecoveryRate[pid] = RMaxBJ(0.0, RecoveryRate[pid] - RecoveryExpiryRate[key])
                    set RecoveryExpiryRate[key] = 0.0
                    set RecoveryExpiryTail[key] = 0.0
                    set amount = amount + maximum * RMaxBJ(0.0, ProtoStat(pid, PROTO_STAT_REGEN)) * 0.001
                    // 0.1초 주기마다 최대 체력의 1%. 포션은 이 함수를 거치지 않는다.
                    set amount = RMinBJ(maximum * 0.01, amount)
                    if amount > 0.0 then
                        call SetUnitState(MainUnit[pid], UNIT_STATE_LIFE, RMinBJ(maximum, life + amount))
                        call RefreshHP(MainUnit[pid])
                    endif
                    if life + amount >= maximum then
                        call ProtoClearRecovery(pid)
                    endif
                endif
            endif
            set pid = pid + 1
        endloop
    endfunction

    private function ProtoRecoveryInit takes nothing returns nothing
        call TimerStart(RecoveryClock, 0.1, true, function ProtoRecoveryTick)
    endfunction
endlibrary
