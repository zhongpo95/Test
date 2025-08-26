scope HeroNarW
globals
    private constant real SD = 0.00

    //폼전환강화 유지시간
    constant real NarChangeTime = 0.75
    //카구라 강화전환시간
    private constant real Time = 1.5
    //카구라 강화전환사출, 타수
    private constant real Time3 = 1.1

    private constant real TICK2 = 10
    //겐지 강화전환시간
    private constant real Time2 = 1.6
    private constant real scale2 = 1500
    private constant real distance2 = 900
    private constant real scale3 = 800
    private constant real distance3 = 650
    
    //범위체크
    private group CheckG
    //더미 유닛
    private unit CheckU
    //이동거리
    private constant real TICK = 20
    private constant real scale = 300
    private constant real distance = 175
    private boolean StackChecker
endglobals


private struct SkillRarW
    unit caster
    unit dummy
    real TargetX
    real TargetY
    integer pid
    integer i
    real r
    real Angle
    integer index
    real speed
    real Aspeed
    real A2speed
    party ul
    private method OnStop takes nothing returns nothing
        set caster = null
        set dummy = null
        set TargetX = 0
        set TargetY = 0
        set pid = 0
        set i = 0
        set Angle = 0
        set r = 0
        set index = 0
        set speed = 0
        set Aspeed = 0
        set A2speed = 0
    endmethod
    //! runtextmacro 연출()
endstruct

private function splashEffect takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillRarW fx = t.data
    local integer random

    set fx.i = fx.i + 1
    
    if fx.i != (TICK2+1) then
        call HeroDeal('A02J',fx.caster,fx.dummy,fx.r,false,false,false,false)
        call UnitEffectTimeEX2('e02I',GetWidgetX(fx.dummy),GetWidgetY(fx.dummy),GetRandomReal(0,360),1.2,fx.pid)
        set random = GetRandomInt(0,2)
        if random == 0 then
            call Sound3D(fx.dummy,'A03X')
        elseif random == 1 then
            call Sound3D(fx.dummy,'A03Y')
        elseif random == 2 then
            call Sound3D(fx.dummy,'A05N')
        endif
        call t.start(0.33, false, function splashEffect)
    else
        call fx.Stop()
        call t.destroy()
    endif
endfunction

private function splashD takes nothing returns nothing
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    //local integer level = HeroSkillLevel[pid][6]
    local real velue = 1.0
    local integer random
    local tick t
    local SkillRarW fx
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        if IsUnitInGroup(GetEnumUnit(),CheckG) == false then
            //뒤는안떄림
            if AngleTrue( GetUnitFacing(CheckU), AngleWBW(CheckU,GetEnumUnit()), 90 ) then
                set t = tick.create(0) 
                set fx = SkillRarW.Create()
                set fx.caster = splash.source
                set fx.dummy = GetEnumUnit()
                if HeroSkillLevel[fx.pid][1] >= 3 then
                    set velue = 0.5
                endif
                set fx.r = HeroSkillVelue1[14]*velue
                set fx.i = 0
                set fx.pid = pid
                set t.data = fx
                call HeroDeal('A02J',splash.source,GetEnumUnit(),fx.r,false,false,false,false)
                call UnitEffectTimeEX2('e02I',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),GetRandomReal(0,360),1.2,fx.pid)
                set random = GetRandomInt(0,2)
                if random == 0 then
                    call Sound3D(GetEnumUnit(),'A03X')
                elseif random == 1 then
                    call Sound3D(GetEnumUnit(),'A03Y')
                elseif random == 2 then
                    call Sound3D(GetEnumUnit(),'A05N')
                endif
                call GroupAddUnit(CheckG,GetEnumUnit())
                if HeroSkillLevel[fx.pid][1] >= 3 then
                    call t.start(0.33, false, function splashEffect)
                    if StackChecker == false then
                        call NarNabiPlus(fx.pid,1)
                        set StackChecker = true
                    endif
                else
                    call fx.Stop()
                    call t.destroy()
                endif
            endif
        endif
    endif
endfunction

private function EffectFunction3 takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillRarW fx = t.data
    local real X
    local real Y
    
    set fx.i = fx.i + 1
    
    if fx.i == 1 then
        set fx.dummy = UnitEffectTimeEX2('e02J', GetWidgetX(fx.caster), GetWidgetY(fx.caster), GetUnitFacing(fx.caster),0.5,fx.pid)
        call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 10 )
        //쿨타임조정
        call CooldownFIX2(fx.caster,'A02J',HeroSkillCD1[14])
        
    endif
    
    if fx.i != (TICK+1) then
        set X = GetWidgetX(fx.dummy)
        set Y = GetWidgetY(fx.dummy)
        call SetUnitX(fx.dummy, X + PolarX( 60, fx.Angle ))
        call SetUnitY(fx.dummy, Y + PolarY( 60, fx.Angle ))
        set CheckG = fx.ul.super
        set CheckU = fx.dummy
        set StackChecker = false
        call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.dummy), GetWidgetY(fx.dummy), scale, function splashD )
        set StackChecker = false
        set CheckU = null
        set CheckG = null
        call t.start( 0.02, false, function EffectFunction3 )
    else
        call fx.ul.destroy()
        call fx.Stop()
        call t.destroy()
    endif

endfunction

//카구라
private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillRarW fx = t.data

    //'e02J'
    set fx.i = 0
    set fx.ul = party.create()
    set fx.Angle = GetUnitFacing(fx.caster)

    call Sound3D(fx.caster,'A03R')

    if GetRandomInt(0,1) == 0 then
        call Sound3DT(fx.caster,'A039',(Time3 /fx.speed )/2 )
    else
        call Sound3DT(fx.caster,'A03A',(Time3 /fx.speed )/2 )
    endif
    call t.start( Time3 /fx.speed, false, function EffectFunction3 ) 

    if HeroSkillLevel[fx.pid][3] >= 3 then
        call CooldownSet(fx.caster,'A02L',0)
    endif
    //call fx.Stop()
    //call t.destroy()
endfunction

private function splashD2 takes nothing returns nothing
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    //local integer level = HeroSkillLevel[pid][6]
    local real velue = 1.0
    local integer random
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance2) then
        //뒤는안떄림
        if AngleTrue( GetUnitFacing(splash.source), AngleWBW(splash.source,GetEnumUnit()), 90 ) then
            call HeroDeal('A02J',splash.source,GetEnumUnit(),HeroSkillVelue1[14]*velue,false,false,false,false)
            call UnitEffectTimeEX2('e02B',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),GetRandomReal(0,360),1.2,pid)
            set random = GetRandomInt(0,2)
            if random == 0 then
                call Sound3D(GetEnumUnit(),'A03X')
            elseif random == 1 then
                call Sound3D(GetEnumUnit(),'A03Y')
            elseif random == 2 then
                call Sound3D(GetEnumUnit(),'A05N')
            endif
        endif
    endif
endfunction

private function splashD3 takes nothing returns nothing
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    //local integer level = HeroSkillLevel[pid][6]
    local real velue = 1.0
    local integer random
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance3) then
        //뒤는안떄림
        if AngleTrue( GetUnitFacing(splash.source), AngleWBW(splash.source,GetEnumUnit()), 90 ) then
            call HeroDeal('A02J',splash.source,GetEnumUnit(),HeroSkillVelue1[14]*velue,false,false,false,false)
            call UnitEffectTimeEX2('e02B',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),GetRandomReal(0,360),1.2,pid)
            set random = GetRandomInt(0,2)
            if random == 0 then
                call Sound3D(GetEnumUnit(),'A03X')
            elseif random == 1 then
                call Sound3D(GetEnumUnit(),'A03Y')
            elseif random == 2 then
                call Sound3D(GetEnumUnit(),'A05N')
            endif
            if StackChecker == false then
                call NarNabiPlus(pid,1)
                set StackChecker = true
            endif
        endif
    endif
endfunction
//겐지
private function EffectFunction2 takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillRarW fx = t.data

    set fx.i = fx.i + 1

    if fx.i == 1 then
        call UnitEffectTimeEX2('e02K',GetWidgetX(fx.caster)+PolarX(375, GetUnitFacing(fx.caster)), GetWidgetY(fx.caster)+PolarY(375, GetUnitFacing(fx.caster)),GetUnitFacing(fx.caster),1.0/fx.speed,fx.pid)
    endif
    if fx.i == 10 then
        call t.start( 0.2/fx.speed, false, function EffectFunction2 )
    elseif fx.i == 11 then
        call AnimationStart3(fx.caster,15, fx.speed)
        call UnitEffectTime2('e02Q',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetUnitFacing(fx.caster),1.2,0,fx.pid)
        set StackChecker = false
        call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale3, function splashD3 )
        set StackChecker = false
        if HeroSkillLevel[fx.pid][1] >= 2 then
            set NarStack[fx.pid] = 3
        endif

        //쿨타임조정
        call CooldownFIX2(fx.caster,'A02J',HeroSkillCD1[14])
        call fx.Stop()
        call t.destroy()
    else
        call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster)+PolarX(375, GetUnitFacing(fx.caster)), GetWidgetY(fx.caster)+PolarY(375, GetUnitFacing(fx.caster)), scale2, function splashD2 )
        call t.start( 0.1/fx.speed, false, function EffectFunction2 )
    endif
endfunction

private function Main takes nothing returns nothing
    local unit caster
    local integer pid
    local tick t
    local SkillRarW fx
    

    if GetSpellAbilityId() == 'A02J' then
        set caster = GetTriggerUnit()
        set pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        
        call Overlay2Count(pid,'A02J')
        
        //전환강화버프
        if BuffNar00.Exists( caster ) then
            //카구라
            if NarForm[pid] != 0 then
                set t = tick.create(0) 
                set fx = SkillRarW.Create()
                set fx.caster = GetTriggerUnit()
                set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
                set fx.speed = ((100+SkillSpeed(fx.pid))/100)
                call BuffNar00.Stop( fx.caster )
                set NarForm[pid] = 0
                set NarStack[GetPlayerId(GetOwningPlayer(GetTriggerUnit()))] = 0
                call AddUnitAnimationProperties(fx.caster, "Gold", true)
                call AddUnitAnimationProperties(fx.caster, "Alternate", true)
                //표기변경
                if GetLocalPlayer() == GetOwningPlayer(fx.caster) then
                    call DzFrameSetTexture(NarAden,"Narmaya_blue.blp",0)
                    call DzFrameSetTexture(NarAdens[0],"Narmaya_blue.blp",0)
                    call DzFrameSetTexture(NarAdens[1],"Narmaya_blue.blp",0)
                    call DzFrameSetTexture(NarAdens[2],"Narmaya_blue.blp",0)
                    call DzFrameSetTexture(NarAdens[3],"Narmaya_blue.blp",0)
                    call DzFrameSetTexture(NarAdens[4],"Narmaya_blue.blp",0)
                    call DzFrameSetTexture(NarAdens[5],"Narmaya_blue.blp",0)
                endif
                if not IsUnitDeadVJ(NarFormG[pid]) then
                    call KillUnit(NarFormG[pid])
                endif
                set NarFormC[pid] = CreateUnit(GetOwningPlayer(fx.caster),'e028',0,0,0)

                call DummyMagicleash(fx.caster,Time /fx.speed)
                call AnimationStart3(fx.caster,17, fx.speed)
                set t.data = fx
                call t.start( 0.02, false, function EffectFunction ) 
            //겐지
            else
                set t = tick.create(0) 
                set fx = SkillRarW.Create()
                set fx.caster = GetTriggerUnit()
                set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
                set fx.speed = ((100+SkillSpeed(fx.pid))/100)
                set fx.i = 0
                call BuffNar00.Stop( fx.caster )
                set NarForm[pid] = 1
                call AddUnitAnimationProperties(fx.caster, "Gold", false)
                call AddUnitAnimationProperties(fx.caster, "Alternate", false)
                //표기변경
                if GetLocalPlayer() == GetOwningPlayer(fx.caster) then
                    call DzFrameSetTexture(NarAden,"Narmaya_pink.blp",0)
                    call DzFrameSetTexture(NarAdens[0],"Narmaya_pink.blp",0)
                    call DzFrameSetTexture(NarAdens[1],"Narmaya_pink.blp",0)
                    call DzFrameSetTexture(NarAdens[2],"Narmaya_pink.blp",0)
                    call DzFrameSetTexture(NarAdens[3],"Narmaya_pink.blp",0)
                    call DzFrameSetTexture(NarAdens[4],"Narmaya_pink.blp",0)
                    call DzFrameSetTexture(NarAdens[5],"Narmaya_pink.blp",0)
                endif
                if not IsUnitDeadVJ(NarFormC[pid]) then
                    call KillUnit(NarFormC[pid])
                endif
                set NarFormG[pid] = CreateUnit(GetOwningPlayer(fx.caster),'e027',0,0,0)

                call DummyMagicleash(fx.caster,Time2 /fx.speed)
                call AnimationStart3(fx.caster,6, fx.speed)
                call Sound3D(fx.caster,'A03Q')
                //다음15
                set t.data = fx
                call t.start( 0.2/fx.speed, false, function EffectFunction2 ) 
            endif
        //그냥전환
        else
            if NarForm[pid] != 0 then
                //카구라
                set NarForm[pid] = 0
                set NarStack[GetPlayerId(GetOwningPlayer(GetTriggerUnit()))] = 0
                call AddUnitAnimationProperties(caster, "Gold", true)
                call AddUnitAnimationProperties(caster, "Alternate", true)
                //사운드
                if GetRandomInt(0,1) == 1 then
                    call Sound3D(caster,'A02T')
                else
                    call Sound3D(caster,'A02U')
                endif
                //표기변경
                if GetLocalPlayer() == GetOwningPlayer(caster) then
                    call DzFrameSetTexture(NarAden,"Narmaya_blue.blp",0)
                    call DzFrameSetTexture(NarAdens[0],"Narmaya_blue.blp",0)
                    call DzFrameSetTexture(NarAdens[1],"Narmaya_blue.blp",0)
                    call DzFrameSetTexture(NarAdens[2],"Narmaya_blue.blp",0)
                    call DzFrameSetTexture(NarAdens[3],"Narmaya_blue.blp",0)
                    call DzFrameSetTexture(NarAdens[4],"Narmaya_blue.blp",0)
                    call DzFrameSetTexture(NarAdens[5],"Narmaya_blue.blp",0)
                endif
                if not IsUnitDeadVJ(NarFormG[pid]) then
                    call KillUnit(NarFormG[pid])
                endif
                set NarFormC[pid] = CreateUnit(GetOwningPlayer(caster),'e028',0,0,0)
                //쿨타임조정
                call CooldownFIX(caster,'A02J',HeroSkillCD1[14])
            else
                //겐지
                set NarForm[pid] = 1
                call AddUnitAnimationProperties(caster, "Gold", false)
                call AddUnitAnimationProperties(caster, "Alternate", false)
                //사운드
                if GetRandomInt(0,1) == 1 then
                    call Sound3D(caster,'A02V')
                else
                    call Sound3D(caster,'A02W')
                endif
                //표기변경
                if GetLocalPlayer() == GetOwningPlayer(caster) then
                    call DzFrameSetTexture(NarAden,"Narmaya_pink.blp",0)
                    call DzFrameSetTexture(NarAdens[0],"Narmaya_pink.blp",0)
                    call DzFrameSetTexture(NarAdens[1],"Narmaya_pink.blp",0)
                    call DzFrameSetTexture(NarAdens[2],"Narmaya_pink.blp",0)
                    call DzFrameSetTexture(NarAdens[3],"Narmaya_pink.blp",0)
                    call DzFrameSetTexture(NarAdens[4],"Narmaya_pink.blp",0)
                    call DzFrameSetTexture(NarAdens[5],"Narmaya_pink.blp",0)
                endif
                if not IsUnitDeadVJ(NarFormC[pid]) then
                    call KillUnit(NarFormC[pid])
                endif
                set NarFormG[pid] = CreateUnit(GetOwningPlayer(caster),'e027',0,0,0)
                //쿨타임조정
                call CooldownFIX(caster,'A02J',HeroSkillCD1[14])
            endif

        endif
        set caster = null
    endif
endfunction
    
private function WSyncData takes nothing returns nothing
    local player p=(DzGetTriggerSyncPlayer())
    local string data=(DzGetTriggerSyncData())
    local integer pid=GetPlayerId(p)
    local integer dataLen=StringLength(data)
    local integer valueLen
    local real x
    local real y
    local real angle

    if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID1[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
        set x=S2R(data)
        set valueLen=StringLength(R2S(x))
        set data=SubString(data,valueLen+1,dataLen)
        set dataLen=dataLen-(valueLen+1)
        set y=S2R(data)
        set pid=GetPlayerId(p)
        set angle = AngleWBP(MainUnit[pid],x,y)
        call SetUnitFacing(MainUnit[pid],angle)
        call EXSetUnitFacing(MainUnit[pid],angle)
        call IssuePointOrder( MainUnit[pid], "acolyteharvest", x, y )
    endif

    set p=null
endfunction

private function WSyncData2 takes nothing returns nothing
    local player p = DzGetTriggerSyncPlayer()
    local integer pid = GetPlayerId(p)
    local real x
    local real y
    local real angle
    local real speed
    local tick t
    //local FxEffect fx
    
    set p=null
endfunction

            
//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("NarW"),(false))
    call TriggerAddAction(t,function WSyncData)
    
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("NarW2"),(false))
    call TriggerAddAction(t,function WSyncData2)

    set t = null
//! runtextmacro 이벤트_끝()
endscope

