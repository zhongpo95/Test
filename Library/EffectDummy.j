library EffectDummy
    globals
        private constant integer NeutralCode = PLAYER_NEUTRAL_PASSIVE
    endglobals
    //! runtextmacro 틱("EffectDummy")
        unit unit
    //! runtextmacro 틱_끝()
    //! runtextmacro 이벤트_틱이_종료되면_발동("EffectDummy")
        call KillUnit(expired.unit)
        set expired.unit = null
        call expired.Destroy()
    //! runtextmacro 이벤트_끝()
    //! runtextmacro 틱("EffectDummy2")
        integer id
        real x
        real y
        real r
        real time
        integer i
    //! runtextmacro 틱_끝()
    //! runtextmacro 이벤트_틱이_종료되면_발동("EffectDummy2")
        local EffectDummy t = EffectDummy.Create()
        set t.unit = CreateUnit(Player(NeutralCode),expired.id,expired.x,expired.y,expired.r)
        call SetUnitX(t.unit,expired.x)
        call SetUnitY(t.unit,expired.y)
        call SetUnitAnimationByIndex(t.unit,expired.i)
        call t.Start(expired.time,false)
        call expired.Destroy()
    //! runtextmacro 이벤트_끝()
    
    function UnitEffectTimeToTime takes integer id, real x, real y, real r, real time, real time2, integer i returns nothing
        local EffectDummy2 t = EffectDummy2.Create()
        set t.id = id
        set t.x = x
        set t.y = y
        set t.r = r
        set t.time = time2
        set t.i = i
        call t.Start(time,false)
    endfunction
    function UnitEffectTimeEX takes integer id, real x, real y, real r, real time returns unit
        local EffectDummy t = EffectDummy.Create()
        set t.unit = CreateUnit(Player(NeutralCode),id,x,y,r)
        call t.Start(time,false)
        return t.unit
    endfunction
    function UnitEffectTime takes integer id, real x, real y, real r, real time, string s returns unit
        local EffectDummy t = EffectDummy.Create()
        set t.unit = CreateUnit(Player(NeutralCode),id,x,y,r)
        call SetUnitAnimation(t.unit,s)
        call t.Start(time,false)
        return t.unit
    endfunction
    function UnitEffectTime2 takes integer id, real x, real y, real r, real time, integer i returns unit
        local EffectDummy t = EffectDummy.Create()
        set t.unit = CreateUnit(Player(NeutralCode),id,x,y,r)
        call SetUnitAnimationByIndex(t.unit,i)
        call t.Start(time,false)
        return t.unit
    endfunction
    function UnitEffectTimeSpeed2 takes integer id, real x, real y, real r, real time, integer i, real r2 returns unit
        local EffectDummy t = EffectDummy.Create()
        set t.unit = CreateUnit(Player(NeutralCode),id,x,y,r)
        call SetUnitAnimationByIndex(t.unit,i)
        call SetUnitTimeScale(t.unit, r2)
        call t.Start(time,false)
        return t.unit
    endfunction
    function DelayKill takes unit u, real time returns nothing
        local EffectDummy t = EffectDummy.Create()
        set t.unit = u
        call t.Start(time,false)
    endfunction
endlibrary