// 실제 원정 UI의 프레임과 콜백을 모의 실행하여 창 분리 및 선택 요청을 검증한다.
const fs = require('fs'), assert = require('node:assert/strict');
const {environment} = require('./check-expedition.cjs');
const files = ['Data/Data_Expedition.j', 'System/ExpeditionEffects.j', 'System/SaveLoad.j', 'System/Expedition.j',
  'UI/UI_InputGate.j', 'UI/UI_MainQuest.j', 'UI/UI_ExpeditionCommon.j', 'UI/UI_ExpeditionChoice.j', 'UI/UI_ExpeditionStats.j', 'UI/UI_Map.j'];
let checks = 0;
function check(name, fn) { fn(); checks++; console.log('PASS ' + name); }
function fresh() {
  const frames = new Map([[0, {id:0,type:'GAME',parent:null,shown:true,enabled:true,x:0,y:.6}]]), packets = [];
  let e, count = 0, eventFrame = 0, eventPlayer = 0;
  const no = () => {}, frame = id => {assert(frames.has(id), 'Unknown frame ' + id);return frames.get(id);};
  const {env} = environment(files, {
    F_UpgradeOnOff: [false,false,false,false], JN_FRAMEPOINT_TOPLEFT: 0,
    JN_FRAMEEVENT_MOUSE_ENTER: 2, JN_FRAMEEVENT_MOUSE_LEAVE: 3, JN_FRAMEEVENT_MOUSE_UP: 4,
    EVENT_PLAYER_END_CINEMATIC: 10, JN_OSKEY_M: 77,
    CreateTrigger: () => ({actions:[]}), TriggerAddAction: (t,fn) => t.actions.push(fn),
    Condition: fn => fn, TriggerAddCondition: (t,fn) => t.actions.push(fn),
    TriggerExecute: t => t.actions.forEach(fn=>fn()), TriggerRegisterPlayerEvent: no,
    TriggerRegisterTimerEventSingle: no, DzTriggerRegisterKeyEventByCode: no,
    FrameCount: () => count + 1, DzGetGameUI: () => 0, GetGameplayUI: () => 0,
    DzCreateFrameByTagName: (type,name,parent) => {const id=++count;frames.set(id,{id,type,parent,shown:true,enabled:true,scripts:{}});return id;},
    DzFrameSetPoint: (id,point,relative,relativePoint,x,y) => Object.assign(frame(id),{relative,x,y,absolute:false}),
    DzFrameClearAllPoints: no,
    DzFrameSetAbsolutePoint: (id,point,x,y) => Object.assign(frame(id),{x,y,absolute:true}),
    DzFrameSetSize: (id,w,h) => Object.assign(frame(id),{w,h}),
    DzFrameSetFont: (id,font,size,flags) => Object.assign(frame(id),{font,size}),
    DzFrameSetText: (id,text) => {frame(id).text=text;}, DzFrameSetTexture: (id,texture) => {frame(id).texture=texture;},
    // 설치된 Dz 구현은 CControl::Enable을 호출하므로 BACKDROP에는 사용할 수 없다.
    DzFrameSetEnable: (id,enabled) => {assert.notEqual(frame(id).type,'BACKDROP','DzFrameSetEnable cannot target a BACKDROP');frame(id).enabled=enabled;}, DzFrameShow: (id,shown) => {frame(id).shown=shown;},
    DzFrameSetAlpha: (id,alpha) => {frame(id).alpha=alpha;}, DzFrameSetPriority: (id,priority) => {frame(id).priority=priority;},
    DzFrameSetScriptByCode: (id,event,callback) => {frame(id).scripts[event]=callback;},
    DzGetTriggerUIEventFrame: () => eventFrame, DzGetTriggerUIEventPlayer: () => eventPlayer,
    DzSyncData: (channel,data) => packets.push({channel,data,player:e.localPlayer}),
  });
  e = env;
  e.UIMainQuest_Init();
  for(const lib of ['UIExpeditionCommon','UIExpeditionChoice','UIExpeditionStats','UIMap'])e[lib+'_Build']();
  const visible = id => id===0 || frame(id).shown && visible(frame(id).parent);
  const render = () => e.TriggerExecute(e.ExpRefresh);
  const event = (id,kind,player=e.localPlayer) => {assert(visible(id),'Hidden frame event');assert(frame(id).enabled,'Disabled frame event');eventFrame=id;eventPlayer=player;frame(id).scripts[kind]();};
  const flush = () => {for(const p of packets.splice(0)){e.eventPlayer=p.player;e.syncData=p.data;e.OnSync();}};
  const click = id => {event(id,4);flush();};
  const common = action => {
    for(let i=1;i<=e.UIExpeditionCommon_ButtonCount;i++)if(e.UIExpeditionCommon_ButtonActions[i]===action && visible(e.ExpUIButtons[i]))return e.ExpUIButtons[i];
    throw Error('No visible button for action '+action);
  };
  const card = (group,i) => e.UIExpeditionChoice_CardButton[e['UIExpeditionChoice_'+group+'Cards'][i]];
  const start = () => {render();click(common(1));assert.equal(e.ExpState,e.EXP_START);};
  const roots = () => Array.from({length:7},(_,i)=>i+1).filter(i=>visible(e.ExpUIRoots[i]));
  render();
  return {e,frames,frame,visible,render,event,packets,flush,click,common,card,start,roots};
}
check('영웅 선택 후 준비창, 시작 보상 6개, M 지도와 스탯창의 독립 전환',()=>{
  const t=fresh(),e=t.e;t.start();assert.deepEqual(t.roots(),[e.EXP_UI_CHOICE]);
  assert.equal(Array.from({length:9},(_,i)=>t.card('Choice',i+1)).filter(t.visible).length,6);
  e.UIMap_Toggle();assert.deepEqual(t.roots(),[e.EXP_UI_MAP]);
  assert(![...t.frames.values()].some(f=>f.type==='BUTTON'&&t.visible(f.id)&&f.parent===e.ExpUIRoots[e.EXP_UI_MAP]));
  t.click(t.common(-e.EXP_UI_STATS));assert.deepEqual(t.roots(),[e.EXP_UI_STATS]);
  t.click(t.common(-98));assert.deepEqual(t.roots(),[e.EXP_UI_CHOICE]);
  assert(e.UIMainQuest_OverlayHidden);
});
check('원정 중 마을 안내 갱신이 선택창에 겹치지 않고 마을에서 다시 표시됨',()=>{
  const t=fresh(),e=t.e;e.MainQuestNew(0,1);assert.equal(t.frame(e.UIMainQuest_F_MQBackDrop).shown,false);
  e.ExpUIOpen(0);assert.equal(t.frame(e.UIMainQuest_F_MQBackDrop).shown,true);
  e.ExpUIOpen(e.EXP_UI_LOBBY);t.start();e.MainQuestRefresh(0,1);assert.equal(t.frame(e.UIMainQuest_F_MQBackDrop).shown,false);
  e.ExpMember[0]=false;e.ExpState=e.EXP_LOBBY;e.ExpRevision++;t.render();e.ExpUIOpen(0);assert.equal(t.frame(e.UIMainQuest_F_MQBackDrop).shown,true);
  assert.equal(e.MainQuestGetStep(0,1),1);
});
check('카드 전체 클릭, 장식의 입력 차단 방지, 마우스 강조와 복원',()=>{
  const t=fresh(),e=t.e;t.start();const id=t.card('Choice',1),index=e.UIExpeditionChoice_ChoiceCards[1];
  for(const f of t.frames.values())if(f.parent===id){if(f.type==='TEXT')assert.equal(f.enabled,false);else assert.equal(f.type,'BACKDROP');}
  const bg=t.frame(e.UIExpeditionChoice_CardActionBackground[index]);
  t.event(id,2);assert(bg.texture.endsWith('ActionHover.tga'));
  assert(t.frame(e.UIExpeditionChoice_CardBorder[index]).texture.endsWith('Blue.blp'));
  t.event(id,3);assert(bg.texture.endsWith('Action.tga'));
  assert(t.frame(e.UIExpeditionChoice_CardBorder[index]).texture.endsWith('White.blp'));
  const points=e.ExpPoints[0];t.click(id);assert.equal(e.ExpPoints[0],points+10);assert.equal(e.ExpDone[0],true);assert.deepEqual(t.roots(),[]);
});
check('시작 후보 6개의 실제 동기화 요청, 타인 UI 이벤트 차단 및 중복 확정 거부',()=>{
  for(let action=1;action<=6;action++){
    const t=fresh(),e=t.e;t.start();const id=t.card('Choice',action);
    t.event(id,4,1);assert.equal(t.packets.length,0);
    t.event(id,4);assert.equal(t.packets[0].channel,'ExpCmd');assert.equal(t.packets[0].data,`${e.ExpRun}|${e.ExpRevision}|${e.ExpOfferVersion[0]}|${action}`);
    const packet=t.packets[0].data;t.flush();assert(e.ExpDone[0]);
    const before=[e.ExpGold[0],e.ExpPoints[0],e.ExpFixedCrit[0],e.ExpFixedSwift[0],e.ExpArcana.join(),e.ExpCardOwned.join()];
    e.syncData=packet;e.OnSync();assert.deepEqual([e.ExpGold[0],e.ExpPoints[0],e.ExpFixedCrit[0],e.ExpFixedSwift[0],e.ExpArcana.join(),e.ExpCardOwned.join()],before);
  }
});
check('배분은 보상 확정과 분리되고 전투 중에는 수정할 수 없음',()=>{
  const t=fresh(),e=t.e;t.start();t.click(t.common(-e.EXP_UI_STATS));t.click(t.common(101));
  assert.equal(e.ExpCritPoints[0],1);assert.equal(e.ExpDone[0],false);assert.deepEqual(t.roots(),[e.EXP_UI_STATS]);
  t.click(t.common(103));assert.equal(e.ExpCritPoints[0],0);
  e.ExpState=e.EXP_BATTLE;e.ExpRevision++;t.render();e.ExpUIOpen(e.EXP_UI_STATS);
  assert.equal(t.frame(e.ExpUIButtons[e.UIExpeditionCommon_StatsButton]).x,.090);
  assert.equal(t.frame(t.common(101)).enabled,false);assert.equal(t.frame(t.common(102)).enabled,false);
});
check('이동·투표·보상·상점에서 스탯 배분, 포인트 부족·한도·전투 제한 표시',()=>{
  for(const state of ['EXP_START','EXP_MOVE','EXP_VOTE','EXP_REWARD','EXP_SHOP']){
    const t=fresh(),e=t.e;t.start();e.ExpState=e[state];e.ExpRevision++;t.render();e.ExpUIOpen(e.EXP_UI_STATS);
    t.event(t.common(101),2);assert(t.frame(e.UIExpeditionCommon_ButtonBackdrops[e.UIExpeditionStats_AddCrit]).texture.endsWith('ActionHover.tga'));
    t.click(t.common(101));t.click(t.common(102));assert.equal(e.ExpCritPoints[0],1);assert.equal(e.ExpSwiftPoints[0],1);
    assert.equal(e.ExpDone[0],false);t.click(t.common(103));assert.equal(e.ExpCritPoints[0]+e.ExpSwiftPoints[0],0);
    e.ExpPoints[0]=1;t.render();t.click(t.common(101));
    assert.equal(t.frame(t.common(102)).enabled,false);assert(t.frame(e.ExpUIButtonLabels[e.UIExpeditionStats_AddSwift]).text.includes('포인트 없음'));
    e.ExpPoints[0]=40;e.ExpCritPoints[0]=30;t.render();assert.equal(t.frame(t.common(101)).enabled,false);
    assert(t.frame(e.ExpUIButtonLabels[e.UIExpeditionStats_AddCrit]).text.includes('최대 30포인트'));assert(t.frame(t.common(102)).enabled);
  }
  const t=fresh(),e=t.e;t.start();e.ExpState=e.EXP_BATTLE;t.render();e.ExpUIOpen(e.EXP_UI_STATS);
  e.ExpAction(0,101);assert.equal(e.ExpCritPoints[0],0);assert(t.frame(e.UIExpeditionStats_Hint).text.includes('전투 중'));
});
check('접기와 ESC 후 후보 유지, 상태 변경 시 자동 표시, 강화창과 겹침 차단',()=>{
  const t=fresh(),e=t.e;t.start();const offered=e.ExpStartCard[0],version=e.ExpOfferVersion[0];
  const toggle=e.ExpUIButtons[e.UIExpeditionCommon_PanelToggles[e.EXP_UI_CHOICE]];
  t.click(toggle);assert.deepEqual(t.roots(),[]);t.click(toggle);assert.equal(e.ExpStartCard[0],offered);assert.equal(e.ExpOfferVersion[0],version);
  e.UIExpeditionCommon_Escape();assert.deepEqual(t.roots(),[]);
  e.Enter(e.EXP_REWARD);assert.deepEqual(t.roots(),[e.EXP_UI_CHOICE]);
  e.F_UpgradeOnOff[0]=true;t.render();assert.deepEqual(t.roots(),[]);e.UIMap_Toggle();assert.equal(e.ExpUIPanel,e.EXP_UI_CHOICE);
  e.F_UpgradeOnOff[0]=false;t.render();assert.deepEqual(t.roots(),[e.EXP_UI_CHOICE]);
});
check('보상 리롤의 비용과 후보 버전, 오래된 요청 거부 및 사건 선택 화면 전환',()=>{
  const t=fresh(),e=t.e;t.start();e.Enter(e.EXP_REWARD);e.ExpGold[0]=500;t.render();
  const old=`${e.ExpRun}|${e.ExpRevision}|${e.ExpOfferVersion[0]}|1`;
  t.click(t.common(100));assert.equal(e.ExpGold[0],400);e.syncData=old;e.OnSync();assert.equal(e.ExpDone[0],false);
  assert.equal(Array.from({length:9},(_,i)=>t.card('Choice',i+1)).filter(t.visible).length,3);
  assert(e.ExpEventCandidate[0]>0);t.click(t.card('Choice',9));assert.deepEqual(t.roots(),[e.EXP_UI_EVENT]);
  assert(e.ExpEventDeadline[0]>0);t.click(t.card('Event',3));assert(e.ExpDone[0]);assert.deepEqual(t.roots(),[]);
});
check('상점의 가격 표시, 돈 부족/구매 완료 비활성화 및 정비 완료 처리',()=>{
  const t=fresh(),e=t.e;t.start();e.Enter(e.EXP_SHOP);e.ExpGold[0]=0;t.render();
  assert.equal(t.frame(t.card('Shop',1)).enabled,false);e.ExpGold[0]=1000;t.render();
  t.click(t.card('Shop',1));assert.equal(e.ExpShopSold[e.ExpKey(0,1)],true);assert.equal(t.frame(t.card('Shop',1)).enabled,false);
  const index=e.UIExpeditionChoice_ShopCards[1];assert(t.frame(e.UIExpeditionChoice_CardActionText[index]).text.includes('구매 완료'));
  t.click(t.common(10));assert(e.ExpDone[0]);assert.deepEqual(t.roots(),[]);
});
check('선택·투표·사건·상점의 같은 버튼으로 접기/열기, 전환·확정 시 잔여 버튼 제거',()=>{
  for(const state of ['EXP_START','EXP_VOTE','EXP_REWARD','EXP_SHOP','event']){
    const t=fresh(),e=t.e;t.start();
    if(state==='event'){e.Enter(e.EXP_REWARD);t.click(t.card('Choice',9));}else e.Enter(e[state]);
    const panel=e.ExpUIPanel,index=e.UIExpeditionCommon_PanelToggles[panel],button=e.ExpUIButtons[index],f=t.frame(button);
    const geometry=[f.parent,f.relative,f.x,f.y,f.w,f.h];assert.equal(f.parent,0);
    for(let repeat=0;repeat<2;repeat++){
      t.click(button);assert.deepEqual(t.roots(),[]);assert(t.visible(button));assert(t.frame(e.ExpUIButtonLabels[index]).text.includes('열기'));
      t.render();assert(t.visible(button));assert.deepEqual([f.parent,f.relative,f.x,f.y,f.w,f.h],geometry);
      t.click(button);assert.deepEqual(t.roots(),[panel]);assert(t.frame(e.ExpUIButtonLabels[index]).text.includes('접기'));
    }
    t.click(button);e.F_UpgradeOnOff[0]=true;t.render();assert(!t.visible(button));
    e.F_UpgradeOnOff[0]=false;t.render();assert(t.visible(button));
    e.ExpDone[0]=true;t.render();assert(!t.visible(button));
    e.Enter(e.EXP_SHOP);assert.deepEqual(t.roots(),[e.EXP_UI_SHOP]);
    e.QueueNext(e.EXP_BATTLE);assert.equal(e.UIExpeditionCommon_FoldedPanel,0);
    assert(e.UIExpeditionCommon_PanelToggles.slice(1,8).every(i=>!t.visible(e.ExpUIButtons[i])));
  }
});
check('상점 잔액과 불가 사유 갱신, 일반 구매 버튼의 강조 및 동기화',()=>{
  const t=fresh(),e=t.e;t.start();e.Enter(e.EXP_SHOP);e.ExpGold[0]=0;t.render();
  const gold=()=>t.frame(e.UIExpeditionChoice_ShopGold).text;
  const label=action=>t.frame(e.ExpUIButtonLabels[e.UIExpeditionChoice_ShopButtons[action]]).text;
  assert(t.visible(e.UIExpeditionChoice_ShopGold));assert(gold().includes('보유 골드'));assert(gold().includes('0 G'));
  assert(label(4).includes('부족'));assert(label(6).includes('부족'));
  const cardIndex=e.UIExpeditionChoice_ShopCards[1];assert(t.frame(e.UIExpeditionChoice_CardActionText[cardIndex]).text.includes('골드 부족'));
  e.ExpGold[0]=450;t.render();t.event(t.common(4),2);
  assert(t.frame(e.UIExpeditionCommon_ButtonBackdrops[e.UIExpeditionChoice_ShopButtons[4]]).texture.endsWith('ActionHover.tga'));
  t.click(t.common(4));assert.equal(e.ExpFixedCrit[0],100);assert.equal(e.ExpGold[0],150);assert(gold().includes('150 G'));
  assert(label(4).includes('구매 완료'));assert(label(5).includes('구매 완료'));assert.equal(t.frame(t.common(5)).enabled,false);
  const charges=e.PlayerItem1[0].charges;t.click(t.common(6));t.click(t.common(6));
  assert.equal(e.PlayerItem1[0].charges,charges+2);assert.equal(e.ExpGold[0],0);assert(gold().includes('0 G'));
  assert(label(6).includes('한도 도달'));assert.equal(t.frame(t.common(6)).enabled,false);assert(label(7).includes('부족'));
});
check('선택 창의 클릭 영역이 분리되고 화면 및 기본 HUD 영역을 침범하지 않음',()=>{
  for(const state of ['start','reward','shop']){
    const t=fresh(),e=t.e;t.start();if(state!=='start')e.Enter(state==='reward'?e.EXP_REWARD:e.EXP_SHOP);
    const group=state==='shop'?'Shop':'Choice',ids=(state==='start'?[1,2,3,4,5,6]:state==='reward'?[7,8,9]:[1,2,3]).map(i=>t.card(group,i));
    const rectangles=ids.map(id=>t.frame(id));
    for(const f of rectangles){const p=t.frame(f.parent);assert(p.x+f.x>=0&&p.x+f.x+f.w<=.8);assert(p.y+f.y-f.h>=.12);}
    for(let i=1;i<rectangles.length;i++)assert(rectangles[i-1].x+rectangles[i-1].w<rectangles[i].x);
  }
});
check('다른 플레이어의 확정이 내 창을 닫지 않음',()=>{
  const t=fresh(),e=t.e;t.start();e.ExpMember[1]=true;e.ExpDone[1]=true;t.render();assert.deepEqual(t.roots(),[e.EXP_UI_CHOICE]);
  e.localPlayer=1;e.UIExpeditionCommon_SeenRevision=-1;t.render();assert.deepEqual(t.roots(),[]);
});
if(process.argv[2]){
  const t=fresh(),e=t.e,out=[];
  const snapshot=name=>out.push({name,frames:[...t.frames.values()].filter(f=>f.id!==0&&t.visible(f.id)).map(({scripts,...f})=>f)});
  t.start();snapshot('start');e.ExpUIOpen(e.EXP_UI_STATS);snapshot('stats');e.Enter(e.EXP_REWARD);snapshot('reward');e.Enter(e.EXP_SHOP);e.ExpGold[0]=500;t.render();snapshot('shop');e.ExpUIOpen(e.EXP_UI_MAP);snapshot('map');
  fs.writeFileSync(process.argv[2],JSON.stringify(out,null,2));
}
console.log(`${checks} UI scenario groups passed. Mock frame/native execution only; real game rendering and input remain untested.`);
