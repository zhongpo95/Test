// 검토한 나즈린 공통 사건을 반영하고 미채택 원안과 시트 확인 한계를 문서로 남긴다.
'use strict';
const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname,'../../..');
const file = path.join(root,'content/roguelite/08-common.json');
const raw = fs.readFileSync(file);
const existing = JSON.parse(raw.toString('utf8'));
const candidate = JSON.parse(fs.readFileSync(path.join(__dirname,'../drafts/nazrin-curated-02.json'),'utf8'));
if (existing.cards.length!==8 || existing.events.length!==10 || existing.cards.some(c=>c.key===candidate.cards[0].key)) throw Error('보관·반영 대상이 예상한 공통 원안과 다릅니다.');
fs.writeFileSync(path.join(__dirname,'08-common-before-nazrin-03.json'),raw,{flag:'wx'});
existing.world.work += ' · 동방프로젝트';
existing.sources.push(...candidate.sources);
existing.canonBoundary += ' ' + candidate.canonBoundary;
existing.cards.push(...candidate.cards);
existing.events.push(...candidate.events);
fs.writeFileSync(file,JSON.stringify(existing,null,2)+'\n');
function append(name,text) {fs.appendFileSync(path.join(root,'md/roguelite',name),'\n'+text.trim()+'\n');}
append('폐기된 사건 카드 아이디어.md',`
## 봇치 공통 사건 1차 원안 제외

[5카드·3사건 계획](../../copy_archive/gemma_rebuild_2026-10-01/requests/bocchi-plan-01.json), [Gemma 집필 원문](../../copy_archive/gemma_rebuild_2026-10-01/drafts/bocchi-text-01.json), [별도 검토 응답](../../copy_archive/gemma_rebuild_2026-10-01/reviews/bocchi-review-02.json)을 보존했다. 이번 묶음은 활성 콘텐츠에 넣지 않았다. 작품 자체를 제외한 것이 아니며 아래 판단은 편집·설계 검토이지 실제 플레이 평가가 아니다.

| 원안 | 제외한 이유 | 다시 검토할 조건 |
| --- | --- | --- |
| 첫 공연 전의 매표소, 인사 뒤에 남은 말, 사진에 담기지 않는 소리. | 선택이 대부분 인쇄·자재·문구 비용을 내고 도움을 주면 카드, 정리하면 일당이라는 구조다. 두 후속도 비용을 내는 준비 작업을 반복해 이전 선택이 겪을 문제를 충분히 바꾸지 못한다. | 공연 노르마·개인 표현·합주 역할에서 실제로 다른 다음 경험과 부담을 만들고, 단순 후원 메뉴를 줄인다. |
| 고토 히토리의 차지·치명 피해, 키타의 치명 확률, 료의 피해·치명 카드. | 문장을 끝까지 말하기나 연락 명단 확인을 전투 차지·치명으로 잇는 설명이 약하다. 비전투 작품을 각색하는 것 자체가 오류는 아니지만 이름을 바꾼 일반 능력치처럼 남았다. | 카드 효과가 연결되는 실제 행동을 먼저 정하고, 필요하면 탐색·수급 역할에 한정한다. |
| 모든 결과 뒤에 남는 히토리의 긴장이나 키타와의 거리감. | 서로 다른 행동 결과가 비슷한 성격 설명으로 끝난다. 사진 준비 뒤 키타의 에너지가 낯설다는 문장은 무엇을 확인했는지 보여주지 않는다. | 인물의 성격을 갑자기 바꾸지 않되, 각 행동으로 바뀐 물건·관계·다음 문제가 보이게 쓴다. |

Gemma는 issues 빈 배열과 수정 불필요 의견을 반환했다. 원작 근거와 선택의 차이를 독립적으로 입증한 결과가 아니므로 위 Codex의 설계 판단을 대신하지 않았다. 빈 지적을 자동 채택 조건으로 사용하지 않는다.

## 나즈린 1차 문장 중 제외한 부분

[1차 원문](../../copy_archive/gemma_rebuild_2026-10-01/drafts/nazrin-text-01.json)과 [전후·이유](../../copy_archive/gemma_rebuild_2026-10-01/revisions/nazrin-curation-02.json)를 보존했다. 이 묶음의 카드·사건 손익은 유지하고 아래 문장만 다시 썼다.

- 상자를 찾아 달라는 의뢰인데 상인이 상자를 두고 갔다고 적었다. 비탈에 상자를 빠뜨리고 의뢰 쪽지를 남긴 상황으로 바꿨다.
- 모든 결과에 선택 문장을 그대로 복사했다. 측정·발견·지급된 보수와 계속 남은 적의 부담을 결과 장면으로 새로 썼다.
- 실패 설명의 ‘성공 카드와 보수는 없다’, ‘능력이 가짜였다고 단정하지 않는다’는 제작 지시 복사였다. 고철·돌아오지 않는 작업비·남은 강한 적으로 보여준다.
- 성공 후속의 이야기에 가능한 선택 목록을 복사했다. 의뢰 상자를 찾은 뒤 남은 미확인 반응과 퇴로 확인으로 고쳤다.

[Gemma 역검토](../../copy_archive/gemma_rebuild_2026-10-01/reviews/nazrin-review-02.json)는 지적 없음 의견이었다. 실제 비용·실패 부담·개인 후속 조건은 코드 모의 검사로 따로 확인한다.

## 참고 시트의 이름과 다른 설정

불가사의한 던전의 반환 범위 카드!A41:L95 중 59행 ‘사쿠라 쿄코’ 설명에 파마의 영력·사혼충·비운의 무녀가 들어 있었다. 이름과 설명을 원작 설정으로 함께 받아들이지 않았으며 해당 효과를 쿄코 사건의 근거로 복사하지 않았다. 별도 원작 확인 없이 다른 인물로도 자동 재배정하지 않는다.
`);
append('참고 시트와 설정 확인 범위.md',`
## 추가 범위와 공통 사건 후보

- 불가사의한 던전의 요청 ‘카드 ’ A41:L95는 connector에서 '카드'!A41:L95로 반환됐다. 문서에는 끝 공백이 있는 535행 탭과 공백 없는 숨김 350행 탭이 함께 있고, 두 이름의 A1:C3 요청 결과가 같았다. 이번 셀 자료를 535행 표시 탭의 확정된 최신 값이라고 단정하지 않는다. [41~95행](../../copy_archive/gemma_rebuild_2026-10-01/requests/additional-sheet-cells-01.json)과 [96~160행](../../copy_archive/gemma_rebuild_2026-10-01/requests/additional-sheet-cells-03.json)의 정확한 반환 범위를 보존했다.
- 환몽의 문 3) 대죄주교 A1:F47와 5) 소녀가극 A1:F28을 읽고 [전자의 셀 자료](../../copy_archive/gemma_rebuild_2026-10-01/requests/additional-sheet-cells-02.json), [후자의 셀 자료](../../copy_archive/gemma_rebuild_2026-10-01/requests/additional-sheet-cells-04.json)를 남겼다. 이름만으로 모든 원작·인물을 확정하지 않았으며 무제한 스탯 성장·팀 회귀·체력 지불을 옮기지 않았다.
- 봇치 더 록은 [공식 인물 소개](https://bocchi.rocks/tv/character/)와 [2화](https://bocchi.rocks/tv/story/?id=02)·[4화](https://bocchi.rocks/tv/story/?id=04)의 공연 노르마·아르바이트·가사 고민을 참고했다. 첫 묶음은 선택 차이와 효과 연결이 약해 미채택이다. 음악 전투나 SNS 시스템을 구현한 것으로 설명하지 않는다.
- 나즈린은 반환 범위 카드!A96:F160의 133·134행에서 작품 후보를 찾았다. [성련선 설정문 전재](https://en.touhouwiki.net/index.php?mobileaction=toggle_view_desktop&title=Nazrin)와 [구문구수 전재](https://touhou.fandom.com/wiki/Symposium_of_Post-mysticism%3A_Nazrin)의 검색으로 읽힌 본문에서 물건 탐색·들쥐·먹이 제한·불리한 전투를 피하는 특징을 확인했다. 개발사 페이지와 해당 전재의 직접 열기는 실패했으므로 개발사 사이트를 직접 읽었다고 하지 않는다. 상인·운반 상자·비용·보수와 성공/실패 후속은 맵의 창작이다.
`);
const doc = path.join(root,'md/roguelite/사건 카드 재제작 검토 기록.md');
let text = fs.readFileSync(doc,'utf8');
text = text.replace('현재 후보는 머리 10종, 성장 카드 93종, 사건 75개다. 후속 사건 29개', '현재 후보는 머리 10종, 성장 카드 95종, 사건 78개다. 후속 사건 31개');
fs.writeFileSync(doc,text);
append('사건 카드 재제작 검토 기록.md',`
## 공통 탐색의 성공과 실패

봇치의 5카드·3사건 원안을 검토했지만 선택 차이와 원작 연결이 약해 이번에는 제외했다. Gemma의 지적 없음은 채택 근거로 삼지 않았다. 나즈린의 두 카드·세 사건은 탐색 후보/수급과 이동 조건으로 나누며 새 머리 카드 없이 공통 풀에 추가했다. 총 머리 10종·카드 95종·사건 78개·개인 후속 31개다.

첫 탐색은 확정 카드에 170골드, 적 수 +2를 감수한 이동 카드, 150골드와 적 단계 +1을 지불하는 성공률 60% 수색, 일당 180골드 중 고른다. 확률 수색은 성공 시 지정 탐색 카드와 420골드, 실패 시 보상 없이 비용과 적 단계 상승을 유지한다. 성공 후속과 실패 후속은 자기 기록에 맞는 하나만 열리며 추가 행동력을 사용한다. 실패 후 정리 일당 140골드를 받는 선택은 최초 비용을 자동 환불하는 기능이 아니다.

Gemma의 1차 결과 문장 복사와 의뢰 상황 모순을 수정했고 원문·변경 이유·역검토를 보존했다. 지금 설명한 수치는 제작 후보이며 플레이로 재미·밸런스를 확인한 결과가 아니다.
`);
console.log('나즈린 공통 후보와 제외 이유·출처 한계를 반영했습니다.');
