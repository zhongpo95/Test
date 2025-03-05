library UIHP initializer init requires UnitIndexer, DataUnit, FrameCount
    globals
        integer HPBarBorder
        integer MPBarBorder
        integer HPBar
        integer SDBar
        integer MPBar
        integer HPTextFrame
        integer MPTextFrame
        unit SelecttingUnit = null
        boolean array HPBshow
    endglobals
    
    function PlayersHPBarShow takes player p , boolean state returns nothing
        set HPBshow[GetPlayerId(p)] = state
        if p == GetLocalPlayer() then
            if state then
                call DzFrameShow(HPTextFrame,true)
                call DzFrameSetAbsolutePoint(HPBarBorder,JN_FRAMEPOINT_TOPLEFT,.180,.0300)
                call DzFrameSetAbsolutePoint(HPBarBorder,JN_FRAMEPOINT_BOTTOMRIGHT,.520,.0140)
                call DzFrameSetAbsolutePoint(HPBar,JN_FRAMEPOINT_TOPLEFT,.180+.0025,.0300-.0025)
                call DzFrameSetAbsolutePoint(HPBar,JN_FRAMEPOINT_BOTTOMRIGHT,.520-.0025,.0140+.0025)
                call DzFrameSetAbsolutePoint(SDBar,JN_FRAMEPOINT_TOPLEFT,.180+.0025,.0380-.0025)
                call DzFrameSetAbsolutePoint(SDBar,JN_FRAMEPOINT_BOTTOMRIGHT,.520-.0025,.0300-.0025)
                //call DzFrameSetAbsolutePoint(MPBarBorder,JN_FRAMEPOINT_TOPLEFT,.320,.0300)
                //call DzFrameSetAbsolutePoint(MPBarBorder,JN_FRAMEPOINT_BOTTOMRIGHT,.480,.0200)
                //call DzFrameSetAbsolutePoint(MPBar,JN_FRAMEPOINT_TOPLEFT,.320+.0025,.0300-.0025)
                //call DzFrameSetAbsolutePoint(MPBar,JN_FRAMEPOINT_BOTTOMRIGHT,.480-.0025,.0200+.0025)
            else
                call DzFrameShow(HPTextFrame,false)
                call DzFrameSetAbsolutePoint(HPBarBorder,JN_FRAMEPOINT_TOPLEFT,-1,-1)
                call DzFrameSetAbsolutePoint(HPBarBorder,JN_FRAMEPOINT_BOTTOMRIGHT,-1,-1)
                //call DzFrameSetAbsolutePoint(MPBarBorder,JN_FRAMEPOINT_TOPLEFT,-1,-1)
                //call DzFrameSetAbsolutePoint(MPBarBorder,JN_FRAMEPOINT_BOTTOMRIGHT,-1,-1)
                call DzFrameSetAbsolutePoint(HPBar,JN_FRAMEPOINT_TOPLEFT,-1,-1)
                call DzFrameSetAbsolutePoint(HPBar,JN_FRAMEPOINT_BOTTOMRIGHT,-1,-1)
                call DzFrameSetAbsolutePoint(SDBar,JN_FRAMEPOINT_TOPLEFT,-1,-1)
                call DzFrameSetAbsolutePoint(SDBar,JN_FRAMEPOINT_BOTTOMRIGHT,-1,-1)
                //call DzFrameSetAbsolutePoint(MPBar,JN_FRAMEPOINT_TOPLEFT,-1,-1)
                //call DzFrameSetAbsolutePoint(MPBar,JN_FRAMEPOINT_BOTTOMRIGHT,-1,-1)  
            endif
        endif
    endfunction

    function RefreshHP takes unit u returns nothing
        if ( GetOwningPlayer(u) == GetLocalPlayer() ) then
            call DzFrameSetMinMaxValue(HPBar,0,GetUnitState(u,UNIT_STATE_MAX_LIFE))
            call DzFrameSetValue(HPBar,GetUnitState(u,UNIT_STATE_LIFE))
            if UnitSD[GetUnitIndex(u)] == 0 then
                call DzFrameSetText(HPTextFrame,I2S(R2I(GetUnitState(u,UNIT_STATE_LIFE)))+"/"+I2S(R2I(GetUnitState(u,UNIT_STATE_MAX_LIFE))))
            else
                call DzFrameSetText(HPTextFrame,I2S(R2I(GetUnitState(u,UNIT_STATE_LIFE)))+"/"+I2S(R2I(GetUnitState(u,UNIT_STATE_MAX_LIFE)))+"(+"+I2S(R2I(UnitSD[GetUnitIndex(u)]))+")")
            endif
            call DzFrameSetMinMaxValue(SDBar,0,GetUnitState(u,UNIT_STATE_MAX_LIFE))
            call DzFrameSetValue(SDBar,UnitSD[GetUnitIndex(u)])
            
            //call DzFrameSetMinMaxValue(MPBar,0,GetUnitState(u,UNIT_STATE_MAX_MANA))
            //call DzFrameSetValue(MPBar,GetUnitState(u,UNIT_STATE_MANA))
        endif
        set u = null
    endfunction
    
    private function SELECTEDAction takes nothing returns nothing
        local unit u = GetTriggerUnit()
        //call DzFrameSetValue(bar, GetUnitLifePercent(u))
        
        if ( GetTriggerPlayer() == GetLocalPlayer() ) then
            if IsUnitOwnedByPlayer(GetTriggerUnit(), GetTriggerPlayer()) then
                set SelecttingUnit = u
                call DzFrameSetMinMaxValue(HPBar,0,GetUnitState(u,UNIT_STATE_MAX_LIFE))
                call DzFrameSetValue(HPBar,GetUnitState(u,UNIT_STATE_LIFE))
                call DzFrameSetText(HPTextFrame,I2S(R2I(GetUnitState(u,UNIT_STATE_LIFE)))+"/"+I2S(R2I(GetUnitState(u,UNIT_STATE_MAX_LIFE))))
                call DzFrameSetMinMaxValue(SDBar,0,GetUnitState(u,UNIT_STATE_MAX_LIFE))
                call DzFrameSetValue(SDBar,UnitSD[GetUnitIndex(u)])
                
                //call DzFrameSetMinMaxValue(MPBar,0,GetUnitState(u,UNIT_STATE_MAX_MANA))
                //call DzFrameSetValue(MPBar,GetUnitState(u,UNIT_STATE_MANA))
                //call DzFrameSetText(MPTextFrame,I2S(R2I(GetUnitState(u,UNIT_STATE_MANA)))+"/"+I2S(R2I(GetUnitState(u,UNIT_STATE_MAX_MANA))))
            else
                if SelecttingUnit != null then
                    if FBS_OnOff[GetPlayerId(GetLocalPlayer())] == true then
                        //call VJDebugMsg("아무것도안함")
                    else
                        //call VJDebugMsg("딴거누름")
                        call SelectUnitForPlayerSingle( SelecttingUnit, GetLocalPlayer() )
                    endif
                else
                endif
            endif
        else
        endif
        set u = null
    endfunction

    private function MyBarCreate2 takes nothing returns nothing
        set HPBarBorder=DzCreateFrameByTagName("SIMPLESTATUSBAR","",DzFrameFindByName("InfoPanelIconBackdrop",0),"", FrameCount())
        call DzFrameSetAbsolutePoint(HPBarBorder,JN_FRAMEPOINT_TOPLEFT,.150,.0900)
        call DzFrameSetAbsolutePoint(HPBarBorder,JN_FRAMEPOINT_BOTTOMRIGHT,.305,.0740)
        call DzFrameSetTexture(HPBarBorder,"war3mapImported\\HPBarBackDrop.tga",0)
        call DzFrameSetMinMaxValue(HPBarBorder,0,'d')
        call DzFrameSetValue(HPBarBorder,'d')
        //set MPBarBorder=DzCreateFrameByTagName("SIMPLESTATUSBAR","",DzFrameFindByName("InfoPanelIconBackdrop",0),"",0)
        //call DzFrameSetAbsolutePoint(MPBarBorder,JN_FRAMEPOINT_TOPLEFT,.320,.0300)
        //call DzFrameSetAbsolutePoint(MPBarBorder,JN_FRAMEPOINT_BOTTOMRIGHT,.480,.0200)
        //call DzFrameSetTexture(MPBarBorder,"war3mapImported\\MPBarBackDrop.tga",0)
        //call DzFrameSetMinMaxValue(MPBarBorder,0,'d')
        //call DzFrameSetValue(MPBarBorder,'d')
        set HPBar=DzCreateFrameByTagName("SIMPLESTATUSBAR","",HPBarBorder,"", FrameCount())
        call DzFrameSetAbsolutePoint(HPBar,JN_FRAMEPOINT_TOPLEFT,.150+.0025,.0900-.0025)
        call DzFrameSetAbsolutePoint(HPBar,JN_FRAMEPOINT_BOTTOMRIGHT,.305-.0025,.0740+.0025)
        call DzFrameSetTexture(HPBar,"war3mapImported\\HPBar.tga",0)
        call DzFrameSetMinMaxValue(HPBar,0,'d')
        call DzFrameSetValue(HPBar,'d')
        set SDBar=DzCreateFrameByTagName("SIMPLESTATUSBAR","",HPBarBorder,"", FrameCount())
        call DzFrameSetAbsolutePoint(SDBar,JN_FRAMEPOINT_TOPLEFT,.150+.0025,.0980-.0025)
        call DzFrameSetAbsolutePoint(SDBar,JN_FRAMEPOINT_BOTTOMRIGHT,.305-.0025,.0900-.0025)
        call DzFrameSetTexture(SDBar,"war3mapImported\\BSDBar.tga",0)
        call DzFrameSetMinMaxValue(SDBar,0,'d')
        call DzFrameSetValue(SDBar,0)
        //set MPBar=DzCreateFrameByTagName("SIMPLESTATUSBAR","",MPBarBorder,"",0)
        //call DzFrameSetAbsolutePoint(MPBar,JN_FRAMEPOINT_TOPLEFT,.320+.0025,.0300-.0025)
        //call DzFrameSetAbsolutePoint(MPBar,JN_FRAMEPOINT_BOTTOMRIGHT,.480-.0025,.0200+.0025)
        //call DzFrameSetTexture(MPBar,"war3mapImported\\MPBar.tga",0)
        //call DzFrameSetMinMaxValue(MPBar,0,'d')
        //call DzFrameSetValue(MPBar,'d')
        set HPTextFrame=DzCreateFrameByTagName("TEXT","",DzGetGameUI(),"", FrameCount())
        call DzFrameSetAbsolutePoint(HPTextFrame,JN_FRAMEPOINT_CENTER,.2275,.0820)
        call DzFrameSetFont(HPTextFrame, "Fonts\\DFHeiMd.ttf", 0.010, 0)
        call DzFrameSetText(HPTextFrame,"0/0")
        
        call PlayersHPBarShow(GetLocalPlayer(),false)
        
        //set MPTextFrame=DzCreateFrameByTagName("TEXT","",DzGetGameUI(),"",0)
        //call DzFrameSetAbsolutePoint(MPTextFrame,JN_FRAMEPOINT_CENTER,.400,.0250)
        //call DzFrameSetText(MPTextFrame,"0/0")
    endfunction

    
    private function MyBarCreate takes nothing returns nothing
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
        call PlayersHPBarShow(GetLocalPlayer(),false)
    endfunction
    
    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer index
        call TriggerRegisterTimerEventSingle( t, 0.10 )
        call TriggerAddAction( t, function MyBarCreate )
        
        set t = CreateTrigger()
        set index = 0
        loop
            call TriggerRegisterPlayerUnitEvent(t, Player(index), EVENT_PLAYER_UNIT_SELECTED, null)
            set index = index + 1
            exitwhen index == bj_MAX_PLAYER_SLOTS
        endloop
        call TriggerAddAction( t, function SELECTEDAction )
        
        set t = null
    endfunction
endlibrary