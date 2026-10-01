// 액셀 집필의 비용 역전·누락·반복 반응을 실제 기억 카드와 현장 문제에 맞추고 독립 검토를 준비한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const fixed=read('requests/axel-card-choices-fixed-83.json'),before=read('before-axel-card-choices-83.json');
const drafts=[1,2,3,4].map(n=>read('drafts/axel-card-choices-text-83-'+n+'.json')),raw=new Map();
for(const d of drafts){assert.equal(d.parseError,null);assert.deepEqual(d.parsed.events.map(e=>e.key),d.request.brief.events.map(e=>e.key));for(const [i,e]of d.parsed.events.entries()){assert.deepEqual(e.choices.map(c=>c.index),d.request.brief.events[i].choices.map(c=>c.index));for(const c of e.choices){assert.equal(c.label,d.request.brief.events[i].choices.find(x=>x.index===c.index).label);raw.set(e.key+'#'+c.index,c);}}}
const scenes={
 'axel_request#3':['루나와 의뢰를 나눠 맡고 다른 모험가가 지나갈 운송 길부터 비웠다.','루나는 두 의뢰서를 다시 겹쳐 놓지 않고 네가 맡은 쪽 옆에 다음 질문을 적는다.'],
 'axel_stolen_notice#3':['크리스와 사라진 명세서를 찾기 전에 이미 지나간 흔적과 새 흔적을 나눴다.','크리스는 네가 먼저 밟으려던 자리를 가리키고 카즈마는 그 너머에서 다시 주머니를 뒤진다.'],
 'axel_stolen_notice#4':['카즈마와 완료한 의뢰의 기록을 대조하고 아직 청구하지 않은 몫을 골랐다.','카즈마는 같은 일을 다시 했다고 적지 말라며 빈 청구란을 네 쪽으로 돌린다.'],
 'axel_blast_site#3':['위즈와 암벽을 등지고 대피할 길에 표식을 놓으며 작은 위험부터 살폈다.','메구밍이 시연할 자리를 가리키자 위즈는 그곳을 볼 자리와 돌아설 길을 다른 표시로 남긴다.'],
 'axel_shop_ledger#3':['위즈와 마도구를 분류하고 작은 고장부터 장부의 다른 줄에 적었다.','바니르는 아직 팔 수 없는 물건까지 매출로 적지 말라며 위즈의 장부를 다시 펼친다.'],
 'axel_priest_supply#2':['아쿠아의 돌을 맡길 자리를 마련하고 비상용 보급을 따로 남겼다.','아쿠아가 남은 돌도 가져오려 하자 너는 소모품을 둘 빈 자리부터 가리킨다.'],
 'axel_priest_supply#3':['아쿠아와 돌아올 때 쓸 보급을 나누고 지금 식사에 쓰지 않을 몫을 남겼다.','아쿠아는 접시에 손을 뻗다가 돌아올 몫이 담긴 쪽은 다른 자리에 놓는다.'],
 'axel_crowded_road#3':['다크니스 뒤에 표식을 놓고 네 공격이 지나갈 방향을 나눴다.','다크니스는 앞을 막고 서 있지만 크리스는 네가 공격할 빈 쪽까지 막지 말라고 손짓한다.'],
 'axel_party_water#3':['루나와 젖으면 곤란한 짐에 덮개를 씌우고 사람들 사이에 지나갈 자리를 남겼다.','아쿠아가 박수를 기다리는 동안 카즈마는 아직 덮지 않은 마지막 짐을 그 자리 밖으로 옮긴다.'],
 'axel_small_figure#3':['크리스와 진열품 옆의 흔적을 살피고 뒤에 선 사람들이 지나갈 길을 나눴다.','다크니스는 길을 비켰지만 눈은 같은 진열품에 남아 있고 크리스는 다시 멈출 자리부터 묻는다.'],
 'axel_rival_target#3':['융융과 표적의 간격을 표시하고 메구밍이 고른 큰 자리와 다른 쪽을 맡았다.','메구밍이 한 번에 끝낼 수 있다며 큰 자리를 가리키자 융융은 네가 아직 보지 않은 작은 표적을 남긴다.'],
 'axel_sword_introduction#3':['카즈마와 표시물을 나눠 옮기고 미츠루기가 소개하는 동안 볼 길목을 골랐다.','미츠루기가 그람의 이름을 다시 말하자 카즈마는 소개가 끝날 때까지 맡을 몫도 함께 적으라고 한다.'],
 'axel_newcomer_questions#3':['루나와 신참이 돌아올 길에 표식을 남기고 맡을 길목을 한 곳 줄였다.','신참이 돌아와도 같은 창구를 찾을 수 있냐고 묻자 루나는 아직 받지 않은 다음 질문을 펼친다.'],
 'axel_cage_from_shore#3':['카즈마와 줄 옆의 짐을 옮기고 가려졌던 줄을 잡을 손과 남길 몫을 나눴다.','구경꾼이 아직 줄을 가리키자 카즈마는 짐을 옮긴 손도 다시 그쪽에 보태 달라고 한다.'],
 'axel_snow_footprints#2':['카즈마와 더 쫓아갈 범위를 나누되 돌아올 표식은 따로 남겼다.','카즈마는 저쪽도 자기 몫이냐고 묻고 아쿠아는 더 간 만큼 돌아올 길도 보라고 한다.'],
 'axel_snow_footprints#3':['아쿠아와 돌아올 짐을 준비하고 겹친 발자국 옆의 표식을 다시 확인했다.','카즈마가 한 번 더 먼 곳을 가리키자 아쿠아는 아직 남긴 짐부터 가져갈 것인지 묻는다.'],
 'axel_question_cut_short#2':['위즈와 작은 시범에서 실패할 자리를 먼저 확인하고 아직 끝나지 않은 질문을 남겼다.','카즈마가 다음 설명을 기다리는 사이 아쿠아는 문밖의 제령 의뢰도 남아 있다고 끼어든다.'],
 'axel_question_cut_short#3':['아쿠아와 문밖의 보급을 나누고 당장 가져갈 몫 옆에 비상분을 남겼다.','가게 안에서 카즈마의 질문이 다시 들리자 아쿠아는 남긴 비상분보다 다음 의뢰를 먼저 가리킨다.'],
 'axel_house_threshold#3':['카즈마와 보급을 준비하되 아직 열리지 않은 문 앞에서 의뢰인이 맡긴 몫부터 확인했다.','아쿠아가 창문을 다시 보자 카즈마는 그쪽으로 옮기기 전에 의뢰인이 문을 열 차례라고 한다.'],
 'axel_rope_after_return#2':['아쿠아와 물 밖에 남길 자리를 살피고 줄에서 손을 떼기 전에 발 디딜 곳을 나눴다.','아쿠아는 바깥 자리가 보여도 우리를 다시 물속에 넣는 것은 아니냐고 확인한다.'],
 'axel_rope_after_return#3':['카즈마와 반환할 짐을 나누고 아직 잡힌 줄 옆에 비워 둘 몫을 남겼다.','구경꾼이 이제 놓아도 되냐고 묻자 카즈마는 짐부터 내려놓고 줄을 잡은 손을 다시 보자고 한다.']
};
const changes=[];
const events=fixed.events.map(e=>({...e,choices:e.choices.map((c,j)=>{
 const key=e.key+'#'+(j+1),d=raw.get(key);if(!d)return {...c};assert(scenes[key]);
 const memory=fixed.cards.find(k=>k.key===c.card),parts=[];assert(memory);
 if(c.cost)parts.push(c.cost+'골드를 지불했다.');parts.push('「'+memory.effectName+'」의 기억 카드1장을 얻었다.');
 if(c.level>0)parts.push('내 사냥의 몬스터 강함 단계가'+c.level+'올랐다.');
 if(c.level<0)parts.push('내 사냥의 몬스터 강함 단계를 최저1범위에서'+(-c.level)+'낮췄다.');
 if(c.density>0)parts.push('내 사냥의 적 수 단계가'+c.density+'올랐다.');
 if(c.density<0)parts.push('내 사냥의 적 수 단계를 최저1범위에서'+(-c.density)+'낮췄다.');
 if(c.potions)parts.push('물약'+c.potions+'개를 받았다.');
 const result=scenes[key][0]+' '+parts.join(' ')+' '+scenes[key][1];
 changes.push({key,field:'result',before:d.result,after:result,reason:'지불 비용을 지급으로 뒤집은 문장·필드/물약 누락·감소량의 음수 중복·종전 설명의 끝을 바꾼 표현·반복 칭찬을 실제 고정 보상과 남은 현장 문제로 고친다.'});return {...c,result};
}),failure:e.failure?e.failure.replace('카드와 보급 보수는 얻지 못했다.','카드는 얻지 못했다.'):null}));
const candidate={...before,cards:fixed.cards,events};
assert.equal(changes.length,21);assert.deepEqual(candidate.world,before.world);
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
write('revisions/axel-card-choices-curated-84.json',candidate);
write('revisions/axel-card-choices-curation-84.json',{rawDrafts:[1,2,3,4].map(n=>'drafts/axel-card-choices-text-83-'+n+'.json'),changes,newCards:fixed.addedCards,retainedGoldException:'사라진 명세서의 기존2번 재발행230골드는 돈 자체가 문제라 유지한다. 이 사건도 크리스2기억·카즈마1기억 세 카드가 따로 있다.',removedGoldChoices:before.events.flatMap(e=>e.choices.map((c,i)=>({key:e.key,index:i+1,...c}))).filter(c=>c.gold>0&&c.key!=='axel_stolen_notice'),sources:fixed.sources,unchangedMechanics:'고정83의 카드·비용·필드·물약·75%확률을 그대로 유지한다. 기존18카드와 머리 효과,두 부모 성공1번을 유지한다.',check});
for(let start=0,batch=1;start<events.length;start+=6,batch++){
 const slice=events.slice(start,start+6),refs=new Set(slice.flatMap(e=>e.choices.filter(c=>c.card).map(c=>c.card)));
 write('requests/axel-card-choices-review-84-'+batch+'.json',{review:true,schema:read('requests/abydos-expansion-review-70.json').schema,system:'한국어 독립 검토자다. 데이터와 문장을 직접 대조해 실제 불일치만 issues에 쓴다. level/density는 초기강함1/적수4에서의 변화량이다. UI가 카드 이름과 정확한 효과를 덧붙인다. 새로운 밸런스나 새 전투 기능을 제안하지 않는다.',brief:{cards:candidate.cards.filter(c=>refs.has(c.key)),events:slice,mechanics:{reward:'성공때 지정카드1장·물약potions개 지급. 예외로 명세서 재발행2번은 gold230만 지급. 다른선택 즉시골드0. 이후처치골드·중복100골드는 별개다.',cost:'cost선지불,실패때도비용/AP/필드유지. result성공일때만이고 failure카드/물약없음.',field:'level몬스터강함,density몬스터수 단계의 지속변화량. 초기1/4,최저1,상한5/10. 플레이어능력·피로·시간이아님.',history:'자기 axel_request성공1번만stolen_notice. 자기cage성공1번만rope후속. 부모의aqua_rope는후속에서다시주지않는다. kazuma_release는후속전용이다.',stats:'카드들은여행자기억이다. regen시간회복/흡수합산10%상한이며즉시회복/물약아님. 방향피해공격플래그+실제각도,healthy65%조건,이동속도지속증가이며진짜NPC성장이아니다.',boundary:candidate.canonBoundary},checks:['16사건 모두 서로 다른 지정카드3종이고 명세서만 추가 골드 예외인가?','카드·비용·물약·필드·확률·개인후속과 글이 맞는가?','공식 역할과 기존 현장의 문제에서 인물 반응이 이어지고 새기술·장비·본편결말·현재체력지불은 없는가?']}});
}
console.log(JSON.stringify({events:16,choices:49,changedResults:21,newCards:8,directGoldChoices:1,check}));
