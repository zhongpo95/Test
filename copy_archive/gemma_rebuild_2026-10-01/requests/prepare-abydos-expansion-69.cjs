// 흥신소 피칭에서 구체적인 네 발단과 자기 선택 뒤의 두 후속을 성장안에 연결한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const pitches=read('drafts/abydos-pitches-68.json').parsed.pitches;assert.equal(pitches.length,6);
const reasons=[
 '아루와 무츠키의 계산서 발단은 남긴다. 포즈와 조롱만 선택해 보상받는 메뉴를 버리고 자기 식사값을 먼저 내거나 부족한 계산을 돕거나 아루의 말만 믿는 서로 다른 행동을 만든다.',
 '카요코의 주문 오해는 남긴다. 카드 보상에 아무 차이가 없는 중재3개를 버리고 주문 내용·CD를 같이 듣는 박자·자기 주문만 마치는 일을 나눈다. 카요코를 여행자 뒤에서 눈치를 보는 의존적 인물로 단정하지 않는다.',
 '하루카의 잡초는 남긴다. 자존감이 낮은 듯이라는 작가 해설을 제거하고 빼려는 자기 손과 하루카가 붙드는 화분을 쓴다. 식물 종류와 트라우마 회복을 확정하지 않는다.',
 '무츠키의 내기는 발단만 남긴다. 사소한 내용이라는 빈칸을 실제 봉투 두 개와 내기값·확실한 대가로 구체화한다. 내용 공개로 얻는 기억이며 폭탄/폭발 기능이나 사냥 중 처치가 아니다.',
 '이번 확장에서는 폐기한다. 검문받고 설명한다는 범용 상황이며 히나 고유의 빠른 판단이 결정에 주는 차이도 없다. 추가 비용을 뇌물로 만들 위험이 있고 풍기위원회 인도 장면을 축소해 반복할 필요가 없다.',
 '이번 확장에서는 폐기한다. 기존 페로로 앞 부탁과 중복되고 히후미가 여행자에게 계획 우선순위 전부를 정해 달라고 의존하는 내용이다. 동시에 해결한다는 선택도 남은 갈등을 없앤다.'
];
write('revisions/abydos-pitches-selection-68.json',{raw:'drafts/abydos-pitches-68.json',requestCount:6,schemaCount:6,items:pitches.map((p,i)=>({...p,decision:i<4?'발단만 남겨 행동과 작은 반응을 다시 작성':'폐기',reason:reasons[i],revisit:i<4?'구체적인 물건과 서로 다른 성장 목적을 유지하는 별도 방문이면 재검토한다.':'기존 사건과 다른 히나/히후미 고유의 문제와 여행자의 자기 행동을 만들 수 있을 때 재검토한다.'}))});
const f=(stat,value)=>({stat,value}),none={kind:0,goal:0,effects:[]};
const card=(key,name,effectName,keyword,effects,canonFact,evolution=none)=>({key,name,effectName,keyword,grade:2,effects,evolution,canonFact,uncertain:[]});
const cards=[
 card('ab68_aru_bill','리쿠하치마 아루','악당의 품격','보스 피해 · 일반 피해 손해',[f('boss_damage_percent',18),f('normal_damage_percent',-6)],'허세를 믿고 큰 상대만 바라보는 기억을 보스에게 가하는 피해 증가와 일반 몬스터에게 가하는 피해 감소로 각색한다. 원작 사격·대출·학교 빚 해소·실제 불법사업 기능은 없다.'),
 card('ab68_kayoko_disc','오니카타 카요코','침묵에도 내용이 있다','차지 속도 · 피해 감소',[f('charge_speed',9),f('damage_reduction',3)],'음악CD수집과 침묵의 오해를 끝까지 듣는 기억으로 각색한다. 차지 준비 속도이며 모든 행동속도·실제 음악버프·공포 상태·적 제압이 아니다.'),
 card('ab68_haruka_pot','이구사 하루카','뽑지 않고 남긴 것','최대 체력 · 재생',[f('max_health_percent',8),f('regeneration',0.5)],'잡초를 기르는 취미에서 남길 자리를 묻는 기억이다. 최대체력은 현재/최대 비율을 유지하고 재생은 시간에 따른 회복이며 화분장비·즉시치유·원작 상처 해결을 주지 않는다.'),
 card('ab68_mutsuki_envelope','아사기 무츠키','열어 보기 전의 웃음','치명타 피해 · 비방향',[f('crit_damage',20),f('nondirectional_damage',10)],'말썽을 즐기는 성격에서 창작 봉투 내기를 만들고 빈틈을 기다리는 성장으로 각색한다. 치명타 확률이 아니라 치명타 피해이며 비방향은 헤드/백 플래그가 없는 공격에만 적용한다. 실제 폭탄·지뢰·폭발·확률 상승은 없다.',{kind:2,goal:8000,effects:[f('normal_damage_percent',5)]}),
 card('ab68_aru_task','리쿠하치마 아루','직함 대신 할 일','치명타 확률 · 고체력',[f('crit_chance',5),f('healthy_damage',8)],'계산을 도왔던 자기 후속에서 말보다 맡을 일을 확인하는 기억이다. 치명확률5%p와 현재체력이 최대의65%이상일 때 가하는 피해8%다. 실제 계약·회사업무·원작 사업 성공은 없다.'),
 card('ab68_kayoko_reply','오니카타 카요코','말을 기다린 박자','행동 속도 · 방어 관통',[f('action_speed',5),f('penetration',4)],'CD를 함께 들었던 자기 후속에서 끊지 않고 대답을 기다리는 기억이다. 일반 행동속도와 방어 관통으로 각색하며 새 음악스킬·침묵해제·공포면역·NPC동행을 주지 않는다.')
];
const b=(action,card=null,cost=0,level=0,density=0,gold=0,potions=0,chance=100)=>({action,card,card2:null,cost,level,density,gold,potions,chance});
const events=[
 {key:'ab68_big_bill',title:'악당답게 계산할게',scene:'아루가 라멘 계산서를 집어 들며 오늘은 자신이 계산하겠다고 한다. 세리카가 기다리는 동안 아루의 손가락은 계산서 끝에 멈추고 무츠키는 사장님의 멋진 모습을 더 보고 싶다며 웃는다. 네 식사값을 먼저 낼지 부족한 몫도 도울지 아루의 큰소리만 믿고 나설지 고른다.',choices:[b('180골드로 부족한 계산을 돕고 아루의 큰소리도 끝까지 듣는다','ab68_aru_bill',180),b('내 사냥의 적 수 단계를1올리고 아루의 큰 상대를 겨눈 말을 기억한다','ab68_aru_bill',0,0,1),b('내 몫의 정리만 마치고 세리카의 일하는 박자를 기억한다','abydos_serika'),b('오늘의 짧은 일을 마치고 내 보수만 챙긴다',null,0,0,0,100)],canonFact:'공식3화의 라멘 만남과 아루 허세·무츠키 관계를 별도 계산 사건으로 각색했다. 원작 계산서 액수·가게 공격·학교 빚·사업 성공을 확정하지 않는다.'},
 {key:'ab68_disc_before_words',title:'아직 주문하지 않았는데',scene:'카요코가 찾는CD를 물으려는데 가게 주인은 그녀가 말하기 전에 먼저 사과한다. 카요코가 잠깐 입을 다물자 주인은 사과를 하나 더 붙이고 그 틈에 주문할 말은 더 멀어진다. 너는 자기 말로 찾는 물건을 묻거나 곁에서 한 곡을 듣거나 자기 주문만 끝낸다.',choices:[b('200골드로 내가 고른CD값을 내고 카요코의 말이 끝날 때까지 듣는다','ab68_kayoko_disc',200),b('내 사냥의 강함 단계를1올리고 카요코와 한 곡의 박자를 끝까지 듣는다','ab68_kayoko_disc',0,1),b('내 주문만 마치고 귀환 보급을 챙긴다',null,0,0,0,120,1)],canonFact:'공식 음악CD수집과 얼굴/침묵 때문에 생기는 오해를 창작 방문으로 만들었다. 곡·장르·CD원작명·실제 가게·실제 음악효과를 확정하지 않는다.'},
 {key:'ab68_weed_hand',title:'잡초라는 말 다음',scene:'네가 화분에서 자란 것을 잡초라고 부르며 손을 뻗자 하루카가 화분 가장자리를 붙든다. 잡초를 기르는 중이었다는 말을 듣고 보니 치우겠다는 네 말이 먼저였다. 하루카는 네 손이 물러난 뒤에도 화분을 놓지 않은 채 어디에 두려던 것인지 묻는다.',choices:[b('160골드로 화분을 둘 받침을 마련하고 먼저 뻗은 손을 거둔다','ab68_haruka_pot',160),b('내 사냥의 적 수 단계를1올리고 남겨 둘 자리를 함께 살핀다','ab68_haruka_pot',0,0,1),b('손을 거두고 내 사냥의 적 수 단계를1낮춘 뒤 보급을 챙긴다',null,0,0,-1,0,2)],canonFact:'공식 잡초기르기 취미에서 여행자가 먼저 치우려 한 작은 오해를 창작했다. 특정 식물·실제 성장/수확·치유·왕따 해결·원작 라멘 폭파를 보상으로 바꾸지 않는다.'},
 {key:'ab68_two_envelopes',title:'웃는 쪽은 두 봉투',scene:'무츠키가 같은 봉투 두 개를 놓고 한쪽에는 장난의 답이 들어 있다고 한다. 아루가 답을 아느냐고 묻자 무츠키는 아는 사람이 웃는 거라며 이번에는 너를 본다. 값을 걸고 하나를 열지 답을 바로 듣는 대가를 낼지 봉투를 남기고 떠날지 정한다.',choices:[b('100골드를 먼저 걸고 봉투 하나를 연다','ab68_mutsuki_envelope',100,0,0,0,0,60),b('240골드로 내기 대신 두 봉투의 답을 바로 듣는다','ab68_mutsuki_envelope',240),b('봉투는 열지 않고 내 작은 일을 마친 보수만 받는다',null,0,0,0,100,1)],failure:'내기값100골드를 먼저 냈지만 고른 봉투에는 답 대신 빈 종이가 있었다. 카드는 얻지 못하고100골드는 돌아오지 않는다. 무츠키는 네 손에 남은 종이와 아직 닫힌 봉투를 번갈아 본다.',canonFact:'무츠키의 장난과 아루 허세를 창작 봉투내기로 각색했다. 원작에 이 내기가 있다고 주장하지 않고 폭탄/폭발·사냥 중 추가 처치·새 미니게임·숨은 확률 기능을 만들지 않는다.'},
 {key:'ab68_name_after_bill',title:'사장님 다음에는',previous:'ab68_big_bill',previousChoice:1,scene:'계산을 도왔던 너에게 아루가 이번에는 흥신소의 이름부터 꺼낸다. 무츠키가 이름 뒤에 할 일은 무엇이냐고 묻자 아루는 맡길 일보다 멋진 소개를 먼저 고친다. 너는 또 큰소리에 맞장구칠지 자기 몫을 먼저 물을지 오늘 대화를 마칠지 정한다.',choices:[b('150골드로 내 의뢰 준비값을 내고 이름보다 맡을 일을 먼저 묻는다','ab68_aru_task',150,0,0,0,0,75),b('220골드로 내 준비를 충분히 하고 할 일부터 다시 확인한다','ab68_aru_task',220),b('내 사냥의 강함 단계를1올리고 세리카의 일을 끝내는 박자를 기억한다','abydos_serika_return'),b('소개만 듣고 내 짧은 일의 보수와 보급을 챙긴다',null,0,0,0,100,2)],failure:'준비값150골드를 먼저 냈지만 소개가 이어져 맡을 일을 분명히 듣지 못했다. 카드는 얻지 못하고150골드는 돌아오지 않는다. 무츠키는 끝나지 않은 소개를 아루에게 한 번 더 짚는다.',canonFact:'자기 계산 도움 성공1번 뒤에만 열리는 창작 소개후속이다. 회사 계약·은행 범죄·원작 습격 승패·실제NPC작업은 없다.'},
 {key:'ab68_reply_after_disc',title:'사과가 끝난 뒤의 한마디',previous:'ab68_disc_before_words',previousChoice:2,scene:'카요코와 한 곡을 끝까지 들었던 너에게 가게 주인이 이번에는 찾는 것이 무엇이었냐고 묻는다. 네가 먼저 답하려 하자 카요코가 아까 끝내지 못한 말을 이어 간다. 주인의 사과가 멈춘 자리에 네 대답까지 채울지 잠깐 기다릴지 정한다.',choices:[b('180골드로 내가 살 것을 따로 정하고 카요코의 대답을 기다린다','ab68_kayoko_reply',180),b('내 사냥의 적 수 단계를1올리고 말과 말 사이의 박자를 기억한다','ab68_kayoko_reply',0,0,1),b('대답을 끊지 않고 내 귀환 준비만 챙긴다',null,0,0,-1,90,1)],canonFact:'자기CD만남 성공2번 뒤에만 열리는 창작 후속이다. 인물의 모든 오해가 없어졌다고 결론내리지 않고 새 음악·동행·가게 할인 기능을 지급하지 않는다.'}
];
// 후속의 세 번째 선택에도 설명한 강함 부담을 실제 변화량으로 연결한다.
events[4].choices[2].level=1;
const learning={ab68_aru_bill:'보스에게 가하는 피해18%증가,일반몬스터에게 가하는 피해6%감소',abydos_serika:'이후 몬스터 처치당 추가골드2,일반몬스터에게 가하는 피해8%',ab68_kayoko_disc:'차지 준비 속도9%,받는 피해감소3%',ab68_haruka_pot:'최대체력8%,초당 최대체력0.5%재생,현재/최대비율보존',ab68_mutsuki_envelope:'치명타 피해20%,헤드/백플래그없는 공격 대미지10%',ab68_aru_task:'치명타확률5%p,현재체력65%이상에서 가하는 피해8%',abydos_serika_return:'현재체력65%이상에서 가하는 피해12%,이후처치당 추가골드1',ab68_kayoko_reply:'일반 행동속도5%,방어관통4%'};
const expected=c=>({paidGold:c.cost,rememberedCard:c.card,remembered:c.card?learning[c.card]:null,receivedGold:c.gold,receivedPotions:c.potions,personalEnemyStrengthChange:c.level,personalEnemyCountChange:c.density});
const schema=read('requests/academy-expansion-text-58.json').schema;schema.properties.events.minItems=schema.properties.events.maxItems=events.length;
const sourceFacts=read('requests/abydos-pitches-68.json').brief.sourceFacts;
write('requests/abydos-expansion-fixed-69.json',{sourceRevision:'8fe7f71',cards,events,sourceFacts});
write('requests/abydos-expansion-text-69.json',{review:false,schema,system:'한국어 사건 작가다. 주어진6개key와순서를 지킨다. story는구체적인 현장과 인물의 반응3문장,intro는남은문제1문장,result는내행동·실제대가/기억/보급·인물의작은다른반응을2~3문장으로쓴다. 서류정리·내준비를마련했다만반복하지않는다. 원작을아는독자가 인물을 떠올릴 수 있게 쓴다.',brief:{sourceFacts,events:events.map(e=>({key:e.key,scene:e.scene,previous:e.previous||null,previousChoice:e.previousChoice||0,choices:e.choices.map(c=>({action:c.action,chance:c.chance,expectedSuccess:expected(c)}))})),rules:[
 '인물의 자칭사장/과장/사원/게헨나소속과 성격을 유지한다. 만난 인물 카드 외 다른작품 보상을 섞지않는다. 원작 큰 결말·실제 공격/은행범죄·학교빚·구출을 대신 끝내지않는다.',
 '카드는 성장 기억이고 새 장비·CD재생버프·공포·폭발·화분성장·NPC사냥/동행·체력지불·시간/AP추가는 없다. 사건중 개인사냥정지,level/density는재개후 개인필드 지속 변화량이며 음수감소도가능하다.',
 '골드/물약은 실제수치대로 쓴다. 처치당 추가골드는지금 받는골드가아니다. 최대체력은현재비율보존,재생은시간회복이고합산흡수/재생상한10%초다. crit_chance는확률%p,crit_damage는치명피해%.',
 '차지준비속도와 일반행동속도는다르다. healthy_damage는체력65%이상때 가하는피해. nondirectional_damage는헤드/백플래그없는공격 대미지. normal_damage_percent 음수는일반몬스터에게가하는피해손해이며 받는피해증가가아니다.',
 '60/75% result는성공때만. 실패에도AP/선지불골드/필드부담유지,실패카드없다. 부모획득카드를후속의기본보상으로반복하지않는다. 낯선원작능력·자동승리·칭찬만남는마무리는쓰지않는다.'
]}});console.log(JSON.stringify({cards:6,roots:4,followups:2,discardedPitches:2}));
