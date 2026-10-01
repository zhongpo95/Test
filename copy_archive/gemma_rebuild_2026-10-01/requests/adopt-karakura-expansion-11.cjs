// 카라쿠라의 무료 작업 문구를 명확히 하고 검토된 독립 사건을 원본 보존 후 반영한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const file=path.join(repo,'content/roguelite/10-karakura.json'),old=fs.readFileSync(file),before=JSON.parse(old);
const candidate=JSON.parse(fs.readFileSync(path.join(root,'revisions/karakura-expansion-curated-10.json'),'utf8'));
const fixed=JSON.parse(fs.readFileSync(path.join(root,'requests/karakura-expansion-fixed-09.json'),'utf8'));
const choice=candidate.events.find(e=>e.key==='bl_uncertain_kit').choices[2],label=choice.label;
assert.equal(label,'구매 대신 창고의 빈 상자를 정리해 보수를 받는다');
choice.label='묶음은 남기고 창고의 빈 상자를 정리해 보수를 받는다';
assert.deepEqual(candidate.world,before.world);assert.deepEqual(candidate.cards.slice(0,before.cards.length),before.cards);assert.deepEqual(candidate.events.slice(0,before.events.length),before.events);
for(const c of fixed.cards){const x=candidate.cards.find(x=>x.key===c.key);assert.deepEqual(x.evolution,c.evolution);assert.deepEqual(x.effects,c.key==='bl_uryu_stitch'?[{stat:'charge_speed',value:6},{stat:'crit_damage',value:15}]:c.effects);}
for(const e of fixed.events){const x=candidate.events.find(x=>x.key===e.key);assert.equal(x.previous,null);assert.equal(x.previousChoice,0);assert.equal(x.requiredCard,null);e.choices.forEach((b,i)=>{for(const k of ['card','card2','cost','gold','level','density','potions','chance'])assert.equal(x.choices[i][k],b[k]);});}
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
const review=JSON.parse(fs.readFileSync(path.join(root,'reviews/karakura-expansion-review-10.json'),'utf8')).parsed;assert.equal(review.verdict,'PASS');assert(review.issues.every(i=>i.problem==='none'));
fs.writeFileSync(path.join(root,'revisions/karakura-expansion-curated-11.json'),JSON.stringify(candidate,null,2)+'\n',{flag:'wx'});
const backup=path.join(root,'before-karakura-expansion-11.json');fs.writeFileSync(backup,old,{flag:'wx'});
fs.writeFileSync(path.join(root,'revisions/karakura-expansion-decision-11.json'),JSON.stringify({sourceRevision:'6d4b0d8',beforeFile:path.relative(repo,backup).replaceAll('\\','/'),beforeSha256:crypto.createHash('sha256').update(old).digest('hex'),review,reviewDisposition:review.issues.map(i=>({key:i.key,decision:'기존 설명 유지.',reason:'problem none은 수정 요청이 아니라 유지 권고다. 원문 issues 배열의 세 항목을 그대로 보존한다.'})),changes:[{key:'bl_uncertain_kit#3',field:'label',before:label,after:choice.label,reason:'구매 대신이라는 부정 표현을 비용 검사기가 구매로 인식했다. 무료 창고 작업임을 직접 표현하고 수치와 실제 동작은 유지한다.'}],decision:'독립6사건·관련4카드 채택. 우류 신규 카드의 차지 속도 변경은 curation-10 원안 비교 기록을 따른다.',candidateCheck:check,limits:['원작 생활 소재의 별도 창작이다. 한국어 공식 전체 대사·후반부 결말을 대조한 것은 아니다.','Gemma PASS의 issues에는 유지 권고 세 개가 있다.','Warcraft 런타임·화면·멀티플레이·재미·밸런스 미검증.']},null,2)+'\n',{flag:'wx'});
fs.writeFileSync(file,JSON.stringify(candidate,null,2)+'\n');console.log(JSON.stringify({cards:candidate.cards.length,events:candidate.events.length,roots:candidate.events.filter(e=>!e.previous).length,check}));
