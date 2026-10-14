// 저장 판 선택 상수. 거짓이면 JN 판, 참이면 Arcana 자체 서버(api=3) 판으로 컴파일된다. 판 전환은 이 파일만 바꾼다.
library ArcanaSaveConfig
    globals
        // DESIGN_REVIEW_06 2번. 맵 머리글(.w3x) 대신 저장소 파일에 두어 커밋으로 판을 고른다.
        constant boolean ARCANA_SAVE_BACKEND = false
        // 09 3.3: 웹 기록. ARCANA_SAVE_BACKEND 도 참일 때만 의미가 있다. 참이면 DLL 0.4.0(api=4) 이상이 필요하다. 단계 7 실게임 검증 전까지 거짓.
        constant boolean ARCANA_RECORDS_ENABLED = false
        constant string ARCANA_MAP_CODE = "arcana"
        constant string ARCANA_MAP_VERSION = "dev"
    endglobals
endlibrary
