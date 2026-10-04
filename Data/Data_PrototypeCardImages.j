// 확보한 캐릭터 원본을 카드 그림과 동일 인물 보상 사건의 표지에 연결한다.
library DataPrototypeCardImages initializer Init requires DataPrototypeCatalog
    globals
        string array ProtoCharacterIconPath
        string array ProtoCharacterArtPath
    endglobals

    private function SetImages takes integer character, string icon, string art returns nothing
        set ProtoCharacterIconPath[character] = "war3mapImported\\" + icon + ".tga"
        set ProtoCharacterArtPath[character] = "war3mapImported\\" + art + ".tga"
    endfunction

    private function Init takes nothing returns nothing
        // 에미야 시로
        call SetImages(13, "UI_Card_FSU6_shirou_Icon", "UI_Card_FSU6_shirou_Art")
        // 세이버
        call SetImages(14, "UI_Card_FSU6_saber_Icon", "UI_Card_FSU6_saber_Art")
        // 토오사카 린
        call SetImages(16, "UI_Card_FSU6_rin_Icon", "UI_Card_FSU6_rin_Art")
        // 아처
        call SetImages(17, "UI_Card_FSU6_archer_Icon", "UI_Card_FSU6_archer_Art")
        // 어새신
        call SetImages(18, "UI_Card_FSU6_assassin_Icon", "UI_Card_FSU6_assassin_Art")
        // 마토 사쿠라
        call SetImages(19, "UI_Card_FSN_ch05_Icon", "UI_Card_FSN_ch05_Art")
        // 캐스터
        call SetImages(20, "UI_Card_FSU6_caster_Icon", "UI_Card_FSU6_caster_Art")
        // 후지무라 타이가
        call SetImages(21, "UI_Card_FSN_ch14_Icon", "UI_Card_FSN_ch14_Art")
        // 랜서
        call SetImages(26, "UI_Card_FSU6_lancer_Icon", "UI_Card_FSU6_lancer_Art")
        // 코토미네 키레이
        call SetImages(30, "UI_Card_FSN_ch09_Icon", "UI_Card_FSN_ch09_Art")
        // 루나
        call SetImages(84, "UI_Card_KSB_luna_Icon", "UI_Card_KSB_luna_Art")
        // 사토 카즈마
        call SetImages(85, "UI_Card_KSB_kazuma_Icon", "UI_Card_KSB_kazuma_Art")
        // 크리스
        call SetImages(86, "UI_Card_KSB_chris_Icon", "UI_Card_KSB_chris_Art")
        // 메구밍
        call SetImages(87, "UI_Card_KSB_megumin_Icon", "UI_Card_KSB_megumin_Art")
        // 다크니스
        call SetImages(88, "UI_Card_KSB_darkness_Icon", "UI_Card_KSB_darkness_Art")
        // 아쿠아
        call SetImages(89, "UI_Card_KSB_aqua_Icon", "UI_Card_KSB_aqua_Art")
        // 위즈
        call SetImages(90, "UI_Card_KSB_wiz_Icon", "UI_Card_KSB_wiz_Art")
        // 바니르
        call SetImages(91, "UI_Card_KSB_vanir_Icon", "UI_Card_KSB_vanir_Art")
        // 융융
        call SetImages(94, "UI_Card_KSB_yunyun_Icon", "UI_Card_KSB_yunyun_Art")
        // 미츠루기
        call SetImages(95, "UI_Card_KSB_mitsurugi_Icon", "UI_Card_KSB_mitsurugi_Art")
        // 카즈마
        call SetImages(123, "UI_Card_KSB_kazuma_Icon", "UI_Card_KSB_kazuma_Art")
        // 오쿠소라 아야네
        call SetImages(147, "UI_Card_BA_23005_Icon", "UI_Card_BA_23005_Art")
        // 스나오오카미 시로코
        call SetImages(148, "UI_Card_BA_10010_Icon", "UI_Card_BA_10010_Art")
        // 쿠로미 세리카
        call SetImages(149, "UI_Card_BA_13008_Icon", "UI_Card_BA_13008_Art")
        // 이자요이 노노미
        call SetImages(150, "UI_Card_Nonomi", "UI_Card_Illustration_Nonomi")
        // 타카나시 호시노
        call SetImages(151, "UI_Card_BA_10005_Icon", "UI_Card_BA_10005_Art")
        // 아지타니 히후미
        call SetImages(153, "UI_Card_BA_10003_Icon", "UI_Card_BA_10003_Art")
        // 리쿠하치마 아루
        call SetImages(161, "UI_Card_BA_10000_Icon", "UI_Card_BA_10000_Art")
        // 오니카타 카요코
        call SetImages(162, "UI_Card_BA_13005_Icon", "UI_Card_BA_13005_Art")
        // 이구사 하루카
        call SetImages(163, "UI_Card_BA_16000_Icon", "UI_Card_BA_16000_Art")
        // 아사기 무츠키
        call SetImages(164, "UI_Card_BA_13006_Icon", "UI_Card_BA_13006_Art")
        // 아야네
        call SetImages(177, "UI_Card_BA_23005_Icon", "UI_Card_BA_23005_Art")
        // 시로코
        call SetImages(180, "UI_Card_BA_10010_Icon", "UI_Card_BA_10010_Art")
        // 세리카
        call SetImages(183, "UI_Card_BA_13008_Icon", "UI_Card_BA_13008_Art")
        // 노노미
        call SetImages(186, "UI_Card_Nonomi", "UI_Card_Illustration_Nonomi")
        // 호시노
        call SetImages(189, "UI_Card_BA_10005_Icon", "UI_Card_BA_10005_Art")
        // 우이하루 카자리
        call SetImages(219, "UI_Card_RGT_10_Icon", "UI_Card_RGT_10_Art")
        // 미사카 미코토
        call SetImages(220, "UI_Card_RGT_8_Icon", "UI_Card_RGT_8_Art")
        // 시라이 쿠로코
        call SetImages(221, "UI_Card_RGT_9_Icon", "UI_Card_RGT_9_Art")
        // 카미조 토우마
        call SetImages(222, "UI_Card_RGT_37_Icon", "UI_Card_RGT_37_Art")
        // 사텐 루이코
        call SetImages(223, "UI_Card_RGT_11_Icon", "UI_Card_RGT_11_Art")
        // 콘고 미츠코
        call SetImages(230, "UI_Card_RGT_34_Icon", "UI_Card_RGT_34_Art")
        // 완나이 키누호
        call SetImages(231, "UI_Card_RGT_35_Icon", "UI_Card_RGT_35_Art")
        // 아와츠키 마아야
        call SetImages(232, "UI_Card_RGT_36_Icon", "UI_Card_RGT_36_Art")
        // 소기이타 군하
        call SetImages(233, "UI_Card_RGT_38_Icon", "UI_Card_RGT_38_Art")
        // 테츠소 츠즈리
        call SetImages(237, "UI_Card_SUP5_tessou_Icon", "UI_Card_SUP5_tessou_Art")
        // 미사카 동생
        call SetImages(252, "UI_Card_RGT_39_Icon", "UI_Card_RGT_39_Art")
        // 액셀러레이터
        call SetImages(258, "UI_Card_RGS_accelerator_Icon", "UI_Card_RGS_accelerator_Art")
        // 누노타바 시노부
        call SetImages(264, "UI_Card_RGS_nunotaba_Icon", "UI_Card_RGS_nunotaba_Art")
        // 카나메 마도카
        call SetImages(294, "UI_Card_MEU10_madoka_Icon", "UI_Card_MEU10_madoka_Art")
        // 토모에 마미
        call SetImages(295, "UI_Card_MEU10_mami_Icon", "UI_Card_MEU10_mami_Art")
        // 아케미 호무라
        call SetImages(296, "UI_Card_MEU10_homura_Icon", "UI_Card_MEU10_homura_Art")
        // 미키 사야카
        call SetImages(297, "UI_Card_MEU10_sayaka_Icon", "UI_Card_MEU10_sayaka_Art")
        // 사쿠라 쿄코
        call SetImages(298, "UI_Card_MEU10_kyoko_Icon", "UI_Card_MEU10_kyoko_Art")
        // 큐베
        call SetImages(299, "UI_Card_PMM_kyube_Icon", "UI_Card_PMM_kyube_Art")
        // 카나메 준코
        call SetImages(302, "UI_Card_SUP5_junko_Icon", "UI_Card_SUP5_junko_Art")
        // 카나메 토모히사
        call SetImages(303, "UI_Card_SUP5_tomohisa_Icon", "UI_Card_SUP5_tomohisa_Art")
        // 시즈키 히토미
        call SetImages(304, "UI_Card_SUP5_hitomi_Icon", "UI_Card_SUP5_hitomi_Art")
        // 에길
        call SetImages(357, "UI_Card_SAOFD_agil_Icon", "UI_Card_SAOFD_agil_Art")
        // 키리토
        call SetImages(358, "UI_Card_SAOFD_kirito_Icon", "UI_Card_SAOFD_kirito_Art")
        // 아스나
        call SetImages(359, "UI_Card_SAOFD_asuna_Icon", "UI_Card_SAOFD_asuna_Art")
        // 리즈벳
        call SetImages(360, "UI_Card_SAOFD_lisbeth_Icon", "UI_Card_SAOFD_lisbeth_Art")
        // 시리카
        call SetImages(361, "UI_Card_SAOFD_silica_Icon", "UI_Card_SAOFD_silica_Art")
        // 클라인
        call SetImages(362, "UI_Card_SAOFD_klein_Icon", "UI_Card_SAOFD_klein_Art")
        // 사치
        call SetImages(367, "UI_Card_SAOFD_sachi_Icon", "UI_Card_SAOFD_sachi_Art")
        // 니시다
        call SetImages(368, "UI_Card_NSU9_nishida_Icon", "UI_Card_NSU9_nishida_Art")
        // 아르고
        call SetImages(370, "UI_Card_SAOFD_argo_Icon", "UI_Card_SAOFD_argo_Art")
        // 유이
        call SetImages(413, "UI_Card_SAOFD_yui_Icon", "UI_Card_SAOFD_yui_Art")
        // 라캄
        call SetImages(425, "UI_Card_GBF_rackam_Icon", "UI_Card_GBF_rackam_Art")
        // 카타리나
        call SetImages(426, "UI_Card_GBF_katalina_Icon", "UI_Card_GBF_katalina_Art")
        // 오이겐
        call SetImages(427, "UI_Card_GBF_eugen_Icon", "UI_Card_GBF_eugen_Art")
        // 이오
        call SetImages(428, "UI_Card_GBF_io_Icon", "UI_Card_GBF_io_Art")
        // 나루메아
        call SetImages(429, "UI_Card_GBF_narmaya_Icon", "UI_Card_GBF_narmaya_Art")
        // 베인
        call SetImages(430, "UI_Card_GBF_vane_Icon", "UI_Card_GBF_vane_Art")
        // 제타
        call SetImages(431, "UI_Card_GBF_zeta_Icon", "UI_Card_GBF_zeta_Art")
        // 칼리오스트로
        call SetImages(432, "UI_Card_GBF_cagliostro_Icon", "UI_Card_GBF_cagliostro_Art")
        // 로제타
        call SetImages(434, "UI_Card_GBF_rosetta_Icon", "UI_Card_GBF_rosetta_Art")
        // 롤란
        call SetImages(435, "UI_Card_GBF_rolan_Icon", "UI_Card_GBF_rolan_Art")
        // 랜슬롯
        call SetImages(436, "UI_Card_GBF_lancelot_Icon", "UI_Card_GBF_lancelot_Art")
        // 퍼시벌
        call SetImages(437, "UI_Card_GBF_percival_Icon", "UI_Card_GBF_percival_Art")
        // 요달라하
        call SetImages(438, "UI_Card_GBF_yodarha_Icon", "UI_Card_GBF_yodarha_Art")
        // 루리아
        call SetImages(448, "UI_Card_GBF_lyria_Icon", "UI_Card_GBF_lyria_Art")
        // 이드
        call SetImages(472, "UI_Card_GBF_id_Icon", "UI_Card_GBF_id_Art")
        // 야토
        call SetImages(490, "UI_Card_NRG_yato_Icon", "UI_Card_NRG_yato_Art")
        // 유키네
        call SetImages(491, "UI_Card_NRG_yukine_Icon", "UI_Card_NRG_yukine_Art")
        // 이키 히요리
        call SetImages(492, "UI_Card_NRG_hiyori_Icon", "UI_Card_NRG_hiyori_Art")
        // 호로
        call SetImages(493, "UI_Card_SW_holo_Icon", "UI_Card_SW_holo_Art")
        // 크래프트 로렌스
        call SetImages(494, "UI_Card_SW_lawrence_Icon", "UI_Card_SW_lawrence_Art")
        // 라그나 더 블러드엣지
        call SetImages(496, "UI_Card_BB_ragna-cf_Icon", "UI_Card_BB_ragna-cf_Art")
        // 나즈린
        call SetImages(498, "UI_Card_LW_nazrin-l1_Icon", "UI_Card_LW_nazrin-l1_Art")
        // 해피
        call SetImages(502, "UI_Card_FT_happy_Icon", "UI_Card_FT_happy_Art")
        // 나츠 드래그닐
        call SetImages(503, "UI_Card_FT_nastu-dragneel_Icon", "UI_Card_FT_nastu-dragneel_Art")
        // 루시 하트필리아
        call SetImages(504, "UI_Card_FT_lucy-heartfilia_Icon", "UI_Card_FT_lucy-heartfilia_Art")
        // 그레이 풀버스터
        call SetImages(505, "UI_Card_FT_gray-fullbuster_Icon", "UI_Card_FT_gray-fullbuster_Art")
        // 엘자 스칼렛
        call SetImages(506, "UI_Card_FT_erza-scarlet_Icon", "UI_Card_FT_erza-scarlet_Art")
        // 웬디 마벨
        call SetImages(508, "UI_Card_FT_wendy-marvell_Icon", "UI_Card_FT_wendy-marvell_Art")
        // 샤를
        call SetImages(509, "UI_Card_FT_charles_Icon", "UI_Card_FT_charles_Art")
        // 가질 레드폭스
        call SetImages(511, "UI_Card_FTG_gajeel_Icon", "UI_Card_FTG_gajeel_Art")
        // 쥬비아 록서
        call SetImages(512, "UI_Card_FTG_juvia_Icon", "UI_Card_FTG_juvia_Art")
        // 미라젠 스트라우스
        call SetImages(513, "UI_Card_FTG_mirajane_Icon", "UI_Card_FTG_mirajane_Art")
        // 렉서스 드레아
        call SetImages(514, "UI_Card_FTG_laxus_Icon", "UI_Card_FTG_laxus_Art")
        // 길다트 클라이브
        call SetImages(515, "UI_Card_FTG_gildarts_Icon", "UI_Card_FTG_gildarts_Art")
        // 마카로프
        call SetImages(543, "UI_Card_QU7_makarov_Icon", "UI_Card_QU7_makarov_Art")
        // 콘
        call SetImages(570, "UI_Card_BBS_kon_Icon", "UI_Card_BBS_kon_Art")
        // 쿠로사키 이치고
        call SetImages(571, "UI_Card_BLH_01_Icon", "UI_Card_BLH_01_Art")
        // 이시다 우류
        call SetImages(572, "UI_Card_BLH_02_Icon", "UI_Card_BLH_02_Art")
        // 이노우에 오리히메
        call SetImages(573, "UI_Card_BLH_03_Icon", "UI_Card_BLH_03_Art")
        // 시호인 요루이치
        call SetImages(574, "UI_Card_BLH_76_Icon", "UI_Card_BLH_76_Art")
        // 쿠치키 루키아
        call SetImages(575, "UI_Card_BLH_20_Icon", "UI_Card_BLH_20_Art")
        // 우라하라 키스케
        call SetImages(576, "UI_Card_BLH_05_Icon", "UI_Card_BLH_05_Art")
        // 사도 야스토라
        call SetImages(577, "UI_Card_BLH_04_Icon", "UI_Card_BLH_04_Art")
        // 쿠로사키 유즈
        call SetImages(580, "UI_Card_QU7_yuzu_Icon", "UI_Card_QU7_yuzu_Art")
        // 아리사와 타츠키
        call SetImages(581, "UI_Card_SUP5_tatsuki_Icon", "UI_Card_SUP5_tatsuki_Art")
        // 돈 칸온지
        call SetImages(582, "UI_Card_BBS_kanonji_Icon", "UI_Card_BBS_kanonji_Art")
        // 쿠로사키 카린
        call SetImages(583, "UI_Card_SUP5_karin_Icon", "UI_Card_SUP5_karin_Art")
        // 쿠로사키 잇신
        call SetImages(584, "UI_Card_BLH_58_Icon", "UI_Card_BLH_58_Art")
        // 츠무기야 우루루
        call SetImages(585, "UI_Card_BBS_ururu_Icon", "UI_Card_BBS_ururu_Art")
        // 아사노 케이고
        call SetImages(586, "UI_Card_BKQ11_keigo_Icon", "UI_Card_BKQ11_keigo_Art")
        // 하나카리 진타
        call SetImages(593, "UI_Card_BBS_jinta_Icon", "UI_Card_BBS_jinta_Art")
        // 야마다 하나타로
        call SetImages(613, "UI_Card_BBS_hanataro_Icon", "UI_Card_BBS_hanataro_Art")
        // 아바라이 렌지
        call SetImages(616, "UI_Card_BLH_12_Icon", "UI_Card_BLH_12_Art")
        // 쿠치키 뱌쿠야
        call SetImages(631, "UI_Card_BLH_11_Icon", "UI_Card_BLH_11_Art")
        // 미샤
        call SetImages(643, "UI_Card_Misha", "UI_Card_Illustration_Misha")
        // 어벤츄린
        call SetImages(645, "UI_Card_HSR_1304_Icon", "UI_Card_HSR_1304_Art")
        // 스파클
        call SetImages(647, "UI_Card_HSR_1306_Icon", "UI_Card_HSR_1306_Art")
        // 블랙 스완
        call SetImages(648, "UI_Card_HSR_1307_Icon", "UI_Card_HSR_1307_Art")
        // 갤러거
        call SetImages(650, "UI_Card_HSR_1301_Icon", "UI_Card_HSR_1301_Art")
        // 아케론
        call SetImages(653, "UI_Card_HSR_1308_Icon", "UI_Card_HSR_1308_Art")
        // 제이드
        call SetImages(656, "UI_Card_HSR_1314_Icon", "UI_Card_HSR_1314_Art")
        // 로빈
        call SetImages(657, "UI_Card_HSR_1309_Icon", "UI_Card_HSR_1309_Art")
        // 부트힐
        call SetImages(659, "UI_Card_HSR_1315_Icon", "UI_Card_HSR_1315_Art")
        // 반디
        call SetImages(661, "UI_Card_HSR_1310_Icon", "UI_Card_HSR_1310_Art")
        // 선데이
        call SetImages(706, "UI_Card_HSR_1313_Icon", "UI_Card_HSR_1313_Art")
        // 윈리 록벨
        call SetImages(717, "UI_Card_FMA_3_Icon", "UI_Card_FMA_3_Art")
        // 에드워드 엘릭
        call SetImages(718, "UI_Card_FCU8_edward_Icon", "UI_Card_FCU8_edward_Art")
        // 알폰스 엘릭
        call SetImages(719, "UI_Card_FCU8_alphonse_Icon", "UI_Card_FCU8_alphonse_Art")
        // 셰스카
        call SetImages(721, "UI_Card_FMA_21_Icon", "UI_Card_FMA_21_Art")
        // 알렉스 루이 암스트롱
        call SetImages(722, "UI_Card_FMA_6_Icon", "UI_Card_FMA_6_Art")
        // 이즈미 커티스
        call SetImages(723, "UI_Card_FMA_25_Icon", "UI_Card_FMA_25_Art")
        // 로이 머스탱
        call SetImages(725, "UI_Card_FMA_4_Icon", "UI_Card_FMA_4_Art")
        // 리자 호크아이
        call SetImages(726, "UI_Card_FMA_5_Icon", "UI_Card_FMA_5_Art")
        // 마스 휴즈
        call SetImages(727, "UI_Card_FMA_7_Icon", "UI_Card_FMA_7_Art")
        // 피나코 록벨
        call SetImages(728, "UI_Card_FMA_13_Icon", "UI_Card_FMA_13_Art")
        // 시그 커티스
        call SetImages(729, "UI_Card_FMA_26_Icon", "UI_Card_FMA_26_Art")
        // 린 야오
        call SetImages(730, "UI_Card_FMA_29_Icon", "UI_Card_FMA_29_Art")
        // 장 하보크
        call SetImages(738, "UI_Card_FMA_17_Icon", "UI_Card_FMA_17_Art")
        // 그리드
        call SetImages(761, "UI_Card_FMA_27_Icon", "UI_Card_FMA_27_Art")
        // 반 호엔하임
        call SetImages(773, "UI_Card_FMA_34_Icon", "UI_Card_FMA_34_Art")
        // 칸자키 아오이
        call SetImages(794, "UI_Card_KNYS_aoi_Icon", "UI_Card_KNYS_aoi_Art")
        // 카마도 탄지로
        call SetImages(795, "UI_Card_KNY_tanjiro_Icon", "UI_Card_KNY_tanjiro_Art")
        // 츠유리 카나오
        call SetImages(796, "UI_Card_KNY_kanawo_Icon", "UI_Card_KNY_kanawo_Art")
        // 코쵸 시노부
        call SetImages(797, "UI_Card_KNY_shinobu_Icon", "UI_Card_KNY_shinobu_Art")
        // 아가츠마 젠이츠
        call SetImages(798, "UI_Card_KNY_zennitsu_Icon", "UI_Card_KNY_zennitsu_Art")
        // 하시비라 이노스케
        call SetImages(799, "UI_Card_KNY_inosuke_Icon", "UI_Card_KNY_inosuke_Art")
        // 무라타
        call SetImages(806, "UI_Card_KNYG_murata_Icon", "UI_Card_KNYG_murata_Art")
        // 카마도 네즈코
        call SetImages(808, "UI_Card_KNY_neduko_Icon", "UI_Card_KNY_neduko_Art")
        // 렌고쿠 쿄쥬로
        call SetImages(833, "UI_Card_KNY_kyojurou_Icon", "UI_Card_KNY_kyojurou_Art")
        // 콧코로
        call SetImages(857, "UI_Card_PCR_105931_Icon", "UI_Card_PCR_105931_Art")
        // 페코린느
        call SetImages(858, "UI_Card_PCR_105831_Icon", "UI_Card_PCR_105831_Art")
        // 캬루
        call SetImages(861, "UI_Card_PCR_106031_Icon", "UI_Card_PCR_106031_Art")
        // 아오이
        call SetImages(865, "UI_Card_PCR_104031_Icon", "UI_Card_PCR_104031_Art")
        // 츠무기
        call SetImages(867, "UI_Card_PCR_105431_Icon", "UI_Card_PCR_105431_Art")
        // 카스미
        call SetImages(868, "UI_Card_PCR_101431_Icon", "UI_Card_PCR_101431_Art")
        // 모니카
        call SetImages(869, "UI_Card_PCR_105331_Icon", "UI_Card_PCR_105331_Art")
        // 노조미
        call SetImages(870, "UI_Card_PCR_102931_Icon", "UI_Card_PCR_102931_Art")
        // 캐르
        call SetImages(888, "UI_Card_PCR_106031_Icon", "UI_Card_PCR_106031_Art")
        // 유우키
        call SetImages(894, "UI_Card_PCRS_yuuki_Icon", "UI_Card_PCRS_yuuki_Art")

        // 모든 선택지에서 같은 인물의 카드를 얻는 사건만 해당 인물의 표지를 사용한다.
        // 학교에 남은 두 사람
        set ProtoEventIcon[69] = ProtoCharacterIconPath[16]
        // 돌아갈 수 없어진 저녁
        set ProtoEventIcon[70] = ProtoCharacterIconPath[13]
        // 성배전쟁이라는 이름
        set ProtoEventIcon[71] = ProtoCharacterIconPath[16]
        // 버서커가 막아선 길
        set ProtoEventIcon[72] = ProtoCharacterIconPath[14]
        // 집에 남겨 둔 일상
        set ProtoEventIcon[73] = ProtoCharacterIconPath[13]
        // 학교에서 맺은 휴전
        set ProtoEventIcon[74] = ProtoCharacterIconPath[16]
        // 류도사의 밤
        set ProtoEventIcon[75] = ProtoCharacterIconPath[17]
        // 결계 안의 학교
        set ProtoEventIcon[76] = ProtoCharacterIconPath[13]
        // 뜻밖의 적과 빈틈
        set ProtoEventIcon[77] = ProtoCharacterIconPath[16]
        // 빼앗긴 계약
        set ProtoEventIcon[78] = ProtoCharacterIconPath[14]
        // 성으로 향한 이유
        set ProtoEventIcon[79] = ProtoCharacterIconPath[16]
        // 같은 얼굴이 품은 답
        set ProtoEventIcon[80] = ProtoCharacterIconPath[17]
        // 이상을 다시 말하는 밤
        set ProtoEventIcon[81] = ProtoCharacterIconPath[13]
        // 성배 앞에 남은 사람들
        set ProtoEventIcon[82] = ProtoCharacterIconPath[16]
        // 끝까지 이어진 검
        set ProtoEventIcon[83] = ProtoCharacterIconPath[13]
        // 다음 아침을 위한 이상
        set ProtoEventIcon[84] = ProtoCharacterIconPath[16]
        // 모험 직전의 잔돈
        set ProtoEventIcon[90] = ProtoCharacterIconPath[89]
        // 처음 적는 모험가 이름
        set ProtoEventIcon[102] = ProtoCharacterIconPath[89]
        // 폭렬 마법 한 번의 약속
        set ProtoEventIcon[103] = ProtoCharacterIconPath[87]
        // 앞에 서고 싶은 사람
        set ProtoEventIcon[104] = ProtoCharacterIconPath[88]
        // 매일 같은 언덕
        set ProtoEventIcon[105] = ProtoCharacterIconPath[87]
        // 화가 난 성의 주인
        set ProtoEventIcon[106] = ProtoCharacterIconPath[123]
        // 호수에서 배운 기대의 크기
        set ProtoEventIcon[107] = ProtoCharacterIconPath[89]
        // 마을을 지키는 서툰 합
        set ProtoEventIcon[108] = ProtoCharacterIconPath[88]
        // 겨울에 걸린 의뢰
        set ProtoEventIcon[109] = ProtoCharacterIconPath[123]
        // 위즈의 조용한 가게
        set ProtoEventIcon[110] = ProtoCharacterIconPath[90]
        // 처음 생긴 돌아올 집
        set ProtoEventIcon[111] = ProtoCharacterIconPath[89]
        // 디스트로이어가 다가오는 날
        set ProtoEventIcon[112] = ProtoCharacterIconPath[87]
        // 자랑보다 먼저 떠오른 얼굴
        set ProtoEventIcon[113] = ProtoCharacterIconPath[123]
        // 세리카의 교대 시간
        set ProtoEventIcon[116] = ProtoCharacterIconPath[149]
        // 낡은 물건의 지워진 항목
        set ProtoEventIcon[124] = ProtoCharacterIconPath[147]
        // 아직 주문하지 않았는데
        set ProtoEventIcon[128] = ProtoCharacterIconPath[162]
        // 잡초라는 말 다음
        set ProtoEventIcon[129] = ProtoCharacterIconPath[163]
        // 사과가 끝난 뒤의 한마디
        set ProtoEventIcon[132] = ProtoCharacterIconPath[162]
        // 모래 속에 남은 학교
        set ProtoEventIcon[133] = ProtoCharacterIconPath[177]
        // 전학생 없는 첫 인사
        set ProtoEventIcon[134] = ProtoCharacterIconPath[180]
        // 세리카가 남기는 수고
        set ProtoEventIcon[135] = ProtoCharacterIconPath[183]
        // 노노미가 지키는 분위기
        set ProtoEventIcon[136] = ProtoCharacterIconPath[186]
        // 호시노의 느긋한 대답
        set ProtoEventIcon[137] = ProtoCharacterIconPath[189]
        // 같은 교실의 작전 회의
        set ProtoEventIcon[138] = ProtoCharacterIconPath[177]
        // 새로 만난 협력자
        set ProtoEventIcon[139] = ProtoCharacterIconPath[180]
        // 수족관에서 남은 말
        set ProtoEventIcon[140] = ProtoCharacterIconPath[189]
        // 땅의 주인을 확인하다
        set ProtoEventIcon[141] = ProtoCharacterIconPath[177]
        // 남겨진 편지
        set ProtoEventIcon[142] = ProtoCharacterIconPath[180]
        // 빈 자리를 지키는 사람들
        set ProtoEventIcon[143] = ProtoCharacterIconPath[183]
        // 제안에 넘기지 않은 책임
        set ProtoEventIcon[144] = ProtoCharacterIconPath[177]
        // 사막 너머로 이어진 부름
        set ProtoEventIcon[145] = ProtoCharacterIconPath[180]
        // 다섯 자리가 다시 모인 아침
        set ProtoEventIcon[146] = ProtoCharacterIconPath[189]
        // 말을 걸었는데 비어 있는 자리
        set ProtoEventIcon[163] = ProtoCharacterIconPath[237]
        // 자판기 앞의 평범한 오후
        set ProtoEventIcon[168] = ProtoCharacterIconPath[220]
        // 같은 얼굴을 한 낯선 사람
        set ProtoEventIcon[169] = ProtoCharacterIconPath[252]
        // 숫자로 적힌 실험
        set ProtoEventIcon[170] = ProtoCharacterIconPath[220]
        // 액셀러레이터가 있는 밤
        set ProtoEventIcon[171] = ProtoCharacterIconPath[258]
        // 혼자 지우려는 기록
        set ProtoEventIcon[172] = ProtoCharacterIconPath[220]
        // 남은 연구소의 이름
        set ProtoEventIcon[173] = ProtoCharacterIconPath[264]
        // 시설을 막는 또 다른 손
        set ProtoEventIcon[174] = ProtoCharacterIconPath[220]
        // 친구들이 느끼는 빈자리
        set ProtoEventIcon[175] = ProtoCharacterIconPath[221]
        // 무너진 시설 뒤의 계속
        set ProtoEventIcon[176] = ProtoCharacterIconPath[220]
        // 다리 위의 대답
        set ProtoEventIcon[177] = ProtoCharacterIconPath[222]
        // 번호와 다른 취향
        set ProtoEventIcon[178] = ProtoCharacterIconPath[252]
        // 도움을 청하는 말
        set ProtoEventIcon[179] = ProtoCharacterIconPath[220]
        // 최강이라는 계산 밖
        set ProtoEventIcon[180] = ProtoCharacterIconPath[222]
        // 멈춘 실험 다음의 질문
        set ProtoEventIcon[181] = ProtoCharacterIconPath[252]
        // 한 사람씩 남기는 이름
        set ProtoEventIcon[182] = ProtoCharacterIconPath[220]
        // 전학생이 먼저 끝낸 준비
        set ProtoEventIcon[193] = ProtoCharacterIconPath[296]
        // 방문 전에 접지 않은 지도
        set ProtoEventIcon[194] = ProtoCharacterIconPath[295]
        // 꿈에서 보았던 소녀
        set ProtoEventIcon[197] = ProtoCharacterIconPath[294]
        // 계약 전에 묻는 질문
        set ProtoEventIcon[198] = ProtoCharacterIconPath[294]
        // 선배가 내어 준 자리
        set ProtoEventIcon[199] = ProtoCharacterIconPath[295]
        // 다시 오지 않는 인사
        set ProtoEventIcon[200] = ProtoCharacterIconPath[294]
        // 사야카가 고른 소원
        set ProtoEventIcon[201] = ProtoCharacterIconPath[297]
        // 쿄코와 다른 대답
        set ProtoEventIcon[202] = ProtoCharacterIconPath[298]
        // 소울 젬이 뜻하는 것
        set ProtoEventIcon[203] = ProtoCharacterIconPath[296]
        // 괜찮다는 말의 빈틈
        set ProtoEventIcon[204] = ProtoCharacterIconPath[297]
        // 돌아올 수 없는 경계
        set ProtoEventIcon[205] = ProtoCharacterIconPath[298]
        // 호무라가 반복한 시간
        set ProtoEventIcon[206] = ProtoCharacterIconPath[296]
        // 한 사람에게 모인 무게
        set ProtoEventIcon[207] = ProtoCharacterIconPath[294]
        // 발푸르기스의 밤 앞
        set ProtoEventIcon[208] = ProtoCharacterIconPath[296]
        // 마도카가 찾아낸 소원
        set ProtoEventIcon[209] = ProtoCharacterIconPath[294]
        // 보이지 않아도 남은 친구
        set ProtoEventIcon[210] = ProtoCharacterIconPath[296]
        // 풍림화산의 빈 뒷자리
        set ProtoEventIcon[219] = ProtoCharacterIconPath[362]
        // 옆 사람도 들은 답
        set ProtoEventIcon[224] = ProtoCharacterIconPath[370]
        // 돌아갈 길 다음에 묻는 것
        set ProtoEventIcon[227] = ProtoCharacterIconPath[370]
        // 로그아웃 없는 시작
        set ProtoEventIcon[230] = ProtoCharacterIconPath[358]
        // 첫 보스 뒤의 이름
        set ProtoEventIcon[231] = ProtoCharacterIconPath[359]
        // 길드에 생긴 식탁
        set ProtoEventIcon[232] = ProtoCharacterIconPath[367]
        // 끝내 남은 메시지
        set ProtoEventIcon[233] = ProtoCharacterIconPath[358]
        // 숲에서 맺은 작은 도움
        set ProtoEventIcon[234] = ProtoCharacterIconPath[361]
        // 안전권이라는 믿음
        set ProtoEventIcon[235] = ProtoCharacterIconPath[359]
        // 함께 만든 검의 기억
        set ProtoEventIcon[236] = ProtoCharacterIconPath[360]
        // 공략 회의의 다른 속도
        set ProtoEventIcon[237] = ProtoCharacterIconPath[359]
        // 함께 싸울 때 보이는 것
        set ProtoEventIcon[238] = ProtoCharacterIconPath[358]
        // 호숫가에 놓인 일상
        set ProtoEventIcon[239] = ProtoCharacterIconPath[359]
        // 유이가 남긴 가족의 자리
        set ProtoEventIcon[240] = ProtoCharacterIconPath[413]
        // 75층에 남은 침묵
        set ProtoEventIcon[241] = ProtoCharacterIconPath[358]
        // 히스클리프의 다른 이름
        set ProtoEventIcon[242] = ProtoCharacterIconPath[358]
        // 아직 끝나지 않은 재회
        set ProtoEventIcon[243] = ProtoCharacterIconPath[359]
        // 새 공역으로 향한 갑판
        set ProtoEventIcon[258] = ProtoCharacterIconPath[448]
        // 폴카에서 다시 모인 얼굴
        set ProtoEventIcon[259] = ProtoCharacterIconPath[425]
        // 롤란의 손길이 닿는 마을
        set ProtoEventIcon[260] = ProtoCharacterIconPath[435]
        // 폭풍 속에서 남겨 둔 길
        set ProtoEventIcon[261] = ProtoCharacterIconPath[426]
        // 루리아가 없는 갑판
        set ProtoEventIcon[262] = ProtoCharacterIconPath[426]
        // 다시 손을 내민 안내인
        set ProtoEventIcon[263] = ProtoCharacterIconPath[435]
        // 목소리를 가리는 장치
        set ProtoEventIcon[264] = ProtoCharacterIconPath[448]
        // 시드홀름에서 찾는 열쇠
        set ProtoEventIcon[265] = ProtoCharacterIconPath[425]
        // 이드와 함께한 짧은 구출
        set ProtoEventIcon[266] = ProtoCharacterIconPath[472]
        // 롤란이 말하는 고향
        set ProtoEventIcon[267] = ProtoCharacterIconPath[435]
        // 도시에서 다시 부른 이름
        set ProtoEventIcon[268] = ProtoCharacterIconPath[448]
        // 탑을 향한 같은 뜻
        set ProtoEventIcon[269] = ProtoCharacterIconPath[472]
        // 다시 빈자리가 된 안내인
        set ProtoEventIcon[270] = ProtoCharacterIconPath[435]
        // 모두가 돌아온 하늘
        set ProtoEventIcon[271] = ProtoCharacterIconPath[448]
        // 얼굴이 지워진 수배서
        set ProtoEventIcon[281] = ProtoCharacterIconPath[496]
        // 길드로 이어진 첫 인사
        set ProtoEventIcon[302] = ProtoCharacterIconPath[504]
        // 처음 나누는 의뢰
        set ProtoEventIcon[303] = ProtoCharacterIconPath[503]
        // 문장보다 먼저 생긴 자리
        set ProtoEventIcon[304] = ProtoCharacterIconPath[513]
        // 그레이와 다른 방식
        set ProtoEventIcon[305] = ProtoCharacterIconPath[505]
        // 엘자가 지키는 규칙
        set ProtoEventIcon[306] = ProtoCharacterIconPath[506]
        // 돌아갈 길드의 의미
        set ProtoEventIcon[307] = ProtoCharacterIconPath[504]
        // 무너진 길드 건물
        set ProtoEventIcon[308] = ProtoCharacterIconPath[543]
        // 루시를 향한 요구
        set ProtoEventIcon[309] = ProtoCharacterIconPath[504]
        // 빼앗긴 사람의 목소리
        set ProtoEventIcon[310] = ProtoCharacterIconPath[503]
        // 다시 손을 잡는 순간
        set ProtoEventIcon[311] = ProtoCharacterIconPath[504]
        // 길드 앞에 선 거대한 위협
        set ProtoEventIcon[312] = ProtoCharacterIconPath[506]
        // 다른 자리에서 이어진 싸움
        set ProtoEventIcon[313] = ProtoCharacterIconPath[505]
        // 팬텀 로드의 끝
        set ProtoEventIcon[314] = ProtoCharacterIconPath[543]
        // 집으로 찾아간 자신의 대답
        set ProtoEventIcon[315] = ProtoCharacterIconPath[504]
        // 다시 부르는 동료의 이름
        set ProtoEventIcon[316] = ProtoCharacterIconPath[504]
        // 카라쿠라의 첫 만남
        set ProtoEventIcon[337] = ProtoCharacterIconPath[575]
        // 대행의 하루
        set ProtoEventIcon[338] = ProtoCharacterIconPath[571]
        // 친구들이 알게 된 세계
        set ProtoEventIcon[339] = ProtoCharacterIconPath[573]
        // 되돌아간 루키아
        set ProtoEventIcon[340] = ProtoCharacterIconPath[571]
        // 우라하라가 여는 준비
        set ProtoEventIcon[341] = ProtoCharacterIconPath[576]
        // 다른 세계의 문턱
        set ProtoEventIcon[342] = ProtoCharacterIconPath[574]
        // 길에서 만난 협력자
        set ProtoEventIcon[343] = ProtoCharacterIconPath[613]
        // 렌지가 놓지 못한 이름
        set ProtoEventIcon[344] = ProtoCharacterIconPath[616]
        // 켄파치가 막아선 길
        set ProtoEventIcon[345] = ProtoCharacterIconPath[571]
        // 갇힌 사람이 남긴 마음
        set ProtoEventIcon[346] = ProtoCharacterIconPath[575]
        // 요루이치와 기다리는 시간
        set ProtoEventIcon[347] = ProtoCharacterIconPath[574]
        // 처형대에서 부른 이름
        set ProtoEventIcon[348] = ProtoCharacterIconPath[571]
        // 뱌쿠야가 지키던 약속
        set ProtoEventIcon[349] = ProtoCharacterIconPath[631]
        // 아이젠이 드러낸 목적
        set ProtoEventIcon[350] = ProtoCharacterIconPath[571]
        // 루키아가 고르는 자리
        set ProtoEventIcon[351] = ProtoCharacterIconPath[575]
        // 마을에 돌아온 대행
        set ProtoEventIcon[352] = ProtoCharacterIconPath[571]
        // 끝나지 않는 지폐
        set ProtoEventIcon[362] = ProtoCharacterIconPath[645]
        // 잔보다 늦게 온 주문
        set ProtoEventIcon[366] = ProtoCharacterIconPath[650]
        // 카우보이를 담는 배경
        set ProtoEventIcon[370] = ProtoCharacterIconPath[659]
        // 초대장이 가리키는 꿈
        set ProtoEventIcon[376] = ProtoCharacterIconPath[643]
        // 황금의 순간의 안내인
        set ProtoEventIcon[377] = ProtoCharacterIconPath[643]
        // 반디와 나란히 걷는 거리
        set ProtoEventIcon[378] = ProtoCharacterIconPath[661]
        // 도시를 내려다보는 약속
        set ProtoEventIcon[379] = ProtoCharacterIconPath[661]
        // 블랙 스완이 펼친 기억
        set ProtoEventIcon[381] = ProtoCharacterIconPath[648]
        // 어벤츄린이 건넨 제안
        set ProtoEventIcon[382] = ProtoCharacterIconPath[645]
        // 스파클의 가면을 마주하다
        set ProtoEventIcon[383] = ProtoCharacterIconPath[647]
        // 미샤에게 이어진 개척의 기억
        set ProtoEventIcon[386] = ProtoCharacterIconPath[643]
        // 선데이의 영원한 안락에 답하다
        set ProtoEventIcon[388] = ProtoCharacterIconPath[706]
        // 두 형제가 떠나는 이유
        set ProtoEventIcon[409] = ProtoCharacterIconPath[719]
        // 기적이라는 이름의 빈틈
        set ProtoEventIcon[410] = ProtoCharacterIconPath[718]
        // 니나를 부르는 목소리
        set ProtoEventIcon[411] = ProtoCharacterIconPath[719]
        // 돌아갈 작업장의 불빛
        set ProtoEventIcon[412] = ProtoCharacterIconPath[717]
        // 현자의 돌 뒤의 사람들
        set ProtoEventIcon[413] = ProtoCharacterIconPath[718]
        // 기억이 흔들리는 갑옷
        set ProtoEventIcon[414] = ProtoCharacterIconPath[719]
        // 스승이 기억하는 배움
        set ProtoEventIcon[415] = ProtoCharacterIconPath[723]
        // 그리드가 묻는 동료
        set ProtoEventIcon[416] = ProtoCharacterIconPath[761]
        // 돌아오지 않은 휴즈
        set ProtoEventIcon[417] = ProtoCharacterIconPath[725]
        // 거짓 결론 뒤의 진실
        set ProtoEventIcon[418] = ProtoCharacterIconPath[718]
        // 윈리가 멈춘 손
        set ProtoEventIcon[419] = ProtoCharacterIconPath[717]
        // 호엔하임이 남긴 시간
        set ProtoEventIcon[420] = ProtoCharacterIconPath[773]
        // 나라에 그어진 원
        set ProtoEventIcon[421] = ProtoCharacterIconPath[719]
        // 약속의 날을 기다리는 사람들
        set ProtoEventIcon[422] = ProtoCharacterIconPath[725]
        // 되돌아온 사람들의 삶
        set ProtoEventIcon[423] = ProtoCharacterIconPath[773]
        // 갑옷이 건넨 마지막 도움
        set ProtoEventIcon[424] = ProtoCharacterIconPath[719]
        // 힘 대신 남겨 둘 관계
        set ProtoEventIcon[425] = ProtoCharacterIconPath[718]
        // 몸을 되찾은 다음의 길
        set ProtoEventIcon[426] = ProtoCharacterIconPath[719]
        // 큰 표주박을 고른 손
        set ProtoEventIcon[440] = ProtoCharacterIconPath[795]
        // 아직 끝나지 않은 인사
        set ProtoEventIcon[441] = ProtoCharacterIconPath[795]
        // 가림막 뒤의 네 차례
        set ProtoEventIcon[443] = ProtoCharacterIconPath[799]
        // 터진 소리 다음에는
        set ProtoEventIcon[444] = ProtoCharacterIconPath[795]
        // 나비저택에 도착한 사람들
        set ProtoEventIcon[445] = ProtoCharacterIconPath[794]
        // 시노부가 바라보는 회복
        set ProtoEventIcon[446] = ProtoCharacterIconPath[797]
        // 함께 서툰 수련
        set ProtoEventIcon[447] = ProtoCharacterIconPath[798]
        // 카나오의 조용한 대답
        set ProtoEventIcon[448] = ProtoCharacterIconPath[796]
        // 밤에도 이어지는 호흡
        set ProtoEventIcon[449] = ProtoCharacterIconPath[795]
        // 출발 전에 남긴 인사
        set ProtoEventIcon[450] = ProtoCharacterIconPath[794]
        // 열차에서 만난 큰 목소리
        set ProtoEventIcon[451] = ProtoCharacterIconPath[833]
        // 꿈에 놓인 집의 풍경
        set ProtoEventIcon[452] = ProtoCharacterIconPath[795]
        // 깨어날 때 붙잡는 이름
        set ProtoEventIcon[453] = ProtoCharacterIconPath[808]
        // 객차마다 이어진 준비
        set ProtoEventIcon[454] = ProtoCharacterIconPath[799]
        // 열차의 위협을 넘긴 뒤
        set ProtoEventIcon[455] = ProtoCharacterIconPath[833]
        // 아카자가 묻는 강함
        set ProtoEventIcon[456] = ProtoCharacterIconPath[833]
        // 남겨진 마지막 말
        set ProtoEventIcon[457] = ProtoCharacterIconPath[795]
        // 다시 걷는 사람들의 호흡
        set ProtoEventIcon[458] = ProtoCharacterIconPath[795]
        // 옷에 묶인 다른 이름
        set ProtoEventIcon[467] = ProtoCharacterIconPath[867]
        // 같은 길의 다른 시각
        set ProtoEventIcon[468] = ProtoCharacterIconPath[868]
        // 낯선 길에서 받은 인사
        set ProtoEventIcon[472] = ProtoCharacterIconPath[857]
        // 배고픈 사람의 큰 웃음
        set ProtoEventIcon[473] = ProtoCharacterIconPath[858]
        // 캐르가 머무는 거리
        set ProtoEventIcon[474] = ProtoCharacterIconPath[888]
        // 길드 이름에 모인 사람들
        set ProtoEventIcon[475] = ProtoCharacterIconPath[857]
        // 처음 남기는 집의 기억
        set ProtoEventIcon[476] = ProtoCharacterIconPath[894]
        // 다른 길드와 나눈 식사
        set ProtoEventIcon[477] = ProtoCharacterIconPath[858]
        // 캐르가 말하지 못한 일
        set ProtoEventIcon[478] = ProtoCharacterIconPath[888]
        // 기억의 빈칸이 부르는 길
        set ProtoEventIcon[479] = ProtoCharacterIconPath[894]
        // 페코린느가 밝히는 이름
        set ProtoEventIcon[480] = ProtoCharacterIconPath[858]
        // 무너지는 익숙한 풍경
        set ProtoEventIcon[481] = ProtoCharacterIconPath[857]
        // 기다리는 사람과 묶인 마음
        set ProtoEventIcon[482] = ProtoCharacterIconPath[888]
        // 네 사람의 뜻이 다시 모이다
        set ProtoEventIcon[483] = ProtoCharacterIconPath[894]
        // 카이저 앞에 남긴 약속
        set ProtoEventIcon[484] = ProtoCharacterIconPath[858]
        // 빈자리 없이 차린 식탁
        set ProtoEventIcon[485] = ProtoCharacterIconPath[888]

        // 여러 인물이나 상황이 있는 사건은 대조한 장면·자체 제작 표지를 사용한다.
        // 학교에 남은 마법진
        set ProtoEventIcon[53] = "war3mapImported\\UI_Event_FES2_school_magic.tga"
        // 서로 다른 마력의 흔적
        set ProtoEventIcon[54] = "war3mapImported\\UI_Event_FES2_mana_trace.tga"
        // 같은 검, 다른 빈틈
        set ProtoEventIcon[55] = "war3mapImported\\UI_Event_FES2_saber_training.tga"
        // 산문을 지키는 검술가
        set ProtoEventIcon[56] = "war3mapImported\\UI_Event_FES2_temple_assassin.tga"
        // 누구의 협력인지
        set ProtoEventIcon[59] = "war3mapImported\\UI_Event_FES2_shinji_offer.tga"
        // 검 없이 둘러볼 자리
        set ProtoEventIcon[60] = "war3mapImported\\UI_Event_FES2_town_outing.tga"
        // 목격담의 빈칸
        set ProtoEventIcon[61] = "war3mapImported\\UI_Event_FES2_issei_testimony.tga"
        // 같은 싸움을 보는 다른 눈
        set ProtoEventIcon[62] = "war3mapImported\\UI_Event_FES2_different_ideals.tga"
        // 창이 가리키지 않은 쪽
        set ProtoEventIcon[63] = "war3mapImported\\UI_Event_FES2_lancer_spacing.tga"
        // 보호한다는 말의 범위
        set ProtoEventIcon[66] = "war3mapImported\\UI_Event_FES2_church_protection.tga"
        // 한 번 막은 뒤의 발자리
        set ProtoEventIcon[67] = "war3mapImported\\UI_Event_FES2_archer_lancer.tga"
        // 아비도스 방문
        set ProtoEventIcon[9] = "war3mapImported\\UI_Event_AAS3_abydos_classroom.tga"
        // 아비도스 방문
        set ProtoEventIcon[10] = "war3mapImported\\UI_Event_AAS3_abydos_classroom.tga"
        // 아비도스 방문
        set ProtoEventIcon[11] = "war3mapImported\\UI_Event_AAS3_abydos_classroom.tga"
        // 아비도스 방문
        set ProtoEventIcon[12] = "war3mapImported\\UI_Event_AAS3_abydos_classroom.tga"
        // 모래에 묻힌 보급로
        set ProtoEventIcon[115] = "war3mapImported\\UI_Event_AAS3_supply_map.tga"
        // 블랙마켓의 잘못된 지도
        set ProtoEventIcon[117] = "war3mapImported\\UI_Event_AAS3_black_market.tga"
        // 남아 있는 라멘 가게의 간판
        set ProtoEventIcon[118] = "war3mapImported\\UI_Event_AAS3_ramen_recovery.tga"
        // 카이저 소유의 사막
        set ProtoEventIcon[119] = "war3mapImported\\UI_Event_AAS3_desert_scouting.tga"
        // 호시노의 빈 자리
        set ProtoEventIcon[120] = "war3mapImported\\UI_Event_AAS3_hoshino_letter.tga"
        // 잠든 자리와 비워 둘 앞자리
        set ProtoEventIcon[122] = "war3mapImported\\UI_Event_AAS3_hoshino_rest.tga"
        // 안내판 앞의 다음 발걸음
        set ProtoEventIcon[125] = "war3mapImported\\UI_Event_AAS3_aquarium_outing.tga"
        // 페로로 앞에서 듣는 부탁
        set ProtoEventIcon[126] = "war3mapImported\\UI_Event_AAS3_hifumi_peroro.tga"
        // 악당답게 계산할게
        set ProtoEventIcon[127] = "war3mapImported\\UI_Event_AAS3_aru_bill.tga"
        // 웃는 쪽은 두 봉투
        set ProtoEventIcon[130] = "war3mapImported\\UI_Event_AAS3_mutsuki_tease.tga"
        // 사장님 다음에는
        set ProtoEventIcon[131] = "war3mapImported\\UI_Event_AAS3_problem_solver.tga"
        // 여정 뒤에 다시 펼친 기억
        set ProtoEventIcon[147] = "war3mapImported\\UI_Event_AAS3_abydos_memories.tga"
        // 아인크라드 방문
        set ProtoEventIcon[21] = "war3mapImported\\UI_Event_AAS3_town_of_beginnings.tga"
        // 아인크라드 방문
        set ProtoEventIcon[22] = "war3mapImported\\UI_Event_AAS3_town_of_beginnings.tga"
        // 아인크라드 방문
        set ProtoEventIcon[23] = "war3mapImported\\UI_Event_AAS3_town_of_beginnings.tga"
        // 아인크라드 방문
        set ProtoEventIcon[24] = "war3mapImported\\UI_Event_AAS3_town_of_beginnings.tga"
        // 부러진 시험검
        set ProtoEventIcon[212] = "war3mapImported\\UI_Event_AAS3_liz_workshop.tga"
        // 공방으로 돌아온 재료
        set ProtoEventIcon[213] = "war3mapImported\\UI_Event_AAS3_workshop_friends.tga"
        // 작은 동료를 되찾으러
        set ProtoEventIcon[214] = "war3mapImported\\UI_Event_AAS3_silica_search.tga"
        // 요리할 수 없는 희귀 고기
        set ProtoEventIcon[215] = "war3mapImported\\UI_Event_AAS3_ragout_rabbit.tga"
        // 되돌아온 정찰대
        set ProtoEventIcon[216] = "war3mapImported\\UI_Event_AAS3_boss_scouting.tga"
        // 안전 구역의 모순
        set ProtoEventIcon[217] = "war3mapImported\\UI_Event_AAS3_safe_zone_mystery.tga"
        // 중층에서 꺼내 놓은 등불
        set ProtoEventIcon[220] = "war3mapImported\\UI_Event_AAS3_sachi_waiting.tga"
        // 호숫가에서 기다릴 사람 · 두 번째 매듭을 묶기 전에
        set ProtoEventIcon[221] = "war3mapImported\\UI_Event_AAS3_nishida_fishing.tga"
        // 호숫가에서 기다릴 사람 · 두 번째 매듭을 묶기 전에
        set ProtoEventIcon[228] = "war3mapImported\\UI_Event_AAS3_nishida_fishing.tga"
        // 부단장이 남긴 두 갈래 지시
        set ProtoEventIcon[222] = "war3mapImported\\UI_Event_AAS3_asuna_instructions.tga"
        // 이름 다음의 질문
        set ProtoEventIcon[225] = "war3mapImported\\UI_Event_AAS3_yui_questions.tga"
        // 둘이서도 혼자 걷는 사람
        set ProtoEventIcon[226] = "war3mapImported\\UI_Event_AAS3_first_party.tga"
        // 여정 뒤에 다시 펼친 기억
        set ProtoEventIcon[244] = "war3mapImported\\UI_Event_AAS3_aincrad_memories.tga"
        // 액셀 방문
        set ProtoEventIcon[5] = "war3mapImported\\UI_Event_KAS4_axel_party.tga"
        // 액셀 방문
        set ProtoEventIcon[6] = "war3mapImported\\UI_Event_KAS4_axel_party.tga"
        // 액셀 방문
        set ProtoEventIcon[7] = "war3mapImported\\UI_Event_KAS4_axel_party.tga"
        // 액셀 방문
        set ProtoEventIcon[8] = "war3mapImported\\UI_Event_KAS4_axel_party.tga"
        // 게시판의 밀린 의뢰
        set ProtoEventIcon[86] = "war3mapImported\\UI_Event_KAS4_quest_board.tga"
        // 폭렬 마법의 연습 장소
        set ProtoEventIcon[88] = "war3mapImported\\UI_Event_KAS4_explosion_practice.tga"
        // 팔릴 때마다 적자인 가게
        set ProtoEventIcon[89] = "war3mapImported\\UI_Event_KAS4_wiz_shop.tga"
        // 단단한 갑옷을 향한 돌진
        set ProtoEventIcon[91] = "war3mapImported\\UI_Event_KAS4_darkness_charge.tga"
        // 박수 뒤에 남은 물자리
        set ProtoEventIcon[92] = "war3mapImported\\UI_Event_KAS4_aqua_performance.tga"
        // 검의 이름보다 먼저 할 말
        set ProtoEventIcon[95] = "war3mapImported\\UI_Event_KAS4_mitsurugi_intro.tga"
        // 처음 온 사람의 두 번째 질문
        set ProtoEventIcon[96] = "war3mapImported\\UI_Event_KAS4_luna_counter.tga"
        // 버린 것이 아니라 줄을 잡은 것
        set ProtoEventIcon[97] = "war3mapImported\\UI_Event_KAS4_aqua_lake_cage.tga"
        // 작은 발자국이 멀어질 때
        set ProtoEventIcon[98] = "war3mapImported\\UI_Event_KAS4_snow_sprites.tga"
        // 질문이 끝나기 전에
        set ProtoEventIcon[99] = "war3mapImported\\UI_Event_KAS4_aqua_wiz_interrupt.tga"
        // 의뢰를 받은 문은 어디지?
        set ProtoEventIcon[100] = "war3mapImported\\UI_Event_KAS4_haunted_house_guide.tga"
        // 끌어올린 뒤에도 잡힌 줄
        set ProtoEventIcon[101] = "war3mapImported\\UI_Event_KAS4_aqua_after_lake.tga"
        // 여정 뒤에 다시 펼친 기억
        set ProtoEventIcon[114] = "war3mapImported\\UI_Event_KAS4_axel_memories.tga"
        // 미타키하라 방문
        set ProtoEventIcon[17] = "war3mapImported\\UI_Event_MHS5_mitakihara_school.tga"
        // 미타키하라 방문
        set ProtoEventIcon[18] = "war3mapImported\\UI_Event_MHS5_mitakihara_school.tga"
        // 미타키하라 방문
        set ProtoEventIcon[19] = "war3mapImported\\UI_Event_MHS5_mitakihara_school.tga"
        // 미타키하라 방문
        set ProtoEventIcon[20] = "war3mapImported\\UI_Event_MHS5_mitakihara_school.tga"
        // 돌아온 안내자
        set ProtoEventIcon[185] = "war3mapImported\\UI_Event_MHS5_mami_guide.tga"
        // 놓친 사역마의 흔적
        set ProtoEventIcon[186] = "war3mapImported\\UI_Event_MHS5_kyoko_conflict.tga"
        // 버려진 교회에서
        set ProtoEventIcon[187] = "war3mapImported\\UI_Event_MHS5_abandoned_church.tga"
        // 한 가지 소원
        set ProtoEventIcon[188] = "war3mapImported\\UI_Event_MHS5_kyubey_wish.tga"
        // 쌓인 준비의 빈틈
        set ProtoEventIcon[189] = "war3mapImported\\UI_Event_MHS5_homura_preparation.tga"
        // 문병 가방에 남은 제목
        set ProtoEventIcon[190] = "war3mapImported\\UI_Event_MHS5_hospital_music.tga"
        // 건너기 전에 달라진 입구
        set ProtoEventIcon[195] = "war3mapImported\\UI_Event_MHS5_witch_boundary.tga"
        // 한 걸음 뒤에서 들을 말
        set ProtoEventIcon[196] = "war3mapImported\\UI_Event_MHS5_mami_spacing.tga"
        // 여정 뒤에 다시 펼친 기억
        set ProtoEventIcon[211] = "war3mapImported\\UI_Event_MHS5_mitakihara_memories.tga"
        // 학원도시 방문
        set ProtoEventIcon[13] = "war3mapImported\\UI_Event_AGR6_academy_friends.tga"
        // 학원도시 방문
        set ProtoEventIcon[14] = "war3mapImported\\UI_Event_AGR6_academy_friends.tga"
        // 학원도시 방문
        set ProtoEventIcon[15] = "war3mapImported\\UI_Event_AGR6_academy_friends.tga"
        // 학원도시 방문
        set ProtoEventIcon[16] = "war3mapImported\\UI_Event_AGR6_academy_friends.tga"
        // 끊어진 구조 신호
        set ProtoEventIcon[148] = "war3mapImported\\UI_Event_AGR6_signal_backup.tga"
        // 신호가 가리킨 장소
        set ProtoEventIcon[149] = "war3mapImported\\UI_Event_AGR6_rescue_coordinates.tga"
        // 소문이 앞선 조사
        set ProtoEventIcon[150] = "war3mapImported\\UI_Event_AGR6_rumor_investigation.tga"
        // 표적 뒤의 빈 공간
        set ProtoEventIcon[151] = "war3mapImported\\UI_Event_AGR6_railgun_coin.tga"
        // 능력 없이 남은 사람
        set ProtoEventIcon[152] = "war3mapImported\\UI_Event_AGR6_saten_conversation.tga"
        // 복구된 두 번째 통로
        set ProtoEventIcon[153] = "war3mapImported\\UI_Event_AGR6_kuroko_route.tga"
        // 단것 옆에 남은 주문 한 줄
        set ProtoEventIcon[155] = "war3mapImported\\UI_Event_AGR6_snack_orders.tga"
        // 둘이 묶기 전에 맞출 보폭
        set ProtoEventIcon[156] = "war3mapImported\\UI_Event_AGR6_festival_stride.tga"
        // 큰 소리보다 먼저 옮길 짐
        set ProtoEventIcon[158] = "war3mapImported\\UI_Event_AGR6_gunha_touma.tga"
        // 한 번 더 넣기 전에
        set ProtoEventIcon[160] = "war3mapImported\\UI_Event_AGR6_vending_coin.tga"
        // 한 입 남기고 울린 호출
        set ProtoEventIcon[161] = "war3mapImported\\UI_Event_AGR6_tea_interrupted.tga"
        // 출발보다 먼저 할 대답
        set ProtoEventIcon[162] = "war3mapImported\\UI_Event_AGR6_answer_before_departure.tga"
        // 아직 뜯지 않은 한 잔
        set ProtoEventIcon[165] = "war3mapImported\\UI_Event_AGR6_drink_after_vending.tga"
        // 확인한 뒤에도 남은 몫
        set ProtoEventIcon[166] = "war3mapImported\\UI_Event_AGR6_next_shift.tga"
        // 접지 않은 항목의 답
        set ProtoEventIcon[167] = "war3mapImported\\UI_Event_AGR6_unsealed_list.tga"
        // 여정 뒤에 다시 펼친 기억
        set ProtoEventIcon[183] = "war3mapImported\\UI_Event_AGR6_academy_memories.tga"
        // 제가 그랑데 공역 방문
        set ProtoEventIcon[25] = "war3mapImported\\UI_Event_AGR6_zegagrande_arrival.tga"
        // 제가 그랑데 공역 방문
        set ProtoEventIcon[26] = "war3mapImported\\UI_Event_AGR6_zegagrande_arrival.tga"
        // 제가 그랑데 공역 방문
        set ProtoEventIcon[27] = "war3mapImported\\UI_Event_AGR6_zegagrande_arrival.tga"
        // 제가 그랑데 공역 방문
        set ProtoEventIcon[28] = "war3mapImported\\UI_Event_AGR6_zegagrande_arrival.tga"
        // 묶이지 않은 화물
        set ProtoEventIcon[245] = "war3mapImported\\UI_Event_AGR6_grandcypher_cargo.tga"
        // 확보한 갑판의 자리
        set ProtoEventIcon[246] = "war3mapImported\\UI_Event_AGR6_katalina_guard.tga"
        // 흐트러진 집중
        set ProtoEventIcon[247] = "war3mapImported\\UI_Event_AGR6_io_concentration.tga"
        // 돌아올 자리의 신호
        set ProtoEventIcon[250] = "war3mapImported\\UI_Event_AGR6_rackam_return_signal.tga"
        // 같은 길에 다른 날짜
        set ProtoEventIcon[251] = "war3mapImported\\UI_Event_AGR6_rosetta_route.tga"
        // 다른 쪽을 보고 있던 관객
        set ProtoEventIcon[256] = "war3mapImported\\UI_Event_AGR6_io_demonstration.tga"
        // 여정 뒤에 다시 펼친 기억
        set ProtoEventIcon[272] = "war3mapImported\\UI_Event_AGR6_grandcypher_memories.tga"
        // 나비저택 방문
        set ProtoEventIcon[45] = "war3mapImported\\UI_Event_BGA7_butterfly_arrival.tga"
        // 나비저택 방문
        set ProtoEventIcon[46] = "war3mapImported\\UI_Event_BGA7_butterfly_arrival.tga"
        // 나비저택 방문
        set ProtoEventIcon[47] = "war3mapImported\\UI_Event_BGA7_butterfly_arrival.tga"
        // 나비저택 방문
        set ProtoEventIcon[48] = "war3mapImported\\UI_Event_BGA7_butterfly_arrival.tga"
        // 울음 사이로 섞인 발소리
        set ProtoEventIcon[428] = "war3mapImported\\UI_Event_BGA7_lost_supply_route.tga"
        // 찾은 흔적의 건너편
        set ProtoEventIcon[429] = "war3mapImported\\UI_Event_BGA7_recovery_stride.tga"
        // 잘못 짚은 소리의 값
        set ProtoEventIcon[430] = "war3mapImported\\UI_Event_BGA7_shinobu_recovery.tga"
        // 지워진 병의 이름
        set ProtoEventIcon[431] = "war3mapImported\\UI_Event_BGA7_aoi_labels.tga"
        // 너무 많은 소리가 나는 낮
        set ProtoEventIcon[434] = "war3mapImported\\UI_Event_BGA7_zenitsu_overwhelmed.tga"
        // 같은 자리에 남은 다른 냄새
        set ProtoEventIcon[435] = "war3mapImported\\UI_Event_BGA7_tanjiro_forest_route.tga"
        // 선배라면 더 강한가
        set ProtoEventIcon[437] = "war3mapImported\\UI_Event_BGA7_murata_return.tga"
        // 문 안에 먼저 들어갈 사람
        set ProtoEventIcon[438] = "war3mapImported\\UI_Event_BGA7_training_door.tga"
        // 물러선 발과 움직이지 않은 손
        set ProtoEventIcon[439] = "war3mapImported\\UI_Event_BGA7_nezuko_rest.tga"
        // 거두지 못한 마지막 손
        set ProtoEventIcon[442] = "war3mapImported\\UI_Event_BGA7_kanao_pause.tga"
        // 여정 뒤에 다시 펼친 기억
        set ProtoEventIcon[459] = "war3mapImported\\UI_Event_BGA7_butterfly_memories.tga"
        // 미식전 길드 하우스 방문
        set ProtoEventIcon[49] = "war3mapImported\\UI_Event_BGA7_gourmet_table.tga"
        // 미식전 길드 하우스 방문
        set ProtoEventIcon[50] = "war3mapImported\\UI_Event_BGA7_gourmet_table.tga"
        // 미식전 길드 하우스 방문
        set ProtoEventIcon[51] = "war3mapImported\\UI_Event_BGA7_gourmet_table.tga"
        // 미식전 길드 하우스 방문
        set ProtoEventIcon[52] = "war3mapImported\\UI_Event_BGA7_gourmet_table.tga"
        // 냄비를 올리기 전에
        set ProtoEventIcon[460] = "war3mapImported\\UI_Event_BGA7_roadside_cooking.tga"
        // 빈 그릇과 늘어난 몫
        set ProtoEventIcon[461] = "war3mapImported\\UI_Event_BGA7_meal_requests.tga"
        // 남겨 둔 한 끼
        set ProtoEventIcon[462] = "war3mapImported\\UI_Event_BGA7_reserved_riceball.tga"
        // 먼지 뒤에 남은 방
        set ProtoEventIcon[463] = "war3mapImported\\UI_Event_BGA7_guildhouse_cleanup.tga"
        // 색이 번진 향신료 지도
        set ProtoEventIcon[464] = "war3mapImported\\UI_Event_BGA7_kokkoro_supplies.tga"
        // 접힌 채 남은 초대장
        set ProtoEventIcon[465] = "war3mapImported\\UI_Event_BGA7_aoi_invitation.tga"
        // 갈라지는 배달길
        set ProtoEventIcon[470] = "war3mapImported\\UI_Event_BGA7_delivery_bags.tga"
        // 여정 뒤에 다시 펼친 기억
        set ProtoEventIcon[486] = "war3mapImported\\UI_Event_BGA7_gourmet_memories.tga"
        // 아메스트리스 방문
        set ProtoEventIcon[41] = "war3mapImported\\UI_Event_BGA7_amestris_brothers.tga"
        // 아메스트리스 방문
        set ProtoEventIcon[42] = "war3mapImported\\UI_Event_BGA7_amestris_brothers.tga"
        // 아메스트리스 방문
        set ProtoEventIcon[43] = "war3mapImported\\UI_Event_BGA7_amestris_brothers.tga"
        // 아메스트리스 방문
        set ProtoEventIcon[44] = "war3mapImported\\UI_Event_BGA7_amestris_brothers.tga"
        // 떠나려는 손, 붙잡는 손
        set ProtoEventIcon[393] = "war3mapImported\\UI_Event_BGA7_winry_automail.tga"
        // 빈칸이 남은 정비 기록 · 사라진 페이지의 무게 · 한 권 뒤에 남겨 둔 빈칸
        set ProtoEventIcon[394] = "war3mapImported\\UI_Event_BGA7_sheska_books.tga"
        // 빈칸이 남은 정비 기록 · 사라진 페이지의 무게 · 한 권 뒤에 남겨 둔 빈칸
        set ProtoEventIcon[396] = "war3mapImported\\UI_Event_BGA7_sheska_books.tga"
        // 빈칸이 남은 정비 기록 · 사라진 페이지의 무게 · 한 권 뒤에 남겨 둔 빈칸
        set ProtoEventIcon[407] = "war3mapImported\\UI_Event_BGA7_sheska_books.tga"
        // 손을 모으기 전에
        set ProtoEventIcon[397] = "war3mapImported\\UI_Event_BGA7_island_training.tga"
        // 사진 아래 놓인 보고서
        set ProtoEventIcon[401] = "war3mapImported\\UI_Event_BGA7_hughes_report.tga"
        // 떠날 몫과 남겨 둘 몫
        set ProtoEventIcon[402] = "war3mapImported\\UI_Event_BGA7_winry_return_supplies.tga"
        // 큰 손이 멈추는 무게
        set ProtoEventIcon[403] = "war3mapImported\\UI_Event_BGA7_sig_transport.tga"
        // 빈 접시와 남은 계산
        set ProtoEventIcon[404] = "war3mapImported\\UI_Event_BGA7_ling_after_meal.tga"
        // 불씨를 내기 전의 목록
        set ProtoEventIcon[405] = "war3mapImported\\UI_Event_BGA7_roy_hawkeye_preparation.tga"
        // 여정 뒤에 다시 펼친 기억
        set ProtoEventIcon[427] = "war3mapImported\\UI_Event_BGA7_resemblool_return.tga"
        // 마그놀리아 방문
        set ProtoEventIcon[29] = "war3mapImported\\UI_Event_FBP8_magnolia_companions.tga"
        // 마그놀리아 방문
        set ProtoEventIcon[30] = "war3mapImported\\UI_Event_FBP8_magnolia_companions.tga"
        // 마그놀리아 방문
        set ProtoEventIcon[31] = "war3mapImported\\UI_Event_FBP8_magnolia_companions.tga"
        // 마그놀리아 방문
        set ProtoEventIcon[32] = "war3mapImported\\UI_Event_FBP8_magnolia_companions.tga"
        // 무너진 게시판 아래 · 짐을 기다리는 사람들
        set ProtoEventIcon[286] = "war3mapImported\\UI_Event_FBP8_guild_preparations.tga"
        // 무너진 게시판 아래 · 짐을 기다리는 사람들
        set ProtoEventIcon[287] = "war3mapImported\\UI_Event_FBP8_guild_preparations.tga"
        // 주소가 다른 두 장의 의뢰서
        set ProtoEventIcon[288] = "war3mapImported\\UI_Event_FBP8_lucy_erza_requests.tga"
        // 생선보다 먼저 챙길 짐
        set ProtoEventIcon[289] = "war3mapImported\\UI_Event_FBP8_carla_transport.tga"
        // 기록을 익힌 손이 다시 찾은 게시판
        set ProtoEventIcon[290] = "war3mapImported\\UI_Event_FBP8_lucy_returning_work.tga"
        // 짐칸에 들어가지 않는 갑옷
        set ProtoEventIcon[291] = "war3mapImported\\UI_Event_FBP8_erza_equipment.tga"
        // 불어난 물과 젖은 의뢰서
        set ProtoEventIcon[292] = "war3mapImported\\UI_Event_FBP8_gray_river_plan.tga"
        // 번진 글씨를 읽는 방법
        set ProtoEventIcon[293] = "war3mapImported\\UI_Event_FBP8_lucy_unreadable_note.tga"
        // 잘못 태우면 안 되는 것
        set ProtoEventIcon[294] = "war3mapImported\\UI_Event_FBP8_natsu_attack_spacing.tga"
        // 한 사람에게 모인 두 우산
        set ProtoEventIcon[296] = "war3mapImported\\UI_Event_FBP8_juvia_shared_table.tga"
        // 의뢰보다 먼저 내민 잡지 · 먼저 목적을 묻던 손님의 다음 방문
        set ProtoEventIcon[297] = "war3mapImported\\UI_Event_FBP8_mirajane_guests.tga"
        // 의뢰보다 먼저 내민 잡지 · 먼저 목적을 묻던 손님의 다음 방문
        set ProtoEventIcon[301] = "war3mapImported\\UI_Event_FBP8_mirajane_guests.tga"
        // 돌아오라는 말이 빠진 답
        set ProtoEventIcon[298] = "war3mapImported\\UI_Event_FBP8_laxus_unfinished_reply.tga"
        // 결말에 도착하지 못한 독자
        set ProtoEventIcon[300] = "war3mapImported\\UI_Event_FBP8_lucy_next_line.tga"
        // 여정 뒤에 다시 펼친 기억
        set ProtoEventIcon[317] = "war3mapImported\\UI_Event_FBP8_guild_journey_memory.tga"
        // 페나코니 방문
        set ProtoEventIcon[37] = "war3mapImported\\UI_Event_FBP8_golden_hour_arrival.tga"
        // 페나코니 방문
        set ProtoEventIcon[38] = "war3mapImported\\UI_Event_FBP8_golden_hour_arrival.tga"
        // 페나코니 방문
        set ProtoEventIcon[39] = "war3mapImported\\UI_Event_FBP8_golden_hour_arrival.tga"
        // 페나코니 방문
        set ProtoEventIcon[40] = "war3mapImported\\UI_Event_FBP8_golden_hour_arrival.tga"
        // 계속 움직이는 목적지
        set ProtoEventIcon[361] = "war3mapImported\\UI_Event_FBP8_golden_hour_destination.tga"
        // 손이 닿기 전에 뜨는 간식
        set ProtoEventIcon[363] = "war3mapImported\\UI_Event_FBP8_golden_hour_snack.tga"
        // 연결된 그림과 끊어진 길
        set ProtoEventIcon[364] = "war3mapImported\\UI_Event_FBP8_dreams_eye_connection.tga"
        // 서로 다른 얼굴의 안내인 · 박수가 끝났는데 남은 역
        set ProtoEventIcon[359] = "war3mapImported\\UI_Event_FBP8_sparkle_changing_role.tga"
        // 서로 다른 얼굴의 안내인 · 박수가 끝났는데 남은 역
        set ProtoEventIcon[365] = "war3mapImported\\UI_Event_FBP8_sparkle_changing_role.tga"
        // 코인 자루가 떠난 자리 · 귀환 표시 다음의 여백
        set ProtoEventIcon[357] = "war3mapImported\\UI_Event_FBP8_misha_return_supplies.tga"
        // 코인 자루가 떠난 자리 · 귀환 표시 다음의 여백
        set ProtoEventIcon[374] = "war3mapImported\\UI_Event_FBP8_misha_return_supplies.tga"
        // 맞지 않은 그림의 기억 · 안전한 꿈이라는 말의 균열
        set ProtoEventIcon[356] = "war3mapImported\\UI_Event_FBP8_black_swan_uncertain_memory.tga"
        // 맞지 않은 그림의 기억 · 안전한 꿈이라는 말의 균열
        set ProtoEventIcon[380] = "war3mapImported\\UI_Event_FBP8_black_swan_uncertain_memory.tga"
        // 가격표 밖의 조건
        set ProtoEventIcon[367] = "war3mapImported\\UI_Event_FBP8_jade_exchange_terms.tga"
        // 벽에 적힌 전화번호
        set ProtoEventIcon[273] = "war3mapImported\\UI_Event_CGP9_yato_five_yen.tga"
        // 시험철의 신사 심부름
        set ProtoEventIcon[274] = "war3mapImported\\UI_Event_CGP9_tenjin_shrine.tga"
        // 연락이 닿지 않는 의뢰인
        set ProtoEventIcon[275] = "war3mapImported\\UI_Event_CGP9_yato_hiyori_route.tga"
        // 저울 앞의 모피
        set ProtoEventIcon[276] = "war3mapImported\\UI_Event_CGP9_holo_cart_goods.tga"
        // 다른 구매자의 장부
        set ProtoEventIcon[277] = "war3mapImported\\UI_Event_CGP9_lawrence_trade_compare.tga"
        // 수익 뒤의 영수증
        set ProtoEventIcon[278] = "war3mapImported\\UI_Event_CGP9_holo_written_terms.tga"
        // 비 맞은 화물 덮개
        set ProtoEventIcon[279] = "war3mapImported\\UI_Event_CGP9_cart_delivery_condition.tga"
        // 북쪽으로 가는 마차
        set ProtoEventIcon[280] = "war3mapImported\\UI_Event_CGP9_northward_wagon.tga"
        // 빗물보다 먼저 거둘 것
        set ProtoEventIcon[466] = "war3mapImported\\UI_Event_CGP9_pecorine_harvest.tga"
        // 닫힌 가게 앞의 지시
        set ProtoEventIcon[469] = "war3mapImported\\UI_Event_CGP9_monika_town_orders.tga"
        // 좋은꿈 슬롯머신 앞에서
        set ProtoEventIcon[354] = "war3mapImported\\UI_Event_PXS10_aventurine_coin_choice.tga"
        // 멈춘 회전판 너머
        set ProtoEventIcon[355] = "war3mapImported\\UI_Event_PXS10_gallagher_guide_after_game.tga"
        // 광고 아래의 솔글래드
        set ProtoEventIcon[358] = "war3mapImported\\UI_Event_PXS10_gallagher_hotel_corridor.tga"
        // 기억에 남겨 둔 출구
        set ProtoEventIcon[360] = "war3mapImported\\UI_Event_PXS10_acheron_open_path.tga"
        // 이름이 노래를 덮을 때 · 이름이 올라간 뒤
        set ProtoEventIcon[368] = "war3mapImported\\UI_Event_PXS10_robin_before_performance.tga"
        // 이름이 노래를 덮을 때 · 이름이 올라간 뒤
        set ProtoEventIcon[372] = "war3mapImported\\UI_Event_PXS10_robin_before_performance.tga"
        // 소개만 남은 무대
        set ProtoEventIcon[369] = "war3mapImported\\UI_Event_PXS10_soulglad_audition_stage.tga"
        // 사진 아래에 빠진 말
        set ProtoEventIcon[373] = "war3mapImported\\UI_Event_PXS10_boothill_own_identity.tga"
        // 노래를 기다렸던 다른 자리 · 로빈과 선데이가 말하는 행복
        set ProtoEventIcon[375] = "war3mapImported\\UI_Event_PXS10_penacony_grand_theater.tga"
        // 노래를 기다렸던 다른 자리 · 로빈과 선데이가 말하는 행복
        set ProtoEventIcon[387] = "war3mapImported\\UI_Event_PXS10_penacony_grand_theater.tga"
        // 꿈의 경계를 시험하는 판
        set ProtoEventIcon[384] = "war3mapImported\\UI_Event_PXS10_aventurine_boundary_trial.tga"
        // 꿈이 흐르는 암초의 사람들
        set ProtoEventIcon[385] = "war3mapImported\\UI_Event_PXS10_dreamflux_reef_people.tga"
        // 각자의 뜻으로 질서의 꿈을 깨다
        set ProtoEventIcon[389] = "war3mapImported\\UI_Event_PXS10_robin_song_and_choice.tga"
        // 벽 너머까지 들린 연습
        set ProtoEventIcon[471] = "war3mapImported\\UI_Event_PXS10_nozomi_considerate_practice.tga"
        // 후유키 방문 · 후유키 방문 · 후유키 방문 · 후유키 방문
        set ProtoEventIcon[1] = "war3mapImported\\UI_Event_FYD11_fuyuki_school_visit.tga"
        // 후유키 방문 · 후유키 방문 · 후유키 방문 · 후유키 방문
        set ProtoEventIcon[2] = "war3mapImported\\UI_Event_FYD11_fuyuki_school_visit.tga"
        // 후유키 방문 · 후유키 방문 · 후유키 방문 · 후유키 방문
        set ProtoEventIcon[3] = "war3mapImported\\UI_Event_FYD11_fuyuki_school_visit.tga"
        // 후유키 방문 · 후유키 방문 · 후유키 방문 · 후유키 방문
        set ProtoEventIcon[4] = "war3mapImported\\UI_Event_FYD11_fuyuki_school_visit.tga"
        // 명단에 없는 상자
        set ProtoEventIcon[57] = "war3mapImported\\UI_Event_FYD11_school_preparation_names.tga"
        // 비어 있는 연락 기록
        set ProtoEventIcon[58] = "war3mapImported\\UI_Event_FYD11_rin_shirou_saber_contacts.tga"
        // 접어 둔 이불 하나
        set ProtoEventIcon[64] = "war3mapImported\\UI_Event_FYD11_taiga_house_preparations.tga"
        // 표적보다 가까운 화살 · 아직 당기지 않은 줄
        set ProtoEventIcon[65] = "war3mapImported\\UI_Event_FYD11_kyudo_patient_preparation.tga"
        // 표적보다 가까운 화살 · 아직 당기지 않은 줄
        set ProtoEventIcon[68] = "war3mapImported\\UI_Event_FYD11_kyudo_patient_preparation.tga"
        // 여정 뒤에 다시 펼친 기억
        set ProtoEventIcon[85] = "war3mapImported\\UI_Event_FYD11_fuyuki_ideal_memory.tga"
        // 버틴 자리와 밀린 자리
        set ProtoEventIcon[395] = "war3mapImported\\UI_Event_FYD11_elric_after_trial.tga"
        // 카라쿠라 마을 방문 · 카라쿠라 마을 방문 · 카라쿠라 마을 방문 · 카라쿠라 마을 방문
        set ProtoEventIcon[33] = "war3mapImported\\UI_Event_BOP12_bleach_karakura_night.tga"
        // 카라쿠라 마을 방문 · 카라쿠라 마을 방문 · 카라쿠라 마을 방문 · 카라쿠라 마을 방문
        set ProtoEventIcon[34] = "war3mapImported\\UI_Event_BOP12_bleach_karakura_night.tga"
        // 카라쿠라 마을 방문 · 카라쿠라 마을 방문 · 카라쿠라 마을 방문 · 카라쿠라 마을 방문
        set ProtoEventIcon[35] = "war3mapImported\\UI_Event_BOP12_bleach_karakura_night.tga"
        // 카라쿠라 마을 방문 · 카라쿠라 마을 방문 · 카라쿠라 마을 방문 · 카라쿠라 마을 방문
        set ProtoEventIcon[36] = "war3mapImported\\UI_Event_BOP12_bleach_karakura_night.tga"
        // 수취인이 없는 짐 · 다시 읽을 수 있는 주소 · 끝까지 채워졌을까 · 한 번 읽은 목록의 다음 빈칸
        set ProtoEventIcon[318] = "war3mapImported\\UI_Event_BOP12_bleach_urahara_deliveries.tga"
        // 수취인이 없는 짐 · 다시 읽을 수 있는 주소 · 끝까지 채워졌을까 · 한 번 읽은 목록의 다음 빈칸
        set ProtoEventIcon[320] = "war3mapImported\\UI_Event_BOP12_bleach_urahara_deliveries.tga"
        // 수취인이 없는 짐 · 다시 읽을 수 있는 주소 · 끝까지 채워졌을까 · 한 번 읽은 목록의 다음 빈칸
        set ProtoEventIcon[330] = "war3mapImported\\UI_Event_BOP12_bleach_urahara_deliveries.tga"
        // 수취인이 없는 짐 · 다시 읽을 수 있는 주소 · 끝까지 채워졌을까 · 한 번 읽은 목록의 다음 빈칸
        set ProtoEventIcon[336] = "war3mapImported\\UI_Event_BOP12_bleach_urahara_deliveries.tga"
        // 지붕 끝의 발자국 · 한곳에서 울리지 않는 경보
        set ProtoEventIcon[319] = "war3mapImported\\UI_Event_BOP12_bleach_yoruichi_dark_route.tga"
        // 지붕 끝의 발자국 · 한곳에서 울리지 않는 경보
        set ProtoEventIcon[323] = "war3mapImported\\UI_Event_BOP12_bleach_yoruichi_dark_route.tga"
        // 사람이 지나간 뒤의 골목
        set ProtoEventIcon[321] = "war3mapImported\\UI_Event_BOP12_bleach_rukia_chad_passage.tga"
        // 짐에서 빠져나온 인형
        set ProtoEventIcon[322] = "war3mapImported\\UI_Event_BOP12_bleach_kon_outside_parcel.tga"
        // 표식 없는 귀환길
        set ProtoEventIcon[324] = "war3mapImported\\UI_Event_BOP12_bleach_rukia_return_route.tga"
        // 검을 내리기 전의 한 박자
        set ProtoEventIcon[325] = "war3mapImported\\UI_Event_BOP12_bleach_ichigo_sword_pause.tga"
        // 바늘 끝에서 멈춘 말
        set ProtoEventIcon[326] = "war3mapImported\\UI_Event_BOP12_bleach_uryu_careful_hands.tga"
        // 큰 손에 든 작은 인형
        set ProtoEventIcon[327] = "war3mapImported\\UI_Event_BOP12_bleach_chad_small_doll.tga"
        // 비워 둘 수 없는 한 칸
        set ProtoEventIcon[328] = "war3mapImported\\UI_Event_BOP12_bleach_yuzu_reserved_supplies.tga"
        // 박수 뒤에 가려진 길
        set ProtoEventIcon[329] = "war3mapImported\\UI_Event_BOP12_bleach_don_kanonji_audience.tga"
        // 발 하나를 놓을 자리
        set ProtoEventIcon[331] = "war3mapImported\\UI_Event_BOP12_bleach_tatsuki_practice.tga"
        // 비어 보이는 벤치
        set ProtoEventIcon[332] = "war3mapImported\\UI_Event_BOP12_bleach_karin_quiet_bench.tga"
        // 친구가 왔다는 한마디
        set ProtoEventIcon[333] = "war3mapImported\\UI_Event_BOP12_bleach_isshin_clinic.tga"
        // 작은 점원에게 맡긴 큰 짐
        set ProtoEventIcon[334] = "war3mapImported\\UI_Event_BOP12_bleach_ururu_jinta_supplies.tga"
        // 여정 뒤에 다시 펼친 기억
        set ProtoEventIcon[353] = "war3mapImported\\UI_Event_BOP12_bleach_karakura_journey_memory.tga"
        // 초대받았다는 사람
        set ProtoEventIcon[335] = "war3mapImported\\UI_Event_BOP12_keigo_invitation.tga"
        // 에길의 값표 두 장 · 같은 값표로 묶지 않을 것
        set ProtoEventIcon[218] = "war3mapImported\\UI_Event_BOP12_merchant_price_tags.tga"
        // 에길의 값표 두 장 · 같은 값표로 묶지 않을 것
        set ProtoEventIcon[229] = "war3mapImported\\UI_Event_BOP12_merchant_price_tags.tga"
        // 마르지 않은 흰 천
        set ProtoEventIcon[432] = "war3mapImported\\UI_Event_BOP12_rainy_white_linen.tga"
        // 진흙 아래의 반응
        set ProtoEventIcon[283] = "war3mapImported\\UI_Event_BOP12_dowsing_before_search.tga"
        // 상자를 연 뒤의 흔적
        set ProtoEventIcon[284] = "war3mapImported\\UI_Event_BOP12_dowsing_after_delivery.tga"
        // 고철 옆에 남은 표시
        set ProtoEventIcon[285] = "war3mapImported\\UI_Event_BOP12_dowsing_scrap_measurement.tga"
        // 파이 상자에 남은 이름
        set ProtoEventIcon[406] = "war3mapImported\\UI_Event_BOP12_pie_delivery_tags.tga"
        // 연금 조정의 견본
        set ProtoEventIcon[249] = "war3mapImported\\UI_Event_DSP13_mixed_alchemy_samples.tga"
        // 한 바퀴가 같은 한 바퀴일까
        set ProtoEventIcon[121] = "war3mapImported\\UI_Event_DSP13_bicycle_and_route.tga"
        // 아직 쓰는 철과 먹을 철
        set ProtoEventIcon[295] = "war3mapImported\\UI_Event_DSP13_chair_parts_and_scrap_iron.tga"
        // 풀 가장자리에 모인 준비물
        set ProtoEventIcon[157] = "war3mapImported\\UI_Event_DSP13_poolside_supply_bundles.tga"
        // 남는 간식이 아니라 남길 간식
        set ProtoEventIcon[123] = "war3mapImported\\UI_Event_DSP13_snacks_and_empty_ledger.tga"
        // 문턱에 남겨 둔 당부
        set ProtoEventIcon[436] = "war3mapImported\\UI_Event_DSP13_torn_departure_satchel.tga"
        // 문이 있던 쪽의 부서진 벽
        set ProtoEventIcon[299] = "war3mapImported\\UI_Event_DSP13_broken_guild_wall_passage.tga"
        // 돌아온 가방에 다른 치수
        set ProtoEventIcon[408] = "war3mapImported\\UI_Event_DSP13_returned_bag_measurements.tga"
        // 까마귀가 두 번 읽은 문장
        set ProtoEventIcon[433] = "war3mapImported\\UI_Event_DSP13_messenger_crow.tga"
    endfunction
endlibrary
