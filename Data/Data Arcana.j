//! runtextmacro 시스템("DataArcana")
globals
    string array Arcana
    string array ArcanaText
    string array ArcanaText2
endglobals
    
//! runtextmacro 이벤트_N초가_지나면_발동("A","1.0")
    //저받
    //각성기의 재사용 대기시간이 10% / 25% / 50% 감소한다.
    set Arcana[0] = "ReplaceableTextures\\CommandButtons\\BTNArcana00.blp"
    set ArcanaText[0] = "저받"
    set ArcanaText2[0] = "적에게 주는 피해가 11 / 14 / 17 % 증가하지만, 받는 생명력 회복 효과가 25% 감소한다."
    //돌대 
    //이동속도 증가량의 32 / 40 / 48% 만큼 적에게 주는 피해량이 증가한다.
    set Arcana[1] = "ReplaceableTextures\\CommandButtons\\BTNArcana01.blp"
    set ArcanaText[1] = "돌대"
    set ArcanaText2[1] = "이동속도 증가량의 32 / 40 / 48% 만큼 적에게 주는 피해량이 증가한다."
    //사멸
    //적에게 주는 피해가 4 / 4.8 / 7.6% 증가하며 백 어택 및 헤드 어택성공 시 피해량이 추가로 12 / 15 / 15 증가한다.
    set Arcana[2] = "ReplaceableTextures\\CommandButtons\\BTNArcana02.blp"
    set ArcanaText[2] = "사멸"
    set ArcanaText2[2] = "적에게 주는 피해가 4 / 4.8 / 7.6% 증가하며 헤드어택 성공 시 피해량이 추가로 12 / 15 / 15 증가한다."
    //타대
    //공격 타입이 백 어택 및 헤드 어택에 해당되지 않는 공격의 피해가 11 / 14 / 17% 증가한다. 각성기는 해당 효과가 적용되지 않는다.
    set Arcana[3] = "ReplaceableTextures\\CommandButtons\\BTNArcana03.blp"
    set ArcanaText[3] = "타대"
    set ArcanaText2[3] = "공격 타입이 백 어택 및 헤드 어택에 해당되지 않는 공격의 피해가 11 / 14 / 17% 증가한다. 각성기는 해당 효과가 적용되지 않는다."
    //바리
    //실드 효과가 적용되는 동안 적에게 입히는 피해가 11 / 14 / 17% 증가한다.
    set Arcana[4] = "ReplaceableTextures\\CommandButtons\\BTNArcana04.blp"
    set ArcanaText[4] = "바리"
    set ArcanaText2[4] = "실드 효과가 적용되는 동안 적에게 입히는 피해가 11 / 14 / 17% 증가한다."
    //슈차 
    //차지 스킬의 차징 속도가 32 / 40 / 40% 증가하고, 피해량이 16 / 18 / 21 % 증가한다.
    set Arcana[5] = "ReplaceableTextures\\CommandButtons\\BTNArcana05.blp"
    set ArcanaText[5] = "슈차"
    set ArcanaText2[5] = "차지 스킬의 차징 속도가 32 / 40 / 40% 증가하고, 피해량이 16 / 18 / 21 % 증가한다."
    //질증
    //공격속도가 10% 감소하지만 적에게 주는 피해가 13 / 16 / 19% 증가한다.
    set Arcana[6] = "ReplaceableTextures\\CommandButtons\\BTNArcana06.blp"
    set ArcanaText[6] = "질증"
    set ArcanaText2[6] = "공격속도가 10% 감소하지만 적에게 주는 피해가 13 / 16 / 19% 증가한다."
    //정단
    //치명타 적중률이 15 / 18 / 21% 증가하지만 치명타 피해가 6% 감소한다.
    set Arcana[7] = "ReplaceableTextures\\CommandButtons\\BTNArcana06.blp"
    set ArcanaText[7] = "정단"
    set ArcanaText2[7] = "치명타 적중률이 15 / 18 / 21% 증가하지만 치명타 피해가 6% 감소한다."
    //안상
    //내 생명력이 65% 이상일 때 주는 피해가 11 / 14 / 17% 증가한다.
    set Arcana[8] = "ReplaceableTextures\\CommandButtons\\BTNArcana06.blp"
    set ArcanaText[8] = "안상"
    set ArcanaText2[8] = "내 생명력이 65% 이상일 때 주는 피해가 11 / 14 / 17% 증가한다."
    //원한
    //보스 및 레이드 몬스터에게 주는 피해가 15 / 18 / 21% 증가하지만, 방어등급이 1단계 감소한다.
    set Arcana[9] = "ReplaceableTextures\\CommandButtons\\BTNArcana06.blp"
    set ArcanaText[9] = "원한"
    set ArcanaText2[9] = "보스 및 레이드 몬스터에게 주는 피해가 15 / 18 / 21% 증가하지만, 방어등급이 1단계 감소한다."
    //예둔
    //치명타 피해량이 36 / 44 / 52% 증가하지만, 공격 시 10% 확률로 20% 감소된 피해를 준다.
    set Arcana[10] = "ReplaceableTextures\\CommandButtons\\BTNArcana06.blp"
    set ArcanaText[10] = "예둔"
    set ArcanaText2[10] = "치명타 피해량이 36 / 44 / 52% 증가하지만, 공격 시 10% 확률로 20% 감소된 피해를 준다."

    
    //공격력 감소
    //공격력이 0/2/4/8/16% 감소한다.
    set Arcana[50] = "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp"
    set ArcanaText[50] = "공격력 감소"
    set ArcanaText2[50] = "공격력이 0/2/4/8/16% 감소한다."
    //체력 감소
    //체력이 0/5/10/15/30% 감소한다
    set Arcana[51] = "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp"
    set ArcanaText[51] = "체력 감소"
    set ArcanaText2[51] = "체력이 0/5/10/15/30% 감소한다"
    //공격속도 감소
    //공격속도가 0/2/4/8/16% 감소한다.
    set Arcana[52] = "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp"
    set ArcanaText[52] = "공격속도 감소"
    set ArcanaText2[52] = "공격속도가 0/2/4/8/16% 감소한다."
    //이동속도 감소
    //이동속도가 0/2/4/8/16% 감소한다.
    set Arcana[53] = "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp"
    set ArcanaText[53] = "이동속도 감소"
    set ArcanaText2[53] = "이동속도가 0/2/4/8/16% 감소한다."
    
    
//! runtextmacro 이벤트_끝()
//! runtextmacro 시스템_끝()