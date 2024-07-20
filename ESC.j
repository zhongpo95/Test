scope ESC initializer init
    globals
        //integer i = 0
        //string s = "12;1;1;2;3;45;1;3;45;6;1;각인A32;각인A수치99999;123123;"
        real AAA = 0
        string s = "1"
        integer frame1 = 0
        integer frame2 = 0
        integer frame3 = 0
        integer frame4 = 0

        integer frame5 = 0
        integer frame6 = 0
    endglobals

    private function ESCAction2 takes nothing returns nothing
        /*
        call BJDebugMsg("ESC")

        set i = i + 1

        if i == 1 then
            call BJDebugMsg("이전가격 : "+I2S(Price[1]))
            call MarketDataDownload(GetPlayerId(GetTriggerPlayer()))
            call BJDebugMsg(I2S(Price[1]))
        elseif i == 2 then
            set Price[1] = Price[1] + 1
            call MarketDataUpload(GetPlayerId(GetTriggerPlayer()),1,Price[1])
            call BJDebugMsg("Price[1] : "+I2S(Price[1]))
            set i = 0
        endif
        */
    endfunction
    
    private function ESCAction4 takes nothing returns nothing
        /*
        local integer i = 0

        set s = "7;"
        set s = SetItemGetItemCombatStats(s, GetRandomInt(1,3))
        set s = SetItemQuality(s, (Quality.pick(false)-1) )
        call additem(Player(0), s)
        set s = "8;"
        set s = SetItemGetItemCombatStats(s, GetRandomInt(1,3))
        set s = SetItemQuality(s, (Quality.pick(false)-1) )
        call additem(Player(0), s)
        set s = "10;"
        set s = SetItemGetItemCombatStats(s, GetRandomInt(1,3))
        set s = SetItemQuality(s, (Quality.pick(false)-1) )
        call additem(Player(0), s)
        //call BJDebugMsg(JNStringRegex(s, "품질\\d+;", 0))
        //set s = JNStringReplace(s, JNStringRegex(s, "품질\\d+;", 0), "품질22;")
        //call BJDebugMsg("바꾼후 : "+s)
        //call BJDebugMsg("ESC")
        //call TodayQuestPlus(0)
        */
    endfunction

    private function ESCAction5 takes nothing returns nothing
        //set AAA = S2R(s)
        //set AAA = AAA + AAA
        //set s = R2SW(AAA,1,0)
        //set s = SubString(s,0,StringLength(s)-2)
        //call DzFrameSetText(F_EnchantUpText, s )
        //call BJDebugMsg(s) 
    endfunction

    private function EffectFunction takes nothing returns nothing
        //set AAA = S2R(s)
        //set AAA = AAA + AAA
        //set s = R2SW(AAA,1,0)
        //set s = SubString(s,0,StringLength(s)-2)
        //call DzFrameSetText(F_EnchantUpText, s )
        //call BJDebugMsg(s) 
        call Sound3D(MainUnit[0],'A02B')
    endfunction

    private function ESCAction takes nothing returns nothing
        local tick t 
        set AAA = AAA + 1
        if AAA == 1 then
            set frame1=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", 0)
            call DzFrameSetAbsolutePoint(frame1,JN_FRAMEPOINT_BOTTOMLEFT,0,0)
            set frame2=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", 0)
            call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_BOTTOMLEFT,0,0)
            set frame3=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", 0)
            call DzFrameSetAbsolutePoint(frame3,JN_FRAMEPOINT_BOTTOMLEFT,0,0)
            set frame4=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", 0)
            call DzFrameSetAbsolutePoint(frame4,JN_FRAMEPOINT_BOTTOMLEFT,0,0)

            set frame5=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", 0)
            call DzFrameSetAbsolutePoint(frame5,JN_FRAMEPOINT_BOTTOMLEFT,0.4,0.3)
        else
            set t = tick.create(0)
            call DzFrameSetModel(frame1, "Chen_Cut1.mdx", 0, 0)
            call DzFrameSetModel(frame2, "Mika_Cut2.mdx", 0, 0)
            call DzFrameSetModel(frame3, "Chen_Cut3.mdx", 0, 0)
            call DzFrameSetModel(frame4, "Cut4.mdx", 0, 0)

            call DzFrameSetModel(frame5, "Sacred Exile.mdx", 0, 0)
            call Sound3D(MainUnit[0],'A02A')
            call Sound3D(MainUnit[0],'A022')
            call Sound3D(MainUnit[0],'A02C')
            call t.start( 0.1, false, function EffectFunction ) 
        endif
    endfunction

    private function init takes nothing returns nothing
        local trigger t=CreateTrigger()
        //esc버튼
        set t = CreateTrigger()
        call TriggerRegisterPlayerEvent(t, Player(0), EVENT_PLAYER_END_CINEMATIC)
        call TriggerAddAction( t, function ESCAction )
        set t = null
        set Price[1] = 10000
    endfunction

endscope