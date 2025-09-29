scope HeroLuciaS
globals
    private constant real SD = 0.00

    //전진시간
    private constant real Time1 = 1.0

    private constant real Time2 = 0.10

    private constant real Time3 = 0.30
    private constant real Time4 = 0.30

    //최대 전진거리
    private constant real MoveD = 250
    private constant real MoveD2 = 50
    
    private constant real scale = 500
    private constant real distance = 400
    boolean array IsCastingLuciaS
endglobals


private function splashD takes nothing returns nothing
    local real Velue = 1.0
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer random
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        if HeroDeal('A02I',splash.source,GetEnumUnit(),HeroSkillVelue0[14]*Velue,false,false,true,false) then
            if HeroSkillLevel[pid][0] >= 2 then
                call NarNabiPlus(pid,6)
            endif
        endif
        //call UnitEffectTimeEX2('e02I',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),GetRandomReal(0,360),1.2,pid)
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

private function EffectFunction2 takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillFx fx = t.data
    local integer i
    local effect e
    local real distancePerTick = 0
    local real remainingDistance = 0

    set fx.r = fx.r + 0.03125
    set fx.i = fx.i + 1

    if fx.j == 0 then
        if fx.i == 1 then
            call Sound3D(fx.caster,'A07T')
        endif

        if fx.i == 1 and ( GetUnitAbilityLevel(fx.caster, 'BPSE') > 0 or GetUnitAbilityLevel(fx.caster, 'A024') > 0 ) or IsCastingLuciaS[GetPlayerId(GetOwningPlayer(fx.caster))] == false then
            set IsCastingLuciaS[GetPlayerId(GetOwningPlayer(fx.caster))] = false
            call fx.Stop()
            call t.destroy()
        else
            if fx.r >= Time2/fx.speed then
                if GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
                    set remainingDistance = MoveD - fx.r2
                    if remainingDistance > 0 then
                        call SetUnitSafePolarUTA(fx.caster, remainingDistance, GetUnitFacing(fx.caster))
                    endif
                    set fx.r2 = fx.r2 + remainingDistance

                    call UnitEffectTimeEX2('e05F', GetWidgetX(fx.caster)+PolarX( 50, GetUnitFacing(fx.caster)), GetWidgetY(fx.caster)+PolarY( 50, GetUnitFacing(fx.caster)), GetUnitFacing(fx.caster), 1.0, fx.pid)
                    call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale, function splashD )
                endif

                set fx.i = 0
                set fx.j = fx.j + 1
                set fx.r = 0
                set fx.r2 = 0
                call t.start( 0.03125, false, function EffectFunction2 ) 
            else
                set distancePerTick = ((MoveD * fx.speed) / Time2) * 0.03125
                call SetUnitSafePolarUTA(fx.caster, distancePerTick , GetUnitFacing(fx.caster))
                set fx.r2 = fx.r2 + distancePerTick
                call t.start( 0.03125, false, function EffectFunction2 ) 
            endif
        endif
    elseif fx.j == 1 then
        if fx.i == 1 then
            //call Sound3D(fx.caster,'A07T')
        endif

        if fx.i == 1 and ( GetUnitAbilityLevel(fx.caster, 'BPSE') > 0 or GetUnitAbilityLevel(fx.caster, 'A024') > 0 ) or IsCastingLuciaS[GetPlayerId(GetOwningPlayer(fx.caster))] == false then
            set IsCastingLuciaS[GetPlayerId(GetOwningPlayer(fx.caster))] = false
            call fx.Stop()
            call t.destroy()
        else
            if fx.r >= Time3/fx.speed then
                if GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
                    /*
                    set remainingDistance = MoveD2 - fx.r2
                    if remainingDistance > 0 then
                        call SetUnitSafePolarUTA(fx.caster, remainingDistance, GetUnitFacing(fx.caster))
                    endif
                    set fx.r2 = fx.r2 + remainingDistance
                    */

                    call UnitEffectTimeEX2('e05E', GetWidgetX(fx.caster)+PolarX( 50, GetUnitFacing(fx.caster)), GetWidgetY(fx.caster)+PolarY( 50, GetUnitFacing(fx.caster)), GetUnitFacing(fx.caster), 1.0, fx.pid)
                    call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale, function splashD )
                endif

                set fx.i = 0
                set fx.j = fx.j + 1
                set fx.r = 0
                set fx.r2 = 0
                call t.start( 0.03125, false, function EffectFunction2 ) 
            else
                /*
                set distancePerTick = ((MoveD2 * fx.speed) / Time3) * 0.03125
                call SetUnitSafePolarUTA(fx.caster, distancePerTick , GetUnitFacing(fx.caster))
                set fx.r2 = fx.r2 + distancePerTick
                */
                call t.start( 0.03125, false, function EffectFunction2 ) 
            endif
        endif
    elseif fx.j == 2 then
        if fx.i == 1 then
            //call Sound3D(fx.caster,'A07T')
        endif

        if fx.i == 1 and ( GetUnitAbilityLevel(fx.caster, 'BPSE') > 0 or GetUnitAbilityLevel(fx.caster, 'A024') > 0 ) or IsCastingLuciaS[GetPlayerId(GetOwningPlayer(fx.caster))] == false then
            set IsCastingLuciaS[GetPlayerId(GetOwningPlayer(fx.caster))] = false
            call fx.Stop()
            call t.destroy()
        else
            if fx.r >= Time4/fx.speed then
                if GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
                /*
                    set remainingDistance = MoveD2 - fx.r2
                    if remainingDistance > 0 then
                        call SetUnitSafePolarUTA(fx.caster, remainingDistance, GetUnitFacing(fx.caster))
                    endif
                    set fx.r2 = fx.r2 + remainingDistance
                */

                    call UnitEffectTimeEX2('e05G', GetWidgetX(fx.caster)+PolarX( 50, GetUnitFacing(fx.caster)), GetWidgetY(fx.caster)+PolarY( 50, GetUnitFacing(fx.caster)), GetUnitFacing(fx.caster), 1.0, fx.pid)
                    call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale, function splashD )
                endif

                set IsCastingLuciaS[GetPlayerId(GetOwningPlayer(fx.caster))] = false
                
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 5 )

                call fx.Stop()
                call t.destroy()
            else
                /*
                set distancePerTick = ((MoveD2 * fx.speed) / Time4) * 0.03125
                call SetUnitSafePolarUTA(fx.caster, distancePerTick , GetUnitFacing(fx.caster))
                set fx.r2 = fx.r2 + distancePerTick
                */
                call t.start( 0.03125, false, function EffectFunction2 ) 
            endif
        endif
    endif
endfunction

private function Main takes nothing returns nothing
    local tick t
    local SkillFx fx
    local real random
    local real r
    local effect e
         
    if GetSpellAbilityId() == 'A07F' then
        call SetUnitFacing(GetTriggerUnit(), AngleWBP(GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() ))
        call EXSetUnitFacing(GetTriggerUnit(), AngleWBP(GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() ))
        set t = tick.create(0)
        set fx = SkillFx.Create()
        set fx.caster = GetTriggerUnit()
        set fx.TargetX = GetSpellTargetX()
        set fx.TargetY = GetSpellTargetY()
        set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set fx.speed = ((100+SkillSpeed(fx.pid))/100)
        set fx.index = IndexUnit(MainUnit[fx.pid])
        set fx.i = 0
        set fx.j = 0
        set fx.r = 0
        set fx.r2 = 0

        call Overlay2Count(fx.pid,'A07F')
        set IsCastingLuciaS[GetPlayerId(GetOwningPlayer(fx.caster))] = true

        set LuciaVelue[fx.pid] = LuciaVelue[fx.pid] + 8
        if LuciaVelue[fx.pid] >= 25 then
            set LuciaVelue[fx.pid] = 25
        endif
        if Player(fx.pid) == GetLocalPlayer() then
            if LuciaForm[fx.pid] == 1 then
                call DzFrameSetValue(LuciaAden2, LuciaVelue[fx.pid])
            endif
        endif
        
        /*
        if EffectOff[GetPlayerId(GetLocalPlayer())] == false and fx.pid != GetPlayerId(GetLocalPlayer()) then
            set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        else
            set e = AddSpecialEffect("nitu.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        endif

        call EXEffectMatRotateZ(e,AngleWBP(fx.caster,fx.TargetX,fx.TargetY))
        call DestroyEffect(e)
        set e = null
        */

        //call Sound3D(fx.caster,'A07T')

        call DummyMagicleash(fx.caster, Time1 / fx.speed)
        call AnimationStart3(fx.caster, 12, fx.speed)
        set t.data = fx
        call t.start( Time2 / fx.speed, false, function EffectFunction2 )

        call CooldownFIX(fx.caster, 'A07F', 5)
    endif
endfunction

private function SSyncData takes nothing returns nothing
    local player p=(DzGetTriggerSyncPlayer())
    local string data=(DzGetTriggerSyncData())
    local integer pid=GetPlayerId(p)
    local integer dataLen=StringLength(data)
    local integer valueLen
    local real x
    local real y
    local real angle
    
    if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID0[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
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

    set p=null
endfunction

private function SSyncData2 takes nothing returns nothing
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
    call DzTriggerRegisterSyncData(t,("LuciaS"),(false))
    call TriggerAddAction(t,function SSyncData)
    
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("LuciaS2"),(false))
    call TriggerAddAction(t,function SSyncData2)

    set t = null
//! runtextmacro 이벤트_끝()
endscope

