//! textmacro 트리거_피해 takes SRC,DST,DMG,RNG,ATKT,DMGT,WPNT
set vj_IS_TRIGGER_DAMAGE = true
call UnitDamageTarget($SRC$,$DST$,$DMG$,true,$RNG$,$ATKT$,$DMGT$,$WPNT$)
set vj_IS_TRIGGER_DAMAGE = false
//! endtextmacro
//! textmacro 오브젝트_피해 takes SRC,DST,DMG,RNG,ATKT,DMGT,WPNT
call UnitDamageTarget($SRC$,$DST$,$DMG$,true,$RNG$,$ATKT$,$DMGT$,$WPNT$)
//! endtextmacro
//! textmacro 이벤트_유닛이_데미지_받으면_발동
private struct DSEvAnyUnitDamage extends array
    private static method Wrapper takes nothing returns nothing
        call thistype.Action(DSARG_SOURCE,DSARG_TARGET,DSARG_DAMAGE)
    endmethod
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function thistype.Wrapper)
        call TriggerRegisterVariableEvent(t,"DSEV_DAMAGE",EQUAL,1)
        set t = null
    endmethod
    private static method Action takes unit source, unit target, real damage returns nothing
//! endtextmacro
//! textmacro 이벤트_유닛_타입이_데미지_받으면_발동 takes TYPE
private struct DSEvUnitTypeDamage$TYPE$ extends array
    private static method Wrapper takes nothing returns nothing
        call thistype.Action(DSARG_SOURCE,DSARG_TARGET,DSARG_DAMAGE)
    endmethod
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function thistype.Wrapper)
        call TriggerRegisterVariableEvent(t,"DSTEV_DAMAGE",EQUAL,'$TYPE$')
        set t = null
    endmethod
    private static method Action takes unit source, unit target, real damage returns nothing
//! endtextmacro
//! textmacro 이벤트_유닛_타입이_데미지_가하면_발동 takes TYPE
private struct DSEvUnitTypeAttack$TYPE$ extends array
    private static method Wrapper takes nothing returns nothing
        call thistype.Action(DSARG_SOURCE,DSARG_TARGET,DSARG_DAMAGE)
    endmethod
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function thistype.Wrapper)
        call TriggerRegisterVariableEvent(t,"DSTEV_ATTACK",EQUAL,'$TYPE$')
        set t = null
    endmethod
    private static method Action takes unit source, unit target, real damage returns nothing
//! endtextmacro
//=======================================================================
//! textmacro 시스템_데미지_시스템
library vJDKPluginDamageSystem initializer main
globals
boolean vj_IS_TRIGGER_DAMAGE = false
boolean vj_IS_SHIELD_DAMAGE = false
private key TrigKey
private key TrigActionKey
unit DSARG_SOURCE = null
real DSARG_DAMAGE = 0
unit DSARG_TARGET = null
real DSTEV_ATTACK = 0
real DSTEV_DAMAGE = 0
real DSEV_DAMAGE = 0
endglobals
private function OnUnitRemove takes nothing returns nothing
    local integer id = R2I(ULEV_REMOV)
    local trigger t = LoadTriggerHandle(VJDK_HANDLE_TABLE,TrigKey,id)
    local triggeraction ta = LoadTriggerActionHandle(VJDK_HANDLE_TABLE,TrigActionKey,id)
    call RemoveSavedHandle(VJDK_HANDLE_TABLE,TrigKey,id)
    call RemoveSavedHandle(VJDK_HANDLE_TABLE,TrigActionKey,id)
    call TriggerRemoveAction(t,ta)
    set ta = null
    call DestroyTrigger(t)
    set t = null
endfunction
private function OnUnitDamaged takes nothing returns nothing
    set DSARG_TARGET = GetTriggerUnit()
    set DSARG_SOURCE = GetEventDamageSource()
    set DSARG_DAMAGE = GetEventDamage()
    set DSTEV_ATTACK = GetUnitTypeId(DSARG_SOURCE)
    set DSTEV_DAMAGE = GetUnitTypeId(DSARG_TARGET)
    set DSEV_DAMAGE = 1
    set DSEV_DAMAGE = 0
    set DSTEV_DAMAGE = 0
    set DSTEV_ATTACK = 0
    set DSARG_DAMAGE = 0
    set DSARG_SOURCE = null
    set DSARG_TARGET = null
endfunction
private function CondUnitDamaged takes nothing returns boolean
    return GetEventDamage() != 0
endfunction
private function OnUnitCreate takes nothing returns nothing
    local unit u = ULEV_WHO
    local integer id = R2I(ULEV_CREAT)
    local trigger t = CreateTrigger()
    local triggeraction ta = TriggerAddAction(t,function OnUnitDamaged)
    call TriggerAddCondition(t,Condition(function CondUnitDamaged))
    call SaveTriggerHandle(VJDK_HANDLE_TABLE,TrigKey,id,t)
    call SaveTriggerActionHandle(VJDK_HANDLE_TABLE,TrigActionKey,id,ta)
    call TriggerRegisterUnitEvent(t,u,EVENT_UNIT_DAMAGED)
    set ta = null
    set t = null
    set u = null
endfunction
private function main takes nothing returns nothing
    local trigger t = CreateTrigger()
    call TriggerAddAction(t,function OnUnitCreate)
    call TriggerRegisterVariableEvent(t,"ULEV_CREAT",GREATER_THAN,0)
    set t = CreateTrigger()
    call TriggerAddAction(t,function OnUnitRemove)
    call TriggerRegisterVariableEvent(t,"ULEV_REMOV",GREATER_THAN,0)
    set t = null
endfunction
endlibrary
//! endtextmacro