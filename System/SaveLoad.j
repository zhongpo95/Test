scope Load initializer onInit

    globals
        trigger DOWNLOAD_CALLBACK = CreateTrigger( )
        trigger UPLOAD_CALLBACK = CreateTrigger( )
        
        stash array PLAYER_DATA
    endglobals

    private function downloadCallback takes nothing returns nothing
        local player user = JNStashNetGetPlayer()
        local integer pid
        local integer i = 0
        local integer j = 0
        local string str = null
        
        if JNStashNetGetFinished( ) then
            if JNStashNetGetResult( ) then
                set pid = GetPlayerId(user)
                set PLAYER_DATA[pid] = JNStashNetGetStash( )
                call JNObjectMapInit(MapName,MapApi)
                
                //슬롯 이미지 세팅
                set str = StashLoad(PLAYER_DATA[pid], "슬롯1", "없음")
                if str != "없음" and str != null then
                    call DzFrameSetTexture(FP_SL[1], "UI_PickSelect1Hero"+str+".blp", 0)
                    set str = null
                endif
                set str = StashLoad(PLAYER_DATA[pid], "슬롯2", "없음")
                if str != "없음" and str != null then
                    call DzFrameSetTexture(FP_SL[2], "UI_PickSelect1Hero"+str+".blp", 0)
                    set str = null
                endif
                set str = StashLoad(PLAYER_DATA[pid], "슬롯3", "없음")
                if str != "없음" and str != null then
                    call DzFrameSetTexture(FP_SL[3], "UI_PickSelect1Hero"+str+".blp", 0)
                    set str = null
                endif
                //빅휠 카운트
                set str = StashLoad(PLAYER_DATA[pid], "BigWheelCount", "0" )

                /*
                set str = StashLoad(PLAYER_DATA[pid], "슬롯4", "없음")
                if str != "없음" and str != null then
                    call DzFrameSetTexture(FP_SL[4], "UI_PickSelect1Hero"+str+".blp", 0)
                    set str = null
                endif
                */
                set j = 0
                loop
                    set str = StashLoad(PLAYER_DATA[pid], "창고"+I2S(j), "없음")
                    if str != "없음" and str != null then
                        call AddStItem(pid,j, str)
                        set str = null
                    else
                    endif
                    set j = j + 1
                exitwhen j == 100
                endloop
                
                
            else
                set pid =GetPlayerId(user)
                set PLAYER_DATA[pid] = CreateStash()
            /*
                set pid = 0
                set PLAYER_DATA[pid] = CreateStash()
                set pid = 1
                set PLAYER_DATA[pid] = CreateStash()
                set pid = 2
                set PLAYER_DATA[pid] = CreateStash()
                set pid = 3
                set PLAYER_DATA[pid] = CreateStash()
                */
            endif
        else
            //call VJDebugMsg( "로드 중 : " + I2S(JNStashNetGetProgress()) + "/" + I2S(JNStashNetGetMaximum()) )
        endif
    endfunction
    
    private function uploadCallback takes nothing returns nothing
        if JNStashNetGetFinished( ) then
            if JNStashNetGetResult( ) then
                call VJDebugMsg( "저장 성공!" )
            else
                call VJDebugMsg( "저장 실패! 이유 : " + JNStashNetGetMessage( ) )
            endif
        else
            //call VJDebugMsg( JNStashNetGetMessage( ) )
        endif
    endfunction

    private function upload takes nothing returns nothing
        local integer pid = GetPlayerId(GetTriggerPlayer())
        local string str = I2S(PlayerSlotNumber[pid])
        local integer i = 0
        call StashSave(PLAYER_DATA[pid], "슬롯"+ str + ".E0", Eitem[pid][0])
        if Eitem[pid][1] != null then
            call StashSave(PLAYER_DATA[pid], "슬롯"+ str + ".E1", Eitem[pid][1])
        endif
        /*
        call StashSave(PLAYER_DATA[pid], "슬롯"+ str + ".E2", Eitem[pid][2])
        call StashSave(PLAYER_DATA[pid], "슬롯"+ str + ".E3", Eitem[pid][3])
        */
        //call StashSave(PLAYER_DATA[pid], "슬롯"+ str + ".E4", Eitem[pid][4])

        call StashSave(PLAYER_DATA[pid], "슬롯"+ str + ".E5", Eitem[pid][5])
        
        if Eitem[pid][6] != null then
            call StashSave(PLAYER_DATA[pid], "슬롯"+ str + ".E6", Eitem[pid][6])
        endif
        if Eitem[pid][7] != null then
            call StashSave(PLAYER_DATA[pid], "슬롯"+ str + ".E7", Eitem[pid][7])
        endif
        if Eitem[pid][8] != null then
            call StashSave(PLAYER_DATA[pid], "슬롯"+ str + ".E8", Eitem[pid][8])
        endif
        if Eitem[pid][9] != null then
            call StashSave(PLAYER_DATA[pid], "슬롯"+ str + ".E9", Eitem[pid][9])
        endif
        if Eitem[pid][10] != null then
            call StashSave(PLAYER_DATA[pid], "슬롯"+ str + ".E10", Eitem[pid][10])
        endif
        if Eitem[pid][11] != null then
            call StashSave(PLAYER_DATA[pid], "슬롯"+ str + ".E11", Eitem[pid][11])
        endif
        if Eitem[pid][12] != null then
            call StashSave(PLAYER_DATA[pid], "슬롯"+ str + ".E12", Eitem[pid][12])
        endif
        
        call JNStashNetUploadUser( GetTriggerPlayer(), MapName, GetPlayerName(GetTriggerPlayer()), MapApi, PLAYER_DATA[pid], UPLOAD_CALLBACK )
    endfunction

    private function download takes nothing returns nothing
        local integer i = 0
        local integer j = 0
        
        loop
            if GetPlayerController(Player(i)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
                call JNStashNetDownloadUser( Player(i), MapName, GetPlayerName(Player(i)), MapApi, DOWNLOAD_CALLBACK )
                set j = 0
                loop
                    set Eitem[i][j] = null
                    set j = j + 1
                exitwhen j == 13
                endloop
            endif
            set i = i + 1
        exitwhen i == bj_MAX_PLAYERS
        endloop
    endfunction
    
    private function onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer index = 0
        
        call TriggerRegisterTimerEventSingle( t, 3.00 )
        call TriggerAddAction( t, function download )
        
        set t = CreateTrigger()
        
        loop
            set PlayerName[index] = GetPlayerName(Player(index))
            call TriggerRegisterPlayerChatEvent(t, Player(index), "-save", false)
            set index = index + 1
            exitwhen index == bj_MAX_PLAYERS
        endloop
        call TriggerAddAction(t, function upload)
        
        call TriggerAddAction( DOWNLOAD_CALLBACK, function downloadCallback )
        call TriggerAddAction( UPLOAD_CALLBACK, function uploadCallback )
        
        set t = null
    endfunction

endscope