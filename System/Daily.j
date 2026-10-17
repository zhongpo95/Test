// 출석 확인. 로드 때 받은 서버 날짜(KST)와 저장 키 daily.last 로 판정한다(09 2.1).
library Daily initializer init requires Stash, UIQuest, ArcanaSaveConfig, ArcanaStashNet
    globals
    endglobals

    function Deilycheck takes integer pid returns nothing
        // Arcana 판(09 2.1): 출석 기록(daily.last)과 보상이 같은 저장 문서·같은 revision 에 들어간다. Stash 쓰기는 기존처럼 소유자 로컬.
        local integer day
        if GetLocalPlayer() != Player(pid) then
            return
        endif
        set day = ArcanaStashNetGetServerDay(pid)
        if not ArcanaStashNetIsReady(pid) then
            call VJDebugMsg("서버에 연결되지 않았습니다.")
            return
        endif
        if day == 0 then
            call VJDebugMsg("출석 정보를 받지 못했습니다.")
            return
        endif
        if ArcanaSaveGetInt(pid, ARCANA_SF_DAILYLAST) == day then
            call VJDebugMsg("이미 출석함")
            return
        endif
        call ArcanaSaveSetInt(pid, ARCANA_SF_DAILYLAST, day)
        call ArcanaSaveSetInt(pid, ARCANA_SF_TOTALDAILY, ArcanaSaveGetInt(pid, ARCANA_SF_TOTALDAILY) + 1)
        call ArcanaSaveSetInt(pid, ARCANA_SF_BIGWHEEL, 3)
        call VJDebugMsg("출석 보상!")
    endfunction
    
    private function Deilycheck_Sync takes nothing returns nothing
        // Arcana 판은 Day_Sync 를 쓰지 않는다(등록도 하지 않음, 09 2.1).
    endfunction

    private function init takes nothing returns nothing
        // Arcana 판: Day_Sync 트리거를 만들지 않는다.
    endfunction
endlibrary