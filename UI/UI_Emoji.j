library Emoji initializer init requires FrameCount, UIInputGate

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

        // 오른쪽 아래 이모티콘 알림 카드: 동기화된 이모티콘을 모든 플레이어 화면에 플레이어 색 카드로 쌓는다
        private constant integer FEED_MAX = 4
        private constant real FEED_LIFE = 4.0
        private constant real FEED_FADE_OUT = 0.35
        private constant real FEED_FADE_IN = 0.12
        private constant real FEED_TICK = 0.02
        // 정사각형 텍스처가 16:9 화면에서 찌그러지지 않도록 가로/세로를 따로 둔다(스킬 칸과 같은 비율)
        // 텍스처 가장자리 15%는 비어 있고(오른쪽은 꼬리) 몸통은 가운데 70% 정사각형이다
        private constant real FEED_W = 0.0513
        private constant real FEED_H = 0.066
        private constant real FEED_GAP = 0.0
        // 스킬 칸 격자(오른쪽 끝 약 0.734) 오른쪽. 오른쪽 아래 구석(y 0.14 아래)은 비워 두고 그 위부터 쌓는다
        private constant real FEED_RIGHT = 0.792
        private constant real FEED_BOTTOM = 0.148
        private integer array FeedCard
        private integer array FeedIcon
        private boolean array FeedUsed
        private real array FeedLeft
        private real array FeedY
        // FeedOrder[0] 이 가장 새 카드(맨 아래), 위로 갈수록 오래된 카드
        private integer array FeedOrder
        private integer FeedCount = 0
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

    // 알림 카드 위치·투명도 갱신, 시간이 다 된 카드 정리
    private function FeedTick takes nothing returns nothing
        local integer i = 0
        local integer j = 0
        local integer c
        local real target
        local real age
        local integer alpha
        if FeedCount == 0 then
            return
        endif
        loop
            exitwhen i >= FeedCount
            set c = FeedOrder[i]
            set FeedLeft[c] = FeedLeft[c] - FEED_TICK
            set target = FEED_BOTTOM + I2R(i) * (FEED_H + FEED_GAP)
            set FeedY[c] = FeedY[c] + (target - FeedY[c]) * 0.3
            if RAbsBJ(target - FeedY[c]) < 0.0004 then
                set FeedY[c] = target
            endif
            set alpha = 255
            set age = FEED_LIFE - FeedLeft[c]
            if age < FEED_FADE_IN then
                set alpha = R2I(255. * age / FEED_FADE_IN)
            endif
            if FeedLeft[c] < FEED_FADE_OUT then
                set alpha = R2I(255. * RMaxBJ(FeedLeft[c], 0.) / FEED_FADE_OUT)
            endif
            call DzFrameClearAllPoints(FeedCard[c])
            call DzFrameSetAbsolutePoint(FeedCard[c], JN_FRAMEPOINT_BOTTOMRIGHT, FEED_RIGHT, FeedY[c])
            call DzFrameSetAlpha(FeedCard[c], alpha)
            call DzFrameSetAlpha(FeedIcon[c], alpha)
            set i = i + 1
        endloop
        // 시간이 다 된 카드를 빼고 순서를 당긴다
        set i = 0
        loop
            exitwhen i >= FeedCount
            set c = FeedOrder[i]
            if FeedLeft[c] <= 0. then
                call DzFrameShow(FeedCard[c], false)
                set FeedUsed[c] = false
            else
                set FeedOrder[j] = c
                set j = j + 1
            endif
            set i = i + 1
        endloop
        set FeedCount = j
    endfunction

    // 동기화 처리 안(모든 클라이언트)에서 부른다: 맨 아래에 새 카드를 넣고 기존 카드를 한 칸씩 위로 민다
    private function FeedPush takes integer pid, integer emoji returns nothing
        local integer c = 0
        local integer i
        local integer color
        if emoji < 1 or emoji > 4 then
            return
        endif
        if FeedCount >= FEED_MAX then
            // 꽉 찼으면 가장 오래된 카드를 다시 쓴다
            set FeedCount = FEED_MAX - 1
            set c = FeedOrder[FeedCount]
        else
            loop
                exitwhen not FeedUsed[c]
                set c = c + 1
            endloop
        endif
        set i = FeedCount
        loop
            exitwhen i <= 0
            set FeedOrder[i] = FeedOrder[i - 1]
            set i = i - 1
        endloop
        set FeedOrder[0] = c
        set FeedCount = FeedCount + 1
        set FeedUsed[c] = true
        set FeedLeft[c] = FEED_LIFE
        set FeedY[c] = FEED_BOTTOM - FEED_H * 0.5

        // 플레이어 색은 1~4번 슬롯에 빨강 파랑 청록 보라로 고정되어 있다
        set color = pid
        if color < 0 or color > 3 then
            set color = 0
        endif
        call DzFrameSetTexture(FeedCard[c], "war3mapImported\\EmojiCard_0" + I2S(color) + ".blp", 0)
        call DzFrameSetTexture(FeedIcon[c], EmojiBlpStr[emoji], 0)
        call DzFrameSetAlpha(FeedCard[c], 0)
        call DzFrameSetAlpha(FeedIcon[c], 0)
        call DzFrameClearAllPoints(FeedCard[c])
        call DzFrameSetAbsolutePoint(FeedCard[c], JN_FRAMEPOINT_BOTTOMRIGHT, FEED_RIGHT, FeedY[c])
        call DzFrameShow(FeedCard[c], true)
    endfunction

    //이모지를 보여줌
    private function EmojiShow takes nothing returns nothing
        local tick t = tick.create(0)
        local EmojiST st = EmojiST.create()

        call FeedPush(GetPlayerId(DzGetTriggerSyncPlayer()), S2I(DzGetTriggerSyncData()))
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
        if not PickCheck[GetPlayerId(GetLocalPlayer())] then
            return
        endif
        call DzFrameShow(EmojiFrameMain,false)
        set EmojiOn = false

        if NowEmoji != 0 then
            call DzSyncData("Img",I2S(NowEmoji))
        endif
    endfunction

    //t를 누름
    function TKey takes nothing returns nothing
        if not PickCheck[GetPlayerId(GetLocalPlayer())] then
            return
        endif
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

    // 알림 카드 프레임은 모든 클라이언트에서 같은 순서로 만든다
    private function FeedCreate takes nothing returns nothing
        local integer i = 0
        loop
            exitwhen i >= FEED_MAX
            set FeedCard[i] = DzCreateFrameByTagName("BACKDROP", "name", GetGameplayUI(), "template", FrameCount())
            call DzFrameSetTexture(FeedCard[i], "war3mapImported\\EmojiCard_00.blp", 0)
            call DzFrameSetSize(FeedCard[i], FEED_W, FEED_H)
            call DzFrameSetAbsolutePoint(FeedCard[i], JN_FRAMEPOINT_BOTTOMRIGHT, FEED_RIGHT, FEED_BOTTOM)
            set FeedIcon[i] = DzCreateFrameByTagName("BACKDROP", "name", FeedCard[i], "template", FrameCount())
            // 말풍선 몸통이 텍스처 한가운데라 이모티콘도 카드 가운데에 그대로 얹는다
            // 참고 게임처럼 이모티콘이 판보다 살짝 커서 가장자리를 조금 넘는다
            call DzFrameSetSize(FeedIcon[i], FEED_W * 0.76, FEED_H * 0.76)
            call DzFrameSetPoint(FeedIcon[i], JN_FRAMEPOINT_CENTER, FeedCard[i], JN_FRAMEPOINT_CENTER, 0., 0.)
            call DzFrameShow(FeedCard[i], false)
            set FeedUsed[i] = false
            set i = i + 1
        endloop
        call TimerStart(CreateTimer(), FEED_TICK, true, function FeedTick)
    endfunction

    private function Main takes nothing returns nothing
        local trigger t
        set EmojiFrameMain = DzCreateFrameByTagName("BACKDROP","name",GetGameplayUI(),"template", FrameCount())
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

        
        set EmojiBlpStr[1] = "ExpressionPic_Miku1_Up.blp"
        set EmojiBlpStr[2] = "ExpressionPic_Miku1_Left.blp"
        set EmojiBlpStr[3] = "ExpressionPic_Miku1_Down.blp"
        set EmojiBlpStr[4] = "ExpressionPic_Miku1_Right.blp"
        set EmojiMdxStr[1] = "ExpressionPic_Miku1_Up.mdx"
        set EmojiMdxStr[2] = "ExpressionPic_Miku1_Left.mdx"
        set EmojiMdxStr[3] = "ExpressionPic_Miku1_Down.mdx"
        set EmojiMdxStr[4] = "ExpressionPic_Miku1_Right.mdx"

        call FeedCreate()

        set t = CreateTrigger()
        call DzTriggerRegisterSyncData(t,"Img",false)
        call TriggerAddCondition(t,Condition(function EmojiShow))
        set t = null
        
        set EmojiLocation = Location(0.,0.)
    endfunction
    
    private function BindInput takes nothing returns boolean
        if EmojiFrameMain == 0 then
            return false
        endif
        call DzTriggerRegisterKeyEventByCode(null,JN_OSKEY_T,1,false,function TKey)
        call DzTriggerRegisterKeyEventByCode(null,JN_OSKEY_T,0,false,function TKey2)
        return true
    endfunction

    private function init takes nothing returns nothing
        local trigger t

        set t = CreateTrigger()
        call TriggerRegisterTimerEventSingle(t, 0.02)
        call TriggerAddAction(t, function Main)
        set t = null
        call UIInputAfterPick(function BindInput)
    endfunction
endlibrary
