scope ESC initializer init
    globals
        private integer i = 0
        //string s = "12;1;1;2;3;45;1;3;45;6;1;각인32;각인수치99999;123123;"
        real AAA = 0
        integer BBB = 0
        integer BBBF
        string s = "1"
    endglobals

    private function ESCAction2 takes nothing returns nothing
        /*
        call VJDebugMsg("ESC")

        set i = i + 1

        if i == 1 then
            call VJDebugMsg("이전가격 : "+I2S(Price[1]))
            call MarketDataDownload(GetPlayerId(GetTriggerPlayer()))
            call VJDebugMsg(I2S(Price[1]))
        elseif i == 2 then
            set Price[1] = Price[1] + 1
            call MarketDataUpload(GetPlayerId(GetTriggerPlayer()),1,Price[1])
            call VJDebugMsg("Price[1] : "+I2S(Price[1]))
            set i = 0
        endif
        */
    endfunction
    
    private function ESCAction4 takes nothing returns nothing
        /*
        local integer i = 0

        //목
        set s = "ID7;"
        set s = SetItemCombatStats(s, GetRandomInt(1,3))
        set s = SetItemQuality(s, (Quality.pick(false)-1) )
        call additem(Player(0), s)
        //귀
        set s = "ID8;"
        set s = SetItemCombatStats(s, GetRandomInt(1,3))
        set s = SetItemQuality(s, (Quality.pick(false)-1) )
        call additem(Player(0), s)
        //반
        set s = "ID10;"
        set s = SetItemCombatStats(s, GetRandomInt(1,3))
        set s = SetItemQuality(s, (Quality.pick(false)-1) )
        call additem(Player(0), s)
        */

        //call VJDebugMsg(JNStringRegex(s, "품질\\d+;", 0))
        //set s = JNStringReplace(s, JNStringRegex(s, "품질\\d+;", 0), "품질22;")
        

        /*
        //call VJDebugMsg("바꾼후 : "+s)
        //call VJDebugMsg("ESC")
        //call TodayQuestPlus(0)
        */

        
        //신속1800설정
        if AAA == 0 then
            set Equip_Swiftness[0] = 600
            call ItemUIStatsSet(0)
            call VJDebugMsg("신속600")
            set AAA = 1
        elseif AAA == 1 then
            set Equip_Swiftness[0] = 1200
            call ItemUIStatsSet(0)
            call VJDebugMsg("신속1200")
            set AAA = 2
        elseif AAA == 2 then
            set Equip_Swiftness[0] = 1800
            call ItemUIStatsSet(0)
            call VJDebugMsg("신속1800")
            set AAA = 3
        elseif AAA == 3 then
            set Equip_Swiftness[0] = 2200
            call ItemUIStatsSet(0)
            call VJDebugMsg("신속2200")
            set AAA = 4
        elseif AAA == 4 then
            set Equip_Swiftness[0] = 0
            call ItemUIStatsSet(0)
            call VJDebugMsg("신속0")
            set AAA = 0
        endif
    endfunction

    private function ESCAction5 takes nothing returns nothing
        //set AAA = S2R(s)
        //set AAA = AAA + AAA
        //set s = R2SW(AAA,1,0)
        //set s = SubString(s,0,StringLength(s)-2)
        //call DzFrameSetText(F_EnchantUpText, s )
        //call VJDebugMsg(s) 
    endfunction

    private function EffectFunction takes nothing returns nothing
        //set AAA = S2R(s)
        //set AAA = AAA + AAA
        //set s = R2SW(AAA,1,0)
        //set s = SubString(s,0,StringLength(s)-2)
        //call DzFrameSetText(F_EnchantUpText, s )
        //call VJDebugMsg(s) 
        //레이지소리
        call Sound3D(MainUnit[0],'A02B')
    endfunction

    private function ESCAction123123 takes nothing returns nothing
        if AAA == 0 then
            set AAA = 1
            set frame1=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "", FrameCount())
            call DzFrameSetTexture(frame1,"Narmaya_blue.blp",0)
            call DzFrameSetAbsolutePoint(frame1,JN_FRAMEPOINT_CENTER,0.4,0.03)
            call DzFrameSetSize(frame1,0.04,0.04)
            call DzFrameShow(frame1, false)
        elseif AAA == 1 then
            set AAA = 2
            call DzFrameSetTexture(frame1,"Narmaya_blue.blp",0)
            call DzFrameShow(frame1, true)
        elseif AAA == 2 then
            set AAA = 1
            call DzFrameSetTexture(frame1,"Narmaya_pink.blp",0)
            call DzFrameShow(frame1, true)
        endif
    endfunction
    
    
    private function ESCAction22 takes nothing returns nothing

        //call DzSetUnitModel(MainUnit[0], "[Hero]\\mh_Firefly_yz.mdl")

        if BBB == 0 then
            set BBBF = 0
            //DzCreateFrameByTagName("BACKDROP", "", JNCreateFrameByType("FRAME","heroStatusUI",DzGetGameUI(),"",0), "", FrameCount())
            //call DzFrameSetTexture(BBBF,"Narmaya_blue.blp",0)
            call DzFrameSetAbsolutePoint(BBBF,JN_FRAMEPOINT_CENTER,0.4,0.3)
            call DzFrameSetSize(BBBF,0.8,0.6)
            call DzFrameShow(BBBF, true)
        endif

        //반디필터
        set BBB = BBB + 1
        if BBB+29 < 10 then
            //call CinematicFilter2(GetTriggerPlayer(), BLEND_MODE_BLEND , "war3mapImported\\BandiZ (0"+I2S(BBB)+").blp" , 100, 100, 100, 100, 100, 100, 100, 25)
            call DzFrameSetTexture(BBBF,"war3mapImported\\BandiZ (0"+I2S(BBB+29)+").blp",0)
            call DzFrameShow(BBBF, true)
        elseif BBB+29 < 86 then
            //call CinematicFilter2(GetTriggerPlayer(), BLEND_MODE_BLEND , "war3mapImported\\BandiZ ("+I2S(BBB)+").blp" , 100, 100, 100, 100, 100, 100, 100, 25)
            call DzFrameSetTexture(BBBF,"war3mapImported\\BandiZ ("+I2S(BBB+29)+").blp",0)
            call DzFrameShow(BBBF, true)
        endif
        
        if BBB+29 == 31 then
            //call Sound3D(MainUnit[0],'A066')
            call Sound3D(MainUnit[0],'A067')
        elseif BBB+29 == 85 then
            call Sound3D(MainUnit[0],'A068')
        endif


        call TriggerSleepActionByTimer(0.02)


        if BBB+29 < 86 then
            call ESCAction22()
        else
            call DzFrameShow(BBBF, false)
            call CinematicFilter2(GetTriggerPlayer(), BLEND_MODE_BLEND , "BANDI.blp" , 100, 100, 100, 100, 100, 100, 100, 25)
            set BBB = 1
        endif

    endfunction

    private function ESCActionF takes string s, string name returns string
        local string s2
        local string s3

        set s2 = JNStringRegex(s, name+"\\d+;", 0)
        set s3 = JNStringRegex(s2, "\\d+", 0)

        return s3
    endfunction
    


    private function ESCAction takes nothing returns nothing
        local string s
        local string s2
        local string s3
        local string name
        local integer frame3

        set AAA = AAA - 0.1
        
        //set SelectString[pid] = JNStringReplace(s, JNStringRegex(s, "0\\d+;", 0), I2S(NowSelectNumber)+";")

        //set frame3 = DzFrameGetCommandBarButton(2,0)
        //call DzFrameSetAbsolutePoint(frame3,JN_FRAMEPOINT_TOPLEFT,-1,-1)

        /*
        
        //목
        set s = "ID10;"
        set s = SetItemCombatStats(s, GetRandomInt(1,3))
        //set s = SetItemQuality(s, (Quality.pick(false)-1) )
        set s = SetItemQuality(s, 20 )
        set s = SetItemCombatBonus1(s,GetRandomInt(0,10))
        set s = SetItemCombatBonus2(s,1)
        set s = SetItemCombatPenalty(s,GetRandomInt(50,53))
        set s = SetItemCombatPenalty2(s,1)
        call additem(Player(0), s)
        //귀
        set s = "ID1;"
        set s = SetItemCombatStats(s, GetRandomInt(1,2))
        set s = SetItemQuality(s, 20 )
        set s = SetItemCombatBonus1(s,GetRandomInt(0,10))
        set s = SetItemCombatBonus2(s,1)
        set s = SetItemCombatPenalty(s,GetRandomInt(50,53))
        set s = SetItemCombatPenalty2(s,1)
        call additem(Player(0), s)
        //반
        set s = "ID19;"
        set s = SetItemCombatStats(s, GetRandomInt(1,2))
        set s = SetItemQuality(s, 20 )
        set s = SetItemCombatBonus1(s,GetRandomInt(0,10))
        set s = SetItemCombatBonus2(s,1)
        set s = SetItemCombatPenalty(s,GetRandomInt(50,53))
        set s = SetItemCombatPenalty2(s,1)
        call additem(Player(0), s)
        */
        //call additem(Player(0),"ID12"+";"+"0")

        /*
        set i = i + 1
        //call SaveInteger(ArcanaData, 50, 0, i)
        //call SaveInteger(ArcanaData, 51, 0, i)
        //call SaveInteger(ArcanaData, 52, 0, i)
        //call SaveInteger(ArcanaData, 53, 0, i)

        if i == 5 then
            set i = 0
        endif
        */
        
        /*
        if AAA == 0 then
            set Equip_Swiftness[0] = 600
            call ItemUIStatsSet(0)
            call VJDebugMsg("신속600")
            set AAA = 1
        elseif AAA == 1 then
            set Equip_Swiftness[0] = 1200
            call ItemUIStatsSet(0)
            call VJDebugMsg("신속1200")
            set AAA = 2
        elseif AAA == 2 then
            set Equip_Swiftness[0] = 1800
            call ItemUIStatsSet(0)
            call VJDebugMsg("신속1800")
            set AAA = 3
        elseif AAA == 3 then
            set Equip_Swiftness[0] = 2200
            call ItemUIStatsSet(0)
            call VJDebugMsg("신속2200")
            set AAA = 4
        elseif AAA == 4 then
            set Equip_Swiftness[0] = 0
            call ItemUIStatsSet(0)
            call VJDebugMsg("신속0")
            set AAA = 0
        endif
        */
        /*
        call VJDebugMsg("전투력 : 1000 , 명성 : "+ I2S(TrailblazePower(1000)))
        call VJDebugMsg("전투력 : 1100 , 명성 : "+ I2S(TrailblazePower(1100)))
        call VJDebugMsg("전투력 : 1210 , 명성 : "+ I2S(TrailblazePower(1210)))
        call VJDebugMsg("전투력 : 1331 , 명성 : "+ I2S(TrailblazePower(1331)))
        call VJDebugMsg("전투력 : 1464 , 명성 : "+ I2S(TrailblazePower(1464)))
        call VJDebugMsg("전투력 : 1610 , 명성 : "+ I2S(TrailblazePower(1610)))
        call VJDebugMsg("전투력 : 1771 , 명성 : "+ I2S(TrailblazePower(1771)))
        call VJDebugMsg("전투력 : 1948 , 명성 : "+ I2S(TrailblazePower(1948)))
        
        call VJDebugMsg("전투력 : 5000 , 명성 : "+ I2S(TrailblazePower(5000)))
        call VJDebugMsg("전투력 : 6666 , 명성 : "+ I2S(TrailblazePower(6666)))
        call VJDebugMsg("전투력 : 7241 , 명성 : "+ I2S(TrailblazePower(7241)))
        call VJDebugMsg("전투력 : 10000 , 명성 : "+ I2S(TrailblazePower(10000)))
        call VJDebugMsg("전투력 : 11000 , 명성 : "+ I2S(TrailblazePower(11000)))
        call VJDebugMsg("전투력 : 30000 , 명성 : "+ I2S(TrailblazePower(30000)))

        call VJDebugMsg("전투력 : 117390 , 명성 : "+ I2S(TrailblazePower(117390)))
        call VJDebugMsg("전투력 : 117390 , 명성 : "+ I2S(TrailblazePower(117390)))
        call VJDebugMsg("전투력 : 129129 , 명성 : "+ I2S(TrailblazePower(129129)))
        call VJDebugMsg("전투력 : 142042 , 명성 : "+ I2S(TrailblazePower(142042)))
        call VJDebugMsg("전투력 : 1000000 , 명성 : "+ I2S(TrailblazePower(1000000)))
        call VJDebugMsg("전투력 : 2000000 , 명성 : "+ I2S(TrailblazePower(2000000)))
        call VJDebugMsg("전투력 : 13780612 , 명성 : "+ I2S(TrailblazePower(13780612)))
        call VJDebugMsg("전투력 : 13780612 , 명성 : "+ I2S(TrailblazePower(13780612)))
        */
        
    endfunction

    private function ESCAction9999 takes nothing returns nothing
        local integer i = 0
        local integer j = 0
        local unit u
        call VJDebugMsg("ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ")
        if AAA == 0 then
            set i = 0
            loop
                set j = 0
                set i = i + 1
                loop
                    set j = j + 10
                    set u = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'h00J',GetUnitX(MainUnit[0])+PolarX(i*100,j),GetUnitY(MainUnit[0])+PolarY(i*100,j),270)
                    call UnitRemoveAbility(u,'Amov')
                    call SetUnitPathing(u,false)
                    call PauseUnit(u,true)
                    call SetUnitPosition(u,GetUnitX(MainUnit[0])+PolarX(i*100,j),GetUnitY(MainUnit[0])+PolarY(i*100,j))
                    exitwhen j == 360
                endloop
            exitwhen i == 12
            endloop
        endif
        set AAA = AAA + 1
    endfunction

    private function ESCAction4123 takes nothing returns nothing
        local tick t 
        set AAA = AAA + 1
        if AAA == 1 then
            set frame1=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", FrameCount())
            call DzFrameSetAbsolutePoint(frame1,JN_FRAMEPOINT_BOTTOMLEFT,0,0)
            set frame2=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", FrameCount())
            call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_BOTTOMLEFT,0,0)
            set frame3=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", FrameCount())
            call DzFrameSetAbsolutePoint(frame3,JN_FRAMEPOINT_BOTTOMLEFT,0,0)
            set frame4=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", FrameCount())
            call DzFrameSetAbsolutePoint(frame4,JN_FRAMEPOINT_BOTTOMLEFT,0,0)

            set frame5=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", FrameCount())
            call DzFrameSetAbsolutePoint(frame5,JN_FRAMEPOINT_BOTTOMLEFT,0.2,0.5)
            set frame6=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", FrameCount())
            call DzFrameSetAbsolutePoint(frame6,JN_FRAMEPOINT_BOTTOMLEFT,0.2,0.3)
            set frame7=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", FrameCount())
            call DzFrameSetAbsolutePoint(frame7,JN_FRAMEPOINT_BOTTOMLEFT,0.2,0.1)

            set frame8=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", FrameCount())
            call DzFrameSetAbsolutePoint(frame8,JN_FRAMEPOINT_BOTTOMLEFT,0.4,0.5)
            set frame9=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", FrameCount())
            call DzFrameSetAbsolutePoint(frame9,JN_FRAMEPOINT_BOTTOMLEFT,0.4,0.3)
            set frame10=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", FrameCount())
            call DzFrameSetAbsolutePoint(frame10,JN_FRAMEPOINT_BOTTOMLEFT,0.4,0.1)

            set frame11=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", FrameCount())
            call DzFrameSetAbsolutePoint(frame11,JN_FRAMEPOINT_BOTTOMLEFT,0.6,0.5)
            set frame12=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", FrameCount())
            call DzFrameSetAbsolutePoint(frame12,JN_FRAMEPOINT_BOTTOMLEFT,0.6,0.3)
            set frame13=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", FrameCount())
            call DzFrameSetAbsolutePoint(frame13,JN_FRAMEPOINT_BOTTOMLEFT,0.6,0.1)

            set frame14=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", FrameCount())
            call DzFrameSetAbsolutePoint(frame14,JN_FRAMEPOINT_BOTTOMLEFT,0.8,0.5)
            set frame15=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", FrameCount())
            call DzFrameSetAbsolutePoint(frame15,JN_FRAMEPOINT_BOTTOMLEFT,0.8,0.3)
            set frame16=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", FrameCount())
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

            //개인사운드로
            //첸
            call Sound3D(MainUnit[0],'A02A')
            //모미지
            //call Sound3D(MainUnit[0],'A022')
            //미카
            //call Sound3D(MainUnit[0],'A02C')
            //나루메아
            //call Sound3D(MainUnit[0],'A02D')

            call t.start( 0.1, false, function EffectFunction )
        endif
    endfunction

    private function ESCAction1233 takes nothing returns nothing
        local tick t 
        set AAA = AAA + 1
        if AAA == 1 then
            set frame4=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", FrameCount())
            call DzFrameSetAbsolutePoint(frame4,JN_FRAMEPOINT_BOTTOMLEFT,0.4,0.15)

            set frame5=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", FrameCount())
            call DzFrameSetAbsolutePoint(frame5,JN_FRAMEPOINT_BOTTOMLEFT,0.4,0.15)
        
            set frame1=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "template", FrameCount())
            call DzFrameSetTexture(frame1, "V.blp", 0)
            call DzFrameSetSize(frame1, 0.030, 0.030)
            call DzFrameSetAbsolutePoint(frame1, JN_FRAMEPOINT_CENTER, 0.4, 0.15)
            call DzFrameShow(frame1, false)

            set frame3=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", FrameCount())
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
        call TriggerRegisterPlayerEvent(t, Player(0), EVENT_PLAYER_END_CINEMATIC)
        call TriggerRegisterPlayerEvent(t, Player(1), EVENT_PLAYER_END_CINEMATIC)
        call TriggerAddAction( t, function ESCAction )
        set t = null
        set Price[1] = 10000
    endfunction

endscope