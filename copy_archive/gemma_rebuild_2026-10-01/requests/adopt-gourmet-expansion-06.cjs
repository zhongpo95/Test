// 미식전 추가 독립 사건의 원본과 검토 의견을 보존한 뒤 활성 후보에 반영한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const file=path.join(repo,'content/roguelite/14-gourmet.json'),candidate=JSON.parse(fs.readFileSync(path.join(root,'revisions/gourmet-expansion-curated-06.json'),'utf8'));
const old=fs.readFileSync(file),before=JSON.parse(old),fixed=JSON.parse(fs.readFileSync(path.join(root,'requests/gourmet-expansion-fixed-06.json'),'utf8'));
assert.deepEqual(candidate.world,before.world);assert.deepEqual(candidate.cards.slice(0,before.cards.length),before.cards);assert.deepEqual(candidate.events.slice(0,before.events.length),before.events);
for(const c of fixed.cards){const x=candidate.cards.find(x=>x.key===c.key);assert.deepEqual(x.effects,c.effects);assert.deepEqual(x.evolution,c.evolution);}
for(const e of fixed.events){const x=candidate.events.find(x=>x.key===e.key);assert.equal(x.previous,null);assert.equal(x.previousChoice,0);assert.equal(x.requiredCard,null);e.choices.forEach((b,i)=>{for(const k of ['card','card2','cost','gold','level','density','potions','chance'])assert.equal(x.choices[i][k],b[k]);});}
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);if(check.errors.length)throw Error(JSON.stringify(check));
const review=JSON.parse(fs.readFileSync(path.join(root,'reviews/gourmet-expansion-review-06.json'),'utf8')).parsed;
const backup=path.join(root,'before-gourmet-expansion-06.json');fs.writeFileSync(backup,old,{flag:'wx'});
fs.writeFileSync(path.join(root,'revisions/gourmet-expansion-decision-06.json'),JSON.stringify({sourceRevision:'4a86910',beforeFile:path.relative(repo,backup).replaceAll('\\','/'),beforeSha256:crypto.createHash('sha256').update(old).digest('hex'),review,reviewDisposition:[{key:'pc_monica_order',decision:'제작 메타데이터에 이미 부대 NPC·동료 버프가 없다고 명시되어 있어 유지. 플레이어 문장에 개발 제한 경고를 더하지 않는다.',reason:'신속 고정180과 피해감소2는 기존 개인 능력치뿐이다. 이야기와 효과 이름은 준비의 행동이며 군사 NPC 기능을 약속하지 않는다.'}],decision:'독립6사건·관련5카드 채택. 원안8개 효과는 직접 채택하지 않고6상황 재작성·2상황 제외.',candidateCheck:check,limits:['Gemma PASS에는 해석상 제안1개가 있다. 원문을 그대로 보존하며 지적 없음이라고 보고하지 않는다.','Warcraft·화면·멀티플레이·플레이 재미와 밸런스 검증은 아니다.']},null,2)+'\n',{flag:'wx'});
fs.writeFileSync(file,JSON.stringify(candidate,null,2)+'\n');console.log(JSON.stringify({cards:candidate.cards.length,events:candidate.events.length,roots:candidate.events.filter(e=>!e.previous).length,check}));
