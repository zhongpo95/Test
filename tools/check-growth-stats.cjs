// 신규 스탯의 누적·플레이어 분리·실제 계산 함수를 모의 실행해 검증한다.
'use strict';
const assert=require('node:assert/strict');
const {environment}=require('./check-expedition.cjs');
const {env:e}=environment(['Data/Data_Expedition.j','System/Cooldown.j','System/DamageEffect.j'],{
 Stat_CooldownHaste:[0,0,0,0],Stat_DashCooldown:[0,0,0,0],Stat_SkillDamage:Array(36).fill(0),Equip_GemCooldown:[0,0,0,0],
 GetOwningPlayer:u=>u, DataUnitIndex:()=>1,HeroSkillID0:[0,1001],HeroSkillID1:[0,1002],HeroSkillID2:[0,1003],HeroSkillID3:[0,1004],
 HeroSkillID4:[0,1005],HeroSkillID5:[0,1006],HeroSkillID6:[0,1007],HeroSkillID7:[0,1008]
},['CooldownHaste','CooldownReduction','CooldownRate','GemCooldownReduction','DashCooldownReduction','DashCoolTime','HeroSkillKey','SkillKeyDamageBonus']);
e.ExpPrototypeActive=true;e.ExpMember[0]=true;e.ExpMember[1]=true;e.ProtoStatsInit();
for(let pid=0;pid<4;pid++)for(let kind=1;kind<=e.PROTO_STAT_LAST;kind++)e.ProtoStatValues[pid*e.PROTO_STAT_STRIDE+kind]=pid*100+kind;
assert.equal(e.ProtoStat(1,e.PROTO_STAT_SKILL_A),132);
e.ProtoStatReset(0);assert.equal(e.ProtoStat(1,e.PROTO_STAT_SKILL_A),132);
e.ProtoStatValues[e.PROTO_STAT_COOLDOWN]=100;
assert.equal(e.CooldownHaste(0),100);assert.equal(e.CooldownReduction(0),50);assert.equal(e.CooldownRate(0),.5);
e.ProtoStatValues[e.PROTO_STAT_COOLDOWN]=1000;assert.equal(e.CooldownHaste(0),300);assert.equal(e.CooldownRate(0),.25);
e.ProtoStatValues[e.PROTO_STAT_DASH_COOLDOWN]=50;assert.equal(e.DashCoolTime(0,10),5);
e.ProtoStatValues[e.PROTO_STAT_DASH_COOLDOWN]=80;assert.equal(e.DashCooldownReduction(0),50);
e.ProtoStatValues[e.PROTO_STAT_SKILL_Q]=100;assert.equal(e.SkillKeyDamageBonus(0,1001),100);assert.equal(e.SkillKeyDamageBonus(0,1002),0);
e.ProtoStatValues[e.PROTO_STAT_SKILL_C]=60;assert.equal(e.SkillKeyDamageBonus(0,2),60);assert.equal(e.SkillKeyDamageBonus(0,77),0);
e.ProtoSetEffect(1,e.PROTO_STAT_SKILL_A,35,false);e.ProtoSetEffect(1,e.PROTO_STAT_ATTACK,7,true);
assert.equal(e.LoadReal(e.ProtoEffectData,1,e.PROTO_STAT_SKILL_A),35);assert.equal(e.LoadReal(e.ProtoEffectData,1,e.PROTO_STAT_ATTACK+e.PROTO_STAT_STRIDE),7);
assert.equal(e.ProtoEffectText(e.PROTO_STAT_COOLDOWN,100),'스킬가속 +100.0');
e.ExpMember[0]=false;assert.equal(e.SkillKeyDamageBonus(0,1001),0);assert.equal(e.CooldownRate(0),1);
console.log('PASS 신규 스탯 저장 분리·스킬가속·대시 상한·키별 효과·원정 밖 효과 차단');
console.log('검증 범위. 실제 JASS 함수 모의 실행. Warcraft 런타임 미검증.');

