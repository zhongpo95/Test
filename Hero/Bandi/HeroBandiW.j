scope HeroBandiW
globals
    private constant real SD = 0.00

    //폼전환강화 유지시간
    //constant real NarChangeTime = 0.75
    //카구라 강화전환시간
    private constant real Time = 1.5
    //카구라 강화전환사출, 타수
    private constant real Time3 = 1.1

    private constant real TICK2 = 10
    //겐지 강화전환시간
    private constant real Time2 = 1.6
    private constant real scale2 = 1500
    private constant real distance2 = 900
    private constant real scale3 = 800
    private constant real distance3 = 650
    
    //범위체크
    private group CheckG
    //더미 유닛
    private unit CheckU
    //이동거리
    private constant real TICK = 20
    private constant real scale = 300
    private constant real distance = 175
    private boolean StackChecker
endglobals


private struct SkillRarW
    unit caster
    unit dummy
    real TargetX
    real TargetY
    integer pid
    integer i
    real r
    real Angle
    integer index
    real speed
    real Aspeed
    real A2speed
    party ul
    private method OnStop takes nothing returns nothing
        set caster = null
        set dummy = null
        set TargetX = 0
        set TargetY = 0
        set pid = 0
        set i = 0
        set Angle = 0
        set r = 0
        set index = 0
        set speed = 0
        set Aspeed = 0
        set A2speed = 0
    endmethod
    //! runtextmacro 연출()
endstruct

private function Main takes nothing returns nothing
    local unit caster
    local integer pid
    local tick t
    local SkillRarW fx
    
    if GetSpellAbilityId() == 'A06L' then
        set caster = GetTriggerUnit()
        set pid = GetPlayerId(GetOwningPlayer(caster))
        
        call BanBisulPlus(GetPlayerId(GetOwningPlayer(GetTriggerUnit())),1)
        //call CooldownFIX(GetTriggerUnit(),'A06H',HeroSkillCD0[15])
        call CooldownFIX(GetTriggerUnit(),'A06L',0.5)
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
        if GetUnitAbilityLevel(MainUnit[pid],'A06N') < 1 then
            set x=S2R(data)
            set valueLen=StringLength(R2S(x))
            set data=SubString(data,valueLen+1,dataLen)
            set dataLen=dataLen-(valueLen+1)
            set y=S2R(data)
            set pid=GetPlayerId(p)
            set angle = AngleWBP(MainUnit[pid],x,y)
            call SetUnitFacing(MainUnit[pid],angle)
            call EXSetUnitFacing(MainUnit[pid],angle)
            call IssuePointOrder( MainUnit[pid], "acolyteharvest", x, y )
        endif
    endif

    set p=null
endfunction

            
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("BandiW"),(false))
    call TriggerAddAction(t,function WSyncData)

    set t = null
//! runtextmacro 이벤트_끝()
endscope

