// 지크프리트 공용 상태: 저스트 판정, 용기(竜気) 스택, 타이밍 게이지, 키 입력
// 모션 인덱스는 Siegfried.mdx의 motions.csv 기준이다. 타격 시점은 검 끝 감속으로 추정한 값이며 뷰어로 확인해 조정한다.
scope HeroSiegCore initializer Init
globals
    constant integer SIEG_INDEX = 26
    constant integer SIEG_MAX_STACK = 10
    // 저스트 판정 창(초, 1배속 기준)
    constant real SIEG_JUST_WINDOW = 0.15
    // 파이널 피니시 입력 창(초)
    constant real SIEG_F_WINDOW = 0.35
    // 판정 창이 끝난 뒤 콤보가 끊기기까지의 여유
    constant real SIEG_COMBO_GRACE = 0.60
    // 용기 스택당 피해 증가
    constant real SIEG_STACK_DAMAGE = 0.03

    timer SiegClock = CreateTimer()
    // 지난 바퀴까지 흐른 시간(초). SiegClock은 100초짜리 반복 타이머
    real SiegClockBase = 0

    integer array SiegStack
    integer array SiegStage
    boolean array SiegStageJust
    boolean array SiegAllJust
    integer array SiegStageAnim
    real array SiegStageStart
    real array SiegHitT
    real array SiegWinEnd
    real array SiegComboEnd
    boolean array SiegQueued
    boolean array SiegQueuedJust
    integer array SiegSerial

    boolean array SiegFOpen
    real array SiegFStart
    real array SiegFHit
    real array SiegFEnd

    boolean array SiegZOn
    real array SiegWinBonus
    real array SiegDmgBonus
    boolean array SiegBusy
    boolean array SiegStance
    boolean array SiegParried
    boolean array SiegQJust
    // Q 착지 뒤 누른 C를 Q가 끝날 때까지 저장
    boolean array SiegQBufOpen
    // 확인용: -siegoff1~5 로 Q 이펙트를 하나씩 끈다 (pid*8+k)
    boolean array SiegOff
    boolean array SiegQBuf
    real array SiegQBufX
    real array SiegQBufY
    // 파이널 피니시 창이 열리기 전에 F를 누르면 그 콤보에서는 F가 막힌다.
    boolean array SiegFLock
    // C 단계 시전 대기 (IssuePointOrder → 시전 이벤트에서 실행)
    integer array SiegPendStage
    boolean array SiegPendJust
    real array SiegPendTime

    // 모션별 타격 시점(1배속 초). 인덱스 = 모션 * 6 + 순번
    real array SiegHitTime
    integer array SiegHitCount
    // 각 모션에서 저스트 판정 기준이 되는 타격 순번
    integer array SiegHitMain

    integer SiegGaugeWin = 0
    integer SiegStackText = 0
endglobals

function SiegNow takes nothing returns real
    // 100만 초짜리 타이머의 경과 시간을 읽으면 실수 정밀도 때문에 0.0625초 단위로만 바뀐다.
    // 100초 반복 타이머 + 바퀴 수로 계산해 1프레임보다 촘촘한 값을 얻는다.
    return SiegClockBase + TimerGetElapsed(SiegClock)
endfunction

function SiegIsHero takes unit u returns boolean
    return u != null and DataUnitIndex(u) == SIEG_INDEX
endfunction

function SiegSpeed takes integer pid returns real
    if SiegDebugSlow[pid] then
        // 확인용 느린 재생(-siegslow)
        return (100 + SkillSpeed(pid)) / 100 * 0.35
    endif
    return (100 + SkillSpeed(pid)) / 100
endfunction

function SiegCanAct takes unit u returns boolean
    if u == null or IsUnitDeadVJ(u) then
        return false
    endif
    if GetUnitAbilityLevel(u, 'BPSE') > 0 or GetUnitAbilityLevel(u, 'A024') > 0 then
        return false
    endif
    return IsUnitPausedEx(u) == false
endfunction

// 용기 스택과 잘바토르 피해 증가를 반영한 피해 계수
function SiegRate takes integer pid, real base returns real
    return base * (1.0 + SIEG_STACK_DAMAGE * SiegStack[pid]) * (1.0 + SiegDmgBonus[pid] / 100.0)
endfunction

function SiegAddStack takes integer pid, integer n returns nothing
    set SiegStack[pid] = SiegStack[pid] + n
    if SiegStack[pid] > SIEG_MAX_STACK then
        set SiegStack[pid] = SIEG_MAX_STACK
    endif
endfunction

// 저스트를 놓치면 용기가 절반으로 줄어든다. 용기 해방 중에는 줄지 않는다.
function SiegMiss takes integer pid returns nothing
    if SiegZOn[pid] == false then
        set SiegStack[pid] = SiegStack[pid] / 2
    endif
endfunction

function SiegSetHit takes integer anim, real t1, real t2, real t3, real t4, integer mainHit returns nothing
    local integer n = 0
    if t1 > 0 then
        set SiegHitTime[anim * 6 + n] = t1
        set n = n + 1
    endif
    if t2 > 0 then
        set SiegHitTime[anim * 6 + n] = t2
        set n = n + 1
    endif
    if t3 > 0 then
        set SiegHitTime[anim * 6 + n] = t3
        set n = n + 1
    endif
    if t4 > 0 then
        set SiegHitTime[anim * 6 + n] = t4
        set n = n + 1
    endif
    set SiegHitCount[anim] = n
    set SiegHitMain[anim] = mainHit
endfunction

function SiegMainHitTime takes integer anim returns real
    return SiegHitTime[anim * 6 + SiegHitMain[anim]]
endfunction

// 진행 중인 콤보 타이머를 무효화하고 콤보를 끊는다.
function SiegResetCombo takes integer pid returns nothing
    set SiegSerial[pid] = SiegSerial[pid] + 1
    set SiegStage[pid] = 0
    set SiegStageJust[pid] = false
    set SiegAllJust[pid] = false
    set SiegQueued[pid] = false
    set SiegQueuedJust[pid] = false
    set SiegFOpen[pid] = false
    set SiegFLock[pid] = false
endfunction

// 지크프리트 공용 피해. 카운터 판정 여부를 받는다.
function SiegDeal takes integer abil, unit src, unit tgt, real rate, boolean counter returns boolean
    set SiegLastHitT[GetPlayerId(GetOwningPlayer(src))] = SiegNow()
    return HeroDeal(abil, src, tgt, SiegRate(GetPlayerId(GetOwningPlayer(src)), rate), false, false, counter, false)
endfunction

function SiegSplitReal takes string data, integer index returns real
    return S2R(JNStringSplit(data, ";", index))
endfunction

function SiegFace takes unit u, real x, real y returns nothing
    local real a = AngleWBP(u, x, y)
    call SetUnitFacing(u, a)
    call EXSetUnitFacing(u, a)
endfunction

// ---------------------------------------------------------------------------
// 행동 고정: 영웅마다 에어리얼 쉐클 더미를 하나만 두고 끝나는 시각만 갱신한다.
// DummyMagicleash를 겹쳐 쓰면 앞 단계의 타이머가 뒤 단계의 쉐클(B000)까지 지워서
// 모션 도중 영웅이 풀리고 모션이 끊긴다(시험 영상 13.8/14.5/15.2/16.0초).
globals
    unit array SiegLockDummy
    real array SiegLockEnd
    boolean array SiegLockRun
endglobals

private function SiegLockRelease takes integer pid returns nothing
    if GetUnitAbilityLevel(MainUnit[pid], 'B000') > 0 then
        call UnitRemoveAbility(MainUnit[pid], 'B000')
    endif
    if SiegLockDummy[pid] != null then
        call UnitApplyTimedLife(SiegLockDummy[pid], 'BHwe', 0.1)
        set SiegLockDummy[pid] = null
    endif
endfunction

private function SiegLockTick takes nothing returns nothing
    local tick t = tick.getExpired()
    local integer pid = t.data
    if SiegNow() >= SiegLockEnd[pid] or MainUnit[pid] == null or IsUnitDeadVJ(MainUnit[pid]) then
        call SiegLockRelease(pid)
        set SiegLockRun[pid] = false
        set t.data = 0
        call t.destroy()
    else
        call t.start(0.02, false, function SiegLockTick)
    endif
endfunction

// 영웅을 dur초 동안 묶는다. 마지막 호출의 끝나는 시각이 기준이다.
function SiegLock takes unit u, real dur returns nothing
    local integer pid = GetPlayerId(GetOwningPlayer(u))
    local tick t
    set SiegLockEnd[pid] = SiegNow() + dur
    if GetUnitAbilityLevel(u, 'B000') < 1 then
        if SiegLockDummy[pid] != null then
            call UnitApplyTimedLife(SiegLockDummy[pid], 'BHwe', 0.1)
        endif
        set SiegLockDummy[pid] = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'h001', GetWidgetX(u), GetWidgetY(u), 270)
        call IssueTargetOrder(SiegLockDummy[pid], "magicleash", u)
    endif
    if not SiegLockRun[pid] then
        set SiegLockRun[pid] = true
        set t = tick.create(0)
        set t.data = pid
        call t.start(0.02, false, function SiegLockTick)
    endif
endfunction

// 다음 명령을 내리기 위해 묶음을 바로 푼다.
function SiegUnlock takes integer pid returns nothing
    set SiegLockEnd[pid] = 0
    call SiegLockRelease(pid)
endfunction

// ---------------------------------------------------------------------------
// 연출
//  - 칼 궤적: 휘두르는 순간 칼끝이 지나는 원(HeroSiegData의 휘두르기 표)에 맞춰 베기 이펙트를 눕히고 돌려서 놓는다.
//    일반은 금색 호(라이브러리 F6701 HSK1_Slash_1), 저스트는 붉은 초승달(맵의 RedCresentSlash)을 겹친다.
//  - 타격·내려찍기: 리링크 원작 이펙트 소재(SiegfriedFX_*)
//  - 소리: 리링크 원작 모션 사운드 호출표(시각·이벤트)를 그대로 따른다.
globals
    constant string SIEG_FX_SLASH = "ArcanaFX\\F6701.mdx"
    constant real SIEG_FX_SLASH_R = 203.0
    constant string SIEG_FX_JUST = "RedCresentSlash.mdx"
    constant real SIEG_FX_JUST_R = 300.0
    constant string SIEG_FX_SPARK = "SiegfriedFX_048_000.mdx"
    constant string SIEG_FX_STAR = "SiegfriedFX_005_000.mdx"
    constant string SIEG_FX_DEBRIS = "SiegfriedFX_002_000.mdx"
    constant string SIEG_FX_SMOKE = "SiegfriedFX_001_000.mdx"
    constant string SIEG_FX_FIRE = "SiegfriedFX_018_Flipbook.mdx"
    constant string SIEG_FX_RING = "SiegfriedFX_011_000.mdx"
    // 새로 만든 연출 모델 (리링크 영상 참고: 진홍 초승달, 빛줄기, 섬광, 빛기둥, 균열, 가시벽, 오라)
    constant string SIEG_FX_CRES = "SiegfriedFX2\\SiegCrescent.mdx"
    constant string SIEG_FX_CRES_BIG = "SiegfriedFX2\\SiegCrescentBig.mdx"
    constant string SIEG_FX_CRES_LITE = "SiegfriedFX2\\SiegCrescentLite.mdx"
    constant real SIEG_FX_CRES_R = 200.0
    constant string SIEG_FX_STREAK = "SiegfriedFX2\\SiegStreak.mdx"
    constant string SIEG_FX_FLASH = "SiegfriedFX2\\SiegJustFlash.mdx"
    constant string SIEG_FX_PILLAR = "SiegfriedFX2\\SiegPillar.mdx"
    constant string SIEG_FX_CRACK = "SiegfriedFX2\\SiegCrack.mdx"
    constant string SIEG_FX_SHOCK = "SiegfriedFX2\\SiegShock.mdx"
    constant string SIEG_FX_SPIKES = "SiegfriedFX2\\SiegSpikes.mdx"
    constant string SIEG_FX_VORTEX = "SiegfriedFX2\\SiegVortex.mdx"
    constant string SIEG_FX_AURA2 = "SiegfriedFX2\\SiegAura.mdx"
    constant string SIEG_FX_CHARGE = "SiegfriedFX2\\SiegCharge.mdx"
    // 전용 궤적(영웅 기준 모델, 정면 = +X): Q 공중 말굽 베기 / Q 착지 내려찍기 / F 내려베기
    constant string SIEG_FX_QARC = "SiegfriedFX2\\SiegQArc.mdx"
    constant string SIEG_FX_QSLAM = "SiegfriedFX2\\SiegQSlam.mdx"
    constant string SIEG_FX_FDROP = "SiegfriedFX2\\SiegFDrop.mdx"
    // 대검 내려찍기: 정면 쐐기 범위로만 바닥 판석·붉은 파편·흙이 튄다
    constant string SIEG_FX_GBURST = "SiegfriedFX2\\SiegGroundBurst.mdx"
    constant string SIEG_FX_GBURST_BIG = "SiegfriedFX2\\SiegGroundBurstBig.mdx"
    // C 5단(#119) 전용 궤적: 칼 기록을 프레임마다 따라가서 공중 높이가 그대로 들어간다
    constant string SIEG_FX_C5RISE = "SiegfriedFX2\\SiegC5Rise.mdx"
    constant string SIEG_FX_C5SLAM = "SiegfriedFX2\\SiegC5Slam.mdx"
    // 도약 흙먼지(발밑에서 뒤로)
    constant string SIEG_FX_DUST = "SiegfriedFX2\\SiegDust.mdx"
    // 원작 대사 재생 여부
    boolean SiegVoiceOn = true
    integer array SiegAnimSerial
endglobals

// 다른 플레이어가 이펙트를 꺼 두었으면 빈 모델로 만든다(다른 영웅과 같은 규칙).
function SiegFxPath takes string path, integer pid returns string
    if EffectOff[GetPlayerId(GetLocalPlayer())] == false and pid != GetPlayerId(GetLocalPlayer()) then
        return ".mdl"
    endif
    return path
endfunction

// 새 이펙트 모델은 Stand(1000~) 하나에 연출 전체가 들어 있고 Death는 짧은 투명 구간이다(맵의 RedCresentSlash와 같은 구성).
// 그래서 재생 시간 동안 들고 있다가 지운다. 영웅을 기준으로 놓은 이펙트는 그동안 영웅을 따라 움직인다.
private struct SiegFxKill
    effect e
    unit u
    real ox
    real oy
    real left
endstruct

private function SiegFxKillFunc takes nothing returns nothing
    local tick t = tick.getExpired()
    local SiegFxKill k = t.data
    if k.u != null and k.left > 0.001 then
        if not IsUnitDeadVJ(k.u) then
            call EXSetEffectXY(k.e, GetUnitX(k.u) + k.ox, GetUnitY(k.u) + k.oy)
        endif
        set k.left = k.left - 0.02
        call t.start(0.02, false, function SiegFxKillFunc)
        return
    endif
    call DestroyEffect(k.e)
    set k.e = null
    set k.u = null
    call k.destroy()
    set t.data = 0
    call t.destroy()
endfunction

// 이펙트 e를 life초 뒤에 지운다. u가 있으면 그동안 u를 따라 움직인다.
function SiegFxKeep takes effect e, unit u, real life returns nothing
    local SiegFxKill k = SiegFxKill.create()
    local tick t = tick.create(0)
    set k.e = e
    set k.u = u
    set k.left = life
    if u != null then
        set k.ox = EXGetEffectX(e) - GetUnitX(u)
        set k.oy = EXGetEffectY(e) - GetUnitY(u)
        set t.data = k
        call t.start(0.02, false, function SiegFxKillFunc)
    else
        set k.left = 0
        set t.data = k
        call t.start(life, false, function SiegFxKillFunc)
    endif
endfunction

// 새로 만든 모델의 재생 길이(초)
function SiegFxLife takes string path returns real
    if path == SIEG_FX_CRES then
        return 0.34
    elseif path == SIEG_FX_CRES_BIG then
        return 0.41
    elseif path == SIEG_FX_CRES_LITE then
        return 0.34
    elseif path == SIEG_FX_STREAK then
        return 0.24
    elseif path == SIEG_FX_FLASH then
        return 0.38
    elseif path == SIEG_FX_VORTEX then
        return 0.51
    elseif path == SIEG_FX_PILLAR then
        return 0.47
    elseif path == SIEG_FX_CRACK then
        return 0.74
    elseif path == SIEG_FX_SPIKES then
        return 0.44
    elseif path == SIEG_FX_SHOCK then
        return 0.37
    elseif path == SIEG_FX_QARC then
        return 0.52
    elseif path == SIEG_FX_QSLAM then
        return 0.77
    elseif path == SIEG_FX_FDROP then
        return 0.89
    elseif path == SIEG_FX_GBURST or path == SIEG_FX_GBURST_BIG then
        return 1.0
    elseif path == SIEG_FX_DUST then
        return 0.7
    elseif path == SIEG_FX_C5RISE then
        return 0.72
    elseif path == SIEG_FX_C5SLAM then
        return 0.69
    endif
    return 0.0
endfunction

// 바닥 기준 높이 z, 크기, 방향(도)으로 이펙트를 놓는다. dur초 뒤 지우고, 0이면 새 모델은 재생 길이만큼, 그 밖의 모델은 바로 지운다.
function SiegFxAt takes string path, real x, real y, real z, real size, real face, real dur, integer pid returns effect
    local effect e = AddSpecialEffect(SiegFxPath(path, pid), x, y)
    call EXSetEffectSize(e, size)
    call EXSetEffectZ(e, EXGetEffectZ(e) + z)
    call EXEffectMatRotateZ(e, face)
    if dur <= 0 then
        set dur = SiegFxLife(path)
    endif
    if dur <= 0 then
        call DestroyEffect(e)
    else
        call SiegFxKeep(e, null, dur)
    endif
    return e
endfunction

// 영웅 u를 따라다니는 이펙트(섬광 등)
function SiegFxAtU takes string path, unit u, real x, real y, real z, real size, real face, integer pid returns nothing
    local effect e = AddSpecialEffect(SiegFxPath(path, pid), x, y)
    call EXSetEffectSize(e, size)
    call EXSetEffectZ(e, EXGetEffectZ(e) + z)
    call EXEffectMatRotateZ(e, face)
    call SiegFxKeep(e, u, SiegFxLife(path))
    set e = null
endfunction

// 3축 회전 이펙트. u가 있으면 영웅을 따라간다.
function SiegFxRotU takes string path, unit u, real x, real y, real z, real size, real roll, real pitch, real yaw, integer pid returns nothing
    local effect e = AddSpecialEffect(SiegFxPath(path, pid), x, y)
    call EXSetEffectSize(e, size)
    call EXSetEffectZ(e, EXGetEffectZ(e) + z)
    // 게임의 EXEffectMatRotate는 호출할 때마다 이펙트 자신의 축 기준으로 돌린다(루시아 W처럼 Z(방향) 다음 X(기울기)).
    // 그래서 방향(Z) -> 피치(Y) -> 롤(X) 순서로 불러야 칼 궤적 원 방향과 맞는다.
    call EXEffectMatRotateZ(e, yaw)
    call EXEffectMatRotateY(e, pitch)
    call EXEffectMatRotateX(e, roll)
    call SiegFxKeep(e, u, SiegFxLife(path))
    set e = null
endfunction

function SiegFxRot takes string path, real x, real y, real z, real size, real roll, real pitch, real yaw, integer pid returns nothing
    call SiegFxRotU(path, null, x, y, z, size, roll, pitch, yaw, pid)
endfunction

// 저스트 베기: 칼끝 원(중심 x,y,z, 반지름 r, 방향 roll/pitch/yaw)에 진홍 초승달을 놓고,
// 타격 지점을 지나는 긴 빛줄기를 칼이 움직이는 방향으로 긋는다. 둘 다 영웅을 따라간다.
function SiegSlashJust takes unit u, real x, real y, real z, real r, real roll, real pitch, real yaw, integer pid returns nothing
    local real cp = Cos(pitch * bj_DEGTORAD)
    local real hx = x + r * cp * Cos(yaw * bj_DEGTORAD)
    local real hy = y + r * cp * Sin(yaw * bj_DEGTORAD)
    local real hz = z - r * Sin(pitch * bj_DEGTORAD)
    local effect e
    if r > 260 then
        call SiegFxRotU(SIEG_FX_CRES_BIG, u, x, y, z, r / SIEG_FX_CRES_R, roll, pitch, yaw, pid)
    else
        call SiegFxRotU(SIEG_FX_CRES, u, x, y, z, r / SIEG_FX_CRES_R, roll, pitch, yaw, pid)
    endif
    // 빛줄기: 모델의 X축(길이 방향)을 휘두르는 방향(원 접선)으로 맞춘다.
    set e = AddSpecialEffect(SiegFxPath(SIEG_FX_STREAK, pid), hx, hy)
    call EXSetEffectSize(e, 0.9)
    call EXSetEffectZ(e, EXGetEffectZ(e) + RMaxBJ(hz, 40))
    call EXEffectMatRotateZ(e, yaw)
    call EXEffectMatRotateY(e, pitch)
    call EXEffectMatRotateX(e, roll)
    call EXEffectMatRotateZ(e, 90)
    call SiegFxKeep(e, u, SiegFxLife(SIEG_FX_STREAK))
    set e = null
endfunction

// 칼 궤적 이펙트 하나: 표의 i번째 휘두르기.
// 휘두르기마다 칼 궤적 원의 위치·기울기를 모델 안에 미리 넣어 둔 전용 모델(SiegfriedFX2\Sw\J<i>/L<i>)을 쓴다.
// 그래서 스크립트는 다른 영웅들처럼 영웅 위치에 놓고 영웅 방향으로 Z 회전만 한다(X/Y 회전 순서 문제 없음).
// 일반은 얇은 주황 초승달(L), 저스트는 진홍 초승달 + 빛줄기(J). 재생하는 동안 영웅을 따라간다.
function SiegSlash takes unit u, integer i, boolean just returns nothing
    local integer pid = GetPlayerId(GetOwningPlayer(u))
    local string p
    local effect e
    local real life
    if just then
        set p = "SiegfriedFX2\\Sw\\J" + I2S(i) + ".mdx"
        set life = 0.42
    else
        set p = "SiegfriedFX2\\Sw\\L" + I2S(i) + ".mdx"
        set life = 0.34
    endif
    set e = AddSpecialEffect(SiegFxPath(p, pid), GetWidgetX(u), GetWidgetY(u))
    call EXEffectMatRotateZ(e, GetUnitFacing(u))
    call SiegFxKeep(e, u, life)
    set e = null
endfunction

// 전용 궤적: 영웅 발밑에 놓고 정면으로 돌린다. 공격 속도만큼 빨리 재생하고, 그동안 영웅을 따라간다.
function SiegTrail takes unit u, string path, real speed returns nothing
    local integer pid = GetPlayerId(GetOwningPlayer(u))
    local effect e = AddSpecialEffect(SiegFxPath(path, pid), GetWidgetX(u), GetWidgetY(u))
    call EXEffectMatRotateZ(e, GetUnitFacing(u))
    call EXSetEffectSpeed(e, speed)
    call SiegFxKeep(e, u, SiegFxLife(path) / speed)
    set e = null
endfunction

// delay초 뒤 전용 궤적을 낸다(그 사이 다른 동작으로 넘어갔으면 내지 않는다)
private struct SiegTrailEv
    unit u
    string p
    integer pid
    integer serial
    real speed
endstruct

private function SiegTrailEvFire takes nothing returns nothing
    local tick t = tick.getExpired()
    local SiegTrailEv ev = t.data
    if ev.serial == SiegSerial[ev.pid] and not IsUnitDeadVJ(ev.u) then
        call SiegTrail(ev.u, ev.p, ev.speed)
    endif
    set ev.u = null
    call ev.destroy()
    set t.data = 0
    call t.destroy()
endfunction

function SiegTrailLater takes unit u, string path, real delay, real speed returns nothing
    local SiegTrailEv ev = SiegTrailEv.create()
    local tick t = tick.create(0)
    set ev.u = u
    set ev.p = path
    set ev.pid = GetPlayerId(GetOwningPlayer(u))
    set ev.serial = SiegSerial[ev.pid]
    set ev.speed = speed
    set t.data = ev
    call t.start(delay, false, function SiegTrailEvFire)
endfunction

// 바닥에 고정해 두는 전용 궤적(이동은 모델 안에 들어 있다). Q 말굽처럼 영웅이 움직이는 동안 쓰는 궤적은
// 매 프레임 위치를 옮기지 않고 이렇게 놓는다.
// 확인용(-siegtest 켜짐): 궤적 이펙트의 실제 좌표를 0.02초마다 채팅에 찍어 엉뚱한 위치로 튀는 순간을 잡는다.
private struct SiegFxProbe
    effect e
    unit u
    integer pid
    integer n
    real x0
    real y0
endstruct

private function SiegFxProbeTick takes nothing returns nothing
    local tick t = tick.getExpired()
    local SiegFxProbe q = t.data
    local real ex = EXGetEffectX(q.e)
    local real ey = EXGetEffectY(q.e)
    local real ez = EXGetEffectZ(q.e)
    set q.n = q.n - 1
    call DisplayTimedTextToPlayer(Player(q.pid), 0, 0, 20, "|cffffcc00[궤적]|r " + I2S(GetHandleId(q.e)) + " e(" + I2S(R2I(ex - q.x0)) + "," + I2S(R2I(ey - q.y0)) + "," + I2S(R2I(ez)) + ") u(" + I2S(R2I(GetUnitX(q.u) - q.x0)) + "," + I2S(R2I(GetUnitY(q.u) - q.y0)) + ") t=" + R2SW(SiegNow(), 1, 2))
    if q.n <= 0 then
        set q.e = null
        set q.u = null
        call q.destroy()
        set t.data = 0
        call t.destroy()
    else
        call t.start(0.02, false, function SiegFxProbeTick)
    endif
endfunction

// 궤적이 몇 프레임 동안 회전이 풀린 채 엉뚱한 곳에 그려지는 현상 대응: 사는 동안 0.02초마다
// 회전 행렬과 위치를 처음 값으로 다시 맞춘다(무언가 행렬을 건드려도 다음 틱에 되돌린다).
private struct SiegFxGuard
    effect e
    real x
    real y
    real z
    real face
    real left
endstruct

private function SiegFxGuardTick takes nothing returns nothing
    local tick t = tick.getExpired()
    local SiegFxGuard g = t.data
    set g.left = g.left - 0.02
    if g.left <= 0.02 then
        set g.e = null
        call g.destroy()
        set t.data = 0
        call t.destroy()
        return
    endif
    call EXEffectMatReset(g.e)
    call EXEffectMatRotateZ(g.e, g.face)
    call EXSetEffectXY(g.e, g.x, g.y)
    call EXSetEffectZ(g.e, g.z)
    call t.start(0.02, false, function SiegFxGuardTick)
endfunction

function SiegTrailFixed takes unit u, string path, real speed returns nothing
    local integer pid = GetPlayerId(GetOwningPlayer(u))
    local effect e = AddSpecialEffect(SiegFxPath(path, pid), GetWidgetX(u), GetWidgetY(u))
    local real life = SiegFxLife(path) / speed
    local SiegFxProbe q
    local SiegFxGuard g = SiegFxGuard.create()
    local tick t
    call EXEffectMatRotateZ(e, GetUnitFacing(u))
    call EXSetEffectSpeed(e, speed)
    call SiegFxKeep(e, null, life)
    set g.e = e
    set g.x = EXGetEffectX(e)
    set g.y = EXGetEffectY(e)
    set g.z = EXGetEffectZ(e)
    set g.face = GetUnitFacing(u)
    set g.left = life
    set t = tick.create(0)
    set t.data = g
    call t.start(0.02, false, function SiegFxGuardTick)
    if SiegDebug[pid] then
        set q = SiegFxProbe.create()
        set q.e = e
        set q.u = u
        set q.pid = pid
        set q.n = R2I(life / 0.02) - 1
        set q.x0 = GetWidgetX(u)
        set q.y0 = GetWidgetY(u)
        set t = tick.create(0)
        set t.data = q
        call t.start(0.01, false, function SiegFxProbeTick)
    endif
    set e = null
endfunction

// Q 공중 말굽: 방향을 22.5도 단위 16개 모델에 미리 구워 두었다(SiegQArc0~15).
// 이 이펙트에서 회전 행렬이 몇 프레임 풀려 엉뚱하게 그려지는 현상이 있어서 회전 함수를 쓰지 않는다.
function SiegQArcFx takes unit u, real speed returns nothing
    local integer pid = GetPlayerId(GetOwningPlayer(u))
    local real f = GetUnitFacing(u)
    local integer k
    local effect e
    local real life = 0.52 / speed
    local SiegFxProbe q
    local tick t
    loop
        exitwhen f >= 0
        set f = f + 360
    endloop
    set k = ModuloInteger(R2I((f + 11.25) / 22.5), 16)
    set e = AddSpecialEffect(SiegFxPath("SiegfriedFX2\\SiegQArc" + I2S(k) + ".mdx", pid), GetWidgetX(u), GetWidgetY(u))
    call EXSetEffectSpeed(e, speed)
    call SiegFxKeep(e, null, life)
    if SiegDebug[pid] then
        set q = SiegFxProbe.create()
        set q.e = e
        set q.u = u
        set q.pid = pid
        set q.n = R2I(life / 0.02) - 1
        set q.x0 = GetWidgetX(u)
        set q.y0 = GetWidgetY(u)
        set t = tick.create(0)
        set t.data = q
        call t.start(0.01, false, function SiegFxProbeTick)
    endif
    set e = null
endfunction

// 대검 내려찍기 땅 터짐: 영웅 위치에서 정면으로만 튄다(바닥에 고정, 영웅을 따라가지 않음).
function SiegGroundBurst takes unit u, boolean big, real speed returns nothing
    local integer pid = GetPlayerId(GetOwningPlayer(u))
    local string p = SIEG_FX_GBURST
    local effect e
    if big then
        set p = SIEG_FX_GBURST_BIG
    endif
    set e = AddSpecialEffect(SiegFxPath(p, pid), GetWidgetX(u), GetWidgetY(u))
    call EXEffectMatRotateZ(e, GetUnitFacing(u))
    call EXSetEffectSpeed(e, speed)
    call SiegFxKeep(e, null, SiegFxLife(p) / speed)
    set e = null
endfunction

// 표에 없는 자유 베기: 유닛 정면, 높이 z, 기울기 roll(도)
function SiegSlashFree takes unit u, integer pid, real z, real roll, boolean just returns nothing
    local real f = GetUnitFacing(u)
    if just then
        call SiegSlashJust(u, GetWidgetX(u), GetWidgetY(u), z, 220, roll, 0, f, pid)
    else
        call SiegFxRotU(SIEG_FX_CRES_LITE, u, GetWidgetX(u), GetWidgetY(u), z, 1.1, roll, 0, f, pid)
    endif
endfunction

// 원작 사운드 하나 재생 (후보 중 무작위)
// 워크3는 처음 쓰는 소리 파일을 읽는 동안 그 첫 재생을 건너뛴다(첫 재생이 무음).
// 같은 파일을 처음 요청할 때는 볼륨 0으로 0.15초 재생해 준비시킨 뒤, 멈추고 처음부터 정상 볼륨으로 다시 재생한다.
// 그다음부터는 준비된 파일로 기록해 바로 재생한다.
globals
    hashtable SiegSndHT = InitHashtable()
    real array SiegLastHitT
endglobals

private struct SiegSndPrep
    sound s
    unit u
    integer vol
endstruct

private function SiegSndPrepFire takes nothing returns nothing
    local tick t = tick.getExpired()
    local SiegSndPrep d = t.data
    call StopSound(d.s, false, false)
    call SetSoundVolume(d.s, d.vol)
    call SetSoundPosition(d.s, GetWidgetX(d.u), GetWidgetY(d.u), 50)
    call StartSound(d.s)
    call KillSoundWhenDone(d.s)
    set d.s = null
    set d.u = null
    call d.destroy()
    set t.data = 0
    call t.destroy()
endfunction

function SiegPlaySound takes unit u, integer i returns nothing
    local sound s
    local string p
    local integer vol = 110
    local SiegSndPrep d
    local tick t
    if SiegSndC[i] <= 0 or (SiegSndVoice[i] and not SiegVoiceOn) then
        return
    endif
    set p = SiegSndPath[SiegSndA[i] + GetRandomInt(0, SiegSndC[i] - 1)]
    set s = CreateSound(p, false, true, true, 10, 10, "CombatSoundsEAX")
    if SiegSndVoice[i] then
        // 음성: 카메라가 멀어도 작아지지 않도록 넓게(파일 자체도 키워 둠)
        set vol = 127
        call SetSoundDistances(s, 3000, 7000)
        call SetSoundDistanceCutoff(s, 7000)
    else
        set vol = 100
        call SetSoundDistances(s, 1500, 5000)
        call SetSoundDistanceCutoff(s, 5000)
    endif
    call SetSoundPosition(s, GetWidgetX(u), GetWidgetY(u), 50)
    if LoadBoolean(SiegSndHT, StringHash(p), 0) then
        call SetSoundVolume(s, vol)
        call StartSound(s)
        call KillSoundWhenDone(s)
    else
        call SaveBoolean(SiegSndHT, StringHash(p), 0, true)
        call SetSoundVolume(s, 0)
        call StartSound(s)
        set d = SiegSndPrep.create()
        set d.s = s
        set d.u = u
        set d.vol = vol
        set t = tick.create(0)
        set t.data = d
        call t.start(0.15, false, function SiegSndPrepFire)
    endif
    set s = null
endfunction

// 타격음(지면 타격·바위 충돌 등)은 적에게 맞았을 때만 낸다: 0.12초 뒤에 확인해서
// 그 사이(앞뒤 0.3초 안)에 이 영웅의 공격이 적에게 맞았으면 재생한다.
private struct SiegHitSnd
    unit u
    integer pid
    integer i
    real at
endstruct

private function SiegHitSndFire takes nothing returns nothing
    local tick t = tick.getExpired()
    local SiegHitSnd h = t.data
    if SiegLastHitT[h.pid] >= h.at - 0.30 then
        call SiegPlaySound(h.u, h.i)
    endif
    set h.u = null
    call h.destroy()
    set t.data = 0
    call t.destroy()
endfunction

function SiegPlayHitSound takes unit u, integer pid, integer i returns nothing
    local SiegHitSnd h = SiegHitSnd.create()
    local tick t = tick.create(0)
    set h.u = u
    set h.pid = pid
    set h.i = i
    set h.at = SiegNow()
    set t.data = h
    call t.start(0.12, false, function SiegHitSndFire)
endfunction

// ---------------------------------------------------------------------------
// 확인용 표시(-siegtest): 휘두르기 표의 타격 순간에, 데이터가 계산한 칼끝 위치에 파란 구슬을 1.5초 찍는다.
// 게임에서 구슬이 칼끝에 붙어 있으면 칼 궤적 데이터(뷰어 계산)가 맞는 것이다. 원의 중심에는 작은 노란 구슬.
globals
    boolean array SiegDebug
    boolean array SiegDebugSlow
    integer SiegDebugIdx = 0
endglobals

function SiegDebugMark takes unit u, integer i returns nothing
    local real f = GetUnitFacing(u) * bj_DEGTORAD
    local real yaw = SiegSwYaw[i] * bj_DEGTORAD
    local real pitch = SiegSwPitch[i] * bj_DEGTORAD
    local real r = SiegSwR[i]
    // 모델 기준 칼끝 = 중심 + 반지름 x (궤적 원의 X축)
    local real tx = SiegSwX[i] + r * Cos(pitch) * Cos(yaw)
    local real ty = SiegSwY[i] + r * Cos(pitch) * Sin(yaw)
    local real tz = SiegSwZ[i] - r * Sin(pitch)
    local real wx = GetWidgetX(u) + tx * Cos(f) - ty * Sin(f)
    local real wy = GetWidgetY(u) + tx * Sin(f) + ty * Cos(f)
    local integer pid = GetPlayerId(GetOwningPlayer(u))
    local effect e = AddSpecialEffect("Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl", wx, wy)
    call EXSetEffectSize(e, 0.8)
    call EXSetEffectZ(e, EXGetEffectZ(e) + tz)
    call SiegFxKeep(e, null, 1.5)
    set wx = GetWidgetX(u) + SiegSwX[i] * Cos(f) - SiegSwY[i] * Sin(f)
    set wy = GetWidgetY(u) + SiegSwX[i] * Sin(f) + SiegSwY[i] * Cos(f)
    set e = AddSpecialEffect("Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl", wx, wy)
    call EXSetEffectSize(e, 0.4)
    call EXSetEffectZ(e, EXGetEffectZ(e) + SiegSwZ[i])
    call SiegFxKeep(e, null, 1.5)
    set e = null
    call DisplayTimedTextToPlayer(GetOwningPlayer(u), 0, 0, 3, "[지크 확인] 모션 " + I2S(i / 4) + " 휘두르기 " + I2S(ModuloInteger(i, 4)) + "  칼끝 높이 " + I2S(R2I(tz)) + "  반지름 " + I2S(R2I(r)))
endfunction

private struct SiegAnimEv
    unit u
    integer pid
    integer serial
    integer kind
    integer i
    boolean just
endstruct

private function SiegAnimEvFire takes nothing returns nothing
    local tick t = tick.getExpired()
    local SiegAnimEv ev = t.data
    if ev.serial == SiegAnimSerial[ev.pid] and not IsUnitDeadVJ(ev.u) then
        if ev.kind == 0 then
            call SiegSlash(ev.u, ev.i, ev.just)
        elseif ev.kind == 2 then
            call SiegDebugMark(ev.u, ev.i)
        elseif SiegSndHit[ev.i] then
            call SiegPlayHitSound(ev.u, ev.pid, ev.i)
        else
            call SiegPlaySound(ev.u, ev.i)
        endif
    endif
    set ev.u = null
    call ev.destroy()
    set t.data = 0
    call t.destroy()
endfunction

private function SiegAnimEvAt takes unit u, integer pid, integer kind, integer i, boolean just, real at returns nothing
    local SiegAnimEv ev = SiegAnimEv.create()
    local tick t = tick.create(0)
    set ev.u = u
    set ev.pid = pid
    set ev.serial = SiegAnimSerial[pid]
    set ev.kind = kind
    set ev.i = i
    set ev.just = just
    set t.data = ev
    call t.start(RMaxBJ(0.01, at), false, function SiegAnimEvFire)
endfunction

// 모션 재생 + 그 모션의 칼 궤적 이펙트와 원작 사운드를 시각에 맞춰 예약한다.
// 새 모션을 걸면 앞 모션에 남은 예약은 취소된다.
function SiegAnimJust takes unit u, integer anim, real speed, boolean just returns nothing
    local integer pid = GetPlayerId(GetOwningPlayer(u))
    local integer k = 0
    set SiegAnimSerial[pid] = SiegAnimSerial[pid] + 1
    call AnimationStart3(u, anim, speed)
    loop
        exitwhen k >= SiegSwN[anim]
        call SiegAnimEvAt(u, pid, 0, anim * 4 + k, just, (SiegSwT0[anim * 4 + k] + 0.01) / speed)
        if SiegDebug[pid] then
            call SiegAnimEvAt(u, pid, 2, anim * 4 + k, just, SiegSwHit[anim * 4 + k] / speed)
        endif
        set k = k + 1
    endloop
    set k = 0
    loop
        exitwhen k >= SiegSndN[anim]
        call SiegAnimEvAt(u, pid, 1, anim * 12 + k, false, (SiegSndT[anim * 12 + k] + 0.01) / speed)
        set k = k + 1
    endloop
endfunction

function SiegAnim takes unit u, integer anim, real speed returns nothing
    call SiegAnimJust(u, anim, speed, false)
endfunction

// 맞은 대상 타격 불꽃
function SiegFxHit takes real x, real y, integer pid returns nothing
    if SiegOff[pid * 8 + 4] then
        return
    endif
    call SiegFxAt(SIEG_FX_SPARK, x, y, 90, 0.55, GetRandomReal(0, 360), 0.35, pid)
endfunction

// 영웅 몸을 잠깐 붉게 물들인다(저스트·오라). 같은 영웅에 겹치면 마지막 것만 원래 색으로 돌린다.
globals
    integer array SiegTintSerial
endglobals

private struct SiegTintData
    unit u
    integer pid
    integer serial
endstruct

private function SiegTintEnd takes nothing returns nothing
    local tick t = tick.getExpired()
    local SiegTintData d = t.data
    if d.serial == SiegTintSerial[d.pid] then
        call SetUnitVertexColor(d.u, 255, 255, 255, 255)
    endif
    set d.u = null
    call d.destroy()
    set t.data = 0
    call t.destroy()
endfunction

function SiegTint takes unit u, integer pid, real dur returns nothing
    local SiegTintData d = SiegTintData.create()
    local tick t = tick.create(0)
    set SiegTintSerial[pid] = SiegTintSerial[pid] + 1
    set d.u = u
    set d.pid = pid
    set d.serial = SiegTintSerial[pid]
    set t.data = d
    call SetUnitVertexColor(u, 255, 70, 60, 255)
    call t.start(dur, false, function SiegTintEnd)
endfunction

// 저스트 성공 표시: 몸이 붉게 빛나며 붉은 방사 섬광 + 흰 십자 별빛
function SiegFxJust takes unit u, integer pid returns nothing
    call SiegFxAtU(SIEG_FX_FLASH, u, GetWidgetX(u), GetWidgetY(u), 150, 1.0, 0, pid)
    call SiegTint(u, pid, 0.30)
endfunction

// 찌르기: 정면으로 뻗는 빛줄기 + 칼끝 섬광
function SiegFxThrust takes unit u, integer pid returns nothing
    local real f = GetUnitFacing(u)
    call SiegFxAtU(SIEG_FX_FLASH, u, GetWidgetX(u) + PolarX(240, f), GetWidgetY(u) + PolarY(240, f), 120, 1.1, f, pid)
    call SiegFxAt(SIEG_FX_SPARK, GetWidgetX(u) + PolarX(240, f), GetWidgetY(u) + PolarY(240, f), 120, 0.7, f, 0.3, pid)
endfunction

// 내려찍기: 진홍 빛기둥 + 바닥 균열 + 충격 고리 + 흙 파편
function SiegFxSlam takes real x, real y, real f, real size, integer pid returns nothing
    call SiegFxAt(SIEG_FX_PILLAR, x, y, 0, size, f, 0, pid)
    call SiegFxAt(SIEG_FX_CRACK, x, y, 0, size * 1.1, GetRandomReal(0, 360), 0, pid)
    call SiegFxAt(SIEG_FX_SHOCK, x, y, 0, size * 1.2, 0, 0, pid)
    call SiegFxAt(SIEG_FX_DEBRIS, x, y, 40, size * 1.2, f, 0.4, pid)
endfunction

// 타격 지점 연출(흙 파편 + 연기)
function SiegFxBurst takes real x, real y, real f, integer pid returns nothing
    call SiegFxAt(SIEG_FX_DEBRIS, x, y, 40, 1.0, f, 0.4, pid)
    call SiegFxAt(SIEG_FX_SMOKE, x, y, 30, 1.2, f, 0.4, pid)
endfunction

// 지면 충격: 충격 고리 + 파편
function SiegFxQuake takes real x, real y, integer pid returns nothing
    call SiegFxAt(SIEG_FX_SHOCK, x, y, 0, 1.4, 0, 0, pid)
    call SiegFxAt(SIEG_FX_DEBRIS, x, y, 40, 1.4, 0, 0.4, pid)
endfunction

// 강화 시전: 몸에서 붉은 오라가 피어오른다(dur초) + 붉은 섬광
function SiegFxAura takes unit u, integer pid returns nothing
    local effect e = AddSpecialEffectTarget(SiegFxPath(SIEG_FX_AURA2, pid), u, "origin")
    local SiegFxKill k = SiegFxKill.create()
    local tick t = tick.create(0)
    set k.e = e
    set t.data = k
    call t.start(2.5, false, function SiegFxKillFunc)
    call SiegFxAtU(SIEG_FX_FLASH, u, GetWidgetX(u), GetWidgetY(u), 150, 1.3, 0, pid)
    call SiegTint(u, pid, 0.6)
    set e = null
endfunction

// 직선으로 이어지는 연출(가시벽·지면 분출): 시작점에서 f 방향으로 d0~d1 사이를 gap 간격, interval초 간격으로 차례로 놓는다.
private struct SiegLineFx
    string path
    real x
    real y
    real f
    real d
    real d1
    real gap
    real size
    real interval
    integer pid
endstruct

private function SiegFxLineTick takes nothing returns nothing
    local tick t = tick.getExpired()
    local SiegLineFx l = t.data
    local real side = GetRandomReal(-30, 30)
    call SiegFxAt(l.path, l.x + PolarX(l.d, l.f) + PolarX(side, l.f + 90), l.y + PolarY(l.d, l.f) + PolarY(side, l.f + 90), 0, l.size * GetRandomReal(0.85, 1.15), GetRandomReal(0, 360), 0, l.pid)
    set l.d = l.d + l.gap
    if l.d > l.d1 then
        call l.destroy()
        set t.data = 0
        call t.destroy()
    else
        call t.start(l.interval, false, function SiegFxLineTick)
    endif
endfunction

function SiegFxLine takes string path, real x, real y, real f, real d0, real d1, real gap, real size, real interval, integer pid returns nothing
    local SiegLineFx l = SiegLineFx.create()
    local tick t = tick.create(0)
    set l.path = path
    set l.x = x
    set l.y = y
    set l.f = f
    set l.d = d0
    set l.d1 = d1
    set l.gap = gap
    set l.size = size
    set l.interval = interval
    set l.pid = pid
    set t.data = l
    call t.start(0.0, false, function SiegFxLineTick)
endfunction

// 불꽃 폭발 (바닥 기준)
function SiegFxFire takes real x, real y, real f, integer pid returns nothing
    call SiegFxAt(SIEG_FX_FIRE, x, y, 60, 1.6, f, 1.0, pid)
endfunction

// ---------------------------------------------------------------------------
// 로컬 판정: 키를 누른 클라이언트에서 판정하고 결과를 동기화 데이터에 싣는다.
// 1 = 새 콤보, e = 빠름(대기 후 일반), q = 빠름(대기 후 저스트, 용기 해방 중), j = 저스트, n = 늦음(일반)
function SiegLocalComboCode takes integer pid returns string
    local real now = SiegNow()
    if SiegStage[pid] == 0 or now > SiegComboEnd[pid] then
        return "1"
    endif
    if now < SiegHitT[pid] then
        if SiegZOn[pid] then
            return "q"
        endif
        return "e"
    endif
    if SiegZOn[pid] then
        return "j"
    endif
    if now <= SiegWinEnd[pid] then
        return "j"
    endif
    return "n"
endfunction

function SiegLocalFinishCode takes integer pid returns string
    local real now = SiegNow()
    if SiegFLock[pid] then
        return "x"
    endif
    if SiegFOpen[pid] and now >= SiegFHit[pid] and now <= SiegFEnd[pid] then
        return "j"
    endif
    // 5단 전 저스트 중 창이 열리기 전에 누름
    if SiegStage[pid] == 5 and SiegStageAnim[pid] == 119 and now < SiegFHit[pid] then
        return "e"
    endif
    return "x"
endfunction

function SiegLocalWindowCode takes integer pid returns string
    local real now = SiegNow()
    if SiegStage[pid] > 0 and SiegStage[pid] < 5 and now >= SiegHitT[pid] and now <= SiegWinEnd[pid] then
        return "j"
    endif
    if SiegZOn[pid] and SiegStage[pid] > 0 and now <= SiegComboEnd[pid] then
        return "j"
    endif
    return "n"
endfunction

private function KeyDown takes nothing returns nothing
    local integer key = DzGetTriggerKey()
    local integer i = GetPlayerId(DzGetTriggerKeyPlayer())
    local string pos
    local unit u = MainUnit[i]

    if not SiegIsHero(u) then
        set u = null
        return
    endif
    if JNMemoryGetByte(JNGetModuleHandle("Game.dll") + 0xD04FEC) != 0 then
        set u = null
        return
    endif
    set pos = R2S(DzGetMouseTerrainX()) + ";" + R2S(DzGetMouseTerrainY())

    if key == JN_OSKEY_C then
        call DzSyncData("SiegC", pos + ";" + SiegLocalComboCode(i))
    elseif key == JN_OSKEY_F then
        call DzSyncData("SiegF", pos + ";" + SiegLocalFinishCode(i))
    elseif key == JN_OSKEY_Q then
        if EXGetAbilityState(EXGetUnitAbility(u, HeroSkillID0[SIEG_INDEX]), ABILITY_STATE_COOLDOWN) == 0 then
            call DzSyncData("SiegQ", pos + ";" + SiegLocalWindowCode(i))
        endif
    elseif key == JN_OSKEY_W then
        if EXGetAbilityState(EXGetUnitAbility(u, HeroSkillID1[SIEG_INDEX]), ABILITY_STATE_COOLDOWN) == 0 then
            call DzSyncData("SiegW", pos)
        endif
    elseif key == JN_OSKEY_E then
        if EXGetAbilityState(EXGetUnitAbility(u, HeroSkillID2[SIEG_INDEX]), ABILITY_STATE_COOLDOWN) == 0 then
            call DzSyncData("SiegE", pos)
        endif
    elseif key == JN_OSKEY_R then
        if EXGetAbilityState(EXGetUnitAbility(u, HeroSkillID3[SIEG_INDEX]), ABILITY_STATE_COOLDOWN) == 0 then
            call DzSyncData("SiegR", pos)
        endif
    elseif key == JN_OSKEY_A then
        if EXGetAbilityState(EXGetUnitAbility(u, HeroSkillID4[SIEG_INDEX]), ABILITY_STATE_COOLDOWN) == 0 then
            call DzSyncData("SiegA", pos)
        endif
    elseif key == JN_OSKEY_S then
        if EXGetAbilityState(EXGetUnitAbility(u, HeroSkillID5[SIEG_INDEX]), ABILITY_STATE_COOLDOWN) == 0 then
            call DzSyncData("SiegS", pos)
        endif
    elseif key == JN_OSKEY_D then
        if EXGetAbilityState(EXGetUnitAbility(u, HeroSkillID6[SIEG_INDEX]), ABILITY_STATE_COOLDOWN) == 0 then
            call DzSyncData("SiegD", pos)
        endif
    elseif key == JN_OSKEY_Z then
        if EXGetAbilityState(EXGetUnitAbility(u, HeroSkillID10[SIEG_INDEX]), ABILITY_STATE_COOLDOWN) == 0 and SiegStack[i] >= SIEG_MAX_STACK then
            call DzSyncData("SiegZ", pos)
        endif
    endif
    set u = null
endfunction

private function KeyUp takes nothing returns nothing
    local integer key = DzGetTriggerKey()
    local integer i = GetPlayerId(DzGetTriggerKeyPlayer())
    if key == JN_OSKEY_E and SiegIsHero(MainUnit[i]) then
        call DzSyncData("SiegE2", R2S(DzGetMouseTerrainX()) + ";" + R2S(DzGetMouseTerrainY()))
    endif
endfunction

// ---------------------------------------------------------------------------
// 타이밍 게이지: 첸 F와 같은 공용 캐스팅바를 쓰고, 막대는 가리지 않는다.
//  - 저스트 구간은 막대 아래 노란 줄 + 양 끝 눈금으로 표시 (파이널 피니시는 보라)
//  - 글자는 막대 위에 따로 띄운다
//  - 입력이 이미 들어가서(일찍 눌러 일반으로 예약) 더 누를 수 없으면 게이지를 끈다
globals
    private constant real GAUGE_L = .320 + .0025
    private constant real GAUGE_R = .480 - .0025
    private constant real GAUGE_T = .1800
    private constant real GAUGE_B = .1700
    private integer GaugeMode = -1
    private boolean GaugeShown = false
    private integer GaugeTick1 = 0
    private integer GaugeTick2 = 0
    private integer GaugeLabel = 0
endglobals

// 점을 하나씩 옮기면 그 사이 한 프레임 동안 이전 점과 새 점에 걸쳐 엉뚱한 곳(체력바 쪽)에 그려진다.
// 그래서 숨긴 상태에서 점을 모두 지우고 다시 잡은 뒤 보여 준다.
private function GaugePut takes integer f, real x1, real y1, real x2, real y2 returns nothing
    call DzFrameClearAllPoints(f)
    call DzFrameSetAbsolutePoint(f, JN_FRAMEPOINT_TOPLEFT, x1, y1)
    call DzFrameSetAbsolutePoint(f, JN_FRAMEPOINT_BOTTOMRIGHT, x2, y2)
endfunction

private function GaugeHide takes nothing returns nothing
    if not GaugeShown then
        return
    endif
    set GaugeShown = false
    // 숨김이 듣지 않는 경우가 있어 화면 밖으로도 옮긴다(원래 방식 유지)
    call GaugePut(SiegGaugeWin, -1, -1, -1, -1)
    call GaugePut(GaugeTick1, -1, -1, -1, -1)
    call GaugePut(GaugeTick2, -1, -1, -1, -1)
    call DzFrameShow(SiegGaugeWin, false)
    call DzFrameShow(GaugeTick1, false)
    call DzFrameShow(GaugeTick2, false)
    call DzFrameShow(GaugeLabel, false)
    call CastingBarShow(GetLocalPlayer(), false)
endfunction

// a, b: 저스트 구간의 시작·끝 위치 (0~1)
private function GaugePlace takes real a, real b returns nothing
    local real w = GAUGE_R - GAUGE_L
    local real xa = GAUGE_L + w * a
    local real xb = GAUGE_L + w * b
    // 막대 바로 아래 줄
    call GaugePut(SiegGaugeWin, xa, GAUGE_B - .0005, xb, GAUGE_B - .0040)
    // 양 끝 눈금 (막대 높이를 관통하는 얇은 선)
    call GaugePut(GaugeTick1, xa - .0006, GAUGE_T + .0015, xa + .0006, GAUGE_B - .0040)
    call GaugePut(GaugeTick2, xb - .0006, GAUGE_T + .0015, xb + .0006, GAUGE_B - .0040)
    if not GaugeShown then
        set GaugeShown = true
        call CastingBarShow(GetLocalPlayer(), true)
        call DzFrameSetText(CastingTextFrame, "")
        call DzFrameShow(GaugeLabel, true)
        call DzFrameShow(SiegGaugeWin, true)
        call DzFrameShow(GaugeTick1, true)
        call DzFrameShow(GaugeTick2, true)
    endif
endfunction

// 0 = 콤보 저스트(노랑), 1 = 파이널 피니시(보라)
private function GaugeSetMode takes integer mode returns nothing
    local string tex = "ReplaceableTextures\\TeamColor\\TeamColor04.blp"
    if mode == GaugeMode then
        return
    endif
    set GaugeMode = mode
    if mode == 1 then
        set tex = "ReplaceableTextures\\TeamColor\\TeamColor03.blp"
    endif
    call DzFrameSetTexture(SiegGaugeWin, tex, 0)
    call DzFrameSetTexture(GaugeTick1, tex, 0)
    call DzFrameSetTexture(GaugeTick2, tex, 0)
endfunction

private function GaugeUpdate takes nothing returns nothing
    local integer pid = GetPlayerId(GetLocalPlayer())
    local real now = SiegNow()
    local real s
    local real e
    local real a
    local real b
    local boolean show = false
    local boolean finish = false

    if SiegGaugeWin == 0 then
        return
    endif
    if not SiegIsHero(MainUnit[pid]) then
        call GaugeHide()
        call DzFrameShow(SiegStackText, false)
        return
    endif

    call DzFrameShow(SiegStackText, true)
    call DzFrameSetText(SiegStackText, "용기 " + I2S(SiegStack[pid]) + " / " + I2S(SIEG_MAX_STACK))

    if SiegStage[pid] == 5 and SiegStageAnim[pid] == 119 and now <= SiegFEnd[pid] + 0.10 then
        // 5단 전 저스트가 시작되면 F 사용 가능 구간. 창 밖에서 누르면 실패로 잠긴다.
        set show = true
        set finish = true
        set s = SiegFStart[pid]
        set e = SiegFEnd[pid] + 0.10
        set a = SiegFHit[pid]
        set b = SiegFEnd[pid]
    elseif SiegStage[pid] > 0 and SiegStage[pid] < 5 and not SiegQueued[pid] and SiegPendStage[pid] == 0 and now <= SiegWinEnd[pid] + 0.10 then
        set show = true
        set s = SiegStageStart[pid]
        set e = SiegWinEnd[pid] + 0.10
        set a = SiegHitT[pid]
        set b = SiegWinEnd[pid]
    endif

    if not show or e <= s then
        call GaugeHide()
        return
    endif

    if finish then
        call GaugeSetMode(1)
    else
        call GaugeSetMode(0)
    endif
    call GaugePlace((a - s) / (e - s), (b - s) / (e - s))
    call DzFrameSetValue(CastingBar, RMinBJ(25.0, RMaxBJ(0, (now - s) / (e - s) * 25.0)))
    if finish then
        if SiegFLock[pid] then
            call DzFrameSetText(GaugeLabel, "|cffff4040파이널 피니시 실패|r")
        elseif now >= a and now <= b then
            call DzFrameSetText(GaugeLabel, "|cffff80ff파이널 피니시! (F)|r")
        else
            call DzFrameSetText(GaugeLabel, "파이널 피니시 (F)")
        endif
    elseif now >= a and now <= b then
        call DzFrameSetText(GaugeLabel, "|cffffff00저스트!|r")
    else
        call DzFrameSetText(GaugeLabel, "아스칼론 " + I2S(SiegStage[pid]) + "단")
    endif
endfunction

private function GaugeCreate takes nothing returns nothing
    set SiegGaugeWin = DzCreateFrameByTagName("BACKDROP", "", GetGameplayUI(), "", FrameCount())
    set GaugeTick1 = DzCreateFrameByTagName("BACKDROP", "", GetGameplayUI(), "", FrameCount())
    set GaugeTick2 = DzCreateFrameByTagName("BACKDROP", "", GetGameplayUI(), "", FrameCount())
    set GaugeMode = -1
    call GaugeSetMode(0)
    call GaugePut(SiegGaugeWin, -1, -1, -1, -1)
    call GaugePut(GaugeTick1, -1, -1, -1, -1)
    call GaugePut(GaugeTick2, -1, -1, -1, -1)
    call DzFrameShow(SiegGaugeWin, false)
    call DzFrameShow(GaugeTick1, false)
    call DzFrameShow(GaugeTick2, false)

    set GaugeLabel = DzCreateFrameByTagName("TEXT", "", GetGameplayUI(), "", FrameCount())
    call DzFrameSetAbsolutePoint(GaugeLabel, JN_FRAMEPOINT_CENTER, .400, .1880)
    call DzFrameSetFont(GaugeLabel, "Fonts\\DFHeiMd.ttf", 0.010, 0)
    call DzFrameSetText(GaugeLabel, "")
    call DzFrameShow(GaugeLabel, false)

    set SiegStackText = DzCreateFrameByTagName("TEXT", "", GetGameplayUI(), "", FrameCount())
    call DzFrameSetAbsolutePoint(SiegStackText, JN_FRAMEPOINT_LEFT, .483, .1750)
    call DzFrameSetFont(SiegStackText, "Fonts\\DFHeiMd.ttf", 0.009, 0)
    call DzFrameSetText(SiegStackText, "")
    call DzFrameShow(SiegStackText, false)
    call TimerStart(CreateTimer(), 0.02, true, function GaugeUpdate)
endfunction

// ---------------------------------------------------------------------------
// 회피(X)는 진행 중인 콤보와 자세를 끊는다.
private function OnDash takes nothing returns nothing
    local integer id = GetSpellAbilityId()
    local integer pid
    if (id == 'A004' or id == 'A005' or id == 'A006') and SiegIsHero(GetTriggerUnit()) then
        set pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        call SiegResetCombo(pid)
        set SiegBusy[pid] = false
        if SiegStance[pid] then
            set SiegStance[pid] = false
            set HeroParryOn[pid] = false
        endif
    endif
endfunction

// 콤보 사이에 이동 명령(우클릭·이동)을 내리면 콤보를 끊는다. 공격 중 묶여 있을 때(B000)는 무시.
private function OnOrder takes nothing returns nothing
    local unit u = GetTriggerUnit()
    local integer id = GetIssuedOrderId()
    local integer pid
    if (id == 851971 or id == 851986) and SiegIsHero(u) then
        set pid = GetPlayerId(GetOwningPlayer(u))
        if SiegStage[pid] > 0 and not SiegBusy[pid] and GetUnitAbilityLevel(u, 'B000') < 1 then
            call SiegResetCombo(pid)
        endif
    endif
    set u = null
endfunction

private struct TEvMapLoad extends array
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t, function thistype.Action)
        call TriggerRegisterTimerEvent(t, 0.04, false)
        set t = null
    endmethod
    private static method Action takes nothing returns nothing
        call DzTriggerRegisterKeyEventByCode(null, JN_OSKEY_C, 1, false, function KeyDown)
        call DzTriggerRegisterKeyEventByCode(null, JN_OSKEY_F, 1, false, function KeyDown)
        call DzTriggerRegisterKeyEventByCode(null, JN_OSKEY_Q, 1, false, function KeyDown)
        call DzTriggerRegisterKeyEventByCode(null, JN_OSKEY_W, 1, false, function KeyDown)
        call DzTriggerRegisterKeyEventByCode(null, JN_OSKEY_E, 1, false, function KeyDown)
        call DzTriggerRegisterKeyEventByCode(null, JN_OSKEY_R, 1, false, function KeyDown)
        call DzTriggerRegisterKeyEventByCode(null, JN_OSKEY_A, 1, false, function KeyDown)
        call DzTriggerRegisterKeyEventByCode(null, JN_OSKEY_S, 1, false, function KeyDown)
        call DzTriggerRegisterKeyEventByCode(null, JN_OSKEY_D, 1, false, function KeyDown)
        call DzTriggerRegisterKeyEventByCode(null, JN_OSKEY_Z, 1, false, function KeyDown)
        call DzTriggerRegisterKeyEventByCode(null, JN_OSKEY_C, 0, false, function KeyUp)
        call DzTriggerRegisterKeyEventByCode(null, JN_OSKEY_F, 0, false, function KeyUp)
        call DzTriggerRegisterKeyEventByCode(null, JN_OSKEY_Q, 0, false, function KeyUp)
        call DzTriggerRegisterKeyEventByCode(null, JN_OSKEY_W, 0, false, function KeyUp)
        call DzTriggerRegisterKeyEventByCode(null, JN_OSKEY_E, 0, false, function KeyUp)
        call DzTriggerRegisterKeyEventByCode(null, JN_OSKEY_R, 0, false, function KeyUp)
        call DzTriggerRegisterKeyEventByCode(null, JN_OSKEY_A, 0, false, function KeyUp)
        call DzTriggerRegisterKeyEventByCode(null, JN_OSKEY_S, 0, false, function KeyUp)
        call DzTriggerRegisterKeyEventByCode(null, JN_OSKEY_D, 0, false, function KeyUp)
        call DzTriggerRegisterKeyEventByCode(null, JN_OSKEY_Z, 0, false, function KeyUp)
    endmethod
endstruct

private function SiegDebugChat takes nothing returns nothing
    local integer pid = GetPlayerId(GetTriggerPlayer())
    local integer k
    if GetEventPlayerChatString() == "-siegtest" then
        set SiegDebug[pid] = not SiegDebug[pid]
        if SiegDebug[pid] then
            call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0, 0, 5, "[지크 확인] 칼끝 표시 켬: 파란 구슬 = 데이터상 칼끝(타격 순간), 노란 구슬 = 궤적 원 중심")
        else
            call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0, 0, 5, "[지크 확인] 칼끝 표시 끔")
        endif
    elseif SubString(GetEventPlayerChatString(), 0, 8) == "-siegoff" then
        set k = S2I(SubString(GetEventPlayerChatString(), 8, 9))
        if k >= 1 and k <= 5 then
            set SiegOff[pid * 8 + k] = not SiegOff[pid * 8 + k]
            if SiegOff[pid * 8 + k] then
                call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0, 0, 8, "[지크 확인] 끔: " + I2S(k) + " (1 말굽궤적 2 착지궤적 3 땅터짐 4 타격불꽃 5 도약먼지·저스트섬광)")
            else
                call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0, 0, 8, "[지크 확인] 켬: " + I2S(k))
            endif
        endif
    elseif GetEventPlayerChatString() == "-siegslow" then
        set SiegDebugSlow[pid] = not SiegDebugSlow[pid]
        if SiegDebugSlow[pid] then
            call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0, 0, 5, "[지크 확인] 느린 재생 켬 (0.35배)")
        else
            call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0, 0, 5, "[지크 확인] 느린 재생 끔")
        endif
    endif
endfunction

private function SiegClockWrap takes nothing returns nothing
    set SiegClockBase = SiegClockBase + 100.0
endfunction

private function Init takes nothing returns nothing
    local trigger t
    // 게임 시간 기준 시계. 모든 클라이언트에서 같은 값을 읽는다.
    call TimerStart(SiegClock, 100.0, true, function SiegClockWrap)
    // 확인용 채팅 명령: -siegtest(칼끝 표시), -siegslow(느린 재생)
    set t = CreateTrigger()
    set SiegDebugIdx = 0
    loop
        exitwhen SiegDebugIdx > 11
        call TriggerRegisterPlayerChatEvent(t, Player(SiegDebugIdx), "-siegtest", true)
        call TriggerRegisterPlayerChatEvent(t, Player(SiegDebugIdx), "-siegslow", true)
        call TriggerRegisterPlayerChatEvent(t, Player(SiegDebugIdx), "-siegoff", false)
        set SiegDebugIdx = SiegDebugIdx + 1
    endloop
    call TriggerAddAction(t, function SiegDebugChat)

    // 지상 콤보 (모션 인덱스, 타격 시점들, 판정 기준 타격 순번)
    // 타격 시점 = 모델의 칼끝이 정면을 지나는 순간(HeroSiegData의 휘두르기 표와 같은 분석)
    call SiegSetHit(104, 0.45, 0, 0, 0, 0)
    call SiegSetHit(105, 0.48, 0, 0, 0, 0)
    call SiegSetHit(106, 0.62, 0, 0, 0, 0)
    call SiegSetHit(107, 0.67, 0, 0, 0, 0)
    call SiegSetHit(108, 0.63, 0, 0, 0, 0)
    call SiegSetHit(109, 0.62, 0, 0, 0, 0)
    call SiegSetHit(110, 0.17, 0.67, 0, 0, 1)
    call SiegSetHit(111, 0.93, 0, 0, 0, 0)
    call SiegSetHit(112, 0.60, 0, 0, 0, 0)
    call SiegSetHit(113, 0.67, 0, 0, 0, 0)
    call SiegSetHit(114, 0.65, 0, 0, 0, 0)
    call SiegSetHit(115, 0.87, 1.62, 0, 0, 1)
    call SiegSetHit(116, 0.67, 0, 0, 0, 0)
    // #117은 앞에서 한 번 휘두른 뒤(0.2~0.35초) 0.63~0.67초에 찌른다: 저스트 기준은 찌르는 순간
    call SiegSetHit(117, 0.65, 0, 0, 0, 0)
    call SiegSetHit(118, 0.87, 1.62, 0, 0, 1)
    // 5단 전 저스트: 마지막 내려찍기(1.98초)가 파이널 피니시 입력 시점
    call SiegSetHit(119, 0.90, 1.35, 1.98, 0, 2)

    set t = CreateTrigger()
    call TriggerAddAction(t, function GaugeCreate)
    call TriggerRegisterTimerEventSingle(t, 0.50)

    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function OnDash)

    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER)
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER)
    call TriggerAddAction(t, function OnOrder)
    set t = null
endfunction
endscope
