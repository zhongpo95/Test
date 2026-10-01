// 새 카드의 생존·차지 준비·사냥 수입을 실제 JASS 함수의 모의 실행으로 대조한다.
'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const {fresh}=require('../../../tools/check-attack-potion.cjs'),{fresh:uiFresh}=require('../../../tools/check-expedition-ui.cjs');
const close=(a,b)=>assert(Math.abs(a-b)<1e-7,`${a} != ${b}`);
function setup(key){
 const {e}=fresh(true);e.ProtoStatsInit();e.ProtoCatalogInit();e.ExpPrototypeActive=true;e.ExpMember[0]=true;e.ExpState=e.EXP_HUNT;
 let life=7000,maximum=10000;e.GetUnitState=(u,s)=>u===0?(s===e.UNIT_STATE_MAX_LIFE?maximum:life):10000;
 e.SetUnitState=(u,s,v)=>{if(u===0){if(s===e.UNIT_STATE_MAX_LIFE)maximum=v;else if(s===e.UNIT_STATE_LIFE)life=v;}};
 e.GetUnitStatePercent=(u,s)=>100*e.GetUnitState(u,s)/e.GetUnitState(u,e.UNIT_STATE_MAX_LIFE);e.RefreshHP=()=>{};
 const id=e.ProtoCardKey.indexOf(key);assert(id>=e.PROTO_CARD_FIRST);e.ExpCardOwned[e.ExpKey(0,id)]=true;e.ProtoRebuildCardStats(0,e.PROTO_CARD_FIRST,e.PROTO_CARD_LAST,0);e.PlayerStatsSet(0);
 return {e,id,life:()=>life,maximum:()=>maximum};
}
const io=setup('gbf_io_smile');close(io.maximum(),10800);close(io.life(),7000);close(io.e.Arcana_ChargeSpeed[0],1);assert.equal(io.e.ProtoStat(0,io.e.PROTO_STAT_HEALTHY),12);
// 생존 여유의 대가는 같은 현재 체력에서 고체력 조건이 더 엄격해지는 것이다.
assert(7000/10000>=.65);assert(io.life()/io.maximum()<.65);
const original=setup('hsr_sparkle'),cut=setup('hsr_sparkle_cut');close(original.e.SkillSpeed(0),8);close(original.e.Arcana_ChargeSpeed[0],1);close(cut.e.SkillSpeed(0),0);close(cut.e.Arcana_ChargeSpeed[0],1.12);
const ordinary=e=>(100+e.SkillSpeed(0))/100,charged=e=>ordinary(e)*e.Arcana_ChargeSpeed[0];close(ordinary(original.e),1.08);close(ordinary(cut.e),1);close(charged(original.e),1.08);close(charged(cut.e),1.12);assert.equal(original.e.ProtoStat(0,original.e.PROTO_STAT_CRIT_DAMAGE),15);assert.equal(cut.e.ProtoStat(0,cut.e.PROTO_STAT_CRIT_DAMAGE),14);
const {e}=uiFresh(0,true);e.online=[true,true,false,false];e.ProtoCodexSlot[0]=e.ProtoCodexSlot[1]=1;e.ProtoAction(0,2001);e.ProtoAction(1,2001);
const sheska=e.ProtoCardKey.indexOf('fma_sheska');e.ProtoGrantCard(0,sheska);assert.equal(e.ProtoChoices[0],3);assert.equal(e.ProtoChoices[1],2);
const gold=e.ExpGold[0],other=e.ExpGold[1];e.ProtoKill(0);assert.equal(e.ExpGold[0],gold+11);assert.equal(e.ExpGold[1],other);e.ProtoKill(1);assert.equal(e.ExpGold[1],other+10);
e.ProtoSetEffect(900,e.PROTO_STAT_CHOICES,3,false);e.ExpCardOwned[e.ExpKey(0,900)]=true;e.ProtoRebuildCardStats(0,e.PROTO_CARD_FIRST,900,0);assert.equal(e.ProtoChoices[0],4);
const report={passed:true,cards:3,io:{maximum:io.maximum(),current:io.life(),healthyThresholdTradeoff:true},sparkle:{ordinaryOriginal:ordinary(original.e),ordinaryCut:ordinary(cut.e),chargedOriginal:charged(original.e),chargedCut:charged(cut.e)},sheska:{ownKillGold:11,otherKillGold:10,ownCandidates:3,candidateCap:4},mapCreated:false,limits:['실제 PlayerStatsSet·SkillSpeed·카드 합산·사건 카드 지급·ProtoKill 함수의 변환 모의 실행이다. 첸R/나루메아F의 준비 배율 식과 대조했으며 실제 스킬 시전과 프레임은 실행하지 않았다.','최대 체력 증가는 현재 체력 회복이 아니다. 현재 체력이 같은 경우 65% 조건에 미달할 수 있음을 확인했다.','Warcraft·화면·실제 멀티플레이·재미·밸런스 미검증.']};
fs.writeFileSync(path.join(__dirname,'card-contrast-probe-47.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify(report));
