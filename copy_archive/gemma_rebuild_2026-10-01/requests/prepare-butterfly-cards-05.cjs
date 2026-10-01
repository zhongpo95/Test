// 누락된 나비저택 카드 초안을 별도 요청하고 미채택 사건과 이유를 보존한다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const before=JSON.parse(fs.readFileSync(path.join(root,'requests/butterfly-expansion-04.json'),'utf8'));
const removed=[
 {key:'kny_gourd_bundle',reason:'납품 문제라고 시작했지만 실제 선택은 비용을 낸 수련·난도를 올린 수련·일당이라는 기존 위험 수련과 동일하다. 모델은 계획의level+1을density+1로 잘못 옮겼다. 박이라는 물건 이름만으로 충분한 차이가 없다.',revisit:'규격 확인 이후 물건과 인물의 부탁에 개입하는 다른 선택 결과를 구성할 때 다시 검토한다.'},
 {key:'kny_silent_turn',reason:'유료 조언·넓은 구역 맡기·일당이라는 흰 천 운반과 거의 같은 구조다. 카나오만 교체해 또 하나의 정리 사건을 늘리지 않는다.',revisit:'반응 수련 소재에 구체적인 상호작용과 달라지는 결과를 마련한다.'},
 {key:'kny_small_visit',reason:'아오이 유료 보급·시노부 유료 확인·일당이라는 병 이름표 사건의 선택을 반복한다. 외부 대원이 빈손이라는 표면 상황만 달라 이야기와 선택의 변화가 부족하다.',revisit:'문병객의 부탁이 앞선 보급 정리와 다른 문제를 만들도록 다시 구상한다.'}
];
fs.writeFileSync(path.join(root,'revisions/butterfly-expansion-rejected-04.json'),JSON.stringify({rawFile:'drafts/butterfly-expansion-04.json',removed,outputErrors:['새 카드6개 요청 중1개만 반환.5개 카드 참조는 정의가 없다.','JSON null 대신 문자열 null을 카드 참조로 출력했다.','확률 없는 병 정리에 실패 문구를 새로 붙였다.','플레이어 이야기 안에 생활 사건·보스전 성향에 맞는 창작이라는 제작 문구가 남았다.'],handling:'원문은 유지하고 카드 집필은 별도 요청한다. 사건의 숫자·참조는 원래 계획의 값으로 재구성하며 원안과 실제 채택의 차이를 기록한다.'},null,2)+'\n',{flag:'wx'});
const request={review:false,system:'한국어 캐릭터 카드 집필자다. 제공한6개를모두반환하고 key·name·grade·effects·evolution을정확히복사한다. 효과이름은인물의준비나태도이며정책·밸런스항목이름이아니다. 지정숫자를추정하지않는다.',schema:require(path.join(repo,'tools/content-schema.json')),brief:{cards:before.brief.newCards,sourceFacts:before.brief.sourceFacts,format:'cards길이6,events는빈배열[]. key/name/grade/effects/evolution은입력값그대로. effectName/keyword/canonFact/uncertain[]만작성한다. 차지속도와이동속도는%,치명확률은%p,재생은maxHP%/초,처치골드는고정골드다. 신규스킬·독·호흡·일격즉사·자동회피·실제NPC·탐지UI가추가되는효과로쓰지않는다.'}};
fs.writeFileSync(path.join(root,'requests/butterfly-cards-05.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});
console.log('미채택3사건·출력오류와 카드6개 재집필 요청 보존.');
