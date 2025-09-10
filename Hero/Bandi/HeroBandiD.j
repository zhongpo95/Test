scope HeroBandiD
    globals
        private constant real SD = 0.00
        //쉐클시간
        private constant real Time = 2.0
        private constant real MoveD = 1000
    
        private constant real TICK = 20
    
        private constant real scale = 600
        private constant real distance = 450
        //범위체크
        private group CheckG
        //더미 유닛
        private unit CheckU
        private integer Nabi
    endglobals
    
    private function splashD takes nothing returns nothing
        local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
        //local integer level = HeroSkillLevel[pid][6]
        local real velue = 1.0
        local integer random
        
        if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
            if IsUnitInGroup(GetEnumUnit(),CheckG) == false then
                //뒤는안떄림
                if AngleTrue( GetUnitFacing(CheckU), AngleWBW(CheckU,GetEnumUnit()), 90 ) then
                    
                    call HeroDeal('A06E',splash.source,GetEnumUnit(),HeroSkillVelue5[14]*velue,false,false,false,false)
                    call UnitEffectTimeEX2('e02B',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),GetRandomReal(0,360),1.2,pid)
    
                    loop
                    exitwhen Nabi == 0
                        set Nabi = Nabi - 1
                        call HeroDeal('A06E',splash.source,GetEnumUnit(),HeroSkillVelue5[14]*velue,false,false,false,false)
                        call UnitEffectTimeEX2('e02B',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),GetRandomReal(0,360),1.2,pid)
                    endloop
    
                    set random = GetRandomInt(0,2)
                    if random == 0 then
                        call Sound3D(GetEnumUnit(),'A03X')
                    elseif random == 1 then
                        call Sound3D(GetEnumUnit(),'A03Y')
                    elseif random == 2 then
                        call Sound3D(GetEnumUnit(),'A05N')
                    endif
                    call GroupAddUnit(CheckG,GetEnumUnit())
                endif
            endif
        endif
    endfunction
    
    private function EffectFunction2 takes nothing returns nothing
        local tick t = tick.getExpired()
        local SkillFx fx = t.data
        local real X
        local real Y
        
        set fx.i = fx.i + 1
        
        if fx.i != (TICK+1) then
            set X = GetWidgetX(fx.dummy)
            set Y = GetWidgetY(fx.dummy)
            call SetUnitX(fx.dummy, X + PolarX( 60, fx.r ))
            call SetUnitY(fx.dummy, Y + PolarY( 60, fx.r ))
            set CheckG = fx.ul.super
            set CheckU = fx.dummy
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.dummy), GetWidgetY(fx.dummy), scale, function splashD )
            set CheckU = null
            set CheckG = null
            call t.start( 0.02, false, function EffectFunction2 )
        else
            call fx.ul.destroy()
            call fx.Stop()
            call t.destroy()
        endif
    
    endfunction
    
    private function EffectFunction3 takes nothing returns nothing
        local tick t = tick.getExpired()
        local SkillFx fx = t.data
        local tick t2
        local SkillFx fx2
        
        set fx.i = fx.i + 1
        if fx.i == 1 then
            if fx.j == 0 then
                call Sound3D(fx.caster,'A060')
            else
                call Sound3D(fx.caster,'A061')
            endif
            call SetUnitGravity(fx.caster,1.2)
        endif

        if fx.i == R2I(40/fx.speed) then
            set t2 = tick.create(0)
            set fx2 = SkillFx.Create()
            set fx2.ul = party.create()
            set fx2.caster = fx.caster
            set fx2.r = fx.r2
            set fx2.pid = GetPlayerId(GetOwningPlayer(fx2.caster))
            set fx2.i = 0
            set fx2.j = 0
            set fx2.speed = ((100+SkillSpeed(fx2.pid))/100)
            set fx2.st = fx.st
            set t2.data = fx2
            call t2.start( 0.02, false, function EffectFunction2 ) 
        endif
    
    
        if fx.i >= R2I(40/fx.speed) then
            call SetUnitGravity(fx.caster,0.6)
            call fx.Stop()
            call t.destroy()
        else
            call SetUnitSafePolarUTA(fx.caster,fx.r/R2I(40/fx.speed), fx.r2 )
            call t.start( 0.02, false, function EffectFunction3 ) 
        endif
    endfunction
    private function EffectFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        local SkillFx fx = t.data

        call SetUnitZVeloP( fx.caster, 20)

        call t.start( 0.586 * (1 - (fx.speed/(100+fx.speed))), false, function EffectFunction3 )
    endfunction
    
    private function Main takes nothing returns nothing
        local real speed
        local tick t
        local SkillFx fx
        local real r
        local integer i
        local effect e
    
        if GetSpellAbilityId() == 'A06E' then
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
            
            if EffectOff[GetPlayerId(GetLocalPlayer())] == false and fx.pid != GetPlayerId(GetLocalPlayer()) then
                set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
            else
                set e = AddSpecialEffect("nitu.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
            endif
            
            call EXEffectMatRotateZ(e,AnglePBW(fx.TargetX,fx.TargetY,fx.caster))
            call DestroyEffect(e)
            set e = null
    
            set fx.r2 = AngleWBP(fx.caster,fx.TargetX,fx.TargetY)
    
            if fx.j == 0 then
                call Sound3D(fx.caster,'A05Y')
            else
                call Sound3D(fx.caster,'A05Z')
            endif
    
            set t.data = fx
    
            if HeroSkillLevel[fx.pid][5] >= 2 then
                call BuffNoNB.Apply( fx.caster, Time, 0 )
                call BuffNoST.Apply( fx.caster, Time, 0 )
            endif
    
            call t.start( 0.439 * (1 - (fx.speed/(100+fx.speed))), false, function EffectFunction )
    
            call CooldownFIX(fx.caster,'A06E',HeroSkillCD5[14])
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
    
    