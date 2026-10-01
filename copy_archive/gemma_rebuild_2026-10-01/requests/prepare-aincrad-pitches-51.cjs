// 아인크라드의 정보 거래·보호·공략 회의에서 반복되지 않는 사건 발단을 요청한다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const world=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/06-aincrad.json'),'utf8'));
const schema=read('requests/axel-pitches-48.json').schema;
schema.properties.pitches.minItems=6;schema.properties.pitches.maxItems=6;
const sourceFacts=[
 {source:'https://eoa.sao-game.jp/character/argo.php',fact:'반다이남코 Echoes of Aincrad 공식 인물 소개에서 아르고는 다양한 정보를 다루는 정보상이며 해당 게임 주인공들과 베타 테스트에서 만났다고 소개한다. 정보상 역할만 활용하며 게임 주인공의 관계와 새 게임 전용 전개를 애니메이션의 사실로 옮기지 않는다.'},
 {source:'https://www.swordart-online.net/sp/aincrad/story/story11.html',fact:'공식 애니메이션11화 소개에서 키리토와 아스나는22층 호숫가의 통나무집에서 살기 시작한다. 유령 소문이 난 숲에서 기억을 잃고 쓰러진 소녀를 보호한다. 본문으로 소녀의 관리자 능력·정체·기억 회복 방법·후일 결말을 확인한 것이 아니다.'},
 {source:'https://www.swordart-online.net/sp/aincrad/story/story02.html',fact:'공식2화 소개에서 베타 경험자 키리토는 솔로로 탐색한 뒤1층 보스 방을 발견한다. 디아벨이 주최한 공략 회의에 참석하고 다른 솔로 플레이어와 파티를 맺는다. 본편의 승패·사망·보상 독점과 비터 평판을 여행자가 바꾸지 않는다.'},
 {source:'https://www.swordart-online.net/sp/aincrad/story/story04.html',fact:'공식4화 소개에서 시리카는 파티와 싸워 헤어진 뒤 숲에서 길을 잃고 피나를 잃는다. 키리토가 구해 주고 소생 방법을 설명하며 무상으로 돕겠다고 한다. 키리토가 왜 돕는지 설명한 답의 내용은 소개 본문에 없다.'},
 {source:'https://www.swordart-online.net/sp/aincrad/story/story13.html',fact:'공식13화 소개에서 낚시가 취미인 니시다는 키리토와 호수의 주인을 낚으려 협력한다. 공략의 최전선에 있던 키리토와 아스나는 평범한 사람들이 하루를 살아가는 모습을 실감한다. 주인을 실제 낚거나 쓰러뜨리는 결말은 본문으로 확인하지 않았다.'}
];
const request={review:false,schema,system:'한국어 사건 작가다. 사건6개를 피칭한다. premise는 발단·인물 반응·내가 당장 할 일의3문장, choices는2~4개의 구체적인 내 행동이다. 숫자 보상은 아직 붙이지 않는다. 공식 소개를 복사하지 말고 basis에서 확인한 역할과 창작 상황을 구분한다. 서류·분류·장부·대금·표시용품을 매번 문제와 해결로 쓰지 않는다.',brief:{sourceFacts,existing:world.events.map(e=>({key:e.key,title:e.title,story:e.story})),directions:[
 '아르고에게 너무 넓은 질문을 해 답의 범위가 어긋나는 작은 정보 거래. 내가 정말 알아야 할 것은 돌아갈 길인가, 다음 상대인가? 베타 정보를 언제나 정답으로 만들거나 NPC가 거짓말했다는 공식 사실을 추가하지 않는다.',
 '아르고가 두 손님에게 같은 정보를 팔자 독점이라고 생각했던 사람이 항의한다. 플레이어는 남의 입을 막는 대신 자신의 구매나 관찰 몫을 정한다. 실제 다른 플레이어 정보·가격·카드 후보를 훔치거나 봉쇄하지 않는다.',
 '통나무집 부근에서 기억을 잃은 소녀에게 사람들이 질문을 한꺼번에 건네 답을 기다리는 장면. 플레이어는 소녀의 기억을 억지로 되찾게 하지 않고 자기 손으로 할 작은 일을 고른다. 유이의 관리자 권한·입양 결말·치료를 보상으로 지급하지 않는다.',
 '디아벨의 공략 회의 뒤 서로 혼자 다니던 두 사람이 한 파티가 되려는데 첫 발걸음부터 엇갈린다. 여행자는 자기 위치와 준비를 정한다. 보스전·회의 진행·디아벨의 사망·비터 평판은 결정하지 않는다.',
 '시리카가 무상으로 도와주겠다는 키리토의 말을 듣고도 이유를 묻는 장면. 여행자는 대가를 대신 요구하거나 원작 대답을 지어내지 않고 자기 보급과 행동으로 대화를 건넨다. 기존 꽃 찾기/몬스터 유도 사건과 다른 문제를 만든다.',
 '첫5개와 기존 사건에서 겹치지 않는 일상 사건1개를 추가한다. 원작 전투를 해결하는 영웅담이나 분류용품을 사는 사무 노동으로 끝내지 않는다.'
],rules:[
 '카드 기억으로 성장·골드·물약·개인 사냥의 적 강함/수만 실제 결과로 허용한다. NPC 동행·원작 장비·소생·스킬 습득·실제 낚시와 미니게임을 약속하지 않는다.',
 '현재 체력 비용·즉시 휴식 회복·추가 행동력·시간 연장은 없다. 사건마다 행동력1을 쓴다. 사건 중 개인 사냥은 정지하므로 몬스터를 실제 추가 처치했다는 결과를 쓰지 않는다.',
 '선택지는 플레이어의 행동이고 원작 인물에게 명령하거나 원작 결말을 대신 정하는 버튼이 아니다. 서로 다른 시점의 창작 방문이며 모든 사건을 같은 날로 연결하지 않는다.',
 '아인크라드의 안전 구역에 사냥 몬스터가 침입했다고 단정하지 않는다. 위험을 고르면 원정의 개인 사냥 조건에 계속 부담을 남기는 방식이다.'
]}};
fs.writeFileSync(path.join(root,'requests/aincrad-pitches-51.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});
console.log('아인크라드 피칭6개 요청 저장.');
