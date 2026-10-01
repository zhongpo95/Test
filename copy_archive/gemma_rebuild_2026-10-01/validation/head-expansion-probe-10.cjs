// 아인크라드 신규·개선 사건의 지정 보상과 개인 후속·확률 경계를 모의 실행한다.
'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const {fresh}=require('../../../tools/check-expedition-ui.cjs');
const root=path.resolve(__dirname,'..');
const fixed=JSON.parse(fs.readFileSync(path.join(root,'requests/aincrad-expansion-fixed-52.json'),'utf8'));
const data=JSON.parse(fs.readFileSync(path.join(root,'revisions/aincrad-expansion-curated-54.json'),'utf8'));
const checked=[...fixed.events,...fixed.rewrites].map(p=>data.events.find(e=>e.key===p.key));
function party(){const {e}=fresh(0,true);e.online=[true,true,false,false];e.ProtoCodexSlot[0]=e.ProtoCodexSlot[1]=1;e.ProtoAction(0,2001);e.ProtoAction(1,2001);e.ProtoGrantHead(0,e.ProtoHeadKey.indexOf('aincrad'));e.ExpGold[0]=1000;return e;}
function scene(e,key){const n=e.ProtoEventKey.indexOf(key);assert(n>0);return n;}
function card(e,key){const n=e.ProtoCardKey.indexOf(key);assert(n>=e.PROTO_CARD_FIRST);return n;}
function enter(e,key){const n=scene(e,key);assert(e.ProtoEventEligible(0,n));e.ProtoOffer(0);e.ProtoCandidates[e.ExpKey(0,1)]=n;e.ProtoAction(0,2101);assert.equal(e.ProtoSelected[0],n);}
function parent(e,event){if(!event.previous)return;enter(e,event.previous);e.GetRandomInt=()=>1;e.ProtoResolve(0,event.previousChoice);e.ProtoResume(0);assert(e.ProtoEventEligible(0,scene(e,event.key)));}
const runs=[],fallbacks=[],historyGates=[];
for(const event of checked){
 const probe=party(),id=scene(probe,event.key);assert.equal(probe.ProtoEventEligible(0,id),!event.previous);assert(!probe.ProtoEventEligible(1,id));
 if(event.previous){
  probe.ProtoGrantHead(1,probe.ProtoHeadKey.indexOf('aincrad'));assert(!probe.ProtoEventEligible(1,id));
  const prior=scene(probe,event.previous),history=probe.ProtoStoryKey(0,prior);
  for(const choice of [-event.previousChoice,0,2,3]){probe.ProtoEventHistory[history]=choice;assert(!probe.ProtoEventEligible(0,id));}
  probe.ProtoEventHistory[history]=event.previousChoice;assert(probe.ProtoEventEligible(0,id));assert(!probe.ProtoEventEligible(1,id));
  historyGates.push({event:event.key,previous:event.previous,allowedChoice:event.previousChoice,wrongOrFailedHistoryExcluded:true,otherPlayerExcluded:true});
 }
 for(const [i,b]of event.choices.entries())for(const roll of b.chance<100?[b.chance,b.chance+1]:[1])for(const duplicate of b.card?[false,true]:[false]){
  const e=party();parent(e,event);e.ExpGold[0]=1000;if(duplicate)e.ProtoGrantCard(0,card(e,b.card));
  enter(e,event.key);const potions=e.GetItemCharges(e.PlayerItem1[0]),level=e.ProtoLevel[0],density=e.ProtoDensity[0];e.GetRandomInt=()=>roll;e.ProtoResolve(0,i+1);
  const success=roll<=b.chance;
  assert.equal(e.ExpGold[0],1000-b.cost+(success?b.gold+(duplicate?100:0):0));
  assert.equal(e.ProtoLevel[0],Math.max(1,level+b.level));assert.equal(e.ProtoDensity[0],Math.max(1,density+b.density));
  assert.equal(e.ProtoAP[0],event.previous?8:9);assert.equal(e.ProtoAP[1],10);
  assert.equal(e.GetItemCharges(e.PlayerItem1[0]),potions+(success?b.potions:0));
  if(b.card)assert.equal(!!e.ExpCardOwned[e.ExpKey(0,card(e,b.card))],success||duplicate);
  assert.equal(e.ProtoEventHistory[e.ProtoStoryKey(0,scene(e,event.key))],success?i+1:-i-1);
  assert(!e.ProtoEventEligible(0,scene(e,event.key)));assert(!e.ProtoEventEligible(1,scene(e,event.key)));
  if(event.key==='sao_argo_fork'){assert.equal(e.ProtoEventEligible(0,scene(e,'sao_argo_second_question')),i===0&&success);assert(!e.ProtoEventEligible(1,scene(e,'sao_argo_second_question')));}
  runs.push({event:event.key,choice:i+1,roll,success,duplicate,gold:e.ExpGold[0],level:e.ProtoLevel[0],density:e.ProtoDensity[0],actionPoints:e.ProtoAP[0]});
 }
 const e=party();parent(e,event);e.ExpGold[0]=0;e.ProtoLevel[0]=5;e.ProtoDensity[0]=10;
 const legal=event.choices.map((b,i)=>e.ProtoBranchAvailable(0,scene(e,event.key),i+1)?i+1:0).filter(Boolean);assert(legal.length>0,event.key+' 상한 상태에서 유효 선택 없음');
 enter(e,event.key);e.ProtoResolve(0,legal[0]);assert.equal(e.ProtoAP[0],event.previous?8:9);assert(e.ExpGold[0]>=0);
 fallbacks.push({event:event.key,legalChoices:legal,gold:e.ExpGold[0],level:e.ProtoLevel[0],density:e.ProtoDensity[0]});
}
assert.equal(fixed.events.filter(e=>!e.previous).length,4);assert.equal(historyGates.length,2);assert.equal(runs.length,60);
const report={newRoots:4,newFollowups:1,rewrittenEvents:5,branchCases:runs.length,runs,fallbacks,historyGates,passed:true,mapCreated:false,validation:'실제 생성 JASS 사건 함수의 변환 모의 실행이다. 두 후속의 자기 성공1번·65/66과70/71 판정·다른 플레이어 기록 분리·AP1회·지정 카드·중복100골드·비용·보수·물약·지속 개인 필드·골드0/상한 선택을 대조했다. 고정 체력 네이티브 모형이며 Warcraft·렌더링·실제 멀티플레이·재미·밸런스 검증은 아니다.'};
fs.writeFileSync(path.join(__dirname,'head-expansion-probe-10.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({newRoots:4,newFollowups:1,rewrittenEvents:5,branchCases:runs.length,passed:true,mapCreated:false}));
