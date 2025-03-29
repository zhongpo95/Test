library Missile initializer Init requires MonoEvent, DamageEffect2
    globals
        constant key E_Missile
    endglobals

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

        //나비
        if id == 1 then
            call BossDeal( caster, target, 50 , false)
        endif

        //세리아 얼음파편 기절
        if id == 2 then
            call BossDeal( caster, target, 50 , false)
            call CustomStun.Stun2( target, 2.0)
        endif

        //세리아 파이어볼
        if id == 3 then
            call BossDeal( caster, target, 100 , false)
            call CustomStun.Stun2( target, 2.0)
            call UnitApplyTimedLife(CreateUnit(GetOwningPlayer(caster), 'e03R', GetWidgetX(target), GetWidgetY(target), GetRandomReal(0,360)), 'BHwe', 1.0)
            call BJDebugMsg("스턴")
        endif

        set target = null
        set du = null
        set caster = null
    endfunction
        
    private function Init takes nothing returns nothing
        call MonoEvent.Add(E_Missile, function Act)
    endfunction

    private function filter2 takes nothing returns boolean
        return not IsUnitType(GetFilterUnit(),UNIT_TYPE_SUMMONED) and UnitAlive(GetFilterUnit()) and GetOwningPlayer(GetFilterUnit()) != Player(PLAYER_NEUTRAL_AGGRESSIVE)
    endfunction

    private struct MissileSt
        unit u
        effect ef
        real time
        real dis
        real ang
        real col
        real damage
        integer id
        party ul
        private method OnStop takes nothing returns nothing
            set u = null
            set ef = null
            set time = 0
            set dis = 0
            set ang = 0
            set col = 0
            set damage = 0
            set id = 0
        endmethod

        //! runtextmacro 연출()
    endstruct

    private function MissileOn takes nothing returns nothing
        local tick t = tick.getExpired()
        local MissileSt st = t.data
        local party ul
        local real x = EXGetEffectX(st.ef) + PolarX( st.dis, st.ang )
        local real y = EXGetEffectY(st.ef) + PolarY( st.dis, st.ang )
        local unit tu = null

        call EXSetEffectXY(st.ef, x, y)

        set ul = party.create()
        call GroupEnumUnitsInRange(ul.super, x, y, st.col * 1.35, Filter(function filter2) )
        loop
            set tu = FirstOfGroup(ul.super)
            call GroupRemoveUnit(ul.super,tu)  
            exitwhen tu == null
            if IsUnitInRangeXY(tu, x, y, st.col * 1.35) then
                if UnitAlive(tu) and IsUnitInRangeXY(tu, x, y, st.col) and not IsUnitAlly(tu, GetOwningPlayer(st.u)) then
                    //데미지줌
                    call MonoEvent.Fire( E_Missile, null, st.u, tu, st.id) /*이벤트 - 투사체가 충돌했을때 작동*/
                    set st.time = 0
                endif
            endif
        endloop
        set st.time = st.time - 1

        call ul.destroy()

        if st.time <= 0 then
            call DestroyEffect(st.ef)
            call t.destroy()
            call st.Stop()
        endif

    endfunction


    private function MissileOn2 takes nothing returns nothing
        local tick t = tick.getExpired()
        local MissileSt st = t.data
        local party ul
        local real x = EXGetEffectX(st.ef) + PolarX( st.dis, st.ang )
        local real y = EXGetEffectY(st.ef) + PolarY( st.dis, st.ang )
        local unit tu = null

        call EXSetEffectXY(st.ef, x, y)

        set ul = party.create()
        call GroupEnumUnitsInRange(ul.super, x, y, st.col * 1.35, Filter(function filter2) )
        loop
            set tu = FirstOfGroup(ul.super)
            call GroupRemoveUnit(ul.super,tu)  
            exitwhen tu == null
            if IsUnitInRangeXY(tu, x, y, st.col * 1.35) then
                if UnitAlive(tu) and IsUnitInRangeXY(tu, x, y, st.col) and not IsUnitAlly(tu, GetOwningPlayer(st.u)) and not IsUnitInGroup(tu,st.ul.super) then
                    //데미지줌
                    call GroupAddUnit(st.ul.super, tu)
                    call MonoEvent.Fire( E_Missile, null, st.u, tu, st.id) /*이벤트 - 투사체가 충돌했을때 작동*/
                    //set st.time = 0
                endif
            endif
        endloop
        set st.time = st.time - 1

        call ul.destroy()

        if st.time <= 0 then
            call st.ul.destroy()
            call DestroyEffect(st.ef)
            call t.destroy()
            call st.Stop()
        endif

    endfunction

    //Missile(미사일소유주, 이펙트, 날라갈거리, 각도, 도착까지의 시간, 피탄범위, 범위, id)
    function Missile takes unit u, effect ef, real distance, real ang, real time, real collision, integer id returns nothing
        local tick t = tick.create(0)
        local MissileSt st = MissileSt.Create()

        set st.u = u
        set st.ef = ef
        set st.time = time / 0.02
        set st.dis = distance / st.time
        set st.ang = ang
        set st.col = collision
        set st.id = id

        set t.data = st
        call t.start(0.02,true,function MissileOn)
    endfunction

    //Missile관통(미사일소유주, 이펙트, 날라갈거리, 각도, 도착까지의 시간, 피탄범위, 범위, id)
    function Missile2 takes unit u, effect ef, real distance, real ang, real time, real collision, integer id returns nothing
        local tick t = tick.create(0)
        local MissileSt st = MissileSt.Create()

        set st.u = u
        set st.ef = ef
        set st.time = time / 0.02
        set st.dis = distance / st.time
        set st.ang = ang
        set st.col = collision
        set st.id = id
        set st.ul = party.create()

        set t.data = st
        call t.start(0.02,true,function MissileOn2)
    endfunction

    //MakeMissile(모델,x,y,높이,각도,size,null)
    function MakeMissile takes string modelname, real x, real y, real z, real r, real size, effect ef returns effect
        set ef = AddSpecialEffect(modelname,x,y)
        call EXSetEffectZ(ef,z)
        call EXSetEffectSize(ef, size)
        call EXEffectMatRotateZ(ef,r)
        return ef
    endfunction
endlibrary

//단점 이펙트가 생성된 위치를 화면에 두지 않으면 움직인 미사일이 보이지 않음.