// 실제 카드 지급과 피해 함수로 이동속도 비례·보호막 전제·일반 피해 손해를 대조한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const {fresh}=require('../../../tools/check-attack-potion.cjs'),{environment}=require('../../../tools/check-expedition.cjs');
const close=(a,b)=>assert(Math.abs(a-b)<1e-7,`${a} != ${b}`);
function grant(key){
 const {e}=fresh(true);e.ProtoStatsInit();e.ProtoCatalogInit();e.ExpPrototypeActive=true;e.ExpMember[0]=true;e.ExpState=e.EXP_HUNT;e.localPlayer=4;
 e.GetUnitStatePercent=()=>100;e.RefreshHP=()=>{};e.ExpEventGradeName=()=> '레어';e.RequestPlayerSave=()=>{};
 // 속도 네이티브를 바꿀 환경에 조건부 피해 함수도 다시 바인딩한다.
 const {env:p}=environment(['System/ExpeditionPrototype.j','System/ExpeditionEffects.j'],e,['ProtoRefreshStats','ProtoGrantCard','ProtoRememberCard','ProtoTargetDamageRate','ExpArcanaDamage','ExpCardPenetration']);
 const id=p.ProtoCardKey.indexOf(key);assert(id>=p.PROTO_CARD_FIRST);p.ProtoGrantCard(0,id);return p;
}
const lancer=grant('fy_lancer_second'),speedCases=[];
for(const [speed,expected]of [[350,0],[400,0],[480,6],[560,12],[600,12]]){lancer.GetUnitMoveSpeed=()=>speed;const damage=lancer.ExpArcanaDamage(0,0,2,false,false,false);close(damage,expected);speedCases.push({speed,damage});}
close(lancer.ExpCardPenetration(0),.04);
const shields=[];
for(const [key,expected,dr]of [['fy_saber_night',14,0],['fy_archer_brace',15,4]]){const p=grant(key);assert.equal(p.UnitSD[0],0);close(p.ExpArcanaDamage(0,0,2,false,false,false),0);p.UnitSD[0]=100;close(p.ExpArcanaDamage(0,0,2,false,false,false),expected);close(p.ProtoStat(0,p.PROTO_STAT_REDUCTION),dr);shields.push({card:key,grantCreatesShield:false,withoutShield:0,withShield:expected});}
const kirei=grant('fy_kirei_shelter');kirei.ExpEnemy[2]=true;kirei.ExpEnemyBoss[2]=false;close(kirei.ProtoTargetDamageRate(0,2),.96);kirei.ExpEnemyBoss[2]=true;close(kirei.ProtoTargetDamageRate(0,2),1);close(kirei.ProtoStat(0,kirei.PROTO_STAT_REDUCTION),7);
const report={passed:true,speedCases,penetration:.04,shields,kirei:{normalTargetRate:.96,bossTargetRate:1,damageReduction:7},limits:'실제 생성 카드 지급·스탯 재계산·피해 함수의 변환 모의 실행이다. 이동 판정·Warcraft·실제 화면·멀티플레이·재미·밸런스 검증은 아니다.',mapCreated:false};
fs.writeFileSync(path.join(__dirname,'card-condition-probe-66.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify(report));
