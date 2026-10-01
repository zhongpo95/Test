// 아비도스 재집필의 칭찬 반복과 누락된 필드 변화를 인물별 실제 행동으로 다듬는다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const fixed=JSON.parse(fs.readFileSync(path.join(root,'requests/abydos-expansion-fixed-14.json'),'utf8'));
const draft=JSON.parse(fs.readFileSync(path.join(root,'drafts/abydos-expansion-text-15.json'),'utf8')).parsed;
const current=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/03-abydos.json'),'utf8'));
assert.deepEqual(draft.events.map(e=>e.key),fixed.events.map(e=>e.key));
const changes=[];function edit(obj,field,value,key,reason){changes.push({key,field,before:obj[field],after:value,reason});obj[field]=value;}
const events=fixed.events.map((p,i)=>{assert.equal(draft.events[i].choices.length,p.choices.length);return {key:p.key,title:p.title,story:draft.events[i].story,intro:draft.events[i].intro,previous:null,previousChoice:0,requiredCard:null,choices:p.choices.map((b,j)=>({label:draft.events[i].choices[j].label,result:draft.events[i].choices[j].result,card:b.card,card2:b.card2,gold:b.gold,cost:b.cost,level:b.level,density:b.density,potions:b.potions,chance:b.chance})),failure:p.failure||null,canonFact:p.canonFact,uncertain:[]};});
function scene(key,intro,rs){const x=events.find(e=>e.key===key);edit(x,'intro',intro,key,'추상적인 효율 평가 대신 실제 맡을 일을 안내한다.');rs.forEach((r,i)=>edit(x.choices[i],'result',r,key+'#'+(i+1),'모든 NPC의 감탄·깊은 신뢰·고마움 반복을 덜고 인물 반응과 비용·카드 준비·개인 몹 단계·수·보수·물약을 연결한다. 안전 경로 보장과 실제 NPC 호위는 약속하지 않는다.'));}
scene('abydos_pace','박자를 맞출지, 더 넓은 길목을 맡을지 정한다.',[
 '준비 도구 값을 내고 시로코와 다음 동작을 늦추지 않을 박자를 맞췄다. 반복해서 마주칠 상대를 넘기는 준비도 배웠다. 세리카는 지도에 표시된 한 바퀴 끝을 손가락으로 다시 짚는다.',
 '시로코와 더 넓은 길목을 맡으며 움직일 자리를 먼저 보는 요령을 배웠다. 맡을 범위가 늘어 개인 사냥의 적 수가 많아졌다. 시로코는 지도를 접고 짧게 출발하자고 한다.',
 '보급에 100골드를 쓰고 물약 하나를 챙겼다. 더 약한 구역을 맡아 개인 사냥의 적 단계가 낮아졌다. 세리카는 그 구역의 표시만 따로 남겨 둔다.',
 '표시 도구를 정리하고 준비 담당자에게 작업 보수를 받았다. 세리카가 남은 도구 수를 장부에 적는다. 시로코는 아직 정하지 않은 바깥 경로를 가리킨다.'
]);
scene('abydos_sleepchair','앞에 설 자리를 준비하거나 맡을 길목을 나눈다.',[
 '준비 비용을 내고 호시노와 몸 상태를 지킨 채 앞에 설 자리를 짚었다. 버티면서 다음 공격을 준비하는 요령을 배웠다. 호시노는 비워진 의자 앞을 보고 가방을 옆으로 당긴다.',
 '노노미와 더 넓은 길목에서 반복해서 마주칠 상대를 짚었다. 공격을 넓게 준비하는 요령을 배운 대신 개인 사냥의 적 수가 늘었다. 노노미는 호시노가 일어날 자리를 하나 남긴다.',
 '맡을 길목을 한 곳 줄여 개인 사냥의 적 수를 줄였다. 가방 정리 보수를 받고 아야네에게 나눈 구역을 전달했다. 호시노는 의자 등받이에 다시 몸을 기댄다.'
]);
scene('abydos_snack_share','지금 나눌 몫과 다음에 쓸 기록 중 맡을 일을 고른다.',[
 '포장 비용을 보태고 노노미와 빠뜨린 몫을 살폈다. 다음 싸움과 오래 움직일 보급을 챙기는 요령을 배웠다. 노노미가 마지막 봉투를 내밀자 세리카는 장부도 봐 달라며 주문서를 당긴다.',
 '기록용품 값을 내고 아야네와 남은 항목을 대조했다. 얻을 몫을 놓치지 않고 여러 부탁을 더 비교하는 준비를 배웠다. 아야네는 아직 확인하지 않은 항목에는 숫자를 적지 않는다.',
 '빈 상자를 나누고 준비 담당자에게 작업 보수와 보급 물약을 받았다. 세리카는 정리한 수량을 적고 노노미는 남은 간식 봉투를 모은다.'
]);
scene('abydos_antique_note','불확실한 기록 확인과 확실한 장부 정리 중 정한다.',[
 '연락 비용 150골드를 쓰고 지워진 항목의 이전 기록을 확인했다. 아야네와 빠뜨린 수급과 비교할 항목을 살피는 요령을 배우고 가게 주인에게 기록 확인 보수 230골드를 받았다. 아야네는 확인한 숫자만 빈칸에 옮긴다.',
 '기록용품 값을 내고 아야네와 확인된 항목만 나누었다. 얻을 몫과 더 비교할 후보를 살피는 준비를 배웠다. 지워진 항목은 확인되지 않았다는 표시로 남겨 둔다.',
 '기록 확인은 맡지 않고 가게의 빈 상자만 정리했다. 가게 주인에게 작업 보수를 받았다. 아야네는 지워진 항목 옆에 물음표를 남긴다.'
]);
scene('abydos_aquarium_step','외출 전에 앞에 설 자리와 귀환길의 부담을 나눈다.',[
 '준비 비용을 내고 호시노와 몸 상태를 지킨 채 앞에 설 위치를 짚었다. 버티면서 다음 공격을 준비하는 요령을 배웠다. 호시노는 안내판 쪽으로 몸을 돌리고 아야네는 남은 보급 일을 적는다.',
 '시로코와 더 강한 적이 드나드는 귀환길을 맡았다. 움직일 자리를 먼저 보는 요령을 배우고 개인 사냥의 적 단계가 올라갔다. 시로코는 돌아갈 길의 표시를 따로 접어 둔다.',
 '맡을 길목을 한 곳 줄여 개인 사냥의 적 수를 줄였다. 안내 정리 담당자에게 작업 보수와 보급 물약을 받았다. 호시노는 어디서 다시 만날지 안내판의 한 지점을 가리킨다.'
]);
scene('abydos_peroro_line','부탁을 들을지, 가져갈 몫과 통행 구역을 나눌지 정한다.',[
 '진열 준비물 값을 내고 히후미와 부탁을 하나씩 들었다. 더 비교할 후보를 놓치지 않고 오래 버틸 준비를 배웠다. 히후미는 진열된 페로로를 다시 보다가 아직 남은 사람 쪽으로 고개를 돌린다.',
 '포장 비용을 보태고 노노미와 가져갈 몫을 나누었다. 다음 싸움과 오래 움직일 보급을 챙기는 요령을 배웠다. 노노미는 기다리는 사람의 봉투도 한쪽에 남겨 둔다.',
 '히후미와 맡을 길목을 한 곳 줄였다. 움직일 자리를 찾고 버티는 요령을 배웠고 개인 사냥의 적 수가 줄었다. 시로코는 줄인 구역 바깥의 표시를 지운다.',
 '진열 상자를 정리하고 가게 주인에게 작업 보수를 받았다. 히후미는 아직 들을 부탁을 적고 노노미는 포장할 몫을 모은다.'
]);
const merged={...current,sources:[...new Set([...current.sources,...fixed.sourceFacts.map(s=>s.source)])],cards:[...current.cards,...fixed.cards],events:[...current.events,...events]};
merged.canonBoundary+=' 조깅·낮잠·간식·골동품·수족관 안내·굿즈 문제는 공식 취미와 역할에서 별도로 창작했다. 학교 일상이 이어지던 때의 독립 만남이며 같은 시각의 본편 전개나 실종 해결을 주장하지 않는다. 골동품70%는 맵의 검사 수치이고 히후미는 트리니티 학생이다. 고체력 피해는 즉시 치료가 아니며 후보 증가는 행동력 증가가 아니다.';
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(merged);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
fs.writeFileSync(path.join(root,'revisions/abydos-expansion-curated-16.json'),JSON.stringify(merged,null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(root,'revisions/abydos-expansion-curation-16.json'),JSON.stringify({sourceRevision:'3d32249',raw:'drafts/abydos-expansion-text-15.json',changes,check,notes:['재집필에서 효과 수치 오인은 없어졌지만 칭찬 반복·필드 변화 누락을 그대로 쓰지 않는다.','원안의 신규 카드5장·사건6개 수치와 모든 기존 콘텐츠는 유지한다.']},null,2)+'\n',{flag:'wx'});
const request={review:true,system:'한국어 독립 검토자다. JSON {verdict,issues:[{key,problem,evidence,suggestion}],strengths:[string]}로 원작·수치·행동의 실제 모순만 지적한다. 문제가 없는 항목은 issues에 넣지 않는다. 맵 각색 능력치를 원작의 고유 기술이라고 오해하지 않는다.',brief:{sourceFacts:fixed.sourceFacts,newContent:{cards:fixed.cards,events},mechanics:'독립6사건. cost/level/density는먼저, 성공때card/gold/potions. 골동품70%성공150비용후카드230보수,실패비용만. 소지카드100골드. 고체력피해는높은체력에서피해증가이며14회복아님. 사건후보+1은화면후보만추가·행동력없음. 신속180은고정수치. 이동피해는실제속도400대비환산·움직임여부아님. 현재체력비용없음. 재생은최대체력%/초·흡수합산10%한도·물약별도. 맵NPC호위·굿즈장비·즉시회복·학교빚전액청산없음.',questions:['효과 오인·알려지지 않은 원작 취미·히후미 소속·호시노 실종 해결이 있는가?','표시한 카드·비용·보수·물약·개인 몹 강함과 수가 결과와 맞는가?','시로코 운동/호시노 낮잠/노노미 간식/아야네 골동품/수족관/히후미 굿즈 상황이 기존 사막 정찰과 라멘 가게의 이름만 바꾼 반복인가?']}};
fs.writeFileSync(path.join(root,'requests/abydos-expansion-review-16.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({cards:merged.cards.length,events:merged.events.length,check}));
