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
        integer frame7 = 0
        integer frame8 = 0
        integer frame9 = 0
        integer frame10 = 0
        integer frame11 = 0
        integer frame12 = 0
        integer frame13 = 0
        integer frame14 = 0
        integer frame15 = 0
        integer frame16 = 0
        integer frame17 = 0
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
        //레이지소리
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
            call DzFrameSetAbsolutePoint(frame5,JN_FRAMEPOINT_BOTTOMLEFT,0.2,0.5)
            set frame6=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", 0)
            call DzFrameSetAbsolutePoint(frame6,JN_FRAMEPOINT_BOTTOMLEFT,0.2,0.3)
            set frame7=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", 0)
            call DzFrameSetAbsolutePoint(frame7,JN_FRAMEPOINT_BOTTOMLEFT,0.2,0.1)

            set frame8=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", 0)
            call DzFrameSetAbsolutePoint(frame8,JN_FRAMEPOINT_BOTTOMLEFT,0.4,0.5)
            set frame9=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", 0)
            call DzFrameSetAbsolutePoint(frame9,JN_FRAMEPOINT_BOTTOMLEFT,0.4,0.3)
            set frame10=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", 0)
            call DzFrameSetAbsolutePoint(frame10,JN_FRAMEPOINT_BOTTOMLEFT,0.4,0.1)

            set frame11=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", 0)
            call DzFrameSetAbsolutePoint(frame11,JN_FRAMEPOINT_BOTTOMLEFT,0.6,0.5)
            set frame12=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", 0)
            call DzFrameSetAbsolutePoint(frame12,JN_FRAMEPOINT_BOTTOMLEFT,0.6,0.3)
            set frame13=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", 0)
            call DzFrameSetAbsolutePoint(frame13,JN_FRAMEPOINT_BOTTOMLEFT,0.6,0.1)

            set frame14=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", 0)
            call DzFrameSetAbsolutePoint(frame14,JN_FRAMEPOINT_BOTTOMLEFT,0.8,0.5)
            set frame15=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", 0)
            call DzFrameSetAbsolutePoint(frame15,JN_FRAMEPOINT_BOTTOMLEFT,0.8,0.3)
            set frame16=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", 0)
            call DzFrameSetAbsolutePoint(frame16,JN_FRAMEPOINT_BOTTOMLEFT,0.8,0.1)
            
            
        else
            set t = tick.create(0)
            call DzFrameSetModel(frame1, "Chen_Cut1.mdx", 0, 0)
            call DzFrameSetModel(frame2, "Mika_Cut2.mdx", 0, 0)
            call DzFrameSetModel(frame3, "Chen_Cut3.mdx", 0, 0)
            call DzFrameSetModel(frame4, "Cut4.mdx", 0, 0)

            //call DzFrameSetModel(frame5, "Sacred Exile.mdx", 0, 0)

            call DzFrameSetModel(frame5, "Light_Hit-2-Red.mdx", 0, 0)
            call DzFrameSetModel(frame6, "Light_Hit-2-Red.mdx", 0, 0)
            call DzFrameSetModel(frame7, "Light_Hit-2-Red.mdx", 0, 0)
            call DzFrameSetModel(frame8, "Light_Hit-2-Red.mdx", 0, 0)
            call DzFrameSetModel(frame9, "Light_Hit-2-Red.mdx", 0, 0)
            call DzFrameSetModel(frame10, "Light_Hit-2-Red.mdx", 0, 0)
            call DzFrameSetModel(frame11, "Light_Hit-2-Red.mdx", 0, 0)
            call DzFrameSetModel(frame12, "Light_Hit-2-Red.mdx", 0, 0)
            call DzFrameSetModel(frame13, "Light_Hit-2-Red.mdx", 0, 0)
            call DzFrameSetModel(frame14, "Light_Hit-2-Red.mdx", 0, 0)
            call DzFrameSetModel(frame15, "Light_Hit-2-Red.mdx", 0, 0)
            call DzFrameSetModel(frame16, "Light_Hit-2-Red.mdx", 0, 0)

            call Sound3D(MainUnit[0],'A02A')
            call Sound3D(MainUnit[0],'A022')
            call Sound3D(MainUnit[0],'A02C')
            call Sound3D(MainUnit[0],'A02D')

            call t.start( 0.1, false, function EffectFunction )
        endif
    endfunction

    private function ESCAction1233 takes nothing returns nothing
        local tick t 
        set AAA = AAA + 1
        if AAA == 1 then
            set frame4=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", 0)
            call DzFrameSetAbsolutePoint(frame4,JN_FRAMEPOINT_BOTTOMLEFT,0.4,0.15)

            set frame5=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", 0)
            call DzFrameSetAbsolutePoint(frame5,JN_FRAMEPOINT_BOTTOMLEFT,0.4,0.15)
        
            set frame1=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "template", 0)
            call DzFrameSetTexture(frame1, "V.blp", 0)
            call DzFrameSetSize(frame1, 0.030, 0.030)
            call DzFrameSetAbsolutePoint(frame1, JN_FRAMEPOINT_CENTER, 0.4, 0.15)
            call DzFrameShow(frame1, false)

            set frame3=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", 0)
            call DzFrameSetAbsolutePoint(frame3,JN_FRAMEPOINT_BOTTOMLEFT,0.4,0.15)

        else
            //call Sound3D(MainUnit[0],'A02B')
            //call DzFrameSetModel(frame4, "VFX_HolyLight.mdx", 0, 0)
            //call DzFrameSetModel(frame5, "VFX_ERE_LightningField3Y.mdx", 0, 0)
            //call DzFrameShow(frame1, true)
            //call DzFrameSetModel(frame3, "Empyrean Nova.mdx", 0, 0)
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