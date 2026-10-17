// 아이템 데이터 원본(content/items.json)에서 맵 JASS(Data/Data_ItemGen.j)와 저장 서버·홈페이지 JSON을 만든다(세이브 v2 설계 10 5.3).
// usage: node tools/generate-item-data.cjs [--check] [--server-root <tools\arcana-save 폴더>]
//   --check        파일을 쓰지 않고 지금 파일과 같은지만 본다. 다르면 종료 코드 1.
//   --server-root  서버 출력 위치(기본: 이 저장소의 tools/arcana-save). server/data/items.v<N>.json, server/data/catalog.json,
//                  server/web/items.public.json, server/web/catalog.public.json 을 쓴다. 이전 판 items.v*.json 은 지우지 않는다.
'use strict';
const fs = require('node:fs'), path = require('node:path');
const root = path.resolve(__dirname, '..');
const args = process.argv.slice(2);
const check = args.includes('--check');
const sr = args.indexOf('--server-root');
const serverRoot = sr >= 0 ? path.resolve(args[sr + 1]) : path.join(root, 'tools', 'arcana-save');
const src = JSON.parse(fs.readFileSync(path.join(root, 'content', 'items.json'), 'utf8'));
const registry = JSON.parse(fs.readFileSync(path.join(root, 'content', 'roguelite-id-registry.json'), 'utf8'));

const fail = m => { throw Error('items.json: ' + m); };
// ---- 검사(생성 때 실패시킴)
const dv = src.data_version;
if (!Number.isInteger(dv) || dv < 1) fail('data_version');
for (const t of src.tags) if (/[0-9;|]/.test(t) || !t) fail('태그 이름에 숫자·;·| 금지: ' + t);
if (!src.tags.includes('ID')) fail('ID 태그 없음');
const ids = new Set();
for (const it of src.items) {
  if (!Number.isInteger(it.id) || it.id < 1 || it.id > 8191) fail('id ' + it.id);
  if (ids.has(it.id)) fail('id 중복 ' + it.id);
  ids.add(it.id);
  if (!/^[A-Za-z0-9]{4}$/.test(it.raw || '')) fail('raw ' + it.id);
  if (it.type !== null && !(Number.isInteger(it.type) && it.type >= 0 && it.type <= 7)) fail('type ' + it.id);
  if (it.tier !== null && !(Number.isInteger(it.tier) && it.tier >= 0)) fail('tier ' + it.id);
}
for (const [tier, table] of Object.entries(src.weapon_attack)) {
  const em = src.enchant_max[tier];
  if (!Number.isInteger(em)) fail('enchant_max 없음 ' + tier);
  if (table.length !== em + 1) fail('무기 공격력 배열 길이 ' + tier + ': ' + table.length + ' != ' + (em + 1));
}
const dataDir = path.join(serverRoot, 'server', 'data'), webDir = path.join(serverRoot, 'server', 'web');
const previous = fs.existsSync(dataDir) ? fs.readdirSync(dataDir).map(f => f.match(/^items\.v(\d+)\.json$/)).filter(Boolean).map(m => +m[1]) : [];
if (previous.length && dv < Math.max(...previous)) fail('data_version 이 이전 판보다 작다: ' + dv + ' < ' + Math.max(...previous));
for (const p of previous.filter(v => v < dv)) {
  const old = JSON.parse(fs.readFileSync(path.join(dataDir, 'items.v' + p + '.json'), 'utf8'));
  for (const it of old.items) {
    const now = src.items.find(x => x.id === it.id);
    if (!now) fail('이전 판 v' + p + ' 의 번호 ' + it.id + ' 가 사라졌다(지우지 말고 retired: true)');
    if (now.raw !== it.raw) fail('번호 ' + it.id + ' 의 rawcode 가 바뀌었다(' + it.raw + ' -> ' + now.raw + ')');
  }
}

// ---- 출력
const maxId = Math.max(...src.items.map(x => x.id));
const q = s => '"' + String(s).replace(/\\/g, '\\\\').replace(/"/g, '\\"') + '"';
const jass = [];
jass.push('// 자동 생성 파일(tools/generate-item-data.cjs, 원본 content/items.json). 손으로 고치지 않는다.');
jass.push('library ArcanaSaveItemData initializer onInit');
jass.push('    globals');
jass.push('        constant integer ARCANA_DATA_VERSION = ' + dv);
jass.push('        constant integer ARCANA_ITEM_ID_MAX = ' + maxId);
jass.push('        // 번호 -> rawcode, 종류(0 엘릭서 1 무기 2 목걸이 3 귀걸이 4 반지 5 팔찌 6 카드 7 보석, 없으면 -1), 단계(SLK Level 과 같은 값)');
jass.push('        integer array ARCANA_ITEM_RAW');
jass.push('        integer array ARCANA_ITEM_TYPE');
jass.push('        integer array ARCANA_ITEM_TIER');
jass.push('        // 단계 -> 무기 공격력 문자열(ItemStats[1][단계] 형식), 강화 한도');
jass.push('        string array ARCANA_WEAPON_ATK');
jass.push('        integer array ARCANA_ENCHANT_MAX');
jass.push('    endglobals');
jass.push('');
jass.push('    private function onInit takes nothing returns nothing');
jass.push('        local integer i = 0');
jass.push('        loop');
jass.push('            exitwhen i > ARCANA_ITEM_ID_MAX');
jass.push('            set ARCANA_ITEM_TYPE[i] = -1');
jass.push('            set i = i + 1');
jass.push('        endloop');
for (const it of [...src.items].sort((a, b) => a.id - b.id)) {
  if (it.retired) continue;
  jass.push("        set ARCANA_ITEM_RAW[" + it.id + "] = '" + it.raw + "'");
  if (it.type !== null) jass.push('        set ARCANA_ITEM_TYPE[' + it.id + '] = ' + it.type);
  if (it.tier) jass.push('        set ARCANA_ITEM_TIER[' + it.id + '] = ' + it.tier);
}
for (const [tier, table] of Object.entries(src.weapon_attack).sort((a, b) => a[0] - b[0])) {
  jass.push('        set ARCANA_WEAPON_ATK[' + tier + '] = ' + q(table.join(';')));
}
for (const [tier, em] of Object.entries(src.enchant_max).sort((a, b) => a[0] - b[0])) {
  jass.push('        set ARCANA_ENCHANT_MAX[' + tier + '] = ' + em);
}
jass.push('    endfunction');
jass.push('endlibrary');
const jassText = jass.join('\r\n') + '\r\n';

const serverItems = {
  version: src.version, data_version: dv, tags: src.tags, quality_max: src.quality_max, slot_types: src.slot_types,
  weapon_attack: src.weapon_attack, enchant_max: src.enchant_max,
  items: src.items.map(it => {
    const o = {id: it.id, raw: it.raw, key: it.key, type: it.type, tier: it.tier, name: it.name};
    if (it.type === 1 && it.tier !== null && src.enchant_max[it.tier] !== undefined) o.enchant_max = src.enchant_max[it.tier];
    if (it.fields) o.fields = it.fields;
    if (it.retired) o.retired = true;
    return o;
  }),
};
const publicItems = {data_version: dv, items: src.items.filter(it => !it.retired).map(it => ({id: it.id, type: it.type, tier: it.tier, name: it.name}))};
const byId = obj => Object.entries(obj).map(([key, id]) => ({id, key})).sort((a, b) => a.id - b.id);
const catalog = {registry_version: registry.version, maximum_id: registry.maximumEntityId, cards: byId(registry.cards), heads: byId(registry.heads)};
const publicCatalog = {cards: catalog.cards.length, heads: catalog.heads.length};

const outputs = [
  [path.join(root, 'Data', 'Data_ItemGen.j'), jassText],
  [path.join(dataDir, 'items.v' + dv + '.json'), JSON.stringify(serverItems, null, 1) + '\n'],
  [path.join(dataDir, 'catalog.json'), JSON.stringify(catalog) + '\n'],
  [path.join(webDir, 'items.public.json'), JSON.stringify(publicItems, null, 1) + '\n'],
  [path.join(webDir, 'catalog.public.json'), JSON.stringify(publicCatalog) + '\n'],
];
let differ = 0;
for (const [file, text] of outputs) {
  const cur = fs.existsSync(file) ? fs.readFileSync(file, 'utf8') : null;
  if (cur === text) continue;
  differ++;
  if (check) { console.log('다름: ' + file); continue; }
  fs.mkdirSync(path.dirname(file), {recursive: true});
  fs.writeFileSync(file, text);
  console.log('씀: ' + file);
}
if (check) { console.log(differ ? 'CHECK FAIL ' + differ : 'CHECK PASS'); process.exit(differ ? 1 : 0); }
console.log('items ' + src.items.length + ', data_version ' + dv + ', 바뀐 파일 ' + differ);
