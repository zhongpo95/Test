library UICastingBar initializer init requires UnitIndexer, DataUnit
    globals
        integer CastingBarBorder
        integer CastingBar
        integer CastingTextFrame
    endglobals
    
    function CastingBarShow takes player p , boolean state returns nothing
        if p == GetLocalPlayer() then
            if state then
                call DzFrameShow(CastingTextFrame,true)
                call DzFrameSetAbsolutePoint(CastingBarBorder,JN_FRAMEPOINT_TOPLEFT,.320,.1800)
                call DzFrameSetAbsolutePoint(CastingBarBorder,JN_FRAMEPOINT_BOTTOMRIGHT,.480,.1700)
                call DzFrameSetAbsolutePoint(CastingBar,JN_FRAMEPOINT_TOPLEFT,.320+.0025,.1800)
                call DzFrameSetAbsolutePoint(CastingBar,JN_FRAMEPOINT_BOTTOMRIGHT,.480-.0025,.1700)
            else
                call DzFrameShow(CastingTextFrame,false)
                call DzFrameSetAbsolutePoint(CastingBarBorder,JN_FRAMEPOINT_TOPLEFT,-1,-1)
                call DzFrameSetAbsolutePoint(CastingBarBorder,JN_FRAMEPOINT_BOTTOMRIGHT,-1,-1)
                call DzFrameSetAbsolutePoint(CastingBar,JN_FRAMEPOINT_TOPLEFT,-1,-1)
                call DzFrameSetAbsolutePoint(CastingBar,JN_FRAMEPOINT_BOTTOMRIGHT,-1,-1)
            endif
        endif
    endfunction
    
    private function MyBarCreate takes nothing returns nothing
        set CastingBarBorder=DzCreateFrameByTagName("SIMPLESTATUSBAR","",DzFrameFindByName("InfoPanelIconBackdrop",0),"",0)
        call DzFrameSetAbsolutePoint(CastingBarBorder,JN_FRAMEPOINT_TOPLEFT,.320,.1800)
        call DzFrameSetAbsolutePoint(CastingBarBorder,JN_FRAMEPOINT_BOTTOMRIGHT,.480,.1700)
        call DzFrameSetTexture(CastingBarBorder,"war3mapImported\\HPBarBackDrop.tga",0)
        call DzFrameSetMinMaxValue(CastingBarBorder,0,'d')
        call DzFrameSetValue(CastingBarBorder,'d')
        set CastingBar=DzCreateFrameByTagName("SIMPLESTATUSBAR","",CastingBarBorder,"",0)
        call DzFrameSetAbsolutePoint(CastingBar,JN_FRAMEPOINT_TOPLEFT,.320+.0025,.1800)
        call DzFrameSetAbsolutePoint(CastingBar,JN_FRAMEPOINT_BOTTOMRIGHT,.480-.0025,.1700)
        call DzFrameSetTexture(CastingBar,"war3mapImported\\CastingBar.tga",0)
        call DzFrameSetMinMaxValue(CastingBar,0,25.00)
        call DzFrameSetValue(CastingBar,0)
        set CastingTextFrame=DzCreateFrameByTagName("TEXT","",DzGetGameUI(),"",0)
        call DzFrameSetAbsolutePoint(CastingTextFrame,JN_FRAMEPOINT_CENTER,.400,.1750)
        call DzFrameSetFont(CastingTextFrame, "Fonts\\DFHeiMd.ttf", 0.009, 0)
        call DzFrameSetText(CastingTextFrame,"버스트 캐논")
        
        call CastingBarShow(GetLocalPlayer(),false)
    endfunction

    
    private function init takes nothing returns nothing
        local trigger t
        set t = CreateTrigger()
        call TriggerRegisterTimerEventSingle( t, 0.10 )
        call TriggerAddAction( t, function MyBarCreate )
        set t = null
    endfunction
endlibrary