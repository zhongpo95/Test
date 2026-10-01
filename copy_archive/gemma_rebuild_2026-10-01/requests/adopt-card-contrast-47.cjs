// 세 카드의 성장 목적과 관련 결과만 교체하고 원본·검토 근거를 보존한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const curated=read('revisions/card-contrast-curation-47.json'),review=read('reviews/card-contrast-review-47.json').parsed;
assert.equal(review.verdict,'PASS');assert.deepEqual(review.issues,[]);
const adopted=[];
for(const item of curated.candidates){
 const file=path.join(repo,'content/roguelite',item.file),bytes=fs.readFileSync(file),before=JSON.parse(bytes),expected=structuredClone(before),candidate=read(item.candidateFile);
 const allowed=curated.changes.filter(c=>c.key===item.cardKey||before.events.some(e=>c.key.startsWith(e.key+'#')));
 for(const change of allowed){
  let target;if(change.key===item.cardKey){assert(['effects','keyword','canonFact'].includes(change.field));target=expected.cards.find(c=>c.key===change.key);}
  else {assert.equal(change.field,'result');const [key,choice]=change.key.split('#');target=expected.events.find(e=>e.key===key).choices[Number(choice)-1];}
  assert.deepEqual(target[change.field],change.before);target[change.field]=change.after;
 }
 assert.deepEqual(candidate,expected);
 const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
 const backup='before-'+item.file.replace('.json','')+'-card-contrast-47.json';fs.writeFileSync(path.join(root,backup),bytes,{flag:'wx'});
 adopted.push({file:item.file,card:item.cardKey,backup,sha256:crypto.createHash('sha256').update(bytes).digest('hex'),changedFields:allowed,check});
 fs.writeFileSync(file,JSON.stringify(candidate,null,2)+'\n');
}
const pairs=[];
for(const file of fs.readdirSync(path.join(repo,'content/roguelite')).filter(x=>x.endsWith('.json'))){const d=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite',file),'utf8'));for(const a of d.cards)for(const b of d.cards){if(a.key===b.key||a.grade!==b.grade)continue;const av=Object.fromEntries(a.effects.map(e=>[e.stat,e.value])),bv=Object.fromEntries(b.effects.map(e=>[e.stat,e.value])),keys=[...new Set([...Object.keys(av),...Object.keys(bv)])];if(keys.every(k=>(av[k]||0)>=(bv[k]||0))&&keys.some(k=>(av[k]||0)>(bv[k]||0)))pairs.push({file,stronger:a.key,weaker:b.key});}}
assert.deepEqual(pairs,[]);
write('revisions/card-contrast-decision-47.json',{sourceRevision:'3e1d38e',review,adopted,beforePairs:3,afterPairs:pairs,decision:'같은 머리·등급의 기본 효과가 모두 낮은 세 카드에서 성장 목적을 구분했다. 사건 접근 비용·필드 부담·확률·등급·각성·머리 수치는 유지한다.',limits:['기본 효과 성분별 비교는 서로 다른 스탯의 가치 환산과 실전 밸런스를 입증하지 않는다.','추가 최대 체력은 현재 체력 즉시 치유가 아니다. 차지 속도는 해당 준비 구간만 적용하며 모든 행동속도와 구분한다.','원작 설정은 역할의 근거이며 맵 수치와 효과는 각색이다. Warcraft·화면·멀티플레이·재미·밸런스 미검증.']});
console.log(JSON.stringify({adopted:adopted.length,beforePairs:3,afterPairs:pairs.length}));
