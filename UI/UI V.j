library UIV initializer init
    globals
        integer Ogiframe_1 = 0
        integer Ogiframe_2 = 0
        integer Ogiframe_3 = 0
        integer Ogiframe_4 = 0
    endglobals

    private function Action takes nothing returns nothing
        set Ogiframe_1=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", 0)
        call DzFrameSetAbsolutePoint(Ogiframe_1, JN_FRAMEPOINT_BOTTOMLEFT,0.4,0.15)
        set Ogiframe_2=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", 0)
        call DzFrameSetAbsolutePoint(Ogiframe_2, JN_FRAMEPOINT_BOTTOMLEFT,0.4,0.15)
        set Ogiframe_3=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "template", 0)
        call DzFrameSetTexture(Ogiframe_3, "V.blp", 0)
        call DzFrameSetSize(Ogiframe_3, 0.030, 0.030)
        call DzFrameSetAbsolutePoint(Ogiframe_3, JN_FRAMEPOINT_CENTER, 0.4, 0.15)
        call DzFrameShow(Ogiframe_3, false)
        set Ogiframe_4=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", 0)
        call DzFrameSetAbsolutePoint(Ogiframe_4, JN_FRAMEPOINT_BOTTOMLEFT,0.4,0.15)
    endfunction
    
    private function init takes nothing returns nothing
        local trigger t=CreateTrigger()
        call TriggerRegisterTimerEventSingle(t,5.)
        call TriggerAddAction(t,function Action)
        set t = null
    endfunction
endlibrary