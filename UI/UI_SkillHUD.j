// 참고 맵 방식의 좌표 기반 스킬 HUD 및 Alt 정보 관리
library UISkillHUD initializer init requires UISkill, UISkillLevel, DataUnit, JAPIAbilityState, JAPIItemState, HeroNarZ, FrameCount, UIInputGate, JNCommon
    globals
        private constant integer SKILL_HUD_COUNT = 12
        // 프리즘 유리 HUD (시안 07). 16:9 화면에서 칸이 정사각형에 가깝게 보이도록 가로/세로를 따로 둔다
        private constant real SKILL_W = 0.0292
        private constant real SKILL_H = 0.0376
        private constant real ITEM_W = 0.0262
        private constant real ITEM_H = 0.0320
        private constant integer ITEM_HOVER_BASE = 100
        // 칸 격자: 0열(X Z) + Q W E R 4열. 0행 포션 3칸(C V 칸은 숨김), 1행 X Q W E R, 2행 Z A S D F
        private constant real GRID_X0 = 0.5683
        private constant real GRID_DX = 0.0341
        private constant real ROW1_TOP = 0.1204
        private constant real ROW_DY = 0.0439
        // 영웅 이미지
        private constant real HERO_HUD_LEFT = 0.1597
        private constant real HERO_HUD_BOTTOM = 0.0357
        private constant real HERO_HUD_WIDTH = 0.0773
        private constant real HERO_HUD_HEIGHT = 0.0932
        private constant string HUD_SLOT_BG = "war3mapImported\\HUD_SlotBG.tga"
        private constant string HUD_SLOT_BORDER = "war3mapImported\\HUD_SlotBorder.tga"
        private constant string HUD_HERO_BORDER = "war3mapImported\\HUD_HeroBorder.tga"
        private integer array SkillHUDIcon
        private integer array SkillHUDArt
        private integer array SkillHUDBorder
        private integer array SkillHUDCooldown
        private integer array SkillHUDCooldownText
        private integer array SkillHUDHotkeyText
        private integer array SkillHUDDisabledCover
        private integer array SkillHUDDisabledDark
        private integer SkillHUDDashStack
        private integer array SkillHUDAbility
        private real array SkillHUDCooldownTotal
        private real array SkillHUDCooldownPrevious
        private integer array ItemHUDIcon
        private integer array ItemHUDCharges
        private integer array ItemHUDSlot
        private integer array ItemHUDBorder
        private integer HeroHUDFrame
        private integer HeroHUDImage
        private integer HeroHUDBorder
        private integer HeroHUDNumber = -1
        private integer SkillHUDTip
        private integer SkillHUDTipName
        private integer SkillHUDTipDescription
        private integer SkillHUDHover = -1
        private boolean SkillHUDAltShown = false
        private boolean SkillHUDSuppressed = false
        private boolean FirstHeroUpdateLogged = false
    endglobals

    private function AbilityId takes integer index, integer slot returns integer
        if slot == 0 then
            return HeroSkillID0[index]
        elseif slot == 1 then
            return HeroSkillID1[index]
        elseif slot == 2 then
            return HeroSkillID2[index]
        elseif slot == 3 then
            return HeroSkillID3[index]
        elseif slot == 4 then
            return HeroSkillID4[index]
        elseif slot == 5 then
            return HeroSkillID5[index]
        elseif slot == 6 then
            return HeroSkillID6[index]
        elseif slot == 7 then
            return HeroSkillID7[index]
        elseif slot == 8 then
            return HeroSkillID10[index]
        elseif slot == 9 then
            return 'A002'
        elseif slot == 10 then
            return HeroSkillID9[index]
        elseif slot == 11 then
            return HeroSkillID8[index]
        endif
        return 0
    endfunction

    // 반디 E는 형태에 따라 A06F(반디) <-> A06Q(샘, 변신 해제)로 능력이 바뀐다. 지금 가진 쪽을 칸에 띄운다.
    private function UnitSlotAbilityId takes unit u, integer index, integer slot returns integer
        if index == 15 and slot == 2 and GetUnitAbilityLevel(u, 'A06Q') > 0 then
            return 'A06Q'
        endif
        return AbilityId(index, slot)
    endfunction

    private function IsDashAbilityReady takes unit u, integer abilId returns boolean
        local ability ab
        local boolean ready
        if GetUnitAbilityLevel(u, abilId) < 1 then
            return false
        endif
        set ab = EXGetUnitAbility(u, abilId)
        if ab == null then
            return false
        endif
        set ready = EXGetAbilityState(ab, ABILITY_STATE_COOLDOWN) <= 0.0
        set ab = null
        return ready
    endfunction

    private function DashAbilityId takes unit u returns integer
        if GetUnitAbilityLevel(u, 'A006') > 0 then
            return 'A006'
        elseif GetUnitAbilityLevel(u, 'A005') > 0 then
            return 'A005'
        elseif GetUnitAbilityLevel(u, 'A004') > 0 then
            return 'A004'
        endif
        return 'A002'
    endfunction

    // 대쉬 남은 횟수: SkillDash.j가 A006(3) > A005(2) > A004(1) > A002(0) 순으로 능력을 바꿔 끼운다
    private function DashStackCount takes unit u returns integer
        if GetUnitAbilityLevel(u, 'A006') > 0 then
            return 3
        elseif GetUnitAbilityLevel(u, 'A005') > 0 then
            return 2
        elseif GetUnitAbilityLevel(u, 'A004') > 0 then
            return 1
        endif
        return 0
    endfunction

    // 루시아 스킬은 오브젝트 요구 조건(더미 유닛)으로 열리고 닫힌다. 기본 명령창 대신 이 HUD가 같은 조건으로 비활성화를 표시한다.
    private function LuciaReqAlive takes unit r, integer typeId returns boolean
        return r != null and GetUnitTypeId(r) == typeId and not IsUnitType(r, UNIT_TYPE_DEAD)
    endfunction

    private function LuciaSlotReady takes integer pid, integer slot returns boolean
        local boolean small = LuciaReqAlive(LuciaFormUnit[pid], 'e05H')
        local boolean big = LuciaReqAlive(LuciaFormUnit[pid], 'e05I')
        if slot == 0 then
            return small
        elseif slot == 1 then
            return LuciaReqAlive(LuciaCheckUnit[pid], 'e04Y')
        elseif slot == 3 then
            return small and LuciaReqAlive(LuciaR[pid], 'e05J')
        elseif slot == 4 or slot == 5 then
            return big
        elseif slot == 6 then
            return big and LuciaReqAlive(LuciaD[pid], 'e05L')
        elseif slot == 7 then
            return big and LuciaReqAlive(LuciaF[pid], 'e05K')
        endif
        return true
    endfunction

    // 반디 스킬도 오브젝트 요구 조건(더미 유닛)으로 열리고 닫힌다 (맵 오브젝트 데이터 기준).
    // 반디 형태 e03A: Q W E(A06F, 비술 e033도 필요) / 샘 형태 e03B: A S D E(A06Q) / 완전연소 e03C: R F / Z: e034
    private function BandiReqAlive takes unit r, integer typeId returns boolean
        return r != null and GetUnitTypeId(r) == typeId and not IsUnitType(r, UNIT_TYPE_DEAD)
    endfunction

    private function BandiSlotReady takes integer pid, integer slot, integer abilId returns boolean
        local boolean bandi = BandiReqAlive(BandiForm[pid], 'e03A')
        local boolean sam = BandiReqAlive(BandiForm[pid], 'e03B')
        local boolean burn = BandiReqAlive(BandiForm[pid], 'e03C')
        if slot == 0 or slot == 1 then
            return bandi
        elseif slot == 2 then
            if abilId == 'A06Q' then
                return sam
            endif
            return bandi and BandiReqAlive(BanBisulU[pid], 'e033')
        elseif slot == 3 or slot == 7 then
            return burn
        elseif slot >= 4 and slot <= 6 then
            return sam
        elseif slot == 8 then
            return BandiReqAlive(BanBisul2U[pid], 'e034')
        endif
        return true
    endfunction

    // 지크프리트 Z는 용기 10스택(발동 중이 아닐 때), F는 콤보 마지막 단의 피니시 창이 열렸을 때만 나간다 (HeroSiegCore 키 입력과 같은 조건)
    private function SiegSlotReady takes integer pid, integer slot returns boolean
        if slot == 8 then
            return not SiegZOn[pid] and SiegStack[pid] >= SIEG_MAX_STACK
        elseif slot == 7 then
            return SiegFOpen[pid] and not SiegFLock[pid]
        endif
        return true
    endfunction

    private function IsAbilityAvailable takes unit u, integer pid, integer index, integer slot, integer abilId returns boolean
        if slot == 9 then
            return IsDashAbilityReady(u, DashAbilityId(u))
        endif
        if index == 14 and slot == 2 then
            return GetUnitAbilityLevel(u, abilId) > 0 and NarForm[pid] == 1
        endif
        if index == 14 and slot == 3 then
            return GetUnitAbilityLevel(u, abilId) > 0 and NarForm[pid] == 0
        endif
        if index == 17 then
            return GetUnitAbilityLevel(u, abilId) > 0 and LuciaSlotReady(pid, slot)
        endif
        if index == 15 then
            return GetUnitAbilityLevel(u, abilId) > 0 and BandiSlotReady(pid, slot, abilId)
        endif
        if index == 26 then
            return GetUnitAbilityLevel(u, abilId) > 0 and SiegSlotReady(pid, slot)
        endif
        return GetUnitAbilityLevel(u, abilId) > 0
    endfunction

    private function Hotkey takes integer slot returns string
        if slot == 0 then
            return "Q"
        elseif slot == 1 then
            return "W"
        elseif slot == 2 then
            return "E"
        elseif slot == 3 then
            return "R"
        elseif slot == 4 then
            return "A"
        elseif slot == 5 then
            return "S"
        elseif slot == 6 then
            return "D"
        elseif slot == 7 then
            return "F"
        elseif slot == 8 then
            return "Z"
        elseif slot == 9 then
            return "X"
        elseif slot == 10 then
            return "C"
        endif
        return "V"
    endfunction

    // 슬롯 번호 -> 격자 칸. 0~3 QWER, 4~7 ASDF, 8 Z, 9 X(대시), 10 C, 11 V
    private function SlotCol takes integer slot returns integer
        if slot < 8 then
            return ModuloInteger(slot, 4) + 1
        elseif slot == 10 then
            return 3
        elseif slot == 11 then
            return 4
        endif
        return 0
    endfunction

    private function SlotRow takes integer slot returns integer
        if slot < 4 or slot == 9 then
            return 1
        elseif slot < 9 then
            return 2
        endif
        return 0
    endfunction

    private function SlotX takes integer slot returns real
        return GRID_X0 + GRID_DX * I2R(SlotCol(slot))
    endfunction

    private function SlotY takes integer slot returns real
        return ROW1_TOP + ROW_DY * I2R(1 - SlotRow(slot))
    endfunction

    // 포션은 0행의 X Q W 칸에 두고, 아래쪽을 C V 칸과 맞춘다
    private function ItemSlotX takes integer slot returns real
        return GRID_X0 + GRID_DX * I2R(slot) + (SKILL_W - ITEM_W) * 0.5
    endfunction

    private function ItemSlotY takes nothing returns real
        return ROW1_TOP + ROW_DY - SKILL_H + ITEM_H
    endfunction

    private function HeroHUDTexture takes integer heroNumber returns string
        if heroNumber <= 0 then
            return "Empty.blp"
        endif
        return "UI_HeroPot" + I2S(heroNumber) + ".blp"
    endfunction

    private function SetFrameVisible takes boolean show returns nothing
        call DzFrameShow(HeroHUDFrame, show)
        call DzFrameShow(HeroHUDImage, show)
        call DzFrameShow(ItemHUDSlot[0], show)
        call DzFrameShow(ItemHUDSlot[1], show)
        call DzFrameShow(ItemHUDSlot[2], show)
    endfunction

    private function HideTip takes nothing returns nothing
        set SkillHUDHover = -1
        set SkillHUDAltShown = false
        call DzFrameShow(SkillHUDTip, false)
    endfunction

    function SkillHUDSetVisible takes boolean show returns nothing
        local integer slot = 0
        set SkillHUDSuppressed = not show
        if show then
            loop
                exitwhen slot >= SKILL_HUD_COUNT
                call DzFrameShow(DzFrameGetCommandBarButton(slot / 4, ModuloInteger(slot, 4)), false)
                set slot = slot + 1
            endloop
        else
            call SetFrameVisible(false)
            loop
                exitwhen slot >= SKILL_HUD_COUNT
                call DzFrameShow(SkillHUDIcon[slot], false)
                set slot = slot + 1
            endloop
            set slot = 0
            loop
                exitwhen slot >= 3
                call DzFrameShow(ItemHUDIcon[slot], false)
                set slot = slot + 1
            endloop
            call HideTip()
        endif
    endfunction

    private function ShowTip takes unit u, integer slot returns nothing
        local integer pid = GetPlayerId(GetLocalPlayer())
        local integer index = DataUnitIndex(u)
        local integer abilId = UnitSlotAbilityId(u, index, slot)
        local integer level = GetUnitAbilityLevel(u, abilId)
        local string desc
        if level < 1 then
            set level = 1
        endif
        set desc = SkillFrameHUDDescription(pid, index, slot, SkillHUDAltShown)
        if desc == "" then
            set desc = EXGetAbilityString(abilId, level, ABILITY_DATA_UBERTIP)
        endif
        call DzFrameSetText(SkillHUDTipName, EXGetAbilityString(abilId, level, ABILITY_DATA_TIP))
        call DzFrameSetText(SkillHUDTipDescription, desc)
        call DzFrameShow(SkillHUDTip, true)
    endfunction

    // 포션 칸 설명. 호버 번호는 ITEM_HOVER_BASE + 칸 번호로 스킬과 구분한다
    private function ShowItemTip takes item it returns nothing
        local string desc = JNGetItemExtendedTooltip(it)
        if desc == "" or desc == null then
            set desc = JNGetItemDescription(it)
        endif
        call DzFrameSetText(SkillHUDTipName, GetItemName(it) + "  |cffffdc64x" + I2S(GetItemCharges(it)) + "|r")
        call DzFrameSetText(SkillHUDTipDescription, desc)
        call DzFrameShow(SkillHUDTip, true)
    endfunction

    private function UpdateHover takes unit u returns nothing
        local real mx = I2R(DzGetMouseXRelative()) / I2R(DzGetWindowWidth()) * 0.8
        local real my = I2R(DzGetWindowHeight() - 42 - DzGetMouseYRelative()) / I2R(DzGetWindowHeight() - 42) * 0.6
        local integer slot = 0
        local integer hover = -1
        local boolean altShown = DzIsKeyDown(JN_OSKEY_ALT)
        local real x
        local real y
        local item heldItem
        loop
            exitwhen slot >= SKILL_HUD_COUNT
            set x = SlotX(slot)
            set y = SlotY(slot)
            if SkillHUDAbility[slot] != 0 and mx >= x and mx <= x + SKILL_W and my <= y and my >= y - SKILL_H then
                set hover = slot
            endif
            set slot = slot + 1
        endloop
        set slot = 0
        loop
            exitwhen slot >= 3 or hover >= 0
            set x = ItemSlotX(slot)
            set y = ItemSlotY()
            if mx >= x and mx <= x + ITEM_W and my <= y and my >= y - ITEM_H then
                set heldItem = UnitItemInSlot(u, slot)
                if heldItem != null then
                    set SkillHUDHover = ITEM_HOVER_BASE + slot
                    set SkillHUDAltShown = altShown
                    call ShowItemTip(heldItem)
                    set heldItem = null
                    return
                endif
            endif
            set slot = slot + 1
        endloop
        if hover < 0 then
            call HideTip()
        elseif hover != SkillHUDHover or altShown != SkillHUDAltShown then
            set SkillHUDHover = hover
            set SkillHUDAltShown = altShown
            call ShowTip(u, hover)
        endif
    endfunction

    private function Update takes nothing returns nothing
        local integer pid = GetPlayerId(GetLocalPlayer())
        local unit u = MainUnit[pid]
        local integer index
        local integer slot = 0
        local integer abilId
        local integer stateAbilId
        local integer level
        local real remain
        local real total
        local real ratio
        local item heldItem

        if SkillHUDSuppressed then
            set u = null
            return
        endif

        if u == null then
            loop
                exitwhen slot >= SKILL_HUD_COUNT
                call DzFrameShow(SkillHUDIcon[slot], false)
                set slot = slot + 1
            endloop
            set slot = 0
            loop
                exitwhen slot >= 3
                call DzFrameShow(ItemHUDIcon[slot], false)
                set slot = slot + 1
            endloop
            call SetFrameVisible(false)
            call HideTip()
            set u = null
            return
        endif

        call SetFrameVisible(true)
        if HeroHUDNumber != PlayerSlotNumber[pid] then
            set HeroHUDNumber = PlayerSlotNumber[pid]
            call DzFrameSetTexture(HeroHUDImage, HeroHUDTexture(HeroHUDNumber), 0)
        endif

        if not FirstHeroUpdateLogged then
            call JNWriteLog("[ARC-PICK-v1] client=" + I2S(pid) + " phase=hud-first-begin")
        endif
        set index = DataUnitIndex(u)
        loop
            exitwhen slot >= SKILL_HUD_COUNT
            set abilId = UnitSlotAbilityId(u, index, slot)
            set stateAbilId = abilId
            if slot == 9 then
                set stateAbilId = DashAbilityId(u)
            endif
            // C(10) V(11) 칸은 화면에 두지 않는다 (2026-10-14 요청)
            if abilId == 0 or slot >= 10 then
                call DzFrameShow(SkillHUDIcon[slot], false)
            else
                call DzFrameShow(SkillHUDIcon[slot], true)
                if SkillHUDAbility[slot] != abilId then
                    set SkillHUDAbility[slot] = abilId
                    set SkillHUDCooldownTotal[slot] = 0.0
                    set SkillHUDCooldownPrevious[slot] = 0.0
                    call DzFrameSetTexture(SkillHUDArt[slot], EXExecuteScript("(require'jass.slk').ability[" + I2S(abilId) + "].Art"), 0)
                endif

                set level = GetUnitAbilityLevel(u, abilId)
                set remain = 0.0
                if GetUnitAbilityLevel(u, stateAbilId) > 0 then
                    set remain = EXGetAbilityState(EXGetUnitAbility(u, stateAbilId), ABILITY_STATE_COOLDOWN)
                endif
                if IsAbilityAvailable(u, pid, index, slot, abilId) then
                    call DzFrameSetAlpha(SkillHUDArt[slot], 255)
                    call DzFrameShow(SkillHUDDisabledCover[slot], false)
                    call DzFrameShow(SkillHUDDisabledDark[slot], false)
                elseif slot == 9 and remain > 0.0 then
                    call DzFrameSetAlpha(SkillHUDArt[slot], 255)
                    call DzFrameShow(SkillHUDDisabledCover[slot], false)
                    call DzFrameShow(SkillHUDDisabledDark[slot], false)
                else
                    call DzFrameSetAlpha(SkillHUDArt[slot], 255)
                    call DzFrameShow(SkillHUDDisabledCover[slot], true)
                    call DzFrameShow(SkillHUDDisabledDark[slot], true)
                endif
                if remain > 0.0 then
                    if SkillHUDCooldownTotal[slot] <= 0.0 or remain > SkillHUDCooldownPrevious[slot] + 0.10 then
                        set SkillHUDCooldownTotal[slot] = remain
                    endif
                    set total = SkillHUDCooldownTotal[slot]
                    if total > 0.0 then
                        set ratio = remain / total
                    else
                        set ratio = 0.0
                    endif
                    call DzFrameSetSize(SkillHUDCooldown[slot], SKILL_W - 0.002, (SKILL_H - 0.0026) * ratio)
                    call DzFrameSetAlpha(SkillHUDCooldown[slot], 150)
                    call DzFrameSetText(SkillHUDCooldownText[slot], I2S(R2I(remain + 0.99)))
                else
                    set SkillHUDCooldownTotal[slot] = 0.0
                    call DzFrameSetSize(SkillHUDCooldown[slot], SKILL_W - 0.002, 0.0)
                    call DzFrameSetAlpha(SkillHUDCooldown[slot], 0)
                    call DzFrameSetText(SkillHUDCooldownText[slot], "")
                endif
                set SkillHUDCooldownPrevious[slot] = remain
                if slot == 9 then
                    call DzFrameSetText(SkillHUDDashStack, "|cffffdc64" + I2S(DashStackCount(u)) + "|r")
                endif
            endif
            set slot = slot + 1
        endloop
        call UpdateHover(u)
        set slot = 0
        loop
            exitwhen slot >= 3
            set heldItem = UnitItemInSlot(u, slot)
            if heldItem == null then
                call DzFrameShow(ItemHUDIcon[slot], false)
            else
                call DzFrameShow(ItemHUDIcon[slot], true)
                call DzFrameSetTexture(ItemHUDIcon[slot], JNGetItemIconPath(heldItem), 0)
                call DzFrameSetText(ItemHUDCharges[slot], I2S(GetItemCharges(heldItem)))
            endif
            set slot = slot + 1
        endloop
        set heldItem = null
        if not FirstHeroUpdateLogged then
            call JNWriteLog("[ARC-PICK-v1] client=" + I2S(pid) + " phase=hud-first-end")
            set FirstHeroUpdateLogged = true
        endif
        set u = null
    endfunction

    private function SyncPing takes nothing returns nothing
        local player sender = DzGetTriggerSyncPlayer()
        local integer pid = GetPlayerId(sender)
        local integer slot = S2I(DzGetTriggerSyncData())
        local unit u = MainUnit[pid]
        local integer abilId
        local integer level
        local real remain
        local integer i = 0
        local string state
        if u == null or slot < 0 or slot >= SKILL_HUD_COUNT then
            set sender = null
            set u = null
            return
        endif
        set abilId = UnitSlotAbilityId(u, DataUnitIndex(u), slot)
        if slot == 9 then
            set abilId = DashAbilityId(u)
        endif
        set level = GetUnitAbilityLevel(u, abilId)
        if level < 1 then
            set level = 1
        endif
        set remain = EXGetAbilityState(EXGetUnitAbility(u, abilId), ABILITY_STATE_COOLDOWN)
        if remain > 0.0 then
            set state = I2S(R2I(remain + 0.99)) + "초"
        else
            set state = "준비됨"
        endif
        loop
            exitwhen i >= 12
            if IsPlayerAlly(Player(i), sender) then
                call DisplayTextToPlayer(Player(i), 0.0, 0.0, GetUnitName(u) + " - " + EXGetAbilityString(abilId, level, ABILITY_DATA_TIP) + " " + state)
            endif
            set i = i + 1
        endloop
        set sender = null
        set u = null
    endfunction

    private function AltClick takes nothing returns nothing
        if not PickCheck[GetPlayerId(GetLocalPlayer())] then
            return
        endif
        if DzGetTriggerKeyPlayer() == GetLocalPlayer() and DzIsKeyDown(JN_OSKEY_ALT) and SkillHUDHover >= 0 and SkillHUDHover < SKILL_HUD_COUNT then
            call DzSyncData("HPing", I2S(SkillHUDHover))
        endif
    endfunction

    private function Create takes nothing returns nothing
        local integer parent = GetGameplayUI()
        local integer slot = 0
        local real x
        local real y

        loop
            exitwhen slot >= SKILL_HUD_COUNT
            call DzFrameShow(DzFrameGetCommandBarButton(slot / 4, ModuloInteger(slot, 4)), false)
            set slot = slot + 1
        endloop

        // 3D 포트레잇 대신 영웅 이미지: 칸 배경 > 이미지 > 테두리 순으로 부모-자식으로 쌓는다
        set HeroHUDFrame = DzCreateFrameByTagName("BACKDROP", "HeroHUDFrame", parent, "", 0)
        call DzFrameSetTexture(HeroHUDFrame, HUD_SLOT_BG, 0)
        call DzFrameSetAbsolutePoint(HeroHUDFrame, JN_FRAMEPOINT_BOTTOMLEFT, HERO_HUD_LEFT, HERO_HUD_BOTTOM)
        call DzFrameSetAbsolutePoint(HeroHUDFrame, JN_FRAMEPOINT_TOPRIGHT, HERO_HUD_LEFT + HERO_HUD_WIDTH, HERO_HUD_BOTTOM + HERO_HUD_HEIGHT)
        call DzFrameShow(HeroHUDFrame, false)
        set HeroHUDImage = DzCreateFrameByTagName("BACKDROP", "HeroHUDImage", HeroHUDFrame, "", 0)
        call DzFrameSetTexture(HeroHUDImage, "Empty.blp", 0)
        call DzFrameSetAbsolutePoint(HeroHUDImage, JN_FRAMEPOINT_BOTTOMLEFT, HERO_HUD_LEFT + 0.0012, HERO_HUD_BOTTOM + 0.0016)
        call DzFrameSetAbsolutePoint(HeroHUDImage, JN_FRAMEPOINT_TOPRIGHT, HERO_HUD_LEFT + HERO_HUD_WIDTH - 0.0012, HERO_HUD_BOTTOM + HERO_HUD_HEIGHT - 0.0016)
        set HeroHUDBorder = DzCreateFrameByTagName("BACKDROP", "HeroHUDBorder", HeroHUDImage, "", 0)
        call DzFrameSetTexture(HeroHUDBorder, HUD_HERO_BORDER, 0)
        call DzFrameSetAbsolutePoint(HeroHUDBorder, JN_FRAMEPOINT_BOTTOMLEFT, HERO_HUD_LEFT, HERO_HUD_BOTTOM)
        call DzFrameSetAbsolutePoint(HeroHUDBorder, JN_FRAMEPOINT_TOPRIGHT, HERO_HUD_LEFT + HERO_HUD_WIDTH, HERO_HUD_BOTTOM + HERO_HUD_HEIGHT)

        // 스킬 칸: SkillHUDIcon(칸 배경, 보이기/숨기기 기준) > SkillHUDArt(아이콘) > 쿨다운 그늘, 테두리 > 글자
        set slot = 0
        loop
            exitwhen slot >= SKILL_HUD_COUNT
            set x = SlotX(slot)
            set y = SlotY(slot)

            set SkillHUDIcon[slot] = DzCreateFrameByTagName("BACKDROP", "SkillHUDIcon" + I2S(slot), parent, "", slot)
            call DzFrameSetTexture(SkillHUDIcon[slot], HUD_SLOT_BG, 0)
            call DzFrameSetSize(SkillHUDIcon[slot], SKILL_W, SKILL_H)
            call DzFrameSetAbsolutePoint(SkillHUDIcon[slot], JN_FRAMEPOINT_TOPLEFT, x, y)
            call DzFrameShow(SkillHUDIcon[slot], false)

            set SkillHUDArt[slot] = DzCreateFrameByTagName("BACKDROP", "SkillHUDArt" + I2S(slot), SkillHUDIcon[slot], "", slot)
            call DzFrameSetSize(SkillHUDArt[slot], SKILL_W - 0.002, SKILL_H - 0.0026)
            call DzFrameSetAbsolutePoint(SkillHUDArt[slot], JN_FRAMEPOINT_TOPLEFT, x + 0.001, y - 0.0013)

            set SkillHUDCooldown[slot] = DzCreateFrameByTagName("BACKDROP", "SkillHUDCooldown" + I2S(slot), SkillHUDArt[slot], "SkillHUD_CooldownShade", slot)
            call DzFrameSetAbsolutePoint(SkillHUDCooldown[slot], JN_FRAMEPOINT_TOPLEFT, x + 0.001, y - 0.0013)
            call DzFrameSetSize(SkillHUDCooldown[slot], SKILL_W - 0.002, 0.0)
            call DzFrameSetAlpha(SkillHUDCooldown[slot], 0)

            set SkillHUDDisabledCover[slot] = DzCreateFrameByTagName("BACKDROP", "SkillHUDDisabledCover" + I2S(slot), SkillHUDArt[slot], "", slot)
            call DzFrameSetAbsolutePoint(SkillHUDDisabledCover[slot], JN_FRAMEPOINT_TOPLEFT, x + 0.001, y - 0.0013)
            call DzFrameSetSize(SkillHUDDisabledCover[slot], SKILL_W - 0.002, SKILL_H - 0.0026)
            call DzFrameSetTexture(SkillHUDDisabledCover[slot], "war3mapImported\\DISBTN.blp", 0)
            call DzFrameShow(SkillHUDDisabledCover[slot], false)

            set SkillHUDDisabledDark[slot] = DzCreateFrameByTagName("BACKDROP", "SkillHUDDisabledDark" + I2S(slot), SkillHUDArt[slot], "SkillHUD_CooldownShade", slot)
            call DzFrameSetAbsolutePoint(SkillHUDDisabledDark[slot], JN_FRAMEPOINT_TOPLEFT, x + 0.001, y - 0.0013)
            call DzFrameSetSize(SkillHUDDisabledDark[slot], SKILL_W - 0.002, SKILL_H - 0.0026)
            call DzFrameSetAlpha(SkillHUDDisabledDark[slot], 150)
            call DzFrameShow(SkillHUDDisabledDark[slot], false)

            set SkillHUDBorder[slot] = DzCreateFrameByTagName("BACKDROP", "SkillHUDBorder" + I2S(slot), SkillHUDArt[slot], "", slot)
            call DzFrameSetTexture(SkillHUDBorder[slot], HUD_SLOT_BORDER, 0)
            call DzFrameSetSize(SkillHUDBorder[slot], SKILL_W, SKILL_H)
            call DzFrameSetAbsolutePoint(SkillHUDBorder[slot], JN_FRAMEPOINT_TOPLEFT, x, y)

            set SkillHUDCooldownText[slot] = DzCreateFrameByTagName("TEXT", "SkillHUDCooldownText" + I2S(slot), SkillHUDBorder[slot], "SkillHUD_CooldownText", slot)
            call DzFrameSetAbsolutePoint(SkillHUDCooldownText[slot], JN_FRAMEPOINT_CENTER, x + SKILL_W * 0.5, y - SKILL_H * 0.5)
            call DzFrameSetEnable(SkillHUDCooldownText[slot], false)

            set SkillHUDHotkeyText[slot] = DzCreateFrameByTagName("TEXT", "SkillHUDHotkeyText" + I2S(slot), SkillHUDBorder[slot], "SkillHUD_HotkeyText", slot)
            call DzFrameSetAbsolutePoint(SkillHUDHotkeyText[slot], JN_FRAMEPOINT_BOTTOMLEFT, x + 0.0022, y - SKILL_H + 0.0022)
            call DzFrameSetText(SkillHUDHotkeyText[slot], "|cffffffff" + Hotkey(slot) + "|r")
            call DzFrameSetEnable(SkillHUDHotkeyText[slot], false)

            if slot == 9 then
                // 대쉬 칸 오른쪽 위에 남은 대쉬 횟수
                set SkillHUDDashStack = DzCreateFrameByTagName("TEXT", "SkillHUDDashStack", SkillHUDBorder[slot], "SkillHUD_HotkeyText", slot)
                call DzFrameSetAbsolutePoint(SkillHUDDashStack, JN_FRAMEPOINT_TOPRIGHT, x + SKILL_W - 0.0022, y - 0.0018)
                call DzFrameSetText(SkillHUDDashStack, "")
                call DzFrameSetEnable(SkillHUDDashStack, false)
            endif

            set slot = slot + 1
        endloop

        // 포션 칸: ItemHUDSlot(칸 배경) > ItemHUDIcon(아이콘, 비면 숨김) > 테두리 > 개수
        set slot = 0
        loop
            exitwhen slot >= 3
            set x = ItemSlotX(slot)
            set y = ItemSlotY()
            set ItemHUDSlot[slot] = DzCreateFrameByTagName("BACKDROP", "ItemHUDSlot" + I2S(slot), parent, "", slot)
            call DzFrameSetTexture(ItemHUDSlot[slot], HUD_SLOT_BG, 0)
            call DzFrameSetSize(ItemHUDSlot[slot], ITEM_W, ITEM_H)
            call DzFrameSetAbsolutePoint(ItemHUDSlot[slot], JN_FRAMEPOINT_TOPLEFT, x, y)
            call DzFrameShow(ItemHUDSlot[slot], false)
            set ItemHUDIcon[slot] = DzCreateFrameByTagName("BACKDROP", "ItemHUDIcon" + I2S(slot), ItemHUDSlot[slot], "", slot)
            call DzFrameSetSize(ItemHUDIcon[slot], ITEM_W - 0.002, ITEM_H - 0.0026)
            call DzFrameSetAbsolutePoint(ItemHUDIcon[slot], JN_FRAMEPOINT_TOPLEFT, x + 0.001, y - 0.0013)
            call DzFrameShow(ItemHUDIcon[slot], false)
            set ItemHUDBorder[slot] = DzCreateFrameByTagName("BACKDROP", "ItemHUDBorder" + I2S(slot), ItemHUDIcon[slot], "", slot)
            call DzFrameSetTexture(ItemHUDBorder[slot], HUD_SLOT_BORDER, 0)
            call DzFrameSetSize(ItemHUDBorder[slot], ITEM_W, ITEM_H)
            call DzFrameSetAbsolutePoint(ItemHUDBorder[slot], JN_FRAMEPOINT_TOPLEFT, x, y)
            set ItemHUDCharges[slot] = DzCreateFrameByTagName("TEXT", "ItemHUDCharges" + I2S(slot), ItemHUDBorder[slot], "SkillHUD_HotkeyText", slot)
            call DzFrameSetAbsolutePoint(ItemHUDCharges[slot], JN_FRAMEPOINT_BOTTOMRIGHT, x + ITEM_W - 0.0022, y - ITEM_H + 0.0022)
            call DzFrameSetEnable(ItemHUDCharges[slot], false)
            set slot = slot + 1
        endloop

        set SkillHUDTip = DzCreateFrameByTagName("BACKDROP", "SkillHUDTip", parent, "SkillHUD_TipBackground", 0)
        call DzFrameSetAlpha(SkillHUDTip, 230)
        call DzFrameSetPriority(SkillHUDTip, 30)
        set SkillHUDTipName = DzCreateFrameByTagName("TEXT", "SkillHUDTipName", SkillHUDTip, "SkillHUD_TipName", 0)
        call DzFrameSetPoint(SkillHUDTipName, JN_FRAMEPOINT_TOPLEFT, SkillHUDTip, JN_FRAMEPOINT_TOPLEFT, 0.01, -0.01)
        set SkillHUDTipDescription = DzCreateFrameByTagName("TEXT", "SkillHUDTipDescription", SkillHUDTip, "SkillHUD_TipDescription", 0)
        call DzFrameSetAbsolutePoint(SkillHUDTipDescription, JN_FRAMEPOINT_BOTTOMRIGHT, 0.795, 0.185)
        call DzFrameSetSize(SkillHUDTipDescription, 0.21, 0.0)
        call DzFrameSetPoint(SkillHUDTip, JN_FRAMEPOINT_TOPLEFT, SkillHUDTipDescription, JN_FRAMEPOINT_TOPLEFT, -0.005, 0.023)
        call DzFrameSetPoint(SkillHUDTip, JN_FRAMEPOINT_BOTTOMRIGHT, SkillHUDTipDescription, JN_FRAMEPOINT_BOTTOMRIGHT, 0.005, -0.005)
        call DzFrameSetEnable(SkillHUDTipName, false)
        call DzFrameSetEnable(SkillHUDTipDescription, false)
        call DzFrameShow(SkillHUDTip, false)

        call TimerStart(CreateTimer(), 0.05, true, function Update)
    endfunction

    private function BindInput takes nothing returns boolean
        if SkillHUDIcon[0] == 0 then
            return false
        endif
        call DzTriggerRegisterMouseEventByCode(null, JN_MOUSE_BUTTON_TYPE_LEFT, 0, false, function AltClick)
        return true
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local trigger syncTrigger = CreateTrigger()
        call DzLoadToc("UnifiedUI.toc")
        call TriggerRegisterTimerEventSingle(t, 0.00)
        call TriggerAddAction(t, function Create)
        call DzTriggerRegisterSyncData(syncTrigger, "HPing", false)
        call TriggerAddAction(syncTrigger, function SyncPing)
        set t = null
        set syncTrigger = null
        call UIInputAfterPick(function BindInput)
    endfunction
endlibrary
