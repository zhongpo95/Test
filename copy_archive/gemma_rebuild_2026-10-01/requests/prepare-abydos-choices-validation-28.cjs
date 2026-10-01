// 아비도스 세 카드 전체 분기와 네 자기 후속·새 기억 합산·열두 Gemma 저장 기록 대조를 준비한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..');
const write=(p,x)=>fs.writeFileSync(path.join(root,p),x,{flag:'wx'});
let probe=fs.readFileSync(path.join(root,'validation/head-card-choices-probe-16.cjs'),'utf8');
function replace(a,b){assert(probe.includes(a),a);probe=probe.replace(a,b);}
replace('후유키 전체 세 카드 분기와 입문 카드 중복 제거·새 기억 합산 및 개인 후속를 모의실행한다.','아비도스 세 카드·네 자기 후속·새 기억 합산과 부모 카드 반복 없음을 모의실행한다.');
probe=probe.replaceAll('fuyuki-card-choices-adopted-82','abydos-card-choices-adopted-90').replaceAll("'fuyuki'","'abydos'").replaceAll('head-card-choices-probe-16','head-card-choices-probe-18');
replace('assert.equal(data.events.length,16);assert.equal(historyGates.length,2);assert.equal(runs.length,102);','assert.equal(data.events.length,18);assert.equal(historyGates.length,4);assert.equal(runs.length,114);');
probe=probe.replaceAll('events:16,choices:48','events:18,choices:54').replaceAll('historyGates:2','historyGates:4').replace('학교연결끊기1/타이가질문1개인후속','라멘교대1/사막방어1/아루계산1/카요코한곡2개인후속');
replace("  probe.ProtoEventHistory[history]=event.previousChoice;assert(probe.ProtoEventEligible(0,id));assert(!probe.ProtoEventEligible(1,id));\n  historyGates.push({event:event.key,previous:event.previous,allowedChoice:event.previousChoice,wrongHistoryExcluded:true,otherPlayerExcluded:true});",`  probe.ProtoEventHistory[history]=event.previousChoice;
  const requiredCard=probe.ProtoEventRequiredCard[id];
  if(requiredCard>0){assert(!probe.ProtoEventEligible(0,id));probe.ProtoGrantCard(0,requiredCard);}
  assert(probe.ProtoEventEligible(0,id));assert(!probe.ProtoEventEligible(1,id));
  probe.ProtoEventHistory[history]=-event.previousChoice;assert(!probe.ProtoEventEligible(0,id));
  historyGates.push({event:event.key,previous:event.previous,allowedChoice:event.previousChoice,requiredCard:requiredCard>0?probe.ProtoCardKey[requiredCard]:null,requiredCardChecked:true,wrongHistoryExcluded:true,otherPlayerExcluded:true});`);
const start=probe.indexOf('const e=party(false),head='),end=probe.indexOf('fs.writeFileSync',start);assert(start>0&&end>start);
probe=probe.slice(0,start)+`const e=party(false),head=e.ProtoHeadKey.indexOf('abydos');enter(e,e.ProtoEventKey[(head-1)*4+1]);
assert.equal(e.ProtoStat(0,e.PROTO_STAT_CHOICES),1);assert.equal(e.ProtoStat(0,e.PROTO_STAT_HEALTH),3);
const newKeys=['abydos_serika_order','abydos_serika_finish','abydos_ayane_route','abydos_ayane_blank','ab68_mutsuki_watch','ab68_kayoko_interval','ab68_kayoko_order','ab68_haruka_ask','ab68_haruka_space','ab68_mutsuki_answer'];
for(const key of newKeys)e.ProtoGrantCard(0,card(e,key));
const expected={attack:10,crit:4,critDamage:24,move:3,regen:0.3,health:29,reduction:7,boss:8,nondirection:28,action:11,normal:26,healthy:10,choices:1};
const ids={attack:e.PROTO_STAT_ATTACK,crit:e.PROTO_STAT_CRIT,critDamage:e.PROTO_STAT_CRIT_DAMAGE,move:e.PROTO_STAT_MOVE,regen:e.PROTO_STAT_REGEN,health:e.PROTO_STAT_HEALTH,reduction:e.PROTO_STAT_REDUCTION,boss:e.PROTO_STAT_BOSS,nondirection:e.PROTO_STAT_NONDIRECTION,action:e.PROTO_STAT_ACTION,normal:e.PROTO_STAT_NORMAL,healthy:e.PROTO_STAT_HEALTHY,choices:e.PROTO_STAT_CHOICES};
for(const [key,value]of Object.entries(expected)){assert(Math.abs(e.ProtoStat(0,ids[key])-value)<1e-8,key);assert.equal(e.ProtoStat(1,ids[key]),0);}
const snapshot=Array.from({length:24},(_,i)=>e.ProtoStat(0,i+1));for(const key of newKeys)e.ProtoGrantCard(0,card(e,key));assert.deepEqual(Array.from({length:24},(_,i)=>e.ProtoStat(0,i+1)),snapshot);
const noParentCardRepeat=[];for(const event of data.events.filter(x=>x.previous)){const x=party();parent(x,event);for(const b of event.choices){assert(!x.ExpCardOwned[x.ExpKey(0,card(x,b.card))]);}noParentCardRepeat.push(event.key);}
report.newMemoryStats={expected,duplicateNotStacked:true,otherPlayerUnchanged:true};report.noParentCardRepeat=noParentCardRepeat;
`+probe.slice(end);
write('validation/head-card-choices-probe-18.cjs',probe);
let ci=fs.readFileSync(path.join(root,'validation/checkpoint-tests-27.cjs'),'utf8');
ci=ci.replace('액셀 세 카드 재구성 뒤 회귀 검사 및 Gemma 일곱 요청의 저장 원문을 대조한다.','아비도스 세 카드 재구성 뒤 회귀 검사 및 Gemma 열두 요청의 저장 원문을 대조한다.');
ci=ci.replace(/const records=\[[^;]+;/,"const records=[...[1,2,3,4].map(n=>'drafts/abydos-card-choices-text-86-'+n+'.json'),...[1,2,3,4].map(n=>'drafts/abydos-scenes-text-87-'+n+'.json'),...[1,2,3].map(n=>'reviews/abydos-card-choices-review-88-'+n+'.json'),'reviews/abydos-failure-review-89.json'];");
ci=ci.replaceAll('ci-commands-27-passed.json','ci-commands-28.json').replace("read('validation/ci-commands-26.json')","read('validation/ci-commands-27-passed.json')").replace('monitor-content-check-27.json','monitor-content-check-28.json').replace('card-contrast-audit-after-85.json','card-contrast-audit-after-90.json');
write('validation/checkpoint-tests-28.cjs',ci);
console.log(JSON.stringify({head:'abydos',events:18,choices:54,expectedBranchCases:114,monitorRecords:12}));
