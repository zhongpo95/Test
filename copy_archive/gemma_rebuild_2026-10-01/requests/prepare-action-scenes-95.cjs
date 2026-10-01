// 무료 사건·행동력 최대치·보유 카드 조건의 원본을 보존하고 Gemma 집필 요청을 만든다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const files=['04-academy.json','13-butterfly.json','01-fuyuki.json','02-axel.json','03-abydos.json'];
const before={};
for(const file of files){const bytes=fs.readFileSync(path.join(repo,'content/roguelite',file));before[file]={sha256:crypto.createHash('sha256').update(bytes).digest('hex'),data:JSON.parse(bytes)};}
const save=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
save('revisions/action-scenes-before-95.json',before);
const card={key:'academy_uiharu_plan',name:'우이하루 카자리',effectName:'다음에 맡을 몫',keyword:'행동력 최대치',grade:2,effects:[{stat:'action_capacity',value:1}],evolution:{kind:0,goal:0,effects:[]},canonFact:'정보 지원과 남은 일을 정리하는 역할에서 여행자가 추가로 맡을 몫을 정하는 창작 기억이다. 행동력 최대치와 현재 행동력이1늘며 원작 인물의 초능력·시간 정지·즉시 전투 보너스는 없다.',uncertain:[]};
const branch=(label,card,cost,level=0,density=0)=>({label,card,card2:null,gold:0,cost,level,density,potions:0,chance:100,result:''});
const events=[
 {key:'academy_next_shift',title:'확인한 뒤에도 남은 몫',intro:'우이하루가 확인할 순서를 적어 둔 네 기록을 다시 펼친다.',story:'우이하루가 네가 남긴 확인 순서 옆에 아직 맡을 사람을 적지 못한 항목을 붙인다. 사텐은 돌아갈 골목을 알려 줄 수 있다고 하고 쿠로코는 통행을 막지 않을 경계를 먼저 정하자고 한다. 앞서 기록을 정리한 너도 이번에는 어디까지 맡을지 답해야 한다.',requiredCard:'academy_uiharu_order',previous:null,previousChoice:0,actionCost:1,failure:null,choices:[branch('200골드로 내 준비를 마련하고 우이하루와 다음에 맡을 몫을 정한다','academy_uiharu_plan',200),branch('160골드로 안내를 마련하고 사텐과 돌아갈 표식을 남긴다','academy_saten_detour',160,0,-1),branch('쿠로코와 더 강한 적이 드나드는 통로의 경계를 맡는다','academy_kuroko_line',0,1)]},
 {key:'academy_unsealed_list',title:'접지 않은 항목의 답',intro:'남겨 둔 항목에 돌아갈 곳과 전할 말이 붙었다.',story:'우이하루가 네가 접어 두지 않은 항목을 보며 확인된 내용과 다시 물어야 할 내용을 나눈다. 토우마는 짐의 도착지가 아직 비어 있다고 하고 사텐은 먼저 나를 상자를 가리킨다. 쿠로코는 나가기 전에 돌아올 자리도 남겨 달라고 한다. 이미 남긴 기록이 있어 처음부터 묻지는 않아도 된다. 다만 모두의 일을 한꺼번에 맡을 수는 없다.',requiredCard:'academy_uiharu_list',previous:null,previousChoice:0,actionCost:0,failure:null,choices:[branch('160골드로 운반을 준비하고 토우마와 짐의 도착지를 확인한다','academy_touma_address',160),branch('사텐과 더 많은 적이 오가는 납품 구역의 상자를 나눈다','academy_saten_box',0,0,1),branch('180골드로 포장을 마련하고 쿠로코에게 돌아올 자리를 남긴다','academy_kuroko_return',180)]}
];
const free={ '04-academy.json':'academy_no_ability','13-butterfly.json':'kny_morning_greeting','01-fuyuki.json':'fy_one_more_blanket','02-axel.json':'axel_newcomer_questions','03-abydos.json':'ab68_big_bill'};
save('requests/action-scenes-fixed-95.json',{card,events,free,policy:{defaultCandidates:3,maxCandidates:4,normalAPCost:1,freeAPCost:0,capacity:'최대치10+카드값. 최대치 증가분만 현재AP에도 지급. 재계산·중복 획득·화면 갱신으로 재지급하지 않음.',conditions:'requiredCard는 자기 카드 보유 판정. 무료 사건도 잔여AP>0일 때만 등장. 선택하면 파티 공유 만남 기록에 남아 재등장하지 않음.',boundary:'사건·카드·시간·실제 사냥은 다른 개념이다. 같은 카드의 다른 비용안이 아니라 서로 다른 지정 카드 세 개다. 직접 골드 보상과 현재 체력 지불은 없다. 원작 사건을 해결하지 않는다.'}});
const choiceSchema={type:'object',additionalProperties:false,required:['index','label','result'],properties:{index:{type:'integer',enum:[1,2,3]},label:{type:'string'},result:{type:'string'}}};
const eventSchema={type:'object',additionalProperties:false,required:['key','title','intro','story','choices'],properties:{key:{type:'string',enum:events.map(e=>e.key)},title:{type:'string'},intro:{type:'string'},story:{type:'string'},choices:{type:'array',minItems:3,maxItems:3,items:choiceSchema}}};
const schema={type:'object',additionalProperties:false,required:['events'],properties:{events:{type:'array',minItems:2,maxItems:2,items:eventSchema}}};
save('requests/action-scenes-text-95.json',{review:false,schema,system:'한국어 사건 집필자. 주어진 기존 사건·인물 역할과 확정된 행동/보상은 바꾸지 않는다. 제목만 붙인 보상 메뉴가 아니라 장면의 남은 문제, 대사 주체, 내가 맡을 일을 담는다. 인물의 미소·끄덕임을 반복하지 않는다. 출력은 요청 JSON뿐이다.',brief:{task:'확정 수치·지정 카드·조건을 유지하고 두 사건의 제목·짧은 도입·본문·세 행동과 성공 결과를 자연스럽게 다듬어라.',events,cards:before['04-academy.json'].data.cards.filter(c=>events.some(e=>e.choices.some(b=>b.card===c.key))).concat(card),rules:['무료는 실제 사냥 시간이나 NPC 능력을 멈추는 원작 설정이 아니라 사건 방문 AP비용0이다.','행동력 최대치+1은 처음 얻을 때 현재AP도1지급. 카드 보유자는 이 사건에서 이전 보유 카드를 다시 받지 않는다.','label은 할 행동, result는 완료한 행동과 남은 문제다. NPC 동행·자동 사냥·새 아이템·완전한 갈등 해결을 구현한다고 쓰지 않는다.','보유조건은 개인 기록이다. 다른 사람의 기록으로 열리지 않는다.','사건에 등장하지 않은 인물이 선택지에 있다면 장면부터 보완하라.']}});
console.log(JSON.stringify({archived:files,newCards:1,newEvents:2,freeExisting:5}));
