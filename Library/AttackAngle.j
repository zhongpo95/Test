library AttackAngle
    
    function AngleTrue takes real A,real A2,real R returns boolean
        local boolean n
       if RAbsBJ(A - A2) > 180 then
            if ((A - A2) < 0 ) and A2 > 0 and A > 0 then
                //(A - A2)가 음수인데 A와 A2가 양수
                set A = A + 360
            else
                if A < 0 then
                    set A = A +360
                endif
                if A2 < 0 then
                    set A2 = A2 +360
                endif
            endif
       endif
       
       call BJDebugMsg( "A : " + R2S( A ) )
       call BJDebugMsg( "A2 : " + R2S( A2 ) )
       if A - A2 >= R*-1 then
            call BJDebugMsg("A-A2 >= R*-1 = true")
        else
            call BJDebugMsg("A-A2 >= R*-1 = false")
       endif
       if A-A2 <= R*1 then
        call BJDebugMsg("A-A2 <= R*1 = true")
        else
        call BJDebugMsg("A-A2 <= R*1 = false")
       endif

       if A - A2 >= R*-1 and A-A2 <= R*1 then
           set n  = true
       else
           set n = false
       endif 
       return n
   endfunction

    function BackTrue takes real A,real A2 returns boolean
        return AngleTrue(A,A2,45)
    endfunction
    
    function HeadTrue takes real A,real A2 returns boolean
        local real r = A2+180
        if r > 360 then
            set r = r - 360
        endif
        return AngleTrue(A,r,45)
    endfunction
    
    function HeadTag takes unit u returns nothing
        local texttag ttag
        set ttag=CreateTextTag()
        call SetTextTagText(ttag, "헤드 어택", 0.020)
        call SetTextTagPos(ttag, GetWidgetX(u), GetWidgetY(u), 100)
        call SetTextTagColor(ttag, 255, 185, 0, 229)
        call SetTextTagVelocityBJ(ttag, 60.00, GetRandomReal(60.00, 120.00))
        call SetTextTagFadepoint(ttag, 0.6)
        call SetTextTagLifespan(ttag, 0.8)
        call SetTextTagPermanent(ttag, false)
        call SetTextTagVisibility(ttag, true)
    endfunction
    
    function BackTag takes unit u returns nothing
        local texttag ttag
        set ttag=CreateTextTag()
        call SetTextTagText(ttag, "백 어택", 0.020)
        call SetTextTagPos(ttag, GetWidgetX(GetEnumUnit()), GetWidgetY(GetEnumUnit()), 100)
        call SetTextTagColor(ttag, 255, 185, 0, 229)
        call SetTextTagVelocityBJ(ttag, 60.00, GetRandomReal(60.00, 120.00))
        call SetTextTagFadepoint(ttag, 0.6)
        call SetTextTagLifespan(ttag, 0.8)
        call SetTextTagPermanent(ttag, false)
        call SetTextTagVisibility(ttag, true)
    endfunction
    
    function CounterTag takes unit u returns nothing
        local texttag ttag
        set ttag=CreateTextTag()
        call SetTextTagText(ttag, "카운터 어택", 0.020)
        call SetTextTagPos(ttag, GetWidgetX(GetEnumUnit()), GetWidgetY(GetEnumUnit()), 100)
        call SetTextTagColor(ttag, 255, 185, 0, 229)
        call SetTextTagVelocityBJ(ttag, 60.00, GetRandomReal(60.00, 120.00))
        call SetTextTagFadepoint(ttag, 0.6)
        call SetTextTagLifespan(ttag, 0.8)
        call SetTextTagPermanent(ttag, false)
        call SetTextTagVisibility(ttag, true)
        call UnitRemoveAbility(GetEnumUnit(), 'A00V')
    endfunction
    endlibrary