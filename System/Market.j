// 상점 가격. JN 판은 공용 SHOP 캐릭터를 읽고 쓴다. Arcana 판은 JN 을 부르지 않고 기본 가격(50000)을 쓴다(09 2.3).
library Market initializer init
    globals
        integer array Price
    endglobals

    function MarketDataDownload takes integer pid returns nothing
        static if ARCANA_SAVE_BACKEND then
        // Arcana 판: 서버 가격 관리 없음. 지금은 실행되지 않는 경로(ShopShow)지만 다시 켜져도 JN 을 부르지 않는다.
        else
        if Player(pid) == GetLocalPlayer() then
            call JNObjectCharacterResetCharacter("SHOP")
            call JNObjectCharacterInit(MapName, "SHOP", MapApi, "Default String")
            set Price[0] = S2I(JNObjectCharacterGetString("SHOP","0.1"))
            set Price[1] = S2I(JNObjectCharacterGetString("SHOP","1.1"))
            set Price[2] = S2I(JNObjectCharacterGetString("SHOP","2.1"))
            set Price[3] = S2I(JNObjectCharacterGetString("SHOP","3.1"))
            set Price[4] = S2I(JNObjectCharacterGetString("SHOP","4.1"))
        endif
        endif
    endfunction

    function MarketDataUpload takes integer pid, integer i, integer j returns nothing
        static if ARCANA_SAVE_BACKEND then
        // Arcana 판: 아무것도 하지 않는다.
        else
        if Player(pid) == GetLocalPlayer() then
            call JNObjectCharacterSetString("SHOP", I2S(i)+".1", I2S(j))
            call JNObjectCharacterSave( MapName, "SHOP", MapApi, "Default String" )
        endif
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
