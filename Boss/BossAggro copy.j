library BossAggroSystem
    globals
        private integer AggroUpdateTimer = null
        private integer MaxAggroTime = 10
        private integer AggroCheckInterval = 1
        private integer AggroDataCount = 0
        private constant integer MaxAggroData = 12
        
        private integer AggroData AggroList[MaxAggroData]
    endglobals

    private struct AggroData
        unit aggroTarget
        real damageTaken
    endstruct
    
    private function InitializeAggroList takes nothing returns nothing
        local integer i = 0
        loop
            exitwhen i >= MaxAggroData
            set AggroList[i] = AggroData.create()
            set AggroList[i].aggroTarget = null
            set AggroList[i].damageTaken = 0
            set i = i + 1
        endloop
    endfunction
    
    private function AggroUpdate takes nothing returns nothing
        local integer i = 0
        local real maxDamage = 0.0
        local unit newAggroTarget = null
        
        loop
            exitwhen i >= AggroDataCount
            if AggroList[i].damageTaken > maxDamage then
                set maxDamage = AggroList[i].damageTaken
                set newAggroTarget = AggroList[i].aggroTarget
            endif
            set i = i + 1
        endloop
        
        // Set new aggro target if found
        if newAggroTarget != null then
            call BJDebugMsg(GetUnitName(newAggroTarget))
        endif
    endfunction
    
    private function AggroCheck takes nothing returns nothing
        local unit damagedUnit = GetTriggerUnit()
        local unit damagingUnit = GetEventDamageSource()
        local integer i = 0
        local boolean found = false
        
        loop
            exitwhen i >= AggroDataCount
            if AggroList[i].aggroTarget == damagedUnit then
                set AggroList[i].damageTaken = AggroList[i].damageTaken + GetEventDamage()
                set found = true
                exitwhen true
            endif
            set i = i + 1
        endloop
        
        if not found and AggroDataCount < MaxAggroData then
            set AggroList[AggroDataCount].aggroTarget = damagedUnit
            set AggroList[AggroDataCount].damageTaken = GetEventDamage()
            set AggroDataCount = AggroDataCount + 1
        endif
    endfunction
    
    private function AggroRemove takes unit u returns nothing
        local integer i = 0
        loop
            exitwhen i >= AggroDataCount
            if AggroList[i].aggroTarget == u then
                // Move last element to fill the gap
                set AggroList[i] = AggroList[AggroDataCount - 1]
                set AggroList[AggroDataCount - 1] = AggroData.create()
                set AggroList[AggroDataCount - 1].aggroTarget = null
                set AggroList[AggroDataCount - 1].damageTaken = 0
                set AggroDataCount = AggroDataCount - 1
                exitwhen true
            endif
            set i = i + 1
        endloop
    endfunction
    
    private function Trig_AggroCheck_Conditions takes nothing returns boolean
        return GetUnitAbilityLevel(GetTriggerUnit(), 'A00O') > 0
    endfunction
    
    private function Trig_AggroCheck_Actions takes nothing returns nothing
        local unit damagedUnit = GetTriggerUnit()
        local unit damagingUnit = GetEventDamageSource()
        
        // Ignore friendly fire
        if IsUnitEnemy(damagedUnit, GetOwningPlayer(damagingUnit)) then
            call AggroCheck()
        endif
    endfunction
    
    private function Trig_AggroUpdate_Conditions takes nothing returns boolean
        return AggroDataCount > 0
    endfunction
    
    private function Trig_AggroUpdate_Actions takes nothing returns nothing
        call AggroUpdate()
    endfunction
    
    private function Trig_AggroRemove_Actions takes nothing returns nothing
        call AggroRemove(GetTriggerUnit())
    endfunction
    
    //===========================================================================
    // Initialization
    //===========================================================================
    private function InitTriggers takes nothing returns nothing
        local trigger t = CreateTrigger()
        
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED)
        call TriggerAddCondition(t, Condition(function Trig_AggroCheck_Conditions))
        call TriggerAddAction(t, function Trig_AggroCheck_Actions)
        
        set t = CreateTrigger()
        call TriggerRegisterTimerEventPeriodic(t, AggroCheckInterval)
        call TriggerAddCondition(t, Condition(function Trig_AggroUpdate_Conditions))
        call TriggerAddAction(t, function Trig_AggroUpdate_Actions)
        
        set t = CreateTrigger()
        call TriggerRegisterUnitEvent(t, EVENT_UNIT_DEATH, null)
        call TriggerAddAction(t, function Trig_AggroRemove_Actions)
    endfunction
    
    private function InitGlobals takes nothing returns nothing
        set AggroUpdateTimer = CreateTimer()
        call TimerStart(AggroUpdateTimer, MaxAggroTime, false, null)
        
        call InitializeAggroList()
        
        call InitTriggers()
    endfunction
    
    //===========================================================================
    // Main
    //===========================================================================
    private function main takes nothing returns nothing
        call InitGlobals()
    endfunction
    endlibrary