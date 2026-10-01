// 아인크라드의 네 사건과 정보 후속을 설계하고 기존 다섯 사건은 수치 그대로 다시 집필한다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const current=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/06-aincrad.json'),'utf8'));
const pitches=read('drafts/aincrad-pitches-51.json').parsed.pitches;
const reasons=[
 '질문의 범위를 정하는 소재만 남긴다. 파편화·우선순위 같은 추상 설명을 특정 갈림길을 돌아오고 싶은 여행자와 정보상의 질문으로 바꾼다.',
 '정보를 혼자만 듣는 것이라고 착각한 손님의 항의만 남긴다. 실제 카드 후보를 아르고에게 요청하는 선택은 폐기하고 내 정보와 관찰의 몫을 고른다.',
 '기억을 잃은 소녀에게 질문이 몰리는 발단만 남긴다. 나무 정리와 타인에게 물건을 가져오라는 명령 대신 내 외투와 앉을 자리를 내놓는 행동으로 바꾼다.',
 '솔로끼리 첫 발걸음이 엇갈리는 발단만 남긴다. 리스트·장비 확인·의견 합의 대신 상대와 떨어지는 자기 간격을 정한다. 본편 보스전은 해결하지 않는다.',
 '키리토에게 감사하며 소모품을 차감하거나 목록을 작성하고 길을 정찰하는 선택은 기존 보급·꽃 의뢰와 겹친다. 이번에는 폐기한다.',
 '특정 원작 인물과 갈등이 없는 일반 캠프·체크리스트·분류·장비 확인이다. 아인크라드 머리를 골라야 만나는 사건의 개성이 없어 폐기한다.'
];
write('revisions/aincrad-pitches-selection-51.json',{raw:'drafts/aincrad-pitches-51.json',items:pitches.map((p,i)=>({...p,decision:i<4?'발단만 남겨 현장 문제로 재설계':'폐기',reason:reasons[i],revisit:'기존 사무·보급·정찰 사건과 다른 인물 반응, 내 행동, 지속 성장과 부담을 만들고 소모품·체력 비용을 없앤 새 원안으로 검토한다.'}))});
const f=(stat,value)=>({stat,value}),none={kind:0,goal:0,effects:[]};
const card=(key,name,effectName,keyword,effects,canonFact,evolution=none)=>({key,name,effectName,keyword,grade:2,effects,evolution,canonFact,uncertain:[]});
const cards=[
 card('sao_argo_question','아르고','묻지 않은 갈림길','사건 후보 · 관통',[f('event_choices',1),f('penetration',6)],'공식 게임 소개의 정보상 역할을 필요한 질문을 좁히고 위험의 빈틈을 찾는 기억으로 각색했다. 정확한 미래·베타의 정답·다른 플레이어 정보·정보 독점권을 지급하지 않는다.'),
 card('sao_argo_shared','아르고','둘이 들어도 남는 정보','행동 · 처치 골드',[f('action_speed',5),f('kill_gold',2)],'정보상 역할을 같은 내용을 듣더라도 자기 몫을 놓치지 않고 움직이는 기억으로 각색했다. 다른 플레이어의 카드와 골드를 빼앗거나 실제 정보 시장·재판매를 열지 않는다.'),
 card('sao_asuna_silence','아스나','대답을 기다리는 자리','최대 체력 · 피해 감소',[f('max_health_percent',10),f('damage_reduction',5)],'공식11화의 기억을 잃은 소녀를 보호하는 상황에서 조용히 곁을 지키는 기억으로 각색했다. 소녀의 기억·정체·관리자 능력을 해금하거나 체력 비율을 즉시 회복하지 않는다.'),
 card('sao_kirito_distance','키리토','혼자와 다른 한 걸음','이동 · 방향',[f('move_speed',6),f('directional_damage',10)],'공식2화의 솔로끼리 파티를 맺는 상황에서 자기 간격과 앞쪽을 보는 기억으로 각색했다. 실제 파티 합류·NPC 동행·원작 소드스킬·공략 승리를 지급하지 않는다.',{kind:1,goal:45,effects:[f('boss_damage_percent',5)]}),
 card('sao_argo_return','아르고','돌아와 더할 한 문장','일반 적 · 치명타 피해',[f('normal_damage_percent',12),f('crit_damage',10)],'정보상을 만났던 자신의 질문을 다시 떠올리는 창작 후속의 기억이다. 실제 새 탐사·낚시·추가 사냥 처치·시스템 지식·최신 지도의 정확성을 보장하지 않는다.')
];
const b=(action,card=null,cost=0,level=0,density=0,gold=0,potions=0,chance=100)=>({action,card,card2:null,cost,level,density,gold,potions,chance});
const events=[
 {key:'sao_argo_fork',title:'강한 상대보다 돌아갈 길',scene:'아르고에게 그 길은 어떠냐고 묻자 상대의 위험부터 답이 돌아온다. 네가 궁금했던 것은 사냥을 마친 뒤 어느 갈림길로 돌아오는가였고, 아르고는 처음부터 무엇을 알고 싶은지 말했어야 한다고 손을 펼친다. 주머니를 열어 필요한 질문만 살까, 더 많은 개인 사냥을 맡으며 자기 간격을 익힐까?',choices:[b('180골드를 내고 돌아올 갈림길만 묻는다','sao_argo_question',180),b('더 많은 개인 사냥을 맡고 자기 발걸음의 간격을 익힌다','sao_kirito_distance',0,0,1),b('가져온 전달물을 건네고 보급 보수를 받는다',null,0,0,0,140,1)],canonFact:'아르고의 정보상 역할에서 질문과 답의 범위가 다른 만남을 창작했다. 길·갈림길·전달물·정보료는 창작이며 베타 정보를 최신 정답으로 확정하지 않는다.'},
 {key:'sao_argo_same_answer',title:'옆 사람도 들은 답',scene:'아르고가 옆 손님에게 방금 네가 들은 이야기를 다시 전하자 그 손님이 먼저 산 쪽만 아는 정보 아니냐며 너를 돌아본다. 아르고는 혼자만 들을 권리를 판 적은 없다며 너에게도 다시 무엇을 살 것인지 묻는다. 너는 남의 입을 막는 대신 자신에게 필요한 질문과 앞으로 맡을 사냥을 정한다.',choices:[b('200골드를 내고 같은 정보에서 내 몫의 질문을 고른다','sao_argo_shared',200),b('더 강한 개인 사냥을 맡으며 위험에 관한 질문을 남긴다','sao_argo_question',0,1),b('거래를 마친 물품을 운반하고 보수를 받는다',null,0,0,0,160,1)],canonFact:'다양한 정보를 거래하는 역할에서 손님의 독점 오해를 창작했다. 정보 독점·다른 플레이어의 후보 차단·실제 정보 재판매 기능과 공식 특정 거래를 추가하지 않는다.'},
 {key:'sao_girl_unanswered',title:'이름 다음의 질문',scene:'기억을 잃은 소녀가 앉은 자리에서 네가 어디서 왔냐고 묻자 키리토도 막 같은 질문을 했다고 말한다. 아스나는 더 묻기 전에 앉을 곳부터 비우고 있지만 소녀에게는 아직 이어서 할 말이 없다. 너는 자기 외투를 내놓거나 조용히 자리를 지키며 대답보다 먼저 할 작은 일을 정한다.',choices:[b('180골드로 깔개를 마련하고 외투를 내놓는다','sao_asuna_silence',180),b('더 많은 개인 사냥을 맡고 기다릴 자리의 간격을 익힌다','sao_kirito_distance',0,0,1),b('빌린 담요를 전달하고 보급품을 받는다',null,0,0,0,120,2)],canonFact:'공식11화의 소녀 보호 상황에서 외투·깔개·담요 전달을 창작했다. 기억 회복·유령 정체·관리자 권한·유이의 후일 결말은 정하지 않는다. 소녀를 원작의 치료 능력으로 바꾸지 않는다.'},
 {key:'sao_first_party_step',title:'둘이서도 혼자 걷는 사람',scene:'첫 공략 회의가 끝난 뒤 키리토와 같은 쪽으로 나서던 네 발걸음이 자꾸 앞서거나 뒤처진다. 키리토는 혼자 다닐 때의 간격이 그대로 남았다며 자기 옆의 빈 자리를 본다. 너는 아직 출발하지 않은 아스나와 키리토 앞에서 자기 보폭과 맡을 준비를 정한다.',choices:[b('190골드로 연습용 준비를 마련하고 내 간격을 맞춘다','sao_kirito_distance',190),b('더 많은 개인 사냥을 맡고 아스나의 앞쪽 보는 자세를 기억한다','sao_asuna',0,0,2),b('회의 뒤에 남은 보급품을 운반하고 보수를 받는다',null,0,0,0,150,1)],canonFact:'공식2화의 공략 회의와 솔로끼리 파티를 맺는 장면에 별도 여행자의 준비를 창작했다. 여행자가 본편의 파티원·공략 지휘자·디아벨의 생사를 결정하는 주체로 대체되지 않는다.'},
 {key:'sao_argo_second_question',title:'돌아갈 길 다음에 묻는 것',previous:'sao_argo_fork',previousChoice:1,scene:'돌아올 갈림길을 물었던 너를 아르고가 알아보고 이번에는 무엇이 빠졌냐고 묻는다. 네가 그 길에서 버텨야 할 상대도 알아야 한다고 말하자 아르고는 처음 질문과 이번 질문은 값이 다르다고 손가락을 편다. 앞선 답을 무효로 만들지 않고 새로운 질문에 자기 골드나 사냥 부담을 보탤지 정한다.',choices:[b('120골드를 내고 기억한 갈림길에 상대 정보를 맞춰 본다','sao_argo_return',120,0,0,120,0,70),b('190골드를 내고 상대 정보까지 차근차근 듣는다','sao_argo_return',190),b('더 많은 개인 사냥을 맡으며 같은 정보에서 내 몫을 고른다','sao_argo_shared',0,0,1),b('전달물을 반환하고 보급 보수를 받는다',null,0,0,0,160,1)],failure:'갈림길에 상대 정보를 맞추려 했지만 네가 기억한 부분만으로는 연결되지 않았다. 정보료120골드는 돌아오지 않고 카드와 확인 보수도 받지 못했다. 아르고는 앞선 귀환 답까지 틀렸던 것은 아니라고 덧붙인다.',canonFact:'sao_argo_fork에서 자신의 성공한1번 정보 구매 뒤에만 열리는 창작 후속이다. 실제 사냥 탐사·미니게임·정보상 카드 소모·새 시스템 지식을 요구하거나 구현하지 않는다.'}
];
const rewrites=[
 {key:'sao_smith_metal',scene:'키리토가 내민 희귀 검과 비교하던 리즈벳의 시험검이 부러져 공방의 말이 잠깐 끊긴다. 리즈벳은 재료만 있다면 더 좋은 검을 만들 수 있다고 하고 키리토는 아직 남은 파편을 본다. 너에게 새 검을 달라는 의뢰는 아니지만 수송 준비와 바깥 사냥, 남은 부품 운반 중 자기 일을 맡을 수 있다.',actions:['220골드로 수송 준비를 마련하며 리즈벳의 가공을 지켜본다','더 강한 개인 사냥을 맡으며 키리토의 움직임을 기억한다','남은 부품을 에길에게 전달하고220골드를 받는다'],canonFact:'공식7화에서 키리토가 리즈벳의 시험검을 부러뜨리고 희귀 금속이 있으면 원하는 검을 만들 수 있다는 대화가 나온다. 여행자의 수송·부품 전달은 창작이며 원작 검 제작의 주인공과 영구 무기 강화 결과는 바꾸지 않는다.'},
 {key:'sao_smith_return',scene:'네가 마련했던 수송 준비가 공방에 닿자 리즈벳은 이제 검을 만드는 쪽은 자기 일이라고 말한다. 키리토는 다음 동작을 살피고 아스나는 친구가 작업할 공간을 비우며 네가 아직 들고 있는 짐을 본다. 너는 직접 내려놓을 자리와 더 맡을 사냥 준비, 남길 보급 중 하나를 정한다.',actions:['더 많은 개인 사냥을 맡고 키리토의 다음 동작을 기억한다','200골드로 짐을 놓을 준비를 마련하고 아스나의 간격을 본다','남은 짐을 내려놓고250골드와물약1개를 받는다'],canonFact:'자신의 수송 준비 성공1번에서만 열리는 공방의 창작 후속이다. 리즈벳의 제작과 키리토의 원작 검은 대신 완성하지 않으며 아스나에게 위치·경계를 명령하지 않는다.'},
 {key:'sao_companion_herb',scene:'피나를 잃은 시리카에게 키리토가 소생을 위한 방법과 길을 설명하고 있다. 시리카는 돌아올 준비물을 만지다가 아직 피나가 없는 쪽을 돌아본다. 너는 소생의 결과를 대신 정하지 않고 그 길을 앞둔 자기 보급과 개인 사냥의 부담을 정한다.',actions:['180골드로 보급을 마련하고 시리카와 돌아올 준비를 한다','더 많은 개인 사냥을 맡으며 클라인과 버틸 간격을 기억한다','더 강한 개인 사냥을 맡으며 키리토의 경고를 듣는다','운반할 용기를 준비하고230골드를 받는다'],title:'작은 동료를 되찾으러',canonFact:'공식4화 소개로 피나를 잃고 키리토가 무상으로 소생 방법을 설명하고 돕는 사실을 확인했다. 꽃의 명칭·정확한 층·소생 시간제한은 이 공식 본문으로 확인하지 않아 새 설명에서 확정하지 않는다. 맵의 운반 준비와 클라인의 기억은 별도 창작이며 피나 소환과 소생을 지급하지 않는다.'},
 {key:'sao_rabbit_table',scene:'에길의 가게에서 키리토가 희귀한 라구 래빗 고기를 내밀지만 자기 요리 실력으로는 아깝다고 말한다. 아스나는 반을 나누는 조건으로 맡겠다고 하다가 요리 도구는 자기 방에 있다고 덧붙인다. 너는 고기의 주인이나 요리할 사람을 대신하지 않고 식탁 준비, 남은 거래, 자기 사냥의 몫을 정한다.',actions:['170골드로 식탁 준비를 보태고 아스나와 식사를 준비한다','에길에게 거래 운반을 돕고280골드를 받는다','더 많은 개인 사냥을 맡으며 클라인과 버틸 위치를 기억한다'],canonFact:'공식8화의 고기는 키리토가 얻었고 아스나는 절반을 받는 조건으로 자신의 요리 도구를 쓰려 한다. 여행자가 고기 소유권을 빼앗아 원작 식사를 취소하는 거래는 없으며 별도 식탁 준비와 운반 보수만 창작했다.'},
 {key:'sao_lakeside_wait',scene:'니시다가 찌를 보는 동안 키리토의 손은 한 번 더 당겨 보려는 쪽으로 움직인다. 니시다는 빨리 다음 일을 찾는 것과 입질을 기다리는 것은 다르다고 말하고 아스나는 두 사람 옆에 앉을 자리를 잡는다. 너는 작은 입질을 노려 볼 준비와 오래 기다릴 자리, 돌아갈 보급 중 자기 몫을 정한다.',actions:['150골드로 미끼를 마련하고 작은 입질의 때를 맞춰 본다','210골드로 기다릴 자리를 마련하고 니시다 옆에서 찌를 본다','더 많은 개인 사냥을 맡으며 아스나와 몸 상태를 유지할 준비를 한다','돌아갈 짐을 운반하고130골드와물약1개를 받는다'],failure:'150골드를 내고 미끼를 마련했지만 작은 입질을 놓쳤다. 준비 비용은 돌아오지 않고 카드와240골드의 낚시 보수도 받지 못했다. 니시다는 호수의 주인 이야기를 아직 꺼내지 않고 찌가 잠잠해질 때를 기다린다.',canonFact:'공식13화의 니시다 취미와 키리토·아스나가 만난 평범한 생활에서 별도 작은 낚시를 창작했다.65%의 입질·미끼값·낚시 보수·자리 준비는 맵 각색이며 호수 주인을 낚거나 쓰러뜨린 결말이 아니다. 실제 물고기 아이템·낚시 기능·호숫가 몬스터 침입은 없다.'}
].map(p=>{const old=current.events.find(e=>e.key===p.key);return {...p,previous:old.previous,previousChoice:old.previousChoice,choices:old.choices.map((c,i)=>({...c,action:p.actions[i]}))};});
const sourceFacts=[...read('requests/aincrad-pitches-51.json').brief.sourceFacts,
 {source:'https://www.swordart-online.net/sp/aincrad/story/story07.html',fact:'키리토는 예산보다 좋은 검을 원하고 리즈벳이 만든 최고 검의 내구력을 시험하다 부러뜨린다. 리즈벳은 희귀 금속이 있으면 원하는 검을 만들 수 있다고 맞선다. 여행자가 원작 검을 소유하거나 영구 장비 강화를 받지 않는다.'},
 {source:'https://www.swordart-online.net/sp/aincrad/story/story08.html',fact:'키리토가74층에서 희귀 라구 래빗 고기를 얻었지만 요리 스킬이 부족해 에길에게 팔려 한다. 아스나는 요리 스킬을 완성했고 고기의 절반을 받는 조건으로 자기 방의 도구를 쓰려 한다. 여행자가 원작 고기 소유권과 거래 결말을 바꾸지 않는다.'},
 {source:'https://www.swordart-online.net/character/index2.html',fact:'아스나는 리즈벳의 친한 친구이며 혈맹기사단 부단장·섬광이라 불리는 검사다. 에길은 상인 겸 도끼 전사, 클라인은 풍림화산 길드장이고 키리토의 친구다.'}
];
const learning={
 sao_argo_question:'사건 후보1개 추가(최대4개)와 방어력 관통6%',sao_argo_shared:'행동속도5%와 처치당골드2추가',sao_asuna_silence:'최대체력10%와받는피해감소5%',sao_kirito_distance:'이동속도6%와방향공격피해10%',sao_argo_return:'일반몬스터피해12%와치명타피해10%',
 sao_liz:'공격력12%와관통6%',sao_kirito:'행동속도6%와치명타확률4%p',sao_asuna:'신속270과방향공격피해12%',sao_silica:'최대체력8%와지속재생최대체력0.6%/초',sao_klein:'받는피해감소6%와비방향공격피해10%',sao_kirito_scout:'보스피해16%와관통10%',sao_asuna_meal:'65%이상체력일때피해14%와최대체력8%',sao_nishida_wait:'지속재생최대체력0.3%/초와비방향공격피해10%'
};
const expected=c=>({paidGold:c.cost,remembered:c.card?learning[c.card]:null,card:c.card,receivedGold:c.gold,receivedPotions:c.potions,personalEnemyStrengthChange:c.level,personalEnemyCountChange:c.density});
const all=[...events,...rewrites];
const schema=read('requests/magnolia-expansion-text-28.json').schema;schema.properties.events.minItems=all.length;schema.properties.events.maxItems=all.length;
write('requests/aincrad-expansion-fixed-52.json',{sourceRevision:'115324d',cards,events,rewrites,sourceFacts});
write('requests/aincrad-expansion-text-52.json',{review:false,schema,system:'한국어 사건 작가다. key와 선택순서를 유지해 story3문장·intro1문장·선택label·성공result2~3문장을 쓴다. 실제 인물의 손과 시선, 아직 남은 질문으로 이야기한다. 모든 결과에 지불·성장·골드/물약·지속 개인 적 강함/수의 사실을 빠뜨리지 않는다. 통계목록이나 최적·효율·칭찬·끄덕임으로만 끝내지 않는다. 원문을 복사하지 않는다.',brief:{sourceFacts,events:all.map(e=>({key:e.key,scene:e.scene,previous:e.previous||null,previousChoice:e.previousChoice||0,choices:e.choices.map(c=>({action:c.action,chance:c.chance,expectedSuccess:expected(c)}))})),rules:[
 '사건중개인사냥은정지다. 적강함/수선택은이후개인사냥에지속되는부담이며실제NPC동행·추가처치·새원작장비·도구·물고기아이템·스킬·정보시장기능은없다.',
 '카드는기억과성장이다. 최대체력이늘면기존현재/최대비율을유지한다. 기억을얻어상처가즉시낫거나소녀기억이돌아오지않는다.흡수/재생은합계최대체력10%/초한도,물약은별도.',
 '골드와물약을따로숫자로설명하고0은보상으로추가하지않는다.65/70%result는성공한때만설명한다.실패와원작승패·사망·소생은다른문장이다.',
 '정보상의원작독점규칙·베타정답·다른플레이어정보를추가하지않는다.외투/짐/전달물은창작소품이며현재체력·물약차감·추가AP·시간변화없다.',
 '각사건은서로다른시점이다.1층회의·22층소녀·니시다낚시를같은하루에이어붙이지않는다.고기는키리토것이며아스나의반나눔조건을여행자가취소하지않는다.'
]}});
console.log(JSON.stringify({newCards:cards.length,newRoots:4,newFollowups:1,rewrites:rewrites.length}));
