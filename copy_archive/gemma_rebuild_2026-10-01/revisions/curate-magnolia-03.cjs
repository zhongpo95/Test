// Gemma 재작성의 문제를 기록한 뒤 마그놀리아 서사·손익을 대조해 활성 후보를 만든다.
const fs=require('node:fs'),path=require('node:path');
const base=path.resolve(__dirname,'..'),root=path.resolve(base,'../..');
const world=JSON.parse(fs.readFileSync(path.join(__dirname,'magnolia-plan-02.json'),'utf8'));
const draft=JSON.parse(fs.readFileSync(path.join(base,'drafts/magnolia-text-02.json'),'utf8')).parsed;
if(draft.events.length!==world.events.length)throw Error('사건 누락');
for(const e of world.events){const d=draft.events.find(x=>x.key===e.key);if(!d||d.choices.length!==e.choices.length)throw Error(e.key+' 참조·행동 누락');e.intro=d.intro;}
const keywords=['이동','공격 · 일반 몬스터','탐색 · 수급','차지 · 비방향','방향 · 치명','체력 · 보호막','재생 · 공격','고체력 · 생존','공격 · 최종 대미지'];
world.cards.forEach((c,i)=>c.keyword=keywords[i]);
const result={
 ft_request_board:[
  '나츠가 목재를 들고 달려갈 틈을 만들었다. 넓게 열린 길 저편에서 큰 짐승이 고개를 들었지만, 나츠는 주먹을 맞대며 먼저 움직일 곳을 짚어 준다.',
  '루시와 영수증을 대조해 빠진 주소를 채웠다. 복사할 종이와 운반 표식을 마련하자, 엉킨 의뢰를 하나씩 구분할 수 있게 됐다.',
  '샤를이 같은 자리에서 끊기는 발자국을 짚었다. 안전한 길을 고르려면 먼저 모여 있는 짐승들의 움직임부터 읽어야 했다.',
  '가려져 있던 길목을 치우고 의뢰서를 다시 걸었다. 길드에서 정리한 보급품을 받아 들자, 비로소 무엇부터 맡을지 둘러볼 여유가 생겼다.'
 ],
 ft_timber:[
  '그레이와 받침대를 세우고 접근할 수 있는 틈을 줄였다. 얼음을 단순히 크게 만드는 것보다 놓일 형태를 먼저 고르는 이유를 배웠다.',
  '웬디에게 맡길 자리를 정리하고 마른 천과 보급품을 마련했다. 돌아온 사람들을 재촉하기보다 다음 일을 버틸 준비를 함께 했다.'
 ],
 ft_receipt:[
  '방어물을 기다리는 수령인의 주소가 맞다는 것을 확인했다. 엘자와 필요한 짐만 나눠 들고 불필요하게 열려 있던 길 하나를 정리했다.',
  '위험한 길목에 남아 있는 의뢰인을 먼저 찾아갔다. 엘자는 앞만 보며 밀어붙이지 말라며, 검이 닿을 자리를 함께 확인했다.',
  '한쪽은 발주서, 다른 쪽은 보관용 사본이었다. 루시와 엉킨 짐을 바로잡고, 헛걸음을 막아 준 수고비와 남은 보급품을 받았다.'
 ],
 ft_fish:[
  '해피에게 생선 봉지를 따로 맡기고 웬디와 보급품을 작은 묶음으로 나눴다. 복잡하게 오가던 짐이 정리되자 길목도 한산해졌다.',
  '해피가 들지 못한 짐을 맡아 엘자와 지상으로 돌아왔다. 숲 가장자리의 큰 짐승을 피해 몸을 돌리는 동안, 무게보다 자세를 먼저 잡는 법을 배웠다.'
 ],
 ft_new_board:[
  '그레이와 좁은 통로에 맞는 받침대와 표식을 마련했다. 사람이 지나갈 틈을 남기는 것과 공격할 공간을 남기는 것은 다른 문제였다.',
  '돌아오는 사람들의 짐이 멈추지 않도록 엘자와 넓은 길목을 맡았다. 여러 짐승이 몰렸지만, 엘자는 흩어진 움직임 속에서도 검을 뻗을 간격을 놓치지 않았다.'
 ],
 ft_armory:[
  '엘자는 먼저 검을 뽑아 볼 공간부터 남기라고 했다. 짐을 덜어 내고 훈련 도구를 마련하자 발끝과 칼끝의 간격을 함께 볼 수 있었다.',
  '엘자와 갑옷을 갖춰 입는 순서와 몸을 돌릴 자리를 확인했다. 무조건 더 챙기기보다 지금 지킬 수 있는 자세에 맞춰 짐을 골랐다.',
  '웬디가 오래 버틸 준비에 필요한 물품을 짚어 줬다. 급히 출발하려던 짐을 다시 펴고, 돌아올 때까지 이어 쓸 보급을 나눠 담았다.'
 ],
 ft_river:[
  '그레이가 만든 조형물을 붙잡아 물살 사이에 통로를 냈다. 건너편에 모인 짐승까지 감수하고 짐을 전달하자, 기다리던 사람이 수고비를 내밀었다.',
  '웬디와 짐을 나눠 마른 길로 돌아왔다. 새 운반 도구를 준비하는 데 비용은 들었지만, 엉킨 통로를 정리하고 남은 보급품도 챙겼다.'
 ],
 ft_wet_receipt:[
  '루시와 마른 종이에 읽히는 부분부터 옮겨 적었다. 연락과 운반에 필요한 비용을 보태자, 남은 짐을 보낼 주소를 다시 찾을 수 있었다.',
  '웬디와 쓸 수 있는 물품을 골라 묶었다. 길을 어지럽히던 젖은 포장을 치우고, 돌아갈 때 사용할 보급만 남겼다.'
 ],
 ft_controlled_flame:[
  '짐에서 떨어진 곳에 가림막과 훈련 도구를 마련했다. 나츠를 따라 한 번의 일격에 힘을 모았지만, 커진 소리를 듣고 큰 짐승이 다가오기 시작했다.',
  '엘자는 옆의 짐을 건드리지 않고 검을 멈춰 보라고 했다. 훈련 도구를 마련해 다시 간격을 맞추자, 힘을 더 싣기 전에 볼 자리를 찾았다.'
 ]
};
for(const e of world.events)e.choices.forEach((b,i)=>b.result=result[e.key][i]);
world.events.find(e=>e.key==='ft_fish').story='해피가 수송할 짐 옆에서 생선 봉지를 발견했다. 모두 가져가고 싶다는 말에 샤를은 짐의 무게부터 보라고 한다. 엘자와 웬디가 도울 준비를 하는 동안, 짐을 나눠 보내거나 지상 운반을 맡을 수 있다.';
world.events.find(e=>e.key==='ft_armory').story='엘자는 여행 가방을 금세 닫았지만, 내 짐은 아직 바닥에 널려 있다. 무구를 환장하는 엘자와 달리 나는 다 들고 갈 수 없다. 엘자는 검을 잡을 공간부터 남기라 하고, 웬디는 오래 버틸 준비를 권한다.';
world.events.find(e=>e.key==='ft_armory').intro='가볍게 떠나는 엘자 옆에서 아직 바닥에 널린 내 짐을 고른다.';
world.events.find(e=>e.key==='ft_wet_receipt').story='빠른 물길에서 짐이 젖은 뒤 루시가 번진 글씨를 살피고 있다. 원래 받는 사람을 찾아 남은 짐을 보내거나 웬디와 젖은 물품부터 정리할 수 있다. 어느 쪽이든 흠뻑 젖은 포장을 그대로 둘 수는 없다.';
const facts={
 ft_request_board:'공식 285화의 마그놀리아 재건과 게임의 의뢰 게시판을 장소의 소재로 삼았다. 뒤섞인 의뢰서·짐과 플레이어의 개입은 창작이다.',
 ft_timber:'그레이의 조형마법, 웬디의 지원·치유 역할을 활용했다. 목재의 용도와 복귀자의 보급 문제는 창작이다.',
 ft_receipt:'길드에서 의뢰를 받고 보고하는 구조와 루시의 기록 역할을 참고했다. 잘못 분류한 사본과 수령인 문제는 창작이다.',
 ft_fish:'해피의 비행과 생선을 좋아하는 성격, 샤를·웬디의 동료 관계를 참고했다. 실제 운반량·수송 사건은 창작이다.',
 ft_new_board:'길드 의뢰 게시판을 다시 활용하는 후속이며 그레이의 조형·엘자의 무구 준비 역할을 사용했다. 원작 특정 의뢰 재현은 아니다.',
 ft_armory:'엘자가 무구를 별도 공간에서 환장한다는 소개를 활용한 짐 정리 사건이다. 플레이어에게 환장이나 원작 갑옷을 지급하지 않는다.',
 ft_river:'그레이의 얼음 조형과 웬디의 지원을 활용한 물길 사건은 창작이다. 실제 보조 유닛·다리·수송 시스템을 구현한다고 주장하지 않는다.',
 ft_wet_receipt:'물길 선택 실패를 자기 기록으로 이어 받는 창작 후속이다. 루시는 기록을, 웬디는 보급 준비를 돕는다.',
 ft_controlled_flame:'나츠의 열정과 동료를 생각하는 성격, 엘자의 검·무구 준비를 각색했다. 원작 고유 기술이나 실제 NPC전투를 지급하지 않는다.'
};
for(const e of world.events)e.canonFact=facts[e.key];
const {inspect}=require(path.join(root,'tools/check-content-candidates.cjs'));
const report=inspect(world);if(report.errors.length)throw Error(JSON.stringify(report));
fs.writeFileSync(path.join(__dirname,'magnolia-curated-03.json'),JSON.stringify(world,null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(root,'content/roguelite/09-magnolia.json'),JSON.stringify(world,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify(report));
