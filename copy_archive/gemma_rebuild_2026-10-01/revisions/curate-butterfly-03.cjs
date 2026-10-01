// 밤길 집필문에서 카드 상실·재발견·새 적 종류와 제작 해설을 고치고 역검토에 넘긴다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..');
const data=JSON.parse(fs.readFileSync(path.join(root,'requests/butterfly-design-02.json'),'utf8'));
const parsed=JSON.parse(fs.readFileSync(path.join(root,'drafts/butterfly-text-02.json'),'utf8')).parsed;
const signature=d=>JSON.stringify({world:d.world,cards:d.cards,events:d.events.map(e=>({key:e.key,previous:e.previous,previousChoice:e.previousChoice,requiredCard:e.requiredCard,choices:e.choices.map(({result,...b})=>b)}))});
const before=signature(data),changes=[];
assert.equal(parsed.events.length,data.events.length);
for(const e of data.events){const text=parsed.events.find(t=>t.key===e.key);assert(text);assert.equal(text.results.length,e.choices.length);e.story=text.story;e.failure=text.failure;for(let i=0;i<e.choices.length;i++)e.choices[i].result=text.results[i];}
function edit(key,field,value,reason){const e=data.events.find(e=>e.key===key),old=field==='story'?e.story:field==='failure'?e.failure:e.choices[field-1].result;changes.push({key,field,before:old,after:value,reason});if(field==='story')e.story=value;else if(field==='failure')e.failure=value;else e.choices[field-1].result=value;}
edit('kny_night_path',1,'소리를 따라 길을 잃은 보급꾼을 찾고 정찰 보수를 받았다. 젠이츠가 소리가 겹쳐도 움직일 순간에 힘을 모으는 준비를 보여 주지만, 맡은 사냥 구역에는 더 강한 적이 남는다.','소리의 정체를 찾는 성공과 실제 정찰 보수·남은 강함을 함께 보여준다.');
edit('kny_night_path',2,'이노스케가 보여 준 자세로 공격을 이어가며 길 일부를 열었다. 적이 드나드는 구역을 더 넓게 맡고 방어의 빈틈도 감수하지만, 보급꾼의 행방은 아직 확인하지 못했다.','짐승이라는 새 적 종류를 약속하지 않고 적 수 증가·방어 패널티와 맞춘다.');
edit('kny_night_path',4,'흩어진 짐을 모아 운반할 길을 좁히고 일당을 받았다. 한쪽 길의 적 부담은 줄였지만, 짐을 내려놓은 기록에는 여전히 보급꾼의 행방이 빈칸으로 남았다.','수송 부담만 감소한다고 설명하지 않고 실제 개인 적 수 감소에 연결한다.');
edit('kny_night_path','failure','보급꾼의 목소리로 짐작한 소리는 다른 울음이었고, 준비비를 쓴 수색은 허탕으로 끝났다. 사람을 찾지 못한 기록과 맡은 구역의 더 강한 적이 남아 돌아갈 짐을 다시 꾸린다.','새 종족과 기술 지급 여부를 해설하지 않고 실패 지출·미발견·남은 위험을 장면으로 쓴다.');
edit('kny_night_found','story','앞선 수색에서 찾았던 보급꾼이 돌아온 길을 기록지에 짚는다. 젠이츠는 소리를 듣는 것과 그 순간 몸을 움직이는 것은 다르다고 말하고, 카나오가 반응을 확인할 자리를 가리킨다. 정찰 뒤 어떤 준비를 더할지 정한다.','이미 찾은 사람을 후속에서 새로 발견하지 않는다.');
edit('kny_night_found',1,'훈련 도구를 마련하고 정찰 기록에 맞춰 발을 옮길 순간을 연습했다. 카나오에게 상대의 움직임을 읽고 정확히 반응하는 법을 배워 앞서 익힌 준비에 더했다.','기존 젠이츠 카드를 잃는다는 문장은 오류다. 새 카드만 추가되고 기존 카드는 유지된다.');
edit('kny_night_wrong',1,'새 준비 비용을 내고 시노부와 다음 전투에 가져갈 약을 정리했다. 비어 있는 수색 기록은 덮어 두고, 무리하게 버티기 전에 회복을 이어갈 준비를 챙긴다.','원작 질병 치료 여부나 환불 불가라는 제작 해설을 결과에 복사하지 않는다.');
assert.equal(signature(data),before);
fs.writeFileSync(path.join(root,'drafts/butterfly-curated-03.json'),JSON.stringify(data,null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(root,'revisions/butterfly-curation-03.json'),JSON.stringify({gemmaIssues:parsed.issues,mechanicsUnchanged:true,changes},null,2)+'\n',{flag:'wx'});
const request={review:true,system:'한국어 사건 검토자다. 비용·보상·필드 변화와 결과가 맞는지, 이전 사건에서 이미 끝난 일을 후속에서 다시 하는지, 새 기술·동료·적 종류를 약속하는지 살핀다. 모든 카드 효과는 유지되며 새 카드가 기존 카드를 삭제하지 않는다. 이전 사건 기록은 개인의 성공/실패이고 후속에서 다른 사건을 사이에 겪을 수 있다. NPC는 이야기 인물이며 실제 사냥 동료를 생성하지 않는다. 근거 없이 지적 없음만 반환하지 말고 문제 있으면 issues에 key와 구체적인 이유를 적는다. 좋은 문장으로 다시 집필할 필요는 없다.',schema:{type:'object',additionalProperties:false,required:['issues','assessment'],properties:{issues:{type:'array',items:{type:'object',additionalProperties:false,required:['key','reason'],properties:{key:{type:'string'},reason:{type:'string'}}}},assessment:{type:'string'}}},brief:{canonBoundary:data.canonBoundary,cards:data.cards.map(c=>({key:c.key,name:c.name,effects:c.effects})),events:data.events}};
fs.writeFileSync(path.join(root,'requests/butterfly-review-03.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});
console.log('나비저택 결과 7곳 수정. 카드·손익·기록 조건 일치 확인.');
