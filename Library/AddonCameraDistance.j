library AddonCameraDistance initializer main

    globals
        //카메라 - 시야 적용 간격 (추천 = 1.00초 간격)
        private constant real CAMERA_TIMEOUT = 1.00
        //카메라 - 적용될 시야 거리 (워크래프트 기본 = 1650)
        private constant real CAMERA_DISTANCE = 3500.00
        //카메라 변화 - 시야 변화 기간 (즉시 변화 = 0.00초)
        private constant real CAMERA_TRANSITION_TIMEOUT = 0.50
        boolean array arrayPlayerCameraBoolean
    endglobals
    
    private function Action takes nothing returns nothing
        if arrayPlayerCameraBoolean[GetPlayerId(GetLocalPlayer())] == false then
            call SetCameraField( CAMERA_FIELD_TARGET_DISTANCE, CAMERA_DISTANCE, CAMERA_TRANSITION_TIMEOUT )
        endif
    endfunction
    
    private function main takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t, function Action)
        call TriggerRegisterTimerEvent(t,CAMERA_TIMEOUT,true)
        set arrayPlayerCameraBoolean[0] = false
        set arrayPlayerCameraBoolean[1] = false
        set arrayPlayerCameraBoolean[2] = false
        set arrayPlayerCameraBoolean[3] = false
        set arrayPlayerCameraBoolean[4] = false
        set arrayPlayerCameraBoolean[5] = false
        set t = null
    endfunction
endlibrary

library SMCamera
    //*********************************************************************
    //* 카메라 - 확장된 카메라 함수들을 가지고 있습니다. by escaco
    //* ----------
    //*
    //* (vJass 필요)
    //*
    //*
    //********************************************************************
            
            globals
                private real array camtx[15]
                private real array camty[15]
                private real array camtz[15]
                private real array camex[15]
                private real array camey[15]
                private real array camez[15]
            endglobals
    
            function SetCameraTargetPositionForPlayer takes player p, real x, real y, real z returns nothing
                local integer i = GetPlayerId(p)
                set camtx[i] = x
                set camty[i] = y
                set camtz[i] = z
            endfunction
    
            function SetCameraEyePositionForPlayer takes player p, real x, real y, real z returns nothing
                local integer i = GetPlayerId(p)
                set camex[i] = x
                set camey[i] = y
                set camez[i] = z
            endfunction
            
            function AdjustCameraSettingsForPlayer takes player p, real d returns nothing
                local integer i = GetPlayerId(p)
                local real dx = camtx[i]-camex[i]
                local real dy = camty[i]-camey[i]
                local real dz = camtz[i]-camez[i]
                local real dist = SquareRoot(Pow(dx,2) + Pow(dy,2) + Pow(dz,2))
                local real zangle = Atan2(dz,dist)*bj_RADTODEG
                local real angle = Atan2(dy,dx)*bj_RADTODEG
                call PanCameraToTimedForPlayer(p,camtx[i],camty[i],d)
                call SetCameraFieldForPlayer(p,CAMERA_FIELD_ZOFFSET,camtz[i],d)
                call SetCameraFieldForPlayer(p,CAMERA_FIELD_ROTATION,angle,d)
                call SetCameraFieldForPlayer(p,CAMERA_FIELD_TARGET_DISTANCE,dist,d)
                call SetCameraFieldForPlayer(p,CAMERA_FIELD_ANGLE_OF_ATTACK,zangle,d)
            endfunction
            
    endlibrary
//    [출처] [vjass]워크래프트의 한계를 뚫어보자 - 카메라편 (워크래프트3 리포지드 유즈맵 포럼 [W3UMF]) | 작성자 동동주