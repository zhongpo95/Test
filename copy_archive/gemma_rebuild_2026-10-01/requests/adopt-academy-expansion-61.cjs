// 학원도시 두 검토의 반영·기각 근거와 원본을 보존하고 수치 대조를 거친 사건을 채택한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const file=path.join(repo,'content/roguelite/04-academy.json'),bytes=fs.readFileSync(file),before=JSON.parse(bytes),candidate=read('revisions/academy-expansion-curated-60.json'),fixed=read('requests/academy-expansion-fixed-58.json'),review=read('reviews/academy-expansion-review-60.json').parsed;
assert.equal(review.verdict,'REVISE');
const stats=fs.readFileSync(path.join(repo,'Data/Data_PrototypeStats.j'),'utf8'),effects=fs.readFileSync(path.join(repo,'System/ExpeditionEffects.j'),'utf8');
assert(stats.includes('차지 공격 대미지 증가'));assert(stats.includes('체력 65% 이상에서 대미지 증가'));assert(effects.includes('UNIT_STATE_MAX_LIFE) * 0.65'));
write('revisions/academy-review-decision-60.json',{review,decision:'세 지적 모두 실제 스탯 불일치로 확인되지 않아 기각한다. charge_damage는 프로젝트 표시에 차지 공격 대미지 증가이며 healthy_damage는 체력65%이상일 때 가하는 피해다. 차지 준비 속도는 차지 속도의 적용 대상을 설명한다. 영어 내부키나 키워드의 짧은 표현을 이야기 결과에 강요하지 않는다.',evidence:['Data/Data_PrototypeStats.j의 PROTO_STAT_CHARGE_DAMAGE 표시가 차지 공격 대미지 증가다.','Data/Data_PrototypeStats.j의 PROTO_STAT_HEALTHY 표시가 체력65%이상에서 대미지 증가다.','System/ExpeditionEffects.j는 source현재체력>=source최대체력*0.65일 때 고체력 효과를 적용한다.','charge_speed의 준비 속도 의미는 기존 카드 능력치 문서·스탯·차지 스킬 적용에서 별도로 검증했다.'],numericExceptions:[],revisit:'실제 카드 함수가 다른 스탯을 지급하거나 조건이 다른 실행 증거가 나오면 재검토한다.',limits:'Gemma의 REVISE 원문을 PASS로 바꾸지 않았다. Codex의 스탯 표시·조건·고정안 대조와 별도 분기 모의를 근거로 채택한다.'});
assert.deepEqual(candidate.world,before.world);
for(const c of before.cards)assert.deepEqual(candidate.cards.find(x=>x.key===c.key),c);
for(const e of before.events)assert.deepEqual(candidate.events.find(x=>x.key===e.key),e);
for(const c of fixed.cards)assert.deepEqual(candidate.cards.find(x=>x.key===c.key),c);
for(const p of fixed.events){const e=candidate.events.find(x=>x.key===p.key);assert.equal(e.previous,p.previous||null);assert.equal(e.previousChoice,p.previousChoice||0);assert.equal(e.requiredCard,null);assert.equal(e.choices.length,p.choices.length);p.choices.forEach((b,i)=>{for(const k of ['card','card2','cost','gold','level','density','potions','chance'])assert.equal(e.choices[i][k],b[k]);});}
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
fs.writeFileSync(path.join(root,'before-academy-expansion-61.json'),bytes,{flag:'wx'});
write('revisions/academy-expansion-decision-61.json',{sourceRevision:'8c8ff709',beforeFile:'before-academy-expansion-61.json',beforeSha256:crypto.createHash('sha256').update(bytes).digest('hex'),reviews:[read('reviews/academy-expansion-review-59.json').parsed,review],reviewDecisions:[read('revisions/academy-review-decision-59.json'),read('revisions/academy-review-decision-60.json')],serverFailure:read('revisions/academy-server-error-60.json'),decision:'별도 방문의 독립5사건·자신의 자판기 성공1번 음료후속1사건·카드6장 채택. 기존 카드15장·사건12개는 모든 필드를 그대로 보존한다.',candidateCheck:check,numericExceptions:[],limits:['두 Gemma 검토는 REVISE다. 밀도와 선지불의 표현은 명확히 하고 실제 지원되는 감소와 프로젝트 스탯 설명을 불일치로 분류한 판단은 기각했다.','공식 줄거리 본문을 읽었으며 원작 전편·영상 전체·게임 전체를 확인한 것은 아니다.','음료·찻잔·여행자의 답·버튼 앞 기다림·무대 준비·성장 기억·맵 방문·골드·확률은 창작이다. 원작 실험·피습·화해·학생 사정·공연의 종류와 결말을 여행자가 바꾸지 않는다.','게임기 조작·전원 차단·미니게임·원작 초능력·NPC동행·음료 아이템·현재체력 회복·사냥 중 추가 처치 기능은 없다.','실제 Warcraft·렌더링·멀티플레이·재미·밸런스는 미검증이다.']});
fs.writeFileSync(file,JSON.stringify(candidate,null,2)+'\n');console.log(JSON.stringify({newCards:6,newRoots:5,newFollowups:1,totalCards:candidate.cards.length,totalEvents:candidate.events.length,check}));
