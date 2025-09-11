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
    
    private function EffectFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        local FxEffect fx = t.data
    
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
                elseif fx.i == 5 then
                    call UnitEffectTime2('e044',GetWidgetX(fx.caster)+PolarX( 50, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster)+PolarY( 50, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.7,0,fx.pid)
                    call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 75, GetUnitFacing(fx.caster) ), scale, function splashD )
                    call UnitEffectTime2('e045',GetWidgetX(fx.caster)+PolarX( 50, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster)+PolarY( 50, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.7,0,fx.pid)
                    call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 75, GetUnitFacing(fx.caster) ), scale, function splashD )
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
            call DummyMagicleash(fx.caster,Time / fx.speed )
            call AnimationStart3(fx.caster,2, fx.speed)

            if GetRandomInt(0,1) == 1 then
                call Sound3D(fx.caster,'A06A')
            else
                call Sound3D(fx.caster,'A06Y')
            endif

            set t.data = fx
            call t.start( Time2 / fx.speed, false, function EffectFunction ) 
            call CooldownFIX(fx.caster,'A06I',3)
            //공격속도가 40퍼 도달시, 이스킬의 공격속도가 40퍼가 아닌 100퍼로 적용
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
        
        if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID3[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
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

