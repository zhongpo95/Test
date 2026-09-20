// 시작 보상과 사건의 카드 선택 및 원정 준비와 상점을 독립 화면으로 표시한다.
library UIExpeditionChoice initializer Init requires UIExpeditionCommon
    globals
        private integer ChoiceRoot
        private integer ChoiceClock
        private integer ChoiceGold
        private integer ChoiceGoldBackground
        private integer Reroll
        private integer EventRoot
        private integer EventTitle
        private integer EventDescription
        private integer EventClock
        private integer ShopRoot
        private integer ShopTitle
        private integer ShopGold
        private integer ShopClock
        private integer array ShopButtons
        private integer LobbyText
        private integer LobbyReady
        private integer ResultText
        private integer ResultReady
        private integer CardCount = 0
        private integer CardHovered = 0
        private integer array CardButton
        private integer array CardBorder
        private integer array CardIcon
        private integer array CardTitle
        private integer array CardDescription
        private integer array CardTag
        private integer array CardActionText
        private integer array CardActionBackground
        private integer array CardAction
        private integer array CardGrade
        private boolean array CardEnabled
        private integer array ChoiceCards
        private integer array EventCards
        private integer array ShopCards
    endglobals

    private function BorderPath takes integer grade returns string
        if grade == 2 then
            return "war3mapImported\\UI_Expedition_Blue.blp"
        elseif grade == 3 then
            return "war3mapImported\\UI_Expedition_Purple.blp"
        elseif grade == 4 then
            return "war3mapImported\\UI_Expedition_Colorful.blp"
        endif
        return "war3mapImported\\UI_Expedition_White.blp"
    endfunction

    private function PaintCard takes integer i returns nothing
        local integer grade = CardGrade[i]
        if not CardEnabled[i] then
            call DzFrameSetAlpha(CardButton[i], 155)
            call DzFrameSetTexture(CardActionBackground[i], "war3mapImported\\UI_Upgrade_Disabled.tga", 0)
        elseif CardHovered == i then
            if grade == 1 then
                set grade = 2
            endif
            call DzFrameSetAlpha(CardButton[i], 255)
            call DzFrameSetTexture(CardActionBackground[i], "war3mapImported\\UI_Upgrade_ActionHover.tga", 0)
        else
            call DzFrameSetAlpha(CardButton[i], 240)
            call DzFrameSetTexture(CardActionBackground[i], "war3mapImported\\UI_Upgrade_Action.tga", 0)
        endif
        call DzFrameSetTexture(CardBorder[i], BorderPath(grade), 0)
    endfunction

    private function HoverCard takes nothing returns nothing
        local integer i = 1
        loop
            exitwhen i > CardCount
            if DzGetTriggerUIEventFrame() == CardButton[i] then
                set CardHovered = i
                call PaintCard(i)
                return
            endif
            set i = i + 1
        endloop
    endfunction

    private function LeaveCard takes nothing returns nothing
        local integer old = CardHovered
        set CardHovered = 0
        if old > 0 then
            call PaintCard(old)
        endif
    endfunction

    private function ClickCard takes nothing returns nothing
        local integer i = 1
        if DzGetTriggerUIEventPlayer() != GetLocalPlayer() then
            return
        endif
        loop
            exitwhen i > CardCount
            if DzGetTriggerUIEventFrame() == CardButton[i] and CardEnabled[i] then
                call ExpUISend(CardAction[i])
                return
            endif
            set i = i + 1
        endloop
    endfunction

    private function MakeCard takes integer parent, integer action, real x, real y, real width, real height returns integer
        local integer i = CardCount + 1
        local integer face
        set CardCount = i
        set CardAction[i] = action
        set CardButton[i] = DzCreateFrameByTagName("BUTTON", "", parent, "", FrameCount())
        call DzFrameSetPoint(CardButton[i], JN_FRAMEPOINT_TOPLEFT, parent, JN_FRAMEPOINT_TOPLEFT, x, -y)
        call DzFrameSetSize(CardButton[i], width, height)
        set CardBorder[i] = ExpUITexture(CardButton[i], 0, 0, width, height, BorderPath(1))
        // 원본 테두리 안에 강화 UI의 밝은 패널을 넣는다. 이미지와 글자는 클릭을 가로채지 않는다.
        set face = ExpUITexture(CardButton[i], 0.003, 0.004, width - 0.006, height - 0.008, "war3mapImported\\UI_Upgrade_Panel.tga")
        if height < 0.23 then
            set CardIcon[i] = ExpUITexture(CardButton[i], 0.014, 0.014, 0.028, 0.034, "ReplaceableTextures\\CommandButtons\\BTNTome.blp")
            set CardTitle[i] = ExpUILabel(CardButton[i], 0.051, 0.016, width - 0.060, 0.035, 0.010, "")
            set CardTag[i] = ExpUILabel(CardButton[i], 0.051, 0.053, width - 0.060, 0.016, 0.008, "")
            set CardDescription[i] = ExpUILabel(CardButton[i], 0.013, 0.077, width - 0.026, height - 0.117, 0.009, "")
        else
            set CardIcon[i] = ExpUITexture(CardButton[i], (width - 0.035) * 0.5, 0.018, 0.035, 0.044, "ReplaceableTextures\\CommandButtons\\BTNTome.blp")
            set CardTag[i] = ExpUILabel(CardButton[i], 0.009, 0.075, width - 0.018, 0.016, 0.008, "")
            set CardTitle[i] = ExpUILabel(CardButton[i], 0.009, 0.096, width - 0.018, 0.044, 0.010, "")
            set CardDescription[i] = ExpUILabel(CardButton[i], 0.009, 0.143, width - 0.018, height - 0.186, 0.009, "")
        endif
        set CardActionBackground[i] = ExpUITexture(CardButton[i], 0.008, height - 0.034, width - 0.016, 0.025, "war3mapImported\\UI_Upgrade_Action.tga")
        set CardActionText[i] = ExpUILabel(CardButton[i], 0.015, height - 0.028, width - 0.030, 0.020, 0.009, "")
        call DzFrameSetScriptByCode(CardButton[i], JN_FRAMEEVENT_MOUSE_ENTER, function HoverCard, false)
        call DzFrameSetScriptByCode(CardButton[i], JN_FRAMEEVENT_MOUSE_LEAVE, function LeaveCard, false)
        call DzFrameSetScriptByCode(CardButton[i], JN_FRAMEEVENT_MOUSE_UP, function ClickCard, false)
        return i
    endfunction

    private function SetCard takes integer i, string title, string description, string tag, string icon, integer grade, string action, boolean enabled returns nothing
        set CardGrade[i] = grade
        set CardEnabled[i] = enabled
        call DzFrameSetEnable(CardButton[i], enabled)
        call ExpUIText(CardTitle[i], title)
        call ExpUIText(CardDescription[i], description)
        call ExpUIText(CardTag[i], tag)
        call DzFrameSetTexture(CardIcon[i], "ReplaceableTextures\\CommandButtons\\" + icon + ".blp", 0)
        call DzFrameSetText(CardActionText[i], "|cffffffff" + action + "|r")
        call PaintCard(i)
    endfunction

    private function RenderChoice takes integer pid returns nothing
        local integer price = 100 * (ExpRolls[pid] + 1)
        call ExpUIText(ChoiceClock, I2S(ExpSeconds) + "초")
        call ExpUIText(ChoiceGold, I2S(ExpGold[pid]) + " G")
        call DzFrameShow(ExpUIButtons[Reroll], ExpState == EXP_REWARD)
        call DzFrameShow(ChoiceGold, ExpState == EXP_REWARD)
        call DzFrameShow(ChoiceGoldBackground, ExpState == EXP_REWARD)
        call ExpUISetButton(Reroll, "다시 뽑기  " + I2S(price) + " G", ExpGold[pid] >= price)
        if ExpState == EXP_START then
            call SetCard(ChoiceCards[1], "스탯 10포인트", "원하는 능력치에 배분할 포인트를 얻습니다.", "스탯", "BTNManual", 1, "선택", true)
            call SetCard(ChoiceCards[2], "무작위 능력치 +200", "치명 또는 신속 중 하나가 같은 확률로 200 증가합니다.|n포인트 소모 없음", "고정 능력치", "BTNClawsOfAttack", 1, "선택", true)
            call SetCard(ChoiceCards[3], "일반 각인 +2", "무작위 일반 각인을 2레벨 얻습니다.|n패널티 없음", "각인", "BTNPeriapt", 1, "선택", true)
            if ExpStartTwoCards[pid] then
                call SetCard(ChoiceCards[4], "일반 카드 2장", "무작위 일반 카드를 2장 얻습니다.", "일반 카드", "BTNTome", 1, "선택", true)
            else
                call SetCard(ChoiceCards[4], ExpCardName(ExpStartCard[pid]), ExpCardText(ExpStartCard[pid]), "일반 카드", "BTNTome", 1, "선택", true)
            endif
            call SetCard(ChoiceCards[5], "희귀 카드 1장", "무작위 희귀 카드를 1장 얻습니다.", "희귀 카드", "BTNTomeOfRetraining", 2, "선택", true)
            call SetCard(ChoiceCards[6], "골드 +200", "이번 원정의 상점에서 사용할 골드를 얻습니다.", "골드", "BTNChestOfGold", 1, "선택", true)
        endif
    endfunction

    private function SaveStatus takes integer pid returns string
        if not PLAYER_DATA_SERVER_READY[pid] then
            return "서버 미연결 · 영구 보상을 저장할 수 없습니다."
        elseif PlayerSaveStatus[pid] == 1 then
            return "저장 중"
        elseif PlayerSaveStatus[pid] == 3 then
            return "저장 실패 · 재시도해 주세요."
        elseif PlayerSaveStatus[pid] == 2 then
            return "저장 완료"
        endif
        return "서버 연결됨"
    endfunction

    private function Render takes nothing returns nothing
        local integer pid = GetPlayerId(GetLocalPlayer())
        local integer i = 0
        local integer card
        local integer price
        local string summary = ""
        local string name
        local boolean enabled
        if ChoiceRoot == 0 or pid > 3 or not PickCheck[pid] then
            return
        endif
        if ExpState == EXP_LOBBY or ExpState == EXP_RESULT then
            loop
                exitwhen i == 4
                if not ExpLeft[i] and GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                    set summary = summary + GetPlayerName(Player(i))
                    if ExpReady[i] then
                        set summary = summary + "   |cff2699be준비 완료|r|n"
                    else
                        set summary = summary + "   준비 대기|n"
                    endif
                endif
                set i = i + 1
            endloop
            call ExpUIText(LobbyText, summary + "|n" + SaveStatus(pid))
            call ExpUIText(ResultText, ExpResultText[pid] + "|n|n" + summary + "|n" + SaveStatus(pid))
            if ExpReady[pid] then
                call ExpUISetButton(LobbyReady, "준비 취소", true)
                call ExpUISetButton(ResultReady, "준비 취소", true)
            else
                call ExpUISetButton(LobbyReady, "원정 준비", true)
                call ExpUISetButton(ResultReady, "다시 준비", true)
            endif
        elseif ExpState == EXP_START then
            call RenderChoice(pid)
        elseif ExpState == EXP_REWARD and ExpEventDeadline[pid] == 0 then
            // 보상은 가로로 펼친 세 장만 표시한다.
            call RenderChoice(pid)
            call SetCard(ChoiceCards[7], "스탯 5포인트", "스탯 배분에 사용할 포인트를 얻습니다.|n|n40포인트 초과분은 포인트당 20골드로 받습니다.", "스탯", "BTNManual", 1, "선택", true)
            call SetCard(ChoiceCards[8], "각인 획득", ArcanaText[ExpArcanaA[pid]] + " +" + I2S(ExpArcanaLevel[pid]) + "|n" + ArcanaText[ExpArcanaB[pid]] + " +1|n|n|cff98284d" + ArcanaText[ExpPenalty[pid]] + " +" + I2S(ExpArcanaLevel[pid]) + "|r", "각인", "BTNPeriapt", 2, "선택", true)
            if ExpEventCandidate[pid] == 0 then
                call SetCard(ChoiceCards[9], "골드 획득", I2S(ExpGradeGold(ExpEventGrade[pid])) + "골드를 얻습니다.", ExpEventGradeName(ExpEventGrade[pid]), "BTNChestOfGold", ExpEventGrade[pid], "선택", true)
            else
                set name = JNStringSplit(ExpEventText(ExpEventCandidate[pid], 1), " · ", 0)
                call SetCard(ChoiceCards[9], name, "사건에 진입한 뒤 제시되는 보상 중 하나를 선택합니다.", ExpEventGradeName(ExpEventGrade[pid]) + " 사건", "BTNScroll", ExpEventGrade[pid], "진입", true)
            endif
        endif
        set i = 1
        loop
            exitwhen i > 9
            call DzFrameShow(CardButton[ChoiceCards[i]], (ExpState == EXP_START and i <= 6) or (ExpState == EXP_REWARD and i >= 7))
            set i = i + 1
        endloop
        if ExpState == EXP_VOTE then
            call ExpUIText(EventTitle, "우솝의 정찰")
            call ExpUIText(EventDescription, "우솝이 앞길의 적 위치를 알려주었습니다. 파티가 이동할 길을 고릅니다.")
            call ExpUIText(EventClock, I2S(ExpSeconds) + "초")
            call SetCard(EventCards[1], "정면 돌파", "적 체력 10% 감소|n승리 시 전투 보상 획득", "팀 투표", "BTNSteelMelee", 2, "투표", true)
            call SetCard(EventCards[2], "우회", "전투 없이 성장 보상 획득|n무작위 물약 1회 충전", "팀 투표", "BTNBootsOfSpeed", 1, "투표", true)
            call DzFrameShow(CardButton[EventCards[3]], false)
        elseif ExpState == EXP_REWARD and ExpEventDeadline[pid] > 0 then
            call ExpUIText(EventTitle, JNStringSplit(ExpEventText(ExpEventCandidate[pid], 1), " · ", 0))
            call ExpUIText(EventDescription, "받을 보상을 선택합니다. 거절하면 이번 사건을 떠납니다.")
            call ExpUIText(EventClock, I2S(ExpChoiceSeconds(pid)) + "초")
            call SetCard(EventCards[1], "첫 번째 보상", ExpEventText(ExpEventCandidate[pid], 1), "사건", "BTNTome", ExpEventGrade[pid], "선택", true)
            call SetCard(EventCards[2], "두 번째 보상", ExpEventText(ExpEventCandidate[pid], 2), "사건", "BTNTome", ExpEventGrade[pid], "선택", true)
            call SetCard(EventCards[3], "떠나기", "보상을 받지 않고 떠납니다.|n이 사건은 다시 등장하지 않습니다.", "거절", "BTNBootsOfSpeed", 1, "거절", true)
            call DzFrameShow(CardButton[EventCards[3]], true)
        endif
        if ExpState == EXP_SHOP then
            call ExpUIText(ShopGold, "보유 골드  |cff07516b" + I2S(ExpGold[pid]) + " G|r")
            call ExpUIText(ShopClock, I2S(ExpSeconds) + "초")
            set i = 1
            loop
                exitwhen i > 3
                set card = ExpShopCard[ExpKey(pid, i)]
                set price = 250
                if ExpCardGrade(card) == 1 then
                    set price = 150
                endif
                set price = ExpShopPrice(pid, price)
                set enabled = card != 0 and not ExpShopSold[ExpKey(pid, i)] and ExpGold[pid] >= price
                set name = I2S(price) + " G"
                if card == 0 then
                    set name = "품절"
                elseif ExpShopSold[ExpKey(pid, i)] then
                    set name = "구매 완료"
                elseif ExpGold[pid] < price then
                    set name = name + " · 골드 부족"
                endif
                call SetCard(ShopCards[i], ExpCardName(card), ExpCardText(card), "카드", "BTNTome", ExpCardGrade(card), name, enabled)
                set i = i + 1
            endloop
            set price = ExpShopPrice(pid, 300)
            set name = I2S(price) + " G"
            if ExpStatBought[pid] then
                set name = "능력치 구매 완료"
            elseif ExpGold[pid] < price then
                set name = name + " · 부족"
            endif
            call ExpUISetButton(ShopButtons[4], "치명 +100|n" + name, not ExpStatBought[pid] and ExpGold[pid] >= price)
            call ExpUISetButton(ShopButtons[5], "신속 +100|n" + name, not ExpStatBought[pid] and ExpGold[pid] >= price)
            set i = 6
            loop
                exitwhen i > 8
                set price = 100
                if i == 6 then
                    set price = 75
                endif
                set price = ExpShopPrice(pid, price)
                set name = JNStringSplit("회복|공격|무적", "|", i - 6) + " 물약 " + I2S(ExpPotionBought[ExpKey(pid, i - 5)]) + "/2|n"
                if ExpPotionBought[ExpKey(pid, i - 5)] >= 2 then
                    set name = name + "구매 한도 도달"
                else
                    set name = name + I2S(price) + " G"
                    if ExpGold[pid] < price then
                        set name = name + " · 부족"
                    endif
                endif
                call ExpUISetButton(ShopButtons[i], name, ExpPotionBought[ExpKey(pid, i - 5)] < 2 and ExpGold[pid] >= price)
                set i = i + 1
            endloop
            call DzFrameShow(ExpUIButtons[ShopButtons[9]], ExpLifeUseful)
            call ExpUISetButton(ShopButtons[9], "라이프 +10  " + I2S(ExpShopPrice(pid, 300)) + " G", not ExpLifeBought and ExpLife <= 90 and ExpGold[pid] >= ExpShopPrice(pid, 300))
        endif
    endfunction

    private function Build takes nothing returns nothing
        local integer i = 1
        local integer f
        local integer root
        set ChoiceRoot = ExpUIRoot(EXP_UI_CHOICE, 0.78, 0.375, 0.523, false)
        set f = ExpUITexture(ChoiceRoot, 0.625, 0, 0.079, 0.028, "war3mapImported\\UI_Upgrade_Header.tga")
        set ChoiceClock = ExpUILabel(ChoiceRoot, 0.643, 0.007, 0.06, 0.020, 0.011, "")
        set f = ExpUIPanelToggle(ChoiceRoot, 0.710, 0, 0.053, 0.028)
        set ChoiceGoldBackground = ExpUITexture(ChoiceRoot, 0.255, 0.340, 0.14, 0.030, "war3mapImported\\UI_Upgrade_Header.tga")
        set ChoiceGold = ExpUILabel(ChoiceRoot, 0.27, 0.347, 0.12, 0.022, 0.011, "")
        set Reroll = ExpUIButton(ChoiceRoot, 0.43, 0.340, 0.210, 0.030, "다시 뽑기", 100)
        loop
            exitwhen i > 6
            set ChoiceCards[i] = MakeCard(ChoiceRoot, i, 0.017 + (i - 1) * 0.126, 0.038, 0.116, 0.292)
            set i = i + 1
        endloop
        set i = 1
        loop
            exitwhen i > 3
            set ChoiceCards[i + 6] = MakeCard(ChoiceRoot, i, 0.048 + (i - 1) * 0.233, 0.038, 0.218, 0.292)
            set i = i + 1
        endloop
        set EventRoot = ExpUIRoot(EXP_UI_EVENT, 0.70, 0.375, 0.523, true)
        set EventTitle = ExpUIHeader(EventRoot, 0.70, "")
        set EventDescription = ExpUILabel(EventRoot, 0.018, 0.055, 0.65, 0.040, 0.010, "")
        set EventClock = ExpUILabel(EventRoot, 0.615, 0.349, 0.07, 0.023, 0.011, "")
        set i = 1
        loop
            exitwhen i > 3
            set EventCards[i] = MakeCard(EventRoot, i, 0.018 + (i - 1) * 0.225, 0.110, 0.213, 0.224)
            set i = i + 1
        endloop
        set ShopRoot = ExpUIRoot(EXP_UI_SHOP, 0.72, 0.375, 0.523, true)
        set ShopTitle = ExpUIHeader(ShopRoot, 0.72, "상점")
        call DzFrameSetSize(ShopTitle, 0.30, 0.026)
        set f = ExpUITexture(ShopRoot, 0.38, 0.007, 0.268, 0.030, "war3mapImported\\UI_Upgrade_Card.tga")
        set ShopGold = ExpUILabel(ShopRoot, 0.39, 0.014, 0.25, 0.022, 0.012, "")
        set ShopClock = ExpUILabel(ShopRoot, 0.45, 0.339, 0.070, 0.023, 0.011, "")
        set i = 1
        loop
            exitwhen i > 3
            set ShopCards[i] = MakeCard(ShopRoot, i, 0.018 + (i - 1) * 0.23, 0.054, 0.224, 0.198)
            set i = i + 1
        endloop
        set i = 4
        loop
            exitwhen i > 8
            set ShopButtons[i] = ExpUIButton(ShopRoot, 0.018 + (i - 4) * 0.14, 0.268, 0.126, 0.046, "", i)
            set i = i + 1
        endloop
        set ShopButtons[9] = ExpUIButton(ShopRoot, 0.018, 0.331, 0.23, 0.028, "", 9)
        set f = ExpUIButton(ShopRoot, 0.548, 0.331, 0.150, 0.028, "정비 완료", 10)
        set root = ExpUIRoot(EXP_UI_LOBBY, 0.46, 0.245, 0.465, true)
        set f = ExpUIHeader(root, 0.46, "원정 준비")
        set LobbyText = ExpUILabel(root, 0.025, 0.065, 0.41, 0.118, 0.011, "")
        set LobbyReady = ExpUIButton(root, 0.025, 0.198, 0.175, 0.030, "원정 준비", 1)
        set f = ExpUIButton(root, 0.235, 0.198, 0.200, 0.030, "보관 보상 수령 · 저장", 2)
        set root = ExpUIRoot(EXP_UI_RESULT, 0.46, 0.295, 0.485, true)
        set f = ExpUIHeader(root, 0.46, "원정 결과")
        set ResultText = ExpUILabel(root, 0.025, 0.061, 0.41, 0.17, 0.011, "")
        set ResultReady = ExpUIButton(root, 0.025, 0.249, 0.175, 0.030, "다시 준비", 1)
        set f = ExpUIButton(root, 0.235, 0.249, 0.200, 0.030, "보관 보상 수령 · 저장", 2)
        call TriggerAddAction(ExpRefresh, function Render)
        call TriggerExecute(ExpRefresh)
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterTimerEventSingle(t, 0.03)
        call TriggerAddAction(t, function Build)
        set t = null
    endfunction
endlibrary
