// 나비저택의 회복 훈련과 감각을 근거로 기존 출발 준비와 다른 사건 발단을 요청한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const current=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/13-butterfly.json'),'utf8'));
const schema=JSON.parse(fs.readFileSync(path.join(root,'requests/abydos-pitches-68.json'),'utf8')).schema;
assert.equal(schema.properties.pitches.minItems,6);assert.equal(schema.properties.pitches.maxItems,6);
const sourceFacts=[
 {source:'https://kimetsu.com/anime/risshihen/story/?story=24',fact:'공식24화는 시노부의 저택에서 치료받던 탄지로와 이노스케가 회복 훈련을 시작하지만 혹독함에 마음이 꺾이고, 뒤늦게 시작한 젠이츠는 여자를 보고 의욕을 낸다고 설명한다. 아오이는 출연자로 확인했다. 개별 훈련 도구와 아래 대사는 별도 창작이다.'},
 {source:'https://kimetsu.com/anime/risshihen/story/?story=25',fact:'공식25화는 탄지로가 온종일 전집중의 호흡을 유지하려 연습하고 그 결과 카나오에게 점점 맞설 수 있게 되며 젠이츠와 이노스케도 매일 연습하는 모습을 보고 훈련으로 돌아온다고 설명한다. 맵 선택으로 탄지로의 원작 성취를 대신 완료하지 않는다.'},
 {source:'https://www.usj.co.jp/company/news/2024/pdf/0513.pdf',fact:'공식 협업 보도자료2쪽은 탄지로가 나비저택에서 전집중 상중을 익히려고 사용한 표주박을 상품의 모티브로 설명한다. 여기서 확인한 것은 표주박과 훈련의 관계다. 새 크기 선택·값·소리·성공률은 창작이며 게임 내 표주박 장비나 새 미니게임을 구현하지 않는다.'},
 {source:'https://kimetsu.com/anime/risshihen/character/?chara=tanjiro',fact:'탄지로는 마음이 따뜻하고 냄새로 귀신과 상대의 급소를 구별할 수 있다. 새 대화가 원작 호흡/탐지 기술을 실제 스킬로 주는 것은 아니다.'},
 {source:'https://kimetsu.com/anime/risshihen/character/?chara=inosuke',fact:'이노스케는 멧돼지 머리를 쓰고 호전적이며 산에서 자라 촉각이 예민해 시야에 없는 상대의 위치도 잡는다. 새 가림막 놀이와 여행자의 선택은 창작이다. 실제 맵 투시·감지·적 자동조준·동료 소환은 없다.'},
 {source:'https://kimetsu.com/anime/risshihen/character/?chara=kanawo',fact:'카나오는 탄지로와 함께 최종선별을 살아남은 검사다. 공식25화에서 회복 훈련 상대인 것도 확인했다. 동전의 정확한 유래·의사결정 장면은 이번 공식 소개에서 확인하지 못했으므로 원작의 중요한 마음/동전 장면을 다시 결말짓지 않는다.'}
];
const request={review:false,schema,system:'한국어 사건 작가다. 정확히6개 발단을 순서대로 제안한다. premise는 물건이나 행동이 일으킨 작은 문제·인물 반응·여행자가 결정할 행동을3문장으로 쓴다. 선택지는2~4개다. 숫자와 새 기능을 제안하지 않는다. 범용 보고서/보급/출발준비를 반복하지 않고 인물의 작은 반응이 선택 후에도 남게 한다.',brief:{sourceFacts,existing:current.events.map(e=>({key:e.key,title:e.title,story:e.story})),directions:[
 '표주박을 보고 먼저 큰 것을 고른 여행자가 아오이의 다음 설명을 듣기도 전에 힘을 준다. 탄지로는 자기가 연습하던 도구와 호흡을 보여 준다. 크게 한 번 도전할지 차근차근 다시 배울지 도구를 내려놓을지 결정한다. 크기·대사·작은 시험은 창작이고 현재체력은 지불하지 않는다.',
 '탄지로에게 아침 인사를 하려는데 말을 하는 사이 호흡이 끊긴다. 탄지로는 온종일 유지하려는 연습을 처음부터 다시 잇는다. 여행자가 말을 계속 걸지 옆에서 박자를 맞출지 자기 할 말을 뒤로 미룰지 정하는 새 만남이다.',
 '카나오와 반응 훈련을 하던 여행자가 끝났다고 생각한 순간 손을 늦게 거둔다. 카나오는 다음 차례를 준비하지만 여행자는 같은 속도로 다시 할지 동작을 줄이고 다시 볼지 오늘은 멈출지 고민한다. 차/찻잔/특정 원작 승부 규칙은 이번 자료에서 확인하지 못해 창작 손동작만 사용한다.',
 '이노스케가 가림막 뒤로 이동한 여행자의 위치를 알아맞히고는 역할을 바꿔 보라고 한다. 여행자는 눈에 안 보이는 상대를 찾는다고 무작정 먼저 움직일지 소리와 발판을 관찰할지 승부를 접을지 정한다. 촉각에 예민한 인물 설정에서 만든 별도 놀이이며 실제 감지 스킬을 주지 않는다.',
 '카나오가 가진 동전으로 여행자가 다음 차례를 정하려는 새 제안이다. 공식 소개에서 동전의 유래와 중요한 원작 선택을 확인하지 못했으니 그 장면을 재현하지 않는다. 단순히 동전이 보상 버튼이 되는지 스스로 문제를 찾는다.',
 '젠이츠가 훈련에 돌아오려는데 이노스케와 문 앞에서 먼저 들어갈 사람을 다툰다. 기존 훈련 복귀 사건과 비슷하므로 새 현장 문제가 있는지 검토한다. 여자의 격려가 곧 확정 보상이 되거나 기존 복귀를 이름만 바꿔 반복하지 않는다.'
],rules:[
 '사건 중 개인 사냥은 정지한다. 실제 보상은 그 인물의 지정 성장 카드·골드·물약·재개 뒤 개인 사냥의 강함/수 변화다. 현재체력·새AP·시간·원작 기술·도구 장비·미니게임·투시/탐지·NPC동행은 없다.',
 '여행자의 별도 방문을 창작한다. 치료 중 인물을 위험한 현장으로 데려가거나 카나오 마음의 결정·탄지로 원작 호흡 완성·귀신 구출/결말을 대신 끝내지 않는다.',
 '사건마다 수치와 비용은 다음 단계에서 정한다. 지금은 구체적인 물건/손동작/인사/가림막과 선택에 따른 다른 반응을 먼저 만든다.'
]}};
fs.writeFileSync(path.join(root,'requests/butterfly-pitches-72.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});console.log('나비저택 피칭6개 요청 저장.');
