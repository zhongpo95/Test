// 미타키하라의 준비와 친구 관계를 실제 지정 카드·비용·필드 변화로 연결한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const fixed=JSON.parse(fs.readFileSync(path.join(root,'requests/mitakihara-expansion-fixed-19.json'),'utf8')),draft=JSON.parse(fs.readFileSync(path.join(root,'drafts/mitakihara-expansion-text-19.json'),'utf8')).parsed,current=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/05-mitakihara.json'),'utf8'));
assert.deepEqual(draft.events.map(e=>e.key),fixed.events.map(e=>e.key));
const changes=[];function edit(obj,field,value,key,reason){if(obj[field]===value)return;changes.push({key,field,before:obj[field],after:value,reason});obj[field]=value;}
const events=fixed.events.map((p,i)=>{assert.equal(draft.events[i].choices.length,p.choices.length);return {key:p.key,title:p.title,story:draft.events[i].story,intro:draft.events[i].intro,previous:null,previousChoice:0,requiredCard:null,choices:p.choices.map((b,j)=>({label:draft.events[i].choices[j].label,result:draft.events[i].choices[j].result,card:b.card,card2:b.card2,gold:b.gold,cost:b.cost,level:b.level,density:b.density,potions:b.potions,chance:b.chance})),failure:p.failure||null,canonFact:p.canonFact,uncertain:[]};});
function scene(key,intro,rs){const x=events.find(e=>e.key===key);edit(x,'intro',intro,key,'분위기나 긴장감 대신 현재 맡을 일을 짚는다.');rs.forEach((r,i)=>{if(r!==null)edit(x.choices[i],'result',r,key+'#'+(i+1),'결과에서 누락된 비용·카드 준비·보수·적 강함과 수를 실제로 연결한다. 다른 인물과 행동 주체를 바꾸거나 본편 운명·안전을 확정하지 않는다.');});}
scene('madoka_visit_music','쪽지의 제목을 확인할지, 가져갈 가방부터 나눌지 정한다.',[
 '연락 비용120골드를 쓰고 이전 목록에서 음악 제목을 찾았다. 사야카와 상대의 말을 끝까지 살피며 몸 상태를 지키고 힘을 싣는 준비를 배웠고 물품 담당자에게 확인 보수180골드를 받았다. 사야카는 제목을 적고도 가방을 바로 닫지 않는다.',
 '포장 용품 값을 내고 사야카와 문병 가방을 나누었다. 상대를 먼저 살피며 몸 상태를 지키고 공격할 순간을 고르는 준비를 배웠다. 마도카는 쪽지를 아직 확인하지 않았다는 표시로 가방 안에 남긴다.',null
]);
scene('madoka_home_morning','먼저 끝낼 일과 남겨 둘 몫 중 도울 준비를 고른다.',[
 '정리 용품 값을 보태고 준코와 먼저 할 일을 나누었다. 큰 상대를 앞두고 버틸 일과 힘을 쏟을 순간을 고르는 준비를 배웠다. 준코는 가방을 닫기 전에 마도카 쪽에 남길 봉투를 하나 빼놓는다.',
 '포장 용품 값을 내고 토모히사와 남겨 둘 몫을 챙겼다. 다음 일을 오래 이어 갈 보급 습관을 배웠다. 토모히사는 현관에 모인 봉투에 이름을 적고 아직 챙기지 않은 몫을 식탁에 남긴다.',
 '마도카와 더 많은 적이 오가는 바깥 배달 길목을 맡았다. 몸 상태를 지키고 버티며 공격할 준비를 배운 대신 개인 사냥의 적 수가 늘었다. 토모히사는 그 길목으로 가져갈 봉투만 나눈다.',null
]);
scene('madoka_afterclass_appts','약속 사이의 준비와 학교에 남은 안내 일을 나눈다.',[
 '표시 용품 값을 내고 히토미와 약속 사이에 준비할 일을 나누었다. 다음 동작과 차지 준비를 늦추지 않는 습관을 배웠다. 히토미가 가방을 챙기자 사야카는 같이 갈 수 있는 구간만 손가락으로 짚는다.',
 '마도카와 더 많은 적이 오가는 안내 길목을 맡았다. 오래 버티며 큰 상대에게 공격할 준비를 배웠고 개인 사냥의 적 수가 늘었다. 히토미는 함께 갈 수 없는 구간을 안내표에서 따로 접는다.',null
]);
scene('madoka_transfer_practice','교실 쪽의 준비와 바깥 구역 중 맡을 일을 정한다.',[
 '준비 용품 값을 내고 호무라와 다음 동작을 맞췄다. 공격할 자리를 넓게 보고 다음 동작을 늦추지 않는 요령을 배웠다. 사야카가 다시 물으려 하자 호무라는 아직 남은 도구를 먼저 가리킨다.',
 '호무라와 더 강한 적이 오가는 길목을 맡았다. 동작을 빠르게 준비하는 요령을 배웠고 개인 사냥의 적 단계가 올라갔다. 마도카는 끝나고 돌아올 자리를 확인해 두자고 한다.',
 '담당 구역을 한 곳 줄여 개인 사냥의 적 수를 줄였다. 남은 도구를 정리하고 준비 담당자에게 보수를 받았다. 호무라는 바깥의 표시만 따로 접어 들고 나간다.'
]);
scene('madoka_room_visit','들어갈 간격을 짚거나 바깥 길목을 맡는다.',[
 '표시 용품 값을 내고 마미와 적중할 위치와 물러설 자리를 짚었다. 맞을 부담을 줄이면서 공격 방향을 정하는 준비를 배웠다. 사야카는 어느 길부터 갈지 묻고 마도카는 돌아올 곳에 표시를 남긴다.',
 '마미와 더 많은 적이 오가는 바깥 길목을 맡았다. 여러 상황을 비교하며 버틸 준비를 배웠고 개인 사냥의 적 수가 늘었다. 마미는 다음에 맡을 범위를 지도에 남겨 둔다.',
 '담당 길목을 한 곳 줄여 개인 사냥의 적 수를 줄였다. 지도 정리 보수와 보급 물약을 받았다. 마도카는 줄인 구역을 접고 남은 돌아올 곳의 표시를 다시 본다.'
]);
scene('madoka_boundary_entrance','입구에 들어가기 전 확인할 구역을 나눈다.',[
 '확인 용품 값을 내고 마미와 들어갈 위치를 정했다. 공격 방향과 물러설 자리를 먼저 보며 맞을 부담을 줄이는 요령을 배웠다. 호무라는 확인하지 않은 안쪽을 그대로 남겨 두자고 한다.',
 '호무라와 더 강한 적이 오가는 바깥 구역을 맡았다. 다음 동작을 빠르게 준비하는 요령을 배운 대신 개인 사냥의 적 단계가 올라갔다. 마도카는 확인한 바깥 흔적만 지도에 적는다.',
 '더 약한 담당 구역을 맡아 개인 사냥의 적 단계가 낮아졌다. 보급 정리를 돕고 준비 담당자에게 보수를 받았다. 안쪽에 남은 흔적은 확인한 것으로 표시하지 않는다.'
]);
const room=events.find(e=>e.key==='madoka_room_visit');edit(room,'story',fixed.events[4].scene,room.key,'어두운 방은 근거 없는 분위기 삽입이다. 원안의 방문 제안과 남은 귀환 준비를 쓴다.');
const merged={...current,sources:[...new Set([...current.sources,...fixed.sourceFacts.map(s=>s.source)])],cards:[...current.cards,...fixed.cards],events:[...current.events,...events]};
merged.canonBoundary+=' 새 문병·아침·약속·전학생·방 방문·결계 바깥 문제는 마미 생전의 서로 다른 별도 만남이다. 기존 교회 등 본편의 다른 시점과 같은 날로 연결하지 않는다. 부모와 히토미의 준비는 맵의 창작 성장으로 원작 전투 기술이 아니며 치료·연애 해결·결계 탈출·추가 시간·마미 운명 변경은 없다. 공식 원 TV와 재편집 TV Edition의 화수는 다르다.';
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(merged);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
fs.writeFileSync(path.join(root,'revisions/mitakihara-expansion-curated-20.json'),JSON.stringify(merged,null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(root,'revisions/mitakihara-expansion-curation-20.json'),JSON.stringify({sourceRevision:'3dc7c81',raw:'drafts/mitakihara-expansion-text-19.json',changes,check,notes:['신규6사건·6카드의 수치와 기존 콘텐츠를 보존한다.','병원 두 번째 선택의 사야카 대신 마도카 주체, 근거 없는 어두운 방, 누락된 카드 준비·필드 변화·비용을 그대로 채택하지 않는다.']},null,2)+'\n',{flag:'wx'});
const str={type:'string'},schema={type:'object',additionalProperties:false,required:['verdict','issues','strengths'],properties:{verdict:{type:'string',enum:['PASS','REVISE']},issues:{type:'array',items:{type:'object',additionalProperties:false,required:['key','problem','evidence','suggestion'],properties:{key:str,problem:str,evidence:str,suggestion:str}}},strengths:{type:'array',items:str}}};
const request={review:true,schema,system:'한국어 독립 검토자다. verdict는 반드시 PASS 또는 REVISE. 원작·수치·행동의 실제 모순만 issues에 쓴다. 문제 없는 항목은 넣지 않는다. 맵의 창작 능력치를 원작 고유 기술로 오해하지 않는다.',brief:{sourceFacts:fixed.sourceFacts,newContent:{cards:fixed.cards,events},mechanics:'독립6사건. cost/level/density먼저,성공card/gold/potions.첫사건70%성공120비용후카드180보수,실패비용만.소지카드100골드.현재체력지불없음. 재생흡수합산10%/초·물약별도. 후보·신속이사냥시간과AP증가아님. 일반인부모의원작초능력·손치료·연애해결·결계탈출보장·마미운명변경없음.모든새만남은마미생전별도시점으로기존교회와같은날아님.',questions:['준코·토모히사·히토미 역할과 원작의 시간·주체가 맞는가?','카드·비용·보수·물약·개인 적 변화가 결과와 일치하는가?','문병·가정·약속·교실·선배 방문·입구의 구체적인 차이가 있는가?']}};
fs.writeFileSync(path.join(root,'requests/mitakihara-expansion-review-20.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({cards:merged.cards.length,events:merged.events.length,check}));
