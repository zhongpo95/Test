library DataUnit initializer init requires Tick

globals
    //hashtable Unithash = InitHashtable()
    //유닛어빌'색인'
    integer array UnitAbilityIndex
    //엔피씨
    unit array NPCUnit
    unit array NPCRoleDummy
    private constant real NPC_TOWN_LEFT = -27840.00
    private constant real NPC_TOWN_RIGHT = -24896.00
    private constant real NPC_TOWN_BOTTOM = 24896.00
    private constant real NPC_TOWN_TOP = 27840.00
    //영웅타입
    boolean array UnitHeroCheck
    //대쉬모션번호
    integer array UnitDashCode
    //컷인스트링
    string array UnitCutString
    //컷인사운드
    sound array UnitCutSound
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
    elseif i == 'H00Q' then
        return 14
    elseif i == 'H00K' then
        return 15
    elseif i == 'h00L' then
        return 16
    elseif i == 'H00P' then
        return 17
    elseif i == 'h00V' then
        return 18
    elseif i == 'h00U' then
        return 19
    elseif i == 'h00E' then
        return 20
    elseif i == 'h00Y' then
        return 21
    elseif i == 'h00S' then
        return 22
    elseif i == 'h00R' then
        return 23
    elseif i == 'h00W' then
        return 24
    elseif i == 'h00X' then
        return 25
    endif
    return 0
endfunction

private function NPCRoleDummyFollowPeriodic takes nothing returns nothing
    local integer i = 0
    loop
        if NPCUnit[i] != null and NPCRoleDummy[i] != null then
            call SetUnitX(NPCRoleDummy[i], GetUnitX(NPCUnit[i]))
            call SetUnitY(NPCRoleDummy[i], GetUnitY(NPCUnit[i]))
        endif
        set i = i + 1
        exitwhen i > 18
    endloop
endfunction
    
private function init takes nothing returns nothing
    local tick t = tick.create(0)
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
    
    //샌드백
    set UnitAbilityIndex[2] = 'h002'
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
    set HeroSkillID0[3] = 'A00Y'
    set HeroSkillID1[3] = 'A00Z'
    set HeroSkillID2[3] = 'A010'
    set HeroSkillID3[3] = 'A011'
    set HeroSkillID4[3] = 'A012'
    set HeroSkillID5[3] = 'A013'
    set HeroSkillID6[3] = 'A014'
    set HeroSkillID7[3] = 'A015'
    set HeroSkillID8[3] = 'A016'

    set HeroSkillTpye0[3] = "일반, 카운터"
    set HeroSkillStr0[3] = "전방으로 짧게 돌진해 적을 벱니다."
    set HeroSkillCD0[3] = 7.0
    set HeroSkillVCount0[3] = 1
    set HeroSkillVelue0[3] = 2.68
    set HeroSkill0Text1[3] = "공격 범위에 적이 있으면 3초간 발도 버프를 얻습니다."
    set HeroSkill0Text2[3] = "이동속도 버프를 4초간 얻습니다. 이동속도 상한이 적용됩니다."
    set HeroSkill0Text3[3] = ""

    set HeroSkillTpye1[3] = "일반"
    set HeroSkillStr1[3] = "전방으로 짧게 돌진해 적을 벱니다."
    set HeroSkillCD1[3] = 7.0
    set HeroSkillVCount1[3] = 1
    set HeroSkillVelue1[3] = 3.34
    set HeroSkill1Text1[3] = "공격 범위에 적이 있으면 3초간 발도 버프를 얻습니다."
    set HeroSkill1Text2[3] = "이 공격은 방어력 80% 관통을 적용합니다. 원정에서는 관통 상한이 적용됩니다."
    set HeroSkill1Text3[3] = ""

    set HeroSkillTpye2[3] = "일반"
    set HeroSkillStr2[3] = "지정 지점에 6회 연속으로 범위 피해를 입힙니다."
    set HeroSkillCD2[3] = 30.0
    set HeroSkillVCount2[3] = 1
    set HeroSkillVelue2[3] = 7.91
    set HeroSkill2Text1[3] = ""
    set HeroSkill2Text2[3] = ""
    set HeroSkill2Text3[3] = ""

    set HeroSkillTpye3[3] = "일반"
    set HeroSkillStr3[3] = "전방으로 세 갈래 충격파를 12회 내보냅니다."
    set HeroSkillCD3[3] = 14.0
    set HeroSkillVCount3[3] = 1
    set HeroSkillVelue3[3] = 5.56/6
    set HeroSkill3Text1[3] = "적중한 적을 공격할 때 자신과 아군의 치명타 확률이 12초간 10%p 증가합니다."
    set HeroSkill3Text2[3] = "적의 위치에 따라 적중 횟수가 달라집니다."
    set HeroSkill3Text3[3] = ""

    set HeroSkillTpye4[3] = "일반"
    set HeroSkillStr4[3] = "전방으로 도약하며 최대 10회 피해를 입힙니다."
    set HeroSkillCD4[3] = 20.0
    set HeroSkillVCount4[3] = 1
    set HeroSkillVelue4[3] = 10.0 * 0.10
    set HeroSkill4Text1[3] = "발도 버프가 있으면 강화된 피해를 주고 마지막 타격 후 버프를 소모합니다."
    set HeroSkill4Text2[3] = "이 스킬의 동작 속도에 18%가 추가됩니다."
    set HeroSkill4Text3[3] = ""

    set HeroSkillTpye5[3] = "일반"
    set HeroSkillStr5[3] = "전방의 적을 빠르게 벱니다."
    set HeroSkillCD5[3] = 20.0
    set HeroSkillVCount5[3] = 1
    set HeroSkillVelue5[3] = 9.92
    set HeroSkill5Text1[3] = "이 공격의 치명타 피해 수치에 180%p가 추가됩니다."
    set HeroSkill5Text2[3] = "이 스킬의 동작 속도에 100%가 추가됩니다."
    set HeroSkill5Text3[3] = ""

    set HeroSkillTpye6[3] = "일반"
    set HeroSkillStr6[3] = "전방으로 관통하는 충격파를 내보냅니다. 같은 적은 한 번만 타격합니다."
    set HeroSkillCD6[3] = 27.0
    set HeroSkillVCount6[3] = 1
    set HeroSkillVelue6[3] = 15.54
    set HeroSkill6Text1[3] = "발도 버프가 있으면 시전 시 소모하고 강화된 피해를 줍니다."
    set HeroSkill6Text2[3] = "이 공격의 치명타 피해 수치에 210%p가 추가됩니다."
    set HeroSkill6Text3[3] = ""

    set HeroSkillTpye7[3] = "일반"
    set HeroSkillStr7[3] = "전방의 적을 최대 8회 연속으로 벱니다."
    set HeroSkillCD7[3] = 5.0
    set HeroSkillVCount7[3] = 1
    set HeroSkillVelue7[3] = 17.01 / 8
    set HeroSkill7Text1[3] = "발도 버프가 있으면 시전 시 소모하고 강화된 피해를 줍니다."
    set HeroSkill7Text2[3] = ""
    set HeroSkill7Text3[3] = ""
    
    //챈
    set UnitAbilityIndex[4] = 'H004'
    set UnitCutString[4] = "Chen_Cut"
    set UnitCutSound[4]= gg_snd_ChenCut
    set UnitHeroCheck[4] = true
    set UnitDashCode[4] = 9
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

    set HeroSkillTpye0[4] = "헤드어택, 차지"
    set HeroSkillStr0[4] = "키를 누르고 차지한 뒤 놓으면 전방을 벱니다."
    set HeroSkillCD0[4] = 10.00
    set HeroSkillVCount0[4] = 1
    set HeroSkillVelue0[4] = 12
    set HeroSkill0Text1[4] = "차지 단계에 따라 피해가 달라지며 최대 차지 후에는 자동으로 공격합니다."
    set HeroSkill0Text2[4] = "차지 중 동작 속도에 27%가 추가됩니다."
    set HeroSkill0Text3[4] = ""

    set HeroSkillTpye1[4] = "헤드어택"
    set HeroSkillStr1[4] = "전방의 적을 두 번 벱니다."
    set HeroSkillCD1[4] = 7.00
    set HeroSkillVCount1[4] = 1
    set HeroSkillVelue1[4] = 2.35
    set HeroSkill1Text1[4] = "사용 시 50% 확률로 기본 재사용 시간이 2초가 됩니다."
    set HeroSkill1Text2[4] = ""
    set HeroSkill1Text3[4] = ""

    set HeroSkillTpye2[4] = "헤드어택, 카운터"
    set HeroSkillStr2[4] = "전방으로 짧게 돌진한 뒤 적을 벱니다."
    set HeroSkillCD2[4] = 16.00
    set HeroSkillVCount2[4] = 1
    set HeroSkillVelue2[4] = 5.13
    set HeroSkill2Text1[4] = ""
    set HeroSkill2Text2[4] = ""
    set HeroSkill2Text3[4] = ""
    
    set HeroSkillTpye3[4] = "헤드어택, 차지"
    set HeroSkillStr3[4] = "키를 누르고 차지한 뒤 놓으면 전방으로 돌진해 공격합니다."
    set HeroSkillCD3[4] = 30.00
    set HeroSkillVCount3[4] = 1
    set HeroSkillVelue3[4] = 12.93
    set HeroSkill3Text1[4] = "차지는 4단계이며 최대 차지 후에는 자동으로 공격합니다."
    set HeroSkill3Text2[4] = ""
    set HeroSkill3Text3[4] = ""
    
    set HeroSkillTpye4[4] = "버프"
    set HeroSkillStr4[4] = "자신과 주변 아군에게 시전자 최대 생명력의 40% 보호막을 부여합니다."
    set HeroSkillCD4[4] = 32.0
    set HeroSkillVCount4[4] = 1
    set HeroSkillVelue4[4] = 0.40
    set HeroSkill4Text1[4] = "보호막은 12초간 유지됩니다."
    set HeroSkill4Text2[4] = ""
    set HeroSkill4Text3[4] = ""
    
    set HeroSkillTpye5[4] = "헤드어택, 카운터"
    set HeroSkillStr5[4] = "전방의 적을 빠르게 벱니다."
    set HeroSkillCD5[4] = 10.00
    set HeroSkillVCount5[4] = 1
    set HeroSkillVelue5[4] = 1.84
    set HeroSkill5Text1[4] = ""
    set HeroSkill5Text2[4] = ""
    set HeroSkill5Text3[4] = ""
    
    set HeroSkillTpye6[4] = "헤드어택"
    set HeroSkillStr6[4] = "주변 적에게 범위 피해를 입히고 자신에게 보호막을 부여합니다."
    set HeroSkillCD6[4] = 24.00
    set HeroSkillVCount6[4] = 1
    set HeroSkillVelue6[4] = 3.39
    set HeroSkill6Text1[4] = "주변에 적이 있으면 장비 기본 공격력의 35%를 10초간 추가 공격력으로 얻습니다."
    set HeroSkill6Text2[4] = "자신의 최대 생명력의 30% 보호막이 4초간 유지됩니다."
    set HeroSkill6Text3[4] = ""
    
    set HeroSkillTpye7[4] = "헤드어택, 차지"
    set HeroSkillStr7[4] = "키를 누르고 차지한 뒤 놓으면 전방을 연속으로 벱니다."
    set HeroSkillCD7[4] = 30.00
    set HeroSkillVCount7[4] = 2
    set HeroSkillVelue7[4] = 1.00
    set HeroSkillVelue27[4] = 9.43
    set HeroSkill7Text1[4] = "1단계는 6타, 2단계는 10타입니다."
    set HeroSkill7Text2[4] = "최대 차지는 일반 9타와 강화된 마지막 1타입니다."
    set HeroSkill7Text3[4] = ""

 
    //히마리 카드부여
    set UnitAbilityIndex[5] = 'h005'
    set UnitHeroCheck[5] = false
    set NPCUnit[5]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h005', GetRandomReal(NPC_TOWN_LEFT, NPC_TOWN_RIGHT), GetRandomReal(NPC_TOWN_BOTTOM, NPC_TOWN_TOP), 319)
    set NPCRoleDummy[5] = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e01M',GetUnitX(NPCUnit[5]), GetUnitY(NPCUnit[5]), 270)
    
    //유즈 장비강화
    set UnitAbilityIndex[6] = 'h006'
    set UnitHeroCheck[6] = false
    set NPCUnit[6]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h006', GetRandomReal(NPC_TOWN_LEFT, NPC_TOWN_RIGHT), GetRandomReal(NPC_TOWN_BOTTOM, NPC_TOWN_TOP), 335)
    set NPCRoleDummy[6] = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e01K', GetUnitX(NPCUnit[6]), GetUnitY(NPCUnit[6]), 270)
    
    //라이자 보스이동
    set UnitAbilityIndex[7] = 'h007'
    set UnitHeroCheck[7] = false
    set NPCUnit[7]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h007', (NPC_TOWN_LEFT + NPC_TOWN_RIGHT) / 2, (NPC_TOWN_BOTTOM + NPC_TOWN_TOP) / 2, 270)
    set NPCRoleDummy[7] = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e01L',GetUnitX(NPCUnit[7]), GetUnitY(NPCUnit[7]), 270)
    
    //반격
    set UnitAbilityIndex[8] = 'h008'
    set UnitSetHP[8] = 100000000
    set UnitSetSD[8] = 100000000
    set UnitSetArm[8] = 10000
    set UnitSetHPx[8] = 1
    set UnitTier[8] = 5
    
    //유우카 창고
    set UnitAbilityIndex[9] = 'h00A'
    set UnitHeroCheck[9] = false
    set NPCUnit[9]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h00A', GetRandomReal(NPC_TOWN_LEFT, NPC_TOWN_RIGHT), GetRandomReal(NPC_TOWN_BOTTOM, NPC_TOWN_TOP), 344)
    set NPCRoleDummy[9] = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e01N',GetUnitX(NPCUnit[9]), GetUnitY(NPCUnit[9]), 270)
    
    //미야코
    set UnitAbilityIndex[10] = 'h00C'
    set UnitHeroCheck[10] = false
    //set NPCUnit[10]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h00C', -27500, 27900, 244)
    set NPCUnit[10]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h00C', GetRandomReal(NPC_TOWN_LEFT, NPC_TOWN_RIGHT), GetRandomReal(NPC_TOWN_BOTTOM, NPC_TOWN_TOP), 244)
    //set NPCRoleDummy[10] = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e01P',GetUnitX(NPCUnit[10]), GetUnitY(NPCUnit[10]), 270)
    
    //하나코
    set UnitAbilityIndex[11] = 'h00D'
    set UnitHeroCheck[11] = false
    //set NPCUnit[11]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h00D', -25733+1000, 28486-3565, 228)
    //call CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e01O',-25733+1000, 28486-3565, 270)
    set NPCUnit[11]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h00D', GetRandomReal(NPC_TOWN_LEFT, NPC_TOWN_RIGHT), GetRandomReal(NPC_TOWN_BOTTOM, NPC_TOWN_TOP), 228)
    //set NPCRoleDummy[11] = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e01O',GetUnitX(NPCUnit[11]), GetUnitY(NPCUnit[11]), 270)
    
    //미카
    set UnitAbilityIndex[12] = 'h00E'
    set UnitHeroCheck[12] = false
    //set NPCUnit[12]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h00E', -27500+1000, 27900-3565, 244)
    //call CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e01R',-27500+1000, 27900-3565, 270)
    set NPCUnit[12]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h00E', GetRandomReal(NPC_TOWN_LEFT, NPC_TOWN_RIGHT), GetRandomReal(NPC_TOWN_BOTTOM, NPC_TOWN_TOP), 244)
    //set NPCRoleDummy[12] = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'e01R',GetUnitX(NPCUnit[12]), GetUnitY(NPCUnit[12]), 270)

    //유유코
    set UnitAbilityIndex[13] = 'h008'
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
    set HeroSkillStr0[14] = "전방으로 돌진해 적을 공격합니다."
    set HeroSkillCD0[14] = 18.00
    set HeroSkillVCount0[14] = 1
    set HeroSkillVelue0[14] = 1.00
    set HeroSkill0Text1[14] = "모든 나비를 사용하며 나비 하나당 기본 타격을 한 번 추가합니다."
    set HeroSkill0Text2[14] = "카운터 성공 시 나비 6개를 얻고 이 스킬의 재사용 시간을 초기화합니다."
    set HeroSkill0Text3[14] = "나비는 50% 확률로 소모되지 않습니다."

    set HeroSkillTpye1[14] = "일반"
    set HeroSkillStr1[14] = "카구라와 겐지 자세를 전환합니다."
    set HeroSkillCD1[14] = 1.00
    set HeroSkillVCount1[14] = 1
    set HeroSkillVelue1[14] = 1.00
    set HeroSkill1Text1[14] = "전환 연계 가능 시간에 W를 사용하면 추가 공격이 발생합니다."
    set HeroSkill1Text2[14] = "겐지 전환 연계는 11회 지속 타격, 카구라 전환 연계는 범위 공격입니다. 적중 시 나비를 얻습니다."
    set HeroSkill1Text3[14] = "겐지 전환 연계 후 E 차지 동작 속도에 150%가 추가되고 R 재사용 시간이 초기화됩니다."

    set HeroSkillTpye2[14] = "일반, 카운터, 차지"
    set HeroSkillStr2[14] = "겐지 자세에서 전방을 차지해 벱니다. 차지할수록 베기 범위와 피해가 증가합니다."
    set HeroSkillCD2[14] = 5.00
    set HeroSkillVCount2[14] = 2
    set HeroSkillVelue2[14] = 1.30
    set HeroSkillVelue22[14] = 0.7
    set HeroSkill2Text1[14] = "2단계 이상은 납도 공격이 3회 추가됩니다. 최대 차지 납도 적중 시 나비를 얻습니다."
    set HeroSkill2Text2[14] = "겐지 기본 공격은 E 차지 속도를 최대 3중첩까지 높입니다. Q/S/D/F 사용 시 E 재사용 시간이 초기화됩니다."
    set HeroSkill2Text3[14] = "카구라 자세의 연계 공격은 범위가 증가하며 최대 범위로 공격하면 자세 전환 연계가 가능합니다."

    set HeroSkillTpye3[14] = "일반"
    set HeroSkillStr3[14] = "카구라 자세의 다음 기본 공격을 강화합니다."
    set HeroSkillCD3[14] = 8.00
    set HeroSkillVCount3[14] = 2
    set HeroSkillVelue3[14] = 1.00
    set HeroSkillVelue23[14] = 1.00
    set HeroSkill3Text1[14] = "강화 연타 적중 시 나비를 얻고 자세 전환 연계가 가능합니다."
    set HeroSkill3Text2[14] = "겐지 전환 연계 후에는 R을 다시 사용하지 않아도 강화 기본 공격이 가능합니다."
    set HeroSkill3Text3[14] = ""
    
    set HeroSkillTpye4[14] = "버프"
    set HeroSkillStr4[14] = "장비 기본 공격력의 35%를 90초간 추가 공격력으로 얻습니다."
    set HeroSkillCD4[14] = 120.00
    set HeroSkillVCount4[14] = 1
    set HeroSkillVelue4[14] = 0.35
    set HeroSkill4Text1[14] = "50% 확률로 나비 6개를 얻습니다."
    set HeroSkill4Text2[14] = "시전 완료 후 재사용 시간이 시작되며 취소하면 1초의 재사용 시간이 적용됩니다."
    set HeroSkill4Text3[14] = ""

    set HeroSkillTpye5[14] = "일반"
    set HeroSkillStr5[14] = "뒤로 물러나며 충격파를 내보냅니다."
    set HeroSkillCD5[14] = 26.00
    set HeroSkillVCount5[14] = 1
    set HeroSkillVelue5[14] = 1.00
    set HeroSkill5Text1[14] = "나비를 사용하면 충격파가 세 갈래로 나가고 각 충격파에 나비 수만큼 타격이 추가됩니다."
    set HeroSkill5Text2[14] = "나비는 50% 확률로 소모되지 않습니다. 시전 중 피해 및 제어 효과를 막습니다."
    set HeroSkill5Text3[14] = ""

    set HeroSkillTpye6[14] = "일반"
    set HeroSkillStr6[14] = "전방을 네 차례 연속으로 벤 뒤 마무리 공격을 합니다."
    set HeroSkillCD6[14] = 42.00
    set HeroSkillVCount6[14] = 1
    set HeroSkillVelue6[14] = 1.00
    set HeroSkill6Text1[14] = "각 연속 베기는 3타이며 마지막 공격에는 사용한 나비 수만큼 타격이 추가됩니다."
    set HeroSkill6Text2[14] = "나비는 50% 확률로 소모되지 않습니다. 시전 중 제어 효과를 막습니다."
    set HeroSkill6Text3[14] = ""

    set HeroSkillTpye7[14] = "일반, 차지"
    set HeroSkillStr7[14] = "전방을 차지해 벤 뒤 3회 납도 공격을 합니다."
    set HeroSkillCD7[14] = 72.00
    set HeroSkillVCount7[14] = 1
    set HeroSkillVelue7[14] = 1.00
    set HeroSkill7Text1[14] = "각 납도 공격에는 사용한 나비 수만큼 타격이 추가됩니다. 나비 하나당 차지 동작 속도가 50%씩 추가됩니다."
    set HeroSkill7Text2[14] = "나비는 50% 확률로 소모되지 않습니다. 나비 6개를 사용하면 납도 동작 중 피해와 제어 효과를 막습니다."
    set HeroSkill7Text3[14] = ""

    
    //반디
    set UnitAbilityIndex[15] = 'H00K'
    //추가해야됨
    set UnitCutString[15] = "Mika_Cut"
    //추가해야됨
    set UnitCutSound[15]= gg_snd_Narmaya_Cut1
    set UnitHeroCheck[15] = true
    set UnitDashCode[15] = 6
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
    set HeroSkillStr0[15] = "전방으로 짧게 돌진해 적을 공격합니다."
    set HeroSkillCD0[15] = 6.00
    set HeroSkillVCount0[15] = 1
    set HeroSkillVelue0[15] = 1.00
    set HeroSkill0Text1[15] = "적중한 적마다 비술을 1 얻습니다."
    set HeroSkill0Text2[15] = ""
    set HeroSkill0Text3[15] = ""

    set HeroSkillTpye1[15] = "일반"
    set HeroSkillStr1[15] = "전방으로 돌진하며 경로의 다섯 지점을 공격합니다."
    set HeroSkillCD1[15] = 8.00
    set HeroSkillVCount1[15] = 1
    set HeroSkillVelue1[15] = 0.66
    set HeroSkill1Text1[15] = "각 적중마다 비술을 1 얻습니다. 적의 위치에 따라 적중 횟수가 달라집니다."
    set HeroSkill1Text2[15] = ""
    set HeroSkill1Text3[15] = ""

    set HeroSkillTpye2[15] = "일반, 키다운"
    set HeroSkillStr2[15] = "비술을 소모하고 키를 놓거나 약 2초가 지나면 범위 공격 후 완전연소 상태로 전환합니다."
    set HeroSkillCD2[15] = 10.00
    set HeroSkillVCount2[15] = 1
    set HeroSkillVelue2[15] = 5.0
    set HeroSkill2Text1[15] = "완전연소 해제 기능의 재사용 시간은 5초입니다."
    set HeroSkill2Text2[15] = ""
    set HeroSkill2Text3[15] = ""

    set HeroSkillTpye3[15] = "헤드어택, 카운터"
    set HeroSkillStr3[15] = "전방의 적을 총 6회 공격합니다."
    set HeroSkillCD3[15] = 2.75
    set HeroSkillVCount3[15] = 2
    set HeroSkillVelue3[15] = 1.00
    set HeroSkillVelue23[15] = 1.00
    set HeroSkill3Text1[15] = "마지막 동작에서 2회 타격합니다."
    set HeroSkill3Text2[15] = ""
    set HeroSkill3Text3[15] = ""
    
    set HeroSkillTpye4[15] = "일반, 카운터"
    set HeroSkillStr4[15] = "지정 방향으로 돌진해 전방의 적을 공격합니다."
    set HeroSkillCD4[15] = 8.00
    set HeroSkillVCount4[15] = 1
    set HeroSkillVelue4[15] = 0.35
    set HeroSkill4Text1[15] = ""
    set HeroSkill4Text2[15] = ""
    set HeroSkill4Text3[15] = ""

    set HeroSkillTpye5[15] = "헤드어택"
    set HeroSkillStr5[15] = "전방에 두 번 범위 피해를 입힙니다."
    set HeroSkillCD5[15] = 10.00
    set HeroSkillVCount5[15] = 1
    set HeroSkillVelue5[15] = 1.00
    set HeroSkill5Text1[15] = ""
    set HeroSkill5Text2[15] = ""
    set HeroSkill5Text3[15] = ""

    set HeroSkillTpye6[15] = "일반"
    set HeroSkillStr6[15] = "돌진 경로의 적을 공격하고 도착 지점에 추가 피해를 입힙니다."
    set HeroSkillCD6[15] = 10.00
    set HeroSkillVCount6[15] = 1
    set HeroSkillVelue6[15] = 1.00
    set HeroSkill6Text1[15] = "완전연소 상태에서는 완전연소 자원을 1 얻습니다."
    set HeroSkill6Text2[15] = ""
    set HeroSkill6Text3[15] = ""

    set HeroSkillTpye7[15] = "일반"
    set HeroSkillStr7[15] = "돌진과 연속 공격 연출을 실행한 뒤 물러납니다."
    set HeroSkillCD7[15] = 10.00
    set HeroSkillVCount7[15] = 1
    set HeroSkillVelue7[15] = 1.00
    set HeroSkill7Text1[15] = "현재 시전 경로에는 직접 피해 판정이 없습니다."
    set HeroSkill7Text2[15] = ""
    set HeroSkill7Text3[15] = ""

    //테스트
    set UnitAbilityIndex[16] = 'h00L'
    set UnitSetHP[16] = 10000
    set UnitSetSD[16] = 10000
    set UnitSetArm[16] = 10000
    set UnitSetHPx[16] = 10
    set UnitTier[16] = 5

    //루시아
    set UnitAbilityIndex[17] = 'H00P'
    //추가해야됨
    set UnitCutString[17] = "Mika_Cut"
    //추가해야됨
    set UnitCutSound[17]= gg_snd_Narmaya_Cut1
    set UnitHeroCheck[17] = true
    set UnitDashCode[17] = 34
    set HeroSkillID0[17] = 'A07B'
    set HeroSkillID1[17] = 'A07A'
    set HeroSkillID2[17] = 'A07C'
    set HeroSkillID3[17] = 'A07D'
    set HeroSkillID4[17] = 'A07E'
    set HeroSkillID5[17] = 'A07F'
    set HeroSkillID6[17] = 'A07G'
    set HeroSkillID7[17] = 'A07H'
    //V
    set HeroSkillID8[17] = 'A06K'
    //C
    set HeroSkillID9[17] = 'A06D'
    //Z
    set HeroSkillID10[17] = 'A06M'

    set HeroSkillTpye0[17] = "일반, 카운터"
    set HeroSkillStr0[17] = "전방의 적을 두 번 공격합니다. 첫 번째 타격은 카운터 판정을 가집니다."
    set HeroSkillCD0[17] = 6.00
    set HeroSkillVCount0[17] = 1
    set HeroSkillVelue0[17] = 1.00
    set HeroSkill0Text1[17] = "사용 시 자원 40을 얻고 차지 진행도를 8 올립니다. 차지 진행도는 최대 25입니다."
    set HeroSkill0Text2[17] = ""
    set HeroSkill0Text3[17] = ""

    set HeroSkillTpye1[17] = "헤드어택, 차지"
    set HeroSkillStr1[17] = "전방으로 여섯 차례 참격을 내보냅니다."
    set HeroSkillCD1[17] = 8.00
    set HeroSkillVCount1[17] = 1
    set HeroSkillVelue1[17] = 0.66
    set HeroSkill1Text1[17] = "사용과 각 참격 생성 시 자원을 20씩 얻습니다."
    set HeroSkill1Text2[17] = "참격이 지나가는 동안 범위 안의 적을 반복 타격합니다."
    set HeroSkill1Text3[17] = ""

    set HeroSkillTpye2[17] = "헤드어택, 차지"
    set HeroSkillStr2[17] = "키를 누르면 차지 진행도가 올라갑니다. 최대 차지 전에 놓으면 자세에 따라 돌진 공격을 합니다."
    set HeroSkillCD2[17] = 10.00
    set HeroSkillVCount2[17] = 1
    set HeroSkillVelue2[17] = 5.0
    set HeroSkill2Text1[17] = "최대 차지는 돌진과 연속 베기 연출을 실행하고 차지 진행도를 초기화합니다. 현재 최대 차지 연출에는 직접 피해 판정이 없습니다."
    set HeroSkill2Text2[17] = ""
    set HeroSkill2Text3[17] = ""

    set HeroSkillTpye3[17] = "일반"
    set HeroSkillStr3[17] = "자세를 전환하고 차지 진행도를 초기화합니다."
    set HeroSkillCD3[17] = 2.75
    set HeroSkillVCount3[17] = 2
    set HeroSkillVelue3[17] = 1.00
    set HeroSkillVelue23[17] = 1.00
    set HeroSkill3Text1[17] = "현재 시전 경로에는 직접 피해 판정이 없습니다."
    set HeroSkill3Text2[17] = ""
    set HeroSkill3Text3[17] = ""
    
    set HeroSkillTpye4[17] = "헤드어택, 카운터"
    set HeroSkillStr4[17] = "전방으로 돌진한 뒤 적을 공격합니다."
    set HeroSkillCD4[17] = 8.00
    set HeroSkillVCount4[17] = 1
    set HeroSkillVelue4[17] = 0.35
    set HeroSkill4Text1[17] = "사용 시 차지 진행도를 8 올립니다. 차지 진행도는 최대 25입니다."
    set HeroSkill4Text2[17] = ""
    set HeroSkill4Text3[17] = ""

    set HeroSkillTpye5[17] = "일반, 카운터"
    set HeroSkillStr5[17] = "전방으로 돌진하며 세 번 공격합니다."
    set HeroSkillCD5[17] = 10.00
    set HeroSkillVCount5[17] = 1
    set HeroSkillVelue5[17] = 1.00
    set HeroSkill5Text1[17] = "사용 시 차지 진행도를 8 올립니다. 차지 진행도는 최대 25입니다."
    set HeroSkill5Text2[17] = ""
    set HeroSkill5Text3[17] = ""

    set HeroSkillTpye6[17] = "일반"
    set HeroSkillStr6[17] = "전방으로 베기 연출을 실행합니다."
    set HeroSkillCD6[17] = 10.00
    set HeroSkillVCount6[17] = 1
    set HeroSkillVelue6[17] = 1.00
    set HeroSkill6Text1[17] = "현재 시전 경로에는 직접 피해 판정이 없습니다."
    set HeroSkill6Text2[17] = ""
    set HeroSkill6Text3[17] = ""

    set HeroSkillTpye7[17] = "일반"
    set HeroSkillStr7[17] = "자세를 전환하고 차지 진행도를 초기화한 뒤 연속 공격 연출을 실행합니다."
    set HeroSkillCD7[17] = 10.00
    set HeroSkillVCount7[17] = 1
    set HeroSkillVelue7[17] = 1.00
    set HeroSkill7Text1[17] = "현재 시전 경로에는 직접 피해 판정이 없습니다."
    set HeroSkill7Text2[17] = ""
    set HeroSkill7Text3[17] = ""
    

    //마리
    set UnitAbilityIndex[18] = 'h00V'
    set UnitHeroCheck[18] = false
    set NPCUnit[18]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h00V', GetRandomReal(NPC_TOWN_LEFT, NPC_TOWN_RIGHT), GetRandomReal(NPC_TOWN_BOTTOM, NPC_TOWN_TOP), 244)
    //미유
    set UnitAbilityIndex[19] = 'h00U'
    set UnitHeroCheck[19] = false
    set NPCUnit[19]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h00U', GetRandomReal(NPC_TOWN_LEFT, NPC_TOWN_RIGHT), GetRandomReal(NPC_TOWN_BOTTOM, NPC_TOWN_TOP), 244)
    //아리스
    set UnitAbilityIndex[20] = 'h00E'
    set UnitHeroCheck[20] = false
    set NPCUnit[20]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h00E', GetRandomReal(NPC_TOWN_LEFT, NPC_TOWN_RIGHT), GetRandomReal(NPC_TOWN_BOTTOM, NPC_TOWN_TOP), 244)
    //아즈사
    set UnitAbilityIndex[21] = 'h00Y'
    set UnitHeroCheck[21] = false
    set NPCUnit[21]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h00Y', GetRandomReal(NPC_TOWN_LEFT, NPC_TOWN_RIGHT), GetRandomReal(NPC_TOWN_BOTTOM, NPC_TOWN_TOP), 244)
    //카요코
    set UnitAbilityIndex[22] = 'h00S'
    set UnitHeroCheck[22] = false
    set NPCUnit[22]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h00S', GetRandomReal(NPC_TOWN_LEFT, NPC_TOWN_RIGHT), GetRandomReal(NPC_TOWN_BOTTOM, NPC_TOWN_TOP), 244)
    //코코나
    set UnitAbilityIndex[23] = 'h00R'
    set UnitHeroCheck[23] = false
    set NPCUnit[23]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h00R', GetRandomReal(NPC_TOWN_LEFT, NPC_TOWN_RIGHT), GetRandomReal(NPC_TOWN_BOTTOM, NPC_TOWN_TOP), 244)
    //호시노
    set UnitAbilityIndex[24] = 'h00W'
    set UnitHeroCheck[24] = false
    set NPCUnit[24]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h00W', GetRandomReal(NPC_TOWN_LEFT, NPC_TOWN_RIGHT), GetRandomReal(NPC_TOWN_BOTTOM, NPC_TOWN_TOP), 244)
    //히나
    set UnitAbilityIndex[25] = 'h00X'
    set UnitHeroCheck[25] = false
    set NPCUnit[25]  = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),'h00X', GetRandomReal(NPC_TOWN_LEFT, NPC_TOWN_RIGHT), GetRandomReal(NPC_TOWN_BOTTOM, NPC_TOWN_TOP), 244)
    


    call t.start(0.03, true, function NPCRoleDummyFollowPeriodic)
endfunction

endlibrary

