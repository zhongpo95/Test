// 실제 JASS의 효과 누적과 조건별 각성 목록을 검증하고 전체 카드 검색이 되돌아오는 것을 차단한다.
'use strict';
const assert=require('node:assert/strict');
const {environment}=require('./check-expedition.cjs');
const {fresh}=require('./check-expedition-ui.cjs');
let checks=0;
const check=(name,fn)=>{fn();checks++;console.log('PASS '+name);};
const close=(a,b)=>assert(Math.abs(a-b)<1e-7,`${a} != ${b}`);
function setup(){
  let e;
  const {env}=environment(['Data/Data_Expedition.j','Data/Data_ExpeditionEvents.j','Data/Data_ExpeditionRewards.j',
    'System/ExpeditionEffects.j','System/SaveLoad.j','System/Expedition.j','System/ExpeditionPrototype.j','System/DamageEffectBoss.j'],{
    EQUIP_SLOT_WEAPON:1,GetItemTier:()=>2,AttackPower:()=>100,AddSpecialEffectTarget:()=>({}),DestroyEffect:()=>{},
    ATTACK_TYPE_CHAOS:0,DAMAGE_TYPE_UNIVERSAL:0,WEAPON_TYPE_WHOKNOWS:0,
    GetOwningPlayer:u=>u,UnitDamageTarget:(s,t,rate)=>{e.damageTaken=rate;},CustomStun:{Stun2:()=>{}},
  });
  e=env;e.ProtoStatsInit();e.ProtoCatalogInit();e.ExpPrototypeEnabled=true;
  e.online=[true,true,true,true];e.MapSt[5]=e.MapSt[6]={caster:null};e.MapRectCheck[5]=e.MapRectCheck[6]=true;
  for(let pid=0;pid<4;pid++)e.ExpReady[pid]=true;
  e.ProtoTryStart();assert.equal(e.ExpState,e.EXP_HUNT);return e;
}
function observe(e,name){
  const accesses=[],array=e[name];
  e[name]=new Proxy(array,{get(a,key){if(/^\d+$/.test(key))accesses.push(Number(key));return a[key];}});
  return {array,accesses};
}
function pending(e,pid,kind){
  const ids=[];
  for(let id=e.ProtoEvolutionFirst[pid*4+kind];id;id=e.ProtoEvolutionNext[e.ExpKey(pid,id)]){
    assert(!ids.includes(id),'중복 카드 또는 목록 순환');ids.push(id);assert(ids.length<=1023);
  }
  return ids;
}
function synthetic(e,id,kind,goal=1){
  e.ProtoCardName[id]='검사 카드 '+id;e.ProtoCardKey[id]='test_'+id;e.ProtoCardGrade[id]=1;
  e.ProtoEvolutionKind[id]=kind;e.ProtoEvolutionGoal[id]=goal;
}
function expected(e,pid){
  return Array.from({length:25},(_,i)=>{
    const kind=i+1;let total=0;
    for(let id=e.PROTO_CARD_FIRST;id<=e.PROTO_CARD_LAST;id++)if(e.ExpCardOwned[e.ExpKey(pid,id)]){
      const scale=1+.5*e.ProtoCardStacks[e.ExpKey(pid,id)];
      total+=e.LoadReal(e.ProtoEffectData,id,kind)*scale;
      if(e.ProtoEvolved[e.ExpKey(pid,id)])total+=e.LoadReal(e.ProtoEffectData,id,kind+32)*scale;
    }
    for(let head=1;head<=e.PROTO_HEAD_COUNT;head++)if(e.ProtoHeadOwned[e.ExpKey(pid,head)])total+=e.LoadReal(e.ProtoHeadEffectData,head,kind);
    return total;
  });
}
check('획득·각성은 해당 카드의 25개 효과만 읽고 중복 획득과 갱신은 추가하지 않음',()=>{
  const e=setup();synthetic(e,900,1);
  for(let kind=1;kind<=25;kind++){
    e.ProtoSetEffect(900,kind,kind/2,false);e.ProtoSetEffect(900,kind,-kind/4,true);
    e.SaveReal(e.ProtoHeadEffectData,13,kind,kind/8);
  }
  const owned=observe(e,'ExpCardOwned'),heads=observe(e,'ProtoHeadOwned'),reads=[],load=e.LoadReal;
  e.LoadReal=(table,id,kind)=>{if(table===e.ProtoEffectData||table===e.ProtoHeadEffectData)reads.push({table,id,kind});return load(table,id,kind);};
  e.ProtoAP[0]=2;e.ProtoGrantHead(0,13);e.ProtoGrantCard(0,900);
  for(let kind=1;kind<=25;kind++)close(e.ProtoStat(0,kind),kind*.625);
  assert.deepEqual(owned.accesses,[900]);assert.deepEqual(heads.accesses,[13]);
  assert(reads.every(r=>r.table===e.ProtoEffectData?r.id===900:r.id===13));
  assert.equal(reads.filter(r=>r.table===e.ProtoEffectData).length,50); // 기본 적용25와 결과 표시25.
  reads.length=0;e.ProtoKill(0);e.ProtoEvolutionTick(0);
  for(let kind=1;kind<=25;kind++)close(e.ProtoStat(0,kind),kind*.375);
  const ap=e.ProtoAP[0],maximum=e.ProtoAPMax[0],state=e.ProtoStatValues.slice();
  assert(reads.every(r=>r.id===900));
  assert.equal(reads.filter(r=>r.kind>32).length,50); // 각성 추가 적용25와 결과 표시25.
  reads.length=0;for(let i=0;i<5;i++){e.ProtoRefreshStats(0);e.ProtoEvolutionTick(0);}
  e.ProtoGrantCard(0,900);e.ProtoGrantHead(0,13);
  assert.equal(reads.length,0);assert.deepEqual(e.ProtoStatValues,state);assert.equal(e.ProtoAP[0],ap);assert.equal(e.ProtoAPMax[0],maximum);
  assert.deepEqual(pending(e,0,1),[]);
});
check('4인 실제 카드 전체는 각성 없이 기본 합계와 중복 강화만 적용',()=>{
  const e=setup();
  for(let pid=0;pid<4;pid++){
    for(const h of [1,5,13])e.ProtoGrantHead(pid,h);
    for(let id=e.PROTO_CARD_FIRST;id<=e.PROTO_CARD_LAST;id++)e.ProtoGrantCard(pid,id);
    expected(e,pid).forEach((value,i)=>close(e.ProtoStat(pid,i+1),value));
    e.ProtoHuntOwner[100]=pid+1;
    for(let i=0;i<100;i++){e.ProtoKill(pid);e.ProtoRecordDamage(pid,100,10000);e.ProtoEvolutionTick(pid);}
    for(let id=e.PROTO_CARD_FIRST;id<=e.PROTO_CARD_LAST;id++){
      assert.equal(e.ProtoEvolutionKind[id],0);assert.equal(e.ProtoEvolutionGoal[id],0);
      assert(!e.ProtoEvolved[e.ExpKey(pid,id)]);assert.equal(e.ProtoCardProgress[e.ExpKey(pid,id)],0);
      assert(!e.ProtoCardText(pid,id).includes('각성'));
      for(let kind=1;kind<=25;kind++)assert.equal(e.LoadReal(e.ProtoEffectData,id,kind+32),0);
      e.ProtoGrantEventCard(pid,id);assert.equal(e.ProtoCardStacks[e.ExpKey(pid,id)],1);
    }
    expected(e,pid).forEach((value,i)=>close(e.ProtoStat(pid,i+1),value));
    for(let kind=1;kind<=3;kind++)assert.deepEqual(pending(e,pid,kind),[]);
  }
});
check('미보유·각성 완료 카드는 주기·피해·처치·피격 처리에서 조회하지 않음',()=>{
  const e=setup(),owned=observe(e,'ExpCardOwned'),progress=observe(e,'ProtoCardProgress');
  e.ProtoHuntOwner[100]=1;
  for(let pid=0;pid<4;pid++)for(let tick=0;tick<240;tick++)e.ProtoEvolutionTick(pid);
  e.ProtoKill(0);e.ProtoRecordDamage(0,100,10);e.BossDeal(99,0,50,false);
  assert.deepEqual(owned.accesses,[]);assert.deepEqual(progress.accesses,[]);
  for(let id=900;id<=902;id++){synthetic(e,id,id-899);e.ProtoGrantCard(0,id);}
  e.ProtoKill(0);e.ProtoRecordDamage(0,100,10);e.ProtoCardProgress[902]=1;e.ProtoEvolutionTick(0);
  owned.accesses.length=progress.accesses.length=0;
  for(let tick=0;tick<240;tick++)e.ProtoEvolutionTick(0);
  e.ProtoKill(0);e.ProtoRecordDamage(0,100,10);e.BossDeal(99,0,50,false);
  assert.deepEqual(owned.accesses,[]);assert.deepEqual(progress.accesses,[]);
});
check('처치·실제 피해·무피격은 해당 조건과 해당 플레이어의 미각성 카드만 처리',()=>{
  const e=setup();
  for(let id=900;id<=903;id++)synthetic(e,id,id===903?2:id-899,100);
  for(let pid=0;pid<4;pid++)for(let id=900;id<=903;id++)e.ProtoGrantCard(pid,id);
  const owned=observe(e,'ExpCardOwned'),progress=observe(e,'ProtoCardProgress');
  e.ProtoKill(3);assert.deepEqual(progress.accesses,[e.ExpKey(3,900)]);progress.accesses.length=0;
  e.ProtoHuntOwner[100]=4;e.ProtoRecordDamage(3,100,7);
  assert.deepEqual(progress.accesses,[e.ExpKey(3,903),e.ExpKey(3,901)]);progress.accesses.length=0;
  e.ProtoRecordDamage(0,100,7);e.ProtoRecordDamage(3,100,0);e.ProtoRecordDamage(3,100,-7);assert.deepEqual(progress.accesses,[]);
  e.ProtoEvolutionTick(3);assert.equal(e.ProtoCardProgress[e.ExpKey(3,902)],.25);
  for(let pid=0;pid<3;pid++)for(let id=900;id<=903;id++)assert.equal(e.ProtoCardProgress[e.ExpKey(pid,id)],0);
  assert.deepEqual(owned.accesses,[]);
});
check('목록의 처음·중간·마지막과 연속 카드가 같은 틱에 각성해도 누락·중복 없음',()=>{
  const e=setup(),order=[900,901,902,903,904];
  for(const id of order){synthetic(e,id,1);e.ProtoSetEffect(id,e.PROTO_STAT_ATTACK,1,true);e.ProtoGrantCard(0,id);}
  for(const id of [904,902,900])e.ProtoCardProgress[id]=1;
  e.ProtoEvolutionTick(0);assert.deepEqual(pending(e,0,1),[903,901]);assert.equal(e.ProtoStat(0,e.PROTO_STAT_ATTACK),3);
  e.ProtoKill(0);e.ProtoEvolutionTick(0);assert.deepEqual(pending(e,0,1),[]);assert.equal(e.ProtoStat(0,e.PROTO_STAT_ATTACK),5);
  for(const id of order){assert(e.ProtoEvolved[id]);assert.equal(e.ProtoEvolutionNext[id],0);}
  e.ProtoKill(0);e.ProtoEvolutionTick(0);assert.equal(e.ProtoStat(0,e.PROTO_STAT_ATTACK),5);
});
check('카드 1023번까지 조건 목록과 캐시는 4인 간 충돌하지 않음',()=>{
  const e=setup();
  for(let id=900;id<=1023;id++){synthetic(e,id,1);e.ProtoSetEffect(id,e.PROTO_STAT_DAMAGE,1,false);e.ProtoSetEffect(id,e.PROTO_STAT_DAMAGE,2,true);}
  for(let pid=0;pid<4;pid++)for(let id=900;id<=1023;id++)e.ProtoGrantCard(pid,id);
  for(let pid=0;pid<4;pid++){assert.equal(pending(e,pid,1).length,124);assert.equal(e.ProtoStat(pid,e.PROTO_STAT_DAMAGE),124);}
  e.ProtoKill(3);e.ProtoEvolutionTick(3);assert.equal(e.ProtoStat(3,e.PROTO_STAT_DAMAGE),372);assert.deepEqual(pending(e,3,1),[]);
  for(let pid=0;pid<3;pid++){assert.equal(pending(e,pid,1).length,124);assert.equal(e.ProtoCardProgress[e.ExpKey(pid,1023)],0);assert(!e.ProtoEvolved[e.ExpKey(pid,1023)]);}
});
check('피격은 보호막 흡수에도 무피격만 초기화하고 사건 정지·준비·보스 상태는 보존',()=>{
  const e=setup();for(let id=900;id<=902;id++){synthetic(e,id,id-899,100);e.ProtoGrantCard(0,id);e.ProtoCardProgress[id]=10;}
  e.UnitSD[0]=100;e.BossDeal(99,0,50,false);assert.equal(e.UnitSD[0],50);assert.equal(e.ProtoCardProgress[902],0);
  assert.equal(e.ProtoCardProgress[900],10);assert.equal(e.ProtoCardProgress[901],10);
  e.ProtoCardProgress[902]=10;
  e.ProtoPaused[0]=true;e.BossDeal(99,0,50,false);assert.equal(e.ProtoCardProgress[902],10);assert.equal(e.UnitSD[0],50);
  e.ProtoPaused[0]=false;e.ProtoReady[0]=true;e.BossDeal(99,0,50,false);assert.equal(e.ProtoCardProgress[902],10);
  e.ProtoReady[0]=false;e.BossDeal(99,0,0,false);assert.equal(e.ProtoCardProgress[902],10);
  e.ExpState=e.EXP_BATTLE;e.BossDeal(99,0,5,false);assert.equal(e.ProtoCardProgress[902],10);
});
check('새 원정에서 이전 능력치를 비우며 실제 카드 재획득에도 각성 목록은 비어 있음',()=>{
  const t=fresh(0,true),e=t.e;t.start();
  const ids=['axel_vanir','shiro_analysis','saber_opening'].map(key=>e.ProtoCardKey.indexOf(key));
  for(const id of ids)e.ProtoGrantCard(0,id);
  e.ProtoGrantHead(0,1);e.ProtoCardProgress[ids[0]]=e.ProtoEvolutionGoal[ids[0]];e.ProtoEvolutionTick(0);
  e.Finish(false);for(let kind=1;kind<=3;kind++)assert.deepEqual(pending(e,0,kind),[]);
  e.ProtoAction(0,2001);assert.equal(e.ExpState,e.EXP_HUNT);
  for(let kind=1;kind<=25;kind++)assert.equal(e.ProtoStat(0,kind),0);
  assert.equal(e.ProtoAP[0],10);assert.equal(e.ProtoAPMax[0],10);assert.equal(e.ProtoChoices[0],3);assert.equal(e.ProtoGoldBonus[0],0);
  for(const id of ids){assert(!e.ExpCardOwned[id]);assert(!e.ProtoEvolved[id]);assert.equal(e.ProtoCardProgress[id],0);e.ProtoGrantCard(0,id);}
  for(let kind=1;kind<=3;kind++)assert.equal(pending(e,0,kind).length,0);
  e.ProtoKill(0);assert.equal(e.ProtoCardProgress[ids[0]],0);
});
check('13개 지역 입구는 4인 전부 결과까지 완료하며 갱신 중 미보유 조회가 없음',()=>{
  for(let head=1;head<=13;head++){
    const e=setup(),owned=observe(e,'ExpCardOwned'),entry=e.ProtoHeadEntryCard[head];
    for(let pid=0;pid<4;pid++){
      const id=(head-1)*4+pid+1;e.ProtoOffer(pid);e.ProtoCandidates[e.ExpKey(pid,1)]=id;owned.accesses.length=0;
      e.ProtoAction(pid,2101);assert.equal(e.ProtoStage[pid],3);assert.equal(e.ProtoAP[pid],10);assert(e.ProtoHeadOwned[e.ExpKey(pid,head)]);
      assert(owned.array[e.ExpKey(pid,entry)]);assert(owned.accesses.every(key=>key===e.ExpKey(pid,entry)));
      expected(e,pid).forEach((value,i)=>close(e.ProtoStat(pid,i+1),value));
    }
  }
});
check('중복 강화는 원래 효과의 50%씩 가산하며 각성 전후 순서와 진행을 보존',()=>{
  const results=[];
  for(const awakeFirst of [false,true]){
    const e=setup(),id=e.PROTO_CARD_FIRST;synthetic(e,id,1,10);
    for(let kind=1;kind<=25;kind++){e.ProtoSetEffect(id,kind,kind,false);e.ProtoSetEffect(id,kind,kind/2,true);}
    e.ProtoGrantCard(0,id);e.ProtoCardProgress[id]=4;
    if(awakeFirst){e.ProtoCardProgress[id]=10;e.ProtoEvolutionTick(0);}
    const before=e.ProtoCardProgress[id],revision=e.ProtoCardRevision[0];
    e.ProtoGrantEventCard(0,id);assert.equal(e.ProtoCardProgress[id],before);assert.equal(e.ProtoCardStacks[id],1);
    for(let kind=1;kind<=25;kind++)close(e.ProtoStat(0,kind),kind*(awakeFirst?2.25:1.5));
    e.ProtoGrantEventCard(0,id);assert.equal(e.ProtoCardStacks[id],2);assert.equal(e.ProtoCardRevision[0],revision+2);
    assert(e.ProtoCardText(0,id).includes('효과 200%'));assert(e.ProtoOutcome[0].includes('강화 완료'));assert.equal(e.ExpGold[0],0);
    if(!awakeFirst){e.ProtoCardProgress[id]=10;e.ProtoEvolutionTick(0);}
    for(let kind=1;kind<=25;kind++)close(e.ProtoStat(0,kind),kind*3);
    results.push(e.ProtoStatValues.slice(1,26));assert.deepEqual(pending(e,0,1),[]);
    for(let pid=1;pid<4;pid++)for(let kind=1;kind<=25;kind++)assert.equal(e.ProtoStat(pid,kind),0);
  }
  assert.deepEqual(results[0],results[1]);
});
check('중복은 해당 카드만 읽으며 선택·결과 배율과 정수 옵션 상한, 새 런 초기화가 일치',()=>{
  const e=setup(),id=e.PROTO_CARD_FIRST;synthetic(e,id,0);
  e.ProtoSetEffect(id,e.PROTO_STAT_DAMAGE,10,false);e.ProtoSetEffect(id,e.PROTO_STAT_CHOICES,1,false);e.ProtoSetEffect(id,e.PROTO_STAT_CAPACITY,1,false);
  e.ProtoGrantCard(0,id);e.ProtoAP[0]=2;e.ProtoSelected[0]=53;const key=e.ProtoChoiceKey(53,1);e.ProtoBranchCard[key]=id;
  assert(e.ProtoBranchText(0,1).includes('대미지 증가 +15.0%'));assert(e.ProtoBranchSummary(0,1).includes('원래 효과 +50%'));
  const reads=[],load=e.LoadReal;e.LoadReal=(table,card,kind)=>{if(table===e.ProtoEffectData)reads.push(card);return load(table,card,kind);};
  e.ProtoGrantEventCard(0,id);assert(reads.every(card=>card===id));assert.equal(reads.length,50); // 누적25 + 결과표시25.
  e.ProtoRefreshStats(0);assert.equal(e.ProtoChoices[0],4);assert.equal(e.ProtoAPMax[0],11);assert.equal(e.ProtoAP[0],2);
  e.ProtoGrantEventCard(0,id);e.ProtoRefreshStats(0);assert.equal(e.ProtoChoices[0],4);assert.equal(e.ProtoAPMax[0],12);assert.equal(e.ProtoAP[0],3);
  e.ProtoRefreshStats(0);assert.equal(e.ProtoAP[0],3);
  const t=fresh(0,true),run=t.e;t.start();run.ProtoGrantCard(0,id);run.ProtoGrantEventCard(0,id);run.ProtoGrantEventCard(0,id);
  assert.equal(run.ProtoCardStacks[id],2);run.Finish(false);run.ProtoAction(0,2001);assert.equal(run.ProtoCardStacks[id],0);assert.equal(run.ProtoStat(0,run.PROTO_STAT_DAMAGE),0);
});
console.log(`${checks} incremental effect/awakening groups passed. Actual JASS with mock natives; Warcraft runtime, multiplayer and frame-time performance remain untested.`);
