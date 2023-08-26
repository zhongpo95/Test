//! runtextmacro 시스템("DataArcana")
globals
    string array Arcana
    string array ArcanaText
    string array ArcanaText2
endglobals
    
//! runtextmacro 이벤트_맵이_로딩되면_발동()
    //광대
    //각성 
    //각성기의 재사용 대기시간이 10% / 25% / 50% 감소한다.
    set Arcana[0] = "ReplaceableTextures\\CommandButtons\\BTNArcana00.blp"
    set ArcanaText[0] = "광대"
    set ArcanaText2[0] = "각성기의 재사용 대기시간이 10% / 25% / 50% 감소한다."
    //마술사
    //돌격대장 
    //이동속도 증가량의 10% / 22% / 45% 만큼 적에게 주는 피해량이 증가한다
    set Arcana[1] = "ReplaceableTextures\\CommandButtons\\BTNArcana01.blp"
    set ArcanaText[1] = "마술사"
    set ArcanaText2[1] = "이동속도 증가량의 10% / 22% / 45% 만큼 적에게 주는 피해량이 증가한다"
    //교황
    //급소 타격 
    //무력화 공격 시 주는 무력화 수치가 6% / 18% / 36% 증가한다.
    set Arcana[2] = "ReplaceableTextures\\CommandButtons\\BTNArcana02.blp"
    set ArcanaText[2] = "교황"
    set ArcanaText2[2] = "무력화 공격 시 주는 무력화 수치가 6% / 18% / 36% 증가한다."
    //여제
    //타격의 대가
    //공격 타입이 백 어택 및 헤드 어택에 해당되지 않는 공격의 피해가 3% / 8% / 16% 증가한다.
    set Arcana[3] = "ReplaceableTextures\\CommandButtons\\BTNArcana03.blp"
    set ArcanaText[3] = "여제"
    set ArcanaText2[3] = "공격 타입이 백 어택 및 헤드 어택에 해당되지 않는 공격의 피해가 3% / 8% / 16% 증가한다."
    //황제
    //결투의 대가 
    //헤드어택 성공 시 피해량이 추가로 5% / 12% / 25% 증가한다.
    set Arcana[4] = "ReplaceableTextures\\CommandButtons\\BTNArcana04.blp"
    set ArcanaText[4] = "황제"
    set ArcanaText2[4] = "헤드어택 성공 시 피해량이 추가로 5% / 12% / 25% 증가한다."
    //법황
    //바리케이드 
    //실드 효과가 적용되는 동안 적에게 입히는 피해가 3% / 8% / 16% 증가한다
    set Arcana[5] = "ReplaceableTextures\\CommandButtons\\BTNArcana05.blp"
    set ArcanaText[5] = "법황"
    set ArcanaText2[5] = "실드 효과가 적용되는 동안 적에게 입히는 피해가 3% / 8% / 16% 증가한다."
    //연인
    set Arcana[6] = "ReplaceableTextures\\CommandButtons\\BTNArcana06.blp"
    set ArcanaText[6] = "연인"
    set ArcanaText2[6] = ""
    //전차
    //슈퍼 차지 
    //차지 스킬의 차징 속도가 8% / 20% / 40% 증가하고, 피해량이 4% / 10% / 20% 증가한다.
    set Arcana[7] = "ReplaceableTextures\\CommandButtons\\BTNArcana07.blp"
    set ArcanaText[7] = "전차"
    set ArcanaText2[7] = "차지 스킬의 차징 속도가 8% / 20% / 40% 증가하고, 피해량이 4% / 10% / 20% 증가한다."
    //힘
    //질량 증가 
    //공격속도가 10% 감소하지만 공격력이 4% / 10% / 18% 증가한다.
    set Arcana[8] = "ReplaceableTextures\\CommandButtons\\BTNArcana08.blp"
    set ArcanaText[8] = "힘"
    set ArcanaText2[8] = "공격속도가 10% 감소하지만 공격력이 4% / 10% / 18% 증가한다."
    //은둔자
    //기습의 대가 
    //백어택 성공 시 피해량이 추가로 5% / 12% / 25% 증가한다.
    set Arcana[9] = "ReplaceableTextures\\CommandButtons\\BTNArcana09.blp"
    set ArcanaText[9] = "은둔자"
    set ArcanaText2[9] = "백어택 성공 시 피해량이 추가로 5% / 12% / 25% 증가한다."
    //운명
    set Arcana[10] = "ReplaceableTextures\\CommandButtons\\BTNArcana10.blp"
    set ArcanaText[10] = "운명"
    set ArcanaText2[10] = ""
    //정의
    set Arcana[11] = "ReplaceableTextures\\CommandButtons\\BTNArcana11.blp"
    set ArcanaText[11] = "정의"
    set ArcanaText2[11] = ""
    //사형수
    //약자 무시 
    //생명력이 30% 이하인 적 타격시 주는 피해가 9% / 22% / 36% 증가한다.
    set Arcana[12] = "ReplaceableTextures\\CommandButtons\\BTNArcana12.blp"
    set ArcanaText[12] = "사형수"
    set ArcanaText2[12] = "생명력이 30% 이하인 적 타격시 주는 피해가 9% / 22% / 36% 증가한다."
    //죽음
    //예리한 둔기 
    //치명타 피해량이 10% / 25% / 50% 증가하지만, 공격 시 10% 확률로 20% 감소된 피해를 준다.
    set Arcana[13] = "ReplaceableTextures\\CommandButtons\\BTNArcana13.blp"
    set ArcanaText[13] = "죽음"
    set ArcanaText2[13] = "치명타 피해량이 10% / 25% / 50% 증가하지만, 공격 시 10% 확률로 20% 감소된 피해를 준다."
    //절제
    //아드레날린 
    //이동기 및 기본공격을 제외한 스킬 사용 후 6초 동안 공격력이 0.3% / 0.6% / 1.0% 증가하며 (최대 6중첩) 해당 효과가 최대 중첩 도달 시 치명타 적중률이 추가로 5% / 10% / 15% 증가한다.
    //해당 효과는 스킬 취소에 따른 재사용 대기시간 감소가 적용되는 경우, 스킬 종료 후 적용된다.
    set Arcana[14] = "ReplaceableTextures\\CommandButtons\\BTNArcana14.blp"
    set ArcanaText[14] = "절제"
    set ArcanaText2[14] = "이동기를 제외한 스킬 사용 후 6초 동안 공격력이 0.3% / 0.6% / 1.0% 증가하며 (최대 6중첩) 해당 효과가 최대 중첩 도달 시 치명타 적중률이 추가로 5% / 10% / 15% 증가한다.|n해당 효과는 스킬 취소에 따른 재사용 대기시간 감소가 적용되는 경우, 스킬 종료 후 적용된다."
    //악마
    //정밀 단도
    //치명타 적중률이 4% / 10% / 20% 증가하지만 치명타 피해가 12% 감소한다.
    set Arcana[15] = "ReplaceableTextures\\CommandButtons\\BTNArcana15.blp"
    set ArcanaText[15] = "악마"
    set ArcanaText2[15] = "치명타 적중률이 4% / 10% / 20% 증가하지만 치명타 피해가 12% 감소한다."
    //탑
    //중갑 착용
    //체력이 15% / 37% / 75% 증가한다.
    set Arcana[16] = "ReplaceableTextures\\CommandButtons\\BTNArcana16.blp"
    set ArcanaText[16] = "탑"
    set ArcanaText2[16] = "체력이 15% / 37% / 75% 증가한다."
    //별
    //추진력
    //이동기 사용 후 5초 동안 기본공격 및 각성기를 제외한 스킬의 피해가 3% / 8% / 16% 증가한다.
    set Arcana[17] = "ReplaceableTextures\\CommandButtons\\BTNArcana18.blp"
    set ArcanaText[17] = "별"
    set ArcanaText2[17] = "이동기 사용 후 5초 동안 스킬의 피해가 3% / 8% / 16% 증가한다."
    //달
    //안정된 상태
    //내 생명력이 80% 이상일 때 주는 피해가 3% / 8% / 16% 증가한다
    set Arcana[18] = "ReplaceableTextures\\CommandButtons\\BTNArcana17.blp"
    set ArcanaText[18] = "달"
    set ArcanaText2[18] = "내 생명력이 80% 이상일 때 주는 피해가 3% / 8% / 16% 증가한다"
    //태양
    //저주받은 인형
    //공격력이 3% / 8% / 16% 증가하지만, 받는 모든 회복 효과가 25% 감소한다.
    set Arcana[19] = "ReplaceableTextures\\CommandButtons\\BTNArcana19.blp"
    set ArcanaText[19] = "태양"
    set ArcanaText2[19] = "공격력이 3% / 8% / 16% 증가하지만, 받는 모든 회복 효과가 25% 감소한다."
    //심판
    //부러진 뼈 
    //무력화 중인 대상에게 주는 피해가 7.5% / 20% / 40% 증가한다.
    set Arcana[20] = "ReplaceableTextures\\CommandButtons\\BTNArcana20.blp"
    set ArcanaText[20] = "심판"
    set ArcanaText2[20] = "무력화 중인 대상에게 주는 피해가 7.5% / 20% / 40% 증가한다."
    //세계
    //정기 흡수
    //공격 및 이동속도가 3% / 8% / 16% 증가한다
    set Arcana[21] = "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp"
    set ArcanaText[21] = "세계"
    set ArcanaText2[21] = "공격 및 이동속도가 3% / 8% / 16% 증가한다."
    
    //공격력 감소
    //공격력이 2/4/6% 감소한다.
    set Arcana[22] = "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp"
    set ArcanaText[22] = "공격력 감소"
    set ArcanaText2[22] = "공격력이 2/4/6% 감소한다."
    //공격속도 감소
    //공격속도가 2/4/6% 감소한다.
    set Arcana[23] = "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp"
    set ArcanaText[23] = "공격속도 감소"
    set ArcanaText2[23] = "공격속도가 2/4/6% 감소한다."
    //체력 감소
    //체력이 5/10/15% 감소한다
    set Arcana[24] = "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp"
    set ArcanaText[24] = "체력 감소"
    set ArcanaText2[24] = "체력이 5/10/15% 감소한다"
    //이동속도 감소
    //이동속도가 2/4/6% 감소한다.
    set Arcana[25] = "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp"
    set ArcanaText[25] = "이동속도 감소"
    set ArcanaText2[25] = "이동속도가 2/4/6% 감소한다."
    
    
//! runtextmacro 이벤트_끝()
//! runtextmacro 시스템_끝()