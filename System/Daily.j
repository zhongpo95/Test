library Daily initializer init requires Stash, UIQuest
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
            call StashSave(pid:PLAYER_DATA, "Totaldaily", StashLoad(pid:PLAYER_DATA,"Totaldaily","0"))
            //출석 보상
            if GetLocalPlayer() == DzGetTriggerSyncPlayer() then
                call BJDebugMsg("출석 보상!")
            endif
            /* 출석보상라인 */

            if GetLocalPlayer() == DzGetTriggerSyncPlayer() then
                call JNDailySave(MapName, GetPlayerName(Player(pid)), MapApi, "Default String", "daily")
                /*일퀘 리셋*/
                //call TodayReset(pid)
            endif
        else
            if JNUse( ) then
                if GetLocalPlayer() == DzGetTriggerSyncPlayer() then
                    call BJDebugMsg("이미 출석함")
                endif
            else
                if GetLocalPlayer() == DzGetTriggerSyncPlayer() then
                    call BJDebugMsg("서버에 연결되지 않았습니다.")
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