library UnitAlpha requires Tick

    private struct DAlpha
        unit target
        integer i
    endstruct

    private struct DRAlpha
        unit target
        integer i
    endstruct

    private struct DRAlpha2
        unit target
    endstruct

    private function DAlphaFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        local DAlpha st = t.data
        if st.i == 0 then
            call SetUnitVertexColorBJ(st.target, 100, 100, 100, 100)
            set st.target = null
            call st.destroy()
            set t.data = 0
            call t.destroy()
        else
            set st.i = st.i - 1
            call SetUnitVertexColorBJ(st.target, 100, 100, 100, 100 - (st.i*100/60))
        endif
    endfunction

    private function DRAlphaFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        local DRAlpha st = t.data
        if st.i == 0 then
            call SetUnitVertexColorBJ(st.target, 100, 100, 100, 0)
            set st.target = null
            call st.destroy()
            set t.data = 0
            call t.destroy()
        else
            set st.i = st.i - 1
            call SetUnitVertexColorBJ(st.target, 100, 100, 100, (st.i*100/60))
        endif
    endfunction

    private function DRAlpha2Function takes nothing returns nothing
        local tick t = tick.getExpired()
        local DRAlpha2 st = t.data
        call SetUnitVertexColorBJ(st.target, 100, 100, 100, 0)
        set st.target = null
        call st.destroy()
        set t.data = 0
        call t.destroy()
    endfunction

    function RemoveAlpha takes unit target returns nothing
        call SetUnitVertexColorBJ( target, 100, 100, 100, 0 )
    endfunction

    function DelayRemoveAlpha2 takes unit target, real time returns nothing
        local tick t = tick.create(0)
        local DRAlpha2 st = DRAlpha2.create()
        set st.target = target
        set t.data = st
        call t.start(time, false, function DRAlpha2Function)
    endfunction

    function DelayRemoveAlpha takes unit target, real time returns nothing
        local tick t = tick.create(0)
        local DRAlpha st = DRAlpha.create()
        set st.i = 60
        set st.target = target
        set t.data = st
        call t.start(time/60, true, function DRAlphaFunction)
    endfunction

    function DelayAlpha takes unit target, real time returns nothing
        local tick t = tick.create(0)
        local DAlpha st = DAlpha.create()
        set st.i = 60
        set st.target = target
        set t.data = st
        call t.start(time/60, true, function DAlphaFunction)
    endfunction
endlibrary
