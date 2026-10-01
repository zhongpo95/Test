// 선택한 행동·인물·보상과 어긋난 사건 문장을 수정하고 원문·판단 근거를 보존한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'../../..'),log=[];
const files=['01-fuyuki.json','02-axel.json','03-abydos.json','04-academy.json','05-mitakihara.json','06-aincrad.json','07-zegagrande.json'];
const loaded=new Map();
for(const f of files){const p=path.join(root,'content/roguelite',f),raw=fs.readFileSync(p);fs.writeFileSync(path.join(__dirname,f.replace('.json','-before-semantic-08.json')),raw,{flag:'wx'});const w=JSON.parse(raw);loaded.set(f,{p,w,original:structuredClone(w)});}
function change(f,key,choice,field,value,reason){const {w}=loaded.get(f);const e=w.events.find(e=>e.key===key);assert(e,key);const target=choice?e.choices[choice-1]:e;const before=target[field];if(before===value)return;target[field]=value;log.push({file:f,key,choice,field,before,after:value,reason});}
function result(f,key,choice,value,reason){change(f,key,choice,'result',value,reason);}
const f='01-fuyuki.json';
change(f,'school_circle',3,'label','술식 기록을 넘기고 대피 통로를 정리한다','사냥터의 인원이라는 구현 용어를 사건 안 행동으로 바꾼다.');
change(f,'school_circle_trace',0,'title','서로 다른 마력의 흔적','학교 결계와 캐스터의 사건을 한 술식으로 연결하지 않는다.');
change(f,'school_circle_trace',0,'story','학교의 기록을 정리한 린이 가스 누출 사고 현장에 남은 다른 마력 흔적을 보여 준다. 아처는 그 흔적에 이끌려 깊이 들어가기보다 다음 큰 전투에 대비하라고 한다. 현장을 더 살필지, 아처에게 상대를 관찰할 자리를 물을지 정한다.','공식 인물 소개에서 학교 결계는 라이더, 공식 4화 개요에서 가스 누출 잔재는 캐스터의 일이다. 후속은 조사 준비의 연결이다.');
change(f,'school_circle_trace',0,'intro','학교 조사 뒤 린이 따로 찾아낸 흔적. 추적과 다음 전투의 준비 중 하나를 맡는다.','서로 다른 근원을 연결한 소개를 수정한다.');
change(f,'school_circle_trace',0,'canonFact','학교 조사와 가스 누출 현장에 남은 캐스터의 흔적은 공식 소개 및 4화 개요에서 별도로 확인했다. 학교 선택 뒤 다른 조사 준비가 열린다는 연결과 플레이어의 개입은 맵 창작이다.','학교 결계의 원작 근원을 캐스터로 잘못 읽지 않게 한다.');
result(f,'school_circle_trace',1,'아처와 현장 바깥에서 상대를 볼 자리를 골랐다. 무작정 따라 들어가는 대신 공격을 받아 낼 위치와 되돌아설 순간을 나눠 짚었다.','아처의 전투 준비 선택에 시로의 술식 해석 결과가 붙어 있었다.');
result(f,'school_circle_trace',2,'린과 골목 안쪽에 남은 마력의 집중점을 확인했다. 흐름을 읽을 단서는 얻었지만 더 강한 기척이 남은 구간까지 맡게 되었고, 그 힘을 운용하는 부담도 가볍지 않았다.','현장 해석 선택인데 아처와 돌파를 멈췄다고 쓰고 추가 위험을 숨겼다.');
result(f,'saber_practice',2,'세이버가 속도를 높이자 검끝을 쫓던 발이 먼저 흐트러졌다. 더 빠른 한 상대를 받아들이며 칼이 지나간 뒤 다시 파고들 자리를 반복해서 맞췄다.','적 단계 증가를 여러 상대를 받아들이는 적 수 증가처럼 표현했다.');
result(f,'temple_gate',2,'세이버가 검술가의 칼을 받아내는 동안 옆으로 설 자리를 골랐다. 필요한 준비물을 마련하고 서로의 검이 겹치지 않는 간격을 맞추자, 정면 돌진으로는 보이지 않던 틈이 드러났다.','세이버의 검술 선택 결과가 캐스터의 마력 수령이었다.');
const a='02-axel.json';
result(a,'axel_request',2,'다크니스와 강한 몬스터가 남은 의뢰를 맡았다. 그녀는 앞에서 버틸 자리를 반겼고, 당신은 빗나가는 검에 기대기보다 빈틈이 생길 때 움직일 위치를 골랐다. 돌아오는 길에도 강한 상대를 경계해야 한다.','다크니스 의뢰에 크리스의 수색 결과가 붙어 있었다.');
result(a,'axel_stolen_notice',2,'카즈마와 완료한 의뢰의 번호를 대조해 길드에 명세서 재발행을 요청했다. 루나가 기록을 확인하고 빠져 있던 보수를 건넸다.','필드 변화가 없는데 더 위험한 새 의뢰를 맡았다고 서술했다.');
change(a,'axel_blast_site',0,'story','메구밍이 오늘 사용할 폭렬 마법의 장소를 찾는다. 당신의 사냥터 근처에는 무너져도 되는 빈 암벽이 있지만, 큰 소리에 강한 몬스터까지 접근할 수 있다. 위즈는 안전 거리를 계산해 주겠다고 한다.','적 수 대신 적 단계가 오르는 실제 위험에 맞춘다.');
result(a,'axel_blast_site',1,'암벽을 뒤흔드는 메구밍의 폭렬을 보고 한 번에 힘을 모으는 박자를 익혔다. 큰 소리에 더 강한 상대의 기척도 다가왔고, 큰 힘을 쓴 뒤 곧바로 다음 동작을 잇기는 어려웠다.','단계 증가와 메구밍 카드의 행동 속도 패널티를 행동 결과에 연결한다.');
result(a,'axel_crowded_road',2,'크리스와 장비를 마련하고 몬스터가 한꺼번에 몰리지 않도록 통로를 나눴다. 적은 수를 마주하는 동안 몸을 빼며 옆을 잡을 자리를 확인했다.','크리스 선택에 아쿠아의 보급 결과가 붙어 있었다.');
result(a,'axel_crowded_road',3,'다크니스가 버티는 앞쪽을 살피며 뒤에서 짐을 옮길 사람들을 호위했다. 맡은 구간을 넘기고 보수와 응급 물약을 받았지만, 몰린 상대가 사라진 것은 아니다.','적 수가 줄지 않는데 상대가 흩어진다고 썼다.');
const b='03-abydos.json';
result(b,'abydos_missing_senior',1,'노노미와 남은 기록을 대조해 호시노가 돌아올 길을 표시했다. 엄호할 자리를 넓히는 동안 강한 상대의 기척도 확인했다. 구출은 아직 끝나지 않았지만 수색대가 다음에 확인할 구간을 남겼다.','노노미의 구조 준비에 시로코가 대신 등장했다. 구출 완료라고 단정하지 않는다.');
const c='04-academy.json';
result(c,'academy_bad_signal',2,'쿠로코와 현장에 들어가 끊긴 신호의 위치를 찾았다. 빠르게 도착하는 데서 그치지 않고 물러날 공간까지 짚었지만, 안쪽에는 더 강한 상대가 기다리고 있었다.','도착만 쓰고 추가 위험을 빼거나 신규 기동 스킬을 배운 듯 표현하지 않는다.');
result(c,'academy_bad_signal',3,'사텐과 가까운 골목의 문을 두드리며 마지막 연락을 들은 사람을 찾았다. 확인할 갈림길이 늘어나 그곳을 오가는 무리까지 맡게 되었지만, 수색 순서를 정할 단서는 모였다.','단순 지형 숙지 대신 구조 신호의 문제와 적 수 증가를 연결한다.');
result(c,'academy_signal_answer',2,'토우마와 구조 대상에게 닿을 통로를 열었다. 사람들을 먼저 내보내고 당신이 뒤쪽을 맡으면서, 더 많은 상대가 남은 구간을 경계할 준비를 했다.','표시되지 않은 방어적 기동 능력 획득을 없애고 남은 적 수 위험을 설명한다.');
result(c,'academy_urban_rumor',1,'조사 장비를 준비해 미코토가 장치의 반응을 살피는 동안 주변 표시를 기록했다. 소문으로 들은 힘을 얻은 것이 아니라 전류가 집중되는 지점과 다가가지 말아야 할 자리를 구분했다.','플레이어가 초능력 제어법을 습득했다는 표현을 없앤다.');
result(c,'academy_coin_test',1,'통로 끝을 맡아 작업자들이 사선에 들어오지 않도록 알렸다. 미코토가 표적을 꿰뚫는 순간을 지켜봤지만, 더 강한 상대가 접근하는 구간까지 계속 지켜야 한다.','플레이어에게 레일건 같은 신규 고위력 집중 타격을 지급하는 것처럼 쓰지 않는다.');
result(c,'academy_no_ability',1,'사텐과 남은 물자를 나르며 골목마다 돌아올 표식을 남겼다. 한 번 더 확인할 길을 맡은 만큼 오가는 무리도 늘었지만, 힘이 없어 멈춰 있던 짐은 목적지에 닿았다.','카드는 이동 속도가 아닌 일반 피해·처치 골드와 후속 각성 신속인데 즉시 기초 이동 능력 증가로 썼다.');
const d='05-mitakihara.json';
result(d,'madoka_parking_seed',2,'사야카와 시민들이 주차장에 들어오지 않게 안내했다. 사람들은 빠져나갔지만 당신은 더 많은 기척이 모인 경계를 맡아 마미가 돌아올 길을 지켜야 했다.','시민 보호가 남은 몬스터 위험까지 제거한 듯 쓰지 않는다.');
result(d,'madoka_mentor_return',1,'마미와 사격할 자리와 물러날 길을 함께 표시했다. 먼 곳을 볼 위치는 얻었지만 그쪽으로 이어진 강한 기척까지 살펴야 하며, 결계 안의 일은 아직 끝나지 않았다.','좋은 위치를 잡았다는 말만 남기고 단계 증가와 결계 위험을 지웠다.');
result(d,'madoka_familiar_trace',3,'쿄코와 놓친 흔적이 갈라지는 길을 나눠 살폈다. 한 구역만 찾을 때보다 확인할 상대가 늘었지만, 어느 길에서 긴 창의 간격을 확보할지 판단할 수 있었다.','효율적인 수색이라는 결과에 적 수 +2의 부담이 없었다.');
const e='06-aincrad.json';
result(e,'sao_companion_herb',2,'클라인과 앞쪽 몬스터의 주의를 끌어 시리카가 지나갈 틈을 만들었다. 당신이 맡은 갈림길로는 더 많은 상대가 모여들어, 동료가 꽃을 가져올 때까지 그 자리를 버텨야 한다.','유도로 동료를 돕지만 플레이어는 적 수 +2를 감수한다는 관계를 분명히 한다.');
result(e,'sao_companion_herb',3,'키리토와 위험한 길을 먼저 살펴 시리카가 피해야 할 구간을 표시했다. 강한 상대의 위치를 알아냈지만 당신이 맡은 길에서 그 상대를 감수할 준비도 필요하다.','정찰로 안전한 길을 확보했다고만 써 단계 증가를 감췄다.');
const g='07-zegagrande.json';
result(g,'gbf_deck_position',3,'쓰지 않을 통로 하나를 닫고 남아 있던 물약을 회수했다. 경계할 상대가 줄어든 자리에 장비를 다시 두었다.','실제 효과는 적 수 감소와 물약인데 플레이어 방어력 증가라고 썼다.');
result(g,'gbf_broken_focus',1,'준비 자재를 마련하고 이오가 힘을 모으는 동안 끼어들지 않을 자리를 골랐다. 그녀가 집중을 다시 잇는 박자를 보며, 당신도 공격을 서두르기 전에 호흡을 맞췄다.','이오 카드에는 차지 속도와 고체력 피해가 있고 마력 방어 전환 기술은 없다.');
result(g,'gbf_broken_focus',2,'나루메아와 갈라진 넓은 통로를 맡아 어디서 검의 간격이 무너지는지 살폈다. 접근하는 상대가 더 많아졌으므로 검이 닿지 않는 옆길까지 경계를 이어가야 한다.','접근을 차단했다는 결과가 실제 적 수 증가의 부담을 없앤 듯 읽혔다.');
result(g,'gbf_broken_focus',3,'베인과 동료가 돌아올 길 끝에 지킬 자리를 정했다. 빠져나오는 사람들의 길은 남겼지만 당신이 맡은 바깥에는 더 강한 상대의 기척이 이어졌다.','귀환 준비와 플레이어가 남길 단계 증가 부담을 함께 적는다.');
result(g,'gbf_return_signal',3,'자재를 마련해 강한 상대가 드나드는 입구 하나를 봉쇄했다. 남은 물약을 챙기고 다른 길로 귀환 준비를 이어갔다.','완전한 적 접근 차단이 아닌 적 단계 감소와 실제 물약 지급을 서술한다.');
function signature(w){return JSON.stringify({world:((x)=>{delete x.intro;delete x.name;delete x.work;return x})(structuredClone(w.world)),cards:w.cards,events:w.events.map(e=>({...e,title:undefined,story:undefined,intro:undefined,canonFact:undefined,choices:e.choices.map(b=>({...b,label:undefined,result:undefined}))}))});}
for(const {p,w,original} of loaded.values()){assert.equal(signature(w),signature(original),'문장 수정에서 능력치·조건·확률은 바꾸지 않는다.');fs.writeFileSync(p,JSON.stringify(w,null,2)+'\n');}
fs.writeFileSync(path.join(__dirname,'semantic-curation-08.json'),JSON.stringify({changes:log,mechanicsUnchanged:true,sources:['https://www.fate-sn.com/ubw/chara/','https://www.aniplex.co.jp/lineup/fate-sn-ubw/story/','https://konosuba.com/3rd/character/','https://toaru-project.com/railgun_t/chara/mikoto.html']},null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({changedFields:log.length,events:new Set(log.map(x=>x.key)).size,choices:new Set(log.filter(x=>x.choice).map(x=>x.key+':'+x.choice)).size,mechanicsUnchanged:true}));
