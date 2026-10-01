// 액셀의 서로 다른 세 카드와 명세서 골드 예외를 원본·수치·후속·역검토와 대조한 뒤 적용한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const fixed=read('requests/axel-card-choices-fixed-83.json'),before=read('before-axel-card-choices-83.json'),candidate=read('revisions/axel-card-choices-curated-84.json');
const file=path.join(repo,'content/roguelite/02-axel.json'),bytes=fs.readFileSync(file);
assert.equal(crypto.createHash('sha256').update(bytes).digest('hex'),fixed.beforeSha256);assert.deepEqual(candidate.world,before.world);
for(const c of before.cards)assert.deepEqual(candidate.cards.find(k=>k.key===c.key),c);assert.deepEqual(candidate.cards,fixed.cards);
for(const [i,e]of candidate.events.entries()){
 const p=fixed.events[i];assert.equal(e.key,p.key);assert.equal(e.story,p.story);assert.equal(e.previous,p.previous);assert.equal(e.previousChoice,p.previousChoice);
 const cards=e.choices.filter(c=>c.card);assert.equal(cards.length,3);assert.equal(new Set(cards.map(c=>c.card)).size,3);assert.equal(e.choices.length,e.key==='axel_stolen_notice'?4:3);
 e.choices.forEach((c,j)=>{for(const k of ['card','card2','cost','gold','level','density','potions','chance'])assert.equal(c[k],p.choices[j][k]);if(c.card){assert.equal(c.gold,0);assert.notEqual(c.card,before.world.entryCard);}else assert.deepEqual(c,before.events.find(x=>x.key==='axel_stolen_notice').choices[1]);});
}
const reviews=[1,2,3].map(n=>read('reviews/axel-card-choices-review-84-'+n+'.json'));for(const r of reviews){assert.equal(r.parsed.verdict,'PASS');assert.deepEqual(r.parsed.issues,[]);}
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
const oldGold=before.events.flatMap(e=>e.choices).filter(c=>c.gold>0).length;assert.equal(oldGold,14);
write('revisions/axel-card-choices-adopted-85.json',candidate);
write('revisions/axel-card-choices-decision-85.json',{sourceRevision:fixed.sourceRevision,beforeFile:fixed.beforeFile,beforeSha256:fixed.beforeSha256,worldUnchanged:true,oldCardsUnchanged:18,newCards:fixed.addedCards,events:16,choices:49,distinctCardsPerEvent:3,directGoldChoices:1,removedDirectGoldChoices:oldGold-1,metadataCorrection:'고정83의 골드 제거 개수12는 집계 오기다. 원본14개 중 명세서 재발행1개만 보존해 실제로13개를 제거했다.',goldException:'명세서 재발행 기존2번230골드는 사건 자체의 돈 문제다. 나머지 세 선택은 크리스 손놀림·크리스 흔적·카즈마 몫의 서로 다른 카드다.',history:'밀린 의뢰와 우리 고정용품의 자기 성공1번을 같은 번호로 유지한다. 후속에서 부모의 줄 카드를 반복하지 않으며 손을 떼는 순서는 후속에서만 준다.',reviews:reviews.map(r=>({recordId:r.monitorRecordId,parsed:r.parsed})),rejectedDrafts:['비용150/100/160을 지급으로 뒤집은 초안','물약·필드 부담 누락과 -1감소 이중 음수','NPC가 칭찬·끄덕임만 되풀이하는 결과'],curation:'21결과를 현장 행동·실제 기억 카드·지속 필드·물약 지급과 별도 작은 반응으로 고쳤다. 원문과모니터링기록은그대로보존한다.',sources:fixed.sources,check,limits:['Gemma세PASS는 자문이다. 실제 수치·참조·개인 후속 검증과 구분한다.','기존 스탯의8개 기억이며 새 전투 기능이 아니다. 실전 선택률과 균형은 미검증이다.','Warcraft·시각·멀티·재미·저장은 미검증이며 맵은 만들지 않는다.']});
fs.writeFileSync(file,JSON.stringify(candidate,null,2)+'\n');
console.log(JSON.stringify({cards:26,events:16,choices:49,directGoldChoices:1,removedDirectGoldChoices:13,reviews:'PASS/PASS/PASS',check}));
