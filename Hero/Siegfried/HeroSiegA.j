// 지크프리트 A: 마니강스 (자기 버프)
// 공격력(장비 기본 공격력의 30%)과 받는 피해 20% 감소, 저스트 판정 창 +0.05초를 15초간 얻는다.
scope HeroSiegA
globals
    private constant real HitTime = 0.60
    private constant real Lock = 0.90
    private constant real Duration = 15.0
    private constant real AttackRate = 0.30
    private constant real Reduce = 20.0
    private constant real WindowBonus = 0.05
    private real array AddedDamage
    private integer array BuffSerial
    private effect array BuffEffect
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

private struct BuffEnd
    integer pid
    integer serial
    method destroy takes nothing returns nothing
        call deallocate()
    endmethod
endstruct

private function Expire takes nothing returns nothing
    local tick t = tick.getExpired()
    local BuffEnd b = t.data
    local integer pid = b.pid
    if b.serial == BuffSerial[pid] then
        set Hero_Damage[pid] = Hero_Damage[pid] - AddedDamage[pid]
        set AddedDamage[pid] = 0
        set HeroDamageReduce[pid] = HeroDamageReduce[pid] - Reduce
        set SiegWinBonus[pid] = 0
        if BuffEffect[pid] != null then
            call DestroyEffect(BuffEffect[pid])
            set BuffEffect[pid] = null
        endif
        call ItemUIStatsSet(pid)
    endif
    call b.destroy()
    call t.destroy()
endfunction

private function ApplyEnd takes integer pid returns nothing
    local BuffEnd b = BuffEnd.create()
    local tick t
    set BuffSerial[pid] = BuffSerial[pid] + 1
    set b.pid = pid
    set b.serial = BuffSerial[pid]
    set t = tick.create(b)
    call t.start(Duration, false, function Expire)
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
        if AddedDamage[pid] == 0 then
            set AddedDamage[pid] = R2I(Equip_Damage[pid]) * AttackRate
            set Hero_Damage[pid] = Hero_Damage[pid] + AddedDamage[pid]
            set HeroDamageReduce[pid] = HeroDamageReduce[pid] + Reduce
            set SiegWinBonus[pid] = WindowBonus
            set BuffEffect[pid] = AddSpecialEffectTarget("Buff_Attack.mdl", u, "origin")
            call ItemUIStatsSet(pid)
        endif
        call ApplyEnd(pid)
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

    if GetSpellAbilityId() == 'A0SA' then
        set u = GetTriggerUnit()
        set fx = FxEffect.create()
        set fx.caster = u
        set fx.pid = GetPlayerId(GetOwningPlayer(u))
        set fx.speed = SiegSpeed(fx.pid)
        call SiegFace(u, GetSpellTargetX(), GetSpellTargetY())
        call SiegResetCombo(fx.pid)
        set fx.serial = SiegSerial[fx.pid]
        set SiegBusy[fx.pid] = true
        call CooldownFIX(u, 'A0SA', HeroSkillCD4[SIEG_INDEX])
        call SiegLock(u, Lock / fx.speed)
        call SiegAnim(u, 135, fx.speed)
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

    if SiegIsHero(u) and SiegCanAct(u) and not SiegBusy[pid] and EXGetAbilityState(EXGetUnitAbility(u, HeroSkillID4[SIEG_INDEX]), ABILITY_STATE_COOLDOWN) == 0 then
        call SiegUnlock(GetPlayerId(GetOwningPlayer(u)))
        call SiegFace(u, SiegSplitReal(data, 0), SiegSplitReal(data, 1))
        call IssuePointOrder(u, "ancestralspirittarget", SiegSplitReal(data, 0), SiegSplitReal(data, 1))
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
        call DzTriggerRegisterSyncData(t, ("SiegA"), (false))
        call TriggerAddAction(t, function SyncData)
        set t = null
    endmethod
endstruct
endscope
