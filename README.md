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
5. 대형 UI 파일 분리
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
content/    맵 환경과 콘텐츠 설정
Data/       유닛, 아이템, 버프, 아르카나, 맵 데이터
Hero/       영웅 공통 시스템과 영웅별 스킬
import/     외부 API와 라이브러리
Library/    재사용 가능한 유틸리티
Memory/     메모리 관련 API 유틸리티
System/     피해, 쿨다운, 저장/로드, 스탯 등 게임 시스템
UI/         DzFrame 기반 UI
vJDK/       vJDK 프레임워크와 플러그인
```

## 주요 파일

- `Import.j`: 전체 스크립트 import 진입점
- `Data/Data Unit.j`: 유닛과 영웅 스킬 데이터
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

