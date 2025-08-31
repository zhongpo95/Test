library DataItem
    globals
        hashtable ItemData = InitHashtable()
        string array ItemStats[9][100]
        real array ItemWeaponQuality
        integer array EnchantRate[100][26]
        integer array EnchantMax
        integer array EnchantMaterial1[100][26]
        integer array EnchantMaterial2[100][26]
        IntegerPool Quality
        string array itemimage
    endglobals

    //! runtextmacro 이벤트_N초가_지나면_발동("A","1.0")
        call SaveInteger(ItemData, StringHash("ITEMID"), 1, 'I007')
        call SaveInteger(ItemData, StringHash("ITEMID"), 2, 'I00M')
        call SaveInteger(ItemData, StringHash("ITEMID"), 3, 'I00S')
        call SaveInteger(ItemData, StringHash("ITEMID"), 4, 'I00Y')
        call SaveInteger(ItemData, StringHash("ITEMID"), 5, 'I014')
        call SaveInteger(ItemData, StringHash("ITEMID"), 6, 'I01A')
        call SaveInteger(ItemData, StringHash("ITEMID"), 7, 'I01G')
        call SaveInteger(ItemData, StringHash("ITEMID"), 8, 'I01M')
        call SaveInteger(ItemData, StringHash("ITEMID"), 9, 'I002')
        call SaveInteger(ItemData, StringHash("ITEMID"), 10, 'I006')
        call SaveInteger(ItemData, StringHash("ITEMID"), 11, 'I00R')
        call SaveInteger(ItemData, StringHash("ITEMID"), 12, 'I00X')
        call SaveInteger(ItemData, StringHash("ITEMID"), 13, 'I013')
        call SaveInteger(ItemData, StringHash("ITEMID"), 14, 'I019')
        call SaveInteger(ItemData, StringHash("ITEMID"), 15, 'I01F')
        call SaveInteger(ItemData, StringHash("ITEMID"), 16, 'I01L')
        call SaveInteger(ItemData, StringHash("ITEMID"), 17, 'I01R')
        call SaveInteger(ItemData, StringHash("ITEMID"), 18, 'I001')
        call SaveInteger(ItemData, StringHash("ITEMID"), 19, 'I00E')
        call SaveInteger(ItemData, StringHash("ITEMID"), 20, 'I00D')
        call SaveInteger(ItemData, StringHash("ITEMID"), 21, 'I00K')
        call SaveInteger(ItemData, StringHash("ITEMID"), 22, 'I00G')
        call SaveInteger(ItemData, StringHash("ITEMID"), 23, 'I00C')
        call SaveInteger(ItemData, StringHash("ITEMID"), 24, 'I00A')
        call SaveInteger(ItemData, StringHash("ITEMID"), 25, 'I00I')
        call SaveInteger(ItemData, StringHash("ITEMID"), 26, 'I00J')
        call SaveInteger(ItemData, StringHash("ITEMID"), 27, 'I009')
        call SaveInteger(ItemData, StringHash("ITEMID"), 28, 'I025')
        call SaveInteger(ItemData, StringHash("ITEMID"), 29, 'I026')
        call SaveInteger(ItemData, StringHash("ITEMID"), 30, 'I027')
        call SaveInteger(ItemData, StringHash("ITEMID"), 31, 'I01Y')
        call SaveInteger(ItemData, StringHash("ITEMID"), 32, 'I00L')
        call SaveInteger(ItemData, StringHash("ITEMID"), 33, 'I028')
        call SaveInteger(ItemData, StringHash("ITEMID"), 34, 'I01Z')
        call SaveInteger(ItemData, StringHash("ITEMID"), 35, 'I01S')
        call SaveInteger(ItemData, StringHash("ITEMID"), 36, 'I029')
        call SaveInteger(ItemData, StringHash("ITEMID"), 37, 'I020')
        call SaveInteger(ItemData, StringHash("ITEMID"), 38, 'I01T')
        call SaveInteger(ItemData, StringHash("ITEMID"), 39, 'I021')
        call SaveInteger(ItemData, StringHash("ITEMID"), 40, 'I01U')
        call SaveInteger(ItemData, StringHash("ITEMID"), 41, 'I022')
        call SaveInteger(ItemData, StringHash("ITEMID"), 42, 'I01V')
        call SaveInteger(ItemData, StringHash("ITEMID"), 43, 'I023')
        call SaveInteger(ItemData, StringHash("ITEMID"), 44, 'I01W')
        call SaveInteger(ItemData, StringHash("ITEMID"), 45, 'I024')
        call SaveInteger(ItemData, StringHash("ITEMID"), 46, 'I01X')
        call SaveInteger(ItemData, StringHash("ITEMID"), 47, 'I000')
        call SaveInteger(ItemData, StringHash("ITEMID"), 48, 'I008')


        //0모자, 1상의, 2하의, 3장갑, 4견갑, 5무기, 6목걸이, 7귀걸이, 8반지, 9팔찌, 10카드
        //장비 0아이템아이디, 1강화수치, 2품질, 3트라이횟수, 4장인의기운
        //악세 0아이템아이디, 1강화수치, 2품질, 3특성, 4각인1, 5각인수치, 6각인2, 7각인수치, 8각인P, 9각인P수치, 10잠금
        //목걸이 0스탯, 1체력, 2품0, 3품질 5당 추가량
        //기타 0아이템아이디, 1중첩수
        
        //모자
        set ItemStats[0][1] = "1"
        set ItemStats[0][2] = "2"
        set ItemStats[0][3] = "3"
        set ItemStats[0][4] = "4"
        set ItemStats[0][5] = "5"
        set ItemStats[0][6] = "6"
        set ItemStats[0][7] = "7"
        set ItemStats[0][8] = "8"
        
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
        
        set EnchantMaterial1[2][1] = 2
        set EnchantMaterial1[2][2] = 2
        set EnchantMaterial1[2][3] = 2
        set EnchantMaterial1[2][4] = 2
        set EnchantMaterial1[2][5] = 2
        set EnchantMaterial1[2][6] = 2
        set EnchantMaterial1[2][7] = 2
        set EnchantMaterial1[2][8] = 2
        set EnchantMaterial1[2][9] = 2
        set EnchantMaterial1[2][10] = 2
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
        set EnchantRate[3][1] = 10000
        set EnchantRate[3][2] = 9000
        set EnchantRate[3][3] = 8000
        set EnchantRate[3][4] = 7000
        set EnchantRate[3][5] = 6000
        set EnchantRate[3][6] = 5000
        set EnchantRate[3][7] = 4000
        set EnchantRate[3][8] = 3000
        set EnchantRate[3][9] = 2000
        set EnchantRate[3][10] = 1000
        
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
        set EnchantRate[4][1] = 10000
        set EnchantRate[4][2] = 9000
        set EnchantRate[4][3] = 8000
        set EnchantRate[4][4] = 7000
        set EnchantRate[4][5] = 6000
        set EnchantRate[4][6] = 5000
        set EnchantRate[4][7] = 4000
        set EnchantRate[4][8] = 3000
        set EnchantRate[4][9] = 2000
        set EnchantRate[4][10] = 1000
        
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
        set EnchantMaterial2[4][7] = 0
        set EnchantMaterial2[4][8] = 0
        set EnchantMaterial2[4][9] = 0
        set EnchantMaterial2[4][10] = 0
        
        set EnchantRate[5][1] = 10000
        set EnchantRate[5][2] = 9000
        set EnchantRate[5][3] = 8000
        set EnchantRate[5][4] = 7000
        set EnchantRate[5][5] = 6000
        set EnchantRate[5][6] = 5000
        set EnchantRate[5][7] = 4000
        set EnchantRate[5][8] = 3000
        set EnchantRate[5][9] = 2000
        set EnchantRate[5][10] = 1000
        
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

        set EnchantMaterial2[5][1] = 0
        set EnchantMaterial2[5][2] = 0
        set EnchantMaterial2[5][3] = 0
        set EnchantMaterial2[5][4] = 0
        set EnchantMaterial2[5][5] = 0
        set EnchantMaterial2[5][6] = 0
        set EnchantMaterial2[5][7] = 0
        set EnchantMaterial2[5][8] = 0
        set EnchantMaterial2[5][9] = 0
        set EnchantMaterial2[5][10] = 0
        
        set EnchantRate[6][1] = 10000
        set EnchantRate[6][2] = 9000
        set EnchantRate[6][3] = 8000
        set EnchantRate[6][4] = 7000
        set EnchantRate[6][5] = 6000
        set EnchantRate[6][6] = 5000
        set EnchantRate[6][7] = 4000
        set EnchantRate[6][8] = 3000
        set EnchantRate[6][9] = 2000
        set EnchantRate[6][10] = 1000
        
        set EnchantMaterial1[6][1] = 0
        set EnchantMaterial1[6][2] = 0
        set EnchantMaterial1[6][3] = 0
        set EnchantMaterial1[6][4] = 0
        set EnchantMaterial1[6][5] = 0
        set EnchantMaterial1[6][6] = 0
        set EnchantMaterial1[6][7] = 0
        set EnchantMaterial1[6][8] = 0
        set EnchantMaterial1[6][9] = 0
        set EnchantMaterial2[6][1] = 0
        set EnchantMaterial2[6][2] = 0
        set EnchantMaterial2[6][3] = 0
        set EnchantMaterial2[6][4] = 0
        set EnchantMaterial2[6][5] = 0
        set EnchantMaterial2[6][6] = 0
        set EnchantMaterial2[6][7] = 0
        set EnchantMaterial2[6][8] = 0
        set EnchantMaterial2[6][9] = 0
        
        set EnchantRate[7][1] = 10000
        set EnchantRate[7][2] = 9000
        set EnchantRate[7][3] = 8000
        set EnchantRate[7][4] = 7000
        set EnchantRate[7][5] = 6000
        set EnchantRate[7][6] = 5000
        set EnchantRate[7][7] = 4000
        set EnchantRate[7][8] = 3000
        set EnchantRate[7][9] = 2000
        set EnchantRate[7][10] = 1000
        
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

        set EnchantRate[8][1] = 10000
        set EnchantRate[8][2] = 9000
        set EnchantRate[8][3] = 8000
        set EnchantRate[8][4] = 7000
        set EnchantRate[8][5] = 6000
        set EnchantRate[8][6] = 5000
        set EnchantRate[8][7] = 4000
        set EnchantRate[8][8] = 3000
        set EnchantRate[8][9] = 2000
        set EnchantRate[8][10] = 1000
        
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
    //! runtextmacro 이벤트_끝()
endlibrary
