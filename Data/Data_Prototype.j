// 개인 사냥 프로토타입의 머리 카드, 성장 카드와 사건 풀을 정의한다.
library DataPrototype initializer ProtoDataInit requires DataExpedition
    globals
        constant integer PROTO_EVENT_COUNT = 108
        constant integer PROTO_CARD_FIRST = 13
        constant integer PROTO_CARD_LAST = 48
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

        integer array ProtoHeadEntryCard
        integer array ProtoEventRequired
        integer array ProtoEventRequiredChoice
        integer array ProtoEventHistory
        string array ProtoEventFailure
        string array ProtoBranchLabel
        string array ProtoBranchResult
        integer array ProtoBranchCard
        integer array ProtoBranchCard2
        integer array ProtoBranchGold
        integer array ProtoBranchCost
        integer array ProtoBranchLevel
        integer array ProtoBranchDensity
        real array ProtoBranchDamage
        integer array ProtoBranchHealth
        integer array ProtoBranchPotions
        integer array ProtoBranchChance
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


    // 사건 기록은 카드의 64칸 키와 분리한다. 기록은 원정 안에서만 유지한다.
    function ProtoStoryKey takes integer pid, integer id returns integer
        return pid * 128 + id
    endfunction

    function ProtoChoiceKey takes integer id, integer choice returns integer
        return id * 2 + choice - 1
    endfunction

    private function ProtoSetScene takes integer id, integer head, string name, string story, integer previous, integer choice returns nothing
        set ProtoEventName[id] = name
        set ProtoEventHead[id] = head
        set ProtoEventKind[id] = 1
        set ProtoEventStory[id] = story
        set ProtoEventRequired[id] = previous
        set ProtoEventRequiredChoice[id] = choice
    endfunction

    private function ProtoSetBranch takes integer id, integer choice, string label, string result, integer card, integer card2, integer gold, integer cost, integer level, integer density, real damage, integer health, integer potions, integer chance returns nothing
        local integer key = ProtoChoiceKey(id, choice)
        set ProtoBranchLabel[key] = label
        set ProtoBranchResult[key] = result
        set ProtoBranchCard[key] = card
        set ProtoBranchCard2[key] = card2
        set ProtoBranchGold[key] = gold
        set ProtoBranchCost[key] = cost
        set ProtoBranchLevel[key] = level
        set ProtoBranchDensity[key] = density
        set ProtoBranchDamage[key] = damage
        set ProtoBranchHealth[key] = health
        set ProtoBranchPotions[key] = potions
        set ProtoBranchChance[key] = chance
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
        set ProtoCardName[37] = "미사카 동생"
        set ProtoCardEffectName[37] = "공유되는 관측"
        set ProtoCardKeyword[37] = "학원도시 · 피해"
        set ProtoCardHead[37] = 1
        set ProtoCardGrade[37] = 2
        set ProtoCardKind[37] = 1
        set ProtoCardValue[37] = 15.0
        set ProtoEvolutionKind[37] = 1
        set ProtoEvolutionGoal[37] = 30.0
        set ProtoCardName[38] = "우이하루 카자리"
        set ProtoCardEffectName[38] = "정보 지원"
        set ProtoCardKeyword[38] = "학원도시 · 탐색"
        set ProtoCardHead[38] = 1
        set ProtoCardGrade[38] = 2
        set ProtoCardKind[38] = 6
        set ProtoCardValue[38] = 1.0
        set ProtoEvolutionKind[38] = 0
        set ProtoEvolutionGoal[38] = 0.0
        set ProtoCardName[39] = "게코타"
        set ProtoCardEffectName[39] = "잠깐의 안도"
        set ProtoCardKeyword[39] = "학원도시 · 생존"
        set ProtoCardHead[39] = 1
        set ProtoCardGrade[39] = 1
        set ProtoCardKind[39] = 4
        set ProtoCardValue[39] = 8.0
        set ProtoEvolutionKind[39] = 0
        set ProtoEvolutionGoal[39] = 0.0
        set ProtoCardName[40] = "미사카 네트워크"
        set ProtoCardEffectName[40] = "서로의 경고"
        set ProtoCardKeyword[40] = "학원도시 · 생존"
        set ProtoCardHead[40] = 1
        set ProtoCardGrade[40] = 3
        set ProtoCardKind[40] = 4
        set ProtoCardValue[40] = 20.0
        set ProtoEvolutionKind[40] = 0
        set ProtoEvolutionGoal[40] = 0.0
        set ProtoCardName[41] = "좋은꿈 슬롯머신"
        set ProtoCardEffectName[41] = "당첨의 기억"
        set ProtoCardKeyword[41] = "페나코니 · 저축"
        set ProtoCardHead[41] = 2
        set ProtoCardGrade[41] = 2
        set ProtoCardKind[41] = 7
        set ProtoCardValue[41] = 30.0
        set ProtoEvolutionKind[41] = 0
        set ProtoEvolutionGoal[41] = 0.0
        set ProtoCardName[42] = "클락"
        set ProtoCardEffectName[42] = "꿈의 길잡이"
        set ProtoCardKeyword[42] = "페나코니 · 탐색"
        set ProtoCardHead[42] = 2
        set ProtoCardGrade[42] = 2
        set ProtoCardKind[42] = 6
        set ProtoCardValue[42] = 1.0
        set ProtoEvolutionKind[42] = 0
        set ProtoEvolutionGoal[42] = 0.0
        set ProtoCardName[43] = "솔글래드"
        set ProtoCardEffectName[43] = "달콤한 꿈의 휴식"
        set ProtoCardKeyword[43] = "페나코니 · 생존"
        set ProtoCardHead[43] = 2
        set ProtoCardGrade[43] = 1
        set ProtoCardKind[43] = 4
        set ProtoCardValue[43] = 8.0
        set ProtoEvolutionKind[43] = 0
        set ProtoEvolutionGoal[43] = 0.0
        set ProtoCardName[44] = "꿈세계의 시계"
        set ProtoCardEffectName[44] = "맞물리는 꿈"
        set ProtoCardKeyword[44] = "페나코니 · 생존"
        set ProtoCardHead[44] = 2
        set ProtoCardGrade[44] = 2
        set ProtoCardKind[44] = 4
        set ProtoCardValue[44] = 12.0
        set ProtoEvolutionKind[44] = 0
        set ProtoEvolutionGoal[44] = 0.0
        set ProtoCardName[45] = "소악마"
        set ProtoCardEffectName[45] = "서가의 조력자"
        set ProtoCardKeyword[45] = "홍마관 · 수급"
        set ProtoCardHead[45] = 3
        set ProtoCardGrade[45] = 1
        set ProtoCardKind[45] = 3
        set ProtoCardValue[45] = 2.0
        set ProtoEvolutionKind[45] = 0
        set ProtoEvolutionGoal[45] = 0.0
        set ProtoCardName[46] = "마도서"
        set ProtoCardEffectName[46] = "빌려 온 지식"
        set ProtoCardKeyword[46] = "홍마관 · 피해"
        set ProtoCardHead[46] = 3
        set ProtoCardGrade[46] = 1
        set ProtoCardKind[46] = 1
        set ProtoCardValue[46] = 12.0
        set ProtoEvolutionKind[46] = 2
        set ProtoEvolutionGoal[46] = 6000.0
        set ProtoCardName[47] = "키리사메 마리사"
        set ProtoCardEffectName[47] = "마법은 화력"
        set ProtoCardKeyword[47] = "홍마관 · 피해"
        set ProtoCardHead[47] = 3
        set ProtoCardGrade[47] = 2
        set ProtoCardKind[47] = 1
        set ProtoCardValue[47] = 25.0
        set ProtoEvolutionKind[47] = 2
        set ProtoEvolutionGoal[47] = 9000.0
        set ProtoCardName[48] = "치르노"
        set ProtoCardEffectName[48] = "얼음의 자랑"
        set ProtoCardKeyword[48] = "홍마관 · 피해"
        set ProtoCardHead[48] = 3
        set ProtoCardGrade[48] = 1
        set ProtoCardKind[48] = 1
        set ProtoCardValue[48] = 15.0
        set ProtoEvolutionKind[48] = 1
        set ProtoEvolutionGoal[48] = 30.0
        // 원작의 장소/역할을 근거로 만든 맵용 각색이다. 아래 선택과 보상은 원작 퀘스트의 재현이 아니다.
        // 학원도시 공식 인물 소개. https://toaru-project.com/railgun_t/chara/
        // 시스터즈/네트워크 공식 소개. https://toaru-project.com/index_3/chara/sisters.html
        // 페나코니 인게임 대화/시설 기록. https://honkai-star-rail.fandom.com/wiki/Tales_from_the_Golden_Age
        // 좋은꿈 슬롯머신. https://honkai-star-rail.fandom.com/wiki/Dreamy_Slots
        // 홍마향 인물/대화 번역. https://www.thpatch.net/wiki/Th06/Reimu%27s_Extra/en
        // 공통 인물 공식 소개. https://www.noragami-anime.net/story.html
        // https://jujutsukaisen.jp/character/category3.php
        // https://kakegurui-anime.com/character/group01.php
        // https://www.swordart-online.net/sp/aincrad/character/
        // https://bofuri.jp/season1/character/ https://ngnl.jp/tv/character/
        set ProtoHeadEntryCard[1] = 20
        set ProtoEventName[1] = "학원도시의 방문증"
        set ProtoEventHead[1] = 1
        set ProtoEventKind[1] = 0
        set ProtoEventStory[1] = "토우마가 도시의 길을 알려 준다. 학원도시의 사건을 만날 준비가 됐다."
        set ProtoHeadEntryCard[2] = 30
        set ProtoEventName[5] = "꿈세계의 체크인"
        set ProtoEventHead[5] = 2
        set ProtoEventKind[5] = 0
        set ProtoEventStory[5] = "갤러거의 안내로 꿈세계에 들어선다. 페나코니의 사건을 만날 준비가 됐다."
        set ProtoHeadEntryCard[3] = 34
        set ProtoEventName[9] = "홍마관의 방문 허가"
        set ProtoEventHead[9] = 3
        set ProtoEventKind[9] = 0
        set ProtoEventStory[9] = "메이링이 방문을 허가한다. 홍마관과 주변 길의 사건을 만날 준비가 됐다."
        set ProtoEventName[2] = "학원도시의 방문증"
        set ProtoEventHead[2] = 1
        set ProtoEventKind[2] = 0
        set ProtoEventStory[2] = "토우마가 도시의 길을 알려 준다. 학원도시의 사건을 만날 준비가 됐다."
        set ProtoEventName[3] = "학원도시의 방문증"
        set ProtoEventHead[3] = 1
        set ProtoEventKind[3] = 0
        set ProtoEventStory[3] = "토우마가 도시의 길을 알려 준다. 학원도시의 사건을 만날 준비가 됐다."
        set ProtoEventName[4] = "학원도시의 방문증"
        set ProtoEventHead[4] = 1
        set ProtoEventKind[4] = 0
        set ProtoEventStory[4] = "토우마가 도시의 길을 알려 준다. 학원도시의 사건을 만날 준비가 됐다."
        set ProtoEventName[6] = "꿈세계의 체크인"
        set ProtoEventHead[6] = 2
        set ProtoEventKind[6] = 0
        set ProtoEventStory[6] = "갤러거의 안내로 꿈세계에 들어선다. 페나코니의 사건을 만날 준비가 됐다."
        set ProtoEventName[7] = "꿈세계의 체크인"
        set ProtoEventHead[7] = 2
        set ProtoEventKind[7] = 0
        set ProtoEventStory[7] = "갤러거의 안내로 꿈세계에 들어선다. 페나코니의 사건을 만날 준비가 됐다."
        set ProtoEventName[8] = "꿈세계의 체크인"
        set ProtoEventHead[8] = 2
        set ProtoEventKind[8] = 0
        set ProtoEventStory[8] = "갤러거의 안내로 꿈세계에 들어선다. 페나코니의 사건을 만날 준비가 됐다."
        set ProtoEventName[10] = "홍마관의 방문 허가"
        set ProtoEventHead[10] = 3
        set ProtoEventKind[10] = 0
        set ProtoEventStory[10] = "메이링이 방문을 허가한다. 홍마관과 주변 길의 사건을 만날 준비가 됐다."
        set ProtoEventName[11] = "홍마관의 방문 허가"
        set ProtoEventHead[11] = 3
        set ProtoEventKind[11] = 0
        set ProtoEventStory[11] = "메이링이 방문을 허가한다. 홍마관과 주변 길의 사건을 만날 준비가 됐다."
        set ProtoEventName[12] = "홍마관의 방문 허가"
        set ProtoEventHead[12] = 3
        set ProtoEventKind[12] = 0
        set ProtoEventStory[12] = "메이링이 방문을 허가한다. 홍마관과 주변 길의 사건을 만날 준비가 됐다."
        call ProtoSetScene(13, 1, "자판기 앞의 초전자포", "미코토가 돈을 삼킨 자판기를 노려보고 있다. 전격을 쓰기 전에 길 건너 사람이 없는지 확인해 달라고 한다. 물러서기만 할지, 곁에서 도울지 정해야 한다.", 0, 0)
        call ProtoSetBranch(13, 1, "주변을 살피고 신호한다", "전격이 튀는 순간을 지켜봤다. 미코토는 다음에는 제대로 된 장소에서 연습하자고 말한다.", 19, 0, 0, 0, 1, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(13, 2, "자판기 관리자를 부른다", "관리자가 음료 대신 환불금을 건넨다. 미코토는 능력을 쓰지 않고 상황을 마무리한다.", 0, 0, 150, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(14, 1, "시스템 스캔", "능력 측정실에서 추가 검사 참가자를 찾고 있다. 반복 검사를 받으면 전투 훈련도 더 거칠어진다고 한다. 사텐은 능력 수치가 전부는 아니라며 옆에 앉아 있다.", 0, 0)
        call ProtoSetBranch(14, 1, "추가 측정을 받는다", "측정 결과를 기록하며 사텐과 서로의 강점을 이야기했다. 이후 사냥 환경에 높은 단계가 적용된다.", 23, 0, 100, 0, 1, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(14, 2, "검사 뒤 회복실로 간다", "측정은 기본 검사로 끝냈다. 회복실에서 컨디션을 되찾는다.", 0, 0, 0, 0, 0, 0, 0.0, 50, 0, 0)
        call ProtoSetScene(15, 1, "풍기위원의 순찰", "쿠로코가 골목 입구를 지키고 우이하루는 무전으로 도주 경로를 찾는다. 사람을 한쪽으로 몰아 검거를 돕거나, 먼저 통행인을 대피시킬 수 있다.", 0, 0)
        call ProtoSetBranch(15, 1, "골목의 도주로를 막는다", "쿠로코가 공간이동으로 도주자를 제압한다. 남은 무리가 당신 쪽으로 몰려든다.", 22, 0, 0, 0, 0, 2, 0.0, 0, 0, 0)
        call ProtoSetBranch(15, 2, "우이하루에게 우회로를 전한다", "통행인이 안전하게 빠져나갔다. 우이하루가 정보를 정리해 다음 상황을 읽기 쉽게 해 준다.", 38, 0, 0, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(16, 1, "같은 얼굴의 소녀", "고글을 쓴 소녀가 똑같은 얼굴이 찍힌 실험 기록을 떨어뜨린다. 번호가 적힌 명찰을 보고 말을 걸자, 소녀는 이 일을 모른 척해도 된다고 말한다.", 0, 0)
        call ProtoSetBranch(16, 1, "기록을 돌려주고 이유를 묻는다", "미사카 동생은 실험의 존재를 털어놓는다. 이 기록을 외면하지 않았다면 뒤이어 실험 현장에 접근할 수 있다.", 37, 0, 0, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(16, 2, "기록을 맡길 곳을 찾아 준다", "소녀에게 풍기위원의 연락처를 전했다. 위험한 실험에 직접 뛰어들지는 않는다.", 0, 0, 120, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(17, 1, "불행한 귀갓길", "토우마가 스킬 아웃에게 둘러싸인 학생을 빼내려 한다. 오른손으로 초능력을 지울 수 있어도 여러 사람의 주먹까지 한꺼번에 막을 수는 없다.", 0, 0)
        call ProtoSetBranch(17, 1, "토우마와 함께 학생을 빼낸다", "당신이 뒤를 맡는 동안 토우마가 학생을 대피시켰다. 추격자들이 늘지만 혼자 싸우지는 않았다.", 20, 0, 0, 0, 0, 2, 0.0, 0, 0, 0)
        call ProtoSetBranch(17, 2, "학생을 안전한 큰길로 안내한다", "먼저 탈출로를 확보했다. 학생의 보호자가 교통비와 수고비를 건넨다.", 0, 0, 150, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(18, 1, "게코타 경품", "경품 기계에 게코타 인형 하나가 걸려 있다. 미코토는 관심 없는 척하지만 시선은 계속 인형으로 향한다. 한 번 시도할 비용은 100골드다.", 0, 0)
        call ProtoSetBranch(18, 1, "100골드로 뽑기에 도전한다", "인형이 출구에 떨어졌다. 미코토가 받아 들고 잠깐 경계심을 내려놓는다.", 39, 0, 0, 100, 0, 0, 0.0, 0, 0, 50)
        call ProtoSetBranch(18, 2, "새 경품을 채우는 일을 돕는다", "기계 관리자가 진열 작업의 대가를 준다. 인형은 다음 사람에게 남겨 둔다.", 0, 0, 100, 0, 0, 0, 0.0, 0, 0, 0)
        set ProtoEventFailure[18] = "집게가 인형을 놓쳤다. 비용은 돌아오지 않는다. 미코토는 다음에는 기계를 탓하기 전에 실력을 보자고 웃는다."
        call ProtoSetScene(19, 1, "배고픈 마도서 도서관", "수녀복 차림의 인덱스가 배고프다며 길가에 앉아 있다. 식사를 사 주면 눈앞의 기묘한 흔적이 어떤 마술인지 설명해 주겠다고 한다.", 0, 0)
        call ProtoSetBranch(19, 1, "식사를 대접하고 설명을 듣는다", "인덱스가 식사를 마치고 마술의 구조를 풀어 준다. 지식은 얻었지만 식비는 만만하지 않았다.", 24, 0, 0, 250, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(19, 2, "토우마의 집까지 길을 알려 준다", "인덱스가 익숙한 이름을 듣고 일어선다. 남은 도시락으로 당신도 기운을 되찾는다.", 0, 0, 0, 0, 0, 0, 0.0, 30, 0, 0)
        call ProtoSetScene(20, 1, "도시전설 수첩", "사텐이 능력을 갑자기 높여 준다는 소문의 출처를 쫓는다. 근거가 불분명한 힘을 얻기보다 소문이 퍼지는 경로부터 확인해 보자는 제안을 받는다.", 0, 0)
        call ProtoSetBranch(20, 1, "사텐과 소문의 출처를 조사한다", "소문을 맹신하지 않고 증언을 모았다. 사텐의 수첩에 새 단서가 남는다.", 23, 0, 0, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(20, 2, "수상한 모집 장소의 위치를 신고한다", "풍기위원이 위험 지역을 정리한다. 이후 사냥터에 모이는 적이 줄어든다.", 0, 0, 80, 0, 0, -1, 0.0, 0, 0, 0)
        call ProtoSetScene(21, 1, "흰 머리 소년의 경고", "액셀러레이터가 통행을 막는다. 능력을 시험하려는 사람에게 좋은 꼴을 보일 생각이 없다며, 이 길을 계속 가면 위험해진다고 경고한다.", 0, 0)
        call ProtoSetBranch(21, 1, "위험을 인정하고 방어법을 관찰한다", "물체의 방향이 뒤집히는 모습을 지켜봤다. 위험한 경로를 감수한 대가로 벡터 제어의 기억이 남는다.", 21, 0, 0, 0, 1, 0, 0.0, -20, 0, 0)
        call ProtoSetBranch(21, 2, "경고를 받아들여 길을 바꾼다", "지름길을 포기하자 추격이 끊겼다. 안전한 경로가 사냥터에도 반영된다.", 0, 0, 0, 0, -1, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(22, 1, "길 잃은 검은 고양이", "미사카 동생이 품에 안고 있던 고양이를 놓쳤다. 소녀가 고양이를 부르자 근처 학생들까지 모여든다. 함께 찾아 줄지, 조용한 길을 알려 줄지 정한다.", 0, 0)
        call ProtoSetBranch(22, 1, "사람들을 불러 함께 찾는다", "고양이를 찾은 미사카 동생이 고맙다고 말한다. 모여든 사람의 흔적을 따라 사냥감도 늘어난다.", 37, 0, 0, 0, 0, 1, 0.0, 0, 0, 0)
        call ProtoSetBranch(22, 2, "조용한 골목으로 유도한다", "고양이가 소녀에게 돌아갔다. 주변이 조용해지고 몬스터가 모이는 수가 줄어든다.", 0, 0, 0, 0, 0, -1, 0.0, 0, 0, 0)
        call ProtoSetScene(23, 1, "정보 검색의 전문가", "우이하루가 끊어진 CCTV 기록을 복구하고 있다. 분석에 필요한 장비를 빌려 주거나, 직접 거리에서 남은 흔적을 찾아 올 수 있다.", 0, 0)
        call ProtoSetBranch(23, 1, "분석 장비 사용료를 낸다", "복구된 영상에서 여러 경로를 확인했다. 우이하루의 정보 지원을 얻는다.", 38, 0, 0, 150, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(23, 2, "거리의 흔적을 수집해 온다", "직접 가져온 기록이 분석의 빈칸을 채웠다. 장비 비용 대신 수고비를 받는다.", 0, 0, 100, 0, 0, 0, 0.0, 20, 0, 0)
        call ProtoSetScene(24, 1, "야간 무전", "풍기위원의 무전이 혼잡하다. 쿠로코는 긴급 출동에 집중해야 하고 우이하루는 시민 신고를 분류할 일손을 찾는다.", 0, 0)
        call ProtoSetBranch(24, 1, "긴급 현장에 동행한다", "쿠로코의 이동을 따라 구조를 도왔다. 이후에도 높은 위험을 감수하게 된다.", 22, 0, 0, 0, 1, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(24, 2, "신고를 분류하고 위험 구역을 표시한다", "우이하루가 당신의 표를 다음 순찰에 사용한다. 위험한 길을 하나 피했다.", 0, 0, 120, 0, -1, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(25, 2, "황금의 순간", "에이딘 공원에서 좋은꿈 슬롯머신의 불빛이 돌아간다. 옆에는 솔글래드 음료가 진열되어 있다. 토큰을 사서 기계를 돌릴지, 음료를 들고 밤거리를 구경할지 고른다.", 0, 0)
        call ProtoSetBranch(25, 1, "토큰을 사서 슬롯머신을 돌린다", "그림이 일렬로 맞춰졌다. 기계가 쏟아낸 당첨금과 좋은꿈 슬롯머신의 기억을 챙긴다.", 41, 0, 200, 100, 0, 0, 0.0, 0, 0, 50)
        call ProtoSetBranch(25, 2, "솔글래드를 마시며 거리를 걷는다", "탄산의 달콤함과 거리의 불빛이 긴장을 풀어 준다. 솔글래드의 기억을 챙겼다.", 43, 0, 0, 0, 0, 0, 0.0, 20, 0, 0)
        set ProtoEventFailure[25] = "그림이 한 칸 어긋났다. 토큰 값은 돌려받지 못했지만 다음 판의 유혹이 남는다."
        call ProtoSetScene(26, 2, "반디의 안내", "반디가 복잡한 황금의 순간을 안내해 주겠다고 한다. 붐비는 놀이시설을 함께 돌거나, 사람 적은 곳에서 꿈에 대한 이야기를 들을 수 있다.", 0, 0)
        call ProtoSetBranch(26, 1, "반디와 놀이시설을 돌아본다", "반디와 시간을 보냈다. 그녀는 다음에는 꿈의 경계 쪽의 조용한 곳을 보여 주겠다고 한다.", 25, 0, 0, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(26, 2, "조용한 벤치에서 이야기한다", "꿈에서 잠시 누리는 자유에 대해 들었다. 충분히 쉬고 준비를 마친다.", 0, 0, 0, 0, 0, 0, 0.0, 60, 1, 0)
        call ProtoSetScene(27, 2, "어벤츄린의 판돈", "어벤츄린이 자신의 칩을 굴리며 승부를 제안한다. 결과를 장담할 수는 없지만, 잃을 각오가 있다면 함께 판을 키울 수 있다.", 0, 0)
        call ProtoSetBranch(27, 1, "200골드를 걸고 승부한다", "승부가 당신 쪽으로 기울었다. 어벤츄린의 기억과 당첨금을 얻는다.", 27, 0, 300, 200, 0, 0, 0.0, 0, 0, 50)
        call ProtoSetBranch(27, 2, "승부 대신 칩 정리를 돕는다", "판돈을 걸지 않고 테이블 정리를 도왔다. 수고비만 받아 떠난다.", 0, 0, 100, 0, 0, 0, 0.0, 0, 0, 0)
        set ProtoEventFailure[27] = "칩이 상대에게 넘어갔다. 어벤츄린은 다음 판에도 같은 각오로 앉을 수 있겠냐고 묻는다."
        call ProtoSetScene(28, 2, "시계 소년의 부탁", "클락이 지나가는 사람에게는 보이지 않는 듯하다. 멈춘 꿈의 장치를 가리키며 수리를 부탁한다. 장치에 모인 꿈의 조각을 옮기거나 동선을 정리할 수 있다.", 0, 0)
        call ProtoSetBranch(28, 1, "클락과 장치를 고친다", "톱니가 다시 맞물리고 장치가 움직였다. 꿈의 안내자인 클락의 기억을 얻는다.", 42, 0, 0, 0, 0, 1, 0.0, 0, 0, 0)
        call ProtoSetBranch(28, 2, "막힌 통로부터 정리한다", "소란이 줄어들고 사람들이 지나간다. 사냥터에도 여유 공간이 생긴다.", 0, 0, 120, 0, 0, -1, 0.0, 0, 0, 0)
        call ProtoSetScene(29, 2, "가면을 쓴 안내인", "같은 안내인이 골목마다 다른 얼굴로 나타난다. 스파클은 정답이 있는 길이라면 재미없다며 가면을 내민다. 그녀의 연극에 참여할지, 관객으로 남을지 고른다.", 0, 0)
        call ProtoSetBranch(29, 1, "가면극의 배역을 맡는다", "예상 밖의 장면을 연기했다. 선택할 수 있는 길이 넓어지지만 이후의 상대도 까다로워진다.", 29, 0, 0, 0, 1, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(29, 2, "객석에서 끝까지 지켜본다", "무대 밖에서는 소란에 휘말리지 않았다. 관객 몫의 기념품을 받는다.", 0, 0, 120, 0, 0, 0, 0.0, 0, 1, 0)
        call ProtoSetScene(30, 2, "블러드하운드의 바", "갤러거가 바의 혼잡한 분위기를 정리하고 있다. 취향에 맞춘 한 잔을 부탁하거나, 바깥의 소란을 함께 막아 줄 수 있다.", 0, 0)
        call ProtoSetBranch(30, 1, "소란을 막는 일을 돕는다", "갤러거가 자신의 방식으로 섞은 음료를 건넨다. 꿈속에서 쉬는 감각이 남는다.", 30, 0, 0, 0, 0, 1, 0.0, 0, 0, 0)
        call ProtoSetBranch(30, 2, "조용한 자리에서 쉬어 간다", "바의 소음에서 벗어나 컨디션을 회복했다.", 0, 0, 0, 0, 0, 0, 0.0, 60, 0, 0)
        call ProtoSetScene(31, 2, "길을 묻는 아케론", "아케론이 목적지의 방향을 묻는다. 안내판을 보면서도 다른 곳으로 걷기 시작한다. 길을 함께 찾아 주거나 표식만 남겨 줄 수 있다.", 0, 0)
        call ProtoSetBranch(31, 1, "위험한 골목까지 함께 걷는다", "긴 침묵 속에서 낯선 힘의 흔적을 느꼈다. 동행은 위험했지만 아케론의 기억이 남는다.", 26, 0, 0, 0, 1, 0, 0.0, -20, 0, 0)
        call ProtoSetBranch(31, 2, "목적지까지 표식을 남긴다", "지도를 고쳐 주고 각자의 길로 향했다. 남은 보급을 나누어 받는다.", 0, 0, 120, 0, 0, 0, 0.0, 0, 1, 0)
        call ProtoSetScene(32, 2, "리허설 중인 목소리", "빈 객석에 로빈의 노래가 울린다. 공연을 방해하는 잡음을 해결할 일손이 필요하다. 무대 뒤를 정리하거나 객석에서 소리를 확인해 줄 수 있다.", 0, 0)
        call ProtoSetBranch(32, 1, "무대 뒤의 장비를 정리한다", "노래가 잡음 없이 이어진다. 함께 부르는 노래의 기억을 얻었다.", 28, 0, 0, 100, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(32, 2, "객석에서 소리를 확인한다", "리허설을 듣는 동안 마음이 가라앉았다. 컨디션을 회복하고 수고비를 받는다.", 0, 0, 80, 0, 0, 0, 0.0, 40, 0, 0)
        call ProtoSetScene(33, 2, "꿈을 짓는 공사장", "꿈의 경계에서 드림위버가 끊어진 길을 만들고 있다. 자재를 더 가져오면 새 길이 열리지만 위험한 구간으로도 이어진다고 한다.", 0, 0)
        call ProtoSetBranch(33, 1, "자재 운반을 돕는다", "꿈의 장치가 새 통로를 만들었다. 위험은 커졌지만 클락의 안내를 따라갈 여지가 늘었다.", 42, 0, 0, 0, 1, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(33, 2, "안전한 통로에 표식을 남긴다", "공사 구간을 피해 갈 수 있게 됐다. 이후 사냥터의 위험이 줄어든다.", 0, 0, 80, 0, -1, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(34, 2, "솔글래드 광고판", "떠들썩한 솔글래드 광고판 앞에 사람들이 모여 있다. 음료 진열을 도우면 시음을 할 수 있고, 군중을 정리하면 보수를 받을 수 있다.", 0, 0)
        call ProtoSetBranch(34, 1, "진열을 돕고 솔글래드를 시음한다", "음료가 손에 들리자 달콤한 냄새가 퍼졌다. 솔글래드의 기억이 남는다.", 43, 0, 0, 0, 0, 0, 0.0, 20, 0, 0)
        call ProtoSetBranch(34, 2, "관람객의 동선을 정리한다", "혼잡한 거리가 정리됐다. 보수를 받고 사냥터의 적도 덜 모이게 한다.", 0, 0, 120, 0, 0, -1, 0.0, 0, 0, 0)
        call ProtoSetScene(35, 2, "종이접기 새의 숨바꼭질", "광고 장식 틈에서 종이접기 새의 꼬리가 보인다. 다른 장식에도 새가 숨어 있을지 모른다. 하나씩 찾아 줄지, 일단 가까운 새만 빼 줄지 고른다.", 0, 0)
        call ProtoSetBranch(35, 1, "장식 사이의 새를 모두 찾아 준다", "새들이 꿈의 길을 알려 준다. 클락의 안내와 연결되는 기억을 얻었다.", 42, 0, 0, 100, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(35, 2, "가까운 새를 빼 주고 길을 묻는다", "짧은 도움으로 안전한 길을 찾았다. 적이 모이는 수가 줄어든다.", 0, 0, 0, 0, 0, -1, 0.0, 20, 0, 0)
        call ProtoSetScene(36, 2, "호텔의 꿈 입구", "꿈에 들어갈 준비가 된 객실이다. 프런트에서는 깊은 꿈의 구간에 관한 안내를 건넨다. 위험한 구간의 정보를 사거나 잠시 휴식을 취할 수 있다.", 0, 0)
        call ProtoSetBranch(36, 1, "깊은 꿈의 안내를 받는다", "꿈의 위험에 대비하는 기록을 챙겼다. 더 강한 적이 기다리지만 힘을 쓸 단서를 얻는다.", 0, 0, 0, 150, 1, 0, 20.0, 0, 0, 0)
        call ProtoSetBranch(36, 2, "꿈 욕조 옆에서 잠시 쉬어 간다", "꿈과 현실 사이에서 컨디션을 회복하고 보급을 챙겼다.", 0, 0, 0, 0, 0, 0, 0.0, 50, 1, 0)
        call ProtoSetScene(37, 3, "붉은 저택의 문", "메이링이 홍마관 문을 지키고 있다. 몰래 들어가기보다 방문 목적을 말하라고 한다. 정식으로 대련을 신청하거나 문 앞 일을 도울 수 있다.", 0, 0)
        call ProtoSetBranch(37, 1, "문지기에게 대련을 신청한다", "메이링의 자세를 가까이서 배웠다. 이후에는 더 강한 상대를 감당해야 한다.", 34, 0, 0, 0, 1, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(37, 2, "방문객의 줄을 정리한다", "몰래 넘어가는 대신 문 앞 일을 끝냈다. 수고비를 받는다.", 0, 0, 150, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(38, 3, "도서관의 책더미", "소악마가 책더미 사이에서 반납 목록을 찾는다. 파츄리는 읽던 책에서 눈을 떼지 않는다. 흩어진 책을 모아 돌려줄지, 목록만 찾아 줄지 정한다.", 0, 0)
        call ProtoSetBranch(38, 1, "흩어진 책을 모아 분류한다", "소악마와 서가를 정리했다. 도서관의 기억을 얻지만 주변에 더 많은 적이 모인다.", 45, 0, 0, 0, 0, 2, 0.0, 0, 0, 0)
        call ProtoSetBranch(38, 2, "반납 목록부터 찾아 준다", "책을 잘못 꽂는 일은 피했다. 목록을 되찾은 보수를 받는다.", 0, 0, 120, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(39, 3, "문지기의 수련", "메이링이 문 앞에서 몸을 풀며 기의 흐름을 설명한다. 더 강한 상대를 가정해 수련하거나 호흡을 정리하는 법을 배울 수 있다.", 0, 0)
        call ProtoSetBranch(39, 1, "실전 강도의 수련을 한다", "호흡과 자세를 익혔다. 거친 사냥을 감수하는 대신 메이링의 기억을 챙긴다.", 34, 0, 100, 0, 1, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(39, 2, "호흡을 고르고 휴식한다", "무리한 대련 대신 몸을 돌봤다. 다음 전투를 위한 컨디션을 되찾는다.", 0, 0, 0, 0, 0, 0, 0.0, 60, 0, 0)
        call ProtoSetScene(40, 3, "메이드의 빠진 일정", "사쿠야가 접시 수를 세며 손님맞이 일정을 맞춘다. 어느 순간 정리된 접시가 한꺼번에 나타난다. 당신은 시간을 멈출 수 없으니 맡을 일을 고르라고 한다.", 0, 0)
        call ProtoSetBranch(40, 1, "식당 준비를 끝까지 돕는다", "멈춘 시간 사이에서 일하는 메이드의 흐름을 엿봤다. 사쿠야의 기억을 얻는다.", 32, 0, 0, 100, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(40, 2, "남은 물자를 운반한다", "정해진 시간 안에 물자를 옮겼다. 보수와 회복을 챙긴다.", 0, 0, 100, 0, 0, 0, 0.0, 30, 0, 0)
        call ProtoSetScene(41, 3, "지하실의 놀이 초대", "지하실에서 플랑드르가 놀자고 부른다. 손에 든 것이 쉽게 부서져 버린다. 잠깐 구경하는 것만으로 끝낼지, 위험을 알고도 함께 놀지 정해야 한다.", 0, 0)
        call ProtoSetBranch(41, 1, "위험을 감수하고 함께 논다", "부서지는 힘을 가까이서 목격했다. 상처와 높아진 위험을 대가로 플랑드르의 기억을 얻는다.", 36, 0, 0, 300, 2, 0, 0.0, -30, 0, 0)
        call ProtoSetBranch(41, 2, "문밖에서 이야기를 들려준다", "안으로 들어가지는 않았다. 이야기로 시간을 보내고 보급을 받는다.", 0, 0, 120, 0, 0, 0, 0.0, 0, 1, 0)
        call ProtoSetScene(42, 3, "주인의 초대", "레밀리아가 창밖의 햇빛을 가리고 손님을 맞는다. 운명에 관한 말을 듣고 저택 깊은 곳으로 따라갈지, 응접실에서 인사를 마칠지 정한다.", 0, 0)
        call ProtoSetBranch(42, 1, "주인의 시험을 받아들인다", "붉은 저택의 위험을 받아들였다. 레밀리아의 기억이 공격에 남는다.", 31, 0, 0, 0, 1, 0, 0.0, -20, 0, 0)
        call ProtoSetBranch(42, 2, "응접실에서 정중히 인사를 마친다", "시험에는 참가하지 않았다. 손님 몫의 물약을 챙긴다.", 0, 0, 0, 0, 0, 0, 0.0, 40, 1, 0)
        call ProtoSetScene(43, 3, "안개 속의 루미아", "홍마관 밖의 길에서 어둠 덩어리가 움직인다. 루미아는 주변이 보이지 않아 자꾸 나무에 부딪힌다. 어둠 속으로 들어가 길을 알려 주거나 멀리서 불러낼 수 있다.", 0, 0)
        call ProtoSetBranch(43, 1, "어둠 속에서 길을 안내한다", "보이지 않는 길을 함께 걸었다. 루미아의 어둠에 익숙해지는 기억을 얻는다.", 35, 0, 0, 0, 0, 0, 0.0, -15, 0, 0)
        call ProtoSetBranch(43, 2, "멀리서 소리로 길을 알려 준다", "어둠에 들어가지 않고 길을 찾았다. 사냥터에 모이는 적을 줄인다.", 0, 0, 80, 0, 0, -1, 0.0, 0, 0, 0)
        call ProtoSetScene(44, 3, "찻잔과 마도서", "파츄리가 찻잔 옆에 펼친 책을 가리킨다. 책에 묻은 먼지를 털면 읽는 내용을 조금 설명해 주겠다고 한다. 손님용 차를 준비하는 일도 남아 있다.", 0, 0)
        call ProtoSetBranch(44, 1, "책을 정리하고 설명을 듣는다", "여러 속성의 마법에 관한 설명을 들었다. 파츄리의 기억을 얻는다.", 33, 0, 0, 150, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(44, 2, "찻잔을 씻고 휴식한다", "마법 지식 대신 차와 휴식을 챙겼다. 보급도 조금 남았다.", 0, 0, 0, 0, 0, 0, 0.0, 50, 1, 0)
        call ProtoSetScene(45, 3, "빌려 간 책", "마리사가 책을 빌렸다고 주장하며 저택을 빠져나가려 한다. 소악마는 반납 기록이 없다고 말한다. 책을 돌려받을지, 마리사의 탈출을 도울지 정한다.", 0, 0)
        call ProtoSetBranch(45, 1, "마리사와 함께 빠져나간다", "책 문제를 뒤로 미루고 빠져나왔다. 마리사의 기억을 얻지만 추격이 늘어난다.", 47, 0, 0, 0, 0, 2, 0.0, 0, 0, 0)
        call ProtoSetBranch(45, 2, "책을 되찾아 도서관에 돌려준다", "반납 도장이 찍혔다. 책의 내용을 잠깐 읽을 기회를 얻는다.", 46, 0, 0, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(46, 3, "복도의 요정 메이드", "요정 메이드들이 복도를 어지럽혔다. 사쿠야가 돌아오기 전에 정리하려면 모아서 일을 시키거나, 동선을 나눠야 한다.", 0, 0)
        call ProtoSetBranch(46, 1, "메이드들을 모아 한꺼번에 정리한다", "정리는 끝났지만 뒤따라오는 소란이 커졌다. 사쿠야의 일 처리 방식을 배웠다.", 32, 0, 0, 0, 0, 2, 0.0, 0, 0, 0)
        call ProtoSetBranch(46, 2, "동선을 나누고 복도를 비운다", "소란 없이 정리가 끝났다. 사냥터에도 여유가 생기고 보수를 받는다.", 0, 0, 150, 0, 0, -1, 0.0, 0, 0, 0)
        call ProtoSetScene(47, 3, "호숫가의 얼음 자랑", "저택으로 향하는 호숫가에서 치르노가 자신이 가장 강하다며 얼음을 보여 준다. 시범을 가까이서 보거나, 얼음 때문에 막힌 길부터 열 수 있다.", 0, 0)
        call ProtoSetBranch(47, 1, "얼음 시범을 받아 준다", "얼음이 깨지는 순간을 보며 치르노의 힘을 기억했다. 이후 훈련도 더 거칠어진다.", 48, 0, 0, 0, 1, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(47, 2, "얼음으로 막힌 길을 연다", "자랑을 겨루는 대신 통로를 만들었다. 보수와 회복을 챙긴다.", 0, 0, 120, 0, 0, 0, 0.0, 30, 0, 0)
        call ProtoSetScene(48, 3, "저택의 밤 연회", "해가 지자 레밀리아가 연회를 시작한다. 메이드들은 바쁘게 움직이고 도서관은 여전히 조용하다. 주인의 이야기 속에 끼거나 뒤에서 연회를 도울 수 있다.", 0, 0)
        call ProtoSetBranch(48, 1, "운명에 관한 이야기를 청한다", "레밀리아가 손님의 질문에 답한다. 비용을 치르고 주인의 기억을 남긴다.", 31, 0, 0, 250, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(48, 2, "연회의 뒤처리를 맡는다", "저택의 손님이 떠난 뒤 정리를 마쳤다. 넉넉한 보수를 받는다.", 0, 0, 200, 0, 0, 0, 0.0, 30, 0, 0)
        call ProtoSetScene(49, 0, "5엔의 의뢰", "벽에 붙은 전화번호로 연락하자 야토가 나타난다. 5엔 신이라며 아주 작은 의뢰도 받겠다고 한다. 부탁할 일이 있는지 묻는다.", 0, 0)
        call ProtoSetBranch(49, 1, "5엔을 주고 사냥을 도와 달라고 한다", "야토가 의뢰를 받아들였다. 작은 부탁에서 이어진 인연의 기억이 남는다.", 13, 0, 0, 5, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(49, 2, "전화번호 전단 붙이기를 돕는다", "야토가 새 의뢰를 받도록 홍보를 도왔다. 일한 보수를 받는다.", 0, 0, 150, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(50, 0, "검사의 사냥터 정리", "키리토가 몬스터가 모이는 구간을 살핀다. 한 번에 더 많은 적을 상대하며 공격의 궤적을 익힐지, 안전한 동선을 확보할지 고른다.", 0, 0)
        call ProtoSetBranch(50, 1, "키리토와 무리를 끌어 모은다", "한 번에 많은 적을 상대하는 검의 움직임을 익혔다. 사냥터의 적 수가 늘어난다.", 16, 0, 0, 0, 0, 2, 0.0, 0, 0, 0)
        call ProtoSetBranch(50, 2, "동선을 정리해 작은 무리로 나눈다", "좁은 길의 위험을 줄였다. 정리 보수를 받고 적 수를 낮춘다.", 0, 0, 100, 0, 0, -1, 0.0, 0, 0, 0)
        call ProtoSetScene(51, 0, "나나미의 추가 근무", "나나미가 남은 위험 구간을 살펴본다. 초과 근무를 좋아하지 않는다면서도 해야 할 일을 정리한다. 함께 위험한 업무를 마칠지 기본 업무만 끝낼지 묻는다.", 0, 0)
        call ProtoSetBranch(51, 1, "더 위험한 업무를 함께 맡는다", "추가 업무를 마친 보수를 받았다. 이후에도 더 강한 사냥감을 상대하게 된다.", 0, 0, 250, 0, 1, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(51, 2, "기본 업무만 마치고 돌아간다", "무리한 일을 늘리지 않았다. 이후 사냥의 위험을 한 단계 낮춘다.", 0, 0, 0, 0, -1, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(52, 0, "유메코의 주사위 탁자", "유메코가 판돈을 보고 웃는다. 주사위가 4 이상이면 이기고 3 이하면 잃는 승부다. 결과보다 위험 그 자체에 들뜬 그녀의 권유를 받아들일지 고른다.", 0, 0)
        call ProtoSetBranch(52, 1, "200골드를 걸고 주사위를 던진다", "좋은 눈이 나왔다. 유메코와 승부한 기억, 그리고 당첨금을 챙겼다.", 15, 0, 200, 200, 0, 0, 0.0, 0, 0, 50)
        call ProtoSetBranch(52, 2, "판돈 정산을 도와주고 떠난다", "승부에는 앉지 않고 장부 정리를 도왔다. 보수를 받는다.", 0, 0, 80, 0, 0, 0, 0.0, 0, 0, 0)
        set ProtoEventFailure[52] = "주사위가 낮은 눈을 보였다. 판돈을 잃었지만 유메코는 위험한 승부였다며 즐거워한다."
        call ProtoSetScene(53, 0, "대방패 뒤의 쉼터", "메이플이 대방패 뒤로 들어오라고 손짓한다. 안전한 곳에서 방어하는 요령을 배울지, 가져온 물자를 정리할지 고른다.", 0, 0)
        call ProtoSetBranch(53, 1, "메이플에게 방어하는 법을 배운다", "막는 데 집중하는 전투를 지켜봤다. 절대 방어의 기억이 남는다.", 17, 0, 0, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(53, 2, "물자를 분류하고 쉬어 간다", "훈련 대신 물자 정리를 끝냈다. 보수와 회복을 받는다.", 0, 0, 150, 0, 0, 0, 0.0, 20, 0, 0)
        call ProtoSetScene(54, 0, "소라의 불리한 판", "소라가 불리한 규칙을 가리키며 지금도 이길 길은 있다고 한다. 위험한 조건을 받아들여 공격의 빈틈을 찾거나 안전한 상태로 다시 시작할 수 있다.", 0, 0)
        call ProtoSetBranch(54, 1, "불리한 조건에서 승부를 이어 간다", "불리한 판에서 공격의 빈틈을 읽었다. 적은 강해지지만 피해가 증가한다.", 0, 0, 0, 0, 1, 0, 15.0, 0, 0, 0)
        call ProtoSetBranch(54, 2, "오늘의 판을 접고 충분히 쉰다", "더 이상 판을 키우지 않았다. 다음 사냥을 위해 생명력을 모두 회복한다.", 0, 0, 0, 0, 0, 0, 0.0, 100, 0, 0)
        call ProtoSetScene(55, 0, "야토의 작은 사당", "야토가 자기 사당이 생길 자리를 가리킨다. 지금은 재료가 부족하다. 재료비를 보태거나 자리를 정리해 줄 수 있다.", 0, 0)
        call ProtoSetBranch(55, 1, "5골드로 작은 재료를 보탠다", "작은 사당의 재료가 늘었다. 야토가 의뢰를 기억하겠다고 한다.", 13, 0, 0, 5, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(55, 2, "터를 정리하고 물건을 옮긴다", "재료 대신 노동을 보탰다. 보수와 물약을 받는다.", 0, 0, 100, 0, 0, 0, 0.0, 0, 1, 0)
        call ProtoSetScene(56, 0, "십획의 약점", "나나미가 표적의 길이를 가늠한다. 일곱 대 셋으로 나눠 약점을 만드는 모습을 배울지, 표적 운반 일을 맡을지 선택한다.", 0, 0)
        call ProtoSetBranch(56, 1, "약점을 만드는 시범을 배운다", "길이의 비율로 만들어진 약점에 일격이 들어갔다. 십획주법의 기억을 얻는다.", 14, 0, 0, 150, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(56, 2, "연습용 표적을 운반한다", "시범은 멀리서 보고 일한 보수를 받는다.", 0, 0, 120, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(57, 0, "검은 검사의 지도", "키리토가 안전 구간과 위험 구간을 지도에 표시한다. 위험한 사냥터를 함께 돌거나 지도 제작을 끝낼 수 있다.", 0, 0)
        call ProtoSetBranch(57, 1, "위험 구간을 함께 조사한다", "검을 쓰는 움직임을 가까이서 익혔다. 강한 상대의 위험도 함께 남는다.", 16, 0, 0, 0, 1, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(57, 2, "안전 구간의 지도를 완성한다", "완성된 지도를 나누어 주었다. 보수와 낮아진 위험을 챙긴다.", 0, 0, 150, 0, -1, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(58, 0, "메이플의 느긋한 모험", "메이플은 급히 달려가기보다 주변을 하나씩 살펴보자고 한다. 눈앞의 공격을 막으며 길을 열거나 옆길로 안전하게 돌아갈 수 있다.", 0, 0)
        call ProtoSetBranch(58, 1, "방패 뒤에서 길을 연다", "차분히 공격을 받아내는 모습을 배웠다. 생존의 기억이 남는다.", 17, 0, 0, 0, 0, 0, 0.0, -15, 0, 0)
        call ProtoSetBranch(58, 2, "옆길로 돌아가 휴식한다", "서두르지 않고 안전한 길을 택했다. 충분히 회복한다.", 0, 0, 0, 0, 0, 0, 0.0, 70, 0, 0)
        call ProtoSetScene(59, 0, "소라의 규칙 읽기", "소라가 이번 승부의 규칙을 손으로 짚는다. 정면 승부의 비용보다 규칙의 빈틈이 더 중요하다고 한다. 분석을 함께할지 심판 일을 도울지 고른다.", 0, 0)
        call ProtoSetBranch(59, 1, "규칙 분석 비용을 보탠다", "다음 수를 읽는 방법을 배웠다. 사건 후보가 더 많이 보인다.", 18, 0, 0, 250, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(59, 2, "심판의 기록을 정리한다", "규칙을 바꾸는 대신 기록을 정리했다. 수고비를 받는다.", 0, 0, 150, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(60, 0, "유메코의 관전석", "유메코가 다음 승부를 지켜보고 있다. 그녀는 작은 판돈보다 크게 흔들릴 순간에 관심이 있다. 관전료를 낼지 자리 정리를 도울지 선택한다.", 0, 0)
        call ProtoSetBranch(60, 1, "관전료를 내고 승부를 끝까지 본다", "위험을 즐기는 눈빛을 가까이서 보았다. 유메코의 기억을 얻는다.", 15, 0, 0, 150, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(60, 2, "자리를 정리하고 수고비를 받는다", "승부에 끼지 않고 관전석을 정리했다. 보수를 받는다.", 0, 0, 120, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(61, 0, "의뢰 전화의 행방", "야토의 전화가 울리지만 주변 소음 때문에 내용을 듣기 어렵다. 함께 조용한 곳을 찾아 주거나 다른 일을 대신 맡을 수 있다.", 0, 0)
        call ProtoSetBranch(61, 1, "조용한 길로 의뢰인을 안내한다", "짧은 부탁이 끝났다. 야토의 기억을 얻는다.", 13, 0, 0, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(61, 2, "주변 물자를 정리한다", "의뢰를 방해하던 짐을 정리했다. 보수와 회복을 받는다.", 0, 0, 120, 0, 0, 0, 0.0, 20, 0, 0)
        call ProtoSetScene(62, 0, "퇴근 시간의 원칙", "나나미가 시계를 보고 추가 업무 여부를 정한다. 위험한 구간을 남기고 퇴근할지, 대가를 받고 업무를 연장할지 묻는다.", 0, 0)
        call ProtoSetBranch(62, 1, "보수를 받고 업무를 연장한다", "맡은 일은 끝까지 처리했다. 이후의 적이 강해지는 대가로 보수와 경험을 받는다.", 14, 0, 100, 0, 1, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(62, 2, "위험 구간을 닫고 퇴근한다", "업무를 더 늘리지 않았다. 사냥터의 위험도 낮아진다.", 0, 0, 0, 0, -1, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(63, 0, "첫 보스의 공략 회의", "키리토가 처음 보스에 도전하는 사람들에게 움직임을 설명한다. 표적을 나눠 맡는 훈련을 할지 보급 전달을 맡을지 정한다.", 0, 0)
        call ProtoSetBranch(63, 1, "공략 훈련에 참가한다", "표적을 상대하는 검의 움직임을 익혔다. 다음 사냥에 더 많은 상대가 모인다.", 16, 0, 0, 0, 0, 2, 0.0, 0, 0, 0)
        call ProtoSetBranch(63, 2, "공략대에 보급을 전달한다", "직접 훈련하지 않고 보급을 지원했다. 보수와 물약을 받는다.", 0, 0, 120, 0, 0, 0, 0.0, 0, 1, 0)
        call ProtoSetScene(64, 0, "대방패의 시범", "메이플이 위험한 구간 앞에서 대방패를 세운다. 무모하게 달려들기보다 먼저 견뎌 보자고 한다. 방어를 배울지, 위험을 피해 통로를 바꿀지 고른다.", 0, 0)
        call ProtoSetBranch(64, 1, "공격을 막는 모습을 지켜본다", "막는 것부터 익혔다. 메이플의 기억을 얻는다.", 17, 0, 0, 100, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(64, 2, "위험 구간을 피해 통로를 바꾼다", "직접 견디는 일은 피했다. 적이 모이는 수가 줄고 몸을 회복한다.", 0, 0, 0, 0, 0, -1, 0.0, 40, 0, 0)
        call ProtoSetScene(65, 0, "유메코의 다음 승부", "첫 주사위 승부 뒤 유메코가 다시 자리를 권한다. 이번에도 결과는 보장되지 않는다. 기억보다 돈을 노리는 판이다.", 52, 1)
        call ProtoSetBranch(65, 1, "300골드로 한 번 더 승부한다", "판이 당신 쪽으로 기울었다. 큰 당첨금을 받는다.", 0, 0, 700, 300, 0, 0, 0.0, 0, 0, 50)
        call ProtoSetBranch(65, 2, "이번에는 관전료만 받는다", "추가 판돈은 걸지 않았다. 지나친 승부를 멈추고 작은 보수를 챙긴다.", 0, 0, 100, 0, 0, 0, 0.0, 0, 0, 0)
        set ProtoEventFailure[65] = "판돈이 상대에게 넘어갔다. 이번 승부의 결과는 손실로 남는다."
        call ProtoSetScene(66, 0, "빈칸의 승리 선언", "소라가 결과보다 과정의 기록을 확인한다. 앞서 읽었던 규칙을 새 상황에 적용하거나 심판의 판정을 받아들일 수 있다.", 59, 1)
        call ProtoSetBranch(66, 1, "분석을 새 승부에 적용한다", "다음 수를 읽는 경험이 공격에 이어진다. 상대도 더 강해지는 조건을 받는다.", 0, 0, 0, 0, 1, 0, 25.0, 0, 0, 0)
        call ProtoSetBranch(66, 2, "결과를 확정하고 보수를 받는다", "더 이상의 승부를 열지 않고 기록을 마무리했다. 보수를 챙긴다.", 0, 0, 200, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(67, 0, "야토에게 돌아온 의뢰인", "작은 사당의 재료를 보탠 뒤 새로운 의뢰인이 왔다. 야토는 자신을 찾는 사람이 늘었다며 의기양양하다.", 55, 1)
        call ProtoSetBranch(67, 1, "새 의뢰를 함께 처리한다", "작은 의뢰들이 다음 일로 이어졌다. 힘과 의뢰 보수를 얻는다.", 0, 0, 100, 0, 0, 0, 15.0, 0, 0, 0)
        call ProtoSetBranch(67, 2, "연락처만 전달하고 쉬어 간다", "이번 일에는 깊게 관여하지 않았다. 의뢰 보수와 회복을 챙긴다.", 0, 0, 150, 0, 0, 0, 0.0, 40, 0, 0)
        call ProtoSetScene(68, 0, "끝나지 않은 장부", "추가 근무를 마친 나나미가 남은 정산표를 확인한다. 약점을 배울 시간을 요청하거나 오늘의 보수만 정산할 수 있다.", 51, 1)
        call ProtoSetBranch(68, 1, "십획주법의 시범을 부탁한다", "추가 업무를 맡았던 대가로 시범을 가까이서 봤다. 나나미의 기억을 얻는다.", 14, 0, 0, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(68, 2, "보수만 정산하고 돌아간다", "더 늦어지기 전에 장부를 마쳤다. 추가 정산금을 받는다.", 0, 0, 180, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(69, 0, "표시해 둔 안전 구간", "키리토와 만든 지도에 위험 구간의 변화가 적혀 있다. 더 높은 난도의 자료를 모으거나 안전 경로를 유지할 수 있다.", 57, 1)
        call ProtoSetBranch(69, 1, "변한 위험 구간을 다시 조사한다", "검의 궤적을 더 정교하게 다듬었다. 높은 위험을 받아들인 만큼 힘을 얻는다.", 0, 0, 0, 0, 1, 0, 20.0, 0, 0, 0)
        call ProtoSetBranch(69, 2, "안전 경로를 계속 사용한다", "당장 강한 적을 만나지 않는 길을 유지했다. 위험을 낮추고 보급을 받는다.", 0, 0, 0, 0, -1, 0, 0.0, 0, 1, 0)
        call ProtoSetScene(70, 0, "방패 뒤의 동료", "방어법을 배웠던 메이플이 뒤에서 맡을 일을 묻는다. 더 많은 적을 모아 동료를 지킬지, 쉴 틈을 만들지 정한다.", 53, 1)
        call ProtoSetBranch(70, 1, "동료 쪽의 적을 끌어온다", "더 많은 적을 상대하는 법을 배웠다. 피해가 늘지만 사냥터도 붐빈다.", 0, 0, 0, 0, 0, 2, 20.0, 0, 0, 0)
        call ProtoSetBranch(70, 2, "방패 뒤에 쉴 자리를 만든다", "안전한 자리를 만들었다. 충분히 쉬고 물약을 챙긴다.", 0, 0, 0, 0, 0, 0, 0.0, 70, 1, 0)
        call ProtoSetScene(71, 0, "배당표의 빈자리", "유메코가 배당표를 가리키며 큰 이익만큼 큰 위험이 있다고 말한다. 판돈을 낼지, 도박장을 떠나 물자 운반을 맡을지 고른다.", 0, 0)
        call ProtoSetBranch(71, 1, "150골드를 걸고 높은 배당에 도전한다", "배당표의 높은 칸에 이름이 적혔다. 유메코의 기억과 당첨금을 얻는다.", 15, 0, 300, 150, 0, 0, 0.0, 0, 0, 40)
        call ProtoSetBranch(71, 2, "도박장 밖에서 물자를 옮긴다", "판돈을 지키고 일을 마쳤다. 운반 보수를 받는다.", 0, 0, 120, 0, 0, 0, 0.0, 0, 0, 0)
        set ProtoEventFailure[71] = "높은 배당의 주인은 다른 사람이 됐다. 판돈은 잃었다."
        call ProtoSetScene(72, 0, "새 게임의 초대", "소라가 새 규칙을 적은 판을 펼친다. 참가비를 내고 규칙을 배울지, 관객들에게 규칙을 설명하는 일을 맡을지 정한다.", 0, 0)
        call ProtoSetBranch(72, 1, "참가비를 내고 규칙을 분석한다", "낯선 규칙도 읽을 수 있다는 경험을 얻었다. 소라의 기억이 사건 후보를 넓힌다.", 18, 0, 0, 250, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(72, 2, "관객에게 기본 규칙을 안내한다", "직접 참가하지 않고 안내를 끝냈다. 보수와 회복을 챙긴다.", 0, 0, 150, 0, 0, 0, 0.0, 20, 0, 0)
        call ProtoSetScene(73, 1, "제대로 된 연습 장소", "자판기 앞에서 도왔던 일을 기억한 미코토가 공터로 부른다. 이번에는 사람이 없는 곳이다. 전격의 궤도를 직접 견뎌 볼지, 피하는 요령부터 배울지 묻는다.", 13, 1)
        call ProtoSetBranch(73, 1, "궤도를 끝까지 관찰한다", "피해를 감수하고 공격의 타이밍을 익혔다. 다음 실전에서 쓸 힘이 남는다.", 0, 0, 0, 0, 0, 0, 25.0, -20, 0, 0)
        call ProtoSetBranch(73, 2, "안전한 회피 구간을 익힌다", "미코토가 빈틈을 짚어 준다. 과한 훈련은 피하면서 작은 성장을 얻는다.", 0, 0, 0, 0, 0, 0, 10.0, 20, 0, 0)
        call ProtoSetScene(74, 1, "기숙사의 간식 시간", "쿠로코가 미코토를 기다리며 간식을 준비해 놓았다. 외부인이 오래 머물 수는 없다. 짐을 옮겨 주거나 부족한 간식을 사 올 수 있다.", 0, 0)
        call ProtoSetBranch(74, 1, "짐을 빠르게 옮겨 준다", "공간이동으로 정리되는 짐을 보며 이동의 감각을 익혔다.", 22, 0, 0, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(74, 2, "간식을 나누고 잠깐 쉬어 간다", "소란을 피해 휴식을 취했다. 기숙사 밖으로 나갈 때 보급도 챙긴다.", 0, 0, 0, 0, 0, 0, 0.0, 40, 1, 0)
        call ProtoSetScene(75, 1, "사텐의 다음 단서", "도시전설을 함께 조사했던 사텐이 새 증언을 가져왔다. 소문을 따라 위험한 골목으로 가거나, 수집한 정보를 의뢰인에게 전달할 수 있다.", 20, 1)
        call ProtoSetBranch(75, 1, "남은 증언의 진위를 확인한다", "소문의 실체를 확인했다. 주변 상황을 읽는 경험이 다음 사건의 후보를 넓힌다.", 38, 0, 0, 0, 0, 1, 0.0, 0, 0, 0)
        call ProtoSetBranch(75, 2, "확인한 부분만 보고한다", "과장된 소문을 빼고 기록을 전달했다. 의뢰인이 보수를 지급한다.", 0, 0, 200, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(76, 1, "실험 예정지", "미사카 동생에게 돌려준 기록의 장소에 도착했다. 실험은 아직 끝나지 않았다. 토우마는 방관할 수 없다며 현장에 들어갈 준비를 한다.", 16, 1)
        call ProtoSetBranch(76, 1, "토우마와 실험을 저지한다", "실험을 막는 데 힘을 보탰다. 강한 적과의 대치를 감수했고 네트워크를 통해 감사가 전해진다.", 40, 0, 0, 0, 1, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(76, 2, "소녀들의 퇴로를 확보한다", "정면 대치 대신 안전한 퇴로를 열었다. 미사카 동생을 지켜 낸 기억이 남는다.", 37, 0, 80, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(77, 1, "남겨진 명찰", "구조 현장에서 학생의 명찰을 찾았다. 토우마는 주인을 찾기 전까지 돌아갈 수 없다고 한다. 위험한 길을 다시 걸을지, 학생들에게 소식을 물을지 선택한다.", 17, 1)
        call ProtoSetBranch(77, 1, "토우마와 발자국을 되짚는다", "명찰을 돌려줬다. 불행한 길에서도 물러서지 않는 모습을 배웠다.", 20, 0, 0, 0, 0, 0, 10.0, 0, 0, 0)
        call ProtoSetBranch(77, 2, "학생들에게 연락을 돌린다", "명찰의 주인을 찾았다. 돌아다닌 대가로 보호자가 보수를 준다.", 0, 0, 180, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(78, 1, "네트워크의 연락", "실험 현장에서 도왔던 시스터즈의 연락이 전해진다. 서로 공유한 관측 정보로 위험한 위치를 알 수 있다. 더 많은 적을 관찰할지, 위험을 피할지 정한다.", 76, 1)
        call ProtoSetBranch(78, 1, "관측 범위를 넓힌다", "새 관측 정보를 함께 정리했다. 적은 늘지만 힘을 더 정확히 쓸 수 있게 된다.", 0, 0, 0, 0, 0, 2, 20.0, 0, 0, 0)
        call ProtoSetBranch(78, 2, "위험 좌표를 피해 이동한다", "네트워크의 경고대로 이동했다. 사냥터의 위험이 한 단계 낮아진다.", 0, 0, 0, 0, -1, 0, 0.0, 30, 0, 0)
        call ProtoSetScene(79, 1, "라스트 오더의 부탁", "라스트 오더가 액셀러레이터에게 전할 물건을 잃어버렸다고 한다. 소녀의 수다를 들으며 찾다 보니 위험한 거리에 접어들었다.", 0, 0)
        call ProtoSetBranch(79, 1, "끝까지 함께 찾아 준다", "물건을 찾자 액셀러레이터가 나타난다. 소녀를 지켜 준 일을 기억한 그는 공격을 막는 요령을 보여 준다.", 21, 0, 0, 0, 1, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(79, 2, "소녀를 안전한 장소로 데려간다", "물건보다 안전을 먼저 챙겼다. 소녀가 남겨 준 정보로 보급을 확보한다.", 0, 0, 150, 0, 0, 0, 0.0, 0, 1, 0)
        call ProtoSetScene(80, 1, "반사되는 잔해", "액셀러레이터가 경고했던 길에 흩어진 잔해가 남았다. 던져진 물체가 돌아오던 방향을 복기하거나, 잔해를 치워 안전한 통로를 만들 수 있다.", 21, 1)
        call ProtoSetBranch(80, 1, "흔적에서 공격의 방향을 읽는다", "방향을 바꾸는 힘을 복기했다. 위험을 견딘 경험이 피해 증가로 남는다.", 0, 0, 0, 0, 0, 0, 20.0, 0, 0, 0)
        call ProtoSetBranch(80, 2, "잔해를 치워 통로를 만든다", "거리를 정리한 보수를 받았다. 적이 모일 공간도 줄었다.", 0, 0, 160, 0, 0, -1, 0.0, 0, 0, 0)
        call ProtoSetScene(81, 1, "마술 흔적의 해독", "인덱스가 설명했던 문양이 다른 벽에도 남아 있다. 뜻을 해독하려면 오래된 기록을 구해야 한다. 아니면 문양을 피해서 갈 수도 있다.", 19, 1)
        call ProtoSetBranch(81, 1, "기록을 구해 해독한다", "문양이 만드는 흐름을 읽었다. 인덱스에게 배운 지식이 실제 힘으로 이어진다.", 0, 0, 0, 200, 0, 0, 30.0, 0, 0, 0)
        call ProtoSetBranch(81, 2, "표식을 남기고 우회한다", "다른 사람도 위험을 피할 수 있게 경고를 남겼다. 당신은 안전하게 쉬어 간다.", 0, 0, 0, 0, 0, 0, 0.0, 50, 0, 0)
        call ProtoSetScene(82, 1, "개발 수업의 과제", "능력 개발 수업의 교사가 실전 관측 자료를 찾는다. 강한 상대의 기록을 모아 제출하거나 기본 과제만 끝낼 수 있다.", 0, 0)
        call ProtoSetBranch(82, 1, "심화 과제를 맡는다", "힘의 사용 기록을 정리했다. 어려운 실전에 계속 도전하는 대신 피해를 높인다.", 0, 0, 0, 0, 1, 0, 20.0, 0, 0, 0)
        call ProtoSetBranch(82, 2, "기본 과제를 제출한다", "정리한 기본 자료도 연구에 도움이 됐다. 과제 보수를 받는다.", 0, 0, 180, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(83, 1, "미코토의 잔돈", "미코토가 동전 하나를 들어 올리고 거리 끝의 표적을 가리킨다. 표적 배치를 도우면 시범을 가까이서 볼 수 있다. 주민들의 통행도 챙겨야 한다.", 0, 0)
        call ProtoSetBranch(83, 1, "표적을 배치하고 시범을 본다", "동전이 섬광이 되어 지나갔다. 초전자포의 기억을 얻고 거친 훈련을 이어 간다.", 19, 0, 0, 0, 1, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(83, 2, "주민을 안전한 통로로 안내한다", "시범을 멀리서 지켜봤다. 통행을 도운 대가로 골드를 받는다.", 0, 0, 150, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(84, 1, "꽃 장식의 안내 데스크", "우이하루가 꽃 장식을 고쳐 쓰며 분실물 목록을 펼친다. 안내를 도우면 도시의 상황을 정리하는 법을 배울 수 있다.", 0, 0)
        call ProtoSetBranch(84, 1, "목록을 정리하고 전달을 돕는다", "작은 정보들이 하나의 경로로 연결됐다. 우이하루의 정보 지원을 얻는다.", 38, 0, 0, 100, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(84, 2, "분실물을 가까운 주인에게 돌려준다", "빠르게 끝낼 수 있는 일을 맡았다. 감사 인사와 작은 보급을 받는다.", 0, 0, 100, 0, 0, 0, 0.0, 0, 1, 0)
        call ProtoSetScene(85, 2, "반디의 비밀 장소", "놀이시설에서 함께했던 반디가 꿈의 경계 쪽으로 부른다. 공사장 너머의 높은 곳에서 페나코니의 불빛이 보인다. 위험한 길을 함께 오른 대가로 무엇을 기억할지 정한다.", 26, 1)
        call ProtoSetBranch(85, 1, "반디와 끝까지 이야기를 나눈다", "북적이는 거리 밖에서 반디의 속마음을 들었다. 함께 오른 기억이 피해 증가로 남는다.", 0, 0, 0, 0, 0, 0, 25.0, 0, 0, 0)
        call ProtoSetBranch(85, 2, "풍경을 보고 충분히 쉬어 간다", "오늘은 더 깊이 묻지 않았다. 풍경을 보며 상처를 회복한다.", 0, 0, 0, 0, 0, 0, 0.0, 100, 0, 0)
        call ProtoSetScene(86, 2, "슬롯머신의 다음 판", "첫 당첨을 본 사람들이 기계 앞에 모여든다. 관리인은 큰 판의 토큰을 내민다. 이미 이긴 돈을 지킬지, 더 높은 판돈을 걸지 묻는다.", 25, 1)
        call ProtoSetBranch(86, 1, "300골드를 걸고 큰 판에 도전한다", "다시 그림이 맞았다. 어벤츄린의 승부를 떠올리는 기억과 큰 당첨금을 챙겼다.", 27, 0, 600, 300, 0, 0, 0.0, 0, 0, 40)
        call ProtoSetBranch(86, 2, "당첨금을 지키고 기계를 떠난다", "첫 승리에서 멈췄다. 관리인이 기념 보너스를 건넨다.", 0, 0, 150, 0, 0, 0, 0.0, 0, 0, 0)
        set ProtoEventFailure[86] = "기계가 멈췄지만 그림은 맞지 않았다. 이번 판돈은 잃었다."
        call ProtoSetScene(87, 2, "남겨진 칩의 주인", "함께 승부한 어벤츄린의 칩 하나가 테이블에 남아 있다. 다음 판의 초대일 수도 있다. 주인에게 돌려주거나 계산대에 맡길 수 있다.", 27, 1)
        call ProtoSetBranch(87, 1, "어벤츄린에게 직접 돌려준다", "판돈을 잃을 때도 웃는 태도에 대해 이야기를 나눴다. 더 위험한 승부를 준비하는 힘을 얻는다.", 0, 0, 0, 0, 1, 0, 25.0, 0, 0, 0)
        call ProtoSetBranch(87, 2, "계산대에 맡기고 보수를 받는다", "새 판에는 앉지 않았다. 칩을 돌려준 보수만 챙긴다.", 0, 0, 200, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(88, 2, "다시 움직이는 시계", "클락과 수리했던 장치가 다른 꿈의 구간에 연결되어 있다. 남은 톱니를 조정하면 더 많은 흐름을 읽을 수 있고, 느린 길로 바꾸면 위험을 피할 수 있다.", 28, 1)
        call ProtoSetBranch(88, 1, "흐름을 읽는 톱니를 맞춘다", "수리한 장치의 기억이 이어졌다. 더 많은 사건 후보를 읽는 감각을 유지한다.", 44, 0, 0, 0, 0, 0, 10.0, 0, 0, 0)
        call ProtoSetBranch(88, 2, "위험 구간을 느린 길로 돌린다", "장치가 우회로를 연다. 위험을 낮추고 여유를 되찾는다.", 0, 0, 0, 0, -1, 0, 0.0, 30, 0, 0)
        call ProtoSetScene(89, 2, "무대 밖의 스파클", "가면극을 함께했던 스파클이 다른 배역을 제안한다. 이번에는 관객에게 들키지 않는 장난이다. 참여할지, 정체를 밝히고 무대를 끝낼지 고른다.", 29, 1)
        call ProtoSetBranch(89, 1, "장난의 마지막 배역을 맡는다", "끝까지 가면을 썼다. 혼란을 감수한 대신 공격의 빈틈을 읽는다.", 0, 0, 0, 0, 0, 1, 25.0, 0, 0, 0)
        call ProtoSetBranch(89, 2, "가면을 벗고 공연을 끝낸다", "상황을 정리하고 출연료를 챙긴다. 더는 혼란을 키우지 않는다.", 0, 0, 200, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(90, 2, "갤러거의 마지막 잔", "바의 소란을 막은 일을 기억한 갤러거가 빈 잔을 밀어 준다. 기억에 남는 한 잔을 만들 재료를 구해 주거나, 오늘의 이야기를 들려줄 수 있다.", 30, 1)
        call ProtoSetBranch(90, 1, "새 재료를 구해 온다", "갤러거가 재료와 기억을 섞어 한 잔을 만든다. 생존의 기억을 보강한다.", 44, 0, 0, 120, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(90, 2, "오늘 겪은 이야기를 들려준다", "거창한 재료 없이도 휴식할 이유는 충분했다. 물약과 회복을 챙긴다.", 0, 0, 0, 0, 0, 0, 0.0, 50, 1, 0)
        call ProtoSetScene(91, 2, "아케론의 갈림길", "함께 걸었던 아케론을 갈림길에서 다시 만난다. 지나온 길에 대한 기억이 흐릿하다. 위험한 흔적을 따라가거나 아까 남긴 표식으로 돌아갈 수 있다.", 31, 1)
        call ProtoSetBranch(91, 1, "낯선 힘의 흔적을 따라간다", "힘의 흔적을 가까이서 보았다. 위험을 감수한 경험이 공격에 남는다.", 0, 0, 0, 0, 1, 0, 30.0, 0, 0, 0)
        call ProtoSetBranch(91, 2, "알아볼 수 있는 표식으로 돌아간다", "익숙한 경로로 되돌아갔다. 몬스터가 모이지 않는 길을 찾는다.", 0, 0, 0, 0, 0, -1, 0.0, 40, 0, 0)
        call ProtoSetScene(92, 2, "노래가 끝난 객석", "리허설을 도왔던 로빈의 노래가 끝났다. 공연 준비가 된 객석을 정리하거나, 짧은 앙코르를 들을 수 있다.", 32, 1)
        call ProtoSetBranch(92, 1, "객석 정리를 마친다", "관객이 들어올 준비를 마쳤다. 무대의 기억과 출연 보조비를 받는다.", 44, 0, 100, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(92, 2, "앙코르를 듣고 쉬어 간다", "노래가 이어지는 동안 호흡을 고른다. 생명력과 물약을 회복한다.", 0, 0, 0, 0, 0, 0, 0.0, 70, 1, 0)
        call ProtoSetScene(93, 2, "꿈속 TV의 작은 통로", "하누가 나오는 TV 근처에 몸을 낮춰 지나갈 통로가 있다. 경비의 눈을 피해 물자를 옮길지, 정면 통로를 정리할지 고른다.", 0, 0)
        call ProtoSetBranch(93, 1, "작은 통로로 물자를 옮긴다", "경비를 피해 운반을 끝냈다. 통로를 알려 준 클락의 기억과 보수를 얻는다.", 42, 0, 80, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(93, 2, "정면 통로의 장애물을 정리한다", "넓은 길이 생겼다. 사냥터의 적이 모이는 수를 낮춘다.", 0, 0, 150, 0, 0, -1, 0.0, 0, 0, 0)
        call ProtoSetScene(94, 2, "고장 난 꿈의 놀이기구", "즐거운 기억을 담아야 할 장치가 거칠게 움직인다. 좋은 기억으로 장치를 진정시키거나 전원을 내려서 통행을 확보할 수 있다.", 0, 0)
        call ProtoSetBranch(94, 1, "로빈의 노래를 따라 장치를 진정시킨다", "불안정한 장치가 천천히 가라앉았다. 함께 부르는 노래의 기억을 얻는다.", 28, 0, 0, 0, 0, 0, 0.0, -15, 0, 0)
        call ProtoSetBranch(94, 2, "전원을 내리고 통로를 연다", "놀이기구는 멈췄지만 더는 위험하지 않다. 낮은 위험의 길을 확보한다.", 0, 0, 100, 0, -1, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(95, 2, "꿈의 경계 전망대", "아래에는 황금의 순간의 불빛이 펼쳐지고 드림위버가 위쪽 길을 만들고 있다. 풍경을 더 가까이 볼지, 안전선 안에서 쉴지 정한다.", 0, 0)
        call ProtoSetBranch(95, 1, "새 길을 따라 높은 곳으로 오른다", "반디가 보여 줬던 풍경을 떠올렸다. 더 위험한 꿈으로 나아갈 힘을 얻는다.", 25, 0, 0, 0, 1, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(95, 2, "안전선 안에서 풍경을 본다", "모험을 늘리지 않고 상처를 돌본다. 전망대의 보급을 챙긴다.", 0, 0, 0, 0, 0, 0, 0.0, 60, 1, 0)
        call ProtoSetScene(96, 2, "골목 끝의 흥겨운 가면", "스파클이 가면을 바꾸며 좁은 골목으로 손님을 부른다. 멀리서 보면 같은 공연이지만 가까이 가면 각자 다른 배역이 적혀 있다.", 0, 0)
        call ProtoSetBranch(96, 1, "새 배역의 참가비를 낸다", "당신만의 배역을 연기했다. 끝없는 가면극의 기억이 사건 후보를 넓힌다.", 29, 0, 0, 250, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(96, 2, "외부에서 손님을 안내한다", "공연에 참가하지 않고 길 안내를 맡았다. 안내 보수를 받는다.", 0, 0, 180, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(97, 3, "대련 다음의 호흡", "문 앞 대련을 기억한 메이링이 자세를 다시 봐 준다. 실전의 움직임을 더 익힐지, 회복하는 호흡을 배울지 고른다.", 37, 1)
        call ProtoSetBranch(97, 1, "실전 동작을 이어서 익힌다", "첫 대련의 경험이 공격의 힘으로 이어진다. 위험한 연습도 계속된다.", 0, 0, 0, 0, 1, 0, 25.0, 0, 0, 0)
        call ProtoSetBranch(97, 2, "숨을 고르는 법을 익힌다", "무리한 수련은 멈췄다. 사냥터의 위험을 낮추고 체력을 회복한다.", 0, 0, 0, 0, -1, 0, 0.0, 60, 0, 0)
        call ProtoSetScene(98, 3, "정리된 서가의 빈칸", "소악마와 정리했던 서가에 빈칸이 보인다. 잘못 놓인 책을 끝까지 찾으면 책을 읽을 기회를 얻는다.", 38, 1)
        call ProtoSetBranch(98, 1, "빈칸의 책을 끝까지 찾는다", "올바른 서가에 책을 돌려줬다. 마도서의 기억을 챙긴다.", 46, 0, 0, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(98, 2, "빈칸 목록만 작성한다", "오늘 할 일을 끝냈다. 소악마가 정리 보수를 지급한다.", 0, 0, 180, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(99, 3, "파츄리의 질문", "책을 정리했던 일을 기억한 파츄리가 어떤 속성의 마법을 읽고 싶은지 묻는다. 공격의 원리를 깊게 읽거나 몸을 돌보며 가볍게 읽을 수 있다.", 44, 1)
        call ProtoSetBranch(99, 1, "공격의 원리를 깊게 읽는다", "일곱 가지 속성이 얽히는 원리를 따라갔다. 지식이 공격에 남는다.", 0, 0, 0, 150, 0, 0, 25.0, 0, 0, 0)
        call ProtoSetBranch(99, 2, "무리하지 않고 읽는다", "짧게 읽고 쉬어 갔다. 상처를 돌보고 물약을 받는다.", 0, 0, 0, 0, 0, 0, 0.0, 50, 1, 0)
        call ProtoSetScene(100, 3, "다시 비워진 서가", "마리사와 빠져나왔던 일을 떠올리는 사이 책이 또 사라졌다. 이번에는 책을 돌려놓을지, 마리사의 마법 연습을 도울지 정한다.", 45, 1)
        call ProtoSetBranch(100, 1, "마리사의 연습에 동행한다", "마법의 힘을 관찰했다. 뒤따르는 소란을 감수한 만큼 피해를 높인다.", 0, 0, 0, 0, 0, 2, 25.0, 0, 0, 0)
        call ProtoSetBranch(100, 2, "책을 돌려놓고 내용을 읽는다", "늦었지만 책을 반납했다. 마도서의 기억을 얻는다.", 46, 0, 0, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(101, 3, "메이드장의 검수", "식당 일을 도왔던 사쿠야가 마무리를 확인한다. 빠뜨린 일을 대신 끝내거나, 다음 일정까지 쉬는 시간을 얻을 수 있다.", 40, 1)
        call ProtoSetBranch(101, 1, "남은 일까지 맡는다", "정해진 일을 깔끔하게 마쳤다. 시간의 흐름을 살피던 경험이 공격에 남는다.", 0, 0, 100, 0, 0, 0, 20.0, 0, 0, 0)
        call ProtoSetBranch(101, 2, "다음 일정 전까지 쉬어 간다", "사쿠야가 마련한 쉬는 시간에 몸을 돌보고 보급을 받는다.", 0, 0, 0, 0, 0, 0, 0.0, 70, 1, 0)
        call ProtoSetScene(102, 3, "부서진 장난감", "함께 놀았던 플랑드르가 부서진 장난감을 보여 준다. 다시 위험한 놀이를 하거나, 고치는 동안 이야기를 들려줄 수 있다.", 41, 1)
        call ProtoSetBranch(102, 1, "새 장난감으로 한 번 더 논다", "부서지는 힘을 다시 견뎌 냈다. 커진 위험만큼 공격의 기억이 강해진다.", 0, 0, 0, 0, 1, 0, 40.0, -20, 0, 0)
        call ProtoSetBranch(102, 2, "장난감을 고치며 이야기를 들려준다", "놀이를 이어 가지 않고 마음을 달랬다. 물약과 회복을 챙긴다.", 0, 0, 0, 0, 0, 0, 0.0, 80, 2, 0)
        call ProtoSetScene(103, 3, "운명에 관한 답례", "시험에 참가했던 일을 기억한 레밀리아가 붉은 밤에 다시 부른다. 위험한 길을 끝까지 갈지, 여기서 주인의 호의를 받을지 정한다.", 42, 1)
        call ProtoSetBranch(103, 1, "다음 시험에도 참가한다", "시험을 끝낸 대가로 공격의 힘을 얻는다. 이후의 상대도 강해진다.", 0, 0, 0, 0, 1, 0, 30.0, 0, 0, 0)
        call ProtoSetBranch(103, 2, "주인의 호의를 받고 떠난다", "무리한 약속은 하지 않았다. 답례와 충분한 휴식을 받는다.", 0, 0, 250, 0, 0, 0, 0.0, 50, 0, 0)
        call ProtoSetScene(104, 3, "어둠 속의 나뭇가지", "함께 길을 걸었던 루미아가 또 나뭇가지에 걸렸다. 길을 익히도록 함께 걷거나 밖에서 손을 잡아 이끌 수 있다.", 43, 1)
        call ProtoSetBranch(104, 1, "어둠 속의 길을 끝까지 익힌다", "어둠에 익숙해진 경험이 공격의 힘으로 남는다.", 0, 0, 0, 0, 0, 0, 20.0, 0, 0, 0)
        call ProtoSetBranch(104, 2, "밖으로 끌어내고 길을 비운다", "덜 붐비는 길을 찾아 줬다. 사냥터의 적도 줄어든다.", 0, 0, 0, 0, 0, -1, 0.0, 30, 0, 0)
        call ProtoSetScene(105, 3, "소악마의 반납 도장", "소악마가 빌려 간 책의 명단을 펼친다. 직접 책을 찾아오면 보상을 주고, 명단만 정리해도 수고비를 준다고 한다.", 0, 0)
        call ProtoSetBranch(105, 1, "책을 회수하러 간다", "책을 찾아 돌아온 보수를 받는다. 도서관을 오가는 기억이 남는다.", 45, 0, 100, 0, 0, 1, 0.0, 0, 0, 0)
        call ProtoSetBranch(105, 2, "명단을 정리하고 도장을 찍는다", "반납 기록을 복구했다. 몬스터가 몰리는 수를 줄이고 보수를 챙긴다.", 0, 0, 120, 0, 0, -1, 0.0, 0, 0, 0)
        call ProtoSetScene(106, 3, "메이링의 교대 전", "메이링이 문을 잠시 맡겨 달라고 한다. 손님을 직접 맞을지, 사쿠야를 불러 교대를 요청할지 선택한다.", 0, 0)
        call ProtoSetBranch(106, 1, "문 앞에서 방문객을 맞는다", "문을 지키는 동안 메이링의 경계하는 자세를 배웠다.", 34, 0, 0, 0, 0, 0, 0.0, -15, 0, 0)
        call ProtoSetBranch(106, 2, "사쿠야에게 교대를 요청한다", "직접 문을 지키는 일은 피했다. 연락을 전한 보수를 받는다.", 0, 0, 150, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(107, 3, "창문으로 들어온 마법사", "마리사가 문 대신 창문으로 들어와 책을 찾는다. 도서관 안내를 맡아 줄지, 밖에서 마법 시범을 부탁할지 정한다.", 0, 0)
        call ProtoSetBranch(107, 1, "밖에서 마법 시범을 부탁한다", "넓은 정원에서 마법의 힘을 봤다. 마리사의 기억을 얻는 대신 위험도 커진다.", 47, 0, 0, 0, 1, 0, 0.0, 0, 0, 0)
        call ProtoSetBranch(107, 2, "도서관 안내만 맡는다", "책이 더 사라지기 전에 안내를 마쳤다. 수고비를 받는다.", 0, 0, 180, 0, 0, 0, 0.0, 0, 0, 0)
        call ProtoSetScene(108, 3, "얼음 때문에 늦은 배달", "치르노가 호숫가의 짐을 얼려 버렸다. 배달원이 더 늦기 전에 도와 달라고 한다. 얼음을 깨거나 치르노에게 풀어 달라고 설득할 수 있다.", 0, 0)
        call ProtoSetBranch(108, 1, "치르노의 얼음을 깨며 겨룬다", "얼음이 깨져 짐이 풀렸다. 치르노의 기억과 실전 경험이 남는다.", 48, 0, 0, 0, 0, 1, 0.0, 0, 0, 0)
        call ProtoSetBranch(108, 2, "짐을 풀도록 설득한다", "겨루지 않고 짐을 옮겼다. 배달원이 보수를 준다.", 0, 0, 160, 0, 0, 0, 0.0, 20, 0, 0)
    endfunction
endlibrary
