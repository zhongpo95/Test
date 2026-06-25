# Warcraft III vJass RPG Map

Warcraft III 유즈맵 RPG 제작 프로젝트입니다.
이 저장소는 vJass 스크립트를 중심으로 영웅 스킬, 보스 전투, UI, 아이템, 저장/로드, 전투 시스템을 구성합니다.

## 현재 목표

처음 제작한 맵이라 파일과 폴더 구조가 아직 정리되지 않은 부분이 많습니다.
기존 코딩 방식은 최대한 유지하면서, 앞으로의 제작 방식을 통일하고 문서화하는 것을 목표로 합니다.

우선순위는 다음과 같습니다.

1. 제작 규칙 문서 정리
2. import 경로와 포함 순서 정리
3. 실제 사용 파일과 복사본 파일 구분
4. 영웅 스킬 작성 방식 통일
5. 대형 UI 파일 현 상태 유지
6. 데이터 테이블 정리

## 기술 스택

- Warcraft III
- vJass
- vJDK
- JN API
- DzAPI
- CommonAPI/JAPI 계열 외부 라이브러리

## 폴더 구조

```text
Boss/       보스 AI, 패턴, 어그로
content/    맵 환경과 콘텐츠 설정, NPC 상호작용
copy_archive/ 정리 전 확인용 복사본 파일 보관
Data/       유닛, 아이템, 버프, 아르카나, 맵 데이터
Hero/       영웅 공통 시스템과 영웅별 스킬
Library/    재사용 가능한 유틸리티, 메모리 유틸리티, 외부 API/JN/Dz/JAPI 계열 라이브러리
System/     피해, 쿨다운, 저장/로드, 스탯 등 게임 시스템
UI/         DzFrame 기반 UI
vJDK/       vJDK 프레임워크와 플러그인
```

## 주요 파일

- `Import.j`: 전체 스크립트 import 진입점
- `content/NPC.j`: NPC 클릭 상호작용 스크립트
- `ESC.j`: 테스트용 스크립트
- `Data/Data_Unit.j`: 유닛과 영웅 스킬 데이터
- `Hero/SkillButton.j`: 키 입력과 스킬 sync 처리
- `System/DamageEffect.j`: 영웅 피해 계산
- `System/Cooldown.j`: 스킬 쿨다운 처리
- `Library/Tick.j`: 타이머 래퍼
- `.github/copilot-instructions.md`: 제작 규칙과 코드 작성 기준

## 기본 스킬 흐름

1. `Hero/SkillButton.j`에서 키 입력을 받습니다.
2. 마우스 좌표를 `DzSyncData`로 동기화합니다.
3. 영웅 스킬 파일의 sync 함수가 좌표를 받아 유닛 방향을 맞춥니다.
4. `IssuePointOrder`로 실제 스킬 주문을 실행합니다.
5. `EVENT_PLAYER_UNIT_SPELL_EFFECT`에서 스킬 ID를 확인합니다.
6. `tick`, `FxEffect`, `splash.range`, `HeroDeal`, `CooldownFIX`를 사용해 스킬을 처리합니다.

## 제작 규칙

새 코드 작성과 기존 코드 수정은 `.github/copilot-instructions.md`를 기준으로 합니다.
큰 리팩터링보다 기존 구조를 이해하고 조금씩 정리하는 방식을 우선합니다.

## 정리 진행 현황

- `copy_archive/`에 복사본 파일을 모아 두었습니다. `NPC copy.j`는 빈 파일이라 삭제했습니다.
- 공백이 있던 주요 파일명은 `_` 기준으로 정리했습니다.
  - `Data/Data_Arcana.j`
  - `Data/Data_Buff.j`
  - `Data/Data_Item.j`
  - `Data/Data_Map.j`
  - `Data/Data_Unit.j`
  - `UI/UI_BossHP.j`
  - `UI/UI_V.j`
- `Import.j`는 섹션 주석으로 구간을 나누었습니다. 현재 대부분의 import는 절대 경로이므로, 상대 경로 전환은 별도 검증 후 진행합니다.
- `NPC.j`는 NPC 클릭 상호작용 스크립트라 `content/NPC.j`로 이동했습니다. `ESC.j`는 테스트용이라 루트에 그대로 둡니다. `ex.j`는 맵에 넣지 않는 코드 확인용 파일이라 정리 대상에서 제외합니다.
- 대형 UI 파일은 현재 구조를 유지합니다. 분리 작업은 진행하지 않습니다.
- `import/`의 파일은 `Library/`로 이동했고, 외부 API/JN/Dz/JAPI 계열 파일도 `Library/`에서 관리합니다.
- `Memory/` 폴더는 `Library/Memory/`로 이동했습니다.

## 정리 기준

- UI 대형 파일은 현재 구조를 유지합니다. 기능 단위 분리 작업은 진행하지 않습니다.
- `content/NPC.j`는 NPC 클릭 상호작용 스크립트입니다.
- `ESC.j`는 테스트용 스크립트라 루트에 그대로 둡니다.
- `ex.j`는 맵에 넣지 않고 코드 확인용으로 작성한 파일이므로 폴더 정리 대상에서 제외합니다.
- `Import.j`의 import 146개는 현재 모두 절대 경로입니다. 상대 경로 전환은 빌드 방식에서 안전하다고 확인되기 전까지 진행하지 않습니다.

## copy_archive 확인 기준

`copy_archive/`는 삭제 전 확인용 보관 폴더입니다. 현재 파일은 아래 기준으로만 참고하고, 바로 삭제하지 않습니다.

| 파일 | 현재 판단 | 이유 |
| --- | --- | --- |
| `Boss1-2 copy.j` | 삭제 가능 후보 | 원본 `Boss/Boss1-2.j`가 현재 형식에 더 가깝습니다. |
| `BossAggro copy.j` | 삭제 가능 후보 | 원본 `Boss/BossAggro.j`가 확장된 구조입니다. |
| `MemUI copy.j` | 삭제 가능 후보 | 원본 `UI/MemUI.j`가 더 최신 구조입니다. |
| `Data Item copy.j` | 복구/병합 후보 | `MakeItem`, `GetItemID`, `initializer init` 같은 예전 아이템 변환 로직이 있습니다. |
| `UI_Item copy.j` | 복구/병합 후보 | 창고, 장비, 삭제, 잠금 관련 예전 UI 구현이 더 많이 남아 있습니다. |
| `UI_Quest copy.j` | 복구/병합 후보 | 원본은 stub에 가깝고, copy에는 퀘스트 UI 구현 함수가 남아 있습니다. |
| `AngleDistancePolar copy.j` | 참고 보관 후보 | 원본과 API 구조가 다른 구버전 유틸 참고본입니다. |

## Data 파일 역할

- `Data/Data_Arcana.j`: 아르카나와 아이템 전투력 계산
- `Data/Data_Buff.j`: 버프/디버프 struct 데이터
- `Data/Data_Item.j`: 아이템 데이터 테이블
- `Data/Data_Map.j`: 맵 구역, 테마, rect 반환과 맵 리셋
- `Data/Data_Unit.j`: 유닛 인덱스와 영웅 스킬 데이터 초기화
- `Data/Native.j`: 캐릭터 저장 같은 네이티브/외부 호출 래퍼

## 빌드와 테스트

현재 저장소에서는 바로 실행할 수 있는 빌드 스크립트나 테스트 명령을 찾지 못했습니다. `Library/readme.txt`에는 jasshelper 문서 안내만 있습니다. 실제 맵 컴파일/테스트는 사용하는 에디터 또는 vJDK/jasshelper 실행 방식이 확인된 뒤 진행합니다.
