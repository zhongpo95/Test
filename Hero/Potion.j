scope Potion
    globals
        private constant real MaxRange = 600

        private constant real scale = 450
        private constant real distance = 300
    endglobals
    
    private struct FxEffect
        unit caster
        integer pid
        effect e
        private method OnStop takes nothing returns nothing
            set caster = null
            set pid = 0
            set e = null
        endmethod
        //! runtextmacro 연출()
    endstruct

    private function splashD takes nothing returns nothing
        if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
            call HeroDeal(2,splash.source,GetEnumUnit(),1,false,false,false,false)
        endif
    endfunction
    
    private function EffectFunction2 takes nothing returns nothing
        local tick t = tick.getExpired()
        local FxEffect fx = t.data
    
        call DestroyEffect(fx.e)
        call SetUnitVertexColorBJ( fx.caster, 100, 100, 100, 0 )
        
        call fx.Stop()
        call t.destroy()
    endfunction
    
    private function EffectFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        local FxEffect fx = t.data
    
        set Hero_Damage[fx.pid] = Hero_Damage[fx.pid] - Hero_Buff2[fx.pid]
        set Hero_Buff2[fx.pid] = 0
        set Hero_BuffMoveSpeed[fx.pid] = Hero_BuffMoveSpeed[fx.pid] - 20.00
        set Hero_BuffAttackSpeed[fx.pid] = Hero_BuffAttackSpeed[fx.pid] - 20.00
        call ItemUIStatsSet(fx.pid)
        
        call fx.Stop()
        call t.destroy()
    endfunction

    private function Main takes nothing returns nothing
        local unit caster
        local string items
        local integer pid
        local integer j
        local tick t
        local FxEffect fx
        local string sn
        
        if GetSpellAbilityId() == 'A01R' then
            set caster = GetTriggerUnit()
            set pid = GetPlayerId(GetOwningPlayer(caster))
            set sn = I2S(PlayerSlotNumber[pid])
            
            call SetUnitState(caster, UNIT_STATE_LIFE, GetUnitState(caster,UNIT_STATE_LIFE) + ( GetUnitState(caster,UNIT_STATE_MAX_LIFE) * 0.6 ) )
            call RefreshHP(caster)

            set j = GetItemCharge(StashLoad(PLAYER_DATA[pid], "슬롯"+sn+".포션1", "0"))
            set items = StashLoad(PLAYER_DATA[pid], "슬롯"+sn+".포션1", "0")
            set items = SetItemCharge(items, j-1)
            call StashSave(PLAYER_DATA[pid], "슬롯"+sn+".포션1", items)
            
            set caster = null
        endif
        
        if GetSpellAbilityId() == 'A01S' then
            set caster = GetTriggerUnit()
            set pid = GetPlayerId(GetOwningPlayer(caster))
            set sn = I2S(PlayerSlotNumber[pid])
            
            call UnitEffectTimeEX('e00Z',GetSpellTargetX(), GetSpellTargetY(),270,1.00)
            call DestroyEffect( AddSpecialEffect("Abilities\\Spells\\Undead\\ReplenishHealth\\ReplenishHealthCaster.mdl", GetSpellTargetX(), GetSpellTargetY() ) )
            call splash.range( splash.ENEMY, caster, GetSpellTargetX(), GetSpellTargetY(), scale, function splashD )
            call DummyMagicleash3(caster,0.3)
            call AnimationStringStart(caster,"Attack")
            
            set j = GetItemCharge(StashLoad(PLAYER_DATA[pid], "슬롯"+sn+".포션2", "0"))
            set items = StashLoad(PLAYER_DATA[pid], "슬롯"+sn+".포션2", "0")
            set items = SetItemCharge(items, j-1)
            call StashSave(PLAYER_DATA[pid], "슬롯"+sn+".포션2", items)
            set caster = null
        endif
        
        if GetSpellAbilityId() == 'A01T' then
            set caster = GetTriggerUnit()
            set pid = GetPlayerId(GetOwningPlayer(caster))
            set sn = I2S(PlayerSlotNumber[pid])
            
            set t = tick.create(0) 
            set fx = FxEffect.Create()
            set fx.caster = GetTriggerUnit()
            set fx.e = AddSpecialEffectTarget("Abilities\\Spells\\Human\\DivineShield\\DivineShieldTarget.mdl",fx.caster,"origin")
            set t.data = fx
            call BuffNoDM.Apply( fx.caster,3.5, 0 )
            call DummyMagicleash3(fx.caster,3.5)
            call SetUnitVertexColorBJ( fx.caster, 33, 33, 33, 0 )
            
            call t.start( 3.5, false, function EffectFunction2 ) 
            
            
            set j = GetItemCharge(StashLoad(PLAYER_DATA[pid], "슬롯"+sn+".포션3", "0"))
            set items = StashLoad(PLAYER_DATA[pid], "슬롯"+sn+".포션3", "0")
            set items = SetItemCharge(items, j-1)
            call StashSave(PLAYER_DATA[pid], "슬롯"+sn+".포션3", items)
            set caster = null
        endif
        
        if GetSpellAbilityId() == 'A01U' then
            set caster = GetTriggerUnit()
            set pid = GetPlayerId(GetOwningPlayer(caster))
            set sn = I2S(PlayerSlotNumber[pid])
            
            set t = tick.create(0) 
            set fx = FxEffect.Create()
            set fx.caster = GetTriggerUnit()
            set fx.pid = pid
            
            if GetUnitState(caster,UNIT_STATE_LIFE) - ( GetUnitState(caster,UNIT_STATE_MAX_LIFE) * 0.25 ) <= 0 then
                call SetUnitState(caster, UNIT_STATE_LIFE, 1 )
            else
                call SetUnitState(caster, UNIT_STATE_LIFE, GetUnitState(caster,UNIT_STATE_LIFE) - ( GetUnitState(caster,UNIT_STATE_MAX_LIFE) * 0.25 ) )
            endif
            
            call RefreshHP(caster)
            
            set Hero_Buff2[pid] = R2I( Equip_Damage[pid] ) * 0.30
            set Hero_Damage[pid] = Hero_Damage[pid] + Hero_Buff2[pid]
            set Hero_BuffMoveSpeed[pid] = Hero_BuffMoveSpeed[pid] + 20.00
            set Hero_BuffAttackSpeed[pid] = Hero_BuffAttackSpeed[pid] + 20.00
            call ItemUIStatsSet(fx.pid)
            
            set t.data = fx
            call t.start( 10, false, function EffectFunction ) 
            
            
            set j = GetItemCharge(StashLoad(PLAYER_DATA[pid], "슬롯"+sn+".포션4", "0"))
            set items = StashLoad(PLAYER_DATA[pid], "슬롯"+sn+".포션4", "0")
            set items = SetItemCharge(items, j-1)
            call StashSave(PLAYER_DATA[pid], "슬롯"+sn+".포션4", items)
            set caster = null
        endif
        
    endfunction
    
    private function PS1Data takes nothing returns nothing
        local player p=(DzGetTriggerSyncPlayer())
        local string data=(DzGetTriggerSyncData())
        local integer pid
        local integer dataLen=StringLength(data)
        local integer valueLen
        local real x
        local real y
        local real angle
        
        set pid=GetPlayerId(p)
            
        if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], potion[1]), ABILITY_STATE_COOLDOWN) == 0 and GetItemCharges(PlayerItem1[pid]) > 0 then
            set x=S2R(data)
            set valueLen=StringLength(R2S(x))
            set data=SubString(data,valueLen+1,dataLen)
            set dataLen=dataLen-(valueLen+1)
            set y=S2R(data)
            set pid=GetPlayerId(p)
            set angle = AngleWBP(MainUnit[pid],x,y)
            call SetUnitFacing(MainUnit[pid],angle)
            call EXSetUnitFacing(MainUnit[pid],angle)
            call UnitUseItemPoint( MainUnit[pid], PlayerItem1[pid], x, y )
        endif
        
        set p=null
    endfunction
    private function PS2Data takes nothing returns nothing
        local player p=(DzGetTriggerSyncPlayer())
        local string data=(DzGetTriggerSyncData())
        local integer pid
        local integer dataLen=StringLength(data)
        local integer valueLen
        local real x
        local real y
        local real angle
        
        set pid=GetPlayerId(p)
            
        if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], potion[2]), ABILITY_STATE_COOLDOWN) == 0 and GetItemCharges(PlayerItem2[pid]) > 0 then
            set x=S2R(data)
            set valueLen=StringLength(R2S(x))
            set data=SubString(data,valueLen+1,dataLen)
            set dataLen=dataLen-(valueLen+1)
            set y=S2R(data)
            set pid=GetPlayerId(p)
            set angle = AngleWBP(MainUnit[pid],x,y)
            call SetUnitFacing(MainUnit[pid],angle)
            call EXSetUnitFacing(MainUnit[pid],angle)
            
            if DistanceWBP(MainUnit[pid],x,y) <= MaxRange then
                call UnitUseItemPoint( MainUnit[pid], PlayerItem2[pid], x, y )
            else
                call UnitUseItemPoint( MainUnit[pid], PlayerItem2[pid], GetWidgetX(MainUnit[pid]) + PolarX(MaxRange,angle), GetWidgetY(MainUnit[pid]) + PolarY(MaxRange,angle) )
            endif
            
        endif
        
        set p=null
    endfunction
    private function PS3Data takes nothing returns nothing
        local player p=(DzGetTriggerSyncPlayer())
        local string data=(DzGetTriggerSyncData())
        local integer pid
        local integer dataLen=StringLength(data)
        local integer valueLen
        local real x
        local real y
        local real angle
        
        set pid=GetPlayerId(p)
            
        if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], potion[3]), ABILITY_STATE_COOLDOWN) == 0 and GetItemCharges(PlayerItem3[pid]) > 0 then
            set x=S2R(data)
            set valueLen=StringLength(R2S(x))
            set data=SubString(data,valueLen+1,dataLen)
            set dataLen=dataLen-(valueLen+1)
            set y=S2R(data)
            set pid=GetPlayerId(p)
            set angle = AngleWBP(MainUnit[pid],x,y)
            call SetUnitFacing(MainUnit[pid],angle)
            call EXSetUnitFacing(MainUnit[pid],angle)
            call UnitUseItemPoint( MainUnit[pid], PlayerItem3[pid], x, y )
        endif
        
        set p=null
    endfunction
    private function PS4Data takes nothing returns nothing
        local player p=(DzGetTriggerSyncPlayer())
        local string data=(DzGetTriggerSyncData())
        local integer pid
        local integer dataLen=StringLength(data)
        local integer valueLen
        local real x
        local real y
        local real angle
        
        set pid=GetPlayerId(p)
            
        if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], potion[4]), ABILITY_STATE_COOLDOWN) == 0 and GetItemCharges(PlayerItem4[pid]) > 0 then
            set x=S2R(data)
            set valueLen=StringLength(R2S(x))
            set data=SubString(data,valueLen+1,dataLen)
            set dataLen=dataLen-(valueLen+1)
            set y=S2R(data)
            set pid=GetPlayerId(p)
            set angle = AngleWBP(MainUnit[pid],x,y)
            call SetUnitFacing(MainUnit[pid],angle)
            call EXSetUnitFacing(MainUnit[pid],angle)
            call UnitUseItemPoint( MainUnit[pid], PlayerItem4[pid], x, y )
        endif
        
        set p=null
    endfunction

            
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("PS1"),(false))
    call TriggerAddAction(t,function PS1Data)
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("PS2"),(false))
    call TriggerAddAction(t,function PS2Data)
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("PS3"),(false))
    call TriggerAddAction(t,function PS3Data)
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("PS4"),(false))
    call TriggerAddAction(t,function PS4Data)

    set t = null
//! runtextmacro 이벤트_끝()
endscope