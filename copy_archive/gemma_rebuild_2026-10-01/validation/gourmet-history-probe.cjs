// 식사 사건의 비용·개인 후속·체력 비율과 필드 하한을 모의 실행으로 대조한다.
'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const {fresh}=require('../../../tools/check-expedition-ui.cjs');
function scene(e,key){const n=e.ProtoEventKey.indexOf(key);assert(n>0);return n;}
function card(e,key){const n=e.ProtoCardKey.indexOf(key);assert(n>=e.PROTO_CARD_FIRST);return n;}
function enter(e,key){const n=scene(e,key);e.ProtoOffer(0);e.ProtoCandidates[e.ExpKey(0,1)]=n;e.ProtoAction(0,2101);assert.equal(e.ProtoSelected[0],n);}
function party(){
 const {e}=fresh(0,true),states=new Map(e.MainUnit.map(u=>[u,{life:10000,max:10000}]));
 // 공통 UI 모의 환경은 체력 읽기를 10000으로 고정한다. 여기서는 쓰기와 최대 체력 변경을 추적한다.
 e.GetUnitState=(u,s)=>states.has(u)?states.get(u)[s===e.UNIT_STATE_LIFE?'life':'max']:10000;
 e.SetUnitState=(u,s,value)=>{if(states.has(u))states.get(u)[s===e.UNIT_STATE_LIFE?'life':'max']=value;};
 e.PlayerStatsSet=pid=>{states.get(e.MainUnit[pid]).max=10000*(1+e.ProtoStat(pid,e.PROTO_STAT_HEALTH)/100);};
 e.online=[true,true,false,false];e.ProtoCodexSlot[0]=e.ProtoCodexSlot[1]=1;e.ProtoAction(0,2001);e.ProtoAction(1,2001);
 const h=e.ProtoHeadKey.indexOf('gourmet');assert(h>0);e.ProtoGrantHead(0,h);e.ProtoGrantHead(1,h);e.ProtoRefreshStats(0);e.ExpGold[0]=600;
 e.SetUnitState(e.MainUnit[0],e.UNIT_STATE_LIFE,e.GetUnitState(e.MainUnit[0],e.UNIT_STATE_MAX_LIFE)*0.4);return e;
}
const runs=[];
for(let choice=1;choice<=4;choice++){
 const e=party(),density=e.ProtoDensity[0],root=scene(e,'pc_road_meal');enter(e,'pc_road_meal');e.ProtoResolve(0,choice);
 const cards=['pc_pecorine_meal','pc_kokkoro_care','pc_karyl_check'];
 for(const [i,key] of cards.entries())assert.equal(!!e.ExpCardOwned[e.ExpKey(0,card(e,key))],i+1===choice);
 assert.equal(e.ExpGold[0],[600,340,440,780][choice-1]);assert.equal(e.ProtoDensity[0],density+[2,0,-1,0][choice-1]);assert.equal(e.ProtoAP[0],9);
 assert.equal(e.ProtoEventHistory[e.ProtoStoryKey(0,root)],choice);
 assert.equal(e.ProtoEventEligible(0,scene(e,'pc_after_feast')),choice===1);assert.equal(e.ProtoEventEligible(0,scene(e,'pc_after_portions')),choice===2);
 for(const key of ['pc_after_feast','pc_after_portions'])assert(!e.ProtoEventEligible(1,scene(e,key)));
 assert.equal(e.GetUnitState(e.MainUnit[0],e.UNIT_STATE_LIFE)/e.GetUnitState(e.MainUnit[0],e.UNIT_STATE_MAX_LIFE),0.4);
 if(choice===1){e.ProtoResume(0);e.ProtoDensity[0]=1;enter(e,'pc_after_feast');e.ProtoResolve(0,2);assert.equal(e.ProtoDensity[0],1);assert.equal(e.ExpGold[0],420);assert.equal(e.ProtoAP[0],8);assert(e.ExpCardOwned[e.ExpKey(0,card(e,'pc_pecorine_meal'))]);assert(e.ExpCardOwned[e.ExpKey(0,card(e,'pc_karyl_resolve'))]);}
 if(choice===2){const charges=e.GetItemCharges(e.PlayerItem1[0]);e.ProtoResume(0);enter(e,'pc_after_portions');e.ProtoResolve(0,2);assert.equal(e.GetItemCharges(e.PlayerItem1[0]),charges+2);assert.equal(e.ExpGold[0],220);assert.equal(e.ProtoAP[0],8);assert.equal(e.GetUnitState(e.MainUnit[0],e.UNIT_STATE_LIFE)/e.GetUnitState(e.MainUnit[0],e.UNIT_STATE_MAX_LIFE),0.4);}
 assert.equal(e.ProtoAP[1],10);runs.push({firstChoice:choice,history:choice,goldAfterOptionalFollowup:e.ExpGold[0],actionPoints:e.ProtoAP[0],otherPlayerActionPoints:e.ProtoAP[1],healthRatio:0.4});
}
const e=party();e.ExpGold[0]=0;e.ProtoDensity[0]=10;enter(e,'pc_road_meal');for(const choice of [1,2,3])assert(!e.ProtoBranchAllowed(0,choice));assert(e.ProtoBranchAllowed(0,4));e.ProtoResolve(0,4);assert.equal(e.ExpGold[0],180);assert.equal(e.ProtoDensity[0],10);
const report={scope:'미식전 1~4번 선택의 자기 후속·비용·지정 카드·추가 행동력, 식사의 체력 비율 유지, 중간 필드 변경 뒤 하한과 비용 부족/상한의 유효 선택',runs,poorAndCappedFallback:{gold:180,density:10,choice:4},passed:true,mapCreated:false,validation:'실제 JASS 사건 함수를 변환한 모의 실행. Get/SetUnitState와 PlayerStatsSet의 최대 체력 변경은 통제한 모형이다. 전체 PlayerStatsSet·Warcraft·실제 멀티플레이·시각·재미·밸런스 검증 아님.',firstProbeFailure:'공통 UI 모의 환경의 GetUnitState는 항상10000이며 SetUnitState는 빈 함수여서 기대한0.4비율이1로 관측됐다. 이 파일에서만 쓰기를 추적하는 체력 모형을 제공했다. 실제 런타임 문제라고 판단하거나 런타임 소스를 우회 수정하지 않았다.'};
fs.writeFileSync(path.join(__dirname,'gourmet-history-probe.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify(report));
