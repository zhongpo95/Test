library UIMap initializer init requires DataUnit, FrameCount
    globals
        integer FMap_OpenButton                       //스킬창 여는 버튼
        integer FMap_OpenButtonBD                     //스킬창 여는 버튼 백드롭
        integer FMap_BackDrop                         //스킬창 배경
        integer FMap_CancelButton                     //스킬창 취소버튼
        integer array FMap_Button[16][4]              //길버튼
        integer array FMap_ButtonSP[16][4]            //길버튼 스프라이트
        integer array FMap_ButtonBackDrop[16][4]      //길버튼 백드롭
        integer array FMap_LineBackDrop        //라인 백드롭
        
        integer FMap_LB                     //X버튼
        integer FMap_L                      //X버튼
        integer FMap_L2                     //X버튼
        integer FMap_RB
        integer FMap_R
        integer FMap_R2
        
        integer FMap_SelectBBD
        integer FMap_SelectBT
        integer FMap_SelectB

        boolean array FMap_OnOff                      //플레이어 온오프

        private integer NowList = 0                 //현재리스트
        private constant integer MaxList = 2
        integer ClickRoom = 0
        integer Myroom = 0

        //전역변수
        string array MapIcon

        // 1 = 시작위치, 2 = 일반전투, 3 = 사건, 4 = 사건 및 전투, 5 = 휴식, 6 = 상점, 7 = 엘리트, 8 = 중간보스, 9 = 보스
        // 스프라이트 0 = 휴식, 1 = 전투, 2 = 사건, 3 = 상점, 4 = 엘리트, 5 = 중간보스, 6 = 보스
        integer array MapLineSelet[16][4]
    endglobals

    function SetMapLine takes integer pid returns nothing
        local integer i = 0

        set MapLineSelet[0][0] = 1

        if GetRandomInt(0,3) <= 2 then
            set MapLineSelet[1][0] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[1][0],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[1][0], "MapLine1.mdx", 0, 0)
        else
            set MapLineSelet[1][0] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[1][0],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[1][0], "MapLine2.mdx", 0, 0)
        endif
        if GetRandomInt(0,3) <= 2 then
            set MapLineSelet[1][1] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[1][1],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[1][1], "MapLine1.mdx", 0, 0)
        else
            set MapLineSelet[1][1] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[1][1],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[1][1], "MapLine2.mdx", 0, 0)
        endif
        if GetRandomInt(0,3) <= 2 then
            set MapLineSelet[1][2] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[1][2],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[1][2], "MapLine1.mdx", 0, 0)
        else
            set MapLineSelet[1][2] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[1][2],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[1][2], "MapLine2.mdx", 0, 0)
        endif
        if GetRandomInt(0,3) <= 2 then
            set MapLineSelet[1][3] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[1][3],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[1][3], "MapLine1.mdx", 0, 0)
        else
            set MapLineSelet[1][3] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[1][3],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[1][3], "MapLine2.mdx", 0, 0)
        endif


        if GetRandomInt(0,3) <= 2 then
            set MapLineSelet[2][0] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[2][0],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[2][0], "MapLine1.mdx", 0, 0)
        else
            set MapLineSelet[2][0] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[2][0],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[2][0], "MapLine2.mdx", 0, 0)
        endif
        if GetRandomInt(0,3) <= 2 then
            set MapLineSelet[2][1] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[2][1],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[2][1], "MapLine1.mdx", 0, 0)
        else
            set MapLineSelet[2][1] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[2][1],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[2][1], "MapLine2.mdx", 0, 0)
        endif
        if GetRandomInt(0,3) <= 2 then
            set MapLineSelet[2][2] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[2][2],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[2][2], "MapLine1.mdx", 0, 0)
        else
            set MapLineSelet[2][2] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[2][2],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[2][2], "MapLine2.mdx", 0, 0)
        endif
        if GetRandomInt(0,3) <= 2 then
            set MapLineSelet[2][3] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[2][3],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[2][3], "MapLine1.mdx", 0, 0)
        else
            set MapLineSelet[2][3] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[2][3],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[2][3], "MapLine2.mdx", 0, 0)
        endif

        if GetRandomInt(0,3) <= 2 then
            set MapLineSelet[3][0] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[3][0],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[3][0], "MapLine1.mdx", 0, 0)
        else
            set MapLineSelet[3][0] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[3][0],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[3][0], "MapLine2.mdx", 0, 0)
        endif
        if GetRandomInt(0,3) <= 2 then
            set MapLineSelet[3][1] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[3][1],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[3][1], "MapLine1.mdx", 0, 0)
        else
            set MapLineSelet[3][1] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[3][1],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[3][1], "MapLine2.mdx", 0, 0)
        endif
        if GetRandomInt(0,3) <= 2 then
            set MapLineSelet[3][2] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[3][2],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[3][2], "MapLine1.mdx", 0, 0)
        else
            set MapLineSelet[3][2] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[3][2],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[3][2], "MapLine2.mdx", 0, 0)
        endif
        if GetRandomInt(0,3) <= 2 then
            set MapLineSelet[3][3] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[3][3],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[3][3], "MapLine1.mdx", 0, 0)
        else
            set MapLineSelet[3][3] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[3][3],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[3][3], "MapLine2.mdx", 0, 0)
        endif
        
        set i = GetRandomInt(0,2)
        if i == 0 then
            set MapLineSelet[4][0] = 5
            call DzFrameSetTexture(FMap_ButtonBackDrop[4][0],MapIcon[0], 0)
            call DzFrameSetModel(FMap_ButtonSP[4][0], "MapLine0.mdx", 0, 0)
        elseif i == 1 then
            set MapLineSelet[4][0] = 6
            call DzFrameSetTexture(FMap_ButtonBackDrop[4][0],MapIcon[8], 0)
            call DzFrameSetModel(FMap_ButtonSP[4][0], "MapLine3.mdx", 0, 0)
        elseif i == 2 then
            set MapLineSelet[4][0] = 7
            call DzFrameSetTexture(FMap_ButtonBackDrop[4][0],MapIcon[10], 0)
            call DzFrameSetModel(FMap_ButtonSP[4][0], "MapLine4.mdx", 0, 0)
        endif
        set i = GetRandomInt(0,2)
        if i == 0 then
            set MapLineSelet[4][1] = 5
            call DzFrameSetTexture(FMap_ButtonBackDrop[4][1],MapIcon[0], 0)
            call DzFrameSetModel(FMap_ButtonSP[4][1], "MapLine0.mdx", 0, 0)
        elseif i == 1 then
            set MapLineSelet[4][1] = 6
            call DzFrameSetTexture(FMap_ButtonBackDrop[4][1],MapIcon[8], 0)
            call DzFrameSetModel(FMap_ButtonSP[4][1], "MapLine3.mdx", 0, 0)
        elseif i == 2 then
            set MapLineSelet[4][1] = 7
            call DzFrameSetTexture(FMap_ButtonBackDrop[4][1],MapIcon[10], 0)
            call DzFrameSetModel(FMap_ButtonSP[4][1], "MapLine4.mdx", 0, 0)
        endif
        set i = GetRandomInt(0,2)
        if i == 0 then
            set MapLineSelet[4][2] = 5
            call DzFrameSetTexture(FMap_ButtonBackDrop[4][2],MapIcon[0], 0)
            call DzFrameSetModel(FMap_ButtonSP[4][2], "MapLine0.mdx", 0, 0)
        elseif i == 1 then
            set MapLineSelet[4][2] = 6
            call DzFrameSetTexture(FMap_ButtonBackDrop[4][2],MapIcon[8], 0)
            call DzFrameSetModel(FMap_ButtonSP[4][2], "MapLine3.mdx", 0, 0)
        elseif i == 2 then
            set MapLineSelet[4][2] = 7
            call DzFrameSetTexture(FMap_ButtonBackDrop[4][2],MapIcon[10], 0)
            call DzFrameSetModel(FMap_ButtonSP[4][2], "MapLine4.mdx", 0, 0)
        endif
        set i = GetRandomInt(0,2)
        if i == 0 then
            set MapLineSelet[4][3] = 5
            call DzFrameSetTexture(FMap_ButtonBackDrop[4][3],MapIcon[0], 0)
            call DzFrameSetModel(FMap_ButtonSP[4][3], "MapLine0.mdx", 0, 0)
        elseif i == 1 then
            set MapLineSelet[4][3] = 6
            call DzFrameSetTexture(FMap_ButtonBackDrop[4][3],MapIcon[8], 0)
            call DzFrameSetModel(FMap_ButtonSP[4][3], "MapLine3.mdx", 0, 0)
        elseif i == 2 then
            set MapLineSelet[4][3] = 7
            call DzFrameSetTexture(FMap_ButtonBackDrop[4][3],MapIcon[10], 0)
            call DzFrameSetModel(FMap_ButtonSP[4][3], "MapLine4.mdx", 0, 0)
        endif

        set MapLineSelet[5][0] = 8
        call DzFrameSetTexture(FMap_ButtonBackDrop[5][0],MapIcon[12], 0)
        call DzFrameSetModel(FMap_ButtonSP[5][0], "MapLine5.mdx", 0, 0)

        
        if GetRandomInt(0,3) <= 2 then
            set MapLineSelet[6][0] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[6][0],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[6][0], "MapLine1.mdx", 0, 0)
        else
            set MapLineSelet[6][0] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[6][0],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[6][0], "MapLine2.mdx", 0, 0)
        endif
        if GetRandomInt(0,3) <= 2 then
            set MapLineSelet[6][1] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[6][1],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[6][1], "MapLine1.mdx", 0, 0)
        else
            set MapLineSelet[6][1] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[6][1],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[6][1], "MapLine2.mdx", 0, 0)
        endif
        if GetRandomInt(0,3) <= 2 then
            set MapLineSelet[6][2] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[6][2],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[6][2], "MapLine1.mdx", 0, 0)
        else
            set MapLineSelet[6][2] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[6][2],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[6][2], "MapLine2.mdx", 0, 0)
        endif
        if GetRandomInt(0,3) <= 2 then
            set MapLineSelet[6][3] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[6][3],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[6][3], "MapLine1.mdx", 0, 0)
        else
            set MapLineSelet[6][3] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[6][3],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[6][3], "MapLine2.mdx", 0, 0)
        endif
        if GetRandomInt(0,3) <= 2 then
            set MapLineSelet[7][0] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[7][0],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[7][0], "MapLine1.mdx", 0, 0)
        else
            set MapLineSelet[7][0] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[7][0],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[7][0], "MapLine2.mdx", 0, 0)
        endif
        if GetRandomInt(0,3) <= 2 then
            set MapLineSelet[7][1] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[7][1],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[7][1], "MapLine1.mdx", 0, 0)
        else
            set MapLineSelet[7][1] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[7][1],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[7][1], "MapLine2.mdx", 0, 0)
        endif
        if GetRandomInt(0,3) <= 2 then
            set MapLineSelet[7][2] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[7][2],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[7][2], "MapLine1.mdx", 0, 0)
        else
            set MapLineSelet[7][2] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[7][2],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[7][2], "MapLine2.mdx", 0, 0)
        endif
        if GetRandomInt(0,3) <= 2 then
            set MapLineSelet[7][3] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[7][3],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[7][3], "MapLine1.mdx", 0, 0)
        else
            set MapLineSelet[7][3] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[7][3],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[7][3], "MapLine2.mdx", 0, 0)
        endif

        if GetRandomInt(0,1) == 0 then
            set MapLineSelet[8][0] = 5
            call DzFrameSetTexture(FMap_ButtonBackDrop[8][0],MapIcon[0], 0)
            call DzFrameSetModel(FMap_ButtonSP[8][0], "MapLine0.mdx", 0, 0)
        else
            set MapLineSelet[8][0] = 6
            call DzFrameSetTexture(FMap_ButtonBackDrop[8][0],MapIcon[8], 0)
            call DzFrameSetModel(FMap_ButtonSP[8][0], "MapLine5.mdx", 0, 0)
        endif
        if GetRandomInt(0,1) == 0 then
            set MapLineSelet[8][1] = 5
            call DzFrameSetTexture(FMap_ButtonBackDrop[8][1],MapIcon[0], 0)
            call DzFrameSetModel(FMap_ButtonSP[8][1], "MapLine0.mdx", 0, 0)
        else
            set MapLineSelet[8][1] = 6
            call DzFrameSetTexture(FMap_ButtonBackDrop[8][1],MapIcon[8], 0)
            call DzFrameSetModel(FMap_ButtonSP[8][1], "MapLine5.mdx", 0, 0)
        endif
        if GetRandomInt(0,1) == 0 then
            set MapLineSelet[8][2] = 5
            call DzFrameSetTexture(FMap_ButtonBackDrop[8][2],MapIcon[0], 0)
            call DzFrameSetModel(FMap_ButtonSP[8][2], "MapLine0.mdx", 0, 0)
        else
            set MapLineSelet[8][2] = 6
            call DzFrameSetTexture(FMap_ButtonBackDrop[8][2],MapIcon[8], 0)
            call DzFrameSetModel(FMap_ButtonSP[8][2], "MapLine5.mdx", 0, 0)
        endif
        if GetRandomInt(0,1) == 0 then
            set MapLineSelet[8][3] = 5
            call DzFrameSetTexture(FMap_ButtonBackDrop[8][3],MapIcon[0], 0)
            call DzFrameSetModel(FMap_ButtonSP[8][3], "MapLine0.mdx", 0, 0)
        else
            set MapLineSelet[8][3] = 6
            call DzFrameSetTexture(FMap_ButtonBackDrop[8][3],MapIcon[8], 0)
            call DzFrameSetModel(FMap_ButtonSP[8][3], "MapLine5.mdx", 0, 0)
        endif

        set i = GetRandomInt(0,10)
        if i <= 8 then
            set MapLineSelet[9][0] = 7
            call DzFrameSetTexture(FMap_ButtonBackDrop[9][0],MapIcon[10], 0)
            call DzFrameSetModel(FMap_ButtonSP[9][0], "MapLine4.mdx", 0, 0)
        elseif i == 9 then
            set MapLineSelet[9][0] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[9][0],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[9][0], "MapLine1.mdx", 0, 0)
        elseif i == 10 then
            set MapLineSelet[9][0] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[9][0],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[9][0], "MapLine2.mdx", 0, 0)
        endif
        set i = GetRandomInt(0,10)
        if i <= 8 then
            set MapLineSelet[9][1] = 7
            call DzFrameSetTexture(FMap_ButtonBackDrop[9][1],MapIcon[10], 0)
            call DzFrameSetModel(FMap_ButtonSP[9][1], "MapLine4.mdx", 0, 0)
        elseif i == 9 then
            set MapLineSelet[9][1] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[9][1],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[9][1], "MapLine1.mdx", 0, 0)
        elseif i == 10 then
            set MapLineSelet[9][1] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[9][1],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[9][1], "MapLine2.mdx", 0, 0)
        endif
        set i = GetRandomInt(0,10)
        if i <= 8 then
            set MapLineSelet[9][2] = 7
            call DzFrameSetTexture(FMap_ButtonBackDrop[9][2],MapIcon[10], 0)
            call DzFrameSetModel(FMap_ButtonSP[9][2], "MapLine4.mdx", 0, 0)
        elseif i == 9 then
            set MapLineSelet[9][2] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[9][2],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[9][2], "MapLine1.mdx", 0, 0)
        elseif i == 10 then
            set MapLineSelet[9][2] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[9][2],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[9][2], "MapLine2.mdx", 0, 0)
        endif
        set i = GetRandomInt(0,10)
        if i <= 8 then
            set MapLineSelet[9][3] = 7
            call DzFrameSetTexture(FMap_ButtonBackDrop[9][3],MapIcon[10], 0)
            call DzFrameSetModel(FMap_ButtonSP[9][3], "MapLine4.mdx", 0, 0)
        elseif i == 9 then
            set MapLineSelet[9][3] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[9][3],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[9][3], "MapLine1.mdx", 0, 0)
        elseif i == 10 then
            set MapLineSelet[9][3] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[9][3],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[9][3], "MapLine2.mdx", 0, 0)
        endif

        set MapLineSelet[10][0] = 8
        call DzFrameSetTexture(FMap_ButtonBackDrop[10][0],MapIcon[12], 0)
        call DzFrameSetModel(FMap_ButtonSP[10][0], "MapLine5.mdx", 0, 0)
        
        if GetRandomInt(0,3) <= 2 then
            set MapLineSelet[11][0] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[11][0],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[11][0], "MapLine1.mdx", 0, 0)
        else
            set MapLineSelet[11][0] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[11][0],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[11][0], "MapLine2.mdx", 0, 0)
        endif
        if GetRandomInt(0,3) <= 2 then
            set MapLineSelet[11][1] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[11][1],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[11][1], "MapLine1.mdx", 0, 0)
        else
            set MapLineSelet[11][1] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[11][1],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[11][1], "MapLine2.mdx", 0, 0)
        endif
        if GetRandomInt(0,3) <= 2 then
            set MapLineSelet[11][2] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[11][2],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[11][2], "MapLine1.mdx", 0, 0)
        else
            set MapLineSelet[11][2] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[11][2],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[11][2], "MapLine2.mdx", 0, 0)
        endif
        if GetRandomInt(0,3) <= 2 then
            set MapLineSelet[11][3] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[11][3],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[11][3], "MapLine1.mdx", 0, 0)
        else
            set MapLineSelet[11][3] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[11][3],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[11][3], "MapLine2.mdx", 0, 0)
        endif
        if GetRandomInt(0,3) <= 2 then
            set MapLineSelet[12][0] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[12][0],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[12][0], "MapLine1.mdx", 0, 0)
        else
            set MapLineSelet[12][0] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[12][0],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[12][0], "MapLine2.mdx", 0, 0)
        endif
        if GetRandomInt(0,3) <= 2 then
            set MapLineSelet[12][1] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[12][1],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[12][1], "MapLine1.mdx", 0, 0)
        else
            set MapLineSelet[12][1] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[12][1],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[12][1], "MapLine2.mdx", 0, 0)
        endif
        if GetRandomInt(0,3) <= 2 then
            set MapLineSelet[12][2] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[12][2],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[12][2], "MapLine1.mdx", 0, 0)
        else
            set MapLineSelet[12][2] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[12][2],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[12][2], "MapLine2.mdx", 0, 0)
        endif
        if GetRandomInt(0,3) <= 2 then
            set MapLineSelet[12][3] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[12][3],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[12][3], "MapLine1.mdx", 0, 0)
        else
            set MapLineSelet[12][3] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[12][3],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[12][3], "MapLine2.mdx", 0, 0)
        endif

        if GetRandomInt(0,1) == 0 then
            set MapLineSelet[13][0] = 5
            call DzFrameSetTexture(FMap_ButtonBackDrop[13][0],MapIcon[0], 0)
            call DzFrameSetModel(FMap_ButtonSP[13][0], "MapLine0.mdx", 0, 0)
        else
            set MapLineSelet[13][0] = 6
            call DzFrameSetTexture(FMap_ButtonBackDrop[13][0],MapIcon[8], 0)
            call DzFrameSetModel(FMap_ButtonSP[13][0], "MapLine5.mdx", 0, 0)
        endif
        if GetRandomInt(0,1) == 0 then
            set MapLineSelet[13][1] = 5
            call DzFrameSetTexture(FMap_ButtonBackDrop[13][1],MapIcon[0], 0)
            call DzFrameSetModel(FMap_ButtonSP[13][1], "MapLine0.mdx", 0, 0)
        else
            set MapLineSelet[13][1] = 6
            call DzFrameSetTexture(FMap_ButtonBackDrop[13][1],MapIcon[8], 0)
            call DzFrameSetModel(FMap_ButtonSP[13][1], "MapLine5.mdx", 0, 0)
        endif
        if GetRandomInt(0,1) == 0 then
            set MapLineSelet[13][2] = 5
            call DzFrameSetTexture(FMap_ButtonBackDrop[13][2],MapIcon[0], 0)
            call DzFrameSetModel(FMap_ButtonSP[13][2], "MapLine0.mdx", 0, 0)
        else
            set MapLineSelet[13][2] = 6
            call DzFrameSetTexture(FMap_ButtonBackDrop[13][2],MapIcon[8], 0)
            call DzFrameSetModel(FMap_ButtonSP[13][2], "MapLine5.mdx", 0, 0)
        endif
        if GetRandomInt(0,1) == 0 then
            set MapLineSelet[13][3] = 5
            call DzFrameSetTexture(FMap_ButtonBackDrop[13][3],MapIcon[0], 0)
            call DzFrameSetModel(FMap_ButtonSP[13][3], "MapLine0.mdx", 0, 0)
        else
            set MapLineSelet[13][3] = 6
            call DzFrameSetTexture(FMap_ButtonBackDrop[13][3],MapIcon[8], 0)
            call DzFrameSetModel(FMap_ButtonSP[13][3], "MapLine5.mdx", 0, 0)
        endif

        set i = GetRandomInt(0,10)
        if i <= 8 then
            set MapLineSelet[14][0] = 7
            call DzFrameSetTexture(FMap_ButtonBackDrop[14][0],MapIcon[10], 0)
            call DzFrameSetModel(FMap_ButtonSP[13][3], "MapLine4.mdx", 0, 0)
        elseif i == 9 then
            set MapLineSelet[14][0] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[14][0],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[14][0], "MapLine1.mdx", 0, 0)
        elseif i == 10 then
            set MapLineSelet[14][0] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[14][0],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[14][0], "MapLine2.mdx", 0, 0)
        endif
        set i = GetRandomInt(0,10)
        if i <= 8 then
            set MapLineSelet[14][1] = 7
            call DzFrameSetTexture(FMap_ButtonBackDrop[14][1],MapIcon[10], 0)
            call DzFrameSetModel(FMap_ButtonSP[14][1], "MapLine4.mdx", 0, 0)
        elseif i == 9 then
            set MapLineSelet[14][1] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[14][1],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[14][1], "MapLine1.mdx", 0, 0)
        elseif i == 10 then
            set MapLineSelet[14][1] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[14][1],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[14][1], "MapLine2.mdx", 0, 0)
        endif
        set i = GetRandomInt(0,10)
        if i <= 8 then
            set MapLineSelet[14][2] = 7
            call DzFrameSetTexture(FMap_ButtonBackDrop[14][2],MapIcon[10], 0)
            call DzFrameSetModel(FMap_ButtonSP[14][2], "MapLine4.mdx", 0, 0)
        elseif i == 9 then
            set MapLineSelet[14][2] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[14][2],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[14][2], "MapLine1.mdx", 0, 0)
        elseif i == 10 then
            set MapLineSelet[14][2] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[14][2],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[14][2], "MapLine2.mdx", 0, 0)
        endif
        set i = GetRandomInt(0,10)
        if i <= 8 then
            set MapLineSelet[14][3] = 7
            call DzFrameSetTexture(FMap_ButtonBackDrop[14][3],MapIcon[10], 0)
            call DzFrameSetModel(FMap_ButtonSP[14][3], "MapLine4.mdx", 0, 0)
        elseif i == 9 then
            set MapLineSelet[14][3] = 2
            call DzFrameSetTexture(FMap_ButtonBackDrop[14][3],MapIcon[2], 0)
            call DzFrameSetModel(FMap_ButtonSP[14][3], "MapLine1.mdx", 0, 0)
        elseif i == 10 then
            set MapLineSelet[14][3] = 3
            call DzFrameSetTexture(FMap_ButtonBackDrop[14][3],MapIcon[4], 0)
            call DzFrameSetModel(FMap_ButtonSP[14][3], "MapLine2.mdx", 0, 0)
        endif

        set MapLineSelet[15][0] = 5
        call DzFrameSetTexture(FMap_ButtonBackDrop[15][0],MapIcon[0], 0)
        call DzFrameSetModel(FMap_ButtonSP[15][0], "MapLine0.mdx", 0, 0)

        set MapLineSelet[16][0] = 9
        call DzFrameSetTexture(FMap_ButtonBackDrop[16][0],MapIcon[14], 0)
        call DzFrameSetModel(FMap_ButtonSP[16][0], "MapLine6.mdx", 0, 0)

    endfunction

    private function ShowMenu takes nothing returns nothing
        //메뉴 버튼을 누르면 메뉴 버튼 비활설화 + 메뉴 배경 표시
        //다시 메뉴 버튼을 누르면 메뉴버튼 활성화 + 메뉴 배경 숨김
        if FMap_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] == true then
            call DzFrameShow(FMap_BackDrop, false)
            set FMap_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = false
        else
            call DzFrameShow(FMap_BackDrop, true)
            set FMap_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = true
        endif
    endfunction

    private function PickLineF takes nothing returns nothing
        local player p=(DzGetTriggerSyncPlayer())
        local integer LineNumber = S2I(DzGetTriggerSyncData())
        
        //call BJDebugMsg(I2S(LineNumber)+"번 입장")

        set p = null
    endfunction

    private function ClickPickLineButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local integer i = 0
        
        call DzFrameShow(FMap_BackDrop, false)
        set FMap_OnOff[pid] = false
        set Myroom = ClickRoom
        //call SelectUnitForPlayerSingle( MainUnit[GetPlayerId(DzGetTriggerUIEventPlayer())], DzGetTriggerUIEventPlayer() )
        call DzSyncData("PickLine", I2S(ClickRoom))

        if ClickRoom == 1 then
            call DzFrameShow(FMap_ButtonSP[1][0], false)
            call DzFrameShow(FMap_ButtonSP[1][1], false)
            call DzFrameShow(FMap_ButtonSP[1][2], false)
            call DzFrameShow(FMap_ButtonSP[1][3], false)
            call DzFrameShow(FMap_ButtonSP[2][0], true)
        elseif ClickRoom == 2 then
            call DzFrameShow(FMap_ButtonSP[1][0], false)
            call DzFrameShow(FMap_ButtonSP[1][1], false)
            call DzFrameShow(FMap_ButtonSP[1][2], false)
            call DzFrameShow(FMap_ButtonSP[1][3], false)
            call DzFrameShow(FMap_ButtonSP[2][1], true)
        elseif ClickRoom == 3 then
            call DzFrameShow(FMap_ButtonSP[1][0], false)
            call DzFrameShow(FMap_ButtonSP[1][1], false)
            call DzFrameShow(FMap_ButtonSP[1][2], false)
            call DzFrameShow(FMap_ButtonSP[1][3], false)
            call DzFrameShow(FMap_ButtonSP[2][2], true)
        elseif ClickRoom == 4 then
            call DzFrameShow(FMap_ButtonSP[1][0], false)
            call DzFrameShow(FMap_ButtonSP[1][1], false)
            call DzFrameShow(FMap_ButtonSP[1][2], false)
            call DzFrameShow(FMap_ButtonSP[1][3], false)
            call DzFrameShow(FMap_ButtonSP[2][3], true)
        elseif ClickRoom == 5 then
            call DzFrameShow(FMap_ButtonSP[2][0], false)
            call DzFrameShow(FMap_ButtonSP[3][0], true)
        elseif ClickRoom == 6 then
            call DzFrameShow(FMap_ButtonSP[2][1], false)
            call DzFrameShow(FMap_ButtonSP[3][1], true)
        elseif ClickRoom == 7 then
            call DzFrameShow(FMap_ButtonSP[2][2], false)
            call DzFrameShow(FMap_ButtonSP[3][2], true)
        elseif ClickRoom == 8 then
            call DzFrameShow(FMap_ButtonSP[2][3], false)
            call DzFrameShow(FMap_ButtonSP[3][3], true)
        endif

        if ClickRoom == 9 then
            call DzFrameShow(FMap_ButtonSP[3][0], false)
            call DzFrameShow(FMap_ButtonSP[4][0], true)
        elseif ClickRoom == 10 then
            call DzFrameShow(FMap_ButtonSP[3][1], false)
            call DzFrameShow(FMap_ButtonSP[4][1], true)
        elseif ClickRoom == 11 then
            call DzFrameShow(FMap_ButtonSP[3][2], false)
            call DzFrameShow(FMap_ButtonSP[4][2], true)
        elseif ClickRoom == 12 then
            call DzFrameShow(FMap_ButtonSP[3][3], false)
            call DzFrameShow(FMap_ButtonSP[4][3], true)
        elseif ClickRoom == 13 then
            call DzFrameShow(FMap_ButtonSP[4][0], false)
            call DzFrameShow(FMap_ButtonSP[5][0], true)
        elseif ClickRoom == 14 then
            call DzFrameShow(FMap_ButtonSP[4][1], false)
            call DzFrameShow(FMap_ButtonSP[5][0], true)
        elseif ClickRoom == 15 then
            call DzFrameShow(FMap_ButtonSP[4][2], false)
            call DzFrameShow(FMap_ButtonSP[5][0], true)
        elseif ClickRoom == 16 then
            call DzFrameShow(FMap_ButtonSP[4][3], false)
            call DzFrameShow(FMap_ButtonSP[5][0], true)
        endif


        if ClickRoom == 17 then
            call DzFrameShow(FMap_ButtonSP[5][0], false)
            call DzFrameShow(FMap_ButtonSP[6][0], true)
            call DzFrameShow(FMap_ButtonSP[6][1], true)
            call DzFrameShow(FMap_ButtonSP[6][2], true)
            call DzFrameShow(FMap_ButtonSP[6][3], true)
        elseif ClickRoom == 18 then
            call DzFrameShow(FMap_ButtonSP[6][0], false)
            call DzFrameShow(FMap_ButtonSP[6][1], false)
            call DzFrameShow(FMap_ButtonSP[6][2], false)
            call DzFrameShow(FMap_ButtonSP[6][3], false)
            call DzFrameShow(FMap_ButtonSP[7][0], true)
        elseif ClickRoom == 19 then
            call DzFrameShow(FMap_ButtonSP[6][0], false)
            call DzFrameShow(FMap_ButtonSP[6][1], false)
            call DzFrameShow(FMap_ButtonSP[6][2], false)
            call DzFrameShow(FMap_ButtonSP[6][3], false)
            call DzFrameShow(FMap_ButtonSP[7][1], true)
        elseif ClickRoom == 20 then
            call DzFrameShow(FMap_ButtonSP[6][0], false)
            call DzFrameShow(FMap_ButtonSP[6][1], false)
            call DzFrameShow(FMap_ButtonSP[6][2], false)
            call DzFrameShow(FMap_ButtonSP[6][3], false)
            call DzFrameShow(FMap_ButtonSP[7][2], true)
        elseif ClickRoom == 21 then
            call DzFrameShow(FMap_ButtonSP[6][0], false)
            call DzFrameShow(FMap_ButtonSP[6][1], false)
            call DzFrameShow(FMap_ButtonSP[6][2], false)
            call DzFrameShow(FMap_ButtonSP[6][3], false)
            call DzFrameShow(FMap_ButtonSP[7][3], true)
        elseif ClickRoom == 22 then
            call DzFrameShow(FMap_ButtonSP[7][0], false)
            call DzFrameShow(FMap_ButtonSP[8][0], true)
        elseif ClickRoom == 23 then
            call DzFrameShow(FMap_ButtonSP[7][1], false)
            call DzFrameShow(FMap_ButtonSP[8][1], true)
        elseif ClickRoom == 24 then
            call DzFrameShow(FMap_ButtonSP[7][2], false)
            call DzFrameShow(FMap_ButtonSP[8][2], true)
        elseif ClickRoom == 25 then
            call DzFrameShow(FMap_ButtonSP[7][3], false)
            call DzFrameShow(FMap_ButtonSP[8][3], true)
        endif

        if ClickRoom == 26 then
            call DzFrameShow(FMap_ButtonSP[8][0], false)
            call DzFrameShow(FMap_ButtonSP[9][0], true)
        elseif ClickRoom == 27 then
            call DzFrameShow(FMap_ButtonSP[8][1], false)
            call DzFrameShow(FMap_ButtonSP[9][1], true)
        elseif ClickRoom == 28 then
            call DzFrameShow(FMap_ButtonSP[8][2], false)
            call DzFrameShow(FMap_ButtonSP[9][2], true)
        elseif ClickRoom == 29 then
            call DzFrameShow(FMap_ButtonSP[8][3], false)
            call DzFrameShow(FMap_ButtonSP[9][3], true)
        elseif ClickRoom == 30 then
            call DzFrameShow(FMap_ButtonSP[9][0], false)
            call DzFrameShow(FMap_ButtonSP[10][0], true)
        elseif ClickRoom == 31 then
            call DzFrameShow(FMap_ButtonSP[9][1], false)
            call DzFrameShow(FMap_ButtonSP[10][0], true)
        elseif ClickRoom == 32 then
            call DzFrameShow(FMap_ButtonSP[9][2], false)
            call DzFrameShow(FMap_ButtonSP[10][0], true)
        elseif ClickRoom == 33 then
            call DzFrameShow(FMap_ButtonSP[9][3], false)
            call DzFrameShow(FMap_ButtonSP[10][0], true)
        endif

        if ClickRoom == 34 then
            call DzFrameShow(FMap_ButtonSP[10][0], false)
            call DzFrameShow(FMap_ButtonSP[11][0], true)
            call DzFrameShow(FMap_ButtonSP[11][1], true)
            call DzFrameShow(FMap_ButtonSP[11][2], true)
            call DzFrameShow(FMap_ButtonSP[11][3], true)
        elseif ClickRoom == 35 then
            call DzFrameShow(FMap_ButtonSP[11][0], false)
            call DzFrameShow(FMap_ButtonSP[11][1], false)
            call DzFrameShow(FMap_ButtonSP[11][2], false)
            call DzFrameShow(FMap_ButtonSP[11][3], false)
            call DzFrameShow(FMap_ButtonSP[12][0], true)
        elseif ClickRoom == 36 then
            call DzFrameShow(FMap_ButtonSP[11][0], false)
            call DzFrameShow(FMap_ButtonSP[11][1], false)
            call DzFrameShow(FMap_ButtonSP[11][2], false)
            call DzFrameShow(FMap_ButtonSP[11][3], false)
            call DzFrameShow(FMap_ButtonSP[12][1], true)
        elseif ClickRoom == 37 then
            call DzFrameShow(FMap_ButtonSP[11][0], false)
            call DzFrameShow(FMap_ButtonSP[11][1], false)
            call DzFrameShow(FMap_ButtonSP[11][2], false)
            call DzFrameShow(FMap_ButtonSP[11][3], false)
            call DzFrameShow(FMap_ButtonSP[12][2], true)
        elseif ClickRoom == 38 then
            call DzFrameShow(FMap_ButtonSP[11][0], false)
            call DzFrameShow(FMap_ButtonSP[11][1], false)
            call DzFrameShow(FMap_ButtonSP[11][2], false)
            call DzFrameShow(FMap_ButtonSP[11][3], false)
            call DzFrameShow(FMap_ButtonSP[12][3], true)
        elseif ClickRoom == 39 then
            call DzFrameShow(FMap_ButtonSP[12][0], false)
            call DzFrameShow(FMap_ButtonSP[13][0], true)
        elseif ClickRoom == 40 then
            call DzFrameShow(FMap_ButtonSP[12][1], false)
            call DzFrameShow(FMap_ButtonSP[13][1], true)
        elseif ClickRoom == 41 then
            call DzFrameShow(FMap_ButtonSP[12][2], false)
            call DzFrameShow(FMap_ButtonSP[13][2], true)
        elseif ClickRoom == 42 then
            call DzFrameShow(FMap_ButtonSP[12][3], false)
            call DzFrameShow(FMap_ButtonSP[13][3], true)
        endif

        if ClickRoom == 43 then
            call DzFrameShow(FMap_ButtonSP[13][0], false)
            call DzFrameShow(FMap_ButtonSP[14][0], true)
        elseif ClickRoom == 44 then
            call DzFrameShow(FMap_ButtonSP[13][1], false)
            call DzFrameShow(FMap_ButtonSP[14][1], true)
        elseif ClickRoom == 45 then
            call DzFrameShow(FMap_ButtonSP[13][2], false)
            call DzFrameShow(FMap_ButtonSP[14][2], true)
        elseif ClickRoom == 46 then
            call DzFrameShow(FMap_ButtonSP[13][3], false)
            call DzFrameShow(FMap_ButtonSP[14][3], true)
        elseif ClickRoom == 47 then
            call DzFrameShow(FMap_ButtonSP[14][0], false)
            call DzFrameShow(FMap_ButtonSP[15][0], true)
        elseif ClickRoom == 48 then
            call DzFrameShow(FMap_ButtonSP[14][1], false)
            call DzFrameShow(FMap_ButtonSP[15][0], true)
        elseif ClickRoom == 49 then
            call DzFrameShow(FMap_ButtonSP[14][2], false)
            call DzFrameShow(FMap_ButtonSP[15][0], true)
        elseif ClickRoom == 50 then
            call DzFrameShow(FMap_ButtonSP[14][3], false)
            call DzFrameShow(FMap_ButtonSP[15][0], true)
        endif

        if ClickRoom == 51 then
            call DzFrameShow(FMap_ButtonSP[15][0], false)
            call DzFrameShow(FMap_ButtonSP[16][0], true)
        elseif ClickRoom == 52 then
            call DzFrameShow(FMap_ButtonSP[16][0], false)
        endif

    endfunction

    private function SelectLine takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer i = 0
        
        if f == FMap_Button[1][0] and Myroom == 0 then
            call BJDebugMsg("1-1")
            set ClickRoom = 1
        elseif f == FMap_Button[1][1] and Myroom == 0 then
            call BJDebugMsg("1-2")
            set ClickRoom = 2
        elseif f == FMap_Button[1][2] and Myroom == 0  then
            call BJDebugMsg("1-3")
            set ClickRoom = 3
        elseif f == FMap_Button[1][3] and Myroom == 0 then
            call BJDebugMsg("1-4")
            set ClickRoom = 4
        endif
        
        if f == FMap_Button[2][0] and Myroom == 1 then
            call BJDebugMsg("2-1")
            set ClickRoom = 5
        elseif f == FMap_Button[2][1] and Myroom == 2 then
            call BJDebugMsg("2-2")
            set ClickRoom = 6
        elseif f == FMap_Button[2][2] and Myroom == 3 then
            call BJDebugMsg("2-3")
            set ClickRoom = 7
        elseif f == FMap_Button[2][3] and Myroom == 4 then
            call BJDebugMsg("2-4")
            set ClickRoom = 8
        endif

        if f == FMap_Button[3][0] and Myroom == 5 then
            call BJDebugMsg("3-1")
            set ClickRoom = 9
        elseif f == FMap_Button[3][1] and Myroom == 6 then
            call BJDebugMsg("3-2")
            set ClickRoom = 10
        elseif f == FMap_Button[3][2] and Myroom == 7 then
            call BJDebugMsg("3-3")
            set ClickRoom = 11
        elseif f == FMap_Button[3][3] and Myroom == 8 then
            call BJDebugMsg("3-4")
            set ClickRoom = 12
        endif

        if f == FMap_Button[4][0] and Myroom == 9 then
            call BJDebugMsg("4-1")
            set ClickRoom = 13
        elseif f == FMap_Button[4][1] and Myroom == 10 then
            call BJDebugMsg("4-2")
            set ClickRoom = 14
        elseif f == FMap_Button[4][2] and Myroom == 11 then
            call BJDebugMsg("4-3")
            set ClickRoom = 15
        elseif f == FMap_Button[4][3] and Myroom == 12 then
            call BJDebugMsg("4-4")
            set ClickRoom = 16
        endif
        
        if f == FMap_Button[5][0] and ( Myroom == 13 or Myroom == 14 or Myroom == 15 or Myroom == 16 ) then
            call BJDebugMsg("5")
            set ClickRoom = 17
        endif

        if f == FMap_Button[6][0] and Myroom == 17 then
            call BJDebugMsg("6-1")
            set ClickRoom = 18
        elseif f == FMap_Button[6][1] and Myroom == 17 then
            call BJDebugMsg("6-2")
            set ClickRoom = 19
        elseif f == FMap_Button[6][2] and Myroom == 17 then
            call BJDebugMsg("6-3")
            set ClickRoom = 20
        elseif f == FMap_Button[6][3] and Myroom == 17 then
            call BJDebugMsg("6-4")
            set ClickRoom = 21
        endif

        if f == FMap_Button[7][0] and Myroom == 18 then
            call BJDebugMsg("7-1")
            set ClickRoom = 22
        elseif f == FMap_Button[7][1] and Myroom == 19 then
            call BJDebugMsg("7-2")
            set ClickRoom = 23
        elseif f == FMap_Button[7][2] and Myroom == 20 then
            call BJDebugMsg("7-3")
            set ClickRoom = 24
        elseif f == FMap_Button[7][3] and Myroom == 21 then
            call BJDebugMsg("7-4")
            set ClickRoom = 25
        endif

        if f == FMap_Button[8][0] and Myroom == 22 then
            call BJDebugMsg("8-1")
            set ClickRoom = 26
        elseif f == FMap_Button[8][1] and Myroom == 23 then
            call BJDebugMsg("8-2")
            set ClickRoom = 27
        elseif f == FMap_Button[8][2] and Myroom == 24 then
            call BJDebugMsg("8-3")
            set ClickRoom = 28
        elseif f == FMap_Button[8][3] and Myroom == 25 then
            call BJDebugMsg("8-4")
            set ClickRoom = 29
        endif

        if f == FMap_Button[9][0] and Myroom == 26 then
            call BJDebugMsg("9-1")
            set ClickRoom = 30
        elseif f == FMap_Button[9][1] and Myroom == 27 then
            call BJDebugMsg("9-2")
            set ClickRoom = 31
        elseif f == FMap_Button[9][2] and Myroom == 28 then
            call BJDebugMsg("9-3")
            set ClickRoom = 32
        elseif f == FMap_Button[9][3] and Myroom == 29 then
            call BJDebugMsg("9-4")
            set ClickRoom = 33
        endif

        if f == FMap_Button[10][0] and ( Myroom == 30 or Myroom == 31 or Myroom == 32 or Myroom == 33 ) then
            call BJDebugMsg("10")
            set ClickRoom = 34
        endif

        if f == FMap_Button[11][0] and Myroom == 34 then
            call BJDebugMsg("11-1")
            set ClickRoom = 35
        elseif f == FMap_Button[11][1] and Myroom == 34 then
            call BJDebugMsg("11-2")
            set ClickRoom = 36
        elseif f == FMap_Button[11][2] and Myroom == 34 then
            call BJDebugMsg("11-3")
            set ClickRoom = 37
        elseif f == FMap_Button[11][3] and Myroom == 34 then
            call BJDebugMsg("11-4")
            set ClickRoom = 38
        endif

        if f == FMap_Button[12][0] and Myroom == 35 then
            call BJDebugMsg("12-1")
            set ClickRoom = 39
        elseif f == FMap_Button[12][1] and Myroom == 36 then
            call BJDebugMsg("12-2")
            set ClickRoom = 40
        elseif f == FMap_Button[12][2] and Myroom == 37 then
            call BJDebugMsg("12-3")
            set ClickRoom = 41
        elseif f == FMap_Button[12][3] and Myroom == 38 then
            call BJDebugMsg("12-4")
            set ClickRoom = 42
        endif

        if f == FMap_Button[13][0] and Myroom == 39 then
            call BJDebugMsg("13-1")
            set ClickRoom = 43
        elseif f == FMap_Button[13][1] and Myroom == 40 then
            call BJDebugMsg("13-2")
            set ClickRoom = 44
        elseif f == FMap_Button[13][2] and Myroom == 41 then
            call BJDebugMsg("13-3")
            set ClickRoom = 45
        elseif f == FMap_Button[13][3] and Myroom == 42 then
            call BJDebugMsg("13-4")
            set ClickRoom = 46
        endif

        if f == FMap_Button[14][0] and Myroom == 43 then
            call BJDebugMsg("14-1")
            set ClickRoom = 47
        elseif f == FMap_Button[14][1] and Myroom == 44 then
            call BJDebugMsg("14-2")
            set ClickRoom = 48
        elseif f == FMap_Button[14][2] and Myroom == 45 then
            call BJDebugMsg("14-3")
            set ClickRoom = 49
        elseif f == FMap_Button[14][3] and Myroom == 46 then
            call BJDebugMsg("14-4")
            set ClickRoom = 50
        endif

        if f == FMap_Button[15][0] and ( Myroom == 47 or Myroom == 48 or Myroom == 49 or Myroom == 50 ) then
            call BJDebugMsg("15")
            set ClickRoom = 51
        endif

        if f == FMap_Button[16][0] and Myroom == 51 then
            call BJDebugMsg("16")
            set ClickRoom = 52
        endif
        
    endfunction
    
    //

    private function ClickRLButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local integer i = 0
        
        call DzFrameShow(FMap_L, true)
        call DzFrameShow(FMap_R, true)
        
        if f == FMap_RB then
            if NowList == MaxList then
                set NowList = MaxList
            else
                set NowList = NowList + 1
            endif
            
            if NowList == 0 then
                call DzFrameShow(FMap_L, false)
                call DzFrameShow(FMap_R, true)
                call DzFrameShow(FMap_L2, true)
                call DzFrameShow(FMap_R2, false)
            elseif MaxList == NowList then
                call DzFrameShow(FMap_L, true)
                call DzFrameShow(FMap_R, false)
                call DzFrameShow(FMap_L2, false)
                call DzFrameShow(FMap_R2, true)
            else
                call DzFrameShow(FMap_L, true)
                call DzFrameShow(FMap_R, true)
                call DzFrameShow(FMap_L2, false)
                call DzFrameShow(FMap_R2, false)
            endif
        elseif f == FMap_LB then
            if NowList == 0 then
                set NowList = 0
            else
                set NowList = NowList - 1
            endif
            
            if NowList == 0 then
                call DzFrameShow(FMap_L, false)
                call DzFrameShow(FMap_R, true)
                call DzFrameShow(FMap_L2, true)
                call DzFrameShow(FMap_R2, false)
            elseif MaxList == NowList then
                call DzFrameShow(FMap_L, true)
                call DzFrameShow(FMap_R, false)
                call DzFrameShow(FMap_L2, false)
                call DzFrameShow(FMap_R2, true)
            else
                call DzFrameShow(FMap_L, true)
                call DzFrameShow(FMap_R, true)
                call DzFrameShow(FMap_L2, false)
                call DzFrameShow(FMap_R2, false)
            endif
        endif
        
        if NowList == 0 then
            call DzFrameSetPoint(FMap_Button[0][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*5), -0.080 - 0.120)

            call DzFrameSetPoint(FMap_Button[1][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FMap_Button[1][1], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FMap_Button[1][2], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FMap_Button[1][3], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FMap_Button[2][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FMap_Button[2][1], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FMap_Button[2][2], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FMap_Button[2][3], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FMap_Button[3][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FMap_Button[3][1], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FMap_Button[3][2], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FMap_Button[3][3], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FMap_Button[4][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*1), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FMap_Button[4][1], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*1), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FMap_Button[4][2], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*1), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FMap_Button[4][3], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*1), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FMap_Button[5][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350, -0.080 - 0.120)

            call DzFrameSetPoint(FMap_Button[6][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FMap_Button[6][1], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FMap_Button[6][2], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FMap_Button[6][3], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FMap_Button[7][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FMap_Button[7][1], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FMap_Button[7][2], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FMap_Button[7][3], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FMap_Button[8][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FMap_Button[8][1], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FMap_Button[8][2], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FMap_Button[8][3], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FMap_Button[9][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*4), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FMap_Button[9][1], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*4), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FMap_Button[9][2], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*4), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FMap_Button[9][3], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*4), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FMap_Button[10][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*5), -0.080 - 0.120)

            call DzFrameShow(FMap_Button[0][0], true)
            call DzFrameShow(FMap_Button[1][0], true)

            call DzFrameShow(FMap_Button[5][0], true)
            call DzFrameShow(FMap_Button[6][0], true)

            call DzFrameShow(FMap_Button[10][0], true)
            call DzFrameShow(FMap_Button[11][0], false)

            call DzFrameShow(FMap_Button[15][0], false)
            call DzFrameShow(FMap_Button[16][0], false)
        elseif NowList == 1 then
            call DzFrameSetPoint(FMap_Button[5][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*5), -0.080 - 0.120)

            call DzFrameSetPoint(FMap_Button[6][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FMap_Button[6][1], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FMap_Button[6][2], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FMap_Button[6][3], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FMap_Button[7][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FMap_Button[7][1], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FMap_Button[7][2], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FMap_Button[7][3], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FMap_Button[8][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FMap_Button[8][1], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FMap_Button[8][2], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FMap_Button[8][3], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FMap_Button[9][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*1), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FMap_Button[9][1], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*1), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FMap_Button[9][2], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*1), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FMap_Button[9][3], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*1), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FMap_Button[10][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350, -0.080 - 0.120)

            call DzFrameSetPoint(FMap_Button[11][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FMap_Button[11][1], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FMap_Button[11][2], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FMap_Button[11][3], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FMap_Button[12][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FMap_Button[12][1], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FMap_Button[12][2], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FMap_Button[12][3], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FMap_Button[13][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FMap_Button[13][1], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FMap_Button[13][2], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FMap_Button[13][3], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FMap_Button[14][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*4), -0.080 + (-0.080*0))
            call DzFrameSetPoint(FMap_Button[14][1], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*4), -0.080 + (-0.080*1))
            call DzFrameSetPoint(FMap_Button[14][2], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*4), -0.080 + (-0.080*2))
            call DzFrameSetPoint(FMap_Button[14][3], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*4), -0.080 + (-0.080*3))

            call DzFrameSetPoint(FMap_Button[15][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*5), -0.080 - 0.120)
            
            call DzFrameShow(FMap_Button[0][0], false)
            call DzFrameShow(FMap_Button[1][0], false)

            call DzFrameShow(FMap_Button[5][0], true)
            call DzFrameShow(FMap_Button[6][0], true)

            call DzFrameShow(FMap_Button[10][0], true)
            call DzFrameShow(FMap_Button[11][0], true)

            call DzFrameShow(FMap_Button[15][0], true)
            call DzFrameShow(FMap_Button[16][0], false)

            set i = 1
            loop
                call DzFrameShow(FMap_LineBackDrop[i], true)
                set i = i + 1
            exitwhen i == 97
            endloop
            call DzFrameShow(FMap_LineBackDrop[97], false)
            call DzFrameShow(FMap_LineBackDrop[98], false)
            call DzFrameShow(FMap_LineBackDrop[99], false)
            call DzFrameShow(FMap_LineBackDrop[100], false)
            call DzFrameShow(FMap_LineBackDrop[101], false)
        elseif NowList == 2 then
            call DzFrameSetPoint(FMap_Button[15][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2.5), -0.080 - 0.120)

            call DzFrameSetPoint(FMap_Button[16][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2.5), -0.080 - 0.120)

            call DzFrameShow(FMap_Button[0][0], false)
            call DzFrameShow(FMap_Button[1][0], false)

            call DzFrameShow(FMap_Button[5][0], false)
            call DzFrameShow(FMap_Button[6][0], false)

            call DzFrameShow(FMap_Button[10][0], false)
            call DzFrameShow(FMap_Button[11][0], false)

            call DzFrameShow(FMap_Button[15][0], true)
            call DzFrameShow(FMap_Button[16][0], true)

            set i = 1
            loop
                call DzFrameShow(FMap_LineBackDrop[i], false)
                set i = i + 1
            exitwhen i == 97
            endloop
            call DzFrameShow(FMap_LineBackDrop[97], true)
            call DzFrameShow(FMap_LineBackDrop[98], true)
            call DzFrameShow(FMap_LineBackDrop[99], true)
            call DzFrameShow(FMap_LineBackDrop[100], true)
            call DzFrameShow(FMap_LineBackDrop[101], true)
        endif
        
    endfunction
    

    private function CreateLineButton takes integer types, integer x returns nothing
        local integer i

        if types == 0 then
            set FMap_Button[types][0]=DzCreateFrameByTagName("BUTTON", "", FMap_BackDrop, "ScoreScreenTabButtonTemplate",  FrameCount())
            call DzFrameSetPoint(FMap_Button[types][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.060 + (0.060*types), -0.080 - 0.120)
            call DzFrameSetSize(FMap_Button[types][0], 0.030, 0.030)
            call DzFrameSetScriptByCode(FMap_Button[types][0], JN_FRAMEEVENT_MOUSE_UP, function SelectLine, false)
            
            set FMap_ButtonBackDrop[types][0]=DzCreateFrameByTagName("BACKDROP", "", FMap_Button[types][0], "", FrameCount())
            call DzFrameSetAllPoints(FMap_ButtonBackDrop[types][0], FMap_Button[types][0])
            call DzFrameSetTexture(FMap_ButtonBackDrop[types][0],"ReplaceableTextures\\CommandButtons\\BTNGarithos.blp", 0)

            set FMap_ButtonSP[types][0]=DzCreateFrameByTagName("SPRITE", "", FMap_ButtonBackDrop[types][0], "", FrameCount())
            call DzFrameSetModel(FMap_ButtonSP[types][0], "MapLine0.mdx", 0, 0)
            call DzFrameSetPoint(FMap_ButtonSP[types][0], JN_FRAMEPOINT_BOTTOMLEFT, FMap_ButtonBackDrop[types][0] , JN_FRAMEPOINT_CENTER, 0, 0)
            call DzFrameShow(FMap_ButtonSP[types][0], false)
        elseif types == 5 or types == 10 or types == 15 then
            set FMap_Button[types][0]=DzCreateFrameByTagName("BUTTON", "", FMap_BackDrop, "ScoreScreenTabButtonTemplate",  FrameCount())
            call DzFrameSetPoint(FMap_Button[types][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.060 + (0.060*types), -0.080 - 0.120)
            call DzFrameSetSize(FMap_Button[types][0], 0.030, 0.030)
            call DzFrameSetScriptByCode(FMap_Button[types][0], JN_FRAMEEVENT_MOUSE_UP, function SelectLine, false)

            set FMap_ButtonBackDrop[types][0]=DzCreateFrameByTagName("BACKDROP", "", FMap_Button[types][0], "", FrameCount())
            call DzFrameSetAllPoints(FMap_ButtonBackDrop[types][0], FMap_Button[types][0])
            call DzFrameSetTexture(FMap_ButtonBackDrop[types][0],MapIcon[0], 0)

            set FMap_ButtonSP[types][0]=DzCreateFrameByTagName("SPRITE", "", FMap_ButtonBackDrop[types][0], "", FrameCount())
            call DzFrameSetModel(FMap_ButtonSP[types][0], "MapLine0.mdx", 0, 0)
            call DzFrameSetPoint(FMap_ButtonSP[types][0], JN_FRAMEPOINT_BOTTOMLEFT, FMap_ButtonBackDrop[types][0] , JN_FRAMEPOINT_CENTER, 0, 0)
            call DzFrameShow(FMap_ButtonSP[types][0], false)
        elseif types == 16 then
            set FMap_Button[types][0]=DzCreateFrameByTagName("BUTTON", "", FMap_BackDrop, "ScoreScreenTabButtonTemplate",  FrameCount())
            call DzFrameSetPoint(FMap_Button[types][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.050 + (0.060*types), -0.080 - 0.120)
            call DzFrameSetSize(FMap_Button[types][0], 0.050, 0.050)
            call DzFrameSetScriptByCode(FMap_Button[types][0], JN_FRAMEEVENT_MOUSE_UP, function SelectLine, false)
            
            set FMap_ButtonBackDrop[types][0]=DzCreateFrameByTagName("BACKDROP", "", FMap_Button[types][0], "", FrameCount())
            call DzFrameSetAllPoints(FMap_ButtonBackDrop[types][0], FMap_Button[types][0])
            call DzFrameSetTexture(FMap_ButtonBackDrop[types][0],"ReplaceableTextures\\CommandButtons\\BTNGarithos.blp", 0)

            set FMap_ButtonSP[types][0]=DzCreateFrameByTagName("SPRITE", "", FMap_ButtonBackDrop[types][0], "", FrameCount())
            call DzFrameSetModel(FMap_ButtonSP[types][0], "MapLine0.mdx", 0, 0)
            call DzFrameSetPoint(FMap_ButtonSP[types][0], JN_FRAMEPOINT_BOTTOMLEFT, FMap_ButtonBackDrop[types][0] , JN_FRAMEPOINT_CENTER, 0, 0)
            call DzFrameShow(FMap_ButtonSP[types][0], false)
        elseif types == 1 or types == 6 or types == 11 then
            set i = 0
            set FMap_Button[types][i]=DzCreateFrameByTagName("BUTTON", "", FMap_BackDrop, "ScoreScreenTabButtonTemplate",  FrameCount())
            call DzFrameSetPoint(FMap_Button[types][i], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.060 + (0.060*types), -0.080 )
            call DzFrameSetSize(FMap_Button[types][i], 0.030, 0.030)
            call DzFrameSetScriptByCode(FMap_Button[types][i], JN_FRAMEEVENT_MOUSE_UP, function SelectLine, false)

            set FMap_ButtonBackDrop[types][i]=DzCreateFrameByTagName("BACKDROP", "", FMap_Button[types][i], "", FrameCount())
            call DzFrameSetAllPoints(FMap_ButtonBackDrop[types][i], FMap_Button[types][i])
            call DzFrameSetTexture(FMap_ButtonBackDrop[types][i],"ReplaceableTextures\\CommandButtons\\BTNDeathPact.blp", 0)
            
            set FMap_ButtonSP[types][i]=DzCreateFrameByTagName("SPRITE", "", FMap_ButtonBackDrop[types][i], "", FrameCount())
            call DzFrameSetModel(FMap_ButtonSP[types][i], "MapLine0.mdx", 0, 0)
            call DzFrameSetPoint(FMap_ButtonSP[types][i], JN_FRAMEPOINT_BOTTOMLEFT, FMap_ButtonBackDrop[types][i] , JN_FRAMEPOINT_CENTER, 0, 0)
            call DzFrameShow(FMap_ButtonSP[types][i], false)

            set i = 1
            set FMap_Button[types][i]=DzCreateFrameByTagName("BUTTON", "", FMap_Button[types][0], "ScoreScreenTabButtonTemplate",  FrameCount())
            call DzFrameSetPoint(FMap_Button[types][i], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.060 + (0.060*types), -0.080 + (-0.080*i))
            call DzFrameSetSize(FMap_Button[types][i], 0.030, 0.030)
            call DzFrameSetScriptByCode(FMap_Button[types][i], JN_FRAMEEVENT_MOUSE_UP, function SelectLine, false)

            set FMap_ButtonBackDrop[types][i]=DzCreateFrameByTagName("BACKDROP", "", FMap_Button[types][i], "", FrameCount())
            call DzFrameSetAllPoints(FMap_ButtonBackDrop[types][i], FMap_Button[types][i])
            call DzFrameSetTexture(FMap_ButtonBackDrop[types][i],"ReplaceableTextures\\CommandButtons\\BTNDeathPact.blp", 0)
            
            set FMap_ButtonSP[types][i]=DzCreateFrameByTagName("SPRITE", "", FMap_ButtonBackDrop[types][i], "", FrameCount())
            call DzFrameSetModel(FMap_ButtonSP[types][i], "MapLine0.mdx", 0, 0)
            call DzFrameSetPoint(FMap_ButtonSP[types][i], JN_FRAMEPOINT_BOTTOMLEFT, FMap_ButtonBackDrop[types][i] , JN_FRAMEPOINT_CENTER, 0, 0)
            call DzFrameShow(FMap_ButtonSP[types][i], false)
            
            set i = 2
            set FMap_Button[types][i]=DzCreateFrameByTagName("BUTTON", "", FMap_Button[types][0], "ScoreScreenTabButtonTemplate",  FrameCount())
            call DzFrameSetPoint(FMap_Button[types][i], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.060 + (0.060*types), -0.080 + (-0.080*i))
            call DzFrameSetSize(FMap_Button[types][i], 0.030, 0.030)
            call DzFrameSetScriptByCode(FMap_Button[types][i], JN_FRAMEEVENT_MOUSE_UP, function SelectLine, false)

            set FMap_ButtonBackDrop[types][i]=DzCreateFrameByTagName("BACKDROP", "", FMap_Button[types][i], "", FrameCount())
            call DzFrameSetAllPoints(FMap_ButtonBackDrop[types][i], FMap_Button[types][i])
            call DzFrameSetTexture(FMap_ButtonBackDrop[types][i],"ReplaceableTextures\\CommandButtons\\BTNDeathPact.blp", 0)
            
            set FMap_ButtonSP[types][i]=DzCreateFrameByTagName("SPRITE", "", FMap_ButtonBackDrop[types][i], "", FrameCount())
            call DzFrameSetModel(FMap_ButtonSP[types][i], "MapLine0.mdx", 0, 0)
            call DzFrameSetPoint(FMap_ButtonSP[types][i], JN_FRAMEPOINT_BOTTOMLEFT, FMap_ButtonBackDrop[types][i] , JN_FRAMEPOINT_CENTER, 0, 0)
            call DzFrameShow(FMap_ButtonSP[types][i], false)
            
            set i = 3
            set FMap_Button[types][i]=DzCreateFrameByTagName("BUTTON", "", FMap_Button[types][0], "ScoreScreenTabButtonTemplate",  FrameCount())
            call DzFrameSetPoint(FMap_Button[types][i], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.060 + (0.060*types), -0.080 + (-0.080*i))
            call DzFrameSetSize(FMap_Button[types][i], 0.030, 0.030)
            call DzFrameSetScriptByCode(FMap_Button[types][i], JN_FRAMEEVENT_MOUSE_UP, function SelectLine, false)

            set FMap_ButtonBackDrop[types][i]=DzCreateFrameByTagName("BACKDROP", "", FMap_Button[types][i], "", FrameCount())
            call DzFrameSetAllPoints(FMap_ButtonBackDrop[types][i], FMap_Button[types][i])
            call DzFrameSetTexture(FMap_ButtonBackDrop[types][i],"ReplaceableTextures\\CommandButtons\\BTNDeathPact.blp", 0)
            
            set FMap_ButtonSP[types][i]=DzCreateFrameByTagName("SPRITE", "", FMap_ButtonBackDrop[types][i], "", FrameCount())
            call DzFrameSetModel(FMap_ButtonSP[types][i], "MapLine0.mdx", 0, 0)
            call DzFrameSetPoint(FMap_ButtonSP[types][i], JN_FRAMEPOINT_BOTTOMLEFT, FMap_ButtonBackDrop[types][i] , JN_FRAMEPOINT_CENTER, 0, 0)
            call DzFrameShow(FMap_ButtonSP[types][i], false)
        else
            set i = 0
            set FMap_Button[types][i]=DzCreateFrameByTagName("BUTTON", "", FMap_Button[(x*5) + 1][0], "ScoreScreenTabButtonTemplate",  FrameCount())
            call DzFrameSetPoint(FMap_Button[types][i], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.060 + (0.060*types), -0.080 )
            call DzFrameSetSize(FMap_Button[types][i], 0.030, 0.030)
            call DzFrameSetScriptByCode(FMap_Button[types][i], JN_FRAMEEVENT_MOUSE_UP, function SelectLine, false)

            set FMap_ButtonBackDrop[types][i]=DzCreateFrameByTagName("BACKDROP", "", FMap_Button[types][i], "", FrameCount())
            call DzFrameSetAllPoints(FMap_ButtonBackDrop[types][i], FMap_Button[types][i])
            call DzFrameSetTexture(FMap_ButtonBackDrop[types][i],"ReplaceableTextures\\CommandButtons\\BTNDeathPact.blp", 0)
            
            set FMap_ButtonSP[types][i]=DzCreateFrameByTagName("SPRITE", "", FMap_ButtonBackDrop[types][i], "", FrameCount())
            call DzFrameSetModel(FMap_ButtonSP[types][i], "MapLine0.mdx", 0, 0)
            call DzFrameSetPoint(FMap_ButtonSP[types][i], JN_FRAMEPOINT_BOTTOMLEFT, FMap_ButtonBackDrop[types][i] , JN_FRAMEPOINT_CENTER, 0, 0)
            call DzFrameShow(FMap_ButtonSP[types][i], false)
            
            set i = 1
            set FMap_Button[types][i]=DzCreateFrameByTagName("BUTTON", "", FMap_Button[(x*5) + 1][0], "ScoreScreenTabButtonTemplate",  FrameCount())
            call DzFrameSetPoint(FMap_Button[types][i], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.060 + (0.060*types), -0.080 + (-0.080*i))
            call DzFrameSetSize(FMap_Button[types][i], 0.030, 0.030)
            call DzFrameSetScriptByCode(FMap_Button[types][i], JN_FRAMEEVENT_MOUSE_UP, function SelectLine, false)

            set FMap_ButtonBackDrop[types][i]=DzCreateFrameByTagName("BACKDROP", "", FMap_Button[types][i], "", FrameCount())
            call DzFrameSetAllPoints(FMap_ButtonBackDrop[types][i], FMap_Button[types][i])
            call DzFrameSetTexture(FMap_ButtonBackDrop[types][i],"ReplaceableTextures\\CommandButtons\\BTNDeathPact.blp", 0)
            
            set FMap_ButtonSP[types][i]=DzCreateFrameByTagName("SPRITE", "", FMap_ButtonBackDrop[types][i], "", FrameCount())
            call DzFrameSetModel(FMap_ButtonSP[types][i], "MapLine0.mdx", 0, 0)
            call DzFrameSetPoint(FMap_ButtonSP[types][i], JN_FRAMEPOINT_BOTTOMLEFT, FMap_ButtonBackDrop[types][i] , JN_FRAMEPOINT_CENTER, 0, 0)
            call DzFrameShow(FMap_ButtonSP[types][i], false)
            
            set i = 2
            set FMap_Button[types][i]=DzCreateFrameByTagName("BUTTON", "", FMap_Button[(x*5) + 1][0], "ScoreScreenTabButtonTemplate",  FrameCount())
            call DzFrameSetPoint(FMap_Button[types][i], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.060 + (0.060*types), -0.080 + (-0.080*i))
            call DzFrameSetSize(FMap_Button[types][i], 0.030, 0.030)
            call DzFrameSetScriptByCode(FMap_Button[types][i], JN_FRAMEEVENT_MOUSE_UP, function SelectLine, false)

            set FMap_ButtonBackDrop[types][i]=DzCreateFrameByTagName("BACKDROP", "", FMap_Button[types][i], "", FrameCount())
            call DzFrameSetAllPoints(FMap_ButtonBackDrop[types][i], FMap_Button[types][i])
            call DzFrameSetTexture(FMap_ButtonBackDrop[types][i],"ReplaceableTextures\\CommandButtons\\BTNDeathPact.blp", 0)
            
            set FMap_ButtonSP[types][i]=DzCreateFrameByTagName("SPRITE", "", FMap_ButtonBackDrop[types][i], "", FrameCount())
            call DzFrameSetModel(FMap_ButtonSP[types][i], "MapLine0.mdx", 0, 0)
            call DzFrameSetPoint(FMap_ButtonSP[types][i], JN_FRAMEPOINT_BOTTOMLEFT, FMap_ButtonBackDrop[types][i] , JN_FRAMEPOINT_CENTER, 0, 0)
            call DzFrameShow(FMap_ButtonSP[types][i], false)
            
            set i = 3
            set FMap_Button[types][i]=DzCreateFrameByTagName("BUTTON", "", FMap_Button[(x*5) + 1][0], "ScoreScreenTabButtonTemplate",  FrameCount())
            call DzFrameSetPoint(FMap_Button[types][i], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.060 + (0.060*types), -0.080 + (-0.080*i))
            call DzFrameSetSize(FMap_Button[types][i], 0.030, 0.030)
            call DzFrameSetScriptByCode(FMap_Button[types][i], JN_FRAMEEVENT_MOUSE_UP, function SelectLine, false)

            set FMap_ButtonBackDrop[types][i]=DzCreateFrameByTagName("BACKDROP", "", FMap_Button[types][i], "", FrameCount())
            call DzFrameSetAllPoints(FMap_ButtonBackDrop[types][i], FMap_Button[types][i])
            call DzFrameSetTexture(FMap_ButtonBackDrop[types][i],"ReplaceableTextures\\CommandButtons\\BTNDeathPact.blp", 0)
            
            set FMap_ButtonSP[types][i]=DzCreateFrameByTagName("SPRITE", "", FMap_ButtonBackDrop[types][i], "", FrameCount())
            call DzFrameSetModel(FMap_ButtonSP[types][i], "MapLine0.mdx", 0, 0)
            call DzFrameSetPoint(FMap_ButtonSP[types][i], JN_FRAMEPOINT_BOTTOMLEFT, FMap_ButtonBackDrop[types][i] , JN_FRAMEPOINT_CENTER, 0, 0)
            call DzFrameShow(FMap_ButtonSP[types][i], false)
        endif
        //call DzFrameShow(FMap_Button[types][0], false)
    endfunction

    private function CreateLine takes nothing returns nothing
        //1번 대각
        set FMap_LineBackDrop[1]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[1], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[1], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*5) + 0.020, -0.080 - 0.100)
        call DzFrameSetTexture(FMap_LineBackDrop[1],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[2]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[2], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[2], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*5) + 0.027, -0.080 - 0.070)
        call DzFrameSetTexture(FMap_LineBackDrop[2],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[3]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[3], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[3], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*5) + 0.033, -0.080 - 0.040)
        call DzFrameSetTexture(FMap_LineBackDrop[3],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[4]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[4], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[4], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*5) + 0.040, -0.080 - 0.010)
        call DzFrameSetTexture(FMap_LineBackDrop[4],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)

        set FMap_LineBackDrop[5]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[5], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[5], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*5) + 0.025, -0.080 + (-0.080*1) - 0.025 )
        call DzFrameSetTexture(FMap_LineBackDrop[5],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[6]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[6], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[6], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*5) + 0.035, -0.080 + (-0.080*1) - 0.015 )
        call DzFrameSetTexture(FMap_LineBackDrop[6],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        
        set FMap_LineBackDrop[7]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[7], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[7], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*5) + 0.025, -0.080 + (-0.080*2) + 0.025 )
        call DzFrameSetTexture(FMap_LineBackDrop[7],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[8]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[8], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[8], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*5) + 0.035, -0.080 + (-0.080*2) + 0.015 )
        call DzFrameSetTexture(FMap_LineBackDrop[8],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)

        set FMap_LineBackDrop[9]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[9], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[9], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*5) + 0.020, -0.080 + (-0.080*3) + 0.100)
        call DzFrameSetTexture(FMap_LineBackDrop[9],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[10]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[10], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[10], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*5) + 0.027, -0.080 + (-0.080*3) + 0.070)
        call DzFrameSetTexture(FMap_LineBackDrop[10],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[11]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[11], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[11], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*5) + 0.033, -0.080 + (-0.080*3) + 0.040)
        call DzFrameSetTexture(FMap_LineBackDrop[11],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[12]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[12], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[12], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*5) + 0.040, -0.080 + (-0.080*3) + 0.010)
        call DzFrameSetTexture(FMap_LineBackDrop[12],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)

        //2번 대각
        set FMap_LineBackDrop[37]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[37], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[37], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - 0.040, -0.080 - 0.010)
        call DzFrameSetTexture(FMap_LineBackDrop[37],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[38]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[38], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[38], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - 0.033, -0.080 - 0.040)
        call DzFrameSetTexture(FMap_LineBackDrop[38],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[39]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[39], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[39], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - 0.027, -0.080 - 0.070)
        call DzFrameSetTexture(FMap_LineBackDrop[39],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[40]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[40], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[40], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - 0.020, -0.080 - 0.100)
        call DzFrameSetTexture(FMap_LineBackDrop[40],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)

        set FMap_LineBackDrop[41]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[41], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[41], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - 0.035, -0.080 + (-0.080*1) - 0.015 )
        call DzFrameSetTexture(FMap_LineBackDrop[41],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[42]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[42], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[42], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - 0.025, -0.080 + (-0.080*1) - 0.025 )
        call DzFrameSetTexture(FMap_LineBackDrop[42],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        
        set FMap_LineBackDrop[43]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[43], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[43], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - 0.035, -0.080 + (-0.080*2) + 0.015 )
        call DzFrameSetTexture(FMap_LineBackDrop[43],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[44]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[44], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[44], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - 0.025, -0.080 + (-0.080*2) + 0.025 )
        call DzFrameSetTexture(FMap_LineBackDrop[44],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)

        set FMap_LineBackDrop[45]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[45], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[45], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - 0.040, -0.080 + (-0.080*3) + 0.010)
        call DzFrameSetTexture(FMap_LineBackDrop[45],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[46]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[46], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[46], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - 0.033, -0.080 + (-0.080*3) + 0.040)
        call DzFrameSetTexture(FMap_LineBackDrop[46],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[47]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[47], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[47], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - 0.027, -0.080 + (-0.080*3) + 0.070)
        call DzFrameSetTexture(FMap_LineBackDrop[47],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[48]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[48], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[48], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - 0.020, -0.080 + (-0.080*3) + 0.100)
        call DzFrameSetTexture(FMap_LineBackDrop[48],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)

        //3번대각
        set FMap_LineBackDrop[49]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[49], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[49], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + 0.020, -0.080 - 0.100)
        call DzFrameSetTexture(FMap_LineBackDrop[49],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[50]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[50], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[50], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + 0.027, -0.080 - 0.070)
        call DzFrameSetTexture(FMap_LineBackDrop[50],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[51]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[51], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[51], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + 0.033, -0.080 - 0.040)
        call DzFrameSetTexture(FMap_LineBackDrop[51],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[52]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[52], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[52], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + 0.040, -0.080 - 0.010)
        call DzFrameSetTexture(FMap_LineBackDrop[52],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)

        set FMap_LineBackDrop[53]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[53], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[53], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + 0.025, -0.080 + (-0.080*1) - 0.025 )
        call DzFrameSetTexture(FMap_LineBackDrop[53],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[54]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[54], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[54], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + 0.035, -0.080 + (-0.080*1) - 0.015 )
        call DzFrameSetTexture(FMap_LineBackDrop[54],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        
        set FMap_LineBackDrop[55]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[55], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[55], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + 0.025, -0.080 + (-0.080*2) + 0.025 )
        call DzFrameSetTexture(FMap_LineBackDrop[55],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[56]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[56], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[56], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + 0.035, -0.080 + (-0.080*2) + 0.015 )
        call DzFrameSetTexture(FMap_LineBackDrop[56],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)

        set FMap_LineBackDrop[57]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[57], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[57], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + 0.020, -0.080 + (-0.080*3) + 0.100)
        call DzFrameSetTexture(FMap_LineBackDrop[57],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[58]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[58], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[58], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + 0.027, -0.080 + (-0.080*3) + 0.070)
        call DzFrameSetTexture(FMap_LineBackDrop[58],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[59]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[59], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[59], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + 0.033, -0.080 + (-0.080*3) + 0.040)
        call DzFrameSetTexture(FMap_LineBackDrop[59],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[60]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[60], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[60], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + 0.040, -0.080 + (-0.080*3) + 0.010)
        call DzFrameSetTexture(FMap_LineBackDrop[60],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)

        //4번 대각
        set FMap_LineBackDrop[85]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[85], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[85], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*5) - 0.040, -0.080 - 0.010)
        call DzFrameSetTexture(FMap_LineBackDrop[85],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[86]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[86], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[86], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*5) - 0.033, -0.080 - 0.040)
        call DzFrameSetTexture(FMap_LineBackDrop[86],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[87]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[87], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[87], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*5) - 0.027, -0.080 - 0.070)
        call DzFrameSetTexture(FMap_LineBackDrop[87],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[88]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[88], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[88], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*5) - 0.020, -0.080 - 0.100)
        call DzFrameSetTexture(FMap_LineBackDrop[88],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)

        set FMap_LineBackDrop[89]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[89], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[89], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*5) - 0.035, -0.080 + (-0.080*1) - 0.015 )
        call DzFrameSetTexture(FMap_LineBackDrop[89],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[90]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[90], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[90], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*5) - 0.025, -0.080 + (-0.080*1) - 0.025 )
        call DzFrameSetTexture(FMap_LineBackDrop[90],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        
        set FMap_LineBackDrop[91]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[91], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[91], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*5) - 0.035, -0.080 + (-0.080*2) + 0.015 )
        call DzFrameSetTexture(FMap_LineBackDrop[91],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[92]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[92], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[92], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*5) - 0.025, -0.080 + (-0.080*2) + 0.025 )
        call DzFrameSetTexture(FMap_LineBackDrop[92],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)

        set FMap_LineBackDrop[93]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[93], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[93], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*5) - 0.040, -0.080 + (-0.080*3) + 0.010)
        call DzFrameSetTexture(FMap_LineBackDrop[93],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[94]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[94], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[94], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*5) - 0.033, -0.080 + (-0.080*3) + 0.040)
        call DzFrameSetTexture(FMap_LineBackDrop[94],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[95]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[95], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[95], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*5) - 0.027, -0.080 + (-0.080*3) + 0.070)
        call DzFrameSetTexture(FMap_LineBackDrop[95],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[96]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[96], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[96], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*5) - 0.020, -0.080 + (-0.080*3) + 0.100)
        call DzFrameSetTexture(FMap_LineBackDrop[96],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)

        //1번줄 앞칸
        set FMap_LineBackDrop[13]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[13], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[13], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4) + 0.025, -0.080 )
        call DzFrameSetTexture(FMap_LineBackDrop[13],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[14]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[14], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[14], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4) + 0.035, -0.080 )
        call DzFrameSetTexture(FMap_LineBackDrop[14],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[21]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[21], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[21], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3) + 0.025, -0.080 )
        call DzFrameSetTexture(FMap_LineBackDrop[21],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[22]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[22], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[22], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3) + 0.035, -0.080 )
        call DzFrameSetTexture(FMap_LineBackDrop[22],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[29]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[29], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[29], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2) + 0.025, -0.080 )
        call DzFrameSetTexture(FMap_LineBackDrop[29],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[30]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[30], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[30], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2) + 0.035, -0.080 )
        call DzFrameSetTexture(FMap_LineBackDrop[30],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        
        //1번줄 뒷칸
        set FMap_LineBackDrop[61]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[61], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[61], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1) + 0.025, -0.080 )
        call DzFrameSetTexture(FMap_LineBackDrop[61],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[62]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[62], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[62], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1) + 0.035, -0.080 )
        call DzFrameSetTexture(FMap_LineBackDrop[62],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[69]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[69], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[69], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2) + 0.025, -0.080 )
        call DzFrameSetTexture(FMap_LineBackDrop[69],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[70]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[70], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[70], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2) + 0.035, -0.080 )
        call DzFrameSetTexture(FMap_LineBackDrop[70],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[77]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[77], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[77], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3) + 0.025, -0.080 )
        call DzFrameSetTexture(FMap_LineBackDrop[77],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[78]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[78], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[78], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3) + 0.035, -0.080 )
        call DzFrameSetTexture(FMap_LineBackDrop[78],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        
        //2번줄 앞칸
        set FMap_LineBackDrop[15]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[15], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[15], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4) + 0.025, -0.080 + (-0.080*1) )
        call DzFrameSetTexture(FMap_LineBackDrop[15],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[16]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[16], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[16], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4) + 0.035, -0.080 + (-0.080*1) )
        call DzFrameSetTexture(FMap_LineBackDrop[16],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[23]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[23], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[23], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3) + 0.025, -0.080 + (-0.080*1) )
        call DzFrameSetTexture(FMap_LineBackDrop[23],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[24]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[24], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[24], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3) + 0.035, -0.080 + (-0.080*1) )
        call DzFrameSetTexture(FMap_LineBackDrop[24],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[31]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[31], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[31], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2) + 0.025, -0.080 + (-0.080*1) )
        call DzFrameSetTexture(FMap_LineBackDrop[31],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[32]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[32], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[32], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2) + 0.035, -0.080 + (-0.080*1) )
        call DzFrameSetTexture(FMap_LineBackDrop[32],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        //2번줄 뒷칸
        set FMap_LineBackDrop[63]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[63], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[63], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1) + 0.025, -0.080 + (-0.080*1) )
        call DzFrameSetTexture(FMap_LineBackDrop[63],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[64]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[64], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[64], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1) + 0.035, -0.080 + (-0.080*1) )
        call DzFrameSetTexture(FMap_LineBackDrop[64],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[71]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[71], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[71], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2) + 0.025, -0.080 + (-0.080*1) )
        call DzFrameSetTexture(FMap_LineBackDrop[71],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[72]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[72], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[72], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2) + 0.035, -0.080 + (-0.080*1) )
        call DzFrameSetTexture(FMap_LineBackDrop[72],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[79]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[79], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[79], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3) + 0.025, -0.080 + (-0.080*1) )
        call DzFrameSetTexture(FMap_LineBackDrop[79],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[80]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[80], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[80], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3) + 0.035, -0.080 + (-0.080*1) )
        call DzFrameSetTexture(FMap_LineBackDrop[80],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        //3번줄 앞칸
        set FMap_LineBackDrop[17]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[17], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[17], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4) + 0.025, -0.080 + (-0.080*2) )
        call DzFrameSetTexture(FMap_LineBackDrop[17],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[18]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[18], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[18], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4) + 0.035, -0.080 + (-0.080*2) )
        call DzFrameSetTexture(FMap_LineBackDrop[18],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[25]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[25], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[25], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3) + 0.025, -0.080 + (-0.080*2) )
        call DzFrameSetTexture(FMap_LineBackDrop[25],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[26]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[26], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[26], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3) + 0.035, -0.080 + (-0.080*2) )
        call DzFrameSetTexture(FMap_LineBackDrop[26],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[33]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[33], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[33], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2) + 0.025, -0.080 + (-0.080*2) )
        call DzFrameSetTexture(FMap_LineBackDrop[33],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[34]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[34], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[34], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2) + 0.035, -0.080 + (-0.080*2) )
        call DzFrameSetTexture(FMap_LineBackDrop[34],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        //3번줄 뒷칸
        set FMap_LineBackDrop[65]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[65], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[65], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1) + 0.025, -0.080 + (-0.080*2) )
        call DzFrameSetTexture(FMap_LineBackDrop[65],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[66]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[66], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[66], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1) + 0.035, -0.080 + (-0.080*2) )
        call DzFrameSetTexture(FMap_LineBackDrop[66],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[73]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[73], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[73], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2) + 0.025, -0.080 + (-0.080*2) )
        call DzFrameSetTexture(FMap_LineBackDrop[73],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[74]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[74], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[74], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2) + 0.035, -0.080 + (-0.080*2) )
        call DzFrameSetTexture(FMap_LineBackDrop[74],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[81]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[81], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[81], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3) + 0.025, -0.080 + (-0.080*2) )
        call DzFrameSetTexture(FMap_LineBackDrop[81],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[82]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[82], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[82], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3) + 0.035, -0.080 + (-0.080*2) )
        call DzFrameSetTexture(FMap_LineBackDrop[82],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        //4번줄 앞칸
        set FMap_LineBackDrop[19]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[19], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[19], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4) + 0.025, -0.080 + (-0.080*3) )
        call DzFrameSetTexture(FMap_LineBackDrop[19],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[20]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[20], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[20], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4) + 0.035, -0.080 + (-0.080*3) )
        call DzFrameSetTexture(FMap_LineBackDrop[20],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[27]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[27], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[27], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3) + 0.025, -0.080 + (-0.080*3) )
        call DzFrameSetTexture(FMap_LineBackDrop[27],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[28]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[28], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[28], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3) + 0.035, -0.080 + (-0.080*3) )
        call DzFrameSetTexture(FMap_LineBackDrop[28],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[35]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[35], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[35], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2) + 0.025, -0.080 + (-0.080*3) )
        call DzFrameSetTexture(FMap_LineBackDrop[35],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[36]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[36], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[36], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2) + 0.035, -0.080 + (-0.080*3) )
        call DzFrameSetTexture(FMap_LineBackDrop[36],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        //4번줄 뒷칸
        set FMap_LineBackDrop[67]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[67], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[67], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1) + 0.025, -0.080 + (-0.080*3) )
        call DzFrameSetTexture(FMap_LineBackDrop[67],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[68]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[68], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[68], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1) + 0.035, -0.080 + (-0.080*3) )
        call DzFrameSetTexture(FMap_LineBackDrop[68],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[75]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[75], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[75], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2) + 0.025, -0.080 + (-0.080*3) )
        call DzFrameSetTexture(FMap_LineBackDrop[75],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[76]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[76], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[76], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2) + 0.035, -0.080 + (-0.080*3) )
        call DzFrameSetTexture(FMap_LineBackDrop[76],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[83]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[83], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[83], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3) + 0.025, -0.080 + (-0.080*3) )
        call DzFrameSetTexture(FMap_LineBackDrop[83],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        set FMap_LineBackDrop[84]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[84], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[84], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3) + 0.035, -0.080 + (-0.080*3) )
        call DzFrameSetTexture(FMap_LineBackDrop[84],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        //보스선
        set FMap_LineBackDrop[97]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[97], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[97], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.250, -0.080 - 0.120)
        call DzFrameSetTexture(FMap_LineBackDrop[97],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        call DzFrameShow(FMap_LineBackDrop[97], false)
        set FMap_LineBackDrop[98]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[98], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[98], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.300, -0.080 - 0.120)
        call DzFrameSetTexture(FMap_LineBackDrop[98],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        call DzFrameShow(FMap_LineBackDrop[98], false)
        set FMap_LineBackDrop[99]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[99], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[99], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350, -0.080 - 0.120)
        call DzFrameSetTexture(FMap_LineBackDrop[99],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        call DzFrameShow(FMap_LineBackDrop[99], false)
        set FMap_LineBackDrop[100]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[100], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[100], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.400, -0.080 - 0.120)
        call DzFrameSetTexture(FMap_LineBackDrop[100],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        call DzFrameShow(FMap_LineBackDrop[100], false)
        set FMap_LineBackDrop[101]=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "", FrameCount())
        call DzFrameSetSize(FMap_LineBackDrop[101], 0.002, 0.002)
        call DzFrameSetPoint(FMap_LineBackDrop[101], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.450, -0.080 - 0.120)
        call DzFrameSetTexture(FMap_LineBackDrop[101],"ReplaceableTextures\\TeamColor\\TeamColor04.blp", 0)
        call DzFrameShow(FMap_LineBackDrop[101], false)
    endfunction

    private function Main takes nothing returns nothing
        local string s
        local integer i
        
        /********************************** 스킬 버튼 생성 **********************************************/
        set FMap_OpenButton = DzCreateFrameByTagName("GLUETEXTBUTTON", "", DzGetGameUI(), "template", FrameCount())
        call DzFrameSetAbsolutePoint(FMap_OpenButton, JN_FRAMEPOINT_CENTER, 0.700, 0.020)
        call DzFrameSetSize(FMap_OpenButton, 0.020, 0.020)
        call DzFrameSetScriptByCode(FMap_OpenButton, JN_FRAMEEVENT_MOUSE_UP, function ShowMenu, false)
        set FMap_OpenButtonBD=DzCreateFrameByTagName("BACKDROP", "", FMap_OpenButton, "template", FrameCount())
        call DzFrameSetTexture(FMap_OpenButtonBD, "skill.blp", 0)
        call DzFrameSetSize(FMap_OpenButtonBD, 0.020, 0.020)
        call DzFrameSetAbsolutePoint(FMap_OpenButtonBD, JN_FRAMEPOINT_CENTER, 0.700, 0.020)
        call DzFrameShow(FMap_OpenButton, false)
        
        /********************************** 메뉴 배경 생성 **********************************************/
        set FMap_BackDrop=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "StandardEditBoxBackdropTemplate", 0)
        call DzFrameSetAbsolutePoint(FMap_BackDrop, JN_FRAMEPOINT_CENTER, 0.40, 0.30)
        call DzFrameSetSize(FMap_BackDrop, 0.75, 0.39)
        
        //왼쪽
        set FMap_L2=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "template", FrameCount())
        call DzFrameSetTexture(FMap_L2, "UI_L2.blp", 0)
        call DzFrameSetSize(FMap_L2, 0.030, 0.030)
        call DzFrameSetAbsolutePoint(FMap_L2, JN_FRAMEPOINT_CENTER, 0.6850, 0.1500)
        call DzFrameShow(FMap_L2, true)
        set FMap_LB = DzCreateFrameByTagName("BUTTON", "", FMap_BackDrop, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetAbsolutePoint(FMap_LB, JN_FRAMEPOINT_CENTER, 0.6850, 0.1500)
        call DzFrameSetSize(FMap_LB, 0.030, 0.030)
        call DzFrameSetScriptByCode(FMap_LB, JN_FRAMEEVENT_MOUSE_UP, function ClickRLButton, false)
        set FMap_L=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "template", FrameCount())
        call DzFrameSetTexture(FMap_L, "UI_L.blp", 0)
        call DzFrameSetSize(FMap_L, 0.030, 0.030)
        call DzFrameSetAbsolutePoint(FMap_L, JN_FRAMEPOINT_CENTER, 0.6850, 0.1500)
        call DzFrameShow(FMap_L, false)
        
        //오른쪽
        set FMap_R2=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "template", FrameCount())
        call DzFrameSetTexture(FMap_R2, "UI_R2.blp", 0)
        call DzFrameSetSize(FMap_R2, 0.030, 0.030)
        call DzFrameSetAbsolutePoint(FMap_R2, JN_FRAMEPOINT_CENTER, 0.7300, 0.1500)
        call DzFrameShow(FMap_R2, false)
        set FMap_RB = DzCreateFrameByTagName("BUTTON", "", FMap_BackDrop, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetAbsolutePoint(FMap_RB, JN_FRAMEPOINT_CENTER, 0.7300, 0.1500)
        call DzFrameSetSize(FMap_RB, 0.030, 0.030)
        call DzFrameSetScriptByCode(FMap_RB, JN_FRAMEEVENT_MOUSE_UP, function ClickRLButton, false)
        set FMap_R=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "template", FrameCount())
        call DzFrameSetTexture(FMap_R, "UI_R.blp", 0)
        call DzFrameSetSize(FMap_R, 0.030, 0.030)
        call DzFrameSetAbsolutePoint(FMap_R, JN_FRAMEPOINT_CENTER, 0.7300, 0.1500)
        
        //시작
        call CreateLineButton(0,0)

        call CreateLineButton(1,0)
        call CreateLineButton(2,0)
        call CreateLineButton(3,0)
        call CreateLineButton(4,0)
        //보스선택or보너스
        call CreateLineButton(5,1)

        call CreateLineButton(6,1)
        call CreateLineButton(7,1)
        call CreateLineButton(8,1)
        call CreateLineButton(9,1)
        //유물상자
        call CreateLineButton(10,2)

        call CreateLineButton(11,2)
        call CreateLineButton(12,2)
        call CreateLineButton(13,2)
        call CreateLineButton(14,2)

        call CreateLineButton(15,3)
        //보스
        call CreateLineButton(16,3)
        //선
        call CreateLine()

        call DzFrameShow(FMap_Button[0][0], true)
        call DzFrameShow(FMap_Button[5][0], true)
        call DzFrameShow(FMap_Button[10][0], false)
        call DzFrameShow(FMap_Button[15][0], false)

        
        set FMap_SelectBBD=DzCreateFrameByTagName("BACKDROP", "", FMap_BackDrop, "template", FrameCount())
        call DzFrameSetTexture(FMap_SelectBBD, "UI_PickSelectButton.tga", 0)
        call DzFrameSetSize(FMap_SelectBBD, 0.06, 0.03)
        call DzFrameSetAbsolutePoint(FMap_SelectBBD, JN_FRAMEPOINT_CENTER, 0.7050, 0.1900)
        call DzFrameShow(FMap_SelectBBD, true)

        set FMap_SelectBT=DzCreateFrameByTagName("TEXT","",FMap_SelectBBD,"",0)
        call DzFrameSetAbsolutePoint(FMap_SelectBT, JN_FRAMEPOINT_CENTER, 0.7050, 0.1900)
        call DzFrameSetText(FMap_SelectBT,"결정")
        
        set FMap_SelectB=DzCreateFrameByTagName("BUTTON", "", FMap_SelectBBD, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetAllPoints(FMap_SelectB, FMap_SelectBBD)
        call DzFrameSetSize(FMap_SelectB, 0.06, 0.03)
        call DzFrameSetScriptByCode(FMap_SelectB, JN_FRAMEEVENT_MOUSE_UP, function ClickPickLineButton, false)
        
        /********************************** 메뉴 취소 버튼 **********************************************/
        set FMap_CancelButton = DzCreateFrameByTagName("GLUETEXTBUTTON", "", FMap_BackDrop, "ScriptDialogButton", 0)
        call DzFrameSetPoint(FMap_CancelButton, JN_FRAMEPOINT_TOPRIGHT, FMap_BackDrop , JN_FRAMEPOINT_TOPRIGHT, -0.015, -0.015)
        call DzFrameSetText(FMap_CancelButton, "X")
        call DzFrameSetSize(FMap_CancelButton, 0.03, 0.03)
        call DzFrameSetScriptByCode(FMap_CancelButton, JN_FRAMEEVENT_MOUSE_UP, function ShowMenu, false)
        
        set Myroom = 0
        set ClickRoom = 0

        call DzFrameShow(FMap_BackDrop, false)
        call DzFrameShow(FMap_ButtonSP[1][0], true)
        call DzFrameShow(FMap_ButtonSP[1][1], true)
        call DzFrameShow(FMap_ButtonSP[1][2], true)
        call DzFrameShow(FMap_ButtonSP[1][3], true)
    endfunction
    
    private function ESCAction takes nothing returns nothing
        if FMap_OnOff[GetPlayerId(GetTriggerPlayer())] == true then
            if ( GetTriggerPlayer() == GetLocalPlayer() ) then
                call DzFrameShow(FMap_BackDrop, false)
            endif
            set FMap_OnOff[GetPlayerId(GetTriggerPlayer())] = false
        endif
    endfunction
    
    
    private function MKey takes nothing returns nothing
        local integer key = DzGetTriggerKey()
        local integer i = 0
        local integer j = GetPlayerId(DzGetTriggerKeyPlayer())
        
        if DzGetTriggerKeyPlayer()==GetLocalPlayer() then
            set i = JNMemoryGetByte(JNGetModuleHandle("Game.dll")+0xD04FEC)
        endif
        
        if i==1 then
        else
            if PickCheck[j] == true then
                if key == 'M' then
                    if FMap_OnOff[j] == true then
                        call DzFrameShow(FMap_BackDrop, false)
                        set FMap_OnOff[j] = false
                    else
                        call DzFrameShow(FMap_BackDrop, true)
                        set FMap_OnOff[j] = true
                        if NowList == 0 then
                            call DzFrameSetPoint(FMap_Button[0][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*5), -0.080 - 0.120)

                            call DzFrameSetPoint(FMap_Button[1][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4), -0.080 + (-0.080*0))
                            call DzFrameSetPoint(FMap_Button[1][1], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4), -0.080 + (-0.080*1))
                            call DzFrameSetPoint(FMap_Button[1][2], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4), -0.080 + (-0.080*2))
                            call DzFrameSetPoint(FMap_Button[1][3], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*4), -0.080 + (-0.080*3))

                            call DzFrameSetPoint(FMap_Button[2][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3), -0.080 + (-0.080*0))
                            call DzFrameSetPoint(FMap_Button[2][1], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3), -0.080 + (-0.080*1))
                            call DzFrameSetPoint(FMap_Button[2][2], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3), -0.080 + (-0.080*2))
                            call DzFrameSetPoint(FMap_Button[2][3], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*3), -0.080 + (-0.080*3))

                            call DzFrameSetPoint(FMap_Button[3][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2), -0.080 + (-0.080*0))
                            call DzFrameSetPoint(FMap_Button[3][1], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2), -0.080 + (-0.080*1))
                            call DzFrameSetPoint(FMap_Button[3][2], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2), -0.080 + (-0.080*2))
                            call DzFrameSetPoint(FMap_Button[3][3], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*2), -0.080 + (-0.080*3))

                            call DzFrameSetPoint(FMap_Button[4][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*1), -0.080 + (-0.080*0))
                            call DzFrameSetPoint(FMap_Button[4][1], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*1), -0.080 + (-0.080*1))
                            call DzFrameSetPoint(FMap_Button[4][2], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*1), -0.080 + (-0.080*2))
                            call DzFrameSetPoint(FMap_Button[4][3], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 - (0.060*1), -0.080 + (-0.080*3))

                            call DzFrameSetPoint(FMap_Button[5][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350, -0.080 - 0.120)

                            call DzFrameSetPoint(FMap_Button[6][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1), -0.080 + (-0.080*0))
                            call DzFrameSetPoint(FMap_Button[6][1], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1), -0.080 + (-0.080*1))
                            call DzFrameSetPoint(FMap_Button[6][2], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1), -0.080 + (-0.080*2))
                            call DzFrameSetPoint(FMap_Button[6][3], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*1), -0.080 + (-0.080*3))

                            call DzFrameSetPoint(FMap_Button[7][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2), -0.080 + (-0.080*0))
                            call DzFrameSetPoint(FMap_Button[7][1], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2), -0.080 + (-0.080*1))
                            call DzFrameSetPoint(FMap_Button[7][2], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2), -0.080 + (-0.080*2))
                            call DzFrameSetPoint(FMap_Button[7][3], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*2), -0.080 + (-0.080*3))

                            call DzFrameSetPoint(FMap_Button[8][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3), -0.080 + (-0.080*0))
                            call DzFrameSetPoint(FMap_Button[8][1], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3), -0.080 + (-0.080*1))
                            call DzFrameSetPoint(FMap_Button[8][2], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3), -0.080 + (-0.080*2))
                            call DzFrameSetPoint(FMap_Button[8][3], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*3), -0.080 + (-0.080*3))

                            call DzFrameSetPoint(FMap_Button[9][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*4), -0.080 + (-0.080*0))
                            call DzFrameSetPoint(FMap_Button[9][1], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*4), -0.080 + (-0.080*1))
                            call DzFrameSetPoint(FMap_Button[9][2], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*4), -0.080 + (-0.080*2))
                            call DzFrameSetPoint(FMap_Button[9][3], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*4), -0.080 + (-0.080*3))

                            call DzFrameSetPoint(FMap_Button[10][0], JN_FRAMEPOINT_CENTER, FMap_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.350 + (0.060*5), -0.080 - 0.120)

                            call DzFrameShow(FMap_Button[0][0], true)
                            call DzFrameShow(FMap_Button[1][0], true)

                            call DzFrameShow(FMap_Button[5][0], true)
                            call DzFrameShow(FMap_Button[6][0], true)

                            call DzFrameShow(FMap_Button[10][0], true)
                            call DzFrameShow(FMap_Button[11][0], false)

                            call DzFrameShow(FMap_Button[15][0], false)
                            call DzFrameShow(FMap_Button[16][0], false)
                        endif
                    endif
                endif
            endif
        endif
    endfunction
    
    private function init takes nothing returns nothing
        local trigger t=CreateTrigger()
        local integer index
        
        set t = CreateTrigger()
        call TriggerAddAction( t, function Main )
        call TriggerRegisterTimerEventSingle( t, 0.1 )
        
        
        //esc버튼으로 인벤토리 닫기
        set t = CreateTrigger()
        
        call TriggerRegisterPlayerEvent(t, Player(0), EVENT_PLAYER_END_CINEMATIC)
        call TriggerRegisterPlayerEvent(t, Player(1), EVENT_PLAYER_END_CINEMATIC)
        call TriggerRegisterPlayerEvent(t, Player(2), EVENT_PLAYER_END_CINEMATIC)
        call TriggerRegisterPlayerEvent(t, Player(3), EVENT_PLAYER_END_CINEMATIC)

        call TriggerAddAction( t, function ESCAction )
        
        set index = 0
        loop
            set HeroSkillLevel[index][0] = 0
            set HeroSkillLevel[index][1] = 0
            set HeroSkillLevel[index][2] = 0
            set HeroSkillLevel[index][3] = 0
            set HeroSkillLevel[index][4] = 0
            set HeroSkillLevel[index][5] = 0
            set HeroSkillLevel[index][6] = 0
            set HeroSkillLevel[index][7] = 0
            set HeroSkillPoint[index] = 0
            set index = index + 1
            exitwhen index == 13
        endloop
        
        //I버튼으로 인벤토리 열기 및 닫기
        call DzTriggerRegisterKeyEventByCode(null, 'M', 0, false, function MKey)
        
        set t=CreateTrigger()
        call DzTriggerRegisterSyncData(t,("PickLine"),(false))
        call TriggerAddAction(t,function PickLineF)
        
        set t = null

        // 1 = 시작위치, 2 = 일반전투, 3 = 사건, 4 = 사건 및 전투, 5 = 휴식, 6 = 상점, 7 = 엘리트, 8 = 중간보스, 9 = 보스
        // 스프라이트 0 = 휴식, 1 = 전투, 2 = 사건, 3 = 상점, 4 = 엘리트, 5 = 중간보스, 6 = 보스
        //휴식
        set MapIcon[0] = "MapLine0.blp"
        set MapIcon[1] = "MapLine1.blp"
        //전투
        set MapIcon[2] = "ReplaceableTextures\\CommandButtons\\BTNHoldPosition.blp"
        set MapIcon[3] = "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNHoldPosition.blp"
        //사건
        set MapIcon[4] = "ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp"
        set MapIcon[5] = "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNSelectHeroOn.blp"
        //사건 및 전투
        set MapIcon[6] = "ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp"
        set MapIcon[7] = "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNSelectHeroOn.blp"
        //상점
        set MapIcon[8] = "ReplaceableTextures\\CommandButtons\\BTNMerchant.blp"
        set MapIcon[9] = "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNMerchant.blp"
        //엘리트
        set MapIcon[10] = "ReplaceableTextures\\CommandButtons\\BTNReincarnation.blp"
        set MapIcon[11] = "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNReincarnation.blp"
        //중간보스
        set MapIcon[12] = "ReplaceableTextures\\CommandButtons\\BTNGarithos.blp"
        set MapIcon[13] = "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNGarithos.blp"
        //보스
        set MapIcon[14] = "ReplaceableTextures\\CommandButtons\\BTNHeroBlademaster.blp"
        set MapIcon[15] = "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNHeroBlademaster.blp"
        
    endfunction
endlibrary
