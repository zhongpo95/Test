// 세이브 v2 개발 명령(10 P0, A1·A2·A9 확인). 시험 맵 import 묶음에만 넣는다. 운영 맵에 쓰지 않는다.
library ArcanaSaveDev initializer onInit requires ArcanaSaveData, ArcanaSaveNet3Natives, ITEM

    // 명령은 채팅 이벤트(모든 클라이언트에서 같은 순서)로 동기 경로에서 돈다. 작업 공간은 빈 플레이어 번호 SCRATCH 의 해시테이블 칸이다.
    //  -a5hash   A1: "a"=="A", StringHash 대소문자, base32hex 32글자의 해시가 서로 다른지, 한글 바이트 길이
    //  -a5codex  A2: 410자 카드·각성 도감과 17자 머리 도감을 한 틱에 해독하고 개수를 확인한다
    //  -a5fill   꽉 찬 합성 계정(영웅 5, 모든 칸, 도감 전부)을 0.05초마다 한 묶음씩 SCRATCH 에 채운다
    //  -a5build  A9: 입력한 사람 화면에서 SCRATCH 문서를 한 번에 만든다(ArcanaDocNew → BuildStep → ArcanaDocDrop, 서버로 보내지 않음)
    //            "-a5build 200" 처럼 예산을 주면 그 예산으로 한 번만 부르고 끝났는지 보여 준다
    //  -a5dump   P1: 아이템 번호 1~200 의 rawcode·SLK 종류(Tip)·단계(Level)·이름을 DLL 로그에 한 줄씩 남긴다([A5DUMP])
    // 결과 줄이 나오지 않으면 그 스레드가 실행 한도에 걸려 멈춘 것이다.

    globals
        private constant integer SCRATCH = 27
        private constant string ACCESSORY = "ID2;특성1;품질20;각인7;각인수치1;각인P51;각인P수치1;"
        private constant string MATERIAL = "ID24;중첩수35;"
        private timer FillTimer = CreateTimer()
        private integer FillStage = 0
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
        local string cards = FullCards()
        local string heads = FullHeads()
        local boolean ok
        call Say("A2 시작: 카드 " + I2S(StringLength(cards)) + "자, 머리 " + I2S(StringLength(heads)) + "자")
        call ArcanaSaveReset(SCRATCH)
        set ok = ArcanaSaveApply(SCRATCH, "v", "2") and ArcanaSaveApply(SCRATCH, "dv", "1")
        set ok = ok and ArcanaSaveApply(SCRATCH, "c.c", cards)
        set ok = ok and ArcanaSaveApply(SCRATCH, "c.a", cards)
        set ok = ok and ArcanaSaveApply(SCRATCH, "c.h", heads)
        call Say("A2 끝: 해독 " + YesNo(ok) + ", 카드 " + I2S(ArcanaSaveCodexCount(SCRATCH, ARCANA_CODEX_CARD)) + "/2035, 각성 " + I2S(ArcanaSaveCodexCount(SCRATCH, ARCANA_CODEX_AWAKE)) + "/2035, 머리 " + I2S(ArcanaSaveCodexCount(SCRATCH, ARCANA_CODEX_HEAD)) + "/80, 1665번 " + YesNo(ArcanaSaveCodexHas(SCRATCH, ARCANA_CODEX_CARD, 1665)) + ", 12번 " + YesNo(ArcanaSaveCodexHas(SCRATCH, ARCANA_CODEX_CARD, 12)))
        set cards = null
        set heads = null
    endfunction

    private function FillStep takes nothing returns nothing
        local integer s = 0
        local integer h = FillStage - 1
        if FillStage == 0 then
            call ArcanaSaveReset(SCRATCH)
            call ArcanaSaveApply(SCRATCH, "v", "2")
            call ArcanaSaveApply(SCRATCH, "dv", "1")
            call ArcanaSaveApply(SCRATCH, "c.c", FullCards())
            call ArcanaSaveApply(SCRATCH, "c.a", FullCards())
            call ArcanaSaveApply(SCRATCH, "c.h", FullHeads())
            call ArcanaSaveSetInt(SCRATCH, ARCANA_SF_GOLD, 2000000000)
            call ArcanaSaveSetInt(SCRATCH, ARCANA_SF_BIGWHEEL, 3)
            call ArcanaSaveSetInt(SCRATCH, ARCANA_SF_TOTALDAILY, 999)
            call ArcanaSaveSetInt(SCRATCH, ARCANA_SF_DAILYLAST, 20261017)
            loop
                exitwhen s >= 100
                call ArcanaSaveSetStore(SCRATCH, s, ACCESSORY)
                set s = s + 1
            endloop
        elseif FillStage <= 5 then
            call ArcanaSaveHeroCreate(SCRATCH, h, 2)
            call ArcanaSaveSetSkinOwned(SCRATCH, h, 1)
            call ArcanaSaveSetSkinOwned(SCRATCH, h, 2)
            set s = 1
            loop
                exitwhen s > ARCANA_HF_X_DONE
                call ArcanaSaveSetHeroInt(SCRATCH, h, s, 99)
                set s = s + 1
            endloop
            set s = 0
            loop
                exitwhen s >= 10
                call ArcanaSaveSetEquip(SCRATCH, h, s, ACCESSORY)
                set s = s + 1
            endloop
            set s = 0
            loop
                exitwhen s >= 100
                if s < 50 then
                    call ArcanaSaveSetInv(SCRATCH, h, s, ACCESSORY)
                else
                    call ArcanaSaveSetInv(SCRATCH, h, s, MATERIAL)
                endif
                set s = s + 1
            endloop
        endif
        set FillStage = FillStage + 1
        if FillStage > 5 then
            call PauseTimer(FillTimer)
            call Say("합성 계정 채움: 골드 " + I2S(ArcanaSaveGetInt(SCRATCH, ARCANA_SF_GOLD)) + ", 영웅5 i99 " + ArcanaSaveInv(SCRATCH, 5, 99, "없음") + ", 카드 " + I2S(ArcanaSaveCodexCount(SCRATCH, ARCANA_CODEX_CARD)))
        endif
    endfunction

    private function CmdBuild takes player p, integer budget returns nothing
        local integer doc
        local boolean done = false
        if GetLocalPlayer() == p then
            static if ARCANA_SAVE_BACKEND then
                set doc = ArcanaDocNew()
                call Say("A9 시작: 예산 " + I2S(budget) + " 문서 " + I2S(doc))
                call ArcanaSaveBuildBegin(SCRATCH)
                set done = ArcanaSaveBuildStep(SCRATCH, doc, budget)
                call Say("A9 끝: 완료 " + YesNo(done) + ", 항목 " + I2S(ARCANA_SAVE_BUILD_COUNT) + " (꽉 찬 합성 계정은 705)")
                call ArcanaDocDrop(doc)
            endif
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

    private function OnChat takes nothing returns nothing
        local string msg = GetEventPlayerChatString()
        local integer budget = ARCANA_SAVE_BUILD_BUDGET
        if msg == "-a5hash" then
            call CmdHash()
        elseif msg == "-a5codex" then
            call CmdCodex()
        elseif msg == "-a5dump" then
            call CmdDump()
        elseif msg == "-a5fill" then
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
        set t = null
    endfunction

endlibrary
