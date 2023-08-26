globals
    hashtable CONTENT_TICK_TABLE = InitHashtable()
endglobals
//! textmacro 틱 takes NAME
private struct $NAME$
    static trigger EVENT = CreateTrigger()
    private static integer MAX = 0
    private timer T
    static method operator Count takes nothing returns integer
        return MAX
    endmethod
    static method GetExpired takes nothing returns thistype
        return LoadInteger( CONTENT_TICK_TABLE, 0, GetHandleId(GetExpiredTimer()) )
    endmethod
    static method Create takes nothing returns thistype
        local thistype this = thistype.allocate(  )
        set MAX = MAX + 1
        set .T = CreateTimer(  )
        call SaveInteger( CONTENT_TICK_TABLE, 0, GetHandleId(T), this )
        return this
    endmethod
    method operator timer takes nothing returns timer
        return .T
    endmethod
    method operator Elapsed takes nothing returns real
        return TimerGetElapsed( .T )
    endmethod
    method operator Remaining takes nothing returns real
        return TimerGetRemaining( .T )
    endmethod
    method operator Timeout takes nothing returns real
        return TimerGetTimeout( .T )
    endmethod
    method Pause takes nothing returns nothing
        call PauseTimer( .T )
    endmethod
    method Resume takes nothing returns nothing
        call ResumeTimer( .T )
    endmethod
    private static method onExpired takes nothing returns nothing
        call TriggerExecute(thistype.EVENT)
    endmethod
    method Start takes real r, boolean flag returns nothing
        call TimerStart( .T, r, flag, function thistype.onExpired )
    endmethod
    method Destroy takes nothing returns nothing
        set MAX = MAX - 1
        call RemoveSavedInteger(CONTENT_TICK_TABLE,0,GetHandleId(.T))
        call DestroyTimer(.T)
        set .T = null
        call .deallocate()
    endmethod
//! endtextmacro
//! textmacro 틱_끝
endstruct
//! endtextmacro
//! textmacro 이벤트_틱이_종료되면_발동 takes NAME
private struct TEvTick$NAME$ extends array
    private static method onInit takes nothing returns nothing
        call TriggerAddAction($NAME$.EVENT,function thistype.Wrapper)
    endmethod
    private static method Wrapper takes nothing returns nothing
        call thistype.Action(LoadInteger(CONTENT_TICK_TABLE,0,GetHandleId(GetExpiredTimer())))
    endmethod
    private static method Action takes $NAME$ expired returns nothing
//! endtextmacro