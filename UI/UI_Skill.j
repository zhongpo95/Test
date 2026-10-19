library UISkill initializer init requires MemUI, FrameCount
    globals
        integer NarAden
        integer array NarAdens
        integer array NarAdens2
        integer BanAden
        integer array BanAdens
        integer array BanAdens2
        integer heroStatusUI
        // 프리즘 유리 HUD (시안 07): 아덴은 체력바와 스킬창 사이, 스킬 가운데 줄 높이에 둔다
        // ADEN_DY는 2026-10-14 사용자가 스샷으로 지정한 자리에 맞춘 값
        private constant real ADEN_DX = 0.079
        private constant real ADEN_DY = 0.0368
        //반디 완전연소(Z) 남은 시간: 아덴 원 바로 아래 금색 가는 선 + 오른쪽 초 숫자
        //선은 BanAdens[1] 아래 가운데 기준 왼쪽 끝을 고정하고 폭만 BANZ_LINE_W -> 0 으로 줄인다
        integer BanZLine
        integer BanZText
        constant real BANZ_LINE_W = 0.046      //선 최대 폭(아덴 원 0.06보다 조금 좁게)
        constant real BANZ_LINE_H = 0.0018     //선 두께
        private constant real BANZ_LINE_GAP = 0.003   //원 아래 끝과 선 사이
        private constant real BANZ_TEXT_GAP = 0.004   //선 오른쪽 끝(최대 폭 기준)과 숫자 사이
        private constant real BANZ_TEXT_SIZE = 0.0095
    endglobals
    
    private function Action takes nothing returns nothing
        local integer frame

        set heroStatusUI=JNCreateFrameByType("FRAME","heroStatusUI",GetGameplayUI(),"",0)

        //반디 아덴
        set BanAdens[0] = DzCreateFrameByTagName("BACKDROP", "", heroStatusUI, "", 0)
        call DzFrameSetTexture(BanAdens[0],"Bandi_Aden0.blp",0)
        call DzFrameSetAbsolutePoint(BanAdens[0],JN_FRAMEPOINT_CENTER,0.4 +ADEN_DX,0.035 +0.045 +ADEN_DY)
        call DzFrameSetSize(BanAdens[0],0.06,0.06)
        call DzFrameShow(BanAdens[0], false)
        set BanAdens[1] = DzCreateFrameByTagName("BACKDROP", "", heroStatusUI, "", 0)
        call DzFrameSetTexture(BanAdens[1],"Bandi_Aden2_0.blp",0)
        call DzFrameSetAbsolutePoint(BanAdens[1],JN_FRAMEPOINT_CENTER,0.4 +ADEN_DX,0.035 +0.045 +ADEN_DY)
        call DzFrameSetSize(BanAdens[1],0.06,0.06)
        call DzFrameShow(BanAdens[1], false)
        
        //필살기 점등프레임
        set BanAdens[2] = DzCreateFrameByTagName("SPRITE", "", BanAdens[1], "", 0)
        call DzFrameSetPoint(BanAdens[2], JN_FRAMEPOINT_BOTTOMLEFT, BanAdens[1] , JN_FRAMEPOINT_CENTER, 0, 0)
        call DzFrameShow(BanAdens[2], false)

        //완전연소 남은 시간 선·숫자 (HeroBandiZ.j BandiZDraw 가 로컬에서만 그린다)
        set BanZLine = DzCreateFrameByTagName("BACKDROP", "", heroStatusUI, "", 0)
        call DzFrameSetTexture(BanZLine, "textures\\white.blp", 0)
        call DzFrameSetVertexColor(BanZLine, DzGetColor(255, 255, 200, 80))
        call DzFrameSetPoint(BanZLine, JN_FRAMEPOINT_TOPLEFT, BanAdens[1], JN_FRAMEPOINT_BOTTOM, -BANZ_LINE_W*0.5, -BANZ_LINE_GAP)
        call DzFrameSetSize(BanZLine, BANZ_LINE_W, BANZ_LINE_H)
        call DzFrameShow(BanZLine, false)
        set BanZText = DzCreateFrameByTagName("TEXT", "", heroStatusUI, "", 0)
        call DzFrameSetEnable(BanZText, false)
        call DzFrameSetPoint(BanZText, JN_FRAMEPOINT_LEFT, BanAdens[1], JN_FRAMEPOINT_BOTTOM, BANZ_LINE_W*0.5 + BANZ_TEXT_GAP, -BANZ_LINE_GAP - BANZ_LINE_H*0.5)
        call DzFrameSetFont(BanZText, "Fonts\\DFHeiMd.ttf", BANZ_TEXT_SIZE, 0)
        call DzFrameSetTextColor(BanZText, JNConvertColor(255, 255, 200, 80))
        call DzFrameSetText(BanZText, "")
        call DzFrameShow(BanZText, false)

        //비술 점등프레임
        set BanAdens2[0]=DzCreateFrameByTagName("SPRITE", "", heroStatusUI, "", 0)
        call DzFrameSetAbsolutePoint(BanAdens2[0],JN_FRAMEPOINT_BOTTOMLEFT,0.374 +ADEN_DX,0.040 +0.045 +ADEN_DY)
        call DzFrameShow(BanAdens2[0], false)
        set BanAdens2[1]=DzCreateFrameByTagName("SPRITE", "", heroStatusUI, "", 0)
        call DzFrameSetAbsolutePoint(BanAdens2[1],JN_FRAMEPOINT_BOTTOMLEFT,0.379 +ADEN_DX,0.048 +0.045 +ADEN_DY)
        call DzFrameShow(BanAdens2[1], false)
        set BanAdens2[2]=DzCreateFrameByTagName("SPRITE", "", heroStatusUI, "", 0)
        call DzFrameSetAbsolutePoint(BanAdens2[2],JN_FRAMEPOINT_BOTTOMLEFT,0.387 +ADEN_DX,0.055 +0.045 +ADEN_DY)
        call DzFrameShow(BanAdens2[2], false)
        set BanAdens2[3]=DzCreateFrameByTagName("SPRITE", "", heroStatusUI, "", 0)
        call DzFrameSetAbsolutePoint(BanAdens2[3],JN_FRAMEPOINT_BOTTOMLEFT,0.396 +ADEN_DX,0.060 +0.045 +ADEN_DY)
        call DzFrameShow(BanAdens2[3], false)
        set BanAdens2[4]=DzCreateFrameByTagName("SPRITE", "", heroStatusUI, "", 0)
        call DzFrameSetAbsolutePoint(BanAdens2[4],JN_FRAMEPOINT_BOTTOMLEFT,0.406 +ADEN_DX,0.060 +0.045 +ADEN_DY)
        call DzFrameShow(BanAdens2[4], false)

        //반디 화면필터
        set BanAden = DzCreateFrameByTagName("BACKDROP", "", heroStatusUI, "", 0)
        //call DzFrameSetTexture(BanAden,"Narmaya_blue.blp",0)
        call DzFrameSetAbsolutePoint(BanAden,JN_FRAMEPOINT_CENTER,0.4,0.3)
        call DzFrameSetSize(BanAden,0.8,0.6)
        call DzFrameShow(BanAden, false)
        
        //나루메아 아덴
        set NarAden = DzCreateFrameByTagName("BACKDROP", "", heroStatusUI, "", 0)
        call DzFrameSetTexture(NarAden,"Narmaya_blue.blp",0)
        call DzFrameSetAbsolutePoint(NarAden,JN_FRAMEPOINT_CENTER,0.4 +ADEN_DX,0.035+0.045 +ADEN_DY)
        call DzFrameSetSize(NarAden,0.04,0.04)
        call DzFrameShow(NarAden, false)
        set NarAdens[0] = DzCreateFrameByTagName("BACKDROP", "", NarAden, "", 0)
        call DzFrameSetTexture(NarAdens[0],"Narmaya_blue.blp",0)
        call DzFrameSetAbsolutePoint(NarAdens[0],JN_FRAMEPOINT_CENTER,0.4 - 0.035 +ADEN_DX, 0.035 - 0.025 +0.045 +ADEN_DY)
        call DzFrameSetSize(NarAdens[0],0.02,0.02)
        call DzFrameShow(NarAdens[0], false)
        set NarAdens2[0]=DzCreateFrameByTagName("SPRITE", "", NarAden, "", 0)
        call DzFrameSetPoint(NarAdens2[0], JN_FRAMEPOINT_BOTTOMLEFT, NarAdens[0] , JN_FRAMEPOINT_CENTER, 0, 0)
        call DzFrameShow(NarAdens2[0], false)
        set NarAdens[1] = DzCreateFrameByTagName("BACKDROP", "", NarAden, "", 0)
        call DzFrameSetTexture(NarAdens[1],"Narmaya_blue.blp",0)
        call DzFrameSetAbsolutePoint(NarAdens[1],JN_FRAMEPOINT_CENTER,0.4 - 0.050 +ADEN_DX, 0.035 +0.045 +ADEN_DY)
        call DzFrameSetSize(NarAdens[1],0.02,0.02)
        call DzFrameShow(NarAdens[1], false)
        set NarAdens2[1]=DzCreateFrameByTagName("SPRITE", "", NarAden, "", 0)
        call DzFrameSetPoint(NarAdens2[1], JN_FRAMEPOINT_BOTTOMLEFT, NarAdens[1] , JN_FRAMEPOINT_CENTER, 0, 0)
        call DzFrameShow(NarAdens2[1], false)
        set NarAdens[2] = DzCreateFrameByTagName("BACKDROP", "", NarAden, "", 0)
        call DzFrameSetTexture(NarAdens[2],"Narmaya_blue.blp",0)
        call DzFrameSetAbsolutePoint(NarAdens[2],JN_FRAMEPOINT_CENTER,0.4 - 0.035 +ADEN_DX, 0.035 + 0.025 +0.045 +ADEN_DY)
        call DzFrameSetSize(NarAdens[2],0.02,0.02)
        call DzFrameShow(NarAdens[2], false)
        set NarAdens2[2]=DzCreateFrameByTagName("SPRITE", "", NarAden, "", 0)
        call DzFrameSetPoint(NarAdens2[2], JN_FRAMEPOINT_BOTTOMLEFT, NarAdens[2] , JN_FRAMEPOINT_CENTER, 0, 0)
        call DzFrameShow(NarAdens2[2], false)

        set NarAdens[3] = DzCreateFrameByTagName("BACKDROP", "", NarAden, "", 0)
        call DzFrameSetTexture(NarAdens[3],"Narmaya_blue.blp",0)
        call DzFrameSetAbsolutePoint(NarAdens[3],JN_FRAMEPOINT_CENTER,0.4 + 0.035 +ADEN_DX, 0.035 - 0.025 +0.045 +ADEN_DY)
        call DzFrameSetSize(NarAdens[3],0.02,0.02)
        call DzFrameShow(NarAdens[3], false)
        set NarAdens2[3]=DzCreateFrameByTagName("SPRITE", "", NarAden, "", 0)
        call DzFrameSetPoint(NarAdens2[3], JN_FRAMEPOINT_BOTTOMLEFT, NarAdens[3] , JN_FRAMEPOINT_CENTER, 0, 0)
        call DzFrameShow(NarAdens2[3], false)
        set NarAdens[4] = DzCreateFrameByTagName("BACKDROP", "", NarAden, "", 0)
        call DzFrameSetTexture(NarAdens[4],"Narmaya_blue.blp",0)
        call DzFrameSetAbsolutePoint(NarAdens[4],JN_FRAMEPOINT_CENTER,0.4 + 0.050 +ADEN_DX, 0.035  +0.045 +ADEN_DY)
        call DzFrameSetSize(NarAdens[4],0.02,0.02)
        call DzFrameShow(NarAdens[4], false)
        set NarAdens2[4]=DzCreateFrameByTagName("SPRITE", "", NarAden, "", 0)
        call DzFrameSetPoint(NarAdens2[4], JN_FRAMEPOINT_BOTTOMLEFT, NarAdens[4] , JN_FRAMEPOINT_CENTER, 0, 0)
        call DzFrameShow(NarAdens2[4], false)
        set NarAdens[5] = DzCreateFrameByTagName("BACKDROP", "", NarAden, "", 0)
        call DzFrameSetTexture(NarAdens[5],"Narmaya_blue.blp",0)
        call DzFrameSetAbsolutePoint(NarAdens[5],JN_FRAMEPOINT_CENTER,0.4 + 0.035 +ADEN_DX, 0.035 + 0.025 +0.045 +ADEN_DY)
        call DzFrameSetSize(NarAdens[5],0.02,0.02)
        call DzFrameShow(NarAdens[5], false)
        set NarAdens2[5]=DzCreateFrameByTagName("SPRITE", "", NarAden, "", 0)
        call DzFrameSetPoint(NarAdens2[5], JN_FRAMEPOINT_BOTTOMLEFT, NarAdens[5] , JN_FRAMEPOINT_CENTER, 0, 0)
        call DzFrameShow(NarAdens2[5], false)

        //포트레잇: 3D 포트레잇 대신 UISkillHUD의 영웅 이미지를 쓴다
        //강화 창을 닫을 때 포트레잇을 다시 켜므로 숨기지 않고 화면 아래로 뺀다
        set frame=DzFrameGetPortrait()
        call DzFrameClearAllPoints(frame)
        call DzFrameSetAbsolutePoint(frame,JN_FRAMEPOINT_BOTTOMLEFT,.180, -.200)
        call DzFrameSetAbsolutePoint(frame,JN_FRAMEPOINT_TOPRIGHT,.275, -.090)

        call DzFrameShow(heroStatusUI, false)
    endfunction

    private function init takes nothing returns nothing
        local trigger t=CreateTrigger()
        local integer index
        
        call TriggerAddAction(t,function Action)
        call TriggerRegisterTimerEventSingle(t,0.30)
    endfunction
endlibrary
