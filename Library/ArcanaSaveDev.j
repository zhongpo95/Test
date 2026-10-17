// 세이브 v2 개발 명령(10 P0, A1·A2·A9 확인). 시험 맵 import 묶음에만 넣는다. 운영 맵에 쓰지 않는다.
library ArcanaSaveDev initializer onInit requires ArcanaSaveData, ArcanaSaveNet3Natives, ITEM

    // 명령은 채팅 이벤트(모든 클라이언트에서 같은 순서)로 동기 경로에서 돈다. 작업 공간은 빈 플레이어 번호 SCRATCH 의 해시테이블 칸이다.
    //  -a5hash   A1: "a"=="A", StringHash 대소문자, base32hex 32글자의 해시가 서로 다른지, 한글 바이트 길이
    //  -a5codex  A2: 410자 카드·각성 도감과 17자 머리 도감을 한 틱에 해독하고 개수를 확인한다
    //  -a5fill   꽉 찬 합성 계정(영웅 5, 모든 칸, 도감 전부)을 0.05초마다 한 묶음씩 SCRATCH 에 채운다
    //  -a5fillme 같은 합성 데이터를 입력한 사람 자신의 저장 데이터에 채운다(시험 계정 전용, 로드 시간 측정용)
    //  -a5build  A9: 입력한 사람 화면에서 SCRATCH 문서를 한 번에 만든다(ArcanaDocNew → BuildStep → ArcanaDocDrop, 서버로 보내지 않음)
    //            "-a5build 200" 처럼 예산을 주면 그 예산으로 한 번만 부르고 끝났는지 보여 준다
    //  -a5ops    실행 한도 재기: 일정한 반복을 2.5만~30만 단계(게임 밖 모의 실행 기준)로 각각 새 스레드에서 돌리고, 끝까지 간 단계마다 한 줄씩 남긴다
    //  -a5dump   P1: 아이템 번호 1~200 의 rawcode·SLK 종류(Tip)·단계(Level)·이름을 DLL 로그에 한 줄씩 남긴다([A5DUMP])
    //  -a5datacheck P1: 생성 배열(ARCANA_ITEM_RAW/TYPE/TIER)과 ItemData·SLK(Tip·Level) 값을 비교해 어긋난 번호만 남긴다
    // 결과 줄이 나오지 않으면 그 스레드가 실행 한도에 걸려 멈춘 것이다.

    globals
        private constant integer SCRATCH = 27
        private constant string ACCESSORY = "ID2;특성1;품질20;각인7;각인수치1;각인P51;각인P수치1;"
        private constant string MATERIAL = "ID24;중첩수35;"
        private timer FillTimer = CreateTimer()
        private integer FillStage = 0
        // 무거운 적용 하나를 새 스레드에서 돌린다(실행 한도가 새로 시작). 결과는 ApplyOk
        private trigger ApplyTrig = CreateTrigger()
        private string ApplyKey = ""
        private string ApplyValue = ""
        private boolean ApplyOk = false
        private string CardsText = ""
        private string HeadsText = ""
        private integer OpsN = 0
        private integer FillPid = 27
        private integer ApplyPid = 27
    endglobals

    private function Say takes string msg returns nothing
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 30.00, "|cff66ccff[A5]|r " + msg)
        call ArcanaSaveTrace("[A5] " + msg)
    endfunction

    private function YesNo takes boolean b returns string
        if b then
            return "예"
        endif
        return "아니오"
    endfunction

    private function Repeat takes string c, integer n returns string
        local string s = ""
        loop
            exitwhen n <= 0
            set s = s + c
            set n = n - 1
        endloop
        return s
    endfunction

    // 카드 13~2047 전부: 글자 0·1 은 0, 글자 2 는 13·14(값 24 = O), 글자 3~408 은 V, 글자 409 는 2045~2047(값 7)
    private function FullCards takes nothing returns string
        return "00O" + Repeat("V", 406) + "7"
    endfunction

    // 머리 1~80: 글자 0 은 1~4(값 30 = U), 글자 1~15 는 V, 글자 16 은 80(값 1)
    private function FullHeads takes nothing returns string
        return "U" + Repeat("V", 15) + "1"
    endfunction

    private function ApplyCond takes nothing returns boolean
        set ApplyOk = ArcanaSaveApply(ApplyPid, ApplyKey, ApplyValue)
        return false
    endfunction

    private function ApplyThread takes string k, string v returns boolean
        set ApplyPid = FillPid
        set ApplyKey = k
        set ApplyValue = v
        set ApplyOk = false
        call TriggerEvaluate(ApplyTrig)
        return ApplyOk
    endfunction

    // 한 바퀴 = 모의 실행 기준 OPS_PER_ITER 단계(run_dev_mock 로 잼)
    private function OpsCond takes nothing returns boolean
        local integer i = 0
        local integer x = 0
        local string s = "0123456789"
        loop
            exitwhen i >= OpsN
            set x = x + StringLength(SubString(s, i - (i / 10) * 10, 10))
            set i = i + 1
        endloop
        call Say("A0 실행량 " + I2S(OpsN) + "바퀴 끝(" + I2S(x) + ")")
        set s = null
        return false
    endfunction

    private function CmdOps takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer k = 1
        call TriggerAddCondition(t, Condition(function OpsCond))
        loop
            exitwhen k > 12
            // 바퀴 수: 1000, 2000, ... 12000
            set OpsN = k * 1000
            call TriggerEvaluate(t)
            set k = k + 1
        endloop
        call Say("A0 실행량 시험 끝(마지막으로 나온 줄까지 견딤)")
        call DestroyTrigger(t)
        set t = null
    endfunction

    private function CmdHash takes nothing returns nothing
        local string a = "0123456789ABCDEFGHIJKLMNOPQRSTUV"
        local integer i = 0
        local integer j
        local integer dup = 0
        loop
            exitwhen i >= 32
            set j = i + 1
            loop
                exitwhen j >= 32
                if StringHash(SubString(a, i, i + 1)) == StringHash(SubString(a, j, j + 1)) then
                    set dup = dup + 1
                endif
                set j = j + 1
            endloop
            set i = i + 1
        endloop
        call Say("A1 \"a\"==\"A\": " + YesNo("a" == "A") + ", StringHash(a)==StringHash(A): " + YesNo(StringHash("a") == StringHash("A")) + ", base32 해시 겹침: " + I2S(dup) + ", 가 바이트: " + I2S(StringLength("가")))
        call Say("A1 \"0o\" 머리 도감 해독(소문자): " + YesNo(ArcanaSaveApply(SCRATCH, "c.h", "0o")) + " (서버는 소문자를 거부한다)")
        call ArcanaSaveReset(SCRATCH)
    endfunction

    private function CmdCodex takes nothing returns nothing
        local string cards = CardsText
        local string heads = HeadsText
        local boolean ok
        call Say("A2 시작: 카드 " + I2S(StringLength(cards)) + "자, 머리 " + I2S(StringLength(heads)) + "자")
        set FillPid = SCRATCH
        call ArcanaSaveReset(SCRATCH)
        set ok = ArcanaSaveApply(SCRATCH, "v", "2") and ArcanaSaveApply(SCRATCH, "dv", "1")
        // 410자 해독은 각각 새 스레드에서(어댑터도 로드 항목을 틱 예산으로 나눠 적용한다)
        set ok = ok and ApplyThread("c.c", cards)
        call Say("A2 카드 해독 끝: " + I2S(ArcanaSaveCodexCount(SCRATCH, ARCANA_CODEX_CARD)))
        set ok = ok and ApplyThread("c.a", cards)
        set ok = ok and ApplyThread("c.h", heads)
        call Say("A2 끝: 해독 " + YesNo(ok) + ", 카드 " + I2S(ArcanaSaveCodexCount(SCRATCH, ARCANA_CODEX_CARD)) + "/2035, 각성 " + I2S(ArcanaSaveCodexCount(SCRATCH, ARCANA_CODEX_AWAKE)) + "/2035, 머리 " + I2S(ArcanaSaveCodexCount(SCRATCH, ARCANA_CODEX_HEAD)) + "/80, 1665번 " + YesNo(ArcanaSaveCodexHas(SCRATCH, ARCANA_CODEX_CARD, 1665)) + ", 12번 " + YesNo(ArcanaSaveCodexHas(SCRATCH, ARCANA_CODEX_CARD, 12)))
        set cards = null
        set heads = null
    endfunction

    // 한 틱에 칸 10개씩 채운다(쓰기마다 아이템 문법 검사가 바이트 수만큼 돈다, 실행 한도). 단계: 0 계정·도감, 1~10 창고, 그 뒤 영웅마다 11단계
    private function FillStep takes nothing returns nothing
        local integer s = 0
        local integer st = FillStage
        local integer h
        local integer part
        if st == 0 then
            call ArcanaSaveReset(FillPid)
            call ArcanaSaveApply(FillPid, "v", "2")
            call ArcanaSaveApply(FillPid, "dv", "1")
            call ApplyThread("c.c", CardsText)
            call ApplyThread("c.a", CardsText)
            call ApplyThread("c.h", HeadsText)
            call ArcanaSaveSetInt(FillPid, ARCANA_SF_GOLD, 2000000000)
            call ArcanaSaveSetInt(FillPid, ARCANA_SF_BIGWHEEL, 3)
            call ArcanaSaveSetInt(FillPid, ARCANA_SF_TOTALDAILY, 999)
            call ArcanaSaveSetInt(FillPid, ARCANA_SF_DAILYLAST, 20261017)
        elseif st <= 10 then
            set s = (st - 1) * 10
            loop
                exitwhen s >= st * 10
                call ArcanaSaveSetStore(FillPid, s, ACCESSORY)
                set s = s + 1
            endloop
        elseif st <= 65 then
            set h = (st - 11) / 11 + 1
            set part = st - 11 - (h - 1) * 11
            if part == 0 then
                call ArcanaSaveHeroCreate(FillPid, h, 2)
                call ArcanaSaveSetSkinOwned(FillPid, h, 1)
                call ArcanaSaveSetSkinOwned(FillPid, h, 2)
                set s = 1
                loop
                    exitwhen s > ARCANA_HF_X_DONE
                    call ArcanaSaveSetHeroInt(FillPid, h, s, 99)
                    set s = s + 1
                endloop
                set s = 0
                loop
                    exitwhen s >= 10
                    call ArcanaSaveSetEquip(FillPid, h, s, ACCESSORY)
                    set s = s + 1
                endloop
            else
                set s = (part - 1) * 10
                loop
                    exitwhen s >= part * 10
                    if s < 50 then
                        call ArcanaSaveSetInv(FillPid, h, s, ACCESSORY)
                    else
                        call ArcanaSaveSetInv(FillPid, h, s, MATERIAL)
                    endif
                    set s = s + 1
                endloop
            endif
        endif
        set FillStage = FillStage + 1
        if FillStage > 65 then
            call PauseTimer(FillTimer)
            call Say("합성 계정 채움: 골드 " + I2S(ArcanaSaveGetInt(FillPid, ARCANA_SF_GOLD)) + ", 영웅5 i99 " + ArcanaSaveInv(FillPid, 5, 99, "없음") + ", 카드 " + I2S(ArcanaSaveCodexCount(FillPid, ARCANA_CODEX_CARD)))
        endif
    endfunction

    private function CmdBuild takes player p, integer budget returns nothing
        local integer doc
        local boolean done = false
        if GetLocalPlayer() == p then
            set doc = ArcanaDocNew()
            call Say("A9 시작: 예산 " + I2S(budget) + " 문서 " + I2S(doc))
            call ArcanaSaveBuildBegin(SCRATCH)
            set done = ArcanaSaveBuildStep(SCRATCH, doc, budget)
            call Say("A9 끝: 완료 " + YesNo(done) + ", 항목 " + I2S(ARCANA_SAVE_BUILD_COUNT) + " (꽉 찬 합성 계정은 705)")
            call ArcanaDocDrop(doc)
        endif
    endfunction

    private function CmdDump takes nothing returns nothing
        local integer id = 1
        local integer n = 0
        local integer raw
        local string it
        loop
            exitwhen id > 200
            set raw = LoadInteger(ItemData, StringHash("ITEMID"), id)
            if raw != 0 then
                set it = "ID" + I2S(id) + ";"
                call ArcanaSaveTrace("[A5DUMP] id=" + I2S(id) + " raw=" + I2S(raw) + " type=" + I2S(GetItemTypes(it)) + " tier=" + I2S(GetItemTier(it)) + " class=" + GetItemClass(it) + " name=" + GetItemNames(it))
                set n = n + 1
            endif
            set id = id + 1
        endloop
        call Say("아이템 덤프: " + I2S(n) + "개를 DLL 로그에 남겼습니다([A5DUMP])")
        set it = null
    endfunction

    private function SlkField takes integer raw, string field returns string
        return EXExecuteScript("(require'jass.slk').item[" + I2S(raw) + "]." + field)
    endfunction

    private function CmdDataCheck takes nothing returns nothing
        local integer id = 1
        local integer bad = 0
        local integer raw
        local integer t
        loop
            exitwhen id > 200
            set raw = LoadInteger(ItemData, StringHash("ITEMID"), id)
            if raw != 0 or (id <= ARCANA_ITEM_ID_MAX and ARCANA_ITEM_RAW[id] != 0) then
                set t = S2I(SlkField(raw, "Tip"))
                if t < 0 or t > 7 then
                    set t = -1
                endif
                if id > ARCANA_ITEM_ID_MAX or raw != ARCANA_ITEM_RAW[id] or t != ARCANA_ITEM_TYPE[id] or S2I(SlkField(raw, "Level")) != ARCANA_ITEM_TIER[id] then
                    set bad = bad + 1
                    call ArcanaSaveTrace("[A5DATA] id=" + I2S(id) + " raw=" + I2S(raw) + "/" + I2S(ARCANA_ITEM_RAW[id]) + " type=" + I2S(t) + "/" + I2S(ARCANA_ITEM_TYPE[id]) + " tier=" + SlkField(raw, "Level") + "/" + I2S(ARCANA_ITEM_TIER[id]))
                endif
            endif
            set id = id + 1
        endloop
        call Say("데이터 대조: 어긋난 번호 " + I2S(bad) + "개(DLL 로그 [A5DATA]), 데이터 판 " + I2S(ARCANA_DATA_VERSION))
    endfunction

    private function OnChat takes nothing returns nothing
        local string msg = GetEventPlayerChatString()
        local integer budget = ARCANA_SAVE_BUILD_BUDGET
        if msg == "-a5ops" then
            call CmdOps()
        elseif msg == "-a5hash" then
            call CmdHash()
        elseif msg == "-a5codex" then
            call CmdCodex()
        elseif msg == "-a5datacheck" then
            call CmdDataCheck()
        elseif msg == "-a5dump" then
            call CmdDump()
        elseif msg == "-a5fill" or msg == "-a5fillme" then
            // -a5fillme: 입력한 사람 자신의 데이터를 꽉 찬 합성 계정으로 덮는다(시험 계정 전용, 다음 저장에 들어간다)
            set FillPid = SCRATCH
            if msg == "-a5fillme" then
                set FillPid = GetPlayerId(GetTriggerPlayer())
            endif
            set FillStage = 0
            call TimerStart(FillTimer, 0.05, true, function FillStep)
        elseif SubString(msg, 0, 8) == "-a5build" then
            if StringLength(msg) > 9 then
                set budget = S2I(SubString(msg, 9, StringLength(msg)))
            endif
            call CmdBuild(GetTriggerPlayer(), budget)
        endif
        set msg = null
    endfunction

    private function onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer i = 0
        loop
            exitwhen i >= bj_MAX_PLAYERS
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-a5", false)
            set i = i + 1
        endloop
        call TriggerAddAction(t, function OnChat)
        call TriggerAddCondition(ApplyTrig, Condition(function ApplyCond))
        set CardsText = FullCards()
        set HeadsText = FullHeads()
        set t = null
    endfunction

endlibrary
