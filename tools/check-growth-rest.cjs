// 실제 JASS를 모의 실행하여 고정 행동력과 휴식 비용의 소비 경계를 검증한다.
'use strict';
const assert=require('node:assert/strict');
const {environment}=require('./check-expedition.cjs');
const {env:e}=environment(['Data/Data_Expedition.j','System/ExpeditionPrototype.j'],{},['ProtoAction','ProtoRestCost','ProtoHeadCapacity','ProtoResume']);
let offers=0;
e.ProtoOffer=()=>offers++;
e.ProtoResetDialogue=()=>{};
e.ProtoSetPause=()=>{};
e.ExpState=e.EXP_HUNT;e.ExpPrototypeActive=true;e.ExpMember[0]=true;e.ProtoStage[0]=1;
e.ProtoAP[0]=e.PROTO_BASE_AP;e.ExpGold[0]=317;
assert.equal(e.ProtoAP[0],100);
assert.equal(e.ProtoHeadCapacity(0),1);
e.ProtoCompletedHeadCount[0]=1;assert.equal(e.ProtoHeadCapacity(0),2);
for(const cost of [1,2,3,3]){
 assert.equal(e.ProtoRestCost(0),cost);
 const before=e.ProtoAP[0];e.ProtoAction(0,2300);
 assert.equal(e.ProtoAP[0],before-cost);assert.equal(e.ExpGold[0],317);
}
assert.equal(offers,4);
e.ProtoResume(0);assert.equal(e.ProtoRestCost(0),3,'사건 종료가 휴식 누적을 초기화하면 안 됨');
e.ProtoStage[0]=1;e.ProtoAP[0]=2;e.ProtoAction(0,2300);
assert.equal(e.ProtoAP[0],2);assert.equal(offers,4,'부족한 행동력으로 후보를 갱신하면 안 됨');
e.ProtoAP[0]=3;e.ProtoAction(0,2300);assert.equal(e.ProtoAP[0],0);assert.equal(offers,5);
e.ProtoAP[0]=41;e.ProtoAPMax[0]=100;e.ProtoStatValues[e.PROTO_STAT_CAPACITY]=20;
e.ProtoStatRefreshDerived(0);assert.equal(e.ProtoAPMax[0],100);assert.equal(e.ProtoAP[0],41);
e.ProtoStatRefreshDerived(0);assert.equal(e.ProtoAP[0],41,'능력치 갱신은 행동력을 충전하지 않음');
assert.equal(e.ProtoRestCost(1),1,'플레이어별 휴식 비용 분리');
console.log('PASS 고정 행동력·머리 한도·휴식 1/2/3 상한·잔액 경계·골드 보존·플레이어 분리');
console.log('검증 범위. 실제 JASS 모의 실행. Warcraft 런타임 미검증.');
