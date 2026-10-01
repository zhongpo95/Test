// 나비저택의 생활·치료 준비·연락·출발을 다루는 독립 사건 확장을 집필한다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const old=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/13-butterfly.json'),'utf8'));
const eff=(stat,value)=>({stat,value}),evo=(kind=0,goal=0,effects=[])=>({kind,goal,effects});
const card=(key,name,effects,evolution,fact)=>({key,name,grade:2,effects,evolution,fact});
const cards=[
 card('kny_aoi_supply','칸자키 아오이',[eff('regeneration',0.4),eff('kill_gold',2)],evo(),'저택의 치료·수련 지원을 전투 중 회복 준비와 처치 뒤 수급 정리로 각색. 원작에 처치골드 능력이 있다는 뜻이 아니다.'),
 card('kny_kanao_quiet','츠유리 카나오',[eff('move_speed',5),eff('crit_chance',5)],evo(),'높은 신체 능력과 반응 수련 상대 역할을 이동 준비와 정확한 공격으로 각색. 실제 회피 확률·동전·자동 이동 없음.'),
 card('kny_tanjiro_smell','카마도 탄지로',[eff('directional_damage',14),eff('penetration',5)],evo(1,45,[eff('boss_damage_percent',6)]),'후각과 상대 급소를 읽는 공식 인물 소재를 방향 적중 피해와 개인 방어 관통으로 각색. 냄새 탐지 UI·새 호흡 기술 없음.'),
 card('kny_shinobu_points','코쵸 시노부',[eff('penetration',8),eff('boss_damage_percent',12)],evo(),'공식 약학·독 전투의 소재를 상대 특성에 맞는 공격 준비로 각색. 실제 독·지속피해·전염·즉사 기술 지급 없음.'),
 card('kny_zenitsu_listen','아가츠마 젠이츠',[eff('charge_speed',7),eff('boss_damage_percent',8)],evo(3,45,[eff('charge_damage',8)]),'공식 청각과 한순간 집중한 공격의 소재를 차지 준비로 각색. 새 소리 감지 기능·실신 필요 없음.'),
 card('kny_inosuke_terrain','하시비라 이노스케',[eff('move_speed',5),eff('normal_damage_percent',15)],evo(),'산에서 자란 감각과 돌파 성향을 길을 읽는 이동 준비와 일반 적 상대 준비로 각색. 실제 벽 통과·쌍검 기술 없음.')
];
const b=(action,card=null,cost=0,level=0,density=0,gold=0,potions=0,chance=100)=>({action,card,card2:null,cost,level,density,gold,potions,chance});
const plans=[
 {key:'kny_unread_bottles',title:'지워진 병의 이름',situation:'나비저택에 들어온 보급 상자의 병 이름표가 비에 번졌다. 시노부는 이름 모를 것을 먼저 쓰지 말라고 하고 아오이는 확실히 구분한 병과 빈 용기를 따로 놓는다. 무엇을 확인하고 어디까지 도울지 고른다. 원작의 공식 치료·약학에서 별도 보급 문제 창작.',choices:[b('새 이름표를 사서 시노부와 병의 기록을 대조한다','kny_shinobu',220),b('아오이와 확인된 보급만 정리하고 나머지는 남긴다','kny_aoi_supply',140),b('빈 용기 운반만 돕고 일당과 보급 물약을 받는다',null,0,0,0,120,1)]},
 {key:'kny_white_linen',title:'마르지 않은 흰 천',situation:'회복 중인 사람들에게 건넬 천을 말리려는데 비가 그치지 않는다. 아오이는 새 천을 구할지, 이노스케가 찾은 돌아가는 길로 건조한 보급을 가져올지 고민한다. 범위와 자원을 고르는 생활 사건. 실제NPC 환자의 상태를 수치화하지 않는다.',choices:[b('새 천을 마련하고 아오이와 보급 묶음을 나눈다','kny_aoi_supply',180),b('이노스케와 돌아가는 보급길을 넓게 맡는다','kny_inosuke_terrain',0,0,1),b('좁은 길목만 맡고 남은 물약을 챙긴다',null,0,0,-1,0,1)]},
 {key:'kny_crow_dispatch',title:'까마귀가 두 번 읽은 문장',situation:'전령 까마귀가 새 임무를 전한다. 긴 설명에서 목적지와 맡을 일을 놓쳐 같은 문장을 두 번 듣는다. 탄지로는 서두르기 전에 다시 확인하자고 하고 아오이는 출발할 보급을 묶고 있다. 공식26화 전령에서 별도 안내 혼선 창작. 원작의 무한열차 임무를 해결하거나 실제 목적지를 바꾸지 않는다.',choices:[b('기록용품을 사서 탄지로와 맡을 일을 다시 확인한다','kny_tanjiro',160),b('보급을 챙기며 아오이와 출발 목록을 맞춘다','kny_aoi_supply',200),b('안내를 옮겨 적는 일만 맡고 보수를 받는다',null,0,0,0,150)]},
 {key:'kny_gourd_bundle',title:'크기가 다른 박 묶음',situation:'기능 회복 훈련에 쓰던 박의 새 묶음이 도착했는데 작은 것과 큰 것의 수가 뒤바뀌었다. 탄지로는 필요한 크기를 다시 세고 이노스케는 큰 것으로 먼저 해 보려 한다. 훈련 자체를 돈내고 선택하는 수업이 아니라 납품 문제에서 대응을 고른다. 공식뉴스53319에 나비저택 기능회복훈련의 박 소재가 확인된다. 파손횟수 미니게임·박 아이템 생성 없음.',choices:[b('운반 비용을 보태 탄지로와 필요한 크기로 바꿔 온다','kny_tanjiro',200),b('이노스케와 큰 묶음을 맡고 더 강한 구역도 받는다','kny_inosuke',0,1),b('잘못 온 묶음을 돌려주고 정리 보수를 받는다',null,0,0,0,180)]},
 {key:'kny_silent_turn',title:'돌아보는 순간의 발',situation:'복도의 반응 수련 뒤 표식을 걷는데 카나오는 발이 먼저 움직이면 물건을 놓치기 쉽다는 것을 몸으로 보여 준다. 카나오와 부딪치지 않게 표식을 옮기거나 바깥길을 돌아 정리할 수 있다. 공식24·25화의 반응·신체훈련을 별도 표식 철거 문제로 각색. 치료실 사람에게 위해를 끼치거나 플레이어실제 미니게임 입력을 요구하지 않는다.',choices:[b('도구를 사서 카나오와 동선을 따라 표식을 걷는다','kny_kanao_quiet',180),b('넓은 바깥 길목까지 맡아 이노스케와 정리한다','kny_inosuke_terrain',0,0,2),b('수련장 밖의 짐만 거두고 일당을 받는다',null,0,0,0,160)]},
 {key:'kny_midday_noise',title:'너무 많은 소리가 나는 낮',situation:'출발 준비 중 젠이츠가 여러 소리를 한꺼번에 들었다며 서두르지 못한다. 짐을 두드리는 소리와 걸음소리가 뒤섞여 있다. 탄지로는 확인할 순서를 줄이고 젠이츠는 한 번 움직일 순간을 고르려 한다. 청각 소재의 별도 출발 준비 문제, 사람실종 밤길 사건과 다름.',choices:[b('완충천을 마련해 짐 소리를 줄이고 젠이츠와 기다릴 순간을 맞춘다','kny_zenitsu_listen',180),b('탄지로와 순서를 나누어 주변 흔적부터 확인한다','kny_tanjiro_smell',220),b('출발 범위를 한 곳 줄이고 물약을 챙긴다',null,0,0,-1,0,1)]},
 {key:'kny_mixed_traces',title:'같은 자리에 남은 다른 냄새',situation:'저택 밖 보급길의 발자국은 하나인데 젖은 짐과 풀 냄새가 겹쳐 흔적을 구분하기 어렵다. 탄지로는 눈에보이는자국만따르지않고, 이노스케는몸으로주변을확인하자고한다. 실종자구출없고 맡을사냥범위를정하기전짧은현장확인이다. 공식 후각·산감각 소재.',choices:[b('도구를 마련해 탄지로가 짚은 흔적을 조사한다','kny_tanjiro_smell',140,1,0,220,0,70),b('이노스케와 넓은 주변 길목을 직접 맡는다','kny_inosuke_terrain',0,0,2),b('확인된 범위만 남기고 조사 기록 보수를 받는다',null,0,0,-1,120)],failure:'같은 자국에 겹친 냄새를 끝내 나누지 못했다. 조사비는 돌아오지 않고 보상도 없다. 맡기로 한 더 강한 구역은 남는다.'},
 {key:'kny_small_visit',title:'빈손으로 온 문병객',situation:'회복하러 온 동료를 보러 저택을 찾은 보통 대원이 손에 든 짐이 없다고 머뭇거린다. 아오이는 이미 가져온 물건보다 지금 필요한 것을 물어보면 된다고 한다. 공식저택치료·칸자키아오이지원에서별도문병부탁창작,특정본편문병장면재연아님. 외부대원은고유무술·신규카드인물이아님.',choices:[b('보급품을 사서 아오이와 필요한 몫을 따로 챙긴다','kny_aoi_supply',160),b('시노부에게 병실에 가져갈 것을 확인하고 준비한다','kny_shinobu',240),b('잔심부름만 맡고 일당을 받는다',null,0,0,0,150)]},
 {key:'kny_before_departure',title:'문턱에 남겨 둔 당부',situation:'훈련을 마친 일행이 다시 떠날 준비를 하는데 시노부가 마지막으로 챙긴것을살핀다. 힘으로끝내려는이노스케와서두르지않는카나오의준비가다르다. 보스전성향에맞는마지막점검을고르는창작,시간제한감소·실제다음임무진입없음. 독은실제새능력으로생성하지않는다.',choices:[b('상대에 맞춰 공격을 준비할 재료를 마련하고 시노부의 조언을 듣는다','kny_shinobu_points',260),b('도구를 챙겨 카나오와 발을 옮길 순서를 점검한다','kny_kanao_quiet',180),b('이노스케와 더 강한 길목을 맡는 대신 돌파 자세를 챙긴다','kny_inosuke',0,1),b('보급 정리를 마치고 일당과 물약을 받는다',null,0,0,0,100,1)]}
];
const sourceFacts=[
 {source:'https://kimetsu.com/anime/risshihen/story/?story=24',fact:'부상당한 탄지로·젠이츠·이노스케가 시노부 저택에서 치료받고 기능회복훈련을 한다.'},
 {source:'https://kimetsu.com/anime/risshihen/story/?story=25',fact:'탄지로는 호흡을 하루내내 이어가는 수련을 하며 카나오와의 훈련에 점차 성과를 얻는다.'},
 {source:'https://kimetsu.com/anime/risshihen/story/?story=26',fact:'훈련을 마무리하던 탄지로에게 전령 까마귀가 새 임무를 전한다.'},
 {source:'https://kimetsu.com/anime/hashirageikohen/character/',fact:'탄지로후각, 젠이츠청각, 이노스케산감각·돌파, 카나오신체능력, 시노부약학·독 전투 역할. 네즈코햇빛극복 등 후기줄거리변화는 초기저택소재에 혼합하지않는다.'},
 {source:'https://kimetsu.com/anime/anime/character/?chara=kanawo',fact:'공식 인물 포털은 탄지로가 상대 급소의 냄새를 나눈다고 소개한다. URL은 아래 sources에 정정해 사용한다.'},
 {source:'https://kimetsu.com/anime/risshihen/news/?id=53319',fact:'공식뉴스는 기능회복훈련의 반사·전신훈련 및 박을 소재로 한 행사를 소개하며 칸자키아오이·테라우치키요의 지원역할을 언급한다. 우리맵에는그행사나게임을구현하지않는다.'}
];
sourceFacts[4].source='https://kimetsu.com/anime/character/?chara=kanawo';
const request={system:'한국어 사건·캐릭터카드 집필자다. 이름만다른보상메뉴대신 구체적인 물건·부탁·인물태도의차이를 보여 준다. 지정 key·등급·스탯·수치·보상과 chance를바꾸지않는다. 공식소재에서별도문제를창작했음을canonFact에쓰고 제작안내는플레이어문장에복사하지않는다.',schema:require(path.join(repo,'tools/content-schema.json')),brief:{newCards:cards,existingCards:old.cards,sourceFacts,plans,format:'cards에는 새6개만,events에는새9개만. 각각story2~3문장·intro1문장·result1~2문장으로간결하게. previous=null previousChoice=0 requiredCard=null. 카드effectName·keyword·canonFact·uncertain[] 채우기. 확률70사건만failure문장있고다른failure=null. 모든금액·필드수치·참조그대로. grade2, card2=null.',mechanics:'사건방문AP1. cost와필드위험먼저적용되고실패때도남는다. chance성공시에만지정카드/gold/potions. 이미소지카드100골드. level1..5,density1..10,감소하한1. 재생0.4는maxHP0.4%/초, 합산흡수재생10%한도,물약별도. 이동5%는기본400에서+20. 차지속도는차지스킬준비; 방향피해는방향적중태그; 공격과버프에일괄추가아님. 신규호흡·독·전령UI·퀘스트물품·NPC동행·체력비용·AP추가없음.',quality:'서로다른9개독립문제이며1~2개훈련보급소재가있어도9개를유료수업으로바꾸지않는다. 비용은종이/천/도구/운반준비와연결.밀도·난도변화는앞으로맡을개인사냥의부담. 골드보상은일당/의뢰비에서나오며살생보상을새로이름붙이지않는다. 실패가사망이나병 악화가되어서는안된다. 탄지로/시노부의고유능력을플레이어가받는것으로묘사하지않는다.'}};
fs.writeFileSync(path.join(root,'requests/butterfly-expansion-04.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});
console.log('나비저택 독립 사건9개·새 카드6개 집필 요청 보존.');
