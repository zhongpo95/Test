// 원본 해시와 개인 보유 경로를 확인한 뒤 무료 사건과 새 행동력 카드를 적용한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));const save=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const before=read('revisions/action-scenes-before-95.json'),proposal=read('revisions/action-scenes-curated-96.json'),review=read('reviews/action-scenes-review-97.json');
assert.equal(review.parsed.verdict,'PASS');assert.deepEqual(review.parsed.issues,[]);
const candidates=[];
for(const [file,original] of Object.entries(before)){
 const target=path.join(repo,'content/roguelite',file);assert.equal(crypto.createHash('sha256').update(fs.readFileSync(target)).digest('hex'),original.sha256);
 const d=structuredClone(original.data),free=d.events.find(e=>e.key===proposal.free[file]);assert(free);free.actionCost=0;
 if(file==='04-academy.json'){d.cards.push(proposal.card);d.events.push(...proposal.events);for(const e of proposal.events){assert(d.events.some(x=>x.choices.some(c=>c.card===e.requiredCard)));assert(!e.choices.some(c=>c.card===e.requiredCard));assert.equal(e.choices.length,3);assert.equal(new Set(e.choices.map(c=>c.card)).size,3);}}
 const report=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(d);assert.deepEqual(report.errors,[]);assert.deepEqual(report.warnings,[]);
 candidates.push({file,target,data:d,report});
}
save('revisions/action-scenes-decision-98.json',{before:Object.fromEntries(Object.entries(before).map(([k,v])=>[k,v.sha256])),normalCost:1,freeEvents:6,newCards:1,newEvents:2,reviewRecordIds:[read('reviews/action-scenes-review-96.json').monitorRecordId,review.monitorRecordId],rejectedReview:'오계산·누락된선행카드·골드/AP혼동은97문서에보존했다. 실제JASS실행을별도로검사한다.',changes:'기존5사건은AP0만변경. 학원도시2사건과최대치1카드를추가. 기존카드효과·선택기록번호와리롤비용은유지.',limits:['모델PASS는자문이며원작사실·밸런스·Warcraft동작을증명하지않는다.','맵을만들지않는다.']});
for(const c of candidates)fs.writeFileSync(c.target,JSON.stringify(c.data,null,2)+'\n');
console.log(JSON.stringify(candidates.map(c=>({file:c.file,...c.report}))));
