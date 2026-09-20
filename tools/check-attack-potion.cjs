// 실제 공격력·피해 함수와 물약 타이머를 모의 실행하여 카드와 물약의 중첩 및 종료를 검증한다.
const assert = require('node:assert/strict');
const {environment} = require('./check-expedition.cjs');
let checks = 0;
const check = (name, fn) => {fn();checks++;console.log('PASS ' + name);};
function fresh() {
  const no = () => {}, arcana = new Map(), timers = [], labels = new Map();
  let e, expired, now = 0;
  const {env} = environment(['Data/Native.j','Data/Data_Expedition.j','Data/Data_ExpeditionEvents.j','Data/Data_ExpeditionRewards.j','System/StatsSetting.j',
    'System/ExpeditionEffects.j','System/Expedition.j','System/DamageEffect.j','Hero/Potion.j','System/ItemPickUp.j'], {
    InitHashtable: () => arcana,
    SaveInteger: (table,a,b,n) => arcana.set(a+':'+b,n), LoadInteger: (table,a,b) => arcana.get(a+':'+b) || 0,
    DzFrameSetText: (id,text) => labels.set(id,text), DzFrameSetTexture: no, DzFrameShow: no,
    F_ArcanaBD: [], F_UIArcana1: [], F_UIArcana2: [], F_UIArcana3: [], F_UIArcana4: [], F_ArcanaStatsText: [], F_ArcanaCheck: [],
    ItemStats: [[],[null,null,'100']], ItemWeaponQuality: [0],
    ITEM_TYPE_WEAPON: 1, ITEM_TYPE_ELIXIR: 0, ITEM_TYPE_NECKLACE: 2, ITEM_TYPE_EARRING: 3,
    ITEM_TYPE_RING: 4, ITEM_TYPE_BRACELET: 5, ITEM_TYPE_CARD: 6, ITEM_TYPE_GEM: 7,
    GetItemTypes: s => s.includes('ID41') ? 0 : 1, GetItemTier: () => 2, GetItemUp: () => 0, GetItemQuality: () => 0,
    GetItemElixirLevel1: () => 8, GetItemElixirLevel2: () => 12,
    GetOwningPlayer: u => u, GetUnitIndex: u => u, GetUnitAbilityLevel: () => 0,
    GetUnitStatePercent: () => 100, GetRandomReal: () => 100,
    DeBuffMArm: {Exists:()=>false}, DeBuffMBackHead: {Exists:()=>false}, DeBuffCri: {Exists:()=>false},
    USDT: [], OverlayPlayerID: [], OverlayPlayerValue: [], PlayerOverlayStop: [true,true],
    SetTextTagVelocityBJ: no, SetTextTagFadepoint: no, SetTextTagLifespan: no, PlayerBossAttack: no,
    FormatDamageText: n => String(n),
    GetSpellAbilityId: () => 'A01U', GetTriggerUnit: () => e.eventPlayer,
    tick: {create: () => ({start(seconds,periodic,fn) {assert.equal(periodic,false);this.end=now+seconds;this.fn=fn;timers.push(this);},destroy() {this.destroyed=true;}}),getExpired:()=>expired},
    FxEffect: {create:()=>({stop(){this.stopped=true;}})},
    JNSetItemName: (item,text) => {item.name=text;}, JNSetItemTooltip: (item,text) => {item.tip=text;},
    JNSetItemExtendedTooltip: (item,text) => {item.description=text;},
  }, ['AttackPower','FinalDamageBonus','PlayerStatsSet','ExpKey','ExpHasCard','ExpCardDamage','ExpArcanaDamage',
    'HeroDeal','Main','EffectFunction','DamagePotionText','DrawCard','GrantCard','RefreshStats','Finish',
    'ExpCardName','ExpCardText','ExpGradeGold','ReleaseEvent','ApplyEvent','ExpEventUnavailable','CardsLeft',
    'PrepareEvent','OwnedEventCard','OwnedEventPenalty','SelectCard','ReleaseReward']);
  e=env;
  e.Eitem[0][0]='ID3;';e.Eitem[0][1]='ID41;';
  e.Eitem[1][0]='ID3;';e.Eitem[1][1]='ID41;';
  e.MainUnit=[0,1,2,3];
  e.PlayerStatsSet(0);e.PlayerStatsSet(1);
  const use = pid => {e.eventPlayer=pid;e.Main();};
  const advance = seconds => {
    now+=seconds;
    for(const t of timers.filter(t=>!t.destroyed&&t.end<=now)){expired=t;t.fn();assert(t.destroyed);assert(t.data.stopped);}
  };
  const damage = pid => {
    e.UnitHP[2]=10000;e.UnitHPMAX[2]=10000;
    e.HeroDeal(1,pid,2,1,false,false,false,false);
    return 10000-e.UnitHP[2];
  };
  return {e,use,advance,damage,labels};
}
check('일반 카드로 조로 획득, 공격력 증가 재계산 및 피해량 중복 적용 방지',()=>{
  const {e,damage}=fresh();e.ExpMember[0]=true;e.ExpState=e.EXP_BATTLE;
  assert.equal(e.AttackPower(0),120);assert.equal(damage(0),120);
  for(let id=2;id<=6;id++)e.ExpCardSeen[id]=true;
  assert.equal(e.DrawCard(0,1),1);e.GrantCard(0,1,1);e.RefreshStats(0);
  assert.equal(e.Equip_DamageP[0],20);assert.equal(e.AttackPower(0),144);assert.equal(damage(0),144);
  assert.equal(e.ExpCardDamage(0,0,2),0);
  e.RefreshStats(0);assert.equal(e.AttackPower(0),144);
  assert.equal(e.AttackPower(1),120);
});
check('기존 스킬 공증과 카드 공증 합산, 감소 각인 및 소수점 버림',()=>{
  const {e}=fresh();e.ExpMember[0]=true;e.ExpCardOwned[1]=true;
  e.Hero_Damage[0]=42;e.PlayerStatsSet(0);assert.equal(e.AttackPower(0),186);
  e.ExpArcana[50]=3;e.PlayerStatsSet(0);
  assert.equal(e.Equip_DamageP[0],12);assert.equal(e.AttackPower(0),176);
});
check('원정 종료 시 공격력 카드 해제, 기존 스킬 버프와 장비 유지',()=>{
  const {e}=fresh();e.ExpMember[0]=true;e.ExpCardOwned[1]=true;e.Hero_Damage[0]=42;e.PlayerStatsSet(0);
  e.Finish(false);assert.equal(e.ExpMember[0],false);assert.equal(e.Equip_DamageP[0],0);
  assert.equal(e.AttackPower(0),162);assert.equal(e.Equip_Damage[0],120);
});
check('수집가에게 공격력 카드 반납 시 실제 공격력 회수와 등장 기록 유지',()=>{
  const {e}=fresh();e.ExpMember[0]=true;e.ExpCardOwned[1]=e.ExpCardSeen[1]=true;e.PlayerStatsSet(0);
  assert.equal(e.AttackPower(0),144);e.ExpEventCandidate[0]=5;e.PrepareEvent(0);e.ApplyEvent(0,2);
  assert.equal(e.AttackPower(0),120);assert.equal(e.ExpGold[0],250);assert(!e.ExpCardOwned[1]);assert(e.ExpCardSeen[1]);
});
check('정화는 원정 감소 각인만 없애고 장비 각인과 타인 능력치를 보존',()=>{
  const {e}=fresh();e.ExpMember[0]=true;e.ExpGold[0]=500;
  const types=e.GetItemTypes;e.GetItemTypes=s=>s==='ID99;'?6:types(s);
  e.GetItemCardBonus1=()=>0;e.GetItemCardBonus2=()=>0;e.GetItemCardBonus3=()=>2;e.Eitem[0][6]='ID99;';
  e.ExpArcana[50]=3;e.PlayerStatsSet(0);assert.equal(e.LoadInteger(e.ArcanaData,50,0),5);assert.equal(e.Equip_DamageP[0],-32);
  e.ExpEventCandidate[0]=7;e.PrepareEvent(0);e.ApplyEvent(0,1);
  assert.equal(e.ExpGold[0],350);assert.equal(e.ExpArcana[50],0);assert.equal(e.LoadInteger(e.ArcanaData,50,0),2);
  assert.equal(e.Equip_DamageP[0],-4);assert.equal(e.Eitem[0][6],'ID99;');assert.equal(e.AttackPower(1),120);
});
check('물약은 공격력을 바꾸지 않고 최종 대미지 증가, 카드 및 기존 최종 대미지 합산',()=>{
  const {e,use,damage}=fresh();e.ExpMember[0]=true;e.ExpState=e.EXP_BATTLE;e.ExpCardOwned[1]=true;e.PlayerStatsSet(0);
  const attack=e.AttackPower(0),before=damage(0);
  use(0);assert.equal(e.Hero_Damage[0],0);assert.equal(e.AttackPower(0),attack);
  assert.equal(e.FinalDamageBonus(0),30);assert(Math.abs(damage(0)-before*1.3)<1e-8);
  e.Equip_LastDamage[0]=10;assert.equal(e.FinalDamageBonus(0),40);
  assert(Math.abs(damage(0)-before*1.4)<1e-8);
});
check('물약 재사용은 갱신, 오래된 만료 무시, 플레이어별 독립 종료',()=>{
  const {e,use,advance}=fresh();e.Hero_Damage[0]=42;
  use(0);advance(5);use(0);use(1);
  assert.equal(e.Hero_BuffMoveSpeed[0],20);assert.equal(e.Hero_BuffAttackSpeed[0],20);
  advance(5);assert.equal(e.Hero_Buff2[0],30);assert.equal(e.Hero_Buff2[1],30);
  advance(5);assert.equal(e.Hero_Buff2[0],0);assert.equal(e.Hero_Buff2[1],0);
  assert.equal(e.Hero_Damage[0],42);assert.equal(e.Hero_BuffMoveSpeed[0],0);assert.equal(e.Hero_BuffAttackSpeed[0],0);
  use(1);assert.equal(e.Hero_Buff2[0],0);assert.equal(e.Hero_Buff2[1],30);
});
check('장비 재계산 중 물약 유지 및 만료 시 기존 최종 대미지 보존',()=>{
  const {e,use,advance}=fresh();e.Equip_LastDamage[0]=15;
  use(0);e.PlayerStatsSet(0);assert.equal(e.FinalDamageBonus(0),45);
  advance(10);assert.equal(e.FinalDamageBonus(0),15);
});
check('물약 이름과 설명은 공격력 대신 최종 대미지 효과 표시',()=>{
  const {e}=fresh(),item={};e.DamagePotionText(item);
  assert.equal(item.name,'최종 대미지 증가 물약');assert.equal(item.tip,item.name);
  assert(item.description.includes('최종 대미지 +30%'));assert(!item.description.includes('공격력'));
});
check('로컬 플레이어가 달라도 카드와 물약의 공유 전투 결과가 같음',()=>{
  const results=[0,1,4].map(pid=>{
    const {e,use,advance,damage}=fresh();e.localPlayer=pid;e.PickCheck=[true,false,false,false];
    e.ExpMember[0]=true;e.ExpState=e.EXP_BATTLE;e.GrantCard(0,1,1);e.RefreshStats(0);use(0);
    const active=[e.AttackPower(0),e.FinalDamageBonus(0),damage(0),e.Hero_BuffMoveSpeed[0]];
    advance(10);
    return [...active,e.AttackPower(0),e.FinalDamageBonus(0),damage(0),e.Hero_BuffMoveSpeed[0]];
  });
  assert.deepEqual(results[0],results[1]);assert.deepEqual(results[0],results[2]);
});
console.log(`${checks} attack/potion checks passed. Mock native execution; Warcraft runtime remains untested.`);
