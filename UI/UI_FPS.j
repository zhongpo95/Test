library FPS initializer Init requires UIItem, Emoji
function FPS takes nothing returns nothing
    local real r1
    local real r2
    local real r3
    local integer NE
    local real X
    local real Y
    
    if F_ItemClickNumber != 200 and PickUpOn == true then
        set r1 = I2R(DzGetMouseXRelative()) / I2R(DzGetWindowWidth()) * 0.8 + 0.0025
        set r2 = I2R(DzGetWindowHeight() - 42 - DzGetMouseYRelative()) / I2R(DzGetWindowHeight() - 42) * 0.6
        call DzFrameSetAbsolutePoint(F_PickUp, JN_FRAMEPOINT_CENTER, r1, r2)
    elseif not (F_ItemClickNumber != 200 and PickUpOn == true) then
        set PickUpOn = false
        call DzFrameShow(F_PickUp, false)
        //call DzFrameSetUpdateCallback("")
        //이모지
        if EmojiOn == true then
            set X = I2R(DzGetMouseX()-DzGetWindowX())/(I2R(DzGetWindowWidth())/.8)+0
            set Y = I2R(DzGetWindowHeight()+DzGetWindowY()-DzGetMouseY())/(I2R(DzGetWindowHeight())/.6)+0
            //원 좌표로부터 떨어짐
            if RAbsBJ(X-NowX)>=.01 or RAbsBJ(Y-NowY)>=.01 then
                set r3 = Atan2BJ(Y-NowY, X-NowX)
                set r3 = ModuloReal(r3+315.,360.)
                set NE = R2I(r3/90.) + 1
            else
                //중앙
                set NE = 0
            endif
            //기존이랑 선택된게 다를경우 선택 이미지표시
            if NowEmoji != NE then
                set NowEmoji = NE
                call DzFrameSetTexture(EmojiFrame[1],"Expression_Up.blp",0)
                call DzFrameSetTexture(EmojiFrame[2],"Expression_Left.blp",0)
                call DzFrameSetTexture(EmojiFrame[3],"Expression_Down.blp",0)
                call DzFrameSetTexture(EmojiFrame[4],"Expression_Right.blp",0)
                if NowEmoji != 0 then
                    if NowEmoji == 1 then
                        call DzFrameSetTexture(EmojiFrame[NowEmoji],"Expression_Up_Select.blp",0)
                    elseif NowEmoji == 2 then
                        call DzFrameSetTexture(EmojiFrame[NowEmoji],"Expression_Left_Select.blp",0)
                    elseif NowEmoji == 3 then
                        call DzFrameSetTexture(EmojiFrame[NowEmoji],"Expression_Down_Select.blp",0)
                    elseif NowEmoji == 4 then
                        call DzFrameSetTexture(EmojiFrame[NowEmoji],"Expression_Right_Select.blp",0)
                    endif
                endif
            endif
        endif
    endif
endfunction

private function Main takes nothing returns nothing
    if GetLocalPlayer()==GetLocalPlayer() then
        call DzFrameSetUpdateCallbackByCode(function FPS)
    endif
endfunction

private function Init takes nothing returns nothing
    local trigger t = CreateTrigger()
    call TriggerRegisterTimerEventSingle(t, 10.00)
    call TriggerAddAction(t, function Main)
    set t = null
endfunction
endlibrary