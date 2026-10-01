// 실제 사건 함수로 기본 후보·무료 방문·행동력 증가·개인 카드 조건의 수명주기를 검증한다.
'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const {fresh}=require('./check-expedition-ui.cjs'),{inspect}=require('./check-content-candidates.cjs');
let checks=0;const check=(name,fn)=>{fn();checks++;console.log('PASS '+name);};
const card=(e,key)=>{const n=e.ProtoCardKey.indexOf(key);assert(n>=e.PROTO_CARD_FIRST,key);return n;};
const scene=(e,key)=>{const n=e.ProtoEventKey.indexOf(key);assert(n>0,key);return n;};
function party(){const t=fresh(0,true),e=t.e;e.online=[true,true,false,false];for(let pid=0;pid<2;pid++){e.ProtoCodexSlot[pid]=1;e.ProtoAction(pid,2001);}assert.equal(e.ExpState,e.EXP_HUNT);return t;}
function request(e,pid,action,packet){e.eventPlayer=pid;e.syncData=packet??`${e.ExpRun}|${e.ExpRevision}|${e.ExpOfferVersion[pid]}|${action}`;e.OnSync();}
function enter(e,pid,id){assert(e.ProtoEventEligible(pid,id));e.ProtoOffer(pid);e.ProtoCandidates[e.ExpKey(pid,1)]=id;request(e,pid,2101);assert.equal(e.ProtoSelected[pid],id);}
check('실제 기본 후보 세 개는 서로 다르며 후보 보너스가 하나 이상이면 최대 네 개',()=>{
 const t=party(),e=t.e;assert.equal(e.ProtoChoices[0],3);e.ProtoOffer(0);t.render();
 const ids=[1,2,3].map(i=>e.ProtoCandidates[e.ExpKey(0,i)]);assert(ids.every(n=>n>0));assert.equal(new Set(ids).size,3);assert.equal(e.ProtoCandidates[e.ExpKey(0,4)],0);
 for(let i=1;i<=3;i++)assert(t.visible(e.ExpUIButtons[e.UIExpeditionPrototype_CandidateButtons[i]]));assert(!t.visible(e.ExpUIButtons[e.UIExpeditionPrototype_CandidateButtons[4]]));
 e.ProtoGrantCard(0,card(e,'academy_uiharu_order'));e.ProtoOffer(0);assert.equal(e.ProtoChoices[0],4);assert(e.ProtoCandidates[e.ExpKey(0,4)]>0);
 e.ProtoGrantCard(0,card(e,'axel_luna'));assert.equal(e.ProtoChoices[0],4);assert.equal(e.ProtoChoices[1],3);
});
check('무료 사건은 AP를 보존하고 공유 만남을 소비하며 타인의 오래된 후보와 중복 요청을 거부',()=>{
 const t=party(),e=t.e,h=e.ProtoHeadKey.indexOf('academy'),id=scene(e,'academy_no_ability');
 for(let pid=0;pid<2;pid++){e.ProtoGrantHead(pid,h);e.ProtoOffer(pid);e.ProtoCandidates[e.ExpKey(pid,1)]=id;}
 const other=`${e.ExpRun}|${e.ExpRevision}|${e.ExpOfferVersion[1]}|2101`,first=`${e.ExpRun}|${e.ExpRevision}|${e.ExpOfferVersion[0]}|2101`;
 assert.equal(e.ProtoEventAPCost[id],0);request(e,0,2101,first);assert.equal(e.ProtoAP[0],10);assert(e.ProtoEventUsed[id]);assert(!e.ProtoEventEligible(1,id));assert.equal(e.ProtoStage[0],2);
 const versions=e.ExpOfferVersion.slice();request(e,0,2101,first);assert.equal(e.ProtoAP[0],10);assert.deepEqual(e.ExpOfferVersion,versions);
 request(e,1,2101,other);assert.equal(e.ProtoSelected[1],0);assert.equal(e.ProtoAP[1],10);
 assert(![1,2,3,4].some(i=>e.ProtoCandidates[e.ExpKey(1,i)]===id));request(e,0,2201);assert(e.ExpCardOwned[e.ExpKey(0,card(e,'academy_saten'))]);assert.equal(e.ProtoAP[0],10);
 e.HuntSeconds[0]=73;request(e,0,2400);assert.equal(e.ProtoLastEvent[0],73);assert.equal(e.ProtoOfferKills[0],e.ProtoKills[0]);assert.equal(e.ProtoStage[0],0);
});
check('무료 사건도 사냥 간격을 지키며 AP 소진 후에는 등장하지 않고 준비 완료가 가능',()=>{
 const {e}=party(),id=scene(e,'academy_no_ability');e.ProtoGrantHead(0,e.ProtoHeadKey.indexOf('academy'));enter(e,0,id);request(e,0,2201);request(e,0,2400);
 e.ProtoKills[0]=e.ProtoOfferKills[0]+12;e.HuntSeconds[0]=e.ProtoLastEvent[0]+18;e.HuntFraction=.75;e.ProtoTick();assert.equal(e.ProtoStage[0],0);
 e.HuntFraction=.75;e.ProtoTick();assert.equal(e.ProtoStage[0],1);
 e.ProtoAP[1]=0;const free=scene(e,'ab68_big_bill');e.ProtoGrantHead(1,e.ProtoHeadKey.indexOf('abydos'));assert(!e.ProtoEventEligible(1,free));e.ProtoOffer(1);assert.equal(e.ProtoStage[1],0);request(e,1,2500);assert(e.ProtoReady[1]);
});
check('지정 카드 조건은 개인 소유로 열리고 AP가 하나 남아도 획득한 증가분을 한 번 지급',()=>{
 const {e}=party(),id=scene(e,'academy_next_shift'),plan=card(e,'academy_uiharu_plan');
 for(let pid=0;pid<2;pid++)e.ProtoGrantHead(pid,e.ProtoHeadKey.indexOf('academy'));
 assert(!e.ProtoEventEligible(0,id));e.ProtoGrantCard(0,card(e,'academy_uiharu_order'));assert(e.ProtoEventEligible(0,id));assert(!e.ProtoEventEligible(1,id));
 e.ProtoAP[0]=1;e.ExpGold[0]=200;enter(e,0,id);assert.equal(e.ProtoAP[0],0);request(e,0,2201);
 assert(e.ExpCardOwned[e.ExpKey(0,plan)]);assert.equal(e.ExpGold[0],0);assert.equal(e.ProtoAP[0],1);assert.equal(e.ProtoAPMax[0],11);assert.equal(e.ProtoStat(0,e.PROTO_STAT_CAPACITY),1);
 for(let i=0;i<5;i++)e.ProtoRefreshStats(0);e.ProtoGrantCard(0,plan);request(e,0,2201);assert.equal(e.ProtoAP[0],1);assert.equal(e.ProtoAPMax[0],11);assert.equal(e.ProtoAPMax[1],10);
});
check('행동력 최대치의 새 카드와 각성 증가분만 지급하고 반복 처치·재집계는 충전하지 않음',()=>{
 const {e}=party(),plan=card(e,'academy_uiharu_plan'),second=card(e,'academy_saten_box');
 // 실제 카탈로그처럼 각성 조건을 획득 전에 정한다. 새로운 콘텐츠는 추가하지 않는다.
 e.ProtoEvolutionKind[plan]=1;e.ProtoEvolutionGoal[plan]=2;e.ProtoSetEffect(plan,e.PROTO_STAT_CAPACITY,1,true);
 e.ProtoAP[0]=4;e.ProtoGrantCard(0,plan);assert.equal(e.ProtoAP[0],5);
 e.ProtoSetEffect(second,e.PROTO_STAT_CAPACITY,2,false);e.ProtoGrantCard(0,second);assert.equal(e.ProtoAPMax[0],13);assert.equal(e.ProtoAP[0],7);
 e.ProtoKill(0);e.ProtoEvolutionTick(0);assert.equal(e.ProtoAP[0],7);e.ProtoKill(0);e.ProtoEvolutionTick(0);assert(e.ProtoEvolved[e.ExpKey(0,plan)]);assert.equal(e.ProtoAPMax[0],14);assert.equal(e.ProtoAP[0],8);
 e.ProtoKill(0);e.ProtoEvolutionTick(0);e.ProtoRefreshStats(0);assert.equal(e.ProtoAP[0],8);assert.equal(e.ProtoAPMax[1],10);
});
check('무료·보유 조건·변경된 AP 최대치를 UI에 표시하고 화면 갱신은 성장 상태를 바꾸지 않음',()=>{
 const t=party(),e=t.e,id=scene(e,'academy_unsealed_list');e.ProtoGrantHead(0,e.ProtoHeadKey.indexOf('academy'));e.ProtoGrantCard(0,card(e,'academy_uiharu_list'));e.ProtoAP[0]=4;e.ProtoGrantCard(0,card(e,'academy_uiharu_plan'));
 e.ProtoOffer(0);e.ProtoCandidates[e.ExpKey(0,1)]=id;t.render();const i=e.UIExpeditionPrototype_CandidateButtons[1];assert(t.frame(e.ExpUIButtonLabels[i]).text.includes('행동력 0'));
 const bonus=t.frame(e.UIExpeditionPrototype_CandidateBonus[1]);assert(t.visible(bonus.id));assert(bonus.text.includes('접어 두지 않은 항목'));assert(t.frame(e.UIExpeditionPrototype_EventInfo).text.includes('행동력 5/11'));
 const before=[e.ProtoAP.slice(),e.ProtoAPMax.slice(),e.ExpGold.slice(),e.ExpCardOwned.slice()];for(let n=0;n<5;n++)t.render();assert.deepEqual([e.ProtoAP,e.ProtoAPMax,e.ExpGold,e.ExpCardOwned],before);assert.equal(t.packets.length,0);
 enter(e,0,id);assert.equal(e.ProtoAP[0],5);assert.equal(e.ProtoEventChoices[id],3);
});
check('신규 세 카드 분기는 실제 보상·골드·필드 변화를 적용하고 선행 보유 카드를 반복 지급하지 않음',()=>{
 for(const key of ['academy_next_shift','academy_unsealed_list'])for(let choice=1;choice<=3;choice++){
  const {e}=party(),id=scene(e,key),required=e.ProtoEventRequiredCard[id];e.ProtoGrantHead(0,e.ProtoHeadKey.indexOf('academy'));e.ProtoGrantCard(0,required);e.ExpGold[0]=1000;
  const b=e.ProtoChoiceKey(id,choice),reward=e.ProtoBranchCard[b];assert.notEqual(reward,required);const level=e.ProtoLevel[0],density=e.ProtoDensity[0];enter(e,0,id);request(e,0,2200+choice);
  assert(e.ExpCardOwned[e.ExpKey(0,reward)]);assert.equal(e.ExpGold[0],1000-e.ProtoBranchCost[b]);assert.equal(e.ProtoLevel[0],Math.max(1,level+e.ProtoBranchLevel[b]));assert.equal(e.ProtoDensity[0],Math.max(1,density+e.ProtoBranchDensity[b]));assert.equal(e.ProtoEventHistory[e.ProtoStoryKey(0,id)],choice);
 }
});
check('새 원정은 카드·각성·AP 최대치를 초기화하고 레거시 사건 기본 비용과 잘못된 입력을 검사',()=>{
 const t=party(),e=t.e;e.ProtoGrantCard(0,card(e,'academy_uiharu_plan'));assert.equal(e.ProtoAPMax[0],11);e.Finish(false);e.ProtoAction(0,2001);e.ProtoAction(1,2001);assert.equal(e.ProtoAPMax[0],10);assert.equal(e.ProtoAP[0],10);assert.equal(e.ProtoStat(0,e.PROTO_STAT_CAPACITY),0);
 for(const file of fs.readdirSync(path.join(__dirname,'../content/roguelite')).filter(f=>f.endsWith('.json'))){const d=JSON.parse(fs.readFileSync(path.join(__dirname,'../content/roguelite',file),'utf8'));for(const event of d.events)assert.equal(e.ProtoEventAPCost[scene(e,event.key)],event.actionCost??1);}
 const academy=JSON.parse(fs.readFileSync(path.join(__dirname,'../content/roguelite/04-academy.json'),'utf8'));for(const cost of [-1,0.5,2]){const d=structuredClone(academy);d.events[0].actionCost=cost;assert(inspect(d).errors.some(x=>x.reason.includes('행동력 비용')));}
 for(const value of [-1,0.5]){const d=structuredClone(academy);d.cards.find(c=>c.key==='academy_uiharu_plan').effects[0].value=value;assert(inspect(d).errors.some(x=>x.reason.includes('행동력 최대치')));}
});
console.log(`${checks} 사건 행동력 검사 묶음 통과. 실제 JASS의 모의 실행이며 Warcraft·화면·멀티플레이는 미검증.`);
