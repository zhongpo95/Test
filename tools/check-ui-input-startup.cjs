// 로딩 중 전역 입력 미등록과 영웅 선택 후 한 번 등록 및 게임 타이머 갱신을 검증한다.
const fs = require('fs'), path = require('path'), assert = require('node:assert/strict');
const {environment} = require('./check-expedition.cjs');
const root = path.resolve(__dirname, '..');
let checks = 0;
function check(name, test) { test(); checks++; console.log('PASS ' + name); }
function gate() {
  let created = 0;
  const {env:e} = environment(['UI/UI_InputGate.j'], {
    CreateTrigger: () => {created++;return {actions:[]};},
    Condition: fn => fn, TriggerAddCondition: (t,fn) => t.actions.push(fn),
    TriggerEvaluate: t => t.actions.every(fn=>fn()),
  });
  e.PickCheck = [false,false,false,false];
  return {e,created:()=>created};
}
check('로딩 대기가 길어져도 게임 전역 입력을 등록하지 않음',()=>{
  const {e,created}=gate(),calls=[];
  e.UIInputAfterPick(()=>{calls.push('TAB');return true;});e.UIInputAfterPick(()=>{calls.push('LeftUp');return true;});
  for(let i=0;i<2000;i++)e.UIInputGate_Tick();
  assert.deepEqual(calls,[]);assert.equal(created(),2);
});
check('선택 순서가 달라도 모든 클라이언트와 관전자의 등록·평가 순서가 같음',()=>{
  const clients=[0,1,4].map(pid=>{
    const {e}=gate(),calls=[];e.localPlayer=pid;e.online=[true,true,false,false];
    const evaluate=e.TriggerEvaluate;e.TriggerEvaluate=t=>{calls.push('evaluate');return evaluate(t);};
    e.UIInputAfterPick(()=>{calls.push('keys');return true;});e.UIInputAfterPick(()=>{calls.push('mouse');return true;});
    return {e,calls};
  });
  for(const {e,calls} of clients){
    e.PickCheck[1]=true;for(let i=0;i<30;i++)e.UIInputGate_Tick();assert.deepEqual(calls,[]);
    e.PickCheck[0]=true;for(let i=0;i<30;i++)e.UIInputGate_Tick();
    assert.deepEqual(calls,['evaluate','keys','evaluate','mouse']);
    e.UIInputAfterPick(()=>{calls.push('late');return true;});e.UIInputGate_Tick();e.UIInputGate_Tick();
    assert.deepEqual(calls,['evaluate','keys','evaluate','mouse','evaluate','late']);
  }
  assert.deepEqual(clients[0].calls,clients[1].calls);assert.deepEqual(clients[0].calls,clients[2].calls);
});
check('전원 선택 후에도 프레임 생성 전이면 대기하고 준비 후 한 번 등록',()=>{
  const {e}=gate();let ready=false,called=0;e.PickCheck[0]=true;
  e.UIInputAfterPick(()=>{if(!ready)return false;called++;return true;});
  for(let i=0;i<20;i++)e.UIInputGate_Tick();assert.equal(called,0);
  ready=true;e.UIInputGate_Tick();e.UIInputGate_Tick();assert.equal(called,1);
});
check('미선택 참가자 이탈 후 남은 참가자 선택으로 등록, 빈 방은 미등록',()=>{
  const {e}=gate();let called=0;e.online=[true,true,false,false];e.PickCheck[0]=true;
  e.UIInputAfterPick(()=>{called++;return true;});e.UIInputGate_Tick();assert.equal(called,0);
  e.online[1]=false;e.UIInputGate_Tick();assert.equal(called,1);
  const empty=gate().e;empty.online=[false,false,false,false];empty.UIInputAfterPick(()=>{throw Error('empty');});empty.UIInputGate_Tick();
});
check('컴퓨터 슬롯은 선택을 기다리지 않음',()=>{
  const {e}=gate();let called=0;e.online=[true,true,false,false];e.PickCheck[0]=true;
  e.GetPlayerController=p=>p===0?e.MAP_CONTROL_USER:99;
  e.UIInputAfterPick(()=>{called++;return true;});e.UIInputGate_Tick();assert.equal(called,1);
});
check('미선택자와 관전자의 이모지·HUD·인벤토리 클릭은 처리하지 않음',()=>{
  const {env:e}=environment(['UI/UI_Emoji.j','UI/UI_SkillHUD.j'],{
    DzFrameShow:()=>{throw Error('unpicked UI access');},DzSyncData:()=>{throw Error('unpicked sync');},
    DzGetTriggerKeyPlayer:()=>e.localPlayer,
  });
  for(const pid of [0,4]){
    e.localPlayer=pid;e.PickCheck[pid]=false;
    e.TKey();e.TKey2();e.UISkillHUD_AltClick();
  }
});
check('인벤토리 가운데 클릭도 미선택 상태에서 UI 접근 전에 반환',()=>{
  const source=fs.readFileSync(path.join(root,'UI/UI_Item.j'),'utf8');
  const body=source.match(/private function MouseRightClick takes nothing returns nothing([\s\S]*?)endfunction/)[1];
  assert(body.indexOf('if not PickCheck[pid] then')<body.indexOf('call DzFrameShow'));
});
check('키·클릭 등록은 모두 지연 함수 내부에 있고 기존 선택창 휠은 유지',()=>{
  const names=['UI_Info','UI_Info2','UI_SkillLevel','UI_Arcana','UI_Overlay','UI_SkillHUD','UI_Map','UI_Emoji','UI_Item'];
  let bindings=0;
  for(const name of names){
    const source=fs.readFileSync(path.join(root,'UI',name+'.j'),'utf8');
    const bind=source.match(/private function BindInput takes nothing returns boolean([\s\S]*?)endfunction/);
    assert(bind,name+' missing BindInput');
    const calls=bind[1].match(/call DzTriggerRegister(?:Key|Mouse)EventByCode\([^\n]+/g)||[];
    assert(calls.length>0,name);bindings+=calls.length;
    const remaining=source.replace(bind[0],'').replace(/\/\/[^\n]*/g,'');
    assert(!/call DzTriggerRegister(?:Key|Mouse)EventByCode/.test(remaining),name+' registers early');
    assert.equal((remaining.match(/call UIInputAfterPick\(function BindInput\)/g)||[]).length,1,name);
  }
  assert.equal(bindings,11);
  const pick=fs.readFileSync(path.join(root,'UI/UI_Pick.j'),'utf8');
  assert(pick.includes('DzTriggerRegisterMouseWheelEventByCode(t, false, function WheelPickScroll)'));
  const fps=fs.readFileSync(path.join(root,'UI/UI_FPS.j'),'utf8').replace(/\/\/[^\n]*/g,'');
  assert(!fps.includes('DzFrameSetUpdateCallback'));
});
check('화면 갱신 훅 없이 게임 타이머로 이동 아이콘 갱신, 준비 전·최소화 중 프레임 접근 차단',()=>{
  const positions=[],shows=[],timers=[];
  const {env:e}=environment(['UI/UI_FPS.j'],{
    F_PickUp:0,F_ItemClickNumber:200,PickUpOn:false,EmojiOn:false,JN_FRAMEPOINT_CENTER:4,
    DzFrameSetUpdateCallbackByCode:()=>{throw Error('Unsafe render hook registration');},
    TimerStart:(t,seconds,repeat,fn)=>timers.push({seconds,repeat,fn}),
    DzGetWindowWidth:()=>1600,DzGetWindowHeight:()=>942,
    DzGetMouseXRelative:()=>800,DzGetMouseYRelative:()=>450,
    DzFrameSetAbsolutePoint:(...args)=>positions.push(args),DzFrameShow:(...args)=>shows.push(args),
  });
  e.PickCheck[0]=false;e.FPS_Main();assert.equal(timers.length,1);assert.equal(timers[0].seconds,.03);
  timers[0].fn();assert.equal(shows.length,0);
  e.PickCheck[0]=true;timers[0].fn();assert.equal(shows.length,0);
  e.F_PickUp=17;e.F_ItemClickNumber=2;e.PickUpOn=true;timers[0].fn();
  assert.equal(positions.length,1);assert.equal(positions[0][0],17);assert(Math.abs(positions[0][2]-.4025)<1e-9);
  e.DzGetWindowWidth=()=>0;timers[0].fn();assert.equal(positions.length,1);
  e.DzGetWindowWidth=()=>1600;e.DzGetWindowHeight=()=>42;timers[0].fn();assert.equal(positions.length,1);
});
console.log(`${checks} startup checks passed. Native Dz dispatch and loading-screen stability require in-game validation.`);
