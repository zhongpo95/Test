scope AOEHIT initializer Init
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
            call KnockbackInverse( target, caster, 500, 0.5)
            call SetUnitZVelo( target, 7.5)
        endif

        //얼음파편 기절
        if id == 2 then
            call CustomStun.Stun2( target, 2.0)
        endif

        set target = null
        set du = null
        set caster = null
    endfunction
        
    private function Init takes nothing returns nothing
        call MonoEvent.Add(E_AOE, function Act)
        call MonoEvent.Add(E_Missile, function Act)
    endfunction
endscope