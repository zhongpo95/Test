// 후유키 전체 세 카드 분기와 입문 카드 중복 제거·새 기억 합산 및 개인 후속를 모의실행한다.
'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const {fresh}=require('../../../tools/check-expedition-ui.cjs');
const root=path.resolve(__dirname,'..');
const data=JSON.parse(fs.readFileSync(path.join(root,'revisions/fuyuki-card-choices-adopted-82.json'),'utf8'));
function party(enterHead=true){const {e}=fresh(0,true);e.online=[true,true,false,false];e.ProtoCodexSlot[0]=e.ProtoCodexSlot[1]=1;e.ProtoAction(0,2001);e.ProtoAction(1,2001);if(enterHead)e.ProtoGrantHead(0,e.ProtoHeadKey.indexOf('fuyuki'));e.ExpGold[0]=1000;return e;}
function scene(e,key){const n=e.ProtoEventKey.indexOf(key);assert(n>0);return n;}
function card(e,key){const n=e.ProtoCardKey.indexOf(key);assert(n>=e.PROTO_CARD_FIRST);return n;}
function enter(e,key){const n=scene(e,key);assert(e.ProtoEventEligible(0,n));const oldRoll=e.GetRandomInt;e.GetRandomInt=min=>min;e.ProtoOffer(0);e.GetRandomInt=oldRoll;e.ProtoCandidates[e.ExpKey(0,1)]=n;e.ProtoAction(0,2101);assert.equal(e.ProtoSelected[0],n,key+' 사건 진입');}
function parent(e,event){if(!event.previous)return;enter(e,event.previous);e.GetRandomInt=()=>event.previousChoice<0?100:1;e.ProtoResolve(0,Math.abs(event.previousChoice));e.ProtoResume(0);assert.equal(e.ProtoEventHistory[e.ProtoStoryKey(0,scene(e,event.previous))],event.previousChoice);assert(e.ProtoEventEligible(0,scene(e,event.key)));}
const runs=[],availability=[],historyGates=[],lowerBounds=[];
for(const event of data.events){
 assert.equal(event.choices.length,3);assert.equal(new Set(event.choices.map(c=>c.card)).size,3);
 const probe=party(),id=scene(probe,event.key);assert.equal(probe.ProtoEventEligible(0,id),!event.previous);assert(!probe.ProtoEventEligible(1,id));
 if(event.previous){
  probe.ProtoGrantHead(1,probe.ProtoHeadKey.indexOf('fuyuki'));assert(!probe.ProtoEventEligible(1,id));
  const prior=scene(probe,event.previous),history=probe.ProtoStoryKey(0,prior);
  for(const choice of [-event.previousChoice,0,1,-1,2,-2,3,-3].filter(x=>x!==event.previousChoice)){probe.ProtoEventHistory[history]=choice;assert(!probe.ProtoEventEligible(0,id));}
  probe.ProtoEventHistory[history]=event.previousChoice;assert(probe.ProtoEventEligible(0,id));assert(!probe.ProtoEventEligible(1,id));
  historyGates.push({event:event.key,previous:event.previous,allowedChoice:event.previousChoice,wrongHistoryExcluded:true,otherPlayerExcluded:true});
 }
 for(const [i,b]of event.choices.entries())for(const roll of b.chance<100?[b.chance,b.chance+1]:[1])for(const duplicate of [false,true]){
  assert(b.card);assert.equal(b.gold,0);
  const e=party();parent(e,event);e.ExpGold[0]=1000;if(duplicate)e.ProtoGrantCard(0,card(e,b.card));
  enter(e,event.key);const potions=e.GetItemCharges(e.PlayerItem1[0]),level=e.ProtoLevel[0],density=e.ProtoDensity[0];e.GetRandomInt=()=>roll;e.ProtoResolve(0,i+1);
  const success=roll<=b.chance;
  assert.equal(e.ExpGold[0],1000-b.cost+(success&&duplicate?100:0));
  assert.equal(e.ProtoLevel[0],Math.max(1,level+b.level));assert.equal(e.ProtoDensity[0],Math.max(1,density+b.density));
  assert.equal(e.ProtoAP[0],event.previous?8:9);assert.equal(e.ProtoAP[1],10);
  assert.equal(e.GetItemCharges(e.PlayerItem1[0]),potions+(success?b.potions:0));
  assert.equal(!!e.ExpCardOwned[e.ExpKey(0,card(e,b.card))],success||duplicate);
  assert.equal(e.ProtoEventHistory[e.ProtoStoryKey(0,scene(e,event.key))],success?i+1:-i-1);
  assert(!e.ProtoEventEligible(0,scene(e,event.key)));assert(!e.ProtoEventEligible(1,scene(e,event.key)));
  for(const follow of data.events.filter(x=>x.previous===event.key)){
   const recorded=success?i+1:-i-1;assert.equal(e.ProtoEventEligible(0,scene(e,follow.key)),recorded===follow.previousChoice);assert(!e.ProtoEventEligible(1,scene(e,follow.key)));
  }
  runs.push({event:event.key,choice:i+1,roll,success,duplicate,gold:e.ExpGold[0],level:e.ProtoLevel[0],density:e.ProtoDensity[0],actionPoints:e.ProtoAP[0]});
 }
 for(const gold of [0,1000]){
  const e=party();parent(e,event);e.ExpGold[0]=gold;e.ProtoLevel[0]=5;e.ProtoDensity[0]=10;
  const legal=event.choices.map((b,i)=>e.ProtoBranchAvailable(0,scene(e,event.key),i+1)?i+1:0).filter(Boolean);
  assert.equal(e.ProtoEventEligible(0,scene(e,event.key)),legal.length>0);
  if(legal.length){enter(e,event.key);e.ProtoResolve(0,legal[0]);assert.equal(e.ProtoAP[0],event.previous?8:9);assert(e.ExpGold[0]>=0);assert(e.ProtoLevel[0]<=5);assert(e.ProtoDensity[0]<=10);}
  availability.push({event:event.key,gold,legalChoices:legal,excludedWhenNoLegalChoice:!legal.length});
 }
 for(const [i,b]of event.choices.entries())if(b.level<0||b.density<0){
  const e=party();parent(e,event);e.ExpGold[0]=1000;e.ProtoLevel[0]=e.ProtoDensity[0]=1;
  enter(e,event.key);e.GetRandomInt=()=>1;e.ProtoResolve(0,i+1);assert.equal(e.ProtoLevel[0],1);assert.equal(e.ProtoDensity[0],1);
  assert(e.ProtoBranchText(0,i+1).includes('최저 1'));
  lowerBounds.push({event:event.key,choice:i+1,level:1,density:1,clampAndDetail:true});
 }
}
assert.equal(data.events.length,16);assert.equal(historyGates.length,2);assert.equal(runs.length,102);
const report={events:16,choices:48,distinctCardsPerEvent:3,directGoldChoices:0,branchCases:runs.length,runs,availability,historyGates,passed:true,mapCreated:false,validation:'실제 생성JASS 함수의 변환모의실행이다. 세지정카드·비용·물약지급·필드변화·확률실패·중복100골드·AP1회·학교연결끊기1/타이가질문1개인후속·다른플레이어분리·골드0및상한에서유효선택없는사건의후보제외를검사했다. Warcraft실행·시각·멀티플레이·실전밸런스·재미검증은아니다.'};
report.lowerBounds=lowerBounds;
const e=party(false),head=e.ProtoHeadKey.indexOf('fuyuki');enter(e,e.ProtoEventKey[(head-1)*4+1]);assert.equal(e.ProtoStat(0,e.PROTO_STAT_ATTACK),11);
const structure=card(e,'fy_shiro_structure'),request=card(e,'fy_shiro_request');
e.ProtoGrantCard(0,structure);assert.equal(e.ProtoStat(0,e.PROTO_STAT_ATTACK),23);assert.equal(e.ProtoStat(0,e.PROTO_STAT_ACTION),3);assert.equal(e.ProtoStat(0,e.PROTO_STAT_REDUCTION),0);
e.ProtoGrantCard(0,request);assert.equal(e.ProtoStat(0,e.PROTO_STAT_ATTACK),35);assert.equal(e.ProtoStat(0,e.PROTO_STAT_ACTION),3);assert.equal(e.ProtoStat(0,e.PROTO_STAT_REDUCTION),2);
e.ProtoGrantCard(0,structure);assert.equal(e.ProtoStat(0,e.PROTO_STAT_ATTACK),35);assert.equal(e.ProtoStat(1,e.PROTO_STAT_ATTACK),0);
report.newMemoryStats={entryAttack:11,structureAttack:23,togetherAttack:35,action:3,reduction:2,duplicateNotStacked:true,otherPlayerUnchanged:true};
fs.writeFileSync(path.join(__dirname,'head-card-choices-probe-16.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({events:16,choices:48,branchCases:runs.length,historyGates:2,passed:true,mapCreated:false}));
