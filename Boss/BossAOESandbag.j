// 상태이상과 피해 장판 회피를 점검하는 허수아비 보스
library BossAOESandbag initializer Init requires Tick,DataUnit,UIBossHP,DamageEffect2,UIBossEnd,DataMap,Boss1,BossAggro,AOE,ItemPickUp,UIOverlay
    globals
        private constant integer DAMAGE_AOE_ID = 401
        private constant integer STATUS_AOE_ID = 402
        private constant integer PATTERN_COOL = 300
        private constant real DAMAGE_RANGE = 325
        private constant real STATUS_RANGE = 275

        private integer AlivePlayerCount
        private unit BossUnit
    endglobals

    private function AOEHit takes nothing returns nothing
        local unit caster = MonoEvent.Unit
        local unit target = MonoEvent.Unit2
        local integer id = MonoEvent.Integer

        if id == DAMAGE_AOE_ID then
            call BossDeal(caster, target, 150, false)
        elseif id == STATUS_AOE_ID then
            call BossDeal(caster, target, 50, false)
            call CustomStun.Stun2(target, 1.5)
        endif

        set caster = null
        set target = null
    endfunction

    private function SpawnDamagePattern takes MapStruct st returns nothing
        local real x = GetWidgetX(st.caster)
        local real y = GetWidgetY(st.caster)
        local unit target = BossAggroTarget(st.caster)

        if UnitAlive(target) then
            call AOE(st.caster, GetWidgetX(target), GetWidgetY(target), DAMAGE_RANGE, 1.5, 'e03J', DAMAGE_AOE_ID, 0)
        endif
        call AOE(st.caster, x + 550, y, DAMAGE_RANGE, 1.5, 'e03J', DAMAGE_AOE_ID, 0)
        call AOE(st.caster, x - 550, y, DAMAGE_RANGE, 1.5, 'e03J', DAMAGE_AOE_ID, 0)
        call AOE(st.caster, x, y + 550, DAMAGE_RANGE, 1.5, 'e03J', DAMAGE_AOE_ID, 0)
        call AOE(st.caster, x, y - 550, DAMAGE_RANGE, 1.5, 'e03J', DAMAGE_AOE_ID, 0)
        set target = null
    endfunction

    private function SpawnStatusPattern takes MapStruct st returns nothing
        local unit target = BossAggroTarget(st.caster)

        if UnitAlive(target) then
            call AOE(st.caster, GetWidgetX(target), GetWidgetY(target), STATUS_RANGE, 2.0, 0, STATUS_AOE_ID, 1)
        endif
        call AOE2(st.caster, GetWidgetX(st.caster), GetWidgetY(st.caster), 400, 1000, 2.5, 'e03J', DAMAGE_AOE_ID)
        set target = null
    endfunction

    private function CountAlivePlayer takes nothing returns nothing
        if UnitAlive(GetEnumUnit()) then
            set AlivePlayerCount = AlivePlayerCount + 1
        endif
    endfunction

    private function PlayerFailed takes nothing returns nothing
        call FailedStart(GetEnumUnit())
        call OverlayStop(GetPlayerId(GetOwningPlayer(GetEnumUnit())))
    endfunction

    private function PlayerSucceeded takes nothing returns nothing
        call SuccessStart(GetEnumUnit())
        call OverlayStop(GetPlayerId(GetOwningPlayer(GetEnumUnit())))
    endfunction

    private function BattleTick takes nothing returns nothing
        local tick t = tick.getExpired()
        local MapStruct st = t.data

        set AlivePlayerCount = 0
        call ForGroup(st.ul.super, function CountAlivePlayer)

        if AlivePlayerCount == 0 then
            call BossAggroDestroy(st.caster)
            call KillUnit(st.caster)
            call RemoveUnit(st.caster)
            call ForGroup(st.ul.super, function PlayerFailed)
            call st.ul.destroy()
            set st.caster = null
            call MapReset(st.rectnumber, 2)
            set st.rectnumber = 0
            call t.destroy()
        elseif UnitHP[IndexUnit(st.caster)] <= 0 or IsUnitDeadVJ(st.caster) then
            call ForGroup(st.ul.super, function PlayerSucceeded)
            call BossAggroDestroy(st.caster)
            call st.ul.destroy()
            call KillUnit(st.caster)
            set st.caster = null
            call BossMapReset(st.rectnumber, 2)
            set st.rectnumber = 0
            call t.destroy()
        else
            set st.pattern1 = st.pattern1 - 1
            if st.pattern1 <= 0 then
                set st.i = st.i + 1
                if ModuloInteger(st.i, 2) == 1 then
                    call SpawnDamagePattern(st)
                else
                    call SpawnStatusPattern(st)
                endif
                set st.pattern1 = PATTERN_COOL
            endif
        endif
    endfunction

    private function StartBattle takes MapStruct st returns nothing
        local tick t = tick.create(st)
        set MapRectCheck[st.rectnumber] = false
        call t.start(0.02, true, function BattleTick)
    endfunction

    private function PreparePlayer takes nothing returns nothing
        local integer pid = GetPlayerId(GetOwningPlayer(GetEnumUnit()))
        call ResetPlayerPotionCharges(pid)
        if GetLocalPlayer() == GetOwningPlayer(GetEnumUnit()) then
            call PlayersBossBarShow(GetLocalPlayer(), true)
            call DzFrameShow(BossTip, false)
        endif
        call BOSSHPSTART(BossUnit, pid)
        call Overlay(pid)
    endfunction

    private function EntranceTick takes nothing returns nothing
        local tick t = tick.getExpired()
        local MapStruct st = t.data
        if splash.range(splash.ALLY, st.caster, GetWidgetX(st.caster), GetWidgetY(st.caster), 500, function SplashNothing) == 0 then
            call KillUnit(st.caster)
            set st.caster = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), 'h00L', GetRectCenterX(MapRectReturn(st.rectnumber)), GetRectCenterY(MapRectReturn(st.rectnumber)), 270)
            call BossAggroInitialize(st.caster, st.ul.super)

            call UnitRemoveAbility(st.caster, 'Amov')
            call SetUnitPathing(st.caster, false)
            call PauseUnit(st.caster, true)
            call SetUnitPosition(st.caster, GetRectCenterX(MapRectReturn(st.rectnumber)), GetRectCenterY(MapRectReturn(st.rectnumber)))

            set BossUnit = st.caster
            call ForGroup(st.ul.super, function PreparePlayer)
            set BossUnit = null
            call StartBattle(st)
            call t.destroy()
        endif
    endfunction

    function AOESandbagStart takes unit source returns nothing
        local tick t
        local MapStruct st
        local integer pid = GetPlayerId(GetOwningPlayer(source))
        local integer mapNumber = GetMap(2)

        if mapNumber == 0 then
            return
        endif

        set st = MapSt[mapNumber]
        if st.caster == null then
            set t = tick.create(0)
            set st.rectnumber = mapNumber
            set st.caster = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'e01I', GetRectCenterX(MapRectReturn2(st.rectnumber)), GetRectCenterY(MapRectReturn2(st.rectnumber)), 270)
            set st.ul = party.create()
            set st.pattern1 = 150
            set st.i = 0
            call GroupAddUnit(st.ul.super, source)
            set t.data = st
            call t.start(0.02, true, function EntranceTick)
        else
            call GroupAddUnit(st.ul.super, source)
        endif

        call SetUnitPosition(source, GetRectCenterX(MapRectReturn2(st.rectnumber)), GetRectCenterY(MapRectReturn2(st.rectnumber)))
        if GetLocalPlayer() == Player(pid) then
            call SetCameraBoundsToRectForPlayerBJ(Player(pid), MapRectReturn(st.rectnumber))
            call SetCameraPositionForPlayer(Player(pid), GetRectCenterX(MapRectReturn2(st.rectnumber)), GetRectCenterY(MapRectReturn2(st.rectnumber)))
            call DzFrameShow(BossTip, true)
        endif
    endfunction

    private function Init takes nothing returns nothing
        call MonoEvent.Add(E_AOE, function AOEHit)
    endfunction
endlibrary
