// 나비저택 피칭의 반복과 이름 오류를 보존하고 네 독립 사건과 자기 표주박 후속을 집필 요청한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const pitches=read('drafts/butterfly-pitches-72.json').parsed.pitches;assert.equal(pitches.length,6);
const reasons={
 kny_training_breath:'발단만 남긴다. 탄지로가 여행자의 존재를 미안해하고 여행자가 그의 호흡을 대신 결정하는 의존을 버린다. 인사 도중 자기 호흡을 잇는 탄지로 옆에서 여행자가 자기 연습/말의 차례를 정한다. 표주박은 아래 별도 사건으로 분리한다.',
 kny_inosuke_hide:'발단만 남긴다. 멧돼지 머리 사이로 촉각을 세운다는 부정확한 신체 표현과 소리로 촉각을 교란한다는 확정 결론을 버린다. 역할을 바꾸고 여행자가 보이지 않는 발판/움직임을 살피는 창작 승부다.',
 kny_kanae_reaction:'손을 늦게 거둔 문제와 속도/범위 선택은 남긴다. key의kanae는 카나오와 다른 인물 이름을 섞었으므로 새kny_hand_return으로 고친다. 특정 차 승부·카나오 감정 해방·원작 중요한 승패는 확정하지 않는다.',
 kny_zenitsu_motivation:'폐기한다. 의욕을 칭찬/웃음/조용히 지켜봄은 다른 행동과 문제를 만들지 못하고 기존 훈련 복귀 사건에 겹친다. 격려를 받으면 보상이 확정되는 메뉴 대신 젠이츠 특유의 청각과 자기 결정이 갈등을 만들 때 재검토한다.',
 kny_training_exhaust:'폐기한다. 격려/자극/휴식은 구체적인 물건이나 남을 문제 없이 기존 훈련 복귀를 반복한다. 원작 마음을 여행자 한 마디로 고치지 말고 다음 행동의 차이가 실제로 남는 상황이면 재검토한다.',
 kny_training_tools:'발단만 남긴다. 설명을 경청/도구 닦기 메뉴 대신 여행자가 큰 표주박을 먼저 골랐다가 아오이의 설명과 탄지로 연습을 듣는 문제로 구체화한다. 새 표주박 크기/시험/값은 창작이다.'
};
write('revisions/butterfly-pitches-selection-72.json',{raw:'drafts/butterfly-pitches-72.json',requestCount:6,schemaCount:6,orderIssue:'요청한 방향 순서를 지키지 않고 동전 대신 혹독한 훈련을 추가했으며 표주박을 마지막에 다시 제안했다. 인덱스가 아닌 실제key와내용으로 대조했다. 동전 유래/결정 장면은 미확인으로 채택하지 않는다.',items:pitches.map(p=>({...p,decision:['kny_zenitsu_motivation','kny_training_exhaust'].includes(p.key)?'폐기':'발단만 남겨 구체적인 행동으로 재작성',reason:reasons[p.key],revisit:'기존 사건과 다른 물건/현장 문제와 자기 행동을 만들고 공식 설정과 창작 경계를 유지하면 재검토한다.'}))});
const f=(stat,value)=>({stat,value}),none={kind:0,goal:0,effects:[]};
const card=(key,name,effectName,keyword,effects,canonFact,evolution=none)=>({key,name,effectName,keyword,grade:2,effects,evolution,canonFact,uncertain:[]});
const cards=[
 card('kny_gourd_breath','카마도 탄지로','크기보다 긴 한숨','차지 피해 · 행동 속도',[f('charge_damage',14),f('action_speed',3)],'표주박과 전집중 상중 훈련 관계에서 여행자의 힘을 급히 쓰지 않는 기억으로 각색한다. 실제 표주박 장비·호흡 스킬·차지속도·현재체력 소모를 주지 않는다.'),
 card('kny_morning_breath','카마도 탄지로','인사 다음에도 이어지는 숨','재생 · 고체력',[f('regeneration',0.4),f('healthy_damage',10)],'온종일 호흡을 유지하려는 훈련을 여행자의 계속 잇는 기억으로 각색한다. 초당 최대체력0.4%재생과 현재체력65%이상에서 가하는피해10%이며 즉시회복·원작 호흡완성·새 지속호흡 스킬은 없다.'),
 card('kny_kanao_return_hand','츠유리 카나오','다음 손을 거두는 때','행동 속도 · 방향',[f('action_speed',6),f('directional_damage',10)],'회복 훈련 상대 카나오와 여행자가 손을 다시 거두는 창작 기억이다. 일반 행동속도와 헤드/백 플래그가 있는 공격의 피해다. 실제 카운터/회피/차 승부/동전으로 마음을 해방하는 기능은 없다.',{kind:2,goal:8000,effects:[f('crit_chance',3)]}),
 card('kny_kanao_small_motion','츠유리 카나오','작게 움직여도 늦지 않게','치명타 확률 · 이동 속도',[f('crit_chance',6),f('move_speed',4)],'창작 손동작의 범위를 줄여 타이밍을 보는 기억이다. 치명확률6%p와 이동속도4%이며 모든 공격이 치명/회피가 되는 것이 아니다.'),
 card('kny_inosuke_partition','하시비라 이노스케','안 보인다고 없는 것은','방어 관통 · 비방향',[f('penetration',8),f('nondirectional_damage',12)],'촉각으로 시야 밖 위치도 아는 설정에서 가림막 역할을 바꿔 보는 창작 기억이다. 헤드/백 플래그 없는 공격 대미지12%와방관8%이며 실제투시·적감지·자동조준·새스킬을 주지 않는다.'),
 card('kny_gourd_second','카마도 탄지로','터뜨린 뒤에 남은 호흡','차지 속도 · 차지 피해',[f('charge_speed',9),f('charge_damage',10)],'자기 표주박 첫 도전 성공1번 뒤에만 남는 창작 훈련 기억이다. 차지 준비속도9%와차지태그공격피해10%이며 일반행동속도·실제표주박장비·탄지로원작성취완성은 없다.')
];
const b=(action,card=null,cost=0,level=0,density=0,gold=0,potions=0,chance=100)=>({action,card,card2:null,cost,level,density,gold,potions,chance});
const events=[
 {key:'kny_first_gourd',title:'큰 표주박을 고른 손',scene:'표주박을 보고 네가 먼저 큰 것을 집자 아오이가 아직 설명을 끝내지 않았다고 손을 멈춘다. 탄지로가 자기 도구에 숨을 잇는 동안 너는 크기가 곧 실력이라는 말을 삼킨다. 한 번에 도전할지 도구값을 충분히 내고 차근차근 연습할지 손을 내려놓을지 정한다.',choices:[b('도구값120골드를 먼저 내고 한 번에 표주박을 울려 본다','kny_gourd_breath',120,0,0,0,0,60),b('도구값220골드를 내고 탄지로의 박자를 따라 충분히 연습한다','kny_gourd_breath',220),b('표주박을 내려놓고 내 사냥의 적 수 단계를1낮춘 뒤 보급을 받는다',null,0,0,-1,0,1)],failure:'도구값120골드를 먼저 냈지만 숨이 끝나기 전에 박자가 끊겼다. 카드는 얻지 못하고120골드는 돌아오지 않는다. 아오이는 네가 큰 것을 다시 집기 전에 설명부터 끝까지 들으라고 한다.',canonFact:'공식 협업 자료의 표주박/전집중상중관계에서 만든 별도 창작 시험이다. 크기·소리·도구값·60%확률은 원작규칙이 아니고 현재체력지불이나 새미니게임은 없다.'},
 {key:'kny_morning_greeting',title:'아직 끝나지 않은 인사',scene:'탄지로에게 아침 인사를 하려는데 그가 대답하다가 자기 호흡의 박자를 다시 잇는다. 하루 종일 유지하려는 연습이라고 듣고 나니 네 다음 질문이 입끝에 남는다. 너는 옆에서 자기 숨의 박자를 맞출지 질문을 잠깐 미룰지 자기 일을 먼저 할지 정한다.',choices:[b('180골드로 내 연습 도구를 마련하고 옆에서 자기 숨을 잇는다','kny_morning_breath',180),b('내 사냥의 강함 단계를1올리고 탄지로 옆에서 끊긴 박자를 다시 잇는다','kny_morning_breath',0,1),b('질문을 미루고 내가 맡은 짧은 일을 마친다',null,0,0,0,100)],canonFact:'공식25화의 온종일 호흡유지연습을 별도 아침 인사로 각색했다. 실제아침대사·원작훈련완성·탄지로구출·새호흡스킬은 확정하지 않는다.'},
 {key:'kny_hand_return',title:'거두지 못한 마지막 손',scene:'카나오와 손동작으로 반응을 맞추던 네가 끝났다고 생각한 순간에도 손은 앞으로 남아 있다. 카나오는 다음 차례를 준비하고 아오이는 손을 거둘 때도 훈련이라고 말한다. 너는 같은 속도를 다시 따라갈지 동작을 줄여 볼지 오늘 차례를 마칠지 정한다.',choices:[b('200골드로 내 추가 연습 준비를 하고 같은 속도에 다시 맞춘다','kny_kanao_return_hand',200),b('내 사냥의 적 수 단계를1올리고 손동작을 작게 줄여 다시 본다','kny_kanao_small_motion',0,0,1),b('오늘 차례를 마치고 짧은 일의 보수와 보급을 챙긴다',null,0,0,0,100,1)],canonFact:'공식25화의 회복훈련상대카나오를 바탕으로 만든 손동작 연습이다. 원작 찻잔승부규칙/특정대사·동전유래·카나오마음의큰결말을 확정하지 않는다.'},
 {key:'kny_partition_role',title:'가림막 뒤의 네 차례',scene:'이노스케가 가림막 뒤로 옮겨 간 네 위치를 가리키고는 이제 네가 맞혀 보라고 한다. 눈앞의 막만 보던 네가 발을 움직이자 이노스케도 다른 쪽으로 발판을 바꾼다. 먼저 막을 걷을지 발판과 움직임을 더 살필지 승부를 접을지 정한다.',choices:[b('180골드로 내 연습 준비를 하고 발판의 변화를 살핀다','kny_inosuke_partition',180),b('내 사냥의 적 수 단계를1올리고 눈에 안 보이는 움직임을 다시 살핀다','kny_inosuke_partition',0,0,1),b('가림막 승부를 접고 내 사냥의 적 수 단계를1낮춘 뒤 보급을 챙긴다',null,0,0,-1,90,1)],canonFact:'공식 인물소개 이노스케의 호전성과 촉각에서 만든 별도 가림막놀이이다. 실제맵투시·감지·자동조준·이노스케동료소환은 없다.'},
 {key:'kny_after_first_gourd',title:'터진 소리 다음에는',previous:'kny_first_gourd',previousChoice:1,scene:'첫 표주박 도전이 끝난 뒤 네가 도구를 내려놓으려는데 탄지로는 아직 숨을 잇고 있다. 아오이가 터진 소리만 세면 다음 박자를 놓친다고 네 손을 본다. 한 번의 성공을 내세울지 다음 동작까지 이어 볼지 오늘은 여기서 마칠지 정한다.',choices:[b('140골드로 내 다음 연습 도구를 마련하고 터진 소리 뒤에도 숨을 잇는다','kny_gourd_second',140),b('내 사냥의 강함 단계를1올리고 탄지로가 다음 빈틈을 보는 감각을 기억한다','kny_tanjiro_smell',0,1),b('오늘 연습을 마치고 짧은 일의 보수와 보급을 챙긴다',null,0,0,0,100,2)],canonFact:'자기첫표주박도전성공1번 뒤에만열리는 창작후속이다. 다른플레이어성공/자기실패/자기2번으로열리지않으며 부모카드를반복보상하지않는다.'}
];
const learning={kny_gourd_breath:'차지 태그 공격피해14%,일반행동속도3%',kny_morning_breath:'초당최대체력0.4%재생,현재체력65%이상에서가하는피해10%',kny_kanao_return_hand:'일반행동속도6%,헤드/백플래그있는공격피해10%',kny_kanao_small_motion:'치명타확률6%p,이동속도4%',kny_inosuke_partition:'방어관통8%,헤드/백플래그없는공격피해12%',kny_gourd_second:'차지준비속도9%,차지태그공격피해10%',kny_tanjiro_smell:'헤드/백플래그있는공격피해14%,방어관통5%'};
const expected=c=>({paidGold:c.cost,rememberedCard:c.card,remembered:c.card?learning[c.card]:null,receivedGold:c.gold,receivedPotions:c.potions,personalEnemyStrengthChange:c.level,personalEnemyCountChange:c.density});
const schema=read('requests/academy-expansion-text-58.json').schema;schema.properties.events.minItems=schema.properties.events.maxItems=events.length;
const sourceFacts=read('requests/butterfly-pitches-72.json').brief.sourceFacts;
write('requests/butterfly-expansion-fixed-73.json',{sourceRevision:'233aa7c',cards,events,sourceFacts});
write('requests/butterfly-expansion-text-73.json',{review:false,schema,system:'한국어 사건 작가다. 주어진5개key와순서를지킨다. story는현장물건/행동과인물반응3문장,intro는남은문제1문장,result는성공한여행자의행동·실제대가/성장/보급·인물의다른작은반응2~3문장이다. 칭찬/끄덕임/내준비만반복하지않고원작성취를대신완료하지않는다.',brief:{sourceFacts,events:events.map(e=>({key:e.key,scene:e.scene,previous:e.previous||null,previousChoice:e.previousChoice||0,choices:e.choices.map(c=>({action:c.action,chance:c.chance,expectedSuccess:expected(c)}))})),rules:[
 '카드는여행자의기억이며NPC성장·호흡스킬·표주박장비·차미니게임·감지/투시/동행을실제로지급하지않는다. 사건중개인사냥정지,level/density는재개후개인필드지속변화량이고음수감소도가능하다.',
 '60%result는성공때만쓴다. 실패도AP1·120골드선지불은유지하고카드/즉시골드/물약은없다. 자기성공1번만후속으로이어지며확정2번·실패·다른플레이어기록은안된다.',
 'regeneration은초당최대체력%재생이며즉시회복아니다. 흡수/재생합산초당10%상한. healthy_damage는현재체력65%이상때가하는피해다.',
 'directional_damage는head또는back플래그공격피해,nondirectional_damage는둘다없는공격피해다. charge_damage는차지태그공격피해,charge_speed는차지준비속도,action_speed는일반행동속도,move_speed는이동속도다. 서로바꾸지않는다.',
 '카드수치/참조와골드/물약/필드변화를그대로쓴다. 성장주체는여행자이고원작인물의큰성취·치료·마음의결말을대신끝내지않는다.'
]}});console.log(JSON.stringify({cards:6,roots:4,followups:1,discardedPitches:2}));
