// 단계 7 웹 기록(09 3.3~3.5). 원정·단독 보스가 끝날 때 플레이어별 기록 하나를 서버로 보낸다. 기록 실패는 저장에 영향이 없다.
library ArcanaRecord initializer onInit requires ArcanaSaveConfig, ArcanaSaveNet3Natives, ArcanaStashNet

    // 실행 위치 규칙(ArcanaStashNet 과 같다)
    // - 동기 경로: 훅(게임 코드가 TriggerEvaluate 로 부름), 버퍼 기록, 상태 변경. 모든 클라이언트에서 같은 순서.
    // - 소유자 로컬 블록: 문서 만들기(ArcanaDoc*), 전송(ArcanaRecordSend), 결과 조회·재시도. 동기 상태와 난수를 건드리지 않는다.
    // 훅을 부르는 라이브러리는 requires 를 늘리지 않는다(라이브러리 초기화 순서 보존, 09 7절 K2). 훅 트리거·인자 전역은 모두가 이미 쓰는
    // DataExpedition(Data_Expedition.j)에 있고, 훅 자리에서는 인자를 넣고 TriggerEvaluate 만 한다(09 9절 K12). 이 라이브러리는 아무도 requires 하지 않으며
    // 두 상수가 모두 참일 때만 초기화에서 트리거를 만들고 동작을 붙인다.
    // ARCANA_RECORDS_ENABLED 가 거짓이면 훅 호출이 static if 로 빠지고 이 라이브러리는 아무 일도 하지 않는다.

    static if ARCANA_RECORDS_ENABLED then
        // 09 3.2 api=4. 이 선언이 있는 맵은 DLL 0.4.0 이상에서만 실행된다.
        native ArcanaRecordSend takes string kind, integer doc, integer seat returns integer
    endif

    globals

        private constant integer MAX_STEPS = 64
        private constant integer MAX_CARDS = 64
        // 09 8.3: DLL 한도(256항목, 16384B)보다 작게 잡고, 잘림 표식 두 개 자리(2항목, 40B)를 처음부터 남긴다
        private constant integer ENTRY_TARGET = 250
        private constant integer BYTE_TARGET = 16000
        private constant integer RESERVE_ENTRIES = 2
        private constant integer RESERVE_BYTES = 40
        private constant integer SEND_CARDS = 40
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
        private boolean LFailed = false
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
    // 남은 예산(목표 - 표식 자리) 안에 entries 항목, bytes 바이트를 더 넣을 수 있는지.
    private function Fits takes integer entries, integer bytes returns boolean
        return LEntries + entries <= ENTRY_TARGET - RESERVE_ENTRIES and LBytes + bytes <= BYTE_TARGET - RESERVE_BYTES
    endfunction

    // 한 항목을 넣는다. 빈 값은 넣지 않는다(09 3.5). 예산은 호출자가 Fits 로 먼저 본다.
    private function Add takes string k, string v returns nothing
        if v == null or v == "" then
            return
        endif
        static if ARCANA_RECORDS_ENABLED then
            if ArcanaDocAdd(LDoc, k, v) != 1 then
                set LFailed = true
            endif
        endif
        set LEntries = LEntries + 1
        set LBytes = LBytes + StringLength(k) + StringLength(v)
    endfunction

    private function Begin takes nothing returns boolean
        set LEntries = 0
        set LBytes = 0
        set LFailed = false
        set LDoc = 0
        static if ARCANA_RECORDS_ENABLED then
            set LDoc = ArcanaDocNew()
        endif
        return LDoc != 0
    endfunction

    // 문서를 보내고 결과 핸들을 플레이어 칸에 넣는다. 칸이 차 있으면 가장 오래된 것을 버린다(09 3.3).
    private function Send takes integer pid, string kind returns nothing
        local integer id = 0
        static if ARCANA_RECORDS_ENABLED then
            if LFailed then
                // 빌더가 넣지 못한 항목이 있으면 DLL 이 0 을 돌려주므로 보내지 않는다(문서는 DLL 이 소비)
                call ArcanaRecordSend("", LDoc, pid)
                set LDoc = 0
                return
            endif
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

    // 원정 기록 문서(09 3.5, 8.3). 공통 키 → 카드(획득 순, 최대 40) → 단계(0번부터, 단계 키를 모두 넣을 수 있을 때만).
    // 카드가 넘치면 cards_truncated=1, 단계가 넘치면 steps_truncated=1. 표식 두 개 자리는 처음부터 남겨 둔다.
    private function SendRun takes integer pid, boolean clear returns nothing
        local integer ms = ElapsedMs(RunStart)
        local integer n = 0
        local integer i
        local integer e
        local integer b
        local string nn
        local string mode = "solo"
        local boolean stepsCut = Truncated[pid]
        local boolean cardsCut = false
        if ms > CLEAR_MS_MAX or not Begin() then
            return
        endif
        if RunSize > 1 then
            set mode = "party"
        endif
        call Add("v", "1")
        call Add("run_key", RunKey)
        call Add("mode", mode)
        call Add("party_size", I2S(RunSize))
        call Add("hero", RunHero[pid])
        if clear then
            call Add("result", "clear")
        else
            call Add("result", "fail")
        endif
        call Add("clear_ms", I2S(ms))
        call Add("boss_rounds", I2S(ProtoBossRound))
        call Add("battles", I2S(ExpConfirmedBattles[pid]))
        set i = 0
        loop
            exitwhen i >= CardN[pid]
            set nn = "card." + CardKey[pid * MAX_CARDS + i]
            if i >= SEND_CARDS or not Fits(1, StringLength(nn) + StringLength(I2S(CardCopies[pid * MAX_CARDS + i]))) then
                set cardsCut = true
                exitwhen true
            endif
            call Add(nn, I2S(CardCopies[pid * MAX_CARDS + i]))
            set i = i + 1
        endloop
        loop
            exitwhen n >= StepN[pid]
            set i = pid * MAX_STEPS + n
            set nn = "step." + Two(n) + "."
            // 이 단계의 항목 수·바이트를 정확히 센다
            set e = 2
            set b = StringLength(nn) * 2 + 4 + 7 + StringLength(StepKind[i]) + StringLength(StepOffered[i])
            if StepPicked[i] != "" then
                set e = e + 1
                set b = b + StringLength(nn) + 6 + StringLength(StepPicked[i])
                if StepAuto[i] then
                    set e = e + 1
                    set b = b + StringLength(nn) + 4 + 1
                endif
            endif
            if StepEvent[i] != "" then
                set e = e + 1
                set b = b + StringLength(nn) + 5 + StringLength(StepEvent[i])
            endif
            if not Fits(e, b) then
                set stepsCut = true
                exitwhen true
            endif
            call Add(nn + "kind", StepKind[i])
            call Add(nn + "offered", StepOffered[i])
            call Add(nn + "picked", StepPicked[i])
            call Add(nn + "event", StepEvent[i])
            if StepAuto[i] and StepPicked[i] != "" then
                call Add(nn + "auto", "1")
            endif
            set n = n + 1
        endloop
        // 표식은 남겨 둔 자리에 넣는다
        if cardsCut then
            call Add("cards_truncated", "1")
        endif
        if stepsCut then
            call Add("steps_truncated", "1")
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
        call Add("v", "1")
        call Add("run_key", BossKey[pid])
        if BossSize[pid] > 1 then
            call Add("mode", "party")
        else
            call Add("mode", "solo")
        endif
        call Add("party_size", I2S(BossSize[pid]))
        call Add("hero", BossHero[pid])
        if win then
            call Add("result", "win")
        else
            call Add("result", "fail")
        endif
        call Add("clear_ms", I2S(ms))
        call Add("boss", BossName[pid])
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
                        static if ARCANA_RECORDS_ENABLED then
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
        static if ARCANA_RECORDS_ENABLED then
            // 게임 키: 동기 난수(모든 클라이언트 같음). 어댑터 GameNonce 와 별개(09 3.3).
            set GameKey = I2S(GetRandomInt(100000, 999999)) + I2S(GetRandomInt(100000, 999999))
            call TimerStart(Clock, 1000000.0, false, null)
            call TimerStart(CreateTimer(), POLL, true, function Poll)
            set ArcanaRecTrigRunBegin = CreateTrigger()
            call TriggerAddCondition(ArcanaRecTrigRunBegin, Condition(function OnRunBegin))
            set ArcanaRecTrigOffer = CreateTrigger()
            call TriggerAddCondition(ArcanaRecTrigOffer, Condition(function OnOffer))
            set ArcanaRecTrigPick = CreateTrigger()
            call TriggerAddCondition(ArcanaRecTrigPick, Condition(function OnPick))
            set ArcanaRecTrigBranch = CreateTrigger()
            call TriggerAddCondition(ArcanaRecTrigBranch, Condition(function OnBranch))
            set ArcanaRecTrigCard = CreateTrigger()
            call TriggerAddCondition(ArcanaRecTrigCard, Condition(function OnCard))
            set ArcanaRecTrigRunEnd = CreateTrigger()
            call TriggerAddCondition(ArcanaRecTrigRunEnd, Condition(function OnRunEnd))
            set ArcanaRecTrigBossBegin = CreateTrigger()
            call TriggerAddCondition(ArcanaRecTrigBossBegin, Condition(function OnBossBegin))
            set ArcanaRecTrigBossEnd = CreateTrigger()
            call TriggerAddCondition(ArcanaRecTrigBossEnd, Condition(function OnBossEnd))
        endif
    endfunction
endlibrary
