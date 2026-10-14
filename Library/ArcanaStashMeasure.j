// 단계 5-0 측정용으로 자기 Stash의 항목 수·바이트 수·최대 항목 크기를 원문 없이 로컬 화면에만 표시한다.
library ArcanaStashMeasure initializer onInit requires PlayerSave, Stash

    // 읽기 전용 진단이다. Stash에 쓰거나 저장·업로드하지 않으며 키·값 원문을 출력하지 않는다.
    // 각 클라이언트의 PLAYER_DATA 사본은 로컬 블록 쓰기 때문에 다를 수 있으므로 소유자 화면의 값을 기준으로 삼는다.

    globals
        // 06 최종설계 10.3절 항목 묶음 형식 추정용. 머리글을 뺀 패킷 본문 한도다.
        private constant integer PACKET_PAYLOAD = 860
    endglobals

    private function YesNo takes boolean b returns string
        if b then
            return "예"
        endif
        return "아니오"
    endfunction

    private function Say takes string msg returns nothing
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 30.00, "|cff66ccff[저장측정]|r " + msg)
    endfunction

    // 10.3절 형식 <키 바이트 수>:<값 바이트 수>:<키><값> 의 길이
    private function EncodedBytes takes integer kb, integer vb returns integer
        return StringLength(I2S(kb)) + 1 + StringLength(I2S(vb)) + 1 + kb + vb
    endfunction

    private function HasSlash takes string s returns boolean
        local integer len = StringLength(s)
        local integer i = 0
        loop
            exitwhen i >= len
            if SubString(s, i, i + 1) == "/" then
                return true
            endif
            set i = i + 1
        endloop
        return false
    endfunction

    // 로컬 클라이언트에서만 호출한다. 게임 상태를 바꾸지 않는다.
    private function Measure takes integer pid returns nothing
        local stash s = PLAYER_DATA[pid]
        local integer size
        local integer i = 0
        local string k
        local string v
        local integer kb
        local integer vb
        local integer e
        local integer live = 0
        local integer empty = 0
        local integer keyBytes = 0
        local integer valueBytes = 0
        local integer jnBytes = 0
        local integer maxKey = 0
        local integer maxValue = 0
        local integer maxEntry = 0
        local integer maxEntryIndex = -1
        local integer slashKeys = 0
        local integer packets = 0
        local integer packetUsed = 0
        local integer tooBig = 0
        if not StashExists(s) then
            call Say("p" + I2S(pid) + " Stash 없음(로드 전 또는 실패). READY=" + YesNo(PLAYER_DATA_SERVER_READY[pid]))
            return
        endif
        set size = StashSize(s)
        loop
            exitwhen i >= size
            set k = StashKeyAt(s, i)
            set v = StashValueAt(s, i, null)
            if k == null or v == null then
                set empty = empty + 1
            else
                set live = live + 1
                set kb = StringLength(k)
                set vb = StringLength(v)
                set keyBytes = keyBytes + kb
                set valueBytes = valueBytes + vb
                // 현재 JNStashNet 업로드 형식 stash.<i> = 키/값 의 본문 길이
                set jnBytes = jnBytes + kb + 1 + vb
                if kb > maxKey then
                    set maxKey = kb
                endif
                if vb > maxValue then
                    set maxValue = vb
                endif
                set e = EncodedBytes(kb, vb)
                if e > maxEntry then
                    set maxEntry = e
                    set maxEntryIndex = i
                endif
                if HasSlash(k) then
                    set slashKeys = slashKeys + 1
                endif
                // 항목 경계에서만 자르는 탐욕 채우기로 패킷 수를 추정한다.
                if e > PACKET_PAYLOAD then
                    set tooBig = tooBig + 1
                elseif packets == 0 or packetUsed + e > PACKET_PAYLOAD then
                    set packets = packets + 1
                    set packetUsed = e
                else
                    set packetUsed = packetUsed + e
                endif
            endif
            set i = i + 1
        endloop
        call Say("p" + I2S(pid) + " READY=" + YesNo(PLAYER_DATA_SERVER_READY[pid]) + " 슬롯=" + I2S(size) + " 유효=" + I2S(live) + " 빈칸=" + I2S(empty))
        call Say("바이트 키합=" + I2S(keyBytes) + " 값합=" + I2S(valueBytes) + " 키+값=" + I2S(keyBytes + valueBytes) + " JN형식=" + I2S(jnBytes))
        call Say("최대 키=" + I2S(maxKey) + "B 값=" + I2S(maxValue) + "B 항목(길이접두)=" + I2S(maxEntry) + "B @index" + I2S(maxEntryIndex))
        call Say("추정 패킷(" + I2S(PACKET_PAYLOAD) + "B)=" + I2S(packets) + " 패킷초과항목=" + I2S(tooBig) + " '/'포함키=" + I2S(slashKeys))
        set k = null
        set v = null
    endfunction

    // 06 최종설계 2.3절 가정 확인. JASS 문자열 길이가 UTF-8 바이트 단위인지 본다.
    private function ByteCheck takes nothing returns nothing
        call Say("StringLength 가=" + I2S(StringLength("가")) + " (바이트 단위면 3), 한글A=" + I2S(StringLength("한글A")) + " (바이트 단위면 7), SubString(한글A,3,6)=[" + SubString("한글A", 3, 6) + "] (바이트 단위면 글)")
    endfunction

    private function StartsWith takes string msg, string cmd returns boolean
        return SubString(msg, 0, StringLength(cmd)) == cmd
    endfunction

    private function OnChat takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local string msg = GetEventPlayerChatString()
        local integer target = GetPlayerId(p)
        if p != GetLocalPlayer() then
            set p = null
            return
        endif
        if msg == "-저장측정" or msg == "-svmeasure" then
            call Measure(target)
        elseif StartsWith(msg, "-저장측정 ") then
            // 다른 플레이어 번호를 주면 이 클라이언트가 가진 그 플레이어 사본을 측정한다.
            set target = S2I(SubString(msg, StringLength("-저장측정 "), StringLength(msg)))
            if target >= 0 and target < bj_MAX_PLAYERS then
                call Measure(target)
            endif
        elseif msg == "-바이트확인" or msg == "-svbytes" then
            call ByteCheck()
        endif
        set p = null
    endfunction

    private function onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer i = 0
        loop
            exitwhen i == bj_MAX_PLAYERS
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-저장측정", false)
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-svmeasure", true)
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-바이트확인", true)
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-svbytes", true)
            set i = i + 1
        endloop
        call TriggerAddAction(t, function OnChat)
        set t = null
    endfunction

endlibrary
