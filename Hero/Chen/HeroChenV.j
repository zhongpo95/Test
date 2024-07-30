scope HeroChenV
globals
    private constant real CoolTime = 30.0
    
    private player filterP = null
endglobals

    private struct FxEffect
        unit caster
        unit target
        private method OnStop takes nothing returns nothing
            set target = null
            set caster = null
        endmethod
        //! runtextmacro 연출()
    endstruct

    private function filterE takes nothing returns boolean
        //중립아님
        if GetOwningPlayer(GetFilterUnit()) == Player(PLAYER_NEUTRAL_PASSIVE) then
            return false
        endif
        //트작유 아님
        if not IsUnitEnemy( GetFilterUnit(), filterP ) then
            return false
        endif
        //살아있음
        if IsUnitType( GetFilterUnit(), UNIT_TYPE_DEAD ) then
            return false
        endif
        //소환됨아님
        if IsUnitType( GetFilterUnit(), UNIT_TYPE_SUMMONED ) then
            return false
        endif
        //일꾼임
        if not IsUnitType( GetFilterUnit(), UNIT_TYPE_PEON ) then
            return false
        endif
        
        return true
    
    endfunction

    private function Main takes nothing returns nothing
        local tick t
        local FxEffect fx
        local party ul
        if GetSpellAbilityId() == 'A01F' then
            set t = t.create(0)
            set fx = FxEffect.Create()
            set fx.caster = GetTriggerUnit()
            set fx.target = null
            set t.data = fx

            //쿨타임조정
            call CooldownFIX(GetTriggerUnit(),'A01F',CoolTime)
            //V UI 제거
            call DzFrameShow(Ogiframe_1, false)
            call DzFrameShow(Ogiframe_2, false)
            call DzFrameShow(Ogiframe_3, false)
            call DzFrameShow(Ogiframe_4, false)

            //4500범위 대상 찾기
            set ul = party.create()
            set filterP = GetOwningPlayer(fx.caster)
            call GroupEnumUnitsInRange( ul.super, GetUnitX(fx.caster), GetUnitY(fx.caster), 4500, Filter( function filterE ) )
            set filterP = null
            set fx.target = FirstOfGroup(ul.super)
            call ul.destroy()

            //이펙트생성
            //이펙트생성
            //이펙트생성
            //이펙트생성
            //이펙트생성
            //이펙트생성
            //이펙트생성


            //t.start()
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
endscope