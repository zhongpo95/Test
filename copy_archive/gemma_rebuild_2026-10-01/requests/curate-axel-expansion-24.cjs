// 액셀 초안의 반복 준비 상황과 누락된 성장 결과를 인물별 사건으로 다듬는다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const fixed=JSON.parse(fs.readFileSync(path.join(root,'requests/axel-expansion-fixed-23.json'),'utf8')),draft=JSON.parse(fs.readFileSync(path.join(root,'drafts/axel-expansion-text-23.json'),'utf8')).parsed,current=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/02-axel.json'),'utf8'));
assert.deepEqual(draft.events.map(e=>e.key),fixed.events.map(e=>e.key));
const changes=[];function edit(obj,field,value,key,reason){if(obj[field]===value)return;changes.push({key,field,before:obj[field],after:value,reason});obj[field]=value;}
const events=fixed.events.map((p,i)=>{assert.equal(draft.events[i].choices.length,p.choices.length);return {key:p.key,title:p.title,story:draft.events[i].story,intro:draft.events[i].intro,previous:null,previousChoice:0,requiredCard:null,choices:p.choices.map((b,j)=>({label:draft.events[i].choices[j].label,result:draft.events[i].choices[j].result,card:b.card,card2:b.card2,gold:b.gold,cost:b.cost,level:b.level,density:b.density,potions:b.potions,chance:b.chance})),failure:p.failure||null,canonFact:p.canonFact,uncertain:[]};});
function scene(key,story,intro,labels,results){const x=events.find(e=>e.key===key);edit(x,'story',story,key,'공식 인물 특징을 유지하면서 상자·안내표 정리만 반복하는 초안 대신 인물별 갈등을 창작한다.');edit(x,'intro',intro,key,'문제와 맡을 행동을 요약한다.');labels.forEach((v,i)=>edit(x.choices[i],'label',v,key+'#'+(i+1),'행동을 새 장면과 맞춘다. 고정 수치와 카드 참조는 유지한다.'));results.forEach((v,i)=>edit(x.choices[i],'result',v,key+'#'+(i+1),'누락된 비용·보수·배운 성장·지속되는 개인 사냥 변화를 밝힌다. NPC 전투 승리를 플레이어 성장으로 대신하지 않는다.'));}
scene('axel_party_water',
 '아쿠아가 물을 쓰는 연회 재주를 보여 주겠다며 자리를 잡는다. 카즈마는 바로 옆에 모험가들의 짐이 쌓였는데도 박수부터 바라느냐고 타박하고, 루나는 젖으면 곤란한 짐을 먼저 나누자고 한다. 아쿠아는 자리를 비우면 더 멋진 것을 보여 줄 수 있다고 물러서지 않는다.',
 '공연 자리를 도울지, 밖의 일을 맡을지 정한다.',
 ['천과 그릇 값을 보태고 아쿠아와 물자리를 나눈다','카즈마와 적이 많은 바깥 길목을 맡는다','공연 자리의 짐을 옮기고 보수와 물약을 받는다'],
 ['천과 그릇 값160골드를 내고 젖어도 되는 자리와 짐 둘 자리를 나눴다. 아쿠아와 여러 부탁을 비교하며 오래 움직일 습관을 익혔다. 아쿠아는 짐이 빠진 자리를 보더니 이제 박수를 칠 준비도 됐냐고 묻는다.',
  '카즈마와 더 많은 적이 오가는 바깥 길목을 맡았다. 빈틈을 노리고 얻을 몫을 놓치지 않는 요령을 배웠고 개인 사냥의 적 수가 늘었다. 카즈마는 안에서 박수만 치는 것보다는 벌이가 있어야 한다며 너와 맡을 자리를 나눈다.',
  '공연 자리의 짐을 옮기고 루나에게 작업 보수130골드와 물약 하나를 받았다. 아쿠아는 짐을 어디로 옮겼는지보다 공연을 보고 갈 것인지 먼저 묻고 카즈마는 빈 자리에 다시 짐을 놓지 말자고 한다.']);
scene('axel_small_figure',
 '다크니스가 귀여운 진열품 앞에서 멈추는 바람에 뒤의 사람들이 지나가지 못한다. 크리스가 슬쩍 옆으로 비키라고 하자 다크니스는 관심 없는 척하다가 같은 물건을 다시 본다. 카즈마는 갑옷을 입고 서 있으면 작은 물건보다 네가 더 눈에 띈다고 말한다.',
 '작은 진열품 앞의 정체를 풀어 보자.',
 ['포장 용품을 마련해 다크니스와 진열품을 나눈다','다크니스와 적이 많은 바깥 자리를 맡는다','크리스와 담당 길목을 줄이고 진열을 정리한다'],
 ['포장 용품 값180골드를 내고 작은 진열품을 나눴다. 다크니스와 몸 상태를 지키며 싸움을 이어 갈 요령을 익혔다. 포장이 끝나자 다크니스는 남은 작은 물건도 살펴보고 크리스는 이번에는 길부터 비키라고 웃는다.',
  '다크니스와 더 많은 적이 드나드는 바깥 자리를 맡았다. 오래 버틸 준비를 배웠지만 공격의 부담도 남고 개인 사냥의 적 수가 늘었다. 다크니스는 진열품을 다시 보고 싶어 하면서도 먼저 맡을 자리를 가리킨다.',
  '크리스와 담당 길목을 한 곳 줄여 개인 사냥의 적 수를 줄였다. 진열 정리 보수140골드를 받고 자리를 비웠다. 크리스는 다크니스가 같은 물건 앞에 다시 멈추기 전에 돌아갈 쪽부터 알려 준다.']);
scene('axel_rival_target',
 '융융이 여러 공격을 연습할 표적을 가져왔는데 메구밍은 폭렬 마법 하나로 끝낼 수 있는 자리를 고른다. 융융은 먼저 작은 표적의 간격도 보자고 하고 메구밍은 큰 자리부터 보자고 맞선다. 카즈마는 연습 전에 둘이 같은 표적을 노리지 않도록 네가 맡을 쪽을 정하라고 한다.',
 '한 번의 큰 공격과 여러 공격의 간격을 비교한다.',
 ['도구 값을 내고 융융과 작은 표적의 간격을 짚는다','메구밍과 더 강한 적이 접근하는 자리를 맡는다','맡을 구역을 줄이고 표적 정리 보수와 물약을 받는다'],
 ['연습 도구 값200골드를 내고 융융과 표적 간격을 짚었다. 힘을 모으면서 주변도 살피는 공격 요령을 익혔다. 융융은 다른 공격도 준비할 수 있다며 아직 남은 표적을 보여 주고 메구밍은 큰 자리를 다시 가리킨다.',
  '메구밍과 더 강한 적이 접근하는 자리를 맡았다. 큰 공격에 힘을 모으는 요령을 배운 대신 다음 동작의 부담이 남고 개인 사냥의 적 단계가 올라갔다. 메구밍은 폭렬 마법을 쓸 때까지 작은 표적도 남겨 두겠냐고 묻는다.',
  '담당 구역을 줄여 개인 사냥의 적 수를 줄였다. 표적 정리 보수120골드와 물약 하나를 받았다. 융융은 남겨 둔 표적을 다시 모으고 카즈마는 둘의 연습 순서가 아직 끝나지 않았다고 말한다.']);
scene('axel_sword_introduction',
 '미츠루기가 아쿠아에게 마검 그람의 이름부터 설명하려는데 크리스는 검보다 먼저 어느 쪽을 맡을지 묻는다. 카즈마는 소개를 듣는 동안 바깥 길목은 누가 볼 것이냐고 끼어든다. 아쿠아가 자기를 위한 설명이 얼마나 남았냐고 묻자 미츠루기는 다시 자세를 고쳐 선다.',
 '검의 이름을 듣기 전에 맡을 자리를 정한다.',
 ['표시 용품을 마련해 미츠루기와 공격 방향을 짚는다','크리스와 적이 많은 바깥 길목을 맡는다','길목의 표시물을 옮기고 작업 보수를 받는다'],
 ['표시 용품 값220골드를 내고 미츠루기와 큰 상대를 향한 공격 방향을 짚었다. 공격 위치와 힘을 실을 순간을 고르는 요령을 익혔다. 미츠루기는 자세 설명을 마치자 다시 그람의 이름을 말하려 하고 카즈마는 맡을 쪽이 먼저 정해졌다며 돌아선다.',
  '크리스와 더 많은 적이 드나드는 바깥 길목을 맡았다. 빠르게 움직이며 공격 방향을 고르는 요령을 익혔고 개인 사냥의 적 수가 늘었다. 크리스는 미츠루기의 소개가 끝나기를 기다리면 늦겠다며 갈 쪽을 먼저 짚는다.',
  '길목의 표시물을 옮기고 작업 보수150골드를 받았다. 크리스가 빈 길을 확인하는 사이 미츠루기는 아쿠아에게 소개를 계속하고 카즈마는 돌아와도 아직 같은 이야기를 듣겠냐고 한다.']);
scene('axel_newcomer_questions',
 '새 모험가가 루나에게 어느 길로 나가야 하냐고 묻다가, 적을 만나면 누구에게 물어야 하냐고 다시 묻는다. 길드에서 늘 모험가를 맞는 거친 남자는 일단 들어올 자리부터 비우자고 한다. 카즈마는 창구에서 답을 듣는 일과 바깥의 강한 적을 확인하는 일을 한 사람이 전부 맡지 말자고 한다.',
 '신참의 다음 질문까지 맡을지, 바깥을 맡을지 정한다.',
 ['기록용품을 마련해 루나와 신참의 질문을 나눈다','카즈마와 더 강한 적이 오가는 안내 길목을 맡는다','담당 길목을 줄이고 안내 정리 보수를 받는다'],
 ['기록용품 값180골드를 내고 루나와 신참의 질문을 나누었다. 여러 부탁과 얻을 몫을 확인하며 오래 움직일 습관을 익혔다. 첫 질문이 끝나자 신참은 다음에 물어볼 일도 적어 놓고 루나는 한꺼번에 답하려 하지 말자고 한다.',
  '카즈마와 더 강한 적이 오가는 안내 길목을 맡았다. 빈틈과 얻을 몫을 놓치지 않는 요령을 익힌 대신 개인 사냥의 적 단계가 올라갔다. 카즈마는 운에만 맡기지 말고 돌아올 길도 확인하자며 신참이 질문한 쪽을 짚는다.',
  '담당 길목을 한 곳 줄여 개인 사냥의 적 수를 줄였다. 안내 정리 보수130골드를 받고 신참이 돌아올 쪽을 표시했다. 루나는 아직 남은 질문을 받아 적고 거친 남자는 다음 모험가가 들어올 자리를 비운다.']);
const merged={...current,sources:[...new Set([...current.sources,...fixed.sourceFacts.map(s=>s.source)])],cards:[...current.cards,...fixed.cards],events:[...current.events,...events]};
merged.canonBoundary+=' 연회 자리·귀여운 진열품·서로 다른 표적 연습·검 자기소개·신참의 질문은 공식 인물 성격에서 별도 창작했다. 환영하는 거친 남자를 길드 직원으로 단정하지 않는다. 그람·새 마법·인형 장비·NPC 동행·자동 의뢰 완수·부활은 지급하지 않는다. 물 공연과 NPC 행동은 사건 글이며 추가 필드 전투나 미니게임이 아니다.';
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(merged);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
fs.writeFileSync(path.join(root,'revisions/axel-expansion-curated-24.json'),JSON.stringify(merged,null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(root,'revisions/axel-expansion-curation-24.json'),JSON.stringify({sourceRevision:'3dc7c81',raw:'drafts/axel-expansion-text-23.json',changes,check,notes:['신규5사건·5카드의 고정 수치와 기존 콘텐츠는 유지한다.','반복 준비 상자·추측한 길드 직원·NPC 전투 성공·상대 제어 도구를 미채택하고 인물별 장면과 실제 성장 결과로 바꾼다.']},null,2)+'\n',{flag:'wx'});
const schema=JSON.parse(fs.readFileSync(path.join(root,'requests/mitakihara-expansion-review-20.json'),'utf8')).schema;
const request={review:true,schema,system:'한국어 독립 검토자다. verdict는 PASS 또는 REVISE. 원작·수치·행동의 실제 모순만 issues에 쓴다. 창작 상황과 성장 비유를 원작 기술로 오해하지 않는다. 문제 없는 항목은 넣지 않는다.',brief:{sourceFacts:fixed.sourceFacts,newContent:{cards:fixed.cards,events},mechanics:'독립5사건. cost/level/density먼저, 성공card/gold/potions. 현재체력지불없음. 소지카드100골드. 재생흡수합산10%/초물약별도. 새마법·그람·인형장비·NPC동행·미니게임없음. 소개와 공연은 글의 장면. 본편승리나운명변경없음.',questions:['공식 성격·친구 관계·연회 재주·마검·길드 환영 역할과 충돌하는가?','비용·개인 적 변화·해당 카드 효과가 결과와 일치하는가?','다섯 사건이 이름만 다른 보급 상자 정리로 반복되는가?']}};
fs.writeFileSync(path.join(root,'requests/axel-expansion-review-24.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({cards:merged.cards.length,events:merged.events.length,check}));
