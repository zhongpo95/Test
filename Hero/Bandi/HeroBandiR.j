scope HeroBandiR
    globals
        //쉐클시간
        private constant real Time = 2.1
        private constant real Time2 = 0.4
        private constant real Time3 = 0.1
        private constant real Time4 = 0.2
        private constant real Time5 = 0.1
        private constant real Time6 = 0.6
    
        private constant real scale = 500
        private constant real scale2 = 600
        private constant real distance = 325
        private constant real distance2 = 450
        //범위체크
        private group CheckG
        //더미 유닛
        private unit CheckU
        boolean array IsCastingBandiR
    endglobals

    private struct FxEffect
        unit caster
        integer pid
        real speed
        integer i
        private method OnStop takes nothing returns nothing
            set caster = null
            set pid = 0
            set speed = 0
            set i = 0
        endmethod
        //! runtextmacro 연출()
    endstruct

    private function splashD2 takes nothing returns nothing
        local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
        local integer level = HeroSkillLevel[pid][5]
        local integer random
        
        if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance2) then
    
            call HeroDeal('A06I',splash.source,GetEnumUnit(),HeroSkillVelue5[4],true,false,false,false)
            call HeroDeal('A06I',splash.source,GetEnumUnit(),HeroSkillVelue5[4],true,false,false,false)
            call UnitEffectTimeEX2('e04I',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),AngleWBW(splash.source,GetEnumUnit())-90,1.2,pid)
            call UnitEffectTimeEX2('e04I',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),AngleWBW(splash.source,GetEnumUnit())+90,1.2,pid)
            
            set random = GetRandomInt(0,2)
            if random == 0 then
                call Sound3D(GetEnumUnit(),'A03X')
            elseif random == 1 then
                call Sound3D(GetEnumUnit(),'A03Y')
            elseif random == 2 then
                call Sound3D(GetEnumUnit(),'A05N')
            endif
            if level >= 1 then
                //call DeBuffMArm.Apply( GetEnumUnit(), 10.0, 0 )
            endif
    
        endif
    endfunction

    private function splashD takes nothing returns nothing
        local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
        local integer level = HeroSkillLevel[pid][5]
        local integer random
        
        if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
    
            call HeroDeal('A06I',splash.source,GetEnumUnit(),HeroSkillVelue5[4],true,false,false,false)
            call UnitEffectTimeEX2('e046',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),GetRandomReal(0,360),1.2,pid)
            
            set random = GetRandomInt(0,2)
            if random == 0 then
                call Sound3D(GetEnumUnit(),'A03X')
            elseif random == 1 then
                call Sound3D(GetEnumUnit(),'A03Y')
            elseif random == 2 then
                call Sound3D(GetEnumUnit(),'A05N')
            endif
            if level >= 1 then
                //call DeBuffMArm.Apply( GetEnumUnit(), 10.0, 0 )
            endif
    
        endif
    endfunction
    
    private function EffectFunctionZ takes nothing returns nothing
        local tick t = tick.getExpired()
        local SkillFx fx = t.data
        local real r
        
        call UnitAddAbility(fx.caster,'Arav')
        call UnitRemoveAbility(fx.caster,'Arav')

        set fx.r = fx.r + 0.04

        if fx.r <= 0.400 then
            set r = RMaxBJ(( 10.00 - ( fx.r - 0.400 ) * 50.00 ), 5.00)
        else
            if fx.e != null then
                call DestroyEffect(fx.e)
                call DestroyEffect(fx.e2)
                call UnitEffectTime2('e049',GetWidgetX(fx.caster)+PolarX( 150, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster)+PolarY( 150, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.7,0,fx.pid)
            endif
            set r = GetUnitFlyHeight(fx.caster) / 3
        endif

        if GetUnitFlyHeight(fx.caster) >= 0 and fx.r <= 0.500 then
            if fx.r <= 0.400 then
                call SetUnitFlyHeight(fx.caster, GetUnitFlyHeight(fx.caster) + r, r / 0.04)
            else
                call SetUnitFlyHeight(fx.caster, GetUnitFlyHeight(fx.caster) - r, r / 0.04)
            endif
        else
            call SetUnitFlyHeight(fx.caster, 0, 0.00)
            call DestroyEffect(fx.e)
            call DestroyEffect(fx.e2)
            call fx.Stop()
            call t.destroy()
        endif
    endfunction

    private function EffectFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        local FxEffect fx = t.data
        local tick t2
        local SkillFx fx2
    
        set fx.i = fx.i + 1

        if IsCastingBandiR[GetPlayerId(GetOwningPlayer(fx.caster))] == true then
            if GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
                if fx.i == 1 then
                    call UnitEffectTime2('e040',GetWidgetX(fx.caster)+PolarX( 50, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster)+PolarY( 50, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.7,0,fx.pid)
                    call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 75, GetUnitFacing(fx.caster) ), scale, function splashD )
                    call t.start( Time3 / fx.speed, false, function EffectFunction ) 
                elseif fx.i == 2 then
                    call UnitEffectTime2('e041',GetWidgetX(fx.caster)+PolarX( 50, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster)+PolarY( 50, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.7,0,fx.pid)
                    call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 75, GetUnitFacing(fx.caster) ), scale, function splashD )
                    call t.start( Time4 / fx.speed, false, function EffectFunction ) 
                elseif fx.i == 3 then
                    call UnitEffectTime2('e042',GetWidgetX(fx.caster)+PolarX( 50, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster)+PolarY( 50, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.7,0,fx.pid)
                    call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 75, GetUnitFacing(fx.caster) ), scale, function splashD )
                    call t.start( Time5 / fx.speed, false, function EffectFunction ) 
                elseif fx.i == 4 then
                    call UnitEffectTime2('e043',GetWidgetX(fx.caster)+PolarX( 50, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster)+PolarY( 50, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.7,0,fx.pid)
                    call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 75, GetUnitFacing(fx.caster) ), scale, function splashD )
                    call t.start( Time6 / fx.speed, false, function EffectFunction ) 
                    set fx2 = SkillFx.Create()
                    set t2 = tick.create(fx2)
                    set fx2.pid = fx.pid
                    set fx2.caster = fx.caster
                    set fx2.speed = fx.speed
                    set fx2.r = 0
                    set fx2.e = AddSpecialEffectTarget("t7_wood_bashenan_juqi_1_2.mdl", fx.caster, "left hand")
                    call EXSetEffectSpeed(fx2.e,2.0)
                    set fx2.e2 = AddSpecialEffectTarget("t7_wood_bashenan_juqi_1_2.mdl", fx.caster, "right hand")
                    call EXSetEffectSpeed(fx2.e2,2.0)
                    call t2.start( 0.04 / fx.speed , true, function EffectFunctionZ )
                elseif fx.i == 5 then
                    call UnitEffectTime2('e044',GetWidgetX(fx.caster)+PolarX( 50, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster)+PolarY( 50, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.7,0,fx.pid)
                    call UnitEffectTime2('e045',GetWidgetX(fx.caster)+PolarX( 50, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster)+PolarY( 50, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.7,0,fx.pid)
                    call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 75, GetUnitFacing(fx.caster) ), scale2, function splashD2 )
                    call fx.Stop()
                    call t.destroy()
                endif
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
        
        if GetSpellAbilityId() == 'A06I' then
            set t = tick.create(0) 
            set fx = FxEffect.Create()
            set fx.caster = GetTriggerUnit()
            set fx.pid = GetPlayerId(GetOwningPlayer(fx.caster))
            set fx.speed = ((100+SkillSpeed(fx.pid))/100)
            set IsCastingBandiR[fx.pid] = true
            set fx.i = 0
            
            //call BanBisul2Use(pid)
            call Overlay2Count(fx.pid,'A06I')

            //공격속도가 40퍼 도달시, 이스킬의 공격속도가 40퍼가 아닌 100퍼로 적용
            if SkillSpeed(fx.pid) != 40 then
                call DummyMagicleash(fx.caster, Time / fx.speed )
                call AnimationStart3(fx.caster, 2, fx.speed)

                //if GetRandomInt(0,1) == 1 then
                    call Sound3D(fx.caster,'A06A')
                //else
                    //call Sound3D(fx.caster,'A06Y')
                //endif

                set t.data = fx
                call t.start( Time2 / fx.speed, false, function EffectFunction ) 
                call CooldownFIX(fx.caster,'A06I', 2.75)
            else
                set fx.speed = ((100+SkillSpeed2(fx.pid,60))/100)
                call DummyMagicleash(fx.caster, Time / fx.speed )
                call AnimationStart3(fx.caster, 2, fx.speed)

                //if GetRandomInt(0,1) == 1 then
                    call Sound3D(fx.caster,'A06B')
                //else
                    //call Sound3D(fx.caster,'A06Y')
                //endif

                set t.data = fx
                call t.start( Time2 / fx.speed, false, function EffectFunction ) 
                call CooldownFIX(fx.caster,'A06I', 2.75)
            endif
        endif
    endfunction
        
    private function RSyncData takes nothing returns nothing
        local player p=(DzGetTriggerSyncPlayer())
        local string data=(DzGetTriggerSyncData())
        local integer pid=GetPlayerId(p)
        local integer dataLen=StringLength(data)
        local integer valueLen
        local real x
        local real y
        local real angle
        
        if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and IsUnitPausedEx(MainUnit[pid]) == false and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID3[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
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
                call IssuePointOrder( MainUnit[pid], "ancestralspirit", x, y )
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
    call DzTriggerRegisterSyncData(t,("BandiR"),(false))
    call TriggerAddAction(t,function RSyncData)

    set t = null
//! runtextmacro 이벤트_끝()
endscope

