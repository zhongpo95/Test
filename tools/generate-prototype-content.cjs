// 검토를 통과한 사건·카드 JSON을 원정 데이터 JASS로 변환한다.
'use strict';
const fs = require('node:fs'), path = require('node:path');
const {inspect} = require('./check-content-candidates.cjs');
const root = path.resolve(__dirname, '..');
const registryPath = path.join(root,'content/roguelite-id-registry.json');
const readRegistry = () => JSON.parse(fs.readFileSync(registryPath,'utf8'));
const eventThumbnails = JSON.parse(fs.readFileSync(path.join(root,'content/event-images/thumbnail-manifest.json'),'utf8'));
if (Math.abs(eventThumbnails.displayAspect-16/9)>0.000001) throw Error('사건 썸네일은 16:9 표시 규격이어야 합니다.');
const eventImageTargets = new Map(eventThumbnails.assets.map(asset=>[asset.source,asset.target]));
if (eventImageTargets.size!==eventThumbnails.assets.length) throw Error('사건 썸네일 원본 경로 중복.');
const statNames = ['attack_percent','damage_percent','final_damage_percent','boss_damage_percent','normal_damage_percent','crit_chance','crit_damage','swift','action_speed','move_speed','charge_speed','penetration','max_health_percent','damage_reduction','leech','regeneration','kill_gold','event_choices','moving_damage','directional_damage','nondirectional_damage','shielded_damage','charge_damage','healthy_damage','action_capacity'];
const q = x => '"' + String(x).replace(/\\/g,'\\\\').replace(/"/g,'\\"').replace(/\r?\n/g,'|n') + '"';
const readability = JSON.parse(fs.readFileSync(path.join(root,'content/event-readability.json'),'utf8'));
const highlightConfig = {"palette":{"person":"FF006B8F","clue":"FF865500"},"limits":{"story":4,"intro":2,"label":1,"result":2},"worlds":{"fuyuki":{"person":["에미야 시로","시로","세이버","토오사카 린","린","아처","랜서","캐스터","길가메시"],"clue":["성배","룰 브레이커","수호자","영주"]},"axel":{"person":["카즈마","아쿠아","메구밍","다크니스","위즈","베르디아"],"clue":["디스트로이어","동력원","폭렬 마법"]},"abydos":{"person":["호시노","시로코","세리카","아야네","노노미","선생","검은 양복"],"clue":["자퇴서","사막 기지","카이저론","학교 부지"]},"academy":{"person":["미코토","토우마","누노타바 시노부","시노부","일방통행","10032호","액셀러레이터"],"clue":["시스터즈","트리 다이어그램","레벨 6","미사카 네트워크","레벨6 시프트"]},"mitakihara":{"person":["마도카","호무라","마미","사야카","쿄코","큐베"],"clue":["소울젬","그리프 시드","발푸르기스의 밤","소울 젬"]},"aincrad":{"person":["키리토","아스나","유이","사치","카야바","히스클리프"],"clue":["너브기어","유이의 마음","이도류","시스템 관리자"]},"amestris":{"person":["에드","알","윈리","호엔하임","머스탱","린","그리드","스카"],"clue":["현자의 돌","인체 연성","국토 연성진","진리의 문"]},"karakura":{"person":["이치고","루키아","렌지","뱌쿠야","아이젠","요루이치","우라하라"],"clue":["붕옥","쌍극","만해","중앙 46실"]},"gourmet":{"person":["페코린느","캐르","콧코로","유우키","카이저","라비리스트","쥰"],"clue":["미식전","반지","열쇠","쉐도우"]},"butterfly":{"person":["탄지로","네즈코","시노부","카나오","렌고쿠","엔무","아카자"],"clue":["전집중 상중","정신의 핵","무한열차"]},"magnolia":{"person":["나츠","루시","엘자","그레이","마카로프","가질","조제"],"clue":["페어리 테일","팬텀 로드","주피터","엘리먼트 4"]},"penacony":{"person":["미샤","미하일","반디","선데이","로빈","아케론","어벤츄린","블랙 스완"],"clue":["은하열차","꿈의 주인","시계공","꿈의 경계"]},"zegagrande":{"person":["루리아","비","롤란","릴리스","이드"],"clue":["구속구","앙그라마이뉴","베르사","일지"]}}};
Object.assign(highlightConfig.worlds, {
  amphoreus: {person:['파이논','키레네','아글라이아','트리비','마이데이','카스토리스','아낙사','히아킨','사이퍼','케리드라','히실렌스','개척자','단항'],clue:['철묘','불씨','검은 물결','재창세']},
  phantom_blood: {person:['죠나단','디오','체펠리','스피드왜건','에리나','톤페티','포코'],clue:['석가면','파문','식시귀 거리']},
  madolche: {person:['마죠레느','푸딩세스','티아라미스','엔젤리','훗케이크','메신젤라또','푸팅세스루','글래스플레'],clue:['초대장','마돌체 샤토','이름표']},
  tengu: {person:['시도','토카','요시노','쿠루미','코토리','오리가미','마나'],clue:['공간진','요시농','라타토스크','AST']},
  ikebukuro: {person:['미카도','마사오미','안리','셀티','이자야','시즈오','신라','카도타'],clue:['다라즈','황건적','사이카','폐공장']},
  frieren: {person:['프리렌','페른','슈타르크','힘멜','하이터','아이젠','자인','플람메','제리에','덴켄','라비네','칸네'],clue:['졸트라크','1급 마법사','복제체','아우라']},
  dungeon_meshi: {person:['라이오스','마르실','칠책','센시','파린','나마리','슈로','카블루'],clue:['염룡','역린','켈피','운디네','고대 마법']},
  hunter_exam: {person:['곤','키르아','크라피카','레오리오','히소카','한조','사토츠','네테로','일루미'],clue:['트릭 타워','제빌섬','번호표','헌터시험','최종 시험']},
  roswaal_mansion: {person:['스바루','에밀리아','렘','람','베아트리스','로즈월','팩'],clue:['금서고','울가름','샤마크','저주']},
  z_city: {person:['사이타마','제노스','소닉','무면허 라이더','뱅','타츠마키','아토믹 사무라이','금속배트','보로스'],clue:['진화의 집','도원단','심해왕','멜자르갈드','우주선']},
  witch_prison: {person:['에마','히로','앙앙','노아','한나','셰리','레이아','미리아','나노카','코코','마고','메루루','아리사','유키'],clue:['대마녀','사바트','마녀 인자']},
  persona5: {person:['조커','모르가나','류지','유스케','마코토','후타바','오쿠무라 하루','아케치','사에','소지로'],clue:['팰리스','예고장','메멘토스','사유리','성배','얄다바오트']},
  persona5_royal: {person:['조커','모르가나','류지','유스케','마코토','후타바','오쿠무라 하루','아케치','요시자와','마루키','스미레','카스미','라벤차'],clue:['메멘토스','상드리용','아자토스','아담 카드몬','예고장']},
  hakugyokurou: {person:['레이무','치르노','레티','첸','앨리스','릴리 화이트','루나사','메를랑','리리카','요우무','유유코'],clue:['백옥루','서행요','명계','봉인']},
  scarlet_mist: {person:['레이무','루미아','치르노','메이링','파츄리','사쿠야','레밀리아'],clue:['붉은 안개','홍마관','양산']},
});
Object.assign(highlightConfig.palette,{emotion:'FF704261',danger:'FFA53528',scene:'FF80560C'});
const sceneWords=['초대장','약속','기억','편지','문틈','발자국','소문','비밀','이름표','기록','노랫소리','목소리','꿈','불빛','그림자','꽃','검','책','도시','마을'];
// 원고는 평문으로 두고 생성 시점에만 짧은 인물·단서 강조를 추가한다.
function highlight(text, world, field, config) {
  if (!config) return text;
  const source=String(text).replace(/\\n/g,'\n'), rules=config.worlds[world] || {}, spans=[], used=new Set();
  if (/\|[cr]/i.test(source)) throw Error('사건 원문에 색상 코드가 있습니다. '+world);
  const reviewed=readability.stories.find(x=>x.world===world && x.story===source);
  const candidates=[...(reviewed?.highlights || []).map(h=>({word:h.text,kind:h.role})),
    ...Object.entries(rules).flatMap(([kind,words])=>words.map(word=>({word,kind}))).sort((a,b)=>b.word.length-a.word.length),
    ...sceneWords.map(word=>({word,kind:'scene'}))];
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
  const selected=spans.slice(0,config.limits[field]).sort((a,b)=>a.start-b.start);
  let result='',cursor=0;
  for (const s of selected) {result+=source.slice(cursor,s.start)+'|c'+s.color+source.slice(s.start,s.end)+'|r';cursor=s.end;}
  return result+source.slice(cursor);
}
// 숫자 ID는 이미지 등록과 연결되므로 기존 키를 고정하고 새 키만 끝에 추가한다.
function allocateIds(worlds, previous=readRegistry()) {
  const registry=structuredClone(previous);
  if (registry.version!==1 || registry.playerKeyStride!==2048 || registry.maximumEntityId!==2047) throw Error('지원하지 않는 콘텐츠 ID 레지스트리 규격.');
  const keys={heads:[],cards:[],events:[]};
  for (const w of worlds) {
    if (w.world.key!=='common') {
      keys.heads.push(w.world.key);
      for (let pid=0;pid<4;pid++) keys.events.push(w.world.key+'_entry_'+pid);
    }
    keys.cards.push(...w.cards.map(c=>c.key));
    keys.events.push(...w.events.map(e=>e.key));
  }
  for (const [kind, names] of Object.entries(keys)) {
    const start=kind==='cards' ? 13 : 1, limit=kind==='heads' ? 80 : registry.maximumEntityId;
    const existing=Object.entries(registry[kind]), ids=existing.map(([,id])=>id).sort((a,b)=>a-b);
    if (new Set(names).size!==names.length) throw Error('작품 간 '+kind+' key 중복.');
    if (ids.some((id,i)=>!Number.isInteger(id) || id!==start+i || id>limit)) throw Error('콘텐츠 ID 범위·연속성 오류. '+kind);
    const active=new Set(names);
    for (const [key] of existing) if (!active.has(key)) throw Error('등록된 콘텐츠 키를 제거할 수 없습니다. 원본 보존과 폐기 처리를 먼저 준비하세요. '+key);
    let next=start+ids.length;
    for (const key of names) if (!Object.hasOwn(registry[kind],key)) registry[kind][key]=next++;
    if (next-1>limit) throw Error('플레이어별 JASS 키 공간을 초과합니다. '+kind+' 최대 '+limit+'번.');
  }
  return registry;
}
function generate(worlds, options={}) {
  const highlights=options.highlights===false ? null : highlightConfig;
  const registry=allocateIds(worlds, options.registry || readRegistry());
  const headsByKey=new Map(worlds.filter(w=>w.world.key!=='common').map(w=>[w.world.key,w.world]));
  for (const world of headsByKey.values()) {
    const visited=new Set([world.key]);
    let required=world.requiresCompletedHead;
    while (required!==undefined) {
      const previous=headsByKey.get(required);
      if (!previous || !previous.mainStory?.length) throw Error('선행 머리 카드의 메인스토리가 없습니다. '+world.key+' -> '+required);
      if (visited.has(required)) throw Error('머리 카드 해금 조건이 순환합니다. '+world.key);
      visited.add(required);required=previous.requiresCompletedHead;
    }
  }
  const cards = new Map(Object.entries(registry.cards)), events = new Map(Object.entries(registry.events)), lines = [];
  const changeKeys = new Set(), eventFirst = new Map();
  let changeCount = 0;
  const nextCard=Math.max(...cards.values())+1, nextEvent=Math.max(...events.values())+1, head=Object.keys(registry.heads).length;
  for (const w of worlds) {
    const report = inspect(w);
    if (report.errors.length) throw Error(JSON.stringify(report));
    for (const change of w.storyChanges || []) {
      if (changeKeys.has(change.key)) throw Error('작품 간 서사 변화 key 중복. '+change.key);
      changeKeys.add(change.key);changeCount++;
    }
    w.head = w.world.key==='common' ? 0 : registry.heads[w.world.key];
  }
  const strings = ['ProtoCardDescription','ProtoEventCommonResult','ProtoDialogueStory','ProtoDialogueLabel','ProtoDialogueResult','ProtoStoryChangeKey','ProtoStoryChangeName','ProtoStoryChangeDescriptionText','ProtoHeadKey','ProtoHeadName','ProtoHeadIntro','ProtoHeadIcon','ProtoCardKey','ProtoCardName','ProtoCardEffectName','ProtoCardKeyword','ProtoEventKey','ProtoEventName','ProtoEventStory','ProtoEventIntro','ProtoEventIcon','ProtoEventFailure','ProtoBranchLabel','ProtoBranchResult'];
  const integers = ['ProtoCardEnding','ProtoEventDialogueEnabled','ProtoEventDialogueFirst','ProtoDialogueNext','ProtoDialogueChoices','ProtoStoryChangeDescriptionLines','ProtoStoryChangeCharacter','ProtoStoryChangeForCharacter','ProtoStoryChangeFirst','ProtoStoryChangeNext','ProtoHeadEntryCard','ProtoHeadEntryEvent','ProtoHeadMainLength','ProtoHeadRequiredMain','ProtoCardHead','ProtoCardGrade','ProtoEvolutionKind','ProtoEventHead','ProtoEventMainStage','ProtoEventEpilogue','ProtoEventGrade','ProtoEventKind','ProtoEventAPCost','ProtoEventRequired','ProtoEventRequiredChoice','ProtoEventRequiredCard','ProtoEventHistory','ProtoEventChoices','ProtoBranchCard','ProtoBranchCard2','ProtoBranchGold','ProtoBranchCost','ProtoBranchLevel','ProtoBranchDensity','ProtoBranchPotions','ProtoBranchChance'];
  lines.push('// 검토된 머리 카드, 캐릭터 카드와 사건 콘텐츠를 로드한다. 생성 도구로 갱신한다.', 'library DataPrototypeCatalog initializer ProtoCatalogInit requires DataPrototypeStats','    globals',
    '        constant integer PROTO_HEAD_COUNT = '+head,
    '        constant integer PROTO_STORY_CHANGE_COUNT = '+changeCount,
    '        hashtable ProtoStoryChangeEffects = InitHashtable()',
    '        constant integer PROTO_EVENT_COUNT = '+(nextEvent-1),
    '        constant integer PROTO_CARD_FIRST = 13',
    '        constant integer PROTO_CARD_LAST = '+(nextCard-1),
    '        constant string PROTO_SAVE_PREFIX = "원정.콘텐츠2."',
    ...strings.map(s=>'        string array '+s), ...integers.map(s=>'        integer array '+s),
    '        real array ProtoEvolutionGoal','        real array ProtoEventImageAspect','    endglobals','');
  const set = (name,id,value) => lines.push('        set '+name+'['+id+'] = '+(typeof value==='string' ? q(value) : value));
  const eventImage = (id, icon) => {
    const thumbnail = eventImageTargets.get(icon);
    if (!thumbnail) throw Error('동일 규격으로 내보내지 않은 사건 그림. '+icon);
    set('ProtoEventIcon',id,thumbnail);
    lines.push('        set ProtoEventImageAspect['+id+'] = '+eventThumbnails.displayAspect.toFixed(6));
  };
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
      set('ProtoHeadKey',h,w.world.key);set('ProtoHeadName',h,w.world.name); set('ProtoHeadIntro',h,marked(w.world.intro,'intro'));
      set('ProtoHeadIcon',h,w.world.icon || 'ReplaceableTextures\\CommandButtons\\BTNManual.blp');
      set('ProtoHeadEntryCard',h,cards.get(w.world.entryCard));set('ProtoHeadMainLength',h,w.world.mainStory?.length || 0);
      set('ProtoHeadRequiredMain',h,w.world.requiresCompletedHead ? registry.heads[w.world.requiresCompletedHead] : 0);
      for (const e of w.world.effects || [w.world.bonus]) {
        if (!e || !statNames.includes(e.stat) || !Number.isFinite(e.value)) throw Error('머리 카드 효과 오류. '+w.world.key);
        lines.push('        call SaveReal(ProtoHeadEffectData, '+h+', '+(statNames.indexOf(e.stat)+1)+', '+Number(e.value).toFixed(2)+')');
      }
      for (let p=0;p<4;p++) {
        const id=events.get(w.world.key+'_entry_'+p);
        set('ProtoHeadEntryEvent',h*4+p,id);
        set('ProtoEventKey',id,w.world.key+'_entry_'+p);set('ProtoEventName',id,w.world.name+' 방문'); set('ProtoEventHead',id,h); set('ProtoEventKind',id,0);set('ProtoEventChoices',id,1);
        set('ProtoEventAPCost',id,0);set('ProtoEventGrade',id,1);
        set('ProtoEventStory',id,marked(w.world.intro,'story')); set('ProtoEventIntro',id,marked(w.world.intro,'intro'));eventImage(id,w.world.entryIcon || w.world.icon || 'ReplaceableTextures\\CommandButtons\\BTNManual.blp');
      }
    }
    for (const c of w.cards) {
      const id=cards.get(c.key);
      if (c.endingCard) {set('ProtoCardEnding',id,1);set('ProtoCardDescription',id,marked(c.canonFact,'story'));}
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
      set('ProtoEventStory',id,marked(e.story,'story'));set('ProtoEventIntro',id,marked(e.intro,'intro'));eventImage(id,e.icon || w.world.entryIcon || w.world.icon || 'ReplaceableTextures\\CommandButtons\\BTNTome.blp');
      set('ProtoEventRequired',id,e.previous ? events.get(e.previous) : 0);set('ProtoEventRequiredChoice',id,e.previousChoice || 0);set('ProtoEventRequiredCard',id,e.requiredCard ? cards.get(e.requiredCard):0);set('ProtoEventFailure',id,marked(e.failure || '','result'));
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
      // 런타임은 숫자 ID 오름차순으로 대표 캐릭터를 정하므로 원고 순서에 의존하지 않는다.
      const character=Math.min(...w.cards.filter(c=>c.name===target.name).map(c=>cards.get(c.key)));
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
  const previous=readRegistry(), registry=allocateIds(worlds,previous);
  const text=generate(worlds,{registry}), file=path.join(root,'Data/Data_PrototypeCatalog.j');
  if (process.argv.includes('--check')) {
    if (JSON.stringify(previous)!==JSON.stringify(registry)) throw Error('새 콘텐츠의 ID를 먼저 생성·등록해야 합니다.');
    if (fs.readFileSync(file,'utf8').replace(/\r\n/g,'\n')!==text) throw Error('검토 JSON과 생성 JASS가 일치하지 않습니다.');
  } else {
    fs.writeFileSync(registryPath,JSON.stringify(registry,null,2)+'\n');
    fs.writeFileSync(file,text);
  }
  console.log(JSON.stringify({worlds:worlds.filter(w=>w.world.key!=='common').length,cards:worlds.reduce((n,w)=>n+w.cards.length,0),events:worlds.reduce((n,w)=>n+w.events.length,0)}));
}
module.exports={generate,allocateIds,highlight,highlightConfig};
if (require.main===module) {try {run();} catch(e) {console.error(e.message);process.exitCode=1;}}
