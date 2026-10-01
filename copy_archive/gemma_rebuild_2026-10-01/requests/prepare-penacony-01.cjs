// 확인한 페나코니 소재와 선택 손익을 보존하고 Gemma에 사건 결과 집필을 요청한다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const base=path.resolve(__dirname,'..');
const card=(key,name,effectName,keyword,grade,effects,canonFact,kind=0,goal=0,extra=[])=>({key,name,effectName,keyword,grade,effects:effects.map(([stat,value])=>({stat,value})),evolution:{kind,goal,effects:extra.map(([stat,value])=>({stat,value}))},canonFact,uncertain:[]});
const choice=(label,card=null,values={})=>({label,result:'검토 대기.',card,card2:null,gold:0,cost:0,level:0,density:0,potions:0,chance:100,...values});
const event=(key,title,story,intro,choices,values={})=>({key,title,story,intro,previous:null,previousChoice:0,requiredCard:null,choices,failure:null,canonFact:'확인한 황금의 순간의 시설과 인물 역할을 이용한 맵 창작 사건이다. 원작 특정 임무의 재현이 아니다.',uncertain:[],...values});
const plan={world:{key:'penacony',name:'페나코니',work:'붕괴 스타레일',intro:'레버리 호텔의 미샤가 꿈세계로 향하는 손님을 안내한다. 황금의 순간에는 오락시설의 불빛과 솔글래드 광고가 뒤섞여 있다.',effects:[{stat:'crit_chance',value:2}],entryCard:'hsr_misha',icon:'ReplaceableTextures\\CommandButtons\\BTNTome.blp'},sources:['https://blog.ko.playstation.com/2024/01/30/20240130-honkaistarrail/','https://blog.ja.playstation.com/2024/03/16/20240316-starrail/','https://honkai-star-rail.fandom.com/wiki/HoYoLAB/Articles/The_Trailblaze_Special_Dreamscape_Guide01'],canonBoundary:'호텔·황금의 순간과 인물의 역할은 HoYoverse 개발팀 소개를 확인했다. 에이딘 공원·솔글래드 음료·좋은꿈 슬롯머신은 게임 내 시설 및 개발사 안내의 커뮤니티 전재 자료로 대조했다. 슬롯머신 확률과 판돈·보상은 원작 수치가 아닌 맵 창작이다. 솔글래드는 음료 브랜드이며 술로 전제하지 않는다. 원작의 방어막 생성·추가 공격·행동 게이지·아르카나 지속 피해·적 디버프·빙결·기억 조작을 새로 구현하지 않는다. 카드의 보호막 조건은 이미 존재하는 플레이어 보호막에만 적용되고 갤러거의 회복은 공통 지연 흡수로 각색한다.',cards:[
 card('hsr_misha','미샤','손님이 돌아갈 길','이동 · 고체력',1,[['move_speed',2],['healthy_damage',5]],'레버리 호텔의 벨보이이며 손님들의 모험담을 좋아한다. 안내를 받아 여유 있게 준비하는 입문 효과다.'),
 card('hsr_misha_route','미샤','기다리는 손님을 위해','행동 · 일반 몬스터',2,[['action_speed',5],['normal_damage_percent',10]],'호텔 손님을 돕는 미샤의 분주한 준비를 각색한다. 빙결이나 새 호텔 업무 시스템은 지급하지 않는다.',1,40,[['healthy_damage',8]]),
 card('hsr_aventurine_fortune','어벤츄린','운명을 마주하는 미소','치명',2,[['crit_chance',5],['crit_damage',18]],'위험과 운명을 게임처럼 마주하는 인물의 태도를 치명 기회의 준비로 각색한다. 원작 슬롯머신 보상이나 확률을 주장하지 않는다.',1,50,[['boss_damage_percent',8]]),
 card('hsr_aventurine_reserve','어벤츄린','판돈 밖에 남겨 둔 여유','보호막 · 치명',2,[['shielded_damage',18],['crit_damage',15]],'아군 보호막과 치명 피해 지원 역할을 참고했다. 새 보호막을 만들지 않고 이미 보유한 보호막 조건만 강화한다.'),
 card('hsr_sparkle','스파클','다음 막은 누구의 차례','행동 · 치명',2,[['action_speed',8],['crit_damage',15]],'신분과 역할을 바꾸며 재미를 추구하는 가면의 우인이다. 원작 행동 게이지·치명 피해 지원을 공통 능력치로 각색한다.'),
 card('hsr_black_swan_trace','블랙 스완','기억에 남은 빈틈','피해 · 보스',2,[['damage_percent',12],['boss_damage_percent',8]],'기억을 살피는 기억하는 자의 역할을 상대의 빈틈을 기억하는 준비로 각색한다. 아르카나 중첩이나 지속 피해를 지급하지 않는다.',2,15000,[['final_damage_percent',4]]),
 card('hsr_black_swan_archive','블랙 스완','흩어진 장면을 잇기','탐색 · 고체력',2,[['event_choices',1],['healthy_damage',8]],'타인의 기억을 경청하고 정리하는 역할을 다음 사건 판단의 여유로 각색한다. 미래 당첨 결과를 알려 주지 않는다.'),
 card('hsr_gallagher','갤러거','경계를 놓지 않는 환대','흡수 · 방어',2,[['leech',5],['damage_reduction',4]],'보안관 겸 바텐더이며 전투에서는 특정 상태의 적을 공격한 아군을 회복시킨다. 카드는 실제 피해의 지연 흡수와 경계 태도로 각색하고 원작 디버프를 새로 만들지 않는다.')
],events:[
 event('hsr_dreamy_slots','좋은꿈 슬롯머신 앞에서','에이딘 공원의 슬롯머신 앞에서 코인을 쥔 손님들이 다음 차례를 기다린다. 어벤츄린은 손에 남길 돈부터 정하라며 빈 기계 옆에 선다. 옆줄에서는 쏟아진 코인이 통로까지 굴러 나와 사람들이 몰리고 있다.','판돈을 정할지, 어벤츄린의 준비를 살필지, 막힌 통로를 도울지 정한다.',[
  choice('코인을 바꾸고 어벤츄린과 한 번만 돌린다','hsr_aventurine_fortune',{cost:300,gold:600,chance:60}),
  choice('놀이 대신 어벤츄린과 귀환 준비를 챙긴다','hsr_aventurine_reserve',{cost:220}),
  choice('쏟아진 코인을 모아 통로 밖으로 옮긴다',null,{gold:150,potions:1,density:1})
 ],{failure:'회전판은 맞지 않은 그림에서 멈췄다. 바꿔 넣은 코인은 돌아오지 않았고 어벤츄린은 다음 판을 대신 돌려주지 않는다. 조용한 쪽으로 걸어가 잠깐 전의 선택을 돌아본다.'}),
 event('hsr_after_win','멈춘 회전판 너머','한 번의 놀이를 끝내고 코인을 정리하는데 스파클이 박수 소리를 흉내 낸다. 같은 얼굴을 따라온 손님들이 출구를 막자 갤러거가 놀이가 끝난 사람부터 밖으로 안내한다.','당첨 뒤 모인 손님 사이에서 누구와 출구를 정리할지 고른다.',[
  choice('스파클과 손님들의 시선을 다른 무대로 돌린다','hsr_sparkle',{cost:220,density:1}),
  choice('갤러거와 조용한 귀환 통로를 확보한다','hsr_gallagher',{cost:180,density:-1})
 ],{previous:'hsr_dreamy_slots',previousChoice:1}),
 event('hsr_after_loss','맞지 않은 그림의 기억','당첨되지 않은 회전판의 그림이 자꾸 떠오른다. 블랙 스완은 기억 속 손이 언제 멈칫했는지 함께 살피자고 한다. 갤러거는 또 돌리러 가기 전에 돌아갈 길부터 정하라고 권한다.','틀린 그림을 다시 돌리는 대신 남은 준비를 정한다.',[
  choice('블랙 스완과 결정을 망설인 장면을 돌아본다','hsr_black_swan_archive',{cost:180}),
  choice('갤러거와 붐비는 길을 피해 돌아갈 준비를 한다','hsr_gallagher',{cost:180,density:-1})
 ],{previous:'hsr_dreamy_slots',previousChoice:-1}),
 event('hsr_sorted_tokens','코인 자루가 떠난 자리','코인을 모은 자루는 통로 밖으로 옮겼지만 몰려든 사람들은 다른 쪽 출구로 흩어졌다. 미샤는 호텔로 돌아갈 손님을 따로 안내하고, 어벤츄린은 남은 준비물을 빽빽한 길과 나눠 쓰지 말자고 한다.','정리한 통로 끝에서 다음 길의 준비를 고른다.',[
  choice('미샤와 호텔로 돌아갈 손님을 나눠 안내한다','hsr_misha_route',{cost:140,level:-1}),
  choice('어벤츄린과 귀환길에 쓸 준비물을 따로 챙긴다','hsr_aventurine_reserve',{cost:180})
 ],{previous:'hsr_dreamy_slots',previousChoice:3}),
 event('hsr_soulglad','광고 아래의 솔글래드','커다란 솔글래드 광고 아래에서 음료를 받은 손님들이 서로 다른 방향을 가리킨다. 갤러거는 유난히 같은 말만 반복하는 사람을 경계하고, 미샤는 호텔로 돌아오지 않은 손님을 찾는다. 쉬지 않고 손님을 모으는 안내대에는 돌아갈 사람의 짐도 쌓여 있다.','환한 음료 광고 아래의 손님과 귀환 준비를 살핀다.',[
  choice('갤러거와 되풀이되는 안내를 확인한다','hsr_gallagher',{cost:180}),
  choice('미샤와 호텔로 돌아갈 손님을 찾아 나선다','hsr_misha_route',{cost:120,density:-1}),
  choice('안내대의 보급 짐을 정리하고 수고비를 받는다',null,{gold:220,density:1})
 ]),
 event('hsr_masked_stage','서로 다른 얼굴의 안내인','무대 앞에서 같은 안내인이 한 번은 오른쪽을, 다음에는 왼쪽을 가리킨다. 스파클은 어느 쪽 얼굴을 믿느냐고 되묻고, 블랙 스완은 두 안내를 들었을 때의 기억을 따로 살펴보자고 한다.','스파클의 연극에 맞출지, 들었던 안내를 기억으로 대조할지 정한다.',[
  choice('스파클의 바뀐 배역에 맞춰 무대를 빠져나간다','hsr_sparkle',{cost:200,level:1}),
  choice('블랙 스완과 두 안내가 갈린 순간을 대조한다','hsr_black_swan_trace',{cost:240}),
  choice('블랙 스완과 지나온 길의 순서부터 정리한다','hsr_black_swan_archive',{cost:180})
 ]),
 event('hsr_remembered_exit','기억에 남겨 둔 출구','서로 달랐던 안내를 기억과 대조한 뒤, 사람들의 걸음이 꺾이는 자리를 찾았다. 어벤츄린은 그 좁은 자리를 그대로 통과하지 말자고 하고, 갤러거는 남아 있는 경비 안내를 다시 확인한다.','찾아낸 출구의 빈틈을 안전한 준비로 바꾼다.',[
  choice('어벤츄린과 넓은 통로를 준비한다','hsr_aventurine_reserve',{cost:260,density:-1}),
  choice('갤러거와 경비가 확인한 우회로를 택한다','hsr_gallagher',{cost:220,level:-1})
 ],{previous:'hsr_masked_stage',previousChoice:2}),
 event('hsr_walking_sign','계속 움직이는 목적지','뛰어다니는 광고판을 따라가자 같은 가게 앞을 다시 지나쳤다. 미샤는 호텔 입구의 시계판이 있는 쪽을 짚고, 블랙 스완은 방금 본 간판과 기억 속 간판의 차이를 찾는다.','움직이는 광고판과 실제 귀환길을 구분한다.',[
  choice('미샤와 호텔 입구를 기준으로 길을 다시 표시한다','hsr_misha_route',{cost:140,density:-1}),
  choice('블랙 스완과 반복해서 본 간판을 대조한다','hsr_black_swan_trace',{cost:200}),
  choice('광고판을 따라온 손님을 모아 안내대를 돕는다',null,{gold:180,potions:1,density:1})
 ])
]};
const schema={type:'object',properties:{events:{type:'array',items:{type:'object',properties:{key:{type:'string'},results:{type:'array',items:{type:'string',maxLength:210}},failure:{type:['string','null']}},required:['key','results','failure'],additionalProperties:false}}},required:['events'],additionalProperties:false};
const request={schema,system:'한국어 게임 사건의 결과를 공동 집필한다. 제공된 문제·행동·선행 결과와 일치하는 짧은 결과를 행동 순서대로 쓴다. 성공 결과에서 아직 감수해야 할 위험을 이미 없앴다고 쓰지 않는다. 실패는 보상 없이 끝나고 판돈이 소모되지만 당첨을 보장하거나 잃은 돈을 자동으로 돌려주지 않는다. 능력치·카드·숫자·제작용 요약을 그대로 베끼지 말고 인물과 물건, 남은 길이 구체적으로 어떻게 바뀌었는지 1~2문장으로 쓴다. 원작 특정 임무가 일어났다고 주장하거나 설정을 새로 확정하지 않는다. 솔글래드를 술·치료제로 쓰지 않는다. 블랙 스완이 당첨을 예언하지 않으며 스파클은 환락을 위한 배역 놀이를 한다. 원작 보호막·분신·기억 조작·디버프 기술을 플레이어가 얻는다고 쓰지 않는다. 말투를 흉내 낸 인용 대사보다 행동 서술을 쓴다. 모든 문장은 콜론으로 끝내지 않는다.',brief:{facts:['미샤는 레버리 호텔의 벨보이며 손님들의 모험담을 좋아한다.','어벤츄린은 위험을 즐기지만 속마음을 읽기 어려운 투자 부서의 고위 간부다.','스파클은 배역과 신분을 바꾸며 재미를 추구한다.','블랙 스완은 기억을 경청하고 정리하는 기억하는 자다. 미래 당첨을 보장하지 않는다.','갤러거는 경계를 놓지 않는 보안관 겸 바텐더다.','황금의 순간에는 움직이는 광고판과 오락시설이 있고 에이딘 공원은 솔글래드 음료 브랜드의 후원으로 세워졌다.'],events:plan.events.map(e=>({key:e.key,problem:e.story,previous:e.previous?{action:plan.events.find(p=>p.key===e.previous).choices[Math.abs(e.previousChoice)-1].label,failure:e.previousChoice<0}:null,actions:e.choices.map(b=>({action:b.label,spending:b.cost>0,remainingRisk:b.level>0?'더 강한 상대와 마주치는 길':b.density>0?'귀환길에 더 많은 상대의 흔적':b.level<0?'강한 상대를 피하는 길':b.density<0?'혼잡한 통로를 나눠 상대가 몰리지 않는 길':'통행 부담 변화 없음',payment:b.gold>0?'플레이어가 수고비 또는 당첨금을 받음':'수고비 없음',uncertain:b.chance<100})),failure:e.failure}))}};
fs.writeFileSync(path.join(base,'revisions/penacony-plan-01.json'),JSON.stringify(plan,null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(__dirname,'penacony-results-01.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});
console.log('페나코니 카드 8종과 사건 8개를 집필 요청으로 보존했습니다.');
