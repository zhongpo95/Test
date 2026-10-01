// 후유키의 입문 카드 반복과 골드 대안을 서로 다른 세 카드 행동의 고정 검토안으로 준비한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const file=path.join(repo,'content/roguelite/01-fuyuki.json'),bytes=fs.readFileSync(file),before=JSON.parse(bytes);
fs.writeFileSync(path.join(root,'before-fuyuki-card-choices-79.json'),bytes,{flag:'wx'});
const card=(key,effectName,keyword,effects,canonFact)=>({key,name:'에미야 시로',effectName,keyword,grade:2,effects,evolution:{kind:0,goal:0,effects:[]},canonFact,uncertain:[]});
const addedCards=[
 card('fy_shiro_structure','맞춰 본 빈칸','공격력 · 행동 속도',[{stat:'attack_percent',value:12},{stat:'action_speed',value:3}],'기존 구조를 살피는 시로의 소개에서 문의 구조·확인한 길·화살을 받는 준비를 살피는 별도 기억을 만든다. 즉시 물건 수리·새 투영무기·활 기술·원작성취를 지급하지 않는다.'),
 card('fy_shiro_request','이름 없이 맡긴 부탁','공격력 · 받는 피해',[{stat:'attack_percent',value:12},{stat:'damage_reduction',value:2}],'기존 남의 일을 돕는 시로의 성향과 이상에서 누가 맡길지 남은 일을 자기 몫으로 나누는 별도 기억을 만든다. 시로의 이상을 정답으로 완성하거나 모든 사람을 구하지 않는다.')
];
const events=structuredClone(before.events),changes=[];
const mechanics=['card','card2','cost','gold','level','density','potions','chance'];
function change(key,index,values){const e=events.find(e=>e.key===key),old=structuredClone(e.choices[index-1]);e.choices[index-1]={...old,...values,gold:0,result:''};changes.push({key,index,before:old,after:structuredClone(e.choices[index-1])});}
change('school_circle',2,{card:'fy_shiro_structure'});
change('school_circle',3,{card:'fy_rin_timing',cost:140,label:'140골드로 기록용품을 마련하고 린과 대피 순서를 나눈다'});
change('school_circle_trace',3,{card:'fy_rin_timing',cost:180,label:'180골드로 기록을 나눠 적고 린과 다시 확인할 차례를 맞춘다'});
change('temple_gate',3,{card:'fy_saber_stride',cost:160,label:'160골드로 돌아갈 표식을 마련하고 세이버와 발을 둘 길을 나눈다'});
change('fy_club_inventory',2,{card:'fy_shiro_structure'});
change('fy_club_inventory',3,{card:'fy_shiro_request',cost:160,label:'160골드로 포장을 마련하고 시로와 아직 이름 없는 상자의 몫을 맡는다'});
change('fy_regular_contact',3,{card:'fy_shiro_request',cost:160,label:'160골드로 연락할 준비를 마련하고 시로와 아직 답 없는 일을 나눈다'});
change('fy_shinji_offer',1,{});
change('fy_shinji_offer',3,{card:'fy_shiro_request',cost:160,label:'160골드로 확인할 준비를 갖추고 시로와 답하기 전 맡을 일을 나눈다'});
change('fy_pause_outside',3,{card:'fy_shiro_request',cost:160,label:'160골드로 가까운 길의 준비를 갖추고 시로와 남은 몫을 나눈다'});
change('fy_teacher_statement',1,{});
change('fy_teacher_statement',2,{card:'fy_shiro_structure'});
change('fy_teacher_statement',3,{card:'fy_shiro_request',cost:160,label:'160골드로 물어볼 준비를 하고 시로와 확인되지 않은 일을 남겨 둔다'});
change('fy_two_ideals',3,{card:'fy_shiro_request',cost:180,label:'180골드로 보급을 마련하고 시로와 다음에 맡을 몫부터 나눈다'});
change('fy_lancer_crossing',3,{card:'saber_opening',cost:160,label:'160골드로 연습할 준비를 갖추고 세이버와 물러선 자리의 검끝을 본다'});
change('fy_arrow_on_floor',2,{card:'fy_shiro_structure',label:'더 많은 개인 사냥을 맡고 시로가 건넨 화살과 내 손의 순서를 본다'});
change('fy_arrow_on_floor',3,{card:'fy_taiga_list',cost:160,label:'160골드로 준비 목록을 마련하고 타이가와 아직 안 받은 물건부터 확인한다'});
change('fy_shelter_question',3,{card:'rin_disarm',cost:180,label:'180골드로 확인할 자료를 마련하고 린과 보호의 말에서 빠진 범위를 짚는다'});
change('fy_after_one_block',3,{card:'archer_pragmatism',cost:180,label:'180골드로 관찰할 준비를 갖추고 아처와 다음 큰 상대의 위치를 나눈다'});
change('fy_next_arrow_wait',2,{card:'fy_shiro_structure',label:'220골드로 내 연습을 준비하고 시로가 건넨 화살을 받을 차례부터 본다'});
events.find(e=>e.key==='fy_next_arrow_wait').choices=events.find(e=>e.key==='fy_next_arrow_wait').choices.slice(0,3);
for(const e of events){assert.equal(e.choices.length,3);assert.equal(new Set(e.choices.map(c=>c.card)).size,3);for(const c of e.choices){assert(c.card);assert.notEqual(c.card,before.world.entryCard);assert.equal(c.gold,0);}}
const fixed={sourceRevision:'5c1ec66',beforeFile:'before-fuyuki-card-choices-79.json',beforeSha256:crypto.createHash('sha256').update(bytes).digest('hex'),world:before.world,cards:[...before.cards,...addedCards],addedCards,events,changes,policy:{choices:'사건 안에서 서로 다른 지정 카드3종',head:'시스템·효과 유지',candidate:'사건 후보2~4개 유지',gold:'후유키 직접골드11선택 제거. 비용/나중처치수급/중복100골드는 별개다.',history:'학교 연결끊기1번과타이가질문1번후속을같은번호로유지',newStats:'시로 기존 역할의 두 희귀 기억, 수치는 검토용이며 실전 밸런스 미검증'}};
write('requests/fuyuki-card-choices-fixed-79.json',fixed);
const schema={type:'object',properties:{events:{type:'array',items:{type:'object',properties:{key:{type:'string'},choices:{type:'array',items:{type:'object',properties:{index:{type:'integer'},label:{type:'string'},result:{type:'string'}},required:['index','label','result'],additionalProperties:false}}},required:['key','choices'],additionalProperties:false}}},required:['events'],additionalProperties:false};
const changedEvents=events.filter(e=>changes.some(c=>c.key===e.key));
for(let start=0,batch=1;start<changedEvents.length;start+=7,batch++){
 const slice=changedEvents.slice(start,start+7),refs=new Set(slice.flatMap(e=>e.choices.map(c=>c.card)));
 write('requests/fuyuki-card-choices-text-79-'+batch+'.json',{review:false,schema,system:'한국어 사건 작가다. 새 장면을 덧붙이지 말고 기존 story의 문제에서 변경된 선택의 행동·결과만 집필한다. 지정 index/label 그대로, result는 행동1문장+여행자가 얻은 카드 기억과 실제 부담/물약1문장+인물의 작은 반응1문장이다. 칭찬·끄덕임을 반복하지 않는다. NPC가 성장하거나 미구현 능력을 주지 않는다.',brief:{cards:fixed.cards.filter(c=>refs.has(c.key)),events:slice.map(e=>({key:e.key,story:e.story,canonFact:e.canonFact,unchangedChoices:e.choices.map((c,j)=>({index:j+1,...c})).filter(c=>!changes.some(x=>x.key===e.key&&x.index===c.index)),choices:e.choices.map((c,j)=>({index:j+1,...c})).filter(c=>changes.some(x=>x.key===e.key&&x.index===c.index))})),mechanics:{reward:'지정카드1장 성공때지급. 즉시골드0. kill_gold는이후처치수급이다. UI가이름/등급/효과를별도덧붙임.',cost:'cost만큼선지불. 실패에도환급/AP환급없음. potions는지급이고소비아님.',field:'level강함/density적수의지속변화량이다. 사냥몬스터가강해지거나많아지는부담이다. 초기강함1/적수4,최저1,상한5/10. -1은감소이며최종값아님.',chance:'result는성공일때만쓴다. 실패서술은별도로고친다. 60/70/75를확정성공으로쓰지않는다.',stats:'attack_percent공격력%,action_speed일반행동속도,DR받는피해감소,swift고정신속,directional플래그+실제유효각도,healthy현재체력65%이상,regen초당최대체력%/흡수합산10%상한/즉시회복아님'},boundary:'각canonFact와기존장면에서만창작한다. 새NPC/새스킬/장비/동행/무적/현재체력지불/시로이상완성/학교사건본편완결없음. 이후전용타이가interval은앞선arrow사건에주지않는다.'}});
}
console.log(JSON.stringify({events:16,choices:48,changedChoices:changes.length,newCards:2,directGoldChoices:0,batches:Math.ceil(changedEvents.length/7)}));
