// 나비저택 카드 지급 뒤 차지와 실제 헤드·백 각도 및 고체력 경계를 대조한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const {fresh}=require('../../../tools/check-attack-potion.cjs'),{environment}=require('../../../tools/check-expedition.cjs');
const close=(a,b)=>assert(Math.abs(a-b)<1e-7,`${a} != ${b}`);
function grant(key){
 const {e}=fresh(true);e.ProtoStatsInit();e.ProtoCatalogInit();e.ExpPrototypeActive=true;e.ExpMember[0]=true;e.ExpState=e.EXP_HUNT;e.localPlayer=4;
 let life=7000,maximum=10000,angle=0;e.GetUnitState=(u,s)=>u===0?(s===e.UNIT_STATE_MAX_LIFE?maximum:life):10000;e.SetUnitState=(u,s,v)=>{if(u===0){if(s===e.UNIT_STATE_MAX_LIFE)maximum=v;else if(s===e.UNIT_STATE_LIFE)life=v;}};e.GetUnitStatePercent=(u,s)=>100*e.GetUnitState(u,s)/e.GetUnitState(u,e.UNIT_STATE_MAX_LIFE);e.RefreshHP=()=>{};e.ExpEventGradeName=()=> '레어';e.RequestPlayerSave=()=>{};e.AngleWBW=()=>angle;e.RAbsBJ=Math.abs;
 const {env:p}=environment(['Library/AttackAngle.j','System/ExpeditionPrototype.j','System/ExpeditionEffects.j'],e,['AngleTrue','HeadTrue','BackTrue','ProtoRefreshStats','ProtoGrantCard','ProtoRememberCard','ExpArcanaDamage']);
 const id=p.ProtoCardKey.indexOf(key);assert(id>=p.PROTO_CARD_FIRST);p.ProtoGrantCard(0,id);return {p,setAngle:a=>angle=a,setHealthRatio:r=>life=maximum*r,health:()=>({life,maximum,ratio:life/maximum})};
}
const g=grant('kny_gourd_breath');close(g.p.ProtoStat(0,g.p.PROTO_STAT_ACTION),3);close(g.p.ProtoStat(0,g.p.PROTO_STAT_CHARGE_SPEED),0);close(g.p.ExpArcanaDamage(0,0,2,false,false,true),14);close(g.p.ExpArcanaDamage(0,0,2,false,false,false),0);
const d=grant('kny_kanao_return_hand'),angles=[];for(const [angle,head,back,expected]of [[180,true,false,10],[135,true,false,10],[225,true,false,10],[134,true,false,0],[226,true,false,0],[90,true,false,0],[0,false,true,10],[45,false,true,10],[46,false,true,0],[180,false,false,0]]){d.setAngle(angle);close(d.p.ExpArcanaDamage(0,0,2,head,back,false),expected);angles.push({angle,head,back,expected});}close(d.p.ProtoStat(0,d.p.PROTO_STAT_ACTION),6);
const n=grant('kny_inosuke_partition');close(n.p.ProtoStat(0,n.p.PROTO_STAT_PENETRATION),8);close(n.p.ExpArcanaDamage(0,0,2,false,false,false),12);close(n.p.ExpArcanaDamage(0,0,2,true,false,false),0);close(n.p.ExpArcanaDamage(0,0,2,false,true,false),0);
const h=grant('kny_morning_breath'),health=[];close(h.p.ProtoStat(0,h.p.PROTO_STAT_REGEN),.4);for(const [ratio,expected]of [[.6499,0],[.65,10],[.7,10]]){h.setHealthRatio(ratio);close(h.p.ExpArcanaDamage(0,0,2,false,false,false),expected);health.push({ratio,expected});}h.p.ProtoRefreshStats(0);close(h.health().ratio,.7);
const s=grant('kny_gourd_second');close(s.p.ProtoStat(0,s.p.PROTO_STAT_CHARGE_SPEED),9);close(s.p.ProtoStat(0,s.p.PROTO_STAT_ACTION),0);close(s.p.ExpArcanaDamage(0,0,2,false,false,true),10);close(s.p.ExpArcanaDamage(0,0,2,false,false,false),0);
const report={passed:true,gourd:{chargeDamage:14,actionSpeed:3,chargeSpeed:0},direction:{angles,actionSpeed:6,flagAloneInsufficient:true},partition:{penetration:8,noFlags:12,eitherFlag:0},morning:{regeneration:.4,health,ratioRefreshStable:true},second:{chargeSpeed:9,chargeDamage:10,actionSpeed:0},mapCreated:false,limits:'실제 카드 지급·스탯 재계산·ExpArcanaDamage와AttackAngle 변환 함수를 실행했다. 좌표 대신AngleWBW의 각도/대상방향0 네이티브를 모의한다. Warcraft·실제화면·멀티·실시간재생·차지시전·재미·밸런스 검증은 아니다.'};
fs.writeFileSync(path.join(__dirname,'card-condition-probe-75.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({passed:true,directionCases:angles.length,healthyBoundaryCases:health.length,mapCreated:false}));
