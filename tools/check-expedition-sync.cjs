// 원정의 로컬 UI 호출 경로에서 게임 상태 변경과 미검토 API 사용을 차단한다.
const fs = require('node:fs'), path = require('node:path'), assert = require('node:assert/strict');
const root = path.resolve(__dirname, '..');
const uiFile = file => /^UI\/UI_Expedition[^/]*\.j$/.test(file) || file === 'UI/UI_Map.j';

// 기존 로컬 저장소 조회는 별도 경계다. StashLoad의 내부 scratch 변수와 저장 엔진은
// 이 검사로 증명하지 않는다. 저장/업로드 API는 허용하지 않는다.
const allowedCalls = new Set(`
  GetLocalPlayer GetPlayerId Player GetTriggerPlayer GetPlayerName GetPlayerSlotState GetPlayerController
  I2S S2I R2I I2R IMaxBJ IMinBJ JNStringSplit StashLoad LoadInteger GetItemCharges
  DzGetTriggerUIEventFrame DzGetTriggerUIEventPlayer DzSyncData
  DzFrameSetText DzFrameSetTexture DzFrameSetEnable DzFrameShow DzFrameClearAllPoints DzFrameSetPoint DzFrameSetAlpha
`.trim().split(/\s+/));
const allowedWrites = new Set(`
  ExpUIPanel FMap_OnOff
  UIExpeditionCommon.ButtonEnabled UIExpeditionCommon.Hovered UIExpeditionCommon.FoldedPanel
  UIExpeditionCommon.SeenRevision UIExpeditionCommon.SeenOffer UIExpeditionCommon.SeenDone
  UIExpeditionCommon.ShownRun UIExpeditionCommon.ShownRevision UIExpeditionCommon.ShownOffer
  UIExpeditionChoice.CardGrade UIExpeditionChoice.CardEnabled UIExpeditionChoice.CardHovered
  UIMainQuest.OverlayHidden
`.trim().split(/\s+/));

// 줄 번호를 유지하며 문자열/주석을 마스킹한다. 문자열 속 가짜 호출은 검사하지 않는다.
function mask(source) {
  return source.replace(/"(?:\\.|[^"\\])*"|'[^'\r\n]*'|\/\/[^\r\n]*|\/\*[\s\S]*?\*\//g,
    token => token.replace(/[^\r\n]/g, ' '));
}
function sources() {
  const result = new Map();
  for (const match of fs.readFileSync(path.join(root, 'Import.j'), 'utf8').matchAll(/^\s*\/\/! import "([^"]+)"/gm)) {
    const file = match[1].replace(/\\/g, '/').split('/Test/')[1];
    assert(file && !file.includes('..'), '프로젝트 import 경로를 해석할 수 없음. ' + match[1]);
    result.set(file, fs.readFileSync(path.join(root, file), 'utf8'));
  }
  return result;
}
function audit(input) {
  const modules = [], globals = new Map(), publicFunctions = new Map(), roots = [], errors = [];
  for (const [file, source] of input) {
    const code = mask(source), scope = code.match(/^\s*(?:library|scope)\s+(\w+)/m)?.[1] || file;
    const mod = {file, code, scope, functions: new Map(), variables: new Map()};
    modules.push(mod);
    for (const block of code.matchAll(/^\s*globals\b([\s\S]*?)^\s*endglobals\b/gm)) {
      for (const m of block[1].matchAll(/^\s*(?:(private|public)\s+)?(?:constant\s+)?\w+\s+(?:array\s+)?(\w+)/gm)) {
        const key = m[1] === 'private' ? scope + '.' + m[2] : m[2];
        mod.variables.set(m[2], key);
        if (m[1] !== 'private') globals.set(m[2], key);
      }
    }
    const pattern = /^\s*(?:(private|public)\s+)?function\s+(\w+)\s+takes\s+([^\r\n]+?)\s+returns\s+\w+([^]*?)\bendfunction\b/gm;
    for (const m of code.matchAll(pattern)) {
      const bodyOffset = m.index + m[0].indexOf(m[4]);
      const locals = new Set([...m[3].matchAll(/\b\w+\s+(\w+)/g)].map(x => x[1]));
      for (const local of m[4].matchAll(/^\s*local\s+\w+\s+(?:array\s+)?(\w+)/gm)) locals.add(local[1]);
      const fn = {mod, name: m[2], body: m[4], bodyOffset, locals, id: scope + '.' + m[2]};
      mod.functions.set(fn.name, fn);
      if (m[1] !== 'private') {
        const candidates = publicFunctions.get(fn.name) || [];
        candidates.push(fn);publicFunctions.set(fn.name, candidates);
      }
    }
  }
  function resolve(mod, name) {
    if (mod.functions.has(name)) return mod.functions.get(name);
    const candidates = publicFunctions.get(name) || [];
    return candidates.length === 1 ? candidates[0] : null;
  }
  for (const mod of modules.filter(m => uiFile(m.file))) {
    // 로컬 플레이어를 읽는 함수, 프레임/키 콜백, 공통 렌더 콜백은 모두 시작점이다.
    for (const fn of mod.functions.values()) {
      if (/\bGetLocalPlayer\s*\(/.test(fn.body) || fn.name === 'ExpUIOpen' || fn.name === 'SetMapLine') roots.push(fn);
    }
    for (const line of mod.code.split(/\r?\n/)) {
      if (/\b(?:DzFrameSetScript\w*|DzTriggerRegister\w*ByCode)\s*\(/.test(line) || /TriggerAddAction\s*\(\s*ExpRefresh\s*,/.test(line)) {
        const name = line.match(/\bfunction\s+(\w+)/)?.[1], fn = name && resolve(mod, name);
        if (!fn) errors.push(mod.file + ' 콜백을 해석할 수 없음. ' + line.trim());
        else roots.push(fn);
      }
    }
  }
  assert(roots.some(f => f.name === 'SetMapLine'), 'SetMapLine 검사 시작점 누락');
  assert(roots.some(f => f.name === 'ExpUIOpen'), 'ExpUIOpen 검사 시작점 누락');
  const visited = new Set();
  function visit(fn, chain) {
    if (visited.has(fn)) return;
    visited.add(fn);
    const trail = [...chain, fn.id];
    const report = (offset, message) => {
      const line = fn.mod.code.slice(0, fn.bodyOffset + offset).split('\n').length;
      errors.push(`${fn.mod.file}:${line} ${message}\n  ${trail.join(' -> ')}`);
    };
    for (const m of fn.body.matchAll(/\bset\s+(\w+)/g)) {
      if (fn.locals.has(m[1])) continue;
      const key = fn.mod.variables.get(m[1]) || globals.get(m[1]);
      if (!allowedWrites.has(key)) report(m.index, '로컬 UI에서 허용하지 않은 상태 쓰기. ' + m[1]);
    }
    for (const m of fn.body.matchAll(/\b(\w+)\s*\(/g)) {
      const name = m[1];
      if (['if', 'elseif', 'and', 'or', 'not', 'return', 'exitwhen'].includes(name)) continue;
      if (allowedCalls.has(name)) continue;
      const callee = resolve(fn.mod, name);
      if (callee) visit(callee, trail);
      else report(m.index, '로컬 UI에서 미검토 또는 위험한 호출. ' + name);
    }
    // code 인자를 통한 간접 실행도 함수 본문을 확인한다. 문자열 ExecuteFunc는 위에서 거부된다.
    for (const m of fn.body.matchAll(/\bfunction\s+(\w+)/g)) {
      const callee = resolve(fn.mod, m[1]);
      if (callee) visit(callee, trail);
      else report(m.index, '해석할 수 없는 code 콜백. ' + m[1]);
    }
  }
  roots.forEach(fn => visit(fn, []));
  return {errors, roots: new Set(roots).size, functions: visited.size};
}

function main() {
  const input = sources(), result = audit(input);
  assert.equal(result.errors.length, 0, result.errors.join('\n'));
  console.log(`PASS 원정 로컬 UI ${result.roots}개 시작점, ${result.functions}개 함수 호출 경로`);
  // 실제 소스를 메모리에서만 변형한다. 검사기가 문제를 놓치면 CI 자체가 실패한다.
  const common = 'UI/UI_ExpeditionCommon.j';
  function injected(statement, helper = '') {
    const changed = new Map(input);
    changed.set(common, input.get(common).replace('function ExpUIOpen takes integer panel returns nothing',
      'function ExpUIOpen takes integer panel returns nothing\n        ' + statement).replace('endlibrary', helper + '\nendlibrary'));
    return audit(changed);
  }
  const cases = [
    ['직접 트리거 실행', 'call TriggerExecute(ExpRefresh)', 'TriggerExecute'],
    ['유닛 상태 변경', 'call SetUnitState(MainUnit[0], UNIT_STATE_LIFE, 1)', 'SetUnitState'],
    ['공유 난수', 'local integer roll = GetRandomInt(1, 10)', 'GetRandomInt'],
    ['핸들 생성', 'local timer t = CreateTimer()', 'CreateTimer'],
    ['공유 배열 변경', 'set ExpGold[0] = 500', 'ExpGold'],
    ['미등록 호출', 'call FutureUnknownAPI()', 'FutureUnknownAPI'],
    ['문자열 간접 실행', 'call ExecuteFunc("FutureUnknownAPI")', 'ExecuteFunc'],
  ];
  for (const [name, statement, expected] of cases) {
    assert(injected(statement).errors.some(e => e.includes(expected)), name + '을 놓침');
    console.log('PASS 금지 동작 검출. ' + name);
  }
  const helper = 'private function UnsafeRefresh takes nothing returns nothing\n call TriggerExecute(ExpRefresh)\nendfunction';
  assert(injected('call UnsafeRefresh()', helper).errors.some(e => e.includes('UnsafeRefresh') && e.includes('TriggerExecute')));
  console.log('PASS 보조 함수 뒤에 숨은 트리거 실행 검출');
  const changedHelper = new Map(input);
  changedHelper.set('System/Expedition.j', input.get('System/Expedition.j').replace(
    'function ExpShopPrice takes integer pid, integer base returns integer',
    'function ExpShopPrice takes integer pid, integer base returns integer\n set ExpGold[pid] = 0'));
  assert(audit(changedHelper).errors.some(e => e.includes('ExpShopPrice') && e.includes('ExpGold')));
  console.log('PASS 다른 라이브러리 조회 함수의 게임 상태 변경 검출');
  const newCallback = new Map(input);
  newCallback.set(common, input.get(common).replace('endlibrary',
    'private function FutureClick takes nothing returns nothing\n call TriggerExecute(ExpRefresh)\nendfunction\nendlibrary')
    .replace('function ClickButton, false)', 'function FutureClick, false)'));
  assert(audit(newCallback).errors.some(e => e.includes('FutureClick') && e.includes('TriggerExecute')));
  console.log('PASS 로컬 플레이어를 직접 읽지 않는 새 프레임 콜백 검출');
  assert.deepEqual(injected('// call TriggerExecute(ExpRefresh)\n local string text = "GetRandomInt(1, 2)"').errors, []);
  console.log('PASS 주석과 문자열은 호출로 오인하지 않음');
}
if (require.main === module) main();
module.exports = {audit, sources};
