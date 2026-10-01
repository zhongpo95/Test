// 후유키 사건의 분기·개인 후속과 회귀·공통 기록 대조 검사를 준비한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..');
let probe=fs.readFileSync(path.join(root,'validation/head-expansion-probe-11.cjs'),'utf8');
probe=probe.replace(/^\/\/.*\r?\n/,'// 후유키 신규 사건의 지정 보상과 감소·개인 후속·확률 경계를 모의 실행한다.\n');
for(const [a,b]of [['academy-expansion-fixed-58','fuyuki-expansion-fixed-66'],['academy-expansion-curated-60','fuyuki-expansion-curated-66'],["'academy'","'fuyuki'"],["'academy_vending_left_coin'","'fy_arrow_on_floor'"],["'academy_drink_after_vending'","'fy_next_arrow_wait'"],['length,5','length,4'],['runs.length,34','runs.length,30'],['newRoots:5','newRoots:4'],['head-expansion-probe-11.json','head-expansion-probe-12.json'],['70/71 판정','75/76 판정']]){assert(probe.includes(a),a);probe=probe.replaceAll(a,b);}
fs.writeFileSync(path.join(root,'validation/head-expansion-probe-12.cjs'),probe,{flag:'wx'});
let tests=fs.readFileSync(path.join(root,'validation/checkpoint-tests-21.cjs'),'utf8');
tests=tests.replace(/^\/\/.*\r?\n/,'// 후유키 확장 뒤 회귀 검사와 Gemma 네 요청의 실제 저장 원문을 대조한다.\n');
tests=tests.replaceAll('ci-commands-20.json','ci-commands-22.json').replaceAll("write('validation/ci-commands-21.json'","write('validation/ci-commands-23.json'").replaceAll('monitor-content-check-21.json','monitor-content-check-23.json').replaceAll('card-contrast-audit-after-53.json','card-contrast-audit-after-66.json');
const a="['drafts/aincrad-pitches-51.json','drafts/aincrad-expansion-text-52.json','reviews/aincrad-expansion-review-53.json','reviews/aincrad-expansion-review-54.json','reviews/aincrad-focused-review-55.json']";assert(tests.includes(a));
tests=tests.replace(a,"['drafts/fuyuki-pitches-62.json','drafts/fuyuki-expansion-text-63.json','reviews/fuyki-expansion-review-64.json','reviews/fuyuki-focused-review-67.json']".replace('fuyki','fuyuki'));
fs.writeFileSync(path.join(root,'validation/checkpoint-tests-23.cjs'),tests,{flag:'wx'});
console.log(JSON.stringify({created:['head-expansion-probe-12.cjs','checkpoint-tests-23.cjs']}));
