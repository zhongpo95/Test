// 후유키의 반복 지도 사건을 제외하고 화면 문장과 지정 보상의 연결을 다듬는다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const fixed=JSON.parse(fs.readFileSync(path.join(root,'requests/fuyuki-expansion-fixed-07.json'),'utf8'));
const draft=JSON.parse(fs.readFileSync(path.join(root,'drafts/fuyuki-expansion-text-08.json'),'utf8')).parsed;
const first=JSON.parse(fs.readFileSync(path.join(root,'drafts/fuyuki-expansion-text-07.json'),'utf8')).parsed;
const current=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/01-fuyuki.json'),'utf8'));
const changes=[];function edit(obj,field,value,key,reason){changes.push({key,field,before:obj[field],after:value,reason});obj[field]=value;}
assert.equal(draft.events[2].key,'fy_신지_offer');edit(draft.events[2],'key','fy_shinji_offer','fy_shinji_offer','문장 모델이 영어 데이터 키 일부를 번역했다. 고정 계획과 위치·선택 순서를 대조한 뒤 원래 키로 되돌린다.');
assert.deepEqual(draft.events.map(e=>e.key),fixed.events.map(e=>e.key));
const names=[['빠뜨린 이름까지','사건 후보 · 처치 골드'],['답을 기다리는 순서','치명타 확률 · 신속'],['계산 밖에 남은 사람','공격력 · 최대 체력 부담'],['감당할 결과부터','보스 피해 · 방어 부담'],['곁에 맞춘 보폭','이동 · 피해 감소']];
const cards=fixed.cards.map((c,i)=>{const x={key:c.key,name:c.name,...first.cards[i],grade:c.grade,effects:c.effects,evolution:c.evolution,canonFact:c.fact,uncertain:[]};edit(x,'effectName',names[i][0],c.key,'긴 수치 나열을 인물의 행동과 태도 이름으로 바꾼다.');edit(x,'keyword',names[i][1],c.key,'기존 능력치의 용어와 부담을 표시한다.');return x;});
const events=fixed.events.map((p,i)=>{assert.equal(draft.events[i].choices.length,p.choices.length);return {key:p.key,title:p.title,story:draft.events[i].story,intro:draft.events[i].intro,previous:null,previousChoice:0,requiredCard:null,choices:p.choices.map((b,j)=>({label:draft.events[i].choices[j].label,result:draft.events[i].choices[j].result,card:b.card,card2:b.card2,gold:b.gold,cost:b.cost,level:b.level,density:b.density,potions:b.potions,chance:b.chance})),failure:p.failure,canonFact:p.situation,uncertain:[]};});
const e=k=>events.find(x=>x.key===k);function results(key,values){values.forEach((v,i)=>edit(e(key).choices[i],'result',v,key+'#'+(i+1),'비용·지정 준비·보수 제공자·개인 필드 변화를 실제 범위로 설명하고 선택하지 않은 부탁을 남긴다.'));}
results('fy_club_inventory',[
 '기록용품 값을 내고 타이가와 물건을 가져온 이름부터 대조했다. 빠뜨린 일을 하나 더 살피고 준비한 몫을 챙기는 요령을 배웠다. 이름 없는 상자는 따로 남겨 두었다.',
 '시로와 넓은 길목까지 살피며 문과 길의 구조를 하나씩 짚었다. 맡을 범위가 넓어 개인 사냥의 적 수가 늘었다. 상자에 이름을 붙일 사람은 아직 찾지 못했다.',
 '이름이 확인된 물건만 정리하고 일을 맡긴 사람에게 보수와 보급 물약을 받았다. 타이가에게 이름 없는 상자를 따로 보여 주고 조사를 남겨 둔다.'
]);
edit(e('fy_regular_contact'),'intro','빠진 연락을 확인할지, 맡을 구역을 줄일지 정한다.','fy_regular_contact','연락 누락지 같은 번역투를 없앤다.');
results('fy_regular_contact',[
 '기록용품 값을 내고 린과 답이 온 곳과 오지 않은 곳을 나누었다. 먼저 확인하고 움직일 순서를 익혔다. 답 없는 곳을 안전하다고 결론 내리지는 않는다.',
 '보급 준비 비용을 내고 세이버와 맡을 길목을 한 곳 줄였다. 기본 방어 자세를 맞추고 개인 사냥의 적 수를 줄였다. 남은 연락은 린에게 맡긴다.',
 '연락이 닿은 곳의 자료 정리를 돕고 조사 보수와 보급 물약을 받았다. 시로에게 답이 없는 항목을 따로 넘긴다. 누락된 연락을 버리거나 전부 끝냈다고 하지는 않는다.'
]);
results('fy_shinji_offer',[
 '연락 비용을 내고 서로 맞는 자료를 찾아 린과 제안의 빈틈을 짚었다. 확인 자료를 넘긴 보수도 받았다. 더 넓은 길목을 맡아 개인 사냥의 적 수는 늘었고 협력을 받아들일지는 아직 정하지 않았다.',
 '준비물 값을 내고 아처와 제안이 무엇을 요구하는지 하나씩 짚었다. 큰 싸움에서 감당할 결과에 집중하는 준비를 배웠지만 주변을 지킬 여유는 줄었다. 신지에게 답은 아직 돌려주지 않는다.',
 '확인된 문장만 따로 옮겨 조사 정리 보수를 받았다. 신지가 빠뜨린 조건은 빈칸으로 남겼다. 린과 시로가 제안을 계속 검토할 자리는 남겨 둔다.'
]);
edit(e('fy_pause_outside').choices[1],'label','기록용품을 사서 린과 다음 연락을 준비한다','fy_pause_outside#2','240골드가 쓰이는 행동을 결과와 함께 보여 준다.');
results('fy_pause_outside',[
 '외출 준비물 값을 내고 세이버와 걸음을 맞췄다. 곁을 살피며 보폭을 고르는 요령을 배웠다. 모두의 걱정이나 다음 싸움까지 잊은 것은 아니다.',
 '기록용품 값을 내고 린과 다음에 확인할 연락을 나누었다. 빠뜨리지 않고 먼저 판단할 순서를 배웠다. 세이버가 둘러보고 싶은 길은 잠시 남겨 둔다.',
 '가까운 보급 정리를 도와 보수와 물약을 받았다. 맡을 길목을 한 곳 덜어 개인 사냥의 적 수도 줄었다. 멀리 둘러볼 곳은 두 사람에게 맡긴다.'
]);
edit(e('fy_teacher_statement').choices[1],'label','기록 도구를 마련해 시로와 확인된 길의 구조를 살핀다','fy_teacher_statement#2','진술의 논리적 구조가 곧 시로 무기 분석 능력이라는 혼동을 피하고 비용 사용처를 보여 준다.');
results('fy_teacher_statement',[
 '조사 비용을 내고 확인할 길목을 넓혀 빠진 시각과 장소를 찾았다. 린과 사실을 짚는 순서를 배우고 자료 보수를 받았다. 개인 사냥의 적 수는 늘었지만 교사의 정체를 단정하지는 않는다.',
 '기록 도구 값을 내고 시로와 진술에 나온 길의 구조를 직접 맞춰 보았다. 복잡한 부분을 하나씩 살피는 요령을 배웠다. 들은 말까지 확인된 사실로 바꾸지는 않았다.',
 '직접 본 일과 전해 들은 일을 다른 줄에 적어 기록 보수를 받았다. 빈칸은 빈칸으로 남긴다. 린에게 더 물어볼 항목을 따로 건넸다.'
]);
results('fy_two_ideals',[
 '시로와 더 강한 적이 드나드는 길목을 맡기로 했다. 앞으로 밀고 나갈 힘을 준비한 대신 몸을 오래 버티게 할 여유는 줄었다. 개인 사냥의 적 단계가 올라갔고 아처의 우려도 남아 있다.',
 '표시 도구 값을 내고 아처와 큰 싸움에서 먼저 겨눌 자리를 골랐다. 큰 상대에 집중하는 준비를 챙긴 대신 주변을 방어할 여유는 줄었다. 시로가 걱정하는 사람들까지 모두 구한 것은 아니다.',
 '둘의 주장을 다른 줄에 적고 보급 준비 일을 도왔다. 작업 보수와 물약을 받았다. 누가 옳다고 판정하지 않고 둘이 남긴 질문도 함께 적어 둔다.'
]);
const rejected=e('fy_vantage_map'),kept=events.filter(x=>x.key!==rejected.key);
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect({...current,cards:[...current.cards,...cards],events:[...current.events,...kept]});if(check.errors.length)throw Error(JSON.stringify(check));
const merged={...current,cards:[...current.cards,...cards],events:[...current.events,...kept]};merged.canonBoundary+=' 추가된 목록·연락·협력 검토·외출·증언·이상의 차이는 공식 인물 관계와 에피소드 동기를 토대로 별도 창작한 작은 사건이다. 본편 계약·학교 교사의 정체·피랍·령주 탈취·성배전쟁 결말을 변경하거나 완료하지 않는다.';
fs.writeFileSync(path.join(root,'revisions/fuyuki-expansion-curated-08.json'),JSON.stringify(merged,null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(root,'revisions/fuyuki-expansion-curation-08.json'),JSON.stringify({sourceRevision:'4a86910',raw:'drafts/fuyuki-expansion-text-08.json',changes,excluded:{event:rejected,reason:'지도와 이상의 차이가 모두 아처의 계산·시로의 위험 부담·안전 보급이라는 선택으로 겹친다. 인물 이상이 더 선명한 후자를 남긴다.',revisit:'다른 문제와 행동·보상을 준비하면 지도 소재를 다시 검토한다.'},check},null,2)+'\n',{flag:'wx'});
const request={review:true,system:'독립 검토자다. JSON {verdict,issues:[{key,problem,evidence,suggestion}],strengths:[string]}로 구체적 원작·수치·행동 모순을 검토한다. 제작 메타데이터와 플레이어 문장을 구분한다.',brief:{sourceFacts:fixed.sourceFacts,existingCards:current.cards,newContent:{cards,events:kept},mechanics:'독립6사건. 비용·level/density는 먼저 적용되어 확률 실패도 유지. 성공 때만 card/gold/potions. 60%/70% 선택의 성공 결과와 실패 문구가 따로 있다. 이미 가진 카드100골드. level1..5,density1..10. HP 비용 없음. 카드의 max_health_percent-6은 이후 최대체력 부담이며 현재 체력 지불 선택이 아니다. 신속135는 고정값. 피해감소-2도 허용된 카드 부담. 실제 본편·NPC·정체·새 기술 변화 없음.',questions:['같은 학교 교사의 정체나 신지의 계약·시로와 아처의 화해를 확정하는가?','확률 성공의 비용·카드·보수·남은 필드 부담과 실패가 서로 맞는가?','손해 없는 완전한 안전이나 즉시 회복을 약속하는가?','입문·기존 카드와 새 카드의 원작 역할이 혼동되는가?']}};
fs.writeFileSync(path.join(root,'requests/fuyuki-expansion-review-08.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({cards:merged.cards.length,events:merged.events.length,roots:merged.events.filter(e=>!e.previous).length,check}));
