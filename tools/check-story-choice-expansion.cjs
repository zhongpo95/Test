// 전체 작품의 후속 개방과 머리 선택용 서브, 머리 선택 세 후보 페이지의 누락을 검증한다.
'use strict';
const fs=require('node:fs'),assert=require('node:assert/strict');
const {fresh}=require('./check-expedition-ui.cjs');
const t=fresh(0,true),e=t.e;t.start();
const worlds=fs.readdirSync('content/roguelite').filter(f=>f.endsWith('.json')).map(f=>JSON.parse(fs.readFileSync('content/roguelite/'+f)));
const eventId=k=>e.ProtoEventKey.indexOf(k),headId=k=>e.ProtoHeadKey.indexOf(k);
function reset(w,complete=false){e.ResetPid=0;e.ProtoResetRunCards();e.ProtoStatReset(0);e.ProtoHeadCount[0]=0;e.ProtoCompletedHeadCount[0]=0;e.ProtoAP[0]=100;e.ExpGold[0]=100000;e.ExpState=e.EXP_HUNT;e.ExpWon=false;e.ProtoReady[0]=false;e.ProtoStage[0]=0;const h=headId(w.world.key);if(h>0){if(e.ProtoHeadRequiredMain[h])e.ProtoHeadCompleted[e.ExpKey(0,e.ProtoHeadRequiredMain[h])]=true;e.ProtoGrantHead(0,h);if(complete){e.ProtoCompletedHeadCount[0]=1;e.ProtoHeadCompleted[e.ExpKey(0,h)]=true;e.ProtoMainProgress[e.ExpKey(0,h)]=w.world.mainStory.length;}}}
function list(){assert(e.ProtoOfferCount[0]<=(e.ProtoHeadBrowse[0]?3:4));if(e.ProtoHeadBrowse[0])assert.equal(e.ProtoCandidates[e.ExpKey(0,4)],0);return Array.from({length:e.ProtoOfferCount[0]},(_,i)=>e.ProtoCandidates[e.ExpKey(0,i+1)]);}
function pages(){e.ProtoOffer(0);const seen=new Set(list()),ap=e.ProtoAP[0],version=e.ExpOfferVersion[0];const n=e.ProtoHeadPages[0];for(let i=1;i<n;i++){e.ProtoAction(0,2701);for(const id of list())seen.add(id);}assert.equal(e.ProtoAP[0],ap);assert(e.ExpOfferVersion[0]>=version);return seen;}
let linked=0,standalone=0,works=0;
for(const w of worlds){
 const h=headId(w.world.key),byKey=new Map(w.events.map(x=>[x.key,x]));
 if(h>0){assert(w.events.some(x=>x.choicePath&&byKey.get(x.previous)?.mainStage),w.world.key+' 메인 연결 없음');works++;}
 for(const ev of w.events.filter(x=>x.choicePath)){
  assert(ev.previous);reset(w,!!ev.epilogue);const id=eventId(ev.key),source=eventId(ev.previous),parent=byKey.get(ev.previous);
  if(parent.mainStage)e.ProtoMainProgress[e.ExpKey(0,h)]=parent.mainStage;
  if(parent.mainStage===w.world.mainStory?.length){e.ProtoCompletedHeadCount[0]=1;e.ProtoHeadCompleted[e.ExpKey(0,h)]=true;}
  if(ev.requiredCard)e.ExpCardOwned[e.ExpKey(0,e.ProtoCardKey.indexOf(ev.requiredCard))]=true;
  assert(!e.ProtoEventEligible(0,id),'열기 전 후보 금지');
  e.ProtoEventHistory[e.ProtoStoryKey(0,source)]=ev.previousChoice;e.ProtoOpenSidePaths(0,source,ev.previousChoice);
  assert.equal(e.ProtoSideState[e.ProtoStoryKey(0,id)],1);assert(e.ProtoEventEligible(0,id),ev.key+' 개방 후 자격');
  assert(pages().has(id),ev.key+' 페이지에서 누락');
  for(let n=0;!list().includes(id);n++){assert(n<e.ProtoHeadPages[0]);e.ProtoAction(0,2701);}
  const ap=e.ProtoAP[0];e.ProtoAction(0,2101+list().indexOf(id));assert.equal(e.ProtoAP[0],ap-ev.actionCost);assert.equal(e.ProtoSideState[e.ProtoStoryKey(0,id)],3);linked++;
 }
 reset(w,true);
 for(const ev of w.events.filter(x=>x.headChoice&&x.requiredCard))e.ExpCardOwned[e.ExpKey(0,e.ProtoCardKey.indexOf(ev.requiredCard))]=true;
 const shown=pages();
 for(const ev of w.events.filter(x=>x.headChoice)){assert(shown.has(eventId(ev.key)),ev.key+' 남은 서브 누락');standalone++;}
 if(h>0){
  const firstRoot=w.events.find(x=>x.headChoice&&!x.requiredCard&&!x.epilogue);
  if(firstRoot){reset(w);assert(!e.ProtoEventEligible(0,eventId(firstRoot.key)),'메인 진행 중 독립 서브 노출 금지');}
 }
}
assert.equal(works,28);assert.equal(linked,164);assert.equal(standalone,327);
// 일반 메인 갈림길은 기존처럼 메인과 세 후속을 함께 보이고, 머리 선택만 세 후보로 제한한다.
const snow=worlds.find(w=>w.world.key==='hakugyokurou');reset(snow);const source=eventId('pcb_main_07');e.ProtoMainProgress[e.ExpKey(0,headId('hakugyokurou'))]=7;e.ProtoEventHistory[e.ProtoStoryKey(0,source)]=1;e.ProtoOpenSidePaths(0,source,1);e.ProtoOffer(0);assert.equal(e.ProtoOfferCount[0],4);assert.equal(e.ProtoHeadPages[0],1);
const version=e.ExpOfferVersion[0];e.syncData=`${e.ExpRun}|${e.ExpRevision}|${version-1}|2101`;e.OnSync();assert.equal(e.ProtoStage[0],1);
function pick(event){const seen=pages();assert(seen.has(event));for(let n=0;!list().includes(event);n++){assert(n<e.ProtoHeadPages[0]);e.ProtoAction(0,2701);}e.ProtoAction(0,2101+list().indexOf(event));}
function finish(branch){let n=0;while(e.ProtoStage[0]===2||e.ProtoDialoguePending(0)){assert(++n<30);e.ProtoAction(0,e.ProtoStage[0]===2?2200+(e.ProtoDialogueFollowing(0)?1:branch):2400);}assert.equal(e.ProtoStage[0],3);e.ProtoAction(0,2400);}
const fuyuki=worlds.find(w=>w.world.key==='fuyuki'),root=eventId('school_circle'),child=eventId('school_circle_trace');
reset(fuyuki,true);pick(root);assert.equal(e.ProtoActiveSideStory[0],root);assert(!e.ProtoCanChooseHead(0));finish(1);assert.equal(e.ProtoActiveSideStory[0],root);assert(!e.ProtoCanChooseHead(0));assert.deepEqual([...pages()],[child]);
const pendingAP=e.ProtoAP[0];e.ProtoDeadline[0]=1;e.HuntFraction=.75;e.ExpSeconds=100;e.ProtoTick();assert.equal(e.ProtoActiveSideStory[0],root);assert.equal(e.ProtoAP[0],pendingAP);assert(!e.ProtoCanChooseHead(0));
e.ExpState=e.EXP_BATTLE;e.ExpWon=true;e.ProtoBossRound=1;e.ProtoBeginNextHunt();assert.equal(e.ProtoActiveSideStory[0],root);assert.equal(e.ProtoAP[0],100);assert(!e.ProtoCanChooseHead(0));
pick(child);finish(1);assert.equal(e.ProtoActiveSideStory[0],0);assert(e.ProtoCanChooseHead(0));assert(e.ProtoOutcome[0].includes('짧은 이야기 완료'));pages();assert(e.ProtoHeadBrowse[0]);assert.equal(e.ProtoOfferCount[0],3);
// 한 사건짜리 서브도 행동 선택 전에는 잠기고 최종 정산 후에만 다음 머리를 고른다.
reset(fuyuki,true);const single=fuyuki.events.find(x=>x.headChoice&&!x.epilogue&&!x.requiredCard&&!fuyuki.events.some(y=>y.previous===x.key));pick(eventId(single.key));assert(!e.ProtoCanChooseHead(0));finish(1);assert(e.ProtoCanChooseHead(0));
// 후보 조회/네 번째 슬롯으로는 새 머리를 얻거나 행동력을 소비할 수 없다.
e.ProtoOffer(0);const ap=e.ProtoAP[0];e.ProtoAction(0,2104);assert.equal(e.ProtoAP[0],ap);assert.equal(e.ProtoStage[0],1);e.ExpUIOpen(9);t.render();assert.equal(e.ProtoOfferCount[0],3);
console.log(JSON.stringify({works,linked,standalone,headCandidates:3,shortStoryLock:true,phaseCarry:true,validation:'JASS 모의 실행',runtime:false}));
