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
endlibrary
