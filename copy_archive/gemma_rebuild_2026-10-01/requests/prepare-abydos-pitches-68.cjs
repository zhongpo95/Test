// 아비도스의 흥신소 만남을 공식 성격과 대조해 보상 메뉴가 아닌 사건 발단으로 요청한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const current=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/03-abydos.json'),'utf8'));
const schema=JSON.parse(fs.readFileSync(path.join(root,'requests/fuyuki-pitches-62.json'),'utf8')).schema;
assert.equal(schema.properties.pitches.minItems,6);assert.equal(schema.properties.pitches.maxItems,6);
const prefix='https://sh-anime.shochiku.co.jp/bluearchive-anime/';
const sourceFacts=[
 {source:prefix+'story/',fact:'공식3화에서 대책위원회는 라멘 가게에서 흥신소68과 의기투합하지만 다음날 공격받는다.5화는 아루의 이상과 현실의 차이를 다룬다.6화는 풍기위원회의 흥신소 인도 요구를 대책위원회가 거부한다. 별도 방문의 대사와 작은 문제를 창작하며 원작 공격·가게 폭파·인도 결말·학교 빚을 새 선택으로 끝내지 않는다.'},
 {source:prefix+'character/rikuhachima-aru/',fact:'아루는 게헨나 흥신소68의 자칭 사장이고 경영 공부가 취미다. 멋진 악당처럼 행동하려 하지만 허술함 때문에 금방 드러난다. 새 라멘 계산과 허세는 창작이다.'},
 {source:prefix+'character/onikata-kayoko/',fact:'카요코는 흥신소68 과장이고 음악CD수집이 취미다. 악의는 없지만 무서워 보이는 얼굴과 침묵 때문에 불량배로 오해받는다. 장르·실제 CD 제목·원작 가게 장면은 확정하지 않는다.'},
 {source:prefix+'character/igusa-haruka/',fact:'하루카는 흥신소68의 막내 역할인 사원이며 잡초 기르기가 취미다. 소극적이고 자존감이 낮지만 돌발적인 발상이 있다. 새 화분을 원작에 나온 특정 물품이라고 부르지 않는다.'},
 {source:prefix+'character/asagi-mutsuki/',fact:'무츠키는 말썽을 즐기는 행동파이며 폭탄 수집이 취미다. 아루의 소꿉친구로 허세를 잘 알지만 배려해 주지는 않는다. 실제 폭탄 피해·새 지뢰·폭탄 장비나 사냥 중 폭발 기능을 지급하지 않는다.'},
 {source:prefix+'character/sorasaki-hina/',fact:'히나는 풍기위원장으로 평소 귀찮아하지만 교칙에는 엄격하고 전장에서는 냉정하고 빠르게 판단한다. 새 검문을 뇌물로 통과시키거나 풍기위원회 교칙 면제를 판매하지 않는다.'},
 {source:prefix+'character/ajitani-hifumi/',fact:'히후미는 트리니티 학생이며 페로로 굿즈 수집·쇼핑·상담이 취미다. 온화해 남의 말을 잘 듣다가 분위기에 휩쓸려 문제를 일으키기도 한다. 아비도스 학생이나 일방적인 보호자 역할로 바꾸지 않는다.'}
];
const request={review:false,schema,system:'한국어 사건 작가다. 정확히6개 발단을 제안한다. premise는 현장 문제·인물 반응·여행자가 당장 결정할 행동을3문장으로 쓴다. 선택지는2~4개이며 숫자와 새 기능은 제안하지 않는다. 인물이 한 선택에 동의하거나 다른 반응을 보이는 작은 결말은 가능하지만 원작의 큰 결말을 다시 정하지 않는다. 보고서·분류표·보급 리스트·자기 준비를 마련한다만 반복하지 않는다.',brief:{sourceFacts,existing:current.events.map(e=>({key:e.key,title:e.title,story:e.story})),directions:[
 '라멘 가게에서 아루가 멋진 악당다운 계산을 하겠다고 큰소리쳤는데 자기 앞에 놓인 계산을 다시 본다. 무츠키는 허세를 알아챈다. 여행자가 계산을 도울지 다른 일을 같이 맡을지 아루의 말에 답할지 선택하는 새 사건. 세리카 교대/가게 복구와 다르게 만든다.',
 '카요코가 찾는CD를 물으려고 입을 열기 전에 가게 주인이 무서워 보인다는 이유로 사과한다. 여행자는 주문을 자기 말로 꺼낼지 잠깐 같이 들을지 오해 속에 물러날지 정한다. 비폭력의 작은 반응이 남는다.',
 '하루카가 기르는 잡초를 여행자가 잡초라는 이유로 치우려다 하루카의 손이 멈춘다. 여행자가 자기 실수를 인정하거나 화분에 쓸 자리를 내주거나 함께 관찰한다. 원작 트라우마가 완전히 치유되거나 맵에 실제 식물 성장 기능이 생기지는 않는다.',
 '무츠키가 아루를 놀리며 여행자에게도 작은 내기를 제안한다. 결과를 모르는 선택과 확실히 대가를 내는 선택을 이야기 속에서 구별한다. 실제 폭발/새 폭탄/원작 범죄 성공을 보상으로 주지 않는다.',
 '히나가 앞을 막자 여행자는 자기 짐이 아니라 옆 사람의 잘못으로도 검문받는다고 오해한다. 히나의 엄격함과 빠른 판단이 드러나는 짧은 만남. 아루 인도/원작 전쟁 승패/뇌물로 교칙 면제를 결정하지 않는다.',
 '히후미가 흥신소 부탁에 맞장구치다가 자기 약속까지 된 것인지 뒤늦게 묻는다. 여행자는 떠밀리기 전에 무엇을 하기로 했는지 말해야 한다. 기존 페로로 진열/잘못된 지도/자료정리와 다른 대화의 사건.'
],rules:[
 '실제 결과는 만난 인물의 지정 성장 카드·골드·물약·이후 개인 사냥의 적 강함/수다. 현재체력 지불·새 AP/시간·동료소환·NPC사냥·장비/무기·공포/폭발/수면 같은 미구현 기능을 보상으로 쓰지 않는다.',
 '개인 사냥은 사건 중 정지한다. 위험/부담은 재개 이후 개인 필드에 남는 적 강함/수이며 안전한 원작 장소를 맵 사냥터와 동일한 곳으로 묘사하지 않는다.',
 '별도 시점의 창작 만남이다. 흥신소는 게헨나이고 히후미는 트리니티다. 원작 사장·직원·학생 관계와 성격은 유지한다. 작은 대화/반응은 허용하되 원작 인물의 큰 비밀·계약·구출·실종 결말은 바꾸지 않는다.',
 '카드 수치와 선택의 비용은 다음 단계에서 고정한다. 지금은 행동의 의미와 인물의 다른 반응을 먼저 쓴다.'
]}};
fs.writeFileSync(path.join(root,'requests/abydos-pitches-68.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});console.log('아비도스피칭6개요청저장.');
