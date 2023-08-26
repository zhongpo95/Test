    //
    // 시스템
    //
//! textmacro 시스템 takes NAME
library $NAME$ requires vJDK
//! endtextmacro
//! textmacro 시스템_고급 takes NAME,OPTIONS
library $NAME$ requires vJDK,$OPTIONS$
//! endtextmacro
//! textmacro 시스템_끝
endlibrary
//! endtextmacro
    //
    // 콘텐츠
    //
//! textmacro 컨텐츠 takes NAME
scope $NAME$
//! endtextmacro
//! textmacro 컨텐츠_끝
endscope
//! endtextmacro
//! textmacro 콘텐츠 takes NAME
scope $NAME$
//! endtextmacro
//! textmacro 콘텐츠_끝
endscope
//! endtextmacro
    //
    // 커스텀 컨텐츠 이벤트
    //
//! textmacro 이벤트_맵이_로딩되기_직전에_발동
private struct MEvBeforeLoad extends array
    private static method onInit takes nothing returns nothing
//! endtextmacro
//! textmacro 이벤트_맵이_로딩되면_발동
private struct MEvAfterLoad extends array
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function thistype.Action)
        call TriggerRegisterTimerEvent(t,0.04,false)
        set t = null
    endmethod
    private static method Action takes nothing returns nothing
//! endtextmacro
//! textmacro 이벤트_N초마다_발동 takes NAME,N
private struct TEvPeriodic$NAME$ extends array
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function thistype.Action)
        call TriggerRegisterTimerEvent(t,$N$,true)
        set t = null
    endmethod
    private static method Action takes nothing returns nothing
//! endtextmacro
//! textmacro 이벤트_N초가_지나면_발동 takes NAME,N
private struct TEvAfter$NAME$ extends array
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function thistype.Action)
        call TriggerRegisterTimerEvent(t,$N$,false)
        set t = null
    endmethod
    private static method Action takes nothing returns nothing
//! endtextmacro
//! textmacro 이벤트_타이머_N초마다_발동 takes NAME,TIME,TITLE,SHOWTO
private struct TEvPTimer$NAME$ extends array
    private static timer PT$NAME$t = CreateTimer()
    private static timerdialog PTD$NAME$t = CreateTimerDialog(PT$NAME$t)
    private static method Wrapper takes nothing returns nothing
        call thistype.Action(PT$NAME$t,PTD$NAME$t)
    endmethod
    private static method Ready takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function thistype.Wrapper)
        call TriggerRegisterTimerExpireEvent(t,PT$NAME$t)
        set t = null
        call TimerStart(PT$NAME$t,$TIME$,true,null)
        call TimerDialogSetTitle(PTD$NAME$t,"$TITLE$")
        call TimerDialogDisplay(PTD$NAME$t,GetLocalPlayer()==$SHOWTO$)
    endmethod
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function thistype.Ready)
        call TriggerRegisterTimerEvent(t,0.04,false)
        set t = null
    endmethod
    private static method Action takes timer expired, timerdialog expireddialog returns nothing
//! endtextmacro
//! textmacro 이벤트_타이머_N초가_지나면_발동 takes NAME,TIME,TITLE,SHOWTO
private struct TEvATimer$NAME$ extends array
    private static timer AT$NAME$t = CreateTimer()
    private static timerdialog ATD$NAME$t = CreateTimerDialog(AT$NAME$t)
    private static method Wrapper takes nothing returns nothing
        call TimerDialogDisplay(ATD$NAME$t,false)
        call thistype.Action(AT$NAME$t,ATD$NAME$t)
    endmethod
    private static method Ready takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function thistype.Wrapper)
        call TriggerRegisterTimerExpireEvent(t,AT$NAME$t)
        set t = null
        call TimerStart(AT$NAME$t,$TIME$,false,null)
        call TimerDialogSetTitle(ATD$NAME$t,"$TITLE$")
        call TimerDialogDisplay(ATD$NAME$t,GetLocalPlayer()==$SHOWTO$)
    endmethod
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function thistype.Ready)
        call TriggerRegisterTimerEvent(t,0.04,false)
        set t = null
    endmethod
    private static method Action takes timer expired, timerdialog expireddialog returns nothing
//! endtextmacro
//! textmacro 이벤트_타이머가_종료되면_발동 takes NAME
globals
private timer $NAME$ = CreateTimer()
private timerdialog $NAME$Dialog = CreateTimerDialog($NAME$)
endglobals
private struct TEvTimer$NAME$ extends array
    private static method Wrapper takes nothing returns nothing
        call thistype.Action($NAME$,$NAME$Dialog)
    endmethod
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function thistype.Wrapper)
        call TriggerRegisterTimerExpireEvent(t,$NAME$)
        set t = null
    endmethod
    private static method Action takes timer expired, timerdialog expireddialog returns nothing
//! endtextmacro
//! textmacro 이벤트_구역에_입장하면_발동 takes NAME,SOURCE
private struct REvEnter$NAME$ extends array
    private static method Wrapper takes nothing returns nothing
        call thistype.Action(GetEnteringUnit(),gg_rct_$SOURCE$)
    endmethod
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function thistype.Wrapper)
        call TriggerRegisterEnterRectSimple( t, gg_rct_$SOURCE$ )
        set t = null
    endmethod
    private static method Action takes unit entering, rect enteringrect returns nothing
//! endtextmacro
//아래추가
//! textmacro 이벤트_구역에_나가면_발동 takes NAME,SOURCE
private struct LrvEnter$NAME$ extends array
    private static method Wrapper takes nothing returns nothing
        call thistype.Action(GetLeavingUnit(),gg_rct_$SOURCE$)
    endmethod
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function thistype.Wrapper)
        call TriggerRegisterLeaveRectSimple( t, gg_rct_$SOURCE$ )
        set t = null
    endmethod
    private static method Action takes unit entering, rect leavingrect returns nothing
//! endtextmacro
//! textmacro 이벤트_아무나_ESC를_누르면_발동
private struct APEvKeyPrsESC extends array
    private static method Wrapper takes nothing returns nothing
        call thistype.Action(GetTriggerPlayer())
    endmethod
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer i = 0
        call TriggerAddAction(t,function thistype.Wrapper)
        loop
            exitwhen i == bj_MAX_PLAYERS
            call TriggerRegisterPlayerEvent(t,Player(i),EVENT_PLAYER_END_CINEMATIC)
            set i = i + 1
        endloop
        set t = null
    endmethod
    private static method Action takes player this returns nothing
//! endtextmacro
//! textmacro 이벤트_플레이어가_ESC를_누르면_발동 takes WHO
private struct PEvKeyPrsESC$WHO$ extends array
    private static method Wrapper takes nothing returns nothing
        call thistype.Action(GetTriggerPlayer())
    endmethod
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function thistype.Wrapper)
        call TriggerRegisterPlayerEvent(t,Player($WHO$),EVENT_PLAYER_END_CINEMATIC)
        set t = null
    endmethod
    private static method Action takes player this returns nothing
//! endtextmacro
//! textmacro 이벤트_끝
    endmethod
endstruct
//! endtextmacro
    //
    // 시스템 이벤트(SYSEVENT)
    //
//! textmacro 게임_이벤트_발동 takes NAME
set CGEV_$NAME$ = 1
set CGEV_$NAME$ = 0
//! endtextmacro
//! textmacro 게임_이벤트 takes NAME
globals
real CGEV_$NAME$ = 0
endglobals
function TriggerRegister$NAME$GameEvent takes trigger t returns nothing
    call TriggerRegisterVariableEvent(t,"CGEV_$NAME$",EQUAL,1)
endfunction
//! endtextmacro
//! textmacro 이벤트_게임_이벤트가_발동되면_발동 takes EVENT
private struct GEv$EVENT$ extends array
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function thistype.Action)
        call TriggerRegister$EVENT$GameEvent(t)
        set t = null
    endmethod
    private static method Action takes nothing returns nothing
//! endtextmacro
//! textmacro 플레이어_이벤트_발동 takes NAME,PLAYER
set CPEV_$NAME$ = GetPlayerId($PLAYER$)+1
set CPEVA_$NAME$ = 1
set CPEVA_$NAME$ = 0
set CPEV_$NAME$ = 0
//! endtextmacro
//! textmacro 플레이어_이벤트 takes NAME
globals
real CPEV_$NAME$ = 0
real CPEVA_$NAME$ = 0
endglobals
function TriggerRegister$NAME$PlayerEvent takes trigger t, player p returns nothing
    call TriggerRegisterVariableEvent(t,"CPEV_$NAME$",EQUAL,GetPlayerId(p)+1)
endfunction
function TriggerRegister$NAME$AnyPlayerEvent takes trigger t returns nothing
    call TriggerRegisterVariableEvent(t,"CPEVA_$NAME$",EQUAL,1)
endfunction
//! endtextmacro
//! textmacro 이벤트_플레이어_이벤트가_발동되면_발동 takes EVENT
private struct PAEv$EVENT$ extends array
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function thistype.Action)
        call TriggerRegister$EVENT$AnyPlayerEvent(t)
        set t = null
    endmethod
    private static method Action takes nothing returns nothing
        local integer triggerplayerid = R2I(CPEV_$EVENT$) - 1
        local player triggerplayer = Player(triggerplayerid)
//! endtextmacro
//! textmacro 이벤트_특정_플레이어_이벤트가_발동되면_발동 takes EVENT,PLAYER
private struct PEv$EVENT$ extends array
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function thistype.Action)
        call TriggerRegister$EVENT$PlayerEvent(t,$PLAYER$)
        set t = null
    endmethod
    private static method Action takes nothing returns nothing
        local integer triggerplayerid = R2I(CPEV_$EVENT$) - 1
        local player triggerplayer = Player(triggerplayerid)
//! endtextmacro
//! textmacro 스테이지_이벤트_발동 takes NAME,INDEX,PARAM
set CFARG_$NAME$ = $PARAM$
set CFEV_$NAME$ = $INDEX$
set CFEVA_$NAME$ = 1
set CFEVA_$NAME$ = 0
set CFEV_$NAME$ = -1048576
set CFARG_$NAME$ = 0
call $PARAM$.destroy()
//! endtextmacro
//! textmacro 스테이지_이벤트 takes NAME
globals
real CFEV_$NAME$ = -1048576
real CFEVA_$NAME$ = 0
$NAME$Arg CFARG_$NAME$ = 0
endglobals
function TriggerRegister$NAME$AnyStageEvent takes trigger t returns nothing
    call TriggerRegisterVariableEvent(t,"CFEVA_$NAME$",EQUAL,1)
endfunction
function TriggerRegister$NAME$StageEvent takes trigger t, integer i returns nothing
    call TriggerRegisterVariableEvent(t,"CFEV_$NAME$",EQUAL,i)
endfunction
struct $NAME$Arg
    static thistype Null = 0
    method destroy takes nothing returns nothing
        if this == 0 then
            return
        endif
        call deallocate()
    endmethod
//! endtextmacro
//! textmacro 스테이지_이벤트_끝
endstruct
//! endtextmacro
//! textmacro 이벤트_스테이지_이벤트가_발동되면_발동 takes EVENT
private struct FAEv$EVENT$ extends array
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function thistype.Wrapper)
        call TriggerRegister$EVENT$AnyStageEvent(t)
        set t = null
    endmethod
    private static method Wrapper takes nothing returns nothing
        call Action(CFARG_$EVENT$,R2I(CFEV_$EVENT$))
    endmethod
    private static method Action takes $EVENT$Arg arg, integer stage returns nothing
//! endtextmacro
//! textmacro 이벤트_특정_스테이지_이벤트가_발동되면_발동 takes EVENT,NUM
private struct FEv$EVENT$$NUM$ extends array
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function thistype.Wrapper)
        call TriggerRegister$EVENT$StageEvent(t,$NUM$)
        set t = null
    endmethod
    private static method Wrapper takes nothing returns nothing
        call Action(CFARG_$EVENT$,R2I(CFEV_$EVENT$))
    endmethod
    private static method Action takes $EVENT$Arg arg, integer stage returns nothing
//! endtextmacro
    //
    // 시스템 변수(VARIABLE)
    //
//! textmacro 게임_변수 takes NAME,TYPE,INIT
globals
$TYPE$ Game_$NAME$ = $INIT$
endglobals
function SetGame$NAME$ takes $TYPE$ value returns nothing
set Game_$NAME$ = value
endfunction
function GetGame$NAME$ takes nothing returns $TYPE$
return Game_$NAME$
endfunction
function IsGame$NAME$ takes nothing returns $TYPE$
return Game_$NAME$
endfunction
//! endtextmacro
//! textmacro 플레이어_변수 takes NAME,TYPE,INIT
globals
$TYPE$ array Player_$NAME$
endglobals
function SetPlayer$NAME$ takes player p, $TYPE$ value returns nothing
set Player_$NAME$[GetPlayerId(p)] = value
endfunction
function GetPlayer$NAME$ takes player p returns $TYPE$
return Player_$NAME$[GetPlayerId(p)]
endfunction
function IsPlayer$NAME$ takes player p returns $TYPE$
return Player_$NAME$[GetPlayerId(p)]
endfunction
private struct PVar$NAME$Init extends array
    private static method onInit takes nothing returns nothing
        local integer i = bj_MAX_PLAYER_SLOTS
        loop
            exitwhen i == 0
            set i = i - 1
            set Player_$NAME$[i] = $INIT$
        endloop
    endmethod
endstruct
//! endtextmacro
globals
    hashtable VJDK_HANDLE_VAR = InitHashtable()
endglobals

//! textmacro 핸들_변수 takes NAME,TYPE,HASHFUNC,CLEARFUNC
globals
key Handle_$NAME$
endglobals
function Clear$NAME$ takes handle h returns nothing
call RemoveSaved$CLEARFUNC$(VJDK_HANDLE_VAR,Handle_$NAME$,GetHandleId(h))
endfunction
function Clear$NAME$ById takes integer i returns nothing
call RemoveSaved$CLEARFUNC$(VJDK_HANDLE_VAR,Handle_$NAME$,i)
endfunction
function Set$NAME$ takes handle h, $TYPE$ value returns nothing
call Save$HASHFUNC$(VJDK_HANDLE_VAR,Handle_$NAME$,GetHandleId(h),value)
endfunction
function Get$NAME$ takes handle h returns $TYPE$
return Load$HASHFUNC$(VJDK_HANDLE_VAR,Handle_$NAME$,GetHandleId(h))
endfunction
function Is$NAME$ takes handle h returns $TYPE$
return Load$HASHFUNC$(VJDK_HANDLE_VAR,Handle_$NAME$,GetHandleId(h))
endfunction
//! endtextmacro
//추가
//! textmacro 핸들_변수확장 takes NAME,TYPE,HASHFUNC,CLEARFUNC
function Set$NAME$ById takes integer i, $TYPE$ value returns nothing
call Save$HASHFUNC$(VJDK_HANDLE_VAR,Handle_$NAME$,i,value)
endfunction
function Get$NAME$ById takes integer i returns $TYPE$
return Load$HASHFUNC$(VJDK_HANDLE_VAR,Handle_$NAME$,i)
endfunction
//! endtextmacro