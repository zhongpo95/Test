library ClosestUnit requires Party
    globals
        private unit ENEMYCheckUnit
    endglobals
    
    private function ENEMYfunction takes nothing returns boolean
        
        if GetOwningPlayer(GetFilterUnit()) == Player(PLAYER_NEUTRAL_PASSIVE) then

            return false

        endif
        
        if not IsUnitEnemy( GetFilterUnit(), GetOwningPlayer(ENEMYCheckUnit) ) then

            return false

        endif

        if IsUnitType( GetFilterUnit(), UNIT_TYPE_DEAD ) then

            return false

        endif

        if IsUnitType( GetFilterUnit(), UNIT_TYPE_SUMMONED ) then

            return false

        endif
        
        return true

    endfunction

    function ClosestUnit takes unit u, real size returns unit
        local party ul = party.create()
        local location loc = GetUnitLoc(u)
        local location loc2 = null
        local unit c = null
        local unit c2 = null

        set ENEMYCheckUnit = u
        call GroupEnumUnitsInRange( ul.super, GetWidgetX(u),GetWidgetY(u), size, Filter( function ENEMYfunction ) )
        set ENEMYCheckUnit = null

        loop
        set c = FirstOfGroup(ul.super) 
        exitwhen c == null
            call GroupRemoveUnit(ul.super, c)
            
            if DistanceWBW(u,c) < DistanceWBW(u, c2) then
                set c2 = c
            endif
        endloop
        
        call ul.destroy()
        set c = null
        set u = c2
        set c2 = null
        return u
    endfunction
//[출처] 존나 쉬운 스크립트 입문 (초장문) (워크래프트3 리포지드 유즈맵 포럼 [W3UMF]) | 작성자 근첩
endlibrary