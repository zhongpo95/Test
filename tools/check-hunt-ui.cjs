// 개인 사냥의 무료 머리·상태창·중복 강화 표시와 로컬 조회 경계를 검증한다.
'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const {fresh}=require('./check-expedition-ui.cjs');
const {environment}=require('./check-expedition.cjs');
let checks=0;
const check=(name,fn)=>{fn();checks++;console.log('PASS '+name);};
const plain=s=>s.replace(/\|c[0-9a-f]{8}|\|r/gi,'');
const worlds=fs.readdirSync(path.join(__dirname,'../content/roguelite')).filter(f=>f.endsWith('.json')).map(f=>JSON.parse(fs.readFileSync(path.join(__dirname,'../content/roguelite',f),'utf8')));
check('처음에는 닫힌 출발창, 한 번 열기·X·ESC와 머리 선택 목록 제거',()=>{
  const t=fresh(0,true),e=t.e;assert.deepEqual(t.roots(),[]);e.SetMapLine(0);t.render();assert.deepEqual(t.roots(),[]);
  t.click(t.common(-98));assert.deepEqual(t.roots(),[8]);
  const text=t.frame(e.UIExpeditionPrototype_LobbyInfo).text;assert(text.includes('최대 2장'));assert(text.includes('획득 비용 없음'));
  assert(!Object.keys(e).includes('UIExpeditionPrototype_HeadButtons'));
  const close=e.ExpUIButtons[e.UIExpeditionCommon_PanelToggles[8]];assert.equal(plain(t.frame(e.ExpUIButtonLabels[e.UIExpeditionCommon_PanelToggles[8]]).text),'X');
  t.click(close);assert.deepEqual(t.roots(),[]);t.click(t.common(-98));assert.deepEqual(t.roots(),[8]);
  e.eventPlayer=0;e.UIExpeditionCommon_Escape();t.render();assert.deepEqual(t.roots(),[]);
  t.click(t.common(-98));e.MockAttack=1;t.render();assert(!t.frame(t.common(2001)).enabled);
});
check('머리 두 장은 AP 무료이며 세 번째는 후보와 직접 지급에서 차단, AP 0은 사냥만 유지',()=>{
  for(let pid=0;pid<4;pid++){
    const t=fresh(pid,true),e=t.e;e.online=[true,true,true,true];for(let p=0;p<4;p++)e.ProtoAction(p,2001);
    for(let h=1;h<=2;h++){
      const id=(h-1)*4+pid+1;e.ProtoOffer(pid);e.ProtoCandidates[e.ExpKey(pid,1)]=id;e.ProtoAction(pid,2101);
      assert.equal(e.ProtoStage[pid],3);assert.equal(e.ProtoAP[pid],10);assert.equal(e.ProtoHeadCount[pid],h);
      const stack=e.ProtoCardStacks[e.ExpKey(pid,e.ProtoHeadEntryCard[h])];e.ProtoAction(pid,2101);assert.equal(e.ProtoCardStacks[e.ExpKey(pid,e.ProtoHeadEntryCard[h])],stack);
      e.ProtoAction(pid,2400);
    }
    e.ProtoGrantHead(pid,3);assert.equal(e.ProtoHeadCount[pid],2);assert(!e.ProtoHeadOwned[e.ExpKey(pid,3)]);
    for(let id=1;id<=e.PROTO_HEAD_COUNT*4;id++)assert(!e.ProtoEventEligible(pid,id));
    e.ProtoAP[pid]=0;e.ProtoOffer(pid);assert.equal(e.ProtoStage[pid],0);
  }
});
check('사건 희귀도는 최고 가능 보상의 등급이며 성공 확률은 행동에서 따로 표시',()=>{
  const t=fresh(0,true),e=t.e;
  for(const w of worlds)for(const scene of w.events){
    const id=e.ProtoEventKey.indexOf(scene.key),cards=scene.choices.flatMap(b=>[b.card,b.card2]).filter(Boolean);
    const expected=Math.max(1,...cards.map(key=>e.ProtoCardGrade[e.ProtoCardKey.indexOf(key)]));assert.equal(e.ProtoEventGrade[id],expected);
  }
  t.start();e.ExpGold[0]=1000;e.ProtoOffer(0);const id=e.ProtoEventKey.indexOf('common_fur_scale');e.ProtoCandidates[1]=id;t.render();
  assert(t.frame(e.UIExpeditionPrototype_CandidateRegion[1]).text.includes('보상 가능'));
  t.click(t.common(2101));assert(t.frame(e.ExpUIButtonLabels[e.UIExpeditionPrototype_BranchButtons[3]]).text.includes('성공 65%'));
});
check('보유 카드 격자는 20칸·정수 페이지·지역/희귀도 정렬, 변경 때만 목록 조회',()=>{
  const t=fresh(0,true),e=t.e;t.start();
  for(let id=e.PROTO_CARD_FIRST;id<e.PROTO_CARD_FIRST+25;id++)e.ProtoGrantCard(0,id);
  t.click(t.common(-e.EXP_UI_STATS));const cell=i=>e.ExpUIButtons[e.UIPrototypeStatus_Cells[i]];t.click(cell(22));
  assert.equal(plain(t.frame(e.UIPrototypeStatus_PageText).text),'1/2');assert.equal(e.UIPrototypeStatus_Count,25);
  const shared={stats:e.ProtoStatValues.slice(),owned:e.ExpCardOwned.slice(),ap:e.ProtoAP.slice(),gold:e.ExpGold.slice(),revision:e.ProtoCardRevision.slice()};
  let scans=0;const owned=e.ExpCardOwned;e.ExpCardOwned=new Proxy(owned,{get:(a,key)=>{if(/^\d+$/.test(key))scans++;return a[key];}});
  for(let tick=0;tick<20;tick++)e.ProtoStatusRender(0);assert(scans<100,'보유 카드 전체를 매 렌더마다 순회함');
  t.click(cell(24));assert.equal(e.UIPrototypeStatus_Page,1);assert.equal(plain(t.frame(e.UIPrototypeStatus_PageText).text),'2/2');assert(!t.visible(cell(6)));
  t.click(cell(1));const selected=e.UIPrototypeStatus_Selected;assert(t.frame(e.UIPrototypeStatus_Detail).text.includes(e.ProtoCardName[selected]));
  t.click(cell(26));const list=e.UIPrototypeStatus_Cards.slice(1,26);for(let i=1;i<list.length;i++)assert(e.ProtoCardGrade[list[i-1]]>=e.ProtoCardGrade[list[i]]);
  t.click(cell(25));assert.deepEqual(e.UIPrototypeStatus_Cards.slice(1,26),Array.from({length:25},(_,i)=>e.PROTO_CARD_FIRST+i));
  assert.deepEqual(e.ProtoStatValues,shared.stats);assert.deepEqual(owned,shared.owned);assert.deepEqual(e.ProtoAP,shared.ap);assert.deepEqual(e.ExpGold,shared.gold);assert.deepEqual(e.ProtoCardRevision,shared.revision);assert.equal(t.packets.length,0);
  e.ExpCardOwned=owned;e.ProtoGrantEventCard(0,selected);t.render();assert(t.frame(e.UIPrototypeStatus_Detail).text.includes('강화 +1'));
  const root=t.frame(e.ExpUIRoots[e.EXP_UI_STATS]);assert.equal(root.w,.8);assert.equal(root.h,.6);
  for(const i of [21,22]){const f=t.frame(cell(i));assert(-f.y>=.078&&-f.y+f.h<=.110,'상태창 탭이 상단 공통 메뉴와 겹침');}
  for(let i=1;i<=20;i++){const f=t.frame(cell(i));assert(f.x>=0&&f.x+f.w<.578);assert(-f.y>=.143&&-f.y+f.h<=.543);}
  e.Finish(false);e.ProtoAction(0,2001);e.ExpUIOpen(e.EXP_UI_STATS);t.render();assert.equal(e.UIPrototypeStatus_Selected,0);assert.equal(e.UIPrototypeStatus_Count,0);
});
check('상태창 공통 메뉴 숨김, 아이콘 툴팁의 경계·타인 입력·페이지·닫기와 큰 이미지 선택',()=>{
  const t=fresh(0,true),e=t.e;t.start();
  for(let id=e.PROTO_CARD_FIRST;id<e.PROTO_CARD_FIRST+25;id++)e.ProtoGrantCard(0,id);
  t.click(t.common(-e.EXP_UI_STATS));const cell=i=>e.ExpUIButtons[e.UIPrototypeStatus_Cells[i]];
  assert(!t.visible(e.UIExpeditionCommon_Navigation));t.click(cell(22));
  const snapshot=JSON.stringify([e.ProtoStatValues,e.ExpCardOwned,e.ProtoAP,e.ExpGold,e.ProtoCardRevision]);
  for(const slot of [1,5,16,20]){
    const icon=e.UIPrototypeStatus_Hotspots[slot];
    t.event(icon,2,1);t.render();assert(!t.visible(e.UIPrototypeStatus_Tooltip));
    t.event(icon,2);t.render();assert(t.visible(e.UIPrototypeStatus_Tooltip));
    const tip=t.frame(e.UIPrototypeStatus_Tooltip),id=e.UIPrototypeStatus_Cards[slot];
    assert(tip.x>=0&&tip.x+tip.w<=.8&&-tip.y>=0&&-tip.y+tip.h<=.6);
    assert(t.frame(e.UIPrototypeStatus_TooltipText).text.includes(e.ProtoCardName[id]));
    assert(t.frame(e.UIPrototypeStatus_TooltipText).text.includes(e.ProtoCardEffectName[id]));
    t.click(icon);assert.equal(e.UIPrototypeStatus_Selected,id);
    assert.equal(t.frame(e.UIPrototypeStatus_Artwork).texture,t.frame(e.UIPrototypeStatus_Icons[slot]).texture);
    t.event(icon,2);t.render();t.event(icon,3);assert(!t.visible(e.UIPrototypeStatus_Tooltip));
  }
  t.event(e.UIPrototypeStatus_Hotspots[1],2);t.render();t.click(cell(24));assert(!t.visible(e.UIPrototypeStatus_Tooltip));
  t.event(e.UIPrototypeStatus_Hotspots[1],2);t.render();t.click(cell(21));assert(!t.visible(e.UIPrototypeStatus_Tooltip));t.click(cell(22));
  t.event(e.UIPrototypeStatus_Hotspots[1],2);t.render();t.click(e.ExpUIButtons[e.UIExpeditionCommon_PanelToggles[e.EXP_UI_STATS]]);
  assert(!t.visible(e.UIPrototypeStatus_Tooltip));assert(t.visible(e.UIExpeditionCommon_Navigation));
  t.click(t.common(-e.EXP_UI_STATS));assert(!t.visible(e.UIPrototypeStatus_Tooltip));
  assert.equal(JSON.stringify([e.ProtoStatValues,e.ExpCardOwned,e.ProtoAP,e.ExpGold,e.ProtoCardRevision]),snapshot);assert.equal(t.packets.length,0);
});
check('상태창은 현재 공격력·치명·장비 배율과 25개 카드 효과를 분리해 표시',()=>{
  const t=fresh(0,true),e=t.e;t.start();e.MockAttack=180;e.Stats_Crit[0]=41;e.Equip_CriDeal[0]=20;e.Equip_ED[0]=10;e.Equip_WDP[0]=20;e.Equip_DP[0]=1.2;
  e.ProtoStatValues[e.PROTO_STAT_CRIT_DAMAGE]=30;e.ProtoStatValues[e.PROTO_STAT_DAMAGE]=30;e.ProtoStatValues[e.PROTO_STAT_FINAL]=40;
  t.click(t.common(-e.EXP_UI_STATS));const actual=t.frame(e.UIPrototypeStatus_Columns[0]).text;
  for(const value of ['최종 공격력 180','치명타 확률 41.0%','치명타 피해 ×2.50','추가 피해 30.0%','대미지 증가 50.0%','최종 대미지 증가 40.0%'])assert(actual.includes(value),value);
  const cards=t.frame(e.UIPrototypeStatus_Columns[1]).text+t.frame(e.UIPrototypeStatus_Columns[2]).text;
  for(let kind=1;kind<=25;kind++)assert(cards.includes(e.ProtoStatNames[kind]));assert(cards.includes('대미지 증가 +30.0%'));
});
check('Tab 실제 콜백은 자기 클라이언트에서만 새 상태창을 토글, 선택 조회는 전투 치명 확률을 보존',()=>{
  let e,shown=[],texts=[];
  const arrays=['Equip_Swiftness','Hero_BuffMoveSpeed','Arcana_MoveSpeed','Equip_Crit','Equip_WDP','Arcana_DP','Equip_ED','Equip_DamageP','Equip_Penetration','Equip_CardDamage1','Equip_CardDamage2'];
  const extras=Object.fromEntries(arrays.map(key=>[key,[0,0,0,0]]));
  Object.assign(extras,{ExpPrototypeEnabled:true,ExpUIPanel:0,EXP_UI_STATS:5,JN_OSKEY_TAB:9,F_ArcanaStatsText:Array(16).fill(70),Equip_DP:[1,1,1,1],
    DzGetTriggerKey:()=>9,DzGetTriggerKeyPlayer:()=>e.eventPlayer,JNMemoryGetByte:()=>0,JNGetModuleHandle:()=>0,
    ExpUIOpen:panel=>{e.ExpUIPanel=panel;},DzFrameShow:(...args)=>shown.push(args),DzFrameSetText:(...args)=>texts.push(args),DzFrameSetTexture:()=>{},
    GetTriggerUnit:()=>0,GetOwningPlayer:()=>0,AttackPower:()=>150,SkillSpeed:()=>20,CooldownRate:()=>.8,FinalDamageBonus:()=>10,
    Power:()=>0,TrailblazePower:()=>0,IsEmptyItem:()=>true,GetEquipSlotEmptyArt:()=>'',Stats_Crit:[41,5,5,5]});
  e=environment(['UI/UI_Info2.j'],extras,['UIInfo2_TABKey','UIInfo2_SELECTEDAction']).env;
  e.UIInfo2_TABKey();assert.equal(e.ExpUIPanel,5);e.UIInfo2_TABKey();assert.equal(e.ExpUIPanel,0);
  e.eventPlayer=1;e.UIInfo2_TABKey();assert.equal(e.ExpUIPanel,0);assert.equal(shown.length,2);
  e.eventPlayer=0;e.UIInfo2_SELECTEDAction();assert.equal(e.Stats_Crit[0],41);assert(texts.some(([,text])=>text==='41%'));
});
console.log(`${checks} hunt UI groups passed. Static/mock checks; Warcraft UI and multiplayer remain untested.`);
