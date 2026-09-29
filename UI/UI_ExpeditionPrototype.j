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
        private integer array BranchButtons
        private integer RerollButton
        private integer ResumeButton
        private integer HuntHUD
        private integer HuntStatus
        private integer HuntReady
        private integer LoadedSlot = -1
    endglobals

    private function Render takes nothing returns nothing
        local integer pid = GetPlayerId(GetLocalPlayer())
        local integer i = 1
        local integer id
        local integer head
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
            call ExpUISetButton(HeadButtons[i], value, not ExpReady[pid] and (i == 0 or ProtoHeadKnown[ExpKey(pid, i)]))
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
            call ExpUISetButton(LobbyReady, "출발 준비", AttackPower(pid) >= 100.0 and UnitAlive(MainUnit[pid]) and RectContainsUnit(gg_rct_Home, MainUnit[pid]) and ProtoCodexSlot[pid] == PlayerSlotNumber[pid])
        endif
        call DzFrameShow(HuntHUD, ExpPrototypeActive and ExpMember[pid] and ExpState == EXP_HUNT and not F_UpgradeOnOff[pid])
        set value = "남은 " + I2S(ExpSeconds) + "초   행동력 " + I2S(ProtoAP[pid]) + "/10   골드 " + I2S(ExpGold[pid]) + "|n사냥 " + I2S(ProtoKills[pid]) + "회 · 적 단계 " + I2S(ProtoLevel[pid]) + " · 밀도 " + I2S(ProtoDensity[pid])
        if ProtoReady[pid] then
            set value = value + "|n준비 완료 · 보스 합류 대기 중"
        endif
        call ExpUIText(HuntStatus, value)
        call ExpUISetButton(HuntReady, "준비 완료", ProtoAP[pid] == 0 and ProtoStage[pid] == 0 and not ProtoReady[pid] and UnitAlive(MainUnit[pid]))
        call ExpUIText(EventInfo, "남은 선택 시간 " + I2S(ProtoDeadline[pid]) + "초    행동력 " + I2S(ProtoAP[pid]) + "    골드 " + I2S(ExpGold[pid]))
        if ProtoStage[pid] == 1 then
            call DzFrameSetSize(EventStory, 0.59, 0.072)
            call ExpUIText(EventStory, "어떤 사건을 만나 볼까요?|n사건 하나를 선택하면 행동력 1을 사용합니다. 선택 중에는 내 공간만 정지합니다.")
        elseif ProtoStage[pid] == 2 then
            call DzFrameSetSize(EventStory, 0.59, 0.11)
            call ExpUIText(EventStory, ProtoEventName[ProtoSelected[pid]] + "|n" + ProtoEventStory[ProtoSelected[pid]])
        else
            call DzFrameSetSize(EventStory, 0.59, 0.26)
            call ExpUIText(EventStory, ProtoOutcome[pid])
        endif
        set i = 1
        loop
            exitwhen i > 4
            set id = ProtoCandidates[ExpKey(pid, i)]
            call DzFrameShow(ExpUIButtons[CandidateButtons[i]], ProtoStage[pid] == 1 and i <= ProtoChoices[pid] and id > 0)
            if id > 0 then
                set head = ProtoEventHead[id]
                set value = ProtoEventName[id]
                if head > 0 then
                    set value = value + " · " + ProtoHeadName[head]
                else
                    set value = value + " · 공통 사건"
                endif
                if ProtoEventKind[id] == 0 then
                    set value = value + " · 머리 카드"
                endif
                call ExpUISetButton(CandidateButtons[i], value, ProtoEventEligible(pid, id))
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
        set EventRoot = ExpUIRoot(9, 0.64, 0.384, 0.524, true)
        set f = ExpUIHeader(EventRoot, 0.64, "개인 사건")
        set EventInfo = ExpUILabel(EventRoot, 0.025, 0.053, 0.59, 0.024, 0.010, "")
        set EventStory = ExpUILabel(EventRoot, 0.025, 0.080, 0.59, 0.11, 0.011, "")
        set i = 1
        loop
            exitwhen i > 4
            set CandidateButtons[i] = ExpUIButton(EventRoot, 0.025, 0.159 + (i - 1) * 0.044, 0.59, 0.038, "", 2100 + i)
            set i = i + 1
        endloop
        set BranchButtons[1] = ExpUIButton(EventRoot, 0.025, 0.230, 0.59, 0.052, "", 2201)
        set BranchButtons[2] = ExpUIButton(EventRoot, 0.025, 0.295, 0.59, 0.052, "", 2202)
        set RerollButton = ExpUIButton(EventRoot, 0.025, 0.348, 0.59, 0.030, "사건 리롤", 2300)
        set ResumeButton = ExpUIButton(EventRoot, 0.025, 0.348, 0.59, 0.030, "확인 · 사냥 재개", 2400)
        set HuntHUD = DzCreateFrameByTagName("FRAME", "", DzGetGameUI(), "", FrameCount())
        call DzFrameSetSize(HuntHUD, 0.31, 0.070)
        call DzFrameSetAbsolutePoint(HuntHUD, JN_FRAMEPOINT_TOPLEFT, 0.245, 0.600)
        call DzFrameSetPriority(HuntHUD, 85)
        set f = ExpUITexture(HuntHUD, 0, 0, 0.31, 0.070, "war3mapImported\\UI_Upgrade_Panel.tga")
        set HuntStatus = ExpUILabel(HuntHUD, 0.012, 0.006, 0.286, 0.037, 0.009, "")
        set HuntReady = ExpUIButton(HuntHUD, 0.073, 0.045, 0.164, 0.021, "준비 완료", 2500)
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
