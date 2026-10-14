library Daily initializer init requires Stash, UIQuest, ArcanaSaveConfig, ArcanaStashNet
    globals
    endglobals

    function Deilycheck takes integer pid returns nothing
        local string str = ""
        if GetLocalPlayer() == Player(pid) then
            set str=JNDailyCheckToday(MapName, GetPlayerName(Player(pid)), MapApi, "Default String", "daily")
            call DzSyncData("Day_Sync", str)
        endif
    endfunction
    
    private function Deilycheck_Sync takes nothing returns nothing
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
                static if ARCANA_SAVE_BACKEND then
                    // 출석 자체는 단계 6까지 JN 에 남는다. 연결 문구만 Arcana 저장 준비 상태로 고른다(06 12.2).
                    if ArcanaStashNetIsReady(pid) then
                        call VJDebugMsg("이미 출석함")
                    else
                        call VJDebugMsg("서버에 연결되지 않았습니다.")
                    endif
                else
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
        local trigger t
        set t = CreateTrigger()
        call TriggerAddAction(t, function Deilycheck_Sync)
        call DzTriggerRegisterSyncData(t, "Day_Sync", false)
        set t = null
    endfunction
endlibrary