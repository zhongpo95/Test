library Filter requires TriggerSleepActionByTimer

function CinematicFilter takes player p,real duration,blendmode bmode,string tex,real red0,real green0,real blue0,real trans0,real red1,real green1,real blue1,real trans1 returns nothing
    local integer pid = GetPlayerId(p)
    if ( GetLocalPlayer() == p ) then
        call SetCineFilterTexture(tex)
        call SetCineFilterBlendMode(bmode)
        call SetCineFilterTexMapFlags(TEXMAP_FLAG_NONE)
        call SetCineFilterStartUV(0, 0, 1, 1)
        call SetCineFilterEndUV(0, 0, 1, 1)
        call SetCineFilterStartColor(PercentTo255(red0), PercentTo255(green0), PercentTo255(blue0), PercentTo255(100 - trans0))
        call SetCineFilterEndColor(PercentTo255(red1), PercentTo255(green1), PercentTo255(blue1), PercentTo255(100 - trans1))
        call SetCineFilterDuration(duration)
        call DisplayCineFilter(true)
    endif
        
    call TriggerSleepActionByTimer(duration)
    
    if ( GetLocalPlayer() == p ) then
        call DisplayCineFilter(false)
    endif
endfunction

function CinematicFilter2 takes player p,blendmode bmode,string tex,real red0,real green0,real blue0,real trans0,real red1,real green1,real blue1,real trans1 returns nothing
    local integer pid = GetPlayerId(p)
    if ( GetLocalPlayer() == p ) then
        call SetCineFilterTexture(tex)
        call SetCineFilterBlendMode(bmode)
        call SetCineFilterTexMapFlags(TEXMAP_FLAG_NONE)
        call SetCineFilterStartUV(0, 0, 1, 1)
        call SetCineFilterEndUV(0, 0, 1, 1)
        call SetCineFilterStartColor(PercentTo255(red0), PercentTo255(green0), PercentTo255(blue0), PercentTo255(100 - trans0))
        call SetCineFilterEndColor(PercentTo255(red1), PercentTo255(green1), PercentTo255(blue1), PercentTo255(100 - trans1))
        call SetCineFilterDuration(0)
        call DisplayCineFilter(true)
    endif
endfunction

endlibrary