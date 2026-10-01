// 랜서 카드의 이동중이라는 잘못된 집필 기준을 실제 추가 이동속도 비례 함수와 대조해 정정한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const file=path.join(repo,'content/roguelite/01-fuyuki.json'),candidate=JSON.parse(fs.readFileSync(file,'utf8')),fixed=read('requests/fuyuki-expansion-fixed-64.json'),source=fs.readFileSync(path.join(repo,'System/ExpeditionEffects.j'),'utf8');
assert(source.includes('(GetUnitMoveSpeed(source) / 400.0 - 1.0) / 0.40'));
const card=candidate.cards.find(c=>c.key==='fy_lancer_second'),event=candidate.events.find(e=>e.key==='fy_after_one_block'),before={keyword:card.keyword,canonFact:card.canonFact,result:event.choices[1].result};
card.keyword='이동속도 비례 피해 · 방어 관통';card.canonFact='강한 대응 뒤 다음 발을 살피는 창작 만남이다. 이동속도 비례 피해는 기본400대비 추가 이동속도에 따라 커지며 추가40%에서 카드의12%가 전부 적용된다. 이동 중이라는 판정으로 켜지지 않는다. 원작 보구의 필중·즉사·방패 파괴·새 돌진을 지급하지 않는다.';
event.choices[1].result=event.choices[1].result.replace('이동 중 가하는 피해와 방어 관통이 늘었다.','추가 이동속도에 따라 가하는 피해와 방어 관통이 늘었다.');assert.notEqual(event.choices[1].result,before.result);
fixed.cards[fixed.cards.findIndex(c=>c.key===card.key)]=card;
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
write('revisions/fuyuki-moving-correction-66.json',{key:card.key,before,after:{keyword:card.keyword,canonFact:card.canonFact,result:event.choices[1].result},reason:'Codex가 집필63과 검토64의 기준에 이동중피해라고 잘못 적었다. Gemma 검토는 이 잘못된 기준을 정확히 준수했다고 평가했으므로 계산 정확성의 근거가 될 수 없다. 실제 JASS와 기존 능력치 단위 문서를 대조해 설명만 정정한다.',evidence:{file:'System/ExpeditionEffects.j',expression:'12 * min(1,max(0,(이동속도/400-1)/0.40))',examples:[{moveSpeed:400,damagePercent:0},{moveSpeed:480,damagePercent:6},{moveSpeed:560,damagePercent:12}],display:'Data/Data_PrototypeStats.j의 추가 이동속도40%에서 대미지 증가',document:'md/roguelite/카드 능력치 단위와 검토 기준.md의 이동중 판정으로 활성화되지 않음'},numericExceptions:[],limits:'원래 함수와12/4효과 수치는 그대로다. 집필·검토 원문은 덮어쓰지 않았다. Warcraft 실기 검증은 아니다.'});
write('requests/fuyuki-expansion-fixed-66.json',fixed);write('revisions/fuyuki-expansion-curated-66.json',candidate);fs.writeFileSync(file,JSON.stringify(candidate,null,2)+'\n');console.log(JSON.stringify({descriptionCorrections:1,numericExceptions:0,check}));
