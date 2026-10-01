// 후유키 세 카드 선택의 원본·고정 수치·개인 후속을 대조하고 검토된 두 시로 기억과 함께 적용한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const fixed=read('requests/fuyuki-card-choices-fixed-79.json'),before=read('before-fuyuki-card-choices-79.json'),candidate=read('revisions/fuyuki-card-choices-curated-81.json');
const file=path.join(repo,'content/roguelite/01-fuyuki.json'),bytes=fs.readFileSync(file);
assert.equal(crypto.createHash('sha256').update(bytes).digest('hex'),fixed.beforeSha256);assert.deepEqual(candidate.world,before.world);
for(const c of before.cards)assert.deepEqual(candidate.cards.find(k=>k.key===c.key),c);
assert.deepEqual(candidate.cards,fixed.cards);
for(const [i,e]of candidate.events.entries()){
 const p=fixed.events[i];assert.equal(e.key,p.key);assert.equal(e.story,p.story);assert.equal(e.previous,p.previous);assert.equal(e.previousChoice,p.previousChoice);assert.equal(e.choices.length,3);assert.equal(new Set(e.choices.map(c=>c.card)).size,3);
 e.choices.forEach((c,j)=>{for(const k of ['card','card2','cost','gold','level','density','potions','chance'])assert.equal(c[k],p.choices[j][k]);assert.equal(c.gold,0);assert.notEqual(c.card,before.world.entryCard);});
}
const reviews=[1,2,3].map(n=>read('reviews/fuyuki-card-choices-review-81-'+n+'.json'));
for(const r of reviews){assert.equal(r.parsed.verdict,'PASS');assert.deepEqual(r.parsed.issues,[]);}
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
write('revisions/fuyuki-card-choices-adopted-82.json',candidate);
write('revisions/fuyuki-card-choices-decision-82.json',{sourceRevision:'5c1ec662b1a90a8cd521358ba722fc7a4de35dc4',beforeFile:fixed.beforeFile,beforeSha256:fixed.beforeSha256,worldUnchanged:true,oldCardsUnchanged:21,newCards:fixed.addedCards,events:16,choices:48,distinctCardsPerEvent:3,directGoldChoices:0,replacedEntryCardChoices:4,history:'학교연결끊기1번과타이가질문1번후속유지',reviews:reviews.map(r=>({recordId:r.monitorRecordId,parsed:r.parsed})),rejectedDrafts:['79-1의사건병합/문장메타데이터유입','79-2의다른언어혼입·아처카드효과혼동·물약/적수누락'],curation:'80재요청의구조는통과했지만효과/부담/물약을빼거나NPC성장으로썼다.20결과를실제지정카드기억·필드·물약지급과별개인물반응으로고쳤다.',check,limits:['Gemma세PASS는자문이며숫자·참조·후속검사와분리한다.','카드단위나새전투기능을추가하지않았다.두기억은기존공격력%/행동속도/피해감소효과다.','Warcraft·화면·멀티플레이·재미·실전밸런스는미검증이고맵은만들지않는다.']});
fs.writeFileSync(file,JSON.stringify(candidate,null,2)+'\n');
console.log(JSON.stringify({cards:23,events:16,choices:48,newCards:2,reviews:'PASS/PASS/PASS',check}));
