// 확장 작품의 보상 규칙과 한 런에서 가능한 사건 진행 경로를 검사한다.
'use strict';
const fs = require('node:fs'), path = require('node:path');
const {inspect} = require('./check-content-candidates.cjs');
const worldKeys = ['amphoreus','phantom_blood','madolche','tengu','ikebukuro','frieren','dungeon_meshi','hunter_exam','roswaal_mansion','z_city'];
const defaultDirectory = path.resolve(__dirname,'../content/roguelite');
const schema = JSON.parse(fs.readFileSync(path.join(__dirname,'content-schema.json'),'utf8'));
const permittedStats = new Set(schema.$defs.effect.properties.stat.enum);
const permittedChoiceFields = new Set(Object.keys(schema.properties.events.items.properties.choices.items.properties));

function effectVector(card) {
  const values = new Map();
  for (const effect of card?.effects || []) values.set(effect.stat,(values.get(effect.stat)||0)+effect.value);
  return JSON.stringify([...values].filter(([,value])=>value!==0).sort(([a],[b])=>a.localeCompare(b)));
}

// 모든 사건은 플레이어당 한 번이다. 일반 사건은 파티 공용 소진 전의 가능성만 검사한다.
// 분기별 상태를 모두 열거하지 않고 필요한 카드의 지급 분기와 선행 사건만 역추적한다.
// 같은 사건의 다른 선택을 동시에 요구하면 거부하고, 마지막 위상 정렬로 시간 모순을 찾는다.
function createPlanner(data) {
  const events = new Map(data.events.map(event=>[event.key,event]));
  const main = data.events.filter(event=>event.mainStage).sort((a,b)=>a.mainStage-b.mainStage);
  const final = main.find(event=>event.mainStage===data.world.mainStory?.length);
  const sources = new Map(data.cards.map(card=>[card.key,[]]));
  if (sources.has(data.world.entryCard)) sources.get(data.world.entryCard).push({entry:true});
  for (const event of data.events) event.choices.forEach((choice,index)=>{
    for (const key of [choice.card,choice.card2]) if (sources.has(key) && choice.chance>0) {
      sources.get(key).push({event:event.key,outcome:index+1});
    }
  });
  const clone = state => ({outcomes:new Map(state.outcomes),expanded:new Set(state.expanded),edges:state.edges.slice()});
  function *requireCard(state,key,consumer) {
    for (const source of sources.get(key)||[]) {
      if (source.entry) {yield state;continue;}
      const next = clone(state);
      next.edges.push([source.event,consumer]);
      yield* requireEvent(next,source.event,source.outcome);
    }
  }
  function *requireEvent(state,key,outcome=0) {
    const event = events.get(key);
    if (!event) return;
    const assigned = state.outcomes.get(key)||0;
    if (outcome && assigned && outcome!==assigned) return;
    if (outcome) {
      const choice = event.choices[Math.abs(outcome)-1];
      if (!choice || (outcome<0 ? choice.chance>=100 : choice.chance<=0)) return;
    }
    const next = clone(state);
    next.outcomes.set(key,outcome||assigned);
    if (next.expanded.has(key)) {yield next;return;}
    next.expanded.add(key);
    const requirements = [];
    if (event.previous) {
      next.edges.push([event.previous,key]);
      requirements.push({event:event.previous,outcome:event.previousChoice});
    }
    if (event.mainStage) for (const earlier of main.filter(item=>item.mainStage<event.mainStage)) {
      next.edges.push([earlier.key,key]);
      requirements.push({event:earlier.key,outcome:0});
    }
    if (event.epilogue && final) {
      next.edges.push([final.key,key]);
      requirements.push({event:final.key,outcome:0});
    }
    if (event.requiredCard) requirements.push({card:event.requiredCard,consumer:key});
    yield* requireAll(next,requirements,0);
  }
  function *requireAll(state,goals,index) {
    if (index===goals.length) {yield state;return;}
    const goal = goals[index];
    const states = goal.card ? requireCard(state,goal.card,goal.consumer) : requireEvent(state,goal.event,goal.outcome);
    for (const next of states) yield* requireAll(next,goals,index+1);
  }
  function order(state) {
    const edges = state.edges.slice();
    // 엔딩을 본 뒤에는 해당 지역의 일반 사건을 뽑을 수 없다.
    if (final && state.outcomes.has(final.key)) for (const key of state.outcomes.keys()) {
      const event = events.get(key);
      if (!event.mainStage && !event.epilogue) edges.push([key,final.key]);
    }
    const dependencies = new Map([...state.outcomes.keys()].map(key=>[key,new Set()]));
    for (const [before,after] of edges) if (dependencies.has(before) && dependencies.has(after)) dependencies.get(after).add(before);
    const ordered = [],remaining = new Set(state.outcomes.keys());
    while (remaining.size) {
      const next = [...remaining].find(key=>[...dependencies.get(key)].every(before=>!remaining.has(before)));
      if (!next) return null;
      remaining.delete(next);
      ordered.push({event:next,outcome:state.outcomes.get(next)||1});
    }
    return ordered;
  }
  function find(goals) {
    const state = {outcomes:new Map(),expanded:new Set(),edges:[]};
    for (const possible of requireAll(state,goals,0)) {
      const witness = order(possible);
      if (witness) return witness;
    }
    return null;
  }
  return {find,sources};
}

function inspectExpansion(data,expectedKey=data?.world?.key) {
  const errors = [],warnings = [];
  const fail = (key,reason) => errors.push({key,reason});
  const warn = (key,reason) => warnings.push({key,reason});
  let base;
  try {base=inspect(data);} catch (error) {fail('root','기본 검사 실행 실패. '+error.message);return {world:expectedKey,errors,warnings};}
  errors.push(...base.errors);warnings.push(...base.warnings);
  if (data.world?.key!==expectedKey) fail('world','파일명과 작품 key가 다름');
  if (!Array.isArray(data.cards) || !Array.isArray(data.events)) return {world:expectedKey,errors,warnings};
  if (base.errors.length) return {world:expectedKey,cards:data.cards.length,events:data.events.length,errors,warnings};
  const cards = new Map(data.cards.filter(Boolean).map(card=>[card.key,card]));
  const ordinaryNames = new Set([...cards.values()].filter(card=>!card.endingCard).map(card=>card.name));
  for (const card of cards.values()) if (card.endingCard && ordinaryNames.has(card.name)) {
    fail(card.key,'엔딩 카드 이름이 일반 카드와 같아 지역·이름 기준 성장 묶음에 합쳐질 수 있음');
  }
  const events = data.events.filter(Boolean);
  function checkEffects(key,effects) {
    for (const effect of effects||[]) {
      if (!permittedStats.has(effect.stat)) fail(key,'스키마에 없는 스탯. '+effect.stat);
      if (effect.stat==='kill_gold' && effect.value) fail(key,'이번 여섯 작품에는 처치 골드 보상 스탯을 사용하지 않음');
    }
  }
  checkEffects('world',data.world?.effects);
  for (const card of cards.values()) {checkEffects(card.key,card.effects);checkEffects(card.key,card.evolution?.effects);}
  for (const change of data.storyChanges||[]) checkEffects(change.key,change.extraEffects);
  const main = events.filter(event=>event.mainStage);
  const side = events.filter(event=>!event.mainStage && !event.epilogue);
  const epilogues = events.filter(event=>event.epilogue);
  const free = side.filter(event=>event.actionCost===0);
  if (!main.length) fail('world','메인 이야기가 없음');
  if (free.length<2) fail('world','무료 일반 사건이 두 개 미만임');
  for (const event of events) {
    if (event.choices?.length!==3) fail(event.key,'보상 선택지는 기본 세 개여야 함');
    for (const [index,choice] of (event.choices||[]).entries()) {
      if (!choice) continue;
      const key = event.key+'#'+(index+1);
      for (const field of ['cost','gold','potions']) if (choice[field]!==0) fail(key,'이번 여섯 작품의 '+field+'는 0이어야 함');
      for (const [field,value] of Object.entries(choice)) {
        if (!permittedChoiceFields.has(field)) fail(key,'스키마에 없는 선택지 필드. '+field);
        if (/^(?:health|hp|life)(?:Cost|Payment|Loss|Reward|Recovery)?$/i.test(field.replace(/[_-]/g,'')) && value) {
          fail(key,'체력 지불·직접 회복 필드를 사용할 수 없음. '+field);
        }
      }
    }
    const rewardCards = (event.choices||[]).map(choice=>cards.get(choice.card));
    const commonEnding = event.mainStage===data.world?.mainStory?.length && rewardCards.length===3 &&
      rewardCards.every(card=>card?.endingCard===true && effectVector(card)==='[]') &&
      new Set(rewardCards.map(card=>card.key)).size===1 && event.choices.every(choice=>!choice.card2);
    // 일반 사건의 보조 카드도 더해, 카드 이름이나 지급 묶음만 다른 같은 보상을 찾는다.
    const vectors = event.choices.map(choice=>effectVector({effects:[choice.card,choice.card2]
      .filter(Boolean).flatMap(key=>cards.get(key)?.effects||[])}));
    if (!commonEnding && new Set(vectors).size!==vectors.length) {
      const duplicates = vectors.map((vector,index)=>({choice:index+1,vector}))
        .filter(item=>vectors.filter(vector=>vector===item.vector).length>1);
      fail(event.key,'세 보상 중 실제 효과 벡터가 같은 선택이 있음. '+JSON.stringify(duplicates));
    }
    if (event.mainStage) {
      if (!event.dialogue?.enabled) fail(event.key,'메인 사건에는 다단계 대화가 필요함');
      if (new Set(rewardCards.map(card=>card?.grade)).size!==1) fail(event.key,'메인 세 보상의 희귀도가 다름');
    }
  }
  const planner = createPlanner(data);
  const reachable = new Map();
  for (const event of events) {
    const witness = planner.find([{event:event.key,outcome:0}]);
    if (!witness) fail(event.key,'입문 카드에서 시작하는 진행 경로가 없음. 보유 카드·선행 선택·메인 순서를 확인해야 함');
    else reachable.set(event.key,witness);
  }
  const requiredCards = events.filter(event=>event.requiredCard).map(event=>({event:event.key,card:event.requiredCard,path:reachable.get(event.key)||null}));
  const capacityCards = [];
  for (const card of cards.values()) {
    const amount = [...card.effects,...card.evolution.effects].filter(effect=>effect.stat==='action_capacity').reduce((sum,effect)=>sum+effect.value,0);
    if (amount<=0) continue;
    const sources = planner.sources.get(card.key)||[];
    const possible = sources.filter(source=>source.entry || planner.find([{event:source.event,outcome:source.outcome}]));
    let duplicate = null;
    for (let i=0;i<possible.length && !duplicate;i++) for (let j=i+1;j<possible.length && !duplicate;j++) {
      const pair = [possible[i],possible[j]];
      // 같은 사건의 두 선택은 한 번의 획득이며 실패 분기에는 카드가 지급되지 않는다.
      if (!pair[0].entry && pair[0].event===pair[1].event) continue;
      const witness = planner.find(pair.filter(source=>!source.entry).map(source=>({event:source.event,outcome:source.outcome})));
      if (witness) duplicate={sources:pair,path:witness};
    }
    if (duplicate) warn(card.key,'행동력 최대치 카드의 중복 획득이 가능한 경로가 있음. 중복 강화로 최대치와 현재 행동력이 증가할 수 있으므로 검토 필요');
    capacityCards.push({card:card.key,baseCapacity:amount,acquisitionSources:possible,duplicate});
  }
  return {
    world:expectedKey,cards:cards.size,events:events.length,main:main.length,side:side.length,epilogues:epilogues.length,
    reachable:reachable.size,freeSideEvents:free.map(event=>event.key),freeEpilogues:epilogues.filter(event=>event.actionCost===0).map(event=>event.key),
    requiredCards,capacityCards,errors,warnings
  };
}

function inspectDirectory(directory=defaultDirectory,allowMissing=false) {
  directory = path.resolve(directory);
  const worlds = [],missing = [],errors = [],warnings = [];
  const seenCards = new Map(),seenEvents = new Map();
  const catalogs = new Map();
  for (const name of fs.readdirSync(directory).filter(name=>name.endsWith('.json')).sort()) {
    const file = path.join(directory,name);
    let data;
    try {data=JSON.parse(fs.readFileSync(file,'utf8').replace(/^\uFEFF/,''));}
    catch (error) {errors.push({key:name,reason:'JSON을 읽을 수 없음. '+error.message});continue;}
    const key = data?.world?.key;
    if (!worldKeys.includes(key)) continue;
    if (catalogs.has(key)) {
      errors.push({key,reason:'같은 작품 key를 가진 파일이 둘 이상임. '+catalogs.get(key).file+' / '+file});
      continue;
    }
    catalogs.set(key,{file,data});
  }
  for (const key of worldKeys) {
    const catalog = catalogs.get(key);
    if (!catalog) {
      missing.push(key);
      if (!allowMissing) errors.push({key,reason:'필수 작품 key의 파일이 없음. '+key+' / '+directory});
      continue;
    }
    const {data} = catalog;
    const result = inspectExpansion(data,key);
    worlds.push(result);
    errors.push(...result.errors.map(issue=>({world:key,...issue})));
    warnings.push(...result.warnings.map(issue=>({world:key,...issue})));
    for (const [kind,items,seen] of [['card',data?.cards,seenCards],['event',data?.events,seenEvents]]) for (const item of Array.isArray(items) ? items.filter(Boolean) : []) {
      if (seen.has(item.key)) errors.push({world:key,key:item.key,reason:kind+' key가 다른 작품과 중복됨. '+seen.get(item.key)});
      else seen.set(item.key,key);
    }
  }
  if (!worlds.length) errors.push({key:'root',reason:'검사한 작품이 없음'});
  return {
    directory,expectedWorlds:worldKeys,checkedWorlds:worlds.length,missing,complete:missing.length===0 && worlds.length===worldKeys.length,
    scope:'정적 경로 가능성 검사. 머리 카드 획득·충분한 행동력·해당 일반 사건의 파티 공용 미소진을 가정하며 실제 등장 확률과 플레이 시간은 검증하지 않음.',
    runtimeTested:false,worlds,errors,warnings
  };
}

function parseArgs(args) {
  const options = {directory:defaultDirectory,allowMissing:false,selfTest:false};
  for (let i=0;i<args.length;i++) {
    if (args[i]==='--allow-missing') options.allowMissing=true;
    else if (args[i]==='--self-test') options.selfTest=true;
    else if (args[i]==='--directory') {
      if (!args[i+1] || args[i+1].startsWith('--')) throw Error('--directory 뒤에 검사할 폴더를 지정해야 합니다.');
      options.directory=path.resolve(args[++i]);
    } else throw Error('지원 옵션은 --directory <폴더>, --allow-missing, --self-test입니다.');
  }
  return options;
}

function selfTest() {
  const assert = require('node:assert/strict');
  const effect = value => [{stat:'attack_percent',value}];
  const card = (key,value,extra={}) => ({key,name:key,effectName:key,keyword:key,grade:1,effects:effect(value),evolution:{kind:0,goal:0,effects:[]},...extra});
  const choice = key => ({label:key,result:key,card:key,card2:null,gold:0,cost:0,level:0,density:0,potions:0,chance:100});
  const event = (key,keys,extra={}) => ({key,title:key,intro:key,story:key,previous:null,previousChoice:0,requiredCard:null,actionCost:1,choices:keys.map(choice),failure:'',...extra});
  function fixture() {
    return {
      world:{key:'fixture',name:'검사용',work:'검사용',effects:effect(1),entryCard:'entry',mainStory:{title:'순서',length:2}},
      cards:[card('entry',1),card('a',2),card('b',3),card('c',4),card('token',1),card('ap',1,{effects:[{stat:'action_capacity',value:1},...effect(1)]}),card('ending',0,{effects:[],endingCard:true})],
      events:[
        event('first',['a','b','c'],{mainStage:1,dialogue:{enabled:true,commonResult:'진행',nodes:[]}}),
        event('last',['ending','ending','ending'],{mainStage:2,dialogue:{enabled:true,commonResult:'',nodes:[{key:'ending',story:'끝',choices:[{label:'확인',result:'끝'}]}]}}),
        event('free_a',['a','b','c'],{actionCost:0}),event('free_b',['a','b','c'],{actionCost:0}),
        event('source',['token','a','b']),event('capacity',['ap','a','b'])
      ]
    };
  }
  const baseline = fixture();
  assert.equal(inspectExpansion(baseline).errors.length,0);
  assert.equal(inspectExpansion(baseline).capacityCards[0].duplicate,null,'한 사건의 AP 보상은 중복 획득으로 세지 않음');
  function rejected(edit,pattern) {
    const data = fixture();edit(data);
    assert.ok(inspectExpansion(data).errors.some(issue=>pattern.test(issue.reason)),String(pattern));
  }
  rejected(data=>{data.events[2].choices.pop();},/기본 세 개/);
  rejected(data=>{data.events[2].choices[0].gold=1;},/gold/);
  rejected(data=>{data.events[2].choices[0].potions=1;},/물약|potions/);
  rejected(data=>{data.events[2].choices[0].hpCost=1;},/체력/);
  rejected(data=>{data.cards.find(item=>item.key==='b').effects=effect(2);},/벡터/);
  rejected(data=>{data.cards.find(item=>item.key==='token').effects=effect(2);},/벡터/);
  rejected(data=>{data.events.push(event('same_epilogue',['entry','token','a'],{epilogue:true}));},/벡터/);
  rejected(data=>{
    const source=data.events.find(item=>item.key==='source');
    source.choices[0].card2='b';source.choices[2].card='c';
  },/벡터/);
  rejected(data=>{data.events.push(event('not_final_memorial',['ending','ending','ending'],{epilogue:true}));},/벡터/);
  const bundled = fixture();
  bundled.events.find(item=>item.key==='source').choices.forEach(item=>{item.card='token';});
  bundled.events.find(item=>item.key==='source').choices[1].card2='b';
  bundled.events.find(item=>item.key==='source').choices[2].card2='c';
  assert.deepEqual(inspectExpansion(bundled).errors,[],'같은 기본 카드에 서로 다른 보조 효과를 더한 세 보상은 허용함');
  const repeatedCapacity = fixture();
  repeatedCapacity.events.find(item=>item.key==='capacity').choices.forEach(item=>{item.card='ap';});
  assert.equal(inspectExpansion(repeatedCapacity).capacityCards[0].duplicate,null,'같은 사건의 세 분기는 세 번의 AP 카드 획득이 아님');
  assert.ok(inspectExpansion(repeatedCapacity).errors.some(issue=>issue.key==='capacity' && /벡터/.test(issue.reason)),'동일 사건의 AP 보상도 실제 선택 다양성 검사는 통과할 수 없음');
  rejected(data=>{data.cards.find(item=>item.key==='ending').name='a';},/엔딩 카드 이름/);
  rejected(data=>{data.events.find(item=>item.key==='source').requiredCard='token';},/진행 경로가 없음/);
  rejected(data=>{data.events[2].requiredCard='ending';},/진행 경로가 없음/);
  rejected(data=>{data.events[2].previous='source';data.events[2].previousChoice=2;data.events[2].requiredCard='token';},/진행 경로가 없음/);
  const compatible = fixture();
  Object.assign(compatible.events[2],{previous:'source',previousChoice:1,requiredCard:'token'});
  assert.equal(inspectExpansion(compatible).errors.length,0,'같은 성공 분기가 카드와 선행 조건을 모두 만족할 수 있음');
  const duplicate = fixture();duplicate.events.push(event('capacity_again',['ap','a','b']));
  assert.ok(inspectExpansion(duplicate).capacityCards[0].duplicate,'다른 사건에서 같은 AP 카드를 다시 획득할 수 있음');
  const gated = fixture();
  Object.assign(gated.events.find(item=>item.key==='capacity'),{previous:'source',previousChoice:1});
  gated.events.push(event('capacity_other',['ap','a','b'],{previous:'source',previousChoice:2}));
  assert.equal(inspectExpansion(gated).capacityCards[0].duplicate,null,'서로 배타적인 선행 선택의 AP 보상은 반복 획득할 수 없음');
  const epilogue = fixture();epilogue.events.push(event('after',['a','b','c'],{epilogue:true,requiredCard:'ending'}));
  assert.equal(inspectExpansion(epilogue).errors.length,0,'엔딩 카드는 후일담 보유 조건으로 사용 가능함');
  assert.equal(parseArgs([]).directory,defaultDirectory,'기본 검사는 실제 배포 카탈로그를 대상으로 함');
  assert.deepEqual(parseArgs(['--directory','content/expansion-drafts','--allow-missing']),{directory:path.resolve('content/expansion-drafts'),allowMissing:true,selfTest:false});
  assert.throws(()=>parseArgs(['--directory','--self-test']),/폴더를 지정/);
  return {selfTests:25,passed:true,runtimeTested:false};
}

if (require.main===module) {
  const options = parseArgs(process.argv.slice(2));
  const result = options.selfTest ? selfTest() : inspectDirectory(options.directory,options.allowMissing);
  console.log(JSON.stringify(result,null,2));
  if (result.errors?.length) process.exitCode=1;
}
module.exports = {worldKeys,effectVector,createPlanner,inspectExpansion,inspectDirectory,selfTest};
