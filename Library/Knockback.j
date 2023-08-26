library FXKnockback requires SafePos, UnitIndexer
    /*
        사용법
            call Knockback( source, angle, distance, duration )
            call KnockbackTo( source, destX, destY, duration )
            call KnockbackFrom( source, originUnit, distance, duration )
            Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl
    */
    globals
        //능력 - 넉백 중
        private constant integer ABID = 'A00S'
        //넉백무시체크
        private constant integer KBImmuneAbility = 'A00R'
        
        private integer array UT
        private trigger array TrgRemove
        private triggeraction array ActRemove
    endglobals
    
    //! runtextmacro 틱("KBTimer")
        unit caster
        real XEND
        real YEND
        real DIST
        real RECT
        integer IMAX
        integer ICUR
    //! runtextmacro 틱_끝()
        
        
    function IsUnitImmune takes unit u returns boolean
        if GetUnitAbilityLevel(u, KBImmuneAbility) == 1 then
            return true
        endif
        return false
    endfunction
    
    //! runtextmacro 이벤트_틱이_종료되면_발동("KBTimer")
        local integer i = GetUnitIndex(expired.caster)
        set expired.ICUR = expired.ICUR + 1
        call SetUnitSafePolarUTA(expired.caster, expired.DIST, expired.RECT )
        call IssueImmediateOrder( expired.caster, "stop" )
        if expired.ICUR == 0 then
            call DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl",GetUnitX(expired.caster),GetUnitY(expired.caster)))
        elseif ModuloInteger(expired.ICUR,10) == 0 then
            call DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl",GetUnitX(expired.caster),GetUnitY(expired.caster)))
        endif
        if expired.ICUR < expired.IMAX then
            return
        endif
        call UnitRemoveAbility( expired.caster, ABID )
        set UT[i] = 0
        set expired.caster = null
        call expired.Destroy()
    //! runtextmacro 이벤트_끝()
        
    function IsUnitKB takes unit u returns boolean
        if GetUnitAbilityLevel(u, ABID) > 0 then
            return true
        endif
        return false
    endfunction
        
    private function OnRemove takes nothing returns nothing
        local integer i = GetTriggerIndex()
        call TriggerRemoveAction(TrgRemove[i], ActRemove[i])
        set ActRemove[i] = null
        set TrgRemove[i] = null
        set UT[i] = 0
    endfunction
    
    private function KnockbackTo takes unit caster, real tx, real ty, real dur returns nothing
        local KBTimer t
        local real dist
        local real direct
        local integer i
        
        //소환물
        if IsUnitType(caster,UNIT_TYPE_SUMMONED) then
            return
        endif
        //이뮨상태
        if IsUnitImmune(caster) then
            return
        endif
        
        //인덱스
        set i = IndexUnit(caster)
        if ActRemove[i] == null then
            set TrgRemove[i] = GetUnitRemoveTrigger(caster)
            set ActRemove[i] = TriggerAddAction(TrgRemove[i],function OnRemove)
        endif
        
        //이미넉백중
        if IsUnitKB(caster) then
            set t = UT[i]
            call t.Pause()
        //새로운넉백
        else
            call UnitAddAbility(caster,ABID)
            set t = KBTimer.Create()
        endif
        
        set UT[i] = t
        
        set t.caster = caster
        set t.XEND = tx
        set t.YEND = ty
        set dist = Distance.WBP( caster, t.XEND, t.YEND )
        set direct = Angle.WBP( caster, t.XEND, t.YEND )
        set t.IMAX = IMaxBJ(1,R2I(dur*32))
        set t.DIST = dist/t.IMAX
        set t.RECT = direct
        set t.ICUR = 0
        call t.Start( 0.03125, true )
    endfunction
        
    function Knockback takes unit caster, real dir, real dist, real dur returns nothing
        local real x = GetUnitX(caster) + Polar.X( dist, dir )
        local real y = GetUnitY(caster) + Polar.Y( dist, dir )
        call KnockbackTo( caster, x, y, dur )
    endfunction
        
    function KnockbackFrom takes unit caster, unit ori, real dist, real dur returns nothing
        local real dir = Angle.WBW( caster, ori )
        call Knockback( caster, dir, dist, dur )
    endfunction
        
    function KnockbackFromPos takes unit caster, real ox, real oy, real dist, real dur returns nothing
        local real dir = Angle.PBW( ox, oy, caster )
        call Knockback( caster, dir, dist, dur )
    endfunction
        
    function KnockbackFromTo takes unit caster, unit ori, real dist, real dur returns nothing
        local real dir = Angle.WBW( ori, caster )
        set dist = dist - Distance.WBW( ori, caster )
        call Knockback( caster, dir, dist, dur )
    endfunction
        
    function KnockbackFromToPos takes unit caster, real ox, real oy, real dist, real dur returns nothing
        local real dir = Angle.PBW( ox,oy, caster )
        set dist = dist - Distance.PBW( ox,oy, caster )
        call Knockback( caster, dir, dist, dur )
    endfunction
    
    function KnockbackInverse takes unit caster, unit ori, real dist, real dur returns nothing
        local real dir = Angle.WBW( ori, caster )
        call Knockback( caster, dir, dist, dur )
    endfunction
    endlibrary