library UISkill initializer init
    globals
        integer array skillbuttonframe
        integer NarAden
        integer NarAden2
    endglobals
    
    private function Action takes nothing returns nothing
        local integer frame
        local integer frame2
        local integer frame3
        local real x
        local real x2
        local real y
        local real y2
        
        set x = 0.192
        set x2 = 0.207
        set y = 0.0275
        set y2 = 0.0225
        set frame=JNCreateFrameByType("FRAME","heroStatusUI",DzGetGameUI(),"",0)
                
        set frame2=JNCreateFrameByType("BACKDROP","Command01",frame,"",0)
        call DzFrameSetTexture(frame2,"Transparent.blp",0)
        call DzFrameSetSize(frame2,0.04,0.04)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_BOTTOMLEFT,x,0.0215)
        set skillbuttonframe[0]=JNCreateFrameByType("TEXT","",frame,"",0)
        call DzFrameSetSize(skillbuttonframe[0],0.007,0.00)
        call DzFrameSetPoint(skillbuttonframe[0],JN_FRAMEPOINT_BOTTOM,frame2,JN_FRAMEPOINT_BOTTOM,-0.007,0.0075)
        call DzFrameSetText(skillbuttonframe[0],"Q")

        set frame2=JNCreateFrameByType("BACKDROP","Command02",frame,"",0)
        call DzFrameSetTexture(frame2,"Transparent.blp",0)
        call DzFrameSetSize(frame2,0.04,0.04)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_BOTTOMLEFT,x+(y*1),0.0215)
        set skillbuttonframe[1]=JNCreateFrameByType("TEXT","",frame2,"",0)
        call DzFrameSetSize(skillbuttonframe[1],0.007,0.00)
        call DzFrameSetPoint(skillbuttonframe[1],JN_FRAMEPOINT_BOTTOM,frame2,JN_FRAMEPOINT_BOTTOM,-0.007,0.0075)
        call DzFrameSetText(skillbuttonframe[1],"W")

        set frame2=JNCreateFrameByType("BACKDROP","Command03",frame,"",0)
        call DzFrameSetTexture(frame2,"Transparent.blp",0)
        call DzFrameSetSize(frame2,0.04,0.04)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_BOTTOMLEFT,x+(y*2),0.0215)
        set skillbuttonframe[2]=JNCreateFrameByType("TEXT","",frame2,"",0)
        call DzFrameSetSize(skillbuttonframe[2],0.007,0.00)
        call DzFrameSetPoint(skillbuttonframe[2],JN_FRAMEPOINT_BOTTOM,frame2,JN_FRAMEPOINT_BOTTOM,-0.007,0.0075)
        call DzFrameSetText(skillbuttonframe[2],"E")

        set frame2=JNCreateFrameByType("BACKDROP","Command04",frame,"",0)
        call DzFrameSetTexture(frame2,"Transparent.blp",0)
        call DzFrameSetSize(frame2,0.04,0.04)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_BOTTOMLEFT,x+(y*3),0.0215)
        set skillbuttonframe[3]=JNCreateFrameByType("TEXT","",frame2,"",0)
        call DzFrameSetSize(skillbuttonframe[3],0.007,0.00)
        call DzFrameSetPoint(skillbuttonframe[3],JN_FRAMEPOINT_BOTTOM,frame2,JN_FRAMEPOINT_BOTTOM,-0.007,0.0075)
        call DzFrameSetText(skillbuttonframe[3],"R")

        set frame2=JNCreateFrameByType("BACKDROP","Command05",frame,"",0)
        call DzFrameSetTexture(frame2,"Transparent.blp",0)
        call DzFrameSetSize(frame2,0.04,0.04)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_BOTTOMLEFT,x2,-0.006)
        set skillbuttonframe[4]=JNCreateFrameByType("TEXT","",frame2,"",0)
        call DzFrameSetSize(skillbuttonframe[4],0.007,0.00)
        call DzFrameSetPoint(skillbuttonframe[4],JN_FRAMEPOINT_BOTTOM,frame2,JN_FRAMEPOINT_BOTTOM,-0.007,0.002)
        call DzFrameSetText(skillbuttonframe[4],"A")

        set frame2=JNCreateFrameByType("BACKDROP","Command06",frame,"",0)
        call DzFrameSetTexture(frame2,"Transparent.blp",0)
        call DzFrameSetSize(frame2,0.04,0.04)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_BOTTOMLEFT,x2+(y*1),-0.006)
        set skillbuttonframe[5]=JNCreateFrameByType("TEXT","",frame2,"",0)
        call DzFrameSetSize(skillbuttonframe[5],0.007,0.00)
        call DzFrameSetPoint(skillbuttonframe[5],JN_FRAMEPOINT_BOTTOM,frame2,JN_FRAMEPOINT_BOTTOM,-0.007,0.002)
        call DzFrameSetText(skillbuttonframe[5],"S")

        set frame2=JNCreateFrameByType("BACKDROP","Command07",frame,"",0)
        call DzFrameSetTexture(frame2,"Transparent.blp",0)
        call DzFrameSetSize(frame2,0.04,0.04)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_BOTTOMLEFT,x2+(y*2),-0.006)
        set skillbuttonframe[6]=JNCreateFrameByType("TEXT","",frame2,"",0)
        call DzFrameSetSize(skillbuttonframe[6],0.007,0.00)
        call DzFrameSetPoint(skillbuttonframe[6],JN_FRAMEPOINT_BOTTOM,frame2,JN_FRAMEPOINT_BOTTOM,-0.007,0.002)
        call DzFrameSetText(skillbuttonframe[6],"D")

        set frame2=JNCreateFrameByType("BACKDROP","Command08",frame,"",0)
        call DzFrameSetTexture(frame2,"Transparent.blp",0)
        call DzFrameSetSize(frame2,0.04,0.04)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_BOTTOMLEFT,x2+(y*3),-0.006)
        set skillbuttonframe[7]=JNCreateFrameByType("TEXT","",frame,"",0)
        call DzFrameSetSize(skillbuttonframe[7],0.007,0.00)
        call DzFrameSetPoint(skillbuttonframe[7],JN_FRAMEPOINT_BOTTOM,frame2,JN_FRAMEPOINT_BOTTOM,-0.007,0.002)
        call DzFrameSetText(skillbuttonframe[7],"F")

        //set frame2=JNCreateFrameByType("BACKDROP","Command09",frame,"",0)
        //call DzFrameSetTexture(frame2,"Transparent.blp",0)
        //call DzFrameSetSize(frame2,0.04,0.04)
        //call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_BOTTOMLEFT,0.390,0.000)
        //set skillbuttonframe[8]=JNCreateFrameByType("TEXT","",frame,"",0)
        //call DzFrameSetSize(skillbuttonframe[8],0.007,0.00)
        //call DzFrameSetPoint(skillbuttonframe[8],JN_FRAMEPOINT_BOTTOM,frame2,JN_FRAMEPOINT_BOTTOM,-0.007,0.007)
        //call DzFrameSetText(skillbuttonframe[8],"Z")
        set NarAden = DzCreateFrameByTagName("BACKDROP", "", frame, "", 0)
        call DzFrameSetTexture(NarAden,"Narmaya_blue.blp",0)
        call DzFrameSetAbsolutePoint(NarAden,JN_FRAMEPOINT_CENTER,0.4,0.035)
        call DzFrameSetSize(NarAden,0.04,0.04)
        call DzFrameShow(NarAden, false)
        set skillbuttonframe[8]=JNCreateFrameByType("TEXT","",frame,"",0)
        call DzFrameSetSize(skillbuttonframe[8],0.007,0.00)
        call DzFrameSetAbsolutePoint(skillbuttonframe[8],JN_FRAMEPOINT_CENTER,0.4,0.015)
        call DzFrameSetText(skillbuttonframe[8],"Z")
        call DzFrameShow(skillbuttonframe[8],false)
        set NarAden2=DzCreateFrameByTagName("SPRITE", "", NarAden, "", 0)
        call DzFrameSetPoint(NarAden2, JN_FRAMEPOINT_BOTTOMLEFT, NarAden , JN_FRAMEPOINT_CENTER, 0, 0)
        call DzFrameShow(NarAden2, false)

        set frame2=JNCreateFrameByType("BACKDROP","Command10",frame,"",0)
        call DzFrameSetTexture(frame2,"Transparent.blp",0)
        call DzFrameSetSize(frame2,0.04,0.04)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_BOTTOMLEFT,x+(y*13)+0.025,-0.001)
        set skillbuttonframe[9]=JNCreateFrameByType("TEXT","",frame,"",0)
        call DzFrameSetSize(skillbuttonframe[9],0.007,0.00)
        call DzFrameSetPoint(skillbuttonframe[9],JN_FRAMEPOINT_BOTTOM,frame2,JN_FRAMEPOINT_BOTTOM,-0.007,0.000)
        call DzFrameSetText(skillbuttonframe[9],"X")

        set frame2=JNCreateFrameByType("BACKDROP","Command11",frame,"",0)
        call DzFrameSetTexture(frame2,"Transparent.blp",0)
        call DzFrameSetSize(frame2,0.04,0.04)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_BOTTOMLEFT,0.150,0.012)
        set skillbuttonframe[10]=JNCreateFrameByType("TEXT","",frame,"",0)
        call DzFrameSetSize(skillbuttonframe[10],0.007,0.00)
        call DzFrameSetPoint(skillbuttonframe[10],JN_FRAMEPOINT_BOTTOM,frame2,JN_FRAMEPOINT_BOTTOM,-0.0075,0.007)
        call DzFrameSetText(skillbuttonframe[10],"V")
        
        set frame2=JNCreateFrameByType("BACKDROP","Command12",frame,"",0)
        call DzFrameSetTexture(frame2,"Transparent.blp",0)
        call DzFrameSetSize(frame2,0.04,0.04)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_BOTTOMLEFT,0.485,-0.006)
        set frame3=JNCreateFrameByType("TEXT","",frame,"",0)
        call DzFrameSetSize(frame3,0.007,0.00)
        call DzFrameSetPoint(frame3,JN_FRAMEPOINT_BOTTOM,frame2,JN_FRAMEPOINT_BOTTOM,-0.0075,0)
        call DzFrameSetText(frame3,"1")
        
        set frame2=JNCreateFrameByType("BACKDROP","Command13",frame,"",0)
        call DzFrameSetTexture(frame2,"Transparent.blp",0)
        call DzFrameSetSize(frame2,0.04,0.04)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_BOTTOMLEFT,0.485+(y2*1),-0.006)
        set frame3=JNCreateFrameByType("TEXT","",frame,"",0)
        call DzFrameSetSize(frame3,0.007,0.00)
        call DzFrameSetPoint(frame3,JN_FRAMEPOINT_BOTTOM,frame2,JN_FRAMEPOINT_BOTTOM,-0.0075,0)
        call DzFrameSetText(frame3,"2")
        
        set frame2=JNCreateFrameByType("BACKDROP","Command14",frame,"",0)
        call DzFrameSetTexture(frame2,"Transparent.blp",0)
        call DzFrameSetSize(frame2,0.04,0.04)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_BOTTOMLEFT,0.485+(y2*2),-0.006)
        set frame3=JNCreateFrameByType("TEXT","",frame,"",0)
        call DzFrameSetSize(frame3,0.007,0.00)
        call DzFrameSetPoint(frame3,JN_FRAMEPOINT_BOTTOM,frame2,JN_FRAMEPOINT_BOTTOM,-0.0075,0)
        call DzFrameSetText(frame3,"3")
        
        set frame2=JNCreateFrameByType("BACKDROP","Command15",frame,"",0)
        call DzFrameSetTexture(frame2,"Transparent.blp",0)
        call DzFrameSetSize(frame2,0.04,0.04)
        call DzFrameSetAbsolutePoint(frame2,JN_FRAMEPOINT_BOTTOMLEFT,0.485+(y2*3),-0.006)
        set frame3=JNCreateFrameByType("TEXT","",frame,"",0)
        call DzFrameSetSize(frame3,0.007,0.00)
        call DzFrameSetPoint(frame3,JN_FRAMEPOINT_BOTTOM,frame2,JN_FRAMEPOINT_BOTTOM,-0.0075,0)
        call DzFrameSetText(frame3,"4")

        set frame = DzFrameGetCommandBarButton(0,0)
        call DzFrameSetSize(frame,.0275,.0275)
        call DzFrameSetPoint(DzFrameGetCommandBarButton(0,0),JN_FRAMEPOINT_TOPLEFT,JNGetFrameByName("Command01",0),JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        set frame = DzFrameGetCommandBarButton(0,1)
        call DzFrameSetSize(frame,.0275,.0275)
        call DzFrameSetPoint(DzFrameGetCommandBarButton(0,1),JN_FRAMEPOINT_TOPLEFT,JNGetFrameByName("Command02",0),JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        set frame = DzFrameGetCommandBarButton(0,2)
        call DzFrameSetSize(frame,.0275,.0275)
        call DzFrameSetPoint(DzFrameGetCommandBarButton(0,2),JN_FRAMEPOINT_TOPLEFT,JNGetFrameByName("Command03",0),JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        set frame = DzFrameGetCommandBarButton(0,3)
        call DzFrameSetSize(frame,.0275,.0275)
        call DzFrameSetPoint(DzFrameGetCommandBarButton(0,3),JN_FRAMEPOINT_TOPLEFT,JNGetFrameByName("Command04",0),JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        set frame = DzFrameGetCommandBarButton(1,0)
        call DzFrameSetSize(frame,.0275,.0275)
        call DzFrameSetPoint(DzFrameGetCommandBarButton(1,0),JN_FRAMEPOINT_TOPLEFT,JNGetFrameByName("Command05",0),JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        set frame = DzFrameGetCommandBarButton(1,1)
        call DzFrameSetSize(frame,.0275,.0275)
        call DzFrameSetPoint(DzFrameGetCommandBarButton(1,1),JN_FRAMEPOINT_TOPLEFT,JNGetFrameByName("Command06",0),JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        set frame = DzFrameGetCommandBarButton(1,2)
        call DzFrameSetSize(frame,.0275,.0275)
        call DzFrameSetPoint(DzFrameGetCommandBarButton(1,2),JN_FRAMEPOINT_TOPLEFT,JNGetFrameByName("Command07",0),JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        set frame = DzFrameGetCommandBarButton(1,3)
        call DzFrameSetSize(frame,.0275,.0275)
        call DzFrameSetPoint(DzFrameGetCommandBarButton(1,3),JN_FRAMEPOINT_TOPLEFT,JNGetFrameByName("Command08",0),JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        set frame = DzFrameGetCommandBarButton(2,0)
        call DzFrameSetSize(frame,.0275,.0275)
        call DzFrameSetPoint(DzFrameGetCommandBarButton(2,0),JN_FRAMEPOINT_TOPLEFT,JNGetFrameByName("Command09",0),JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        set frame = DzFrameGetCommandBarButton(2,1)
        call DzFrameSetSize(frame,.0275,.0275)
        call DzFrameSetPoint(DzFrameGetCommandBarButton(2,1),JN_FRAMEPOINT_TOPLEFT,JNGetFrameByName("Command10",0),JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        set frame = DzFrameGetCommandBarButton(2,2)
        call DzFrameSetSize(frame,.0275,.0275)
        call DzFrameSetPoint(DzFrameGetCommandBarButton(2,2),JN_FRAMEPOINT_TOPLEFT,JNGetFrameByName("Command11",0),JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        
        set frame = DzFrameGetItemBarButton(0)
        call DzFrameSetSize(frame,.0225,.0225)
        call DzFrameSetPoint(DzFrameGetItemBarButton(0),JN_FRAMEPOINT_TOPLEFT,JNGetFrameByName("Command12",0),JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        set frame = DzFrameGetItemBarButton(1)
        call DzFrameSetSize(frame,.0225,.0225)
        call DzFrameSetPoint(DzFrameGetItemBarButton(1),JN_FRAMEPOINT_TOPLEFT,JNGetFrameByName("Command13",0),JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        set frame = DzFrameGetItemBarButton(2)
        call DzFrameSetSize(frame,.0225,.0225)
        call DzFrameSetPoint(DzFrameGetItemBarButton(2),JN_FRAMEPOINT_TOPLEFT,JNGetFrameByName("Command14",0),JN_FRAMEPOINT_TOPLEFT,0.0,0.0)
        set frame = DzFrameGetItemBarButton(3)
        call DzFrameSetSize(frame,.0225,.0225)
        call DzFrameSetPoint(DzFrameGetItemBarButton(3),JN_FRAMEPOINT_TOPLEFT,JNGetFrameByName("Command15",0),JN_FRAMEPOINT_TOPLEFT,0.0,0.0)

        call DzFrameShow(JNGetFrameByName("heroStatusUI",0), false)
    endfunction
    
    private function init takes nothing returns nothing
        local trigger t=CreateTrigger()
        local integer index
        
        call TriggerAddAction(t,function Action)
        call TriggerRegisterTimerEventSingle(t,0.10)
    endfunction
endlibrary