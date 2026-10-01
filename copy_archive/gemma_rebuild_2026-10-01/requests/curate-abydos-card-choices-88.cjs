// 아비도스 재집필의 행동 주체와 반복 반응을 바로잡고 고정 보상과 결합하여 독립 검토를 준비한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const fixed=read('requests/abydos-card-choices-fixed-86.json'),before=read('before-abydos-card-choices-86.json'),drafts=[1,2,3,4].map(n=>read('drafts/abydos-scenes-text-87-'+n+'.json')),raw=new Map();
for(const d of drafts){assert.equal(d.parseError,null);assert.deepEqual(d.parsed.events.map(e=>e.key),d.request.brief.events.map(e=>e.key));for(const [i,e]of d.parsed.events.entries()){assert.deepEqual(e.choices.map(c=>c.index),d.request.brief.events[i].choices.map(c=>c.index));for(const c of e.choices)raw.set(e.key+'#'+c.index,c);}}
const scenes={
 'abydos_ramen_shift#2':['세리카와 먼저 받은 주문서를 따로 묶고 새 주문이 들어갈 빈 줄을 남겼다.','세리카는 뒤늦게 온 주문을 그 묶음에 넣으려다 아직 안 나간 첫 그릇부터 찾는다.'],
 'abydos_ramen_shift#3':['세리카와 운송한 재료를 나누고 다음 교대가 쓸 몫을 따로 남겼다.','세리카는 학교 일도 남았다고 하면서 다음 사람이 찾을 재료의 자리를 다시 표시한다.'],
 'abydos_blackmarket_map#3':['아야네가 남긴 기록을 가방에 나눠 넣고 어디에 전달할 것인지부터 확인했다.','히후미가 출구 쪽을 가리키자 시로코는 조사할 골목과 네가 돌아갈 길을 다른 표시로 남긴다.'],
 'abydos_ramen_repair#3':['세리카와 병문안 짐을 나누고 다음에 쓸 물건은 잔해와 다른 쪽에 남겼다.','세리카는 가게가 다 고쳐진 것처럼 도구를 놓지 않고 아직 가져다줄 짐 옆에 이름을 적는다.'],
 'abydos_desert_watch#3':['아야네에게 돌아갈 경로를 전하고 넘어가지 않을 경계를 지도에 남겼다.','호시노가 무리한 진입을 말리자 노노미도 네가 돌아올 쪽부터 엄호할 자리를 짚는다.'],
 'abydos_missing_senior#3':['아야네와 귀환 보급을 나누고 비어 있는 호시노의 자리 옆에 돌아올 공간을 남겼다.','아야네는 찾은 사람의 이름을 쓰는 대신 아직 연락해야 할 곳을 기록의 빈 줄에 남긴다.'],
 'abydos_pace#3':['세리카와 더 약한 구역을 먼저 맡을 차례를 나누고 시로코가 펼친 지도에 표시했다.','세리카는 시로코의 한 바퀴가 자기에게도 같은 거리인지 다시 물으며 맡은 구역부터 접는다.'],
 'abydos_sleepchair#3':['아야네와 준비 가방을 옮기고 호시노가 일어날 자리 옆에 돌아올 통로를 남겼다.','노노미가 다음 가방을 내려놓으려 하자 아야네는 방금 남긴 통로는 비워 두자고 한다.'],
 'abydos_snack_share#3':['세리카와 간식보다 먼저 받은 주문을 나누고 빈칸이 남은 주문서를 다시 펼쳤다.','노노미는 아직 못 받은 간식 몫을 묻고 세리카는 주문이 끝난 줄과 남은 줄을 다른 쪽에 놓는다.'],
 'abydos_antique_note#1':['연락한 기록을 아야네와 대조하고 지워진 항목의 남은 숫자를 확인했다.','가게 주인이 확인한 줄을 가리키자 아야네는 그 아래의 빈칸까지 같은 답으로 채우지 않는다.'],
 'abydos_antique_note#2':['아야네와 확인하지 않은 빈칸을 그대로 남기고 확실한 줄만 기록에 옮겼다.','아야네는 주인이 장담하지 않은 항목 옆에 다음에 물어볼 일을 따로 적는다.'],
 'abydos_antique_note#3':['아야네와 확인된 물건을 옮길 준비를 하고 전달할 곳부터 나눴다.','주인이 아직 확인하지 않은 상자를 함께 밀자 아야네는 그 상자는 다른 목록에 남기자고 한다.'],
 'abydos_aquarium_step#3':['아야네와 돌아올 통로를 비우고 외출 전에 맡을 길목을 한 곳 줄였다.','호시노가 다음에 볼 곳을 묻자 시로코는 안내판과 따로 접어 둔 귀환길을 번갈아 가리킨다.'],
 'ab68_big_bill#2':['무츠키와 계산서가 닫히기 전 아루의 다음 말을 기다렸다.','아루가 큰소리를 다시 내려 하자 무츠키는 세리카 손의 계산서도 아직 여기 있다고 웃는다.'],
 'ab68_disc_before_words#2':['카요코와 한 곡이 끝날 때까지 말을 끊지 않고 박자를 들었다.','곡이 끝나도 카요코는 주문할 말이 남았다며 주인이 다시 사과하기 전에 진열을 가리킨다.'],
 'ab68_disc_before_words#3':['귀환 보급을 나눈 뒤 카요코가 끝내지 못한 주문부터 들었다.','주인이 또 사과를 붙이려 하자 카요코는 이번에는 찾는 물건 이름부터 이어 말한다.'],
 'ab68_weed_hand#2':['하루카에게 손을 뻗기 전에 화분을 어디에 두려던 것인지 먼저 물었다.','하루카는 화분을 붙든 채 그 자리까지 치우려 했던 것인지 네가 거둔 손을 다시 본다.'],
 'ab68_weed_hand#3':['보급을 마련하되 하루카의 화분을 놓을 작은 자리는 그대로 남겼다.','하루카는 네가 비워 둔 자리에 화분을 놓기 전에 무엇을 치우려 했던 것인지 한 번 더 묻는다.'],
 'ab68_two_envelopes#2':['무츠키에게 두 봉투의 답을 모두 듣고 아직 봉투를 고르지 않은 손을 남겼다.','무츠키는 답을 들은 아루가 이제 하나를 골라도 되겠냐고 묻자 이번에는 대가부터 정하자고 한다.'],
 'ab68_two_envelopes#3':['보급을 준비한 뒤 봉투를 고르기 전에 아루의 큰소리부터 들었다.','아루가 답을 아는 것처럼 말하려 하자 무츠키는 아직 닫힌 봉투를 그 앞으로 민다.'],
 'ab68_name_after_bill#2':['내 준비를 마친 뒤 무츠키와 아루의 이름 다음에 나올 일을 기다렸다.','아루가 소개를 다시 고치려 하자 무츠키는 이번에는 이름 뒤에 할 일을 붙여 달라고 한다.'],
 'ab68_reply_after_disc#2':['카요코가 아까 멈춘 주문을 이어 말할 때까지 말 사이의 박자를 남겼다.','주인이 이번에는 사과 대신 진열을 보자 카요코는 주문을 끝낸 뒤 네가 고를 것도 기다린다.'],
 'ab68_reply_after_disc#3':['귀환을 준비하며 카요코와 끝난 곡의 박자를 되짚되 남은 주문은 끊지 않았다.','카요코가 주문을 마친 뒤 주인은 네가 고른 것을 아직 못 들었다며 진열을 다시 가리킨다.']
};
const changes=[];
const events=fixed.events.map(e=>({...e,choices:e.choices.map((c,j)=>{
 const key=e.key+'#'+(j+1),d=raw.get(key);if(!d)return {...c};assert(scenes[key]);const memory=fixed.cards.find(k=>k.key===c.card),parts=[];assert(memory);
 if(c.cost)parts.push(c.cost+'골드를 지불했다.');parts.push('「'+memory.effectName+'」의 기억 카드1장을 얻었다.');
 if(c.level>0)parts.push('내 사냥의 몬스터 강함 단계가'+c.level+'올랐다.');if(c.level<0)parts.push('내 사냥의 몬스터 강함 단계를 최저1범위에서'+(-c.level)+'낮췄다.');
 if(c.density>0)parts.push('내 사냥의 적 수 단계가'+c.density+'올랐다.');if(c.density<0)parts.push('내 사냥의 적 수 단계를 최저1범위에서'+(-c.density)+'낮췄다.');if(c.potions)parts.push('물약'+c.potions+'개를 받았다.');
 const result=scenes[key][0]+' '+parts.join(' ')+' '+scenes[key][1];changes.push({key,rawAction:d.actionText,rawReaction:d.reactionText,after:result,reason:'주체와시제·비용중복·적수/강함혼동·칭찬/끄덕임·아루대신무츠키의다음말혼동을고치고고정보상을결합했다. NPC가성장하거나실패확률을만들지않는다.'});return {...c,result};
}),failure:e.failure?e.failure.replace('카드와 확인 보수는 받지 못한다.','카드는 받지 못한다.'):null}));
const candidate={...before,cards:fixed.cards,events};assert.equal(changes.length,23);assert.deepEqual(candidate.world,before.world);
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
write('revisions/abydos-card-choices-curated-88.json',candidate);
write('revisions/abydos-card-choices-curation-88.json',{rawDrafts:[1,2,3,4].map(n=>'drafts/abydos-scenes-text-87-'+n+'.json'),rejectedEarlier:[1,2,3,4].map(n=>'drafts/abydos-card-choices-text-86-'+n+'.json'),changes,removedChoices:fixed.removedChoices,newCards:fixed.addedCards,sources:fixed.sources,unchangedMechanics:'고정86의 카드·비용·개인 필드·물약·확률을 유지한다. 기존20카드/머리효과와 네 후속번호를 유지한다.',check});
for(let start=0,batch=1;start<events.length;start+=6,batch++){
 const slice=events.slice(start,start+6),refs=new Set(slice.flatMap(e=>e.choices.map(c=>c.card)));
 write('requests/abydos-card-choices-review-88-'+batch+'.json',{review:true,schema:read('requests/abydos-expansion-review-70.json').schema,system:'한국어 독립 검토자다. 실제 데이터와 문장의 불일치만 issues에 쓴다. level/density는 초기몬스터강함1/적수4에서의 변화량이다. UI가 카드 이름과 정확한 효과를 덧붙인다. 새밸런스나기능은제안하지않는다.',brief:{cards:candidate.cards.filter(c=>refs.has(c.key)),events:slice,mechanics:{reward:'성공때 지정카드1장과 potions개물약 지급.즉시골드0.이후처치골드·중복100은별개다. result는성공일때만사용한다.',cost:'cost선지불.실패때도비용/AP/필드유지.실패때카드/물약없음.',field:'level몬스터강함,density몬스터수 단계의 지속변화량. 초기1/4,최저1,상한5/10. 플레이어능력·피로·시간아님.',history:fixed.policy.history,stats:'기억은여행자성장이다. 이동3은3%,regen시간회복/흡수합산10%상한이며즉시회복아님. 최대체력증가현재/최대비율유지. 방향은플래그+실제각도,비방향은헤드/백없는공격,보호막조건은새보호막지급아님. healthy65%조건.',boundary:candidate.canonBoundary},checks:['모든 사건 서로 다른 지정카드3종이며 직접골드대안/입문카드반복이없는가?','비용·필드변화·물약·지정기억·성공결과/실패문구·자기후속과 데이터가맞는가?','공식역할과기존현장행동에서남은문제의반응이이어지고미구현주문/음악/화분기능·NPC성장·학교빚해결은없는가?']}});
}
console.log(JSON.stringify({events:18,choices:54,newCards:10,changedResults:23,check}));
