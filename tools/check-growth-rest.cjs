// 실제 JASS를 모의 실행하여 고정 행동력과 폐지된 휴식 요청의 무효 처리를 검증한다.
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
for(const balance of [100,3,2,0]){
 e.ProtoAP[0]=balance;e.ProtoAction(0,2300);
 assert.equal(e.ProtoAP[0],balance);assert.equal(e.ExpGold[0],317);
}
assert.equal(offers,0,'폐지한 재추첨은 후보를 변경하지 않는다');
e.ProtoAP[0]=41;e.ProtoAPMax[0]=100;e.ProtoStatValues[e.PROTO_STAT_CAPACITY]=20;
e.ProtoStatRefreshDerived(0);assert.equal(e.ProtoAPMax[0],100);assert.equal(e.ProtoAP[0],41);
e.ProtoStatRefreshDerived(0);assert.equal(e.ProtoAP[0],41,'능력치 갱신은 행동력을 충전하지 않음');
assert.equal(e.ProtoRestCost(1),1,'플레이어별 휴식 비용 분리');
console.log('PASS 고정 행동력·머리 한도·구 휴식 요청 무효·잔액 경계·골드 보존·플레이어 분리');
console.log('검증 범위. 실제 JASS 모의 실행. Warcraft 런타임 미검증.');
