// 후유키의 숙박·궁도부·교회 보호와 막아낸 다음의 판단을 기존 기록 사건과 다르게 요청한다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const current=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/01-fuyuki.json'),'utf8'));
const sourceFacts=[
 {source:'https://www.aniplex.co.jp/lineup/fate-sn-ubw/story/?p=1',part:'4화',fact:'세이버는 영체화할 수 없어 시로가 학교에서 그 존재를 설명하려 한다. 타이가와 사쿠라는 시로의 집에 묵게 된다. 숙박에서 자기 자리를 정하는 별도 방문을 각색하며 세이버를 영체화하거나 원작 신분 설명을 여행자가 확정하지 않는다.'},
 {source:'https://www.fate-sn.com/ubw/chara/',part:'타이가·사쿠라',fact:'타이가는 호무라하라 학원의 영어 교사이자 궁도부 고문이며 시로의 어린 시절부터 누나 같은 사이다. 사쿠라는 시로의 후배이고 가족 같은 관계인 조용한 인물이다. 궁도부의 작은 지도는 창작이며 영령의 검술·보구를 전수하지 않는다.'},
 {source:'https://www.aniplex.co.jp/lineup/fate-sn-ubw/story/?p=1',part:'2·9화',fact:'키레이는 성배전쟁 감독자로서 시로에게 규칙을 설명한다. 9화에서 서번트를 잃은 신지가 교회의 보호를 구한다. 새 만남은 여행자가 감독자의 말을 어디까지 신뢰할지 정하는 별도 방문이며 신지의 새 영령 계약이나 성배전쟁 참여를 보상으로 주지 않는다.'},
 {source:'https://www.aniplex.co.jp/lineup/fate-sn-ubw/story/?p=2',part:'17화',fact:'랜서가 필살 보구를 쓰고 아처가 자신이 가진 가장 강한 방패로 대응한다. 새 사건은 대응 뒤 판단의 역할만 각색한다. 플레이어가 원작 결투 승패·보구 소유권·실제 방패 생성을 결정하지 않는다.'},
 {source:'https://www.aniplex.co.jp/lineup/fate-sn-ubw/story/?p=1',part:'12화',fact:'린 제안의 외출 뒤 캐스터가 타이가를 인질로 잡고 시로에게 자신의 편이 되라고 한다. 시로는 거부하지만 세이버와 영주를 빼앗긴다. 원작 인질을 거래하거나 구출 성공을 여행자에게 결정시키는 사건은 만들지 않는다.'}
];
const request={review:false,schema:read('requests/academy-pitches-57.json').schema,system:'한국어 사건 작가다. 서로 다른 발단5개를 제안한다. premise는 현장 물건·인물 반응·여행자가 당장 결정할 일을3문장으로 쓴다. choices는2~4개 자기 행동이다. 숫자와 새로운 기능을 제안하지 않는다. basis에는 확인된 역할과 별도 창작을 구분한다. 서류 정리·분류표·배달 보수·모두의 칭찬·물건 목록만 반복하지 않는다.',brief:{sourceFacts,existing:current.events.map(e=>({key:e.key,title:e.title,story:e.story})),directions:[
 '잠들 자리를 마련했는데 타이가와 사쿠라가 묵고 세이버도 사라질 수 없다. 여행자는 자기 방문을 마칠지 밖을 살필지 침구를 내놓을지 정한다. 집주인·손님의 몸이나 숙박을 대신 결정하지 않는다.',
 '궁도부에서 자신이 놓은 화살이 표적보다 먼저 바닥에 닿았다. 타이가는 실패의 원인을 자기 동작에서 보라고 한다. 여행자는 다음 한 발을 서두를지 자세를 기다릴지 정한다. 실제 사격 미니게임·성능 좋은 원작 활 지급은 없다.',
 '교회에서 감독자 키레이가 보호와 위험에 대한 설명을 한다. 여행자는 설명을 들으면 안전이 보장된다고 생각하다가 남은 질문을 발견한다. 신지의 계약·원작 뒷계획을 해결하지 않는다.',
 '아처와 랜서의 강한 대응 역할에서 막아낸 뒤에도 다음 공격을 봐야 하는 별도 만남을 만든다. 기존 두이상 논쟁·검술 간격·창 갈림길과 다른 상황이어야 한다. 원작 보구·NPC의 결투 승패·방패 생성 보상은 없다.',
 '캐스터의 조건 제시 역할에서 여행자가 조건 없는 말에 어디까지 답할지 정하는 작은 만남을 제안한다. 타이가나 세이버를 거래·구출하지 않고 영주·계약을 보상으로 주지 않는다.'
],rules:[
 '카드는 만난 인물에게 연결되는 성장 기억이다. 지정 카드·골드·물약·이후 개인 사냥 강함/수만 실제 결과다. 현재체력 비용·새 AP·시간·새 능력·영구 무기·자동방패·NPC동행·실제 추가 처치는 없다.',
 '모든 방문은 창작이고 원작 여러 날짜를 하나의 날로 묶지 않는다. 원작 대결과 죽음·계약을 바꾸지 않는다.',
 '피칭을 통째로 합격시킬 필요 없다. 개별 장면의 재미와 이름만 바꾼 메뉴인지 검토한다.'
]}};
fs.writeFileSync(path.join(root,'requests/fuyuki-pitches-62.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});console.log('후유키피칭5개요청저장.');
