/* CameraShaker.setShake( real 세기 )
화면을 (세기)의 힘으로 타격합니다.
CameraShaker.setShakeForPlayer( player 플레이어, real 세기 )
(플레이어)의 화면을 (세기)의 힘으로 타격합니다.

※이미 화면이 더 강한 힘으로 흔들리는 중이었다면 위 두 함수는 효과가 무시됩니다.

CameraShaker.stopShake()
화면을 그만 흔듭니다.
CameraShaker.stopShakeForPlayer()
플레이어의 화면을 그만 흔듭니다.

CameraShaker.setShakePosition( real 세기, real X, real Y, real 최소 거리, real 최대 거리 )
(X), (Y)좌표를 (세기)의 힘으로 진동시킵니다. 진동은 0~(최소 거리)까지 강하게, (최대 거리)까지 영향을 줍니다.


진동점과의 거리에 따른 세기 변화
거리:   0    최소 거리     최대 거리
세기: 100%--100%~~~~~~0% */

library CameraShaker initializer onInit

    globals
        private constant integer MAX_PLAYER = 12
    
        private timer CS_T
        private real array CS_V
        private integer CS_U
        private real CS_S
    endglobals
    
    private function Shake takes nothing returns nothing
        set CS_U = CS_U * -1
        call SetCameraField( CAMERA_FIELD_ZOFFSET, CS_S * CS_U, 0.00 )
        set CS_S = CS_S - CS_S / 5
    endfunction
    
    private function onInit takes nothing returns nothing
        set CS_T = CreateTimer()
        set CS_U = 1
        set CS_S = 0
        call TimerStart(CS_T, 0.04, true, function Shake)
    endfunction
    
    struct CameraShaker
        static method setShakeForPlayer takes player p, real v returns nothing
            if GetLocalPlayer() == p then
                if CS_S < v then
                    set CS_S = v
                endif
            endif
        endmethod
        static method setShake takes real v returns nothing
            if CS_S < v then
                set CS_S = v
            endif
        endmethod
        static method stopShake takes nothing returns nothing
            set CS_S = 0
        endmethod
        static method stopShakeForPlayer takes player p returns nothing
            if GetLocalPlayer() == p then
                set CS_S = 0
            endif
        endmethod
        static method setShakePosition takes real v, real x, real y, real r, real d returns nothing
            local real dx = x - GetCameraTargetPositionX()
            local real dy = y - GetCameraTargetPositionY()
            local real dist = SquareRoot( dx * dx + dy * dy ) - r
            if dist <= 0 then
                set dist = 1
            else
                if d - r <= 0 then
                    set dist = 0
                else
                    set dist = 1 - ( dist / (d - r) )
                    if dist <= 0 then
                        set dist = 0
                    endif
                endif
            endif
            set CS_S = v * dist
        endmethod
    endstruct
    
endlibrary