library_once TimerUtils
//*********************************************************************
//* TimerUtils (Purple flavor for 1.23b or later)
//* ----------
//*
//*  To implement it , create a custom text trigger called TimerUtils
//* and paste the contents of this script there.
//*
//*  To copy from a map to another, copy the trigger holding this
//* library to your map.
//*
//* (requires vJass)   More scripts: http://www.wc3c.net/
//*
//* For your timer needs:
//*  * Attaching
//*  * Recycling (with double-free protection)
//*
//* set t=NewTimer()      : Get a timer (alternative to CreateTimer)
//* ReleaseTimer(t)       : Relese a timer (alt to DestroyTimer)
//* SetTimerData(t,2)     : Attach value 2 to timer
//* GetTimerData(t)       : Get the timer's value.
//*                         You can assume a timer's value is 0
//*                         after NewTimer.
//*
//* Purple Flavor: Slower than the red flavor by a multiplication and a
//*             division, and as such faster than the blue flavor. Has
//*             a theoretical limit of timers, which is HASH_SIZE, but
//*             you should keep your timer count below 3/4 of that to
//*             insure good performance of the NewTimer function.
//*
//* Credits:  * Hash algorithm by Cohadar (used in an early version
//*             of his ABCT timer system)
//*
//*           * TimerUtils "interface" by Vexorian.
//*
//*           * This library by Iron_Doors.
//*
//********************************************************************
 
//================================================================
    globals // These are the hash constants Cohadar used in an early version of ABCT
        private constant integer HASH_SIZE = 4096       // 2^12
        private constant integer HASH_UP   = 2138046464 // 2^(31-(12-1)) * 2039
        private constant integer HASH_DOWN = 1048576    // 2^(31-(12-1))
        private constant integer HASH_BIAS = 2048       // 2^(12-1)
    endglobals
 
    //==================================================================================================
    globals
        private integer array Data[HASH_SIZE]
        private timer array Timer[HASH_SIZE]
    endglobals
    
    function SetTimerData takes timer t, integer value returns nothing
        debug if (Timer[GetHandleId(t) * HASH_UP / HASH_DOWN + HASH_BIAS] != t) then
        debug     call VJDebugMsg("SetTimerData: Wrong handle id, only use SetTimerData on timers created by NewTimer")
        debug endif
        set Data[GetHandleId(t) * HASH_UP / HASH_DOWN + HASH_BIAS] = value
    endfunction
 
    function GetTimerData takes timer t returns integer
        debug if (Timer[GetHandleId(t) * HASH_UP / HASH_DOWN + HASH_BIAS] != t) then
        debug     call VJDebugMsg("GetTimerData: Wrong handle id, only use GetTimerData on timers created by NewTimer")
        debug endif
        return Data[GetHandleId(t) * HASH_UP / HASH_DOWN + HASH_BIAS]
    endfunction
 
    //==========================================================================================
    globals
        private integer array tH
        private integer tN = 0
        private constant integer HELD=0x28829022
        //use a totally random number here, the more improbable someone uses it, the better.
    endglobals
 
    //==========================================================================================
    function NewTimer takes nothing returns timer
     local timer t
        if (tN == 0) then
            loop
                set t = CreateTimer()
                set tH[0] = GetHandleId(t) * HASH_UP / HASH_DOWN + HASH_BIAS
                exitwhen Timer[tH[0]] == null
            endloop
            set Timer[tH[0]] = t
        else
            set tN = tN - 1
        endif
        set Data[tH[tN]] = 0
     return Timer[tH[tN]]
    endfunction
 
    //==========================================================================================
    function ReleaseTimer takes timer t returns nothing
        if (t == null) then
            debug call VJDebugMsg("Warning: attempt to release a null timer")
            return
        endif
        debug if (Timer[GetHandleId(t) * HASH_UP / HASH_DOWN + HASH_BIAS] != t) then
        debug     call VJDebugMsg("ReleaseTimer: Wrong handle id, only use ReleaseTimer on timers created by NewTimer")
        debug endif
        call PauseTimer(t)
        set tH[tN] = GetHandleId(t) * HASH_UP / HASH_DOWN + HASH_BIAS
        if (Data[tH[tN]] == HELD) then
            debug call VJDebugMsg("Warning: ReleaseTimer: Double free!")
            return
        endif
        set Data[tH[tN]] = HELD
        set tN = tN + 1
    endfunction
 
endlibrary