//! textmacro 이벤트_유닛이_생성되면_발동
private struct ULEvCreate extends array
    private static method Wrapper takes nothing returns nothing
        call thistype.Action(ULEV_WHO)
    endmethod
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function thistype.Wrapper)
        call TriggerRegisterVariableEvent(t,"ULEV_CREAT",GREATER_THAN,0)
        set t = null
    endmethod
    private static method Action takes unit created returns nothing
//! endtextmacro
//! textmacro 이벤트_유닛_타입이_생성되면_발동 takes TYPE
private struct UTLEvCreate$TYPE$ extends array
    private static method Wrapper takes nothing returns nothing
        call thistype.Action(ULEV_WHO)
    endmethod
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function thistype.Wrapper)
        call TriggerRegisterVariableEvent(t,"UTLEV_CREAT",EQUAL,'$TYPE$')
        set t = null
    endmethod
    private static method Action takes unit created returns nothing
//! endtextmacro
//! textmacro 이벤트_유닛이_제거되면_발동
private struct ULEvRemove extends array
    private static method Wrapper takes nothing returns nothing
        call thistype.Action(R2I(ULEV_REMOV))
    endmethod
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function thistype.Wrapper)
        call TriggerRegisterVariableEvent(t,"ULEV_REMOV",GREATER_THAN,0)
        set t = null
    endmethod
    private static method Action takes integer removed returns nothing
//! endtextmacro
//==================================================================================
library vJDKPluginUnitLocateEvent initializer main
globals
unit ULEV_WHO = null
real ULEV_CREAT = 0
real UTLEV_CREAT = 0
real ULEV_REMOV = 0
private key PluginKey
private key TimerKey
endglobals
function TriggerRegisterAnyUnitCreateEvent takes trigger t returns event
    return TriggerRegisterVariableEvent(t,"ULEV_CREAT",GREATER_THAN,0)
endfunction
function TriggerRegisterUnitTypeCreateEvent takes trigger t, integer id returns event
    return TriggerRegisterVariableEvent(t,"UTLEV_CREAT",EQUAL,id)
endfunction
function TriggerRegisterAnyUnitRemoveEvent takes trigger t returns event
    return TriggerRegisterVariableEvent(t,"ULEV_REMOV",GREATER_THAN,0)
endfunction
function TriggerRegisterUnitRemoveEvent takes trigger t, unit u returns event
    return TriggerRegisterVariableEvent(t,"ULEV_REMOV",EQUAL,GetHandleId(u))
endfunction
private function IsUnitRemoved takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer tid = GetHandleId(t)
    local unit u = LoadUnitHandle(VJDK_HANDLE_VAR,TimerKey,tid)
    local integer id
    if GetUnitTypeId(u) != 0 then
        set t = null
        set u = null
        return
    endif
    set id = LoadInteger(VJDK_HANDLE_VAR,PluginKey,tid)
    set ULEV_REMOV = id
    set ULEV_REMOV = 0
    call RemoveSavedBoolean(VJDK_HANDLE_VAR,PluginKey,id)
    call RemoveSavedInteger(VJDK_HANDLE_VAR,PluginKey,tid)
    call RemoveSavedHandle(VJDK_HANDLE_VAR,TimerKey,tid)
    call DestroyTimer(t)
    set t = null
    set u = null
endfunction
private function RegisterU takes unit u returns nothing
    local integer id = GetHandleId(u)
    local timer t = CreateTimer()
    local integer tid = GetHandleId(t)
    call SaveBoolean(VJDK_HANDLE_VAR,PluginKey,id,true)
    call SaveInteger(VJDK_HANDLE_VAR,PluginKey,tid,id)
    call SaveUnitHandle(VJDK_HANDLE_VAR,TimerKey,tid,u)
    call TimerStart(t,GetRandomReal(5.00,6.00),true,function IsUnitRemoved)
    set ULEV_WHO = u
    set ULEV_CREAT = id
    set UTLEV_CREAT = GetUnitTypeId(u)
    set UTLEV_CREAT = 0
    set ULEV_CREAT = 0
    set ULEV_WHO = null
    set t = null
endfunction
private function OnAfterCheck takes nothing returns nothing
    local unit u = GetEnteringUnit()
    local integer id = GetHandleId(u)
    local timer t = CreateTimer()
    local integer tid = GetHandleId(t)
    call SaveBoolean(VJDK_HANDLE_VAR,PluginKey,id,true)
    call SaveInteger(VJDK_HANDLE_VAR,PluginKey,tid,id)
    call SaveUnitHandle(VJDK_HANDLE_VAR,TimerKey,tid,u)
    call TimerStart(t,GetRandomReal(5.00,6.00),true,function IsUnitRemoved)
    set ULEV_WHO = u
    set ULEV_CREAT = id
    set UTLEV_CREAT = GetUnitTypeId(u)
    set UTLEV_CREAT = 0
    set ULEV_CREAT = 0
    set ULEV_WHO = null
    set t = null
    set u = null
endfunction
private function CondAfterCheck takes nothing returns boolean
    return not HaveSavedBoolean(VJDK_HANDLE_VAR,PluginKey,GetHandleId(GetEnteringUnit()))
endfunction
private function FilterPreCheck takes nothing returns boolean
    if HaveSavedBoolean(VJDK_HANDLE_VAR,PluginKey,GetHandleId(GetFilterUnit())) then
       return false 
    endif
    call RegisterU(GetFilterUnit())
    return false
endfunction
private function OnPreCheck takes nothing returns nothing
    local group g = CreateGroup()
    local integer i = 0
    loop
        exitwhen i == bj_MAX_PLAYER_SLOTS
        call GroupEnumUnitsOfPlayer(g,Player(i),Filter(function FilterPreCheck))
        set i = i + 1
    endloop
    call DestroyGroup(g)
    set g = null
endfunction
private function main takes nothing returns nothing
    local trigger t = CreateTrigger()
    call TriggerAddAction(t,function OnAfterCheck)
    call TriggerAddCondition(t,Condition(function CondAfterCheck))
    call TriggerRegisterEnterRectSimple(t,GetWorldBounds())
    set t = CreateTrigger()
    call TriggerAddAction(t,function OnPreCheck)
    call TriggerRegisterTimerEvent(t,0.03125,false)
    set t = null
endfunction
endlibrary