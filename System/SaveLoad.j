scope Load initializer onInit

    globals
        trigger DOWNLOAD_CALLBACK = CreateTrigger( )
        trigger UPLOAD_CALLBACK = CreateTrigger( )
        
        stash array PLAYER_DATA
    endglobals

    private function IsValidPickSlotNumber takes integer slotNumber returns boolean
        return slotNumber >= 1 and slotNumber <= 3
    endfunction

    private function RefreshPickSlotImage takes integer pid, integer slotNumber returns nothing
        local string str = StashLoad(PLAYER_DATA[pid], "슬롯"+I2S(slotNumber), "없음")
        if str != "없음" and str != null and str != "" then
            call DzFrameSetTexture(FP_SL[slotNumber], "UI_PickSelect2.blp", 0)
        endif
        set str = null
    endfunction

    private function SaveEquippedItems takes integer pid, integer slotNumber returns nothing
        local integer i = 0
        loop
            if Eitem[pid][i] == null or Eitem[pid][i] == "" then
                call StashSave(PLAYER_DATA[pid], "슬롯"+I2S(slotNumber)+".E"+I2S(i), "0")
            else
                call StashSave(PLAYER_DATA[pid], "슬롯"+I2S(slotNumber)+".E"+I2S(i), Eitem[pid][i])
            endif
            exitwhen i == EQUIP_SLOT_MAX
            set i = i + 1
        endloop
    endfunction

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
                set i = 1
                loop
                    call RefreshPickSlotImage(pid, i)
                    set i = i + 1
                exitwhen i > 3
                endloop
                //빅휠 카운트
                set str = StashLoad(PLAYER_DATA[pid], "BigWheelCount", "0" )
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
        local integer slotNumber = PlayerSlotNumber[pid]
        /*
        if JNGetConnectionState() == 1280266064 then
            call BJDebugMsg("현재 싱글 플레이중입니다.")
        elseif JNGetConnectionState() == 1413697614 then
            call BJDebugMsg("현재 LAN에서 중입니다.")
        elseif JNGetConnectionState() == 1112425812 then
            call BJDebugMsg("현재 배틀넷에서 플레이중입니다.")
        */
        if IsValidPickSlotNumber(slotNumber) then
            call SaveEquippedItems(pid, slotNumber)
            call JNStashNetUploadUser( GetTriggerPlayer(), MapName, GetPlayerName(GetTriggerPlayer()), MapApi, PLAYER_DATA[pid], UPLOAD_CALLBACK )
        else
            call VJDebugMsg("캐릭터 선택 후 저장할 수 있습니다.")
        endif
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
                exitwhen j > EQUIP_SLOT_MAX
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
