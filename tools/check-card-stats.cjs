// 실제 전투·회복 JASS를 모의 실행하여 새 카드의 배율, 단위와 회복 수명 경계를 검증한다.
'use strict';
const assert=require('node:assert/strict');
const fs=require('node:fs'),path=require('node:path');
const {fresh}=require('./check-attack-potion.cjs');
const native=fs.readFileSync(path.join(__dirname,'../Data/Native.j'),'utf8');
const baseCritDamage=Number(native.match(/set Hero_CriDeal\[pid\] = ([\d.]+)/)[1]);
let checks=0;
const check=(name,fn)=>{fn();checks++;console.log('PASS '+name);};
const close=(a,b)=>assert(Math.abs(a-b)<1e-7,`${a} != ${b}`);
function setup(){
  const {e}=fresh(true);e.ProtoStatsInit();e.ProtoCatalogInit();e.ExpPrototypeActive=true;e.ExpMember[0]=true;e.ExpState=e.EXP_HUNT;e.localPlayer=4;
  let life=5000,maximum=10000,alive=true;
  e.GetUnitState=(u,state)=>u===0?(state===e.UNIT_STATE_MAX_LIFE?maximum:life):10000;
  e.SetUnitState=(u,state,value)=>{if(u===0){if(state===e.UNIT_STATE_MAX_LIFE)maximum=value;else if(state===e.UNIT_STATE_LIFE)life=value;}};
  e.GetUnitStatePercent=(u,state)=>100*e.GetUnitState(u,state)/e.GetUnitState(u,e.UNIT_STATE_MAX_LIFE);
  e.UnitAlive=u=>u!==0||alive;e.RefreshHP=()=>{};
  const effects=values=>{for(const [stat,value] of values)e.ProtoSetEffect(1023,stat,value,false);e.ProtoStatAddCard(0,1023,false);e.ProtoStatRefreshDerived(0);};
  const hit=(flags=[false,false,false,false])=>{e.UnitHP[2]=100000;e.UnitHPMAX[2]=100000;e.ExpEnemy[2]=true;e.ProtoHuntOwner[2]=1;e.HeroDeal(1,0,2,1,...flags);return 100000-e.UnitHP[2];};
  const advance=n=>{for(let i=0;i<n;i++)e.ProtoRecoveryTick();};
  return {e,effects,hit,advance,health:()=>life,setHealth:x=>{life=x;},setAlive:x=>{alive=x;},maximum:()=>maximum};
}
check('영구 무기 배율 뒤 런 공격력 배율, 추가·대미지·최종·대상 배율은 서로 곱함',()=>{
  const t=setup(),{e}=t;e.Equip_Damage[0]=100;e.Equip_DamageP[0]=20;
  t.effects([[e.PROTO_STAT_ATTACK,50],[e.PROTO_STAT_DAMAGE,30],[e.PROTO_STAT_FINAL,10],[e.PROTO_STAT_BOSS,25],[e.PROTO_STAT_NORMAL,15]]);
  assert.equal(e.AttackPower(0),180);e.Equip_ED[0]=20;e.Equip_WDP[0]=10;e.Equip_DP[0]=1.2;
  e.ExpEnemyBoss[2]=true;close(t.hit(),180*1.3*1.5*1.1*1.25);
  e.ExpEnemyBoss[2]=false;close(t.hit(),180*1.3*1.5*1.1*1.15);
  e.ExpEnemy[2]=false;assert.equal(e.ProtoTargetDamageRate(0,2),1);
  e.ExpMember[0]=false;assert.equal(e.ProtoStat(0,e.PROTO_STAT_ATTACK),0);assert.equal(e.AttackPower(0),120);
});
check('신규 치명 확률과 피해는 분리, 신속·행동속도와 상한은 다른 단위',()=>{
  const t=setup(),{e}=t;e.Hero_CriRate[0]=5;e.Hero_CriDeal[0]=baseCritDamage;
  t.effects([[e.PROTO_STAT_CRIT,95],[e.PROTO_STAT_CRIT_DAMAGE,50],[e.PROTO_STAT_SWIFT,450],[e.PROTO_STAT_ACTION,7]]);
  e.PlayerStatsSet(0);e.ItemUIStatsSet(0);assert.equal(e.Stats_Crit[0],100);assert.equal(e.Equip_Crit[0],0);assert.equal(e.Equip_Swiftness[0],450);
  close(t.hit(),120*2);assert.equal(e.SkillSpeed(0),17);e.Hero_BuffAttackSpeed[0]=100;assert.equal(e.SkillSpeed(0),40);
});
check('기본 치명타 추가 피해 50%와 장비·카드 합산이 실제 타격과 전투력 추정에 일치',()=>{
  const t=setup(),{e}=t;assert.equal(baseCritDamage,50);e.Hero_CriDeal[0]=baseCritDamage;e.Stats_Crit[0]=100;
  e.Equip_DP[0]=1;e.Equip_ED[0]=e.Equip_WDP[0]=0;e.CooldownRate=()=>1;
  close(t.hit(),180);close(e.Power(0),180);
  e.Stats_Crit[0]=0;close(t.hit(),120);close(e.Power(0),120);
  e.Stats_Crit[0]=100;e.Equip_CriDeal[0]=20;e.Arcana_CriDeal[0]=10;t.effects([[e.PROTO_STAT_CRIT_DAMAGE,4]]);
  close(t.hit(),220.8);close(e.Power(0),220.8);
  // 런 밖 전투력도 기본 100을 하드코딩하지 않고 같은 추가 피해를 사용한다.
  e.ExpMember[0]=false;e.GetItemCombatPower=()=>0;close(e.Power(0),216);
});
check('방관은 방어력에만 적용, 방향·비방향·차지·보호막·고체력은 조건 충족 때 합산',()=>{
  const t=setup(),{e}=t;t.effects([[e.PROTO_STAT_PENETRATION,50],[e.PROTO_STAT_MOVING,20],[e.PROTO_STAT_DIRECTION,12],[e.PROTO_STAT_NONDIRECTION,8],[e.PROTO_STAT_SHIELDED,10],[e.PROTO_STAT_CHARGE_DAMAGE,15],[e.PROTO_STAT_HEALTHY,9]]);
  e.UnitArm[2]=10000;close(t.hit(),120*(1-5000/15000)*1.08);
  e.GetUnitMoveSpeed=()=>480;e.UnitSD[0]=100;t.setHealth(6500);
  close(e.ExpArcanaDamage(0,0,2,true,false,true),10+12+10+15+9);
  e.HeadTrue=()=>false;close(e.ExpArcanaDamage(0,0,2,true,false,true),10+10+15+9);
  close(e.ExpArcanaDamage(0,0,2,false,false,false),10+8+10+9);
  e.GetUnitMoveSpeed=()=>600;t.setHealth(6499);e.UnitSD[0]=0;close(e.ExpArcanaDamage(0,0,2,false,false,false),20+8);
});
check('관통 주력의 전투력 추정은 실제 타격과 같은 60% 상한을 사용',()=>{
 const t=setup(),{e}=t;e.Equip_DP[0]=1;e.Equip_ED[0]=e.Equip_WDP[0]=0;e.Stats_Crit[0]=0;e.CooldownRate=()=>1;
 t.effects([[e.PROTO_STAT_PENETRATION,80]]);e.UnitArm[2]=10000;
 close(t.hit(),120*10000/14000);close(e.Power(0),120*20000/14000);
 e.Penetration[0]=.20;e.Equip_Penetration[0]=.20;close(t.hit(),120*10000/14000);close(e.Power(0),120*20000/14000);
});
check('흡수는 실제 피해의 비율을 저장하며 한 타격 10%, 초당 2%, 최대 5초',()=>{
  const t=setup(),{e}=t;t.effects([[e.PROTO_STAT_LEECH,100]]);e.ProtoLeechHit(0,0,100000);
  t.advance(49);close(t.health(),5980);t.advance(1);close(t.health(),6000);t.advance(30);close(t.health(),6000);
});
check('작은 흡수량 마지막 틱을 보존하고 초과 타격 피해는 흡수하지 않음',()=>{
  const t=setup(),{e}=t;t.effects([[e.PROTO_STAT_LEECH,10]]);e.ProtoLeechHit(0,0,15);t.advance(1);close(t.health(),5001.5);t.advance(2);close(t.health(),5001.5);
  e.UnitHP[2]=30;e.UnitHPMAX[2]=300;e.ExpEnemy[2]=true;e.ProtoHuntOwner[2]=1;e.HeroDeal(1,0,2,100,false,false,false,false);
  t.advance(1);close(t.health(),5004.5);assert.equal(e.ProtoDamage[0],30);
});
check('여러 타격과 재생의 합계는 10%/초, 한도 중에도 흡수 수명은 정상 종료',()=>{
  const t=setup(),{e}=t;t.setHealth(100);t.effects([[e.PROTO_STAT_LEECH,100],[e.PROTO_STAT_REGEN,6]]);
  for(let i=0;i<10;i++)e.ProtoLeechHit(0,0,100000);t.advance(50);close(t.health(),5100);t.advance(10);close(t.health(),5700);
});
check('사건 정지·준비 중 회복과 흡수 수명 정지, 사망·종료·최대 체력에서는 저장량 폐기',()=>{
  const t=setup(),{e}=t;t.effects([[e.PROTO_STAT_LEECH,100]]);e.ProtoLeechHit(0,0,1000);
  e.ProtoPaused[0]=true;t.advance(100);close(t.health(),5000);e.ProtoPaused[0]=false;e.ProtoReady[0]=true;t.advance(100);close(t.health(),5000);
  e.ProtoReady[0]=false;t.advance(1);close(t.health(),5020);t.setAlive(false);t.advance(1);t.setAlive(true);t.advance(50);close(t.health(),5020);
  e.ProtoLeechHit(0,0,1000);t.setHealth(10000);t.advance(1);t.setHealth(5000);t.advance(50);close(t.health(),5000);
  e.ProtoLeechHit(0,0,1000);e.ExpPrototypeActive=false;t.advance(1);e.ExpPrototypeActive=true;t.advance(50);close(t.health(),5000);
});
check('플레이어별 흡수 저장량 분리, 물약 직접 회복은 공유 회복 상한에 포함하지 않음',()=>{
  const t=setup(),{e}=t;t.effects([[e.PROTO_STAT_LEECH,100]]);e.ProtoLeechHit(1,0,1000);t.advance(1);close(t.health(),5000);
  t.setHealth(1000);e.ProtoLeechHit(0,0,1000);e.GetSpellAbilityId=()=> 'A01R';e.eventPlayer=0;e.Main();close(t.health(),7000);t.advance(1);close(t.health(),7020);
});
console.log(`${checks} card stat/recovery groups passed. Actual JASS functions with mock natives; Warcraft runtime and performance remain untested.`);
