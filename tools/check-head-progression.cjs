// 메인 완주에 따른 머리 카드 한도와 후속 지역 해금을 실제 JASS 모의 실행으로 검증한다.
'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const {fresh}=require('./check-expedition-ui.cjs');
const {generate}=require('./generate-prototype-content.cjs');
let checks=0;
const check=(name,run)=>{run();checks++;console.log('PASS '+name);};
function setup(){const t=fresh(0,true);t.start();return t;}
function packet(e,pid,action){return `${e.ExpRun}|${e.ExpRevision}|${e.ExpOfferVersion[pid]}|${action}`;}
function send(e,pid,action,data){e.eventPlayer=pid;e.syncData=data??packet(e,pid,action);e.OnSync();}
function ending(e,head){return e.ProtoEventHead.findIndex((h,id)=>h===head&&e.ProtoEventMainStage[id]===e.ProtoHeadMainLength[head]&&e.ProtoEventMainStage[id]>0);}
function beginFinal(t,pid,head){
 const e=t.e,id=ending(e,head);assert(id>0);e.ProtoResume(pid);
 e.ExpMember[pid]=true;e.ProtoHeadOwned[e.ExpKey(pid,head)]=true;
 e.ProtoMainProgress[e.ExpKey(pid,head)]=e.ProtoHeadMainLength[head]-1;e.ProtoEventHistory[e.ProtoStoryKey(pid,id)]=0;
 e.ProtoAP[pid]=20;e.ProtoStage[pid]=1;e.ProtoCandidates[e.ExpKey(pid,1)]=id;
 send(e,pid,2101);assert.equal(e.ProtoStage[pid],2);return id;
}
function finish(t,pid){const e=t.e;let steps=0;while(e.ProtoStage[pid]===2||e.ProtoDialoguePending(pid)){assert(++steps<30);send(e,pid,e.ProtoStage[pid]===2?2201:2400);}assert.equal(e.ProtoStage[pid],3);}
check('기본 두 장에서 추가 획득과 후보가 막히고, 최종 대화 정산 뒤 세 번째 머리가 열림',()=>{
 const t=setup(),e=t.e;assert.equal(e.ProtoHeadCapacity(0),2);
 e.ProtoGrantHead(0,1);e.ProtoGrantHead(0,2);e.ProtoGrantHead(0,3);assert.equal(e.ProtoHeadCount[0],2);
 const next=e.ProtoHeadEntryEvent[3*4];assert.equal(e.ProtoEventEligible(0,next),false);
 const id=beginFinal(t,0,1),old=packet(e,0,2201);send(e,0,2201);
 assert(e.ProtoDialoguePending(0));assert.equal(e.ProtoHeadCapacity(0),2);assert.equal(e.ProtoHeadCompleted[e.ExpKey(0,1)],false);
 send(e,0,2201,old);assert.equal(e.ProtoHeadCapacity(0),2);finish(t,0);
 assert.equal(e.ProtoHeadCapacity(0),3);assert(e.ProtoOutcome[0].includes('머리 카드 한도 +1'));
 assert.equal(e.ProtoHeadCount[0],2);assert(e.ProtoHeadOwned[e.ExpKey(0,1)]);
 send(e,0,2201,old);assert.equal(e.ProtoHeadCapacity(0),3);
 assert.equal(e.ProtoEventEligible(0,next),true);
 // 재정산을 강제로 호출하더라도 완주 기록이 한도를 중복 증가시키지 않아야 한다.
 e.ProtoStage[0]=2;e.ProtoSelected[0]=id;e.ProtoResolve(0,1);assert.equal(e.ProtoHeadCapacity(0),3);
 e.ProtoResume(0);e.ProtoStage[0]=1;e.ProtoCandidates[e.ExpKey(0,1)]=next;const ap=e.ProtoAP[0];send(e,0,2101);
 assert.equal(e.ProtoHeadCount[0],3);assert.equal(e.ProtoAP[0],ap);assert(e.ProtoHeadOwned[e.ExpKey(0,1)]);
 beginFinal(t,0,2);finish(t,0);assert.equal(e.ProtoHeadCapacity(0),4);
});
check('완주 실패와 일반 사건은 한도를 늘리지 않음',()=>{
 const t=setup(),e=t.e,id=beginFinal(t,0,1),key=e.ProtoChoiceKey(id,1);
 e.ProtoBranchChance[key]=1;e.GetRandomInt=(a,b)=>b;e.ProtoResolve(0,1);
 assert.equal(e.ProtoHeadCapacity(0),2);assert.equal(e.ProtoHeadCompleted[e.ExpKey(0,1)],false);
 const side=e.ProtoEventHead.findIndex((h,i)=>h===1&&e.ProtoEventKind[i]===1&&!e.ProtoEventMainStage[i]&&!e.ProtoEventEpilogue[i]);assert(side>0);
 e.ProtoSelected[0]=side;e.ProtoStage[0]=2;e.ProtoResolve(0,1);assert.equal(e.ProtoHeadCapacity(0),2);
});
check('네 플레이어의 완주와 새 런 초기화가 분리되고 영구 발견 도감은 유지됨',()=>{
 const t=setup(),e=t.e;
 for(let pid=0;pid<4;pid++){
  beginFinal(t,pid,1);finish(t,pid);assert.equal(e.ProtoHeadCapacity(pid),3);
  for(let other=pid+1;other<4;other++)assert.equal(e.ProtoHeadCapacity(other),2);
  e.ProtoHeadKnown[e.ExpKey(pid,1)]=true;
 }
 for(let pid=0;pid<4;pid++){
  e.ResetPid=pid;e.ProtoResetRunCards();assert.equal(e.ProtoHeadCapacity(pid),2);
  assert.equal(e.ProtoHeadCompleted[e.ExpKey(pid,1)],false);assert.equal(e.ProtoHeadOwned[e.ExpKey(pid,1)],false);
  assert.equal(e.ProtoHeadKnown[e.ExpKey(pid,1)],true);
  for(let other=pid+1;other<4;other++)assert.equal(e.ProtoHeadCapacity(other),3);
 }
});
check('선행 메인 미완료 시 후보·획득·위조 선택·영구 발견 도감으로 후속 머리를 우회하지 못함',()=>{
 const t=setup(),e=t.e,head=e.PROTO_HEAD_COUNT,id=e.ProtoHeadEntryEvent[head*4];
 e.ProtoHeadRequiredMain[head]=1;e.ProtoHeadKnown[e.ExpKey(0,head)]=true;e.ProtoCodexSlot[0]=e.PlayerSlotNumber[0];
 e.ProtoStartHead[0]=head;assert.equal(e.ProtoStartHeadReady(0),false);
 assert.equal(e.ProtoEventEligible(0,id),false);e.ProtoSelected[0]=id;e.ProtoStage[0]=2;
 assert.equal(e.ProtoBranchAllowed(0,1),false);e.ProtoResolve(0,1);e.ProtoGrantHead(0,head);
 assert.equal(e.ProtoHeadOwned[e.ExpKey(0,head)],false);assert.equal(e.ProtoHeadCount[0],0);
 e.ProtoStage[0]=1;e.ProtoCandidates[e.ExpKey(0,1)]=id;send(e,0,2101);assert.equal(e.ProtoHeadOwned[e.ExpKey(0,head)],false);
 beginFinal(t,0,1);finish(t,0);assert.equal(e.ProtoHeadUnlocked(0,head),true);assert.equal(e.ProtoEventEligible(0,id),true);
 assert.equal(e.ProtoHeadUnlocked(1,head),false);assert.equal(e.ProtoStartHeadReady(0),false,'새 런에 후속 지역 선선택 금지');
 e.ProtoResume(0);e.ProtoStage[0]=1;e.ProtoCandidates[e.ExpKey(0,1)]=id;send(e,0,2101);
 assert.equal(e.ProtoHeadOwned[e.ExpKey(0,head)],true);
 e.ResetPid=0;e.ProtoResetRunCards();assert.equal(e.ProtoHeadUnlocked(0,head),false);
});
check('생성기는 고정 ID로 선행 머리를 연결하고 없는 지역·메인 없음·순환을 거부함',()=>{
 const root=path.resolve(__dirname,'../content/roguelite');
 const worlds=fs.readdirSync(root).filter(f=>f.endsWith('.json')).sort().map(f=>JSON.parse(fs.readFileSync(path.join(root,f),'utf8')));
 const a=worlds.find(w=>w.world.key==='fuyuki'),b=worlds.find(w=>w.world.key==='axel');
 b.world.requiresCompletedHead='fuyuki';const text=generate(worlds);
 assert(text.includes(`set ProtoHeadRequiredMain[${b.head}] = ${a.head}`));
 const links=s=>[...s.matchAll(/set ProtoHeadRequiredMain\[(\d+)\] = (\d+)/g)].map(m=>m[0]).sort();
 assert.deepEqual(links(text),links(generate([...worlds].reverse())));
 b.world.requiresCompletedHead='missing';assert.throws(()=>generate(worlds),/선행 머리 카드/);
 b.world.requiresCompletedHead='common';assert.throws(()=>generate(worlds),/선행 머리 카드/);
 b.world.requiresCompletedHead='axel';assert.throws(()=>generate(worlds),/순환/);
 b.world.requiresCompletedHead='fuyuki';a.world.requiresCompletedHead='axel';assert.throws(()=>generate(worlds),/순환/);
 delete a.world.requiresCompletedHead;a.world.mainStory=[];assert.throws(()=>generate(worlds),/선행 머리 카드/);
});
console.log(JSON.stringify({checks,validation:'actual JASS translated with mocked natives',warcraftRuntime:false,mapCreated:false}));
