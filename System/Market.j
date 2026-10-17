// 상점 가격. 서버 가격 관리 없이 기본 가격(50000)을 쓴다(09 2.3).
library Market initializer init
    globals
        integer array Price
    endglobals

    function MarketDataDownload takes integer pid returns nothing
        // Arcana 판: 서버 가격 관리 없음. 지금은 실행되지 않는 경로(ShopShow)지만 다시 켜져도 JN 을 부르지 않는다.
    endfunction

    function MarketDataUpload takes integer pid, integer i, integer j returns nothing
        // Arcana 판: 아무것도 하지 않는다.
    endfunction

    private function init takes nothing returns nothing
        set Price[0] = 50000
        set Price[1] = 50000
        set Price[2] = 50000
        set Price[3] = 50000
        set Price[4] = 50000
    endfunction
endlibrary
