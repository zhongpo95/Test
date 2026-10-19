library SafePos
    globals
        real SafePosX
        real SafePosY
        // 이동 경계(플레이어별). 사냥터/원정 전투가 등록하면 돌진·순간이동·넉백이 경계에서 멈춘다.
        unit array MoveBoundUnit
        real array MoveBoundMinX
        real array MoveBoundMinY
        real array MoveBoundMaxX
        real array MoveBoundMaxY
        real MoveBoundX
        real MoveBoundY
        constant real MOVE_BOUND_MARGIN = 32.0
    endglobals

    function MoveBoundSet takes integer pid, unit u, real minX, real minY, real maxX, real maxY returns nothing
        set MoveBoundUnit[pid] = u
        set MoveBoundMinX[pid] = minX
        set MoveBoundMinY[pid] = minY
        set MoveBoundMaxX[pid] = maxX
        set MoveBoundMaxY[pid] = maxY
    endfunction

    function MoveBoundSetRect takes integer pid, unit u, rect r returns nothing
        if r == null then
            set MoveBoundUnit[pid] = null
            return
        endif
        call MoveBoundSet(pid, u, GetRectMinX(r), GetRectMinY(r), GetRectMaxX(r), GetRectMaxY(r))
    endfunction

    function MoveBoundClear takes integer pid returns nothing
        set MoveBoundUnit[pid] = null
    endfunction

    // (x, y)를 u의 이동 경계 안으로 당겨 MoveBoundX/Y에 넣는다. 경계가 없거나
    // u가 이미 경계 밖에 있으면(지난 경계가 남은 경우) 그대로 둔다. 잘렸으면 true.
    function MoveBoundClamp takes unit u, real x, real y returns boolean
        local integer pid
        local real ux
        local real uy
        set MoveBoundX = x
        set MoveBoundY = y
        if u == null then
            return false
        endif
        set pid = GetPlayerId(GetOwningPlayer(u))
        if MoveBoundUnit[pid] != u then
            return false
        endif
        set ux = GetUnitX(u)
        set uy = GetUnitY(u)
        if ux < MoveBoundMinX[pid] or ux > MoveBoundMaxX[pid] or uy < MoveBoundMinY[pid] or uy > MoveBoundMaxY[pid] then
            return false
        endif
        set MoveBoundX = RMaxBJ(MoveBoundMinX[pid] + MOVE_BOUND_MARGIN, RMinBJ(MoveBoundMaxX[pid] - MOVE_BOUND_MARGIN, x))
        set MoveBoundY = RMaxBJ(MoveBoundMinY[pid] + MOVE_BOUND_MARGIN, RMinBJ(MoveBoundMaxY[pid] - MOVE_BOUND_MARGIN, y))
        return MoveBoundX != x or MoveBoundY != y
    endfunction

    function SetSafePolar takes unit u, real DIST, real RECT returns nothing
        local real UnitX = GetWidgetX(u)
        local real UnitY = GetWidgetY(u)
        local real TPX = UnitX+PolarX( DIST, RECT )
        local real TPY = UnitY+PolarY( DIST, RECT )
        local real TPX2 = UnitX+PolarX( DIST, RECT )
        local real TPY2 = UnitY+PolarY( DIST, RECT )
        local real dis = DIST
        local real dislimit = DIST

        loop
        exitwhen IsTerrainPathable(TPX, TPY, PATHING_TYPE_WALKABILITY) == false or IsTerrainPathable(TPX2, TPY2, PATHING_TYPE_WALKABILITY) == false
            set dis = dis - 4.00
            set TPX = UnitX+PolarX( dis, RECT )
            set TPY = UnitY+PolarY( dis, RECT )
            if dislimit < DIST+0.1 then
                set dislimit = dislimit + 4.00
                set TPX2 = UnitX+PolarX( dis, RECT )
                set TPY2 = UnitY+PolarY( dis, RECT )
            endif
        endloop
        if IsTerrainPathable(TPX, TPY, PATHING_TYPE_WALKABILITY) == false then
            set SafePosX = TPX
            set SafePosY = TPY
        else
            set SafePosX = TPX2
            set SafePosY = TPY2
        endif
        if MoveBoundClamp(u, SafePosX, SafePosY) then
            set SafePosX = MoveBoundX
            set SafePosY = MoveBoundY
        endif
        call SetUnitPosition(u,SafePosX,SafePosY)
    endfunction

    function SetSafePolar2 takes unit u, real DIST, real RECT returns nothing
        local real UnitX = GetWidgetX(u)
        local real UnitY = GetWidgetY(u)
        local real TPX = UnitX+PolarX( DIST, RECT )
        local real TPY = UnitY+PolarY( DIST, RECT )
        local real TPX2 = UnitX+PolarX( DIST, RECT )
        local real TPY2 = UnitY+PolarY( DIST, RECT )
        local real dis = DIST
        local real dislimit = DIST

        loop
        exitwhen IsTerrainPathable(TPX, TPY, PATHING_TYPE_WALKABILITY) == false or IsTerrainPathable(TPX2, TPY2, PATHING_TYPE_WALKABILITY) == false
            set dis = dis - 4.00
            set TPX = UnitX+PolarX( dis, RECT )
            set TPY = UnitY+PolarY( dis, RECT )
            if dislimit < DIST+0.1 then
                set dislimit = dislimit + 4.00
                set TPX2 = UnitX+PolarX( dis, RECT )
                set TPY2 = UnitY+PolarY( dis, RECT )
            endif
        endloop
        if IsTerrainPathable(TPX, TPY, PATHING_TYPE_WALKABILITY) == false then
            set SafePosX = TPX
            set SafePosY = TPY
        else
            set SafePosX = TPX2
            set SafePosY = TPY2
        endif
        if MoveBoundClamp(u, SafePosX, SafePosY) then
            set SafePosX = MoveBoundX
            set SafePosY = MoveBoundY
        endif
    endfunction
    // (x0, y0)에서 (x1, y1)로 가는 길을 16 간격으로 확인해, 처음 막힌 칸 바로 앞 지점을
    // MoveBoundX/Y에 넣는다. 얇은 벽(사냥터 팔각형 테두리 등)을 한 번에 건너뛰는 것을 막는다.
    // 출발점이 이미 막힌 칸이면 걸을 수 있는 칸을 만날 때까지는 막힌 칸을 무시한다(벽에 낀 채 굳지 않게).
    function SafePathClip takes real x0, real y0, real x1, real y1 returns boolean
        local real dx = x1 - x0
        local real dy = y1 - y0
        local integer n = R2I(SquareRoot(dx * dx + dy * dy) / 16.0) + 1
        local integer i = 1
        local real px
        local real py
        local boolean seen = not IsTerrainPathable(x0, y0, PATHING_TYPE_WALKABILITY)
        set MoveBoundX = x0
        set MoveBoundY = y0
        loop
            exitwhen i > n
            set px = x0 + dx * i / n
            set py = y0 + dy * i / n
            if IsTerrainPathable(px, py, PATHING_TYPE_WALKABILITY) then
                if seen then
                    return true
                endif
            else
                set seen = true
                set MoveBoundX = px
                set MoveBoundY = py
            endif
            set i = i + 1
        endloop
        return false
    endfunction

    // 아이템 배치로 막힌 칸을 피해 (X, Y)로 옮긴다. 이동 경계가 있으면 그 안에서 멈추고,
    // 가는 길에 막힌 칸이 있으면 그 앞에서 멈춘다.
    function SafeMoveUnitXY takes unit u, real X, real Y returns nothing
        local item tem
        local real tx
        local real ty
        call MoveBoundClamp(u, X, Y)
        set tem = CreateItem('cnob', MoveBoundX, MoveBoundY)
        set tx = GetItemX(tem)
        set ty = GetItemY(tem)
        call RemoveItem(tem)
        set tem = null
        call MoveBoundClamp(u, tx, ty)
        set tx = MoveBoundX
        set ty = MoveBoundY
        if SafePathClip(GetUnitX(u), GetUnitY(u), tx, ty) then
            set tx = MoveBoundX
            set ty = MoveBoundY
        endif
        if IsTerrainPathable(tx, ty, PATHING_TYPE_WALKABILITY) == false then
            call SetUnitX(u, tx)
            call SetUnitY(u, ty)
        endif
    endfunction
    //아이템위치로이동
    function SetUnitSafePolarUTA takes unit u, real DIST, real Ang returns nothing
        call SafeMoveUnitXY(u, GetWidgetX(u)+PolarX( DIST, Ang ), GetWidgetY(u)+PolarY( DIST, Ang ))
    endfunction
    function SetUnitSafePolarUTP takes unit u, real DIST, real tx, real ty returns nothing
        local real angle = Atan2(ty-GetWidgetY(u), tx-GetWidgetX(u))
        call SafeMoveUnitXY(u, GetWidgetX(u)+ DIST * Cos(angle), GetWidgetY(u)+ DIST * Sin(angle))
    endfunction
    function SetUnitSafeXY takes unit u, real X, real Y returns nothing
        call SafeMoveUnitXY(u, X, Y)
    endfunction
    function SafeUnitCreate takes player p, integer i, real X, real Y, real r returns unit
        local item tem
        local real temX
        local real temY
        set tem = CreateItem('cnob', X, Y)
        set temX = GetItemX(tem)
        set temY = GetItemY(tem)
        call RemoveItem(tem)
        set tem = null
        return CreateUnit(p,i,temX,temY,r)
    endfunction

    struct SkillDash
        /*========================================================================*/
        unit Owner
        real Max
        real TargetX
        real TargetY
        real Speed
        /*========================================================================*/
        private method OnStop takes nothing returns nothing
            //call UnitRemoveAbility( this.Owner, 'B000' )

            call PauseUnitEx(this.Owner,false)
            //call SetUnitVertexColorBJ( this.Owner, 100, 100, 100, 0 )
            set this.Owner = null
        endmethod
        private method OnTick takes nothing returns nothing
            // 최대 거리에 도착하면 멈춤
            if this.Max < this.Speed then
                call SetUnitSafePolarUTP(this.Owner,this.Speed,this.TargetX,this.TargetY)
                call this.stop()
            elseif DistanceWBP(this.Owner,this.TargetX,this.TargetY) > this.Speed then
                // 속도만큼 이동시켜도 남은 거리가 더 있다면 [비행!]
                call SetUnitSafePolarUTP(this.Owner,this.Speed,this.TargetX,this.TargetY)
                set this.Max = this.Max - this.Speed
            else
                // 남은 거리가 속도보다 짧거나 같다면 [충돌!]
                call SetUnitSafeXY(this.Owner,this.TargetX,this.TargetY)
                call this.stop()
            endif
        endmethod
        /*========================================================================*/
        private static method OnTimer takes nothing returns nothing
            local tick expiredTick = tick.getExpired()
            local thistype this = expiredTick.data

            call this.OnTick()
        endmethod
        private tick lifeTick
        private boolean lifeStarted
        private boolean lifeStopping

        static method create takes nothing returns thistype
            local thistype this = allocate()

            set this.lifeTick = 0
            set this.lifeStarted = false
            set this.lifeStopping = false

            return this
        endmethod
        method start takes nothing returns nothing
            if this.lifeStarted then
                return
            endif

            set this.lifeStarted = true
            set this.lifeTick = tick.create(0)
            set this.lifeTick.data = this
            call this.lifeTick.start(0.02, true, function thistype.OnTimer)
        endmethod
        method stop takes nothing returns nothing
            if this.lifeStopping then
                return
            endif

            set this.lifeStopping = true
            call this.OnStop()

            if this.lifeTick != 0 then
                set this.lifeTick.data = 0
                call this.lifeTick.destroy()
                set this.lifeTick = 0
            endif

            call deallocate()
        endmethod
        /*========================================================================*/
    endstruct

endlibrary