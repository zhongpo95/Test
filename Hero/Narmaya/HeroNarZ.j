scope HeroNarZ

globals
    private constant real CoolTime = 1.0

    integer array NarForm
    integer array NarStack
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
        local integer i
        
        if GetSpellAbilityId() == 'A02S' then
            set caster = GetTriggerUnit()
            //쿨타임조정
            call CooldownFIX(caster,'A02S',CoolTime)
            set i = IndexUnit(caster)

            if NarForm[i] != 0 then
                //카구라
                set NarForm[i] = 0
                call AddUnitAnimationProperties(caster, "Gold", true)
                call AddUnitAnimationProperties(caster, "Alternate", true)
                //사운드
                if GetRandomInt(0,1) == 1 then
                    call Sound3D(caster,'A02T')
                else
                    call Sound3D(caster,'A02U')
                endif
                //표기변경
                if GetLocalPlayer() == GetOwningPlayer(caster) then
                    call DzFrameSetTexture(NarAden,"Narmaya_blue.blp",0)
                    //call DzFrameSetModel(NarAden2, "Narmaya_blue.mdx", 0, 0)
                    call BJDebugMsg("카구라")
                endif
            else
                //겐지
                set NarForm[i] = 1
                call AddUnitAnimationProperties(caster, "Gold", false)
                call AddUnitAnimationProperties(caster, "Alternate", false)
                //사운드
                if GetRandomInt(0,1) == 1 then
                    call Sound3D(caster,'A02V')
                else
                    call Sound3D(caster,'A02W')
                endif
                //표기변경
                if GetLocalPlayer() == GetOwningPlayer(caster) then
                    call DzFrameSetTexture(NarAden,"Narmaya_pink.blp",0)
                    //call DzFrameSetModel(NarAden2, "Narmaya_pink.mdx", 0, 0)
                    call BJDebugMsg("겐지")
                endif
            endif
            set caster = null
        endif
    endfunction

    private function ZSyncData takes nothing returns nothing
        local player p=(DzGetTriggerSyncPlayer())
        local string data=(DzGetTriggerSyncData())
        local integer pid
        local integer dataLen=StringLength(data)
        local integer valueLen
        local real x
        local real y
        local real angle

        set pid=GetPlayerId(p)
        
        if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID10[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
            set x=S2R(data)
            set valueLen=StringLength(R2S(x))
            set data=SubString(data,valueLen+1,dataLen)
            set dataLen=dataLen-(valueLen+1)
            set y=S2R(data)
            set pid=GetPlayerId(p)
            set angle = Angle.WBP(MainUnit[pid],x,y)
            call SetUnitFacing(MainUnit[pid],angle)
            call EXSetUnitFacing(MainUnit[pid],angle)
            call IssuePointOrder( MainUnit[pid], "autodispel", x, y )
        endif
        
        set p=null
    endfunction

            
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("NarZ"),(false))
    call TriggerAddAction(t,function ZSyncData)

    set t = null
//! runtextmacro 이벤트_끝()
endscope