// 호접저의 선배 호칭·훈련 복귀·네즈코를 향한 시선을 세 독립 사건으로 집필한다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'..');
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const prev=JSON.parse(fs.readFileSync(path.join(root,'requests/butterfly-pitches-33.json'),'utf8'));
const pitches=JSON.parse(fs.readFileSync(path.join(root,'drafts/butterfly-pitches-33.json'),'utf8')).parsed.pitches;
const accepted=new Set(['kny_respect_clash','kny_training_ego','kny_nezuko_fear']);
write('revisions/butterfly-pitches-selection-33.json',{source:'drafts/butterfly-pitches-33.json',items:pitches.map(p=>({...p,decision:accepted.has(p.key)?'재설계 후 집필':'폐기',reason:accepted.has(p.key)?'선배라는 호칭·복귀 동기·네즈코를 두려워하는 방문객의 서로 다른 문제를 쓴다. 선택을 예의 지도만으로 끝내지 않고 지속 성장과 필드 부담에 연결한다.':'미소 뒤 거절은 부탁이 구체적이지 않다. 호의·예법·감사는 이노스케를 무례함의 대상으로만 반복하고 호흡 리듬은 기존 훈련 지도와 중복한다.',revisit:accepted.has(p.key)?'네즈코의 장면은 해가 진 저택의 방문으로 한정하고 공격 시험이나 통제는 하지 않는다.':'구체적인 인물의 요구와 사건의 변화, 기존 사건과 다른 선택을 마련한 경우 새 초안으로 검토한다.'}))});
const f=(stat,value)=>({stat,value}),none={kind:0,goal:0,effects:[]};
const c=(key,name,effectName,keyword,effects,canonFact,evolution=none)=>({key,name,effectName,keyword,grade:2,effects,evolution,canonFact,uncertain:[]});
const cards=[
 c('kny_murata_senior','무라타','강함과 다른 선배의 몫','최대 체력 · 피해 감소',[f('max_health_percent',10),f('damage_reduction',3)],'공식 소개의 선배 귀살대원이라는 역할을 힘을 과시하지 않고 자기 몫을 버티는 성장으로 각색한다. 물의 호흡·선배 보너스·동행은 지급하지 않는다.'),
 c('kny_tanjiro_return','카마도 탄지로','돌아오게 하는 꾸준함','행동 속도 · 보스',[f('action_speed',4),f('boss_damage_percent',8)],'공식 25화에서 탄지로의 꾸준함을 보고 동료들이 훈련에 복귀하는 모습을 동작을 이어 가며 큰 상대를 준비하는 성장으로 각색한다. 카나오를 가르치거나 원작의 호흡 기술을 지급하지 않는다.',{kind:2,goal:12000,effects:[f('final_damage_percent',2)]}),
 c('kny_nezuko_will','카마도 네즈코','겁내는 이의 앞에서','재생 · 고체력',[f('regeneration',0.5),f('healthy_damage',8)],'네즈코가 자기 의지와 암시로 사람을 해치지 않는 특징을 동요 속에서 좋은 상태를 유지하는 성장으로 각색한다. 귀화·암시·즉시 치료·공격 통제·혈귀술은 없다.')
];
const b=(action,card=null,cost=0,level=0,density=0,gold=0,potions=0,chance=100)=>({action,card,card2:null,cost,level,density,gold,potions,chance});
const events=[
 {key:'kny_senior_challenge',title:'선배라면 더 강한가',scene:'저택을 찾은 무라타를 선배라고 소개하자 이노스케가 자기보다 강한지부터 묻는다. 탄지로는 먼저 인사하자고 하지만 이노스케는 선배라는 말이 승부를 피할 이유는 되지 않는다고 한다. 무라타는 사람을 오래 지켜 온 것과 싸움에서 이기는 것을 같은 말로 묶지 말라며 네가 어떤 준비를 택할지 묻는다.',choices:[b('무라타에게 버틸 몫을 묻고 준비 물품을 마련한다','kny_murata_senior',180),b('이노스케의 승부를 대신 맡고 더 강한 사냥을 준비한다','kny_inosuke',0,1),b('승부를 벌이지 않고 맡을 구역을 줄인다',null,0,-1,0,0,1)],canonFact:'물의 호흡을 쓰는 선배 귀살대원과 호전적인 이노스케라는 공식 소개에서 방문 중 호칭 갈등을 창작했다. 무라타의 이 발언은 원작 대사가 아니다. 실제 NPC 대련·선후배 게이지·호흡 전수가 없고 카드와 개인 필드만 변한다.'},
 {key:'kny_return_to_training',title:'문 안에 먼저 들어갈 사람',scene:'쉬지 않는 탄지로를 보고 돌아온 젠이츠와 이노스케가 훈련장 문 앞에서 서로 먼저 들어가라며 버틴다. 젠이츠는 보는 사람이 있는지 살피고 이노스케는 탄지로보다 먼저 시작한 것처럼 들어가겠다고 한다. 탄지로는 이미 같은 동작을 한 번 더 반복하고 있으니 네가 둘을 부를 말부터 정해야 한다.',choices:[b('탄지로와 반복할 자리를 마련해 두 사람을 부른다','kny_tanjiro_return',160),b('이노스케에게 먼저 도전하라며 맡을 길목을 넓힌다','kny_inosuke',0,0,1),b('젠이츠에게 반응을 보여 줄 자리를 맡긴다','kny_zenitsu',200)],canonFact:'24화의 젠이츠 동기와 25화의 탄지로를 보고 훈련에 복귀한 두 동료를 바탕으로 문 앞의 자존심 충돌을 창작했다. 플레이어가 카나오의 스승이 되거나 본편 대련 결과·연애 성취를 결정하지 않는다.'},
 {key:'kny_frightened_visitor',title:'물러선 발과 움직이지 않은 손',scene:'해가 진 뒤 저택을 찾은 방문객이 네즈코를 보고 뒤로 물러난다. 네즈코는 손을 뻗지 않고 가만히 있고 탄지로는 동생을 몰아세우지 않으면서도 손님의 놀람을 가볍게 넘기고 싶지 않다. 네가 양쪽의 거리를 지켜 이야기를 들을지 탄지로와 다른 자리를 안내할지 정한다.',choices:[b('두 사람 사이를 비워 두고 네즈코의 행동을 지켜본다','kny_nezuko_will'),b('탄지로와 손님이 머무를 자리를 마련한다','kny_tanjiro',180),b('방문객을 안내하고 맡을 바깥 길목을 줄인다',null,0,0,-1,100)],canonFact:'네즈코의 자기 의지와 암시·탄지로의 따뜻함이라는 공식 특징을 저택의 야간 방문에 각색했다. 사람을 공격하는 시험·암시 재주입·새 치료·원작 재판 결과·NPC 동행은 없다. 무료 카드도 사건 행동력 1을 소모한다.'}
];
const learning={kny_murata_senior:'최대 체력을 늘리고 받는 피해를 줄이는 요령',kny_inosuke:'작은 상대와 방향 조건 없는 일격에 힘을 싣는 대신 받는 피해가 늘어나는 성장',kny_tanjiro_return:'동작을 빠르게 이어 가고 큰 상대에게 힘을 싣는 요령',kny_zenitsu:'차지 일격과 치명타에 힘을 모으는 요령',kny_nezuko_will:'몸 상태를 천천히 유지하고 좋은 상태에서 일격에 힘을 싣는 요령',kny_tanjiro:'신속과 좋은 몸 상태에서 힘을 쓰는 요령'};
const schema=JSON.parse(fs.readFileSync(path.join(root,'requests/magnolia-expansion-text-28.json'),'utf8')).schema;
schema.properties.events.minItems=3;schema.properties.events.maxItems=3;
const request={review:false,schema,system:'한국어 사건 작가다. story3문장·intro1문장·각 result2~3문장. key와 선택 순서를 유지한다. expectedSuccess의 비용·카드 배움·골드·물약·적 강함과 수를 빠짐없이 구분하고 마지막 문장은 인물의 반응을 쓴다. 숫자는 맵 규칙이며 원작 대사를 인용하지 않는다.',brief:{sourceFacts:prev.brief.sourceFacts,events:events.map(e=>({key:e.key,scene:e.scene,choices:e.choices.map(b=>({action:b.action,expectedSuccess:{paidGold:b.cost,learned:b.card?learning[b.card]:null,receivedGold:b.gold,receivedPotions:b.potions,personalEnemyStrengthChange:b.level,personalEnemyCountChange:b.density}}))})),rules:['모두성공100%. 사건하나에행동력1. 무료네즈코카드도행동력을쓴다. 물약은소비가아닌획득. 0과null인추가효과를지어내지않는다.','현재체력지불·즉시치유·암시시험·강제치료·실신·새호흡·귀화·NPC동행·실제대련없음. 이노스케 카드의지속피해감소-4는카드부담이지현재체력소모가아니다.','25화의훈련성장주체는탄지로다. 카나오를가르치지않는다. 무라타는선배귀살대원이며방문중발언은창작.','네즈코장면은해가진뒤저택방문. 놀란사람에게공격시험하지않고사람을해치지않는네즈코의의지를존중한다.','모든선택을골드지불vs유료카드로만만들지않는다. 무료관찰배움·자원준비·필드부담·필드완화라는지정행동을유지한다.']}};
write('requests/butterfly-expansion-fixed-36.json',{cards,events,sourceFacts:prev.brief.sourceFacts});
write('requests/butterfly-expansion-text-36.json',request);
console.log(JSON.stringify({cards:3,events:3}));
