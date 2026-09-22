# Hera RPG v149 야에 사쿠라 E 수정

야에 사쿠라를 선택하고 E를 눌렀다 떼면 몬스터 없이도 종료되는 v148 입력 경로를 수정했습니다.

## 확인된 충돌 경로

- 2026-09-22 18.46.17과 18.47.32의 실제 덤프 예외는 모두 `Game.dll+0x95DE2`, `0xc0000005`입니다.
- 실패한 배열 조회의 인덱스 ESI는 두 덤프 모두 `852138`입니다. 첫 덤프의 활성 Lua C 콜백에서 같은 정수 인자가 확인됩니다.
- 이 값은 `shot/act.lua`가 야에 사쿠라 E 키 해제 때 호출하던 `message.order_immediate(852138)`의 명령 ID이며, 기존 A1S0 충전 해제와 연결됩니다.
- 충돌은 설치된 Lua 입력 브리지 호출 중 발생합니다. 정확한 DLL 내부 결함의 기원까지 확정한 것은 아닙니다. 몬스터 피해 처리나 방어력 조회 실패로 진단하지 않습니다.

## 변경

- E 키 해제에서 `HeraYaeRelease` 동기화 요청만 보냅니다. 해당 입력 네이티브를 호출하지 않습니다.
- 모든 클라이언트에 동일한 수신기를 초기화하고 실제 송신자의 영웅에 `IssueImmediateOrderById`를 실행합니다.
- 소유자, 야에 사쿠라 여부, 유닛 수명, 생존, 충전 상태, A1S0 보유를 확인합니다. 취소되었거나 잘못된 요청은 무시합니다.
- 원래 A1S0 시전 이벤트와 E 충전·피해 계산은 그대로 유지합니다. v148의 기존 유닛 수명 수정도 유지합니다.
- v149 입력 로그에 E 키를 추가하고 부팅 로그에 해제 요청 및 수신 결과를 최대 40건 기록합니다.

## 검증

- 정적 검사 완료. 추출 Lua 593개 문법, 수정 모듈 포함 및 원래 E/A1S0 코드 보존 확인.
- 빌드·패키지 검사 완료. MPQ 5,652개 블록의 해시, 알려진 파일 조회와 보호 로더 제외 확인.
- Lua 모의 검사 완료. 실제 E 입력 훅 및 A1S0 콜백을 사용한 37개 시나리오, 두 독립 클라이언트의 동일 명령, 여섯 슬롯, 중복·잘못된 요청 거부 확인.
- 기존 유닛 수명·지속 피해 및 방어력 회귀 검사 통과.
- Warcraft 실행, 실제 명령 수락·네트워크 순서·멀티 동기화, 충전과 타격 화면은 미검증입니다. JASS 로직 변경 및 JASS 재컴파일은 없습니다.

게임에서는 양쪽 모두 v149를 사용하고, 야에 사쿠라 선택 직후 빈 공간에서 E 짧게 누르기와 길게 충전 후 떼기를 확인합니다. 이후 몬스터 타격을 확인합니다.

맵 SHA256 `a07eeb9c07b0d8cc12f254cf93f1b981c8b6d35347c9472a36f825a2d830833e`

## 원본 작업 폴더에 적용

이 저장소에는 맵 원본과 모델팩을 넣지 않습니다. 별도 Hera RPG 작업 폴더의 v148 `hera-port`와 `build_hera_rpg.py`에 적용하는 패치입니다. v148을 보존한 복사본에서 실행합니다. Lua 모의 검사는 Lua 5.3을 포함한 Lupa 및 독립 검증기로 추출한 v148/v149 소스가 필요합니다.

```powershell
# 첫 번째 경로는 이 디렉터리, 현재 위치는 v148 맵 작업 폴더입니다.
$patchDirectory = '검토한 패치 디렉터리의 절대 경로'
git apply --check "$patchDirectory/integration.patch"
git apply "$patchDirectory/integration.patch"
Copy-Item -LiteralPath "$patchDirectory/yae_release.lua" -Destination './hera-port/scripts/gameplay/feature/shot/yae_release.lua'
python build_hera_rpg.py
node validate_hera_rpg.js Hera_RPG_Init_v149.w3x hera-rpg-validation-v149
python "$patchDirectory/check_v149.py" (Get-Location).Path
python "$patchDirectory/check_packaged_v149.py"
```

`integration.patch`는 기존 파일의 최소 변경만 포함하고 새 수신 모듈은 `yae_release.lua`에 있습니다. v149가 이미 적용된 폴더에 재적용하지 않습니다.
