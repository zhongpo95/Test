// 액셀 확장·폐기 이유·체력 설명 정정과 전달 검사 결과를 기록한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const data=fs.readdirSync('content/roguelite').filter(x=>x.endsWith('.json')).map(x=>JSON.parse(fs.readFileSync(path.join('content/roguelite',x),'utf8')));
const counts={heads:data.filter(d=>d.world.key!=='common').length,cards:data.reduce((n,d)=>n+d.cards.length,0),events:data.reduce((n,d)=>n+d.events.length,0),roots:data.reduce((n,d)=>n+d.events.filter(e=>!e.previous).length,0),followups:data.reduce((n,d)=>n+d.events.filter(e=>e.previous).length,0)};assert.deepEqual(counts,{heads:13,cards:208,events:190,roots:148,followups:42});
const compile=JSON.parse(fs.readFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-content-164-compile-24/report.json','utf8')),probe=read('validation/head-expansion-probe-09.json'),health=read('validation/card-health-grant-probe-50.json'),ci=read('validation/ci-commands-20.json'),monitor=read('validation/monitor-content-check-20.json');
assert.equal(compile.compiler_exit,0);assert.equal(compile.pjass_exit,0);assert.equal(compile.map_created,false);assert(probe.passed&&health.passed&&ci.passed);assert.equal(probe.branchCases,27);assert.equal(monitor.checks.length,3);
fs.writeFileSync(path.join(root,'validation/compile-24.json'),JSON.stringify(compile,null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(root,'validation/head-expansion-check-20.json'),JSON.stringify({counts,contentGroups:21,statGroups:8,ciCommands:15,newRootCases:4,newFollowupCases:1,branchCases:27,healthRatioChecked:true,compilerExit:0,pjassExit:0,ignoredErrors:24,scriptSha256:compile.script_sha256,mapCreated:false,monitorCheckedRequests:3,usage:{used:41,remaining:59},limits:['사건 분기는 고정 체력 모형이다. 최대 체력 카드 지급은 별도의 실제 스탯 함수 모형에서 비율 보존을 확인했다.','Warcraft·실제 화면·멀티플레이·서버 저장·프레임·재미·밸런스는 미검증이다.']},null,2)+'\n',{flag:'wx'});
function replace(file,a,b){const p=path.join(repo,file),s=fs.readFileSync(p,'utf8');assert(s.includes(a),file+' 기준 문장 없음');fs.writeFileSync(p,s.replace(a,b));}
function append(file,s){fs.appendFileSync(path.join(repo,file),'\n'+s+'\n');}
replace('md/roguelite/사건 카드 재제작 검토 기록.md','현재 후보는 머리 13종, 성장 카드 203종, 사건 185개다. 독립 사건 144개와 개인 후속 사건 41개다.','현재 후보는 머리 13종, 성장 카드 208종, 사건 190개다. 독립 사건 148개와 개인 후속 사건 42개다.');
replace('md/roguelite/사건 카드 재제작 검토 기록.md','등급은 노말 20장·레어 172장·에픽 11장.','등급은 노말 20장·레어 177장·에픽 11장.');
append('md/roguelite/머리별 사건 확장 계획.md',`## 액셀의 정화·겨울 의뢰·제령 현장

우리를 버린 것으로 오해하는 구경꾼과 붙들 손이 필요한 줄, 멀어지는 정령과 겹친 발자국, 제령 의뢰 때문에 끊긴 질문, 창문과 의뢰받은 문을 서로 가리키는 현장을 독립 사건 4개로 추가했다. 줄을 고정한 자신의 1번 선택에서는 내려놓을 받침과 손을 뗄 때의 개인 후속이 열린다. 아쿠아·카즈마·위즈의 카드 5장을 연결한다. 액셀은 독립 14개·후속 2개·카드 18장이다. 전체 후보는 카드 208장·사건 190개, 독립 148개·후속 42개다.

[27분기 모의 검사](../../copy_archive/gemma_rebuild_2026-10-01/validation/head-expansion-probe-09.json)에서 자기 기록과 타인 분리, 75/76 판정, 지정 카드/중복100골드, 비용·물약·지속 필드와 빈 골드/필드 상한의 무료 선택을 확인했다. 기존 15검사와 [스크립트 컴파일](../../copy_archive/gemma_rebuild_2026-10-01/validation/compile-24.json)이 통과했다. 맵과 실제 수중/겨울/제령 전투를 만들지 않았다. 실제 Warcraft·화면·멀티·재미·밸런스는 미검증이다.`);
append('md/roguelite/사건 카드 재제작 검토 기록.md',`## 액셀 현장 확장과 체력 설명 정정

피칭48의 8개 중 4개는 소재만 남겨 다시 썼다. 카즈마의 무기를 빼앗아 원작 사망의 원인을 바꾸는 장면, 기존 다크니스 집중 공격·물 재주와 짐·융융 표적의 세 반복은 폐기했다. 집필49는 사건 중 정령과 몬스터를 실제 추가 처치한 것처럼 썼으므로 개인 사냥의 지속 조건을 택하는 결과로 바꿨다. [모든 원안의 결정과 재검토 조건](../../copy_archive/gemma_rebuild_2026-10-01/revisions/axel-pitches-selection-48.json), [문장 수정 전후](../../copy_archive/gemma_rebuild_2026-10-01/revisions/axel-expansion-curation-50.json), [원본 해시·검토·채택](../../copy_archive/gemma_rebuild_2026-10-01/revisions/axel-expansion-decision-50.json)을 보존한다.

검토47의 현재 체력 7000 유지·65% 조건 미달은 PlayerStatsSet만 따로 호출한 검사였다. 실제 사건의 ProtoGrantCard → ProtoRefreshStats는 기존 비율을 보존한다. [지급 경로 모의 검사50](../../copy_archive/gemma_rebuild_2026-10-01/validation/card-health-grant-probe-50.json)에서 7000/10000이 약7560/10800으로 같은70%를 유지하고 반복 재계산도 안정적임을 확인했다. 단독 함수의 결과를 전체 지급에 일반화한 문서를 정정했다. 기존 요청·리뷰·검사 원문은 덮어쓰지 않는다. 모델의 PASS가 실행 경로를 대신 확인하지 않는 사례이며 코드와 체력 수치는 바꾸지 않았다.

새3요청의 입력·원문·ID·저장 성공을 [실제 기록 상세 API와 대조](../../copy_archive/gemma_rebuild_2026-10-01/validation/monitor-content-check-20.json)했다. 주간 사용량은41%·잔여59%로 중단 기준30%에 도달하지 않았다. 콘텐츠와 실제 게임의 정확성·재미는 기록 저장 여부와 별도로 검토한다.`);
append('md/roguelite/폐기된 사건 카드 아이디어.md',`## 액셀 현장 피칭의 미채택 이유

겨울 장군 앞에서 카즈마의 무기를 빼앗는 피칭은 원작의 사망 원인을 플레이어가 바꾼다. 군집한 몬스터와 다크니스, 물 재주와 젖는 짐, 융융·메구밍의 표적은 기존 세 사건을 반복했다. 특히 물 재주 피칭은 기존 창작을7화의 공식 사실로 잘못 표기했다. [8개 원안·판단·재검토 조건](../../copy_archive/gemma_rebuild_2026-10-01/revisions/axel-pitches-selection-48.json)을 보존한다. 눈의 추위가 현재 체력을 깎는 발단도 사용하지 않는다.

집필49의 '주변 정령을 추가 사냥했다', '강한 적을 사냥하며 설명을 들었다'는 결과는 정지된 사건 중 실제 처치가 일어나지 않는 코드와 맞지 않아 폐기했다. 개인 사냥의 강함/수를 계속 바꾸는 선택과 카드 성장 기억으로 다시 썼다. 결과의 안도·미소·끄덕임 반복과 단위 없는 수치 목록은 인물에게 남은 행동과 구체적인 지불·보급으로 교체했다. [문장별 수정 기록](../../copy_archive/gemma_rebuild_2026-10-01/revisions/axel-expansion-curation-50.json)에서 전후를 확인할 수 있다.`);
append('md/roguelite/참고 시트와 설정 확인 범위.md',`## 액셀의 호수·눈의 정령·제령 의뢰

[공식1기 줄거리](https://konosuba.com/1st/story/)의5·7·8화 본문에서 호수 정화와 우리, 달아나는 눈의 정령과 겨울 장군 앞의 무기 문제, 위즈에게 배우려는 카즈마와 아쿠아의 방해 및 저택 제령 의뢰를 읽었다. 구경꾼·줄 고정용품·겹친 발자국·남은 질문·서로 다른 문·받침은 별도 창작이다. 겨울 장군의 승패와 카즈마의 사망, 저택 유령의 신원·성불 조건은 새 선택으로 결정하지 않는다. 특정 드레인 터치의 세부 작동은 이 공식 본문으로 확인하지 못해 새 카드에 넣지 않았다. 검색에서 확인한 비공식 게임 공략을 공식 근거로 바꾸지 않는다.`);
append('copy_archive/gemma_rebuild_2026-10-01/README.md','액셀의 독립4사건·개인 줄 후속1사건·카드5장을 더했다. 피칭48의 원문/미채택·집필49·검토50·원본바이트와 해시·27분기 검사·15기존검사·compile24·새3요청의 실제 기록 대조를 보존한다. 기존47의 체력 불변 예시는 스탯 함수 단독 실행에만 한정하며 실제 지급은70%를 보존한다는 검사50과 정정 기록을 추가했다. 과거 요청과 리뷰를 덮어쓰지 않으며 실제 Warcraft 검증과 맵 생성은 없다.');
let body=fs.readFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-pr-165-body-19.md','utf8');
body=body.replace('카드 203장·사건 185개','카드 208장·사건 190개').replace('독립 사건 144개','독립 사건 148개').replace('후속 41개','후속 42개');
body=body.replace('새 후속은 자신의 성공한 1번 선택에서만 열린다.','액셀에는 정화의 줄·눈의 발자국·끊긴 질문·저택의 문을 더했다. 줄을 고정한 선택은 내려놓는 개인 후속으로 이어진다. 새 후속은 자신의 성공한1번에서만 열린다.');
body=body.replace('최근 검토 47의 입력·원문·ID를 기록 상세 API와 대조했다.','최근48~50의3요청 입력·원문·ID를 기록 상세 API와 대조했다.');
body=body.replace('이번 6사건 31분기에서 자기 성공 후속·70/71 확률 경계','최근 액셀5사건27분기에서 자기 성공 후속·75/76 확률 경계');
body=body.replace('최대/현재 체력 분리·차지/일반 행동 차이·개인 처치 수입과 후보 상한을 확인했다.','차지/일반 행동 차이·개인 처치 수입과 후보 상한을 확인했다. 체력은 실제 ProtoGrantCard → ProtoRefreshStats → PlayerStatsSet을 함께 모의 실행해7000/10000→약7560/10800의70%보존과 반복 갱신을 확인했다. 스탯 함수 단독 검사에서 현재 체력이 그대로였다는 예시를 전체 지급에 일반화한 문서를 정정하고 원본을 보존했다.');
body=body.replace('최종 compile-23.json·card-contrast-probe-47.json과 기존 head-expansion-probe-08.json','최종 compile-24.json·head-expansion-probe-09.json·card-health-grant-probe-50.json');
fs.writeFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-pr-165-body-20.md',body,{flag:'wx'});console.log(JSON.stringify(counts));
