scope HeroBandiD
    globals
        private constant real SD = 0.00
        //쉐클시간
        private constant real Time = 1.8
        private constant real MoveD = 750
    
        private constant real TICK = 20
    
        private constant real scale = 150
        private constant real distance = 300
        private constant real scale2 = 300
        private constant real distance2 = 400
        //범위체크
        private group CheckG
        //더미 유닛
        private unit CheckU
        private integer Nabi
    endglobals
    
    private function splashD2 takes nothing returns nothing
        local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
        //local integer level = HeroSkillLevel[pid][6]
        local real velue = 1.0
        local integer random
        
        if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
            call HeroDeal('A06E',splash.source,GetEnumUnit(),HeroSkillVelue5[14]*velue,false,false,false,false)
            call UnitEffectTimeEX2('e03Y',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),GetRandomReal(0,360),1.2,pid)
                /*
                set random = GetRandomInt(0,2)
                if random == 0 then
                    call Sound3D(GetEnumUnit(),'A03X')
                    elseif random == 1 then
                    call Sound3D(GetEnumUnit(),'A03Y')
                elseif random == 2 then
                    call Sound3D(GetEnumUnit(),'A05N')
                endif
                */
        endif
    endfunction

    private function splashD takes nothing returns nothing
        local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
        //local integer level = HeroSkillLevel[pid][6]
        local real velue = 1.0
        local integer random
        
        if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance2) then
            if IsUnitInGroup(GetEnumUnit(),CheckG) == false then
                call HeroDeal('A06E',splash.source,GetEnumUnit(),HeroSkillVelue5[14]*velue,false,false,false,false)
                call UnitEffectTimeEX2('e03Y',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),GetRandomReal(0,360),1.2,pid)
                /*
                set random = GetRandomInt(0,2)
                if random == 0 then
                    call Sound3D(GetEnumUnit(),'A03X')
                    elseif random == 1 then
                    call Sound3D(GetEnumUnit(),'A03Y')
                elseif random == 2 then
                    call Sound3D(GetEnumUnit(),'A05N')
                endif
                */
                call GroupAddUnit(CheckG,GetEnumUnit())
            endif
        endif
    endfunction
    
    private function EffectFunction3 takes nothing returns nothing
        local tick t = tick.getExpired()
        local SkillFx fx = t.data
        
        set fx.i = fx.i + 1
        if fx.i == 1 then
            if fx.j == 0 then
                call Sound3D(fx.caster,'A060')
            else
                call Sound3D(fx.caster,'A061')
            endif
            set fx.ul = party.create()
            //call SetUnitGravity(fx.caster,2.3)
            call UnitEffectTime2('e03W',GetWidgetX(fx.caster)+PolarX(0,GetUnitFacing(fx.caster)),GetWidgetY(fx.caster)+PolarY(0,GetUnitFacing(fx.caster)),GetUnitFacing(fx.caster),1.5,0,fx.pid)
            call UnitEffectTime2('e04G',GetWidgetX(fx.caster)+PolarX(50,GetUnitFacing(fx.caster)),GetWidgetY(fx.caster)+PolarY(50,GetUnitFacing(fx.caster)),fx.r2-180,2.0,0,fx.pid)
        endif

        if fx.i == R2I(18/fx.speed) then
        endif
    
    
        if fx.i >= R2I(18/fx.speed) then
            //call SetUnitGravity(fx.caster,0.6)
            call UnitEffectTime2('e03Z',GetWidgetX(fx.caster)+PolarX(0,GetUnitFacing(fx.caster)),GetWidgetY(fx.caster)+PolarY(0,GetUnitFacing(fx.caster)),GetUnitFacing(fx.caster),1.5,0,fx.pid)
            call UnitEffectTime2('e04F',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetUnitFacing(fx.caster),2.0,0,fx.pid)
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale2, function splashD2 )
            call fx.ul.destroy()
            call fx.Stop()
            call t.destroy()
        else
            set CheckG = fx.ul.super
            set CheckU = fx.caster
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale, function splashD )
            set CheckU = null
            set CheckG = null
            call SetUnitSafePolarUTA(fx.caster,fx.r/R2I(18/fx.speed), fx.r2 )
            call t.start( 0.02, false, function EffectFunction3 ) 
        endif
    endfunction

    private function EffectFunctionZ takes nothing returns nothing
        local tick t = tick.getExpired()
        local SkillFx fx = t.data
        local real r
        
        call UnitAddAbility(fx.caster,'Arav')
        call UnitRemoveAbility(fx.caster,'Arav')

        set fx.r = fx.r + 0.04

        if fx.r <= 0.586 then
            set r = RMaxBJ(( 50.00 - ( fx.r - 0.586 ) * 50.00 ), 5.00)
        else
            set r = GetUnitFlyHeight(fx.caster) / 4
        endif

        if GetUnitFlyHeight(fx.caster) >= 0 and fx.r <= 0.946 then
            if fx.r <= 0.586 then
                call SetUnitFlyHeight(fx.caster, GetUnitFlyHeight(fx.caster) + r, r / 0.04)
            else
                call SetUnitFlyHeight(fx.caster, GetUnitFlyHeight(fx.caster) - r, r / 0.04)
            endif
        else
            call SetUnitFlyHeight(fx.caster, 0, 0.00)
            call fx.Stop()
            call t.destroy()
        endif
    endfunction


    private function EffectFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        local SkillFx fx = t.data
        local tick t2
        local SkillFx fx2

        if fx.caster != null and IsUnitDeadVJ(fx.caster) == false then
            set fx2 = SkillFx.Create()
            set t2 = tick.create(fx2)
            set fx2.pid = fx.pid
            set fx2.caster = fx.caster
            set fx2.speed = fx.speed
            set fx2.r = 0

            //call SetUnitZVeloP( fx.caster, 20)
            call Sound3D(fx.caster,'A05X')
            call UnitEffectTime2('e03X',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),2.0,0,fx.pid)
            call UnitEffectTime2('e03X',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),2.0,0,fx.pid)
            call UnitEffectTime2('e04E',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),2.0,0,fx.pid)

            call t.start( 0.586 / fx.speed , false, function EffectFunction3 )
            call t2.start( 0.04 / fx.speed , true, function EffectFunctionZ )
        else
            call fx.Stop()
            call t.destroy()
        endif
    endfunction
    
    private function Main takes nothing returns nothing
        local real speed
        local tick t
        local SkillFx fx
        local real r
        local integer i
        local effect e
    
        if GetSpellAbilityId() == 'A06E' then
            call SetUnitFacing(GetTriggerUnit(), AngleWBP(GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() ))
            call EXSetUnitFacing(GetTriggerUnit(), AngleWBP(GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() ))
            set t = tick.create(0)
            set fx = SkillFx.Create()
            set fx.caster = GetTriggerUnit()
            set fx.TargetX = GetSpellTargetX()
            set fx.TargetY = GetSpellTargetY()
            set fx.pid = GetPlayerId(GetOwningPlayer(fx.caster))
            set fx.i = 0
            set fx.speed = ((100+SkillSpeed(fx.pid))/100)
            set fx.r = MoveD
            set fx.j = GetRandomInt(0,1)
    
            call Overlay2Count(fx.pid,'A06E')
    
            //유닛애니메이션속도
            call DummyMagicleash(fx.caster, Time /fx.speed)
            call AnimationStart3(fx.caster, 2, fx.speed)
    
            call Sound3D(fx.caster,'A05W')

            set fx.r2 = AngleWBP(fx.caster,fx.TargetX,fx.TargetY)
    
            if fx.j == 0 then
                call Sound3D(fx.caster,'A05Y')
            else
                call Sound3D(fx.caster,'A05Z')
            endif
    
            set t.data = fx
            
            call BanBisul2Plus( fx.pid,1)
    
            if HeroSkillLevel[fx.pid][5] >= 2 then
                call BuffNoNB.Apply( fx.caster, Time, 0 )
                call BuffNoST.Apply( fx.caster, Time, 0 )
            endif
            call t.start( 0.439 / fx.speed, false, function EffectFunction )

            //call CooldownFIX(fx.caster,'A06E',HeroSkillCD5[14])
            call CooldownFIX(fx.caster,'A06E',5.0)
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
        
        if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and IsUnitPausedEx(MainUnit[pid]) == false and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID6[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
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
                call IssuePointOrder( MainUnit[pid], "antimagicshell", x, y )
            endif
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
        call DzTriggerRegisterSyncData(t,("BandiD"),(false))
        call TriggerAddAction(t,function DSyncData)

        set t=CreateTrigger()
        call DzTriggerRegisterSyncData(t,("BandiD2"),(false))
        call TriggerAddAction(t,function DSyncData2)
    
        set t = null
    //! runtextmacro 이벤트_끝()
    endscope
    
    