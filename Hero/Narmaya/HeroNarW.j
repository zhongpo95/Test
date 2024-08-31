scope HeroNarW
globals
    private constant real CoolTime = 1.00

    integer array NarForm
    integer array NarStack
    unit array NarFormG
    unit array NarFormC
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
    

    if GetSpellAbilityId() == 'A02J' then
        set caster = GetTriggerUnit()
        set i = IndexUnit(caster)
        
        if NarForm[i] != 0 then
            //카구라
            set NarForm[i] = 0
            set NarStack[GetPlayerId(GetOwningPlayer(GetTriggerUnit()))] = 0
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
            endif
            if not IsUnitDeadVJ(NarFormG[i]) then
                call KillUnit(NarFormG[i])
            endif
            set NarFormC[i] = CreateUnit(GetOwningPlayer(caster),'e028',0,0,0)
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
            endif
            if not IsUnitDeadVJ(NarFormC[i]) then
                call KillUnit(NarFormC[i])
            endif
            set NarFormG[i] = CreateUnit(GetOwningPlayer(caster),'e027',0,0,0)
        endif

        //쿨타임조정
        call CooldownFIX(caster,'A02J',CoolTime)
        set caster = null
    endif
endfunction
    
private function WSyncData takes nothing returns nothing
    local player p=(DzGetTriggerSyncPlayer())
    local string data=(DzGetTriggerSyncData())
    local integer pid=GetPlayerId(p)
    local integer dataLen=StringLength(data)
    local integer valueLen
    local real x
    local real y
    local real angle

    if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID1[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
        set x=S2R(data)
        set valueLen=StringLength(R2S(x))
        set data=SubString(data,valueLen+1,dataLen)
        set dataLen=dataLen-(valueLen+1)
        set y=S2R(data)
        set pid=GetPlayerId(p)
        set angle = Angle.WBP(MainUnit[pid],x,y)
        call SetUnitFacing(MainUnit[pid],angle)
        call EXSetUnitFacing(MainUnit[pid],angle)
        call IssuePointOrder( MainUnit[pid], "acolyteharvest", x, y )
    endif

    set p=null
endfunction

private function WSyncData2 takes nothing returns nothing
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
    call DzTriggerRegisterSyncData(t,("NarW"),(false))
    call TriggerAddAction(t,function WSyncData)
    
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("NarW2"),(false))
    call TriggerAddAction(t,function WSyncData2)

    set t = null
//! runtextmacro 이벤트_끝()
endscope

