library BossAggro requires Tick, UnitIndexer
    globals
        private unit Boss
        private group PlayerGroup
        private constant real AggroCheckInterval = 1.0
        private constant integer AggroCheckCount = 10
        private constant integer MaxPlayer = 6
        integer array BossStruct
    endglobals
    
    struct AggroSystem
        integer currentIndex
        integer NowAggro

        real array PlayerDamageCount0[10]
        real array PlayerDamageCount1[10]
        real array PlayerDamageCount2[10]
        real array PlayerDamageCount3[10]
        real array PlayerDamageCount4[10]
        real array PlayerDamageCount5[10]
        real array PlayerDamageCount6[10]
        real array PlayerDamageCount7[10]
        real array PlayerDamageCount8[10]
        real array PlayerDamageCount9[10]

        tick AggroCheckTimer

        //pid = playerId
        method SetDamage takes integer pid, real damage returns nothing
            
            if this.currentIndex == 0 then
                set this.PlayerDamageCount0[pid] = this.PlayerDamageCount0[pid] + damage
            elseif this.currentIndex == 1 then
                set this.PlayerDamageCount1[pid] = this.PlayerDamageCount1[pid] + damage
            elseif this.currentIndex == 2 then
                set this.PlayerDamageCount2[pid] = this.PlayerDamageCount2[pid] + damage
            elseif this.currentIndex == 3 then
                set this.PlayerDamageCount3[pid] = this.PlayerDamageCount3[pid] + damage
            elseif this.currentIndex == 4 then
                set this.PlayerDamageCount4[pid] = this.PlayerDamageCount4[pid] + damage
            elseif this.currentIndex == 5 then
                set this.PlayerDamageCount5[pid] = this.PlayerDamageCount5[pid] + damage
            elseif this.currentIndex == 6 then
                set this.PlayerDamageCount6[pid] = this.PlayerDamageCount6[pid] + damage
            elseif this.currentIndex == 7 then
                set this.PlayerDamageCount7[pid] = this.PlayerDamageCount7[pid] + damage
            elseif this.currentIndex == 8 then
                set this.PlayerDamageCount8[pid] = this.PlayerDamageCount8[pid] + damage
            elseif this.currentIndex == 9 then
                set this.PlayerDamageCount9[pid] = this.PlayerDamageCount9[pid] + damage
            endif
        endmethod

        private static method AggroUpdate takes nothing returns nothing
            local tick t = tick.getExpired()
            local thistype this = t.data
            local integer index = 0
            local real maxDamage = 0
            local real maxDamage2 = 0

            set this.currentIndex = this.currentIndex + 1

            if this.currentIndex == 1 then
                set this.PlayerDamageCount1[0] = 0
                set this.PlayerDamageCount1[1] = 0
                set this.PlayerDamageCount1[2] = 0
                set this.PlayerDamageCount1[3] = 0
                set this.PlayerDamageCount1[4] = 0
                set this.PlayerDamageCount1[5] = 0
            elseif this.currentIndex == 2 then
                set this.PlayerDamageCount2[0] = 0
                set this.PlayerDamageCount2[1] = 0
                set this.PlayerDamageCount2[2] = 0
                set this.PlayerDamageCount2[3] = 0
                set this.PlayerDamageCount2[4] = 0
                set this.PlayerDamageCount2[5] = 0
            elseif this.currentIndex == 3 then
                set this.PlayerDamageCount3[0] = 0
                set this.PlayerDamageCount3[1] = 0
                set this.PlayerDamageCount3[2] = 0
                set this.PlayerDamageCount3[3] = 0
                set this.PlayerDamageCount3[4] = 0
                set this.PlayerDamageCount3[5] = 0
            elseif this.currentIndex == 4 then
                set this.PlayerDamageCount4[0] = 0
                set this.PlayerDamageCount4[1] = 0
                set this.PlayerDamageCount4[2] = 0
                set this.PlayerDamageCount4[3] = 0
                set this.PlayerDamageCount4[4] = 0
                set this.PlayerDamageCount4[5] = 0
            elseif this.currentIndex == 5 then
                set this.PlayerDamageCount5[0] = 0
                set this.PlayerDamageCount5[1] = 0
                set this.PlayerDamageCount5[2] = 0
                set this.PlayerDamageCount5[3] = 0
                set this.PlayerDamageCount5[4] = 0
                set this.PlayerDamageCount5[5] = 0
            elseif this.currentIndex == 6 then
                set this.PlayerDamageCount6[0] = 0
                set this.PlayerDamageCount6[1] = 0
                set this.PlayerDamageCount6[2] = 0
                set this.PlayerDamageCount6[3] = 0
                set this.PlayerDamageCount6[4] = 0
                set this.PlayerDamageCount6[5] = 0
            elseif this.currentIndex == 7 then
                set this.PlayerDamageCount7[0] = 0
                set this.PlayerDamageCount7[1] = 0
                set this.PlayerDamageCount7[2] = 0
                set this.PlayerDamageCount7[3] = 0
                set this.PlayerDamageCount7[4] = 0
                set this.PlayerDamageCount7[5] = 0
            elseif this.currentIndex == 8 then
                set this.PlayerDamageCount8[0] = 0
                set this.PlayerDamageCount8[1] = 0
                set this.PlayerDamageCount8[2] = 0
                set this.PlayerDamageCount8[3] = 0
                set this.PlayerDamageCount8[4] = 0
                set this.PlayerDamageCount8[5] = 0
            elseif this.currentIndex == 9 then
                set this.PlayerDamageCount9[0] = 0
                set this.PlayerDamageCount9[1] = 0
                set this.PlayerDamageCount9[2] = 0
                set this.PlayerDamageCount9[3] = 0
                set this.PlayerDamageCount9[4] = 0
                set this.PlayerDamageCount9[5] = 0
            elseif this.currentIndex == 10 then
                set this.PlayerDamageCount0[0] = 0
                set this.PlayerDamageCount0[1] = 0
                set this.PlayerDamageCount0[2] = 0
                set this.PlayerDamageCount0[3] = 0
                set this.PlayerDamageCount0[4] = 0
                set this.PlayerDamageCount0[5] = 0
                set this.currentIndex = 0
            endif

            loop
                set maxDamage = 0
                set maxDamage = maxDamage + this.PlayerDamageCount0[index]
                set maxDamage = maxDamage + this.PlayerDamageCount1[index]
                set maxDamage = maxDamage + this.PlayerDamageCount2[index]
                set maxDamage = maxDamage + this.PlayerDamageCount3[index]
                set maxDamage = maxDamage + this.PlayerDamageCount4[index]
                set maxDamage = maxDamage + this.PlayerDamageCount5[index]
                set maxDamage = maxDamage + this.PlayerDamageCount6[index]
                set maxDamage = maxDamage + this.PlayerDamageCount7[index]
                set maxDamage = maxDamage + this.PlayerDamageCount8[index]
                set maxDamage = maxDamage + this.PlayerDamageCount9[index]

                if maxDamage2 <= maxDamage then
                    set this.NowAggro = index
                    set maxDamage2 = maxDamage
                endif
                
                set index = index + 1
                exitwhen index == MaxPlayer
            endloop
            call BJDebugMsg( "현재 어그로 번호 : " + I2S(this.NowAggro) )
        endmethod
        
        method onDestroy takes nothing returns nothing
            call this.AggroCheckTimer.pause()
            call this.AggroCheckTimer.destroy()
        endmethod

        static method create takes nothing returns thistype
            local thistype this = thistype.allocate()
            local integer i = 0
            
            loop
                exitwhen i == MaxPlayer
                set this.PlayerDamageCount0[i] = 0
                set this.PlayerDamageCount1[i] = 0
                set this.PlayerDamageCount2[i] = 0
                set this.PlayerDamageCount3[i] = 0
                set this.PlayerDamageCount4[i] = 0
                set this.PlayerDamageCount5[i] = 0
                set this.PlayerDamageCount6[i] = 0
                set this.PlayerDamageCount7[i] = 0
                set this.PlayerDamageCount8[i] = 0
                set this.PlayerDamageCount9[i] = 0
                set i = i + 1
            endloop

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