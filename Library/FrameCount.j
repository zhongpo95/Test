// 프레임 번호와 강화 화면에서 숨길 공통 게임 UI 부모 관리
library FrameCount requires DzAPIFrameHandle
    globals
        integer FrameNum = 0
        private integer GameplayUIRoot = 0
    endglobals

    function FrameCount takes nothing returns integer
        set FrameNum = FrameNum + 1
        return FrameNum
    endfunction

    function GetGameplayUI takes nothing returns integer
        if GameplayUIRoot == 0 then
            set GameplayUIRoot = DzCreateFrameByTagName("FRAME", "GameplayUI", DzGetGameUI(), "", FrameCount())
            // 표시 상태만 묶는 부모에는 게임 클릭을 가로채는 화면 영역을 만들지 않습니다.
            call DzFrameSetAbsolutePoint(GameplayUIRoot, JN_FRAMEPOINT_BOTTOMLEFT, 0.0, 0.0)
            call DzFrameSetSize(GameplayUIRoot, 0.0, 0.0)
        endif
        return GameplayUIRoot
    endfunction
endlibrary
