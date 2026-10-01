// 검토를 통과한 사건·카드 JSON을 원정 데이터 JASS로 변환한다.
'use strict';
const fs = require('node:fs'), path = require('node:path');
const {inspect} = require('./check-content-candidates.cjs');
const root = path.resolve(__dirname, '..');
const statNames = ['attack_percent','damage_percent','final_damage_percent','boss_damage_percent','normal_damage_percent','crit_chance','crit_damage','swift','action_speed','move_speed','charge_speed','penetration','max_health_percent','damage_reduction','leech','regeneration','kill_gold','event_choices','moving_damage','directional_damage','nondirectional_damage','shielded_damage','charge_damage','healthy_damage'];
const q = x => '"' + String(x).replace(/\\/g,'\\\\').replace(/"/g,'\\"').replace(/\r?\n/g,'|n') + '"';
function generate(worlds) {
  const cards = new Map(), events = new Map(), lines = [];
  let nextCard = 13, nextEvent = worlds.filter(w=>w.world.key!=='common').length * 4 + 1, head = 0;
  for (const w of worlds) {
    const report = inspect(w);
    if (report.errors.length) throw Error(JSON.stringify(report));
    w.head = w.world.key==='common' ? 0 : ++head;
    for (const c of w.cards) {
      if (cards.has(c.key)) throw Error('작품 간 카드 key 중복. '+c.key);
      cards.set(c.key,nextCard++);
    }
    for (const e of w.events) {
      if (events.has(e.key)) throw Error('작품 간 사건 key 중복. '+e.key);
      events.set(e.key,nextEvent++);
    }
  }
  if (nextCard>1024 || nextEvent>1024 || head>80) throw Error('플레이어별 JASS 키 공간을 초과합니다. 저장 구조를 확장한 뒤 다시 생성하세요.');
  const strings = ['ProtoHeadKey','ProtoHeadName','ProtoHeadIntro','ProtoHeadIcon','ProtoCardKey','ProtoCardName','ProtoCardEffectName','ProtoCardKeyword','ProtoEventKey','ProtoEventName','ProtoEventStory','ProtoEventIntro','ProtoEventIcon','ProtoEventFailure','ProtoBranchLabel','ProtoBranchResult'];
  const integers = ['ProtoHeadEntryCard','ProtoCardHead','ProtoCardGrade','ProtoEvolutionKind','ProtoEventHead','ProtoEventKind','ProtoEventRequired','ProtoEventRequiredChoice','ProtoEventRequiredCard','ProtoEventHistory','ProtoEventChoices','ProtoBranchCard','ProtoBranchCard2','ProtoBranchGold','ProtoBranchCost','ProtoBranchLevel','ProtoBranchDensity','ProtoBranchPotions','ProtoBranchChance'];
  lines.push('// 검토된 머리 카드, 캐릭터 카드와 사건 콘텐츠를 로드한다. 생성 도구로 갱신한다.', 'library DataPrototypeCatalog initializer ProtoCatalogInit requires DataPrototypeStats','    globals',
    '        constant integer PROTO_HEAD_COUNT = '+head,
    '        constant integer PROTO_EVENT_COUNT = '+(nextEvent-1),
    '        constant integer PROTO_CARD_FIRST = 13',
    '        constant integer PROTO_CARD_LAST = '+(nextCard-1),
    '        constant string PROTO_SAVE_PREFIX = "원정.콘텐츠2."',
    ...strings.map(s=>'        string array '+s), ...integers.map(s=>'        integer array '+s),
    '        real array ProtoEvolutionGoal','    endglobals','');
  const set = (name,id,value) => lines.push('        set '+name+'['+id+'] = '+(typeof value==='string' ? q(value) : value));
  const effects = (id, list, evolved) => {
    for (const e of list) lines.push('        call ProtoSetEffect('+id+', '+(statNames.indexOf(e.stat)+1)+', '+Number(e.value).toFixed(2)+', '+evolved+')');
  };
  // 작품별 로더로 분리해 큰 단일 초기화 함수의 실행 한도를 피한다.
  for (let wi=0;wi<worlds.length;wi++) {
    const w=worlds[wi], h=w.head;
    lines.push('    function ProtoLoadWorld'+wi+' takes nothing returns nothing');
    if (h) {
      set('ProtoHeadKey',h,w.world.key);set('ProtoHeadName',h,w.world.name); set('ProtoHeadIntro',h,w.world.intro);
      set('ProtoHeadIcon',h,w.world.icon || 'ReplaceableTextures\\CommandButtons\\BTNManual.blp');
      set('ProtoHeadEntryCard',h,cards.get(w.world.entryCard));
      for (const e of w.world.effects || [w.world.bonus]) {
        if (!e || !statNames.includes(e.stat) || !Number.isFinite(e.value)) throw Error('머리 카드 효과 오류. '+w.world.key);
        lines.push('        call SaveReal(ProtoHeadEffectData, '+h+', '+(statNames.indexOf(e.stat)+1)+', '+Number(e.value).toFixed(2)+')');
      }
      for (let p=0;p<4;p++) {
        const id=(h-1)*4+p+1;
        set('ProtoEventKey',id,w.world.key+'_entry_'+p);set('ProtoEventName',id,w.world.name+' 방문'); set('ProtoEventHead',id,h); set('ProtoEventKind',id,0);set('ProtoEventChoices',id,1);
        set('ProtoEventStory',id,w.world.intro); set('ProtoEventIntro',id,w.world.intro);set('ProtoEventIcon',id,w.world.icon || 'ReplaceableTextures\\CommandButtons\\BTNManual.blp');
      }
    }
    for (const c of w.cards) {
      const id=cards.get(c.key);
      set('ProtoCardKey',id,c.key);set('ProtoCardName',id,c.name);set('ProtoCardEffectName',id,c.effectName);set('ProtoCardKeyword',id,w.world.name+' · '+c.keyword);
      set('ProtoCardHead',id,h);set('ProtoCardGrade',id,c.grade);set('ProtoEvolutionKind',id,c.evolution.kind);
      lines.push('        set ProtoEvolutionGoal['+id+'] = '+Number(c.evolution.goal).toFixed(2));
      effects(id,c.effects,false); effects(id,c.evolution.effects,true);
    }
    for (const e of w.events) {
      const id=events.get(e.key);
      set('ProtoEventKey',id,e.key);set('ProtoEventName',id,e.title);set('ProtoEventHead',id,h);set('ProtoEventKind',id,1);set('ProtoEventChoices',id,e.choices.length);
      set('ProtoEventStory',id,e.story);set('ProtoEventIntro',id,e.intro);set('ProtoEventIcon',id,w.world.icon || 'ReplaceableTextures\\CommandButtons\\BTNTome.blp');
      set('ProtoEventRequired',id,e.previous ? events.get(e.previous) : 0);set('ProtoEventRequiredChoice',id,e.previousChoice || 0);set('ProtoEventRequiredCard',id,e.requiredCard ? cards.get(e.requiredCard):0);set('ProtoEventFailure',id,e.failure || '');
      e.choices.forEach((b,i)=>{
        const key=id*4+i;
        set('ProtoBranchLabel',key,b.label);set('ProtoBranchResult',key,b.result);
        for (const n of ['card','card2']) set('ProtoBranch'+n[0].toUpperCase()+n.slice(1),key,b[n] ? cards.get(b[n]):0);
        for (const n of ['gold','cost','level','density','potions','chance']) set('ProtoBranch'+n[0].toUpperCase()+n.slice(1),key,b[n]);
      });
    }
    lines.push('    endfunction','');
  }
  lines.push('    function ProtoCatalogInit takes nothing returns nothing',...worlds.map((_,i)=>'        call ProtoLoadWorld'+i+'()'),'    endfunction','endlibrary','');
  return lines.join('\n');
}
function run() {
  const dir=path.join(root,'content/roguelite');
  const files=fs.readdirSync(dir).filter(f=>f.endsWith('.json')).sort();
  const worlds=files.map(f=>JSON.parse(fs.readFileSync(path.join(dir,f),'utf8')));
  const text=generate(worlds), file=path.join(root,'Data/Data_PrototypeCatalog.j');
  if (process.argv.includes('--check')) {
    if (fs.readFileSync(file,'utf8')!==text) throw Error('검토 JSON과 생성 JASS가 일치하지 않습니다.');
  } else fs.writeFileSync(file,text);
  console.log(JSON.stringify({worlds:worlds.filter(w=>w.world.key!=='common').length,cards:worlds.reduce((n,w)=>n+w.cards.length,0),events:worlds.reduce((n,w)=>n+w.events.length,0)}));
}
module.exports={generate};
if (require.main===module) {try {run();} catch(e) {console.error(e.message);process.exitCode=1;}}
