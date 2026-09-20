// 선택 진단 로그의 클라이언트별 내용, 제한 시간 및 게임 상태 비변경을 검증한다.
const fs = require('fs'), path = require('path'), assert = require('node:assert/strict');
const source = fs.readFileSync(path.join(__dirname, '../UI/UI_Pick.j'), 'utf8');
const names = ['TracePick', 'TracePickState', 'BeginPickTrace'];
const bodies = Object.fromEntries(names.map(name => [name, source.match(new RegExp('private function ' + name + ' takes (.*?) returns nothing([\\s\\S]*?)endfunction'))]));
function client(localPlayer) {
  const logs = [], timers = [], pauses = [];
  const env = {
    PickTraceTimer: 100, PickTraceSequence: 0, PickTraceSeconds: 0,
    MainUnit: [{id: 200, type: 300, x: 12, y: 34}, null, null, null],
    PickCheck: [true, false, false, false], PLAYER_DATA_SERVER_READY: [false, false, false, false],
    Equip_Crit: [200, 0, 0, 0], Equip_Swiftness: [100, 0, 0, 0],
    UNIT_STATE_LIFE: 1, UNIT_STATE_MAX_LIFE: 2,
    GetLocalPlayer: () => localPlayer, GetPlayerId: x => x, I2S: String, R2S: String,
    GetHandleId: u => u == null ? 0 : typeof u === 'number' ? u : u.id,
    GetUnitTypeId: u => u?.type || 0,
    GetUnitX: u => u.x, GetUnitY: u => u.y,
    GetUnitState: u => { assert(u); return 10000; }, GetUnitMoveSpeed: () => 400,
    JNWriteLog: s => logs.push(s), TimerStart: (...args) => timers.push(args), PauseTimer: t => pauses.push(t),
  };
  for (const name of names) {
    const [,args,body] = bodies[name];
    const js = body.split(/\r?\n/).map(s => s.trim()).filter(s => s && !s.startsWith('//')).map(s => {
      if (s.startsWith('local ')) return 'let ' + s.split(' ').slice(2).join(' ') + ';';
      if (s === 'loop') return 'for(let guard=0; guard<10; guard++){';
      if (s === 'endloop' || s === 'endif') return '}';
      if (s.startsWith('exitwhen ')) return 'if(' + s.slice(9) + ') break;';
      if (s.startsWith('if ')) return 'if(' + s.slice(3,-5) + '){';
      if (/^(set|call) /.test(s)) return s.replace(/^(set|call) /, '').replace(/function (\w+)/g, '$1') + ';';
      throw Error('Unsupported diagnostic line: ' + s);
    }).join('\n');
    const params = args === 'nothing' ? '' : args.split(',').map(s => s.trim().split(' ')[1]).join(',');
    env[name] = Function('e', `with(e){return function(${params}){${js}}}`)(env);
  }
  return {env,logs,timers,pauses};
}
const clients = [0,1,4].map(client);
for (const {env:e,logs,timers,pauses} of clients) {
  const before = JSON.stringify([e.MainUnit,e.PickCheck,e.PLAYER_DATA_SERVER_READY,e.Equip_Crit,e.Equip_Swiftness]);
  e.BeginPickTrace(0,2,1,'new');
  assert.equal(timers.length,1);
  assert.deepEqual(timers[0].slice(0,3),[100,1,true]);
  for (let i=0;i<20;i++) { assert.equal(pauses.length,0);timers[0][3](); }
  assert.deepEqual(pauses,[100]);
  assert.equal(logs.length,101); // 시작 한 줄과 매초 4슬롯 + 생성된 영웅 한 줄.
  assert(logs.some(s=>s.includes('pid=1 phase=state picked=0 server=0 unit=0 type=0')));
  assert.equal(JSON.stringify([e.MainUnit,e.PickCheck,e.PLAYER_DATA_SERVER_READY,e.Equip_Crit,e.Equip_Swiftness]),before);
}
const normalize = logs => logs.map(s=>s.replace(/client=\d+/,'client=X'));
assert.deepEqual(normalize(clients[0].logs),normalize(clients[1].logs));
assert.deepEqual(normalize(clients[0].logs),normalize(clients[2].logs));
clients[1].env.MainUnit[0].id=201;
clients[1].env.BeginPickTrace(1,3,1,'load');
assert.equal(clients[1].env.PickTraceSequence,2);
assert.equal(clients[1].env.PickTraceSeconds,0);
clients[1].env.TracePickState();
assert(clients[1].logs.some(s=>s.includes('seq=2 second=1 pid=0 phase=state picked=1 server=0 unit=201')));
for (const name of ['NewPickF','LoadPickF']) {
  const body=source.match(new RegExp('private function '+name+' takes[\\s\\S]*?endfunction'))[0];
  assert(body.indexOf('call BeginPickTrace') < body.indexOf('if not PickSkinUnlocked'));
  for (const stage of ['reject-skin','hero-created','before-skill-ui','after-skill-ui','before-lobby-ui','after-lobby-ui','before-daily','after-daily','before-upload','complete']) assert(body.includes('"'+stage),name+' '+stage);
}
for (const name of names) {
  for (const m of bodies[name][2].matchAll(/call (\w+)/g)) assert(['TracePick','JNWriteLog','TimerStart','PauseTimer'].includes(m[1]),m[1]);
  assert(!/GetRandom|StashLoad|MapApi|GetPlayerName|DzSyncData/.test(bodies[name][2]));
}
const stats = fs.readFileSync(path.join(__dirname, '../System/StatsSetting.j'), 'utf8');
assert.equal((stats.match(/phase=reset-end/g)||[]).length,1);
assert(stats.match(/private function EquipReset[\s\S]*?endfunction/)[0].includes('phase=reset-end'));
console.log('PASS 선택 진단: 3개 클라이언트 동일 상태, 미선택 슬롯, 20초 종료, 재선택, 불일치 기록, 두 선택 경로, 읽기 전용 로그');
