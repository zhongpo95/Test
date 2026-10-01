// 신규 독립 사건의 머리 소지 조건·분기 손익·중복 교환·상한의 유효 선택을 대조한다.
'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const {fresh}=require('../../../tools/check-expedition-ui.cjs');
const root=path.resolve(__dirname,'..');
const cases=[['abydos','abydos-expansion-curated-16.json','before-abydos-expansion-16.json'],['academy','academy-expansion-curated-18.json','before-academy-expansion-18.json']];
function party(head){const {e}=fresh(0,true);e.online=[true,true,false,false];e.ProtoCodexSlot[0]=e.ProtoCodexSlot[1]=1;e.ProtoAction(0,2001);e.ProtoAction(1,2001);e.ProtoGrantHead(0,e.ProtoHeadKey.indexOf(head));e.ExpGold[0]=1000;return e;}
function scene(e,key){const n=e.ProtoEventKey.indexOf(key);assert(n>0);return n;}
function card(e,key){const n=e.ProtoCardKey.indexOf(key);assert(n>=e.PROTO_CARD_FIRST);return n;}
function enter(e,key){const n=scene(e,key);e.ProtoOffer(0);e.ProtoCandidates[e.ExpKey(0,1)]=n;e.ProtoAction(0,2101);assert.equal(e.ProtoSelected[0],n);}
const runs=[],fallbacks=[];
for(const [head,file,beforeFile]of cases){
 const data=JSON.parse(fs.readFileSync(path.join(root,'revisions',file),'utf8'));
 const before=new Set(JSON.parse(fs.readFileSync(path.join(root,beforeFile),'utf8')).events.map(e=>e.key));
 for(const event of data.events.filter(x=>!before.has(x.key))){
  assert.equal(event.previous,null);assert.equal(event.previousChoice,0);assert.equal(event.requiredCard,null);
  const probe=party(head),id=scene(probe,event.key);assert(probe.ProtoEventEligible(0,id));assert(!probe.ProtoEventEligible(1,id));
  assert.equal(probe.ProtoEventHistory[probe.ProtoStoryKey(0,id)]||0,0);
  for(const [i,b]of event.choices.entries())for(const roll of b.chance<100?[b.chance,b.chance+1]:[1])for(const duplicate of b.card?[false,true]:[false]){
   const e=party(head);if(duplicate)e.ProtoGrantCard(0,card(e,b.card));
   enter(e,event.key);const potions=e.GetItemCharges(e.PlayerItem1[0]),ap=e.ProtoAP[0];e.GetRandomInt=()=>roll;e.ProtoResolve(0,i+1);
   const success=roll<=b.chance;
   assert.equal(e.ExpGold[0],1000-b.cost+(success?b.gold+(duplicate?100:0):0));
   assert.equal(e.ProtoLevel[0],Math.max(1,1+b.level));assert.equal(e.ProtoDensity[0],Math.max(1,4+b.density));
   assert.equal(e.ProtoAP[0],9);assert.equal(ap,9);assert.equal(e.ProtoAP[1],10);
   assert.equal(e.GetItemCharges(e.PlayerItem1[0]),potions+(success?b.potions:0));
   if(b.card)assert.equal(!!e.ExpCardOwned[e.ExpKey(0,card(e,b.card))],success||duplicate);
   assert.equal(e.ProtoEventHistory[e.ProtoStoryKey(0,scene(e,event.key))],success?i+1:-i-1);
   assert(!e.ProtoEventEligible(0,scene(e,event.key)));assert(!e.ProtoEventEligible(1,scene(e,event.key)));
   runs.push({head,event:event.key,choice:i+1,roll,success,duplicate,gold:e.ExpGold[0],level:e.ProtoLevel[0],density:e.ProtoDensity[0]});
  }
  const e=party(head);e.ExpGold[0]=0;e.ProtoLevel[0]=5;e.ProtoDensity[0]=10;
  const legal=event.choices.map((b,i)=>e.ProtoBranchAvailable(0,scene(e,event.key),i+1)?i+1:0).filter(Boolean);assert(legal.length>0);
  assert(e.ProtoEventEligible(0,scene(e,event.key)));enter(e,event.key);e.ProtoResolve(0,legal[0]);assert.equal(e.ProtoAP[0],9);assert(e.ExpGold[0]>=0);
  fallbacks.push({head,event:event.key,legalChoices:legal,gold:e.ExpGold[0],level:e.ProtoLevel[0],density:e.ProtoDensity[0]});
 }
}
const report={roots:fallbacks.length,branchCases:runs.length,runs,fallbacks,passed:true,mapCreated:false,validation:'생성된 실제 JASS 사건 함수의 변환 모의 실행. 신규12독립 사건의 머리 소지·초기 기록 불필요·AP1·지정 카드·비용·포션·필드·확률 경계·이미 소지한 카드100골드·빈 골드와 필드 상한을 대조했다. Warcraft 런타임·렌더링·실제 멀티플레이·밸런스·성능·재미 검증은 아니다. 공통 모의 환경의 체력 네이티브는 고정값이므로 이 검사로 체력 비율이나 전체 PlayerStatsSet을 검증하지 않는다.'};
fs.writeFileSync(path.join(__dirname,'head-expansion-probe-04.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({roots:report.roots,branchCases:report.branchCases,passed:true,mapCreated:false}));
