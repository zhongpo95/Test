// 학원도시 피칭의 인물 강제 조작과 반복 청소를 걸러 여섯 만남의 고정안을 만든다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const pitches=read('drafts/academy-pitches-57.json').parsed.pitches;
const reasons=[
 '삼킨 동전의 발단만 남긴다. 미코토의 손을 잡아 세우거나 비법을 막는 선택은 NPC 행동과 원작 파괴를 대신 결정한다. 여행자가 자기 음료를 따로 마련하는 행동으로 바꾼다.',
 '호출에 중단된 간식만 남긴다. 사텐의 잔을 들고 호출 장소로 같이 가는 선택은 실제 동행을 약속할 수 있어 자기 기다릴 몫과 포장으로 바꾼다.',
 '아직 답하지 않은 약속만 남긴다. 쿠로코의 앞을 막거나 고개를 끄덕여 둘의 갈등을 끝내는 선택은 폐기하고 여행자의 대답과 맡을 사냥을 정한다.',
 '학생이 떠나고 테츠소에게 말끝과 버튼이 남은 장면만 남긴다. 손을 겹쳐 누르거나 게임기 전원을 끄는 행위는 인물을 조작하며 게임기를 소유한 것처럼 만든다. 자기 다음 동전과 관찰로 바꾼다.',
 '성하제의 안내와 무대 차례 사이 긴장만 남긴다. 공식 소개에 없는 무대 소품의 종류와 메이드 복장 그대로 현장에 남은 쿠로코를 확정하지 않는다.',
 '물때·양동이·걸레 속도는 기존 수영장 준비물의 분류/보조를 바꾼 반복 청소다. 새 독립 사건으로 쓰지 않는다.'
];
write('revisions/academy-pitches-selection-57.json',{raw:'drafts/academy-pitches-57.json',items:pitches.map((p,i)=>({...p,decision:i<5?'발단만 남겨 내 행동으로 재설계':'폐기',reason:reasons[i],revisit:'NPC 손·위치·화해·기술을 조작하지 않는 내 행동과 기존 사건과 다른 인물 반응·성장·부담을 가진 새 원안으로 검토한다.'}))});
const f=(stat,value)=>({stat,value}),none={kind:0,goal:0,effects:[]};
const card=(key,name,effectName,keyword,effects,canonFact,evolution=none)=>({key,name,effectName,keyword,grade:2,effects,evolution,canonFact,uncertain:[]});
const cards=[
 card('academy_touma_coin','카미조 토우마','삼켜도 남은 한 닢','처치 골드 · 피해 감소',[f('kill_gold',2),f('damage_reduction',5)],'자판기에 돈을 삼켜도 남은 준비를 찾는 별도 만남의 기억이다. 원작의 불행을 다른 사람에게 전가하거나 흡수·확률 보정·이매진 브레이커 새 기능을 주지 않는다.'),
 card('academy_kuroko_return','시라이 쿠로코','다녀와서 들 한 잔','신속 · 고체력',[f('swift',180),f('healthy_damage',10)],'간식 도중 풍기위원 호출을 받는 공식 상황을 급히 나서도 돌아올 몫을 남기는 성장으로 각색했다. 순간이동·NPC 출동·현재 체력 비율 회복 기능은 없다.'),
 card('academy_uiharu_promise','우이하루 카자리','아직 답하지 않은 약속','사건 후보 · 보스',[f('event_choices',1),f('boss_damage_percent',8)],'지원과 잊은 약속을 둘러싼 공식 갈등에서 자기 답을 서두르지 않고 큰 상대를 앞둘 질문을 남기는 성장이다. 원작 약속의 내용을 지어내거나 친구의 화해·실제 미래 정보를 보상으로 주지 않는다.'),
 card('academy_tessou_button','테츠소 츠즈리','떠난 뒤 남은 버튼','행동 · 비방향',[f('action_speed',4),f('nondirectional_damage',12)],'안티스킬의 실패와 좋아하던 게임을 하다 혼자 남은 공식 상황에서 다음 입력을 지켜보는 기억으로 각색했다. 학생의 사정·게임 종류·실제 미니게임·게임 기술 전수를 확정하지 않는다.',{kind:1,goal:35,effects:[f('crit_chance',3)]}),
 card('academy_mikoto_curtain','미사카 미코토','막 앞의 한 호흡','차지 피해 · 치명타 피해',[f('charge_damage',12),f('crit_damage',12)],'성하제에서 무대의 큰 일을 맡고 긴장하는 공식 소개를 힘을 싣는 순간을 기다리는 기억으로 각색했다. 원작의 악기·공연·곡·관객 평가·새 발사 기술은 지급하지 않는다.',{kind:2,goal:9000,effects:[f('boss_damage_percent',4)]}),
 card('academy_mikoto_drink','미사카 미코토','차가워지기 전에','차지 속도 · 최대 체력',[f('charge_speed',8),f('max_health_percent',8)],'자판기에서 얻지 못한 음료를 별도로 마련한 자기 선택의 후속에서 준비를 기다리는 기억이다. 실제 음료 아이템·상처 치료·자판기 수리·전기 기술을 지급하지 않는다.')
];
const b=(action,card=null,cost=0,level=0,density=0,gold=0,potions=0,chance=100)=>({action,card,card2:null,cost,level,density,gold,potions,chance});
const events=[
 {key:'academy_vending_left_coin',title:'한 번 더 넣기 전에',scene:'토우마가 동전을 삼킨 자판기를 보며 남은 한 닢을 꺼내자 미코토는 익숙한 방법이 있다고 발을 보낸다. 네 손에도 아직 마시지 못한 음료값이 남아 있고 토우마는 네 동전까지 같은 곳에 넣을 필요는 없다고 말한다. 너는 다른 음료를 마련하거나 자기 다음 사냥에 남길 몫을 정한다.',choices:[b('160골드로 다른 곳의 음료를 마련하고 내 남은 몫을 챙긴다','academy_touma_coin',160),b('더 강한 개인 사냥을 맡고 미코토와 준비의 끝을 기다린다','academy_mikoto_drink',0,1),b('더 많은 개인 사냥을 맡고 토우마와 남은 준비를 나눈다','academy_touma_coin',0,0,1),b('전달할 짐만 옮기고 보급 보수를 받는다',null,0,0,0,110,1)],canonFact:'금서목록1기10화의 동전 삼킴과 미코토 비법 역할에서 별도의 유사 고장 만남을 창작했다. 원작 자판기 파괴·미사카 동생 등장·실험 결말을 플레이어가 바꾸거나 불행을 전가하지 않는다.'},
 {key:'academy_tea_after_call',title:'한 입 남기고 울린 호출',scene:'케이크를 막 나누려던 쿠로코가 호출을 듣고 일어서자 우이하루는 아직 들지 못한 자기 찻잔을 본다. 사텐은 돌아올 때도 남아 있겠냐고 묻고 쿠로코는 나갔다 온 뒤의 이야기까지 지금 못 한다고 말한다. 너는 자기 간식과 기다릴 자리, 가져갈 보급 중 무엇을 남길지 정한다.',choices:[b('180골드로 포장을 마련하고 돌아올 한 잔을 남긴다','academy_kuroko_return',180),b('더 많은 개인 사냥을 맡고 우이하루의 남은 답을 기다린다','academy_uiharu_promise',0,0,1),b('자기 짐을 옮기고 보급 보수를 받는다',null,0,0,0,130,1)],canonFact:'초전자포1기3화의 파티스리와 호출 순간에서 별도 간식 준비를 창작했다. 기존 중복 주문과 상자 분류를 반복하지 않고 사텐의 피습·범인 체포·NPC 출동 동행을 해결하지 않는다.'},
 {key:'academy_unanswered_promise',title:'출발보다 먼저 할 대답',scene:'쿠로코가 먼저 나설 준비를 하는데 우이하루는 네가 맡을 일에도 아직 대답을 듣지 못했다고 말한다. 쿠로코는 이미 들은 이야기라며 앞을 보고 우이하루는 누가 대답한 것이냐고 되묻는다. 여행자는 두 사람의 약속을 대신 정하지 않고 자기 몫을 직접 답할 차례다.',choices:[b('180골드로 내 준비를 마련하고 맡을 일을 끝까지 답한다','academy_uiharu_promise',180),b('더 강한 개인 사냥을 맡고 쿠로코의 다음 행동을 기억한다','academy_kuroko_response',0,1),b('맡을 사냥을 줄이고 남은 전달물의 보수를 받는다',null,0,0,-1,100)],canonFact:'초전자포1기5화의 지원을 기다리지 않음과 잊은 약속의 갈등에서 별도 준비를 창작했다. 원작의 약속 내용·폭행·화해와 둘의 신뢰를 여행자가 해결하거나 판정하지 않는다.'},
 {key:'academy_arcade_empty_seat',title:'말을 걸었는데 비어 있는 자리',scene:'오락실에서 학생이 중간에 떠나자 테츠소는 방금 하려던 말과 버튼 사이에 손을 멈춘다. 좋아하던 게임인데도 누구에게 말을 이어야 할지 몰라 자기 옆의 빈 의자를 보고 있다. 너는 자기 동전을 보탤지 손의 다음 움직임을 지켜볼지 정한다.',choices:[b('200골드로 내 다음 차례를 마련하고 남은 버튼을 지켜본다','academy_tessou_button',200),b('더 많은 개인 사냥을 맡고 테츠소와 다음 입력의 간격을 본다','academy_tessou_button',0,0,1),b('반납할 물품을 옮기고 보급 보수를 받는다',null,0,0,0,140,1)],canonFact:'초전자포1기17화에서 코노에가 플레이 도중 떠나 테츠소가 혼자 남는 상황을 작은 별도 만남으로 각색했다. 학생의 이유·게임 종류·승패·손을 대신 움직이는 선택·전원 차단·실제 미니게임은 없다.'},
 {key:'academy_festival_before_stage',title:'안내하다가 멈춘 말끝',scene:'성하제에서 너를 안내하던 미코토가 다음 전시를 가리키다가 자기 무대 차례를 떠올려 말을 멈춘다. 우이하루는 전시를 더 보고 싶어 하고 사텐은 미코토에게도 돌아갈 자리가 남아 있냐고 묻는다. 너는 미코토의 공연을 대신 정하지 않고 자기 구경과 가져갈 준비를 고른다.',choices:[b('210골드로 내 기다릴 준비를 마련하고 무대 앞의 호흡을 기억한다','academy_mikoto_curtain',210),b('더 강한 개인 사냥을 맡고 미코토와 준비의 끝을 기다린다','academy_mikoto_drink',0,1),b('안내를 마친 짐을 운반하고 보수를 받는다',null,0,0,0,150,1)],canonFact:'초전자포1기19화의 미코토 안내와 무대 부담을 각색했다. 공연의 종류·악기·곡·성공평가를 공식 소개로 확인하지 않아 정하지 않고 쿠로코를 업무에 불려간 뒤 현장에 남기지 않는다.'},
 {key:'academy_drink_after_vending',title:'손에 남은 것은 음료값이 아니라',previous:'academy_vending_left_coin',previousChoice:1,scene:'다른 곳에서 음료를 마련했던 네 앞에서 미코토가 아직 뜯지 않은 자기 몫을 내려놓는다. 토우마는 자판기에 남은 동전부터 떠올리고 미코토는 지금 손의 것을 마시기 전에 또 같은 기계를 볼 것이냐고 묻는다. 너는 잃은 동전의 결말보다 자기 준비를 끝낼 때를 정한다.',choices:[b('120골드로 다음 보급을 마련하고 음료를 열 때를 맞춘다','academy_mikoto_drink',120,0,0,0,0,70),b('더 많은 개인 사냥을 맡고 미코토의 짧은 호흡을 기억한다','academy_mikoto_curtain',0,0,1),b('남은 짐을 반환하고 보급 보수를 받는다',null,0,0,0,150,1)],failure:'다음 보급값120골드를 썼지만 준비를 끝낼 때를 맞추지 못했다. 카드는 얻지 못하고 준비 비용도 돌아오지 않는다. 미코토는 아직 뜯지 않은 음료를 내려놓고 토우마는 남은 짐부터 본다.',canonFact:'자판기 앞에서 자신이 다른 음료를 마련한 성공1번에서만 열리는 창작 후속이다. 원작 자판기를 수리하거나 삼킨 동전을 돌려주지 않고 실제 음료 소모·전기 기술·소모품 차감·현재 체력 회복은 없다.'}
];
const sourceFacts=read('requests/academy-pitches-57.json').brief.sourceFacts;
const learning={academy_touma_coin:'처치당골드2추가·받는피해감소5%',academy_kuroko_return:'신속180·체력65%이상일때가하는피해10%',academy_uiharu_promise:'사건후보1개추가(최대4)·보스피해8%',academy_kuroko_response:'행동속도6%·받는피해감소4%',academy_tessou_button:'행동속도4%·비방향공격피해12%',academy_mikoto_curtain:'차지공격피해12%·치명타피해12%',academy_mikoto_drink:'차지준비속도8%·최대체력8%'};
const expected=c=>({paidGold:c.cost,rememberedCard:c.card,remembered:c.card?learning[c.card]:null,receivedGold:c.gold,receivedPotions:c.potions,personalEnemyStrengthChange:c.level,personalEnemyCountChange:c.density});
const schema=read('requests/magnolia-expansion-text-28.json').schema;schema.properties.events.minItems=events.length;schema.properties.events.maxItems=events.length;
write('requests/academy-expansion-fixed-58.json',{sourceRevision:'8c8ff70',cards,events,sourceFacts});
write('requests/academy-expansion-text-58.json',{review:false,schema,system:'한국어 사건 작가다. story는3문장,intro는현재남은문제1문장,result는성공한내행동·지불/성장/보급·인물에게남은행동의2~3문장이다. key와분기순서를유지한다. 무의미한끄덕임·칭찬·정리·효율설명으로끝내지않는다.',brief:{sourceFacts,events:events.map(e=>({key:e.key,scene:e.scene,previous:e.previous||null,previousChoice:e.previousChoice||0,choices:e.choices.map(c=>({action:c.action,chance:c.chance,expectedSuccess:expected(c)}))})),rules:[
 '사건중개인사냥은정지다. 강함/수는이후원정개인사냥에남는부담/완화이고실제몹을지금추가처치하지않는다. NPC동행·미니게임·자판기수리·음료아이템·초능력·화해·동생실험결말없다.',
 '지불과골드/물약보수는숫자로적고지급없음을새보수로바꾸지않는다.카드기억의성장은고체력가하는피해와받는피해감소를구분한다.최대체력은기존현재/최대비율보존이지즉시치료아니다.',
 '타인의손과몸을강제로잡아움직이거나기계전원을주인처럼끄지않는다. 각기다른시점의별도만남이며원작자판기파괴·피습·징계·화해·공연승패를플레이어가결정하지않는다.',
 '70%결과는성공때만서술한다.후속은자기앞선성공1번만.처치골드는실제현재골드지급과다르고사건후보는분기수를바꾸거나확률을늘리는스탯이아니다.추가AP/시간없다.'
]}});
console.log(JSON.stringify({newCards:6,newRoots:5,newFollowups:1,discardedPitches:1}));
