scope HeroChenV
globals
    private constant real CoolTime = 2.0
    
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

    private struct EFst
        unit caster
        unit target
        real time
        real time2
        integer id
        real r
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

    


    private function Effunction4 takes nothing returns nothing
        local tick t = tick.getExpired()
        local EFst fx = t.data
        
        call SetUnitTimeScale(fx.caster, 100 * 0.01)
        call KillUnit(fx.caster)
        set fx.caster = null
        set fx.target = null

        call fx.destroy()
        call t.destroy()
    endfunction

    private function Effunction3 takes nothing returns nothing
        local tick t = tick.getExpired()
        local EFst fx = t.data
        
        call SetUnitTimeScale(fx.caster, 0 * 0.01)

        call t.start(fx.time, false, function Effunction4 )
    endfunction

    private function Effunction2 takes nothing returns nothing
        local tick t = tick.getExpired()
        local EFst fx = t.data
        
        set fx.caster = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), fx.id, GetUnitX(fx.target), GetUnitY(fx.target), fx.r)
        call UnitAddAbility(fx.caster,'Arav')
        call UnitRemoveAbility(fx.caster,'Arav')
        call SetUnitFlyHeight(fx.caster, GetRandomReal(125,275), 0)

        call t.start(0.2, false, function Effunction3 )
    endfunction

    private function StopEft takes unit target, integer id, real r, real time, real time2 returns nothing
        local tick t = tick.create(0)
        local EFst fx = EFst.create()
        
        set fx.id = id
        set fx.target = target
        set fx.r = r
        set fx.time = time2
        set t.data = fx

        call t.start(time, false, function Effunction2 )
    endfunction

    private function Main takes nothing returns nothing
        local tick t
        local FxEffect fx
        local party ul
        if GetSpellAbilityId() == 'A01F' then
            set t = tick.create(0)
            set fx = FxEffect.Create()
            set fx.caster = GetTriggerUnit()
            set fx.target = null
            set t.data = fx

            set PlayerVCount[GetPlayerId(GetOwningPlayer(fx.caster))] = 1

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

            call Sound3D(fx.caster,'A02E')

            call StopEft(fx.target, 'e01Y', GetRandomReal(0,360), 0.75, 2.25)
            call StopEft(fx.target, 'e01Y', GetRandomReal(0,360), 0.95, 2.05)
            call StopEft(fx.target, 'e01Y', GetRandomReal(0,360), 1.15, 1.85)
            call StopEft(fx.target, 'e01Y', GetRandomReal(0,360), 1.25, 1.75)
            call StopEft(fx.target, 'e01Y', GetRandomReal(0,360), 1.48, 1.42)
            call StopEft(fx.target, 'e01Y', GetRandomReal(0,360), 1.70, 1.30)
            call StopEft(fx.target, 'e01Y', GetRandomReal(0,360), 2.00, 1.00)
            call StopEft(fx.target, 'e01Y', GetRandomReal(0,360), 2.10, 0.90)
            call StopEft(fx.target, 'e01Y', GetRandomReal(0,360), 2.40, 0.60)
            call DelayCreate(fx.target, 'e01Z', GetRandomReal(0,360), 3.0 )
            call DelayCreate(fx.target, 'e021', GetRandomReal(0,360), 3.0 )
            call AnimationStart(fx.caster,11)
            call SetUnitFacing(fx.caster,Angle.WBW(fx.caster,fx.target))
            call EXSetUnitFacing(fx.caster,Angle.WBW(fx.caster,fx.target))

            call DelayAlpha(fx.caster, 0.60)
            call DelayRemoveAlpha2(fx.caster, 3.0 )

            call DummyMagicleash(fx.caster, 3.0 )

            call TriggerSleepActionByTimer(3.0)
            call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 30 )
            
            
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