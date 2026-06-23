# Warcraft III vJass RPG 제작 규칙

이 프로젝트는 Warcraft III 유즈맵 RPG의 vJass 스크립트 프로젝트이다.
기존 코드 스타일과 제작 방식은 최대한 유지하되, 새 코드와 수정 코드는 아래 규칙을 기준으로 작성한다.

## 프로젝트 목표

- 기존 맵의 코딩 방식을 크게 바꾸지 않고 정리한다.
- 영웅 스킬, 보스 패턴, UI, 시스템 스크립트의 작성 방식을 통일한다.
- 새 기능을 추가할 때 어디에 무엇을 작성해야 하는지 명확하게 만든다.
- 큰 리팩터링보다 안정적인 정리와 일관성 확보를 우선한다.

## 폴더 역할

- `Hero/`: 플레이어블 영웅, 공통 스킬 입력, 대시, 포션 로직.
- `Hero/<HeroName>/`: 영웅별 스킬 파일. 예: `Hero/Chen/HeroChenS.j`.
- `Boss/`: 보스 AI, 패턴, 어그로, 보스 전투 흐름.
- `Data/`: 유닛, 아이템, 버프, 아르카나, 맵 데이터 같은 전역 데이터 정의.
- `System/`: 게임 규칙 시스템. 피해, 쿨다운, 스탯, 저장/로드, 아이템 획득 등.
- `UI/`: DzFrame 기반 UI 생성, 표시, 갱신 로직.
- `Library/`: 여러 시스템에서 재사용하는 범용 유틸리티.
- `content/`: 맵 환경, 시간, 콘텐츠 설정.
- `import/`: 외부 API, JN/Dz/JAPI/CommonAPI 계열 의존성.
- `vJDK/`: vJDK 프레임워크와 플러그인.

## 기본 작성 원칙

- 기존 vJass 문법과 매크로 사용 방식을 유지한다.
- 단, `Library/FX.j`, `연출()`, `연출효과_타이머()`는 사용하지 않는다.
- 지연 실행과 반복 실행은 `Library/Tick.j`의 `tick`으로 처리한다.
- 수정 범위는 요청받은 기능과 직접 관련된 파일로 제한한다.
- 작동 중인 시스템을 대규모로 갈아엎지 않는다.
- 새 코드가 기존 전역 배열, 스킬 ID, 쿨다운, 피해 계산 계약을 깨지 않게 한다.
- 인코딩은 UTF-8을 기준으로 관리한다.
- 주석은 필요한 곳에만 짧게 작성한다.

## Import 규칙

- `Import.j`는 전체 스크립트의 포함 순서를 관리하는 진입 파일이다.
- 가능하면 절대 경로 대신 프로젝트 기준 상대 경로를 사용한다.
- 의존성이 있는 파일은 의존 대상보다 뒤에 import한다.
- 새 영웅 스킬 파일을 추가하면 `Data/`, 공통 `Hero/`, 개별 영웅 파일 순서를 고려해 `Import.j`에 등록한다.

권장 순서:

1. 외부 API와 vJDK
2. `Data/`
3. `Library/`
4. `System/`
5. `UI/`
6. `Hero/` 공통 파일
7. `Hero/<HeroName>/` 스킬 파일
8. `Boss/`
9. 기타 콘텐츠와 맵 초기화

## 파일 명명 규칙

- 영웅 스킬: `Hero/<HeroName>/Hero<HeroShortName><Key>.j`
- 예: `Hero/Chen/HeroChenS.j`, `Hero/Narmaya/HeroNarQ.j`
- 시스템: 기능 이름 중심으로 작성한다. 예: `Cooldown.j`, `DamageEffect.j`.
- UI: `UI_<Name>.j` 또는 기존 파일명 규칙을 따른다.
- 임시 파일, 복사본 파일은 실제 빌드 기준으로 사용하지 않는다.

## 영웅 스킬 작성 규칙

영웅 스킬 파일은 기본적으로 `scope` 하나로 구성한다.

권장 구성 순서:

1. `scope Hero<Name><Key>`
2. `globals`
3. private constants
4. 스킬 상태 배열
5. private struct `FxEffect`
6. 피해 또는 범위 판정 함수
7. tick 콜백 함수
8. 주문 발동 함수 `Main`
9. sync 수신 함수
10. 트리거 등록 매크로
11. `endscope`

## struct 생명주기 규칙

`연출()` 매크로는 사용하지 않는다.
struct가 필요하면 `Create`, `Start`, `Stop`을 직접 작성한다.

반복 실행이 필요한 struct는 tick의 `data` 정수 슬롯에 struct id를 저장해서 전달한다.

```vjass
private struct FxEffect
    unit caster
    integer i
    private tick lifeTick
    private boolean stopping

    private static method OnTimer takes nothing returns nothing
        local tick t = tick.getExpired()
        local thistype fx = t.data

        set fx.i = fx.i + 1

        if fx.caster == null then
            call fx.Stop()
            return
        endif

        // 반복 처리
    endmethod

    static method Create takes nothing returns thistype
        local thistype this = allocate()
        set caster = null
        set i = 0
        set lifeTick = 0
        set stopping = false
        return this
    endmethod

    method Start takes nothing returns nothing
        set lifeTick = tick.create(0)
        set lifeTick.data = this
        call lifeTick.start(0.02, true, function thistype.OnTimer)
    endmethod

    method Stop takes nothing returns nothing
        if stopping then
            return
        endif
        set stopping = true

        if lifeTick != 0 then
            call lifeTick.destroy()
            set lifeTick = 0
        endif

        set caster = null
        call deallocate()
    endmethod
endstruct
```

## 스킬 입력 흐름

현재 프로젝트의 기본 스킬 입력 흐름은 유지한다.

1. `Hero/SkillButton.j`에서 키 입력을 감지한다.
2. 마우스 좌표를 문자열로 만들어 `DzSyncData`로 보낸다.
3. 영웅 스킬 파일의 sync 함수가 좌표를 파싱한다.
4. `SetUnitFacing`, `EXSetUnitFacing`으로 방향을 맞춘다.
5. `IssuePointOrder`로 실제 워크래프트 스킬 주문을 발동한다.
6. `EVENT_PLAYER_UNIT_SPELL_EFFECT`에서 스킬 ID를 확인하고 스킬 로직을 실행한다.

## 스킬 데이터 규칙

- 영웅별 스킬 ID, 쿨다운, 피해 배율은 `Data/Data Unit.j`에서 관리한다.
- `DataUnitIndex(unit)` 결과가 영웅 데이터의 기준 인덱스이다.
- Chen은 현재 인덱스 `4`를 사용한다.
- 스킬 파일에서는 가능하면 `HeroSkillID*`, `HeroSkillCD*`, `HeroSkillVelue*` 배열을 참조한다.
- 기존 오탈자 이름인 `Velue`는 전역 계약이므로 함부로 변경하지 않는다.

## 피해 처리 규칙

- 플레이어 영웅의 일반 피해는 기본적으로 `HeroDeal`을 사용한다.
- 범위 판정은 `splash.range`와 `IsUnitInRangeXY` 패턴을 우선 사용한다.
- 직접 체력을 깎는 코드는 특별한 시스템 피해가 아니라면 피한다.
- 헤드, 백어택, 카운터, 차지 여부는 `HeroDeal` 인자로 명확하게 전달한다.

## 쿨다운 규칙

- 일반 스킬 쿨다운은 `CooldownFIX`를 사용한다.
- 즉시 쿨다운 적용이 필요한 경우에만 `CooldownFIX2`를 사용한다.
- 고정 쿨다운은 `CooldownSet`을 사용한다.
- 쿨다운 값은 가능하면 `Data/Data Unit.j`의 `HeroSkillCD*` 배열에서 가져온다.

## 변수와 메모리 정리

- 지역 handle 변수는 사용 후 `null`로 정리한다.
- 변수 대입에는 반드시 `set`을 사용한다.
- 조건문 안의 대입도 반드시 `set`을 사용한다.
- 불필요한 전역 변수 추가를 피한다.
- 스킬 내부 상태는 가능하면 해당 `scope`의 private 전역 배열로 제한한다.

## UI 작성 규칙

- UI 생성과 표시 상태는 `UI/` 폴더 안에서 관리한다.
- UI 이벤트에서 게임 상태를 바꿀 때는 필요한 경우 `DzSyncData`를 통해 동기화한다.
- 로컬 플레이어 전용 표시 코드는 `GetLocalPlayer()` 조건을 명확히 둔다.
- UI 파일은 매우 커지기 쉬우므로 새 UI는 기능 단위로 파일을 분리한다.

## NPC와 상호작용 규칙

- NPC 선택 이벤트는 `NPC.j`에서 관리한다.
- NPC 종류 판정은 `DataUnitIndex(u)`를 기준으로 한다.
- 상점, 창고, 강화, 아르카나 같은 UI 열기는 각 UI 시스템 함수로 위임한다.
- NPC 파일 안에 UI 세부 구현을 과도하게 넣지 않는다.

## 금지 또는 주의 사항

- 기존 정상 동작 코드를 이유 없이 전체 리팩터링하지 않는다.
- 빌드에 쓰는 파일과 백업 파일을 섞지 않는다.
- `Import.j`에 오래된 개인 PC 절대 경로를 새로 추가하지 않는다.
- `GetLocalPlayer()` 내부에서 동기화되는 게임 상태를 직접 바꾸지 않는다.
- 스킬 ID와 데이터 배열 인덱스를 임의로 바꾸지 않는다.
- 새 코드에서 `FX.j`, `연출()`, `연출효과_타이머()`를 사용하지 않는다.

## 새 스킬 추가 체크리스트

- [ ] `Data/Data Unit.j`에 스킬 ID, 쿨다운, 피해 배율을 등록했다.
- [ ] `Hero/SkillButton.j`에 키 입력과 sync 이름을 등록했다.
- [ ] `Hero/<HeroName>/Hero<HeroShortName><Key>.j` 파일을 만들었다.
- [ ] sync 이름과 `DzTriggerRegisterSyncData` 이름이 일치한다.
- [ ] `IssuePointOrder`의 주문 문자열이 실제 어빌리티 주문과 일치한다.
- [ ] `GetSpellAbilityId()`의 스킬 ID가 데이터와 일치한다.
- [ ] `CooldownFIX`가 정상 적용된다.
- [ ] 반복 실행 struct는 `tick.data = fx` 방식으로 전달한다.
- [ ] 종료 경로에서 tick과 handle 변수를 정리했다.
- [ ] `Import.j`에 파일을 등록했다.

## 정리 우선순위

1. 깨진 문서와 제작 규칙 정리
2. `Import.j`의 절대 경로 정리
3. 복사본 파일과 실제 사용 파일 구분
4. 영웅 스킬 파일 구조 통일
5. UI 대형 파일 분리
6. 데이터 테이블 정리

