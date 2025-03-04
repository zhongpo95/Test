library InterfaceOff initializer init requires FrameCount
    private function init takes nothing returns nothing
        call DzFrameHideInterface()
        call DzFrameEditBlackBorders(0,0)
    endfunction
endlibrary
