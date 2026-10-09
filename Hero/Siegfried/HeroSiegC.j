// 지크프리트 C: 아스칼론 연격 (5단 콤보, 저스트 어택)
scope HeroSiegC
globals
    // 단별 피해 계수(일반). 저스트는 JustRate배, 여러 번 베는 단은 타격 수로 나눈다.
    private real array StageRate
    private constant real JustRate = 1.5
    // 5단 전 저스트 총 계수
    private constant real AllJustRate = 0.90
    // 전방 판정
    private constant real Front = 110
    private constant real Range = 230
    private constant real Scale = 600
    private real CurRate = 0
endglobals

private struct HitFx
    unit caster
    integer pid
    integer serial
    integer anim
    integer hit
    real rate
    // 저스트 입력으로 나간 단인지 (로 아이아스 꽃잎 판정용)
    boolean just

    method destroy takes nothing returns nothing
        set caster = null
        call deallocate()
    endmethod
endstruct

private function splashD takes nothing returns nothing
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    if IsUnitInRangeXY(GetEnumUnit(), splash.x, splash.y, Range) then
        call SiegDeal(2, splash.source, GetEnumUnit(), CurRate, false)
        call SiegFxHit(GetWidgetX(GetEnumUnit()), GetWidgetY(GetEnumUnit()), pid)
    endif
endfunction

private function AnimFor takes integer stage, boolean just, boolean prevJust, boolean allJust returns integer
    if stage == 1 then
        return 104
    elseif stage == 2 then
        if just then
            return 112
        endif
        return 105
    elseif stage == 3 then
        if just then
            if prevJust then
                return 113
            endif
            return 116
        endif
        if prevJust then
            return 109
        endif
        return 106
    elseif stage == 4 then
        if just then
            if prevJust then
                return 114
            endif
            return 117
        endif
        if prevJust then
            return 110
        endif
        return 107
    endif
    if just then
        if allJust then
            return 119
        endif
        if prevJust then
            return 115
        endif
        return 118
    endif
    if prevJust then
        return 111
    endif
    return 108
endfunction

// 다음 단은 다른 영웅 C처럼 능력 명령(auravampiric)으로 시전해서 이동을 확실히 끊는다.
// 실제 단계 시작은 시전 이벤트(Main)에서 한다.
function SiegOrderStage takes integer pid, integer stage, boolean just, real x, real y returns nothing
    local unit u = MainUnit[pid]
    set SiegPendStage[pid] = stage
    set SiegPendJust[pid] = just
    set SiegPendTime[pid] = SiegNow()
    call SiegUnlock(GetPlayerId(GetOwningPlayer(u)))
    call SiegFace(u, x, y)
    if not IssuePointOrder(u, "auravampiric", x, y) then
        set SiegPendStage[pid] = 0
    elseif GetUnitCurrentOrder(u) == 0 then
        // 명령이 시전으로 이어지지 않는 환경(뷰어 등)에서는 바로 단계를 시작한다.
        set SiegPendStage[pid] = 0
        call SiegStartStage.evaluate(pid, stage, just)
    endif
    set u = null
endfunction

// 판정 전에 눌러 둔 입력: 현재 단의 칼질이 끝까지 보이도록 타격 직후 조금 기다렸다가 다음 단으로 넘긴다.
private struct QueueNext
    integer pid
    integer serial
    integer stage
endstruct

private function QueueNextFire takes nothing returns nothing
    local tick t = tick.getExpired()
    local QueueNext q = t.data
    local unit u = MainUnit[q.pid]
    local real f = GetUnitFacing(u)
    if q.serial == SiegSerial[q.pid] and SiegStage[q.pid] == q.stage and SiegQueued[q.pid] and SiegCanAct(u) then
        call SiegOrderStage(q.pid, q.stage + 1, SiegQueuedJust[q.pid], GetWidgetX(u) + PolarX(100, f), GetWidgetY(u) + PolarY(100, f))
    endif
    set u = null
    call q.destroy()
    set t.data = 0
    call t.destroy()
endfunction

function HitFxFire takes nothing returns nothing
    local tick t = tick.getExpired()
    local HitFx fx = t.data
    local unit u = fx.caster
    local integer pid = fx.pid
    local real f
    local real now = SiegNow()
    local QueueNext q
    local tick qt

    if fx.serial == SiegSerial[pid] and SiegCanAct(u) then
        set f = GetUnitFacing(u)
        set CurRate = fx.rate
        set HeroDealJust = fx.just
        call splash.range(splash.ENEMY, u, GetWidgetX(u) + PolarX(Front, f), GetWidgetY(u) + PolarY(Front, f), Scale, function splashD)
        set HeroDealJust = false

        if fx.hit == SiegHitMain[fx.anim] then
            // 타격음은 이번 타격에 적이 맞았을 때만
            if SiegLastHitT[pid] >= now - 0.001 then
                call Sound3D(u, 'A03X')
            endif
            if fx.anim == 119 then
                // 내려찍기: 파이널 피니시 입력 창
                call CameraShaker.setShakeForPlayer(GetOwningPlayer(u), 12)
                if SiegStageJust[pid] then
                    // 저스트 내려찍기: 진홍 빛기둥 + 바닥 균열
                    call SiegGroundBurst(u, false, SiegSpeed(pid))
                else
                    call SiegFxBurst(GetWidgetX(u) + PolarX(Front, f), GetWidgetY(u) + PolarY(Front, f), f, pid)
                endif
                set SiegFOpen[pid] = not SiegFLock[pid]
                set SiegFStart[pid] = SiegStageStart[pid]
                set SiegFHit[pid] = now
                set SiegFEnd[pid] = now + (SIEG_F_WINDOW + SiegWinBonus[pid]) / SiegSpeed(pid)
                set SiegComboEnd[pid] = SiegFEnd[pid] + 0.10
            else
                if fx.anim == 114 or fx.anim == 117 then
                    // 4단 저스트는 칼을 휘두르지 않고 앞으로 찌르는 자세: 찌르기 빛줄기 + 칼끝 섬광
                    call SiegFxThrust(u, pid)
                endif
                if SiegQueued[pid] and SiegStage[pid] < 5 then
                    set q = QueueNext.create()
                    set q.pid = pid
                    set q.serial = fx.serial
                    set q.stage = SiegStage[pid]
                    set qt = tick.create(0)
                    set qt.data = q
                    call qt.start(0.15 / SiegSpeed(pid), false, function QueueNextFire)
                endif
            endif
        elseif fx.anim == 119 and fx.hit == 2 then
            call CameraShaker.setShakeForPlayer(GetOwningPlayer(u), 6)
        endif
    endif

    set u = null
    call fx.destroy()
    call t.destroy()
endfunction

function SiegStartStage takes integer pid, integer stage, boolean just returns nothing
    local unit u = MainUnit[pid]
    local boolean prevJust = SiegStageJust[pid]
    local real speed = SiegSpeed(pid)
    local real now = SiegNow()
    local integer anim
    local integer k = 0
    local real total
    local HitFx fx
    local tick t

    if stage == 1 then
        set prevJust = false
        set SiegAllJust[pid] = true
    elseif SiegResumeNoMiss[pid] then
        // 회피 뒤 이어지는 단: 일반 타격이지만 실패로 치지 않는다(용기 유지).
        // 다시 치는 저스트 단은 이미 용기를 받았으므로 더 주지 않는다. 직전 단 저스트 여부도 회피 전 값으로 되살린다.
        set SiegAllJust[pid] = SiegDodgeAllJust[pid] and just
        set prevJust = SiegDodgePrevJust[pid]
        if SiegDodgeFresh[pid] and just then
            // 저스트 타이밍에 회피해 넘어온 새 단: 용기를 한 번 준다.
            call SiegAddStack(pid, 1)
        endif
    elseif not just then
        set SiegAllJust[pid] = false
        call SiegMiss(pid)
    else
        call SiegAddStack(pid, 1)
    endif

    set SiegDodgeStage[pid] = 0
    set SiegResumeNoMiss[pid] = false
    set SiegDodgeFresh[pid] = false
    set SiegStagePrevJust[pid] = prevJust
    set anim = AnimFor(stage, just, prevJust, SiegAllJust[pid] and just and stage == 5)
    set SiegSerial[pid] = SiegSerial[pid] + 1
    set SiegStage[pid] = stage
    set SiegStageJust[pid] = just
    set SiegStageAnim[pid] = anim
    set SiegQueued[pid] = false
    set SiegQueuedJust[pid] = false
    set SiegFOpen[pid] = false
    set SiegFLock[pid] = false
    set SiegStageStart[pid] = now
    set SiegHitT[pid] = now + SiegMainHitTime(anim) / speed
    set SiegWinEnd[pid] = SiegHitT[pid] + (SIEG_JUST_WINDOW + SiegWinBonus[pid]) / speed
    if stage == 5 then
        // 마지막 단은 후딜까지 묶어 두고 끝나야 1단부터 다시 시작한다.
        set SiegComboEnd[pid] = SiegHitT[pid] + 0.45 / speed
    else
        set SiegComboEnd[pid] = SiegWinEnd[pid] + SIEG_COMBO_GRACE / speed
    endif

    // 단별 계수
    if anim == 119 then
        set total = AllJustRate
    else
        set total = StageRate[stage]
        if just then
            set total = total * JustRate
        endif
    endif

    if just then
        call SiegFxJust(u, pid)
    endif

    if anim == 119 then
        // 파이널 피니시 입력 창 예상 위치 (실제 창은 내려찍기 타격 때 열린다)
        set SiegFStart[pid] = now
        set SiegFHit[pid] = now + SiegMainHitTime(119) / speed
        set SiegFEnd[pid] = SiegFHit[pid] + (SIEG_F_WINDOW + SiegWinBonus[pid]) / speed
    endif

    if stage == 5 then
        if anim == 119 then
            set SiegComboEnd[pid] = SiegFEnd[pid] + 0.10
        endif
        call SiegLock(u, SiegComboEnd[pid] - now)
    else
        call SiegLock(u, SiegWinEnd[pid] - now)
    endif
    call SiegAnimJust(u, anim, speed, just)
    if anim == 119 then
        // 올려베기(1.217초~)와 공중 내려찍기(1.90초~): 칼을 따라가는 전용 궤적. 영웅이 뜬 높이에서 시작해 함께 내려온다.
        call SiegTrailLater(u, SIEG_FX_C5RISE, 1.217 / speed, speed)
        call SiegTrailLater(u, SIEG_FX_C5SLAM, 1.90 / speed, speed)
    endif

    loop
        exitwhen k >= SiegHitCount[anim]
        set fx = HitFx.create()
        set fx.caster = u
        set fx.pid = pid
        set fx.serial = SiegSerial[pid]
        set fx.anim = anim
        set fx.hit = k
        set fx.rate = total / SiegHitCount[anim]
        set fx.just = just
        set t = tick.create(fx)
        call t.start(SiegHitTime[anim * 6 + k] / speed, false, function HitFxFire)
        set k = k + 1
    endloop
    set u = null
endfunction



private function Main takes nothing returns nothing
    local unit u
    local integer pid
    if GetSpellAbilityId() == 'A0SC' then
        set u = GetTriggerUnit()
        set pid = GetPlayerId(GetOwningPlayer(u))
        if SiegPendStage[pid] > 0 and SiegCanAct(u) and not SiegBusy[pid] then
            call SiegFace(u, GetSpellTargetX(), GetSpellTargetY())
            call SiegStartStage(pid, SiegPendStage[pid], SiegPendJust[pid])
        elseif SiegPendStage[pid] == 0 and SiegStage[pid] == 0 and GetUnitCurrentOrder(u) == 0 and SiegCanAct(u) and not SiegBusy[pid] then
            // 뷰어의 스킬 실행처럼 명령 없이 시전 이벤트만 온 경우에만 1단으로 시작한다.
            // (게임에서는 묶임이 풀린 뒤 이전 시전 명령이 다시 실행돼도 여기서 시작하지 않는다)
            call SiegFace(u, GetSpellTargetX(), GetSpellTargetY())
            call SiegStartStage(pid, 1, false)
        endif
        set SiegPendStage[pid] = 0
        call CooldownFIX(u, 'A0SC', 0.05)
        set u = null
    endif
endfunction

private function CSyncData takes nothing returns nothing
    local player p = DzGetTriggerSyncPlayer()
    local string data = DzGetTriggerSyncData()
    local integer pid = GetPlayerId(p)
    local unit u = MainUnit[pid]
    local string res = JNStringSplit(data, ";", 2)
    local real now = SiegNow()
    local integer stage = SiegStage[pid]
    local real x = SiegSplitReal(data, 0)
    local real y = SiegSplitReal(data, 1)

    if SiegIsHero(u) and SiegBusy[pid] and SiegQBufOpen[pid] then
        // Q 착지 뒤에 누른 C: Q가 끝나는 순간 다음 단으로 낸다
        set SiegQBuf[pid] = true
        set SiegQBufX[pid] = x
        set SiegQBufY[pid] = y
        set u = null
        set p = null
        return
    endif
    if not SiegIsHero(u) or not SiegCanAct(u) or SiegBusy[pid] or (SiegPendStage[pid] > 0 and now < SiegPendTime[pid] + 0.5) then
        set u = null
        set p = null
        return
    endif

    if stage == 0 or now > SiegComboEnd[pid] then
        // 콤보가 끊겼거나 5단 후딜이 끝났으면 1단부터. 다른 기술에 묶여 있으면(B000) 받지 않는다.
        if GetUnitAbilityLevel(u, 'B000') < 1 then
            if SiegDodgeStage[pid] > 0 and now <= SiegDodgeUntil[pid] then
                // 회피로 끊은 콤보: 끊긴 다음 단부터 일반으로 이어진다(실패로 치지 않음).
                set SiegResumeNoMiss[pid] = true
                call SiegOrderStage(pid, SiegDodgeStage[pid] + 1, SiegDodgeJust[pid], x, y)
            else
                call SiegOrderStage(pid, 1, false, x, y)
            endif
        endif
    elseif stage < 5 and not SiegQueued[pid] then
        if res == "e" or res == "q" then
            // 타격 전에 누르면 이번 단은 저스트를 포기하고 타격 직후 일반으로 이어진다(연타 방지).
            if now < SiegHitT[pid] then
                set SiegQueued[pid] = true
                set SiegQueuedJust[pid] = res == "q"
            else
                call SiegOrderStage(pid, stage + 1, res == "q", x, y)
            endif
        elseif res == "j" then
            call SiegOrderStage(pid, stage + 1, true, x, y)
        elseif res == "n" then
            call SiegOrderStage(pid, stage + 1, false, x, y)
        endif
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
        set StageRate[1] = 0.20
        set StageRate[2] = 0.20
        set StageRate[3] = 0.24
        set StageRate[4] = 0.24
        set StageRate[5] = 0.40
        call DzTriggerRegisterSyncData(t, ("SiegC"), (false))
        call TriggerAddAction(t, function CSyncData)
        set t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddAction(t, function Main)
        set t = null
    endmethod
endstruct
endscope
