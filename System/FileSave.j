/*
    FileSave
    
        -파일저장시 다이얼로그를 띄워 취소시킵니다.
        
*/
scope FileSave
globals
    dialog SaveDialog
endglobals

private function EffectFunction takes nothing returns nothing
    call DialogDisplay( GetLocalPlayer(), SaveDialog, false )
endfunction

function FileSave_Actions takes nothing returns nothing
    local dialog d = DialogCreate()
    local tick t = tick.create(0)
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 60.0, "|cffFF0202Warning) |cffDFFB4F워크래프트3 기본 파일 세이브 기능은 사용이 불가능합니다! -save 명령어를 이용하세요.|r")
    call DialogDisplay( GetLocalPlayer(), SaveDialog, true )
    call t.start( 0.0, false, function EffectFunction ) 
endfunction
 
private struct TEvMapLoadFileSave extends array
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t, function thistype.Action)
        call TriggerRegisterTimerEvent(t, 0.04, false)
        set t = null
    endmethod
    private static method Action takes nothing returns nothing
    local trigger t = CreateTrigger()
    set SaveDialog = DialogCreate()
    call TriggerRegisterGameEvent(t, EVENT_GAME_SAVE)
    call TriggerAddAction( t, function FileSave_Actions )
    set t = null
    endmethod
endstruct
endscope