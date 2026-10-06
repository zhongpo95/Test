// 지크프리트 W: 넬라나브 (전진하는 검기)
// 용기 3을 소모하면 무력화 피해가 강화된다.
scope HeroSiegW
globals
    private constant real Rate = 0.60
    private constant real StackBonus = 1.20
    private constant integer StackCost = 3
    private constant real Travel = 900
    private constant integer Steps = 15
    private constant real Range = 200
    private constant real Scale = 500
    // 모션(#139)의 검기 발사 순간은 1.35초라서 모션을 1.4배로 돌리고 그 시점(0.96초)에 검기를 낸다.
    private constant real AnimRate = 1.4
    private constant real CastTime = 0.96
    private real CurRate = 0
    private group CheckG = null
endglobals

private struct FxEffect
    unit caster
    unit dummy
    party hit = 0
    integer pid
    integer serial
    integer step
    boolean empowered
    real x
    real y
    real f
    real speed

    method destroy takes nothing returns nothing
        if hit != 0 then
            call hit.destroy()
            set hit = 0
        endif
        set caster = null
        set dummy = null
        call deallocate()
    endmethod
endstruct

private function splashD takes nothing returns nothing
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    if IsUnitInRangeXY(GetEnumUnit(), splash.x, splash.y, Range) and not IsUnitInGroup(GetEnumUnit(), CheckG) then
        call GroupAddUnit(CheckG, GetEnumUnit())
        call SiegDeal('A0SW', splash.source, GetEnumUnit(), CurRate, false)
        call SiegFxHit(GetWidgetX(GetEnumUnit()), GetWidgetY(GetEnumUnit()), pid)
    endif
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data

    if fx.step == 0 then
        // 회피로 끊겼으면(SiegSerial 변경) 검기를 내지 않는다.
        if fx.serial == SiegSerial[fx.pid] then
            set SiegBusy[fx.pid] = false
        endif
        if fx.serial != SiegSerial[fx.pid] or not SiegCanAct(fx.caster) then
            call fx.destroy()
            call t.destroy()
            return
        endif
        set fx.x = GetWidgetX(fx.caster)
        set fx.y = GetWidgetY(fx.caster)
        set fx.f = GetUnitFacing(fx.caster)
        set fx.hit = party.create()
        // 기존 파동 더미(e02T, 분홍 초승달)는 연출과 맞지 않아 쓰지 않는다.
        set fx.dummy = null
        // 넬라나브: 세로 올려베기 날개 + 전방으로 이어지는 붉은 지면 분출
        call SiegFxLine(SIEG_FX_PILLAR, fx.x, fx.y, fx.f, 180, Travel - 150, 170, 0.38, 0.05, fx.pid)
        call CameraShaker.setShakeForPlayer(GetOwningPlayer(fx.caster), 6)
    endif

    set fx.step = fx.step + 1
    set fx.x = fx.x + PolarX(Travel / Steps, fx.f)
    set fx.y = fx.y + PolarY(Travel / Steps, fx.f)
    if fx.dummy != null then
        call SetUnitX(fx.dummy, fx.x)
        call SetUnitY(fx.dummy, fx.y)
    endif
    set CurRate = Rate
    if fx.empowered then
        set CurRate = Rate * StackBonus
        set HeroDealBonusSD = 2.0
    endif
    set CheckG = fx.hit.super
    call splash.range(splash.ENEMY, fx.caster, fx.x, fx.y, Scale, function splashD)
    set CheckG = null
    set HeroDealBonusSD = 0.0

    if fx.step >= Steps then
        call fx.destroy()
        call t.destroy()
    else
        call t.start(0.02, false, function EffectFunction)
    endif
endfunction

private function Main takes nothing returns nothing
    local unit u
    local FxEffect fx
    local tick t

    if GetSpellAbilityId() == 'A0SW' then
        set u = GetTriggerUnit()
        set fx = FxEffect.create()
        set fx.caster = u
        set fx.pid = GetPlayerId(GetOwningPlayer(u))
        set fx.speed = SiegSpeed(fx.pid)
        set fx.step = 0
        set fx.empowered = SiegStack[fx.pid] >= StackCost
        if fx.empowered then
            set SiegStack[fx.pid] = SiegStack[fx.pid] - StackCost
        endif
        call SiegFace(u, GetSpellTargetX(), GetSpellTargetY())
        call SiegResetCombo(fx.pid)
        set fx.serial = SiegSerial[fx.pid]
        set SiegBusy[fx.pid] = true
        call CooldownFIX(u, 'A0SW', HeroSkillCD1[SIEG_INDEX])
        call SiegLock(u, (CastTime + 0.25) / fx.speed)
        call SiegAnimJust(u, 139, fx.speed * AnimRate, true)
        set t = tick.create(fx)
        call t.start(CastTime / fx.speed, false, function EffectFunction)
        set u = null
    endif
endfunction

private function WSyncData takes nothing returns nothing
    local player p = DzGetTriggerSyncPlayer()
    local string data = DzGetTriggerSyncData()
    local integer pid = GetPlayerId(p)
    local unit u = MainUnit[pid]

    if SiegIsHero(u) and SiegCanAct(u) and not SiegBusy[pid] and EXGetAbilityState(EXGetUnitAbility(u, HeroSkillID1[SIEG_INDEX]), ABILITY_STATE_COOLDOWN) == 0 then
        call SiegUnlock(GetPlayerId(GetOwningPlayer(u)))
        call SiegFace(u, SiegSplitReal(data, 0), SiegSplitReal(data, 1))
        call IssuePointOrder(u, "acolyteharvest", SiegSplitReal(data, 0), SiegSplitReal(data, 1))
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
        call DzTriggerRegisterSyncData(t, ("SiegW"), (false))
        call TriggerAddAction(t, function WSyncData)
        set t = null
    endmethod
endstruct
endscope
