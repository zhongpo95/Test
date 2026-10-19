// 세이브 스키마 v2 저장소(10 4절). 플레이어 영구 데이터를 해시테이블에 들고, 로드 항목 해석(Apply)과 저장 문서 만들기(BuildStep)를 한다.
library ArcanaSaveData initializer onInit requires ArcanaSaveNet3Natives, ArcanaSaveItemData

    // 실행 위치 규칙(10 4.4·4.5)
    // - 이 라이브러리에는 ForForce, 핸들을 만드는 native, 난수, GetLocalPlayer, DzSyncData 가 없다. 그래서 읽기·쓰기는 어디서 불러도 동기화를 깨지 않는다.
    // - 수명 함수(Reset/Apply/ApplyEnd)는 어댑터가 동기 경로에서만 부른다. BuildBegin/BuildStep 은 어댑터가 소유자 로컬에서만 부른다(DLL 호출).
    // - 데이터는 소유자 기준이다. 로드 직후에는 모든 클라이언트가 같고, 소유자 로컬 쓰기 뒤에는 다른 클라이언트 사본이 낡을 수 있다.
    //   동기 판정(유닛·아이템 생성, 난수, 동기 분기)에 저장 데이터를 직접 쓰지 않는다.
    // 실행량(JASS 실행 한도): 실게임에서 410자 도감 두 개를 글자마다 비트 5개로 펼치는 해독이 한 스레드에서 멈췄다(2026-10-17 -a5codex).
    // 그래서 도감은 글자 값 하나를 정수 칸 하나로 두고(비트는 읽을 때 계산), 로드 적용은 아이템 문자열을 짧게만 검사하며(전체 문법은 서버가 저장 때 본다),
    // 저장 문서는 영웅·칸 단위의 촘촘한 반복으로 만든다.
    // 서버 참조 코덱: tools\arcana-save\server\save_schema.py. 키 표·값 문법·정해진 순서가 같아야 한다(save_v2_vectors.json).

    globals
        constant integer ARCANA_SAVE_SCHEMA = 2
        constant integer ARCANA_SAVE_ITEM_MAX = 200
        constant integer ARCANA_SAVE_INT_MAX = 2000000000
        // 저장 문서 만들기 한 번에 돌 묶음 수(전체 16 = 한 번에 끝남)
        constant integer ARCANA_SAVE_BUILD_BUDGET = 16
        // 계정 숫자
        constant integer ARCANA_SF_GOLD = 0
        constant integer ARCANA_SF_BIGWHEEL = 1
        constant integer ARCANA_SF_TOTALDAILY = 2
        constant integer ARCANA_SF_DAILYLAST = 3
        // 영웅 숫자(키 순서와 같다: sk lg q qb tq x.st x.win x.done)
        constant integer ARCANA_HF_SKIN = 0
        constant integer ARCANA_HF_LOGINS = 1
        constant integer ARCANA_HF_Q = 2
        constant integer ARCANA_HF_QB = 3
        constant integer ARCANA_HF_TQUEST = 4
        constant integer ARCANA_HF_X_STORE = 5
        constant integer ARCANA_HF_X_WIN = 6
        constant integer ARCANA_HF_X_DONE = 7
        // 도감 종류
        constant integer ARCANA_CODEX_CARD = 0
        constant integer ARCANA_CODEX_AWAKE = 1
        constant integer ARCANA_CODEX_HEAD = 2

        // 부모 키 = pid * 16 + 섹션. 0 계정 숫자, 1 창고, 2 알 수 없는 키, 3~5 도감(카드·각성·머리), 6 스킨
        // 영웅: 부모 키 = 1000 + pid * 16 + N. 자식 0~9 장착, 100~199 인벤토리, 299 손댐(쓴 적 있음), 300 있음, 301~308 숫자
        // 도감 섹션 자식: 10000 + 글자 위치 = 그 글자 값(번호 5k~5k+4 의 비트), -1 = 개수, -2 = 글자 수
        hashtable ARCANA_SAVE_DB = InitHashtable()
        boolean array ARCANA_SAVE_LOADED
        // 소유자 로컬: 마지막 BuildStep 이 넘긴 항목 수(진단), 그 플레이어 문서를 만드는 중인지(만드는 중 쓰기 진단)
        integer ARCANA_SAVE_BUILD_COUNT = 0
        boolean array ARCANA_SAVE_BUILDING

        private constant string B32 = "0123456789ABCDEFGHIJKLMNOPQRSTUV"
        private hashtable CharTab = InitHashtable()
        private string array B32C
        private integer array Pop
        private integer array Pow2
        // 아이템 문법 검사용 글자 분류: StringHash(글자) -> 1~10 숫자 0~9, 11 ';', 12 '|'. ClassChar 로 다시 확인한다(해시 충돌 방지)
        private hashtable ClassTab = InitHashtable()
        private string array ClassChar
        // 문서 키 표(만들 때 문자열 이어 붙이기를 줄인다)
        private string array KeyStore
        private string array KeyInv
        private string array KeyEquip
        private string array KeyHero
        private string array KeyHeroField
        private boolean array SawV
        private boolean array SawDv
        private integer array LoadDv
        // 소유자 로컬 진행 위치(BuildStep, 묶음 번호)와 묶음 스레드 인자
        private integer array BCur
        private integer BArgPid = 0
        private integer BArgDoc = 0
        private integer BArgSec = 0
        private trigger BuildTrig = null
    endglobals

    //==========================================================================
    // 도구
    //==========================================================================
    private function Sec takes integer pid, integer sec returns integer
        return pid * 16 + sec
    endfunction

    private function HeroKey takes integer pid, integer h returns integer
        return 1000 + pid * 16 + h
    endfunction

    // 그 영웅 묶음에 쓴 적이 있다는 표시. 문서 만들기가 비어 있는 영웅 119칸을 건너뛰는 데 쓴다.
    private function Touch takes integer pid, integer h returns nothing
        call SaveBoolean(ARCANA_SAVE_DB, 1000 + pid * 16 + h, 299, true)
    endfunction

    function ArcanaSaveTraceReject takes string what, integer pid, string detail returns nothing
        call ArcanaSaveTrace("[ARC-SAVE] reject " + what + " pid=" + I2S(pid) + " " + detail)
    endfunction

    // 소유자가 문서를 만드는 도중에 쓰기가 있으면 진단 줄을 남긴다(10 11.2). 게임 상태에는 영향이 없다(로그만).
    private function NoteWrite takes integer pid, string what returns nothing
        if ARCANA_SAVE_BUILDING[pid] then
            call ArcanaSaveTrace("[ARC-SAVE] write during build pid=" + I2S(pid) + " " + what)
        endif
    endfunction

    // 한 바이트 분류: 1~10 숫자(값+1), 11 ';', 12 '|', 0 그 밖
    private function Cls takes string c returns integer
        local integer v = LoadInteger(ClassTab, 0, StringHash(c))
        if v != 0 and ClassChar[v] != c then
            return 0
        endif
        return v
    endfunction

    private function IsDigit takes string c returns boolean
        local integer v = Cls(c)
        return v >= 1 and v <= 10
    endfunction

    // base32hex 글자 값, 아니면 -1
    private function CharVal takes string c returns integer
        local integer v = LoadInteger(CharTab, 0, StringHash(c)) - 1
        if v < 0 or B32C[v] != c then
            return -1
        endif
        return v
    endfunction

    // 기존 코드가 넣던 "빈 칸 표시" 네 가지(10 4.2)
    function ArcanaSaveIsEmptyItem takes string v returns boolean
        return v == null or v == "" or v == "0" or v == "없음"
    endfunction

    // 아이템 문자열 문법(10 3.3): (태그 숫자;)+, 첫 태그 ID, 숫자는 0 또는 앞자리 0 없는 10자리 이하, | 없음, 200B 이하. 쓰기(Set) 때 쓴다.
    function ArcanaSaveItemOk takes string s returns boolean
        local integer n = StringLength(s)
        local integer i = 2
        local integer d
        local integer k
        local boolean tag = false
        if n < 4 or n > ARCANA_SAVE_ITEM_MAX or SubString(s, 0, 2) != "ID" or not IsDigit(SubString(s, 2, 3)) then
            // 첫 태그는 정확히 ID(바로 뒤가 숫자)
            return false
        endif
        // 상태: tag 참 = 태그 글자 안, 거짓 = 숫자 자리 시작(첫 태그 ID 뒤)
        set d = -1
        loop
            exitwhen i >= n
            set k = Cls(SubString(s, i, i + 1))
            if k == 12 then
                return false
            elseif k == 11 then
                // ';' 는 숫자 바로 뒤에만
                if d < 0 or i - d > 10 or (i - d > 1 and SubString(s, d, d + 1) == "0") then
                    return false
                endif
                set d = -1
                set tag = true
            elseif k >= 1 then
                if d < 0 then
                    if tag and i > 0 and Cls(SubString(s, i - 1, i)) == 11 then
                        // 태그가 비었다(';' 바로 뒤 숫자)
                        return false
                    endif
                    set d = i
                endif
            else
                // 태그 글자. 숫자 자리 도중이면 틀림(숫자 뒤에는 ';' 만)
                if d >= 0 then
                    return false
                endif
                set tag = true
            endif
            set i = i + 1
        endloop
        // 끝은 ';' 이어야 한다
        return d < 0 and Cls(SubString(s, n - 1, n)) == 11
    endfunction

    // 로드 적용 때의 짧은 검사(길이, ID 로 시작, ';' 로 끝남). 전체 문법은 서버가 저장 때 본다(10 9.2). 실행량 때문에 바이트마다 보지 않는다.
    private function ItemQuick takes string s returns boolean
        local integer n = StringLength(s)
        return n >= 4 and n <= ARCANA_SAVE_ITEM_MAX and SubString(s, 0, 2) == "ID" and SubString(s, n - 1, n) == ";"
    endfunction

    // 정수 문법: 0 또는 앞자리 0 없는 10자리 이하, 2,000,000,000 이하. 아니면 -1
    private function ParseInt takes string s returns integer
        local integer n = StringLength(s)
        local integer i = 0
        if n < 1 or n > 10 then
            return -1
        endif
        loop
            exitwhen i >= n
            if not IsDigit(SubString(s, i, i + 1)) then
                return -1
            endif
            set i = i + 1
        endloop
        if n > 1 and SubString(s, 0, 1) == "0" then
            return -1
        endif
        if n == 10 and (SubString(s, 0, 1) != "1" and (SubString(s, 0, 1) != "2" or SubString(s, 1, 10) != "000000000")) then
            return -1
        endif
        return S2I(s)
    endfunction

    // 칸 번호: 0 또는 앞자리 0 없는 수, max 이하. 아니면 -1
    private function ParseSlot takes string s, integer max returns integer
        local integer v
        if StringLength(s) > 3 then
            return -1
        endif
        set v = ParseInt(s)
        if v > max then
            return -1
        endif
        return v
    endfunction

    //==========================================================================
    // 계정
    //==========================================================================
    function ArcanaSaveGetInt takes integer pid, integer f returns integer
        return LoadInteger(ARCANA_SAVE_DB, Sec(pid, 0), f)
    endfunction

    function ArcanaSaveSetInt takes integer pid, integer f, integer v returns nothing
        if f < 0 or f > ARCANA_SF_DAILYLAST then
            return
        endif
        if v < 0 or v > ARCANA_SAVE_INT_MAX then
            call ArcanaSaveTraceReject("int", pid, "f=" + I2S(f) + " v=" + I2S(v))
            return
        endif
        call NoteWrite(pid, "int")
        if v == 0 then
            call RemoveSavedInteger(ARCANA_SAVE_DB, Sec(pid, 0), f)
        else
            call SaveInteger(ARCANA_SAVE_DB, Sec(pid, 0), f, v)
        endif
    endfunction

    // 결과가 0 미만이거나 상한을 넘으면 거짓이고 바꾸지 않는다.
    function ArcanaSaveAddGold takes integer pid, integer d returns boolean
        local integer cur = ArcanaSaveGetInt(pid, ARCANA_SF_GOLD)
        if (d > 0 and d > ARCANA_SAVE_INT_MAX - cur) or (d < 0 and cur + d < 0) then
            call ArcanaSaveTraceReject("gold", pid, "cur=" + I2S(cur) + " d=" + I2S(d))
            return false
        endif
        call ArcanaSaveSetInt(pid, ARCANA_SF_GOLD, cur + d)
        return true
    endfunction

    function ArcanaSaveSkinOwned takes integer pid, integer hero, integer skin returns boolean
        return LoadBoolean(ARCANA_SAVE_DB, Sec(pid, 6), hero * 100 + skin)
    endfunction

    function ArcanaSaveSetSkinOwned takes integer pid, integer hero, integer skin returns nothing
        local integer p = Sec(pid, 6)
        if hero < 1 or hero > 9 or skin < 1 or skin > 99 or LoadBoolean(ARCANA_SAVE_DB, p, hero * 100 + skin) then
            return
        endif
        call NoteWrite(pid, "skin")
        call SaveBoolean(ARCANA_SAVE_DB, p, hero * 100 + skin, true)
        call SaveInteger(ARCANA_SAVE_DB, p, -1, LoadInteger(ARCANA_SAVE_DB, p, -1) + 1)
    endfunction

    //==========================================================================
    // 영웅
    //==========================================================================
    function ArcanaSaveHeroExists takes integer pid, integer h returns boolean
        return h >= 1 and h <= 9 and LoadBoolean(ARCANA_SAVE_DB, HeroKey(pid, h), 300)
    endfunction

    function ArcanaSaveHeroInt takes integer pid, integer h, integer f returns integer
        if h < 1 or h > 9 then
            return 0
        endif
        return LoadInteger(ARCANA_SAVE_DB, HeroKey(pid, h), 301 + f)
    endfunction

    function ArcanaSaveSetHeroInt takes integer pid, integer h, integer f, integer v returns nothing
        if h < 1 or h > 9 or f < 0 or f > ARCANA_HF_X_DONE then
            return
        endif
        if v < 0 or v > ARCANA_SAVE_INT_MAX then
            call ArcanaSaveTraceReject("hero int", pid, "h=" + I2S(h) + " f=" + I2S(f) + " v=" + I2S(v))
            return
        endif
        call NoteWrite(pid, "hero int")
        call Touch(pid, h)
        if v == 0 then
            call RemoveSavedInteger(ARCANA_SAVE_DB, HeroKey(pid, h), 301 + f)
        else
            call SaveInteger(ARCANA_SAVE_DB, HeroKey(pid, h), 301 + f, v)
        endif
    endfunction

    function ArcanaSaveHeroCreate takes integer pid, integer h, integer skin returns nothing
        if h < 1 or h > 9 then
            return
        endif
        call Touch(pid, h)
        call SaveBoolean(ARCANA_SAVE_DB, HeroKey(pid, h), 300, true)
        call ArcanaSaveSetHeroInt(pid, h, ARCANA_HF_SKIN, skin)
    endfunction

    // 아이템 칸 쓰기 공통: 빈 칸 표시는 지우고, 문법이 틀리면 쓰지 않고 기존 값을 둔다(10 4.2).
    private function PutItem takes integer pid, integer parent, integer child, string itemStr, string where returns nothing
        call NoteWrite(pid, where)
        if ArcanaSaveIsEmptyItem(itemStr) then
            call RemoveSavedString(ARCANA_SAVE_DB, parent, child)
        elseif ArcanaSaveItemOk(itemStr) then
            call SaveStr(ARCANA_SAVE_DB, parent, child, itemStr)
        else
            call ArcanaSaveTraceReject("item", pid, where + " len=" + I2S(StringLength(itemStr)) + " head=" + SubString(itemStr, 0, 40))
        endif
    endfunction

    private function GetItem takes integer parent, integer child, string def returns string
        if HaveSavedString(ARCANA_SAVE_DB, parent, child) then
            return LoadStr(ARCANA_SAVE_DB, parent, child)
        endif
        return def
    endfunction

    function ArcanaSaveEquip takes integer pid, integer h, integer s, string def returns string
        if h < 1 or h > 9 or s < 0 or s > 9 then
            return def
        endif
        return GetItem(HeroKey(pid, h), s, def)
    endfunction

    function ArcanaSaveSetEquip takes integer pid, integer h, integer s, string itemStr returns nothing
        if h >= 1 and h <= 9 and s >= 0 and s <= 9 then
            call Touch(pid, h)
            call PutItem(pid, HeroKey(pid, h), s, itemStr, "h" + I2S(h) + ".e" + I2S(s))
        endif
    endfunction

    function ArcanaSaveInv takes integer pid, integer h, integer s, string def returns string
        if h < 1 or h > 9 or s < 0 or s > 99 then
            return def
        endif
        return GetItem(HeroKey(pid, h), 100 + s, def)
    endfunction

    function ArcanaSaveSetInv takes integer pid, integer h, integer s, string itemStr returns nothing
        if h >= 1 and h <= 9 and s >= 0 and s <= 99 then
            call Touch(pid, h)
            call PutItem(pid, HeroKey(pid, h), 100 + s, itemStr, "h" + I2S(h) + ".i" + I2S(s))
        endif
    endfunction

    //==========================================================================
    // 창고·도감
    //==========================================================================
    function ArcanaSaveStore takes integer pid, integer s, string def returns string
        if s < 0 or s > 99 then
            return def
        endif
        return GetItem(Sec(pid, 1), s, def)
    endfunction

    function ArcanaSaveSetStore takes integer pid, integer s, string itemStr returns nothing
        if s >= 0 and s <= 99 then
            call PutItem(pid, Sec(pid, 1), s, itemStr, "s." + I2S(s))
        endif
    endfunction

    private function CodexChars takes integer kind returns integer
        if kind == ARCANA_CODEX_HEAD then
            return 17
        endif
        return 410
    endfunction

    function ArcanaSaveCodexHas takes integer pid, integer kind, integer id returns boolean
        local integer g = id / 5
        local integer bit
        local integer x
        if id < 0 or kind < 0 or kind > ARCANA_CODEX_HEAD then
            return false
        endif
        set bit = Pow2[id - g * 5]
        set x = LoadInteger(ARCANA_SAVE_DB, Sec(pid, 3 + kind), 10000 + g)
        return x / bit - (x / (bit * 2)) * 2 == 1
    endfunction

    // 머리 도감 동기화 패킷용("1"/"0")
    function ArcanaSaveCodexFlag takes integer pid, integer kind, integer id returns string
        if ArcanaSaveCodexHas(pid, kind, id) then
            return "1"
        endif
        return "0"
    endfunction

    function ArcanaSaveCodexCount takes integer pid, integer kind returns integer
        return LoadInteger(ARCANA_SAVE_DB, Sec(pid, 3 + kind), -1)
    endfunction

    function ArcanaSaveCodexAdd takes integer pid, integer kind, integer id returns nothing
        local integer p = Sec(pid, 3 + kind)
        local integer g = id / 5
        if kind < 0 or kind > ARCANA_CODEX_HEAD or id < 0 or g >= CodexChars(kind) or ArcanaSaveCodexHas(pid, kind, id) then
            return
        endif
        call NoteWrite(pid, "codex")
        call SaveInteger(ARCANA_SAVE_DB, p, 10000 + g, LoadInteger(ARCANA_SAVE_DB, p, 10000 + g) + Pow2[id - g * 5])
        call SaveInteger(ARCANA_SAVE_DB, p, -1, LoadInteger(ARCANA_SAVE_DB, p, -1) + 1)
        if g + 1 > LoadInteger(ARCANA_SAVE_DB, p, -2) then
            call SaveInteger(ARCANA_SAVE_DB, p, -2, g + 1)
        endif
    endfunction

    //==========================================================================
    // 수명(동기 경로 전용, 어댑터만 부른다)
    //==========================================================================
    function ArcanaSaveReset takes integer pid returns nothing
        local integer i = 0
        loop
            exitwhen i > 15
            call FlushChildHashtable(ARCANA_SAVE_DB, Sec(pid, i))
            call FlushChildHashtable(ARCANA_SAVE_DB, HeroKey(pid, i))
            set i = i + 1
        endloop
        set SawV[pid] = false
        set SawDv[pid] = false
        set LoadDv[pid] = 0
        set ARCANA_SAVE_LOADED[pid] = false
    endfunction

    private function KeepUnknown takes integer pid, string k, string v returns boolean
        local integer p = Sec(pid, 2)
        local integer n = LoadInteger(ARCANA_SAVE_DB, p, -1)
        call SaveStr(ARCANA_SAVE_DB, p, n * 2, k)
        call SaveStr(ARCANA_SAVE_DB, p, n * 2 + 1, v)
        call SaveInteger(ARCANA_SAVE_DB, p, -1, n + 1)
        return true
    endfunction

    // 도감 글자열 -> 글자 값 칸. 글자마다 SubString·해시 조회·저장 한 번(410자 약 6천 단계)
    private function ApplyCodex takes integer pid, integer kind, string v returns boolean
        local integer p = Sec(pid, 3 + kind)
        local integer n = StringLength(v)
        local integer k = 0
        local integer x = 0
        local integer count = 0
        if n < 1 or n > CodexChars(kind) or LoadInteger(ARCANA_SAVE_DB, p, -2) != 0 then
            return false
        endif
        loop
            exitwhen k >= n
            set x = CharVal(SubString(v, k, k + 1))
            if x < 0 then
                return false
            endif
            if x > 0 then
                call SaveInteger(ARCANA_SAVE_DB, p, 10000 + k, x)
                set count = count + Pop[x]
            endif
            set k = k + 1
        endloop
        // 끝 글자가 0 이면 문법 오류(서버가 만들지 않는 꼴)
        if x == 0 then
            return false
        endif
        call SaveInteger(ARCANA_SAVE_DB, p, -1, count)
        call SaveInteger(ARCANA_SAVE_DB, p, -2, n)
        return true
    endfunction

    // "N.s,N.s,..." N 1~9, s 1~99
    private function ApplySkins takes integer pid, string v returns boolean
        local integer n = StringLength(v)
        local integer i = 0
        local integer start = 0
        local integer h
        local integer s
        local string part
        if n < 3 or n > 255 then
            return false
        endif
        loop
            exitwhen i > n
            if i == n or SubString(v, i, i + 1) == "," then
                set part = SubString(v, start, i)
                if StringLength(part) < 3 or SubString(part, 1, 2) != "." then
                    return false
                endif
                set h = ParseSlot(SubString(part, 0, 1), 9)
                set s = ParseSlot(SubString(part, 2, StringLength(part)), 99)
                if h < 1 or s < 1 then
                    return false
                endif
                call ArcanaSaveSetSkinOwned(pid, h, s)
                set start = i + 1
            endif
            set i = i + 1
        endloop
        set part = null
        return true
    endfunction

    private function ApplyAccountInt takes integer pid, integer f, string v returns boolean
        local integer x = ParseInt(v)
        if x < 0 then
            return false
        endif
        if f == ARCANA_SF_DAILYLAST and StringLength(v) != 8 then
            return false
        endif
        call ArcanaSaveSetInt(pid, f, x)
        return true
    endfunction

    private function HeroField takes string r returns integer
        if r == "sk" then
            return ARCANA_HF_SKIN
        elseif r == "lg" then
            return ARCANA_HF_LOGINS
        elseif r == "q" then
            return ARCANA_HF_Q
        elseif r == "qb" then
            return ARCANA_HF_QB
        elseif r == "tq" then
            return ARCANA_HF_TQUEST
        elseif r == "x.st" then
            return ARCANA_HF_X_STORE
        elseif r == "x.win" then
            return ARCANA_HF_X_WIN
        elseif r == "x.done" then
            return ARCANA_HF_X_DONE
        endif
        return -1
    endfunction

    private function ApplyHero takes integer pid, string k, string v returns boolean
        local integer n = StringLength(k)
        local integer h = ParseSlot(SubString(k, 1, 2), 9)
        local string r
        local string c
        local integer f
        local integer s
        if h < 1 or (n > 2 and SubString(k, 2, 3) != ".") or n == 3 then
            return KeepUnknown(pid, k, v)
        endif
        call Touch(pid, h)
        if n == 2 then
            if v != "1" then
                return false
            endif
            call SaveBoolean(ARCANA_SAVE_DB, HeroKey(pid, h), 300, true)
            return true
        endif
        set r = SubString(k, 3, n)
        set c = SubString(r, 0, 1)
        if c == "e" or c == "i" then
            if c == "e" and StringLength(r) == 2 then
                set s = ParseSlot(SubString(r, 1, 2), 9)
            elseif c == "i" then
                set s = ParseSlot(SubString(r, 1, StringLength(r)), 99)
            else
                set s = -1
            endif
            if s >= 0 then
                if not ItemQuick(v) then
                    return false
                endif
                if c == "e" then
                    call SaveStr(ARCANA_SAVE_DB, HeroKey(pid, h), s, v)
                else
                    call SaveStr(ARCANA_SAVE_DB, HeroKey(pid, h), 100 + s, v)
                endif
                return true
            endif
        endif
        set f = HeroField(r)
        if f >= 0 then
            set s = ParseInt(v)
            if s < 0 then
                return false
            endif
            call ArcanaSaveSetHeroInt(pid, h, f, s)
            return true
        endif
        return KeepUnknown(pid, k, v)
    endfunction

    // 로드 항목 하나를 해석해 넣는다. 형식 오류면 거짓(어댑터가 로드 실패로 끝낸다). 표에 없는 키는 그대로 보존한다(10 3.5).
    // 자주 나오는 키(영웅·창고)를 먼저 본다(실행량).
    function ArcanaSaveApply takes integer pid, string k, string v returns boolean
        local integer n = StringLength(k)
        local string c0 = SubString(k, 0, 1)
        local integer s
        if v == null then
            return false
        endif
        if not SawV[pid] then
            // v 는 첫 항목이어야 한다
            if k == "v" and v == "2" then
                set SawV[pid] = true
                return true
            endif
            return false
        endif
        if c0 == "h" and n >= 2 then
            return ApplyHero(pid, k, v)
        elseif c0 == "s" and SubString(k, 1, 2) == "." then
            set s = ParseSlot(SubString(k, 2, n), 99)
            if s < 0 then
                return KeepUnknown(pid, k, v)
            endif
            if not ItemQuick(v) then
                return false
            endif
            call SaveStr(ARCANA_SAVE_DB, Sec(pid, 1), s, v)
            return true
        elseif k == "v" then
            return false
        elseif k == "dv" then
            set LoadDv[pid] = ParseInt(v)
            set SawDv[pid] = LoadDv[pid] >= 0
            return SawDv[pid]
        elseif k == "a.g" then
            return ApplyAccountInt(pid, ARCANA_SF_GOLD, v)
        elseif k == "a.bw" then
            return ApplyAccountInt(pid, ARCANA_SF_BIGWHEEL, v)
        elseif k == "a.td" then
            return ApplyAccountInt(pid, ARCANA_SF_TOTALDAILY, v)
        elseif k == "a.dl" then
            return ApplyAccountInt(pid, ARCANA_SF_DAILYLAST, v)
        elseif k == "a.sk" then
            return ApplySkins(pid, v)
        elseif k == "c.c" then
            return ApplyCodex(pid, ARCANA_CODEX_CARD, v)
        elseif k == "c.a" then
            return ApplyCodex(pid, ARCANA_CODEX_AWAKE, v)
        elseif k == "c.h" then
            return ApplyCodex(pid, ARCANA_CODEX_HEAD, v)
        endif
        return KeepUnknown(pid, k, v)
    endfunction

    // 로드 적용 끝. v·dv 가 있었는지 확인한다. 거짓이면 어댑터가 로드 실패로 끝낸다.
    function ArcanaSaveApplyEnd takes integer pid returns boolean
        return SawV[pid] and SawDv[pid]
    endfunction

    function ArcanaSaveLoadedDataVersion takes integer pid returns integer
        return LoadDv[pid]
    endfunction

    //==========================================================================
    // 저장 문서 만들기(소유자 로컬 전용, 어댑터만 부른다)
    //==========================================================================
    private function Emit takes integer doc, string k, string v returns nothing
        call ArcanaDocAdd(doc, k, v)
        set ARCANA_SAVE_BUILD_COUNT = ARCANA_SAVE_BUILD_COUNT + 1
    endfunction

    private function CodexText takes integer pid, integer kind returns string
        local integer p = Sec(pid, 3 + kind)
        local integer n = LoadInteger(ARCANA_SAVE_DB, p, -2)
        local integer k = 0
        local string s = ""
        loop
            exitwhen k >= n
            set s = s + B32C[LoadInteger(ARCANA_SAVE_DB, p, 10000 + k)]
            set k = k + 1
        endloop
        return s
    endfunction

    private function SkinText takes integer pid returns string
        local integer p = Sec(pid, 6)
        local integer h = 1
        local integer s
        local integer left = LoadInteger(ARCANA_SAVE_DB, p, -1)
        local string out = ""
        loop
            exitwhen h > 9 or left <= 0
            set s = 1
            loop
                exitwhen s > 99 or left <= 0
                if LoadBoolean(ARCANA_SAVE_DB, p, h * 100 + s) then
                    if out != "" then
                        set out = out + ","
                    endif
                    set out = out + I2S(h) + "." + I2S(s)
                    set left = left - 1
                endif
                set s = s + 1
            endloop
            set h = h + 1
        endloop
        return out
    endfunction

    private function EmitInt takes integer doc, string k, integer v returns nothing
        if v != 0 then
            call Emit(doc, k, I2S(v))
        endif
    endfunction

    private function EmitStr takes integer doc, string k, string v returns nothing
        if v != null and v != "" then
            call Emit(doc, k, v)
        endif
    endfunction

    // 영웅 h 묶음 전체(있음, 숫자 8, 장착 10, 인벤토리 100)
    private function BuildHero takes integer pid, integer doc, integer h returns nothing
        local integer p = HeroKey(pid, h)
        local string hk = KeyHero[h]
        local integer s = 0
        if not LoadBoolean(ARCANA_SAVE_DB, p, 299) then
            set hk = null
            return
        endif
        if LoadBoolean(ARCANA_SAVE_DB, p, 300) then
            call Emit(doc, hk, "1")
        endif
        loop
            exitwhen s > 7
            call EmitInt(doc, hk + KeyHeroField[s], LoadInteger(ARCANA_SAVE_DB, p, 301 + s))
            set s = s + 1
        endloop
        set s = 0
        loop
            exitwhen s > 9
            if HaveSavedString(ARCANA_SAVE_DB, p, s) then
                call Emit(doc, hk + KeyEquip[s], LoadStr(ARCANA_SAVE_DB, p, s))
            endif
            set s = s + 1
        endloop
        set s = 0
        loop
            exitwhen s > 99
            if HaveSavedString(ARCANA_SAVE_DB, p, 100 + s) then
                call Emit(doc, hk + KeyInv[s], LoadStr(ARCANA_SAVE_DB, p, 100 + s))
            endif
            set s = s + 1
        endloop
        set hk = null
    endfunction

    // 묶음 하나. 0 v·dv·계정 숫자, 1 스킨, 2~4 도감(카드·각성·머리), 5 창고, 6~14 영웅 1~9, 15 알 수 없는 키(정해진 순서 10 3.2)
    private function BuildSection takes integer pid, integer doc, integer sec returns nothing
        local integer s = 0
        local integer p
        if sec == 0 then
            call Emit(doc, "v", I2S(ARCANA_SAVE_SCHEMA))
            call Emit(doc, "dv", I2S(ARCANA_DATA_VERSION))
            call EmitInt(doc, "a.g", ArcanaSaveGetInt(pid, ARCANA_SF_GOLD))
            call EmitInt(doc, "a.bw", ArcanaSaveGetInt(pid, ARCANA_SF_BIGWHEEL))
            call EmitInt(doc, "a.td", ArcanaSaveGetInt(pid, ARCANA_SF_TOTALDAILY))
            call EmitInt(doc, "a.dl", ArcanaSaveGetInt(pid, ARCANA_SF_DAILYLAST))
        elseif sec == 1 then
            call EmitStr(doc, "a.sk", SkinText(pid))
        elseif sec == 2 then
            call EmitStr(doc, "c.c", CodexText(pid, ARCANA_CODEX_CARD))
        elseif sec == 3 then
            call EmitStr(doc, "c.a", CodexText(pid, ARCANA_CODEX_AWAKE))
        elseif sec == 4 then
            call EmitStr(doc, "c.h", CodexText(pid, ARCANA_CODEX_HEAD))
        elseif sec == 5 then
            set p = Sec(pid, 1)
            loop
                exitwhen s > 99
                if HaveSavedString(ARCANA_SAVE_DB, p, s) then
                    call Emit(doc, KeyStore[s], LoadStr(ARCANA_SAVE_DB, p, s))
                endif
                set s = s + 1
            endloop
        elseif sec <= 14 then
            call BuildHero(pid, doc, sec - 5)
        else
            set p = Sec(pid, 2)
            loop
                exitwhen s >= LoadInteger(ARCANA_SAVE_DB, p, -1)
                call Emit(doc, LoadStr(ARCANA_SAVE_DB, p, s * 2), LoadStr(ARCANA_SAVE_DB, p, s * 2 + 1))
                set s = s + 1
            endloop
        endif
    endfunction

    private function BuildSectionCond takes nothing returns boolean
        call BuildSection(BArgPid, BArgDoc, BArgSec)
        return false
    endfunction

    function ArcanaSaveBuildBegin takes integer pid returns nothing
        set BCur[pid] = 0
        set ARCANA_SAVE_BUILD_COUNT = 0
        set ARCANA_SAVE_BUILDING[pid] = true
    endfunction

    // 정해진 순서(10 3.2)대로 항목을 문서에 넘긴다. 묶음(16개)마다 TriggerEvaluate 로 새 스레드에서 돌린다: 실행 한도가 묶음마다 새로 시작하고,
    // 모두 같은 틱 안에서 차례로 끝나므로 만드는 도중의 변경이 섞이지 않는다(10 4.3). budget = 한 번에 돌 묶음 수, 끝나면 참.
    function ArcanaSaveBuildStep takes integer pid, integer doc, integer budget returns boolean
        local integer n = 0
        loop
            exitwhen BCur[pid] >= 16 or n >= budget
            set BArgPid = pid
            set BArgDoc = doc
            set BArgSec = BCur[pid]
            call TriggerEvaluate(BuildTrig)
            set BCur[pid] = BCur[pid] + 1
            set n = n + 1
        endloop
        if BCur[pid] >= 16 then
            set ARCANA_SAVE_BUILDING[pid] = false
            return true
        endif
        return false
    endfunction

    private function onInit takes nothing returns nothing
        local integer i = 0
        loop
            exitwhen i >= 32
            set B32C[i] = SubString(B32, i, i + 1)
            call SaveInteger(CharTab, 0, StringHash(B32C[i]), i + 1)
            set Pop[i] = Pop[i / 2] + i - (i / 2) * 2
            set i = i + 1
        endloop
        set Pow2[0] = 1
        set Pow2[1] = 2
        set Pow2[2] = 4
        set Pow2[3] = 8
        set Pow2[4] = 16
        set i = 0
        loop
            exitwhen i > 9
            set ClassChar[i + 1] = I2S(i)
            call SaveInteger(ClassTab, 0, StringHash(I2S(i)), i + 1)
            set KeyEquip[i] = ".e" + I2S(i)
            set KeyHero[i] = "h" + I2S(i)
            set i = i + 1
        endloop
        set ClassChar[11] = ";"
        call SaveInteger(ClassTab, 0, StringHash(";"), 11)
        set ClassChar[12] = "|"
        call SaveInteger(ClassTab, 0, StringHash("|"), 12)
        set i = 0
        loop
            exitwhen i > 99
            set KeyStore[i] = "s." + I2S(i)
            set KeyInv[i] = ".i" + I2S(i)
            set i = i + 1
        endloop
        set KeyHeroField[0] = ".sk"
        set KeyHeroField[1] = ".lg"
        set KeyHeroField[2] = ".q"
        set KeyHeroField[3] = ".qb"
        set KeyHeroField[4] = ".tq"
        set KeyHeroField[5] = ".x.st"
        set KeyHeroField[6] = ".x.win"
        set KeyHeroField[7] = ".x.done"
        // 맵 시작 때 모든 클라이언트에서 한 번 만든다(이 라이브러리가 만드는 핸들은 이것 하나)
        set BuildTrig = CreateTrigger()
        call TriggerAddCondition(BuildTrig, Condition(function BuildSectionCond))
    endfunction

endlibrary
