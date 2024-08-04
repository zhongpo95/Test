scope HeroNarC

globals
    private constant real CoolTime = 5.0
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
        if GetSpellAbilityId() == 'A02R' then
            //쿨타임조정
            call CooldownFIX(GetTriggerUnit(),'A02R',CoolTime)
        endif
    endfunction


    private function CSyncData takes nothing returns nothing
        local player p=(DzGetTriggerSyncPlayer())
        local string data=(DzGetTriggerSyncData())
        local integer pid
        local integer dataLen=StringLength(data)
        local integer valueLen
        local real x
        local real y
        local real angle

        set pid=GetPlayerId(p)
        
        if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID9[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
            set x=S2R(data)
            set valueLen=StringLength(R2S(x))
            set data=SubString(data,valueLen+1,dataLen)
            set dataLen=dataLen-(valueLen+1)
            set y=S2R(data)
            set pid=GetPlayerId(p)
            set angle = Angle.WBP(MainUnit[pid],x,y)
            call SetUnitFacing(MainUnit[pid],angle)
            call EXSetUnitFacing(MainUnit[pid],angle)
            call IssuePointOrder( MainUnit[pid], "auravampiric", x, y )
        endif
        
        set p=null
    endfunction

            
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("NarC"),(false))
    call TriggerAddAction(t,function CSyncData)

    set t = null
//! runtextmacro 이벤트_끝()
endscope