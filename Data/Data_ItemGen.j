// 자동 생성 파일(tools/generate-item-data.cjs, 원본 content/items.json). 손으로 고치지 않는다.
library ArcanaSaveItemData initializer onInit
    globals
        constant integer ARCANA_DATA_VERSION = 1
        constant integer ARCANA_ITEM_ID_MAX = 41
        // 번호 -> rawcode, 종류(0 엘릭서 1 무기 2 목걸이 3 귀걸이 4 반지 5 팔찌 6 카드 7 보석, 없으면 -1), 단계(SLK Level 과 같은 값)
        integer array ARCANA_ITEM_RAW
        integer array ARCANA_ITEM_TYPE
        integer array ARCANA_ITEM_TIER
        // 단계 -> 무기 공격력 문자열(ItemStats[1][단계] 형식), 강화 한도
        string array ARCANA_WEAPON_ATK
        integer array ARCANA_ENCHANT_MAX
    endglobals

    private function onInit takes nothing returns nothing
        local integer i = 0
        loop
            exitwhen i > ARCANA_ITEM_ID_MAX
            set ARCANA_ITEM_TYPE[i] = -1
            set i = i + 1
        endloop
        set ARCANA_ITEM_RAW[1] = 'I007'
        set ARCANA_ITEM_RAW[2] = 'I006'
        set ARCANA_ITEM_RAW[3] = 'I00R'
        set ARCANA_ITEM_TYPE[3] = 1
        set ARCANA_ITEM_TIER[3] = 2
        set ARCANA_ITEM_RAW[4] = 'I00X'
        set ARCANA_ITEM_TYPE[4] = 1
        set ARCANA_ITEM_TIER[4] = 3
        set ARCANA_ITEM_RAW[5] = 'I013'
        set ARCANA_ITEM_TYPE[5] = 1
        set ARCANA_ITEM_TIER[5] = 4
        set ARCANA_ITEM_RAW[6] = 'I019'
        set ARCANA_ITEM_TYPE[6] = 1
        set ARCANA_ITEM_TIER[6] = 5
        set ARCANA_ITEM_RAW[7] = 'I01F'
        set ARCANA_ITEM_TYPE[7] = 1
        set ARCANA_ITEM_TIER[7] = 6
        set ARCANA_ITEM_RAW[8] = 'I01L'
        set ARCANA_ITEM_TYPE[8] = 1
        set ARCANA_ITEM_TIER[8] = 7
        set ARCANA_ITEM_RAW[9] = 'I01R'
        set ARCANA_ITEM_TYPE[9] = 1
        set ARCANA_ITEM_TIER[9] = 8
        set ARCANA_ITEM_RAW[10] = 'I001'
        set ARCANA_ITEM_TYPE[10] = 1
        set ARCANA_ITEM_TIER[10] = 1
        set ARCANA_ITEM_RAW[11] = 'I00E'
        set ARCANA_ITEM_RAW[12] = 'I00D'
        set ARCANA_ITEM_RAW[13] = 'I00K'
        set ARCANA_ITEM_TYPE[13] = 6
        set ARCANA_ITEM_RAW[14] = 'I00G'
        set ARCANA_ITEM_RAW[15] = 'I00C'
        set ARCANA_ITEM_RAW[16] = 'I00A'
        set ARCANA_ITEM_RAW[17] = 'I00I'
        set ARCANA_ITEM_RAW[18] = 'I00J'
        set ARCANA_ITEM_RAW[19] = 'I009'
        set ARCANA_ITEM_RAW[20] = 'I025'
        set ARCANA_ITEM_RAW[21] = 'I026'
        set ARCANA_ITEM_RAW[22] = 'I027'
        set ARCANA_ITEM_RAW[23] = 'I01Y'
        set ARCANA_ITEM_RAW[24] = 'I00L'
        set ARCANA_ITEM_RAW[25] = 'I028'
        set ARCANA_ITEM_RAW[26] = 'I01Z'
        set ARCANA_ITEM_RAW[27] = 'I01S'
        set ARCANA_ITEM_RAW[28] = 'I029'
        set ARCANA_ITEM_RAW[29] = 'I020'
        set ARCANA_ITEM_RAW[30] = 'I01T'
        set ARCANA_ITEM_RAW[31] = 'I021'
        set ARCANA_ITEM_RAW[32] = 'I01U'
        set ARCANA_ITEM_RAW[33] = 'I022'
        set ARCANA_ITEM_RAW[34] = 'I01V'
        set ARCANA_ITEM_RAW[35] = 'I023'
        set ARCANA_ITEM_RAW[36] = 'I01W'
        set ARCANA_ITEM_RAW[37] = 'I024'
        set ARCANA_ITEM_RAW[38] = 'I01X'
        set ARCANA_ITEM_RAW[39] = 'I000'
        set ARCANA_ITEM_RAW[40] = 'I008'
        set ARCANA_ITEM_RAW[41] = 'I003'
        set ARCANA_ITEM_TYPE[41] = 0
        set ARCANA_WEAPON_ATK[1] = "1"
        set ARCANA_WEAPON_ATK[2] = "100;103;106;109;113;116;119;123;127;130;134"
        set ARCANA_WEAPON_ATK[3] = "138;143;147;151;156;160;165;170;175;181;186"
        set ARCANA_WEAPON_ATK[4] = "192;197;203;209;216;222;229;236;243;250;258"
        set ARCANA_WEAPON_ATK[5] = "265;273;281;290;299;307;317;326;336;346;356"
        set ARCANA_WEAPON_ATK[6] = "367;378;390;401;413;426;438;452;465;479;493"
        set ARCANA_WEAPON_ATK[7] = "508;523;539;555;572;589;607;625;644;663;683"
        set ARCANA_WEAPON_ATK[8] = "703;725;746;769;792;816;840;865;891;918;945"
        set ARCANA_ENCHANT_MAX[1] = 0
        set ARCANA_ENCHANT_MAX[2] = 10
        set ARCANA_ENCHANT_MAX[3] = 10
        set ARCANA_ENCHANT_MAX[4] = 10
        set ARCANA_ENCHANT_MAX[5] = 10
        set ARCANA_ENCHANT_MAX[6] = 10
        set ARCANA_ENCHANT_MAX[7] = 10
        set ARCANA_ENCHANT_MAX[8] = 10
    endfunction
endlibrary
