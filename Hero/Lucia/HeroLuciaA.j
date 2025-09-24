scope HeroLuciaA
globals
    private constant real SD = 0.00

    private constant real Time1 = 0.60
    private constant real Time2 = 0.20
    private constant real MoveTime = 0.20
    //최대 전진거리
    private constant real MoveD = 450
    
    private constant real scale = 500
    private constant real distance = 400
    boolean array IsCastingLuciaA
endglobals


private function splashD takes nothing returns nothing
    local real Velue = 1.0
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer level = HeroSkillLevel[pid][2]
    
    if IsCastingLuciaA[pid] == true then
        if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
            call HeroDeal('A019',splash.source,GetEnumUnit(),HeroSkillVelue2[4]*Velue,true,false,true,false)
        endif
    endif
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillFx fx = t.data
    local integer i
    local effect e
    local real distancePerTick = 0
    local real remainingDistance = 0

    set fx.r = fx.r + 0.03125
    set fx.i = fx.i + 1

    if fx.i == 1 then

        if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
            set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        else
            set e = AddSpecialEffect("tx-shqy21.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        endif
        call EXSetEffectSize(e, 4.0)
        call EXEffectMatRotateZ(e, GetUnitFacing(fx.caster))
        call EXSetEffectZ(e,EXGetEffectZ(e) + 25)
        call DestroyEffect(e)

        if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
            set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        else
            set e = AddSpecialEffect("tx-shqy10-E.mdl",GetWidgetX(fx.caster)+PolarX( MoveD/2, GetUnitFacing(fx.caster)),GetWidgetY(fx.caster)+PolarY( MoveD/2, GetUnitFacing(fx.caster)))
        endif

        call EXEffectMatRotateZ(e, GetUnitFacing(fx.caster))
        call EXSetEffectZ(e, EXGetEffectZ(e) + 25)
        call EXSetEffectSize(e, 0.75)
        call DestroyEffect(e)
    endif

    if fx.i == 1 and ( GetUnitAbilityLevel(fx.caster, 'BPSE') > 0 or GetUnitAbilityLevel(fx.caster, 'A024') > 0 ) or IsCastingLuciaA[GetPlayerId(GetOwningPlayer(fx.caster))] == false then
        set IsCastingLuciaA[GetPlayerId(GetOwningPlayer(fx.caster))] = false
        call fx.Stop()
        call t.destroy()
    else
        if fx.r >= MoveTime/fx.speed then
            if GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
                set remainingDistance = MoveD - fx.r2
                if remainingDistance > 0 then
                    call SetUnitSafePolarUTA(fx.caster, remainingDistance, GetUnitFacing(fx.caster))
                endif
                set fx.r2 = fx.r2 + remainingDistance

                /*
                if EffectOff[GetPlayerId(GetLocalPlayer())] == false and GetPlayerId(GetOwningPlayer(fx.caster)) != GetPlayerId(GetLocalPlayer()) then
                    set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                else
                    set e = AddSpecialEffect("ZK_BM_Red knife shine4-1.mdl",GetWidgetX(fx.caster)+PolarX( 0, GetUnitFacing(fx.caster)-180),GetWidgetY(fx.caster)+PolarY( 0, GetUnitFacing(fx.caster)-180))
                endif

                call EXEffectMatRotateZ(e, GetUnitFacing(fx.caster))
                call EXSetEffectSize(e, 1.75)
                call DestroyEffect(e)
                */
                call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale, function splashD )
            endif

            set LuciaVelue[fx.pid] = LuciaVelue[fx.pid] + 8
            if LuciaVelue[fx.pid] >= 25 then
                set LuciaVelue[fx.pid] = 25
            endif
            if Player(fx.pid) == GetLocalPlayer() then
                if LuciaForm[fx.pid] == 1 then
                    call DzFrameSetValue(LuciaAden2, LuciaVelue[fx.pid])
                endif
            endif

            set IsCastingLuciaA[GetPlayerId(GetOwningPlayer(fx.caster))] = false
            call fx.Stop()
            call t.destroy()
        else
            set distancePerTick = ((MoveD * fx.speed) / MoveTime) * 0.03125
            call SetUnitSafePolarUTA(fx.caster, distancePerTick , GetUnitFacing(fx.caster))
            set fx.r2 = fx.r2 + distancePerTick
            call t.start( 0.03125, false, function EffectFunction ) 
        endif
    endif
endfunction

private function Main takes nothing returns nothing
    local tick t
    local SkillFx fx
    local real random
    local real r
    local effect e
         
    if GetSpellAbilityId() == 'A07E' then
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
        set fx.r = 0

        call Overlay2Count(fx.pid,'A07E')
        set IsCastingLuciaA[fx.pid] = true

        if EffectOff[GetPlayerId(GetLocalPlayer())] == false and fx.pid != GetPlayerId(GetLocalPlayer()) then
            set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        else
            set e = AddSpecialEffect("nitu.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
        endif

        call EXEffectMatRotateZ(e,AngleWBP(fx.caster,fx.TargetX,fx.TargetY))
        call DestroyEffect(e)
        set e = null

        call Sound3D(fx.caster,'A07S')

        call DummyMagicleash(fx.caster, (Time1+Time2)/fx.speed)
        call AnimationStart3(fx.caster, 7, fx.speed)

        set t.data = fx
        call t.start( Time2 + 0.03125, false, function EffectFunction )

        call CooldownFIX(fx.caster, 'A07E', HeroSkillCD0[14])
    endif
endfunction

private function ASyncData takes nothing returns nothing
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
        call IssuePointOrder( MainUnit[pid], "ancestralspirittarget", x, y )
    endif

    set p=null
endfunction

private function ASyncData2 takes nothing returns nothing
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
    call DzTriggerRegisterSyncData(t,("LuciaA"),(false))
    call TriggerAddAction(t,function ASyncData)
    
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("LuciaA2"),(false))
    call TriggerAddAction(t,function ASyncData2)

    set t = null
//! runtextmacro 이벤트_끝()
endscope

