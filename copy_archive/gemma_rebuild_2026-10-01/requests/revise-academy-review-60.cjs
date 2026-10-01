// 학원도시 검토의 밀도 변화와 선지불 판정을 명확히 하고 실제 지원되는 감소를 유지한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const candidate=read('revisions/academy-expansion-curated-59.json'),review=read('reviews/academy-expansion-review-59.json').parsed,changes=[];
assert.equal(review.verdict,'REVISE');
const vending=candidate.events.find(e=>e.key==='academy_vending_left_coin'),follow=candidate.events.find(e=>e.key==='academy_drink_after_vending');
function edit(o,k,v,key,reason){changes.push({key,field:k,before:o[k],after:v,reason});o[k]=v;}
edit(vending.choices[2],'result',vending.choices[2].result.replace('더 많은 개인 사냥을 맡는 부담을 택하고','개인 사냥의 몬스터 수 단계를1올리는 부담을 택하고'),vending.key+'#3','더 많은 개인 사냥이 지속 밀도+1임을 명시한다. 나눈 몫의 카드 효과 자체가 강화된다는 모델 제안은 실제 지급과 달라 쓰지 않는다.');
edit(follow,'failure','다음 보급값120골드를 먼저 낸 뒤 준비를 끝낼 때를 맞추지 못했다. 카드는 얻지 못하고 지불한120골드는 돌아오지 않는다. 미코토는 아직 뜯지 않은 음료를 내려놓고 토우마는 남은 짐부터 본다.',follow.key,'확률 판정 전에 지불한 비용이 실패에도 유지된다고 명시한다.');
const source=fs.readFileSync(path.join(repo,'System/ExpeditionPrototype.j'),'utf8');assert(source.includes('set ProtoDensity[pid] = IMaxBJ(1, ProtoDensity[pid] + ProtoBranchDensity[key])'));
assert(source.indexOf('set ExpGold[pid] = ExpGold[pid] - ProtoBranchCost[key]')<source.indexOf('set roll = GetRandomInt(1, 100)'));
write('revisions/academy-review-decision-59.json',{review,decisions:[{key:vending.key,decision:'표현 명확화',reason:'이미 더 많은 개인 사냥이라고 적혀 있지만 단계+1을 명시한다. 카드의 효과 강화로 바꾸지 않는다.'},{key:'academy_unanswered_promise',decision:'제안 기각',reason:'density는 현재 수가 아니라 변화량이다. ProtoResolve는 음수 변화량을 더하고 최저1로 제한한다. -1은 적 수 단계 감소이며 결과도 감소로 적혀 있다. 0으로 바꾸면 선택지의 약속을 훼손한다.'},{key:follow.key,decision:'표현 명확화',reason:'현재 함수가 비용을 먼저 차감한 뒤 확률 판정한다. 실패 문장에 먼저 지불했다는 순서를 명시하고120골드 차감은 유지한다.'}],changes,numericExceptions:[],limits:'원문 REVISE를 보존하며 판정의 근거를 별도 기록한다. 실제 Warcraft 검증은 아니다.'});
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
write('revisions/academy-expansion-curated-60.json',candidate);
const request=read('requests/academy-expansion-review-59.json');
request.brief.events=request.brief.events.map(e=>candidate.events.find(x=>x.key===e.key));
request.brief.mechanics.field='level과density는 절대값이 아니라 개인 사냥 단계의 변화량이다. 양수는 증가, 음수는 감소다. 적용 후 최저1이며 최대강함5/수10이다. 이후 개인 사냥에 지속한다.';
request.brief.mechanics.reward='비용을 먼저 지불한 뒤chance%로 성공을 판정한다. 실패해도 지불한 비용/필드 변화/AP1은 유지되며 카드/골드/물약은 얻지 않는다. 이미 보유한 카드는100골드로 대체한다.';
write('requests/academy-expansion-review-60.json',request);
console.log(JSON.stringify({changes:changes.length,numericExceptions:0,check}));
