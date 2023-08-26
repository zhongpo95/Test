//! textmacro 이벤트_유닛이_사망하면_발동
private struct UTEvDeath extends array
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddCondition(t, Condition(function thistype.Wrapper))
        call TriggerRegisterVariableEvent(t,"UTE_DEATH",GREATER_THAN,0)
        set t = null
    endmethod
    private static method Wrapper takes nothing returns boolean
        call thistype.Action(UTE_KILLED,UTE_KILLER)
        return false
    endmethod
    private static method Action takes unit killed, unit killer returns nothing
//! endtextmacro
//! textmacro 이벤트_유닛이_처치하면_발동
private struct UTEvKill extends array
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddCondition(t, Condition(function thistype.Wrapper))
        call TriggerRegisterVariableEvent(t,"UTE_KILL",GREATER_THAN,0)
        set t = null
    endmethod
    private static method Wrapper takes nothing returns boolean
        call thistype.Action(UTE_KILLED,UTE_KILLER)
        return false
    endmethod
    private static method Action takes unit killed, unit killer returns nothing
//! endtextmacro
//! textmacro 이벤트_유닛이_선택되면_발동
private struct AUTEvSelect extends array
    private static method Wrapper takes nothing returns boolean
        call thistype.Action(UTE_SELECTOR,UTE_SELECTED)
        return false
    endmethod
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddCondition(t, Condition(function thistype.Wrapper))
        call TriggerRegisterVariableEvent(t,"UTE_SELECTF",GREATER_THAN,0)
        set t = null
    endmethod
    private static method Action takes player selector, unit selected returns nothing
//! endtextmacro
//=============================================================
library vJDKPluginUnitTypeEvent
    globals
        real UTE_DEATH = 0
        real UTE_KILL = 0
        unit UTE_KILLER = null
        unit UTE_KILLED = null
    endglobals
    //! runtextmacro vJDK_UnitTypeEvent("KillDeath","EVENT_PLAYER_UNIT_DEATH")
        set UTE_KILLED = GetDyingUnit()
        set UTE_KILLER = GetKillingUnit()
        if UTE_KILLER != null then
            set UTE_KILL = GetUnitTypeId(UTE_KILLER)
        endif
        set UTE_DEATH = GetUnitTypeId(UTE_KILLED)
        set UTE_DEATH = 0
        set UTE_KILL = 0
        set UTE_KILLER = null
        set UTE_KILLED = null
    //! runtextmacro vJDK_UnitTypeEventEnd()
    globals
        real UTE_SELECTF = 0
        player UTE_SELECTOR = null
        unit UTE_SELECTED = null
    endglobals
    //! runtextmacro vJDK_UnitTypeEvent("Select","EVENT_PLAYER_UNIT_SELECTED")
        set UTE_SELECTOR = GetTriggerPlayer()
        set UTE_SELECTED = GetTriggerUnit()
        set UTE_SELECTF = GetUnitTypeId(UTE_SELECTED)
        set UTE_SELECTF = 0
        set UTE_SELECTED = null
        set UTE_SELECTOR = null
    //! runtextmacro vJDK_UnitTypeEventEnd()
endlibrary
//=============================================================
//! textmacro vJDK_UnitTypeEvent takes NAME,EVENT
private struct UTE$NAME$ extends array
    private static playerunitevent event = $EVENT$
    private static method Action takes nothing returns nothing
//! endtextmacro
//! textmacro vJDK_UnitTypeEventEnd
    endmethod
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function thistype.Action)
        call TriggerRegisterAnyUnitEventBJ(t,event)
        set t = null
    endmethod
endstruct
//! endtextmacro
