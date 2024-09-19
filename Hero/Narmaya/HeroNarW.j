scope HeroNarW
globals
    private constant real DR = 1.00
    private constant real SD = 0.00
    private constant real CoolTime = 1.00

    //폼전환강화 유지시간
    constant real NarChangeTime = 1.0
    //카구라 강화전환시간
    private constant real Time = 1.0
    //겐지 강화전환시간
    private constant real Time2 = 1.0
    
    //범위체크
    private group CheckG
    //더미 유닛
    private unit CheckU
    //이동거리
    private constant real TICK = 20
    private constant real scale = 600
    private constant real distance = 400

    integer array NarForm
    integer array NarStack
    boolean array NarStack2
    unit array NarFormG
    unit array NarFormC
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
        call ul.destroy()
    endmethod
    //! runtextmacro 연출()
endstruct

private function splashD takes nothing returns nothing
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    //local integer level = HeroSkillLevel[pid][6]
    local real velue = 1.0
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        if IsUnitInGroup(GetEnumUnit(),CheckG) == false then
            //뒤는안떄림
            if AngleTrue( GetUnitFacing(CheckU), AngleWBW(CheckU,GetEnumUnit()), 90 ) then
                call HeroDeal(splash.source,GetEnumUnit(),DR*velue,false,false,SD,false)
                call GroupAddUnit(CheckG,GetEnumUnit())
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
        set fx.dummy = UnitEffectTimeEX('e02J', GetWidgetX(fx.caster), GetWidgetY(fx.caster), GetUnitFacing(fx.caster),0.5)
    endif
    
    if fx.i != (TICK+1) then
        set X = GetWidgetX(fx.dummy)
        set Y = GetWidgetY(fx.dummy)
        call SetUnitX(fx.dummy, X + PolarX( 60, fx.Angle ))
        call SetUnitY(fx.dummy, Y + PolarY( 60, fx.Angle ))
        set CheckG = fx.ul.super
        set CheckU = fx.dummy
        call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.dummy), GetWidgetY(fx.dummy), scale, function splashD )
        set CheckU = null
        set CheckG = null
        call t.start( 0.02, false, function EffectFunction3 )
    else
        call fx.Stop()
        call t.destroy()
    endif

endfunction

//카구라
private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillRarW fx = t.data

    call BJDebugMsg("카구라전환댐")
    //'e02J'
    set fx.i = 0
    set fx.ul = party.create()
    set fx.Angle = GetUnitFacing(fx.caster)
    call t.start( 0.02, false, function EffectFunction3 ) 

    //쿨타임조정
    call CooldownFIX2(fx.caster,'A02J',CoolTime)

    call fx.Stop()
    call t.destroy()
endfunction
//겐지
private function EffectFunction2 takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillRarW fx = t.data

    call BJDebugMsg("겐지전환댐")

    //쿨타임조정
    call CooldownFIX2(fx.caster,'A02J',CoolTime)

    call fx.Stop()
    call t.destroy()
endfunction

private function Main takes nothing returns nothing
    local unit caster
    local integer i
    local tick t
    local SkillRarW fx
    

    if GetSpellAbilityId() == 'A02J' then
        set caster = GetTriggerUnit()
        set i = IndexUnit(caster)
        
        //전환강화버프
        if BuffNar00.Exists( caster ) then
            //카구라
            if NarForm[i] != 0 then
                set t = tick.create(0) 
                set fx = SkillRarW.Create()
                set fx.caster = GetTriggerUnit()
                set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
                set fx.speed = ((100+SkillSpeed(fx.pid))/100)
                call BuffNar00.Stop( fx.caster )
                set NarForm[i] = 0
                set NarStack[GetPlayerId(GetOwningPlayer(GetTriggerUnit()))] = 0
                call AddUnitAnimationProperties(fx.caster, "Gold", true)
                call AddUnitAnimationProperties(fx.caster, "Alternate", true)
                //표기변경
                if GetLocalPlayer() == GetOwningPlayer(fx.caster) then
                    call DzFrameSetTexture(NarAden,"Narmaya_blue.blp",0)
                endif
                if not IsUnitDeadVJ(NarFormG[i]) then
                    call KillUnit(NarFormG[i])
                endif
                set NarFormC[i] = CreateUnit(GetOwningPlayer(fx.caster),'e028',0,0,0)

                call DummyMagicleash(fx.caster,Time /fx.speed)
                call AnimationStart3(fx.caster,17, (100+fx.speed)/100)
                set t.data = fx
                call t.start( 0.02, false, function EffectFunction ) 
            //겐지
            else
                set t = tick.create(0) 
                set fx = SkillRarW.Create()
                set fx.caster = GetTriggerUnit()
                set fx.pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
                set fx.speed = ((100+SkillSpeed(fx.pid))/100)
                call BuffNar00.Stop( fx.caster )
                set NarForm[i] = 1
                call AddUnitAnimationProperties(fx.caster, "Gold", false)
                call AddUnitAnimationProperties(fx.caster, "Alternate", false)
                //표기변경
                if GetLocalPlayer() == GetOwningPlayer(fx.caster) then
                    call DzFrameSetTexture(NarAden,"Narmaya_pink.blp",0)
                endif
                if not IsUnitDeadVJ(NarFormC[i]) then
                    call KillUnit(NarFormC[i])
                endif
                set NarFormG[i] = CreateUnit(GetOwningPlayer(fx.caster),'e027',0,0,0)

                call DummyMagicleash(fx.caster,Time2 /fx.speed)
                call AnimationStart3(fx.caster,6, (100+fx.speed)/100)
                set t.data = fx
                call t.start( 0.02, false, function EffectFunction2 ) 
            endif
        //그냥전환
        else
            if NarForm[i] != 0 then
                //카구라
                set NarForm[i] = 0
                set NarStack[GetPlayerId(GetOwningPlayer(GetTriggerUnit()))] = 0
                set NarStack2[GetPlayerId(GetOwningPlayer(GetTriggerUnit()))] = false
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
                    //call DzFrameSetModel(NarAden2, "Narmaya_blue.mdx", 0, 0)
                endif
                if not IsUnitDeadVJ(NarFormG[i]) then
                    call KillUnit(NarFormG[i])
                endif
                set NarFormC[i] = CreateUnit(GetOwningPlayer(caster),'e028',0,0,0)
                //쿨타임조정
                call CooldownFIX(caster,'A02J',CoolTime)
            else
                //겐지
                set NarForm[i] = 1
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
                    //call DzFrameSetModel(NarAden2, "Narmaya_pink.mdx", 0, 0)
                endif
                if not IsUnitDeadVJ(NarFormC[i]) then
                    call KillUnit(NarFormC[i])
                endif
                set NarFormG[i] = CreateUnit(GetOwningPlayer(caster),'e027',0,0,0)
                //쿨타임조정
                call CooldownFIX(caster,'A02J',CoolTime)
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

