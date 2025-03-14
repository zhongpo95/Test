library Boss2 requires FX,DataUnit,UIBossHP,DamageEffect2,UIBossEnd,DataMap,Boss1
    globals
        //무력화시간
        private constant integer Pattern2Time = 500
        private integer NoDieCheck
        private unit CheckUnit

        private constant real scale = 3000
        private constant real distance = 2000
    endglobals
    
    private struct FxEffect
        unit caster
        integer i
        private method OnStop takes nothing returns nothing
            set caster = null
        endmethod
        //! runtextmacro 연출()
    endstruct
    
    private function splashD2 takes nothing returns nothing
        if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
            call KnockbackInverse( GetEnumUnit(), splash.source, 2000, 2.0)
            call SetUnitZVelo( GetEnumUnit(), 30)
            call BossDeal( splash.source, GetEnumUnit(), 1000000 , false)
        endif
    endfunction
    
    private struct FxEffect_Timer extends array
        private method OnAction takes FxEffect fx returns nothing
            local effect e
            local real r
            local integer index = IndexUnit(fx.caster)
            local integer frame = 0
            set fx.i = fx.i + 1
            
            if fx.caster != null and IsUnitDeadVJ(fx.caster) == false then
                if fx.i == 1 then
                    //call UnitEffectTimeEX('e00F',GetWidgetX(fx.caster),GetWidgetY(fx.caster),0,3)
                    //call UnitEffectTimeEX('e00G',GetWidgetX(fx.caster),GetWidgetY(fx.caster),0,3)
                    //call UnitEffectTimeEX('e01S',GetWidgetX(fx.caster),GetWidgetY(fx.caster),0,3)
                elseif fx.i == 100 then
                    call AnimationStart(fx.caster, 8)
                //무력화 성공
                elseif fx.i >= 1 and UnitCasting[index] == false then
                    //체력감소
                    set UnitHP[IndexUnit(fx.caster)] = UnitHP[IndexUnit(fx.caster)] - 100000000

                    call Sound3D(fx.caster,'A00U')
                    call AnimationStart(fx.caster,6)

                    call fx.Stop()
                //무력화를 못함
                elseif fx.i == Pattern2Time then
                    call UnitEffectTimeEX('e01J',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.90)
                    call UnitEffectTimeEX('e01J',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.90)
                    call UnitEffectTimeEX('e01J',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.90)
                    call UnitEffectTimeEX('e01J',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.90)
                    call UnitEffectTimeEX('e01J',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.90)
                    call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale, function splashD2 )
                    call AnimationStart2(fx.caster, 0, 0.6, 3.0)
                    call AnimationStart4(fx.caster, 7, 0.6)
                    set UnitCastingSD[index] = 0
                    set UnitCastingSDMAX[index] = 0
                    set UnitCasting[index] = false
                    call KillUnit(UnitCastingDummy[index])
                    set UnitCastingDummy[index] = null
                    
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
        call AddReward(GetOwningPlayer(GetEnumUnit()), "ID59"+";"+"0")
        call AddReward(GetOwningPlayer(GetEnumUnit()), "ID59"+";"+"0")
        call AddReward(GetOwningPlayer(GetEnumUnit()), "ID59"+";"+"0")
        call AddReward(GetOwningPlayer(GetEnumUnit()), "ID59"+";"+"0")
        //확률드랍
        call AddRandomReward(GetOwningPlayer(GetEnumUnit()), "ID12"+";"+"0", 100)
        call AddRandomReward(GetOwningPlayer(GetEnumUnit()), "ID12"+";"+"0", 100)
        call AddRandomReward(GetOwningPlayer(GetEnumUnit()), "ID12"+";"+"0", 100)
        call AddRandomReward(GetOwningPlayer(GetEnumUnit()), "ID12"+";"+"0", 100)
        call AddRandomReward(GetOwningPlayer(GetEnumUnit()), "ID12"+";"+"0", 100)
        call AddRandomReward(GetOwningPlayer(GetEnumUnit()), "ID12"+";"+"0", 100)
        call AddRandomReward(GetOwningPlayer(GetEnumUnit()), "ID12"+";"+"0", 100)
        call AddRandomReward(GetOwningPlayer(GetEnumUnit()), "ID12"+";"+"0", 100)
        call AddRandomReward(GetOwningPlayer(GetEnumUnit()), "ID12"+";"+"0", 100)
        call AddRandomReward(GetOwningPlayer(GetEnumUnit()), "ID12"+";"+"0", 100)
    endfunction
    
    private function EffectFunction2 takes nothing returns nothing
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
                if st.pattern1 == 0 then
                    set fx = FxEffect.Create()
                    set fx.caster = st.caster
                    set fx.i = 0
                    call AnimationStart(fx.caster, 4)
                    call fx.Start()
                    set st.pattern1 = 750
                    
                    set index = IndexUnit(st.caster)
                    call Sound3D(fx.caster,'A026')
                    set UnitCasting[index] = true
                    set UnitCastingSDMAX[index] = 300
                    set UnitCastingSD[index] = UnitCastingSDMAX[index]
                    set UnitCastingDummy[index] = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'e01H', GetWidgetX(fx.caster), GetWidgetY(fx.caster), 270 )
                    call SetUnitAnimationByIndex(UnitCastingDummy[index], (100-1) )
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
    
    private function Boss1Start2 takes MapStruct str returns nothing
        local tick t = tick.create(0) 
        local MapStruct st = str
        
        set t.data = st
        
        set MapRectCheck[st.rectnumber] = false
        
        call t.start( 0.02 , true, function EffectFunction2 ) 
    endfunction
    
    
    private function NoRemove takes nothing returns nothing
        if GetLocalPlayer() == GetOwningPlayer(GetEnumUnit()) then
            call PlayersBossBarShow(GetLocalPlayer(),true)
            call DzFrameShow(BossTip, false)
        endif
        call BOSSHPSTART(CheckUnit, GetPlayerId(GetOwningPlayer(GetEnumUnit())))
    endfunction
    
    private function EffectFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        local MapStruct st = t.data
        local integer Dataindex
        local integer UnitIndex
        local unit Unit
        
        if splash.range( splash.ALLY, st.caster, GetWidgetX(st.caster), GetWidgetY(st.caster), 500, function SplashNothing ) == 0 then
            //컷신?
            call KillUnit(st.caster)
            set st.caster = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'h008',GetRectCenterX(MapRectReturn(st.rectnumber)),GetRectCenterY(MapRectReturn(st.rectnumber)),270)
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
            
            call Boss1Start2(st)
            
            set Unit = null
            call t.destroy()
        endif
        
    endfunction
    
    function Boss2Start takes unit source returns nothing
        local tick t
        local MapStruct st
        local integer pid = GetPlayerId(GetOwningPlayer(source))
        
        set st = MapSt[GetMap(2)]
        
        if st.caster == null then
            set t = tick.create(0)
            set st.rectnumber = GetMap(2)
            set st.caster = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e01I', GetRectCenterX(MapRectReturn2(st.rectnumber)),GetRectCenterY(MapRectReturn2(st.rectnumber)), 270)
            set st.ul = party.create()
            set st.pattern1 = 250
            call GroupAddUnit( st.ul.super, source )
            set t.data = st
            call t.start( 0.02 , true, function EffectFunction )
        else
            call GroupAddUnit( st.ul.super, source )
        endif
        
        if GetLocalPlayer() == Player(pid) then
            //카메라
            call SetCameraBoundsToRectForPlayerBJ( Player(pid), MapRectReturn(st.rectnumber) )
            call SetCameraPositionForPlayer( Player(pid), GetRectCenterX(MapRectReturn2(st.rectnumber)), GetRectCenterY(MapRectReturn2(st.rectnumber)))
            call DzFrameShow(BossTip, true)
        endif
        call SetUnitPosition(source, GetRectCenterX(MapRectReturn2(st.rectnumber)),GetRectCenterY(MapRectReturn2(st.rectnumber)))
        
    endfunction
    
    endlibrary
    
    
    //체력바 보이게123
    //파티모드??
    //패턴 체력비례, 시간비례, 랜덤패턴
    //어그로 (패턴 2~4개후 전환) 대상과의 각도가 일정각도 이상이면 대가리 전환
    //보스 체력바 플레이어마다 보이게 변경123
    //유저부활123
    
    