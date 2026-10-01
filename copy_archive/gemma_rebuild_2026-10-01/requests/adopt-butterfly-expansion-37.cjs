// 호접저 고정 분기와 재검토를 대조하고 기존 파일의 바이트와 해시를 보존한 뒤 반영한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const file=path.join(repo,'content/roguelite/13-butterfly.json'),old=fs.readFileSync(file),before=JSON.parse(old);
const candidate=read('revisions/butterfly-expansion-curated-37.json'),fixed=read('requests/butterfly-expansion-fixed-36.json'),review=read('reviews/butterfly-expansion-review-37.json').parsed;
assert.deepEqual(candidate.world,before.world);assert.deepEqual(candidate.cards.slice(0,before.cards.length),before.cards);assert.deepEqual(candidate.events.slice(0,before.events.length),before.events);
for(const c of fixed.cards)assert.deepEqual(candidate.cards.find(x=>x.key===c.key),c);
for(const e of fixed.events){const x=candidate.events.find(x=>x.key===e.key);assert.equal(x.previous,null);assert.equal(x.previousChoice,0);assert.equal(x.requiredCard,null);assert.equal(x.choices.length,e.choices.length);e.choices.forEach((b,i)=>{for(const k of ['card','card2','cost','gold','level','density','potions','chance'])assert.equal(x.choices[i][k],b[k]);});}
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);assert.equal(review.verdict,'PASS');assert.deepEqual(review.issues,[]);
const backup=path.join(root,'before-butterfly-expansion-37.json');fs.writeFileSync(backup,old,{flag:'wx'});
fs.writeFileSync(path.join(root,'revisions/butterfly-expansion-decision-37.json'),JSON.stringify({sourceRevision:'95b850d',beforeFile:path.relative(repo,backup).replaceAll('\\','/'),beforeSha256:crypto.createHash('sha256').update(old).digest('hex'),review,reviewDisposition:['역검토의 장점 중 카드 지급이 아니라 능력치 변화라는 표현은 부정확하다. 실제 고정 분기는 지정 카드를 지급하고 카드가 스탯을 적용한다. PASS를 실제 게임 재미나 원작 재현의 증명으로 해석하지 않는다.'],decision:'독립3사건·관련3카드 채택. 피칭32의8개와 피칭33의5개는 이유·재검토 조건과 원문을 보존하고 폐기한다.',candidateCheck:check,limits:['24·25화 줄거리와 히노카미 혈풍담 본편 인물 소개를 읽었다. 전체 애니메이션·만화·이미지 픽셀·한국어 공식 현지화 이름 전체는 미검토. 이전 캐릭터 주소의 동전 결정·세부 역할은 이번 집필 근거로 쓰지 않았다.','Warcraft 런타임·화면·멀티·재미·밸런스 미검증. 맵 생성 없음.']},null,2)+'\n',{flag:'wx'});
fs.writeFileSync(file,JSON.stringify(candidate,null,2)+'\n');console.log(JSON.stringify({cards:candidate.cards.length,events:candidate.events.length,roots:candidate.events.filter(e=>!e.previous).length,check}));
