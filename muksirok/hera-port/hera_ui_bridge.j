// Lua의 UI 요청을 JASS 전역변수로 받아 Dz 네이티브를 JASS에서 호출한다.
native DzTriggerRegisterMouseEventByCode takes trigger trig, integer btn, integer status, boolean sync, code funcHandle returns nothing
native DzTriggerRegisterKeyEventByCode takes trigger trig, integer key, integer status, boolean sync, code funcHandle returns nothing
native DzGetTriggerKeyPlayer takes nothing returns player
native DzGetMouseFocus takes nothing returns integer
native DzFrameGetTooltip takes nothing returns integer
native DzGetGameUI takes nothing returns integer
native DzCreateFrameByTagName takes string frameType, string name, integer parent, string template, integer id returns integer
native DzDestroyFrame takes integer frame returns nothing
native DzFrameSetPoint takes integer frame, integer point, integer relativeFrame, integer relativePoint, real x, real y returns nothing
native DzFrameSetAbsolutePoint takes integer frame, integer point, real x, real y returns nothing
native DzFrameSetSize takes integer frame, real w, real h returns nothing
native DzFrameSetText takes integer frame, string text returns nothing
native DzFrameGetText takes integer frame returns string
native DzFrameSetFocus takes integer frame, boolean enable returns boolean
native DzFrameSetTexture takes integer frame, string texture, integer flag returns nothing
native DzFrameShow takes integer frame, boolean enable returns nothing
native DzFrameSetEnable takes integer frame, boolean enable returns nothing
native DzFrameSetScriptByCode takes integer frame, integer eventId, code funcHandle, boolean sync returns nothing
native DzGetTriggerUIEventPlayer takes nothing returns player
native DzGetTriggerUIEventFrame takes nothing returns integer
native DzLoadToc takes string fileName returns nothing
native DzFrameGetHeight takes integer frame returns real
native DzTriggerRegisterSyncData takes trigger trig, string prefix, boolean server returns nothing
native DzSyncData takes string prefix, string data returns nothing
native DzGetTriggerSyncData takes nothing returns string
native DzGetTriggerSyncPlayer takes nothing returns player
native DzFrameSetPriority takes integer frame, integer priority returns nothing
native DzFrameSetAlpha takes integer frame, integer alpha returns nothing
native DzFrameGetAlpha takes integer frame returns integer
native DzFrameSetTextColor takes integer frame, integer color returns nothing

native DzFrameHideInterface takes nothing returns nothing
native DzFrameEditBlackBorders takes real upperHeight, real bottomHeight returns nothing
native DzFrameGetMinimap takes nothing returns integer
native DzFrameGetUpperButtonBarButton takes integer buttonId returns integer
native DzFrameGetParent takes integer frame returns integer
native DzFrameGetChatMessage takes nothing returns integer
native DzFrameClearAllPoints takes integer frame returns nothing
native DzSimpleFrameFindByName takes string name, integer id returns integer
native DzSimpleFontStringFindByName takes string name, integer id returns integer
native DzSimpleTextureFindByName takes string name, integer id returns integer

native DzFrameSetFont takes integer frame, string fileName, real height, integer flag returns nothing
native DzFrameGetCommandBarButton takes integer row, integer column returns integer
native DzFrameSetModel takes integer frame, string modelFile, integer modelType, integer flag returns nothing
native DzFrameSetAnimate takes integer frame, integer animId, boolean autocast returns nothing
native DzFrameSetAnimateOffset takes integer frame, real offset returns nothing
native JNHeraModelSetSize takes integer frame, real value returns integer
native JNHeraModelSetSpeed takes integer frame, real value returns integer
native JNHeraModelTransform takes integer frame, integer operation, real x, real y, real z returns integer
native JNHeraModelSetColor takes integer frame, integer argb returns integer
native DzSetUnitModel takes unit whichUnit, string path returns nothing
native DzGetUnitUnderMouse takes nothing returns unit
native DzGetMouseXRelative takes nothing returns integer
native DzGetMouseYRelative takes nothing returns integer
native DzGetClientWidth takes nothing returns integer
native DzGetClientHeight takes nothing returns integer

globals
    trigger HeraUIBridgeEvaluator = null
    integer HeraUIBridgeOperation = 0
    integer HeraUIBridgeResult = 0
    real HeraUIBridgeRealResult = 0.0
    string HeraUIBridgeStringResult = ""
    player HeraUIBridgePlayerResult = null
    trigger HeraUIBridgeTriggerA = null
    unit HeraUIBridgeUnitA = null
    widget HeraUIBridgeWidgetResult = null
    // 마우스 상태와 무관하게 초기화해 클라이언트별 핸들 생성 시점 차이를 피한다.
    hashtable HeraUIBridgeTargetTable = InitHashtable()
    boolean HeraUIBridgeCompleted = false
    boolean HeraUIBridgeBusy = false
    integer HeraUIBridgeIntA = 0
    integer HeraUIBridgeIntB = 0
    integer HeraUIBridgeIntC = 0
    integer HeraUIBridgeIntD = 0
    real HeraUIBridgeRealA = 0.0
    real HeraUIBridgeRealB = 0.0
    real HeraUIBridgeRealC = 0.0
    real HeraUIBridgeRealD = 0.0
    real HeraUIBridgeRealE = 0.0
    real HeraUIBridgeRealF = 0.0
    integer HeraSceneTestText = 0
    string HeraUIBridgeStringA = ""
    string HeraUIBridgeStringB = ""
    string HeraUIBridgeStringC = ""
    boolean HeraUIBridgeBoolA = false
endglobals

// EXExecuteScript 선언은 통합하는 맵에서 제공한다.
function HeraUIBridgeEvent takes integer eventId returns nothing
    local integer frame = DzGetTriggerUIEventFrame()
    local integer playerId = GetPlayerId(DzGetTriggerUIEventPlayer())
    local string result = EXExecuteScript("require('hera_ui_bridge').dispatch_event(" + I2S(frame) + "," + I2S(eventId) + "," + I2S(playerId) + ")")
    if result != "" then
        call ClearTextMessages()
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 180.0, result)
    endif
endfunction

function HeraUIBridgeClick takes nothing returns nothing
    call HeraUIBridgeEvent(1)
endfunction

function HeraUIBridgeEnter takes nothing returns nothing
    call HeraUIBridgeEvent(2)
endfunction

function HeraUIBridgeLeave takes nothing returns nothing
    call HeraUIBridgeEvent(3)
endfunction

function HeraUIBridgeMouseUp takes nothing returns nothing
    call HeraUIBridgeEvent(4)
endfunction

function HeraUIBridgeMouseDown takes nothing returns nothing
    call HeraUIBridgeEvent(5)
endfunction

function HeraUIBridgeEditChanged takes nothing returns nothing
    call HeraUIBridgeEvent(9)
endfunction

// 왼쪽 버튼은 고정 해제된 UI의 드래그 시작과 종료만 전달한다.
function HeraUIBridgeLeftDown takes nothing returns nothing
    local string result = EXExecuteScript("require('hera_button_input').dispatch_left(true," + I2S(GetPlayerId(DzGetTriggerKeyPlayer())) + ")")
endfunction

function HeraUIBridgeLeftUp takes nothing returns nothing
    local string result = EXExecuteScript("require('hera_button_input').dispatch_left(false," + I2S(GetPlayerId(DzGetTriggerKeyPlayer())) + ")")
endfunction

// 우클릭은 로컬 입력만 전달하며 게임 효과는 기존 UI 동기화 큐에서 실행한다.
function HeraUIBridgeRightDown takes nothing returns nothing
    local string result = EXExecuteScript("require('hera_button_input').dispatch_right(true," + I2S(GetPlayerId(DzGetTriggerKeyPlayer())) + ")")
endfunction

function HeraUIBridgeRightUp takes nothing returns nothing
    local string result = EXExecuteScript("require('hera_button_input').dispatch_right(false," + I2S(GetPlayerId(DzGetTriggerKeyPlayer())) + ")")
endfunction

// 아르카나의 T키 등록과 동일하게 누름과 뗌을 직접 전달한다.
function HeraUIBridgeEmojiDown takes nothing returns nothing
    local string result = EXExecuteScript("require('hera_emoji_input').key_down()")
endfunction

function HeraUIBridgeEmojiUp takes nothing returns nothing
    local string result = EXExecuteScript("require('hera_emoji_input').key_up()")
endfunction

function HeraUIBridgeDispatch takes nothing returns nothing
    local integer upperBar = 0
    set HeraUIBridgeCompleted = false
    set HeraUIBridgeResult = 0
    set HeraUIBridgeRealResult = 0.0
    set HeraUIBridgeStringResult = ""
    set HeraUIBridgePlayerResult = null
    set HeraUIBridgeWidgetResult = null
    if HeraUIBridgeOperation == 1 then
        set HeraUIBridgeResult = DzGetGameUI()
    elseif HeraUIBridgeOperation == 2 then
        set HeraUIBridgeResult = DzCreateFrameByTagName(HeraUIBridgeStringA, HeraUIBridgeStringB, HeraUIBridgeIntA, HeraUIBridgeStringC, HeraUIBridgeIntB)
    elseif HeraUIBridgeOperation == 3 then
        call DzDestroyFrame(HeraUIBridgeIntA)
    elseif HeraUIBridgeOperation == 4 then
        call DzFrameSetPoint(HeraUIBridgeIntA, HeraUIBridgeIntB, HeraUIBridgeIntC, HeraUIBridgeIntD, HeraUIBridgeRealA, HeraUIBridgeRealB)
    elseif HeraUIBridgeOperation == 5 then
        call DzFrameSetAbsolutePoint(HeraUIBridgeIntA, HeraUIBridgeIntB, HeraUIBridgeRealA, HeraUIBridgeRealB)
    elseif HeraUIBridgeOperation == 6 then
        call DzFrameSetSize(HeraUIBridgeIntA, HeraUIBridgeRealA, HeraUIBridgeRealB)
    elseif HeraUIBridgeOperation == 7 then
        call DzFrameSetText(HeraUIBridgeIntA, HeraUIBridgeStringA)
    elseif HeraUIBridgeOperation == 8 then
        call DzFrameSetTexture(HeraUIBridgeIntA, HeraUIBridgeStringA, HeraUIBridgeIntB)
    elseif HeraUIBridgeOperation == 9 then
        call DzFrameShow(HeraUIBridgeIntA, HeraUIBridgeBoolA)
    elseif HeraUIBridgeOperation == 10 then
        if HeraUIBridgeIntB == 1 then
            call DzFrameSetScriptByCode(HeraUIBridgeIntA, 1, function HeraUIBridgeClick, HeraUIBridgeBoolA)
        elseif HeraUIBridgeIntB == 2 then
            call DzFrameSetScriptByCode(HeraUIBridgeIntA, 2, function HeraUIBridgeEnter, HeraUIBridgeBoolA)
        elseif HeraUIBridgeIntB == 3 then
            call DzFrameSetScriptByCode(HeraUIBridgeIntA, 3, function HeraUIBridgeLeave, HeraUIBridgeBoolA)
        elseif HeraUIBridgeIntB == 4 then
            call DzFrameSetScriptByCode(HeraUIBridgeIntA, 4, function HeraUIBridgeMouseUp, HeraUIBridgeBoolA)
        elseif HeraUIBridgeIntB == 5 then
            call DzFrameSetScriptByCode(HeraUIBridgeIntA, 5, function HeraUIBridgeMouseDown, HeraUIBridgeBoolA)
        elseif HeraUIBridgeIntB == 9 then
            call DzFrameSetScriptByCode(HeraUIBridgeIntA, 9, function HeraUIBridgeEditChanged, HeraUIBridgeBoolA)
        else
            return
        endif
    elseif HeraUIBridgeOperation == 11 then
        call DzFrameSetEnable(HeraUIBridgeIntA, HeraUIBridgeBoolA)
    elseif HeraUIBridgeOperation == 12 then
        call DzLoadToc(HeraUIBridgeStringA)
    elseif HeraUIBridgeOperation == 13 then
        set HeraUIBridgeRealResult = DzFrameGetHeight(HeraUIBridgeIntA)
    elseif HeraUIBridgeOperation == 14 then
        call DzTriggerRegisterSyncData(HeraUIBridgeTriggerA, HeraUIBridgeStringA, HeraUIBridgeBoolA)
    elseif HeraUIBridgeOperation == 15 then
        call DzSyncData(HeraUIBridgeStringA, HeraUIBridgeStringB)
    elseif HeraUIBridgeOperation == 16 then
        set HeraUIBridgeStringResult = DzGetTriggerSyncData()
    elseif HeraUIBridgeOperation == 17 then
        set HeraUIBridgePlayerResult = DzGetTriggerSyncPlayer()
    elseif HeraUIBridgeOperation == 18 then
        call DzFrameSetPriority(HeraUIBridgeIntA, HeraUIBridgeIntB)
    elseif HeraUIBridgeOperation == 19 then
        call DzFrameSetAlpha(HeraUIBridgeIntA, HeraUIBridgeIntB)
    elseif HeraUIBridgeOperation == 20 then
        set HeraUIBridgeResult = DzFrameGetAlpha(HeraUIBridgeIntA)
    elseif HeraUIBridgeOperation == 21 then
        call DzFrameSetTextColor(HeraUIBridgeIntA, HeraUIBridgeIntB)
    elseif HeraUIBridgeOperation == 22 then
        call DzFrameHideInterface()
        // 설치 Dz 숨김 함수에 빠진 상단 버튼 부모 이동을 원본 동작에 맞춰 보완한다.
        set upperBar = DzFrameGetUpperButtonBarButton(1)
        if upperBar != 0 then
            set upperBar = DzFrameGetParent(upperBar)
        endif
        if upperBar != 0 and upperBar != DzGetGameUI() then
            call DzFrameClearAllPoints(upperBar)
            call DzFrameSetPoint(upperBar, 0, DzGetGameUI(), 0, 0.0, 1.0)
        endif
    elseif HeraUIBridgeOperation == 23 then
        call DzFrameEditBlackBorders(HeraUIBridgeRealA, HeraUIBridgeRealB)
    elseif HeraUIBridgeOperation == 24 then
        set HeraUIBridgeResult = DzFrameGetMinimap()
    elseif HeraUIBridgeOperation == 25 then
        set HeraUIBridgeResult = DzFrameGetUpperButtonBarButton(HeraUIBridgeIntA)
    elseif HeraUIBridgeOperation == 26 then
        set HeraUIBridgeResult = DzFrameGetChatMessage()
    elseif HeraUIBridgeOperation == 27 then
        call DzFrameClearAllPoints(HeraUIBridgeIntA)
    elseif HeraUIBridgeOperation == 28 then
        set HeraUIBridgeResult = DzSimpleFrameFindByName(HeraUIBridgeStringA, HeraUIBridgeIntA)
    elseif HeraUIBridgeOperation == 29 then
        set HeraUIBridgeResult = DzSimpleFontStringFindByName(HeraUIBridgeStringA, HeraUIBridgeIntA)
    elseif HeraUIBridgeOperation == 30 then
        set HeraUIBridgeResult = DzSimpleTextureFindByName(HeraUIBridgeStringA, HeraUIBridgeIntA)
    elseif HeraUIBridgeOperation == 31 then
        call DzFrameSetFont(HeraUIBridgeIntA, HeraUIBridgeStringA, HeraUIBridgeRealA, HeraUIBridgeIntB)
    elseif HeraUIBridgeOperation == 32 then
        set HeraUIBridgeResult = DzFrameGetCommandBarButton(HeraUIBridgeIntA, HeraUIBridgeIntB)
    elseif HeraUIBridgeOperation == 33 then
        call DzFrameSetModel(HeraUIBridgeIntA, HeraUIBridgeStringA, HeraUIBridgeIntB, HeraUIBridgeIntC)
    elseif HeraUIBridgeOperation == 34 then
        call DzFrameSetAnimate(HeraUIBridgeIntA, HeraUIBridgeIntB, HeraUIBridgeBoolA)
    elseif HeraUIBridgeOperation == 35 then
        call DzFrameSetAnimateOffset(HeraUIBridgeIntA, HeraUIBridgeRealA)
    elseif HeraUIBridgeOperation == 36 then
        set HeraUIBridgeResult = JNHeraModelSetSize(HeraUIBridgeIntA, HeraUIBridgeRealA)
    elseif HeraUIBridgeOperation == 37 then
        set HeraUIBridgeResult = JNHeraModelSetSpeed(HeraUIBridgeIntA, HeraUIBridgeRealA)
    elseif HeraUIBridgeOperation == 38 then
        set HeraUIBridgeResult = JNHeraModelTransform(HeraUIBridgeIntA, HeraUIBridgeIntB, HeraUIBridgeRealA, HeraUIBridgeRealB, HeraUIBridgeRealC)
    elseif HeraUIBridgeOperation == 39 then
        set HeraUIBridgeResult = JNHeraModelSetColor(HeraUIBridgeIntA, HeraUIBridgeIntB)
    elseif HeraUIBridgeOperation == 40 then
        call DzSetUnitModel(HeraUIBridgeUnitA, HeraUIBridgeStringA)
    elseif HeraUIBridgeOperation == 41 then
        // 설치 Dz 함수는 WorldFrame의 대상 포인터를 종류 필터 없이 핸들로 변환한다.
        set HeraUIBridgeWidgetResult = DzGetUnitUnderMouse()
        if HeraUIBridgeWidgetResult != null then
            call SaveWidgetHandle(HeraUIBridgeTargetTable, 0, 0, HeraUIBridgeWidgetResult)
            if LoadItemHandle(HeraUIBridgeTargetTable, 0, 0) != null then
                set HeraUIBridgeResult = 1
            elseif LoadUnitHandle(HeraUIBridgeTargetTable, 0, 0) != null then
                set HeraUIBridgeResult = 2
            endif
            call RemoveSavedHandle(HeraUIBridgeTargetTable, 0, 0)
        endif
    elseif HeraUIBridgeOperation == 44 then
        call SetDayNightModels(HeraUIBridgeStringA, HeraUIBridgeStringB)
    elseif HeraUIBridgeOperation == 45 then
        if IsFogEnabled() then
            set HeraUIBridgeResult = 1
        endif
        if IsFogMaskEnabled() then
            set HeraUIBridgeResult = HeraUIBridgeResult + 2
        endif
        if HeraUIBridgeIntA >= 0 then
            call FogEnable(ModuloInteger(HeraUIBridgeIntA, 2) == 1)
            call FogMaskEnable(HeraUIBridgeIntA >= 2)
        endif
    elseif HeraUIBridgeOperation == 46 then
        if HeraUIBridgeBoolA then
            call ResetTerrainFog()
        else
            call SetTerrainFogEx(HeraUIBridgeIntA, HeraUIBridgeRealA, HeraUIBridgeRealB, HeraUIBridgeRealC, HeraUIBridgeRealD, HeraUIBridgeRealE, HeraUIBridgeRealF)
        endif
    elseif HeraUIBridgeOperation == 47 then
        if IsCineFilterDisplayed() then
            set HeraUIBridgeResult = 1
        endif
        if HeraUIBridgeIntA == 1 then
            call DisplayCineFilter(HeraUIBridgeBoolA)
        endif
    elseif HeraUIBridgeOperation == 48 then
        if HeraSceneTestText == 0 then
            call DzLoadToc("HeraDiagnostic.toc")
            set HeraSceneTestText = DzCreateFrameByTagName("TEXT", "HeraSceneTestText", DzGetGameUI(), "HeraDiagnosticText", 0)
        endif
        if HeraSceneTestText != 0 then
            call DzFrameClearAllPoints(HeraSceneTestText)
            call DzFrameSetAbsolutePoint(HeraSceneTestText, 0, 0.06, 0.49)
            call DzFrameSetSize(HeraSceneTestText, 0.68, 0.04)
            call DzFrameSetPriority(HeraSceneTestText, 1002)
            call DzFrameSetTextColor(HeraSceneTestText, -256)
            call DzFrameSetText(HeraSceneTestText, HeraUIBridgeStringA)
            call DzFrameShow(HeraSceneTestText, true)
        else
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 10.0, HeraUIBridgeStringA)
        endif
    elseif HeraUIBridgeOperation == 49 then
        set HeraUIBridgeResult = DzFrameGetTooltip()
    elseif HeraUIBridgeOperation == 50 then
        set HeraUIBridgeResult = DzGetMouseFocus()
    elseif HeraUIBridgeOperation == 51 then
        set HeraUIBridgeStringResult = DzFrameGetText(HeraUIBridgeIntA)
    elseif HeraUIBridgeOperation == 52 then
        call DzFrameSetFocus(HeraUIBridgeIntA, HeraUIBridgeBoolA)
    elseif HeraUIBridgeOperation == 42 then
        if DzGetClientWidth() > 0 then
            set HeraUIBridgeRealResult = I2R(DzGetMouseXRelative()) * 1024.0 / I2R(DzGetClientWidth())
        endif
    elseif HeraUIBridgeOperation == 43 then
        if DzGetClientHeight() > 0 then
            set HeraUIBridgeRealResult = 768.0 - I2R(DzGetMouseYRelative()) * 768.0 / I2R(DzGetClientHeight())
        endif
    else
        return
    endif
    set HeraUIBridgeCompleted = true
endfunction


// 모든 클라이언트에서 한 번 생성하며 로컬 UI 호출 중에는 실행 트리거를 만들지 않는다.
function HeraUIBridgeEvaluate takes nothing returns boolean
    call HeraUIBridgeDispatch()
    return HeraUIBridgeCompleted
endfunction

function HeraUIBridgeInitialize takes nothing returns nothing
    if HeraUIBridgeEvaluator == null then
        set HeraUIBridgeEvaluator = CreateTrigger()
        call TriggerAddCondition(HeraUIBridgeEvaluator, Condition(function HeraUIBridgeEvaluate))
        call DzTriggerRegisterMouseEventByCode(null, 1, 1, false, function HeraUIBridgeLeftDown)
        call DzTriggerRegisterMouseEventByCode(null, 1, 0, false, function HeraUIBridgeLeftUp)
        // 설치된 Dz DLL은 WM_RBUTTONDOWN/UP을 버튼 2로 전달한다.
        call DzTriggerRegisterMouseEventByCode(null, 2, 1, false, function HeraUIBridgeRightDown)
        call DzTriggerRegisterMouseEventByCode(null, 2, 0, false, function HeraUIBridgeRightUp)
        call DzTriggerRegisterKeyEventByCode(null, 84, 1, false, function HeraUIBridgeEmojiDown)
        call DzTriggerRegisterKeyEventByCode(null, 84, 0, false, function HeraUIBridgeEmojiUp)
    endif
endfunction
