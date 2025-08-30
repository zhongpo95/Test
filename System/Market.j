library Market initializer init
    globals
        integer array Price
    endglobals

    function MarketDataDownload takes integer pid returns nothing
        if Player(pid) == GetLocalPlayer() then
            call JNObjectCharacterResetCharacter("SHOP")
            call JNObjectCharacterInit(MapName, "SHOP", MapApi, "Default String")
            set Price[0] = S2I(JNObjectCharacterGetString("SHOP","0.1"))
            set Price[1] = S2I(JNObjectCharacterGetString("SHOP","1.1"))
            set Price[2] = S2I(JNObjectCharacterGetString("SHOP","2.1"))
            set Price[3] = S2I(JNObjectCharacterGetString("SHOP","3.1"))
            set Price[4] = S2I(JNObjectCharacterGetString("SHOP","4.1"))
        endif
    endfunction

    function MarketDataUpload takes integer pid, integer i, integer j returns nothing
        if Player(pid) == GetLocalPlayer() then
            call JNObjectCharacterSetString("SHOP", I2S(i)+".1", I2S(j))
            call JNObjectCharacterSave( MapName, "SHOP", MapApi, "Default String" )
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