scope HeroMoF

globals
    private constant real SD = 74 / 8
    
    //쉐클시간
    private constant real Time = 2.7
    //스킬이펙트 시간
    private constant real Time2 = 0.300
    //2타 시간
    private constant real Time3 = 0.200
    //3타 시간
    private constant real Time4 = 0.300
    //4타 시간
    private constant real Time5 = 0.500
    //5타 시간
    private constant real Time6 = 0.300
    //6타 시간
    private constant real Time7 = 0.300
    //7타 시간
    private constant real Time8 = 0.300
    //8타 시간
    private constant real Time9 = 0.200
    
    //발도 버프 체크
    private real Check = 0

    private constant real scale = 825
    private constant real distance = 550
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
    private method OnStop takes nothing returns nothing
        set caster = null
        set dummy = null
        set dummy2 = null
        set pid = 0
        set Velue = 0
        set speed = 0
        set i = 0
    endmethod
    //! runtextmacro 연출()
endstruct

private function splashD takes nothing returns nothing
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer level = HeroSkillLevel[pid][7]
    local real velue = 1.0
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        //뒤는안떄림
        if AngleTrue( GetUnitFacing(splash.source), AngleWBW(splash.source,GetEnumUnit()), 90 ) then
            if level >= 1 then
                if Check == 1 then
                    set velue = velue * 1.60
                endif
            endif
            
            if level >= 2 then
                set velue = velue * 1.60
            endif
            
            if level >= 3 then
                set velue = velue * 1.95
            endif
            
            call HeroDeal(splash.source,GetEnumUnit(),HeroSkillVelue7[3]*velue,false,false,SD,false)
        endif
    endif
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data
    local real X
    local real Y
    
    set fx.i = fx.i + 1
    
    if GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
        if fx.i == 1 then
            set fx.dummy = UnitEffectTimeEX2('e01D', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set fx.dummy = UnitEffectTimeEX2('e01D', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set fx.dummy = UnitEffectTimeEX2('e01D', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set fx.dummy = UnitEffectTimeEX2('e01D', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set Check = fx.Velue
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.dummy), GetWidgetY(fx.dummy), scale, function splashD )
            set Check = 0
            call t.start( Time3 * (1 - (fx.speed/(100+fx.speed)) ), false, function EffectFunction ) 
        elseif fx.i == 2 then
            set fx.dummy = UnitEffectTimeEX2('e01C', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set fx.dummy = UnitEffectTimeEX2('e01C', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set fx.dummy = UnitEffectTimeEX2('e01C', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set fx.dummy = UnitEffectTimeEX2('e01C', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set Check = fx.Velue
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.dummy), GetWidgetY(fx.dummy), scale, function splashD )
            set Check = 0
            call t.start( Time4 * (1 - (fx.speed/(100+fx.speed)) ), false, function EffectFunction ) 
        elseif fx.i == 3 then
            set fx.dummy = UnitEffectTimeEX2('e01E', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set fx.dummy = UnitEffectTimeEX2('e01E', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set fx.dummy = UnitEffectTimeEX2('e01E', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set fx.dummy = UnitEffectTimeEX2('e01E', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set Check = fx.Velue
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.dummy), GetWidgetY(fx.dummy), scale, function splashD )
            set Check = 0
            call t.start( Time5 * (1 - (fx.speed/(100+fx.speed)) ), false, function EffectFunction ) 
        elseif fx.i == 4 then
            call Sound3D(fx.caster,'A021')
            set fx.dummy = UnitEffectTimeEX2('e01F', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set fx.dummy = UnitEffectTimeEX2('e01F', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set fx.dummy = UnitEffectTimeEX2('e01F', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set fx.dummy = UnitEffectTimeEX2('e01F', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set Check = fx.Velue
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.dummy), GetWidgetY(fx.dummy), scale, function splashD )
            set Check = 0
            call t.start( Time6 * (1 - (fx.speed/(100+fx.speed)) ), false, function EffectFunction ) 
        elseif fx.i == 5 then
            set fx.dummy = UnitEffectTimeEX2('e01C', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set fx.dummy = UnitEffectTimeEX2('e01C', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set fx.dummy = UnitEffectTimeEX2('e01C', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set fx.dummy = UnitEffectTimeEX2('e01C', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set Check = fx.Velue
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.dummy), GetWidgetY(fx.dummy), scale, function splashD )
            set Check = 0
            call t.start( Time7 * (1 - (fx.speed/(100+fx.speed)) ), false, function EffectFunction ) 
        elseif fx.i == 6 then
            set fx.dummy = UnitEffectTimeEX2('e01G', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set fx.dummy = UnitEffectTimeEX2('e01G', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set fx.dummy = UnitEffectTimeEX2('e01G', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set fx.dummy = UnitEffectTimeEX2('e01G', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set Check = fx.Velue
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.dummy), GetWidgetY(fx.dummy), scale, function splashD )
            set Check = 0
            call t.start( Time8 * (1 - (fx.speed/(100+fx.speed)) ), false, function EffectFunction ) 
        elseif fx.i == 7 then
            set fx.dummy = UnitEffectTimeEX2('e01G', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set fx.dummy = UnitEffectTimeEX2('e01G', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set fx.dummy = UnitEffectTimeEX2('e01G', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set fx.dummy = UnitEffectTimeEX2('e01G', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set Check = fx.Velue
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.dummy), GetWidgetY(fx.dummy), scale, function splashD )
            set Check = 0
            call t.start( Time9 * (1 - (fx.speed/(100+fx.speed)) ), false, function EffectFunction ) 
        elseif fx.i == 8 then
            set fx.dummy = UnitEffectTimeEX2('e01D', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set fx.dummy = UnitEffectTimeEX2('e01D', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set fx.dummy = UnitEffectTimeEX2('e01D', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set fx.dummy = UnitEffectTimeEX2('e01D', GetWidgetX(fx.caster), GetWidgetY(fx.caster), fx.Angle, 0.01,GetPlayerId(GetOwningPlayer(fx.caster)))
            set Check = fx.Velue
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.dummy), GetWidgetY(fx.dummy), scale, function splashD )
            set Check = 0
            call fx.Stop()
            call t.destroy()
        endif
    else
        call fx.Stop()
        call t.destroy()
    endif
endfunction

private function Main takes nothing returns nothing
    local real speed
    local tick t
    local FxEffect fx
    if GetSpellAbilityId() == 'A015' then
        set t = tick.create(0) 
        set fx = FxEffect.Create()
        set fx.caster = GetTriggerUnit()
        set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set fx.speed = SkillSpeed(fx.pid)
        set fx.Velue = 0
        set fx.Angle = GetUnitFacing(fx.caster)
        if HeroSkillLevel[fx.pid][6] >= 2 then
            if BuffMomiz01.Exists( fx.caster ) then
                call BuffMomiz01.Stop( fx.caster )
                set fx.Velue = 1
            endif
        endif
        
        call Sound3D(fx.caster,'A01X')
        
        call CooldownFIX(fx.caster,'A015',HeroSkillCD7[3])
        set fx.i = 0
        
        call DummyMagicleash(fx.caster, Time * (1 - (fx.speed/(100+fx.speed)) ))
        call BuffNoST.Apply( fx.caster, Time * (1 - (fx.speed/(100+fx.speed)) ), 0 )
        call AnimationStart3(fx.caster, 10, fx.speed)
        
        set t.data = fx
        call t.start( Time2 * (1 - (fx.speed/(100+fx.speed)) ), false, function EffectFunction ) 
    endif
endfunction

private function FSyncData takes nothing returns nothing
    local player p=(DzGetTriggerSyncPlayer())
    local string data=(DzGetTriggerSyncData())
    local integer pid
    local integer dataLen=StringLength(data)
    local integer valueLen
    local real x
    local real y
    local real angle
    
    set pid=GetPlayerId(p)
    
    if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID7[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
        set x=S2R(data)
        set valueLen=StringLength(R2S(x))
        set data=SubString(data,valueLen+1,dataLen)
        set dataLen=dataLen-(valueLen+1)
        set y=S2R(data)
        set pid=GetPlayerId(p)
        set angle = AngleWBP(MainUnit[pid],x,y)
        call SetUnitFacing(MainUnit[pid],angle)
        call EXSetUnitFacing(MainUnit[pid],angle)
        call IssuePointOrder( MainUnit[pid], "attributemodskill", x, y )
    endif
    
    set p=null
endfunction

            
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("MoF"),(false))
    call TriggerAddAction(t,function FSyncData)

    set t = null
//! runtextmacro 이벤트_끝()
endscope
