library BGMSound
    globals
        string BGMSound
    endglobals
    function PSound takes string s returns nothing
        call StopMusic(false)
        call PlayMusic(s)
        set BGMSound = s
    endfunction
endlibrary

library PSound
    
    private struct FxSt
        unit caster
        integer i
        real r
        private method OnStop takes nothing returns nothing
            set caster = null
            set i = 0
            set r = 0
        endmethod
        //! runtextmacro 연출()
    endstruct

    globals
        private constant integer NeutralCode = PLAYER_NEUTRAL_PASSIVE
        //더미
        private constant integer DummyCode = 'h001'
    endglobals
    function Sound3D takes unit u, integer s returns nothing
        local unit A = CreateUnit(Player(NeutralCode),DummyCode,GetWidgetX(u),GetWidgetY(u),0)
        call UnitAddAbility(A,s)
        call IssueImmediateOrder( A, "berserk" )
        call UnitApplyTimedLife(A, 'BHwe', 1)
        set A = null
    endfunction
    function Sound3DXY takes real x, real y, integer s returns nothing
        local unit A = CreateUnit(Player(NeutralCode),DummyCode,x,y,0)
        call UnitAddAbility(A,s)
        call IssueImmediateOrder( A, "berserk" )
        call UnitApplyTimedLife(A, 'BHwe', 1)
        set A = null
    endfunction


    private function EffectFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        local FxSt fx = t.data
        local unit A = CreateUnit(Player(NeutralCode),DummyCode,GetWidgetX(fx.caster),GetWidgetY(fx.caster),0)

        call UnitAddAbility(A,fx.i)
        call IssueImmediateOrder( A, "berserk" )
        call UnitApplyTimedLife(A, 'BHwe', 1)
        set A = null
        
        call fx.Stop()
        call t.destroy()
    endfunction

    function Sound3DT takes unit u, integer s, real r returns nothing
        local tick t
        local FxSt fx
             
        set t = tick.create(0) 
        set fx = FxSt.Create()
        set fx.caster = u
        set fx.i = s
        set t.data = fx
        
        call t.start( r, false, function EffectFunction ) 
    endfunction
endlibrary
