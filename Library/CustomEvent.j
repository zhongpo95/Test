/**
 *  CustomEvent.j
 *
 *  Copyright (c) escaco95@naver.com
 *  Distributed under the BSD License, Version 210227.0
 *
 *  MonoEvent.Add( event, callback )
 *  MonoEvent.Fire( event, player, unit, item, id ) -> boolean
 *  MonoEvent.Event
 *  MonoEvent.Player
 *  MonoEvent.Unit
 *  MonoEvent.Item
 *  MonoEvent.Integer
 *
 *  DuoEvent.Add( event, subevent, callback )
 *  DuoEvent.Fire( event, subevent, player, unit, item, id ) -> boolean
 *  DuoEvent.Event1
 *  DuoEvent.Event2
 *  DuoEvent.Player
 *  DuoEvent.Unit
 *  DuoEvent.Item
 *  DuoEvent.Integer
 */
 library MonoEvent
    

    globals
        constant key E_AOE 
    endglobals
    
    globals
        private hashtable TABLE_MONO = InitHashtable()
        private hashtable TABLE_DUO = InitHashtable()

        private integer P_E1 = 0
        private integer P_E2 = 0
        private player P_P = null
        private unit P_U = null
        private unit P_T = null
        private integer P_I = 0
    endglobals

    struct MonoEvent extends array
        static method operator Event takes nothing returns integer
            return P_E1
        endmethod
        static method operator Player takes nothing returns player
            return P_P
        endmethod
        static method operator Unit takes nothing returns unit
            return P_U
        endmethod
        static method operator Unit2 takes nothing returns unit
            return P_T
        endmethod
        static method operator Integer takes nothing returns integer
            return P_I
        endmethod
        static method Add takes integer e1, code c returns triggercondition
            if not HaveSavedHandle(TABLE_MONO,e1,0) then
                call SaveTriggerHandle(TABLE_MONO,e1,0,CreateTrigger())
            endif
            return TriggerAddCondition(LoadTriggerHandle(TABLE_MONO,e1,0),Condition(c))
        endmethod
        static method Fire takes integer e, player p, unit u, unit t, integer i returns boolean
            local integer pe1 = P_E1
            local integer pe2 = P_E2
            local player pp = P_P
            local unit pu = P_U
            local unit pt = P_T
            local integer pi = P_I
            local boolean result
            set P_E1 = e
            set P_E2 = 0
            set P_P = p
            set P_U = u
            set P_T = t
            set P_I = i
            set result = TriggerEvaluate(LoadTriggerHandle(TABLE_MONO,e,0))
            set P_E1 = pe1
            set P_E2 = pe2
            set P_P = pp
            set P_U = pu
            set P_T = pt
            set P_I = pi
            set pp = null
            set pu = null
            set pt = null
            return result
        endmethod
    endstruct

    struct DuoEvent extends array
        static method operator Event1 takes nothing returns integer
            return P_E1
        endmethod
        static method operator Event2 takes nothing returns integer
            return P_E2
        endmethod
        static method operator Player takes nothing returns player
            return P_P
        endmethod
        static method operator Unit takes nothing returns unit
            return P_U
        endmethod
        static method operator Unit2 takes nothing returns unit
            return P_T
        endmethod
        static method operator Integer takes nothing returns integer
            return P_I
        endmethod
        static method Add takes integer e1, integer e2, code c returns triggercondition 
            if not HaveSavedHandle(TABLE_DUO,e1,e2) then
                call SaveTriggerHandle(TABLE_DUO,e1,e2,CreateTrigger())
            endif
            return TriggerAddCondition(LoadTriggerHandle(TABLE_DUO,e1,e2),Condition(c))
        endmethod
        static method Fire takes integer e1, integer e2, player p, unit u, unit t, integer i returns boolean
            local integer pe1 = P_E1
            local integer pe2 = P_E2
            local player pp = P_P
            local unit pu = P_U
            local unit pt = P_T
            local integer pi = P_I
            local boolean result
            set P_E1 = e1
            set P_E2 = e2
            set P_P = p
            set P_U = u
            set P_T = t
            set P_I = i
            set result = TriggerEvaluate(LoadTriggerHandle(TABLE_MONO,e1,0))
            set result = TriggerEvaluate(LoadTriggerHandle(TABLE_DUO,e1,e2))
            set P_E1 = pe1
            set P_E2 = pe2
            set P_P = pp
            set P_U = pu
            set P_T = pt
            set P_I = pi
            set pp = null
            set pu = null
            set pt = null
            return result
        endmethod
    endstruct

endlibrary