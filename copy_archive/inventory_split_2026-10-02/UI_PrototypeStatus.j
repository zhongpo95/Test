// 개인 사냥의 실제 능력치와 보유 카드 격자 및 강화·각성 상세를 표시한다.
library UIPrototypeStatus initializer Init requires UIExpeditionCommon, StatsSet
    globals
        private integer Canvas
        private integer StatsPanel
        private integer CardsPanel
        private integer Summary
        private integer Artwork
        private integer Tooltip
        private integer TooltipText
        private integer TooltipIcon
        private integer Hover = 0
        private integer array Hotspots
        private integer Detail
        private integer PageText
        private integer ClickCount = 0
        private integer ClickStep = 0
        private integer RenderStep = 0
        private integer Tab = 0
        private integer Page = 0
        private integer Selected = 0
        private integer Sort = 0
        private integer SeenRun = -1
        private integer SeenVersion = -1
        private integer Count = 0
        private integer array Cards
        private integer array Cells
        private integer array Icons
        private integer array ActualValues
        private integer array Columns
    endglobals

    // 등급 강조가 끝나도 어두운 배경에 맞는 본문 색을 유지한다.
    private function StatusText takes integer frame, string value returns nothing
        call DzFrameSetText(frame, "|cffe7edf3" + JNStringReplace(value, "|r", "|cffe7edf3") + "|r")
    endfunction

    private function StatusLabel takes integer parent, real x, real y, real width, real height, real size, string value returns integer
        local integer f = ExpUILabel(parent, x, y, width, height, size, "")
        call StatusText(f, value)
        return f
    endfunction

    private function CardColor takes integer grade returns string
        if grade == 4 then
            return "|cffffd37d"
        elseif grade == 3 then
            return "|cffd6abff"
        elseif grade == 2 then
            return "|cff74ccff"
        endif
        return "|cffe7edf3"
    endfunction

    // 카드 전용 일러스트가 연결되기 전에는 현재 등록된 지역 아이콘을 사용한다.
    private function CardArt takes integer id returns string
        if ProtoCardHead[id] > 0 then
            return ProtoHeadIcon[ProtoCardHead[id]]
        endif
        return "ReplaceableTextures\\CommandButtons\\BTNTome.blp"
    endfunction

    private function EnterIcon takes nothing returns nothing
        local integer i = 1
        if DzGetTriggerUIEventPlayer() != GetLocalPlayer() then
            return
        endif
        loop
            exitwhen i > 20
            if DzGetTriggerUIEventFrame() == Hotspots[i] then
                set Hover = i
                return
            endif
            set i = i + 1
        endloop
    endfunction

    private function LeaveIcon takes nothing returns nothing
        if DzGetTriggerUIEventPlayer() == GetLocalPlayer() then
            set Hover = 0
            call DzFrameShow(Tooltip, false)
        endif
    endfunction

    private function Click takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer i = 1
        if DzGetTriggerUIEventPlayer() != GetLocalPlayer() then
            return
        endif
        set ClickCount = ClickCount + 1
        set ClickStep = 1
        set Hover = 0
        call DzFrameShow(Tooltip, false)
        set ClickStep = 2
        loop
            exitwhen i > 26
            if f == ExpUIButtons[Cells[i]] or (i <= 20 and f == Hotspots[i]) then
                set ClickStep = 100 + i
                if i <= 20 then
                    set Selected = Cards[Page * 20 + i]
                elseif i == 21 then
                    set Tab = 0
                elseif i == 22 then
                    set Tab = 1
                elseif i == 23 then
                    set Page = IMaxBJ(0, Page - 1)
                elseif i == 24 then
                    set Page = IMinBJ(IMaxBJ(0, R2I((Count - 1) / 20)), Page + 1)
                elseif i == 25 then
                    set Sort = 0
                    set SeenVersion = -1
                else
                    set Sort = 1
                    set SeenVersion = -1
                endif
                return
            endif
            set i = i + 1
        endloop
    endfunction

    function ProtoStatusRender takes integer pid returns nothing
        local integer i
        local integer grade
        local integer id
        local integer column
        local string value
        local string icon
        local real x
        local real y
        set RenderStep = 1
        call DzFrameShow(Canvas, ExpPrototypeEnabled)
        if not ExpPrototypeEnabled or ExpUIPanel != EXP_UI_STATS then
            set Hover = 0
            call DzFrameShow(Tooltip, false)
            return
        endif
        if SeenRun != ExpRun or SeenVersion != ProtoCardRevision[pid] then
            set Hover = 0
            set Count = 0
            set grade = 4
            loop
                exitwhen grade < 1
                set id = PROTO_CARD_FIRST
                loop
                    exitwhen id > PROTO_CARD_LAST
                    if ExpCardOwned[ExpKey(pid, id)] and (Sort == 0 or ProtoCardGrade[id] == grade) then
                        set Count = Count + 1
                        set Cards[Count] = id
                    endif
                    set id = id + 1
                endloop
                if Sort == 0 then
                    exitwhen true
                endif
                set grade = grade - 1
            endloop
            if SeenRun != ExpRun or Selected == 0 or not ExpCardOwned[ExpKey(pid, Selected)] then
                set Selected = Cards[1]
            endif
            if Count == 0 then
                set Selected = 0
            endif
            set SeenRun = ExpRun
            set SeenVersion = ProtoCardRevision[pid]
            set Page = IMaxBJ(0, IMinBJ(Page, R2I((Count - 1) / 20)))
        endif
        call StatusText(Summary, "보유 카드 " + I2S(Count) + "장 · 머리 " + I2S(ProtoHeadCount[pid]) + "/2 · 행동력 " + I2S(ProtoAP[pid]) + "/" + I2S(ProtoAPMax[pid]))
        call ExpUISetButton(Cells[21], "능력치", true)
        call ExpUISetButton(Cells[22], "보유 카드", true)
        call ExpUISelectButton(Cells[21], Tab == 0)
        call ExpUISelectButton(Cells[22], Tab == 1)
        set RenderStep = 2
        call DzFrameShow(StatsPanel, Tab == 0)
        set RenderStep = 3
        call DzFrameShow(CardsPanel, Tab == 1)
        set RenderStep = 4
        call DzFrameShow(Tooltip, false)
        set RenderStep = 5
        if Tab == 0 then
            set Hover = 0
            call StatusText(ActualValues[0], I2S(R2I(Equip_Damage[pid])))
            call StatusText(ActualValues[1], R2SW(Equip_DamageP[pid], 0, 1) + "%")
            call StatusText(ActualValues[2], I2S(R2I(AttackPower(pid))))
            call StatusText(ActualValues[3], R2SW(Stats_Crit[pid], 0, 1) + "%")
            call StatusText(ActualValues[4], "×" + R2SW(1.0 + (Hero_CriDeal[pid] + Equip_CriDeal[pid] + Arcana_CriDeal[pid] + ProtoStat(pid, PROTO_STAT_CRIT_DAMAGE)) / 100.0, 0, 2))
            call StatusText(ActualValues[5], R2SW(SkillSpeed(pid), 0, 1) + "%")
            call StatusText(ActualValues[6], R2SW((1.0 - CooldownRate(pid)) * 100.0, 0, 1) + "%")
            call StatusText(ActualValues[7], I2S(R2I(GetUnitMoveSpeed(MainUnit[pid]))))
            call StatusText(ActualValues[8], I2S(R2I(GetUnitState(MainUnit[pid], UNIT_STATE_MAX_LIFE))))
            call StatusText(ActualValues[9], R2SW(Equip_ED[pid] + Equip_WDP[pid], 0, 1) + "%")
            call StatusText(ActualValues[10], R2SW((Equip_DP[pid] - 1.0) * 100.0 + ProtoStat(pid, PROTO_STAT_DAMAGE), 0, 1) + "%")
            call StatusText(ActualValues[11], R2SW(FinalDamageBonus(pid), 0, 1) + "%")
            set column = 1
            loop
                exitwhen column > 2
                set value = ""
                set i = 1 + (column - 1) * 13
                loop
                    exitwhen i > IMinBJ(column * 13, PROTO_STAT_LAST)
                    if ProtoStat(pid, i) != 0.0 then
                        if value != "" then
                            set value = value + "|n|n"
                        endif
                        set value = value + ProtoEffectText(i, ProtoStat(pid, i))
                    endif
                    set i = i + 1
                endloop
                if value == "" then
                    set value = "아직 획득한 효과가 없습니다."
                endif
                call StatusText(Columns[column], value)
                set column = column + 1
            endloop
            set RenderStep = 6
            return
        endif
        set i = 1
        loop
            exitwhen i > 20
            set id = 0
            if Page * 20 + i <= Count then
                set id = Cards[Page * 20 + i]
            endif
            call DzFrameShow(ExpUIButtons[Cells[i]], id > 0)
            if id > 0 then
                set icon = CardArt(id)
                call DzFrameSetTexture(Icons[i], icon, 0)
                set value = CardColor(ProtoCardGrade[id]) + ProtoCardName[id] + "|r|n" + ProtoCardEffectName[id] + "|n강화 +" + I2S(ProtoCardStacks[ExpKey(pid, id)])
                if ProtoEvolved[ExpKey(pid, id)] then
                    set value = value + " · 각성"
                endif
                call ExpUISetButton(Cells[i], value, true)
                call ExpUISelectButton(Cells[i], Selected == id)
            endif
            set i = i + 1
        endloop
        call StatusText(PageText, I2S(Page + 1) + "/" + I2S(IMaxBJ(1, R2I((Count + 19) / 20))))
        call ExpUISetButton(Cells[25], "지역순", true)
        call ExpUISetButton(Cells[26], "희귀도순", true)
        call ExpUISelectButton(Cells[25], Sort == 0)
        call ExpUISelectButton(Cells[26], Sort == 1)
        call ExpUISetButton(Cells[23], "이전", Page > 0)
        call ExpUISetButton(Cells[24], "다음", (Page + 1) * 20 < Count)
        call DzFrameShow(Artwork, Selected > 0)
        set value = "획득한 카드 없음"
        if Selected > 0 and ExpCardOwned[ExpKey(pid, Selected)] then
            call DzFrameSetTexture(Artwork, CardArt(Selected), 0)
            set value = CardColor(ProtoCardGrade[Selected]) + "[" + ExpEventGradeName(ProtoCardGrade[Selected]) + "] " + ProtoCardName[Selected] + "|r|n" + ProtoCardEffectName[Selected] + "|n강화 +" + I2S(ProtoCardStacks[ExpKey(pid, Selected)])
        endif
        set RenderStep = 7
        call StatusText(Detail, value)
        if Hover > 0 and Page * 20 + Hover <= Count then
            set id = Cards[Page * 20 + Hover]
            set x = 0.100 + ModuloInteger(Hover - 1, 5) * 0.110
            if x + 0.232 > 0.774 then
                set x = x - 0.300
            endif
            set y = RMinBJ(0.155 + R2I((Hover - 1) / 5) * 0.097, 0.295)
            call DzFrameClearAllPoints(Tooltip)
            call DzFrameSetPoint(Tooltip, JN_FRAMEPOINT_TOPLEFT, Canvas, JN_FRAMEPOINT_TOPLEFT, x, -y)
            call DzFrameSetTexture(TooltipIcon, CardArt(id), 0)
            call StatusText(TooltipText, CardColor(ProtoCardGrade[id]) + "[" + ExpEventGradeName(ProtoCardGrade[id]) + "] " + ProtoCardName[id] + "|r|n|n" + ProtoCardText(pid, id))
            call DzFrameShow(Tooltip, true)
        endif
    endfunction

    // 진단은 요청한 클라이언트에서 UI 상태만 읽으며 전투 데이터나 동기화 명령을 바꾸지 않는다.
    private function Diagnose takes nothing returns nothing
        if GetTriggerPlayer() != GetLocalPlayer() then
            return
        endif
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 30, "상태창 진단 · panel=" + I2S(ExpUIPanel) + " tab=" + I2S(Tab) + " clicks=" + I2S(ClickCount) + " clickStep=" + I2S(ClickStep) + " renderStep=" + I2S(RenderStep))
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 30, "frame · stats=" + I2S(StatsPanel) + " cards=" + I2S(CardsPanel) + " tip=" + I2S(Tooltip) + " tabButton=" + I2S(ExpUIButtons[Cells[22]]))
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer i = 0
        loop
            exitwhen i > 3
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-상태진단", true)
            set i = i + 1
        endloop
        call TriggerAddAction(t, function Diagnose)
        set t = null
    endfunction

    function ProtoStatusBuild takes integer parent returns nothing
        local integer f
        local integer i = 1
        local real x
        local real y
        set Canvas = DzCreateFrameByTagName("FRAME", "", parent, "", FrameCount())
        call DzFrameSetPoint(Canvas, JN_FRAMEPOINT_TOPLEFT, parent, JN_FRAMEPOINT_TOPLEFT, 0, 0)
        call DzFrameSetSize(Canvas, 0.8, 0.6)
        call DzFrameSetPriority(Canvas, 90)
        call ExpUISetToggleOverlay(EXP_UI_STATS, Canvas)
        set f = ExpUITexture(Canvas, 0, 0, 0.8, 0.6, "war3mapImported\\UI_Arcana_Ink.tga")
        set f = ExpUITexture(Canvas, 0, 0, 0.8, 0.044, "war3mapImported\\UI_Arcana_Ink.tga")
        set f = StatusLabel(Canvas, 0.025, 0.012, 0.60, 0.025, 0.015, "CHARACTER  /  캐릭터 상태")
        set f = ExpUITexture(Canvas, 0.025, 0.055, 0.750, 0.001, "war3mapImported\\UI_Arcana_Rule.tga")
        set Summary = StatusLabel(Canvas, 0.025, 0.117, 0.75, 0.024, 0.012, "")
        set StatsPanel = DzCreateFrameByTagName("FRAME", "", Canvas, "", FrameCount())
        set CardsPanel = DzCreateFrameByTagName("FRAME", "", Canvas, "", FrameCount())
        call DzFrameSetPoint(StatsPanel, JN_FRAMEPOINT_TOPLEFT, Canvas, JN_FRAMEPOINT_TOPLEFT, 0, -0.145)
        call DzFrameSetPoint(CardsPanel, JN_FRAMEPOINT_TOPLEFT, Canvas, JN_FRAMEPOINT_TOPLEFT, 0, -0.145)
        // 본문 입력 영역은 상단 탭과 겹치지 않게 요약 아래로 제한한다.
        call DzFrameSetSize(StatsPanel, 0.8, 0.455)
        call DzFrameSetSize(CardsPanel, 0.8, 0.455)
        call DzFrameSetPriority(StatsPanel, 91)
        call DzFrameSetPriority(CardsPanel, 91)
        set f = ExpUITexture(StatsPanel, 0.025, 0.010, 0.244, 0.388, "war3mapImported\\UI_Arcana_Panel.tga")
        set Columns[0] = StatusLabel(StatsPanel, 0.037, 0.024, 0.220, 0.028, 0.013, "현재 적용 능력치")
        set f = StatusLabel(StatsPanel, 0.039, 0.069, 0.145, 0.024, 0.0105, "무기 공격력")
        set ActualValues[0] = StatusLabel(StatsPanel, 0.187, 0.069, 0.066, 0.024, 0.012, "")
        call JNFrameSetTextAlignment(ActualValues[0], JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_RIGHT)
        set f = StatusLabel(StatsPanel, 0.039, 0.095, 0.145, 0.024, 0.0105, "무기 공격력 증가")
        set ActualValues[1] = StatusLabel(StatsPanel, 0.187, 0.095, 0.066, 0.024, 0.012, "")
        call JNFrameSetTextAlignment(ActualValues[1], JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_RIGHT)
        set f = StatusLabel(StatsPanel, 0.039, 0.121, 0.145, 0.024, 0.0105, "최종 공격력")
        set ActualValues[2] = StatusLabel(StatsPanel, 0.187, 0.121, 0.066, 0.024, 0.012, "")
        call JNFrameSetTextAlignment(ActualValues[2], JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_RIGHT)
        set f = StatusLabel(StatsPanel, 0.039, 0.147, 0.145, 0.024, 0.0105, "치명타 확률")
        set ActualValues[3] = StatusLabel(StatsPanel, 0.187, 0.147, 0.066, 0.024, 0.012, "")
        call JNFrameSetTextAlignment(ActualValues[3], JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_RIGHT)
        set f = StatusLabel(StatsPanel, 0.039, 0.173, 0.145, 0.024, 0.0105, "치명타 피해")
        set ActualValues[4] = StatusLabel(StatsPanel, 0.187, 0.173, 0.066, 0.024, 0.012, "")
        call JNFrameSetTextAlignment(ActualValues[4], JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_RIGHT)
        set f = StatusLabel(StatsPanel, 0.039, 0.199, 0.145, 0.024, 0.0105, "행동 속도")
        set ActualValues[5] = StatusLabel(StatsPanel, 0.187, 0.199, 0.066, 0.024, 0.012, "")
        call JNFrameSetTextAlignment(ActualValues[5], JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_RIGHT)
        set f = StatusLabel(StatsPanel, 0.039, 0.225, 0.145, 0.024, 0.0105, "재사용 감소")
        set ActualValues[6] = StatusLabel(StatsPanel, 0.187, 0.225, 0.066, 0.024, 0.012, "")
        call JNFrameSetTextAlignment(ActualValues[6], JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_RIGHT)
        set f = StatusLabel(StatsPanel, 0.039, 0.251, 0.145, 0.024, 0.0105, "이동 속도")
        set ActualValues[7] = StatusLabel(StatsPanel, 0.187, 0.251, 0.066, 0.024, 0.012, "")
        call JNFrameSetTextAlignment(ActualValues[7], JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_RIGHT)
        set f = StatusLabel(StatsPanel, 0.039, 0.277, 0.145, 0.024, 0.0105, "최대 체력")
        set ActualValues[8] = StatusLabel(StatsPanel, 0.187, 0.277, 0.066, 0.024, 0.012, "")
        call JNFrameSetTextAlignment(ActualValues[8], JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_RIGHT)
        set f = StatusLabel(StatsPanel, 0.039, 0.303, 0.145, 0.024, 0.0105, "추가 피해")
        set ActualValues[9] = StatusLabel(StatsPanel, 0.187, 0.303, 0.066, 0.024, 0.012, "")
        call JNFrameSetTextAlignment(ActualValues[9], JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_RIGHT)
        set f = StatusLabel(StatsPanel, 0.039, 0.329, 0.145, 0.024, 0.0105, "대미지 증가")
        set ActualValues[10] = StatusLabel(StatsPanel, 0.187, 0.329, 0.066, 0.024, 0.012, "")
        call JNFrameSetTextAlignment(ActualValues[10], JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_RIGHT)
        set f = StatusLabel(StatsPanel, 0.039, 0.355, 0.145, 0.024, 0.0105, "최종 대미지 증가")
        set ActualValues[11] = StatusLabel(StatsPanel, 0.187, 0.355, 0.066, 0.024, 0.012, "")
        call JNFrameSetTextAlignment(ActualValues[11], JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_RIGHT)
        set i = 1
        loop
            exitwhen i > 2
            set f = ExpUITexture(StatsPanel, 0.025 + i * 0.253, 0.010, 0.244, 0.388, "war3mapImported\\UI_Arcana_Panel.tga")
            if i == 1 then
                set f = StatusLabel(StatsPanel, 0.037 + i * 0.253, 0.024, 0.220, 0.030, 0.013, "카드 성장 효과")
            else
                set f = StatusLabel(StatsPanel, 0.037 + i * 0.253, 0.024, 0.220, 0.030, 0.013, "조건부 효과 · 생존")
            endif
            set Columns[i] = StatusLabel(StatsPanel, 0.037 + i * 0.253, 0.069, 0.220, 0.320, 0.010, "")
            call JNFrameSetTextAlignment(Columns[i], JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_LEFT)
            set i = i + 1
        endloop
        set f = StatusLabel(StatsPanel, 0.025, 0.411, 0.75, 0.025, 0.010, "조건부 피해는 조건 충족 시 적용 · 흡수·재생 합산 최대 체력 10%/초")
        set f = ExpUITexture(CardsPanel, 0.578, 0.010, 0.196, 0.388, "war3mapImported\\UI_Arcana_Panel.tga")
        set Artwork = ExpUITexture(CardsPanel, 0.589, 0.025, 0.174, 0.232, "ReplaceableTextures\\CommandButtons\\BTNTome.blp")
        set Detail = StatusLabel(CardsPanel, 0.591, 0.280, 0.170, 0.080, 0.011, "")
        set f = StatusLabel(CardsPanel, 0.591, 0.366, 0.170, 0.025, 0.009, "아이콘에 마우스를 올려 효과 확인")
        call JNFrameSetTextAlignment(Detail, JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_LEFT)
        set i = 1
        loop
            exitwhen i > 20
            set x = 0.025 + ModuloInteger(i - 1, 5) * 0.110
            set y = 0.010 + R2I((i - 1) / 5) * 0.097
            set Cells[i] = ExpUICoverButton(CardsPanel, 0)
            call ExpUIThemeButton(Cells[i], 1)
            call DzFrameClearAllPoints(ExpUIButtons[Cells[i]])
            call DzFrameSetPoint(ExpUIButtons[Cells[i]], JN_FRAMEPOINT_TOPLEFT, CardsPanel, JN_FRAMEPOINT_TOPLEFT, x, -y)
            call ExpUIResizeCover(Cells[i], 0.102, 0.091)
            set Hotspots[i] = DzCreateFrameByTagName("BUTTON", "", ExpUIButtons[Cells[i]], "", FrameCount())
            call DzFrameSetPoint(Hotspots[i], JN_FRAMEPOINT_TOPLEFT, ExpUIButtons[Cells[i]], JN_FRAMEPOINT_TOPLEFT, 0.037, -0.003)
            call DzFrameSetSize(Hotspots[i], 0.028, 0.037)
            call DzFrameSetScriptByCode(Hotspots[i], JN_FRAMEEVENT_MOUSE_ENTER, function EnterIcon, false)
            call DzFrameSetScriptByCode(Hotspots[i], JN_FRAMEEVENT_MOUSE_LEAVE, function LeaveIcon, false)
            call DzFrameSetScriptByCode(Hotspots[i], JN_FRAMEEVENT_MOUSE_UP, function Click, false)
            set Icons[i] = ExpUITexture(Hotspots[i], 0, 0, 0.028, 0.037, "ReplaceableTextures\\CommandButtons\\BTNTome.blp")
            call DzFrameClearAllPoints(ExpUIButtonLabels[Cells[i]])
            call DzFrameSetPoint(ExpUIButtonLabels[Cells[i]], JN_FRAMEPOINT_TOPLEFT, ExpUIButtons[Cells[i]], JN_FRAMEPOINT_TOPLEFT, 0.006, -0.038)
            call DzFrameSetSize(ExpUIButtonLabels[Cells[i]], 0.090, 0.049)
            call DzFrameSetFont(ExpUIButtonLabels[Cells[i]], "Fonts\\DFHeiMd.ttf", 0.009, 0)
            call JNFrameSetTextAlignment(ExpUIButtonLabels[Cells[i]], JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_LEFT)
            call DzFrameSetScriptByCode(ExpUIButtons[Cells[i]], JN_FRAMEEVENT_MOUSE_UP, function Click, false)
            set i = i + 1
        endloop
        set Cells[21] = ExpUIButton(Canvas, 0.025, 0.080, 0.130, 0.027, "능력치", 0)
        set Cells[22] = ExpUIButton(Canvas, 0.167, 0.080, 0.130, 0.027, "보유 카드", 0)
        set Cells[23] = ExpUIButton(CardsPanel, 0.025, 0.408, 0.075, 0.027, "이전", 0)
        set Cells[24] = ExpUIButton(CardsPanel, 0.170, 0.408, 0.075, 0.027, "다음", 0)
        set Cells[25] = ExpUIButton(CardsPanel, 0.303, 0.408, 0.110, 0.027, "지역순", 0)
        set Cells[26] = ExpUIButton(CardsPanel, 0.425, 0.408, 0.110, 0.027, "희귀도순", 0)
        set PageText = StatusLabel(CardsPanel, 0.112, 0.412, 0.050, 0.022, 0.011, "")
        set i = 21
        loop
            exitwhen i > 26
            call ExpUIThemeButton(Cells[i], 1)
            call DzFrameSetScriptByCode(ExpUIButtons[Cells[i]], JN_FRAMEEVENT_MOUSE_UP, function Click, false)
            set i = i + 1
        endloop
        set Tooltip = ExpUITexture(CardsPanel, 0, 0, 0.232, 0.290, "war3mapImported\\UI_Arcana_Panel.tga")
        call DzFrameSetPriority(Tooltip, 110)
        set TooltipIcon = ExpUITexture(Tooltip, 0.012, 0.010, 0.036, 0.048, "ReplaceableTextures\\CommandButtons\\BTNTome.blp")
        set TooltipText = StatusLabel(Tooltip, 0.012, 0.066, 0.208, 0.212, 0.010, "")
        call JNFrameSetTextAlignment(TooltipText, JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_LEFT)
        call DzFrameShow(Tooltip, false)
        call DzFrameShow(Canvas, false)
    endfunction
endlibrary
