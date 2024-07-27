//! runtextmacro 콘텐츠("HeroChenV")
globals
    private constant real CoolTime = 30.0
endglobals

    private function Main takes nothing returns nothing
        local unit caster
        if GetSpellAbilityId() == 'A01F' then
            set caster = GetTriggerUnit()
            
            call CooldownFIX(caster,'A01F',CoolTime)
            
            call DzFrameShow(frame4, false)
            call DzFrameShow(frame5, false)
            call DzFrameShow(frame1, false)
            call DzFrameShow(frame3, false)

            //call DzFrameSetModel(frame4, "VFX_HolyLight.mdx", 0, 0)
            //call DzFrameSetModel(frame5, "VFX_ERE_LightningField3Y.mdx", 0, 0)
            //call DzFrameShow(frame1, true)
            //call DzFrameSetModel(frame3, "Empyrean Nova.mdx", 0, 0)
            
            set caster = null
        endif
    endfunction
    
    private function VSyncData takes nothing returns nothing
        local player p=(DzGetTriggerSyncPlayer())
        local string data=(DzGetTriggerSyncData())
        local integer pid
        local integer dataLen=StringLength(data)
        local integer valueLen
        local real x
        local real y
        local real angle

        set pid=GetPlayerId(p)
        
        if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID8[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
            set x=S2R(data)
            set valueLen=StringLength(R2S(x))
            set data=SubString(data,valueLen+1,dataLen)
            set dataLen=dataLen-(valueLen+1)
            set y=S2R(data)
            set pid=GetPlayerId(p)
            set angle = Angle.WBP(MainUnit[pid],x,y)
            call SetUnitFacing(MainUnit[pid],angle)
            call EXSetUnitFacing(MainUnit[pid],angle)
            call IssuePointOrder( MainUnit[pid], "auraunholy", x, y )
        endif
        
        set p=null
    endfunction


//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("ChenV"),(false))
    call TriggerAddAction(t,function VSyncData)

    set t = null
//! runtextmacro 이벤트_끝()
//! runtextmacro 콘텐츠_끝()