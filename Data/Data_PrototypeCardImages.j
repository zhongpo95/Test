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
        call SetImages(14, "UI_Card_FateCalm_saber_Icon", "UI_Card_FateCalm_saber_Art")
        // 토오사카 린
        call SetImages(16, "UI_Card_FateCalm_rin_Icon", "UI_Card_FateCalm_rin_Art")
        // 아처
        call SetImages(17, "UI_Card_FateCalm_archer_Icon", "UI_Card_FateCalm_archer_Art")
        // 어새신
        call SetImages(18, "UI_Card_FateCalm_assassin_Icon", "UI_Card_FateCalm_assassin_Art")
        // 마토 사쿠라
        call SetImages(19, "UI_Card_FateCalm_sakura_Icon", "UI_Card_FateCalm_sakura_Art")
        // 캐스터
        call SetImages(20, "UI_Card_FateCalm_caster_Icon", "UI_Card_FateCalm_caster_Art")
        // 후지무라 타이가
        call SetImages(21, "UI_Card_FSN_ch14_Icon", "UI_Card_FSN_ch14_Art")
        // 랜서
        call SetImages(26, "UI_Card_FateCalm_lancer_Icon", "UI_Card_FateCalm_lancer_Art")
        // 코토미네 키레이
        call SetImages(30, "UI_Card_FSN_ch09_Icon", "UI_Card_FSN_ch09_Art")
        // 루나
        call SetImages(84, "UI_Card_KSB_luna_Icon", "UI_Card_KSB_luna_Art")
        // 사토 카즈마
        call SetImages(85, "UI_Card_KSO1_kazuma_Icon", "UI_Card_KSO1_kazuma_Art")
        // 크리스
        call SetImages(86, "UI_Card_KSB_MST26_chris_Icon", "UI_Card_KSB_MST26_chris_Art")
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
        call SetImages(94, "UI_Card_KSB_MST26_yunyun_Icon", "UI_Card_KSB_MST26_yunyun_Art")
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
        call SetImages(219, "UI_Card_RGT_IF_uiharu_Icon", "UI_Card_RGT_IF_uiharu_Art")
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
        // 소울 젬
        call SetImages(335, "UI_Card_ITEM1_SayakaSoulGem_Icon", "UI_Card_ITEM1_SayakaSoulGem_Art")
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
        call SetImages(491, "UI_Card_FaceFix_yukine_Icon", "UI_Card_NRG_yukine_Art")
        // 이키 히요리
        call SetImages(492, "UI_Card_NRG_hiyori_Icon", "UI_Card_NRG_hiyori_Art")
        // 호로
        call SetImages(493, "UI_Card_SWO1_holo_Icon", "UI_Card_SWO1_holo_Art")
        // 크래프트 로렌스
        call SetImages(494, "UI_Card_SWO1_lawrence_Icon", "UI_Card_SWO1_lawrence_Art")
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
        call SetImages(717, "UI_Card_FMO3_winry_Icon", "UI_Card_FMO3_winry_Art")
        // 에드워드 엘릭
        call SetImages(718, "UI_Card_FCU8_edward_Icon", "UI_Card_FCU8_edward_Art")
        // 알폰스 엘릭
        call SetImages(719, "UI_Card_FCU8_alphonse_Icon", "UI_Card_FCU8_alphonse_Art")
        // 셰스카
        call SetImages(721, "UI_Card_FMA_21_Icon", "UI_Card_FMA_21_Art")
        // 알렉스 루이 암스트롱
        call SetImages(722, "UI_Card_FMO1_armstrong_Icon", "UI_Card_FMO1_armstrong_Art")
        // 이즈미 커티스
        call SetImages(723, "UI_Card_FMO2_izumi_Icon", "UI_Card_FMO2_izumi_Art")
        // 로이 머스탱
        call SetImages(725, "UI_Card_RMU12_roy_Icon", "UI_Card_RMU12_roy_Art")
        // 리자 호크아이
        call SetImages(726, "UI_Card_FMO3_riza_Icon", "UI_Card_FMO3_riza_Art")
        // 마스 휴즈
        call SetImages(727, "UI_Card_FMO1_hughes_Icon", "UI_Card_FMO1_hughes_Art")
        // 피나코 록벨
        call SetImages(728, "UI_Card_FMA_13_Icon", "UI_Card_FMA_13_Art")
        // 시그 커티스
        call SetImages(729, "UI_Card_FMA_26_Icon", "UI_Card_FMA_26_Art")
        // 린 야오
        call SetImages(730, "UI_Card_FMO2_lin_Icon", "UI_Card_FMO2_lin_Art")
        // 장 하보크
        call SetImages(738, "UI_Card_FMA_17_Icon", "UI_Card_FMA_17_Art")
        // 그리드
        call SetImages(761, "UI_Card_FMO3_greed_Icon", "UI_Card_FMO3_greed_Art")
        // 반 호엔하임
        call SetImages(773, "UI_Card_FMO2_hohenheim_Icon", "UI_Card_FMO2_hohenheim_Art")
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
        call SetImages(806, "UI_Card_FaceFix_murata_Icon", "UI_Card_KNYG_murata_Art")
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

        // 메인 이야기 완결을 기념하는 작품별 공식 표지를 연결한다.
        // 함께 걷는 이상
        call SetImages(924, "UI_Card_Ending_fuyuki_Icon", "UI_Card_Ending_fuyuki_Art")
        // 돌아갈 집은 지켰다
        call SetImages(925, "UI_Card_Ending_axel_Icon", "UI_Card_Ending_axel_Art")
        // 다섯 자리가 있는 교실
        call SetImages(926, "UI_Card_Ending_abydos_Icon", "UI_Card_Ending_abydos_Art")
        // 번호 너머의 내일
        call SetImages(927, "UI_Card_Ending_academy_Icon", "UI_Card_Ending_academy_Art")
        // 이어지는 리본
        call SetImages(928, "UI_Card_Ending_mitakihara_Icon", "UI_Card_Ending_mitakihara_Art")
        // 현실로 이어진 약속
        call SetImages(929, "UI_Card_Ending_aincrad_Icon", "UI_Card_Ending_aincrad_Art")
        // 돌아온 안내인의 일지
        call SetImages(930, "UI_Card_Ending_zegagrande_Icon", "UI_Card_Ending_zegagrande_Art")
        // 내가 돌아올 길드
        call SetImages(931, "UI_Card_Ending_magnolia_Icon", "UI_Card_Ending_magnolia_Art")
        // 사신대행증
        call SetImages(932, "UI_Card_Ending_karakura_Icon", "UI_Card_Ending_karakura_Art")
        // 우린 꿈에서 깨어날 거니까
        call SetImages(933, "UI_Card_Ending_penacony_Icon", "UI_Card_Ending_penacony_Art")
        // 함께 돌아온 두 손
        call SetImages(934, "UI_Card_Ending_amestris_Icon", "UI_Card_Ending_amestris_Art")
        // 다음 새벽의 호흡
        call SetImages(935, "UI_Card_Ending_butterfly_Icon", "UI_Card_Ending_butterfly_Art")
        // 네 사람이 앉는 식탁
        call SetImages(936, "UI_Card_Ending_gourmet_Icon", "UI_Card_Ending_gourmet_Art")
        // 트리비
        call SetImages(937, "UI_Card_XP_amphoreus_tribbie_Icon", "UI_Card_XP_amphoreus_tribbie_Art")
        // 파이논
        call SetImages(938, "UI_Card_XP_amphoreus_phainon_Icon", "UI_Card_XP_amphoreus_phainon_Art")
        // 아글라이아
        call SetImages(939, "UI_Card_XP_amphoreus_aglaea_Icon", "UI_Card_XP_amphoreus_aglaea_Art")
        // 마이데이
        call SetImages(940, "UI_Card_XP_amphoreus_mydei_Icon", "UI_Card_XP_amphoreus_mydei_Art")
        // 카스토리스
        call SetImages(941, "UI_Card_XP_amphoreus_castorice_Icon", "UI_Card_XP_amphoreus_castorice_Art")
        // 아낙사
        call SetImages(942, "UI_Card_XP_amphoreus_anaxa_Icon", "UI_Card_XP_amphoreus_anaxa_Art")
        // 히아킨
        call SetImages(943, "UI_Card_XP_amphoreus_hyacine_Icon", "UI_Card_XP_amphoreus_hyacine_Art")
        // 사이퍼
        call SetImages(944, "UI_Card_XP_amphoreus_cipher_Icon", "UI_Card_XP_amphoreus_cipher_Art")
        // 키레네
        call SetImages(945, "UI_Card_XP_amphoreus_cyrene_Icon", "UI_Card_XP_amphoreus_cyrene_Art")
        // 케리드라
        call SetImages(946, "UI_Card_XP_amphoreus_cerydra_Icon", "UI_Card_XP_amphoreus_cerydra_Art")
        // 히실렌스
        call SetImages(947, "UI_Card_XP_amphoreus_hysilens_Icon", "UI_Card_XP_amphoreus_hysilens_Art")
        // 미래에 남겨 둔 불씨
        call SetImages(994, "UI_Card_XP_amphoreus_head_Icon", "UI_Card_XP_amphoreus_head_Art")
        // 스피드왜건
        call SetImages(995, "UI_Card_XP_phantom_blood_speedwagon_Icon", "UI_Card_XP_phantom_blood_speedwagon_Art")
        // 죠나단 죠스타
        call SetImages(996, "UI_Card_XP_phantom_blood_jonathan_Icon", "UI_Card_XP_phantom_blood_jonathan_Art")
        // 디오 브란도
        call SetImages(997, "UI_Card_XP_phantom_blood_dio_Icon", "UI_Card_XP_phantom_blood_dio_Art")
        // 윌 A. 체펠리
        call SetImages(998, "UI_Card_XP_phantom_blood_zeppeli_Icon", "UI_Card_XP_phantom_blood_zeppeli_Art")
        // 에리나 펜들턴
        call SetImages(999, "UI_Card_XP_phantom_blood_erina_Icon", "UI_Card_XP_phantom_blood_erina_Art")
        // 톤페티
        call SetImages(1000, "UI_Card_XP_phantom_blood_tonpetty_Icon", "UI_Card_XP_phantom_blood_tonpetty_Art")
        // 마지막 파문
        call SetImages(1034, "UI_Card_XP_phantom_blood_head_Icon", "UI_Card_XP_phantom_blood_head_Art")
        // 마돌체 마죠레느
        call SetImages(1035, "UI_Card_XP_madolche_magileine_Icon", "UI_Card_XP_madolche_magileine_Art")
        // 마돌체 푸딩세스
        call SetImages(1036, "UI_Card_XP_madolche_puddingcess_Icon", "UI_Card_XP_madolche_puddingcess_Art")
        // 퀸마돌체 티아라미스
        call SetImages(1037, "UI_Card_XP_madolche_tiaramisu_Icon", "UI_Card_XP_madolche_tiaramisu_Art")
        // 마돌체 엔젤리
        call SetImages(1038, "UI_Card_XP_madolche_anjelly_Icon", "UI_Card_XP_madolche_anjelly_Art")
        // 마돌체 훗케이크
        call SetImages(1039, "UI_Card_XP_madolche_hootcake_Icon", "UI_Card_XP_madolche_hootcake_Art")
        // 마돌체 메신젤라또
        call SetImages(1040, "UI_Card_XP_madolche_messengelato_Icon", "UI_Card_XP_madolche_messengelato_Art")
        // 마돌체 푸팅세스루
        call SetImages(1041, "UI_Card_XP_madolche_petingcessoeur_Icon", "UI_Card_XP_madolche_petingcessoeur_Art")
        // 티처마돌체 글래스플레
        call SetImages(1042, "UI_Card_XP_madolche_glassouffle_Icon", "UI_Card_XP_madolche_glassouffle_Art")
        // 돌아올 자리가 있는 다과회
        call SetImages(1076, "UI_Card_XP_madolche_head_Icon", "UI_Card_XP_madolche_head_Art")
        // 이츠카 시도
        call SetImages(1077, "UI_Card_XP_tengu_shido_Icon", "UI_Card_XP_tengu_shido_Art")
        // 야토가미 토카
        call SetImages(1078, "UI_Card_XP_tengu_tohka_Icon", "UI_Card_XP_tengu_tohka_Art")
        // 토비이치 오리가미
        call SetImages(1079, "UI_Card_XP_tengu_origami_Icon", "UI_Card_XP_tengu_origami_Art")
        // 이츠카 코토리
        call SetImages(1080, "UI_Card_XP_tengu_kotori_Icon", "UI_Card_XP_tengu_kotori_Art")
        // 요시노
        call SetImages(1081, "UI_Card_XP_tengu_yoshino_Icon", "UI_Card_XP_tengu_yoshino_Art")
        // 토키사키 쿠루미
        call SetImages(1082, "UI_Card_XP_tengu_kurumi_Icon", "UI_Card_XP_tengu_kurumi_Art")
        // 텐구시의 기억
        call SetImages(1119, "UI_Card_XP_tengu_head_Icon", "UI_Card_XP_tengu_head_Art")
        // 류가미네 미카도
        call SetImages(1120, "UI_Card_XP_ikebukuro_mikado_Icon", "UI_Card_XP_ikebukuro_mikado_Art")
        // 셀티 스툴루손
        call SetImages(1121, "UI_Card_XP_ikebukuro_celty_Icon", "UI_Card_XP_ikebukuro_celty_Art")
        // 키다 마사오미
        call SetImages(1122, "UI_Card_XP_ikebukuro_masaomi_Icon", "UI_Card_XP_ikebukuro_masaomi_Art")
        // 소노하라 안리
        call SetImages(1123, "UI_Card_XP_ikebukuro_anri_Icon", "UI_Card_XP_ikebukuro_anri_Art")
        // 오리하라 이자야
        call SetImages(1124, "UI_Card_XP_ikebukuro_izaya_Icon", "UI_Card_XP_ikebukuro_izaya_Art")
        // 헤이와지마 시즈오
        call SetImages(1125, "UI_Card_XP_ikebukuro_shizuo_Icon", "UI_Card_XP_ikebukuro_shizuo_Art")
        // 키시타니 신라
        call SetImages(1126, "UI_Card_XP_ikebukuro_shinra_Icon", "UI_Card_XP_ikebukuro_shinra_Art")
        // 카도타 쿄헤이
        call SetImages(1127, "UI_Card_XP_ikebukuro_kadota_Icon", "UI_Card_XP_ikebukuro_kadota_Art")
        // 이케부쿠로의 기억
        call SetImages(1162, "UI_Card_XP_ikebukuro_head_Icon", "UI_Card_XP_ikebukuro_head_Art")
        // 페른
        call SetImages(1163, "UI_Card_XP_frieren_fern_Icon", "UI_Card_XP_frieren_fern_Art")
        // 프리렌
        call SetImages(1164, "UI_Card_XP_frieren_frieren_Icon", "UI_Card_XP_frieren_frieren_Art")
        // 슈타르크
        call SetImages(1165, "UI_Card_XP_frieren_stark_Icon", "UI_Card_XP_frieren_stark_Art")
        // 힘멜
        call SetImages(1166, "UI_Card_XP_frieren_himmel_Icon", "UI_Card_XP_frieren_himmel_Art")
        // 하이터
        call SetImages(1167, "UI_Card_XP_frieren_heiter_Icon", "UI_Card_XP_frieren_heiter_Art")
        // 아이젠
        call SetImages(1168, "UI_Card_XP_frieren_eisen_Icon", "UI_Card_XP_frieren_eisen_Art")
        // 자인
        call SetImages(1169, "UI_Card_XP_frieren_sein_Icon", "UI_Card_XP_frieren_sein_Art")
        // 플람메
        call SetImages(1170, "UI_Card_XP_frieren_flamme_Icon", "UI_Card_XP_frieren_flamme_Art")
        // 제리에
        call SetImages(1171, "UI_Card_XP_frieren_serie_Icon", "UI_Card_XP_frieren_serie_Art")
        // 덴켄
        call SetImages(1172, "UI_Card_XP_frieren_denken_Icon", "UI_Card_XP_frieren_denken_Art")
        // 라비네
        call SetImages(1173, "UI_Card_XP_frieren_lawine_Icon", "UI_Card_XP_frieren_lawine_Art")
        // 칸네
        call SetImages(1174, "UI_Card_XP_frieren_kanne_Icon", "UI_Card_XP_frieren_kanne_Art")
        // 프리렌 일행
        call SetImages(1208, "UI_Card_XP_frieren_head_Icon", "UI_Card_XP_frieren_head_Art")
        // 라이오스
        call SetImages(1209, "UI_Card_XP_dungeon_meshi_laios_Icon", "UI_Card_XP_dungeon_meshi_laios_Art")
        // 마르실
        call SetImages(1210, "UI_Card_XP_dungeon_meshi_marcille_Icon", "UI_Card_XP_dungeon_meshi_marcille_Art")
        // 칠책
        call SetImages(1211, "UI_Card_XP_dungeon_meshi_chilchuck_Icon", "UI_Card_XP_dungeon_meshi_chilchuck_Art")
        // 센시
        call SetImages(1212, "UI_Card_XP_dungeon_meshi_senshi_Icon", "UI_Card_XP_dungeon_meshi_senshi_Art")
        // 파린
        call SetImages(1213, "UI_Card_XP_dungeon_meshi_falin_Icon", "UI_Card_XP_dungeon_meshi_falin_Art")
        // 나마리
        call SetImages(1214, "UI_Card_XP_dungeon_meshi_namari_Icon", "UI_Card_XP_dungeon_meshi_namari_Art")
        // 슈로
        call SetImages(1215, "UI_Card_XP_dungeon_meshi_shuro_Icon", "UI_Card_XP_dungeon_meshi_shuro_Art")
        // 카블루
        call SetImages(1216, "UI_Card_XP_dungeon_meshi_kabru_Icon", "UI_Card_XP_dungeon_meshi_kabru_Art")
        // 다시 마주 앉은 식탁
        call SetImages(1256, "UI_Card_XP_dungeon_meshi_head_Icon", "UI_Card_XP_dungeon_meshi_head_Art")
        // 곤
        call SetImages(1257, "UI_Card_XP_hunter_exam_gon_Icon", "UI_Card_XP_hunter_exam_gon_Art")
        // 키르아
        call SetImages(1258, "UI_Card_XP_hunter_exam_killua_Icon", "UI_Card_XP_hunter_exam_killua_Art")
        // 크라피카
        call SetImages(1259, "UI_Card_XP_hunter_exam_kurapika_Icon", "UI_Card_XP_hunter_exam_kurapika_Art")
        // 레오리오
        call SetImages(1260, "UI_Card_XP_hunter_exam_leorio_Icon", "UI_Card_XP_hunter_exam_leorio_Art")
        // 히소카
        call SetImages(1261, "UI_Card_XP_hunter_exam_hisoka_Icon", "UI_Card_XP_hunter_exam_hisoka_Art")
        // 한조
        call SetImages(1262, "UI_Card_XP_hunter_exam_hanzo_Icon", "UI_Card_XP_hunter_exam_hanzo_Art")
        // 사토츠
        call SetImages(1263, "UI_Card_XP_hunter_exam_satotz_Icon", "UI_Card_XP_hunter_exam_satotz_Art")
        // 네테로
        call SetImages(1264, "UI_Card_XP_hunter_exam_netero_Icon", "UI_Card_XP_hunter_exam_netero_Art")
        // 합격증 너머의 친구
        call SetImages(1266, "UI_Card_XP_hunter_exam_ending_memorial_Icon", "UI_Card_XP_hunter_exam_ending_memorial_Art")
        // 나츠키 스바루
        call SetImages(1306, "UI_Card_XP_roswaal_mansion_subaru_Icon", "UI_Card_XP_roswaal_mansion_subaru_Art")
        // 에밀리아
        call SetImages(1307, "UI_Card_XP_roswaal_mansion_emilia_Icon", "UI_Card_XP_roswaal_mansion_emilia_Art")
        // 렘
        call SetImages(1308, "UI_Card_XP_roswaal_mansion_rem_Icon", "UI_Card_XP_roswaal_mansion_rem_Art")
        // 람
        call SetImages(1309, "UI_Card_XP_roswaal_mansion_ram_Icon", "UI_Card_XP_roswaal_mansion_ram_Art")
        // 베아트리스
        call SetImages(1310, "UI_Card_XP_roswaal_mansion_beatrice_Icon", "UI_Card_XP_roswaal_mansion_beatrice_Art")
        // 로즈월 L. 메이더스
        call SetImages(1311, "UI_Card_XP_roswaal_mansion_roswaal_Icon", "UI_Card_XP_roswaal_mansion_roswaal_Art")
        // 팩
        call SetImages(1312, "UI_Card_XP_roswaal_mansion_puck_Icon", "UI_Card_XP_roswaal_mansion_puck_Art")
        // 모두가 있는 저택의 아침
        call SetImages(1355, "UI_Card_XP_roswaal_mansion_ending_memorial_Icon", "UI_Card_XP_roswaal_mansion_ending_memorial_Art")
        // 사이타마
        call SetImages(1356, "UI_Card_XP_z_city_saitama_Icon", "UI_Card_XP_z_city_saitama_Art")
        // 제노스
        call SetImages(1357, "UI_Card_XP_z_city_genos_Icon", "UI_Card_XP_z_city_genos_Art")
        // 음속의 소닉
        call SetImages(1358, "UI_Card_XP_z_city_sonic_Icon", "UI_Card_XP_z_city_sonic_Art")
        // 무면허 라이더
        call SetImages(1359, "UI_Card_XP_z_city_mumen_Icon", "UI_Card_XP_z_city_mumen_Art")
        // 뱅
        call SetImages(1360, "UI_Card_XP_z_city_bang_Icon", "UI_Card_XP_z_city_bang_Art")
        // 전율의 타츠마키
        call SetImages(1361, "UI_Card_XP_z_city_tatsumaki_Icon", "UI_Card_XP_z_city_tatsumaki_Art")
        // 아토믹 사무라이
        call SetImages(1362, "UI_Card_XP_z_city_atomic_Icon", "UI_Card_XP_z_city_atomic_Art")
        // 금속배트
        call SetImages(1363, "UI_Card_XP_z_city_metalbat_Icon", "UI_Card_XP_z_city_metalbat_Art")
        // 보로스
        call SetImages(1364, "UI_Card_XP_z_city_boros_Icon", "UI_Card_XP_z_city_boros_Art")
        // 내일도 히어로
        call SetImages(1402, "UI_Card_XP_z_city_ending_memorial_Icon", "UI_Card_XP_z_city_ending_memorial_Art")
        // 사쿠라바 에마
        call SetImages(1403, "UI_Card_XP_witch_prison_ema_Icon", "UI_Card_XP_witch_prison_ema_Art")
        // 니카이도 히로
        call SetImages(1404, "UI_Card_XP_witch_prison_hiro_Icon", "UI_Card_XP_witch_prison_hiro_Art")
        // 나츠메 앙앙
        call SetImages(1405, "UI_Card_XP_witch_prison_anan_Icon", "UI_Card_XP_witch_prison_anan_Art")
        // 조가사키 노아
        call SetImages(1406, "UI_Card_XP_witch_prison_noah_Icon", "UI_Card_XP_witch_prison_noah_Art")
        // 토노 한나
        call SetImages(1407, "UI_Card_XP_witch_prison_hanna_Icon", "UI_Card_XP_witch_prison_hanna_Art")
        // 타치바나 셰리
        call SetImages(1408, "UI_Card_XP_witch_prison_sherry_Icon", "UI_Card_XP_witch_prison_sherry_Art")
        // 하스미 레이아
        call SetImages(1409, "UI_Card_XP_witch_prison_leia_Icon", "UI_Card_XP_witch_prison_leia_Art")
        // 사에키 미리아
        call SetImages(1410, "UI_Card_XP_witch_prison_miria_Icon", "UI_Card_XP_witch_prison_miria_Art")
        // 쿠로베 나노카
        call SetImages(1411, "UI_Card_XP_witch_prison_nanoka_Icon", "UI_Card_XP_witch_prison_nanoka_Art")
        // 사와타리 코코
        call SetImages(1412, "UI_Card_XP_witch_prison_koko_Icon", "UI_Card_XP_witch_prison_koko_Art")
        // 호쇼 마고
        call SetImages(1413, "UI_Card_XP_witch_prison_margo_Icon", "UI_Card_XP_witch_prison_margo_Art")
        // 히카미 메루루
        call SetImages(1414, "UI_Card_XP_witch_prison_meruru_Icon", "UI_Card_XP_witch_prison_meruru_Art")
        // 철문 너머의 내일
        call SetImages(1460, "UI_Card_XP_witch_prison_ending_memorial_Icon", "UI_Card_XP_witch_prison_ending_memorial_Art")
        // 조커
        call SetImages(1462, "UI_Card_XP_persona5_joker_Icon", "UI_Card_XP_persona5_joker_Art")
        // 모르가나
        call SetImages(1463, "UI_Card_XP_persona5_morgana_Icon", "UI_Card_XP_persona5_morgana_Art")
        // 사카모토 류지
        call SetImages(1464, "UI_Card_XP_persona5_ryuji_Icon", "UI_Card_XP_persona5_ryuji_Art")
        // 타카마키 안
        call SetImages(1465, "UI_Card_XP_persona5_ann_Icon", "UI_Card_XP_persona5_ann_Art")
        // 키타가와 유스케
        call SetImages(1466, "UI_Card_XP_persona5_yusuke_Icon", "UI_Card_XP_persona5_yusuke_Art")
        // 니지마 마코토
        call SetImages(1467, "UI_Card_XP_persona5_makoto_Icon", "UI_Card_XP_persona5_makoto_Art")
        // 사쿠라 후타바
        call SetImages(1468, "UI_Card_XP_persona5_futaba_Icon", "UI_Card_XP_persona5_futaba_Art")
        // 오쿠무라 하루
        call SetImages(1469, "UI_Card_XP_persona5_haru_Icon", "UI_Card_XP_persona5_haru_Art")
        // 아케치 고로
        call SetImages(1470, "UI_Card_XP_persona5_akechi_Icon", "UI_Card_XP_persona5_akechi_Art")
        // 니지마 사에
        call SetImages(1471, "UI_Card_XP_persona5_sae_Icon", "UI_Card_XP_persona5_sae_Art")
        // 사쿠라 소지로
        call SetImages(1472, "UI_Card_XP_persona5_sojiro_Icon", "UI_Card_XP_persona5_sojiro_Art")
        // 다시 이어질 우리의 길
        call SetImages(1519, "UI_Card_XP_persona5_ending_memorial_Icon", "UI_Card_XP_persona5_ending_memorial_Art")
        // 조커
        call SetImages(1520, "UI_Card_XP_persona5_royal_joker_Icon", "UI_Card_XP_persona5_royal_joker_Art")
        // 모르가나
        call SetImages(1521, "UI_Card_XP_persona5_royal_morgana_Icon", "UI_Card_XP_persona5_royal_morgana_Art")
        // 사카모토 류지
        call SetImages(1522, "UI_Card_XP_persona5_royal_ryuji_Icon", "UI_Card_XP_persona5_royal_ryuji_Art")
        // 타카마키 안
        call SetImages(1523, "UI_Card_XP_persona5_royal_ann_Icon", "UI_Card_XP_persona5_royal_ann_Art")
        // 키타가와 유스케
        call SetImages(1524, "UI_Card_XP_persona5_royal_yusuke_Icon", "UI_Card_XP_persona5_royal_yusuke_Art")
        // 니지마 마코토
        call SetImages(1525, "UI_Card_XP_persona5_royal_makoto_Icon", "UI_Card_XP_persona5_royal_makoto_Art")
        // 사쿠라 후타바
        call SetImages(1526, "UI_Card_XP_persona5_royal_futaba_Icon", "UI_Card_XP_persona5_royal_futaba_Art")
        // 오쿠무라 하루
        call SetImages(1527, "UI_Card_XP_persona5_royal_haru_Icon", "UI_Card_XP_persona5_royal_haru_Art")
        // 아케치 고로
        call SetImages(1528, "UI_Card_XP_persona5_royal_akechi_Icon", "UI_Card_XP_persona5_royal_akechi_Art")
        // 요시자와
        call SetImages(1529, "UI_Card_XP_persona5_royal_yoshizawa_Icon", "UI_Card_XP_persona5_royal_yoshizawa_Art")
        // 마루키 타쿠토
        call SetImages(1530, "UI_Card_XP_persona5_royal_maruki_Icon", "UI_Card_XP_persona5_royal_maruki_Art")
        // 우리 손으로 고른 내일
        call SetImages(1571, "UI_Card_XP_persona5_royal_ending_memorial_Icon", "UI_Card_XP_persona5_royal_ending_memorial_Art")
        // 하쿠레이 레이무
        call SetImages(1572, "UI_Card_XP_hakugyokurou_reimu_Icon", "UI_Card_XP_hakugyokurou_reimu_Art")
        // 치르노
        call SetImages(1573, "UI_Card_XP_hakugyokurou_cirno_Icon", "UI_Card_XP_hakugyokurou_cirno_Art")
        // 레티 화이트록
        call SetImages(1574, "UI_Card_XP_hakugyokurou_letty_Icon", "UI_Card_XP_hakugyokurou_letty_Art")
        // 첸
        call SetImages(1575, "UI_Card_XP_hakugyokurou_chen_Icon", "UI_Card_XP_hakugyokurou_chen_Art")
        // 앨리스 마가트로이드
        call SetImages(1576, "UI_Card_XP_hakugyokurou_alice_Icon", "UI_Card_XP_hakugyokurou_alice_Art")
        // 릴리 화이트
        call SetImages(1577, "UI_Card_XP_hakugyokurou_lily_Icon", "UI_Card_XP_hakugyokurou_lily_Art")
        // 루나사 프리즘리버
        call SetImages(1578, "UI_Card_XP_hakugyokurou_lunasa_Icon", "UI_Card_XP_hakugyokurou_lunasa_Art")
        // 메를랑 프리즘리버
        call SetImages(1579, "UI_Card_XP_hakugyokurou_merlin_Icon", "UI_Card_XP_hakugyokurou_merlin_Art")
        // 리리카 프리즘리버
        call SetImages(1580, "UI_Card_XP_hakugyokurou_lyrica_Icon", "UI_Card_XP_hakugyokurou_lyrica_Art")
        // 콘파쿠 요우무
        call SetImages(1581, "UI_Card_XP_hakugyokurou_youmu_Icon", "UI_Card_XP_hakugyokurou_youmu_Art")
        // 사이교우지 유유코
        call SetImages(1582, "UI_Card_XP_hakugyokurou_yuyuko_Icon", "UI_Card_XP_hakugyokurou_yuyuko_Art")
        // 돌아온 봄의 자리
        call SetImages(1620, "UI_Card_XP_hakugyokurou_ending_memorial_Icon", "UI_Card_XP_hakugyokurou_ending_memorial_Art")
        // 하쿠레이 레이무
        call SetImages(1621, "UI_Card_XP_scarlet_mist_reimu_Icon", "UI_Card_XP_scarlet_mist_reimu_Art")
        // 루미아
        call SetImages(1622, "UI_Card_XP_scarlet_mist_rumia_Icon", "UI_Card_XP_scarlet_mist_rumia_Art")
        // 치르노
        call SetImages(1623, "UI_Card_XP_scarlet_mist_cirno_Icon", "UI_Card_XP_scarlet_mist_cirno_Art")
        // 홍 메이링
        call SetImages(1624, "UI_Card_XP_scarlet_mist_meiling_Icon", "UI_Card_XP_scarlet_mist_meiling_Art")
        // 파츄리 널릿지
        call SetImages(1625, "UI_Card_XP_scarlet_mist_patchouli_Icon", "UI_Card_XP_scarlet_mist_patchouli_Art")
        // 이자요이 사쿠야
        call SetImages(1626, "UI_Card_XP_scarlet_mist_sakuya_Icon", "UI_Card_XP_scarlet_mist_sakuya_Art")
        // 레밀리아 스칼렛
        call SetImages(1627, "UI_Card_XP_scarlet_mist_remilia_Icon", "UI_Card_XP_scarlet_mist_remilia_Art")
        // 안개 뒤에 돌아온 여름
        call SetImages(1665, "UI_Card_XP_scarlet_mist_ending_memorial_Icon", "UI_Card_XP_scarlet_mist_ending_memorial_Art")
    endfunction
endlibrary
