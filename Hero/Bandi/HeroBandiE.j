scope HeroBandiE
globals
    private real SD = 0
    private constant integer TimeTick = 100
    //변신해제 쿨 5초
    private constant real removetime = 5.0
    private integer array Stack

    private constant real scale = 900
    private constant real distance = 800

endglobals

private function splashD takes nothing returns nothing
    local real Velue = 1.0
    local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
    local integer level = HeroSkillLevel[pid][2]
    local integer random
    
    if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
        call HeroDeal(1,splash.source,GetEnumUnit(),HeroSkillVelue2[15]*Velue,false,false,false,false)
    endif
endfunction

private function EffectFunction2 takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillFx fx = t.data
    local string data
    local integer random
    local integer i
        
    if fx.caster != null and IsUnitDeadVJ(fx.caster) == false then

        call UnitEffectTime2('e035',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetUnitFacing(fx.caster),1.2,0,fx.pid)
        call UnitEffectTime2('e036',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetUnitFacing(fx.caster),1.2,0,fx.pid)
        call UnitEffectTime2('e037',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetUnitFacing(fx.caster),1.2,0,fx.pid)
        call UnitEffectTime2('e038',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetUnitFacing(fx.caster),1.2,0,fx.pid)
        call UnitEffectTime2('e039',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetUnitFacing(fx.caster),1.2,0,fx.pid)
        
        call DzSetUnitModel(fx.caster, "[AWF]FireFlySam1.mdx")
        call AnimationStart3(fx.caster,7, 1.0)

        call DummyMagicleash(fx.caster, 0.5)

        call Sound3D(fx.caster,'A064')
        call Sound3D(fx.caster,'A06P')

        call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 30 )
        if Stack[fx.pid] == 11 then
            call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale, function splashD )
        endif

        if not IsUnitDeadVJ(BandiForm[fx.pid]) then
            call KillUnit(BandiForm[fx.pid])
        endif
        set BandiForm[fx.pid] = CreateUnit(GetOwningPlayer(fx.caster),'e03B',0,0,0)

        //form 샘
        set BandiState[fx.pid] = 2

        call UnitRemoveAbility(fx.caster,'A06F')
        call UnitAddAbility(fx.caster,'A06Q')
        //변신해제 쿨 5초
        call CooldownFIX2(fx.caster,'A06Q',removetime)


        call CastingBarShow(Player(fx.pid),false)

        call UnitRemoveAbility(fx.caster,'A06N')
        set Stack[fx.pid] = 0
        call fx.Stop()
        call t.destroy()
    endif
endfunction

private function EffectFunction takes nothing returns nothing
    local tick t = tick.getExpired()
    local SkillFx fx = t.data
    local string data
    local effect e
    local integer i
    
    set fx.i = fx.i + 1
    if fx.caster != null and IsUnitDeadVJ(fx.caster) == false and GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 then
        if Stack[fx.pid] == 1 then
            if fx.i < TimeTick then
                set Stack[fx.pid] = 1
                if Player(fx.pid) == GetLocalPlayer() then
                    call DzFrameSetValue(CastingBar, I2R(fx.i)/4)
                endif
                call t.start( 0.02, false, function EffectFunction )
            elseif fx.i == TimeTick then
                if Stack[fx.pid] == 1 then
                    set fx.i = 0
                    set Stack[fx.pid] = 11
                    call t.start( 0.02, false, function EffectFunction2 )
                else
                    call fx.Stop()
                    call t.destroy()
                endif
            endif
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
    local tick t
    local SkillFx fx
    local integer i
    local integer pid
    local unit caster

    if GetSpellAbilityId() == 'A06Q' then
        set caster = GetTriggerUnit()
        set pid = GetPlayerId(GetOwningPlayer(caster))

        if not IsUnitDeadVJ(BandiForm[pid]) then
            call KillUnit(BandiForm[pid])
        endif

        set BandiForm[pid] = CreateUnit(GetOwningPlayer(caster),'e03A',0,0,0)
        //form 반디
        set BandiState[pid] = 1

        call DzSetUnitModel(caster, "FireFly_V1.mdx")

        call UnitRemoveAbility(caster,'A06Q')
        call UnitAddAbility(caster,'A06F')
        //변신해제 쿨 5초
        call CooldownFIX2(caster,'A06F',removetime)

        if GetLocalPlayer() == Player(pid) then
            call DzFrameShow(BanAdens[0],true)
            call DzFrameShow(BanAdens[1],false)
        endif

        set caster = null
    endif

    if GetSpellAbilityId() == 'A06F' then
        set t = tick.create(0)
        set fx = SkillFx.Create()
        set fx.caster = GetTriggerUnit()
        set fx.pid = GetPlayerId(GetOwningPlayer(fx.caster))
        set fx.i = 0

        call BanBisulUse(fx.pid)

        call DzSetUnitModel(fx.caster, "tx-LiuYing05.mdx")

        call Overlay2Count(fx.pid,'A06F')

        set t.data = fx
        set Stack[fx.pid] = 1
    
        if Player(fx.pid) == GetLocalPlayer() then
            call DzFrameSetText(CastingTextFrame,"Δ지령-초토화 운석 폭격")
            call DzFrameSetValue(CastingBar,0)
            call CastingBarShow(Player(fx.pid),true)
        endif

        call Sound3D(fx.caster,'A06O')
        call Sound3D(fx.caster,'A063')
        call UnitAddAbility(fx.caster,'A06N')

        call t.start( 0.02, false, function EffectFunction )

        call CooldownFIX(fx.caster,'A06F',HeroSkillCD2[15])

        //call BanBisul2Plus(pid,1)
    endif
endfunction
    
private function ESyncData takes nothing returns nothing
    local player p=(DzGetTriggerSyncPlayer())
    local string data=(DzGetTriggerSyncData())
    local integer pid=GetPlayerId(p)
    local integer dataLen=StringLength(data)
    local integer valueLen
    local real x
    local real y
    local real angle
    
    if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and IsUnitPausedEx(MainUnit[pid]) == false and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID2[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
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
            call IssuePointOrder( MainUnit[pid], "ambush", x, y )
        endif
    endif

    set p=null
endfunction


private function ESyncData2 takes nothing returns nothing
    local player p = DzGetTriggerSyncPlayer()
    local integer pid = GetPlayerId(p)
    local real x
    local real y
    local real angle
    local real speed
    local tick t
    local SkillFx fx

    if Stack[pid] == 1 then
        set t = tick.create(0) 
        set fx = SkillFx.Create()
        set fx.pid = pid
        set fx.caster = MainUnit[fx.pid]
        set fx.i = 0
        set t.data = fx
        set Stack[fx.pid] = 11
        call t.start( 0.02, false, function EffectFunction2 )
    endif

    set p=null
endfunction

//! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
    local trigger t
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function Main)
        
    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("BandiE"),(false))
    call TriggerAddAction(t,function ESyncData)

    set t=CreateTrigger()
    call DzTriggerRegisterSyncData(t,("BandiE2"),(false))
    call TriggerAddAction(t,function ESyncData2)

    set t = null
//! runtextmacro 이벤트_끝()
endscope




