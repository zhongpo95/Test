// 학원도시 확장과 검토 지적의 반영·기각 및 성공·실패 기록 확인을 전달 문서에 남긴다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const data=fs.readdirSync('content/roguelite').filter(x=>x.endsWith('.json')).map(x=>JSON.parse(fs.readFileSync(path.join('content/roguelite',x),'utf8')));
const counts={heads:data.filter(d=>d.world.key!=='common').length,cards:data.reduce((n,d)=>n+d.cards.length,0),events:data.reduce((n,d)=>n+d.events.length,0),roots:data.reduce((n,d)=>n+d.events.filter(e=>!e.previous).length,0),followups:data.reduce((n,d)=>n+d.events.filter(e=>e.previous).length,0)};assert.deepEqual(counts,{heads:13,cards:219,events:201,roots:157,followups:44});
const compile=JSON.parse(fs.readFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-content-164-compile-26/report.json','utf8')),probe=read('validation/head-expansion-probe-11.json'),ci=read('validation/ci-commands-22.json'),monitor=read('validation/monitor-content-check-22.json');
assert.equal(compile.compiler_exit,0);assert.equal(compile.pjass_exit,0);assert.equal(compile.map_created,false);assert(probe.passed&&ci.passed);assert.equal(probe.branchCases,34);assert.equal(monitor.checks.length,5);
fs.writeFileSync(path.join(root,'validation/compile-26.json'),JSON.stringify(compile,null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(root,'validation/head-expansion-check-22.json'),JSON.stringify({counts,contentGroups:21,statGroups:8,ciCommands:15,newRootCases:5,newFollowupCases:1,branchCases:34,compilerExit:0,pjassExit:0,ignoredErrors:24,scriptSha256:compile.script_sha256,mapCreated:false,monitorCheckedRequests:{success:4,error:1},usage:{used:41,remaining:59},modelReviews:{verdicts:['REVISE','REVISE'],decisions:['몬스터 수 단계+1과 선지불 표현 명확화','지원되는 밀도 감소 폐기 제안 기각','프로젝트 스탯의 설명을 불일치로 단정한 제안 기각']},limits:['정적·고정체력 모의 실행·스크립트 컴파일을 검증했다.','Warcraft·실제 화면·멀티플레이·서버 저장·재미·밸런스는 미검증이다.']},null,2)+'\n',{flag:'wx'});
function replace(file,a,b){const p=path.join(repo,file),s=fs.readFileSync(p,'utf8');assert(s.includes(a),file+' 기준 문장 없음');fs.writeFileSync(p,s.replace(a,b));}
function append(file,s){fs.appendFileSync(path.join(repo,file),'\n'+s+'\n');}
replace('md/roguelite/사건 카드 재제작 검토 기록.md','현재 후보는 머리 13종, 성장 카드 213종, 사건 195개다. 독립 사건 152개와 개인 후속 사건 43개다.','현재 후보는 머리 13종, 성장 카드 219종, 사건 201개다. 독립 사건 157개와 개인 후속 사건 44개다.');
replace('md/roguelite/사건 카드 재제작 검토 기록.md','등급은 노말 20장·레어 182장·에픽 11장.','등급은 노말 20장·레어 188장·에픽 11장.');
append('md/roguelite/머리별 사건 확장 계획.md',`## 학원도시의 남은 동전·한 잔·대답

자판기 앞의 남은 동전, 호출로 남긴 간식, 대답하지 않은 자기 몫, 학생이 떠난 오락실, 무대 전 안내를 독립5사건으로 더했다. 자판기에서 다른 음료를 마련한 자기 성공1번 뒤에 음료후속1사건이 열린다. 카드6장을 연결하며 학원도시는 카드21장·독립15개·후속3개다. 전체는 카드219장·사건201개, 독립157개·후속44개다.

[34분기 검사](../../copy_archive/gemma_rebuild_2026-10-01/validation/head-expansion-probe-11.json)에서70/71경계·자기 후속·다른 사람 제외·밀도-1·AP·보상·중복100골드·골드0/상한의 무료 선택을 대조했다. [15검사](../../copy_archive/gemma_rebuild_2026-10-01/validation/ci-commands-22.json)와 [compile26](../../copy_archive/gemma_rebuild_2026-10-01/validation/compile-26.json)이 통과했다. 고정체력 네이티브 모형이며 실제 Warcraft·화면·멀티·재미·밸런스 미검증이다. 맵은 만들지 않았다.`);
append('md/roguelite/사건 카드 재제작 검토 기록.md',`## 학원도시 확장과 정상적으로 저장된 실패 요청

Gemma 피칭57에서5개 발단을 다시 쓰고 풀장 청소 반복1개를 폐기했다. 집필58의 내부키 노출·빈 결과·고체력 피해를 받는 피해 감소로 뒤집은 문장·인물 손이나 원작 갈등을 대신 정한 표현을 [수정59](../../copy_archive/gemma_rebuild_2026-10-01/revisions/academy-expansion-curation-59.json)에서 고쳤다. [수정60과 판단59](../../copy_archive/gemma_rebuild_2026-10-01/revisions/academy-review-decision-59.json)는 밀도+1과 실패 선지불을 명시한다.

검토59·60은 모두REVISE다. density는 변화량이고 음수도 최저1에서 적용되어 감소를0으로 바꾸라는 제안을 기각했다. 두 번째는 차지 공격 피해·차지 준비 속도·체력65%이상 피해 설명을 스탯 불일치로 분류했다. [표시·함수와 판단60](../../copy_archive/gemma_rebuild_2026-10-01/revisions/academy-review-decision-60.json)에서 실제 프로젝트 뜻과 일치함을 대조했다. 원문 verdict를PASS로 바꾸지 않고 [고정안·원본해시·채택61](../../copy_archive/gemma_rebuild_2026-10-01/revisions/academy-expansion-decision-61.json)과34분기 모의 실행을 별도 근거로 삼았다.

재검토60의 첫 요청은 Ollama HTTP500으로 실패했지만 [실패 전체 기록](../../copy_archive/gemma_rebuild_2026-10-01/reviews/academy-expansion-review-60-server-error.json)이 모니터링에 정상 저장됐다. 같은 입력의 재시도는13.9초에 성공했으며 서로 다른ID로 보존했다. [입력·원문·기록 대조22](../../copy_archive/gemma_rebuild_2026-10-01/validation/monitor-content-check-22.json)에서 성공4건과 실패1건을 확인했다. [오류 근거60](../../copy_archive/gemma_rebuild_2026-10-01/revisions/academy-server-error-60.json)은 실행 로그의500과 상태 확인만 기록하고 모델 내부 원인을 단정하지 않는다. 주간사용41%·잔여59%로 작업을 계속한다.`);
append('md/roguelite/폐기된 사건 카드 아이디어.md',`## 학원도시의 과도한 개입과 잘못된 스탯 지적

자판기 앞 NPC 몸을 잡거나 발길질을 막는 피칭, 쿠로코의 출동을 여행자가 정하는 피칭, 실제 약속의 화해를 끝내는 피칭, 테츠소 손을 대신 눌러 주거나 게임기 전원을 끄는 피칭, 확인되지 않은 공연 소품과 업무중인 쿠로코를 남기는 피칭을 제거했다. 풀장 청소는 기존 풀장 준비와 겹쳐 폐기했다. [6원안·선택과 재검토조건57](../../copy_archive/gemma_rebuild_2026-10-01/revisions/academy-pitches-selection-57.json)에 남겼다.

집필58의 healthy_damage를 피해감소로 뒤집은 문장은 제거했다. 검토59의 density-1폐기 제안은 실제 감소가 지원되어 기각했다. 검토60의 내부 스탯 이름 강요는 프로젝트 표시와 함수의 뜻에 이미 맞아 기각했다. [판단59](../../copy_archive/gemma_rebuild_2026-10-01/revisions/academy-review-decision-59.json)·[60](../../copy_archive/gemma_rebuild_2026-10-01/revisions/academy-review-decision-60.json)에 근거와 재검토 조건을 보존한다.`);
append('md/roguelite/참고 시트와 설정 확인 범위.md',`## 학원도시의 자판기·호출·오락실·성하제

[금서목록1기10화](https://toaru-project.com/index_1_2/story/1st/10.html)의 동전 삼킴과 미코토 비법, 초전자포 [3화](https://toaru-project.com/railgun/story/03.html)의 파티스리와 호출, [5화](https://toaru-project.com/railgun/story/05.html)의 기다리지 않은 지원과 잊은 약속, [17화](https://toaru-project.com/railgun/story/17.html)의 테츠소와 중간에 떠난 학생, [19화](https://toaru-project.com/railgun/story/19.html)의 성하제 안내와 무대 부담 본문을 읽었다. [2화](https://toaru-project.com/railgun/story/02.html)의 풀장 청소는 기존 준비 소재와 겹쳐 새 사건으로 채택하지 않았다.

각색은 별도 방문이다. 원작 자판기 파괴·미사카 동생 실험·피습·친구의 화해를 여행자가 해결하지 않는다. 원래 약속의 정확한 내용·학생이 떠난 이유·게임 명칭과 승패·공연 종류와 악기/곡은 이 본문에서 확정하지 않아 새 문장에 쓰지 않았다. 음료값·짐·보수·NPC의 새 대사·확률·성장 기억은 창작이며 실제 원작 기술·아이템·음료 소비 기능이 없다.`);
append('copy_archive/gemma_rebuild_2026-10-01/README.md','학원도시 독립5사건·자기 자판기 성공 후속1사건·카드6장을 채택했다. 피칭57·집필58·검토59/60과 HTTP500 실패 기록을 각각 보존한다. 두 REVISE의 실제 문장 모호함은 명확히 했고 정상적인 밀도 감소와 프로젝트 스탯 설명을 불일치로 분류한 제안은 기각 근거를 남겼다. 원본바이트/해시·채택61·34분기 모의·15검사·compile26·성공4건/실패1건 상세기록 대조를 보존한다. 맵 생성과 실제 Warcraft 검증은 없다.');
let body=fs.readFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-pr-165-body-21.md','utf8');
body=body.replace('카드 213장·사건 195개','카드 219장·사건 201개').replace('독립 사건 152개','독립 사건 157개').replace('후속 43개','후속 44개');
body=body.replace('새후속은자기성공1번만요구한다.','학원도시는 남은 동전·호출 뒤 간식·내가 답할 약속·오락실 빈자리·무대 전 안내를 더하고 자기 자판기 성공1번 뒤에 음료 후속을 연결했다. 새 후속은 자기 성공1번만 요구한다.');
const start='최근51~55의5요청입력·원문·ID를기록상세API와대조했다.';assert(body.includes(start));
body=body.replace(start,'최근57~60의 성공4요청 입력·원문·ID와 실패1요청 전체 기록을 상세API와 대조했다. HTTP500은 정상적으로 실패 저장됐고 동일 입력 재시도는 성공했다. 내부 원인은 미확정이다.');
body=body.replace('이번Gemma의세verdict는모두REVISE이며모호함수정과모델의사건/스탯혼동·상충된계산판단기각을기록했다.','학원도시의 두 검토도 REVISE이며 문장 명확화와 지원되는 감소·스탯 설명에 대한 잘못된 지적 기각을 기록했다.');
body=body.replace('최근아인크라드10사건60분기에서자기성공후속·65/66과70/71확률경계','최근 학원도시6사건34분기에서 자기 성공 후속·70/71확률 경계·밀도-1 감소');
body=body.replace('최종compile-25.json·head-expansion-probe-10.json','최종compile-26.json·head-expansion-probe-11.json');
fs.writeFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-pr-165-body-22.md',body,{flag:'wx'});console.log(JSON.stringify(counts));
