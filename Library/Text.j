library Text
    function TextTag takes string s, unit u, real size, real red, real green, real blue, real textlife returns texttag
        set bj_lastCreatedTextTag = CreateTextTag()
        call SetTextTagText(bj_lastCreatedTextTag, s, size*0.023/10)
        call SetTextTagPos(bj_lastCreatedTextTag, GetUnitX(u),GetUnitY(u), 0)
        call SetTextTagColor(bj_lastCreatedTextTag, R2I(red*I2R(255)*0.01),R2I(green*I2R(255)*0.01), R2I(blue*I2R(255)*0.01), 255)
        call SetTextTagVelocity(bj_lastCreatedTextTag, 64*0.071/128*Cos(90*bj_DEGTORAD),64*0.071/128*Sin(90*bj_DEGTORAD) )
        call SetTextTagPermanent( bj_lastCreatedTextTag, false )
        call SetTextTagLifespan( bj_lastCreatedTextTag, textlife )
        call SetTextTagVisibility(bj_lastCreatedTextTag,false)
        set bj_forLoopAIndex = 0
        loop
            exitwhen bj_forLoopAIndex == 14
            if IsUnitVisible(u,Player(bj_forLoopAIndex)) == true then
                if GetLocalPlayer() == Player(bj_forLoopAIndex) then
                    call SetTextTagVisibility(bj_lastCreatedTextTag,true)
                endif
            endif
            set bj_forLoopAIndex = bj_forLoopAIndex+1
        endloop
    
        return bj_lastCreatedTextTag
    endfunction
    endlibrary