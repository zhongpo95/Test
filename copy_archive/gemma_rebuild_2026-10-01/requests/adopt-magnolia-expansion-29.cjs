// 마그놀리아 독립 사건의 고정 수치와 재검토 결과를 대조하고 원본 보존 후 반영한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const file=path.join(repo,'content/roguelite/09-magnolia.json'),old=fs.readFileSync(file),before=JSON.parse(old);
const candidate=JSON.parse(fs.readFileSync(path.join(root,'revisions/magnolia-expansion-curated-29.json'),'utf8'));
const fixed=JSON.parse(fs.readFileSync(path.join(root,'requests/magnolia-expansion-fixed-28.json'),'utf8'));
assert.deepEqual(candidate.world,before.world);assert.deepEqual(candidate.cards.slice(0,before.cards.length),before.cards);assert.deepEqual(candidate.events.slice(0,before.events.length),before.events);
for(const c of fixed.cards){const x=candidate.cards.find(x=>x.key===c.key);assert.deepEqual(x,c);}
for(const e of fixed.events){const x=candidate.events.find(x=>x.key===e.key);assert.equal(x.previous,null);assert.equal(x.previousChoice,0);assert.equal(x.requiredCard,null);e.choices.forEach((b,i)=>{for(const k of ['card','card2','cost','gold','level','density','potions','chance'])assert.equal(x.choices[i][k],b[k]);});}
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
const review=JSON.parse(fs.readFileSync(path.join(root,'reviews/magnolia-expansion-review-29.json'),'utf8')).parsed;assert.equal(review.verdict.toUpperCase(),'PASS');assert.deepEqual(review.issues,[]);
const backup=path.join(root,'before-magnolia-expansion-29.json');fs.writeFileSync(backup,old,{flag:'wx'});
fs.writeFileSync(path.join(root,'revisions/magnolia-expansion-decision-29.json'),JSON.stringify({sourceRevision:'51b0c55',beforeFile:path.relative(repo,backup).replaceAll('\\','/'),beforeSha256:crypto.createHash('sha256').update(old).digest('hex'),review,reviewDisposition:[],decision:'독립6사건·관련6카드 채택.',candidateCheck:check,limits:['공식 코에이테크모 인물 소개 다섯 명과 애니메이션 100년 퀘스트 루시 소개 본문을 읽었다. 서로 다른 여행 시점이며 전체 만화·애니메이션·게임·이미지 픽셀과 한국어 공식 현지화 이름 전체는 미검토.','Warcraft 런타임·화면·멀티플레이·재미·밸런스 미검증.']},null,2)+'\n',{flag:'wx'});
fs.writeFileSync(file,JSON.stringify(candidate,null,2)+'\n');console.log(JSON.stringify({cards:candidate.cards.length,events:candidate.events.length,roots:candidate.events.filter(e=>!e.previous).length,check}));
