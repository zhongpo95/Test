// 학원도시 초안의 추상 결과와 수영부 능력 오인을 실제 비용·준비·사냥 변화에 맞춘다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const fixed=JSON.parse(fs.readFileSync(path.join(root,'requests/academy-expansion-fixed-17.json'),'utf8'));
const draft=JSON.parse(fs.readFileSync(path.join(root,'drafts/academy-expansion-text-17.json'),'utf8')).parsed;
const current=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/04-academy.json'),'utf8'));
assert.deepEqual(draft.events.map(e=>e.key),fixed.events.map(e=>e.key));
const changes=[];function edit(obj,field,value,key,reason){if(obj[field]===value)return;changes.push({key,field,before:obj[field],after:value,reason});obj[field]=value;}
const events=fixed.events.map((p,i)=>{assert.equal(draft.events[i].choices.length,p.choices.length);return {key:p.key,title:p.title,story:draft.events[i].story,intro:draft.events[i].intro,previous:null,previousChoice:0,requiredCard:null,choices:p.choices.map((b,j)=>({label:draft.events[i].choices[j].label,result:draft.events[i].choices[j].result,card:b.card,card2:b.card2,gold:b.gold,cost:b.cost,level:b.level,density:b.density,potions:b.potions,chance:b.chance})),failure:p.failure||null,canonFact:p.canonFact,uncertain:[]};});
function scene(key,intro,rs){const x=events.find(e=>e.key===key);edit(x,'intro',intro,key,'분위기 평가 대신 실제 맡을 일을 안내한다.');rs.forEach((r,i)=>edit(x.choices[i],'result',r,key+'#'+(i+1),'배운 준비·비용·보수·물약·개인 적 강함과 수를 누락하지 않는다. 비장함·깊은 신뢰·체계적 처리만으로 끝내지 않으며 실제 초능력과 신규 장비를 지급하지 않는다.'));}
scene('academy_display_window','가려진 진열창과 순찰 길목 중 맡을 일을 고른다.',[
 '정리 도구 값을 보태고 미코토와 진열 앞에 겹친 상자를 옮겼다. 힘을 쏟을 순간을 고르면서 다음 일을 버틸 준비를 배웠다. 미코토가 마지막 소품을 들여다보자 쿠로코는 순찰 시간을 다시 짚는다.',
 '쿠로코와 더 많은 적이 드나드는 길목을 맡았다. 도착한 자리에서 다음 동작을 빠르게 준비하고 버틸 요령을 배운 대신 개인 사냥의 적 수가 늘었다. 쿠로코는 맡기로 한 길목만 지도에 표시한다.',
 '빈 상자만 옮기고 가게 주인에게 작업 보수를 받았다. 가려져 있던 진열창이 드러났다. 미코토는 아직 자리를 못 잡은 소품 하나를 옆으로 옮긴다.'
]);
scene('academy_sweet_orders','겹친 주문을 맞추거나 납품 경로의 연락을 맡는다.',[
 '확인 용품 값을 내고 우이하루와 겹친 주문 항목을 지웠다. 쉬었다가 다시 오래 움직이며 차지 동작을 준비하는 습관을 배웠다. 우이하루는 접힌 주문표를 펴 둔 뒤 고르던 간식 쪽으로 돌아간다.',
 '우이하루와 더 강한 적이 오가는 납품 경로의 연락을 맡았다. 다음 동작을 늦추지 않고 필요한 연락을 먼저 잇는 요령을 배운 대신 개인 사냥의 적 단계가 올라갔다. 사텐은 그 경로의 상자만 따로 빼놓는다.',
 '빈 상자를 정리하고 점원에게 작업 보수와 보급 물약을 받았다. 사텐이 접힌 주문표를 상자 위에 펼친다. 우이하루는 아직 확인하지 않은 줄에 작은 표시를 남긴다.'
]);
scene('academy_pair_step','옆 사람의 보폭과 바깥 준비 구역 중 맡을 일을 정한다.',[
 '준비 도구 값을 내고 콘고와 옆 사람의 보폭을 맞췄다. 다음 동작을 빠르게 준비하고 움직일 속도에 맞춰 힘을 싣는 요령을 배웠다. 미코토가 걸음을 늦추자 콘고도 앞서 내민 발을 되돌린다.',
 '미코토와 더 강한 적이 오가는 바깥 준비 구역을 맡았다. 힘을 모아 공격하고 단단한 상대를 넘기는 준비를 배웠고 개인 사냥의 적 단계가 올라갔다. 콘고는 돌아와서 다시 보폭을 맞추자고 한다.',
 '준비물 값을 내고 완나이와 먼저 버틸 위치를 짚었다. 맞을 부담을 줄이고 다음 일을 오래 이어 갈 준비를 배웠다. 완나이는 바깥까지 한 번에 맡기보다 지금 나눈 위치를 먼저 보자고 한다.',
 '남은 끈과 상자를 정리하고 준비 담당자에게 작업 보수를 받았다. 미코토는 연습할 자리를 비우고 콘고는 끈을 다시 펴 둔다. 경기 전에 맞출 걸음은 아직 남아 있다.'
]);
scene('academy_pool_bundle','흐름을 살필지, 뜨는 물건의 균형을 맞출지 고른다.',[
 '준비물 값을 내고 완나이와 물이 흐르는 쪽부터 위치를 살폈다. 맞을 부담을 줄이고 오래 버틸 준비를 배웠다. 완나이는 먼저 옮길 꾸러미를 가리키고 콘고는 바깥 구역의 목록을 접는다.',
 '받침 도구 값을 내고 아와츠키와 잠깐 뜨는 물건의 균형을 맞췄다. 차지 동작을 빠르게 준비하고 모은 힘을 싣는 요령을 배웠다. 아와츠키는 균형이 흐트러진 꾸러미를 따로 남긴다.',
 '바깥 담당 구역을 한 곳 줄여 개인 사냥의 적 수를 줄였다. 준비물 정리 보수와 보급 물약을 받았다. 완나이와 아와츠키는 풀 가장자리에 남긴 꾸러미를 다시 나눈다.'
]);
scene('academy_guts_corner','더 강한 적이 오가는 길목과 남은 짐 정리 중 맡을 일을 정한다.',[
 '군하와 더 강한 적이 드나드는 길목까지 맡았다. 더 세게 밀어붙이는 힘을 얻었지만 오래 버틸 여유는 조금 줄었고 개인 사냥의 적 단계도 올라갔다. 토우마는 짐의 도착지를 적은 종이를 군하에게 먼저 내민다.',
 '운송 도구 값을 내고 토우마와 남은 사람 쪽을 살폈다. 버티며 큰 상대에게 공격할 준비를 배웠다. 토우마는 아직 갈 곳을 확인하지 못한 짐 하나를 옆으로 남긴다.',
 '빈 운송 도구를 정리하고 담당자에게 작업 보수와 보급 물약을 받았다. 군하는 남은 짐 쪽으로 돌아가고 토우마는 도착지 표시를 고쳐 붙인다.'
]);
scene('academy_parade_markers','예전 기록의 확인과 새 표식 준비 중 맡을 일을 고른다.',[
 '연락 비용 120골드를 쓰고 예전 표식의 기록을 확인했다. 우이하루와 쉬었다가 차지 동작을 다시 준비하는 습관을 배우고 준비 담당자에게 기록 확인 보수 210골드를 받았다. 우이하루는 확인한 표식만 새 상자로 옮긴다.',
 '새 표시 도구 값을 내고 쿠로코와 연락 뒤 움직일 순서를 맞췄다. 다음 동작을 빠르게 준비하면서 도착한 자리에서 버틸 요령을 배웠다. 쿠로코는 확인되지 않은 옛 표식을 따로 남기고 새 표식만 가리킨다.',
 '맡을 길목을 한 곳 줄여 개인 사냥의 적 수를 줄였다. 상자 정리 보수와 보급 물약을 받았다. 사텐은 아직 확인하지 않은 표식 위에 내일 볼 항목을 적는다.'
]);
const display=events.find(e=>e.key==='academy_display_window');edit(display,'story',fixed.events[0].scene,display.key,'들어내기 오자를 없애고 미코토의 부탁 대신 가게 주인의 정리 요청과 쿠로코의 순찰을 구분한다.');
const pair=events.find(e=>e.key==='academy_pair_step');edit(pair,'story',fixed.events[2].scene,pair.key,'4개 선택을 세 가지 요구사항이라고 쓰는 불일치를 없앤다.');edit(pair.choices[3],'label',fixed.events[2].choices[3].action,pair.key+'#4','받다 종결 오자를 받는다로 고친다.');
const pool=events.find(e=>e.key==='academy_pool_bundle');edit(pool,'story',fixed.events[3].scene,pool.key,'풀에 상류를 덧붙이고 부력을 조절하는 대상을 부력 조절용 물건으로 바꾼 오인을 없앤다.');
const merged={...current,sources:[...new Set([...current.sources,...fixed.sourceFacts.map(s=>s.source)])],cards:[...current.cards,...fixed.cards],events:[...current.events,...events]};
merged.canonBoundary+=' 귀여운 소품·단것·대회 준비·수영부·짐 정리·야간 표식은 공식 취향과 역할에서 별도로 창작한 만남이다. 이인삼각과 밤 퍼레이드는 공식2·4화 배경을 참고하되 경기 승패·본편 실종·기억 조작은 바꾸지 않는다. 아와츠키의 부력은 물의 밀도가 아니며 군하 능력의 상세 원리는 확정하지 않는다. 새 카드의 최대 체력 패널티는 지속 능력치로 현재 체력 지불 사건이 아니다.';
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(merged);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
fs.writeFileSync(path.join(root,'revisions/academy-expansion-curated-18.json'),JSON.stringify(merged,null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(root,'revisions/academy-expansion-curation-18.json'),JSON.stringify({sourceRevision:'3d32249',raw:'drafts/academy-expansion-text-17.json',changes,check,notes:['신규6카드·6사건의 고정 수치와 기존 콘텐츠를 유지한다.','반복된 추상 결과·필드와 비용 누락·상류와 부력 물건 오기·4선택을3가지로 설명한 오류를 그대로 채택하지 않는다.']},null,2)+'\n',{flag:'wx'});
const request={review:true,system:'한국어 독립 검토자다. JSON {verdict,issues:[{key,problem,evidence,suggestion}],strengths:[string]}로 원작·수치·행동의 실제 모순만 지적한다. 문제가 없는 항목은 issues에 넣지 않는다. 맵 각색 능력치를 원작 기술이라고 오해하지 않는다.',brief:{sourceFacts:fixed.sourceFacts,newContent:{cards:fixed.cards,events},mechanics:'독립6사건. cost/level/density는먼저, 성공때card/gold/potions.70%성공120비용후카드210보수,실패비용만. 소지카드100골드.현재체력비용없고군하max_health_percent-5는지속스탯.재생흡수합산초당최대체력10%·물약별도.이동피해는실제속도400대비환산·움직임여부아님.새초능력·수영전투·보호막·경기우승·능력과학적해명없음.',questions:['캐릭터·부력·군하의 불명확한 능력·공식 경기나 실종 해결의 오인이 있는가?','모든 카드·비용·보수·물약·개인 적 강함과 수가 문장과 일치하는가?','쇼핑·간식·짝 연습·수영부·길목의 짐·야간 표식의 구체적인 상황 차이가 유지되는가?']}};
fs.writeFileSync(path.join(root,'requests/academy-expansion-review-18.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({cards:merged.cards.length,events:merged.events.length,check}));
