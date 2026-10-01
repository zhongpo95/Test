// 나비저택 세 카드 선택의 역검토 오독과 표현 보완을 분리하고 원본 해시를 대조해 적용한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const fixed=read('requests/butterfly-card-choices-fixed-76.json'),before=read('before-butterfly-card-choices-76.json'),candidate=read('revisions/butterfly-card-choices-curated-77.json');
const file=path.join(repo,'content/roguelite/13-butterfly.json'),bytes=fs.readFileSync(file);
assert.equal(crypto.createHash('sha256').update(bytes).digest('hex'),fixed.beforeSha256);
assert.deepEqual(candidate.cards,before.cards);assert.deepEqual(candidate.world,before.world);
const hunt=fs.readFileSync(path.join(repo,'System/ExpeditionPrototype.j'),'utf8');
for(const source of ['set ProtoDensity[pid] = 4','IMaxBJ(1, ProtoDensity[pid] + ProtoBranchDensity[key])','call ProtoGrantEventCard(pid, ProtoBranchCard[key])','set value = value + "|n[사냥터] " + field'])assert(hunt.includes(source));
const reviews=[1,2,3].map(n=>read('reviews/butterfly-card-choices-review-77-'+n+'.json'));
assert.deepEqual(reviews.map(r=>r.parsed.verdict),['REVISE','REVISE','REVISE']);
const decisions=reviews.flatMap((r,i)=>r.parsed.issues.map(issue=>({batch:i+1,issue,decision:issue.key==='kny_morning_greeting'?'표현 보완, 수치와 참조 유지':'검토 의견 반려',evidence:issue.key==='kny_morning_greeting'?'신속과현재체력65%이상피해는이미별개효과였다. 두효과의띄어쓰기와접속을더분명하게보완한다.':/카드 1장|카드 획득/.test(issue.problem+issue.evidence)?'결과문장은행동과기억을쓰고ProtoResolve의ProtoGrantEventCard가실제지정카드이름/등급/효과를획득보상에덧붙인다. 카드가없다는의견은서술과UI책임을혼동했다.':issue.key==='kny_mixed_traces'||issue.key==='kny_before_departure'?'level은플레이어성장레벨이아니라사냥몬스터강함의지속변화량이다. 문장도강한적의부담으로썼고ProtoApplyField와결과의적체력/공격피해변화가별도로표시된다.':'density와level은최종값이아닌변화량이다. density초기4,하한1이고3→2등감소가가능하다. 하한에서유지됨은기존상세[사냥터]의최저1과실제전후표시로안내된다. 음수변화량을0으로바꾸거나임의의초기0을가정하지않는다.',validation:'validation/head-card-choices-probe-15.json에실제JASS변환의108분기·자기성공/실패후속·상한/하한·유효선택없음후보제외를검사한다.'})));
const c=candidate.events.find(e=>e.key==='kny_morning_greeting').choices[1],old=c.result;
c.result=c.result.replace('신속과현재체력65%이상에서 가하는 피해를 높였다.','신속이 늘었으며, 현재 체력65%이상에서 가하는 피해도 높아졌다.');assert.notEqual(c.result,old);
for(const [i,e]of candidate.events.entries()){
 const p=fixed.events[i];assert.equal(e.key,p.key);assert.equal(e.previous,p.previous);assert.equal(e.previousChoice,p.previousChoice);assert.equal(e.choices.length,3);assert.equal(new Set(e.choices.map(c=>c.card)).size,3);
 e.choices.forEach((c,j)=>{for(const k of ['card','card2','cost','gold','level','density','potions','chance'])assert.equal(c[k],p.choices[j][k]);assert.equal(c.gold,0);});
}
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
write('revisions/butterfly-card-choices-adopted-78.json',candidate);
write('revisions/butterfly-card-choices-decision-78.json',{beforeFile:fixed.beforeFile,beforeSha256:fixed.beforeSha256,rawReviews:reviews.map(r=>({monitorRecordId:r.monitorRecordId,parsed:r.parsed})),decisions,wordingCorrection:{key:'kny_morning_greeting#2',before:old,after:c.result},events:17,choices:51,distinctCardsPerEvent:3,directGoldChoices:0,unchanged:['카드21장의수치와참조','머리효과','사건후보2~4개','사냥기본10골드','리롤500+100','흡수/재생합산10%상한','중복카드100골드','개인성공/실패후속'],limits:['Gemma세REVISE는그대로보존하고오독반증과표현수정은분리한다.','이번세카드재구성은나비저택먼저이며다른머리는계속작업한다.','Warcraft·렌더링·실전멀티·재미·밸런스는미검증이며맵은만들지않는다.'],check});
fs.writeFileSync(file,JSON.stringify(candidate,null,2)+'\n');
console.log(JSON.stringify({events:17,choices:51,distinctCardsPerEvent:3,directGoldChoices:0,reviewIssues:decisions.length,check}));
