// 자체 저장 서버 시험용 ArcanaNet native를 채팅 명령으로 호출하고 결과를 동기화해 모든 플레이어에게 표시한다.
library ArcanaSaveNetTest initializer onInit requires DzAPISync

    // Arcana.SaveNet.dll(api=2)이 등록하는 native다. DLL이 없는 클라이언트에서는 이 선언 때문에 맵 스크립트가 실패하므로 시험 맵에만 Import한다.
    native ArcanaNetVersion takes nothing returns string
    native ArcanaNetBegin takes string op, string key, string value returns integer
    native ArcanaNetPoll takes integer id returns integer
    native ArcanaNetResult takes integer id returns string
    native ArcanaNetError takes integer id returns integer
    native ArcanaNetRevision takes integer id returns integer
    native ArcanaNetRequestId takes integer id returns string
    native ArcanaNetRelease takes integer id returns integer
    native ArcanaNetRetry takes integer id returns integer
    native ArcanaNetResultParts takes integer id returns integer
    native ArcanaNetResultPart takes integer id, integer index returns string

    globals
        private constant string KEY_PREFIX = "smoke.p"
        private constant string API_TAG = "api=2"
        private constant string SYNC_PREFIX = "ASNSYNC"
        private constant real POLL_INTERVAL = 0.10
        // DLL 시간 제한(기본 10초)보다 길게 둔다. 이 값을 넘기면 맵 쪽에서 요청을 해제한다.
        private constant real MAP_TIMEOUT = 15.00
        // 분할 패킷이 이 주기 수(0.1초 × 100 = 10초) 안에 모두 도착하지 않으면 결과를 버린다. 실수 누적 오차를 피하려고 정수로 센다.
        private constant integer ASSEMBLY_TIMEOUT_TICKS = 100
        private constant integer PAYLOAD_FIELD = 9
        // 저장 결과 패킷에 값을 그대로 싣기 때문에 동기화 한도(998바이트) 안으로 제한한다.
        private constant integer MAX_SAVE_BYTES = 800

        // 서버 상태. 동기화 콜백에서만 바뀌므로 모든 클라이언트에서 같다.
        // 0 미확인, 1 로드됨, 2 신규(서버에 값 없음), 3 로드 실패, 4 revision 충돌(다시 로드 필요)
        private integer array SrvState
        private integer array SrvRev
        private string array SrvValue

        // 분할 패킷 조립 상태(동기화 콜백과 동기 타이머에서만 바뀐다).
        private hashtable Parts = InitHashtable()
        private integer array AsmTag
        private integer array AsmTotal
        private integer array AsmGot
        private integer array AsmKind
        // 첫 조각의 머리글. 같은 tag의 모든 조각이 이 값과 같아야 한다.
        private integer array AsmState
        private integer array AsmErr
        private integer array AsmRev
        private integer array AsmAge
        private integer array DoneTag
        private integer GameNonce = 0

        // 아래 값은 요청한 클라이언트에서만 바뀐다. 게임 상태 판단에 쓰지 않는다.
        private boolean LocalApiOk = false
        private integer LocalRequest = 0
        private string LocalOp = ""
        private string LocalValue = ""
        private real LocalElapsed = 0.00
        private integer LocalFailed = 0
        private string LocalFailedOp = ""
        private string LocalFailedValue = ""
        private integer LocalTag = 0
        // 보낼 동기화 패킷 대기열(한 주기에 한 조각씩 보낸다)
        private integer LocalSendId = 0
        private string LocalSendKind = ""
        private integer LocalSendSeq = 0
        private integer LocalSendTotal = 0
        // 마지막 로드에서 DLL이 돌려준 전체 원문(분할·동기화 전). -서버검증 의 송신자 쪽 대조용이다.
        private string LocalLastRaw = ""
        private integer LocalLastRawRev = -1

        // -서버검증 해시 계산용. 표시 제한을 피하려고 값 전체 대신 길이·해시·끝부분만 보여 준다.
        private constant integer DIAG_CHUNK = 32
        private constant integer DIAG_MOD = 1000003
        private constant integer DIAG_TAIL = 24

        private timer PollTimer = CreateTimer()
    endglobals

    private function Say takes string msg returns nothing
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 12.00, "|cff66ccff[서버시험]|r " + msg)
    endfunction

    private function ErrorName takes integer errCode returns string
        if errCode == 1 then
            return "네트워크 연결 실패"
        elseif errCode == 2 then
            return "인증 실패(토큰 확인)"
        elseif errCode == 3 then
            return "저장된 값 없음"
        elseif errCode == 4 then
            return "구버전 저장 거부(revision 충돌)"
        elseif errCode == 5 then
            return "시간 초과"
        elseif errCode == 6 then
            return "서버 HTTP 오류"
        elseif errCode == 7 then
            return "잘못된 요청 인자"
        elseif errCode == 8 then
            return "DLL 설정 파일 없음 또는 오류"
        elseif errCode == 9 then
            return "서버 응답 형식 오류"
        endif
        return "알 수 없는 오류 " + I2S(errCode)
    endfunction

    private function Contains takes string s, string part returns boolean
        local integer len = StringLength(s)
        local integer plen = StringLength(part)
        local integer i = 0
        loop
            exitwhen i + plen > len
            if SubString(s, i, i + plen) == part then
                return true
            endif
            set i = i + 1
        endloop
        return false
    endfunction

    // '|'로 나눈 index번째 필드. PAYLOAD_FIELD는 나머지 전체(본문 안의 '|' 포함)를 돌려준다.
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
                if n == PAYLOAD_FIELD and index == PAYLOAD_FIELD then
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

    private function TestKey takes player p returns string
        return KEY_PREFIX + I2S(GetPlayerId(p))
    endfunction

    private function StateName takes integer s returns string
        if s == 1 then
            return "로드됨"
        elseif s == 2 then
            return "신규"
        elseif s == 3 then
            return "로드 실패(저장 차단)"
        elseif s == 4 then
            return "충돌(다시 로드 필요)"
        endif
        return "미확인(로드 필요)"
    endfunction
    // 동기화 적용. 모든 클라이언트에서 같은 순서로 실행된다.

    private function ApplyResult takes player sender, integer kind, integer state, integer err, integer rev, string payload returns nothing
        local integer pid = GetPlayerId(sender)
        local string who = GetPlayerName(sender)
        if kind == 1 then
            // 로드 결과. 실패를 신규로 취급하지 않는다.
            if state == 1 then
                set SrvState[pid] = 1
                set SrvRev[pid] = rev
                set SrvValue[pid] = payload
                call Say(who + " 로드 성공 rev=" + I2S(rev) + " 값=" + payload)
            elseif state == 2 and err == 3 then
                set SrvState[pid] = 2
                set SrvRev[pid] = 0
                set SrvValue[pid] = ""
                call Say(who + " 서버에 값 없음. 신규로 저장할 수 있습니다.")
            else
                set SrvState[pid] = 3
                call Say(who + " 로드 실패: " + ErrorName(err) + ". 로드가 성공할 때까지 저장을 막습니다.")
            endif
        elseif kind == 2 then
            // 저장 결과
            if state == 1 then
                set SrvState[pid] = 1
                set SrvRev[pid] = rev
                set SrvValue[pid] = payload
                call Say(who + " 저장 확정 rev=" + I2S(rev) + " 값=" + payload)
            elseif state == 2 and err == 4 then
                set SrvState[pid] = 4
                call Say(who + " 저장 거부: 서버 rev=" + I2S(rev) + " 가 더 최신입니다. -서버로드 후 다시 저장하세요.")
            else
                call Say(who + " 저장 결과 불명: " + ErrorName(err) + ". -서버확인 또는 -서버재시도 로 판별하세요.")
            endif
        elseif kind == 3 then
            // 이전 저장 요청의 서버 확정 여부
            if state == 1 and payload == "200" then
                set SrvState[pid] = 1
                set SrvRev[pid] = rev
                call Say(who + " 확인: 이전 저장은 서버에 확정됨 rev=" + I2S(rev))
            elseif state == 1 and payload == "409" then
                set SrvState[pid] = 4
                call Say(who + " 확인: 이전 저장은 revision 충돌로 거부됨. -서버로드 하세요.")
            elseif state == 2 and err == 3 then
                call Say(who + " 확인: 이전 저장은 서버에 도착하지 않았습니다. -서버재시도 로 다시 보낼 수 있습니다.")
            else
                call Say(who + " 확인 실패: " + ErrorName(err))
            endif
        endif
        set who = null
    endfunction

    // 미완성 조립을 버린다. 로드 결과였다면 로드 실패로 두어 저장을 막는다.
    private function AbortAssembly takes integer pid, string reason returns nothing
        call FlushChildHashtable(Parts, pid)
        set DoneTag[pid] = AsmTag[pid]
        set AsmTotal[pid] = 0
        if AsmKind[pid] == 1 then
            set SrvState[pid] = 3
        endif
        call Say(GetPlayerName(Player(pid)) + " " + reason + " 결과를 버렸습니다.")
    endfunction

    private function OnSync takes nothing returns nothing
        local player sender = DzGetTriggerSyncPlayer()
        local integer spid = GetPlayerId(sender)
        local string packet = DzGetTriggerSyncData()
        local integer tag
        local integer seq
        local integer total
        local integer kind
        local integer state
        local integer err
        local integer rev
        local integer i
        local string body
        if S2I(FieldAt(packet, 0)) != GameNonce or S2I(FieldAt(packet, 1)) != spid then
            // 다른 게임·다른 송신자의 패킷은 적용하지 않는다.
            set sender = null
            return
        endif
        set tag = S2I(FieldAt(packet, 2))
        set seq = S2I(FieldAt(packet, 3))
        set total = S2I(FieldAt(packet, 4))
        set kind = S2I(FieldAt(packet, 5))
        set state = S2I(FieldAt(packet, 6))
        set err = S2I(FieldAt(packet, 7))
        set rev = S2I(FieldAt(packet, 8))
        if tag <= DoneTag[spid] or total < 1 or total > 8 or seq < 0 or seq >= total or kind < 1 or kind > 3 then
            set sender = null
            return
        endif
        if AsmTotal[spid] > 0 and tag < AsmTag[spid] then
            // 조립 중인 결과보다 오래된 tag는 늦게 도착한 이전 결과다. 진행 중인 조립을 건드리지 않는다.
            set sender = null
            return
        endif
        if AsmTotal[spid] == 0 or tag > AsmTag[spid] then
            // 더 새 결과가 오면 미완성 이전 조립은 버리고 첫 조각의 머리글을 기준으로 삼는다.
            call FlushChildHashtable(Parts, spid)
            set AsmTag[spid] = tag
            set AsmTotal[spid] = total
            set AsmGot[spid] = 0
            set AsmAge[spid] = 0
            set AsmKind[spid] = kind
            set AsmState[spid] = state
            set AsmErr[spid] = err
            set AsmRev[spid] = rev
        elseif total != AsmTotal[spid] or kind != AsmKind[spid] or state != AsmState[spid] or err != AsmErr[spid] or rev != AsmRev[spid] then
            // 같은 tag인데 머리글이 다르면 어느 조각도 믿을 수 없다.
            call AbortAssembly(spid, "패킷 머리글 불일치로")
            set sender = null
            return
        endif
        if not HaveSavedString(Parts, spid, seq) then
            call SaveStr(Parts, spid, seq, FieldAt(packet, PAYLOAD_FIELD))
            set AsmGot[spid] = AsmGot[spid] + 1
        endif
        if AsmGot[spid] >= AsmTotal[spid] then
            set body = ""
            set i = 0
            loop
                exitwhen i >= AsmTotal[spid]
                set body = body + LoadStr(Parts, spid, i)
                set i = i + 1
            endloop
            call FlushChildHashtable(Parts, spid)
            set DoneTag[spid] = tag
            set AsmTotal[spid] = 0
            call ApplyResult(sender, AsmKind[spid], AsmState[spid], AsmErr[spid], AsmRev[spid], body)
        endif
        set sender = null
    endfunction

    // 동기 타이머에서 호출한다. 조각이 빠진 결과는 시간 제한 뒤 버린다.
    private function AgeAssemblies takes nothing returns nothing
        local integer pid = 0
        loop
            exitwhen pid >= bj_MAX_PLAYERS
            if AsmTotal[pid] > 0 then
                set AsmAge[pid] = AsmAge[pid] + 1
                if AsmAge[pid] >= ASSEMBLY_TIMEOUT_TICKS then
                    call AbortAssembly(pid, "결과 패킷 누락으로")
                endif
            endif
            set pid = pid + 1
        endloop
    endfunction
    // 로컬 요청. 요청한 플레이어의 클라이언트에서만 실행된다.

    private function KindOf takes string op returns integer
        if op == "get" then
            return 1
        elseif op == "status" then
            return 3
        endif
        return 2
    endfunction

    // 완료된 요청 결과를 동기화 대기열에 올린다.
    private function QueueSync takes integer id returns nothing
        set LocalTag = LocalTag + 1
        set LocalSendId = id
        set LocalSendKind = I2S(KindOf(LocalOp))
        set LocalSendSeq = 0
        set LocalSendTotal = 1
        if LocalOp == "get" and ArcanaNetPoll(id) == 1 then
            set LocalSendTotal = ArcanaNetResultParts(id)
            set LocalLastRaw = ArcanaNetResult(id)
            set LocalLastRawRev = ArcanaNetRevision(id)
        endif
    endfunction

    private function SendNextPart takes nothing returns nothing
        local integer id = LocalSendId
        local string payload = ""
        local integer state = ArcanaNetPoll(id)
        if LocalSendKind == "1" and state == 1 then
            set payload = ArcanaNetResultPart(id, LocalSendSeq)
        elseif LocalSendKind == "2" and state == 1 then
            set payload = LocalValue
        elseif LocalSendKind == "3" and state == 1 then
            set payload = ArcanaNetResult(id)
        endif
        call DzSyncData(SYNC_PREFIX, I2S(GameNonce) + "|" + I2S(GetPlayerId(GetLocalPlayer())) + "|" + I2S(LocalTag) + "|" + I2S(LocalSendSeq) + "|" + I2S(LocalSendTotal) + "|" + LocalSendKind + "|" + I2S(state) + "|" + I2S(ArcanaNetError(id)) + "|" + I2S(ArcanaNetRevision(id)) + "|" + payload)
        set LocalSendSeq = LocalSendSeq + 1
        if LocalSendSeq >= LocalSendTotal then
            if LocalFailed != id then
                call ArcanaNetRelease(id)
            endif
            set LocalSendId = 0
        endif
    endfunction

    private function IsRetryable takes integer state, integer errCode returns boolean
        return state == 3 or (state == 2 and (errCode == 1 or errCode == 5 or errCode == 6 or errCode == 9))
    endfunction

    private function FinishLocal takes integer id, integer state returns nothing
        if (LocalOp == "get" or Contains(LocalOp, "put")) and IsRetryable(state, ArcanaNetError(id)) then
            // 재시도·상태 확인용으로 요청을 남긴다.
            if LocalFailed != 0 then
                call ArcanaNetRelease(LocalFailed)
            endif
            set LocalFailed = id
            set LocalFailedOp = LocalOp
            set LocalFailedValue = LocalValue
            call Say("재시도 가능: -서버재시도 (같은 요청 ID) 또는 -서버확인 (저장 확정 여부)")
        endif
        call Say("소요 " + R2SW(LocalElapsed, 1, 1) + "초 rid=" + ArcanaNetRequestId(id))
        call QueueSync(id)
        set LocalRequest = 0
    endfunction

    private function StartLocal takes string op, string key, string value returns nothing
        if not LocalApiOk then
            call Say("ArcanaSaveNet DLL api=2 가 필요합니다. 현재: " + ArcanaNetVersion())
            return
        endif
        if LocalRequest != 0 or LocalSendId != 0 then
            call Say("이전 요청을 처리하는 중입니다.")
            return
        endif
        set LocalRequest = ArcanaNetBegin(op, key, value)
        set LocalOp = op
        set LocalValue = value
        set LocalElapsed = 0.00
        if LocalRequest == 0 then
            call Say("요청 표가 가득 찼습니다. 잠시 뒤 다시 시도하세요.")
            return
        endif
        call Say("요청 시작 " + op + " rid=" + ArcanaNetRequestId(LocalRequest))
    endfunction

    private function RetryLocal takes nothing returns nothing
        local integer id
        if LocalFailed == 0 then
            call Say("재시도할 요청이 없습니다.")
            return
        endif
        if LocalRequest != 0 or LocalSendId != 0 then
            call Say("이전 요청을 처리하는 중입니다.")
            return
        endif
        set id = ArcanaNetRetry(LocalFailed)
        if id == 0 then
            call Say("재시도할 수 없는 요청입니다.")
            return
        endif
        call Say("같은 요청 ID로 재시도 rid=" + ArcanaNetRequestId(id))
        call ArcanaNetRelease(LocalFailed)
        set LocalFailed = 0
        set LocalRequest = id
        set LocalOp = LocalFailedOp
        set LocalValue = LocalFailedValue
        set LocalElapsed = 0.00
    endfunction

    // 모든 클라이언트에서 같은 주기로 실행된다. 로컬 요청 처리와 동기 조립 시간 관리를 함께 한다.
    private function OnPoll takes nothing returns nothing
        local integer state
        local integer id = LocalRequest
        call AgeAssemblies()
        if LocalSendId != 0 then
            call SendNextPart()
        endif
        if id == 0 then
            return
        endif
        set state = ArcanaNetPoll(id)
        set LocalElapsed = LocalElapsed + POLL_INTERVAL
        if state == 0 then
            if LocalElapsed >= MAP_TIMEOUT then
                call Say("맵 대기 시간 초과로 요청을 해제합니다. rid=" + ArcanaNetRequestId(id))
                call ArcanaNetRelease(id)
                set LocalRequest = 0
            endif
            return
        endif
        if state == 4 then
            call Say("요청 ID를 찾을 수 없습니다. 맵 재시작으로 정리된 요청일 수 있습니다.")
            set LocalRequest = 0
            return
        endif
        call FinishLocal(id, state)
    endfunction

    private function StartsWith takes string msg, string cmd returns boolean
        return SubString(msg, 0, StringLength(cmd)) == cmd
    endfunction

    // 32바이트 조각마다 StringHash를 구해 위치 가중 합으로 묶는다. 모든 클라이언트에서 같은 문자열이면 같은 값이다.
    // StringHash는 영문 대소문자와 \, / 를 구분하지 않으므로 완전 일치 판정은 송신자 쪽 원문 비교로 보완한다.
    private function Digest takes string s returns integer
        local integer len = StringLength(s)
        local integer i = 0
        local integer h = 7
        loop
            exitwhen i >= len
            set h = ModuloInteger(h * 31 + ModuloInteger(StringHash(SubString(s, i, i + DIAG_CHUNK)), DIAG_MOD), DIAG_MOD)
            set i = i + DIAG_CHUNK
        endloop
        return ModuloInteger(h * 31 + ModuloInteger(len, DIAG_MOD), DIAG_MOD)
    endfunction

    private function Tail takes string s returns string
        local integer len = StringLength(s)
        if len <= DIAG_TAIL then
            return s
        endif
        return SubString(s, len - DIAG_TAIL, len)
    endfunction

    // 모든 클라이언트에서 실행된다. 동기화된 값만 읽고 아무것도 바꾸지 않는다.
    private function ShowDiag takes player requester, integer pid returns nothing
        local string v
        if pid < 0 or pid >= bj_MAX_PLAYERS then
            call Say("검증 대상 번호가 잘못되었습니다. 0부터 시작하는 플레이어 번호를 쓰세요.")
            return
        endif
        set v = SrvValue[pid]
        call Say(GetPlayerName(requester) + " 검증 p" + I2S(pid) + " " + StateName(SrvState[pid]) + " rev=" + I2S(SrvRev[pid]) + " 바이트=" + I2S(StringLength(v)) + " 해시=" + I2S(Digest(v)) + " 끝=[" + Tail(v) + "]")
        if GetLocalPlayer() == Player(pid) and LocalLastRawRev >= 0 then
            // 송신자만 DLL 원문을 갖고 있다. JASS 문자열 비교는 바이트 단위로 정확하다.
            if LocalLastRawRev == SrvRev[pid] then
                if LocalLastRaw == v then
                    call Say("송신자 대조: 마지막 로드 원문(DLL)과 동기화 값 완전 일치 바이트=" + I2S(StringLength(LocalLastRaw)) + " 해시=" + I2S(Digest(LocalLastRaw)))
                else
                    call Say("|cffff4040송신자 대조: 불일치|r 원문 바이트=" + I2S(StringLength(LocalLastRaw)) + " 해시=" + I2S(Digest(LocalLastRaw)))
                endif
            else
                call Say("송신자 대조: 마지막 로드 rev=" + I2S(LocalLastRawRev) + " 와 현재 rev가 달라 비교하지 않습니다. -서버로드 후 다시 검증하세요.")
            endif
        endif
        set v = null
    endfunction

    private function SaveCommand takes player p, string value returns nothing
        local integer pid = GetPlayerId(p)
        if SrvState[pid] != 1 and SrvState[pid] != 2 then
            call Say("저장 불가: 현재 상태 " + StateName(SrvState[pid]) + ". 먼저 -서버로드 가 성공해야 합니다.")
            return
        endif
        if StringLength(value) > MAX_SAVE_BYTES then
            call Say("시험 저장 값은 " + I2S(MAX_SAVE_BYTES) + "바이트 이하만 허용합니다.")
            return
        endif
        // 마지막으로 확인한 revision을 기대값으로 보내 다른 곳의 최신 저장을 덮어쓰지 않는다.
        call StartLocal("put:" + I2S(SrvRev[pid]), TestKey(p), value)
    endfunction

    private function OnChat takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local string msg = GetEventPlayerChatString()
        local integer pid = GetPlayerId(p)
        if msg == "-서버검증" or msg == "-svdiag" then
            call ShowDiag(p, pid)
            set p = null
            return
        elseif StartsWith(msg, "-서버검증 ") then
            call ShowDiag(p, S2I(SubString(msg, StringLength("-서버검증 "), StringLength(msg))))
            set p = null
            return
        elseif StartsWith(msg, "-svdiag ") then
            call ShowDiag(p, S2I(SubString(msg, StringLength("-svdiag "), StringLength(msg))))
            set p = null
            return
        endif
        if p != GetLocalPlayer() then
            set p = null
            return
        endif
        if StartsWith(msg, "-서버저장 ") then
            call SaveCommand(p, SubString(msg, StringLength("-서버저장 "), StringLength(msg)))
        elseif StartsWith(msg, "-svsave ") then
            call SaveCommand(p, SubString(msg, StringLength("-svsave "), StringLength(msg)))
        elseif msg == "-서버로드" or msg == "-svload" then
            call StartLocal("get", TestKey(p), "")
        elseif msg == "-서버구버전저장" or msg == "-svstale" then
            // 일부러 한 단계 낮은 revision을 보내 서버가 409로 거부하는지 본다.
            if SrvRev[pid] < 1 then
                call Say("먼저 한 번 저장해야 시험할 수 있습니다.")
            else
                call StartLocal("put:" + I2S(SrvRev[pid] - 1), TestKey(p), "stale-should-be-rejected")
            endif
        elseif msg == "-서버재시도" or msg == "-svretry" then
            call RetryLocal()
        elseif msg == "-서버확인" or msg == "-svcheck" then
            if LocalFailed == 0 or not Contains(LocalFailedOp, "put") then
                call Say("확인할 실패한 저장 요청이 없습니다.")
            else
                call StartLocal("status", ArcanaNetRequestId(LocalFailed), "")
            endif
        elseif msg == "-서버상태" or msg == "-svstate" then
            call Say("상태 " + StateName(SrvState[pid]) + " rev=" + I2S(SrvRev[pid]) + " 값=" + SrvValue[pid])
        elseif msg == "-서버버전" or msg == "-svver" then
            call Say("DLL " + ArcanaNetVersion())
        endif
        set p = null
    endfunction

    private function CheckApi takes nothing returns nothing
        local string v = ArcanaNetVersion()
        set LocalApiOk = Contains(v, API_TAG)
        if not LocalApiOk then
            call Say("|cffff4040ArcanaSaveNet DLL 버전이 맞지 않습니다.|r 필요 " + API_TAG + ", 현재 " + v + ". 서버 명령을 막습니다.")
        endif
        call DestroyTimer(GetExpiredTimer())
    endfunction

    private function onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer i = 0
        loop
            exitwhen i == bj_MAX_PLAYERS
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-서버", false)
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-sv", false)
            set i = i + 1
        endloop
        call TriggerAddAction(t, function OnChat)
        set t = CreateTrigger()
        call DzTriggerRegisterSyncData(t, SYNC_PREFIX, false)
        call TriggerAddAction(t, function OnSync)
        // 모든 클라이언트에서 같은 난수열을 쓰므로 같은 값이 된다.
        set GameNonce = GetRandomInt(1, 999999)
        call TimerStart(PollTimer, POLL_INTERVAL, true, function OnPoll)
        call TimerStart(CreateTimer(), 1.00, false, function CheckApi)
        set t = null
    endfunction

endlibrary
