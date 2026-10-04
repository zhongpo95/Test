// 지크프리트 D: 잘바토르 (자기 버프)
// 12초간 경직·넉백 면역과 지크프리트의 모든 피해 +15%를 얻는다.
scope HeroSiegD
globals
    private constant real HitTime = 0.60
    private constant real Lock = 1.00
    private constant real Duration = 12.0
    private constant real DamageBonus = 15.0
    private integer array BuffSerial
    private effect array BuffEffect
endglobals

private struct FxEffect
    unit caster
    integer pid
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
    if b.serial == BuffSerial[b.pid] then
        set SiegDmgBonus[b.pid] = 0
        if BuffEffect[b.pid] != null then
            call DestroyEffect(BuffEffect[b.pid])
            set BuffEffect[b.pid] = null
        endif
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

    set SiegBusy[pid] = false
    if SiegCanAct(u) then
        set SiegDmgBonus[pid] = DamageBonus
        call BuffNoST.Apply(u, Duration, 0)
        call BuffNoNB.Apply(u, Duration, 0)
        if BuffEffect[pid] == null then
            set BuffEffect[pid] = AddSpecialEffectTarget("Abilities\\Spells\\Human\\InnerFire\\InnerFireTarget.mdl", u, "origin")
        endif
        call ApplyEnd(pid)
        // 잘바토르: 발밑 고리 + 섬광 (붉은 오라는 매니건스·용의 기운 전용)
        call SiegFxAt(SIEG_FX_RING, GetWidgetX(u), GetWidgetY(u), 10, 1.6, 0, 0.4, pid)
        call SiegFxAt(SIEG_FX_FLASH, GetWidgetX(u), GetWidgetY(u), 150, 1.2, 0, 0, pid)
    endif
    set u = null
    call fx.destroy()
    call t.destroy()
endfunction

private function Main takes nothing returns nothing
    local unit u
    local FxEffect fx
    local tick t

    if GetSpellAbilityId() == 'A0SD' then
        set u = GetTriggerUnit()
        set fx = FxEffect.create()
        set fx.caster = u
        set fx.pid = GetPlayerId(GetOwningPlayer(u))
        set fx.speed = SiegSpeed(fx.pid)
        call SiegFace(u, GetSpellTargetX(), GetSpellTargetY())
        call SiegResetCombo(fx.pid)
        set SiegBusy[fx.pid] = true
        call CooldownFIX(u, 'A0SD', HeroSkillCD6[SIEG_INDEX])
        call BuffNoDM.Apply(u, Lock / fx.speed, 0)
        call SiegLock(u, Lock / fx.speed)
        call SiegAnim(u, 144, fx.speed)
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

    if SiegIsHero(u) and SiegCanAct(u) and not SiegBusy[pid] and EXGetAbilityState(EXGetUnitAbility(u, HeroSkillID6[SIEG_INDEX]), ABILITY_STATE_COOLDOWN) == 0 then
        call SiegUnlock(GetPlayerId(GetOwningPlayer(u)))
        call SiegFace(u, SiegSplitReal(data, 0), SiegSplitReal(data, 1))
        call IssuePointOrder(u, "antimagicshell", SiegSplitReal(data, 0), SiegSplitReal(data, 1))
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
        call DzTriggerRegisterSyncData(t, ("SiegD"), (false))
        call TriggerAddAction(t, function SyncData)
        set t = null
    endmethod
endstruct
endscope
