// 액셀 피칭의 체력 비용·원작 결말 변경·반복을 걸러 고정 수치와 집필 요청을 보존한다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const pitches=read('drafts/axel-pitches-48.json').parsed.pitches;
const reasons=[
 '우리의 목적을 오해하는 구경꾼만 유지한다. 다음 정화 지점으로 이동하는 선택은 끌어올리기도 전에 끝나며, 위협과 논리적 설명의 태도 비교보다 실제 줄을 잡는 문제를 넣는다.',
 '달아나는 눈의 정령을 추격할수록 멀어진다는 발단을 유지한다. 현재 체력이 깎이는 추위와 휴식 즉시 회복은 폐기하고 발자국·돌아올 길·사냥 준비의 부담으로 다시 쓴다.',
 '카즈마의 무기를 빼앗는 선택은 원작의 겨울 장군 장면과 사망 원인을 플레이어가 바꾼다. 새 실제 대치·장비 제거가 없는 작은 사건으로 바꾸기 어려워 이번 묶음에서 폐기한다.',
 '카즈마의 배움과 아쿠아의 방해라는 발단만 유지한다. 두 사람의 우선순위를 대신 결정하지 않고 여행자가 질문을 듣거나 직접 밖의 보급을 맡는 행동으로 다시 쓴다.',
 '제령 의뢰를 받은 저택 문턱만 유지한다. NPC에게 신성한 힘을 쓰거나 뒤로 물러나라고 명령하지 않고 자신이 잡을 문·의뢰 확인·바깥의 발자국을 선택한다.',
 '기존 axel_crowded_road의 다크니스·몬스터 집중·공격 경로 상황과 거의 같다. 새 사건으로 쓰지 않는다.',
 '기존 axel_party_water의 아쿠아·물 재주·카즈마·젖는 짐·루나를 반복하고 그것을 7화 공식 사실로 잘못 적었다. 새 사건으로 쓰지 않는다.',
 '기존 axel_rival_target의 융융·메구밍·작은/큰 표적 분리를 그대로 반복한다. 새 사건으로 쓰지 않는다.'
];
write('revisions/axel-pitches-selection-48.json',{source:'drafts/axel-pitches-48.json',items:pitches.map((p,i)=>({...p,decision:[0,1,3,4].includes(i)?'소재만 남겨 플레이어 행동으로 재설계':'폐기',reason:reasons[i],revisit:'현재 체력 비용과 원작 결말 개입을 없애고 기존 사건과 다른 현장 문제·플레이어 행동·결과를 만들 때 새 원안으로 검토한다.'}))});
const f=(stat,value)=>({stat,value}),none={kind:0,goal:0,effects:[]};
const card=(key,name,effectName,keyword,effects,canonFact,evolution=none)=>({key,name,effectName,keyword,grade:2,effects,evolution,canonFact,uncertain:[]});
const cards=[
 card('axel_aqua_rope','아쿠아','끌어올릴 때까지 놓지 않기','최대 체력 · 피해 감소',[f('max_health_percent',10),f('damage_reduction',6)],'공식 호수 정화의 우리와 노출된 아쿠아를 바탕으로 줄을 잡는 여행자의 지속 생존 여유를 각색한다. 아쿠아의 새 방어 주문·보호막·실제 수중 전투는 주지 않는다.'),
 card('axel_kazuma_snow','사토 카즈마','먼 발자국을 따라갈 때','이동 · 일반 적',[f('move_speed',5),f('normal_damage_percent',12)],'눈의 정령 토벌에서 쉬운 의뢰를 더 쫓으려는 상황의 발걸음을 각색했다. 정령의 골드·겨울 장군 토벌·냉기 기술을 지급하지 않는다.',{kind:1,goal:40,effects:[f('boss_damage_percent',5)]}),
 card('axel_wiz_question','위즈','질문이 끝나는 순간','차지 속도 · 비방향',[f('charge_speed',8),f('nondirectional_damage',10)],'위즈에게 유용한 기술을 배우려는 공식 상황에서, 질문과 시범의 준비가 끝나기를 기다리는 기억을 각색한다. 특정 주문이나 드레인 터치 전수를 공식 사실로 추가하지 않는다.'),
 card('axel_aqua_threshold','아쿠아','의뢰받은 문부터','일반 적 · 재생',[f('normal_damage_percent',14),f('regeneration',0.3)],'제령 의뢰를 수행하는 아크 프리스트의 일을 끝까지 확인하는 기억으로 각색한다. 새 제령 주문·유령 정체·성불 규칙을 지어내지 않으며 실제 사냥의 재생은 물약과 구분한다.'),
 card('axel_kazuma_release','사토 카즈마','손을 떼는 순서','이동 · 차지 속도',[f('move_speed',4),f('charge_speed',12)],'우리에서 사람을 끌어올리는 다음 준비를 기다리는 창작 후속의 기억이다. 호수 정화의 원작 방법을 새 발명으로 바꾸거나 실제 도르래·무기·카즈마 기술을 지급하지 않는다.')
];
const b=(action,card=null,cost=0,level=0,density=0,gold=0,potions=0,chance=100)=>({action,card,card2:null,cost,level,density,gold,potions,chance});
const events=[
 {key:'axel_cage_from_shore',title:'버린 것이 아니라 줄을 잡은 것',scene:'호숫가에서 아쿠아가 든 우리를 보던 구경꾼이 사람을 버리는 것 아니냐며 네 앞을 막는다. 카즈마는 정화 의뢰라고 해명하는 동안 줄을 잡아 줄 손을 찾고, 우리 안의 아쿠아는 해명보다 끌어올리는 때를 놓치지 말라고 외친다. 너는 구경꾼과 줄 사이에서 지금 자기 손을 어디에 쓸지 정한다.',choices:[b('180골드로 줄 고정용품을 마련하고 끌어올릴 때까지 잡는다','axel_aqua_rope',180),b('정화 의뢰의 목적을 설명하고 더 많은 개인 사냥을 맡는다','axel_aqua_threshold',0,0,1),b('물가의 짐을 운반하고 보급품을 받는다',null,0,0,0,100,1)],canonFact:'5화의 우리와 정화 의뢰는 공식 소개의 사실이고 구경꾼·줄 고정용품·여행자의 일은 별도 창작이다. 우리 안의 아쿠아를 버리거나 새로운 정화 지점을 완료했다고 하지 않는다.'},
 {key:'axel_snow_footprints',title:'작은 발자국이 멀어질 때',scene:'눈의 정령을 쫓던 카즈마가 저쪽에도 더 있다며 손가락을 뻗는다. 뒤돌아보니 네가 남긴 발자국은 겹쳐 있어 어디서 내려왔는지 바로 보이지 않고, 아쿠아는 쉬운 의뢰라도 돌아갈 길을 놓치지 말라고 말한다. 너는 더 멀리 쫓을 발걸음과 지금 확보할 보급 중 자기 몫을 정한다.',choices:[b('180골드로 길 표시 용품을 마련하고 발자국 사이를 따라간다','axel_kazuma_snow',180),b('더 많은 개인 사냥을 맡으며 추격의 발걸음을 기억한다','axel_kazuma_snow',0,0,2),b('돌아올 짐만 운반하고 보급품을 받는다',null,0,0,0,140,1)],canonFact:'7화의 달아나는 정령과 토벌 상황에서 길을 잃기 쉬운 여행자의 일을 창작했다. 현재 체력 냉기 피해·실제 정령 몹·겨울 장군 전투·카즈마의 죽음과 부활 변경은 없다.'},
 {key:'axel_question_cut_short',title:'질문이 끝나기 전에',scene:'위즈가 카즈마의 질문에 답하려는데 아쿠아가 제령 의뢰가 왔다며 말을 끊는다. 카즈마는 아직 질문이 끝나지 않았다고 하고 위즈는 답하던 손을 멈춘 채 너도 무엇을 물으러 왔는지 묻는다. 너는 남은 시범을 듣거나 밖의 준비를 맡을 수 있지만 두 사람이 어디로 갈지 대신 정할 수는 없다.',choices:[b('200골드로 시범 소모품을 마련하고 내 질문을 먼저 마친다','axel_wiz_question',200),b('더 강한 개인 사냥을 맡고 위즈의 남은 설명을 듣는다','axel_wiz_question',0,1),b('밖에서 보급품을 운반한 보수를 받는다',null,0,0,0,150,1)],canonFact:'8화의 배움을 방해하는 아쿠아·가르치려는 위즈·제령 의뢰의 등장에서 별도 방문을 창작했다. 플레이어에게 원작 주문·드레인 터치·마력 회복·새 기술을 전수하지 않는다.'},
 {key:'axel_house_threshold',title:'의뢰를 받은 문은 어디지?',scene:'제령 의뢰의 저택 앞에서 아쿠아가 기운이 난다는 창문을 가리키자 카즈마는 먼저 의뢰인을 만나야 하지 않냐고 묻는다. 위즈는 두 사람이 서로 다른 문턱에 서 있는 동안에도 의뢰받은 집인지 다시 확인하고 있다. 너는 아직 열리지 않은 문과 바깥에 남은 발자국 사이에서 자기 일을 고른다.',choices:[b('170골드로 의뢰 안내를 대조하고 열릴 문을 기다린다','axel_aqua_threshold',170),b('더 강한 개인 사냥을 맡으며 위즈와 바깥 흔적을 살핀다','axel_wiz_question',0,1),b('가져온 보급품을 전달하고 보수를 받는다',null,0,0,0,120,2)],canonFact:'8화의 저택 제령 의뢰를 바탕으로, 먼저 확인할 문이 다르다는 작은 문제를 창작했다. 안의 유령 신원·기운의 실체·성불 방법·아쿠아의 새 능력을 확정하지 않고 위즈에게 남의 명령을 따르게 하지 않는다.'},
 {key:'axel_rope_after_return',title:'끌어올린 뒤에도 잡힌 줄',previous:'axel_cage_from_shore',previousChoice:1,scene:'줄을 붙들었던 네 앞에 우리를 올려놓을 자리가 마련되었는데도 구경꾼이 이제 놓아도 되냐고 묻는다. 카즈마는 먼저 발 디딜 자리를 보자고 하고 아쿠아는 밖에 나와도 다시 물속에 넣지 말라며 손을 뻗는다. 너는 손을 떼기 전의 짧은 준비와 돌아올 보급 중 무엇을 맡을지 정한다.',choices:[b('150골드로 내려놓을 받침을 마련하고 손을 뗄 때를 맞춘다','axel_kazuma_release',150,0,0,0,0,75),b('더 많은 개인 사냥을 맡고 줄과 발 디딜 자리를 직접 살핀다','axel_kazuma_release',0,0,1),b('물가의 짐을 반환하고 보수를 받는다',null,0,0,0,160,1)],failure:'150골드를 내고 받침을 준비했지만 내려놓는 때를 맞추지 못했다. 기다리던 손은 아직 줄을 잡고 있고 카드와 보급 보수는 얻지 못했다.',canonFact:'줄 고정용품을 마련한 자신의 성공한 1번 선택에서만 열리는 창작 후속이다. 우리를 끌어올렸다는 앞선 행동의 연속이며 호수의 모든 정화·원작 이후 사건·실제 장비를 해결하거나 지급하지 않는다.'}
];
const sourceFacts=read('requests/axel-pitches-48.json').brief.sourceFacts;
const schema=read('requests/magnolia-expansion-text-28.json').schema;schema.properties.events.minItems=events.length;schema.properties.events.maxItems=events.length;
const learning=Object.fromEntries(cards.map(c=>[c.key,c.effects.map(e=>({max_health_percent:'최대 체력 증가',damage_reduction:'받는 피해 감소',move_speed:'이동속도 증가',normal_damage_percent:'일반 몬스터 피해 증가',charge_speed:'차지 준비 속도 증가',nondirectional_damage:'비방향 공격 피해 증가',regeneration:'초당 최대 체력 재생'})[e.stat]+' '+e.value).join(' / ')]));
const expected=c=>Object.fromEntries(Object.entries({paidGold:c.cost,rememberedCard:c.card?learning[c.card]:null,receivedGold:c.gold,receivedPotions:c.potions,personalEnemyStrengthChange:c.level,personalEnemyCountChange:c.density}).filter(([,v])=>v!==0&&v!==null));
write('requests/axel-expansion-fixed-49.json',{cards,events,sourceFacts});
write('requests/axel-expansion-text-49.json',{review:false,schema,system:'한국어 사건 작가다. story는 선택 전 3문장, intro는 남은 문제 1문장, result는 성공한 행동·정확한 성장과 숫자 보수·NPC에게 남은 반응 2~3문장이다. key와 분기 순서를 유지한다. 플레이어가 자기 일을 하는 구조와 고정안의 상황을 유지한다. 빈 칭찬과 도덕적 평가로 결과를 채우지 않는다.',brief:{sourceFacts,events:events.map(e=>({key:e.key,scene:e.scene,previous:e.previous||null,previousChoice:e.previousChoice||0,choices:e.choices.map(c=>({action:c.action,chance:c.chance,expectedSuccess:expected(c)}))})),rules:[
 '수치 보수·비용·물약·지속 개인 사냥 단계/수·카드 효과를 빠뜨리지 않는다. 카드의 태도는 성장 기억이고 주문·액티브 기술·실제 위즈 시범 기능·의뢰 게시판·수중 유닛을 구현하는 것이 아니다.',
 '현재 체력 비용·추위 피해·쉬기만 해서 즉시 치료·새 주문·겨울 장군 소환·NPC 동행·카즈마 사망과 부활 변경은 없다. 최대 체력 성장과 지속 재생은 현재 체력 회복이나 물약 지급과 다르다.',
 '다음 정화 지점이나 저택 전체 제령을 완료했다는 결말은 없다. 구경꾼을 겁주거나 아쿠아/카즈마/위즈에게 행동·위치를 명령하지 않는다. 서로 다른 시점의 창작 방문이다.',
 '75% 분기의 result는 성공했을 때만 쓴다. 실패는 별도 문장이다. 후속은 자기 앞선 성공1번만 요구하며 실제 물가 방문 기능은 없다.',
 '0/null 값을 새로운 보수나 효과로 바꾸지 않는다. 새 강함/수를 택한 원정의 개인 사냥 준비 조건은 계속 유지된다. 이야기 속 정령·유령·구경꾼이 실제 사냥 몬스터가 되는 것이 아니다.'
]}});
console.log(JSON.stringify({cards:cards.length,roots:4,followups:1,discardedPitches:4}));
