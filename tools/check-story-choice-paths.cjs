// 선택으로 열린 서브의 정산·포기·비용·동기화와 작품 선택을 실제 JASS 모의 실행으로 검증한다.
'use strict';
const assert=require('node:assert/strict');
const {fresh}=require('./check-expedition-ui.cjs');
const t=fresh(0,true),e=t.e;t.start();
const head=e.ProtoHeadKey.indexOf('penacony');
const fixedHead=e.ProtoHeadKey.indexOf('dungeon_meshi');
assert(fixedHead>0);assert.equal(e.PROTO_TEST_START_HEAD,fixedHead);
const lobby=fresh(0,true);assert.equal(lobby.e.ProtoStartingHead(0),fixedHead);
lobby.e.ProtoAction(0,2011);assert.equal(lobby.e.ProtoStartingHead(0),fixedHead);
lobby.e.ProtoAction(0,2003);assert.equal(lobby.e.ProtoStartingHead(0),fixedHead);
lobby.e.ProtoAction(0,2010+head);assert.equal(lobby.e.ProtoStartingHead(0),fixedHead);
lobby.start();assert(lobby.e.ProtoHeadOwned[lobby.e.ExpKey(0,fixedHead)]);
assert(!lobby.e.ProtoHeadOwned[lobby.e.ExpKey(0,head)]);
lobby.e.ProtoOffer(0);assert.equal(lobby.e.ProtoEventKey[lobby.e.ProtoCandidates[lobby.e.ExpKey(0,1)]],'dm_main_01');

const id=k=>e.ProtoEventKey.indexOf(k), main=id('hsr_main_04'), side=id('hsr_masked_stage'), child=id('hsr_remembered_exit'), next=id('hsr_main_05');
const state=(event,p=0)=>e.ProtoSideState[e.ProtoStoryKey(p,event)];
function reset(){e.ResetPid=0;e.ProtoResetRunCards();e.ProtoStatReset(0);e.ProtoHeadCount[0]=0;e.ProtoAP[0]=100;e.ExpGold[0]=10000;e.ProtoReady[0]=false;e.ProtoStage[0]=0;e.ExpState=e.EXP_HUNT;e.ProtoGrantHead(0,head);e.ProtoMainProgress[e.ExpKey(0,head)]=3;}
function offer(){e.ProtoOffer(0);return Array.from({length:e.ProtoOfferCount[0]},(_,i)=>e.ProtoCandidates[e.ExpKey(0,i+1)]);}
function pick(event){const list=offer();assert(list.includes(event));e.ProtoAction(0,2101+list.indexOf(event));assert.equal(e.ProtoSelected[0],event);}
function settle(branch){let n=0;while(e.ProtoStage[0]===2||e.ProtoDialoguePending(0)){assert(++n<30);e.ProtoAction(0,e.ProtoStage[0]===2?2200+(e.ProtoDialogueFollowing(0)?1:branch):2400);}assert.equal(e.ProtoStage[0],3);e.ProtoAction(0,2400);}
reset();assert.deepEqual(offer(),[main]);pick(main);e.ProtoAction(0,2202);assert.equal(state(side),0,'초기 반응에서는 열리지 않음');settle(2);assert.equal(state(side),1);assert.equal(e.ProtoAP[0],96);assert.deepEqual(offer(),[next,side]);
assert(e.ProtoOutcome[0].includes('후속 사건 개방'));
const ap=e.ProtoAP[0];e.ProtoAction(0,2300);assert.equal(e.ProtoAP[0],ap);assert.equal(state(side),1);offer();assert.equal(state(side),1);e.ProtoDeadline[0]=1;e.HuntFraction=0.75;e.ExpSeconds=100;e.ProtoTick();assert.equal(e.ProtoStage[0],0);assert.equal(state(side),1);assert.equal(e.ProtoAP[0],ap);
// 행동력 부족과 구버전 요청으로 기회를 잃지 않는다.
offer();e.ProtoAP[0]=3;e.ProtoAction(0,2102);assert.equal(state(side),1);assert.equal(e.ProtoAP[0],3);e.ProtoAP[0]=96;offer();e.syncData=`${e.ExpRun}|${e.ExpRevision}|${e.ExpOfferVersion[0]-1}|2101`;e.eventPlayer=0;e.OnSync();assert.equal(state(side),1);
pick(side);assert.equal(e.ProtoAP[0],92);assert.equal(state(side),3);settle(2);assert.equal(state(child),1);assert.equal(e.ProtoMainProgress[e.ExpKey(0,head)],4);assert.deepEqual(offer(),[next,child]);pick(child);settle(1);assert.equal(e.ProtoAP[0],86);assert.equal(e.ProtoMainProgress[e.ExpKey(0,head)],4);assert.equal(state(child),3);const gold=e.ExpGold[0];e.ProtoAction(0,2201);assert.equal(e.ExpGold[0],gold);assert.deepEqual(offer(),[next]);
reset();pick(main);settle(1);assert.equal(state(side),0);assert.deepEqual(offer(),[next]);
reset();pick(main);settle(2);e.ProtoOpenSidePaths(1,main,2);pick(next);assert.equal(state(side),2);assert.equal(state(side,1),1);settle(1);e.ProtoOpenSidePaths(0,main,2);assert.equal(state(side),2);assert(!offer().includes(side));
reset();pick(main);settle(2);e.ExpState=e.EXP_BATTLE;e.ExpWon=true;e.ProtoBossRound=1;e.ProtoAP[0]=7;e.ProtoBeginNextHunt();assert.equal(e.ProtoAP[0],100);assert.equal(state(side),1);assert.equal(state(side,1),1);assert(offer().includes(side));
// UI 실제 후보 수와 페이지 조작은 행동력을 소비하지 않는다.
e.ExpUIOpen(9);t.render();assert.equal(e.ProtoOfferCount[0],2);assert.throws(()=>t.common(2300));assert(e.ProtoBranchOpens[e.ProtoChoiceKey(main,2)].includes('행동력 4'));
e.ProtoMainProgress[e.ExpKey(0,head)]=e.ProtoHeadMainLength[head];e.ProtoHeadCompleted[e.ExpKey(0,head)]=true;e.ProtoCompletedHeadCount[0]=1;offer();e.ProtoAction(0,2700);assert(e.ProtoHeadBrowse[0]);const first=e.ProtoCandidates[e.ExpKey(0,1)],before=e.ProtoAP[0];e.ProtoAction(0,2701);assert.notEqual(e.ProtoCandidates[e.ExpKey(0,1)],first);assert.equal(e.ProtoAP[0],before);assert.equal(state(side),1);t.render();
e.ResetPid=0;e.ProtoResetRunCards();assert.equal(state(side),0);assert.equal(state(child),0);
console.log('PASS choice paths: settlement, 4+6 AP, expiry, wrong answer, refresh, timeout resume, stale sync, boss carry, per-player isolation, head pages and UI');
