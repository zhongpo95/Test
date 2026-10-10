// 실제 JASS와 UI 콜백을 모의 실행하여 다단계 대화의 보상·비용·동기화 경계를 검증한다.
const assert = require('node:assert/strict');
const {fresh} = require('./check-expedition-ui.cjs');
let checks=0, paths=0, longestOutcome={length:0};
function check(name,run){run();checks++;console.log('PASS '+name);}
function packet(e,action){return `${e.ExpRun}|${e.ExpRevision}|${e.ExpOfferVersion[0]}|${action}`;}
function send(e,action,data){e.eventPlayer=0;e.syncData=data??packet(e,action);e.OnSync();}
function setup(){const t=fresh(0,true);t.start();return t;}
function begin(t,id){const e=t.e,head=e.ProtoEventHead[id];e.ProtoHeadOwned[e.ExpKey(0,head)]=true;e.ProtoMainProgress[e.ExpKey(0,head)]=e.ProtoEventMainStage[id]-1;e.ProtoEventHistory[e.ProtoStoryKey(0,id)]=0;e.ProtoAP[0]=20;e.ProtoStage[0]=1;e.ProtoChoices[0]=3;e.ProtoCandidates[e.ExpKey(0,1)]=id;send(e,2101);assert.equal(e.ProtoStage[0],2,`enter ${id}`);t.render();}
function copies(e){return e.ProtoRewardCopies.reduce((a,b)=>a+b,0);}
function drain(t,first=1,follow=1){const e=t.e;let steps=0;while(e.ProtoStage[0]===2||e.ProtoDialoguePending(0)){assert(++steps<30);if(e.ProtoStage[0]===2)send(e,2200+(e.ProtoDialogueFollowing(0)?Math.min(follow,e.ProtoDialogueChoiceCount(0)):first));else send(e,2400);t.render();}return steps;}
const index=setup().e;
const main=Array.from({length:index.PROTO_EVENT_COUNT},(_,i)=>i+1).filter(id=>index.ProtoEventDialogueEnabled[id]);
check('기존 198개와 추가된 모든 메인 사건이 대화 런타임에 연결됨',()=>{
 assert.equal(main.filter(id=>index.ProtoEventHead[id]<=13).length,198);
 assert.equal(main.length,index.ProtoHeadMainLength.slice(1,index.PROTO_HEAD_COUNT+1).reduce((n,v)=>n+v,0));
});
check('모든 최초 보상 분기 및 후속 선택이 끝난 뒤 보상·기록·행동력 한 번 정산',()=>{
 const t=setup(),e=t.e;
 for(const id of main)for(let first=1;first<=e.ProtoEventChoices[id];first++){
  e.ProtoResume(0);begin(t,id);const before=copies(e),ap=e.ProtoAP[0],progress=e.ProtoMainProgress[e.ExpKey(0,e.ProtoEventHead[id])];
  const stale=packet(e,2200+first);send(e,2200+first);assert.equal(copies(e),before);assert.equal(e.ProtoMainProgress[e.ExpKey(0,e.ProtoEventHead[id])],progress);assert(e.ProtoDialoguePending(0));
  send(e,2200+first,stale);assert.equal(copies(e),before);drain(t,first,(first%3)+1);
  const key=e.ProtoChoiceKey(id,first),rewardCount=Number(e.ProtoBranchCard[key]>0)+Number(e.ProtoBranchCard2[key]>0);
  assert.equal(copies(e),before+rewardCount,`reward ${id}/${first}`);assert.equal(e.ProtoAP[0],ap);assert.equal(ap,20-e.ProtoEventAPCost[id]);
  assert.equal(e.ProtoMainProgress[e.ExpKey(0,e.ProtoEventHead[id])],e.ProtoEventMainStage[id]);assert.equal(e.ProtoEventHistory[e.ProtoStoryKey(0,id)],first);
  const text=e.ProtoOutcome[0].replace(/\|c[0-9a-f]{8}|\|r/gi,'');if(text.length>longestOutcome.length)longestOutcome={id,first,length:text.length,lines:text.split('|n').length,text};
  send(e,2200+first,stale);assert.equal(copies(e),before+rewardCount);paths++;
 }
});
check('페나코니 결말은 선데이 질문 뒤 단일 답변과 공통 엔딩 보상',()=>{
 const t=setup(),e=t.e,id=main.find(id=>e.ProtoEventHead[id]===e.ProtoHeadKey.indexOf('penacony')&&e.ProtoEventMainStage[id]===15);assert(id);
 begin(t,id);send(e,2201);let found=false;
 for(let i=0;i<15&&(e.ProtoStage[0]===2||e.ProtoDialoguePending(0));i++){
  if(e.ProtoStage[0]===3)send(e,2400);else{
   const story=e.ProtoDialogueStoryText(0).replace(/\|c[0-9a-f]{8}|\|r/gi,'');
   if(story.includes('생명은 왜 깊은 잠에 빠지는 건가')){found=true;assert.equal(e.ProtoDialogueChoiceCount(0),1);assert(e.ProtoDialogueChoiceText(0,1,false).replace(/\|c[0-9a-f]{8}|\|r/gi,'').includes('우린 꿈에서 깨어날 거니까'));assert.equal(copies(e),0);}
   send(e,2201);
  }
 }
 assert(found);assert.equal(copies(e),1);const rewards=[1,2,3].map(i=>e.ProtoBranchCard[e.ProtoChoiceKey(id,i)]);assert.equal(new Set(rewards).size,1);
});
check('보스 합류가 최초 선택 및 중간 반응에서 보상을 누락하지 않음',()=>{
 for(const reaction of [false,true]){const t=setup(),e=t.e,id=main.find(id=>e.ProtoEventDialogueFirst[id]>0);begin(t,id);if(reaction)send(e,2201);e.ProtoJoinBoss();assert.equal(e.ExpState,e.EXP_BATTLE);assert.equal(e.ProtoStage[0],0);assert(!e.ProtoDialoguePending(0));assert.equal(copies(e),1);}
});
check('선택 제한시간과 반응 제한시간이 한 단계씩 진행됨',()=>{
 const t=setup(),e=t.e,id=main.find(id=>e.ProtoEventDialogueFirst[id]>0);begin(t,id);e.ProtoDeadline[0]=1;
 for(let i=0;i<4;i++)e.ProtoTick();assert.equal(e.ProtoStage[0],3);assert(e.ProtoDialoguePending(0));assert.equal(copies(e),0);
 e.ProtoDeadline[0]=1;for(let i=0;i<4;i++)e.ProtoTick();assert.equal(e.ProtoStage[0],2);assert(e.ProtoDialogueFollowing(0));assert.equal(copies(e),0);
});
check('범위를 벗어난 후속 답변과 오래된 계속 요청은 대화 상태를 바꾸지 않음',()=>{
 const t=setup(),e=t.e,id=main.find(id=>e.ProtoEventDialogueFirst[id]>0);begin(t,id);send(e,2201);const old=packet(e,2400);send(e,2400);const version=e.ExpOfferVersion[0];send(e,2400,old);assert.equal(e.ExpOfferVersion[0],version);e.ProtoChoose(0,0);e.ProtoChoose(0,e.ProtoDialogueChoiceCount(0)+1);assert.equal(e.ExpOfferVersion[0],version);assert.equal(copies(e),0);assert.equal(e.ProtoStage[0],2);
});
check('다단계가 없는 기존 서브 사건은 최초 선택 즉시 정산',()=>{
 const t=setup(),e=t.e,id=Array.from({length:e.PROTO_EVENT_COUNT},(_,i)=>i+1).find(id=>e.ProtoEventKind[id]>0&&!e.ProtoEventDialogueEnabled[id]&&!e.ProtoEventMainStage[id]&&!e.ProtoEventEpilogue[id]&&!e.ProtoEventRequired[id]&&!e.ProtoEventRequiredCard[id]);assert(id);begin(t,id);const choice=Array.from({length:e.ProtoEventChoices[id]},(_,i)=>i+1).find(i=>e.ProtoBranchAllowed(0,i));send(e,2200+choice);assert.equal(e.ProtoStage[0],3);assert(!e.ProtoDialoguePending(0));assert.notEqual(e.ProtoEventHistory[e.ProtoStoryKey(0,id)],0);
});
console.log(JSON.stringify({checks,mainEvents:main.length,firstChoicePaths:paths,longestOutcome,validation:'actual JASS translated to JavaScript with mocked natives',warcraftRuntime:false,mapCreated:false}));
