// 저장 판 선택 상수. 거짓이면 JN 판, 참이면 Arcana 자체 서버(api=3) 판으로 컴파일된다. 판 전환은 이 파일만 바꾼다.
library ArcanaSaveConfig
    globals
        // DESIGN_REVIEW_06 2번. 맵 머리글(.w3x) 대신 저장소 파일에 두어 커밋으로 판을 고른다.
        constant boolean ARCANA_SAVE_BACKEND = false
        constant string ARCANA_MAP_CODE = "arcana"
        constant string ARCANA_MAP_VERSION = "dev"
    endglobals
endlibrary
