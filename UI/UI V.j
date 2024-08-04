library UIV initializer init
    globals
        integer Ogiframe_1 = 0
        integer Ogiframe_2 = 0
        integer Ogiframe_3 = 0
        integer Ogiframe_4 = 0
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
    endglobals

    
    private function CutinLimit2 takes nothing returns nothing
        local tick t = tick.getExpired()

        call DzFrameShow(Ogiframe_1, false)
        call DzFrameShow(Ogiframe_2, false)
        call DzFrameShow(Ogiframe_3, false)
        call DzFrameShow(Ogiframe_4, false)

        call t.destroy()
    endfunction

    private function limit3 takes nothing returns nothing
        call DelayKill(CreateUnit(GetOwningPlayer(GetEnumUnit()),'e01W',0,0,0), 3.0)

        call Sound3D(GetEnumUnit(),'A02B')
        
        if GetLocalPlayer() == GetOwningPlayer(GetEnumUnit()) then
            call DzFrameSetModel(Ogiframe_1, "VFX_HolyLight.mdx", 0, 0)
            call DzFrameShow(Ogiframe_1, true)
            call DzFrameSetModel(Ogiframe_2, "VFX_ERE_LightningField3Y.mdx", 0, 0)
            call DzFrameShow(Ogiframe_2, true)
            call DzFrameShow(Ogiframe_3, true)
            call DzFrameSetModel(Ogiframe_4, "Empyrean Nova.mdx", 0, 0)
            call DzFrameShow(Ogiframe_4, true)
        endif
    endfunction

    function CutinLimit takes group g returns nothing
        local tick t = tick.create(0)
        
        call ForGroup(g, function limit3)
        call t.start( 3, false, function CutinLimit2 )
    endfunction

    private function EffectFunction takes nothing returns nothing
        //레이지소리
        call Sound3D(MainUnit[0],'A02B')
    endfunction

    function VAction takes nothing returns nothing
        local tick t = tick.create(0)

        if GetLocalPlayer() == GetOwningPlayer(GetEnumUnit()) then
        endif
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
    endfunction

    private function Action takes nothing returns nothing
        set Ogiframe_1=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", 0)
        call DzFrameSetAbsolutePoint(Ogiframe_1, JN_FRAMEPOINT_BOTTOMLEFT,0.4,0.15)
        set Ogiframe_2=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", 0)
        call DzFrameSetAbsolutePoint(Ogiframe_2, JN_FRAMEPOINT_BOTTOMLEFT,0.4,0.15)
        set Ogiframe_3=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "template", 0)
        call DzFrameSetTexture(Ogiframe_3, "V.blp", 0)
        call DzFrameSetSize(Ogiframe_3, 0.030, 0.030)
        call DzFrameSetAbsolutePoint(Ogiframe_3, JN_FRAMEPOINT_CENTER, 0.4, 0.15)
        call DzFrameShow(Ogiframe_3, false)
        set Ogiframe_4=DzCreateFrameByTagName("SPRITE", "", DzGetGameUI(), "", 0)
        call DzFrameSetAbsolutePoint(Ogiframe_4, JN_FRAMEPOINT_BOTTOMLEFT,0.4,0.15)

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
    endfunction
    
    private function init takes nothing returns nothing
        local trigger t=CreateTrigger()
        call TriggerRegisterTimerEventSingle(t,5.)
        call TriggerAddAction(t,function Action)
        set t = null
    endfunction
endlibrary