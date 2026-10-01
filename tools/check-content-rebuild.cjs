// 실제 콘텐츠와 사건 JASS를 함께 실행하여 분기, 비용, 도감과 생성 데이터의 경계를 검증한다.
'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const {fresh}=require('./check-expedition-ui.cjs');
const {inspect}=require('./check-content-candidates.cjs');
let checks=0;
const check=(name,fn)=>{fn();checks++;console.log('PASS '+name);};
const worlds=fs.readdirSync(path.join(__dirname,'../content/roguelite')).filter(f=>f.endsWith('.json')).sort().map(f=>JSON.parse(fs.readFileSync(path.join(__dirname,'../content/roguelite',f),'utf8')));
const id=(e,key)=>{const i=e.ProtoEventKey.indexOf(key);assert(i>0,key);return i;};
const card=(e,key)=>{const i=e.ProtoCardKey.indexOf(key);assert(i>=e.PROTO_CARD_FIRST,key);return i;};
function party(){const t=fresh(0,true),e=t.e;e.online=[true,true,false,false];e.ProtoCodexSlot[0]=e.ProtoCodexSlot[1]=1;e.ProtoAction(0,2001);e.ProtoAction(1,2001);t.render();assert.equal(e.ExpState,e.EXP_HUNT);return t;}
function enter(e,pid,key){const scene=id(e,key);e.ProtoOffer(pid);e.ProtoCandidates[e.ExpKey(pid,1)]=scene;e.ProtoAction(pid,2101);assert.equal(e.ProtoSelected[pid],scene);return scene;}
check('검토 JSON 전체 참조·단위 검사와 실제 생성 데이터 수 일치',()=>{
 const {e}=fresh(0,true);let cards=0,events=0,heads=0;
 for(const w of worlds){const report=inspect(w);assert.deepEqual(report.errors,[],JSON.stringify(report));cards+=w.cards.length;events+=w.events.length;
  if(w.world.key!=='common')heads++;
  for(const scene of w.events){const n=id(e,scene.key);assert.equal(e.ProtoEventChoices[n],scene.choices.length);assert.equal(e.ProtoEventStory[n],scene.story);for(const [i,b] of scene.choices.entries()){const k=e.ProtoChoiceKey(n,i+1);assert.equal(e.ProtoBranchChance[k],b.chance);assert.equal(e.ProtoBranchCard[k],b.card?card(e,b.card):0);}}
 }
 assert.equal(e.PROTO_HEAD_COUNT,heads);assert.equal(e.PROTO_CARD_LAST-e.PROTO_CARD_FIRST+1,cards);assert.equal(e.PROTO_EVENT_COUNT,heads*4+events);
});
check('잘못된 카드 참조·체력 지불·실패 후속·순환·각성·미지급 카드는 검사에서 탈락',()=>{
 const mutations=[w=>w.events[0].choices[0].card='missing',w=>w.events[0].choices[0].hpCost=1,w=>{w.events[1].previous=w.events[0].key;w.events[1].previousChoice=0;},w=>{w.events[1].previous=w.events[0].key;w.events[1].previousChoice=-1;},w=>{w.events[0].previous=w.events[1].key;w.events[0].previousChoice=1;w.events[1].previous=w.events[0].key;w.events[1].previousChoice=1;},w=>w.cards[0].evolution.kind=4,w=>{const c=structuredClone(w.cards[0]);c.key='unawarded';w.cards.push(c);w.events[0].requiredCard=c.key;},w=>w.world.entryCard='missing'];
 for(const mutate of mutations){const w=structuredClone(worlds[0]);mutate(w);assert(inspect(w).errors.length>0);}
});
check('머리 후보 첫 선택에서 행동력 한 번 지불, 즉시 입문 카드와 약한 지역 효과 획득',()=>{
 const {e}=party();enter(e,0,e.ProtoEventKey[1]);assert.equal(e.ProtoStage[0],3);assert.equal(e.ProtoAP[0],9);assert.equal(e.ProtoHeadCount[0],1);assert(e.ExpCardOwned[e.ExpKey(0,e.ProtoHeadEntryCard[1])]);assert(e.ProtoStat(0,e.PROTO_STAT_ATTACK)>0);assert.equal(e.ExpCardOwned.filter(Boolean).length,1);
 assert.equal(e.ProtoAP[1],10);assert(!e.ProtoHeadOwned[e.ExpKey(1,1)]);
});
check('확률 경계 65는 성공, 66은 실패하며 비용은 둘 다 지불하고 후속은 선택한 플레이어만 개방',()=>{
 for(const [roll,success] of [[65,true],[66,false]]){
  const {e}=party();e.ExpGold[0]=120;const event=enter(e,0,'common_fur_scale');const ap=e.ProtoAP[0],hp=e.GetUnitState(e.MainUnit[0],e.UNIT_STATE_LIFE);
  assert(e.ProtoBranchText(0,3).includes('성공 65%'));assert(e.ProtoBranchText(0,3).includes('실패해도 비용은 소모'));
  e.GetRandomInt=()=>roll;e.ProtoResolve(0,3);assert.equal(e.ExpGold[0],0);assert.equal(e.ProtoAP[0],ap);assert.equal(e.GetUnitState(e.MainUnit[0],e.UNIT_STATE_LIFE),hp);assert.equal(e.ProtoEventHistory[e.ProtoStoryKey(0,event)],success?3:-3);
  assert.equal(!!e.ExpCardOwned[e.ExpKey(0,card(e,'common_holo_wit'))],success);
  assert.equal(e.ProtoEventEligible(0,id(e,'common_good_receipt')),success);assert.equal(e.ProtoEventEligible(0,id(e,'common_other_buyer')),!success);
  assert(!e.ProtoEventEligible(1,id(e,'common_good_receipt')));assert(!e.ProtoEventEligible(1,id(e,'common_other_buyer')));
  const before=e.ExpGold[0];e.ProtoResolve(0,3);assert.equal(e.ExpGold[0],before);
 }
});
check('사건 선택 전 골드 부족과 사냥터 상한을 검사하고 중복 지급은 관련 카드의 100골드로 교환',()=>{
 const {e}=party();e.ExpGold[0]=0;const scene=enter(e,0,'common_five_coin');assert(!e.ProtoBranchAllowed(0,1));const ap=e.ProtoAP[0];e.ProtoResolve(0,1);assert.equal(e.ProtoStage[0],2);assert.equal(e.ProtoAP[0],ap);
 e.ProtoLevel[0]=5;assert(!e.ProtoBranchAllowed(0,2));e.ProtoLevel[0]=1;e.ExpGold[0]=5;e.ProtoGrantCard(0,card(e,'common_yato'));
 assert(e.ProtoBranchText(0,1).includes('이미 보유'));e.ProtoResolve(0,1);assert.equal(e.ExpGold[0],100);assert.equal(e.ExpCardOwned.filter(Boolean).length,1);assert(e.ProtoOutcome[0].includes('이미 보유'));
 assert.equal(e.ProtoEventHistory[e.ProtoStoryKey(0,scene)],1);assert(e.ProtoEventEligible(0,id(e,'common_lost_address')));
});
check('공통 사건은 머리 없이 등장하고 관련 사건은 소유 지역에서만 열리며 선택 전 공유 후보는 소진되지 않음',()=>{
 const {e}=party();const commonId=id(e,'common_five_coin'),related=id(e,'academy_bad_signal');assert(e.ProtoEventEligible(0,commonId));assert(e.ProtoEventEligible(1,commonId));assert(!e.ProtoEventEligible(0,related));e.ProtoGrantHead(0,e.ProtoHeadKey.indexOf('academy'));assert(e.ProtoEventEligible(0,related));assert(!e.ProtoEventEligible(1,related));
 e.ProtoOffer(0);e.ProtoCandidates[1]=commonId;assert(e.ProtoEventEligible(1,commonId));e.ProtoAction(0,2101);assert(!e.ProtoEventEligible(1,commonId));
});
check('네 행동은 영역 안에 배치되고 상세 확인은 로컬 UI만 바꾸며 커서 이탈 시 사건 설명 복원',()=>{
 const t=party(),e=t.e;e.ExpGold[0]=1000;enter(e,0,'common_fur_scale');t.render();const original=t.frame(e.UIExpeditionPrototype_StoryText).text,ap=e.ProtoAP.slice(),gold=e.ExpGold.slice(),used=e.ProtoEventUsed.slice();
 for(let i=1;i<=4;i++){const f=e.ExpUIButtons[e.UIExpeditionPrototype_BranchButtons[i]],b=t.frame(f);assert(t.visible(f));assert(-b.y+b.h<=.543);assert(b.h>=.098);}
 const b=e.ExpUIButtons[e.UIExpeditionPrototype_BranchButtons[3]];
 t.event(b,2,1);t.render();assert.equal(t.frame(e.UIExpeditionPrototype_StoryText).text,original);
 t.event(b,2);t.render();assert(t.frame(e.UIExpeditionPrototype_StoryText).text.includes('성공 65%'));assert(t.frame(e.UIExpeditionPrototype_StoryText).text.includes('손익 뒤의 의도'));
 assert.equal(t.packets.length,0);assert.deepEqual(e.ProtoAP,ap);assert.deepEqual(e.ExpGold,gold);assert.deepEqual(e.ProtoEventUsed,used);
 t.event(b,3);t.render();assert.equal(t.frame(e.UIExpeditionPrototype_StoryText).text,original);
});
check('도감의 마지막 지역 선택은 페이지 이동 뒤 실제 머리 ID를 동기화하고 저장은 안정된 콘텐츠 key 사용',()=>{
 const t=fresh(0,true),e=t.e;e.ProtoCodexSlot[0]=1;
 for(let h=1;h<=e.PROTO_HEAD_COUNT;h++)e.ProtoHeadKnown[e.ExpKey(0,h)]=true;t.render();
 const next=e.ExpUIButtons[e.UIExpeditionPrototype_HeadNext];
 while(t.frame(next).enabled)t.click(next);
 const h=e.PROTO_HEAD_COUNT;assert.equal(e.UIExpeditionPrototype_HeadPage,Math.floor((h-1)/3));
 const slot=h-e.UIExpeditionPrototype_HeadPage*3;t.click(e.ExpUIButtons[e.UIExpeditionPrototype_HeadButtons[slot]]);assert.equal(e.ProtoStartHead[0],h);
 t.start();e.ProtoGrantCard(0,card(e,'common_yato'));const saved=[];e.StashSave=(...args)=>saved.push(args);e.ProtoHeadKnown[1]=false;e.ProtoGrantHead(0,1);
 assert(saved.some(args=>args.includes(e.PROTO_SAVE_PREFIX+'머리도감.'+e.ProtoHeadKey[1])));
});
check('마그놀리아 게시판의 네 행동은 자기 후속 하나만 열고 다른 플레이어의 기록을 만들지 않음',()=>{
 const next=['ft_timber','ft_receipt','ft_fish','ft_new_board'];
 for(let choice=1;choice<=4;choice++){
  const {e}=party();e.ExpGold[0]=1000;
  const h=e.ProtoHeadKey.indexOf('magnolia');e.ProtoGrantHead(0,h);e.ProtoGrantHead(1,h);
  for(const key of next)assert(!e.ProtoEventEligible(0,id(e,key)));
  const board=enter(e,0,'ft_request_board');e.ProtoResolve(0,choice);
  for(const [i,key] of next.entries()){
   assert.equal(e.ProtoEventEligible(0,id(e,key)),i+1===choice,key);
   assert(!e.ProtoEventEligible(1,id(e,key)),key);
  }
  assert.equal(e.ProtoAP[0],9);assert(!e.ProtoEventEligible(1,board));
 }
});
check('물길의 70/71 확률 경계와 실패 후속, 나츠 준비 카드의 후속 조건을 실제 JASS로 검증',()=>{
 for(const [roll,success] of [[70,true],[71,false]]){
  const {e}=party();e.ExpGold[0]=1000;e.ProtoGrantHead(0,e.ProtoHeadKey.indexOf('magnolia'));
  const scene=enter(e,0,'ft_river'),before=e.ProtoDensity[0];
  e.GetRandomInt=()=>roll;e.ProtoResolve(0,1);
  assert.equal(e.ExpGold[0],success?1090:910);assert.equal(e.ProtoDensity[0],before+1);
  assert.equal(e.ProtoEventHistory[e.ProtoStoryKey(0,scene)],success?1:-1);
  assert.equal(e.ProtoEventEligible(0,id(e,'ft_wet_receipt')),!success);
  assert.equal(!!e.ExpCardOwned[e.ExpKey(0,card(e,'ft_gray'))],success);
  const flame=id(e,'ft_controlled_flame');assert(!e.ProtoEventEligible(0,flame));
  e.ProtoGrantCard(0,card(e,'ft_natsu'));assert(e.ProtoEventEligible(0,flame));
 }
});
check('직전 성공 보상을 반드시 소유하는 후속에서 같은 카드를 성장 보상으로 다시 제시하지 않음',()=>{
 for(const w of worlds){const events=new Map(w.events.map(e=>[e.key,e]));
  for(const scene of w.events.filter(e=>e.previous&&e.previousChoice>0)){
   const previous=events.get(scene.previous).choices[scene.previousChoice-1];
   const granted=[previous.card,previous.card2].filter(Boolean);
   for(const b of scene.choices)for(const key of [b.card,b.card2].filter(Boolean))assert(!granted.includes(key),scene.key+'의 직전 보상 중복 '+key);
  }
 }
});
check('카라쿠라의 배송 행동은 해당 후속 하나와 지정 카드만 열고 비용 부족 후속은 후보에서 제외',()=>{
 const next=['bl_rooftop_marks','bl_return_receipt','bl_closed_lane','bl_light_parcel'];
 const rewards=['bl_ichigo','bl_uryu','bl_orihime',null];
 for(let choice=1;choice<=4;choice++){
  const {e}=party();e.ExpGold[0]=1000;const h=e.ProtoHeadKey.indexOf('karakura');e.ProtoGrantHead(0,h);e.ProtoGrantHead(1,h);
  enter(e,0,'bl_shop_boxes');e.ProtoResolve(0,choice);
  for(const [i,key] of next.entries()){
   assert.equal(e.ProtoEventEligible(0,id(e,key)),i+1===choice,key);
   assert(!e.ProtoEventEligible(1,id(e,key)),key);
  }
  for(const key of rewards.filter(Boolean))assert.equal(!!e.ExpCardOwned[e.ExpKey(0,card(e,key))],key===rewards[choice-1]);
 }
 const {e}=party();e.ExpGold[0]=180;e.ProtoGrantHead(0,e.ProtoHeadKey.indexOf('karakura'));
 enter(e,0,'bl_shop_boxes');e.ProtoResolve(0,2);assert.equal(e.ExpGold[0],0);
 const follow=id(e,'bl_return_receipt');assert(!e.ProtoEventEligible(0,follow));
 e.ExpGold[0]=180;assert(e.ProtoEventEligible(0,follow));enter(e,0,'bl_return_receipt');
 assert(!e.ProtoBranchAllowed(0,1));assert(e.ProtoBranchAllowed(0,2));
});
check('카라쿠라 경보의 실패는 보상 없이 비용·적 수 부담과 개인 실패 기록을 유지',()=>{
 for(const [roll,success] of [[70,true],[71,false]]){
  const {e}=party();e.ExpGold[0]=1000;e.ProtoGrantHead(0,e.ProtoHeadKey.indexOf('karakura'));
  const scene=enter(e,0,'bl_stray_alarm'),density=e.ProtoDensity[0];e.GetRandomInt=()=>roll;e.ProtoResolve(0,1);
  assert.equal(e.ExpGold[0],success?1100:900);assert.equal(e.ProtoDensity[0],density+2);
  assert.equal(e.ProtoEventHistory[e.ProtoStoryKey(0,scene)],success?1:-1);
  assert.equal(!!e.ExpCardOwned[e.ExpKey(0,card(e,'bl_yoruichi'))],success);
  assert.equal(e.ProtoEventEligible(0,id(e,'bl_unmarked_corner')),!success);
  assert(!e.ProtoEventEligible(1,id(e,'bl_unmarked_corner')));
 }
});
check('라그나 공통 사건의 흡수 카드는 머리 없이 획득하고 후속 안전 선택은 적 단계를 실제 감소',()=>{
 const {e}=party();e.ExpGold[0]=1000;assert.equal(e.ProtoHeadCount[0],0);
 enter(e,0,'common_torn_poster');e.ProtoResolve(0,1);
 assert.equal(e.ProtoStat(0,e.PROTO_STAT_LEECH),8);assert.equal(e.ProtoStat(0,e.PROTO_STAT_ATTACK),6);assert.equal(e.ProtoLevel[0],2);
 assert(e.ProtoEventEligible(0,id(e,'common_lowered_blade')));assert(!e.ProtoEventEligible(1,id(e,'common_lowered_blade')));
 e.ProtoResume(0);enter(e,0,'common_lowered_blade');e.ProtoResolve(0,2);
 assert.equal(e.ProtoLevel[0],1);assert.equal(e.ExpGold[0],1230);
 assert(!e.ExpCardOwned[e.ExpKey(0,card(e,'common_ragna_break'))]);
});
check('페나코니 슬롯머신의 60/61 경계는 판돈을 소모하고 성공·실패 후속을 개인 기록으로 구분',()=>{
 for(const [roll,success] of [[60,true],[61,false]]){
  const {e}=party();e.ExpGold[0]=1000;const h=e.ProtoHeadKey.indexOf('penacony');e.ProtoGrantHead(0,h);e.ProtoGrantHead(1,h);
  const scene=enter(e,0,'hsr_dreamy_slots');e.GetRandomInt=()=>roll;e.ProtoResolve(0,1);
  assert.equal(e.ExpGold[0],success?1300:700);assert.equal(e.ProtoAP[0],9);
  assert.equal(e.ProtoEventHistory[e.ProtoStoryKey(0,scene)],success?1:-1);
  assert.equal(!!e.ExpCardOwned[e.ExpKey(0,card(e,'hsr_aventurine_fortune'))],success);
  assert.equal(e.ProtoEventEligible(0,id(e,'hsr_after_win')),success);
  assert.equal(e.ProtoEventEligible(0,id(e,'hsr_after_loss')),!success);
  assert(!e.ProtoEventEligible(0,id(e,'hsr_sorted_tokens')));
  for(const key of ['hsr_after_win','hsr_after_loss','hsr_sorted_tokens'])assert(!e.ProtoEventEligible(1,id(e,key)));
  const outcome=e.ProtoOutcome[0];e.ProtoResolve(0,1);assert.equal(e.ProtoOutcome[0],outcome);assert.equal(e.ExpGold[0],success?1300:700);
 }
});
check('슬롯머신 정리와 실패 후속은 추가 행동력을 쓰며 비용 부족이면 후속 후보가 나타나지 않음',()=>{
 const {e}=party();e.ExpGold[0]=1000;e.ProtoGrantHead(0,e.ProtoHeadKey.indexOf('penacony'));
 enter(e,0,'hsr_dreamy_slots');const density=e.ProtoDensity[0];e.ProtoResolve(0,3);
 assert.equal(e.ProtoDensity[0],density+1);assert.equal(e.ExpGold[0],1150);
 assert(e.ProtoEventEligible(0,id(e,'hsr_sorted_tokens')));
 assert(!e.ProtoEventEligible(0,id(e,'hsr_after_win')));assert(!e.ProtoEventEligible(0,id(e,'hsr_after_loss')));
 e.ProtoLevel[0]=2;e.ProtoResume(0);enter(e,0,'hsr_sorted_tokens');e.ProtoResolve(0,1);
 assert.equal(e.ProtoAP[0],8);assert.equal(e.ExpGold[0],1010);assert.equal(e.ProtoLevel[0],1);
 assert(e.ExpCardOwned[e.ExpKey(0,card(e,'hsr_misha_route'))]);
 const t=party(),f=t.e;f.ExpGold[0]=300;f.ProtoGrantHead(0,f.ProtoHeadKey.indexOf('penacony'));
 enter(f,0,'hsr_dreamy_slots');f.GetRandomInt=()=>61;f.ProtoResolve(0,1);
 assert.equal(f.ExpGold[0],0);assert(!f.ProtoEventEligible(0,id(f,'hsr_after_loss')));
 f.ExpGold[0]=180;assert(f.ProtoEventEligible(0,id(f,'hsr_after_loss')));
 f.ProtoResume(0);enter(f,0,'hsr_after_loss');f.ProtoResolve(0,1);
 assert.equal(f.ProtoAP[0],8);assert.equal(f.ExpGold[0],0);assert(f.ExpCardOwned[f.ExpKey(0,card(f,'hsr_black_swan_archive'))]);
 assert(!f.ExpCardOwned[f.ExpKey(0,card(f,'hsr_aventurine_fortune'))]);
});
check('가면 연극의 기억 대조만 출구 후속을 열고 다른 배역과 길 정리는 해당 후속을 열지 않음',()=>{
 for(let action=1;action<=3;action++){
  const {e}=party();e.ExpGold[0]=1000;e.ProtoGrantHead(0,e.ProtoHeadKey.indexOf('penacony'));
  enter(e,0,'hsr_masked_stage');e.ProtoResolve(0,action);
  assert.equal(e.ProtoEventEligible(0,id(e,'hsr_remembered_exit')),action===2);
  if(action===2){e.ProtoDensity[0]=5;e.ProtoResume(0);enter(e,0,'hsr_remembered_exit');e.ProtoResolve(0,1);
   assert.equal(e.ProtoDensity[0],4);assert.equal(e.ProtoAP[0],8);assert.equal(e.ExpGold[0],500);
   assert(e.ExpCardOwned[e.ExpKey(0,card(e,'hsr_aventurine_reserve'))]);
  }
 }
});
console.log(`${checks} content integration/negative-control groups passed. Mock natives only; visual rendering, Warcraft gameplay and server saves remain untested.`);
