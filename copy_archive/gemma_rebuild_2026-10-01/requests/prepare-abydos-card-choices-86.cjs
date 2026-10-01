// 아비도스의 일당 대안과 같은 기억 반복을 세 지정 카드 행동으로 나누고 Gemma 집필을 준비한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const file=path.join(repo,'content/roguelite/03-abydos.json'),bytes=fs.readFileSync(file),before=JSON.parse(bytes);
fs.writeFileSync(path.join(root,'before-abydos-card-choices-86.json'),bytes,{flag:'wx'});
const card=(key,name,effectName,keyword,pairs,canonFact)=>({key,name,effectName,keyword,grade:2,effects:pairs.map(([stat,value])=>({stat,value})),evolution:{kind:0,goal:0,effects:[]},canonFact,uncertain:[]});
const addedCards=[
 card('abydos_serika_order','쿠로미 세리카','먼저 받은 주문','행동 속도 · 일반 적',[['action_speed',4],['normal_damage_percent',12]],'공식 회계·아르바이트 역할과 기존 주문 정리에서 차례를 맞추는 여행자의 기억이다. 가게 소유·무료 물약 제작·학교 빚 해소·원작 사격 기술은 없다.'),
 card('abydos_serika_finish','쿠로미 세리카','다음 교대에 남길 것','공격력 · 재생',[['attack_percent',10],['regeneration',0.3]],'아르바이트를 하면서 학교 일을 이어 가는 공식 성향에서 재료와 다음 몫을 남기는 기억을 각색한다. 근무 자동보수·현재체력 즉시회복·NPC 파견·본편 복구 완수는 없다.'),
 card('abydos_ayane_route','오쿠소라 아야네','전달할 곳부터','이동 · 최대 체력',[['move_speed',3],['max_health_percent',8]],'공식 서기·지원 역할과 기존 보급 운반에서 전달할 곳과 돌아올 자리를 먼저 확인하는 기억이다. 새 통신 기술·실제 보급차량·NPC 운반·귀환 스킬은 없다.'),
 card('abydos_ayane_blank','오쿠소라 아야네','지우지 않은 빈칸','치명 피해 · 받는 피해',[['crit_damage',12],['damage_reduction',4]],'공식 기록·규칙 중시와 가계부·골동품 취미에서 확인하지 않은 기록을 단정하지 않는 기억이다. 자동 감정·골동품 소유·학교 빚 해소·원작 관통 기술은 없다.'),
 card('ab68_mutsuki_watch','아사기 무츠키','말이 끝나기 전에','치명 피해 · 보스',[['crit_damage',12],['boss_damage_percent',8]],'공식 장난스러운 성격과 기존 아루의 허세를 지켜보는 관계에서 다음 말을 기다리는 기억을 각색한다. 웃음 게이지·폭탄·심리 피해·원작 사건 승리를 지급하지 않는다.'),
 card('ab68_kayoko_interval','오니카타 카요코','아직 끝나지 않은 곡','치명 확률 · 비방향',[['crit_chance',4],['nondirectional_damage',14]],'공식 음악CD수집과 침묵의 오해에서 한 곡을 끊지 않고 듣는 여행자의 기억이다. 실제 음악 버프·새 곡·주문·공포 스킬·NPC 성장은 없다.'),
 card('ab68_kayoko_order','오니카타 카요코','사과 대신 주문','최대 체력 · 행동 속도',[['max_health_percent',8],['action_speed',4]],'공식 침묵 때문에 생기는 오해에서 사과를 반복하기보다 남은 주문의 말을 듣는 기억이다. 모든 오해 해결·침묵 면역·가게 할인·음악 스킬·즉시 회복은 없다.'),
 card('ab68_haruka_ask','이구사 하루카','먼저 묻는 손','일반 적 · 받는 피해',[['normal_damage_percent',14],['damage_reduction',3]],'공식 잡초 기르기 취미와 내성적인 성향에서 치우기 전에 묻는 여행자의 기억을 각색한다. 식물 공격·실제 수확·잡초를 몬스터로 바꾸는 기능·상처 완전 해결은 없다.'),
 card('ab68_haruka_space','이구사 하루카','남겨 둔 작은 자리','최대 체력 · 고체력',[['max_health_percent',10],['healthy_damage',10]],'공식 잡초 기르기에서 화분을 놓을 자리를 남겨 두는 여행자의 기억이다. 보호막 생성·현재체력 즉시회복·수면·식물 성장 기능은 없다. 고체력 조건은65%이상이다.'),
 card('ab68_mutsuki_answer','아사기 무츠키','답을 듣는 대가','행동 속도 · 비방향',[['action_speed',3],['nondirectional_damage',14]],'공식 장난을 즐기는 성향에서 창작 봉투의 답을 듣고 다음 말을 준비하는 기억이다. 치명확률을 늘리는 카드가 아니며 실제 내기 미니게임·폭발·원작 능력 전수는 없다.')
];
const events=structuredClone(before.events),changes=[],removedChoices=[];
function change(key,index,values){const e=events.find(e=>e.key===key),old=structuredClone(e.choices[index-1]);assert(old);e.choices[index-1]={...old,...values,gold:0,result:''};changes.push({key,index,before:old,after:structuredClone(e.choices[index-1])});}
function trim(key){const e=events.find(e=>e.key===key);removedChoices.push({key,index:4,choice:structuredClone(e.choices[3])});e.choices=e.choices.slice(0,3);}
change('abydos_ramen_shift',2,{card:'abydos_serika_order',cost:160,label:'160골드로 기록용품을 마련하고 세리카와 먼저 받은 주문부터 나눈다'});
change('abydos_ramen_shift',3,{card:'abydos_serika_finish',label:'100골드로 재료 운송을 준비하고 세리카와 다음 교대의 몫을 남긴다'});
change('abydos_blackmarket_map',3,{card:'abydos_ayane_route',label:'130골드로 운반을 준비하고 아야네의 기록을 전달할 곳부터 확인한다'});
change('abydos_ramen_repair',3,{card:'abydos_serika_finish',cost:160,label:'160골드로 병문안 짐을 준비하고 세리카와 다음에 쓸 물건을 남긴다'});
change('abydos_desert_watch',3,{card:'abydos_ayane_route',cost:160,label:'160골드로 전달을 준비하고 아야네에게 돌아갈 길부터 나눈다'});
change('abydos_missing_senior',3,{card:'abydos_ayane_route',cost:160,label:'160골드로 귀환 보급을 준비하고 아야네와 돌아올 자리를 남긴다'});
change('abydos_pace',3,{card:'abydos_serika_order',label:'100골드로 보급을 마련하고 세리카와 더 약한 구역의 차례를 맞춘다'});trim('abydos_pace');
change('abydos_sleepchair',3,{card:'abydos_ayane_route',cost:160,label:'160골드로 가방을 준비하고 아야네와 돌아올 통로를 비운다'});
change('abydos_snack_share',3,{card:'abydos_serika_order',cost:160,label:'160골드로 정리를 준비하고 세리카와 간식보다 먼저 온 주문을 나눈다'});
change('abydos_antique_note',1,{});
change('abydos_antique_note',2,{card:'abydos_ayane_blank',label:'220골드로 기록용품을 마련하고 아야네와 아직 확인하지 않은 빈칸을 남긴다'});
change('abydos_antique_note',3,{card:'abydos_ayane_route',cost:160,label:'160골드로 운반을 준비하고 아야네와 확인된 물건을 전할 곳을 나눈다'});
change('abydos_aquarium_step',3,{card:'abydos_ayane_route',cost:160,label:'160골드로 안내를 준비하고 아야네와 돌아올 통로를 비운다'});trim('abydos_peroro_line');
change('ab68_big_bill',2,{card:'ab68_mutsuki_watch',label:'내 사냥의 적 수 단계를1올리고 무츠키와 아루의 다음 말을 기다린다'});trim('ab68_big_bill');
change('ab68_disc_before_words',2,{card:'ab68_kayoko_interval'});
change('ab68_disc_before_words',3,{card:'ab68_kayoko_order',cost:160,label:'160골드로 귀환 보급을 준비하고 카요코의 사과 아닌 주문부터 듣는다'});
change('ab68_weed_hand',2,{card:'ab68_haruka_ask',label:'내 사냥의 적 수 단계를1올리고 하루카에게 손을 뻗기 전에 먼저 묻는다'});
change('ab68_weed_hand',3,{card:'ab68_haruka_space',cost:160,label:'160골드로 보급을 마련하고 하루카의 작은 자리를 남긴 채 적 수를1낮춘다'});
change('ab68_two_envelopes',2,{card:'ab68_mutsuki_answer'});
change('ab68_two_envelopes',3,{card:'ab68_aru_bill',cost:160,label:'160골드로 보급을 마련하고 봉투를 고르기 전에 아루의 큰소리부터 듣는다'});
change('ab68_name_after_bill',2,{card:'ab68_mutsuki_watch',label:'220골드로 내 준비를 하고 무츠키와 아루의 이름 다음 말을 기다린다'});trim('ab68_name_after_bill');
change('ab68_reply_after_disc',2,{card:'ab68_kayoko_order'});
change('ab68_reply_after_disc',3,{card:'ab68_kayoko_disc',cost:180,label:'180골드로 귀환을 준비하고 카요코와 끝난 곡의 박자를 다시 확인한다'});
for(const e of events){assert.equal(e.choices.length,3);assert.equal(new Set(e.choices.map(c=>c.card)).size,3);for(const c of e.choices){assert(c.card);assert.notEqual(c.card,before.world.entryCard);assert.equal(c.gold,0);}}
const fixed={sourceRevision:'92afc1f',beforeFile:'before-abydos-card-choices-86.json',beforeSha256:crypto.createHash('sha256').update(bytes).digest('hex'),world:before.world,cards:[...before.cards,...addedCards],addedCards,events,changes,removedChoices,policy:{choices:'18사건54선택 모두 서로 다른 지정카드3종이다. 기존 세 카드인 보급·페로로 선택은 그대로 유지한다.',gold:'즉시골드13선택을 제거한다. 학교 빚 자체를 갚은 보상이나 은행 돈을 새로 만들지 않는다.',history:'라멘교대1/사막방어1/아루계산1/카요코한곡2의 자기 성공후속을 같은 번호로 유지한다. 카요코부모2는새곡카드이며후속은이를다시주지않는다. aru_task/kayoko_reply후속전용을유지한다.',stats:'기존20카드/머리효과를 유지하며 기존 스탯의 희귀 기억10장을 더한다. 수치와 실전 선택률은 테스트가 필요하다.',candidate:'사건 후보2~4개 유지'},sources:[{url:'https://sh-anime.shochiku.co.jp/bluearchive-anime/character/onikata-kayoko/',confirmed:'음악CD수집과 침묵 때문에 생기는 오해만 확인했다.'},{url:'https://sh-anime.shochiku.co.jp/bluearchive-anime/character/igusa-haruka/',confirmed:'잡초 기르기와 내성적인 성향만 사용한다.'},{url:'https://sh-anime.shochiku.co.jp/bluearchive-anime/character/okusora-ayane/',confirmed:'서기·기계 지식·규칙 중시·가계부·골동품 취미만 사용한다.'},{url:'https://sh-anime.shochiku.co.jp/bluearchive-anime/character/kuromi-serika/',confirmed:'회계·아르바이트·학교를 위한 성향만 사용한다.'}]};
assert.equal(before.events.flatMap(e=>e.choices).filter(c=>c.gold>0).length,13);
write('requests/abydos-card-choices-fixed-86.json',fixed);
const changedEvents=events.filter(e=>changes.some(x=>x.key===e.key)),schema=structuredClone(read('requests/fuyuki-card-choices-text-80-1.json').schema);
for(let start=0,batch=1;start<changedEvents.length;start+=4,batch++){
 const slice=changedEvents.slice(start,start+4),refs=new Set(slice.flatMap(e=>e.choices.map(c=>c.card))),s=structuredClone(schema);
 s.properties.events.minItems=slice.length;s.properties.events.maxItems=slice.length;s.properties.events.items.properties.key.enum=slice.map(e=>e.key);
 write('requests/abydos-card-choices-text-86-'+batch+'.json',{review:false,schema:s,system:'한국어 사건 작가다. events는 입력key마다 별도 객체이며 같은 순서로 한번만 출력한다. choices는 입력index만 쓴다. label그대로, result는 현장행동·지정기억카드와 실제비용/물약/지속필드·인물의 작은 반응을 세 문장으로 쓴다. 다른 사건이나 JSON/메타데이터를 결과문장에 섞지 않는다.',brief:{cards:fixed.cards.filter(c=>refs.has(c.key)),events:slice.map(e=>({key:e.key,story:e.story,canonFact:e.canonFact,choices:e.choices.map((c,j)=>({index:j+1,...c})).filter(c=>changes.some(x=>x.key===e.key&&x.index===c.index))})),mechanics:{reward:'성공때 지정카드1장과 potions개 물약 지급. 즉시골드0. UI가 정확한 이름·효과를 별도 덧붙인다. result는성공만,70/60/75실패는별도있다.',cost:'cost지불이며지급아님. 실패때비용/AP/필드환급없음.물약은그개수받는것이며소비아님.',field:'초기강함1/적수4. level/density는 몬스터강함/적수 단계 변화량. max(1,현재+변화량),상한5/10. 피로/시간/플레이어레벨아님.',stats:'기억은여행자의성장이다. regen초당최대체력%로흡수합산10%상한,즉시회복아님. maxHP현재/최대비율유지. healthy65%이상. 비방향헤드/백플래그없는공격,보호막조건은기존보호막이며새보호막없음.'},boundary:before.canonBoundary,checks:['원래현장만남에서행동과인물반응을이어간다.','추가원작기술·장비·큰빚해소·은행돈·NPC성장·즉시치유·실제CD음악효과·식물기능없음.','칭찬/끄덕임만반복하지않고남은주문·부탁·화분·기록을인물이살핀다.']}});
}
console.log(JSON.stringify({events:18,choices:54,newCards:10,changedChoices:changes.length,changedEvents:changedEvents.length,batches:Math.ceil(changedEvents.length/4),directGoldChoices:0}));
