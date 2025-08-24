scope HeroNarA
globals
    //쉐클시간
    private constant real Time2 = 1.4
    //버프지속시간,공증량
    private constant real Time3 = 60
    private constant integer Velue2 = 350
    private constant real CancelTime = 1.00
    boolean array IsCastingNarA
endglobals


private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillFx fx = t.data

    if IsCastingNarA[fx.pid] == true then
        if Hero_Buff[fx.pid] == 0 then
            if HeroSkillLevel[fx.pid][4] >= 2 then
                call BuffNar01.Apply( fx.caster, Time3 * 1.5, Velue2 )
            else
                call BuffNar01.Apply( fx.caster, Time3, Velue2 )
            endif
        endif

        if HeroSkillLevel[fx.pid][4] >= 1 then
            if HeroSkillLevel[fx.pid][4] >= 3 then
                if GetRandomInt(0,1) == 1 then
                    call NarNabiPlus(fx.pid,6)
                endif
            else
                call NarNabiPlus(fx.pid,3)
            endif
        endif

        call CooldownFIX2(fx.caster,'A02M',HeroSkillCD4[14])

        set IsCastingNarA[fx.pid] = false
        
        call fx.Stop()
        call t.destroy()
    else
        set IsCastingNarA[fx.pid] = false
        call CooldownSet(fx.caster,'A02M', CancelTime)
        call fx.Stop()
        call t.destroy()
    endif
endfunction

private function Main takes nothing returns nothing
    local tick t
    local SkillFx fx

    if GetSpellAbilityId() == 'A02M' then
        set t = tick.create(0)
        set fx = SkillFx.Create()
        set fx.caster = GetTriggerUnit()
        set fx.pid = GetPlayerId(GetOwningPlayer(fx.caster))
        set fx.speed = ((100+SkillSpeed(fx.pid))/100)

        call Sound3D(fx.caster,'A03S')
        call Sound3D(fx.caster,'A04H')

        call DummyMagicleash(fx.caster, Time2 /fx.speed)
        call AnimationStart3(fx.caster, 3, (100+fx.speed)/100)

        set IsCastingNarA[fx.pid] = true

        set t.data = fx
        call t.start( Time2 /fx.speed , false, function EffectFunction )
    endif
endfunction
    
private function ASyncData takes nothing returns nothing
    local player p=(DzGetTriggerSyncPlayer())
    local string data=(DzGetTriggerSyncData())
    local integer pid=GetPlayerId(p)
    local integer dataLen=StringLength(data)
    local integer valueLen
    local real x
    local real y
    local real angle
    
    if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID4[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
        set x=S2R(data)
        set valueLen=StringLength(R2S(x))
        set data=SubString(data,valueLen+1,dataLen)
        set dataLen=dataLen-(valueLen+1)
        set y=S2R(data)
        set pid=GetPlayerId(p)
        set angle = AngleWBP(MainUnit[pid],x,y)
        call SetUnitFacing(MainUnit[pid],angle)
        call EXSetUnitFacing(MainUnit[pid],angle)
        call IssuePointOrder( MainUnit[pid], "ancestralspirittarget", x, y )
    endif

    set p=null
endfunction

            
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("NarA"),(false))
    call TriggerAddAction(t,function ASyncData)

    set t = null
//! runtextmacro 이벤트_끝()
endscope

