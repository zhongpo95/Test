// 검토를 통과한 사건·카드 JSON을 원정 데이터 JASS로 변환한다.
'use strict';
const fs = require('node:fs'), path = require('node:path');
const {inspect} = require('./check-content-candidates.cjs');
const root = path.resolve(__dirname, '..');
const statNames = ['attack_percent','damage_percent','final_damage_percent','boss_damage_percent','normal_damage_percent','crit_chance','crit_damage','swift','action_speed','move_speed','charge_speed','penetration','max_health_percent','damage_reduction','leech','regeneration','kill_gold','event_choices','moving_damage','directional_damage','nondirectional_damage','shielded_damage','charge_damage','healthy_damage','action_capacity'];
const q = x => '"' + String(x).replace(/\\/g,'\\\\').replace(/"/g,'\\"').replace(/\r?\n/g,'|n') + '"';
const highlightConfig = {"palette":{"person":"FF006B8F","clue":"FF865500"},"limits":{"story":4,"intro":2,"label":1,"result":2},"worlds":{"fuyuki":{"person":["에미야 시로","시로","세이버","토오사카 린","린","아처","랜서","캐스터","길가메시"],"clue":["성배","룰 브레이커","수호자","영주"]},"axel":{"person":["카즈마","아쿠아","메구밍","다크니스","위즈","베르디아"],"clue":["디스트로이어","동력원","폭렬 마법"]},"abydos":{"person":["호시노","시로코","세리카","아야네","노노미","선생","검은 양복"],"clue":["자퇴서","사막 기지","카이저론","학교 부지"]},"academy":{"person":["미코토","토우마","누노타바 시노부","시노부","일방통행","10032호","액셀러레이터"],"clue":["시스터즈","트리 다이어그램","레벨 6","미사카 네트워크","레벨6 시프트"]},"mitakihara":{"person":["마도카","호무라","마미","사야카","쿄코","큐베"],"clue":["소울젬","그리프 시드","발푸르기스의 밤","소울 젬"]},"aincrad":{"person":["키리토","아스나","유이","사치","카야바","히스클리프"],"clue":["너브기어","유이의 마음","이도류","시스템 관리자"]},"amestris":{"person":["에드","알","윈리","호엔하임","머스탱","린","그리드","스카"],"clue":["현자의 돌","인체 연성","국토 연성진","진리의 문"]},"karakura":{"person":["이치고","루키아","렌지","뱌쿠야","아이젠","요루이치","우라하라"],"clue":["붕옥","쌍극","만해","중앙 46실"]},"gourmet":{"person":["페코린느","캐르","콧코로","유우키","카이저","라비리스트","쥰"],"clue":["미식전","반지","열쇠","쉐도우"]},"butterfly":{"person":["탄지로","네즈코","시노부","카나오","렌고쿠","엔무","아카자"],"clue":["전집중 상중","정신의 핵","무한열차"]},"magnolia":{"person":["나츠","루시","엘자","그레이","마카로프","가질","조제"],"clue":["페어리 테일","팬텀 로드","주피터","엘리먼트 4"]},"penacony":{"person":["미샤","미하일","반디","선데이","로빈","아케론","어벤츄린","블랙 스완"],"clue":["은하열차","꿈의 주인","시계공","꿈의 경계"]},"zegagrande":{"person":["루리아","비","롤란","릴리스","이드"],"clue":["구속구","앙그라마이뉴","베르사","일지"]}}};
// 원고는 평문으로 두고 생성 시점에만 짧은 인물·단서 강조를 추가한다.
function highlight(text, world, field, config) {
  if (!config) return text;
  const source=String(text), rules=config.worlds[world] || {}, spans=[], used=new Set();
  if (/\|[cr]/i.test(source)) throw Error('사건 원문에 색상 코드가 있습니다. '+world);
  const candidates=Object.entries(rules).flatMap(([kind,words])=>words.map(word=>({word,kind})))
    .sort((a,b)=>b.word.length-a.word.length);
  for (const {word,kind} of candidates) {
    if (!word || used.has(word)) continue;
    let start=source.indexOf(word);
    // '열린' 안의 '린'처럼 일반 단어 내부를 인물로 강조하지 않는다. 뒤의 한국어 조사는 허용한다.
    while (start>=0) {
      const inside=start>0 && /[\p{L}\p{N}_]/u.test(source[start-1]);
      const suffix=source.slice(start+word.length).match(/^[\p{L}\p{N}_]+/u)?.[0] || '';
      const shortCollision=word.length===1 && suffix && !/^(은|는|이|가|을|를|의|과|와|에|에서|에게|도|만|로|으로|께|랑|이랑|처럼|조차|마저|부터|까지|에게는|에게도|에게서|이라는|라는|이라고|라고|이다|였다)$/.test(suffix);
      if (!inside && !shortCollision) break;
      start=source.indexOf(word,start+word.length);
    }
    const end=start+word.length;
    if (start<0 || spans.some(s=>start<s.end && end>s.start)) continue;
    spans.push({start,end,color:config.palette[kind]});used.add(word);
  }
  const selected=spans.sort((a,b)=>a.start-b.start).slice(0,config.limits[field]);
  let result='',cursor=0;
  for (const s of selected) {result+=source.slice(cursor,s.start)+'|c'+s.color+source.slice(s.start,s.end)+'|r';cursor=s.end;}
  return result+source.slice(cursor);
}
function generate(worlds, options={}) {
  const highlights=options.highlights===false ? null : highlightConfig;
  const cards = new Map(), events = new Map(), lines = [];
  const changeKeys = new Set(), eventFirst = new Map();
  let changeCount = 0;
  let nextCard = 13, nextEvent = worlds.filter(w=>w.world.key!=='common').length * 4 + 1, head = 0;
  for (const w of worlds) {
    const report = inspect(w);
    if (report.errors.length) throw Error(JSON.stringify(report));
    for (const change of w.storyChanges || []) {
      if (changeKeys.has(change.key)) throw Error('작품 간 서사 변화 key 중복. '+change.key);
      changeKeys.add(change.key);changeCount++;
    }
    w.head = w.world.key==='common' ? 0 : ++head;
    for (const c of w.cards.filter(c=>!c.endingCard)) {
      if (cards.has(c.key)) throw Error('작품 간 카드 key 중복. '+c.key);
      cards.set(c.key,nextCard++);
    }
    for (const e of w.events) {
      if (events.has(e.key)) throw Error('작품 간 사건 key 중복. '+e.key);
      events.set(e.key,nextEvent++);
    }
  }
  // 엔딩 카드는 기존 작품별 카드의 숫자 ID를 유지하도록 전체 기존 카드 뒤에 배정한다.
  for (const w of worlds) for (const c of w.cards.filter(c=>c.endingCard)) {
    if (cards.has(c.key)) throw Error('작품 간 카드 key 중복. '+c.key);
    cards.set(c.key,nextCard++);
  }
  if (nextCard>1024 || nextEvent>1024 || head>80) throw Error('플레이어별 JASS 키 공간을 초과합니다. 저장 구조를 확장한 뒤 다시 생성하세요.');
  const strings = ['ProtoCardDescription','ProtoEventCommonResult','ProtoDialogueStory','ProtoDialogueLabel','ProtoDialogueResult','ProtoStoryChangeKey','ProtoStoryChangeName','ProtoStoryChangeDescriptionText','ProtoHeadKey','ProtoHeadName','ProtoHeadIntro','ProtoHeadIcon','ProtoCardKey','ProtoCardName','ProtoCardEffectName','ProtoCardKeyword','ProtoEventKey','ProtoEventName','ProtoEventStory','ProtoEventIntro','ProtoEventIcon','ProtoEventFailure','ProtoBranchLabel','ProtoBranchResult'];
  const integers = ['ProtoCardEnding','ProtoEventDialogueEnabled','ProtoEventDialogueFirst','ProtoDialogueNext','ProtoDialogueChoices','ProtoStoryChangeDescriptionLines','ProtoStoryChangeCharacter','ProtoStoryChangeForCharacter','ProtoStoryChangeFirst','ProtoStoryChangeNext','ProtoHeadEntryCard','ProtoHeadMainLength','ProtoCardHead','ProtoCardGrade','ProtoEvolutionKind','ProtoEventHead','ProtoEventMainStage','ProtoEventEpilogue','ProtoEventGrade','ProtoEventKind','ProtoEventAPCost','ProtoEventRequired','ProtoEventRequiredChoice','ProtoEventRequiredCard','ProtoEventHistory','ProtoEventChoices','ProtoBranchCard','ProtoBranchCard2','ProtoBranchGold','ProtoBranchCost','ProtoBranchLevel','ProtoBranchDensity','ProtoBranchPotions','ProtoBranchChance'];
  lines.push('// 검토된 머리 카드, 캐릭터 카드와 사건 콘텐츠를 로드한다. 생성 도구로 갱신한다.', 'library DataPrototypeCatalog initializer ProtoCatalogInit requires DataPrototypeStats','    globals',
    '        constant integer PROTO_HEAD_COUNT = '+head,
    '        constant integer PROTO_STORY_CHANGE_COUNT = '+changeCount,
    '        hashtable ProtoStoryChangeEffects = InitHashtable()',
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
  let changeId = 0, dialogueId = 0;
  // 작품별 로더로 분리해 큰 단일 초기화 함수의 실행 한도를 피한다.
  for (let wi=0;wi<worlds.length;wi++) {
    const w=worlds[wi], h=w.head;
    const marked=(text,field)=>highlight(text,w.world.key,field,highlights);
    lines.push('    function ProtoLoadWorld'+wi+' takes nothing returns nothing');
    if (h) {
      set('ProtoHeadKey',h,w.world.key);set('ProtoHeadName',h,w.world.name); set('ProtoHeadIntro',h,w.world.intro);
      set('ProtoHeadIcon',h,w.world.icon || 'ReplaceableTextures\\CommandButtons\\BTNManual.blp');
      set('ProtoHeadEntryCard',h,cards.get(w.world.entryCard));set('ProtoHeadMainLength',h,w.world.mainStory?.length || 0);
      for (const e of w.world.effects || [w.world.bonus]) {
        if (!e || !statNames.includes(e.stat) || !Number.isFinite(e.value)) throw Error('머리 카드 효과 오류. '+w.world.key);
        lines.push('        call SaveReal(ProtoHeadEffectData, '+h+', '+(statNames.indexOf(e.stat)+1)+', '+Number(e.value).toFixed(2)+')');
      }
      for (let p=0;p<4;p++) {
        const id=(h-1)*4+p+1;
        set('ProtoEventKey',id,w.world.key+'_entry_'+p);set('ProtoEventName',id,w.world.name+' 방문'); set('ProtoEventHead',id,h); set('ProtoEventKind',id,0);set('ProtoEventChoices',id,1);
        set('ProtoEventAPCost',id,0);set('ProtoEventGrade',id,1);
        set('ProtoEventStory',id,marked(w.world.intro,'story')); set('ProtoEventIntro',id,marked(w.world.intro,'intro'));set('ProtoEventIcon',id,w.world.entryIcon || w.world.icon || 'ReplaceableTextures\\CommandButtons\\BTNManual.blp');
      }
    }
    for (const c of w.cards) {
      const id=cards.get(c.key);
      if (c.endingCard) {set('ProtoCardEnding',id,1);set('ProtoCardDescription',id,c.canonFact);}
      set('ProtoCardKey',id,c.key);set('ProtoCardName',id,c.name);set('ProtoCardEffectName',id,c.effectName);set('ProtoCardKeyword',id,w.world.name+' · '+c.keyword);
      set('ProtoCardHead',id,h);set('ProtoCardGrade',id,c.grade);set('ProtoEvolutionKind',id,c.evolution.kind);
      lines.push('        set ProtoEvolutionGoal['+id+'] = '+Number(c.evolution.goal).toFixed(2));
      effects(id,c.effects,false); effects(id,c.evolution.effects,true);
    }
    for (const e of w.events) {
      const id=events.get(e.key);
      set('ProtoEventKey',id,e.key);set('ProtoEventName',id,e.title);set('ProtoEventHead',id,h);set('ProtoEventKind',id,1);set('ProtoEventChoices',id,e.choices.length);
      set('ProtoEventAPCost',id,e.actionCost ?? 1);set('ProtoEventMainStage',id,e.mainStage || 0);set('ProtoEventEpilogue',id,e.epilogue ? 1 : 0);
      // 분기 최고 카드 등급은 가능한 보상의 기준이며 성공률은 각 분기에 별도 표시한다.
      set('ProtoEventGrade',id,Math.max(1,...e.choices.flatMap(b=>[b.card,b.card2]).filter(Boolean).map(key=>worlds.flatMap(x=>x.cards).find(c=>c.key===key).grade)));
      set('ProtoEventStory',id,marked(e.story,'story'));set('ProtoEventIntro',id,marked(e.intro,'intro'));set('ProtoEventIcon',id,e.icon || w.world.icon || 'ReplaceableTextures\\CommandButtons\\BTNTome.blp');
      set('ProtoEventRequired',id,e.previous ? events.get(e.previous) : 0);set('ProtoEventRequiredChoice',id,e.previousChoice || 0);set('ProtoEventRequiredCard',id,e.requiredCard ? cards.get(e.requiredCard):0);set('ProtoEventFailure',id,e.failure || '');
      if (e.dialogue?.enabled) {
        set('ProtoEventDialogueEnabled',id,1);
        set('ProtoEventCommonResult',id,marked(e.dialogue.commonResult,'story'));
        set('ProtoEventDialogueFirst',id,e.dialogue.nodes.length ? dialogueId+1 : 0);
        e.dialogue.nodes.forEach((node,index)=>{
          const nid=++dialogueId;
          if (nid*4+3>=8192) throw Error('대화 선택 배열 범위 초과');
          set('ProtoDialogueStory',nid,marked(node.story,'story'));
          set('ProtoDialogueChoices',nid,node.choices.length);
          set('ProtoDialogueNext',nid,index+1<e.dialogue.nodes.length ? nid+1 : 0);
          node.choices.forEach((choice,j)=>{
            set('ProtoDialogueLabel',nid*4+j,marked(choice.label,'label'));
            set('ProtoDialogueResult',nid*4+j,marked(choice.result,'result'));
          });
        });
      }
      e.choices.forEach((b,i)=>{
        const key=id*4+i;
        set('ProtoBranchLabel',key,marked(b.label,'label'));set('ProtoBranchResult',key,marked(b.result,'result'));
        for (const n of ['card','card2']) set('ProtoBranch'+n[0].toUpperCase()+n.slice(1),key,b[n] ? cards.get(b[n]):0);
        for (const n of ['gold','cost','level','density','potions','chance']) set('ProtoBranch'+n[0].toUpperCase()+n.slice(1),key,b[n]);
      });
    }
    for (const change of w.storyChanges || []) {
      const id=++changeId, event=events.get(change.eventKey);
      const target=w.cards.find(c=>c.key===change.characterCardKey);
      const character=cards.get(w.cards.find(c=>c.name===target.name).key);
      set('ProtoStoryChangeKey',id,change.key);
      set('ProtoStoryChangeCharacter',id,character);set('ProtoStoryChangeForCharacter',character,id);
      // Unicode 문자 기준으로 계산해 JASS 바이트 길이에 의존하지 않는다.
      set('ProtoStoryChangeDescriptionLines',id,change.description.replace(/\r?\n/g,'|n').split('|n').reduce((n,line)=>n+Math.max(1,Math.ceil([...line].length/22)),0));
      set('ProtoStoryChangeName',id,change.displayName);set('ProtoStoryChangeDescriptionText',id,change.description);
      set('ProtoStoryChangeNext',id,eventFirst.get(event)||0);set('ProtoStoryChangeFirst',event,id);eventFirst.set(event,id);
      for (const effect of change.extraEffects) lines.push('        call SaveReal(ProtoStoryChangeEffects, '+id+', '+(statNames.indexOf(effect.stat)+1)+', '+Number(effect.value).toFixed(2)+')');
    }
    lines.push('    endfunction','');
  }
  // 지역별 초기화를 별도 실행하여 늘어난 전체 카탈로그가 한 스레드의 실행 한도를 공유하지 않게 한다.
  lines.push('    function ProtoCatalogInit takes nothing returns nothing',...worlds.map((_,i)=>'        call ExecuteFunc("ProtoLoadWorld'+i+'")'),'    endfunction','endlibrary','');
  return lines.join('\n');
}
function run() {
  const dir=path.join(root,'content/roguelite');
  const files=fs.readdirSync(dir).filter(f=>f.endsWith('.json')).sort();
  const worlds=files.map(f=>JSON.parse(fs.readFileSync(path.join(dir,f),'utf8')));
  const text=generate(worlds), file=path.join(root,'Data/Data_PrototypeCatalog.j');
  if (process.argv.includes('--check')) {
    if (fs.readFileSync(file,'utf8').replace(/\r\n/g,'\n')!==text) throw Error('검토 JSON과 생성 JASS가 일치하지 않습니다.');
  } else fs.writeFileSync(file,text);
  console.log(JSON.stringify({worlds:worlds.filter(w=>w.world.key!=='common').length,cards:worlds.reduce((n,w)=>n+w.cards.length,0),events:worlds.reduce((n,w)=>n+w.events.length,0)}));
}
module.exports={generate,highlight,highlightConfig};
if (require.main===module) {try {run();} catch(e) {console.error(e.message);process.exitCode=1;}}
