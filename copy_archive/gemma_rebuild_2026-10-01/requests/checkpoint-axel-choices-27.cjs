// 액셀 세 카드 선택과 돈 예외의 채택·폐기·검증 범위를 기록하고 기존 초안 PR 설명을 갱신한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const data=fs.readdirSync('content/roguelite').filter(f=>f.endsWith('.json')).map(f=>JSON.parse(fs.readFileSync(path.join('content/roguelite',f),'utf8')));
const counts={heads:data.filter(d=>d.world.key!=='common').length,cards:data.reduce((n,d)=>n+d.cards.length,0),events:data.reduce((n,d)=>n+d.events.length,0),roots:data.reduce((n,d)=>n+d.events.filter(e=>!e.previous).length,0),followups:data.reduce((n,d)=>n+d.events.filter(e=>e.previous).length,0)};
assert.deepEqual(counts,{heads:13,cards:248,events:217,roots:169,followups:48});
const compile=JSON.parse(fs.readFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-content-164-compile-31/report.json','utf8')),probe=read('validation/head-card-choices-probe-17.json'),ci=read('validation/ci-commands-27-passed.json'),monitor=read('validation/monitor-content-check-27.json');
assert.equal(compile.compiler_exit,0);assert.equal(compile.pjass_exit,0);assert.equal(compile.map_created,false);assert(probe.passed&&ci.passed);assert.equal(probe.branchCases,99);assert.equal(monitor.checks.length,7);
write('validation/compile-31.json',compile);
write('validation/head-choices-check-27.json',{counts,rewrittenEvents:16,choices:49,newCards:8,branchCases:99,newMemoryStats:probe.newMemoryStats,noParentCardRepeat:probe.noParentCardRepeat,directGoldChoices:1,removedGoldChoices:13,ciCommands:15,monitorRecords:7,compilerExit:0,pjassExit:0,ignoredErrors:24,scriptSha256:compile.script_sha256,mapCreated:false,usage:{used:43,remaining:57},review:'PASS/PASS/PASS',scope:'세 머리49사건에 서로 다른 지정카드3종을 적용했다. 명세서 사건만 돈 예외를 더한다. 다른 머리는 계속 작업한다.',testCorrections:['새 검사에서 존재하지 않는 PROTO_STAT_DIRECTIONAL 이름을 실제 PROTO_STAT_DIRECTION으로 고쳤다. 실제 코드 변경은 없다.','기존 시간초과 검사가 장부180골드·보급160골드와 모든사건무료분기를 가정했다. 새 장부무료바니르 카드/몬스터강함2, 보급비80지불/아쿠아비상분카드/물약2/AP1회를 검사하도록 고쳤다. 자동선택·합류 로직은 변경하지 않았다.'],limits:['정적·JASS변환모의·스크립트컴파일이며 실제 Warcraft·시각·멀티·서버저장·재미·실전밸런스는 미검증이다.']});
function replace(file,a,b){const p=path.join(repo,file),s=fs.readFileSync(p,'utf8');assert(s.includes(a),file);fs.writeFileSync(p,s.replace(a,b));}
function append(file,text){fs.appendFileSync(path.join(repo,file),'\n'+text+'\n');}
replace('md/roguelite/사건 카드 재제작 검토 기록.md','현재 후보는 머리 13종, 성장 카드 240종, 사건 217개다.','현재 후보는 머리 13종, 성장 카드 248종, 사건 217개다.');
replace('md/roguelite/사건 카드 재제작 검토 기록.md','등급은 노말 20장·레어 209장·에픽 11장.','등급은 노말 20장·레어 217장·에픽 11장.');
append('md/roguelite/사건 카드 재제작 검토 기록.md',`## 액셀의 세 카드와 돈 자체가 문제인 예외

액셀16개 사건에 서로 다른 카드3종을 배치했다. 15개는 세 선택이고 사라진 명세서 사건은 크리스 손놀림·흔적과 카즈마 몫의 세 카드에 기존 명세서 재발행230골드 선택을 보존한 네 선택이다. 일반 일당·정리 보수13개는 제거했다. 기존18개 카드와 머리 효과는 유지하고 역할별 기억8장을 추가했다.

우리 고정용품 성공1번 뒤의 후속에서 부모가 이미 준 아쿠아 줄 카드를 반복하지 않는다. 카즈마의 「손을 떼는 순서」는 여전히 후속 전용이고 실패75%의 비용도 유지한다. 밀린 의뢰의 자기 성공1번에서만 사라진 명세서를 만난다. 변경 전 원본83과 [채택85](../../copy_archive/gemma_rebuild_2026-10-01/revisions/axel-card-choices-decision-85.json)에 해시·예외·후속을 남겼다. 고정안83의 골드 제거12는 집계 오기이며 실제 원본14개 중13개 제거다.

Gemma 집필83은 비용을 골드 지급으로 뒤집고 물약·필드 변화를 누락했으며 칭찬·끄덕임이 반복됐다. [수정84](../../copy_archive/gemma_rebuild_2026-10-01/revisions/axel-card-choices-curation-84.json)는21결과를 현장의 남은 문제·기억·실제 지속 부담과 지급에 맞춰 다시 썼다. 독립 역검토 세 PASS는 자문이며 원문을 그대로 보존한다.

[99분기 검사](../../copy_archive/gemma_rebuild_2026-10-01/validation/head-card-choices-probe-17.json)는 비용·확률·물약·필드·중복100골드·AP1회·두 개인 후속과 골드 예외를 대조했다. 여덟 새 기억의 합산과 중복 비중첩·다른 플레이어 미변경, 부모 소유 카드 반복 없음도 통과했다. [15회귀 검사](../../copy_archive/gemma_rebuild_2026-10-01/validation/ci-commands-27-passed.json)와 [7저장기록 대조](../../copy_archive/gemma_rebuild_2026-10-01/validation/monitor-content-check-27.json)가 통과했다. 기존 시간초과 테스트의180/160골드 기대는 새 카드·비용·물약·필드 확인으로 바꿨으며 자동처리 로직은 변경하지 않았다.

[스크립트 컴파일31](../../copy_archive/gemma_rebuild_2026-10-01/validation/compile-31.json)은 compiler/pjass0과 기존 ignored24개다. 맵은 만들지 않았고 Warcraft·시각·멀티·저장·재미·밸런스는 미검증이다. 세 카드 재구성은 나비저택·후유키·액셀49사건148선택까지 진행했다. 전체는 카드248장·217사건·독립169개·후속48개이며 다른 머리는 계속 정리한다.`);
append('md/roguelite/머리별 사건 확장 계획.md',`## 액셀 보상 세 갈래

액셀은 카드26장·독립14개·후속2개다. 16사건 모두 지정카드 세 가지를 비교한다. 명세서의 재발행만 이야기의 돈 문제여서 네 번째 종류의 선택으로 남겼으며 선택번호는 기존2번을 보존한다. 일당 대안13개와 같은 카드의 비용 차이는 제외했다. 두 자기 성공1번 후속과 카즈마 후속 전용 기억을 유지하며 부모 소유 카드를 후속에 다시 주지 않는다.

세 카드 정리가 끝난 머리는 나비저택·후유키·액셀이다. 합계49사건148선택이며 나머지 머리와 공통 사건은 계속 작업한다. 전체는 카드248장·사건217개다.`);
append('md/roguelite/폐기된 사건 카드 아이디어.md',`## 액셀의 일당과 동일 카드 가격 차이

일반 일당·정리 보수13개, 눈 발자국과 위즈 질문에서 동일카드를 비용만 바꿔 주던 선택을 제외했다. 이미 소유한 부모 카드가 후속의 정상 성장으로 보이는 구성도 피했다. 돈이 핵심인 사라진 명세서 재발행230골드는 명시적 예외다. [원본83](../../copy_archive/gemma_rebuild_2026-10-01/before-axel-card-choices-83.json)에 기존 전체를 보존했다.

비용을 지급으로 뒤집은 초안, 물약·필드 누락, -1감소의 이중 음수, 인물의 반복 칭찬은 [수정84](../../copy_archive/gemma_rebuild_2026-10-01/revisions/axel-card-choices-curation-84.json)에서 제외 이유와 원문을 나눴다. 재검토 때는 지정 기억·실제 비용·물약·지속 필드·현장의 남은 문제가 함께 맞아야 한다. 역검토 PASS를 근거로 원작의 새 기술·장비·부활을 추가하지 않는다.`);
append('md/roguelite/참고 시트와 설정 확인 범위.md',`## 액셀 세 카드 재구성의 확인 범위

[공식3기 인물 소개](https://konosuba.com/3rd/character/)에서 크리스의 도적 역할, 아쿠아의 회복 담당과 음식·돌·연회 재주, 다크니스의 방어·서툰 공격·귀여운 취향, 루나의 안내, 위즈의 가게, 융융과 메구밍의 관계를 재확인했다. [공식1기 줄거리](https://konosuba.com/1st/story/)의5화 우리 정화·7화 달아나는 눈의 정령·8화 위즈의 가르침 방해와 제령 의뢰를 사용한다. 카드 기억·대화·비용·개인 사냥 조건은 별도 각색이고 원작 주문·장비·실제 수중/정령 전투·주요 결말을 새로 지급하지 않는다.`);
append('md/roguelite/카드 능력치 단위와 검토 기준.md',`## 액셀의 서로 다른 성장과 예외

크리스의 이동/치명 피해, 카즈마의 공격력/치명 확률, 아쿠아의 최대체력/재생 또는 재생/받는피해, 루나의 사건후보/받는피해, 융융의 차지속도/치명피해, 다크니스의 방향피해/받는피해, 위즈의 차지속도/받는피해를 기존 스탯의 새 기억으로 배치했다. 기본 효과의 같은 등급 성분 우월 비교는0쌍이지만 조건 빈도·비용·각성·실전 선택률의 균형을 증명하지 않는다. 후속에서는 그 후속을 연 부모 선택이 이미 준 카드를 정상 성장 선택으로 반복하지 않는다.`);
append('copy_archive/gemma_rebuild_2026-10-01/README.md','액셀83~85와검증27은16사건49선택의세지정카드를적용했다. 원본18카드/머리효과보존,8기억추가,직접골드13개제거와명세서230골드1개예외,두자기후속과부모카드반복없음을기록했다. 집필4/역검토3원문·7모니터기록·99분기·합산·15회귀최종통과·compile31을보존한다. 초기회귀실패는기존골드기대값이며실제자동처리코드는바꾸지않았다. 맵/Warcraft/시각/멀티/재미는없고나머지머리는진행중이다.');
let body=fs.readFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-pr-165-body-26.md','utf8');
body=body.replaceAll('240카드','248카드').replace('나비저택17사건51선택과 후유키16사건48선택에 적용했고','나비저택17사건51선택·후유키16사건48선택·액셀16사건49선택에 적용했고').replace('최근후유키102분기와나비저택108분기','최근액셀99분기·후유키102분기·나비저택108분기').replace('스크립트전용컴파일30','스크립트전용컴파일31').replace('compile-30.json','compile-31.json').replace('head-card-choices-probe-16.json','head-card-choices-probe-17.json').replace('ci-commands-26.json','ci-commands-27-passed.json');
body+='\n액셀은 기존18카드와 머리효과를 유지하고 기억8장을 추가했다. 일당 대안13개를 제거했으며 명세서 재발행230골드는 돈 자체가 문제인 예외다. 이 사건도 세 지정카드를 비교한다. 시간초과 회귀의 옛 골드 기대값을 새 카드·비용·물약·필드 검사로 갱신했고 자동처리 로직은 변경하지 않았다.\n';
body=body.replace('즉시골드 대안은 제거했다.','일반 즉시골드 대안은 제거하고 명세서 재발행230골드만 예외로 남겼다.').replace('9Gemma요청','최근7Gemma요청').replace('컴파일31는','컴파일31은');
fs.writeFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-pr-165-body-27.md',body,{flag:'wx'});
console.log(JSON.stringify({counts,headEvents:16,branches:99,completedChoiceHeads:3,completedChoiceEvents:49,compile:31,mapCreated:false}));
