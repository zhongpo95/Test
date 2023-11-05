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
        
        call BJDebugMsg("히트발동")

        if id == 1 then
            call BJDebugMsg("id = 1")
            call KnockbackInverse( target, caster, 500, 0.5)
            call SetUnitZVelo( target, 7.5)
        endif

        set target = null
        set du = null
        set caster = null
        endfunction
        
        private function Init takes nothing returns nothing
        call MonoEvent.Add(E_AOE, function Act)
    endfunction
endscope