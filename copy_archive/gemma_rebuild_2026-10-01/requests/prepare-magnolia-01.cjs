// 마그놀리아의 확인한 설정과 분기 손익을 보존하고 Gemma 서사 요청을 만든다.
const fs=require('node:fs'),path=require('node:path');
const base=path.resolve(__dirname,'..');
const effect=(stat,value)=>({stat,value});
const card=(key,name,effectName,grade,effects,canonFact,kind=0,goal=0,extra=[])=>({key,name,effectName,keyword:effects.map(e=>e.stat).join(' · '),grade,effects,evolution:{kind,goal,effects:extra},canonFact,uncertain:[]});
const cards=[
 card('ft_happy','해피','하늘에서 찾은 귀환길',1,[effect('move_speed',3)],'날개 마법으로 비행하는 나츠의 동료이며 생선을 좋아한다. 카드 효과는 정찰한 길을 활용하는 이동 준비다. 실제 비행을 지급하지 않는다.'),
 card('ft_natsu','나츠 드래그닐','화룡의 철권',2,[effect('attack_percent',12),effect('normal_damage_percent',8)],'불의 멸룡마도사인 나츠의 공격적인 전투를 각색했다. 별도 화염 공격·원작 기술은 지급하지 않는다.',2,12000,[effect('boss_damage_percent',8)]),
 card('ft_lucy','루시 하트필리아','의뢰를 잇는 기록',2,[effect('event_choices',1),effect('kill_gold',1)],'성령마도사이며 글을 쓰는 루시의 역할을 의뢰 기록과 수급으로 각색했다. 성령 소환을 지급하지 않는다.'),
 card('ft_gray','그레이 풀버스터','아이스 메이크',2,[effect('charge_damage',18),effect('nondirectional_damage',8)],'얼음을 여러 형태의 무기로 만드는 조형마법을 차지와 비방향 공격으로 각색했다. 차지·비방향 판정이 있는 기존 스킬에 적용된다.',2,12000,[effect('charge_speed',6)]),
 card('ft_erza_blade','엘자 스칼렛','검 하나에 실은 결심',2,[effect('directional_damage',16),effect('crit_chance',4)],'무기와 갑옷을 순간적으로 환장하는 엘자의 전투를 방향 적중 준비로 각색했다. 원작 갑옷 이름이나 신규 무기를 지급하지 않는다.',1,45,[effect('crit_damage',15)]),
 card('ft_erza_guard','엘자 스칼렛','갑옷을 고르는 이유',2,[effect('max_health_percent',10),effect('shielded_damage',16)],'엘자가 여러 갑옷을 준비한다는 설정에서 방어 태세를 각색했다. 카드는 보호막을 생성하지 않으며 기존 보호막 중에만 피해 보너스가 적용된다.'),
 card('ft_wendy','웬디 마벨','하늘의 부가술',2,[effect('regeneration',0.7),effect('attack_percent',6)],'공기를 힘의 근원으로 삼으며 부가마법과 치유를 다루는 웬디의 역할을 재생·공격력으로 표현했다. 흡수·재생 합산 한도를 따른다.'),
 card('ft_charles','샤를','놓치지 않는 징후',2,[effect('healthy_damage',12),effect('damage_reduction',4)],'웬디의 동료이며 때때로 예지 능력을 보이는 샤를을 위험 징후에 주의를 기울이는 준비로 각색했다. 확정 예언·실제 다음 보스 정보 기능은 제공하지 않는다.',3,60,[effect('crit_chance',4)]),
 card('ft_natsu_focus','나츠 드래그닐','동료를 향한 불꽃',3,[effect('attack_percent',10),effect('final_damage_percent',6),effect('action_speed',-4)],'감정이 격해지기 쉽고 동료를 생각하는 나츠의 성격을 일격에 힘을 싣는 성장으로 각색했다. 드래곤 포스나 신규 발동 스킬을 지급하지 않는다.')
];
const b=(label,card=null,o={})=>({label,result:'검토 전 서사',card,card2:null,gold:0,cost:0,level:0,density:0,potions:0,chance:100,...o});
const e=(key,title,situation,choices,previous=null,previousChoice=0,requiredCard=null,failure=null)=>({key,title,story:situation,intro:situation,previous,previousChoice,requiredCard,choices,failure,canonFact:'공식 길드와 인물의 역할을 활용한 원작 외 창작 사건이다.',uncertain:[]});
const events=[
 e('ft_request_board','무너진 게시판 아래','길드를 다시 정리하던 중 의뢰서와 수송 짐이 뒤섞여 있다. 나츠는 짐을 치울 테니 밖의 위험을 맡아 달라고 하고, 루시는 주소를 대조하자고 한다. 해피와 샤를의 수송을 돕거나 먼저 게시판을 다시 세울 수도 있다.',[
  b('나츠와 짐을 옮길 길을 연다','ft_natsu',{level:1}),
  b('루시와 의뢰서 주소를 대조한다','ft_lucy',{cost:160}),
  b('샤를과 수송 동선을 살핀다','ft_charles',{density:1}),
  b('게시판을 먼저 다시 세운다',null,{gold:100,density:-1,potions:2})]),
 e('ft_timber','짐을 기다리는 사람들','나츠와 운반 길을 열고 돌아오니 맡아 둔 목재를 어디에 쓸지 묻는 사람들이 있다. 그레이는 위험한 길목의 방어물을 만들려 하고, 웬디는 운반을 마친 사람들의 회복을 돕고 있다.',[
  b('그레이와 길목의 구조를 정리한다','ft_gray',{density:1}),
  b('웬디와 돌아온 사람들을 돌본다','ft_wendy',{cost:140,potions:1})],'ft_request_board',1),
 e('ft_receipt','주소가 다른 두 장의 의뢰서','루시와 주소를 대조해 놓은 의뢰서 중 같은 물품에 서로 다른 수령인이 적혀 있다. 접수 실수인지 확인하는 동안, 엘자가 필요한 짐을 나눠 들겠다고 한다. 어느 수령인에게 어떤 준비를 보내야 할까?',[
  b('방어가 필요한 수령인부터 맡는다','ft_erza_guard',{cost:160,density:-1}),
  b('위험한 길목의 의뢰를 먼저 맡는다','ft_erza_blade',{level:1}),
  b('루시와 두 수령인에게 확인한다',null,{gold:280,potions:1})],'ft_request_board',2),
 e('ft_fish','생선보다 먼저 챙길 짐','샤를과 수송 동선을 살피다 해피가 가져갈 짐 옆에서 생선 봉지를 발견한다. 해피는 모두 가져가고 싶어 하지만 날개로 운반할 짐은 골라야 한다. 짐을 나누거나 지상 운반을 도와 줄 수 있다.',[
  b('생선과 보급품을 나눠 운반한다','ft_wendy',{cost:160,potions:2}),
  b('내가 위험한 지상 운반을 맡는다','ft_erza_guard',{level:1,gold:100})],'ft_request_board',3),
 e('ft_new_board','다시 걸린 첫 의뢰','다시 세운 게시판에 첫 의뢰가 붙었다. 그레이는 좁은 길의 구조를 확인하는 일, 엘자는 돌아올 사람을 위한 경계를 제안한다. 손이 많이 가는 작업과 위험한 길목 중 어느 쪽을 맡을까?',[
  b('그레이와 좁은 길목을 점검한다','ft_gray',{cost:170}),
  b('엘자와 복귀할 길을 지킨다','ft_erza_blade',{density:2})],'ft_request_board',4),
 e('ft_armory','짐칸에 들어가지 않는 갑옷','엘자는 출발을 준비하다 무기와 갑옷을 하나씩 확인하고 있다. 환장하는 엘자와 달리 내가 챙길 짐에는 한계가 있다. 긴 공세를 위한 준비, 기존 보호막을 활용할 방어 준비, 웬디의 지속 지원 중 무엇을 배울지 고른다.',[
  b('검을 휘두를 간격을 맞춘다','ft_erza_blade',{cost:220}),
  b('방어 태세에 맞춰 짐을 정리한다','ft_erza_guard',{cost:180}),
  b('웬디에게 지속 지원을 부탁한다','ft_wendy',{cost:210})]),
 e('ft_river','불어난 물과 젖은 의뢰서','비로 불어난 물가에서 돌아갈 짐이 멈춰 있다. 그레이는 간단한 구조물을 만들 수 있지만 물살 속에 고정할지는 장담하지 않는다. 힘을 보태 빠른 길을 시도할지, 웬디와 짐을 나눠 안전하게 돌아갈지 고른다.',[
  b('구조물을 고정해 물길을 건넌다','ft_gray',{gold:180,cost:90,density:1,chance:70}),
  b('웬디와 짐을 나눠 우회한다','ft_wendy',{cost:140,density:-1,potions:1})],null,0,null,'고정한 구조물이 물살에 밀려 짐 일부가 젖었다. 비용과 늘어난 적 수는 그대로 남지만, 버린 의뢰서를 다시 확인할 길은 남아 있다.'),
 e('ft_wet_receipt','번진 글씨를 읽는 방법','빠른 물길에서 짐이 젖은 뒤 루시가 번진 글씨를 살피고 있다. 원래 받는 사람을 찾아 남은 짐을 보내거나 웬디와 젖은 물품을 정리할 수 있다. 실수한 일을 같은 판단으로 밀어붙이지는 않아도 된다.',[
  b('루시와 수령인을 다시 찾는다','ft_lucy',{cost:160}),
  b('웬디와 돌아갈 보급을 정리한다','ft_wendy',{density:-1,potions:1})],'ft_river',-1),
 e('ft_controlled_flame','잘못 태우면 안 되는 것','나츠와 공격 준비를 해 본 뒤 운반할 짐 옆에서 다시 힘을 맞춘다. 나츠는 크게 힘을 싣는 쪽을 권하지만, 엘자는 옆의 짐을 가리키며 한 번 더 간격을 확인하라고 한다. 강한 일격과 정확한 간격 중 무엇을 준비할까?',[
  b('나츠와 한 번의 일격에 힘을 싣는다','ft_natsu_focus',{cost:260,level:1}),
  b('엘자와 빗나갈 간격을 줄인다','ft_erza_blade',{cost:200})],null,0,'ft_natsu')
];
const world={world:{key:'magnolia',name:'마그놀리아',work:'페어리 테일',intro:'길드에 다시 모인 사람들이 의뢰서를 정리하고 돌아올 길을 준비하고 있다. 해피가 길드까지 안내한다.',effects:[effect('max_health_percent',3)],entryCard:'ft_happy',icon:'ReplaceableTextures\\CommandButtons\\BTNTome.blp'},sources:[
 'https://fairytail-tv.com/story/list.php',
 'https://www.gamecity.ne.jp/manual/fairytail/jp/4100.html',
 'https://www.fairytail100yq.com/character/nastu-dragneel.html',
 'https://www.fairytail100yq.com/character/lucy-heartfilia.html',
 'https://www.fairytail100yq.com/character/happy.html',
 'https://www.fairytail100yq.com/character/gray-fullbuster.html',
 'https://www.fairytail100yq.com/character/erza-scarlet.html',
 'https://www.fairytail100yq.com/character/wendy-marvell.html',
 'https://www.fairytail100yq.com/character/charles.html'],canonBoundary:'마그놀리아의 길드 재건과 의뢰 게시판, 인물의 능력·역할은 공식 자료를 참고했다. 맵의 짐·주소·물길 사건은 별도 창작이며 원작 특정 회차 전체나 길드 순위 시스템을 재현하지 않는다. 원작 스킬, 실제 비행·환장·성령 소환을 지급하지 않는다.',cards,events};
fs.writeFileSync(path.join(base,'revisions/magnolia-plan-01.json'),JSON.stringify(world,null,2)+'\n',{flag:'wx'});
const schema={type:'object',properties:{events:{type:'array',items:{type:'object',properties:{key:{type:'string'},title:{type:'string'},story:{type:'string'},intro:{type:'string'},choices:{type:'array',minItems:2,maxItems:4,items:{type:'object',properties:{label:{type:'string'},result:{type:'string'}},required:['label','result'],additionalProperties:false}}},required:['key','title','story','intro','choices'],additionalProperties:false}}},required:['events'],additionalProperties:false};
const system='제공된 페어리 테일 사건 9개를 빠짐없이 한국어로 재작성한다. key와 행동 수·순서·의도는 유지한다. story는 2~3문장, intro는 결과를 미리 말하지 않는 1문장, label은 25자 이하, result는 인물의 반응·행동 결과 1~2문장이다. 플레이어가 고르는 경험이며 나츠·루시 등이 대신 선택하지 않는다. result에 수치·카드 지급·스탯·게임 구현 설명은 쓰지 않는다. 행동에 지정된 인물에게 배우거나 함께 행동했다는 결과를 연결하되 다른 인물에게서 임의 마법을 받지 않는다. 원작 갈등 전체를 해결하거나 원작 스킬·동료 소환을 플레이어에게 지급한다고 쓰지 않는다. 엘자는 실제 환장을 하지만 플레이어는 배우는 전투 준비만 얻는다. 샤를의 예지는 확정 미래나 가격 예언이 아니다. 현재 체력 지불·실제 자동 회복 장면 대신 전투 준비와 보급을 말한다. 이전 행동을 하지 않은 루트에서 이미 했다고 쓰지 않는다. 새 시스템을 약속하지 말고 9개 상황 자체가 주는 재미를 살린다.';
const brief={facts:['루시의 편지로 옛 길드원들이 마그놀리아에 모여 재건했다는 공식 285화 소개를 장소의 소재로 삼는다. 모든 맵 사건이 원작 285화에 발생했다고 주장하지 않는다.','길드의 의뢰 게시판에서 의뢰를 받고 돌아와 보고한다. 공식 게임 매뉴얼의 역할을 참고한다.','나츠는 불의 멸룡마도사이며 감정이 격해지기 쉽지만 동료를 아낀다.','루시는 열쇠와 계약으로 성령마법을 다루고 글을 쓴다.','해피는 날개로 날고 생선을 좋아한다. 샤를도 날개 마법을 쓰고 웬디와 함께하며 때때로 예지한다.','그레이는 얼음을 여러 무기 형태로 만들고 나츠와 경쟁한다.','엘자는 별도 공간의 무기·갑옷을 순간 환장한다.','웬디는 공기를 마력 근원으로 삼고 공격·방어 부가술과 치유를 다룬다.'],rules:['모든 사건 진입에 행동력1. 카드 효과는 원작 능력을 기존 전투 스탯으로 각색한 것.','적 단계 상승은 더 강한 기존 근접 적, 적 수 상승은 더 많은 적. 골드와 필드 변화는 확률 실패에도 적용.','실제 미니게임·물건 인벤토리·NPC전투·실시간 수송 시스템은 없다. 이야기 속 개입 결과는 선택에 적힌 카드와 수치만 적용.','후속 후보는 이전 선택 성공/실패 기록 또는 필요 카드가 있어야 등장할 수 있고 확정 만남은 아니다.'],cards:cards.map(c=>({key:c.key,name:c.name,effectName:c.effectName,canonFact:c.canonFact})),events};
fs.writeFileSync(path.join(__dirname,'magnolia-text-01.json'),JSON.stringify({system,schema,brief},null,2)+'\n',{flag:'wx'});
console.log('마그놀리아 계획과 9사건 Gemma 요청 보존.');
