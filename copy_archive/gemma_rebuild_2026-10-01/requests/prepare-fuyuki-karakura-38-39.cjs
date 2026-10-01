// 후유키의 창병 조우와 카라쿠라의 가족·점원·약속 사건을 고정 분기로 집필한다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const f=(stat,value)=>({stat,value}),none={kind:0,goal:0,effects:[]};
const c=(key,name,effectName,keyword,effects,canonFact,evolution=none)=>({key,name,effectName,keyword,grade:2,effects,evolution,canonFact,uncertain:[]});
const b=(action,card=null,cost=0,level=0,density=0,gold=0,potions=0,chance=100)=>({action,card,card2:null,cost,level,density,gold,potions,chance});
function prepare(name,id,pitchId,accepted,cards,events,learning,extraRules){
 const pitches=read('drafts/'+name+'-pitches-'+pitchId+'.json').parsed.pitches;
 const sourceFacts=read('requests/'+name+'-pitches-'+pitchId+'.json').brief.sourceFacts;
 write('revisions/'+name+'-pitches-selection-'+pitchId+'.json',{source:'drafts/'+name+'-pitches-'+pitchId+'.json',items:pitches.map(p=>({...p,decision:accepted.includes(p.key)?'구체적인 장면으로 재설계 후 집필':'폐기',reason:accepted.includes(p.key)?'인물의 요구와 실제 플레이어 행동을 특정해 기존 독립 사건과 다른 장면으로 작성한다.':name==='fuyuki'?'타이가 장비 목록·세이버 대련·신지 동맹은 기존 사건과 중복한다. 린 상담은 관리자 효율로만, 사쿠라 간식은 부담의 동기가 없고, 키레이 정원은 정원사 취향을 덧붙이며, 아처 감시는 NPC 동행 기능을 요구한다.':'우류는 취향이 나쁘다는 사실을 자신감 부족으로 바꿨고 기존 옷수선과 겹친다. 텟사이 시연은 손님의 요구가 막연하고 플레이어의 귀도 설명 능력을 가정한다. 이치고 오해는 누가 무엇을 오해했는지 모호하고 축제는 인물 없는 동선 최적화다.',revisit:'구체적 발단·인물의 요구·선택 뒤 반응이 있고 기존 사건과 다른 문제인 경우, 공식 근거와 창작을 나누어 새 초안으로 검토한다.'}))});
 const schema=read('requests/magnolia-expansion-text-28.json').schema;
 schema.properties.events.minItems=events.length;schema.properties.events.maxItems=events.length;
 write('requests/'+name+'-expansion-fixed-'+id+'.json',{cards,events,sourceFacts});
 write('requests/'+name+'-expansion-text-'+id+'.json',{review:false,schema,system:'한국어 사건 작가다. key와 선택 순서를 유지한다. story3문장·intro1문장·각result2~3문장으로 실제 인물의 요구와 반응을 쓴다. expectedSuccess의 비용·배운 카드 효과·골드·물약·개인 적 강함/수를 빠짐없이 구분한다. 원작 대사를 인용하지 않으며, 효율·최적·깊은신뢰라는 추상적 평가로 끝내지 않는다.',brief:{sourceFacts,events:events.map(e=>({key:e.key,scene:e.scene,choices:e.choices.map(b=>({action:b.action,expectedSuccess:{paidGold:b.cost,learned:b.card?learning[b.card]:null,receivedGold:b.gold,receivedPotions:b.potions,personalEnemyStrengthChange:b.level,personalEnemyCountChange:b.density}}))})),rules:['모든분기는성공100%. currentHP지불·즉시회복·실제NPC동행·새기술·실물보상없음. 무료카드도사건행동력1을소모한다. 물약은소모가아닌획득.0이나null인추가효과를만들지않는다.','단계증가는적이강해지는것이며밀도증가는적수가늘어나는것이다. 개인필드수치는이후계속유지되며감소는하한에서적용되는값으로제한된다.',...extraRules]}});
}
prepare('fuyuki',38,34,['lancer_traveler'],[
 c('fy_lancer_reach','랜서','창끝보다 먼저 움직인 발','방향 · 이동 속도',[f('directional_damage',14),f('move_speed',5)],'세이버와 대등한 창병 영령의 위압적인 간격을 공격 방향과 빠른 발의 성장으로 각색한다. 게이 볼그·필중·창 지급·영령 동행은 없다.',{kind:3,goal:60,effects:[f('penetration',3)]})
],[
 {key:'fy_lancer_crossing',title:'창이 가리키지 않은 쪽',scene:'좁은 길 끝에 선 랜서가 창을 한쪽으로 돌리자 너는 빈 쪽으로 지나갈 수 있다고 생각한다. 뒤에서 지켜보던 세이버는 창끝이 비었다고 발을 둘 자리까지 빈 것은 아니라고 말한다. 랜서는 겁을 주려는지 길을 열어 준 것인지 답하지 않고 네가 먼저 고를 쪽을 본다.',choices:[b('랜서 앞의 간격을 직접 확인하고 더 강한 길목을 맡는다','fy_lancer_reach',0,1),b('180골드로 돌아갈 길의 등불을 마련하고 세이버와 발을 옮긴다','fy_saber_stride',180),b('가까이 다가가지 않고 맡을 길목을 줄인다',null,0,0,-1)],canonFact:'공식 소개의 세이버와 대등한 창병 영령과 세이버의 검술에서 길 위 간격 문제를 창작했다. 랜서의 마스터·진의·원작 승부를 결정하지 않는다. 세이버의 말은 창작이며 실제 검술 대련·영령 동행·원작 기술 전수는 없다.'}
],{fy_lancer_reach:'일격의 방향을 고르고 발을 빠르게 옮기는 요령',fy_saber_stride:'빠른 발과 받는 피해를 줄이는 요령'},['NPC의원작승부·본편진의·마스터정체를결정하지않는다. 랜서는실제로새개인필드에출현하거나보스가되지않는다. 길의선택은플레이어사냥필드단계/밀도만변한다.']);
prepare('karakura',39,35,['bl_karin_whisper','bl_isshin_hospitality','bl_ururu_strength','bl_keigo_promise'],[
 c('bl_karin_distance','쿠로사키 카린','보이지 않아도 비울 자리','이동 속도 · 고체력',[f('move_speed',5),f('healthy_damage',10)],'냉정한 성격과 영감을 지닌 카린에게 다른 이가 보지 못하는 자리를 성급히 채우지 않는 법을 배운다. 영감·유령 시야·사신화·적 탐지 기능을 주지 않는다.'),
 c('bl_isshin_welcome','쿠로사키 잇신','지나친 환영 뒤의 걱정','최대 체력 · 재생',[f('max_health_percent',10),f('regeneration',0.4)],'가족을 과하게 아끼는 의원 운영자의 특징을 오래 버틸 준비로 각색한다. 진료·즉시 치료·사신 능력·물약 무한 공급은 없다.'),
 c('bl_ururu_lift','츠무기야 우루루','가볍게 보지 않을 힘','차지 · 치명타 피해',[f('charge_damage',16),f('crit_damage',14)],'외형과 달리 초인적인 전투 능력이 있는 점원에게 겉모습만 보고 힘을 가늠하지 않는 일격 준비를 배운다. 실제 동행·상자 들기 미니게임·초인화·점원 고용은 없다.',{kind:2,goal:12000,effects:[f('penetration',3)]}),
 c('bl_keigo_invitation','아사노 케이고','아직 묻지 않은 약속','사건 후보 · 행동 속도',[f('event_choices',1),f('action_speed',3)],'이치고를 자주 귀찮게 하는 활발한 동급생의 특징을 약속의 다른 갈래를 묻고 행동을 이어 가는 성장으로 각색한다. 우정 수치·새 일정·NPC 가이드·무한 행동력은 없다.')
],[
 {key:'bl_empty_bench',title:'비어 보이는 벤치',scene:'상점 앞에서 쉬려는 손님을 카린이 벤치의 반대편으로 짧게 부른다. 손님은 아무도 앉지 않은 자리를 왜 비워 두냐고 묻고 카린은 남들이 못 보는 것을 떠들어 봐야 더 시끄러워진다고 한다. 이치고가 옆자리를 내주려 하니 너는 설명을 캐물을지 먼저 자리를 옮길지 고른다.',choices:[b('카린이 비워 둔 자리를 존중하고 옆으로 옮긴다','bl_karin_distance'),b('이치고와 더 강한 길목을 맡아 자리를 비운다','bl_ichigo',0,1),b('손님을 안내하고 맡을 구역을 좁힌다',null,0,0,-1,120)],canonFact:'공식 카린의 냉정함과 영감에서 상점 앞의 창작 만남을 만들었다. 보이지 않는 존재의 정체·본편 사건을 확정하지 않고 플레이어에게 유령 시야를 주지 않는다.'},
 {key:'bl_welcome_at_door',title:'친구가 왔다는 한마디',scene:'이치고를 찾으러 왔다는 말에 잇신이 의원 문 밖까지 나와 반갑게 맞는다. 이치고는 잠깐 물건만 돌려받을 일이라고 말하지만 잇신은 아들과 무슨 일을 같이 했는지부터 묻는다. 유즈가 둘 사이에 설 자리를 내주자 너는 잇신의 걱정을 들을지 이치고의 짧은 용건부터 마칠지 정한다.',choices:[b('180골드로 머무를 준비를 하고 잇신의 걱정을 듣는다','bl_isshin_welcome',180),b('유즈와 손님이 드나들 길목을 더 맡는다','bl_yuzu_portion',0,0,1),b('용건을 먼저 마치고 잇신이 건넨 물약만 받는다',null,0,0,0,0,2)],canonFact:'공식 잇신의 가족 사랑과 과한 응대·유즈의 가사 역할에서 의원 문 앞 환영을 창작했다. 친척 편입·진료 결과·즉시 체력 회복·원작 가족의 비밀을 결정하지 않는다.'},
 {key:'bl_small_shop_clerk',title:'작은 점원에게 맡긴 큰 짐',scene:'우라하라 상점의 손님이 우루루에게 커다란 상자를 밖으로 옮기라며 혼자서는 못 들 것 같다고 비웃는다. 우루루가 상자를 가볍게 들자 진타는 옮겨 달라는 말과 얕보는 말은 다르다고 끼어든다. 손님이 이번에는 더 많은 짐을 밀어 넣으려 하니 네가 어디서 부탁을 멈출지 정한다.',choices:[b('220골드로 받칠 도구를 마련하고 우루루의 힘을 먼저 묻는다','bl_ururu_lift',220),b('차드와 더 많은 길목을 맡고 점원에게 미룬 일을 나눈다','bl_chad',0,0,2),b('추가 부탁을 거절하고 맡을 길목을 줄인다',null,0,0,-1,130)],canonFact:'공식 우루루의 점원 역할과 외형과 다른 초인적 능력에서 큰 심부름의 경계 문제를 창작했다. 차드는 부탁을 나누는 대화 인물이며 플레이어의 상시 동행이 아니다. 실제 상자 운반·노동 게이지·점원 고용은 없다.'},
 {key:'bl_unasked_invitation',title:'초대받았다는 사람',scene:'케이고가 네게 이치고와 마을을 둘러보자고 약속했지만 이치고는 그런 말을 들은 적 없다고 한다. 케이고는 친구라면 같이 갈 줄 알았다고 하고 이치고는 남의 약속을 대신 잡지 말라고 한다. 너는 케이고에게 자기 약속부터 맡기거나 이치고와 가능한 범위를 다시 정할 수 있다.',choices:[b('케이고에게 자신이 한 약속부터 설명하게 한다','bl_keigo_invitation'),b('이치고와 더 강한 구역을 맡을 수 있는 범위를 정한다','bl_ichigo',0,1),b('140골드로 따로 안내를 구하고 우라하라에게 길을 묻는다','bl_urahara',140)],canonFact:'공식 활발하고 이치고에게 자주 말을 거는 케이고와 의리 있는 이치고에서 허락 없는 초대를 창작했다. 실제 동행 경로·방문 타이머·무한 사건·우정 수치·원작 관계 결말은 없다.'}
],{bl_karin_distance:'발을 빠르게 옮기고 좋은 몸 상태에서 일격에 힘을 싣는 요령',bl_ichigo:'공격력과 보스에게 힘을 싣는 요령',bl_isshin_welcome:'최대 체력을 늘리고 몸 상태를 천천히 유지하는 요령',bl_yuzu_portion:'몸 상태를 천천히 유지하고 처치 보수를 늘리는 요령',bl_ururu_lift:'차지 일격과 치명타에 힘을 모으는 요령',bl_chad:'최대 체력을 늘리고 받는 피해를 줄이는 요령',bl_keigo_invitation:'사건의 다른 후보를 더 보고 빠르게 행동을 이어 가는 요령',bl_urahara:'사건의 다른 후보를 더 보고 보스에게 힘을 싣는 요령'},['카린의소란을피하는구체적인말·잇신의방문객환대·케이고약속·점원심부름은창작이며공식사건을재현한다는주장이아니다.','차드·우라하라·유즈가나오는분기도다른NPC동행/노동/안내기능을추가하지않고해당인물과대화로카드만받는다. 귀도·사신화·영혼변경·실제진료없음.']);
console.log(JSON.stringify({cards:5,events:5}));
