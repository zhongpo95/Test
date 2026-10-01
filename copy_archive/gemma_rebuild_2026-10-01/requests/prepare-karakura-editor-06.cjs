// 숫자 해석 오류가 반복된 검토를 서사 편집으로 좁혀 실제 설정·행동 연결을 다시 확인한다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'../../..'),w=JSON.parse(fs.readFileSync(path.join(root,'content/roguelite/10-karakura.json'),'utf8'));
const cards=new Map(w.cards.map(c=>[c.key,c]));
const schema={type:'object',properties:{findings:{type:'array',items:{type:'object',properties:{key:{type:'string'},choice:{type:'integer'},reason:{type:'string'},suggestion:{type:'string'}},required:['key','choice','reason','suggestion'],additionalProperties:false}}},required:['findings'],additionalProperties:false};
const brief={confirmedFacts:['우라하라 상점은 겉으로 과자 가게이며 사신에게 물품을 제공해 현세 활동을 돕는다.','우류는 퀸시이며 손재주와 바느질에 능하다.','오리히메는 순순육화로 사물의 현상을 거절하며 동료를 생각한다.','콘은 인형에 머무는 개조혼백이며 이치고의 몸을 지킨다.','이치고는 동료를 지키는 사신대행이다.','차드는 약한 사람을 몸으로 지킨다.','요루이치는 보법의 달인이다.','루키아는 현세의 사신 임무를 수행하는 이치고의 동료다.'],events:w.events.map(e=>({key:e.key,problem:e.story,previous:e.previous?{event:e.previous,result:w.events.find(p=>p.key===e.previous).choices[Math.abs(e.previousChoice)-1].result,failure:e.previousChoice<0}:null,choices:e.choices.map(b=>({action:b.label,result:b.result,associatedCard:b.card?{name:cards.get(b.card).name,meaning:cards.get(b.card).canonFact}:null})),failure:e.failure}))};
const system='한국어 사건의 서사 편집자다. 능력치 계산이나 밸런스 숫자는 검토하지 않는다. 확인한 공식 사실과 맵 창작 상황을 구분한다. 다른 문제로 새로 쓰기보다, 여기서 앞뒤가 맞지 않거나 인물의 역할과 연결이 얕은 최대4개 사례만 적는다. 문제 없는 목록을 채우지 않아도 된다. 선행 행동과 결과가 후속의 문제로 자연스럽게 이어지는지, 결과가 아직 남아야 할 위험을 이미 해결했다고 하는지, 사람·물건의 역할이 어색한지 확인한다. 단순한 NPC 이름 바꾸기로 보이는 행동이면 어떤 확인 사실을 이용하면 더 자연스러운지 제안한다. 이야기의 NPC 묘사는 문장 속 사건이며 새 NPC 시뮬레이션이나 새 기술을 플레이어에게 지급한다는 뜻이 아니다. 현재 체력 지불, 새 관계·가방·퀘스트 시스템, 실시간 배송 수송을 권하지 않는다. 오리히메의 복원은 현재체력 비용이 아니다. 후속 사건은 즉시 확정 등장이 아니므로 구체적인 길 안내만으로 후속 출현을 강요했다고 오독하지 않는다.';
fs.writeFileSync(path.join(__dirname,'karakura-editor-06.json'),JSON.stringify({review:true,schema,system,brief},null,2)+'\n',{flag:'wx'});
console.log('숫자와 분리한 서사 편집 요청을 보존했습니다.');
