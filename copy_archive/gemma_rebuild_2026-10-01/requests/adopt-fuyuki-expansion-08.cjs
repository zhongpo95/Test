// 후유키 독립 사건의 고정 분기와 제외 목록을 대조하고 원본을 보존하여 반영한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const file=path.join(repo,'content/roguelite/01-fuyuki.json'),candidate=JSON.parse(fs.readFileSync(path.join(root,'revisions/fuyuki-expansion-curated-08.json'),'utf8'));
const old=fs.readFileSync(file),before=JSON.parse(old),fixed=JSON.parse(fs.readFileSync(path.join(root,'requests/fuyuki-expansion-fixed-07.json'),'utf8'));
assert.deepEqual(candidate.world,before.world);assert.deepEqual(candidate.cards.slice(0,before.cards.length),before.cards);assert.deepEqual(candidate.events.slice(0,before.events.length),before.events);assert(!candidate.events.some(e=>e.key==='fy_vantage_map'));
for(const c of fixed.cards){const x=candidate.cards.find(x=>x.key===c.key);assert.deepEqual(x.effects,c.effects);assert.deepEqual(x.evolution,c.evolution);}
for(const e of fixed.events.filter(e=>e.key!=='fy_vantage_map')){const x=candidate.events.find(x=>x.key===e.key);assert.equal(x.previous,null);assert.equal(x.previousChoice,0);assert.equal(x.requiredCard,null);e.choices.forEach((b,i)=>{for(const k of ['card','card2','cost','gold','level','density','potions','chance'])assert.equal(x.choices[i][k],b[k]);});}
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);if(check.errors.length)throw Error(JSON.stringify(check));
const review=JSON.parse(fs.readFileSync(path.join(root,'reviews/fuyuki-expansion-review-08.json'),'utf8')).parsed;
const backup=path.join(root,'before-fuyuki-expansion-08.json');fs.writeFileSync(backup,old,{flag:'wx'});
fs.writeFileSync(path.join(root,'revisions/fuyuki-expansion-decision-08.json'),JSON.stringify({sourceRevision:'4a86910',beforeFile:path.relative(repo,backup).replaceAll('\\','/'),beforeSha256:crypto.createHash('sha256').update(old).digest('hex'),review,reviewDisposition:[{key:'fy_shinji_offer',decision:'성공 보수와 실패 비용 문구 유지.',reason:'성공 결과에 자료 보수를 받았다고 명시했고 실패 결과에 연락 비용·적 수 부담만 남으며 카드와 자료 보수는 없다고 구분했다. 실제 적용은180비용 후 성공280보수, 실패0보수다. 제안을 수락하거나 원작 진상을 확정하지 않는다.'}],decision:'독립6사건·관련5카드 채택. 지도 원안1개는 이상의 차이 사건과 선택이 겹쳐 제외.',candidateCheck:check,limits:['Gemma PASS에 보수 표현 제안1개가 있으며 지적 없음이라고 보고하지 않는다.','Warcraft·화면·멀티플레이·실제 성능·플레이 재미와 밸런스 검증은 아니다.']},null,2)+'\n',{flag:'wx'});
fs.writeFileSync(file,JSON.stringify(candidate,null,2)+'\n');console.log(JSON.stringify({cards:candidate.cards.length,events:candidate.events.length,roots:candidate.events.filter(e=>!e.previous).length,check}));
