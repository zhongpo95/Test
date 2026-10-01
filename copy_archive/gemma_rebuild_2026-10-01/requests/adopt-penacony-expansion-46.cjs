// 재검토한 페나코니 공연·관광 사건의 기존 바이트와 수치를 대조하고 반영한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const file=path.join(repo,'content/roguelite/11-penacony.json'),bytes=fs.readFileSync(file),before=JSON.parse(bytes);
const candidate=read('revisions/penacony-expansion-curated-46.json'),fixed=read('requests/penacony-expansion-fixed-45.json'),review=read('reviews/penacony-expansion-review-46.json').parsed;
assert.equal(review.verdict,'PASS');assert.deepEqual(review.issues,[]);
assert.deepEqual(candidate.world,before.world);assert.deepEqual(candidate.cards.slice(0,before.cards.length),before.cards);assert.deepEqual(candidate.events.slice(0,before.events.length),before.events);
for(const c of fixed.cards)assert.deepEqual(candidate.cards.find(x=>x.key===c.key),c);
for(const p of fixed.events){const e=candidate.events.find(x=>x.key===p.key);assert.equal(e.previous,p.previous||null);assert.equal(e.previousChoice,p.previousChoice||0);assert.equal(e.requiredCard,null);p.choices.forEach((b,i)=>{for(const k of ['card','card2','cost','gold','level','density','potions','chance'])assert.equal(e.choices[i][k],b[k]);});}
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
const backup=path.join(root,'before-penacony-expansion-46.json');fs.writeFileSync(backup,bytes,{flag:'wx'});
write('revisions/penacony-expansion-decision-46.json',{sourceRevision:'d94e43d',beforeFile:path.relative(repo,backup).replaceAll('\\','/'),beforeSha256:crypto.createHash('sha256').update(bytes).digest('hex'),review,reviewDisposition:[{item:'카드 메커니즘이 공식 데이터와 모순되지 않는다는 strengths 문장',decision:'제공한 맵 메커니즘과 일치한다는 뜻으로만 취급한다. 공식 스타레일이 moving_damage나 regeneration 필드를 사용한다는 근거는 아니다.'}],numericExceptions:[],decision:'독립4사건·개인후속2사건·관련6카드 채택.',candidateCheck:check,limits:['개발팀의 PlayStation 2.2 독일어·2.3 영어 본문에서 시설과 인물의 역할·목적을 확인했다. 관광·관객·참가자·잘못된 안내지·사진 설명과 모든 수치·확률은 맵 창작이다. 전체 게임·개별 퀘스트 전편·한국어 공식 대사·이미지 픽셀은 미검토.','종이새 피칭의 가까운 새/먼 새 규칙은 이 공식 소개로 확인되지 않아 폐기했다. 이 묶음에는 종이새 카드나 게임을 추가하지 않는다.','Warcraft 런타임·화면·멀티플레이·재미·밸런스 미검증.']});
fs.writeFileSync(file,JSON.stringify(candidate,null,2)+'\n');console.log(JSON.stringify({cards:candidate.cards.length,events:candidate.events.length,roots:candidate.events.filter(e=>!e.previous).length,check}));
