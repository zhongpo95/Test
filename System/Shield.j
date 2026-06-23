library Shield requires UIHP,DataUnit

    globals
        integer array USDT
        private trigger array TrgRemove
        private triggeraction array ActRemove
    endglobals

    private struct ShieldTimer
        unit caster
    endstruct

    private function EffectFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        local ShieldTimer st = t.data

        set UnitSD[GetUnitIndex(st.caster)] = 0
        set USDT[GetUnitIndex(st.caster)] = 0
        call RefreshHP(st.caster)
        set st.caster = null
        call st.destroy()
        set t.data = 0
        call t.destroy()
    endfunction

    private function OnRemove takes nothing returns nothing
        local integer i = GetTriggerIndex()
        call TriggerRemoveAction(TrgRemove[i], ActRemove[i])
        set ActRemove[i] = null
        set TrgRemove[i] = null
        set USDT[i] = 0
    endfunction

    function ShieldAdd takes unit caster, real time, real value returns nothing
        local tick t
        local ShieldTimer st
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

            set t = tick.create(0)
            set st = ShieldTimer.create()
            set st.caster = caster
            set t.data = st
            set USDT[i] = t
            call t.start(ttime,false,function EffectFunction)
        else
            set t = USDT[i]
            set st = t.data
            set st.caster = caster
            set ttime = t.remaining
            if time < t.remaining then
                set ttime = t.remaining
            else
                set ttime = time
            endif

            set UnitSD[i] = UnitSD[i] + value
            set HP = GetUnitState(caster, UNIT_STATE_MAX_LIFE)
            if UnitSD[i] >= HP then
                set UnitSD[i] = HP
            endif
            call t.start(ttime,false,function EffectFunction)
        endif
        call RefreshHP(caster)
    endfunction
    endlibrary
