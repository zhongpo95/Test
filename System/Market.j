library Market initializer init
    globals
        integer array Price
    endglobals

    function MarketDataDownload takes integer pid returns nothing
        if Player(pid) == GetLocalPlayer() then
            call JNObjectUserResetCharacter("SHOP")
            call JNObjectUserInit(MapName, "SHOP", MapApi, "Default String")
            set Price[0] = S2I(JNObjectUserGetString("SHOP","0.1"))
            set Price[1] = S2I(JNObjectUserGetString("SHOP","1.1"))
            set Price[2] = S2I(JNObjectUserGetString("SHOP","2.1"))
            set Price[3] = S2I(JNObjectUserGetString("SHOP","3.1"))
            set Price[4] = S2I(JNObjectUserGetString("SHOP","4.1"))
        endif
    endfunction

    function MarketDataUpload takes integer pid, integer i, integer j returns nothing
        if Player(pid) == GetLocalPlayer() then
            call JNObjectUserSetString("SHOP", I2S(i)+".1", I2S(j))
            call JNObjectUserSave( MapName, "SHOP", MapApi, "Default String" )
        endif
    endfunction

    private function init takes nothing returns nothing
        set Price[0] = 50000
        set Price[1] = 50000
        set Price[2] = 50000
        set Price[3] = 50000
        set Price[4] = 50000
    endfunction
endlibrary