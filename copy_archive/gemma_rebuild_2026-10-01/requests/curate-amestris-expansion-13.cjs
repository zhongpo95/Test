// 아메스트리스 초안의 과장된 동작과 추상적 결과를 실제 카드·비용·개인 필드에 맞춘다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const fixed=JSON.parse(fs.readFileSync(path.join(root,'requests/amestris-expansion-fixed-12.json'),'utf8'));
const draft=JSON.parse(fs.readFileSync(path.join(root,'drafts/amestris-expansion-text-12.json'),'utf8')).parsed;
const current=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/12-amestris.json'),'utf8'));
assert.deepEqual(draft.events.map(e=>e.key),fixed.events.map(e=>e.key));
const changes=[];function edit(obj,field,value,key,reason){changes.push({key,field,before:obj[field],after:value,reason});obj[field]=value;}
const events=fixed.events.map((p,i)=>{assert.equal(draft.events[i].choices.length,p.choices.length);return {key:p.key,title:p.title,story:draft.events[i].story,intro:draft.events[i].intro,previous:null,previousChoice:0,requiredCard:null,choices:p.choices.map((b,j)=>({label:draft.events[i].choices[j].label,result:draft.events[i].choices[j].result,card:b.card,card2:b.card2,gold:b.gold,cost:b.cost,level:b.level,density:b.density,potions:b.potions,chance:b.chance})),failure:p.failure||null,canonFact:p.canonFact,uncertain:[]};});
const e=k=>events.find(x=>x.key===k);function scene(key,intro,rs){const x=e(key);edit(x,'intro',intro,key,'맡을 행동을 짧게 안내하고 본문과 같은 결론을 반복하지 않는다.');rs.forEach((r,i)=>edit(x.choices[i],'result',r,key+'#'+(i+1),'비용·지정 카드의 준비·개인 몹 단계와 수·보수 제공자·보급 물약을 연결한다. 효율·완전한 경로 확보 등 미구현 보장을 덜고 인물 반응을 남긴다.'));}
edit(e('fma_hayate_commands'),'story','리자가 블랙 하야테에게 낮은 목소리로 기다리라고 한다. 에드워드는 앞길을 살피려 움직이고, 개는 준비 가방 쪽을 빤히 쳐다본다. 리자는 가방을 든 네 손을 낮추고 지나갈 선부터 비우라고 말한다.','fma_hayate_commands','원안에 없는 개를 겨누는 공격 동작을 덧붙였다. 총기 사용 장면을 확인한 척하지 않고 기다림과 통행 문제로 되돌린다.');
scene('fma_hayate_commands','지나갈 선을 준비할지, 바깥길을 맡을지 정한다.',[
 '표시 도구 값을 내고 리자와 사람 앞을 가로지르지 않을 위치를 짚었다. 공격할 방향과 짧은 틈을 정확히 고르는 준비를 배웠다. 리자가 손을 내리자 블랙 하야테도 가방에서 시선을 뗀다.',
 '에드워드와 더 강한 적이 드나드는 길을 맡았다. 단단한 상대를 무너뜨릴 곳부터 짚는 법을 배우고 개인 사냥의 적 단계가 올라갔다. 리자는 안쪽 통행 준비를 계속한다.',
 '가방 안의 보급을 나누고 준비 담당자에게 보수와 물약을 받았다. 에드워드는 바깥길로 고개를 돌리고 리자는 블랙 하야테를 곁에 세운다.'
]);
scene('fma_family_photo','사진과 보고서 중 어느 정리를 도울지 정한다.',[
 '정리용품 값을 내고 휴즈와 사진 아래 가려진 기록을 한 장씩 살폈다. 빠뜨린 후보를 더 보고 강한 상대에게 놓칠 점을 짚는 준비를 배웠다. 휴즈는 사진을 꺼내 놓고 딸 이야기를 이어 간다.',
 '대조용품 값을 내고 셰스카와 더 넓은 길목의 기록을 맡았다. 기억한 내용을 비교해 볼 곳을 늘리는 법을 배운 대신 개인 사냥의 적 수가 늘었다. 휴즈에게는 가족 사진을 돌려주었다.',
 '사진이 보고서 아래 깔리지 않게 보관 상자를 나눴다. 준비를 맡긴 곳에서 작업 보수와 보급 물약을 받았다. 셰스카는 대조할 보고서를 따로 쌓아 둔다.'
]);
scene('fma_home_spares','떠날 준비에 보태거나 돌아올 몫을 남길 수 있다.',[
 '소모품 값을 내고 피나코와 돌아올 때 쓸 몫을 남겼다. 오래 버티려면 지금 가져갈 것뿐 아니라 다음에 기대어 쓸 자리도 챙기는 법을 배웠다. 윈리는 가방을 다시 닫고 문 쪽으로 옮긴다.',
 '윈리와 더 넓은 시험 구역에서 살필 움직임을 짚었다. 작은 어긋남을 덜고 힘을 모을 준비를 배운 대신 개인 사냥의 적 수가 늘었다. 피나코는 집에 남길 상자를 따로 두었다.',
 '떠날 상자와 집에 남길 상자를 나누어 준비 작업 보수를 받았다. 보급 물약도 챙겼다. 에드워드가 먼저 문을 열고 윈리는 마지막 가방을 들어 올린다.'
]);
scene('fma_butcher_counter','무게를 나눌 작업과 바깥 시험 중 맡을 일을 정한다.',[
 '작업 준비물 값을 내고 시그와 무게가 흔들리지 않을 잡는 자리를 찾았다. 한 번에 힘을 쏟기보다 힘을 모아 쓰는 법을 배웠다. 시그는 작은 묶음을 다시 저울에 올리고 고개를 끄덕인다.',
 '이즈미와 더 강한 상대가 있는 구역을 맡았다. 주변을 살피며 다음 동작을 잇는 준비를 배웠고 개인 사냥의 적 단계가 올라갔다. 에드워드는 무게만 들면 되는 줄 알았다며 저울을 다시 본다.',
 '작은 주문을 분류하고 시그에게 작업 보수와 보급 물약을 받았다. 큰 묶음은 가게 안쪽에 남았다. 이즈미는 에드워드에게 저울의 움직임부터 보라고 한다.'
]);
scene('fma_ling_lunch','식사비를 거들거나 다른 준비와 가게 일을 맡는다.',[
 '식사비 180골드를 거들고 린과 공격 뒤에 멈추지 않을 발걸음을 맞췄다. 공격을 이어 가며 버티고 움직일 여유를 찾는 요령을 배웠다. 린은 빈 접시를 밀어 두고 다음 길을 가리킨다.',
 '에드워드와 더 강한 적이 드나드는 길을 맡았다. 상대를 무너뜨릴 곳을 짚는 준비를 배우고 개인 사냥의 적 단계가 올라갔다. 알폰스는 계산서를 린 앞으로 다시 놓는다.',
 '보급에 100골드를 쓰고 물약 두 개를 챙겼다. 맡을 길목을 한 곳 줄여 개인 사냥의 적 수를 줄였다. 린의 식사비는 식탁 위에 남겨 두었다.',
 '빈 접시를 옮기고 가게 주인에게 작업 보수를 받았다. 린이 계산서를 접으려 하자 에드워드가 손으로 눌러 둔다. 알폰스는 식탁 옆에서 둘을 기다린다.'
]);
scene('fma_flame_supplies','화력 준비와 통행 표시, 운반 중 맡을 일을 고른다.',[
 '재료 값을 내고 로이와 강한 상대를 겨누기 전에 힘을 모을 순서를 짚었다. 서둘러 불씨부터 내기보다 집중할 지점을 고르는 준비를 배웠다. 리자는 사람들이 지나갈 선을 다시 확인한다.',
 '표시 도구 값을 내고 리자와 공격할 선 앞을 비워 둘 위치를 짚었다. 정확한 방향과 짧은 틈을 고르는 준비를 배웠다. 하보크는 아직 남은 상자를 안쪽으로 옮긴다.',
 '운반 상자를 나누어 놓고 준비 담당자에게 군무 작업 보수를 받았다. 로이와 리자는 각자 맡을 준비를 이어 간다. 하보크는 마지막 상자를 가리키며 한 번만 더 부탁한다.'
]);
scene('fma_pie_delivery','불확실한 연락을 맡을지, 확인된 포장만 도울지 고른다.',[
 '포장과 연락에 120골드를 쓰고 겹친 이름을 구분할 수 있었다. 휴즈와 놓친 부분을 한 번 더 살피는 요령을 배우고 준비 작업 보수 200골드와 보급 물약 하나를 받았다. 그레이시아는 표시가 나뉜 상자부터 따로 놓는다.',
 '확인된 포장 값을 내고 알폰스와 상자를 들었을 때 무너지지 않을 자세를 짚었다. 발을 놓고 버티는 준비를 배웠다. 겹친 이름의 연락은 휴즈에게 남긴다.',
 '배달 연락은 맡지 않고 빈 포장 상자를 정리했다. 그레이시아에게 작업 보수를 받았다. 알폰스는 아직 나뉘지 않은 표시를 다시 가리킨다.'
]);
const merged={...current,cards:[...current.cards,...fixed.cards],events:[...current.events,...events]};
merged.canonBoundary+=' 추가된 반려견 기다림·가족 사진·귀가 보급·정육점 무게·식사 계산·발화포 준비·파이 표시 문제는 공식 인물의 생활에서 별도로 창작했다. 휴즈는 생전, 하보크는 부상 전의 서로 독립된 만남이다. 모든 사건이 본편 같은 시각·장소에 일어났다고 주장하지 않는다. 알폰스는 먹지 않으며 흡수는 린의 원작 흡혈 능력이 아니다.';
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(merged);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
fs.writeFileSync(path.join(root,'revisions/amestris-expansion-curated-13.json'),JSON.stringify(merged,null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(root,'revisions/amestris-expansion-curation-13.json'),JSON.stringify({sourceRevision:'6d4b0d8',raw:'drafts/amestris-expansion-text-12.json',changes,check,notes:['독립7사건·관련6카드다. 제목과 모든 수치·참조·기존 콘텐츠는 유지한다.','Gemma의 초안은 인물별 짧은 반응에는 활용했으나 결과 문장이 추상적이고 지정 능력과 필드 변화·비용·보급을 누락해 전부 재작성했다.']},null,2)+'\n',{flag:'wx'});
const request={review:true,system:'한국어 독립 검토자다. JSON {verdict,issues:[{key,problem,evidence,suggestion}],strengths:[string]}로 실제 모순만 지적한다. 문제가 없는 항목은 issues에 넣지 않는다. 맵 수치가 원작 고유 능력이라는 전제로 검토하지 않는다.',brief:{sourceFacts:fixed.sourceFacts,newContent:{cards:fixed.cards,events},mechanics:'독립 사건7개. 비용과 필드 단계·수는 먼저 적용. 성공 때만 지정 카드·골드·물약. 파이70% 성공은120비용후 휴즈카드200보수물약1, 실패는비용만. 이미 소지 카드100골드. 적 단계1..5·수1..10. 현재체력비용없고 최대체력카드는 비율 보존. 흡수는 실제 공격 피해 기반의 회복 인스턴스, 재생과 합산 최대체력10%/초이며 물약은 별도. 이동피해는 실제 속도400대비%로 환산하며 계속 걸어야 켜지는 조건이 아니다.',questions:['알폰스가 먹거나 휴즈·하보크가 사후·부상 후를 성공적으로 뒤집는가?','새 불꽃·총기·오토메일·군대·반려견 전투·현재 체력치료를 약속하는가?','지정 카드와 cost/gold/potions/level/density·확률 결과가 서로 모순인가?','서로 다른 생활 문제가 기존 정비·수련·도서관의 제목만 바꾼 복사인가?']}};
fs.writeFileSync(path.join(root,'requests/amestris-expansion-review-13.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({cards:merged.cards.length,events:merged.events.length,check}));
