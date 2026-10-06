// 지크프리트 Z: 용기 해방 (아이덴티티)
// 용기 10이 필요하다. 12초 동안 C가 모두 저스트로 판정되고 용기가 줄지 않는다. 끝나면 용기가 0이 된다.
scope HeroSiegZ
globals
    private constant real HitTime = 1.20
    private constant real Lock = 1.20
    private constant real Duration = 12.0
    private integer array ZSerial
    private effect array ZEffect
endglobals

private struct FxEffect
    unit caster
    integer pid
    integer serial
    real speed

    method destroy takes nothing returns nothing
        set caster = null
        call deallocate()
    endmethod
endstruct

private struct ZEnd
    integer pid
    integer serial
    method destroy takes nothing returns nothing
        call deallocate()
    endmethod
endstruct

private function Expire takes nothing returns nothing
    local tick t = tick.getExpired()
    local ZEnd b = t.data
    if b.serial == ZSerial[b.pid] then
        set SiegZOn[b.pid] = false
        set SiegStack[b.pid] = 0
        if ZEffect[b.pid] != null then
            call DestroyEffect(ZEffect[b.pid])
            set ZEffect[b.pid] = null
        endif
    endif
    call b.destroy()
    call t.destroy()
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data
    local unit u = fx.caster
    local integer pid = fx.pid
    local tick zt

    // 회피로 끊겼으면(SiegSerial 변경) 아무것도 하지 않는다.
    if fx.serial == SiegSerial[fx.pid] then
        set SiegBusy[pid] = false
    endif
    if fx.serial == SiegSerial[pid] and SiegCanAct(u) then
        set SiegZOn[pid] = true
        set ZSerial[pid] = ZSerial[pid] + 1
        if ZEffect[pid] == null then
            set ZEffect[pid] = AddSpecialEffectTarget("Abilities\\Spells\\Orc\\Bloodlust\\BloodlustTarget.mdl", u, "origin")
        endif
        set zt = tick.create(ZEnd.create())
        set ZEnd(zt.data).pid = pid
        set ZEnd(zt.data).serial = ZSerial[pid]
        call zt.start(Duration, false, function Expire)
        call CameraShaker.setShakeForPlayer(GetOwningPlayer(u), 14)
        call SiegFxAura(u, pid)
    endif
    set u = null
    call fx.destroy()
    call t.destroy()
endfunction

private function Main takes nothing returns nothing
    local unit u
    local FxEffect fx
    local tick t

    if GetSpellAbilityId() == 'A0SZ' then
        set u = GetTriggerUnit()
        set fx = FxEffect.create()
        set fx.caster = u
        set fx.pid = GetPlayerId(GetOwningPlayer(u))
        set fx.speed = SiegSpeed(fx.pid)
        call SiegFace(u, GetSpellTargetX(), GetSpellTargetY())
        call SiegResetCombo(fx.pid)
        set fx.serial = SiegSerial[fx.pid]
        set SiegBusy[fx.pid] = true
        call CooldownFIX(u, 'A0SZ', 4.0)
        call BuffNoDM.Apply(u, Lock / fx.speed, 0)
        call BuffNoST.Apply(u, Lock / fx.speed, 0)
        call BuffNoNB.Apply(u, Lock / fx.speed, 0)
        call SiegLock(u, Lock / fx.speed)
        call SiegAnim(u, 147, fx.speed)
        set t = tick.create(fx)
        call t.start(HitTime / fx.speed, false, function EffectFunction)
        set u = null
    endif
endfunction

private function SyncData takes nothing returns nothing
    local player p = DzGetTriggerSyncPlayer()
    local string data = DzGetTriggerSyncData()
    local integer pid = GetPlayerId(p)
    local unit u = MainUnit[pid]

    if SiegIsHero(u) and SiegCanAct(u) and not SiegBusy[pid] and EXGetAbilityState(EXGetUnitAbility(u, HeroSkillID10[SIEG_INDEX]), ABILITY_STATE_COOLDOWN) == 0 and SiegStack[pid] >= SIEG_MAX_STACK then
        call SiegUnlock(GetPlayerId(GetOwningPlayer(u)))
        call SiegFace(u, SiegSplitReal(data, 0), SiegSplitReal(data, 1))
        call IssuePointOrder(u, "autodispel", SiegSplitReal(data, 0), SiegSplitReal(data, 1))
    endif
    set u = null
    set p = null
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
        call DzTriggerRegisterSyncData(t, ("SiegZ"), (false))
        call TriggerAddAction(t, function SyncData)
        set t = null
    endmethod
endstruct
endscope
