// Tab 전용 실제 능력치와 카드 누적 효과를 표시한다. 카드 보관함은 별도 UI가 담당한다.
library UIPrototypeStatus initializer Init requires UIExpeditionCommon, StatsSet
    globals
        private integer Canvas
        private integer StatsPanel
        private integer Summary
        private integer RenderStep = 0
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

    function ProtoStatusRender takes integer pid returns nothing
        local integer i
        local integer column
        local string value
        set RenderStep = 1
        call DzFrameShow(Canvas, ExpPrototypeEnabled)
        if not ExpPrototypeEnabled or ExpUIPanel != EXP_UI_STATS then
            return
        endif
        call StatusText(Summary, "실제 적용 수치와 카드 누적 효과 · 보유 카드는 I키로 확인")
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
    endfunction

    private function Diagnose takes nothing returns nothing
        if GetTriggerPlayer() == GetLocalPlayer() then
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 30, "상태창 진단 · panel=" + I2S(ExpUIPanel) + " renderStep=" + I2S(RenderStep))
        endif
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
        local integer i
        set Canvas = DzCreateFrameByTagName("FRAME", "", parent, "", FrameCount())
        call DzFrameSetPoint(Canvas, JN_FRAMEPOINT_TOPLEFT, parent, JN_FRAMEPOINT_TOPLEFT, 0, 0)
        call DzFrameSetSize(Canvas, 0.8, 0.6)
        call DzFrameSetPriority(Canvas, 90)
        call ExpUISetToggleOverlay(EXP_UI_STATS, Canvas)
        set f = ExpUITexture(Canvas, 0, 0, 0.8, 0.6, "war3mapImported\\UI_Arcana_Ink.tga")
        set f = StatusLabel(Canvas, 0.025, 0.020, 0.60, 0.035, 0.018, "능력치 · Tab")
        set f = ExpUITexture(Canvas, 0.025, 0.065, 0.750, 0.001, "war3mapImported\\UI_Arcana_Rule.tga")
        set Summary = StatusLabel(Canvas, 0.025, 0.081, 0.75, 0.025, 0.011, "")
        set StatsPanel = DzCreateFrameByTagName("FRAME", "", Canvas, "", FrameCount())
        call DzFrameSetPoint(StatsPanel, JN_FRAMEPOINT_TOPLEFT, Canvas, JN_FRAMEPOINT_TOPLEFT, 0, -0.115)
        call DzFrameSetSize(StatsPanel, 0.8, 0.485)
        call DzFrameSetPriority(StatsPanel, 91)
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
        call DzFrameShow(Canvas, false)
    endfunction
endlibrary
