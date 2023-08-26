library UITIP initializer init
    globals
        integer UI_Tip= 0
        integer array UI_Tip_Text
    endglobals
    
    private function Main takes nothing returns nothing
        call DzLoadToc("war3mapImported\\Templates.toc")
        set UI_Tip=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "EscMenuEditBoxBackdropTemplate", 0)
        //call DzFrameSetTexture(UI_Tip, "war3mapImported\\UI_Black.blp", 0)
        call DzFrameSetSize(UI_Tip, 0, 0)
        call DzFrameShow(UI_Tip, false)
        call DzFrameSetPriority(UI_Tip, 200)
        set UI_Tip_Text[1]=DzCreateFrameByTagName("TEXT", "", UI_Tip, "template", 0)
        call DzFrameSetFont(UI_Tip_Text[1], "Fonts\\DFHeiMd.ttf", 0.012, 0)
        call DzFrameSetTextAlignment(UI_Tip_Text[1], JN_TEXT_JUSTIFY_MIDDLE)
        call DzFrameSetEnable(UI_Tip_Text[1], false)
        call DzFrameSetAlpha(UI_Tip_Text[1], 255)
        call DzFrameSetPoint(UI_Tip_Text[1], 0, UI_Tip, 0, 0.005, - 0.005)
        call DzFrameSetText(UI_Tip_Text[1], "이름")
        set UI_Tip_Text[2]=DzCreateFrameByTagName("TEXT", "", UI_Tip, "template", 0)
        call DzFrameSetFont(UI_Tip_Text[2], "Fonts\\DFHeiMd.ttf", 0.010, 0)
        call DzFrameSetTextAlignment(UI_Tip_Text[2], JN_TEXT_JUSTIFY_MIDDLE)
        call DzFrameSetEnable(UI_Tip_Text[2], false)
        call DzFrameSetAlpha(UI_Tip_Text[2], 255)
        call DzFrameSetPoint(UI_Tip_Text[2], 8, DzGetGameUI(), 8, - 0.005, 0.165)
        call DzFrameSetSize(UI_Tip_Text[2], 0.21, 0.00)
        call DzFrameSetText(UI_Tip_Text[2], "설명")
        call DzFrameSetPoint(UI_Tip, 0, UI_Tip_Text[2], 0, - 0.005, 0.023)
        call DzFrameSetPoint(UI_Tip, 8, UI_Tip_Text[2], 8, 0.005, - 0.005)
    endfunction
    
    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterTimerEventSingle( t, 0.00 )
        call TriggerAddAction( t, function Main )
        set t = null
    endfunction
endlibrary