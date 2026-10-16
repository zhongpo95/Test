// Arcana 자체 저장 서버(api=3)용 Stash 저장·불러오기 어댑터다. JNStashNet 과 같은 이벤트 인터페이스를 주고 결과는 동기화 경로에서만 적용한다.
library ArcanaStashNet initializer onInit requires ArcanaSaveConfig, ArcanaSaveNet3Natives, Stash, DzAPISync

    // 실행 위치 규칙 (Codex 검토, 07 6.5·6.6)
    // - 동기 경로(모든 클라이언트): 공개 함수 호출, 0.05초 동기 타이머, DzSyncData 수신 콜백.
    //   CreateStash·StashCopy·DestroyStash·StashSave(적용), 상태·대기열·tag 변경, 콜백 발생은 여기서만 한다.
    //   Stash.j 의 생성 함수가 MAX_STASH 를 늘리므로 이것을 로컬 블록에서 부르면 클라이언트마다 핸들 번호가 달라진다.
    // - 소유자 로컬 블록(GetLocalPlayer() == p): DLL 호출(Arcana*/ArcanaNet*), DzSyncData 송신, 동기 경로가 채운 표(SnapTab) 읽기만 한다. Stash 는 읽지 않는다.
    //   로컬 블록의 결과는 반드시 DzSyncData 패킷으로 보내고, 받은 쪽 동기 콜백에서 상태에 반영한다.
    // - 같은 송신자의 DzSyncData 는 보낸 순서대로 모든 클라이언트에 도착한다(lockstep). 로드 패킷 수신은 이 순서를 전제로 한다.

    globals
        // 게임 로그인 연결(ArcanaSaveLogin → PlayerSave → UIPick). requires 를 늘리지 않으려고 이 라이브러리에 둔다. Arcana 판 초기화에서만 만든다.
        trigger ARCANA_LOGIN_OK = null
        integer ARCANA_LOGIN_OK_PID = -1
        boolean array ARCANA_LOGIN_DONE
        trigger ARCANA_PICK_SHOW = null
        integer ARCANA_PICK_SHOW_PID = -1
        private constant string PREFIX = "ARCSAVE"
        private constant real TICK = 0.05
        private constant integer BUILD_PER_TICK = 200       // 07 D12
        private constant integer APPLY_PER_TICK = 200
        private constant integer LOAD_STAGGER_TICKS = 10    // 0.5초, 07 D11
        private constant integer LOAD_HTTP_TIMEOUT_TICKS = 900   // 45초(DLL 20초 + 여유)
        private constant integer LOAD_IDLE_TICKS = 200           // 10초. 여기에 현재 대기열 인원 × 2틱을 더한다(07 6.5)
        private constant integer SAVE_TIMEOUT_TICKS = 1800       // 90초(재시도 3회 포함)
        private constant integer STATUS_DELAY_1 = 40        // 2초, 07 11.4
        private constant integer STATUS_DELAY_2 = 100       // 5초
        private constant integer STATUS_DELAY_3 = 200       // 10초
        // 07 2.3 고정 상수(수신부 검증)
        private constant integer BODY_MAX = 900
        private constant integer KEY_MAX = 128
        private constant integer ENTRY_ENC_MAX = 892
        private constant integer PACKETS_MAX = 320
        private constant integer ENTRIES_MAX = 4000
        private constant integer DOC_BYTES_MAX = 262144
        private constant integer INFO_MAX = 80

        // 패킷 종류. 4·5 는 06 10.2, 7·8 은 동기 대기열을 위한 추가(DESIGN_FEEDBACK_07 F8)
        private constant integer K_LOAD_DATA = 4
        private constant integer K_SAVE_RESULT = 5
        private constant integer K_LOAD_READY = 7
        private constant integer K_SAVE_STARTED = 8

        // 플레이어 상태(06 11.1). 모든 클라이언트에서 같다. 1·2 만 저장을 허용한다.
        constant integer ARCANA_STASH_UNKNOWN = 0
        constant integer ARCANA_STASH_LOADED = 1
        constant integer ARCANA_STASH_NEW = 2
        constant integer ARCANA_STASH_FAILED = 3
        constant integer ARCANA_STASH_CONFLICT = 4
        constant integer ARCANA_STASH_LEASE_LOST = 5
        // 저장 결과 불명·인증 실패·시간 초과. 반영 여부를 모르므로 다시 로드할 때까지 저장을 막는다(Codex 검토 1)
        constant integer ARCANA_STASH_RESULT_UNKNOWN = 6

        // 단계: 0 없음, 1 로드 시작 대기, 2 로드 HTTP 중, 3 로드 패킷 수신, 4 로드 적용, 5 저장 문서 작성, 6 저장 결과 대기
        private integer array Phase
        private integer array St
        private integer array Rev
        private integer array Tag
        private integer array StartTick
        private integer array Deadline
        private integer array Total
        private integer array Got
        private integer array SentSeq
        private integer array LoadRev
        private integer array BufN
        private integer array BufBytes
        private integer array Trailer
        private integer array ApplyIdx
        private string array LoadInfo
        private stash array ApplyStash
        private stash array Snap
        private trigger array CbLoad
        private trigger array CbSave
        private hashtable Buf = InitHashtable()
        // 마지막 로드의 받은 패킷 본문 원문(정확 대조용, 동기 경로에서만 기록)
        private hashtable Raw = InitHashtable()
        // 저장 스냅숏 읽기는 동기 경로(모든 클라이언트)에서 한다. Stash 읽기(StashKeyAt/StashValueAt)는 ForForce 를 써서
        // 소유자 로컬 블록에서 부르면 같은 PC 두 창 LAN 에서 다른 창이 끊겼다(멀티_끊김_조사 19절). 소유자 로컬은 이 표만 읽는다.
        private hashtable SnapTab = InitHashtable()
        private integer array SnapN
        private integer array SnapCur
        private boolean array SnapReady
        private integer array RawN

        // 공용 송신 대기열(07 D11). 모든 클라이언트에서 같다.
        private integer array QPid
        private integer QLen = 0
        private integer QHead = 0
        private integer NextStagger = 0
        private integer Now = 0
        private integer GameNonce = 0

        // 소유자 로컬 상태. 그 플레이어의 클라이언트에서만 의미가 있다.
        // LPhase: 0 없음, 1 로드 대기, 2 로드 패킷 보유, 5 문서 작성, 6 저장 응답 대기, 7 상태 조회 대기, 8 상태 조회 중
        private integer array LPhase
        private integer array LReq
        private integer array LDoc
        private integer array LCursor
        private integer array LTries
        private integer array LWait
        private integer array LStatus
        private integer array LFirstErr

        // 이벤트(JNStashNet 과 같은 의미)
        private player EV_USER = null
        private stash EV_STASH = 0
        private boolean EV_FINISHED = false
        private boolean EV_RESULT = false
        private string EV_MESSAGE = ""
        private integer EV_MAX = 0
        private integer EV_PROGRESS = 0
    endglobals

    //==========================================================================
    // DLL 호출 감싸기. JN 판(ARCANA_SAVE_BACKEND 거짓)에서는 native 참조가 빠지고 0/빈 값을 돌려준다.
    // 모두 소유자 로컬 블록에서만 부른다.
    //==========================================================================
    private function N_LoadBegin takes integer seat returns integer
        static if ARCANA_SAVE_BACKEND then
            return ArcanaLoadBegin("main", ARCANA_MAP_VERSION, seat)
        else
            return 0
        endif
    endfunction
    private function N_SaveBegin takes integer doc, integer expected returns integer
        static if ARCANA_SAVE_BACKEND then
            return ArcanaSaveBegin("main", doc, expected)
        else
            return 0
        endif
    endfunction
    private function N_StatusBegin takes string rid returns integer
        static if ARCANA_SAVE_BACKEND then
            return ArcanaStatusBegin(rid, 1)
        else
            return 0
        endif
    endfunction
    private function N_DocNew takes nothing returns integer
        static if ARCANA_SAVE_BACKEND then
            return ArcanaDocNew()
        else
            return 0
        endif
    endfunction
    private function N_DocAdd takes integer doc, string k, string v returns integer
        static if ARCANA_SAVE_BACKEND then
            return ArcanaDocAdd(doc, k, v)
        else
            return 0
        endif
    endfunction
    private function N_DocDrop takes integer doc returns integer
        static if ARCANA_SAVE_BACKEND then
            return ArcanaDocDrop(doc)
        else
            return 0
        endif
    endfunction
    private function N_Packets takes integer id returns integer
        static if ARCANA_SAVE_BACKEND then
            return ArcanaLoadPackets(id)
        else
            return -1
        endif
    endfunction
    private function N_Packet takes integer id, integer i returns string
        static if ARCANA_SAVE_BACKEND then
            return ArcanaLoadPacket(id, i)
        else
            return ""
        endif
    endfunction
    private function N_Poll takes integer id returns integer
        static if ARCANA_SAVE_BACKEND then
            return ArcanaNetPoll(id)
        else
            return 4
        endif
    endfunction
    private function N_Error takes integer id returns integer
        static if ARCANA_SAVE_BACKEND then
            return ArcanaNetError(id)
        else
            return 8
        endif
    endfunction
    private function N_Revision takes integer id returns integer
        static if ARCANA_SAVE_BACKEND then
            return ArcanaNetRevision(id)
        else
            return -1
        endif
    endfunction
    private function N_Result takes integer id returns string
        static if ARCANA_SAVE_BACKEND then
            return ArcanaNetResult(id)
        else
            return ""
        endif
    endfunction
    private function N_RequestId takes integer id returns string
        static if ARCANA_SAVE_BACKEND then
            return ArcanaNetRequestId(id)
        else
            return ""
        endif
    endfunction
    private function N_Retry takes integer id returns integer
        static if ARCANA_SAVE_BACKEND then
            return ArcanaNetRetry(id)
        else
            return 0
        endif
    endfunction
    private function N_Release takes integer id returns nothing
        static if ARCANA_SAVE_BACKEND then
            if id != 0 then
                call ArcanaNetRelease(id)
            endif
        endif
    endfunction

    //==========================================================================
    // 공용 도구
    //==========================================================================
    // 정확히 8바이트이고 모두 0~9 인지(09 2.1 서버 날짜).
    private function Digits8 takes string s returns boolean
        local integer i = 0
        local string c
        if StringLength(s) != 8 then
            return false
        endif
        loop
            exitwhen i >= 8
            set c = SubString(s, i, i + 1)
            if c != "0" and c != "1" and c != "2" and c != "3" and c != "4" and c != "5" and c != "6" and c != "7" and c != "8" and c != "9" then
                return false
            endif
            set i = i + 1
        endloop
        return true
    endfunction

    private function Fire takes trigger cb, player user, stash s, boolean result, string message, integer max, integer progress returns nothing
        local player pUser = EV_USER
        local stash pStash = EV_STASH
        local boolean pFinished = EV_FINISHED
        local boolean pResult = EV_RESULT
        local string pMessage = EV_MESSAGE
        local integer pMax = EV_MAX
        local integer pProgress = EV_PROGRESS
        if cb == null then
            set pUser = null
            return
        endif
        set EV_USER = user
        set EV_STASH = s
        set EV_FINISHED = true
        set EV_RESULT = result
        set EV_MESSAGE = message
        set EV_MAX = max
        set EV_PROGRESS = progress
        call TriggerExecute(cb)
        set EV_USER = pUser
        set EV_STASH = pStash
        set EV_FINISHED = pFinished
        set EV_RESULT = pResult
        set EV_MESSAGE = pMessage
        set EV_MAX = pMax
        set EV_PROGRESS = pProgress
        set pUser = null
    endfunction

    // 0~999,999,999 의 음이 아닌 10진수만 받는다. 아니면 -1 (Codex 검토 4)
    private function Nat takes string s returns integer
        local integer len = StringLength(s)
        local integer i = 0
        local string c
        if s == null or len < 1 or len > 9 then
            return -1
        endif
        loop
            exitwhen i >= len
            set c = SubString(s, i, i + 1)
            if c != "0" and c != "1" and c != "2" and c != "3" and c != "4" and c != "5" and c != "6" and c != "7" and c != "8" and c != "9" then
                return -1
            endif
            set i = i + 1
        endloop
        return S2I(s)
    endfunction

    // revision 은 -1(없음) 또는 0~2,000,000,000(08 2.4 상한, JASS 정수 범위 안). 숫자만, 최대 10자리. 그 밖은 -2
    private function RevField takes string s returns integer
        local integer len = StringLength(s)
        local integer i = 0
        local string c
        if s == "-1" then
            return -1
        endif
        if s == null or len < 1 or len > 10 then
            return -2
        endif
        loop
            exitwhen i >= len
            set c = SubString(s, i, i + 1)
            if c != "0" and c != "1" and c != "2" and c != "3" and c != "4" and c != "5" and c != "6" and c != "7" and c != "8" and c != "9" then
                return -2
            endif
            set i = i + 1
        endloop
        // 10자리는 S2I 전에 자릿값으로 상한을 확인한다(2147483648 이상이 정수로 넘치지 않게). 첫 자리 3~9 거부, 2 이면 나머지가 모두 0 이어야 한다
        if len == 10 then
            set c = SubString(s, 0, 1)
            if c != "0" and c != "1" and c != "2" then
                return -2
            endif
            if c == "2" and SubString(s, 1, 10) != "000000000" then
                return -2
            endif
        endif
        return S2I(s)
    endfunction

    private function FieldAt takes string s, integer index returns string
        local integer len = StringLength(s)
        local integer i = 0
        local integer start = 0
        local integer n = 0
        loop
            exitwhen i >= len
            if SubString(s, i, i + 1) == "|" then
                if n == index then
                    return SubString(s, start, i)
                endif
                set n = n + 1
                set start = i + 1
                if n == 9 and index == 9 then
                    return SubString(s, start, len)
                endif
            endif
            set i = i + 1
        endloop
        if n == index then
            return SubString(s, start, len)
        endif
        return null
    endfunction

    // 소유자 로컬 블록 안에서만 부른다.
    private function Send takes integer pid, integer seq, integer total, integer kind, integer state, integer err, integer rev, string payload returns nothing
        call DzSyncData(PREFIX, I2S(GameNonce) + "|" + I2S(pid) + "|" + I2S(Tag[pid]) + "|" + I2S(seq) + "|" + I2S(total) + "|" + I2S(kind) + "|" + I2S(state) + "|" + I2S(err) + "|" + I2S(rev) + "|" + payload)
    endfunction

    private function QueueAdd takes integer pid returns nothing
        set QPid[QLen] = pid
        set QLen = QLen + 1
    endfunction

    private function QueueRemove takes integer pid returns nothing
        local integer i = 0
        local integer j = 0
        loop
            exitwhen i >= QLen
            if QPid[i] != pid then
                set QPid[j] = QPid[i]
                set j = j + 1
            elseif i < QHead then
                set QHead = QHead - 1
            endif
            set i = i + 1
        endloop
        set QLen = j
        if QHead >= QLen then
            set QHead = 0
        endif
    endfunction

    // 동기 경로. 본문(<키 바이트>:<값 바이트>:<키><값>... [#항목 수])을 검증하며 버퍼에 쌓는다. 형식·한도 위반이면 거짓.
    private function ParsePacket takes integer pid, string payload, boolean last returns boolean
        local integer len = StringLength(payload)
        local integer i = 0
        local integer j
        local integer kb
        local integer vb
        local string head
        if len > BODY_MAX then
            return false
        endif
        loop
            exitwhen i >= len
            if SubString(payload, i, i + 1) == "#" then
                set kb = Nat(SubString(payload, i + 1, len))
                if not last or kb < 0 or kb > ENTRIES_MAX then
                    return false
                endif
                set Trailer[pid] = kb
                return true
            endif
            set j = i
            loop
                exitwhen j >= len or j - i > 4 or SubString(payload, j, j + 1) == ":"
                set j = j + 1
            endloop
            if j >= len or SubString(payload, j, j + 1) != ":" then
                return false
            endif
            set kb = Nat(SubString(payload, i, j))
            set head = SubString(payload, i, j + 1)
            set i = j + 1
            set j = i
            loop
                exitwhen j >= len or j - i > 4 or SubString(payload, j, j + 1) == ":"
                set j = j + 1
            endloop
            if j >= len or SubString(payload, j, j + 1) != ":" then
                return false
            endif
            set vb = Nat(SubString(payload, i, j))
            set head = head + SubString(payload, i, j + 1)
            set i = j + 1
            if kb < 1 or kb > KEY_MAX or vb < 0 or StringLength(head) + kb + vb > ENTRY_ENC_MAX or i + kb + vb > len then
                return false
            endif
            if BufN[pid] >= ENTRIES_MAX or BufBytes[pid] + kb + vb > DOC_BYTES_MAX then
                return false
            endif
            call SaveStr(Buf, pid, BufN[pid] * 2, SubString(payload, i, i + kb))
            call SaveStr(Buf, pid, BufN[pid] * 2 + 1, SubString(payload, i + kb, i + kb + vb))
            set BufN[pid] = BufN[pid] + 1
            set BufBytes[pid] = BufBytes[pid] + kb + vb
            set i = i + kb + vb
        endloop
        // 마지막 패킷인데 꼬리가 없으면 틀림
        set head = null
        return not last
    endfunction

    //==========================================================================
    // 동기 경로: 완료 처리
    //==========================================================================
    // 소유자 로컬 정리. 동기 완료(시간 초과 포함) 뒤 DLL 요청·문서·상태 조회가 표에 남지 않게 한다(Codex 검토 2).
    private function LocalCleanup takes integer pid returns nothing
        if GetLocalPlayer() == Player(pid) then
            call N_Release(LReq[pid])
            call N_Release(LStatus[pid])
            if LDoc[pid] != 0 then
                call N_DocDrop(LDoc[pid])
            endif
            set LReq[pid] = 0
            set LStatus[pid] = 0
            set LDoc[pid] = 0
            set LPhase[pid] = 0
        endif
    endfunction

    private function FinishLoad takes integer pid, integer state, boolean result, string message returns nothing
        local stash s = ApplyStash[pid]
        call LocalCleanup(pid)
        call QueueRemove(pid)
        call FlushChildHashtable(Buf, pid)
        set BufN[pid] = 0
        set BufBytes[pid] = 0
        set Phase[pid] = 0
        set St[pid] = state
        if not result then
            if s != 0 then
                call DestroyStash(s)
            endif
            set s = 0
            call FlushChildHashtable(Raw, pid)
            set RawN[pid] = 0
        endif
        set ApplyStash[pid] = 0
        call Fire(CbLoad[pid], Player(pid), s, result, message, Total[pid], Got[pid])
    endfunction

    private function FinishSave takes integer pid, integer state, boolean result, string message returns nothing
        call ArcanaSaveTrace("[ARC-NET] save finish pid=" + I2S(pid) + " ok=" + I2S(IntegerTertiaryOp(result, 1, 0)) + " state=" + I2S(state) + " phase=" + I2S(Phase[pid]) + " snapN=" + I2S(SnapN[pid]) + " ready=" + I2S(IntegerTertiaryOp(SnapReady[pid], 1, 0)) + " now=" + I2S(Now) + " msg=" + message)
        call LocalCleanup(pid)
        if Snap[pid] != 0 then
            call DestroyStash(Snap[pid])
            set Snap[pid] = 0
        endif
        call FlushChildHashtable(SnapTab, pid)
        set SnapN[pid] = 0
        set SnapCur[pid] = 0
        set SnapReady[pid] = false
        set Phase[pid] = 0
        set St[pid] = state
        call Fire(CbSave[pid], Player(pid), 0, result, message, 0, 0)
    endfunction

    //==========================================================================
    // 동기 경로: 수신
    //==========================================================================
    private function OnSync takes nothing returns nothing
        local player sender = DzGetTriggerSyncPlayer()
        local integer pid = GetPlayerId(sender)
        local string packet = DzGetTriggerSyncData()
        local string payload
        local integer kind
        local integer seq
        local integer total
        local integer state
        local integer err
        local integer rev
        set sender = null
        if Nat(FieldAt(packet, 0)) != GameNonce or Nat(FieldAt(packet, 1)) != pid or Nat(FieldAt(packet, 2)) != Tag[pid] then
            // 다른 게임·다른 송신자·지난 작업의 패킷(또는 형식이 틀린 머리글)
            return
        endif
        set seq = Nat(FieldAt(packet, 3))
        set total = Nat(FieldAt(packet, 4))
        set kind = Nat(FieldAt(packet, 5))
        set state = Nat(FieldAt(packet, 6))
        set err = Nat(FieldAt(packet, 7))
        set rev = RevField(FieldAt(packet, 8))
        set payload = FieldAt(packet, 9)
        if seq < 0 or total < 0 or kind < 0 or state < 0 or err < 0 or rev < -1 or payload == null then
            // 이 작업의 패킷인데 머리글이 틀렸다. 부분 적용 없이 실패로 끝낸다.
            if Phase[pid] == 2 or Phase[pid] == 3 then
                call FinishLoad(pid, ARCANA_STASH_FAILED, false, "로드 패킷 머리글 오류")
            elseif Phase[pid] == 5 or Phase[pid] == 6 then
                call FinishSave(pid, ARCANA_STASH_RESULT_UNKNOWN, false, "저장 결과 패킷 오류(다시 로드 필요)")
            endif
            return
        endif
        if kind == K_LOAD_READY and Phase[pid] == 2 then
            if state == 1 and total >= 1 and total <= PACKETS_MAX and rev >= 1 and StringLength(payload) <= INFO_MAX then
                set Total[pid] = total
                set Got[pid] = 0
                set SentSeq[pid] = 0
                set LoadRev[pid] = rev
                set LoadInfo[pid] = payload
                set BufN[pid] = 0
                set BufBytes[pid] = 0
                set Trailer[pid] = -1
                call FlushChildHashtable(Raw, pid)
                set RawN[pid] = 0
                set Phase[pid] = 3
                set Deadline[pid] = Now + LOAD_IDLE_TICKS
                call QueueAdd(pid)
            elseif state == 2 and err == 3 then
                // 신규(서버에 저장 없음). 빈 Stash 로 성공(06 11.2). 실패와 구별한다.
                set Rev[pid] = 0
                // 09 2.1·D9: "new" 또는 "new;day=" + 숫자 8자리만 받는다. 그 밖(빈 값, 다른 문자, 길이 초과, 자릿수 틀림)은 "new".
                if StringLength(payload) == 16 and SubString(payload, 0, 8) == "new;day=" and Digits8(SubString(payload, 8, 16)) then
                    set LoadInfo[pid] = payload
                else
                    set LoadInfo[pid] = "new"
                endif
                call FlushChildHashtable(Raw, pid)
                set RawN[pid] = 0
                set ApplyStash[pid] = CreateStash()
                call FinishLoad(pid, ARCANA_STASH_NEW, true, "신규")
            else
                call FinishLoad(pid, ARCANA_STASH_FAILED, false, "로드 실패 오류 " + I2S(err))
            endif
        elseif kind == K_LOAD_DATA and Phase[pid] == 3 then
            if seq != Got[pid] or total != Total[pid] or not ParsePacket(pid, payload, seq == total - 1) then
                call FinishLoad(pid, ARCANA_STASH_FAILED, false, "로드 패킷 오류")
            else
                call SaveStr(Raw, pid, seq, payload)
                set RawN[pid] = seq + 1
                set Got[pid] = Got[pid] + 1
                set Deadline[pid] = Now + LOAD_IDLE_TICKS
                if Got[pid] >= Total[pid] then
                    call QueueRemove(pid)
                    if Trailer[pid] != BufN[pid] then
                        call FinishLoad(pid, ARCANA_STASH_FAILED, false, "항목 수 불일치")
                    else
                        set ApplyStash[pid] = CreateStash()
                        set ApplyIdx[pid] = 0
                        set Phase[pid] = 4
                    endif
                endif
            endif
        elseif kind == K_SAVE_STARTED and Phase[pid] == 5 then
            set Phase[pid] = 6
            set Deadline[pid] = Now + SAVE_TIMEOUT_TICKS
        elseif kind == K_SAVE_RESULT and (Phase[pid] == 5 or Phase[pid] == 6) then
            if state == 1 and rev >= 1 then
                set Rev[pid] = rev
                call FinishSave(pid, ARCANA_STASH_LOADED, true, "저장 확정")
            elseif err == 4 then
                call FinishSave(pid, ARCANA_STASH_CONFLICT, false, "다른 곳에서 더 최신 저장이 있습니다(다시 로드 필요)")
            elseif err == 11 then
                call FinishSave(pid, ARCANA_STASH_LEASE_LOST, false, "다른 게임에서 같은 계정으로 접속했습니다")
            elseif err == 12 then
                // 서버로 보내지 않은 거절(로드 불가 문서). 반영 안 됨이 확정이므로 상태는 그대로(07 2.5)
                call FinishSave(pid, St[pid], false, "저장 데이터 한도를 넘었습니다")
            else
                // 결과 불명·인증 실패 등. 반영 여부를 모르므로 다시 로드할 때까지 저장을 막는다
                call FinishSave(pid, ARCANA_STASH_RESULT_UNKNOWN, false, "저장 결과 불명 오류 " + I2S(err) + "(다시 로드 필요)")
            endif
        endif
        set payload = null
    endfunction

    //==========================================================================
    // 소유자 로컬: 요청 진행. Tick 에서 GetLocalPlayer() == Player(pid) 일 때만 부른다.
    //==========================================================================
    private function LocalSaveFinal takes integer pid, integer state, integer err, integer rev returns nothing
        call Send(pid, 0, 1, K_SAVE_RESULT, state, err, rev, "")
        call N_Release(LReq[pid])
        call N_Release(LStatus[pid])
        set LReq[pid] = 0
        set LStatus[pid] = 0
        set LPhase[pid] = 0
    endfunction

    // 동기 경로: 스냅숏을 표(SnapTab)로 옮긴다. 삭제된 항목(값 null)은 넣지 않는다(07 D8).
    private function SnapCopyStep takes integer pid returns nothing
        local stash s = Snap[pid]
        local integer size = StashSize(s)
        local integer n = 0
        local string v
        loop
            exitwhen SnapCur[pid] >= size or n >= BUILD_PER_TICK
            set v = StashValueAt(s, SnapCur[pid], null)
            if v != null then
                call SaveStr(SnapTab, pid, SnapN[pid] * 2, StashKeyAt(s, SnapCur[pid]))
                call SaveStr(SnapTab, pid, SnapN[pid] * 2 + 1, v)
                set SnapN[pid] = SnapN[pid] + 1
            endif
            set SnapCur[pid] = SnapCur[pid] + 1
            set n = n + 1
        endloop
        if SnapCur[pid] >= size then
            set SnapReady[pid] = true
            call ArcanaSaveTrace("[ARC-NET] snapshot ready pid=" + I2S(pid) + " size=" + I2S(size) + " live=" + I2S(SnapN[pid]) + " now=" + I2S(Now))
        endif
        set v = null
    endfunction

    // 소유자 로컬: 동기 경로가 채운 표만 읽어 DLL 문서를 만든다(Stash 를 직접 읽지 않는다).
    private function LocalBuild takes integer pid returns nothing
        local integer n = 0
        if not SnapReady[pid] then
            return
        endif
        loop
            exitwhen LCursor[pid] >= SnapN[pid] or n >= BUILD_PER_TICK
            call N_DocAdd(LDoc[pid], LoadStr(SnapTab, pid, LCursor[pid] * 2), LoadStr(SnapTab, pid, LCursor[pid] * 2 + 1))
            set LCursor[pid] = LCursor[pid] + 1
            set n = n + 1
        endloop
        if LCursor[pid] >= SnapN[pid] then
            set LReq[pid] = N_SaveBegin(LDoc[pid], Rev[pid])
            call ArcanaSaveTrace("[ARC-NET] save begin pid=" + I2S(pid) + " doc entries=" + I2S(SnapN[pid]) + " expected=" + I2S(Rev[pid]) + " req=" + I2S(LReq[pid]))
            set LDoc[pid] = 0   // 성공·실패와 관계없이 DLL이 소비했다
            if LReq[pid] == 0 then
                call LocalSaveFinal(pid, 2, 12, -1)
            else
                call Send(pid, 0, 1, K_SAVE_STARTED, 0, 0, 0, "")
                set LPhase[pid] = 6
            endif
        endif
    endfunction

    private function IsUnknown takes integer state, integer err returns boolean
        return state == 3 or (state == 2 and (err == 1 or err == 5 or err == 6 or err == 9))
    endfunction

    private function LocalStep takes integer pid returns nothing
        local integer st
        local integer id
        if LPhase[pid] == 1 then
            set st = N_Poll(LReq[pid])
            if st == 1 then
                call Send(pid, 0, N_Packets(LReq[pid]), K_LOAD_READY, 1, 0, N_Revision(LReq[pid]), N_Result(LReq[pid]))
                set LPhase[pid] = 2
            elseif st != 0 then
                // 09 2.1: 신규(오류 3)일 때만 DLL 결과("new;day=YYYYMMDD")를 함께 보낸다. 다른 오류는 지금처럼 빈 문자열.
                if N_Error(LReq[pid]) == 3 then
                    call Send(pid, 0, 0, K_LOAD_READY, 2, 3, N_Revision(LReq[pid]), N_Result(LReq[pid]))
                else
                    call Send(pid, 0, 0, K_LOAD_READY, 2, N_Error(LReq[pid]), N_Revision(LReq[pid]), "")
                endif
                call N_Release(LReq[pid])
                set LReq[pid] = 0
                set LPhase[pid] = 0
            endif
        elseif LPhase[pid] == 5 then
            call LocalBuild(pid)
        elseif LPhase[pid] == 6 then
            set st = N_Poll(LReq[pid])
            if st == 1 then
                call LocalSaveFinal(pid, 1, 0, N_Revision(LReq[pid]))
            elseif st != 0 then
                if IsUnknown(st, N_Error(LReq[pid])) and LTries[pid] < 3 then
                    // 결과 불명: 상태 조회(봉인)부터. 2·5·10초 간격(07 11.4)
                    if LTries[pid] == 0 then
                        set LFirstErr[pid] = N_Error(LReq[pid])
                        set LWait[pid] = STATUS_DELAY_1
                    elseif LTries[pid] == 1 then
                        set LWait[pid] = STATUS_DELAY_2
                    else
                        set LWait[pid] = STATUS_DELAY_3
                    endif
                    set LTries[pid] = LTries[pid] + 1
                    set LPhase[pid] = 7
                else
                    call LocalSaveFinal(pid, 2, N_Error(LReq[pid]), N_Revision(LReq[pid]))
                endif
            endif
        elseif LPhase[pid] == 7 then
            set LWait[pid] = LWait[pid] - 1
            if LWait[pid] <= 0 then
                set LStatus[pid] = N_StatusBegin(N_RequestId(LReq[pid]))
                set LPhase[pid] = 8
            endif
        elseif LPhase[pid] == 8 then
            set st = N_Poll(LStatus[pid])
            if st == 1 then
                if N_Result(LStatus[pid]) == "200" then
                    call LocalSaveFinal(pid, 1, 0, N_Revision(LStatus[pid]))
                elseif N_Result(LStatus[pid]) == "409" then
                    call LocalSaveFinal(pid, 2, 4, N_Revision(LStatus[pid]))
                else
                    // 봉인됨(미도착 확정): 같은 스냅숏을 새 요청 ID로 다시 만든다
                    call N_Release(LReq[pid])
                    call N_Release(LStatus[pid])
                    set LReq[pid] = 0
                    set LStatus[pid] = 0
                    set LDoc[pid] = N_DocNew()
                    set LCursor[pid] = 0
                    set LPhase[pid] = 5
                    if LDoc[pid] == 0 then
                        call LocalSaveFinal(pid, 2, 12, -1)
                    endif
                endif
            elseif st != 0 then
                // 조회 자체 실패: 같은 요청 ID로 저장 재시도(멱등)
                call N_Release(LStatus[pid])
                set LStatus[pid] = 0
                set id = N_Retry(LReq[pid])
                if id == 0 then
                    call LocalSaveFinal(pid, 2, LFirstErr[pid], -1)
                else
                    call N_Release(LReq[pid])
                    set LReq[pid] = id
                    set LPhase[pid] = 6
                endif
            endif
        endif
    endfunction

    //==========================================================================
    // 동기 경로: 0.05초 타이머
    //==========================================================================
    private function Tick takes nothing returns nothing
        local integer pid = 0
        local integer n
        local integer p
        set Now = Now + 1
        loop
            exitwhen pid >= bj_MAX_PLAYERS
            if Phase[pid] == 1 and Now >= StartTick[pid] then
                set Phase[pid] = 2
                set Deadline[pid] = Now + LOAD_HTTP_TIMEOUT_TICKS
                if GetLocalPlayer() == Player(pid) then
                    set LReq[pid] = N_LoadBegin(pid)
                    if LReq[pid] == 0 then
                        call Send(pid, 0, 0, K_LOAD_READY, 2, 8, -1, "")
                    else
                        set LPhase[pid] = 1
                    endif
                endif
            elseif Phase[pid] == 2 and Now > Deadline[pid] then
                call FinishLoad(pid, ARCANA_STASH_FAILED, false, "로드 응답 시간 초과")
            elseif Phase[pid] == 3 and Now > Deadline[pid] + QLen * 2 then
                // 마지막 진행 뒤 10초 + 현재 대기열 인원 × 2틱 동안 다음 패킷이 없으면 누락(Codex 검토 3)
                call FinishLoad(pid, ARCANA_STASH_FAILED, false, "로드 패킷 누락")
            elseif Phase[pid] == 4 then
                set n = 0
                loop
                    exitwhen ApplyIdx[pid] >= BufN[pid] or n >= APPLY_PER_TICK
                    call StashSave(ApplyStash[pid], LoadStr(Buf, pid, ApplyIdx[pid] * 2), LoadStr(Buf, pid, ApplyIdx[pid] * 2 + 1))
                    set ApplyIdx[pid] = ApplyIdx[pid] + 1
                    set n = n + 1
                endloop
                if ApplyIdx[pid] >= BufN[pid] then
                    set Rev[pid] = LoadRev[pid]
                    call FinishLoad(pid, ARCANA_STASH_LOADED, true, "로드 성공")
                endif
            elseif (Phase[pid] == 5 or Phase[pid] == 6) and Now > Deadline[pid] then
                call FinishSave(pid, ARCANA_STASH_RESULT_UNKNOWN, false, "저장 응답 시간 초과(다시 로드 필요)")
            endif
            if (Phase[pid] == 5 or Phase[pid] == 6) and Snap[pid] != 0 and not SnapReady[pid] then
                call SnapCopyStep(pid)
            endif
            if GetLocalPlayer() == Player(pid) and LPhase[pid] != 0 then
                call LocalStep(pid)
            endif
            set pid = pid + 1
        endloop
        // 공용 송신 대기열: 틱마다 맨 앞 플레이어의 다음 패킷 하나. 순서·카운터는 동기, 본문만 소유자가 읽는다.
        if QLen > 0 then
            set p = QPid[QHead]
            if GetLocalPlayer() == Player(p) then
                call Send(p, SentSeq[p], Total[p], K_LOAD_DATA, 1, 0, LoadRev[p], N_Packet(LReq[p], SentSeq[p]))
                if SentSeq[p] + 1 >= Total[p] then
                    call N_Release(LReq[p])
                    set LReq[p] = 0
                    set LPhase[p] = 0
                endif
            endif
            set SentSeq[p] = SentSeq[p] + 1
            if SentSeq[p] >= Total[p] then
                // 다 보낸 플레이어는 대기열에서 뺀다. 목록이 당겨지므로 QHead 는 그대로 두고 범위만 맞춘다.
                call QueueRemove(p)
            else
                set QHead = QHead + 1
            endif
            if QHead >= QLen then
                set QHead = 0
            endif
        endif
    endfunction

    //==========================================================================
    // 공개 함수. 모두 동기 경로(모든 클라이언트)에서 부른다.
    //==========================================================================
    function ArcanaStashNetDownloadUser takes player user, trigger callback returns boolean
        local integer pid = GetPlayerId(user)
        static if not ARCANA_SAVE_BACKEND then
            return false
        endif
        if Phase[pid] != 0 then
            return false
        endif
        set Tag[pid] = Tag[pid] + 1
        set CbLoad[pid] = callback
        set Phase[pid] = 1
        // 로드 시작은 요청 순서대로 0.5초씩 어긋난다(07 D11)
        if NextStagger < Now then
            set NextStagger = Now
        endif
        set StartTick[pid] = NextStagger + 1
        set NextStagger = NextStagger + LOAD_STAGGER_TICKS
        return true
    endfunction

    function ArcanaStashNetUploadUser takes player user, stash whichStash, trigger callback returns boolean
        local integer pid = GetPlayerId(user)
        static if not ARCANA_SAVE_BACKEND then
            return false
        endif
        if Phase[pid] != 0 or (St[pid] != ARCANA_STASH_LOADED and St[pid] != ARCANA_STASH_NEW) or not StashExists(whichStash) then
            return false
        endif
        set Tag[pid] = Tag[pid] + 1
        set CbSave[pid] = callback
        // 스냅숏은 동기 경로에서 만든다(MAX_STASH 일치). 내용 읽기만 소유자 로컬에서 한다.
        set Snap[pid] = StashCopy(whichStash)
        call ArcanaSaveTrace("[ARC-NET] upload pid=" + I2S(pid) + " src=" + I2S(whichStash) + " snap=" + I2S(Snap[pid]) + " st=" + I2S(St[pid]) + " rev=" + I2S(Rev[pid]) + " now=" + I2S(Now))
        call FlushChildHashtable(SnapTab, pid)
        set SnapN[pid] = 0
        set SnapCur[pid] = 0
        set SnapReady[pid] = false
        set Phase[pid] = 5
        set Deadline[pid] = Now + SAVE_TIMEOUT_TICKS
        if GetLocalPlayer() == user then
            set LDoc[pid] = N_DocNew()
            set LCursor[pid] = 0
            set LTries[pid] = 0
            set LPhase[pid] = 5
            if LDoc[pid] == 0 then
                call LocalSaveFinal(pid, 2, 12, -1)
            endif
        endif
        return true
    endfunction

    // 정확 대조(Codex 검토 5). s 의 살아 있는 항목을 07 2.4 와 같은 규칙으로 다시 묶어 마지막 로드에서 받은 패킷 원문과 바이트 단위로 비교한다.
    // 반환: 비교한 바이트 수(일치), -1 불일치, -2 비교할 로드 원문 없음. 동기 경로에서 부른다(모든 클라이언트에서 같은 결과).
    function ArcanaStashNetVerifyExact takes integer pid, stash s returns integer
        local integer size
        local integer i = 0
        local integer seq = 0
        local integer count = 0
        local integer bytes = 0
        local string cur = ""
        local string enc
        local string k
        local string v
        if RawN[pid] <= 0 or s == 0 or not StashExists(s) then
            return -2
        endif
        set size = StashSize(s)
        loop
            exitwhen i >= size
            set v = StashValueAt(s, i, null)
            if v != null then
                set k = StashKeyAt(s, i)
                set enc = I2S(StringLength(k)) + ":" + I2S(StringLength(v)) + ":" + k + v
                if StringLength(cur) + StringLength(enc) > ENTRY_ENC_MAX then
                    if seq >= RawN[pid] or LoadStr(Raw, pid, seq) != cur then
                        return -1
                    endif
                    set bytes = bytes + StringLength(cur)
                    set seq = seq + 1
                    set cur = ""
                endif
                set cur = cur + enc
                set count = count + 1
            endif
            set i = i + 1
        endloop
        set cur = cur + "#" + I2S(count)
        if seq != RawN[pid] - 1 or LoadStr(Raw, pid, seq) != cur then
            return -1
        endif
        set k = null
        set v = null
        set enc = null
        return bytes + StringLength(cur)
    endfunction

    function ArcanaStashNetIsReady takes integer pid returns boolean
        return St[pid] == ARCANA_STASH_LOADED or St[pid] == ARCANA_STASH_NEW
    endfunction
    function ArcanaStashNetGetState takes integer pid returns integer
        return St[pid]
    endfunction
    function ArcanaStashNetGetRevision takes integer pid returns integer
        return Rev[pid]
    endfunction
    function ArcanaStashNetGetLoadInfo takes integer pid returns string
        return LoadInfo[pid]
    endfunction
    // 09 2.1: 마지막 로드의 서버 날짜(KST, YYYYMMDD 정수). LoadInfo 끝의 ";day=" + 8자리를 읽고, 없거나 형식이 틀리면 0.
    // LoadInfo 는 동기화된 값이라 모든 클라이언트에서 같은 값을 돌려준다.
    function ArcanaStashNetGetServerDay takes integer pid returns integer
        local string s = LoadInfo[pid]
        local integer n = StringLength(s)
        local string d
        if n < 13 or SubString(s, n - 13, n - 8) != ";day=" then
            return 0
        endif
        set d = SubString(s, n - 8, n)
        if not Digits8(d) then
            return 0
        endif
        return S2I(d)
    endfunction
    function ArcanaStashNetIsBusy takes integer pid returns boolean
        return Phase[pid] != 0
    endfunction
    function ArcanaStashNetQueueLength takes nothing returns integer
        return QLen
    endfunction
    function ArcanaStashNetGetPlayer takes nothing returns player
        return EV_USER
    endfunction
    function ArcanaStashNetGetResult takes nothing returns boolean
        return EV_RESULT
    endfunction
    function ArcanaStashNetGetFinished takes nothing returns boolean
        return EV_FINISHED
    endfunction
    function ArcanaStashNetGetMessage takes nothing returns string
        return EV_MESSAGE
    endfunction
    function ArcanaStashNetGetMaximum takes nothing returns integer
        return EV_MAX
    endfunction
    function ArcanaStashNetGetProgress takes nothing returns integer
        return EV_PROGRESS
    endfunction
    function ArcanaStashNetGetStash takes nothing returns stash
        return EV_STASH
    endfunction

    private function onInit takes nothing returns nothing
        local trigger t
        static if ARCANA_SAVE_BACKEND then
            set ARCANA_LOGIN_OK = CreateTrigger()
            set ARCANA_PICK_SHOW = CreateTrigger()
            set GameNonce = GetRandomInt(1, 999999)
            set t = CreateTrigger()
            call DzTriggerRegisterSyncData(t, PREFIX, false)
            call TriggerAddAction(t, function OnSync)
            call TimerStart(CreateTimer(), TICK, true, function Tick)
        endif
        set t = null
    endfunction

endlibrary
