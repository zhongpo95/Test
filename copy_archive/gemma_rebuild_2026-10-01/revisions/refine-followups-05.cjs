// 직전 보상이 반복되는 후속과 보상 안내가 섞인 이야기를 보존한 뒤 다듬는다.
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'../../..'),dir=path.join(root,'content/roguelite');
const texts={
 '01-fuyuki.json':{
  school_circle:['학교 안쪽에 남은 술식의 연결을 린과 끊었다. 사람을 붙잡아 둘 이유가 사라졌지만, 남은 흔적은 아직 복도 저편으로 이어져 있었다.','시로와 학생들을 밖으로 안내하며 막힌 문을 하나씩 열었다. 근원을 건드리지는 못해, 뒤에서 다가오는 기척도 함께 경계해야 했다.','린에게 찾은 기록을 넘기고 학생들이 빠져나올 길을 정리했다. 복도에 몰리던 기척이 흩어지고 응급 물약도 챙길 수 있었다.'],
  school_circle_trace:['시로와 남은 흔적을 따라 술식이 놓인 형태를 확인했다. 그대로 따라 만들기보다 어디에 힘이 모이는지 살펴보기로 했다.','아처는 눈앞의 흔적만 보고 깊이 들어가지 말라고 했다. 무리한 돌파를 멈추고, 큰 상대와 마주할 때 볼 자리를 다시 짚었다.','더 깊이 들어가는 대신 찾은 기록을 정리해 넘겼다. 확인에 필요한 수고비를 받고 다음 조사를 준비했다.'],
  saber_practice:['세이버는 검을 세우기 전에 돌아설 자리를 보라고 했다. 흩어진 상대부터 정리한 뒤 지켜야 할 간격을 다시 맞췄다.','세이버의 검이 움직이기 전에 발끝이 어디를 향하는지 살폈다. 넓은 자리에서 여러 상대를 받아들여 간격이 무너지는 순간까지 익혔다.','집으로 돌아와 사쿠라와 식사를 준비했다. 서두르던 일을 잠시 내려놓고 다시 움직일 준비를 했다.'],
  temple_gate:['산문 앞에서 검이 닿는 거리를 살폈다. 머무는 동안 뒤로 몰리는 기척이 늘었지만, 한 걸음이 공격 간격을 바꾸는 순간을 놓치지 않았다.','캐스터가 건네는 마력의 흐름을 받아들였다. 힘을 끌어오는 방법은 얻었지만, 그것을 감당할 부담까지 사라진 것은 아니었다.','경계를 넘지 않고 바깥의 길부터 정리했다. 발길이 엉키지 않게 만든 뒤 돌아갈 보급을 챙겼다.']
 },
 '02-axel.json':{
  axel_request:['카즈마와 몬스터 수가 많은 의뢰를 골랐다. 서류의 수고비부터 확인했지만, 약속된 자리에는 상대해야 할 무리도 더 기다리고 있었다.','크리스와 혼잡한 길을 빠져나갈 순서를 맞췄다. 필요한 도구를 준비하고, 손이 먼저 갈 곳과 몸을 뺄 곳을 나눠 봤다.','다른 모험가들이 맡을 몫을 나누고 주변 길을 정리했다. 비용은 들었지만 홀로 모든 무리를 받아낼 필요는 없어졌다.'],
  axel_stolen_notice:['크리스와 사라진 게시물의 흔적을 따라갔다. 물건을 되찾는 데 급급하기보다 누가 지나갔는지부터 구분했다.','카즈마와 수고비가 적힌 부분부터 대조했다. 더 위험한 길을 맡아야 한다는 것을 확인하고도 이번에는 직접 나서기로 했다.','크리스의 수색을 도우며 위험한 길목을 비웠다. 더 강한 상대가 드나들던 길을 정리하고 돌아올 준비를 했다.'],
  axel_blast_site:['메구밍이 가리킨 자리에서 폭렬 마법의 여파를 살폈다. 주변까지 끌어들일 만큼 큰 힘에는 빈틈도 남는다는 것을 배웠다.','위즈에게 비용을 내고 마도구의 출력을 차례로 확인했다. 큰 폭발을 쫓기보다 손에 맞는 준비부터 다시 고른다.','마법이 닿을 자리 밖으로 사람과 짐을 옮겼다. 뒤엉키던 길목을 비우고 남은 보급을 챙겼다.'],
  axel_shop_ledger:['위즈와 납품 기록을 맞춰 보며 도구를 확인했다. 장부에 이름만 남아 있던 물건을 실제 용도대로 나누었다.','바니르와 계산을 맞추다 까다로운 납품까지 맡게 됐다. 겉으로 보이는 이익만 믿지 말라는 말을 듣고, 큰 상대에게 들이밀 자리를 다시 고른다.','창고의 짐을 정리해 뒤엉킨 출입구를 비웠다. 일당을 받고 나니, 무슨 물건을 위해 이 자리를 차지하고 있었는지 보였다.'],
  axel_crowded_road:['다크니스의 방어 뒤에서 공격할 자리를 잡았다. 좁은 곳에 몰린 상대까지 맡아야 했지만, 정면에서 버틸 사람이 있다는 차이를 배웠다.','아쿠아가 돌아올 사람을 위한 준비를 할 수 있도록 물품을 마련했다. 길을 서둘러 나서는 대신 보급을 먼저 맞췄다.','길목에 엉킨 짐을 옮기며 한쪽의 흐름을 줄였다. 몰리던 상대가 흩어진 틈에 돌아갈 보급을 챙겼다.']
 },
 '03-abydos.json':{
  abydos_ramen_shift:[null,null,'부족한 재료를 들여오고 주문이 엉킨 통로를 정리했다. 가게에서 나눠 준 보급을 챙기자 밖의 길도 덜 붐볐다.'],
  abydos_blackmarket_map:[null,'시로코와 위험한 길목의 움직임을 살폈다. 큰 상대의 흔적까지 따라간 만큼 돌아오는 길도 더 신중하게 골라야 했다.',null],
  abydos_ramen_repair:['세리카와 잔해 사이에서 남은 도구를 골랐다. 모여드는 상대를 살피면서도, 쉬던 교대 때와 달리 지킬 자리가 있다는 것을 기억했다.',null,'가게 주인에게 물품을 전달할 길을 만들었다. 강한 상대가 드나들던 길목을 비우고 병문안 짐과 함께 응급 물약을 챙겼다.'],
  abydos_desert_watch:[null,null,'깊이 들어가지 않고 되돌아올 통로부터 정리했다. 큰 상대의 흔적이 이어지는 길을 피해 보급품을 옮겼다.'],
  abydos_missing_senior:['시로코와 남겨진 단서를 따라 돌아올 길을 이었다. 앞을 막는 강한 상대를 감수하며 호시노가 돌아올 자리를 준비했다.',null,'학교에 남아 돌아오는 사람을 맞을 지점을 정리했다. 여러 길에 흩어져 있던 보급을 모으고 경계할 통로도 줄였다.']
 },
 '04-academy.json':{
  academy_urban_rumor:[null,null,'사람들을 안내하며 골목을 비웠다. 수고비를 받아 들고 돌아보니 서로 엉키던 발길도 한쪽으로 정리되어 있었다.'],
  academy_second_route:['새 통로를 확인하고 우이하루에게 위치를 전달했다. 더 많은 상대가 오가는 길을 맡는 동안, 다음 연락을 기다리기보다 필요한 정보를 먼저 주고받았다.',null,'쿠로코와 현장 장비를 준비하고 연락이 들어왔을 때 움직일 순서를 맞췄다. 길을 빠르게 건너는 데서 그치지 않고 도착한 자리에서 할 일을 확인했다.']
 },
 '05-mitakihara.json':{
  madoka_mentor_return:[null,'마도카와 돌아올 길의 표식을 다시 맞췄다. 준비할 물품을 마련하고, 서로 엇갈리지 않도록 찾을 자리를 끝까지 들어 뒀다.',null]
 },
 '07-zegagrande.json':{
  gbf_return_signal:[null,'라캄과 귀환 신호를 맞추고 필요한 자재를 준비했다. 열어 둘 길과 닫을 길을 구분한 뒤, 연락이 왔을 때 움직일 순서를 다시 익혔다.',null]
 }
};
for(const [file,updates] of Object.entries(texts)){
 const source=path.join(dir,file),bytes=fs.readFileSync(source);
 fs.writeFileSync(path.join(__dirname,file.replace('.json','-before-followup-05.json')),bytes,{flag:'wx'});
 const w=JSON.parse(bytes);
 for(const [key,results] of Object.entries(updates)){
  const e=w.events.find(e=>e.key===key);if(!e||e.choices.length!==results.length)throw Error(key+' 행동 수 불일치');
  results.forEach((r,i)=>{if(r)e.choices[i].result=r;});
 }
 if(file==='03-abydos.json'){
  w.cards.push({key:'abydos_serika_return',name:'쿠로미 세리카',effectName:'다시 열 가게를 위해',keyword:'고체력 · 수급',grade:2,effects:[{stat:'healthy_damage',value:12},{stat:'kill_gold',value:1}],evolution:{kind:1,goal:40,effects:[{stat:'attack_percent',value:5}]},canonFact:'시바세키 라멘에서 아르바이트하는 세리카의 역할과 가게 복구를 돕는 창작 사건을 연결했다. 멀쩡히 일을 이어 갈 준비를 고체력·수급으로 각색하며 원작 신규 능력이라고 주장하지 않는다.',uncertain:[]});
  w.events.find(e=>e.key==='abydos_ramen_repair').choices[0].card='abydos_serika_return';
 }
 if(file==='04-academy.json'){
  w.cards.push({key:'academy_kuroko_response',name:'시라이 쿠로코',effectName:'현장에서 정할 다음 행동',keyword:'행동 · 생존',grade:2,effects:[{stat:'action_speed',value:6},{stat:'damage_reduction',value:4}],evolution:{kind:0,goal:0,effects:[]},canonFact:'저지먼트에서 현장을 맡는 쿠로코의 역할을 즉응·방어 준비로 각색했다. 입문 공간 이동 요령과 다른 후속이며 실제 순간이동은 지급하지 않는다.',uncertain:[]});
  const e=w.events.find(e=>e.key==='academy_second_route');e.choices[2].card='academy_kuroko_response';e.choices[2].label='쿠로코와 현장 대응 순서를 점검한다';
  e.story='현장에 들어간 쿠로코가 처음 보지 못한 통로를 알려 왔다. 우이하루와 백업 통신을 연결할지, 위험한 길 하나를 닫을지, 쿠로코와 도착한 자리에서 할 일을 정할지 고른다. 더 많은 길을 맡으면 오가는 상대도 늘어난다.';
 }
 if(file==='05-mitakihara.json'){
  w.events.find(e=>e.key==='madoka_mentor_return').choices[1].card='madoka_resolve';
 }
 if(file==='07-zegagrande.json'){
  w.cards.push({key:'gbf_rackam_signal',name:'라캄',effectName:'끊기지 않는 귀환 신호',keyword:'신속 · 고체력',grade:2,effects:[{stat:'swift',value:180},{stat:'healthy_damage',value:12}],evolution:{kind:0,goal:0,effects:[]},canonFact:'기공정 조타수인 라캄의 항로·귀환 역할을 신속과 체력을 유지한 준비로 각색했다. 입문 항로 점검과 다른 후속이며 실제 항로·교신 조작 기능은 지급하지 않는다.',uncertain:[]});
  w.events.find(e=>e.key==='gbf_return_signal').choices[1].card='gbf_rackam_signal';
 }
 fs.writeFileSync(source,JSON.stringify(w,null,2)+'\n');
}
console.log('6작품 서사 정리와 4후속의 확정 중복 보상 수정. 카드3종 추가.');
