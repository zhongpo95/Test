// 실제 JASS 진행 함수를 모의 네이티브 환경에서 실행하여 중복 선택과 정산 경계를 검증한다.
const fs = require('fs'), path = require('path'), assert = require('node:assert/strict');
const root = path.resolve(__dirname, '..');
let checks = 0;
function check(name, test) { test(); checks++; console.log('PASS ' + name); }
function environment(files, extras = {}, onlyFunctions = null) {
  const env = {}, records = new Map(), saves = [], pauses = new Map();
  let seed = 41, unitId = 100;
  const no = () => {};
  Object.assign(env, {
    localPlayer: 0, eventPlayer: 0, syncData: '', uploadAccepted: true, uploadSuccess: true,
    online: [true, false, false, false], selected: [true, true, true, true], home: true,
    PLAYER_SLOT_STATE_PLAYING: 1, MAP_CONTROL_USER: 1, PLAYER_NEUTRAL_AGGRESSIVE: 12,
    UNIT_STATE_LIFE: 1, UNIT_STATE_MAX_LIFE: 2, PLAYER_DATA: [0, 1, 2, 3],
    PLAYER_NEUTRAL_PASSIVE: 15, PATHING_TYPE_WALKABILITY: 1, bj_RADTODEG: 180 / Math.PI,
    PlayerSlotNumber: [1, 1, 1, 1], MainUnit: [0, 1, 2, 3], PickCheck: [true, true, true, true],
    PlayerItem1: [0, 1, 2, 3].map(() => ({charges: 2})),
    PlayerItem2: [0, 1, 2, 3].map(() => ({charges: 2})),
    PlayerItem3: [0, 1, 2, 3].map(() => ({charges: 2})),
    MapSt: [null, {caster: null}, {caster: null}, {caster: null}, {caster: null}],
    MapRectCheck: [false, true, true, true, true], Mapthema: [0, 0, 0, 0, 0],
    bj_FORCE_ALL_PLAYERS: 0, gg_rct_Home: 0, Eitem: Array.from({length: 4}, () => Array(20).fill('0')),
    EQUIP_SLOT_MAX: 7, MapName: '', MapApi: '', ArcanaData: 0,
    ArcanaText: Array.from({length: 64}, (_, i) => '각인' + i),
    UnitHP: Array(8192).fill(1000), UnitHPMAX: Array(8192).fill(1000), UnitSD: Array(8192).fill(0), UnitSDMAX: Array(8192).fill(0),
    UnitArm: Array(8192).fill(0), UnitCasting: Array(8192).fill(false),
    Player: x => x, GetPlayerId: x => x, GetLocalPlayer: () => env.localPlayer,
    GetPlayerSlotState: p => env.online[p] ? 1 : 0, GetPlayerController: () => 1,
    GetPlayerName: p => 'P' + p, GetTriggerPlayer: () => env.eventPlayer,
    DzGetTriggerSyncPlayer: () => env.eventPlayer, DzGetTriggerSyncData: () => env.syncData,
    JNStringSplit: (s, sep, i) => s.split(sep)[i] || '', I2S: String, S2I: s => parseInt(s) || 0,
    I2R: Number, R2I: Math.trunc, IMinBJ: Math.min, IMaxBJ: Math.max,
    RMinBJ: Math.min, RMaxBJ: Math.max, ModuloInteger: (a, b) => a % b, SquareRoot: Math.sqrt,
    GetRandomInt: (a, b) => { seed = (seed * 1664525 + 1013904223) >>> 0; return a + seed % (b - a + 1); },
    UnitAlive: u => typeof u === 'number' || !!u && !u.dead && !u.removed, RectContainsUnit: () => env.home, GetUnitState: () => 10000,
    GetUnitX: u => typeof u === 'number' ? u * 100 : u.x, GetUnitY: u => typeof u === 'number' ? 0 : u.y, GetUnitFacing: () => 0, GetUnitMoveSpeed: () => 400,
    IndexUnit: x => typeof x === 'number' ? x : x.id, LoadInteger: () => 0, HeadTrue: () => true, BackTrue: () => false, AngleWBW: () => 0,
    GetRandomReal: (a,b) => a + env.GetRandomInt(0,10000) / 10000 * (b-a),
    IsTerrainPathable: () => false, CreateUnit: (p,raw,x,y) => ({id:unitId++,p,raw,x,y,abilities:new Set()}),
    KillUnit: u => {u.dead=true;}, RemoveUnit: u => {u.removed=true;},
    CreateTextTag: () => ({}), DestroyTextTag: t => {t.destroyed=true;}, SetTextTagPermanent: no, SetTextTagColor: no,
    SetTextTagText: (t,text) => {t.text=text;}, SetTextTagPosUnit: (t,u,height) => {t.unit=u;t.height=height;},
    SetTextTagVisibility: (t,visible) => {t.visible=visible;}, IsUnitVisible: () => true,
    R2SW: (value,width,precision) => value.toFixed(precision), BOSSHPSTART: no,
    UnitAddAbility: (u,a) => u.abilities.add(a), UnitRemoveAbility: (u,a) => u.abilities.delete(a), GetUnitAbilityLevel: (u,a) => u.abilities.has(a) ? 1 : 0,
    IsUnitInRange: (u,v,r) => Math.hypot(env.GetUnitX(u)-env.GetUnitX(v),env.GetUnitY(u)-env.GetUnitY(v))<=r,
    SetUnitX: (u,x) => {u.x=x;}, SetUnitY: (u,y) => {u.y=y;}, Atan2: Math.atan2,
    SetUnitAnimation: no, SetUnitScale: no, SetUnitVertexColor: no, SetUnitTimeScale: no, SetUnitMoveSpeed: no, SetUnitAcquireRange: no, SetUnitPathing: no,
    IssuePointOrder: no, IssueImmediateOrder: no, SetUnitFacing: no, SelectUnit: no, TimerStart: no, PauseTimer: no, BossDeal: no,
    CreateTimer: () => ({}), CreateTrigger: () => ({}), TriggerExecute: no,
    PauseUnit: (u, v) => pauses.set(u, v), GetRectCenterX: () => 0, GetRectCenterY: () => 0,
    MapRectReturn: x => x, MapResetAll: no, MapReset: (x) => {env.MapRectCheck[x] = true;},
    MapSet: (x, theme) => {env.Mapthema[x] = theme; env.MapRectCheck[x] = true; return x;},
    Rect: (x,y,w,h) => ({x,y,w,h}), RemoveRect: no,
    SetUnitState: no, SetUnitPosition: no, SetUnitInvulnerable: no, ReviveHero: no,
    PlayerStatsSet: no, ItemUIStatsSet: no, RefreshHP: no, ShowPlayerPotionDisplay: no,
    ResetPlayerPotionCharges: no, SetItemCharges: (item, n) => { item.charges = n; }, GetItemCharges: item => item.charges,
    SetCameraBoundsToRectForPlayerBJ: no, SetCameraPosition: no, DisplayTimedTextToForce: no,
    DisplayTimedTextToPlayer: no, ShowUnit: no, ExpCombatStop: no, ExpCombatStart: no,
    StashLoad: (p, k, d) => records.get(p + ':' + k) ?? d,
    StashSave: (p, k, v) => {records.set(p + ':' + k, v);},
    GetItemIDs: s => Number(String(s).match(/ID(\d+)/)?.[1] || 0),
    additem: (p) => {
      const key = p + ':영웅1.아이템50';
      records.set(key, 'ID27;C' + (Number(records.get(key)?.match(/C(\d+)/)?.[1] || 0) + 1) + ';');
    },
    JNStashNetGetPlayer: () => env.eventPlayer, JNStashNetGetFinished: () => true,
    JNStashNetGetResult: () => env.uploadSuccess,
    JNStashNetUploadUser: p => {saves.push({p, snapshot: new Map(records)});return env.uploadAccepted;},
  });
  Object.assign(env, extras);
  const expr = s => s.split(/("(?:\\.|[^"\\])*")/g).map((p, i) => i % 2 ? p : p.replace(/\band\b/g, '&&').replace(/\bor\b/g, '||').replace(/\bnot\b/g, '!').replace(/\bfunction (\w+)/g, '$1')).join('');
  const sources = files.map(f => {
    let source = fs.readFileSync(path.join(root, f), 'utf8').replace(/\/\*[\s\S]*?\*\//g, '');
    // UI 검사는 서로 다른 library의 private 이름을 구분해 실제 창과 콜백을 함께 실행한다.
    if (!f.startsWith('UI/')) return source;
    const prefix = source.match(/\blibrary (\w+)/)[1] + '_';
    const names = [...source.matchAll(/private (?:constant )?(?:function|integer|real|boolean|string|trigger|timer)(?: array)? (\w+)/g)].map(m => m[1]);
    for (const name of new Set(names)) {
      source = source.split(/("(?:\\.|[^"\\])*")/g).map((part, i) => i % 2 ? part : part.replace(new RegExp('\\b' + name + '\\b', 'g'), prefix + name)).join('');
    }
    return source;
  });
  for (const s of sources) for (const block of s.matchAll(/\bglobals\b([\s\S]*?)\bendglobals\b/g)) {
    for (const line of block[1].split(/\r?\n/)) {
      const m = line.trim().match(/^(?:private )?(?:constant )?(integer|boolean|real|string|trigger|timer|stash|unit|rect|texttag) (array )?(\w+)(?:\s*=\s*(.*))?/);
      if (!m) continue;
      const initial = m[1] === 'boolean' ? false : m[1] === 'string' ? '' : ['unit','texttag'].includes(m[1]) ? null : 0;
      env[m[3]] = m[2] ? Array(8192).fill(initial) : m[4] ? Function('env', 'with(env){return ' + expr(m[4]) + '}')(env) : initial;
    }
  }
  const skip = new Set(['Init', 'init', 'onInit', 'download', 'downloadCallback', 'uploadCallback', 'upload']);
  for (const s of sources) for (const m of s.matchAll(/(?:private )?function (\w+) takes (.*?) returns (\w+)([\s\S]*?)endfunction/g)) {
    const [, name, args, returns, body] = m;
    if (skip.has(name)) continue;
    if (onlyFunctions && !onlyFunctions.includes(name)) continue;
    const params = args === 'nothing' ? '' : args.split(',').map(p => p.trim().split(/\s+/)[1]).join(',');
    const js = [];
    for (let line of body.split(/\r?\n/)) {
      line = line.trim(); if (!line || line.startsWith('//')) continue;
      if (line.startsWith('local ')) {
        const v = line.match(/^local \w+ (\w+)(?:\s*=\s*(.*))?/);
        js.push(`let ${v[1]}=${v[2] ? expr(v[2]) : '0'};`);
      } else if (line === 'loop') js.push('for(let guard=0;guard<10000;guard++){');
      else if (line === 'endloop' || line === 'endif') js.push('}');
      else if (line === 'else') js.push('}else{');
      else if (line.startsWith('elseif ')) js.push('}else if(' + expr(line.slice(7, -5)) + '){');
      else if (line.startsWith('if ')) js.push('if(' + expr(line.slice(3, -5)) + '){');
      else if (line.startsWith('exitwhen ')) js.push('if(' + expr(line.slice(9)) + ')break;');
      else if (line.startsWith('set ')) js.push(expr(line.slice(4)) + ';');
      else if (line.startsWith('call ')) js.push(expr(line.slice(5)) + ';');
      else if (line.startsWith('return ')) js.push('return ' + (returns === 'integer' ? 'Math.trunc(' + expr(line.slice(7)) + ')' : expr(line.slice(7))) + ';');
      else if (line === 'return') js.push('return;');
      else throw Error(name + ': unsupported ' + line);
    }
    try {env[name] = Function('env', `with(env){return function(${params}){${js.join('\n')}}}`)(env);}
    catch (e) {throw Error(name + ': ' + e.message);}
  }
  return {env, records, saves, pauses};
}
module.exports = {environment};
if (require.main === module) {
const files = ['Data/Data_Expedition.j', 'Data/Data_ExpeditionEvents.j', 'System/ExpeditionEffects.j', 'System/SaveLoad.j', 'System/Expedition.j'];
const fresh = () => environment(files);
check('라이프 손실의 모든 구간과 반올림 경계', () => {
  const {env:e} = fresh();
  for (const [n, base] of [[1,5],[8,5],[9,10],[15,10],[16,15],[22,15]]) for (const p of [-1,0,.1,.5,.999,1,2])
    assert.equal(e.ExpLoss(n,p), p >= 1 ? 0 : Math.ceil(base * (2 - Math.max(0,p))));
});
check('등급 경계 5500/9000/9950과 최대 40포인트', () => {
  const {env:e} = fresh();
  assert.deepEqual([1,5500,5501,9000,9001,9950,9951,10000].map(e.ExpGradeFromRoll), [1,1,2,2,3,3,4,4]);
  e.ExpPoints[0] = 38; e.GrantPoints(0,5); assert.equal(e.ExpPoints[0],40); assert.equal(e.ExpGold[0],60);
  e.GrantPoints(0,5); assert.equal(e.ExpGold[0],160);
});
check('개인 카드 공개 중복 방지와 소진 대체 보상', () => {
  const {env:e} = fresh();const drawn = Array.from({length:6}, () => e.DrawCard(0,1));
  assert.equal(new Set(drawn).size,6);assert.equal(e.DrawCard(0,1),0);assert(e.DrawCard(1,1)>0);
  e.GrantCard(0,0,1);assert.equal(e.ExpGold[0],150);
});
check('사건 예약 중복 방지, 미선택 해제, 거절 소모', () => {
  const {env:e} = fresh();e.ExpMember[0]=true;e.ExpMember[1]=true;
  e.RollOffers(0);const a=e.ExpEventCandidate[0];assert(a>0);e.RollOffers(1);assert.notEqual(e.ExpEventCandidate[1],a);
  e.ReleaseEvent(0);assert.equal(e.ExpEventReservation[a],0);assert.equal(e.ExpEventUsed[a],false);
  e.ExpEventCandidate[0]=4;e.ExpEventReservation[4]=1;e.ApplyEvent(0,3);assert.equal(e.ExpEventUsed[4],true);
  e.GetRandomInt=(a,b)=>a;e.RollOffers(0);assert.notEqual(e.ExpEventCandidate[0],4);
});
check('준비 인원, 영웅 선택, 마을 조건과 전투 구역 예약', () => {
  const {env:e,pauses} = fresh();e.online[1]=true;e.ExpReady[0]=true;e.TryStart();assert.equal(e.ExpState,0);
  e.ExpReady[1]=true;e.PickCheck[1]=false;e.TryStart();assert.equal(e.ExpState,0);
  e.PickCheck[1]=true;e.home=false;e.TryStart();assert.equal(e.ExpState,0);
  e.home=true;e.TryStart();assert.equal(e.ExpState,e.EXP_START);assert.equal(e.ExpPlayers,2);assert.equal(e.ExpPoints[0],5);
  assert.equal(e.MapRectCheck[e.ExpArena],false);assert.equal(e.Mapthema[e.ExpArena],1);assert.equal(pauses.get(0),true);
});
check('오래된 원정/화면/후보 요청과 시작 보상 중복 거부', () => {
  const {env:e}=fresh();e.ExpState=e.EXP_START;e.ExpMember[0]=true;e.ExpRun=2;e.ExpRevision=3;e.ExpOfferVersion[0]=4;
  for(const packet of ['1|3|4|6','2|2|4|6','2|3|3|6']){e.syncData=packet;e.OnSync();assert.equal(e.ExpGold[0],0);}
  e.syncData='2|3|4|6';e.OnSync();e.OnSync();assert.equal(e.ExpGold[0],200);
});
check('시작 무작위 능력치는 한 종류만 200 증가하고 마지막 선택은 골드', () => {
  for(const roll of [1,2]){
    const {env:e}=fresh();e.ExpState=e.EXP_START;e.ExpMember[0]=true;e.ExpPoints[0]=5;
    e.GetRandomInt=(min,max)=>{assert.equal(min,1);assert.equal(max,2);return roll;};
    e.ExpAction(0,2);e.ExpAction(0,2);
    assert.equal(e.ExpFixedCrit[0],roll===1?200:0);assert.equal(e.ExpFixedSwift[0],roll===2?200:0);
    assert.equal(e.ExpPoints[0],5);assert.equal(e.ExpGold[0],0);assert(e.ExpDone[0]);
  }
  const {env:e}=fresh();e.ExpState=e.EXP_START;e.ExpMember[0]=true;
  e.ExpAction(0,7);assert.equal(e.ExpDone[0],false);
  e.ExpAction(0,6);assert.equal(e.ExpGold[0],200);assert(e.ExpDone[0]);
});
check('리롤 비용 증가, 시간 유지, 확정 후 차단', () => {
  const {env:e}=fresh();e.ExpMember[0]=true;e.Enter(e.EXP_REWARD);e.ExpGold[0]=600;
  e.ExpAction(0,100);e.ExpAction(0,100);assert.equal(e.ExpGold[0],300);assert.equal(e.ExpSeconds,60);
  e.ExpAction(0,1);e.ExpAction(0,100);assert.equal(e.ExpGold[0],300);assert.equal(e.ExpPoints[0],5);
});
check('스탯 배분 한도, 초기화, 전투 중 변경 차단', () => {
  const {env:e}=fresh();e.ExpMember[0]=true;e.ExpState=e.EXP_SHOP;e.ExpPoints[0]=40;
  for(let i=0;i<40;i++)e.ExpAction(0,101);assert.equal(e.ExpCritPoints[0],30);
  for(let i=0;i<20;i++)e.ExpAction(0,102);assert.equal(e.ExpSwiftPoints[0],10);
  e.ExpState=e.EXP_BATTLE;e.ExpAction(0,103);assert.equal(e.ExpCritPoints[0],30);
  e.ExpState=e.EXP_SHOP;e.ExpAction(0,103);assert.equal(e.ExpCritPoints[0]+e.ExpSwiftPoints[0],0);
});
check('보상 시간 초과는 비용이나 패널티 없이 5포인트', () => {
  const {env:e}=fresh();e.ExpMember[0]=true;e.Enter(e.EXP_REWARD);e.ExpSeconds=1;e.Tick();
  assert.equal(e.ExpPoints[0],5);assert.equal(e.ExpGold[0],0);assert.equal(e.ExpState,e.EXP_MOVE);assert.equal(e.NextState,e.EXP_SHOP);
});
check('마지막 순간 사건 진입 후 40초, 내부 시간 초과는 거절', () => {
  const {env:e}=fresh();e.ExpMember[0]=true;e.Enter(e.EXP_REWARD);e.Elapsed=59;e.ExpSeconds=1;
  e.ExpEventCandidate[0]=1;e.ExpEventReservation[1]=1;e.ExpAction(0,3);assert.equal(e.ExpEventDeadline[0],99);
  for(let i=0;i<39;i++)e.Tick();assert.equal(e.ExpDone[0],false);
  e.Tick();assert.equal(e.ExpDone[0],true);assert.equal(e.ExpFixedCrit[0],0);assert.equal(e.ExpEventUsed[1],true);
});
check('사건 진입 후 이탈해도 만난 사건은 다시 나오지 않음', () => {
  const {env:e}=fresh();e.ExpMember[0]=e.ExpMember[1]=true;e.ExpPlayers=2;e.Enter(e.EXP_REWARD);
  e.ReleaseEvent(0);e.ExpEventCandidate[0]=4;e.ExpEventReservation[4]=1;e.ExpAction(0,3);
  assert.equal(e.ExpEventUsed[4],true);assert.equal(e.ExpChoiceSeconds(0),40);e.Leave();assert.equal(e.ExpEventReservation[4],0);assert.equal(e.ExpEventUsed[4],true);
});
check('비전투 대기 두 배와 시간 초과 경계, 이동 대기 6초', () => {
  for(const [state,seconds] of [['EXP_START',60],['EXP_REWARD',60],['EXP_VOTE',40],['EXP_SHOP',120]]){
    const {env:e}=fresh();e.ExpMember[0]=true;e.Enter(e[state]);assert.equal(e.ExpSeconds,seconds);
    for(let i=0;i<seconds-1;i++)e.Tick();assert.equal(e.ExpState,e[state]);assert.equal(e.ExpDone[0],false);
    e.Tick();assert.equal(e.ExpState,e.EXP_MOVE);assert.equal(e.ExpSeconds,6);
    for(let i=0;i<5;i++)e.Tick();assert.equal(e.ExpState,e.EXP_MOVE);
    e.Tick();assert.notEqual(e.ExpState,e.EXP_MOVE);
  }
});
check('상점 단일 구매와 물약 종류별 2회 및 할인 올림', () => {
  const {env:e}=fresh();e.ExpMember[0]=true;e.ExpState=e.EXP_SHOP;e.ExpGold[0]=2000;
  e.ExpShopCard[e.ExpKey(0,1)]=11;e.ExpAction(0,1);e.ExpAction(0,1);assert.equal(e.ExpGold[0],1750);
  assert.equal(e.ExpShopPrice(0,150),128);assert.equal(e.ExpShopPrice(0,75),64);
  e.ExpAction(0,6);e.ExpAction(0,6);e.ExpAction(0,6);assert.equal(e.ExpGold[0],1622);assert.equal(e.PlayerItem1[0].charges,4);
  e.ExpAction(0,4);const g=e.ExpGold[0];e.ExpAction(0,5);assert.equal(e.ExpGold[0],g);assert.equal(e.ExpFixedCrit[0],100);assert.equal(e.ExpFixedSwift[0],0);
});
check('팀 라이프 구매는 개인 골드와 파티 1회 한도', () => {
  const {env:e}=fresh();e.ExpMember[0]=e.ExpMember[1]=true;e.ExpState=e.EXP_SHOP;e.ExpLife=80;e.ExpGold[0]=e.ExpGold[1]=300;e.ExpLifeUseful=true;
  e.ExpAction(0,9);e.ExpAction(1,9);assert.equal(e.ExpLife,90);assert.equal(e.ExpGold[0],0);assert.equal(e.ExpGold[1],300);
});
check('마지막 전투만 남은 시험 상점은 라이프 상품 차단', () => {
  const {env:e}=fresh();e.ExpMember[0]=true;e.Enter(e.EXP_SHOP);e.ExpLife=80;e.ExpGold[0]=300;
  e.ExpAction(0,9);assert.equal(e.ExpLife,80);assert.equal(e.ExpGold[0],300);
});
check('승리 정산은 한 번, 일반전 실패 후 기본 보상', () => {
  const {env:e,records,saves}=fresh();e.PLAYER_DATA_SERVER_READY[0]=true;e.ExpMember[0]=true;e.ExpState=e.EXP_BATTLE;e.ExpStep=2;e.ExpArena=1;e.ExpWon=true;
  e.BattleFinished();e.BattleFinished();assert.equal(e.ExpConfirmedBattles[0],1);assert.equal(saves.length,1);assert.equal(records.get('0:영웅1.아이템50'),'ID27;C1;');
  e.ExpState=e.EXP_BATTLE;e.ExpNode=2;e.ExpProgress=.5;e.ExpWon=false;e.BattleFinished();assert.equal(e.ExpLife,92);assert.equal(e.ExpState,e.EXP_REWARD);assert.equal(e.ExpConfirmedBattles[0],1);
});
check('대표 보스 실패는 종료, 임시 성장 분리와 전투 구역 반환', () => {
  const {env:e}=fresh();e.ExpMember[0]=true;e.ExpState=e.EXP_BATTLE;e.ExpStep=4;e.ExpArena=1;e.ExpWon=false;e.ExpCardOwned[1]=true;
  e.BattleFinished();assert.equal(e.ExpState,e.EXP_RESULT);assert.equal(e.ExpMember[0],false);assert.equal(e.ExpHasCard(0,1),false);assert.equal(e.MapRectCheck[1],true);
});
check('저장 중 후속 요청은 최신 스냅샷으로 한 번 더 전송', () => {
  const {env:e,records,saves}=fresh();e.PLAYER_DATA_SERVER_READY[0]=true;
  e.RequestPlayerSave(0);records.set('0:award','2');e.RequestPlayerSave(0);e.RequestPlayerSave(0);assert.equal(saves.length,1);
  e.requestedSaveFinished();assert.equal(saves.length,2);assert.equal(saves[1].snapshot.get('0:award'),'2');assert.equal(e.PlayerSaveStatus[0],1);
  e.requestedSaveFinished();assert.equal(e.PlayerSaveStatus[0],2);
});
check('서버 로드 실패 차단, 저장 실패 재시도는 보상 재지급 없음', () => {
  const {env:e,saves}=fresh();assert.equal(e.RequestPlayerSave(0),false);assert.equal(saves.length,0);
  e.PLAYER_DATA_SERVER_READY[0]=true;e.uploadAccepted=false;assert.equal(e.RequestPlayerSave(0),false);assert.equal(e.PlayerSaveStatus[0],3);
  e.uploadAccepted=true;e.RequestPlayerSave(0);e.uploadSuccess=false;e.requestedSaveFinished();assert.equal(e.PlayerSaveStatus[0],3);assert.equal(e.ExpConfirmedBattles[0],0);
});
check('가방이 가득 찬 영구 재료는 보관 수량 유지', () => {
  const {env:e,records}=fresh();e.PLAYER_DATA_SERVER_READY[0]=true;
  for(let i=50;i<100;i++)records.set('0:영웅1.아이템'+i,'ID30;C1;');
  records.set('0:영웅1.시험원정.보관재료','2');e.ClaimMaterials(0);assert.equal(records.get('0:영웅1.시험원정.보관재료'),'2');
  records.set('0:영웅1.아이템50','0');e.ClaimMaterials(0);assert.equal(records.get('0:영웅1.시험원정.보관재료'),'0');assert.equal(records.get('0:영웅1.아이템50'),'ID27;C2;');
});
check('이탈 인원은 대기에서 제외, 마지막 이탈은 정리', () => {
  const {env:e}=fresh();e.ExpMember[0]=e.ExpMember[1]=true;e.ExpPlayers=2;e.ExpArena=1;e.ExpState=e.EXP_SHOP;e.ExpDone[0]=true;e.eventPlayer=1;
  e.Leave();assert.equal(e.ExpPlayers,1);e.Tick();assert.equal(e.ExpState,e.EXP_MOVE);
  e.eventPlayer=0;e.Leave();assert.equal(e.ExpState,e.EXP_RESULT);assert.equal(e.MapRectCheck[1],true);
});
check('카드 조건부 피해와 골드 기반 관통값', () => {
  const {env:e}=fresh();e.ExpMember[0]=true;e.ExpCardOwned[1]=e.ExpCardOwned[2]=e.ExpCardOwned[3]=true;
  assert.equal(e.ExpCardDamage(0,0,1),70);e.UnitHP[1]=500;assert.equal(e.ExpCardDamage(0,0,1),30);
  e.ExpCardOwned[7]=e.ExpCardOwned[8]=true;e.ExpGold[0]=1000;assert.equal(e.ExpCardPenetration(0),.5);
});
check('개인 상태에 따른 사건 제외와 투표 중 스탯 배분', () => {
  const {env:e}=fresh();e.ExpMember[0]=true;e.ExpPoints[0]=10;e.ExpState=e.EXP_VOTE;e.ExpAction(0,101);assert.equal(e.ExpCritPoints[0],1);
  assert.equal(e.EventValid(0,5),false);assert.equal(e.EventValid(0,7),false);assert.equal(e.EventValid(0,6),true);
  e.ExpCardOwned[1]=true;e.ExpArcana[50]=1;
  assert(e.EventValid(0,5));assert(e.EventValid(0,7));
  assert(e.EventValid(0,8));
});
check('일반 적 구성, 2마리 이하 두 번째 무리 예고, 미등장 체력 포함', () => {
  const {env:e}=environment([...files,'System/ExpeditionCombat.j']);e.ExpMember[0]=true;e.ExpPlayers=1;e.ExpArena=1;e.ExpState=e.EXP_BATTLE;
  e.ExpCombatStart(false);assert.equal(e.Spawned,8);assert.deepEqual(e.EnemyKind.slice(1,9),[1,1,1,1,1,2,2,3]);
  for(let i=1;i<=6;i++)e.UnitHP[e.IndexUnit(e.Enemies[i])]=0;e.Update();
  assert.equal(e.Spawned,8);assert.equal(e.ExpProgress,6/16);assert.equal(e.Warnings.slice(9,17).filter(Boolean).length,8);
  for(let i=0;i<12;i++)e.Update();assert.equal(e.Spawned,16);
  for(let i=1;i<=16;i++)if(e.Enemies[i])e.UnitHP[e.IndexUnit(e.Enemies[i])]=0;e.Update();assert.equal(e.ExpWon,true);assert.equal(e.ExpProgress,1);assert.equal(e.Finished,true);
});
check('전투 제한시간 실패와 정산 한 번, 생존 적/예고 정리', () => {
  const {env:e}=environment([...files,'System/ExpeditionCombat.j']);e.ExpMember[0]=true;e.ExpPlayers=1;e.ExpArena=1;e.ExpState=e.EXP_BATTLE;e.ExpCombatStart(true);
  const enemy=e.Enemies[1];let ended=0;e.TriggerExecute=()=>{ended++;};e.ExpSeconds=0;e.Update();e.Update();e.Conclude(false);
  assert.equal(ended,1);assert.equal(e.ExpWon,false);assert.equal(e.ExpProgress,0);assert.equal(enemy.removed,true);assert.equal(e.ExpEnemy[enemy.id],false);
});
check('일반 적 체력 추적·가시성·사망/전투 종료 정리와 참여자 보스바 연결', () => {
  const calls=[];
  const {env:e}=environment([...files,'System/ExpeditionCombat.j'],{BOSSHPSTART:(unit,pid)=>calls.push({unit,pid})});
  e.ExpMember[0]=e.ExpMember[2]=true;e.ExpPlayers=2;e.ExpArena=1;e.ExpState=e.EXP_BATTLE;e.ExpCombatStart(false);
  assert.equal(e.ExpSeconds,120);assert.equal(calls.length,0);
  const tag=e.EnemyHealth[1],enemy=e.Enemies[1];assert.equal(tag.text,'100.0%');assert(tag.visible);assert.equal(tag.unit,enemy);
  e.UnitHP[enemy.id]=e.EnemyMaximum[1]/2;e.Update();assert.equal(tag.text,'50.0%');
  e.localPlayer=1;e.Update();assert.equal(tag.visible,false);
  e.localPlayer=0;e.IsUnitVisible=()=>false;e.Update();assert.equal(tag.visible,false);
  e.IsUnitVisible=()=>true;e.Update();assert.equal(tag.visible,true);
  e.UnitHP[enemy.id]=0;e.Update();assert(tag.destroyed);assert.equal(e.EnemyHealth[1],null);
  const remaining=e.EnemyHealth.slice(2,9);e.ExpCombatStop();assert(remaining.every(t=>t.destroyed));
  assert(e.EnemyHealth.slice(1,17).every(t=>t===null));
  e.ExpCombatStart(true);assert.equal(e.ExpSeconds,360);assert.deepEqual(calls.map(c=>c.pid),[0,2]);
  assert(calls.every(c=>c.unit===e.Enemies[1]));assert.equal(e.EnemyHealth[1],null);
});
check('원정 보스는 로커스트를 유지하고 기존 보스 생성 순서를 적용, 일반 적과 예고는 유지', () => {
  const setup=[],units=[];
  const {env:e}=environment([...files,'System/ExpeditionCombat.j'],{
    CreateUnit:(p,raw,x,y)=>{
      // 실제 시험 맵의 h002는 A00X,Aloc, h00H는 Avul,Aloc를 기본 보유한다.
      const inherited=raw==='h002'?['A00X','Aloc']:raw==='h00H'?['Avul','Aloc']:[];
      const u={id:100+units.length,p,raw,x,y,abilities:new Set([...inherited,'Aatk','Amov'])};
      units.push(u);return u;
    },
    UnitRemoveAbility:(u,a)=>{u.abilities.delete(a);if(a!=='Aatk')setup.push(['remove',u,a]);},
    SetUnitPathing:(u,state)=>{u.pathing=state;setup.push(['pathing',u,state]);},
    PauseUnit:(u,state)=>{u.paused=state;setup.push(['pause',u,state]);},
    SetUnitPosition:(u,x,y)=>{if(typeof u==='object'){u.x=x;u.y=y;setup.push(['position',u,x,y]);}},
    BOSSHPSTART:(u)=>{
      assert(u.abilities.has('Aloc'));assert(u.abilities.has('A00X'));assert(!u.abilities.has('Amov'));
      assert.equal(u.paused,true);assert.equal(u.pathing,false);assert.equal(setup.at(-1)[0],'position');
    },
  });
  e.ExpMember[0]=true;e.ExpPlayers=1;e.ExpArena=1;e.ExpState=e.EXP_BATTLE;
  e.ExpCombatStart(false);assert.equal(setup.length,0);e.ExpCombatStop();
  e.ExpCombatStart(true);const boss=e.Enemies[1];
  assert.equal(boss.raw,'h002');assert(!boss.abilities.has('Aatk'));
  assert.deepEqual(setup,[['remove',boss,'Amov'],['pathing',boss,false],['pause',boss,true],['position',boss,e.SpawnX[1],e.SpawnY[1]]]);
  assert.equal(e.UnitHP[boss.id],12000000);assert.equal(e.UnitHPMAX[boss.id],12000000);
  boss.x=100;boss.y=0;e.EnemyClock[1]=0;e.ActEnemy(1);const warning=e.Warnings[1];
  assert.equal(warning.raw,'h00H');assert(warning.abilities.has('Aloc'));assert(warning.abilities.has('Avul'));
  assert.equal(setup.length,4);assert(boss.abilities.has('A00V'));
});
check('보스 좌표 추적은 로커스트와 정지를 유지하고 사거리·예고·회복 중 이동을 멈춤',()=>{
  const moves=[],animations=[];
  const {env:e}=environment([...files,'System/ExpeditionCombat.j'],{
    SetUnitPosition:(u,x,y)=>{if(typeof u==='object'){u.x=x;u.y=y;moves.push([x,y]);}},
    SetUnitAnimation:(u,name)=>animations.push(name),
  });
  e.ExpMember[0]=true;e.ExpPlayers=1;e.ExpArena=1;e.ExpState=e.EXP_BATTLE;e.ExpCombatStart(true);
  const boss=e.Enemies[1];boss.x=1000;boss.y=0;boss.abilities.add('Aloc');
  e.EnemyClock[1]=0;moves.length=0;e.ActEnemy(1);assert.equal(boss.x,960);assert.equal(boss.y,0);assert.deepEqual(animations,['walk']);
  for(let i=0;i<30 && e.EnemyPhase[1]===0;i++)e.ActEnemy(1);
  assert.equal(boss.x,320);assert.equal(e.EnemyPhase[1],1);assert.deepEqual(animations,['walk','stand']);
  const count=moves.length,aim=[e.AimX[1],e.AimY[1]];
  for(let i=0;i<3;i++)e.ActEnemy(1);assert.equal(moves.length,count);assert.deepEqual([e.AimX[1],e.AimY[1]],aim);
  e.EnemyClock[1]=0;e.ActEnemy(1);assert.equal(e.EnemyPhase[1],2);
  for(let i=0;i<3;i++)e.ActEnemy(1);assert.equal(moves.length,count);assert(boss.abilities.has('Aloc'));
  e.EnemyPhase[1]=0;e.EnemyClock[1]=0;boss.x=320;boss.y=0;e.ActEnemy(1);assert.equal(moves.length,count);
});
check('보호막이 없는 보스도 체력 UI 크기 계산을 끝까지 수행', () => {
  let update;const sizes=[],texts=[],timer={start:(seconds,repeat,fn)=>{update=fn;}};
  const {env:e}=environment(['UI/UI_BossHP.j'],{
    tick:{create:()=>timer,getExpired:()=>timer},FxEffect:{create:()=>({})},
    GetUnitIndex:()=>1,DataUnitIndex:()=>2,UnitSetHPx:[0,0,200],GetUnitName:()=>'원정 보스',
    ModuloReal:(a,b)=>a%b,DzFrameShow:()=>{},DzFrameSetText:(f,text)=>texts.push(text),
    DzFrameSetTexture:()=>{},DzFrameSetPoint:()=>{},
    DzFrameSetSize:(f,w,h)=>{assert(Number.isFinite(w)&&Number.isFinite(h));sizes.push([w,h]);},
  });
  e.UnitHP[1]=e.UnitHPMAX[1]=12000000;e.BOSSHPSTART(1,0);update();
  assert(texts.includes('원정 보스'));assert.equal(sizes.length,3);assert.equal(sizes.at(-1)[0],300/1280);
  e.UnitHP[1]=6000000;update();assert.equal(sizes.at(-1)[0],150/1280);
  e.UnitSDMAX[1]=1000;e.UnitSD[1]=500;update();assert.equal(sizes.at(-3)[0],150/1280);
});
check('보스 사망은 60초 한 번 차감, 15초 부활과 2초 무적', () => {
  const {env:e}=environment([...files,'System/ExpeditionCombat.j']);e.ExpMember[0]=e.ExpMember[1]=true;e.ExpPlayers=2;e.ExpArena=1;e.ExpState=e.EXP_BATTLE;
  const alive=[true,true], protectedNow=[false,false];
  e.UnitAlive=u=>typeof u==='number'?alive[u]:!!u&&!u.dead&&!u.removed;
  e.ReviveHero=u=>{alive[u]=true;};e.SetUnitInvulnerable=(u,v)=>{protectedNow[u]=v;};
  e.ExpCombatStart(true);alive[0]=false;e.Update();assert.equal(e.ExpSeconds,300);
  for(let i=0;i<149;i++)e.Update();assert.equal(alive[0],false);assert.equal(e.ExpSeconds,300);
  for(let i=0;i<3;i++)e.Update();assert.equal(alive[0],true);assert.equal(protectedNow[0],true);
  for(let i=0;i<22;i++)e.Update();assert.equal(protectedNow[0],false);
});
check('일반 전투 사망은 30초 한 번 차감, 이탈은 현재 적 체력 유지', () => {
  const {env:e}=environment([...files,'System/ExpeditionCombat.j']);e.ExpMember[0]=e.ExpMember[1]=true;e.ExpPlayers=2;e.ExpArena=1;e.ExpState=e.EXP_BATTLE;
  e.ExpCombatStart(false);const hp=e.EnemyMaximum[1];e.UnitAlive=u=>typeof u==='number'?u!==0:!!u&&!u.dead&&!u.removed;
  e.Update();e.Update();assert.equal(e.ExpSeconds,90);e.eventPlayer=0;e.Leave();assert.equal(e.ExpPlayers,1);assert.equal(e.EnemyMaximum[1],hp);
  e.ExpCombatStart(true);assert.equal(e.EnemyMaximum[1],12000000);
});
check('2인 원정 전체 진행 후 새 원정에 임시 성장 미이월', () => {
  const {env:e}=environment([...files,'System/ExpeditionCombat.j']);e.online[1]=true;
  e.TriggerExecute=t=>{if(t===e.ExpBattleFinished)e.BattleFinished();};
  const move=()=>{e.Tick();assert.equal(e.ExpState,e.EXP_MOVE);for(let i=0;i<6;i++)e.Tick();};
  e.ExpAction(0,1);e.ExpAction(1,1);assert.equal(e.ExpState,e.EXP_START);
  e.ExpAction(0,4);e.ExpAction(1,2);move();assert.equal(e.ExpState,e.EXP_VOTE);
  e.ExpAction(0,1);e.ExpAction(1,1);move();assert.equal(e.ExpState,e.EXP_BATTLE);
  for(let i=1;i<=8;i++)e.UnitHP[e.IndexUnit(e.Enemies[i])]=0;
  for(let i=0;i<13;i++)e.Update();assert.equal(e.Spawned,16);
  for(let i=9;i<=16;i++)e.UnitHP[e.IndexUnit(e.Enemies[i])]=0;e.Update();assert.equal(e.ExpState,e.EXP_REWARD);
  e.ExpAction(0,1);e.ExpAction(1,2);move();assert.equal(e.ExpState,e.EXP_SHOP);
  e.ExpAction(0,1);e.ExpAction(1,6);e.ExpAction(0,10);e.ExpAction(1,10);move();assert.equal(e.ExpBossBattle,true);
  e.UnitHP[e.IndexUnit(e.Enemies[1])]=0;e.Update();assert.equal(e.ExpState,e.EXP_RESULT);assert.equal(e.ExpConfirmedBattles[0],2);
  assert.equal(e.ExpMember[0],false);assert.equal(e.ExpMember[1],false);assert.equal(e.ExpArena,0);
  e.ExpAction(0,1);e.ExpAction(1,1);assert.equal(e.ExpState,e.EXP_START);assert.equal(e.ExpGold[0],0);assert.equal(e.ExpPoints[0],5);assert.equal(e.ExpFixedCrit[1],0);
});
console.log(`${checks} scenario groups passed. JASS natives, real multiplayer, game rendering and server persistence remain untested.`);
}
