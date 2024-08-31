library Boss1 initializer init requires FX,DataUnit,UIBossHP,DamageEffect2,UIBossEnd,DataMap, UIBossEnd, BossAggro, Missile, UIV
    globals
        integer BossTip
        //8초
        private constant integer Pattern1Cool = 400
        private unit CheckUnit

        private constant real scale = 750
        private constant real distance = 500
        private integer groupCountUnits = 0
    endglobals
    
    private struct FxEffect
        unit caster
        integer rectnumber
        integer i
        MapStruct st
        private method OnStop takes nothing returns nothing
            set rectnumber = 0
            set st = 0
            set caster = null
        endmethod
        //! runtextmacro 연출()
    endstruct
    
    private function splashD2 takes nothing returns nothing
        if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
            call KnockbackInverse( GetEnumUnit(), splash.source, 500, 0.5)
            call SetUnitZVelo( GetEnumUnit(), 7.5)
        endif
    endfunction

    private function CutinFor takes nothing returns nothing
        local tick t = tick.getExpired()
        local MapStruct st = t.data
        
        set groupCountUnits = groupCountUnits + 1

        if PlayerVCount[GetPlayerId(GetOwningPlayer(GetEnumUnit()))] == 1 then
            set st.i = st.i + 1
            if st.i == 1 then
                set st.cut1 = DataUnitIndex(GetEnumUnit())
            elseif st.i == 2 then
                set st.cut2 = DataUnitIndex(GetEnumUnit())
            elseif st.i == 3 then
                set st.cut3 = DataUnitIndex(GetEnumUnit())
            elseif st.i == 4 then
                set st.cut4 = DataUnitIndex(GetEnumUnit())
            endif
        endif
    endfunction

    private function CutinBoom takes nothing returns nothing
        local tick t = tick.getExpired()
        local MapStruct st = t.data
        //딜 참가한인원 x3% 체퍼딜
        call CutInDeal(st.caster, st.i * 0.03)
        //행동불가 해제
        call UnitRemoveAbility(st.caster, 'A02F')
    endfunction

    private function Cutin takes nothing returns nothing
        local tick t = tick.getExpired()
        local MapStruct st = t.data

        set st.i = 0
        set groupCountUnits = 0
        call ForGroup(st.ul.super,function CutinFor)
        
        if st.i == groupCountUnits and st.i != 1 then

            if st.i == 4 then
                call ForGroup(st.ul.super,function VAction4)
                call DelayCreate(st.caster, 'e023', GetRandomReal(0,360), 2.5 )
                call DelayCreate(st.caster, 'e024', GetRandomReal(0,360), 2.5 )
                call DelayCreate(st.caster, 'e025', GetRandomReal(0,360), 2.5 )
                call t.start(2.5,false,function CutinBoom)
            elseif st.i == 3 then
                call ForGroup(st.ul.super,function VAction3)
                call DelayCreate(st.caster, 'e023', GetRandomReal(0,360), 2.5 )
                call DelayCreate(st.caster, 'e024', GetRandomReal(0,360), 2.5 )
                call DelayCreate(st.caster, 'e025', GetRandomReal(0,360), 2.5 )
                call t.start(2.5,false,function CutinBoom)
            elseif st.i == 2 then
                call ForGroup(st.ul.super,function VAction2)
                call DelayCreate(st.caster, 'e023', GetRandomReal(0,360), 2.5 )
                call DelayCreate(st.caster, 'e024', GetRandomReal(0,360), 2.5 )
                call DelayCreate(st.caster, 'e025', GetRandomReal(0,360), 2.5 )
                call t.start(2.5,false,function CutinBoom)
            endif

            //쓴사람 사운드 출력
            call ForGroup(st.ul.super,function VActionSound)
        elseif st.i != 0 then
            call DelayCreate(st.caster, 'e023', GetRandomReal(0,360), 2.5 )
            call DelayCreate(st.caster, 'e024', GetRandomReal(0,360), 2.5 )
            call DelayCreate(st.caster, 'e025', GetRandomReal(0,360), 2.5 )
            call t.start(2.5,false,function CutinBoom)
        else
            set st.cut1 = 0
            set st.cut2 = 0
            set st.cut3 = 0
            set st.cut4 = 0

            set st.i = 0
            call t.destroy()
        endif
    endfunction
    
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
                    //체력감소
                    call UnitDamageTarget(fx.caster,fx.caster,200000000,true,true,ATTACK_TYPE_CHAOS,DAMAGE_TYPE_UNIVERSAL,WEAPON_TYPE_WHOKNOWS)
                    set UnitHP[IndexUnit(fx.caster)] = UnitHP[IndexUnit(fx.caster)] - 30000000
    

                    call Sound3D(fx.caster,'A00U')
                    call AnimationStart(fx.caster,6)
                    call SetUnitVertexColorBJ( fx.caster, 100, 100, 100, 0 )

                    //call CutinLimit(fx.st.ul.super)

                    //보스행동불가
                    //call UnitAddAbility(fx.caster, 'A02F')

                    //컷인
                    //set t = tick.create(0)
                    //set t.data = fx.st
                    //call t.start(5, false, function Cutin)

                    call fx.Stop()
                //카운터를 못침
                elseif fx.i == 75 then
                    call UnitEffectTimeEX('e01J',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.90)
                    call UnitEffectTimeEX('e01J',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.90)
                    call UnitEffectTimeEX('e01J',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.90)
                    call UnitEffectTimeEX('e01J',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.90)
                    call UnitEffectTimeEX('e01J',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.90)

                    //call splash.range( splash.ENEMY, fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), scale, function splashD2 )
                    set i = 0
                    loop
                        call Missile(fx.caster, MakeMissile("Butterfly_Pink.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster),100,i*10,2.00,null), 1750, i*10, 3.0, 75, 1, 0)
                        call Missile(fx.caster, MakeMissile("Butterfly_Pink.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster),100,i*10,2.00,null), 1750, i*10, 3.5, 75, 1, 0)
                        call Missile(fx.caster, MakeMissile("Butterfly_Pink.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster),100,i*10,2.00,null), 1750, i*10, 4.0, 75, 1, 0)
                        call Missile(fx.caster, MakeMissile("Butterfly_Pink.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster),100,i*10,2.00,null), 1750, i*10, 4.5, 75, 1, 0)
                        call Missile(fx.caster, MakeMissile("Butterfly_Pink.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster),100,i*10,2.00,null), 1750, i*10, 5.0, 75, 1, 0)
                        call Missile(fx.caster, MakeMissile("Butterfly_Pink.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster),100,i*10,2.00,null), 1750, i*10, 5.5, 75, 1, 0)
                        call Missile(fx.caster, MakeMissile("Butterfly_Pink.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster),100,i*10,2.00,null), 1750, i*10, 6.0, 75, 1, 0)
                        call Missile(fx.caster, MakeMissile("Butterfly_Pink.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster),100,i*10,2.00,null), 1750, i*10, 6.5, 75, 1, 0)
                        set i = i + 1
                    exitwhen i == 36
                    endloop

                    //call AOE2(fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), 300, distance, 0.5,  100, 0, 1)

                    call UnitRemoveAbility(fx.caster,'A00V')
                    call SetUnitVertexColorBJ( fx.caster, 100, 100, 100, 0 )
                    //call AnimationStart2(fx.caster, 0, 0.6, 3.0)
                    call AnimationStart4(fx.caster, 7, 0.02)
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
    
    private function SuccessF takes nothing returns nothing
        local real r
        call SuccessStart(GetEnumUnit())
        call RewardStart(GetEnumUnit())
        //확정드랍
        call AddReward(GetOwningPlayer(GetEnumUnit()), "14"+";"+"0")
        call AddReward(GetOwningPlayer(GetEnumUnit()), "14"+";"+"0")
        call AddReward(GetOwningPlayer(GetEnumUnit()), "14"+";"+"0")
        call AddReward(GetOwningPlayer(GetEnumUnit()), "14"+";"+"0")
        //확률드랍
        call AddRandomReward(GetOwningPlayer(GetEnumUnit()), "12"+";"+"0", 5000)
        call AddRandomReward(GetOwningPlayer(GetEnumUnit()), "12"+";"+"0", 5000)
        call AddRandomReward(GetOwningPlayer(GetEnumUnit()), "12"+";"+"0", 5000)
        call AddRandomReward(GetOwningPlayer(GetEnumUnit()), "12"+";"+"0", 5000)
        call AddRandomReward(GetOwningPlayer(GetEnumUnit()), "12"+";"+"0", 5000)
    endfunction

    private function EffectFunction2 takes nothing returns nothing
        local tick t = tick.getExpired()
        local MapStruct st = t.data
        local FxEffect fx
        local AggroSystem s

        if UnitHP[IndexUnit(st.caster)] > 0 and IsUnitDeadVJ(st.caster) == false then
            //행동불가
            if GetUnitAbilityLevel(st.caster,'A02F') >= 1 then
            else
                set st.pattern1 = st.pattern1 - 1
                if st.pattern1 <= 0 then
                    set fx = FxEffect.Create()
                    set fx.caster = st.caster
                    set fx.i = 0
                    set fx.st = st
                    call AnimationStart(fx.caster, 5)
                    call fx.Start()
                    set st.pattern1 = Pattern1Cool
                endif
            endif
        //주금
        else
            call ForGroup(st.ul.super,function SuccessF)
            call st.ul.destroy()
            //그룹 보상
            call KillUnit(st.caster)
            set s = BossStruct[IndexUnit(st.caster)]
            call s.destroy()
            set st.caster = null
            call BossMapReset(st.rectnumber, 1)
            set st.rectnumber = 0
            call t.destroy()
        endif
        
    endfunction
    
    private function Boss1Start2 takes integer str returns nothing
        local tick t = tick.create(0) 
        local MapStruct st = str
        local FxEffect fx = FxEffect.Create()
        
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
            //set st.caster = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e01Q',GetRectCenterX(MapRectReturn(st.rectnumber)),GetRectCenterY(MapRectReturn(st.rectnumber)),270)
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
            set BossStruct[UnitIndex] = AggroSystem.create()
            
            //call SaveBoolean(Unithash,GetHandleId(st.caster),0,false)
            
            //call SELECTEDBOSS(GetLocalPlayer(),SandBagUnit)
            
            set CheckUnit = st.caster
            call ForGroup(st.ul.super, function NoRemove)
            set CheckUnit = null
            
            call Boss1Start2(st)
            
            set Unit = null
            call t.destroy()
        endif
        
    endfunction
    
    function Boss1Start takes unit source returns nothing
        local tick t
        local MapStruct st
        local integer pid = GetPlayerId(GetOwningPlayer(source))
        
        set st = MapSt[GetMap(1)]
        
        if st.caster == null then
            set t = tick.create(0)
            set st.rectnumber = GetMap(1)
            set st.caster = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e01I', GetRectCenterX(MapRectReturn2(st.rectnumber)),GetRectCenterY(MapRectReturn2(st.rectnumber)), 270)
            set st.ul = party.create()
            set st.pattern1 = 100
            call GroupAddUnit( st.ul.super, source )
            set t.data = st
            call t.start( 0.02 , true, function EffectFunction )
        else
            call GroupAddUnit( st.ul.super, source )
        endif
        
        if GetLocalPlayer() == Player(pid) then
            call SetCameraBoundsToRectForPlayerBJ( Player(pid), MapRectReturn(st.rectnumber) )
            call SetCameraPositionForPlayer( Player(pid), GetRectCenterX(MapRectReturn2(st.rectnumber)), GetRectCenterY(MapRectReturn2(st.rectnumber)))
            call DzFrameShow(BossTip, true)
        endif
        call SetUnitPosition(source, GetRectCenterX(MapRectReturn2(st.rectnumber)),GetRectCenterY(MapRectReturn2(st.rectnumber)))
        
    endfunction
    
    private function Main takes nothing returns nothing
        set BossTip=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "template", 0)
        call DzFrameSetPoint(BossTip, 0, DzGetGameUI(), 6, ( 318.00 / 1280.00 ), ( 700.00 / 1280.00 ))
        call DzFrameSetSize(BossTip, ( 388.00 / 1280.00 ), ( 100.00 / 1280.00 ))
        call DzFrameSetTexture(BossTip, "BossTip1.tga", 0)
        call DzFrameShow(BossTip, false)
    endfunction
            
    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer index
        
        call TriggerRegisterTimerEventSingle( t, 0.10 )
        call TriggerAddAction( t, function Main )
        set t = null
    endfunction
    endlibrary
    
    
    //체력바 보이게
    //파티모드??
    //패턴 체력비례, 시간비례, 랜덤패턴
    //어그로 (패턴 2~4개후 전환) 대상과의 각도가 일정각도 이상이면 대가리 전환
    //보스 체력바 플레이어마다 보이게 변경
    //유저부활
    
    