library Shield requires UIHP,DataUnit

    globals
        private integer array USDT
        private trigger array TrgRemove
        private triggeraction array ActRemove
    endglobals
    
    //! runtextmacro 틱("ShieldTimer")
        unit caster
    //! runtextmacro 틱_끝()
    
    
    //! runtextmacro 이벤트_틱이_종료되면_발동("ShieldTimer")
        set UnitSD[GetUnitIndex(expired.caster)] = 0
        set USDT[GetUnitIndex(expired.caster)] = 0
        call RefreshHP(expired.caster)
        set expired.caster = null
        call expired.Destroy()
    //! runtextmacro 이벤트_끝()
    
    private function OnRemove takes nothing returns nothing
        local integer i = GetTriggerIndex()
        call TriggerRemoveAction(TrgRemove[i], ActRemove[i])
        set ActRemove[i] = null
        set TrgRemove[i] = null
        set USDT[i] = 0
    endfunction
    
    function ShieldAdd takes unit caster, real time, real value returns nothing
        local ShieldTimer t
        local integer i
        local real ttime
        local real HP
        
        set i = IndexUnit(caster)
        if USDT[i] == 0 then
            if ActRemove[i] == null then
                set TrgRemove[i] = GetUnitRemoveTrigger(caster)
                set ActRemove[i] = TriggerAddAction(TrgRemove[i],function OnRemove)
            endif
            
            set UnitSD[i] = value
            set HP = GetUnitState(caster, UNIT_STATE_MAX_LIFE)
            if UnitSD[i] >= HP then
                set UnitSD[i] = HP
            endif
            set ttime = time
            
            set t = ShieldTimer.Create()
            set t.caster = caster
            set USDT[i] = t
            call t.Start(ttime,false)
        else
            set t = USDT[i]
            set t.caster = caster
            set ttime = t.Remaining
            if time < t.Remaining then
                set ttime = t.Remaining
            else
                set ttime = time
            endif
            
            set UnitSD[i] = UnitSD[i] + value
            set HP = GetUnitState(caster, UNIT_STATE_MAX_LIFE)
            if UnitSD[i] >= HP then
                set UnitSD[i] = HP
            endif
            call t.Start(ttime,false)
        endif
        call RefreshHP(caster)
    endfunction
    endlibrary