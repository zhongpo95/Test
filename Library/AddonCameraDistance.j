library AddonCameraDistance initializer main

    globals
        //카메라 - 시야 적용 간격 (추천 = 1.00초 간격)
        private constant real CAMERA_TIMEOUT = 1.00
        //카메라 - 적용될 시야 거리 (워크래프트 기본 = 1650)
        private constant real CAMERA_DISTANCE = 3500.00
        //카메라 변화 - 시야 변화 기간 (즉시 변화 = 0.00초)
        private constant real CAMERA_TRANSITION_TIMEOUT = 0.50
    endglobals
    
    private function Action takes nothing returns nothing
        call SetCameraField( CAMERA_FIELD_TARGET_DISTANCE, CAMERA_DISTANCE, CAMERA_TRANSITION_TIMEOUT )
    endfunction
    
    private function main takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t, function Action)
        call TriggerRegisterTimerEvent(t,CAMERA_TIMEOUT,true)
        set t = null
    endfunction
endlibrary