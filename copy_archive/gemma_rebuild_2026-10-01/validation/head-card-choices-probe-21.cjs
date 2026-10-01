// 아인크라드 전체 세 카드·두 확률 경계·개인 후속·무료 조건 방문·행동력 카드를 모의 실행한다.
'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');const {fresh}=require('../../../tools/check-expedition-ui.cjs');const root=path.resolve(__dirname,'..');
const data=JSON.parse(fs.readFileSync(path.join(root,'revisions/aincrad-card-choices-adopted-108.json'),'utf8'));
const card=(e,key)=>{const n=e.ProtoCardKey.indexOf(key);assert(n>=e.PROTO_CARD_FIRST,key);return n;};const scene=(e,key)=>{const n=e.ProtoEventKey.indexOf(key);assert(n>0,key);return n;};
function party(){const {e}=fresh(0,true);e.online=[true,true,false,false];for(let pid=0;pid<2;pid++){e.ProtoCodexSlot[pid]=1;e.ProtoAction(pid,2001);}e.ProtoGrantHead(0,e.ProtoHeadKey.indexOf('aincrad'));e.ExpGold[0]=1000;return e;}
function enter(e,key){const id=scene(e,key);assert(e.ProtoEventEligible(0,id),key);e.ProtoOffer(0);e.ProtoCandidates[e.ExpKey(0,1)]=id;e.ProtoAction(0,2101);assert.equal(e.ProtoSelected[0],id);}
function requirements(e,event){if(event.previous){const prior=data.events.find(x=>x.key===event.previous);requirements(e,prior);enter(e,prior.key);e.GetRandomInt=()=>event.previousChoice<0?100:1;e.ProtoResolve(0,Math.abs(event.previousChoice));e.ProtoResume(0);}if(event.requiredCard)e.ProtoGrantCard(0,card(e,event.requiredCard));}
const runs=[],gates=[],bounds=[],availability=[];
for(const event of data.events){
 assert.equal(event.choices.length,3);assert.equal(new Set(event.choices.map(c=>c.card)).size,3);
 const probe=party(),id=scene(probe,event.key);assert.equal(probe.ProtoEventEligible(0,id),!event.previous&&!event.requiredCard);assert(!probe.ProtoEventEligible(1,id));
 if(event.previous){const history=probe.ProtoStoryKey(0,scene(probe,event.previous));for(const choice of [0,-1,1,-2,2,-3,3].filter(x=>x!==event.previousChoice)){probe.ProtoEventHistory[history]=choice;assert(!probe.ProtoEventEligible(0,id));}probe.ProtoEventHistory[history]=event.previousChoice;assert(probe.ProtoEventEligible(0,id));probe.ProtoGrantHead(1,probe.ProtoHeadKey.indexOf('aincrad'));assert(!probe.ProtoEventEligible(1,id));gates.push({event:event.key,previous:event.previous,allowedChoice:event.previousChoice});}
 if(event.requiredCard){probe.ProtoGrantCard(0,card(probe,event.requiredCard));assert(probe.ProtoEventEligible(0,id));probe.ProtoGrantHead(1,probe.ProtoHeadKey.indexOf('aincrad'));assert(!probe.ProtoEventEligible(1,id));gates.push({event:event.key,requiredCard:event.requiredCard,personal:true});}
 for(const [i,b]of event.choices.entries())for(const roll of b.chance<100?[b.chance,b.chance+1]:[1])for(const duplicate of [false,true]){
  assert(b.card);assert.equal(b.gold,0);const e=party();requirements(e,event);e.ExpGold[0]=1000;const reward=card(e,b.card);if(duplicate)e.ProtoGrantCard(0,reward);
  const beforeAP=e.ProtoAP[0],beforeMax=e.ProtoAPMax[0];enter(e,event.key);assert.equal(e.ProtoAP[0],beforeAP-(event.actionCost??1));
  const potions=e.GetItemCharges(e.PlayerItem1[0]),level=e.ProtoLevel[0],density=e.ProtoDensity[0];e.GetRandomInt=()=>roll;e.ProtoResolve(0,i+1);const success=roll<=b.chance;
  const capacity=success&&!duplicate?(data.cards.find(c=>c.key===b.card).effects.find(f=>f.stat==='action_capacity')?.value??0):0;
  assert.equal(e.ExpGold[0],1000-b.cost+(success&&duplicate?100:0));assert.equal(e.ProtoAP[0],beforeAP-(event.actionCost??1)+capacity);assert.equal(e.ProtoAPMax[0],beforeMax+capacity);assert.equal(e.ProtoAP[1],10);
  assert.equal(e.ProtoLevel[0],Math.max(1,level+b.level));assert.equal(e.ProtoDensity[0],Math.max(1,density+b.density));assert.equal(e.GetItemCharges(e.PlayerItem1[0]),potions+(success?b.potions:0));assert.equal(!!e.ExpCardOwned[e.ExpKey(0,reward)],success||duplicate);
  const signed=success?i+1:-i-1;assert.equal(e.ProtoEventHistory[e.ProtoStoryKey(0,scene(e,event.key))],signed);assert(!e.ProtoEventEligible(0,scene(e,event.key)));assert(!e.ProtoEventEligible(1,scene(e,event.key)));
  for(const next of data.events.filter(x=>x.previous===event.key)){assert.equal(e.ProtoEventEligible(0,scene(e,next.key)),signed===next.previousChoice);assert(!e.ProtoEventEligible(1,scene(e,next.key)));}
  runs.push({event:event.key,choice:i+1,roll,success,duplicate,gold:e.ExpGold[0],level:e.ProtoLevel[0],density:e.ProtoDensity[0],ap:e.ProtoAP[0],max:e.ProtoAPMax[0]});
 }
 for(const gold of [0,1000]){const e=party();requirements(e,event);e.ExpGold[0]=gold;e.ProtoLevel[0]=5;e.ProtoDensity[0]=10;const legal=event.choices.map((b,i)=>e.ProtoBranchAvailable(0,scene(e,event.key),i+1)?i+1:0).filter(Boolean);assert.equal(e.ProtoEventEligible(0,scene(e,event.key)),legal.length>0);if(legal.length){enter(e,event.key);e.ProtoResolve(0,legal[0]);assert(e.ExpGold[0]>=0);assert(e.ProtoLevel[0]<=5);assert(e.ProtoDensity[0]<=10);}availability.push({event:event.key,gold,legal});}
 for(const [i,b]of event.choices.entries())if(b.level<0||b.density<0){const e=party();requirements(e,event);e.ExpGold[0]=1000;e.ProtoLevel[0]=e.ProtoDensity[0]=1;enter(e,event.key);e.GetRandomInt=()=>1;e.ProtoResolve(0,i+1);assert.equal(e.ProtoLevel[0],1);assert.equal(e.ProtoDensity[0],1);assert(e.ProtoBranchText(0,i+1).includes('최저 1'));bounds.push({event:event.key,choice:i+1});}
}
assert.equal(runs.length,112);assert.equal(gates.length,4);
const e=party(),newKeys=['sao_liz_shards','sao_klein_carry','sao_agil_axe','sao_kirito_sign','sao_asuna_margin','sao_nishida_pause','sao_nishida_next','sao_argo_sketch'];for(const key of newKeys)e.ProtoGrantCard(0,card(e,key));
const expected={critDamage:40,penetration:5,move:3,reduction:4,normal:29,healthy:10,crit:4,chargeSpeed:6,swift:180,regen:0.4,capacity:1,moving:8};
const stats={critDamage:e.PROTO_STAT_CRIT_DAMAGE,penetration:e.PROTO_STAT_PENETRATION,move:e.PROTO_STAT_MOVE,reduction:e.PROTO_STAT_REDUCTION,normal:e.PROTO_STAT_NORMAL,healthy:e.PROTO_STAT_HEALTHY,crit:e.PROTO_STAT_CRIT,chargeSpeed:e.PROTO_STAT_CHARGE_SPEED,swift:e.PROTO_STAT_SWIFT,regen:e.PROTO_STAT_REGEN,capacity:e.PROTO_STAT_CAPACITY,moving:e.PROTO_STAT_MOVING};
for(const [key,value]of Object.entries(expected)){assert(Math.abs(e.ProtoStat(0,stats[key])-value)<1e-8,key);assert.equal(e.ProtoStat(1,stats[key]),0);}assert.equal(e.ProtoAP[0],11);assert.equal(e.ProtoAPMax[0],11);
const snapshot=Array.from({length:25},(_,i)=>e.ProtoStat(0,i+1));for(const key of newKeys)e.ProtoGrantCard(0,card(e,key));assert.deepEqual(Array.from({length:25},(_,i)=>e.ProtoStat(0,i+1)),snapshot);assert.equal(e.ProtoAP[0],11);
const noRepeats=[];for(const event of data.events.filter(x=>x.previous||x.requiredCard)){const x=party();requirements(x,event);for(const b of event.choices)assert(!x.ExpCardOwned[x.ExpKey(0,card(x,b.card))]);noRepeats.push(event.key);}
const report={events:18,choices:54,branchCases:runs.length,runs,gates,bounds,availability,newMemoryStats:expected,noRepeats,passed:true,mapCreated:false,limits:'실제 JASS의 변환 모의 실행이다. Warcraft·시각·멀티·저장·재미·실전 밸런스는 미검증.'};fs.writeFileSync(path.join(__dirname,'head-card-choices-probe-21.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({events:18,choices:54,branchCases:112,gates:4,passed:true}));
