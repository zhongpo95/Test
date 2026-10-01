// 흥신소 카드의 대상별 손익과 비방향 전제 및 실제 지급의 체력 비율을 대조한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const {fresh}=require('../../../tools/check-attack-potion.cjs'),{environment}=require('../../../tools/check-expedition.cjs');
const close=(a,b)=>assert(Math.abs(a-b)<1e-7,`${a} != ${b}`);
function grant(key){
 const {e}=fresh(true);e.ProtoStatsInit();e.ProtoCatalogInit();e.ExpPrototypeActive=true;e.ExpMember[0]=true;e.ExpState=e.EXP_HUNT;e.localPlayer=4;
 let life=7000,maximum=10000;e.GetUnitState=(u,s)=>u===0?(s===e.UNIT_STATE_MAX_LIFE?maximum:life):10000;e.SetUnitState=(u,s,v)=>{if(u===0){if(s===e.UNIT_STATE_MAX_LIFE)maximum=v;else if(s===e.UNIT_STATE_LIFE)life=v;}};e.GetUnitStatePercent=(u,s)=>100*e.GetUnitState(u,s)/e.GetUnitState(u,e.UNIT_STATE_MAX_LIFE);e.RefreshHP=()=>{};e.ExpEventGradeName=()=> '레어';e.RequestPlayerSave=()=>{};
 const {env:p}=environment(['System/ExpeditionPrototype.j','System/ExpeditionEffects.j'],e,['ProtoRefreshStats','ProtoGrantCard','ProtoRememberCard','ProtoTargetDamageRate','ExpArcanaDamage']);
 const id=p.ProtoCardKey.indexOf(key);assert(id>=p.PROTO_CARD_FIRST);p.ProtoGrantCard(0,id);return {p,health:()=>({life,maximum,ratio:life/maximum})};
}
const {p:aru}=grant('ab68_aru_bill');aru.ExpEnemy[2]=true;aru.ExpEnemyBoss[2]=true;close(aru.ProtoTargetDamageRate(0,2),1.18);aru.ExpEnemyBoss[2]=false;close(aru.ProtoTargetDamageRate(0,2),.94);assert.equal(aru.ProtoStat(1,aru.PROTO_STAT_BOSS),0);
const {p:mutsuki}=grant('ab68_mutsuki_envelope');close(mutsuki.ProtoStat(0,mutsuki.PROTO_STAT_CRIT_DAMAGE),20);close(mutsuki.ProtoStat(0,mutsuki.PROTO_STAT_CRIT),0);close(mutsuki.ExpArcanaDamage(0,0,2,false,false,false),10);close(mutsuki.ExpArcanaDamage(0,0,2,true,false,false),0);close(mutsuki.ExpArcanaDamage(0,0,2,false,true,false),0);
const haruka=grant('ab68_haruka_pot');close(haruka.health().maximum,10800);close(haruka.health().life,7560);close(haruka.health().ratio,.7);close(haruka.p.ProtoStat(0,haruka.p.PROTO_STAT_REGEN),.5);haruka.p.ProtoRefreshStats(0);close(haruka.health().life,7560);
const report={passed:true,aru:{bossRate:1.18,normalRate:.94,otherPlayerUnchanged:true},mutsuki:{critDamage:20,critChance:0,withoutHeadBackFlags:10,withEitherFlag:0},haruka:{...haruka.health(),regeneration:.5,repeatRefreshStable:true},limits:'실제 카드 지급·스탯 재계산·조건부 피해 함수의 변환 모의 실행이다. Warcraft·실제 화면·멀티플레이·재미·밸런스·실시간 재생 검증은 아니다.',mapCreated:false};
fs.writeFileSync(path.join(__dirname,'card-condition-probe-71.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify(report));
