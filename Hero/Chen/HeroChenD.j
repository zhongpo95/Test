scope HeroChenD

globals
    private constant real DR = 3.39
    private constant real SD = 21
    
    private constant real CoolTime = 24.0
    //쉐클시간
    private constant real Time = 0.8
    //쉴드량
    private constant real Value = 0.30
    //버프지속시간,공증량
    private constant real Time3 = 10
    private constant integer Velue2 = 350

    private constant real scale = 1500
    private constant real distance = 1000
endglobals

private struct FxEffect
    unit caster
    integer pid
    private method OnStop takes nothing returns nothing
        set pid = 0
        set caster = null
    endmethod
    //! runtextmacro 연출()
endstruct

private function splashD takes nothing returns nothing
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer level = HeroSkillLevel[pid][6]
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        call HeroDeal(splash.source,GetEnumUnit(),DR,true,false,SD,false)
        
        if level >= 1 then
            call DeBuffMArm.Apply( GetEnumUnit(), 10.0, 0 )
        endif
        
        if level >= 3 then
            call DeBuffMBackHead.Apply( GetEnumUnit(), 12.0, 0 )
        endif
    endif
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local FxEffect fx = t.data
     
    if GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
        if HeroSkillLevel[fx.pid][6] >= 2 then
            call ShieldAdd(fx.caster,4.0,GetUnitMaxLifeVJ(fx.caster)*Value)
        endif
        call UnitEffectTime2('e00V',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetUnitFacing(fx.caster),1.5,1)
        if splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale, function splashD ) != 0 then
            //공증버프
            if HeroSkillLevel[fx.pid][6] >= 1 then
                if Hero_Buff[fx.pid] == 0 then
                    call BuffChen00.Apply( fx.caster, Time3, Velue2 )
                endif
            endif
        endif
        call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
    endif
    
    call fx.Stop()
    call t.destroy()
endfunction

private function Main takes nothing returns nothing
    local real speed
    local integer pid
    local tick t
    local FxEffect fx
    
    if GetSpellAbilityId() == 'A01D' then
        set t = tick.create(0)
        set fx = FxEffect.Create()
        set fx.caster = GetTriggerUnit()
        set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set speed = SkillSpeed(fx.pid)
        
        call Sound3D(fx.caster,'A01L')
        call DummyMagicleash(fx.caster,Time * (1 - (speed/(100+speed)) ))
        call AnimationStart3(fx.caster,10, (100+speed)/100)
        call CooldownFIX(fx.caster,'A01D',CoolTime)
        
        set t.data = fx
        call t.start( Time * (1 - (speed/(100+speed)) ), false, function EffectFunction ) 
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
    call DzTriggerRegisterSyncData(t,("ChenD"),(false))
    call TriggerAddAction(t,function DSyncData)

    set t = null
//! runtextmacro 이벤트_끝()
endscope
