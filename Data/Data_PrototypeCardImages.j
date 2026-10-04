// 확보한 캐릭터 원본의 얼굴 아이콘과 큰 카드 일러스트 경로를 등록한다.
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
        call SetImages(13, "UI_Card_FSN_ch01_Icon", "UI_Card_FSN_ch01_Art")
        // 세이버
        call SetImages(14, "UI_Card_FSN_ch02_Icon", "UI_Card_FSN_ch02_Art")
        // 토오사카 린
        call SetImages(16, "UI_Card_FSN_ch03_Icon", "UI_Card_FSN_ch03_Art")
        // 아처
        call SetImages(17, "UI_Card_FSN_ch04_Icon", "UI_Card_FSN_ch04_Art")
        // 어새신
        call SetImages(18, "UI_Card_FSN_ch13_Icon", "UI_Card_FSN_ch13_Art")
        // 마토 사쿠라
        call SetImages(19, "UI_Card_FSN_ch05_Icon", "UI_Card_FSN_ch05_Art")
        // 캐스터
        call SetImages(20, "UI_Card_FSN_ch12_Icon", "UI_Card_FSN_ch12_Art")
        // 후지무라 타이가
        call SetImages(21, "UI_Card_FSN_ch14_Icon", "UI_Card_FSN_ch14_Art")
        // 랜서
        call SetImages(26, "UI_Card_FSN_ch06_Icon", "UI_Card_FSN_ch06_Art")
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
        // 카나메 마도카
        call SetImages(294, "UI_Card_PMM_madoka_Icon", "UI_Card_PMM_madoka_Art")
        // 토모에 마미
        call SetImages(295, "UI_Card_PMM_mami_Icon", "UI_Card_PMM_mami_Art")
        // 아케미 호무라
        call SetImages(296, "UI_Card_PMM_homura_Icon", "UI_Card_PMM_homura_Art")
        // 미키 사야카
        call SetImages(297, "UI_Card_PMM_sayaka_Icon", "UI_Card_PMM_sayaka_Art")
        // 사쿠라 쿄코
        call SetImages(298, "UI_Card_PMM_kyoko_Icon", "UI_Card_PMM_kyoko_Art")
        // 큐베
        call SetImages(299, "UI_Card_PMM_kyube_Icon", "UI_Card_PMM_kyube_Art")
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
    endfunction
endlibrary
