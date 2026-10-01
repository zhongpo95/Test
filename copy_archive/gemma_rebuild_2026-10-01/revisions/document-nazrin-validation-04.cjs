// 나즈린 추가분의 확인한 검사 결과와 스크립트 전용 컴파일 보고서를 보존한다.
'use strict';
const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname,'../../..');
const dir = path.join(__dirname,'../validation');
const report = fs.readFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-content-164-compile-09/report.json');
fs.writeFileSync(path.join(dir,'compile-09.json'),report,{flag:'wx'});
const validation = {
  checkedAt:new Date().toISOString(),
  counts:{heads:10,cards:95,events:78,followups:31},
  checks:[{name:'check-content-rebuild.cjs',exit:0,groups:19},{name:'check-card-stats.cjs',exit:0,groups:8},{name:'generate-prototype-content.cjs --check',exit:0},{name:'generate-content-review.cjs --check',exit:0},{name:'git diff --check -- content tools Data md',exit:0}],
  repairedTest:{file:'tools/check-content-rebuild.cjs',line:188,firstExit:1,reason:'비용과 필드 변화가 함께 있는 선택의 실제 문구는 실패해도 비용과 사냥터 변화는 적용입니다. 비용만 있는 선택의 문구를 기대했던 테스트를 실제 분기에 맞게 수정했습니다. 런타임 코드를 변경한 것은 아닙니다.'},
  compile:'compile-09.json',
  scope:'실제 JASS 함수를 mock native로 실행한 검사와 소스 정적 검사. Warcraft·멀티플레이·UI 렌더링·서버 저장·재미·실제 성능은 미검증.',
  mapCreated:false
};
fs.writeFileSync(path.join(dir,'nazrin-static-mock-06.json'),JSON.stringify(validation,null,2)+'\n',{flag:'wx'});
fs.appendFileSync(path.join(root,'md/roguelite/사건 카드 재제작 검토 기록.md'),'\n나즈린 추가분의 콘텐츠 모의 검사 19그룹과 능력치·회복 8그룹, 생성 데이터·검토 문서 일치 검사, 활성 소스의 diff 검사가 통과했다. 60/61 성공 경계에서 비용·적 단계가 실패에도 남고 자기 후속만 열리는지, 정리 후속이 두 번째 행동력을 쓰는지, 골드 부족·적 단계/수 상한에서 운반 선택이 남는지 확인했다. 첫 검사의 문구 기대값은 실제 비용+필드 안내에 맞게 수정했으며 런타임 우회 수정이 아니다. [검사 기록](../../copy_archive/gemma_rebuild_2026-10-01/validation/nazrin-static-mock-06.json)과 [compile-09](../../copy_archive/gemma_rebuild_2026-10-01/validation/compile-09.json)에 보존했다. 컴파일러·pjass 종료 코드 0, 맵 생성 없음, pjass의 24 errors ignored를 확인했다. Warcraft 실행·화면·실제 재미 검증은 수행하지 않았다.\n');
console.log('나즈린 검증 범위와 컴파일 결과를 보존했습니다.');
