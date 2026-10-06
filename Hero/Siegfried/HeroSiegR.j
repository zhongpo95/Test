// 지크프리트 R: 페어드렝겐 (충격파 + 방어력 감소)
scope HeroSiegR
globals
    private constant real Rate = 0.90
    private constant real Range = 450
    private constant real Scale = 900
    private constant real HitTime = 0.72
    private constant real DebuffTime = 10.0
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

private function splashD takes nothing returns nothing
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    if IsUnitInRangeXY(GetEnumUnit(), splash.x, splash.y, Range) then
        call SiegDeal('A0SR', splash.source, GetEnumUnit(), Rate, false)
        call DeBuffMArm.Apply(GetEnumUnit(), DebuffTime, 0)
        call SiegFxHit(GetWidgetX(GetEnumUnit()), GetWidgetY(GetEnumUnit()), pid)
    endif
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data
    local unit u = fx.caster
    local real f = GetUnitFacing(u)

    // 회피로 끊겼으면(SiegSerial 변경) 아무것도 하지 않는다.
    if fx.serial == SiegSerial[fx.pid] then
        set SiegBusy[fx.pid] = false
    endif
    if fx.serial == SiegSerial[fx.pid] and SiegCanAct(u) then
        call splash.range(splash.ENEMY, u, GetWidgetX(u) + PolarX(200, f), GetWidgetY(u) + PolarY(200, f), Scale, function splashD)
        // 페어드렝겐: 전방 직선으로 붉은 불꽃 가시벽이 솟는다
        call SiegFxAt(SIEG_FX_SHOCK, GetWidgetX(u) + PolarX(120, f), GetWidgetY(u) + PolarY(120, f), 0, 1.0, 0, 0, fx.pid)
        call SiegFxLine(SIEG_FX_SPIKES, GetWidgetX(u), GetWidgetY(u), f, 110, 560, 75, 1.0, 0.03, fx.pid)
        call CameraShaker.setShakeForPlayer(GetOwningPlayer(u), 12)
    endif
    set u = null
    call fx.destroy()
    call t.destroy()
endfunction

private function Main takes nothing returns nothing
    local unit u
    local FxEffect fx
    local tick t

    if GetSpellAbilityId() == 'A0SR' then
        set u = GetTriggerUnit()
        set fx = FxEffect.create()
        set fx.caster = u
        set fx.pid = GetPlayerId(GetOwningPlayer(u))
        set fx.speed = SiegSpeed(fx.pid)
        call SiegFace(u, GetSpellTargetX(), GetSpellTargetY())
        call SiegResetCombo(fx.pid)
        set fx.serial = SiegSerial[fx.pid]
        set SiegBusy[fx.pid] = true
        call CooldownFIX(u, 'A0SR', HeroSkillCD3[SIEG_INDEX])
        call SiegLock(u, (HitTime + 0.35) / fx.speed)
        call SiegAnimJust(u, 146, fx.speed, true)
        set t = tick.create(fx)
        call t.start(HitTime / fx.speed, false, function EffectFunction)
        set u = null
    endif
endfunction

private function RSyncData takes nothing returns nothing
    local player p = DzGetTriggerSyncPlayer()
    local string data = DzGetTriggerSyncData()
    local integer pid = GetPlayerId(p)
    local unit u = MainUnit[pid]

    if SiegIsHero(u) and SiegCanAct(u) and not SiegBusy[pid] and EXGetAbilityState(EXGetUnitAbility(u, HeroSkillID3[SIEG_INDEX]), ABILITY_STATE_COOLDOWN) == 0 then
        call SiegUnlock(GetPlayerId(GetOwningPlayer(u)))
        call SiegFace(u, SiegSplitReal(data, 0), SiegSplitReal(data, 1))
        call IssuePointOrder(u, "ancestralspirit", SiegSplitReal(data, 0), SiegSplitReal(data, 1))
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
        call DzTriggerRegisterSyncData(t, ("SiegR"), (false))
        call TriggerAddAction(t, function RSyncData)
        set t = null
    endmethod
endstruct
endscope
