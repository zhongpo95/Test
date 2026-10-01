// 세 카드의 선택 목적 수정과 검증 한계를 문서·PR 초안에 기록한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const compile=JSON.parse(fs.readFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-content-164-compile-23/report.json','utf8'));
const probe=read('validation/card-contrast-probe-47.json'),ci=read('validation/ci-commands-19.json'),monitor=read('validation/monitor-content-check-19.json'),decision=read('revisions/card-contrast-decision-47.json');
assert.equal(compile.compiler_exit,0);assert.equal(compile.pjass_exit,0);assert.equal(compile.map_created,false);assert(probe.passed);assert(ci.passed);assert.equal(monitor.checks.length,1);assert.equal(decision.adopted.length,3);
fs.writeFileSync(path.join(root,'validation/compile-23.json'),JSON.stringify(compile,null,2)+'\n',{flag:'wx'});
function append(file,s){fs.appendFileSync(path.join(repo,file),'\n'+s+'\n');}
append('md/roguelite/사건 카드 재제작 검토 기록.md',`## 같은 머리·등급의 카드 선택 목적 비교

기본 효과를 성분별로 비교하니 각성도 없고 기존 카드보다 모든 수치가 낮은 카드가 3장 있었다. 획득 비용과 필드 부담을 함께 보고 성장 목적을 구분했다. 이오의 미소는 차지 속도 5%를 최대 체력 8%로 바꾸고 고체력 피해 12%를 유지한다. 스파클의 마지막 장면은 행동 속도 4%를 차지 속도 12%로 바꾸고 치명타 피해 14%를 유지한다. 셰스카는 사건 후보 +1에 처치 골드 +1을 더했다. 등급·각성·사건 비용·확률·필드 변화는 바꾸지 않았다.

[원래 3쌍과 획득 조건](../../copy_archive/gemma_rebuild_2026-10-01/revisions/card-contrast-audit-before-47.json), [문장과 수치 수정 이유](../../copy_archive/gemma_rebuild_2026-10-01/revisions/card-contrast-curation-47.json), [독립 검토와 원본 해시](../../copy_archive/gemma_rebuild_2026-10-01/revisions/card-contrast-decision-47.json)를 보존한다. 같은 비교에서 하위 쌍은 없어졌지만, 다른 스탯의 가치 환산과 전체 밸런스가 검증된 것은 아니다. 카드 203장·사건 185개 수는 유지한다.

[실제 함수의 모의 실행](../../copy_archive/gemma_rebuild_2026-10-01/validation/card-contrast-probe-47.json)에서 최대 체력 10800과 현재 체력 7000 유지, 차지 준비 배율 1.12와 일반 행동 1.00, 셰스카 소유자 처치 11골드와 타인 10골드, 사건 후보 상한 4개를 확인했다. 기존 15검사와 스크립트 컴파일은 통과했다. Warcraft·화면·실제 멀티플레이·재미·밸런스는 미검증이다.`);
append('md/roguelite/카드 능력치 단위와 검토 기준.md',`## 같은 효과의 낮은 카드와 다른 성장 목적

수치 성분만 비교하는 검사는 가격·확률·필드 부담·개인 후속 접근과 각성 시간을 포함하지 않는다. 경고 후보를 찾는 데만 사용한다. 이번 3장은 각성 차이 없이 성장 축까지 같아, 최대 체력·차지 준비·처치 수입으로 구분했다.

추가 최대 체력은 즉시 치유가 아니다. 현재 체력 7000은 기본 최대 체력 10000에서는 65% 이상이지만, 최대 체력 10800에서는 약 64.8%라서 고체력 피해 조건에 미달한다. 물약과 체력 관리를 함께 고려해야 한다. 스파클의 차지 12%는 Arcana_ChargeSpeed를 사용하는 준비 구간에만 적용한다. 다른 속도가 없을 때 기존 행동 8%의 준비 배율 1.08보다 1.12로 높지만 일반 행동에는 기존 1.08 대신 1.00이며 치명타 피해도 1%p 낮다. 스킬 전체 DPS와 실제 프레임을 검증한 수치가 아니다.`);
append('md/roguelite/폐기된 사건 카드 아이디어.md',`## 세 카드의 같은 성장 축 수정

이오의 미소의 고체력 12%·차지 5%는 기존 이오의 고체력 12%·차지 8%와 비교해 준비 속도만 낮았다. 마지막 장면의 행동 4%·치명타 피해 14%는 기존 스파클의 행동 8%·치명타 피해 15%보다 모두 낮았다. 셰스카의 사건 후보 +1은 휴즈의 사건 후보 +1·보스 피해 6%와 성장 축이 겹쳤다. 전체 카드를 상향하는 대신 이오의 최대 체력, 스파클의 차지 준비, 셰스카의 사냥 수입으로 다른 목적을 만들었다. 원래 획득 비용·부담이 낮은 경우도 있어 순수 수치 비교만으로 무가치라고 단정하지 않았다.

[교체 전후와 이유](../../copy_archive/gemma_rebuild_2026-10-01/revisions/card-contrast-curation-47.json)를 남긴다. 새 역할의 카드가 실전에서 의미 없는 경우, 캐릭터별 차지 사용 빈도·65% 체력 유지·남은 사냥 시간과 재화 구매력을 확인한 뒤 다시 검토한다.`);
append('md/roguelite/참고 시트와 설정 확인 범위.md',`## 세 카드의 역할을 나누는 추가 근거

[리링크 공식 캐릭터 소개](https://asia.sega.com/relink.granbluefantasy/kr/characters/detail/?chara=io)에서 이오가 사람들에게 미소를 전하려는 작은 마법사라는 역할을, [개발팀 스타레일 2.0 소개](https://blog.ko.playstation.com/2024/01/30/20240130-honkaistarrail/)에서 스파클의 역할 바꾸기와 행동·치명타 지원을, [강철의 연금술사 공식 인물 소개](https://www.hagaren.jp/fa/characters/index01.html)에서 셰스카의 읽은 글을 기억하는 능력과 휴즈에게 인정받은 일을 확인했다. 최대 체력·차지 준비·처치 골드는 이 역할에 맞춘 맵 성장의 각색이며 공식 게임의 수치나 새 원작 기술로 주장하지 않는다.`);
append('copy_archive/gemma_rebuild_2026-10-01/README.md','검토 47은 같은 머리·등급에서 기본 효과가 모두 낮은 3장을 생존·차지 준비·사냥 수입으로 구분한다. 비용·확률·등급·각성·필드 부담은 유지했다. 기존 바이트/해시·수정 전후·Gemma 원문·상세 기록 일치·실제 스탯/지급 함수의 모의 실행과 compile-23을 보존한다. 카드·사건 수는 유지하며 맵 생성과 실제 게임 검증은 없다.');
let body=fs.readFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-pr-165-body-18.md','utf8');
body=body.replace('카드 능력치 24종을 연결했다.','같은 머리·등급에서 기본 효과가 모두 낮은 세 카드는 생존 여유·차지 준비·사냥 수입으로 선택 목적을 나눴다. 등급·각성·사건 비용·확률·필드 부담은 유지했다. 카드 능력치 24종을 연결했다.');
body=body.replace('이번 새 3요청의 입력·원문·ID를 기록 상세 API와 대조했다.','최근 검토 47의 입력·원문·ID를 기록 상세 API와 대조했다.');
body=body.replace('고정 체력 네이티브 모형이므로 전체 PlayerStatsSet·체력 비율 실기는 검증하지 않았다.','이전 사건 분기는 고정 체력 네이티브 모형이다. 새 카드 비교에서는 실제 PlayerStatsSet·SkillSpeed·카드 지급·ProtoKill을 모의 실행해 최대/현재 체력 분리·차지/일반 행동 차이·개인 처치 수입과 후보 상한을 확인했다. 실제 스킬 시전·프레임·체력 실기는 미검증이다.');
body=body.replace('최종 compile-22.json·head-expansion-probe-08.json·head-expansion-check-18.json에 저장했다.','최종 compile-23.json·card-contrast-probe-47.json과 기존 head-expansion-probe-08.json에 저장했다.');
fs.writeFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-pr-165-body-19.md',body,{flag:'wx'});
console.log(JSON.stringify({cards:203,events:185,revisedCards:3,compilerExit:0,mapCreated:false}));
