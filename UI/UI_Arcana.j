library UIArcana initializer Init requires DataItem, StatsSet, UIItem, ITEM, FrameCount
    globals
        integer F_ArcanaBackDrop                        //각인 배경
        integer array F_ArcanaButtons               
        integer array F_ArcanaButtonsBackDrop               
        integer array F_ArcanaStatsText
        integer array F_UIArcana1                 
        integer array F_UIArcana2                 
        integer array F_UIArcana3                
        integer array F_UIArcana4              
        
        boolean array F_ArcanaOnOff                     //각인 온오프
    endglobals

    private function F_OFF_Actions takes nothing returns nothing
        call DzFrameShow(UI_Tip, false)
    endfunction
    
    private function ArcanaOpen takes nothing returns nothing
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        //메뉴 버튼을 누르면 메뉴 버튼 비활설화 + 메뉴 배경 표시
        //다시 메뉴 버튼을 누르면 메뉴버튼 활성화 + 메뉴 배경 숨김
        if F_ArcanaOnOff[pid] == true then
            call DzFrameShow(F_ArcanaBackDrop, false)
            set F_ArcanaOnOff[pid] = false
        else
            if F_InfoOnOff[pid] == true then
                call DzFrameShow(F_InfoBackDrop, false)
                set F_InfoOnOff[pid] = false
            endif
            call DzFrameShow(F_ArcanaBackDrop, true)
            set F_ArcanaOnOff[pid] = true
        endif
    endfunction

    private function F_ON_Actions1 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local string str = ""
        
        call DzFrameShow(UI_Tip, true)
        call DzFrameSetText(UI_Tip_Text[1], "공격력 감소" )
        set str = "|cFFA5FA7D ◎ |r" + "공격력이 0/2/4/8/16% 감소한다." 
        call DzFrameSetText(UI_Tip_Text[2], str )
    endfunction

    private function F_ON_Actions2 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local string str = ""
        
        call DzFrameShow(UI_Tip, true)
        call DzFrameSetText(UI_Tip_Text[1], "체력 감소" )
        set str = "|cFFA5FA7D ◎ |r" + "체력이 0/5/10/15/30% 감소한다"
        call DzFrameSetText(UI_Tip_Text[2], str )
    endfunction

    private function F_ON_Actions3 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local string str = ""
        
        call DzFrameShow(UI_Tip, true)
        call DzFrameSetText(UI_Tip_Text[1], "공격속도 감소" )
        set str = "|cFFA5FA7D ◎ |r" + "공격속도가 0/2/4/8/16% 감소한다."
        call DzFrameSetText(UI_Tip_Text[2], str )
    endfunction

    private function F_ON_Actions4 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local string str = ""
        
        call DzFrameShow(UI_Tip, true)
        call DzFrameSetText(UI_Tip_Text[1], "이동속도 감소" )
        set str = "|cFFA5FA7D ◎ |r" + "이동속도가 0/2/4/8/16% 감소한다."
        call DzFrameSetText(UI_Tip_Text[2], str )
    endfunction


    private function F_ON_Actions takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local string str = ""
        local string items = ""
        local integer itemid = 0
        local integer i = 0
        local integer quality = 0
        local integer up = 0
        local integer cts = 0
        local integer tier = 0
        local item tem
        
        if f ==  F_ArcanaButtons[0] then
            set items = Eitem[pid][6]
            set itemid = GetItemIDs(items)
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "목걸이" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        elseif f ==  F_ArcanaButtons[1] then
            set items = Eitem[pid][7]
            set itemid = GetItemIDs(items)
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "귀걸이" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        elseif f ==  F_ArcanaButtons[2] then
            set items = Eitem[pid][8]
            set itemid = GetItemIDs(items)
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "귀걸이" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        elseif f ==  F_ArcanaButtons[3] then
            set items = Eitem[pid][9]
            set itemid = GetItemIDs(items)
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "반지" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        elseif f ==  F_ArcanaButtons[4] then
            set items = Eitem[pid][10]
            set itemid = GetItemIDs(items)
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "반지" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        elseif f ==  F_ArcanaButtons[5] then
            set items = Eitem[pid][12]
            set itemid = GetItemIDs(items)
            if itemid == 0 then
                call DzFrameShow(UI_Tip, true)
                call DzFrameSetText(UI_Tip_Text[1], "카드" )
                call DzFrameSetText(UI_Tip_Text[2], "")
            endif
        endif
                
        if itemid != 0 then
            call DzFrameShow(UI_Tip, true)
            set i = GetItemTypes(items)
            set up = GetItemUp(items)
            set quality = GetItemQuality(items)
            set cts = GetItemCombatStats(items)
            set tier = GetItemTier(items)
                
            if i >= 6 or tier == 1 then
                call DzFrameSetText(UI_Tip_Text[1], GetItemNames(items) )
            else
                call DzFrameSetText(UI_Tip_Text[1], "+" + I2S(up) + " " + GetItemNames(items) )
            endif
            set str = "|cFFA5FA7D[ 종류 ]|r "
            if i == 6 then
                set str = str + "목걸이|n|n"
                //치신
                
                if cts == 1 then
                    set str = str + "|c005AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA치명|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                    set str = str + "|n  |cFFB9E2FA신속|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //치치
                elseif cts == 2 then
                    set str = str + "|c005AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA치명|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                    set str = str + "|n  |cFFB9E2FA치명|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //신신
                elseif cts == 3 then
                    set str = str + "|c005AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA신속|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                    set str = str + "|n  |cFFB9E2FA신속|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                endif
                //아르카나
                if GetItemCombatBonus2(items) + GetItemCombatPenalty2(items) > 0 then
                    set str = str + "|n|n|c005AD2FF[ 아르카나 ]|r|n"
                    set str = str + "  [|cFFFFE400 " + ArcanaText[GetItemCombatBonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombatBonus2(items))
                    set str = str + "|n  [|cFFFF0000 " + ArcanaText[GetItemCombatPenalty(items)] + " |r]"
                endif
            elseif i == 7 then
                set str = str + "귀걸이|n|n"
                //치
                if cts == 1 then
                    set str = str + "|c005AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA치명|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //신
                elseif cts == 2 then
                    set str = str + "|c005AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA신속|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                endif
                //아르카나
                if GetItemCombatBonus2(items) + GetItemCombatPenalty2(items) > 0 then
                    set str = str + "|n|n|c005AD2FF[ 아르카나 ]|r|n"
                    set str = str + "  [|cFFFFE400 " + ArcanaText[GetItemCombatBonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombatBonus2(items))
                    set str = str + "|n  [|cFFFF0000 " + ArcanaText[GetItemCombatPenalty(items)] + " |r]"
                endif
            elseif i == 8 then
                set str = str + "반지|n|n"
                //치
                if cts == 1 then
                    set str = str + "|c005AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA치명|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                //신
                elseif cts == 2 then
                    set str = str + "|c005AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                    set str = str + "  |cFFB9E2FA신속|r "
                    set str = str + I2S(S2I(JNStringSplit(ItemStats[i][tier],";", 0 ))) + "|c005AD2FF +" + I2S( quality * S2I(JNStringSplit(ItemStats[i][tier],";", 1 ))) + "|r"
                endif
                //아르카나
                if GetItemCombatBonus2(items) + GetItemCombatPenalty2(items) > 0 then
                    set str = str + "|n|n|c005AD2FF[ 아르카나 ]|r|n"
                    set str = str + "  [|cFFFFE400 " + ArcanaText[GetItemCombatBonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombatBonus2(items))
                    set str = str + "|n  [|cFFFF0000 " + ArcanaText[GetItemCombatPenalty(items)] + " |r]"
                endif
            elseif i == 9 then
                set str = str + "팔찌|n|n"
            elseif i == 10 then
                set str = str + "카드|n|n"
                set str = str + "|n|cFFB9E2FA체력 + "
                set str = str + "0"
                if GetItemCombatBonus2(items) + GetItemCombatPenalty2(items) > 0 then
                    set str = str + "|n|n|c005AD2FF[ 아르카나 ]|r|n"
                    set str = str + "  [|cFFFFE400 " + ArcanaText[GetItemCombatBonus1(items)] + " |r] 활성도 +"
                    set str = str + I2S(GetItemCombatBonus2(items))
                    set str = str + "|n  [|cFFFF0000 " + ArcanaText[GetItemCombatPenalty(items)] + " |r]"
                endif
            elseif i == 11 then
                set str = str + "보석|n|n"
            elseif i == 12 then
                set str = str + "보석2|n|n"
            endif
            
            call DzFrameSetText(UI_Tip_Text[2], str)
        endif
    endfunction

    private function CreateEItemButton takes integer types, real x, real y returns nothing
        set F_ArcanaButtons[types]=DzCreateFrameByTagName("BUTTON", "", F_ArcanaBackDrop, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetPoint(F_ArcanaButtons[types], JN_FRAMEPOINT_CENTER, F_ArcanaBackDrop , JN_FRAMEPOINT_BOTTOMLEFT, x, y)
        call DzFrameSetSize(F_ArcanaButtons[types], 0.030, 0.030)
        
        set F_ArcanaButtonsBackDrop[types]=DzCreateFrameByTagName("BACKDROP", "", F_ArcanaButtons[types], "", FrameCount())
        call DzFrameSetAllPoints(F_ArcanaButtonsBackDrop[types], F_ArcanaButtons[types])
        call DzFrameSetTexture(F_ArcanaButtonsBackDrop[types],"UI_Inventory.blp", 0)
        
        call DzFrameSetScriptByCode(F_ArcanaButtons[types], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions, false)
        call DzFrameSetScriptByCode(F_ArcanaButtons[types], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        call SaveInteger(Hash, F_ArcanaButtons[types], StringHash("number"), types+201)
    endfunction
    
    private function Main takes nothing returns nothing
        local string s
        local integer i
        call DzLoadToc("war3mapImported\\Templates.toc")

        //메뉴 배경
        set F_ArcanaBackDrop=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "template", FrameCount())
        call DzFrameSetTexture(F_ArcanaBackDrop, "File00005255.blp", 0)
        call DzFrameSetAbsolutePoint(F_ArcanaBackDrop, JN_FRAMEPOINT_CENTER, 0.225, 0.315)
        call DzFrameSetSize(F_ArcanaBackDrop, 0.40, 0.43)

        call CreateEItemButton(0 , 0.065 , 0.350)
        call CreateEItemButton(1 , 0.105 , 0.350)
        call CreateEItemButton(2 , 0.145 , 0.350)
        call CreateEItemButton(3 , 0.185 , 0.350)
        call CreateEItemButton(4 , 0.225 , 0.350)
        call CreateEItemButton(5 , 0.315 , 0.350)
        
        set F_ArcanaStatsText[0]=DzCreateFrameByTagName("TEXT", "", F_ArcanaBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_ArcanaStatsText[0], JN_FRAMEPOINT_CENTER, F_ArcanaBackDrop, JN_FRAMEPOINT_BOTTOMLEFT, 0.090, 0.130)
        call DzFrameSetText(F_ArcanaStatsText[0], "|cFFFFE400공격력 감소")
        
        set F_ArcanaStatsText[0]=DzCreateFrameByTagName("TEXT", "", F_ArcanaBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_ArcanaStatsText[0], JN_FRAMEPOINT_CENTER, F_ArcanaBackDrop, JN_FRAMEPOINT_BOTTOMLEFT, 0.330, 0.130)
        call DzFrameSetText(F_ArcanaStatsText[0], "0%")
        call DzFrameSetScriptByCode(F_ArcanaStatsText[0], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions1, false)
        call DzFrameSetScriptByCode(F_ArcanaStatsText[0], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        set F_ArcanaStatsText[1]=DzCreateFrameByTagName("TEXT", "", F_ArcanaBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_ArcanaStatsText[1], JN_FRAMEPOINT_CENTER, F_ArcanaBackDrop, JN_FRAMEPOINT_BOTTOMLEFT, 0.090, 0.105)
        call DzFrameSetText(F_ArcanaStatsText[1], "|cFFFFE400체력 감소")
        
        set F_ArcanaStatsText[1]=DzCreateFrameByTagName("TEXT", "", F_ArcanaBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_ArcanaStatsText[1], JN_FRAMEPOINT_CENTER, F_ArcanaBackDrop, JN_FRAMEPOINT_BOTTOMLEFT, 0.330, 0.105)
        call DzFrameSetText(F_ArcanaStatsText[1], "0%")
        call DzFrameSetScriptByCode(F_ArcanaStatsText[1], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions2, false)
        call DzFrameSetScriptByCode(F_ArcanaStatsText[1], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        set F_ArcanaStatsText[2]=DzCreateFrameByTagName("TEXT", "", F_ArcanaBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_ArcanaStatsText[2], JN_FRAMEPOINT_CENTER, F_ArcanaBackDrop, JN_FRAMEPOINT_BOTTOMLEFT, 0.090, 0.080)
        call DzFrameSetText(F_ArcanaStatsText[2], "|cFFFFE400공격속도 감소")
        
        set F_ArcanaStatsText[2]=DzCreateFrameByTagName("TEXT", "", F_ArcanaBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_ArcanaStatsText[2], JN_FRAMEPOINT_CENTER, F_ArcanaBackDrop, JN_FRAMEPOINT_BOTTOMLEFT, 0.330, 0.080)
        call DzFrameSetText(F_ArcanaStatsText[2], "0%")
        call DzFrameSetScriptByCode(F_ArcanaStatsText[2], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions3, false)
        call DzFrameSetScriptByCode(F_ArcanaStatsText[2], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        
        set F_ArcanaStatsText[3]=DzCreateFrameByTagName("TEXT", "", F_ArcanaBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_ArcanaStatsText[3], JN_FRAMEPOINT_CENTER, F_ArcanaBackDrop, JN_FRAMEPOINT_BOTTOMLEFT, 0.090, 0.055)
        call DzFrameSetText(F_ArcanaStatsText[3], "|cFFFFE400이동속도 감소")
        
        set F_ArcanaStatsText[3]=DzCreateFrameByTagName("TEXT", "", F_ArcanaBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_ArcanaStatsText[3], JN_FRAMEPOINT_CENTER, F_ArcanaBackDrop, JN_FRAMEPOINT_BOTTOMLEFT, 0.330, 0.055)
        call DzFrameSetText(F_ArcanaStatsText[3], "0%")
        call DzFrameSetScriptByCode(F_ArcanaStatsText[3], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions4, false)
        call DzFrameSetScriptByCode(F_ArcanaStatsText[3], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)

        set F_UIArcana1[0]=DzCreateFrameByTagName("BACKDROP", "", F_ArcanaBackDrop, "template", FrameCount())
        call DzFrameSetPoint(F_UIArcana1[0], JN_FRAMEPOINT_CENTER, F_ArcanaBackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.160 , 0.130 )
        call DzFrameSetSize(F_UIArcana1[0], 0.02125 , 0.02125)
        call DzFrameSetTexture(F_UIArcana1[0], "UI_Arcana_Work3.blp", 0)

        set F_UIArcana1[1]=DzCreateFrameByTagName("BACKDROP", "", F_ArcanaBackDrop, "template", FrameCount())
        call DzFrameSetPoint(F_UIArcana1[1], JN_FRAMEPOINT_CENTER, F_ArcanaBackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.190 , 0.130 )
        call DzFrameSetSize(F_UIArcana1[1], 0.02125 , 0.02125)
        call DzFrameSetTexture(F_UIArcana1[1], "UI_Arcana_Work3.blp", 0)

        set F_UIArcana1[2]=DzCreateFrameByTagName("BACKDROP", "", F_ArcanaBackDrop, "template", FrameCount())
        call DzFrameSetPoint(F_UIArcana1[2], JN_FRAMEPOINT_CENTER, F_ArcanaBackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.220 , 0.130 )
        call DzFrameSetSize(F_UIArcana1[2], 0.02125 , 0.02125)
        call DzFrameSetTexture(F_UIArcana1[2], "UI_Arcana_Work3.blp", 0)

        set F_UIArcana1[3]=DzCreateFrameByTagName("BACKDROP", "", F_ArcanaBackDrop, "template", FrameCount())
        call DzFrameSetPoint(F_UIArcana1[3], JN_FRAMEPOINT_CENTER, F_ArcanaBackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.250 , 0.130 )
        call DzFrameSetSize(F_UIArcana1[3], 0.02125 , 0.02125)
        call DzFrameSetTexture(F_UIArcana1[3], "UI_Arcana_Work3.blp", 0)

        set F_UIArcana1[4]=DzCreateFrameByTagName("BACKDROP", "", F_ArcanaBackDrop, "template", FrameCount())
        call DzFrameSetPoint(F_UIArcana1[4], JN_FRAMEPOINT_CENTER, F_ArcanaBackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.280 , 0.130 )
        call DzFrameSetSize(F_UIArcana1[4], 0.02125 , 0.02125)
        call DzFrameSetTexture(F_UIArcana1[4], "UI_Arcana_Work3.blp", 0)



        
        call DzFrameShow(F_ArcanaBackDrop, false)
    endfunction
    
    private function OKey takes nothing returns nothing
        local integer key = DzGetTriggerKey()
        local integer i = 0
        local integer j = GetPlayerId(DzGetTriggerKeyPlayer())
        
        if DzGetTriggerKeyPlayer()==GetLocalPlayer() then
            set i = JNMemoryGetByte(JNGetModuleHandle("Game.dll")+0xD04FEC)
        endif
        
        if i==1 then
        else
            if PickCheck[j] == true then
                if key == 'O' then
                    if F_ArcanaOnOff[j] == true then
                        call DzFrameShow(F_ArcanaBackDrop, false)
                        set F_ArcanaOnOff[j] = false
                    else
                        if F_InfoOnOff[j] == true then
                            call DzFrameShow(F_InfoBackDrop, false)
                            set F_InfoOnOff[j] = false
                        endif
                        call DzFrameShow(F_ArcanaBackDrop, true)
                        set F_ArcanaOnOff[j] = true
                    endif
                endif
            endif
        endif
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer index
        
        call TriggerRegisterTimerEventSingle( t, 3.0 )
        call TriggerAddAction( t, function Main )
        call DzLoadToc("war3mapimported\\BoxedText.toc")
        
        set F_ArcanaOnOff[0] = false
        set F_ArcanaOnOff[1] = false
        set F_ArcanaOnOff[2] = false
        set F_ArcanaOnOff[3] = false
        set F_ArcanaOnOff[4] = false
        set F_ArcanaOnOff[5] = false
        
        //P버튼으로 인포창 열기 및 닫기
        call DzTriggerRegisterKeyEventByCode(null, 'O', 0, false, function OKey)
        
        set t = null
    endfunction
endlibrary