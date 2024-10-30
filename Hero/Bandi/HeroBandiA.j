scope HeroBandiA
globals
    //쉐클시간
    private constant real Time2 = 1.4
    //버프지속시간,공증량
    private constant real Time3 = 10
    private constant integer Velue2 = 350
endglobals

    private struct FxEffect
        unit caster
        real TargetX
        real TargetY
        integer pid
        integer i
        real speed
        private method OnStop takes nothing returns nothing
            set caster = null
            set TargetX = 0
            set TargetY = 0
            set pid = 0
            set i = 0
            set speed = 0
        endmethod
        //! runtextmacro 연출()
    endstruct

private function Main takes nothing returns nothing
    local unit caster
    local integer pid
    local real speed

    if GetSpellAbilityId() == 'A02M' then
        set caster = GetTriggerUnit()
        set pid = GetPlayerId(GetOwningPlayer(caster))
        set speed = ((100+SkillSpeed(pid))/100)

        call Sound3D(caster,'A03S')
        call Sound3D(caster,'A04H')

        call DummyMagicleash(caster, Time2 /speed)
        call AnimationStart3(caster, 3, (100+speed)/100)

        if Hero_Buff[pid] == 0 then
            if HeroSkillLevel[pid][4] >= 2 then
                call BuffNar01.Apply( caster, Time3 * 1.5, Velue2 )
            else
                call BuffNar01.Apply( caster, Time3, Velue2 )
            endif
        endif

        if HeroSkillLevel[pid][4] >= 1 then
            if HeroSkillLevel[pid][4] >= 3 then
                if GetRandomInt(0,1) == 1 then
                    call NarNabiPlus(pid,6)
                endif
            else
                call NarNabiPlus(pid,3)
            endif
        endif


        call CooldownFIX(caster,'A02M',HeroSkillCD4[14])
        set caster = null
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

private function ASyncData2 takes nothing returns nothing
    local player p = DzGetTriggerSyncPlayer()
    local integer pid = GetPlayerId(p)
    local real x
    local real y
    local real angle
    local real speed
    local tick t
    local FxEffect fx
    
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
    
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("NarA2"),(false))
    call TriggerAddAction(t,function ASyncData2)

    set t = null
//! runtextmacro 이벤트_끝()
endscope

