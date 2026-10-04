// 지크프리트 Q: 우베 (돌진 연속 베기)
// C의 저스트 창 안에서 쓰면 저스트 캔슬: 강화되고, 끝난 뒤 C 콤보가 다음 단으로 이어진다.
// 원작 #137(중간 낙하 구간)은 바닥으로 빠지므로 #136 -> #138로 잇는다.
scope HeroSiegQ
globals
    private constant real Rate = 0.13
    private constant real JustBonus = 1.30
    private constant integer JumpSteps = 20
    private constant integer SlashStep = 14
    private constant real Dash = 420
    private constant real Range = 230
    private constant real Scale = 600
    private constant real Total = 1.40
    private real CurRate = 0
endglobals

private struct FxEffect
    unit caster
    integer pid
    integer serial
    integer step
    integer stage
    boolean just
    real speed
    unit dummy

    method destroy takes nothing returns nothing
        set caster = null
        set dummy = null
        call deallocate()
    endmethod
endstruct

private function splashD takes nothing returns nothing
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    if IsUnitInRangeXY(GetEnumUnit(), splash.x, splash.y, Range) then
        call SiegDeal('A0SQ', splash.source, GetEnumUnit(), CurRate, true)
        call SiegFxHit(GetWidgetX(GetEnumUnit()), GetWidgetY(GetEnumUnit()), pid)
    endif
endfunction

// 우베 동작: #136(뛰어올라 세로 베기, 0.57초) -> #138(내려찍으며 착지).
// 0.15~0.75초 동안 앞으로 뛰어들고, 세로 베기 때 1타, 착지 내려찍기 때 2타(강타).
private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data
    local unit u = fx.caster
    local real f = GetUnitFacing(u)
    local real now
    local real bonus = 1.0

    if fx.serial != SiegSerial[fx.pid] or not SiegCanAct(u) then
        set SiegBusy[fx.pid] = false
        set SiegQBufOpen[fx.pid] = false
        set SiegQBuf[fx.pid] = false
        set u = null
        call fx.destroy()
        call t.destroy()
        return
    endif
    if fx.just then
        set bonus = JustBonus
    endif

    set fx.step = fx.step + 1
    if fx.step <= JumpSteps then
        call SetUnitSafePolarUTA(u, Dash / JumpSteps, f)
        if fx.dummy != null then
            call SetUnitX(fx.dummy, GetWidgetX(u))
            call SetUnitY(fx.dummy, GetWidgetY(u))
        endif
        if fx.step == 6 then
            // #136 0.30초: 칼이 뒤에서 올라오기 시작 -> 전용 말굽 궤적(머리 위를 크게 한 바퀴 돌아 앞 아래로)
            // 돌진 거리(남은 14걸음 × 21)는 모델 안에 들어 있어서 따라 옮기지 않고 놓아 둔다
            if not SiegOff[fx.pid * 8 + 1] then
                call SiegQArcFx(u, fx.speed)
            endif
        elseif fx.step == JumpSteps then
            // 착지 직전: 내려찍기 궤적(머리 위 -> 앞 바닥)
            if not SiegOff[fx.pid * 8 + 2] then
                call SiegTrail(u, SIEG_FX_QSLAM, fx.speed)
            endif
        endif
        if fx.step == SlashStep then
            // 공중 세로 베기 판정
            if SiegDebug[fx.pid] then
                call DisplayTimedTextToPlayer(Player(fx.pid), 0, 0, 20, "|cffff6060[Q] 공중 베기 판정|r t=" + R2SW(SiegNow(), 1, 2))
            endif
            set CurRate = Rate * 2 * bonus
            call splash.range(splash.ENEMY, u, GetWidgetX(u) + PolarX(110, f), GetWidgetY(u) + PolarY(110, f), Scale, function splashD)
        endif
        if fx.step == JumpSteps then
            call t.start(0.06 / fx.speed, false, function EffectFunction)
        else
            call t.start(0.03 / fx.speed, false, function EffectFunction)
        endif
    elseif fx.step == JumpSteps + 1 then
        // 착지 내려찍기
        call SiegAnimJust(u, 138, fx.speed, true)
        set CurRate = Rate * 4 * bonus
        call splash.range(splash.ENEMY, u, GetWidgetX(u) + PolarX(130, f), GetWidgetY(u) + PolarY(130, f), Scale, function splashD)
        // 착지 내려찍기: 대검이 박힌 앞쪽으로만 바닥 판석·붉은 파편·흙이 튄다
        if not SiegOff[fx.pid * 8 + 3] then
            call SiegGroundBurst(u, false, fx.speed)
        endif
        call CameraShaker.setShakeForPlayer(GetOwningPlayer(u), 10)
        // 착지한 뒤 누른 C는 저장했다가 Q가 끝나는 순간 이어 준다
        set SiegQBufOpen[fx.pid] = true
        set SiegQBuf[fx.pid] = false
        call t.start((Total - 0.81) / fx.speed, false, function EffectFunction)
    else
        set SiegBusy[fx.pid] = false
        set SiegQBufOpen[fx.pid] = false
        if fx.just and fx.stage > 0 and fx.stage < 5 then
            // 저스트 캔슬: 끝난 직후 C를 누르면 다음 단이 저스트로 이어진다.
            set now = SiegNow()
            set SiegStage[fx.pid] = fx.stage
            set SiegStageJust[fx.pid] = true
            set SiegStageStart[fx.pid] = now - 0.25
            set SiegHitT[fx.pid] = now
            set SiegWinEnd[fx.pid] = now + (SIEG_JUST_WINDOW + 0.10 + SiegWinBonus[fx.pid]) / fx.speed
            set SiegComboEnd[fx.pid] = SiegWinEnd[fx.pid] + SIEG_COMBO_GRACE / fx.speed
        endif
        if SiegQBuf[fx.pid] then
            set SiegQBuf[fx.pid] = false
            if fx.just and fx.stage > 0 and fx.stage < 5 then
                call SiegOrderStage.evaluate(fx.pid, fx.stage + 1, true, SiegQBufX[fx.pid], SiegQBufY[fx.pid])
            else
                call SiegOrderStage.evaluate(fx.pid, 1, false, SiegQBufX[fx.pid], SiegQBufY[fx.pid])
            endif
        endif
        set u = null
        call fx.destroy()
        call t.destroy()
        return
    endif
    set u = null
endfunction

private function Main takes nothing returns nothing
    local unit u
    local integer pid
    local FxEffect fx
    local tick t

    if GetSpellAbilityId() == 'A0SQ' then
        set u = GetTriggerUnit()
        set pid = GetPlayerId(GetOwningPlayer(u))
        call SiegFace(u, GetSpellTargetX(), GetSpellTargetY())
        set fx = FxEffect.create()
        set fx.caster = u
        set fx.pid = pid
        set fx.just = SiegQJust[pid]
        set fx.stage = SiegStage[pid]
        set fx.speed = SiegSpeed(pid)
        set fx.step = 0
        // 진행 중인 C 타격을 끊고 우베로 넘어간다.
        set SiegSerial[pid] = SiegSerial[pid] + 1
        set SiegStage[pid] = 0
        set SiegFOpen[pid] = false
        set fx.serial = SiegSerial[pid]
        set SiegBusy[pid] = true
        if fx.just then
            call SiegAddStack(pid, 1)
            if not SiegOff[pid * 8 + 5] then
                call SiegFxJust(u, pid)
            endif
        endif
        call CooldownFIX(u, 'A0SQ', HeroSkillCD0[SIEG_INDEX])
        call BuffNoST.Apply(u, Total / fx.speed, 0)
        call BuffNoNB.Apply(u, Total / fx.speed, 0)
        call SiegLock(u, Total / fx.speed)
        call SiegAnimJust(u, 136, fx.speed, true)
        // 도약: 발밑에서 뒤로 흙먼지와 잔돌이 튄다
        if not SiegOff[pid * 8 + 5] then
            call SiegFxAt(SIEG_FX_DUST, GetWidgetX(u), GetWidgetY(u), 0, 1.2, GetUnitFacing(u), 0, pid)
        endif
        set fx.dummy = null
        set t = tick.create(fx)
        call t.start(0.15 / fx.speed, false, function EffectFunction)
        set u = null
    endif
endfunction

private function QSyncData takes nothing returns nothing
    local player p = DzGetTriggerSyncPlayer()
    local string data = DzGetTriggerSyncData()
    local integer pid = GetPlayerId(p)
    local unit u = MainUnit[pid]

    if SiegIsHero(u) and SiegCanAct(u) and not SiegBusy[pid] and EXGetAbilityState(EXGetUnitAbility(u, HeroSkillID0[SIEG_INDEX]), ABILITY_STATE_COOLDOWN) == 0 then
        set SiegQJust[pid] = JNStringSplit(data, ";", 2) == "j"
        call SiegUnlock(GetPlayerId(GetOwningPlayer(u)))
        call SiegFace(u, SiegSplitReal(data, 0), SiegSplitReal(data, 1))
        call IssuePointOrder(u, "acidbomb", SiegSplitReal(data, 0), SiegSplitReal(data, 1))
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
        call DzTriggerRegisterSyncData(t, ("SiegQ"), (false))
        call TriggerAddAction(t, function QSyncData)
        set t = null
    endmethod
endstruct
endscope
