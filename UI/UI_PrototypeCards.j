// I키 보유 카드 보관함을 10열 아이콘 격자와 호버 설명으로 표시한다.
library UIPrototypeCards initializer Init requires UIExpeditionCommon, UIInputGate
    globals
        private integer Root
        private integer Summary
        private integer PageText
        private integer Previous
        private integer Next
        private integer RegionSort
        private integer GradeSort
        private integer Tooltip
        private integer TooltipIcon
        private integer TooltipText
        private integer Hover = 0
        private integer Page = 0
        private integer Sort = 0
        private integer Count = 0
        private integer SeenRun = -1
        private integer SeenVersion = -1
        private integer array Cards
        private integer array Cells
        private integer array Icons
    endglobals

    private function Text takes integer frame, string value returns nothing
        call DzFrameSetText(frame, "|cffe7edf3" + JNStringReplace(value, "|r", "|cffe7edf3") + "|r")
    endfunction

    private function Art takes integer id returns string
        if ProtoCardHead[id] > 0 then
            return ProtoHeadIcon[ProtoCardHead[id]]
        endif
        return "ReplaceableTextures\\CommandButtons\\BTNTome.blp"
    endfunction

    private function Color takes integer grade returns string
        if grade == 4 then
            return "|cffffd37d"
        elseif grade == 3 then
            return "|cffd6abff"
        elseif grade == 2 then
            return "|cff74ccff"
        endif
        return "|cffe7edf3"
    endfunction

    private function Enter takes nothing returns nothing
        local integer i = 1
        if DzGetTriggerUIEventPlayer() != GetLocalPlayer() then
            return
        endif
        loop
            exitwhen i > 50
            if DzGetTriggerUIEventFrame() == ExpUIButtons[Cells[i]] then
                set Hover = i
                return
            endif
            set i = i + 1
        endloop
    endfunction

    private function Leave takes nothing returns nothing
        if DzGetTriggerUIEventPlayer() == GetLocalPlayer() then
            set Hover = 0
            call DzFrameShow(Tooltip, false)
        endif
    endfunction

    private function Click takes nothing returns nothing
        local integer frame = DzGetTriggerUIEventFrame()
        if DzGetTriggerUIEventPlayer() != GetLocalPlayer() then
            return
        endif
        set Hover = 0
        call DzFrameShow(Tooltip, false)
        if frame == ExpUIButtons[Previous] then
            set Page = IMaxBJ(0, Page - 1)
        elseif frame == ExpUIButtons[Next] then
            set Page = IMinBJ(IMaxBJ(0, R2I((Count - 1) / 50)), Page + 1)
        elseif frame == ExpUIButtons[RegionSort] then
            set Sort = 0
            set SeenVersion = -1
        elseif frame == ExpUIButtons[GradeSort] then
            set Sort = 1
            set SeenVersion = -1
        endif
    endfunction

    private function Render takes nothing returns nothing
        local integer pid = GetPlayerId(GetLocalPlayer())
        local integer i = 1
        local integer id
        local integer grade
        local real x
        local real y
        local string value
        if Root == 0 then
            return
        endif
        call DzFrameShow(Tooltip, false)
        if pid > 3 or not ExpPrototypeEnabled or ExpUIPanel != EXP_UI_CARDS or not PickCheck[pid] or F_UpgradeOnOff[pid] then
            set Hover = 0
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
            if SeenRun != ExpRun then
                set Page = 0
            endif
            set SeenRun = ExpRun
            set SeenVersion = ProtoCardRevision[pid]
            set Page = IMaxBJ(0, IMinBJ(Page, R2I((Count - 1) / 50)))
        endif
        call Text(Summary, "보유 카드 " + I2S(Count) + "장 · 머리 " + I2S(ProtoHeadCount[pid]) + "/2")
        loop
            exitwhen i > 50
            set id = 0
            if Page * 50 + i <= Count then
                set id = Cards[Page * 50 + i]
            endif
            call ExpUISetButton(Cells[i], "", id > 0)
            call ExpUISelectButton(Cells[i], Hover == i)
            call DzFrameShow(Icons[i], id > 0)
            if id > 0 then
                call DzFrameSetTexture(Icons[i], Art(id), 0)
                set value = ""
                if ProtoCardStacks[ExpKey(pid, id)] > 0 then
                    set value = "+" + I2S(ProtoCardStacks[ExpKey(pid, id)])
                endif
                if ProtoEvolved[ExpKey(pid, id)] then
                    set value = "★ " + value
                endif
                call Text(ExpUIButtonLabels[Cells[i]], Color(ProtoCardGrade[id]) + value)
            endif
            set i = i + 1
        endloop
        call Text(PageText, I2S(Page + 1) + " / " + I2S(IMaxBJ(1, R2I((Count + 49) / 50))))
        call ExpUISetButton(Previous, "이전", Page > 0)
        call ExpUISetButton(Next, "다음", (Page + 1) * 50 < Count)
        call ExpUISetButton(RegionSort, "지역순", true)
        call ExpUISetButton(GradeSort, "희귀도순", true)
        call ExpUISelectButton(RegionSort, Sort == 0)
        call ExpUISelectButton(GradeSort, Sort == 1)
        if Hover > 0 and Page * 50 + Hover <= Count then
            set id = Cards[Page * 50 + Hover]
            set x = 0.226 + ModuloInteger(Hover - 1, 10) * 0.042
            if x + 0.230 > 0.785 then
                set x = x - 0.276
            endif
            set y = RMaxBJ(0.320, 0.485 - R2I((Hover - 1) / 10) * 0.056)
            call DzFrameClearAllPoints(Tooltip)
            call DzFrameSetAbsolutePoint(Tooltip, JN_FRAMEPOINT_TOPLEFT, x, y)
            call DzFrameSetTexture(TooltipIcon, Art(id), 0)
            call Text(TooltipText, Color(ProtoCardGrade[id]) + "[" + ExpEventGradeName(ProtoCardGrade[id]) + "] " + ProtoCardName[id] + "|r|n|n" + ProtoCardText(pid, id))
            call DzFrameShow(Tooltip, true)
        endif
    endfunction

    private function IKey takes nothing returns nothing
        local integer pid = GetPlayerId(DzGetTriggerKeyPlayer())
        if DzGetTriggerKeyPlayer() != GetLocalPlayer() or pid > 3 then
            return
        endif
        if not PickCheck[pid] or not ExpPrototypeEnabled then
            return
        endif
        if JNMemoryGetByte(JNGetModuleHandle("Game.dll") + 0xD04FEC) == 1 then
            return
        endif
        set Hover = 0
        call DzFrameShow(Tooltip, false)
        if ExpUIPanel == EXP_UI_CARDS then
            call ExpUIOpen(0)
        else
            call ExpUIOpen(EXP_UI_CARDS)
        endif
    endfunction

    private function BindInput takes nothing returns boolean
        if Root == 0 then
            return false
        endif
        call DzTriggerRegisterKeyEventByCode(null, 'I', 0, false, function IKey)
        return true
    endfunction

    private function Build takes nothing returns nothing
        local integer f
        local integer i = 1
        local real x
        local real y
        set Root = ExpUIRoot(EXP_UI_CARDS, 0.46, 0.38, 0.535, false)
        set f = ExpUITexture(Root, 0, 0, 0.46, 0.38, "war3mapImported\\UI_Arcana_Panel.tga")
        set f = ExpUILabel(Root, 0.014, 0.011, 0.19, 0.026, 0.014, "")
        call Text(f, "보유 카드 · I")
        set Summary = ExpUILabel(Root, 0.200, 0.016, 0.207, 0.023, 0.010, "")
        set f = ExpUIPanelToggle(Root, 0.422, 0.009, 0.026, 0.027)
        call ExpUIThemeButton(f, 1)
        loop
            exitwhen i > 50
            set x = 0.022 + ModuloInteger(i - 1, 10) * 0.042
            set y = 0.050 + R2I((i - 1) / 10) * 0.056
            set Cells[i] = ExpUICoverButton(Root, 0)
            call ExpUIThemeButton(Cells[i], 3)
            call DzFrameClearAllPoints(ExpUIButtons[Cells[i]])
            call DzFrameSetPoint(ExpUIButtons[Cells[i]], JN_FRAMEPOINT_TOPLEFT, Root, JN_FRAMEPOINT_TOPLEFT, x, -y)
            call ExpUIResizeCover(Cells[i], 0.038, 0.0507)
            set Icons[i] = ExpUITexture(ExpUIButtons[Cells[i]], 0.002, 0.0027, 0.034, 0.0453, "ReplaceableTextures\\CommandButtons\\BTNTome.blp")
            call DzFrameClearAllPoints(ExpUIButtonLabels[Cells[i]])
            call DzFrameSetPoint(ExpUIButtonLabels[Cells[i]], JN_FRAMEPOINT_TOPLEFT, ExpUIButtons[Cells[i]], JN_FRAMEPOINT_TOPLEFT, 0.003, -0.035)
            call DzFrameSetSize(ExpUIButtonLabels[Cells[i]], 0.032, 0.014)
            call DzFrameSetFont(ExpUIButtonLabels[Cells[i]], "Fonts\\DFHeiMd.ttf", 0.008, 0)
            call DzFrameSetPriority(ExpUIButtonLabels[Cells[i]], 92)
            call DzFrameSetScriptByCode(ExpUIButtons[Cells[i]], JN_FRAMEEVENT_MOUSE_ENTER, function Enter, false)
            call DzFrameSetScriptByCode(ExpUIButtons[Cells[i]], JN_FRAMEEVENT_MOUSE_LEAVE, function Leave, false)
            call DzFrameSetScriptByCode(ExpUIButtons[Cells[i]], JN_FRAMEEVENT_MOUSE_UP, function Click, false)
            set i = i + 1
        endloop
        set Previous = ExpUIButton(Root, 0.022, 0.344, 0.053, 0.023, "이전", 0)
        set Next = ExpUIButton(Root, 0.120, 0.344, 0.053, 0.023, "다음", 0)
        set PageText = ExpUILabel(Root, 0.079, 0.348, 0.040, 0.019, 0.010, "")
        set RegionSort = ExpUIButton(Root, 0.258, 0.344, 0.080, 0.023, "지역순", 0)
        set GradeSort = ExpUIButton(Root, 0.348, 0.344, 0.090, 0.023, "희귀도순", 0)
        call ExpUIThemeButton(Previous, 1)
        call ExpUIThemeButton(Next, 1)
        call ExpUIThemeButton(RegionSort, 1)
        call ExpUIThemeButton(GradeSort, 1)
        call DzFrameSetScriptByCode(ExpUIButtons[Previous], JN_FRAMEEVENT_MOUSE_UP, function Click, false)
        call DzFrameSetScriptByCode(ExpUIButtons[Next], JN_FRAMEEVENT_MOUSE_UP, function Click, false)
        call DzFrameSetScriptByCode(ExpUIButtons[RegionSort], JN_FRAMEEVENT_MOUSE_UP, function Click, false)
        call DzFrameSetScriptByCode(ExpUIButtons[GradeSort], JN_FRAMEEVENT_MOUSE_UP, function Click, false)
        set Tooltip = ExpUITexture(Root, 0, 0, 0.230, 0.300, "war3mapImported\\UI_Arcana_Ink.tga")
        call DzFrameSetPriority(Tooltip, 110)
        set TooltipIcon = ExpUITexture(Tooltip, 0.012, 0.012, 0.038, 0.0507, "ReplaceableTextures\\CommandButtons\\BTNTome.blp")
        set TooltipText = ExpUILabel(Tooltip, 0.012, 0.072, 0.206, 0.217, 0.010, "")
        call JNFrameSetTextAlignment(TooltipText, JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_LEFT)
        call DzFrameShow(Tooltip, false)
        call TriggerAddAction(ExpRefresh, function Render)
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterTimerEventSingle(t, 0.04)
        call TriggerAddAction(t, function Build)
        call UIInputAfterPick(function BindInput)
        set t = null
    endfunction
endlibrary
