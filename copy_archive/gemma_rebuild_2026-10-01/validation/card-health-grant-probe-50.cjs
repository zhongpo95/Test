// 스탯 재계산만 한 검사와 실제 카드 지급의 체력 비율 보존을 구분한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const close=(a,b)=>assert(Math.abs(a-b)<1e-7,`${a} != ${b}`);
const {fresh}=require('../../../tools/check-attack-potion.cjs'),{environment}=require('../../../tools/check-expedition.cjs');
const {e}=fresh(true);e.ProtoStatsInit();e.ProtoCatalogInit();e.ExpPrototypeActive=true;e.ExpMember[0]=true;e.ExpState=e.EXP_HUNT;e.localPlayer=4;
let life=7000,maximum=10000;e.GetUnitState=(u,s)=>u===0?(s===e.UNIT_STATE_MAX_LIFE?maximum:life):10000;e.SetUnitState=(u,s,v)=>{if(u===0){if(s===e.UNIT_STATE_MAX_LIFE)maximum=v;else if(s===e.UNIT_STATE_LIFE)life=v;}};e.GetUnitStatePercent=(u,s)=>100*e.GetUnitState(u,s)/e.GetUnitState(u,e.UNIT_STATE_MAX_LIFE);e.RefreshHP=()=>{};
// 같은 데이터 배열·네이티브 모형을 공유하며 실제 원정의 지급/갱신 함수를 추가로 변환한다.
e.ExpEventGradeName=()=> '레어';e.RequestPlayerSave=()=>{};
const {env:p}=environment(['System/ExpeditionPrototype.j'],e,['ProtoRefreshStats','ProtoGrantCard','ProtoRememberCard']);
const id=p.ProtoCardKey.indexOf('gbf_io_smile');assert(id>=p.PROTO_CARD_FIRST);p.ProtoGrantCard(0,id);close(maximum,10800);close(life,7560);close(life/maximum,.7);
p.ProtoRefreshStats(0);close(maximum,10800);close(life,7560);assert.equal(p.ProtoStat(0,p.PROTO_STAT_HEALTHY),12);
const report={passed:true,card:'gbf_io_smile',path:'ProtoGrantCard → ProtoRefreshStats → ProtoRebuildCardStats → PlayerStatsSet → 비율로 현재 체력 설정',before:{maximum:10000,current:7000,ratio:.7},after:{maximum,current:life,ratio:life/maximum},repeatRefreshStable:true,correctionTo:'validation/card-contrast-probe-47.json',meaning:'검사47의 7000 유지와 65% 조건 미달은 PlayerStatsSet 단독 호출에서만 관찰했다. 실제 카드 지급은 기존 70%를 유지하여 7560/10800이므로 그 사례의 조건 미달은 발생하지 않는다. 물약처럼 체력 비율 자체를 회복한 것은 아니다.',limits:'실제 JASS 함수의 변환 모의 실행이며 Warcraft·체력바 렌더링·물약 실기·멀티플레이 미검증.',mapCreated:false};
fs.writeFileSync(path.join(__dirname,'card-health-grant-probe-50.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify(report));
