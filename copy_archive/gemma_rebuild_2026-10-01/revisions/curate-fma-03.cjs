// 연금술사 초안의 서사 검토를 반영하고 시간차 후속의 단정과 제작자 설명을 정리한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const base=path.resolve(__dirname,'..');
const original=JSON.parse(fs.readFileSync(path.join(base,'requests/fma-design-02.json'),'utf8'));
const review=JSON.parse(fs.readFileSync(path.join(base,'reviews/fma-editor-02.json'),'utf8')).parsed;
const data=structuredClone(original),changes=[];
assert.equal(review.events.length,data.events.length);
const keySet=new Set();
for(const edited of review.events){
 assert(!keySet.has(edited.key));keySet.add(edited.key);
 const e=data.events.find(x=>x.key===edited.key);assert(e);assert.equal(edited.results.length,e.choices.length);
 if(e.story!==edited.story){changes.push({key:e.key,field:'story',before:e.story,after:edited.story,reason:'Gemma의 짧은 서사 편집을 검토해 채택'});e.story=edited.story;}
 edited.results.forEach((s,i)=>{if(e.choices[i].result!==s){changes.push({key:e.key,field:'choice '+(i+1),before:e.choices[i].result,after:s,reason:'Gemma의 결과 편집을 검토해 채택'});e.choices[i].result=s;}});
}
function edit(key,choice,after,reason){const e=data.events.find(x=>x.key===key),target=choice?e.choices[choice-1]:e,field=choice?'result':'story';changes.push({key,field:choice?'choice '+choice:'story',before:target[field],after,reason});target[field]=after;}
edit('fma_library',1,'셰스카의 기억을 받아 적고 흩어진 내용을 목차에 맞춰 모은다. 무엇을 비교해야 할지 막막했던 기술서에서 필요한 부분을 찾는 순서가 보인다.','독자가 알 필요 없는 능력 제한 해설을 빼고 필사의 결과와 탐색 성장 연결을 보여준다.');
edit('fma_training',0,'이즈미는 사냥터의 발자국과 먹다 남은 열매를 가리키며, 강한 기술부터 찾는 너를 멈춰 세운다. 더 강한 적이 있는 구역도, 적이 여러 방향에서 다니는 구역도 있다. 알폰스는 기본 자세를 되풀이할 자리에서 기다린다.','적의 크기·종류나 일대일 전투를 바꾸는 기능은 없다. 실제 강함·수 선택과 맞춘다.');
edit('fma_trial_footprints',2,'암스트롱의 체술을 보며 힘을 모았다가 내딛는 순서를 익힌다. 이번 연습에서는 지금 맡은 구역에 더 많은 적을 받아들여 빈틈을 살핀다.','중간의 다른 사건으로 적 단계가 낮아질 수 있으므로 과거 강함이 계속 남았다고 단정하지 않는다.');
edit('fma_trial_footprints',3,'밀린 자리까지 숨기지 않고 시험 기록에 남긴다. 의뢰 보수를 정산한 뒤 현재 맡고 있는 구역으로 돌아갈 준비를 한다.','기존 시험의 적 단계가 현재까지 그대로라는 단정을 제거한다.');
edit('fma_after_large',1,'상대가 쓰러진 다음에 어디로 움직일지도 함께 살핀다. 지금보다 더 많은 적을 받아들이고, 눈앞과 주변의 움직임을 함께 읽는 연습을 준비한다.','후속의 현재 적 단계는 선행 직후와 다를 수 있다. 이번 적 수 증가만 설명한다.');
edit('fma_after_large',2,'강한 구역을 정리할 비용을 내고 알폰스와 물러날 위치를 익힌다. 다음에 맡을 범위는 현재의 사냥터 상황을 보며 다시 정한다.','음수 단계는 최저 1로 제한되고 중간 사건도 있으므로 수련 전후의 강함을 고정 비교하지 않는다.');
edit('fma_after_crowd',1,'구역 정리를 맡기고 남은 적의 흐름을 살핀다. 이즈미와 공격하는 순간뿐 아니라 그 뒤 몸을 옮기는 순서까지 되짚는다.','중간 사건과 최저 적 수 제한에 관계없이 성립하도록 정리 결과를 쓴다.');
edit('fma_after_crowd',2,'무리하게 넓혀 보았던 구역을 돌아보며 정리할 곳을 확인한다. 알폰스와 기본 자세를 되풀이한 뒤 지금 감당할 범위를 다시 살핀다.','수련 전보다 여전히 적이 많다는 단정은 현재 필드 값과 다를 수 있어 제거한다.');
const signature=w=>JSON.stringify({world:w.world,cards:w.cards,events:w.events.map(({key,previous,previousChoice,requiredCard,choices})=>({key,previous,previousChoice,requiredCard,choices:choices.map(({label,result,...rest})=>rest)}))});
assert.equal(signature(original),signature(data),'서사 편집은 카드·손익·후속 조건을 변경하지 않아야 한다.');
fs.writeFileSync(path.join(base,'drafts/fma-curated-03.json'),JSON.stringify(data,null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(__dirname,'fma-curation-03.json'),JSON.stringify({gemmaIssues:review.issues,changes,mechanicsUnchanged:true,scope:'편집 검토만 수행. 실제 플레이·밸런스 검증 아님.'},null,2)+'\n',{flag:'wx'});
console.log('아메스트리스 문장 수정과 전후 이유를 보존했습니다.');
