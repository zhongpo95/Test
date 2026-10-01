// 나비저택 확장과 세 카드 선택의 원안·폐기 이유·검증 범위를 문서와 PR 초안에 기록한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const list=fs.readdirSync('content/roguelite').filter(f=>f.endsWith('.json')).map(f=>JSON.parse(fs.readFileSync(path.join('content/roguelite',f),'utf8')));
const counts={heads:list.filter(d=>d.world.key!=='common').length,cards:list.reduce((n,d)=>n+d.cards.length,0),events:list.reduce((n,d)=>n+d.events.length,0),roots:list.reduce((n,d)=>n+d.events.filter(e=>!e.previous).length,0),followups:list.reduce((n,d)=>n+d.events.filter(e=>e.previous).length,0)};
assert.deepEqual(counts,{heads:13,cards:238,events:217,roots:169,followups:48});
const compile=JSON.parse(fs.readFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-content-164-compile-29/report.json','utf8')),probe=read('validation/head-card-choices-probe-15.json'),ci=read('validation/ci-commands-25.json'),monitor=read('validation/monitor-content-check-25.json'),condition=read('validation/card-condition-probe-75.json');
assert.equal(compile.compiler_exit,0);assert.equal(compile.pjass_exit,0);assert.equal(compile.map_created,false);assert(probe.passed&&ci.passed&&condition.passed);assert.equal(probe.branchCases,108);assert.equal(monitor.checks.length,9);
write('validation/compile-29.json',compile);
write('validation/head-expansion-check-25.json',{counts,contentGroups:21,statGroups:8,ciCommands:15,expandedRoots:4,expandedFollowups:1,expandedCards:6,rewrittenEvents:17,distinctCardsPerEvent:3,directGoldChoicesInButterfly:0,branchCases:108,lowerBounds:probe.lowerBounds.length,compilerExit:0,pjassExit:0,ignoredErrors:24,scriptSha256:compile.script_sha256,mapCreated:false,monitorCheckedRequests:9,usage:{used:42,remaining:58},modelReview:'확장과 세 묶음 모두 REVISE 원문을 보존',limits:['새 선택 구성은 나비저택부터 적용했다. 다른 머리는 같은 기준으로 계속 수정한다.','Gemma의변화량/상태오독은실제함수와모의결과로반려하고신속/체력조건표현은보완했다.','Warcraft·시각·실전멀티·서버저장·재미·밸런스는미검증이다.'],probeCorrection:'처음모의실패는앞선실패판정100을후보의가중난수에도돌려준검사도우미오류였다. 후보추첨만요청범위의최솟값을돌려주고분기판정난수를복원해통과했다. 실제코드는바꾸지않았다.'});
function replace(file,a,b){const p=path.join(repo,file),s=fs.readFileSync(p,'utf8');assert(s.includes(a),file);fs.writeFileSync(p,s.replace(a,b));}
function append(file,text){fs.appendFileSync(path.join(repo,file),'\n'+text+'\n');}
replace('md/roguelite/사건 카드 재제작 검토 기록.md','현재 후보는 머리 13종, 성장 카드 232종, 사건 212개다. 독립 사건 165개와 개인 후속 사건 47개다.','현재 후보는 머리 13종, 성장 카드 238종, 사건 217개다. 독립 사건 169개와 개인 후속 사건 48개다.');
replace('md/roguelite/사건 카드 재제작 검토 기록.md','등급은 노말 20장·레어 201장·에픽 11장.','등급은 노말 20장·레어 207장·에픽 11장.');
append('md/roguelite/사건 카드 재제작 검토 기록.md',`## 나비저택 확장과 카드 세 갈래 선택

표주박의 크기, 아침 인사 사이의 호흡, 거두지 않은 손, 가림막 너머 발판을 독립4사건으로 더했다. 자기 첫 표주박60%도전의 성공1번에서만 이어지는 후속1사건과 카드6장을 더해 나비저택은 카드21장·사건17개·독립14개·후속3개다. 피칭72에서 기존 격려와 겹친2발단을 폐기했다. 집필73의120/220분기 반전·성공을 실패로 쓴 결과·표주박을 손으로 치는 행동·선택전지불·방향조건누락을 수정74/75에 보존했다.

사용자의 새 지시에 따라 사건 안의 보상은 서로 다른 카드3종을 비교하는 방향으로 바꾼다. 사건 후보2~4개는 별개로 유지한다. 나비저택17사건은51선택 모두 지정카드1장으로 이어지고 즉시골드는0이다. 골드만 받던 대안과 같은카드를 가격만 바꿔 주던 대안을 장면에 맞는 다른카드 행동으로 교체했다. 세카드 초안76의물약소비/부담누락/칭찬반복과사라진보수를 정리하는 문장은 [수정77](../../copy_archive/gemma_rebuild_2026-10-01/revisions/butterfly-card-choices-curation-77.json)에 남겼다. 다른 머리는 계속 재구성한다.

[역검토77 세 응답](../../copy_archive/gemma_rebuild_2026-10-01/revisions/butterfly-card-choices-decision-78.json)의REVISE 원문은 그대로 남겼다. density초기4/변화량-1/최저1을 초기0·최종값으로 오독한 지적과 사냥몬스터강함을 플레이어레벨보상으로 읽은 지적은 실제함수로반려했다. 카드설명이없다는의견은ProtoGrantEventCard가결과UI에덧붙이는이름·효과와대조했다. 신속과65%체력조건은접속표현을보완했다.

[108분기](../../copy_archive/gemma_rebuild_2026-10-01/validation/head-card-choices-probe-15.json)와[15회귀검사](../../copy_archive/gemma_rebuild_2026-10-01/validation/ci-commands-25.json)가통과했다. 야간성공1/실패-1/표주박성공1의자기후속,물약지급,비용과실패부담,중복100골드,상한/하한,유효선택없는사건후보제외를검사했다. [Gemma9요청기록](../../copy_archive/gemma_rebuild_2026-10-01/validation/monitor-content-check-25.json)의입력·원문·ID가공통저장기록과일치했다. [compile29](../../copy_archive/gemma_rebuild_2026-10-01/validation/compile-29.json)은JassHelper/pjass종료0이며기존ignored오류24개를포함한다. 실제Warcraft·시각·멀티·재미·밸런스는미검증이고맵은만들지않았다.`);
append('md/roguelite/머리별 사건 확장 계획.md',`## 나비저택과 세 카드 비교의 첫 적용

전체는 카드238장·사건217개·독립169개·후속48개다. 나비저택은 카드21장·독립14개·후속3개이고, 새 표주박 후속은 자기60%도전 성공1번만 요구한다. 기존 야간수색 성공1/실패-1도 유지한다.

현재 나비저택17사건만 세개의서로다른카드 행동으로 재구성했다. 예를들어 표주박의 첫 도전은 차지피해/행동속도,꾸준한숨은재생/체력조건피해,도구를거두는차례는행동속도/보스피해의카드로 이어진다. 확률·비용·적수변화·물약보급도 함께비교한다. 다른 머리의골드대안과두갈래는같은기준으로계속작업한다. 수량목표로무관한카드·미확인원작장면을채우지않는다.`);
append('md/roguelite/폐기된 사건 카드 아이디어.md',`## 나비저택 초안과 보수만 받는 대안의 폐기

피칭72의 단순격려와 기진맥진한훈련은 기존 돌아오는훈련과역할이겹쳐 제외했다. 미확인찻잔/동전장면·카나에/카나오혼동은 채택하지않았다. [원안과재검토조건72](../../copy_archive/gemma_rebuild_2026-10-01/revisions/butterfly-pitches-selection-72.json)에보존했다.

골드가카드대안으로반복되던나비저택기존선택과가격만다른동일카드분기는활성콘텐츠에서뺐다. [변경전정확한바이트76](../../copy_archive/gemma_rebuild_2026-10-01/before-butterfly-card-choices-76.json)와[수정전후77](../../copy_archive/gemma_rebuild_2026-10-01/revisions/butterfly-card-choices-curation-77.json)에보관했다. 돈·내기자체가중심인사건에서그대가를판단하게만드는경우에만골드보상재검토가가능하다. 단순히마지막저가대안으로붙이는일당은복원하지않는다.

초안76의물약1/2개를소비하는결과·개인필드감소누락·NPC가새능력을주는칭찬반복은제거했다. Gemma의음수변화량과플레이어레벨오독은원문을고치지않고[반려근거78](../../copy_archive/gemma_rebuild_2026-10-01/revisions/butterfly-card-choices-decision-78.json)에분리했다. 신속과체력조건의접속은표현보완으로남겼다.`);
append('md/roguelite/참고 시트와 설정 확인 범위.md',`## 나비저택72의 공식 훈련과 표주박

[공식24화](https://kimetsu.com/anime/risshihen/story/?story=24)의회복훈련과좌절,[공식25화](https://kimetsu.com/anime/risshihen/story/?story=25)의지속호흡연습과두사람의복귀를읽었다. 공식탄지로·이노스케·카나오소개를확인하고, [USJ공식협업자료](https://www.usj.co.jp/company/news/2024/pdf/0513.pdf)의표주박이탄지로의나비저택훈련도구라는설명을대조했다. 크기·가격·성공확률·손을거두는시험·아침인사·가림막·대사는별도창작이다. 특정찻잔/동전장면·영상전편·원작전체를확인했다는뜻은아니다. 호흡완성/감지/미니게임/장비/동행을실제로지급하지않고여행자의기억카드로연결한다.`);
append('md/roguelite/카드 능력치 단위와 검토 기준.md',`## 사건 보상의 세 카드 비교

사용자지시에따라골드만주는대안을대부분제거하고사건안에서서로다른카드3종을기본비교한다. 사건후보2~4개·리롤500골드부터+100·사냥10골드·카드중복100골드는별개다. 나비저택부터17사건51선택에적용했으며다른머리는진행중이다. 같은NPC의카드도서로다른효과/행동의기억을가져야한다. 후속전용카드를원사건에서미리주지않는다. 카드수급을표시수로만늘리지않고현재보유카드·비용·개인필드부담을비교하게한다.`);
append('copy_archive/gemma_rebuild_2026-10-01/README.md','나비저택72~75에6카드·독립4사건·자기표주박성공1번후속1사건을추가했다. 새사용자지시로76~78에서전체17사건을서로다른세카드51선택으로재구성하고즉시골드보상을제거했다. 변경전바이트/해시·Gemma초안·54수정·세REVISE와13지적반증/표현보완을보존한다.108분기·카드조건75·15회귀·compile29·9공통기록원문대조통과,Warcraft/화면/멀티/재미미검증,맵미제작이다.검사도우미의가중난수범위오류는실제코드변경없이수정했다.다른머리의세카드재구성은계속한다.');
const body=`사건을 거치며 성장해도 피해 수치와 무작위 카드에 편중되어 선택의 차이가 적었다. 기존 콘텐츠를 원본·해시와 함께 보관하고 머리별 장면과 지정 성장 카드를 다시 구성한다. Draft이며 병합하지 않는다.

- 머리 시스템은 유지하고13머리·238카드·217사건을 구성했다. 독립169개·개인후속48개이며 최종규모상한이 아니다. 제공시트와 원작소개/줄거리의 확인범위는 별도문서로 남긴다.
- 공격력%·대미지/최종/추가피해 구분·대상별피해·치명·신속·방향/차지/보호막/체력조건·흡수·재생 등24능력치를 연결했다. 흡수/재생합산초당최대체력10%이며 물약은 별개다. 체력지불 사건은 제외한다. 기존각인/치명과폐기콘텐츠는copy_archive에보존하고Import에서제외한다.
- 새 요청에 따라 사건 안에서 서로 다른 카드 세 장을 비교한다. 나비저택17사건51선택부터 적용했고 즉시골드 대안은 제거했다. 개인후속은 야간수색 성공1/실패-1,표주박도전 성공1을 그대로 요구한다. 사건후보2~4개·사냥10골드·리롤500부터+100·중복100골드는 유지한다. 다른 머리의세카드재구성은 계속 진행중이다.
- Gemma4는공통모니터링API를통해집필/역검토한다. 원문과수정·폐기·재검토조건을분리보존한다. 최근세REVISE의변화량/레벨오독은실제코드로반려하고신속/체력조건접속은보완했다. PASS/REVISE는자문이다.

정적·모의 검증을 수행했다.15회귀명령이통과했고 최근나비저택108분기에서지정세카드·실패비용·물약지급·개인성공/실패후속·AP·중복·필드상한/하한·유효선택없는사건제외를대조했다. 실제피해함수모의검사로방향유효각도·차지태그·65%체력조건도대조했다.9Gemma요청의공통저장입력·원문·ID가일치했다. 기본동급카드성분별열위쌍은0이며 조건빈도/가격/각성/실전밸런스까지증명하지않는다.

스크립트전용컴파일29는JassHelper/pjass종료0,기존ignored오류24개포함이다. compile-29.json, head-card-choices-probe-15.json, card-condition-probe-75.json, ci-commands-25.json에기록했다. 맵 생성·패키징·배포·Warcraft실행·실제화면·실전멀티·서버저장·재미검증은수행하지않았다.

Closes #164
`;
fs.writeFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-pr-165-body-25.md',body,{flag:'wx'});
console.log(JSON.stringify({counts,choices:51,branchCases:108,monitorRecords:9,compile:29,mapCreated:false}));
