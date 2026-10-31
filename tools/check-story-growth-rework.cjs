// 전체 작품의 완주 비용·완결 효과·연계와 두 성장 구간을 실제 JASS 모의 실행으로 검증한다.
'use strict';
const fs=require('fs'),assert=require('node:assert/strict');
const {fresh}=require('./check-expedition-ui.cjs');const {specs}=require('./story-growth-policy.cjs');
const stats=['attack_percent','damage_percent','final_damage_percent','boss_damage_percent','normal_damage_percent','crit_chance','crit_damage','swift','action_speed','move_speed','charge_speed','penetration','max_health_percent','damage_reduction','leech','regeneration','kill_gold','event_choices','moving_damage','directional_damage','nondirectional_damage','shielded_damage','charge_damage','healthy_damage','action_capacity','skill_haste','dash_cooldown_reduction','q_skill_damage','w_skill_damage','e_skill_damage','r_skill_damage','a_skill_damage','s_skill_damage','d_skill_damage','f_skill_damage','c_skill_damage','basic_damage','move_damage_scale','recovery_speed'];
const worlds=fs.readdirSync('content/roguelite').filter(f=>f.endsWith('.json')).map(f=>JSON.parse(fs.readFileSync('content/roguelite/'+f,'utf8')));
const t=fresh(0,true),e=t.e;t.start();
function reset(head){e.ResetPid=0;e.ProtoResetRunCards();e.ProtoStatReset(0);e.ProtoHeadCount[0]=0;e.ProtoCompletedHeadCount[0]=0;e.ProtoAP[0]=100;e.ProtoAPMax[0]=100;e.ExpGold[0]=10000;e.ExpState=e.EXP_HUNT;e.ExpWon=false;e.ProtoReady[0]=false;e.ProtoStage[0]=0;if(e.ProtoHeadRequiredMain[head])e.ProtoHeadCompleted[e.ExpKey(0,e.ProtoHeadRequiredMain[head])]=true;e.ProtoGrantHead(0,head);}
function choose(id,branch){e.ProtoStage[0]=1;e.ProtoOfferCount[0]=1;e.ProtoCandidates[e.ExpKey(0,1)]=id;assert(e.ProtoEventEligible(0,id),'선택 불가 '+e.ProtoEventKey[id]);e.ProtoAction(0,2101);let guard=0;while(e.ProtoStage[0]===2||e.ProtoDialoguePending(0)){assert(++guard<50);e.ProtoAction(0,e.ProtoStage[0]===2?2200+(e.ProtoDialogueFollowing(0)?1:branch):2400)}assert.equal(e.ProtoStage[0],3);e.ProtoAction(0,2400)}
let mains=0,links=0,shops=0;
for(const w of worlds){
 if(!w.world.mainStory)continue;const head=e.ProtoHeadKey.indexOf(w.world.key);
 for(let branch=1;branch<=3;branch++){
  reset(head);const ordered=w.events.filter(x=>x.mainStage).sort((a,b)=>a.mainStage-b.mainStage);let finalBefore=0;
  const kind=stats.indexOf(specs[w.world.key][0])+1;
  for(const ev of ordered){if(ev.mainStage===ordered.length)finalBefore=e.ProtoStat(0,kind);choose(e.ProtoEventKey.indexOf(ev.key),branch)}
  assert.equal(e.ProtoAP[0],100-(ordered.length*4+4),w.world.key+' 총행동력');
  assert.equal(e.ProtoHeadCapacity(0),2,w.world.key+' 완주 한도');assert.equal(e.ProtoStat(0,kind)-finalBefore,specs[w.world.key][1],w.world.key+' 완결 핵심 지급');mains++;
 }
 // 첫 사용 가능한 2단계 연계와 개인별 완료 제한.
 const root=w.events.find(x=>x.chainStage===1&&x.choicePath);
 if(root){reset(head);const previous=e.ProtoEventKey.indexOf(root.previous);e.ProtoEventHistory[e.ProtoStoryKey(0,previous)]=root.previousChoice;e.ProtoOpenSidePaths(0,previous,root.previousChoice);const child=w.events.find(x=>x.previous===root.key&&x.chainRoot===root.key);assert(child);choose(e.ProtoEventKey.indexOf(root.key),child.previousChoice);e.ProtoOffer(0);assert(e.ProtoCandidates.slice(e.ExpKey(0,1),e.ExpKey(0,4)+1).includes(e.ProtoEventKey.indexOf(child.key)),'후속 후보 보장');choose(e.ProtoEventKey.indexOf(child.key),1);assert.equal(e.ProtoAP[0],90);assert(e.ProtoChainComplete[e.ExpKey(0,e.ProtoEventKey.indexOf(root.key))]);links++;}
 const shop=w.events.find(x=>x.growthRole==='shop'&&!x.previous&&!x.epilogue);
 if(shop){reset(head);assert(!e.ProtoEventEligible(0,e.ProtoEventKey.indexOf(shop.key)),'미연결 상점은 후보에서 제외');shops++;}
}
reset(1);e.ProtoAP[0]=17;e.ProtoRerolls[0]=7;e.ProtoMainProgress[e.ExpKey(0,1)]=2;e.ProtoStatValues[e.PROTO_STAT_ATTACK]=12;e.ExpState=e.EXP_BATTLE;e.ExpWon=true;e.ProtoBossRound=1;e.ProtoBeginNextHunt();assert.equal(e.ProtoBossRound,2);assert.equal(e.ProtoAP[0],100);assert.equal(e.ProtoRestCost(0),1);assert.equal(e.ProtoMainProgress[e.ExpKey(0,1)],2);assert.equal(e.ProtoStat(0,e.PROTO_STAT_ATTACK),12);assert(e.ProtoHeadOwned[e.ExpKey(0,1)]);
e.ProtoAP[0]=1;e.ExpGold[0]=0;e.ProtoStage[0]=0;assert(e.ProtoCanFinishGrowth(0),'사용 불가능한 잔여 행동력 종료');
// 모든 원고의 실제 상품 가격과 제한 효과, 연계 비용을 검사한다.
const {prices}=require('./story-growth-policy.cjs');
let allChains=0,allShops=0;
for(const w of worlds){
 const cards=new Map(w.cards.map(c=>[c.key,c]));
 for(const ev of w.events){
  assert.equal(ev.actionCost,ev.mainStage?(ev.growthRole==='main_final'?8:4):ev.chainStage?(ev.chainLength===2?(ev.chainStage===1?4:6):ev.chainStage===1?3:ev.chainStage===2?4:7):1);
  if(ev.chainStage)allChains++;
  for(const b of ev.choices){
   assert.equal(b.chance,100);assert.equal(b.gold,0);assert.equal(b.level,0);assert.equal(b.density,0);
   const c=cards.get(b.card);assert(c&&!c.retiredBalanceReward);
   for(const x of c.effects){
    assert(!['swift','max_health_percent','damage_reduction','action_capacity','kill_gold'].includes(x.stat),ev.key+' 제거 스탯');
    if(x.stat==='leech')assert(['main_final','chain_final'].includes(ev.growthRole));
   }
   if(ev.growthRole==='shop'){
    assert.equal(c.effects.length,1);const x=c.effects[0],price=prices[x.stat];assert(price,ev.key+' 판매 허용 스탯');
    assert([price[0],price[0]*2].includes(x.value));assert.equal(b.cost,price[1]*(x.value===price[0]?1:2.5));allShops++;
   }else assert.equal(b.cost,0);
  }
 }
}
// 메인 선행 조건을 가진 연계를 포함해 각 후속 분기를 완주한다.
let chainPaths=0;
for(const w of worlds){
 for(const last of w.events.filter(x=>x.growthRole==='chain_final'&&x.choicePath)){
  const path=[last];while(path[0].key!==last.chainRoot)path.unshift(w.events.find(x=>x.key===path[0].previous));
  reset(Math.max(1,e.ProtoHeadKey.indexOf(w.world.key)));
  const root=path[0];if(root.previous)e.ProtoEventHistory[e.ProtoStoryKey(0,e.ProtoEventKey.indexOf(root.previous))]=root.previousChoice;
  e.ProtoOpenSidePaths(0,e.ProtoEventKey.indexOf(root.previous),root.previousChoice);
  if(root.epilogue)e.ProtoMainProgress[e.ExpKey(0,e.ProtoHeadKey.indexOf(w.world.key))]=w.world.mainStory.length;
  for(let i=0;i<path.length;i++)choose(e.ProtoEventKey.indexOf(path[i].key),i+1<path.length?path[i+1].previousChoice:1);
  assert.equal(e.ProtoAP[0],100-path.reduce((n,x)=>n+x.actionCost,0));
  const rootId=e.ProtoEventKey.indexOf(root.key);assert(e.ProtoChainComplete[e.ExpKey(0,rootId)]);assert(!e.ProtoChainComplete[e.ExpKey(1,rootId)]);chainPaths++;
 }
}
// 선택 스킬은 각 키에 별도로 누적하고 가상 스탯 슬롯에는 남기지 않는다.
reset(1);const chosen=worlds.flatMap(w=>w.cards).find(c=>c.effects.some(x=>x.stat==='chosen_skill_damage'));
const chosenId=e.ProtoCardKey.indexOf(chosen.key),amount=chosen.effects.find(x=>x.stat==='chosen_skill_damage').value;
for(let key=0;key<9;key++){e.ProtoRewardSkill[0]=key;const before=e.ProtoStat(0,e.PROTO_STAT_SKILL_Q+key);e.ProtoStatAddCard(0,chosenId,false);assert.equal(e.ProtoStat(0,e.PROTO_STAT_SKILL_Q+key)-before,amount);}
assert.equal(e.ProtoStat(0,e.PROTO_STAT_CHOSEN_SKILL),0);
// 이동 배율은 기본 속도를 제외하고 추가 퍼센트만 40까지 계산한다.
e.Stat_MoveSpeed=[0];e.Hero_BuffMoveSpeed=[0];e.Arcana_MoveSpeed=[0];e.ProtoStatReset(0);e.ProtoStatValues[e.PROTO_STAT_MOVE_SCALE]=2.5;
for(const [speed,expected] of [[0,0],[20,50],[40,100],[60,100]]){e.Stat_MoveSpeed[0]=speed;assert.equal(e.ExpArcanaDamage(0,0,1,false,false,false),expected);}
// 흡혈 속도는 저장량을 늘리지 않고 같은 양을 더 짧게 회복한다.
e.ProtoStatReset(0);e.ProtoStatValues[e.PROTO_STAT_LEECH]=20;e.ProtoPaused[0]=false;e.ProtoReady[0]=false;
let life=100;e.GetUnitState=(u,k)=>k===e.UNIT_STATE_MAX_LIFE?1000:life;e.SetUnitState=(u,k,n)=>{life=n};
for(const [speed,ticks] of [[0,50],[30,39]]){life=100;e.ProtoClearRecovery(0);e.ProtoStatValues[e.PROTO_STAT_RECOVERY_SPEED]=speed;e.ProtoLeechHit(0,e.MainUnit[0],500);for(let i=0;i<ticks;i++)e.ProtoRecoveryTick();assert(Math.abs(life-200)<.00001);e.ProtoRecoveryTick();assert(Math.abs(life-200)<.00001);}
console.log(JSON.stringify({mains,links,shops,chainPaths,allChains,allShops,selectedSkills:9,twoPhaseReset:true,validation:'실제 JASS 모의 실행',runtime:false}));
