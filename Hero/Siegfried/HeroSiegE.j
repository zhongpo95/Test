// 지크프리트 E: 롱브르 디에르 (키다운 패리)
// 키를 누르는 동안 패리 자세, 떼면 즉시 반격한다. 자세 중 보스 공격을 받으면 저스트 패리가 되어
// 피해를 무효로 하고 강화 반격과 용기 +2를 얻는다. 맞지 않았으면 일반 반격만 나간다.
// 반격 모션: 일반 #142, 저스트 패리 #143 (뷰어 확인 후 바꿀 수 있음)
scope HeroSiegE
globals
    private constant real Rate = 1.00
    private constant real ParryRate = 2.50
    private constant real MaxHold = 1.50
    // 일반 반격(#143) 찌르기 0.20초, 패리 반격(#142) 내려찍기 1.10초
    private constant real HitDelay = 0.20
    private constant real ParryDelay = 1.10
    private constant real Range = 260
    private constant real Scale = 600
    private real CurRate = 0
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

private function splashD takes nothing returns nothing
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    if IsUnitInRangeXY(GetEnumUnit(), splash.x, splash.y, Range) then
        call SiegDeal('A0SE', splash.source, GetEnumUnit(), CurRate, true)
        call SiegFxHit(GetWidgetX(GetEnumUnit()), GetWidgetY(GetEnumUnit()), pid)
    endif
endfunction

private function CounterHit takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data
    local unit u = fx.caster
    local real f = GetUnitFacing(u)

    set SiegBusy[fx.pid] = false
    if SiegCanAct(u) then
        if SiegParried[fx.pid] then
            set CurRate = ParryRate
            call CameraShaker.setShakeForPlayer(GetOwningPlayer(u), 14)
            // 패리 반격: 대상 위치에 붉은 빛기둥
            call SiegFxSlam(GetWidgetX(u) + PolarX(150, f), GetWidgetY(u) + PolarY(150, f), f, 1.0, fx.pid)
        else
            set CurRate = Rate
        endif
        call splash.range(splash.ENEMY, u, GetWidgetX(u) + PolarX(120, f), GetWidgetY(u) + PolarY(120, f), Scale, function splashD)
    endif
    set SiegParried[fx.pid] = false
    set u = null
    call fx.destroy()
    call t.destroy()
endfunction

// 자세를 풀고 반격한다. 키를 떼거나 최대 유지 시간이 지나면 호출된다.
private function Release takes integer pid returns nothing
    local unit u = MainUnit[pid]
    local FxEffect fx
    local tick t
    local real speed = SiegSpeed(pid)
    local real delay

    if not SiegStance[pid] then
        set u = null
        return
    endif
    set SiegStance[pid] = false
    set HeroParryOn[pid] = false
    set HoldSerial[pid] = HoldSerial[pid] + 1

    call SiegUnlock(GetPlayerId(GetOwningPlayer(u)))
    // 원작 롱브르 디에르: 3432(#142)가 당신(패리 성공) 반격, 3433(#141 다음 #143)이 일반 반격
    if SiegParried[pid] then
        call SiegAddStack(pid, 2)
        set delay = ParryDelay
        call BuffNoDM.Apply(u, (ParryDelay + 0.25) / speed, 0)
        call SiegAnimJust(u, 142, speed, true)
    else
        set delay = HitDelay
        call SiegAnimJust(u, 143, speed, true)
    endif
    call SiegLock(u, (delay + 0.25) / speed)

    set fx = FxEffect.create()
    set fx.caster = u
    set fx.pid = pid
    set fx.speed = speed
    set t = tick.create(fx)
    call t.start(delay / speed, false, function CounterHit)
    set u = null
endfunction

private function HoldTick takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data
    local unit u = fx.caster

    if fx.serial != HoldSerial[fx.pid] or not SiegStance[fx.pid] then
        set u = null
        call fx.destroy()
        call t.destroy()
        return
    endif
    if not SiegCanAct(u) then
        set SiegStance[fx.pid] = false
        set HeroParryOn[fx.pid] = false
        set SiegBusy[fx.pid] = false
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

// 보스 공격이 패리 자세에 막혔을 때 (BossDeal에서 호출)
private function OnParry takes nothing returns boolean
    local integer pid = HeroParryPid
    local unit u = MainUnit[pid]
    if SiegIsHero(u) and SiegStance[pid] and not SiegParried[pid] then
        set SiegParried[pid] = true
        // 패리 성공: 크게 퍼지는 분홍빛 섬광
        call SiegFxJust(u, pid)
        call SiegFxAt(SIEG_FX_FLASH, GetWidgetX(u), GetWidgetY(u), 150, 1.8, 0, 0, pid)
        call Sound3D(u, 'A03Y')
        call CameraShaker.setShakeForPlayer(GetOwningPlayer(u), 8)
    endif
    set u = null
    return false
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
        set SiegParried[pid] = false
        set HeroParryOn[pid] = true
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
        call TriggerAddCondition(HeroParryTrigger, Condition(function OnParry))
        set t = null
    endmethod
endstruct
endscope
