// 지크프리트 S: 르 미라주 (아군 보호막)
// 자신과 주변 아군에게 시전자 최대 생명력 30%의 보호막을 10초간 부여한다.
scope HeroSiegS
globals
    private constant real HitTime = 0.70
    private constant real Lock = 1.00
    private constant real Radius = 1200
    private constant real ShieldRate = 0.30
    private constant real Duration = 10.0
    private real ShieldValue = 0
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

private function splashA takes nothing returns nothing
    call ShieldAdd(GetEnumUnit(), Duration, ShieldValue)
    call UnitEffectTimeEX2('e03S', GetWidgetX(GetEnumUnit()), GetWidgetY(GetEnumUnit()), 0, 1.5, GetPlayerId(GetOwningPlayer(splash.source)))
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data
    local unit u = fx.caster
    local integer pid = fx.pid

    // 회피로 끊겼으면(SiegSerial 변경) 아무것도 하지 않는다.
    if fx.serial == SiegSerial[pid] then
        set SiegBusy[pid] = false
    endif
    if fx.serial == SiegSerial[pid] and SiegCanAct(u) then
        set ShieldValue = GetUnitMaxLifeVJ(u) * ShieldRate
        call splash.range(splash.ALLY, u, GetWidgetX(u), GetWidgetY(u), Radius, function splashA)
        call CameraShaker.setShakeForPlayer(GetOwningPlayer(u), 6)
    endif
    set u = null
    call fx.destroy()
    call t.destroy()
endfunction

private function Main takes nothing returns nothing
    local unit u
    local FxEffect fx
    local tick t

    if GetSpellAbilityId() == 'A0SS' then
        set u = GetTriggerUnit()
        set fx = FxEffect.create()
        set fx.caster = u
        set fx.pid = GetPlayerId(GetOwningPlayer(u))
        set fx.speed = SiegSpeed(fx.pid)
        call SiegFace(u, GetSpellTargetX(), GetSpellTargetY())
        call SiegResetCombo(fx.pid)
        set fx.serial = SiegSerial[fx.pid]
        set SiegBusy[fx.pid] = true
        call CooldownFIX(u, 'A0SS', HeroSkillCD5[SIEG_INDEX])
        call SiegLock(u, Lock / fx.speed)
        call SiegAnim(u, 145, fx.speed)
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

    if SiegIsHero(u) and SiegCanAct(u) and not SiegBusy[pid] and EXGetAbilityState(EXGetUnitAbility(u, HeroSkillID5[SIEG_INDEX]), ABILITY_STATE_COOLDOWN) == 0 then
        call SiegUnlock(GetPlayerId(GetOwningPlayer(u)))
        call SiegFace(u, SiegSplitReal(data, 0), SiegSplitReal(data, 1))
        call IssuePointOrder(u, "animatedead", SiegSplitReal(data, 0), SiegSplitReal(data, 1))
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
        call DzTriggerRegisterSyncData(t, ("SiegS"), (false))
        call TriggerAddAction(t, function SyncData)
        set t = null
    endmethod
endstruct
endscope
