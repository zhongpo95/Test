//! import "JNMemory.j"
//! import "DzAPIFrameHandle.j"

scope NGUI initializer NGUI_init

function NGUI_timer2 takes nothing returns nothing
    local integer UI = DzGetGameUI()
    local integer f = 0
    local integer a = 3
    local integer b = 2
    local real size = 0.032
    local real offset = 0.0039
    local real maxsize_a = I2R(a) * size
    local real maxsize_b = I2R(b) * size
    local integer frame
    local integer frame2
    local integer UIFrame

    call DestroyTimer(GetExpiredTimer())
    
        set UIFrame=JNCreateFrameByType("FRAME","heroStatusUI",DzGetGameUI(),"",0)
        call DzFrameShow(UIFrame,true)
        set frame=JNCreateFrameByType("BACKDROP","Command01",UIFrame,"",0)
        call DzFrameSetTexture(frame2,"Transparent.blp",0)
        //call DzFrameSetTexture(frame2,"ReplaceableTextures\\CommandButtons\\BTNDispelMagic.blp",0)
        call DzFrameSetSize(frame2,0.02,0.02)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_TOPLEFT,0.6075, 0.1205)
        call DzFrameShow(frame2,true)
        set frame2 = DzFrameGetCommandBarButton(0,0)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(frame2,JN_FRAMEPOINT_TOPLEFT,frame,JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        call DzFrameShow(frame2,true)
        
        set frame=JNCreateFrameByType("BACKDROP","Command02",UIFrame,"",0)
        call DzFrameSetTexture(frame2,"Transparent.blp",0)
        //call DzFrameSetTexture(frame2,"ReplaceableTextures\\CommandButtons\\BTNDispelMagic.blp",0)
        call DzFrameSetSize(frame2,0.02,0.02)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_TOPLEFT,0.6443, 0.1205)
        call DzFrameShow(frame2,true)
        set frame2 = DzFrameGetCommandBarButton(0,1)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(frame2,JN_FRAMEPOINT_TOPLEFT,frame,JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        call DzFrameShow(frame2,true)
        
        set frame=JNCreateFrameByType("BACKDROP","Command03",UIFrame,"",0)
        call DzFrameSetTexture(frame2,"Transparent.blp",0)
        //call DzFrameSetTexture(frame2,"ReplaceableTextures\\CommandButtons\\BTNDispelMagic.blp",0)
        call DzFrameSetSize(frame2,0.02,0.02)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_TOPLEFT,0.6811, 0.1205)
        
        call DzFrameShow(frame2,true)
        set frame2 = DzFrameGetCommandBarButton(0,2)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(frame2,JN_FRAMEPOINT_TOPLEFT,frame,JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        call DzFrameShow(frame2,true)
        
        set frame=JNCreateFrameByType("BACKDROP","Command04",UIFrame,"",0)
        call DzFrameSetTexture(frame2,"Transparent.blp",0)
        //call DzFrameSetTexture(frame2,"ReplaceableTextures\\CommandButtons\\BTNDispelMagic.blp",0)
        call DzFrameSetSize(frame2,0.02,0.02)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_TOPLEFT,0.7179, 0.1205)
        call DzFrameShow(frame2,true)
        set frame2 = DzFrameGetCommandBarButton(0,3)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(frame2,JN_FRAMEPOINT_TOPLEFT,frame,JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        call DzFrameShow(frame2,true)
        
        set frame=JNCreateFrameByType("BACKDROP","Command05",UIFrame,"",0)
        call DzFrameSetTexture(frame2,"Transparent.blp",0)
        //call DzFrameSetTexture(frame2,"ReplaceableTextures\\CommandButtons\\BTNDispelMagic.blp",0)
        call DzFrameSetSize(frame2,0.02,0.02)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_TOPLEFT,0.6075, 0.0840)
        call DzFrameShow(frame2,true)
        set frame2 = DzFrameGetCommandBarButton(1,0)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(frame2,JN_FRAMEPOINT_TOPLEFT,frame,JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        call DzFrameShow(frame2,true)
        
        set frame=JNCreateFrameByType("BACKDROP","Command06",UIFrame,"",0)
        call DzFrameSetTexture(frame2,"Transparent.blp",0)
        //call DzFrameSetTexture(frame2,"ReplaceableTextures\\CommandButtons\\BTNDispelMagic.blp",0)
        call DzFrameSetSize(frame2,0.02,0.02)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_TOPLEFT,0.6443, 0.0840)
        call DzFrameShow(frame2,true)
        set frame2 = DzFrameGetCommandBarButton(1,1)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(frame2,JN_FRAMEPOINT_TOPLEFT,frame,JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        call DzFrameShow(frame2,true)
        
        set frame=JNCreateFrameByType("BACKDROP","Command07",UIFrame,"",0)
        call DzFrameSetTexture(frame2,"Transparent.blp",0)
        //call DzFrameSetTexture(frame2,"ReplaceableTextures\\CommandButtons\\BTNDispelMagic.blp",0)
        call DzFrameSetSize(frame2,0.02,0.02)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_TOPLEFT,0.6811, 0.0840)
        
        call DzFrameShow(frame2,true)
        set frame2 = DzFrameGetCommandBarButton(1,2)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(frame2,JN_FRAMEPOINT_TOPLEFT,frame,JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        call DzFrameShow(frame2,true)
        
        set frame=JNCreateFrameByType("BACKDROP","Command08",UIFrame,"",0)
        call DzFrameSetTexture(frame2,"Transparent.blp",0)
        //call DzFrameSetTexture(frame2,"ReplaceableTextures\\CommandButtons\\BTNDispelMagic.blp",0)
        call DzFrameSetSize(frame2,0.02,0.02)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_TOPLEFT,0.7179, 0.0840)
        call DzFrameShow(frame2,true)
        set frame2 = DzFrameGetCommandBarButton(1,3)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(frame2,JN_FRAMEPOINT_TOPLEFT,frame,JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        call DzFrameShow(frame2,true)
        
        set frame=JNCreateFrameByType("BACKDROP","Command09",UIFrame,"",0)
        call DzFrameSetTexture(frame2,"Transparent.blp",0)
        //call DzFrameSetTexture(frame2,"ReplaceableTextures\\CommandButtons\\BTNDispelMagic.blp",0)
        call DzFrameSetSize(frame2,0.02,0.02)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_TOPLEFT,0.6075, 0.0475)
        call DzFrameShow(frame2,true)
        set frame2 = DzFrameGetCommandBarButton(2,0)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(frame2,JN_FRAMEPOINT_TOPLEFT,frame,JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        call DzFrameShow(frame2,true)
        
        set frame=JNCreateFrameByType("BACKDROP","Command10",UIFrame,"",0)
        call DzFrameSetTexture(frame2,"Transparent.blp",0)
        //call DzFrameSetTexture(frame2,"ReplaceableTextures\\CommandButtons\\BTNDispelMagic.blp",0)
        call DzFrameSetSize(frame2,0.02,0.02)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_TOPLEFT,0.6443, 0.0475)
        call DzFrameShow(frame2,true)
        set frame2 = DzFrameGetCommandBarButton(2,1)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(frame2,JN_FRAMEPOINT_TOPLEFT,frame,JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        call DzFrameShow(frame2,true)
        
        set frame=JNCreateFrameByType("BACKDROP","Command11",UIFrame,"",0)
        call DzFrameSetTexture(frame2,"Transparent.blp",0)
        //call DzFrameSetTexture(frame2,"ReplaceableTextures\\CommandButtons\\BTNDispelMagic.blp",0)
        call DzFrameSetSize(frame2,0.02,0.02)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_TOPLEFT,0.6811, 0.0475)
        
        call DzFrameShow(frame2,true)
        set frame2 = DzFrameGetCommandBarButton(2,2)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(frame2,JN_FRAMEPOINT_TOPLEFT,frame,JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        call DzFrameShow(frame2,true)
        
        set frame=JNCreateFrameByType("BACKDROP","Command12",UIFrame,"",0)
        call DzFrameSetTexture(frame2,"Transparent.blp",0)
        //call DzFrameSetTexture(frame2,"ReplaceableTextures\\CommandButtons\\BTNDispelMagic.blp",0)
        call DzFrameSetSize(frame2,0.02,0.02)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_TOPLEFT,0.7179, 0.0475)
        call DzFrameShow(frame2,true)
        set frame2 = DzFrameGetCommandBarButton(2,3)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(frame2,JN_FRAMEPOINT_TOPLEFT,frame,JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        call DzFrameShow(frame2,true)
        
        
        set frame=JNCreateFrameByType("BACKDROP","Command12",UIFrame,"",0)
        call DzFrameSetTexture(frame2,"Transparent.blp",0)
        //call DzFrameSetTexture(frame2,"ReplaceableTextures\\CommandButtons\\BTNDispelMagic.blp",0)
        call DzFrameSetSize(frame2,0.02,0.02)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_TOPLEFT,0.5475,0.1185)
        set frame2 = DzFrameGetItemBarButton(0)
        call DzFrameSetSize(frame2,.0225,.0225)
        call DzFrameSetPoint(DzFrameGetItemBarButton(0),JN_FRAMEPOINT_TOPLEFT,frame,JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        
        set frame=JNCreateFrameByType("BACKDROP","Command13",UIFrame,"",0)
        call DzFrameSetTexture(frame2,"Transparent.blp",0)
        //call DzFrameSetTexture(frame2,"ReplaceableTextures\\CommandButtons\\BTNDispelMagic.blp",0)
        call DzFrameSetSize(frame2,0.02,0.02)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_TOPLEFT,0.5475,0.08175)
        set frame2 = DzFrameGetItemBarButton(1)
        call DzFrameSetSize(frame2,.0225,.0225)
        call DzFrameSetPoint(DzFrameGetItemBarButton(1),JN_FRAMEPOINT_TOPLEFT,frame,JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        
        set frame=JNCreateFrameByType("BACKDROP","Command14",UIFrame,"",0)
        call DzFrameSetTexture(frame2,"Transparent.blp",0)
        //call DzFrameSetTexture(frame2,"ReplaceableTextures\\CommandButtons\\BTNDispelMagic.blp",0)
        call DzFrameSetSize(frame2,0.02,0.02)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_TOPLEFT,0.5475,0.0440)
        set frame2 = DzFrameGetItemBarButton(2)
        call DzFrameSetSize(frame2,.0225,.0225)
        call DzFrameSetPoint(DzFrameGetItemBarButton(2),JN_FRAMEPOINT_TOPLEFT,frame,JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        
        set frame=DzFrameGetPortrait()
        call DzFrameClearAllPoints(frame)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_BOTTOMLEFT,.180, .040)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_TOPRIGHT,.275, .15)
        
endfunction
    
function NGUI_timer takes nothing returns nothing
    
        local integer HPBarBorder
        local integer MPBarBorder
        local integer HPBar
        local integer SDBar
        local integer MPBar
        local integer HPTextFrame
        local integer MPTextFrame
        local unit SelecttingUnit = null
    
    call DestroyTimer(GetExpiredTimer())
    
    
        set HPBarBorder=DzCreateFrameByTagName("SIMPLESTATUSBAR","",DzFrameFindByName("InfoPanelIconBackdrop",0),"", 0)
        call DzFrameSetAbsolutePoint(HPBarBorder,JN_FRAMEPOINT_TOPLEFT,.180,.0300)
        call DzFrameSetAbsolutePoint(HPBarBorder,JN_FRAMEPOINT_BOTTOMRIGHT,.520,.0140)
        call DzFrameSetTexture(HPBarBorder,"war3mapImported\\HPBarBackDrop.tga",0)
        call DzFrameSetMinMaxValue(HPBarBorder,0,'d')
        call DzFrameSetValue(HPBarBorder,'d')
        set HPBar=DzCreateFrameByTagName("SIMPLESTATUSBAR","",HPBarBorder,"", 0)
        call DzFrameSetAbsolutePoint(HPBar,JN_FRAMEPOINT_TOPLEFT,.180+.0025,.0300-.0025)
        call DzFrameSetAbsolutePoint(HPBar,JN_FRAMEPOINT_BOTTOMRIGHT,.520-.0025,.0140+.0025)
        call DzFrameSetTexture(HPBar,"war3mapImported\\HPBar.tga",0)
        call DzFrameSetMinMaxValue(HPBar,0,'d')
        call DzFrameSetValue(HPBar,'d')
        set SDBar=DzCreateFrameByTagName("SIMPLESTATUSBAR","",HPBarBorder,"", 0)
        call DzFrameSetAbsolutePoint(SDBar,JN_FRAMEPOINT_TOPLEFT,.180+.0025,.0380-.0025)
        call DzFrameSetAbsolutePoint(SDBar,JN_FRAMEPOINT_BOTTOMRIGHT,.520-.0025,.0300-.0025)
        call DzFrameSetTexture(SDBar,"war3mapImported\\BSDBar.tga",0)
        call DzFrameSetMinMaxValue(SDBar,0,'d')
        call DzFrameSetValue(SDBar,0)
        set HPTextFrame=DzCreateFrameByTagName("TEXT","",DzGetGameUI(),"", 0)
        call DzFrameSetAbsolutePoint(HPTextFrame,JN_FRAMEPOINT_CENTER,.3575,.0220)
        call DzFrameSetFont(HPTextFrame, "Fonts\\DFHeiMd.ttf", 0.010, 0)
        call DzFrameSetText(HPTextFrame,"0/0")
        
        //call PlayersHPBarShow(GetLocalPlayer(),false)
        
        call DzFrameShow(HPTextFrame,true)
        call DzFrameSetAbsolutePoint(HPBarBorder,JN_FRAMEPOINT_TOPLEFT,.180,.0300)
        call DzFrameSetAbsolutePoint(HPBarBorder,JN_FRAMEPOINT_BOTTOMRIGHT,.520,.0140)
        call DzFrameSetAbsolutePoint(HPBar,JN_FRAMEPOINT_TOPLEFT,.180+.0025,.0300-.0025)
        call DzFrameSetAbsolutePoint(HPBar,JN_FRAMEPOINT_BOTTOMRIGHT,.520-.0025,.0140+.0025)
        call DzFrameSetAbsolutePoint(SDBar,JN_FRAMEPOINT_TOPLEFT,.180+.0025,.0380-.0025)
        call DzFrameSetAbsolutePoint(SDBar,JN_FRAMEPOINT_BOTTOMRIGHT,.520-.0025,.0300-.0025)
    
    call TimerStart(CreateTimer(), 0.5, false, function NGUI_timer2)
endfunction

function NGUI_init takes nothing returns nothing
    local integer UI = DzGetGameUI()
    local integer f = 0

    // 미니맵 크기 변경
    //set f = DzFrameGetMinimap()
    //call DzFrameClearAllPoints(f)
    //call DzFrameSetPoint(f, JN_FRAMEPOINT_BOTTOMLEFT, UI, JN_FRAMEPOINT_BOTTOMLEFT, 0.015,0.015)
    //call DzFrameSetPoint(f, JN_FRAMEPOINT_TOPRIGHT, UI, JN_FRAMEPOINT_BOTTOMLEFT, 0.145,0.14)

    call TimerStart(CreateTimer(), 0.5, false, function NGUI_timer)
endfunction

endscope


        set frame2 = DzFrameGetCommandBarButton(0,0)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(DzFrameGetCommandBarButton(0,0),JN_FRAMEPOINT_TOPLEFT,JNGetFrameByName("Command01",0),JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        set frame2 = DzFrameGetCommandBarButton(0,1)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(DzFrameGetCommandBarButton(0,1),JN_FRAMEPOINT_TOPLEFT,JNGetFrameByName("Command02",0),JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        set frame2 = DzFrameGetCommandBarButton(0,2)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(DzFrameGetCommandBarButton(0,2),JN_FRAMEPOINT_TOPLEFT,JNGetFrameByName("Command03",0),JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        set frame2 = DzFrameGetCommandBarButton(0,3)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(DzFrameGetCommandBarButton(0,3),JN_FRAMEPOINT_TOPLEFT,JNGetFrameByName("Command04",0),JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        set frame2 = DzFrameGetCommandBarButton(1,0)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(DzFrameGetCommandBarButton(1,0),JN_FRAMEPOINT_TOPLEFT,JNGetFrameByName("Command05",0),JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        set frame2 = DzFrameGetCommandBarButton(1,1)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(DzFrameGetCommandBarButton(1,1),JN_FRAMEPOINT_TOPLEFT,JNGetFrameByName("Command06",0),JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        set frame2 = DzFrameGetCommandBarButton(1,2)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(DzFrameGetCommandBarButton(1,2),JN_FRAMEPOINT_TOPLEFT,JNGetFrameByName("Command07",0),JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        set frame2 = DzFrameGetCommandBarButton(1,3)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(DzFrameGetCommandBarButton(1,3),JN_FRAMEPOINT_TOPLEFT,JNGetFrameByName("Command08",0),JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        set frame2 = DzFrameGetCommandBarButton(2,0)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(DzFrameGetCommandBarButton(2,0),JN_FRAMEPOINT_TOPLEFT,JNGetFrameByName("Command09",0),JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        set frame2 = DzFrameGetCommandBarButton(2,1)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(DzFrameGetCommandBarButton(2,1),JN_FRAMEPOINT_TOPLEFT,JNGetFrameByName("Command10",0),JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        set frame2 = DzFrameGetCommandBarButton(2,2)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(DzFrameGetCommandBarButton(2,2),JN_FRAMEPOINT_TOPLEFT,JNGetFrameByName("Command11",0),JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        
        set frame2 = DzFrameGetItemBarButton(0)
        call DzFrameSetSize(frame2,.0225,.0225)
        call DzFrameSetPoint(DzFrameGetItemBarButton(0),JN_FRAMEPOINT_TOPLEFT,JNGetFrameByName("Command12",0),JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        set frame2 = DzFrameGetItemBarButton(1)
        call DzFrameSetSize(frame2,.0225,.0225)
        call DzFrameSetPoint(DzFrameGetItemBarButton(1),JN_FRAMEPOINT_TOPLEFT,JNGetFrameByName("Command13",0),JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        set frame2 = DzFrameGetItemBarButton(2)
        call DzFrameSetSize(frame2,.0225,.0225)
        call DzFrameSetPoint(DzFrameGetItemBarButton(2),JN_FRAMEPOINT_TOPLEFT,JNGetFrameByName("Command14",0),JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        set frame2 = DzFrameGetItemBarButton(3)
        call DzFrameSetSize(frame2,.0225,.0225)
        call DzFrameSetPoint(DzFrameGetItemBarButton(3),JN_FRAMEPOINT_TOPLEFT,JNGetFrameByName("Command15",0),JN_FRAMEPOINT_TOPLEFT,0.0,0.0)