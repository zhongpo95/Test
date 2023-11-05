/*
    시스템 DummyMagicleash
    
    하는 일
    
        - 정지를 사용하지않고 에어리얼 쉐클을 사용하여 소녀의 작동을 동작불가상태로 만듭니다.
*/
//! runtextmacro 시스템("DummyMagicleash")
    globals
        private constant integer NeutralCode = PLAYER_NEUTRAL_PASSIVE
        private constant integer DummyCode = 'h001'
        private constant integer BuffCode = 'B000'
        private unit DummyUnit
    endglobals
    
    //! runtextmacro 틱("Magicleash")
        unit unit
        unit dummy
    //! runtextmacro 틱_끝()
    
    //! runtextmacro 이벤트_틱이_종료되면_발동("Magicleash")
        call UnitRemoveAbility( expired.unit, BuffCode )
        call UnitApplyTimedLife(expired.dummy, 'BHwe', 0.1)
        set expired.unit = null
        set expired.dummy = null
        call expired.Destroy()
    //! runtextmacro 이벤트_끝()
    
    //! runtextmacro 틱("Magicleash2")
        unit unit
        unit dummy
        real time
        integer i
    //! runtextmacro 틱_끝()
    
    //! runtextmacro 이벤트_틱이_종료되면_발동("Magicleash2")
        if expired.i == 0 then
            set expired.i = 1
            call IssueTargetOrder(expired.dummy,"magicleash",expired.unit)
            call expired.Start(expired.time,false)
        else
            call UnitRemoveAbility( expired.unit, BuffCode )
            call UnitApplyTimedLife( expired.dummy, 'BHwe', 0.1 )
            set expired.unit = null
            set expired.dummy = null
            set expired.time = 0
            call expired.Destroy()
        endif
    //! runtextmacro 이벤트_끝()
    
    function DummyMagicleash takes unit u, real time returns nothing
        local Magicleash t = Magicleash.Create()
        set t.dummy = CreateUnit(Player(NeutralCode), DummyCode, GetWidgetX(u), GetWidgetY(u), 270)
        set t.unit = u
        call IssueTargetOrder(t.dummy,"magicleash",u)
        call t.Start(time,false)
    endfunction
    
    function DummyMagicleash2 takes unit target returns unit
        local unit dummy = CreateUnit(Player(NeutralCode), DummyCode, GetWidgetX(target), GetWidgetY(target), 270)
        call IssueTargetOrder(dummy,"magicleash",target)
        set target = dummy
        set dummy = null
        return target
    endfunction
    
    function DummyMagicleash3 takes unit u, real time returns nothing
        local Magicleash2 t = Magicleash2.Create()
        set t.dummy = CreateUnit(Player(NeutralCode), DummyCode, GetWidgetX(u), GetWidgetY(u), 270)
        set t.unit = u
        set t.time = time
        set t.i = 0
        call t.Start(0.02,false)
    endfunction
//! runtextmacro 시스템_끝()