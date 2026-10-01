// 미식전 추가 상황의 미구현 효과를 제외하고 고정 수치와 집필 문장을 분리한다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const before=JSON.parse(fs.readFileSync(path.join(root,'requests/gourmet-pitches-05.json'),'utf8'));
const decisions=[
 ['pc_irrigation_route','제외','같은 묶음의 배수·수확 상황과 농사 선택이 겹친다. 체력·관계·시간과 미래 수리비라는 미구현 효과가 중심이다.','다른 농사 문제와 결과를 준비하면 재검토한다.'],
 ['pc_garment_misdelivery','상황 재작성','호감·재고·시간은 제외한다. 손님 허락 없이 다른 옷을 수선하는 정답 대신 의뢰서와 전달할 물건을 먼저 확인한다.','츠무기 가게와 배달만 공식 소재다.'],
 ['pc_witness_discrepancy','상황 재작성','체력·민심·시간은 제외하고 본편 섀도 진상을 대신 해결하지 않는다. 시간대가 다른 평범한 길목의 증언을 대조한다.','카스미의 조사 역할만 공식 근거다.'],
 ['pc_monica_priority','전면 재작성','모니카가 전통을 고집한다는 근거가 없다. 축제 정치·관계게이지와 시간 비용은 제외하고 자칭 군인의 주민 보호 준비로 바꾼다.','공식6화의 주민 피해·식사와 의뢰, 군인 소재만 사용한다.'],
 ['pc_carmina_practice','제외','실력 상하로 구성원을 나눈 근거가 없고 숙련·사기·무대 품질이 모두 미구현 값이다.','세 인물의 공식 역할을 확인하고 작은 준비 문제에서 다시 구상한다.'],
 ['pc_delivery_boundary','상황 재작성','시간과 모험 속도 보상·실제 NPC 동행은 제외한다. 짐의 내용이 아니라 맡는 범위와 비용을 결정한다.','유우키 물건 배달과 미식전 도움에서 별도 의뢰다.'],
 ['pc_rice_field_water','상황 재작성','체력·시간·수확 재고와 다음 농사 상태는 제외한다. 오늘 작업의 보급·일당·넓은 길목 부담으로 한정한다.','쌀농사만 공식 소재이고 폭우·배수 문제는 창작이다.'],
 ['pc_noisy_village','상황 재작성','관계·장기 체류비·시간 손실을 제외하고 음향 포장·바깥 길목·정리 보수로 한정한다. 노조미의 정치력이나 주민 마음 조작은 없다.','카르미나 가수 역할에서 새 연습 자리 문제를 만든다.']
].map(([key,decision,reason,revisit])=>({key,decision,reason,revisit}));
fs.writeFileSync(path.join(root,'revisions/gourmet-pitch-selection-05.json'),JSON.stringify({raw:'drafts/gourmet-pitches-05.json',directlyAdopted:0,decisions,notes:'8개 원안의 수치 효과는 모두 미채택. 여섯 상황은 원작 역할과 구현된 규칙에 맞게 아래 새 계획에서 재작성한다.'},null,2)+'\n',{flag:'wx'});
const f=(stat,value)=>({stat,value}),none={kind:0,goal:0,effects:[]};
const cards=[
 {key:'pc_kokkoro_harvest',name:'콧코로',grade:2,effects:[f('max_health_percent',8),f('kill_gold',3)],evolution:none,fact:'미식전 쌀농사와 생활 지원을 든든한 준비·자원 정리로 각색. 쌀 인벤토리·영구 성장·즉시 치료는 아니다.'},
 {key:'pc_tsumugi_fit',name:'츠무기',grade:2,effects:[f('action_speed',6),f('move_speed',4)],evolution:none,fact:'공식 의상 가게와 아이돌의 활동을 움직임에 맞는 준비로 각색한다. 실제 옷 장비·새 실 기술·호감 게이지는 생성하지 않는다.'},
 {key:'pc_kasumi_compare',name:'카스미',grade:2,effects:[f('penetration',6),f('crit_chance',5)],evolution:{kind:2,goal:6500,effects:[f('boss_damage_percent',5)]},fact:'자경단 조사 역할에서 서로 다른 흔적을 대조하는 준비를 개인 관통·정확한 일격으로 각색. 실제 조사 마법·적 방어 디버프·본편 진상을 지급하지 않는다.'},
 {key:'pc_monica_order',name:'모니카',grade:2,effects:[f('swift',180),f('damage_reduction',2)],evolution:none,fact:'자칭 군인과 주민 보호 의뢰 소재를 빠른 지시·방어 준비로 각색. 원작 스킬 수치나 동료 버프·부대 NPC 생성은 아니다.'},
 {key:'pc_nozomi_step',name:'노조미',grade:2,effects:[f('action_speed',6),f('max_health_percent',8)],evolution:none,fact:'카르미나 가수와 동료를 돕는 역할을 일정한 움직임·든든한 준비로 각색. 실제 공연·노래 스킬·즉시 회복·민심 변화는 없다.'}
];
const b=(action,card=null,cost=0,level=0,density=0,gold=0,potions=0)=>({action,card,card2:null,cost,level,density,gold,potions,chance:100});
const events=[
 {key:'pc_rainy_harvest',title:'빗물보다 먼저 거둘 것',situation:'미식전의 쌀농사에서 별도 비오는작업일을창작한다. 비가오려는데논가에묶어둔곡식과막힌배수길이함께남았다. 콧코로는필요한도구를세고페코린느는옮길수있는것부터들자고한다. 한행동으로수확·배수둘다완전히해결하지않고다른일을남긴다.',choices:[b('도구를 빌려 콧코로와 배수부터 돕는다','pc_kokkoro_harvest',220),b('페코린느와 넓은 보급길까지 맡아 묶음을 옮긴다','pc_pecorine_expedition',0,0,2),b('좁은 구역의 정리만 돕고 일당과 물약을 받는다',null,0,0,-1,150,1)],boundaries:'1 도구비를내고준비·자원정리요령을얻는다.곡물재고·영구골드능력없음.2더많은적이드나들구역을맡고지정페코린느준비.3범위와보급만;모든논을구했다는결말없음.'},
 {key:'pc_wrong_costume_tag',title:'옷에 묶인 다른 이름',situation:'츠무기가게로배달된옷의이름표와의뢰서받을사람이서로다르다. 유우키는종이를번갈아보고츠무기는허락없이자르면돌릴수없다며가위를내려놓는다. 옷을수선해버리는것이정답이아니고확인·반송범위를고른다.',choices:[b('연락용품과 측정 도구를 마련해 츠무기와 의뢰를 맞춘다','pc_tsumugi_fit',240),b('맞지 않는 옷은 돌려보내고 포장 일을 돕는다',null,0,0,0,180,1)],boundaries:'1확인할수있는연락·측정준비에서배운요령을카드로.실제옷장비없음.2일당과확인된보급물약.유우키에게호감·모든배송완료를주는결말아님.'},
 {key:'pc_witness_hours',title:'같은 길의 다른 시각',situation:'카스미가자경단에들어온두주민의평범한길목목격담을나란히놓는다. 한사람은짐수레를다른이는어두운보행자를봤지만진술한시각이다르다. 서로거짓말한다고단정하기전에어느부분을확인할지결정한다.섀도정체·본편괴수섬사건을해결하지않는다.',choices:[b('기록 도구를 사서 카스미와 시각부터 대조한다','pc_kasumi_compare',220),b('확인할 길목을 줄이고 보급품을 다시 묶는다',null,100,0,-1,0,2),b('확인된 문장만 옮겨 적고 기록 보수를 받는다',null,0,0,0,170)],boundaries:'조사는관통·치명준비로각색하나원작주문없음.2보급포장비100·적수-1·물약2.3판단하지않은빈칸을남긴다.시각표는실제시간소모·NPC판정이아니다.'},
 {key:'pc_monica_market_watch',title:'닫힌 가게 앞의 지시',situation:'주민을해치는일이생겨가게들이일찍문을닫으려한다. 모니카는지킬길목을정하자고하고페코린느는상인들이저녁준비를못하는것을걱정한다. 캬루는넓게맡을수록놓칠구석도늘어난다고말한다.공식6화의주민보호동기를참고한새작은시장준비문제이고수수께끼기사를쓰러뜨리지않는다.',choices:[b('표시 도구를 사서 모니카와 맡을 순서를 맞춘다','pc_monica_order',240),b('캬루와 더 넓은 길목을 맡아 공격 준비를 챙긴다','pc_karyl_resolve',0,0,2),b('맡을 위험한 길을 줄이고 보급품을 다시 마련한다',null,100,-1,0,0,1),b('폐점 정리만 돕고 일당을 받는다',null,0,0,0,170)],boundaries:'1순서준비에서고정신속180과감소2만.2무료이지만적수+2;기사처치·주민완전안전없음.3적강함-1하한1·물약1·비용100.4상인일당이며폐점자체해결아님.'},
 {key:'pc_delivery_divide',title:'갈라지는 배달길',situation:'유우키가전할짐과미식전이들고갈보급의목적지가다르다.같은수레에올렸는데첫갈림길부터어느짐을누가맡을지정해야한다.콧코로는다시포장할몫을표시하고페코린느는큰짐을먼저들자고한다.플레이어의실제NPC동행이나목적지이동없음.',choices:[b('포장 비용을 내고 콧코로와 전달할 몫을 나눈다','pc_kokkoro_care',260),b('페코린느와 큰 짐과 넓은 길목을 함께 맡는다','pc_pecorine_front',0,0,1),b('내가 맡을 구역만 줄이고 짐 분류 보수를 받는다',null,0,0,-1,160)],boundaries:'1지속회복·신속준비를유지해다음전투로간다.2동료와몫을나누는공격방어준비,적수+1.3목적지에짐전부배달했다고하지않는다.책임기록·물품인벤토리생성없음.'},
 {key:'pc_rehearsal_wall',title:'벽 너머까지 들린 연습',situation:'카르미나의연습자리에둔짐이좁은벽쪽을막고,바로너머에서는주민들이쉬려한다.노조미는연습을준비하되모든부탁을한번에들어줄수없다며상황을살핀다. 미식전은벽쪽짐을정리할지바깥길까지맡을지정한다.구성원실력상하·정치갈등·주민마음을수치화하지않는다.',choices:[b('완충재를 마련하고 노조미와 움직일 자리를 맞춘다','pc_nozomi_step',200),b('페코린느와 바깥 길까지 맡아 짐을 옮긴다','pc_pecorine_expedition',0,0,1),b('짐 정리만 돕고 일당과 물약을 받는다',null,0,0,0,130,1)],boundaries:'1동작·든든한준비만.새노래스킬·민심·연습시간연장없음.2더많은개인적수.3소음문제를전체해결하지않고제한된실무만한다.'}
];
const str={type:'string'},texts={type:'object',additionalProperties:false,required:['key','effectName','keyword','canonFact'],properties:{key:str,effectName:str,keyword:str,canonFact:str}};
const story={type:'object',additionalProperties:false,required:['key','story','intro','choices'],properties:{key:str,story:str,intro:str,choices:{type:'array',minItems:2,maxItems:4,items:{type:'object',additionalProperties:false,required:['label','result'],properties:{label:str,result:str}}}}};
const schema={type:'object',additionalProperties:false,required:['cards','events'],properties:{cards:{type:'array',minItems:5,maxItems:5,items:texts},events:{type:'array',minItems:6,maxItems:6,items:story}}};
const fixed={cards,events,sourceFacts:before.brief.sources};
fs.writeFileSync(path.join(root,'requests/gourmet-expansion-fixed-06.json'),JSON.stringify(fixed,null,2)+'\n',{flag:'wx'});
const request={review:false,system:'한국어 사건 집필자다. 숫자와참조는별도계획에서고정하므로이번에는문장만작성한다. cards5개·events6개를빠뜨리지않는다. 제작안내가아닌물건·부탁·남은문제·인물반응을짧은장면으로쓴다. 마침표로문장을끝낸다.',schema,brief:{fixed,existingCardRoles:JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/14-gourmet.json'),'utf8')).cards.map(c=>({key:c.key,name:c.name,effectName:c.effectName,effects:c.effects})),format:'cards의key/effectName/keyword/canonFact,events의key/story/intro/choices순서대로label/result만. 다른숫자·효과필드는쓰지않는다. story2~3문장,결과2문장안팎.각선택의일당·포장·보급비용제공자와지정카드의준비를행동에연결한다.모든선택성공100이며비용·필드값먼저적용된다.',rules:'관계·재고·시간·체력·AP·팀라이프효과없음.원작의섀도나수수께끼기사·치카의문제를완결하지않는다.고유검기술·노래·정신지배·적디버프기능지급없음.미식전쌀농사·츠무기의상가게·카스미조사·모니카군인·노조미가수만원작소재다.가격·길목·폭우·받을사람혼선·같은시각증언·짐은창작.기존카드중복100골드로교환되며현재필드상한이면위험증가선택비활성.다른사건에서받은카드를삭제하지않고현재체력을즉시회복시키지않는다.'}};
fs.writeFileSync(path.join(root,'requests/gourmet-expansion-text-06.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});
console.log('미식전 원안8개 판단과 고정6사건·5카드 문장 집필 요청 보존.');
