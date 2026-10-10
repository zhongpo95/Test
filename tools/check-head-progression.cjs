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
 assert.equal(e.ProtoHeadCapacity(0),3);assert(e.ProtoOutcome[0].includes('이번 원정 머리 카드 한도 +1'));
 assert(!e.ProtoOutcome[0].includes('후속 머리 후보 해금'),'후속 머리가 없는 완주에 해금 안내 표시');
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
 e.ProtoHeadRequiredMain[head]=1;e.ProtoHeadRequiredMain[head-1]=1;
 e.ProtoHeadKnown[e.ExpKey(0,head)]=true;e.ProtoCodexSlot[0]=e.PlayerSlotNumber[0];
 e.ProtoStartHead[0]=head;assert.equal(e.ProtoStartHeadReady(0),false);
 assert.equal(e.ProtoEventEligible(0,id),false);e.ProtoSelected[0]=id;e.ProtoStage[0]=2;
 assert.equal(e.ProtoBranchAllowed(0,1),false);e.ProtoResolve(0,1);e.ProtoGrantHead(0,head);
 assert.equal(e.ProtoHeadOwned[e.ExpKey(0,head)],false);assert.equal(e.ProtoHeadCount[0],0);
 e.ProtoStage[0]=1;e.ProtoCandidates[e.ExpKey(0,1)]=id;send(e,0,2101);assert.equal(e.ProtoHeadOwned[e.ExpKey(0,head)],false);
 beginFinal(t,0,1);finish(t,0);assert.equal(e.ProtoHeadUnlocked(0,head),true);assert.equal(e.ProtoEventEligible(0,id),true);
 for(const unlocked of [head-1,head])assert(e.ProtoOutcome[0].includes('후속 머리 후보 해금 · '+e.ProtoHeadName[unlocked]),'선행 연결을 가진 후속 머리 이름 안내 누락');
 assert.equal(e.ProtoOutcome[0].split('이번 원정의 이후 사건 후보에 등장 가능').length-1,1,'여러 후속 머리의 범위 설명 중복');
 assert.equal(e.ProtoHeadUnlocked(1,head),false);assert.equal(e.ProtoStartHeadReady(0),false,'새 런에 후속 지역 선선택 금지');
 e.ProtoResume(0);e.ProtoStage[0]=1;e.ProtoCandidates[e.ExpKey(0,1)]=id;send(e,0,2101);
 assert.equal(e.ProtoHeadOwned[e.ExpKey(0,head)],true);
 e.ResetPid=0;e.ProtoResetRunCards();assert.equal(e.ProtoHeadUnlocked(0,head),false);
});
check('페르소나5 마지막 추가 대화 정산 뒤에만 로열이 세 번째 머리로 열리고 지도에 3/3 표시',()=>{
 const t=setup(),e=t.e;
 const base=e.ProtoHeadKey.findIndex(key=>key==='persona5'),royal=e.ProtoHeadKey.findIndex(key=>key==='persona5_royal');
 assert(base>0&&royal>0,'실제 persona5·persona5_royal production 카탈로그 통합 필요');
 assert.equal(e.ProtoHeadRequiredMain[royal],base,'로열의 실제 선행 머리 연결 누락');
 const other=e.ProtoHeadKey.findIndex((key,head)=>head>0&&head<=e.PROTO_HEAD_COUNT&&head!==base&&head!==royal&&e.ProtoHeadRequiredMain[head]===0);
 assert(other>0,'비교용 독립 머리 없음');
 const enter=head=>{e.ProtoResume(0);e.ProtoStage[0]=1;e.ProtoCandidates[e.ExpKey(0,1)]=e.ProtoHeadEntryEvent[head*4];send(e,0,2101);};
 enter(base);enter(other);
 assert.equal(e.ProtoHeadCount[0],2);assert.equal(e.ProtoHeadCapacity(0),2);
 assert(e.ProtoHeadOwned[e.ExpKey(0,base)]);assert(e.ProtoHeadOwned[e.ExpKey(0,other)]);
 const royalEntry=e.ProtoHeadEntryEvent[royal*4];assert(royalEntry>0);
 const locked=()=>{
  assert.equal(e.ProtoHeadCapacity(0),2,'최종 대화 정산 전에 한도 증가');
  assert.equal(e.ProtoHeadCompleted[e.ExpKey(0,base)],false);
  assert.equal(e.ProtoHeadUnlocked(0,royal),false,'최종 대화 정산 전에 로열 해금');
  assert.equal(e.ProtoEventEligible(0,royalEntry),false);
  assert(!e.ProtoOutcome[0].includes('후속 머리 후보 해금'),'최종 대화 정산 전 해금 안내');
 };
 locked();const id=beginFinal(t,0,base);locked();send(e,0,2201);assert(e.ProtoDialoguePending(0));locked();
 let node=e.ProtoEventDialogueFirst[id],nodes=0;
 while(node>0){
  assert(++nodes<30,'마지막 추가 대화가 끝나지 않음');
  send(e,0,2400);assert.equal(e.ProtoStage[0],2);assert(e.ProtoDialogueFollowing(0));
  assert.equal(e.ProtoDialogueStoryText(0),e.ProtoDialogueStory[node]);locked();
  send(e,0,2201);assert.equal(e.ProtoStage[0],3);assert(e.ProtoDialoguePending(0));locked();
  node=e.ProtoDialogueNext[node];
 }
 assert(nodes>0,'페르소나5 엔딩 추가 대화 누락');
 const settlement=packet(e,0,2400);send(e,0,2400,settlement);
 assert.equal(e.ProtoDialoguePending(0),false);assert.equal(e.ProtoHeadCapacity(0),3);
 assert.equal(e.ProtoCompletedHeadCount[0],1);assert.equal(e.ProtoHeadUnlocked(0,royal),true);
 assert.equal(e.ProtoEventEligible(0,royalEntry),true);assert.equal(e.ProtoHeadCount[0],2);
 assert(e.ProtoHeadOwned[e.ExpKey(0,base)],'본편 머리가 로열 해금 때 교체됨');
 const unlockText='후속 머리 후보 해금 · '+e.ProtoHeadName[royal];
 assert.equal(e.ProtoOutcome[0].split(unlockText).length-1,1);
 assert(e.ProtoOutcome[0].includes('이번 원정의 이후 사건 후보에 등장 가능'));
 assert(!e.ProtoHeadOwned[e.ExpKey(0,royal)],'후속 안내가 로열 자동 지급으로 이어짐');
 assert(!(e.ProtoOutcome[1]||'').includes(unlockText),'다른 플레이어에게 해금 안내 전파');
 send(e,0,2400,settlement);assert.equal(e.ProtoHeadCapacity(0),3,'지난 정산 패킷이 한도를 중복 증가시킴');
 assert.equal(e.ProtoOutcome[0].split(unlockText).length-1,1,'지난 패킷에 해금 문구 중복');
 // 이미 완료한 실제 본편의 보상 함수를 다시 정산해도 지역 완주 수는 늘지 않는다.
 e.ProtoStage[0]=2;e.ProtoSelected[0]=id;e.ProtoResolve(0,1);
 assert.equal(e.ProtoCompletedHeadCount[0],1);assert.equal(e.ProtoHeadCapacity(0),3);
 assert(!e.ProtoOutcome[0].includes(unlockText),'이미 완주한 지역 재정산에 새 해금 안내');
 const ap=e.ProtoAP[0],entryCard=e.ProtoHeadEntryCard[royal],copies=e.ProtoRewardCopies[e.ExpKey(0,entryCard)];
 assert.equal(e.ProtoEventAPCost[royalEntry],0);enter(royal);
 assert.equal(e.ProtoAP[0],ap);assert.equal(e.ProtoHeadCount[0],3);
 assert.equal(e.ProtoRewardCopies[e.ExpKey(0,entryCard)],copies+1);
 assert(e.ProtoHeadOwned[e.ExpKey(0,base)]);assert(e.ProtoHeadOwned[e.ExpKey(0,other)]);assert(e.ProtoHeadOwned[e.ExpKey(0,royal)]);
 // 결과 정산에 따른 자동 창 전환을 공통 타이머에서 소비한 뒤 실제 지도 열기 순서를 따른다.
 e.ProtoResume(0);t.render();e.ExpUIOpen(e.EXP_UI_MAP);t.render();
 assert(t.visible(e.UIMap_Status));assert(t.frame(e.UIMap_Status).text.includes('머리 3/3'),'실제 지도 상태 문자열이 동적 한도를 표시하지 않음');
 assert.equal(e.ProtoHeadUnlocked(1,royal),false,'다른 플레이어에게 로열 해금 전파');
 // 카드 배열뿐 아니라 머리 수 초기화도 담당하는 실제 새 런 진입 함수를 거친다.
 const run=e.ExpRun;e.ProtoCleanup();e.ExpState=e.EXP_RESULT;e.ExpRevision++;send(e,0,2001);
 assert.equal(e.ExpRun,run+1);assert.equal(e.ExpState,e.EXP_HUNT);
 assert.equal(e.ProtoHeadCapacity(0),2);assert.equal(e.ProtoCompletedHeadCount[0],0);assert.equal(e.ProtoHeadCount[0],0);
 assert.equal(e.ProtoHeadCompleted[e.ExpKey(0,base)],false);assert.equal(e.ProtoHeadUnlocked(0,royal),false);
 for(const head of [base,other,royal])assert.equal(e.ProtoHeadOwned[e.ExpKey(0,head)],false);
 assert.equal(e.ProtoHeadKnown[e.ExpKey(0,royal)],true,'새 런이 영구 발견 기록을 삭제함');
 e.ExpMember[0]=true;e.ProtoAP[0]=20;
 assert.equal(e.ProtoEventEligible(0,royalEntry),false,'새 런에서 이전 발견만으로 로열 후보 해금');
 assert(!e.ProtoOutcome[0].includes(unlockText),'새 런에 이전 해금 결과 문구 잔존');
});
check('출발 규칙과 사건 선택에 이번 원정 한도 및 꽉 찬 경우의 완주 안내를 두 줄 안에 표시',()=>{
 const t=setup(),e=t.e,plain=text=>text.replace(/\|c[\da-f]{8}|\|r/gi,'');
 t.render();assert(plain(t.frame(e.UIExpeditionPrototype_LobbyInfo).text).includes('이번 원정 머리 2장부터'));
 const hint=(count,capacity,full)=>{
  e.ProtoResume(0);e.ProtoStage[0]=1;e.ExpUIOpen(9);t.render();
  const frame=t.frame(e.UIExpeditionPrototype_EventStory),text=plain(frame.text);
  assert(t.visible(e.UIExpeditionPrototype_EventStory));
  assert(text.startsWith(`머리 ${count}/${capacity} ·`));
  assert.equal(text.includes('메인 이야기 완주 시 이번 원정의 머리 한도 +1.'),full);
  assert.equal(text.split('|n').length,full?2:1);assert.equal(frame.h,0.030,'기존 안내 프레임 높이 변경');
 };
 e.ProtoGrantHead(0,1);e.ProtoGrantHead(0,2);hint(2,2,true);
 beginFinal(t,0,1);finish(t,0);hint(2,3,false);
 e.ProtoGrantHead(0,3);hint(3,3,true);
 beginFinal(t,0,2);finish(t,0);hint(3,4,false);
 e.ProtoCleanup();e.ExpState=e.EXP_RESULT;e.ExpRevision++;send(e,0,2001);hint(0,2,false);
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
