// 아인크라드 확장·문장 정정·모델 지적 기각과 실제 분기 검사 결과를 전달 문서에 남긴다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const data=fs.readdirSync('content/roguelite').filter(x=>x.endsWith('.json')).map(x=>JSON.parse(fs.readFileSync(path.join('content/roguelite',x),'utf8')));
const counts={heads:data.filter(d=>d.world.key!=='common').length,cards:data.reduce((n,d)=>n+d.cards.length,0),events:data.reduce((n,d)=>n+d.events.length,0),roots:data.reduce((n,d)=>n+d.events.filter(e=>!e.previous).length,0),followups:data.reduce((n,d)=>n+d.events.filter(e=>e.previous).length,0)};assert.deepEqual(counts,{heads:13,cards:213,events:195,roots:152,followups:43});
const compile=JSON.parse(fs.readFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-content-164-compile-25/report.json','utf8')),probe=read('validation/head-expansion-probe-10.json'),ci=read('validation/ci-commands-21.json'),monitor=read('validation/monitor-content-check-21.json');
assert.equal(compile.compiler_exit,0);assert.equal(compile.pjass_exit,0);assert.equal(compile.map_created,false);assert(probe.passed&&ci.passed);assert.equal(probe.branchCases,60);assert.equal(monitor.checks.length,5);
fs.writeFileSync(path.join(root,'validation/compile-25.json'),JSON.stringify(compile,null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(root,'validation/head-expansion-check-21.json'),JSON.stringify({counts,contentGroups:21,statGroups:8,ciCommands:15,newRootCases:4,newFollowupCases:1,rewrittenEvents:5,branchCases:60,compilerExit:0,pjassExit:0,ignoredErrors:24,scriptSha256:compile.script_sha256,mapCreated:false,monitorCheckedRequests:5,usage:{used:41,remaining:59},modelReviews:{verdicts:['REVISE','REVISE','REVISE'],decisions:['주체·동액보수·고체력조건을명확히수정','다른사건수치통일제안기각','수치일치를인정하면서오류라분류한제안기각']},limits:['정적검사·고정체력모의실행·스크립트컴파일을검증했다.','Warcraft·실제화면·멀티플레이·서버저장·프레임·재미·밸런스미검증.']},null,2)+'\n',{flag:'wx'});
function replace(file,a,b){const p=path.join(repo,file),s=fs.readFileSync(p,'utf8');assert(s.includes(a),file+' 기준 문장 없음');fs.writeFileSync(p,s.replace(a,b));}
function append(file,s){fs.appendFileSync(path.join(repo,file),'\n'+s+'\n');}
replace('md/roguelite/사건 카드 재제작 검토 기록.md','현재 후보는 머리 13종, 성장 카드 208종, 사건 190개다. 독립 사건 148개와 개인 후속 사건 42개다.','현재 후보는 머리 13종, 성장 카드 213종, 사건 195개다. 독립 사건 152개와 개인 후속 사건 43개다.');
replace('md/roguelite/사건 카드 재제작 검토 기록.md','등급은 노말 20장·레어 177장·에픽 11장.','등급은 노말 20장·레어 182장·에픽 11장.');
append('md/roguelite/머리별 사건 확장 계획.md',`## 아인크라드의 질문·기다림·첫 보폭

아르고에게 위험 대신 귀환 갈림길을 묻는 만남, 같은 답을 듣고 독점으로 오해한 손님, 소녀에게 질문보다 먼저 내놓을 외투, 첫 회의 뒤 솔로의 보폭을 관찰하는 독립 사건4개를 추가했다. 자기 귀환 질문을 산 성공1번에서만 두 번째 질문 후속이 열린다. 새카드5장과 연결하며 아인크라드는 카드18장·독립14개·후속2개다. 전체는 카드213장·사건195개, 독립152개·후속43개다.

기존 공방의 수송/귀환·소생 준비·희귀 고기의 식탁·니시다 낚시5사건은 비용·보상·물약·필드·확률·선택조건을 유지했다. 니시다는 기록 분류 대신 작은 입질을 기다리고 원작 고기는 키리토의 것으로 바로잡았다. [60분기 모의 검사](../../copy_archive/gemma_rebuild_2026-10-01/validation/head-expansion-probe-10.json)에서65/66·70/71경계와 개인 후속·지급·필드·골드0/상한의 무료 선택을 확인했다. 기존15검사와 [compile25](../../copy_archive/gemma_rebuild_2026-10-01/validation/compile-25.json)도 통과했다. 실제화면·Warcraft·멀티·재미·밸런스는 미검증이며 맵을 생성하지 않았다.`);
append('md/roguelite/사건 카드 재제작 검토 기록.md',`## 아인크라드 확장과 모델의 상충된 재검토

Gemma 피칭51에서 처음4개의 발단만 남기고 일반 모닥불과 보급 목록2개는 기존 소재 반복으로 폐기했다. 집필52는 고체력 가하는 피해를 받는 피해 감소로 뒤집고 정보 후속의120골드 보수를 빠뜨렸다. 질문의 주체·원작 파티/고기 소유권·정지중 실제 사냥 완료와 빈칭찬도 고쳤다. [수정전후53](../../copy_archive/gemma_rebuild_2026-10-01/revisions/aincrad-expansion-curation-53.json)과 [추가명확화54](../../copy_archive/gemma_rebuild_2026-10-01/revisions/aincrad-review-decision-53.json)를 보존한다.

Gemma의 검토53·54·55 verdict는 모두REVISE다. 첫 검토의 문장 모호함은 명확히 했지만 고체력 피해를 공격력으로 바꾸라는 제안과 소녀가 질문했다고 유지하라는 주체 반전은 기각했다. 둘째는 정보후속과 낚시의 비용을 통일하라고 했고 셋째는120−120=0과240−150=90이 맞다고 스스로 쓴 뒤 오류로 분류했다. [사건별 판단54](../../copy_archive/gemma_rebuild_2026-10-01/revisions/aincrad-review-decision-54.json)와 [계산판단55](../../copy_archive/gemma_rebuild_2026-10-01/revisions/aincrad-review-decision-55.json)에서 이유를 확인할 수 있다. 원문 verdict를PASS로 바꾸지 않았으며 Codex의 고정안 대조와 실제 JASS60분기 모의 검사를 별도로 근거로 삼았다.

[원본바이트·해시·고정안과채택56](../../copy_archive/gemma_rebuild_2026-10-01/revisions/aincrad-expansion-decision-56.json)을 보존한다. 계획했던adopt53~55는 실행하지 않았고adopt56만 활성JSON에 적용했다. 새5요청은 [상세기록API](../../copy_archive/gemma_rebuild_2026-10-01/validation/monitor-content-check-21.json)와 입력·원문·ID·성공저장을 대조했다. 저장성공과 검토판단·콘텐츠재미는 서로 다르다. 주간사용41%·잔여59%로 작업을 계속한다.`);
append('md/roguelite/폐기된 사건 카드 아이디어.md',`## 아인크라드의 반복 발단과 잘못된 검토 제안

감사하며 소모품을 나누고 목록을 만드는 무상도움 피칭은 기존 꽃의 보급·정찰과 겹쳤다. 일반 모닥불은 원작 인물 없이 분류·체크리스트·장비 점검만 반복했다. [피칭51의6원안과재검토조건](../../copy_archive/gemma_rebuild_2026-10-01/revisions/aincrad-pitches-selection-51.json)을 남긴다. 집필52의 고체력 피해감소·정보 보수누락·질문 주체반전·정지중실제사냥은 활성문장에서 제거하고 원문은 보존했다.

모델이 제안한 고체력 효과의 공격력화는 승인된healthy_damage와 다른 능력치다. 정보후속의120/120과 낚시의150/240은 다른 사건의 비용/보수라 통일할 이유가 없다. 마지막검토는 차액0과90이 정확하다고 적고도 계산오류로 분류했다. [53](../../copy_archive/gemma_rebuild_2026-10-01/revisions/aincrad-review-decision-53.json)·[54](../../copy_archive/gemma_rebuild_2026-10-01/revisions/aincrad-review-decision-54.json)·[55](../../copy_archive/gemma_rebuild_2026-10-01/revisions/aincrad-review-decision-55.json)에 반영·기각·재검토조건을 보존했다. 검토표의PASS/REVISE만으로 숫자를 바꾸지 않는다.`);
append('md/roguelite/참고 시트와 설정 확인 범위.md',`## 아인크라드의 생활과 정보상 역할

[공식2화](https://www.swordart-online.net/sp/aincrad/story/story02.html)의 공략회의/솔로파티, [4화](https://www.swordart-online.net/sp/aincrad/story/story04.html)의 피나 상실/무상소생준비, [7화](https://www.swordart-online.net/sp/aincrad/story/story07.html)의 시험검/희귀금속, [8화](https://www.swordart-online.net/sp/aincrad/story/story08.html)의 키리토 소유고기/아스나 절반요리, [11화](https://www.swordart-online.net/sp/aincrad/story/story11.html)의 소녀보호, [13화](https://www.swordart-online.net/sp/aincrad/story/story13.html)의 니시다 낚시취미와 평범한사람들의생활 본문을 읽었다. [아르고의공식게임소개](https://eoa.sao-game.jp/character/argo.php)에서는 정보상역할만 가져왔다. 그게임의주인공/베타전개를애니메이션사실로옮기지않았다.

이 문서들이 꽃의 명칭·정확한층·소생기한·유이관리자권한·호수주인의승패를 모두 확인해주는 것은 아니다. 검색된비공식위키·팬픽·다른게임공략을공식근거로바꾸지않았다. 미끼와작은입질·정보독점오해·외투·보수·확률·맵방문은 별도창작이다. 기존사건의수치는유지하고원작소유권과모호한근거의설명을좁혔다.`);
append('copy_archive/gemma_rebuild_2026-10-01/README.md','아인크라드에 독립4사건·개인정보후속1사건·카드5장을 추가하고 기존5사건의문장을정정했다. 피칭51·집필52·검토53~55 원문은보존한다. 세verdict는모두REVISE이며실제문장모호함은명확히하고모델의스탯/주체반전·다른사건수치통일·일치하는계산을오류로분류한판단은이유를붙여기각했다. 실행되지않은채택안53~55도기록으로남기고채택56만실행했다. 60분기모의검사·15기존검사·compile25·새5요청상세기록대조를보존하며실제Warcraft·재미·맵생성은없다.');
let body=fs.readFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-pr-165-body-20.md','utf8');
body=body.replace('카드 208장·사건 190개','카드 213장·사건 195개').replace('독립 사건 148개','독립 사건 152개').replace('후속 42개','후속 43개');
body=body.replace('새 후속은 자신의 성공한1번에서만 열린다.','아인크라드는 정보상의 질문·같은답의독점오해·소녀옆의외투·첫회의뒤보폭을더하고귀환질문에서개인후속을연결했다. 기존공방/소생/식탁/낚시5사건은수치와지급참조를유지하고문장을정정했다. 새후속은자기성공1번만요구한다.');
body=body.replace('최근48~50의3요청 입력·원문·ID를 기록 상세 API와 대조했다.','최근51~55의5요청입력·원문·ID를기록상세API와대조했다. 이번Gemma의세verdict는모두REVISE이며모호함수정과모델의사건/스탯혼동·상충된계산판단기각을기록했다. Codex의고정안대조와실제JASS분기모의검사를별도근거로삼았다.');
body=body.replace('최근 액셀5사건27분기에서 자기 성공 후속·75/76 확률 경계','최근아인크라드10사건60분기에서자기성공후속·65/66과70/71확률경계');
body=body.replace('최종 compile-24.json·head-expansion-probe-09.json·card-health-grant-probe-50.json','최종compile-25.json·head-expansion-probe-10.json과기존card-health-grant-probe-50.json');
fs.writeFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-pr-165-body-21.md',body,{flag:'wx'});console.log(JSON.stringify(counts));
