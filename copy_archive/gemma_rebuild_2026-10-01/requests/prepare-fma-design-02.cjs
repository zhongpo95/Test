// 확인된 연금술사 인물과 수련·정비·기록 소재를 실행 가능한 사건 초안으로 묶는다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const fx=(stat,value)=>({stat,value});
const card=(key,name,effectName,keyword,grade,effects,canonFact,evolution={kind:0,goal:0,effects:[]})=>({key,name,effectName,keyword,grade,effects,evolution,canonFact,uncertain:[]});
const branch=(label,result,card=null,{cost=0,gold=0,level=0,density=0,potions=0}={})=>({label,result,card,card2:null,cost,gold,level,density,potions,chance:100});
const scene=(key,title,story,intro,choices,previous=null,previousChoice=0)=>({key,title,story,intro,previous,previousChoice,requiredCard:null,choices,failure:null,canonFact:'공식 인물의 역할과 수련·정비·기록 소재를 바탕으로 한 맵 전용 만남이다. 본편 사건의 재현이나 결말 해결이 아니다.',uncertain:[]});
const cards=[
 card('fma_winry','윈리 록벨','떠나기 전의 점검','신속',1,[fx('swift',3)],'오토메일 정비사의 준비 습관을 입문 효과로 각색한다. 플레이어에게 오토메일이나 영구 장비 강화를 지급하지 않는다.'),
 card('fma_edward','에드워드 엘릭','이해하고 부수고 다시 잇기','공격 · 관통',2,[fx('attack_percent',10),fx('penetration',8)],'재료의 구조를 이해하고 재구축하는 연금술과 체술을 약점을 짚는 공격 준비로 각색한다. 연금술 기술을 새로 지급하지 않는다.',{kind:2,goal:8000,effects:[fx('penetration',4)]}),
 card('fma_alphonse','알폰스 엘릭','먼저 무너지지 않는 자세','생존',1,[fx('max_health_percent',10),fx('damage_reduction',2)],'침착한 성향과 체술을 바탕으로 방어 자세를 익힌다. 플레이어의 영혼을 갑옷으로 옮기거나 알폰스에게 음식·물약을 먹이지 않는다.'),
 card('fma_winry_precision','윈리 록벨','작은 어긋남까지','행동 · 차지 속도',2,[fx('action_speed',6),fx('charge_speed',8)],'정밀한 정비와 움직임 확인을 준비 동작의 효율로 각색한다. 무기 공격력이나 영구 무기 공격력 배율을 바꾸지 않는다.'),
 card('fma_sheska','셰스카','한 권도 빠뜨리지 않는 기억','탐색',2,[fx('event_choices',1)],'읽은 책을 정확히 기억하는 능력을 더 많은 사건 후보를 비교하는 성장으로 각색한다. 읽지 않은 책이나 미래를 아는 능력이 아니다.'),
 card('fma_armstrong','알렉스 루이 암스트롱','체술과 조형의 호흡','생존 · 차지 피해',2,[fx('max_health_percent',12),fx('charge_damage',18)],'체술과 조형을 결합하는 전투를 단단한 준비 자세와 힘을 싣는 공격으로 각색한다. 원작의 조형 기술을 새로 지급하지 않는다.'),
 card('fma_izumi','이즈미 커티스','도망치지 않는 한 걸음','공격 · 고체력',3,[fx('attack_percent',16),fx('healthy_damage',16)],'엄격한 생존 수련과 체술을 공격 전에 자세와 몸 상태를 지키는 성장으로 각색한다. 내장 손실·인체 연성을 대가로 요구하지 않는다.',{kind:3,goal:60,effects:[fx('final_damage_percent',4)]}),
 card('fma_izumi_flow','이즈미 커티스','혼자서도 흐름 속에서','신속 · 이동 피해',2,[fx('swift',5),fx('moving_damage',12)],'주변과 자신의 연결을 살피는 수련을 움직이며 다음 동작을 준비하는 성장으로 각색한다. 원작 수련의 정답을 고르는 퀴즈가 아니다.')
];
const events=[
 scene('fma_workshop','떠나려는 손, 붙잡는 손','에드워드가 정비를 마친 팔을 움직이자 윈리가 손목에서 나는 작은 소리에 귀를 기울인다. 에드는 밖에서 시험하면 금방 알 수 있다고 하고, 알폰스는 우선 넘어지지 않을 자세부터 보자고 한다. 누구의 확인을 도울지 정한다.','정밀 점검, 강한 적을 상대로 한 시험, 방어 자세 중 고른다.',[
  branch('정밀 공구를 빌려 윈리의 점검을 돕는다','헛도는 부분을 찾아 조이고 다시 움직여 본다. 윈리는 힘을 더 주기 전에 작은 어긋남부터 확인하는 순서를 보여 준다.','fma_winry_precision',{cost:200}),
  branch('에드워드와 더 강한 적이 있는 구역을 시험한다','에드가 단단한 상대를 무너뜨릴 때 어디를 먼저 보는지 짚어 준다. 시험을 마친 뒤에도 네가 맡은 사냥 구역의 적은 전보다 강하다.','fma_edward',{level:1}),
  branch('알폰스와 막고 물러서는 자세를 익힌다','알폰스가 발을 놓을 위치를 바꿔 가며 같은 자세를 되풀이한다. 세게 버티는 것보다 무너지지 않은 채 물러나는 법이 먼저 손에 익는다.','fma_alphonse')
 ]),
 scene('fma_measurement_notes','빈칸이 남은 정비 기록','함께 점검했던 손목은 이제 부드럽게 움직인다. 윈리가 기록지를 접다가 낡은 정비서의 치수가 번진 부분을 발견한다. 그 책을 읽었다는 셰스카의 도움을 받을지, 에드와 실제 움직임을 더 확인할지 정한다.','정확한 기록, 실전 확인, 끝낸 작업의 정산으로 나뉜다.',[
  branch('종이와 제본비를 마련해 셰스카의 기억을 기록한다','셰스카가 기억하는 페이지를 읽어 주고, 윈리가 실제 치수와 대조한다. 흐릿한 원본을 억지로 짐작하는 대신 확인한 내용만 남긴다.','fma_sheska',{cost:180}),
  branch('에드워드와 강한 상대를 기준으로 다시 시험한다','도면에 적힌 수치와 실제로 힘이 걸리는 자리를 비교한다. 시험에 택한 강한 적 구역은 앞으로도 네가 맡는다.','fma_edward',{level:1}),
  branch('확인한 부분까지 기록하고 보수를 정산한다','읽지 못한 치수는 빈칸으로 남겨 윈리에게 돌려준다. 완료한 점검의 보수를 받고 이번 일은 여기서 마친다.',null,{gold:140})
 ],'fma_workshop',1),
 scene('fma_trial_footprints','버틴 자리와 밀린 자리','강한 적을 상대로 한 시험이 끝나자 에드워드가 땅에 남은 발자국을 내려다본다. 공격은 닿았지만 너는 생각보다 멀리 밀려났다. 알폰스는 뒤로 빠질 자리를, 함께 시험을 지켜본 암스트롱은 힘을 모으는 자세를 짚는다.','강한 구역을 좁히거나, 더 많은 적 사이에서 힘을 싣는 연습을 한다.',[
  branch('정리 비용을 내고 알폰스와 강한 구역을 줄인다','주변 정리를 맡길 비용을 내고 무리한 시험 구역 한 곳을 뺀다. 알폰스와 발을 놓는 위치를 다시 익히며 남은 구역으로 돌아간다.','fma_alphonse',{cost:160,level:-1}),
  branch('암스트롱과 더 많은 적 사이에서 자세를 시험한다','암스트롱의 체술을 보며 힘을 모았다가 내딛는 순서를 익힌다. 앞선 강한 적 부담에 더해 이번에는 더 많은 적을 상대하게 된다.','fma_armstrong',{density:1}),
  branch('시험 기록을 넘기고 의뢰 보수를 받는다','밀린 자리까지 숨기지 않고 시험 기록에 남긴다. 의뢰 보수는 받지만 이미 맡은 강한 적 구역은 그대로 남아 있다.',null,{gold:160})
 ],'fma_workshop',2),
 scene('fma_library','사라진 페이지의 무게','셰스카가 물에 젖어 읽을 수 없게 된 기술서의 한 페이지를 막힘없이 적어 내려간다. 에드워드는 그 옆에서 글자를 베끼는 것과 구조를 이해하는 것은 다르다며 도면을 가리킨다. 책을 온전히 남길지, 당장 필요한 원리를 배울지 정한다.','기록을 통해 사건 후보를 넓히거나 재료의 구조를 배운다.',[
  branch('필사 비용을 마련하고 한 권 전체를 함께 정리한다','셰스카의 기억을 받아 적으며 관련된 내용을 찾아 비교하는 순서를 배운다. 그녀가 읽은 적 없는 뒷이야기까지 적혀 있는 책은 아니다.','fma_sheska',{cost:240}),
  branch('실습 재료를 사서 에드워드와 도면의 원리를 확인한다','같은 재료를 두고 모양과 힘이 걸리는 자리를 달리해 본다. 글의 표현을 외우는 대신 어느 부분을 먼저 이해해야 하는지 짚는다.','fma_edward',{cost:80}),
  branch('복원한 페이지의 제본을 맡아 일당을 받는다','순서를 맞춘 종이를 꿰매고 젖은 원본과 구분해 둔다. 셰스카가 다음 장을 읽을 수 있도록 책상을 정리한 뒤 일당을 받는다.',null,{gold:180})
 ]),
 scene('fma_training','손을 모으기 전에','이즈미는 사냥터의 발자국과 먹다 남은 열매를 가리키며, 강한 기술부터 찾는 너를 멈춰 세운다. 큰 적 한 마리와 맞서는 구역도, 작은 적이 여러 방향에서 다니는 구역도 있다. 알폰스는 기본 자세를 되풀이할 자리에서 기다린다.','적의 강함이나 수를 늘려 수련하거나 기본 자세부터 다진다.',[
  branch('큰 적이 있는 구역에서 자세를 지키며 수련한다','이즈미는 급하게 달려드는 발을 멈추고 몸이 준비된 순간에 내딛게 한다. 한 번의 수련이 끝나도 이 구역의 강한 적을 계속 상대해야 한다.','fma_izumi',{level:2}),
  branch('더 많은 적이 지나는 구역에서 암스트롱과 힘을 모은다','암스트롱의 체술을 따라 몸을 낮췄다가 힘을 실어 움직인다. 빈틈을 찾을 상대도, 놓치면 몰려올 적도 많아진다.','fma_armstrong',{density:2}),
  branch('알폰스와 기본 방어 자세부터 되풀이한다','주변을 읽지 못한 채 버티려던 습관을 알폰스가 하나씩 짚어 준다. 더 위험한 구역을 맡기 전에 발을 놓고 물러서는 기본을 익힌다.','fma_alphonse')
 ]),
 scene('fma_after_large','쓰러뜨린 뒤에 남은 것','큰 적을 넘긴 자리에서 이즈미가 네 등 뒤의 발자국을 가리킨다. 눈앞에 집중하는 동안 다른 적이 지나갈 길을 놓쳤다. 힘을 내는 법 다음에는 움직일 자리를 읽어야 한다.','추가 수련으로 움직임을 익히거나 강한 구역을 줄인다.',[
  branch('이즈미와 주변 흐름까지 살피며 수련을 넓힌다','상대가 쓰러진 다음에 어디로 움직일지도 함께 살핀다. 강한 적을 맡은 채 더 많은 적의 움직임까지 읽어야 하는 연습이 남는다.','fma_izumi_flow',{density:1}),
  branch('정리 비용을 내고 알폰스와 맡은 구역을 줄인다','강한 구역 일부를 정리하는 비용을 내고 알폰스와 안전하게 물러날 위치를 익힌다. 수련을 시작하며 늘어난 부담이 전부 사라진 것은 아니다.','fma_alphonse',{cost:240,level:-1})
 ],'fma_training',1),
 scene('fma_after_crowd','발을 디딜 한 뼘','여러 적 사이에서 힘을 모으던 연습이 끝나자 이즈미가 발밑을 보게 한다. 공격할 자리는 찾았지만 다음 발을 둘 공간을 자꾸 잃었다. 알폰스는 넓게 맡은 구역부터 줄여 보자고 한다.','사냥 구역을 일부 줄이면서 움직임이나 방어 자세를 정리한다.',[
  branch('정리 비용을 내고 이즈미와 다음 발을 놓을 곳을 익힌다','한쪽 구역의 정리를 맡기고 남은 적의 흐름을 살핀다. 공격하는 순간뿐 아니라 그 뒤 몸을 옮기는 순서가 손에 익는다.','fma_izumi_flow',{cost:280,density:-1}),
  branch('알폰스와 길을 정리하고 기본 자세로 돌아간다','무리하게 넓힌 구역 한 곳을 직접 정리하고 알폰스의 기본 자세를 되풀이한다. 남은 구역에는 수련 전보다 여전히 많은 적이 있다.','fma_alphonse',{density:-1})
 ],'fma_training',2)
];
const data={world:{key:'amestris',name:'아메스트리스',work:'강철의 연금술사 FULLMETAL ALCHEMIST',intro:'기차에서 내리자 정비 도구를 챙긴 윈리가 여행 준비를 살핀다. 연금술과 오토메일, 오래된 기록과 수련의 길을 따라갈 준비를 한다.',effects:[fx('penetration',2)],entryCard:'fma_winry',icon:'ReplaceableTextures\\CommandButtons\\BTNManual.blp'},sources:['https://www.hagaren.jp/fa/characters/index01.html','https://www.hagaren.jp/fa/about/introduction.html','https://www.hagaren.jp/about/story.html','https://www.hagaren.jp/fa/about/story01.html'],canonBoundary:'2009년 FULLMETAL ALCHEMIST의 인물 소개와 6·7·9·12화 줄거리에서 정비·기록 복원·수련 소재를 확인했다. 이 사건의 기술서·치수·의뢰·수련 구역·비용과 보상은 맵의 창작이며 본편 장면을 대신 해결하지 않는다. 인체 연성·현재 체력 지불·팀 라이프 소모·플레이어 오토메일·연금술 신규 기술·NPC 전투 능력·퀘스트 물품을 구현하지 않는다. 사냥터 부담은 사건 이후 남는 플레이어 개인 구역의 변화다. 시트는 풀 연결의 참고이며 원작 자료가 아니다.',cards,events};
const system='한국어 사건 편집자다. 주어진 사건의 story와 result를 더 자연스러운 짧은 장면으로 고쳐 쓴다. 숫자·보상·인물·선택의 행동·이전 선택 조건은 변경하지 않는다. 제작자 해설을 장면에 복사하지 않는다. 알폰스는 갑옷의 영혼, 윈리는 오토메일 정비사, 셰스카는 읽은 책을 정확히 기억하는 사람이다. 그녀가 번진 글자를 추측하거나 미래를 알지는 않는다. 모든 새 기술서와 만남은 맵 창작이다. 비용을 낸 사람과 보수를 받는 사람을 바꾸지 않는다. 적 단계·수가 늘거나 일부만 줄면 결과에서 모두 안전해졌다고 쓰지 않는다. NPC가 플레이어를 따라 사냥한다고 약속하지 않는다. 주어진 제목과 선택 문장을 그대로 복사해 결과로 제출하지 않는다. 설정이나 선택의 앞뒤에 실제 문제가 있으면 issues에 최대 세 개 지적한다.';
const item={type:'object',additionalProperties:false,required:['key','story','results'],properties:{key:{type:'string'},story:{type:'string'},results:{type:'array',items:{type:'string'}}}};
const request={review:true,system,schema:{type:'object',additionalProperties:false,required:['events','issues'],properties:{events:{type:'array',items:item},issues:{type:'array',items:{type:'object',additionalProperties:false,required:['key','reason'],properties:{key:{type:'string'},reason:{type:'string'}}}}}},brief:{canonBoundary:data.canonBoundary,events:events.map(e=>({key:e.key,title:e.title,story:e.story,previous:e.previous?{key:e.previous,choice:e.previousChoice,choiceResult:events.find(p=>p.key===e.previous).choices[e.previousChoice-1].result}:null,choices:e.choices.map(b=>({action:b.label,result:b.result,cost:b.cost,gold:b.gold,level:b.level,density:b.density,card:b.card?cards.find(c=>c.key===b.card).name:null}))}))}};
fs.writeFileSync(path.join(__dirname,'fma-design-02.json'),JSON.stringify(data,null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(__dirname,'fma-editor-02.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});
console.log('아메스트리스 8카드·7사건 검토 초안을 보존했습니다. 아직 활성 데이터가 아닙니다.');
