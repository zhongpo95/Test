// 모델의 선택 번호 지적을 실제 사건 처리 모의 실행으로 대조하고 검증 한계를 보존한다.
'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const {fresh}=require('../../../tools/check-expedition-ui.cjs');
const runs=[];
function scene(e,key){const n=e.ProtoEventKey.indexOf(key);assert(n>0);return n;}
function card(e,key){const n=e.ProtoCardKey.indexOf(key);assert(n>=e.PROTO_CARD_FIRST);return n;}
function enter(e,key){const n=scene(e,key);e.ProtoOffer(0);e.ProtoCandidates[e.ExpKey(0,1)]=n;e.ProtoAction(0,2101);assert.equal(e.ProtoSelected[0],n);}
for(const roll of [70,71]){
 const {e}=fresh(0,true);e.online=[true,true,false,false];e.ProtoCodexSlot[0]=e.ProtoCodexSlot[1]=1;e.ProtoAction(0,2001);e.ProtoAction(1,2001);assert.equal(e.ExpState,e.EXP_HUNT);
 const head=e.ProtoHeadKey.indexOf('butterfly');e.ProtoGrantHead(0,head);e.ProtoGrantHead(1,head);e.ExpGold[0]=1000;
 const root=scene(e,'kny_night_path'),found=scene(e,'kny_night_found'),wrong=scene(e,'kny_night_wrong');
 enter(e,'kny_night_path');e.GetRandomInt=()=>roll;e.ProtoResolve(0,1);
 const success=roll===70;
 assert.equal(e.ProtoEventHistory[e.ProtoStoryKey(0,root)],success?1:-1);
 assert.equal(e.ProtoEventEligible(0,found),success);assert.equal(e.ProtoEventEligible(0,wrong),!success);
 assert(!e.ProtoEventEligible(1,found));assert(!e.ProtoEventEligible(1,wrong));
 assert.equal(e.ExpGold[0],success?1040:840);assert.equal(e.ProtoLevel[0],2);assert.equal(e.ProtoAP[0],9);
 assert.equal(!!e.ExpCardOwned[e.ExpKey(0,card(e,'kny_zenitsu'))],success);
 e.ProtoResume(0);enter(e,success?'kny_night_found':'kny_night_wrong');e.ProtoResolve(0,1);
 assert.equal(e.ProtoAP[0],8);assert.equal(e.ProtoAP[1],10);assert.equal(e.ExpGold[0],success?800:680);
 assert(e.ExpCardOwned[e.ExpKey(0,card(e,success?'kny_kanao':'kny_shinobu'))]);
 assert.equal(!!e.ExpCardOwned[e.ExpKey(0,card(e,'kny_zenitsu'))],success);
 runs.push({roll,history:success?1:-1,followup:success?'kny_night_found':'kny_night_wrong',gold:e.ExpGold[0],actionPoints:e.ProtoAP[0],previousCardRetained:success?true:null});
}
const report={scope:'선택 1의 성공·실패 후속, 개인 기록, 추가 행동력과 기존 카드 유지',runs,passed:true,mapCreated:false,validation:'JASS 변환 모의 실행. Warcraft 런타임·화면·멀티플레이 미검증.'};
fs.writeFileSync(path.join(__dirname,'butterfly-history-probe.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify(report));
