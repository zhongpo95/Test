// 블레이블루 공식 흡수 설명을 확인한 라그나 공통 사건 후보를 보존해 추가한다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'../../..'),file=path.join(root,'content/roguelite/08-common.json');
const old=fs.readFileSync(file),data=JSON.parse(old);
fs.writeFileSync(path.join(__dirname,'08-common-before-ragna-06.json'),old,{flag:'wx'});
const source='https://www.blazblue.jp/cf/images/playguide_0828.pdf';
data.sources.push(source,'https://www.blazblue.jp/bbrr/sp/character/ragna/');
data.world.work+=' · 블레이블루';
data.canonBoundary+=' 라그나의 소울 이터 체력 흡수와 거친 정면 돌파 성향은 공식 가이드·소개를 확인했다. 수배서·통행 문제는 맵의 창작이며 원작 라운드, 히트 게이지, 새 검 기술을 지급하지 않는다.';
data.cards.push(
 {key:'common_ragna_eater',name:'라그나 더 블러드엣지',effectName:'소울 이터',keyword:'공통 · 흡수 · 공격',grade:2,effects:[{stat:'leech',value:8},{stat:'attack_percent',value:6}],evolution:{kind:2,goal:15000,effects:[{stat:'max_health_percent',value:8}]},canonFact:'공식 가이드의 소울 이터는 상대 체력을 흡수하는 공격이다. 맵에서는 실제 피해에 비례한 지연 흡수로 각색하며 원작 드라이브 기술을 지급하지 않는다.',uncertain:[]},
 {key:'common_ragna_break',name:'라그나 더 블러드엣지',effectName:'정면 돌파',keyword:'공통 · 방향 · 관통',grade:2,effects:[{stat:'directional_damage',value:16},{stat:'penetration',value:6}],evolution:{kind:0,goal:0,effects:[]},canonFact:'라그나가 거칠게 정면을 돌파하는 성향을 기존 헤드·백 적중과 방어 관통 준비로 각색했다. 새로운 연속 기술이나 회피 행동을 지급하지 않는다.',uncertain:[]}
);
const c=(label,result,card=null,v={})=>({label,result,card,card2:null,gold:0,cost:0,level:0,density:0,potions:0,chance:100,...v});
data.events.push(
 {key:'common_torn_poster',title:'얼굴이 지워진 수배서',story:'막힌 길의 안내판에 찢어진 수배서가 붙어 있다. 그림과 닮은 남자가 종이를 구겨 주머니에 넣고, 짐이 쌓인 쪽을 보며 길부터 비우라고 말한다. 라그나의 칼이 지나갈 앞길을 맡을지, 옆에서 틈을 살필지, 사람들을 다른 길로 보낼지 정해야 한다.',intro:'수배서 속 얼굴과 닮은 남자가 막힌 길 앞에서 칼을 고쳐 쥔다.',previous:null,previousChoice:0,requiredCard:null,choices:[
  c('라그나와 막힌 길의 앞쪽을 맡는다','라그나가 짐이 지나갈 틈을 먼저 열었다. 검이 닿은 뒤에도 움직임을 끊지 않는 모습을 따라 보지만, 길 끝에 남은 큰 흔적까지 맡아야 한다.','common_ragna_eater',{level:1}),
  c('옆길의 짐을 묶고 칼이 닿을 자리를 살핀다','운반 끈을 바꿔 짐을 옆으로 옮기자 라그나의 칼이 들어갈 각도가 보였다. 좁은 옆길을 쓰는 동안 그쪽으로 더 많은 흔적이 모였다.','common_ragna_break',{cost:220,density:1}),
  c('사람들이 돌아갈 우회로를 알린다','수배서는 접어 두고 안내판의 화살표를 돌렸다. 보급 담당자가 수고비와 약품을 건넸고, 한곳에 몰렸던 사람들이 다른 길로 흩어졌다.',null,{gold:180,potions:1,density:-1})
 ],failure:null,canonFact:'수배자이며 정면 돌파를 자주 하는 라그나의 소개를 참고했다. 길을 막은 짐과 보급 담당자는 맵 창작이고 원작의 고액 현상금을 받는 사건이 아니다.',uncertain:[]},
 {key:'common_lowered_blade',title:'갈림길 앞에서 내린 검',story:'앞길을 맡은 뒤 라그나가 갈림길에서 잠깐 검을 내렸다. 짐을 통과시키기에는 폭이 모자라지만, 뒤쪽에는 사람들을 돌려보낼 보급 담당자가 도착했다. 좁은 길을 손봐 다시 칼이 들어갈 각도를 찾을지, 큰 흔적을 피해 보급품을 먼저 옮길지 정할 수 있다.',intro:'라그나가 좁은 갈림길을 보고 검을 내린다.',previous:'common_torn_poster',previousChoice:1,requiredCard:null,choices:[
  c('좁은 길을 손보고 라그나와 각도를 다시 잡는다','새 지지대로 짐을 묶어 옆으로 밀었다. 라그나는 비워진 길에서 칼을 다시 들었고, 돌아갈 때는 같은 병목에 멈출 필요가 줄었다.','common_ragna_break',{cost:240,density:-1}),
  c('큰 흔적을 피해 보급품을 담당자에게 옮긴다','보급 담당자에게 짐을 인계하고 위험한 갈림길을 닫았다. 약품과 운반비를 받은 뒤, 큰 흔적을 따라가려던 길 대신 돌아갈 길을 택했다.',null,{gold:230,potions:2,level:-1})
 ],failure:null,canonFact:'거친 행동과 달리 근본적으로 악인이 아니라는 공식 소개를 참고한 공동 통행 사건이다. 칼의 각도·보급품 인계는 맵 창작이고 실제 NPC 전투·원작 장소 이동을 추가하지 않는다.',uncertain:[]}
);
fs.writeFileSync(path.join(__dirname,'ragna-common-candidate-06.json'),JSON.stringify({cards:data.cards.slice(-2),events:data.events.slice(-2)},null,2)+'\n',{flag:'wx'});
fs.writeFileSync(file,JSON.stringify(data,null,2)+'\n');
console.log('라그나 카드 2종과 공통 사건 2개를 역검토 후보로 추가했습니다.');
