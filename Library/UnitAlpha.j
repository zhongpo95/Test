library UnitAlpha

    //! runtextmacro 틱("DAlpha")
    unit target
    integer i
    //! runtextmacro 틱_끝()

    //! runtextmacro 틱("DRAlpha")
    unit target
    integer i
    //! runtextmacro 틱_끝()
    
    //! runtextmacro 틱("DRAlpha2")
    unit target
    //! runtextmacro 틱_끝()
    
    //! runtextmacro 이벤트_틱이_종료되면_발동("DRAlpha")
        if expired.i == 0 then
            call SetUnitVertexColorBJ( expired.target, 100, 100, 100, 0 )
            set expired.target = null
            call expired.Pause()
            call expired.Destroy()
        else
            set expired.i = expired.i - 1
            call SetUnitVertexColorBJ( expired.target, 100, 100, 100, (expired.i*100/60) )
        endif
    //! runtextmacro 이벤트_끝()

    //! runtextmacro 이벤트_틱이_종료되면_발동("DAlpha")
        if expired.i == 0 then
            call SetUnitVertexColorBJ( expired.target, 100, 100, 100, 100 )
            set expired.target = null
            call expired.Pause()
            call expired.Destroy()
        else
            set expired.i = expired.i - 1
            call SetUnitVertexColorBJ( expired.target, 100, 100, 100, 100 - (expired.i*100/60) )
        endif
    //! runtextmacro 이벤트_끝()

    //! runtextmacro 이벤트_틱이_종료되면_발동("DRAlpha2")
        call SetUnitVertexColorBJ( expired.target, 100, 100, 100, 0 )
        set expired.target = null
        call expired.Destroy()
    //! runtextmacro 이벤트_끝()

    function RemoveAlpha takes unit target returns nothing
        call SetUnitVertexColorBJ( target, 100, 100, 100, 0 )
    endfunction

    function DelayRemoveAlpha2 takes unit target, real time returns nothing
        local DRAlpha2 t = DRAlpha2.Create()
        set t.target = target
        call t.Start(time, false)
    endfunction

    function DelayRemoveAlpha takes unit target, real time returns nothing
        local DRAlpha t = DRAlpha.Create()
        set t.i = 60
        set t.target = target
        call t.Start(time/60, true)
    endfunction

    function DelayAlpha takes unit target, real time returns nothing
        local DAlpha t = DAlpha.Create()
        set t.i = 60
        set t.target = target
        call t.Start(time/60, true)
    endfunction
endlibrary