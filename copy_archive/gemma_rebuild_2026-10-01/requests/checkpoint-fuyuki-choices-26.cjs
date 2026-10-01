// 후유키 세 카드 선택의 폐기·수정·검증 결과와 다음 머리의 진행 범위를 기록한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const data=fs.readdirSync('content/roguelite').filter(f=>f.endsWith('.json')).map(f=>JSON.parse(fs.readFileSync(path.join('content/roguelite',f),'utf8')));
const counts={heads:data.filter(d=>d.world.key!=='common').length,cards:data.reduce((n,d)=>n+d.cards.length,0),events:data.reduce((n,d)=>n+d.events.length,0),roots:data.reduce((n,d)=>n+d.events.filter(e=>!e.previous).length,0),followups:data.reduce((n,d)=>n+d.events.filter(e=>e.previous).length,0)};
assert.deepEqual(counts,{heads:13,cards:240,events:217,roots:169,followups:48});
const compile=JSON.parse(fs.readFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-content-164-compile-30/report.json','utf8')),probe=read('validation/head-card-choices-probe-16.json'),ci=read('validation/ci-commands-26.json'),monitor=read('validation/monitor-content-check-26.json');
assert.equal(compile.compiler_exit,0);assert.equal(compile.pjass_exit,0);assert.equal(compile.map_created,false);assert(probe.passed&&ci.passed);assert.equal(probe.branchCases,102);assert.equal(monitor.checks.length,9);
write('validation/compile-30.json',compile);
write('validation/head-choices-check-26.json',{counts,rewrittenEvents:16,choices:48,newCards:2,branchCases:102,newMemoryStats:probe.newMemoryStats,lowerBounds:probe.lowerBounds.length,ciCommands:15,monitorRecords:9,compilerExit:0,pjassExit:0,ignoredErrors:24,scriptSha256:compile.script_sha256,mapCreated:false,usage:{used:42,remaining:58},review:'PASS/PASS/PASS',scope:'후유키16개와나비저택17개는서로다른세카드선택.다른머리계속작업.',probeCorrection:'ProtoGrantHead만직접호출한모형은입문카드를주지않는것이정상이다. 새능력치검사에서실제머리후보선택/ProtoResolve를거쳐입문공격8+머리3을얻고23/35합산을검사했다. 실제코드는변경하지않았다.',limits:['정적·실제JASS함수의변환모의·스크립트컴파일이다.','Warcraft·화면·실전멀티·서버저장·재미·밸런스는미검증이다.']});
function replace(file,a,b){const p=path.join(repo,file),s=fs.readFileSync(p,'utf8');assert(s.includes(a),file);fs.writeFileSync(p,s.replace(a,b));}
function append(file,text){fs.appendFileSync(path.join(repo,file),'\n'+text+'\n');}
replace('md/roguelite/사건 카드 재제작 검토 기록.md','현재 후보는 머리 13종, 성장 카드 238종, 사건 217개다.','현재 후보는 머리 13종, 성장 카드 240종, 사건 217개다.');
replace('md/roguelite/사건 카드 재제작 검토 기록.md','등급은 노말 20장·레어 207장·에픽 11장.','등급은 노말 20장·레어 209장·에픽 11장.');
append('md/roguelite/사건 카드 재제작 검토 기록.md',`## 후유키의 세 카드와 입문 카드 반복 제거

후유키16개 사건을 서로 다른 카드3장으로 구성했다. 즉시 골드를 주던11개 선택의 보상을 제거하고, 마지막 일당 대안은 현장에서 다른 행동을 하는 카드로 바꿨다. 학교·길목·진술에서 입문 카드만 다시 얻던4개 선택은 시로의 새 기억으로 대체했다. 「맞춰 본 빈칸」은 공격력12%와 일반 행동속도3%, 「이름 없이 맡긴 부탁」은 공격력12%와 받는 피해 감소2%다. 기존21개 카드 수치와 머리 효과는 유지했다.

집필79-1은 일곱 사건을 한 사건의 결과 문자열 안에 섞고 요청하지 않은 메타데이터를 붙여 폐기했다.79-2는 다른 언어와 아처의 다른 카드 수치를 섞고 적 수·물약을 누락했다. 원문은 그대로 보존했다.80에서는 수정할 분기만 네 사건 이하로 나눠 구조를 확인했지만, 보상과 부담을 빠뜨린 결과는 [수정81](../../copy_archive/gemma_rebuild_2026-10-01/revisions/fuyuki-card-choices-curation-81.json)에서 실제 카드와 현장 반응에 맞췄다. 세 묶음의 역검토81은 PASS지만 자문이다.

[102분기 검사](../../copy_archive/gemma_rebuild_2026-10-01/validation/head-card-choices-probe-16.json)는 비용·확률·물약·지속 필드·중복100골드와 학교 연결끊기1번/타이가 질문1번의 자기 후속을 대조했다. 실제 머리 사건에서 입문 공격8%와 머리3%를 얻은 뒤, 새 카드로 합산 공격이11→23→35%가 되는 것을 검사했다. 일반 행동속도3%·피해감소2%와 중복 비중첩, 다른 플레이어의 미변경도 확인했다.

[15회귀 검사](../../copy_archive/gemma_rebuild_2026-10-01/validation/ci-commands-26.json), [Gemma9요청 상세 기록](../../copy_archive/gemma_rebuild_2026-10-01/validation/monitor-content-check-26.json), [스크립트 컴파일30](../../copy_archive/gemma_rebuild_2026-10-01/validation/compile-30.json)이 통과했다. 컴파일의 기존 ignored 오류24개를 포함하며 실제 Warcraft·화면·멀티·재미·밸런스는 미검증이다. 맵 파일은 만들지 않았다.

새 세 카드 구성은 후유키16개와 나비저택17개, 합계33개 사건에 적용했다. 다른 머리도 같은 기준으로 계속 작업한다. 전체는 카드240장·사건217개·독립169개·개인후속48개다.`);
append('md/roguelite/머리별 사건 확장 계획.md',`## 후유키 보상 세 갈래

후유키는 카드23장·독립14개·후속2개를 유지한다. 사건16개의48선택은 서로 다른 지정 카드로 이어지고 입문 카드 반복과 직접 골드 대안은 없다. 화살 질문 성공1번에서 열린 후속의 확률 선택과 확정 선택도 다른 카드가 된다. 학교 연결끊기1번의 후속 번호는 유지한다.

전체는 카드240장·217사건이며 독립169개·후속48개다. 세 카드 재구성이 끝난 두 머리는33사건·99선택이다. 남은 머리에서는 장면에 없는 인물을 억지로 넣거나 이미 받은 입문/직전 후속 카드를 숫자를 채우려고 다시 주지 않는다.`);
append('md/roguelite/폐기된 사건 카드 아이디어.md',`## 후유키의 일당 대안과 초안 혼입

기존 골드 대안, 입문 카드만 반복하는 선택, 같은 타이가 카드를 가격·부담만 바꿔 주는 선택을 활성 콘텐츠에서 제외했다. [변경 전 원본79](../../copy_archive/gemma_rebuild_2026-10-01/before-fuyuki-card-choices-79.json)와 [고정 변경안79](../../copy_archive/gemma_rebuild_2026-10-01/requests/fuyuki-card-choices-fixed-79.json)에 보존했다. 단순히 저렴한 마지막 일당 대안으로 되돌리지 않는다.

79-1의 사건 병합·결과 문자열 안의 메타데이터,79-2의 다른 언어·아처 카드 혼동은 폐기했다. [폐기 이유80](../../copy_archive/gemma_rebuild_2026-10-01/revisions/fuyuki-card-choices-draft-rejection-80.json)과 [수정81](../../copy_archive/gemma_rebuild_2026-10-01/revisions/fuyuki-card-choices-curation-81.json), [채택82](../../copy_archive/gemma_rebuild_2026-10-01/revisions/fuyuki-card-choices-decision-82.json)에 구조·지정효과·필드·물약의 대조를 다시 통과해야 한다는 재검토 조건을 남겼다. 모니터링 원문은 고치지 않았다.`);
append('md/roguelite/카드 능력치 단위와 검토 기준.md',`## 시로의 두 기억과 소유 확인

머리에서 받은 입문 카드가 사건의 정상 성장 보상으로 반복되지 않도록 후유키4선택을 새 기억으로 바꿨다. 공격력12%에 행동속도3%를 더하는 카드와 공격력12%에 피해감소2%를 더하는 카드는 서로 다른 준비다. 새 스탯이나 전투 기능을 추가하지 않았다. 입문·머리 합산11%에서 두 카드로23/35%가 되고 같은 카드를 직접 다시 지급해도 중첩하지 않는 것을 실제 JASS 변환 함수로 검사했다. 실전 가치와 선택률은 별도 테스트가 필요하다.`);
append('copy_archive/gemma_rebuild_2026-10-01/README.md','후유키79~82에서16사건을서로다른세카드48선택으로재구성했다. 직접골드11선택·입문카드반복4선택·타이가동일카드가격차를교체하고시로기억2장을더했다. 원본바이트/해시·집필79/80·폐기/수정81·세PASS/채택82를보존한다.102분기·입문및새기억합산·15회귀·compile30·9공통저장기록대조가통과했다. 맵/Warcraft/실제화면/멀티/재미는없으며다른머리는계속작업한다.');
let body=fs.readFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-pr-165-body-25.md','utf8');
body=body.replaceAll('238카드','240카드').replace('나비저택17사건51선택부터 적용했고','나비저택17사건51선택과 후유키16사건48선택에 적용했고').replace('최근나비저택108분기','최근후유키102분기와나비저택108분기').replace('최근세REVISE의변화량/레벨오독은실제코드로반려하고신속/체력조건접속은보완했다.','나비저택세REVISE의변화량/레벨오독은실제코드로반려했고 후유키세PASS도자문으로보존했다. 후유키초안의사건병합·다른언어·카드혼동·물약누락은수정전후로분리했다.').replace('스크립트전용컴파일29','스크립트전용컴파일30').replace('compile-29.json','compile-30.json').replace('head-card-choices-probe-15.json','head-card-choices-probe-16.json').replace('ci-commands-25.json','ci-commands-26.json');
body=body.replace('사건후보2~4개·사냥10골드','후유키 입문카드 반복4선택을 새 시로 기억2장으로 대체했고 기존21카드 효과는 유지했다. 사건후보2~4개·사냥10골드');
fs.writeFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-pr-165-body-26.md',body,{flag:'wx'});
console.log(JSON.stringify({counts,headEvents:16,branches:102,completedChoiceHeads:2,completedChoiceEvents:33,compile:30,mapCreated:false}));
