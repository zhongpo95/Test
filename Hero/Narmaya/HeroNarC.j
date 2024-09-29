scope HeroNarC
globals
    private constant real DR = 1.00
    private constant real SD = 0.00
    
    private constant real CoolTime = 0.7
    
    //쉐클시간
    private constant real Time = 0.40
    //스킬이펙트 시간
    private constant real Time2 = 0.40
    //쉐클시간
    private constant real Time4 = 0.80
    //쉐클시간
    private constant real Time5 = 1.25

    //평타강화 1타
    private constant real Time6 = 0.16

    //평타강화 막타
    private constant real Time9 = 0.30
    private constant real Time10 = 0.10


    //전진시간
    private constant real Time3 = 0.40
    //전진거리
    private constant real MoveD = 350

    private constant real scale = 500
    private constant real distance = 400
    private constant real scale2 = 500
    private constant real distance2 = 350

    
endglobals

    private function splashD takes nothing returns nothing
        local real Velue = 1.0
        local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
        local integer random
        
        if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
            call HeroDeal(splash.source,GetEnumUnit(),DR*Velue,false,false,SD,false)
            call UnitEffectTimeEX('e02I',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),GetRandomReal(0,360),1.2)
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
        local real Velue = 1.0
        local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
        local integer random
        
        if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance2) then
            call HeroDeal(splash.source,GetEnumUnit(),DR*Velue,false,false,SD,false)
            call UnitEffectTimeEX('e02I',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),GetRandomReal(0,360),1.2)
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
    private function splashD3 takes nothing returns nothing
        local real Velue = 1.0
        local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
        local integer random
        
        if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance2) then
            call HeroDeal(splash.source,GetEnumUnit(),DR*Velue,false,false,SD,false)
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

    private function EffectFunction3 takes nothing returns nothing
        local tick t = tick.getExpired()
        local SkillFx fx = t.data

        set fx.i = fx.i + 1

        //if BuffMomiz01.Exists( fx.caster ) then
            //call BuffMomiz01.Stop( fx.caster )
            //set fx.Velue = 1
        //endif

        if NarStack[fx.pid] == 3 then
            //막타
            if fx.i == 8 then
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
                call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale2, function splashD2 )
                set NarStack[fx.pid] = 0
                if HeroSkillLevel[fx.pid][1] >= 1 then
                    call BuffNar00.Apply( fx.caster, NarChangeTime, 0 )
                endif
                call fx.Stop()
                call t.destroy()
            elseif fx.i == 1 or fx.i == 3 or fx.i == 5 then
                call UnitEffectTime2('e02E',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetUnitFacing(fx.caster),0.7,0)
                call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale2, function splashD2 )
                call t.start( Time10/fx.speed , false, function EffectFunction3 )
            elseif fx.i == 7 then
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
                call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale2, function splashD2 )
                call t.start( Time10/fx.speed , false, function EffectFunction3 )
            else
                call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale2, function splashD2 )
                call t.start( Time10/fx.speed , false, function EffectFunction3 )
            endif
        elseif NarStack[fx.pid] ==  1 then
            call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 2 )
            if fx.i == 5 then
                call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 75, GetUnitFacing(fx.caster) ), scale, function splashD )
                set NarStack[fx.pid] = NarStack[fx.pid] + 1
                call fx.Stop()
                call t.destroy()
            elseif fx.i == 4 then
                call UnitEffectTime2('e02P',GetWidgetX(fx.caster)+PolarX( 50, GetUnitFacing(fx.caster) ) ,GetWidgetY(fx.caster)+PolarY( 50, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.7,0)
                call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 75, GetUnitFacing(fx.caster) ), scale, function splashD )
                call t.start( Time6/fx.speed , false, function EffectFunction3 ) 
            elseif fx.i == 3 then
                call UnitEffectTime2('e02O',GetWidgetX(fx.caster)+PolarX( 50, GetUnitFacing(fx.caster) ) ,GetWidgetY(fx.caster)+PolarY( 50, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.7,0)
                call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 75, GetUnitFacing(fx.caster) ), scale, function splashD )
                call t.start( Time6/fx.speed , false, function EffectFunction3 ) 
            elseif fx.i == 2 then
                call UnitEffectTime2('e02M',GetWidgetX(fx.caster)+PolarX( 50, GetUnitFacing(fx.caster) ) ,GetWidgetY(fx.caster)+PolarY( 50, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.7,0)
                call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 75, GetUnitFacing(fx.caster) ), scale, function splashD )
                call t.start( Time6/fx.speed , false, function EffectFunction3 ) 
            elseif fx.i == 1 then
                call UnitEffectTime2('e02L',GetWidgetX(fx.caster)+PolarX( 50, GetUnitFacing(fx.caster)+90 )+PolarX( 50, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster)+PolarY( 50, GetUnitFacing(fx.caster)+90 )+PolarY( 50, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.7,0)
                call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 75, GetUnitFacing(fx.caster) ), scale, function splashD )
                call t.start( Time6/fx.speed , false, function EffectFunction3 ) 
            endif
        elseif NarStack[fx.pid] == 2 then
            call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 2 )
            if fx.i == 4 then
                call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 75, GetUnitFacing(fx.caster) ), scale, function splashD )
                set NarStack[fx.pid] = NarStack[fx.pid] + 1
                call fx.Stop()
                call t.destroy()
            elseif fx.i == 3 then
                call UnitEffectTime2('e02O',GetWidgetX(fx.caster)+PolarX( 50, GetUnitFacing(fx.caster) ) ,GetWidgetY(fx.caster)+PolarY( 50, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.7,0)
                call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 75, GetUnitFacing(fx.caster) ), scale, function splashD )
                call t.start( Time6/fx.speed , false, function EffectFunction3 ) 
            elseif fx.i == 2 then
                call UnitEffectTime2('e02M',GetWidgetX(fx.caster)+PolarX( 50, GetUnitFacing(fx.caster) ) ,GetWidgetY(fx.caster)+PolarY( 50, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.7,0)
                call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 75, GetUnitFacing(fx.caster) ), scale, function splashD )
                call t.start( Time6/fx.speed , false, function EffectFunction3 ) 
            elseif fx.i == 1 then
                call UnitEffectTime2('e02L',GetWidgetX(fx.caster)+PolarX( 50, GetUnitFacing(fx.caster)+90 )+PolarX( 50, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster)+PolarY( 50, GetUnitFacing(fx.caster)+90 )+PolarY( 50, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.7,0)
                call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 75, GetUnitFacing(fx.caster) ), scale, function splashD )
                call t.start( Time6/fx.speed , false, function EffectFunction3 ) 
            endif
        endif

    endfunction

    //카구라
    private function EffectFunction2 takes nothing returns nothing
        local tick t = tick.getExpired()
        local SkillFx fx = t.data
    
        if NarStack[fx.pid] == 3 then
            //막타
            call DummyMagicleash(fx.caster, Time5 /fx.speed)
            call AnimationStart3(fx.caster,19, (100+fx.speed)/100)
            set fx.i = 0
            call Sound3DT(fx.caster,'A03E',0.02)
            call t.start( Time9/fx.speed, false, function EffectFunction3 ) 
        elseif NarStack[fx.pid] ==  1 or NarStack[fx.pid] == 2 then
            call DummyMagicleash(fx.caster, Time4 /fx.speed)
            call AnimationStart3(fx.caster,18, (100+fx.speed)/100)
            if NarStack[fx.pid] ==  1 then
                call Sound3D(fx.caster,'A03H')
            elseif NarStack[fx.pid] ==  2 then
                call Sound3D(fx.caster,'A03I')
            endif
            set fx.i = 0
            call UnitEffectTime2('e02N',GetWidgetX(fx.caster)+PolarX( 50, GetUnitFacing(fx.caster)+270 )+PolarX( 50, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster)+PolarY( 50, GetUnitFacing(fx.caster)+270 )+PolarY( 50, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.7,0)
            call t.start( Time6/fx.speed , false, function EffectFunction3 ) 
        else
            //일반평타
            //파란이펙트
            if GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
                call UnitEffectTime2('e02R',GetWidgetX(fx.caster)+PolarX( 50, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster)+PolarY( 50, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.7,0)
                call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 75, GetUnitFacing(fx.caster) ), scale, function splashD )            
            endif
            call fx.Stop()
            call t.destroy()
        endif
        
    endfunction

    //겐지
    private function EffectFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        local SkillFx fx = t.data
        
        set fx.i = fx.i + 1
        //MoveD 전진거리
        if fx.i >= 20/fx.speed then
            //빨간이펙트
            if NarStack[fx.pid] < 3 then
                set NarStack[fx.pid] = NarStack[fx.pid] + 1
            endif

            if GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
                call UnitEffectTime2('e02S',GetWidgetX(fx.caster)+PolarX( 50, GetUnitFacing(fx.caster) ),GetWidgetY(fx.caster)+PolarY( 50, GetUnitFacing(fx.caster) ),GetUnitFacing(fx.caster),0.7,0)
                call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX( 75, GetUnitFacing(fx.caster) ), GetWidgetY(fx.caster) +PolarY( 75, GetUnitFacing(fx.caster) ), scale, function splashD3 )
            endif
            
            call fx.Stop()
            call t.destroy()
        else
            call SetUnitSafePolarUTA(fx.caster, MoveD/(20/fx.speed), GetUnitFacing(fx.caster))
            call t.start( 0.02, false, function EffectFunction ) 
        endif
    endfunction
    
    private function Main takes nothing returns nothing
        local tick t
        local SkillFx fx
        local real random
             
        if GetSpellAbilityId() == 'A02R' then
            set t = tick.create(0) 
            set fx = SkillFx.Create()
            set fx.caster = GetTriggerUnit()
            set fx.TargetX = GetSpellTargetX()
            set fx.TargetY = GetSpellTargetY()
            set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
            set fx.speed = ((100+SkillSpeed(fx.pid))/100)
            set fx.index = IndexUnit(MainUnit[fx.pid])
            set fx.i = 0 
            
            call CooldownFIX(fx.caster,'A02R', CoolTime)

            //카구라
            if NarForm[fx.index] == 0 then
                if NarStack[fx.pid] == 3 then
                    set t.data = fx
                    call t.start( 0.02, false, function EffectFunction2 ) 
                elseif NarStack[fx.pid] ==  1 or NarStack[fx.pid] == 2 then
                    set t.data = fx
                    call t.start( 0.02, false, function EffectFunction2 ) 
                else
                    call DummyMagicleash(fx.caster, Time /fx.speed)
                    call AnimationStart3(fx.caster,21, (100+fx.speed)/100)
                    set t.data = fx
                    call t.start( Time2 /fx.speed, false, function EffectFunction2 ) 
                endif
            //겐지
            elseif NarForm[fx.index] == 1 then
                call DummyMagicleash(fx.caster,Time3 /fx.speed)
                call AnimationStart3(fx.caster,21, (100+fx.speed)/100)
                set t.data = fx
                call t.start( 0.02, false, function EffectFunction ) 
            endif

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
        
        if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID9[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
            set x=S2R(data)
            set valueLen=StringLength(R2S(x))
            set data=SubString(data,valueLen+1,dataLen)
            set dataLen=dataLen-(valueLen+1)
            set y=S2R(data)
            set pid=GetPlayerId(p)
            set angle = AngleWBP(MainUnit[pid],x,y)
            call SetUnitFacing(MainUnit[pid],angle)
            call EXSetUnitFacing(MainUnit[pid],angle)
            call IssuePointOrder( MainUnit[pid], "auravampiric", x, y )
        endif
        
        set p=null
    endfunction
            
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("NarC"),(false))
    call TriggerAddAction(t,function CSyncData)

    set t = null
//! runtextmacro 이벤트_끝()
endscope