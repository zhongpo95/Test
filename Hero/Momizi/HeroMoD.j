scope HeroMoD
globals
    private constant real DR = 15.54
    private constant real SD = 41
    
    private constant real CoolTime = 27.0
    //쉐클시간
    private constant real Time = 1.5
    //스킬이펙트 시간
    private constant real Time2 = 0.50
    //이동거리
    private constant real TICK = 20
    
    //발도 버프 체크
    private real Check = 0
    //범위체크
    private group CheckG
    //더미 유닛
    private unit CheckU

    private constant real scale = 600
    private constant real distance = 400
endglobals

private struct FxEffect
    unit caster
    unit dummy
    unit dummy2
    real Angle
    integer pid
    real Velue
    real speed
    integer i
    party ul
    private method OnStop takes nothing returns nothing
        set caster = null
        set dummy = null
        set dummy2 = null
        set pid = 0
        set Velue = 0
        set speed = 0
        set i = 0
        call ul.destroy()
    endmethod
    //! runtextmacro 연출()
endstruct

private function splashD takes nothing returns nothing
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer level = HeroSkillLevel[pid][6]
    local real velue = 1.0
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        if IsUnitInGroup(GetEnumUnit(),CheckG) == false then
            //뒤는안떄림
            if AngleTrue( GetUnitFacing(CheckU), Angle.WBW(CheckU,GetEnumUnit()), 90 ) then
            
                if level >= 1 then
                    set velue = velue * 1.45
                endif
                
                if level >= 2 then
                    if Check == 1 then
                        set velue = velue * 1.95
                    endif
                endif
                            
                if level >= 3 then
                    set Hero_CriDeal[pid] = Hero_CriDeal[pid] + 210
                    call HeroDeal(splash.source,GetEnumUnit(),DR*velue,false,false,SD,false)
                    set Hero_CriDeal[pid] = Hero_CriDeal[pid] - 210
                else
                    call HeroDeal(splash.source,GetEnumUnit(),DR*velue,false,false,SD,false)
                endif
                call GroupAddUnit(CheckG,GetEnumUnit())
            endif
        endif
    endif
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data
    local real X
    local real Y
    
    set fx.i = fx.i + 1
    
    if fx.i == 1 and ( GetUnitAbilityLevel(fx.caster, 'BPSE') > 0 or GetUnitAbilityLevel(fx.caster, 'A024') > 0 )  then
        call fx.Stop()
        call t.destroy()
    else
        if fx.i == 1 then
            set fx.dummy = UnitEffectTimeEX('e01B', GetWidgetX(fx.caster), GetWidgetY(fx.caster), GetUnitFacing(fx.caster),0.5)
        endif
        
        if fx.i != (TICK+1) then
            set X = GetWidgetX(fx.dummy)
            set Y = GetWidgetY(fx.dummy)
            call SetUnitX(fx.dummy, X + Polar.X( 60, fx.Angle ))
            call SetUnitY(fx.dummy, Y + Polar.Y( 60, fx.Angle ))
            set Check = fx.Velue
            set CheckG = fx.ul.super
            set CheckU = fx.dummy
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.dummy), GetWidgetY(fx.dummy), scale, function splashD )
            set CheckU = null
            set CheckG = null
            set Check = 0
            call t.start( 0.02, false, function EffectFunction )
        else
            call fx.Stop()
            call t.destroy()
        endif
    endif
endfunction

private function Main takes nothing returns nothing
    local real speed
    local tick t
    local FxEffect fx
    if GetSpellAbilityId() == 'A014' then
        set t = tick.create(0) 
        set fx = FxEffect.Create()
        set fx.caster = GetTriggerUnit()
        set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set fx.speed = SkillSpeed(fx.pid)
        set fx.Velue = 0
        set fx.ul = party.create()
        set fx.Angle = GetUnitFacing(fx.caster)
        if HeroSkillLevel[fx.pid][6] >= 2 then
            if BuffMomiz01.Exists( fx.caster ) then
                call BuffMomiz01.Stop( fx.caster )
                set fx.Velue = 1
            endif
        endif
        
        call Sound3D(fx.caster,'A023')
        call CooldownFIX(fx.caster,'A014',CoolTime)
        set fx.i = 0
        
        call DummyMagicleash(fx.caster, Time * (1 - (fx.speed/(100+fx.speed)) ))
        call BuffNoST.Apply( fx.caster, Time * (1 - (fx.speed/(100+fx.speed)) ), 0 )
        call AnimationStart3(fx.caster, 5, (100+fx.speed)/100)
        
        set t.data = fx
        call t.start( Time2 * (1 - (fx.speed/(100+fx.speed)) ), false, function EffectFunction ) 
    endif
endfunction

private function DSyncData takes nothing returns nothing
    local player p=(DzGetTriggerSyncPlayer())
    local string data=(DzGetTriggerSyncData())
    local integer pid
    local integer dataLen=StringLength(data)
    local integer valueLen
    local real x
    local real y
    local real angle
    
    set pid=GetPlayerId(p)
    
    if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID6[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
        set x=S2R(data)
        set valueLen=StringLength(R2S(x))
        set data=SubString(data,valueLen+1,dataLen)
        set dataLen=dataLen-(valueLen+1)
        set y=S2R(data)
        set pid=GetPlayerId(p)
        set angle = Angle.WBP(MainUnit[pid],x,y)
        call SetUnitFacing(MainUnit[pid],angle)
        call EXSetUnitFacing(MainUnit[pid],angle)
        call IssuePointOrder( MainUnit[pid], "antimagicshell", x, y )
    endif
    
    set p=null
endfunction

            
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("MoD"),(false))
    call TriggerAddAction(t,function DSyncData)

    set t = null
//! runtextmacro 이벤트_끝()
endscope
