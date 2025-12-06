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

        real array PlayerDamageCount[DamageArraySize]
        tick AggroCheckTimer
        group participatingUnits

        //pid = playerId
        method SetDamage takes integer pid, real damage returns nothing
            local integer index = this.currentIndex + ( AggroCheckCount * pid )
            set this.PlayerDamageCount[index] = this.PlayerDamageCount[index] + damage
        endmethod

        private static method AggroUpdate takes nothing returns nothing
            local tick t = tick.getExpired()
            local thistype this = t.data
            local integer index = 0
            local real maxDamage2 = 0
            local integer playerOffset
            local real playerDamage = 0
            local integer validPlayerFound = 0
            
            set this.currentIndex = this.currentIndex + 1

            if this.currentIndex == AggroCheckCount then
                set this.currentIndex = 0
            endif

            set this.PlayerDamageCount[this.currentIndex + (AggroCheckCount * 0)] = 0
            set this.PlayerDamageCount[this.currentIndex + (AggroCheckCount * 1)] = 0
            set this.PlayerDamageCount[this.currentIndex + (AggroCheckCount * 2)] = 0
            set this.PlayerDamageCount[this.currentIndex + (AggroCheckCount * 3)] = 0
            set this.PlayerDamageCount[this.currentIndex + (AggroCheckCount * 4)] = 0
            set this.PlayerDamageCount[this.currentIndex + (AggroCheckCount * 5)] = 0
            
            set index = 0
            loop
                exitwhen index >= MaxPlayer
                set playerOffset = AggroCheckCount * index
                set playerDamage = 0
                
                set playerDamage = playerDamage + this.PlayerDamageCount[0 + (playerOffset)]
                set playerDamage = playerDamage + this.PlayerDamageCount[1 + (playerOffset)]
                set playerDamage = playerDamage + this.PlayerDamageCount[2 + (playerOffset)]
                set playerDamage = playerDamage + this.PlayerDamageCount[3 + (playerOffset)]
                set playerDamage = playerDamage + this.PlayerDamageCount[4 + (playerOffset)]
                set playerDamage = playerDamage + this.PlayerDamageCount[5 + (playerOffset)]
                set playerDamage = playerDamage + this.PlayerDamageCount[6 + (playerOffset)]
                set playerDamage = playerDamage + this.PlayerDamageCount[7 + (playerOffset)]
                set playerDamage = playerDamage + this.PlayerDamageCount[8 + (playerOffset)]
                set playerDamage = playerDamage + this.PlayerDamageCount[9 + (playerOffset)]

                // 피해를 입힌 플레이어만 어그로 대상 체크
                if playerDamage > 0 or (maxDamage2 == 0 and validPlayerFound == 0) then
                    set validPlayerFound = 1
                    if maxDamage2 < playerDamage or (maxDamage2 == 0 and this.NowAggro == 0) then
                        set this.NowAggro = index
                        set maxDamage2 = playerDamage
                    endif
                endif
                
                set index = index + 1
            endloop
            //call VJDebugMsg( "현재 어그로 번호 : " + I2S(this.NowAggro)  )
        endmethod
        
        method onDestroy takes nothing returns nothing
            call this.AggroCheckTimer.pause()
            call this.AggroCheckTimer.destroy()
            set this.participatingUnits = null
        endmethod

        static method create takes group playerUnits returns thistype
            local thistype this = thistype.allocate()
            local integer i = 0
            local unit u = null
            
            loop
                exitwhen i >= DamageArraySize
                set this.PlayerDamageCount[i] = 0
                set i = i + 1
            endloop

            set this.participatingUnits = playerUnits
            set this.NowAggro = GetPlayerId(GetOwningPlayer(FirstOfGroup(playerUnits)))
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