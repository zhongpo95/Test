// 흥신소 초안의 성장 주체·확률 성공·비방향 조건·누락 부담을 고치고 인물 반응을 살린다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..'),read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const fixed=read('requests/abydos-expansion-fixed-69.json'),draft=read('drafts/abydos-expansion-text-69.json').parsed,current=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/03-abydos.json'),'utf8'));
assert.deepEqual(draft.events.map(e=>e.key),fixed.events.map(e=>e.key));
const events=fixed.events.map((p,i)=>{assert.equal(draft.events[i].choices.length,p.choices.length);return {key:p.key,title:p.title,story:draft.events[i].story,intro:draft.events[i].intro,previous:p.previous||null,previousChoice:p.previousChoice||0,requiredCard:null,choices:p.choices.map((b,j)=>({label:draft.events[i].choices[j].label,result:draft.events[i].choices[j].result,card:b.card,card2:b.card2,cost:b.cost,gold:b.gold,level:b.level,density:b.density,potions:b.potions,chance:b.chance})),failure:p.failure||null,canonFact:p.canonFact,uncertain:[]};});
const changes=[],edit=(o,k,v,key,reason)=>{if(o[k]===v)return;changes.push({key,field:k,before:o[k],after:v,reason});o[k]=v;};
const stories=[
 '아루가 라멘 계산서를 집어 들며 오늘은 자신이 계산하겠다고 한다. 세리카가 기다리는 동안 아루의 손가락은 계산서 끝에 멈추고 무츠키는 사장님의 멋진 모습을 더 보고 싶다며 웃는다. 계산서를 덮으려는 아루 앞에서 세리카는 마감에 쓸 빈 그릇을 모은다.',
 '카요코가 찾는CD를 물으려는데 가게 주인은 그녀가 말하기 전에 먼저 사과한다. 카요코가 잠깐 입을 다물자 주인은 사과를 하나 더 붙이고 그 틈에 주문할 말은 더 멀어진다. 카요코는 사과를 요구한 적 없다는 말까지 꺼내려다 찾던CD쪽을 다시 가리킨다.',
 '네가 화분에서 자란 것을 잡초라고 부르며 손을 뻗자 하루카가 화분 가장자리를 붙든다. 잡초를 기르는 중이었다는 말을 듣고 보니 치우겠다는 네 말이 먼저였다. 하루카는 네 손이 물러난 뒤에도 화분을 놓지 않은 채 어디에 두려던 것인지 묻는다.',
 '무츠키가 같은 봉투 두 개를 놓고 한쪽에는 장난의 답이 들어 있다고 한다. 아루가 답을 아느냐고 묻자 무츠키는 아는 사람이 웃는 거라며 이번에는 너를 본다. 네가 봉투를 뒤집어 보려 하자 무츠키는 값을 걸고 열거나 답을 듣는 대가를 내라고 한다.',
 '계산을 도왔던 너에게 아루가 이번에는 흥신소의 이름부터 꺼낸다. 무츠키가 이름 뒤에 할 일은 무엇이냐고 묻자 아루는 맡길 일보다 멋진 소개를 먼저 고친다. 옆에서 마감 그릇을 옮기는 세리카는 아루가 소개하는 동안에도 자기 일을 끝내 간다.',
 '카요코와 한 곡을 끝까지 들었던 너에게 가게 주인이 이번에는 찾는 것이 무엇이었냐고 묻는다. 네가 먼저 답하려 하자 카요코가 아까 끝내지 못한 말을 이어 간다. 주인은 이번에는 사과 대신CD진열 쪽을 보며 카요코의 다음 말을 기다린다.'
];
const intros=['계산서 끝을 넘기면 사장님 체면도 넘어갈까?','사과를 듣고 싶은 사람이 아무도 없는데 말은 끊겼다.','치우려던 것이 누군가에게는 기르는 것이었다.','답을 아는 사람만 먼저 웃고 있다.','이름을 들었지만 아직 할 일은 못 들었다.','이번에는 누구의 말이 먼저였을까?'];
const results=[
 ['부족한 계산에180골드를 보태고 아루의 큰소리를 끝까지 들었다. 네가 기억한 악당의 품격으로 보스에게 가하는 피해가18%늘고 일반 몬스터에게 가하는 피해는6%줄었다. 아루는 계산서가 닫힌 뒤에야 원래 그렇게 하려 했다며 목소리를 다시 높인다.',
  '개인 사냥의 적 수 단계를1올리는 부담을 맡고 큰 상대를 겨눈 아루의 말을 기억했다. 보스에게 가하는 피해가18%늘고 일반 몬스터에게 가하는 피해는6%줄었다. 무츠키는 큰소리를 함께 내는 사람은 늘었는데 계산서는 아직 여기 있다고 아루를 본다.',
  '세리카와 네 몫의 그릇을 모으며 자기 일을 마쳤다. 세리카의 박자를 기억해 이후 처치당 추가골드2와 일반 몬스터에게 가하는 피해8%가 늘었다. 세리카는 그릇을 내려놓고 아루에게 계산은 어떻게 할 것인지 다시 묻는다.',
  '네가 맡은 마감의 짧은 일을 끝내고 보수100골드를 받았다. 네 보수와 아루의 계산서는 별개여서 세리카의 손에 남은 계산서가 아루 앞에 다시 놓인다.'],
 ['네가 고른CD값200골드를 내고 카요코의 말을 끝까지 들었다. 그 기억으로 차지 준비 속도9%와 받는 피해 감소3%를 얻었다. 주인이 또 사과하려 하자 카요코는 이번에는 찾는 물건 이름부터 말한다.',
  '개인 사냥의 강함 단계를1올리는 부담을 맡고 카요코와 한 곡을 끝까지 들었다. 차지 준비 속도9%와 받는 피해 감소3%가 늘었다. 카요코는 곡이 끝난 뒤에도 주문할 말을 남겨 두고 진열을 다시 본다.',
  '네 주문만 마치고 귀환 준비에서120골드와물약1개를 챙겼다. 카요코는 네가 말을 끝낸 틈에 자기 주문을 다시 꺼내고 주인은 이번에는 사과를 붙이지 않는다.'],
 ['받침값160골드를 내고 먼저 뻗었던 손을 거둔 뒤 화분을 놓을 자리를 만들었다. 하루카의 남겨 둔 것을 기억해 최대 체력8%와초당 최대체력0.5%재생이 늘었다. 하루카는 그 자리에 둔 화분을 보고도 네가 잡초라고 부르던 말을 한 번 되묻는다.',
  '개인 사냥의 적 수 단계를1올리는 부담을 맡고 하루카와 화분을 둘 자리를 살폈다. 최대 체력8%와초당 최대체력0.5%재생이 늘었다. 하루카는 화분을 아직 놓지 않고 네가 다시 손을 뻗을 쪽을 먼저 본다.',
  '손을 거두고 개인 사냥의 적 수 단계를1낮춘 뒤 물약2개를 챙겼다. 화분은 남았고 하루카는 네가 치우려던 빈자리에 무엇을 둘 생각이었는지 다시 묻는다.'],
 ['내기값100골드를 먼저 내고 답이 든 봉투를 골랐다. 무츠키의 빈틈을 기다리는 기억으로 치명타 피해20%와헤드·백이 없는 비방향 공격 대미지10%가 늘었다. 무츠키는 네가 웃는 것을 보더니 아직 닫힌 봉투를 아루 앞으로 민다.',
  '대가240골드를 내고 두 봉투의 답을 모두 들었다. 치명타 피해20%와헤드·백이 없는 비방향 공격 대미지10%가 늘었다. 무츠키는 봉투를 고르지 않은 네 손을 보고 다음에는 대가도 바꿔 봐야겠다고 웃는다.',
  '봉투는 열지 않고 네 작은 일을 끝낸 보수100골드와물약1개를 받았다. 무츠키는 닫힌 봉투를 거두지 않고 아루에게는 하나쯤 골라도 되지 않겠느냐고 묻는다.'],
 ['준비값150골드를 먼저 내고 이름보다 맡을 일을 물어 분명히 들었다. 아루의 말에서 할 일을 가르는 기억으로 치명타 확률5%p와체력65%이상에서 가하는 피해8%가 늘었다. 아루가 소개를 다시 꺼내려 하자 무츠키는 이번에는 할 일부터였다고 짚는다.',
  '준비값220골드를 내고 소개가 길어지기 전에 할 일부터 다시 확인했다. 치명타 확률5%p와체력65%이상에서 가하는 피해8%가 늘었다. 아루는 소개에 쓰려던 이름을 잠깐 접어 두고 질문부터 받는다.',
  '개인 사냥의 강함 단계를1올리는 부담을 맡고 소개 옆에서도 일을 마치는 세리카의 박자를 기억했다. 체력65%이상에서 가하는 피해12%와이후 처치당 추가골드1이 늘었다. 세리카는 빈 그릇을 내려놓으며 아루의 소개는 아직 계속되는지 묻는다.',
  '소개를 끝까지 듣고 네 짧은 일에서100골드와물약2개를 챙겼다. 네가 떠나려 하자 아루는 소개 뒤에 할 말도 있었다며 아직 접지 않은 이름을 든다.'],
 ['네가 살 것의 값180골드를 내고 카요코의 대답을 기다렸다. 말을 기다린 기억으로 일반 행동속도5%와방어관통4%가 늘었다. 카요코가 주문을 마친 뒤에야 주인은 네가 고른 것도 함께 묻는다.',
  '개인 사냥의 적 수 단계를1올리는 부담을 맡고 말과 말 사이의 박자를 기억했다. 일반 행동속도5%와방어관통4%가 늘었다. 카요코는 이번에는 말을 다 마친 뒤 네가 무엇을 고를 것인지 본다.',
  '대답을 끊지 않고 개인 사냥의 적 수 단계를1낮춘 뒤90골드와물약1개를 챙겼다. 카요코의 주문은 끝났지만 주인은 네가 고른 것을 아직 듣지 못해 너에게 진열을 다시 가리킨다.']
];
events.forEach((e,i)=>{edit(e,'story',stories[i],e.key,'메타 고민과 겁먹음/의존만 반복하는 인물 묘사를 현장 말과 물건으로 바꾸고 실제 보상 인물을 장면에 둔다.');edit(e,'intro',intros[i],e.key,'최선/현명한 선택을 정해 주는 설명 대신 남은 문제를 짧게 쓴다.');e.choices.forEach((c,j)=>edit(c,'result',results[i][j],e.key+'#'+(j+1),'성장 주체를 여행자로 되돌리고 실패인데 성장한 모순·비방향을 일반공격으로 바꾼 오류·적 수 감소 누락·갑작스러운 물건/칭찬을 고친다.'));});
const candidate={...current,sources:[...new Set([...current.sources,...fixed.sourceFacts.map(s=>s.source)])],cards:[...current.cards,...fixed.cards],events:[...current.events,...events]};
candidate.canonBoundary+=' 흥신소68의계산서·카요코CD주문·하루카잡초·무츠키봉투내기는공식역할에서만든별도창작방문이다. 아루후속은자기계산도움성공1번,카요코후속은자기한곡듣기성공2번에서만열린다. 학교빚·은행범죄·가게폭파·인물의큰갈등을해결하거나실제음악/폭발/식물성장기능을지급하지않는다.';
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
write('revisions/abydos-expansion-curated-70.json',candidate);write('revisions/abydos-expansion-curation-70.json',{sourceRevision:'8fe7f71',raw:'drafts/abydos-expansion-text-69.json',changes,numericExceptions:[],rewardReferenceCorrections:[],check});
const refs=[...new Set(events.flatMap(e=>e.choices.map(c=>c.card)).filter(Boolean))],cards=refs.map(key=>candidate.cards.find(c=>c.key===key));
write('requests/abydos-expansion-review-70.json',{review:true,schema:read('requests/fuyuki-expansion-review-64.json').schema,system:'한국어 독립 검토자다. 각사건의story/result를해당card/cost/gold/potions/level/density/chance와직접대조한다. 실제불일치만issues에적고PASS/REVISE를판단한다. 자연스러운한국어와영어key의단순차이를오류로분류하지않으며새기능·수치·밸런스를추가하지않는다.',brief:{sourceFacts:fixed.sourceFacts,cards,events,mechanics:{cost:'사건진입AP1,cost골드선지불후chance%성공. 실패에도비용/AP/필드유지,성공보상없음.',field:'level/density는지속변화량,강함/적수이며음수감소가능. 최저1강함최대5수최대10,사건중사냥정지.',reward:'성공일때만지정카드/gold/potions,중복카드는100골드. 성장주체는여행자이고NPC피해량을바꾸지않음.',history:'아루후속은자기계산도움성공1번. 카요코후속은자기한곡듣기성공2번. 다른플레이어기록으로열리지않음.',normal:'normal_damage_percent는일반몬스터에게가하는피해. 음수는가하는피해감소이며받는피해증가가아님.',health:'max_health_percent는현재/최대비율보존. regeneration은초당최대체력%재생. 즉시회복없고흡수/재생합산10%초.',conditional:'healthy_damage는현재체력65%이상때가하는피해. nondirectional_damage는head=false,back=false인공격에만적용하고기본공격만이아님.',charge:'charge_speed는차지준비속도,action_speed는일반행동속도. 서로다름.',crit:'crit_chance는확률%p,crit_damage는치명피해보너스%.',gold:'kill_gold는이후처치마다보너스,currentgold즉시지급과다름.'},checks:['원작인물역할/소속/성격을틀리게바꾸거나학교빚/원작폭파/구출을완료시키는가?','그사건에서만난보상인물이장면에있는가?','NPC가성장하거나실제폭발/CD버프/공포/식물기능/새AP/시간을약속하는가?','선지불/확률/보급/일반피해손해/필드/자기후속이데이터와다른가?','범용효율메뉴보다계산서/주문/화분/봉투에서인물반응과남은문제를보여주는가?']}});
console.log(JSON.stringify({newCards:6,newRoots:4,newFollowups:2,changes:changes.length,check}));
