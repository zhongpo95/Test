# 스크립트 보관

로그라이트 제작 중 사용하지 않게 된 스크립트와 크게 수정할 스크립트의 원본을 보관한다. 기존 보관 파일은 덮어쓰지 않는다.

## 보관 규칙

- 미사용으로 판단한 파일은 import, 호출부, 라이브러리 의존성, 초기화 및 이벤트 등록을 확인한 뒤 보관 폴더로 이동한다.
- 크게 수정할 파일은 수정 전에 원본을 보관한다. 현재 실행에 필요한 파일은 대체 구현과 참조 전환이 끝날 때 원래 위치에서 제외한다.
- 보관본은 당시 내용과 인코딩을 그대로 유지한다. 보관을 위해 파일의 주석이나 서식을 고치지 않는다.
- 작업별 폴더 안에 원래 상대 경로를 유지하고, 출처 커밋·보관 이유·이동 또는 원본 복사 여부를 기록한다.
- 보관 폴더는 활성 스크립트 import에 추가하지 않는다. 복구할 때는 당시 참조 관계와 현재 구현을 확인한다.

## 2026-09-19 로그라이트 제작 준비

출처 커밋은 `623bb5792fb5a8c21242b5c12d9d674c6c719501`이며, 보관 폴더는 `roguelite_2026-09-19`다.

| 원래 경로 | 보관 경로 | 처리 | 이유 |
|---|---|---|---|
| `ex.j` | [unused/ex.j](roguelite_2026-09-19/unused/ex.j) | 이동 | 명령창 UI 실험과 로그 함수 예제. Import.j에 포함되지 않고 저장소 내 외부 참조가 확인되지 않음 |
| `UI/UI_Achievement.j` | [unused/UI/UI_Achievement.j](roguelite_2026-09-19/unused/UI/UI_Achievement.j) | 이동 | 업적 UI 초안. Import.j 및 다른 스크립트의 라이브러리 의존성에서 사용하지 않음 |
| `UI/UI_Map.j` | [before_rewrite/UI/UI_Map.j](roguelite_2026-09-19/before_rewrite/UI/UI_Map.j) | 수정 전 원본 복사 | 23칸 원정 진행 및 경로 UI 개편 대상. 현재 Import.j와 영웅 선택에서 사용하므로 활성 파일 유지 |

보관 직전 원본과 보관 직후 파일의 SHA-256 일치를 확인했다.

| 원래 경로 | SHA-256 |
|---|---|
| `ex.j` | `1BD979AD6D39A935749708455F163A949A8A9E79C56C10051C492967CDDB3609` |
| `UI/UI_Achievement.j` | `3E555875F29C6508EB5C8651FD804F3B78468D48391FD9F1592A653D01175C49` |
| `UI/UI_Map.j` | `A84D754EECBBD0BCBA472D350B5DDB1F4995B652EAB28947D1CC6511DF844EBB` |

미사용 판정은 저장소의 텍스트 참조를 기준으로 한다. 외부 편집기 트리거와 배포 맵 내부의 직접 import는 이번 정리에서 검증하지 않았다. 위 원본 복사본은 수정 전 상태이며 이후 활성 파일 변경을 따라 갱신하지 않는다.

## 2026-09-19 첫 시험 원정 구현

출처 커밋은 `f7a9d56691019d48b735ae0e85828d3781413244`다. 다음 세 파일은 수정 전 작업 폴더의 CRLF 바이트를 그대로 복사했다. Git의 LF 저장본과는 줄바꿈을 정규화하여 내용 일치를 확인했다.

| 원래 경로 | 보관 경로 | 이유 | 보관 파일 SHA-256 |
|---|---|---|---|
| `System/SaveLoad.j` | [before_rewrite/System/SaveLoad.j](roguelite_2026-09-19/before_rewrite/System/SaveLoad.j) | 저장 요청 대기열과 완료 상태 연결 전 원본 | `ef8c4425310b00b744ec855df37d7ae7a8b69570b9925df4de28cfcd93f9469c` |
| `System/StatsSetting.j` | [before_rewrite/System/StatsSetting.j](roguelite_2026-09-19/before_rewrite/System/StatsSetting.j) | 임시 스탯·각인 합산과 표시 범위 수정 전 원본 | `04b786a50ea8e5abe45ea41db50872352d62bc7e4b5eb2b958125c3dc0315397` |
| `System/DamageEffect.j` | [before_rewrite/System/DamageEffect.j](roguelite_2026-09-19/before_rewrite/System/DamageEffect.j) | 원정 카드·피해 합산·관통 연결 전 원본 | `895754efa8fc3104e1fa71d9ebdcec95f587a812ffb801192b610c79cbbf6f64` |

기존에 보관한 `UI/UI_Map.j` 원본은 유지하고 활성 파일을 새 원정 화면으로 교체했다. 새 원정 스크립트는 별도 파일로 만들었으며, 보관 파일은 활성 import에 포함하지 않는다. 영웅 선택은 `SetMapLine` 호출을 유지하고 UI 라이브러리 의존성 선언만 추가했다.
