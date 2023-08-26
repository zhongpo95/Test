/*
    시스템 AnimationTime
    
    하는 일
    
        - 스킬모션 함수를 제공합니다.
*/
//! runtextmacro 시스템("AnimationTime")
    //! runtextmacro 틱("AnimationString")
        unit unit
        string string
    //! runtextmacro 틱_끝()
    
    //! runtextmacro 틱("AnimationTime")
        unit unit
        integer integer
    //! runtextmacro 틱_끝()
    
    //! runtextmacro 틱("AnimationTime2")
        unit unit
        integer integer
        integer integer2
        real r
        real time
    //! runtextmacro 틱_끝()
    
    //! runtextmacro 틱("AnimationTime3")
        unit unit
        integer integer
        real r
    //! runtextmacro 틱_끝()
    
    //! runtextmacro 이벤트_틱이_종료되면_발동("AnimationString")
        call SetUnitAnimation(expired.unit,expired.string)
        set expired.unit = null
        call expired.Destroy()
    //! runtextmacro 이벤트_끝()
    
    //! runtextmacro 이벤트_틱이_종료되면_발동("AnimationTime")
        call SetUnitAnimationByIndex(expired.unit,expired.integer)
        set expired.unit = null
        set expired.integer = 0
        call expired.Destroy()
    //! runtextmacro 이벤트_끝()
    
    //! runtextmacro 이벤트_틱이_종료되면_발동("AnimationTime2")
    if expired.integer2 == 0 then
        call SetUnitTimeScale(expired.unit,expired.r)
        call SetUnitAnimationByIndex(expired.unit,expired.integer)
        set expired.integer2 = 1
        call expired.Start(expired.time,false)
    else
        call SetUnitTimeScale(expired.unit,1)
        set expired.unit = null
        set expired.integer = 0
        set expired.integer2 = 0
        set expired.r = 0
        set expired.time = 0
        call expired.Destroy()
    endif
    //! runtextmacro 이벤트_끝()
    
    //! runtextmacro 이벤트_틱이_종료되면_발동("AnimationTime3")
        call SetUnitAnimationByIndex(expired.unit,expired.integer)
        call SetUnitTimeScale(expired.unit,expired.r)
        set expired.unit = null
        set expired.integer = 0
        set expired.r = 0
        call expired.Destroy()
    //! runtextmacro 이벤트_끝()
    
    function AnimationStringStart takes unit u, string s returns nothing
        local AnimationString t = AnimationString.Create()
        set t.unit = u
        set t.string = s
        call t.Start(0.01,false)
    endfunction
    
    function AnimationStart takes unit u, integer i returns nothing
        local AnimationTime t = AnimationTime.Create()
        set t.unit = u
        set t.integer = i
        call t.Start(0.01,false)
    endfunction
    
    function AnimationStart2 takes unit u, integer i, real time, real r returns nothing
        local AnimationTime2 t = AnimationTime2.Create()
        set t.unit = u
        set t.integer = i
        set t.integer2 = 0
        set t.r = r
        set t.time = time
        call t.Start(0.01,false)
    endfunction
    
    function AnimationStart3 takes unit u, integer i, real r returns nothing
        local AnimationTime3 t = AnimationTime3.Create()
        set t.unit = u
        set t.integer = i
        set t.r = r
        call t.Start(0.01,false)
    endfunction
    
    
    function AnimationStart4 takes unit u, integer i, real r returns nothing
        local AnimationTime t = AnimationTime.Create()
        set t.unit = u
        set t.integer = i
        call t.Start(r,false)
    endfunction
//! runtextmacro 시스템_끝()