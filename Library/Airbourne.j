//GetUnitHeight(대상 유닛) : 대상 유닛의 고도(오브젝트상 기본 고도값을 뺀)값을 반환합니다.
//
//SetUnitHeight(대상 유닛,값) : 대상 유닛의 고도(오브젝트상 기본 고도값을 뺀)값을 설정합니다.
//
//GetUnitZVelo(대상 유닛) : 대상 유닛의 Z축 속력을 반환합니다.
//
//SetUnitZVelo(대상 유닛, 값) : 대상 유닛의 Z축 속력을 설정합니다. 양수값일때 위로 뜹니다.
//
//GetUnitGravity(대상 유닛) : 대상 유닛의 중력값을 반환합니다. 쓰실 일이 있을지는...?
//
//SetUnitGravity(대상 유닛, 값) : 대상 유닛의 중력값(Z축 속력 감소율)을 설정합니다. 디폴트 값은 0.6이며 양수값일때 아래로 가라앉습니다. 음수값으로 설정하는 경우는 그 반대.
//
//UnitApplyGravity(대상 유닛, 사용여부) : 대상 유닛의 중력에 의한 Z축 속력 변화를 허용할지 여부입니다.
//Z축 속력을 양수값으로 설정하고 해당 함수에 false 값을 대입해 실행하면 일정한 속력으로 하늘로 승천합니다.(?)

library AirbourneSystem initializer init

    globals
    private trigger MAIN = CreateTrigger()
    private hashtable physics = InitHashtable()
    private integer BASEHEIGHT = 0
    private integer HEIGHT = 1
    private integer ZVELO = 2
    private integer GRAVITY = 3
    private integer APPLYGRAVITY = 4
    private real GRAVITY_DEFAULT = 0.6
    private real TIMER_PERIOD = 0.02
    public group GROUP = CreateGroup()
    endglobals
    
    private function remove takes unit u returns nothing
    if IsUnitInGroup(u,GROUP) then
    call SetUnitFlyHeight(u,LoadReal(physics,GetHandleId(u),BASEHEIGHT),0)
    call RemoveSavedReal(physics,GetHandleId(u),BASEHEIGHT)
    call RemoveSavedReal(physics,GetHandleId(u),ZVELO)
    call RemoveSavedReal(physics,GetHandleId(u),HEIGHT)
    call RemoveSavedReal(physics,GetHandleId(u),GRAVITY)
    call RemoveSavedBoolean(physics,GetHandleId(u),APPLYGRAVITY)
    call GroupRemoveUnit(GROUP,u)
    //에어본제거
    call UnitRemoveAbility(u,'A024')
    endif
    endfunction
    
    private function regist takes unit u returns nothing
    call SaveReal(physics,GetHandleId(u),BASEHEIGHT,GetUnitFlyHeight(u))
    call SaveReal(physics,GetHandleId(u),ZVELO,0)
    call SaveReal(physics,GetHandleId(u),HEIGHT,0)
    call SaveReal(physics,GetHandleId(u),GRAVITY,GRAVITY_DEFAULT)
    call SaveBoolean(physics,GetHandleId(u),APPLYGRAVITY,true)
    call UnitAddAbility(u,'Arav')
    call UnitRemoveAbility(u,'Arav')
    call GroupAddUnit(GROUP,u)
    //에어본중
    call UnitAddAbility(u,'A024')
    endfunction
    
    private function setheight takes nothing returns nothing
    local unit u = GetEnumUnit()
    local real x
    local real y
    call SaveReal(physics,GetHandleId(u),HEIGHT,LoadReal(physics,GetHandleId(u),HEIGHT)+LoadReal(physics,GetHandleId(u),ZVELO))
    if LoadBoolean(physics,GetHandleId(u),APPLYGRAVITY) then
        call SaveReal(physics,GetHandleId(u),ZVELO,LoadReal(physics,GetHandleId(u),ZVELO)-LoadReal(physics,GetHandleId(u),GRAVITY))
    endif
    if LoadReal(physics,GetHandleId(u),ZVELO) < 0 and LoadReal(physics,GetHandleId(u),HEIGHT) <= 0 then
        call SaveReal(physics,GetHandleId(u),HEIGHT,0)
        call SaveReal(physics,GetHandleId(u),ZVELO,0)
    endif
    call SetUnitFlyHeight(u,LoadReal(physics,GetHandleId(u),HEIGHT)+LoadReal(physics,GetHandleId(u),BASEHEIGHT),0)
    //////////////////////////////////////////////
    
    if LoadReal(physics,GetHandleId(u),ZVELO) == 0 and LoadReal(physics,GetHandleId(u),HEIGHT) == 0 then
        call remove(u)
    endif
    set u = null
    endfunction
    
    private function main takes nothing returns nothing
        call ForGroup(GROUP,function setheight)
    endfunction
    
    function GetUnitHeight takes unit u returns real
        return LoadReal(physics,GetHandleId(u),HEIGHT)
    endfunction
    
    function SetUnitHeight takes unit u, real r returns nothing
        if not IsUnitInGroup(u,GROUP) then
            call regist(u)
        endif
        call SaveReal(physics,GetHandleId(u),HEIGHT,r)
    endfunction
    
    function GetUnitZVelo takes unit u returns real
        return LoadReal(physics,GetHandleId(u),ZVELO)
    endfunction
    
    function SetUnitZVelo takes unit u, real r returns nothing
        if GetUnitAbilityLevel(u,'A00R') < 1 then
            if not IsUnitInGroup(u,GROUP) then
                call regist(u)
            endif
            call SaveReal(physics,GetHandleId(u),ZVELO,r)
        endif
    endfunction
    
    function GetUnitGravity takes unit u returns real
        return LoadReal(physics,GetHandleId(u),GRAVITY)
    endfunction
    
    function SetUnitGravity takes unit u, real r returns nothing
        if not IsUnitInGroup(u,GROUP) then
            call regist(u)
        endif
        call SaveReal(physics,GetHandleId(u),GRAVITY,r)
    endfunction
    
    function UnitApplyGravity takes unit u, boolean flag returns nothing
        if IsUnitInGroup(u,GROUP) then
            call SaveBoolean(physics,GetHandleId(u),APPLYGRAVITY,flag)
        endif
    endfunction
    
    private function init takes nothing returns nothing
    call TriggerRegisterTimerEvent(MAIN,TIMER_PERIOD,true)
    call TriggerAddAction(MAIN,function main)
    endfunction
    
    endlibrary