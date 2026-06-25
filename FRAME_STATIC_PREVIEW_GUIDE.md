# Frame Static Preview Guide

담당 에이전트: 작업도우미1

이 문서는 Warcraft III/JASS UI 스크립트에서 프레임 생성 흐름을 읽어 정적 PNG 샘플을 만드는 절차를 정리한다. 자동 관리되는 `AGENTS.md`는 수정하지 않는다.

## 목적

`DzCreateFrameByTagName`, `DzFrameSetTexture`, `DzFrameSetSize`, `DzFrameSetPoint`, `DzFrameSetAbsolutePoint`, `DzFrameSetText`, `DzFrameShow` 호출을 기준으로 UI 프레임의 예상 배치와 텍스처 적용 상태를 PNG로 미리 확인한다.

정적 샘플은 게임 클라이언트의 실제 렌더러를 대체하지 않는다. 목적은 다음 범위다.

- 루트 프레임과 자식 프레임의 상대 위치 확인
- 필요한 텍스처가 누락됐는지 확인
- 어두운 텍스처, 투명도, 숨김 상태 때문에 보이지 않는 요소를 진단
- 사용자에게 원본 느낌 샘플과 진단용 샘플을 Multica 첨부로 공유

## 파싱 대상

우선 대상 스크립트 하나를 명확히 정한다.

- 예: `UI/UI_Elixir.j`
- 예: `UI/UI_Arcana.j`

검색은 다음 호출을 중심으로 좁힌다.

```powershell
rg -n "Dz(CreateFrame|FrameSetTexture|FrameSetPoint|FrameSetSize|FrameShow|FrameSetAlpha|FrameSetAbsolutePoint|FrameSetText|FrameSetFont|FrameSetTextColor|FrameSetPriority|FrameSetAllPoints|FrameSetScale)" .\UI\UI_Elixir.j
rg -n "\.blp|\.tga|\.dds|\.png" .\UI\UI_Elixir.j
```

큰 파일은 전체를 읽기보다 루트 프레임을 만드는 함수와 주변 블록을 줄 번호로 잘라 읽는다.

## 루트 프레임 찾기

루트 프레임은 보통 `DzGetGameUI()`를 부모로 가지는 큰 `BACKDROP`이다.

확인할 항목:

- 변수명: 예 `El_BackDrop`, `El_BackDrop2`, `F_ArcanaBackDrop`
- 생성: `DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), ...)`
- 텍스처: `DzFrameSetTexture(root, "...", 0)`
- 위치: `DzFrameSetAbsolutePoint(root, JN_FRAMEPOINT_CENTER, x, y)`
- 크기: `DzFrameSetSize(root, w, h)`
- 표시 상태: `DzFrameShow(root, true/false)`와 나중에 다시 표시되는 이벤트 흐름

`DzFrameShow(root, false)`로 초기 숨김 처리되는 경우에도, 미리보기에서는 사용자가 요청한 표시 대상이면 루트를 강제로 보이게 렌더링한다. 단, 문서나 결과 댓글에 "초기 코드는 숨김이며 특정 키/이벤트에서 표시된다"고 명시한다.

## 프레임 호출 처리

### `DzFrameSetTexture`

텍스처 파일명을 추출하고 `MPQEditor\Work`에서 같은 파일명을 찾는다.

```powershell
$base = "C:\Users\ctqho\OneDrive\Desktop\JN\External Tools\MPQEditor\Work"
Get-ChildItem -Path $base -Recurse -File -Filter "Filenemo.blp"
```

찾은 파일은 PNG로 변환해서 렌더러에 전달한다. 텍스처가 없으면 해당 프레임은 경계선과 파일명 라벨로 대체하고, 누락 파일 목록을 결과 댓글에 남긴다.

### `DzFrameSetSize`

JASS UI 좌표계의 `w`, `h`를 캔버스 픽셀로 변환한다. 이번 작업에서는 4:3 UI 좌표계를 다음처럼 다뤘다.

- x 범위: `0.0`에서 `0.8`
- y 범위: `0.0`에서 `0.6`
- 예시 캔버스: `1280x960`

변환 예:

```text
pixel_x = ui_x / 0.8 * canvas_width
pixel_y = canvas_height - (ui_y / 0.6 * canvas_height)
pixel_w = ui_w / 0.8 * canvas_width
pixel_h = ui_h / 0.6 * canvas_height
```

### `DzFrameSetAbsolutePoint`

루트처럼 절대 좌표를 갖는 프레임에 사용한다. `CENTER` 기준이면 계산된 중심 좌표에서 폭과 높이의 절반을 빼서 사각형을 만든다.

### `DzFrameSetPoint`

부모 프레임 기준의 상대 좌표다. 이번 샘플에서는 `JN_FRAMEPOINT_CENTER`를 부모의 `JN_FRAMEPOINT_BOTTOMLEFT`에 붙이는 형태가 많았다.

처리 방식:

1. 부모 사각형을 먼저 계산한다.
2. 부모의 bottom-left를 원점으로 보고 상대 `x`, `y`를 픽셀로 변환한다.
3. 자식 프레임의 anchor가 `CENTER`면 자식 폭/높이 절반을 빼서 사각형을 만든다.

### `DzFrameSetText`

텍스트 프레임은 위치와 문자열을 함께 렌더링한다.

주의할 점:

- 원본 스크립트가 CP949/EUC-KR 계열로 작성됐거나 이미 깨진 상태면, UTF-8로 단순 읽기 시 한글이 깨질 수 있다.
- 샘플에는 원본 문자열을 그대로 쓰기보다 사용자 확인에 필요한 의미를 짧게 표시해도 된다.
- 한글 표시가 필요하면 Windows에서는 `Malgun Gothic` 같은 한글 지원 폰트를 사용한다.

### `DzFrameShow`

정적 미리보기에서는 표시 상태를 반드시 구분한다.

- `true`: 일반 샘플에 표시
- `false`: 일반 샘플에서는 숨김
- 진단용 샘플에서는 숨김 프레임을 반투명/점선/경계선으로 표시할 수 있다.

`UI/UI_Arcana.j`의 `F_ArcanaBD[0..4]`처럼 생성 직후 숨김 처리되는 프레임은 원본 느낌 샘플에는 숨기고, 진단용 샘플에는 반투명으로 표시해 위치와 텍스처를 확인했다.

## BLP/TGA 변환

### BLP1 JPEG

이번에 확인한 BLP 파일들은 `BLP1` JPEG-compressed 계열이었다.

주요 헤더 값:

- magic: offset `0`, ASCII `BLP1`
- compression: offset `4`, `0`이면 JPEG
- width: offset `12`
- height: offset `16`
- mipmap0 offset: offset `28`
- mipmap0 size: offset `92`
- JPEG header size: offset `156`
- JPEG header start: offset `160`

변환 방식:

1. JPEG header 영역을 읽는다.
2. mipmap0 데이터를 이어 붙인다.
3. 완성된 JPEG 스트림을 이미지로 열어 PNG로 저장한다.

BLP2, DXT, palette 기반 BLP가 나오면 별도 디코더나 외부 변환기가 필요할 수 있다.

### TGA

`UI_PickSelectButton.tga`는 32-bit RLE true-color TGA였다.

처리 방식:

- image type `10`
- bpp `32`
- BGRA 순서로 픽셀 복원
- descriptor의 origin bit를 보고 y 방향을 보정
- alpha 채널을 유지한 PNG로 저장

지원하지 않는 TGA 변형이면 변환 실패 사유와 필요한 디코더를 남긴다.

## UTF-8과 한글 처리

Windows PowerShell 5.1은 파이프와 네이티브 명령 인코딩에서 비 ASCII 문자를 손상시킬 수 있다. Multica 댓글은 항상 UTF-8 파일로 작성한 뒤 `--content-file`을 사용한다.

```powershell
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText((Join-Path (Get-Location) "reply.md"), $body, $utf8NoBom)
multica issue comment add <issue-id> --parent <comment-id> --content-file .\reply.md --attachment .\sample.png
Remove-Item .\reply.md
```

하지 말아야 할 방식:

- `--content`에 긴 본문을 직접 넣기
- `--content-stdin`에 파이프하기
- 문자열에 `\n`을 넣어 줄바꿈을 흉내내기

샘플 이미지 안의 한글은 렌더러가 사용하는 폰트와 스크립트 파일의 원본 문자셋을 따로 확인해야 한다. 한글이 깨질 때는 다음을 구분한다.

- 폰트 미지원: 한글 글리프가 네모나 공백으로 표시
- 렌더러/스크립트 인코딩 문제: 원본 문자열이 `??깃났`처럼 깨진 상태로 표시
- 원본 파일 자체 문제: 파일을 올바른 문자셋으로 열어도 이미 깨진 문자열

## 샘플 종류

### 원본 느낌 샘플

가능한 한 실제 UI의 색감과 표시 상태를 보존한다.

- 어두운 배경 유지
- 원래 숨김 처리된 프레임은 숨김
- 텍스처 밝기 보정 최소화
- 텍스트는 실제 위치에 배치

### 진단용 샘플

원본 느낌 샘플에서 요소가 잘 안 보일 때 만든다.

- 밝은 체크 배경
- 프레임 경계선 표시
- 프레임 변수명 또는 텍스처명 라벨 표시
- 어두운 텍스처 밝기 보정
- 숨김 프레임은 반투명으로 표시
- 알파/밝기/크기 같은 통계 정보를 하단에 표시

진단용 샘플은 실제 게임 색감을 보장하지 않는다. 위치, 크기, 텍스처 매핑을 검증하기 위한 산출물이다.

## 어두운 텍스처 가시성 보정

`UI_Elixir.j` 작업에서 `elixir_preview_textures_applied.png`가 검은 화면처럼 보이는 문제가 있었다. 확인 결과 첨부 PNG 자체는 정상이고 캔버스도 투명하지 않았지만, 텍스처가 어두운 배경에 묻혀 보이지 않았다.

진단용 샘플에서 사용한 보정:

- 배경을 밝은 체크 패턴으로 교체
- cyan 경계선으로 실제 프레임 영역 표시
- 텍스처 RGB에 1.3에서 1.9 정도의 brightness boost 적용
- 숨김/저대비 프레임은 반투명으로 표시

보정값은 디버깅용이다. 원본 느낌 샘플에는 같은 보정을 적용하지 않는다.

## Multica 첨부 방식

결과는 댓글 본문과 이미지 첨부로 남긴다.

```powershell
multica issue comment add <issue-id> `
  --parent <trigger-comment-id> `
  --content-file .\reply.md `
  --attachment .\original_preview.png `
  --attachment .\diagnostic_preview.png
```

첨부 후에는 임시 파일을 제거한다.

```powershell
Remove-Item .\reply.md
Remove-Item .\.agent_context\<task-temp-dir> -Recurse
```

댓글에는 다음을 짧게 포함한다.

- 분석한 스크립트
- 표시 대상으로 본 루트 프레임
- 찾고 변환한 텍스처 목록
- 원본 느낌/진단용 샘플 차이
- 숨김 프레임을 어떻게 처리했는지
- 변환 실패나 누락 텍스처가 있으면 그 사유

## 확인 사례

### `UI/UI_Elixir.j`

확인한 루트:

- `El_BackDrop`
- `El_BackDrop2`

확인한 주요 텍스처:

- `Filenemo.blp`
- `File00005254.blp`
- `UI_Arcana_Work1.blp`
- `UI_PickSelect2.blp`
- `File00004591.blp`
- `UI_PickSelectButton.tga`

특이사항:

- BLP 5개는 `BLP1` JPEG-compressed 계열로 변환 가능했다.
- `UI_PickSelectButton.tga`는 32-bit RLE TGA로 직접 디코딩했다.
- 첫 합성 샘플은 텍스처가 어두운 배경에 묻혀 보였고, 진단용 샘플에서 밝은 배경, 경계선, 밝기 보정으로 가시성을 확보했다.
- `DzFrameShow(El_BackDrop, true)` 결과를 기준으로 정적 샘플을 만들었다.

### `UI/UI_Arcana.j`

확인한 루트:

- `F_ArcanaBackDrop`

표시 흐름:

- `Main`에서 `F_ArcanaBackDrop` 생성
- `File00005255.blp` 적용
- 초기에는 `DzFrameShow(F_ArcanaBackDrop, false)`
- O 키 처리에서 다시 `DzFrameShow(F_ArcanaBackDrop, true)`

확인한 주요 텍스처:

- `File00005255.blp`
- `UI_Inventory.blp`
- `UI_Arcana_Work3.blp`
- `Arcana001.blp`

특이사항:

- `F_ArcanaBD[0..4]` 카드 프레임은 생성 후 `DzFrameShow(..., false)`로 숨겨진다.
- 원본 느낌 샘플에서는 카드 이미지를 숨겼다.
- 진단용 샘플에서는 `Arcana001.blp` 카드 위치와 텍스처를 확인할 수 있도록 반투명으로 표시했다.

## 한계

정적 미리보기는 다음을 완전하게 재현하지 못한다.

- 게임 클라이언트의 실제 frame priority와 template 스타일
- `SPRITE` 효과
- 마우스 이벤트에 따른 실시간 텍스트 변경
- 플레이어별 local state
- TOC 템플릿의 내부 렌더링
- BLP2/DXT/palette 등 아직 구현하지 않은 텍스처 형식

따라서 결과를 "게임 화면의 최종 렌더"가 아니라 "스크립트 기반 예상 배치와 텍스처 적용 확인용 이미지"로 다룬다.

