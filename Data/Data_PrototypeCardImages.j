// 검토한 캐릭터 그림을 보관함과 카드 보상의 얼굴 아이콘·큰 그림에 연결한다.
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
        call SetImages(85, "UI_Card_KSO1_kazuma_Icon", "UI_Card_KSO1_kazuma_Art")
        // 크리스
        call SetImages(86, "UI_Card_KSB_chris_Icon", "UI_Card_KSB_chris_Art")
        // 메구밍
        call SetImages(87, "UI_Card_KSO1_megumin_Icon", "UI_Card_KSO1_megumin_Art")
        // 다크니스
        call SetImages(88, "UI_Card_KSO1_darkness_Icon", "UI_Card_KSO1_darkness_Art")
        // 아쿠아
        call SetImages(89, "UI_Card_KSO1_aqua_Icon", "UI_Card_KSO1_aqua_Art")
        // 위즈
        call SetImages(90, "UI_Card_KSO1_wiz_Icon", "UI_Card_KSO1_wiz_Art")
        // 바니르
        call SetImages(91, "UI_Card_KSB_vanir_Icon", "UI_Card_KSB_vanir_Art")
        // 융융
        call SetImages(94, "UI_Card_KSB_yunyun_Icon", "UI_Card_KSB_yunyun_Art")
        // 미츠루기
        call SetImages(95, "UI_Card_KSB_mitsurugi_Icon", "UI_Card_KSB_mitsurugi_Art")
        // 카즈마
        call SetImages(123, "UI_Card_KSO1_kazuma_Icon", "UI_Card_KSO1_kazuma_Art")
        // 오쿠소라 아야네
        call SetImages(147, "UI_Card_BAM2_23005_Icon", "UI_Card_BAM1_23005_Art")
        // 스나오오카미 시로코
        call SetImages(148, "UI_Card_BAS1_10010_Icon", "UI_Card_BAS1_10010_Art")
        // 쿠로미 세리카
        call SetImages(149, "UI_Card_BAM2_13008_Icon", "UI_Card_BAM1_13008_Art")
        // 이자요이 노노미
        call SetImages(150, "UI_Card_BAM2_13004_Icon", "UI_Card_BAM1_13004_Art")
        // 타카나시 호시노
        call SetImages(151, "UI_Card_BAM2_10005_Icon", "UI_Card_BAM1_10005_Art")
        // 아지타니 히후미
        call SetImages(153, "UI_Card_BAM2_10003_Icon", "UI_Card_BAM1_10003_Art")
        // 리쿠하치마 아루
        call SetImages(161, "UI_Card_BAM2_10000_Icon", "UI_Card_BAM1_10000_Art")
        // 오니카타 카요코
        call SetImages(162, "UI_Card_BAM2_13005_Icon", "UI_Card_BAM1_13005_Art")
        // 이구사 하루카
        call SetImages(163, "UI_Card_BAM2_16000_Icon", "UI_Card_BAM1_16000_Art")
        // 아사기 무츠키
        call SetImages(164, "UI_Card_BAM2_13006_Icon", "UI_Card_BAM1_13006_Art")
        // 아야네
        call SetImages(177, "UI_Card_BAM2_23005_Icon", "UI_Card_BAM1_23005_Art")
        // 시로코
        call SetImages(180, "UI_Card_BAS1_10010_Icon", "UI_Card_BAS1_10010_Art")
        // 세리카
        call SetImages(183, "UI_Card_BAM2_13008_Icon", "UI_Card_BAM1_13008_Art")
        // 노노미
        call SetImages(186, "UI_Card_BAM2_13004_Icon", "UI_Card_BAM1_13004_Art")
        // 호시노
        call SetImages(189, "UI_Card_BAM2_10005_Icon", "UI_Card_BAM1_10005_Art")
        // 우이하루 카자리
        call SetImages(219, "UI_Card_RGT_10_Icon", "UI_Card_RGT_10_Art")
        // 미사카 미코토
        call SetImages(220, "UI_Card_RGO1_mikoto_Icon", "UI_Card_RGO1_mikoto_Art")
        // 시라이 쿠로코
        call SetImages(221, "UI_Card_RGO1_kuroko_Icon", "UI_Card_RGO1_kuroko_Art")
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
        call SetImages(258, "UI_Card_RGO1_accelerator_Icon", "UI_Card_RGO1_accelerator_Art")
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
        call SetImages(358, "UI_Card_SAO1_kirito_Icon", "UI_Card_SAO1_kirito_Art")
        // 아스나
        call SetImages(359, "UI_Card_SAO1_asuna_Icon", "UI_Card_SAO1_asuna_Art")
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
        call SetImages(490, "UI_Card_NRO1_yato_Icon", "UI_Card_NRO1_yato_Art")
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
        call SetImages(571, "UI_Card_BBO1_ichigo_Icon", "UI_Card_BBO1_ichigo_Art")
        // 이시다 우류
        call SetImages(572, "UI_Card_BBO1_uryu_Icon", "UI_Card_BBO1_uryu_Art")
        // 이노우에 오리히메
        call SetImages(573, "UI_Card_BBO2_orihime_Icon", "UI_Card_BBO2_orihime_Art")
        // 시호인 요루이치
        call SetImages(574, "UI_Card_BBO2_yoruichi_Icon", "UI_Card_BBO2_yoruichi_Art")
        // 쿠치키 루키아
        call SetImages(575, "UI_Card_BBO1_rukia_Icon", "UI_Card_BBO1_rukia_Art")
        // 우라하라 키스케
        call SetImages(576, "UI_Card_BBO2_urahara_Icon", "UI_Card_BBO2_urahara_Art")
        // 사도 야스토라
        call SetImages(577, "UI_Card_BBO2_sado_Icon", "UI_Card_BBO2_sado_Art")
        // 쿠로사키 유즈
        call SetImages(580, "UI_Card_QU7_yuzu_Icon", "UI_Card_QU7_yuzu_Art")
        // 아리사와 타츠키
        call SetImages(581, "UI_Card_SUP5_tatsuki_Icon", "UI_Card_SUP5_tatsuki_Art")
        // 돈 칸온지
        call SetImages(582, "UI_Card_BBS_kanonji_Icon", "UI_Card_BBS_kanonji_Art")
        // 쿠로사키 카린
        call SetImages(583, "UI_Card_SUP5_karin_Icon", "UI_Card_SUP5_karin_Art")
        // 쿠로사키 잇신
        call SetImages(584, "UI_Card_BBO2_isshin_Icon", "UI_Card_BBO2_isshin_Art")
        // 츠무기야 우루루
        call SetImages(585, "UI_Card_BBS_ururu_Icon", "UI_Card_BBS_ururu_Art")
        // 아사노 케이고
        call SetImages(586, "UI_Card_BKQ11_keigo_Icon", "UI_Card_BKQ11_keigo_Art")
        // 하나카리 진타
        call SetImages(593, "UI_Card_BBS_jinta_Icon", "UI_Card_BBS_jinta_Art")
        // 야마다 하나타로
        call SetImages(613, "UI_Card_BBS_hanataro_Icon", "UI_Card_BBS_hanataro_Art")
        // 아바라이 렌지
        call SetImages(616, "UI_Card_BBO1_renji_Icon", "UI_Card_BBO1_renji_Art")
        // 쿠치키 뱌쿠야
        call SetImages(631, "UI_Card_BBO1_byakuya_Icon", "UI_Card_BBO1_byakuya_Art")
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
        call SetImages(725, "UI_Card_RMU12_roy_Icon", "UI_Card_RMU12_roy_Art")
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
        call SetImages(795, "UI_Card_KMO1_tanjiro_Icon", "UI_Card_KMO1_tanjiro_Art")
        // 츠유리 카나오
        call SetImages(796, "UI_Card_KNY_kanawo_Icon", "UI_Card_KNY_kanawo_Art")
        // 코쵸 시노부
        call SetImages(797, "UI_Card_KMO2_shinobu_Icon", "UI_Card_KMO2_shinobu_Art")
        // 아가츠마 젠이츠
        call SetImages(798, "UI_Card_KMO1_zenitsu_Icon", "UI_Card_KMO1_zenitsu_Art")
        // 하시비라 이노스케
        call SetImages(799, "UI_Card_KMO2_inosuke_Icon", "UI_Card_KMO2_inosuke_Art")
        // 무라타
        call SetImages(806, "UI_Card_KNYG_murata_Icon", "UI_Card_KNYG_murata_Art")
        // 카마도 네즈코
        call SetImages(808, "UI_Card_KMO1_nezuko_Icon", "UI_Card_KMO1_nezuko_Art")
        // 렌고쿠 쿄쥬로
        call SetImages(833, "UI_Card_KMO2_rengoku_Icon", "UI_Card_KMO2_rengoku_Art")
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
    endfunction
endlibrary
