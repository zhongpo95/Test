library UIInterface initializer init requires FrameCount
    globals
        private integer Skillframe
    endglobals


    private function ESCAction takes nothing returns nothing
        local integer XFV
        set XFV=DzFrameGetMinimap()
        call DzFrameClearAllPoints(XFV)
        call DzFrameSetPoint(XFV,6,DzGetGameUI(),6,.0077,.0079)
        call DzFrameSetPoint(XFV,2,DzGetGameUI(),6,.1124,.1098)
        call DzFrameShow(XFV,true)
    endfunction

    private function Main takes nothing returns nothing
        //set Skillframe = DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "template", FrameCount())
        //call DzFrameSetTexture(Skillframe, "File00005271.blp", 0)
        //call DzFrameSetSize(Skillframe, 1.0, 1.0)
        //call DzFrameSetAbsolutePoint(Skillframe, JN_FRAMEPOINT_CENTER, 0.775, 0.020)
        //call DzFrameShow(F_ItemOpenButton, true)
    endfunction
    
    private function init takes nothing returns nothing
        local trigger t=CreateTrigger()
        //esc버튼
        call TriggerRegisterPlayerEvent(t, Player(0), EVENT_PLAYER_END_CINEMATIC)
        call TriggerRegisterPlayerEvent(t, Player(1), EVENT_PLAYER_END_CINEMATIC)
        call TriggerAddAction( t, function ESCAction )

        set t = CreateTrigger()
        call TriggerAddAction(t,function Main)
        call TriggerRegisterTimerEventSingle(t,0.16)
        set t = null

    endfunction
endlibrary
