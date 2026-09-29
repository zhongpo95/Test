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
  request(e,pid,2101);assert.equal(e.ProtoStage[pid],2);
  request(e,pid,2200+branch);assert.equal(e.ProtoStage[pid],3);
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
  for(let slot=1;slot<=4;slot++){const u=e.HuntUnits[slot];assert.equal(e.UnitHPMAX[u.id],300);assert.equal(e.ProtoHuntOwner[u.id],1);assert(!u.abilities.has('Aatk'));}
  const old=e.HuntUnits[1];e.UnitHP[old.id]=0;e.ProtoHuntUpdate(0);
  assert(old.removed);assert.notEqual(e.HuntUnits[1],old);assert.equal(e.ExpGold[0],10);assert.equal(e.ProtoKills[0],1);
  assert.equal(e.ExpCardOwned.filter(Boolean).length,0);assert.equal(e.ProtoAP[0],10);
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
  const gold=e.ExpGold[0];assert.equal(gold,250);e.ProtoSelected[0]=51;e.ProtoLevel[0]=5;assert(!e.ProtoBranchAllowed(0,1));
  e.ProtoLevel[0]=2;choose(e,0,50,1);assert.equal(e.ProtoDensity[0],6);e.ProtoHuntUpdate(0);assert(e.HuntUnits[6]);
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
    choose(e,0,1,1);choose(e,1,5,1);choose(e,0,13,1);
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
check('사건 후보와 분기 UI 실제 동기화, 최대 4개 클릭 영역·화면 경계·준비 HUD 분리',()=>{
  const t=party(),e=t.e;e.ProtoChoices[0]=4;e.ProtoOffer(0);t.render();assert.deepEqual(t.roots(),[9]);
  const buttons=[1,2,3,4].map(i=>t.frame(t.common(2100+i))),root=t.frame(e.ExpUIRoots[9]);
  for(const b of buttons){assert(root.y+b.y-b.h>=.12);assert(root.x+b.x>=0);assert(root.x+b.x+b.w<=.8);}
  for(let i=1;i<buttons.length;i++)assert(buttons[i-1].y-buttons[i-1].h>buttons[i].y);
  const hud=t.frame(e.UIExpeditionPrototype_HuntHUD);assert(hud.y-hud.h>root.y);
  t.event(t.common(2101),4,1);assert.equal(t.packets.length,0);
  t.click(t.common(2101));assert.equal(e.ProtoStage[0],2);assert.deepEqual(t.roots(),[9]);
  t.click(t.common(2202));assert.equal(e.ProtoStage[0],3);t.click(t.common(2400));assert.deepEqual(t.roots(),[]);
});
console.log(`${checks} prototype scenario groups passed. Static JASS/mock checks only; Warcraft rendering, actual multiplayer and server persistence remain untested.`);
