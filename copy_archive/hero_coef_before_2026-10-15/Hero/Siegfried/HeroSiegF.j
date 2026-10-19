// 지크프리트 F: 파이널 피니시
// C 5단을 모두 저스트로 치면, 마지막 내려찍기가 땅에 닿는 순간 F 입력 창이 열린다.
// 원작 #121(낙하 반복 구간)은 그대로 재생하면 바닥 밑으로 빠지므로 #120 -> #122로 잇는다.
scope HeroSiegF
globals
    private constant real Rate1 = 0.40
    private constant real Rate2 = 0.40
    private constant real Rate3 = 2.00
    private constant real Range = 350
    private constant real Scale = 700
    private real CurRate = 0
endglobals

private struct FxEffect
    unit caster
    integer pid
    integer serial
    integer step
    real speed

    method destroy takes nothing returns nothing
        set caster = null
        call deallocate()
    endmethod
endstruct

private function splashD takes nothing returns nothing
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    if IsUnitInRangeXY(GetEnumUnit(), splash.x, splash.y, Range) then
        call SiegDeal('A0SF', splash.source, GetEnumUnit(), CurRate, false)
        call SiegFxHit(GetWidgetX(GetEnumUnit()), GetWidgetY(GetEnumUnit()), pid)
    endif
endfunction

private function Strike takes unit u, real rate returns nothing
    local real f = GetUnitFacing(u)
    set CurRate = rate
    call splash.range(splash.ENEMY, u, GetWidgetX(u) + PolarX(120, f), GetWidgetY(u) + PolarY(120, f), Scale, function splashD)
endfunction

// 공중에서 내려찍기 전에 칼에 기를 모으는 연출(원작 just_finish_charge 시점 1.12초).
// 영웅 모델이 모션 안에서 공중(모델 높이 약 400, 크기 2배라 800)에 떠 있으므로 그 높이의 칼 쪽에 놓고, 영웅을 따라간다.
private struct FCharge
    unit u
    integer pid
    integer serial
    real speed
endstruct

// 내려베기 전용 궤적: #120 1.683초부터 칼이 머리 위를 넘어 앞으로 내려오고, 착지(1.85초)까지 수직으로 떨어진다.
private function DropFire takes nothing returns nothing
    local tick t = tick.getExpired()
    local FCharge c = t.data
    if c.serial == SiegSerial[c.pid] and not IsUnitDeadVJ(c.u) then
        call SiegTrail(c.u, SIEG_FX_FDROP, c.speed)
    endif
    set c.u = null
    call c.destroy()
    set t.data = 0
    call t.destroy()
endfunction

private function ChargeFire takes nothing returns nothing
    local tick t = tick.getExpired()
    local FCharge c = t.data
    local real f
    local effect e
    if c.serial == SiegSerial[c.pid] and not IsUnitDeadVJ(c.u) then
        set f = GetUnitFacing(c.u)
        set e = AddSpecialEffect(SiegFxPath(SIEG_FX_CHARGE, c.pid), GetWidgetX(c.u) + PolarX(-60, f), GetWidgetY(c.u) + PolarY(-60, f))
        call EXSetEffectSize(e, 1.3)
        call EXSetEffectZ(e, EXGetEffectZ(e) + 760)
        call SiegFxKeep(e, c.u, 0.58)
        call SiegTint(c.u, c.pid, 0.65)
        set e = null
    endif
    set c.u = null
    call c.destroy()
    set t.data = 0
    call t.destroy()
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data
    local unit u = fx.caster
    local real f
    local FCharge ch
    local tick ct

    if fx.serial != SiegSerial[fx.pid] or IsUnitDeadVJ(u) then
        set SiegBusy[fx.pid] = false
        set SiegFActive[fx.pid] = false
        set u = null
        call fx.destroy()
        call t.destroy()
        return
    endif

    set fx.step = fx.step + 1
    set f = GetUnitFacing(u)
    if fx.step == 1 then
        // 올려 베기
        call Strike(u, Rate1)
        // 칼 궤적 초승달은 #120 휘두르기 표가 칼 높이에 맞춰 낸다(공중으로 뛰어오른 높이 포함).
        call SiegTint(u, fx.pid, 0.5)
        set ch = FCharge.create()
        set ch.u = u
        set ch.pid = fx.pid
        set ch.serial = fx.serial
        set ct = tick.create(0)
        set ct.data = ch
        call ct.start((1.12 - 0.90) / fx.speed, false, function ChargeFire)
        set ch = FCharge.create()
        set ch.u = u
        set ch.pid = fx.pid
        set ch.serial = fx.serial
        set ch.speed = fx.speed
        set ct = tick.create(0)
        set ct.data = ch
        call ct.start((1.683 - 0.90) / fx.speed, false, function DropFire)
        call t.start((1.77 - 0.90) / fx.speed, false, function EffectFunction)
    elseif fx.step == 2 then
        // (원작 F는 올려베기 1번 + 내려베기 1번: 공중 구간에서는 따로 타격하지 않고 내려베기 착지 타격에 합친다)
        call t.start((1.80 - 1.77) / fx.speed, false, function EffectFunction)
    elseif fx.step == 3 then
        // 착지 모션으로 전환
        call SiegAnim(u, 122, fx.speed)
        call t.start(0.05 / fx.speed, false, function EffectFunction)
    elseif fx.step == 4 then
        // 착지 내려찍기
        call Strike(u, Rate3)
        call CameraShaker.setShakeForPlayer(GetOwningPlayer(u), 20)
        // 대검이 박힌 앞쪽으로만 크게 땅이 터진다(Q보다 1.3배 넓게)
        call SiegGroundBurst(u, true, fx.speed)
        call SiegTint(u, fx.pid, 0.5)
        call t.start(0.40 / fx.speed, false, function EffectFunction)
    else
        set SiegBusy[fx.pid] = false
        set SiegFActive[fx.pid] = false
        call SiegResetCombo(fx.pid)
        set u = null
        call fx.destroy()
        call t.destroy()
        return
    endif
    set u = null
endfunction

private function FSyncData takes nothing returns nothing
    local player p = DzGetTriggerSyncPlayer()
    local string data = DzGetTriggerSyncData()
    local integer pid = GetPlayerId(p)
    local unit u = MainUnit[pid]
    local FxEffect fx
    local tick t

    if JNStringSplit(data, ";", 2) == "e" and SiegStage[pid] == 5 and SiegStageAnim[pid] == 119 then
        // 창이 열리기 전에 누름: 이번 콤보에서는 파이널 피니시 불가
        set SiegFLock[pid] = true
        set SiegFOpen[pid] = false
    elseif SiegIsHero(u) and SiegCanAct(u) and SiegFOpen[pid] and not SiegFLock[pid] and JNStringSplit(data, ";", 2) == "j" then
        call SiegResetCombo(pid)
        set SiegBusy[pid] = true
        set SiegFActive[pid] = true
        call SiegFace(u, SiegSplitReal(data, 0), SiegSplitReal(data, 1))
        set fx = FxEffect.create()
        set fx.caster = u
        set fx.pid = pid
        set fx.serial = SiegSerial[pid]
        set fx.step = 0
        set fx.speed = SiegSpeed(pid)
        call BuffNoDM.Apply(u, 2.3 / fx.speed, 0)
        call BuffNoST.Apply(u, 2.3 / fx.speed, 0)
        call BuffNoNB.Apply(u, 2.3 / fx.speed, 0)
        // 남아 있는 C 시전 명령이 묶임이 풀린 뒤 다시 실행되지 않도록 명령을 비운다.
        call IssueImmediateOrder(u, "stop")
        call SiegLock(u, 2.3 / fx.speed)
        call SiegAnimJust(u, 120, fx.speed, true)
        call Overlay2Count(pid, 'A0SF')
        set t = tick.create(fx)
        call t.start(0.90 / fx.speed, false, function EffectFunction)
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
        call DzTriggerRegisterSyncData(t, ("SiegF"), (false))
        call TriggerAddAction(t, function FSyncData)
        set t = null
    endmethod
endstruct
endscope
