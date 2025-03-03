library Boss3 requires FX,DataUnit,UIBossHP,DamageEffect2,UIBossEnd,DataMap,Boss1,PointToPolygon
    globals
        //2분30초 7500
        //50 1초
        //test1500

        //이동 Distance멈추는거리 Distance2이동최소거리
        private constant integer Pattern1Cool = 0
        private constant integer Pattern1Distance = 500
        private constant integer Pattern1Distance2 = 750
        //3장판 거리보다 멀면 사용안함
        private constant integer Pattern2Cool = 500
        private constant integer Pattern2RandomCool = 500
        private constant integer Pattern2Time = 100
        private constant integer Pattern2Distance = 1500
        //카운터 밀치기 30~40초
        private constant integer Pattern3Cool = 200 //1500
        private constant integer Pattern3RandomCool = 500
        private constant integer Pattern3CounterTime = 125
        private constant integer Pattern3Distance = 600
        //얼음파편 30~35초 거리보다 멀면 사용안함
        private constant integer Pattern4Cool = 1500 //1500
        private constant integer Pattern4RandomCool = 250
        private constant integer Pattern4Time = 150
        private constant integer Pattern4Time2 = 175
        private constant integer Pattern4Distance = 2000
        private constant integer Pattern4Range = 75
        private constant integer Pattern4DMG = 20
        private constant real Pattern4Speed = 1.0
        //마력충전 거리안에 아무도 없을시 발동
        private constant integer Pattern5Cool = 5000
        private constant integer Pattern5RandomCool = 500
        private constant integer Pattern5Distance = 3000
        //마력포격 거리보다 멀면 사용안함
        private constant integer Pattern6Cool = 50
        private constant integer Pattern6RandomCool = 150
        private constant integer Pattern6Time = 125
        private constant integer Pattern6Time2 = 100
        private constant integer Pattern6Distance = 2000
        //파이어볼 거리보다 멀면 사용안함
        private constant integer Pattern7Cool = 1000
        private constant integer Pattern7RandomCool = 500
        private constant integer Pattern7Distance = 1500
        //지뢰마법,지뢰마법2 거리보다 멀면 사용안함
        private constant integer Pattern8Cool = 1000
        private constant integer Pattern8RandomCool = 500
        private constant integer Pattern8Distance = 2000

        private integer NoDieCheck
        private unit CheckUnit

        private constant real scale = 3000
        private constant real distance = 2000
    endglobals

    private function NoDie takes nothing returns nothing
        set NoDieCheck = NoDieCheck + 1
        if IsUnitDeadVJ(GetEnumUnit()) then
            set NoDieCheck = NoDieCheck - 1
        endif
    endfunction


    //마력 포격
    private struct FxEffect4
        unit caster
        unit array dummy[5]
        unit array targetUnit[5]
        unit array effectdummy[5]
        integer i
        integer fake
        MapStruct st
        private method OnStop takes nothing returns nothing
            set caster = null
            set dummy[0] = null
            set dummy[1] = null
            set dummy[2] = null
            set dummy[3] = null
            set dummy[4] = null
            set targetUnit[0] = null
            set targetUnit[1] = null
            set targetUnit[2] = null
            set targetUnit[3] = null
            set targetUnit[4] = null
            set effectdummy[0] = null
            set effectdummy[1] = null
            set effectdummy[2] = null
            set effectdummy[3] = null
            set effectdummy[4] = null
            set i = 0
            set fake = 0
            set st = 0
        endmethod
        //! runtextmacro 연출()
    endstruct
    
    private function splashF takes nothing returns nothing
        local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
        local polygon p = polygon.create()
        local real ux
        local real uy
        local real x
        local real y
        local real r

        set r = GetUnitFacing(splash.source)
        set ux = GetWidgetX(splash.source)
        set uy = GetWidgetY(splash.source)

        set x = ux+PolarX(200,r-90)
        set y = uy+PolarY(200,r-90)
        call p.AddPoint(x, y)

        set x = ux+PolarX(200,r+90)
        set y = uy+PolarY(200,r+90)
        call p.AddPoint(x, y)

        set x = ux+PolarX(2000,r)+PolarX(200,r+90)
        set y = uy+PolarY(2000,r)+PolarY(200,r+90)
        call p.AddPoint(x, y)

        set x = ux+PolarX(2000,r)+PolarX(200,r-90)
        set y = uy+PolarY(2000,r)+PolarY(200,r-90)
        call p.AddPoint(x, y)

        if p.IsPointInside(GetWidgetX(GetEnumUnit()), GetWidgetY(GetEnumUnit())) then
            call Knockback( GetEnumUnit(), r, 200, 0.20)
            call CustomStun.Stun2( GetEnumUnit(), 0.20)
            call BossDeal( splash.source, GetEnumUnit(), 50 , false)
        endif
        call p.destroy()
    endfunction

    private function splashF2 takes nothing returns nothing
        local integer pid = GetPlayerId(GetOwningPlayer(splash.source))
        local polygon p = polygon.create()
        local polygon p2 = polygon.create()
        local real ux
        local real uy
        local real ux2
        local real uy2
        local real x
        local real y
        local real r
        local integer i = 0
        
        set ux = GetWidgetX(splash.source)
        set uy = GetWidgetY(splash.source)
        set r = GetUnitFacing(splash.source)

        set ux2 = ux + PolarX(800,r-90)
        set uy2 = uy + PolarY(800,r-90)

        set x = ux2+PolarX(200,r-90)
        set y = uy2+PolarY(200,r-90)
        call p.AddPoint(x, y)

        set x = ux2+PolarX(600,r+90)
        set y = uy2+PolarY(600,r+90)
        call p.AddPoint(x, y)

        set x = ux2+PolarX(2000,r)+PolarX(600,r+90)
        set y = uy2+PolarY(2000,r)+PolarY(600,r+90)
        call p.AddPoint(x, y)

        set x = ux2+PolarX(2000,r)+PolarX(200,r-90)
        set y = uy2+PolarY(2000,r)+PolarY(200,r-90)
        call p.AddPoint(x, y)

        if p.IsPointInside(GetWidgetX(GetEnumUnit()), GetWidgetY(GetEnumUnit())) then
            set i = i + 1
        endif

        set ux2 = ux+PolarX(800,r+90)
        set uy2 = uy+PolarY(800,r+90)

        set x = ux2+PolarX(600,r-90)
        set y = uy2+PolarY(600,r-90)
        call p2.AddPoint(x, y)

        set x = ux2+PolarX(200,r+90)
        set y = uy2+PolarY(200,r+90)
        call p2.AddPoint(x, y)

        set x = ux2+PolarX(2000,r)+PolarX(200,r+90)
        set y = uy2+PolarY(2000,r)+PolarY(200,r+90)
        call p2.AddPoint(x, y)

        set x = ux2+PolarX(2000,r)+PolarX(600,r-90)
        set y = uy2+PolarY(2000,r)+PolarY(600,r-90)
        call p2.AddPoint(x, y)

        if p2.IsPointInside(GetWidgetX(GetEnumUnit()), GetWidgetY(GetEnumUnit())) then
            set i = i + 1
        endif

        if i > 0 then
            call Knockback( GetEnumUnit(), r, 200, 0.20)
            call CustomStun.Stun2( GetEnumUnit(), 0.2)
            call BossDeal( splash.source, GetEnumUnit(), 50 , false)
        endif
        call p.destroy()
        call p2.destroy()
    endfunction

    private struct FxEffect4_Timer extends array
        private method OnAction takes FxEffect4 fx returns nothing
            local effect e
            local real r
            local real x
            local real y
            local integer i
            local tick t
            local MapStruct st = fx.st

            set fx.i = fx.i + 1
            if fx.caster != null and IsUnitDeadVJ(fx.caster) == false then
                if fx.i == 1 then
                    set r = GetUnitFacing(fx.caster)
                    set x = GetWidgetX(fx.caster)+PolarX(-500,r)
                    set y = GetWidgetY(fx.caster)+PolarY(-500,r)
                    set fx.fake = GetRandomInt(0,1)
                    if fx.fake == 1 then
                        set fx.dummy[0] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03N',x,y,r)
                        set fx.dummy[1] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03O',x+PolarX(400,r-90),y+PolarY(400,r-90),r)
                        set fx.dummy[2] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03O',x+PolarX(800,r-90),y+PolarY(800,r-90),r)
                        set fx.dummy[3] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03O',x+PolarX(400,r+90),y+PolarY(400,r+90),r)
                        set fx.dummy[4] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03O',x+PolarX(800,r+90),y+PolarY(800,r+90),r)
                    else
                        set fx.dummy[0] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03O',x,y,r)
                        set fx.dummy[1] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03N',x+PolarX(400,r-90),y+PolarY(400,r-90),r)
                        set fx.dummy[2] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03N',x+PolarX(800,r-90),y+PolarY(800,r-90),r)
                        set fx.dummy[3] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03N',x+PolarX(400,r+90),y+PolarY(400,r+90),r)
                        set fx.dummy[4] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03N',x+PolarX(800,r+90),y+PolarY(800,r+90),r)
                    endif
                //발사 및 종료
                elseif fx.i == Pattern6Time then
                    set r = GetUnitFacing(fx.dummy[0])
                    if fx.fake == 1 then
                        call UnitApplyTimedLife(CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03P',GetWidgetX(fx.dummy[1])+PolarX(-128,r),GetWidgetY(fx.dummy[1])+PolarY(-128,r),r), 'BHwe', 1.5)
                        call UnitApplyTimedLife(CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03P',GetWidgetX(fx.dummy[2])+PolarX(-128,r),GetWidgetY(fx.dummy[2])+PolarY(-128,r),r), 'BHwe', 1.5)
                        call UnitApplyTimedLife(CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03P',GetWidgetX(fx.dummy[3])+PolarX(-128,r),GetWidgetY(fx.dummy[3])+PolarY(-128,r),r), 'BHwe', 1.5)
                        call UnitApplyTimedLife(CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03P',GetWidgetX(fx.dummy[4])+PolarX(-128,r),GetWidgetY(fx.dummy[4])+PolarY(-128,r),r), 'BHwe', 1.5)
                        call splash.range( splash.ENEMY, fx.dummy[0], GetWidgetX(fx.caster), GetWidgetY(fx.caster), 5000, function splashF2 )
                    else
                        call UnitApplyTimedLife(CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03P',GetWidgetX(fx.dummy[0])+PolarX(-128,r),GetWidgetY(fx.dummy[0])+PolarY(-128,r),r), 'BHwe', 1.5)
                        call splash.range( splash.ENEMY, fx.dummy[0], GetWidgetX(fx.caster), GetWidgetY(fx.caster), 5000, function splashF )
                    endif
                    call UnitApplyTimedLife(fx.dummy[0], 'BHwe', 1.5)
                    call UnitApplyTimedLife(fx.dummy[1], 'BHwe', 1.5)
                    call UnitApplyTimedLife(fx.dummy[2], 'BHwe', 1.5)
                    call UnitApplyTimedLife(fx.dummy[3], 'BHwe', 1.5)
                    call UnitApplyTimedLife(fx.dummy[4], 'BHwe', 1.5)
                elseif fx.i > Pattern6Time and fx.i < Pattern6Time + Pattern6Time2 then
                    set i = fx.i-Pattern6Time
                    if ModuloInteger(i,15) == 0 then 
                        if fx.fake == 1 then
                            call splash.range( splash.ENEMY, fx.dummy[0], GetWidgetX(fx.caster), GetWidgetY(fx.caster), 5000, function splashF2 )
                        else
                            call splash.range( splash.ENEMY, fx.dummy[0], GetWidgetX(fx.caster), GetWidgetY(fx.caster), 5000, function splashF )
                        endif
                    endif
                elseif fx.i == Pattern6Time + Pattern6Time2 then
                    call BJDebugMsg("전환")
                    //대기상태로 전환
                    call AnimationStart4(fx.caster, 7, 0.02)
                    set Unitstate[IndexUnit(fx.caster)] = 4
                    set st.j = StandTime
                    call BJDebugMsg("전환2")
                    call fx.Stop()
                    call BJDebugMsg("전환3")
                endif
            //주금
            else
                call UnitRemoveAbility(fx.caster,'A00V')
                call fx.Stop()
            endif
        endmethod
        //! runtextmacro 연출효과_타이머("FxEffect4", "0.02", "true")
    endstruct

    //이동
    private struct FxEffect1
        unit caster
        unit dummy
        integer i
        AggroSystem s
        private method OnStop takes nothing returns nothing
            set caster = null
            set dummy = null
            set i = 0
            set s = 0
        endmethod
        //! runtextmacro 연출()
    endstruct
    
    private struct FxEffect1_Timer extends array
        private method OnAction takes FxEffect1 fx returns nothing
            local effect e
            local real r
            local real ang
            local integer i
            local tick t
            set fx.i = fx.i + 1
            if fx.caster != null and IsUnitDeadVJ(fx.caster) == false then
                set r = DistanceWBW( fx.caster, MainUnit[fx.s.NowAggro])
                if Unitstate[IndexUnit(fx.caster)] == 3 then
                    //거리로 인한 종료
                    if r <= Pattern1Distance then
                        call BJDebugMsg("정지")
                        call AnimationStart4(fx.caster, 7, 0.02)
                        set Unitstate[IndexUnit(fx.caster)] = 0
                        call fx.Stop()
                    else
                        set ang = AngleWBW(fx.caster,MainUnit[fx.s.NowAggro])
                        call SetUnitFacing(fx.caster,ang)
                        call EXSetUnitFacing(fx.caster,ang)
                        call SetUnitPosition(fx.caster, GetWidgetX(fx.caster)+PolarX(8, ang), GetWidgetY(fx.caster)+PolarY(8, ang))
                    endif
                //이동 강제 종료
                elseif Unitstate[IndexUnit(fx.caster)] != 3 then
                    call BJDebugMsg("정지")
                    call fx.Stop()
                //거리로 인한 종료
                elseif r <= Pattern1Distance then
                    call BJDebugMsg("정지")
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
        //! runtextmacro 연출효과_타이머("FxEffect1", "0.02", "true")
    endstruct

    //얼음파편
    private struct FxEffect3
        unit caster
        unit array dummy[7]
        unit array targetUnit[7]
        unit array effectdummy[7]
        real array lockangle[7]
        integer i
        integer targetcount
        MapStruct st
        private method OnStop takes nothing returns nothing
            set caster = null
            set dummy[0] = null
            set dummy[1] = null
            set dummy[2] = null
            set dummy[3] = null
            set dummy[4] = null
            set dummy[5] = null
            set dummy[6] = null
            set targetUnit[0] = null
            set targetUnit[1] = null
            set targetUnit[2] = null
            set targetUnit[3] = null
            set targetUnit[4] = null
            set targetUnit[5] = null
            set targetUnit[6] = null
            set effectdummy[0] = null
            set effectdummy[1] = null
            set effectdummy[2] = null
            set effectdummy[3] = null
            set effectdummy[4] = null
            set effectdummy[5] = null
            set effectdummy[6] = null
            set i = 0
            set targetcount = 0
            set st = 0
        endmethod
        //! runtextmacro 연출()
    endstruct
    
    private struct FxEffect3_Timer extends array
        private method OnAction takes FxEffect3 fx returns nothing
            local effect e
            local real r
            local integer i
            local tick t
            local MapStruct st = fx.st

            set fx.i = fx.i + 1
            if fx.caster != null and IsUnitDeadVJ(fx.caster) == false then
                if fx.i == 1 then
                    set NoDieCheck = 0
                    call ForGroup(st.ul.super,function NoDie)
                    set fx.targetcount = NoDieCheck - 1
                    //call Missile(fx.caster, MakeMissile("Butterfly_Pink.mdl",GetWidgetX(fx.caster),GetWidgetY(fx.caster),100,i*10,2.00,null), 1750, i*10, 3.0, 75, 1, 0)

                    set fx.dummy[0] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03L',GetWidgetX(fx.caster)+PolarX(GetRandomReal(300,750),GetRandomReal(0,360)),GetWidgetY(fx.caster)+PolarY(GetRandomReal(300,750),GetRandomReal(0,360)),270)
                    set fx.targetUnit[0] = ClosestUnit(fx.dummy[0], 3000)
                    set fx.effectdummy[0] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03M',GetWidgetX(fx.dummy[0]),GetWidgetY(fx.dummy[0]),270)
                    set fx.dummy[1] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03L',GetWidgetX(fx.caster)+PolarX(GetRandomReal(300,750),GetRandomReal(0,360)),GetWidgetY(fx.caster)+PolarY(GetRandomReal(300,750),GetRandomReal(0,360)),270)
                    set fx.targetUnit[1] = ClosestUnit(fx.dummy[1], 3000)
                    set fx.effectdummy[1] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03M',GetWidgetX(fx.dummy[1]),GetWidgetY(fx.dummy[1]),270)
                    set fx.dummy[2] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03L',GetWidgetX(fx.caster)+PolarX(GetRandomReal(300,750),GetRandomReal(0,360)),GetWidgetY(fx.caster)+PolarY(GetRandomReal(300,750),GetRandomReal(0,360)),270)
                    set fx.targetUnit[2] = ClosestUnit(fx.dummy[2], 3000)
                    set fx.effectdummy[2] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03M',GetWidgetX(fx.dummy[2]),GetWidgetY(fx.dummy[2]),270)
                    set fx.dummy[3] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03L',GetWidgetX(fx.caster)+PolarX(GetRandomReal(300,750),GetRandomReal(0,360)),GetWidgetY(fx.caster)+PolarY(GetRandomReal(300,750),GetRandomReal(0,360)),270)
                    set fx.targetUnit[3] = ClosestUnit(fx.dummy[3], 3000)
                    set fx.effectdummy[3] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03M',GetWidgetX(fx.dummy[3]),GetWidgetY(fx.dummy[3]),270)
                    if fx.targetcount == 1 then
                        set fx.dummy[4] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03L',GetWidgetX(fx.caster)+PolarX(GetRandomReal(300,750),GetRandomReal(0,360)),GetWidgetY(fx.caster)+PolarY(GetRandomReal(300,750),GetRandomReal(0,360)),270)
                        set fx.targetUnit[4] = ClosestUnit(fx.dummy[4], 3000)
                        set fx.effectdummy[4] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03M',GetWidgetX(fx.dummy[4]),GetWidgetY(fx.dummy[4]),270)
                    endif
                    if fx.targetcount == 2 then
                        set fx.dummy[5] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03L',GetWidgetX(fx.caster)+PolarX(GetRandomReal(300,750),GetRandomReal(0,360)),GetWidgetY(fx.caster)+PolarY(GetRandomReal(300,750),GetRandomReal(0,360)),270)
                        set fx.targetUnit[5] = ClosestUnit(fx.dummy[5], 3000)
                        set fx.effectdummy[5] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03M',GetWidgetX(fx.dummy[5]),GetWidgetY(fx.dummy[5]),270)
                    endif
                    if fx.targetcount == 3 then
                        set fx.dummy[6] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03L',GetWidgetX(fx.caster)+PolarX(GetRandomReal(300,750),GetRandomReal(0,360)),GetWidgetY(fx.caster)+PolarY(GetRandomReal(300,750),GetRandomReal(0,360)),270)
                        set fx.targetUnit[6] = ClosestUnit(fx.dummy[6], 3000)
                        set fx.effectdummy[6] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03M',GetWidgetX(fx.dummy[6]),GetWidgetY(fx.dummy[6]),270)
                    endif

                //방향회전
                elseif fx.i <= Pattern4Time then
                    set fx.lockangle[0] = AngleWBW(fx.dummy[0], fx.targetUnit[0])
                    call SetUnitFacing(fx.dummy[0],fx.lockangle[0])
                    call EXSetUnitFacing(fx.dummy[0], fx.lockangle[0])
                    call SetUnitFacing(fx.effectdummy[0],fx.lockangle[0])
                    call EXSetUnitFacing(fx.effectdummy[0], fx.lockangle[0])
                    set fx.lockangle[1] = AngleWBW(fx.dummy[1], fx.targetUnit[1])
                    call SetUnitFacing(fx.dummy[1],fx.lockangle[1])
                    call EXSetUnitFacing(fx.dummy[1], fx.lockangle[1])
                    call SetUnitFacing(fx.effectdummy[1],fx.lockangle[1])
                    call EXSetUnitFacing(fx.effectdummy[1], fx.lockangle[1])
                    set fx.lockangle[2] = AngleWBW(fx.dummy[2], fx.targetUnit[2])
                    call SetUnitFacing(fx.dummy[2],fx.lockangle[2])
                    call EXSetUnitFacing(fx.dummy[2], fx.lockangle[2])
                    call SetUnitFacing(fx.effectdummy[2],fx.lockangle[2])
                    call EXSetUnitFacing(fx.effectdummy[2], fx.lockangle[2])
                    set fx.lockangle[3] = AngleWBW(fx.dummy[3], fx.targetUnit[3])
                    call SetUnitFacing(fx.dummy[3],fx.lockangle[3])
                    call EXSetUnitFacing(fx.dummy[3], fx.lockangle[3])
                    call SetUnitFacing(fx.effectdummy[3],fx.lockangle[3])
                    call EXSetUnitFacing(fx.effectdummy[3], fx.lockangle[3])
                    if fx.targetcount == 1 then
                        set fx.lockangle[4] = AngleWBW(fx.dummy[4], fx.targetUnit[4])
                        call SetUnitFacing(fx.dummy[4],fx.lockangle[4])
                        call EXSetUnitFacing(fx.dummy[4], fx.lockangle[4])
                        call SetUnitFacing(fx.effectdummy[4],fx.lockangle[4])
                        call EXSetUnitFacing(fx.effectdummy[4], fx.lockangle[4])
                    endif
                    if fx.targetcount == 2 then
                        set fx.lockangle[5] = AngleWBW(fx.dummy[5], fx.targetUnit[5])
                        call SetUnitFacing(fx.dummy[5],fx.lockangle[5])
                        call EXSetUnitFacing(fx.dummy[5], fx.lockangle[5])
                        call SetUnitFacing(fx.effectdummy[5],fx.lockangle[5])
                        call EXSetUnitFacing(fx.effectdummy[5], fx.lockangle[5])
                    endif
                    if fx.targetcount == 3 then
                        set fx.lockangle[6] = AngleWBW(fx.dummy[6], fx.targetUnit[6])
                        call SetUnitFacing(fx.dummy[6],fx.lockangle[6])
                        call EXSetUnitFacing(fx.dummy[6], fx.lockangle[6])
                        call SetUnitFacing(fx.effectdummy[6],fx.lockangle[6])
                        call EXSetUnitFacing(fx.effectdummy[6], fx.lockangle[6])
                    endif
                //발사 및 종료
                elseif fx.i == Pattern4Time2 then
                    call Missile(fx.caster, MakeMissile("Freezingsplinter.mdl",GetWidgetX(fx.dummy[0]),GetWidgetY(fx.dummy[0]),50,fx.lockangle[0],1.00,null), Pattern4Distance, fx.lockangle[0], Pattern4Speed, Pattern4Range, Pattern4DMG, 2)
                    call KillUnit(fx.dummy[0])
                    call KillUnit(fx.effectdummy[0])
                    call Missile(fx.caster, MakeMissile("Freezingsplinter.mdl",GetWidgetX(fx.dummy[1]),GetWidgetY(fx.dummy[1]),50,fx.lockangle[1],1.00,null), Pattern4Distance, fx.lockangle[1], Pattern4Speed, Pattern4Range, Pattern4DMG, 2)
                    call KillUnit(fx.dummy[1])
                    call KillUnit(fx.effectdummy[1])
                    call Missile(fx.caster, MakeMissile("Freezingsplinter.mdl",GetWidgetX(fx.dummy[2]),GetWidgetY(fx.dummy[2]),50,fx.lockangle[2],1.00,null), Pattern4Distance, fx.lockangle[2], Pattern4Speed, Pattern4Range, Pattern4DMG, 2)
                    call KillUnit(fx.dummy[2])
                    call KillUnit(fx.effectdummy[2])
                    call Missile(fx.caster, MakeMissile("Freezingsplinter.mdl",GetWidgetX(fx.dummy[3]),GetWidgetY(fx.dummy[3]),50,fx.lockangle[3],1.00,null), Pattern4Distance, fx.lockangle[3], Pattern4Speed, Pattern4Range, Pattern4DMG, 2)
                    call KillUnit(fx.dummy[3])
                    call KillUnit(fx.effectdummy[3])
                    if fx.targetcount == 1 then
                        call Missile(fx.caster, MakeMissile("Freezingsplinter.mdl",GetWidgetX(fx.dummy[4]),GetWidgetY(fx.dummy[4]),50,fx.lockangle[4],1.00,null), Pattern4Distance, fx.lockangle[4], Pattern4Speed, Pattern4Range, Pattern4DMG, 2)
                        call KillUnit(fx.dummy[4])
                        call KillUnit(fx.effectdummy[4])
                    endif
                    if fx.targetcount == 2 then
                        call Missile(fx.caster, MakeMissile("Freezingsplinter.mdl",GetWidgetX(fx.dummy[5]),GetWidgetY(fx.dummy[5]),50,fx.lockangle[5],1.00,null), Pattern4Distance, fx.lockangle[5], Pattern4Speed, Pattern4Range, Pattern4DMG, 2)
                        call KillUnit(fx.dummy[5])
                        call KillUnit(fx.effectdummy[5])
                    endif
                    if fx.targetcount == 3 then
                        call Missile(fx.caster, MakeMissile("Freezingsplinter.mdl",GetWidgetX(fx.dummy[6]),GetWidgetY(fx.dummy[6]),50,fx.lockangle[6],1.00,null), Pattern4Distance, fx.lockangle[6], Pattern4Speed, Pattern4Range, Pattern4DMG, 2)
                        call KillUnit(fx.dummy[6])
                        call KillUnit(fx.effectdummy[6])
                    endif
                    //대기상태로 전환
                    call AnimationStart4(fx.caster, 7, 0.02)
                    set Unitstate[IndexUnit(fx.caster)] = 4
                    set st.j = StandTime
                    call fx.Stop()
                endif
            //주금
            else
                call UnitRemoveAbility(fx.caster,'A00V')
                call fx.Stop()
            endif
        endmethod
        //! runtextmacro 연출효과_타이머("FxEffect3", "0.02", "true")
    endstruct

    //3장판
    private struct FxEffect2
        unit caster
        unit dummy1
        unit dummy2
        unit dummy3
        integer i
        MapStruct st
        private method OnStop takes nothing returns nothing
            set caster = null
            set dummy1 = null
            set dummy2 = null
            set dummy3 = null
            set st = 0
        endmethod
        //! runtextmacro 연출()
    endstruct
    
    private struct FxEffect2_Timer extends array
        private method OnAction takes FxEffect2 fx returns nothing
            local effect e
            local real r
            local integer i
            local tick t
            local MapStruct st = fx.st
            set fx.i = fx.i + 1
            if fx.caster != null and IsUnitDeadVJ(fx.caster) == false then
                if fx.i == 1 then
                    set i = GetRandomInt(0,3)
                    set fx.dummy1 = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03K',GetWidgetX(fx.caster)+PolarX(500,GetUnitFacing(fx.caster)+(i*90)),GetWidgetY(fx.caster)+PolarY(500,GetUnitFacing(fx.caster)+(i*90)),270)
                    call AOE(fx.caster, GetWidgetX(fx.caster)+PolarX(500,GetUnitFacing(fx.caster)+(i*90)),GetWidgetY(fx.caster)+PolarY(500,GetUnitFacing(fx.caster)+(i*90)), 500, 2.0, 0, 2, 2)
                    set fx.dummy2 = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03K',GetWidgetX(fx.caster)+PolarX(500,GetUnitFacing(fx.caster)+(i*90)+90),GetWidgetY(fx.caster)+PolarY(500,GetUnitFacing(fx.caster)+(i*90)+90),270)
                    call AOE(fx.caster, GetWidgetX(fx.caster)+PolarX(500,GetUnitFacing(fx.caster)+(i*90)+90),GetWidgetY(fx.caster)+PolarY(500,GetUnitFacing(fx.caster)+(i*90)+90), 500, 2.0, 0, 2, 2)
                    set fx.dummy3 = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'e03K',GetWidgetX(fx.caster)+PolarX(500,GetUnitFacing(fx.caster)+(i*90)+180),GetWidgetY(fx.caster)+PolarY(500,GetUnitFacing(fx.caster)+(i*90)+180),270)
                    call AOE(fx.caster, GetWidgetX(fx.caster)+PolarX(500,GetUnitFacing(fx.caster)+(i*90)+180),GetWidgetY(fx.caster)+PolarY(500,GetUnitFacing(fx.caster)+(i*90)+180), 500, 2.0, 0, 2, 2)
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
                    set Unitstate[IndexUnit(fx.caster)] = 4
                    set st.j = StandTime
                    call fx.Stop()
                endif
            //주금
            else
                call UnitRemoveAbility(fx.caster,'A00V')
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
        MapStruct st
        AOESt ast
        private method OnStop takes nothing returns nothing
            set caster = null
            set dummy = null
            set st = 0
            set ast = 0
        endmethod
        //! runtextmacro 연출()
    endstruct
    
    private struct FxEffect_Timer extends array
        private method OnAction takes FxEffect fx returns nothing
            local effect e
            local real r
            local integer i
            local tick t
            local MapStruct st = fx.st
            local AOESt ast
            set fx.i = fx.i + 1
            if fx.caster != null and IsUnitDeadVJ(fx.caster) == false then
                if fx.i == 1 then
                    call SetUnitVertexColorBJ( fx.caster, 70, 70, 100, 0 )
                    call UnitEffectTimeEX('e00F',GetWidgetX(fx.caster),GetWidgetY(fx.caster),0,3)
                    call UnitEffectTimeEX('e00G',GetWidgetX(fx.caster),GetWidgetY(fx.caster),0,3)
                    call UnitEffectTimeEX('e01S',GetWidgetX(fx.caster),GetWidgetY(fx.caster),0,3)
                    call UnitAddAbility(fx.caster,'A00V')
                    set fx.ast = AOE(fx.caster, GetWidgetX(fx.caster), GetWidgetY(fx.caster), distance, 0.5 + (Pattern3CounterTime * 0.02) , 0, 1, 2)

                //카운터침
                elseif fx.i >= 1 and GetUnitAbilityLevel(fx.caster,'A00V') == 0 then
                    call Sound3D(fx.caster,'A00U')
                    call AnimationStart(fx.caster,6)
                    call SetUnitVertexColorBJ( fx.caster, 100, 100, 100, 0 )
                    set fx.ast.stop = true
                    set Unitstate[IndexUnit(fx.caster)] = 4
                    set st.j = StandTime + CounterTime
                    call fx.Stop()
                //카운터를 못침
                elseif fx.i == Pattern3CounterTime then
                    call UnitEffectTimeEX('e01J',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.90)
                    call UnitEffectTimeEX('e01J',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.90)
                    call UnitEffectTimeEX('e01J',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.90)
                    call UnitEffectTimeEX('e01J',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.90)
                    call UnitEffectTimeEX('e01J',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),0.90)
                    set fx.ast.stop = false
                    call UnitRemoveAbility(fx.caster,'A00V')
                    call SetUnitVertexColorBJ( fx.caster, 100, 100, 100, 0 )
                    call AnimationStart4(fx.caster, 7, 0.02)
                    set Unitstate[IndexUnit(fx.caster)] = 4
                    set st.j = StandTime
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
        local FxEffect1 fx1
        local FxEffect2 fx2
        local FxEffect3 fx3
        local FxEffect4 fx4
        local integer index
        local AggroSystem s
        local real r
        
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
                
                //휴식시간감소
                if st.j != 0 then
                    set st.j = st.j - 1
                //휴식종료
                elseif st.j == 0 and Unitstate[IndexUnit(st.caster)] == 4 then
                    set Unitstate[IndexUnit(st.caster)] = 0
                endif
                //if splash.range( splash.ENEMY, st.caster, GetWidgetX(st.caster), GetWidgetY(st.caster), scale, function SplashNothing ) then
                //endif
                //일반상태,이동중,휴식
                if Unitstate[IndexUnit(st.caster)] == 0 or Unitstate[IndexUnit(st.caster)] == 3 or Unitstate[IndexUnit(st.caster)] == 4 then
                    set st.pattern6 = st.pattern6 - 1
                    //set st.pattern4 = st.pattern4 - 1
                    //set st.pattern3 = st.pattern3 - 1
                    //set st.pattern2 = st.pattern2 - 1
                    call BJDebugMsg("3장판: "+I2S(st.pattern2)+", 카운터: "+I2S(st.pattern3)+", 파편:"+I2S(st.pattern4)+", 마력포격:"+I2S(st.pattern6))

                    if Unitstate[IndexUnit(st.caster)] != 4 then
                        //카운터
                        if st.pattern3 <= 0 then
                            call BJDebugMsg("카운터")
                            set fx = FxEffect.Create()
                            set fx.caster = st.caster
                            set fx.i = 0
                            set fx.st = st
                            call AnimationStart(fx.caster, 5)
                            call fx.Start()
                            set Unitstate[IndexUnit(fx.caster)] = 1
                            set st.pattern3 = Pattern3Cool + GetRandomInt(0,Pattern3RandomCool)
                        //3장판
                        elseif st.pattern2 <= 0 then
                            call BJDebugMsg("3장판")
                            set fx2 = FxEffect2.Create()
                            set fx2.caster = st.caster
                            set fx2.i = 0
                            set fx2.st = st
                            call AnimationStart(fx2.caster, 3)
                            call fx2.Start()
                            set Unitstate[IndexUnit(fx2.caster)] = 1
                            set st.pattern2 = Pattern2Cool + GetRandomInt(0,Pattern2RandomCool)
                        //얼음파편
                        elseif st.pattern4 <= 0 then
                            call BJDebugMsg("파편")
                            set fx3 = FxEffect3.Create()
                            set fx3.caster = st.caster
                            set fx3.i = 0
                            set fx3.st = st
                            call AnimationStart(fx3.caster, 3)
                            call fx3.Start()
                            set Unitstate[IndexUnit(fx3.caster)] = 1
                            set st.pattern4 = Pattern4Cool + GetRandomInt(0,Pattern4RandomCool)
                        //마력포격
                        elseif st.pattern6 <= 0 then
                            call BJDebugMsg("마력포격")
                            set fx4 = FxEffect4.Create()
                            set fx4.caster = st.caster
                            set fx4.i = 0
                            set fx4.st = st
                            call AnimationStart(fx4.caster, 3)
                            call fx4.Start()
                            set Unitstate[IndexUnit(fx4.caster)] = 1
                            set st.pattern6 = Pattern6Cool + GetRandomInt(0,Pattern6RandomCool)
                        //이동
                        else
                            //이동중이 아님
                            if Unitstate[IndexUnit(st.caster)] != 3 then
                                set s = BossStruct[IndexUnit(st.caster)]
                                set r = DistanceWBW( st.caster, MainUnit[s.NowAggro])
                                if r > Pattern1Distance2 then
                                    call BJDebugMsg("이동")
                                    set fx1 = FxEffect1.Create()
                                    set fx1.caster = st.caster
                                    set fx1.i = 0
                                    set fx1.s = BossStruct[IndexUnit(fx1.caster)]
                                    call SetUnitFacing(fx1.caster,AngleWBW(fx1.caster,MainUnit[s.NowAggro]))
                                    call EXSetUnitFacing(fx1.caster,AngleWBW(fx1.caster,MainUnit[s.NowAggro]))
                                    call AnimationStart(fx1.caster, 2)
                                    call fx1.Start()
                                    set Unitstate[IndexUnit(fx1.caster)] = 3
                                endif
                            endif
                        endif
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
            set st.pattern4 = Pattern4Cool
            set st.pattern5 = Pattern5Cool
            set st.pattern6 = Pattern6Cool
            set st.pattern7 = Pattern7Cool
            //휴식
            set st.j = 0
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
    
    