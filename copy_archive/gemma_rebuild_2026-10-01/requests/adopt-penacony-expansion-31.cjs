// 페나코니 독립 사건의 고정 수치와 재검토 결과를 대조하고 원본 보존 후 반영한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const file=path.join(repo,'content/roguelite/11-penacony.json'),old=fs.readFileSync(file),before=JSON.parse(old);
const candidate=JSON.parse(fs.readFileSync(path.join(root,'revisions/penacony-expansion-curated-31.json'),'utf8'));
const fixed=JSON.parse(fs.readFileSync(path.join(root,'requests/penacony-expansion-fixed-30.json'),'utf8'));
assert.deepEqual(candidate.world,before.world);assert.deepEqual(candidate.cards.slice(0,before.cards.length),before.cards);assert.deepEqual(candidate.events.slice(0,before.events.length),before.events);
for(const c of fixed.cards){const x=candidate.cards.find(x=>x.key===c.key);assert.deepEqual(x,c);}
for(const e of fixed.events){const x=candidate.events.find(x=>x.key===e.key);assert.equal(x.previous,null);assert.equal(x.previousChoice,0);assert.equal(x.requiredCard,null);e.choices.forEach((b,i)=>{for(const k of ['card','card2','cost','gold','level','density','potions','chance'])assert.equal(x.choices[i][k],e.key==='hsr_jade_unwritten_price'&&i===1&&k==='card'?'hsr_jade_terms':b[k]);});}
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
const review=JSON.parse(fs.readFileSync(path.join(root,'reviews/penacony-expansion-review-31.json'),'utf8')).parsed;assert.equal(review.verdict.toUpperCase(),'PASS');assert.deepEqual(review.issues,[]);
const backup=path.join(root,'before-penacony-expansion-31.json');fs.writeFileSync(backup,old,{flag:'wx'});
fs.writeFileSync(path.join(root,'revisions/penacony-expansion-decision-31.json'),JSON.stringify({sourceRevision:'51b0c55',beforeFile:path.relative(repo,backup).replaceAll('\\','/'),beforeSha256:crypto.createHash('sha256').update(old).digest('hex'),review,reviewDisposition:[],numericExceptions:[{event:'hsr_jade_unwritten_price',choice:2,cardBefore:'hsr_misha_route',cardAfter:'hsr_jade_terms',reason:'등장 인물의 거래에 보상을 연결한다. 분기 숫자는 그대로.'}],decision:'독립6사건·관련6카드 채택.',candidateCheck:check,limits:['개발팀의 공식 PlayStation 2.0·2.1·2.3 본문에서 장소 장치와 인물 특징을 읽었다. 새로운 여섯 상황과 가격·확률은 별도 창작이다. 미샤 정체는 기존 경계와 같이 꿈속 일대일로 한정한다. 전체 게임·개별 퀘스트 전편·이미지 픽셀은 미검토.','Warcraft 런타임·화면·멀티플레이·재미·밸런스 미검증.']},null,2)+'\n',{flag:'wx'});
fs.writeFileSync(file,JSON.stringify(candidate,null,2)+'\n');console.log(JSON.stringify({cards:candidate.cards.length,events:candidate.events.length,roots:candidate.events.filter(e=>!e.previous).length,check}));
