//! runtextmacro 시스템("DataArcana")
globals
    hashtable ArcanaData = InitHashtable()
    string array Arcana
    string array ArcanaText
    string array ArcanaText2
endglobals
    
//! runtextmacro 이벤트_N초가_지나면_발동("A","1.0")
    //각성 
    //각성기의 재사용 대기시간이 10% / 25% / 50% 감소한다.
    set Arcana[0] = "ReplaceableTextures\\CommandButtons\\BTNArcana00.blp"
    set ArcanaText[0] = "각성"
    set ArcanaText2[0] = "각성기의 재사용 대기시간이 10% / 25% / 50% 감소한다."
    //신속정확 
    //이동속도 증가량의 10% / 22% / 45% 만큼 적에게 주는 피해량이 증가한다
    set Arcana[1] = "ReplaceableTextures\\CommandButtons\\BTNArcana01.blp"
    set ArcanaText[1] = "신속정확"
    set ArcanaText2[1] = "이동속도 증가량의 10% / 22% / 45% 만큼 적에게 주는 피해량이 증가한다"
    //타격의 대가
    //백 어택 및 헤드 어택에 해당되지 않는 공격의 피해가 3% / 8% / 16% 증가한다..
    set Arcana[2] = "ReplaceableTextures\\CommandButtons\\BTNArcana02.blp"
    set ArcanaText[2] = "타격의 대가"
    set ArcanaText2[2] = "백 어택 및 헤드 어택에 해당되지 않는 공격의 피해가 3% / 8% / 16% 증가한다."
    //빈틈공격
    //공격 타입이 백 어택 및 헤드 어택에 해당되지 않는 공격의 피해가 3% / 8% / 16% 증가한다.
    set Arcana[3] = "ReplaceableTextures\\CommandButtons\\BTNArcana03.blp"
    set ArcanaText[3] = "빈틈공격"
    set ArcanaText2[3] = "백 어택 및 헤드 어택 성공 시 피해량이 추가로 5% / 12% / 25% 증가한다."
    //실드 브레이커
    //헤드어택 성공 시 피해량이 추가로 5% / 12% / 25% 증가한다.
    set Arcana[4] = "ReplaceableTextures\\CommandButtons\\BTNArcana04.blp"
    set ArcanaText[4] = "실드 브레이커"
    set ArcanaText2[4] = "실드 효과가 적용되는 동안 적에게 입히는 피해가 3% / 8% / 16% 증가한다."
    //바리케이드 
    //차지 스킬의 차징 속도가 8% / 20% / 40% 증가하고, 피해량이 4% / 10% / 20% 증가한다.
    set Arcana[5] = "ReplaceableTextures\\CommandButtons\\BTNArcana05.blp"
    set ArcanaText[5] = "슈퍼 차지"
    set ArcanaText2[5] = "차지 스킬의 차징 속도가 8% / 20% / 40% 증가하고, 피해량이 4% / 10% / 20% 증가한다."
    //묵직한 일격
    //공격속도가 12% 감소하지만 공격력이 4% / 10% / 18% 증가한다.
    set Arcana[6] = "ReplaceableTextures\\CommandButtons\\BTNArcana06.blp"
    set ArcanaText[6] = "묵직한 일격"
    set ArcanaText2[6] = "공격속도가 12% 감소하지만 피해량이 4% / 10% / 18% 증가한다."
    //사형수
    //생명력이 30% 이하인 적 타격시 주는 피해가 8% / 20% / 36% 증가한다.
    set Arcana[7] = "ReplaceableTextures\\CommandButtons\\BTNArcana07.blp"
    set ArcanaText[7] = "사형수"
    set ArcanaText2[7] = "생명력이 30% 이하인 적 타격시 주는 피해가 8% / 20% / 36% 증가한다."
    //죽음 
    //치명타 피해량이 10% / 25% / 50% 증가하지만, 공격 시 10% 확률로 20% 감소된 피해를 준다.
    set Arcana[8] = "ReplaceableTextures\\CommandButtons\\BTNArcana08.blp"
    set ArcanaText[8] = "죽음"
    set ArcanaText2[8] = "치명타 피해량이 10% / 25% / 50% 증가하지만, 공격 시 10% 확률로 20% 감소된 피해를 준다."
    //악마
    //치명타 적중률이 4% / 10% / 20% 증가하지만 치명타 피해가 12% 감소한다.
    set Arcana[9] = "ReplaceableTextures\\CommandButtons\\BTNArcana09.blp"
    set ArcanaText[9] = "악마"
    set ArcanaText2[9] = "치명타 적중률이 4% / 10% / 20% 증가하지만 치명타 피해가 12% 감소한다."
    //빛의 사수
    //이동기 사용 후 5초 동안 스킬의 피해가 3% / 8% / 16% 증가한다.
    set Arcana[10] = "ReplaceableTextures\\CommandButtons\\BTNArcana10.blp"
    set ArcanaText[10] = "빛의 사수"
    set ArcanaText2[10] = "이동기 사용 후 5초 동안 스킬의 피해가 3% / 8% / 16% 증가한다."
    //안정된 상태
    //내 생명력이 80% 이상일 때 주는 피해가 3% / 8% / 16% 증가한다.
    set Arcana[11] = "ReplaceableTextures\\CommandButtons\\BTNArcana11.blp"
    set ArcanaText[11] = "안정된 상태"
    set ArcanaText2[11] = "내 생명력이 80% 이상일 때 주는 피해가 3% / 8% / 16% 증가한다."
    //저주받은 계약
    //피해량이 3% / 8% / 16% 증가하지만, 받는 모든 회복 효과가 25% 감소한다.
    set Arcana[12] = "ReplaceableTextures\\CommandButtons\\BTNArcana12.blp"
    set ArcanaText[12] = "저주받은 계약"
    set ArcanaText2[12] = "피해량이 3% / 8% / 16% 증가하지만, 받는 모든 회복 효과가 25% 감소한다."
    //가속
    //공격 및 이동속도가 3% / 8% / 16% 증가한다.
    set Arcana[13] = "ReplaceableTextures\\CommandButtons\\BTNArcana13.blp"
    set ArcanaText[13] = "가속"
    set ArcanaText2[13] = "공격 및 이동속도가 3% / 8% / 16% 증가한다."
    //세계
    //받는피해가 20% 증가하지만, 스킬의 피해가 4% / 10% / 18% 증가한다.
    set Arcana[14] = "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp"
    set ArcanaText[14] = "세계"
    set ArcanaText2[14] = "방어등급이 1등급 감소하지만, 스킬의 피해가 4% / 10% / 18% 증가한다."


    set Arcana[14] = "ReplaceableTextures\\CommandButtons\\BTNArcana14.blp"
    set ArcanaText[14] = "절제"
    set ArcanaText2[14] = "이동기를 제외한 스킬 사용 후 6초 동안 공격력이 0.3% / 0.6% / 1.0% 증가하며 (최대 6중첩) 해당 효과가 최대 중첩 도달 시 치명타 적중률이 추가로 5% / 10% / 15% 증가한다.|n해당 효과는 스킬 취소에 따른 재사용 대기시간 감소가 적용되는 경우, 스킬 종료 후 적용된다."
    set Arcana[15] = "ReplaceableTextures\\CommandButtons\\BTNArcana15.blp"
    set ArcanaText[15] = "악마"
    set ArcanaText2[15] = ""
    set Arcana[16] = "ReplaceableTextures\\CommandButtons\\BTNArcana16.blp"
    set ArcanaText[16] = "탑"
    set ArcanaText2[16] = ""
    set Arcana[17] = "ReplaceableTextures\\CommandButtons\\BTNArcana18.blp"
    set ArcanaText[17] = "별"
    set ArcanaText2[17] = ""
    set Arcana[18] = "ReplaceableTextures\\CommandButtons\\BTNArcana17.blp"
    set ArcanaText[18] = "달"
    set ArcanaText2[18] = ""
    set Arcana[19] = "ReplaceableTextures\\CommandButtons\\BTNArcana19.blp"
    set ArcanaText[19] = "태양"
    set ArcanaText2[19] = ""
    set Arcana[20] = "ReplaceableTextures\\CommandButtons\\BTNArcana20.blp"
    set ArcanaText[20] = "심판"
    set ArcanaText2[20] = ""
    set Arcana[21] = "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp"
    set ArcanaText[21] = "세계"
    set ArcanaText2[21] = ""
    
    //공격력 감소
    //공격력이 2/4/6% 감소한다.
    set Arcana[50] = "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp"
    set ArcanaText[50] = "공격력 감소"
    set ArcanaText2[50] = "공격력이 2/4/6% 감소한다."
    //공격속도 감소
    //공격속도가 2/4/6% 감소한다.
    set Arcana[51] = "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp"
    set ArcanaText[51] = "공격속도 감소"
    set ArcanaText2[51] = "공격속도가 2/4/6% 감소한다."
    //체력 감소
    //체력이 5/10/15% 감소한다
    set Arcana[52] = "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp"
    set ArcanaText[52] = "체력 감소"
    set ArcanaText2[52] = "체력이 5/10/15% 감소한다"
    //이동속도 감소
    //이동속도가 2/4/6% 감소한다.
    set Arcana[53] = "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp"
    set ArcanaText[53] = "이동속도 감소"
    set ArcanaText2[53] = "이동속도가 2/4/6% 감소한다."
    
    
//! runtextmacro 이벤트_끝()
//! runtextmacro 시스템_끝()