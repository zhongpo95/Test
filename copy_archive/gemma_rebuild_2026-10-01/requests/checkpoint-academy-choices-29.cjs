// 학원도시 세 카드의 검사 결과와 원본·수정 기록을 문서와 기존 초안 PR에 남긴다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const compile=JSON.parse(fs.readFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-content-164-compile-33/report.json','utf8')),probe=read('validation/head-card-choices-probe-19.json'),ci=read('validation/ci-commands-29.json'),monitor=read('validation/monitor-content-check-29.json');
assert.equal(compile.compiler_exit,0);assert.equal(compile.pjass_exit,0);assert.equal(compile.map_created,false);assert(probe.passed&&ci.passed);assert.equal(probe.branchCases,112);assert.equal(monitor.checks.length,7);
write('validation/compile-33.json',compile);
write('validation/head-choices-check-29.json',{counts:{heads:13,cards:266,events:217,roots:169,followups:48},rewrittenEvents:18,choices:54,newCards:8,branchCases:112,historyGates:probe.historyGates,newMemoryStats:probe.newMemoryStats,noParentCardRepeat:probe.noParentCardRepeat,directGoldChoices:0,removedGoldChoices:16,ciCommands:15,monitorRecords:7,compile,completedChoiceHeads:5,completedChoiceEvents:85,completedChoices:256,review:'PASS/PASS/PASS',limits:['정적·JASS변환모의·스크립트컴파일이다. Warcraft·시각·멀티·저장·실전밸런스·재미는 미검증이다.']});
const append=(file,text)=>fs.appendFileSync(file,'\n'+text+'\n'),record='md/roguelite/사건 카드 재제작 검토 기록.md';
let s=fs.readFileSync(record,'utf8');assert(s.includes('성장 카드 258종'));s=s.replace('성장 카드 258종','성장 카드 266종').replace('노말 20장·레어 227장·에픽 11장','노말 20장·레어 235장·에픽 11장');fs.writeFileSync(record,s);
append(record,`## 학원도시의 세 행동과 세 기억

학원도시18사건54선택에서 서로 다른 카드를 비교한다. 기존21카드·머리효과와 구조백업1/현장진입2/다른곳음료1 자기후속을 유지하고 기억8장을 더했다. 직접골드16개를 제거했으며 구조 사건의 네 번째 보급 기능은 세 번째 귀환길 기억에 결합했다. 같은 토우마/테츠소 카드를 비용만 바꿔 받는 선택도 다른 기억으로 나눴다. 부모가 이미 준 카드는 후속에서 반복하지 않는다.

[원본91](../../copy_archive/gemma_rebuild_2026-10-01/before-academy-card-choices-91.json)과 [수정92](../../copy_archive/gemma_rebuild_2026-10-01/revisions/academy-card-choices-curation-92.json), [채택93](../../copy_archive/gemma_rebuild_2026-10-01/revisions/academy-card-choices-decision-93.json)에 요청·원문·해시·인물반응 수정·실패문구의 폐기 보수를 보존했다. 세 역검토 PASS는 자문이며 강점에 언급한 시간정지는 이 사건의 설정 근거로 채택하지 않는다.

[112분기](../../copy_archive/gemma_rebuild_2026-10-01/validation/head-card-choices-probe-19.json), [15회귀](../../copy_archive/gemma_rebuild_2026-10-01/validation/ci-commands-29.json), [7저장원문](../../copy_archive/gemma_rebuild_2026-10-01/validation/monitor-content-check-29.json)이 통과했다. [컴파일33](../../copy_archive/gemma_rebuild_2026-10-01/validation/compile-33.json)은 compiler/pjass0·기존 ignored24개다. 맵을 만들지 않았고 Warcraft·시각·멀티·저장·실전밸런스·재미는 미검증이다. 다섯 머리85사건256선택까지 세 카드 정리를 진행했다. 새 요청인 무료 사건·행동력 최대치·보유 카드 조건 사건과 후보 기본3개는 다음 변경에서 구현한다.`);
append('md/roguelite/머리별 사건 확장 계획.md','학원도시는 카드29장·독립15개·후속3개이며18사건54선택을 세 지정카드로 정리했다. 다섯 머리85사건256선택까지 적용했고 전체 카드266장·사건217개다. 무료 사건·행동력 최대치·카드 보유 사건 및 후보 기본3개를 함께 확장한다.');
append('md/roguelite/폐기된 사건 카드 아이디어.md','학원도시91~93에서 직접골드16개와 같은 카드의 가격 차이만 있는 선택을 제외했다. 집필의 반복 미소/끄덕임, 미확인 표식을 버렸다는 오독, 대답을 기다리는 인물을 쿠로코로 바꾼 오독, 학생 복귀·비법 시연 확정은 수정92에 원문과 함께 남겼다. 재검토 때 실제 행동·대사 주체·남은 현장 문제·지정 카드가 함께 맞아야 한다.');
append('md/roguelite/참고 시트와 설정 확인 범위.md',`학원도시 세 카드 재구성은 [공식17화](https://toaru-project.com/railgun/story/17.html)의 테츠소와 게임센터 학생·남은 대화, [3화](https://toaru-project.com/railgun/story/03.html)의 간식 중 호출, [5화](https://toaru-project.com/railgun/story/05.html)의 두 사람의 약속과 갈등, [19화](https://toaru-project.com/railgun/story/19.html)의 성하제 안내와 무대 차례를 재확인했다. 새로운 대사·기억·수치·현장 분담은 별도 각색이며 본편 화해·학생 복귀·발표 결과를 확정하지 않는다.`);
append('md/roguelite/카드 능력치 단위와 검토 기준.md','학원도시의 새 기억8장은 후보/일반피해·이동/일반피해·공격력/차지속도·비방향/피해감소·최대체력/보스피해·최대체력/치명피해·차지속도/치명피해·치명피해/65%체력조건으로 나눈다. 단순 성분 우월0쌍과 합산 검사는 조건 빈도·가격·각성·실전 선택률의 균형 증명이 아니다.');
append('copy_archive/gemma_rebuild_2026-10-01/README.md','학원도시91~93·검증29는18사건54선택·기억8장·직접골드16개제거를 기록한다. 원본21카드/머리효과·세 자기후속·부모카드반복없음을 유지했다. 집필4/역검토3·7저장기록·112분기·15회귀·compile33을 보존한다. 맵·Warcraft·시각·멀티·재미는 미검증이다.');
let body=fs.readFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-pr-165-body-28.md','utf8');body=body.replaceAll('258카드','266카드').replace('아비도스18사건54선택에 적용했고','아비도스18사건54선택·학원도시18사건54선택에 적용했고').replace('최근아비도스114분기','최근학원도시112분기·아비도스114분기').replace('최근12Gemma요청','최근7Gemma요청').replaceAll('컴파일32','컴파일33').replaceAll('compile-32.json','compile-33.json').replaceAll('head-card-choices-probe-18.json','head-card-choices-probe-19.json').replaceAll('ci-commands-28.json','ci-commands-29.json');
body+='\n학원도시는 기억8장을 더해18사건54선택으로 나눴고 직접골드16개를 제외했다. 무료 사건·행동력 최대치·보유 카드 조건 사건과 후보 기본3개는 사용자 추가 요청으로 다음 변경에서 구현한다.\n';fs.writeFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-pr-165-body-29.md',body,{flag:'wx'});
console.log(JSON.stringify({cards:266,completedChoiceEvents:85,compile:33,mapCreated:false}));
