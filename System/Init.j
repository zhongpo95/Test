scope vJDKAddonRevealAll initializer main
private function main takes nothing returns nothing
call FogEnable(false)
call FogMaskEnable(false)
endfunction
endscope
//최대이동속도 조절
library MoveSpeedLimit requires JNMemory

    function SetMaxMoveSpeedLimit takes real msLimit returns nothing
        local integer pGameDll = JNGetModuleHandle("game.dll")
        call JNMemorySetReal(pGameDll + 0xD38804, msLimit)
        call JNMemorySetReal(JNMemoryGetInteger(pGameDll + 0xD04438) + 0x80, msLimit)
    endfunction
    private struct TEvMapLoadMoveSpeedLimit extends array
        private static method onInit takes nothing returns nothing
            local trigger t = CreateTrigger()
            call TriggerAddAction(t, function thistype.Action)
            call TriggerRegisterTimerEvent(t, 0.04, false)
            set t = null
        endmethod
        private static method Action takes nothing returns nothing
        call SetMaxMoveSpeedLimit(560)
        endmethod
    endstruct
endlibrary

//초기 셋팅 트리거
scope SetInit initializer Init
    globals
        unit array MainUnit                         //시점의 기준이 될 유닛
        //소모품
        item array PlayerItem1
        item array PlayerItem2
        item array PlayerItem3
        item array PlayerItem4
    endglobals
    
    private function Main takes nothing returns nothing
        call MapResetAll(1)
        call MapResetAll(2)
        call MapResetAll(3)
        call MapResetAll(4)
        call MapResetAll(5)
        call MapResetAll(6)
    endfunction


    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        
        call TriggerRegisterTimerEventSingle( t, 1.0 )
        call TriggerAddAction( t, function Main )
    endfunction
endscope

scope SetInit2
    //스페이스바 이동위치설정
    private function Main takes nothing returns nothing
        call SetCameraQuickPosition(GetUnitX(MainUnit[GetPlayerId(GetLocalPlayer())]), GetUnitY(MainUnit[GetPlayerId(GetLocalPlayer())]))
    endfunction
    private struct TEvMapLoadSetInit2 extends array
        private static method onInit takes nothing returns nothing
            local trigger t = CreateTrigger()
            call TriggerAddAction(t, function thistype.Action)
            call TriggerRegisterTimerEvent(t, 0.04, false)
            set t = null
        endmethod
        private static method Action takes nothing returns nothing
         local tick t = tick.create(0)
         call t.start( 0.02, true, function Main ) 
        endmethod
    endstruct
endscope
