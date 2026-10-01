// 학원도시 세 카드 전체 분기·세 자기 후속·새 기억 합산과 일곱 저장 원문 검사를 준비한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),write=(p,x)=>fs.writeFileSync(path.join(root,p),x,{flag:'wx'});
let probe=fs.readFileSync(path.join(root,'validation/head-card-choices-probe-18.cjs'),'utf8');
probe=probe.replace('아비도스 세 카드·네 자기 후속·새 기억 합산과 부모 카드 반복 없음을 모의실행한다.','학원도시 세 카드·세 자기 후속·새 기억 합산과 부모 카드 반복 없음을 모의실행한다.').replaceAll('abydos-card-choices-adopted-90','academy-card-choices-adopted-93').replaceAll("'abydos'","'academy'").replaceAll('head-card-choices-probe-18','head-card-choices-probe-19').replaceAll('historyGates.length,4','historyGates.length,3').replaceAll('runs.length,114','runs.length,112').replaceAll('historyGates:4','historyGates:3').replace('라멘교대1/사막방어1/아루계산1/카요코한곡2개인후속','구조백업1/현장진입2/다른곳음료1개인후속');
const start=probe.indexOf('assert.equal(e.ProtoStat(0,e.PROTO_STAT_CHOICES),1);'),end=probe.indexOf('for(const [key,value]',start);assert(start>0&&end>start);
probe=probe.slice(0,start)+`assert.equal(e.ProtoStat(0,e.PROTO_STAT_CHOICES),1);assert.equal(e.ProtoStat(0,e.PROTO_STAT_ACTION),2);
const newKeys=['academy_uiharu_order','academy_saten_detour','academy_saten_box','academy_kuroko_line','academy_touma_address','academy_tessou_seat','academy_tessou_interval','academy_uiharu_list'];
for(const key of newKeys)e.ProtoGrantCard(0,card(e,key));
const expected={attack:12,move:3,normal:26,choices:2,chargeSpeed:9,nondirection:12,reduction:4,health:16,boss:10,critDamage:39,healthy:10,action:2};
const ids={attack:e.PROTO_STAT_ATTACK,move:e.PROTO_STAT_MOVE,normal:e.PROTO_STAT_NORMAL,choices:e.PROTO_STAT_CHOICES,chargeSpeed:e.PROTO_STAT_CHARGE_SPEED,nondirection:e.PROTO_STAT_NONDIRECTION,reduction:e.PROTO_STAT_REDUCTION,health:e.PROTO_STAT_HEALTH,boss:e.PROTO_STAT_BOSS,critDamage:e.PROTO_STAT_CRIT_DAMAGE,healthy:e.PROTO_STAT_HEALTHY,action:e.PROTO_STAT_ACTION};
`+probe.slice(end);
write('validation/head-card-choices-probe-19.cjs',probe);
let ci=fs.readFileSync(path.join(root,'validation/checkpoint-tests-28.cjs'),'utf8');
ci=ci.replace('아비도스 세 카드 재구성 뒤 회귀 검사 및 Gemma 열두 요청의 저장 원문을 대조한다.','학원도시 세 카드 재구성 뒤 회귀 검사 및 Gemma 일곱 요청의 저장 원문을 대조한다.').replace("read('validation/ci-commands-27-passed.json')","read('validation/ci-commands-28.json')").replaceAll('ci-commands-28.json\',{passed','ci-commands-29.json\',{passed').replace('monitor-content-check-28.json','monitor-content-check-29.json').replace('card-contrast-audit-after-90.json','card-contrast-audit-after-93.json');
ci=ci.replace(/const records=\[[^;]+;/,"const records=[...[1,2,3,4].map(n=>'drafts/academy-scenes-text-91-'+n+'.json'),...[1,2,3].map(n=>'reviews/academy-card-choices-review-92-'+n+'.json')];");
assert(ci.includes("write('validation/ci-commands-29.json'"));write('validation/checkpoint-tests-29.cjs',ci);
console.log(JSON.stringify({events:18,choices:54,expectedBranchCases:112,monitorRecords:7}));
