// 사건 중 실제 사냥이 끝났다는 문장을 바로잡고 액셀의 결과와 체력 설명을 재검토한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const draft=read('drafts/axel-expansion-text-49.json').parsed,fixed=read('requests/axel-expansion-fixed-49.json');
const current=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/02-axel.json'),'utf8'));
assert.deepEqual(draft.events.map(e=>e.key),fixed.events.map(e=>e.key));
const changes=[],edit=(o,k,v,key,reason)=>{if(o[k]===v)return;changes.push({key,field:k,before:o[k],after:v,reason});o[k]=v;};
const events=fixed.events.map((p,i)=>{assert.equal(draft.events[i].choices.length,p.choices.length);return {key:p.key,title:p.title,story:draft.events[i].story,intro:draft.events[i].intro,previous:p.previous||null,previousChoice:p.previousChoice||0,requiredCard:null,choices:p.choices.map((b,j)=>({label:draft.events[i].choices[j].label,result:draft.events[i].choices[j].result,card:b.card,card2:b.card2,gold:b.gold,cost:b.cost,level:b.level,density:b.density,potions:b.potions,chance:b.chance})),failure:p.failure||null,canonFact:p.canonFact,uncertain:[]};});
const intros=['해명하는 말과 끌어올리는 손 중 어디에 힘을 보탤까?','더 쫓아갈 발걸음과 돌아올 보급 중 무엇을 맡을까?','남은 질문을 마칠까, 밖의 준비를 맡을까?','아직 열린 문이 없다. 먼저 무엇을 확인할까?','우리를 내려놓기 전, 손을 언제 뗄 수 있을까?'];
const results=[
 ['줄 고정용품 값 180골드를 내고 우리를 끌어올릴 때까지 손을 놓지 않았다. 끝까지 버틴 기억으로 최대 체력이 늘고 받는 피해가 줄었다. 아쿠아는 물 밖으로 나왔지만 손을 뗄 자리부터 찾으라고 외친다.',
  '구경꾼에게 정화 의뢰와 우리를 쓰는 이유를 설명하고 더 많은 개인 사냥을 맡는 부담을 택했다. 의뢰받은 일을 확인하는 기억으로 일반 몬스터에게 가하는 피해와 지속 체력 재생이 늘었다. 카즈마는 설명이 끝난 손도 줄을 잡을 수 있냐고 묻는다.',
  '물가의 짐을 옮긴 보수로 100골드와 물약 1개를 받았다. 카즈마는 짐 때문에 가려졌던 줄을 다시 볼 수 있게 되었고 아쿠아는 이제 끌어올릴 차례라고 재촉한다.'],
 ['길 표시 용품 값 180골드를 내고 겹친 발자국 사이에 돌아올 표식을 남겼다. 추격의 발걸음을 기억해 이동속도와 일반 몬스터에게 가하는 피해가 늘었다. 카즈마는 멀어진 정령과 네가 남긴 표식을 번갈아 본다.',
  '추격의 발걸음을 기억하는 대신 개인 사냥의 적 수를 늘리는 부담을 택했다. 이동속도와 일반 몬스터에게 가하는 피해가 늘었다. 아쿠아는 네가 돌아올 표식을 가리키며 그쪽까지 놓치지 말라고 말한다.',
  '돌아올 짐을 운반한 보수로 140골드와 물약 1개를 받았다. 카즈마는 한 번 더 저쪽을 가리키다가 네가 준비한 짐도 확인한다.'],
 ['시범 소모품 값 200골드를 내고 내 질문을 끝까지 마쳤다. 질문과 시범이 끝날 때를 기다린 기억으로 차지 준비 속도와 비방향 공격 피해가 늘었다. 위즈는 답하던 손을 다시 들고 아쿠아는 아직 문밖의 의뢰를 가리킨다.',
  '더 강한 개인 사냥을 맡는 부담을 택하고 위즈의 남은 설명을 들었다. 준비의 끝을 기다린 기억으로 차지 준비 속도와 비방향 공격 피해가 늘었다. 카즈마는 자기가 아직 못 들은 다음 부분도 있냐고 묻는다.',
  '문밖의 보급품을 운반한 보수로 150골드와 물약 1개를 받았다. 아쿠아에게는 무엇을 가져왔는지 전했고 가게 안에서는 위즈와 카즈마의 질문이 아직 이어진다.'],
 ['의뢰 안내를 마련한 값 170골드를 내고 문턱을 대조했다. 의뢰받은 곳부터 확인한 기억으로 일반 몬스터에게 가하는 피해와 지속 체력 재생이 늘었다. 아쿠아는 먼저 본 창문에서 문 쪽으로 시선을 옮긴다.',
  '위즈와 바깥의 발자국을 살피고 더 강한 개인 사냥을 맡는 부담을 택했다. 끝까지 설명을 듣고 준비한 기억으로 차지 준비 속도와 비방향 공격 피해가 늘었다. 위즈는 흔적만으로 집 안의 주인을 안다고 단정하지 않고 다시 문을 본다.',
  '가져온 보급품을 전달한 보수로 120골드와 물약 2개를 받았다. 카즈마는 먼저 의뢰인이 문을 열어야 한다고 다시 말하고 아쿠아는 창문과 닫힌 문을 함께 살핀다.'],
 ['받침 값 150골드를 내고 내려놓는 때를 맞춰 줄에서 손을 뗐다. 카즈마와 짧은 준비의 끝을 기다린 기억으로 이동속도와 차지 준비 속도가 늘었다. 아쿠아는 받침을 보자 다시 물속에 넣는 용도는 아니냐고 묻는다.',
  '발 디딜 자리와 줄을 직접 확인하는 대신 더 많은 개인 사냥을 맡는 부담을 택했다. 손을 뗄 때를 기다린 기억으로 이동속도와 차지 준비 속도가 늘었다. 카즈마는 네 손이 움직이자 아쿠아가 나설 자리도 다시 본다.',
  '물가의 짐을 반환한 보수로 160골드와 물약 1개를 받았다. 구경꾼에게는 아직 줄을 잡은 사람이 있다고 전했고 아쿠아는 밖으로 나설 자리를 계속 묻는다.']
];
events.forEach((e,i)=>{edit(e,'intro',intros[i],e.key,'고정안의 마지막 문장을 반복하거나 구현 제약을 설명하는 대신 당장의 문제를 짧게 요약한다.');e.choices.forEach((c,j)=>edit(c,'result',results[i][j],e.key+'#'+(j+1),'사건 중 몬스터나 정령을 추가 처치했다는 잘못된 완료를 없애고 지속 개인 사냥의 조건 선택으로 바꾼다. 단위 없는 스탯 목록 대신 성장 기억·비용·보급과 인물에게 남은 행동을 연결한다.'));});
edit(events[2],'story','위즈가 카즈마의 질문에 답하려는데 아쿠아가 제령 의뢰가 왔다며 말을 끊는다. 카즈마는 아직 질문이 끝나지 않았다고 하고 위즈는 답하던 손을 멈춘 채 너도 무엇을 물으러 왔는지 묻는다. 네가 마치려던 질문은 아직 남았고 문밖에는 옮겨야 할 보급품도 기다리고 있다.',events[2].key,'플레이어에게 코드의 제약을 설명하는 마지막 문장을 실제 사건의 남은 문제로 바꾼다.');
const candidate={...current,sources:[...new Set([...current.sources,...fixed.sourceFacts.map(s=>s.source)])],cards:[...current.cards,...fixed.cards],events:[...current.events,...events]};
candidate.canonBoundary+=' 호수의 구경꾼·줄 고정과 받침·눈의 겹친 발자국·질문을 끝낼 방문·저택의 서로 다른 문턱은 공식 1기 5·7·8화 소개에서 각색한 독립 만남이다. 현재 체력의 추위 비용·겨울 장군 전투와 사망 결말·새 원작 기술·유령의 신원과 성불 방법은 추가하지 않는다. 사건 결과는 그 만남의 기억으로 카드 성장과 원정 개인 사냥 조건을 얻는 것이며 실제 NPC·정령·수중 전투·제령 주문·물가 장비가 생기지 않는다. 카드 지급 시 최대 체력이 늘면 기존 현재 체력 비율을 보존하며 물약처럼 체력 비율을 회복하는 효과는 아니다. 줄 후속은 자신이 고정용품을 마련한 성공1번에서만 열린다.';
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
write('revisions/axel-expansion-curated-50.json',candidate);write('revisions/axel-expansion-curation-50.json',{sourceRevision:'f09853c',raw:'drafts/axel-expansion-text-49.json',changes,check,numericExceptions:[],corrections:[{prior:'검토47의 요청/검사/문서에서 최대 체력 증가 뒤 현재7000 유지·65% 조건 미달',fact:'PlayerStatsSet 단독 호출 결과만 일반화했다. 실제 ProtoGrantCard → ProtoRefreshStats는 70%를 보존하므로 7560/10800이다. 원본 요청/응답/검사는 덮어쓰지 않고 검증50과 수정 문서를 별도로 남긴다.',evidence:'validation/card-health-grant-probe-50.json'}]});
write('requests/axel-expansion-review-50.json',{review:true,schema:read('requests/mitakihara-expansion-review-20.json').schema,system:'한국어 독립 검토자다. PASS 또는 REVISE로 판단한다. 원작으로 확인한 사실과 별도 창작, NPC 행동을 강제로 결정하는 선택과 플레이어의 자기 행동을 구분한다. 실제 모순만 issues에 적고 단순 취향이나 검증하지 않은 성공 확률의 밸런스를 오류라고 단정하지 않는다.',brief:{sourceFacts:fixed.sourceFacts,newContent:{cards:fixed.cards,events},mechanics:'사건 진입은 AP1. 개인 사냥은 정지 상태라 실제 추가 처치 없음. cost/level/density를 먼저 적용하고 성공시만 card/gold/potions 지급. 강함/수 변화는 지속 원정 사냥 조건이며 정령/유령/NPC가 실제적이 되지않음. 후속은자기앞선성공1번만.75%는성공일때카드,실패시150골드소모/AP1유지/보상없음.중복카드는100골드.현재체력비용없음.최대체력10%는실제ProtoRefreshStats에서기존현재/최대비율유지(7000/10000→7700/11000).물약처럼체력비율을높이는효과아님.위즈차지8은차지준비구간에만적용,비방향10은해당공격조건.아쿠아재생.3은최대체력.3%/초,흡수합계10%/초한도,물약별도.',questions:['원작의 겨울 장군과 카즈마의 죽음·호수 전체 정화·저택 전체 제령을 플레이어가 바꾸거나 완료했다고 쓰는가?','정지된 사건 중 정령 또는 몬스터를 실제로 사냥했다고 하는가?','지급 카드와 골드·물약·비용·개인 강함/수가 결과와 일치하는가?','현재 체력 비용·체력 비율 회복·새 주문·원작 무기·유령 신원을 추가하는가?','후속은 이미 소유를 보장받은 같은 카드를 성장 보상으로 다시 지급하는가?']}});
console.log(JSON.stringify({newCards:5,newRoots:4,newFollowups:1,check}));
