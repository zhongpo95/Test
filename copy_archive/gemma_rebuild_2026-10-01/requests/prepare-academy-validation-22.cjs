// 기존 모의 검사와 회귀 검사 형식으로 학원도시 확장 검증 파일을 준비한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..');
let probe=fs.readFileSync(path.join(root,'validation/head-expansion-probe-10.cjs'),'utf8');
probe=probe.replace(/^\/\/.*\r?\n/,'// 학원도시 신규 사건의 지정 보상과 감소·개인 후속·확률 경계를 모의 실행한다.\n');
for(const [a,b]of [['aincrad-expansion-fixed-52','academy-expansion-fixed-58'],['aincrad-expansion-curated-54','academy-expansion-curated-60'],["[...fixed.events,...fixed.rewrites]","fixed.events"],["'aincrad'","'academy'"],["'sao_argo_fork'","'academy_vending_left_coin'"],["'sao_argo_second_question'","'academy_drink_after_vending'"],['length,4','length,5'],['historyGates.length,2','historyGates.length,1'],['runs.length,60','runs.length,34'],['newRoots:4','newRoots:5'],['rewrittenEvents:5','rewrittenEvents:0'],['head-expansion-probe-10.json','head-expansion-probe-11.json'],['두 후속의 자기 성공1번·65/66과70/71 판정','자기 성공1번·70/71 판정·밀도-1 감소']]){assert(probe.includes(a),a);probe=probe.replaceAll(a,b);}
fs.writeFileSync(path.join(root,'validation/head-expansion-probe-11.cjs'),probe,{flag:'wx'});
let tests=fs.readFileSync(path.join(root,'validation/checkpoint-tests-21.cjs'),'utf8');
tests=tests.replace(/^\/\/.*\r?\n/,'// 학원도시 확장 뒤 회귀 검사와 성공·실패 요청의 실제 저장 기록을 대조한다.\n');
tests=tests.replaceAll('ci-commands-20.json','ci-commands-21.json').replaceAll("write('validation/ci-commands-21.json'","write('validation/ci-commands-22.json'").replaceAll('monitor-content-check-21.json','monitor-content-check-22.json').replaceAll('card-contrast-audit-after-53.json','card-contrast-audit-after-60.json');
const a="['drafts/aincrad-pitches-51.json','drafts/aincrad-expansion-text-52.json','reviews/aincrad-expansion-review-53.json','reviews/aincrad-expansion-review-54.json','reviews/aincrad-focused-review-55.json']";
assert(tests.includes(a));tests=tests.replace(a,"['drafts/academy-pitches-57.json','drafts/academy-expansion-text-58.json','reviews/academy-expansion-review-59.json','reviews/academy-expansion-review-60.json']");
const point="write('validation/monitor-content-check-22.json'";assert(tests.includes(point));
tests=tests.replace(point,"const failed=read('reviews/academy-expansion-review-60-server-error.json');const failureResponse=await fetch(endpoint+'/api/records/'+failed.id,{headers:{'X-Session-Token':token}});assert(failureResponse.ok);const failure=await failureResponse.json();assert.deepEqual(failure,failed);assert.equal(failure.status,'error');assert.equal(failure.input.text,'academy-expansion-review-60.json');checks.push({file:'reviews/academy-expansion-review-60-server-error.json',recordId:failure.id,status:failure.status,inputMatches:true,fullRecordMatches:true});\n "+point);
tests=tests.replace('입력·원문·ID·저장 성공을 대조했다.','성공4요청의 입력·원문·ID와 실패1요청의 전체 저장 기록을 대조했다.');
fs.writeFileSync(path.join(root,'validation/checkpoint-tests-22.cjs'),tests,{flag:'wx'});
console.log(JSON.stringify({created:['head-expansion-probe-11.cjs','checkpoint-tests-22.cjs']}));
