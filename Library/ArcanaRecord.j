// 단계 7 웹 기록(09 3.3~3.5). 원정·단독 보스가 끝날 때 플레이어별 기록 하나를 서버로 보낸다. 기록 실패는 저장에 영향이 없다.
library ArcanaRecord initializer onInit requires ArcanaSaveConfig, ArcanaSaveNet3Natives, ArcanaStashNet

    // 실행 위치 규칙(ArcanaStashNet 과 같다)
    // - 동기 경로: 훅(게임 코드가 TriggerEvaluate 로 부름), 버퍼 기록, 상태 변경. 모든 클라이언트에서 같은 순서.
    // - 소유자 로컬 블록: 문서 만들기(ArcanaDoc*), 전송(ArcanaRecordSend), 결과 조회·재시도. 동기 상태와 난수를 건드리지 않는다.
    // 훅을 부르는 라이브러리는 requires 를 늘리지 않도록(라이브러리 초기화 순서 보존) 공개 전역 인자 + 트리거로 부른다.
    // 두 상수(ARCANA_SAVE_BACKEND, ARCANA_RECORDS_ENABLED) 중 하나라도 거짓이면 훅 호출이 static if 로 빠지고 이 라이브러리는 아무 일도 하지 않는다.

    static if ARCANA_SAVE_BACKEND and ARCANA_RECORDS_ENABLED then
        // 09 3.2 api=4. 이 선언이 있는 맵은 DLL 0.4.0 이상에서만 실행된다.
        native ArcanaRecordSend takes string kind, integer doc, integer seat returns integer
    endif

    globals
        // 훅 인자(호출하는 쪽이 채운 뒤 해당 트리거를 TriggerEvaluate 한다)
        integer ArcanaRecArgPid = 0
        integer ArcanaRecArgId = 0
        integer ArcanaRecArgChoice = 0
        boolean ArcanaRecArgFlag = false
        string ArcanaRecArgText = ""
        integer ArcanaRecArgN = 0
        unit array ArcanaRecArgUnit
        // 시간 초과 자동 선택 표시(ProtoResolveTimeout 이 참으로, RecBranch·RecOffer·RecPick 이 거짓으로)
        boolean array ArcanaRecAuto
        trigger ArcanaRecTrigRunBegin = CreateTrigger()
        trigger ArcanaRecTrigOffer = CreateTrigger()
        trigger ArcanaRecTrigPick = CreateTrigger()
        trigger ArcanaRecTrigBranch = CreateTrigger()
        trigger ArcanaRecTrigCard = CreateTrigger()
        trigger ArcanaRecTrigRunEnd = CreateTrigger()
        trigger ArcanaRecTrigBossBegin = CreateTrigger()
        trigger ArcanaRecTrigBossEnd = CreateTrigger()

        private constant integer MAX_STEPS = 64
        private constant integer MAX_CARDS = 64
        private constant integer ENTRY_LIMIT = 256       // 09 3.2 DLL 한도
        private constant integer BYTE_LIMIT = 16384
        private constant integer CLEAR_MS_MAX = 21600000
        private constant real POLL = 0.05
        private constant integer RETRY_WAIT_1 = 40        // 2초
        private constant integer RETRY_WAIT_2 = 100       // 5초

        private string GameKey = ""
        private timer Clock = CreateTimer()
        // 원정 런(동기)
        private boolean RunOn = false
        private string RunKey = ""
        private real RunStart = 0.0
        private integer RunSize = 0
        private boolean array RunMember
        private string array RunHero
        private integer array StepN
        private boolean array Truncated
        private string array StepKind
        private string array StepOffered
        private string array StepPicked
        private string array StepEvent
        private boolean array StepAuto
        private integer array CardN
        private string array CardKey
        private integer array CardCopies
        // 단독 보스(동기, 플레이어별)
        private integer BossSeq = 0
        private boolean array BossOn
        private string array BossKey
        private string array BossName
        private real array BossStart
        private integer array BossSize
        private string array BossHero
        // 소유자 로컬 전송 상태(플레이어당 2칸, 클라이언트마다 다를 수 있다)
        private integer array LReq
        private integer array LTry
        private integer array LWait
        private integer LDoc = 0
        private integer LEntries = 0
        private integer LBytes = 0
        private boolean LFull = false
    endglobals

    private function Two takes integer n returns string
        if n < 10 then
            return "0" + I2S(n)
        endif
        return I2S(n)
    endfunction

    private function ElapsedMs takes real start returns integer
        local integer ms = R2I((TimerGetElapsed(Clock) - start) * 1000.0)
        if ms < 1 then
            return 1
        endif
        return ms
    endfunction

    //==========================================================================
    // 소유자 로컬: 문서 만들기와 전송
    //==========================================================================
    // 한 항목을 문서에 넣는다. 빈 값은 넣지 않고(09 3.5), 한도를 넘으면 넣지 않고 LFull 을 켠다.
    private function Put takes string k, string v returns boolean
        local integer b
        if v == null or v == "" then
            return true
        endif
        set b = StringLength(k) + StringLength(v)
        if LEntries + 1 > ENTRY_LIMIT or LBytes + b > BYTE_LIMIT then
            set LFull = true
            return false
        endif
        static if ARCANA_SAVE_BACKEND and ARCANA_RECORDS_ENABLED then
            if ArcanaDocAdd(LDoc, k, v) != 1 then
                set LFull = true
                return false
            endif
        endif
        set LEntries = LEntries + 1
        set LBytes = LBytes + b
        return true
    endfunction

    private function Begin takes nothing returns boolean
        set LEntries = 0
        set LBytes = 0
        set LFull = false
        set LDoc = 0
        static if ARCANA_SAVE_BACKEND and ARCANA_RECORDS_ENABLED then
            set LDoc = ArcanaDocNew()
        endif
        return LDoc != 0
    endfunction

    // 문서를 보내고 결과 핸들을 플레이어 칸에 넣는다. 칸이 차 있으면 가장 오래된 것을 버린다(09 3.3).
    private function Send takes integer pid, string kind returns nothing
        local integer id = 0
        static if ARCANA_SAVE_BACKEND and ARCANA_RECORDS_ENABLED then
            set id = ArcanaRecordSend(kind, LDoc, pid)      // 문서는 DLL 이 소비한다
            set LDoc = 0
            if id == 0 then
                return
            endif
            if LReq[pid * 2] != 0 and LReq[pid * 2 + 1] != 0 then
                call ArcanaNetRelease(LReq[pid * 2])
                set LReq[pid * 2] = LReq[pid * 2 + 1]
                set LTry[pid * 2] = LTry[pid * 2 + 1]
                set LWait[pid * 2] = LWait[pid * 2 + 1]
                set LReq[pid * 2 + 1] = 0
            endif
            if LReq[pid * 2] == 0 then
                set LReq[pid * 2] = id
                set LTry[pid * 2] = 0
                set LWait[pid * 2] = 0
            else
                set LReq[pid * 2 + 1] = id
                set LTry[pid * 2 + 1] = 0
                set LWait[pid * 2 + 1] = 0
            endif
        endif
    endfunction

    // 원정 기록 문서(09 3.5). 공통 → 카드 → 단계 순으로 넣고, 한도에 걸리면 이후 단계를 버리고 steps_truncated=1.
    private function SendRun takes integer pid, boolean clear returns nothing
        local integer ms = ElapsedMs(RunStart)
        local integer n = 0
        local integer i
        local integer need
        local string nn
        local string mode = "solo"
        local boolean cut = Truncated[pid]
        if ms > CLEAR_MS_MAX or not Begin() then
            return
        endif
        if RunSize > 1 then
            set mode = "party"
        endif
        call Put("v", "1")
        call Put("run_key", RunKey)
        call Put("mode", mode)
        call Put("party_size", I2S(RunSize))
        call Put("hero", RunHero[pid])
        if clear then
            call Put("result", "clear")
        else
            call Put("result", "fail")
        endif
        call Put("clear_ms", I2S(ms))
        call Put("boss_rounds", I2S(ProtoBossRound))
        call Put("battles", I2S(ExpConfirmedBattles[pid]))
        set i = 0
        loop
            exitwhen i >= CardN[pid]
            call Put("card." + CardKey[pid * MAX_CARDS + i], I2S(CardCopies[pid * MAX_CARDS + i]))
            set i = i + 1
        endloop
        loop
            exitwhen n >= StepN[pid]
            set i = pid * MAX_STEPS + n
            set need = 2
            if StepPicked[i] != "" then
                set need = need + 1
            endif
            if StepEvent[i] != "" then
                set need = need + 1
            endif
            if StepAuto[i] then
                set need = need + 1
            endif
            // steps_truncated 한 칸과 30바이트를 남긴다
            if LEntries + need + 1 > ENTRY_LIMIT or LBytes + need * 12 + StringLength(StepOffered[i]) + StringLength(StepEvent[i]) + StringLength(StepPicked[i]) + 30 > BYTE_LIMIT then
                set cut = true
                exitwhen true
            endif
            set nn = "step." + Two(n) + "."
            call Put(nn + "kind", StepKind[i])
            call Put(nn + "offered", StepOffered[i])
            call Put(nn + "picked", StepPicked[i])
            call Put(nn + "event", StepEvent[i])
            if StepAuto[i] then
                call Put(nn + "auto", "1")
            endif
            set n = n + 1
        endloop
        if cut or LFull then
            set LFull = false
            call Put("steps_truncated", "1")
        endif
        call Send(pid, "expedition")
        set nn = null
        set mode = null
    endfunction

    private function SendBoss takes integer pid, boolean win returns nothing
        local integer ms = ElapsedMs(BossStart[pid])
        if ms > CLEAR_MS_MAX or not Begin() then
            return
        endif
        call Put("v", "1")
        call Put("run_key", BossKey[pid])
        if BossSize[pid] > 1 then
            call Put("mode", "party")
        else
            call Put("mode", "solo")
        endif
        call Put("party_size", I2S(BossSize[pid]))
        call Put("hero", BossHero[pid])
        if win then
            call Put("result", "win")
        else
            call Put("result", "fail")
        endif
        call Put("clear_ms", I2S(ms))
        call Put("boss", BossName[pid])
        call Send(pid, "boss")
    endfunction

    // 0.05초 동기 타이머. 결과 조회·재시도는 소유자 로컬에서만 한다(09 3.3: 오류 1·5·6·9, 시간 초과는 2·5초 뒤 같은 요청 ID 로 최대 2회).
    private function Poll takes nothing returns nothing
        local integer pid = 0
        local integer k
        local integer s
        local integer st
        local integer err
        local integer nid
        loop
            exitwhen pid >= 4
            if GetLocalPlayer() == Player(pid) then
                set k = 0
                loop
                    exitwhen k >= 2
                    set s = pid * 2 + k
                    if LReq[s] != 0 then
                        static if ARCANA_SAVE_BACKEND and ARCANA_RECORDS_ENABLED then
                            if LWait[s] > 0 then
                                set LWait[s] = LWait[s] - 1
                                if LWait[s] == 0 then
                                    set nid = ArcanaNetRetry(LReq[s])
                                    call ArcanaNetRelease(LReq[s])
                                    set LReq[s] = nid
                                endif
                            else
                                set st = ArcanaNetPoll(LReq[s])
                                if st != 0 then
                                    set err = ArcanaNetError(LReq[s])
                                    if (st == 3 or (st == 2 and (err == 1 or err == 5 or err == 6 or err == 9))) and LTry[s] < 2 then
                                        set LTry[s] = LTry[s] + 1
                                        if LTry[s] == 1 then
                                            set LWait[s] = RETRY_WAIT_1
                                        else
                                            set LWait[s] = RETRY_WAIT_2
                                        endif
                                    else
                                        // 성공(1), 재시도하지 않는 실패, 결과 없음(4) 모두 끝. 화면 표시는 하지 않는다.
                                        call ArcanaNetRelease(LReq[s])
                                        set LReq[s] = 0
                                    endif
                                endif
                            endif
                        endif
                    endif
                    set k = k + 1
                endloop
            endif
            set pid = pid + 1
        endloop
    endfunction

    //==========================================================================
    // 동기 훅
    //==========================================================================
    private function OnRunBegin takes nothing returns boolean
        local integer pid = 0
        set RunOn = true
        set RunKey = GameKey + "-" + I2S(ExpRun)
        set RunStart = TimerGetElapsed(Clock)
        set RunSize = 0
        loop
            exitwhen pid >= 4
            set RunMember[pid] = ExpMember[pid]
            set StepN[pid] = 0
            set Truncated[pid] = false
            set CardN[pid] = 0
            set ArcanaRecAuto[pid] = false
            set RunHero[pid] = I2S(GetUnitTypeId(MainUnit[pid]))
            if ExpMember[pid] then
                set RunSize = RunSize + 1
            endif
            set pid = pid + 1
        endloop
        return false
    endfunction

    // 새 단계를 연다. 64단계를 넘으면 버리고 표시만 한다.
    private function NewStep takes integer pid, string kind, string offered, string ev returns integer
        local integer i
        if not RunOn or pid < 0 or pid >= 4 or not RunMember[pid] or offered == "" then
            return -1
        endif
        if StepN[pid] >= MAX_STEPS then
            set Truncated[pid] = true
            return -1
        endif
        set i = pid * MAX_STEPS + StepN[pid]
        set StepKind[i] = kind
        set StepOffered[i] = offered
        set StepPicked[i] = ""
        set StepEvent[i] = ev
        set StepAuto[i] = false
        set StepN[pid] = StepN[pid] + 1
        return i
    endfunction

    // RecOffer: 인자 pid, 제시 목록(쉼표, 사건 ID)
    private function OnOffer takes nothing returns boolean
        set ArcanaRecAuto[ArcanaRecArgPid] = false
        call NewStep(ArcanaRecArgPid, "event", ArcanaRecArgText, "")
        return false
    endfunction

    // 쉼표 목록 list 에 item 이 정확히 있는지(목록은 4~10개 이하로 짧다).
    private function InList takes string lst, string it returns boolean
        local integer n = StringLength(lst)
        local integer i = 0
        local integer start = 0
        loop
            exitwhen i > n
            if i == n or SubString(lst, i, i + 1) == "," then
                if SubString(lst, start, i) == it then
                    return true
                endif
                set start = i + 1
            endif
            set i = i + 1
        endloop
        return false
    endfunction

    // RecPick: 인자 pid, 사건 ID. 마지막 event 단계의 선택으로 기록한다(제시 목록에 있을 때만, 서버 검증과 같다).
    private function OnPick takes nothing returns boolean
        local integer pid = ArcanaRecArgPid
        local integer i
        set ArcanaRecAuto[pid] = false
        if not RunOn or pid < 0 or pid >= 4 or not RunMember[pid] or StepN[pid] == 0 then
            return false
        endif
        set i = pid * MAX_STEPS + StepN[pid] - 1
        if StepKind[i] == "event" and StepPicked[i] == "" and InList(StepOffered[i], I2S(ArcanaRecArgId)) then
            set StepPicked[i] = I2S(ArcanaRecArgId)
        endif
        return false
    endfunction

    // RecBranch: 인자 pid, 사건 ID, 선택 번호, 허용 선택지 목록(쉼표)
    private function OnBranch takes nothing returns boolean
        local integer pid = ArcanaRecArgPid
        local integer i = NewStep(pid, "branch", ArcanaRecArgText, I2S(ArcanaRecArgId))
        if i >= 0 and InList(ArcanaRecArgText, I2S(ArcanaRecArgChoice)) then
            set StepPicked[i] = I2S(ArcanaRecArgChoice)
            set StepAuto[i] = ArcanaRecAuto[pid]
        endif
        set ArcanaRecAuto[pid] = false
        return false
    endfunction

    // RecCard: 인자 pid, 카드 키
    private function OnCard takes nothing returns boolean
        local integer pid = ArcanaRecArgPid
        local integer i = 0
        if not RunOn or pid < 0 or pid >= 4 or not RunMember[pid] or ArcanaRecArgText == "" then
            return false
        endif
        loop
            exitwhen i >= CardN[pid]
            if CardKey[pid * MAX_CARDS + i] == ArcanaRecArgText then
                set CardCopies[pid * MAX_CARDS + i] = CardCopies[pid * MAX_CARDS + i] + 1
                return false
            endif
            set i = i + 1
        endloop
        if CardN[pid] < MAX_CARDS then
            set CardKey[pid * MAX_CARDS + CardN[pid]] = ArcanaRecArgText
            set CardCopies[pid * MAX_CARDS + CardN[pid]] = 1
            set CardN[pid] = CardN[pid] + 1
        endif
        return false
    endfunction

    // RecRunEnd: 인자 Flag = 완주 여부. 끝까지 남은 참가자(ExpMember)만 보낸다(중도 이탈은 보내지 않음).
    private function OnRunEnd takes nothing returns boolean
        local integer pid = 0
        local boolean clear = ArcanaRecArgFlag
        if not RunOn then
            return false
        endif
        set RunOn = false
        loop
            exitwhen pid >= 4
            if RunMember[pid] and ExpMember[pid] and ArcanaStashNetIsReady(pid) then
                if GetLocalPlayer() == Player(pid) then
                    call SendRun(pid, clear)
                endif
            endif
            set pid = pid + 1
        endloop
        return false
    endfunction

    // RecBossBegin: 인자 Text = 보스 키, N·Unit[] = 참가자
    private function OnBossBegin takes nothing returns boolean
        local integer i = 0
        local integer pid
        local string key
        set BossSeq = BossSeq + 1
        set key = GameKey + "-b" + I2S(BossSeq)
        loop
            exitwhen i >= ArcanaRecArgN
            if ArcanaRecArgUnit[i] != null then
                set pid = GetPlayerId(GetOwningPlayer(ArcanaRecArgUnit[i]))
                if pid >= 0 and pid < 4 then
                    set BossOn[pid] = true
                    set BossKey[pid] = key
                    set BossName[pid] = ArcanaRecArgText
                    set BossStart[pid] = TimerGetElapsed(Clock)
                    set BossSize[pid] = ArcanaRecArgN
                    set BossHero[pid] = I2S(GetUnitTypeId(MainUnit[pid]))
                endif
            endif
            set i = i + 1
        endloop
        set key = null
        return false
    endfunction

    // RecBossEnd: 인자 pid, Flag = 승리
    private function OnBossEnd takes nothing returns boolean
        local integer pid = ArcanaRecArgPid
        if pid < 0 or pid >= 4 or not BossOn[pid] then
            return false
        endif
        set BossOn[pid] = false
        if ArcanaStashNetIsReady(pid) then
            if GetLocalPlayer() == Player(pid) then
                call SendBoss(pid, ArcanaRecArgFlag)
            endif
        endif
        return false
    endfunction

    private function onInit takes nothing returns nothing
        static if ARCANA_SAVE_BACKEND and ARCANA_RECORDS_ENABLED then
            // 게임 키: 동기 난수(모든 클라이언트 같음). 어댑터 GameNonce 와 별개(09 3.3).
            set GameKey = I2S(GetRandomInt(100000, 999999)) + I2S(GetRandomInt(100000, 999999))
            call TimerStart(Clock, 1000000.0, false, null)
            call TimerStart(CreateTimer(), POLL, true, function Poll)
            call TriggerAddCondition(ArcanaRecTrigRunBegin, Condition(function OnRunBegin))
            call TriggerAddCondition(ArcanaRecTrigOffer, Condition(function OnOffer))
            call TriggerAddCondition(ArcanaRecTrigPick, Condition(function OnPick))
            call TriggerAddCondition(ArcanaRecTrigBranch, Condition(function OnBranch))
            call TriggerAddCondition(ArcanaRecTrigCard, Condition(function OnCard))
            call TriggerAddCondition(ArcanaRecTrigRunEnd, Condition(function OnRunEnd))
            call TriggerAddCondition(ArcanaRecTrigBossBegin, Condition(function OnBossBegin))
            call TriggerAddCondition(ArcanaRecTrigBossEnd, Condition(function OnBossEnd))
        endif
    endfunction
endlibrary
