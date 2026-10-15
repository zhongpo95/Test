// Arcana 판 게임 로그인(홈페이지에서 만든 아이디·비밀번호). JN 판(ARCANA_SAVE_BACKEND 거짓)에서는 아무것도 하지 않는다.
// - 각자 화면에 아이디·비밀번호 칸과 로그인 버튼을 띄운다. 비밀번호 칸은 * 로 가린다.
// - 로그인(ArcanaLogin)은 그 플레이어 화면(로컬)에서만 DLL 로 하고, 결과(성공 여부·표시 이름)만 "ALG" 로 동기화한다. 비밀번호는 동기화하지 않는다.
// - 성공을 받으면(동기) ARCANA_LOGIN_OK 를 실행한다. PlayerSave 가 그 플레이어 로드를 시작하고, 로드가 끝나면 영웅 선택 창이 열린다.
// - 로드가 실패하면(ARCANA_LOGIN_DONE 거짓으로 돌아옴) 입력칸이 다시 열린다.
library ArcanaSaveLogin initializer ArcanaSaveLoginInit requires ArcanaSaveConfig, ArcanaSaveNet3Natives, ArcanaStashNet, DzAPISync, DzAPIFrameHandle

    globals
        string array ARCANA_LOGIN_NAME
        integer ARCANA_LOGIN_ID_BOX = 0
        integer ARCANA_LOGIN_PW_BOX = 0
        integer ARCANA_LOGIN_BUTTON = 0
        integer ARCANA_LOGIN_HINT = 0
        integer ARCANA_LOGIN_PANEL = 0
        // 소유자 화면에서만 쓰는 값
        string ARCANA_LOGIN_PW = ""
        string ARCANA_LOGIN_MASK = ""
        integer ARCANA_LOGIN_REQ = 0
        boolean ARCANA_LOGIN_SHOWN = false
    endglobals

    function ArcanaSaveLoginHint takes string s returns nothing
        if ARCANA_LOGIN_HINT != 0 then
            call DzFrameSetText(ARCANA_LOGIN_HINT, s)
        endif
    endfunction

    function ArcanaSaveLoginShow takes boolean show returns nothing
        set ARCANA_LOGIN_SHOWN = show
        if ARCANA_LOGIN_PANEL != 0 then
            call DzFrameShow(ARCANA_LOGIN_PANEL, show)
        endif
    endfunction

    // 로컬: 입력칸 내용을 읽어 로그인 요청. 버튼·Enter 에서 부른다
    function ArcanaSaveLoginSubmit takes nothing returns nothing
        local string id
        static if ARCANA_SAVE_BACKEND then
            if ARCANA_LOGIN_REQ != 0 or ARCANA_LOGIN_DONE[GetPlayerId(GetLocalPlayer())] then
                return
            endif
            set id = DzFrameGetText(ARCANA_LOGIN_ID_BOX)
            if id == null or id == "" or ARCANA_LOGIN_PW == "" then
                call ArcanaSaveLoginHint("|cffffcc00아이디와 비밀번호를 입력하세요.|r")
                return
            endif
            set ARCANA_LOGIN_REQ = ArcanaLogin(id, ARCANA_LOGIN_PW)
            set ARCANA_LOGIN_PW = ""
            set ARCANA_LOGIN_MASK = ""
            call DzFrameSetText(ARCANA_LOGIN_PW_BOX, "")
            if ARCANA_LOGIN_REQ == 0 then
                call ArcanaSaveLoginHint("|cffff4040로그인을 시작하지 못했습니다(DLL 설정 확인).|r")
            else
                call ArcanaSaveLoginHint("로그인 중...")
            endif
        endif
        set id = null
    endfunction

    // 로컬: 비밀번호 칸을 * 로 가린다. 바뀐 글자만 실제 비밀번호에 반영한다(끝에 덧붙임·지움 기준)
    function ArcanaSaveLoginPwChanged takes nothing returns nothing
        local string t = DzFrameGetText(ARCANA_LOGIN_PW_BOX)
        local integer n
        local integer m
        if t == null then
            set t = ""
        endif
        if t == ARCANA_LOGIN_MASK then
            set t = null
            return
        endif
        set n = StringLength(t)
        set m = StringLength(ARCANA_LOGIN_PW)
        if n > m then
            set ARCANA_LOGIN_PW = ARCANA_LOGIN_PW + SubString(t, m, n)
        else
            set ARCANA_LOGIN_PW = SubString(ARCANA_LOGIN_PW, 0, n)
        endif
        set ARCANA_LOGIN_MASK = ""
        set m = 0
        loop
            exitwhen m >= StringLength(ARCANA_LOGIN_PW)
            set ARCANA_LOGIN_MASK = ARCANA_LOGIN_MASK + "*"
            set m = m + 1
        endloop
        call DzFrameSetText(ARCANA_LOGIN_PW_BOX, ARCANA_LOGIN_MASK)
        set t = null
    endfunction

    // 0.1초 동기 타이머. 로그인 결과 확인·입력칸 다시 열기는 각자 화면에서만 한다
    function ArcanaSaveLoginTick takes nothing returns nothing
        local integer st
        local string r
        static if ARCANA_SAVE_BACKEND then
            if ARCANA_LOGIN_REQ != 0 then
                set st = ArcanaNetPoll(ARCANA_LOGIN_REQ)
                if st == 1 then
                    set r = ArcanaNetResult(ARCANA_LOGIN_REQ)
                    call ArcanaNetRelease(ARCANA_LOGIN_REQ)
                    set ARCANA_LOGIN_REQ = 0
                    call ArcanaSaveLoginHint("로그인 성공. 다른 플레이어에게 알리는 중...")
                    call DzSyncData("ALG", "1|" + r)
                elseif st != 0 then
                    set r = ArcanaNetResult(ARCANA_LOGIN_REQ)
                    call ArcanaNetRelease(ARCANA_LOGIN_REQ)
                    set ARCANA_LOGIN_REQ = 0
                    if r == "bad_credentials" then
                        call ArcanaSaveLoginHint("|cffff4040아이디 또는 비밀번호가 틀렸습니다.|r")
                    elseif r == "too_many_attempts" then
                        call ArcanaSaveLoginHint("|cffff4040시도가 너무 많습니다. 잠시 뒤 다시 하세요.|r")
                    elseif r == "account_locked" then
                        call ArcanaSaveLoginHint("|cffff4040잠긴 계정입니다. 관리자에게 문의하세요.|r")
                    else
                        call ArcanaSaveLoginHint("|cffff4040서버에 연결하지 못했습니다(" + r + "). 다시 시도하세요.|r")
                    endif
                endif
            elseif not ARCANA_LOGIN_SHOWN and not ARCANA_LOGIN_DONE[GetPlayerId(GetLocalPlayer())] and ARCANA_LOGIN_PANEL != 0 then
                // 로드 실패 등으로 로그인이 풀리면 입력칸을 다시 연다
                call ArcanaSaveLoginShow(true)
            endif
        endif
        set r = null
    endfunction

    // 동기: 로그인 결과 수신(모든 클라이언트)
    function ArcanaSaveLoginOnSync takes nothing returns nothing
        local integer pid = GetPlayerId(DzGetTriggerSyncPlayer())
        local string d = DzGetTriggerSyncData()
        if pid < 0 or pid >= bj_MAX_PLAYERS or SubString(d, 0, 2) != "1|" or ARCANA_LOGIN_DONE[pid] then
            set d = null
            return
        endif
        set ARCANA_LOGIN_DONE[pid] = true
        set ARCANA_LOGIN_NAME[pid] = SubString(d, 2, StringLength(d))
        if GetLocalPlayer() == Player(pid) then
            call ArcanaSaveLoginShow(false)
        endif
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 8, "|cff40ff40[로그인]|r " + GetPlayerName(Player(pid)) + " → " + ARCANA_LOGIN_NAME[pid] + " (데이터를 불러옵니다)")
        set ARCANA_LOGIN_OK_PID = pid
        call TriggerExecute(ARCANA_LOGIN_OK)
        set d = null
    endfunction

    function ArcanaSaveLoginMakeFrames takes nothing returns nothing
        local integer label
        set ARCANA_LOGIN_PANEL = DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "StandardEditBoxBackdropTemplate", 0)
        call DzFrameSetSize(ARCANA_LOGIN_PANEL, 0.30, 0.17)
        call DzFrameSetAbsolutePoint(ARCANA_LOGIN_PANEL, 4, 0.40, 0.38)
        set label = DzCreateFrameByTagName("TEXT", "", ARCANA_LOGIN_PANEL, "", 0)
        call DzFrameSetPoint(label, 1, ARCANA_LOGIN_PANEL, 1, 0.0, -0.012)
        call DzFrameSetText(label, "|cffffcc00아르카나 로그인|r  (가입은 홈페이지에서)")
        set ARCANA_LOGIN_ID_BOX = DzCreateFrameByTagName("EDITBOX", "ArcanaLoginId", ARCANA_LOGIN_PANEL, "EscMenuEditBoxTemplate", 0)
        call DzFrameSetSize(ARCANA_LOGIN_ID_BOX, 0.20, 0.03)
        call DzFrameSetPoint(ARCANA_LOGIN_ID_BOX, 1, ARCANA_LOGIN_PANEL, 1, 0.03, -0.035)
        set label = DzCreateFrameByTagName("TEXT", "", ARCANA_LOGIN_PANEL, "", 0)
        call DzFrameSetPoint(label, 5, ARCANA_LOGIN_ID_BOX, 3, -0.005, 0.0)
        call DzFrameSetText(label, "아이디")
        set ARCANA_LOGIN_PW_BOX = DzCreateFrameByTagName("EDITBOX", "ArcanaLoginPw", ARCANA_LOGIN_PANEL, "EscMenuEditBoxTemplate", 0)
        call DzFrameSetSize(ARCANA_LOGIN_PW_BOX, 0.20, 0.03)
        call DzFrameSetPoint(ARCANA_LOGIN_PW_BOX, 1, ARCANA_LOGIN_ID_BOX, 7, 0.0, -0.006)
        set label = DzCreateFrameByTagName("TEXT", "", ARCANA_LOGIN_PANEL, "", 0)
        call DzFrameSetPoint(label, 5, ARCANA_LOGIN_PW_BOX, 3, -0.005, 0.0)
        call DzFrameSetText(label, "비밀번호")
        set ARCANA_LOGIN_BUTTON = DzCreateFrameByTagName("GLUETEXTBUTTON", "", ARCANA_LOGIN_PANEL, "ScriptDialogButton", 0)
        call DzFrameSetSize(ARCANA_LOGIN_BUTTON, 0.10, 0.03)
        call DzFrameSetPoint(ARCANA_LOGIN_BUTTON, 1, ARCANA_LOGIN_PW_BOX, 7, 0.0, -0.006)
        call DzFrameSetText(ARCANA_LOGIN_BUTTON, "로그인")
        set ARCANA_LOGIN_HINT = DzCreateFrameByTagName("TEXT", "", ARCANA_LOGIN_PANEL, "", 0)
        call DzFrameSetPoint(ARCANA_LOGIN_HINT, 7, ARCANA_LOGIN_PANEL, 7, 0.0, 0.008)
        call DzFrameSetText(ARCANA_LOGIN_HINT, "아이디·비밀번호 입력 후 Enter 또는 로그인")
        call DzFrameSetScriptByCode(ARCANA_LOGIN_PW_BOX, JN_FRAMEEVENT_EDITBOX_TEXT_CHANGED, function ArcanaSaveLoginPwChanged, false)
        call DzFrameSetScriptByCode(ARCANA_LOGIN_PW_BOX, JN_FRAMEEVENT_EDITBOX_ENTER, function ArcanaSaveLoginSubmit, false)
        call DzFrameSetScriptByCode(ARCANA_LOGIN_ID_BOX, JN_FRAMEEVENT_EDITBOX_ENTER, function ArcanaSaveLoginSubmit, false)
        call DzFrameSetScriptByCode(ARCANA_LOGIN_BUTTON, JN_FRAMEEVENT_MOUSE_UP, function ArcanaSaveLoginSubmit, false)
        call ArcanaSaveLoginShow(true)
        call DestroyTimer(GetExpiredTimer())
    endfunction

    function ArcanaSaveLoginInit takes nothing returns nothing
        local trigger t
        static if ARCANA_SAVE_BACKEND then
            set t = CreateTrigger()
            call DzTriggerRegisterSyncData(t, "ALG", false)
            call TriggerAddAction(t, function ArcanaSaveLoginOnSync)
            call TimerStart(CreateTimer(), 0.1, true, function ArcanaSaveLoginTick)
            // 프레임은 모든 클라이언트에서 같은 순서로 만든다(입력은 각자 화면에서만 쓰인다)
            call TimerStart(CreateTimer(), 1.0, false, function ArcanaSaveLoginMakeFrames)
        endif
        set t = null
    endfunction

endlibrary
