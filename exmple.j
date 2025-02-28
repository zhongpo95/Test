library BossAI requires AttackAngle, AOE, FX, DataUnit, UIBossHP, DamageEffect2, UIBossEnd, DataMap, BossAggro // 필요한 라이브러리들을 추가

    globals
        // 보스 관련 변수들
        unit BossUnit = null // 보스 유닛
        integer BossHP = 0 // 보스 현재 체력
        integer BossHPMAX = 1000 // 보스 최대 체력
        integer BossState = 0 // 보스 상태 (0: 일반, 1: 패턴 시행 중, 2: 무력화)
        integer BossPhase = 0 // 보스 페이즈 (체력에 따른 패턴 변화)
        timer BossAITimer = CreateTimer() // AI 타이머
        group BossTargetGroup = CreateGroup() // 보스의 타겟 그룹
    
        //스킬 사용 조건에 관련된 변수
        constant real CLOSE_RANGE = 300 // 근거리 스킬 사용 범위
        constant real MID_RANGE = 600   // 중거리 스킬 사용 범위
        constant real LONG_RANGE = 1000  // 원거리 스킬 사용 범위
        constant real MOVE_SPEED = 20 // 이동 속도
    
        //스킬ID
        constant integer SKILL_CLOSE = 'A001' // 근거리 스킬 ID (임의)
        constant integer SKILL_MID = 'A002'   // 중거리 스킬 ID (임의)
        constant integer SKILL_LONG = 'A003'  // 원거리 스킬 ID (임의)
        
        //AggroSystem
        AggroSystem Aggro
    endglobals
    
    // 스킬 데이터 구조체 (스킬 정보를 담을 구조체)
    struct BossSkillData
        integer skillId // 스킬 ID
        real cooldown // 쿨다운
        real range // 사거리
        real damage // 데미지
        real castTime // 시전 시간
        integer currentCooldown // 남은 쿨다운
    
        static method create takes integer skillId, real cooldown, real range, real damage, real castTime returns BossSkillData
            local BossSkillData data = BossSkillData.allocate()
            set data.skillId = skillId
            set data.cooldown = cooldown
            set data.range = range
            set data.damage = damage
            set data.castTime = castTime
            set data.currentCooldown = 0
            return data
        endmethod
    
        method decreaseCooldown takes nothing returns nothing
            if this.currentCooldown > 0 then
                set this.currentCooldown = this.currentCooldown - 1
            endif
        endmethod
    endstruct
    
    //스킬정보를 담을 배열
    globals
        BossSkillData array BossSkill
    endglobals
    
    // 이동 데이터를 저장하는 구조체
    struct MoveData
        real targetX
        real targetY
        real moveAngle
        real currentSpeed
        boolean isMoving
    
        static method create takes nothing returns MoveData
            local MoveData data = MoveData.allocate()
            set data.targetX = 0
            set data.targetY = 0
            set data.moveAngle = 0
            set data.currentSpeed = MOVE_SPEED
            set data.isMoving = false
            return data
        endmethod
    
        method destroy takes nothing returns nothing
            call this.deallocate()
        endmethod
    endstruct
    
    // 보스 AI 관리 구조체
    struct BossAI
        unit bossUnit
        integer state // 보스 상태 (0: 일반, 1: 패턴 시행 중, 2: 무력화)
        integer phase // 보스 페이즈
        integer hp // 현재 체력
        integer hpMax // 최대 체력
        group targetGroup // 타겟 그룹
        //패턴관련
        integer currentPattern
    
        //보스스킬
        BossSkillData closeSkill
        BossSkillData midSkill
        BossSkillData longSkill
    
        //이동에 관련된 정보
        MoveData moveData
    
        static method create takes unit u returns BossAI
            local BossAI ai = BossAI.allocate()
            set ai.bossUnit = u
            set ai.state = 0 // 초기 상태: 일반
            set ai.phase = 0 // 초기 페이즈
            set ai.hpMax = BossHPMAX
            set ai.hp = ai.hpMax
            set ai.targetGroup = CreateGroup()
    
            //보스의 스킬 정보
            set ai.closeSkill = BossSkillData.create(SKILL_CLOSE, 10, CLOSE_RANGE, 100, 0.5) //스킬ID, 쿨타임, 사거리, 데미지, 시전시간
            set ai.midSkill = BossSkillData.create(SKILL_MID, 15, MID_RANGE, 150, 0.8) //스킬ID, 쿨타임, 사거리, 데미지, 시전시간
            set ai.longSkill = BossSkillData.create(SKILL_LONG, 20, LONG_RANGE, 200, 1) //스킬ID, 쿨타임, 사거리, 데미지, 시전시간
    
            // 이동 관련 데이터 초기화
            set ai.moveData = MoveData.create()
    
            return ai
        endmethod
    
        method destroy takes nothing returns nothing
            call DestroyGroup(this.targetGroup)
            call this.moveData.destroy()
            set this.targetGroup = null
            set this.bossUnit = null
            set this.closeSkill = null
            set this.midSkill = null
            set this.longSkill = null
            set this.moveData = null
            call this.deallocate()
        endmethod
    
        // 스킬 사용 가능한지 체크
        method CanUseSkill takes BossSkillData skillData returns boolean
            return skillData.currentCooldown <= 0
        endmethod
    
        // 스킬 쿨다운 감소
        method DecreaseSkillCoolDown takes nothing returns nothing
            call this.closeSkill.decreaseCooldown()
            call this.midSkill.decreaseCooldown()
            call this.longSkill.decreaseCooldown()
        endmethod
    
        // 스킬 사용
        method UseSkill takes unit targetUnit, BossSkillData skillData returns nothing
            if this.CanUseSkill(skillData) then
                set skillData.currentCooldown = skillData.cooldown
                call BJDebugMsg("보스가 " + I2S(skillData.skillId) + " 스킬을 사용합니다!")
    
                // 특정 스킬에 대한 사용 로직을 구현합니다.
                if skillData.skillId == SKILL_CLOSE then
                    // 근거리 스킬 사용 로직
                    call IssueTargetOrderById(this.bossUnit, $D0200, targetUnit)
                elseif skillData.skillId == SKILL_MID then
                    // 중거리 스킬 사용 로직 (AOE 스킬 사용 예시)
                    call AOE(this.bossUnit, GetUnitX(this.bossUnit), GetUnitY(this.bossUnit), skillData.range, skillData.castTime, skillData.damage, 'e03H', 1, 0)
                elseif skillData.skillId == SKILL_LONG then
                    // 원거리 스킬 사용 로직 (AOE2 스킬 사용 예시)
                    call AOE2(this.bossUnit, GetUnitX(this.bossUnit), GetUnitY(this.bossUnit), 300, skillData.range, skillData.castTime, skillData.damage, 'e03H', 1, 0)
                endif
    
                // 스킬 시전 상태로 변경
                set this.state = 1
            endif
        endmethod
    
        // 타겟 유닛 찾기 (어그로 시스템 사용)
        method FindTarget takes nothing returns unit
            local integer targetPlayerId = Aggro.NowAggro
            return GetPlayerUnit(Player(targetPlayerId), 1) // 플레이어의 첫 번째 유닛을 타겟으로 설정
        endmethod
    
        // 목표 지점으로 이동하도록 설정
        method MoveToPosition takes real x, real y returns nothing
            set this.moveData.targetX = x
            set this.moveData.targetY = y
            set this.moveData.moveAngle = Atan2(y - GetUnitY(this.bossUnit), x - GetUnitX(this.bossUnit))
            set this.moveData.isMoving = true
            // 이동 시작 애니메이션 재생
            call UnitAddAbility(this.bossUnit, 'Amov') // 'Amov'는 Walk 애니메이션을 재생하는 임의의 스킬입니다.
        endmethod
    
        // 보스를 조금씩 이동시키는 함수 (0.02초마다 호출)
        method MoveLoop takes nothing returns nothing
            local real currentX = GetUnitX(this.bossUnit)
            local real currentY = GetUnitY(this.bossUnit)
            local real moveX
            local real moveY
            local real distance
    
            if this.moveData.isMoving then
                // 목표 지점까지의 거리가 이동 속도보다 작으면, 바로 목표 지점으로 이동
                set distance = DistanceBetweenPoints(currentX, currentY, this.moveData.targetX, this.moveData.targetY)
                if distance <= this.moveData.currentSpeed then
                    call SetUnitPosition(this.bossUnit, this.moveData.targetX, this.moveData.targetY)
                    set this.moveData.isMoving = false
                    // 이동 종료 애니메이션 재생
                    call UnitRemoveAbility(this.bossUnit, 'Amov') // 'Amov'는 Walk 애니메이션을 재생하는 임의의 스킬입니다.
                    call UnitAddAbility(this.bossUnit, 'Astan') // 'Astan'은 Stand 애니메이션을 재생하는 임의의 스킬입니다.
                else
                    // 이동할 좌표 계산
                    set moveX = currentX + this.moveData.currentSpeed * Cos(this.moveData.moveAngle)
                    set moveY = currentY + this.moveData.currentSpeed * Sin(this.moveData.moveAngle)
                    call SetUnitPosition(this.bossUnit, moveX, moveY)
                endif
            endif
        endmethod
    
        method BossNormalState takes unit targetUnit returns nothing
            local real distance = DistanceBetweenPoints(GetUnitX(this.bossUnit), GetUnitY(this.bossUnit), GetUnitX(targetUnit), GetUnitY(targetUnit))
            local BossSkillData selectedSkill = null // 선택된 스킬
            local boolean skillUsed = false
    
            //체크포인트
            if this.hp <= this.hpMax * 0.5 and this.phase == 0 then
                set this.phase = 1
            endif
    
            //스킬 시전중이 아니면
            if this.state != 1 then
                // 스킬 우선순위에 따라 스킬 선택
                if distance <= LONG_RANGE and this.CanUseSkill(this.longSkill) then
                    set selectedSkill = this.longSkill
                elseif distance <= MID_RANGE and this.CanUseSkill(this.midSkill) then
                    set selectedSkill = this.midSkill
                elseif distance <= CLOSE_RANGE and this.CanUseSkill(this.closeSkill) then
                    set selectedSkill = this.closeSkill
                endif
    
                // 선택된 스킬이 있으면 사용
                if selectedSkill != null then
                    call this.UseSkill(targetUnit, selectedSkill)
                    set skillUsed = true
                endif
    
                // 스킬 사용 거리가 부족하면 이동
                if not skillUsed and this.moveData.isMoving == false then
                    // 너무 가까우면 이동하지 않기
                    if distance > CLOSE_RANGE * 0.8 then
                        call this.MoveToPosition(GetUnitX(targetUnit), GetUnitY(targetUnit))
                    endif
                endif
            endif
        endmethod
    
        // 보스 AI 메인 루프
        method MainLoop takes nothing returns nothing
            // 타겟 유닛 가져오기 (어그로 시스템을 사용합니다.)
            local unit targetUnit = this.FindTarget()
    
            // 보스 유닛이 없거나 죽었으면 AI 종료
            if this.bossUnit == null or IsUnitDeadBJ(this.bossUnit) then
                call this.destroy()
                return
            endif
    
            //이동루프
            call this.MoveLoop()
    
            // 상태에 따른 AI 동작
            if this.state == 0 then // 일반 상태
                if targetUnit != null then
                    //타겟에게 스킬 사용하기
                    call this.BossNormalState(targetUnit)
                elseif this.moveData.isMoving then //타겟이 없을때 이동중이라면 이동멈추기
                    set this.moveData.isMoving = false
                endif
    
            elseif this.state == 1 then // 패턴 시행 중
                //스킬 사용중일때
                //...
                set this.state = 0 //스킬이 끝나면 다시 일반상태로
            elseif this.state == 2 then // 무력화 상태
                // 아무 행동도 하지 않음
            endif
    
            // 스킬 쿨다운 감소
            call this.DecreaseSkillCoolDown()
        endmethod
    
        // 보스의 데미지를 처리하는 함수입니다.
        method TakeDamage takes integer damage returns nothing
            set this.hp = this.hp - damage
            if this.hp <= 0 then
                call KillUnit(this.bossUnit)
            endif
        endmethod
    endstruct
    
    // 보스 AI 타이머 콜백 함수
    function BossAILoop takes nothing returns nothing
        local BossAI ai = GetTimerData(GetExpiredTimer())
        call ai.MainLoop()
    endfunction
    
    // 보스 생성 함수
    function CreateBoss takes nothing returns nothing
        local BossAI ai
        // 보스 유닛 생성
        set BossUnit = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), 'h00L', 0, 0, 270)
    
        //보스 AI 생성
        set ai = BossAI.create(BossUnit)
    
        // 보스 유닛 초기 설정
        call SetUnitPathing(BossUnit, false)
        call PauseUnit(BossUnit, false)
        // ... 기타 보스 유닛 설정 (체력, 공격력, 스킬 등)
    
        //보스 유닛의 위치
        call SetUnitPosition(BossUnit,GetRectCenterX(MapRectReturn(1)),GetRectCenterY(MapRectReturn(1)))
    
        // 타이머 데이터에 AI 구조체 할당
        call SetTimerData(BossAITimer, ai)
    
        // AI 타이머 시작
        call TimerStart(BossAITimer, 0.02, true, function BossAILoop)
        
        //어그로 시스템 생성
        set Aggro = AggroSystem.create()
        call BossStruct[IndexUnit(BossUnit)]=Aggro
    endfunction
    
    // 보스 초기화 함수
    function InitAI takes nothing returns nothing
        // 보스 유닛 생성
        call CreateBoss()
    
        call BJDebugMsg("InitAI실행")
    endfunction
    
    // ... 기존 exmple.j 코드 ...
    
    // 초기화 함수 (예시)
    function InitTrig_Start takes nothing returns nothing
        // ... 기존 초기화 코드 ...
        call InitAI()
        // ... 기타 초기화 코드 ...
    endfunction
    
    //데미지처리
    function BossDamage takes unit Damager, unit Target, real damage returns nothing
        call PlayerBossAttack(Target,Damager,damage)
    endfunction
    
    //보스의 정보를 저장
    function SaveBoss takes nothing returns nothing
        local BossAI ai = GetTimerData(BossAITimer)
        //Save 로직을 구현해야합니다.
    endfunction
    
    //보스의 정보를 불러옴
    function LoadBoss takes nothing returns nothing
        local BossAI ai = GetTimerData(BossAITimer)
        //Load 로직을 구현해야합니다.
    endfunction
    