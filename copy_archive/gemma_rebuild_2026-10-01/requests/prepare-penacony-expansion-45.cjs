// 페나코니 후보의 약점을 기록하고 공연·관광 사건과 개인 후속을 고정 분기로 집필한다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const original=read('drafts/penacony-pitches-44.json').parsed.pitches;
const reasons=[
 '플레이어가 로빈 대신 공연과 조명을 결정한다. 유명인을 보는 관객과 노래를 듣는 관객의 구체적 갈등도 후원 광고라는 같은 문제로 바꾸었다.',
 '후원 참가자의 말이 막힌다는 소재만 유지한다. 기존 선택은 플레이어가 참가자의 노래를 대신 결정하므로 먼저 원하는 도움을 물어야 한다.',
 '플레이어가 부트힐의 시선을 차단하거나 총을 겨누는 행동을 결정한다. 구경꾼에게 총구를 돌리는 행동은 사건의 범위를 넘어선다. key에 키릴 문자가 섞였다.',
 '관광 기념사진과 IPC를 향한 행동의 의미가 다르다는 소재만 유지한다. 플레이어가 부트힐의 표정·포즈를 명령하거나 복수의 이유를 바꾸지 않는다. key의 키릴 문자도 쓰지 않는다.',
 'SAM 구경과 평범한 여행의 차이라는 소재만 유지한다. 플레이어가 반디의 답변 순서를 결정하는 대신 자신의 질문과 안내를 선택한다. 갑옷을 실제로 소환하는 장면은 제외한다.',
 '제한된 이동으로 제거하는 오락 게임을 가까운 새와 먼 새를 쫓는 경로로 바꾸었다. 공식 2.3 소개만으로 이 거리 규칙은 확인되지 않는다. 새를 제거하는 대상처럼 쓴 초안은 폐기한다.',
 '이름 없는 여행자의 길 기억 대조라 기존 길 찾기·기억·도면 사건과 중복한다.',
 '특정 인물도 장소의 기능도 없이 전투 흔적과 꽃을 기록하는 일반 관찰이다. 페나코니 머리에 붙일 이유가 약하다.'
];
write('revisions/penacony-pitches-selection-44.json',{source:'drafts/penacony-pitches-44.json',items:original.map((x,i)=>({...x,decision:[1,3,4].includes(i)?'소재만 유지하고 플레이어 행동으로 전면 재설계':'폐기',reason:reasons[i],revisit:'확인한 시설·인물의 목적에 실제 플레이어 행동을 연결하고 기존 사건과 다른 결과를 만들 때 새 초안으로 검토한다.'}))});
const f=(stat,value)=>({stat,value}),none={kind:0,goal:0,effects:[]};
const c=(key,name,effectName,keyword,effects,canonFact,evolution=none)=>({key,name,effectName,keyword,grade:2,effects,evolution,canonFact,uncertain:[]});
const b=(action,card=null,cost=0,level=0,density=0,gold=0,potions=0,chance=100)=>({action,card,card2:null,cost,level,density,gold,potions,chance});
const cards=[
 c('hsr_robin_listen','로빈','이름보다 오래 남은 노래','공격력 · 재생',[f('attack_percent',6),f('regeneration',0.4)],'공식 유명 가수의 음악이 여러 존재에게 울림을 준다는 특징을 자신의 힘과 지속 준비로 각색한다. 노래를 들은 즉시 치료되거나 새 오라·음원을 받지 않는다.'),
 c('hsr_robin_voice','로빈','첫마디에 남긴 자기 이름','공격력 · 고체력',[f('attack_percent',8),f('healthy_damage',12)],'화합의 음악을 듣는 만남에서 남의 기대에 가려지지 않는 첫마디를 성장으로 각색한다. 여행자가 가수나 오디션 심사위원이 되거나 원작 공연을 바꾸지 않는다.',{kind:3,goal:60,effects:[f('boss_damage_percent',6)]}),
 c('hsr_boothill_focus','부트힐','많은 시선 속의 한 표적','보스 · 방향',[f('boss_damage_percent',14),f('directional_damage',10)],'공식 사이보그 카우보이의 한 상대와의 결투 철학을 큰 상대와 방향 조건의 공격 준비로 각색한다. 총·결투 기술·원작 물리 약점 부여를 지급하지 않는다.',{kind:2,goal:15000,effects:[f('penetration',3)]}),
 c('hsr_boothill_attention','부트힐','숨기지 않은 발걸음','이동 · 이동 조건 · 패널티',[f('move_speed',4),f('moving_damage',14),f('damage_reduction',-3)],'IPC의 관심을 끄는 대담한 행동을 빠른 이동과 그 속도에 비례하는 피해, 받는 피해의 부담으로 각색한다. moving_damage는 이동 중 판정이 아니라 기본 이동속도 대비 증가량을 사용하는 기존 카드 능력치다. 총격·도발·NPC 난동은 없다.'),
 c('hsr_firefly_visit','반디','갑옷 밖에서 보려던 풍경','최대 체력 · 이동',[f('max_health_percent',10),f('move_speed',4)],'삶의 의미를 찾고 운명에 맞서려는 목적을 평범한 풍경을 고르는 독립 만남으로 각색한다. 체력 증가는 카드 성장이지 엔트로피 상실증 치료나 반디의 신체 변화가 아니다.',{kind:1,goal:40,effects:[f('healthy_damage',8)]}),
 c('hsr_boothill_caption','부트힐','사진 아래에 빠진 말','사건 후보 · 치명타 피해',[f('event_choices',1),f('crit_damage',14)],'관광 사진의 잘못된 설명을 바로잡는 창작 후속에서 더 많은 기회와 일격의 힘을 챙기는 성장이다. 실제 사진 수집·문서 편집 UI·IPC 평판·명성 시스템은 없다.')
];
const events=[
 {key:'hsr_name_over_song',title:'이름이 노래를 덮을 때',scene:'대극장의 사전 공연 안내 자리에서 네 앞의 관객들이 로빈의 이름을 번갈아 외쳐 뒤쪽 사람은 시작 안내를 듣지 못한다. 로빈은 아직 노래를 시작하지 않고 뒤편에서도 안내가 들렸는지 묻는다. 너는 함께 이름을 외치려던 친구에게 기다릴 이유를 말할지, 다른 자리에서 듣도록 도울지 정한다.',choices:[b('160골드로 다른 자리를 마련하고 뒤편 관객과 먼저 듣는다','hsr_robin_listen',160),b('더 많은 개인 사냥을 맡고 친구와 기다릴 첫마디를 정한다','hsr_robin_voice',0,0,1),b('안내를 전달하고 보급품을 받으며 맡을 사냥 수를 줄인다',null,0,0,-1,60,2)],canonFact:'공식 대극장과 유명 가수 로빈의 예정 공연에서 사전 안내 중의 새 관객 갈등을 창작했다. 플레이어가 실제 공연·조명·관객 수·원작 축제 결과를 결정하지 않는다. 사냥 밀도는 개인 준비의 별도 규칙이며 관객을 몬스터로 바꾸지 않는다.'},
 {key:'hsr_introduction_left',title:'소개만 남은 무대',scene:'솔글래드 후원 오디션 참가자가 소개를 연습하는데 광고 문구는 끝까지 읽고도 자기 이름은 말하지 못한다. 옆을 지나던 로빈이 네가 내민 소개지에서 참가자 이름이 어디에 있는지 묻자 참가자가 빈 여백을 짚는다. 너는 이름을 다시 적을 준비를 도울지, 순서를 바꾸지 않고 들릴 위치를 찾을지 정한다.',choices:[b('150골드로 새 소개지를 마련하고 이름부터 말할 시도를 돕는다','hsr_robin_voice',150,0,0,60,0,70),b('200골드로 안내 자리를 마련해 먼저 들어 줄 사람을 찾는다','hsr_robin_listen',200),b('광고 안내만 전달하고 맡은 일의 보수를 받는다',null,0,0,0,120)],failure:'150골드로 소개지를 다시 마련했지만 참가자는 이름 앞에서 멈추었다. 새 카드와 보수는 얻지 못했다. 로빈은 종이를 대신 읽어 주지 않고 참가자가 다시 입을 열 때까지 기다린다.',canonFact:'공식 솔글래드 후원 오디션과 로빈의 음악에서 별도 참가자의 말 막힘을 창작했다. 로빈이 원작 오디션 심사위원이라는 주장은 아니다. 70%는 맵 판정이며 공식 우승·심사 점수·노래·명성·추가 참가 기능은 없다.'},
 {key:'hsr_cowboy_in_frame',title:'카우보이를 담는 배경',scene:'한 관광객이 IPC 광고 앞에서 부트힐의 기념사진을 찍어 달라며 네게 카메라를 건넨다. 부트힐은 광고의 로고가 자기 뒤에 들어오는 것을 보자 그 사진을 누가 무슨 뜻으로 보게 될지 먼저 묻는다. 관광객은 멋진 사이보그를 남기고 싶었을 뿐이라며 광고를 빼면 어떤 말을 붙여야 할지 되묻는다.',choices:[b('180골드로 별도 사진 자리를 마련하고 배경을 고른 이유를 적는다','hsr_boothill_focus',180),b('부트힐이 알리려는 말을 듣고 더 강한 개인 사냥을 맡는다','hsr_boothill_attention',0,1),b('촬영 안내만 마치고 보수를 받으며 개인 사냥 수를 줄인다',null,0,0,-1,120)],canonFact:'공식 부트힐의 사이보그·갤럭시 레인저·IPC 복수 대상을 기념사진의 잘못된 인상에 각색했다. 관광객의 부탁과 대화는 창작이며 실제 사진 기능·총격·새 결투·IPC 소속 변경·복수 완수는 없다.'},
 {key:'hsr_view_without_armor',title:'갑옷을 기다리지 않는 길',scene:'꿈속 관광 안내 자리에서 여행자가 반디에게 SAM의 모습을 보여 달라고 부탁한다. 반디는 바로 답하지 않고 네가 펼친 풍경 안내의 한쪽을 보고 있는데 여행자는 갑옷 사진이 없으면 무엇을 보러 가냐고 묻는다. 너는 반디에게 보고 싶은 풍경을 물을지, 안내만 전달하고 다른 준비를 할지 정한다.',choices:[b('170골드로 풍경 안내를 마련하고 반디가 보고 싶은 곳을 묻는다','hsr_firefly_visit',170),b('더 많은 개인 사냥을 맡는 대신 풍경 안내를 직접 전달한다','hsr_firefly_visit',0,0,2),b('갑옷을 요구하지 않고 안내만 마쳐 물약을 받는다',null,0,0,-1,0,2)],canonFact:'공식 반디의 SAM 갑옷과 삶의 의미를 찾는 목적에서 독립 관광 만남을 창작했다. 반디를 로빈의 경호원·점원으로 바꾸지 않고 갑옷 소환·새 장비·질병 치료·본편 죽음이나 결말을 결정하지 않는다. 같은 카드를 골드와 밀도 부담 중 하나로 얻는다.'},
 {key:'hsr_name_after_poster',title:'이름이 올라간 뒤',previous:'hsr_introduction_left',previousChoice:1,scene:'참가자가 첫 소개를 마친 뒤 그 이름을 적은 안내지가 네 자리에도 붙었다. 다음 손님은 준비를 도운 네가 무대의 주인인 줄 알고 공연을 부탁한다. 로빈은 참가자가 다시 말할 기회를 잃지 않게 누가 도왔고 누가 이름을 말했는지 구분하자고 한다.',choices:[b('130골드로 안내를 고쳐 참가자의 이름을 분명히 남긴다','hsr_robin_listen',130),b('다음 안내를 맡고 잘못 찾아온 손님에게 맡은 일을 설명한다',null,0,0,0,180),b('안내 자리를 줄이고 보급품을 받아 물러난다',null,0,0,-1,80,1)],canonFact:'첫 소개 시도에 성공한 자신의 행동에서 이어지는 창작 개인 후속이다. 참가자가 오디션을 우승했다는 뜻은 아니며 여행자에게 가수 명성·공연 역할을 지급하지 않는다.'},
 {key:'hsr_photo_missing_caption',title:'사진 아래에 빠진 말',previous:'hsr_cowboy_in_frame',previousChoice:1,scene:'광고가 빠진 사진을 넘긴 뒤 관광객이 붙인 설명에는 IPC의 수호자라는 말이 적혀 있다. 부트힐은 배경만 바꾸면 같은 뜻도 바뀌는 줄 알았냐며 네가 앞서 적은 이유를 보여 준다. 관광객은 사진은 마음에 든다며 설명만 어디부터 고칠지 묻는다.',choices:[b('140골드로 설명지를 다시 마련하고 빠진 이유를 적는다','hsr_boothill_caption',140),b('더 강한 개인 사냥을 맡고 부트힐이 숨기지 않을 말을 전한다','hsr_boothill_attention',0,1),b('설명 전달만 맡아 보수를 받고 개인 사냥 수를 줄인다',null,0,0,-1,150)],canonFact:'광고를 뺀 사진을 마련한 개인 기록으로만 열리는 창작 후속이다. 부트힐을 IPC의 직원이나 수호자로 설정하는 것이 아니라 관광객의 잘못된 설명을 사건 안에서 바로잡는다. 실제 평판·사진 보관·총격·협박·복수 완수는 없다.'}
];
const learning=Object.fromEntries(cards.map(c=>[c.key,c.effects.map(e=>({attack_percent:'공격력 증가',regeneration:'지속 체력 재생',healthy_damage:'고체력에서 피해 증가',boss_damage_percent:'보스 피해 증가',directional_damage:'방향 조건 피해 증가',move_speed:'이동속도 증가',moving_damage:'늘어난 이동속도 비율에 따른 피해 증가',damage_reduction:'받는 피해 감소 비율',max_health_percent:'최대 체력 증가',event_choices:'사건 후보 추가',crit_damage:'치명타 피해 증가'})[e.stat]+' '+e.value).join(' / ')]));
const sourceFacts=read('requests/penacony-pitches-44.json').brief.sourceFacts;
const schema=read('requests/magnolia-expansion-text-28.json').schema;
schema.properties.events.minItems=events.length;schema.properties.events.maxItems=events.length;
const expected=b=>Object.fromEntries(Object.entries({paidGold:b.cost,rememberedCard:b.card?learning[b.card]:null,receivedGold:b.gold,receivedPotions:b.potions,personalEnemyStrengthChange:b.level,personalEnemyCountChange:b.density}).filter(([,v])=>v!==0&&v!==null));
write('requests/penacony-expansion-fixed-45.json',{cards,events,sourceFacts});
write('requests/penacony-expansion-text-45.json',{review:false,schema,system:'한국어 사건 작가다. story는 선택 전 발단 3문장, intro는 남은 문제 1문장, result는 성공한 행동과 NPC의 남은 반응 2~3문장이다. key와 선택 순서를 유지한다. 플레이어가 NPC 대신 결정하지 않는다. 카드 성장 수치를 내부 필드 목록으로 복사하지 말고 그 만남에서 기억에 남은 태도로 표현한다. 지불·보수·물약·개인 적 강함과 수는 실제 변화와 맞게 적는다. 현재 체력 회복과 재생·최대 체력 성장을 구분한다.',brief:{sourceFacts,events:events.map(e=>({key:e.key,scene:e.scene,previous:e.previous||null,previousChoice:e.previousChoice||0,choices:e.choices.map(b=>({action:b.action,chance:b.chance,expectedSuccess:expected(b)}))})),rules:[
 '명단·비품 정리나 일반 훈련 조언으로 장면을 바꾸지 않는다. NPC의 대사와 관광객 상황은 창작이며 원작 문장을 인용하지 않는다. 역할·질병·복수·축제 결말을 새로 확정하지 않는다.',
 '부트힐의 수호자라는 말은 후속의 잘못된 설명이다. 부트힐은 IPC에 복수하려는 갤럭시 레인저이며 IPC 직원이 아니다. 반디는 갑옷을 실제 소환하지 않고 삶의 의미를 찾는 만남을 가진다.',
 '로빈은 참가자 대신 노래하거나 플레이어에게 공연 운영권을 주지 않는다. 참가자는 자신의 소개를 시도하며 우승이 확정되는 것이 아니다.',
 '사냥 단계와 수의 변화는 관객이나 안내 행사를 몬스터로 바꾸는 효과가 아니다. 여행자가 원정 준비의 부담을 택하는 별도 개인 필드 규칙이며 다음 한 번만이 아니라 계속 유지된다.',
 '현재 체력 소모·즉시 치료·새 기술·갑옷·실제 촬영·노래 음원·실제 오디션·명성·미래 부채·NPC 전투 동행은 없다. 물약은 받는 보급품이다. 카드의 피해 감소 -3은 지속 패널티다.',
 '70% 분기의 결과는 성공일 때만 쓴다. 실패 문장은 따로 고정되어 있으니 성공과 실패를 섞지 않는다. 후속은 자기의 앞선 성공한 선택을 요구한다. 0이나 null의 효과를 만들지 않는다.'
 ]}});
console.log('페나코니 독립4사건·개인후속2사건·카드6장의 고정안과 집필 요청을 보존했다.');
