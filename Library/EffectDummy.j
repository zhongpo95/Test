library EffectDummy initializer init requires Tick
    globals
        private constant integer NeutralCode = PLAYER_NEUTRAL_PASSIVE

        boolean array EffectOff
    endglobals

    private struct EffectDummy
        unit unit
        integer pid
    endstruct

    private struct EffectDummy2
        integer id
        real x
        real y
        real r
        real time
        real time2
        integer i
    endstruct

    private struct EffectDummy3
        integer id
        unit target
        real r
        real time
        real time2
        integer i
    endstruct

    private struct EffectDummy4
        integer id
        unit target
        real r
        real time
        real time2
        integer i
        integer pid
    endstruct

    private function EffectDummyFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        local EffectDummy st = t.data
        call KillUnit(st.unit)
        call ShowUnit(st.unit,false)
        set st.unit = null
        call st.destroy()
        set t.data = 0
        call t.destroy()
    endfunction

    private function EffectDummy2Function takes nothing returns nothing
        local tick t = tick.getExpired()
        local EffectDummy2 st = t.data
        local tick t2 = tick.create(0)
        local EffectDummy st2 = EffectDummy.create()
        set st2.unit = CreateUnit(Player(NeutralCode),st.id,st.x,st.y,st.r)
        if EffectOff[GetPlayerId(GetLocalPlayer())] == false then
            call DzSetUnitModel(st2.unit,".mdl")
        endif
        call SetUnitAnimationByIndex(st2.unit,st.i)
        set t2.data = st2
        call t2.start(st.time,false,function EffectDummyFunction)
        call st.destroy()
        set t.data = 0
        call t.destroy()
    endfunction

    private function EffectDummy3Function takes nothing returns nothing
        local tick t = tick.getExpired()
        local EffectDummy3 st = t.data
        local tick t2 = tick.create(0)
        local EffectDummy st2 = EffectDummy.create()
        set st2.unit = CreateUnit(Player(NeutralCode),st.id,GetUnitX(st.target),GetUnitY(st.target),st.r)
        set t2.data = st2
        call t2.start(st.time2,false,function EffectDummyFunction)
        set st.target = null
        call st.destroy()
        set t.data = 0
        call t.destroy()
    endfunction

    private function EffectDummy4Function takes nothing returns nothing
        local tick t = tick.getExpired()
        local EffectDummy4 st = t.data
        local tick t2 = tick.create(0)
        local EffectDummy st2 = EffectDummy.create()
        set st2.unit = CreateUnit(Player(NeutralCode),st.id,GetUnitX(st.target),GetUnitY(st.target),st.r)
        if EffectOff[GetPlayerId(GetLocalPlayer())] == false and st.pid != GetPlayerId(GetLocalPlayer()) then
            call DzSetUnitModel(st2.unit,".mdl")
        endif
        set t2.data = st2
        call t2.start(st.time2,false,function EffectDummyFunction)
        set st.target = null
        call st.destroy()
        set t.data = 0
        call t.destroy()
    endfunction

    function UnitEffectTimeToTime takes integer id, real x, real y, real r, real time, real time2, integer i returns nothing
        local tick t = tick.create(0)
        local EffectDummy2 st = EffectDummy2.create()
        set st.id = id
        set st.x = x
        set st.y = y
        set st.r = r
        set st.time = time2
        set st.i = i
        set t.data = st
        call t.start(time,false,function EffectDummy2Function)
    endfunction
    //투명적용안됨
    function UnitEffectTimeEX takes integer id, real x, real y, real r, real time returns unit
        local tick t = tick.create(0)
        local EffectDummy st = EffectDummy.create()
        set st.unit = CreateUnit(Player(NeutralCode),id,x,y,r)
        if EffectOff[GetPlayerId(GetLocalPlayer())] == false then
            call DzSetUnitModel(st.unit,".mdl")
        endif
        set t.data = st
        call t.start(time,false,function EffectDummyFunction)
        return st.unit
    endfunction

    function UnitEffectTimeEX2 takes integer id, real x, real y, real r, real time, integer pid returns unit
        local tick t = tick.create(0)
        local EffectDummy st = EffectDummy.create()
        set st.unit = CreateUnit(Player(NeutralCode),id,x,y,r)
        if EffectOff[GetPlayerId(GetLocalPlayer())] == false and pid != GetPlayerId(GetLocalPlayer()) then
            call DzSetUnitModel(st.unit,".mdl")
        endif
        set t.data = st
        call t.start(time,false,function EffectDummyFunction)
        return st.unit
    endfunction

    function UnitEffectTime takes integer id, real x, real y, real r, real time, string s returns unit
        local tick t = tick.create(0)
        local EffectDummy st = EffectDummy.create()
        set st.unit = CreateUnit(Player(NeutralCode),id,x,y,r)
        if EffectOff[GetPlayerId(GetLocalPlayer())] == false then
            call DzSetUnitModel(st.unit,".mdl")
        endif
        call SetUnitAnimation(st.unit,s)
        set t.data = st
        call t.start(time,false,function EffectDummyFunction)
        return st.unit
    endfunction

    function UnitEffectTime2 takes integer id, real x, real y, real r, real time, integer i, integer pid returns unit
        local tick t = tick.create(0)
        local EffectDummy st = EffectDummy.create()
        set st.unit = CreateUnit(Player(NeutralCode),id,x,y,r)
        if EffectOff[GetPlayerId(GetLocalPlayer())] == false and pid != GetPlayerId(GetLocalPlayer()) then
            call DzSetUnitModel(st.unit,".mdl")
        endif
        call SetUnitAnimationByIndex(st.unit,i)
        set t.data = st
        call t.start(time,false,function EffectDummyFunction)
        return st.unit
    endfunction

    //투명적용안됨
    function DelayKill takes unit u, real time returns nothing
        local tick t = tick.create(0)
        local EffectDummy st = EffectDummy.create()
        set st.unit = u
        set t.data = st
        call t.start(time,false,function EffectDummyFunction)
    endfunction
    //투명적용안됨

    function OnlyDelayKill takes unit u, real time, integer pid returns nothing
        local tick t = tick.create(0)
        local EffectDummy st = EffectDummy.create()
        set st.unit = u
        if pid != GetPlayerId(GetLocalPlayer()) then
            call DzSetUnitModel(st.unit,".mdl")
        endif
        set t.data = st
        call t.start(time,false,function EffectDummyFunction)
    endfunction
    //투명적용안됨
    function DelayCreate takes unit target, integer id, real r, real time, real time2 returns nothing
        local tick t = tick.create(0)
        local EffectDummy3 st = EffectDummy3.create()
        set st.id = id
        set st.target = target
        set st.r = r
        set st.time2 = time2
        set t.data = st
        call t.start(time,false,function EffectDummy3Function)
    endfunction
    function DelayCreate2 takes unit target, integer id, real r, real time, real time2, integer pid returns nothing
        local tick t = tick.create(0)
        local EffectDummy4 st = EffectDummy4.create()
        set st.id = id
        set st.target = target
        set st.r = r
        set st.time2 = time2
        set st.pid = pid
        set t.data = st
        call t.start(time,false,function EffectDummy4Function)
    endfunction


    function SetEffectViewON takes nothing returns nothing
        set EffectOff[GetPlayerId(GetTriggerPlayer())] = true
    endfunction
    function SetEffectViewOFF takes nothing returns nothing
        set EffectOff[GetPlayerId(GetTriggerPlayer())] = false
    endfunction

    private function init takes nothing returns nothing
        local trigger t
        local trigger t2
        local integer index = 0
        set t = CreateTrigger()
        set t2 = CreateTrigger()
        loop
            call TriggerRegisterPlayerChatEvent(t, Player(index), "-이펙트 끄기", false)
            call TriggerRegisterPlayerChatEvent(t2, Player(index), "-이펙트 켜기", false)
            set index = index + 1
            exitwhen index == bj_MAX_PLAYER_SLOTS
        endloop
        call TriggerAddAction(t, function SetEffectViewOFF)
        call TriggerAddAction(t2, function SetEffectViewON)
        set t = null
        set t2 = null

        set EffectOff[0] = true
        set EffectOff[1] = true
        set EffectOff[2] = true
        set EffectOff[3] = true
        set EffectOff[4] = true
    endfunction
endlibrary
