// 확인한 나비저택의 수련·약학 소재와 개인 정찰 후속을 사건 초안으로 보존한다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const fx=(stat,value)=>({stat,value});
const card=(key,name,effectName,keyword,effects,canonFact,evolution={kind:0,goal:0,effects:[]},grade=2)=>({key,name,effectName,keyword,grade,effects,evolution,canonFact,uncertain:[]});
const branch=(label,intent,card=null,extra={})=>({label,result:intent,card,card2:null,gold:0,cost:0,level:0,density:0,potions:0,chance:100,...extra});
const scene=(key,title,situation,intro,choices,canonFact,previous=null,previousChoice=0,failure=null)=>({key,title,story:situation,intro,previous,previousChoice,requiredCard:null,choices,failure,canonFact,uncertain:[]});
const cards=[
 card('kny_aoi','칸자키 아오이','다시 시작할 준비','행동',[fx('action_speed',3)],'나비저택 수련의 준비를 작은 입문 효과로 각색한다. 신규 기술이나 현재 체력 즉시 회복이 아니다.',undefined,1),
 card('kny_tanjiro','카마도 탄지로','끊기지 않는 호흡','신속 · 고체력',[fx('swift',6),fx('healthy_damage',14)],'일상에도 전집중 호흡을 이어가는 수련을 행동 준비와 고체력 조건으로 각색한다. 호흡 기술을 새로 지급하지 않는다.',{kind:3,goal:45,effects:[fx('final_damage_percent',3)]}),
 card('kny_kanao','츠유리 카나오','먼저 읽는 움직임','치명 · 행동',[fx('crit_chance',7),fx('action_speed',6)],'높은 신체 능력과 탄지로의 수련 상대 역할을 반응과 정확한 공격 준비로 각색한다.',{kind:2,goal:6000,effects:[fx('crit_damage',15)]}),
 card('kny_shinobu','코쵸 시노부','출발 전에 남긴 당부','재생 · 생존',[fx('regeneration',0.6),fx('damage_reduction',3)],'약학 지식과 저택의 치료 역할을 전투 중 재생 준비로 각색한다. 독 기술·부활·즉시 완전 회복을 지급하지 않는다.'),
 card('kny_zenitsu','아가츠마 젠이츠','한순간에 모은 힘','차지 · 치명',[fx('charge_damage',18),fx('crit_damage',20)],'날카로운 청각과 번개의 호흡을 집중한 한 번의 공격 준비로 각색한다. 플레이어의 실신·수면이나 신규 돌진을 요구하지 않는다.',{kind:1,goal:60,effects:[fx('boss_damage_percent',8)]}),
 card('kny_inosuke','하시비라 이노스케','머뭇거리지 않는 돌파','일반 · 비방향',[fx('normal_damage_percent',15),fx('nondirectional_damage',12),fx('damage_reduction',-4)],'돌진하는 호전성을 일반 적·비방향 공격과 방어 부담으로 각색한다. 실제 쌍검 기술이나 방향 적중 공격 보너스는 지급하지 않는다.')
];
const events=[
 scene('kny_training','훈련표 앞의 빈자리','카나오와 겨루던 탄지로가 잠시 물러나 호흡부터 가다듬는다. 아오이는 다음 훈련에 쓸 도구를 놓고, 시노부는 서둘러 나서기 전에 준비를 확인하자고 한다. 네가 먼저 점검할 것을 정한다.','반응 훈련·호흡·회복 준비 중 지금 필요한 것을 고른다.',[
  branch('훈련 도구를 마련하고 카나오의 움직임을 읽는다','카나오의 동작을 따라가며 손을 내미는 순간보다 그 직전의 어깨와 발을 살핀다. 더 위험한 구역을 맡지 않고 정확한 반응을 익힌다.','kny_kanao',{cost:180}),
  branch('탄지로와 더 강한 상대 앞에서도 호흡을 이어 간다','급하게 힘을 주면 흐트러지는 호흡을 반복해 바로잡는다. 연습 이후의 개인 사냥 구역에는 전보다 강한 적이 남는다.','kny_tanjiro',{level:1}),
  branch('시노부와 출발 전 회복 준비를 갖춘다','준비물 비용을 지불하고 무리해서 버티는 것과 회복을 기다리는 것을 구분한다. 그 준비를 앞으로의 전투에 가져간다.','kny_shinobu',{cost:120}),
  branch('아오이와 훈련 도구를 정리하고 보급품을 받는다','다 쓴 도구를 정리해 다음 사람이 바로 연습할 수 있게 한다. 맡은 일의 일당과 출발용 물약을 챙긴다.',null,{gold:150,potions:1})
 ],'공식 24·25화의 저택 치료·기능 회복·호흡 수련과 카나오의 상대 역할을 소재로 삼는다. 비용·보급품·플레이어 연습은 맵 창작이다.'),
 scene('kny_breath_after','서 있을 때와 걸을 때','탄지로는 네가 멈춰 있을 때 호흡을 잇는 것과 움직이며 잇는 것은 다르다고 짚는다. 카나오는 다시 연습할 자리를 가리키고, 시노부는 준비를 점검한 뒤 돌아오라고 말한다. 앞선 수련의 다음 과제를 정한다.','호흡 뒤 반응 훈련 또는 회복 준비로 이어진다.',[
  branch('정리 비용을 내고 카나오와 반응 훈련에 집중한다','현재 맡은 강한 구역 일부를 정리하도록 비용을 내고 발을 옮기는 순간을 연습한다. 카나오의 속도를 무작정 따라잡기보다 움직임의 시작을 본다.','kny_kanao',{cost:240,level:-1}),
  branch('시노부와 더 많은 적 앞에서 버틸 준비를 한다','한 번의 공격만 버틸 생각을 버리고 여러 상대 사이에서 회복을 이어갈 준비를 한다. 남은 사냥에는 더 많은 적이 들어오는 부담도 감수한다.','kny_shinobu',{density:1}),
  branch('이번 훈련을 정리하고 물약을 챙긴다','연습 도구를 정리하고 다음 사냥에 쓸 물약을 받는다. 배운 호흡은 유지하되 이번에는 새 반응 훈련을 맡지 않는다.',null,{potions:2})
 ],'하루 동안 호흡을 유지하는 수련의 소재를 새 개인 후속으로 각색한다. 이전 적 단계가 그대로라고 단정하지 않는다.','kny_training',2),
 scene('kny_night_path','울음 사이로 섞인 발소리','저택 밖 길에서 젠이츠가 멀리서 섞여 오는 소리를 듣고 발을 멈춘다. 이노스케는 망설일 틈에 자신이 먼저 길을 보겠다고 하고, 탄지로는 각자가 확인한 것을 나눠 말하자고 한다. 어떤 준비를 익히며 네 사냥 구역을 맡을지 정한다.','소리를 건 정찰·돌파·차분한 준비·보급 정리로 나뉜다.',[
  branch('정찰 준비비를 내고 젠이츠가 짚은 길을 확인한다','소리의 간격을 놓치지 않게 힘을 한순간에 모으는 법을 익혔다. 정찰 의뢰의 보수를 받고도 맡은 구역의 더 강한 적은 계속 상대해야 한다.','kny_zenitsu',{cost:160,gold:200,level:1,chance:70}),
  branch('이노스케에게 돌파할 때 놓치기 쉬운 자리를 묻는다','머뭇거리는 대신 공격을 이어가는 자세를 배운다. 다가오는 상대를 더 많이 맡고 방어에 빈틈이 생기는 부담도 감수한다.','kny_inosuke',{density:2}),
  branch('탄지로와 차분하게 출발 준비를 되짚는다','준비 비용을 내고 서두르며 놓친 발과 호흡을 다시 맞춘다. 맡은 구역을 더 위험하게 바꾸지 않고 다음 싸움의 자세를 다진다.','kny_tanjiro',{cost:220}),
  branch('길목의 보급품을 정리하고 일당을 받는다','흩어진 보급품을 정리해 한쪽 길의 부담을 줄이고 일당을 받는다. 누구도 불확실한 소리의 정체를 단정하지 않는다.',null,{gold:160,density:-1})
 ],'공식 인물 소개의 젠이츠 청각·이노스케 감각과 호전성·탄지로 성실한 수련을 쓴다. 밤길 정찰과 판정·비용은 맵 창작이다.',null,0,'소리를 따라 확인했지만 의뢰에서 찾던 흔적을 가려내지 못했다. 준비비는 이미 썼고, 더 강한 구역을 맡는 부담은 남았다. 젠이츠에게서 새 공격 준비를 익히거나 정찰 보수를 받은 결과는 아니다.'),
 scene('kny_night_found','찾은 흔적의 건너편','앞선 정찰에서 확인한 흔적을 기록지에 옮기자, 젠이츠는 소리를 듣는 것과 그 순간 움직이는 것은 다르다고 말한다. 카나오가 손발의 반응을 시험할 자리를 가리킨다. 더 배우거나 보급으로 준비를 마칠 수 있다.','정찰 뒤 반응 카드·부담 감소와 물약·보수 정리 중 고른다.',[
  branch('카나오와 반응 훈련을 위한 도구를 마련한다','정찰 기록을 놓고 움직여야 할 순간을 되풀이한다. 카나오에게 상대의 동작을 읽고 손발을 옮기는 순서를 배운다.','kny_kanao',{cost:240}),
  branch('길 한 곳을 정리하고 출발용 물약을 받는다','현재 맡은 길의 한쪽을 정리하고 다음 전투의 보급품을 받는다. 적의 부담이 전부 사라진 것은 아니지만 이번에는 새로운 훈련 대신 물약을 챙긴다.',null,{density:-1,potions:2}),
  branch('확인한 기록을 넘기고 일당을 받는다','찾은 흔적을 더 크게 부풀리지 않고 기록지에 남긴다. 정리한 기록의 일당을 받고 현재 사냥 구역으로 돌아간다.',null,{gold:200})
 ],'소리를 확인한 자기 성공 기록을 요구하는 맵 전용 후속이다. 실제 청각 스킬·새 적 종족을 지급하지 않는다.','kny_night_path',1),
 scene('kny_night_wrong','잘못 짚은 소리의 값','정찰 기록에는 찾던 흔적 대신 같은 자리를 돌아온 발자국이 남았다. 이노스케는 더 직접 확인하자고 하고, 시노부는 서두르기 전에 다음 출발의 준비부터 보자고 한다. 이번 실패 뒤 무엇을 보완할지 정한다.','실패 비용을 환불하지 않고 회복 준비·돌파·안전 보급으로 이어진다.',[
  branch('시노부와 다음 출발의 회복 준비를 갖춘다','새 준비 비용을 내고 앞으로의 전투에서 회복을 이어갈 방법을 챙긴다. 앞선 정찰의 지출을 되돌리거나 무리한 구역을 자동으로 없애지는 않는다.','kny_shinobu',{cost:160}),
  branch('이노스케에게 더 강한 구역을 맡는 자세를 묻는다','몸을 사리던 자세를 버리고 상대에게 공격을 이어가는 순서를 익힌다. 현재 구역보다 강한 적을 맡는 위험과 방어의 빈틈도 감수한다.','kny_inosuke',{level:1}),
  branch('확인하지 못한 길을 하나 줄이고 물약을 챙긴다','현재 맡은 길 일부를 정리하고 남은 길에 가져갈 물약을 받는다. 찾지 못한 흔적은 빈칸으로 남기고 다음 싸움을 준비한다.',null,{density:-1,potions:1})
 ],'실패 자체를 무료 성장으로 환급하지 않는다. 자기 실패 기록에서 추가 행동력으로 보완하는 창작이다.','kny_night_path',-1)
];
const data={world:{key:'butterfly',name:'나비저택',work:'귀멸의 칼날',intro:'아오이가 훈련 도구를 놓고 출발 준비를 살핀다. 몸의 반응과 호흡, 약학과 길을 읽는 준비를 배울 자리가 열린다.',effects:[fx('healthy_damage',2)],entryCard:'kny_aoi',icon:'ReplaceableTextures\\CommandButtons\\BTNInnerFire.blp'},sources:['https://kimetsu.com/anime/risshihen/story/?story=24','https://kimetsu.com/anime/risshihen/story/?story=25','https://kimetsu.com/anime/hashirageikohen/character/'],canonBoundary:'24·25화의 나비저택 치료와 기능 회복·호흡 수련, 공식 인물 소개의 카나오 신체 능력·시노부 약학·젠이츠 청각·이노스케 성향을 소재로 삼는다. 원작의 호흡·독·실신·귀화·신규 기술·NPC 동행을 구현하지 않는다. 밤길 의뢰·도구 비용·보급 일당·적 구역 변화는 맵 전용 창작이다. 현재 체력을 지불하지 않는다. 사건의 정찰 판정은 능력치 판정이나 실제 미니게임 입력이 아닌 표시한 확률이다.',cards,events};
const textItem={type:'object',additionalProperties:false,required:['key','story','results','failure'],properties:{key:{type:'string'},story:{type:'string'},results:{type:'array',items:{type:'string'}},failure:{type:['string','null']}}};
const issueItem={type:'object',additionalProperties:false,required:['key','reason'],properties:{key:{type:'string'},reason:{type:'string'}}};
const schema={type:'object',additionalProperties:false,required:['events','issues'],properties:{events:{type:'array',items:textItem},issues:{type:'array',items:issueItem}}};
const request={review:false,schema,system:'한국어로 사건의 이야기와 각 행동의 결과를 짧은 구체적 장면으로 집필한다. 주어진 상황과 행동·인물·손익·후속 조건을 바꾸지 않는다. story는 2~3문장, result는 1~2문장. 숫자·카드·스탯·성공률 설명이나 제작 지시를 본문에 복사하지 않는다. 비용은 플레이어가 내며 보수는 플레이어가 받는다. 후속 사이에 다른 사건으로 필드 값이 바뀔 수 있다. 현재 줄이는 길·강함만 설명하고 과거 값 복원을 단정하지 않는다. 사냥 몬스터를 새 귀 종족으로 바꾸거나 NPC가 같이 사냥한다고 쓰지 않는다. 호흡·청각·독 기술을 플레이어에게 새로 주지 않는다. 실패에는 원정체력 손실을 만들어 넣지 말고 지출과 남은 위험만 보여준다. 앞선 훈련·기록·정비 사건과 반복되는 약점이 있으면 issues에 지적한다. 고유 장면을 창작하되 원작의 살인·가족·결말을 해결하지 않는다.',brief:{canonBoundary:data.canonBoundary,cards:cards.map(c=>({key:c.key,name:c.name,effectName:c.effectName,effects:c.effects,canonFact:c.canonFact})),events:events.map(e=>({...e,choices:e.choices.map(b=>({...b,resultIntent:b.result}))}))}};
fs.writeFileSync(path.join(__dirname,'butterfly-design-01.json'),JSON.stringify(data,null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(__dirname,'butterfly-text-01.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});
console.log('나비저택 6카드·5사건 원안을 보존했습니다. 아직 활성 콘텐츠가 아닙니다.');
