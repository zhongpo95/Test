library PointToPolygon
    struct polygon
        private static constant integer MAX_LENGTH = 32     /* 최대 꼭지점 수 */
        private integer count                               /* 현재 가지고 있는 꼭지점 수 */
        private real array px[32]                           /* 저장된 꼭지점 X축 */
        private real array py[32]                           /* 저장된 꼭지점 Y축 */
        
        static method create takes nothing returns thistype
            local thistype this = thistype.allocate()
            set count = 0
            return this
        endmethod
        
        method destroy takes nothing returns nothing
            set count = 0
            call this.deallocate()
        endmethod
        
        method operator Count takes nothing returns integer
            return count
        endmethod
        
        // 꼭지점 수정
        method SetPoint takes integer index, real x, real y returns nothing
            if index >= 0 and index < count then
                set px[index] = x
                set py[index] = y
            endif
        endmethod
        
        // 꼭지점 x축
        method GetPointX takes integer index returns real
            if index >= 0 and index < count then
                return px[index]
            endif
            return 0.0
        endmethod
        
        // 꼭지점 y축
        method GetPointY takes integer index returns real
            if index >= 0 and index < count then
                return py[index]
            endif
            return 0.0
        endmethod
        
        // 꼭지점 추가
        method AddPoint takes real x, real y returns nothing
            if count < MAX_LENGTH then
                set px[count] = x
                set py[count] = y
                set count = count + 1
            endif
        endmethod
        
        // 꼭지점 제거
        method RemovePoint takes integer index returns nothing
            local integer i
            if index >= 0 and index < count then
                // Shift 작업
                set i = index + 1
                loop
                    exitwhen i >= count
                    set px[i - 1] = px[i]
                    set py[i - 1] = py[i]
                    set i = i + 1
                endloop
                set count = count - 1
            endif
        endmethod
        
        // 꼭지점 모두 비우기
        method Clear takes nothing returns nothing
            set count = 0
        endmethod
        
        // 현재 다각형이 해당 좌표에 포함되어 있는지 확인
        method IsPointInside takes real x, real y returns boolean
            local integer wn = 0
            local integer start = 0
            local integer end
            
            loop
                exitwhen start >= count
                set end = ModuloInteger(start + 1, count)
                if py[start] <= y then
                    if py[end] > y and (px[end] - px[start]) * (y - py[start]) - (x - px[start]) * (py[end] - py[start]) > 0 then
                        set wn = wn + 1
                    endif
                else
                    if py[end] <= y and (px[end] - px[start]) * (y - py[start]) - (x - px[start]) * (py[end] - py[start]) < 0 then
                        set wn = wn - 1
                    endif
                endif
                set start = start + 1
            endloop
            
            return wn != 0
        endmethod
    endstruct
endlibrary
//[출처] 다각형 내부의 지점 판별하기 (+24.09.16 충돌크기 고려 적용) (워크래프트3 리포지드 유즈맵 포럼 [W3UMF]) | 작성자 Howww
/*
    local polygon p = polygon.create()
    call p.AddPoint(0.0, 0.0)
    call p.AddPoint(100.0, 0.0)
    call p.AddPoint(100.0, 100.0)
    call p.AddPoint(0.0, 100.0)
    if p.IsPointInside(50.0, 50.0) then
        call BJDebugMsg("포함")
    else
        call BJDebugMsg("미포함")
    endif
    call p.destroy()
*/