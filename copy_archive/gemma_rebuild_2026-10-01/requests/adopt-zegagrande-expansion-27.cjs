// 제가 그랑데 공역 독립 사건의 고정 수치와 재검토 결과를 대조하고 원본 보존 후 반영한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const file=path.join(repo,'content/roguelite/07-zegagrande.json'),old=fs.readFileSync(file),before=JSON.parse(old);
const candidate=JSON.parse(fs.readFileSync(path.join(root,'revisions/zegagrande-expansion-curated-27.json'),'utf8'));
const fixed=JSON.parse(fs.readFileSync(path.join(root,'requests/zegagrande-expansion-fixed-25.json'),'utf8'));
assert.deepEqual(candidate.world,before.world);assert.deepEqual(candidate.cards.slice(0,before.cards.length),before.cards);assert.deepEqual(candidate.events.slice(0,before.events.length),before.events);
for(const c of fixed.cards){const x=candidate.cards.find(x=>x.key===c.key);assert.deepEqual(x,c);}
for(const e of fixed.events){const x=candidate.events.find(x=>x.key===e.key);assert.equal(x.previous,null);assert.equal(x.previousChoice,0);assert.equal(x.requiredCard,null);e.choices.forEach((b,i)=>{for(const k of ['card','card2','cost','gold','level','density','potions','chance'])assert.equal(x.choices[i][k],b[k]);});}
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
const review=JSON.parse(fs.readFileSync(path.join(root,'reviews/zegagrande-expansion-review-27.json'),'utf8')).parsed;assert.equal(review.verdict.toUpperCase(),'PASS');assert.deepEqual(review.issues,[]);
const backup=path.join(root,'before-zegagrande-expansion-27.json');fs.writeFileSync(backup,old,{flag:'wx'});
fs.writeFileSync(path.join(root,'revisions/zegagrande-expansion-decision-27.json'),JSON.stringify({sourceRevision:'51b0c55',beforeFile:path.relative(repo,backup).replaceAll('\\','/'),beforeSha256:crypto.createHash('sha256').update(old).digest('hex'),review,reviewDisposition:[],decision:'독립6사건·관련6카드 채택.',candidateCheck:check,limits:['공식 한국어 인물 소개와 세계관 본문을 읽었다. 공식 매뉴얼은 메뉴만 읽혀 게임의 기본·메인 메뉴 본문 검토로 보고하지 않는다. 전체 게임·페이트 에피소드·이미지 픽셀은 미검토.','Warcraft 런타임·화면·멀티플레이·재미·밸런스 미검증.']},null,2)+'\n',{flag:'wx'});
fs.writeFileSync(file,JSON.stringify(candidate,null,2)+'\n');console.log(JSON.stringify({cards:candidate.cards.length,events:candidate.events.length,roots:candidate.events.filter(e=>!e.previous).length,check}));
