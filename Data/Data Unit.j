//! runtextmacro 시스템("DataUnit")
globals
    //hashtable Unithash = InitHashtable()
    //유닛어빌'색인'
    integer array UnitAbilityIndex
    //엔피씨
    unit array NPCUnit
    //영웅타입
    boolean array UnitHeroCheck
    //대쉬모션번호
    integer array UnitDashCode
    //스킬blp
    string array HeroSkillBlp0
    string array HeroSkillBlp1
    string array HeroSkillBlp2
    string array HeroSkillBlp3
    string array HeroSkillBlp4
    string array HeroSkillBlp5
    string array HeroSkillBlp6
    string array HeroSkillBlp7
    //스킬 설명
    string array HeroSkill0Text1
    string array HeroSkill0Text2
    string array HeroSkill0Text3
    string array HeroSkill1Text1
    string array HeroSkill1Text2
    string array HeroSkill1Text3
    string array HeroSkill2Text1
    string array HeroSkill2Text2
    string array HeroSkill2Text3
    string array HeroSkill3Text1
    string array HeroSkill3Text2
    string array HeroSkill3Text3
    string array HeroSkill4Text1
    string array HeroSkill4Text2
    string array HeroSkill4Text3
    string array HeroSkill5Text1
    string array HeroSkill5Text2
    string array HeroSkill5Text3
    string array HeroSkill6Text1
    string array HeroSkill6Text2
    string array HeroSkill6Text3
    string array HeroSkill7Text1
    string array HeroSkill7Text2
    string array HeroSkill7Text3
    //스킬 아이디
    integer array HeroSkillID0
    integer array HeroSkillID1
    integer array HeroSkillID2
    integer array HeroSkillID3
    integer array HeroSkillID4
    integer array HeroSkillID5
    integer array HeroSkillID6
    integer array HeroSkillID7
    integer array HeroSkillID8
    integer array HeroSkillID9
    integer array HeroSkillID10
    integer array HeroSkillID11
    
    //기초체력
    real array UnitSetHP
    //체력  체력배율,스트링
    integer array UnitHPValue
    string array UnitHPString
    real array UnitHP
    real array UnitHPMAX
    integer array UnitSetHPx
    //기초쉴드
    real array UnitSetSD
    //쉴드
    real array UnitSD
    real array UnitSDMAX
    real array UnitSDCheck
    real array UnitSetArm
    real array UnitArm
    boolean array UnitCasting
    unit array UnitCastingDummy
    real array UnitCastingSD
    real array UnitCastingSDMAX
    real array UnitTier
    //플레이어 쉴드
    real array PUnitSD
    
    integer array potion
endglobals

function DataUnitIndex takes unit u returns integer
    local integer i = GetUnitTypeId(u)
    if i == 'H000' then
        return 1
    elseif i == 'h002' then
        return 2
    elseif i == 'H003' then
        return 3
    elseif i == 'H004' then
        return 4
    elseif i == 'h005' then
        return 5
    elseif i == 'h006' then
        return 6
    elseif i == 'h007' then
        return 7
    elseif i == 'h008' then
        return 8
    elseif i == 'h00A' then
        return 9
    elseif i == 'h00C' then
        return 10
    elseif i == 'h00D' then
        return 11
    elseif i == 'h00E' then
        return 12
    endif
    return 0
endfunction
    
//! runtextmacro 이벤트_N초가_지나면_발동("A","1.0")
    //포션
    set potion[1] = 'A01R'
    set potion[2] = 'A01S'
    set potion[3] = 'A01T'
    set potion[4] = 'A01U'

    //잭
    set UnitAbilityIndex[1] = 'H000'
    set UnitHeroCheck[1] = true
    set UnitDashCode[1] = 6
    set HeroSkillBlp0[1] = "ReplaceableTextures\\CommandButtons\\BTNHero_Jack2.blp"
    set HeroSkillBlp1[1] = "ReplaceableTextures\\CommandButtons\\BTNClawsOfAttack.blp"
    set HeroSkillBlp2[1] = "ReplaceableTextures\\CommandButtons\\BTNHero_Jack.blp"
    set HeroSkillBlp3[1] = "ReplaceableTextures\\CommandButtons\\BTNHero_Jack3.blp"
    set HeroSkillBlp4[1] = "ReplaceableTextures\\CommandButtons\\BTNAmbush.blp"
    set HeroSkillBlp5[1] = ""
    set HeroSkillBlp6[1] = "ReplaceableTextures\\CommandButtons\\BTNHero_Jack4.blp"
    
    //샌드백
    set UnitAbilityIndex[2] = 'h002'
    set UnitHPValue[2] = 1
    set UnitHPString[2] = ""
    set UnitSetHP[2] = 1000000
    set UnitSetSD[2] = 1000
    set UnitSetArm[2] = 10000
    set UnitSetHPx[2] = 200
    
    //모미지
    set UnitAbilityIndex[3] = 'H003'
    set UnitHeroCheck[3] = true
    set UnitDashCode[3] = 3
    set HeroSkillBlp0[3] = "ReplaceableTextures\\CommandButtons\\BTNHero_Jack2.blp"
    set HeroSkillBlp1[3] = "ReplaceableTextures\\CommandButtons\\BTNClawsOfAttack.blp"
    set HeroSkillBlp2[3] = "ReplaceableTextures\\CommandButtons\\BTNHero_Jack.blp"
    set HeroSkillBlp3[3] = "ReplaceableTextures\\CommandButtons\\BTNHero_Jack3.blp"
    set HeroSkillBlp4[3] = "ReplaceableTextures\\CommandButtons\\BTNAmbush.blp"
    set HeroSkillBlp5[3] = "ReplaceableTextures\\CommandButtons\\BTNAmbush.blp"
    set HeroSkillBlp6[3] = "ReplaceableTextures\\CommandButtons\\BTNHero_Jack4.blp"
    set HeroSkillBlp7[3] = "ReplaceableTextures\\CommandButtons\\BTNHero_Jack4.blp"
    set HeroSkillID0[3] = 'A00Y'
    set HeroSkillID1[3] = 'A00Z'
    set HeroSkillID2[3] = 'A010'
    set HeroSkillID3[3] = 'A011'
    set HeroSkillID4[3] = 'A012'
    set HeroSkillID5[3] = 'A013'
    set HeroSkillID6[3] = 'A014'
    set HeroSkillID7[3] = 'A015'
    set HeroSkillID8[3] = 'A016'
    set HeroSkill0Text1[3] = "스킬 적중 시 3.0초간 자신에게 발도버프를 생성한다."
    set HeroSkill0Text2[3] = "스킬 시전 시 4.0초간 자신의 이동속도가 30.0% 증가한다." 
    set HeroSkill0Text3[3] = "적에게 주는 피해가 105.0% 증가된다."
    set HeroSkill1Text1[3] = "스킬 적중 시 3.0초간 자신에게 발도버프를 생성한다."
    set HeroSkill1Text2[3] = "스킬 시전 시 지점 방향으로 돌진하며, 적에게 주는 피해가 45.0% 증가된다."
    set HeroSkill1Text3[3] = "공격 적중 시 적의 모든 방어력을 80.0% 무시한다."
    set HeroSkill2Text1[3] = "재사용 대기시간이 11.0초 감소한다."
    set HeroSkill2Text2[3] = "적에게 주는 피해가 70.0% 증가한다."
    set HeroSkill2Text3[3] = "적에게 주는 피해가 80.0% 증가한다."
    set HeroSkill3Text1[3] = "공격 적중 시 대상이 자신 및 파티원에게 받는 치명타 저항률이 12.0초간 10.0% 감소한다."
    set HeroSkill3Text2[3] = "적에게 주는 피해가 60.0% 증가한다."
    set HeroSkill3Text3[3] = "적에게 주는 피해가 70.0% 증가한다."
    set HeroSkill4Text1[3] = "공격속도가 18.0% 증가한다."
    set HeroSkill4Text2[3] = "발도 버프를 가지고 있으면, 버프를 제거하고 적에게 주는 피해가 95.0% 증가한다."
    set HeroSkill4Text3[3] = "적에게 주는 피해가 105.0% 증가한다."
    set HeroSkill5Text1[3] = "공격속도가 50.0% 증가하고, 재사용 대기 시간이 5.0초 감소한다."
    set HeroSkill5Text2[3] = "치명타 피해가 180.0% 증가한다."
    set HeroSkill5Text3[3] = "적에게 주는 피해가 95.0% 증가한다."
    set HeroSkill6Text1[3] = "적에게 주는 피해가 45.0% 증가한다."
    set HeroSkill6Text2[3] = "발도 버프를 가지고 있으면, 버프를 제거하고 적에게 주는 피해가 95.0% 증가한다."
    set HeroSkill6Text3[3] = "치명타 피해가 210.0% 증가한다."
    set HeroSkill7Text1[3] = "발도 버프를 가지고 있으면, 버프를 제거하고 적에게 주는 피해가 60.0% 증가한다."
    set HeroSkill7Text2[3] = "적에게 주는 피해가 60.0% 증가한다."
    set HeroSkill7Text3[3] = "적에게 주는 피해가 95.0% 증가한다."
    
    //챈
    set UnitAbilityIndex[4] = 'H004'
    set UnitHeroCheck[4] = true
    set UnitDashCode[4] = 9
    set HeroSkillBlp0[4] = "ReplaceableTextures\\CommandButtons\\BTNHero_Jack2.blp"
    set HeroSkillBlp1[4] = "ReplaceableTextures\\CommandButtons\\BTNClawsOfAttack.blp"
    set HeroSkillBlp2[4] = "ReplaceableTextures\\CommandButtons\\BTNHero_Jack.blp"
    set HeroSkillBlp3[4] = "ReplaceableTextures\\CommandButtons\\BTNHero_Jack3.blp"
    set HeroSkillBlp4[4] = "ReplaceableTextures\\CommandButtons\\BTNAmbush.blp"
    set HeroSkillBlp5[4] = "ReplaceableTextures\\CommandButtons\\BTNAmbush.blp"
    set HeroSkillBlp6[4] = "ReplaceableTextures\\CommandButtons\\BTNHero_Jack4.blp"
    set HeroSkillBlp7[4] = "ReplaceableTextures\\CommandButtons\\BTNHero_Jack4.blp"
    set HeroSkillID0[4] = 'A01A'
    set HeroSkillID1[4] = 'A017'
    set HeroSkillID2[4] = 'A019'
    set HeroSkillID3[4] = 'A01C'
    set HeroSkillID4[4] = 'A01E'
    set HeroSkillID5[4] = 'A018'
    set HeroSkillID6[4] = 'A01D'
    set HeroSkillID7[4] = 'A01B'
    set HeroSkillID8[4] = 'A01F'
    set HeroSkillID9[4] = 'A028'

    set HeroSkill0Text1[4] = "공격속도가 27.0% 증가한다."
    set HeroSkill0Text2[4] = "적에게 주는 피해가 70.0% 증가한다."
    set HeroSkill0Text3[4] = "차지 조작으로 변경된다.　　　　　　2단계 차지 시 총 52.5%의 증가된 피해를 주며, 풀 차지 시 총 150.0%의 증가된 피해를 주지만, 1단계 차지 시 피해가 20.0% 감소된다."
    set HeroSkill1Text1[4] = "스킬 사용시 50.0% 확률로 재사용 대기시간이 4.9초 감소된다."
    set HeroSkill1Text2[4] = "적에게 주는 피해가 50.0% 증가된다." 
    set HeroSkill1Text3[4] = "적에게 주는 피해가 100.0% 증가된다."
    set HeroSkill2Text1[4] = "재사용 대기시간이 5.6초 감소한다."
    set HeroSkill2Text2[4] = "적에게 주는 피해가 70.0% 증가한다."
    set HeroSkill2Text3[4] = "적에게 주는 피해가 159.5% 증가한다."
    set HeroSkill3Text1[4] = "적에게 주는 피해가 50.0% 증가한다."
    set HeroSkill3Text2[4] = "차지 단계가 올라갈수록 공격력이 30.0% 상승한다."
    set HeroSkill3Text3[4] = "풀 차지 시 적에게 주는 피해가 122% 증가한다."
    set HeroSkill4Text1[4] = "재사용 대기시간이 8.0초 감소한다."
    set HeroSkill4Text2[4] = "보호막 지속 시간이 6.0초 증가한다."
    set HeroSkill4Text3[4] = "보호막 수치가 자신의 최대 생명력의 40%로 변경된다."
    set HeroSkill5Text1[4] = ""
    set HeroSkill5Text2[4] = ""
    set HeroSkill5Text3[4] = ""
    set HeroSkill6Text1[4] = "공격에 적중된 적들의 방어력을 10.0초간 12.0% 감소시키고, 공격 적중 시 자신의 공격력이 10.0초간 35% 증가한다."
    set HeroSkill6Text2[4] = "3.0초간 자신의 최대 생명력의 30.0% 만큼 보호막을 생성한다."
    set HeroSkill6Text3[4] = "12.0초간 약점을 노출시켜 헤드 어택 및 백 어택의 경우, 받는 피해 효과 12.0% 증가한다."
    set HeroSkill7Text1[4] = "적에게 주는 피해가 100.0% 증가한다."
    set HeroSkill7Text2[4] = "풀 차지 시 마지막 공격의 피해가 100% 증가한다."
    set HeroSkill7Text3[4] = "풀 차지 시 마지막 공격의 피해가 89.1% 증가한다."


    //사신짱
    set UnitAbilityIndex[5] = 'h005'
    set UnitHeroCheck[5] = false
    set NPCUnit[5]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h005', -28831, 28813, 319)
    call CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e01M',-28831, 28813, 270)
    
    //세레스티아 루덴베르크
    set UnitAbilityIndex[6] = 'h006'
    set UnitHeroCheck[6] = false
    set NPCUnit[6]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h006', -28958, 28380, 335)
    call CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e01K', -28958, 28380, 270)
    
    //라이자
    set UnitAbilityIndex[7] = 'h007'
    set UnitHeroCheck[7] = false
    set NPCUnit[7]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h007', -27445, 28849, 270)
    call CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e01L',-27445, 28849, 270)
    
    //반격
    set UnitAbilityIndex[8] = 'h008'
    set UnitHPValue[8] = 1
    set UnitHPString[8] = ""
    set UnitSetHP[8] = 100000000
    set UnitSetSD[8] = 100000000
    set UnitSetArm[8] = 10000
    set UnitSetHPx[8] = 1
    set UnitTier[8] = 5
    
    //나히다
    set UnitAbilityIndex[9] = 'h00A'
    set UnitHeroCheck[9] = false
    set NPCUnit[9]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h00A', -29000, 27654, 344)
    call CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e01N',-29000, 27654, 270)
    
    //아즈사
    set UnitAbilityIndex[10] = 'h00C'
    set UnitHeroCheck[10] = false
    //set NPCUnit[10]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h00C', -27500, 27900, 244)
    set NPCUnit[10]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h00C', -26022, 28784, 244)
    call CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e01P',-26022, 28784, 270)
    
    //치카
    set UnitAbilityIndex[11] = 'h00D'
    set UnitHeroCheck[11] = false
    set NPCUnit[11]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h00D', -25733, 28486, 228)
    call CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e01O',-25733, 28486, 270)
    
    //미카
    set UnitAbilityIndex[12] = 'h00E'
    set UnitHeroCheck[12] = false
    set NPCUnit[12]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h00E', -27500, 27900, 244)
    call CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e01R',-27500, 27900, 270)

//! runtextmacro 이벤트_끝()
//! runtextmacro 시스템_끝()