library Boss3 requires FX,DataUnit,UIBossHP,DamageEffect2,UIBossEnd,DataMap,Boss1
    globals
        //2분30초 7500
        //50 1초
        //test1500

        //이동 Distance최소거리
        private constant integer Pattern1Cool = 0
        private constant integer Pattern1Distance = 300
        //3장판 거리보다 멀면 사용안함
        private constant integer Pattern2Cool = 500
        private constant integer Pattern2RandomCool = 500
        private constant integer Pattern2Time = 100
        private constant integer Pattern2Distance = 1500
        //카운터 밀치기 40초
        private constant integer Pattern3Cool = 1500
        private constant integer Pattern3RandomCool = 500
        private constant integer Pattern3CounterTime = 125
        private constant integer Pattern3Distance = 600
        //얼음파편 100초 거리보다 멀면 사용안함
        private constant integer Pattern4Cool = 5000
        private constant integer Pattern4RandomCool = 500
        private constant integer Pattern4Distance = 2000
        //마력충전 거리안에 아무도 없을시 발동
        private constant integer Pattern5Cool = 5000
        private constant integer Pattern5RandomCool = 500
        private constant integer Pattern5Distance = 3000
        //마력포격 거리보다 멀면 사용안함
        private constant integer Pattern6Cool = 5000
        private constant integer Pattern6RandomCool = 500
        private constant integer Pattern6Distance = 2000
        //파이어볼 거리보다 멀면 사용안함
        private constant integer Pattern7Cool = 1000
        private constant integer Pattern7RandomCool = 500
        private constant integer Pattern7Distance = 1500

        private integer NoDieCheck
        private unit CheckUnit

        private constant real scale = 3000
        private constant real distance = 2000
    endglobals

    //3장판
    private struct FxEffect2
        unit caster
        unit dummy1
        unit dummy2
        unit dummy3
        integer i
        private method OnStop takes nothing returns nothing
            set caster = null
            set dummy1 = null
            set dummy2 = null
            set dummy3 = null
        endmethod
        //! runtextmacro 연출()
    endstruct
    
    private struct FxEffect2_Timer extends array
        private method OnAction takes FxEffect2 fx returns nothing
            local effect e
            local real r
            local integer i
            local tick t
            local MapStruct st
            set fx.i = fx.i + 1
            if fx.caster != null and IsUnitDeadVJ(fx.caster) == false then
                if fx.i == 1 then
                    set i = GetRandomInt(0,3)
                    set fx.dummy1 = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03K',GetWidgetX(fx.caster)+PolarX(500,GetUnitFacing(fx.caster)+(i*90)),GetWidgetY(fx.caster)+PolarY(500,GetUnitFacing(fx.caster)+(i*90)),270)
                    call AOE(fx.caster, GetWidgetX(fx.caster)+PolarX(500,GetUnitFacing(fx.caster)+(i*90)),GetWidgetY(fx.caster)+PolarY(500,GetUnitFacing(fx.caster)+(i*90)), 500, 2.0, 100, 0, 1, 2)
                    set fx.dummy2 = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03K',GetWidgetX(fx.caster)+PolarX(500,GetUnitFacing(fx.caster)+(i*90)+90),GetWidgetY(fx.caster)+PolarY(500,GetUnitFacing(fx.caster)+(i*90)+90),270)
                    call AOE(fx.caster, GetWidgetX(fx.caster)+PolarX(500,GetUnitFacing(fx.caster)+(i*90)+90),GetWidgetY(fx.caster)+PolarY(500,GetUnitFacing(fx.caster)+(i*90)+90), 500, 2.0, 100, 0, 1, 2)
                    set fx.dummy3 = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03K',GetWidgetX(fx.caster)+PolarX(500,GetUnitFacing(fx.caster)+(i*90)+180),GetWidgetY(fx.caster)+PolarY(500,GetUnitFacing(fx.caster)+(i*90)+180),270)
                    call AOE(fx.caster, GetWidgetX(fx.caster)+PolarX(500,GetUnitFacing(fx.caster)+(i*90)+180),GetWidgetY(fx.caster)+PolarY(500,GetUnitFacing(fx.caster)+(i*90)+180), 500, 2.0, 100, 0, 1, 2)
                elseif fx.i == Pattern2Time then
                    call UnitEffectTimeEX('e03H',GetWidgetX(fx.dummy1),GetWidgetY(fx.dummy1),GetRandomReal(0,360),1.20)
                    call UnitEffectTimeEX('e03I',GetWidgetX(fx.dummy1),GetWidgetY(fx.dummy1),GetRandomReal(0,360),1.20)
                    call UnitEffectTimeEX('e03J',GetWidgetX(fx.dummy1),GetWidgetY(fx.dummy1),GetRandomReal(0,360),1.20)

                    call UnitEffectTimeEX('e03H',GetWidgetX(fx.dummy2),GetWidgetY(fx.dummy2),GetRandomReal(0,360),1.20)
                    call UnitEffectTimeEX('e03I',GetWidgetX(fx.dummy2),GetWidgetY(fx.dummy2),GetRandomReal(0,360),1.20)
                    call UnitEffectTimeEX('e03J',GetWidgetX(fx.dummy2),GetWidgetY(fx.dummy2),GetRandomReal(0,360),1.20)

                    call UnitEffectTimeEX('e03H',GetWidgetX(fx.dummy3),GetWidgetY(fx.dummy3),GetRandomReal(0,360),1.20)
                    call UnitEffectTimeEX('e03I',GetWidgetX(fx.dummy3),GetWidgetY(fx.dummy3),GetRandomReal(0,360),1.20)
                    call UnitEffectTimeEX('e03J',GetWidgetX(fx.dummy3),GetWidgetY(fx.dummy3),GetRandomReal(0,360),1.20)

                    call KillUnit(fx.dummy1)
                    call KillUnit(fx.dummy2)
                    call KillUnit(fx.dummy3)

                    //대기상태로 전환
                    call AnimationStart4(fx.caster, 7, 0.02)
                    set Unitstate[IndexUnit(fx.caster)] = 0
                    call fx.Stop()
                endif
            //주금
            else
                call UnitRemoveAbility(fx.caster,'A00V')
                call SetUnitVertexColorBJ( fx.caster, 100, 100, 100, 0 )
                call fx.Stop()
            endif
        endmethod
        //! runtextmacro 연출효과_타이머("FxEffect2", "0.02", "true")
    endstruct
    
    //넉백 카운터
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
    
    private struct FxEffect_Timer extends array
        private method OnAction takes FxEffect fx returns nothing
            local effect e
            local real r
            local integer i
            local tick t
            local MapStruct st
            set fx.i = fx.i + 1
            if fx.caster != null and IsUnitDeadVJ(fx.caster) == false then
                if fx.i == 1 then
                    call SetUnitVertexColorBJ( fx.caster, 70, 70, 100, 0 )
                    call UnitEffectTimeEX('e00F',GetWidgetX(fx.caster),GetWidgetY(fx.caster),0,3)
                    call UnitEffectTimeEX('e00G',GetWidgetX(fx.caster),GetWidgetY(fx.caster),0,3)
                    call UnitEffectTimeEX('e01S',GetWidgetX(fx.caster),GetWidgetY(fx.caster),0,3)
                    call UnitAddAbility(fx.caster,'A00V')
                //카운터침
                elseif fx.i >= 1 and GetUnitAbilityLevel(fx.caster,'A00V') == 0 then
                    call Sound3D(fx.caster,'A00U')
                    call AnimationStart(fx.caster,6)
                    call SetUnitVertexColorBJ( fx.caster, 100, 100, 100, 0 )
                    call fx.Stop()
                //카운터를 못침
                elseif fx.i == Pattern3CounterTime then
                    call UnitEffectTimeEX('e01J',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.90)
                    call UnitEffectTimeEX('e01J',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.90)
                    call UnitEffectTimeEX('e01J',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.90)
                    call UnitEffectTimeEX('e01J',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.90)
                    call UnitEffectTimeEX('e01J',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.90)

                    call AOE(fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), distance, 0.5,  100, 0, 1, 2)

                    call UnitRemoveAbility(fx.caster,'A00V')
                    call SetUnitVertexColorBJ( fx.caster, 100, 100, 100, 0 )
                    call AnimationStart4(fx.caster, 7, 0.02)
                    set Unitstate[IndexUnit(fx.caster)] = 0
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
        //확률드랍
        call AddRandomReward(GetOwningPlayer(GetEnumUnit()), "12"+";"+"0", 100)
    endfunction
    
    private function Function2 takes nothing returns nothing
        local tick t = tick.getExpired()
        local MapStruct st = t.data
        local FxEffect fx
        local FxEffect2 fx2
        local integer index
        
        set NoDieCheck = 0
        call ForGroup(st.ul.super,function NoDie)
        
        //플레이어가 다죽음
        if NoDieCheck == 0 then
            call KillUnit(st.caster)
            call RemoveUnit(st.caster)
            call ForGroup(st.ul.super,function AllDie)
            set st.caster = null
            call MapReset(st.rectnumber,2)
            set st.rectnumber = 0
            call t.destroy()
        else
            //보스가 생존
            if UnitHP[IndexUnit(st.caster)] > 0 and IsUnitDeadVJ(st.caster) == false then
                
                if splash.range( splash.ENEMY, st.caster, GetWidgetX(st.caster), GetWidgetY(st.caster), scale, function SplashNothing ) then
                endif
                //일반상태
                if Unitstate[IndexUnit(st.caster)] == 0 then
                    set st.pattern3 = st.pattern3 - 1
                    set st.pattern2 = st.pattern2 - 1
                        
                    //카운터
                    if st.pattern3 <= 0 then
                        set fx = FxEffect.Create()
                        set fx.caster = st.caster
                        set fx.i = 0
                        call AnimationStart(fx.caster, 5)
                        call fx.Start()
                        set Unitstate[IndexUnit(fx.caster)] = 1
                        set st.pattern3 = Pattern3Cool + GetRandomInt(0,Pattern3RandomCool)
                    //3장판
                    elseif st.pattern2 <= 0 then
                        set fx2 = FxEffect2.Create()
                        set fx2.caster = st.caster
                        set fx2.i = 0
                        call AnimationStart(fx2.caster, 3)
                        call fx2.Start()
                        set Unitstate[IndexUnit(fx2.caster)] = 1
                        set st.pattern2 = Pattern2Cool + GetRandomInt(0,Pattern2RandomCool)
                    elseif 
                    endif
                //스킬사용중
                elseif Unitstate[IndexUnit(st.caster)] == 1 then
                //무력화
                elseif Unitstate[IndexUnit(st.caster)] == 2 then
                endif
            //주금
            else
                //그룹 보상
                call ForGroup(st.ul.super,function SuccessF)
                call st.ul.destroy()
                call KillUnit(st.caster)
                set s = BossStruct[IndexUnit(st.caster)]
                call s.destroy()
                set st.caster = null
                call BossMapReset(st.rectnumber, 2)
                set st.rectnumber = 0
                call t.destroy()
            endif
        endif
    endfunction
    
    private function Boss1Start3 takes MapStruct str returns nothing
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
            //정비소제거
            call KillUnit(st.caster)
            //보스생성
            set st.caster = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'h00L',GetRectCenterX(MapRectReturn(st.rectnumber)),GetRectCenterY(MapRectReturn(st.rectnumber)),270)
            set Dataindex = DataUnitIndex(st.caster)
            //보스설정
            set UnitIndex = IndexUnit(st.caster)
            set UnitHPMAX[UnitIndex] = UnitSetHP[Dataindex]
            set UnitHP[UnitIndex] = UnitSetHP[Dataindex]
            set UnitSDMAX[UnitIndex] = UnitSetSD[Dataindex]
            set UnitSD[UnitIndex] = UnitSetSD[Dataindex]
            set UnitArm[UnitIndex] = UnitSetArm[Dataindex]
            set UnitCasting[UnitIndex] = false
            set Unitstate[UnitIndex] = 0 
            
            //이동능력제거
            call UnitRemoveAbility(st.caster,'Amov')
            call SetUnitPathing(st.caster,false)
            call PauseUnit(st.caster,true)
            call SetUnitPosition(st.caster,GetRectCenterX(MapRectReturn(st.rectnumber)),GetRectCenterY(MapRectReturn(st.rectnumber)))
            //어그로시스템설정
            set BossStruct[UnitIndex] = AggroSystem.create()
            
            //call SaveBoolean(Unithash,GetHandleId(fx.caster),0,false)
            
            //call SELECTEDBOSS(GetLocalPlayer(),SandBagUnit)
            
            set CheckUnit = st.caster
            call ForGroup(st.ul.super, function NoRemove)
            set CheckUnit = null
            
            call Boss1Start3(st)
            
            set Unit = null
            call t.destroy()
        endif
        
    endfunction
    
    function Boss3Start takes unit source returns nothing
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
            set st.pattern1 = Pattern1Cool
            set st.pattern2 = Pattern2Cool
            set st.pattern3 = Pattern3Cool
            call GroupAddUnit( st.ul.super, source )
            set t.data = st
            call t.start( 1.00 , true, function Function )
        else
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
    
    