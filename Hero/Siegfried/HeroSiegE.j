// 지크프리트 E: 롱브르 디에르 (키다운 방어)
// 키를 누르는 동안 방어 자세를 취하고 받는 피해가 80% 줄어든다(SIEG_GUARD_REDUCE). 떼면 자세만 풀린다(반격 없음).
scope HeroSiegE
globals
    private constant real MaxHold = 1.50
    private integer array HoldSerial
    private boolean array Held
    // 짧게 눌러도 최소 이 시간은 자세를 유지한다.
    private constant real MinHold = 0.20
endglobals

private struct FxEffect
    unit caster
    integer pid
    integer serial
    real speed
    real start
    real until

    method destroy takes nothing returns nothing
        set caster = null
        call deallocate()
    endmethod
endstruct

// 자세를 푼다. 키를 떼거나 최대 유지 시간이 지나면 호출된다.
private function Release takes integer pid returns nothing
    local unit u = MainUnit[pid]

    if not SiegStance[pid] then
        set u = null
        return
    endif
    set SiegStance[pid] = false
    set SiegBusy[pid] = false
    set HoldSerial[pid] = HoldSerial[pid] + 1
    call SiegGuardSet(pid, false)
    call SiegUnlock(pid)
    call SetUnitAnimation(u, "stand")
    set u = null
endfunction

private function HoldTick takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data
    local unit u = fx.caster

    if fx.serial != HoldSerial[fx.pid] or not SiegStance[fx.pid] then
        // 회피 등으로 자세가 이미 풀렸다(감소는 거기서 해제됨).
        set u = null
        call fx.destroy()
        call t.destroy()
        return
    endif
    if not SiegCanAct(u) then
        set SiegStance[fx.pid] = false
        set SiegBusy[fx.pid] = false
        call SiegGuardSet(fx.pid, false)
        set u = null
        call fx.destroy()
        call t.destroy()
        return
    endif
    if SiegNow() >= fx.until or (not Held[fx.pid] and SiegNow() >= fx.start + MinHold) then
        set u = null
        call Release(fx.pid)
        call fx.destroy()
        call t.destroy()
        return
    endif
    // 자세 유지 모션(#141, 1초)을 반복한다.
    if fx.speed <= 0 then
        // 자세 유지 모션(#141)은 첫 틱과 이후 1초마다 다시 건다.
        call AnimationStart3(u, 141, 1.0)
        set fx.speed = 1.0
    else
        set fx.speed = fx.speed - 0.1
    endif
    call SiegLock(u, 0.15)
    call t.start(0.10, false, function HoldTick)
    set u = null
endfunction

private function Main takes nothing returns nothing
    local unit u
    local integer pid
    local FxEffect fx
    local tick t

    if GetSpellAbilityId() == 'A0SE' then
        set u = GetTriggerUnit()
        set pid = GetPlayerId(GetOwningPlayer(u))
        call SiegFace(u, GetSpellTargetX(), GetSpellTargetY())
        call SiegResetCombo(pid)
        set SiegBusy[pid] = true
        set SiegStance[pid] = true
        call SiegGuardSet(pid, true)
        set HoldSerial[pid] = HoldSerial[pid] + 1
        call CooldownFIX(u, 'A0SE', HeroSkillCD2[SIEG_INDEX])
        call BuffNoST.Apply(u, MaxHold + 0.2, 0)
        call BuffNoNB.Apply(u, MaxHold + 0.2, 0)
        call SiegLock(u, 0.55)
        call SiegAnim(u, 140, 1.0)

        set fx = FxEffect.create()
        set fx.caster = u
        set fx.pid = pid
        set fx.serial = HoldSerial[pid]
        set fx.speed = 0
        set fx.start = SiegNow()
        set fx.until = fx.start + MaxHold
        set t = tick.create(fx)
        call t.start(0.083, false, function HoldTick)
        set u = null
    endif
endfunction

private function ESyncData takes nothing returns nothing
    local player p = DzGetTriggerSyncPlayer()
    local string data = DzGetTriggerSyncData()
    local integer pid = GetPlayerId(p)
    local unit u = MainUnit[pid]

    if SiegIsHero(u) and SiegCanAct(u) and not SiegBusy[pid] and EXGetAbilityState(EXGetUnitAbility(u, HeroSkillID2[SIEG_INDEX]), ABILITY_STATE_COOLDOWN) == 0 then
        set Held[pid] = true
        call SiegUnlock(GetPlayerId(GetOwningPlayer(u)))
        call SiegFace(u, SiegSplitReal(data, 0), SiegSplitReal(data, 1))
        call IssuePointOrder(u, "ambush", SiegSplitReal(data, 0), SiegSplitReal(data, 1))
    endif
    set u = null
    set p = null
endfunction

private function ESyncData2 takes nothing returns nothing
    local integer pid = GetPlayerId(DzGetTriggerSyncPlayer())
    set Held[pid] = false
endfunction

private struct TEvAfterB extends array
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t, function thistype.Action)
        call TriggerRegisterTimerEvent(t, 2.0, false)
        set t = null
    endmethod
    private static method Action takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddAction(t, function Main)
        set t = CreateTrigger()
        call DzTriggerRegisterSyncData(t, ("SiegE"), (false))
        call TriggerAddAction(t, function ESyncData)
        set t = CreateTrigger()
        call DzTriggerRegisterSyncData(t, ("SiegE2"), (false))
        call TriggerAddAction(t, function ESyncData2)
        set t = null
    endmethod
endstruct
endscope
