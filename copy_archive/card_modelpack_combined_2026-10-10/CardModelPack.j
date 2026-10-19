// 카드 그림 ASI를 맵 초기화 때 한 번 로드하며 로컬 결과를 기록한다.
//! import "JAPIMisc.j"

library ArcanaCardModelPack initializer Init requires JAPIMisc, JNCommon
    private function Init takes nothing returns nothing
        static if not REFORGED_MODE then
            local string result = EXExecuteScript("(function() if type(package) ~= 'table' or type(package.loadlib) ~= 'function' then return 'UNSUPPORTED' end local ok, loaded = pcall(package.loadlib, 'Arcana_Cards_20261010_v2.asi', '*'); if ok and loaded then return 'OK' end return 'FAILED' end)()")
            // 설치 여부는 클라이언트마다 다르므로 동기화된 게임 상태에 사용하지 않는다.
            call JNWriteLog("[ArcanaCardModelPack] " + result)
            set result = null
        endif
    endfunction
endlibrary
