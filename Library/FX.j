
/**

 * FX Library

 *

 * Copyright (c) 2020 escaco95@naver.com

 * Distributed under the BSD License, Version 200812.0

 *

 *

 *

 */

 library FX

    globals
    
        constant boolean FX_DEBUG_NOTE_ONCREATE = true
    
        constant boolean FX_DEBUG_NOTE_ONSTART = true
    
        constant boolean FX_DEBUG_NOTE_ONSTOP = true
    
        
    
        constant boolean FX_DEBUG_NOTE_ONSUBCREATE = true
    
        constant boolean FX_DEBUG_NOTE_ONSUBSTART = true
    
        constant boolean FX_DEBUG_NOTE_ONSUBSTOP = true
    
        constant hashtable FX_TABLE = InitHashtable()
    
        
    
        integer fx_triggerFX = 0
    
        key FX_KEY_EVENT_CREATE
    
        key FX_KEY_EVENT_START
    
        key FX_KEY_EVENT_STOP
    
        
    
        key FX_KEY_HANDLE
    
    endglobals
    
        function FXGetTriggerFX takes nothing returns integer
    
            return fx_triggerFX
    
        endfunction
    
        
    
        function FXGetTimerFX takes nothing returns integer
    
            return LoadInteger(FX_TABLE,FX_KEY_HANDLE,GetHandleId(GetExpiredTimer()))
    
        endfunction
    
        function FXFireEvent takes integer id, integer k, integer fx returns boolean
    
            local boolean r
    
            local integer pst = fx_triggerFX
    
            set fx_triggerFX = fx
    
            set r = TriggerEvaluate(LoadTriggerHandle(FX_TABLE,id,k))
    
            set fx_triggerFX = pst
    
            return r
    
        endfunction
    
        
    
        function FXRegisterEvent takes integer id, integer k, code c returns nothing
    
            local trigger t = LoadTriggerHandle(FX_TABLE,id,k)
    
            if t == null then
    
                set t = CreateTrigger()
    
                call SaveTriggerHandle(FX_TABLE,id,k,t)
    
            endif
    
            call TriggerAddCondition(t,Condition(c))
    
        endfunction
    
    endlibrary
    
    //! textmacro 연출
    
        static key KEY
    
        private boolean m_Started
    
        private boolean m_Disposing
    
        static method create takes nothing returns thistype
    
            debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[경고] thistype.create는 사용할 수 없습니다. 대신 thistype.Create()를 사용하세요.")
    
            return 0
    
        endmethod
    
        method destroy takes nothing returns nothing
    
            debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[경고] thistype.destroy는 사용할 수 없습니다. 대신 thistype.Stop()을 사용하세요.")
    
        endmethod
    
        static method Create takes nothing returns thistype
    
            local thistype this = allocate()
    
            debug if FX_DEBUG_NOTE_ONCREATE then
    
            debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[알림] thistype::"+I2S(this)+" 연출 개체 초기화")
    
            debug endif
    
            set m_Started = false
    
            set m_Disposing = false
    
            static if thistype.OnCreate.exists then
    
                call this.OnCreate()
    
            endif
    
            call FXFireEvent(FX_KEY_EVENT_CREATE,KEY,this)
    
            return this
    
        endmethod
    
        method Stop takes nothing returns nothing
    
            if m_Disposing then
    
                debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[경고] 이미 Stop()된 thistype 연출을 중복으로 중지 시도했습니다!")
    
                return
    
            endif
    
            debug if FX_DEBUG_NOTE_ONSTOP then
    
            debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[알림] thistype::"+I2S(this)+" 연출 개체 중지")
    
            debug endif
    
            set m_Disposing = true
    
            static if thistype.OnStop.exists then
    
                call this.OnStop()
    
            endif
    
            call FXFireEvent(FX_KEY_EVENT_STOP,KEY,this)
    
            call deallocate()
    
        endmethod
    
        method Start takes nothing returns nothing
    
            if m_Started then
    
                debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[경고] 이미 Start()된 thistype 연출을 중복으로 시작 시도했습니다!")
    
                return
    
            endif
    
            debug if FX_DEBUG_NOTE_ONSTART then
    
            debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[알림] thistype::"+I2S(this)+" 연출 개체 작동")
    
            debug endif
    
            set m_Started = true
    
            static if thistype.OnStart.exists then
    
                call this.OnStart()
    
            endif
    
            call FXFireEvent(FX_KEY_EVENT_START,KEY,this)
    
        endmethod
    
    //! endtextmacro
    
    //! textmacro 연출효과_타이머 takes FX, TIMEOUT, LOOP
    
        private static method OnTimerExpire takes nothing returns nothing
    
            local thistype this = LoadInteger(FX_TABLE,FX_KEY_HANDLE,GetHandleId(GetExpiredTimer()))
    
            static if thistype.OnAction.exists then
    
                call this.OnAction(this)
    
            endif
    
        endmethod
    
        private timer Timer
    
        private integer TimerHandle
    
        private static method OnCreate takes nothing returns nothing
    
            local thistype this = fx_triggerFX
    
            local $FX$ fx = this
    
            set Timer = CreateTimer()
    
            set TimerHandle = GetHandleId(Timer)
    
            call SaveInteger(FX_TABLE,FX_KEY_HANDLE,TimerHandle,this)
    
            debug if FX_DEBUG_NOTE_ONSUBCREATE then
    
            debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[알림] 모듈 thistype 초기화")
    
            debug endif
    
        endmethod
    
        private static method OnStart takes nothing returns nothing
    
            local thistype this = fx_triggerFX
    
            local $FX$ fx = this
    
            call TimerStart(Timer,$TIMEOUT$,$LOOP$,function thistype.OnTimerExpire)
    
            debug if FX_DEBUG_NOTE_ONSUBSTART then
    
            debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[알림] 모듈 thistype 작동")
    
            debug endif
    
        endmethod
    
        private static method OnStop takes nothing returns nothing
    
            local thistype this = fx_triggerFX
    
            local $FX$ fx = this
    
            call RemoveSavedInteger(FX_TABLE,FX_KEY_HANDLE,TimerHandle)
    
            call DestroyTimer(Timer)
    
            set Timer = null
    
            debug if FX_DEBUG_NOTE_ONSUBSTOP then
    
            debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[알림] 모듈 thistype 중지")
    
            debug endif
    
        endmethod
    
        private static method onInit takes nothing returns nothing
    
            call FXRegisterEvent(FX_KEY_EVENT_CREATE,$FX$.KEY,function thistype.OnCreate)
    
            call FXRegisterEvent(FX_KEY_EVENT_START,$FX$.KEY,function thistype.OnStart)
    
            call FXRegisterEvent(FX_KEY_EVENT_STOP,$FX$.KEY,function thistype.OnStop)
    
        endmethod
    
    //! endtextmacro
    
    //! textmacro 연출효과_직선거리이동 takes FX, UNIT, TIMEOUT, DIST, ANGLE, SPEED
    
        real DurationPassed
    
        real X
    
        real Y
    
        private static method OnTimerExpire takes nothing returns nothing
    
            local thistype this = LoadInteger(FX_TABLE,FX_KEY_HANDLE,GetHandleId(GetExpiredTimer()))
    
            local $FX$ fx = this
    
            
    
            local real speed
    
            local real dx
    
            local real dy
    
            local real dd
    
            local boolean proceed = true
    
            local boolean dashUnfinished
    
            
    
            static if thistype.OnBeforeAction.exists then
    
                call this.OnBeforeAction(this)
    
            endif
    
            
    
            set speed = $SPEED$ * $TIMEOUT$
    
            set dd = $DIST$ - DurationPassed
    
            set dashUnfinished = dd > speed
    
            
    
            if dashUnfinished then
    
                set dx = speed * Cos($ANGLE$*bj_DEGTORAD) 
    
                set dy = speed * Sin($ANGLE$*bj_DEGTORAD)
    
            else
    
                set dx = dd * Cos($ANGLE$*bj_DEGTORAD) 
    
                set dy = dd * Sin($ANGLE$*bj_DEGTORAD)
    
            endif
    
            
    
            set X = GetWidgetX($UNIT$)+dx
    
            set Y = GetWidgetY($UNIT$)+dy
    
            
    
            static if thistype.OnBeforeMove.exists then
    
                set proceed = this.OnBeforeMove(this,X,Y)
    
            endif
    
            
    
            if proceed then
    
                call SetUnitX($UNIT$,X)
    
                call SetUnitY($UNIT$,Y)
    
                
    
                set DurationPassed = DurationPassed + speed
    
                if dashUnfinished then
    
                    return
    
                endif
    
            endif
    
            
    
            static if thistype.OnAction.exists then
    
                call this.OnAction(this)
    
            endif
    
        endmethod
    
        private timer Timer
    
        private integer TimerHandle
    
        private static method OnCreate takes nothing returns nothing
    
            local thistype this = fx_triggerFX
    
            local $FX$ fx = this
    
            set Timer = CreateTimer()
    
            set TimerHandle = GetHandleId(Timer)
    
            call SaveInteger(FX_TABLE,FX_KEY_HANDLE,TimerHandle,this)
    
            set DurationPassed = 0.0
    
            debug if FX_DEBUG_NOTE_ONSUBCREATE then
    
            debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[알림] 모듈 thistype 초기화")
    
            debug endif
    
        endmethod
    
        private static method OnStart takes nothing returns nothing
    
            local thistype this = fx_triggerFX
    
            local $FX$ fx = this
    
            call TimerStart(Timer,$TIMEOUT$,true,function thistype.OnTimerExpire)
    
            debug if FX_DEBUG_NOTE_ONSUBSTART then
    
            debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[알림] 모듈 thistype 작동")
    
            debug endif
    
        endmethod
    
        private static method OnStop takes nothing returns nothing
    
            local thistype this = fx_triggerFX
    
            local $FX$ fx = this
    
            call RemoveSavedInteger(FX_TABLE,FX_KEY_HANDLE,TimerHandle)
    
            call DestroyTimer(Timer)
    
            set Timer = null
    
            debug if FX_DEBUG_NOTE_ONSUBSTOP then
    
            debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[알림] 모듈 thistype 중지")
    
            debug endif
    
        endmethod
    
        private static method onInit takes nothing returns nothing
    
            call FXRegisterEvent(FX_KEY_EVENT_CREATE,$FX$.KEY,function thistype.OnCreate)
    
            call FXRegisterEvent(FX_KEY_EVENT_START,$FX$.KEY,function thistype.OnStart)
    
            call FXRegisterEvent(FX_KEY_EVENT_STOP,$FX$.KEY,function thistype.OnStop)
    
        endmethod
    
    //! endtextmacro
    
    //! textmacro 연출효과_직선시간이동 takes FX, UNIT, TIMEOUT, DURATION, ANGLE, SPEED
    
        real DurationPassed
    
        real X
    
        real Y
    
        private static method OnTimerExpire takes nothing returns nothing
    
            local thistype this = LoadInteger(FX_TABLE,FX_KEY_HANDLE,GetHandleId(GetExpiredTimer()))
    
            local $FX$ fx = this
    
            
    
            local real speed
    
            local real dx
    
            local real dy
    
            local boolean proceed = true
    
            static if thistype.OnBeforeAction.exists then
    
                call this.OnBeforeAction(this)
    
            endif
    
            set speed = $SPEED$ * $TIMEOUT$
    
            set dx = speed * Cos($ANGLE$*bj_DEGTORAD)
    
            set dy = speed * Sin($ANGLE$*bj_DEGTORAD)
    
            
    
            set X = GetWidgetX($UNIT$)+dx
    
            set Y = GetWidgetY($UNIT$)+dy
    
            
    
            static if thistype.OnBeforeMove.exists then
    
                set proceed = this.OnBeforeMove(this,X,Y)
    
            endif
    
            
    
            if proceed then
    
                call SetUnitX($UNIT$,X)
    
                call SetUnitY($UNIT$,Y)
    
                
    
                set DurationPassed = DurationPassed + $TIMEOUT$
    
                if DurationPassed < $DURATION$ then
    
                    return
    
                endif
    
            endif
    
            
    
            static if thistype.OnAction.exists then
    
                call this.OnAction(this)
    
            endif
    
        endmethod
    
        private timer Timer
    
        private integer TimerHandle
    
        private static method OnCreate takes nothing returns nothing
    
            local thistype this = fx_triggerFX
    
            local $FX$ fx = this
    
            set Timer = CreateTimer()
    
            set TimerHandle = GetHandleId(Timer)
    
            call SaveInteger(FX_TABLE,FX_KEY_HANDLE,TimerHandle,this)
    
            set DurationPassed = 0.0
    
            debug if FX_DEBUG_NOTE_ONSUBCREATE then
    
            debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[알림] 모듈 thistype 초기화")
    
            debug endif
    
        endmethod
    
        private static method OnStart takes nothing returns nothing
    
            local thistype this = fx_triggerFX
    
            local $FX$ fx = this
    
            call TimerStart(Timer,$TIMEOUT$,true,function thistype.OnTimerExpire)
    
            debug if FX_DEBUG_NOTE_ONSUBSTART then
    
            debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[알림] 모듈 thistype 작동")
    
            debug endif
    
        endmethod
    
        private static method OnStop takes nothing returns nothing
    
            local thistype this = fx_triggerFX
    
            local $FX$ fx = this
    
            call RemoveSavedInteger(FX_TABLE,FX_KEY_HANDLE,TimerHandle)
    
            call DestroyTimer(Timer)
    
            set Timer = null
    
            debug if FX_DEBUG_NOTE_ONSUBSTOP then
    
            debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[알림] 모듈 thistype 중지")
    
            debug endif
    
        endmethod
    
        private static method onInit takes nothing returns nothing
    
            call FXRegisterEvent(FX_KEY_EVENT_CREATE,$FX$.KEY,function thistype.OnCreate)
    
            call FXRegisterEvent(FX_KEY_EVENT_START,$FX$.KEY,function thistype.OnStart)
    
            call FXRegisterEvent(FX_KEY_EVENT_STOP,$FX$.KEY,function thistype.OnStop)
    
        endmethod
    
    //! endtextmacro
    
    //! textmacro 연출효과_유닛이벤트 takes FX, UNIT, EVENT
    
        private static method OnTriggerExecute takes nothing returns nothing
    
            local thistype this = LoadInteger(FX_TABLE,FX_KEY_HANDLE,GetHandleId(GetTriggeringTrigger()))
    
            static if thistype.OnAction.exists then
    
                call this.OnAction(this)
    
            endif
    
        endmethod
    
        private trigger Trigger
    
        private integer TriggerHandle
    
        private triggeraction TriggerAction
    
        private static method OnCreate takes nothing returns nothing
    
            local thistype this = fx_triggerFX
    
            local $FX$ fx = this
    
            set Trigger = CreateTrigger()
    
            set TriggerHandle = GetHandleId(Trigger)
    
            set TriggerAction = null
    
            call SaveInteger(FX_TABLE,FX_KEY_HANDLE,TriggerHandle,this)
    
            debug if FX_DEBUG_NOTE_ONSUBCREATE then
    
            debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[알림] 모듈 thistype 초기화")
    
            debug endif
    
        endmethod
    
        private static method OnStart takes nothing returns nothing
    
            local thistype this = fx_triggerFX
    
            local $FX$ fx = this
    
            set TriggerAction = TriggerAddAction(Trigger,function thistype.OnTriggerExecute)
    
            call TriggerRegisterUnitEvent(Trigger,$UNIT$,$EVENT$)
    
            debug if FX_DEBUG_NOTE_ONSUBSTART then
    
            debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[알림] 모듈 thistype 작동")
    
            debug endif
    
        endmethod
    
        private static method OnStop takes nothing returns nothing
    
            local thistype this = fx_triggerFX
    
            local $FX$ fx = this
    
            call TriggerRemoveAction(Trigger,TriggerAction)
    
            set TriggerAction = null
    
            call RemoveSavedInteger(FX_TABLE,FX_KEY_HANDLE,TriggerHandle)
    
            call DestroyTrigger(Trigger)
    
            set Trigger = null
    
            debug if FX_DEBUG_NOTE_ONSUBSTOP then
    
            debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[알림] 모듈 thistype 중지")
    
            debug endif
    
        endmethod
    
        private static method onInit takes nothing returns nothing
    
            call FXRegisterEvent(FX_KEY_EVENT_CREATE,$FX$.KEY,function thistype.OnCreate)
    
            call FXRegisterEvent(FX_KEY_EVENT_START,$FX$.KEY,function thistype.OnStart)
    
            call FXRegisterEvent(FX_KEY_EVENT_STOP,$FX$.KEY,function thistype.OnStop)
    
        endmethod
    
    //! endtextmacro
    
    //! textmacro 연출효과_유닛범위 takes FX, UNIT, RANGE
    
        private static method OnTriggerExecute takes nothing returns nothing
    
            local thistype this = LoadInteger(FX_TABLE,FX_KEY_HANDLE,GetHandleId(GetTriggeringTrigger()))
    
            static if thistype.OnAction.exists then
    
                call this.OnAction(this)
    
            endif
    
        endmethod
    
        private trigger Trigger
    
        private integer TriggerHandle
    
        private triggeraction TriggerAction
    
        private static method OnCreate takes nothing returns nothing
    
            local thistype this = fx_triggerFX
    
            local $FX$ fx = this
    
            set Trigger = CreateTrigger()
    
            set TriggerHandle = GetHandleId(Trigger)
    
            set TriggerAction = null
    
            call SaveInteger(FX_TABLE,FX_KEY_HANDLE,TriggerHandle,this)
    
            debug if FX_DEBUG_NOTE_ONSUBCREATE then
    
            debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[알림] 모듈 thistype 초기화")
    
            debug endif
    
        endmethod
    
        private static method OnStart takes nothing returns nothing
    
            local thistype this = fx_triggerFX
    
            local $FX$ fx = this
    
            set TriggerAction = TriggerAddAction(Trigger,function thistype.OnTriggerExecute)
    
            call TriggerRegisterUnitInRange(Trigger,$UNIT$,$RANGE$,null)
    
            debug if FX_DEBUG_NOTE_ONSUBSTART then
    
            debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[알림] 모듈 thistype 작동")
    
            debug endif
    
        endmethod
    
        private static method OnStop takes nothing returns nothing
    
            local thistype this = fx_triggerFX
    
            local $FX$ fx = this
    
            call TriggerRemoveAction(Trigger,TriggerAction)
    
            set TriggerAction = null
    
            call RemoveSavedInteger(FX_TABLE,FX_KEY_HANDLE,TriggerHandle)
    
            call DestroyTrigger(Trigger)
    
            set Trigger = null
    
            debug if FX_DEBUG_NOTE_ONSUBSTOP then
    
            debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[알림] 모듈 thistype 중지")
    
            debug endif
    
        endmethod
    
        private static method onInit takes nothing returns nothing
    
            call FXRegisterEvent(FX_KEY_EVENT_CREATE,$FX$.KEY,function thistype.OnCreate)
    
            call FXRegisterEvent(FX_KEY_EVENT_START,$FX$.KEY,function thistype.OnStart)
    
            call FXRegisterEvent(FX_KEY_EVENT_STOP,$FX$.KEY,function thistype.OnStop)
    
        endmethod
    
    //! endtextmacro