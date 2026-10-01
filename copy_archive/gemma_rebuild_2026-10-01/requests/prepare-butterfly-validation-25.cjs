// 나비저택의 개인 성공 후속과 변화량·모니터링 원문 대조 검사를 준비한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..');
let probe=fs.readFileSync(path.join(root,'validation/head-expansion-probe-13.cjs'),'utf8');
probe=probe.replace(/^\/\/.*\r?\n/,'// 나비저택의 자기60%성공후속·변화량감소·지정보상을모의실행한다.\n');
for(const [a,b]of [['abydos-expansion-fixed-69','butterfly-expansion-fixed-74'],['abydos-expansion-curated-70','butterfly-expansion-curated-74'],["'abydos'","'butterfly'"],['historyGates.length,2','historyGates.length,1'],['runs.length,38','runs.length,27'],['newFollowups:2','newFollowups:1'],['head-expansion-probe-13.json','head-expansion-probe-14.json'],['자기 성공1/2번·60/61과75/76 판정','자기 성공1번·60/61 판정']]){assert(probe.includes(a),a);probe=probe.replaceAll(a,b);}
fs.writeFileSync(path.join(root,'validation/head-expansion-probe-14.cjs'),probe,{flag:'wx'});
let tests=fs.readFileSync(path.join(root,'validation/checkpoint-tests-24.cjs'),'utf8');
tests=tests.replace(/^\/\/.*\r?\n/,'// 나비저택 확장 뒤 회귀 검사와 Gemma 세 요청의 실제 저장 원문을 대조한다.\n');
for(const [a,b]of [['ci-commands-23.json','ci-commands-24.json'],["write('validation/ci-commands-24.json'","write('validation/ci-commands-25.json'"],['monitor-content-check-24.json','monitor-content-check-25.json'],['card-contrast-audit-after-70.json','card-contrast-audit-after-74.json'],["['drafts/abydos-pitches-68.json','drafts/abydos-expansion-text-69.json','reviews/abydos-expansion-review-70.json']","['drafts/butterfly-pitches-72.json','drafts/butterfly-expansion-text-73.json','reviews/butterfly-expansion-review-74.json']"]]){assert(tests.includes(a),a);tests=tests.replaceAll(a,b);}
fs.writeFileSync(path.join(root,'validation/checkpoint-tests-25.cjs'),tests,{flag:'wx'});console.log('나비저택 검증 도구 저장.');
