library AOE requires MonoEvent, DamageEffect2


    private function filter2 takes nothing returns boolean
        return not IsUnitType(GetFilterUnit(),UNIT_TYPE_SUMMONED) and UnitAlive(GetFilterUnit()) == true
    endfunction

    private struct AOESt
        unit caster
        real x
        real y
        real range
        real safe
        real damage
        integer eft
        //커스텀 이벤트 아이디
        integer id
        private method OnStop takes nothing returns nothing
            set caster = null
            set x = 0
            set y = 0
            set range = 0
            set safe = 0
            set damage = 0
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
                if UnitAlive(tu) == true and IsUnitInRangeXY(tu,st.x,st.y,st.range) and IsUnitAlly(tu, GetOwningPlayer(st.caster)) == false then
                    //데미지줌
                    call BossDeal( st.caster, tu, st.damage , false)
                    call MonoEvent.Fire( E_AOE, null, st.caster, tu, st.id) /*이벤트 - 투사체가 충돌했을때 작동*/
                endif
            endif
        endloop

        call ul.destroy()
        call t.destroy()
        call st.Stop()
    endfunction

    function AOE takes unit u, real x, real y, real range, real time, real damage, integer eft, integer id returns nothing
        local tick t = tick.create(0)
        local AOESt st = AOESt.Create()
        local unit du = null
        set st.caster = u
        set st.x = x
        set st.y = y
        set st.range = range
        set st.damage = damage
        set st.eft = eft
        set st.id = id
        set t.data = st
        
        set range = range * 0.01

        set du = CreateUnit(GetOwningPlayer(u), 'h00H', x, y, 270)
        call SetUnitScalePercent(du,100 * range, 100 * range, 100)
        call SetUnitVertexColor(du, 255, 10, 10, 255) 
        call SetUnitTimeScale( du, 1 / time)
        call UnitApplyTimedLife(du, 'BHwe', 1 * time)
        set du = null

        call t.start(time,false,function AOE_Tick)
    endfunction

    private function AOE2_Tick takes nothing returns nothing
        local tick t = tick.getExpired()
        local AOESt st = t.data
        local unit du = null
        local real r = 1
        local party ul
        local party ul2
        local unit tu = null

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
                if UnitAlive(tu) == true and IsUnitInRangeXY(tu,st.x,st.y,st.range) and IsUnitAlly(tu, GetOwningPlayer(st.caster)) == false and IsUnitInGroup(tu, ul2.super) == false then
                    call BossDeal( st.caster, tu, st.damage , false)
                    call MonoEvent.Fire( E_AOE, null, st.caster, tu, st.id)
                endif
            endif
        endloop

        call ul.destroy()
        call ul2.destroy()
        call t.destroy()
        call st.Stop()
    endfunction

    function AOE2 takes unit u, real x, real y, real safe, real range, real time, real damage, integer eft, integer id returns nothing
        local tick t = tick.create(0)
        local AOESt st = AOESt.Create()
        local unit du = null
        set st.caster = u
        set st.x = x
        set st.y = y
        set st.safe = safe
        set st.range = range
        set st.damage = damage
        set st.eft = eft
        set st.id = id
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
    endfunction

endlibrary