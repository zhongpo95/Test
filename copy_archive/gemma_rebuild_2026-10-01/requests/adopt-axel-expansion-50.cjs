// 액셀의 독립 사건·개인 줄 후속을 반영하고 체력 지급 설명의 잘못된 일반화를 바로잡는다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const file=path.join(repo,'content/roguelite/02-axel.json'),bytes=fs.readFileSync(file),before=JSON.parse(bytes),candidate=read('revisions/axel-expansion-curated-50.json'),fixed=read('requests/axel-expansion-fixed-49.json'),review=read('reviews/axel-expansion-review-50.json').parsed;
assert.equal(review.verdict,'PASS');assert.deepEqual(review.issues,[]);assert.deepEqual(candidate.world,before.world);assert.deepEqual(candidate.cards.slice(0,before.cards.length),before.cards);assert.deepEqual(candidate.events.slice(0,before.events.length),before.events);
for(const c of fixed.cards)assert.deepEqual(candidate.cards.find(x=>x.key===c.key),c);
for(const p of fixed.events){const e=candidate.events.find(x=>x.key===p.key);assert.equal(e.previous,p.previous||null);assert.equal(e.previousChoice,p.previousChoice||0);assert.equal(e.requiredCard,null);p.choices.forEach((b,i)=>{for(const k of ['card','card2','cost','gold','level','density','potions','chance'])assert.equal(e.choices[i][k],b[k]);});}
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
fs.writeFileSync(path.join(root,'before-axel-expansion-50.json'),bytes,{flag:'wx'});
write('revisions/axel-expansion-decision-50.json',{sourceRevision:'f09853c',beforeFile:'before-axel-expansion-50.json',beforeSha256:crypto.createHash('sha256').update(bytes).digest('hex'),review,decision:'독립4사건·자신의 줄 고정 성공을 요구하는 후속1사건·카드5장 채택.',numericExceptions:[],candidateCheck:check,limits:['공식 1기 5·7·8화 소개 본문을 확인했다. 구경꾼·발자국 표시·별도 질문·문턱·줄 받침과 수치·확률은 창작이다. 개별 에피소드 영상 전체·원작 소설 전편은 미검토.','드레인 터치의 세부 작동을 공식 소개 본문으로 확인하지 못해 새 위즈 카드의 근거로 삼지 않았다. 제령 유령의 신원과 성불 규칙도 추가하지 않는다.','검토49는 사건 중 실제 처치가 일어난 것처럼 썼다. 실제 데이터는 개인 사냥의 지속 조건 변경이므로 결과를 다시 썼다.','기존 검토47의 체력 불변 예시는 PlayerStatsSet 단독 검사에 한정한다. 실제 카드 지급은 현재 체력 비율을 보존하며 검증50으로 별도 정정한다.','Warcraft·화면·멀티플레이·재미·밸런스 미검증.']});
fs.writeFileSync(file,JSON.stringify(candidate,null,2)+'\n');
function replace(file,a,b){const p=path.join(repo,file),s=fs.readFileSync(p,'utf8');assert(s.includes(a),file+' 기준 문장 없음');fs.writeFileSync(p,s.replace(a,b));}
replace('md/roguelite/사건 카드 재제작 검토 기록.md','최대 체력 10800과 현재 체력 7000 유지, 차지 준비 배율 1.12와 일반 행동 1.00','최대 체력의 스탯 재계산과 차지 준비 배율 1.12·일반 행동 1.00');
replace('md/roguelite/카드 능력치 단위와 검토 기준.md','추가 최대 체력은 즉시 치유가 아니다. 현재 체력 7000은 기본 최대 체력 10000에서는 65% 이상이지만, 최대 체력 10800에서는 약 64.8%라서 고체력 피해 조건에 미달한다. 물약과 체력 관리를 함께 고려해야 한다.','추가 최대 체력 카드를 실제 사건에서 받으면 기존 현재 체력 비율을 보존한다. 현재 체력 7000/최대 10000이었다면 새 최대 10800에 현재 약 7560으로 70%를 유지한다. 물약처럼 체력 비율 자체를 회복하는 효과는 아니다. 앞선 스탯 함수 단독 검사에서 현재 7000이 유지된 사례를 실제 지급까지 일반화한 설명은 정정한다.');
const ioFile=path.join(repo,'content/roguelite/07-zegagrande.json'),ioBytes=fs.readFileSync(ioFile),io=JSON.parse(ioBytes),card=io.cards.find(c=>c.key==='gbf_io_smile'),old=card.canonFact;
assert(old.includes('즉시 치유'));card.canonFact=old.replace('즉시 치유','체력 비율 자체의 회복');fs.writeFileSync(path.join(root,'before-zegagrande-health-explanation-50.json'),ioBytes,{flag:'wx'});
write('revisions/health-explanation-correction-50.json',{sourceRevision:'f09853c',card:card.key,field:'canonFact',before:old,after:card.canonFact,beforeFile:'before-zegagrande-health-explanation-50.json',beforeSha256:crypto.createHash('sha256').update(ioBytes).digest('hex'),evidence:read('validation/card-health-grant-probe-50.json'),reason:'최대 체력 성장의 절대 현재 체력 증가와 물약의 비율 회복을 구분한다. 검토47 요청·원문·단독 검사 파일은 역사적 원본으로 보존한다. 코드와 수치는 바꾸지 않는다.'});
fs.writeFileSync(ioFile,JSON.stringify(io,null,2)+'\n');
console.log(JSON.stringify({newRoots:4,newFollowups:1,newCards:5,totalCards:candidate.cards.length,totalEvents:candidate.events.length,check}));
