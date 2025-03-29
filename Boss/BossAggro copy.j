library BossAggro requires Tick, UnitIndexer
    globals
        private unit Boss
        private group PlayerGroup
        private constant real AggroCheckInterval = 1.0
        private constant integer AggroCheckCount = 10
        private constant integer MaxPlayer = 6
        private constant integer DamageArraySize = MaxPlayer * AggroCheckCount
        integer array BossStruct
    endglobals
    
    struct AggroSystem
        integer currentIndex
        integer NowAggro
        tick AggroCheckTimer
        real array PlayerDamageCount[DamageArraySize]
    
        method SetDamage takes integer pid, real damage returns nothing
            local integer index = this.currentIndex * MaxPlayer + pid
            set this.PlayerDamageCount[index] = this.PlayerDamageCount[index] + damage
        endmethod
    
        private static method AggroUpdate takes nothing returns nothing
            local tick t = tick.getExpired()
            local thistype this = t.data
            local integer index = 0
            local real maxDamage = 0
            local real maxDamage2 = 0
    
            set this.currentIndex = this.currentIndex + 1
    
            if this.currentIndex == AggroCheckCount then
                this.currentIndex = 0
            endif
    
            loop
                set maxDamage = 0
                local playerOffset = this.currentIndex * MaxPlayer
                local playerEnd = playerOffset + MaxPlayer - 1
                for index = playerOffset to playerEnd do
                    set maxDamage = maxDamage + this.PlayerDamageCount[index]
                endfor
    
                if maxDamage2 <= maxDamage then
                    set this.NowAggro = this.currentIndex
                    set maxDamage2 = maxDamage
                endif
                
                set this.currentIndex = this.currentIndex + 1
                exitwhen this.currentIndex == AggroCheckCount
            endloop
            //call BJDebugMsg( "현재 어그로 번호 : " + I2S(this.NowAggro) )
        endmethod
        
        method onDestroy takes nothing returns nothing
            call this.AggroCheckTimer.pause()
            call this.AggroCheckTimer.destroy()
        endmethod
    
        static method create takes nothing returns thistype
            local thistype this = thistype.allocate()
    
            set this.AggroCheckTimer = tick.create(this)
            call this.AggroCheckTimer.start(AggroCheckInterval, true, function thistype.AggroUpdate )
    
            return this
        endmethod
    endstruct
    
    function PlayerBossAttack takes unit damagedUnit, unit damagingUnit, real damage returns nothing
        local AggroSystem s = BossStruct[IndexUnit(damagingUnit)]
        call s.SetDamage(GetPlayerId(GetOwningPlayer(damagedUnit)), damage)
    endfunction
endlibrary