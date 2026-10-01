// Gemma 재검토의 유효한 문장 모호함과 잘못된 효과 해석을 나눠 두 번째 검토를 요청한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const data=read('revisions/aincrad-expansion-curated-53.json'),review=read('reviews/aincrad-expansion-review-53.json').parsed,changes=[];
assert.equal(review.verdict,'REVISE');
function edit(key,field,after,reason){const event=data.events.find(e=>e.key===key),parts=field.split('.');let o=event;for(const k of parts.slice(0,-1))o=o[k];const last=parts.at(-1);changes.push({key,field,before:o[last],after,reason});o[last]=after;}
edit('sao_girl_unanswered','story','네가 앉아 있는 소녀에게 어디서 왔냐고 묻자 키리토도 막 같은 질문을 했다고 말한다. 아스나는 더 묻기 전에 앉을 곳부터 비우고 있지만 기억을 잃은 소녀에게는 아직 이어서 할 말이 없다. 네 손에는 자기 외투와 전달할 담요가 남아 있다.','여행자가 소녀에게 질문했다는 주어와 대상을 직접 붙여 모호함을 줄인다. 소녀가 먼저 질문했다는 모델의 해석은 채택하지 않는다.');
edit('sao_argo_second_question','choices.0.result','정보료120골드를 내고 기억한 갈림길과 상대 정보를 연결했다. 돌아와 한 문장을 더한 기억으로 일반 몬스터 피해와 치명타 피해가 늘고 냈던 정보료와 같은 액수의 확인 보수120골드도 받았다. 아르고는 이번에 물었던 부분과 처음 들었던 귀환 답을 따로 짚는다.','cost120을 먼저 소모한 뒤 성공시에만 gold120을 받는 합계0을 명확히 쓴다. 순이익120 또는 비용환불 기능으로 바꾸지 않는다.');
edit('sao_rabbit_table','choices.0.result','식탁 준비값170골드를 내고 아스나의 식사 준비를 도왔다. 최대 체력이 늘고 체력이65%이상일 때 가하는 피해도 늘었다. 아스나는 키리토와 나눌 고기부터 살피고 도구를 가져올 쪽을 가리킨다.','고체력 대미지가 받는 피해 감소와 다르다는 조건을 명시한다. 모델이 제안한 공격력 증가로 바꾸지 않는다.');
edit('sao_lakeside_wait','choices.2.result','더 많은 개인 사냥을 맡는 부담을 택하고 아스나와 몸 상태를 지킬 준비를 했다. 최대 체력이 늘고 체력이65%이상일 때 가하는 피해도 늘었다. 아스나는 기다릴 자리에 앉고 네가 가져갈 보급을 옆에 남긴다.','같은 식사 카드 지급의 두 결과가 같은 조건부 가하는 피해를 설명하게 한다.');
write('revisions/aincrad-review-decision-53.json',{review,decision:'수치 변경 없이 질문 주어·동액 비용과 보수·고체력 조건을 명확히 하고 재검토한다.',issueDecisions:[
 {key:'sao_asuna_meal_description',validity:'현재 문장은 받는 피해 감소라고 하지 않았다. 몸 상태라는 맥락만으로 감소라고 판정한 근거는 약하다.',action:'65%이상일때가하는피해를명시하되공격력증가로바꾸라는제안은잘못된스탯이라폐기.'},
 {key:'sao_argo_second_question_gold',validity:'결과에비용120과보수120은이미존재했다.추가밸런스변경의근거는아니지만동액여부를명확히할수있다.',action:'같은액수라고서술하고성공시차액0·실패시손실120의검사를유지.'},
 {key:'sao_girl_unanswered_logic',validity:'여행자가소녀에게묻는문장이다.소녀가먼저질문했다고유지하라는제안은원래발단과맞지않는다.',action:'주어와대상을붙여명확히쓰고모델의주체반전제안은폐기.'}
],changes,numericExceptions:[],limits:'모델REVISE/PASS는증거가아니므로각제안을고정수치와문장으로따로대조한다.'});
write('revisions/aincrad-expansion-curated-54.json',data);
const request=read('requests/aincrad-expansion-review-53.json');
request.system='한국어 독립 검토자다. 실제 문장과 effects·cost·gold·level·density·chance를 직접 대조해 PASS 또는 REVISE를 판단한다. 문장에 없는 피해 감소나 소녀의 질문을 상상하지 않는다. 새로운 스탯이나 수치 변경을 권고하지 않는다. 모호함과 실제 모순을 구분한다.';
request.brief.content.events=request.brief.content.events.map(e=>data.events.find(x=>x.key===e.key));
request.brief.questions=['실제결과의비용·골드·물약·지속필드·지정카드가데이터와모순되는경우만찾는다.','healthy_damage는65%이상체력일때가하는대미지이며attack_percent나damage_reduction이아니다.','소녀에게먼저질문한주체는여행자다.소녀는아직대답하지못한다.','정보후속1번은cost120을먼저지불하고70%성공때card와gold120을받는다.성공차액0·실패손실120이며의도된위험선택이다.','원작역할대체·정지중실제추가처치·새NPC동행·소생·관리자권한을약속하는지확인한다.'];
write('requests/aincrad-expansion-review-54.json',request);
let adopter=fs.readFileSync(path.join(root,'requests/adopt-aincrad-expansion-53.cjs'),'utf8');adopter=adopter.replaceAll('53.json','54.json');
fs.writeFileSync(path.join(root,'requests/adopt-aincrad-expansion-54.cjs'),adopter,{flag:'wx'});
console.log(JSON.stringify({changes:changes.length,numericChanges:0}));
