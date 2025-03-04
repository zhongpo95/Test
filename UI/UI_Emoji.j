library Emoji initializer init requires FrameCount

    globals
        integer array EmojiNumber
        string array EmojiBlpStr
        string array EmojiMdxStr
        integer NowEmoji = 0
        real NowX
        real NowY
        integer EmojiFrameMain
        integer array EmojiFrame
        private location EmojiLocation
        private integer array NowEmojiSt
        boolean EmojiOn = false
    endglobals

    struct EmojiST
        unit caster
        integer pid
        effect e
        real time
    endstruct

    //이모지 갱신
    private function EmojiShow2 takes nothing returns nothing
        local tick t = tick.getExpired()
        local EmojiST st = t.data


        //한번더 이모지를 누르지않고 남은시간이 있으면 따라움직임
        if st.time > 0. and NowEmojiSt[st.pid] == t.data then
            set st.time = st.time - 0.03
            call MoveLocation(EmojiLocation,GetWidgetX(st.caster),GetWidgetY(st.caster))
            call EXSetEffectXY(st.e,GetWidgetX(st.caster),GetWidgetY(st.caster))
            call EXSetEffectZ(st.e,GetLocationZ(EmojiLocation)+(GetUnitFlyHeight(MainUnit[st.pid])+256.))
        //파괴
        else
            //한번더 이모지를 눌렀으면 이펙트 날림
            if NowEmojiSt[st.pid]!=t.data then
                call EXSetEffectZ(st.e,9999.)
            endif
            call DestroyEffect(st.e)
            set st.caster = null
            set st.pid = 0
            set st.time = 0
            set st.e = null
            call st.destroy()
            call t.destroy()
        endif
    endfunction

    //이모지를 보여줌
    private function EmojiShow takes nothing returns nothing
        local tick t = tick.create(0)
        local EmojiST st = EmojiST.create()

        set st.pid = GetPlayerId(DzGetTriggerSyncPlayer())
        set st.caster = MainUnit[st.pid]
        set st.e = AddSpecialEffect( EmojiMdxStr[S2I(DzGetTriggerSyncData())], GetWidgetX(st.caster), GetWidgetY(st.caster))
        set st.time = 5.
        call MoveLocation(EmojiLocation,GetWidgetX(st.caster), GetWidgetY(st.caster))
        call EXSetEffectZ(st.e,GetLocationZ(EmojiLocation)+(GetUnitFlyHeight(MainUnit[st.pid])+256.))
        set t.data = st
        set NowEmojiSt[st.pid] = st

        call t.start(0.03, true, function EmojiShow2)
    endfunction

    //t를 땜
    function TKey2 takes nothing returns nothing
        call DzFrameShow(EmojiFrameMain,false)
        set EmojiOn = false

        if NowEmoji != 0 then
            call DzSyncData("Img",I2S(NowEmoji))
        endif
    endfunction

    //t를 누름
    function TKey takes nothing returns nothing
        if not EmojiOn then
            set EmojiOn = true
            set NowX = I2R(DzGetMouseX()-DzGetWindowX())/(I2R(DzGetWindowWidth())/.8)+0
            set NowY = I2R(DzGetWindowHeight()+DzGetWindowY()-DzGetMouseY())/(I2R(DzGetWindowHeight())/.6)+0
            call DzFrameClearAllPoints(EmojiFrameMain)
            call DzFrameSetAbsolutePoint(EmojiFrameMain,4,NowX,NowY)
            call DzFrameSetTexture(EmojiFrame[1],"Expression_Up.blp",0)
            call DzFrameSetTexture(EmojiFrame[2],"Expression_Left.blp",0)
            call DzFrameSetTexture(EmojiFrame[3],"Expression_Down.blp",0)
            call DzFrameSetTexture(EmojiFrame[4],"Expression_Right.blp",0)
            call DzFrameSetTexture(EmojiFrame[5],EmojiBlpStr[1],0)
            call DzFrameSetTexture(EmojiFrame[6],EmojiBlpStr[2],0)
            call DzFrameSetTexture(EmojiFrame[7],EmojiBlpStr[3],0)
            call DzFrameSetTexture(EmojiFrame[8],EmojiBlpStr[4],0)
            call DzFrameShow(EmojiFrameMain,true)
        endif
    endfunction

    private function Main takes nothing returns nothing
        local trigger t
        set EmojiFrameMain = DzCreateFrameByTagName("BACKDROP","name",DzGetGameUI(),"template", FrameCount())
        call DzFrameSetTexture(EmojiFrameMain,"Expression_Point.blp",0)
        call DzFrameSetSize(EmojiFrameMain,0.065,0.065)
        call DzFrameShow(EmojiFrameMain,false)
        set EmojiFrame[1] = DzCreateFrameByTagName("BACKDROP","name",EmojiFrameMain,"template", FrameCount())
        call DzFrameSetPoint(EmojiFrame[1],7,EmojiFrameMain,1,0,-.0325)
        call DzFrameSetSize(EmojiFrame[1],.14,.07)
        set EmojiFrame[2] = DzCreateFrameByTagName("BACKDROP","name",EmojiFrameMain,"template", FrameCount())
        call DzFrameSetPoint(EmojiFrame[2],5,EmojiFrameMain,3,.0325,0)
        call DzFrameSetSize(EmojiFrame[2],.07,.14)
        set EmojiFrame[3] = DzCreateFrameByTagName("BACKDROP","name",EmojiFrameMain,"template", FrameCount())
        call DzFrameSetPoint(EmojiFrame[3],1,EmojiFrameMain,7,0,.0325)
        call DzFrameSetSize(EmojiFrame[3],.14,.07)
        set EmojiFrame[4] = DzCreateFrameByTagName("BACKDROP","name",EmojiFrameMain,"template", FrameCount())
        call DzFrameSetPoint(EmojiFrame[4],3,EmojiFrameMain,5,-.0325,0.)
        call DzFrameSetSize(EmojiFrame[4],.07,.14)
        set EmojiFrame[5] = DzCreateFrameByTagName("BACKDROP","name",EmojiFrameMain,"template", FrameCount())
        call DzFrameSetSize(EmojiFrame[5],.05,.05)
        call DzFrameSetPoint(EmojiFrame[5],7,EmojiFrameMain,1,0,-.015)
        set EmojiFrame[6] = DzCreateFrameByTagName("BACKDROP","name",EmojiFrameMain,"template", FrameCount())
        call DzFrameSetSize(EmojiFrame[6],.05,.05)
        call DzFrameSetPoint(EmojiFrame[6],5,EmojiFrameMain,3,.015,0)
        set EmojiFrame[7] = DzCreateFrameByTagName("BACKDROP","name",EmojiFrameMain,"template", FrameCount())
        call DzFrameSetSize(EmojiFrame[7],.05,.05)
        call DzFrameSetPoint(EmojiFrame[7],1,EmojiFrameMain,7,0,.015)
        set EmojiFrame[8] = DzCreateFrameByTagName("BACKDROP","name",EmojiFrameMain,"template", FrameCount())
        call DzFrameSetSize(EmojiFrame[8],.05,.05)
        call DzFrameSetPoint(EmojiFrame[8],3,EmojiFrameMain,5,-.015,0.)

        if GetLocalPlayer()==GetLocalPlayer() then
            call DzTriggerRegisterKeyEventByCode(null,JN_OSKEY_T,1,false,function TKey)
            call DzTriggerRegisterKeyEventByCode(null,JN_OSKEY_T,0,false,function TKey2)
        endif
        
        set EmojiBlpStr[1] = "ExpressionPic_Miku1_Up.blp"
        set EmojiBlpStr[2] = "ExpressionPic_Miku1_Left.blp"
        set EmojiBlpStr[3] = "ExpressionPic_Miku1_Down.blp"
        set EmojiBlpStr[4] = "ExpressionPic_Miku1_Right.blp"
        set EmojiMdxStr[1] = "ExpressionPic_Miku1_Up.mdx"
        set EmojiMdxStr[2] = "ExpressionPic_Miku1_Left.mdx"
        set EmojiMdxStr[3] = "ExpressionPic_Miku1_Down.mdx"
        set EmojiMdxStr[4] = "ExpressionPic_Miku1_Right.mdx"

        set t = CreateTrigger()
        call DzTriggerRegisterSyncData(t,"Img",false)
        call TriggerAddCondition(t,Condition(function EmojiShow))
        set t = null
        
        set EmojiLocation = Location(0.,0.)
    endfunction
    
    private function init takes nothing returns nothing
        local trigger t

        set t = CreateTrigger()
        call TriggerRegisterTimerEventSingle(t, 0.02)
        call TriggerAddAction(t, function Main)
        set t = null
    endfunction
endlibrary