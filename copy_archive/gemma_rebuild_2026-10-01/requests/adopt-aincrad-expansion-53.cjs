// 검토한 아인크라드 콘텐츠만 채택하고 기존 카드 수치와 다섯 사건의 모든 판정을 보존한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const file=path.join(repo,'content/roguelite/06-aincrad.json'),bytes=fs.readFileSync(file),before=JSON.parse(bytes),candidate=read('revisions/aincrad-expansion-curated-53.json'),fixed=read('requests/aincrad-expansion-fixed-52.json'),review=read('reviews/aincrad-expansion-review-53.json').parsed;
assert.equal(review.verdict,'PASS');assert.deepEqual(review.issues,[]);assert.deepEqual(candidate.world,before.world);
for(const c of before.cards){const after=candidate.cards.find(x=>x.key===c.key);if(c.key==='sao_silica')assert.deepEqual({...after,canonFact:c.canonFact},c);else assert.deepEqual(after,c);}
for(const c of fixed.cards)assert.deepEqual(candidate.cards.find(x=>x.key===c.key),c);
const preserved=before.events.filter(e=>!fixed.rewrites.some(p=>p.key===e.key));for(const e of preserved)assert.deepEqual(candidate.events.find(x=>x.key===e.key),e);
for(const p of [...fixed.events,...fixed.rewrites]){const e=candidate.events.find(x=>x.key===p.key);assert.equal(e.previous,p.previous||null);assert.equal(e.previousChoice,p.previousChoice||0);assert.equal(e.requiredCard,null);assert.equal(e.choices.length,p.choices.length);p.choices.forEach((b,i)=>{for(const k of ['card','card2','cost','gold','level','density','potions','chance'])assert.equal(e.choices[i][k],b[k]);});}
const oldBoundary=candidate.canonBoundary;assert(oldBoundary.includes('낚시 기록'));candidate.canonBoundary=oldBoundary.replace('낚시 기록','작은 낚시');
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
fs.writeFileSync(path.join(root,'before-aincrad-expansion-53.json'),bytes,{flag:'wx'});
write('revisions/aincrad-expansion-decision-53.json',{sourceRevision:'115324d',beforeFile:'before-aincrad-expansion-53.json',beforeSha256:crypto.createHash('sha256').update(bytes).digest('hex'),review,decision:'독립4사건·자신의 귀환 질문 성공1번 후속1사건·카드5장 채택. 기존5사건은 모든 수치·판정·지급 참조를 유지하고 문장만 정정한다.',boundaryCorrection:{before:oldBoundary,after:candidate.canonBoundary,reason:'활성 낚시가 기록 분류에서 작은 입질로 바뀌어 총괄 설명의 과거 소재도 맞춘다. 수치와 리뷰 대상 문장은 바꾸지 않는다.'},candidateCheck:check,numericExceptions:[],limits:['공식 소개 본문을 읽었으며 애니메이션 전체 영상·원작 전편·관련 게임 전체를 검토한 것은 아니다.','아르고는 공식 게임의 정보상 역할만 가져오고 베타에서 만난 게임 주인공이나 고유 전개를 애니메이션에 옮기지 않는다.','꽃의 명칭·층·소생 시간 제한은 확인한 공식 소개에서 확인하지 않아 새 문장에 쓰지 않았다. 비공식 요약은 공식 출처로 바꾸지 않는다.','작은 입질·미끼·낚시 보수·정보 독점 오해·외투·준비물·수치·확률·방문은 창작이다. 실제 낚시·정보시장·NPC동행·원작장비·관리자기능·소생을 구현하지 않는다.','Warcraft·실제 화면·멀티플레이·재미·밸런스 미검증.']});
fs.writeFileSync(file,JSON.stringify(candidate,null,2)+'\n');console.log(JSON.stringify({newCards:5,newRoots:4,newFollowups:1,rewrites:5,totalCards:candidate.cards.length,totalEvents:candidate.events.length,check}));
