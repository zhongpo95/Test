// 후유키 피칭의 방 배정·화살 주체 오류·인질 거래와 중복을 걸러 고정 성장안을 만든다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const pitches=read('drafts/fuyuki-pitches-62.json').parsed.pitches;assert.equal(pitches.length,6);
const reasons=[
 '숙박 발단만 남긴다. 여행자가 집주인처럼 타이가·사쿠라·세이버 방을 배정하는 선택을 폐기하고 자기 침구·순찰·방문 종료를 정한다.',
 '궁도부에서 바닥에 닿은 화살을 남긴다. 요청은 여행자의 실패였는데 초안이 타이가가 실패한 것으로 바꿨다. 자기 동작의 실패를 타이가에게 묻는 장면으로 되돌리고 날씨 점검보다 성급한 한 발을 다룬다.',
 '감독자의 보호 범위를 묻는 발단만 남긴다. 시로의 생각과 참여 결말을 여행자가 바꾸지 않고 자기 안전의 판단과 독자 준비를 정한다.',
 '막아낸 다음에도 남은 판단만 남긴다. 본편 보구 충돌 직후 유지되는 방패와 승패를 새 만남의 사실로 확정하지 않는다. 거리를 잘못 본 여행자와 대응을 설명하는 두 인물의 별도 만남으로 바꾼다.',
 '폐기한다. 원작 인질 상황을 직접 재연하며 타이가 안전을 조건으로 묻는 선택은 금지한 거래를 되살린다. 작은 협상이라 해도 원작 주인공의 거부 이후에 끼어드는 방식이다.',
 '폐기한다. 첫 숙박 피칭과 key·본문·선택이 완전히 같은 중복이다. 집필 요청은5개였는데 재사용한 피칭 스키마가6개를 요구한 요청 충돌도 원인 후보다. 다음 요청에는 개수를 맞춘다.'
];
write('revisions/fuyuki-pitches-selection-62.json',{raw:'drafts/fuyuki-pitches-62.json',requestConflict:{requested:5,schemaMinimum:6,duplicateKey:'fy_stay_arrangement',decision:'원문은 보존하고 중복을 채택하지 않는다. 이어지는 집필 스키마는 실제5사건과 일치시킨다.'},items:pitches.map((p,i)=>({...p,decision:i<4?'발단만 남겨 자기 행동으로 재설계':'폐기',reason:reasons[i],revisit:'원작 인질·승패·타인 숙박을 조작하지 않는 자기 행동이며 기존 사건과 다른 장면과 성장 선택을 가진 원안으로 다시 검토한다.'}))});
const f=(stat,value)=>({stat,value}),none={kind:0,goal:0,effects:[]};
const card=(key,name,effectName,keyword,effects,canonFact,evolution=none)=>({key,name,effectName,keyword,grade:2,effects,evolution,canonFact,uncertain:[]});
const cards=[
 card('fy_sakura_blanket','마토 사쿠라','접어 두었던 한 사람 몫','최대 체력 · 재생',[f('max_health_percent',10),f('regeneration',0.3)],'가족 같은 관계와 숙박을 자기 몫의 여유로 각색했다. 원작 식사 메뉴·질병 치료·현재체력 즉시회복은 지급하지 않는다.'),
 card('fy_saber_night','세이버','사라지지 않는 자리','신속 · 보호막',[f('swift',90),f('shielded_damage',14)],'영체화할 수 없는 세이버의 존재와 바깥을 살피는 별도 방문을 준비의 기억으로 각색했다. 실제 영체화·NPC순찰·자동보호막은 없고 보호막 유지 피해는 이미 보호막이 있을 때만 적용한다.'),
 card('fy_taiga_arrow','후지무라 타이가','바닥에 먼저 닿은 화살','치명타 확률 · 방향',[f('crit_chance',6),f('directional_damage',8)],'궁도부 고문에게 자기 실패의 동작을 묻는 창작 만남의 기억이다. 타이가의 원작 사격 실패를 확정하거나 새 활·사격·미니게임을 지급하지 않는다.',{kind:1,goal:35,effects:[f('normal_damage_percent',6)]}),
 card('fy_kirei_shelter','코토미네 키레이','감독자의 보호 아래','피해 감소 · 일반 피해 감소',[f('damage_reduction',7),f('normal_damage_percent',-4)],'보호를 듣고 자기 경계를 좁힌 선택을 받는피해감소와 일반몬스터피해손해로 각색한다. 실제 안전 보장·무적·교회비밀·성배전쟁 참가권은 없다.'),
 card('fy_archer_brace','아처','막은 다음의 한 수','보호막 · 피해 감소',[f('shielded_damage',15),f('damage_reduction',4)],'강한 공격에 대응한 역할에서 막은 다음도 보는 기억이다. 원작 보구를 빌리거나 방패를 새로 생성하지 않으며 이미 보호막이 있어야 조건부피해가 적용된다.'),
 card('fy_lancer_second','랜서','창끝 다음의 발','이동 피해 · 방어 관통',[f('moving_damage',12),f('penetration',4)],'강한 대응 뒤 다음 발을 살피는 창작 만남이다. 원작 보구의 필중·즉사·방패 파괴·새 돌진을 지급하지 않는다.'),
 card('fy_taiga_interval','후지무라 타이가','다음 한 발을 놓기 전에','차지 속도 · 치명타 확률',[f('charge_speed',8),f('crit_chance',3)],'자기 성급한 동작을 물었던 후속에서 힘을 싣기 전 간격을 기억한다. 실제 궁도 점수·새 사격·활을 지급하지 않는다.')
];
const b=(action,card=null,cost=0,level=0,density=0,gold=0,potions=0,chance=100)=>({action,card,card2:null,cost,level,density,gold,potions,chance});
const events=[
 {key:'fy_one_more_blanket',title:'접어 둔 이불 하나',scene:'타이가와 사쿠라가 묵을 준비를 하는데 시로의 손에 펼치지 않은 이불 하나가 남아 있다. 세이버는 사라져 자리를 비울 수 없고 타이가는 네가 아직 외투를 벗지 않은 것을 본다. 너는 자기 침구를 마련할지 밖을 살필지 오늘 방문을 마칠지 정한다.',choices:[b('160골드로 내 침구를 마련하고 남겨 둔 한 사람 몫을 나눈다','fy_sakura_blanket',160),b('더 강한 개인 사냥을 맡고 바깥에서 세이버의 경계를 기억한다','fy_saber_night',0,1),b('외투를 챙겨 오늘 방문을 마치고 세이버의 기본 방어를 기억한다','saber_guard')],canonFact:'공식4화의 영체화 불가와 숙박을 별도 방문으로 각색한다. 누가 어디서 자는지·원작 신분 설명·인물 관계를 여행자가 대신 정하지 않는다.'},
 {key:'fy_arrow_on_floor',title:'표적보다 가까운 화살',scene:'네가 놓은 화살이 표적에 닿기 전에 바닥에 내려앉자 타이가는 다음 화살보다 네 손부터 보라고 한다. 시로가 화살을 가져오지만 너는 이미 다시 쏠 자세를 잡고 있다. 다시 서두르기 전에 자기 실패를 물을지 더 많은 사냥의 부담을 맡아 관찰할지 이번 시도를 마칠지 정한다.',choices:[b('180골드로 내 연습 준비를 마련하고 타이가에게 성급했던 동작을 묻는다','fy_taiga_arrow',180),b('더 많은 개인 사냥을 맡고 타이가에게 실패한 동작을 묻는다','fy_taiga_arrow',0,0,1),b('오늘 연습을 마치고 내가 맡은 정리의 보수만 받는다',null,0,0,0,120)],canonFact:'궁도부 고문이라는 공식 역할에서 여행자의 실패를 창작했다. 타이가가 원작에서 화살을 바닥에 떨어뜨렸다는 사실이나 궁도 승패를 확정하지 않는다.'},
 {key:'fy_shelter_question',title:'보호한다는 말의 범위',scene:'교회에서 키레이가 보호를 설명하자 너는 문 안에 있으면 다음 위험도 사라질 것이라 생각한다. 린은 감독자가 말한 범위에 네 다음 사냥까지 들어 있었냐고 묻는다. 키레이는 먼저 네가 무엇을 보호받으려는지 말하라며 대답을 기다린다.',choices:[b('감독자의 보호를 받아들여 경계를 좁힌다','fy_kirei_shelter'),b('200골드로 내 준비를 마련하고 린에게 다음 위험을 따로 묻는다','fy_rin_timing',200),b('내 사냥의 적 수를 줄이고 돌아갈 보급을 챙긴다',null,0,0,-1,0,2)],canonFact:'공식2·9화의 감독자 설명과 교회 보호 역할을 별도 방문으로 각색한다. 실제 안전·무적·신지의 새 계약·숨은 계획을 해결하거나 제공하지 않는다.'},
 {key:'fy_after_one_block',title:'한 번 막은 뒤의 발자리',scene:'아처가 막아낸 다음에도 상대의 손을 보는 사이 너는 대응이 끝났다고 한 발을 내놓는다. 랜서는 창을 고쳐 쥐며 그 발자리도 다음 움직임 안에 들어갈 수 있다고 말한다. 아처는 너 대신 새 방패를 놓지 않고 지금 뒤로 뺄 발과 남아 볼 자리를 묻는다.',choices:[b('220골드로 내 방어 준비를 마련하고 아처의 다음 대응을 기억한다','fy_archer_brace',220),b('더 강한 개인 사냥을 맡고 랜서의 창끝 다음 발을 본다','fy_lancer_second',0,1),b('내 사냥의 적 수를 줄이고 뒤로 물러날 보급을 챙긴다',null,0,0,-1,0,1)],canonFact:'공식17화의 강한 보구와 방패 대응에서 역할만 가져온 별도 만남이다. 본편 충돌 직후 방패가 계속 유지된다고 확정하지 않고 실제 원작 결투·방패 생성·보구 지급은 없다.'},
 {key:'fy_next_arrow_wait',title:'아직 당기지 않은 줄',previous:'fy_arrow_on_floor',previousChoice:1,scene:'타이가에게 성급한 동작을 물었던 네 앞에 시로가 다음 화살을 놓는다. 타이가는 아직 줄을 당기지 않았는데 네 눈이 벌써 표적에 가 있다고 말한다. 너는 한 발의 결과부터 서두를지 먼저 기다릴 간격을 정할지 선택한다.',choices:[b('150골드로 내 연습을 준비하고 기다릴 간격을 맞춘다','fy_taiga_interval',150,0,0,0,0,75),b('220골드로 충분히 준비하고 타이가에게 다음 간격을 다시 묻는다','fy_taiga_interval',220),b('더 강한 개인 사냥을 맡고 다음 발을 먼저 보는 기억을 택한다','fy_lancer_second',0,1),b('연습을 마치고 남은 내 준비의 보급을 챙긴다',null,0,0,0,100,2)],failure:'연습 준비값150골드를 먼저 냈지만 기다릴 간격을 맞추지 못했다. 카드는 얻지 못하고 지불한150골드는 돌아오지 않는다. 타이가는 네 다음 화살보다 아직 놓지 않은 손을 본다.',canonFact:'자기 궁도부 질문의 성공1번에서만 열리는 창작 후속이다. 원작 궁도 성적·NPC동행·새 활 기술·사냥중 추가 처치를 제공하지 않는다.'}
];
const learning={fy_sakura_blanket:'최대체력10%·초당최대체력0.3%재생,현재비율유지',fy_saber_night:'신속90·이미보호막있을때대미지14%,자동보호막없음',saber_guard:'받는피해감소6%',fy_taiga_arrow:'치명타확률6%p·방향공격대미지8%',fy_kirei_shelter:'받는피해감소7%·일반몬스터에게가하는대미지4%감소',fy_rin_timing:'치명타확률4%p·신속135',fy_archer_brace:'이미보호막있을때대미지15%·받는피해감소4%,자동보호막없음',fy_lancer_second:'이동중대미지12%·방어관통4%',fy_taiga_interval:'차지준비속도8%·치명타확률3%p'};
const expected=c=>({paidGold:c.cost,rememberedCard:c.card,remembered:c.card?learning[c.card]:null,receivedGold:c.gold,receivedPotions:c.potions,personalEnemyStrengthChange:c.level,personalEnemyCountChange:c.density});
const schema=read('requests/academy-expansion-text-58.json').schema;schema.properties.events.minItems=events.length;schema.properties.events.maxItems=events.length;
const sourceFacts=read('requests/fuyuki-pitches-62.json').brief.sourceFacts;
write('requests/fuyuki-expansion-fixed-63.json',{sourceRevision:'5d5efd9',cards,events,sourceFacts});
write('requests/fuyuki-expansion-text-63.json',{review:false,schema,system:'한국어 사건 작가다. 주어진5사건의key·순서를 지킨다. story는현장소품과인물반응을3문장,intro는남은문제1문장,result는내행동·실제지불/성장/보급·인물에게남은행동을2~3문장으로쓴다. 메타제약·빈칭찬·내부key·능력치목록만쓰지않는다.',brief:{sourceFacts,events:events.map(e=>({key:e.key,scene:e.scene,previous:e.previous||null,previousChoice:e.previousChoice||0,choices:e.choices.map(c=>({action:c.action,chance:c.chance,expectedSuccess:expected(c)}))})),rules:[
 '방패와활은새로지급하지않는다. 보호막유지피해는이미보호막있을때만적용하고자동방패가아니다. 최대체력변화는현재/최대비율보존이며즉시치료없다. 재생은시간에따른성장이다.',
 '사건중개인사냥은정지다. level/density는이후개인사냥강함/수변화량이며음수도가능하다. 현재HP비용·실제추가처치·NPC동행·영체화·성배계약·보구·원작인질거래없다.',
 '골드와물약은수치대로적고처치보너스와현재지급을섞지않는다. 카드의치명확률·치명피해·일반피해감소·받는피해감소·신속을바꾸지않는다.',
 '75%결과는성공때만쓴다. 선지불비용은실패에도유지되고카드없다. 기존모든사건/카드와결말은그대로며이5개는각기별도창작방문이다.'
]}});console.log(JSON.stringify({newCards:7,newRoots:4,newFollowups:1,discardedPitches:2}));
