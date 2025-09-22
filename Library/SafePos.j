library SafePos
    globals
        real SafePosX
        real SafePosY
    endglobals
        
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
            call SetUnitPosition(u,TPX,TPY)
            set SafePosX = TPX
            set SafePosY = TPY
        else
            call SetUnitPosition(u,TPX2,TPY2)
            set SafePosX = TPX2
            set SafePosY = TPY2
        endif
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
    endfunction
    //아이템위치로이동
    function SetUnitSafePolarUTA takes unit u, real DIST, real Ang returns nothing
        local real UnitX = GetWidgetX(u)
        local real UnitY = GetWidgetY(u)
        local real TPX = UnitX+PolarX( DIST, Ang )
        local real TPY = UnitY+PolarY( DIST, Ang )
        local item tem
        
        set tem = CreateItem('cnob', TPX, TPY)
        call SetUnitX(u, GetItemX(tem))
        call SetUnitY(u, GetItemY(tem))
        call RemoveItem(tem)
        set tem = null
    endfunction
    function SetUnitSafePolarUTP takes unit u, real DIST, real tx, real ty returns nothing
        local real angle = Atan2(ty-GetWidgetY(u), tx-GetWidgetX(u))
        local real TPX = GetWidgetX(u)+ DIST * Cos(angle)
        local real TPY = GetWidgetY(u)+ DIST * Sin(angle)
        local item tem
        
        set tem = CreateItem('cnob', TPX, TPY)
        call SetUnitX(u, GetItemX(tem))
        call SetUnitY(u, GetItemY(tem))
        call RemoveItem(tem)
        set tem = null
    endfunction
    function SetUnitSafeXY takes unit u, real X, real Y returns nothing
        local real UnitX = GetWidgetX(u)
        local real UnitY = GetWidgetY(u)
        local item tem
        
        set tem = CreateItem('cnob', X, Y)
        call SetUnitX(u, GetItemX(tem))
        call SetUnitY(u, GetItemY(tem))
        call RemoveItem(tem)
        set tem = null
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
                call this.Stop()
            elseif DistanceWBP(this.Owner,this.TargetX,this.TargetY) > this.Speed then
                // 속도만큼 이동시켜도 남은 거리가 더 있다면 [비행!]
                call SetUnitSafePolarUTP(this.Owner,this.Speed,this.TargetX,this.TargetY)
                set this.Max = this.Max - this.Speed
            else
                // 남은 거리가 속도보다 짧거나 같다면 [충돌!]
                call SetUnitSafeXY(this.Owner,this.TargetX,this.TargetY)
                call this.Stop()
            endif
        endmethod
        /*========================================================================*/
        //! runtextmacro CFX()
        /*========================================================================*/
    endstruct
    
endlibrary