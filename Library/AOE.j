library AOE initializer Init requires MonoEvent, DamageEffect2
    globals
        constant key E_AOE
    endglobals

    //추가해야함
    //빨강은 그냥 데미지
    //파랑은 상태이상
    //노랑은 피격이나 경직

    private function Act takes nothing returns nothing
        local unit caster = MonoEvent.Unit
        local unit target = MonoEvent.Unit2
        local unit du = null
        local integer id = MonoEvent.Integer
        local real angle = 0
        local integer ui = 0
        local real dist = 0
        local integer i = 0
        local real r = 0
        
        //세리아 카운터 넉백
        if id == 1 then
            call BossDeal( caster, target, 100 , false)
            call KnockbackInverse( target, caster, 500, 0.5)
            call SetUnitZVelo( target, 7.5)
            //1.0스턴
            call CustomStun.Stun2(target, 1.0)
        endif
        //세리아 3장판
        if id == 2 then
            call BossDeal( caster, target, 100 , false)
            call KnockbackInverse( target, caster, 500, 0.5)
            call SetUnitZVelo( target, 7.5)
            //1.5초스턴
            call CustomStun.Stun2(target, 1.5)
        endif

        set target = null
        set du = null
        set caster = null
    endfunction
    
    private function Init takes nothing returns nothing
        call MonoEvent.Add(E_AOE, function Act)
    endfunction

    private function filter2 takes nothing returns boolean
        return not IsUnitType(GetFilterUnit(),UNIT_TYPE_SUMMONED) and UnitAlive(GetFilterUnit())
    endfunction

    struct AOESt
        unit caster
        real x
        real y
        real range
        real safe
        integer eft
        //도중정지
        boolean stop
        //커스텀 이벤트 아이디
        integer id
        private method OnStop takes nothing returns nothing
            set caster = null
            set x = 0
            set y = 0
            set range = 0
            set safe = 0
            set eft = 0
            set id = 0
        endmethod
        //! runtextmacro 연출()
    endstruct

    private function AOE_Tick takes nothing returns nothing
        local tick t = tick.getExpired()
        local AOESt st = t.data
        local unit du = null
        local real r = 1
        local party ul
        local unit tu = null

        if st.stop != true then
            if st.eft != 0 then
                set du = CreateUnit(GetOwningPlayer(st.caster), st.eft, st.x, st.y, GetRandomReal(0,360))
                call UnitApplyTimedLife(du, 'BHwe', r)
                set du = null
            endif
            
            set ul = party.create()
            
            call GroupEnumUnitsInRange(ul.super, st.x, st.y, st.range * 1.35, Filter(function filter2)  )
            loop
                set tu = FirstOfGroup(ul.super)
                call GroupRemoveUnit(ul.super,tu)  
                exitwhen tu == null
                if IsUnitInRangeXY(tu, st.x, st.y, st.range * 1.35) then
                    if UnitAlive(tu) and IsUnitInRangeXY(tu,st.x,st.y,st.range) and not IsUnitAlly(tu, GetOwningPlayer(st.caster)) then
                        //데미지줌
                        call MonoEvent.Fire( E_AOE, null, st.caster, tu, st.id) /*이벤트 - 대미지 격발*/
                    endif
                endif
            endloop

            call ul.destroy()
            call t.destroy()
        endif
        call st.Stop()
    endfunction
    /*types 0=red 1=blue 2=Yellow 3=green
        빨강은 그냥 데미지
        파랑은 상태이상(기절,혼란,속박)
        노랑은 피격이나 경직(넉백,다운)
        초록은 안전
    */
    function AOE takes unit u, real x, real y, real range, real time, integer eft, integer id, integer types returns AOESt
        local tick t = tick.create(0)
        local AOESt st = AOESt.Create()
        local unit du = null
        set st.caster = u
        set st.x = x
        set st.y = y
        set st.range = range
        set st.eft = eft
        set st.id = id
        set st.stop = false
        set t.data = st

        set range = range * 0.01

        set du = CreateUnit(GetOwningPlayer(u), 'h00H', x, y, 270)
        call SetUnitScalePercent(du,100 * range, 100 * range, 100)
        if types == 0 then
            call SetUnitVertexColor(du, 255, 10, 10, 255) 
        elseif types == 1 then
            call SetUnitVertexColor(du, 10, 10, 255, 255) 
        elseif types == 2 then
            call SetUnitVertexColor(du, 255, 255, 10, 255) 
        elseif types == 3 then
            call SetUnitVertexColor(du, 10, 255, 10, 255) 
        endif
        
        call SetUnitTimeScale( du, 1 / time)
        call UnitApplyTimedLife(du, 'BHwe', 1 * time)
        set du = null

        call t.start(time,false,function AOE_Tick)
        return st
    endfunction

    private function AOE2_Tick takes nothing returns nothing
        local tick t = tick.getExpired()
        local AOESt st = t.data
        local unit du = null
        local real r = 1
        local party ul
        local party ul2
        local unit tu = null

        if st.stop != true then

            if st.eft != 0 then
                set du = CreateUnit(GetOwningPlayer(st.caster), st.eft, st.x, st.y, GetRandomReal(0,360))
                call UnitApplyTimedLife(du, 'BHwe', r)
                set du = null
            endif
            
            set ul = party.create()
            set ul2 = party.create()
            
            call GroupEnumUnitsInRange(ul2.super, st.x, st.y, st.safe, Filter(function filter2)  ) /*안전범위safe 안의 유닛들을 그룹에 넣고*/

            call GroupEnumUnitsInRange(ul.super, st.x, st.y, st.range * 1.5, Filter(function filter2)  )
            loop
                set tu = FirstOfGroup(ul.super)
                call GroupRemoveUnit(ul.super,tu)
                exitwhen tu == null
                if IsUnitInRangeXY(tu, st.x, st.y, st.range * 1.35) then
                    if UnitAlive(tu) and IsUnitInRangeXY(tu,st.x,st.y,st.range) and not IsUnitAlly(tu, GetOwningPlayer(st.caster)) and not IsUnitInGroup(tu, ul2.super) then
                        call MonoEvent.Fire( E_AOE, null, st.caster, tu, st.id)
                    endif
                endif
            endloop

            call ul.destroy()
            call ul2.destroy()

        endif

        call t.destroy()
        call st.Stop()
    endfunction

    //u = 유닛, x = x좌표, y = y좌표, safe = range보다 큰범위, range = 실제범위, time = 효과적용시간, eft 이펙트, id 효과아이디
    function AOE2 takes unit u, real x, real y, real safe, real range, real time, integer eft, integer id returns AOESt
        local tick t = tick.create(0)
        local AOESt st = AOESt.Create()
        local unit du = null
        set st.caster = u
        set st.x = x
        set st.y = y
        set st.safe = safe
        set st.range = range
        set st.eft = eft
        set st.id = id
        set st.stop = false
        set t.data = st
        
        set range = range * 0.01

        set du = CreateUnit(GetOwningPlayer(u), 'h00H', x, y, 270)
        call SetUnitScalePercent(du, 100 * range, 100 * range, 100)
        call SetUnitVertexColor(du, 255, 10, 10, 255) 
        call SetUnitTimeScale(du, 1 / time)
        call UnitApplyTimedLife(du, 'BHwe', 1 * time)
        set du = null

        set safe = safe * 0.01
        set du = CreateUnit(GetOwningPlayer(u), 'h00H', x, y, 270)
        call SetUnitScalePercent(du,93 * safe, 93 * safe, 100)
        call SetUnitVertexColor(du, 10, 255, 10, 255) 
        call SetUnitTimeScale( du, 1 / time)
        call UnitApplyTimedLife(du, 'BHwe', 1 * time)
        set du = null

        call t.start(time, false, function AOE2_Tick)
        return st
    endfunction

endlibrary