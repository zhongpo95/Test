// 실제 아인크라드 카드 데이터로 이동속도 정규화와65%체력 조건의 경계를 대조한다.
'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');const {fresh}=require('../../../tools/check-attack-potion.cjs');const {e}=fresh(true);
e.ProtoStatsInit();e.ProtoCatalogInit();e.ExpPrototypeActive=true;e.ExpMember[0]=true;e.ExpState=e.EXP_HUNT;
for(const key of ['sao_argo_sketch','sao_agil_axe']){const id=e.ProtoCardKey.indexOf(key);assert(id>=e.PROTO_CARD_FIRST);e.ExpCardOwned[e.ExpKey(0,id)]=true;}
e.ProtoRebuildCardStats(0,e.PROTO_CARD_FIRST,e.PROTO_CARD_LAST,0);assert.equal(e.ProtoStat(0,e.PROTO_STAT_MOVING),8);assert.equal(e.ProtoStat(0,e.PROTO_STAT_HEALTHY),10);
let speed=400,life=6499;const maximum=10000;e.GetUnitMoveSpeed=()=>speed;e.GetUnitState=(u,state)=>state===e.UNIT_STATE_MAX_LIFE?maximum:life;e.UnitSD[0]=0;
const results=[];for(const current of [350,400,480,560,600])for(const health of [6499,6500]){speed=current;life=health;const actual=e.ExpArcanaDamage(0,0,2,false,false,false),expected=(current<=400?0:current===480?4:8)+(health===6500?10:0);assert(Math.abs(actual-expected)<1e-8);results.push({speed,life,actual,expected});}
fs.writeFileSync(path.join(__dirname,'aincrad-conditions-108.json'),JSON.stringify({passed:true,results,mapCreated:false,limits:'실제 JASS 변환·카드 데이터의 모의 실행이다. Warcraft·시각·멀티·저장·재미·실전 밸런스는 미검증.'},null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({passed:true,cases:results.length}));
