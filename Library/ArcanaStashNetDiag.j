// ArcanaStashNet(api=3) 시험용 채팅 명령. 합성 Stash 저장·로드, 항목별 정확 대조, 클라이언트 간 비교 값(MAX_STASH, 대기열)을 모든 화면에 표시한다.
library ArcanaStashNetDiag initializer onInit requires ArcanaStashNet, ArcanaSaveNet3Natives, Stash

    // 모든 명령은 채팅 이벤트(모든 클라이언트에서 같은 순서로 실행)에서 동기 경로로 처리한다.
    // Stash 생성·수정은 모든 클라이언트에서 같이 일어나므로 MaxStashCount()가 클라이언트마다 같아야 한다.
    // 합성 데이터는 plugin\harness\synthetic_max_stash.json(make_synthetic_stash.py)과 같은 키·값·순서다(07 2.8). 운영 데이터가 아니다.

    globals
        private constant string ITEM = "ID999;강화99;품질100;특성99;각인99;각인수치99;각인99;각인수치99;각인P99;각인P수치99;잠금1;중첩수999;트라이99;장기99;"
        private constant string NUM = "9999999999"
        private stash array Work
        private stash array Loaded
        private string array LastDeleted
        private trigger LoadCb = CreateTrigger()
        private trigger SaveCb = CreateTrigger()
    endglobals

    private function YesNo takes boolean b returns string
        if b then
            return "예"
        endif
        return "아니오"
    endfunction

    private function Say takes string msg returns nothing
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 20.00, "|cff66ff99[A3]|r " + msg)
    endfunction

    private function StateName takes integer s returns string
        if s == ARCANA_STASH_LOADED then
            return "로드됨"
        elseif s == ARCANA_STASH_NEW then
            return "신규"
        elseif s == ARCANA_STASH_FAILED then
            return "로드 실패(저장 차단)"
        elseif s == ARCANA_STASH_CONFLICT then
            return "충돌(다시 로드 필요)"
        elseif s == ARCANA_STASH_LEASE_LOST then
            return "임대 상실(저장 차단)"
        elseif s == ARCANA_STASH_RESULT_UNKNOWN then
            return "저장 결과 불명(다시 로드 필요)"
        endif
        return "미확인"
    endfunction

    // 참고용 해시. StringHash 는 대소문자·슬래시를 구분하지 않아 정확 일치의 증거가 아니다. 정확 대조는 -a3비교 / -a3원문.
    private function HintHash takes stash s returns integer
        local integer size
        local integer i = 0
        local integer h = 7
        local string v
        if s == 0 or not StashExists(s) then
            return -1
        endif
        set size = StashSize(s)
        loop
            exitwhen i >= size
            set v = StashValueAt(s, i, null)
            if v != null then
                set h = ModuloInteger(h * 31 + ModuloInteger(StringHash(StashKeyAt(s, i) + "=" + v), 1000003), 1000003)
            endif
            set i = i + 1
        endloop
        set v = null
        return h
    endfunction

    private function Count takes stash s returns integer
        if s == 0 or not StashExists(s) then
            return -1
        endif
        return StashRemaining(s)
    endfunction

    private function Pad6 takes integer i returns string
        local string s = I2S(i)
        loop
            exitwhen StringLength(s) >= 6
            set s = "0" + s
        endloop
        return s
    endfunction

    // make_synthetic_stash.py build() 와 같은 순서·내용(998항목)
    private function Synth takes integer pid returns nothing
        local stash s
        local integer h = 1
        local integer i
        if Work[pid] != 0 then
            call DestroyStash(Work[pid])
        endif
        set s = CreateStash()
        loop
            exitwhen h > 5
            set i = 0
            loop
                exitwhen i >= 100
                call StashSave(s, "영웅" + I2S(h) + ".아이템" + I2S(i), ITEM)
                set i = i + 1
            endloop
            set i = 0
            loop
                exitwhen i >= 10
                call StashSave(s, "영웅" + I2S(h) + ".E" + I2S(i), ITEM)
                set i = i + 1
            endloop
            call StashSave(s, "영웅" + I2S(h), NUM)
            call StashSave(s, "영웅" + I2S(h) + ".skin", NUM)
            call StashSave(s, "영웅" + I2S(h) + ".logins", NUM)
            call StashSave(s, "영웅" + I2S(h) + ".Q", NUM)
            call StashSave(s, "영웅" + I2S(h) + ".QB", NUM)
            call StashSave(s, "영웅" + I2S(h) + ".시험원정.보관재료", NUM)
            call StashSave(s, "영웅" + I2S(h) + ".시험원정.전투승리", NUM)
            call StashSave(s, "영웅" + I2S(h) + ".시험원정.완주", NUM)
            call StashSave(s, "슬롯" + I2S(h) + ".TQuest", NUM)
            set h = h + 1
        endloop
        set i = 0
        loop
            exitwhen i >= 100
            call StashSave(s, "창고" + I2S(i), ITEM)
            set i = i + 1
        endloop
        call StashSave(s, "골드", NUM)
        call StashSave(s, "BigWheelCount", NUM)
        call StashSave(s, "Totaldaily", NUM)
        set i = 0
        loop
            exitwhen i >= 100
            call StashSave(s, "원정.카드도감.가나다라마바사아자차카타파하" + Pad6(i), "1")
            set i = i + 1
        endloop
        set i = 0
        loop
            exitwhen i >= 100
            call StashSave(s, "원정.머리도감.가나다라마바사아자차카타파하" + Pad6(i), "1")
            set i = i + 1
        endloop
        set i = 0
        loop
            exitwhen i >= 100
            call StashSave(s, "원정.카드각성도감.가나다라마바사아자차카타파하" + Pad6(i), "1")
            set i = i + 1
        endloop
        set Work[pid] = s
        call Say(GetPlayerName(Player(pid)) + " 합성 Stash(synthetic_max_stash.json 동일) " + I2S(Count(s)) + "항목. MaxStash=" + I2S(MaxStashCount()))
    endfunction

    // 정확 대조: a 의 살아 있는 모든 항목이 b 에 같은 값으로 있고 개수가 같으며, 마지막으로 지운 키가 b 에 없는지. 결과 문자열.
    private function Compare takes stash a, stash b, string deleted returns string
        local integer size
        local integer i = 0
        local integer checked = 0
        local string k
        local string v
        if a == 0 or b == 0 or not StashExists(a) or not StashExists(b) then
            return "비교 불가(Stash 없음)"
        endif
        set size = StashSize(a)
        loop
            exitwhen i >= size
            set v = StashValueAt(a, i, null)
            if v != null then
                set k = StashKeyAt(a, i)
                if StashLoad(b, k, null) != v then
                    return "불일치 index" + I2S(i) + " 키바이트=" + I2S(StringLength(k))
                endif
                set checked = checked + 1
            endif
            set i = i + 1
        endloop
        if checked != StashRemaining(b) then
            return "불일치 항목 수 작업=" + I2S(checked) + " 로드=" + I2S(StashRemaining(b))
        endif
        if deleted != null and deleted != "" and StashContains(b, deleted) then
            return "불일치 삭제한 키가 로드에 있음"
        endif
        set k = null
        set v = null
        return "완전 일치 " + I2S(checked) + "항목"
    endfunction

    private function OnLoad takes nothing returns nothing
        local player p = ArcanaStashNetGetPlayer()
        local integer pid = GetPlayerId(p)
        if ArcanaStashNetGetResult() then
            if Loaded[pid] != 0 then
                call DestroyStash(Loaded[pid])
            endif
            set Loaded[pid] = ArcanaStashNetGetStash()
        endif
        call Say(GetPlayerName(p) + " 로드 " + ArcanaStashNetGetMessage() + " 상태=" + StateName(ArcanaStashNetGetState(pid)) + " rev=" + I2S(ArcanaStashNetGetRevision(pid)) + " 항목=" + I2S(Count(Loaded[pid])) + " DLL=" + ArcanaStashNetGetLoadInfo(pid))
        set p = null
    endfunction

    private function OnSave takes nothing returns nothing
        local player p = ArcanaStashNetGetPlayer()
        local integer pid = GetPlayerId(p)
        call Say(GetPlayerName(p) + " 저장 " + ArcanaStashNetGetMessage() + " 상태=" + StateName(ArcanaStashNetGetState(pid)) + " rev=" + I2S(ArcanaStashNetGetRevision(pid)) + " MaxStash=" + I2S(MaxStashCount()))
        set p = null
    endfunction

    private function ShowDiag takes integer pid returns nothing
        call Say("p" + I2S(pid) + " " + StateName(ArcanaStashNetGetState(pid)) + " rev=" + I2S(ArcanaStashNetGetRevision(pid)) + " 바쁨=" + YesNo(ArcanaStashNetIsBusy(pid)) + " 로드항목=" + I2S(Count(Loaded[pid])) + " 작업항목=" + I2S(Count(Work[pid])) + " 참고해시 로드/작업=" + I2S(HintHash(Loaded[pid])) + "/" + I2S(HintHash(Work[pid])))
        call Say("공통 MaxStash=" + I2S(MaxStashCount()) + " AliveStash=" + I2S(AliveStashCount()) + " 대기열=" + I2S(ArcanaStashNetQueueLength()) + " DLL=" + ArcanaSaveDllVersion() + " 로드정보=" + ArcanaStashNetGetLoadInfo(pid))
    endfunction

    private function StartsWith takes string msg, string cmd returns boolean
        return SubString(msg, 0, StringLength(cmd)) == cmd
    endfunction

    private function Arg takes string msg, string cmd returns string
        return SubString(msg, StringLength(cmd), StringLength(msg))
    endfunction

    private function OnChat takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pid = GetPlayerId(p)
        local string msg = GetEventPlayerChatString()
        local integer target = pid
        local integer r
        if msg == "-a3로드" or msg == "-a3load" then
            if not ArcanaStashNetDownloadUser(p, LoadCb) then
                call Say(GetPlayerName(p) + " 로드 거부(진행 중 작업 있음)")
            endif
        elseif msg == "-a3합성" or msg == "-a3synth" then
            call Synth(pid)
        elseif msg == "-a3저장" or msg == "-a3save" then
            if Work[pid] == 0 then
                // 작업 Stash 가 없으면 로드한 것을 복사해 저장한다
                if Loaded[pid] != 0 then
                    set Work[pid] = StashCopy(Loaded[pid])
                else
                    set Work[pid] = CreateStash()
                endif
            endif
            if not ArcanaStashNetUploadUser(p, Work[pid], SaveCb) then
                call Say(GetPlayerName(p) + " 저장 거부: 상태 " + StateName(ArcanaStashNetGetState(pid)) + ", 바쁨=" + YesNo(ArcanaStashNetIsBusy(pid)) + " (로드 성공 또는 신규일 때만 저장)")
            endif
        elseif StartsWith(msg, "-a3삭제 ") or StartsWith(msg, "-a3del ") then
            if Work[pid] != 0 then
                if StartsWith(msg, "-a3삭제 ") then
                    set LastDeleted[pid] = Arg(msg, "-a3삭제 ")
                else
                    set LastDeleted[pid] = Arg(msg, "-a3del ")
                endif
                call StashRemove(Work[pid], LastDeleted[pid])
                call Say(GetPlayerName(p) + " 작업 Stash 항목 삭제. 남은 항목=" + I2S(Count(Work[pid])))
            endif
        elseif msg == "-a3비교" or msg == "-a3cmp" then
            // 작업 Stash(저장한 것)와 로드한 Stash 를 항목별로 정확히 대조
            call Say("p" + I2S(pid) + " 작업↔로드 " + Compare(Work[pid], Loaded[pid], LastDeleted[pid]))
        elseif msg == "-a3원문" or msg == "-a3raw" then
            // 로드 Stash 를 07 2.4 규칙으로 다시 묶어 받은 패킷 원문과 바이트 단위 대조
            set r = ArcanaStashNetVerifyExact(pid, Loaded[pid])
            if r >= 0 then
                call Say("p" + I2S(pid) + " 로드↔받은 패킷 원문 완전 일치 " + I2S(r) + "바이트")
            elseif r == -2 then
                call Say("p" + I2S(pid) + " 받은 패킷 원문 없음(신규 또는 로드 전)")
            else
                call Say("p" + I2S(pid) + " |cffff4040로드↔받은 패킷 원문 불일치|r")
            endif
        elseif msg == "-a3검증" or msg == "-a3diag" then
            call ShowDiag(pid)
        elseif StartsWith(msg, "-a3검증 ") or StartsWith(msg, "-a3diag ") then
            if StartsWith(msg, "-a3검증 ") then
                set target = S2I(Arg(msg, "-a3검증 "))
            else
                set target = S2I(Arg(msg, "-a3diag "))
            endif
            if target >= 0 and target < bj_MAX_PLAYERS then
                call ShowDiag(target)
            endif
        endif
        set p = null
    endfunction

    private function onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer i = 0
        loop
            exitwhen i == bj_MAX_PLAYERS
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-a3", false)
            set i = i + 1
        endloop
        call TriggerAddAction(t, function OnChat)
        call TriggerAddAction(LoadCb, function OnLoad)
        call TriggerAddAction(SaveCb, function OnSave)
        set t = null
    endfunction

endlibrary
