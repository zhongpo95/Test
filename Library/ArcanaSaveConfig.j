// 저장 설정 상수. 저장은 Arcana 자체 서버(DLL)만 쓴다(JN 판은 세이브 v2 P1.5 에서 없앴다, 되돌리기는 git 태그 save2-before-jn-removal).
library ArcanaSaveConfig
    globals
        // 09 3.3: 웹 기록. 참이면 DLL 0.4.0(api=4) 이상이 필요하다. 단계 7 실게임 검증 전까지 거짓.
        constant boolean ARCANA_RECORDS_ENABLED = false
        constant string ARCANA_MAP_CODE = "arcana"
        constant string ARCANA_MAP_VERSION = "dev"
    endglobals
endlibrary
