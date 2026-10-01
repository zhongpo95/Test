// 액셀 세 카드·돈 사건 예외·후속 소유 중복과 새 여덟 기억 합산의 모의 검사 및 저장 기록 대조를 준비한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..');
const write=(p,x)=>fs.writeFileSync(path.join(root,p),x,{flag:'wx'});
let probe=fs.readFileSync(path.join(root,'validation/head-card-choices-probe-16.cjs'),'utf8');
function replace(a,b){assert(probe.includes(a),a);probe=probe.replace(a,b);}
replace('후유키 전체 세 카드 분기와 입문 카드 중복 제거·새 기억 합산 및 개인 후속를 모의실행한다.','액셀의 세 카드와 명세서 돈 예외·새 기억 합산·부모 소유 카드 배제를 모의실행한다.');
probe=probe.replaceAll('fuyuki-card-choices-adopted-82','axel-card-choices-adopted-85').replaceAll("'fuyuki'","'axel'").replaceAll('head-card-choices-probe-16','head-card-choices-probe-17');
replace('assert.equal(event.choices.length,3);assert.equal(new Set(event.choices.map(c=>c.card)).size,3);',"const rewards=event.choices.filter(c=>c.card);assert.equal(rewards.length,3);assert.equal(new Set(rewards.map(c=>c.card)).size,3);assert.equal(event.choices.length,event.key==='axel_stolen_notice'?4:3);");
replace('for(const duplicate of [false,true]){','for(const duplicate of b.card?[false,true]:[false]){');
replace('assert(b.card);assert.equal(b.gold,0);',"if(b.card)assert.equal(b.gold,0);else {assert.equal(event.key,'axel_stolen_notice');assert.equal(i,1);assert.equal(b.gold,230);}");
replace('1000-b.cost+(success&&duplicate?100:0)','1000-b.cost+(success?b.gold:0)+(success&&duplicate?100:0)');
replace('assert.equal(!!e.ExpCardOwned[e.ExpKey(0,card(e,b.card))],success||duplicate);','if(b.card)assert.equal(!!e.ExpCardOwned[e.ExpKey(0,card(e,b.card))],success||duplicate);');
replace('assert.equal(runs.length,102);','assert.equal(runs.length,99);');
replace('events:16,choices:48,distinctCardsPerEvent:3,directGoldChoices:0','events:16,choices:49,distinctCardsPerEvent:3,directGoldChoices:1');
replace('학교연결끊기1/타이가질문1개인후속','밀린의뢰1/우리고정용품1개인후속');
const start=probe.indexOf('const e=party(false),head='),end=probe.indexOf('fs.writeFileSync',start);assert(start>0&&end>start);
probe=probe.slice(0,start)+`const e=party(false),head=e.ProtoHeadKey.indexOf('axel');enter(e,e.ProtoEventKey[(head-1)*4+1]);
assert.equal(e.ProtoStat(0,e.PROTO_STAT_CHOICES),1);assert.equal(e.ProtoStat(0,e.PROTO_STAT_GOLD),1);
const newKeys=['axel_chris_trace','axel_kazuma_share','axel_aqua_supply','axel_aqua_return','axel_luna_space','axel_yunyun_gap','axel_darkness_position','axel_wiz_small'];
for(const key of newKeys)e.ProtoGrantCard(0,card(e,key));
const expected={attack:12,crit:3,critDamage:26,move:4,regen:0.7,health:10,reduction:16,chargeSpeed:12,direction:12,choices:2,gold:1};
const ids={attack:e.PROTO_STAT_ATTACK,crit:e.PROTO_STAT_CRIT,critDamage:e.PROTO_STAT_CRIT_DAMAGE,move:e.PROTO_STAT_MOVE,regen:e.PROTO_STAT_REGEN,health:e.PROTO_STAT_HEALTH,reduction:e.PROTO_STAT_REDUCTION,chargeSpeed:e.PROTO_STAT_CHARGE_SPEED,direction:e.PROTO_STAT_DIRECTION,choices:e.PROTO_STAT_CHOICES,gold:e.PROTO_STAT_GOLD};
for(const [key,value]of Object.entries(expected)){assert(Math.abs(e.ProtoStat(0,ids[key])-value)<1e-8,key);assert.equal(e.ProtoStat(1,ids[key]),0);}
const snapshot=Array.from({length:24},(_,i)=>e.ProtoStat(0,i+1));for(const key of newKeys)e.ProtoGrantCard(0,card(e,key));assert.deepEqual(Array.from({length:24},(_,i)=>e.ProtoStat(0,i+1)),snapshot);
const noParentCardRepeat=[];for(const event of data.events.filter(x=>x.previous)){const x=party();parent(x,event);for(const b of event.choices.filter(c=>c.card)){assert(!x.ExpCardOwned[x.ExpKey(0,card(x,b.card))]);}noParentCardRepeat.push(event.key);}
report.newMemoryStats={expected,duplicateNotStacked:true,otherPlayerUnchanged:true};report.noParentCardRepeat=noParentCardRepeat;
`+probe.slice(end);
probe=probe.replaceAll('events:16,choices:48','events:16,choices:49');
write('validation/head-card-choices-probe-17.cjs',probe);
let ci=fs.readFileSync(path.join(root,'validation/checkpoint-tests-26.cjs'),'utf8');
ci=ci.replace('후유키 세 카드 재구성 뒤 회귀 검사 및 Gemma 아홉 요청의 저장 원문을 대조한다.','액셀 세 카드 재구성 뒤 회귀 검사 및 Gemma 일곱 요청의 저장 원문을 대조한다.');
ci=ci.replace(/const records=\[[^;]+;/,"const records=[...[1,2,3,4].map(n=>'drafts/axel-card-choices-text-83-'+n+'.json'),...[1,2,3].map(n=>'reviews/axel-card-choices-review-84-'+n+'.json')];");
ci=ci.replaceAll('ci-commands-26.json','ci-commands-27.json').replace("read('validation/ci-commands-25.json')","read('validation/ci-commands-26.json')").replace('monitor-content-check-26.json','monitor-content-check-27.json').replace('card-contrast-audit-after-82.json','card-contrast-audit-after-85.json');
write('validation/checkpoint-tests-27.cjs',ci);
console.log(JSON.stringify({head:'axel',events:16,choices:49,expectedBranchCases:99,monitorRecords:7}));
