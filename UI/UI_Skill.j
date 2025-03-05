library UISkill initializer init
    globals
        integer array skillbuttonframe
        integer NarAden
        integer array NarAdens
        integer array NarAdens2
        integer BanAden
        integer array BanAdens
        integer array BanAdens2
        integer heroStatusUI
    endglobals
    
    private function Action takes nothing returns nothing
        local integer frame
        local integer frame2
        local real x
        local real x2
        local real y
        local real y2
        
        set x = 0.192
        set x2 = 0.207
        set y = 0.0275
        set y2 = 0.0225
        set heroStatusUI=JNCreateFrameByType("FRAME","heroStatusUI",DzGetGameUI(),"",0)
                
        set frame=JNCreateFrameByType("BACKDROP","Command01",heroStatusUI,"",0)
        call DzFrameSetTexture(frame,"Transparent.blp",0)
        call DzFrameSetSize(frame,0.02,0.02)
        call DzFrameSetAbsolutePoint(frame,JN_FRAMEPOINT_TOPLEFT,0.6075, 0.1205)
        set frame2 = DzFrameGetCommandBarButton(0,0)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(frame2,JN_FRAMEPOINT_TOPLEFT,frame,JN_FRAMEPOINT_TOPLEFT,0.0,0.0)

        set frame=JNCreateFrameByType("BACKDROP","Command02",heroStatusUI,"",0)
        call DzFrameSetTexture(frame,"Transparent.blp",0)
        call DzFrameSetSize(frame,0.02,0.02)
        call DzFrameSetAbsolutePoint(frame,JN_FRAMEPOINT_TOPLEFT,0.6443, 0.1205)
        set frame2 = DzFrameGetCommandBarButton(0,1)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(frame2,JN_FRAMEPOINT_TOPLEFT,frame,JN_FRAMEPOINT_TOPLEFT,0.0,0.0)

        set frame=JNCreateFrameByType("BACKDROP","Command03",heroStatusUI,"",0)
        call DzFrameSetTexture(frame,"Transparent.blp",0)
        call DzFrameSetSize(frame,0.02,0.02)
        call DzFrameSetAbsolutePoint(frame,JN_FRAMEPOINT_TOPLEFT,0.6811, 0.1205)
        set frame2 = DzFrameGetCommandBarButton(0,2)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(frame2,JN_FRAMEPOINT_TOPLEFT,frame,JN_FRAMEPOINT_TOPLEFT,0.0,0.0)

        set frame=JNCreateFrameByType("BACKDROP","Command04",heroStatusUI,"",0)
        call DzFrameSetTexture(frame,"Transparent.blp",0)
        call DzFrameSetSize(frame,0.02,0.02)
        call DzFrameSetAbsolutePoint(frame,JN_FRAMEPOINT_TOPLEFT,0.7179, 0.1205)
        set frame2 = DzFrameGetCommandBarButton(0,3)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(frame2,JN_FRAMEPOINT_TOPLEFT,frame,JN_FRAMEPOINT_TOPLEFT,0.0,0.0)

        set frame=JNCreateFrameByType("BACKDROP","Command05",heroStatusUI,"",0)
        call DzFrameSetTexture(frame,"Transparent.blp",0)
        call DzFrameSetSize(frame,0.02,0.02)
        call DzFrameSetAbsolutePoint(frame,JN_FRAMEPOINT_TOPLEFT,0.6075, 0.0840)
        set frame2 = DzFrameGetCommandBarButton(1,0)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(frame2,JN_FRAMEPOINT_TOPLEFT,frame,JN_FRAMEPOINT_TOPLEFT,0.0,0.0)

        set frame=JNCreateFrameByType("BACKDROP","Command06",heroStatusUI,"",0)
        call DzFrameSetTexture(frame,"Transparent.blp",0)
        call DzFrameSetSize(frame,0.02,0.02)
        call DzFrameSetAbsolutePoint(frame,JN_FRAMEPOINT_TOPLEFT,0.6443, 0.0840)
        set frame2 = DzFrameGetCommandBarButton(1,1)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(frame2,JN_FRAMEPOINT_TOPLEFT,frame,JN_FRAMEPOINT_TOPLEFT,0.0,0.0)

        set frame=JNCreateFrameByType("BACKDROP","Command07",heroStatusUI,"",0)
        call DzFrameSetTexture(frame,"Transparent.blp",0)
        call DzFrameSetSize(frame,0.02,0.02)
        call DzFrameSetAbsolutePoint(frame,JN_FRAMEPOINT_TOPLEFT,0.6811, 0.0840)
        set frame2 = DzFrameGetCommandBarButton(1,2)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(frame2,JN_FRAMEPOINT_TOPLEFT,frame,JN_FRAMEPOINT_TOPLEFT,0.0,0.0)

        set frame=JNCreateFrameByType("BACKDROP","Command08",heroStatusUI,"",0)
        call DzFrameSetTexture(frame,"Transparent.blp",0)
        call DzFrameSetSize(frame,0.02,0.02)
        call DzFrameSetAbsolutePoint(frame,JN_FRAMEPOINT_TOPLEFT,0.7179, 0.0840)
        set frame2 = DzFrameGetCommandBarButton(1,3)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(frame2,JN_FRAMEPOINT_TOPLEFT,frame,JN_FRAMEPOINT_TOPLEFT,0.0,0.0)

        //set frame=JNCreateFrameByType("BACKDROP","Command09",heroStatusUI,"",0)
        //call DzFrameSetTexture(frame,"Transparent.blp",0)
        //call DzFrameSetSize(frame,0.02,0.02)
        //call DzFrameSetAbsolutePoint(frame,JN_FRAMEPOINT_TOPLEFT,0.6075, 0.0475)
        //set frame2 = DzFrameGetCommandBarButton(2,0)
        //call DzFrameSetSize(frame2,.0275,.0275)
        //call DzFrameSetPoint(frame2,JN_FRAMEPOINT_TOPLEFT,frame,JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        //set skillbuttonframe[8]=JNCreateFrameByType("TEXT","",heroStatusUI,"",0)
        //call DzFrameSetSize(skillbuttonframe[8],0.007,0.00)
        //call DzFrameSetPoint(skillbuttonframe[8],JN_FRAMEPOINT_BOTTOM,frame,JN_FRAMEPOINT_BOTTOM,-0.007,0.007)
        //call DzFrameSetText(skillbuttonframe[8],"Z")



        set skillbuttonframe[8]=JNCreateFrameByType("TEXT","",heroStatusUI,"",0)
        call DzFrameSetSize(skillbuttonframe[8],0.007,0.00)
        call DzFrameSetAbsolutePoint(skillbuttonframe[8],JN_FRAMEPOINT_CENTER,0.4,0.015)
        call DzFrameSetText(skillbuttonframe[8],"Z")
        call DzFrameShow(skillbuttonframe[8],false)


        set frame=JNCreateFrameByType("BACKDROP","Command10",heroStatusUI,"",0)
        call DzFrameSetTexture(frame,"Transparent.blp",0)
        call DzFrameSetSize(frame,0.02,0.02)
        call DzFrameSetAbsolutePoint(frame,JN_FRAMEPOINT_TOPLEFT,0.6443, 0.0475)
        set frame2 = DzFrameGetCommandBarButton(2,1)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(frame2,JN_FRAMEPOINT_TOPLEFT,frame,JN_FRAMEPOINT_TOPLEFT,0.0,0.0)

        set frame=JNCreateFrameByType("BACKDROP","Command11",heroStatusUI,"",0)
        call DzFrameSetTexture(frame,"Transparent.blp",0)
        call DzFrameSetSize(frame,0.02,0.02)
        call DzFrameSetAbsolutePoint(frame,JN_FRAMEPOINT_TOPLEFT,0.6811, 0.0475)
        set frame2 = DzFrameGetCommandBarButton(2,2)
        call DzFrameSetSize(frame2,.0275,.0275)
        call DzFrameSetPoint(frame2,JN_FRAMEPOINT_TOPLEFT,frame,JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        
        //소모품
        set frame=JNCreateFrameByType("BACKDROP","Command12",heroStatusUI,"",0)
        call DzFrameSetTexture(frame,"Transparent.blp",0)
        call DzFrameSetSize(frame,0.02,0.02)
        call DzFrameSetAbsolutePoint(frame,JN_FRAMEPOINT_TOPLEFT,0.5475,0.1185)
        set frame2 = DzFrameGetItemBarButton(0)
        call DzFrameSetSize(frame2,.0225,.0225)
        call DzFrameSetPoint(frame2,JN_FRAMEPOINT_TOPLEFT,frame,JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        
        set frame=JNCreateFrameByType("BACKDROP","Command13",heroStatusUI,"",0)
        call DzFrameSetTexture(frame,"Transparent.blp",0)
        call DzFrameSetSize(frame,0.02,0.02)
        call DzFrameSetAbsolutePoint(frame,JN_FRAMEPOINT_TOPLEFT,0.5475,0.08175)
        set frame2 = DzFrameGetItemBarButton(1)
        call DzFrameSetSize(frame2,.0225,.0225)
        call DzFrameSetPoint(frame2,JN_FRAMEPOINT_TOPLEFT,frame,JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        
        set frame=JNCreateFrameByType("BACKDROP","Command14",heroStatusUI,"",0)
        call DzFrameSetTexture(frame,"Transparent.blp",0)
        call DzFrameSetSize(frame,0.02,0.02)
        call DzFrameSetAbsolutePoint(frame,JN_FRAMEPOINT_TOPLEFT,0.5475,0.0440)
        set frame2 = DzFrameGetItemBarButton(2)
        call DzFrameSetSize(frame2,.0225,.0225)
        call DzFrameSetPoint(frame2,JN_FRAMEPOINT_TOPLEFT,frame,JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        
        //set frame=JNCreateFrameByType("BACKDROP","Command15",heroStatusUI,"",0)
        //call DzFrameSetTexture(frame,"Transparent.blp",0)
        //call DzFrameSetSize(frame,0.02,0.02)
        //call DzFrameSetAbsolutePoint(frame,JN_FRAMEPOINT_BOTTOMLEFT,0.485+(y2*3),-0.006)
        //set frame3=JNCreateFrameByType("TEXT","",heroStatusUI,"",0)
        //call DzFrameSetSize(frame3,0.007,0.00)
        //call DzFrameSetPoint(frame3,JN_FRAMEPOINT_BOTTOM,frame,JN_FRAMEPOINT_BOTTOM,-0.0075,0)
        //call DzFrameSetText(frame3,"4")

        //반디 아덴
        set BanAdens[0] = DzCreateFrameByTagName("BACKDROP", "", frame, "", 0)
        call DzFrameSetTexture(BanAdens[0],"Bandi_Aden0.blp",0)
        call DzFrameSetAbsolutePoint(BanAdens[0],JN_FRAMEPOINT_CENTER,0.4,0.035 +0.045)
        call DzFrameSetSize(BanAdens[0],0.06,0.06)
        call DzFrameShow(BanAdens[0], false)
        set BanAdens[1] = DzCreateFrameByTagName("BACKDROP", "", frame, "", 0)
        call DzFrameSetTexture(BanAdens[1],"Bandi_Aden2_0.blp",0)
        call DzFrameSetAbsolutePoint(BanAdens[1],JN_FRAMEPOINT_CENTER,0.4,0.035 +0.045)
        call DzFrameSetSize(BanAdens[1],0.06,0.06)
        call DzFrameShow(BanAdens[1], false)
        
        //필살기 점등프레임
        set BanAdens[2] = DzCreateFrameByTagName("SPRITE", "", BanAdens[1], "", 0)
        call DzFrameSetPoint(BanAdens[2], JN_FRAMEPOINT_BOTTOMLEFT, BanAdens[1] , JN_FRAMEPOINT_CENTER, 0, 0)
        call DzFrameShow(BanAdens[2], false)

        //비술 점등프레임
        set BanAdens2[0]=DzCreateFrameByTagName("SPRITE", "", frame, "", 0)
        call DzFrameSetAbsolutePoint(BanAdens2[0],JN_FRAMEPOINT_BOTTOMLEFT,0.374,0.040 +0.045)
        call DzFrameShow(BanAdens2[0], false)
        set BanAdens2[1]=DzCreateFrameByTagName("SPRITE", "", frame, "", 0)
        call DzFrameSetAbsolutePoint(BanAdens2[1],JN_FRAMEPOINT_BOTTOMLEFT,0.379,0.048 +0.045)
        call DzFrameShow(BanAdens2[1], false)
        set BanAdens2[2]=DzCreateFrameByTagName("SPRITE", "", frame, "", 0)
        call DzFrameSetAbsolutePoint(BanAdens2[2],JN_FRAMEPOINT_BOTTOMLEFT,0.387,0.055 +0.045)
        call DzFrameShow(BanAdens2[2], false)
        set BanAdens2[3]=DzCreateFrameByTagName("SPRITE", "", frame, "", 0)
        call DzFrameSetAbsolutePoint(BanAdens2[3],JN_FRAMEPOINT_BOTTOMLEFT,0.396,0.060 +0.045)
        call DzFrameShow(BanAdens2[3], false)
        set BanAdens2[4]=DzCreateFrameByTagName("SPRITE", "", frame, "", 0)
        call DzFrameSetAbsolutePoint(BanAdens2[4],JN_FRAMEPOINT_BOTTOMLEFT,0.406,0.060 +0.045)
        call DzFrameShow(BanAdens2[4], false)

        //반디 화면필터
        set BanAden = DzCreateFrameByTagName("BACKDROP", "", frame, "", 0)
        //call DzFrameSetTexture(BanAden,"Narmaya_blue.blp",0)
        call DzFrameSetAbsolutePoint(BanAden,JN_FRAMEPOINT_CENTER,0.4,0.3)
        call DzFrameSetSize(BanAden,0.8,0.6)
        call DzFrameShow(BanAden, false)
        
        //나루메아 아덴
        set NarAden = DzCreateFrameByTagName("BACKDROP", "", frame, "", 0)
        call DzFrameSetTexture(NarAden,"Narmaya_blue.blp",0)
        call DzFrameSetAbsolutePoint(NarAden,JN_FRAMEPOINT_CENTER,0.4,0.035+0.045)
        call DzFrameSetSize(NarAden,0.04,0.04)
        call DzFrameShow(NarAden, false)
        set NarAdens[0] = DzCreateFrameByTagName("BACKDROP", "", NarAden, "", 0)
        call DzFrameSetTexture(NarAdens[0],"Narmaya_blue.blp",0)
        call DzFrameSetAbsolutePoint(NarAdens[0],JN_FRAMEPOINT_CENTER,0.4 - 0.035, 0.035 - 0.025 +0.045)
        call DzFrameSetSize(NarAdens[0],0.02,0.02)
        call DzFrameShow(NarAdens[0], false)
        set NarAdens2[0]=DzCreateFrameByTagName("SPRITE", "", NarAden, "", 0)
        call DzFrameSetPoint(NarAdens2[0], JN_FRAMEPOINT_BOTTOMLEFT, NarAdens[0] , JN_FRAMEPOINT_CENTER, 0, 0)
        call DzFrameShow(NarAdens2[0], false)
        set NarAdens[1] = DzCreateFrameByTagName("BACKDROP", "", NarAden, "", 0)
        call DzFrameSetTexture(NarAdens[1],"Narmaya_blue.blp",0)
        call DzFrameSetAbsolutePoint(NarAdens[1],JN_FRAMEPOINT_CENTER,0.4 - 0.050, 0.035 +0.045)
        call DzFrameSetSize(NarAdens[1],0.02,0.02)
        call DzFrameShow(NarAdens[1], false)
        set NarAdens2[1]=DzCreateFrameByTagName("SPRITE", "", NarAden, "", 0)
        call DzFrameSetPoint(NarAdens2[1], JN_FRAMEPOINT_BOTTOMLEFT, NarAdens[1] , JN_FRAMEPOINT_CENTER, 0, 0)
        call DzFrameShow(NarAdens2[1], false)
        set NarAdens[2] = DzCreateFrameByTagName("BACKDROP", "", NarAden, "", 0)
        call DzFrameSetTexture(NarAdens[2],"Narmaya_blue.blp",0)
        call DzFrameSetAbsolutePoint(NarAdens[2],JN_FRAMEPOINT_CENTER,0.4 - 0.035, 0.035 + 0.025 +0.045)
        call DzFrameSetSize(NarAdens[2],0.02,0.02)
        call DzFrameShow(NarAdens[2], false)
        set NarAdens2[2]=DzCreateFrameByTagName("SPRITE", "", NarAden, "", 0)
        call DzFrameSetPoint(NarAdens2[2], JN_FRAMEPOINT_BOTTOMLEFT, NarAdens[2] , JN_FRAMEPOINT_CENTER, 0, 0)
        call DzFrameShow(NarAdens2[2], false)

        set NarAdens[3] = DzCreateFrameByTagName("BACKDROP", "", NarAden, "", 0)
        call DzFrameSetTexture(NarAdens[3],"Narmaya_blue.blp",0)
        call DzFrameSetAbsolutePoint(NarAdens[3],JN_FRAMEPOINT_CENTER,0.4 + 0.035, 0.035 - 0.025 +0.045)
        call DzFrameSetSize(NarAdens[3],0.02,0.02)
        call DzFrameShow(NarAdens[3], false)
        set NarAdens2[3]=DzCreateFrameByTagName("SPRITE", "", NarAden, "", 0)
        call DzFrameSetPoint(NarAdens2[3], JN_FRAMEPOINT_BOTTOMLEFT, NarAdens[3] , JN_FRAMEPOINT_CENTER, 0, 0)
        call DzFrameShow(NarAdens2[3], false)
        set NarAdens[4] = DzCreateFrameByTagName("BACKDROP", "", NarAden, "", 0)
        call DzFrameSetTexture(NarAdens[4],"Narmaya_blue.blp",0)
        call DzFrameSetAbsolutePoint(NarAdens[4],JN_FRAMEPOINT_CENTER,0.4 + 0.050, 0.035  +0.045)
        call DzFrameSetSize(NarAdens[4],0.02,0.02)
        call DzFrameShow(NarAdens[4], false)
        set NarAdens2[4]=DzCreateFrameByTagName("SPRITE", "", NarAden, "", 0)
        call DzFrameSetPoint(NarAdens2[4], JN_FRAMEPOINT_BOTTOMLEFT, NarAdens[4] , JN_FRAMEPOINT_CENTER, 0, 0)
        call DzFrameShow(NarAdens2[4], false)
        set NarAdens[5] = DzCreateFrameByTagName("BACKDROP", "", NarAden, "", 0)
        call DzFrameSetTexture(NarAdens[5],"Narmaya_blue.blp",0)
        call DzFrameSetAbsolutePoint(NarAdens[5],JN_FRAMEPOINT_CENTER,0.4 + 0.035, 0.035 + 0.025 +0.045)
        call DzFrameSetSize(NarAdens[5],0.02,0.02)
        call DzFrameShow(NarAdens[5], false)
        set NarAdens2[5]=DzCreateFrameByTagName("SPRITE", "", NarAden, "", 0)
        call DzFrameSetPoint(NarAdens2[5], JN_FRAMEPOINT_BOTTOMLEFT, NarAdens[5] , JN_FRAMEPOINT_CENTER, 0, 0)
        call DzFrameShow(NarAdens2[5], false)

        //포트레잇
        set frame=DzFrameGetPortrait()
        call DzFrameClearAllPoints(frame)
        call DzFrameSetAbsolutePoint(frame,JN_FRAMEPOINT_BOTTOMLEFT,.180, .040)
        call DzFrameSetAbsolutePoint(frame,JN_FRAMEPOINT_TOPRIGHT,.275, .15)

        call DzFrameShow(heroStatusUI, false)
    endfunction
    
    private function init takes nothing returns nothing
        local trigger t=CreateTrigger()
        local integer index
        
        call TriggerAddAction(t,function Action)
        call TriggerRegisterTimerEventSingle(t,0.30)
    endfunction
endlibrary