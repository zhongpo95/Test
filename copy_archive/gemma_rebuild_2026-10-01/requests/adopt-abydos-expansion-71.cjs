// 아비도스 확장의 고정 수치와 역검토를 확인하고 기존 바이트 보존 뒤 콘텐츠를 채택한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..'),read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const file=path.join(repo,'content/roguelite/03-abydos.json'),bytes=fs.readFileSync(file),before=JSON.parse(bytes),candidate=read('revisions/abydos-expansion-curated-70.json'),fixed=read('requests/abydos-expansion-fixed-69.json'),review=read('reviews/abydos-expansion-review-70.json').parsed;
assert.equal(review.verdict,'PASS');assert.deepEqual(review.issues,[]);assert.deepEqual(candidate.world,before.world);
for(const c of before.cards)assert.deepEqual(candidate.cards.find(x=>x.key===c.key),c);for(const e of before.events)assert.deepEqual(candidate.events.find(x=>x.key===e.key),e);
for(const c of fixed.cards)assert.deepEqual(candidate.cards.find(x=>x.key===c.key),c);
for(const p of fixed.events){const e=candidate.events.find(x=>x.key===p.key);assert.equal(e.previous,p.previous||null);assert.equal(e.previousChoice,p.previousChoice||0);assert.equal(e.requiredCard,null);assert.equal(e.choices.length,p.choices.length);p.choices.forEach((b,i)=>{for(const k of ['card','card2','cost','gold','level','density','potions','chance'])assert.equal(e.choices[i][k],b[k]);});}
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
fs.writeFileSync(path.join(root,'before-abydos-expansion-71.json'),bytes,{flag:'wx'});
fs.writeFileSync(path.join(root,'revisions/abydos-expansion-decision-71.json'),JSON.stringify({sourceRevision:'8fe7f7197a776b69c4158907e14f66dbab0fe25d',beforeFile:'before-abydos-expansion-71.json',beforeSha256:crypto.createHash('sha256').update(bytes).digest('hex'),review,decision:'네 독립 사건·자기 계산 도움 성공1번/한 곡 듣기 성공2번의 두 후속·카드6장 채택. 기존14카드·12사건의 모든 필드를 유지한다.',numericExceptions:[],rewardReferenceCorrections:[],check,limits:['공식 줄거리와 인물 소개의 관계·취미·역할을 읽었으며 원작 전편/전체 영상을 확인한 것은 아니다.','계산서·CD주문·잡초 화분·봉투 내기와 작은 대사는 별도 창작이다. 원작 큰 결말·가게폭파·학교빚·원작범죄·구출을 해결하지 않는다.','카드는 여행자의 기억이며 NPC피해량·실제CD버프·공포·폭발·식물성장·동행·새AP/시간/체력비용 기능을 지급하지 않는다.','Gemma PASS는 자문이며 정적·JASS 변환 모의 검사·컴파일과 분리한다. Warcraft·화면·멀티·재미·밸런스는 미검증이다.']},null,2)+'\n',{flag:'wx'});
fs.writeFileSync(file,JSON.stringify(candidate,null,2)+'\n');console.log(JSON.stringify({newCards:6,newRoots:4,newFollowups:2,totalCards:candidate.cards.length,totalEvents:candidate.events.length,check}));
