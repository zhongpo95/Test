library PauseUnitEx /*
    --------------
    */ requires /*
    --------------
        --------------------
        */ optional Table /*
        --------------------
            Link: "hiveworkshop.com/forums/showthread.php?t=188084"
        --------------------
        |   PauseUnitEx    |
        |    - MyPad       |
        --------------------
            A simple snippet that grants additional functionality
            to PauseUnitEx that mimics PauseUnit
        ---------
        | API   |
        ---------
            function PauseUnitEx(unit whichUnit, boolean flag)
                - Internally calls PauseUnitEx
            function IsUnitPausedEx(unit whichUnit) -> boolean
                - Checks if the unit is paused.
                - This does not return accurate values when
                  PauseUnitEx is called directly.
            function GetUnitPauseExCounter(unit whichUnit) -> integer
                - Returns the pause counter of the unit.
            function SetUnitPauseExCounter(unit whichUnit, integer new)
                - Sets the pause counter of the unit to the
                  new value. Internally calls PauseUnitEx
                  when appropriate.
                - Time Complexity: O(n)
    */
private module PauseM
    static if LIBRARY_Table then
        static Table map        = 0
        private static method onInit takes nothing returns nothing
            set thistype.map    = Table.create()
        endmethod
    else
        static hashtable map    = InitHashtable()
    endif
    static method getPauseCounter takes unit whichUnit returns integer
        local integer counter   = 0
        local integer unitId    = GetHandleId(whichUnit)
        static if LIBRARY_Table then
            set counter     = map[unitId]
        else
            set counter     = LoadInteger(map, 0, unitId)
        endif
        return counter
    endmethod
    static method pauseUnit takes unit whichUnit, boolean flag returns nothing
        local integer counter   = thistype.getPauseCounter(whichUnit)
        local integer unitId    = GetHandleId(whichUnit)
        local integer incr      = IntegerTertiaryOp(flag, 1, -1)
       
        set counter = counter + incr
        static if LIBRARY_Table then
            set map[unitId] = counter
        else
            call SaveInteger(map, 0, unitId, counter)
        endif
        call EXPauseUnit(whichUnit, flag)
    endmethod
    static method isPaused takes unit whichUnit returns boolean
        local integer counter   = thistype.getPauseCounter(whichUnit)
        return counter > 0
    endmethod
    static method setPauseCounter takes unit whichUnit, integer new returns nothing
        local integer counter   = thistype.getPauseCounter(whichUnit)
        local integer sign      = 0
        local integer unitId    = GetHandleId(whichUnit)
        local boolean flag      = false
        if new < counter then
            set sign    = -1
            set flag    = false
        elseif new > counter then
            set sign    = 1
            set flag    = true
        endif
        loop
            exitwhen counter == new
            set counter = counter + sign
            call EXPauseUnit(whichUnit, flag)
        endloop
        static if LIBRARY_Table then
            set map[unitId] = counter
        else
            call SaveInteger(map, 0, unitId, counter)
        endif
    endmethod
endmodule
private struct Pause extends array
    implement PauseM
endstruct
function PauseUnitEx takes unit whichUnit, boolean flag returns nothing
    call Pause.pauseUnit(whichUnit, flag)
endfunction
function SetUnitPauseExCounter takes unit whichUnit, integer new returns nothing
    call Pause.setPauseCounter(whichUnit, new)
endfunction
function IsUnitPausedEx takes unit whichUnit returns boolean
    return Pause.isPaused(whichUnit)
endfunction
function GetUnitPauseExCounter takes unit whichUnit returns integer
    return Pause.getPauseCounter(whichUnit)
endfunction
endlibrary