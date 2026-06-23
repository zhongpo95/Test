/*
    시스템 DummyMagicleash

    하는 일

        - 정지를 사용하지않고 에어리얼 쉐클을 사용하여 소녀의 작동을 동작불가상태로 만듭니다.
*/
library DummyMagicleash requires Tick
    globals
        private constant integer NeutralCode = PLAYER_NEUTRAL_PASSIVE
        private constant integer DummyCode = 'h001'
        private constant integer BuffCode = 'B000'
        private unit DummyUnit
    endglobals

    private struct Magicleash
        unit unit
        unit dummy
    endstruct

    private struct Magicleash2
        unit unit
        unit dummy
        real time
        integer i
    endstruct

    private function MagicleashFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        local Magicleash st = t.data
        call UnitRemoveAbility(st.unit, BuffCode)
        call UnitApplyTimedLife(st.dummy, 'BHwe', 0.1)
        set st.unit = null
        set st.dummy = null
        call st.destroy()
        set t.data = 0
        call t.destroy()
    endfunction

    private function Magicleash2Function takes nothing returns nothing
        local tick t = tick.getExpired()
        local Magicleash2 st = t.data
        if st.i == 0 then
            set st.i = 1
            call IssueTargetOrder(st.dummy,"magicleash",st.unit)
            call t.start(st.time,false,function Magicleash2Function)
        else
            call UnitRemoveAbility(st.unit, BuffCode)
            call UnitApplyTimedLife(st.dummy, 'BHwe', 0.1)
            set st.unit = null
            set st.dummy = null
            set st.time = 0
            call st.destroy()
            set t.data = 0
            call t.destroy()
        endif
    endfunction

    function DummyMagicleash takes unit u, real time returns nothing
        local tick t = tick.create(0)
        local Magicleash st = Magicleash.create()
        set st.dummy = CreateUnit(Player(NeutralCode), DummyCode, GetWidgetX(u), GetWidgetY(u), 270)
        set st.unit = u
        if GetUnitAbilityLevel(st.unit,BuffCode) > 0 then
            call UnitRemoveAbility(st.unit, BuffCode)
        endif
        call IssueTargetOrder(st.dummy,"magicleash",u)
        set t.data = st
        call t.start(time,false,function MagicleashFunction)
    endfunction

    function DummyMagicleash2 takes unit target returns unit
        local unit dummy = CreateUnit(Player(NeutralCode), DummyCode, GetWidgetX(target), GetWidgetY(target), 270)
        call IssueTargetOrder(dummy,"magicleash",target)
        set target = dummy
        set dummy = null
        return target
    endfunction

    function DummyMagicleash3 takes unit u, real time returns nothing
        local tick t = tick.create(0)
        local Magicleash2 st = Magicleash2.create()
        set st.dummy = CreateUnit(Player(NeutralCode), DummyCode, GetWidgetX(u), GetWidgetY(u), 270)
        set st.unit = u
        set st.time = time
        set st.i = 0
        set t.data = st
        call t.start(0.02,false,function Magicleash2Function)
    endfunction
endlibrary
