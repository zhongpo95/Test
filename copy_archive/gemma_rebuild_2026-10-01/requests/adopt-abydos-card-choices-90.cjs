// 아비도스 세 카드의 원본·고정 수치·개인 후속과 실패 문구 재검토를 대조하여 적용한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const fixed=read('requests/abydos-card-choices-fixed-86.json'),before=read('before-abydos-card-choices-86.json'),candidate=read('revisions/abydos-card-choices-curated-89.json'),file=path.join(repo,'content/roguelite/03-abydos.json'),bytes=fs.readFileSync(file);
assert.equal(crypto.createHash('sha256').update(bytes).digest('hex'),fixed.beforeSha256);assert.deepEqual(candidate.world,before.world);assert.deepEqual(candidate.cards,fixed.cards);
for(const c of before.cards)assert.deepEqual(candidate.cards.find(k=>k.key===c.key),c);
for(const [i,e]of candidate.events.entries()){
 const p=fixed.events[i];for(const k of ['key','story','previous','previousChoice','requiredCard'])assert.equal(e[k],p[k]);assert.equal(e.choices.length,3);assert.equal(new Set(e.choices.map(c=>c.card)).size,3);
 e.choices.forEach((c,j)=>{for(const k of ['card','card2','cost','gold','level','density','potions','chance'])assert.equal(c[k],p.choices[j][k]);assert(c.card);assert.equal(c.gold,0);assert.notEqual(c.card,before.world.entryCard);});
 if(e.failure)assert(!e.failure.includes('보수'));
}
const reviews=[1,2,3].map(n=>read('reviews/abydos-card-choices-review-88-'+n+'.json')),failureReview=read('reviews/abydos-failure-review-89.json');
for(const r of [...reviews,failureReview]){assert.equal(r.parsed.verdict,'PASS');assert.deepEqual(r.parsed.issues,[]);}
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
write('revisions/abydos-card-choices-adopted-90.json',candidate);
write('revisions/abydos-card-choices-decision-90.json',{sourceRevision:fixed.sourceRevision,beforeFile:fixed.beforeFile,beforeSha256:fixed.beforeSha256,worldUnchanged:true,oldCardsUnchanged:20,newCards:fixed.addedCards,events:18,choices:54,directGoldChoices:0,removedGoldChoices:13,removedFourthGoldChoices:4,distinctCardsPerEvent:3,history:fixed.policy.history,reviews:[...reviews,failureReview].map(r=>({recordId:r.monitorRecordId,parsed:r.parsed})),curation:'86원문을 편집하지 않고87에서 현장 행동과 반응만 재요청했다.88은23결과를 주체·남은 문제와 실제 보상에 맞추고89에서는 실패문에 남은 폐기 보수를 제거했다.',sources:fixed.sources,check,limits:['네PASS도자문이다. 실제 수치·참조·역할·실패 문구와 분기 검증을 별도로 수행한다.','성장10개 기억은 기존 스탯이다. 실제 선택률·밸런스·재미는 미검증이다.','Warcraft·실제시각·멀티·저장은 미검증이고 맵은 만들지 않는다.']});
fs.writeFileSync(file,JSON.stringify(candidate,null,2)+'\n');console.log(JSON.stringify({cards:30,events:18,choices:54,removedGoldChoices:13,reviews:'PASS/PASS/PASS 및 수정사건PASS',check}));
