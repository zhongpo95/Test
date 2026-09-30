// 개인 사냥 준비, 머리 도감, 사건 후보와 준비 완료 버튼을 표시한다.
library UIExpeditionPrototype initializer Init requires UIExpeditionCommon, ExpeditionPrototype
    globals
        private integer LobbyRoot
        private integer LobbyInfo
        private integer LobbyReady
        private integer array HeadButtons
        private integer EventRoot
        private integer EventInfo
        private integer EventStory
        private integer array CandidateButtons
        private integer array CandidateRegion
        private integer array CandidateTitle
        private integer array CandidateIcon
        private integer array CandidateIntro
        private integer array CandidateBonus
        private integer array CandidateFooter
        private integer array BranchButtons
        private integer RerollButton
        private integer ResumeButton
        private integer HuntHUD
        private integer HuntStatus
        private integer HuntReady
        private integer LoadedSlot = -1
    endglobals

    private function CoverLabel takes integer parent, real size returns integer
        local integer f = ExpUILabel(parent, 0, 0, 0.279, 0.020, size, "")
        call JNFrameSetTextAlignment(f, JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_LEFT)
        return f
    endfunction

    private function PlaceCoverPart takes integer frame, integer parent, real x, real y, real width, real height returns nothing
        call DzFrameClearAllPoints(frame)
        call DzFrameSetPoint(frame, JN_FRAMEPOINT_TOPLEFT, parent, JN_FRAMEPOINT_TOPLEFT, x, -y)
        call DzFrameSetSize(frame, width, height)
    endfunction

    private function RenderCover takes integer pid, integer i, integer id returns nothing
        local integer cover = ExpUIButtons[CandidateButtons[i]]
        local integer head = ProtoEventHead[id]
        local boolean compact = ProtoChoices[pid] > 2
        local boolean opening = ProtoEventKind[id] == 0
        local real x = 0.025
        local real y = 0.104
        local real height = 0.246
        local string tag = "공통 사건"
        local string action = "사건 만나기"
        if i == 2 or i == 4 then
            set x = 0.348
        endif
        if compact then
            set height = 0.124
            if i > 2 then
                set y = 0.232
            endif
        endif
        call PlaceCoverPart(cover, EventRoot, x, y, 0.307, height)
        call ExpUIResizeCover(CandidateButtons[i], height)
        call PlaceCoverPart(CandidateFooter[i], cover, 0.007, height - 0.028, 0.293, 0.022)
        call PlaceCoverPart(ExpUIButtonLabels[CandidateButtons[i]], cover, 0.018, height - 0.025, 0.271, 0.018)
        if compact then
            call PlaceCoverPart(CandidateIcon[i], cover, 0.013, 0.012, 0.040, 0.051)
            call PlaceCoverPart(CandidateRegion[i], cover, 0.065, 0.010, 0.229, 0.013)
            call PlaceCoverPart(CandidateTitle[i], cover, 0.065, 0.025, 0.229, 0.024)
            if opening then
                call PlaceCoverPart(CandidateIcon[i], cover, 0.013, 0.012, 0.030, 0.038)
                call PlaceCoverPart(CandidateIntro[i], cover, 0.013, 0.052, 0.281, 0.017)
                call PlaceCoverPart(CandidateBonus[i], cover, 0.013, 0.070, 0.281, 0.024)
            else
                call PlaceCoverPart(CandidateIntro[i], cover, 0.065, 0.051, 0.229, 0.041)
            endif
            call DzFrameSetFont(CandidateIntro[i], "Fonts\\DFHeiMd.ttf", 0.008, 0)
            call DzFrameSetFont(CandidateBonus[i], "Fonts\\DFHeiMd.ttf", 0.0075, 0)
        else
            call PlaceCoverPart(CandidateIcon[i], cover, 0.018, 0.052, 0.070, 0.088)
            call PlaceCoverPart(CandidateRegion[i], cover, 0.018, 0.015, 0.271, 0.016)
            call PlaceCoverPart(CandidateTitle[i], cover, 0.104, 0.059, 0.185, 0.057)
            if opening then
                call PlaceCoverPart(CandidateIntro[i], cover, 0.018, 0.148, 0.271, 0.026)
                call PlaceCoverPart(CandidateBonus[i], cover, 0.018, 0.176, 0.271, 0.040)
            else
                call PlaceCoverPart(CandidateIntro[i], cover, 0.018, 0.148, 0.271, 0.067)
            endif
            call DzFrameSetFont(CandidateIntro[i], "Fonts\\DFHeiMd.ttf", 0.010, 0)
            call DzFrameSetFont(CandidateBonus[i], "Fonts\\DFHeiMd.ttf", 0.009, 0)
        endif
        if head > 0 then
            set tag = ProtoHeadName[head]
        endif
        if opening then
            set tag = "지역 개방 · " + tag
            set action = "머리 카드 획득"
            call ExpUIText(CandidateBonus[i], "머리 카드 · 관련 사건 개방 · 피해 +5%|n" + ProtoEventCardPreview(pid, ProtoHeadEntryCard[head]))
        elseif ProtoEventRequired[id] > 0 then
            set tag = tag + " · 이어지는 사건"
        endif
        call ExpUIText(CandidateRegion[i], tag)
        call ExpUIText(CandidateTitle[i], ProtoEventName[id])
        call ExpUIText(CandidateIntro[i], ProtoEventIntro[id])
        call DzFrameSetTexture(CandidateIcon[i], ProtoEventIcon[id], 0)
        call DzFrameShow(CandidateBonus[i], opening)
        if not ProtoEventEligible(pid, id) then
            set action = "선택 불가 · 후보 갱신 대기"
        endif
        call ExpUISetButton(CandidateButtons[i], action, ProtoEventEligible(pid, id))
    endfunction

    private function Render takes nothing returns nothing
        local integer pid = GetPlayerId(GetLocalPlayer())
        local integer i = 1
        local integer id
        local boolean lobby
        local string value
        local string packet
        if LobbyRoot == 0 or pid > 3 or not PickCheck[pid] then
            return
        endif
        set lobby = ExpState == EXP_LOBBY or ExpState == EXP_RESULT
        if lobby and LoadedSlot != PlayerSlotNumber[pid] then
            set LoadedSlot = PlayerSlotNumber[pid]
            set packet = I2S(PlayerSlotNumber[pid])
            loop
                exitwhen i > 3
                set packet = packet + "|" + StashLoad(PLAYER_DATA[pid], "원정.머리도감." + I2S(i), "0")
                set i = i + 1
            endloop
            call DzSyncData("ProtoCodex", packet)
        endif
        set i = 0
        loop
            exitwhen i > 3
            if i == 0 then
                set value = "머리 카드 없이 출발"
            else
                set value = ProtoHeadName[i]
                if not ProtoHeadKnown[ExpKey(pid, i)] then
                    set value = value + " · 미발견"
                endif
            endif
            if ProtoStartHead[pid] == i then
                set value = "선택 · " + value
            endif
            call ExpUISetButton(HeadButtons[i], value, not ExpReady[pid] and (i == 0 or (ProtoCodexSlot[pid] == PlayerSlotNumber[pid] and ProtoHeadKnown[ExpKey(pid, i)])))
            set i = i + 1
        endloop
        set value = "개인 사냥 10분 · 행동력 10 · 사냥 처치당 기본 10골드|n사건 후보 2개 · 리롤 500골드부터 +100골드|n발견한 머리 카드 0~1장을 들고 출발합니다.|n"
        if AttackPower(pid) < 100.0 then
            set value = value + "마을에서 첫 계승으로 공격력 100의 T2 무기를 준비해 주세요."
        else
            set value = value + "개인 사냥 후 보스 구역에서 파티가 합류합니다."
        endif
        set value = value + "|n"
        set i = 0
        loop
            exitwhen i == 4
            if not ExpLeft[i] and GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                set value = value + GetPlayerName(Player(i))
                if ExpReady[i] then
                    set value = value + " 준비완료   "
                else
                    set value = value + " 준비중   "
                endif
            endif
            set i = i + 1
        endloop
        call ExpUIText(LobbyInfo, value)
        if ExpReady[pid] then
            call ExpUISetButton(LobbyReady, "출발 준비 취소", true)
        else
            call ExpUISetButton(LobbyReady, "출발 준비", AttackPower(pid) >= 100.0 and UnitAlive(MainUnit[pid]) and RectContainsUnit(gg_rct_Home, MainUnit[pid]) and PlayerSlotNumber[pid] > 0 and ProtoStartHeadReady(pid))
        endif
        call DzFrameShow(HuntHUD, ExpPrototypeActive and ExpMember[pid] and ExpState == EXP_HUNT and not F_UpgradeOnOff[pid])
        set value = "남은 " + I2S(ExpSeconds) + "초   행동력 " + I2S(ProtoAP[pid]) + "/10   골드 " + I2S(ExpGold[pid]) + "|n사냥 " + I2S(ProtoKills[pid]) + "회 · 적 단계 " + I2S(ProtoLevel[pid]) + " · 동시 몬스터 " + I2S(ProtoDensity[pid]) + "마리|n몬스터 체력 " + I2S(R2I(300.0 * (1.0 + 0.30 * (ProtoLevel[pid] - 1)))) + " · 기본 공격 피해 최대 체력의 " + R2SW(4.0 * (1.0 + 0.25 * (ProtoLevel[pid] - 1)), 0, 1) + "%"
        if ProtoReady[pid] then
            set value = "보스 합류 대기 · " + value
        endif
        call ExpUIText(HuntStatus, value)
        call ExpUISetButton(HuntReady, "준비 완료", ProtoAP[pid] == 0 and ProtoStage[pid] == 0 and not ProtoReady[pid] and UnitAlive(MainUnit[pid]))
        call ExpUIText(EventInfo, "남은 선택 시간 " + I2S(ProtoDeadline[pid]) + "초    행동력 " + I2S(ProtoAP[pid]) + "    골드 " + I2S(ExpGold[pid]))
        if ProtoStage[pid] == 1 then
            call DzFrameSetSize(EventStory, 0.63, 0.016)
            call ExpUIText(EventStory, "어떤 사건을 만나 볼까요?  ·  선택 시 행동력 1 소모  ·  내 공간만 정지합니다.")
        elseif ProtoStage[pid] == 2 then
            call DzFrameSetSize(EventStory, 0.63, 0.145)
            call ExpUIText(EventStory, ProtoEventName[ProtoSelected[pid]] + "|n" + ProtoEventStory[ProtoSelected[pid]])
        else
            call DzFrameSetSize(EventStory, 0.63, 0.265)
            call ExpUIText(EventStory, ProtoOutcome[pid])
        endif
        set i = 1
        loop
            exitwhen i > 4
            set id = ProtoCandidates[ExpKey(pid, i)]
            call DzFrameShow(ExpUIButtons[CandidateButtons[i]], ProtoStage[pid] == 1 and i <= ProtoChoices[pid] and id > 0)
            if ProtoStage[pid] == 1 and i <= ProtoChoices[pid] and id > 0 then
                call RenderCover(pid, i, id)
            endif
            set i = i + 1
        endloop
        set i = 1
        loop
            exitwhen i > 2
            call DzFrameShow(ExpUIButtons[BranchButtons[i]], ProtoStage[pid] == 2)
            if ProtoStage[pid] == 2 then
                call ExpUISetButton(BranchButtons[i], ProtoBranchText(pid, i), ProtoBranchAllowed(pid, i))
            endif
            set i = i + 1
        endloop
        call DzFrameShow(ExpUIButtons[RerollButton], ProtoStage[pid] == 1)
        call ExpUISetButton(RerollButton, "사건 리롤 · " + I2S(500 + ProtoRerolls[pid] * 100) + "골드", ExpGold[pid] >= 500 + ProtoRerolls[pid] * 100)
        call DzFrameShow(ExpUIButtons[ResumeButton], ProtoStage[pid] == 3)
    endfunction

    private function Build takes nothing returns nothing
        local integer f
        local integer i = 0
        set LobbyRoot = ExpUIRoot(8, 0.54, 0.35, 0.50, true)
        set f = ExpUIHeader(LobbyRoot, 0.54, "개인 사냥 프로토타입")
        set LobbyInfo = ExpUILabel(LobbyRoot, 0.025, 0.060, 0.49, 0.106, 0.010, "")
        loop
            exitwhen i > 3
            set HeadButtons[i] = ExpUIButton(LobbyRoot, 0.025, 0.174 + i * 0.032, 0.49, 0.027, "", 2010 + i)
            set i = i + 1
        endloop
        set LobbyReady = ExpUIButton(LobbyRoot, 0.025, 0.309, 0.49, 0.029, "출발 준비", 2001)
        set EventRoot = ExpUIRoot(9, 0.68, 0.400, 0.524, true)
        set f = ExpUIHeader(EventRoot, 0.68, "개인 사건")
        set EventInfo = ExpUILabel(EventRoot, 0.025, 0.053, 0.63, 0.024, 0.010, "")
        set EventStory = ExpUILabel(EventRoot, 0.025, 0.080, 0.63, 0.145, 0.011, "")
        set i = 1
        loop
            exitwhen i > 4
            set CandidateButtons[i] = ExpUICoverButton(EventRoot, 2100 + i)
            set f = ExpUIButtons[CandidateButtons[i]]
            set CandidateRegion[i] = CoverLabel(f, 0.008)
            set CandidateTitle[i] = CoverLabel(f, 0.0105)
            set CandidateIcon[i] = ExpUITexture(f, 0, 0, 0.070, 0.088, "ReplaceableTextures\\CommandButtons\\BTNTome.blp")
            set CandidateIntro[i] = CoverLabel(f, 0.010)
            set CandidateBonus[i] = CoverLabel(f, 0.009)
            set CandidateFooter[i] = ExpUITexture(f, 0, 0, 0.293, 0.022, "war3mapImported\\UI_Upgrade_Header.tga")
            call DzFrameSetPriority(ExpUIButtonLabels[CandidateButtons[i]], 1)
            // 모든 장식은 표지 버튼의 자식이며 글자는 클릭을 가로채지 않는다.
            call JNFrameSetTextAlignment(ExpUIButtonLabels[CandidateButtons[i]], JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_LEFT)
            set i = i + 1
        endloop
        set BranchButtons[1] = ExpUIButton(EventRoot, 0.025, 0.232, 0.63, 0.062, "", 2201)
        set BranchButtons[2] = ExpUIButton(EventRoot, 0.025, 0.299, 0.63, 0.062, "", 2202)
        set RerollButton = ExpUIButton(EventRoot, 0.025, 0.365, 0.63, 0.030, "사건 리롤", 2300)
        set ResumeButton = ExpUIButton(EventRoot, 0.025, 0.365, 0.63, 0.030, "확인 · 사냥 재개", 2400)
        set HuntHUD = DzCreateFrameByTagName("FRAME", "", DzGetGameUI(), "", FrameCount())
        call DzFrameSetSize(HuntHUD, 0.40, 0.074)
        call DzFrameSetAbsolutePoint(HuntHUD, JN_FRAMEPOINT_TOPLEFT, 0.245, 0.600)
        call DzFrameSetPriority(HuntHUD, 85)
        set f = ExpUITexture(HuntHUD, 0, 0, 0.40, 0.074, "war3mapImported\\UI_Upgrade_Panel.tga")
        set HuntStatus = ExpUILabel(HuntHUD, 0.012, 0.006, 0.376, 0.044, 0.0085, "")
        set HuntReady = ExpUIButton(HuntHUD, 0.125, 0.052, 0.164, 0.020, "준비 완료", 2500)
        call DzFrameShow(HuntHUD, false)
        call TriggerAddAction(ExpRefresh, function Render)
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterTimerEventSingle(t, 0.04)
        call TriggerAddAction(t, function Build)
        set t = null
    endfunction
endlibrary
