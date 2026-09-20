// 사건의 거래·정산·중복 입력과 조우의 전투 조건을 실제 JASS 함수로 모의 검증한다.
const assert = require('node:assert/strict');
const {environment} = require('./check-expedition.cjs');
const files = ['Data/Data_Expedition.j','Data/Data_ExpeditionEvents.j','System/ExpeditionEffects.j','System/SaveLoad.j','System/Expedition.j'];
let checks = 0;
const check = (name, fn) => {fn();checks++;console.log('PASS ' + name);};
function fresh(id, combat = false) {
  const {env:e} = environment(combat ? [...files,'System/ExpeditionCombat.j'] : files);
  e.ExpMember[0]=true;e.ExpPlayers=1;e.ExpArena=1;e.ExpStep=2;e.ExpState=e.EXP_REWARD;
  e.ExpGold[0]=500;e.ExpEventCandidate[0]=id;e.ExpEventReservation[id]=1;e.ExpEventDeadline[0]=40;
  e.PrepareEvent(0);
  return e;
}
function snapshot(e) {
  return JSON.stringify([e.ExpGold,e.ExpArcana,e.ExpCardOwned,e.ExpCardSeen,
    e.PlayerItem1,e.PlayerItem2,e.PlayerItem3,e.ExpEventResolved,e.ExpOfferVersion,e.ExpLife]);
}
check('아홉 사건의 두 선택은 개인 자원만 변경하고 결과 확인 전까지 대기',()=>{
  for(let id=1;id<=9;id++)for(const choice of [1,2]){
    const e=fresh(id);e.ExpCardOwned[1]=e.ExpCardSeen[1]=true;e.ExpArcana[50]=2;e.PrepareEvent(0);
    const other=JSON.stringify([e.ExpGold[1],e.ExpCardOwned.slice(64,128),e.PlayerItem1[1],e.PlayerItem2[1],e.PlayerItem3[1]]);
    assert.equal(e.ExpEventUnavailable(0,choice),'');e.ExpAction(0,choice);
    assert(e.ExpEventResolved[0]);assert(e.ExpEventOutcome[0].length>10);assert(!e.ExpDone[0]);assert.equal(e.ExpChoiceSeconds(0),12);
    assert.equal(JSON.stringify([e.ExpGold[1],e.ExpCardOwned.slice(64,128),e.PlayerItem1[1],e.PlayerItem2[1],e.PlayerItem3[1]]),other);
    assert.equal(e.ExpLife,100);const after=snapshot(e);e.ExpAction(0,choice);assert.equal(snapshot(e),after);
    e.ExpAction(0,3);assert(e.ExpDone[0]);assert.equal(e.ExpEventDeadline[0],0);assert.equal(e.ExpEventReservation[id],0);
  }
});
check('골드 부족·물약 부족·카드 소진은 차감과 선택 종료 없이 거부',()=>{
  for(const [id,choice] of [[2,1],[2,2],[6,2],[7,1],[8,1]]){
    const e=fresh(id);e.ExpGold[0]=0;e.ExpArcana[50]=2;e.PrepareEvent(0);
    assert(e.ExpEventUnavailable(0,choice));const before=snapshot(e);e.ExpAction(0,choice);assert.equal(snapshot(e),before);
  }
  const e=fresh(3);e.PlayerItem1[0].charges=0;assert(e.ExpEventUnavailable(0,1));e.ExpAction(0,1);assert.equal(e.ExpGold[0],500);
  for(const [id,choice,first,last] of [[2,1,1,6],[5,1,7,10],[9,1,7,9]]){
    const e=fresh(id);e.ExpCardOwned[1]=true;e.PrepareEvent(0);
    for(let i=first;i<=last;i++)e.ExpCardSeen[i]=true;
    assert(e.ExpEventUnavailable(0,choice));const before=snapshot(e);e.ExpAction(0,choice);assert.equal(snapshot(e),before);
  }
});
check('거래별 실제 차감·보상과 바이바인 충전 보너스',()=>{
  let e=fresh(2);e.ExpAction(0,1);assert.equal(e.ExpGold[0],400);assert.equal(e.ExpCardOwned.slice(1,7).filter(Boolean).length,1);
  e=fresh(2);e.ExpCardOwned[12]=true;e.ExpAction(0,2);assert.equal(e.ExpGold[0],450);assert.equal(e.PlayerItem2[0].charges,4);
  e=fresh(3);e.ExpCardOwned[12]=true;e.ExpAction(0,1);assert.equal(e.ExpGold[0],700);assert.equal(e.PlayerItem1[0].charges,1);
  for(const choice of [1,2]){
    e=fresh(5);e.ExpCardOwned[1]=e.ExpCardSeen[1]=true;e.PrepareEvent(0);e.ExpAction(0,choice);
    assert(!e.ExpCardOwned[1]);assert(e.ExpCardSeen[1]);assert.equal(e.ExpGold[0],choice===1?500:750);
    assert.equal(e.ExpCardOwned.slice(7,11).filter(Boolean).length,choice===1?1:0);
  }
  e=fresh(9);e.ExpAction(0,1);assert.equal(e.ExpCardOwned.slice(7,11).filter(Boolean).length,2);
  e=fresh(9);e.ExpCardOwned[12]=true;e.ExpAction(0,2);assert.equal(e.ExpGold[0],1000);
  for(const items of [e.PlayerItem1,e.PlayerItem2,e.PlayerItem3])assert.equal(items[0].charges,4);
});
check('금고는 공개된 50% 경계와 정확한 순이익·손실 적용',()=>{
  for(const roll of [1,50,51,100]){
    const e=fresh(6);let calls=0;e.GetRandomInt=(a,b)=>{assert.equal(a,1);assert.equal(b,100);calls++;return roll;};
    e.ExpAction(0,2);assert.equal(e.ExpGold[0],roll<=50?800:400);assert.equal(calls,1);
    e.ExpAction(0,2);assert.equal(calls,1);
  }
});
check('각인 최대치와 실제 +1 미리보기, 전부 포화된 경우 비용 없는 대안',()=>{
  const e=fresh(4);e.LoadInteger=(table,id)=>id===3?2:id<50?3:5;e.PrepareEvent(0);
  assert.equal(e.ExpEventTargetArcana[0],3);assert(e.ExpEventUnavailable(0,1));
  e.LoadInteger=(table,id)=>id===3?2:id<50?3:id===52?4:5;e.PrepareEvent(0);
  assert.equal(e.ExpEventTargetPenalty[0],52);assert.equal(e.ExpEventArcanaGain(0),1);assert(e.ExpEventOptionText(0,1).includes('각인3 +1'));
  e.ExpAction(0,1);assert.equal(e.ExpArcana[3],1);assert.equal(e.ExpArcana[52],1);
  const capped=fresh(4);capped.LoadInteger=()=>5;capped.PrepareEvent(0);assert(capped.ExpEventUnavailable(0,1));
  capped.ExpAction(0,2);assert.equal(capped.ExpGold[0],580);
});
check('중복·오래된 동기화 요청과 결과 확인 12초 만료',()=>{
  const e=fresh(6);e.ExpRun=2;e.ExpRevision=3;e.ExpOfferVersion[0]=4;e.GetRandomInt=()=>50;
  e.syncData='2|3|4|2';e.OnSync();const after=snapshot(e);e.OnSync();assert.equal(snapshot(e),after);
  e.syncData='2|3|5|2';e.OnSync();assert.equal(snapshot(e),after);
  for(let i=0;i<11;i++)e.Tick();assert(!e.ExpDone[0]);e.Tick();assert(e.ExpDone[0]);assert.equal(e.NextState,e.EXP_SHOP);
});
check('아무 선택도 하지 않은 사건 만료는 무료 떠나기',()=>{
  for(let id=1;id<=9;id++){
    const e=fresh(id),before=snapshot(e);e.ExpEventDeadline[0]=1;e.Tick();
    assert.equal(snapshot(e),before);assert(e.ExpDone[0]);assert.equal(e.ExpEventCandidate[0],0);
  }
});
check('작업대는 표시된 각인 +1만 지급하고 감소 각인과 타인 자원은 유지',()=>{
  const e=fresh(8);const target=e.ExpEventTargetArcana[0];e.ExpAction(0,1);
  assert.equal(e.ExpGold[0],350);assert.equal(e.ExpArcana[target],1);assert.equal(e.ExpArcana.slice(50,54).reduce((a,b)=>a+b),0);
  const capped=fresh(8);capped.LoadInteger=()=>3;capped.PrepareEvent(0);assert(capped.ExpEventUnavailable(0,1));
  capped.ExpAction(0,2);assert.equal(capped.ExpGold[0],600);
});
check('조우별 체력·시간 조건과 보스전 독립',()=>{
  for(const encounter of [1,2,3])for(const boss of [false,true]){
    const e=fresh(1,true);e.ExpPlayers=2;e.ExpEncounter=encounter;e.ExpState=e.EXP_BATTLE;e.ExpCombatStart(boss);
    assert.equal(e.EnemyMaximum[1],boss?24000000:encounter===2?1100000:900000);
    assert.equal(e.ExpBattleLimit,boss?360:encounter===3?90:120);
  }
});
check('조우 승리 추가 보상은 일반전에만 적용하고 카드 소진은 골드 대체',()=>{
  for(const encounter of [1,2,3]){
    const e=fresh(1);e.ExpEncounter=encounter;e.ExpState=e.EXP_BATTLE;e.ExpWon=true;e.BattleFinished();
    assert.equal(e.ExpGold[0],encounter===2?700:600);assert.equal(e.ExpCardOwned.slice(1,7).filter(Boolean).length,encounter===3?1:0);
    const boss=fresh(1);boss.ExpEncounter=encounter;boss.ExpStep=4;boss.ExpState=boss.EXP_BATTLE;boss.ExpWon=true;boss.BattleFinished();
    assert.equal(boss.ExpGold[0],600);assert(!boss.ExpCardOwned.some(Boolean));
  }
  const e=fresh(1);e.ExpEncounter=3;e.ExpState=e.EXP_BATTLE;e.ExpWon=true;
  for(let i=1;i<=6;i++)e.ExpCardSeen[i]=true;e.BattleFinished();assert.equal(e.ExpGold[0],750);
});
check('파티 동률은 우회하고 과반수만 전투, 미응답도 우회 표로 처리',()=>{
  for(const encounter of [1,2,3])for(const mode of ['tie','majority','timeout']){
    const e=fresh(1);e.ExpMember[1]=true;e.ExpPlayers=2;e.Enter(e.EXP_VOTE);e.ExpEncounter=encounter;
    e.ExpAction(0,1);if(mode!=='timeout')e.ExpAction(1,mode==='majority'?1:2);else e.ExpSeconds=1;
    e.Tick();assert.equal(e.NextState,mode==='majority'?e.EXP_BATTLE:e.EXP_REWARD);
    if(mode!=='majority'){
      assert.equal(e.ExpGold[0],encounter===1?500:encounter===2?550:560);
      assert.equal(e.ExpGold[1],encounter===1?0:encounter===2?50:60);
      if(encounter===1)for(const pid of [0,1])assert.equal(e.PlayerItem1[pid].charges+e.PlayerItem2[pid].charges+e.PlayerItem3[pid].charges,7);
    }
  }
});
check('서로 다른 로컬 플레이어에서도 동일한 사건 요청의 공유 상태 일치',()=>{
  const clients=[0,1].map(local=>{const e=fresh(6);e.localPlayer=local;e.ExpMember[1]=true;return e;});
  for(const e of clients){e.syncData='0|0|0|2';e.OnSync();e.OnSync();}
  assert.equal(snapshot(clients[0]),snapshot(clients[1]));
});
console.log(`${checks} event/encounter groups passed. Mock execution only; real multiplayer and rendering remain untested.`);
