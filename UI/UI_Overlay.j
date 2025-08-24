library UIOverlay initializer init requires UnitIndexer, DataUnit, FrameCount
    globals
        boolean array OverlayShow
        integer Overlay_BackDrop
        integer array OverlayBar
        integer array OverlayText
        integer array OverlayValue
        integer array OverlayAv
        integer OverlayTimer
        integer array OverlayTimerValue
        integer OverlayDamage
        integer array OverlayDamageValue
        integer OverlayDPS
        integer array OverlayDPSValue

        boolean array Overlay2_InfoOnOff
        integer Overlay2_BackDrop
        integer Overlay2_ImageText
        integer array Overlay2_Bar

    endglobals

    private function Main2 takes nothing returns nothing
        //메뉴 배경
        set Overlay2_BackDrop=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "template", FrameCount())
        call DzFrameSetTexture(Overlay2_BackDrop, "File00005255.blp", 0)
        call DzFrameSetAbsolutePoint(Overlay2_BackDrop, JN_FRAMEPOINT_CENTER, 0.400, 0.300)
        call DzFrameSetSize(Overlay2_BackDrop, 0.650, 0.450)
        call DzFrameSetAlpha(Overlay2_BackDrop, 225)
        call DzFrameSetPriority(Overlay2_BackDrop, 5)

        set Overlay2_ImageText=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "template", FrameCount())
        call DzFrameSetTexture(Overlay2_ImageText, "Overlay2.tga", 0)
        call DzFrameSetAbsolutePoint(Overlay2_ImageText, JN_FRAMEPOINT_CENTER, 0.400, 0.450)
        call DzFrameSetSize(Overlay2_ImageText, 0.590, 0.0250)

        set Overlay2_Bar[0]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[0], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.095)
        call DzFrameSetTexture(Overlay2_Bar[0],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
        call DzFrameSetSize(Overlay2_Bar[0], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[0], true)

        set Overlay2_Bar[0]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[0], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.120 )
        call DzFrameSetTexture(Overlay2_Bar[0],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
        call DzFrameSetSize(Overlay2_Bar[0], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[0], true)

        set Overlay2_Bar[0]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[0], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.145 )
        call DzFrameSetTexture(Overlay2_Bar[0],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
        call DzFrameSetSize(Overlay2_Bar[0], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[0], true)

        set Overlay2_Bar[0]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[0], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.170 )
        call DzFrameSetTexture(Overlay2_Bar[0],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
        call DzFrameSetSize(Overlay2_Bar[0], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[0], true)

        set Overlay2_Bar[0]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[0], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.195)
        call DzFrameSetTexture(Overlay2_Bar[0],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
        call DzFrameSetSize(Overlay2_Bar[0], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[0], true)

        set Overlay2_Bar[0]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[0], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.220)
        call DzFrameSetTexture(Overlay2_Bar[0],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
        call DzFrameSetSize(Overlay2_Bar[0], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[0], true)

        set Overlay2_Bar[0]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[0], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.245)
        call DzFrameSetTexture(Overlay2_Bar[0],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
        call DzFrameSetSize(Overlay2_Bar[0], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[0], true)

        set Overlay2_Bar[0]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[0], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.270)
        call DzFrameSetTexture(Overlay2_Bar[0],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
        call DzFrameSetSize(Overlay2_Bar[0], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[0], true)

        set Overlay2_Bar[0]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[0], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.295)
        call DzFrameSetTexture(Overlay2_Bar[0],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
        call DzFrameSetSize(Overlay2_Bar[0], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[0], true)

        set Overlay2_Bar[0]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[0], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.320)
        call DzFrameSetTexture(Overlay2_Bar[0],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
        call DzFrameSetSize(Overlay2_Bar[0], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[0], true)

        set Overlay2_Bar[0]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[0], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.345)
        call DzFrameSetTexture(Overlay2_Bar[0],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
        call DzFrameSetSize(Overlay2_Bar[0], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[0], true)

        set Overlay2_Bar[0]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[0], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.370)
        call DzFrameSetTexture(Overlay2_Bar[0],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
        call DzFrameSetSize(Overlay2_Bar[0], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[0], true)

        set Overlay2_Bar[0]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[0], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.395)
        call DzFrameSetTexture(Overlay2_Bar[0],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
        call DzFrameSetSize(Overlay2_Bar[0], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[0], true)

        set Overlay2_Bar[0]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[0], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.320)
        call DzFrameSetTexture(Overlay2_Bar[0],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
        call DzFrameSetSize(Overlay2_Bar[0], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[0], true)

        set Overlay2_Bar[0]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[0], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.345)
        call DzFrameSetTexture(Overlay2_Bar[0],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
        call DzFrameSetSize(Overlay2_Bar[0], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[0], true)


        call DzFrameShow(Overlay2_BackDrop, false)
    endfunction
    
    private function Main takes nothing returns nothing
        //set Overlay_BackDrop=DzCreateFrameByTagName("BACKDROP","",DzGetGameUI(),"", FrameCount())
        //call DzFrameSetTexture(Overlay_BackDrop,"File00005255.tga",0)
        //call DzFrameSetAbsolutePoint(Overlay_BackDrop, JN_FRAMEPOINT_CENTER, 0.08, 0.35)
        //call DzFrameSetSize(Overlay_BackDrop, 0.165, 0.140)

        
        //set Overlay_BackDrop=DzCreateFrameByTagName("SIMPLESTATUSBAR","",DzFrameFindByName("InfoPanelIconBackdrop",0),"", FrameCount())
        //call DzFrameSetAbsolutePoint(Overlay_BackDrop,JN_FRAMEPOINT_TOPLEFT,.150,.0900)
        //call DzFrameSetAbsolutePoint(Overlay_BackDrop,JN_FRAMEPOINT_BOTTOMRIGHT,.305,.0740)
        //call DzFrameSetTexture(Overlay_BackDrop,"File00005255.tga",0)
        //call DzFrameSetMinMaxValue(Overlay_BackDrop,0,1)
        //call DzFrameSetValue(Overlay_BackDrop,1)
        //call DzFrameSetAlpha(Overlay_BackDrop, 100)
        
        set Overlay_BackDrop=DzCreateFrameByTagName("BACKDROP","",DzGetGameUI(),"", FrameCount())
        call DzFrameSetTexture(Overlay_BackDrop,"Overlay.tga",0)
        call DzFrameSetAbsolutePoint(Overlay_BackDrop, JN_FRAMEPOINT_CENTER, 0.08, 0.35)
        call DzFrameSetSize(Overlay_BackDrop, 0.165, 0.140)
        call DzFrameSetAlpha(Overlay_BackDrop, 200)

        set OverlayBar[0]=DzCreateFrameByTagName("BACKDROP", "", Overlay_BackDrop, "", FrameCount())
        call DzFrameSetPoint(OverlayBar[0], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.010, -0.025)
        call DzFrameSetSize(OverlayBar[0], 0.145, 0.0130)
        call DzFrameSetTexture(OverlayBar[0],"M_Player1.tga",0)
        call DzFrameSetAlpha(OverlayBar[0], 200)
        call DzFrameShow(OverlayBar[0], true)

        set OverlayText[0]=JNCreateFrameByType("TEXT","",OverlayBar[0],"", FrameCount())
        call DzFrameSetSize(OverlayText[0],0.145,0.00)
        call DzFrameSetPoint(OverlayText[0], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.010, -0.0275)
        call DzFrameSetText(OverlayText[0],"ABCDEABCDEABCDE")
        call DzFrameSetFont(OverlayText[0], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayText[0],true)

        set OverlayValue[0]=JNCreateFrameByType("TEXT","",OverlayBar[0],"", FrameCount())
        call DzFrameSetSize(OverlayValue[0],0.145,0.00)
        call DzFrameSetPoint(OverlayValue[0], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.085, -0.0275)
        call DzFrameSetText(OverlayValue[0],"9999.99"+"만")
        call DzFrameSetFont(OverlayValue[0], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayValue[0],true)

        set OverlayAv[0]=JNCreateFrameByType("TEXT","",OverlayBar[0],"", FrameCount())
        call DzFrameSetSize(OverlayAv[0],0.145,0.00)
        call DzFrameSetPoint(OverlayAv[0], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.121, -0.0275)
        call DzFrameSetText(OverlayAv[0],"(" + "100.00" + "%)")
        call DzFrameSetFont(OverlayAv[0], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayAv[0],true)

        set OverlayBar[1]=DzCreateFrameByTagName("BACKDROP", "", Overlay_BackDrop, "", FrameCount())
        call DzFrameSetPoint(OverlayBar[1], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.010, -0.045)
        call DzFrameSetSize(OverlayBar[1], 0.125, 0.0130)
        call DzFrameSetTexture(OverlayBar[1],"M_Player2.tga",0)
        call DzFrameSetAlpha(OverlayBar[1], 200)
        call DzFrameShow(OverlayBar[1], true)

        set OverlayText[1]=JNCreateFrameByType("TEXT","",OverlayBar[1],"", FrameCount())
        call DzFrameSetSize(OverlayText[1],0.145,0.00)
        call DzFrameSetPoint(OverlayText[1], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.010, -0.0475)
        call DzFrameSetText(OverlayText[1],"ABCDEABCDEABCDE")
        call DzFrameSetFont(OverlayText[1], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayText[1],true)

        set OverlayValue[1]=JNCreateFrameByType("TEXT","",OverlayBar[1],"", FrameCount())
        call DzFrameSetSize(OverlayValue[1],0.145,0.00)
        call DzFrameSetPoint(OverlayValue[1], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.085, -0.0475)
        call DzFrameSetText(OverlayValue[1],"9999.99"+"만")
        call DzFrameSetFont(OverlayValue[1], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayValue[1],true)

        set OverlayAv[1]=JNCreateFrameByType("TEXT","",OverlayBar[1],"", FrameCount())
        call DzFrameSetSize(OverlayAv[1],0.145,0.00)
        call DzFrameSetPoint(OverlayAv[1], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.121, -0.0475)
        call DzFrameSetText(OverlayAv[1],"(" + "100.00" + "%)")
        call DzFrameSetFont(OverlayAv[1], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayAv[1],true)

        set OverlayBar[2]=DzCreateFrameByTagName("BACKDROP", "", Overlay_BackDrop, "", FrameCount())
        call DzFrameSetPoint(OverlayBar[2], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.010, -0.065)
        call DzFrameSetSize(OverlayBar[2], 0.125, 0.0130)
        call DzFrameSetTexture(OverlayBar[2],"M_Player3.tga",0)
        call DzFrameSetAlpha(OverlayBar[2], 200)
        call DzFrameShow(OverlayBar[2], true)

        set OverlayText[2]=JNCreateFrameByType("TEXT","",OverlayBar[2],"", FrameCount())
        call DzFrameSetSize(OverlayText[2],0.145,0.00)
        call DzFrameSetPoint(OverlayText[2], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.010, -0.0675)
        call DzFrameSetText(OverlayText[2],"ABCDEABCDEABCDE")
        call DzFrameSetFont(OverlayText[2], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayText[2],true)

        set OverlayValue[2]=JNCreateFrameByType("TEXT","",OverlayBar[2],"", FrameCount())
        call DzFrameSetSize(OverlayValue[2],0.145,0.00)
        call DzFrameSetPoint(OverlayValue[2], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.085, -0.0675)
        call DzFrameSetText(OverlayValue[2],"9999.99"+"만")
        call DzFrameSetFont(OverlayValue[2], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayValue[2],true)

        set OverlayAv[2]=JNCreateFrameByType("TEXT","",OverlayBar[2],"", FrameCount())
        call DzFrameSetSize(OverlayAv[2],0.145,0.00)
        call DzFrameSetPoint(OverlayAv[2], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.121, -0.0675)
        call DzFrameSetText(OverlayAv[2],"(" + "100.00" + "%)")
        call DzFrameSetFont(OverlayAv[2], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayAv[2],true)

        set OverlayBar[3]=DzCreateFrameByTagName("BACKDROP", "", Overlay_BackDrop, "", FrameCount())
        call DzFrameSetPoint(OverlayBar[3], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.010, -0.085)
        call DzFrameSetSize(OverlayBar[3], 0.125, 0.0130)
        call DzFrameSetTexture(OverlayBar[3],"M_Player4.tga",0)
        call DzFrameSetAlpha(OverlayBar[3], 200)
        call DzFrameShow(OverlayBar[3], true)

        set OverlayText[3]=JNCreateFrameByType("TEXT","",OverlayBar[3],"", FrameCount())
        call DzFrameSetSize(OverlayText[3],0.145,0.00)
        call DzFrameSetPoint(OverlayText[3], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.010, -0.0875)
        call DzFrameSetText(OverlayText[3],"ABCDEABCDEABCDE")
        call DzFrameSetFont(OverlayText[3], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayText[3],true)

        set OverlayValue[3]=JNCreateFrameByType("TEXT","",OverlayBar[3],"", FrameCount())
        call DzFrameSetSize(OverlayValue[3],0.145,0.00)
        call DzFrameSetPoint(OverlayValue[3], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.085, -0.0875)
        call DzFrameSetText(OverlayValue[3],"9999.99"+"만")
        call DzFrameSetFont(OverlayValue[3], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayValue[3],true)

        set OverlayAv[3]=JNCreateFrameByType("TEXT","",OverlayBar[3],"", FrameCount())
        call DzFrameSetSize(OverlayAv[3],0.145,0.00)
        call DzFrameSetPoint(OverlayAv[3], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.121, -0.0875)
        call DzFrameSetText(OverlayAv[3],"(" + "100.00" + "%)")
        call DzFrameSetFont(OverlayAv[3], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayAv[3],true)

        set OverlayTimer=JNCreateFrameByType("TEXT","",Overlay_BackDrop,"", FrameCount())
        call DzFrameSetSize(OverlayTimer,0.145,0.00)
        call DzFrameSetPoint(OverlayTimer, JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.121, -0.1000)
        call DzFrameSetText(OverlayTimer,"00"+":"+"00"+":"+"00")
        call DzFrameSetFont(OverlayTimer, "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayTimer,true)

        set OverlayDamage=JNCreateFrameByType("TEXT","",Overlay_BackDrop,"", FrameCount())
        call DzFrameSetSize(OverlayDamage,0.145,0.00)
        call DzFrameSetPoint(OverlayDamage, JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.0375, -0.1100)
        call DzFrameSetText(OverlayDamage,"피해량")
        call DzFrameSetFont(OverlayDamage, "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayDamage,true)
        set OverlayDamage=JNCreateFrameByType("TEXT","",Overlay_BackDrop,"", FrameCount())
        call DzFrameSetSize(OverlayDamage,0.145,0.00)
        call DzFrameSetPoint(OverlayDamage, JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.0275, -0.1225)
        call DzFrameSetText(OverlayDamage,"9999.99"+"만")
        call DzFrameSetFont(OverlayDamage, "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayDamage,true)

        set OverlayDPS=JNCreateFrameByType("TEXT","",Overlay_BackDrop,"", FrameCount())
        call DzFrameSetSize(OverlayDPS,0.145,0.00)
        call DzFrameSetPoint(OverlayDPS, JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.1100, -0.1100)
        call DzFrameSetText(OverlayDPS,"DPS")
        call DzFrameSetFont(OverlayDPS, "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayDPS,true)
        set OverlayDPS=JNCreateFrameByType("TEXT","",Overlay_BackDrop,"", FrameCount())
        call DzFrameSetSize(OverlayDPS,0.145,0.00)
        call DzFrameSetPoint(OverlayDPS, JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.1000, -0.1225)
        call DzFrameSetText(OverlayDPS,"9999.99"+"만")
        call DzFrameSetFont(OverlayDPS, "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayDPS,true)

        call DzFrameShow(Overlay_BackDrop,true)
    endfunction

    private function Key takes nothing returns nothing
        local integer key = DzGetTriggerKey()
        local integer i = 0
        local integer j = GetPlayerId(DzGetTriggerKeyPlayer())
        
        if DzGetTriggerKeyPlayer()==GetLocalPlayer() then
            set i = JNMemoryGetByte(JNGetModuleHandle("Game.dll")+0xD04FEC)
        endif
        
        if i==1 then
        else
            if PickCheck[j] == true then
                if key == JN_OSKEY_OEM_PERIOD then
                    if Overlay2_InfoOnOff[j] == true then
                        call DzFrameShow(Overlay2_BackDrop, false)
                        set Overlay2_InfoOnOff[j] = false
                    else
                        if F_ArcanaOnOff[j] == true then
                            call DzFrameShow(F_ArcanaBackDrop, false)
                            set F_ArcanaOnOff[j] = false
                        endif
                        if F_Info2OnOff[j] == true then
                            call DzFrameShow(F_InfoBackDrop2, false)
                            set F_Info2OnOff[j] = false
                        endif
                        call DzFrameShow(Overlay2_BackDrop, true)
                        set Overlay2_InfoOnOff[j] = true
                    endif
                endif
            endif
        endif
    endfunction


    private function Command takes nothing returns nothing
        if OverlayShow[GetPlayerId(GetTriggerPlayer())] == false then
            call DzFrameShow(Overlay_BackDrop,true)
            set OverlayShow[GetPlayerId(GetTriggerPlayer())] = true

        elseif OverlayShow[GetPlayerId(GetTriggerPlayer())] == true then
            call DzFrameShow(Overlay_BackDrop,false)
            set OverlayShow[GetPlayerId(GetTriggerPlayer())] = false
        endif
    endfunction

    //private function Command2 takes nothing returns nothing
        //local string s = GetEventPlayerChatString()
        //local string temp = JNStringSplit(s, " ", 1)
        //local real a = S2R(JNStringSplit(temp, "/", 0))
        //local real b = S2R(JNStringSplit(temp, "/", 1))
        //call BJDebugMsg(R2S(a) + " " + R2S(b))
        //call DzFrameSetAbsolutePoint(Overlay_BackDrop, JN_FRAMEPOINT_CENTER, a, b)
    //endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger(  )
        local integer i = 0
        call TriggerRegisterTimerEvent(t, 0.10, false)
        call TriggerAddAction( t, function Main )
        
        set t = CreateTrigger(  )
        loop
            exitwhen i > 4
            call TriggerRegisterPlayerChatEvent( t, Player(i), "-미터기", false )
            set OverlayShow[GetPlayerId(GetTriggerPlayer())] = false
            set i = i + 1
        endloop
        call TriggerAddAction( t, function Command )

        set t = CreateTrigger(  )
        call TriggerRegisterTimerEvent(t, 0.10, false)
        call TriggerAddAction( t, function Main2 )
        
        set i = 0
        loop
            set Overlay2_InfoOnOff[i] = false
            set i = i + 1
            exitwhen i == 4
        endloop
        
        //P버튼으로 인포창 열기 및 닫기
        call DzTriggerRegisterKeyEventByCode(null, JN_OSKEY_OEM_PERIOD, 0, false, function Key)

        //set t = CreateTrigger(  )
        //loop
            //exitwhen i > 4
            //call TriggerRegisterPlayerChatEvent( t, Player(i), "-좌표 ", false )
            //set i = i + 1
        //endloop
        //call TriggerAddAction( t, function Command2 )
        
        set t = null
    endfunction
endlibrary