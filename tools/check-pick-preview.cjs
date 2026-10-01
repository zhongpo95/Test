// 실제 선택창 생성과 동기화된 미리보기 클릭의 플레이어별 화면 격리를 모의 검증한다.
const assert = require('node:assert/strict');
const {environment} = require('./check-expedition.cjs');
const functions = ['Main','Main2','ClickBBDButton','PickHeroName','PickPreviewTexture','PickHeroSkinCount',
  'PickSkinName','PickValidSkinNumber','PickSkinUnlocked','PickHeroValue','PickHeroIsSaved',
  'PickMaxScrollOffset','PickMaxScrollRow','PickVisibleHeroNumber','RefreshPickScroll',
  'HidePickPortraits','RefreshPickSkinList','ShowPickPreview','RefreshPickConfirm','RefreshPickCards','TracePick',
  'ClickPickHeroButton','ClickSkinButton','ChangePickScrollSlider','SetPickScrollOffset','PickSelectedSkinNumber'];
let checks = 0;
function check(name, test) { test(); checks++; console.log('PASS ' + name); }
function client(localPlayer) {
  let e, count = 0, eventFrame = 0, eventPlayer = 0;
  const frames = new Map([[0,{type:'GAME'}]]), logs = [];
  const no = () => {}, frame = id => {assert(frames.has(id), 'Unknown frame ' + id);return frames.get(id);};
  const {env,records} = environment(['UI/UI_Pick.j'], {
    gg_rct_Pick: 0, JN_FRAMEPOINT_CENTER: 4, JN_FRAMEPOINT_TOP: 1, JN_FRAMEPOINT_BOTTOM: 7,
    JN_FRAMEEVENT_MOUSE_UP: 4, JN_FRAMEEVENT_SLIDER_VALUE_CHANGED: 14,
    SetCameraBoundsToRectForPlayerBJ: no, SetCameraPositionForPlayer: no, DzLoadToc: no,
    DzGetGameUI: () => 0, FrameCount: () => count + 1, DzGetColor: (...rgba) => rgba,
    DzCreateFrameByTagName: (type,name,parent) => {frame(parent);const id=++count;frames.set(id,{type,parent,scripts:{},shown:true});return id;},
    DzFrameSetTexture: (id,texture) => {frame(id).texture=texture;},
    DzFrameSetText: (id,text) => {assert.equal(frame(id).type,'TEXT');frame(id).text=text;},
    DzFrameShow: (id,shown) => {frame(id).shown=shown;},
    DzFrameSetEnable: (id,enabled) => {assert.notEqual(frame(id).type,'BACKDROP');frame(id).enabled=enabled;},
    DzFrameSetSize: (id,w,h) => Object.assign(frame(id),{w,h}),
    DzFrameSetPoint: (id,point,relative) => {frame(id);frame(relative);},
    DzFrameSetAllPoints: (id,relative) => {frame(id);frame(relative);},
    DzFrameSetAbsolutePoint: id => frame(id), DzFrameClearAllPoints: id => frame(id),
    DzFrameSetVertexColor: id => frame(id), DzFrameSetAlpha: id => frame(id), JNFrameSetLevel: id => frame(id),
    DzFrameSetMinMaxValue: (id,min,max) => Object.assign(frame(id),{min,max}),
    DzFrameSetStepValue: (id,step) => {frame(id).step=step;}, DzFrameSetValue: (id,value) => {frame(id).value=value;},
    DzFrameSetScriptByCode: (id,event,callback,sync) => {frame(id).scripts[event]={callback,sync};},
    DzGetTriggerUIEventFrame: () => eventFrame, DzGetTriggerUIEventPlayer: () => eventPlayer,
    DzSyncData: () => {throw Error('A preview must not create or load a hero');},
    JNWriteLog: message => logs.push(message),
  }, functions.map(name => 'UIPick_' + name));
  e=env;e.localPlayer=localPlayer;e.PickCheck=[false,false,false,false];
  e.UIPick_Main();e.UIPick_Main2();
  const click = (slot,player=localPlayer) => {
    eventFrame=e.FP_HeroB[slot];eventPlayer=player;
    const binding=frame(eventFrame).scripts[4];
    assert.equal(binding.sync,true, 'First image click must bypass the asynchronous RunFunction route');
    binding.callback();
  };
  return {e,frames,frame,logs,records,click};
}
const snapshot = t => JSON.stringify({frames:[...t.frames],hero:t.e.SHNumber,skin:t.e.PickSkinNumber,
  traced:t.e.UIPick_PickPreviewTraced,picked:t.e.PickCheck,units:t.e.MainUnit,records:[...t.records],logs:t.logs});
check('실제 생성한 12개 이미지 버튼은 동기화된 이벤트를 사용하고 나머지 선택 이벤트는 유지',()=>{
  const t=client(0);
  for(let i=1;i<=12;i++)assert.equal(t.frame(t.e.FP_HeroB[i]).scripts[4].sync,true);
  for(const id of [...t.e.FP_SkinB.slice(1,3),t.e.FP_SelectB])assert.equal(t.frame(id).scripts[4].sync,false);
  assert.equal(t.frame(t.e.FP_ScrollB).scripts[14].sync,false);
});
check('첫 이미지 클릭으로 미리보기와 생성 버튼이 표시되고 영웅 생성 및 저장은 실행되지 않음',()=>{
  const t=client(0),before=JSON.stringify([t.e.MainUnit,t.e.PickCheck,[...t.records]]);
  t.click(1);
  assert.equal(t.e.SHNumber,1);assert.equal(t.e.PickSkinNumber,1);
  assert.equal(t.frame(t.e.FP_PotBD[1]).shown,true);assert.equal(t.frame(t.e.FP_PotBD[1]).texture,'HeroBack1.blp');
  assert.equal(t.frame(t.e.FP_SelectBBD).shown,true);assert.equal(t.frame(t.e.FP_SelectBT).text,'생성');
  assert.equal(JSON.stringify([t.e.MainUnit,t.e.PickCheck,[...t.records]]),before);
  assert.equal(t.logs.length,2);assert(t.logs[0].includes('preview-begin hero=1'));assert(t.logs[1].includes('preview-complete'));
});
check('같은 클릭을 전원과 관전자에게 전달해도 선택자만 화면과 지역 미리보기 상태를 갱신',()=>{
  const clients=[0,1,4].map(client),before=clients.map(snapshot);
  for(const t of clients)t.click(2,1);
  assert.equal(snapshot(clients[0]),before[0]);assert.equal(snapshot(clients[2]),before[2]);
  assert.equal(clients[1].e.SHNumber,2);assert.equal(clients[1].frame(clients[1].e.FP_PotBD[2]).shown,true);
  assert.equal(clients[1].logs.length,2);
});
check('서로 다른 참가자의 연속 선택이 다른 클라이언트의 선택과 스킨을 덮어쓰지 않음',()=>{
  const clients=[0,1,4].map(client);
  for(const t of clients)t.click(2,0);
  clients[0].e.PickSkinNumber=2;
  const first=snapshot(clients[0]);
  for(const t of clients)t.click(3,1);
  assert.equal(snapshot(clients[0]),first);assert.equal(clients[1].e.SHNumber,3);assert.equal(clients[2].e.SHNumber,0);
});
check('저장된 영웅은 로드로 표시하고 캐릭터 변경 시 이전 초상화와 스킨을 정리',()=>{
  const t=client(0);t.records.set('0:영웅2','saved');t.click(2);
  assert.equal(t.frame(t.e.FP_SelectBT).text,'로드');t.e.PickSkinNumber=2;t.click(3);
  assert.equal(t.e.PickSkinNumber,1);assert.equal(t.frame(t.e.FP_PotBD[2]).shown,false);
  assert.equal(t.frame(t.e.FP_PotBD[3]).shown,true);assert.equal(t.frame(t.e.FP_SkinB[2]).shown,false);
});
check('잠금 카드와 마지막 스크롤 행에서도 유효한 프레임만 접근하고 진단 로그는 첫 클릭 두 줄로 제한',()=>{
  const t=client(0);t.click(4);assert.equal(t.frame(t.e.FP_SelectBBD).shown,false);
  t.e.PickScrollOffset=4;t.click(12);assert.equal(t.e.SHNumber,16);
  assert.equal(t.frame(t.e.FP_PotBD[16]).shown,true);assert.equal(t.frame(t.e.FP_SelectBBD).shown,false);
  t.e.PickScrollOffset=0;for(let i=0;i<100;i++)t.click(i%3+1);
  assert.equal(t.logs.length,2);
});
console.log(`${checks} preview checks passed. Native Dz dispatch and crash recovery require in-game validation.`);
