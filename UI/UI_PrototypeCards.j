// I키 보관함의 캐릭터 목록, 선택한 큰 일러스트와 호버 합산 효과를 표시한다.
library UIPrototypeCards initializer Init requires UIExpeditionCommon, UIInputGate
    globals
        private constant integer PAGE_SIZE = 20
        private integer Root
        private integer Summary
        private integer PageText
        private integer Previous
        private integer Next
        private integer RegionSort
        private integer GradeSort
        private integer GalleryArt
        private integer GalleryBorder
        private integer GalleryName
        private integer GalleryMeta
        private integer GalleryStacks
        private integer GalleryEmpty
        private integer Tooltip
        private integer TooltipIcon
        private integer TooltipBorder
        private integer TooltipTitle
        private integer TooltipText
        private integer Hover = 0
        private integer Selected = 0
        private integer Page = 0
        private integer Sort = 0
        private integer Count = 0
        private integer SeenRun = -1
        private integer SeenVersion = -1
        private integer SeenSelected = -1
        private integer SeenPage = -1
        private integer array Cards
        private integer array Cells
        private integer array Icons
        private integer array Borders
        private integer array Names
    endglobals

    private function Text takes integer frame, string value returns nothing
        call DzFrameSetText(frame, "|cffe7edf3" + JNStringReplace(value, "|r", "|cffe7edf3") + "|r")
    endfunction

    private function Label takes integer parent, real x, real y, real width, real height, real size, string value returns integer
        local integer f = ExpUILabel(parent, x, y, width, height, size, "")
        call Text(f, value)
        return f
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

    private function PortraitFrame takes integer grade returns string
        if grade == 4 then
            return "war3mapImported\\UI_Cards_Portrait_Prism.tga"
        elseif grade == 3 then
            return "war3mapImported\\UI_Cards_Portrait_Epic.tga"
        elseif grade == 2 then
            return "war3mapImported\\UI_Cards_Portrait_Rare.tga"
        endif
        return "war3mapImported\\UI_Cards_Portrait_Normal.tga"
    endfunction

    private function Enter takes nothing returns nothing
        local integer i = 1
        if DzGetTriggerUIEventPlayer() != GetLocalPlayer() then
            return
        endif
        loop
            exitwhen i > PAGE_SIZE
            if DzGetTriggerUIEventFrame() == ExpUIButtons[Cells[i]] then
                set Hover = i
                call ExpUISelectButton(Cells[i], true)
                return
            endif
            set i = i + 1
        endloop
    endfunction

    private function Leave takes nothing returns nothing
        if DzGetTriggerUIEventPlayer() == GetLocalPlayer() then
            if Hover > 0 then
                call ExpUISelectButton(Cells[Hover], Page * PAGE_SIZE + Hover <= Count and Cards[Page * PAGE_SIZE + Hover] == Selected)
            endif
            set Hover = 0
            call DzFrameShow(Tooltip, false)
        endif
    endfunction

    private function Click takes nothing returns nothing
        local integer frame = DzGetTriggerUIEventFrame()
        local integer i = 1
        if DzGetTriggerUIEventPlayer() != GetLocalPlayer() then
            return
        endif
        set Hover = 0
        call DzFrameShow(Tooltip, false)
        if frame == ExpUIButtons[Previous] then
            set Page = IMaxBJ(0, Page - 1)
            set Selected = 0
        elseif frame == ExpUIButtons[Next] then
            set Page = IMinBJ(IMaxBJ(0, R2I((Count - 1) / PAGE_SIZE)), Page + 1)
            set Selected = 0
        elseif frame == ExpUIButtons[RegionSort] or frame == ExpUIButtons[GradeSort] then
            if frame == ExpUIButtons[RegionSort] then
                set Sort = 0
            else
                set Sort = 1
            endif
            set Page = 0
            set Selected = 0
            set SeenVersion = -1
        else
            loop
                exitwhen i > PAGE_SIZE
                if frame == ExpUIButtons[Cells[i]] and Page * PAGE_SIZE + i <= Count then
                    set Selected = Cards[Page * PAGE_SIZE + i]
                    return
                endif
                set i = i + 1
            endloop
        endif
    endfunction

    private function Render takes nothing returns nothing
        local integer pid = GetPlayerId(GetLocalPlayer())
        local integer i = 1
        local integer id
        local integer grade
        local integer effects
        local real x
        local real y
        local real tooltipHeight
        local string value
        local boolean changed = false
        if Root == 0 then
            return
        endif
        call DzFrameShow(Tooltip, false)
        if pid > 3 or not ExpPrototypeEnabled or ExpUIPanel != EXP_UI_CARDS or not PickCheck[pid] or F_UpgradeOnOff[pid] then
            set Hover = 0
            set SeenSelected = -1
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
                    if ProtoIsInventoryCard(pid, id) and (Sort == 0 or ProtoOwnedCardGrade(pid, id) == grade) then
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
                set Selected = 0
            endif
            set SeenRun = ExpRun
            set SeenVersion = ProtoCardRevision[pid]
            set Page = IMaxBJ(0, IMinBJ(Page, R2I((Count - 1) / PAGE_SIZE)))
            set changed = true
        endif
        if Selected == 0 and Count > 0 then
            set Selected = Cards[Page * PAGE_SIZE + 1]
        endif
        call Text(Summary, "보유 카드 " + I2S(Count) + "장 · 머리 " + I2S(ProtoHeadCount[pid]) + "/2")
        if changed or SeenSelected != Selected or SeenPage != Page then
            loop
                exitwhen i > PAGE_SIZE
                set id = 0
                if Page * PAGE_SIZE + i <= Count then
                    set id = Cards[Page * PAGE_SIZE + i]
                endif
                call ExpUISetButton(Cells[i], "", id > 0)
                call ExpUISelectButton(Cells[i], id > 0 and id == Selected)
                if id == 0 then
                    call DzFrameSetAlpha(ExpUIButtons[Cells[i]], 45)
                endif
                call DzFrameShow(Icons[i], id > 0)
                call DzFrameShow(Borders[i], id > 0)
                call DzFrameShow(Names[i], id > 0)
                if id > 0 then
                    call DzFrameSetTexture(Icons[i], ProtoCardArt(id), 0)
                    call DzFrameSetTexture(Borders[i], ProtoCardFrame(ProtoOwnedCardGrade(pid, id)), 0)
                    call Text(Names[i], Color(ProtoOwnedCardGrade(pid, id)) + ProtoCardName[id])
                    set value = ""
                    if ProtoCardStacks[ExpKey(pid, id)] > 0 then
                        set value = "+" + I2S(ProtoCardStacks[ExpKey(pid, id)])
                    endif
                    if ProtoCharacterEvolved[ExpKey(pid, id)] then
                        set value = "★ " + value
                    endif
                    call Text(ExpUIButtonLabels[Cells[i]], Color(ProtoOwnedCardGrade(pid, id)) + value)
                endif
                set i = i + 1
            endloop
            call DzFrameShow(GalleryArt, Selected > 0)
            call DzFrameShow(GalleryBorder, Selected > 0)
            call DzFrameShow(GalleryName, Selected > 0)
            call DzFrameShow(GalleryMeta, Selected > 0)
            call DzFrameShow(GalleryStacks, Selected > 0)
            call DzFrameShow(GalleryEmpty, Selected == 0)
            if Selected > 0 then
                set grade = ProtoOwnedCardGrade(pid, Selected)
                set value = ProtoCardIllustration(Selected)
                call DzFrameClearAllPoints(GalleryArt)
                if value != "" then
                    call DzFrameSetPoint(GalleryArt, JN_FRAMEPOINT_TOPLEFT, Root, JN_FRAMEPOINT_TOPLEFT, 0.428, -0.082)
                    call DzFrameSetSize(GalleryArt, 0.300, 0.400)
                else
                    // 작은 지역 아이콘을 확대하지 않고 일러스트 미등록 상태를 명확히 표시한다.
                    set value = ProtoCardArt(Selected)
                    call DzFrameSetPoint(GalleryArt, JN_FRAMEPOINT_TOPLEFT, Root, JN_FRAMEPOINT_TOPLEFT, 0.533, -0.210)
                    call DzFrameSetSize(GalleryArt, 0.090, 0.120)
                    call DzFrameShow(GalleryEmpty, true)
                endif
                call DzFrameSetTexture(GalleryArt, value, 0)
                call DzFrameSetTexture(GalleryBorder, PortraitFrame(grade), 0)
                call Text(GalleryName, Color(grade) + ProtoCardName[Selected])
                set value = "공용"
                if ProtoCardHead[Selected] > 0 then
                    set value = ProtoHeadName[ProtoCardHead[Selected]]
                endif
                call Text(GalleryMeta, value + " · " + Color(grade) + ExpEventGradeName(grade))
                call Text(GalleryStacks, "강화 |cff83e4e6+" + I2S(ProtoCardStacks[ExpKey(pid, Selected)]))
                call Text(GalleryEmpty, "|cff90a4b8일러스트 준비 중")
            else
                call Text(GalleryEmpty, "|cff90a4b8아직 획득한 카드가 없습니다.")
            endif
            call Text(PageText, I2S(Page + 1) + " / " + I2S(IMaxBJ(1, R2I((Count + PAGE_SIZE - 1) / PAGE_SIZE))))
            call ExpUISetButton(Previous, "이전", Page > 0)
            call ExpUISetButton(Next, "다음", (Page + 1) * PAGE_SIZE < Count)
            call ExpUISelectButton(RegionSort, Sort == 0)
            call ExpUISelectButton(GradeSort, Sort == 1)
            set SeenSelected = Selected
            set SeenPage = Page
        endif
        if Hover > 0 and Page * PAGE_SIZE + Hover <= Count then
            set id = Cards[Page * PAGE_SIZE + Hover]
            // 호버 설명은 목록 내부에 제한하여 오른쪽 일러스트와 하단 조작을 가리지 않는다.
            set x = RMinBJ(0.153, 0.087 + ModuloInteger(Hover - 1, 5) * 0.075)
            set effects = ProtoCharacterEffectCount(pid, id)
            set tooltipHeight = 0.108 + 0.0115 * effects
            if effects > 12 then
                set tooltipHeight = tooltipHeight + 0.045
                call DzFrameSetFont(TooltipText, "Fonts\\DFHeiMd.ttf", 0.009, 0)
            else
                call DzFrameSetFont(TooltipText, "Fonts\\DFHeiMd.ttf", 0.010, 0)
            endif
            set y = RMaxBJ(tooltipHeight + 0.065, 0.430 - R2I((Hover - 1) / 5) * 0.090)
            call DzFrameClearAllPoints(Tooltip)
            call DzFrameSetAbsolutePoint(Tooltip, JN_FRAMEPOINT_TOPLEFT, x, y)
            call DzFrameSetSize(Tooltip, 0.268, tooltipHeight)
            call DzFrameSetSize(TooltipText, 0.244, tooltipHeight - 0.084)
            call DzFrameSetTexture(TooltipIcon, ProtoCardArt(id), 0)
            call DzFrameSetTexture(TooltipBorder, ProtoCardFrame(ProtoOwnedCardGrade(pid, id)), 0)
            call Text(TooltipTitle, Color(ProtoOwnedCardGrade(pid, id)) + "[" + ExpEventGradeName(ProtoOwnedCardGrade(pid, id)) + "] " + ProtoCardName[id])
            call Text(TooltipText, ProtoCardText(pid, id))
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
        set Root = ExpUIRoot(EXP_UI_CARDS, 0.76, 0.558, 0.584, false)
        set f = ExpUITexture(Root, 0, 0, 0.76, 0.558, "war3mapImported\\UI_Cards_Archive.tga")
        set f = Label(Root, 0.026, 0.016, 0.22, 0.022, 0.010, "|cffd9c094A R C A N A")
        set f = Label(Root, 0.026, 0.039, 0.23, 0.034, 0.023, "보유 카드")
        set Summary = Label(Root, 0.473, 0.027, 0.235, 0.024, 0.012, "")
        call JNFrameSetTextAlignment(Summary, JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_RIGHT)
        set f = ExpUIPanelToggle(Root, 0.721, 0.014, 0.026, 0.028)
        call ExpUIThemeButton(f, 1)
        set f = ExpUITexture(Root, 0.016, 0.093, 0.387, 0.417, "war3mapImported\\UI_Cards_Collection.tga")
        set f = Label(Root, 0.031, 0.108, 0.13, 0.022, 0.012, "보유 목록")
        set RegionSort = ExpUIButton(Root, 0.235, 0.107, 0.069, 0.026, "지역순", 0)
        set GradeSort = ExpUIButton(Root, 0.311, 0.107, 0.078, 0.026, "희귀도순", 0)
        loop
            exitwhen i > PAGE_SIZE
            set x = 0.029 + ModuloInteger(i - 1, 5) * 0.075
            set y = 0.151 + R2I((i - 1) / 5) * 0.090
            set Cells[i] = ExpUICoverButton(Root, 0)
            call ExpUIThemeButton(Cells[i], 4)
            call DzFrameClearAllPoints(ExpUIButtons[Cells[i]])
            call DzFrameSetPoint(ExpUIButtons[Cells[i]], JN_FRAMEPOINT_TOPLEFT, Root, JN_FRAMEPOINT_TOPLEFT, x, -y)
            call ExpUIResizeCover(Cells[i], 0.063, 0.085)
            set Icons[i] = ExpUITexture(ExpUIButtons[Cells[i]], 0.0045, 0.0035, 0.054, 0.072, "ReplaceableTextures\\CommandButtons\\BTNTome.blp")
            set Borders[i] = ExpUITexture(ExpUIButtons[Cells[i]], 0.0045, 0.0035, 0.054, 0.072, ProtoCardFrame(1))
            call DzFrameSetPriority(Icons[i], 90)
            call DzFrameSetPriority(Borders[i], 91)
            set Names[i] = Label(ExpUIButtons[Cells[i]], 0.003, 0.073, 0.057, 0.017, 0.0085, "")
            call JNFrameSetTextAlignment(Names[i], JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_CENTER)
            call DzFrameSetPriority(Names[i], 92)
            call DzFrameClearAllPoints(ExpUIButtonLabels[Cells[i]])
            call DzFrameSetPoint(ExpUIButtonLabels[Cells[i]], JN_FRAMEPOINT_TOPLEFT, ExpUIButtons[Cells[i]], JN_FRAMEPOINT_TOPLEFT, 0.038, -0.052)
            call DzFrameSetSize(ExpUIButtonLabels[Cells[i]], 0.020, 0.014)
            call DzFrameSetFont(ExpUIButtonLabels[Cells[i]], "Fonts\\DFHeiMd.ttf", 0.008, 0)
            call DzFrameSetPriority(ExpUIButtonLabels[Cells[i]], 93)
            call DzFrameSetScriptByCode(ExpUIButtons[Cells[i]], JN_FRAMEEVENT_MOUSE_ENTER, function Enter, false)
            call DzFrameSetScriptByCode(ExpUIButtons[Cells[i]], JN_FRAMEEVENT_MOUSE_LEAVE, function Leave, false)
            call DzFrameSetScriptByCode(ExpUIButtons[Cells[i]], JN_FRAMEEVENT_MOUSE_UP, function Click, false)
            set i = i + 1
        endloop
        set f = ExpUITexture(Root, 0.415, 0.070, 0.326, 0.443, "war3mapImported\\UI_Cards_Gallery.tga")
        set GalleryArt = ExpUITexture(Root, 0.428, 0.082, 0.300, 0.400, "ReplaceableTextures\\CommandButtons\\BTNTome.blp")
        set GalleryBorder = ExpUITexture(Root, 0.415, 0.070, 0.326, 0.443, PortraitFrame(1))
        set GalleryName = Label(Root, 0.436, 0.468, 0.220, 0.026, 0.014, "")
        set GalleryMeta = Label(Root, 0.436, 0.494, 0.220, 0.022, 0.0095, "")
        set GalleryStacks = Label(Root, 0.644, 0.488, 0.077, 0.022, 0.010, "")
        call JNFrameSetTextAlignment(GalleryStacks, JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_RIGHT)
        set GalleryEmpty = Label(Root, 0.450, 0.352, 0.25, 0.026, 0.010, "")
        call JNFrameSetTextAlignment(GalleryEmpty, JN_TEXT_JUSTIFY_TOP, JN_TEXT_JUSTIFY_CENTER)
        set Previous = ExpUIButton(Root, 0.027, 0.527, 0.049, 0.021, "이전", 0)
        set Next = ExpUIButton(Root, 0.121, 0.527, 0.049, 0.021, "다음", 0)
        set PageText = Label(Root, 0.080, 0.530, 0.038, 0.018, 0.0095, "")
        set f = Label(Root, 0.207, 0.530, 0.32, 0.020, 0.009, "|cff90a4b8아이콘에 마우스를 올려 효과 확인")
        set f = Label(Root, 0.665, 0.530, 0.083, 0.020, 0.009, "|cff90a4b8I / ESC 닫기")
        call ExpUIThemeButton(Previous, 1)
        call ExpUIThemeButton(Next, 1)
        call ExpUIThemeButton(RegionSort, 1)
        call ExpUIThemeButton(GradeSort, 1)
        call ExpUISetButton(RegionSort, "지역순", true)
        call ExpUISetButton(GradeSort, "희귀도순", true)
        call DzFrameSetScriptByCode(ExpUIButtons[Previous], JN_FRAMEEVENT_MOUSE_UP, function Click, false)
        call DzFrameSetScriptByCode(ExpUIButtons[Next], JN_FRAMEEVENT_MOUSE_UP, function Click, false)
        call DzFrameSetScriptByCode(ExpUIButtons[RegionSort], JN_FRAMEEVENT_MOUSE_UP, function Click, false)
        call DzFrameSetScriptByCode(ExpUIButtons[GradeSort], JN_FRAMEEVENT_MOUSE_UP, function Click, false)
        set Tooltip = ExpUITexture(Root, 0, 0, 0.268, 0.300, "war3mapImported\\UI_Cards_Tooltip.tga")
        call DzFrameSetPriority(Tooltip, 110)
        set TooltipIcon = ExpUITexture(Tooltip, 0.012, 0.012, 0.034, 0.0453, "ReplaceableTextures\\CommandButtons\\BTNTome.blp")
        set TooltipBorder = ExpUITexture(Tooltip, 0.012, 0.012, 0.034, 0.0453, ProtoCardFrame(1))
        call DzFrameSetPriority(TooltipIcon, 110)
        call DzFrameSetPriority(TooltipBorder, 111)
        set TooltipTitle = Label(Tooltip, 0.055, 0.025, 0.200, 0.023, 0.0105, "")
        set TooltipText = Label(Tooltip, 0.012, 0.068, 0.244, 0.217, 0.009, "")
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
