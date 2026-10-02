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
      assert.equal(e.ProtoStage[pid],3);assert.equal(e.ProtoAP[pid],20);assert.equal(e.ProtoHeadCount[pid],h);
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
check('상태창은 현재 공격력·치명·장비 배율과 25개 카드 효과를 분리해 표시',()=>{
  const t=fresh(0,true),e=t.e;t.start();t.click(t.common(-e.EXP_UI_STATS));
  assert.equal(plain(t.frame(e.UIPrototypeStatus_ActualValues[4]).text),'×1.50');
  e.MockAttack=180;e.Stats_Crit[0]=41;e.Equip_CriDeal[0]=20;e.Equip_ED[0]=10;e.Equip_WDP[0]=20;e.Equip_DP[0]=1.2;
  e.ProtoStatValues[e.PROTO_STAT_CRIT_DAMAGE]=30;e.ProtoStatValues[e.PROTO_STAT_DAMAGE]=30;e.ProtoStatValues[e.PROTO_STAT_FINAL]=40;
  t.render();
  for(const [slot,value] of [[2,'180'],[3,'41.0%'],[4,'×2.00'],[9,'30.0%'],[10,'50.0%'],[11,'40.0%']]){
    assert.equal(plain(t.frame(e.UIPrototypeStatus_ActualValues[slot]).text),value);
    assert.equal(t.frame(e.UIPrototypeStatus_ActualValues[slot]).horizontal,5);
  }
  let cards=t.frame(e.UIPrototypeStatus_Columns[1]).text+t.frame(e.UIPrototypeStatus_Columns[2]).text;
  assert(cards.includes('대미지 증가 +30.0%'));assert(!cards.includes('이동 속도 +0.0%'));
  for(let kind=1;kind<=25;kind++)e.ProtoStatValues[kind]=1;
  t.render();cards=t.frame(e.UIPrototypeStatus_Columns[1]).text+t.frame(e.UIPrototypeStatus_Columns[2]).text;
  for(let kind=1;kind<=25;kind++)assert(cards.includes(e.ProtoStatNames[kind]));

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
check('I 카드창은 10열 50칸이며 페이지·정렬·강화 표시가 전투 상태를 바꾸지 않음',()=>{
  const t=fresh(0,true),e=t.e;t.start();for(let id=e.PROTO_CARD_FIRST;id<e.PROTO_CARD_FIRST+55;id++)e.ProtoGrantCard(0,id);
  e.UIPrototypeCards_IKey();t.render();assert.equal(e.ExpUIPanel,e.EXP_UI_CARDS);
  assert(!t.visible(e.UIPrototypeStatus_Canvas));assert(!t.visible(e.UIExpeditionCommon_Navigation));
  assert.equal(e.UIPrototypeCards_Count,55);const cell=i=>e.ExpUIButtons[e.UIPrototypeCards_Cells[i]];
  const state=JSON.stringify([e.ProtoStatValues,e.ExpCardOwned,e.ProtoAP,e.ExpGold,e.ProtoCardRevision]);
  const owned=e.ExpCardOwned;let scans=0;e.ExpCardOwned=new Proxy(owned,{get:(a,k)=>{if(/^\d+$/.test(k))scans++;return a[k];}});
  for(let tick=0;tick<20;tick++)t.render();assert(scans<100,'매 갱신 전체 카드 조회');e.ExpCardOwned=owned;
  for(let i=1;i<=50;i++){const f=t.frame(cell(i));assert(t.visible(f.id));assert(f.x>=.02&&f.x+f.w<=.44);assert(-f.y>=.05&&-f.y+f.h<.335);}
  t.click(e.ExpUIButtons[e.UIPrototypeCards_Next]);assert.equal(e.UIPrototypeCards_Page,1);assert.equal(plain(t.frame(e.UIPrototypeCards_PageText).text),'2 / 2');assert(!t.frame(cell(6)).enabled);assert(!t.visible(e.UIPrototypeCards_Icons[6]));
  t.click(cell(1));assert.equal(t.packets.length,0);
  t.click(e.ExpUIButtons[e.UIPrototypeCards_GradeSort]);const list=e.UIPrototypeCards_Cards.slice(1,56);for(let i=1;i<list.length;i++)assert(e.ProtoCardGrade[list[i-1]]>=e.ProtoCardGrade[list[i]]);
  t.click(e.ExpUIButtons[e.UIPrototypeCards_RegionSort]);assert.equal(JSON.stringify([e.ProtoStatValues,e.ExpCardOwned,e.ProtoAP,e.ExpGold,e.ProtoCardRevision]),state);
  const selected=e.UIPrototypeCards_Cards[51];e.ProtoGrantEventCard(0,selected);t.render();assert(t.frame(e.ExpUIButtonLabels[e.UIPrototypeCards_Cells[1]]).text.includes('+1'));
  e.Finish(false);e.ProtoAction(0,2001);e.ExpUIOpen(e.EXP_UI_CARDS);t.render();assert.equal(e.UIPrototypeCards_Count,0);assert.equal(e.UIPrototypeCards_Page,0);assert(!t.frame(cell(1)).enabled);
});
check('I 입력은 로컬·선택 완료·채팅 닫힘에서만 작동하고 Tab 화면과 독립 전환',()=>{
  const t=fresh(0,true),e=t.e;t.start();
  e.eventPlayer=1;e.UIPrototypeCards_IKey();assert.notEqual(e.ExpUIPanel,e.EXP_UI_CARDS);
  e.eventPlayer=0;e.chatOpen=1;e.UIPrototypeCards_IKey();assert.notEqual(e.ExpUIPanel,e.EXP_UI_CARDS);
  e.chatOpen=0;e.PickCheck[0]=false;e.UIPrototypeCards_IKey();assert.notEqual(e.ExpUIPanel,e.EXP_UI_CARDS);e.PickCheck[0]=true;
  e.ExpUIOpen(e.EXP_UI_STATS);t.render();assert(t.visible(e.UIPrototypeStatus_Canvas));
  e.UIPrototypeCards_IKey();t.render();assert.equal(e.ExpUIPanel,e.EXP_UI_CARDS);assert(!t.visible(e.UIPrototypeStatus_Canvas));assert(t.visible(e.UIPrototypeCards_Root));
  e.UIPrototypeCards_IKey();t.render();assert.equal(e.ExpUIPanel,0);assert(!t.visible(e.UIPrototypeCards_Root));
  e.F_UpgradeOnOff[0]=true;e.UIPrototypeCards_IKey();assert.equal(e.ExpUIPanel,0);e.F_UpgradeOnOff[0]=false;
  e.UIPrototypeCards_IKey();t.render();t.click(e.ExpUIButtons[e.UIExpeditionCommon_PanelToggles[e.EXP_UI_CARDS]]);assert.equal(e.ExpUIPanel,0);
  e.UIPrototypeCards_IKey();t.render();e.UIExpeditionCommon_Escape();t.render();assert.equal(e.ExpUIPanel,0);
});
check('50칸의 끝 행·열 툴팁은 화면 안에 있고 페이지·닫기·타인 입력에서 정리',()=>{
  const t=fresh(0,true),e=t.e;t.start();for(let id=e.PROTO_CARD_FIRST;id<e.PROTO_CARD_FIRST+55;id++)e.ProtoGrantCard(0,id);e.UIPrototypeCards_IKey();t.render();
  const cell=i=>e.ExpUIButtons[e.UIPrototypeCards_Cells[i]];
  for(const slot of [1,10,41,50]){
    t.event(cell(slot),2,1);t.render();assert(!t.visible(e.UIPrototypeCards_Tooltip));
    t.event(cell(slot),2);t.render();assert(t.visible(e.UIPrototypeCards_Tooltip));
    const tip=t.frame(e.UIPrototypeCards_Tooltip);assert(tip.x>=0&&tip.x+tip.w<=.8&&tip.y<=.6&&tip.y-tip.h>=0);
    const text=t.frame(e.UIPrototypeCards_TooltipText).text;assert(text.includes(e.ProtoCardName[e.UIPrototypeCards_Cards[slot]]));assert(!text.includes('|r|n'));
    t.event(cell(slot),3);assert(!t.visible(e.UIPrototypeCards_Tooltip));
  }
  t.event(cell(1),2);t.render();t.click(e.ExpUIButtons[e.UIPrototypeCards_Next]);assert(!t.visible(e.UIPrototypeCards_Tooltip));
  t.event(cell(1),2);t.render();e.ExpUIOpen(e.EXP_UI_STATS);t.render();assert(!t.visible(e.UIPrototypeCards_Tooltip));
});
check('Tab 중앙 패널은 배경과 닫기 버튼까지 경계 안에 표시',()=>{
  const t=fresh(0,true),e=t.e;t.start();e.ExpUIOpen(e.EXP_UI_STATS);t.render();
  const root=t.frame(e.ExpUIRoots[e.EXP_UI_STATS]),canvas=t.frame(e.UIPrototypeStatus_Canvas);
  assert.equal(root.w,.60);assert.equal(root.h,.37);assert.equal(root.x,.10);assert.equal(root.y,.50);
  assert.equal(canvas.w,root.w);assert.equal(canvas.h,root.h);
  assert(!t.visible(e.UIExpeditionStats_LegacyBackground));
  const close=e.ExpUIButtons[e.UIExpeditionCommon_PanelToggles[e.EXP_UI_STATS]],f=t.frame(close);
  assert(f.x+f.w<=root.w);assert.equal(f.parent,canvas.id);t.click(close);assert(!t.visible(canvas.id));
});
console.log(`${checks} hunt UI groups passed. Static/mock checks; Warcraft UI and multiplayer remain untested.`);
