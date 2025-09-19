scope HeroBandiC
globals
    private constant real DR = 1.00
    private constant real SD = 0.00
    
    private constant real CoolTime = 0.7
    
    //쉐클시간
    private constant real Time = 0.40
    //스킬이펙트 시간
    private constant real Time2 = 0.40

    private constant real scale = 500
    private constant real distance = 400

    private boolean StackChecker
    boolean array IsCastingBandiC
endglobals
    
    private function splashD takes nothing returns nothing
        local real Velue = 1.0
        local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
        local integer random
        
        if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
            call HeroDeal(2,splash.source,GetEnumUnit(),DR*Velue,false,false,false,false)
            call UnitEffectTimeEX2('e046',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),GetRandomReal(0,360),1.2,pid)
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
         
        /*
        if IsCastingChenC[GetPlayerId(GetOwningPlayer(fx.caster))] == true then
            set IsCastingChenC[GetPlayerId(GetOwningPlayer(fx.caster))] = false
    
            if GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
                call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 75, GetUnitFacing(fx.caster) ), scale, function splashD )
            endif
        endif
        */
        call fx.Stop()
        call t.destroy()
    endfunction
    
    private function Main takes nothing returns nothing
        local tick t
        local SkillFx fx
        local real random
        local integer pid
        local real speed
             
        if GetSpellAbilityId() == 'A06D' then
            call SetUnitFacing(GetTriggerUnit(), AngleWBP(GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() ))
            call EXSetUnitFacing(GetTriggerUnit(), AngleWBP(GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() ))
            set t = tick.create(0) 
            set fx = SkillFx.Create()
            set fx.caster = GetTriggerUnit()
            set fx.TargetX = GetSpellTargetX()
            set fx.TargetY = GetSpellTargetY()
            set pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
            set speed = ((100+SkillSpeed(pid))/100)
            set IsCastingChenC[pid] = true
            
            call CooldownFIX(fx.caster,'A06D', CoolTime)
    
            call DummyMagicleash(fx.caster,Time /speed)
            call AnimationStart3(fx.caster, 18, speed)
            
            set t.data = fx
            call t.start( Time2 /speed, false, function EffectFunction ) 
        endif
    endfunction

    private function CSyncData takes nothing returns nothing
        local player p=(DzGetTriggerSyncPlayer())
        local string data=(DzGetTriggerSyncData())
        local integer pid
        local integer dataLen=StringLength(data)
        local integer valueLen
        local real x
        local real y
        local real angle

        set pid=GetPlayerId(p)
        
        if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and IsUnitPausedEx(MainUnit[pid]) == false then
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
            endif
        endif
        
        set p=null
    endfunction
            
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    /*
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
    */
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("BandiC"),(false))
    call TriggerAddAction(t,function CSyncData)
    set t = null
//! runtextmacro 이벤트_끝()
endscope