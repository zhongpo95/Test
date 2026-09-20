// 통합 시험 원정의 일반 적 두 무리와 대표 보스 전투를 진행한다.
library ExpeditionCombat requires DataExpedition, DataMap, DataUnit, DamageEffect2, UIHP, UIBossHP
    globals
        private timer CombatTimer = CreateTimer()
        private unit array Enemies
        private unit array Warnings
        private texttag array EnemyHealth
        private real array EnemyMaximum
        private real array EnemyClock
        private real array SpawnX
        private real array SpawnY
        private boolean array Planned
        private real array AimX
        private real array AimY
        private integer array EnemyKind
        private integer array EnemyPhase
        private boolean array EnemyDead
        private real array ReviveAt
        private real array ProtectUntil
        private boolean array WasDead
        private real CombatTime = 0.0
        private real SpawnAt = 0.0
        private integer Spawned = 0
        private integer EnemyCount = 0
        private real CenterX = 0.0
        private real CenterY = 0.0
        private rect ArenaBounds = null
        private boolean Finished = true
    endglobals

    private function NearestHero takes unit enemy returns unit
        local integer pid = 0
        local real best = 1000000000.0
        local real dx
        local real dy
        local unit result = null
        loop
            exitwhen pid == 4
            if ExpMember[pid] and UnitAlive(MainUnit[pid]) then
                set dx = GetUnitX(enemy) - GetUnitX(MainUnit[pid])
                set dy = GetUnitY(enemy) - GetUnitY(MainUnit[pid])
                if dx * dx + dy * dy < best then
                    set best = dx * dx + dy * dy
                    set result = MainUnit[pid]
                endif
            endif
            set pid = pid + 1
        endloop
        return result
    endfunction

    private function ClearWarning takes integer i returns nothing
        if Warnings[i] != null then
            call KillUnit(Warnings[i])
            call RemoveUnit(Warnings[i])
            set Warnings[i] = null
        endif
    endfunction

    private function ClearHealth takes integer i returns nothing
        if EnemyHealth[i] != null then
            call DestroyTextTag(EnemyHealth[i])
            set EnemyHealth[i] = null
        endif
    endfunction

    private function UpdateHealth takes integer i returns nothing
        local real percent
        if EnemyHealth[i] != null then
            set percent = RMaxBJ(0.0, RMinBJ(100.0, 100.0 * UnitHP[IndexUnit(Enemies[i])] / EnemyMaximum[i]))
            call SetTextTagText(EnemyHealth[i], R2SW(percent, 0, 1) + "%", 0.019)
            call SetTextTagPosUnit(EnemyHealth[i], Enemies[i], 120.0)
            call SetTextTagVisibility(EnemyHealth[i], ExpMember[GetPlayerId(GetLocalPlayer())] and IsUnitVisible(Enemies[i], GetLocalPlayer()))
        endif
    endfunction

    function ExpCombatStop takes nothing returns nothing
        local integer i = 1
        local integer index
        call PauseTimer(CombatTimer)
        set Finished = true
        if ArenaBounds != null then
            call RemoveRect(ArenaBounds)
            set ArenaBounds = null
        endif
        loop
            exitwhen i > 16
            call ClearWarning(i)
            call ClearHealth(i)
            if Enemies[i] != null then
                set index = IndexUnit(Enemies[i])
                set ExpEnemy[index] = false
                call KillUnit(Enemies[i])
                call RemoveUnit(Enemies[i])
                set Enemies[i] = null
            endif
            set i = i + 1
        endloop
        set i = 0
        loop
            exitwhen i == 4
            if ProtectUntil[i] > 0.0 and MainUnit[i] != null then
                call SetUnitInvulnerable(MainUnit[i], false)
            endif
            set ProtectUntil[i] = 0.0
            set i = i + 1
        endloop
    endfunction

    private function Conclude takes boolean won returns nothing
        local integer i = 1
        local real maximum = 0.0
        local real remaining = 0.0
        if Finished then
            return
        endif
        set Finished = true
        loop
            exitwhen i > EnemyCount
            set maximum = maximum + EnemyMaximum[i]
            if i > Spawned then
                set remaining = remaining + EnemyMaximum[i]
            elseif not EnemyDead[i] then
                set remaining = remaining + RMaxBJ(0.0, UnitHP[IndexUnit(Enemies[i])])
            endif
            set i = i + 1
        endloop
        set ExpProgress = RMaxBJ(0.0, RMinBJ(1.0, 1.0 - remaining / maximum))
        set ExpWon = won
        call ExpCombatStop()
        call TriggerExecute(ExpBattleFinished)
    endfunction

    private function SpawnValid takes integer i, real x, real y returns boolean
        local integer j = 0
        local real dx
        local real dy
        if IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY) then
            return false
        endif
        loop
            exitwhen j == 4
            if ExpMember[j] and UnitAlive(MainUnit[j]) then
                set dx = x - GetUnitX(MainUnit[j])
                set dy = y - GetUnitY(MainUnit[j])
                if dx * dx + dy * dy < 90000.0 then
                    return false
                endif
            endif
            set j = j + 1
        endloop
        set j = 1
        loop
            exitwhen j > EnemyCount
            if j != i and Planned[j] and not EnemyDead[j] then
                set dx = x - SpawnX[j]
                set dy = y - SpawnY[j]
                if Enemies[j] != null then
                    set dx = x - GetUnitX(Enemies[j])
                    set dy = y - GetUnitY(Enemies[j])
                endif
                if dx * dx + dy * dy < 9216.0 then
                    return false
                endif
            endif
            set j = j + 1
        endloop
        return true
    endfunction

    private function PlanEnemy takes integer i returns boolean
        local integer attempt = 0
        loop
            set SpawnX[i] = CenterX + GetRandomReal(-950.0, 950.0)
            set SpawnY[i] = CenterY + GetRandomReal(-650.0, 950.0)
            if SpawnValid(i, SpawnX[i], SpawnY[i]) then
                set Planned[i] = true
                return true
            endif
            set attempt = attempt + 1
            exitwhen attempt == 128
        endloop
        return false
    endfunction

    private function SpawnEnemy takes integer i returns nothing
        local integer raw = 'hfoo'
        local integer index
        local integer pid = 0
        local real x
        local real y
        if not Planned[i] and not PlanEnemy(i) then
            call DisplayTimedTextToForce(bj_FORCE_ALL_PLAYERS, 8, "전장 배치 공간이 부족합니다. 이번 전투를 정산합니다.")
            call Conclude(false)
            return
        endif
        set x = SpawnX[i]
        set y = SpawnY[i]
        if EnemyKind[i] == 2 then
            set raw = 'hrif'
        elseif EnemyKind[i] == 3 then
            set raw = 'ngsp'
        elseif EnemyKind[i] == 4 then
            set raw = 'h002'
        endif
        call ClearWarning(i)
        set Enemies[i] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), raw, x, y, 270)
        set index = IndexUnit(Enemies[i])
        set ExpEnemy[index] = true
        set UnitHP[index] = EnemyMaximum[i]
        set UnitHPMAX[index] = EnemyMaximum[i]
        set UnitArm[index] = 2000.0
        set UnitSD[index] = 0.0
        set UnitSDMAX[index] = 0.0
        set UnitCasting[index] = false
        call SetUnitState(Enemies[i], UNIT_STATE_MAX_LIFE, 1000000.0)
        call SetUnitState(Enemies[i], UNIT_STATE_LIFE, 1000000.0)
        call UnitRemoveAbility(Enemies[i], 'Aatk')
        call SetUnitAcquireRange(Enemies[i], 0)
        if EnemyKind[i] == 1 then
            call SetUnitMoveSpeed(Enemies[i], 380)
        elseif EnemyKind[i] == 2 then
            call SetUnitMoveSpeed(Enemies[i], 350)
        else
            call SetUnitMoveSpeed(Enemies[i], 400)
        endif
        set EnemyClock[i] = 0.5 + 0.1 * i
        set EnemyPhase[i] = 0
        set EnemyDead[i] = false
        if EnemyKind[i] == 4 then
            loop
                exitwhen pid == 4
                if ExpMember[pid] then
                    call BOSSHPSTART(Enemies[i], pid)
                endif
                set pid = pid + 1
            endloop
        else
            // 기본 체력바 표시 설정과 무관하게 실제 전투 체력 비율을 머리 위에 표시한다.
            set EnemyHealth[i] = CreateTextTag()
            call SetTextTagPermanent(EnemyHealth[i], true)
            call SetTextTagColor(EnemyHealth[i], 255, 100, 100, 255)
            call UpdateHealth(i)
        endif
    endfunction

    private function PreviewWave takes nothing returns boolean
        local integer i = 9
        local boolean ready = true
        loop
            exitwhen i > 16
            if not Planned[i] or not SpawnValid(i, SpawnX[i], SpawnY[i]) then
                if not PlanEnemy(i) then
                    call Conclude(false)
                    return false
                endif
                call ClearWarning(i)
                set Warnings[i] = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'h00H', SpawnX[i], SpawnY[i], 270)
                call SetUnitVertexColor(Warnings[i], 255, 200, 30, 220)
                set SpawnAt = CombatTime + 1.0
                set ready = false
            endif
            set i = i + 1
        endloop
        return ready
    endfunction

    private function HitArea takes integer i, real radius, real damage returns nothing
        local integer pid = 0
        local real dx
        local real dy
        loop
            exitwhen pid == 4
            if ExpMember[pid] and UnitAlive(MainUnit[pid]) and ProtectUntil[pid] <= CombatTime then
                set dx = GetUnitX(MainUnit[pid]) - AimX[i]
                set dy = GetUnitY(MainUnit[pid]) - AimY[i]
                if dx * dx + dy * dy <= radius * radius then
                    call BossDeal(Enemies[i], MainUnit[pid], damage, false)
                endif
            endif
            set pid = pid + 1
        endloop
    endfunction

    private function ActEnemy takes integer i returns nothing
        local unit target = NearestHero(Enemies[i])
        local real radius = 180.0
        local real delay = 0.7
        if target == null then
            return
        endif
        if EnemyKind[i] == 2 then
            set radius = 220.0
            set delay = 1.1
        elseif EnemyKind[i] == 3 then
            set radius = 300.0
            set delay = 2.0
        elseif EnemyKind[i] == 4 then
            set radius = 420.0
            set delay = 1.8
        endif
        if EnemyPhase[i] == 1 and EnemyKind[i] == 3 then
            set AimX[i] = GetUnitX(Enemies[i])
            set AimY[i] = GetUnitY(Enemies[i])
            call SetUnitX(Warnings[i], AimX[i])
            call SetUnitY(Warnings[i], AimY[i])
            call IssuePointOrder(Enemies[i], "move", GetUnitX(target), GetUnitY(target))
        endif
        set EnemyClock[i] = EnemyClock[i] - 0.1
        if EnemyClock[i] > 0 then
            set target = null
            return
        endif
        if EnemyPhase[i] == 1 then
            if EnemyKind[i] == 3 then
                call HitArea(i, radius, 2200.0)
                set EnemyClock[i] = 5.0
            elseif EnemyKind[i] == 4 then
                if GetUnitAbilityLevel(Enemies[i], 'A00V') == 0 then
                    set EnemyClock[i] = 5.0
                else
                    call HitArea(i, radius, 2400.0)
                    set EnemyClock[i] = 2.5
                endif
                call UnitRemoveAbility(Enemies[i], 'A00V')
            else
                call HitArea(i, radius, 600.0)
                set EnemyClock[i] = 1.2
            endif
            call IssueImmediateOrder(Enemies[i], "stop")
            call ClearWarning(i)
            set EnemyPhase[i] = 2
        elseif EnemyPhase[i] == 2 then
            set EnemyPhase[i] = 0
            set EnemyClock[i] = 0.0
        elseif EnemyKind[i] == 1 and not IsUnitInRange(Enemies[i], target, 170.0) then
            call IssuePointOrder(Enemies[i], "move", GetUnitX(target), GetUnitY(target))
            set EnemyClock[i] = 0.25
        elseif EnemyKind[i] == 3 and not IsUnitInRange(Enemies[i], target, 650.0) then
            call IssuePointOrder(Enemies[i], "move", GetUnitX(target), GetUnitY(target))
            set EnemyClock[i] = 0.25
        else
            set AimX[i] = GetUnitX(target)
            set AimY[i] = GetUnitY(target)
            if EnemyKind[i] == 3 then
                set AimX[i] = GetUnitX(Enemies[i])
                set AimY[i] = GetUnitY(Enemies[i])
            else
                call IssueImmediateOrder(Enemies[i], "stop")
                call SetUnitFacing(Enemies[i], Atan2(GetUnitY(target) - GetUnitY(Enemies[i]), GetUnitX(target) - GetUnitX(Enemies[i])) * bj_RADTODEG)
            endif
            set Warnings[i] = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'h00H', AimX[i], AimY[i], 270)
            call SetUnitScale(Warnings[i], radius / 100.0, radius / 100.0, 1.0)
            call SetUnitVertexColor(Warnings[i], 255, 30, 30, 200)
            call SetUnitTimeScale(Warnings[i], 1.0 / delay)
            if EnemyKind[i] == 4 then
                call UnitAddAbility(Enemies[i], 'A00V')
                call SetUnitVertexColor(Warnings[i], 30, 120, 255, 200)
            endif
            set EnemyClock[i] = delay
            set EnemyPhase[i] = 1
        endif
        set target = null
    endfunction

    private function Update takes nothing returns nothing
        local integer i = 1
        local integer alive = 0
        local integer heroes = 0
        local real maximum = 0.0
        local real remaining = 0.0
        if Finished or ExpState != EXP_BATTLE then
            return
        endif
        set CombatTime = CombatTime + 0.1
        loop
            exitwhen i > Spawned
            if not EnemyDead[i] then
                if UnitHP[IndexUnit(Enemies[i])] <= 0 or not UnitAlive(Enemies[i]) then
                    set EnemyDead[i] = true
                    call ClearWarning(i)
                    call ClearHealth(i)
                    call KillUnit(Enemies[i])
                else
                    set alive = alive + 1
                    call SetUnitState(Enemies[i], UNIT_STATE_LIFE, RMaxBJ(1.0, 1000000.0 * UnitHP[IndexUnit(Enemies[i])] / EnemyMaximum[i]))
                    call UpdateHealth(i)
                    call ActEnemy(i)
                endif
            endif
            set i = i + 1
        endloop
        if not ExpBossBattle and Spawned == 8 and alive <= 2 then
            if SpawnAt == 0.0 then
                set SpawnAt = CombatTime + 1.0
                call DisplayTimedTextToForce(bj_FORCE_ALL_PLAYERS, 2, "두 번째 무리가 1초 후 등장합니다.")
                call PreviewWave()
                if Finished then
                    return
                endif
            elseif CombatTime >= SpawnAt and PreviewWave() then
                set i = 9
                loop
                    exitwhen i > 16 or Finished
                    call SpawnEnemy(i)
                    set i = i + 1
                endloop
                if Finished then
                    return
                endif
                set Spawned = 16
                set alive = alive + 8
            endif
        endif
        if Finished then
            return
        endif
        set i = 1
        loop
            exitwhen i > EnemyCount
            set maximum = maximum + EnemyMaximum[i]
            if i > Spawned then
                set remaining = remaining + EnemyMaximum[i]
            elseif not EnemyDead[i] then
                set remaining = remaining + RMaxBJ(0.0, UnitHP[IndexUnit(Enemies[i])])
            endif
            set i = i + 1
        endloop
        set ExpProgress = RMaxBJ(0.0, RMinBJ(1.0, 1.0 - remaining / maximum))
        if alive == 0 and Spawned == EnemyCount then
            call Conclude(true)
            return
        endif
        set i = 0
        loop
            exitwhen i == 4
            if ExpMember[i] then
                if UnitAlive(MainUnit[i]) then
                    set heroes = heroes + 1
                    if not RectContainsUnit(ArenaBounds, MainUnit[i]) then
                        call SetUnitPosition(MainUnit[i], RMaxBJ(CenterX - 1240, RMinBJ(CenterX + 1240, GetUnitX(MainUnit[i]))), RMaxBJ(CenterY - 1240, RMinBJ(CenterY + 1240, GetUnitY(MainUnit[i]))))
                    endif
                    if ProtectUntil[i] > 0 and CombatTime >= ProtectUntil[i] then
                        call SetUnitInvulnerable(MainUnit[i], false)
                        set ProtectUntil[i] = 0
                    endif
                elseif not WasDead[i] then
                    set WasDead[i] = true
                    if ExpBossBattle then
                        set ExpSeconds = IMaxBJ(0, ExpSeconds - 60)
                        set ReviveAt[i] = CombatTime + 15.0
                    else
                        set ExpSeconds = IMaxBJ(0, ExpSeconds - 30)
                    endif
                endif
            endif
            set i = i + 1
        endloop
        if heroes == 0 or ExpSeconds == 0 then
            call Conclude(false)
            return
        endif
        set i = 0
        loop
            exitwhen i == 4
            if ExpMember[i] and ExpBossBattle and WasDead[i] and CombatTime >= ReviveAt[i] then
                call ReviveHero(MainUnit[i], CenterX - 450.0 + i * 300.0, CenterY - 700.0, false)
                call SetUnitState(MainUnit[i], UNIT_STATE_LIFE, GetUnitState(MainUnit[i], UNIT_STATE_MAX_LIFE) * 0.5)
                call SetUnitInvulnerable(MainUnit[i], true)
                set ProtectUntil[i] = CombatTime + 2.0
                set WasDead[i] = false
                call RefreshHP(MainUnit[i])
            endif
            set i = i + 1
        endloop
    endfunction

    function ExpCombatStart takes boolean boss returns nothing
        local integer i = 0
        call ExpCombatStop()
        set Finished = false
        set CombatTime = 0.0
        set SpawnAt = 0.0
        set ExpProgress = 0.0
        set CenterX = GetRectCenterX(MapRectReturn(ExpArena))
        set CenterY = GetRectCenterY(MapRectReturn(ExpArena))
        set ArenaBounds = Rect(CenterX - 1280, CenterY - 1280, CenterX + 1280, CenterY + 1280)
        set ExpBossBattle = boss
        set ExpBattleLimit = 120
        set EnemyCount = 16
        if boss then
            set EnemyCount = 1
            set ExpBattleLimit = 360
        endif
        set ExpSeconds = ExpBattleLimit
        loop
            exitwhen i == 4
            set WasDead[i] = false
            set ReviveAt[i] = 0.0
            if ExpMember[i] then
                if not UnitAlive(MainUnit[i]) then
                    call ReviveHero(MainUnit[i], CenterX - 450.0 + i * 300.0, CenterY - 700.0, false)
                endif
                call SetUnitPosition(MainUnit[i], CenterX - 450.0 + i * 300.0, CenterY - 700.0)
                call SetUnitState(MainUnit[i], UNIT_STATE_LIFE, GetUnitState(MainUnit[i], UNIT_STATE_MAX_LIFE))
                call SetUnitInvulnerable(MainUnit[i], false)
                call RefreshHP(MainUnit[i])
                if GetLocalPlayer() == Player(i) then
                    call SetCameraBoundsToRectForPlayerBJ(Player(i), ArenaBounds)
                    call SetCameraPosition(CenterX, CenterY)
                    call SelectUnit(MainUnit[i], true)
                endif
            endif
            set i = i + 1
        endloop
        set i = 1
        loop
            exitwhen i > EnemyCount
            set EnemyKind[i] = 1
            if ModuloInteger(i - 1, 8) >= 5 then
                set EnemyKind[i] = 2
            endif
            if ModuloInteger(i, 8) == 0 then
                set EnemyKind[i] = 3
            endif
            // T23 우솝의 위치 정보에 따른 일반 적 체력 10% 감소.
            set EnemyMaximum[i] = 450000.0 * ExpPlayers
            if boss then
                set EnemyKind[i] = 4
                set EnemyMaximum[i] = 12000000.0 * ExpPlayers
            endif
            set EnemyDead[i] = false
            set Planned[i] = false
            set i = i + 1
        endloop
        set Spawned = 0
        set i = 1
        loop
            exitwhen i > IMinBJ(8, EnemyCount) or Finished
            call SpawnEnemy(i)
            if not Finished then
                set Spawned = i
            endif
            set i = i + 1
        endloop
        if not Finished then
            call TimerStart(CombatTimer, 0.1, true, function Update)
        endif
    endfunction

endlibrary
