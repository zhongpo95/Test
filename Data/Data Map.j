library DataMap requires FX
globals
    rect array MapRect
    integer array Mapthema
    integer array MapSt
    boolean array MapRectCheck
    //기본휴식타임 3.0초
    constant integer StandTime = 150
    //카운터 그로기 5초
    constant integer CounterTime = 250
endglobals

struct MapStruct
    unit caster = null
    party ul
    integer rectnumber = 0
    integer pattern1 = 0
    integer pattern2 = 0
    integer pattern3 = 0
    integer pattern4 = 0
    integer pattern5 = 0
    integer pattern6 = 0
    integer pattern7 = 0
    integer pattern8 = 0
    integer pattern9 = 0
    integer pattern10 = 0
    integer i = 0
    integer j = 0
    integer cut1 = 0
    integer cut2 = 0
    integer cut3 = 0
    integer cut4 = 0
    private method OnStop takes nothing returns nothing
    endmethod
    //! runtextmacro 연출()
endstruct

function MapRectReturn takes integer mapnumber returns rect
    if mapnumber == 1 then
        return MapRect[1]
    elseif mapnumber == 2 then
        return MapRect[2]
    elseif mapnumber == 3 then
        return MapRect[3]
    elseif mapnumber == 4 then
        return MapRect[4]
    //elseif mapnumber == 5 then
        //return MapRect[5]
    //elseif mapnumber == 6 then
        //return MapRect[6]
    endif
    return null
endfunction
function MapRectReturn2 takes integer mapnumber returns rect
    if mapnumber == 1 then
        return gg_rct_Boss1
    elseif mapnumber == 2 then
        return gg_rct_Boss2
    elseif mapnumber == 3 then
        return gg_rct_Boss3
    elseif mapnumber == 4 then
        return gg_rct_Boss4
    //elseif mapnumber == 5 then
        //return gg_rct_Boss5
    //elseif mapnumber == 6 then
        //return gg_rct_Boss6
    endif
    return null
endfunction

function MapResetAll takes integer mapnumber returns nothing
    call SetDoodadAnimationRect( MapRectReturn(mapnumber), 'D00N', "stand alternate", false )
    call SetDoodadAnimationRect( MapRectReturn(mapnumber), 'D011', "stand alternate", false )
    set Mapthema[mapnumber] = 0
endfunction

function MapSet takes integer mapnumber, integer thema returns integer
    if thema == 1 then
        call SetDoodadAnimationRect( MapRectReturn(mapnumber), 'D00N', "stand", false )
    elseif thema == 2 then
        call SetDoodadAnimationRect( MapRectReturn(mapnumber), 'D011', "stand", false )
    endif
    set Mapthema[mapnumber] = thema
    set MapRectCheck[mapnumber] = true
    return mapnumber
endfunction

function MapReset takes integer mapnumber, integer thema returns nothing
    if thema == 1 then
        call SetDoodadAnimationRect( MapRectReturn(mapnumber), 'D00N', "stand alternate", false )
    elseif thema == 2 then
        call SetDoodadAnimationRect( MapRectReturn(mapnumber), 'D011', "stand alternate", false )
    endif
    set Mapthema[mapnumber] = 0
    set MapRectCheck[mapnumber] = true
endfunction

function GetMap takes integer thema returns integer
    local integer i = 0
    
    //테마가 같으면서 입장이 가능
    loop
        set i = i + 1
        if Mapthema[i] == thema and MapRectCheck[i] == true then
            return MapSet(i, thema)
        endif
    exitwhen i == 4
    endloop
    //입장가능한 빈공간이 있음
    set i = 0
    loop
        set i = i + 1
        if Mapthema[i] == 0 and MapRectCheck[i] == true then
            return MapSet(i, thema)
        endif
    exitwhen i == 4
    endloop
    
    return 0
endfunction

//! runtextmacro 이벤트_N초가_지나면_발동("A","1.0")
    set MapRectCheck[1] = true
    set MapRectCheck[2] = true
    set MapRectCheck[3] = true
    set MapRectCheck[4] = true
    //set MapRectCheck[5] = true
    //set MapRectCheck[6] = true
    set MapSt[1] = MapStruct.Create()
    set MapSt[2] = MapStruct.Create()
    set MapSt[3] = MapStruct.Create()
    set MapSt[4] = MapStruct.Create()
    //set MapSt[5] = MapStruct.Create()
    //set MapSt[6] = MapStruct.Create()
    set MapRect[1] = gg_rct_MapRect01
    set MapRect[2] = gg_rct_MapRect02
    set MapRect[3] = gg_rct_MapRect03
    set MapRect[4] = gg_rct_MapRect04
    //set MapRect[5] = gg_rct_MapRect05
    //set MapRect[6] = gg_rct_MapRect06
//! runtextmacro 이벤트_끝()
endlibrary