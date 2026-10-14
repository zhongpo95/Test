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
