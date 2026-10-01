// 미식전 머리의 반복을 줄일 독립 사건 세 개와 관련 성장 카드를 집필한다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const current=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/14-gourmet.json'),'utf8'));
const schema=require(path.join(repo,'tools/content-schema.json'));
const b=(action,card,cost=0,level=0,density=0,gold=0,potions=0,chance=100)=>({action,card,card2:null,cost,level,density,gold,potions,chance});
const cards=[
 {key:'pc_kokkoro_notes',name:'콧코로',grade:2,effects:[{stat:'event_choices',value:1},{stat:'kill_gold',value:2}],evolution:{kind:0,goal:0,effects:[]},fact:'기록과 출발 준비를 챙기는 길드 활동을 사건 후보와 처치 수급으로 각색한다. 후보 추가는 총4개 한도이며 행동력·리롤 할인·무한 재고가 아니다.'},
 {key:'pc_pecorine_expedition',name:'페코린느',grade:2,effects:[{stat:'healthy_damage',value:18},{stat:'normal_damage_percent',value:12}],evolution:{kind:1,goal:45,effects:[{stat:'boss_damage_percent',value:6}]},fact:'배고픈 검사와 식재료를 찾아 길드 의뢰에 나서는 모습을 고체력·일반 적 준비로 각색한다. 흡혈·고유 검 기술·재료 인벤토리를 생성하지 않는다.'},
 {key:'pc_aoi_courage',name:'아오이',grade:2,effects:[{stat:'move_speed',value:4},{stat:'healthy_damage',value:12}],evolution:{kind:3,goal:45,effects:[{stat:'action_speed',value:3}]},fact:'낯선 학교 분위기에 적응하기 어려워하는 아오이를 돕는 상황에서 한 걸음씩 나아가는 준비로 각색한다. 원작 고유 전투 기술이나 친구 수 게이지를 만든 것이 아니다.'}
];
const plans=[
 {key:'pc_dusty_room',title:'먼지 뒤에 남은 방',previous:null,previousChoice:0,requiredCard:null,situation:'길드 하우스 대청소의 공식 소재에서 별도 작은 방 정리를 창작한다. 오래된 재료 상자와 깨진 선반, 쓸 수 있는 수납공간이 한 방에 뒤섞여 있다. 콧코로는 남길 물건을 기록하자고 하고 페코린느는 큰 상자를 먼저 들어내려 한다. 무엇을 보존하고 어디까지 정리할지 정한다.',choices:[
   b('제본과 정리 비용을 내고 콧코로와 남길 물건을 기록한다','pc_kokkoro_notes',220),
   b('페코린느와 큰 상자부터 옮기고 더 넓은 구역을 맡는다','pc_pecorine_front',0,0,1),
   b('필요한 보급품만 챙기고 쓰지 않을 공간은 닫는다',null,0,0,-1,0,1),
   b('빈 상자와 고철을 매입상에게 넘긴다',null,0,0,0,170)
 ],boundaries:'1. 물건과 맡을 일의 기록을 챙긴다. 새 인벤토리 물품·창고 확장 없음. 2. 큰 상자를 치우는 힘쓴 자세를 준비한다. 개인 사냥에 더 많은 적이 남고 방 실제 지형 변경은 없음. 3. 물약1·적 수-1. 전체 문제가 해결되었다고 하지 않는다. 4. 돈을 받고 남겨 둘 물건을 구분한 결론으로 쓰지 않는다.'},
 {key:'pc_faded_spice_map',title:'색이 번진 향신료 지도',previous:null,previousChoice:0,requiredCard:null,situation:'식재료 의뢰에 나서는 활동과 불확실한 지도 모험을 참고하되 원작의 궁극 조미료·타르굼 마을·섀도 사건을 재연하지 않는다. 습기에 번진 평범한 향신료 채집 지도에서 한 길만 표시가 남았다. 페코린느는 확인해 보고 싶어 하고 캬루는 정확한지 먼저 보자고 한다. 콧코로는 오늘 필요한 보급만 따로 챙기고 있다.',choices:[
   b('현장 도구를 마련해 페코린느와 남은 표시를 확인한다','pc_pecorine_expedition',150,1,0,280,0,65),
   b('확인된 길 안내를 사서 캬루와 출발 준비를 점검한다','pc_karyl_check',240),
   b('콩알만 한 글씨를 다시 정리하고 콧코로와 의뢰를 나눈다','pc_kokkoro_notes',180),
   b('채집은 맡지 않고 지도를 돌려주며 보급품만 정리한다',null,0,0,0,120,1)
 ],boundaries:'1. 65% 성공 때만 지정 페코린느 카드·280골드. 실패면 보상 없음, 도구비150·적 단계+1은 이미 적용되어 남는다. 큰 악역·원작 고유 보물·새 식재료 아이템 없음. 2. 보스나 주요 원작 사건 결말을 알아내지 않는다. 3. 이미 가진 지도/불확실한 보고를 정리할 뿐 미래나 정답을 완벽히 예언하지 않는다. 4. 그리운 원작 도구를 신규아이템으로 지급하지 않고 물약1·골드120만 받는다.',failure:'표시가 남은 길은 오래 전에 쓰던 길이었다. 찾던 재료는 확인하지 못했고 준비비는 돌아오지 않았다. 앞으로 더 강한 개인 사냥 구역을 맡는 부담이 남는다.'},
 {key:'pc_tea_invitation',title:'접힌 채 남은 초대장',previous:null,previousChoice:0,requiredCard:null,situation:'성 테레사 여학원 분위기에 적응하기 어려운 아오이와 유우키·콧코로의 도움이라는 공식 소재에서 별도 작은 초대장 문제를 만든다. 아오이가 가벼운 차 모임 안내장을 들고 있지만 건네려던 말을 적다가 종이만 접어 두었다. 콧코로는 먼저 준비할 물건부터 고르자고 하고 아오이는 네가 대신 모든 말을 해버리는 것은 바라지 않는다. 학교 전체 관계나 인생 문제를 한 번의 선택으로 해결하지 않는다.',choices:[
   b('아오이와 건넬 말 한 문장부터 정리해 함께 문 앞에 선다','pc_aoi_courage',160),
   b('모임의 준비 목록을 정리해 콧코로와 빠진 것을 챙긴다','pc_kokkoro_notes',200),
   b('전달할 범위를 줄이고 보급 준비만 돕는다',null,0,0,-1,0,1),
   b('안내장 정리와 봉투 작업만 맡고 보수를 받는다',null,0,0,0,160)
 ],boundaries:'유료1은 연습 종이·준비물 비용160. 마음조작·확정 친구획득 없음. 말과 준비 중 어느것을 맡았는지 다르게 남겨라. 3번의 전달 범위는 맵 전용 배정 사냥 범위와 대응하여 적 수-1, 실제NPC배달·호위·지도순간이동 없다. 4번은 보수만 받고 아오이 대신 관계를 완성하지 않는다. 병든인물·거짓왕족·SNS시스템 만들지 않는다.'}
];
const request={review:false,system:'한국어 사건·캐릭터 카드 집필자다. 기존 머리 안에서 서로 다른 문제를 해결하는 독립 사건을 만든다. 지정한 key·수치·이전기록·카드 보상을 정확히 보존한다. 원작 사실과 별도 창작을 구분하며 새 기술이나 현재 체력 비용을 추가하지 않는다. 제작용 안내를 플레이어 이야기 문장에 복사하지 않는다.',schema,brief:{existingCardKeys:current.cards.map(c=>({key:c.key,name:c.name,effectName:c.effectName,effects:c.effects})),newCards:cards,plans,sourceFacts:[{source:'https://anime.priconne-redive.jp/archive/1st/story/id_04.html',fact:'미식전 네 사람이 길드 하우스를 빌려 함께 청소한다.'},{source:'https://anime.priconne-redive.jp/archive/1st/story/id_06.html',fact:'길드 관리 협회 의뢰로 향신료 원료 수확에 나선다. 타르굼 주변에서 섀도에 따른 실종 사건이 일어나지만 이 요청에서 본편 실종을 해결하지 않는다.'},{source:'https://anime.priconne-redive.jp/story/ep_01.html',fact:'불확실한 조미료 지도를 보고 새로운 모험에 나선다. 특정 보물 이름과 본편 결과를 쓰지 않는다.'},{source:'https://anime.priconne-redive.jp/story/ep_03.html',fact:'랜드솔의 아오이는 성 테레사 여학원에 다니지만 분위기에 적응하기 어려워한다. 유우키·콧코로가 돕고자 학교로 함께 간다.'}],format:'cards에는 새 카드 세 개만, events에는 위의 새 독립 사건 세 개만 작성한다. 기존 카드를 복사하지 않는다. effectName·keyword·canonFact·uncertain[]와 story·intro·label·result를 채운다. card2=null. 모든 기존카드 참조는 existingCardKeys를 사용한다. 자유로운 랜덤 카드 지급으로 바꾸지 않는다.',mechanics:'각 사건 후보 선택은AP1, 방문과후속구분. 비용은선택시차감. 확률65는1~100난수판정이며성공카드·골드만확률, 비용과필드변화는성공/실패둘다적용. level은적강함, density는동시적수. 변화는사냥에남지만하한1·강함상한5·수상한10. 포션은기존소모품, 카드중복은100골드. 신속고정단위, 치명p, regenmaxHP%/초, event_choices후보총4한도, 무피격각성은연속초다. 새스킬·NPCAI·감정/관계게이지·퀘스트아이템·행동력증감·체력비용없음.',quality:'기존 냄비 식사와 남은 끼니 후속은 반복하지 않는다. 대청소/불확실한자료확인/대화준비라는 세 문제의 차이를 인물·물건·남은 부탁으로 보여라. 모든 선택을 돈을내고기술배우기 또는모두해결했다로 끝내지 않는다. 실제재미·원작전수검증했다고 주장하지 않는다.'}};
fs.writeFileSync(path.join(root,'requests/gourmet-expansion-04.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});
console.log('미식전 독립 사건3개·새 카드3개 확장 요청을 보존했습니다.');
