// 시험 원정의 진행 상황과 개인 선택을 표시하고 동기화 요청을 보낸다.
library UIMap initializer Init requires Expedition, FrameCount
    globals
        private integer Root
        private integer Header
        private integer Detail
        private integer Footer
        private integer Hud
        private integer OpenButton
        private integer array Buttons
        private integer array Labels
        private integer SeenRevision = -1
        private integer ShownRun = 0
        private integer ShownRevision = 0
        private integer ShownOffer = 0
        boolean array FMap_OnOff
    endglobals

    private function SaveText takes integer pid returns string
        if not PLAYER_DATA_SERVER_READY[pid] then
            return "서버 미연결 · 이번 플레이는 저장되지 않습니다."
        elseif PlayerSaveStatus[pid] == 1 then
            return "서버 저장 중"
        elseif PlayerSaveStatus[pid] == 2 then
            return "서버 저장 완료 · 가방이 가득 차면 재료 보관"
        elseif PlayerSaveStatus[pid] == 3 then
            return "저장 실패 · 재시도 또는 -save"
        endif
        return "서버 연결됨 · 승리 확정 시 저장"
    endfunction

    private function Title takes nothing returns string
        if ExpState == EXP_LOBBY or ExpState == EXP_RESULT then
            return "ARCANA  ·  시험 원정 RL-01"
        elseif ExpState == EXP_START then
            return "시작 보너스 · 한 가지 선택"
        elseif ExpState == EXP_VOTE then
            return "우솝의 정찰 · 팀 투표"
        elseif ExpState == EXP_BATTLE then
            if ExpBossBattle then
                return "대표 보스 · 파란 예고 중 헤드 카운터"
            endif
            return "일반 전투 · 8마리씩 두 무리"
        elseif ExpState == EXP_REWARD then
            return "개인 성장 보상 · 한 가지 선택"
        elseif ExpState == EXP_SHOP then
            return "개인 상점 · 완료 후 다음 전투"
        endif
        return "다음 구역 준비"
    endfunction

    private function Option takes integer pid, integer i returns string
        local integer card
        local integer price
        if i == 11 then
            if ExpState == EXP_REWARD and not ExpDone[pid] and ExpEventDeadline[pid] == 0 then
                return "후보 리롤 · " + I2S(100 * (ExpRolls[pid] + 1)) + "G"
            endif
            return ""
        elseif i >= 12 then
            if not ExpMember[pid] or ExpState == EXP_BATTLE or ExpState == EXP_MOVE or ExpState == EXP_VOTE then
                return ""
            elseif i == 12 then
                return "치명 +1 · " + I2S(ExpCritPoints[pid]) + "/30"
            elseif i == 13 then
                return "신속 +1 · " + I2S(ExpSwiftPoints[pid]) + "/30"
            endif
            return "배분 초기화"
        endif
        if ExpState == EXP_LOBBY or ExpState == EXP_RESULT then
            if i == 1 then
                if ExpReady[pid] then
                    return "준비 취소"
                endif
                return "시험 원정 준비"
            elseif i == 2 then
                return "보관 재료 수령 · 저장 재시도"
            endif
            return ""
        elseif not ExpMember[pid] or ExpDone[pid] then
            return ""
        elseif ExpState == EXP_START then
            if i == 1 then
                return "스탯 10포인트"
            elseif i == 2 then
                return "고정 치명 +200"
            elseif i == 3 then
                return "고정 신속 +200"
            elseif i == 4 then
                return "골드 +200"
            elseif i == 5 then
                return "무작위 일반 각인 +2 · 패널티 없음"
            elseif i == 6 then
                if ExpStartTwoCards[pid] then
                    return "무작위 일반 카드 2장"
                endif
                return ExpCardName(ExpStartCard[pid]) + "|n" + ExpCardText(ExpStartCard[pid])
            elseif i == 7 then
                return "무작위 희귀 카드 1장"
            endif
        elseif ExpState == EXP_VOTE then
            if i == 1 then
                return "위치를 듣고 돌파 · 적 체력 10% 감소|n승리 시 시험 보상 100G와 영구 재료"
            elseif i == 2 then
                return "이번 길을 피한다 · 무작위 물약 1회|n전투 없이 기본 성장 보상"
            endif
        elseif ExpState == EXP_REWARD then
            if ExpEventDeadline[pid] > 0 then
                if i <= 2 then
                    return ExpEventText(ExpEventCandidate[pid], i)
                elseif i == 3 then
                    return "거절한다 · 이 사건 계열은 소모됩니다."
                endif
            elseif i == 1 then
                return "스탯 5포인트 · 초과분은 1포인트당 20G"
            elseif i == 2 then
                return ArcanaText[ExpArcanaA[pid]] + " +" + I2S(ExpArcanaLevel[pid]) + " / " + ArcanaText[ExpArcanaB[pid]] + " +1|n패널티 " + ArcanaText[ExpPenalty[pid]] + " +" + I2S(ExpArcanaLevel[pid])
            elseif i == 3 then
                if ExpEventCandidate[pid] == 0 then
                    return "사건 후보 소진 · 골드 +" + I2S(ExpGradeGold(ExpEventGrade[pid]))
                endif
                return ExpEventGradeName(ExpEventGrade[pid]) + " 사건 · " + JNStringSplit(ExpEventText(ExpEventCandidate[pid], 1), " · ", 0) + "|n진입 후 두 선택지 중 결정 · 최대 20초"
            endif
        elseif ExpState == EXP_SHOP then
            if i <= 3 then
                set card = ExpShopCard[ExpKey(pid, i)]
                if ExpShopSold[ExpKey(pid, i)] then
                    return "구매 완료"
                elseif card == 0 then
                    return "품절 · 해당 등급의 미등장 카드 없음"
                endif
                set price = 250
                if ExpCardGrade(card) == 1 then
                    set price = 150
                endif
                return ExpCardName(card) + " · " + I2S(ExpShopPrice(pid, price)) + "G|n" + ExpCardText(card)
            elseif i <= 5 then
                if ExpStatBought[pid] then
                    return "고정 스탯 구매 완료"
                elseif i == 4 then
                    return "고정 치명 +100 · " + I2S(ExpShopPrice(pid, 300)) + "G"
                endif
                return "고정 신속 +100 · " + I2S(ExpShopPrice(pid, 300)) + "G"
            elseif i <= 8 then
                set price = 100
                if i == 6 then
                    set price = 75
                endif
                return JNStringSplit("회복 물약|공격 물약|무적 물약", "|", i - 6) + " · " + I2S(ExpShopPrice(pid, price)) + "G|n이번 상점 구매 " + I2S(ExpPotionBought[ExpKey(pid, i - 5)]) + "/2"
            elseif i == 9 then
                if not ExpLifeUseful then
                    return ""
                elseif ExpLifeBought or ExpLife > 90 then
                    return "팀 라이프 구매 불가 · 90 이하, 팀당 1회"
                endif
                return "팀 라이프 +10 · " + I2S(ExpShopPrice(pid, 300)) + "G"
            elseif i == 10 then
                return "구매 완료 · 대표 보스로 이동"
            endif
        endif
        return ""
    endfunction

    private function Render takes nothing returns nothing
        local integer pid = GetPlayerId(GetLocalPlayer())
        local integer i = 1
        local string value
        local string summary = ""
        if Root == 0 or pid > 3 or not PickCheck[pid] then
            return
        endif
        if SeenRevision != ExpRevision then
            set FMap_OnOff[pid] = ExpState != EXP_BATTLE and ExpState != EXP_MOVE
            set SeenRevision = ExpRevision
        endif
        set ShownRun = ExpRun
        set ShownRevision = ExpRevision
        set ShownOffer = ExpOfferVersion[pid]
        call DzFrameShow(OpenButton, true)
        call DzFrameShow(Root, FMap_OnOff[pid])
        call DzFrameSetText(Header, "|cff72d9ff" + Title() + "|r")
        call DzFrameSetText(Hud, Title() + "  |  라이프 " + I2S(ExpLife) + "  |  " + I2S(ExpSeconds) + "초  |  M 원정")
        if ExpState == EXP_BATTLE then
            call DzFrameSetText(Hud, Title() + "  |  진행 " + I2S(R2I(ExpProgress * 100)) + "%  |  " + I2S(ExpSeconds) + "초  |  M 원정")
        endif
        if ExpState == EXP_LOBBY or ExpState == EXP_RESULT then
            set summary = "시작 선택 → 전투/우회 → 보상 → 상점 → 대표 보스|n참여 중인 1~4명 모두 영웅 선택 후 마을에서 준비합니다.|n"
            set i = 0
            loop
                exitwhen i == 4
                if not ExpLeft[i] and GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                    set summary = summary + GetPlayerName(Player(i))
                    if ExpReady[i] then
                        set summary = summary + " [준비]  "
                    else
                        set summary = summary + " [대기]  "
                    endif
                endif
                set i = i + 1
            endloop
            set summary = summary + "|n" + ExpResultText[pid] + "|n" + SaveText(pid)
        else
            set summary = "개인 골드 " + I2S(ExpGold[pid]) + "G · 남은 포인트 " + I2S(ExpPoints[pid] - ExpCritPoints[pid] - ExpSwiftPoints[pid]) + " / 총 " + I2S(ExpPoints[pid]) + "/40|n치명 " + I2S(ExpCritPoints[pid] * 60 + ExpFixedCrit[pid]) + " / 신속 " + I2S(ExpSwiftPoints[pid] * 60 + ExpFixedSwift[pid]) + " · 선택 시간 " + I2S(ExpSeconds) + "초"
            if ExpEventDeadline[pid] > 0 then
                set summary = summary + "|n사건 선택 " + I2S(ExpChoiceSeconds(pid)) + "초 남음 · 시간 초과 시 거절"
            elseif ExpDone[pid] then
                set summary = summary + "|n선택 완료 · 다른 참가자를 기다립니다."
            endif
            set summary = summary + "|n카드  "
            set i = 1
            loop
                exitwhen i > 12
                if ExpCardOwned[ExpKey(pid, i)] then
                    set summary = summary + ExpCardName(i) + "  "
                endif
                set i = i + 1
            endloop
            set summary = summary + "|n각인  "
            set i = 0
            loop
                exitwhen i > 10
                if LoadInteger(ArcanaData, i, pid) > 0 then
                    set summary = summary + ArcanaText[i] + " " + I2S(LoadInteger(ArcanaData, i, pid)) + "  "
                endif
                set i = i + 1
            endloop
        endif
        call DzFrameSetText(Detail, summary)
        call DzFrameSetText(Footer, "시험판 · 대표 카드 12종/사건 9후보 · 본편 23칸과 별도 기록|nM 열기/닫기 · 스탯 배분은 비전투 중 · 영구 재료는 승리 시 확정")
        set i = 1
        loop
            exitwhen i > 14
            set value = Option(pid, i)
            call DzFrameSetText(Labels[i], value)
            call DzFrameShow(Buttons[i], value != "")
            set i = i + 1
        endloop
    endfunction

    private function Click takes nothing returns nothing
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local integer i = 1
        local integer action
        if GetLocalPlayer() != Player(pid) then
            return
        endif
        loop
            exitwhen i > 14
            if DzGetTriggerUIEventFrame() == Buttons[i] then
                set action = i
                if i >= 11 then
                    set action = i + 89
                endif
                call DzSyncData("ExpCmd", I2S(ShownRun) + "|" + I2S(ShownRevision) + "|" + I2S(ShownOffer) + "|" + I2S(action))
                return
            endif
            set i = i + 1
        endloop
    endfunction

    private function Toggle takes nothing returns nothing
        local integer pid = GetPlayerId(GetLocalPlayer())
        if pid < 4 and PickCheck[pid] then
            set FMap_OnOff[pid] = not FMap_OnOff[pid]
            call Render()
        endif
    endfunction

    function SetMapLine takes integer pid returns nothing
        if GetLocalPlayer() == Player(pid) then
            set FMap_OnOff[pid] = true
            call Render()
        endif
    endfunction

    private function Label takes integer parent, real x, real y, real width, real height, real size returns integer
        local integer frame = DzCreateFrameByTagName("TEXT", "", parent, "", FrameCount())
        call DzFrameSetPoint(frame, JN_FRAMEPOINT_TOPLEFT, parent, JN_FRAMEPOINT_TOPLEFT, x, y)
        call DzFrameSetSize(frame, width, height)
        call DzFrameSetFont(frame, "Fonts\\DFHeiMd.ttf", size, 0)
        call DzFrameSetEnable(frame, false)
        return frame
    endfunction

    private function Build takes nothing returns nothing
        local integer i = 1
        local integer background
        local real x
        local real y
        set Root = DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "", FrameCount())
        call DzFrameSetSize(Root, 0.66, 0.48)
        call DzFrameSetAbsolutePoint(Root, JN_FRAMEPOINT_CENTER, 0.40, 0.32)
        call DzFrameSetTexture(Root, "UI\\Widgets\\ToolTips\\Human\\human-tooltip-background.blp", 0)
        call DzFrameSetPriority(Root, 90)
        set Header = Label(Root, 0.02, -0.017, 0.62, 0.025, 0.014)
        set Detail = Label(Root, 0.02, -0.049, 0.62, 0.099, 0.010)
        set Footer = Label(Root, 0.02, -0.435, 0.62, 0.04, 0.009)
        loop
            exitwhen i > 14
            set x = 0.02 + I2R(ModuloInteger(i - 1, 2)) * 0.315
            set y = -0.154 - I2R((i - 1) / 2) * 0.047
            if i >= 11 then
                set x = 0.02 + I2R(i - 11) * 0.158
                set y = -0.397
            endif
            set Buttons[i] = DzCreateFrameByTagName("BUTTON", "", Root, "", FrameCount())
            call DzFrameSetPoint(Buttons[i], JN_FRAMEPOINT_TOPLEFT, Root, JN_FRAMEPOINT_TOPLEFT, x, y)
            if i < 11 then
                call DzFrameSetSize(Buttons[i], 0.305, 0.042)
            else
                call DzFrameSetSize(Buttons[i], 0.148, 0.030)
            endif
            set background = DzCreateFrameByTagName("BACKDROP", "", Buttons[i], "", FrameCount())
            call DzFrameSetAllPoints(background, Buttons[i])
            call DzFrameSetTexture(background, "UI\\Widgets\\EscMenu\\Human\\blank-background.blp", 0)
            if i < 11 then
                set Labels[i] = Label(Buttons[i], 0.007, -0.007, 0.291, 0.032, 0.009)
            else
                set Labels[i] = Label(Buttons[i], 0.007, -0.007, 0.135, 0.025, 0.009)
            endif
            call DzFrameSetScriptByCode(Buttons[i], JN_FRAMEEVENT_MOUSE_UP, function Click, false)
            set i = i + 1
        endloop
        set Hud = Label(DzGetGameUI(), 0.16, -0.03, 0.56, 0.02, 0.010)
        set OpenButton = DzCreateFrameByTagName("GLUETEXTBUTTON", "", DzGetGameUI(), "ScriptDialogButton", FrameCount())
        call DzFrameSetAbsolutePoint(OpenButton, JN_FRAMEPOINT_TOPLEFT, 0.02, 0.566)
        call DzFrameSetSize(OpenButton, 0.09, 0.029)
        call DzFrameSetText(OpenButton, "원정 [M]")
        call DzFrameSetScriptByCode(OpenButton, JN_FRAMEEVENT_MOUSE_UP, function Toggle, false)
        call DzTriggerRegisterKeyEventByCode(null, JN_OSKEY_M, 1, false, function Toggle)
        call TriggerAddAction(ExpRefresh, function Render)
        call DzFrameShow(Root, false)
        call DzFrameShow(OpenButton, false)
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterTimerEventSingle(t, 0.02)
        call TriggerAddAction(t, function Build)
        set t = null
    endfunction
endlibrary
