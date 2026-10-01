// 확인된 미식전의 성격으로 별도 식사 사건과 지원되는 카드 효과를 집필한다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'..');
const schema=require(path.resolve(__dirname,'../../..','tools/content-schema.json'));
const effects=(...pairs)=>pairs.map(([stat,value])=>({stat,value}));
const card=(key,name,grade,stats,evolution,fact)=>({key,name,grade,effects:effects(...stats),evolution:evolution||{kind:0,goal:0,effects:[]},fact});
const cards=[
  card('pc_kokkoro_entry','콧코로',1,[['action_speed',2]],null,'출발 준비와 생활을 세심하게 돌보는 역할을 작은 행동 준비로 각색한다.'),
  card('pc_pecorine_meal','페코린느',2,[['max_health_percent',12],['healthy_damage',14]],{kind:1,goal:60,effects:effects(['normal_damage_percent',8])},'밝은 대식가이자 검사라는 성격을 든든한 준비와 고체력 조건으로 각색한다.'),
  card('pc_pecorine_front','페코린느',2,[['attack_percent',12],['damage_reduction',3]],null,'먹는 즐거움과 동료들과 함께 모험하는 검사의 적극성을 공격과 방어 준비로 각색한다. 새 검 기술을 지급하지 않는다.'),
  card('pc_kokkoro_care','콧코로',2,[['regeneration',0.6],['swift',90]],null,'식사와 수선 등 세심한 생활 지원을 지속 회복과 고정 신속으로 각색한다. 즉시 회복·물약 대체가 아니다.'),
  card('pc_karyl_check','캬루',2,[['crit_chance',7],['crit_damage',18]],{kind:2,goal:7000,effects:effects(['boss_damage_percent',8])},'부탁에 불평하면서도 길드 활동에 참여하는 모습을 헛수고를 줄이는 정확한 공격 준비로 각색한다. 확인하지 않은 마법 명칭을 쓰지 않는다.'),
  card('pc_karyl_resolve','캬루',2,[['boss_damage_percent',14],['penetration',8]],null,'귀찮은 일을 끝까지 확인하고 문제를 직접 처리하는 사건 속 행동의 보상이다. 이 행동과 수치는 맵 전용 각색이며 원작 고유 기술 수치가 아니다.')
];
const branch=(action,card,cost=0,density=0,level=0,gold=0,potions=0)=>({action,card,cost,density,level,gold,potions,chance:100});
const brief={
  sourceFacts:[
    {source:'https://anime.priconne-redive.jp/archive/1st/story/id_02.html',fact:'페코린느는 대식 대회에 우승한 배고픈 검사다. 유우키·콧코로가 잃어버린 검을 찾는 것을 돕는다.'},
    {source:'https://anime.priconne-redive.jp/archive/1st/story/id_03.html',fact:'페코린느가 식당 재료를 먹어 주문이 막히며, 남겨진 숨은 메뉴를 주문한다.'},
    {source:'https://anime.priconne-redive.jp/archive/1st/story/id_04.html',fact:'캬루까지 합류한 네 사람이 미식전을 만들고, 활동 거점인 길드 하우스를 빌려 함께 청소한다.'},
    {source:'https://anime.priconne-redive.jp/archive/1st/story/id_11.html',fact:'페코린느가 걱정해 캬루의 방에 들어갔다가 인형을 망가뜨리고, 바느질에 능한 콧코로가 수선을 제안한다.'},
    {source:'https://anime.priconne-redive.jp/story/ep_01.html',fact:'불확실한 지도를 보고 특이한 조미료를 찾으려 모험을 떠나는 길드다. 이 요청에서는 그 본편 보물이나 결말을 사용하지 않는다.'}
  ],
  newFiction:'원작의 특정 식당·검 분실·인형 파손을 재연하지 않는다. 별도 의뢰를 마친 뒤 길가에서 함께 식사할 준비를 하는 맵 전용 작은 사건이다. 재료 냄새에 몰리는 적, 장보기 비용, 끼니를 얻으려는 동료, 남겨 둔 식사의 처리만 창작한다. 본편 등장 인물의 정체나 운명은 바꾸지 않는다.',
  cards,
  eventPlans:[
    {key:'pc_road_meal',title:'냄비를 올리기 전에',situation:'일을 마친 미식전이 길가에서 식사하려 한다. 준비한 재료는 부족하고 냄새를 맡고 접근하는 적이 보인다. 페코린느는 근처에서 재료를 더 모으자고, 콧코로는 가진 재료로 나눌 방법을, 캬루는 적이 드나드는 길부터 피하자고 한다.',previous:null,previousChoice:0,choices:[
      branch('페코린느와 넓은 구역의 재료를 모아 넉넉히 차린다','pc_pecorine_meal',0,2),
      branch('밀봉된 재료를 구해 콧코로와 끼니를 나누어 준비한다','pc_kokkoro_care',260),
      branch('캬루와 길목을 확인하고 식사 준비를 좁힌다','pc_karyl_check',160,-1),
      branch('식사는 다음으로 미루고 남은 재료를 매입상에게 판다',null,0,0,0,180)
    ],resultBoundaries:['1. 재료를 넉넉히 모아 먹는다. 페코린느와 준비하는 카드 획득. 넓게 맡은 사냥 구역 때문에 적 수 +2가 유지된다.','2. 더 산 재료로 오늘 먹을 것과 다음 끼니를 나눈다. 콧코로의 회복 준비 카드 획득. 이 시점에 물약 즉시 지급은 없다.','3. 비용을 내고 한쪽 길을 정리해 식사 자리를 마련한다. 캬루의 정확한 공격 준비 카드, 적 수 -1. 원작의 마법 기술이나 순간 이동을 쓰지 않는다.','4. 재료를 팔아 일당을 받는다. 카드를 얻거나 끼니를 해결한 결말이 아니다.']},
    {key:'pc_after_feast',title:'빈 그릇과 늘어난 몫',situation:'넉넉히 차려 함께 먹은 뒤, 그릇을 거두는데 주변 일을 돕던 사람들도 끼니를 부탁한다. 페코린느는 이미 먹은 몫까지 다시 세어 보며 재료를 보태자고 하고, 캬루는 나눠 줄 자리와 길부터 정하자고 한다. 이 부탁은 맵 전용 창작이다.',previous:'pc_road_meal',previousChoice:1,choices:[
      branch('재료값을 보태 페코린느와 남은 사람들의 식사를 차린다','pc_pecorine_front',220),
      branch('캬루와 한쪽 길을 정리하고 나눠 줄 자리를 좁힌다','pc_karyl_resolve',180,-1),
      branch('설거지와 정리만 맡고 보수를 받는다',null,0,0,0,160)
    ],resultBoundaries:['1. 자기 식사를 더 먹는 게 아니라 추가로 부탁한 사람들의 식사를 차린다. 페코린느 카드 효과를 한 번 얻는다.','2. 한쪽 길의 적 부담을 줄이고 마련한 자리에서 식사를 나누는 준비를 한다. 캬루 카드. 새로운 적 종류·NPC 수송 모드를 만들지 않는다.','3. 그릇을 정리하고 일당을 받는다. 식사 추가 부탁은 맡지 않는다. 과거에 늘린 적 수가 현재도 동일하다고 단정하지 않는다.']},
    {key:'pc_after_portions',title:'남겨 둔 한 끼',situation:'앞서 콧코로와 다음 끼니까지 나누어 두었다. 다시 만났을 때 밀봉한 한 끼가 남아 있고, 이번에는 다급히 길을 떠나려는 일행이 식사를 부탁한다. 준비한 몫을 건넬지 지금 먹을지 결정한다.',previous:'pc_road_meal',previousChoice:2,choices:[
      branch('내 몫을 먹고 페코린느와 다음 일의 준비를 한다','pc_pecorine_meal'),
      branch('남겨 둔 식사를 건네고 포장 재료를 다시 마련한다',null,120,0,0,0,2),
      branch('식사를 매입상에게 넘기고 정리 비용을 받는다',null,0,0,0,220)
    ],resultBoundaries:['1. 지금까지 남겨 둔 자신의 식사를 먹는다. 페코린느 카드. 현재 체력을 즉시 채우는 효과는 없다.','2. 식사를 건네는 고마움으로 길 떠날 보급품(물약 2개)을 받고 포장비 120을 낸다. 상대 인물이 마법·원작 고유 물약을 주는 설정은 없다.','3. 골드를 받되 자기 끼니나 부탁한 일행의 식사를 해결한 결론으로 쓰지 않는다. 거래 NPC와 재료는 설명상 존재하며 맵 유닛·인벤토리 물품을 만들지 않는다.']}
  ],
  units:'swift 90은 고정 수치이며 행동·이동 약2%, 신속 쿨감 약1.96%p 기여다. 다른 숫자는 %, crit은 %p, regen은 최대체력%/초. 흡수+재생 합산 10%/초 제한. 각성 kind1=처치수,2=실제 누적 피해,3=연속 무피격 시간이며 달성 후 effects를 기본 효과에 더한다.',
  mechanics:'사건 선택 자체에 행동력1. 후속도 별도 사건으로 행동력1, 등장 보장 안됨. previousChoice는 1부터 센 성공 선택. 선택 전에 비용이 가능한지 검사. 카드2=null, requiredCard=null, failure=null, uncertain=[]. 카드는 기존 것을 없애지 않고 추가한다. level/density 변화는 선택 직후 사냥터에 남지만 다른 사건이 나중에 바꿀 수 있다. 적 수 감소는 최저1에서 멈춘다. 현재 체력 소모, NPC 감정·평판 게이지, 팀 비용, 새 기술, 퀘스트 물품, 실제 호위·시간 지연 임무는 없다.',
  writing:'cards의 effectName,keyword,canonFact를 작성하고 events의 story,intro,label,result를 집필한다. 제시한 key·효과·각성·비용·필드·지급·기록 조건은 정확히 보존한다. 각 카드 canonFact와 사건 canonFact에는 확인된 성격에서 맵 전용 행동·수치로 각색했음을 구분한다. 문장마다 제작 제한 안내를 넣지 말고 장면에서 누가 무엇을 했는지 보여준다. 짧은 이야기 2~4문장과 행동 결과 1~2문장. 원작 인형·검 분실 재연, 불확실 지도와 신비한 보물, 피로/감정 게이지로만 차이를 내는 제안은 이미 제외했으니 반복하지 않는다.'
};
const request={review:false,system:'확인된 원작 성격을 살려 맵 전용 사건과 캐릭터 카드를 집필한다. 지시된 수치·기록·행동 결과를 바꾸지 않는다. 전부 한국어 JSON으로 반환한다. 보상 안내가 아닌 인물·물건·남은 부탁이 있는 장면을 쓴다. 원작 본편을 해결하거나 확인하지 않은 고유 기술을 붙이지 않는다.',schema,brief};
fs.writeFileSync(path.join(root,'requests/gourmet-design-02.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(root,'revisions/gourmet-rejected-01.json'),JSON.stringify({source:'drafts/gourmet-situations-01.json',decision:'reject both pitches; do not import',items:[{title:'재료 고갈과 특별한 조리법',reasons:['새 작은 상황을 요청했지만 공식 3화의 식당 재료 소진·숨은 메뉴를 그대로 재연했다.','situation 문장이 캬루는에서 중단됐다.','차이의 대부분이 미구현 메뉴 다양성·NPC 피로도다.']},{title:'수선용 천의 부족과 캬루의 고집',reasons:['명시적으로 피하라고 한 본편의 캬루 인형 파손·수선을 다시 사용했다.','원래 색감과 질감에 극도로 고집한다는 세부 설정은 확인하지 않았다.','두 선택이 모두 수선 미흡과 불만만 남겨 행동의 차이가 약하다.']}],retry:'공식 장면은 성격 확인만 활용하고 별도 길가 식사 문제를 작성한다. 실제 지급 카드·골드·물약·사냥 구역으로 결과를 표현하되 본편 사건을 반복하지 않는다.'},null,2)+'\n',{flag:'wx'});
console.log('미식전 카드 6장·식사 사건 3개 요청과 1차 제외 이유를 보존했습니다.');
