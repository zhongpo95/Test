// 호접저·후유키·카라쿠라의 확장 검증과 폐기 근거를 문서와 PR 설명에 보존한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const data=fs.readdirSync(path.join(repo,'content/roguelite')).filter(x=>x.endsWith('.json')).map(x=>JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite',x),'utf8')));
const counts={heads:data.filter(x=>x.world.key!=='common').length,cards:data.reduce((n,x)=>n+x.cards.length,0),events:data.reduce((n,x)=>n+x.events.length,0),roots:data.reduce((n,x)=>n+x.events.filter(e=>!e.previous).length,0),followups:data.reduce((n,x)=>n+x.events.filter(e=>e.previous).length,0)};
assert.deepEqual(counts,{heads:13,cards:197,events:179,roots:140,followups:39});
for(const x of data.filter(x=>x.world.key!=='common'))assert(x.events.filter(e=>!e.previous).length>=10);
const compile=JSON.parse(fs.readFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-content-164-compile-21/report.json','utf8')),probe=read('validation/head-expansion-probe-07.json'),ci=read('validation/ci-commands-17-final.json'),monitor=read('validation/monitor-content-check-17.json');
assert.equal(compile.compiler_exit,0);assert.equal(compile.pjass_exit,0);assert.equal(compile.map_created,false);assert.equal(probe.passed,true);assert.equal(probe.roots,8);assert.equal(probe.branchCases,43);assert.equal(ci.passed,true);assert.equal(monitor.checks.length,12);
for(const id of [20,21])fs.writeFileSync(path.join(root,'validation/compile-'+id+'.json'),fs.readFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-content-164-compile-'+id+'/report.json'),{flag:'wx'});
fs.writeFileSync(path.join(root,'validation/head-expansion-check-17.json'),JSON.stringify({counts,contentGroups:21,statGroups:8,ciCommands:15,newRootCases:8,branchCases:43,compilerExit:0,pjassExit:0,ignoredErrors:24,scriptSha256:compile.script_sha256,mapCreated:false,monitorCheckedRequests:12,usage:{used:40,remaining:60},limits:['신규 생성 JASS 함수의 변환 모의 실행과 스크립트 컴파일이다. 공통 모형의 체력 네이티브가 고정되어 전체 PlayerStatsSet·체력 비율을 실제 게임에서 검증한 것은 아니다.','Warcraft·화면·실제 멀티·서버 저장·프레임·재미·밸런스 미검증.']},null,2)+'\n',{flag:'wx'});
function replace(file,a,b){const p=path.join(repo,file),s=fs.readFileSync(p,'utf8');assert(s.includes(a),file+' 기준 문장 없음');fs.writeFileSync(p,s.replace(a,b));}
function append(file,s){fs.appendFileSync(path.join(repo,file),'\n'+s+'\n');}
replace('md/roguelite/사건 카드 재제작 검토 기록.md','현재 후보는 머리 13종, 성장 카드 189종, 사건 171개다. 독립 사건 132개','현재 후보는 머리 13종, 성장 카드 197종, 사건 179개다. 독립 사건 140개');
replace('md/roguelite/사건 카드 재제작 검토 기록.md','등급은 노말 20장·레어 158장·에픽 11장.','등급은 노말 20장·레어 166장·에픽 11장.');
const table=['| 머리 | 카드 | 독립 | 후속 |','| --- | --- | --- | --- |',...data.map(x=>`| ${x.world.name} | ${x.cards.length} | ${x.events.filter(e=>!e.previous).length} | ${x.events.filter(e=>e.previous).length} |`)].join('\n');
append('md/roguelite/머리별 사건 확장 계획.md',`## 호접저·후유키·카라쿠라 추가 확장

나비저택은 선배 호칭·동료의 훈련 복귀·네즈코를 두려워하는 방문객의 독립3사건과 카드3장을 더해 독립10개·전체12개·카드15장이다. 후유키는 창병과 좁은 길의 독립1사건과 카드1장을 더해 독립10개·전체11개·카드14장이다. 카라쿠라는 카린의 빈 자리·잇신의 과한 환영·우루루의 큰 심부름·케이고의 허락 없는 초대로 독립4사건과 카드4장을 더해 독립13개·전체18개·카드17장이다.

무료 관찰이나 대화로 카드를 얻는 선택도 행동력1을 소모한다. 훈련 복귀의 원래3분기는 골드0·밀도상한에서 모두 막혔다. 사건은 후보에서 제외되므로 빈 선택창이 열리는 버그는 아니지만, 언제나 고를 행동이 있도록 무료로 연락을 돕고 밀도를 낮춰 물약1개를 받는 네 번째 분기를 더했다. [실패 재현](../../copy_archive/gemma_rebuild_2026-10-01/validation/head-expansion-probe-07-failed.json)·[보완 판단](../../copy_archive/gemma_rebuild_2026-10-01/revisions/butterfly-fallback-decision-43.json)을 보존했다.

새8사건·분기43가지,15검사명령·스크립트컴파일을 통과했다. [체크포인트17](../../copy_archive/gemma_rebuild_2026-10-01/validation/head-expansion-check-17.json)에 보고한다. 현재13머리 모두 처음 만날 독립 사건10개 이상이며,이는 최종 수량 상한이 아니다. 전체카드197장·사건179개,독립140개·후속39개다. 실제 게임·멀티·화면·재미·밸런스는 미검증이다.

${table}`);
append('md/roguelite/사건 카드 재제작 검토 기록.md',`## 새 방문과 유효한 선택의 대조

호접저·후유키·카라쿠라에 독립8사건·카드8장을 추가했다. 피칭32의 호접저8개는 훈련 지도 반복과25화 역할 오독으로 폐기했다. 피칭33·34·35는 각각3·1·4개의 소재만 재설계 후 채택했다. 원문과 모든 제외 이유·재검토 조건을 보존한다.

카라쿠라 첫 집필은 내부 필드 목록·JSON 구조 조각과 잘못된 발단을 남겨 전량 미반영하고 재집필했다. 두 번째 집필도 의원 사건의 키를 복사하고 첫 사건 본문을 선택 후 결과로 바꿨다. 일치하는 장면과 선택 순서를 대조하여 키를 복구하고 분기별 결과를 수정했다. [수정 기록](../../copy_archive/gemma_rebuild_2026-10-01/revisions/karakura-expansion-curation-42.json)에 남겼다.

모델 역검토3건은 PASS·빈issues였다. 무료4분기의 별도 역검토는 REVISE를 반환했으나 실제 입력에 들어 있는 밀도감소·물약획득을 없다고 했고 필드 선적용과 카드 지급을 충돌이라고 했다. 실제 결과와 처리 함수에 맞지 않는 지적3개는 기각 이유를 보존했다. 최종 생성 함수 모의 검사는8사건43분기를 통과했다. 실패했던상태도 무료4선택을 실제로 고를 수 있었다.

모니터링 상세 API에서 새12개 요청의 입력·raw·기록ID가 모두 일치했다. API의 성공은 모델 요청과 기록 저장 성공이며 사건 내용의 정확성이나 재미를 의미하지 않는다. 스크립트컴파일21과15검사명령을 통과했고 pjass24 errors ignored 설정은 유지된다. 맵 생성·Warcraft·시각·멀티·저장·프레임·재미·밸런스 실기는 수행하지 않았다.`);
append('md/roguelite/폐기된 사건 카드 아이디어.md',`## 호접저·후유키·카라쿠라의 추가 피칭과 집필

호접저 피칭32의8개는 일반 훈련 지도 반복,카나오와 탄지로의 성장 주체 오독,전투 중 극도의 공포라는 젠이츠 수면 조건의 확대,네즈코의 자기 의지를 암시에 종속시킨 묘사로 폐기했다. [각 원안·이유·재검토조건](../../copy_archive/gemma_rebuild_2026-10-01/revisions/butterfly-pitches-rejected-32.json)을 보존한다. 피칭33의미소거절·호의·리듬·예법·감사5개는 문제를 구체화하지 못하거나 이노스케의 무례함을 반복해 미채택했다. [피칭33판단](../../copy_archive/gemma_rebuild_2026-10-01/revisions/butterfly-pitches-selection-33.json)에 기록한다.

후유키 피칭34의7개는 장비목록·세이버대련·신지협력 중복,관리 효율에 머문 린,근거 없는 키레이의 정원사 취향,아처의 상시 감시와 사쿠라 간식의 불분명한 부담으로 미채택했다. [후유키 판단](../../copy_archive/gemma_rebuild_2026-10-01/revisions/fuyuki-pitches-selection-34.json)을 보존한다. 카라쿠라 피칭35의4개는 우류의 나쁜 취향을 자신감 부족으로 바꾼 점,플레이어 귀도 설명 가정,주체가 불분명한 외모 오해,인물 없는 축제 동선으로 미채택했다. [카라쿠라 판단](../../copy_archive/gemma_rebuild_2026-10-01/revisions/karakura-pitches-selection-35.json)에 기록한다.

카라쿠라 집필39는 결과에 비용/배움/골드 등 내부필드와 JSON구조조각을 노출하고 발단의주체를바꿨다. 전량미반영하고 [원문](../../copy_archive/gemma_rebuild_2026-10-01/drafts/karakura-expansion-text-39.json)·[재집필 이유](../../copy_archive/gemma_rebuild_2026-10-01/revisions/karakura-text-rejection-39.json)를 보존했다. 재집필41에서도 중복키·결과로시작한본문·한명만강해지는단계표현을 그대로 쓰지 않았다. [수정전후](../../copy_archive/gemma_rebuild_2026-10-01/revisions/karakura-expansion-curation-42.json)에 모두 보존한다. 구체적인 장면·인물·지정성장과 실제 필드 값을 맞춘 경우에만 다시 검토한다.

훈련복귀의 원래3분기는 골드0·밀도10에서 모두 막히므로 해당 구성을 유지하지 않았다. 무료4분기를 추가했고,모델이 이 분기의 물약과 밀도감소를 없다고 한 재검토 지적도 입력과 맞지 않아 기각했다. [모델원문](../../copy_archive/gemma_rebuild_2026-10-01/reviews/butterfly-fallback-review-43.json)·[지적별 대조](../../copy_archive/gemma_rebuild_2026-10-01/revisions/butterfly-fallback-decision-43.json)에 기록한다.`);
append('md/roguelite/참고 시트와 설정 확인 범위.md',`## 추가 방문의 원작 근거와 한계

나비저택은 [24화](https://kimetsu.com/anime/risshihen/story/?story=24)와 [25화](https://kimetsu.com/anime/risshihen/story/?story=25),[히노카미 혈풍담 본편 소개](https://game.kimetsu.com/hinokami/character/)에서 역할과 조건을 다시 읽었다. 25화는 탄지로가 카나오와의 훈련에서 발전하는 내용이며 카나오를 탄지로가 가르친다는 뜻이 아니다. 무라타는 선배 귀살대원,네즈코는 자기 의지와 암시로 사람을 해치지 않는다. 젠이츠가 잠드는 조건은 전투 중 극도의 공포다. 페이지 아래 학원 파생작을 본편과 섞지 않았다. 카나오 동전의 개별주소는 본문을 읽지 못해 이 새 집필 근거로 쓰지 않았다.

후유키 [공식 인물 본문](https://www.fate-sn.com/ubw/chara/)은 랜서가 세이버와 대등한 창병이라는 소개를 확인했다. 랜서의 진의와 마스터는 새 사건에서 확정하지 않는다. 카라쿠라 [제작사 본문](https://pierrot.jp/title/bleach/chara.html)에서는 카린의냉정함/영감,잇신의의원/가족사랑,진타와우루루의점원역할/우루루의초인성,활발한케이고를읽었다. 카린 스포츠 취미는이본문으로확인하지않았다. 벤치·환대·심부름·허락없는초대와 수치·물약은맵의창작이다. 전체애니메이션·게임·이미지픽셀·한국어공식대사와현지화이름전체를검토하지않았다.`);
append('copy_archive/gemma_rebuild_2026-10-01/README.md','호접저·후유키·카라쿠라의 독립8사건과8카드를 추가했다. 피칭32~35·집필36/38/39/41·검토37/40/42/43의 원문과 폐기 이유를 보존한다. probe-07 최초 상한 상태 실패와 무료4분기 보완,최종8사건43분기 성공도 남겼다. compile-20은보완전이며최종은compile-21이다. 모니터링 새12요청의입력/원문/ID일치와실제게임미검증을구분한다. 모델REVISE도원문을보존하고잘못된지적은구체적반증과함께기각했다.');
const oldBody=fs.readFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-pr-165-body-17-source.md','utf8').replace(/^\uFEFF/,'');
const monitorSection=oldBody.slice(oldBody.indexOf('## Gemma 모니터링 연결')).replace(/\s*Closes #164\s*$/,'');assert(monitorSection.includes('51b0c55'));
const body=`기존 개인 사냥은 무작위 카드와 피해·피해 감소 중심의 보상을 반복했다. 머리로 관련 사건 풀을 여는 시스템은 유지하고 제공 시트의 작품 범위와 별도로 확인한 원작 자료를 사용해 머리13종·성장카드197종·사건179개로 콘텐츠를 교체했다. 처음 만날 독립 사건140개와 자신의 이전 행동을 요구하는 후속39개를 구분한다. 13머리 모두 독립10개 이상이며 개수 상한은 아니다.

사건의2~4행동은 만난 인물의 지정 카드·골드·물약·지속 개인 적 단계/밀도와 후속으로 이어진다. 무료 관찰·대화도 행동력1을쓴다. 같은 카드를 이미 가지고 있으면100골드로교환한다. 머리의입문효과와개인후속은유지했다. 확장시작의52독립사건에서88개를추가했으며 이번에는선배호칭·훈련복귀·네즈코방문·창병간격·카린의빈자리·잇신의환대·점원심부름·허락없는초대를더했다. 골드0·밀도상한에서훈련복귀의행동이모두막히던구성은무료연락/밀도완화/물약선택으로보완했다.

런공격력·대미지·최종/대상별피해·치명·신속·조건부효과등24개카드스탯을연결했다. 흡수와재생은합산최대체력10%/초이며기존물약회복은별도다. 사건에서현재체력을지불하지않는다. 기존각인장비의영구데이터와원정밖처리는보존했다. 원작기술·NPC전투동행·새장비를지급하지않는다.

집필·재집필·역검토원문,교체전소스바이트/해시,폐기이유/재검토조건,모델지적의반영/기각을copy_archive에보존했다. 기록API의성공과원작/게임내용의정확성은구분한다. 새12요청의입력·raw·기록ID를실제상세API와대조했다. 보관자료는활성Import에들어가지않는다.

검증한 범위.

- 정적/모의 실행. 콘텐츠21그룹·스탯8그룹을포함한15검사명령,생성데이터/검토문서일치가통과했다. 이번8독립사건43분기에서머리소지·이전기록불필요·AP1회·지정카드·중복100골드·비용·물약·개인필드·다른플레이어값보존·빈골드/상한의유효선택을대조했다. 이전묶음의확률경계/후속검사도통과했다. 체력네이티브고정모형으로전체PlayerStatsSet실기를검증한것은아니다.
- 스크립트 빌드. 현재Import.j를기존템플릿에연결해JassHelper --scriptonly와pjass exit0. 24 errors ignored 허용설정이있으며무경고검증이아니다. 최종compile-21.json·head-expansion-probe-07.json·head-expansion-check-17.json에기록했다.
- 미수행. Warcraft실행·실제화면·멀티플레이·서버저장·프레임·재미·밸런스검증.
- 전달 확인. 맵생성·패키징·배포·병합없음. 활성소스/문서공백검사와원문바이트보존. 작업을계속하는Draft PR이다.

검토 시작점은 md/roguelite/머리별 사건 확장 계획.md,검토용 사건 카드 목록.md,폐기된 사건 카드 아이디어.md다. 각성은개인사냥중진행하고보스구간에는획득효과가유지된다.

${monitorSection}

Closes #164
`;
fs.writeFileSync('C:/Users/ctqho/AppData/Local/Temp/arcana-pr-165-body-17.md',body,{flag:'wx'});console.log(JSON.stringify(counts));
