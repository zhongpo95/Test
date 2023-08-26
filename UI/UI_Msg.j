library UIMsg initializer init

    private function Action takes nothing returns nothing
        local integer frame=DzFrameGetChatMessage()
        call DzFrameClearAllPoints(frame)
        call DzFrameSetAbsolutePoint(frame,JN_FRAMEPOINT_BOTTOMLEFT,.01,.14)
        call DzFrameSetAbsolutePoint(frame,JN_FRAMEPOINT_TOPRIGHT,.30,.28)
        set frame=DzFrameGetUnitMessage()
        call DzFrameClearAllPoints(frame)
        call DzFrameSetAbsolutePoint(frame,JN_FRAMEPOINT_BOTTOMLEFT,.01,.24)
        call DzFrameSetAbsolutePoint(frame,JN_FRAMEPOINT_TOPRIGHT,.50,.50)
    endfunction
    
    private function init takes nothing returns nothing
        local trigger t=CreateTrigger()
        call TriggerRegisterTimerEventSingle(t,1.)
        call TriggerAddAction(t,function Action)
        set t = null
    endfunction
endlibrary