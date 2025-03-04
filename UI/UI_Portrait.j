library UIPortrait initializer init

    private function Action takes nothing returns nothing
        //local integer frame=DzFrameGetPortrait()
        //call DzFrameClearAllPoints(frame)
        //call DzFrameSetPoint(frame,JN_FRAMEPOINT_BOTTOMLEFT,DzGetGameUI(),JN_FRAMEPOINT_BOTTOMLEFT,.0, .0)
        //call DzFrameSetPoint(frame,JN_FRAMEPOINT_TOPRIGHT,DzGetGameUI(),JN_FRAMEPOINT_BOTTOMLEFT,.1047, .1019)
        
    endfunction
    
    private function init takes nothing returns nothing
        local trigger t=CreateTrigger()
        call TriggerRegisterTimerEventSingle(t,1.)
        call TriggerAddAction(t,function Action)
        set t = null
    endfunction
endlibrary