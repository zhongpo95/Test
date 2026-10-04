// 지크프리트 연출 데이터 (자동 생성: 모델의 칼끝 궤적 분석 + 원작 모션 사운드 호출표)
// 각 휘두르기: 시작 시각, 칼이 정면을 지나는 시각(타격), 궤적 원의 중심(유닛 기준 앞·왼쪽·높이, 모델 크기 2.0 반영),
// 반지름, 원 평면의 방향(Z 방향·Y 기울기·X 회전, 도). 이펙트는 X→Y→Z 순서로 회전한다.
library HeroSiegData initializer Init
globals
    constant real SIEG_MODEL_SCALE = 2.0
    integer array SiegSwN
    real array SiegSwT0
    real array SiegSwHit
    real array SiegSwX
    real array SiegSwY
    real array SiegSwZ
    real array SiegSwR
    real array SiegSwYaw
    real array SiegSwPitch
    real array SiegSwRoll
    integer array SiegSndN
    real array SiegSndT
    integer array SiegSndA
    integer array SiegSndC
    boolean array SiegSndVoice
    // 적에게 맞았을 때만 내는 타격음(지면 타격·바위 충돌 등)
    boolean array SiegSndHit
    string array SiegSndPath
endglobals

private function SiegSw takes integer i, real t0, real hit, real x, real y, real z, real r, real yaw, real pitch, real roll returns nothing
    set SiegSwT0[i] = t0
    set SiegSwHit[i] = hit
    set SiegSwX[i] = x
    set SiegSwY[i] = y
    set SiegSwZ[i] = z
    set SiegSwR[i] = r
    set SiegSwYaw[i] = yaw
    set SiegSwPitch[i] = pitch
    set SiegSwRoll[i] = roll
endfunction

private function SiegSnd takes integer i, real t, integer a, integer c, integer voice returns nothing
    set SiegSndT[i] = t
    set SiegSndA[i] = a
    set SiegSndC[i] = c
    set SiegSndVoice[i] = voice == 1
    set SiegSndHit[i] = voice == 2
endfunction

private function InitSwing takes nothing returns nothing
    set SiegSwN[104] = 1
    call SiegSw(416, 0.367, 0.450, 40.4, -11.4, 145.4, 232.6, -0.3, 0.1, 177.1)
    set SiegSwN[105] = 1
    call SiegSw(420, 0.417, 0.483, 8.0, -16.4, 168.0, 224.4, -8.7, 14.4, 60.0)
    set SiegSwN[106] = 1
    call SiegSw(424, 0.517, 0.617, 59.4, -18.0, 131.4, 208.0, 4.1, -4.0, -141.6)
    set SiegSwN[107] = 1
    call SiegSw(428, 0.550, 0.667, 41.8, -19.4, 89.6, 238.0, -2.6, -8.2, 163.9)
    set SiegSwN[108] = 1
    call SiegSw(432, 0.517, 0.633, 30.6, -17.6, 240.6, 234.8, 2.8, -16.7, 66.6)
    set SiegSwN[109] = 1
    call SiegSw(436, 0.533, 0.617, 57.4, -19.8, 130.6, 209.6, 26.5, -20.0, -146.1)
    set SiegSwN[110] = 1
    call SiegSw(440, 0.550, 0.667, 43.2, -15.6, 87.0, 238.4, -3.0, -7.9, 164.0)
    set SiegSwN[111] = 1
    call SiegSw(444, 0.850, 0.933, -24.6, -17.6, 254.2, 269.2, 1.4, -10.4, 68.8)
    set SiegSwN[112] = 1
    call SiegSw(448, 0.500, 0.600, 61.4, 18.8, 118.4, 239.4, -29.9, -5.8, -20.3)
    set SiegSwN[113] = 1
    call SiegSw(452, 0.583, 0.667, 31.2, 76.4, 170.0, 251.4, -19.5, -22.7, -74.2)
    set SiegSwN[115] = 2
    call SiegSw(460, 0.783, 0.867, 7.8, -17.2, 152.2, 236.4, -11.2, 4.2, 44.1)
    call SiegSw(461, 1.533, 1.617, 50.8, -44.2, 145.4, 251.2, 14.9, 9.2, -156.7)
    set SiegSwN[116] = 1
    call SiegSw(464, 0.583, 0.667, 31.2, 76.4, 170.0, 251.4, -19.5, -22.6, -74.2)
    set SiegSwN[118] = 2
    call SiegSw(472, 0.783, 0.867, 7.8, -17.2, 152.2, 236.4, -11.2, 4.2, 44.1)
    call SiegSw(473, 1.533, 1.617, 50.8, -44.0, 145.4, 251.2, 14.9, 9.2, -156.7)
    set SiegSwN[119] = 1
    call SiegSw(476, 0.800, 0.900, -24.6, 15.4, 175.8, 276.8, -8.8, -3.8, 56.1)
    set SiegSwN[120] = 1
    call SiegSw(480, 0.750, 0.883, -21.0, -33.0, 266.6, 297.8, 5.7, -15.2, 69.3)
    set SiegSwN[139] = 1
    call SiegSw(556, 1.267, 1.350, 12.0, -0.0, 157.2, 266.2, 2.4, -4.1, 68.2)
    set SiegSwN[142] = 3
    call SiegSw(568, 0.167, 0.267, 25.4, -41.8, 178.2, 218.4, 16.2, -3.9, 73.1)
    call SiegSw(569, 0.583, 0.683, -0.8, -4.4, 371.2, 209.8, 0.4, -4.2, -84.0)
    call SiegSw(570, 1.017, 1.117, -0.8, -11.2, 198.8, 302.6, -0.8, 33.9, -92.4)
    set SiegSwN[143] = 1
    call SiegSw(572, 0.000, 0.200, 3.2, 0.2, 186.0, 145.0, 2.8, 3.5, -164.3)
    set SiegSwN[146] = 1
    call SiegSw(584, 0.617, 0.717, 3.6, 40.2, 112.0, 238.2, -5.5, -27.2, -81.9)
endfunction

private function InitSound takes nothing returns nothing
    set SiegSndN[104] = 2
    call SiegSnd(1248, 0.083, 0, 3, 1) // PL1100_vo_ATK_default_s
    call SiegSnd(1249, 0.133, 3, 3, 0) // wp1100_atk_swing_s
    set SiegSndN[105] = 2
    call SiegSnd(1260, 0.150, 6, 3, 1) // PL1100_vo_ATK_default_s
    call SiegSnd(1261, 0.167, 9, 3, 0) // wp1100_atk_swing_s
    set SiegSndN[106] = 2
    call SiegSnd(1272, 0.217, 12, 3, 0) // wp1100_atk_swing_s
    call SiegSnd(1273, 0.300, 15, 3, 1) // PL1100_vo_ATK_default_s
    set SiegSndN[107] = 2
    call SiegSnd(1284, 0.217, 18, 3, 1) // PL1100_vo_ATK_default_s
    call SiegSnd(1285, 0.217, 21, 3, 0) // wp1100_atk_swing_s
    set SiegSndN[108] = 2
    call SiegSnd(1296, 0.283, 24, 3, 0) // wp1100_atk_swing_m
    call SiegSnd(1297, 0.383, 27, 3, 1) // PL1100_vo_ATK_default_line_s
    set SiegSndN[109] = 2
    call SiegSnd(1308, 0.267, 30, 3, 1) // PL1100_vo_ATK_default_m
    call SiegSnd(1309, 0.433, 33, 3, 0) // wp1100_atk_swing_s
    set SiegSndN[110] = 2
    call SiegSnd(1320, 0.250, 36, 3, 0) // wp1100_atk_swing_m
    call SiegSnd(1321, 0.333, 39, 3, 1) // PL1100_vo_ATK_default_l
    set SiegSndN[111] = 3
    call SiegSnd(1332, 0.050, 42, 3, 0) // wp1100_atk_swing_s
    call SiegSnd(1333, 0.350, 45, 3, 1) // PL1100_vo_ATK_default_finish
    call SiegSnd(1334, 0.783, 48, 3, 0) // wp1100_atk_swing_m
    set SiegSndN[112] = 2
    call SiegSnd(1344, 0.100, 51, 3, 1) // PL1100_vo_ATK_default_l
    call SiegSnd(1345, 0.200, 54, 1, 0) // wp1100_atk_swing_red_s
    set SiegSndN[113] = 4
    call SiegSnd(1356, 0.083, 55, 3, 1) // PL1100_vo_ATK_default_line_s
    call SiegSnd(1357, 0.483, 58, 1, 0) // wp1100_atk_swing_red_ss
    call SiegSnd(1358, 0.683, 59, 1, 2) // wp1100_atk_ground_hit_ss
    call SiegSnd(1359, 0.750, 60, 2, 2) // wp1100_atk_rock_impact_s
    set SiegSndN[114] = 3
    call SiegSnd(1368, 0.183, 62, 3, 1) // PL1100_vo_ATK_default_l
    call SiegSnd(1369, 0.500, 65, 1, 0) // wp1100_atk_stab_m
    call SiegSnd(1370, 0.633, 66, 1, 0) // wp1100_atk_stab_whoosh
    set SiegSndN[115] = 4
    call SiegSnd(1380, 0.067, 67, 1, 0) // wp1100_atk_swing_red_ss
    call SiegSnd(1381, 0.167, 68, 3, 1) // PL1100_vo_ATK_default_justfinish
    call SiegSnd(1382, 0.550, 71, 1, 0) // wp1100_atk_swing_red_s_long
    call SiegSnd(1383, 1.300, 72, 1, 0) // wp1100_atk_swing_red_m
    set SiegSndN[116] = 4
    call SiegSnd(1392, 0.017, 73, 3, 1) // PL1100_vo_ATK_default_line_s
    call SiegSnd(1393, 0.450, 76, 1, 0) // wp1100_atk_swing_red_ss
    call SiegSnd(1394, 0.650, 77, 1, 2) // wp1100_atk_ground_hit_s
    call SiegSnd(1395, 0.683, 78, 3, 2) // wp1100_atk_rock_impact
    set SiegSndN[117] = 4
    call SiegSnd(1404, 0.183, 81, 3, 1) // PL1100_vo_ATK_default_l
    call SiegSnd(1405, 0.400, 84, 1, 0) // wp1100_atk_stab_whoosh
    call SiegSnd(1406, 0.500, 85, 1, 0) // wp1100_atk_stab_m
    call SiegSnd(1407, 0.600, 86, 1, 0) // wp1100_atk_stab_red
    set SiegSndN[118] = 4
    call SiegSnd(1416, 0.450, 87, 3, 1) // PL1100_vo_ATK_default_m
    call SiegSnd(1417, 0.550, 90, 1, 0) // wp1100_atk_swing_red_s_long
    call SiegSnd(1418, 1.200, 91, 3, 1) // PL1100_vo_ATK_default_line_s
    call SiegSnd(1419, 1.233, 94, 1, 0) // wp1100_atk_swing_red_m
    set SiegSndN[119] = 9
    call SiegSnd(1428, 0.017, 95, 3, 1) // PL1100_vo_ATK_charge_line
    call SiegSnd(1429, 0.083, 98, 3, 0) // wp1100_atk_swing_s
    call SiegSnd(1430, 0.650, 101, 1, 0) // wp1100_atk_swing_red_ss_long
    call SiegSnd(1431, 1.000, 102, 1, 0) // wp1100_atk_swing_red_s_long
    call SiegSnd(1432, 1.650, 103, 1, 0) // wp1100_atk_swing_red_l
    call SiegSnd(1433, 1.767, 104, 3, 1) // PL1100_vo_ATK_default_l
    call SiegSnd(1434, 1.900, 107, 1, 2) // wp1100_atk_ground_hit_m
    call SiegSnd(1435, 1.967, 108, 1, 0) // wp1100_atk_combo_fin_whoosh_m
    call SiegSnd(1436, 2.083, 109, 1, 2) // wp1100_atk_rock_debris_m
    set SiegSndN[120] = 5
    call SiegSnd(1440, 0.000, 110, 1, 0) // wp1100_atk_just_finish
    call SiegSnd(1441, 0.017, 111, 3, 1) // PL1100_vo_ATK_charge_l
    call SiegSnd(1442, 1.117, 114, 2, 0) // wp1100_atk_just_finish_charge
    call SiegSnd(1443, 1.550, 116, 1, 0) // wp1100_atk_swing_red_ss_long
    call SiegSnd(1444, 1.683, 117, 1, 0) // wp1100_atk_just_finish_2
    set SiegSndN[122] = 2
    call SiegSnd(1464, 0.000, 118, 3, 1) // PL1100_vo_ATK_default_l
    call SiegSnd(1465, 0.000, 121, 3, 2) // wp1100_atk_just_finish_impact
    set SiegSndN[135] = 4
    call SiegSnd(1620, 0.017, 124, 3, 1) // PL1100_vo_ATK_ability_1
    call SiegSnd(1621, 0.017, 127, 3, 0) // wp1100_ab_manigans_charge
    call SiegSnd(1622, 0.250, 130, 3, 0) // wp1100_ab_manigans_sword_move
    call SiegSnd(1623, 0.717, 133, 1, 0) // wp1100_ab_manigans_aura_start
    set SiegSndN[136] = 4
    call SiegSnd(1632, 0.000, 134, 1, 0) // wp1100_ab_Jump
    call SiegSnd(1633, 0.017, 135, 3, 1) // PL1100_vo_ATK_ability_2
    call SiegSnd(1634, 0.117, 138, 1, 0) // wp1100_ab_sword_roll
    call SiegSnd(1635, 0.633, 139, 1, 0) // wp1100_ab_sword_finish
    set SiegSndN[138] = 2
    call SiegSnd(1656, 0.017, 140, 1, 2) // wp1100_atk_ground_hit_m
    call SiegSnd(1657, 0.117, 141, 3, 2) // wp1100_atk_rock_impact
    set SiegSndN[139] = 5
    call SiegSnd(1668, 0.017, 144, 3, 1) // PL1100_vo_ATK_ability_3_a
    call SiegSnd(1669, 0.417, 147, 1, 0) // wp1100_ab_stab_m
    call SiegSnd(1670, 0.867, 148, 1, 0) // wp1100_ab_wave
    call SiegSnd(1671, 1.317, 149, 1, 2) // wp1100_ab_rock_impact
    call SiegSnd(1672, 1.333, 150, 3, 1) // PL1100_vo_ATK_ability_3_b
    set SiegSndN[140] = 1
    call SiegSnd(1680, 0.017, 153, 3, 1) // PL1100_vo_ATK_ability_4_a
    set SiegSndN[141] = 1
    call SiegSnd(1692, 0.000, 156, 1, 0) // wp1100_ab_buff_start
    set SiegSndN[142] = 6
    call SiegSnd(1704, 0.000, 157, 1, 0) // wp1100_ab_atemi
    call SiegSnd(1705, 0.400, 158, 1, 0) // wp1100_ab_jump_roll
    call SiegSnd(1706, 0.600, 159, 3, 1) // PL1100_vo_ATK_ability_4_b
    call SiegSnd(1707, 0.833, 162, 1, 0) // wp1100_atk_swing_red_l
    call SiegSnd(1708, 1.100, 163, 1, 2) // wp1100_atk_ground_hit_m
    call SiegSnd(1709, 1.167, 164, 3, 2) // wp1100_atk_rock_impact
    set SiegSndN[143] = 3
    call SiegSnd(1716, 0.283, 167, 1, 0) // wp1100_ab_stab_s
    call SiegSnd(1717, 0.667, 168, 3, 1) // PL1100_vo_ATK_ability_4_c
    call SiegSnd(1718, 0.733, 171, 1, 0) // wp1100_ab_kick_wsh
    set SiegSndN[144] = 3
    call SiegSnd(1728, 0.000, 172, 1, 0) // pl1100_ab_salvator_a
    call SiegSnd(1729, 0.150, 173, 3, 1) // PL1100_vo_ATK_ability_6
    call SiegSnd(1730, 0.967, 176, 1, 0) // pl1100_ab_salvator_b
    set SiegSndN[145] = 3
    call SiegSnd(1740, 0.000, 177, 1, 0) // pl1100_ab_mirage_a
    call SiegSnd(1741, 0.017, 178, 3, 1) // PL1100_vo_ATK_ability_5
    call SiegSnd(1742, 1.050, 181, 1, 0) // pl1100_ab_mirage_b
    set SiegSndN[146] = 3
    call SiegSnd(1752, 0.000, 182, 1, 0) // pl1100_ab_verdrangen_a
    call SiegSnd(1753, 0.017, 183, 3, 1) // PL1100_vo_ATK_ability_7
    call SiegSnd(1754, 0.683, 186, 1, 0) // pl1100_ab_verdrangen_b
    set SiegSndN[147] = 3
    call SiegSnd(1764, 0.000, 187, 1, 0) // pl1100_ab_justcombination_a
    call SiegSnd(1765, 0.017, 188, 3, 1) // PL1100_vo_ATK_ability_8
    call SiegSnd(1766, 0.783, 191, 1, 0) // pl1100_ab_justcombination_b
endfunction

private function InitPath takes nothing returns nothing
    set SiegSndPath[0] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_s_10_652184928.mp3"
    set SiegSndPath[1] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_s_11_453781605.mp3"
    set SiegSndPath[2] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_s_12_611709025.mp3"
    set SiegSndPath[3] = "Siegfried_Sound\\SE\\unnamed_1016774434.wav"
    set SiegSndPath[4] = "Siegfried_Sound\\SE\\unnamed_17896442.wav"
    set SiegSndPath[5] = "Siegfried_Sound\\SE\\unnamed_83062330.wav"
    set SiegSndPath[6] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_s_10_652184928.mp3"
    set SiegSndPath[7] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_s_11_453781605.mp3"
    set SiegSndPath[8] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_s_12_611709025.mp3"
    set SiegSndPath[9] = "Siegfried_Sound\\SE\\unnamed_1016774434.wav"
    set SiegSndPath[10] = "Siegfried_Sound\\SE\\unnamed_17896442.wav"
    set SiegSndPath[11] = "Siegfried_Sound\\SE\\unnamed_83062330.wav"
    set SiegSndPath[12] = "Siegfried_Sound\\SE\\unnamed_1016774434.wav"
    set SiegSndPath[13] = "Siegfried_Sound\\SE\\unnamed_17896442.wav"
    set SiegSndPath[14] = "Siegfried_Sound\\SE\\unnamed_83062330.wav"
    set SiegSndPath[15] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_s_10_652184928.mp3"
    set SiegSndPath[16] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_s_11_453781605.mp3"
    set SiegSndPath[17] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_s_12_611709025.mp3"
    set SiegSndPath[18] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_s_10_652184928.mp3"
    set SiegSndPath[19] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_s_11_453781605.mp3"
    set SiegSndPath[20] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_s_12_611709025.mp3"
    set SiegSndPath[21] = "Siegfried_Sound\\SE\\unnamed_1016774434.wav"
    set SiegSndPath[22] = "Siegfried_Sound\\SE\\unnamed_17896442.wav"
    set SiegSndPath[23] = "Siegfried_Sound\\SE\\unnamed_83062330.wav"
    set SiegSndPath[24] = "Siegfried_Sound\\SE\\unnamed_193115186.wav"
    set SiegSndPath[25] = "Siegfried_Sound\\SE\\unnamed_511615851.wav"
    set SiegSndPath[26] = "Siegfried_Sound\\SE\\unnamed_817757964.wav"
    set SiegSndPath[27] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_line_s_1_967305351.mp3"
    set SiegSndPath[28] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_line_s_2_433083107.mp3"
    set SiegSndPath[29] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_line_s_3_606101299.mp3"
    set SiegSndPath[30] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_m_1_850137193.mp3"
    set SiegSndPath[31] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_m_2_797696838.mp3"
    set SiegSndPath[32] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_m_3_150923239.mp3"
    set SiegSndPath[33] = "Siegfried_Sound\\SE\\unnamed_1016774434.wav"
    set SiegSndPath[34] = "Siegfried_Sound\\SE\\unnamed_17896442.wav"
    set SiegSndPath[35] = "Siegfried_Sound\\SE\\unnamed_83062330.wav"
    set SiegSndPath[36] = "Siegfried_Sound\\SE\\unnamed_193115186.wav"
    set SiegSndPath[37] = "Siegfried_Sound\\SE\\unnamed_511615851.wav"
    set SiegSndPath[38] = "Siegfried_Sound\\SE\\unnamed_817757964.wav"
    set SiegSndPath[39] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_l_1_308361897.mp3"
    set SiegSndPath[40] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_l_2_696541074.mp3"
    set SiegSndPath[41] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_l_3_798788669.mp3"
    set SiegSndPath[42] = "Siegfried_Sound\\SE\\unnamed_1016774434.wav"
    set SiegSndPath[43] = "Siegfried_Sound\\SE\\unnamed_17896442.wav"
    set SiegSndPath[44] = "Siegfried_Sound\\SE\\unnamed_83062330.wav"
    set SiegSndPath[45] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_line_l_1_349571670.mp3"
    set SiegSndPath[46] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_line_l_2_973303171.mp3"
    set SiegSndPath[47] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_line_l_3_817338426.mp3"
    set SiegSndPath[48] = "Siegfried_Sound\\SE\\unnamed_193115186.wav"
    set SiegSndPath[49] = "Siegfried_Sound\\SE\\unnamed_511615851.wav"
    set SiegSndPath[50] = "Siegfried_Sound\\SE\\unnamed_817757964.wav"
    set SiegSndPath[51] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_l_1_308361897.mp3"
    set SiegSndPath[52] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_l_2_696541074.mp3"
    set SiegSndPath[53] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_l_3_798788669.mp3"
    set SiegSndPath[54] = "Siegfried_Sound\\SE\\unnamed_785587355.wav"
    set SiegSndPath[55] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_line_s_1_967305351.mp3"
    set SiegSndPath[56] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_line_s_2_433083107.mp3"
    set SiegSndPath[57] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_line_s_3_606101299.mp3"
    set SiegSndPath[58] = "Siegfried_Sound\\SE\\unnamed_702215035.wav"
    set SiegSndPath[59] = "Siegfried_Sound\\SE\\unnamed_731005698.wav"
    set SiegSndPath[60] = "Siegfried_Sound\\SE\\unnamed_844354718.wav"
    set SiegSndPath[61] = "Siegfried_Sound\\SE\\unnamed_897672790.wav"
    set SiegSndPath[62] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_l_1_308361897.mp3"
    set SiegSndPath[63] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_l_2_696541074.mp3"
    set SiegSndPath[64] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_l_3_798788669.mp3"
    set SiegSndPath[65] = "Siegfried_Sound\\SE\\unnamed_170874190.wav"
    set SiegSndPath[66] = "Siegfried_Sound\\SE\\unnamed_448202301.wav"
    set SiegSndPath[67] = "Siegfried_Sound\\SE\\unnamed_702215035.wav"
    set SiegSndPath[68] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_justfinish_a_1_301486170.mp3"
    set SiegSndPath[69] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_justfinish_a_2_1065191216.mp3"
    set SiegSndPath[70] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_justfinish_a_3_180639266.mp3"
    set SiegSndPath[71] = "Siegfried_Sound\\SE\\unnamed_703436331.wav"
    set SiegSndPath[72] = "Siegfried_Sound\\SE\\unnamed_743223209.wav"
    set SiegSndPath[73] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_line_s_1_967305351.mp3"
    set SiegSndPath[74] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_line_s_2_433083107.mp3"
    set SiegSndPath[75] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_line_s_3_606101299.mp3"
    set SiegSndPath[76] = "Siegfried_Sound\\SE\\unnamed_702215035.wav"
    set SiegSndPath[77] = "Siegfried_Sound\\SE\\unnamed_489920525.wav"
    set SiegSndPath[78] = "Siegfried_Sound\\SE\\unnamed_1009757052.wav"
    set SiegSndPath[79] = "Siegfried_Sound\\SE\\unnamed_1023382208.wav"
    set SiegSndPath[80] = "Siegfried_Sound\\SE\\unnamed_1036813287.wav"
    set SiegSndPath[81] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_l_1_308361897.mp3"
    set SiegSndPath[82] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_l_2_696541074.mp3"
    set SiegSndPath[83] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_l_3_798788669.mp3"
    set SiegSndPath[84] = "Siegfried_Sound\\SE\\unnamed_448202301.wav"
    set SiegSndPath[85] = "Siegfried_Sound\\SE\\unnamed_170874190.wav"
    set SiegSndPath[86] = "Siegfried_Sound\\SE\\unnamed_434361355.wav"
    set SiegSndPath[87] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_m_1_850137193.mp3"
    set SiegSndPath[88] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_m_2_797696838.mp3"
    set SiegSndPath[89] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_m_3_150923239.mp3"
    set SiegSndPath[90] = "Siegfried_Sound\\SE\\unnamed_703436331.wav"
    set SiegSndPath[91] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_line_s_1_967305351.mp3"
    set SiegSndPath[92] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_line_s_2_433083107.mp3"
    set SiegSndPath[93] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_line_s_3_606101299.mp3"
    set SiegSndPath[94] = "Siegfried_Sound\\SE\\unnamed_743223209.wav"
    set SiegSndPath[95] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_charge_line_1_924817606.mp3"
    set SiegSndPath[96] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_charge_line_2_471908366.mp3"
    set SiegSndPath[97] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_charge_line_3_715656084.mp3"
    set SiegSndPath[98] = "Siegfried_Sound\\SE\\unnamed_1016774434.wav"
    set SiegSndPath[99] = "Siegfried_Sound\\SE\\unnamed_17896442.wav"
    set SiegSndPath[100] = "Siegfried_Sound\\SE\\unnamed_83062330.wav"
    set SiegSndPath[101] = "Siegfried_Sound\\SE\\unnamed_1062195902.wav"
    set SiegSndPath[102] = "Siegfried_Sound\\SE\\unnamed_703436331.wav"
    set SiegSndPath[103] = "Siegfried_Sound\\SE\\unnamed_499716480.wav"
    set SiegSndPath[104] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_l_1_308361897.mp3"
    set SiegSndPath[105] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_l_2_696541074.mp3"
    set SiegSndPath[106] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_l_3_798788669.mp3"
    set SiegSndPath[107] = "Siegfried_Sound\\SE\\unnamed_96585222.wav"
    set SiegSndPath[108] = "Siegfried_Sound\\SE\\unnamed_539374457.wav"
    set SiegSndPath[109] = "Siegfried_Sound\\SE\\unnamed_382378168.wav"
    set SiegSndPath[110] = "Siegfried_Sound\\SE\\unnamed_467863059.wav"
    set SiegSndPath[111] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_charge_l_1_846363766.mp3"
    set SiegSndPath[112] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_charge_l_2_545891468.mp3"
    set SiegSndPath[113] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_charge_l_3_611072018.mp3"
    set SiegSndPath[114] = "Siegfried_Sound\\SE\\unnamed_285488699.wav"
    set SiegSndPath[115] = "Siegfried_Sound\\SE\\unnamed_431561593.wav"
    set SiegSndPath[116] = "Siegfried_Sound\\SE\\unnamed_1062195902.wav"
    set SiegSndPath[117] = "Siegfried_Sound\\SE\\unnamed_750689740.wav"
    set SiegSndPath[118] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_l_1_308361897.mp3"
    set SiegSndPath[119] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_l_2_696541074.mp3"
    set SiegSndPath[120] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_default_l_3_798788669.mp3"
    set SiegSndPath[121] = "Siegfried_Sound\\SE\\unnamed_103910576.wav"
    set SiegSndPath[122] = "Siegfried_Sound\\SE\\unnamed_278815863.wav"
    set SiegSndPath[123] = "Siegfried_Sound\\SE\\unnamed_392683032.wav"
    set SiegSndPath[124] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_1_1_505777048.mp3"
    set SiegSndPath[125] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_1_2_394215840.mp3"
    set SiegSndPath[126] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_1_3_498273885.mp3"
    set SiegSndPath[127] = "Siegfried_Sound\\SE\\unnamed_508689479.wav"
    set SiegSndPath[128] = "Siegfried_Sound\\SE\\unnamed_683201376.wav"
    set SiegSndPath[129] = "Siegfried_Sound\\SE\\unnamed_818068544.wav"
    set SiegSndPath[130] = "Siegfried_Sound\\SE\\unnamed_135029311.wav"
    set SiegSndPath[131] = "Siegfried_Sound\\SE\\unnamed_237565895.wav"
    set SiegSndPath[132] = "Siegfried_Sound\\SE\\unnamed_444859268.wav"
    set SiegSndPath[133] = "Siegfried_Sound\\SE\\unnamed_230138953.wav"
    set SiegSndPath[134] = "Siegfried_Sound\\SE\\unnamed_127517984.wav"
    set SiegSndPath[135] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_2_a_1_558091881.mp3"
    set SiegSndPath[136] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_2_a_2_901663727.mp3"
    set SiegSndPath[137] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_2_a_3_12437439.mp3"
    set SiegSndPath[138] = "Siegfried_Sound\\SE\\unnamed_42046121.wav"
    set SiegSndPath[139] = "Siegfried_Sound\\SE\\unnamed_315371204.wav"
    set SiegSndPath[140] = "Siegfried_Sound\\SE\\unnamed_96585222.wav"
    set SiegSndPath[141] = "Siegfried_Sound\\SE\\unnamed_1009757052.wav"
    set SiegSndPath[142] = "Siegfried_Sound\\SE\\unnamed_1023382208.wav"
    set SiegSndPath[143] = "Siegfried_Sound\\SE\\unnamed_1036813287.wav"
    set SiegSndPath[144] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_3_a_1_804941251.mp3"
    set SiegSndPath[145] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_3_a_2_631508760.mp3"
    set SiegSndPath[146] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_3_a_3_1059589789.mp3"
    set SiegSndPath[147] = "Siegfried_Sound\\SE\\unnamed_163750511.wav"
    set SiegSndPath[148] = "Siegfried_Sound\\SE\\unnamed_515241495.wav"
    set SiegSndPath[149] = "Siegfried_Sound\\SE\\unnamed_313403143.wav"
    set SiegSndPath[150] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_3_b_1_856359648.mp3"
    set SiegSndPath[151] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_3_b_2_957621640.mp3"
    set SiegSndPath[152] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_3_b_3_867938289.mp3"
    set SiegSndPath[153] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_4_a_1_875870568.mp3"
    set SiegSndPath[154] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_4_a_2_1016976565.mp3"
    set SiegSndPath[155] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_4_a_3_779607628.mp3"
    set SiegSndPath[156] = "Siegfried_Sound\\SE\\unnamed_537064902.wav"
    set SiegSndPath[157] = "Siegfried_Sound\\SE\\unnamed_544924419.wav"
    set SiegSndPath[158] = "Siegfried_Sound\\SE\\unnamed_972676762.wav"
    set SiegSndPath[159] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_4_b_1_267275288.mp3"
    set SiegSndPath[160] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_4_b_2_510363342.mp3"
    set SiegSndPath[161] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_4_b_3_787571589.mp3"
    set SiegSndPath[162] = "Siegfried_Sound\\SE\\unnamed_499716480.wav"
    set SiegSndPath[163] = "Siegfried_Sound\\SE\\unnamed_96585222.wav"
    set SiegSndPath[164] = "Siegfried_Sound\\SE\\unnamed_1009757052.wav"
    set SiegSndPath[165] = "Siegfried_Sound\\SE\\unnamed_1023382208.wav"
    set SiegSndPath[166] = "Siegfried_Sound\\SE\\unnamed_1036813287.wav"
    set SiegSndPath[167] = "Siegfried_Sound\\SE\\unnamed_441723473.wav"
    set SiegSndPath[168] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_4_c_1_797362313.mp3"
    set SiegSndPath[169] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_4_c_2_269223786.mp3"
    set SiegSndPath[170] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_4_c_3_1017151762.mp3"
    set SiegSndPath[171] = "Siegfried_Sound\\SE\\unnamed_58263673.wav"
    set SiegSndPath[172] = "Siegfried_Sound\\SE\\unnamed_281186242.wav"
    set SiegSndPath[173] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_6_1_1024673463.mp3"
    set SiegSndPath[174] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_6_2_970290619.mp3"
    set SiegSndPath[175] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_6_3_911539212.mp3"
    set SiegSndPath[176] = "Siegfried_Sound\\SE\\unnamed_57407415.wav"
    set SiegSndPath[177] = "Siegfried_Sound\\SE\\unnamed_259624705.wav"
    set SiegSndPath[178] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_5_1_1_144099498.mp3"
    set SiegSndPath[179] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_5_2_1_989577767.mp3"
    set SiegSndPath[180] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_5_3_1_145910399.mp3"
    set SiegSndPath[181] = "Siegfried_Sound\\SE\\unnamed_190933286.wav"
    set SiegSndPath[182] = "Siegfried_Sound\\SE\\unnamed_274210251.wav"
    set SiegSndPath[183] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_7_1_412114078.mp3"
    set SiegSndPath[184] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_7_2_790962343.mp3"
    set SiegSndPath[185] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_7_3_323563209.mp3"
    set SiegSndPath[186] = "Siegfried_Sound\\SE\\unnamed_967615294.wav"
    set SiegSndPath[187] = "Siegfried_Sound\\SE\\unnamed_478274644.wav"
    set SiegSndPath[188] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_8_1_1000257055.mp3"
    set SiegSndPath[189] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_8_2_338441508.mp3"
    set SiegSndPath[190] = "Siegfried_Sound\\JP\\PL1100_vo_ATK_ability_8_3_1010544673.mp3"
    set SiegSndPath[191] = "Siegfried_Sound\\SE\\unnamed_989885312.wav"
endfunction

private function Init takes nothing returns nothing
    call InitSwing()
    call InitSound()
    call InitPath()
endfunction
endlibrary
