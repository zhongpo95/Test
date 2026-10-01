// 아비도스 세 카드의 채택·폐기·검사 결과와 초안 PR의 현재 범위를 기록한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const data=fs.readdirSync('content/roguelite').filter(f=>f.endsWith('.json')).map(f=>JSON.parse(fs.readFileSync(path.join('content/roguelite',f),'utf8')));
const counts={heads:data.filter(d=>d.world.key!=='common').length,cards:data.reduce((n,d)=>n+d.cards.length,0),events:data.reduce((n,d)=>n+d.events.length,0),roots:data.reduce((n,d)=>n+d.events.filter(e=>!e.previous).length,0),followups:data.reduce((n,d)=>n+d.events.filter(e=>e.previous).length,0)};
assert.deepEqual(counts,{heads:13,cards:258,events:217,roots:169,followups:48});
assert.equal(data.flatMap(d=>d.cards).filter(c=>c.grade===2).length,227);
const compile=JSON.parse(fs.readFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-content-164-compile-32/report.json','utf8')),probe=read('validation/head-card-choices-probe-18.json'),ci=read('validation/ci-commands-28.json'),monitor=read('validation/monitor-content-check-28.json');
assert.equal(compile.compiler_exit,0);assert.equal(compile.pjass_exit,0);assert.equal(compile.map_created,false);assert(probe.passed&&ci.passed);assert.equal(probe.branchCases,114);assert.equal(monitor.checks.length,12);
write('validation/compile-32.json',compile);
write('validation/head-choices-check-28.json',{counts,rewrittenEvents:18,choices:54,newCards:10,branchCases:114,historyGates:probe.historyGates,newMemoryStats:probe.newMemoryStats,noParentCardRepeat:probe.noParentCardRepeat,directGoldChoices:0,removedGoldChoices:13,ciCommands:15,monitorRecords:12,compilerExit:0,pjassExit:0,ignoredErrors:24,scriptSha256:compile.script_sha256,mapCreated:false,usage:{used:43,remaining:57},review:'세 역검토 PASS와 실패 문구 추가 검토 PASS',completedChoiceHeads:4,completedChoiceEvents:67,completedChoices:202,testCorrection:'직접 기록만 넣던 검사에 기존 호시노 카드 보유 조건을 추가했다. 카드 없이는 제외, 카드 보유 뒤 정확한 자기 기록만 허용한다. 실제 진입 조건과 JASS 코드는 바꾸지 않았다.',limits:['정적·JASS변환모의·스크립트컴파일이다. Warcraft·시각·멀티·저장·실전밸런스·재미는 미검증이다.']});
function append(file,text){fs.appendFileSync(file,'\n'+text+'\n');}
const record='md/roguelite/사건 카드 재제작 검토 기록.md';
let text=fs.readFileSync(record,'utf8');assert(text.includes('성장 카드 248종'));text=text.replace('성장 카드 248종','성장 카드 258종').replace('노말 20장·레어 217장·에픽 11장','노말 20장·레어 227장·에픽 11장');fs.writeFileSync(record,text);
append(record,`## 아비도스의 세 행동과 세 기억

아비도스18사건을 서로 다른 지정카드3종·54선택으로 구성했다. 직접골드13선택과 네 번째 골드 대안을 제거하고 기존20카드·머리효과를 보존했다. 세리카의 주문/교대, 아야네의 전달/빈칸, 무츠키의 관찰/답, 카요코의 간격/주문, 하루카의 질문/자리 기억10장을 더했다. 새 기술이나 인물의 능력치 상승이 아니라 플레이어가 선택을 거치며 얻는 성장이다.

라멘교대1·사막방어1·아루계산1·카요코한곡2의 자기 성공 후속과 부모 카드 반복 없음을 유지했다. 사막 후속은 기존 호시노 보유도 요구한다. [114분기 검사](../../copy_archive/gemma_rebuild_2026-10-01/validation/head-card-choices-probe-18.json)에서 확률 실패·비용·물약·필드 상하한·중복100골드·AP·다른 플레이어·필수카드·합산을 대조했다. 직접 기록만 주입하던 검사 누락을 고쳤고 실제 진입 조건은 바꾸지 않았다.

집필86의 JSON 조각·다른 언어·확정 선택의 확률 창작·단위 변경과 집필87의 반복 반응을 [반려87](../../copy_archive/gemma_rebuild_2026-10-01/revisions/abydos-card-choices-draft-rejection-87.json), [수정88](../../copy_archive/gemma_rebuild_2026-10-01/revisions/abydos-card-choices-curation-88.json)에 보존했다. 역검토 세 PASS 이후에도 실패 문구의 옛 보수 표현을 발견해 [수정89](../../copy_archive/gemma_rebuild_2026-10-01/revisions/abydos-card-choices-curation-89.json)와 별도 PASS를 남겼다. 모델 판단은 자문이다.

[15회귀](../../copy_archive/gemma_rebuild_2026-10-01/validation/ci-commands-28.json)와 [12저장기록](../../copy_archive/gemma_rebuild_2026-10-01/validation/monitor-content-check-28.json) 입력/원문/ID 대조가 통과했다. [컴파일32](../../copy_archive/gemma_rebuild_2026-10-01/validation/compile-32.json)는 compiler/pjass0·기존 ignored24개다. 맵은 만들지 않았다. 실제 Warcraft·시각·멀티·저장·재미·실전밸런스는 미검증이다. 세 카드 정리는 네 머리67사건202선택까지 진행했고 다른 머리는 계속 작업한다.`);
append('md/roguelite/머리별 사건 확장 계획.md',`## 아비도스 보상 세 갈래

카드30장·독립14개·후속4개다. 18사건54선택 모두 다른 지정카드를 준다. 골드만 지급하던13대안은 제외하고 기존 성공 선택번호와 호시노 보유 조건을 유지한다. 세 카드 정리는 나비저택·후유키·액셀·아비도스67사건202선택까지 진행했다. 전체는 카드258장·사건217개이며 다른 머리와 공통은 계속 작업한다.`);
append('md/roguelite/폐기된 사건 카드 아이디어.md',`## 아비도스의 보수 대안과 집필 오독

일당·분실물 보수 등 직접골드13선택, 네 번째 골드 대안, 부모가 이미 준 기억을 다시 받는 후속 구성은 제외했다. [원본86](../../copy_archive/gemma_rebuild_2026-10-01/before-abydos-card-choices-86.json)을 보존했다. 집필86의 코드/JSON 조각·다른 언어·새 확률·단위 변경·NPC 성장 오독과 집필87의 반복 끄덕임은 수정전후를 분리했다. 원래 카드·비용·물약·필드와 플레이어 행동 및 남은 현장 문제가 함께 맞아야 재검토한다. 세 PASS에서 누락된 실패 문구의 옛 보수도 별도 수정89에 남겼다.`);
append('md/roguelite/참고 시트와 설정 확인 범위.md',`## 아비도스 세 카드 재구성의 확인 범위

[공식 세리카 소개](https://sh-anime.shochiku.co.jp/bluearchive-anime/character/kuromi-serika/)의 회계와 아르바이트, [아야네 소개](https://sh-anime.shochiku.co.jp/bluearchive-anime/character/okusora-ayane/)의 비서·원칙·기계/가계부/골동품, [카요코 소개](https://sh-anime.shochiku.co.jp/bluearchive-anime/character/onikata-kayoko/)의 음악과 CD 수집·무뚝뚝한 인상, [하루카 소개](https://sh-anime.shochiku.co.jp/bluearchive-anime/character/igusa-haruka/)의 잡초 취미·소극성과 낮은 자신감을 대조했다. 대사·기억·수치·비용·사냥 변화는 별도 각색이다. 짧은 선택으로 학교 부채·실종·과거 갈등 전체를 해결한 것처럼 쓰지 않는다.`);
append('md/roguelite/카드 능력치 단위와 검토 기준.md',`## 아비도스 새 기억의 분화

주문 기억은 행동속도/일반피해, 교대는 공격력/재생, 전달은 이동/최대체력, 빈칸은 치명피해/피해감소, 관찰은 치명피해/보스피해, 간격은 치명확률/비방향피해, 주문은 최대체력/행동속도, 질문은 일반피해/피해감소, 자리는 최대체력/65%이상 체력조건 피해, 답은 행동속도/비방향피해로 나눴다. 기본 동급 성분 우월쌍0은 실전 균형 증명이 아니다. 부모 카드 재지급을 피하고 필수카드/자기 기록을 함께 검사한다.`);
append('copy_archive/gemma_rebuild_2026-10-01/README.md','아비도스86~90·검증28은18사건54선택·기억10장·직접골드13개제거를 기록한다. 원본20카드/머리효과·네 자기후속·호시노 필수카드를 유지했다. 집필8·역검토4·12모니터·114분기·15회귀·compile32를 보존한다. 직접기록 검사에 필수카드 누락을 보완했으며 실제 진입 조건은 바꾸지 않았다. 맵·Warcraft·시각·멀티·재미는 미검증이고 다른 머리는 진행중이다.');
let body=fs.readFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-pr-165-body-27.md','utf8');
body=body.replaceAll('248카드','258카드').replace('액셀16사건49선택에 적용했고','액셀16사건49선택·아비도스18사건54선택에 적용했고').replace('최근액셀99분기','최근아비도스114분기·액셀99분기').replace('최근7Gemma요청','최근12Gemma요청').replaceAll('컴파일31','컴파일32').replaceAll('compile-31.json','compile-32.json').replaceAll('head-card-choices-probe-17.json','head-card-choices-probe-18.json').replaceAll('ci-commands-27-passed.json','ci-commands-28.json');
body+='\n아비도스는 기존20카드·머리효과를 유지하고 기억10장을 더해18사건54선택을 구성했다. 직접골드13개를 제거했다. 네 자기후속과 호시노 필수카드 조건을 유지하며 부모카드 반복을 피했다. 검사에 필수카드 주입 누락을 보완했고 실제 진입 로직은 변경하지 않았다.\n';
fs.writeFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-pr-165-body-28.md',body,{flag:'wx'});
console.log(JSON.stringify({counts,completedChoiceEvents:67,compile:32,mapCreated:false}));
