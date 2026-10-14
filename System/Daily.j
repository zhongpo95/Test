// 출석 확인. JN 판은 JNDaily(닉네임 기준)와 Day_Sync, Arcana 판은 로드 때 받은 서버 날짜(KST)와 Stash 키 daily.last 로 판정한다(09 2.1).
library Daily initializer init requires Stash, UIQuest, ArcanaSaveConfig, ArcanaStashNet
    globals
    endglobals

    function Deilycheck takes integer pid returns nothing
        static if ARCANA_SAVE_BACKEND then
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
        if StashLoad(PLAYER_DATA[pid], "daily.last", "") == I2S(day) then
            call VJDebugMsg("이미 출석함")
            return
        endif
        call StashSave(PLAYER_DATA[pid], "daily.last", I2S(day))
        call StashSave(PLAYER_DATA[pid], "Totaldaily", I2S(S2I(StashLoad(PLAYER_DATA[pid],"Totaldaily","0")) + 1 ) )
        call StashSave(PLAYER_DATA[pid], "BigWheelCount", "3" )
        call VJDebugMsg("출석 보상!")
        else
        local string str = ""
        if GetLocalPlayer() == Player(pid) then
            set str=JNDailyCheckToday(MapName, GetPlayerName(Player(pid)), MapApi, "Default String", "daily")
            call DzSyncData("Day_Sync", str)
        endif
        endif
    endfunction
    
    private function Deilycheck_Sync takes nothing returns nothing
        static if ARCANA_SAVE_BACKEND then
        // Arcana 판은 Day_Sync 를 쓰지 않는다(등록도 하지 않음, 09 2.1).
        else
        local integer pid = GetPlayerId(DzGetTriggerSyncPlayer())
        local string data = DzGetTriggerSyncData()
        //출석 오늘처음
        if data == "데이터 없음" then
            /*출석 일수 저장*/
            if GetLocalPlayer() == DzGetTriggerSyncPlayer() then
                call StashSave(PLAYER_DATA[pid], "Totaldaily", I2S(S2I(StashLoad(PLAYER_DATA[pid],"Totaldaily","0")) + 1 ) )
            endif
            //출석 보상
            if GetLocalPlayer() == DzGetTriggerSyncPlayer() then
                call VJDebugMsg("출석 보상!")
                call StashSave(PLAYER_DATA[pid], "BigWheelCount", "3" )
            endif


            /* 출석보상라인 */

            if GetLocalPlayer() == DzGetTriggerSyncPlayer() then
                call JNDailySave(MapName, GetPlayerName(Player(pid)), MapApi, "Default String", "daily")
                /*일퀘 리셋*/
                //call TodayReset(pid)
            endif
        else
            if GetLocalPlayer() == DzGetTriggerSyncPlayer() then
                if JNObjectCharacterServerConnectCheck() then
                    call VJDebugMsg("이미 출석함")
                else
                    call VJDebugMsg("서버에 연결되지 않았습니다.")
                endif
            endif
        endif
        endif
    endfunction

    private function init takes nothing returns nothing
        static if ARCANA_SAVE_BACKEND then
        // Arcana 판: Day_Sync 트리거를 만들지 않는다.
        else
        local trigger t
        set t = CreateTrigger()
        call TriggerAddAction(t, function Deilycheck_Sync)
        call DzTriggerRegisterSyncData(t, "Day_Sync", false)
        set t = null
        endif
    endfunction
endlibrary