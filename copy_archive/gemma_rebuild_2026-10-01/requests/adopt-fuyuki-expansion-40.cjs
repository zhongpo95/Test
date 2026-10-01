// 후유키 고정 분기와 재검토를 대조하고 기존 파일의 바이트와 해시를 보존한 뒤 반영한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const file=path.join(repo,'content/roguelite/01-fuyuki.json'),old=fs.readFileSync(file),before=JSON.parse(old);
const candidate=read('revisions/fuyuki-expansion-curated-40.json'),fixed=read('requests/fuyuki-expansion-fixed-38.json'),review=read('reviews/fuyuki-expansion-review-40.json').parsed;
assert.deepEqual(candidate.world,before.world);assert.deepEqual(candidate.cards.slice(0,before.cards.length),before.cards);assert.deepEqual(candidate.events.slice(0,before.events.length),before.events);
for(const c of fixed.cards)assert.deepEqual(candidate.cards.find(x=>x.key===c.key),c);
for(const e of fixed.events){const x=candidate.events.find(x=>x.key===e.key);assert.equal(x.previous,null);assert.equal(x.previousChoice,0);assert.equal(x.requiredCard,null);assert.equal(x.choices.length,e.choices.length);e.choices.forEach((b,i)=>{for(const k of ['card','card2','cost','gold','level','density','potions','chance'])assert.equal(x.choices[i][k],b[k]);});}
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);assert.equal(review.verdict,'PASS');assert.deepEqual(review.issues,[]);
const backup=path.join(root,'before-fuyuki-expansion-40.json');fs.writeFileSync(backup,old,{flag:'wx'});
fs.writeFileSync(path.join(root,'revisions/fuyuki-expansion-decision-40.json'),JSON.stringify({sourceRevision:'95b850d',beforeFile:path.relative(repo,backup).replaceAll('\\','/'),beforeSha256:crypto.createHash('sha256').update(old).digest('hex'),review,reviewDisposition:[],decision:'독립1사건·관련1카드 채택. 피칭34의 나머지7개는 중복과 잘못된 인물 역할로 폐기하고 원문·이유·재검토 조건을 보존한다.',candidateCheck:check,limits:['공식 UBW 인물 본문을 읽었다. 전체 애니메이션·게임·이미지 픽셀과 한국어 공식 현지화 이름 전체 미검토. 새로운 길목 만남과 대사는 창작이다.','Warcraft 런타임·화면·멀티·재미·밸런스 미검증. 맵 생성 없음.']},null,2)+'\n',{flag:'wx'});
fs.writeFileSync(file,JSON.stringify(candidate,null,2)+'\n');console.log(JSON.stringify({cards:candidate.cards.length,events:candidate.events.length,roots:candidate.events.filter(e=>!e.previous).length,check}));
