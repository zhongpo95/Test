// 기본 보상과 추가 사건의 순서, 비공개 카드 예약, 중복 요청 및 구역별 제외를 검증한다.
const assert = require('node:assert/strict');
const {environment} = require('./check-expedition.cjs');
const files=['Data/Data_Expedition.j','Data/Data_ExpeditionEvents.j','Data/Data_ExpeditionRewards.j',
  'System/ExpeditionEffects.j','System/SaveLoad.j','System/Expedition.j'];
let checks=0;
const check=(name,fn)=>{fn();checks++;console.log('PASS '+name);};
function fresh(){const {env:e}=environment(files);e.ExpMember[0]=true;e.ExpPlayers=1;e.ExpNode=2;e.Enter(e.EXP_REWARD);return e;}
const grade=kind=>kind<=6?1:kind<=12?2:kind<=19?3:4;
function offer(e,kind,pid=0){
  e.ReleaseReward(pid);
  const random=e.GetRandomInt,ranges=[[1,6],[7,12],[13,19],[20,23]],range=ranges[grade(kind)-1];
  const valid=Array.from({length:range[1]-range[0]+1},(_,i)=>range[0]+i).filter(id=>e.RewardValid(pid,id));
  assert(valid.includes(kind));let index=0;
  e.GetRandomInt=(a,b)=>{
    if(b===10000)return [1,5501,9001,9951][grade(kind)-1];
    if(index<valid.length)return valid[index++]===kind?1:b;
    return random(a,b);
  };
  e.RollOffers(pid);e.GetRandomInt=random;assert.equal(e.ExpRewardKind[pid],kind);
}
const visibleSeen=e=>e.ExpCardSeen.slice(0,256);
check('기본 세 선택 모두 먼저 지급하고 사건은 확정 뒤 처음 추첨',()=>{
  for(const action of [1,2,3]){
    const e=fresh();offer(e,1);assert.equal(e.ExpEventGrade[0],0);assert.equal(e.ExpEventCandidate[0],0);assert(!e.ExpEventUsed.some(Boolean));
    const a=e.ExpArcanaA[0],level=e.ExpArcanaLevel[0];e.GetRandomInt=(a,b)=>a;e.ExpAction(0,action);
    assert(e.ExpRewardTaken[0]);assert(!e.ExpDone[0]);assert.equal(e.ExpEventCandidate[0],4);assert.equal(e.ExpChoiceSeconds(0),40);
    assert.equal(e.ExpPoints[0],action===1?5:0);assert.equal(e.ExpGold[0],action===3?150:0);assert.equal(e.ExpArcana[a],action===2?level:0);
    const before=[e.ExpPoints[0],e.ExpGold[0],e.ExpArcana.slice(0,64)];e.ExpAction(0,3);
    assert.deepEqual([e.ExpPoints[0],e.ExpGold[0],e.ExpArcana.slice(0,64)],before);assert(e.ExpDone[0]);
  }
});
check('현재 유효한 19개 즉시 항목의 실제 지급 수량과 중복 없는 카드 묶음',()=>{
  for(const kind of [1,2,3,4,5,6,7,8,9,10,11,12,13,15,16,17,18,22,23]){
    const e=fresh();offer(e,kind);const cards=[e.ExpRewardCardA[0],e.ExpRewardCardB[0]].filter(Boolean),potion=e.ExpRewardPotion[0];
    assert.equal(e.ApplyReward(0),true);e.ReleaseReward(0);
    const gold={1:150,7:250,13:500,23:1200},crit={3:75,10:150,17:250,22:300},swift={4:75,11:150,18:250,22:300};
    assert.equal(e.ExpGold[0],gold[kind]||0);assert.equal(e.ExpFixedCrit[0],crit[kind]||0);assert.equal(e.ExpFixedSwift[0],swift[kind]||0);
    assert.equal(e.ExpPoints[0],kind===16?15:0);assert.equal(new Set(cards).size,cards.length);
    for(const card of cards){assert(e.ExpCardSeen[card]);assert(e.ExpCardOwned[card]);}
    const expected=[2,2,2];if(kind===5)expected[0]+=2;if(kind===6)expected[potion-1]+=3;if(kind===12)expected.fill(4);
    assert.deepEqual([e.PlayerItem1[0].charges,e.PlayerItem2[0].charges,e.PlayerItem3[0].charges],expected);
  }
});
check('카드 이름 비공개 예약은 등장 기록을 소모하지 않고 리롤·다른 선택 시 반환',()=>{
  const e=fresh();offer(e,9);const cards=[e.ExpRewardCardA[0],e.ExpRewardCardB[0]];
  assert.equal(e.CardsLeft(0,1,6),4);assert(!e.ExpCardSeen.some(Boolean));
  for(const card of cards){assert(e.ExpCardReserved[card]);assert(!e.ExpRewardText(0).includes(e.ExpCardName(card)));}
  const seen=visibleSeen(e);e.ExpGold[0]=100;e.ExpAction(0,100);assert.deepEqual(visibleSeen(e),seen);assert.equal(e.ExpGold[0],0);
  offer(e,9);e.GetRandomInt=(a,b)=>a;e.ExpAction(0,1);assert(!e.ExpCardReserved.some(Boolean));assert.deepEqual(visibleSeen(e),seen);
});
check('카드 예약은 다른 추첨과 충돌하지 않고 실제 선택 때만 공개 소모',()=>{
  const e=fresh();offer(e,9);const cards=[e.ExpRewardCardA[0],e.ExpRewardCardB[0]],drawn=[];
  for(let i=0;i<4;i++)drawn.push(e.DrawCard(0,1));assert.equal(e.DrawCard(0,1),0);
  for(const card of cards)assert(!drawn.includes(card));e.GetRandomInt=(a,b)=>a;e.ExpAction(0,3);
  assert(e.ExpRewardTaken[0]);for(const card of cards){assert(e.ExpCardOwned[card]);assert(e.ExpCardSeen[card]);assert(!e.ExpCardReserved[card]);}
});
check('보상 재고·포인트 한도·미구현 등급·잔여 성장 조건을 같은 등급 내에서 제외',()=>{
  const e=fresh();for(let i=1;i<=10;i++)e.ExpCardSeen[i]=true;e.ExpPoints[0]=26;
  for(const kind of [2,8,9,14,15,16,19,20,21])assert(!e.RewardValid(0,kind));
  for(const [roll,allowed] of [[1,[1,3,4,5,6]],[5501,[7,10,11,12]],[9001,[13,17,18]],[9951,[22,23]]]){
    const random=e.GetRandomInt;e.GetRandomInt=(a,b)=>b===10000?roll:random(a,b);
    for(let i=0;i<40;i++){e.RollOffers(0);assert(allowed.includes(e.ExpRewardKind[0]));}e.GetRandomInt=random;
  }
  e.ExpPoints[0]=25;assert(e.RewardValid(0,16));offer(e,16);e.ExpPoints[0]=26;assert(!e.ApplyReward(0));assert.equal(e.ExpPoints[0],26);
});
check('새 각인과 카드 획득을 반영한 뒤 정화·교환 사건의 자격 판단',()=>{
  const e=fresh();e.GetRandomInt=(a,b)=>b===10000?5501:b<=2?1:b;e.ExpAction(0,2);
  assert.equal(e.ExpEventCandidate[0],7);assert(e.ExpEventTargetPenalty[0]>=50);assert(e.ExpArcana[e.ExpEventTargetPenalty[0]]>0);
  const c=fresh();offer(c,2);const card=c.ExpRewardCardA[0];c.GetRandomInt=(a,b)=>b===10000?5501:b;c.ExpAction(0,3);
  assert.equal(c.ExpEventCandidate[0],5);assert.equal(c.ExpEventTargetCard[0],card);assert(c.ExpCardOwned[card]);
});
check('기본 보상과 추가 사건의 독립 등급, 사건 소진 대체도 기본 보상 유지',()=>{
  const e=fresh();offer(e,1);e.GetRandomInt=(a,b)=>b===10000?9951:a;e.ExpAction(0,3);
  assert.equal(e.ExpRewardGrade[0],1);assert.equal(e.ExpEventGrade[0],4);assert.equal(e.ExpGold[0],1350);
  assert(e.ExpEventResolved[0]);assert.equal(e.ExpEventCandidate[0],0);assert(!e.ExpEventUsed.some(Boolean));
  e.ExpAction(0,3);assert(e.ExpDone[0]);assert(!e.ExpEventUsed[0]);assert.equal(e.ExpGold[0],1350);
});
check('리롤·기본 선택 중복 패킷이 추가 사건의 선택으로 해석되지 않음',()=>{
  const e=fresh();offer(e,1);e.GetRandomInt=(a,b)=>a;const packet=`${e.ExpRun}|${e.ExpRevision}|${e.ExpOfferVersion[0]}|3`;
  e.syncData=packet;e.OnSync();const version=e.ExpOfferVersion[0];e.OnSync();assert(!e.ExpDone[0]);assert.equal(e.ExpGold[0],150);assert.equal(e.ExpOfferVersion[0],version);
  e.syncData=`${e.ExpRun}|${e.ExpRevision}|${version}|100`;e.OnSync();assert.equal(e.ExpGold[0],150);assert.equal(e.ExpOfferVersion[0],version);
});
check('파티원이 기본 선택과 사건을 따로 진행해도 사건 중복과 조기 이동 없음',()=>{
  const e=fresh();e.ExpMember[1]=true;e.ExpPlayers=2;e.Enter(e.EXP_REWARD);e.GetRandomInt=(a,b)=>a;e.ExpAction(0,1);
  const first=e.ExpEventCandidate[0];assert(!e.ExpRewardTaken[1]);e.ExpAction(0,3);e.Tick();assert.equal(e.ExpState,e.EXP_REWARD);
  e.ExpAction(1,1);assert(e.ExpEventCandidate[1]!==first);e.Tick();assert.equal(e.ExpState,e.EXP_REWARD);
  e.ExpAction(1,3);e.Tick();assert.equal(e.ExpState,e.EXP_MOVE);assert.equal(e.ExpSeconds,6);
});
check('팀 전용 대상 구역은 기본 보상 뒤 개인 사건을 추가하지 않음',()=>{
  for(const node of [6,8,13,15,20]){
    const e=fresh();e.ExpNode=node;e.ExpAction(0,1);assert.equal(e.ExpPoints[0],5);assert(e.ExpRewardTaken[0]);assert(e.ExpDone[0]);
    assert.equal(e.ExpEventDeadline[0],0);assert.equal(e.ExpEventCandidate[0],0);assert(!e.ExpEventUsed.some(Boolean));
  }
});
check('이탈·원정 종료·화면 변경은 비공개 예약을 반환하고 기본 보상 반복 지급 없음',()=>{
  for(const exit of [e=>e.Leave(),e=>e.Finish(false),e=>e.Enter(e.EXP_SHOP)]){
    const e=fresh();offer(e,9);exit(e);assert(!e.ExpCardReserved.some(Boolean));
  }
  const e=fresh();e.ExpPoints[0]=40;e.GetRandomInt=(a,b)=>a;e.ExpAction(0,1);assert.equal(e.ExpGold[0],100);e.ExpAction(0,100);assert.equal(e.ExpGold[0],100);
});
check('실패로 계속되는 원정은 보상과 사건, 라이프 소진·최종보스는 추가 사건 없음',()=>{
  for(const [life,step,reward] of [[100,2,true],[1,2,false],[100,4,false]]){
    const e=fresh();e.ExpState=e.EXP_BATTLE;e.ExpStep=step;e.ExpWon=false;e.ExpLife=life;e.ExpProgress=0;e.BattleFinished();
    assert.equal(e.ExpState,reward?e.EXP_REWARD:e.EXP_RESULT);assert.equal(e.ExpEventDeadline[0],0);
    if(reward){e.GetRandomInt=(a,b)=>a;e.ExpAction(0,1);assert(e.ExpEventDeadline[0]>0);}
  }
});
check('로컬 플레이어가 다른 두 클라이언트의 보상·사건 순서와 공유 결과 일치',()=>{
  const clients=[0,1].map(pid=>{const e=fresh();e.ExpMember[1]=true;e.ExpPlayers=2;e.localPlayer=pid;e.Enter(e.EXP_REWARD);return e;});
  for(const e of clients)for(const [pid,action] of [[1,3],[0,2],[1,3],[0,3]]){
    e.eventPlayer=pid;e.syncData=`${e.ExpRun}|${e.ExpRevision}|${e.ExpOfferVersion[pid]}|${action}`;e.OnSync();
  }
  for(const field of ['ExpGold','ExpArcana','ExpCardOwned','ExpCardSeen','ExpCardReserved','ExpEventUsed','ExpEventGrade','ExpDone'])assert.deepEqual(clients[0][field],clients[1][field]);
});
console.log(`${checks} reward separation groups passed. Mock execution only; Warcraft multiplayer remains untested.`);
