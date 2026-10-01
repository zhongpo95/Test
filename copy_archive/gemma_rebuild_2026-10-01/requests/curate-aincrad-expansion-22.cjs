// 아인크라드 집필의 주체 변경과 모호한 방어 결과를 지정 성장·필드 변화에 맞춘다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const fixed=JSON.parse(fs.readFileSync(path.join(root,'requests/aincrad-expansion-fixed-21.json'),'utf8')),draft=JSON.parse(fs.readFileSync(path.join(root,'drafts/aincrad-expansion-text-21.json'),'utf8')).parsed,current=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/06-aincrad.json'),'utf8'));
assert.deepEqual(draft.events.map(e=>e.key),fixed.events.map(e=>e.key));
const changes=[];function edit(obj,field,value,key,reason){if(obj[field]===value)return;changes.push({key,field,before:obj[field],after:value,reason});obj[field]=value;}
const events=fixed.events.map((p,i)=>{assert.equal(draft.events[i].choices.length,p.choices.length);return {key:p.key,title:p.title,story:draft.events[i].story,intro:draft.events[i].intro,previous:null,previousChoice:0,requiredCard:null,choices:p.choices.map((b,j)=>({label:draft.events[i].choices[j].label,result:draft.events[i].choices[j].result,card:b.card,card2:b.card2,gold:b.gold,cost:b.cost,level:b.level,density:b.density,potions:b.potions,chance:b.chance})),failure:p.failure||null,canonFact:p.canonFact,uncertain:[]};});
function scene(key,intro,rs){const x=events.find(e=>e.key===key);edit(x,'intro',intro,key,'분위기 대신 맡을 작업과 갈래를 설명한다.');rs.forEach((r,i)=>{if(r!==null)edit(x.choices[i],'result',r,key+'#'+(i+1),'비용·지정 카드의 배운 준비·사냥 적 강함과 수를 연결한다. 방어·확보만 적어 위험이 사라진 것처럼 보이거나 실제 원작 기술을 지급하지 않는다.');});}
scene('sao_counter_labels','겹친 값표를 맞추거나 바깥 운반과 보급을 맡는다.',[
 '기록용품 값180골드를 내고 에길과 겹친 값표를 맞췄다. 얻을 몫과 비교할 후보를 놓치지 않는 준비를 배웠다. 키리토가 바깥에서 가져올 물건을 묻자 에길은 아직 확인하지 않은 상자부터 가리킨다.',
 '키리토와 더 강한 적이 오가는 운반 길목을 맡았다. 공격할 순간과 다음 동작을 잇는 요령을 배웠고 개인 사냥의 적 단계가 올라갔다. 에길은 그 길목으로 나갈 상자만 따로 나눈다.',null,null
]);
scene('sao_guild_roll','빈 뒷자리와 적이 많은 옆길 중 맡을 일을 정한다.',[
 '준비 도구 값200골드를 내고 클라인과 앞뒤 역할을 나누었다. 큰 상대에게 힘을 싣고 버틸 위치를 남기는 준비를 배웠다. 키리토는 뒤에 남길 몫이 빠지지 않았는지 다시 묻는다.',
 '클라인과 더 많은 적이 드나드는 옆길을 맡았다. 주변을 넓게 보며 맞을 부담을 줄이는 준비를 배운 대신 개인 사냥의 적 수가 늘었다. 클라인은 앞쪽뿐 아니라 돌아올 쪽에도 표시를 남긴다.',
 '담당 길목을 한 곳 줄여 개인 사냥의 적 수를 줄였다. 보급 정리 담당자에게 보수140골드와 물약 하나를 받았다. 클라인은 비운 뒷자리를 다음에 누가 맡을지 확인한다.'
]);
scene('sao_middle_lantern','사치의 답을 재촉하지 않고 먼저 맡을 구역을 나눈다.',[
 '준비물 값220골드를 내고 사치와 더 약한 구역을 맡았다. 몸 상태를 지키고 오래 이어 갈 준비를 배웠고 개인 사냥의 적 단계가 낮아졌다. 사치는 대답을 서두르지 않고 돌아올 자리의 표시를 한 번 더 본다.',
 '키리토와 더 강한 적이 오가는 바깥 길목을 맡았다. 공격할 순간과 다음 동작을 잇는 요령을 배운 대신 개인 사냥의 적 단계가 올라갔다. 키리토는 사치가 아직 나누지 않은 준비물을 옆에 남긴다.',
 '맡을 길목을 한 곳 줄여 개인 사냥의 적 수를 줄였다. 등불 정리 담당자에게 보수120골드를 받았다. 사치는 남겨 둘 등불을 다시 세고 돌아올 자리를 확인한다.'
]);
scene('sao_lakeside_wait','예전 자리 기록을 확인할지, 지금 남은 도구를 정리할지 고른다.',[
 '연락 비용150골드를 쓰고 예전 낚시 자리 기록을 확인했다. 니시다와 오래 움직이며 주변을 넓게 보는 준비를 배웠고 준비 담당자에게 확인 보수240골드를 받았다. 니시다는 확인한 위치만 적고 먼저 잡아당기지 말자고 한다.',
 '준비 도구 값210골드를 내고 니시다와 기다릴 자리를 나누었다. 오래 움직이며 주변을 넓게 보는 준비를 배웠다. 아스나는 기다리는 동안 섞인 묶음부터 정리하고 키리토는 니시다의 말을 끝까지 듣는다.',
 '아스나와 더 많은 적이 오가는 바깥 안내 구역을 맡았다. 몸 상태를 지키고 오래 움직일 보급 습관을 배웠고 개인 사냥의 적 수가 늘었다. 니시다는 지금 남길 도구만 나누고 낚시 자리를 아직 떠나지 않는다.',null
]);
scene('sao_deputy_directions','한 곳에 몰린 준비와 빈 길목의 역할을 다시 나눈다.',[
 '표시 용품 값220골드를 내고 아스나와 남은 지시를 나누었다. 큰 상대에게 힘을 싣는 순간을 고르는 준비를 배웠다. 키리토는 자신에게 남길 연락을 먼저 묻고 클라인은 아직 빈 길목을 가리킨다.',
 '클라인과 더 많은 적이 드나드는 빈 길목을 맡았다. 큰 상대에게 힘을 싣고 버틸 위치를 남기는 준비를 배웠고 개인 사냥의 적 수가 늘었다. 아스나는 네가 맡은 범위만 따로 표시한다.',
 '보급 비용100골드를 내고 물약 하나를 챙겼다. 더 약한 구역을 맡아 개인 사냥의 적 단계가 낮아졌다. 아스나는 그 구역에 남겨 둘 연락을 따로 적는다.',null
]);
const guild=events.find(e=>e.key==='sao_guild_roll');edit(guild,'story',fixed.events[1].scene,guild.key,'모두 앞자리만 원한다는 문제를 클라인 혼자 앞자리만 가리키는 행동으로 바꾸지 않는다.');
const merged={...current,sources:[...new Set([...current.sources,...fixed.sourceFacts.map(s=>s.source)])],cards:[...current.cards,...fixed.cards],events:[...current.events,...events]};
merged.canonBoundary+=' 값표·역할 분담·중층 등불·낚시 기록·지시 누락은 공식 인물과 생활 배경에서 별도로 창작했다. 사치 생전과 니시다 만남은 서로 다른 시점이다. 사치의 공포와 본편 비극·낚시 주인·혈맹기사단 결투·귀환 결말은 선택 보상으로 해결하지 않는다. 맵의 개인 몬스터 변화가 원작 안전 구역 해제나 실제 마을 침입이라는 뜻은 아니다.';
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(merged);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
fs.writeFileSync(path.join(root,'revisions/aincrad-expansion-curated-22.json'),JSON.stringify(merged,null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(root,'revisions/aincrad-expansion-curation-22.json'),JSON.stringify({sourceRevision:'3dc7c81',raw:'drafts/aincrad-expansion-text-21.json',changes,check,notes:['신규5사건·5카드의 수치와 기존 콘텐츠는 유지한다.','클라인으로 바뀐 문제 주체·누락 카드 준비·위험도 표현만 남은 적 단계와 수·어색한 지시 오해를 보완한다.']},null,2)+'\n',{flag:'wx'});
const schema=JSON.parse(fs.readFileSync(path.join(root,'requests/mitakihara-expansion-review-20.json'),'utf8')).schema;
const request={review:true,schema,system:'한국어 독립 검토자다. verdict는 PASS 또는 REVISE. 원작·수치·행동의 실제 모순만 issues에 쓴다. 맵의 창작 능력치를 원작 기술이라고 오해하지 않는다. 문제 없는 항목은 넣지 않는다.',brief:{sourceFacts:fixed.sourceFacts,newContent:{cards:fixed.cards,events},mechanics:'독립5사건. cost/level/density먼저,성공card/gold/potions.낚시기록65%성공150비용후카드240보수,실패비용만.소지카드100골드.현재체력지불없음.사치생전과니시다만남은서로다른독립시점.재생흡수합산10%/초물약별도.새길드원소환·무기·낚시시스템·주인격파·사치운명변경없음.',questions:['사치·니시다·에길·길드 역할의 원작 근거와 시점이 맞는가?','카드·비용·보수·물약·개인 적 변화가 결과와 일치하는가?','상점·역할 분담·중층 생활·낚시·부단장 준비가 기존 시험검·고기·보스 정찰의 이름만 바꾼 반복인가?']}};
fs.writeFileSync(path.join(root,'requests/aincrad-expansion-review-22.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({cards:merged.cards.length,events:merged.events.length,check}));
