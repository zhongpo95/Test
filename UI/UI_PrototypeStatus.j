// 개인 사냥의 실제 능력치와 보유 카드 격자 및 강화·각성 상세를 표시한다.
library UIPrototypeStatus requires UIExpeditionCommon, StatsSet
    globals
        private integer Canvas
        private integer StatsPanel
        private integer CardsPanel
        private integer Summary
        private integer Detail
        private integer PageText
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
        private integer array Columns
    endglobals

    private function Click takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer i = 1
        if DzGetTriggerUIEventPlayer() != GetLocalPlayer() then
            return
        endif
        loop
            exitwhen i > 26
            if f == ExpUIButtons[Cells[i]] then
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
        call DzFrameShow(Canvas, ExpPrototypeEnabled)
        if not ExpPrototypeEnabled or ExpUIPanel != EXP_UI_STATS then
            return
        endif
        if SeenRun != ExpRun or SeenVersion != ProtoCardRevision[pid] then
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
        call ExpUIText(Summary, "보유 카드 " + I2S(Count) + "장 · 머리 " + I2S(ProtoHeadCount[pid]) + "/2 · 행동력 " + I2S(ProtoAP[pid]) + "/" + I2S(ProtoAPMax[pid]))
        call DzFrameShow(StatsPanel, Tab == 0)
        call DzFrameShow(CardsPanel, Tab == 1)
        if Tab == 0 then
            set value = "현재 적용 능력치|n|n무기 공격력 " + I2S(R2I(Equip_Damage[pid])) + "|n무기 공격력 증가 " + R2SW(Equip_DamageP[pid], 0, 1) + "%|n최종 공격력 " + I2S(R2I(AttackPower(pid))) + "|n치명타 확률 " + R2SW(Stats_Crit[pid], 0, 1) + "%|n치명타 피해 ×" + R2SW(1.0 + (Hero_CriDeal[pid] + Equip_CriDeal[pid] + Arcana_CriDeal[pid] + ProtoStat(pid, PROTO_STAT_CRIT_DAMAGE)) / 100.0, 0, 2)
            set value = value + "|n행동 속도 " + R2SW(SkillSpeed(pid), 0, 1) + "%|n재사용 감소 " + R2SW((1.0 - CooldownRate(pid)) * 100.0, 0, 1) + "%|n이동 속도 " + I2S(R2I(GetUnitMoveSpeed(MainUnit[pid]))) + "|n최대 체력 " + I2S(R2I(GetUnitState(MainUnit[pid], UNIT_STATE_MAX_LIFE)))
            set value = value + "|n추가 피해 " + R2SW(Equip_ED[pid] + Equip_WDP[pid], 0, 1) + "%|n대미지 증가 " + R2SW((Equip_DP[pid] - 1.0) * 100.0 + ProtoStat(pid, PROTO_STAT_DAMAGE), 0, 1) + "%|n최종 대미지 증가 " + R2SW(FinalDamageBonus(pid), 0, 1) + "%"
            call ExpUIText(Columns[0], value)
            set column = 1
            loop
                exitwhen column > 2
                set value = "카드 누적 효과|n|n"
                set i = 1 + (column - 1) * 13
                loop
                    exitwhen i > IMinBJ(column * 13, PROTO_STAT_LAST)
                    set value = value + ProtoEffectText(i, ProtoStat(pid, i)) + "|n"
                    set i = i + 1
                endloop
                call ExpUIText(Columns[column], value)
                set column = column + 1
            endloop
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
                set icon = "ReplaceableTextures\\CommandButtons\\BTNTome.blp"
                if ProtoCardHead[id] > 0 then
                    set icon = ProtoHeadIcon[ProtoCardHead[id]]
                endif
                call DzFrameSetTexture(Icons[i], icon, 0)
                set value = ProtoGradeColor(ProtoCardGrade[id]) + ProtoCardName[id] + "|r|n" + ProtoCardEffectName[id] + "|n강화 +" + I2S(ProtoCardStacks[ExpKey(pid, id)])
                if ProtoEvolved[ExpKey(pid, id)] then
                    set value = value + " · 각성"
                endif
                if Selected == id then
                    set value = "선택 · " + value
                endif
                call ExpUISetButton(Cells[i], value, true)
            endif
            set i = i + 1
        endloop
        call ExpUIText(PageText, I2S(Page + 1) + "/" + I2S(IMaxBJ(1, R2I((Count + 19) / 20))))
        call ExpUISetButton(Cells[23], "이전", Page > 0)
        call ExpUISetButton(Cells[24], "다음", (Page + 1) * 20 < Count)
        set value = "획득한 카드 없음|n|n사건에서 얻은 카드를 이곳에서 확인할 수 있습니다."
        if Selected > 0 and ExpCardOwned[ExpKey(pid, Selected)] then
            set value = ProtoGradeColor(ProtoCardGrade[Selected]) + "[" + ExpEventGradeName(ProtoCardGrade[Selected]) + "] " + ProtoCardName[Selected] + "|r|n|n" + ProtoCardText(pid, Selected)
        endif
        call ExpUIText(Detail, value)
    endfunction

    function ProtoStatusBuild takes integer parent returns nothing
        local integer f
        local integer i = 1
        local real x
        local real y
        set Canvas = DzCreateFrameByTagName("FRAME", "", parent, "", FrameCount())
        call DzFrameSetPoint(Canvas, JN_FRAMEPOINT_TOPLEFT, parent, JN_FRAMEPOINT_TOPLEFT, 0, 0)
        call DzFrameSetSize(Canvas, 0.8, 0.6)
        set f = ExpUITexture(Canvas, 0, 0, 0.8, 0.6, "war3mapImported\\UI_Upgrade_Background.tga")
        set f = ExpUITexture(Canvas, 0, 0, 0.8, 0.044, "war3mapImported\\UI_Upgrade_Header.tga")
        set f = ExpUILabel(Canvas, 0.025, 0.012, 0.60, 0.025, 0.015, "캐릭터 상태 · Tab")
        set Summary = ExpUILabel(Canvas, 0.025, 0.117, 0.75, 0.024, 0.012, "")
        set StatsPanel = DzCreateFrameByTagName("FRAME", "", Canvas, "", FrameCount())
        set CardsPanel = DzCreateFrameByTagName("FRAME", "", Canvas, "", FrameCount())
        call DzFrameSetPoint(StatsPanel, JN_FRAMEPOINT_TOPLEFT, Canvas, JN_FRAMEPOINT_TOPLEFT, 0, 0)
        call DzFrameSetPoint(CardsPanel, JN_FRAMEPOINT_TOPLEFT, Canvas, JN_FRAMEPOINT_TOPLEFT, 0, 0)
        set i = 0
        loop
            exitwhen i > 2
            set f = ExpUITexture(StatsPanel, 0.025 + i * 0.253, 0.155, 0.244, 0.388, "war3mapImported\\UI_Upgrade_Card.tga")
            set Columns[i] = ExpUILabel(StatsPanel, 0.037 + i * 0.253, 0.169, 0.220, 0.360, 0.0105, "")
            call JNFrameSetTextAlignment(Columns[i], JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_LEFT)
            set i = i + 1
        endloop
        set f = ExpUILabel(StatsPanel, 0.025, 0.556, 0.75, 0.025, 0.010, "조건부 피해는 조건 충족 시 적용 · 흡수·재생 합산 최대 체력 10%/초")
        set f = ExpUITexture(CardsPanel, 0.578, 0.155, 0.196, 0.388, "war3mapImported\\UI_Upgrade_Card.tga")
        set Detail = ExpUILabel(CardsPanel, 0.591, 0.169, 0.170, 0.360, 0.011, "")
        call JNFrameSetTextAlignment(Detail, JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_LEFT)
        set i = 1
        loop
            exitwhen i > 20
            set x = 0.025 + ModuloInteger(i - 1, 5) * 0.110
            set y = 0.155 + R2I((i - 1) / 5) * 0.097
            set Cells[i] = ExpUICoverButton(CardsPanel, 0)
            call DzFrameClearAllPoints(ExpUIButtons[Cells[i]])
            call DzFrameSetPoint(ExpUIButtons[Cells[i]], JN_FRAMEPOINT_TOPLEFT, CardsPanel, JN_FRAMEPOINT_TOPLEFT, x, -y)
            call ExpUIResizeCover(Cells[i], 0.102, 0.091)
            set Icons[i] = ExpUITexture(ExpUIButtons[Cells[i]], 0.037, 0.006, 0.028, 0.028, "ReplaceableTextures\\CommandButtons\\BTNTome.blp")
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
        set Cells[23] = ExpUIButton(CardsPanel, 0.025, 0.553, 0.075, 0.027, "이전", 0)
        set Cells[24] = ExpUIButton(CardsPanel, 0.170, 0.553, 0.075, 0.027, "다음", 0)
        set Cells[25] = ExpUIButton(CardsPanel, 0.303, 0.553, 0.110, 0.027, "지역순", 0)
        set Cells[26] = ExpUIButton(CardsPanel, 0.425, 0.553, 0.110, 0.027, "희귀도순", 0)
        set PageText = ExpUILabel(CardsPanel, 0.112, 0.557, 0.050, 0.022, 0.011, "")
        set i = 21
        loop
            exitwhen i > 26
            call DzFrameSetScriptByCode(ExpUIButtons[Cells[i]], JN_FRAMEEVENT_MOUSE_UP, function Click, false)
            set i = i + 1
        endloop
        call DzFrameShow(Canvas, false)
    endfunction
endlibrary
