// 후유키 확장과 잘못된 이동중 기준의 정정·역검토 판단을 전달 문서에 보존한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const data=fs.readdirSync('content/roguelite').filter(x=>x.endsWith('.json')).map(x=>JSON.parse(fs.readFileSync(path.join('content/roguelite',x),'utf8')));
const counts={heads:data.filter(d=>d.world.key!=='common').length,cards:data.reduce((n,d)=>n+d.cards.length,0),events:data.reduce((n,d)=>n+d.events.length,0),roots:data.reduce((n,d)=>n+d.events.filter(e=>!e.previous).length,0),followups:data.reduce((n,d)=>n+d.events.filter(e=>e.previous).length,0)};assert.deepEqual(counts,{heads:13,cards:226,events:206,roots:161,followups:45});
const compile=JSON.parse(fs.readFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-content-164-compile-27/report.json','utf8')),probe=read('validation/head-expansion-probe-12.json'),ci=read('validation/ci-commands-23.json'),monitor=read('validation/monitor-content-check-23.json'),condition=read('validation/card-condition-probe-66.json'),review=read('reviews/fuyuki-focused-review-67.json');
assert.equal(compile.compiler_exit,0);assert.equal(compile.pjass_exit,0);assert.equal(compile.map_created,false);assert(probe.passed&&ci.passed&&condition.passed);assert.equal(probe.branchCases,30);assert.equal(monitor.checks.length,4);assert.equal(review.parsed.verdict,'REVISE');
write('revisions/fuyuki-focused-review-decision-67.json',{verdict:'REVISE',originalReview:'reviews/fuyuki-focused-review-67.json',decision:'계산 불일치라는 분류는 기각한다. 검토 본문도480에서6%,560에서12%가 일치한다고 계산했다. 기본400대비 추가40%에서 전부 적용된다는 설명은 같은 상한이며 이동중이라는 표현은 이미 제거했다.',evidence:{source:'System/ExpeditionEffects.j',probe:'validation/card-condition-probe-66.json',examples:condition.speedCases},ownCorrection:'집필63에 Codex가 이동중 피해라고 잘못 준 기준은 수정66에서 별도로 정정했다. 검토64의 기준 준수 평가는 함수 정확성의 증거로 사용하지 않는다.',revisit:'실제 함수·기본속도·상한이 달라지거나 인게임 표시가 비례 관계를 잘못 안내하면 다시 검토한다.',limits:'모델 verdict는 덮어쓰지 않았다. 실제 JASS 변환 모의 결과이며 Warcraft 실기가 아니다.'});
write('validation/compile-27.json',compile);
write('validation/head-expansion-check-23.json',{counts,contentGroups:21,statGroups:8,ciCommands:15,newRootCases:4,newFollowupCases:1,branchCases:30,cardConditions:condition,compilerExit:0,pjassExit:0,ignoredErrors:24,scriptSha256:compile.script_sha256,mapCreated:false,monitorCheckedRequests:4,usage:{used:41,remaining:59},modelReviews:{verdicts:['REVISE','REVISE'],decisions:['키레이의 일반 몬스터 가하는 피해 손해와 타이가의 다음 후보 증가 명확화','밀도 부담을 카드 효과에 붙이라는 지적 기각','Codex의 이동중 집필 기준을 실제 추가 이동속도 비례로 정정','일치하는 수치를 불일치로 분류한 focused67 지적 기각']},limits:['정적·JASS 변환 모의 실행·스크립트 컴파일을 검증했다.','Warcraft·실제 화면·멀티플레이·서버 저장·재미·밸런스는 미검증이다.']});
function replace(file,a,b){const p=path.join(repo,file),s=fs.readFileSync(p,'utf8');assert(s.includes(a),file+' 기준 문장 없음');fs.writeFileSync(p,s.replace(a,b));}
function append(file,s){fs.appendFileSync(path.join(repo,file),'\n'+s+'\n');}
replace('md/roguelite/사건 카드 재제작 검토 기록.md','현재 후보는 머리 13종, 성장 카드 219종, 사건 201개다. 독립 사건 157개와 개인 후속 사건 44개다.','현재 후보는 머리 13종, 성장 카드 226종, 사건 206개다. 독립 사건 161개와 개인 후속 사건 45개다.');
replace('md/roguelite/사건 카드 재제작 검토 기록.md','등급은 노말 20장·레어 188장·에픽 11장.','등급은 노말 20장·레어 195장·에픽 11장.');
append('md/roguelite/머리별 사건 확장 계획.md',`## 후유키의 자리·한 발·보호의 범위

펼치지 않은 이불, 여행자의 실패한 화살, 교회에서 들은 보호의 범위, 대응 뒤의 발자리를 독립4사건으로 추가했다. 궁도부에서 자기 동작을 물은 성공1번 뒤에는 기다릴 간격의 개인 후속1사건이 열린다. 카드7장을 연결해 후유키는 카드21장·독립14개·후속2개가 됐다. 전체는 카드226장·사건206개, 독립161개·후속45개다.

[30분기 검사](../../copy_archive/gemma_rebuild_2026-10-01/validation/head-expansion-probe-12.json)에서75/76경계·자기 후속·다른 사람 제외·적 수 감소·AP·카드/중복100골드·선지불·물약·골드0/상한의 무료 선택을 대조했다. [카드 조건 검사66](../../copy_archive/gemma_rebuild_2026-10-01/validation/card-condition-probe-66.json)은 추가 이동속도 비례·보호막 전제·일반 몬스터에게 가하는 피해 손해를 실제 지급과 피해 함수로 대조한다. [15검사](../../copy_archive/gemma_rebuild_2026-10-01/validation/ci-commands-23.json)·[compile27](../../copy_archive/gemma_rebuild_2026-10-01/validation/compile-27.json)이 통과했다. Warcraft·화면·실제 멀티·재미·밸런스는 미검증이며 맵은 만들지 않았다.`);
append('md/roguelite/사건 카드 재제작 검토 기록.md',`## 후유키 확장과 Codex 집필 기준의 오류 정정

Gemma 피칭62는 요청의5개와 재사용한 스키마 최소6개가 충돌했다. [선택62](../../copy_archive/gemma_rebuild_2026-10-01/revisions/fuyuki-pitches-selection-62.json)에 이 준비 오류와 중복안을 보존했다. 숙박 인물의 방을 여행자가 배정하는 행동, 타이가가 원작에서 화살을 실패했다는 전제, 인질 거래와 원작 충돌 뒤 방패 유지 가정은 제거했다.4발단은 여행자의 몫·실패·질문으로 다시 썼다.

집필63의 몬스터 수를 강함으로 뒤집은 표현·누락된100골드·빈 결과·자동보호막으로 보이는 표현을 [수정64](../../copy_archive/gemma_rebuild_2026-10-01/revisions/fuyuki-expansion-curation-64.json)에서 정정했다. 궁도부 후속의 랜서 보상 참조는 그 장면의 타이가 준비 카드로 바꾼1건이며 [채택65](../../copy_archive/gemma_rebuild_2026-10-01/revisions/fuyuki-expansion-decision-65.json)에 기존 바이트/해시와 함께 남겼다. 기존14카드·11사건은 보존했다. 검토64는REVISE다. 일반 피해 손해와 다음 후보 증가 설명은 명확히 하고 선택의 밀도 부담을 카드 효과에 붙이라는 제안은 기각했다.

Codex가 집필63과 검토64의 기준에 moving_damage를 이동중 피해라고 잘못 적었다. [정정66](../../copy_archive/gemma_rebuild_2026-10-01/revisions/fuyuki-moving-correction-66.json)에서 실제 함수의 기본400대비 추가 이동속도/40%를 대조해 설명만 고쳤다.12%/방관4% 수치는 유지했다. [역검토67](../../copy_archive/gemma_rebuild_2026-10-01/reviews/fuyuki-focused-review-67.json)은 다시REVISE지만 스스로480에서6%,560에서12%의 일치를 계산했다. [판단67](../../copy_archive/gemma_rebuild_2026-10-01/revisions/fuyuki-focused-review-decision-67.json)과 실제 지급·피해 함수 모의 검사에서350/400은0,480은6,560/600은12를 대조해 불일치 분류를 기각했다. 검토64의 잘못된 기준 준수를 계산 정확성 증거로 사용하지 않는다.

보호막 카드를 얻어도 보호막은 생기지 않고 이미 보호막이 있을 때만14/15피해가 적용됐다. 키레이 카드는 받는피해감소7과 일반대상 배율0.96·보스1.0을 대조했다. 추가 검사 초안은 복사된 모의 환경의 이전 속도 네이티브를 참조해0을 냈으며 실제 조건부 함수를 같은 환경에 다시 바인딩해 고쳤다. 활성 전투 함수를 수정한 것은 아니다. [기록 대조23](../../copy_archive/gemma_rebuild_2026-10-01/validation/monitor-content-check-23.json)에서 새 성공4요청의 입력·원문·ID 저장이 일치했다. 주간사용41%·잔여59%로 계속 진행한다.`);
append('md/roguelite/폐기된 사건 카드 아이디어.md',`## 후유키의 원작 소유권과 이동중이라는 잘못된 기준

원작 숙박 배정·타이가의 사격 실패·교회 비밀 해결·인질 거래·계속 유지되는 원작 방패를 여행자가 정하는 제안은 채택하지 않았다. 똑같은 숙박 피칭이 다시 나온6번도 중복으로 폐기했다. 개수 요청/스키마 충돌은 Codex 준비 오류였다. [피칭62의 이유·재검토 조건](../../copy_archive/gemma_rebuild_2026-10-01/revisions/fuyuki-pitches-selection-62.json)을 보존했다.

궁도부 장면에 없던 랜서 보상은 타이가 준비 카드로 교체했다. Codex가 잘못 준 이동중 피해 기준은 [정정66](../../copy_archive/gemma_rebuild_2026-10-01/revisions/fuyuki-moving-correction-66.json)에 남겼다. 원문은 덮어쓰지 않고 추가 이동속도 비례로 정정한다. [검토64 판단](../../copy_archive/gemma_rebuild_2026-10-01/revisions/fuyuki-review-decision-64.json)·[67 판단](../../copy_archive/gemma_rebuild_2026-10-01/revisions/fuyuki-focused-review-decision-67.json)에 밀도 부담을 카드 효과로 옮기는 제안과 일치하는 계산을 불일치로 분류한 지적의 기각 이유를 남겼다.`);
append('md/roguelite/참고 시트와 설정 확인 범위.md',`## 후유키의 숙박·궁도부·감독자·대응

[공식 인물 소개](https://www.fate-sn.com/ubw/chara/)의 타이가 궁도부 고문·사쿠라 관계와 [공식 줄거리 첫 페이지](https://www.aniplex.co.jp/lineup/fate-sn-ubw/story/?p=1)의4화 영체화 불가/숙박,2·9화 감독자/교회 보호,12화 인질 상황을 읽었다. [두 번째 페이지](https://www.aniplex.co.jp/lineup/fate-sn-ubw/story/?p=2)의17화 강한 공격과 방패 대응도 읽었다. 인질 거래는 채택하지 않았다.

여행자의 실패한 화살·자기 이불·보호 질문·대응 뒤 발자리는 별도 방문의 창작이다. 궁도 승패·숙박 방 배정·원작 결투 직후 방패 지속·인물의 새 계약·원작 보구를 확정하지 않는다. 보수·준비값·성장 기억·새 대사는 창작이며 실제 활·보구·NPC동행·자동보호막을 지급하지 않는다.`);
append('copy_archive/gemma_rebuild_2026-10-01/README.md','후유키 독립4사건·궁도부 자기 성공 후속1사건·카드7장을 추가했다. 피칭62·집필63·검토64·채택65·이동속도 비례 정정66·역검토67 원문과 판단을 보존한다.5개 요청/최소6스키마 충돌과 잘못된 이동중 집필 기준은 Codex 오류로 구분한다.30분기·실제 카드 조건·15검사·compile27·4요청 입력/원문/ID 상세기록 대조를 보존한다. 맵과 Warcraft 실기 검증은 없다.');
let body=fs.readFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-pr-165-body-22.md','utf8');
body=body.replace('카드 219장·사건 201개','카드 226장·사건 206개').replace('독립 사건 157개','독립 사건 161개').replace('후속 44개','후속 45개');
body=body.replace('새 후속은 자기 성공1번만 요구한다.','후유키는 자기 자리·실패한 화살·보호의 범위·대응 뒤 발자리를 더했다. 궁도부 후속은 자기 성공1번만 요구한다.');
body=body.replace('최근57~60의 성공4요청 입력·원문·ID와 실패1요청 전체 기록을 상세API와 대조했다.','최근62~67의 성공4요청 입력·원문·ID를 상세API와 대조했다. 이전57~60의 성공4건과 실패1건 대조도 보존했다.');
body=body.replace('학원도시의 두 검토도 REVISE이며 문장 명확화와 지원되는 감소·스탯 설명에 대한 잘못된 지적 기각을 기록했다.','후유키의 두 검토도 REVISE이며 문장 명확화와 잘못된 지적 기각을 기록했다. Codex가 이동중 피해라고 잘못 준 기준은 실제 추가 이동속도 비례로 설명을 정정하고 원문을 보존했다.');
body=body.replace('최근 학원도시6사건34분기에서 자기 성공 후속·70/71확률 경계·밀도-1 감소','최근 후유키5사건30분기에서 자기 성공 후속·75/76확률 경계·밀도-1 감소');
body=body.replace('실제 스킬 시전·프레임·체력 실기는 미검증이다.','랜서12% 카드는 실제 지급/피해 함수로 속도400/480/560에서0/6/12%를 확인했다. 보호막 카드는 자동보호막 없이 기존 보호막에서만 적용되며 키레이의 일반대상 피해 손해도 확인했다. 실제 스킬 시전·프레임·체력 실기는 미검증이다.');
body=body.replace('최종compile-26.json·head-expansion-probe-11.json','최종compile-27.json·head-expansion-probe-12.json·card-condition-probe-66.json');
fs.writeFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-pr-165-body-23.md',body,{flag:'wx'});console.log(JSON.stringify(counts));
