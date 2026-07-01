---
name: ui-frame-guidelines
description: Use when modifying or creating Warcraft III JASS frame UI in this project, especially Dz-based UI work in UI/*.j involving frame creation, coordinates and anchors, backdrop textures, button events, tooltips, status bars, sliders, panel state, validation steps, or character selection UI safeguards.
---

# UI Frame Guidelines

프레임 관련 UI 수정/제작 작업 전 반드시 먼저 읽고 따라야 하는 지침

## UI 수정 및 제작 지침

이 문서는 현재 프로젝트에서 Warcraft III JASS UI를 수정하거나 새로 제작할 때 따르는 기준이다. 최종 작업 기준은 `DzCreateFrameByTagName`, `DzFrameSetPoint`, `DzFrameSetAbsolutePoint`, `DzFrameSetTexture`, `DzFrameShow`, `DzTriggerRegisterUIEvent` 등 현재 코드에서 사용 중인 Dz 함수 흐름이다.

## 기본 원칙

- 기존 `UI/*.j`의 Dz 함수 사용 방식과 파일 구조를 우선한다.
- UI 변경은 화면 하나, 기능 하나, 상태 하나 단위로 작게 진행한다.
- 코드 수정 전에는 사용처, 생성 흐름, 이벤트 흐름, 표시/숨김 조건, 전역 프레임 공유 여부를 먼저 확인한다.
- 표시용 frame과 이벤트용 frame을 구분한다.
- 좌표, 크기, 텍스처, 표시 상태, 이벤트 등록은 한 세트로 검토한다.
- 캐릭터 선택 창처럼 영향 범위가 큰 UI는 구조를 한 번에 바꾸지 않는다.
- 많은 파일을 수정해야 하거나 구조 변경이 필요하면 먼저 확인을 받고 진행한다.
- 문서만 요청받은 경우 코드 파일을 수정하지 않는다.

## Dz 함수 사용 기준

| 목적 | 기본 함수 |
| --- | --- |
| 프레임 생성 | `DzCreateFrameByTagName` |
| 화면 기준 위치 지정 | `DzFrameSetAbsolutePoint` |
| 부모 기준 위치 지정 | `DzFrameSetPoint` |
| 크기 지정 | `DzFrameSetSize` |
| 텍스처 지정 | `DzFrameSetTexture` |
| 텍스트 지정 | `DzFrameSetText` |
| 표시/숨김 | `DzFrameShow` |
| 상태바 범위 지정 | `DzFrameSetMinMaxValue` |
| 상태바 값 지정 | `DzFrameSetValue` |
| UI 이벤트 등록 | `DzTriggerRegisterUIEvent` |
| 키 이벤트 등록 | `DzTriggerRegisterKeyEventByCode` |

## Frame 생성 규칙

### 핵심

UI는 parent frame 아래에 child frame을 붙이는 계층 구조로 작성한다. root panel, background, button/control, text, overlay의 역할을 나누고, 각 frame의 parent를 명확히 둔다.

### Dz로 작성할 때의 규칙

- 기본 생성 함수는 `DzCreateFrameByTagName`이다.
- 전체 화면에 붙는 UI는 `DzGetGameUI()`를 parent로 둔다.
- 패널 내부 요소는 해당 패널 frame을 parent로 둔다.
- 배경, 패널, 아이콘 이미지는 `BACKDROP`으로 만든다.
- 텍스트는 `TEXT`로 만들고 위치, 폰트, 정렬, 내용을 생성 직후 함께 설정한다.
- 클릭 가능한 영역은 `GLUETEXTBUTTON` 또는 기존 파일에서 쓰는 클릭용 frame 패턴을 따른다.
- 상태바는 `SIMPLESTATUSBAR`를 사용한다.
- `FrameCount()`를 사용하는 파일에서는 기존 패턴을 유지한다.

### 사용 절차

1. UI의 root parent를 정한다.
2. root 또는 panel `BACKDROP`을 만든다.
3. 클릭이 필요한 영역에는 클릭용 frame을 만든다.
4. 버튼에 이미지가 필요하면 표시용 `BACKDROP`을 같은 parent 아래에 만든다.
5. 텍스트가 필요하면 `TEXT` frame을 만든다.
6. 각 frame의 size와 point를 설정한다.
7. 기본 표시 상태를 `DzFrameShow`로 명확히 정한다.
8. 이벤트 등록은 frame 생성이 끝난 뒤 한 곳에서 처리한다.

### 금지/주의사항

- parent를 정하지 않은 채 frame을 만들지 않는다.
- 표시용 `BACKDROP`만 만들고 클릭용 frame의 좌표와 크기를 맞추지 않는 작업을 금지한다.
- 같은 역할의 frame을 여러 parent에 흩어서 만들지 않는다.
- 초기 표시 상태를 생략하지 않는다.
- 캐릭터 선택 창에는 검증되지 않은 새 생성 패턴을 바로 적용하지 않는다.

## 좌표와 Anchor 계산

### 핵심

좌표는 화면 기준 좌표와 부모 기준 좌표를 구분해서 계산한다. 같은 x/y 값이라도 parent가 다르면 실제 위치가 달라진다.

### Dz로 작성할 때의 규칙

- 고정 HUD처럼 화면 전체 기준으로 배치할 때는 `DzFrameSetAbsolutePoint`를 사용한다.
- 패널 내부 요소는 `DzFrameSetPoint`로 parent 기준 배치를 한다.
- 한 패널 안에서는 가능한 한 같은 parent와 같은 기준점 체계를 유지한다.
- 반복 슬롯은 기준 좌표와 간격으로 계산한다.
- 클릭용 frame과 표시용 frame이 분리된 경우 같은 기준점, 같은 크기, 같은 parent를 사용한다.

### 사용 절차

1. frame이 화면 고정인지, parent 내부 배치인지 결정한다.
2. root panel의 위치와 크기를 먼저 정한다.
3. child frame은 root panel의 `TOPLEFT`, `BOTTOMLEFT`, `CENTER` 등 한 기준점을 정해 상대 배치한다.
4. 반복 요소는 `baseX + index * gapX`, `baseY - row * gapY`처럼 계산한다.
5. 표시 frame과 이벤트 frame의 size/point가 일치하는지 확인한다.
6. 숨김은 우선 `DzFrameShow(frame, false)`로 처리한다. 화면 밖 좌표 이동은 기존 코드가 그렇게 관리하는 경우에만 따른다.

### 금지/주의사항

- absolute 좌표와 parent 기준 좌표를 같은 묶음 안에서 임의로 섞지 않는다.
- parent를 확인하지 않고 좌표만 복사하지 않는다.
- 4:3 UI 좌표계 범위를 벗어난 값은 의도적 숨김인지 실수인지 확인한다.
- 좌표만 맞고 클릭이 안 되는 경우 표시 frame이 아니라 클릭 frame의 parent, size, point를 먼저 확인한다.

## Backdrop과 Texture

### 핵심

`BACKDROP`은 이미지, 아이콘, 패널 배경을 표시하는 frame이다. 이벤트를 받는 클릭 영역과는 별도일 수 있다.

### Dz로 작성할 때의 규칙

- 이미지와 패널 배경은 `DzCreateFrameByTagName("BACKDROP", ...)`로 만든다.
- 텍스처는 `DzFrameSetTexture(frame, "파일명", 0)`로 지정한다.
- 크기는 `DzFrameSetSize`로 고정한다.
- 위치는 `DzFrameSetPoint` 또는 `DzFrameSetAbsolutePoint`로 명확히 지정한다.
- hover, selected, disabled 상태가 있으면 상태별 텍스처 이름과 전환 함수를 먼저 정한다.

### 사용 절차

1. 표시할 요소가 패널 배경인지, 아이콘인지, 버튼 이미지인지 구분한다.
2. `BACKDROP`을 생성한다.
3. size를 지정한다.
4. point를 지정한다.
5. texture를 지정한다.
6. 상태 변화가 있다면 상태 변경 함수에서 texture를 교체한다.

### 금지/주의사항

- `BACKDROP`에 클릭 이벤트가 걸린다고 가정하지 않는다.
- texture만 지정하고 size/point를 누락하지 않는다.
- 같은 상태 전환을 여러 파일에서 직접 처리하지 않는다.
- hover/selected/disabled 상태를 추가할 때 기존 상태와 우선순위를 정하지 않고 텍스처를 바꾸지 않는다.

## Button과 Event

### 핵심

버튼은 클릭 가능한 영역이고, 실제로 보이는 이미지나 텍스트는 별도 frame일 수 있다. 이벤트는 클릭, hover 진입, hover 이탈, 키 입력처럼 역할별로 나눠 등록한다.

### Dz로 작성할 때의 규칙

- UI 이벤트는 `DzTriggerRegisterUIEvent`를 사용한다.
- 키 입력은 기존 코드처럼 `DzTriggerRegisterKeyEventByCode`를 사용한다.
- 클릭용 frame과 표시용 frame을 분리한 경우 좌표, 크기, 표시 상태를 함께 관리한다.
- 이벤트 콜백에서는 먼저 player id를 구한다.
- player별 on/off 상태는 배열로 관리한다.
- hover 이벤트는 tooltip 표시 또는 texture 변경처럼 하나의 책임만 갖게 한다.

### 사용 절차

1. 버튼이 텍스트 버튼인지 아이콘 버튼인지 결정한다.
2. 텍스트 버튼이면 `GLUETEXTBUTTON`과 `DzFrameSetText`를 사용한다.
3. 아이콘 버튼이면 클릭용 frame과 표시용 `BACKDROP` 조합을 우선한다.
4. click, mouse enter, mouse leave 이벤트를 필요한 만큼만 등록한다.
5. 콜백에서 `pid`를 구한다.
6. 콜백에서 상태 배열, frame 표시, texture 변경을 의도한 순서대로 처리한다.
7. 버튼이 다른 패널을 열거나 닫는다면 관련 on/off 배열도 함께 갱신한다.

### 금지/주의사항

- 같은 frame에 같은 이벤트를 중복 등록하지 않는다.
- 표시용 frame과 클릭용 frame의 위치가 다르게 남지 않게 한다.
- 이벤트 콜백 안에서 여러 UI를 임의 순서로 열고 닫지 않는다.
- 버튼 클릭 후 상태 배열 갱신을 누락하지 않는다.
- 이벤트 player 기준이 `DzGetTriggerUIEventPlayer()`인지 `GetTriggerPlayer()`인지 섞이지 않게 한다.

## Tooltip

### 핵심

현재 프로젝트의 tooltip은 전역 `UI_Tip` frame을 표시/숨김하고 `UI_Tip_Text` 내용을 갱신하는 수동 방식이 기본이다.

### Dz로 작성할 때의 규칙

- hover enter에서 tooltip 제목과 본문을 모두 갱신한다.
- hover enter에서 `DzFrameShow(UI_Tip, true)`를 호출한다.
- hover leave에서 `DzFrameShow(UI_Tip, false)`를 호출한다.
- tooltip 대상은 실제 hover 이벤트가 등록된 frame이어야 한다.
- tooltip 위치와 크기는 내용 길이에 맞게 확인한다.

### 사용 절차

1. tooltip을 띄울 이벤트 frame을 확인한다.
2. mouse enter 콜백을 만든다.
3. 콜백에서 `DzFrameSetText(UI_Tip_Text[...], ...)`로 제목과 본문을 갱신한다.
4. 같은 콜백에서 `DzFrameShow(UI_Tip, true)`를 호출한다.
5. mouse leave 콜백에서 `DzFrameShow(UI_Tip, false)`를 호출한다.
6. tooltip 내용이 긴 경우 패널 밖으로 나가지 않는지 확인한다.

### 금지/주의사항

- tooltip 숨김 처리를 누락하지 않는다.
- 제목 또는 본문 중 하나만 갱신해 이전 내용이 남게 하지 않는다.
- 표시용 `BACKDROP`에 hover 이벤트가 등록되어 있다고 가정하지 않는다.
- tooltip을 여러 곳에서 동시에 표시하는 구조를 만들지 않는다.

## Status Bar

### 핵심

상태바는 min/max/value 값에 따라 텍스처가 채워지는 UI다. HP, 실드, 캐스팅, 보스 HP처럼 값 기반으로 갱신되는 요소에 사용한다.

### Dz로 작성할 때의 규칙

- 상태바는 `DzCreateFrameByTagName("SIMPLESTATUSBAR", ...)`로 만든다.
- 생성 직후 `DzFrameSetMinMaxValue`, `DzFrameSetValue`, `DzFrameSetTexture`를 함께 설정한다.
- 표시/숨김 함수와 값 갱신 함수는 분리한다.
- 값 갱신은 가능하면 한 함수로 모은다.
- background bar, value bar, text가 분리된 경우 세 frame을 함께 검증한다.

### 사용 절차

1. 상태바가 표현할 값과 범위를 정한다.
2. background bar가 필요한지 결정한다.
3. value bar frame을 생성한다.
4. size와 point를 지정한다.
5. texture를 지정한다.
6. min/max/value 초기값을 설정한다.
7. 값 갱신 함수에서 현재 값과 최대 값을 읽어 반영한다.
8. 표시/숨김 함수에서는 위치와 표시 상태만 처리한다.

### 금지/주의사항

- max 값이 바뀌는 UI에서 value만 갱신하지 않는다.
- 전역 상태바를 여러 파일에서 직접 조작하는 새 호출을 추가하지 않는다.
- 표시 상태와 값 갱신을 한 함수에 무리하게 섞지 않는다.
- 숨긴 상태바의 값 갱신이 필요한지 결정하지 않고 방치하지 않는다.

## Slider

### 핵심

현재 프로젝트에서 slider는 일반적인 UI 패턴이 아니다. 숫자 조절 UI가 꼭 필요할 때만 별도 설계 대상으로 판단한다.

### Dz로 작성할 때의 규칙

- 기본 UI 선택 방식으로 slider를 쓰지 않는다.
- 버튼, 페이지, 선택 슬롯으로 대체 가능한지 먼저 본다.
- slider가 꼭 필요하면 값 범위, step, label, reset, player별 상태를 먼저 설계한다.
- 프로젝트 안에 기존 slider 패턴이 없으면 작은 테스트 범위로 검증한 뒤 본 작업에 적용한다.

### 사용 절차

1. slider가 꼭 필요한 이유를 정리한다.
2. 값의 min/max/step을 정한다.
3. 값 표시용 `TEXT` frame이 필요한지 정한다.
4. 값 변경 이벤트와 적용 타이밍을 정한다.
5. player별 local UI 값인지, 게임 상태와 동기화되어야 하는 값인지 결정한다.
6. reset 또는 cancel 동작을 정한다.
7. 검증 범위를 별도로 잡는다.

### 금지/주의사항

- 단순 선택 UI에 slider를 도입하지 않는다.
- player별 값인지 공용 값인지 정하지 않고 구현하지 않는다.
- 캐릭터 선택 창 같은 실패 비용이 큰 UI에 slider 실험을 넣지 않는다.
- 기존 Dz UI 패턴과 맞지 않는 복잡한 조절 UI를 한 번에 추가하지 않는다.

## 패널과 On/Off 상태

### 핵심

열고 닫는 UI는 실제 frame 표시 상태와 player별 상태 배열이 일치해야 한다.

### Dz로 작성할 때의 규칙

- 표시 상태는 `DzFrameShow`로 처리한다.
- on/off 상태는 `F_*OnOff[pid]` 같은 기존 배열 패턴을 따른다.
- 한 패널을 열 때 같이 닫혀야 하는 패널을 확인한다.
- 닫기 버튼, 외부 NPC 상호작용, 단축키가 같은 상태를 공유하는지 확인한다.

### 사용 절차

1. UI의 열림 상태 배열을 확인한다.
2. show 함수와 hide 함수를 분리하거나, toggle 함수 안에서 두 경로를 명확히 나눈다.
3. 열 때 필요한 다른 UI 닫기 동작을 확인한다.
4. 닫을 때 tooltip, 선택 상태, 임시 frame 표시를 정리한다.
5. 실제 `DzFrameShow` 상태와 on/off 배열 값이 일치하는지 확인한다.

### 금지/주의사항

- frame만 숨기고 on/off 배열을 갱신하지 않는 작업을 금지한다.
- on/off 배열만 바꾸고 실제 frame 표시를 바꾸지 않는 작업을 금지한다.
- 여러 패널이 같은 전역 frame을 공유하는지 확인하지 않고 닫기 처리를 추가하지 않는다.

## 검증 절차

### 수정 전

1. 수정 대상 frame이 생성되는 파일과 함수 위치를 찾는다.
2. 해당 frame 이름과 관련 전역 배열을 검색한다.
3. 해당 frame을 show/hide하는 함수를 찾는다.
4. 해당 frame에 등록된 click/hover/key 이벤트를 찾는다.
5. 같은 화면에서 겹치는 frame과 공유 tooltip/status bar를 확인한다.
6. 캐릭터 선택 창과 연결되는 작업이면 선택 완료 후 호출 흐름까지 확인한다.

### 수정 후

1. frame이 생성되는지 확인한다.
2. 기본 표시 상태가 의도와 같은지 확인한다.
3. 좌표와 크기가 의도와 같은지 확인한다.
4. 클릭 영역과 보이는 이미지가 일치하는지 확인한다.
5. hover enter/leave가 정상 동작하는지 확인한다.
6. tooltip이 남지 않는지 확인한다.
7. 상태바 min/max/value가 정상 갱신되는지 확인한다.
8. on/off 배열과 실제 표시 상태가 일치하는지 확인한다.
9. 인접 UI가 밀리거나 가려지지 않았는지 확인한다.
10. 검증하지 못한 항목은 완료로 처리하지 말고 남긴다.

## 캐릭터 선택 창 실패 재발 방지 원칙

- 캐릭터 선택 창은 안정성 최우선 UI로 취급한다.
- 한 번에 구조, 텍스처, 좌표, 이벤트, 데이터 흐름을 동시에 바꾸지 않는다.
- 별도 요청이 없으면 `UI_Pick` 계열을 수정하지 않는다.
- 카드, 페이지, 선택 버튼, 잠금 상태, 미리보기 패널을 각각 독립적으로 검증한다.
- 선택 완료 이벤트가 호출하는 HP 표시, 스킬 레벨 설정, 맵 라인 설정, 아이템 지급 흐름을 함께 확인한다.
- 시각적 개선이 목적이어도 선택 가능 여부, 잠금 여부, 실제 선택 결과가 바뀌면 안 된다.
- 작은 변경 후에도 선택 전, hover, 선택, 잠금 카드, 페이지 이동, 선택 완료 흐름을 확인한다.
- 재현 가능한 실패가 하나라도 있으면 추가 확장을 중단하고 원인부터 정리한다.

## 작업 기록 원칙

- UI 조사 결과와 변경 이유는 짧게 남긴다.
- 추측으로 구현하지 않는다.
- 기존 Dz 기반 코드의 대응 관계를 먼저 확인한다.
- 많은 파일을 수정해야 하거나 구조 변경이 필요하면 먼저 확인을 받고 진행한다.
- 문서만 요청받은 경우 코드 파일을 수정하지 않는다.

