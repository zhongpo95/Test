//! textmacro 콘텐츠_모두_보이기
scope vJDKAddonRevealAll initializer main
private function main takes nothing returns nothing
call FogEnable(false)
call FogMaskEnable(false)
endfunction
endscope
//! endtextmacro
//! textmacro 콘텐츠_모두_안보이기
scope vJDKAddonRevealAll initializer main
private function main takes nothing returns nothing
call FogEnable(true)
call FogMaskEnable(true)
endfunction
endscope
//! endtextmacro
//! textmacro 콘텐츠_게임시간_고정 takes TIME
scope vJDKAddonFixDayTime initializer main
private function main takes nothing returns nothing
call SetFloatGameState(GAME_STATE_TIME_OF_DAY, $TIME$)
call SuspendTimeOfDay(true)
endfunction
endscope
//! endtextmacro
//! textmacro 콘텐츠_게임시간_설정 takes TIME
scope vJDKAddonSetDayTime initializer main
private function main takes nothing returns nothing
call SetFloatGameState(GAME_STATE_TIME_OF_DAY, $TIME$)
endfunction
endscope
//! endtextmacro
//! textmacro 콘텐츠_부드러운_카메라 takes AMOUNT
scope vJDKAddonSmoothCamera initializer main
private function main takes nothing returns nothing
call CameraSetSmoothingFactor($AMOUNT$)
endfunction
endscope
//! endtextmacro
//! textmacro 콘텐츠_핸들_관리자 takes SHORT
scope vJDKAddonHandleChecker initializer main
    globals
        private integer NUSU_LIMITBREAK = 0
        private integer PREV_MAXNUSU = 0
        private integer NUSU_FIRST = 0
        private integer NUSU_TIME = 0
        private integer NUSU_TIME_ALL = 0
        private location NUSU_HOLDER = null
    endglobals
    private function Action takes nothing returns nothing
        debug local location l = Location(0,0)
        debug local integer chid = GetHandleId(l)
        debug set NUSU_TIME = NUSU_TIME + 1
        debug set NUSU_TIME_ALL = NUSU_TIME_ALL + 1
        debug if chid > PREV_MAXNUSU then
            debug set NUSU_LIMITBREAK = NUSU_LIMITBREAK + 1
            debug if $SHORT$ then
                debug call DisplayTextToPlayer(GetLocalPlayer(),0,0,"핸들 알림 : "+I2S(chid-NUSU_FIRST)+"(+"+I2S(chid-PREV_MAXNUSU)+")")
            debug else
                debug call DisplayTextToPlayer(GetLocalPlayer(),0,0,"핸들 최고치 "+I2S(NUSU_LIMITBREAK)+"차 경신!")
                debug call DisplayTextToPlayer(GetLocalPlayer(),0,0,"현재 시간 : "+I2S(NUSU_TIME_ALL)+"s")
                debug call DisplayTextToPlayer(GetLocalPlayer(),0,0,"경신에 걸린 시간 : "+I2S(NUSU_TIME)+"s")
                debug call DisplayTextToPlayer(GetLocalPlayer(),0,0,"증가량 : "+I2S(chid-PREV_MAXNUSU))
                debug call DisplayTextToPlayer(GetLocalPlayer(),0,0,"경신 값 : "+I2S(chid-NUSU_FIRST))
                debug call DisplayTextToPlayer(GetLocalPlayer(),0,0,"이전 값 : "+I2S(PREV_MAXNUSU-NUSU_FIRST))
            debug endif
            debug set PREV_MAXNUSU = chid
            debug set NUSU_TIME = 0
        debug endif
        debug if NUSU_HOLDER != null then
            debug call RemoveLocation(NUSU_HOLDER)
        debug else
            debug set NUSU_FIRST = chid
        debug endif
        debug set NUSU_HOLDER = l
        debug set l = null
    endfunction
    private function main takes nothing returns nothing
        debug local trigger t = CreateTrigger(  )
        debug call TriggerRegisterTimerEvent( t, 0.02, true )
        debug call TriggerAddAction( t, function Action )
        debug set t = null
        debug call VJContentMsg("작업_관리자")
    endfunction
endscope
//! endtextmacro