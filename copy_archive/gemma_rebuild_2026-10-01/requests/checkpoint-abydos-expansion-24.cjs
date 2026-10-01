// 흥신소 사건 확장의 폐기·수정·자기 후속과 모의·기록·컴파일 검증을 문서에 보존한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..'),read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const data=fs.readdirSync('content/roguelite').filter(x=>x.endsWith('.json')).map(x=>JSON.parse(fs.readFileSync(path.join('content/roguelite',x),'utf8')));
const counts={heads:data.filter(d=>d.world.key!=='common').length,cards:data.reduce((n,d)=>n+d.cards.length,0),events:data.reduce((n,d)=>n+d.events.length,0),roots:data.reduce((n,d)=>n+d.events.filter(e=>!e.previous).length,0),followups:data.reduce((n,d)=>n+d.events.filter(e=>e.previous).length,0)};assert.deepEqual(counts,{heads:13,cards:232,events:212,roots:165,followups:47});
const compile=JSON.parse(fs.readFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-content-164-compile-28/report.json','utf8')),probe=read('validation/head-expansion-probe-13.json'),ci=read('validation/ci-commands-24.json'),monitor=read('validation/monitor-content-check-24.json'),condition=read('validation/card-condition-probe-71.json'),review=read('reviews/abydos-expansion-review-70.json');
assert.equal(compile.compiler_exit,0);assert.equal(compile.pjass_exit,0);assert.equal(compile.map_created,false);assert(probe.passed&&ci.passed&&condition.passed);assert.equal(probe.branchCases,38);assert.equal(monitor.checks.length,3);assert.equal(review.parsed.verdict,'PASS');
write('validation/compile-28.json',compile);write('validation/head-expansion-check-24.json',{counts,contentGroups:21,statGroups:8,ciCommands:15,newRootCases:4,newFollowupCases:2,branchCases:38,cardConditions:condition,compilerExit:0,pjassExit:0,ignoredErrors:24,scriptSha256:compile.script_sha256,mapCreated:false,monitorCheckedRequests:3,usage:{used:42,remaining:58},modelReview:'PASS',limits:['Gemma PASS는 자문이고 정적·JASS 변환 모의 실행·스크립트 컴파일과 분리한다.','Warcraft·실제 화면·멀티플레이·서버 저장·재미·밸런스는 미검증이다.']});
function replace(file,a,b){const p=path.join(repo,file),s=fs.readFileSync(p,'utf8');assert(s.includes(a),file+' 기준 문장 없음');fs.writeFileSync(p,s.replace(a,b));}
function append(file,s){fs.appendFileSync(path.join(repo,file),'\n'+s+'\n');}
replace('md/roguelite/사건 카드 재제작 검토 기록.md','현재 후보는 머리 13종, 성장 카드 226종, 사건 206개다. 독립 사건 161개와 개인 후속 사건 45개다.','현재 후보는 머리 13종, 성장 카드 232종, 사건 212개다. 독립 사건 165개와 개인 후속 사건 47개다.');
replace('md/roguelite/사건 카드 재제작 검토 기록.md','등급은 노말 20장·레어 195장·에픽 11장.','등급은 노말 20장·레어 201장·에픽 11장.');
append('md/roguelite/머리별 사건 확장 계획.md',`## 아비도스에서 만난 흥신소68

계산서를 든 아루와 무츠키, 사과에 막힌 카요코의CD주문, 뽑으려던 잡초 화분의 하루카, 무츠키의 두 봉투를 독립4사건으로 추가했다. 아루의 계산을 도운 자기 성공1번과 카요코와 한 곡을 들은 자기 성공2번 뒤에 각각 다른 후속이 열린다. 카드6장과 연결해 아비도스는 카드20장·독립14개·후속4개다. 전체는 카드232장·사건212개, 독립165개·후속47개다.

[38분기 검사](../../copy_archive/gemma_rebuild_2026-10-01/validation/head-expansion-probe-13.json)에서60/61·75/76경계,서로 다른 자기 후속,다른플레이어 기록 분리,AP·선지불·중복100골드·필드 감소·골드0/상한 선택을 대조했다. [실제 카드 조건71](../../copy_archive/gemma_rebuild_2026-10-01/validation/card-condition-probe-71.json)은 아루의보스1.18/일반0.94,무츠키의치명피해와비방향전제,하루카의70%체력비율 보존을 대조했다. [15검사](../../copy_archive/gemma_rebuild_2026-10-01/validation/ci-commands-24.json)·[compile28](../../copy_archive/gemma_rebuild_2026-10-01/validation/compile-28.json)이 통과했다. 실제 Warcraft·화면·멀티·재미·밸런스 미검증이며 맵은 만들지 않았다.`);
append('md/roguelite/사건 카드 재제작 검토 기록.md',`## 흥신소의 작은 사건과 성장 주체 정정

Gemma 피칭68의6발단 중4개를 남기고 범용 검문과 기존 부탁에 겹치는 대화를 폐기했다. [원안·이유·재검토 조건68](../../copy_archive/gemma_rebuild_2026-10-01/revisions/abydos-pitches-selection-68.json)에 남겼다. 요청수와 스키마는6으로 일치했다.

집필69는 아루가 성장한 것으로 주체를 뒤집고, 내기에 실패했으나 보상을 받는 문장을 썼다. 비방향 피해를 일반공격 피해로 바꾸고,카요코 후속의적수-1을 누락했다. [수정70](../../copy_archive/gemma_rebuild_2026-10-01/revisions/abydos-expansion-curation-70.json)에서 그 오류와 겁먹고 미안해하는 반응만 반복한 묘사를 고쳤다. 세리카 보상은 실제 장면에 세리카를 놓고 자신의 일을 마치는 박자로 연결했다. [역검토70](../../copy_archive/gemma_rebuild_2026-10-01/reviews/abydos-expansion-review-70.json)은PASS지만 자문이며 보상/설정 정확성의 단독 근거가 아니다.

[채택71](../../copy_archive/gemma_rebuild_2026-10-01/revisions/abydos-expansion-decision-71.json)에서 기존14카드·12사건의 모든 필드와 새 고정 수치를 대조했다. 38분기 및 실제 카드 지급·피해 함수 모의 검사가 통과했다. [기록 대조24](../../copy_archive/gemma_rebuild_2026-10-01/validation/monitor-content-check-24.json)의 새3요청은 공통 모니터링의 입력·원문·ID가 일치했다. 주간사용42%·잔여58%로 계속 진행한다.`);
append('md/roguelite/폐기된 사건 카드 아이디어.md',`## 아비도스의 범용 검문·떠밀린 약속과 초안의 수치 오류

히나의 검문은 누구에게나 붙일 수 있는 설명/기다림 메뉴여서 이번 확장에서 폐기했다. 히후미의 약속은 기존 페로로 부탁과 겹치며 여행자가 그녀의 모든 우선순위를 대신 정하고 모두 해결하는 결말이어서 폐기했다. [6원안·이유·재검토 조건68](../../copy_archive/gemma_rebuild_2026-10-01/revisions/abydos-pitches-selection-68.json)에 보존했다.

아루가 카드로 성장한다는 주체 오류,실패한 내기의 카드 지급,비방향을 일반공격으로 좁힌 설명,적 수 감소 누락은 제거했다. 카요코/하루카가 겁먹고 여행자의 배려에만 감사하는 반복도 원작 역할과 현장 말로 다시 썼다. [수정전후70](../../copy_archive/gemma_rebuild_2026-10-01/revisions/abydos-expansion-curation-70.json)의32변경을 보존하며 수치·확률·카드 참조는 유지했다.`);
append('md/roguelite/참고 시트와 설정 확인 범위.md',`## 흥신소68의 공식 인물 관계

[공식3·5·6화 줄거리](https://sh-anime.shochiku.co.jp/bluearchive-anime/story/)의 라멘 만남·이상과 현실·인도 요구를 읽었다. [아루](https://sh-anime.shochiku.co.jp/bluearchive-anime/character/rikuhachima-aru/)의허세,[카요코](https://sh-anime.shochiku.co.jp/bluearchive-anime/character/onikata-kayoko/)의음악CD/침묵오해,[하루카](https://sh-anime.shochiku.co.jp/bluearchive-anime/character/igusa-haruka/)의잡초취미,[무츠키](https://sh-anime.shochiku.co.jp/bluearchive-anime/character/asagi-mutsuki/)의장난/아루관계를 새 사건의 근거로 사용했다. [히나](https://sh-anime.shochiku.co.jp/bluearchive-anime/character/sorasaki-hina/)와[히후미](https://sh-anime.shochiku.co.jp/bluearchive-anime/character/ajitani-hifumi/)소개도 읽었지만 두 피칭은 이번 확장에서 폐기했다.

라멘 계산서·CD가게의작은오해·잡초화분·두봉투내기는 창작이다. 특정 곡/장르·식물명·원작 내기와 계산서 액수·실제 회사의뢰·학교 빚·가게폭파·구출을 확정하지 않는다. 게헨나 흥신소와 트리니티 히후미의 소속을 유지한다. 카드 효과는 여행자의 기억이며 원작 음악/폭발/공포/식물성장/동행 기능이 아니다.`);
append('copy_archive/gemma_rebuild_2026-10-01/README.md','아비도스에 흥신소68 독립4사건·자기1/2번선택에서 갈라지는후속2사건·카드6장을 추가했다. 피칭68/집필69/수정·PASS역검토70/원본바이트·해시와채택71을 보존한다. 성장주체·실패성공모순·비방향/기본공격혼동·감소누락은 고쳤고 범용검문/반복부탁은 폐기이유를 남겼다.38분기·카드조건·15검사·compile28·새3요청상세기록 대조가 통과했다. 맵과 Warcraft 실기는 없다.');
let body=fs.readFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-pr-165-body-23.md','utf8');
for(const [a,b]of [['카드 226장·사건 206개','카드 232장·사건 212개'],['독립 사건 161개','독립 사건 165개'],['후속 45개','후속 47개'],['최근62~67의 성공4요청 입력·원문·ID를 상세API와 대조했다.','최근68~70의 성공3요청 입력·원문·ID를 상세API와 대조했다. 후유키62~67의4요청 대조도 보존했다.'],['최근 후유키5사건30분기에서 자기 성공 후속·75/76확률 경계·밀도-1 감소','최근 아비도스6사건38분기에서 자기 성공1/2번 후속·60/61과75/76확률 경계·밀도-1 감소'],['최종compile-27.json·head-expansion-probe-12.json·card-condition-probe-66.json','최종compile-28.json·head-expansion-probe-13.json·card-condition-probe-71.json']]){assert(body.includes(a),a);body=body.replace(a,b);}
body=body.replace('궁도부 후속은 자기 성공1번만 요구한다.','궁도부 후속은 자기 성공1번만 요구한다. 아비도스에 아루의 계산서·카요코 주문·하루카 잡초·무츠키 봉투를 더하고 자기 계산 도움1번/한 곡 듣기2번을 별도 후속으로 연결했다.');
body=body.replace('보관 자료는 활성 Import에 들어가지 않는다.','아비도스 역검토는PASS지만 성장 주체·실패성공모순·비방향/일반공격 혼동·감소누락을 원문과 분리해 고친 기록과 실제 함수 모의검사를 함께 근거로 삼았다. 보관 자료는 활성 Import에 들어가지 않는다.');
body=body.replace('실제 스킬 시전·프레임·체력 실기는 미검증이다.','아루의 보스1.18/일반0.94와 무츠키의비방향플래그·하루카의70%체력비율도 실제 지급/피해함수로 대조했다. 실제 스킬 시전·프레임·체력 실기는 미검증이다.');
fs.writeFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-pr-165-body-24.md',body,{flag:'wx'});console.log(JSON.stringify(counts));
