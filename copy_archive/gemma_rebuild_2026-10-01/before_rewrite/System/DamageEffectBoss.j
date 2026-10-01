library DamageEffect2 requires DataUnit,UIBossHP,AttackAngle,BuffData,DataPrototype
    globals
        //1초 넉백
        constant real ConZVelo = 15.0
        //기본경직시간 0.5
        constant real ConStun = 0.5
        
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
        
        local integer card = PROTO_CARD_FIRST
        local real reduction = 0.0
        if ExpPrototypeActive and pid >= 0 and pid < 4 and ExpMember[pid] then
            if ProtoPaused[pid] or ProtoReady[pid] then
                return
            endif
            loop
                exitwhen card > PROTO_CARD_LAST
                if ExpCardOwned[ExpKey(pid, card)] and ProtoCardKind[card] == 4 then
                    set reduction = reduction + ProtoCardValue[card]
                endif
                if ExpState == EXP_HUNT and rate > 0.0 and ExpCardOwned[ExpKey(pid, card)] and not ProtoEvolved[ExpKey(pid, card)] and ProtoEvolutionKind[card] == 3 then
                    set ProtoCardProgress[ExpKey(pid, card)] = 0.0
                endif
                set card = card + 1
            endloop
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
