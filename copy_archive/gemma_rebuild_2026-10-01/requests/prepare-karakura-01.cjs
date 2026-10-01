// 확인한 블리치 설정과 선택 손익을 보존하고 Gemma에 사건 서사를 요청한다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const base=path.resolve(__dirname,'..');
const card=(key,name,effectName,keyword,grade,effects,canonFact,kind=0,goal=0,extra=[])=>({key,name,effectName,keyword,grade,effects:effects.map(([stat,value])=>({stat,value})),evolution:{kind,goal,effects:extra.map(([stat,value])=>({stat,value}))},canonFact,uncertain:[]});
const choice=(label,card=null,values={})=>({label,result:'검토 대기.',card,card2:null,gold:0,cost:0,level:0,density:0,potions:0,chance:100,...values});
const event=(key,title,story,choices,values={})=>({key,title,story,intro:'검토 대기.',previous:null,previousChoice:0,requiredCard:null,choices,failure:null,canonFact:'우라하라 상점과 인물의 역할을 참고한 맵 창작 사건이다. 해당 사건이 원작에서 그대로 일어났다고 주장하지 않는다.',uncertain:[],...values});
const plan={world:{key:'karakura',name:'카라쿠라 마을',work:'블리치',intro:'우라하라 상점에서 콘이 배달 짐에 매달려 있다. 현세의 길을 정리하며 사신과 동료들의 준비를 접한다.',effects:[{stat:'damage_reduction',value:3}],entryCard:'bl_kon',icon:'ReplaceableTextures\\CommandButtons\\BTNTome.blp'},sources:['https://pierrot.jp/title/bleach/chara.html','https://bleach-anime.com/character/','https://en.bandainamcoent.eu/bleach-rebirth-of-souls-soul-society'],canonBoundary:'카라쿠라 마을, 우라하라 상점과 인물의 역할은 공식 소개를 확인했다. 분류되지 않은 짐과 경보·배송 사건은 맵 창작이다. 사신화·영체 이탈·새 참백도 기술·빙결·순보·보호막 생성은 지급하지 않으며 기존 능력치로 각색한다. 시트의 사신 카운트 무한 성장·사망 진화·스킬 교체는 도입하지 않는다.',cards:[
 card('bl_kon','콘','몸을 맡길 수 있는 동료','이동',1,[['move_speed',3]],'인형에 머무는 개조혼백으로 이치고의 몸을 지키는 역할에서 귀환 준비를 각색했다. 플레이어의 몸을 대신 조종하지 않는다.'),
 card('bl_ichigo','쿠로사키 이치고','지키기 위해 들었던 검','공격 · 보스',2,[['attack_percent',12],['boss_damage_percent',8]],'사신대행으로 동료를 지키는 이치고의 결심을 공격 준비로 각색했다.',1,45,[['crit_chance',3]]),
 card('bl_uryu','이시다 우류','흐트러지지 않는 조준','치명 · 관통',2,[['crit_chance',6],['penetration',8]],'퀸시인 우류의 정밀한 전투와 손재주를 조준 준비로 각색했다. 원작 활을 지급하지 않는다.',3,60,[['crit_damage',20]]),
 card('bl_orihime','이노우에 오리히메','거절하는 것은 상처','재생 · 체력',2,[['regeneration',0.8],['max_health_percent',8]],'순순육화로 현상을 거절하는 능력을 완만한 회복 준비로 각색했다. 상처의 즉시 복원이나 새 보호막을 지급하지 않는다.'),
 card('bl_yoruichi','시호인 요루이치','순신의 보법','신속 · 이동 피해',2,[['swift',270],['moving_damage',16]],'보법의 달인인 요루이치의 전투를 이동하며 공격하는 준비로 각색했다. 순간이동을 지급하지 않는다.',3,60,[['action_speed',5]]),
 card('bl_rukia','쿠치키 루키아','현세에서 지켜야 할 간격','차지 · 피해',2,[['charge_speed',6],['damage_percent',12]],'현세에서 사신 임무를 수행하는 루키아의 전투 판단을 차지 간격 조절로 각색했다. 참백도나 빙결 기술을 지급하지 않는다.',3,45,[['damage_reduction',4]]),
 card('bl_urahara','우라하라 키스케','준비가 남기는 여유','탐색 · 보스',2,[['event_choices',1],['boss_damage_percent',6]],'사신에게 물품을 제공하며 성장을 돕는 상점 주인의 준비와 정보 역할을 각색했다.'),
 card('bl_chad','사도 야스토라','약한 사람 앞에 서는 팔','체력 · 방어',2,[['max_health_percent',14],['damage_reduction',6]],'다른 사람을 몸으로 지키는 차드의 태도를 생존 준비로 각색했다. 새 방패나 팔 기술을 지급하지 않는다.'),
 card('bl_ichigo_focus','쿠로사키 이치고','한 번의 틈에 모은 힘','차지 · 공격',3,[['charge_damage',24],['attack_percent',6],['action_speed',-3]],'이치고의 칼에 집중하는 준비를 차지 공격의 큰 일격으로 각색했다. 월아천충을 새로 지급하지 않는다.',2,12000,[['boss_damage_percent',10]])
],events:[
 event('bl_shop_boxes','수취인이 없는 짐','우라하라 상점 앞에 네 갈래 길로 보낼 짐이 쌓였다. 콘이 끼어든 상자에는 수취인 이름이 가려져 있고, 이치고와 우류가 배송 쪽지를 서로 다르게 읽는다. 오리히메는 사람 없는 뒷길부터 확인하자고 한다.',[
  choice('이치고와 앞길을 열고 짐을 옮긴다','bl_ichigo',{level:1}),
  choice('우류와 젖은 배송 쪽지를 복구한다','bl_uryu',{cost:180}),
  choice('오리히메와 뒷길의 통행을 정리한다','bl_orihime',{cost:160,density:-1}),
  choice('콘이 섞인 짐을 찾아 묶음부터 다시 나눈다',null,{gold:180,potions:1,density:1})
 ]),
 event('bl_rooftop_marks','지붕 끝의 발자국','앞길의 짐을 옮긴 뒤, 돌아가는 길 위로 같은 발자국이 이어진다. 요루이치는 좁은 발판을 통해 거리를 벌리자고 하고 루키아는 적이 몰리기 전에 골목 입구를 맡자고 한다.',[
  choice('요루이치가 짚은 발판을 정비한다','bl_yoruichi',{cost:200,density:-1}),
  choice('루키아와 골목 입구를 맡는다','bl_rukia',{density:2})
 ],{previous:'bl_shop_boxes',previousChoice:1}),
 event('bl_return_receipt','다시 읽을 수 있는 주소','배송 쪽지의 글씨를 되살렸지만 짐을 보내야 할 집까지는 위험한 구간이 남았다. 우라하라는 약속한 준비물을 펼치고, 차드는 짐을 한 번에 나눠 들어 좁은 길을 비우려 한다.',[
  choice('우라하라에게 다음 구간의 준비물을 맡긴다','bl_urahara',{cost:240}),
  choice('차드와 짐을 나눠 안전 통로를 만든다','bl_chad',{cost:180,density:-1})
 ],{previous:'bl_shop_boxes',previousChoice:2}),
 event('bl_closed_lane','사람이 지나간 뒤의 골목','오리히메와 사람들을 먼저 보낸 뒷길이 조용해졌다. 하지만 바깥 골목의 흔적은 아직 남아 있어 루키아가 그쪽을 맡으려 한다. 차드는 돌아오는 사람이 길을 잃지 않게 표식을 더 세우자고 한다.',[
  choice('루키아와 바깥 골목의 흔적을 따라간다','bl_rukia',{level:1}),
  choice('차드와 귀환 표식을 세운다','bl_chad',{cost:220,potions:1})
 ],{previous:'bl_shop_boxes',previousChoice:3}),
 event('bl_light_parcel','짐에서 빠져나온 인형','콘을 잘못 묶인 짐에서 꺼내자 구겨진 배송 메모가 함께 떨어졌다. 오리히메는 늦어진 배송을 걱정하고, 우라하라는 목적지별로 꼭 필요한 물품부터 추리자고 한다.',[
  choice('오리히메와 남은 배송 길을 살핀다','bl_orihime',{cost:160}),
  choice('우라하라와 필요한 물품만 골라 싣는다','bl_urahara',{cost:220})
 ],{previous:'bl_shop_boxes',previousChoice:4}),
 event('bl_stray_alarm','한곳에서 울리지 않는 경보','경보가 서로 다른 골목에서 엇갈려 울린다. 요루이치는 가장 가까운 신호를 따라 좁은 길로 들어가려 하고, 차드는 사람들이 지나는 길을 먼저 확보한다. 우류는 흩어진 표시를 대조해 잘못된 신호를 가리려 한다.',[
  choice('요루이치와 가까운 신호를 추적한다','bl_yoruichi',{cost:100,density:2,gold:200,chance:70}),
  choice('차드와 통행로의 짐을 치운다','bl_chad',{cost:220,density:-1}),
  choice('우류와 경보 표시를 대조한다','bl_uryu',{cost:210})
 ],{failure:'먼저 울린 경보를 좇는 동안 다른 골목의 신호를 놓쳤다. 준비한 표식은 이미 사용했고 돌아가는 길에는 더 많은 적의 흔적이 남았다. 장소를 잘못 짚었다는 기록이 남는다.'}),
 event('bl_unmarked_corner','표식 없는 귀환길','추적했던 경보는 빈 골목에서 끊겼고 쓸 수 있는 표식도 줄었다. 루키아는 돌아갈 갈림길을 다시 확인하고, 우라하라는 경보 기록에서 빼먹은 지점을 짚는다.',[
  choice('루키아와 갈림길을 다시 표시한다','bl_rukia',{cost:160,density:-1}),
  choice('우라하라에게 경보 기록을 보여 준다','bl_urahara',{cost:200})
 ],{previous:'bl_stray_alarm',previousChoice:-1}),
 event('bl_joint_training','검을 내리기 전의 한 박자','이치고와 앞길을 맡아 본 뒤, 칼을 너무 빨리 뻗으면 다음 동작이 흐트러진다는 점을 알게 된다. 이치고는 더 강한 상대의 틈을 기다려 한 번에 힘을 모으려 한다. 차드는 길을 넓혀 다음 공격을 버틸 자리를 먼저 고르자고 한다.',[
  choice('이치고와 한 번의 틈에 힘을 모은다','bl_ichigo_focus',{cost:300,level:1}),
  choice('차드와 버틸 자리를 고른다','bl_chad',{cost:180,density:-1})
 ],{requiredCard:'bl_ichigo'})
]};
const schema={type:'object',properties:{events:{type:'array',items:{type:'object',properties:{key:{type:'string'},intro:{type:'string',maxLength:110},story:{type:'string',maxLength:350},choices:{type:'array',items:{type:'object',properties:{label:{type:'string',maxLength:65},result:{type:'string',maxLength:210}},required:['label','result'],additionalProperties:false}}},required:['key','intro','story','choices'],additionalProperties:false}}},required:['events'],additionalProperties:false};
const facts=['카라쿠라 마을에서 사신대행 이치고가 동료들을 지킨다.','우라하라는 과자 가게 뒤에서 사신용 물품을 다루며 현세 활동을 돕는다.','콘은 개조혼백이며 평소 인형에 머물고 이치고의 몸을 지키는 동료다.','우류는 퀸시이고 손재주가 좋아 바느질에 능하다.','오리히메는 사물의 현상을 거절하는 순순육화 능력을 갖고 동료를 생각한다.','차드는 약한 사람을 몸으로 지키며 자신을 위해 힘을 쓰지 않으려 한다.','요루이치는 보법의 달인이며 우라하라와 함께 동료들을 돕는다.','루키아는 현세 사신 임무를 수행하며 이치고의 동료다.'];
const request={schema,system:'한국어 게임 사건을 공동 집필한다. 제공된 8사건의 key와 행동 수·순서를 유지한다. 설명은 원작 확정 사실과 맵 창작 상황을 혼동하지 않도록 쓴다. 사건 story는 해결되지 않은 문제를 구체적인 물건·장소·인물 행동으로 2~3문장 제시한다. intro는 후보 화면에서 결과를 미리 확정하지 않는 1문장이다. result는 행동 뒤에 무엇이 변했는지 1~2문장이다. 맨 끝에 매번 칭찬하거나 웃는 문장을 반복하지 않는다. 영어 필드명, 숫자, 카드·능력치 획득, 시스템·제작자 설명을 이야기 안에 쓰지 않는다. 실제로 없는 새 기술·몸 조종·즉시 치료·빙결·순간이동을 플레이어가 얻는다고 약속하지 않는다. 흡수는 새 기술이 아니라 다른 공통 사건에서 별도로 다룬다. 후속이 없는 추가 서사를 약속하지 않는다. 한국어 문장을 콜론으로 끝내지 않는다.',brief:{facts,events:plan.events.map(e=>({key:e.key,title:e.title,situation:e.story,previousAction:e.previous?plan.events.find(p=>p.key===e.previous).choices[Math.abs(e.previousChoice)-1].label+(e.previousChoice<0?' 실패 뒤':' 뒤'):e.requiredCard?'이미 이치고와 앞길을 맡아 본 뒤':'선행 행동 없음',actions:e.choices.map(b=>({action:b.label,learning:b.card?plan.cards.find(c=>c.key===b.card).name+'의 준비를 접함':'배송 정리 수고비와 보급품을 챙김',consequence:[b.cost&&'배송 또는 표식·수련 준비에 비용 지출',b.level>0&&'남은 길에 더 강한 적을 감수',b.density>0&&'남은 길에 더 많은 적을 감수',b.density<0&&'통로를 정비해 남은 적 수를 줄임',b.chance<100&&'신호 추적은 실패할 수 있고 준비 비용·더 많은 적 부담은 남음'].filter(Boolean).join(' / ')||'주어진 문제를 해결하고 다음 준비를 정함'}))}))}};
fs.writeFileSync(path.join(base,'revisions/karakura-plan-01.json'),JSON.stringify(plan,null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(__dirname,'karakura-text-01.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});
console.log('카라쿠라 선택 손익과 서사 요청을 보존했습니다.');
