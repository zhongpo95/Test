// 학원도시의 쇼핑·간식·대회 준비·수영부·길목·야간 퍼레이드를 독립 사건으로 준비한다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const current=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/04-academy.json'),'utf8'));
const f=(stat,value)=>({stat,value}),none={kind:0,goal:0,effects:[]};
const c=(key,name,effectName,keyword,effects,canonFact,evolution=none)=>({key,name,effectName,keyword,grade:2,effects,evolution,canonFact,uncertain:[]});
const cards=[
 c('academy_mikoto_keepsake','미사카 미코토','진열 앞에서 한 번 더','치명타 피해 · 최대 체력',[f('crit_damage',15),f('max_health_percent',6)],'귀여운 소품을 좋아하는 공식 취향을 힘을 쏟을 순간을 고르고 다음 일을 버틸 준비로 각색한다. 특정 마스코트·실제 소품 장비·새 전격을 지급하지 않는다.'),
 c('academy_uiharu_break','우이하루 카자리','쉬었다가 다시 맞춘 항목','재생 · 차지 속도',[f('regeneration',0.3),f('charge_speed',8)],'단것 선호·정보 처리와 관찰 집중에서 오래 움직이며 차지 동작을 준비할 습관을 각색한다. 케이크 즉시 회복·새 자원·행동력 증가는 없다.'),
 c('academy_kongo_pair','콘고 미츠코','옆 사람에게 맞춘 보폭','행동 속도 · 이동속도 비례 피해',[f('action_speed',5),f('moving_damage',12)],'친구를 아끼는 성격과 대패성제에서 미코토와 짝을 이루는 역할을 보폭과 다음 동작을 맞출 준비로 각색한다. 실제 이인삼각 이동 제한·에어 핸드 능력·경기 우승 보상은 없다.'),
 c('academy_wannai_calm','완나이 키누호','흐르는 쪽부터 살피기','피해 감소 · 최대 체력',[f('damage_reduction',5),f('max_health_percent',8)],'수영부·물 흐름을 다루는 능력과 침착함을 버틸 위치를 먼저 보는 준비로 각색한다. 수중 전투·물 장벽·새 보호막은 생성하지 않는다.'),
 c('academy_awatsuki_balance','아와츠키 마아야','떠 있는 동안의 균형','차지 속도 · 차지 피해',[f('charge_speed',6),f('charge_damage',12)],'대상 주변의 부력을 조절하는 플로트 다이얼과 수영부 역할을 준비 동작의 균형으로 각색한다. 물의 밀도를 바꾸는 능력으로 설명하지 않으며 공중 부양·중력 면역은 없다.'),
 c('academy_sogiita_guts','소기이타 군하','먼저 내디딜 한 걸음','공격력 · 최대 체력 패널티',[f('attack_percent',18),f('max_health_percent',-5)],'곤란한 사람을 돕는 열혈 성격을 더 세게 밀어붙이되 오래 버틸 여유를 줄이는 성장으로 각색한다. 원작의 불명확한 능력 원리·새 펀치·무적을 구현하지 않는다. 최대 체력 패널티는 지속 능력치이며 현재 체력 지불 선택지가 아니다.',{kind:2,goal:9000,effects:[f('normal_damage_percent',10)]})
];
const b=(action,card=null,cost=0,level=0,density=0,gold=0,potions=0,chance=100)=>({action,card,card2:null,cost,level,density,gold,potions,chance});
const events=[
 {key:'academy_display_window',title:'진열창 앞에서 멈춘 발걸음',scene:'미코토가 귀여운 소품 진열을 보다가 한 발 물러선다. 쿠로코는 약속한 순찰 시간이 다가온다고 알리고 가게 주인은 새 상자 때문에 가려진 진열창을 가리킨다. 쿠로코의 부탁과 가게 정리를 한 번에 맡기에는 손이 부족하다.',choices:[b('정리 도구 값을 보태고 미코토와 가려진 진열을 고친다','academy_mikoto_keepsake',180),b('쿠로코와 적이 더 많이 드나드는 순찰 길목을 맡는다','academy_kuroko_response',0,0,1),b('빈 상자만 옮기고 가게의 작업 보수를 받는다',null,0,0,0,140)],canonFact:'공식 미코토의 귀여운 소품 취향·쿠로코의 풍기위원 책임감에서 별도 일상 만남을 창작한다. 특정 게코타 굿즈·새 가게·대회 결과를 원작 사실로 주장하지 않는다.'},
 {key:'academy_sweet_orders',title:'단것 옆에 남은 주문 한 줄',scene:'우이하루가 쉬는 시간에 단것을 고르려는데 점원은 접힌 주문표 때문에 같은 상자가 두 번 적혔다고 말한다. 우이하루는 종이를 펴고 사텐은 아직 정리하지 않은 납품 상자를 가리킨다. 주문을 맞출지 남은 상자를 맡을지 정해야 한다.',choices:[b('확인 용품을 마련하고 우이하루와 주문을 맞춘다','academy_uiharu_break',160),b('우이하루와 더 강한 적이 드나드는 납품 경로의 연락을 맡는다','academy_dispatch',0,1),b('빈 상자를 정리하고 작업 보수와 보급 물약을 받는다',null,0,0,0,130,1)],canonFact:'공식 우이하루의 단것 취향·관찰과 정보 처리, 사텐과의 교우에서 별도 주문 문제를 만든다. 단것이 현재 체력을 즉시 회복시키거나 사건 행동력을 더 주지 않는다.'},
 {key:'academy_pair_step',title:'둘이 묶기 전에 맞출 보폭',scene:'대패성제의 이인삼각 준비 자리에서 콘고가 미코토에게 먼저 출발 순서를 묻는다. 미코토가 보폭을 짚자 콘고는 자기 쪽만 크게 내디뎠던 발을 멈춘다. 완나이는 바깥 준비물도 아직 나누지 못했다고 알린다.',choices:[b('준비 도구를 마련해 콘고와 옆 사람의 보폭을 맞춘다','academy_kongo_pair',180),b('미코토와 더 강한 적이 오가는 바깥 준비 구역을 맡는다','academy_mikoto',0,1),b('완나이와 버틸 위치를 살필 준비물을 챙긴다','academy_wannai_calm',220),b('남은 끈과 상자를 정리하고 준비 보수를 받는다',null,0,0,0,150)],canonFact:'초전자포T 공식2화의 미코토·콘고 이인삼각과 공식 콘고의 친구를 아끼는 성격을 사전 준비 만남으로 각색한다. 실제 경기 승패를 새 선택으로 바꾸거나 플레이어의 이동을 이인삼각으로 제한하지 않는다.'},
 {key:'academy_pool_bundle',title:'풀 가장자리에 모인 준비물',scene:'수영부 준비물 꾸러미가 풀 가장자리에 한꺼번에 모였다. 완나이는 물이 흐르는 쪽부터 보자고 하고 아와츠키는 잠깐 뜨게 할 물건을 따로 나눈다. 콘고가 바깥 통행까지 맡겠다고 나서자 완나이는 먼저 맡을 범위를 적자고 한다.',choices:[b('준비물 비용을 내고 완나이와 버틸 위치를 살핀다','academy_wannai_calm',220),b('받침 도구를 마련해 아와츠키와 준비 동작의 균형을 맞춘다','academy_awatsuki_balance',220),b('바깥 담당 구역을 줄이고 준비물 정리 보수와 물약을 받는다',null,0,0,-1,120,1)],canonFact:'공식 완나이의 수영부·하이드로 핸드와 아와츠키의 수영부·플로트 다이얼, 콘고와의 친구 관계에서 별도 준비 문제를 만든다. 부력을 물 밀도로 오기하지 않고 물건이나 NPC의 이동을 실제 게임 기능으로 생성하지 않는다.'},
 {key:'academy_guts_corner',title:'큰 소리보다 먼저 옮길 짐',scene:'길목을 막은 짐을 보고 군하가 곤란한 사람을 그냥 둘 수 없다며 앞으로 나온다. 토우마는 짐의 도착지를 먼저 확인하자고 하고 군하는 이미 한쪽을 들 준비를 한다. 짐을 옮긴 뒤 어느 길목까지 맡을지 결정해야 한다.',choices:[b('군하와 더 강한 적이 드나드는 길목까지 맡는다','academy_sogiita_guts',0,1),b('운송 도구를 마련해 토우마와 남은 사람 쪽을 살핀다','academy_touma',200),b('빈 운송 도구를 정리하고 보수와 보급 물약을 받는다',null,0,0,0,150,1)],canonFact:'공식 군하의 열혈·근성·곤란한 사람 돕기, 토우마의 어려운 사람을 외면하지 못하는 성격에서 별도 짐 정리를 창작한다. 군하 능력의 과학적 원리·신기술·불운 해소를 확정하지 않는다.'},
 {key:'academy_parade_markers',title:'밤 퍼레이드 전에 남은 표식',scene:'낮 경기가 끝나고 밤 퍼레이드 준비가 시작되자 예전 안내표와 새 표식이 한 상자에서 섞여 나온다. 우이하루는 이전 기록의 연락처부터 대조하고 쿠로코는 확인되지 않은 표식을 길목에 세우지 말라고 한다. 사텐은 지금 확인할 몫과 내일로 남길 몫을 따로 놓는다.',choices:[b('120골드의 연락 비용을 내고 예전 표식의 기록을 찾는다','academy_uiharu_break',120,0,0,210,0,70),b('새 표시 도구를 마련해 쿠로코와 대응 순서를 맞춘다','academy_kuroko_response',200),b('맡을 길목을 줄이고 상자 정리 보수와 물약을 받는다',null,0,0,-1,130,1)],failure:'예전 표식의 기록을 확인하지 못했다. 연락 비용 120골드는 돌아오지 않고 카드와 기록 확인 보수도 받지 못한다. 우이하루는 확인되지 않은 표식을 상자에 남긴다.',canonFact:'초전자포T 공식4화의 밤 퍼레이드 배경에 별도 표식 준비 의뢰를 창작했다. 70%와 보수는 맵의 수치다. 미사카 동생 실종·기억 조작·음모의 본편을 이 선택으로 해결하지 않는다.'}
];
const sourceFacts=[
 ['https://toaru-project.com/railgun_t/chara/mikoto.html','미코토는 귀여운 소품을 좋아하며 솔직하고 털털한 성격이다.'],
 ['https://toaru-project.com/railgun_t/chara/kuroko.html','쿠로코는 풍기위원의 책임감과 강한 정의감을 지닌다.'],
 ['https://toaru-project.com/railgun_t/chara/uiharu.html','우이하루는 단것을 좋아하고 관찰·정보 처리에 집중하며 쿠로코의 백업을 맡는다.'],
 ['https://toaru-project.com/railgun_t/chara/saten.html','사텐은 우이하루와 같은 반이며 활발한 레벨0 학생이다.'],
 ['https://toaru-project.com/railgun_t/chara/kamijo.html','토우마는 곤란한 사람을 외면하지 못하는 불운한 고등학생이다.'],
 ['https://toaru-project.com/railgun_t/chara/kongou.html','콘고는 토키와다이2학년·레벨4 에어 핸드, 과시하는 면이 있지만 솔직하고 친구를 아낀다.'],
 ['https://toaru-project.com/railgun_t/chara/wannai.html','완나이는 수영부·레벨3 하이드로 핸드로 물의 흐름을 다루며 침착하고 온화하다.'],
 ['https://toaru-project.com/railgun_t/chara/awatsuki.html','아와츠키는 수영부·레벨3 플로트 다이얼로 대상 주변의 부력을 조절하며 완나이와 함께 다니고 콘고의 친구다.'],
 ['https://toaru-project.com/railgun_t/chara/sogiita.html','군하는 레벨5 일곱 번째, 근성과 열혈로 곤란한 사람을 돕는다. 능력의 상세 원리는 불명확하다.'],
 ['https://toaru-project.com/railgun_t/story/02.html','미코토와 콘고가 이인삼각의 짝이 된다. 새 사건은 경기 전에 준비하는 별도 만남이다.'],
 ['https://toaru-project.com/railgun_t/story/04.html','낮 경기가 끝난 뒤 밤 퍼레이드가 있다. 새 사건은 독립된 표식 준비 문제이며 본편 음모는 해결하지 않는다.']
].map(([source,fact])=>({source,fact}));
const str={type:'string'},schema={type:'object',additionalProperties:false,required:['events'],properties:{events:{type:'array',minItems:6,maxItems:6,items:{type:'object',additionalProperties:false,required:['key','story','intro','choices'],properties:{key:str,story:str,intro:str,choices:{type:'array',minItems:2,maxItems:4,items:{type:'object',additionalProperties:false,required:['label','result'],properties:{label:str,result:str}}}}}}}};
const request={review:false,schema,system:'한국어 게임 화면용 사건 작가다. story는 구체적 문제와 인물 행동3문장, intro는1문장, result는2~3문장으로 쓴다. key와 선택 순서를 유지한다. 개발 설명·공식 출처·몇 화·NPC·기능 제약은 화면 문장에 넣지 않는다.',brief:{events:events.map(({canonFact,...e})=>e),cards:[...current.cards,...cards].map(c=>({key:c.key,name:c.name,effectName:c.effectName})),sourceFacts,rules:['도구·운송·연락 비용을 내는 것이며 우정이나 카드를 사는 돈이 아니다. 비용·실제 작업·관련 인물의 짧은 반응을 잇는다. 모든 결과를 NPC의 칭찬·감탄·깊은 신뢰·고마움으로 끝내지 않는다.','카드는 플레이어의 준비 습관을 준다. 실제 초능력·전격·펀치·물 장벽·비행·소환·신규 장비를 지급하지 않는다. 케이크나 식사로 현재 체력 즉시 회복을 약속하지 않는다.','level은 개인 사냥의 적 강함,density는 개인 사냥의 적 수다. 위험한 길 선택은 실제 적 단계·수가 변하는 결과를 쓴다. 경로만 안전해지거나 거리가 늘어난다고 끝내지 않는다.','우이하루 휴식은 오래 움직이면서 차지 동작을 준비하는 습관, 미코토 진열은 힘을 쏟을 순간과 버틸 준비, 콘고 보폭은 다음 동작과 이동속도에 비례한 공격 준비, 완나이는 위치·버티기, 아와츠키는 차지 동작 균형이다. 원작 고유 기술을 획득했다고 쓰지 않는다.','군하 카드는 더 세게 밀어붙이되 오래 버틸 여유를 조금 줄이는 성장이다. 현재 체력을 소모하는 계약이나 실제 피로 상태가 아니다.','마지막 사건 첫 분기는120골드 연락 비용후70% 성공으로 우이하루카드·210골드보수, 실패는 비용만이다. 성공 결과만 작성하며 고정 failure문은 요청에 있지만 출력하지 않는다.','보수는 가게·준비 담당자가 제공하고 물약은 보급품이다. 최대4선택의 구체적인 작업 차이를 보존한다. 대패성제 경기 승패·본편 실종·기억 조작을 해결하지 않는다.']}};
fs.writeFileSync(path.join(root,'requests/academy-expansion-fixed-17.json'),JSON.stringify({cards,events,sourceFacts},null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(root,'requests/academy-expansion-text-17.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});
console.log('학원도시 독립6사건·관련6카드 집필 요청 보존.');
