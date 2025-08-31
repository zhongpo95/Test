library DataUnit initializer init

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
    //컷인스트링
    string array UnitCutString
    //컷인사운드
    sound array UnitCutSound
    //스킬blp
    string array HeroSkillBlp0
    string array HeroSkillBlp1
    string array HeroSkillBlp2
    string array HeroSkillBlp3
    string array HeroSkillBlp4
    string array HeroSkillBlp5
    string array HeroSkillBlp6
    string array HeroSkillBlp7
    //스킬타입
    string array HeroSkillTpye0
    string array HeroSkillTpye1
    string array HeroSkillTpye2
    string array HeroSkillTpye3
    string array HeroSkillTpye4
    string array HeroSkillTpye5
    string array HeroSkillTpye6
    string array HeroSkillTpye7
    //스킬설명
    string array HeroSkillStr0
    string array HeroSkillStr1
    string array HeroSkillStr2
    string array HeroSkillStr3
    string array HeroSkillStr4
    string array HeroSkillStr5
    string array HeroSkillStr6
    string array HeroSkillStr7
    //쿨타임
    real array HeroSkillCD0
    real array HeroSkillCD1
    real array HeroSkillCD2
    real array HeroSkillCD3
    real array HeroSkillCD4
    real array HeroSkillCD5
    real array HeroSkillCD6
    real array HeroSkillCD7
    //값개수
    integer array HeroSkillVCount0
    integer array HeroSkillVCount1
    integer array HeroSkillVCount2
    integer array HeroSkillVCount3
    integer array HeroSkillVCount4
    integer array HeroSkillVCount5
    integer array HeroSkillVCount6
    integer array HeroSkillVCount7
    //값1
    real array HeroSkillVelue0
    real array HeroSkillVelue1
    real array HeroSkillVelue2
    real array HeroSkillVelue3
    real array HeroSkillVelue4
    real array HeroSkillVelue5
    real array HeroSkillVelue6
    real array HeroSkillVelue7
    //값2
    real array HeroSkillVelue20
    real array HeroSkillVelue21
    real array HeroSkillVelue22
    real array HeroSkillVelue23
    real array HeroSkillVelue24
    real array HeroSkillVelue25
    real array HeroSkillVelue26
    real array HeroSkillVelue27
    //트포 설명
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
    //유저 V 카운트
    integer array PlayerVCount
    
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
    //유닛의 상태, 0 아무행동없음 , 1 스킬시전중, 2 무력화상태, 3 이동중, 4 패턴사용후 휴식
    integer array Unitstate
    real array UnitTier
    
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
    elseif i == 'h00F' then
        return 13
    elseif i == 'H00I' then
        return 14
    elseif i == 'H00K' then
        return 15
    elseif i == 'h00L' then
        return 16
    endif
    return 0
endfunction
    
private function init takes nothing returns nothing
    //플레이어 오의 카운트
    set PlayerVCount[0] = 0
    set PlayerVCount[1] = 0
    set PlayerVCount[2] = 0
    set PlayerVCount[3] = 0
    
    //포션
    set potion[1] = 'A01R'
    set potion[2] = 'A01U'
    set potion[3] = 'A01T'

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
    set UnitCutString[3] = "Momizi_Cut"
    set UnitCutSound[3]= gg_snd_Momi8
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

    set HeroSkillTpye0[3] = "일반"
    set HeroSkillStr0[3] = "지정 방향을 빠르게 베어 피해를 입힙니다."
    set HeroSkillCD0[3] = 7.0
    set HeroSkillVCount0[3] = 1
    set HeroSkillVelue0[3] = 2.68
    set HeroSkill0Text1[3] = "스킬 적중 시 3.0초간 자신에게 발도버프를 생성한다."
    set HeroSkill0Text2[3] = "스킬 시전 시 4.0초간 자신의 이동속도가 30.0% 증가한다." 
    set HeroSkill0Text3[3] = "적에게 주는 피해가 105.0% 증가된다."

    set HeroSkillTpye1[3] = "일반"
    set HeroSkillStr1[3] = "지정 방향을 빠르게 베어 피해를 입힙니다."
    set HeroSkillCD1[3] = 7.0
    set HeroSkillVCount1[3] = 1
    set HeroSkillVelue1[3] = 3.34
    set HeroSkill1Text1[3] = "스킬 적중 시 3.0초간 자신에게 발도버프를 생성한다."
    set HeroSkill1Text2[3] = "스킬 시전 시 지점 방향으로 돌진하며, 적에게 주는 피해가 45.0% 증가된다."
    set HeroSkill1Text3[3] = "공격 적중 시 적의 모든 방어력을 80.0% 무시한다."

    set HeroSkillTpye2[3] = "일반"
    set HeroSkillStr2[3] = "지정 방향을 빠르게 베어 피해를 입힙니다."
    set HeroSkillCD2[3] = 30.0
    set HeroSkillVCount2[3] = 1
    set HeroSkillVelue2[3] = 7.91
    set HeroSkill2Text1[3] = "재사용 대기시간이 11.0초 감소한다."
    set HeroSkill2Text2[3] = "적에게 주는 피해가 70.0% 증가한다."
    set HeroSkill2Text3[3] = "적에게 주는 피해가 80.0% 증가한다."

    set HeroSkillTpye3[3] = "일반"
    set HeroSkillStr3[3] = "지정 방향을 빠르게 베어 피해를 입힙니다."
    set HeroSkillCD3[3] = 14.0
    set HeroSkillVCount3[3] = 1
    set HeroSkillVelue3[3] = 5.56/6
    set HeroSkill3Text1[3] = "공격 적중 시 대상이 자신 및 파티원에게 받는 치명타 저항률이 12.0초간 10.0% 감소한다."
    set HeroSkill3Text2[3] = "적에게 주는 피해가 60.0% 증가한다."
    set HeroSkill3Text3[3] = "적에게 주는 피해가 70.0% 증가한다."

    set HeroSkillTpye4[3] = "일반"
    set HeroSkillStr4[3] = "지정 방향을 빠르게 베어 피해를 입힙니다."
    set HeroSkillCD4[3] = 20.0
    set HeroSkillVCount4[3] = 1
    set HeroSkillVelue4[3] = 10.0 * 0.10
    set HeroSkill4Text1[3] = "공격속도가 18.0% 증가한다."
    set HeroSkill4Text2[3] = "발도 버프를 가지고 있으면, 버프를 제거하고 적에게 주는 피해가 95.0% 증가한다."
    set HeroSkill4Text3[3] = "적에게 주는 피해가 105.0% 증가한다."

    set HeroSkillTpye5[3] = "일반"
    set HeroSkillStr5[3] = "지정 방향을 빠르게 베어 피해를 입힙니다."
    set HeroSkillCD5[3] = 20.0
    set HeroSkillVCount5[3] = 1
    set HeroSkillVelue5[3] = 9.92
    set HeroSkill5Text1[3] = "공격속도가 50.0% 증가하고, 재사용 대기 시간이 5.0초 감소한다."
    set HeroSkill5Text2[3] = "치명타 피해가 180.0% 증가한다."
    set HeroSkill5Text3[3] = "적에게 주는 피해가 95.0% 증가한다."

    set HeroSkillTpye6[3] = "일반"
    set HeroSkillStr6[3] = "지정 방향을 빠르게 베어 피해를 입힙니다."
    set HeroSkillCD6[3] = 27.0
    set HeroSkillVCount6[3] = 1
    set HeroSkillVelue6[3] = 15.54
    set HeroSkill6Text1[3] = "적에게 주는 피해가 45.0% 증가한다."
    set HeroSkill6Text2[3] = "발도 버프를 가지고 있으면, 버프를 제거하고 적에게 주는 피해가 95.0% 증가한다."
    set HeroSkill6Text3[3] = "치명타 피해가 210.0% 증가한다."

    set HeroSkillTpye7[3] = "일반"
    set HeroSkillStr7[3] = "지정 방향을 빠르게 베어 피해를 입힙니다."
    set HeroSkillCD7[3] = 5.0
    set HeroSkillVCount7[3] = 1
    set HeroSkillVelue7[3] = 17.01 / 8
    set HeroSkill7Text1[3] = "발도 버프를 가지고 있으면, 버프를 제거하고 적에게 주는 피해가 60.0% 증가한다."
    set HeroSkill7Text2[3] = "적에게 주는 피해가 60.0% 증가한다."
    set HeroSkill7Text3[3] = "적에게 주는 피해가 95.0% 증가한다."
    
    //챈
    set UnitAbilityIndex[4] = 'H004'
    set UnitCutString[4] = "Chen_Cut"
    set UnitCutSound[4]= gg_snd_ChenCut
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

    set HeroSkillTpye0[4] = "헤드어택"
    set HeroSkillStr0[4] = "지정 방향을 빠르게 베어 피해를 입힙니다."
    set HeroSkillCD0[4] = 10.00
    set HeroSkillVCount0[4] = 1
    set HeroSkillVelue0[4] = 7.12
    set HeroSkill0Text1[4] = "공격속도가 27.0% 증가한다."
    set HeroSkill0Text2[4] = "적에게 주는 피해가 70.0% 증가한다."
    set HeroSkill0Text3[4] = "차지 조작으로 변경된다.　　　　　　2단계 차지 시 총 52.5%의 증가된 피해를 주며, 풀 차지 시 총 150.0%의 증가된 피해를 주지만, 1단계 차지 시 피해가 20.0% 감소된다."

    set HeroSkillTpye1[4] = "헤드어택"
    set HeroSkillStr1[4] = "무기를 교차해 피해를 입힙니다."
    set HeroSkillCD1[4] = 7.00
    set HeroSkillVCount1[4] = 1
    set HeroSkillVelue1[4] = 2.35
    set HeroSkill1Text1[4] = "스킬 사용시 50.0% 확률로 재사용 대기시간이 4.9초 감소된다."
    set HeroSkill1Text2[4] = "적에게 주는 피해가 50.0% 증가된다." 
    set HeroSkill1Text3[4] = "적에게 주는 피해가 100.0% 증가된다."

    set HeroSkillTpye2[4] = "헤드어택, 카운터"
    set HeroSkillStr2[4] = "지정 방향으로 짧게 돌진해 피해를 입힙니다."
    set HeroSkillCD2[4] = 16.00
    set HeroSkillVCount2[4] = 1
    set HeroSkillVelue2[4] = 5.13
    set HeroSkill2Text1[4] = "재사용 대기시간이 5.6초 감소한다."
    set HeroSkill2Text2[4] = "적에게 주는 피해가 70.0% 증가한다."
    set HeroSkill2Text3[4] = "적에게 주는 피해가 159.5% 증가한다."
    
    set HeroSkillTpye3[4] = "헤드어택, 차지"
    set HeroSkillStr3[4] = "키다운 해제시 돌진하여 피해를 입힙니다."
    set HeroSkillCD3[4] = 30.00
    set HeroSkillVCount3[4] = 1
    set HeroSkillVelue3[4] = 12.93
    set HeroSkill3Text1[4] = "적에게 주는 피해가 50.0% 증가한다."
    set HeroSkill3Text2[4] = "차지 단계가 올라갈수록 공격력이 30.0% 상승한다."
    set HeroSkill3Text3[4] = "풀 차지 시 적에게 주는 피해가 122% 증가한다."
    
    set HeroSkillTpye4[4] = "버프"
    set HeroSkillStr4[4] = "주변 아군과 자신에게 최대 생명력에 비례해서 보호막을 씌웁니다."
    set HeroSkillCD4[4] = 40.0
    set HeroSkillVCount4[4] = 1
    set HeroSkillVelue4[4] = 0.15
    set HeroSkill4Text1[4] = "재사용 대기시간이 8.0초 감소한다."
    set HeroSkill4Text2[4] = "보호막 지속 시간이 6.0초 증가한다."
    set HeroSkill4Text3[4] = "보호막 수치가 자신의 최대 생명력의 40%로 변경된다."
    
    set HeroSkillTpye5[4] = "헤드어택, 카운터"
    set HeroSkillStr5[4] = "지정 방향을 빠르게 베어 피해를 입힙니다."
    set HeroSkillCD5[4] = 10.00
    set HeroSkillVCount5[4] = 1
    set HeroSkillVelue5[4] = 1.84
    set HeroSkill5Text1[4] = ""
    set HeroSkill5Text2[4] = ""
    set HeroSkill5Text3[4] = ""
    
    set HeroSkillTpye6[4] = "헤드어택"
    set HeroSkillStr6[4] = "주변 범위의 적에게 피해를 입힙니다."
    set HeroSkillCD6[4] = 24.00
    set HeroSkillVCount6[4] = 1
    set HeroSkillVelue6[4] = 3.39
    set HeroSkill6Text1[4] = "공격에 적중된 적들의 방어력을 10.0초간 12.0% 감소시키고, 공격 적중 시 자신의 공격력이 10.0초간 35% 증가한다."
    set HeroSkill6Text2[4] = "3.0초간 자신의 최대 생명력의 30.0% 만큼 보호막을 생성한다."
    set HeroSkill6Text3[4] = "12.0초간 약점을 노출시켜 헤드 어택 및 백 어택의 경우, 받는 피해 효과 12.0% 증가한다."
    
    set HeroSkillTpye7[4] = "헤드어택, 차지"
    set HeroSkillStr7[4] = "키다운 해제시 연속으로 베어 피해를 입힙니다."
    set HeroSkillCD7[4] = 30.00
    set HeroSkillVCount7[4] = 2
    set HeroSkillVelue7[4] = 1.00
    set HeroSkillVelue27[4] = 9.43
    set HeroSkill7Text1[4] = "적에게 주는 피해가 100.0% 증가한다."
    set HeroSkill7Text2[4] = "풀 차지 시 마지막 공격의 피해가 100% 증가한다."
    set HeroSkill7Text3[4] = "풀 차지 시 마지막 공격의 피해가 89.1% 증가한다."


    //사신짱
    set UnitAbilityIndex[5] = 'h005'
    set UnitHeroCheck[5] = false
    set NPCUnit[5]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h005', -28831+1000, 28813-3565, 319)
    call CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e01M',-28831+1000, 28813-3565, 270)
    
    //세레스티아 루덴베르크
    set UnitAbilityIndex[6] = 'h006'
    set UnitHeroCheck[6] = false
    set NPCUnit[6]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h006', -28958+1000, 28380-3565, 335)
    call CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e01K', -28958+1000, 28380-3565, 270)
    
    //라이자
    set UnitAbilityIndex[7] = 'h007'
    set UnitHeroCheck[7] = false
    set NPCUnit[7]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h007', -27445+1000, 28849-3565, 270)
    call CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e01L',-27445+1000, 28849-3565, 270)
    
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
    set NPCUnit[9]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h00A', -29000+1000, 27654-3565, 344)
    call CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e01N',-29000+1000, 27654-3565, 270)
    
    //아즈사
    set UnitAbilityIndex[10] = 'h00C'
    set UnitHeroCheck[10] = false
    //set NPCUnit[10]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h00C', -27500, 27900, 244)
    set NPCUnit[10]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h00C', -26022+1000, 28784-3565, 244)
    call CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e01P',-26022+1000, 28784-3565, 270)
    
    //치카
    set UnitAbilityIndex[11] = 'h00D'
    set UnitHeroCheck[11] = false
    set NPCUnit[11]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h00D', -25733+1000, 28486-3565, 228)
    call CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e01O',-25733+1000, 28486-3565, 270)
    
    //미카
    set UnitAbilityIndex[12] = 'h00E'
    set UnitHeroCheck[12] = false
    set NPCUnit[12]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h00E', -27500+1000, 27900-3565, 244)
    call CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e01R',-27500+1000, 27900-3565, 270)

    //유유코
    set UnitAbilityIndex[13] = 'h008'
    set UnitHPValue[13] = 1
    set UnitHPString[13] = ""
    set UnitSetHP[13] = 100000000
    set UnitSetSD[13] = 100000000
    set UnitSetArm[13] = 10000
    set UnitSetHPx[13] = 1
    set UnitTier[13] = 5

    //나루메아
    set UnitAbilityIndex[14] = 'H00I'
    //추가해야됨
    set UnitCutString[14] = "Mika_Cut"
    set UnitCutSound[14]= gg_snd_Narmaya_Cut1
    set UnitHeroCheck[14] = true
    set UnitDashCode[14] = 9
    set HeroSkillBlp0[14] = "ReplaceableTextures\\CommandButtons\\BTNHero_Jack2.blp"
    set HeroSkillBlp1[14] = "ReplaceableTextures\\CommandButtons\\BTNClawsOfAttack.blp"
    set HeroSkillBlp2[14] = "ReplaceableTextures\\CommandButtons\\BTNHero_Jack.blp"
    set HeroSkillBlp3[14] = "ReplaceableTextures\\CommandButtons\\BTNHero_Jack3.blp"
    set HeroSkillBlp4[14] = "ReplaceableTextures\\CommandButtons\\BTNAmbush.blp"
    set HeroSkillBlp5[14] = "ReplaceableTextures\\CommandButtons\\BTNAmbush.blp"
    set HeroSkillBlp6[14] = "ReplaceableTextures\\CommandButtons\\BTNHero_Jack4.blp"
    set HeroSkillBlp7[14] = "ReplaceableTextures\\CommandButtons\\BTNHero_Jack4.blp"
    set HeroSkillID0[14] = 'A02I'
    set HeroSkillID1[14] = 'A02J'
    set HeroSkillID2[14] = 'A02K'
    set HeroSkillID3[14] = 'A02L'
    set HeroSkillID4[14] = 'A02M'
    set HeroSkillID5[14] = 'A02N'
    set HeroSkillID6[14] = 'A02O'
    set HeroSkillID7[14] = 'A02P'
    set HeroSkillID8[14] = 'A02Q'
    set HeroSkillID9[14] = 'A02R'


    set HeroSkillTpye0[14] = "일반, 카운터"
    set HeroSkillStr0[14] = "지정 방향으로 돌진하며 피해를 입힙니다."
    set HeroSkillCD0[14] = 6.00
    set HeroSkillVCount0[14] = 1
    set HeroSkillVelue0[14] = 1.00
    set HeroSkill0Text1[14] = "모든 나비를 소모하여 나비 한개당 총 피해량이 100.0% 증가"
    set HeroSkill0Text2[14] = "카운터 적중시 나비 6개 획득"
    set HeroSkill0Text3[14] = "50% 확률로 나비 반환"

    set HeroSkillTpye1[14] = "일반"
    set HeroSkillStr1[14] = "카구라/겐지 자세를 변환합니다."
    set HeroSkillCD1[14] = 1.00
    set HeroSkillVCount1[14] = 1
    set HeroSkillVelue1[14] = 1.00
    set HeroSkill1Text1[14] = "E풀차지후 전환시 추가타격발생, R평타 강화 타격후 전환시 추가타격발생"
    set HeroSkill1Text2[14] = "R평타 강화 타격후 전환 추가타격후 발동하는 E스킬의 차지속도가 150% 증가" 
    set HeroSkill1Text3[14] = "E풀차지후 전환 추가타격후 발동하는 피해가 10회에 걸쳐 피해를 입히게되며 총 피해량이 500% 증가. 또한 전환시 추가타격 명중시 나비 1개 획득"

    set HeroSkillTpye2[14] = "일반, 차지"
    set HeroSkillStr2[14] = "전방을 발도술로 공격합니다. 버튼을 길게 누르면 범위가 증가합니다."
    set HeroSkillCD2[14] = 5.00
    set HeroSkillVCount2[14] = 2
    set HeroSkillVelue2[14] = 13.0
    set HeroSkillVelue22[14] = 7.0
    set HeroSkill2Text1[14] = "겐지 상태로 기본공격시 차지속도가 50%씩(최대 3회) 증가하고, 다른 스킬사용시 차지속도가 150% 증가"
    set HeroSkill2Text2[14] = "차지 단계가 생기며, 납도 동작이 추가되고 풀 차지 납도 적중시 나비 1개 획득, 차지 단계가 올라갈수록 베기 피해량이 30.0% 상승"
    set HeroSkill2Text3[14] = "풀 차지 시 납도가 적에게 주는 피해가 100.0% 증가"

    set HeroSkillTpye3[14] = "일반"
    set HeroSkillStr3[14] = "다음 평타 공격을 강화합니다."
    set HeroSkillCD3[14] = 8.00
    set HeroSkillVCount3[14] = 2
    set HeroSkillVelue3[14] = 1.00
    set HeroSkillVelue23[14] = 1.00
    set HeroSkill3Text1[14] = "강화 평타 적중시 나비 1개 획득"
    set HeroSkill3Text2[14] = "강화 평타의 피해량이 100.0% 증가"
    set HeroSkill3Text3[14] = "E풀차지후 전환 추가타격 후 즉시 R쿨타임 초기화, 다른 스킬사용시 사용하지 않아도 강화평타 사용가능"
    
    set HeroSkillTpye4[14] = "버프"
    set HeroSkillStr4[14] = "자신의 공격력을 증가시키는 버프를 겁니다."
    set HeroSkillCD4[14] = 120.00
    set HeroSkillVCount4[14] = 1
    set HeroSkillVelue4[14] = 0.35
    set HeroSkill4Text1[14] = "사용시 나비를 3개 획득"
    set HeroSkill4Text2[14] = "버프 지속시간 50% 증가"
    set HeroSkill4Text3[14] = "50% 확률로 나비를 3개가 아닌 6개 획득"

    set HeroSkillTpye5[14] = "일반"
    set HeroSkillStr5[14] = "후방으로 물러나며 충격파를 쏘아 피해를 입힙니다."
    set HeroSkillCD5[14] = 20.00
    set HeroSkillVCount5[14] = 1
    set HeroSkillVelue5[14] = 1.00
    set HeroSkill5Text1[14] = "모든 나비를 소모하여 3번의 참격을 날리며 나비 한개당 총 피해량이 100.0% 증가"
    set HeroSkill5Text2[14] = "시전도중 CC면역"
    set HeroSkill5Text3[14] = "50% 확률로 나비 반환"

    set HeroSkillTpye6[14] = "일반"
    set HeroSkillStr6[14] = "여러번 횡베기를 하여 연속으로 피해를 입힙니다."
    set HeroSkillCD6[14] = 32.00
    set HeroSkillVCount6[14] = 1
    set HeroSkillVelue6[14] = 1.00
    set HeroSkill6Text1[14] = "모든 나비를 소모하여 나비 한개당 마지막 베기의 총 피해량이 100.0% 증가"
    set HeroSkill6Text2[14] = "시전도중 CC면역"
    set HeroSkill6Text3[14] = "50% 확률로 나비 반환"

    set HeroSkillTpye7[14] = "일반, 차지"
    set HeroSkillStr7[14] = "전방의 적을 발도술로 공격한다. 버튼을 길게 누르면 피해가 증가합니다."
    set HeroSkillCD7[14] = 55.00
    set HeroSkillVCount7[14] = 1
    set HeroSkillVelue7[14] = 1.00
    set HeroSkill7Text1[14] = "모든 나비를 소모하여 나비 한개당 납도의 총 피해량이 100.0% 증가"
    set HeroSkill7Text2[14] = "나비를 소모한 만큼 차지속도가 50%씩 증가"
    set HeroSkill7Text3[14] = "50% 확률로 나비 반환, 나비를 6개 사용시, 납도 도중 무적"

    
    //반디
    set UnitAbilityIndex[15] = 'H00K'
    //추가해야됨
    set UnitCutString[15] = "Mika_Cut"
    //추가해야됨
    set UnitCutSound[15]= gg_snd_Narmaya_Cut1
    set UnitHeroCheck[15] = true
    set UnitDashCode[15] = 6
    set HeroSkillBlp0[15] = "ReplaceableTextures\\CommandButtons\\BTNHero_Jack2.blp"
    set HeroSkillBlp1[15] = "ReplaceableTextures\\CommandButtons\\BTNClawsOfAttack.blp"
    set HeroSkillBlp2[15] = "ReplaceableTextures\\CommandButtons\\BTNHero_Jack.blp"
    set HeroSkillBlp3[15] = "ReplaceableTextures\\CommandButtons\\BTNHero_Jack3.blp"
    set HeroSkillBlp4[15] = "ReplaceableTextures\\CommandButtons\\BTNAmbush.blp"
    set HeroSkillBlp5[15] = "ReplaceableTextures\\CommandButtons\\BTNAmbush.blp"
    set HeroSkillBlp6[15] = "ReplaceableTextures\\CommandButtons\\BTNHero_Jack4.blp"
    set HeroSkillBlp7[15] = "ReplaceableTextures\\CommandButtons\\BTNHero_Jack4.blp"
    set HeroSkillID0[15] = 'A06H'
    set HeroSkillID1[15] = 'A06L'
    set HeroSkillID2[15] = 'A06F'
    set HeroSkillID3[15] = 'A06I'
    set HeroSkillID4[15] = 'A06C'
    set HeroSkillID5[15] = 'A06J'
    set HeroSkillID6[15] = 'A06E'
    set HeroSkillID7[15] = 'A06G'
    //V
    set HeroSkillID8[15] = 'A06K'
    //C
    set HeroSkillID9[15] = 'A06D'
    //Z
    set HeroSkillID10[15] = 'A06M'

    set HeroSkillTpye0[15] = "일반, 카운터"
    set HeroSkillStr0[15] = "지정 방향으로 짧게 돌진하며 피해를 입힙니다. 적중시 비술을 1 획득합니다."
    set HeroSkillCD0[15] = 6.00
    set HeroSkillVCount0[15] = 1
    set HeroSkillVelue0[15] = 1.00
    set HeroSkill0Text1[15] = "총 피해량이 66.0% 증가"
    set HeroSkill0Text2[15] = "적중시 비술 1 을 추가 획득"
    set HeroSkill0Text3[15] = "카운터 적중시 비술게이지 5개 획득"

    set HeroSkillTpye1[15] = "일반"
    set HeroSkillStr1[15] = "지정 방향으로 관통하며 5번의 피해를 입히며 돌진합니다. 각 적중시 비술을 1 획득합니다."
    set HeroSkillCD1[15] = 8.00
    set HeroSkillVCount1[15] = 1
    set HeroSkillVelue1[15] = 0.66
    set HeroSkill1Text1[15] = ""
    set HeroSkill1Text2[15] = ""
    set HeroSkill1Text3[15] = ""

    set HeroSkillTpye2[15] = "일반, 키다운"
    set HeroSkillStr2[15] = "비술이 5일 경우에만 사용 가능하며 누르고 있으면 비술 사용중 이동할 수 있습니다."
    set HeroSkillCD2[15] = 10.00
    set HeroSkillVCount2[15] = 1
    set HeroSkillVelue2[15] = 5.0
    set HeroSkill2Text1[15] = "공격에 적중된 적들의 방어력을 10.0초간 12.0% 감소시킵니다."
    set HeroSkill2Text2[15] = "입히는 피해가 총 100% 증가합니다."
    set HeroSkill2Text3[15] = "비술 적중시 완전연소 게이지를 50% 회복합니다."

    set HeroSkillTpye3[15] = "일반"
    set HeroSkillStr3[15] = "짧게 지정 방향으로 이동하며 3회 공격합니다."
    set HeroSkillCD3[15] = 8.00
    set HeroSkillVCount3[15] = 2
    set HeroSkillVelue3[15] = 1.00
    set HeroSkillVelue23[15] = 1.00
    set HeroSkill3Text1[15] = ""
    set HeroSkill3Text2[15] = ""
    set HeroSkill3Text3[15] = ""
    
    set HeroSkillTpye4[15] = "일반, 카운터"
    set HeroSkillStr4[15] = "지정 지점으로 짧게 돌진하며 피해를 입힙니다."
    set HeroSkillCD4[15] = 8.00
    set HeroSkillVCount4[15] = 1
    set HeroSkillVelue4[15] = 0.35
    set HeroSkill4Text1[15] = "시전도중 CC면역"
    set HeroSkill4Text2[15] = "적중시 최대체력의 20%를 회복합니다."
    set HeroSkill4Text3[15] = "카운터 적중시 완전연소 게이지를 100% 회복합니다."

    set HeroSkillTpye5[15] = "일반"
    set HeroSkillStr5[15] = "바닥을 발로 찍어 범위 피해를 입힙니다."
    set HeroSkillCD5[15] = 10.00
    set HeroSkillVCount5[15] = 1
    set HeroSkillVelue5[15] = 1.00
    set HeroSkill5Text1[15] = "시전도중 CC면역"
    set HeroSkill5Text2[15] = ""
    set HeroSkill5Text3[15] = ""

    set HeroSkillTpye6[15] = "일반"
    set HeroSkillStr6[15] = "자신의 현재체력의 20%를 소모하여 점프해서 발로 내려찍고 피해를 입히며 완전연소 게이지를 25% 회복합니다."
    set HeroSkillCD6[15] = 10.00
    set HeroSkillVCount6[15] = 1
    set HeroSkillVelue6[15] = 1.00
    set HeroSkill6Text1[15] = "시전도중 CC면역"
    set HeroSkill6Text2[15] = "소모한 체력과 최대체력과 비례하여 소모한 체력이 높을 수록 피해가 최대 500% 까지 증가합니다."
    set HeroSkill6Text3[15] = "완전연소 게이지를 25%가 아닌 50%를 회복합니다."

    set HeroSkillTpye7[15] = "일반"
    set HeroSkillStr7[15] = "시전도중 무적 상태가 되며 지정 방향에 범위 입힙니다. 3번 사용하면 완전연소가 해제됩니다."
    set HeroSkillCD7[15] = 10.00
    set HeroSkillVCount7[15] = 1
    set HeroSkillVelue7[15] = 1.00
    set HeroSkill7Text1[15] = ""
    set HeroSkill7Text2[15] = ""
    set HeroSkill7Text3[15] = "사용시 완전연소 해제가 3회에서 4회로 증가합니다."

    //테스트
    set UnitAbilityIndex[16] = 'h00L'
    set UnitHPValue[16] = 1
    set UnitHPString[16] = ""
    set UnitSetHP[16] = 10000
    set UnitSetSD[16] = 10000
    set UnitSetArm[16] = 10000
    set UnitSetHPx[16] = 10
    set UnitTier[16] = 5
endfunction

endlibrary