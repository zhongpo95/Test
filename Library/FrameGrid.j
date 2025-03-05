//! import "DzAPIFrameHandle.j"

library DisplayGrid initializer Init
    globals
        private constant integer GRID_ALPHA = 255
        
        private integer GridLine
        private integer GridLine_Small
        private integer GridLine_Medium
        private integer GridLine_Large
    endglobals
    
    function GetShowGridLine takes integer size returns nothing
        if size == 0 then
            call DzFrameShow(GridLine_Small, false)
            call DzFrameShow(GridLine_Medium, false)
            call DzFrameShow(GridLine_Large, false)
        elseif size == 1 then
            call DzFrameShow(GridLine_Small, false)
            call DzFrameShow(GridLine_Medium, false)
            call DzFrameShow(GridLine_Large, true)
        elseif size == 2 then
            call DzFrameShow(GridLine_Small, false)
            call DzFrameShow(GridLine_Medium, true)
            call DzFrameShow(GridLine_Large, true)
        elseif size == 3 then
            call DzFrameShow(GridLine_Small, true)
            call DzFrameShow(GridLine_Medium, true)
            call DzFrameShow(GridLine_Large, true)
        endif
    endfunction
    
    private function Main takes nothing returns nothing
        local integer targetFrame
        local integer frame
        local integer x = 1
        local integer y = 1
        local string texture
        
        call DestroyTrigger( GetTriggeringTrigger() )
        set GridLine = DzCreateFrameByTagName("FRAME", "", DzGetGameUI(), "", 0)
        set GridLine_Small = DzCreateFrameByTagName("FRAME", "", GridLine, "", 0)
        set GridLine_Medium = DzCreateFrameByTagName("FRAME", "", GridLine, "", 0)
        set GridLine_Large = DzCreateFrameByTagName("FRAME", "", GridLine, "", 0)
        call DzFrameShow(GridLine_Small, false)
        call DzFrameShow(GridLine_Medium, false)
        call DzFrameShow(GridLine_Large, false)
        
        //알파 값
        call DzFrameSetAlpha(GridLine, GRID_ALPHA)
        
        //x축 격자 생성
        loop
            exitwhen x > 79
            if ModuloInteger(x, 10) == 0 then
                set targetFrame = GridLine_Large
                set texture = "ReplaceableTextures\\TeamColor\\TeamColor04.blp"
            elseif ModuloInteger(x, 5) == 0 then
                set targetFrame = GridLine_Medium
                set texture = "Textures\\white.blp"
            else
                set targetFrame = GridLine_Small
                set texture = "ReplaceableTextures\\TeamColor\\TeamColor08.blp"
            endif
            set frame = DzCreateFrameByTagName("BACKDROP", "", targetFrame, "", 0)
            call DzFrameSetTexture(frame, texture, 0)
            call DzFrameSetAbsolutePoint(frame, JN_FRAMEPOINT_CENTER, x*0.01, 0.30)
            call DzFrameSetSize(frame, 0.0001, 0.6)
            set x = x + 1
        endloop
        //x축 격자 수치 표기
        set x = 1
        loop
            exitwhen x > 8
            set frame = DzCreateFrameByTagName("TEXT", "", GridLine_Large, "", 0)
            call DzFrameSetText(frame, "0." + I2S(x))
            call DzFrameSetAbsolutePoint(frame, JN_FRAMEPOINT_BOTTOMRIGHT, x*0.1, 0.0)
            set x = x + 1
        endloop
        
        //y축 격자 생성
        loop
            exitwhen y > 59
            if ModuloInteger(y, 10) == 0 then
                set targetFrame = GridLine_Large
                set texture = "ReplaceableTextures\\TeamColor\\TeamColor04.blp"
            elseif ModuloInteger(y, 5) == 0 then
                set targetFrame = GridLine_Medium
                set texture = "Textures\\white.blp"
            else
                set targetFrame = GridLine_Small
                set texture = "ReplaceableTextures\\TeamColor\\TeamColor08.blp"
            endif
            set frame = DzCreateFrameByTagName("BACKDROP", "", targetFrame, "", 0)
            call DzFrameSetTexture(frame, texture, 0)
            call DzFrameSetAbsolutePoint(frame, JN_FRAMEPOINT_CENTER, 0.40, y*0.01)
            call DzFrameSetSize(frame, 0.8, 0.0001)
            set y = y + 1
        endloop
        
        //y축 격자 수치 표기
        set y = 0
        loop
            exitwhen y > 8
            set frame = DzCreateFrameByTagName("TEXT", "", GridLine_Large, "", 0)
            call DzFrameSetText(frame, "0." + I2S(y))
            call DzFrameSetAbsolutePoint(frame, JN_FRAMEPOINT_TOPLEFT, 0.0, y*0.1)
            set y = y + 1
        endloop
        
        //(0.0) 격자 수치 표기
        set frame = DzCreateFrameByTagName("TEXT", "", GridLine_Large, "", 0)
        call DzFrameSetText(frame, "0.0")
        call DzFrameSetAbsolutePoint(frame, JN_FRAMEPOINT_BOTTOMLEFT, 0.0, 0.0)
    endfunction
    
    private function Command takes nothing returns nothing
        local string chat = StringCase(GetEventPlayerChatString(), false)
        if chat == "-g0" then
            call GetShowGridLine(0)
        elseif chat == "-g1" then
            call GetShowGridLine(1)
        elseif chat == "-g2" then
            call GetShowGridLine(2)
        elseif chat == "-g3" then
            call GetShowGridLine(3)
        endif
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger(  )
        local integer i = 0
        call TriggerRegisterTimerEvent(t, 0.00, false)
        call TriggerAddAction( t, function Main )
        
        set t = CreateTrigger(  )
        loop
            exitwhen i > 11
            call TriggerRegisterPlayerChatEvent( t, Player(i), "-g", false )
            set i = i + 1
        endloop
        call TriggerAddAction( t, function Command )
        
        set t = null
    endfunction
endlibrary