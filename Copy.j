scope SimpleTest initializer onInit

    globals
        private trigger DOWNLOAD_CALLBACK = CreateTrigger( )
        private trigger UPLOAD_CALLBACK = CreateTrigger( )
        
        private stash array PLAYER_DATA
    endglobals

    private function downloadCallback takes nothing returns nothing
        local player user = JNStashNetGetPlayer( )
        
        if JNStashNetGetFinished( ) then
            if JNStashNetGetResult( ) then
                call BJDebugMsg( JNStashNetGetMessage( ) )
                set PLAYER_DATA[GetPlayerId(user)] = JNStashNetGetStash( )
                call StashPrint( PLAYER_DATA[GetPlayerId(user)] )
            else
                call BJDebugMsg( JNStashNetGetMessage( ) )
            endif
        else
            call BJDebugMsg( "로드 중 : " + I2S(JNStashNetGetProgress()) + "/" + I2S(JNStashNetGetMaximum()) )
        endif
    endfunction
    
    private function uploadCallback takes nothing returns nothing
        if JNStashNetGetFinished( ) then
            if JNStashNetGetResult( ) then
                call BJDebugMsg( "저장 성공!" )
            else
                call BJDebugMsg( "저장 실패! 이유 : " + JNStashNetGetMessage( ) )
            endif
        else
            call BJDebugMsg( JNStashNetGetMessage( ) )
        endif
    endfunction

    private function test takes nothing returns nothing
        local integer pid = GetPlayerId(GetTriggerPlayer())
        
        if not StashExists( pid:PLAYER_DATA ) then
            call JNStashNetDownloadUser( GetTriggerPlayer(), "??????", GetPlayerName(GetTriggerPlayer()), "??????", DOWNLOAD_CALLBACK )
        else
            call StashSave( pid:PLAYER_DATA, "value.prop.1", "asdf" )
            call StashSave( pid:PLAYER_DATA, "value.prop.5", "asdf" )
            call JNStashNetUploadUser( GetTriggerPlayer(), "??????", GetPlayerName(GetTriggerPlayer()), "??????", pid:PLAYER_DATA, UPLOAD_CALLBACK )
        endif
    endfunction

    private function onInit takes nothing returns nothing
        local trigger trig
        
        set trig = CreateTrigger( )
        call TriggerRegisterPlayerEvent( trig, Player(0), EVENT_PLAYER_END_CINEMATIC )
        call TriggerAddAction( trig, function test )
        
        call TriggerAddAction( DOWNLOAD_CALLBACK, function downloadCallback )
        call TriggerAddAction( UPLOAD_CALLBACK, function uploadCallback )
        
        set trig = null
    endfunction

endscope