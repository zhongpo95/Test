scope HeroBandiF
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
        private constant real MoveD = 600
        private constant real MoveD2 = 300
        //범위체크
        private group CheckG
        //더미 유닛
        private unit CheckU
        boolean array IsCastingBandiF
    endglobals
    
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
        local SkillFx fx = t.data
        local integer i = 0
        local real x = 0
        local real y = 0
        local real r = 0
        local real r2 = 0
        local effect e
    
        set fx.i = fx.i + 1

        //if GetUnitAbilityLevel(fx.caster, 'BPSE') < 1 and GetUnitAbilityLevel(fx.caster, 'A024') < 1 then
            if fx.i == 1 then
                call AnimationStart3(fx.caster, 4, 1.00)
                if fx.pid != GetPlayerId(GetLocalPlayer()) then
                    set fx.e = AddSpecialEffectTarget(".mdl", fx.caster,"chest")
                else
                    set fx.e = AddSpecialEffectTarget("tx-LiuYing17.mdl",fx.caster,"chest")
                endif
                call t.start( 0.02 / fx.speed, false, function EffectFunction ) 
            elseif fx.i == 2 then
                if fx.pid != GetPlayerId(GetLocalPlayer()) then
                    set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                else
                    set e = AddSpecialEffect("tx-LiuYing15.mdl", GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                endif
                call EXSetEffectZ(e, GetUnitFlyHeight(fx.caster) + 250 )
                call EXEffectMatRotateZ(e, GetUnitFacing(fx.caster) + 90)
                call EXSetEffectSize(e, 2.0)
                call DestroyEffect(e)
                set e = null
                if fx.pid != GetPlayerId(GetLocalPlayer()) then
                    set e = AddSpecialEffect(".mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                else
                    set e = AddSpecialEffect("Suzakuin-17-Y.mdl", GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                endif
                call EXSetEffectZ(e, GetUnitFlyHeight(fx.caster) + 250 )
                call EXEffectMatRotateZ(e, GetUnitFacing(fx.caster) + 90)
                call DestroyEffect(e)
                set e = null
                call t.start( 0.85 / fx.speed, false, function EffectFunction ) 
            elseif fx.i == 3 then
                if fx.j == 1 then
                    call Sound3D(fx.caster,'A077')
                elseif fx.j == 0 then
                    call Sound3D(fx.caster,'A077')
                endif
                call DestroyEffect(fx.e)
                set fx.e = null
                call AnimationStart3(fx.caster, 5, 1.00)
                call DelayAlpha(fx.caster, 0.5 / fx.speed)
                call t.start( 0.05 / fx.speed, false, function EffectFunction ) 
            elseif fx.i <= 13 and fx.i >= 4 then
                call SetUnitSafePolarUTA(fx.caster, MoveD / R2I(10/fx.speed), GetUnitFacing(fx.caster) )
                call t.start( 0.05 / fx.speed, false, function EffectFunction ) 
            elseif fx.i == 14 then
                set fx.TargetX = GetUnitX(fx.caster)
                set fx.TargetY = GetUnitY(fx.caster)
                call t.start( 0.04 / fx.speed, false, function EffectFunction )
                if fx.j == 1 then
                    call Sound3D(fx.caster,'A072')
                    call Sound3D(fx.caster,'A078')
                elseif fx.j == 0 then
                    call Sound3D(fx.caster,'A073')
                    call Sound3D(fx.caster,'A078')
                endif
            elseif fx.i <= 34 and fx.i >= 15 then
                set r = GetRandomReal(0,360)
                set r2 = GetRandomReal(0,SquareRoot(250*250))
                set i = GetRandomInt(1,8)
                if i == 1 then
                    call UnitEffectTime2('e04A',fx.TargetX+PolarX( r2, r ),fx.TargetY+PolarY( r2, r ),GetRandomReal(0,360),1.5,0,fx.pid)
                elseif i == 2 then
                    call UnitEffectTime2('e04N',fx.TargetX+PolarX( r2, r ),fx.TargetY+PolarY( r2, r ),GetRandomReal(0,360),1.5,0,fx.pid)
                elseif i == 3 then
                    call UnitEffectTime2('e04L',fx.TargetX+PolarX( r2, r ),fx.TargetY+PolarY( r2, r ),GetRandomReal(0,360),1.5,0,fx.pid)
                elseif i == 4 then
                    call UnitEffectTime2('e04M',fx.TargetX+PolarX( r2, r ),fx.TargetY+PolarY( r2, r ),GetRandomReal(0,360),1.5,0,fx.pid)
                elseif i == 5 then
                    call UnitEffectTime2('e04C',fx.TargetX+PolarX( r2, r ),fx.TargetY+PolarY( r2, r ),GetRandomReal(0,360),1.5,0,fx.pid)
                elseif i == 6 then
                    call UnitEffectTime2('e04B',fx.TargetX+PolarX( r2, r ),fx.TargetY+PolarY( r2, r ),GetRandomReal(0,360),1.5,0,fx.pid)
                elseif i == 7 then
                    call UnitEffectTime2('e04J',fx.TargetX+PolarX( r2, r ),fx.TargetY+PolarY( r2, r ),GetRandomReal(0,360),1.5,0,fx.pid)
                elseif i == 8 then
                    call UnitEffectTime2('e04K',fx.TargetX+PolarX( r2, r ),fx.TargetY+PolarY( r2, r ),GetRandomReal(0,360),1.5,0,fx.pid)
                endif
                call SetUnitX(fx.caster,fx.TargetX+PolarX( r2, r ))
                call SetUnitY(fx.caster,fx.TargetY+PolarY( r2, r ))
                if fx.i == 24 then
                    call UnitEffectTimeEX2('e048',fx.TargetX,fx.TargetY,GetRandomReal(0,360),2.0,fx.pid)
                    call UnitEffectTimeEX2('e047',fx.TargetX,fx.TargetY,GetRandomReal(0,360),2.0,fx.pid)
                endif
                call t.start( 0.04 / fx.speed, false, function EffectFunction )
            elseif fx.i == 35 then
                if fx.j == 1 then
                    call Sound3D(fx.caster,'A079')
                elseif fx.j == 0 then
                    call Sound3D(fx.caster,'A079')
                endif
                call SetUnitX(fx.caster,fx.TargetX)
                call SetUnitY(fx.caster,fx.TargetY)
                call UnitEffectTimeEX2('e04O',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetUnitFacing(fx.caster)-45,1.5,fx.pid)
                call UnitEffectTimeEX2('e04Q',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetUnitFacing(fx.caster),2.0,fx.pid)
                call UnitEffectTimeEX2('e04R',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetUnitFacing(fx.caster),2.0,fx.pid)
                set r = GetUnitFacing(fx.caster)+180
                call SetUnitFacing(fx.caster, r)
                call EXSetUnitFacing(fx.caster, r)
                call AnimationStart3(fx.caster, 6, 1.00)
                call DelayRemoveAlpha(fx.caster, 0.4 / fx.speed)
                call t.start( 0.04 / fx.speed, false, function EffectFunction )
            elseif fx.i <= 42 and fx.i >= 36 then
                call SetUnitSafePolarUTA(fx.caster, MoveD2 / R2I(7/fx.speed), GetUnitFacing(fx.caster) )
                call t.start( 0.04 / fx.speed, false, function EffectFunction )
            elseif fx.i == 43 then
                call t.start( 0.24 / fx.speed, false, function EffectFunction )
            elseif fx.i == 44 then
                call PauseUnitEx(fx.caster,false)
                call BuffNoNB.Stop( fx.caster )
                call BuffNoST.Stop( fx.caster )
                call fx.Stop()
                call t.destroy()
            endif
            /*
        else
            if fx.e != null then
                call DestroyEffect(fx.e)
                set fx.e = null
            endif
            call PauseUnitEx(fx.caster,false)
            call fx.Stop()
            call t.destroy()
        endif
            */
    endfunction

    private function EffectFunctionZ takes nothing returns nothing
        local tick t = tick.getExpired()
        local SkillFx fx = t.data
        local real r
        
        call UnitAddAbility(fx.caster,'Arav')
        call UnitRemoveAbility(fx.caster,'Arav')

        set fx.r = fx.r + 0.04

        if fx.r <= 1.300 then
            set r = RMaxBJ(( 10.00 - ( fx.r - 1.700 ) * 10.00 ), 2.00)
        elseif fx.r <= 1.800 then
            set r = 0
        else
            set r = GetUnitFlyHeight(fx.caster) / 8.0
        endif

        if GetUnitFlyHeight(fx.caster) >= 0 and fx.r <= 2.20 then
            if fx.r <= 1.600 then
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

    private function Main takes nothing returns nothing
        local real speed
        local tick t
        local SkillFx fx
        local tick t2
        local SkillFx fx2
        
        if GetSpellAbilityId() == 'A06G' then
            call SetUnitFacing(GetTriggerUnit(), AngleWBP(GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() ))
            call EXSetUnitFacing(GetTriggerUnit(), AngleWBP(GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() ))
            set t = tick.create(0) 
            set fx = SkillFx.Create()
            set fx.caster = GetTriggerUnit()
            set fx.pid = GetPlayerId(GetOwningPlayer(fx.caster))
            set fx.speed = ((100+SkillSpeed(fx.pid))/100)
            set IsCastingBandiF[fx.pid] = true
            set fx.i = 0
            
            //call BanBisul2Use(pid)
            call Overlay2Count(fx.pid,'A06G')

            call BuffNoNB.Apply( fx.caster, Time, 0 )
            call BuffNoST.Apply( fx.caster, Time, 0 )
            
            //공격속도가 40퍼 도달시, 이스킬의 공격속도가 40퍼가 아닌 100퍼로 적용
            if SkillSpeed(fx.pid) != 40 then
                call DummyMagicleash(fx.caster, Time / fx.speed )
                call PauseUnitEx(fx.caster,true)
                call AnimationStart3(fx.caster, 5, fx.speed)
        

                set fx.j = GetRandomInt(0,1)
                if fx.j == 1 then
                    call Sound3D(fx.caster,'A076')
                    call Sound3D(fx.caster,'A070')
                    //call Sound3D(fx.caster,'A072')
                else
                    call Sound3D(fx.caster,'A076')
                    call Sound3D(fx.caster,'A071')
                    //call Sound3D(fx.caster,'A073')
                endif

                call AnimationStart3(fx.caster, 3, 1.50 * fx.speed)
                call BuffNoNB.Apply( fx.caster, 4 / (1.50 * fx.speed), 0 )
                call BuffNoST.Apply( fx.caster, 4 / (1.50 * fx.speed), 0 )

                set fx2 = SkillFx.Create()
                set t2 = tick.create(fx2)
                set fx2.pid = fx.pid
                set fx2.caster = fx.caster
                set fx2.speed = fx.speed
                set fx2.r = 0

                call t2.start( 0.04 / fx.speed , true, function EffectFunctionZ )

                set t.data = fx
                call t.start( 1.0 / fx.speed, false, function EffectFunction ) 
            else
                set fx.speed = ((100+SkillSpeed2(fx.pid,60))/100)
                call DummyMagicleash(fx.caster, Time / fx.speed )
                call PauseUnitEx(fx.caster,true)
                call AnimationStart3(fx.caster, 5, fx.speed)
        

                set fx.j = GetRandomInt(2,3)
                if fx.j == 2 then
                    call Sound3D(fx.caster,'A075')
                else
                    call Sound3D(fx.caster,'A074')
                endif

                call AnimationStart3(fx.caster, 3, 1.50 * fx.speed)
                call BuffNoNB.Apply( fx.caster, 4 / (1.50 * fx.speed), 0 )
                call BuffNoST.Apply( fx.caster, 4 / (1.50 * fx.speed), 0 )

                set fx2 = SkillFx.Create()
                set t2 = tick.create(fx2)
                set fx2.pid = fx.pid
                set fx2.caster = fx.caster
                set fx2.speed = fx.speed
                set fx2.r = 0

                call t2.start( 0.04 / fx.speed , true, function EffectFunctionZ )

                set t.data = fx
                call t.start( 1.0 / fx.speed, false, function EffectFunction ) 
            endif
            call CooldownFIX(fx.caster,'A06G',5)
        endif
    endfunction

        
    private function FSyncData takes nothing returns nothing
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
                call IssuePointOrder( MainUnit[pid], "attributemodskill", x, y )
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
        call DzTriggerRegisterSyncData(t,("BandiF"),(false))
        call TriggerAddAction(t,function FSyncData)
    
        set t = null
    //! runtextmacro 이벤트_끝()
    endscope
    
    