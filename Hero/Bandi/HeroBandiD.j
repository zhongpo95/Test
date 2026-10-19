scope HeroBandiD
    globals
        private constant real SD = 0.00
        //쉐클(행동 불가) 시간: 도약 + 체공 + 내려찍기 + 착지 후딜
        private constant real Time = 0.95
        //2번 애니메이션(라이더킥)은 시작 0.439초 뒤에 발차기가 나온다. 도약(0.30)+체공(0.12)이 끝나 내려찍기를 시작하는 시점과 맞춘다
        //지정 최대 사거리
        private constant real MaxRange = 700
        //뒤로 도약하는 거리와 최고 높이
        private constant real BackD = 250
        private constant real JumpH = 420
        //구간 길이(틱 0.02초 기준): 도약 15틱(0.30초), 체공 6틱(0.12초), 내려찍기 9틱(0.18초)
        private constant integer TickUp = 15
        private constant integer TickHang = 6
        private constant integer TickDown = 9
        //내려찍기 범위
        private constant real scale = 450
        private constant real distance = 350
    endglobals

    //착지 피해: 대상마다 2회 (예전 돌진 경로 1회 + 착지 1회와 같은 횟수)
    private function splashD takes nothing returns nothing
        local integer pid = GetPlayerId(GetOwningPlayer(splash.source))

        if IsUnitInRangeXY(GetEnumUnit(),splash.x,splash.y,distance) then
            call HeroDeal('A06E',splash.source,GetEnumUnit(),HeroSkillVelue6[15],false,false,false,false)
            call HeroDeal('A06E',splash.source,GetEnumUnit(),HeroSkillVelue6[15],false,false,false,false)
            call UnitEffectTimeEX2('e03Y',GetWidgetX(GetEnumUnit()),GetWidgetY(GetEnumUnit()),GetRandomReal(0,360),1.2,pid)
        endif
    endfunction

    private function SetHeight takes unit u, real h returns nothing
        call UnitAddAbility(u,'Arav')
        call UnitRemoveAbility(u,'Arav')
        call SetUnitFlyHeight(u, h, 0.00)
    endfunction

    //fx.i: 틱 카운트, fx.r2: 시전 방향(대상 쪽), fx.TargetX/Y: 내려찍을 지점, fx.TargetX2/Y2: 체공 시작 지점
    private function EffectFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        local SkillFx fx = t.data
        local real p
        local real x
        local real y

        if fx.caster == null or IsUnitDeadVJ(fx.caster) then
            if fx.caster != null then
                call SetHeight(fx.caster, 0)
            endif
            if fx.e != null then
                call DestroyEffect(fx.e)
                set fx.e = null
            endif
            call fx.stop()
            call t.destroy()
            return
        endif

        set fx.i = fx.i + 1

        if fx.i <= TickUp then
            //1) 대상 반대쪽(뒤쪽 하늘)으로 도약. 얼굴은 대상 쪽을 유지한다
            set p = I2R(fx.i) / I2R(TickUp)
            call SetUnitSafePolarUTA(fx.caster, BackD / I2R(TickUp), fx.r2 + 180)
            call SetHeight(fx.caster, JumpH * Sin(p * bj_PI / 2))
            call SetUnitFacing(fx.caster, fx.r2)
            call EXSetUnitFacing(fx.caster, fx.r2)
            if fx.i == TickUp then
                set fx.TargetX2 = GetUnitX(fx.caster)
                set fx.TargetY2 = GetUnitY(fx.caster)
            endif
            call t.start( 0.02 / fx.speed, false, function EffectFunction )
        elseif fx.i <= TickUp + TickHang then
            //2) 최고점에서 잠깐 멈춘 뒤 내려찍기 준비
            if fx.i == TickUp + 1 then
                if fx.j == 0 then
                    call Sound3D(fx.caster,'A060')
                else
                    call Sound3D(fx.caster,'A061')
                endif
            endif
            call t.start( 0.02 / fx.speed, false, function EffectFunction )
        elseif fx.i <= TickUp + TickHang + TickDown then
            //3) 지정 지점으로 내려찍기
            if fx.i == TickUp + TickHang + 1 then
                //발차기 순간: 예전 D가 최고점에서 발차기할 때 쓰던 공중 폭발 이펙트 (같은 위치·방향) + 몸에 붙는 잔상. 바닥 이펙트는 쓰지 않는다
                call Sound3D(fx.caster,'A05X')
                call UnitEffectTime2('e03W',GetWidgetX(fx.caster),GetWidgetY(fx.caster),fx.r2,1.5,0,fx.pid)
                call UnitEffectTime2('e04G',GetWidgetX(fx.caster)+PolarX(50,fx.r2),GetWidgetY(fx.caster)+PolarY(50,fx.r2),fx.r2-180,2.0,0,fx.pid)
                if fx.pid != GetPlayerId(GetLocalPlayer()) then
                    set fx.e = AddSpecialEffectTarget(".mdl", fx.caster,"chest")
                else
                    set fx.e = AddSpecialEffectTarget("tx-LiuYing17.mdl",fx.caster,"chest")
                endif
            endif
            set p = I2R(fx.i - TickUp - TickHang) / I2R(TickDown)
            set x = fx.TargetX2 + (fx.TargetX - fx.TargetX2) * p
            set y = fx.TargetY2 + (fx.TargetY - fx.TargetY2) * p
            call SetUnitSafeXY(fx.caster, x, y)
            call SetHeight(fx.caster, JumpH * (1.0 - p * p))
            if fx.i == TickUp + TickHang + TickDown then
                //착지: 실제로 도착한 위치를 중심으로 판정 (벽에 막히면 막힌 자리에서 터진다)
                call SetHeight(fx.caster, 0)
                if fx.e != null then
                    call DestroyEffect(fx.e)
                    set fx.e = null
                endif
                set x = GetUnitX(fx.caster)
                set y = GetUnitY(fx.caster)
                call CameraShaker.setShakeForPlayer( GetOwningPlayer(fx.caster), 20 )
                //착지: 예전 D의 도착 이펙트
                call UnitEffectTime2('e03Z',x,y,fx.r2,1.5,0,fx.pid)
                call UnitEffectTime2('e04F',x,y,fx.r2,2.0,0,fx.pid)
                call splash.range( splash.ENEMY, fx.caster, x, y, scale, function splashD )
                call fx.stop()
                call t.destroy()
            else
                call t.start( 0.02 / fx.speed, false, function EffectFunction )
            endif
        endif
    endfunction

    private function Main takes nothing returns nothing
        local tick t
        local SkillFx fx
        local real d

        if GetSpellAbilityId() == 'A06E' and not BandiCastBlocked(GetTriggerUnit(), 'A06E') then
            set t = tick.create(0)
            set fx = SkillFx.create()
            set fx.caster = GetTriggerUnit()
            set fx.pid = GetPlayerId(GetOwningPlayer(fx.caster))
            set fx.i = 0
            set fx.speed = ((100+SkillSpeed(fx.pid))/100)
            set fx.j = GetRandomInt(0,1)
            set fx.e = null
            set fx.r2 = AngleWBP(fx.caster, GetSpellTargetX(), GetSpellTargetY())
            //지정 지점. 최대 사거리를 넘으면 그 방향 최대 사거리 지점
            set d = DistanceWBP(fx.caster, GetSpellTargetX(), GetSpellTargetY())
            if d > MaxRange then
                set d = MaxRange
            endif
            set fx.TargetX = GetUnitX(fx.caster) + PolarX(d, fx.r2)
            set fx.TargetY = GetUnitY(fx.caster) + PolarY(d, fx.r2)

            call SetUnitFacing(fx.caster, fx.r2)
            call EXSetUnitFacing(fx.caster, fx.r2)

            call Overlay2Count(fx.pid,'A06E')

            call DummyMagicleash(fx.caster, Time / fx.speed)
            call AnimationStart3(fx.caster, 2, fx.speed)

            call Sound3D(fx.caster,'A05W')
            if fx.j == 0 then
                call Sound3D(fx.caster,'A05Y')
            else
                call Sound3D(fx.caster,'A05Z')
            endif
            //도약 순간: 발밑 바닥이 터진다 (예전 D가 뛰어오를 때 쓰던 바닥 폭발)
            call UnitEffectTime2('e03X',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),2.0,0,fx.pid)
            call UnitEffectTime2('e03X',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),2.0,0,fx.pid)
            call UnitEffectTime2('e04E',GetWidgetX(fx.caster),GetWidgetY(fx.caster),GetRandomReal(0,360),2.0,0,fx.pid)

            call BanBisul2Plus( fx.pid,1)

            call BuffNoNB.Apply( fx.caster, Time / fx.speed, 0 )
            call BuffNoST.Apply( fx.caster, Time / fx.speed, 0 )

            set t.data = fx
            call t.start( 0.02 / fx.speed, false, function EffectFunction )

            call BandiStopOrder(fx.caster, "antimagicshell", Time / fx.speed)
            call CooldownFIX(fx.caster,'A06E',HeroSkillCD6[15])
        endif
    endfunction

    private function DSyncData takes nothing returns nothing
        local player p=(DzGetTriggerSyncPlayer())
        local string data=(DzGetTriggerSyncData())
        local integer pid=GetPlayerId(p)
        local integer dataLen=StringLength(data)
        local integer valueLen
        local real x
        local real y
        local real angle

        if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and IsUnitPausedEx(MainUnit[pid]) == false and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID6[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
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
                call BandiRequest(pid, 'A06E')
                call IssuePointOrder( MainUnit[pid], "antimagicshell", x, y )
            endif
        endif

        set p=null
    endfunction

    private function DSyncData2 takes nothing returns nothing
        local player p = DzGetTriggerSyncPlayer()
        local integer pid = GetPlayerId(p)
        local real x
        local real y
        local real angle
        local real speed
        local tick t

        set p=null
    endfunction


    private struct TEvAfterB extends array
        private static method onInit takes nothing returns nothing
            local trigger t = CreateTrigger()
            call TriggerAddAction(t,function thistype.Action)
            call TriggerRegisterTimerEvent(t,2.0,false)
            set t = null
        endmethod
        private static method Action takes nothing returns nothing
        local trigger t

        set t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddAction(t, function Main)

        set t=CreateTrigger()
        call DzTriggerRegisterSyncData(t,("BandiD"),(false))
        call TriggerAddAction(t,function DSyncData)

        set t=CreateTrigger()
        call DzTriggerRegisterSyncData(t,("BandiD2"),(false))
        call TriggerAddAction(t,function DSyncData2)

        set t = null
        endmethod
    endstruct
    endscope


