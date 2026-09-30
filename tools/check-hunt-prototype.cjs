// 실제 개인 사냥 JASS와 UI 콜백을 모의 실행하여 사건·성장·합류의 경계를 검증한다.
const assert = require('node:assert/strict');
const {fresh} = require('./check-expedition-ui.cjs');
const {fresh: combat} = require('./check-attack-potion.cjs');
const {environment} = require('./check-expedition.cjs');
let checks=0;
const check=(name,fn)=>{fn();checks++;console.log('PASS '+name);};
function party(n=1){
  const t=fresh(0,true),e=t.e;
  e.online=Array.from({length:4},(_,i)=>i<n);
  for(let pid=0;pid<n;pid++){e.ProtoCodexSlot[pid]=1;e.ExpAction(pid,2001);}
  assert.equal(e.ExpState,e.EXP_HUNT);t.render();return t;
}
function request(e,pid,action,packet){
  e.eventPlayer=pid;e.syncData=packet??`${e.ExpRun}|${e.ExpRevision}|${e.ExpOfferVersion[pid]}|${action}`;e.OnSync();
}
function choose(e,pid,id,branch=1){
  e.ProtoOffer(pid);e.ProtoCandidates[e.ExpKey(pid,1)]=id;
  request(e,pid,2101);
  if(e.ProtoEventKind[id]!==0){assert.equal(e.ProtoStage[pid],2);request(e,pid,2200+branch);}
  assert.equal(e.ProtoStage[pid],3);
  request(e,pid,2400);assert.equal(e.ProtoStage[pid],0);
}
check('머리 카드 없음은 도감 동기화 전에도 준비·출발 가능, 발견하지 않은 머리는 차단',()=>{
  const t=fresh(0,true),e=t.e;e.ProtoCodexSlot[0]=0;t.render();
  assert.equal(e.ProtoStartHead[0],0);assert(t.frame(t.common(2001)).enabled);assert(e.ProtoCanDepart(0));
  e.ProtoStartHead[0]=1;assert(!e.ProtoCanDepart(0));e.ProtoHeadKnown[1]=true;
  assert(!e.ProtoCanDepart(0));e.ProtoCodexSlot[0]=1;assert(e.ProtoCanDepart(0));
  e.ProtoHeadKnown[1]=false;assert(!e.ProtoCanDepart(0));e.ProtoStartHead[0]=0;e.ProtoCodexSlot[0]=0;
  t.start();assert.equal(e.ProtoHeadCount[0],0);assert.equal(e.ProtoDamageBonus[0],0);
});
check('카드 없이 파티 준비 중 늦은 도감 동기화는 준비 상태를 취소하지 않음',()=>{
  const t=fresh(0,true),e=t.e;e.online=[true,true,false,false];e.ProtoCodexSlot[0]=e.ProtoCodexSlot[1]=0;
  request(e,0,2001);assert(e.ExpReady[0]);assert.equal(e.ExpState,e.EXP_LOBBY);
  e.eventPlayer=0;e.syncData='1|0|0|0';e.ProtoCodexSync();assert(e.ExpReady[0]);
  request(e,1,2001);assert.equal(e.ExpState,e.EXP_HUNT);assert.equal(e.ExpPlayers,2);
});
check('카드 없이 출발 후 늦은 도감 로드는 새 발견을 보존하고 기존 도감도 복원',()=>{
  const t=fresh(0,true),e=t.e;e.ProtoCodexSlot[0]=0;t.start();e.ProtoGrantHead(0,1);
  e.eventPlayer=0;e.syncData='1|0|1|0';e.ProtoCodexSync();
  assert.equal(e.ProtoCodexSlot[0],1);assert(e.ProtoHeadKnown[1]);assert(e.ProtoHeadKnown[2]);
  assert.equal(e.ProtoHeadCount[0],1);assert(!e.ProtoHeadOwned[2]);assert.equal(e.ExpState,e.EXP_HUNT);
});
check('T1 출발 차단, 도감 머리 0~1장 선택과 초기 전투 카드 없음',()=>{
  const t=fresh(0,true),e=t.e;e.MockAttack=1;t.render();
  assert(!t.frame(t.common(2001)).enabled);request(e,0,2001);assert.equal(e.ExpRun,0);
  e.MockAttack=100;e.GetItemTier=()=>1;request(e,0,2001);assert.equal(e.ExpRun,0);
  e.GetItemTier=()=>2;e.ProtoHeadKnown[e.ExpKey(0,1)]=true;t.render();t.click(t.common(2011));
  assert.equal(e.ProtoStartHead[0],1);t.start();assert.equal(e.ProtoHeadCount[0],1);
  assert.equal(e.ProtoAP[0],10);assert.equal(e.ExpSeconds,600);assert.equal(e.ExpGold[0],0);
  assert.equal(e.ExpCardOwned.filter(Boolean).length,0);
  assert.equal(e.ProtoDamageBonus[0],5);assert(e.ProtoEventEligible(0,13));assert(!e.ProtoEventEligible(0,25));
});
check('4인 개인 구역 1~4와 남은 5~6 구역의 보스 예약, 사용 중이면 출발 보류',()=>{
  const t=fresh(0,true),e=t.e;e.online=[true,true,true,true];e.MapSt[2].caster={};
  for(let pid=0;pid<4;pid++){e.ProtoCodexSlot[pid]=1;request(e,pid,2001);}
  assert.equal(e.ExpRun,0);assert(e.MapRectCheck[1]);assert(e.MapRectCheck[5]);
  e.MapSt[2].caster=null;e.MapRectCheck[5]=false;e.ProtoTryStart();
  assert.equal(e.ExpArena,6);assert.equal(e.ExpPlayers,4);assert(e.ExpMember.slice(0,4).every(Boolean));
  assert(e.MapRectCheck.slice(1,5).every(v=>v===false));assert.equal(e.MapRectCheck[6],false);
});
check('기본 근접 몬스터 체력 300, 처치당 10골드와 지속 재생성',()=>{
  const {e}=party();e.ProtoHuntUpdate(0);
  assert(e.HuntUnits.slice(1,5).every(Boolean));assert.equal(e.HuntUnits[5],null);
  for(let slot=1;slot<=4;slot++){const u=e.HuntUnits[slot];assert.equal(e.UnitHPMAX[u.id],300);assert.equal(e.UnitArm[u.id],0);assert.equal(u.engineArmor,0);assert.equal(e.ProtoHuntOwner[u.id],1);assert(!u.abilities.has('Aatk'));}
  const old=e.HuntUnits[1];e.UnitHP[old.id]=0;e.ProtoHuntUpdate(0);
  assert(old.removed);assert.notEqual(e.HuntUnits[1],old);assert.equal(e.ExpGold[0],10);assert.equal(e.ProtoKills[0],1);
  assert.equal(e.UnitArm[e.HuntUnits[1].id],0);assert.equal(e.HuntUnits[1].engineArmor,0);
  assert.equal(e.ExpCardOwned.filter(Boolean).length,0);assert.equal(e.ProtoAP[0],10);
});
check('일반 전투 근접·원거리·위험 몬스터 방어력 0, 보스 방어력 유지',()=>{
  const {env:e}=environment(['System/ExpeditionCombat.j'],{
    ExpEnemy:[], ExpMember:[false,false,false,false], ClearWarning:()=>{}, UpdateHealth:()=>{},
    CreateUnit:(p,raw,x,y)=>({id:100,p,raw,x,y,engineArmor:9,abilities:new Set()}),
  },['SpawnEnemy']);
  e.Planned[1]=true;e.SpawnX[1]=100;e.SpawnY[1]=100;e.EnemyMaximum[1]=300;
  for(const kind of [1,2,3,4]){
    e.EnemyKind[1]=kind;e.SpawnEnemy(1);const u=e.Enemies[1];
    assert.equal(e.UnitArm[u.id],kind===4?2000:0);assert.equal(u.engineArmor,kind===4?9:0);
  }
});
check('4인 최초 생성·재생성은 각자의 MapCenter 내부이며 미지정·막힌 구역에서 외부 생성하지 않음',()=>{
  const {e}=party(4);
  const inside=(u,r)=>u.x>=r.minX+160&&u.x<=r.maxX-160&&u.y>=r.minY+160&&u.y<=r.maxY-160;
  for(let pid=0;pid<4;pid++){
    e.MapCenter[pid+1]={minX:4000*(pid+1),minY:5000*(pid+1),maxX:4000*(pid+1)+1600,maxY:5000*(pid+1)+1600};
    e.ProtoDensity[pid]=10;e.ProtoHuntUpdate(pid);
    for(let slot=1;slot<=10;slot++)assert(inside(e.HuntUnits[pid*16+slot],e.MapCenter[pid+1]));
    for(let i=0;i<20;i++){
      const old=e.HuntUnits[pid*16+1];e.UnitHP[old.id]=0;e.ProtoHuntUpdate(pid);
      assert(old.removed);assert(inside(e.HuntUnits[pid*16+1],e.MapCenter[pid+1]));
    }
  }
  e.ProtoRemoveEnemy(1);e.MapCenter[1]=null;e.ProtoSpawn(0,1);assert.equal(e.HuntUnits[1],null);
  e.MapCenter[1]={minX:1000,minY:1000,maxX:1200,maxY:1200};e.ProtoSpawn(0,1);assert.equal(e.HuntUnits[1],null);
  e.MapCenter[1]={minX:1000,minY:1000,maxX:2600,maxY:2600};e.IsTerrainPathable=()=>true;
  e.ProtoSpawn(0,1);assert.equal(e.HuntUnits[1],null);
  e.IsTerrainPathable=()=>false;e.MapCenter[1]={minX:-320,minY:-320,maxX:320,maxY:320};
  e.ProtoSpawn(0,1);assert.equal(e.HuntUnits[1],null);
});
check('중립 귀환 AI 차단, 동일 목적지 추적 유지와 사건 재개 후 재추적·근접 공격',()=>{
  const {e}=party(),orders=[];e.ProtoHuntUpdate(0);const u=e.HuntUnits[1];
  assert.equal(u.creepGuard,false);assert(u.guardRemoved);u.x=600;u.y=0;
  e.IssuePointOrder=(enemy,order,x,y)=>{enemy.order=order;orders.push({enemy,x,y});return true;};
  for(let i=0;i<5;i++)e.ProtoHuntUpdate(0);assert.equal(orders.filter(o=>o.enemy===u).length,1);
  const getX=e.GetUnitX;e.GetUnitX=unit=>unit===0?150:getX(unit);e.ProtoHuntUpdate(0);
  assert.equal(orders.filter(o=>o.enemy===u).length,2);assert.equal(orders.at(-1).x,150);
  e.ProtoOffer(0);u.order='stop';e.ProtoResume(0);e.ProtoHuntUpdate(0);
  assert.equal(orders.filter(o=>o.enemy===u).length,3);
  const hits=[];e.BossDeal=(source,target,damage)=>hits.push({source,target,damage});u.x=250;
  e.ProtoHuntUpdate(0);assert(e.AttackWarning[1]);assert.equal(u.order,'stop');
  e.ProtoHuntUpdate(0);e.ProtoHuntUpdate(0);assert.equal(hits.filter(h=>h.source===u).length,1);
  assert.equal(hits.find(h=>h.source===u).damage,400);
});
check('HeroDeal에서 체력바와 치명적 타격의 사망을 즉시 반영하고 각성 피해는 실제 체력만 집계',()=>{
  const {e}=combat(),life=[],kills=[];e.ProtoDataInit();e.ExpPrototypeActive=true;e.ExpMember[0]=true;e.ExpState=e.EXP_HUNT;
  e.ProtoHuntOwner[2]=1;e.ExpEnemy[2]=true;e.UnitHP[2]=300;e.UnitHPMAX[2]=300;e.ExpCardOwned[16]=true;
  e.SetUnitState=(unit,state,value)=>life.push({unit,state,value});e.KillUnit=unit=>kills.push(unit);
  e.HeroDeal(1,0,2,1,false,false,false,false);assert.equal(e.UnitHP[2],168);
  assert(Math.abs(life.at(-1).value-5600)<1e-8);assert.equal(kills.length,0);
  e.HeroDeal(1,0,2,2,false,false,false,false);assert.deepEqual(kills,[2]);assert.equal(e.ProtoDamage[0],300);
  e.HeroDeal(1,0,2,2,false,false,false,false);assert.deepEqual(kills,[2]);
});
check('내 사건 중에는 내 공간만 정지하고 공통 최대시간과 다른 플레이어 사냥은 계속됨',()=>{
  const {e}=party(2),paused=new Map();e.PauseUnit=(u,v)=>paused.set(u,v);
  e.ProtoHuntUpdate(0);e.ProtoHuntUpdate(1);e.ProtoOffer(0);
  assert(paused.get(e.MainUnit[0]));assert(paused.get(e.HuntUnits[1]));assert(!e.ProtoPaused[1]);
  assert(!e.ProtoCanHit(0,e.HuntUnits[1].id));assert(!e.ProtoCanHit(1,e.HuntUnits[1].id));
  const own=e.HuntUnits[1];e.UnitHP[own.id]=0;
  for(let i=0;i<4;i++)e.ProtoTick();
  assert.equal(e.ExpSeconds,599);assert.equal(e.HuntSeconds[0],0);assert.equal(e.HuntSeconds[1],1);
  assert.equal(e.ProtoKills[0],0);assert.equal(e.ExpGold[0],0);
  e.ProtoResume(0);e.ProtoHuntUpdate(0);assert.equal(e.ProtoKills[0],1);
});
check('사건 선택만 AP 소모, 500/600골드 리롤과 다음 화면 500골드 복귀',()=>{
  const t=party(),e=t.e;e.ExpGold[0]=2000;e.ProtoOffer(0);t.render();
  assert.equal(e.ProtoChoices[0],2);t.click(t.common(2300));assert.equal(e.ExpGold[0],1500);assert.equal(e.ProtoAP[0],10);
  t.click(t.common(2300));assert.equal(e.ExpGold[0],900);assert.equal(e.ProtoRerolls[0],2);
  const id=e.ProtoCandidates[e.ExpKey(0,1)];t.click(t.common(2101));assert(e.ProtoEventUsed[id]);assert.equal(e.ProtoAP[0],9);
  t.click(t.common(2202));const after=e.ExpGold[0];request(e,0,2202);assert.equal(e.ExpGold[0],after);
  t.click(t.common(2400));assert(!e.ProtoPaused[0]);assert.equal(e.ProtoRerolls[0],0);
  e.ProtoOffer(0);assert.equal(500+e.ProtoRerolls[0]*100,500);assert(!e.ProtoEventEligible(0,id));
});
check('표시만 된 사건은 미소비, 동시 선택은 파티 중복 차단과 오래된 패킷 거부',()=>{
  const {e}=party(2);e.ProtoOffer(0);e.ProtoOffer(1);const id=49;
  e.ProtoCandidates[e.ExpKey(0,1)]=id;e.ProtoCandidates[e.ExpKey(1,1)]=id;
  assert(!e.ProtoEventUsed[id]);const old=`${e.ExpRun}|${e.ExpRevision}|${e.ExpOfferVersion[1]}|2101`;
  request(e,0,2101);assert(e.ProtoEventUsed[id]);assert.equal(e.ProtoAP[0],9);
  assert(![1,2].some(i=>e.ProtoCandidates[e.ExpKey(1,i)]===id));
  request(e,1,2101,old);assert.equal(e.ProtoAP[1],10);assert.equal(e.ProtoStage[1],1);
});
check('처치·시간·정체 사건의 쿨다운, AP 0일 때 사냥만 계속',()=>{
  for(const reason of ['kills','time','stalled']){
    const {e}=party();e.HuntSeconds[0]=reason==='time'?44:24;e.ProtoLastKill[0]=reason==='stalled'?0:e.HuntSeconds[0];
    if(reason==='kills')e.ProtoKills[0]=12;
    for(let i=0;i<4;i++)e.ProtoTick();assert.equal(e.ProtoStage[0],1,reason);
    e.ProtoResume(0);for(let i=0;i<19*4;i++)e.ProtoTick();assert.equal(e.ProtoStage[0],0);
  }
  const {e}=party();e.ProtoAP[0]=0;e.ProtoKills[0]=100;
  for(let i=0;i<60*4;i++)e.ProtoTick();assert.equal(e.ProtoStage[0],0);
  const before=e.ExpGold[0];e.UnitHP[e.HuntUnits[1].id]=0;e.ProtoTick();assert.equal(e.ExpGold[0],before+10);
});
check('사건 필드 변경은 기존 몬스터에도 HP 비율을 보존하고 적용하며 상한에서 공짜 위험 보상 차단',()=>{
  const {e}=party();e.ProtoHuntUpdate(0);const u=e.HuntUnits[1];e.UnitHP[u.id]=150;
  choose(e,0,51,1);assert.equal(e.ProtoLevel[0],2);assert.equal(e.UnitHPMAX[u.id],390);assert.equal(e.UnitHP[u.id],195);
  assert(e.ProtoOutcome[0].includes('적 단계 1 → 2'));assert(e.ProtoOutcome[0].includes('몬스터 체력 300 → 390'));
  assert(e.ProtoOutcome[0].includes('4.0% → 5.0%'));
  const gold=e.ExpGold[0];assert.equal(gold,250);e.ProtoSelected[0]=51;e.ProtoLevel[0]=5;assert(!e.ProtoBranchAllowed(0,1));
  e.ProtoLevel[0]=2;choose(e,0,50,1);assert.equal(e.ProtoDensity[0],6);e.ProtoHuntUpdate(0);assert(e.HuntUnits[6]);
  assert(e.ProtoOutcome[0].includes('동시 몬스터 수 4 → 6'));
  e.ProtoDensity[0]=9;e.ProtoSelected[0]=50;assert(!e.ProtoBranchAllowed(0,1));
});
check('획득 이후부터만 처치·실제 피해·무피격 각성 진행, 카드 효과와 최대 사건 후보 4개',()=>{
  const {e}=party();e.ProtoKills[0]=100;e.ProtoDamage[0]=50000;e.ProtoSafeTime[0]=100;
  e.ProtoGrantCard(0,15);e.ProtoGrantCard(0,16);e.ProtoGrantCard(0,17);
  for(const id of [15,16,17])assert.equal(e.ProtoCardProgress[e.ExpKey(0,id)],0);
  for(let i=0;i<25;i++)e.ProtoKill(0);e.ProtoEvolutionTick(0);assert(e.ProtoEvolved[e.ExpKey(0,15)]);
  e.ProtoHuntOwner[100]=1;e.ProtoRecordDamage(0,100,6000);e.ProtoEvolutionTick(0);assert(e.ProtoEvolved[e.ExpKey(0,16)]);
  for(let i=0;i<180;i++)e.ProtoEvolutionTick(0);assert(e.ProtoEvolved[e.ExpKey(0,17)]);
  const defense=environment(['Data/Data_Expedition.j','Data/Data_Prototype.j','System/DamageEffectBoss.j'],{
    GetOwningPlayer:u=>u,UnitDamageTarget:(s,t,rate)=>{defense.lastDamage=rate;},CustomStun:{Stun2:()=>{}},
  }).env;
  // 별도 실제 BossDeal 실행. 차감한 보호막에도 무피격 조건은 깨진다.
  defense.ProtoDataInit();defense.ExpPrototypeActive=true;defense.ExpMember[0]=true;defense.ExpState=defense.EXP_HUNT;
  defense.ExpCardOwned[17]=true;defense.ProtoCardProgress[17]=30;defense.UnitSD[0]=100;
  defense.BossDeal(99,0,50,false);assert.equal(defense.ProtoCardProgress[17],0);assert.equal(defense.UnitSD[0],57.5);
  defense.ProtoPaused[0]=true;defense.BossDeal(99,0,50,false);assert.equal(defense.UnitSD[0],57.5);
  e.ProtoGrantCard(0,18);e.ProtoHeadOwned[e.ExpKey(0,3)]=true;e.ProtoGrantCard(0,29);
  assert.equal(e.ProtoChoices[0],4);e.ProtoOffer(0);assert(e.ProtoCandidates[e.ExpKey(0,4)]>0);
  e.ProtoGrantCard(0,14);assert.equal(e.ExpCardPenetration(0),.15);
});
check('실제 HeroDeal에서 정지·타인 사냥터 피해 차단, 초과 피해를 각성에 더하지 않음',()=>{
  const {e}=combat();e.ProtoDataInit();e.ExpPrototypeActive=true;e.ExpMember[0]=true;e.ExpState=e.EXP_HUNT;
  e.ProtoHuntOwner[2]=1;e.ExpEnemy[2]=true;e.ExpCardOwned[16]=true;e.UnitHP[2]=30;
  e.HeroDeal(1,0,2,1,false,false,false,false);assert.equal(e.ProtoDamage[0],30);assert.equal(e.ProtoCardProgress[16],30);
  e.UnitHP[2]=100;e.ProtoPaused[0]=true;e.HeroDeal(1,0,2,1,false,false,false,false);assert.equal(e.UnitHP[2],100);
  e.ProtoPaused[0]=false;e.ProtoHuntOwner[2]=2;e.HeroDeal(1,0,2,1,false,false,false,false);assert.equal(e.UnitHP[2],100);
});
check('획득 카드 전체를 로컬 페이지로 확인, 효과·각성 진행 표시와 난이도 HUD 갱신',()=>{
  const t=party(),e=t.e,notices=[];e.DisplayTimedTextToPlayer=(player,x,y,seconds,text)=>notices.push(text);
  for(let id=e.PROTO_CARD_FIRST;id<=e.PROTO_CARD_LAST;id++)e.ProtoGrantCard(0,id);
  const count=e.PROTO_CARD_LAST-e.PROTO_CARD_FIRST+1;
  assert.equal(notices.length,count);assert(notices[0].includes(e.ProtoCardName[13]));
  e.ProtoGrantHead(0,1);e.ExpUIOpen(5);t.render();const effect=t.frame(e.UIExpeditionStats_Effects);
  const previous=e.ExpUIButtons[e.UIExpeditionStats_PreviousCard],next=e.ExpUIButtons[e.UIExpeditionStats_NextCard];
  assert(effect.text.includes('학원도시'));assert(effect.text.includes(e.ProtoCardName[13]));assert(!t.frame(previous).enabled);
  t.click(next);assert(effect.text.includes(e.ProtoCardName[14]));assert(effect.text.includes('방어력 관통 +15%'));
  t.event(next,4,1);t.render();assert(effect.text.includes(e.ProtoCardName[14]));
  t.click(next);e.ProtoCardProgress[15]=9;t.render();assert(effect.text.includes('9/25'));
  e.ProtoEvolved[15]=true;t.render();assert(effect.text.includes('각성 · 피해 +25%'));
  for(let i=3;i<count;i++)t.click(next);assert(effect.text.includes(e.ProtoCardName[e.PROTO_CARD_LAST]));assert(!t.frame(next).enabled);
  assert.equal(t.packets.length,0);assert.equal(e.ExpCardOwned.filter(Boolean).length,count);
  t.click(previous);assert(effect.text.includes(e.ProtoCardName[e.PROTO_CARD_LAST-1]));
  e.ProtoLevel[0]=2;t.render();const hud=t.frame(e.UIExpeditionPrototype_HuntStatus);
  assert(hud.text.includes('몬스터 체력 390'));assert(hud.text.includes('5.0%'));
  e.ExpCardOwned.fill(false);e.ProtoHeadOwned.fill(false);t.render();assert(effect.text.includes('획득한 성장 카드 없음'));
  assert(!t.frame(previous).enabled);assert(!t.frame(next).enabled);assert.equal(e.UIExpeditionStats_CardPage,0);
});
check('사냥 사망 15초 부활, 사망 중 사건·각성 진행 차단과 골드 패널티 없음',()=>{
  const {e}=party();let alive=false,revives=0;e.UnitAlive=u=>u===0?alive:!!u&&!u.dead&&!u.removed;
  e.ReviveHero=()=>{alive=true;revives++;};e.ExpGold[0]=321;e.ProtoGrantCard(0,17);
  for(let i=0;i<59;i++)e.ProtoTick();assert.equal(revives,0);assert.equal(e.ProtoCardProgress[17],0);
  e.ProtoTick();assert.equal(revives,1);assert.equal(e.ExpGold[0],321);assert.equal(e.ProtoStage[0],0);
});
check('준비 완료 버튼은 AP 0에서만 활성화, 남은 시간 골드 한 번 지급, 전원 준비 또는 10분 뒤 합류',()=>{
  const t=party(2),e=t.e;e.ExpSeconds=400;request(e,0,2500);assert(!e.ProtoReady[0]);
  e.ProtoAP[0]=0;t.render();t.click(t.common(2500));assert(e.ProtoReady[0]);assert.equal(e.ExpGold[0],400);
  request(e,0,2500);assert.equal(e.ExpGold[0],400);e.ProtoTick();assert.equal(e.ExpState,e.EXP_HUNT);
  e.ProtoAP[1]=0;request(e,1,2500);e.ProtoTick();assert.equal(e.ExpState,e.EXP_BATTLE);assert.equal(e.ExpArena,5);
  assert(!e.ProtoPaused[0]);assert(!e.ProtoReady[0]);assert.equal(e.HuntUnits.filter(Boolean).length,0);
  const end=party().e;end.ProtoOffer(0);end.ProtoCandidates[end.ExpKey(0,1)]=49;request(end,0,2101);
  end.ExpSeconds=1;for(let i=0;i<4;i++)end.ProtoTick();assert.equal(end.ExpState,end.EXP_BATTLE);
  assert.equal(end.ProtoStage[0],0);assert.equal(end.ExpGold[0],150);assert.equal(end.ProtoAP[0],9);
});
check('원정 종료·새 출발 때 카드/필드/AP 초기화, 머리 도감만 유지 및 이탈 정리',()=>{
  const {e}=party();choose(e,0,1,1);e.ProtoGrantCard(0,15);e.ProtoLevel[0]=4;e.ProtoDensity[0]=8;e.ExpGold[0]=888;
  e.ProtoJoinBoss();e.ExpWon=false;e.BattleFinished();assert.equal(e.ExpState,e.EXP_RESULT);assert(!e.ExpPrototypeActive);
  assert.equal(e.HuntUnits.filter(Boolean).length,0);assert(e.MapRectCheck.slice(1,7).every(Boolean));
  assert(e.ProtoHeadKnown[1]);assert.equal(e.StashLoad(0,'원정.머리도감.1','0'),'1');
  e.eventPlayer=0;e.syncData='1|0|0|0';e.ProtoCodexSync();assert(e.ProtoHeadKnown[1]);
  request(e,0,2001);assert.equal(e.ExpState,e.EXP_HUNT);assert.equal(e.ExpGold[0],0);assert.equal(e.ProtoAP[0],10);
  assert.equal(e.ProtoLevel[0],1);assert.equal(e.ProtoDensity[0],4);assert.equal(e.ExpCardOwned.filter(Boolean).length,0);
  assert.equal(e.ProtoHeadCount[0],0);assert(!e.ProtoEventUsed[1]);assert.equal(e.ProtoKills[0],0);assert(e.ProtoHeadKnown[1]);
  e.eventPlayer=0;e.Leave();assert.equal(e.ExpState,e.EXP_RESULT);assert.equal(e.HuntUnits.filter(Boolean).length,0);
});
check('다른 로컬 플레이어의 클라이언트에서 같은 요청은 같은 사냥·사건·성장 상태를 만든다',()=>{
  const clients=[fresh(0,true),fresh(1,true)];
  for(const {e} of clients){
    e.online=[true,true,false,false];e.ProtoCodexSlot[0]=e.ProtoCodexSlot[1]=1;
    request(e,0,2001);request(e,1,2001);
    for(let i=0;i<4;i++)e.ProtoTick();
    choose(e,0,1,1);choose(e,1,6,1);choose(e,0,13,1);
    e.UnitHP[e.HuntUnits[1].id]=0;e.ProtoTick();
  }
  const snapshot=e=>({state:e.ExpState,seconds:e.ExpSeconds,ap:e.ProtoAP.slice(0,4),gold:e.ExpGold.slice(0,4),heads:e.ProtoHeadOwned.slice(),known:e.ProtoHeadKnown.slice(),used:e.ProtoEventUsed.slice(),cards:e.ExpCardOwned.slice(),kills:e.ProtoKills.slice(0,4),damage:e.ProtoDamageBonus.slice(0,4),hp:e.HuntUnits.filter(Boolean).map(u=>e.UnitHP[u.id])});
  assert.deepEqual(snapshot(clients[0].e),snapshot(clients[1].e));
});
check('사건 만료는 후보 AP 미소비 또는 무료 분기, 대기실 이탈은 남은 인원으로 새 흐름 출발',()=>{
  const {e}=party();e.ProtoOffer(0);e.ProtoDeadline[0]=1;for(let i=0;i<4;i++)e.ProtoTick();
  assert.equal(e.ProtoStage[0],0);assert.equal(e.ProtoAP[0],10);
  e.ProtoOffer(0);e.ProtoCandidates[1]=52;request(e,0,2101);e.ProtoDeadline[0]=1;
  for(let i=0;i<4;i++)e.ProtoTick();assert.equal(e.ProtoStage[0],3);assert.equal(e.ExpGold[0],80);assert.equal(e.ProtoAP[0],9);
  const lobby=fresh(0,true).e;lobby.online=[true,true,false,false];request(lobby,0,2001);assert.equal(lobby.ExpState,lobby.EXP_LOBBY);
  lobby.eventPlayer=1;lobby.Leave();assert.equal(lobby.ExpState,lobby.EXP_HUNT);assert.equal(lobby.ExpPlayers,1);
});
check('머리 후보는 AP 한 번으로 바로 성장, 4인 각자의 같은 지역 입구와 중복 패킷 차단',()=>{
  const t=party(4),e=t.e;
  for(let pid=0;pid<4;pid++){
    const id=pid+1;e.ProtoOffer(pid);e.ProtoCandidates[e.ExpKey(pid,1)]=id;
    assert(e.ProtoEventEligible(pid,id));assert(!e.ProtoEventEligible(pid,(pid+1)%4+1));
    const packet=''+e.ExpRun+'|'+e.ExpRevision+'|'+e.ExpOfferVersion[pid]+'|2101';
    request(e,pid,2101,packet);
    assert.equal(e.ProtoStage[pid],3);assert.equal(e.ProtoAP[pid],9);assert.equal(e.ProtoHeadCount[pid],1);
    assert.equal(e.ProtoDamageBonus[pid],5);assert(e.ExpCardOwned[e.ExpKey(pid,20)]);
    assert(e.ProtoOutcome[pid].includes('관련 사건 풀 개방 · 피해 +5%'));
    request(e,pid,2101,packet);request(e,pid,2201);
    assert.equal(e.ProtoAP[pid],9);assert.equal(e.ProtoDamageBonus[pid],5);
    assert(!e.ProtoEventEligible(pid,id));assert(e.ProtoEventEligible(pid,13));
  }
});
check('황금의 순간은 슬롯머신·솔글래드의 고정 카드, 확률 성공과 실패의 비용 및 후속 조건',()=>{
  for(const win of [true,false]){
    const {e}=party();e.ProtoGrantHead(0,2);e.ExpGold[0]=100;
    e.ProtoSelected[0]=25;assert(e.ProtoBranchText(0,1).includes('좋은꿈 슬롯머신'));
    assert(e.ProtoBranchText(0,1).includes('성공 50%'));
    e.ProtoOffer(0);e.ProtoCandidates[1]=25;request(e,0,2101);
    e.GetRandomInt=(a,b)=>win?a:b;request(e,0,2201);
    assert.equal(e.ExpGold[0],win?200:0);assert.equal(e.ExpCardOwned[41],win);
    assert(!e.ExpCardOwned[18]);assert.equal(e.ProtoEventHistory[e.ProtoStoryKey(0,25)],win?1:-1);
    assert.equal(e.ProtoEventEligible(0,86),win);assert.equal(e.ProtoAP[0],9);
    assert(e.ProtoOutcome[0].includes(win?'그림이 일렬로':'그림이 한 칸'));
  }
  const {e}=party();e.ProtoGrantHead(0,2);e.ExpGold[0]=99;
  e.ProtoOffer(0);e.ProtoCandidates[1]=25;request(e,0,2101);
  assert(!e.ProtoBranchAllowed(0,1));request(e,0,2201);assert.equal(e.ProtoStage[0],2);assert.equal(e.ExpGold[0],99);
  request(e,0,2202);assert(e.ExpCardOwned[43]);assert.equal(e.ExpGold[0],99);
  assert.equal(e.ProtoEventHistory[e.ProtoStoryKey(0,25)],2);assert(!e.ProtoEventEligible(0,86));
});
check('지역별 24개와 공통 24개의 관련 카드·서사·무료 기본 선택지, 모든 결과를 실제 실행',()=>{
  const {e}=party(),counts=[0,0,0,0],cards=new Set();
  for(let id=1;id<=e.PROTO_EVENT_COUNT;id++){
    if(e.ProtoEventKind[id]===0)continue;
    counts[e.ProtoEventHead[id]]++;assert(e.ProtoEventStory[id].length>=45);
    for(const choice of [1,2]){
      const key=e.ProtoChoiceKey(id,choice);assert(e.ProtoBranchLabel[key]);assert(e.ProtoBranchResult[key]);
      for(const card of [e.ProtoBranchCard[key],e.ProtoBranchCard2[key]]){
        if(!card)continue;
        assert(card>=e.PROTO_CARD_FIRST&&card<=e.PROTO_CARD_LAST);cards.add(card);
        assert.equal(e.ProtoCardHead[card],e.ProtoEventHead[id]);
      }
      if(choice===2){
        assert.equal(e.ProtoBranchCost[key],0);assert(e.ProtoBranchLevel[key]<=0);
        assert(e.ProtoBranchDensity[key]<=0);assert(e.ProtoBranchHealth[key]>=0);assert.equal(e.ProtoBranchChance[key],0);
      }
      // 리스크와 수입, 카드 중복 환산까지 포함해 실제 ProtoResolve를 실행한다.
      e.ProtoSelected[0]=id;e.ProtoStage[0]=2;e.ExpGold[0]=1000;
      e.ProtoLevel[0]=1;e.ProtoDensity[0]=4;e.GetRandomInt=(a,b)=>id===52?b:a;
      const beforeCards=e.ExpCardOwned.slice(),bonus=e.ProtoDamageBonus[0];
      let duplicateGold=0;
      for(const card of [e.ProtoBranchCard[key],e.ProtoBranchCard2[key]]){
        if(card&&beforeCards[card])duplicateGold+=100;
      }
      assert(e.ProtoBranchAllowed(0,choice),id+':'+choice);e.ProtoResolve(0,choice);
      assert.equal(e.ProtoStage[0],3);assert.equal(e.ProtoDeadline[0],30);
      assert.equal(e.ExpGold[0],1000-e.ProtoBranchCost[key]+e.ProtoBranchGold[key]+duplicateGold);
      assert.equal(e.ProtoDamageBonus[0],bonus+e.ProtoBranchDamage[key]);
      assert(e.ProtoOutcome[0].includes(e.ProtoBranchResult[key]));
    }
  }
  assert.deepEqual(counts,[24,24,24,24]);assert.equal(cards.size,36);
});
check('실제 체력 리스크는 생존 가능한 경우만 지불, 회복은 최대 체력을 넘지 않음',()=>{
  const {e}=party();let hp=2000;
  e.GetUnitState=(u,state)=>state===e.UNIT_STATE_MAX_LIFE?10000:hp;
  e.SetUnitState=(u,state,value)=>{if(state===e.UNIT_STATE_LIFE)hp=value;};
  e.ProtoGrantHead(0,1);e.ProtoSelected[0]=21;e.ProtoStage[0]=2;
  assert(!e.ProtoBranchAllowed(0,1));e.ProtoResolve(0,1);assert.equal(hp,2000);assert(!e.ExpCardOwned[21]);
  hp=2001;e.ProtoResolve(0,1);assert.equal(hp,1);assert(e.ExpCardOwned[21]);assert.equal(e.ProtoLevel[0],2);
  hp=9900;e.ProtoSelected[0]=26;e.ProtoStage[0]=2;e.ProtoResolve(0,2);assert.equal(hp,10000);
});
check('이야기는 선택/성공한 본인에게만 이어지고 재출발 때 64칸을 넘는 기록도 초기화',()=>{
  const {e}=party(2);for(let pid=0;pid<2;pid++)e.ProtoGrantHead(pid,2);
  assert(!e.ProtoEventEligible(0,85));assert(!e.ProtoEventEligible(1,85));
  choose(e,0,26,1);assert(e.ProtoEventEligible(0,85));assert(!e.ProtoEventEligible(1,85));
  assert(!e.ProtoEventEligible(1,26));choose(e,0,85,1);
  assert.equal(e.ProtoEventHistory[e.ProtoStoryKey(0,85)],1);
  assert.equal(e.ProtoEventHistory[e.ProtoStoryKey(1,85)],0);
  e.ProtoEventHistory[e.ProtoStoryKey(3,108)]=2;
  e.ProtoJoinBoss();e.ExpWon=false;e.BattleFinished();
  request(e,0,2001);request(e,1,2001);
  assert.equal(e.ProtoEventHistory[e.ProtoStoryKey(0,26)],0);
  assert.equal(e.ProtoEventHistory[e.ProtoStoryKey(0,85)],0);
  assert.equal(e.ProtoEventHistory[e.ProtoStoryKey(3,108)],0);
  assert(!e.ProtoEventEligible(0,85));
});
check('중복은 표시한 100골드로만 교환, 다른 작품 추첨과 사건 결과 채팅 겹침 없음',()=>{
  const {e}=party(),notices=[];e.DisplayTimedTextToPlayer=(p,x,y,t,text)=>notices.push(text);
  e.ProtoGrantHead(0,2);e.ProtoGrantCard(0,43);notices.length=0;e.ProtoSelected[0]=25;
  assert(e.ProtoBranchText(0,2).includes('솔글래드 이미 보유 · 골드 +100'));
  e.ProtoStage[0]=2;e.ProtoResolve(0,2);
  assert.equal(e.ExpGold[0],100);assert.equal(e.ExpCardOwned.filter(Boolean).length,1);assert.equal(notices.length,0);
  e.ProtoStage[0]=2;e.ProtoSelected[0]=30;e.ProtoResolve(0,1);
  assert(e.ExpCardOwned[30]);assert.equal(notices.length,0);
});
check('사건 화면은 불투명 배경, 짙은 선택 글씨와 버튼 안에 들어가는 텍스트 영역',()=>{
  const t=party(),e=t.e;e.ProtoChoices[0]=4;e.ProtoOffer(0);t.render();
  const root=t.frame(e.ExpUIRoots[9]);
  assert([...t.frames.values()].some(f=>f.relative===e.ExpUIRoots[9]&&f.texture==='war3mapImported\\UI_Upgrade_Background.tga'));
  for(const action of [2101,2102,2103,2104,2300]){
    const button=t.common(action),index=e.ExpUIButtons.indexOf(button),frame=t.frame(button),label=t.frame(e.ExpUIButtonLabels[index]);
    assert(label.text.startsWith(frame.enabled?'|cff163848':'|cff425c6b'));
    assert(-label.y+label.h<=frame.h);assert(label.x+label.w<=frame.w);
  }
  e.ProtoCandidates[1]=1;t.render();const index=e.ExpUIButtons.indexOf(t.common(2101));
  assert(t.frame(e.ExpUIButtonLabels[index]).text.includes('즉시 획득 · 피해 +5%'));
  t.click(t.common(2101));assert.equal(e.ProtoStage[0],3);
  assert(!t.frame(e.ExpUIButtons[e.UIExpeditionPrototype_BranchButtons[1]]).shown);
  assert(t.frame(t.common(2400)).shown);
  assert(root.y-root.h>=.12);
});
check('사건 후보와 분기 UI 실제 동기화, 최대 4개 클릭 영역·화면 경계·준비 HUD 분리',()=>{
  const t=party(),e=t.e;e.ProtoChoices[0]=4;e.ProtoOffer(0);t.render();assert.deepEqual(t.roots(),[9]);
  const buttons=[1,2,3,4].map(i=>t.frame(t.common(2100+i))),root=t.frame(e.ExpUIRoots[9]);
  for(const b of buttons){assert(root.y+b.y-b.h>=.12);assert(root.x+b.x>=0);assert(root.x+b.x+b.w<=.8);}
  for(let i=1;i<buttons.length;i++)assert(buttons[i-1].y-buttons[i-1].h>buttons[i].y);
  const hud=t.frame(e.UIExpeditionPrototype_HuntHUD);assert(hud.y-hud.h>root.y);
  t.event(t.common(2101),4,1);assert.equal(t.packets.length,0);
  e.ProtoCandidates[e.ExpKey(0,1)]=49;t.render();
  t.click(t.common(2101));assert.equal(e.ProtoStage[0],2);assert.deepEqual(t.roots(),[9]);
  t.click(t.common(2202));assert.equal(e.ProtoStage[0],3);t.click(t.common(2400));assert.deepEqual(t.roots(),[]);
});
console.log(`${checks} prototype scenario groups passed. Static JASS/mock checks only; Warcraft rendering, actual multiplayer and server persistence remain untested.`);
