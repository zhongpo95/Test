library DataItem initializer init
    globals
        string array ItemStats[9][100]
        real array ItemWeaponQuality
        integer array EnchantRate[100][26]
        integer array EnchantMax
        integer array EnchantMaterial1[100][26]
        integer array EnchantMaterial2[100][26]
        IntegerPool Quality
    endglobals
        
    function MakeItem takes integer itemid returns string
        return I2S(itemid)+";"+"0"+";"+"0"+";"+"0"+";"+"0"+";"+"0"+";"+"0"+";"+"0"+";"+"0"+";"+"0"+";"+"0"
    endfunction
        
    function GetItemID takes integer itemid returns integer
        if itemid == 1 then
            return 'I001'
        elseif itemid == 'I001' then
            return 1
        elseif itemid == 2 then
            return 'I002'
        elseif itemid == 'I002' then
            return 2
        elseif itemid == 3 then
            return 'I003'
        elseif itemid == 'I003' then
            return 3
        elseif itemid == 4 then
            return 'I004'
        elseif itemid == 'I004' then
            return 4
        elseif itemid == 5 then
            return 'I005'
        elseif itemid == 'I005' then
            return 5
        elseif itemid == 6 then
            return 'I00F'
        elseif itemid == 'I00F' then
            return 6
        elseif itemid == 7 then
            return 'I006'
        elseif itemid == 'I006' then
            return 7
        elseif itemid == 8 then
            return 'I007'
        elseif itemid == 'I007' then
            return 8
        elseif itemid == 9 then
            return 'I00D'
        elseif itemid == 'I00D' then
            return 9
        elseif itemid == 10 then
            return 'I00E'
        elseif itemid == 'I00E' then
            return 10
        elseif itemid == 11 then
            return 'I00K'
        elseif itemid == 'I00K' then
            return 11
        elseif itemid == 12 then
            return 'I000'
        elseif itemid == 'I000' then
            return 12
        elseif itemid == 13 then
            return 'I009'
        elseif itemid == 'I009' then
            return 13
        elseif itemid == 14 then
            return 'I00B'
        elseif itemid == 'I00B' then
            return 14
        elseif itemid == 15 then
            return 'I00A'
        elseif itemid == 'I00A' then
            return 15
        elseif itemid == 16 then
            return 'I00C'
        elseif itemid == 'I00C' then
            return 16
        elseif itemid == 17 then
            return 'I00M'
        elseif itemid == 'I00M' then
            return 17
        elseif itemid == 18 then
            return 'I00N'
        elseif itemid == 'I00N' then
            return 18
        elseif itemid == 19 then
            return 'I00O'
        elseif itemid == 'I00O' then
            return 19
        elseif itemid == 20 then
            return 'I00P'
        elseif itemid == 'I00P' then
            return 20
        elseif itemid == 21 then
            return 'I00Q'
        elseif itemid == 'I00Q' then
            return 21
        elseif itemid == 22 then
            return 'I00R'
        elseif itemid == 'I00R' then
            return 22
        elseif itemid == 23 then
            return 'I00S'
        elseif itemid == 'I00S' then
            return 23
        elseif itemid == 24 then
            return 'I00T'
        elseif itemid == 'I00T' then
            return 24
        elseif itemid == 25 then
            return 'I00U'
        elseif itemid == 'I00U' then
            return 25
        elseif itemid == 26 then
            return 'I00V'
        elseif itemid == 'I00V' then
            return 26
        elseif itemid == 27 then
            return 'I00W'
        elseif itemid == 'I00W' then
            return 27
        elseif itemid == 28 then
            return 'I00X'
        elseif itemid == 'I00X' then
            return 28
        elseif itemid == 29 then
            return 'I00Y'
        elseif itemid == 'I00Y' then
            return 29
        elseif itemid == 30 then
            return 'I00Z'
        elseif itemid == 'I00Z' then
            return 30
        endif
        
        if itemid == 31 then
            return 'I010'
        elseif itemid == 'I010' then
            return 31
        elseif itemid == 32 then
            return 'I011'
        elseif itemid == 'I011' then
            return 32
        elseif itemid == 33 then
            return 'I012'
        elseif itemid == 'I012' then
            return 33
        elseif itemid == 34 then
            return 'I013'
        elseif itemid == 'I013' then
            return 34
        elseif itemid == 35 then
            return 'I014'
        elseif itemid == 'I014' then
            return 35
        elseif itemid == 36 then
            return 'I015'
        elseif itemid == 'I015' then
            return 36
        elseif itemid == 37 then
            return 'I016'
        elseif itemid == 'I016' then
            return 37
        elseif itemid == 38 then
            return 'I017'
        elseif itemid == 'I017' then
            return 38
        elseif itemid == 39 then
            return 'I018'
        elseif itemid == 'I018' then
            return 39
        elseif itemid == 40 then
            return 'I019'
        elseif itemid == 'I019' then
            return 40
        elseif itemid == 41 then
            return 'I01A'
        elseif itemid == 'I01A' then
            return 41
        elseif itemid == 42 then
            return 'I01B'
        elseif itemid == 'I01B' then
            return 42
        elseif itemid == 43 then
            return 'I01C'
        elseif itemid == 'I01C' then
            return 43
        elseif itemid == 44 then
            return 'I01D'
        elseif itemid == 'I01D' then
            return 44
        elseif itemid == 45 then
            return 'I01E'
        elseif itemid == 'I01E' then
            return 45
        elseif itemid == 46 then
            return 'I01F'
        elseif itemid == 'I01F' then
            return 46
        elseif itemid == 47 then
            return 'I01G'
        elseif itemid == 'I01G' then
            return 47
        elseif itemid == 48 then
            return 'I01H'
        elseif itemid == 'I01H' then
            return 48
        elseif itemid == 49 then
            return 'I01I'
        elseif itemid == 'I01I' then
            return 49
        elseif itemid == 50 then
            return 'I01J'
        elseif itemid == 'I01J' then
            return 50
        elseif itemid == 51 then
            return 'I01K'
        elseif itemid == 'I01K' then
            return 51
        elseif itemid == 52 then
            return 'I01L'
        elseif itemid == 'I01L' then
            return 52
        elseif itemid == 53 then
            return 'I01M'
        elseif itemid == 'I01M' then
            return 53
        elseif itemid == 54 then
            return 'I01N'
        elseif itemid == 'I01N' then
            return 54
        elseif itemid == 55 then
            return 'I01O'
        elseif itemid == 'I01O' then
            return 55
        elseif itemid == 56 then
            return 'I01P'
        elseif itemid == 'I01P' then
            return 56
        elseif itemid == 57 then
            return 'I01Q'
        elseif itemid == 'I01Q' then
            return 57
        elseif itemid == 58 then
            return 'I01R'
        elseif itemid == 'I01R' then
            return 58
        elseif itemid == 59 then
            return 'I00L'
        elseif itemid == 'I00L' then
            return 59
        elseif itemid == 60 then
            return 'I01S'
        elseif itemid == 'I01S' then
            return 60
        endif
        
        if itemid == 61 then
            return 'I01T'
        elseif itemid == 'I01T' then
            return 61
        elseif itemid == 62 then
            return 'I01U'
        elseif itemid == 'I01U' then
            return 62
        elseif itemid == 63 then
            return 'I01V'
        elseif itemid == 'I01V' then
            return 63
        elseif itemid == 64 then
            return 'I01W'
        elseif itemid == 'I01W' then
            return 64
        elseif itemid == 65 then
            return 'I01X'
        elseif itemid == 'I01X' then
            return 65
        elseif itemid == 66 then
            return 'I01Y'
        elseif itemid == 'I01Y' then
            return 66
        elseif itemid == 67 then
            return 'I01Z'
        elseif itemid == 'I01Z' then
            return 67
        elseif itemid == 68 then
            return 'I020'
        elseif itemid == 'I020' then
            return 68
        elseif itemid == 69 then
            return 'I021'
        elseif itemid == 'I021' then
            return 69
        elseif itemid == 70 then
            return 'I022'
        elseif itemid == 'I022' then
            return 70
        elseif itemid == 71 then
            return 'I023'
        elseif itemid == 'I023' then
            return 71
        elseif itemid == 72 then
            return 'I024'
        elseif itemid == 'I024' then
            return 72
        elseif itemid == 73 then
            return 'I025'
        elseif itemid == 'I025' then
            return 73
        elseif itemid == 74 then
            return 'I026'
        elseif itemid == 'I026' then
            return 74
        elseif itemid == 75 then
            return 'I027'
        elseif itemid == 'I027' then
            return 75
        elseif itemid == 76 then
            return 'I028'
        elseif itemid == 'I028' then
            return 76
        elseif itemid == 77 then
            return 'I029'
        elseif itemid == 'I029' then
            return 77
        endif
        
        return 0
    endfunction
    
    private function init takes nothing returns nothing
        //0보조무기, 1상의, 2하의, 3장갑, 4견갑, 5무기, 6목걸이, 7귀걸이, 8반지, 9팔찌, 10카드
        //장비 0아이템아이디, 1강화수치, 2품질, 3트라이횟수, 4장인의기운
        //악세 0아이템아이디, 1강화수치, 2품질, 3특성, 4각인1, 5각인수치, 6각인2, 7각인수치, 8각인P, 9각인P수치, 10잠금
        //목걸이 0스탯, 1체력, 2품0, 3품질 5당 추가량
        //기타 0아이템아이디, 1중첩수
        
        //보조무기
        set ItemStats[0][1] = "1"
        set ItemStats[0][2] = "2"
        set ItemStats[0][3] = "3"
        set ItemStats[0][4] = "4"
        set ItemStats[0][5] = "5"
        set ItemStats[0][6] = "6"
        set ItemStats[0][7] = "7"
        set ItemStats[0][8] = "8"
        
        //상의
        set ItemStats[1][1] = "1"
        set ItemStats[1][2] = "2"
        set ItemStats[1][3] = "3"
        set ItemStats[1][4] = "4"
        set ItemStats[1][5] = "5"
        set ItemStats[1][6] = "6"
        set ItemStats[1][7] = "7"
        set ItemStats[1][8] = "8"
        
        //하의
        set ItemStats[2][1] = "1"
        set ItemStats[2][2] = "2"
        set ItemStats[2][3] = "3"
        set ItemStats[2][4] = "4"
        set ItemStats[2][5] = "5"
        set ItemStats[2][6] = "6"
        set ItemStats[2][7] = "7"
        set ItemStats[2][8] = "8"
        
        //장갑
        set ItemStats[3][1] = "1"
        set ItemStats[3][2] = "2"
        set ItemStats[3][3] = "3"
        set ItemStats[3][4] = "4"
        set ItemStats[3][5] = "5"
        set ItemStats[3][6] = "6"
        set ItemStats[3][7] = "7"
        set ItemStats[3][8] = "8"
        
        //견갑
        set ItemStats[4][1] = "1"
        set ItemStats[4][2] = "2"
        set ItemStats[4][3] = "3"
        set ItemStats[4][4] = "4"
        set ItemStats[4][5] = "5"
        set ItemStats[4][6] = "6"
        set ItemStats[4][7] = "7"
        set ItemStats[4][8] = "8"
        
        //무기 공격력
        set ItemStats[5][1] = "10"
        //증10퍼
        set ItemStats[5][2] = "100;110;121;133;146;161;177;194;214;235;259"
        //증5퍼
        set ItemStats[5][3] = "285;299;314;330;346;363;382;401;421;442;464"
        //증5퍼
        set ItemStats[5][4] = "487;511;537;564;592;622;653;685;720;756;793"
        //증3퍼
        set ItemStats[5][5] = "833;858;884;911;938;966;995;1025;1056;1087;1120"
        //증3퍼
        set ItemStats[5][6] = "1154;1188;1224;1261;1298;1337;1377;1419;1461;1505;1550"
        //증3퍼
        set ItemStats[5][7] = "1597;1645;1694;1745;1797;1851;1907;1964;2023;2084;2146"
        //증3퍼
        set ItemStats[5][8] = "2211;2277;2345;2416;2488;2563;2640;2719;2801;2885;2971"
        
        //미구현
        //증3퍼
        //set ItemStats[5][9] = "3060;3152;3247;3344;3445;3548;3654;3764;3877;3993;4113"
        //증3퍼
        //set ItemStats[5][10] = "4236;4364;4495;4629;4768;4911;5059;5210;5367;5528;5694"
        //증3퍼
        //set ItemStats[5][11] = "5864;6040;6222;6408;6601;6799;7003;7213;7429;7652;7882"
        
        //목걸이 0스탯, 1체력, 2품0, 3품질 5당 추가량
        set ItemStats[6][1] = "150;5"
        set ItemStats[6][2] = "175;5"
        set ItemStats[6][3] = "200;5;"
        set ItemStats[6][4] = "300;5"
        set ItemStats[6][5] = "340;5;"
        set ItemStats[6][6] = "400;5;"
        set ItemStats[6][7] = "500;5;"
        
        //귀걸이 0스탯, 1체력, 2품0, 3품질 5당 추가량
        set ItemStats[7][1] = "90;3;"
        set ItemStats[7][2] = "105;3;"
        set ItemStats[7][3] = "121;3;"
        set ItemStats[7][4] = "180;3;"
        set ItemStats[7][5] = "210;3;"
        set ItemStats[7][6] = "240;3;"
        set ItemStats[7][7] = "300;3;"
        
        //반지 0스탯, 1체력, 2품0, 3품질 5당 추가량
        set ItemStats[8][1] = "65;2;"
        set ItemStats[8][2] = "70;2;"
        set ItemStats[8][3] = "80;2;"
        set ItemStats[8][4] = "120;2;"
        set ItemStats[8][5] = "140;2;"
        set ItemStats[8][6] = "160;2;"
        set ItemStats[8][7] = "200;2;"
        
        //기본 강화확률 [티어][목표]
        
        //0티어
        
        //1티어
        set EnchantRate[2][1] = 10000
        set EnchantRate[2][2] = 9000
        set EnchantRate[2][3] = 8000
        set EnchantRate[2][4] = 7000
        set EnchantRate[2][5] = 6000
        set EnchantRate[2][6] = 5000
        set EnchantRate[2][7] = 4000
        set EnchantRate[2][8] = 3000
        set EnchantRate[2][9] = 2000
        set EnchantRate[2][10] = 1000
        
        set EnchantMaterial1[2][1] = 0
        set EnchantMaterial1[2][2] = 0
        set EnchantMaterial1[2][3] = 0
        set EnchantMaterial1[2][4] = 0
        set EnchantMaterial1[2][5] = 0
        set EnchantMaterial1[2][6] = 0
        set EnchantMaterial1[2][7] = 0
        set EnchantMaterial1[2][8] = 0
        set EnchantMaterial1[2][9] = 0
        set EnchantMaterial1[2][10] = 0
        set EnchantMaterial2[2][1] = 0
        set EnchantMaterial2[2][2] = 0
        set EnchantMaterial2[2][3] = 0
        set EnchantMaterial2[2][4] = 0
        set EnchantMaterial2[2][5] = 0
        set EnchantMaterial2[2][6] = 0
        set EnchantMaterial2[2][7] = 0
        set EnchantMaterial2[2][8] = 0
        set EnchantMaterial2[2][9] = 0
        set EnchantMaterial2[2][10] = 0
        
        //2티어
        set EnchantRate[3][1] = 5000
        set EnchantRate[3][2] = 5000
        set EnchantRate[3][3] = 5000
        set EnchantRate[3][4] = 4000
        set EnchantRate[3][5] = 2000
        set EnchantRate[3][6] = 2000
        set EnchantRate[3][7] = 1000
        set EnchantRate[3][8] = 1000
        set EnchantRate[3][9] = 600
        set EnchantRate[3][10] = 600
        
        set EnchantMaterial1[3][1] = 0
        set EnchantMaterial1[3][2] = 0
        set EnchantMaterial1[3][3] = 0
        set EnchantMaterial1[3][4] = 0
        set EnchantMaterial1[3][5] = 0
        set EnchantMaterial1[3][6] = 0
        set EnchantMaterial1[3][7] = 0
        set EnchantMaterial1[3][8] = 0
        set EnchantMaterial1[3][9] = 0
        set EnchantMaterial1[3][10] = 0
        set EnchantMaterial2[3][1] = 0
        set EnchantMaterial2[3][2] = 0
        set EnchantMaterial2[3][3] = 0
        set EnchantMaterial2[3][4] = 0
        set EnchantMaterial2[3][5] = 0
        set EnchantMaterial2[3][6] = 0
        set EnchantMaterial2[3][7] = 0
        set EnchantMaterial2[3][8] = 0
        set EnchantMaterial2[3][9] = 0
        set EnchantMaterial2[3][10] = 0
        
        //3티어
        set EnchantRate[4][1] = 5000
        set EnchantRate[4][2] = 3500
        set EnchantRate[4][3] = 3500
        set EnchantRate[4][4] = 3500
        set EnchantRate[4][5] = 3000
        set EnchantRate[4][6] = 2000
        set EnchantRate[4][7] = 2000
        set EnchantRate[4][8] = 1000
        set EnchantRate[4][9] = 500
        set EnchantRate[4][10] = 300
        
        set EnchantMaterial1[4][1] = 0
        set EnchantMaterial1[4][2] = 0
        set EnchantMaterial1[4][3] = 0
        set EnchantMaterial1[4][4] = 0
        set EnchantMaterial1[4][5] = 0
        set EnchantMaterial1[4][6] = 0
        set EnchantMaterial1[4][7] = 0
        set EnchantMaterial1[4][8] = 0
        set EnchantMaterial1[4][9] = 0
        set EnchantMaterial1[4][10] = 0
        set EnchantMaterial2[4][1] = 0
        set EnchantMaterial2[4][2] = 0
        set EnchantMaterial2[4][3] = 0
        set EnchantMaterial2[4][4] = 0
        set EnchantMaterial2[4][5] = 0
        set EnchantMaterial2[4][6] = 0
        set EnchantMaterial2[4][7] = 0//110
        set EnchantMaterial2[4][8] = 0//110
        set EnchantMaterial2[4][9] = 0//110
        set EnchantMaterial2[4][10] = 0//110
        
        set EnchantRate[5][1] = 5000
        set EnchantRate[5][2] = 3500
        set EnchantRate[5][3] = 3500
        set EnchantRate[5][4] = 3500
        set EnchantRate[5][5] = 3000
        set EnchantRate[5][6] = 2000
        set EnchantRate[5][7] = 2000
        set EnchantRate[5][8] = 1000
        set EnchantRate[5][9] = 500
        set EnchantRate[5][10] = 300
        
        set EnchantMaterial1[5][1] = 0
        set EnchantMaterial1[5][2] = 0
        set EnchantMaterial1[5][3] = 0
        set EnchantMaterial1[5][4] = 0
        set EnchantMaterial1[5][5] = 0
        set EnchantMaterial1[5][6] = 0
        set EnchantMaterial1[5][7] = 0
        set EnchantMaterial1[5][8] = 0
        set EnchantMaterial1[5][9] = 0
        set EnchantMaterial1[5][10] = 0
        set EnchantMaterial1[5][11] = 0
        set EnchantMaterial1[5][12] = 0
        set EnchantMaterial1[5][13] = 0
        set EnchantMaterial1[5][14] = 0
        set EnchantMaterial1[5][15] = 0
        set EnchantMaterial2[5][1] = 0 //132
        set EnchantMaterial2[5][2] = 0 //132
        set EnchantMaterial2[5][3] = 0 //132
        set EnchantMaterial2[5][4] = 0 //132
        set EnchantMaterial2[5][5] = 0 //132
        set EnchantMaterial2[5][6] = 0 //132
        set EnchantMaterial2[5][7] = 0 //132
        set EnchantMaterial2[5][8] = 0 //132
        set EnchantMaterial2[5][9] = 0 //132
        set EnchantMaterial2[5][10] = 0 //350
        set EnchantMaterial2[5][11] = 0 //350
        set EnchantMaterial2[5][12] = 0 //350
        set EnchantMaterial2[5][13] = 0 //350
        set EnchantMaterial2[5][14] = 0 //350
        set EnchantMaterial2[5][15] = 0 //350
        
        set EnchantRate[6][1] = 5000
        set EnchantRate[6][2] = 3500
        set EnchantRate[6][3] = 3500
        set EnchantRate[6][4] = 3500
        set EnchantRate[6][5] = 3000
        set EnchantRate[6][6] = 2000
        set EnchantRate[6][7] = 2000
        set EnchantRate[6][8] = 1000
        set EnchantRate[6][9] = 500
        set EnchantRate[6][10] = 300
        
        set EnchantMaterial1[6][1] = 0
        set EnchantMaterial1[6][2] = 0
        set EnchantMaterial1[6][3] = 0
        set EnchantMaterial1[6][4] = 0
        set EnchantMaterial1[6][5] = 0
        set EnchantMaterial1[6][6] = 0
        set EnchantMaterial1[6][7] = 0
        set EnchantMaterial1[6][8] = 0
        set EnchantMaterial1[6][9] = 0
        set EnchantMaterial2[6][1] = 0 //480
        set EnchantMaterial2[6][2] = 0 //480
        set EnchantMaterial2[6][3] = 0 //520
        set EnchantMaterial2[6][4] = 0 //560
        set EnchantMaterial2[6][5] = 0 //670
        set EnchantMaterial2[6][6] = 0 //720
        set EnchantMaterial2[6][7] = 0 //810
        set EnchantMaterial2[6][8] = 0 //860
        set EnchantMaterial2[6][9] = 0 //960
        
        set EnchantRate[7][1] = 5000
        set EnchantRate[7][2] = 3500
        set EnchantRate[7][3] = 3500
        set EnchantRate[7][4] = 3500
        set EnchantRate[7][5] = 3000
        set EnchantRate[7][6] = 2000
        set EnchantRate[7][7] = 2000
        set EnchantRate[7][8] = 1000
        set EnchantRate[7][9] = 500
        set EnchantRate[7][10] = 300
        
        set EnchantMaterial1[7][1] = 0
        set EnchantMaterial1[7][2] = 0
        set EnchantMaterial1[7][3] = 0
        set EnchantMaterial1[7][4] = 0
        set EnchantMaterial1[7][5] = 0
        set EnchantMaterial1[7][6] = 0
        set EnchantMaterial1[7][7] = 0
        set EnchantMaterial1[7][8] = 0
        set EnchantMaterial1[7][9] = 0
        set EnchantMaterial1[7][10] = 0
        
        set EnchantMaterial2[7][1] = 0
        set EnchantMaterial2[7][2] = 0
        set EnchantMaterial2[7][3] = 0
        set EnchantMaterial2[7][4] = 0
        set EnchantMaterial2[7][5] = 0
        set EnchantMaterial2[7][6] = 0
        set EnchantMaterial2[7][7] = 0
        set EnchantMaterial2[7][8] = 0
        set EnchantMaterial2[7][9] = 0
        set EnchantMaterial2[7][10] = 0

        set EnchantRate[8][1] = 5000
        set EnchantRate[8][2] = 3500
        set EnchantRate[8][3] = 3500
        set EnchantRate[8][4] = 3500
        set EnchantRate[8][5] = 3000
        set EnchantRate[8][6] = 2000
        set EnchantRate[8][7] = 2000
        set EnchantRate[8][8] = 1000
        set EnchantRate[8][9] = 500
        set EnchantRate[8][10] = 300
        
        set EnchantMaterial1[8][1] = 0
        set EnchantMaterial1[8][2] = 0
        set EnchantMaterial1[8][3] = 0
        set EnchantMaterial1[8][4] = 0
        set EnchantMaterial1[8][5] = 0
        set EnchantMaterial1[8][6] = 0
        set EnchantMaterial1[8][7] = 0
        set EnchantMaterial1[8][8] = 0
        set EnchantMaterial1[8][9] = 0
        set EnchantMaterial1[8][10] = 0
        
        set EnchantMaterial2[8][1] = 0
        set EnchantMaterial2[8][2] = 0
        set EnchantMaterial2[8][3] = 0
        set EnchantMaterial2[8][4] = 0
        set EnchantMaterial2[8][5] = 0
        set EnchantMaterial2[8][6] = 0
        set EnchantMaterial2[8][7] = 0
        set EnchantMaterial2[8][8] = 0
        set EnchantMaterial2[8][9] = 0
        set EnchantMaterial2[8][10] = 0
        
        set EnchantMax[1] = 0
        set EnchantMax[2] = 10
        set EnchantMax[3] = 10
        set EnchantMax[4] = 10
        set EnchantMax[5] = 10
        set EnchantMax[6] = 10
        set EnchantMax[7] = 10
        set EnchantMax[8] = 10
        
        //품질
        set ItemWeaponQuality[0] = 10.00
        set ItemWeaponQuality[1] = 10.05
        set ItemWeaponQuality[2] = 10.20
        set ItemWeaponQuality[3] = 10.45
        set ItemWeaponQuality[4] = 10.80
        set ItemWeaponQuality[5] = 11.25
        set ItemWeaponQuality[6] = 11.80
        set ItemWeaponQuality[7] = 12.45
        set ItemWeaponQuality[8] = 13.20
        set ItemWeaponQuality[9] = 14.05
        set ItemWeaponQuality[10] = 15.00
        set ItemWeaponQuality[11] = 16.05
        set ItemWeaponQuality[12] = 17.20
        set ItemWeaponQuality[13] = 18.45
        set ItemWeaponQuality[14] = 19.80
        set ItemWeaponQuality[15] = 21.25
        set ItemWeaponQuality[16] = 22.80
        set ItemWeaponQuality[17] = 24.45
        set ItemWeaponQuality[18] = 26.20
        set ItemWeaponQuality[19] = 28.05
        set ItemWeaponQuality[20] = 30.00
        
        //나온값 -1해야함 정수풀은 0이 안됨
        set Quality = IntegerPool.Create()
        call Quality.add(1,11.45)
        call Quality.add(2,11.45)
        call Quality.add(3,10.85)
        call Quality.add(4,10.71)
        call Quality.add(5,09.19)
        call Quality.add(6,08.82)
        call Quality.add(7,07.30)
        call Quality.add(8,06.93)
        call Quality.add(9,05.42)
        call Quality.add(10,05.03)
        call Quality.add(11,03.53)
        call Quality.add(12,03.15)
        call Quality.add(13,01.64)
        call Quality.add(14,01.26)
        call Quality.add(15,00.75)
        call Quality.add(16,00.63)
        call Quality.add(17,00.53)
        call Quality.add(18,00.50)
        call Quality.add(19,00.41)
        call Quality.add(20,00.37)
        call Quality.add(21,00.08)
    endfunction
endlibrary