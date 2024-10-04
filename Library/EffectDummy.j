library EffectDummy initializer init
    globals
        private constant integer NeutralCode = PLAYER_NEUTRAL_PASSIVE

        boolean array EffectOff
    endglobals

    //! runtextmacro 틱("EffectDummy")
        unit unit
        integer pid
    //! runtextmacro 틱_끝()
    //! runtextmacro 이벤트_틱이_종료되면_발동("EffectDummy")
        call KillUnit(expired.unit)
        call ShowUnit(expired.unit,false)
        set expired.unit = null
        call expired.Destroy()
    //! runtextmacro 이벤트_끝()
    //! runtextmacro 틱("EffectDummy2")
        integer id
        real x
        real y
        real r
        real time
        real time2
        integer i
    //! runtextmacro 틱_끝()
    //! runtextmacro 틱("EffectDummy3")
        integer id
        unit target
        real r
        real time
        real time2
        integer i
    //! runtextmacro 틱_끝()
    //! runtextmacro 틱("EffectDummy4")
        integer id
        unit target
        real r
        real time
        real time2
        integer i
        integer pid
    //! runtextmacro 틱_끝()

    //! runtextmacro 이벤트_틱이_종료되면_발동("EffectDummy2")
        local EffectDummy t = EffectDummy.Create()
        set t.unit = CreateUnit(Player(NeutralCode),expired.id,expired.x,expired.y,expired.r)
        if EffectOff[GetPlayerId(GetLocalPlayer())] == false then
            call DzSetUnitModel(t.unit,".mdl")
        endif
        call SetUnitAnimationByIndex(t.unit,expired.i)
        call t.Start(expired.time,false)
        call expired.Destroy()
    //! runtextmacro 이벤트_끝()
    
    function SetEffectView takes integer pid, boolean off returns nothing
        set EffectOff[pid] = off
    endfunction

    //투명적용안됨
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
    //투명적용안됨
    function UnitEffectTimeEX takes integer id, real x, real y, real r, real time returns unit
        local EffectDummy t = EffectDummy.Create()
        set t.unit = CreateUnit(Player(NeutralCode),id,x,y,r)
        if EffectOff[GetPlayerId(GetLocalPlayer())] == false then
            call DzSetUnitModel(t.unit,".mdl")
        endif
        call t.Start(time,false)
        return t.unit
    endfunction

    function UnitEffectTimeEX2 takes integer id, real x, real y, real r, real time, integer pid returns unit
        local EffectDummy t = EffectDummy.Create()
        set t.unit = CreateUnit(Player(NeutralCode),id,x,y,r)
        if EffectOff[GetPlayerId(GetLocalPlayer())] == false and pid != GetPlayerId(GetLocalPlayer()) then
            call DzSetUnitModel(t.unit,".mdl")
        endif
        call t.Start(time,false)
        return t.unit
    endfunction

    function UnitEffectTime takes integer id, real x, real y, real r, real time, string s returns unit
        local EffectDummy t = EffectDummy.Create()
        set t.unit = CreateUnit(Player(NeutralCode),id,x,y,r)
        if EffectOff[GetPlayerId(GetLocalPlayer())] == false then
            call DzSetUnitModel(t.unit,".mdl")
        endif
        call SetUnitAnimation(t.unit,s)
        call t.Start(time,false)
        return t.unit
    endfunction

    function UnitEffectTime2 takes integer id, real x, real y, real r, real time, integer i, integer pid returns unit
        local EffectDummy t = EffectDummy.Create()
        set t.unit = CreateUnit(Player(NeutralCode),id,x,y,r)
        if EffectOff[GetPlayerId(GetLocalPlayer())] == false and pid != GetPlayerId(GetLocalPlayer()) then
            call DzSetUnitModel(t.unit,".mdl")
        endif
        call SetUnitAnimationByIndex(t.unit,i)
        call t.Start(time,false)
        return t.unit
    endfunction

    //투명적용안됨
    function DelayKill takes unit u, real time returns nothing
        local EffectDummy t = EffectDummy.Create()
        set t.unit = u
        call t.Start(time,false)
    endfunction
    
    //! runtextmacro 이벤트_틱이_종료되면_발동("EffectDummy3")
        local EffectDummy t = EffectDummy.Create()
        set t.unit = CreateUnit(Player(NeutralCode),expired.id,GetUnitX(expired.target),GetUnitY(expired.target),expired.r)
        call t.Start(expired.time2, false)
        set expired.target = null
        call expired.Destroy()
    //! runtextmacro 이벤트_끝()

    //투명적용안됨
    function DelayCreate takes unit target, integer id, real r, real time, real time2 returns nothing
        local EffectDummy3 t = EffectDummy3.Create()
        set t.id = id
        set t.target = target
        set t.r = r
        set t.time = time2
        call t.Start(time,false)
    endfunction

    //! runtextmacro 이벤트_틱이_종료되면_발동("EffectDummy4")
        local EffectDummy t = EffectDummy.Create()
        set t.unit = CreateUnit(Player(NeutralCode),expired.id,GetUnitX(expired.target),GetUnitY(expired.target),expired.r)
        if EffectOff[GetPlayerId(GetLocalPlayer())] == false and expired.pid != GetPlayerId(GetLocalPlayer()) then
            call DzSetUnitModel(t.unit,".mdl")
        endif
        call t.Start(expired.time2, false)
        set expired.target = null
        call expired.Destroy()
    //! runtextmacro 이벤트_끝()

    function DelayCreate2 takes unit target, integer id, real r, real time, real time2, integer pid returns nothing
        local EffectDummy4 t = EffectDummy4.Create()
        set t.id = id
        set t.target = target
        set t.r = r
        set t.time = time2
        set t.pid = pid
        call t.Start(time,false)
    endfunction
    
    private function init takes nothing returns nothing
        set EffectOff[0] = true
        set EffectOff[1] = true
        set EffectOff[2] = true
        set EffectOff[3] = true
        set EffectOff[4] = true
    endfunction
endlibrary