// 액셀 사건의 골드 대안과 같은 카드 반복을 세 가지 기억 카드 행동으로 나누고 Gemma 집필을 준비한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const file=path.join(repo,'content/roguelite/02-axel.json'),bytes=fs.readFileSync(file),before=JSON.parse(bytes);
fs.writeFileSync(path.join(root,'before-axel-card-choices-83.json'),bytes,{flag:'wx'});
const card=(key,name,effectName,keyword,pairs,canonFact)=>({key,name,effectName,keyword,grade:2,effects:pairs.map(([stat,value])=>({stat,value})),evolution:{kind:0,goal:0,effects:[]},canonFact,uncertain:[]});
const addedCards=[
 card('axel_chris_trace','크리스','흔적을 밟기 전에','이동 · 치명 피해',[['move_speed',4],['crit_damage',14]],'공식 도적 역할과 기존 수색 장면에서 지나간 흔적을 구분하는 여행자의 기억을 각색한다. 탐지 기술·자동 수색·크리스의 새 스킬을 지급하지 않는다.'),
 card('axel_kazuma_share','사토 카즈마','먼저 따져 볼 몫','공격력 · 치명 확률',[['attack_percent',12],['crit_chance',3]],'평범한 모험가이며 행운이 높다는 공식 소개와 기존 몫을 따지는 행동에서 별도 준비의 기억을 만든다. 새로운 원작 기술이나 자동 보수 수급은 없다.'),
 card('axel_aqua_supply','아쿠아','남겨 둔 비상분','최대 체력 · 재생',[['max_health_percent',10],['regeneration',0.3]],'공식 회복 담당·음식과 돌 취향을 기존 소모품 준비의 기억으로 각색한다. 새 물약 제작·즉시 체력 회복·부활·NPC 동행은 없다.'),
 card('axel_aqua_return','아쿠아','돌아갈 곳부터','재생 · 받는 피해',[['regeneration',0.4],['damage_reduction',4]],'공식 지원 역할과 기존 돌아올 길·물 밖의 자리를 확인하는 여행자의 기억이다. 귀환 기술·새 보호막·정화 주문·물약 즉시 사용은 없다.'),
 card('axel_luna_space','루나','창구 밖의 빈자리','사건 후보 · 받는 피해',[['event_choices',1],['damage_reduction',3]],'공식 접수와 안내 역할에서 부탁을 구분하고 지나갈 공간을 남기는 기억을 각색한다. 접수 시스템이나 추가 행동력을 지급하지 않는다.'),
 card('axel_yunyun_gap','융융','서로 다른 표적','차지 속도 · 치명 피해',[['charge_speed',7],['crit_damage',12]],'공식 상식적인 아크 위저드·메구밍의 라이벌 역할에서 기존 표적 간격을 나누는 기억을 각색한다. 새 마법·시전 자원·우정 게이지·NPC 훈련 성취를 지급하지 않는다.'),
 card('axel_darkness_position','다크니스','검보다 먼저 선 자리','방향 피해 · 받는 피해',[['directional_damage',12],['damage_reduction',5]],'공식 방어 역할에서 그녀 뒤에 공격할 공간을 남기는 여행자의 기억이다. 방향 피해는 플레이어 공격의 유효 방향 조건이며 다크니스의 검 명중·도발·적 강제 이동 기술을 새로 지급하지 않는다.'),
 card('axel_wiz_small','위즈','작은 실패부터 살피기','차지 속도 · 받는 피해',[['charge_speed',5],['damage_reduction',4]],'공식 마도구점 주인과 기존 감정·시범 준비에서 작은 실패를 먼저 확인하는 기억을 각색한다. 장비 수리·원작 주문·새 마도구를 지급하지 않는다.')
];
const events=structuredClone(before.events),changes=[];
function change(key,index,values){const e=events.find(e=>e.key===key),old=structuredClone(e.choices[index-1]);assert(old);e.choices[index-1]={...old,...values,gold:0,result:''};changes.push({key,index,before:old,after:structuredClone(e.choices[index-1])});}
change('axel_request',3,{card:'axel_luna_arrival',label:'150골드로 운송을 준비하고 루나와 의뢰를 나눠 맡는다'});
change('axel_stolen_notice',3,{card:'axel_chris_trace',label:'100골드로 수색을 준비하고 크리스와 지나간 흔적을 구분한다'});
events.find(e=>e.key==='axel_stolen_notice').choices.push({label:'180골드로 기록을 대조하고 카즈마와 청구할 몫을 나눈다',result:'',card:'axel_kazuma_share',card2:null,gold:0,cost:180,level:0,density:0,potions:0,chance:100});
changes.push({key:'axel_stolen_notice',index:4,before:null,after:structuredClone(events.find(e=>e.key==='axel_stolen_notice').choices[3])});
change('axel_blast_site',3,{card:'axel_wiz_small',cost:160,label:'160골드로 표식을 마련하고 위즈와 대피 통로부터 살핀다'});
change('axel_shop_ledger',3,{card:'axel_wiz_small',cost:160,label:'160골드로 분류 용품을 마련하고 위즈와 작은 고장부터 나눈다'});
change('axel_priest_supply',2,{card:'axel_aqua_supply',label:'80골드로 돌을 맡길 자리를 마련하고 아쿠아와 비상분을 남긴다'});
change('axel_priest_supply',3,{card:'axel_aqua_return',cost:160,label:'160골드로 돌아올 보급을 준비하고 아쿠아와 남길 몫을 나눈다'});
change('axel_crowded_road',3,{card:'axel_darkness_position',cost:160,label:'160골드로 표식을 마련하고 다크니스 뒤의 공격 방향을 나눈다'});
change('axel_party_water',3,{card:'axel_luna_space',cost:180,label:'180골드로 짐 덮개를 마련하고 루나와 지나갈 자리를 비운다'});
change('axel_small_figure',3,{card:'axel_chris_trace',cost:160,label:'160골드로 진열을 준비하고 크리스와 사람들이 지나갈 길을 나눈다'});
change('axel_rival_target',3,{card:'axel_yunyun_gap',cost:160,label:'160골드로 표시 용품을 마련하고 융융과 서로 다른 표적을 나눈다'});
change('axel_sword_introduction',3,{card:'axel_kazuma_share',cost:160,label:'160골드로 표시를 준비하고 카즈마와 소개하는 동안 맡을 몫을 나눈다'});
change('axel_newcomer_questions',3,{card:'axel_luna_space',cost:160,label:'160골드로 안내를 준비하고 루나와 신참이 돌아올 길을 비운다'});
change('axel_cage_from_shore',3,{card:'axel_kazuma_share',cost:160,label:'160골드로 운반을 준비하고 카즈마와 줄 옆에 남길 몫을 나눈다'});
change('axel_snow_footprints',2,{card:'axel_kazuma_share',label:'더 많은 개인 사냥을 맡고 카즈마와 더 쫓아갈 범위를 나눈다'});
change('axel_snow_footprints',3,{card:'axel_aqua_return',cost:160,label:'160골드로 돌아올 짐을 준비하고 아쿠아와 남긴 표식을 확인한다'});
change('axel_question_cut_short',2,{card:'axel_wiz_small',label:'더 강한 개인 사냥을 맡고 위즈와 작은 시범부터 확인한다'});
change('axel_question_cut_short',3,{card:'axel_aqua_supply',cost:160,label:'160골드로 보급을 마련하고 아쿠아와 문밖의 비상분을 나눈다'});
change('axel_house_threshold',3,{card:'axel_kazuma_share',cost:160,label:'160골드로 보급을 준비하고 카즈마와 의뢰인이 맡긴 몫부터 확인한다'});
change('axel_rope_after_return',2,{card:'axel_aqua_return',label:'더 많은 개인 사냥을 맡고 아쿠아와 물 밖에 남길 자리를 살핀다'});
change('axel_rope_after_return',3,{card:'axel_kazuma_share',cost:160,label:'160골드로 반환을 준비하고 카즈마와 아직 잡힌 줄 옆의 짐을 나눈다'});
for(const e of events){const cards=e.choices.filter(c=>c.card);assert.equal(cards.length,3);assert.equal(new Set(cards.map(c=>c.card)).size,3);assert.equal(e.choices.length,e.key==='axel_stolen_notice'?4:3);for(const c of cards)assert.notEqual(c.card,before.world.entryCard);}
const fixed={sourceRevision:'a6b51b99c0c727d3eb04604705590d97b43c5e6e',beforeFile:'before-axel-card-choices-83.json',beforeSha256:crypto.createHash('sha256').update(bytes).digest('hex'),world:before.world,cards:[...before.cards,...addedCards],addedCards,events,changes,policy:{choices:'16사건 모두 서로 다른 지정 카드3종. 명세서 재발행만 돈 자체가 문제여서 별도4번째가 아니라 기존2번230골드를 보존한다.',gold:'일반 일당·정리 보수12선택의 즉시골드를 제거한다. 카드의 이후 처치골드와 중복100골드는 별개다.',follow:'밀린 의뢰1번의 명세서 후속, 우리 고정용품1번의 줄 후속을 보존한다. 후속에서 부모가 준 아쿠아 줄 카드를 반복하지 않는다.',stats:'8희귀 기억은 기존 스탯만 사용한다. 검토용 수치이며 실제 게임 밸런스 미검증이다.',candidate:'사건 후보2~4개 유지'},sources:[{url:'https://konosuba.com/3rd/character/',confirmed:'인물 직업·역할·취향·관계만 확인했다. 카드 효과와 대화·비용·개인 필드 변화는 별도 각색이다.'},{url:'https://konosuba.com/1st/story/',confirmed:'5화 우리 정화,7화 달아나는 눈의 정령,8화 위즈의 가르침 방해와 제령 의뢰를 확인했다. 원작 큰 결말이나 새 기술을 지급하지 않는다.'}]};
write('requests/axel-card-choices-fixed-83.json',fixed);
const schema=structuredClone(read('requests/fuyuki-card-choices-text-80-1.json').schema);
for(let start=0,batch=1;start<events.length;start+=4,batch++){
 const slice=events.slice(start,start+4),refs=new Set(slice.flatMap(e=>e.choices.filter(c=>c.card).map(c=>c.card))),s=structuredClone(schema);
 s.properties.events.minItems=slice.length;s.properties.events.maxItems=slice.length;s.properties.events.items.properties.key.enum=slice.map(e=>e.key);s.properties.events.items.properties.choices.maxItems=4;s.properties.events.items.properties.choices.items.properties.index.enum=[1,2,3,4];
 write('requests/axel-card-choices-text-83-'+batch+'.json',{review:false,schema:s,system:'한국어 사건 작가다. events에 입력 key를 별도 객체로 한번씩 같은 순서로 출력한다. choices에는 입력 index만 출력한다. label은 입력 그대로 쓴다. result는 기존 현장에서 한 행동, 지정 기억 카드와 실제 비용/필드/물약 지급, 인물의 작은 반응을 세 문장으로 쓴다. JSON이나 메타데이터를 문장에 넣지 않는다.',brief:{cards:fixed.cards.filter(c=>refs.has(c.key)),events:slice.map(e=>({key:e.key,story:e.story,canonFact:e.canonFact,choices:e.choices.map((c,j)=>({index:j+1,...c})).filter(c=>changes.some(x=>x.key===e.key&&x.index===c.index))})),mechanics:{reward:'지정 카드1장 성공때 지급. UI가 이름·등급·정확한 효과를 별도 덧붙인다. 즉시골드0이며 명세서의 기존230골드 선택은 변경 대상이 아니다.',cost:'cost만큼 선지불. potions는 그 개수 지급이며 소비·즉시회복 아님.',field:'초기몬스터강함1/적수4. level/density는 몬스터강함/적수 단계 변화량이며 max(1,현재+변화량)로 지속한다. 플레이어 능력이나 피로/시간이 아니다. 상한5/10.',stats:'regen초당최대체력% 재생이며 흡수합산10%상한. 건강피해65%조건. 방향피해는 공격 플래그+유효각도. NPC가 성장하거나 새스킬·장비·도발·자동수색·부활·정령/수중전투를 지급하지 않는다.'},boundary:before.canonBoundary,checks:['요청한 index만 쓴다. 변경하지 않는 선택은 추가하지 않는다.','기억 카드 이름과 현장 행동이 맞고 비용·물약·개인필드 지속 부담을 빠뜨리지 않는다.','칭찬과 끄덕임만 반복하지 않고 현장의 남은 문제에 인물이 반응한다.']}});
}
console.log(JSON.stringify({events:events.length,choices:events.reduce((n,e)=>n+e.choices.length,0),newCards:addedCards.length,changedChoices:changes.length,directGoldChoices:events.flatMap(e=>e.choices).filter(c=>c.gold>0).length,batches:4}));
