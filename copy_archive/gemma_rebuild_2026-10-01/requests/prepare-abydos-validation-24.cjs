// 아비도스의 두 개인 성공 후속과 확률·수량 감소·보상 및 공통 기록 대조 검사를 준비한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..');
let probe=fs.readFileSync(path.join(root,'validation/head-expansion-probe-12.cjs'),'utf8');
probe=probe.replace(/^\/\/.*\r?\n/,'// 아비도스 신규 사건의 두 개인 후속·확률·수량 감소·지정 보상을 모의 실행한다.\n');
for(const [a,b]of [['fuyuki-expansion-fixed-66','abydos-expansion-fixed-69'],['fuyuki-expansion-curated-66','abydos-expansion-curated-70'],["'fuyuki'","'abydos'"],['[-event.previousChoice,0,2,3]','[-event.previousChoice,0,1,2,3,4].filter(x=>x!==event.previousChoice)'],['historyGates.length,1','historyGates.length,2'],['runs.length,30','runs.length,38'],['newFollowups:1','newFollowups:2'],['head-expansion-probe-12.json','head-expansion-probe-13.json'],['자기 성공1번·75/76 판정','자기 성공1/2번·60/61과75/76 판정']]){assert(probe.includes(a),a);probe=probe.replaceAll(a,b);}
const old="if(event.key==='fy_arrow_on_floor'){assert.equal(e.ProtoEventEligible(0,scene(e,'fy_next_arrow_wait')),i===0&&success);assert(!e.ProtoEventEligible(1,scene(e,'fy_next_arrow_wait')));}";
assert(probe.includes(old));probe=probe.replace(old,"for(const follow of checked.filter(x=>x.previous===event.key)){assert.equal(e.ProtoEventEligible(0,scene(e,follow.key)),i+1===follow.previousChoice&&success);assert(!e.ProtoEventEligible(1,scene(e,follow.key)));}");
fs.writeFileSync(path.join(root,'validation/head-expansion-probe-13.cjs'),probe,{flag:'wx'});
let tests=fs.readFileSync(path.join(root,'validation/checkpoint-tests-23.cjs'),'utf8');
tests=tests.replace(/^\/\/.*\r?\n/,'// 아비도스 확장 뒤 회귀 검사와 Gemma 세 요청의 실제 저장 원문을 대조한다.\n');
for(const [a,b]of [['ci-commands-22.json','ci-commands-23.json'],["write('validation/ci-commands-23.json'","write('validation/ci-commands-24.json'"],['monitor-content-check-23.json','monitor-content-check-24.json'],['card-contrast-audit-after-66.json','card-contrast-audit-after-70.json'],["['drafts/fuyuki-pitches-62.json','drafts/fuyuki-expansion-text-63.json','reviews/fuyuki-expansion-review-64.json','reviews/fuyuki-focused-review-67.json']","['drafts/abydos-pitches-68.json','drafts/abydos-expansion-text-69.json','reviews/abydos-expansion-review-70.json']"]]){assert(tests.includes(a),a);tests=tests.replaceAll(a,b);}
fs.writeFileSync(path.join(root,'validation/checkpoint-tests-24.cjs'),tests,{flag:'wx'});
console.log(JSON.stringify({created:['head-expansion-probe-13.cjs','checkpoint-tests-24.cjs']}));
