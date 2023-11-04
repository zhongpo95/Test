library Splash requires Party
    globals

        private player PSRC = null

        private unit SRC = null

        private integer IRC = 0

        private real SX = 0
        private real SY = 0

    endglobals
    
    function SplashNothing takes nothing returns nothing
    endfunction

    private struct filter extends array

        static method E takes nothing returns boolean
        
            if GetOwningPlayer(GetFilterUnit()) == Player(PLAYER_NEUTRAL_PASSIVE) then

                return false

            endif
            
            if not IsUnitEnemy( GetFilterUnit(), PSRC ) then

                return false

            endif

            if IsUnitType( GetFilterUnit(), UNIT_TYPE_DEAD ) then

                return false

            endif

            if IsUnitType( GetFilterUnit(), UNIT_TYPE_SUMMONED ) then

                return false

            endif
            
            return true

        endmethod

        static method O takes nothing returns boolean
        
            if GetOwningPlayer(GetFilterUnit()) == Player(PLAYER_NEUTRAL_PASSIVE) then

                return false

            endif

            if GetOwningPlayer(GetFilterUnit()) != PSRC then

                return false

            endif

            if IsUnitType( GetFilterUnit(), UNIT_TYPE_DEAD ) then

                return false

            endif

            if IsUnitType( GetFilterUnit(), UNIT_TYPE_SUMMONED ) then

                return false

            endif

            return true

        endmethod

        static method A takes nothing returns boolean
        
            if GetOwningPlayer(GetFilterUnit()) == Player(PLAYER_NEUTRAL_PASSIVE) then

                return false

            endif

            if not IsUnitAlly( GetFilterUnit(), PSRC ) then

                return false

            endif

            if IsUnitType( GetFilterUnit(), UNIT_TYPE_DEAD ) then

                return false

            endif

            if IsUnitType( GetFilterUnit(), UNIT_TYPE_SUMMONED ) then

                return false

            endif

            return true

        endmethod

        static method W takes nothing returns boolean
        
            if GetOwningPlayer(GetFilterUnit()) == Player(PLAYER_NEUTRAL_PASSIVE) then

                return false

            endif

            return not IsUnitType( GetFilterUnit(), UNIT_TYPE_DEAD )

        endmethod

        static method ANOT takes nothing returns boolean
        
            if GetOwningPlayer(GetFilterUnit()) == Player(PLAYER_NEUTRAL_PASSIVE) then

                return false

            endif

            if not IsUnitAlly( GetFilterUnit(), PSRC ) then

                return false

            endif

            if GetFilterUnit() == SRC then

                return false

            endif

            if IsUnitType( GetFilterUnit(), UNIT_TYPE_DEAD ) then

                return false

            endif

            return true

        endmethod

    endstruct

    struct splash extends array
        static boolexpr ENEMY = null

        static boolexpr PLAYER = null

        static boolexpr ALLY = null

        static boolexpr ANY = null

        static boolexpr ALLYNOTME = null

        private static method onInit takes nothing returns nothing

            set ENEMY = Filter( function filter.E )

            set PLAYER = Filter( function filter.O )

            set ALLY = Filter( function filter.A )

            set ANY = Filter( function filter.W )

            set ALLYNOTME = Filter( function filter.ANOT )

        endmethod

        static method operator source takes nothing returns unit

            return SRC

        endmethod
    
        static method operator owner takes nothing returns player

            return PSRC

        endmethod

        static method operator int takes nothing returns integer

            return IRC

        endmethod

        static method operator x takes nothing returns real

            return SX

        endmethod

        static method operator y takes nothing returns real

            return SY

        endmethod

        static method range takes boolexpr f, unit src, real x, real y, real rng, code c returns integer

            local party ul = party.create()

            local player ppsrc = PSRC

            local unit psrc = SRC
            
            local integer pirc = IRC

            set SRC = src

            set PSRC = GetOwningPlayer( src )

            set SX = x

            set SY = y

            call GroupEnumUnitsInRange( ul.super, x, y, rng, f )
            
            set bj_groupCountUnits = 0
            
            call ForGroup( ul.super, function CountUnitsInGroupEnum)
            
            call ForGroup( ul.super, c )

            call ul.destroy()

            set SRC = psrc

            set PSRC = ppsrc
            
            set IRC = pirc

            set psrc = null

            set ppsrc = null

            set SX = 0

            set SY = 0
            
            return bj_groupCountUnits

        endmethod

        static method zone takes boolexpr f, unit src, integer i, real x, real y, real w, real h, code c returns nothing

            local party ul = party.create()

            local player ppsrc = PSRC

            local unit psrc = SRC
            
            local integer pirc = IRC

            local rect r = Rect( x-w/2,y-h/2,x+w/2,y+h/2)

            set SRC = src

            set PSRC = GetOwningPlayer( src )
            
            set IRC = i

            set SX = x

            set SY = y

            call GroupEnumUnitsInRect( ul.super, r, f )

            call ForGroup( ul.super, c )

            call RemoveRect( r )

            call ul.destroy()

            set r = null
            
            set IRC = pirc

            set PSRC = ppsrc

            set ppsrc = null

            set SRC = psrc

            set psrc = null

            set SX = 0

            set SY = 0
        endmethod

        static method rect takes boolexpr f, unit src, integer i, rect r, code c returns nothing

            local party ul = party.create()

            local player ppsrc = PSRC

            local unit psrc = SRC
            
            local integer pirc = IRC

            set SRC = src

            set PSRC = GetOwningPlayer( src )
            
            set IRC = i

            call GroupEnumUnitsInRect( ul.super, r, f )

            call ForGroup( ul.super, c )

            call ul.destroy()
            
            set IRC = pirc

            set PSRC = ppsrc

            set ppsrc = null

            set SRC = psrc

            set psrc = null

            set SX = 0

            set SY = 0
        endmethod

    endstruct

endlibrary