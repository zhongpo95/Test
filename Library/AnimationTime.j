/*
    시스템 AnimationTime

    하는 일

        - 스킬모션 함수를 제공합니다.
*/
library AnimationTime requires Tick
    private struct AnimationTimer
        unit unit
        string string
        integer integer
        integer integer2
        real r
        real time
    endstruct

    private function ClearAnimationTimer takes AnimationTimer st returns nothing
        set st.unit = null
        set st.string = null
        set st.integer = 0
        set st.integer2 = 0
        set st.r = 0
        set st.time = 0
        call st.destroy()
    endfunction

    private function AnimationStringFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        local AnimationTimer st = t.data
        call SetUnitAnimation(st.unit,st.string)
        call ClearAnimationTimer(st)
        set t.data = 0
        call t.destroy()
    endfunction

    private function AnimationTimeFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        local AnimationTimer st = t.data
        call SetUnitAnimationByIndex(st.unit,st.integer)
        call ClearAnimationTimer(st)
        set t.data = 0
        call t.destroy()
    endfunction

    private function AnimationTimeScaleFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        local AnimationTimer st = t.data
        if st.integer2 == 0 then
            call SetUnitTimeScale(st.unit,st.r)
            call SetUnitAnimationByIndex(st.unit,st.integer)
            set st.integer2 = 1
            call t.start(st.time,false,function AnimationTimeScaleFunction)
        else
            call SetUnitTimeScale(st.unit,1)
            call ClearAnimationTimer(st)
            set t.data = 0
            call t.destroy()
        endif
    endfunction

    private function AnimationTimeScaleStartFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        local AnimationTimer st = t.data
        call SetUnitAnimationByIndex(st.unit,st.integer)
        call SetUnitTimeScale(st.unit,st.r)
        call ClearAnimationTimer(st)
        set t.data = 0
        call t.destroy()
    endfunction

    function AnimationStringStart takes unit u, string s returns nothing
        local tick t = tick.create(0)
        local AnimationTimer st = AnimationTimer.create()
        set st.unit = u
        set st.string = s
        set t.data = st
        call t.start(0.01,false,function AnimationStringFunction)
    endfunction

    function AnimationStart takes unit u, integer i returns nothing
        local tick t = tick.create(0)
        local AnimationTimer st = AnimationTimer.create()
        set st.unit = u
        set st.integer = i
        set t.data = st
        call t.start(0.01,false,function AnimationTimeFunction)
    endfunction

    function AnimationStart2 takes unit u, integer i, real time, real r returns nothing
        local tick t = tick.create(0)
        local AnimationTimer st = AnimationTimer.create()
        set st.unit = u
        set st.integer = i
        set st.integer2 = 0
        set st.r = r
        set st.time = time
        set t.data = st
        call t.start(0.01,false,function AnimationTimeScaleFunction)
    endfunction

    function AnimationStart3 takes unit u, integer i, real r returns nothing
        local tick t = tick.create(0)
        local AnimationTimer st = AnimationTimer.create()
        set st.unit = u
        set st.integer = i
        set st.r = r
        set t.data = st
        call t.start(0.01,false,function AnimationTimeScaleStartFunction)
    endfunction

    function AnimationStart4 takes unit u, integer i, real r returns nothing
        local tick t = tick.create(0)
        local AnimationTimer st = AnimationTimer.create()
        set st.unit = u
        set st.integer = i
        set t.data = st
        call t.start(r,false,function AnimationTimeFunction)
    endfunction
endlibrary
