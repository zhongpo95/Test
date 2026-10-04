library DamageEffect2 requires DataUnit,UIBossHP,AttackAngle,BuffData,DataPrototype
    globals
        //1초 넉백
        constant real ConZVelo = 15.0
        //기본경직시간 0.5
        constant real ConStun = 0.5

        // 패리 자세: 켜져 있으면 보스 공격을 무효로 하고 HeroParryTrigger를 평가한다.
        boolean array HeroParryOn
        trigger HeroParryTrigger = CreateTrigger()
        integer HeroParryPid = -1
        unit HeroParrySource = null
        // 받는 피해 감소(%)
        real array HeroDamageReduce
    endglobals
    
    //때린유닛,맞은유닛,데미지,경직유무
    function BossDeal takes unit source, unit target, real rate, boolean Damagetype returns nothing
        local integer pid = GetPlayerId(GetOwningPlayer(target))
        local integer UnitIndex = IndexUnit(target)
        //local real ut = UnitTier[DataUnitIndex(source)]
        //local real put = Equip_Defense[pid] + Arcana_Defense[pid]
        //local real rateut = (ut - put) * 2
        //local real rateut = (ut) * 2
        
        //if rateut > 0 then
            //set rate = rate * ( 1 + ( rateut / 10 ) )
        //endif
        
        local real reduction = 0.0
        if pid >= 0 and pid < 12 and HeroParryOn[pid] then
            set HeroParryPid = pid
            set HeroParrySource = source
            call TriggerEvaluate(HeroParryTrigger)
            set HeroParrySource = null
            return
        endif
        if pid >= 0 and pid < 12 and HeroDamageReduce[pid] > 0 then
            set rate = rate * (1.0 - RMinBJ(80.0, HeroDamageReduce[pid]) / 100.0)
        endif
        if ExpPrototypeActive and pid >= 0 and pid < 4 and ExpMember[pid] then
            if ProtoPaused[pid] or ProtoReady[pid] then
                return
            endif
            set reduction = ProtoStat(pid, PROTO_STAT_REDUCTION)
            if ExpState == EXP_HUNT and rate > 0.0 then
                call ProtoResetSafeProgress(pid)
            endif
            set rate = rate * (1.0 - RMinBJ(60.0, reduction) / 100.0)
            if ExpState == EXP_HUNT and rate > 0.0 then
                set ProtoSafeTime[pid] = 0.0
            endif
        endif
        //쉴드가 없음
        if UnitSD[UnitIndex] == 0 then
            call UnitDamageTarget(source,target,rate,true,true,ATTACK_TYPE_CHAOS,DAMAGE_TYPE_UNIVERSAL,WEAPON_TYPE_WHOKNOWS)
        //쉴드가 있음
        else
            //피해량보다 쉴드량이 더큼
            if UnitSD[UnitIndex] >= rate then
                set UnitSD[UnitIndex] = UnitSD[UnitIndex] - rate
            //쉴드량보다 피해량이 더큼
            else
                set rate = rate - UnitSD[UnitIndex]
                set UnitSD[UnitIndex] = 0
                call UnitDamageTarget(source,target,rate,true,true,ATTACK_TYPE_CHAOS,DAMAGE_TYPE_UNIVERSAL,WEAPON_TYPE_WHOKNOWS)
            endif
        endif
        if Damagetype then
            call CustomStun.Stun2(target, ConStun)
        endif
        call RefreshHP(target)
    endfunction
endlibrary
