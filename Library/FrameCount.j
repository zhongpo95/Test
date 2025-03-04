library FrameCount requires Party
    globals
        integer FrameNum = 0
    endglobals

    function FrameCount takes nothing returns integer
        set FrameNum = FrameNum + 1
        return FrameNum
    endfunction
endlibrary