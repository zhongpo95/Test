// 실제 개인 사냥 JASS와 UI 콜백을 모의 실행하여 사건·성장·합류의 경계를 검증한다.
const assert = require('node:assert/strict');
const {fresh:rawFresh} = require('./check-expedition-ui.cjs');
function fresh(...args){const t=rawFresh(...args);if(args[1])t.click(t.common(-98));return t;}
const {fresh: combat} = require('./check-attack-potion.cjs');
const {environment} = require('./check-expedition.cjs');
function card(e,key){const id=e.ProtoCardKey.indexOf(key);assert(id>=e.PROTO_CARD_FIRST,'카드 없음 '+key);return id;}
function scene(e,key){const id=e.ProtoEventKey.indexOf(key);assert(id>0,'사건 없음 '+key);return id;}
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
  e.GetItemTier=()=>2;e.ProtoHeadKnown[e.ExpKey(0,1)]=true;t.render();request(e,0,2011);
  assert.equal(e.ProtoStartHead[0],1);t.start();assert.equal(e.ProtoHeadCount[0],1);
  assert.equal(e.ProtoAP[0],20);assert.equal(e.ExpSeconds,1200);assert.equal(e.ExpGold[0],0);
  assert.equal(e.ExpCardOwned.filter(Boolean).length,0);
  assert.equal(e.ProtoStat(0,e.PROTO_STAT_ATTACK),3);assert(e.ProtoEventEligible(0,scene(e,'school_circle')));assert(!e.ProtoEventEligible(0,scene(e,'abydos_sand_supply')));
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
  assert(e.HuntUnits.slice(1,9).every(Boolean));assert.equal(e.HuntUnits[9],null);
  for(let slot=1;slot<=8;slot++){const u=e.HuntUnits[slot];assert.equal(e.UnitHPMAX[u.id],300);assert.equal(e.UnitArm[u.id],0);assert.equal(u.engineArmor,0);assert.equal(e.ProtoHuntOwner[u.id],1);assert(!u.abilities.has('Aatk'));}
  const old=e.HuntUnits[1];e.UnitHP[old.id]=0;e.ProtoHuntUpdate(0);
  assert(old.removed);assert.notEqual(e.HuntUnits[1],old);assert.equal(e.ExpGold[0],10);assert.equal(e.ProtoKills[0],1);
  assert.equal(e.UnitArm[e.HuntUnits[1].id],0);assert.equal(e.HuntUnits[1].engineArmor,0);
  assert.equal(e.ExpCardOwned.filter(Boolean).length,0);assert.equal(e.ProtoAP[0],20);
});
check('일반 전투 근접·원거리·위험 몬스터 방어력 0, 보스 방어력 유지',()=>{
  const {env:e}=environment(['System/ExpeditionCombat.j'],{
    ExpEnemy:[], ExpEnemyBoss:[], ExpMember:[false,false,false,false], ClearWarning:()=>{}, UpdateHealth:()=>{},
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
  assert.equal(hits.find(h=>h.source===u).damage,200);
});
check('HeroDeal에서 체력바와 치명적 타격의 사망을 즉시 반영하고 각성 피해는 실제 체력만 집계',()=>{
  const {e}=combat(),life=[],kills=[];e.ProtoStatsInit();e.ProtoCatalogInit();e.ExpPrototypeActive=true;e.ExpMember[0]=true;e.ExpState=e.EXP_HUNT;
  e.ProtoHuntOwner[2]=1;e.ExpEnemy[2]=true;e.UnitHP[2]=300;e.UnitHPMAX[2]=300;
  e.SetUnitState=(unit,state,value)=>life.push({unit,state,value});e.KillUnit=unit=>kills.push(unit);
  e.HeroDeal(1,0,2,1,false,false,false,false);assert.equal(e.UnitHP[2],180);
  assert(Math.abs(life.at(-1).value-6000)<1e-8);assert.equal(kills.length,0);
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
  assert.equal(e.ExpSeconds,1199);assert.equal(e.HuntSeconds[0],0);assert.equal(e.HuntSeconds[1],1);
  assert.equal(e.ProtoKills[0],0);assert.equal(e.ExpGold[0],0);
  e.ProtoResume(0);e.ProtoHuntUpdate(0);assert.equal(e.ProtoKills[0],1);
});
check('사건 선택만 AP 소모, 500/600골드 리롤과 다음 화면 500골드 복귀',()=>{
  const t=party(),e=t.e;e.ExpGold[0]=2000;e.ProtoOffer(0);t.render();
  assert.equal(e.ProtoChoices[0],3);t.click(t.common(2300));assert.equal(e.ExpGold[0],1500);assert.equal(e.ProtoAP[0],20);
  t.click(t.common(2300));assert.equal(e.ExpGold[0],900);assert.equal(e.ProtoRerolls[0],2);
  const id=e.ProtoCandidates[e.ExpKey(0,1)];t.click(t.common(2101));assert(e.ProtoEventUsed[id]);assert.equal(e.ProtoAP[0],20-e.ProtoEventAPCost[id]);
  if(e.ProtoStage[0]===2)t.click(t.common(2202));const after=e.ExpGold[0];request(e,0,2202);assert.equal(e.ExpGold[0],after);
  t.click(t.common(2400));assert(!e.ProtoPaused[0]);assert.equal(e.ProtoRerolls[0],0);
  e.ProtoOffer(0);assert.equal(500+e.ProtoRerolls[0]*100,500);assert(!e.ProtoEventEligible(0,id));
});
check('표시만 된 사건은 미소비, 동시 선택은 파티 중복 차단과 오래된 패킷 거부',()=>{
  const {e}=party(2);e.ProtoGrantHead(0,1);e.ProtoGrantHead(1,1);e.ProtoOffer(0);e.ProtoOffer(1);const id=scene(e,'school_circle');
  e.ProtoCandidates[e.ExpKey(0,1)]=id;e.ProtoCandidates[e.ExpKey(1,1)]=id;
  assert(!e.ProtoEventUsed[id]);const old=`${e.ExpRun}|${e.ExpRevision}|${e.ExpOfferVersion[1]}|2101`;
  request(e,0,2101);assert(e.ProtoEventUsed[id]);assert.equal(e.ProtoAP[0],19);
  assert(![1,2].some(i=>e.ProtoCandidates[e.ExpKey(1,i)]===id));
  request(e,1,2101,old);assert.equal(e.ProtoAP[1],20);assert.equal(e.ProtoStage[1],1);
});
check('최소 대기 없이 12처치로 사건을 열고 시간·정체만으로는 열지 않으며 AP 0은 사냥만 계속',()=>{
  const kills=party().e;kills.ProtoKills[0]=12;
  for(let i=0;i<4;i++)kills.ProtoTick();assert.equal(kills.ProtoStage[0],1);
  kills.ProtoResume(0);for(let i=0;i<60*4;i++)kills.ProtoTick();assert.equal(kills.ProtoStage[0],0);
  kills.ProtoKills[0]+=12;for(let i=0;i<4;i++)kills.ProtoTick();assert.equal(kills.ProtoStage[0],1);
  const stalled=party().e;stalled.HuntSeconds[0]=100;stalled.ProtoLastKill[0]=0;
  for(let i=0;i<120*4;i++)stalled.ProtoTick();assert.equal(stalled.ProtoStage[0],0);
  const {e}=party();e.ProtoAP[0]=0;e.ProtoKills[0]=100;
  for(let i=0;i<60*4;i++)e.ProtoTick();assert.equal(e.ProtoStage[0],0);
  const before=e.ExpGold[0];e.UnitHP[e.HuntUnits[1].id]=0;e.ProtoTick();assert.equal(e.ExpGold[0],before+10);
});
check('사건 필드 변경은 기존 몬스터에도 HP 비율을 보존하고 적용하며 상한에서 공짜 위험 보상 차단',()=>{
  const {e}=party();e.ProtoHuntUpdate(0);const u=e.HuntUnits[1];e.UnitHP[u.id]=150;
  e.ProtoGrantHead(0,2);const id=scene(e,'axel_request');
  choose(e,0,id,2);assert.equal(e.ProtoLevel[0],2);assert.equal(e.UnitHPMAX[u.id],390);assert.equal(e.UnitHP[u.id],195);
  assert(e.ProtoOutcome[0].includes('적 단계 1 → 2'));assert(e.ProtoOutcome[0].includes('몬스터 체력 300 → 390'));
  assert(e.ProtoOutcome[0].includes('2.0% → 2.5%'));
  e.ProtoSelected[0]=id;e.ProtoLevel[0]=5;assert(!e.ProtoBranchAllowed(0,2));
  // 활성 콘텐츠에서는 제거할 수 옵션의 하위 호환만 가상 입력으로 검사한다.
  e.ProtoBranchDensity[e.ProtoChoiceKey(id,1)]=2;
  e.ProtoLevel[0]=2;e.ProtoStage[0]=2;e.ProtoResolve(0,1);assert.equal(e.ProtoDensity[0],10);e.ProtoHuntUpdate(0);assert(e.HuntUnits[10]);
  assert(e.ProtoOutcome[0].includes('동시 몬스터 수 8 → 10'));
  e.ProtoDensity[0]=9;e.ProtoSelected[0]=id;assert(!e.ProtoBranchAllowed(0,1));
});
check('실제 카드는 처치·피해·시간으로 각성하지 않고 기본 효과와 사건 후보 상한을 유지',()=>{
  const {e}=party();e.ProtoKills[0]=100;e.ProtoDamage[0]=50000;e.ProtoSafeTime[0]=100;
  const kill=card(e,'axel_vanir'),hit=card(e,'shiro_analysis'),safe=card(e,'saber_opening');
  for(const id of [kill,hit,safe]){e.ProtoGrantCard(0,id);assert.equal(e.ProtoCardProgress[e.ExpKey(0,id)],0);}
  for(let i=0;i<45;i++)e.ProtoKill(0);e.ProtoEvolutionTick(0);assert(!e.ProtoEvolved[e.ExpKey(0,kill)]);
  e.ProtoHuntOwner[100]=1;e.ProtoRecordDamage(0,100,6000);e.ProtoEvolutionTick(0);assert(!e.ProtoEvolved[e.ExpKey(0,hit)]);
  for(let i=0;i<240;i++)e.ProtoEvolutionTick(0);assert(!e.ProtoEvolved[e.ExpKey(0,safe)]);
  const defense=environment(['Data/Data_Expedition.j','Data/Data_Prototype.j','System/DamageEffectBoss.j'],{
    GetOwningPlayer:u=>u,UnitDamageTarget:(s,t,rate)=>{defense.lastDamage=rate;},CustomStun:{Stun2:()=>{}},
  }).env;
  // 별도 실제 BossDeal 실행. 기본 피해 감소와 보호막 처리는 유지한다.
  defense.ProtoStatsInit();defense.ProtoCatalogInit();defense.ExpPrototypeActive=true;defense.ExpMember[0]=true;defense.ExpState=defense.EXP_HUNT;
  defense.ExpCardOwned[safe]=true;defense.ProtoEvolutionRegister(0,safe);defense.ProtoStatAddCard(0,card(defense,'saber_guard'),false);
  defense.UnitSD[0]=100;
  defense.BossDeal(99,0,50,false);assert.equal(defense.ProtoCardProgress[safe],0);assert.equal(defense.UnitSD[0],51);
  defense.ProtoPaused[0]=true;defense.BossDeal(99,0,50,false);assert.equal(defense.UnitSD[0],51);
  e.ProtoGrantCard(0,card(e,'axel_luna'));e.ProtoGrantCard(0,card(e,'abydos_ayane'));
  assert.equal(e.ProtoChoices[0],3);e.ProtoGrantCard(0,card(e,'common_holo'));e.ProtoGrantHead(0,1);e.ProtoOffer(0);assert(e.ProtoCandidates[e.ExpKey(0,4)]>0);
  e.ProtoGrantCard(0,card(e,'rin_disarm'));assert.equal(e.ExpCardPenetration(0),.08);
});
check('실제 HeroDeal에서 정지·타인 사냥터 피해 차단, 실제 피해만 기록하고 각성 진행 없음',()=>{
  const {e}=combat();e.ProtoStatsInit();e.ProtoCatalogInit();e.ExpPrototypeActive=true;e.ExpMember[0]=true;e.ExpState=e.EXP_HUNT;
  const id=card(e,'shiro_analysis');e.ProtoHuntOwner[2]=1;e.ExpEnemy[2]=true;e.ExpCardOwned[id]=true;e.ProtoEvolutionRegister(0,id);e.UnitHP[2]=30;
  e.HeroDeal(1,0,2,1,false,false,false,false);assert.equal(e.ProtoDamage[0],30);assert.equal(e.ProtoCardProgress[id],0);
  e.UnitHP[2]=100;e.ProtoPaused[0]=true;e.HeroDeal(1,0,2,1,false,false,false,false);assert.equal(e.UnitHP[2],100);
  e.ProtoPaused[0]=false;e.ProtoHuntOwner[2]=2;e.HeroDeal(1,0,2,1,false,false,false,false);assert.equal(e.UnitHP[2],100);
});
check('보유 카드 격자와 상세·강화·각성 정보, 난이도 HUD 갱신',()=>{
  const t=party(),e=t.e;for(let id=e.PROTO_CARD_FIRST;id<e.PROTO_CARD_FIRST+25;id++)e.ProtoGrantCard(0,id);
  e.ExpUIOpen(e.EXP_UI_CARDS);t.render();
  assert.equal(e.UIPrototypeCards_Count,25);assert(t.visible(e.ExpUIButtons[e.UIPrototypeCards_Cells[25]]));
  assert(!t.frame(e.ExpUIButtons[e.UIPrototypeCards_Cells[26]]).enabled);
  t.event(e.ExpUIButtons[e.UIPrototypeCards_Cells[21]],2);t.render();
  assert(t.frame(e.UIPrototypeCards_TooltipText).text.includes(e.ProtoCardName[e.PROTO_CARD_FIRST+20]));
  e.ProtoLevel[0]=2;t.render();assert(t.frame(e.UIExpeditionPrototype_HuntStatus).text.includes('2.5%'));
});

check('사냥 사망 15초 부활, 사망 중 사건·각성 진행 차단과 골드 패널티 없음',()=>{
  const {e}=party();let alive=false,revives=0;e.UnitAlive=u=>u===0?alive:!!u&&!u.dead&&!u.removed;
  const safe=card(e,'saber_opening');e.ReviveHero=()=>{alive=true;revives++;};e.ExpGold[0]=321;e.ProtoGrantCard(0,safe);
  for(let i=0;i<59;i++)e.ProtoTick();assert.equal(revives,0);assert.equal(e.ProtoCardProgress[safe],0);
  e.ProtoTick();assert.equal(revives,1);assert.equal(e.ExpGold[0],321);assert.equal(e.ProtoStage[0],0);
});
check('준비 완료 버튼은 AP 0에서만 활성화, 남은 시간 골드 한 번 지급, 전원 준비 또는 20분 뒤 합류',()=>{
  const t=party(2),e=t.e;e.ExpSeconds=400;request(e,0,2500);assert(!e.ProtoReady[0]);
  e.ProtoAP[0]=0;t.render();t.click(t.common(2500));assert(e.ProtoReady[0]);assert.equal(e.ExpGold[0],400);
  request(e,0,2500);assert.equal(e.ExpGold[0],400);e.ProtoTick();assert.equal(e.ExpState,e.EXP_HUNT);
  e.ProtoAP[1]=0;request(e,1,2500);e.ProtoTick();assert.equal(e.ExpState,e.EXP_BATTLE);assert.equal(e.ExpArena,5);
  assert(!e.ProtoPaused[0]);assert(!e.ProtoReady[0]);assert.equal(e.HuntUnits.filter(Boolean).length,0);
  const end=party().e;end.ProtoGrantHead(0,2);end.ProtoOffer(0);end.ProtoCandidates[end.ExpKey(0,1)]=scene(end,'axel_shop_ledger');request(end,0,2101);
  end.ExpSeconds=1;for(let i=0;i<4;i++)end.ProtoTick();assert.equal(end.ExpState,end.EXP_BATTLE);
  assert.equal(end.ProtoStage[0],0);assert.equal(end.ExpGold[0],0);assert.equal(end.ProtoAP[0],19);
  assert(end.ExpCardOwned[end.ExpKey(0,card(end,'axel_vanir'))]);assert.equal(end.ProtoLevel[0],2);
});
check('원정 종료·새 출발 때 카드/필드/AP 초기화, 머리 도감만 유지 및 이탈 정리',()=>{
  const {e}=party();choose(e,0,1,1);e.ProtoGrantCard(0,15);e.ProtoLevel[0]=4;e.ProtoDensity[0]=8;e.ExpGold[0]=888;
  e.ProtoJoinBoss();e.ExpWon=false;e.BattleFinished();assert.equal(e.ExpState,e.EXP_RESULT);assert(!e.ExpPrototypeActive);
  assert.equal(e.HuntUnits.filter(Boolean).length,0);assert(e.MapRectCheck.slice(1,7).every(Boolean));
  assert(e.ProtoHeadKnown[1]);assert.equal(e.StashLoad(0,e.PROTO_SAVE_PREFIX+'머리도감.'+e.ProtoHeadKey[1],'0'),'1');
  e.eventPlayer=0;e.syncData='1|0|0|0';e.ProtoCodexSync();assert(e.ProtoHeadKnown[1]);
  request(e,0,2001);assert.equal(e.ExpState,e.EXP_HUNT);assert.equal(e.ExpGold[0],0);assert.equal(e.ProtoAP[0],20);
  assert.equal(e.ProtoLevel[0],1);assert.equal(e.ProtoDensity[0],8);assert.equal(e.ExpCardOwned.filter(Boolean).length,0);
  assert.equal(e.ProtoHeadCount[0],0);assert(!e.ProtoEventUsed[1]);assert.equal(e.ProtoKills[0],0);assert(e.ProtoHeadKnown[1]);
  e.eventPlayer=0;e.Leave();assert.equal(e.ExpState,e.EXP_RESULT);assert.equal(e.HuntUnits.filter(Boolean).length,0);
});
check('다른 로컬 플레이어의 클라이언트에서 같은 요청은 같은 사냥·사건·성장 상태를 만든다',()=>{
  const clients=[fresh(0,true),fresh(1,true)];
  for(const {e} of clients){
    e.online=[true,true,false,false];e.ProtoCodexSlot[0]=e.ProtoCodexSlot[1]=1;
    request(e,0,2001);request(e,1,2001);
    for(let i=0;i<4;i++)e.ProtoTick();
    choose(e,0,1,1);choose(e,1,6,1);choose(e,0,scene(e,'school_circle'),2);
    e.UnitHP[e.HuntUnits[1].id]=0;e.ProtoTick();
  }
  const snapshot=e=>({state:e.ExpState,seconds:e.ExpSeconds,ap:e.ProtoAP.slice(0,4),gold:e.ExpGold.slice(0,4),heads:e.ProtoHeadOwned.slice(),known:e.ProtoHeadKnown.slice(),used:e.ProtoEventUsed.slice(),cards:e.ExpCardOwned.slice(),stats:e.ProtoStatValues.slice(),pending:e.ProtoEvolutionFirst.slice(),links:e.ProtoEvolutionNext.slice(),progress:e.ProtoCardProgress.slice(),evolved:e.ProtoEvolved.slice(),kills:e.ProtoKills.slice(0,4),damage:e.ProtoDamageBonus.slice(0,4),hp:e.HuntUnits.filter(Boolean).map(u=>e.UnitHP[u.id])});
  assert.deepEqual(snapshot(clients[0].e),snapshot(clients[1].e));
});
check('사건 만료는 후보 AP 미소비 또는 유효 분기, 대기실 이탈은 남은 인원으로 새 흐름 출발',()=>{
  const {e}=party();e.ProtoOffer(0);e.ProtoDeadline[0]=1;for(let i=0;i<4;i++)e.ProtoTick();
  assert.equal(e.ProtoStage[0],0);assert.equal(e.ProtoAP[0],20);
  e.ProtoGrantHead(0,2);e.ExpGold[0]=80;e.ProtoOffer(0);e.ProtoCandidates[1]=scene(e,'axel_priest_supply');request(e,0,2101);e.ProtoDeadline[0]=1;
  const potions=e.GetItemCharges(e.PlayerItem1[0]);
  for(let i=0;i<4;i++)e.ProtoTick();assert.equal(e.ProtoStage[0],3);assert.equal(e.ExpGold[0],0);assert.equal(e.ProtoAP[0],19);
  assert(e.ExpCardOwned[e.ExpKey(0,card(e,'axel_aqua_supply'))]);assert.equal(e.GetItemCharges(e.PlayerItem1[0]),potions);
  const lobby=fresh(0,true).e;lobby.online=[true,true,false,false];request(lobby,0,2001);assert.equal(lobby.ExpState,lobby.EXP_LOBBY);
  lobby.eventPlayer=1;lobby.Leave();assert.equal(lobby.ExpState,lobby.EXP_HUNT);assert.equal(lobby.ExpPlayers,1);
});
check('머리 후보는 AP 무료로 바로 성장, 4인 각자의 같은 지역 입구와 중복 패킷 차단',()=>{
  const t=party(4),e=t.e;
  for(let pid=0;pid<4;pid++){
    const id=pid+1;e.ProtoOffer(pid);e.ProtoCandidates[e.ExpKey(pid,1)]=id;
    assert(e.ProtoEventEligible(pid,id));assert(!e.ProtoEventEligible(pid,(pid+1)%4+1));
    const packet=''+e.ExpRun+'|'+e.ExpRevision+'|'+e.ExpOfferVersion[pid]+'|2101';
    request(e,pid,2101,packet);
    assert.equal(e.ProtoStage[pid],3);assert.equal(e.ProtoAP[pid],20);assert.equal(e.ProtoHeadCount[pid],1);
    assert.equal(e.ProtoStat(pid,e.PROTO_STAT_ATTACK),6);assert(e.ExpCardOwned[e.ExpKey(pid,card(e,'shiro_analysis'))]);
    assert(e.ProtoOutcome[pid].includes('공격력 증가 +3.0%'));
    request(e,pid,2101,packet);request(e,pid,2201);
    assert.equal(e.ProtoAP[pid],20);assert.equal(e.ProtoStat(pid,e.PROTO_STAT_ATTACK),6);
    assert(!e.ProtoEventEligible(pid,id));assert(e.ProtoEventEligible(pid,scene(e,'school_circle')));
  }
});
check('13개 머리 획득 후 4인 동시 다음 사건은 12처치에서 한 번의 조건 검사로 재개',()=>{
  for(let head=1;head<=13;head++){
    const t=party(4),e=t.e;
    for(let pid=0;pid<4;pid++){
      choose(e,pid,(head-1)*4+pid+1);assert.equal(e.ProtoAP[pid],20);assert(!e.ProtoPaused[pid]);
      e.HuntSeconds[pid]=0;e.ProtoLastKill[pid]=0;e.ProtoKills[pid]=12;
    }
    const original=e.ProtoEventEligible,counts=[0,0,0,0];
    e.ProtoEventEligible=(pid,id)=>{counts[pid]++;assert(counts[pid]<=e.PROTO_EVENT_COUNT,'후보별 전체 조건 재검사');return original(pid,id);};
    for(let i=0;i<3;i++)e.ProtoTick();for(let pid=0;pid<4;pid++)assert.equal(e.ProtoStage[pid],0);
    e.ProtoTick();
    for(let pid=0;pid<4;pid++){
      assert.equal(e.ProtoStage[pid],1,head+' '+pid);assert(e.ProtoPaused[pid]);assert.equal(e.ProtoAP[pid],20);
      assert.equal(counts[pid],e.PROTO_EVENT_COUNT);
      const candidates=e.ProtoCandidates.slice(e.ExpKey(pid,1),e.ExpKey(pid,1)+e.ProtoChoices[pid]);
      assert(candidates.every(id=>id>0&&original(pid,id)));assert.equal(new Set(candidates).size,candidates.length);
    }
    e.ProtoEventEligible=original;t.render();assert.deepEqual(t.roots(),[9]);assert(!t.visible(e.UIExpeditionPrototype_HuntHUD));
  }
});
check('머리 획득 결과를 접고 만료시켜도 사냥 재개와 다음 사건 표시가 이어짐',()=>{
  const t=party(),e=t.e;e.ProtoOffer(0);e.ProtoCandidates[1]=17;t.render();t.click(t.common(2101));
  assert.equal(e.ProtoStage[0],3);t.click(e.ExpUIButtons[e.UIExpeditionCommon_PanelToggles[9]]);assert.deepEqual(t.roots(),[]);
  const original=e.ProtoEventEligible;let count=0;
  e.ProtoEventEligible=(pid,id)=>{count++;assert(count<=e.PROTO_EVENT_COUNT);return original(pid,id);};
  for(let i=0;i<60*4;i++)e.ProtoTick();assert.equal(e.ProtoStage[0],0);assert(!e.ProtoPaused[0]);
  e.ProtoKills[0]+=12;for(let i=0;i<4;i++)e.ProtoTick();assert.equal(e.ProtoStage[0],1);assert.equal(count,e.PROTO_EVENT_COUNT);
  e.ProtoEventEligible=original;t.render();assert.deepEqual(t.roots(),[9]);assert(t.visible(e.ExpUIButtons[e.UIExpeditionPrototype_CandidateButtons[1]]));
});
check('추첨은 기존 80·12·3·1 가중치를 유지하고 후보 중복과 비어 있는 목록을 처리',()=>{
  const {e}=party(),ids=[1,e.ProtoEventRequired.findIndex(x=>x>0),e.ProtoEventHead.findIndex((h,id)=>h>0&&e.ProtoEventKind[id]===1&&e.ProtoEventRequired[id]===0),e.ProtoEventHead.findIndex((h,id)=>id>0&&h===0&&e.ProtoEventKind[id]===1)];
  assert.equal(new Set(ids).size,4);assert(ids.every(id=>id>0));e.ProtoChoices[0]=4;
  const allowed=new Set(ids),counts=new Map(ids.map(id=>[id,0]));e.ProtoEventEligible=(pid,id)=>allowed.has(id);
  for(let ticket=1;ticket<=96;ticket++){
    let rolls=0;e.GetRandomInt=(low,high)=>{const roll=rolls++===0?ticket:1;assert(roll>=low&&roll<=high);return roll;};
    e.ProtoOffer(0);const candidates=e.ProtoCandidates.slice(1,5);assert.equal(rolls,4);assert.deepEqual(new Set(candidates),allowed);
    counts.set(candidates[0],counts.get(candidates[0])+1);
  }
  assert.deepEqual(ids.map(id=>counts.get(id)),[80,12,3,1]);
  allowed.clear();e.GetRandomInt=()=>assert.fail('빈 후보 목록에서 난수 호출');e.ProtoOffer(0);
  assert.equal(e.ProtoStage[0],0);assert(!e.ProtoPaused[0]);assert.deepEqual(e.ProtoCandidates.slice(1,5),[0,0,0,0]);assert.equal(e.ProtoAP[0],20);
});
check('사건 화면은 불투명 배경, 짙은 선택 글씨와 버튼 안에 들어가는 텍스트 영역',()=>{
  const t=party(),e=t.e;e.ProtoGrantHead(0,1);e.ProtoChoices[0]=4;e.ProtoOffer(0);t.render();
  const root=t.frame(e.ExpUIRoots[9]);
  assert([...t.frames.values()].some(f=>f.relative===e.ExpUIRoots[9]&&f.texture==='war3mapImported\\UI_Arcana_Paper.tga'));
  for(const action of [2101,2102,2103,2104,2300]){
    const button=t.common(action),index=e.ExpUIButtons.indexOf(button),frame=t.frame(button),label=t.frame(e.ExpUIButtonLabels[index]);
    assert(label.text.startsWith(frame.enabled?'|cff163848':'|cff425c6b'));
    assert(-label.y+label.h<=frame.h);assert(label.x+label.w<=frame.w);
  }
  e.ProtoHeadOwned[1]=false;e.ProtoCandidates[1]=1;t.render();const index=e.ExpUIButtons.indexOf(t.common(2101));
  assert(t.frame(e.ExpUIButtonLabels[index]).text.includes('머리 카드 획득'));
  assert(t.frame(e.UIExpeditionPrototype_CandidateRegion[1]).text.includes('지역 개방'));
  assert(t.frame(e.UIExpeditionPrototype_CandidateBonus[1]).text.includes('공격력 증가 +3.0%'));
  t.click(t.common(2101));assert.equal(e.ProtoStage[0],3);
  assert(!t.frame(e.ExpUIButtons[e.UIExpeditionPrototype_BranchButtons[1]]).shown);
  assert(t.frame(t.common(2400)).shown);
  assert.equal(root.x,0);assert.equal(root.y,.6);assert.equal(root.w,.8);assert.equal(root.h,.6);
});
check('사건 후보와 분기 UI 실제 동기화, 최대 4개 클릭 영역·화면 경계·준비 HUD 분리',()=>{
  const t=party(),e=t.e;e.ProtoGrantHead(0,1);e.ProtoChoices[0]=4;e.ProtoOffer(0);t.render();assert.deepEqual(t.roots(),[9]);
  const buttons=[1,2,3,4].map(i=>t.frame(t.common(2100+i))),root=t.frame(e.ExpUIRoots[9]);
  for(const b of buttons){assert(root.y+b.y-b.h>=0);assert(root.x+b.x>=0);assert(root.x+b.x+b.w<=.8);}
  const overlap=(a,b)=>a.x<b.x+b.w&&b.x<a.x+a.w&&-a.y<-b.y+b.h&&-b.y<-a.y+a.h;
  for(let i=0;i<buttons.length;i++)for(let j=i+1;j<buttons.length;j++)assert(!overlap(buttons[i],buttons[j]));
  const hud=e.UIExpeditionPrototype_HuntHUD;assert(!t.visible(hud));
  const info=()=>t.frame(e.UIExpeditionPrototype_EventInfo).text;
  assert(info().includes('사냥 '+e.ExpSeconds+'초'));assert(info().includes('선택 '+e.ProtoDeadline[0]+'초'));
  t.event(t.common(2101),4,1);assert.equal(t.packets.length,0);
  e.ProtoGrantHead(0,1);e.ProtoCandidates[e.ExpKey(0,1)]=scene(e,'school_circle');t.render();
  t.click(t.common(2101));assert.equal(e.ProtoStage[0],2);assert.deepEqual(t.roots(),[9]);
  t.click(t.common(2202));assert.equal(e.ProtoStage[0],3);t.click(t.common(2400));assert.deepEqual(t.roots(),[]);assert(t.visible(hud));
});
check('후보 2·3·4개는 같은 크기로 가운데 정렬, 장식과 하단 글씨 경계 및 최신 후보 표시',()=>{
  const t=party(),e=t.e;
  const parts=['CandidateRegion','CandidateTitle','CandidateIcon','CandidateIntro','CandidateBonus','CandidateFooter'];
  for(const count of [2,3,4]){
    e.ProtoChoices[0]=count;e.ProtoOffer(0);
    e.ProtoCandidates[1]=scene(e,'temple_gate');e.ProtoCandidates[2]=9;
    if(count>2)e.ProtoCandidates[3]=scene(e,'axel_shop_ledger');
    if(count>3)e.ProtoCandidates[4]=scene(e,'school_circle');
    t.render();
    for(let i=1;i<=count;i++){
      const id=e.ProtoCandidates[e.ExpKey(0,i)],button=t.frame(t.common(2100+i));
      assert.equal(button.h,.386);assert.equal(button.w,.174);assert.equal(button.y,-.138);
      const index=e.UIExpeditionPrototype_CandidateButtons[i],background=t.frame(e.UIExpeditionCommon_ButtonBackdrops[index]);
      assert.equal(background.w,button.w);assert.equal(background.h,button.h);
      assert(t.frame(e.UIExpeditionPrototype_CandidateTitle[i]).text.includes(e.ProtoEventName[id]));
      assert(t.frame(e.UIExpeditionPrototype_CandidateIntro[i]).text.includes(e.ProtoEventIntro[id]));
      assert.equal(t.frame(e.UIExpeditionPrototype_CandidateIcon[i]).texture,e.ProtoEventIcon[id]);
      for(const part of parts){
        const f=t.frame(e['UIExpeditionPrototype_'+part][i]);if(!f.shown)continue;
        assert.equal(f.parent,button.id);assert(f.x>=0&&f.x+f.w<=button.w+.00001);
        assert(-f.y>=0&&-f.y+f.h<=button.h+.00001);
        if(f.type==='TEXT'){assert.equal(f.enabled,false);assert.equal(f.vertical,0);assert.equal(f.horizontal,0);}
      }
      assert.equal(t.frame(e.UIExpeditionPrototype_CandidateBonus[i]).shown,e.ProtoEventKind[id]===0);
      const action=t.frame(e.ExpUIButtonLabels[index]),footer=t.frame(e.UIExpeditionPrototype_CandidateFooter[i]);
      assert(action.id>footer.id,'하단 글자는 배경 다음에 생성해야 함');assert.equal(action.enabled,false);
      assert(-footer.y<=-action.y&&-action.y+action.h<=-footer.y+footer.h);
      if(e.ProtoEventKind[id]===0){
        const icon=t.frame(e.UIExpeditionPrototype_CandidateIcon[i]),intro=t.frame(e.UIExpeditionPrototype_CandidateIntro[i]);
        assert(-icon.y+icon.h<=-intro.y);
      }
    }
    const first=t.frame(t.common(2101)),last=t.frame(t.common(2100+count));
    assert(Math.abs(first.x-(.8-last.x-last.w))<.00001,'후보 행의 좌우 여백이 다름');
    for(let i=2;i<=count;i++)assert(t.frame(t.common(2100+i-1)).x+first.w<t.frame(t.common(2100+i)).x);
    for(let i=count+1;i<=4;i++)assert(!t.visible(e.ExpUIButtons[e.UIExpeditionPrototype_CandidateButtons[i]]));
  }
  assert(t.frame(e.UIExpeditionPrototype_CandidateRegion[2]).text.includes('지역 개방'));
  assert(t.frame(e.UIExpeditionPrototype_CandidateBonus[2]).text.includes('오쿠소라 아야네'));
  e.ExpGold[0]=1100;t.render();const ap=e.ProtoAP[0];
  const stale=`${e.ExpRun}|${e.ExpRevision}|${e.ExpOfferVersion[0]}|2101`;
  t.click(t.common(2300));assert.equal(e.ExpGold[0],600);assert.equal(e.ProtoAP[0],ap);
  request(e,0,2101,stale);assert.equal(e.ProtoStage[0],1);assert.equal(e.ProtoAP[0],ap);
  const id=e.ProtoCandidates[1];assert(t.frame(e.UIExpeditionPrototype_CandidateTitle[1]).text.includes(e.ProtoEventName[id]));
  t.event(t.common(2101),2);const index=e.UIExpeditionPrototype_CandidateButtons[1];
  assert(t.frame(e.UIExpeditionCommon_ButtonBackdrops[index]).texture.endsWith('SheetHover.tga'));
  t.event(t.common(2101),3);assert(t.frame(e.UIExpeditionCommon_ButtonBackdrops[index]).texture.endsWith('Sheet.tga'));
  for(let id=1;id<=e.PROTO_EVENT_COUNT;id++){
    assert(e.ProtoEventIntro[id]);assert(e.ProtoEventStory[id].length>=e.ProtoEventIntro[id].length);assert(e.ProtoEventIcon[id]);
  }
});
check('전체 사건 화면의 이야기 유지, 비용 부족·선택 결과·접기·성장 카드 왕복',()=>{
  const t=party(),e=t.e;e.ProtoGrantHead(0,1);const id=scene(e,'school_circle');e.ProtoOffer(0);e.ProtoCandidates[1]=id;e.ExpGold[0]=0;t.render();
  const candidates=e.ProtoCandidates.slice(),version=e.ExpOfferVersion[0];
  t.click(t.common(-e.EXP_UI_STATS));assert.deepEqual(t.roots(),[e.EXP_UI_STATS]);
  assert(t.visible(e.UIExpeditionPrototype_HuntHUD));t.click(e.ExpUIButtons[e.UIExpeditionCommon_PanelToggles[e.EXP_UI_STATS]]);t.click(t.common(-98));assert.deepEqual(t.roots(),[9]);
  assert(!t.visible(e.UIExpeditionPrototype_HuntHUD));assert.deepEqual(e.ProtoCandidates.slice(),candidates);assert.equal(e.ExpOfferVersion[0],version);
  t.click(t.common(2101));assert.equal(e.ProtoStage[0],2);
  assert(t.visible(e.UIExpeditionPrototype_StoryPanel));assert(!t.visible(e.UIExpeditionPrototype_OutcomePanel));
  const story=t.frame(e.UIExpeditionPrototype_StoryText).text;
  assert(story.includes(e.ProtoEventStory[id]));assert(t.frame(e.UIExpeditionPrototype_StoryTitle).text.includes(e.ProtoEventName[id]));
  const first=e.UIExpeditionPrototype_BranchButtons[1];assert(!t.frame(e.ExpUIButtons[first]).enabled);
  assert(t.frame(e.ExpUIButtonLabels[first]).text.includes('200골드'));
  assert(t.frame(e.UIExpeditionPrototype_BranchAction[1]).text.includes('선택 불가'));
  const toggle=e.ExpUIButtons[e.UIExpeditionCommon_PanelToggles[9]];
  t.click(toggle);assert.deepEqual(t.roots(),[]);assert(t.visible(e.UIExpeditionPrototype_HuntHUD));
  t.click(toggle);assert.deepEqual(t.roots(),[9]);assert.equal(t.frame(e.UIExpeditionPrototype_StoryText).text,story);
  t.click(t.common(2202));assert.equal(e.ProtoStage[0],3);
  assert(t.visible(e.UIExpeditionPrototype_OutcomePanel));assert(t.frame(e.UIExpeditionPrototype_OutcomeText).text.includes(e.ProtoOutcome[0]));
  assert.equal(t.frame(e.UIExpeditionPrototype_StoryText).text,story);assert(!t.visible(e.ExpUIButtons[first]));
  assert(!t.visible(e.ExpUIButtons[e.UIExpeditionPrototype_RerollButton]));
  for(const pid of [0,1]){
    e.localPlayer=pid;e.PickCheck[pid]=true;e.ExpMember[pid]=true;e.UIExpeditionCommon_SeenRevision=-1;t.render();
    assert.equal(t.visible(e.ExpUIRoots[9]),pid===0);
  }
  e.localPlayer=0;e.UIExpeditionCommon_SeenRevision=-1;t.render();t.click(t.common(2400));assert.equal(e.ProtoStage[0],0);assert(t.visible(e.UIExpeditionPrototype_HuntHUD));
});
console.log(`${checks} prototype scenario groups passed. Static JASS/mock checks only; Warcraft rendering, actual multiplayer and server persistence remain untested.`);
