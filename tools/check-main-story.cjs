// 실제 메인 단계·대화 보상·완결 후보와 보스 후 행동력 충전을 모의 실행한다.
'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs');
const {fresh}=require('./check-expedition-ui.cjs');
const {inspect}=require('./check-content-candidates.cjs');
let checks=0;
const check=(name,fn)=>{fn();checks++;console.log('PASS '+name);};
const penacony=JSON.parse(fs.readFileSync('content/roguelite/11-penacony.json','utf8'));
function party(n=1){const t=fresh(0,true),e=t.e;e.online=Array.from({length:4},(_,i)=>i<n);for(let pid=0;pid<n;pid++){e.ProtoCodexSlot[pid]=1;e.ProtoAction(pid,2001);}assert.equal(e.ExpState,e.EXP_HUNT);return t;}
function head(e,key='penacony'){const n=e.ProtoHeadKey.indexOf(key);assert(n>0);return n;}
function scene(e,key){const n=e.ProtoEventKey.indexOf(key);assert(n>0,key);return n;}
const stage=(e,n)=>scene(e,'hsr_main_'+String(n).padStart(2,'0'));
function request(e,pid,action,packet){e.eventPlayer=pid;e.syncData=packet??`${e.ExpRun}|${e.ExpRevision}|${e.ExpOfferVersion[pid]}|${action}`;e.OnSync();}
function enter(e,pid,id){assert(e.ProtoEventEligible(pid,id));e.ProtoOffer(pid);e.ProtoCandidates[e.ExpKey(pid,1)]=id;request(e,pid,2101);assert.equal(e.ProtoStage[pid],2);assert.equal(e.ProtoSelected[pid],id);}
function finish(e,pid,id,choice){enter(e,pid,id);request(e,pid,2200+choice);assert.equal(e.ProtoStage[pid],3);request(e,pid,2400);assert.equal(e.ProtoStage[pid],0);}
check('15장 순서와 세 동급 카드, 후일담·기본 효과를 생성 데이터에서 확인',()=>{
 const {e}=party(),h=head(e);assert.equal(e.ProtoHeadMainLength[h],15);
 assert.deepEqual(inspect(penacony).errors,[]);
 for(const event of penacony.events.filter(e=>e.mainStage)){
  const id=scene(e,event.key);assert.equal(e.ProtoEventMainStage[id],event.mainStage);assert.equal(e.ProtoEventAPCost[id],1);assert.equal(e.ProtoEventChoices[id],3);
  const cards=event.choices.map((_,i)=>e.ProtoBranchCard[e.ProtoChoiceKey(id,i+1)]);assert.equal(new Set(cards).size,3);assert.equal(new Set(cards.map(id=>e.ProtoCardGrade[id])).size,1);
  for(const id of cards){assert.equal(e.ProtoEvolutionKind[id],0);assert.equal(e.ProtoEvolutionGoal[id],0);}
 }
 for(const event of penacony.events.filter(e=>e.epilogue))assert.equal(e.ProtoEventEpilogue[scene(e,event.key)],1);
});
check('각 대화는 같은 다음 장과 완결에 도달하며 고른 카드만 지급',()=>{
 for(let choice=1;choice<=3;choice++){
  const {e}=party(),h=head(e);e.ProtoGrantHead(0,h);
  for(let n=1;n<=15;n++){
   const id=stage(e,n),before=e.ProtoAP[0];finish(e,0,id,choice);
   assert.equal(e.ProtoMainProgress[e.ExpKey(0,h)],n);assert.equal(e.ProtoAP[0],before-1);assert.equal(e.ProtoEventUsed[id],false);
   for(let j=1;j<=3;j++)assert.equal(e.ExpCardOwned[e.ExpKey(0,e.ProtoBranchCard[e.ProtoChoiceKey(id,j)])],j===choice);
   assert(!e.ProtoEventEligible(0,id));if(n<15)assert(e.ProtoEventEligible(0,stage(e,n+1)));
  }
  assert.equal(e.ProtoAP[0],5);assert(e.ProtoOutcome[0].includes('[이야기 완결] 페나코니'));assert(e.ExpPrototypeActive);
 }
});
check('13개 머리의 12~18장과 모든 대화 경로는 개인 완결에 도달하고 해당 풀을 닫음',()=>{
 const worlds=fs.readdirSync('content/roguelite').filter(f=>f.endsWith('.json')).map(f=>JSON.parse(fs.readFileSync('content/roguelite/'+f))).filter(d=>d.world.key!=='common');
 assert.equal(worlds.length,13);
 for(const world of worlds){
  assert(world.world.mainStory.length>=12&&world.world.mainStory.length<=18);assert.deepEqual(inspect(world).errors,[]);
  const mains=world.events.filter(ev=>ev.mainStage).sort((a,b)=>a.mainStage-b.mainStage);
  for(let choice=1;choice<=3;choice++){
   const {e}=party(),h=head(e,world.world.key);e.ProtoGrantHead(0,h);assert.equal(e.ProtoHeadMainLength[h],mains.length);
   for(const ev of mains){const id=scene(e,ev.key),cards=ev.choices.map((_,j)=>e.ProtoBranchCard[e.ProtoChoiceKey(id,j+1)]);assert.equal(new Set(cards).size,3);assert.equal(new Set(cards.map(c=>e.ProtoCardGrade[c])).size,1);const ap=e.ProtoAP[0];finish(e,0,id,choice);assert.equal(e.ProtoMainProgress[h],ev.mainStage);assert.equal(e.ProtoAP[0],ap-1);for(let j=1;j<=3;j++)assert.equal(e.ExpCardOwned[e.ExpKey(0,cards[j-1])],j===choice);}
   assert.equal(e.ProtoAP[0],20-mains.length);assert(e.ProtoOutcome[0].includes('[이야기 완결] '+world.world.name));
   for(const ev of world.events)assert.equal(e.ProtoEventEligible(0,scene(e,ev.key)),!!ev.epilogue,world.world.key+' '+ev.key);
   const ep=world.events.find(ev=>ev.epilogue);assert(ep);const ap=e.ProtoAP[0];finish(e,0,scene(e,ep.key),choice);assert.equal(e.ProtoAP[0],ap);assert(!e.ProtoEventEligible(0,scene(e,ep.key)));
  }
 }
});
check('단계 건너뛰기·오래된 패킷·반복 클릭은 진행과 행동력을 바꾸지 않음',()=>{
 const {e}=party(),h=head(e);e.ProtoGrantHead(0,h);assert(!e.ProtoEventEligible(0,stage(e,2)));
 e.ProtoOffer(0);e.ProtoCandidates[1]=stage(e,2);const ap=e.ProtoAP[0];request(e,0,2101);assert.equal(e.ProtoMainProgress[h],0);assert.equal(e.ProtoAP[0],ap);assert.equal(e.ProtoSelected[0],0);
 enter(e,0,stage(e,1));const stale=`${e.ExpRun}|${e.ExpRevision}|${e.ExpOfferVersion[0]}|2202`;
 request(e,0,2201);const stats=e.ProtoStatValues.slice();request(e,0,2202,stale);assert.deepEqual(e.ProtoStatValues,stats);assert.equal(e.ProtoEventHistory[e.ProtoStoryKey(0,stage(e,1))],1);
 assert.equal(e.ProtoMainProgress[h],1);assert.equal(e.ProtoAP[0],ap-1);
});
check('완결 결과만 특별 제목을 표시하고 다음 후일담에서는 일반 결과로 복원',()=>{
 const t=party(),e=t.e,h=head(e);e.ProtoGrantHead(0,h);
 enter(e,0,stage(e,1));request(e,0,2201);t.render();assert(t.frame(e.UIExpeditionPrototype_EventTitle).text.includes('개인 사건 · 사건 결과'));request(e,0,2400);
 for(let n=2;n<15;n++)finish(e,0,stage(e,n),1);
 enter(e,0,stage(e,15));request(e,0,2203);t.render();assert(t.frame(e.UIExpeditionPrototype_EventTitle).text.includes('이야기 완결 · 페나코니'));assert(t.frame(e.UIExpeditionPrototype_StoryRegion).text.includes('메인 15/15'));request(e,0,2400);
 enter(e,0,scene(e,'hsr_epilogue_postcard'));request(e,0,2201);t.render();assert(t.frame(e.UIExpeditionPrototype_EventTitle).text.includes('개인 사건 · 사건 결과'));assert(t.frame(e.UIExpeditionPrototype_StoryRegion).text.includes('후일담'));
});
check('네 사람이 같은 메인을 선택해도 개인 단계와 선택 기록은 서로 소진하지 않음',()=>{
 const {e}=party(4),h=head(e),id=stage(e,1);
 for(let pid=0;pid<4;pid++){e.ProtoGrantHead(pid,h);e.ProtoOffer(pid);e.ProtoCandidates[e.ExpKey(pid,1)]=id;}
 const packets=Array.from({length:4},(_,pid)=>`${e.ExpRun}|${e.ExpRevision}|${e.ExpOfferVersion[pid]}|2101`);
 for(let pid=0;pid<4;pid++){request(e,pid,2101,packets[pid]);request(e,pid,2200+pid%3+1);assert.equal(e.ProtoMainProgress[e.ExpKey(pid,h)],1);assert.equal(e.ProtoAP[pid],19);}
 assert(!e.ProtoEventUsed[id]);assert(e.ProtoEventEligible(3,stage(e,2)));
});
check('메인 하나를 후보에 보장하고 나머지는 중복 없이 추첨, 완결 뒤 해당 지역은 후일담만 남음',()=>{
 const {e}=party(2),h=head(e);e.ProtoGrantHead(0,h);e.ProtoGrantHead(1,h);e.ProtoGrantHead(0,head(e,'fuyuki'));
 for(let i=0;i<30;i++){e.ProtoOffer(0);assert([stage(e,1),scene(e,'fuyuki_main_01')].includes(e.ProtoCandidates[1]));assert.equal(new Set(e.ProtoCandidates.slice(1,4)).size,3);}
 const epilogue=scene(e,'hsr_epilogue_postcard');assert(!e.ProtoEventEligible(0,epilogue));
 for(let n=1;n<=15;n++)finish(e,0,stage(e,n),1);
 for(const event of penacony.events){const id=scene(e,event.key);assert.equal(e.ProtoEventEligible(0,id),!!event.epilogue,event.key);}
 assert(e.ProtoEventEligible(1,stage(e,1)));assert(e.ProtoEventEligible(1,scene(e,'hsr_soulglad')));
 assert(e.ProtoEventEligible(0,scene(e,'school_circle')));assert(e.ProtoEventEligible(0,scene(e,'common_five_coin')));
 const ap=e.ProtoAP[0];finish(e,0,epilogue,1);assert.equal(e.ProtoAP[0],ap);assert(!e.ProtoEventEligible(0,epilogue));assert(!e.ProtoEventUsed[epilogue]);
 e.ProtoAP[0]=0;e.ProtoOffer(0);assert.equal(e.ProtoStage[0],0);assert(!e.ProtoEventEligible(0,scene(e,'hsr_epilogue_voice')));request(e,0,2500);assert(e.ProtoReady[0]);
});
check('여러 보스 구간에서도 카드·기록·미완결 메인은 유지하고 매 구간 AP 최대치로 충전',()=>{
 const {e}=party(2),h=head(e);e.ProtoBossLimit=3;e.ProtoGrantHead(0,h);finish(e,0,stage(e,1),2);
 const capacity=e.ProtoCardKey.indexOf('academy_uiharu_plan');e.ProtoGrantCard(0,capacity);assert.equal(e.ProtoAPMax[0],21);
 const cards=e.ExpCardOwned.slice(),stats=e.ProtoStatValues.slice(),history=e.ProtoEventHistory.slice();
 e.ProtoAP[0]=e.ProtoAP[1]=0;e.ProtoJoinBoss();const revision=e.ExpRevision;e.ExpWon=true;e.BattleFinished();
 assert.equal(e.ExpState,e.EXP_HUNT);assert.equal(e.ProtoBossRound,2);assert.equal(e.ExpSeconds,1200);assert.equal(e.ProtoAP[0],21);assert.equal(e.ProtoAP[1],20);assert(e.ExpRevision>revision);
 assert.deepEqual(e.ExpCardOwned,cards);assert.deepEqual(e.ProtoStatValues,stats);assert.deepEqual(e.ProtoEventHistory,history);assert.equal(e.ProtoMainProgress[h],1);assert(e.ProtoEventEligible(0,stage(e,2)));
 const ap=e.ProtoAP.slice();e.ProtoBeginNextHunt();assert.deepEqual(e.ProtoAP,ap);assert.equal(e.ProtoBossRound,2);
 e.ProtoAP[0]=0;e.ProtoJoinBoss();e.ExpWon=true;e.BattleFinished();assert.equal(e.ProtoBossRound,3);assert.equal(e.ProtoAP[0],21);
 e.ProtoJoinBoss();e.ExpWon=true;e.BattleFinished();assert.equal(e.ExpState,e.EXP_RESULT);assert(!e.ExpPrototypeActive);
});
check('현재 단일 보스 종료는 유지하며 실패는 충전하지 않고 새 런에서 메인 진행 초기화',()=>{
 for(const won of [false,true]){const {e}=party(),h=head(e);assert.equal(e.ProtoBossLimit,1);e.ProtoGrantHead(0,h);finish(e,0,stage(e,1),1);e.ProtoJoinBoss();e.ExpWon=won;e.BattleFinished();assert.equal(e.ExpState,e.EXP_RESULT);assert.equal(e.ProtoBossRound,1);e.ProtoAction(0,2001);assert.equal(e.ProtoMainProgress[h],0);assert.equal(e.ProtoAP[0],20);}
});
check('4인 런 뒤 1인으로 재출발해도 마지막 카드와 비참가자의 메인·선택 기록을 모두 초기화',()=>{
 const {e}=party(4),h=head(e),last=e.PROTO_CARD_LAST,id=stage(e,1);
 for(let pid=0;pid<4;pid++){
  e.ProtoGrantHead(pid,h);finish(e,pid,id,pid%3+1);e.ProtoGrantCard(pid,last);e.ProtoGrantEventCard(pid,last);
  const key=e.ExpKey(pid,last);e.ExpCardSeen[key]=true;e.ExpCardReserved[key]=true;assert.equal(e.ProtoCardStacks[key],1);
 }
 e.Finish(false);e.online=[true,false,false,false];e.ProtoAction(0,2001);assert.equal(e.ExpState,e.EXP_HUNT);
 for(let pid=0;pid<4;pid++){
  const key=e.ExpKey(pid,last);assert(!e.ExpCardOwned[key]);assert(!e.ExpCardSeen[key]);assert(!e.ExpCardReserved[key]);assert.equal(e.ProtoCardStacks[key],0);
  assert(!e.ProtoHeadOwned[e.ExpKey(pid,h)]);assert.equal(e.ProtoMainProgress[e.ExpKey(pid,h)],0);assert.equal(e.ProtoEventHistory[e.ProtoStoryKey(pid,id)],0);
 }
});
check('누락·중복 단계·보상격차·기존분기조건·각성·후일담 오류는 검토를 통과하지 못함',()=>{
 const mutate=[d=>d.world.mainStory.length=14,d=>d.events.find(e=>e.mainStage===2).mainStage=1,d=>d.events.find(e=>e.mainStage===1).requiredCard=d.world.entryCard,d=>d.events.find(e=>e.mainStage===1).choices[0].chance=80,d=>d.cards.find(c=>c.key==='hsr_main_01_1').grade=4,d=>d.cards.find(c=>c.key==='hsr_main_01_1').evolution={kind:1,goal:1,effects:[{stat:'attack_percent',value:8}]},d=>d.events.find(e=>e.epilogue).mainStage=16,d=>d.events.find(e=>e.epilogue).epilogue='yes'];
 for(const fn of mutate){const d=structuredClone(penacony);fn(d);assert(inspect(d).errors.length>0);}
});
console.log(`${checks} 메인 이야기 검사 묶음 통과. 실제 JASS의 모의 실행이며 인게임·멀티플레이와 3종 보스는 미검증.`);
