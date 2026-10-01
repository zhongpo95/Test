// 학원도시 원본 해시·세 카드·자기 후속을 대조하고 검토된 콘텐츠만 적용한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..'),read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const fixed=read('requests/academy-card-choices-fixed-91.json'),before=read(fixed.beforeFile),candidate=read('revisions/academy-card-choices-curated-92.json'),file=path.join(repo,'content/roguelite/04-academy.json');
assert.equal(crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex'),fixed.beforeSha256);assert.deepEqual(candidate.world,before.world);assert.deepEqual(candidate.cards,fixed.cards);
for(const c of before.cards)assert.deepEqual(candidate.cards.find(x=>x.key===c.key),c);
for(const [i,e]of candidate.events.entries()){const p=fixed.events[i];for(const k of ['key','story','previous','previousChoice','requiredCard'])assert.equal(e[k],p[k]);assert.equal(e.choices.length,3);assert.equal(new Set(e.choices.map(c=>c.card)).size,3);e.choices.forEach((c,j)=>{for(const k of ['card','card2','cost','gold','level','density','potions','chance'])assert.equal(c[k],p.choices[j][k]);assert(c.card);assert.equal(c.gold,0);});if(e.failure)assert(!e.failure.includes('보수'));}
const reviews=[1,2,3].map(n=>read('reviews/academy-card-choices-review-92-'+n+'.json'));for(const r of reviews){assert.equal(r.parsed.verdict,'PASS');assert.deepEqual(r.parsed.issues,[]);}
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
write('revisions/academy-card-choices-adopted-93.json',candidate);
write('revisions/academy-card-choices-decision-93.json',{sourceRevision:fixed.sourceRevision,beforeFile:fixed.beforeFile,beforeSha256:fixed.beforeSha256,oldCardsUnchanged:21,worldUnchanged:true,newCards:fixed.addedCards,events:18,choices:54,directGoldChoices:0,removedGoldChoices:16,history:fixed.policy.history,removedChoices:fixed.removedChoices,reviews:reviews.map(r=>({recordId:r.monitorRecordId,parsed:r.parsed})),curation:'91집필의반복미소/끄덕임·대사주체·표식버림오독을92에서고쳤다. 별도로폐기된골드보수가실패문구에도남지않도록확인했다.',limits:['세PASS는자문이다. 강점에언급한시간정지는이사건의설정근거로사용하지않는다.','실제조건·수치·자기후속과분기를별도검사한다.','맵을만들지않고Warcraft·시각·멀티·저장·재미·실전밸런스는미검증이다.'],check});
fs.writeFileSync(file,JSON.stringify(candidate,null,2)+'\n');console.log(JSON.stringify({cards:29,events:18,choices:54,removedGoldChoices:16,check}));
