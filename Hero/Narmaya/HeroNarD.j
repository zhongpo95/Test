scope HeroNarD
globals
    private constant real DR = 1.00
    private constant real SD = 0.00
    private constant real CoolTime = 5.00
    //쉐클시간
    private constant real Time = 2.3

    private constant real scale = 800
    private constant real distance = 500
    private constant real scale2 = 900
    private constant real distance2 = 650
endglobals

private function splashD takes nothing returns nothing
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    //local integer level = HeroSkillLevel[pid][6]
    local real velue = 1.0
    local integer random
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        call HeroDeal(splash.source,GetEnumUnit(),DR*velue,false,false,SD,false)
        call UnitEffectTimeEX('e02B',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),GetRandomReal(0,360),1.2)
        call HeroDeal(splash.source,GetEnumUnit(),DR*velue,false,false,SD,false)
        call UnitEffectTimeEX('e02B',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),GetRandomReal(0,360),1.2)
        call HeroDeal(splash.source,GetEnumUnit(),DR*velue,false,false,SD,false)
        call UnitEffectTimeEX('e02B',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),GetRandomReal(0,360),1.2)
        set random = GetRandomInt(0,2)
        if random == 0 then
            call Sound3D(GetEnumUnit(),'A03X')
        elseif random == 1 then
            call Sound3D(GetEnumUnit(),'A03Y')
        elseif random == 2 then
            call Sound3D(GetEnumUnit(),'A05N')
        endif
    endif
endfunction

private function splashD2 takes nothing returns nothing
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    //local integer level = HeroSkillLevel[pid][6]
    local real velue = 1.0
    local integer random
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance2) then
        call HeroDeal(splash.source,GetEnumUnit(),DR*velue,false,false,SD,false)
        call UnitEffectTimeEX('e02B',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),GetRandomReal(0,360),1.2)
        set random = GetRandomInt(0,2)
        if random == 0 then
            call Sound3D(GetEnumUnit(),'A03X')
        elseif random == 1 then
            call Sound3D(GetEnumUnit(),'A03Y')
        elseif random == 2 then
            call Sound3D(GetEnumUnit(),'A05N')
        endif
    endif
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillFx fx = t.data
    local effect e

    set fx.i = fx.i + 1

    if fx.i == 1 then
        call UnitEffectTimeEX('e02W',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call UnitEffectTimeEX('e02X',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call UnitEffectTimeEX('e02Y',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call UnitEffectTimeEX('e02Z',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call UnitEffectTimeEX('e02W',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call UnitEffectTimeEX('e02X',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call UnitEffectTimeEX('e02Y',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call UnitEffectTimeEX('e02Z',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale, function splashD )
        set e = AddSpecialEffect("Air.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        call EXSetEffectSize(e, 3.00)
        call EXEffectMatRotateY(e, 180)
        call DestroyEffect(e)
        set e = null
        call t.start( 0.02, false, function EffectFunction )
    elseif fx.i == R2I(20/fx.speed) then
        call UnitEffectTimeEX('e02W',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call UnitEffectTimeEX('e02X',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call UnitEffectTimeEX('e02Y',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call UnitEffectTimeEX('e02Z',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call UnitEffectTimeEX('e02W',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call UnitEffectTimeEX('e02X',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call UnitEffectTimeEX('e02Y',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call UnitEffectTimeEX('e02Z',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale, function splashD )
        set e = AddSpecialEffect("Air.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        call EXSetEffectSize(e, 3.00)
        call EXEffectMatRotateY(e, 180)
        call DestroyEffect(e)
        set e = null
        call t.start( 0.02, false, function EffectFunction )
    elseif fx.i == R2I(40/fx.speed) then
        call UnitEffectTimeEX('e02W',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call UnitEffectTimeEX('e02X',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call UnitEffectTimeEX('e02Y',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call UnitEffectTimeEX('e02Z',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call UnitEffectTimeEX('e02W',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call UnitEffectTimeEX('e02X',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call UnitEffectTimeEX('e02Y',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call UnitEffectTimeEX('e02Z',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale, function splashD )
        set e = AddSpecialEffect("Air.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        call EXSetEffectSize(e, 3.00)
        call EXEffectMatRotateY(e, 180)
        call DestroyEffect(e)
        set e = null
        call t.start( 0.02, false, function EffectFunction )
    elseif fx.i == R2I(60/fx.speed) then
        call UnitEffectTimeEX('e02W',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call UnitEffectTimeEX('e02X',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call UnitEffectTimeEX('e02Y',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call UnitEffectTimeEX('e02Z',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call UnitEffectTimeEX('e02W',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call UnitEffectTimeEX('e02X',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call UnitEffectTimeEX('e02Y',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call UnitEffectTimeEX('e02Z',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.8)
        call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale, function splashD )
        set e = AddSpecialEffect("Air.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        call EXSetEffectSize(e, 3.00)
        call EXEffectMatRotateY(e, 180)
        call DestroyEffect(e)
        set e = null
        call t.start( 0.02, false, function EffectFunction )
    elseif fx.i == R2I(90/fx.speed) then
        call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale2, function splashD2 )
        set e = AddSpecialEffect("Air.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        call EXSetEffectSize(e, 3.00)
        call EXEffectMatRotateY(e, 180)
        call DestroyEffect(e)
        set e = null
        call UnitEffectTimeEX('e030',GetWidgetX(fx.caster),GetWidgetY(fx.caster),fx.r,0.8)
        call t.start( 0.02, false, function EffectFunction )
    elseif fx.i >= R2I(105/fx.speed) then
        call fx.Stop()
        call t.destroy()
    else
        call t.start( 0.02, false, function EffectFunction )
    endif

endfunction

private function Main takes nothing returns nothing
    local real speed
    local tick t
    local SkillFx fx
    local real r
    local integer i

    if GetSpellAbilityId() == 'A02O' then
        set t = tick.create(0)
        set fx = SkillFx.Create()
        set fx.caster = GetTriggerUnit()
        set fx.TargetX = GetSpellTargetX()
        set fx.TargetY = GetSpellTargetY()
        set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set fx.i = 0
        set fx.r = GetUnitFacing(fx.caster)
        set fx.speed = ((100+SkillSpeed(fx.pid))/100)

        //유닛애니메이션속도
        call DummyMagicleash(fx.caster, Time /fx.speed)
        call AnimationStart3(fx.caster, 13, fx.speed)
        
        call Sound3D(fx.caster,'A03J')

        set r = GetRandomInt(0,1)
        if r == 0 then
            call Sound3D(fx.caster,'A04F')
        elseif r == 1 then
            call Sound3D(fx.caster,'A04D')
        endif
        set t.data = fx

        call t.start( 0.20 /fx.speed , false, function EffectFunction )

        call CooldownFIX(GetTriggerUnit(),'A02O',CoolTime)
    endif
endfunction

    
private function DSyncData takes nothing returns nothing
    local player p=(DzGetTriggerSyncPlayer())
    local string data=(DzGetTriggerSyncData())
    local integer pid=GetPlayerId(p)
    local integer dataLen=StringLength(data)
    local integer valueLen
    local real x
    local real y
    local real angle
    
    if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID6[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
        set x=S2R(data)
        set valueLen=StringLength(R2S(x))
        set data=SubString(data,valueLen+1,dataLen)
        set dataLen=dataLen-(valueLen+1)
        set y=S2R(data)
        set pid=GetPlayerId(p)
        set angle = AngleWBP(MainUnit[pid],x,y)
        call SetUnitFacing(MainUnit[pid],angle)
        call EXSetUnitFacing(MainUnit[pid],angle)
        call IssuePointOrder( MainUnit[pid], "antimagicshell", x, y )
    endif

    set p=null
endfunction

private function DSyncData2 takes nothing returns nothing
    local player p = DzGetTriggerSyncPlayer()
    local integer pid = GetPlayerId(p)
    local real x
    local real y
    local real angle
    local real speed
    local tick t
    
    set p=null
endfunction

            
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("NarD"),(false))
    call TriggerAddAction(t,function DSyncData)
    
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("NarD2"),(false))
    call TriggerAddAction(t,function DSyncData2)

    set t = null
//! runtextmacro 이벤트_끝()
endscope

