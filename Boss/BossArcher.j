/*
    아쳐 보스 (Fate/stay night)

    - 이동 능력과 일반 AI 없이 0.02초 전투 틱 하나가 모든 행동을 직접 제어한다.
    - 1페이즈: HP 1 아래로 내려가지 않음. HP 80·70·…·10%에서 영창 1~8을 순서대로 예약·재생.
    - 영창 8(10%): 진행 중 공격 취소, 피해 잠금, 전장 타일·배경 변경, 최대 체력까지 회복 후 2페이즈.
    - 2페이즈(무한의 검제): 검의 비·검의 포위·검제 연속 공격이 추가되고 정상 처치 가능.

    패턴, 투사체, 예고 장판이 모두 전투 틱 안에서 진행되므로 취소는 이 문맥의 배열을 비우는 것으로 끝난다.
    지연 콜백이 없어서 이전 페이즈·이전 시도의 공격이 다음 전투에 피해를 주지 않는다.

    ※ 아래 "확정 필요" 표시가 있는 값은 임시값이다. 맵에 맞춰 바꿔야 한다.
*/
library BossArcher requires Tick,DataUnit,UIBossHP,DamageEffect2,UIBossEnd,DataMap,Boss1,BossAggro,ItemPickUp,UIMainQuest,UIPick,AnimationTime,CameraShaker,Euclid,Splash,PSound,Missile
    globals
        // ===== 확정 필요: 오브젝트 =====
        // 아쳐 유닛 rawcode 는 Data_Unit.j 의 ARCHER_UNIT_ID (모델 Archer.mdx)
        // Data_Unit.j 의 DataUnitIndex 번호
        constant integer ARCHER_DATA_INDEX = 27
        // 전장 테마 번호 (GetMap). 1=카운터 훈련, 2=그 외 보스가 사용 중
        private constant integer ARENA_THEMA = 3
        // 입장 대기 표식 (다른 보스와 같은 더미)
        private constant integer ENTRANCE_DUMMY = 'e01I'
        // 예고 장판 더미 (AOE.j 와 같은 원형 데칼)
        private constant integer DECAL_ID = 'h00H'

        // ===== 확정 필요: 이펙트 모델 (기본 워크래프트 모델로 임시 지정) =====
        private constant string FX_THROW_SWORD = "Abilities\\Weapons\\GlaiveMissile\\GlaiveMissile.mdl"
        private constant string FX_SNIPE_BOLT = "Abilities\\Weapons\\MoonPriestessMissile\\MoonPriestessMissile.mdl"
        private constant string FX_SNIPE_BOOM = "Objects\\Spawnmodels\\Other\\NeutralBuildingExplosion\\NeutralBuildingExplosion.mdl"
        private constant string FX_SNIPE_MARK = "Abilities\\Spells\\Other\\TalkToMe\\TalkToMe.mdl"
        private constant string FX_SLASH = "Abilities\\Spells\\Orc\\MirrorImage\\MirrorImageCaster.mdl"
        private constant string FX_SWORD_FALL = "Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl"
        private constant string FX_SWORD_STUCK = "Abilities\\Weapons\\GlaiveMissile\\GlaiveMissile.mdl"
        private constant string FX_COUNTER_READY = "Abilities\\Spells\\Human\\Defend\\DefendCaster.mdl"
        private constant string FX_TRANSITION = "Abilities\\Spells\\Human\\Resurrect\\ResurrectCaster.mdl"

        // ===== 확정 필요: 무한의 검제 전장 =====
        // 바꿀 타일. 0 이면 타일을 바꾸지 않는다. 맵 타일셋에 들어 있는 타일이어야 한다.
        private constant integer UBW_TILE = 'Ldrt'
        // 하늘 모델. "" 이면 바꾸지 않는다. 종료 시 UBW_SKY_RESTORE 로 되돌린다.
        private constant string UBW_SKY = ""
        private constant string UBW_SKY_RESTORE = ""
        // 바닥에 꽂힌 검 장식 수
        private constant integer UBW_STUCK_COUNT = 24

        // ===== 확정 필요: 음성 =====
        private string array ChantSound
        private real array ChantDur
        private string array ChantText
        private constant string FINAL_SOUND = "war3mapImported\\Archer_Final.mp3"

        // ===== 전투 수치 (테스트용 초안) =====
        // 시작 인원 1명 기준 체력은 Data_Unit.j UnitSetHP[ARCHER_DATA_INDEX]. 1명 추가마다 +70%
        private constant real PARTY_HP_BONUS = 0.70
        private constant real TICK = 0.02

        private constant real DMG_SLASH = 150
        private constant real DMG_DASH = 250
        private constant real DMG_THROW = 120
        private constant real DMG_SNIPE = 350
        private constant real DMG_SNIPE_BOOM = 200
        private constant real DMG_COUNTER = 300
        private constant real DMG_RAIN = 220
        private constant real DMG_RING = 250
        private constant real DMG_CORE = 300

        // 패턴 쿨다운(초)과 가중치
        private real array PatCool
        private integer array PatWeight

        // 검의 비 안전 통로 이동 시간 (가장 느린 캐릭터가 한 칸 이동할 수 있게)
        private constant real RAIN_FIRST_WARN = 2.4
        private constant real RAIN_NEXT_WARN = 2.2
        private constant integer RAIN_LANES = 5

        // 투사체 슬롯
        private constant integer MAXP = 8

        // 상태
        constant integer ARCHER_READY = 0
        constant integer ARCHER_PHASE1 = 1
        constant integer ARCHER_TRANSITION_PENDING = 2
        constant integer ARCHER_TRANSITION = 3
        constant integer ARCHER_PHASE2 = 4
        constant integer ARCHER_ENDED = 5

        // 아쳐 모델 애니메이션 인덱스 (Archer.mdx SEQS 순서)
        // 모델이 애니메이션마다 보이는 무기를 바꾼다 (지오셋 알파 기준)
        //  쌍검: stand, stand ready, attack 1/2, spell three(한 자루 투척)
        //  활: morph 후반, *alternate 계열, spell alternate three, spell channel four/five
        //  빈손: stand slam, spell one, attack slam, spell alternate one
        // 타격 시점(재생 1배속 기준): attack 1 약 0.38초, attack 2 약 0.35초, spell three 투척 약 0.2초,
        //  spell channel five 발사 직후, spell alternate two 착지 약 0.65초
        private constant integer AN_STAND = 0
        private constant integer AN_STAND_READY = 2
        private constant integer AN_ATTACK1 = 3
        private constant integer AN_ATTACK2 = 4
        private constant integer AN_SPELL_TWO = 6
        private constant integer AN_DEATH = 7
        private constant integer AN_SPELL_THREE = 8
        private constant integer AN_MORPH = 13
        private constant integer AN_STAND_ALT = 14
        private constant integer AN_STANDREADY_ALT = 16
        private constant integer AN_ATTACK_ALT = 17
        private constant integer AN_SPELL_ALT = 18
        private constant integer AN_SPELL_ALT_TWO = 19
        private constant integer AN_MORPH_ALT = 21
        private constant integer AN_STAND_SLAM = 22
        private constant integer AN_SPELL_ONE = 23
        private constant integer AN_ATTACK_SLAM = 24
        private constant integer AN_SPELL_ALT_ONE = 27
        private constant integer AN_SPELL_ALT_THREE = 28
        private constant integer AN_CHANNEL_FOUR = 29
        private constant integer AN_CHANNEL_FIVE = 30
        // 애니메이션 길이(초)와 반복 여부 (Archer.mdx)
        private real array AnimDur
        private boolean array AnimLoop

        integer array ArcherFightAt
        private hashtable TerrainSave = InitHashtable()
        private integer CheckFight = 0
    endglobals

    // ======================================================================
    // 전투 문맥
    // ======================================================================
    struct ArcherFight
        unit boss = null
        unit entrance = null
        party ul
        integer rect = 0
        integer state = ARCHER_READY
        real now = 0
        tick t
        // 반복하지 않는 동작이 끝나는 시각. 지나면 대기 동작으로 돌아간다 (0 이면 없음)
        real animEnd = 0

        unit array mem[6]
        integer array markCount[6]
        integer memN = 0

        // 영창
        integer chantReserved = 0
        integer chantDone = 0
        boolean chantPlaying = false
        real chantEnd = 0
        real transStart = 0
        integer transStep = 0

        // 패턴
        integer pat = 0
        integer step = 0
        real patStart = 0
        real nextSelect = 0
        integer lastPat = 0
        integer introIdx = 0
        integer combo = 0
        integer rainUsed = 0
        real array readyAt[8]

        // 고정 좌표·방향
        unit target = null
        real ax = 0
        real ay = 0
        real ang = 0
        real tx = 0
        real ty = 0
        real dashLeft = 0
        real dashSpeed = 0
        party hit
        group decals
        effect mark = null

        // 검의 비
        integer rainSafe = 0
        integer rainWave = 0
        integer rainWaves = 0
        real rainAng = 0
        real rainNext = 0
        boolean rainSnipe = false

        // 투사체: 1 회귀검, 2 저격탄
        integer array pk[8]
        effect array pe[8]
        real array px[8]
        real array py[8]
        real array pox[8]
        real array poy[8]
        real array pdir[8]
        real array pspd[8]
        real array ptrav[8]
        real array pmax[8]
        real array prad[8]
        real array pdmg[8]
        boolean array pback[8]
        party array phit[8]

        // 무한의 검제 장식
        effect array stuck[24]
        boolean terrainChanged = false

        method arenaCX takes nothing returns real
            return GetRectCenterX(MapRectReturn(this.rect))
        endmethod
        method arenaCY takes nothing returns real
            return GetRectCenterY(MapRectReturn(this.rect))
        endmethod
    endstruct

    // ======================================================================
    // 공용 도우미
    // ======================================================================
    private function AngDiff takes real a, real b returns real
        local real d = ModuloReal(a - b + 540.0, 360.0) - 180.0
        if d < 0 then
            return -d
        endif
        return d
    endfunction

    // 점 (x,y) 와 선분 (x1,y1)-(x2,y2) 사이 거리
    private function SegDist takes real x, real y, real x1, real y1, real x2, real y2 returns real
        local real dx = x2 - x1
        local real dy = y2 - y1
        local real l2 = dx * dx + dy * dy
        local real k = 0
        if l2 > 0.01 then
            set k = ((x - x1) * dx + (y - y1) * dy) / l2
            if k < 0 then
                set k = 0
            elseif k > 1 then
                set k = 1
            endif
        endif
        return SquareRoot((x - x1 - k * dx) * (x - x1 - k * dx) + (y - y1 - k * dy) * (y - y1 - k * dy))
    endfunction

    private function MemAlive takes unit u returns boolean
        return u != null and not IsUnitDeadVJ(u)
    endfunction

    private function AliveCount takes ArcherFight f returns integer
        local integer i = 0
        local integer n = 0
        loop
            exitwhen i >= f.memN
            if MemAlive(f.mem[i]) then
                set n = n + 1
            endif
            set i = i + 1
        endloop
        return n
    endfunction

    private function Anim takes ArcherFight f, integer idx, real speed returns nothing
        call AnimationStart3(f.boss, idx, speed)
        if AnimLoop[idx] then
            set f.animEnd = 0
        else
            set f.animEnd = f.now + AnimDur[idx] / speed
        endif
    endfunction

    // 현재 무기 자세에 맞는 대기 동작 (1페이즈 쌍검, 2페이즈 활)
    private function AnimIdle takes ArcherFight f returns nothing
        if f.state == ARCHER_PHASE2 or (f.state == ARCHER_TRANSITION and f.transStep >= 2) then
            call Anim(f, AN_STAND_ALT, 1.0)
        else
            call Anim(f, AN_STAND, 1.0)
        endif
    endfunction

    private function Face takes ArcherFight f, real a returns nothing
        call SetUnitFacing(f.boss, a)
        call EXSetUnitFacing(f.boss, a)
    endfunction

    private function ClampX takes ArcherFight f, real x returns real
        local rect r = MapRectReturn(f.rect)
        local real lo = GetRectMinX(r) + 150
        local real hi = GetRectMaxX(r) - 150
        set r = null
        if x < lo then
            return lo
        elseif x > hi then
            return hi
        endif
        return x
    endfunction

    private function ClampY takes ArcherFight f, real y returns real
        local rect r = MapRectReturn(f.rect)
        local real lo = GetRectMinY(r) + 150
        local real hi = GetRectMaxY(r) - 150
        set r = null
        if y < lo then
            return lo
        elseif y > hi then
            return hi
        endif
        return y
    endfunction

    private function PlaySoundPath takes string path returns nothing
        local sound s
        if path == null or path == "" then
            return
        endif
        set s = CreateSound(path, false, false, false, 10, 10, "")
        call SetSoundVolume(s, 127)
        call StartSound(s)
        call KillSoundWhenDone(s)
        set s = null
    endfunction

    private function MsgAll takes ArcherFight f, string s, real dur returns nothing
        local integer i = 0
        loop
            exitwhen i >= f.memN
            if f.mem[i] != null then
                call DisplayTimedTextToPlayer(GetOwningPlayer(f.mem[i]), 0, 0, dur, s)
            endif
            set i = i + 1
        endloop
    endfunction

    // 현재 어그로 대상. 살아 있지 않으면 살아 있는 참가자 중 하나
    private function PickTarget takes ArcherFight f returns unit
        local unit u = BossAggroTarget(f.boss)
        local integer i = 0
        if MemAlive(u) and IsUnitInGroup(u, f.ul.super) then
            return u
        endif
        loop
            exitwhen i >= f.memN
            if MemAlive(f.mem[i]) then
                return f.mem[i]
            endif
            set i = i + 1
        endloop
        return null
    endfunction

    // 저격 대상: 표식을 가장 적게 받은 생존자 (동률은 무작위)
    private function PickSnipeTarget takes ArcherFight f returns integer
        local integer i = 0
        local integer best = -1
        local integer bestCount = 999999
        local integer ties = 0
        loop
            exitwhen i >= f.memN
            if MemAlive(f.mem[i]) then
                if f.markCount[i] < bestCount then
                    set best = i
                    set bestCount = f.markCount[i]
                    set ties = 1
                elseif f.markCount[i] == bestCount then
                    set ties = ties + 1
                    if GetRandomInt(1, ties) == 1 then
                        set best = i
                    endif
                endif
            endif
            set i = i + 1
        endloop
        return best
    endfunction

    // ======================================================================
    // 예고 장판 (types 0 빨강, 2 노랑, 3 초록 - AOE.j 색 규칙)
    // ======================================================================
    private function Decal takes ArcherFight f, real x, real y, real radius, real time, integer types returns nothing
        local unit d = CreateUnit(GetOwningPlayer(f.boss), DECAL_ID, x, y, 270)
        local real s = radius * 0.01
        call SetUnitScalePercent(d, 100 * s, 100 * s, 100)
        if types == 0 then
            call SetUnitVertexColor(d, 255, 10, 10, 255)
        elseif types == 2 then
            call SetUnitVertexColor(d, 255, 255, 10, 255)
        elseif types == 3 then
            call SetUnitVertexColor(d, 10, 255, 10, 255)
        endif
        call SetUnitTimeScale(d, 1 / time)
        call UnitApplyTimedLife(d, 'BHwe', time)
        call GroupAddUnit(f.decals, d)
        set d = null
    endfunction

    // 직선 예고: 원형 데칼을 이어 붙인다
    private function DecalLine takes ArcherFight f, real x, real y, real a, real len, real width, real time, integer types returns nothing
        local real r = width * 0.5
        local real step = width * 0.8
        local real d = r
        loop
            exitwhen d > len
            call Decal(f, x + PolarX(d, a), y + PolarY(d, a), r, time, types)
            set d = d + step
        endloop
    endfunction

    // 부채꼴 예고: 중심선과 양 끝선에 데칼
    private function DecalFan takes ArcherFight f, real x, real y, real a, real range, real half, real time, integer types returns nothing
        call DecalLine(f, x, y, a, range, range * 0.45, time, types)
        call DecalLine(f, x, y, a - half * 0.6, range * 0.9, range * 0.35, time, types)
        call DecalLine(f, x, y, a + half * 0.6, range * 0.9, range * 0.35, time, types)
    endfunction

    private function ClearDecalsEnum takes nothing returns nothing
        local unit u = GetEnumUnit()
        if not IsUnitDeadVJ(u) then
            call ShowUnit(u, false)
            call KillUnit(u)
        endif
        set u = null
    endfunction

    private function ClearDecals takes ArcherFight f returns nothing
        call ForGroup(f.decals, function ClearDecalsEnum)
        call GroupClear(f.decals)
    endfunction

    // ======================================================================
    // 피해 판정 (이 전투 참가자만 대상)
    // ======================================================================
    private function Deal takes ArcherFight f, unit u, real dmg, boolean stun returns nothing
        call BossDeal(f.boss, u, dmg, stun)
    endfunction

    // 원형. g 가 0 이 아니면 그 그룹에 이미 있는 대상은 건너뛴다
    private function HitCircle takes ArcherFight f, real x, real y, real r, real dmg, boolean stun, party g returns nothing
        local integer i = 0
        local unit u
        loop
            exitwhen i >= f.memN
            set u = f.mem[i]
            if MemAlive(u) and IsUnitInRangeXY(u, x, y, r) then
                if g == 0 then
                    call Deal(f, u, dmg, stun)
                elseif not IsUnitInGroup(u, g.super) then
                    call GroupAddUnit(g.super, u)
                    call Deal(f, u, dmg, stun)
                endif
            endif
            set i = i + 1
        endloop
        set u = null
    endfunction

    // 고리: inner 보다 멀고 outer 안쪽
    private function HitRing takes ArcherFight f, real x, real y, real inner, real outer, real dmg returns nothing
        local integer i = 0
        local unit u
        loop
            exitwhen i >= f.memN
            set u = f.mem[i]
            if MemAlive(u) and IsUnitInRangeXY(u, x, y, outer) and not IsUnitInRangeXY(u, x, y, inner) then
                call Deal(f, u, dmg, true)
            endif
            set i = i + 1
        endloop
        set u = null
    endfunction

    // 부채꼴: 거리 range, 중심 방향 a 에서 ±half 도
    private function HitFan takes ArcherFight f, real x, real y, real a, real range, real half, real dmg, boolean stun returns nothing
        local integer i = 0
        local unit u
        loop
            exitwhen i >= f.memN
            set u = f.mem[i]
            if MemAlive(u) and IsUnitInRangeXY(u, x, y, range) then
                if AngDiff(AnglePBP(x, y, GetUnitX(u), GetUnitY(u)), a) <= half or IsUnitInRangeXY(u, x, y, 100) then
                    call Deal(f, u, dmg, stun)
                endif
            endif
            set i = i + 1
        endloop
        set u = null
    endfunction

    // 선분 휩쓸기: 이전 위치와 현재 위치 사이를 검사해서 빠른 이동에도 충돌을 놓치지 않는다
    private function HitSweep takes ArcherFight f, real x1, real y1, real x2, real y2, real width, real dmg, boolean stun, party g returns nothing
        local integer i = 0
        local unit u
        loop
            exitwhen i >= f.memN
            set u = f.mem[i]
            if MemAlive(u) and not IsUnitInGroup(u, g.super) then
                if SegDist(GetUnitX(u), GetUnitY(u), x1, y1, x2, y2) <= width then
                    call GroupAddUnit(g.super, u)
                    call Deal(f, u, dmg, stun)
                endif
            endif
            set i = i + 1
        endloop
        set u = null
    endfunction

    // ======================================================================
    // 투사체
    // ======================================================================
    private function FreeSlot takes ArcherFight f returns integer
        local integer i = 0
        loop
            exitwhen i >= MAXP
            if f.pk[i] == 0 then
                return i
            endif
            set i = i + 1
        endloop
        return -1
    endfunction

    private function ProjKill takes ArcherFight f, integer i returns nothing
        if f.pe[i] != null then
            call DestroyEffect(f.pe[i])
            set f.pe[i] = null
        endif
        if f.phit[i] != 0 then
            call f.phit[i].destroy()
            set f.phit[i] = 0
        endif
        set f.pk[i] = 0
    endfunction

    private function ProjSpawn takes ArcherFight f, integer kind, string model, real x, real y, real a, real spd, real maxd, real rad, real dmg, real size returns integer
        local integer i = FreeSlot(f)
        if i < 0 then
            return -1
        endif
        set f.pk[i] = kind
        set f.pe[i] = MakeMissile(model, x, y, 90, a, size, null)
        set f.px[i] = x
        set f.py[i] = y
        set f.pox[i] = x
        set f.poy[i] = y
        set f.pdir[i] = a
        set f.pspd[i] = spd
        set f.ptrav[i] = 0
        set f.pmax[i] = maxd
        set f.prad[i] = rad
        set f.pdmg[i] = dmg
        set f.pback[i] = false
        set f.phit[i] = party.create()
        return i
    endfunction

    private function ProjCount takes ArcherFight f, integer kind returns integer
        local integer i = 0
        local integer n = 0
        loop
            exitwhen i >= MAXP
            if f.pk[i] == kind then
                set n = n + 1
            endif
            set i = i + 1
        endloop
        return n
    endfunction

    private function ProjUpdate takes ArcherFight f returns nothing
        local integer i = 0
        local real ox
        local real oy
        local real step
        local real d
        local real a
        loop
            exitwhen i >= MAXP
            if f.pk[i] != 0 then
                set ox = f.px[i]
                set oy = f.py[i]
                set step = f.pspd[i] * TICK
                if f.pk[i] == 1 and f.pback[i] then
                    // 돌아오는 검: 저장한 원점으로 회수
                    set d = DistancePBP(ox, oy, f.pox[i], f.poy[i])
                    set a = AnglePBP(ox, oy, f.pox[i], f.poy[i])
                    if d <= step then
                        set f.px[i] = f.pox[i]
                        set f.py[i] = f.poy[i]
                    else
                        set f.px[i] = ox + PolarX(step, a)
                        set f.py[i] = oy + PolarY(step, a)
                    endif
                    call EXSetEffectXY(f.pe[i], f.px[i], f.py[i])
                    call HitSweep(f, ox, oy, f.px[i], f.py[i], f.prad[i], f.pdmg[i], true, f.phit[i])
                    if d <= step then
                        call ProjKill(f, i)
                    endif
                else
                    if f.ptrav[i] + step > f.pmax[i] then
                        set step = f.pmax[i] - f.ptrav[i]
                    endif
                    set f.px[i] = ox + PolarX(step, f.pdir[i])
                    set f.py[i] = oy + PolarY(step, f.pdir[i])
                    set f.ptrav[i] = f.ptrav[i] + step
                    call EXSetEffectXY(f.pe[i], f.px[i], f.py[i])
                    call HitSweep(f, ox, oy, f.px[i], f.py[i], f.prad[i], f.pdmg[i], f.pk[i] == 1, f.phit[i])
                    if f.ptrav[i] >= f.pmax[i] - 0.01 then
                        if f.pk[i] == 1 then
                            // 나가는 구간과 돌아오는 구간은 별도 판정
                            set f.pback[i] = true
                            call GroupClear(f.phit[i].super)
                            call EXEffectMatRotateZ(f.pe[i], 180)
                        else
                            // 저격탄 끝 폭발: 직선과 같은 피격 기록 공유
                            call DestroyEffect(AddSpecialEffect(FX_SNIPE_BOOM, f.px[i], f.py[i]))
                            call HitCircle(f, f.px[i], f.py[i], 250, DMG_SNIPE_BOOM, true, f.phit[i])
                            call CameraShaker.setShake(8)
                            call ProjKill(f, i)
                        endif
                    endif
                endif
            endif
            set i = i + 1
        endloop
    endfunction

    // ======================================================================
    // 취소·정리
    // ======================================================================
    private function ClearMark takes ArcherFight f returns nothing
        if f.mark != null then
            call DestroyEffect(f.mark)
            set f.mark = null
        endif
    endfunction

    // 진행 중인 공격 전부 취소 (패턴, 투사체, 장판, 표식, 카운터 창)
    private function CancelAttacks takes ArcherFight f returns nothing
        local integer i = 0
        loop
            exitwhen i >= MAXP
            if f.pk[i] != 0 then
                call ProjKill(f, i)
            endif
            set i = i + 1
        endloop
        call ClearDecals(f)
        call ClearMark(f)
        if f.boss != null then
            call UnitRemoveAbility(f.boss, 'A00V')
            call SetUnitVertexColor(f.boss, 255, 255, 255, 255)
        endif
        set f.pat = 0
        set f.step = 0
        set f.combo = 0
        set f.dashLeft = 0
        set f.rainSnipe = false
        set f.target = null
    endfunction

    // ======================================================================
    // 무한의 검제 전장
    // ======================================================================
    private function TerrainApply takes ArcherFight f returns nothing
        local rect r = MapRectReturn(f.rect)
        local real x
        local real y
        local integer k = 0
        if UBW_TILE == 0 or f.terrainChanged then
            set r = null
            return
        endif
        call FlushChildHashtable(TerrainSave, f.rect)
        set y = GetRectMinY(r)
        loop
            exitwhen y > GetRectMaxY(r)
            set x = GetRectMinX(r)
            loop
                exitwhen x > GetRectMaxX(r)
                call SaveInteger(TerrainSave, f.rect, k * 2, GetTerrainType(x, y))
                call SaveInteger(TerrainSave, f.rect, k * 2 + 1, GetTerrainVariance(x, y))
                call SetTerrainType(x, y, UBW_TILE, -1, 1, 0)
                set k = k + 1
                set x = x + 128
            endloop
            set y = y + 128
        endloop
        set f.terrainChanged = true
        set r = null
    endfunction

    private function TerrainRestore takes ArcherFight f returns nothing
        local rect r = MapRectReturn(f.rect)
        local real x
        local real y
        local integer k = 0
        if not f.terrainChanged then
            set r = null
            return
        endif
        set y = GetRectMinY(r)
        loop
            exitwhen y > GetRectMaxY(r)
            set x = GetRectMinX(r)
            loop
                exitwhen x > GetRectMaxX(r)
                call SetTerrainType(x, y, LoadInteger(TerrainSave, f.rect, k * 2), LoadInteger(TerrainSave, f.rect, k * 2 + 1), 1, 0)
                set k = k + 1
                set x = x + 128
            endloop
            set y = y + 128
        endloop
        call FlushChildHashtable(TerrainSave, f.rect)
        set f.terrainChanged = false
        set r = null
    endfunction

    private function StuckSwordsCreate takes ArcherFight f returns nothing
        local rect r = MapRectReturn(f.rect)
        local integer i = 0
        loop
            exitwhen i >= UBW_STUCK_COUNT
            set f.stuck[i] = AddSpecialEffect(FX_SWORD_STUCK, GetRandomReal(GetRectMinX(r) + 200, GetRectMaxX(r) - 200), GetRandomReal(GetRectMinY(r) + 200, GetRectMaxY(r) - 200))
            call EXEffectMatRotateZ(f.stuck[i], GetRandomReal(0, 360))
            set i = i + 1
        endloop
        set r = null
    endfunction

    private function StuckSwordsDestroy takes ArcherFight f returns nothing
        local integer i = 0
        loop
            exitwhen i >= UBW_STUCK_COUNT
            if f.stuck[i] != null then
                call DestroyEffect(f.stuck[i])
                set f.stuck[i] = null
            endif
            set i = i + 1
        endloop
    endfunction

    // 참가자 화면에만 적용 (색 변화·하늘). 게임 상태는 바꾸지 않는다
    private function LocalFilter takes ArcherFight f, boolean on, real dur returns nothing
        local integer i = 0
        loop
            exitwhen i >= f.memN
            if f.mem[i] != null and GetLocalPlayer() == GetOwningPlayer(f.mem[i]) then
                if on then
                    call SetCineFilterTexture("ReplaceableTextures\\CameraMasks\\White_mask.blp")
                    call SetCineFilterBlendMode(BLEND_MODE_BLEND)
                    call SetCineFilterTexMapFlags(TEXMAP_FLAG_NONE)
                    call SetCineFilterStartUV(0, 0, 1, 1)
                    call SetCineFilterEndUV(0, 0, 1, 1)
                    call SetCineFilterStartColor(255, 255, 255, 0)
                    call SetCineFilterEndColor(255, 90, 40, 110)
                    call SetCineFilterDuration(dur)
                    call DisplayCineFilter(true)
                    if UBW_SKY != "" then
                        call SetSkyModel(UBW_SKY)
                    endif
                else
                    call DisplayCineFilter(false)
                    if UBW_SKY != "" then
                        call SetSkyModel(UBW_SKY_RESTORE)
                    endif
                endif
            endif
            set i = i + 1
        endloop
    endfunction

    // ======================================================================
    // 패턴 시작·종료
    // ======================================================================
    private function PatternEnd takes ArcherFight f, real rest returns nothing
        call ClearDecals(f)
        call ClearMark(f)
        call UnitRemoveAbility(f.boss, 'A00V')
        call SetUnitVertexColor(f.boss, 255, 255, 255, 255)
        set f.pat = 0
        set f.step = 0
        set f.target = null
        set f.nextSelect = f.now + rest
        call AnimIdle(f)
    endfunction

    private function StartPattern takes ArcherFight f, integer id returns nothing
        local real a
        set f.pat = id
        set f.step = 0
        set f.patStart = f.now
        if f.combo == 0 then
            set f.readyAt[id] = f.now + PatCool[id]
            set f.lastPat = id
        endif
        if f.hit == 0 then
            set f.hit = party.create()
        endif
        call GroupClear(f.hit.super)
        set f.target = PickTarget(f)
        if f.target != null then
            set a = AngleWBW(f.boss, f.target)
            call Face(f, a)
            set f.ang = a
        endif
    endfunction

    // 다음 패턴 선택: 상태·전환 예약·쿨다운 확인 → 직전 패턴 제외 → 가중치 추첨
    private function SelectPattern takes ArcherFight f returns nothing
        local integer i = 1
        local integer total = 0
        local integer n = 0
        local integer roll
        local integer last = f.lastPat
        local boolean ok

        if f.pat != 0 or (f.state != ARCHER_PHASE1 and f.state != ARCHER_PHASE2) then
            return
        endif
        if PickTarget(f) == null then
            return
        endif

        // 첫 전투 첫 바퀴는 A1 → A2 → A3 순서로 보여 준다
        if f.state == ARCHER_PHASE1 and f.introIdx < 3 then
            set f.introIdx = f.introIdx + 1
            call StartPattern(f, f.introIdx)
            return
        endif

        // 후보 수 (직전 패턴 제외 여부 판단용)
        loop
            exitwhen i > 7
            set ok = f.now >= f.readyAt[i]
            if i >= 5 and f.state != ARCHER_PHASE2 then
                set ok = false
            endif
            if i == 7 and UnitHP[IndexUnit(f.boss)] > UnitHPMAX[IndexUnit(f.boss)] * 0.30 then
                set ok = false
            endif
            if ok then
                set n = n + 1
            endif
            set i = i + 1
        endloop
        if n <= 1 then
            set last = 0
        endif

        set i = 1
        loop
            exitwhen i > 7
            set ok = f.now >= f.readyAt[i] and i != last
            if i >= 5 and f.state != ARCHER_PHASE2 then
                set ok = false
            endif
            if i == 7 and UnitHP[IndexUnit(f.boss)] > UnitHPMAX[IndexUnit(f.boss)] * 0.30 then
                set ok = false
            endif
            if ok then
                set total = total + PatWeight[i]
            endif
            set i = i + 1
        endloop
        if total <= 0 then
            return
        endif

        set roll = GetRandomInt(1, total)
        set i = 1
        loop
            exitwhen i > 7
            set ok = f.now >= f.readyAt[i] and i != last
            if i >= 5 and f.state != ARCHER_PHASE2 then
                set ok = false
            endif
            if i == 7 and UnitHP[IndexUnit(f.boss)] > UnitHPMAX[IndexUnit(f.boss)] * 0.30 then
                set ok = false
            endif
            if ok then
                set roll = roll - PatWeight[i]
                if roll <= 0 then
                    if i == 7 then
                        // A7 검제 연속 공격: 검의 비 → 저격 → 심안·역습 → 긴 후딜
                        set f.readyAt[7] = f.now + PatCool[7]
                        set f.lastPat = 7
                        set f.combo = 1
                        set f.rainWaves = 3
                        call MsgAll(f, "|cFFFF4040검제 연속 공격|r", 3.0)
                        call StartPattern(f, 5)
                    else
                        call StartPattern(f, i)
                    endif
                    return
                endif
            endif
            set i = i + 1
        endloop
    endfunction

    // 패턴 하나가 끝났을 때. A7 진행 중이면 다음 단계로 넘긴다
    private function PatternDone takes ArcherFight f, real rest returns nothing
        if f.combo == 1 then
            set f.combo = 2
            call PatternEnd(f, 0)
            call StartPattern(f, 3)
        elseif f.combo == 2 then
            set f.combo = 3
            call PatternEnd(f, 0)
            call StartPattern(f, 4)
        elseif f.combo == 3 then
            set f.combo = 0
            call PatternEnd(f, 3.0)
            // 집중 공격 기회
            call Anim(f, AN_STAND_SLAM, 1.0)
        else
            call PatternEnd(f, rest)
        endif
    endfunction

    // ======================================================================
    // A1. 간장·막야 연격
    // ======================================================================
    private function RunA1 takes ArcherFight f, real el returns nothing
        local real bx = GetUnitX(f.boss)
        local real by = GetUnitY(f.boss)
        local real nx
        local real ny
        local real step
        if f.step == 0 then
            // 첫 베기: attack 1 타격(0.38초)이 0.7초 판정에 맞도록 0.55배속
            call Anim(f, AN_ATTACK1, 0.55)
            call DecalFan(f, bx, by, f.ang, 350, 60, 0.7, 0)
            set f.step = 1
        elseif f.step == 1 and el >= 0.7 then
            call HitFan(f, bx, by, f.ang, 350, 60, DMG_SLASH, false)
            call DestroyEffect(AddSpecialEffect(FX_SLASH, bx + PolarX(150, f.ang), by + PolarY(150, f.ang)))
            // 두 번째 베기는 대상을 다시 바라본다
            if MemAlive(f.target) then
                set f.ang = AngleWBW(f.boss, f.target)
                call Face(f, f.ang)
            endif
            // 두 번째 베기: attack 2 타격(0.35초)이 0.5초 뒤 판정에 맞도록 0.7배속
            call Anim(f, AN_ATTACK2, 0.7)
            call DecalFan(f, bx, by, f.ang, 350, 60, 0.5, 0)
            set f.step = 2
        elseif f.step == 2 and el >= 1.2 then
            call HitFan(f, bx, by, f.ang, 350, 60, DMG_SLASH, false)
            call DestroyEffect(AddSpecialEffect(FX_SLASH, bx + PolarX(150, f.ang), by + PolarY(150, f.ang)))
            // 마지막 돌진 방향 고정. 이후 대상을 추적하지 않는다
            if MemAlive(f.target) then
                set f.ang = AngleWBW(f.boss, f.target)
            endif
            call Face(f, f.ang)
            call Anim(f, AN_STAND_READY, 1.0)
            call DecalLine(f, bx, by, f.ang, 550, 260, 0.6, 2)
            set f.step = 3
        elseif f.step == 3 and el >= 1.8 then
            // 돌진 베기: 쌍검 attack 1 을 1.5배속으로, 0.25초 돌진 끝에 베기가 닿는다
            call Anim(f, AN_ATTACK1, 1.5)
            set f.dashLeft = 450
            set f.dashSpeed = 450 / 0.25
            set f.step = 4
        elseif f.step == 4 then
            set step = RMinBJ(f.dashLeft, f.dashSpeed * TICK)
            set nx = ClampX(f, bx + PolarX(step, f.ang))
            set ny = ClampY(f, by + PolarY(step, f.ang))
            call SetUnitPosition(f.boss, nx, ny)
            call HitSweep(f, bx, by, nx, ny, 130, DMG_DASH, true, f.hit)
            set f.dashLeft = f.dashLeft - step
            if f.dashLeft <= 0 then
                set f.step = 5
            endif
        elseif f.step == 5 and el >= 3.6 then
            call PatternDone(f, 0.4)
        endif
    endfunction

    // ======================================================================
    // A2. 회귀하는 쌍검
    // ======================================================================
    private function RunA2 takes ArcherFight f, real el returns nothing
        local real bx = GetUnitX(f.boss)
        local real by = GetUnitY(f.boss)
        if f.step == 0 then
            set f.ax = bx
            set f.ay = by
            // 예고 동안 쌍검 준비 자세
            call Anim(f, AN_STAND_READY, 1.0)
            call DecalLine(f, bx, by, f.ang - 20, 900, 180, 1.0, 0)
            call DecalLine(f, bx, by, f.ang + 20, 900, 180, 1.0, 0)
            set f.step = 1
        elseif f.step == 1 and el >= 0.8 then
            // spell three: 검을 던지는 동작. 손을 떠나는 시점(약 0.2초)에 투사체 생성
            call Anim(f, AN_SPELL_THREE, 1.0)
            set f.step = 2
        elseif f.step == 2 and el >= 1.0 then
            call ProjSpawn(f, 1, FX_THROW_SWORD, f.ax, f.ay, f.ang - 20, 1100, 900, 90, DMG_THROW, 1.6)
            call ProjSpawn(f, 1, FX_THROW_SWORD, f.ax, f.ay, f.ang + 20, 1100, 900, 90, DMG_THROW, 1.6)
            set f.step = 3
        elseif f.step == 3 and ProjCount(f, 1) == 0 then
            // 검 회수 후 접근해서 공격할 시간 (쌍검을 다시 쥔 대기 자세)
            set f.patStart = f.now
            call AnimIdle(f)
            set f.step = 4
        elseif f.step == 4 and el >= 1.2 then
            call PatternDone(f, 0.3)
        endif
    endfunction

    // ======================================================================
    // A3. 위·나선검 저격
    // ======================================================================
    private function RunA3 takes ArcherFight f, real el returns nothing
        local real bx = GetUnitX(f.boss)
        local real by = GetUnitY(f.boss)
        local integer k
        if f.step == 0 then
            set k = PickSnipeTarget(f)
            if k < 0 then
                call PatternDone(f, 0.5)
                return
            endif
            set f.markCount[k] = f.markCount[k] + 1
            set f.target = f.mem[k]
            call ClearMark(f)
            set f.mark = AddSpecialEffectTarget(FX_SNIPE_MARK, f.target, "overhead")
            call Anim(f, AN_CHANNEL_FOUR, 1.0)
            set f.step = 1
        elseif f.step == 1 then
            // 조준 중에는 대상을 바라본다
            if MemAlive(f.target) then
                set f.ang = AngleWBW(f.boss, f.target)
                set f.tx = GetUnitX(f.target)
                set f.ty = GetUnitY(f.target)
                call Face(f, f.ang)
            endif
            if el >= 1.0 then
                // 마지막 0.5초: 방향과 목표 좌표 고정
                call DecalLine(f, bx, by, f.ang, DistancePBP(bx, by, f.tx, f.ty), 180, 0.5, 0)
                call Decal(f, f.tx, f.ty, 250, 0.5, 0)
                set f.step = 2
            endif
        elseif f.step == 2 and el >= 1.5 then
            call ClearMark(f)
            call Anim(f, AN_CHANNEL_FIVE, 1.0)
            call ProjSpawn(f, 2, FX_SNIPE_BOLT, bx, by, f.ang, 3000, RMaxBJ(50, DistancePBP(bx, by, f.tx, f.ty)), 90, DMG_SNIPE, 1.4)
            set f.step = 3
        elseif f.step == 3 and ProjCount(f, 2) == 0 then
            set f.patStart = f.now
            set f.step = 4
        elseif f.step == 4 and el >= 1.0 then
            call PatternDone(f, 0.3)
        endif
    endfunction

    // ======================================================================
    // A4. 심안·역습 (마지막 역베기에 정면 카운터 가능)
    // ======================================================================
    private function RunA4 takes ArcherFight f, real el returns nothing
        local real bx = GetUnitX(f.boss)
        local real by = GetUnitY(f.boss)
        local real nx
        local real ny
        local real step
        if f.step == 0 then
            // 방어 자세: 쌍검 준비 자세 + 푸른 빛
            call Anim(f, AN_STAND_READY, 1.0)
            call SetUnitVertexColor(f.boss, 200, 200, 255, 255)
            set f.step = 1
        elseif f.step == 1 and el >= 0.8 then
            if MemAlive(f.target) then
                set f.ang = AngleWBW(f.boss, f.target)
            endif
            call Face(f, f.ang)
            call DecalLine(f, bx, by, f.ang, 600, 260, 0.5, 2)
            set f.step = 2
        elseif f.step == 2 and el >= 1.3 then
            // 돌진 베기: attack 1 을 1.5배속으로, 돌진 끝에 베기가 닿는다
            call Anim(f, AN_ATTACK1, 1.5)
            set f.dashLeft = 500
            set f.dashSpeed = 500 / 0.25
            set f.step = 3
        elseif f.step == 3 then
            set step = RMinBJ(f.dashLeft, f.dashSpeed * TICK)
            set nx = ClampX(f, bx + PolarX(step, f.ang))
            set ny = ClampY(f, by + PolarY(step, f.ang))
            call SetUnitPosition(f.boss, nx, ny)
            call HitSweep(f, bx, by, nx, ny, 130, DMG_DASH, true, f.hit)
            set f.dashLeft = f.dashLeft - step
            if f.dashLeft <= 0 then
                // 카운터 가능 구간 시작
                set f.patStart = f.now
                // 역베기 준비: attack 2 를 느리게(0.29배속) 재생해 타격(0.35초)이 1.2초 판정에 맞는다
                call Anim(f, AN_ATTACK2, 0.29)
                call UnitAddAbility(f.boss, 'A00V')
                call SetUnitVertexColor(f.boss, 120, 120, 255, 255)
                call DestroyEffect(AddSpecialEffectTarget(FX_COUNTER_READY, f.boss, "origin"))
                call DecalFan(f, nx, ny, f.ang, 450, 80, 1.2, 2)
                set f.step = 4
            endif
        elseif f.step == 4 then
            if GetUnitAbilityLevel(f.boss, 'A00V') == 0 then
                // 카운터 성공: 공격 취소, 약 3초 그로기
                call ClearDecals(f)
                call SetUnitVertexColor(f.boss, 255, 255, 255, 255)
                call Sound3D(f.boss, 'A00U')
                // 그로기: 무기를 놓친 빈손 자세 (stand slam 반복)
                call Anim(f, AN_STAND_SLAM, 1.0)
                set f.patStart = f.now
                set f.step = 6
            elseif el >= 1.2 then
                // 카운터 실패: 예고한 공격 실행
                call UnitRemoveAbility(f.boss, 'A00V')
                call SetUnitVertexColor(f.boss, 255, 255, 255, 255)
                call HitFan(f, bx, by, f.ang, 450, 80, DMG_COUNTER, true)
                call DestroyEffect(AddSpecialEffect(FX_SLASH, bx + PolarX(200, f.ang), by + PolarY(200, f.ang)))
                set f.patStart = f.now
                set f.step = 5
            endif
        elseif f.step == 5 and el >= 1.5 then
            call PatternDone(f, 0.3)
        elseif f.step == 6 and el >= 3.0 then
            call PatternDone(f, 0.3)
        endif
    endfunction

    // ======================================================================
    // A5. 검의 비 (2페이즈) - 전장을 통로로 나누고 안전 통로가 한 칸씩 이동
    // ======================================================================
    private function RainHalf takes ArcherFight f returns real
        local rect r = MapRectReturn(f.rect)
        local real h
        if ModuloReal(f.rainAng, 180) < 1 then
            // 통로가 동서로 길다 → 남북으로 나눈다
            set h = (GetRectMaxY(r) - GetRectMinY(r)) * 0.5
        else
            set h = (GetRectMaxX(r) - GetRectMinX(r)) * 0.5
        endif
        set r = null
        return h
    endfunction

    private function RainLen takes ArcherFight f returns real
        local rect r = MapRectReturn(f.rect)
        local real h
        if ModuloReal(f.rainAng, 180) < 1 then
            set h = (GetRectMaxX(r) - GetRectMinX(r)) * 0.5
        else
            set h = (GetRectMaxY(r) - GetRectMinY(r)) * 0.5
        endif
        set r = null
        return h
    endfunction

    // 통로 번호 lane 의 중심 좌표 (중심선 방향 rainAng, 폭 방향 rainAng+90)
    private function LaneOffset takes ArcherFight f, integer lane returns real
        local real w = RainHalf(f) * 2 / RAIN_LANES
        return -RainHalf(f) + w * (lane + 0.5)
    endfunction

    private function RainTelegraph takes ArcherFight f, real time returns nothing
        local real cx = f.arenaCX()
        local real cy = f.arenaCY()
        local real w = RainHalf(f) * 2 / RAIN_LANES
        local real len = RainLen(f)
        local integer lane = 0
        local real off
        local real sx
        local real sy
        loop
            exitwhen lane >= RAIN_LANES
            set off = LaneOffset(f, lane)
            set sx = cx + PolarX(off, f.rainAng + 90) + PolarX(-len, f.rainAng)
            set sy = cy + PolarY(off, f.rainAng + 90) + PolarY(-len, f.rainAng)
            if lane == f.rainSafe then
                call DecalLine(f, sx, sy, f.rainAng, len * 2, w * 0.9, time, 3)
            else
                call DecalLine(f, sx, sy, f.rainAng, len * 2, w, time, 0)
            endif
            set lane = lane + 1
        endloop
    endfunction

    private function RainStrike takes ArcherFight f returns nothing
        local real cx = f.arenaCX()
        local real cy = f.arenaCY()
        local real half = RainHalf(f)
        local real w = half * 2 / RAIN_LANES
        local real len = RainLen(f)
        local integer i = 0
        local integer lane
        local real perp
        local unit u
        local real off
        local integer k
        // 낙하 연출
        set lane = 0
        loop
            exitwhen lane >= RAIN_LANES
            if lane != f.rainSafe then
                set off = LaneOffset(f, lane)
                set k = 0
                loop
                    exitwhen k >= 4
                    call DestroyEffect(AddSpecialEffect(FX_SWORD_FALL, cx + PolarX(off, f.rainAng + 90) + PolarX(GetRandomReal(-len, len), f.rainAng), cy + PolarY(off, f.rainAng + 90) + PolarY(GetRandomReal(-len, len), f.rainAng)))
                    set k = k + 1
                endloop
            endif
            set lane = lane + 1
        endloop
        // 판정: 안전 통로 밖이면 피해
        loop
            exitwhen i >= f.memN
            set u = f.mem[i]
            if MemAlive(u) then
                set perp = (GetUnitX(u) - cx) * Cos((f.rainAng + 90) * bj_DEGTORAD) + (GetUnitY(u) - cy) * Sin((f.rainAng + 90) * bj_DEGTORAD)
                set lane = R2I((perp + half) / w)
                if perp + half < 0 then
                    set lane = -1
                endif
                if lane != f.rainSafe then
                    call Deal(f, u, DMG_RAIN, true)
                endif
            endif
            set i = i + 1
        endloop
        call CameraShaker.setShake(6)
        set u = null
    endfunction

    private function RunA5 takes ArcherFight f, real el returns nothing
        local integer k
        if f.step == 0 then
            if f.rainWaves <= 0 then
                set f.rainWaves = 4
            endif
            if GetRandomInt(0, 1) == 0 then
                set f.rainAng = 0
            else
                set f.rainAng = 90
            endif
            set f.rainSafe = GetRandomInt(0, RAIN_LANES - 1)
            set f.rainWave = 0
            // 처음은 단독, 이후에는 저격 하나와 조합 (A7 진행 중 제외)
            set f.rainSnipe = f.rainUsed >= 1 and f.combo == 0
            set f.rainUsed = f.rainUsed + 1
            call Anim(f, AN_SPELL_ALT_THREE, 1.0)
            call MsgAll(f, "|cFFFF8040검의 비|r - 초록 통로로 이동하세요.", 3.0)
            call RainTelegraph(f, RAIN_FIRST_WARN)
            set f.rainNext = f.now + RAIN_FIRST_WARN
            set f.step = 1
        elseif f.step == 1 then
            if f.rainSnipe and f.rainWave == 1 and f.mark == null and f.now >= f.rainNext - RAIN_NEXT_WARN + 0.3 then
                set k = PickSnipeTarget(f)
                if k >= 0 then
                    set f.markCount[k] = f.markCount[k] + 1
                    set f.target = f.mem[k]
                    set f.tx = GetUnitX(f.target)
                    set f.ty = GetUnitY(f.target)
                    set f.mark = AddSpecialEffectTarget(FX_SNIPE_MARK, f.target, "overhead")
                    set f.ang = AnglePBP(GetUnitX(f.boss), GetUnitY(f.boss), f.tx, f.ty)
                    call Face(f, f.ang)
                    // 활 당기기 (spell channel four 반복)
                    call Anim(f, AN_CHANNEL_FOUR, 1.0)
                    call DecalLine(f, GetUnitX(f.boss), GetUnitY(f.boss), f.ang, DistancePBP(GetUnitX(f.boss), GetUnitY(f.boss), f.tx, f.ty), 180, 1.2, 0)
                    call Decal(f, f.tx, f.ty, 250, 1.2, 0)
                    set f.ax = f.now + 1.2
                else
                    set f.rainSnipe = false
                endif
            endif
            if f.mark != null and f.now >= f.ax then
                call ClearMark(f)
                // 발사 (spell channel five 첫 프레임에 시위를 놓는다)
                call Anim(f, AN_CHANNEL_FIVE, 1.0)
                call ProjSpawn(f, 2, FX_SNIPE_BOLT, GetUnitX(f.boss), GetUnitY(f.boss), f.ang, 3000, RMaxBJ(50, DistancePBP(GetUnitX(f.boss), GetUnitY(f.boss), f.tx, f.ty)), 90, DMG_SNIPE, 1.4)
                set f.rainSnipe = false
            endif
            if f.now >= f.rainNext then
                call RainStrike(f)
                set f.rainWave = f.rainWave + 1
                if f.rainWave >= f.rainWaves then
                    set f.patStart = f.now
                    set f.step = 2
                else
                    // 안전 통로는 한 칸씩 이동한다
                    if f.rainSafe == 0 then
                        set f.rainSafe = 1
                    elseif f.rainSafe == RAIN_LANES - 1 then
                        set f.rainSafe = RAIN_LANES - 2
                    elseif GetRandomInt(0, 1) == 0 then
                        set f.rainSafe = f.rainSafe - 1
                    else
                        set f.rainSafe = f.rainSafe + 1
                    endif
                    call RainTelegraph(f, RAIN_NEXT_WARN)
                    set f.rainNext = f.now + RAIN_NEXT_WARN
                    // 다음 낙하를 지휘하는 동작 (저격 조준 중이면 유지)
                    if f.mark == null then
                        call Anim(f, AN_SPELL_ALT_THREE, 1.0)
                    endif
                endif
            endif
        elseif f.step == 2 and el >= 1.2 and ProjCount(f, 2) == 0 then
            set f.rainWaves = 0
            call PatternDone(f, 0.3)
        endif
    endfunction

    // ======================================================================
    // A6. 검의 포위 (2페이즈) - 바깥 고리 → 안쪽 폭발
    // ======================================================================
    private function RunA6 takes ArcherFight f, real el returns nothing
        if f.step == 0 then
            set f.ax = GetUnitX(f.boss)
            set f.ay = GetUnitY(f.boss)
            call Anim(f, AN_SPELL_ALT_ONE, 1.0)
            // 바깥 고리 예고 (빨강) + 안전 안쪽 (초록)
            call Decal(f, f.ax, f.ay, 1000, 1.6, 0)
            call Decal(f, f.ax, f.ay, 360, 1.6, 3)
            set f.step = 1
        elseif f.step == 1 and el >= 1.6 then
            call HitRing(f, f.ax, f.ay, 380, 1000, DMG_RING)
            call DestroyEffect(AddSpecialEffect(FX_SWORD_FALL, f.ax + 700, f.ay))
            call DestroyEffect(AddSpecialEffect(FX_SWORD_FALL, f.ax - 700, f.ay))
            call DestroyEffect(AddSpecialEffect(FX_SWORD_FALL, f.ax, f.ay + 700))
            call DestroyEffect(AddSpecialEffect(FX_SWORD_FALL, f.ax, f.ay - 700))
            call ClearDecals(f)
            // 안쪽 폭발 별도 예고 → 바깥으로 이동. 활 준비 자세로 기다린다
            call Anim(f, AN_STANDREADY_ALT, 1.0)
            call Decal(f, f.ax, f.ay, 380, 1.3, 0)
            set f.step = 2
        elseif f.step == 2 and el >= 2.25 then
            // spell alternate two: 뛰어올랐다 내려찍는 동작. 착지(약 0.65초)가 2.9초 폭발에 맞는다
            call Anim(f, AN_SPELL_ALT_TWO, 1.0)
            set f.step = 3
        elseif f.step == 3 and el >= 2.9 then
            call HitCircle(f, f.ax, f.ay, 380, DMG_CORE, true, 0)
            call DestroyEffect(AddSpecialEffect(FX_SNIPE_BOOM, f.ax, f.ay))
            call CameraShaker.setShake(8)
            set f.step = 4
        elseif f.step == 4 and el >= 4.4 then
            call PatternDone(f, 0.3)
        endif
    endfunction

    private function RunPattern takes ArcherFight f returns nothing
        local real el = f.now - f.patStart
        if f.pat == 1 then
            call RunA1(f, el)
        elseif f.pat == 2 then
            call RunA2(f, el)
        elseif f.pat == 3 then
            call RunA3(f, el)
        elseif f.pat == 4 then
            call RunA4(f, el)
        elseif f.pat == 5 then
            call RunA5(f, el)
        elseif f.pat == 6 then
            call RunA6(f, el)
        endif
    endfunction

    // ======================================================================
    // 영창 예약·재생과 페이즈 전환
    // ======================================================================
    private function SetProtect takes ArcherFight f, boolean floorOn, boolean lock returns nothing
        local integer idx = IndexUnit(f.boss)
        set UnitHPFloorOn[idx] = floorOn
        set UnitHPFloor[idx] = 1.0
        set UnitDamageLock[idx] = lock
    endfunction

    // 피해 직후 HP 구간을 넘은 만큼 영창을 예약한다 (여러 구간을 한 번에 넘겨도 순서대로)
    private function ReserveChants takes ArcherFight f returns nothing
        local integer idx = IndexUnit(f.boss)
        local real pct = UnitHP[idx] / UnitHPMAX[idx]
        loop
            exitwhen f.chantReserved >= 8
            exitwhen pct > (80 - 10 * f.chantReserved) * 0.01
            set f.chantReserved = f.chantReserved + 1
        endloop
        if f.chantReserved >= 8 and f.state == ARCHER_PHASE1 then
            // 마지막 영창 예약: 새 패턴 선택 보류
            set f.state = ARCHER_TRANSITION_PENDING
        endif
    endfunction

    private function PlayChant takes ArcherFight f, integer k returns nothing
        set f.chantPlaying = true
        set f.chantEnd = f.now + ChantDur[k]
        call PlaySoundPath(ChantSound[k])
        call MsgAll(f, "|cFFFFD080아쳐|r: " + ChantText[k], ChantDur[k] + 1.0)
    endfunction

    private function StartTransition takes ArcherFight f returns nothing
        set f.state = ARCHER_TRANSITION
        set f.transStart = f.now
        set f.transStep = 0
        // 공격 정리, 피해·카운터 잠금
        call CancelAttacks(f)
        call SetProtect(f, true, true)
        // 전장 중앙으로
        call SetUnitPosition(f.boss, f.arenaCX(), f.arenaCY())
        call Face(f, 270)
        // 영창 시작: 빈손을 앞으로 내미는 동작 (spell one)
        call Anim(f, AN_SPELL_ONE, 1.0)
        call PlayChant(f, 8)
        call DestroyEffect(AddSpecialEffectTarget(FX_TRANSITION, f.boss, "origin"))
        call LocalFilter(f, true, ChantDur[8] * 0.5)
    endfunction

    private function UpdateTransition takes ArcherFight f returns nothing
        local real el = f.now - f.transStart
        local integer idx = IndexUnit(f.boss)
        if f.transStep == 0 and el >= 1.4 then
            // 영창 중 빈손 자세 유지 (stand slam 반복)
            call Anim(f, AN_STAND_SLAM, 1.0)
            set f.transStep = 1
        elseif f.transStep == 1 and el >= ChantDur[8] * 0.6 then
            // 전장 타일·배경을 검의 황야로. morph: 쌍검이 사라지고 활이 나타난다
            call TerrainApply(f)
            call StuckSwordsCreate(f)
            call CameraShaker.setShake(10)
            set f.transStep = 2
            call Anim(f, AN_MORPH, 1.0)
        elseif f.transStep == 2 and el >= ChantDur[8] then
            // 마지막 선언: 최대 체력까지 회복
            set f.chantPlaying = false
            set f.chantDone = 8
            call PlaySoundPath(FINAL_SOUND)
            set UnitHP[idx] = UnitHPMAX[idx]
            call MsgAll(f, "|cFFFF4040무한의 검제|r", 4.0)
            call Anim(f, AN_STANDREADY_ALT, 1.0)
            set f.transStep = 3
        elseif f.transStep == 3 and el >= ChantDur[8] + 1.5 then
            // 2페이즈 시작: 보호 해제, 쿨다운 초기화
            call LocalFilter(f, false, 0)
            call SetProtect(f, false, false)
            set f.readyAt[1] = f.now
            set f.readyAt[2] = f.now
            set f.readyAt[3] = f.now
            set f.readyAt[4] = f.now
            set f.readyAt[5] = f.now
            set f.readyAt[6] = f.now
            set f.readyAt[7] = f.now
            set f.lastPat = 0
            set f.nextSelect = f.now
            set f.state = ARCHER_PHASE2
            call Anim(f, AN_STAND_ALT, 1.0)
            // 첫 2페이즈 패턴은 검의 비
            call StartPattern(f, 5)
        endif
    endfunction

    private function UpdateChant takes ArcherFight f returns nothing
        local integer k
        if f.chantPlaying and f.now >= f.chantEnd then
            set f.chantPlaying = false
            set f.chantDone = f.chantDone + 1
        endif
        if not f.chantPlaying and f.chantDone < f.chantReserved then
            set k = f.chantDone + 1
            if k >= 8 then
                call StartTransition(f)
            else
                call PlayChant(f, k)
            endif
        endif
    endfunction

    // ======================================================================
    // 종료
    // ======================================================================
    private function SuccessF takes nothing returns nothing
        call SuccessStart(GetEnumUnit())
        call OverlayStop(GetPlayerId(GetOwningPlayer(GetEnumUnit())))
    endfunction

    private function AllDie takes nothing returns nothing
        call FailedStart(GetEnumUnit())
        call OverlayStop(GetPlayerId(GetOwningPlayer(GetEnumUnit())))
    endfunction

    private function Finish takes ArcherFight f, boolean win returns nothing
        local integer i = 0
        set f.state = ARCHER_ENDED
        call CancelAttacks(f)
        call LocalFilter(f, false, 0)
        call TerrainRestore(f)
        call StuckSwordsDestroy(f)
        call SetProtect(f, false, false)
        call CameraShaker.stopShake()
        call BossAggroDestroy(f.boss)
        if win then
            call ForGroup(f.ul.super, function SuccessF)
            call SetUnitAnimationByIndex(f.boss, 20)
            call KillUnit(f.boss)
            call BossMapReset(f.rect, ARENA_THEMA)
        else
            call ForGroup(f.ul.super, function AllDie)
            call KillUnit(f.boss)
            call RemoveUnit(f.boss)
            call MapReset(f.rect, ARENA_THEMA)
        endif
        set ArcherFightAt[f.rect] = 0
        call f.t.destroy()
        if f.hit != 0 then
            call f.hit.destroy()
            set f.hit = 0
        endif
        call DestroyGroup(f.decals)
        set f.decals = null
        call f.ul.destroy()
        loop
            exitwhen i >= 6
            set f.mem[i] = null
            set i = i + 1
        endloop
        set f.boss = null
        set f.target = null
        call f.destroy()
    endfunction

    // ======================================================================
    // 전투 틱
    // ======================================================================
    private function BattleTick takes nothing returns nothing
        local tick t = tick.getExpired()
        local ArcherFight f = t.data
        local integer idx

        if f.state == ARCHER_ENDED then
            return
        endif
        set f.now = f.now + TICK
        set idx = IndexUnit(f.boss)

        // 전멸
        if AliveCount(f) == 0 then
            call Finish(f, false)
            return
        endif
        // 2페이즈 정상 처치
        if f.state == ARCHER_PHASE2 and (UnitHP[idx] <= 0 or IsUnitDeadVJ(f.boss)) then
            call Finish(f, true)
            return
        endif
        // 1페이즈 보호는 피해 경로(HeroDeal/CutInDeal)에서 즉시 처리. 여기서는 한 번 더 보정만 한다
        if (f.state == ARCHER_PHASE1 or f.state == ARCHER_TRANSITION_PENDING or f.state == ARCHER_TRANSITION) and UnitHP[idx] < 1 then
            set UnitHP[idx] = 1
        endif

        // 반복하지 않는 동작이 끝나면 현재 무기 자세의 대기 동작으로 돌아간다
        if f.animEnd > 0 and f.now >= f.animEnd then
            set f.animEnd = 0
            call AnimIdle(f)
        endif

        if f.state == ARCHER_PHASE1 or f.state == ARCHER_TRANSITION_PENDING then
            call ReserveChants(f)
            call UpdateChant(f)
        endif
        if f.state == ARCHER_TRANSITION then
            call UpdateTransition(f)
            return
        endif

        call ProjUpdate(f)
        if f.pat != 0 then
            call RunPattern(f)
        elseif f.now >= f.nextSelect then
            call SelectPattern(f)
        endif
    endfunction

    // ======================================================================
    // 입장
    // ======================================================================
    private function NoRemove takes nothing returns nothing
        local integer pid = GetPlayerId(GetOwningPlayer(GetEnumUnit()))
        local ArcherFight f = CheckFight
        call ResetPlayerPotionCharges(pid)
        if GetLocalPlayer() == GetOwningPlayer(GetEnumUnit()) then
            call PlayersBossBarShow(GetLocalPlayer(), true)
            call DzFrameShow(BossTip, false)
        endif
        call BOSSHPSTART(f.boss, pid)
        call Overlay(pid)
        if f.memN < 6 then
            set f.mem[f.memN] = GetEnumUnit()
            set f.markCount[f.memN] = 0
            set f.memN = f.memN + 1
        endif
    endfunction

    private function StartBattle takes ArcherFight f returns nothing
        local integer idx
        local integer n
        local real hpRate

        set f.boss = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), ARCHER_UNIT_ID, f.arenaCX(), f.arenaCY(), 270)
        call BossAggroInitialize(f.boss, f.ul.super)
        set idx = IndexUnit(f.boss)
        set Unitstate[idx] = 0
        call UnitRemoveAbility(f.boss, 'Amov')
        call SetUnitPathing(f.boss, false)
        call PauseUnit(f.boss, true)
        call SetUnitPosition(f.boss, f.arenaCX(), f.arenaCY())

        // 체력 배율: 전투 시작 인원 기준. 도중 사망으로 바꾸지 않는다
        set n = CountUnitsInGroup(f.ul.super)
        if n < 1 then
            set n = 1
        endif
        set hpRate = 1.0 + PARTY_HP_BONUS * (n - 1)
        set UnitHPMAX[idx] = UnitSetHP[ARCHER_DATA_INDEX] * hpRate
        set UnitHP[idx] = UnitHPMAX[idx]

        // 구조체 배열은 재사용 시 초기화되지 않으므로 직접 비운다
        set n = 0
        loop
            exitwhen n >= MAXP
            set f.pk[n] = 0
            set f.pe[n] = null
            set f.phit[n] = 0
            set n = n + 1
        endloop
        set n = 0
        loop
            exitwhen n >= 8
            set f.readyAt[n] = 0
            set n = n + 1
        endloop

        set f.memN = 0
        set CheckFight = f
        call ForGroup(f.ul.super, function NoRemove)
        set CheckFight = 0

        call SetProtect(f, true, false)
        set f.decals = CreateGroup()
        set f.state = ARCHER_PHASE1
        set f.now = 0
        set f.nextSelect = 2.0
        call Anim(f, AN_STAND_READY, 1.0)

        set MapRectCheck[f.rect] = false
        set f.t = tick.create(f)
        call f.t.start(TICK, true, function BattleTick)
    endfunction

    private function EntranceTick takes nothing returns nothing
        local tick t = tick.getExpired()
        local ArcherFight f = t.data
        if splash.range(splash.ALLY, f.entrance, GetWidgetX(f.entrance), GetWidgetY(f.entrance), 500, function SplashNothing) == 0 then
            call KillUnit(f.entrance)
            set f.entrance = null
            call t.destroy()
            call StartBattle(f)
        endif
    endfunction

    function ArcherBossStart takes unit source returns nothing
        local tick t
        local ArcherFight f
        local integer pid = GetPlayerId(GetOwningPlayer(source))
        local integer mapNumber = GetMap(ARENA_THEMA)
        local rect r2

        if mapNumber == 0 then
            return
        endif

        set f = ArcherFightAt[mapNumber]
        if f == 0 then
            set f = ArcherFight.create()
            set f.rect = mapNumber
            set f.state = ARCHER_READY
            set f.ul = party.create()
            set f.hit = 0
            set ArcherFightAt[mapNumber] = f
            set f.entrance = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), ENTRANCE_DUMMY, GetRectCenterX(MapRectReturn2(mapNumber)), GetRectCenterY(MapRectReturn2(mapNumber)), 270)
            call GroupAddUnit(f.ul.super, source)
            set t = tick.create(f)
            call t.start(1.00, true, function EntranceTick)
        elseif f.state == ARCHER_READY then
            call GroupAddUnit(f.ul.super, source)
        else
            // 이미 시작한 전투에는 합류하지 않는다
            return
        endif

        set r2 = MapRectReturn2(mapNumber)
        call SetUnitPosition(source, GetRectCenterX(r2), GetRectCenterY(r2))
        if GetLocalPlayer() == Player(pid) then
            call SetCameraBoundsToRectForPlayerBJ(Player(pid), MapRectReturn(mapNumber))
            call SetCameraPositionForPlayer(Player(pid), GetRectCenterX(r2), GetRectCenterY(r2))
            call DzFrameShow(BossTip, true)
        endif
        set r2 = null
    endfunction

    // 테스트 입장: 채팅 "-아처"
    private function ChatEnter takes nothing returns nothing
        local integer pid = GetPlayerId(GetTriggerPlayer())
        if MainUnit[pid] != null and not IsUnitDeadVJ(MainUnit[pid]) then
            call ArcherBossStart(MainUnit[pid])
        endif
    endfunction

    // ======================================================================
    // 데이터
    // ======================================================================
    private module ArcherInit
        private static method onInit takes nothing returns nothing
            local integer i = 0
            local trigger t = CreateTrigger()
            loop
                exitwhen i >= 12
                call TriggerRegisterPlayerChatEvent(t, Player(i), "-아처", true)
                set i = i + 1
            endloop
            call TriggerAddAction(t, function ChatEnter)
            set t = null

            // Archer.mdx 애니메이션 길이(초). 반복 동작은 AnimLoop
            set AnimDur[0] = 2.000
            set AnimDur[1] = 0.800
            set AnimDur[2] = 1.000
            set AnimDur[3] = 1.166
            set AnimDur[4] = 1.166
            set AnimDur[5] = 0.333
            set AnimDur[6] = 2.500
            set AnimDur[7] = 1.000
            set AnimDur[8] = 1.666
            set AnimDur[9] = 0.267
            set AnimDur[10] = 1.000
            set AnimDur[11] = 0.334
            set AnimDur[12] = 1.333
            set AnimDur[13] = 1.000
            set AnimDur[14] = 2.000
            set AnimDur[15] = 0.800
            set AnimDur[16] = 1.000
            set AnimDur[17] = 0.833
            set AnimDur[18] = 1.166
            set AnimDur[19] = 1.200
            set AnimDur[20] = 1.000
            set AnimDur[21] = 0.834
            set AnimDur[22] = 2.000
            set AnimDur[23] = 1.333
            set AnimDur[24] = 1.000
            set AnimDur[25] = 1.000
            set AnimDur[26] = 0.800
            set AnimDur[27] = 1.334
            set AnimDur[28] = 1.667
            set AnimDur[29] = 0.500
            set AnimDur[30] = 0.833
            set AnimLoop[0] = true
            set AnimLoop[1] = true
            set AnimLoop[2] = true
            set AnimLoop[9] = true
            set AnimLoop[14] = true
            set AnimLoop[15] = true
            set AnimLoop[16] = true
            set AnimLoop[22] = true
            set AnimLoop[26] = true
            set AnimLoop[29] = true

            set i = 1
            // 확정 필요: 영창 음성 경로와 실제 길이(초)
            loop
                exitwhen i > 8
                set ChantSound[i] = "war3mapImported\\Archer_Chant" + I2S(i) + ".mp3"
                set ChantDur[i] = 3.5
                set ChantText[i] = "(영창 " + I2S(i) + "/8)"
                set i = i + 1
            endloop
            // 마지막 영창은 전환 연출 길이를 겸한다
            set ChantDur[8] = 7.0

            set PatCool[1] = 5
            set PatCool[2] = 10
            set PatCool[3] = 14
            set PatCool[4] = 18
            set PatCool[5] = 12
            set PatCool[6] = 18
            set PatCool[7] = 30

            set PatWeight[1] = 40
            set PatWeight[2] = 25
            set PatWeight[3] = 20
            set PatWeight[4] = 15
            set PatWeight[5] = 30
            set PatWeight[6] = 20
            set PatWeight[7] = 25
        endmethod
    endmodule

    private struct ArcherInitSt extends array
        implement ArcherInit
    endstruct
endlibrary
