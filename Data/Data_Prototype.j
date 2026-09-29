// 개인 사냥 프로토타입의 머리 카드, 성장 카드와 사건 풀을 정의한다.
library DataPrototype initializer ProtoDataInit requires DataExpedition
    globals
        constant integer PROTO_EVENT_COUNT = 72
        constant integer PROTO_CARD_FIRST = 13
        constant integer PROTO_CARD_LAST = 36
        string array ProtoHeadName
        string array ProtoCardName
        string array ProtoCardEffectName
        string array ProtoCardKeyword
        integer array ProtoCardHead
        integer array ProtoCardGrade
        integer array ProtoCardKind
        real array ProtoCardValue
        integer array ProtoEvolutionKind
        real array ProtoEvolutionGoal
        string array ProtoEventName
        integer array ProtoEventHead
        integer array ProtoEventKind
        string array ProtoEventStory
    endglobals

    function ProtoCardText takes integer pid, integer id returns string
        local string value = "[" + ProtoCardKeyword[id] + "] " + ProtoCardEffectName[id] + "|n"
        if ProtoCardKind[id] == 1 then
            set value = value + "피해 +" + I2S(R2I(ProtoCardValue[id])) + "%"
        elseif ProtoCardKind[id] == 2 then
            set value = value + "방어력 관통 +" + I2S(R2I(ProtoCardValue[id])) + "%"
        elseif ProtoCardKind[id] == 3 then
            set value = value + "사냥 처치 골드 +" + I2S(R2I(ProtoCardValue[id]))
        elseif ProtoCardKind[id] == 4 then
            set value = value + "받는 피해 -" + I2S(R2I(ProtoCardValue[id])) + "%"
        elseif ProtoCardKind[id] == 5 then
            set value = value + "고정 신속 +" + I2S(R2I(ProtoCardValue[id]))
        elseif ProtoCardKind[id] == 7 then
            set value = value + "보유 골드 1,000당 피해 +30% (최대 30%)"
        else
            set value = value + "사건 후보 +1 (최대 4개)"
        endif
        if ProtoEvolutionKind[id] > 0 then
            if ProtoEvolved[ExpKey(pid, id)] then
                set value = value + "|n|cffc781ff각성 · 피해 +25%|r"
            elseif ProtoEvolutionKind[id] == 1 then
                set value = value + "|n각성 목표 · 획득 후 처치 " + I2S(R2I(ProtoCardProgress[ExpKey(pid, id)])) + "/" + I2S(R2I(ProtoEvolutionGoal[id]))
            elseif ProtoEvolutionKind[id] == 2 then
                set value = value + "|n각성 목표 · 실제 누적 피해 " + I2S(R2I(ProtoCardProgress[ExpKey(pid, id)])) + "/" + I2S(R2I(ProtoEvolutionGoal[id]))
            else
                set value = value + "|n각성 목표 · 연속 무피격 " + I2S(R2I(ProtoCardProgress[ExpKey(pid, id)])) + "/" + I2S(R2I(ProtoEvolutionGoal[id])) + "초"
            endif
        endif
        return value
    endfunction

    function ProtoCanHit takes integer pid, integer targetIndex returns boolean
        local integer owner = ProtoHuntOwner[targetIndex] - 1
        if ExpPrototypeActive and ExpMember[pid] and (ProtoPaused[pid] or ProtoReady[pid]) then
            return false
        endif
        if owner >= 0 then
            return ExpPrototypeActive and ExpState == EXP_HUNT and owner == pid and ExpMember[pid] and not ProtoPaused[pid] and not ProtoReady[pid]
        endif
        return true
    endfunction

    function ProtoRecordDamage takes integer pid, integer targetIndex, real amount returns nothing
        local integer id = PROTO_CARD_FIRST
        if ProtoHuntOwner[targetIndex] != pid + 1 or amount <= 0 then
            return
        endif
        set ProtoDamage[pid] = ProtoDamage[pid] + amount
        loop
            exitwhen id > PROTO_CARD_LAST
            if ExpCardOwned[ExpKey(pid, id)] and ProtoEvolutionKind[id] == 2 and not ProtoEvolved[ExpKey(pid, id)] then
                set ProtoCardProgress[ExpKey(pid, id)] = ProtoCardProgress[ExpKey(pid, id)] + amount
            endif
            set id = id + 1
        endloop
    endfunction

    private function ProtoDataInit takes nothing returns nothing
        set ProtoCardKeyword[13] = "공통 · 수급"
        set ProtoCardKeyword[14] = "공통 · 관통"
        set ProtoCardKeyword[15] = "공통 · 피해"
        set ProtoCardKeyword[16] = "공통 · 피해"
        set ProtoCardKeyword[17] = "공통 · 생존"
        set ProtoCardKeyword[18] = "공통 · 탐색"
        set ProtoCardKeyword[19] = "학원도시 · 피해"
        set ProtoCardKeyword[20] = "학원도시 · 피해"
        set ProtoCardKeyword[21] = "학원도시 · 생존"
        set ProtoCardKeyword[22] = "학원도시 · 능력치"
        set ProtoCardKeyword[23] = "학원도시 · 수급"
        set ProtoCardKeyword[24] = "학원도시 · 피해"
        set ProtoCardKeyword[25] = "페나코니 · 피해"
        set ProtoCardKeyword[26] = "페나코니 · 피해"
        set ProtoCardKeyword[27] = "페나코니 · 저축"
        set ProtoCardKeyword[28] = "페나코니 · 생존"
        set ProtoCardKeyword[29] = "페나코니 · 탐색"
        set ProtoCardKeyword[30] = "페나코니 · 생존"
        set ProtoCardKeyword[31] = "홍마관 · 피해"
        set ProtoCardKeyword[32] = "홍마관 · 피해"
        set ProtoCardKeyword[33] = "홍마관 · 피해"
        set ProtoCardKeyword[34] = "홍마관 · 생존"
        set ProtoCardKeyword[35] = "홍마관 · 피해"
        set ProtoCardKeyword[36] = "홍마관 · 피해"
        set ProtoHeadName[1] = "학원도시"
        set ProtoHeadName[2] = "페나코니"
        set ProtoHeadName[3] = "홍마관"
        set ProtoCardName[13] = "야토"
        set ProtoCardEffectName[13] = "5엔의 인연"
        set ProtoCardHead[13] = 0
        set ProtoCardGrade[13] = 1
        set ProtoCardKind[13] = 3
        set ProtoCardValue[13] = 2.0
        set ProtoEvolutionKind[13] = 0
        set ProtoEvolutionGoal[13] = 0.0
        set ProtoCardName[14] = "나나미 켄토"
        set ProtoCardEffectName[14] = "십획주법"
        set ProtoCardHead[14] = 0
        set ProtoCardGrade[14] = 2
        set ProtoCardKind[14] = 2
        set ProtoCardValue[14] = 15.0
        set ProtoEvolutionKind[14] = 0
        set ProtoEvolutionGoal[14] = 0.0
        set ProtoCardName[15] = "쟈바미 유메코"
        set ProtoCardEffectName[15] = "승부의 쾌감"
        set ProtoCardHead[15] = 0
        set ProtoCardGrade[15] = 2
        set ProtoCardKind[15] = 1
        set ProtoCardValue[15] = 20.0
        set ProtoEvolutionKind[15] = 1
        set ProtoEvolutionGoal[15] = 25.0
        set ProtoCardName[16] = "키리토"
        set ProtoCardEffectName[16] = "검의 궤적"
        set ProtoCardHead[16] = 0
        set ProtoCardGrade[16] = 1
        set ProtoCardKind[16] = 1
        set ProtoCardValue[16] = 10.0
        set ProtoEvolutionKind[16] = 2
        set ProtoEvolutionGoal[16] = 6000.0
        set ProtoCardName[17] = "메이플"
        set ProtoCardEffectName[17] = "절대 방어"
        set ProtoCardHead[17] = 0
        set ProtoCardGrade[17] = 2
        set ProtoCardKind[17] = 4
        set ProtoCardValue[17] = 15.0
        set ProtoEvolutionKind[17] = 3
        set ProtoEvolutionGoal[17] = 45.0
        set ProtoCardName[18] = "소라"
        set ProtoCardEffectName[18] = "다음 수 읽기"
        set ProtoCardHead[18] = 0
        set ProtoCardGrade[18] = 3
        set ProtoCardKind[18] = 6
        set ProtoCardValue[18] = 1.0
        set ProtoEvolutionKind[18] = 0
        set ProtoEvolutionGoal[18] = 0.0
        set ProtoCardName[19] = "미사카 미코토"
        set ProtoCardEffectName[19] = "초전자포"
        set ProtoCardHead[19] = 1
        set ProtoCardGrade[19] = 2
        set ProtoCardKind[19] = 1
        set ProtoCardValue[19] = 20.0
        set ProtoEvolutionKind[19] = 2
        set ProtoEvolutionGoal[19] = 6000.0
        set ProtoCardName[20] = "카미조 토우마"
        set ProtoCardEffectName[20] = "포기하지 않는 주먹"
        set ProtoCardHead[20] = 1
        set ProtoCardGrade[20] = 1
        set ProtoCardKind[20] = 1
        set ProtoCardValue[20] = 12.0
        set ProtoEvolutionKind[20] = 1
        set ProtoEvolutionGoal[20] = 25.0
        set ProtoCardName[21] = "액셀러레이터"
        set ProtoCardEffectName[21] = "벡터 제어"
        set ProtoCardHead[21] = 1
        set ProtoCardGrade[21] = 3
        set ProtoCardKind[21] = 4
        set ProtoCardValue[21] = 25.0
        set ProtoEvolutionKind[21] = 0
        set ProtoEvolutionGoal[21] = 0.0
        set ProtoCardName[22] = "시라이 쿠로코"
        set ProtoCardEffectName[22] = "판단과 이동"
        set ProtoCardHead[22] = 1
        set ProtoCardGrade[22] = 2
        set ProtoCardKind[22] = 5
        set ProtoCardValue[22] = 120.0
        set ProtoEvolutionKind[22] = 0
        set ProtoEvolutionGoal[22] = 0.0
        set ProtoCardName[23] = "사텐 루이코"
        set ProtoCardEffectName[23] = "작은 단서"
        set ProtoCardHead[23] = 1
        set ProtoCardGrade[23] = 1
        set ProtoCardKind[23] = 3
        set ProtoCardValue[23] = 2.0
        set ProtoEvolutionKind[23] = 0
        set ProtoEvolutionGoal[23] = 0.0
        set ProtoCardName[24] = "인덱스"
        set ProtoCardEffectName[24] = "마도서의 지식"
        set ProtoCardHead[24] = 1
        set ProtoCardGrade[24] = 3
        set ProtoCardKind[24] = 1
        set ProtoCardValue[24] = 35.0
        set ProtoEvolutionKind[24] = 0
        set ProtoEvolutionGoal[24] = 0.0
        set ProtoCardName[25] = "반디"
        set ProtoCardEffectName[25] = "연소하는 의지"
        set ProtoCardHead[25] = 2
        set ProtoCardGrade[25] = 2
        set ProtoCardKind[25] = 1
        set ProtoCardValue[25] = 20.0
        set ProtoEvolutionKind[25] = 1
        set ProtoEvolutionGoal[25] = 25.0
        set ProtoCardName[26] = "아케론"
        set ProtoCardEffectName[26] = "덧없는 꿈"
        set ProtoCardHead[26] = 2
        set ProtoCardGrade[26] = 3
        set ProtoCardKind[26] = 1
        set ProtoCardValue[26] = 35.0
        set ProtoEvolutionKind[26] = 2
        set ProtoEvolutionGoal[26] = 9000.0
        set ProtoCardName[27] = "어벤츄린"
        set ProtoCardEffectName[27] = "모든 것을 건 승부"
        set ProtoCardHead[27] = 2
        set ProtoCardGrade[27] = 2
        set ProtoCardKind[27] = 7
        set ProtoCardValue[27] = 30.0
        set ProtoEvolutionKind[27] = 0
        set ProtoEvolutionGoal[27] = 0.0
        set ProtoCardName[28] = "로빈"
        set ProtoCardEffectName[28] = "함께 부르는 노래"
        set ProtoCardHead[28] = 2
        set ProtoCardGrade[28] = 2
        set ProtoCardKind[28] = 4
        set ProtoCardValue[28] = 18.0
        set ProtoEvolutionKind[28] = 3
        set ProtoEvolutionGoal[28] = 45.0
        set ProtoCardName[29] = "스파클"
        set ProtoCardEffectName[29] = "끝없는 가면극"
        set ProtoCardHead[29] = 2
        set ProtoCardGrade[29] = 3
        set ProtoCardKind[29] = 6
        set ProtoCardValue[29] = 1.0
        set ProtoEvolutionKind[29] = 0
        set ProtoEvolutionGoal[29] = 0.0
        set ProtoCardName[30] = "갤러거"
        set ProtoCardEffectName[30] = "꿈속의 휴식"
        set ProtoCardHead[30] = 2
        set ProtoCardGrade[30] = 1
        set ProtoCardKind[30] = 4
        set ProtoCardValue[30] = 10.0
        set ProtoEvolutionKind[30] = 0
        set ProtoEvolutionGoal[30] = 0.0
        set ProtoCardName[31] = "레밀리아"
        set ProtoCardEffectName[31] = "붉은 운명"
        set ProtoCardHead[31] = 3
        set ProtoCardGrade[31] = 3
        set ProtoCardKind[31] = 1
        set ProtoCardValue[31] = 35.0
        set ProtoEvolutionKind[31] = 0
        set ProtoEvolutionGoal[31] = 0.0
        set ProtoCardName[32] = "사쿠야"
        set ProtoCardEffectName[32] = "완벽한 준비"
        set ProtoCardHead[32] = 3
        set ProtoCardGrade[32] = 2
        set ProtoCardKind[32] = 1
        set ProtoCardValue[32] = 20.0
        set ProtoEvolutionKind[32] = 3
        set ProtoEvolutionGoal[32] = 45.0
        set ProtoCardName[33] = "파츄리"
        set ProtoCardEffectName[33] = "칠색의 마법"
        set ProtoCardHead[33] = 3
        set ProtoCardGrade[33] = 2
        set ProtoCardKind[33] = 1
        set ProtoCardValue[33] = 20.0
        set ProtoEvolutionKind[33] = 2
        set ProtoEvolutionGoal[33] = 6000.0
        set ProtoCardName[34] = "메이링"
        set ProtoCardEffectName[34] = "문지기의 수련"
        set ProtoCardHead[34] = 3
        set ProtoCardGrade[34] = 1
        set ProtoCardKind[34] = 4
        set ProtoCardValue[34] = 10.0
        set ProtoEvolutionKind[34] = 1
        set ProtoEvolutionGoal[34] = 30.0
        set ProtoCardName[35] = "루미아"
        set ProtoCardEffectName[35] = "어둠에 익숙해지기"
        set ProtoCardHead[35] = 3
        set ProtoCardGrade[35] = 1
        set ProtoCardKind[35] = 1
        set ProtoCardValue[35] = 12.0
        set ProtoEvolutionKind[35] = 3
        set ProtoEvolutionGoal[35] = 45.0
        set ProtoCardName[36] = "플랑드르"
        set ProtoCardEffectName[36] = "파괴의 충동"
        set ProtoCardHead[36] = 3
        set ProtoCardGrade[36] = 4
        set ProtoCardKind[36] = 1
        set ProtoCardValue[36] = 60.0
        set ProtoEvolutionKind[36] = 1
        set ProtoEvolutionGoal[36] = 40.0
        set ProtoEventName[1] = "학원도시로 가는 길 1"
        set ProtoEventHead[1] = 1
        set ProtoEventKind[1] = 0
        set ProtoEventStory[1] = "학원도시의 소문을 들었다. 이 지역을 조사하면 관련 사건과 카드가 등장한다."
        set ProtoEventName[2] = "학원도시로 가는 길 2"
        set ProtoEventHead[2] = 1
        set ProtoEventKind[2] = 0
        set ProtoEventStory[2] = "학원도시의 소문을 들었다. 이 지역을 조사하면 관련 사건과 카드가 등장한다."
        set ProtoEventName[3] = "학원도시로 가는 길 3"
        set ProtoEventHead[3] = 1
        set ProtoEventKind[3] = 0
        set ProtoEventStory[3] = "학원도시의 소문을 들었다. 이 지역을 조사하면 관련 사건과 카드가 등장한다."
        set ProtoEventName[4] = "학원도시로 가는 길 4"
        set ProtoEventHead[4] = 1
        set ProtoEventKind[4] = 0
        set ProtoEventStory[4] = "학원도시의 소문을 들었다. 이 지역을 조사하면 관련 사건과 카드가 등장한다."
        set ProtoEventName[5] = "페나코니로 가는 길 1"
        set ProtoEventHead[5] = 2
        set ProtoEventKind[5] = 0
        set ProtoEventStory[5] = "페나코니의 소문을 들었다. 이 지역을 조사하면 관련 사건과 카드가 등장한다."
        set ProtoEventName[6] = "페나코니로 가는 길 2"
        set ProtoEventHead[6] = 2
        set ProtoEventKind[6] = 0
        set ProtoEventStory[6] = "페나코니의 소문을 들었다. 이 지역을 조사하면 관련 사건과 카드가 등장한다."
        set ProtoEventName[7] = "페나코니로 가는 길 3"
        set ProtoEventHead[7] = 2
        set ProtoEventKind[7] = 0
        set ProtoEventStory[7] = "페나코니의 소문을 들었다. 이 지역을 조사하면 관련 사건과 카드가 등장한다."
        set ProtoEventName[8] = "페나코니로 가는 길 4"
        set ProtoEventHead[8] = 2
        set ProtoEventKind[8] = 0
        set ProtoEventStory[8] = "페나코니의 소문을 들었다. 이 지역을 조사하면 관련 사건과 카드가 등장한다."
        set ProtoEventName[9] = "홍마관로 가는 길 1"
        set ProtoEventHead[9] = 3
        set ProtoEventKind[9] = 0
        set ProtoEventStory[9] = "홍마관의 소문을 들었다. 이 지역을 조사하면 관련 사건과 카드가 등장한다."
        set ProtoEventName[10] = "홍마관로 가는 길 2"
        set ProtoEventHead[10] = 3
        set ProtoEventKind[10] = 0
        set ProtoEventStory[10] = "홍마관의 소문을 들었다. 이 지역을 조사하면 관련 사건과 카드가 등장한다."
        set ProtoEventName[11] = "홍마관로 가는 길 3"
        set ProtoEventHead[11] = 3
        set ProtoEventKind[11] = 0
        set ProtoEventStory[11] = "홍마관의 소문을 들었다. 이 지역을 조사하면 관련 사건과 카드가 등장한다."
        set ProtoEventName[12] = "홍마관로 가는 길 4"
        set ProtoEventHead[12] = 3
        set ProtoEventKind[12] = 0
        set ProtoEventStory[12] = "홍마관의 소문을 들었다. 이 지역을 조사하면 관련 사건과 카드가 등장한다."
        set ProtoEventName[13] = "방과 후의 자판기"
        set ProtoEventHead[13] = 1
        set ProtoEventKind[13] = 1
        set ProtoEventStory[13] = "학원도시에서 방과 후의 자판기을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[14] = "실험 참가 모집"
        set ProtoEventHead[14] = 1
        set ProtoEventKind[14] = 2
        set ProtoEventStory[14] = "학원도시에서 실험 참가 모집을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[15] = "저지먼트의 순찰"
        set ProtoEventHead[15] = 1
        set ProtoEventKind[15] = 3
        set ProtoEventStory[15] = "학원도시에서 저지먼트의 순찰을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[16] = "흩어진 실험 기록"
        set ProtoEventHead[16] = 1
        set ProtoEventKind[16] = 4
        set ProtoEventStory[16] = "학원도시에서 흩어진 실험 기록을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[17] = "스킬아웃의 골목"
        set ProtoEventHead[17] = 1
        set ProtoEventKind[17] = 5
        set ProtoEventStory[17] = "학원도시에서 스킬아웃의 골목을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[18] = "능력 개발 상담"
        set ProtoEventHead[18] = 1
        set ProtoEventKind[18] = 6
        set ProtoEventStory[18] = "학원도시에서 능력 개발 상담을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[19] = "미사카의 동전"
        set ProtoEventHead[19] = 1
        set ProtoEventKind[19] = 7
        set ProtoEventStory[19] = "학원도시에서 미사카의 동전을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[20] = "기숙사 통금"
        set ProtoEventHead[20] = 1
        set ProtoEventKind[20] = 8
        set ProtoEventStory[20] = "학원도시에서 기숙사 통금을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[21] = "도서관의 금서"
        set ProtoEventHead[21] = 1
        set ProtoEventKind[21] = 1
        set ProtoEventStory[21] = "학원도시에서 도서관의 금서을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[22] = "철도 아래의 거래"
        set ProtoEventHead[22] = 1
        set ProtoEventKind[22] = 2
        set ProtoEventStory[22] = "학원도시에서 철도 아래의 거래을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[23] = "관찰자의 시험"
        set ProtoEventHead[23] = 1
        set ProtoEventKind[23] = 3
        set ProtoEventStory[23] = "학원도시에서 관찰자의 시험을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[24] = "학원도시의 하루"
        set ProtoEventHead[24] = 1
        set ProtoEventKind[24] = 4
        set ProtoEventStory[24] = "학원도시에서 학원도시의 하루을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[25] = "황금의 순간"
        set ProtoEventHead[25] = 2
        set ProtoEventKind[25] = 5
        set ProtoEventStory[25] = "페나코니에서 황금의 순간을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[26] = "꿈속의 카지노"
        set ProtoEventHead[26] = 2
        set ProtoEventKind[26] = 6
        set ProtoEventStory[26] = "페나코니에서 꿈속의 카지노을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[27] = "호텔 로비의 초대"
        set ProtoEventHead[27] = 2
        set ProtoEventKind[27] = 7
        set ProtoEventStory[27] = "페나코니에서 호텔 로비의 초대을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[28] = "시계 소년의 안내"
        set ProtoEventHead[28] = 2
        set ProtoEventKind[28] = 8
        set ProtoEventStory[28] = "페나코니에서 시계 소년의 안내을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[29] = "꿈의 거품"
        set ProtoEventHead[29] = 2
        set ProtoEventKind[29] = 1
        set ProtoEventStory[29] = "페나코니에서 꿈의 거품을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[30] = "꿈을 만드는 공방"
        set ProtoEventHead[30] = 2
        set ProtoEventKind[30] = 2
        set ProtoEventStory[30] = "페나코니에서 꿈을 만드는 공방을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[31] = "가족의 초대장"
        set ProtoEventHead[31] = 2
        set ProtoEventKind[31] = 3
        set ProtoEventStory[31] = "페나코니에서 가족의 초대장을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[32] = "무대 뒤의 휴식"
        set ProtoEventHead[32] = 2
        set ProtoEventKind[32] = 4
        set ProtoEventStory[32] = "페나코니에서 무대 뒤의 휴식을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[33] = "기억을 잃은 손님"
        set ProtoEventHead[33] = 2
        set ProtoEventKind[33] = 5
        set ProtoEventStory[33] = "페나코니에서 기억을 잃은 손님을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[34] = "꿈속의 흥정"
        set ProtoEventHead[34] = 2
        set ProtoEventKind[34] = 6
        set ProtoEventStory[34] = "페나코니에서 꿈속의 흥정을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[35] = "미완성 공연"
        set ProtoEventHead[35] = 2
        set ProtoEventKind[35] = 7
        set ProtoEventStory[35] = "페나코니에서 미완성 공연을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[36] = "깨어날 시간"
        set ProtoEventHead[36] = 2
        set ProtoEventKind[36] = 8
        set ProtoEventStory[36] = "페나코니에서 깨어날 시간을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[37] = "붉은 저택의 문"
        set ProtoEventHead[37] = 3
        set ProtoEventKind[37] = 1
        set ProtoEventStory[37] = "홍마관에서 붉은 저택의 문을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[38] = "도서관의 책더미"
        set ProtoEventHead[38] = 3
        set ProtoEventKind[38] = 2
        set ProtoEventStory[38] = "홍마관에서 도서관의 책더미을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[39] = "문지기의 수련"
        set ProtoEventHead[39] = 3
        set ProtoEventKind[39] = 3
        set ProtoEventStory[39] = "홍마관에서 문지기의 수련을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[40] = "메이드의 휴식"
        set ProtoEventHead[40] = 3
        set ProtoEventKind[40] = 4
        set ProtoEventStory[40] = "홍마관에서 메이드의 휴식을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[41] = "지하실의 소리"
        set ProtoEventHead[41] = 3
        set ProtoEventKind[41] = 5
        set ProtoEventStory[41] = "홍마관에서 지하실의 소리을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[42] = "주인의 초대"
        set ProtoEventHead[42] = 3
        set ProtoEventKind[42] = 6
        set ProtoEventStory[42] = "홍마관에서 주인의 초대을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[43] = "안개 낀 정원"
        set ProtoEventHead[43] = 3
        set ProtoEventKind[43] = 7
        set ProtoEventStory[43] = "홍마관에서 안개 낀 정원을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[44] = "찻잔에 담긴 약속"
        set ProtoEventHead[44] = 3
        set ProtoEventKind[44] = 8
        set ProtoEventStory[44] = "홍마관에서 찻잔에 담긴 약속을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[45] = "잃어버린 마도서"
        set ProtoEventHead[45] = 3
        set ProtoEventKind[45] = 1
        set ProtoEventStory[45] = "홍마관에서 잃어버린 마도서을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[46] = "복도의 그림자"
        set ProtoEventHead[46] = 3
        set ProtoEventKind[46] = 2
        set ProtoEventStory[46] = "홍마관에서 복도의 그림자을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[47] = "붉은 달의 시험"
        set ProtoEventHead[47] = 3
        set ProtoEventKind[47] = 3
        set ProtoEventStory[47] = "홍마관에서 붉은 달의 시험을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[48] = "저택의 연회"
        set ProtoEventHead[48] = 3
        set ProtoEventKind[48] = 4
        set ProtoEventStory[48] = "홍마관에서 저택의 연회을 마주쳤다. 이번 사냥의 방향을 정하자."
        set ProtoEventName[49] = "길 잃은 여행자"
        set ProtoEventHead[49] = 0
        set ProtoEventKind[49] = 1
        set ProtoEventStory[49] = "길 잃은 여행자. 카드와 자원을 얻거나 사냥터의 조건을 바꿀 수 있다."
        set ProtoEventName[50] = "버려진 보급품"
        set ProtoEventHead[50] = 0
        set ProtoEventKind[50] = 2
        set ProtoEventStory[50] = "버려진 보급품. 카드와 자원을 얻거나 사냥터의 조건을 바꿀 수 있다."
        set ProtoEventName[51] = "몰려오는 무리"
        set ProtoEventHead[51] = 0
        set ProtoEventKind[51] = 3
        set ProtoEventStory[51] = "몰려오는 무리. 카드와 자원을 얻거나 사냥터의 조건을 바꿀 수 있다."
        set ProtoEventName[52] = "위험한 사냥감"
        set ProtoEventHead[52] = 0
        set ProtoEventKind[52] = 4
        set ProtoEventStory[52] = "위험한 사냥감. 카드와 자원을 얻거나 사냥터의 조건을 바꿀 수 있다."
        set ProtoEventName[53] = "허름한 주사위 탁자"
        set ProtoEventHead[53] = 0
        set ProtoEventKind[53] = 5
        set ProtoEventStory[53] = "허름한 주사위 탁자. 카드와 자원을 얻거나 사냥터의 조건을 바꿀 수 있다."
        set ProtoEventName[54] = "고요한 쉼터"
        set ProtoEventHead[54] = 0
        set ProtoEventKind[54] = 6
        set ProtoEventStory[54] = "고요한 쉼터. 카드와 자원을 얻거나 사냥터의 조건을 바꿀 수 있다."
        set ProtoEventName[55] = "수상한 교환 제안"
        set ProtoEventHead[55] = 0
        set ProtoEventKind[55] = 7
        set ProtoEventStory[55] = "수상한 교환 제안. 카드와 자원을 얻거나 사냥터의 조건을 바꿀 수 있다."
        set ProtoEventName[56] = "사냥꾼의 조언"
        set ProtoEventHead[56] = 0
        set ProtoEventKind[56] = 8
        set ProtoEventStory[56] = "사냥꾼의 조언. 카드와 자원을 얻거나 사냥터의 조건을 바꿀 수 있다."
        set ProtoEventName[57] = "뒤집힌 표지판"
        set ProtoEventHead[57] = 0
        set ProtoEventKind[57] = 1
        set ProtoEventStory[57] = "뒤집힌 표지판. 카드와 자원을 얻거나 사냥터의 조건을 바꿀 수 있다."
        set ProtoEventName[58] = "낡은 야영지"
        set ProtoEventHead[58] = 0
        set ProtoEventKind[58] = 2
        set ProtoEventStory[58] = "낡은 야영지. 카드와 자원을 얻거나 사냥터의 조건을 바꿀 수 있다."
        set ProtoEventName[59] = "발자국을 좇아서"
        set ProtoEventHead[59] = 0
        set ProtoEventKind[59] = 3
        set ProtoEventStory[59] = "발자국을 좇아서. 카드와 자원을 얻거나 사냥터의 조건을 바꿀 수 있다."
        set ProtoEventName[60] = "새로운 사냥터"
        set ProtoEventHead[60] = 0
        set ProtoEventKind[60] = 4
        set ProtoEventStory[60] = "새로운 사냥터. 카드와 자원을 얻거나 사냥터의 조건을 바꿀 수 있다."
        set ProtoEventName[61] = "우연한 만남"
        set ProtoEventHead[61] = 0
        set ProtoEventKind[61] = 5
        set ProtoEventStory[61] = "우연한 만남. 카드와 자원을 얻거나 사냥터의 조건을 바꿀 수 있다."
        set ProtoEventName[62] = "묻힌 상자"
        set ProtoEventHead[62] = 0
        set ProtoEventKind[62] = 6
        set ProtoEventStory[62] = "묻힌 상자. 카드와 자원을 얻거나 사냥터의 조건을 바꿀 수 있다."
        set ProtoEventName[63] = "밀집한 흔적"
        set ProtoEventHead[63] = 0
        set ProtoEventKind[63] = 7
        set ProtoEventStory[63] = "밀집한 흔적. 카드와 자원을 얻거나 사냥터의 조건을 바꿀 수 있다."
        set ProtoEventName[64] = "거대한 발자국"
        set ProtoEventHead[64] = 0
        set ProtoEventKind[64] = 8
        set ProtoEventStory[64] = "거대한 발자국. 카드와 자원을 얻거나 사냥터의 조건을 바꿀 수 있다."
        set ProtoEventName[65] = "밤의 내기"
        set ProtoEventHead[65] = 0
        set ProtoEventKind[65] = 1
        set ProtoEventStory[65] = "밤의 내기. 카드와 자원을 얻거나 사냥터의 조건을 바꿀 수 있다."
        set ProtoEventName[66] = "불 꺼진 초소"
        set ProtoEventHead[66] = 0
        set ProtoEventKind[66] = 2
        set ProtoEventStory[66] = "불 꺼진 초소. 카드와 자원을 얻거나 사냥터의 조건을 바꿀 수 있다."
        set ProtoEventName[67] = "막다른 길의 거래"
        set ProtoEventHead[67] = 0
        set ProtoEventKind[67] = 3
        set ProtoEventStory[67] = "막다른 길의 거래. 카드와 자원을 얻거나 사냥터의 조건을 바꿀 수 있다."
        set ProtoEventName[68] = "귀환자의 기록"
        set ProtoEventHead[68] = 0
        set ProtoEventKind[68] = 4
        set ProtoEventStory[68] = "귀환자의 기록. 카드와 자원을 얻거나 사냥터의 조건을 바꿀 수 있다."
        set ProtoEventName[69] = "새벽의 갈림길"
        set ProtoEventHead[69] = 0
        set ProtoEventKind[69] = 5
        set ProtoEventStory[69] = "새벽의 갈림길. 카드와 자원을 얻거나 사냥터의 조건을 바꿀 수 있다."
        set ProtoEventName[70] = "남겨진 짐"
        set ProtoEventHead[70] = 0
        set ProtoEventKind[70] = 6
        set ProtoEventStory[70] = "남겨진 짐. 카드와 자원을 얻거나 사냥터의 조건을 바꿀 수 있다."
        set ProtoEventName[71] = "숲속의 소문"
        set ProtoEventHead[71] = 0
        set ProtoEventKind[71] = 7
        set ProtoEventStory[71] = "숲속의 소문. 카드와 자원을 얻거나 사냥터의 조건을 바꿀 수 있다."
        set ProtoEventName[72] = "이름 없는 의뢰"
        set ProtoEventHead[72] = 0
        set ProtoEventKind[72] = 8
        set ProtoEventStory[72] = "이름 없는 의뢰. 카드와 자원을 얻거나 사냥터의 조건을 바꿀 수 있다."
    endfunction
endlibrary
