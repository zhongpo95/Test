// 개인 사냥 준비, 머리 도감, 사건 후보와 준비 완료 버튼을 표시한다.
library UIExpeditionPrototype initializer Init requires UIExpeditionCommon, ExpeditionPrototype, StoryLineLayout
    globals
        private constant string PAPER_TITLE = "|cff30382f"
        private constant string PAPER_BODY = "|cff485047"
        private constant string PAPER_META = "|cff626b5e"
        private constant string PAPER_GAIN = "|cff28633f"
        private constant string PAPER_COST = "|cff9d4938"
        private constant string PAPER_GOLD = "|cff875b21"
        private integer LobbyRoot
        private integer LobbyInfo
        private integer LobbyLoadout
        private integer LobbyParty
        private integer LobbyReady
        private integer EventRoot
        private integer EventTitle
        private integer EventInfo
        private integer EventStory
        private integer StoryPanel
        private integer StoryRegion
        private integer StoryTitle
        private integer StoryIcon
        private string StoryCached = ""
        private real StoryCachedTop = -1.0
        private real StoryCachedAspect = 0.0
        // 사건 본문 자동 줄바꿈 행간. 기본 TEXT의 행간은 글자 크기와 같은 약 0.011이다.
        private constant real STORY_LINE_GAP = 0.014
        // 4:3 화면에서 한글 한 글자 폭 / 글자 크기. 와이드 화면은 화면 비율로 나눠 보정한다.
        private constant real STORY_EM_43 = 1.03
        private integer array StoryLineFrames
        private integer LineTestRoot
        private boolean LineTestVisible = false
        private integer PitchRoot
        private integer PitchOriginal
        private integer PitchRight
        private integer PitchInfo
        private integer array PitchLines
        private boolean PitchVisible = false
        private real PitchGap = 0.014
        private integer PitchEvent = 534
        private integer StoryText
        private integer OutcomePanel
        private integer OutcomeHeading
        private integer OutcomeText
        private integer array CandidateButtons
        private integer array CandidateRegion
        private integer array CandidateTitle
        private integer array CandidateIcon
        private integer array CandidateIntro
        private integer array CandidateBonus
        private integer array CandidateFooter
        private integer EntryTooltip
        private integer EntryTooltipIcon
        private integer EntryTooltipBorder
        private integer EntryTooltipTitle
        private integer EntryTooltipText
        private integer HoverCandidate = 0
        private integer HoverCandidateEvent = 0
        private integer HoverCandidateOffer = 0
        private integer HoverCandidateRun = 0
        private integer array BranchButtons
        private integer array BranchAction
        private integer array BranchHeader
        private integer array BranchStrip
        private integer HoverBranch = 0
        private integer RerollButton
        private integer ResumeButton
        private integer HuntHUD
        private integer HuntStatus
        private integer HuntReady
        private integer LoadedSlot = -1
        private real ImagePixelAspect = 1.0
    endglobals

    private function PaperText takes integer frame, string value, string color returns nothing
        // 사건의 종이 배경에서만 색을 보정하고, 강조가 끝나면 해당 글자의 기본색으로 돌아간다.
        set value = JNStringReplace(value, "|cff315a70", color)
        set value = JNStringReplace(value, "|cff163848", color)
        set value = JNStringReplace(value, "|cFF006B8F", "|cff376571")
        set value = JNStringReplace(value, "|cFF865500", PAPER_GOLD)
        set value = JNStringReplace(value, "|cff83e4e6", "|cff376571")
        set value = JNStringReplace(value, "|cff9cddb0", PAPER_GAIN)
        set value = JNStringReplace(value, "|cff216548", PAPER_GAIN)
        set value = JNStringReplace(value, "|cff9c4a22", PAPER_COST)
        set value = JNStringReplace(value, "|cff0877ae", "|cff2f628d")
        set value = JNStringReplace(value, "|cff8042ad", "|cff705189")
        set value = JNStringReplace(value, "|cffb84ca5", "|cff995078")
        set value = JNStringReplace(value, "|cffc781ff", "|cff705189")
        set value = JNStringReplace(value, "[카드 획득]", PAPER_GAIN + "[카드 획득]" + color)
        set value = JNStringReplace(value, "[효과 추가]", PAPER_GAIN + "[효과 추가]" + color)
        call DzFrameSetText(frame, color + JNStringReplace(value, "|r", color) + "|r")
    endfunction

    // 자동 줄바꿈 행간을 넓히려고 본문을 미리 줄로 나눠 줄마다 TEXT로 배치한다.
    // 원본 TEXT를 먼저 채우고, 분할과 높이 검사가 모두 통과한 뒤에만 줄 TEXT로 바꾼다.
    // 분할 실패, 넘침 또는 계산 도중 중단 시에는 원본 TEXT가 그대로 보인다.
    private function SetStoryText takes string value, real top, real available returns nothing
        local integer i = 0
        if value == StoryCached and top == StoryCachedTop and ImagePixelAspect == StoryCachedAspect then
            return
        endif
        set StoryCached = value
        set StoryCachedTop = top
        set StoryCachedAspect = ImagePixelAspect
        call PaperText(StoryText, value, PAPER_BODY)
        call DzFrameShow(StoryText, true)
        loop
            exitwhen i >= STORY_LINE_MAX
            call DzFrameShow(StoryLineFrames[i], false)
            set i = i + 1
        endloop
        // 와이드 화면에서는 UI 가로 단위가 늘어나므로 글자 폭을 화면 비율로 보정한다.
        set StoryLineEm = STORY_EM_43 / ImagePixelAspect
        if not StoryLineLayout(value, 0.274, 0.011) or StoryLineCount * STORY_LINE_GAP > available then
            return
        endif
        set i = 0
        loop
            exitwhen i >= StoryLineCount
            call PlaceCoverPart(StoryLineFrames[i], StoryPanel, 0.018, top + i * STORY_LINE_GAP, 0.284, 0.016)
            call PaperText(StoryLineFrames[i], StoryLines[i], PAPER_BODY)
            call DzFrameShow(StoryLineFrames[i], true)
            set i = i + 1
        endloop
        call DzFrameShow(StoryText, false)
    endfunction

    private function CreateStoryText takes nothing returns integer
        // TEXTAREA의 검은 그림자를 피하고 결과 영역과 같은 TEXT 표시를 사용한다.
        return ExpUILabel(StoryPanel, 0.018, 0.126, 0.274, 0.242, 0.011, "")
    endfunction

    private function ClearCandidateHover takes nothing returns nothing
        if HoverCandidate > 0 then
            call ExpUISelectButton(CandidateButtons[HoverCandidate], false)
        endif
        set HoverCandidate = 0
        set HoverCandidateEvent = 0
        call DzFrameShow(EntryTooltip, false)
    endfunction

    private function CandidateEnter takes nothing returns nothing
        local integer pid = GetPlayerId(GetLocalPlayer())
        local integer i = 1
        if DzGetTriggerUIEventPlayer() != GetLocalPlayer() or pid > 3 then
            return
        endif
        call ClearCandidateHover()
        if ExpUIPanel != 9 or ProtoStage[pid] != 1 then
            return
        endif
        loop
            exitwhen i > ProtoChoices[pid] or i > 4
            if DzGetTriggerUIEventFrame() == ExpUIButtons[CandidateButtons[i]] then
                set HoverCandidate = i
                set HoverCandidateEvent = ProtoCandidates[ExpKey(pid, i)]
                set HoverCandidateOffer = ExpOfferVersion[pid]
                set HoverCandidateRun = ExpRun
                call ExpUISelectButton(CandidateButtons[i], true)
                return
            endif
            set i = i + 1
        endloop
    endfunction

    private function CandidateLeave takes nothing returns nothing
        if DzGetTriggerUIEventPlayer() == GetLocalPlayer() and HoverCandidate > 0 then
            if DzGetTriggerUIEventFrame() == ExpUIButtons[CandidateButtons[HoverCandidate]] then
                call ClearCandidateHover()
            endif
        endif
    endfunction

    private function BranchEnter takes nothing returns nothing
        local integer i = 1
        if DzGetTriggerUIEventPlayer() != GetLocalPlayer() then
            return
        endif
        loop
            exitwhen i > 4
            if DzGetTriggerUIEventFrame() == ExpUIButtons[BranchButtons[i]] then
                set HoverBranch = i
                return
            endif
            set i = i + 1
        endloop
    endfunction

    private function BranchLeave takes nothing returns nothing
        if DzGetTriggerUIEventPlayer() == GetLocalPlayer() then
            set HoverBranch = 0
        endif
    endfunction

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

    private function PlaceEventImage takes integer frame, integer parent, real x, real y, real width, real height, integer id returns nothing
        local real aspect = ProtoEventImageAspect[id] / ImagePixelAspect
        local real imageWidth = width
        local real imageHeight = height
        if aspect <= 0.0 then
            set aspect = 1.0 / ImagePixelAspect
        endif
        // 통일된 사건 썸네일을 화면 비율에 맞춰 표시하고 그림이 늘어나지 않게 한다.
        if imageWidth > imageHeight * aspect then
            set imageWidth = imageHeight * aspect
        else
            set imageHeight = imageWidth / aspect
        endif
        call PlaceCoverPart(frame, parent, x + (width - imageWidth) * 0.5, y + (height - imageHeight) * 0.5, imageWidth, imageHeight)
    endfunction

    private function RenderEntryTooltip takes integer pid returns nothing
        local integer card
        local integer grade
        local real x
        if HoverCandidate <= 0 then
            return
        endif
        if ExpUIPanel != 9 or ProtoStage[pid] != 1 or F_UpgradeOnOff[pid] or not ExpPrototypeActive or not ExpMember[pid] or HoverCandidate > ProtoChoices[pid] or HoverCandidateOffer != ExpOfferVersion[pid] or HoverCandidateRun != ExpRun or HoverCandidateEvent != ProtoCandidates[ExpKey(pid, HoverCandidate)] then
            call ClearCandidateHover()
            return
        endif
        if HoverCandidateEvent <= 0 or ProtoEventKind[HoverCandidateEvent] != 0 then
            call DzFrameShow(EntryTooltip, false)
            return
        endif
        set card = ProtoHeadEntryCard[ProtoEventHead[HoverCandidateEvent]]
        if card <= 0 then
            call DzFrameShow(EntryTooltip, false)
            return
        endif
        // 선택 중인 후보를 덮지 않고 옆에 띄워 마우스 진입/이탈이 반복되지 않게 한다.
        set x = (0.8 - (0.174 * ProtoChoices[pid] + 0.012 * (ProtoChoices[pid] - 1))) * 0.5 + (HoverCandidate - 1) * 0.186
        if x + 0.182 + 0.266 <= 0.788 then
            set x = x + 0.182
        else
            set x = x - 0.274
        endif
        call PlaceCoverPart(EntryTooltip, EventRoot, x, 0.214, 0.266, 0.220)
        call PlaceCoverPart(EntryTooltipIcon, EntryTooltip, 0.012, 0.044, 0.046, 0.046 * ImagePixelAspect)
        call PlaceCoverPart(EntryTooltipBorder, EntryTooltip, 0.012, 0.044, 0.046, 0.046 * ImagePixelAspect)
        set grade = ProtoRewardGrade(pid, card, false)
        call DzFrameSetTexture(EntryTooltipIcon, ProtoCardArt(card), 0)
        call DzFrameSetTexture(EntryTooltipBorder, ProtoCardFrame(grade), 0)
        // 보관함의 누적 합산 대신 실제 입문 보상의 추가 효과를 미리 보여준다.
        call DzFrameSetText(EntryTooltipText, "|cffe7edf3" + JNStringReplace(ProtoEventCardPreview(pid, card), "|r", "|cffe7edf3") + "|r")
        call DzFrameShow(EntryTooltip, true)
    endfunction

    private function RenderCover takes integer pid, integer i, integer id returns nothing
        local integer cover = ExpUIButtons[CandidateButtons[i]]
        local integer head = ProtoEventHead[id]
        local boolean opening = ProtoEventKind[id] == 0
        local boolean eligible = ProtoEventEligible(pid, id)
        // 후보 수가 바뀌어도 표지와 글자 크기는 유지하고 전체 행만 가운데 정렬한다.
        local real x = (0.8 - (0.174 * ProtoChoices[pid] + 0.012 * (ProtoChoices[pid] - 1))) * 0.5 + (i - 1) * 0.186
        local string tag = "공통 사건"
        local string action = "행동력 " + I2S(ProtoEventAPCost[id]) + " · 사건 만나기"
        local string entryReward
        call PlaceCoverPart(cover, EventRoot, x, 0.138, 0.174, 0.386)
        call ExpUIResizeCover(CandidateButtons[i], 0.174, 0.386)
        call PlaceCoverPart(CandidateRegion[i], cover, 0.012, 0.012, 0.150, 0.038)
        call PlaceEventImage(CandidateIcon[i], cover, 0.012, 0.052, 0.150, 0.108, id)
        call PlaceCoverPart(CandidateTitle[i], cover, 0.012, 0.168, 0.150, 0.034)
        if opening or ProtoEventRequiredCard[id] > 0 then
            call PlaceCoverPart(CandidateIntro[i], cover, 0.012, 0.210, 0.150, 0.077)
            call PlaceCoverPart(CandidateBonus[i], cover, 0.012, 0.294, 0.150, 0.044)
        else
            call PlaceCoverPart(CandidateIntro[i], cover, 0.012, 0.210, 0.150, 0.128)
        endif
        if head > 0 then
            set tag = ProtoHeadName[head]
        endif
        if opening then
            set tag = "지역 개방 · " + tag
            set action = "행동력 0 · 머리 카드 획득"
            set entryReward = "입문 카드 · " + ProtoDisplayCardName(pid, ProtoHeadEntryCard[head])
            if ProtoOwnsCharacter(pid, ProtoHeadEntryCard[head]) then
                set entryReward = entryReward + " (효과 추가)"
            else
                set entryReward = entryReward + " 획득"
            endif
            call PaperText(CandidateBonus[i], "머리 효과 · " + ProtoHeadEffectText(head) + "|n" + entryReward, PAPER_GAIN)
        elseif ProtoEventMainStage[id] > 0 then
            set tag = tag + " · 메인 " + I2S(ProtoEventMainStage[id]) + "/" + I2S(ProtoHeadMainLength[head])
        elseif ProtoEventEpilogue[id] > 0 then
            set tag = tag + " · 후일담"
        elseif ProtoEventRequired[id] > 0 then
            set tag = tag + " · 후속"
        endif
        if not opening and ProtoEventRequiredCard[id] > 0 then
            call PaperText(CandidateBonus[i], "보유 조건|n" + ProtoDisplayCardName(pid, ProtoEventRequiredCard[id]) + "|n" + ProtoCardEffectName[ProtoEventRequiredCard[id]], PAPER_META)
        endif
        call PaperText(CandidateRegion[i], tag + "|n" + ProtoGradeColor(ProtoEventGrade[id]) + ExpEventGradeName(ProtoEventGrade[id]) + " 보상 가능|r", PAPER_META)
        call PaperText(CandidateTitle[i], ProtoEventName[id], PAPER_TITLE)
        call PaperText(CandidateIntro[i], ProtoEventIntro[id], PAPER_BODY)
        call DzFrameSetTexture(CandidateIcon[i], ProtoEventIcon[id], 0)
        call DzFrameShow(CandidateBonus[i], opening or ProtoEventRequiredCard[id] > 0)
        if not eligible then
            set action = "선택 불가 · 후보 갱신 대기"
        endif
        call ExpUISetButton(CandidateButtons[i], action, eligible)
        // 선택 제한은 유지하되 글자와 그림까지 흐려져 불가 사유를 읽지 못하게 하지 않는다.
        call DzFrameSetAlpha(ExpUIButtons[CandidateButtons[i]], 255)
        if eligible then
            call PaperText(ExpUIButtonLabels[CandidateButtons[i]], action, PAPER_GAIN)
        else
            call PaperText(ExpUIButtonLabels[CandidateButtons[i]], action, PAPER_COST)
        endif
    endfunction

    private function Render takes nothing returns nothing
        local integer pid = GetPlayerId(GetLocalPlayer())
        local integer i = 1
        local integer id
        local boolean lobby
        local string tag
        local string value
        local string packet
        local real branchHeight
        local real storyTop = 0.126
        local real storyHeight = 0.242
        local string clockColor = PAPER_GOLD
        local integer clientWidth = JNGetLocalClientWidth()
        local integer clientHeight = JNGetLocalClientHeight()
        if LobbyRoot == 0 or pid > 3 or not PickCheck[pid] then
            if EntryTooltip != 0 then
                call ClearCandidateHover()
            endif
            return
        endif
        if clientWidth > 0 and clientHeight > 0 then
            set ImagePixelAspect = 0.75 * I2R(clientWidth) / I2R(clientHeight)
        endif
        call RenderEntryTooltip(pid)
        set lobby = ExpState == EXP_LOBBY or ExpState == EXP_RESULT
        if lobby and LoadedSlot != PlayerSlotNumber[pid] then
            set LoadedSlot = PlayerSlotNumber[pid]
            set packet = I2S(PlayerSlotNumber[pid])
            loop
                exitwhen i > PROTO_HEAD_COUNT
                set packet = packet + "|" + StashLoad(PLAYER_DATA[pid], PROTO_SAVE_PREFIX + "머리도감." + ProtoHeadKey[i], "0")
                set i = i + 1
            endloop
            call DzSyncData("ProtoCodex", packet)
        endif
        set value = "원정 규칙|n|n개인 사냥 20분 · 행동력 20|n이번 원정 머리 2장부터 · 메인 완주마다 한도 +1|n머리 획득 비용 없음 · 사건 후보 3개 (최대 4개)|n리롤 500골드부터 · 다음 리롤 +100골드"
        call ExpUIText(LobbyInfo, value)
        set value = "출발 장비|n|n출발 머리 · "
        if ProtoStartHead[pid] > 0 then
            set value = value + ProtoHeadName[ProtoStartHead[pid]]
        else
            set value = value + "없음"
        endif
        set value = value + "|n머리 선택은 추후 도감에서 설정합니다.|n|n장착 공격력 " + I2S(R2I(AttackPower(pid))) + "|n"
        if AttackPower(pid) < 100.0 or not UnitAlive(MainUnit[pid]) or not RectContainsUnit(gg_rct_Home, MainUnit[pid]) or PlayerSlotNumber[pid] <= 0 or not ProtoStartHeadReady(pid) then
            set value = value + "T2 무기 · 공격력 100 · 마을에서 출발 가능|n"
        endif
        call ExpUIText(LobbyLoadout, value)
        set value = "파티 준비 상태|n"
        set i = 0
        loop
            exitwhen i == 4
            if not ExpLeft[i] and GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                set value = value + "|n" + GetPlayerName(Player(i))
                if ExpReady[i] then
                    set value = value + " · 준비완료"
                else
                    set value = value + " · 준비중"
                endif
            endif
            set i = i + 1
        endloop
        call ExpUIText(LobbyParty, value)
        if ExpReady[pid] then
            call ExpUISetButton(LobbyReady, "출발 준비 취소", true)
        else
            call ExpUISetButton(LobbyReady, "출발 준비", AttackPower(pid) >= 100.0 and UnitAlive(MainUnit[pid]) and RectContainsUnit(gg_rct_Home, MainUnit[pid]) and PlayerSlotNumber[pid] > 0 and ProtoStartHeadReady(pid))
        endif
        call DzFrameShow(HuntHUD, ExpPrototypeActive and ExpMember[pid] and ExpState == EXP_HUNT and not F_UpgradeOnOff[pid] and ExpUIPanel != 9)
        set value = "남은 " + I2S(ExpSeconds) + "초   행동력 " + I2S(ProtoAP[pid]) + "/" + I2S(ProtoAPMax[pid]) + "   골드 " + I2S(ExpGold[pid]) + "|n사냥 " + I2S(ProtoKills[pid]) + "회 · 적 단계 " + I2S(ProtoLevel[pid]) + " · 동시 몬스터 " + I2S(ProtoDensity[pid]) + "마리|n몬스터 체력 " + I2S(R2I(300.0 * (1.0 + 0.30 * (ProtoLevel[pid] - 1)))) + " · 기본 공격 피해 최대 체력의 " + R2SW(PROTO_BASE_HIT_PERCENT * (1.0 + 0.25 * (ProtoLevel[pid] - 1)), 0, 1) + "%"
        if ProtoReady[pid] then
            set value = "보스 합류 대기 · " + value
        endif
        call ExpUIText(HuntStatus, value)
        call ExpUISetButton(HuntReady, "준비 완료", ProtoAP[pid] == 0 and ProtoStage[pid] == 0 and not ProtoReady[pid] and UnitAlive(MainUnit[pid]))
        if ProtoDeadline[pid] <= 10 then
            set clockColor = PAPER_COST
        endif
        call PaperText(EventInfo, "사냥 " + PAPER_TITLE + I2S(ExpSeconds) + "초|r · 선택 " + clockColor + I2S(ProtoDeadline[pid]) + "초|r|n행동력 " + PAPER_GAIN + I2S(ProtoAP[pid]) + "/" + I2S(ProtoAPMax[pid]) + "|r · 골드 " + PAPER_GOLD + I2S(ExpGold[pid]) + "|r", PAPER_META)
        call DzFrameShow(StoryPanel, ProtoStage[pid] == 2 or ProtoStage[pid] == 3)
        call DzFrameShow(OutcomePanel, ProtoStage[pid] == 3)
        if ProtoStage[pid] == 1 then
            call PaperText(EventTitle, "개인 사건 · 사건 선택", PAPER_TITLE)
            set value = "머리 " + I2S(ProtoHeadCount[pid]) + "/" + I2S(ProtoHeadCapacity(pid)) + " · 후보에 표시된 행동력 소모 · 내 공간만 정지합니다."
            if ProtoHeadCount[pid] >= ProtoHeadCapacity(pid) then
                set value = value + "|n메인 이야기 완주 시 이번 원정의 머리 한도 +1."
            endif
            call PaperText(EventStory, value, PAPER_META)
        elseif ProtoStage[pid] == 2 then
            call PaperText(EventTitle, "개인 사건 · 행동 선택", PAPER_TITLE)
            if ProtoDialogueFollowing(pid) then
                call PaperText(EventStory, "이야기에 답하세요. 추가 행동력 소모 없이 대화가 이어집니다.", PAPER_META)
            else
                call PaperText(EventStory, "상황을 읽고 행동을 고르세요. 커서를 올리면 카드 수치를 확인할 수 있습니다.", PAPER_META)
            endif
        else
            set id = ProtoSelected[pid]
            if ProtoDialoguePending(pid) then
                call PaperText(EventTitle, "개인 사건 · 대화 반응", PAPER_TITLE)
                call PaperText(EventStory, "반응을 읽고 다음 장면으로 이어가세요. 보상은 대화를 모두 마친 뒤 한 번 받습니다.", PAPER_META)
            elseif ProtoStage[pid] == 3 and ProtoEventMainStage[id] > 0 and ProtoEventMainStage[id] == ProtoHeadMainLength[ProtoEventHead[id]] and ProtoMainProgress[ExpKey(pid, ProtoEventHead[id])] == ProtoEventMainStage[id] then
                call PaperText(EventTitle, "이야기 완결 · " + ProtoHeadName[ProtoEventHead[id]], PAPER_TITLE)
                call PaperText(EventStory, "여정의 마지막 기억을 카드에 남겼습니다. 이 지역의 이야기는 매듭짓고, 후일담을 만날 수 있습니다.", PAPER_META)
            else
                call PaperText(EventTitle, "개인 사건 · 사건 결과", PAPER_TITLE)
                call PaperText(EventStory, "이번 선택의 결과를 확인하세요. 확인을 누르면 내 사냥터로 돌아갑니다.", PAPER_META)
            endif
            if ProtoDialoguePending(pid) then
                call PaperText(OutcomeHeading, "선택에 대한 반응", PAPER_TITLE)
            else
                call PaperText(OutcomeHeading, "사건 결과 · 획득과 변화", PAPER_TITLE)
            endif
            call PaperText(OutcomeText, ProtoOutcome[pid], PAPER_BODY)
        endif
        if ProtoStage[pid] == 2 or ProtoStage[pid] == 3 then
            set id = ProtoSelected[pid]
            set tag = "공통 사건"
            if ProtoEventHead[id] > 0 then
                set tag = ProtoHeadName[ProtoEventHead[id]]
            endif
            if ProtoEventMainStage[id] > 0 then
                set tag = tag + " · 메인 " + I2S(ProtoEventMainStage[id]) + "/" + I2S(ProtoHeadMainLength[ProtoEventHead[id]])
            elseif ProtoEventEpilogue[id] > 0 then
                set tag = tag + " · 후일담"
            endif
            call PaperText(StoryRegion, tag + " · " + ProtoGradeColor(ProtoEventGrade[id]) + ExpEventGradeName(ProtoEventGrade[id]) + " 보상 가능|r", PAPER_META)
            call PaperText(StoryTitle, ProtoEventName[id], PAPER_TITLE)
            call DzFrameSetTexture(StoryIcon, ProtoEventIcon[id], 0)
            // 후속 장면은 결말과 질문을 함께 담으므로 아이콘보다 본문의 세로 공간을 우선한다.
            if ProtoDialogueFollowing(pid) then
                call PlaceEventImage(StoryIcon, StoryPanel, 0.018, 0.045, 0.044, 0.044, id)
                call PlaceCoverPart(StoryTitle, StoryPanel, 0.076, 0.048, 0.216, 0.044)
                call PlaceCoverPart(StoryText, StoryPanel, 0.018, 0.104, 0.274, 0.264)
                set storyTop = 0.104
                set storyHeight = 0.264
            else
                call PlaceEventImage(StoryIcon, StoryPanel, 0.018, 0.045, 0.070, 0.070, id)
                call PlaceCoverPart(StoryTitle, StoryPanel, 0.112, 0.048, 0.180, 0.070)
                call PlaceCoverPart(StoryText, StoryPanel, 0.018, 0.126, 0.274, 0.242)
            endif
            // 최종 본문은 행동 상세 여부를 결정한 뒤 한 번만 설정한다.
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
            exitwhen i > 4
            call DzFrameShow(ExpUIButtons[BranchButtons[i]], ProtoStage[pid] == 2 and i <= ProtoDialogueChoiceCount(pid))
            if ProtoStage[pid] == 2 and i <= ProtoDialogueChoiceCount(pid) then
                set branchHeight = (0.426 - 0.010 * (ProtoDialogueChoiceCount(pid) - 1)) / ProtoDialogueChoiceCount(pid)
                call PlaceCoverPart(ExpUIButtons[BranchButtons[i]], EventRoot, 0.356, 0.116 + (i - 1) * (branchHeight + 0.010), 0.412, branchHeight)
                call ExpUIResizeCover(BranchButtons[i], 0.412, branchHeight)
                call PlaceCoverPart(ExpUIButtonLabels[BranchButtons[i]], ExpUIButtons[BranchButtons[i]], 0.016, 0.026, 0.380, branchHeight - 0.052)
                call PlaceCoverPart(BranchStrip[i], ExpUIButtons[BranchButtons[i]], 0.010, branchHeight - 0.021, 0.392, 0.016)
                call PlaceCoverPart(BranchAction[i], ExpUIButtons[BranchButtons[i]], 0.018, branchHeight - 0.019, 0.376, 0.014)
                if ProtoDialogueChoiceCount(pid) >= 3 then
                    set value = ProtoDialogueChoiceText(pid, i, true)
                else
                    set value = ProtoDialogueChoiceText(pid, i, false)
                endif
                call ExpUISetButton(BranchButtons[i], value, ProtoDialogueChoiceAllowed(pid, i))
                call DzFrameSetAlpha(ExpUIButtons[BranchButtons[i]], 255)
                if ProtoDialogueChoiceAllowed(pid, i) then
                    call PaperText(ExpUIButtonLabels[BranchButtons[i]], value, PAPER_BODY)
                    call PaperText(BranchAction[i], "이 행동을 선택", PAPER_GAIN)
                else
                    call PaperText(ExpUIButtonLabels[BranchButtons[i]], value, PAPER_META)
                    call PaperText(BranchAction[i], "조건 미충족 · 선택 불가", PAPER_COST)
                endif
            endif
            set i = i + 1
        endloop
        if ProtoStage[pid] == 2 and not ProtoDialogueFollowing(pid) and HoverBranch > 0 and HoverBranch <= ProtoDialogueChoiceCount(pid) then
            call SetStoryText("[행동 상세 · 커서를 옮기면 사건 설명]|n|n" + ProtoDialogueChoiceText(pid, HoverBranch, false), storyTop, storyHeight)
        else
            set HoverBranch = 0
            if ProtoStage[pid] == 2 or ProtoStage[pid] == 3 then
                call SetStoryText(ProtoDialogueStoryText(pid), storyTop, storyHeight)
            endif
        endif
        call DzFrameShow(ExpUIButtons[RerollButton], ProtoStage[pid] == 1)
        call ExpUISetButton(RerollButton, "사건 리롤 · " + I2S(500 + ProtoRerolls[pid] * 100) + "골드", ExpGold[pid] >= 500 + ProtoRerolls[pid] * 100)
        call DzFrameSetAlpha(ExpUIButtons[RerollButton], 255)
        if ExpGold[pid] >= 500 + ProtoRerolls[pid] * 100 then
            call PaperText(ExpUIButtonLabels[RerollButton], "사건 리롤 · " + I2S(500 + ProtoRerolls[pid] * 100) + "골드", PAPER_GOLD)
        else
            call PaperText(ExpUIButtonLabels[RerollButton], "사건 리롤 · " + I2S(500 + ProtoRerolls[pid] * 100) + "골드", PAPER_META)
        endif
        call DzFrameShow(ExpUIButtons[ResumeButton], ProtoStage[pid] == 3)
        if ProtoDialoguePending(pid) then
            call ExpUISetButton(ResumeButton, "계속 · 다음 장면", true)
            call PaperText(ExpUIButtonLabels[ResumeButton], "계속 · 다음 장면", PAPER_GAIN)
        else
            call ExpUISetButton(ResumeButton, "확인 · 사냥 재개", true)
            call PaperText(ExpUIButtonLabels[ResumeButton], "확인 · 사냥 재개", PAPER_GAIN)
        endif
    endfunction

    // 진단은 글을 읽고 로컬 비교 창만 표시한다. 사건 상태나 본문은 변경하지 않는다.
    private function LineTestClose takes nothing returns nothing
        if DzGetTriggerUIEventPlayer() == GetLocalPlayer() then
            set LineTestVisible = false
            call DzFrameShow(LineTestRoot, false)
        endif
    endfunction

    private function LineTestLog takes string label, string value returns nothing
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 120, label + " bytes=" + I2S(StringLength(value)) + " n=" + I2S(JNStringCount(value, "|n")))
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 120, JNStringReplace(value, "|n", "/N/"))
    endfunction

    private function LineTest takes nothing returns nothing
        local integer pid = GetPlayerId(GetTriggerPlayer())
        if GetTriggerPlayer() != GetLocalPlayer() or LineTestRoot == 0 then
            return
        endif
        if LineTestVisible then
            set LineTestVisible = false
            call DzFrameShow(LineTestRoot, false)
            return
        endif
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 120, "줄 진단 v1 · panel=" + I2S(ExpUIPanel) + " stage=" + I2S(ProtoStage[pid]) + " event=" + I2S(ProtoSelected[pid]) + " hover=" + I2S(HoverBranch))
        call LineTestLog("T1 534 원문", ProtoEventStory[534])
        call LineTestLog("T1 133 원문", ProtoEventStory[133])
        if ExpUIPanel == 9 and (ProtoStage[pid] == 2 or ProtoStage[pid] == 3) then
            call LineTestLog("T2 현재 원문", ProtoDialogueStoryText(pid))
            call LineTestLog("T2 프레임 스냅샷", DzFrameGetText(StoryText))
        else
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 120, "T2는 사건의 행동 선택 또는 결과 화면에서 다시 확인하세요.")
        endif
        set LineTestVisible = true
        call DzFrameShow(LineTestRoot, true)
    endfunction

    private function BuildLineTest takes nothing returns nothing
        local integer f
        local integer i = 0
        local string value = "가나다라|n마바사아"
        set LineTestRoot = DzCreateFrameByTagName("FRAME", "", DzGetGameUI(), "", FrameCount())
        call DzFrameSetSize(LineTestRoot, 0.74, 0.24)
        call DzFrameSetAbsolutePoint(LineTestRoot, JN_FRAMEPOINT_TOPLEFT, 0.03, 0.38)
        call DzFrameSetPriority(LineTestRoot, 200)
        set f = ExpUITexture(LineTestRoot, 0, 0, 0.74, 0.24, "war3mapImported\\UI_Arcana_Sheet.tga")
        set f = ExpUILabel(LineTestRoot, 0.015, 0.012, 0.60, 0.024, 0.012, "")
        call PaperText(f, "줄 진단 v1 · T3 빈 줄 비교", PAPER_TITLE)
        set f = DzCreateFrameByTagName("GLUETEXTBUTTON", "", LineTestRoot, "ScriptDialogButton", FrameCount())
        call PlaceCoverPart(f, LineTestRoot, 0.64, 0.008, 0.085, 0.028)
        call DzFrameSetText(f, "닫기")
        call DzFrameSetScriptByCode(f, JN_FRAMEEVENT_MOUSE_UP, function LineTestClose, false)
        loop
            exitwhen i >= 3
            set f = ExpUILabel(LineTestRoot, 0.015 + i * 0.24, 0.054, 0.22, 0.024, 0.011, "")
            call PaperText(f, "빈 줄 " + I2S(i) + "개", PAPER_META)
            set f = ExpUILabel(LineTestRoot, 0.015 + i * 0.24, 0.090, 0.22, 0.10, 0.011, "")
            call JNFrameSetTextAlignment(f, JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_LEFT)
            call PaperText(f, value, PAPER_BODY)
            set value = JNStringReplace(value, "마바사아", "|n마바사아")
            set i = i + 1
        endloop
        set f = ExpUILabel(LineTestRoot, 0.015, 0.205, 0.70, 0.025, 0.009, "")
        call PaperText(f, "T1·T2는 F12 로그 확인 · 닫기 또는 -줄테스트 재입력 · 사냥 시간은 계속 흐릅니다.", PAPER_META)
        call DzFrameShow(LineTestRoot, false)
    endfunction

    // 행간 비교 샘플: 왼쪽은 기존 TEXT 한 개, 오른쪽은 미리 나눈 줄을 줄마다 TEXT로 배치한다.
    // 오른쪽도 원본 TEXT를 먼저 채우고, 줄 분할과 높이 검사가 모두 통과한 뒤에만 줄 TEXT로 바꾼다.
    private function PitchArg takes string value, integer index returns string
        local integer i = 0
        local integer n = StringLength(value)
        local integer k = 0
        local integer start = 0
        loop
            exitwhen i > n
            if i == n or SubString(value, i, i + 1) == " " then
                if i > start then
                    if k == index then
                        return SubString(value, start, i)
                    endif
                    set k = k + 1
                endif
                set start = i + 1
            endif
            set i = i + 1
        endloop
        return ""
    endfunction

    private function PitchRender takes nothing returns nothing
        local string value = ProtoEventStory[PitchEvent]
        local string state = "원본 유지"
        local integer i = 0
        local boolean ok
        call PaperText(PitchOriginal, value, PAPER_BODY)
        call PaperText(PitchRight, value, PAPER_BODY)
        call DzFrameShow(PitchRight, true)
        loop
            exitwhen i >= STORY_LINE_MAX
            call DzFrameShow(PitchLines[i], false)
            set i = i + 1
        endloop
        set ok = StoryLineLayout(value, 0.274, 0.011)
        if not ok then
            set state = "분할 실패"
        elseif StoryLineCount * PitchGap > 0.300 then
            set ok = false
            set state = "높이 넘침"
        endif
        if ok then
            set i = 0
            loop
                exitwhen i >= StoryLineCount
                call PlaceCoverPart(PitchLines[i], PitchRoot, 0.400, 0.070 + i * PitchGap, 0.284, 0.016)
                call PaperText(PitchLines[i], StoryLines[i], PAPER_BODY)
                call DzFrameShow(PitchLines[i], true)
                set i = i + 1
            endloop
            // 줄 TEXT를 모두 채운 다음에 원본을 숨긴다.
            call DzFrameShow(PitchRight, false)
            set state = "줄 배치"
        endif
        call PaperText(PitchInfo, "사건 " + I2S(PitchEvent) + " · 행간 " + R2SW(PitchGap, 1, 4) + " · em " + R2SW(StoryLineEm, 1, 2) + " · 가=" + I2S(StringLength("가")) + "|n줄 " + I2S(StoryLineCount) + " · " + state + "|n눈금 줄 첫 줄 글자 수 N → em = 0.274 / (N × 0.011)", PAPER_META)
        set i = 0
        loop
            exitwhen i >= StoryLineCount or not ok
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 120, "행간 줄 " + I2S(i + 1) + ": " + StoryLines[i])
            set i = i + 1
        endloop
    endfunction

    private function PitchClose takes nothing returns nothing
        if DzGetTriggerUIEventPlayer() == GetLocalPlayer() then
            set PitchVisible = false
            call DzFrameShow(PitchRoot, false)
        endif
    endfunction

    // -행간 [행간] [em] [사건ID]. 인자 없이 다시 입력하면 닫는다.
    private function PitchCommand takes nothing returns nothing
        local string value = GetEventPlayerChatString()
        local string gap = PitchArg(value, 1)
        local string em = PitchArg(value, 2)
        local string id = PitchArg(value, 3)
        if GetTriggerPlayer() != GetLocalPlayer() or PitchRoot == 0 or PitchArg(value, 0) != "-행간" then
            return
        endif
        if gap == "" and PitchVisible then
            set PitchVisible = false
            call DzFrameShow(PitchRoot, false)
            return
        endif
        if gap != "" and S2R(gap) >= 0.010 and S2R(gap) <= 0.030 then
            set PitchGap = S2R(gap)
        endif
        // em을 주지 않으면 실제 본문과 같은 화면 비율 보정값을 쓴다.
        set StoryLineEm = STORY_EM_43 / ImagePixelAspect
        if em != "" and S2R(em) >= 0.6 and S2R(em) <= 1.6 then
            set StoryLineEm = S2R(em)
        endif
        if id != "" and S2I(id) > 0 and S2I(id) < 8192 then
            if ProtoEventStory[S2I(id)] != "" then
                set PitchEvent = S2I(id)
            endif
        endif
        set PitchVisible = true
        call DzFrameShow(PitchRoot, true)
        call PitchRender()
    endfunction

    private function BuildPitchSample takes nothing returns nothing
        local integer f
        local integer i = 0
        set PitchRoot = DzCreateFrameByTagName("FRAME", "", DzGetGameUI(), "", FrameCount())
        call DzFrameSetSize(PitchRoot, 0.74, 0.46)
        call DzFrameSetAbsolutePoint(PitchRoot, JN_FRAMEPOINT_TOPLEFT, 0.03, 0.57)
        call DzFrameSetPriority(PitchRoot, 200)
        set f = ExpUITexture(PitchRoot, 0, 0, 0.74, 0.46, "war3mapImported\\UI_Arcana_Paper.tga")
        set f = ExpUITexture(PitchRoot, 0.012, 0.040, 0.310, 0.340, "war3mapImported\\UI_Arcana_Sheet.tga")
        set f = ExpUITexture(PitchRoot, 0.382, 0.040, 0.310, 0.340, "war3mapImported\\UI_Arcana_Sheet.tga")
        set f = ExpUILabel(PitchRoot, 0.015, 0.012, 0.60, 0.024, 0.012, "")
        call PaperText(f, "행간 비교 샘플", PAPER_TITLE)
        set f = ExpUILabel(PitchRoot, 0.030, 0.048, 0.274, 0.018, 0.010, "")
        call PaperText(f, "기본 · TEXT 한 개 자동 줄바꿈", PAPER_META)
        set f = ExpUILabel(PitchRoot, 0.400, 0.048, 0.274, 0.018, 0.010, "")
        call PaperText(f, "넓힘 · 줄마다 TEXT", PAPER_META)
        set PitchOriginal = ExpUILabel(PitchRoot, 0.030, 0.070, 0.274, 0.300, 0.011, "")
        call JNFrameSetTextAlignment(PitchOriginal, JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_LEFT)
        set PitchRight = ExpUILabel(PitchRoot, 0.400, 0.070, 0.274, 0.300, 0.011, "")
        call JNFrameSetTextAlignment(PitchRight, JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_LEFT)
        loop
            exitwhen i >= STORY_LINE_MAX
            set PitchLines[i] = ExpUILabel(PitchRoot, 0.400, 0.070, 0.284, 0.016, 0.011, "")
            call JNFrameSetTextAlignment(PitchLines[i], JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_LEFT)
            call DzFrameShow(PitchLines[i], false)
            set i = i + 1
        endloop
        // 눈금 줄: 폭 0.274 배경 위에 10글자씩 색을 바꾼 30글자를 두고 첫 줄 글자 수로 em을 보정한다.
        set f = ExpUITexture(PitchRoot, 0.030, 0.390, 0.274, 0.040, "war3mapImported\\UI_Arcana_Sheet.tga")
        set f = ExpUILabel(PitchRoot, 0.030, 0.392, 0.274, 0.040, 0.011, "")
        call JNFrameSetTextAlignment(f, JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_LEFT)
        call PaperText(f, PAPER_COST + "가나다라마바사아자차|r가나다라마바사아자차" + PAPER_COST + "가나다라마바사아자차|r", PAPER_BODY)
        set PitchInfo = ExpUILabel(PitchRoot, 0.330, 0.390, 0.390, 0.060, 0.009, "")
        call JNFrameSetTextAlignment(PitchInfo, JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_LEFT)
        set f = DzCreateFrameByTagName("GLUETEXTBUTTON", "", PitchRoot, "ScriptDialogButton", FrameCount())
        call PlaceCoverPart(f, PitchRoot, 0.64, 0.008, 0.085, 0.028)
        call DzFrameSetText(f, "닫기")
        call DzFrameSetScriptByCode(f, JN_FRAMEEVENT_MOUSE_UP, function PitchClose, false)
        call DzFrameShow(PitchRoot, false)
    endfunction

    private function Build takes nothing returns nothing
        local integer f
        local integer i = 0
        set LobbyRoot = ExpUIRoot(8, 0.8, 0.56, 0.58, false)
        set f = ExpUITexture(LobbyRoot, 0, 0, 0.8, 0.56, "war3mapImported\\UI_Arcana_Paper.tga")
        set f = ExpUIPanelToggle(LobbyRoot, 0.752, 0.008, 0.033, 0.026)
        call ExpUIThemeButton(f, 2)
        set f = ExpUILabel(LobbyRoot, 0.035, 0.020, 0.50, 0.024, 0.011, "ARCANA   /   EXPEDITION")
        set f = ExpUILabel(LobbyRoot, 0.035, 0.071, 0.40, 0.042, 0.027, "다음 이야기를 향해")
        set f = ExpUILabel(LobbyRoot, 0.037, 0.123, 0.36, 0.042, 0.012, "사건을 만나고, 카드를 모아|n보스전에 도전하세요.")
        set f = ExpUITexture(LobbyRoot, 0.035, 0.188, 0.345, 0.320, "war3mapImported\\UI_Arcana_Route.tga")
        set f = ExpUILabel(LobbyRoot, 0.054, 0.207, 0.25, 0.030, 0.019, "20분의 원정")
        set f = ExpUILabel(LobbyRoot, 0.054, 0.250, 0.27, 0.060, 0.012, "사냥과 사건 → 카드 성장 → 보스 합류")
        set f = ExpUITexture(LobbyRoot, 0.416, 0.070, 0.348, 0.139, "war3mapImported\\UI_Arcana_Sheet.tga")
        set LobbyInfo = ExpUILabel(LobbyRoot, 0.436, 0.087, 0.308, 0.115, 0.011, "")
        set f = ExpUITexture(LobbyRoot, 0.416, 0.220, 0.348, 0.127, "war3mapImported\\UI_Arcana_Sheet.tga")
        set LobbyLoadout = ExpUILabel(LobbyRoot, 0.436, 0.233, 0.308, 0.111, 0.011, "")
        call JNFrameSetTextAlignment(LobbyLoadout, JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_LEFT)
        set f = ExpUITexture(LobbyRoot, 0.416, 0.358, 0.348, 0.104, "war3mapImported\\UI_Arcana_Sheet.tga")
        set LobbyParty = ExpUILabel(LobbyRoot, 0.436, 0.371, 0.308, 0.088, 0.011, "")
        call JNFrameSetTextAlignment(LobbyParty, JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_LEFT)
        call JNFrameSetTextAlignment(LobbyInfo, JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_LEFT)
        set LobbyReady = ExpUIButton(LobbyRoot, 0.416, 0.473, 0.348, 0.041, "출발 준비", 2001)
        call ExpUIThemeButton(LobbyReady, 1)
        set EventRoot = ExpUIRoot(9, 0.8, 0.6, 0.6, false)
        set f = ExpUITexture(EventRoot, 0, 0, 0.8, 0.6, "war3mapImported\\UI_Arcana_Paper.tga")
        set f = ExpUIPanelToggle(EventRoot, 0.752, 0.008, 0.033, 0.026)
        call ExpUIThemeButton(f, 2)
        set EventTitle = ExpUILabel(EventRoot, 0.026, 0.014, 0.65, 0.026, 0.018, "개인 사건")
        set EventInfo = ExpUILabel(EventRoot, 0.330, 0.050, 0.444, 0.038, 0.012, "")
        call JNFrameSetTextAlignment(EventInfo, JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_LEFT)
        set EventStory = ExpUILabel(EventRoot, 0.026, 0.097, 0.748, 0.030, 0.012, "")
        call JNFrameSetTextAlignment(EventStory, JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_LEFT)
        set i = 1
        loop
            exitwhen i > 4
            set CandidateButtons[i] = ExpUICoverButton(EventRoot, 2100 + i)
            call ExpUIThemeButton(CandidateButtons[i], 2)
            set f = ExpUIButtons[CandidateButtons[i]]
            call DzFrameSetScriptByCode(f, JN_FRAMEEVENT_MOUSE_ENTER, function CandidateEnter, false)
            call DzFrameSetScriptByCode(f, JN_FRAMEEVENT_MOUSE_LEAVE, function CandidateLeave, false)
            set CandidateRegion[i] = CoverLabel(f, 0.011)
            set CandidateTitle[i] = CoverLabel(f, 0.014)
            set CandidateIcon[i] = ExpUITexture(f, 0, 0, 0.094, 0.094, "ReplaceableTextures\\CommandButtons\\BTNTome.blp")
            set CandidateIntro[i] = CoverLabel(f, 0.012)
            set CandidateBonus[i] = CoverLabel(f, 0.011)
            set CandidateFooter[i] = ExpUITexture(f, 0.007, 0.346, 0.160, 0.027, "war3mapImported\\UI_Arcana_Paper.tga")
            // 하단 배경보다 나중에 글자를 생성해 버튼 문구가 배경 뒤에 가려지지 않게 한다.
            call DzFrameShow(ExpUIButtonLabels[CandidateButtons[i]], false)
            set ExpUIButtonLabels[CandidateButtons[i]] = ExpUILabel(f, 0.012, 0.350, 0.150, 0.022, 0.0105, "")
            // 모든 장식은 표지 버튼의 자식이며 글자는 클릭을 가로채지 않는다.
            call JNFrameSetTextAlignment(ExpUIButtonLabels[CandidateButtons[i]], JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_LEFT)
            set i = i + 1
        endloop
        set StoryPanel = DzCreateFrameByTagName("FRAME", "", EventRoot, "", FrameCount())
        call PlaceCoverPart(StoryPanel, EventRoot, 0.032, 0.138, 0.310, 0.386)
        set f = ExpUITexture(StoryPanel, 0, 0, 0.310, 0.386, "war3mapImported\\UI_Arcana_Sheet.tga")
        set StoryRegion = ExpUILabel(StoryPanel, 0.018, 0.016, 0.274, 0.016, 0.009, "")
        set StoryIcon = ExpUITexture(StoryPanel, 0.018, 0.045, 0.080, 0.080, "ReplaceableTextures\\CommandButtons\\BTNTome.blp")
        set StoryTitle = ExpUILabel(StoryPanel, 0.112, 0.048, 0.180, 0.070, 0.014, "")
        set StoryText = CreateStoryText()
        set i = 0
        loop
            exitwhen i >= STORY_LINE_MAX
            set StoryLineFrames[i] = ExpUILabel(StoryPanel, 0.018, 0.126, 0.284, 0.016, 0.011, "")
            call JNFrameSetTextAlignment(StoryLineFrames[i], JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_LEFT)
            call DzFrameShow(StoryLineFrames[i], false)
            set i = i + 1
        endloop
        call JNFrameSetTextAlignment(StoryTitle, JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_LEFT)
        call JNFrameSetTextAlignment(StoryText, JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_LEFT)
        set i = 1
        loop
            exitwhen i > 4
            set BranchButtons[i] = ExpUICoverButton(EventRoot, 2200 + i)
            call ExpUIThemeButton(BranchButtons[i], 2)
            set f = ExpUIButtons[BranchButtons[i]]
            call DzFrameSetScriptByCode(f, JN_FRAMEEVENT_MOUSE_ENTER, function BranchEnter, false)
            call DzFrameSetScriptByCode(f, JN_FRAMEEVENT_MOUSE_LEAVE, function BranchLeave, false)
            call PlaceCoverPart(f, EventRoot, 0.356, 0.138 + (i - 1) * 0.200, 0.412, 0.186)
            call ExpUIResizeCover(BranchButtons[i], 0.412, 0.186)
            set BranchHeader[i] = ExpUILabel(f, 0.016, 0.008, 0.380, 0.016, 0.008, "행동 " + I2S(i))
            call PaperText(BranchHeader[i], "행동 " + I2S(i), PAPER_META)
            set f = ExpUIButtons[BranchButtons[i]]
            call PlaceCoverPart(ExpUIButtonLabels[BranchButtons[i]], f, 0.016, 0.040, 0.380, 0.103)
            call DzFrameSetFont(ExpUIButtonLabels[BranchButtons[i]], "Fonts\\DFHeiMd.ttf", 0.011, 0)
            call JNFrameSetTextAlignment(ExpUIButtonLabels[BranchButtons[i]], JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_LEFT)
            set BranchStrip[i] = ExpUITexture(f, 0.010, 0.150, 0.392, 0.026, "war3mapImported\\UI_Arcana_Paper.tga")
            set BranchAction[i] = ExpUILabel(ExpUIButtons[BranchButtons[i]], 0.018, 0.155, 0.376, 0.019, 0.010, "")
            call JNFrameSetTextAlignment(BranchAction[i], JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_LEFT)
            set i = i + 1
        endloop
        set OutcomePanel = DzCreateFrameByTagName("FRAME", "", EventRoot, "", FrameCount())
        call PlaceCoverPart(OutcomePanel, EventRoot, 0.356, 0.138, 0.412, 0.386)
        set f = ExpUITexture(OutcomePanel, 0, 0, 0.412, 0.386, "war3mapImported\\UI_Arcana_Sheet.tga")
        set OutcomeHeading = ExpUILabel(OutcomePanel, 0.018, 0.016, 0.376, 0.026, 0.013, "선택 결과 · 획득과 변화")
        set OutcomeText = ExpUILabel(OutcomePanel, 0.018, 0.056, 0.376, 0.314, 0.012, "")
        call JNFrameSetTextAlignment(OutcomeText, JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_LEFT)
        set RerollButton = ExpUIButton(EventRoot, 0.285, 0.552, 0.230, 0.030, "사건 리롤", 2300)
        set ResumeButton = ExpUIButton(EventRoot, 0.285, 0.552, 0.230, 0.030, "확인 · 사냥 재개", 2400)
        call ExpUIThemeButton(RerollButton, 2)
        call ExpUIThemeButton(ResumeButton, 2)
        // 장식 BACKDROP과 입력을 받지 않는 TEXT만 사용하며 후보 클릭 콜백은 그대로 둔다.
        set EntryTooltip = ExpUITexture(EventRoot, 0, 0, 0.266, 0.176, "war3mapImported\\UI_Cards_Tooltip.tga")
        call DzFrameSetPriority(EntryTooltip, 110)
        set EntryTooltipIcon = ExpUITexture(EntryTooltip, 0.012, 0.044, 0.046, 0.0613, "ReplaceableTextures\\CommandButtons\\BTNTome.blp")
        set EntryTooltipBorder = ExpUITexture(EntryTooltip, 0.012, 0.044, 0.046, 0.0613, ProtoCardFrame(1))
        call DzFrameSetPriority(EntryTooltipIcon, 110)
        call DzFrameSetPriority(EntryTooltipBorder, 111)
        set EntryTooltipTitle = ExpUILabel(EntryTooltip, 0.012, 0.012, 0.242, 0.024, 0.011, "")
        call DzFrameSetText(EntryTooltipTitle, "|cff83e4e6입문 카드 · 머리 선택 시 함께 획득|r")
        set EntryTooltipText = ExpUILabel(EntryTooltip, 0.072, 0.044, 0.180, 0.164, 0.011, "")
        call JNFrameSetTextAlignment(EntryTooltipText, JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_LEFT)
        call DzFrameShow(EntryTooltip, false)
        set HuntHUD = DzCreateFrameByTagName("FRAME", "", DzGetGameUI(), "", FrameCount())
        call DzFrameSetSize(HuntHUD, 0.40, 0.074)
        call DzFrameSetAbsolutePoint(HuntHUD, JN_FRAMEPOINT_TOPLEFT, 0.245, 0.600)
        call DzFrameSetPriority(HuntHUD, 85)
        set f = ExpUITexture(HuntHUD, 0, 0, 0.40, 0.074, "war3mapImported\\UI_Upgrade_Panel.tga")
        set HuntStatus = ExpUILabel(HuntHUD, 0.012, 0.006, 0.376, 0.044, 0.0085, "")
        set HuntReady = ExpUIButton(HuntHUD, 0.125, 0.052, 0.164, 0.020, "준비 완료", 2500)
        call DzFrameShow(HuntHUD, false)
        call BuildLineTest()
        call BuildPitchSample()
        call TriggerAddAction(ExpRefresh, function Render)
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer i = 0
        call TriggerRegisterTimerEventSingle(t, 0.04)
        call TriggerAddAction(t, function Build)
        set t = CreateTrigger()
        loop
            exitwhen i >= 4
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-줄테스트", true)
            set i = i + 1
        endloop
        call TriggerAddAction(t, function LineTest)
        set t = CreateTrigger()
        set i = 0
        loop
            exitwhen i >= 4
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-행간", false)
            set i = i + 1
        endloop
        call TriggerAddAction(t, function PitchCommand)
        set t = null
    endfunction
endlibrary
