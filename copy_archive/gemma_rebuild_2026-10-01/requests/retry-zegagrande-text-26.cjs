// 공역 초안의 성공·실패 혼동과 자원 반전 이유를 보존하고 성공 결과만 재집필한다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'..');
const fixed=JSON.parse(fs.readFileSync(path.join(root,'requests/zegagrande-expansion-fixed-25.json'),'utf8'));
const request=JSON.parse(fs.readFileSync(path.join(root,'requests/zegagrande-expansion-text-25.json'),'utf8'));
const original=JSON.parse(fs.readFileSync(path.join(root,'drafts/zegagrande-expansion-text-25.json'),'utf8')).parsed;
const rejected=[
 {key:'gbf_rosetta_dates#1',text:original.events[0].choices[0].result,reason:'70% 성공 결과에 고정 실패문을 복제했다. 성공 카드와 확인 보수180골드가 누락됐다.',revisit:'실패문은 그대로 보존하고 성공 결과를 따로 쓸 때.'},
 {key:'gbf_lancelot_shift#3',text:original.events[2].choices[2].result,reason:'100골드로 물약1개를 받는 선택을 물약 소비로 반전했다.',revisit:'골드 차감·물약 획득·적 단계-1을 모두 맞출 때.'},
 {key:'all_results',reason:'비용·지정 카드에서 얻은 플레이어 성장·골드와 물약·지속되는 적 강함과 수가 자주 빠졌다. 항로 점검 수치·NPC 성공·효율·최적 위치가 실제 보상을 대신했다.',revisit:'기존 필드와 카드 처리에 맞는 구체적 행동 결과를 쓸 때.'}
];
fs.writeFileSync(path.join(root,'revisions/zegagrande-text-rejection-25.json'),JSON.stringify({sourceRevision:'51b0c55',raw:'drafts/zegagrande-expansion-text-25.json',decision:'이야기 상황은 검토 후보로 두되 결과 문장은 미채택하고 재집필한다.',rejected},null,2)+'\n',{flag:'wx'});
const learning={gbf_rosetta_trace:'단서를 더 비교하고 큰 상대의 차이를 찾는 요령',gbf_rolan_guide:'여러 부탁을 확인하고 더 빠르게 이동할 동선을 읽는 요령',gbf_lancelot_roles:'공격 위치를 고르고 다음 동작을 빠르게 잇는 요령',gbf_percival_share:'큰 상대와 작은 상대에 맞춰 힘을 나누는 요령',gbf_yodarha_wait:'몸놀림을 빠르게 하고 움직임에 힘을 싣는 요령',gbf_io_smile:'몸 상태를 지키면서 공격할 힘을 빠르게 모으는 요령',gbf_rackam_signal:'몸 상태를 지키며 빠르게 움직이는 요령',gbf_vane:'더 오래 버티며 받을 부담을 줄이는 요령',gbf_narmaya:'공격 방향과 빈틈을 고르는 요령'};
request.system='한국어 사건 작가다. story는 고정 scene의 인물과 문제를 보존한다. intro는 구체적인 문제 한 문장이다. choices 순서와 key를 유지한다. result는 오직 성공한 결과2~3문장이다. 각 선택의 expectedSuccess를 빠짐없이 지키고 인물의 남은 행동이나 짧은 말을 덧붙인다. 칭찬·효율적·체계적·최적·안전을 확보 같은 반복으로 끝내지 않는다.';
request.brief={sourceFacts:fixed.sourceFacts,events:fixed.events.map(e=>({key:e.key,scene:e.scene,choices:e.choices.map(b=>({action:b.action,expectedSuccess:{paidGold:b.cost,learned:b.card?learning[b.card]:null,receivedGold:b.gold,receivedPotions:b.potions,personalEnemyStrengthChange:b.level,personalEnemyCountChange:b.density},successChance:b.chance}))})),rules:['각 결과는 플레이어가 실제 지불한 골드와 받은 골드·물약, 배운 요령과 개인 몬스터 강함·수의 변화가 있으면 모두 설명한다. 표의0이나null은 새 효과를 만들지 않는다.','로제타 첫선택은 연락에 성공해 주인을 찾고 단서비교·큰상대차이를 배우며160골드를쓴뒤180골드보수를받은 결과다. 실패 가능성·실패 결과를 result에 쓰지 않는다. 별도 고정 실패문이 이미 있다.','랜슬롯 세번째는 물약을 소비하지 않는다.100골드를내고물약1개를받으며개인적단계가1낮아진다.','성공이라고 NPC가 전투에서 이겨 위험이 사라지지 않는다. 새로운 기술·항로점검수치·마법·도구제어·부활·낚시성공·카드 아닌 보너스를 넣지 않는다.','배운 요령은 사건의 특정 행동과 연결한다. 모든 선택 결과를 똑같은 준비 습관이라는 한 문장으로 대체하지 않는다.']};
fs.writeFileSync(path.join(root,'requests/zegagrande-expansion-text-26.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});console.log('첫 결과 오류 보존·성공 결과 재집필 요청 생성.');
