// 서로 다른 두 사건의 골드 판정을 혼동한 재검토를 분리하고 수치 변경 제안은 보존해 기각한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const data=read('revisions/aincrad-expansion-curated-54.json'),review=read('reviews/aincrad-expansion-review-54.json').parsed;
assert.equal(review.verdict,'REVISE');
write('revisions/aincrad-review-decision-54.json',{review,decision:'두 사건의 수치를 통일하라는 제안은 기각하고 비용·성공 보수를 각각 분리해 재검토한다.',issueDecisions:[
 {key:'sao_argo_return',validity:'정보료120지불과같은액수확인보수120수령은정확히차액0이다.문장에새보너스나순이익을추가하지않았다.',action:'수치를유지하고사건이름을붙인각각의성공·실패예제로별도대조한다.'},
 {key:'sao_lakeside_wait',validity:'정보후속은sao_argo_second_question이고낚시는sao_lakeside_wait다.다른사건의수치를일치시킬이유가없다.',action:'원작관련성·가격·확률이서로다른두사건을통일하라는제안은폐기한다.'}
],cases:[{event:'sao_argo_second_question',cost:120,gold:120,chance:70,successBalanceChange:0,failureBalanceChange:-120},{event:'sao_lakeside_wait',cost:150,gold:240,chance:65,successBalanceChange:90,failureBalanceChange:-150}],numericExceptions:[],revisit:'실제 JASS가 실패 보수를 지급하거나 두 사건의 필드를 공유한다는 실행 증거가 발견되면 원인을 다시 검사한다.'});
const focused=data.events.filter(e=>['sao_argo_second_question','sao_lakeside_wait'].includes(e.key)).map(e=>({key:e.key,story:e.story,firstChoice:e.choices[0],failure:e.failure,calculation:{paidBeforeRoll:e.choices[0].cost,receivedOnlyOnSuccess:e.choices[0].gold,successNetGold:e.choices[0].gold-e.choices[0].cost,failureNetGold:-e.choices[0].cost}}));
write('requests/aincrad-focused-review-55.json',{review:true,schema:read('requests/mitakihara-expansion-review-20.json').schema,system:'한국어 독립 검토자다. 각 사건을 별도로 비교한다. firstChoice.result와 해당 객체 calculation 사이에 실제 숫자·지급 오류가 있으면 REVISE, 없으면 PASS로 판단한다. 다른 사건의 값은 이 사건의 규칙이 아니다. 가격 통일이나 밸런스 재설계를 제안하지 않는다.',brief:{events:focused,rule:'골드를 먼저 cost만큼 지불한다. 성공시에만 card와gold를지급하며 실패에는둘다없다. 각calculation은그사건의firstChoice값으로계산했다. 가령120을내고120을받으면골드차액0이고150을내고240을받으면차액90이다. 서로다른두사건은가격과확률이달라도된다.'}});
let adopter=fs.readFileSync(path.join(root,'requests/adopt-aincrad-expansion-54.cjs'),'utf8');adopter=adopter.replace("review=read('reviews/aincrad-expansion-review-54.json').parsed","review=read('reviews/aincrad-focused-review-55.json').parsed");
adopter=adopter.replace("review,decision:","review,priorReviews:[read('revisions/aincrad-review-decision-53.json'),read('revisions/aincrad-review-decision-54.json')],decision:");
fs.writeFileSync(path.join(root,'requests/adopt-aincrad-expansion-55.cjs'),adopter,{flag:'wx'});
console.log('서로 다른 정보 후속과 낚시의 비용·보수만 분리해 재검토한다.');
