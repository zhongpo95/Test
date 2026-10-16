// Arcana.SaveNet3.dll(api=3) native 선언. ARCANA_SAVE_BACKEND 가 거짓이면 선언과 호출이 맵 스크립트에서 모두 빠진다(07_설계결정_수정 4.2).
library ArcanaSaveNet3Natives requires ArcanaSaveConfig

    // 이 맵은 api=3 DLL이 먼저 설치돼 있어야 실행된다(07 4.1 "DLL 먼저"). 맵 안에서는 DLL 누락·구버전을 감지할 수 없다.
    static if ARCANA_SAVE_BACKEND then
        // api=3 추가 8개
        native ArcanaDocNew takes nothing returns integer
        native ArcanaDocAdd takes integer doc, string key, string value returns integer
        native ArcanaDocDrop takes integer doc returns integer
        native ArcanaSaveBegin takes string slot, integer doc, integer expectedRev returns integer
        native ArcanaLoadBegin takes string slot, string mapVersion, integer seat returns integer
        native ArcanaStatusBegin takes string requestId, integer seal returns integer
        // DLL 0.6.0(api=5): 홈페이지 계정 로그인. 결과는 ArcanaNetPoll/ArcanaNetResult(표시 이름 또는 실패 이유)
        native ArcanaLogin takes string loginId, string password returns integer
        // DLL 0.8.1: 진단 줄을 DLL 로그(%TEMP%\ArcanaSaveNet\savenet3-<pid>.log)에 바로 쓴다(게임 상태에 영향 없음)
        native ArcanaLog takes string line returns nothing
        // DLL 0.9.0: 저장 실패 증거 파일(문서\ArcanaSave\*.arcsave). 마지막 실패한 저장 / 맵이 만든 지금 데이터 문서(소비됨). 경로를 돌려준다
        native ArcanaSaveClaim takes string reason returns string
        native ArcanaSaveClaimDoc takes integer doc, string reason returns string
        native ArcanaLoadPackets takes integer id returns integer
        native ArcanaLoadPacket takes integer id, integer index returns string
        // api=2 와 같은 이름의 결과 조회 native. api=3 DLL이 핸들 범위로 api=3 요청을 처리한다.
        native ArcanaNetVersion takes nothing returns string
        native ArcanaNetPoll takes integer id returns integer
        native ArcanaNetResult takes integer id returns string
        native ArcanaNetError takes integer id returns integer
        native ArcanaNetRevision takes integer id returns integer
        native ArcanaNetRequestId takes integer id returns string
        native ArcanaNetRelease takes integer id returns integer
        native ArcanaNetRetry takes integer id returns integer
    endif

    // 저장 진단 기록. JN 판에서는 아무것도 하지 않는다.
    function ArcanaSaveTrace takes string s returns nothing
        static if ARCANA_SAVE_BACKEND then
            call ArcanaLog(s)
        endif
    endfunction

    // 하위 판 차이를 로그로 남기는 용도다(07 4.1). 호환 판정에는 쓰지 않는다.
    function ArcanaSaveDllVersion takes nothing returns string
        static if ARCANA_SAVE_BACKEND then
            return ArcanaNetVersion()
        else
            return "jn"
        endif
    endfunction

    // 맵 버전·좌석은 매 로드에 넘긴다(07 4.4). JN 판에서는 항상 0(요청 없음)이다.
    function ArcanaSaveLoadMain takes integer seat returns integer
        static if ARCANA_SAVE_BACKEND then
            return ArcanaLoadBegin("main", ARCANA_MAP_VERSION, seat)
        else
            return 0
        endif
    endfunction

endlibrary
