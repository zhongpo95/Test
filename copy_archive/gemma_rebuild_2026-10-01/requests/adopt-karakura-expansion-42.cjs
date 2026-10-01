// 카라쿠라 고정 분기와 재검토를 대조하고 기존 파일의 바이트와 해시를 보존한 뒤 반영한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const file=path.join(repo,'content/roguelite/10-karakura.json'),old=fs.readFileSync(file),before=JSON.parse(old);
const candidate=read('revisions/karakura-expansion-curated-42.json'),fixed=read('requests/karakura-expansion-fixed-39.json'),review=read('reviews/karakura-expansion-review-42.json').parsed;
assert.deepEqual(candidate.world,before.world);assert.deepEqual(candidate.cards.slice(0,before.cards.length),before.cards);assert.deepEqual(candidate.events.slice(0,before.events.length),before.events);
for(const c of fixed.cards)assert.deepEqual(candidate.cards.find(x=>x.key===c.key),c);
for(const e of fixed.events){const x=candidate.events.find(x=>x.key===e.key);assert.equal(x.previous,null);assert.equal(x.previousChoice,0);assert.equal(x.requiredCard,null);assert.equal(x.choices.length,e.choices.length);e.choices.forEach((b,i)=>{for(const k of ['card','card2','cost','gold','level','density','potions','chance'])assert.equal(x.choices[i][k],b[k]);});}
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);assert.equal(review.verdict,'PASS');assert.deepEqual(review.issues,[]);
const backup=path.join(root,'before-karakura-expansion-42.json');fs.writeFileSync(backup,old,{flag:'wx'});
fs.writeFileSync(path.join(root,'revisions/karakura-expansion-decision-42.json'),JSON.stringify({sourceRevision:'95b850d',beforeFile:path.relative(repo,backup).replaceAll('\\','/'),beforeSha256:crypto.createHash('sha256').update(old).digest('hex'),review,reviewDisposition:[],decision:'독립4사건·관련4카드 채택. 피칭35의4개와 집필39는 미채택하고 재집필41의중복키·잘못된발단·단계표현을수정했다. 원문·이유·재검토조건을보존한다.',candidateCheck:check,limits:['제작사 블리치 인물 본문을 읽었다. 카린의 냉정함·영감, 잇신의 가족 사랑과 의원, 점원 진타·우루루, 활발한 케이고를 참고했다. 전체 애니메이션·만화·게임·이미지 픽셀과 한국어 공식 현지화 이름 전체 미검토.','Warcraft 런타임·화면·멀티·재미·밸런스 미검증. 맵 생성 없음.']},null,2)+'\n',{flag:'wx'});
fs.writeFileSync(file,JSON.stringify(candidate,null,2)+'\n');console.log(JSON.stringify({cards:candidate.cards.length,events:candidate.events.length,roots:candidate.events.filter(e=>!e.previous).length,check}));
