/*
    FileSave
    
        -파일저장시 다이얼로그를 띄워 취소시킵니다.
        
*/
//! runtextmacro 콘텐츠("FileSave")
globals
    dialog SaveDialog
endglobals

//! runtextmacro 틱("FileSaveT")
//! runtextmacro 틱_끝()
    
//! runtextmacro 이벤트_틱이_종료되면_발동("FileSaveT")
    call DialogDisplay( GetLocalPlayer(), SaveDialog, false )
//! runtextmacro 이벤트_끝()

function FileSave_Actions takes nothing returns nothing
    local dialog d = DialogCreate()
    local FileSaveT t = FileSaveT.Create()
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 60.0, "|cffFF0202Warning) |c00DFFB4F워크래프트3 기본 파일 세이브 기능은 사용이 불가능합니다! -save 명령어를 이용하세요.|r")
    call DialogDisplay( GetLocalPlayer(), SaveDialog, true )
    call t.Start(0.00,false)
endfunction

//! runtextmacro 이벤트_맵이_로딩되면_발동()
    local trigger t = CreateTrigger()
    set SaveDialog = DialogCreate()
    call TriggerRegisterGameEvent(t, EVENT_GAME_SAVE)
    call TriggerAddAction( t, function FileSave_Actions )
    set t = null
//! runtextmacro 이벤트_끝()
//! runtextmacro 콘텐츠_끝()