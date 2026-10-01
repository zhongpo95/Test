// 미식전 집필 문장을 고정 수치와 대조하고 사건별 남는 문제와 보상을 정리한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const fixed=JSON.parse(fs.readFileSync(path.join(root,'requests/gourmet-expansion-fixed-06.json'),'utf8'));
const draft=JSON.parse(fs.readFileSync(path.join(root,'drafts/gourmet-expansion-text-06.json'),'utf8')).parsed;
const current=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/14-gourmet.json'),'utf8'));
assert.deepEqual(draft.cards.map(c=>c.key),fixed.cards.map(c=>c.key));assert.deepEqual(draft.events.map(e=>e.key),fixed.events.map(e=>e.key));
const changes=[];
function change(obj,field,value,key,reason){changes.push({key,field,before:obj[field],after:value,reason});obj[field]=value;}
const cards=fixed.cards.map((c,i)=>({key:c.key,name:c.name,...draft.cards[i],grade:c.grade,effects:c.effects,evolution:c.evolution,canonFact:c.fact,uncertain:[]}));
const names=[['차곡차곡 모아 둔 몫','최대 체력 · 처치 골드'],['움직임을 남기는 한 땀','행동 · 이동'],['빠진 시각을 짚다','관통 · 치명타 확률'],['먼저 맡을 자리','신속 · 피해 감소'],['발걸음에 맞춘 박자','행동 · 최대 체력']];
cards.forEach((c,i)=>{change(c,'effectName',names[i][0],c.key,'제작 제한이나 수치 용어 대신 인물의 행동을 효과 이름으로 쓴다.');change(c,'keyword',names[i][1],c.key,'금지 기능 설명을 플레이어에게 보여 주지 않고 실제 능력치의 종류를 표시한다.');});
const events=fixed.events.map((p,i)=>{assert.equal(draft.events[i].choices.length,p.choices.length);return {key:p.key,title:p.title,story:draft.events[i].story,intro:draft.events[i].intro,previous:null,previousChoice:0,requiredCard:null,choices:p.choices.map((b,j)=>({label:draft.events[i].choices[j].label,result:draft.events[i].choices[j].result,card:b.card,card2:b.card2,gold:b.gold,cost:b.cost,level:b.level,density:b.density,potions:b.potions,chance:b.chance})),failure:null,canonFact:p.situation+' '+p.boundaries,uncertain:[]};});
const e=k=>events.find(x=>x.key===k);
function scene(key,story,intro,results){const x=e(key);change(x,'story',story,key,'원작의 활동을 바탕으로 창작한 물건·인물의 부탁을 보여 주고 한 선택으로 전부 해결하지 않는다.');change(x,'intro',intro,key,'유일한 정답을 요구하지 않고 맡을 일을 정하게 한다.');results.forEach((r,i)=>change(x.choices[i],'result',r,key+'#'+(i+1),'지정 카드의 준비·일당 제공자·개인 필드 변화와 남은 일을 실제 적용 범위에 맞춘다.'));}
scene('pc_rainy_harvest','논가에 묶어 둔 곡식 옆으로 빗방울이 떨어진다. 콧코로는 막힌 배수길과 남은 묶음을 번갈아 보고, 페코린느는 들 수 있는 것부터 옮기자고 한다. 둘 다 끝내기에는 손이 부족하다.','배수 도구를 마련할지, 곡식을 옮길지, 맡을 범위를 줄일지 정한다.',[
 '도구 대여비를 내고 콧코로와 물길부터 열었다. 남은 묶음은 페코린느에게 맡기고, 준비물과 거둘 몫을 나누는 요령을 챙긴다.',
 '페코린느와 묶음을 옮기며 든든히 준비하고 움직이는 요령을 배웠다. 대신 밖의 넓은 보급길도 맡아 개인 사냥의 적 수가 늘었다. 배수 작업은 콧코로에게 남긴다.',
 '필요한 곳의 정리만 돕고 작업 보수와 보급 물약을 받았다. 맡을 길목을 한 곳 줄여 개인 사냥의 적 수도 줄었다. 다른 논의 일까지 마친 것은 아니다.'
]);
scene('pc_wrong_costume_tag','츠무기가 옷에 묶인 이름표를 의뢰서 옆에 놓는다. 받는 사람이 서로 다르자 유우키도 배달 종이를 다시 펼친다. 츠무기는 허락도 받지 않고 자를 수는 없다며 가위를 내려놓는다.','확인을 도울지, 맞지 않는 옷을 되돌릴 준비를 할지 정한다.',[
 '연락용품과 측정 도구 값을 내고 주문한 사람의 조건을 확인했다. 츠무기와 움직일 여유를 남기는 옷의 준비를 배웠다. 맞지 않는 옷을 억지로 수선하지는 않는다.',
 '이름표를 그대로 묶어 반송할 옷을 포장하고 다른 짐도 정리했다. 가게에서 작업 보수와 보급 물약을 받았다. 새 옷을 누구에게 맞출지는 츠무기에게 남긴다.'
]);
scene('pc_witness_hours','카스미가 두 주민의 진술을 나란히 펼친다. 한 사람은 짐수레를, 다른 사람은 어두운 보행자를 보았지만 적힌 시각이 다르다. 카스미는 둘 중 누구를 거짓말쟁이라 부르기 전에 시각부터 확인하자고 한다.','어느 부분을 확인하고 어디까지 기록할지 정한다.',[
 '기록 도구 값을 내고 시각과 길목을 하나씩 맞춰 보았다. 카스미와 섣불리 결론 내리지 않고 빈틈을 짚는 요령을 배웠다. 보행자의 정체는 아직 알 수 없다.',
 '포장 비용을 내고 확인할 길목 하나를 덜어 보급을 다시 묶었다. 자경단에서 물약 두 개를 받고 개인 사냥의 적 수를 줄였다. 남은 진술의 대조는 카스미에게 맡긴다.',
 '확인된 시각과 문장만 따로 옮겨 기록 보수를 받았다. 서로 맞지 않는 부분은 빈칸으로 남긴다. 누구의 말이 전부 옳다고 결론 내리지는 않았다.'
]);
scene('pc_monica_market_watch','불안해진 상인들이 저녁도 준비하기 전에 문을 닫으려 한다. 모니카는 지킬 길목을 나누자고 하고, 페코린느는 식사할 사람들의 몫도 걱정한다. 캬루는 넓게 맡을수록 놓칠 구석이 늘어난다고 말한다.','길목을 준비하거나 맡을 범위를 바꿀 수 있다. 폐점 일을 돕는 방법도 있다.',[
 '표시 도구 값을 내고 모니카와 먼저 맡을 자리와 돌아설 순서를 맞췄다. 빠른 지시와 방어 준비를 익혔다. 상인들의 불안이 모두 사라진 것은 아니다.',
 '캬루와 공격할 자리를 짚으며 더 넓은 길목까지 맡았다. 다음 싸움의 준비를 챙긴 대신 개인 사냥의 적 수가 늘었다. 다른 구역의 안전까지 약속하지 않는다.',
 '보급 비용을 내고 강한 적이 드나들던 길을 맡을 범위에서 덜었다. 개인 사냥의 적 단계가 내려가고 물약 하나를 받았다. 남은 경계는 다른 사람에게 맡긴다.',
 '가게의 물건을 안으로 옮기고 폐점 정리 보수를 받았다. 상인들이 문을 닫는 결정은 바꾸지 못했다. 경계할 길목을 정하는 일은 모니카에게 남긴다.'
]);
scene('pc_delivery_divide','유우키의 배달 짐과 미식전의 보급품이 같은 수레에 실렸다. 목적지가 달라 첫 갈림길에서 그대로 나아갈 수는 없다. 콧코로는 나눌 몫을 표시하고 페코린느는 큰 짐부터 들자고 한다.','다시 포장할지, 큰 몫을 맡을지, 좁은 범위만 도울지 정한다.',[
 '포장 비용을 내고 콧코로와 전달할 몫을 나누었다. 몸과 다음 행동을 오래 돌보는 준비를 배웠다. 모든 목적지에 짐을 전했다고 하지는 않는다.',
 '페코린느와 큰 짐을 나누어 들며 함께 버티고 나아갈 준비를 배웠다. 넓은 길목까지 맡아 개인 사냥의 적 수가 늘었다. 작은 짐의 배달은 유우키에게 남긴다.',
 '짐 분류를 도운 보수를 받고 맡을 길목을 한 곳 덜었다. 개인 사냥의 적 수는 줄었지만 남의 배달까지 끝내지는 않았다. 목적지별 꾸러미는 수레에 나누어 둔다.'
]);
scene('pc_rehearsal_wall','카르미나의 연습 자리에서 움직일 때마다 벽 쪽 짐이 덜컹거린다. 벽 너머에서는 주민들이 쉬고 있고, 노조미는 연습도 부탁도 전부 한 번에 맡기는 어렵다고 말한다. 페코린느는 바깥에 쌓인 짐부터 들어 보려 한다.','연습 자리의 움직임을 맞추거나 짐을 옮기는 일을 도울 수 있다.',[
 '완충재 값을 내고 노조미와 짐에 걸리지 않을 발걸음을 맞췄다. 몸을 준비하고 일정하게 움직이는 요령을 배웠다. 이 준비만으로 주민들의 모든 불편이 사라지지는 않는다.',
 '페코린느와 바깥 길까지 짐을 옮기며 든든히 움직이는 준비를 배웠다. 넓은 길목을 맡은 만큼 개인 사냥의 적 수가 늘었다. 연습 자리의 순서는 노조미에게 남긴다.',
 '연습에는 끼어들지 않고 필요한 짐만 정리했다. 작업 보수와 보급 물약을 받았다. 노조미가 연습과 주민의 부탁을 조율할 자리는 남겨 둔다.'
]);
const merged={...current,cards:[...current.cards,...cards],events:[...current.events,...events],sources:[...new Set([...current.sources,...fixed.sourceFacts.map(s=>typeof s==='string'?s:s.source)])]};
assert(merged.sources.every(Boolean));
merged.canonBoundary+=' 추가된 농사·의상 배달·길목 증언·상점 경계·짐 분류·연습 자리는 공식 인물과 활동에서 별도로 창작한 사건이다. 공식 본편의 섀도·기사·치카 문제를 해결하지 않고 NPC 동행·공연·관계·재고 시스템은 생성하지 않는다.';
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(merged);if(check.errors.length)throw Error(JSON.stringify(check));
fs.writeFileSync(path.join(root,'revisions/gourmet-expansion-curated-06.json'),JSON.stringify(merged,null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(root,'revisions/gourmet-expansion-curation-06.json'),JSON.stringify({sourceRevision:'4a86910',raw:'drafts/gourmet-expansion-text-06.json',changes,notes:['고정 수치·지정 카드 참조는 별도 계획과 동일하다.','Gemma 초안의 금지 기능 목록이 카드 키워드로 들어온 부분과 모호한 일당·필드 변화 표현을 수정했다.']},null,2)+'\n',{flag:'wx'});
const request={review:true,system:'독립 내용 검토자다. JSON {verdict,issues:[{key,problem,evidence,suggestion}],strengths:[string]}로 답한다. 숫자와 원작 사실, 행동과 결과가 충돌하는 구체적인 항목을 찾는다. 맵 전용 각색을 실제 NPC 기능으로 오해하지 않는다.',brief:{sourceFacts:fixed.sourceFacts,newContent:{cards,events},existingCardRoles:current.cards,mechanics:'골드 비용·level/density는 먼저 적용. 성공 때 card/gold/potions. 모든 새 선택100%. 머리 보유만으로 열리는 독립6사건. 이미 가진 카드100골드. level1..5,density1..10. HP 비용 없음. 최대체력 상승은 현재 비율 유지. 골드·지정 카드·물약·개인 필드 외 실제 옷·곡식·관계·NPC·공연 기능 없음.',questions:['각 선택의 비용 사용처와 보상 제공자를 설명하는가?','농사·의상·조사·군인·카르미나를 원작 사실 이상으로 부풀리는가?','개인 필드 변화·지정 카드와 행동이 모순되는가?','이름만 다른 식사 또는 정리 선택 반복으로 전부 해결되는가?']}};
fs.writeFileSync(path.join(root,'requests/gourmet-expansion-review-06.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({cards:merged.cards.length,events:merged.events.length,roots:merged.events.filter(e=>!e.previous).length,check}));
