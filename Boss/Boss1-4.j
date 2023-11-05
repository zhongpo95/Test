library Boss4 requires FX,DataUnit,UIBossHP,DamageEffect2,UIBossEnd,DataMap,Boss1
    globals
        //2분30초 7500
        //test1500

        private constant integer Pattern1Cool = 500
        private integer NoDieCheck
        private unit CheckUnit

        private constant real scale = 3000
        private constant real distance = 2000
    endglobals
    
    private struct FxEffect
        unit caster
        unit dummy
        integer i
        private method OnStop takes nothing returns nothing
            set caster = null
            set dummy = null
        endmethod
        //! runtextmacro 연출()
    endstruct
    
    private function splashD2 takes nothing returns nothing
        if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
            call KnockbackInverse( GetEnumUnit(), splash.source, 2000, 2.0)
            call SetUnitZVelo( GetEnumUnit(), 30)
            call BossDeal( splash.source, GetEnumUnit(), 100 , false)
        endif
    endfunction
    
    private struct FxEffect_Timer extends array
        private method OnAction takes FxEffect fx returns nothing
            local effect e
            local real r
            set fx.i = fx.i + 1
            if fx.caster != null and IsUnitDeadVJ(fx.caster) == false then
                if fx.i == 75 then
                    set fx.dummy = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e01V',GetWidgetX(fx.caster),GetWidgetY(fx.caster), GetUnitFacing(fx.caster))
                    call SetUnitVertexColorBJ( fx.caster, 70, 70, 100, 0 )
                    call UnitEffectTimeEX('e00F',GetWidgetX(fx.caster),GetWidgetY(fx.caster),0,3)
                    call UnitEffectTimeEX('e00G',GetWidgetX(fx.caster),GetWidgetY(fx.caster),0,3)
                    call UnitEffectTimeEX('e01S',GetWidgetX(fx.caster),GetWidgetY(fx.caster),0,3)
                    call UnitAddAbility(fx.caster,'A00V')
                //카운터침
                elseif fx.i != 150 and fx.i >= 75 and GetUnitAbilityLevel(fx.caster,'A00V') == 0 then
                    call Sound3D(fx.caster,'A00U')
                    call AnimationStart(fx.caster,11)
                    call SetUnitVertexColorBJ( fx.caster, 100, 100, 100, 0 )
                    call DelayKill(fx.caster,1.5)
                    call KillUnit(fx.dummy)
                    call fx.Stop()
                //카운터를 못침
                elseif fx.i == 150 then
                    call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale, function splashD2 )
                    call UnitRemoveAbility(fx.caster,'A00V')
                    call SetUnitVertexColorBJ( fx.caster, 100, 100, 100, 0 )
                    //call AnimationStart2(fx.caster, 0, 0.6, 3.0)
                    call AnimationStart4(fx.caster, 36, 0.02)
                    call DelayKill(fx.caster,2.2)
                    call KillUnit(fx.dummy)
                    call fx.Stop()
                endif
            //주금
            else
                call UnitRemoveAbility(fx.caster,'A00V')
                call SetUnitVertexColorBJ( fx.caster, 100, 100, 100, 0 )
                call fx.Stop()
            endif
        endmethod
        //! runtextmacro 연출효과_타이머("FxEffect", "0.02", "true")
    endstruct

    private function NoDie takes nothing returns nothing
        set NoDieCheck = NoDieCheck + 1
        if IsUnitDeadVJ(GetEnumUnit()) then
            set NoDieCheck = NoDieCheck - 1
        endif
    endfunction
    
    private function AllDie takes nothing returns nothing
        call FailedStart(GetEnumUnit())
    endfunction
    
    private function SuccessF takes nothing returns nothing
        call SuccessStart(GetEnumUnit())
        call RewardStart(GetEnumUnit())
        call AddReward(GetOwningPlayer(GetEnumUnit()), "59"+";"+"0")
        call AddReward(GetOwningPlayer(GetEnumUnit()), "59"+";"+"0")
        call AddReward(GetOwningPlayer(GetEnumUnit()), "59"+";"+"0")
        call AddReward(GetOwningPlayer(GetEnumUnit()), "59"+";"+"0")
        //확률드랍
        call AddRandomReward(GetOwningPlayer(GetEnumUnit()), "12"+";"+"0", 100)
        call AddRandomReward(GetOwningPlayer(GetEnumUnit()), "12"+";"+"0", 100)
        call AddRandomReward(GetOwningPlayer(GetEnumUnit()), "12"+";"+"0", 100)
        call AddRandomReward(GetOwningPlayer(GetEnumUnit()), "12"+";"+"0", 100)
        call AddRandomReward(GetOwningPlayer(GetEnumUnit()), "12"+";"+"0", 100)
        call AddRandomReward(GetOwningPlayer(GetEnumUnit()), "12"+";"+"0", 100)
        call AddRandomReward(GetOwningPlayer(GetEnumUnit()), "12"+";"+"0", 100)
        call AddRandomReward(GetOwningPlayer(GetEnumUnit()), "12"+";"+"0", 100)
        call AddRandomReward(GetOwningPlayer(GetEnumUnit()), "12"+";"+"0", 100)
        call AddRandomReward(GetOwningPlayer(GetEnumUnit()), "12"+";"+"0", 100)
    endfunction
    
    private function Function2 takes nothing returns nothing
        local tick t = tick.getExpired()
        local MapStruct st = t.data
        local FxEffect fx
        local integer index
        
        set NoDieCheck = 0
        call ForGroup(st.ul.super,function NoDie)
        
        //다죽음
        if NoDieCheck == 0 then
            call KillUnit(st.caster)
            call RemoveUnit(st.caster)
            call ForGroup(st.ul.super,function AllDie)
            set st.caster = null
            call MapReset(st.rectnumber,2)
            set st.rectnumber = 0
            call t.destroy()
        else
            if UnitHP[IndexUnit(st.caster)] > 0 and IsUnitDeadVJ(st.caster) == false then
                set st.pattern1 = st.pattern1 - 1
                if st.pattern1 <= 0 then
                    set fx = FxEffect.Create()
                    set fx.caster = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'h00G',GetWidgetX(st.caster)+Polar.X(1000, GetUnitFacing(st.caster)),GetWidgetY(st.caster)+Polar.Y(1000, GetUnitFacing(st.caster)) , GetUnitFacing(st.caster)+180)
                    call AddSpecialEffectTarget("Abilities\\Spells\\Human\\MassTeleport\\MassTeleportTarget.mdl",fx.caster,"origin")
                    call UnitRemoveAbility(fx.caster,'Amov')
                    call SetUnitPathing(fx.caster,false)
                    call PauseUnit(fx.caster,true)
                    call SetUnitPosition(fx.caster,GetWidgetX(fx.caster),GetWidgetY(fx.caster))
                    set fx.i = 0
                    call AnimationStart(fx.caster, 12)
                    call fx.Start()
                    set st.pattern1 = Pattern1Cool
                endif
            //주금
            else
                //그룹 보상
                call ForGroup(st.ul.super,function SuccessF)
                call st.ul.destroy()
                call KillUnit(st.caster)
                set st.caster = null
                call BossMapReset(st.rectnumber, 2)
                set st.rectnumber = 0
                call t.destroy()
            endif
        endif
    endfunction
    
    private function Boss4Start2 takes MapStruct str returns nothing
        local tick t = tick.create(0) 
        local MapStruct st = str
        
        set t.data = st
        
        set MapRectCheck[st.rectnumber] = false
        
        call t.start( 0.02 , true, function Function2 ) 
    endfunction
    
    private function NoRemove takes nothing returns nothing
        if GetLocalPlayer() == GetOwningPlayer(GetEnumUnit()) then
            call PlayersBossBarShow(GetLocalPlayer(),true)
            call DzFrameShow(BossTip, false)
        endif
        call BOSSHPSTART(CheckUnit, GetPlayerId(GetOwningPlayer(GetEnumUnit())))
    endfunction
    
    private function Function takes nothing returns nothing
        local tick t = tick.getExpired()
        local MapStruct st = t.data
        local integer Dataindex
        local integer UnitIndex
        local unit Unit
        
        if splash.range( splash.ALLY, st.caster, GetWidgetX(st.caster), GetWidgetY(st.caster), 500, function SplashNothing ) == 0 then
            //컷신?
            call KillUnit(st.caster)
            set st.caster = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'h00F',GetRectCenterX(MapRectReturn(st.rectnumber)),GetRectCenterY(MapRectReturn(st.rectnumber)),270)
            set Dataindex = DataUnitIndex(st.caster)
            set UnitIndex = IndexUnit(st.caster)
            set UnitHPMAX[UnitIndex] = UnitSetHP[Dataindex]
            set UnitHP[UnitIndex] = UnitSetHP[Dataindex]
            set UnitSDMAX[UnitIndex] = UnitSetSD[Dataindex]
            set UnitSD[UnitIndex] = UnitSetSD[Dataindex]
            set UnitArm[UnitIndex] = UnitSetArm[Dataindex]
            set UnitCasting[UnitIndex] = false
            
            //이동능력제거
            call UnitRemoveAbility(st.caster,'Amov')
            call SetUnitPathing(st.caster,false)
            call PauseUnit(st.caster,true)
            call SetUnitPosition(st.caster,GetRectCenterX(MapRectReturn(st.rectnumber)),GetRectCenterY(MapRectReturn(st.rectnumber)))
            
            //call SaveBoolean(Unithash,GetHandleId(fx.caster),0,false)
            
            //call SELECTEDBOSS(GetLocalPlayer(),SandBagUnit)
            
            set CheckUnit = st.caster
            call ForGroup(st.ul.super, function NoRemove)
            set CheckUnit = null
            
            call Boss4Start2(st)
            
            set Unit = null
            call t.destroy()
        endif
        
    endfunction
    
    function Boss4Start takes unit source returns nothing
        local tick t
        local MapStruct st
        local integer pid=GetPlayerId(GetOwningPlayer(source))
        
        set st = MapSt[GetMap(2)]
        
        if st.caster == null then
            call BJDebugMsg(GetUnitName(source))
            set t = tick.create(0)
            set st.rectnumber = GetMap(2)
            set st.caster = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e01I', GetRectCenterX(MapRectReturn2(st.rectnumber)),GetRectCenterY(MapRectReturn2(st.rectnumber)), 270)
            set st.ul = party.create()
            set st.pattern1 = 250
            call GroupAddUnit( st.ul.super, source )
            set t.data = st
            call t.start( 1.00 , true, function Function )
        else
            call BJDebugMsg("2")
            call GroupAddUnit( st.ul.super, source )
        endif
        
        call SetUnitPosition(source, GetRectCenterX(MapRectReturn2(st.rectnumber)),GetRectCenterY(MapRectReturn2(st.rectnumber)))

        if GetLocalPlayer() == Player(pid) then
            call SetCameraBoundsToRectForPlayerBJ( Player(pid), MapRectReturn(st.rectnumber) )
            call SetCameraPositionForPlayer( Player(pid), GetRectCenterX(MapRectReturn2(st.rectnumber)), GetRectCenterY(MapRectReturn2(st.rectnumber)))
            call DzFrameShow(BossTip, true)
        endif

        
    endfunction
    
    endlibrary
    
    