scope HeroBandiS
    globals
        //쉐클시간
        private constant real Time = 2.0
        //private constant real Time2 = 2.0
        private constant real Time2 = 1.05
    
        private constant real scale = 500
        private constant real scale2 = 600
        private constant real distance = 325
        private constant real distance2 = 450
        //범위체크
        private group CheckG
        //더미 유닛
        private unit CheckU
        boolean array IsCastingBandiS
    endglobals
    
    private struct FxEffect
        unit caster
        real TargetX
        real TargetY
        integer pid
        real speed
        private method OnStop takes nothing returns nothing
            set caster = null
            set pid = 0
            set TargetX = 0
            set TargetY = 0
            set speed = 0
        endmethod
        //! runtextmacro 연출()
    endstruct
    
    private function splashD2 takes nothing returns nothing
        local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
        local integer level = HeroSkillLevel[pid][5]
        
        if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
    
            call HeroDeal('A06J',splash.source,GetEnumUnit(),HeroSkillVelue5[4],true,false,false,false)
            
            if level >= 1 then
                //call DeBuffMArm.Apply( GetEnumUnit(), 10.0, 0 )
            endif
    
        endif
    endfunction

    private function splashD takes nothing returns nothing
        local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
        local integer level = HeroSkillLevel[pid][5]
        
        if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
    
            call HeroDeal('A06J',splash.source,GetEnumUnit(),HeroSkillVelue5[4],true,false,false,false)
            
            if level >= 1 then
                //call DeBuffMArm.Apply( GetEnumUnit(), 10.0, 0 )
            endif
    
        endif
    endfunction
    
    private function EffectFunction2 takes nothing returns nothing
        local tick t = tick.getExpired()
        local FxEffect fx = t.data

        if IsCastingBandiS[GetPlayerId(GetOwningPlayer(fx.caster))] == true then
            set IsCastingBandiS[GetPlayerId(GetOwningPlayer(fx.caster))] = false
            
            if GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 15 )
                call UnitEffectTime2('e03V',GetWidgetX(fx.caster)+PolarX( 125, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster) + PolarY( 125, GetUnitFacing(fx.caster)-15 ),GetUnitFacing(fx.caster),2.0,1,GetPlayerId(GetOwningPlayer(fx.caster)))
                if splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 125, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 125, GetUnitFacing(fx.caster)-15 ), scale2, function splashD2 ) != 0 then
                endif
            else
            endif
        else
        endif
        call fx.Stop()
        call t.destroy()
    endfunction


    private function EffectFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        local FxEffect fx = t.data
    
        if IsCastingBandiS[GetPlayerId(GetOwningPlayer(fx.caster))] == true then
            if GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 15 )
                call Sound3D(fx.caster,'A06X')
                call UnitEffectTime2('e03U',GetWidgetX(fx.caster)+PolarX( 125, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster) + PolarY( 125, GetUnitFacing(fx.caster)-15 ),GetUnitFacing(fx.caster),2.0,1,GetPlayerId(GetOwningPlayer(fx.caster)))
                if splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 125, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 125, GetUnitFacing(fx.caster)-15 ), scale, function splashD ) != 0 then
                endif
                call t.start( 0.336 /fx.speed, false, function EffectFunction2 ) 
            else
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
        
        if GetSpellAbilityId() == 'A06J' then
            set t = tick.create(0) 
            set fx = FxEffect.Create()
            set fx.caster = GetTriggerUnit()
            set fx.TargetX = GetSpellTargetX()
            set fx.TargetY = GetSpellTargetY()
            set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
            //set fx.speed = SkillSpeed(fx.pid)
            set fx.speed = ((100+SkillSpeed(fx.pid))/100)
            set IsCastingBandiS[fx.pid] = true
            
            call Sound3D(fx.caster,'A06W')
            call DummyMagicleash(fx.caster,Time / fx.speed )
            call AnimationStart3(fx.caster,3, fx.speed)

            call Overlay2Count(fx.pid,'A06J')
            
            set t.data = fx
            call t.start( Time2 / fx.speed, false, function EffectFunction ) 
            call CooldownFIX(fx.caster,'A06J',HeroSkillCD5[4])
        endif
    endfunction
        
    private function SSyncData takes nothing returns nothing
        local player p=(DzGetTriggerSyncPlayer())
        local string data=(DzGetTriggerSyncData())
        local integer pid
        local integer dataLen=StringLength(data)
        local integer valueLen
        local real x
        local real y
        local real angle
        
        set pid=GetPlayerId(p)
        
        if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID5[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
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
                call IssuePointOrder( MainUnit[pid], "animatedead", x, y )
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
        call DzTriggerRegisterSyncData(t,("BandiS"),(false))
        call TriggerAddAction(t,function SSyncData)
    
        set t = null
    //! runtextmacro 이벤트_끝()
    endscope